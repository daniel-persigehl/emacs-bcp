;;; bcp-roman-proprium.el --- Proprium Sanctorum for the Roman Breviary -*- lexical-binding: t -*-

;;; Commentary:

;; Fixed-feast calendar (Sanctorale) for the Roman Breviary following
;; the 1911 Divino Afflatu rubrics.  Each feast entry specifies a rank,
;; an optional commune base, a collect, and optional proper overrides.
;;
;; Architecture:
;;   Calendar alist: ((MONTH . DAY) . FEAST-PLIST)
;;   Feast plist: :name :latin :rank :commune :collect + optional overrides
;;   Three-tier override: feast proper → commune → (replaces temporale)
;;
;; Rank system (1911 DA):
;;   duplex-i     — Duplex I classis (highest)
;;   duplex-ii    — Duplex II classis
;;   duplex-majus — Duplex majus
;;   duplex       — Duplex
;;   semiduplex   — Semiduplex
;;   simplex      — Simplex (commemoration only)
;;
;; Public API:
;;   `bcp-roman-proprium-feast'       — return feast plist for a date
;;   `bcp-roman-proprium-rank'        — return rank symbol for a date
;;   `bcp-roman-proprium--merged-data' — merge feast proper onto commune
;;   `bcp-roman-proprium--full-office-p' — t if feast gets its own office

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-calendar)
(require 'bcp-roman-commune)
(require 'bcp-roman-collectarium)
(require 'bcp-roman-psalterium)

(declare-function bcp-roman-breviary--resolve "bcp-roman-breviary")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Rank system

(defconst bcp-roman-proprium--rank-values
  '((duplex-i     . 6)
    (duplex-ii    . 5)
    (duplex-majus . 4)
    (duplex       . 3)
    (semiduplex   . 2)
    (simplex      . 1))
  "Numeric precedence values for feast ranks.")

(defun bcp-roman-proprium--rank-value (rank)
  "Return numeric precedence for RANK."
  (or (alist-get rank bcp-roman-proprium--rank-values) 0))

(defun bcp-roman-proprium--full-office-p (feast)
  "Return t if FEAST gets its own full office (not just a commemoration).
Semiduplex and above get full offices; simplex is commemoration only."
  (>= (bcp-roman-proprium--rank-value (plist-get feast :rank)) 2))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Three-tier merger

(defun bcp-roman-proprium--merged-data (feast)
  "Return merged feast data, overlaying proper onto commune base.
FEAST is the feast plist from the calendar.  Returns a new plist
with all commune keys filled in and feast-specific overrides applied.
For :lessons and :responsories, merges element-wise: non-nil feast
entries replace commune entries at the same index."
  (let* ((commune-key (plist-get feast :commune))
         (commune (when commune-key (bcp-roman-commune-get commune-key)))
         (merged (copy-sequence (or commune '()))))
    ;; Overlay all feast keys onto the commune base
    (cl-loop for (key val) on feast by #'cddr
             do (when val
                  (pcase key
                    ;; Element-wise merge for lists
                    ((or :lessons :responsories)
                     (let* ((base (plist-get merged key))
                            (result (cl-mapcar
                                     (lambda (proper commune-val)
                                       (or proper commune-val))
                                     val
                                     (or base (make-list (length val) nil)))))
                       (plist-put merged key result)))
                    ;; Skip internal keys that aren't data
                    ((or :name :latin :rank :commune)
                     nil)
                    ;; Simple overlay for everything else
                    (_
                     (plist-put merged key val)))))
    merged))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sunday interaction
;;
;; DA 1911 precedence: Sundays are I or II class.
;; I class Sundays: Advent I, Lent I–IV, Passion, Palm, Easter,
;;   Low Sunday (in Albis), Pentecost, Trinity.
;; II class: all other Sundays.
;;
;; On Sundays:
;;   Duplex I classis  — always celebrated (feast wins)
;;   Duplex II classis — celebrated on II class Sundays, transferred from I class
;;   Duplex majus/below — transferred from all Sundays (Sunday wins)
;;   Simplex           — commemoration only (always)
;;
;; When a feast is displaced, its collect is commemorated after the
;; Sunday collect.

(defun bcp-roman-proprium--sunday-class (date)
  "Return the class of the Sunday on DATE: 1 or 2.
Returns nil if DATE is not a Sunday."
  (let ((dow (calendar-day-of-week date)))
    (when (= dow 0)
      (let* ((year  (caddr date))
             (feasts (bcp-moveable-feasts year))
             (easter (cdr (assq 'easter feasts)))
             (easter-abs (calendar-absolute-from-gregorian easter))
             (abs (calendar-absolute-from-gregorian date))
             (diff (- abs easter-abs)))
        (cond
         ;; Easter Sunday
         ((= diff 0) 1)
         ;; Low Sunday (in Albis)
         ((= diff 7) 1)
         ;; Pentecost
         ((= diff 49) 1)
         ;; Trinity Sunday
         ((= diff 56) 1)
         ;; Septuagesima, Sexagesima, Quinquagesima
         ((memq diff '(-63 -56 -49)) 2)
         ;; Lent I–IV (diff = -42, -35, -28, -21)
         ((<= -42 diff -21) 1)
         ;; Passion Sunday (diff = -14)
         ((= diff -14) 1)
         ;; Palm Sunday (diff = -7)
         ((= diff -7) 1)
         ;; Advent I: need to compute
         ((let* ((adv1 (bcp-advent-1 year))
                 (adv1-abs (calendar-absolute-from-gregorian adv1)))
            (= abs adv1-abs))
          1)
         ;; All other Sundays
         (t 2))))))

(defun bcp-roman-proprium--feast-wins-p (feast date)
  "Return t if FEAST takes precedence over the Sunday on DATE.
Returns t on non-Sundays (feast always wins on weekdays).
Returns nil for simplex feasts (always commemoration-only)."
  (let ((dow (calendar-day-of-week date))
        (rank (plist-get feast :rank)))
    (cond
     ;; Simplex feasts never get their own office
     ((eq rank 'simplex) nil)
     ;; On weekdays, any semiduplex+ feast wins
     ((/= dow 0) t)
     ;; On Sundays, compare rank vs. Sunday class
     (t
      (let ((sunday-class (bcp-roman-proprium--sunday-class date))
            (rank-val (bcp-roman-proprium--rank-value rank)))
        (cond
         ;; Duplex I classis always wins
         ((= rank-val 6) t)
         ;; Duplex II classis wins on II class Sundays
         ((and (= rank-val 5) (= sunday-class 2)) t)
         ;; Everything else: Sunday wins
         (t nil)))))))

(defun bcp-roman-proprium--feast-impeded-p (feast date)
  "Return t if FEAST is impeded on DATE (cannot be celebrated).
A feast is impeded on Sundays where it doesn't win precedence."
  (let ((dow (calendar-day-of-week date)))
    (and (= dow 0)
         (not (bcp-roman-proprium--feast-wins-p feast date)))))

(defun bcp-roman-proprium--native-feast (date)
  "Return the feast natively assigned to DATE (ignoring transfers)."
  (or (bcp-roman-proprium--moveable-feast date)
      (alist-get (cons (car date) (cadr date))
                 bcp-roman-proprium--calendar
                 nil nil #'equal)))

(defun bcp-roman-proprium--transferable-p (feast)
  "Return t if FEAST can be transferred when impeded.
Only duplex and above can be transferred; semiduplex and simplex
get a commemoration only."
  (>= (bcp-roman-proprium--rank-value (plist-get feast :rank)) 3))

(defun bcp-roman-proprium--transfer-target (impeded-abs feast)
  "Find the absolute date where FEAST impeded on IMPEDED-ABS transfers to.
Returns the absolute date of the next day without a native feast of
equal or higher rank."
  (let ((feast-rank (bcp-roman-proprium--rank-value (plist-get feast :rank))))
    (cl-loop for try-abs from (1+ impeded-abs) to (+ impeded-abs 8)
             for try-date = (calendar-gregorian-from-absolute try-abs)
             for blocking = (bcp-roman-proprium--native-feast try-date)
             for blocking-rank = (if blocking
                                     (bcp-roman-proprium--rank-value
                                      (plist-get blocking :rank))
                                   0)
             ;; Transfer to the first day without a higher/equal native feast
             ;; and not a Sunday (feasts can't transfer onto Sundays)
             when (and (< blocking-rank feast-rank)
                       (/= (calendar-day-of-week try-date) 0))
             return try-abs)))

(defun bcp-roman-proprium--transferred-feast (date)
  "Return a feast transferred to DATE from a prior impeded day, or nil.
Scans back up to 8 days for impeded duplex+ feasts."
  (let ((date-abs (calendar-absolute-from-gregorian date)))
    (cl-loop for offset from 1 to 8
             for check-abs = (- date-abs offset)
             for check-date = (calendar-gregorian-from-absolute check-abs)
             for feast = (bcp-roman-proprium--native-feast check-date)
             when (and feast
                       (bcp-roman-proprium--transferable-p feast)
                       (bcp-roman-proprium--feast-impeded-p feast check-date))
             when (equal date-abs
                         (bcp-roman-proprium--transfer-target check-abs feast))
             return feast)))

(defun bcp-roman-proprium--commemoration-collect (date)
  "Return (COLLECT . FEAST) for any displaced feast on DATE, or nil.
A feast is displaced when:
  1. On Sundays: a non-transferable semiduplex+ feast loses to the Sunday.
  2. On weekdays: a native feast is displaced by an incoming transferred feast.
  3. An octave (infra-octave or octave day) is displaced by a higher feast.
Returns nil when no commemoration is due."
  (let* ((native (bcp-roman-proprium--native-feast date))
         (effective (bcp-roman-proprium-feast date))
         (dow (calendar-day-of-week date))
         (oct (bcp-roman-proprium--octave-feast date)))
    (cond
     ;; Case 1: Sunday — native feast loses to Sunday, gets commemoration
     ;; (only semiduplex; duplex+ transfers instead)
     ((and native
           (= dow 0)
           (not (bcp-roman-proprium--feast-wins-p native date))
           (bcp-roman-proprium--full-office-p native)
           (not (bcp-roman-proprium--transferable-p native)))
      (cons (plist-get native :collect) native))
     ;; Case 2: Weekday — native feast displaced by a transferred feast
     ((and native effective
           (/= dow 0)
           (not (equal (plist-get native :name) (plist-get effective :name)))
           (bcp-roman-proprium--full-office-p native))
      (cons (plist-get native :collect) native))
     ;; Case 3: Octave displaced by a higher feast
     ((and oct effective
           (not (equal (plist-get oct :name) (plist-get effective :name))))
      (cons (plist-get oct :collect) oct)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Octave system

;; 1911 DA octave classes:
;;   privileged-i   — Christmas, Easter, Pentecost (handled by season modules)
;;   privileged-ii  — Corpus Christi
;;   privileged-iii — Sacred Heart
;;   common         — St John Baptist, Sts Peter & Paul, St Lawrence,
;;                    Assumption, All Saints
;;   simple         — Nativity of BVM, St Stephen, St John Ap., Holy Innocents
;;
;; Effect: during the 8 days after the principal feast, infra-octave days
;; (days 2-7) have semiduplex rank and use the principal feast's collect.
;; The octave day (day 8) has duplex rank.
;;
;; Interaction with other feasts:
;;   - A feast of higher rank displaces the octave day
;;   - Infra-octave days yield to any duplex+ feast
;;   - When displaced, the octave gets a commemoration (collect)

(defconst bcp-roman-proprium--octaves
  '(;; Fixed-date octaves: (MONTH DAY PRIVILEGE OCTAVE-DAY-RANK)
    ;; Christmas-adjacent (Dec 26-28) handled by bcp-roman-season-christmas
    ((6 . 24) common      duplex-majus)   ; St John Baptist → Jul 1
    ((6 . 29) common      duplex-majus)   ; Sts Peter & Paul → Jul 6
    ((8 . 10) common      duplex)         ; St Lawrence → Aug 17
    ((8 . 15) common      duplex-majus)   ; Assumption → Aug 22
    ((9 . 8)  simple      duplex)         ; Nativity of BVM → Sep 15
    ((11 . 1) common      duplex-majus))  ; All Saints → Nov 8
  "Fixed-date feasts with octaves.
Each entry is ((MONTH . DAY) PRIVILEGE OCTAVE-DAY-RANK).
Easter, Pentecost, Christmas octaves are handled by season modules.
Corpus Christi and Sacred Heart octaves are in `--moveable-octaves'.")

(defconst bcp-roman-proprium--moveable-octaves
  '((60  privileged-ii  duplex-majus)   ; Corpus Christi
    (68  privileged-iii duplex-majus))   ; Sacred Heart
  "Moveable feasts with octaves: (EASTER-OFFSET PRIVILEGE OCTAVE-DAY-RANK).")

(defun bcp-roman-proprium--octave-info (date)
  "Return octave info for DATE if it falls within an octave, or nil.
Returns (PRINCIPAL-FEAST DAY-IN-OCTAVE PRIVILEGE OCTAVE-DAY-RANK)
where DAY-IN-OCTAVE is 2-7 for infra-octave or 8 for the octave day.
Day 1 (the feast itself) returns nil — that's handled as a normal feast."
  (let* ((date-abs (calendar-absolute-from-gregorian date))
         (year (caddr date)))
    (or
     ;; Check fixed-date octaves
     (cl-loop
      for (md privilege oct-rank) in bcp-roman-proprium--octaves
      for feast-date = (list (car md) (cdr md) year)
      for feast-abs = (calendar-absolute-from-gregorian feast-date)
      for day-n = (- date-abs feast-abs)
      when (<= 1 day-n 7)
      return (let ((feast (bcp-roman-proprium--native-feast feast-date)))
               (when feast
                 (list feast (1+ day-n) privilege oct-rank))))
     ;; Check moveable octaves
     (let* ((easter (bcp-easter year))
            (easter-abs (calendar-absolute-from-gregorian easter)))
       (cl-loop
        for (offset privilege oct-rank) in bcp-roman-proprium--moveable-octaves
        for feast-abs = (+ easter-abs offset)
        for day-n = (- date-abs feast-abs)
        when (<= 1 day-n 7)
        return (let ((feast-date (calendar-gregorian-from-absolute feast-abs)))
                 (let ((feast (bcp-roman-proprium--native-feast feast-date)))
                   (when feast
                     (list feast (1+ day-n) privilege oct-rank)))))))))

(defun bcp-roman-proprium--octave-feast (date)
  "Return a synthetic feast plist for an octave day on DATE, or nil.
For the octave day (day 8): returns a feast with the octave-day rank.
For infra-octave days (2-7): returns a semiduplex feast.
The feast uses the principal feast's collect and commune."
  (let ((info (bcp-roman-proprium--octave-info date)))
    (when info
      (let* ((principal (nth 0 info))
             (day-n     (nth 1 info))
             (oct-rank  (nth 3 info))
             (name      (plist-get principal :name))
             (latin     (plist-get principal :latin))
             (commune   (plist-get principal :commune))
             (collect   (plist-get principal :collect)))
        (if (= day-n 8)
            ;; Octave day
            (list :name (format "Octave of %s" name)
                  :latin (format "In Octava %s" latin)
                  :rank oct-rank
                  :commune commune
                  :collect collect)
          ;; Infra-octave day
          (list :name (format "%s (infra Oct.)" name)
                :latin (format "De ea infra Oct. %s" latin)
                :rank 'semiduplex
                :commune commune
                :collect collect))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Calendar

(defvar bcp-roman-proprium--calendar nil
  "Alist of ((MONTH . DAY) . FEAST-PLIST) for the fixed-feast calendar.")

;;;; Moveable feasts (Easter-dependent)

(defconst bcp-roman-proprium--moveable-feasts
  '((:offset 60
     :name "Corpus Christi"
     :latin "In Festo Sanctíssimi Córporis Christi"
     :rank duplex-i
     :commune nil
     :collect deus-qui-nobis-sub-sacramento

     ;; ── Matins ──
     ;; Proper office (Thomas Aquinas).
     ;; Noc I: 1 Cor 11. Noc II: Thomas Aquinas Opusc. 57. Noc III: Augustine Tract. 26 in Joann.
     :invitatory christum-regem-adoremus-dominantem
     :hymn sacris-solemniis
     :psalms-1 ((fructum-salutiferum . 1)
                (a-fructu-frumenti . 4)
                (communione-calicis . 15))
     :psalms-2 ((memor-sit-dominus . 19)
                (paratur-nobis-mensa . 22)
                (in-voce-exsultationis . 41))
     :psalms-3 ((introibo-ad-altare-sumam . 42)
                (cibavit-nos-dominus-ex-adipe . 80)
                (ex-altari-tuo-domine . 83))
     :versicle-1 ("Panem cæli dedit eis, allelúja."
                  "Panem Angelórum manducávit homo, allelúja.")
     :versicle-1-en ("He gave them of the bread of heaven, alleluia."
                     "Man did eat angels' food, alleluia.")
     :versicle-2 ("Cibávit illos ex ádipe fruménti, allelúja."
                  "Et de petra, melle saturávit eos, allelúja.")
     :versicle-2-en ("He fed them with the finest of the wheat, alleluia."
                     "And with honey out of the rock hath he satisfied them, alleluia.")
     :versicle-3 ("Edúcas panem de terra, allelúja."
                  "Et vinum lætíficet cor hóminis, allelúja.")
     :versicle-3-en ("That thou mayest bring forth bread out of the earth, alleluia."
                     "And wine that maketh glad the heart of man, alleluia.")

     :lessons
     (;; ── Nocturn I: 1 Corinthians 11 ──

      (:ref "1 Cor 11:20-22"
       :source "De Epístola prima beáti Pauli Apóstoli ad Corínthios"
       :text "\
Conveniéntibus ergo vobis in unum, jam non est Domínicam cenam manducáre. Unusquísque enim suam cenam \
præsúmit ad manducándum. Et álius quidem ésurit, álius autem ébrius est. Numquid domos non habétis ad \
manducándum et bibéndum? aut Ecclésiam Dei contémnitis, et confúnditis eos, qui non habent? Quid dicam \
vobis? Laudo vos? In hoc non laudo.")

      (:ref "1 Cor 11:23-26"
       :text "\
Ego enim accépi a Dómino quod et trádidi vobis, quóniam Dóminus Jesus, in qua nocte tradebátur, accépit \
panem, et grátias agens fregit, et dixit: Accípite, et manducáte: hoc est corpus meum, quod pro vobis \
tradétur: hoc fácite in meam commemoratiónem. Simíliter et cálicem, postquam cœnávit, dicens: Hic calix \
novum testaméntum est in meo sánguine: hoc fácite, quotiescúmque bibétis, in meam commemoratiónem. \
Quotiescúmque enim manducábitis panem hunc, et cálicem bibétis, mortem Dómini annuntiábitis donec véniat.")

      (:ref "1 Cor 11:27-32"
       :text "\
Itaque quicúmque manducáverit panem hunc, vel bíberit cálicem Dómini indígne, reus erit córporis et \
sánguinis Dómini. Probet autem seípsum homo: et sic de pane illo edat, et de cálice bibat. Qui enim \
mandúcat et bibit indígne, judícium sibi mandúcat et bibit, non dijúdicans corpus Dómini. Ideo inter vos \
multi infírmi et imbecílles, et dórmiunt multi. Quod, si nosmetípsos dijudicarémus, non útique judicarémur. \
Dum judicámur autem, a Dómino corrípimur, ut non cum hoc mundo damnémur.")

      ;; ── Nocturn II: Thomas Aquinas, Opusc. 57 ──

      (:ref "Opusc."
       :source "Sermo sancti Thomæ Aquinátis\nLectio iv in opusculo 57"
       :text "\
Imménsa divínæ largitátis benefícia, exhíbita pópulo christiáno, inæstimábilem ei cónferunt dignitátem. \
Neque enim est, aut fuit aliquándo tam grandis nátio, quæ hábeat deos appropinquántes sibi, sicut adest \
nobis Deus noster. Unigénitus síquidem Dei Fílius, suæ divinitátis volens nos esse partícipes, natúram \
nostram assúmpsit, ut hómines deos fáceret factus homo. Et hoc ínsuper, quod de nostro assúmpsit, totum \
nobis cóntulit ad salútem. Corpus namque suum pro nostra reconcilatióne in ara crucis hóstiam óbtulit Deo \
Patri, sánguinem suum fudit in prétium simul et lavácrum; ut redémpti a miserábili servitúte, a peccátis \
ómnibus mundarémur. Ut autem tanti benefícii jugis in nobis manéret memória, corpus suum in cibum, et \
sánguinem suum in potum, sub spécie panis et vini suméndum fidélibus derelíquit.")

      (:ref "Opusc."
       :text "\
O pretiósum et admirándum convívium, salutíferum et omni suavitáte replétum! Quid enim hoc convívio \
pretiósius esse potest? in quo non carnes vitulórum et hircórum, ut olim in lege, sed nobis Christus \
suméndus propónitur verus Deus. Quid hoc Sacraménto mirabílius? In ipso namque panis et vinum in Christi \
corpus et sánguinem substantiáliter convertúntur; ideóque Christus, Deus et homo perféctus, sub módici \
panis et vini spécie continétur. Manducátur ítaque a fidélibus, sed mínime lacerátur; quinímmo, divíso \
Sacraménto, sub quálibet divisiónis partícula ínteger persevérat. Accidéntia autem sine subjécto in eódem \
subsístunt, ut fides locum hábeat, dum visíbile invisibíliter súmitur aliéna spécie occultátum; et sensus \
a deceptióne reddántur immúnes, qui de accidéntibus júdicant sibi notis.")

      (:ref "Opusc."
       :text "\
Nullum étiam sacraméntum est isto salúbrius, quo purgántur peccáta, virtútes augéntur, et mens ómnium \
spirituálium charísmatum abundántia impinguátur. Offértur in Ecclésia pro vivis et mórtuis, ut ómnibus \
prosit, quod est pro salúte ómnium institútum. Suavitátem dénique hujus Sacraménti nullus exprímere \
súfficit, per quod spirituális dulcédo in suo fonte gustátur; et recólitur memória illíus, quam in sua \
passióne Christus monstrávit, excellentíssimæ caritátis. Unde, ut árctius hujus caritátis imménsitas \
fidélium córdibus infigerétur, in última cena, quando Pascha cum discípulis celebráto, transitúrus erat \
de hoc mundo ad Patrem, hoc Sacraméntum instítuit, tamquam passiónis suæ memoriále perénne, figurárum \
véterum impletívum, miraculórum ab ipso factórum máximum; et de sua contristátis abséntia solátium \
singuláre relíquit.")

      ;; ── Nocturn III: Augustine, Tract. 26 in Joann. ──

      (:ref "John 6:56-59"
       :source "Léctio sancti Evangélii secúndum Joánnem\nJoannes 6:56-59\nIn illo témpore: Dixit Jesus turbis Judæórum: Caro mea vere est cibus, et sanguis meus vere est potus. Et réliqua.\n\nHomilía sancti Augustíni Epíscopi\nTractatus 26 in Joannem, sub finem"
       :text "\
Cum cibo et potu id áppetant hómines, ut neque esúriant, neque sítiant: hoc veráciter non præstat, nisi \
iste cibus et potus, qui eos, a quibus súmitur, immortáles et incorruptíbiles facit; id est, socíetas \
ipsa Sanctórum, ubi pax erit et únitas plena atque perfécta. Proptérea quippe, sicut étiam ante nos hoc \
intellexérunt hómines Dei, Dóminus noster Jesus Christus corpus et sánguinem suum in eis rebus \
commendávit, quæ ad unum áliquid redigúntur ex multis. Namque áliud in unum ex multis granis confícitur: \
áliud in unum ex multis ácinis cónfluit. Dénique jam expónit, quómodo id fiat, quod lóquitur; et quid \
sit manducáre corpus ejus, et sánguinem bíbere.")

      (:ref "John 6:56-59"
       :text "\
Qui mandúcat carnem meam et bibit meum sánguinem, in me manet, et ego in illo. Hoc est ergo manducáre \
illam escam, et illum bíbere potum, in Christo manére, et illum manéntem in se habére. Ac per hoc, qui \
non manet in Christo, et in quo non manet Christus, proculdúbio nec mandúcat spiritáliter carnem ejus, \
nec bibit ejus sánguinem, licet carnáliter et visibíliter premat déntibus Sacraméntum córporis et \
sánguinis Christi: sed magis tantæ rei sacraméntum ad judícium sibi mandúcat et bibit, quia immúndus \
præsúmpsit ad Christi accédere Sacraménta, quæ áliquis non digne sumit, nisi qui mundus est; de quibus \
dícitur: Beáti mundo corde, quóniam ipsi Deum vidébunt.")

      (:ref "John 6:56-59"
       :text "\
Sicut, inquit, misit me vivens Pater, et ego vivo propter Patrem: et qui mandúcat me, et ipse vivet \
propter me. Ac si díceret: Ut ego vivam propter Patrem, id est, ad illum tamquam ad majórem réferam \
vitam meam, exinanítio mea fecit, in qua me misit: ut autem quisquam vivat propter me, participátio \
facit, qua mandúcat me. Ego ítaque humiliátus vivo propter Patrem: ille eréctus vivit propter me. Si \
autem ita dictus est, Vivo propter Patrem, quia ipse de illo, non ille de ipso est; sine detriménto \
æqualitátis dictum est. Nec tamen dicéndo, Et qui mandúcat me, et ipse vivet propter me; eándem suam \
et nostram æqualitátem significávit, sed grátiam mediatóris osténdit."))

     :responsories
     ((:respond "Immolábit hædum multitúdo filiórum Israël ad vésperam Paschæ:"
       :verse "Pascha nostrum immolátus est Christus: ítaque epulémur in ázymis sinceritátis et veritátis."
       :repeat "Et edent carnes et ázymos panes.")
      (:respond "Comedétis carnes, et saturabímini pánibus:"
       :verse "Non Móyses dedit vobis panem de cælo, sed Pater meus dat vobis panem de cælo verum."
       :repeat "Iste est panis, quem dedit vobis Dóminus ad vescéndum.")
      (:respond "Respéxit Elías ad caput suum subcinerícium panem: qui surgens comédit et bibit:"
       :verse "Si quis manducáverit ex hoc pane, vivet in ætérnum."
       :repeat "Et ambulávit in fortitúdine cibi illíus usque ad montem Dei."
       :gloria t)
      (:respond "Cenántibus illis, accépit Jesus panem, et benedíxit, ac fregit, dedítque discípulis suis, et ait:"
       :verse "Dixérunt viri tabernáculi mei: Quis det de cárnibus ejus, ut saturémur?"
       :repeat "Accípite et comédite: hoc est corpus meum.")
      (:respond "Accépit Jesus cálicem, postquam cenávit, dicens: Hic calix novum testaméntum est in meo sánguine:"
       :verse "Memória memor ero, et tabéscet in me ánima mea."
       :repeat "Hoc fácite in meam commemoratiónem.")
      (:respond "Ego sum panis vitæ; patres vestri manducavérunt manna in desérto, et mórtui sunt:"
       :verse "Ego sum panis vivus, qui de cælo descéndi: si quis manducáverit ex hoc pane, vivet in ætérnum."
       :repeat "Hic est panis de cælo descéndens, ut, si quis ex ipso mandúcet, non moriátur."
       :gloria t)
      (:respond "Qui mandúcat meam carnem et bibit meum sánguinem,"
       :verse "Non est ália nátio tam grandis, quæ hábeat deos appropinquántes sibi, sicut Deus noster adest nobis."
       :repeat "In me manet, et ego in eo.")
      (:respond "Misit me vivens Pater, et ego vivo propter Patrem:"
       :verse "Cibávit illum Dóminus pane vitæ et intelléctus."
       :repeat "Et qui mandúcat me, vivet propter me."
       :gloria t)))

    (:offset 68
     :name "Sacred Heart of Jesus"
     :latin "Sacratíssimi Cordis D.N.J.C."
     :rank duplex-i
     :commune nil
     :collect deus-qui-nobis-in-corde

     ;; ── Matins ──
     ;; Proper office.
     ;; Noc I: Jeremiah. Noc II: Historical (Devotion to the Sacred Heart). Noc III: Bonaventure on John 19.
     :invitatory cor-jesu-amore-nostri
     :hymn auctor-beate-saeculi
     :psalms-1 ((cogitationes-cordis-ejus . 32)
                (apud-te-est-fons-vitae . 35)
                (homo-pacis-meae . 40))
     :psalms-2 ((rex-omnis-terrae-deus . 46)
                (dum-anxiaretur-cor-meum . 60)
                (secundum-multitudinem-dolorum . 93))
     :psalms-3 ((qui-diligitis-dominum-confitemini . 96)
                (viderunt-omnes-termini . 97)
                (psallam-tibi-in-nationibus . 107))
     :versicle-1 ("Tóllite jugum meum super vos et díscite a me."
                  "Quia mitis sum et húmilis Corde.")
     :versicle-1-en ("Take my yoke upon you, and learn of me."
                     "For I am meek and lowly in Heart.")
     :versicle-2 ("Ego dixi, Dómine, miserére mei."
                  "Sana ánimam meam quia peccávi tibi.")
     :versicle-2-en ("I said: Lord, be merciful unto me."
                     "Heal my soul, for I have sinned against thee.")
     :versicle-3 ("Memóriam fecit mirabílium suórum miserátor Dóminus."
                  "Escam dedit timéntibus se.")
     :versicle-3-en ("The merciful Lord hath instituted a memorial of his wondrous deeds."
                     "He hath given meat unto them that fear him.")

     :lessons
     (;; ── Nocturn I: Jeremiah ──

      (:ref "Jer 24:5-7"
       :source "De Jeremía Prophéta"
       :text "\
Hæc dicit Dóminus, Deus Israël: Cognóscam transmigratiónem Juda, quam emísi de loco isto in terram \
Chaldæórum, in bonum. Et ponam óculos meos super eos ad placándum, et redúcam eos in terram hanc; et \
ædificábo eos, et non déstruam; et plantábo eos et non evéllam. Et dabo eis cor ut sciant me, quia ego \
sum Dóminus; et erunt mihi in pópulum, et ego ero eis in Deum, quia reverténtur ad me in toto corde suo.")

      (:ref "Jer 30:18-19, 21-24"
       :text "\
Hæc dicit Dóminus: Ecce ego convértam conversiónem tabernaculórum Jacob, et tectis ejus miserébor, et \
ædificábitur cívitas in excélso suo, et templum juxta órdinem suum fundábitur, et egrediétur de eis \
laus, voxque ludéntium. Et erit dux ejus ex eo, et princeps de médio ejus producétur; et, applicábo eum \
et accédet ad me. Quis enim iste est qui ápplicet cor suum ut appropínquet mihi? ait Dóminus. Et éritis \
mihi in pópulum, et ego ero vobis in Deum. Ecce turbo Dómini, furor egrédiens, procélla ruens; in cápite \
impiórum conquiéscet. Non avértet iram indignatiónis Dóminus, donec fáciat et cómpleat cogitatiónem \
Cordis sui: in novíssimo diérum intellegétis ea.")

      (:ref "Jer 31:1-3, 31-33"
       :text "\
In témpore illo, dicit Dóminus, ero Deus univérsis cognatiónibus Israël, et ipsi erunt mihi in pópulum. \
Hæc dicit Dóminus: Invénit grátiam in desérto pópulus qui remánserat a gládio; vadet ad réquiem suam \
Israël. Longe Dóminus appáruit mihi. Et in caritáte perpétua diléxi te: ídeo attráxi te, míserans. Ecce \
dies vénient, dicit Dóminus: et fériam dómui Israël et dómui Juda fœdus novum: non secúndum pactum, quod \
pépigi cum pátribus eórum in die, qua apprehéndi manum eórum, ut edúcerem eos de Terra Ægýpti: pactum \
quod írritum fecérunt, et ego dominátus sum eórum, dicit Dóminus. Sed hoc erit pactum, quod fériam cum \
domo Israël: post dies illos dicit Dóminus: Dabo legem meam in viscéribus eórum, et in corde eórum \
scribam eam: et ero eis in Deum, et ipsi erunt mihi in pópulum.")

      ;; ── Nocturn II: Historical (Devotion to the Sacred Heart) ──

      (:ref "Encycl."
       :source "Ex história devotiónis erga sacratíssimum Cor Jesu"
       :text "\
Inter mira sacræ doctrínæ pietatísque increménta, quibus divínæ Sapiéntiæ consília clárius in dies \
Ecclésiæ manifestántur, vix áliud magis conspícuum est quam triumphális progréssio cultus sacratíssimi \
Cordis Jesu. Sǽpius quidem, priórum decúrsu témporum, Patres, Doctóres, Sancti, Redemptóris nostri \
amórem celebrárunt: vulnus in látere Christi apértum ómnium gratiárum arcánum dixérunt fontem. At inde a \
médio ævo, cum tenerióre quadam erga sanctíssimam Salvatóris Humanitátem religióne fidéles áffici cœpti \
sunt, ánimæ contemplatívæ per plagam illam ad ipsum Cor, amóre hóminum vulnerátum, penetráre fere \
solébant. Atque ex eo témpore hæc contemplátio sanctíssimis quibúsque ita familiáris evásit, ut neque \
régio neque ordo religiósus sit, in quibus non insígnia, hac ætáte, ejus reperiántur testimónia.")

      (:ref "Encycl."
       :text "\
Verum, ad cultum sacratíssimi Cordis Jesu plene perfectéque constituéndum, eundémque per totum orbem \
propagándum, Deus ipse sibi instruméntum elégit humíllimam ex órdine Visitatiónis vírginem, sanctam \
Margarítam Maríam Alacóque, cui, a prima quidem ætáte jam in Eucharístiæ Sacraméntum amóre flagránti, \
Christus Dóminus sæpenúmero appárens, divíni Cordis sui et divítias et optáta significáre dignátus est. \
Quarum apparitiónum celebérrima illa est, qua ei ante Eucharístiam oránti Jesus conspiciéndum se dedit, \
sacratíssimum Cor osténdit et conquéstus quod, pro imménsa sua caritáte, nihil nisi ingratórum hóminum \
contumélias recíperet, ipsi præcépit ut novum festum, féria sexta post Octávam Córporis Christi, \
instituéndum curáret, quo Cor suum honóre débito colerétur, atque injúriæ sibi in Sacraménto amóris a \
peccatóribus illátæ dignis expiaréntur obséquiis.")

      (:ref "Encycl."
       :text "\
Anno tandem millésimo septingentésimo sexagésimo quinto, Clemens décimus tértius Póntifex Máximus \
offícium et missam in honórem sacratíssimi Cordis Jesu approbávit; Pius vero nonus festum ad univérsam \
Ecclésiam exténdit. Exínde, cultus sacratíssimi Cordis, quasi flumen exúndans, prolútis impediméntis \
ómnibus, per totum se orbem effúdit, et, novo illucescénte sǽculo, jubilǽo indícto, Leo décimus tértius \
humánum genus univérsum sacratíssimo Cordi devótum vóluit. Quæ consecrátio, in ómnibus quidem cathólici \
orbis ecclésiis, solémni ritu perácta, ingens áttulit devotiónis hujus increméntum, et ad eam non solum \
pópulos, verum étiam singuláres famílias addúxit, quæ Divíno Cordi innumerábiles se dévovent, regióque \
ejus império subíciunt.")

      ;; ── Nocturn III: Bonaventure on John 19:31-37 ──

      (:ref "John 19:31-37"
       :source "Léctio sancti Evangélii secúndum Joánnem\nJoannes 19:31-37\nIn illo témpore: Judǽi, quóniam parascéve erat, ut non remanérent in cruce córpora sábbato rogavérunt Pilátum, ut frangeréntur eórum crura et tolleréntur. Et réliqua.\n\nHomilía sancti Bonaventúræ Epíscopi\nLiber de ligno vitæ, num. 30"
       :text "\
Ut de látere Christi dormiéntis in cruce formarétur Ecclésia, et Scriptúra implerétur quæ dicit: Vidébunt \
in quem transfixérunt, divína est ordinatióne indúltum ut unus mílitum láncea latus illud sacrum aperiéndo \
perfóderet, quátenus sánguine cum aqua manánte, prétium effunderétur nostræ salútis quod a fonte scílicet \
Cordis arcáno profúsum, vim daret sacraméntis Ecclésiæ ad vitam grátiæ conferéndam, essétque jam in \
Christo vivéntibus póculum fontis vivi, saliéntis in vitam ætérnam. Surge ígitur, ánima amíca Christi, \
vigiláre non cesses, ibi os appóne, ut háurias aquas de fóntibus salvatóris.")

      (:ref "John 19:31-37"
       :source "De vite mystica, cap. 3"
       :text "\
Quia semel vénimus ad Cor Dómini Jesu dulcíssimi, et bonum est nos hic esse, non fácile evellámur ab eo. \
O quam bonum et jucúndum habitáre in Corde hoc. Bonus thesáurus, pretiósa margaríta Cor tuum, óptime \
Jesu, quam, fosso agro córporis tui, invenímus. Quis hanc margarítam abíciat? Quin pótius, dabo omnes \
margarítas, cogitatiónes et affectiónes meas commutábo et comparábo illam mihi, jactans omnem cogitátum \
meum in Cor boni Jesu, et sine fallácia illud me enútriet. Hoc ígitur tuo et meo Corde, dulcíssime Jesu, \
invénto, orábo te Deum meum: admítte in sacrárium exauditiónis preces meas: immo me totum trahe in Cor tuum.")

      (:ref "John 19:31-37"
       :text "\
Ad hoc enim perforátum est latus tuum, ut nobis páteat intróitus. Ad hoc vulnerátum est Cor tuum, ut in \
illo ab exterióribus turbatiónibus absolúti habitáre possímus. Nihilóminus et proptérea vulnerátum est, ut \
per vulnus visíbile, vulnus amóris invisíbile videámus. Quómodo hic ardor mélius posset osténdi, nisi quod \
non solum corpus, verum étiam ipsum Cor láncea vulnerári permísit? Carnále ergo vulnus, vulnus spirituále \
osténdit. Quis illud Cor tam vulnerátum non díligat? quis tam amántem non rédamet? quis tam castum non \
amplectátur? Nos ígitur adhuc in carne manéntes, quantum póssumus, amántem redamémus, amplectámur \
vulnerátum nostrum, cujus ímpii agrícolæ fodérunt manus et pedes, latus et Cor; oremúsque ut cor nostrum, \
adhuc durum et impœ́nitens, amóris sui vínculo constríngere et jáculo vulneráre dignétur."))

     :responsories
     ((:respond "Fériam eis pactum sempitérnum et non désinam eis benefácere et timórem meum dabo in corde eórum"
       :verse "Et lætábor super eis cum bene eis fécero in toto Corde meo."
       :repeat "Ut non recédant a me.")
      (:respond "Si inimícus meus maledixísset mihi, sustinuíssem útique"
       :verse "Et si is qui me óderat super me magna locútus fuísset, abscondíssem me fórsitan ab eo."
       :repeat "Tu vero homo unánimis qui simul mecum dulces capiébas cibos.")
      (:respond "Cum essémus mórtui peccátis, convivificávit nos Deus in Christo"
       :verse "Ut osténderet in sǽculis superveniéntibus abundántes divítias grátiæ suæ."
       :repeat "Propter nímiam caritátem suam qua diléxit nos."
       :gloria t)
      (:respond "Prope est Dóminus ómnibus invocántibus eum,"
       :verse "Miserátor et miséricors Dóminus, pátiens et multum miséricors."
       :repeat "Omnibus invocántibus eum in veritáte.")
      (:respond "Confíteor tibi, Pater, Dómine cæli et terræ, quia abscondísti hæc a sapiéntibus et prudéntibus"
       :verse "Ita, Pater, quóniam sic fuit plácitum ante te."
       :repeat "Et revelásti ea párvulis.")
      (:respond "Omnes gentes quascúmque fecísti, vénient"
       :verse "Et glorificábunt nomen tuum, quóniam magnus es tu, et fáciens mirabília."
       :repeat "Et adorábunt coram te, Dómine."
       :gloria t)
      (:respond "Ego si exaltátus fúero a terra"
       :verse "Hoc autem dicébat signíficans qua morte esset moritúrus."
       :repeat "Omnia traham ad meípsum.")
      (:respond "Simus ergo imitatóres Dei"
       :verse "Sicut et Christus diléxit nos et trádidit semetípsum pro nobis."
       :repeat "Et ambulémus in dilectióne."
       :gloria t))))
  "Moveable feasts defined as Easter offsets.
Each entry has :offset (days after Easter), plus standard feast plist keys.")

(defun bcp-roman-proprium--christ-the-king (year)
  "Return (MONTH DAY YEAR) for Christ the King in YEAR.
Last Sunday of October."
  (let* ((oct-31-dow (calendar-day-of-week (list 10 31 year)))
         (day (- 31 oct-31-dow)))
    (list 10 day year)))

(defconst bcp-roman-proprium--christ-the-king-plist
  '(:name "Christ the King"
    :latin "D.N. Jesu Christi Regis"
    :rank duplex-i
    :commune nil
    :collect omnipotens-sempiterne-deus-qui-in-dilecto

    ;; ── Matins ──
    ;; Proper office (1925 Quas primas).
    ;; Noc I: Colossians 1. Noc II: Pius XI Encycl. Quas primas. Noc III: Augustine on John 18.
    :invitatory jesum-christum-regem-regum
    :hymn aeterna-imago-altissimi
    :psalms-1 ((ego-autem-constitutus-sum-rex . 2)
               (gloria-et-honore-coronasti . 8)
               (elevamini-portae-aeternales . 23))
    :psalms-2 ((sedebit-dominus-rex . 28)
               (virga-directionis . 44)
               (psallite-regi-nostro . 46))
    :psalms-3 ((benedicentur-in-ipso . 71)
               (et-ego-primogenitum . "88(2-30)")
               (thronus-ejus-sicut-sol . "88(31-53)"))
    :versicle-1 ("Data est mihi omnis potéstas."
                 "In cælo et in terra.")
    :versicle-1-en ("Given to me is all power."
                    "In heaven and in earth.")
    :versicle-2 ("Afférte Dómino, famíliæ populórum."
                 "Afférte Dómino glóriam et impérium.")
    :versicle-2-en ("Bring ye to the Lord, O ye families of the nations."
                    "Bring ye to the Lord glory and dominion.")
    :versicle-3 ("Adorábunt eum omnes reges terræ."
                 "Omnes gentes sérvient ei.")
    :versicle-3-en ("All kings shall adore him."
                    "All nations shall serve him.")

    :lessons
    (;; ── Nocturn I: Colossians 1 ──

     (:ref "Col 1:3-8"
      :source "De Epistola beáti Pauli Apóstoli ad Colossénses"
      :text "\
Grátias agimus Deo, et Patri Dómini nostri Jesu Christi, semper pro vobis orántes, audiéntes fidem \
vestram in Christo Jesu, et dilectiónem quam habétis in sanctos omnes, propter spem, quæ repósita est \
vobis in cælis, quam audístis in verbo veritátis Evangélii, quod pervénit ad vos, sicut et in univérso \
mundo est, et fructíficat, et crescit, sicut in vobis, ex ea die, qua audístis, et cognovístis grátiam \
Dei in veritáte, sicut didicístis ab Epáphra, caríssimo consérvo nostro, qui est fidélis pro vobis \
miníster Christi Jesu, qui étiam manifestávit nobis dilectiónem vestram in spíritu.")

     (:ref "Col 1:9-17"
      :text "\
Ideo et nos ex qua die audívimus, non cessámus pro vobis orántes, et postulántes ut impleámini agnitióne \
voluntátis ejus, in omni sapiéntia et intelléctu spiritáli; ut ambulétis digne Deo per ómnia placéntes; \
in omni ópere bono fructificántes, et crescéntes in sciéntia Dei: in omni virtúte confortáti secúndum \
poténtiam claritátis ejus, in omni patiéntia et longanimitáte cum gáudio; grátias agéntes Deo Patri, \
qui dignos nos fecit in partem sortis sanctórum in lúmine, qui erípuit nos de potestáte tenebrárum, et \
tránstulit in regnum Fílii dilectiónis suæ, in quo habémus redemptiónem per sánguinem ejus, remissiónem \
peccatórum. Qui est imágo Dei invisíbilis, primogénitus omnis creatúræ; quóniam in ipso cóndita sunt \
univérsa in cælis et in terra, visibília, et invisibília, sive Throni, sive Dominatiónes, sive \
Principátus, sive Potestátes: ómnia per ipsum et in ipso creáta sunt: et ipse est ante omnes, et ómnia \
in ipso constant.")

     (:ref "Col 1:18-23"
      :text "\
Et ipse est caput córporis Ecclésiæ, qui est princípium, primogénitus ex mórtuis, ut sit in ómnibus ipse \
primátum tenens; quia in ipso complácuit omnem plenitúdinem inhabitáre, et per eum reconciliáre ómnia in \
ipsum, pacíficans per sánguinem crucis ejus, sive quæ in terris, sive quæ in cælis sunt. Et vos, cum \
essétis aliquándo alienáti, et inimíci sensu in opéribus malis; nunc autem reconciliávit in córpore \
carnis ejus per mortem, exhibére vos sanctos, et immaculátos, et irreprehensíbiles coram ipso; si tamen \
permanétis in fide fundáti, et stábiles, et immóbiles a spe evangélii, quod audístis, quod prædicátum \
est in univérsa creatúra quæ sub cælo est, cujus factus sum ego Paulus miníster.")

     ;; ── Nocturn II: Pius XI, Quas primas (1925) ──

     (:ref "Encycl."
      :source "Ex Lítteris Encýclicis Pii Papæ undécimi\nLitt. Encycl. « Quas primas » diei 11 Decembris 1925"
      :text "\
Cum Annus sacer non unam ad illustrándum Christi regnum habúerit opportunitátem, vidémur rem factúri \
Apostólico múneri in primis consentáneam, si, plurimórum Patrum Cardinálium, Episcopórum fideliúmque \
précibus, concedéntes, hunc ipsum Annum peculiári festo Dómini Nostri Jesu Christi Regis in \
ecclesiásticam liturgíam inducéndo clausérimus. Ut transláta verbi significatióne Rex appellarétur \
Christus ob summum excelléntiæ gradum, quo inter omnes res creátas præstat atque éminet, jam diu \
communitérque usu venit. Ita enim fit, ut regnare is « in méntibus hóminum » dicátur non tam ob mentis \
áciem scientiǽque suæ amplitúdinem, quam quod ipse est Véritas, et veritátem ab eo mortáles hauríre \
atque obediénter accípere necésse est; « in voluntátibus » item « hóminum », quia non modo sanctitáti in \
eo voluntátis divínæ perfécta prorsus respóndet humánæ intégritas atque obtemperátio, sed étiam líberæ \
voluntáti nostræ id permotióne instinctúque suo súbicit, unde ad nobilíssima quæque exardescámus.")

     (:ref "Encycl."
      :text "\
Quo autem hæc Dómini nostri dígnitas et potéstas fundaménto consístat, apte Cyríllus Alexandrínus \
animadvértit: « Omnium, ut verbo dicam, creaturárum dominátum óbtinet, non per vim extórtum, nec \
aliúnde invéctum, sed esséntia sua et natúra »; scílicet ejus principátus illa nítitur unióne mirábili, \
quam hypostáticam appéllant. Unde conséquitur, non modo ut Christus ab Angelis et homínibus Deus sit \
adorándus, sed étiam ut ejus império Hóminis, Angeli et hómines páreant et subjécti sint: nempe ut vel \
solo hypostáticæ uniónis nómine Christus potestátem in univérsas creatúras obtíneat.")

     (:ref "Encycl."
      :text "\
Verúmtamen ejúsmodi regnum præcípuo quodam modo et spirituále esse et ad spirituália pertinére, cum ea, \
quæ ex Bíbliis supra protúlimus, verba planíssime osténdunt, tum Christus Dóminus sua agéndi ratióne \
confírmat. Síquidem, non una data occasióne, cum Judǽi, immo vel ipsi Apóstoli, per errórem censérent, \
fore ut Messías pópulum in libertátem vindicáret regnúmque Israël restitúeret, vanam ipse opiniónem ac \
spem adímere et convéllere; rex a circumfúsa admirántium multitúdine renuntiándus, et nomen et honórem \
fugiéndo latendóque detrectáre; coram prǽside Románo edícere, regnum suum « de hoc mundo » non esse. \
Itaque, auctoritáte Nostra apostólica, festum Dómini Nostri Jesu Christi Regis institúimus, quotánnis, \
postrémo mensis octóbris domínico die, qui scílicet Omnium Sanctórum celebritátem próxime antecédit, \
ubíque terrárum agéndum.")

     ;; ── Nocturn III: Augustine on John 18:33-37 ──

     (:ref "John 18:33-37"
      :source "Léctio sancti Evangélii secúndum Joánnem\nJoannes 18:33-37\nIn illo témpore: Dixit Pilátus ad Jesum: Tu es Rex Judæórum? Et réliqua.\n\nHomilía sancti Augustíni Epíscopi\nTract. 51 in Joann. 12-13; Tract 117 in Joann. 19-21"
      :text "\
Quid magnum fuit Regi sæculórum Regem fíeri hóminum? Non enim Rex Israël Christus ad exigéndum \
tribútum vel exércitum ferro armándum hostésque visibíliter debellándos; sed Rex Israël, quod mentes \
regat, quod in ætérnum cónsulat, quod in regnum cælórum credéntes, sperántes amantésque perdúcat. \
Dei ergo Fílius æquális Patri, Verbum per quod facta sunt ómnia, quod Rex esse vóluit Israël, dignátio \
est, non promótio; miseratiónis indícium est, non potestátis augméntum. Qui enim appellátus est in terra \
Rex Judæórum, in cælis est Dóminus Angelórum. Sed Judæórum tantum Rex est Christus, an et géntium? \
Immo et géntium.")

     (:ref "John 18:33-37"
      :source "Tract. 115 in Joannem 18-36"
      :text "\
Respóndit Jesus: Regnum meum non est de hoc mundo. Si ex hoc mundo esset regnum meum, minístri mei \
útique decertárent, ut non tráderer Judǽis; nunc autem regnum meum non est hinc. Hoc est quod bonus \
Magíster scire nos vóluit; sed prius nobis demonstránda fúerat vana hóminum de regno ejus opínio, sive \
géntium, sive Judæórum a quibus id Pilátus audíerat: quasi proptérea morte fuísset plecténdus, quod \
illícitum affectáverit regnum, vel quóniam solent regnatúris invidére regnántes, et vidélicet cavéndum \
erat ne ejus regnum sive Románis, sive Judǽis esset advérsum.")

     (:ref "John 18:33-37"
      :text "\
Póterat autem Dóminus quod ait, Regnum meum non est de hoc mundo, ad primam interrogatiónem prǽsidis \
respondére, ubi ei dixit, Tu es rex Judæórum? sed eum vicíssim intérrogans, utrum hoc a semetípso \
díceret, an audísset ab áliis, illo respondénte osténdere vóluit hoc sibi apud illum fuísse a Judǽis \
velut crimen objéctum: patefáciens nobis cogitatiónes hóminum, quas ipse nóverat, quóniam vanæ sunt; \
eísque post responsiónem Piláti, jam Judǽis et géntibus opportúnius aptiúsque respóndens, Regnum meum \
non est de hoc mundo."))

    :responsories
    ((:respond "Super sólium David et super regnum ejus sedébit in ætérnum:"
      :verse "Multiplicábitur ejus impérium, et pacis non erit finis."
      :repeat "Et vocábitur nomen ejus Deus, Fortis, Princeps pacis.")
     (:respond "Aspiciébam in visu noctis, et ecce in núbibus cæli Fílius hóminis veniébat: et datum est ei regnum et honor:"
      :verse "Potéstas ejus, potéstas ætérna, quæ non auferétur: et regnum ejus, quod non corrumpétur."
      :repeat "Et omnis pópulus, tribus et linguæ sérvient ei.")
     (:respond "Tu Béthlehem Ephrata, párvulus in míllibus Juda: ex te mihi egrediétur qui sit dominátor in Israël:"
      :verse "Egréssus ejus ab inítio, a diébus æternitátis: stabit, et pascet in fortitúdine Dómini."
      :repeat "Et erit iste Pax."
      :gloria t)
     (:respond "Exsúlta satis, fília Sion; júbila, fília Jerúsalem: ecce Rex tuus véniet tibi justus et Salvátor:"
      :verse "Potéstas ejus a mari usque ad mare: et a flumínibus usque ad fines terræ."
      :repeat "Et loquétur pacem géntibus.")
     (:respond "Opórtet illum regnáre, quóniam ómnia subjécit Deus sub pédibus ejus:"
      :verse "Cum subjécta fúerint illi ómnia, tunc et ipse Fílius subjéctus erit Patri."
      :repeat "Ut sit Deus ómnia in ómnibus.")
     (:respond "Fecit nos regnum et sacerdótes Deo et Patri suo:"
      :verse "Ipse est primogénitus mortuórum, et princeps regum terræ."
      :repeat "Ipsi glória et impérium, in sǽcula sæculórum."
      :gloria t)
     (:respond "Factum est regnum hujus mundi Dómini nostri et Christi ejus:"
      :verse "Adorábunt in conspéctu ejus univérsæ famíliæ géntium; quóniam Dómini est regnum."
      :repeat "Et regnábit in sǽcula sæculórum.")
     (:respond "Decem córnua quæ vidísti, decem reges sunt. Hi cum Agno pugnábunt, et Agnus vincet illos:"
      :verse "Regnávit Dóminus Deus noster omnípotens: gaudeámus et exsultémus, et demus glóriam ei."
      :repeat "Quóniam Dóminus dominórum est, et Rex regum."
      :gloria t)))
  "Feast plist for Christ the King (last Sunday of October).")

(defun bcp-roman-proprium--moveable-feast (date)
  "Return feast plist for a moveable feast on DATE, or nil.
DATE is (MONTH DAY YEAR)."
  (let* ((year (caddr date))
         (easter (bcp-easter year))
         (easter-abs (calendar-absolute-from-gregorian easter))
         (date-abs (calendar-absolute-from-gregorian date)))
    (or
     ;; Check Easter-offset feasts
     (cl-loop for entry in bcp-roman-proprium--moveable-feasts
              for offset = (plist-get entry :offset)
              when (= date-abs (+ easter-abs offset))
              return (cl-loop for (k v) on entry by #'cddr
                              unless (eq k :offset) append (list k v)))
     ;; Check Christ the King
     (let ((ctk (bcp-roman-proprium--christ-the-king year)))
       (when (equal date ctk)
         bcp-roman-proprium--christ-the-king-plist)))))

(defun bcp-roman-proprium-feast (date)
  "Return feast plist for DATE, or nil if no feast.
DATE is (MONTH DAY YEAR).  Priority order:
  1. Native feast that wins on this day
  2. Transferred feast from a prior impeded day
  3. Octave day or infra-octave day (if no higher feast)
  4. Native feast (impeded — for commemoration purposes)
  5. nil"
  (let ((native (bcp-roman-proprium--native-feast date)))
    (cond
     ;; Native feast that wins on this day
     ((and native (bcp-roman-proprium--feast-wins-p native date))
      native)
     ;; Check for a transferred feast landing on this day
     ((bcp-roman-proprium--transferred-feast date))
     ;; Octave day/infra-octave (when no native feast occupies the day)
     ((let ((oct (bcp-roman-proprium--octave-feast date)))
        (when (and oct
                   (or (not native)
                       ;; Native simplex yields to octave
                       (eq (plist-get native :rank) 'simplex)))
          oct)))
     ;; Native feast exists but is impeded — simplex/semiduplex
     ;; still returns for commemoration purposes (caller checks rank)
     (native native)
     ;; No feast
     (t nil))))

(defun bcp-roman-proprium-rank (date)
  "Return rank symbol for the feast on DATE, or nil."
  (plist-get (bcp-roman-proprium-feast date) :rank))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Feast ordo builders

(defun bcp-roman-proprium--vespers-ordo (date feast vespers-n)
  "Build feast Vespers ordo for DATE using FEAST data.
VESPERS-N is 1 for I Vespers or 2 for II Vespers."
  (let* ((data (bcp-roman-proprium--merged-data feast))
         (psalms-key (if (= vespers-n 2) :vespers2-psalms :vespers-psalms))
         (psalms (or (plist-get data psalms-key)
                     (plist-get data :vespers-psalms)))
         (hymn (or (plist-get data :vespers-hymn)
                   (plist-get data :lauds-hymn)))
         (mag-key (if (= vespers-n 2) :magnificat2-antiphon :magnificat-antiphon))
         (mag-ant (plist-get data mag-key))
         (collect (plist-get feast :collect)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Psalmi cum Antiphonis
      ,@(mapcar (lambda (pair)
                  `(:psalm ,(cdr pair) :antiphon ,(car pair)))
                psalms)
      ;; Capitulum
      (:capitulum feast-vespers-capitulum)
      ;; Hymnus
      (:hymn ,hymn)
      ;; Versus
      (:versicles feast-vespers-versicle)
      ;; Canticum: Magnificat
      (:canticle magnificat :antiphon ,(or mag-ant 'magnificat-anima-mea-quia))
      ;; Oratio
      (:pre-oratio)
      (:collect ,collect)
      ;; Conclusio
      (:conclusio)
      ;; Antiphona finalis B.M.V.
      (:marian-antiphon))))

(defun bcp-roman-proprium--lauds-ordo (date feast)
  "Build feast Lauds ordo for DATE using FEAST data."
  (let* ((data (bcp-roman-proprium--merged-data feast))
         (psalms (plist-get data :lauds-psalms))
         (hymn (plist-get data :lauds-hymn))
         (ben-ant (plist-get data :benedictus-antiphon))
         (collect (plist-get feast :collect)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Psalmi cum Antiphonis
      ,@(mapcar (lambda (pair)
                  `(:psalm ,(cdr pair) :antiphon ,(car pair)))
                psalms)
      ;; Capitulum
      (:capitulum feast-lauds-capitulum)
      ;; Hymnus
      (:hymn ,hymn)
      ;; Versus
      (:versicles feast-lauds-versicle)
      ;; Canticum: Benedictus
      (:canticle benedictus :antiphon ,(or ben-ant 'benedictus-dominus-deus-israel))
      ;; Oratio
      (:pre-oratio)
      (:collect ,collect)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-proprium--prime-ordo (date feast)
  "Build feast Prime ordo for DATE using FEAST data."
  (let* ((data (bcp-roman-proprium--merged-data feast))
         (psalms-data (bcp-roman-psalterium-prime-psalms 0)) ; Sunday scheme
         (ant  (plist-get psalms-data :antiphon))
         (pss  (plist-get psalms-data :psalms))
         (collect (plist-get feast :collect)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Hymnus
      (:hymn jam-lucis-orto-sidere)
      ;; Psalmi (Sunday scheme)
      (:antiphon ,ant)
      ,@(mapcar (lambda (ps) `(:psalm ,ps)) pss)
      (:antiphon ,ant :repeat t)
      ;; Capitulum
      (:capitulum feast-prime-capitulum)
      ;; Responsorium breve
      (:versicles prime-versicle)
      ;; Preces feriales
      (:rubric "[Confíteor... Misereátur... Indulgéntiam...]")
      (:preces preces-feriales-prime)
      ;; Martyrologium
      (:rubric "[Martyrológium]")
      ;; Oratio
      (:pre-oratio)
      (:collect ,collect)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-proprium--minor-hour-ordo (date feast hour)
  "Build feast minor hour ordo for DATE using FEAST data.
HOUR is terce, sext, or none."
  (let* ((data (bcp-roman-proprium--merged-data feast))
         ;; Psalms: Sunday scheme from psalterium
         (psalms-fn (pcase hour
                      ('terce #'bcp-roman-psalterium-terce-psalms)
                      ('sext  #'bcp-roman-psalterium-sext-psalms)
                      ('none  #'bcp-roman-psalterium-none-psalms)))
         (ps-data (funcall psalms-fn 0)) ; Sunday
         (pss  (plist-get ps-data :psalms))
         ;; Antiphon: first Lauds antiphon from commune (Antiphonas horas)
         (lauds-psalms (plist-get data :lauds-psalms))
         (ant (if lauds-psalms (caar lauds-psalms) (plist-get ps-data :antiphon)))
         (hymn-key  (pcase hour
                      ('terce 'nunc-sancte-nobis-spiritus)
                      ('sext  'rector-potens-verax-deus)
                      ('none  'rerum-deus-tenax-vigor)))
         (cap-key   (pcase hour
                      ('terce 'feast-terce-capitulum)
                      ('sext  'feast-sext-capitulum)
                      ('none  'feast-none-capitulum)))
         (vers-key  (pcase hour
                      ('terce 'feast-terce-versicle)
                      ('sext  'feast-sext-versicle)
                      ('none  'feast-none-versicle)))
         (collect (plist-get feast :collect)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Hymnus
      (:hymn ,hymn-key)
      ;; Psalmi (Sunday scheme, single antiphon)
      (:antiphon ,ant)
      ,@(mapcar (lambda (ps) `(:psalm ,ps)) pss)
      (:antiphon ,ant :repeat t)
      ;; Capitulum
      (:capitulum ,cap-key)
      ;; Versus
      (:versicles ,vers-key)
      ;; Oratio
      (:pre-oratio)
      (:collect ,collect)
      ;; Conclusio
      (:conclusio))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Feast resolver (data-fn)

(defvar bcp-roman-proprium--current-feast nil
  "Merged feast data for the current render pass.
Let-bound during feast office rendering.")

(defun bcp-roman-proprium--resolve (key)
  "Resolve data KEY for a feast office.
Falls back to `bcp-roman-breviary--resolve' for shared texts."
  (let ((data bcp-roman-proprium--current-feast)
        (lang bcp-roman-office-language))
    (pcase key
      ;; ── Feast capitula (from commune data) ──
      ('feast-vespers-capitulum (plist-get data :vespers-capitulum))
      ('feast-lauds-capitulum   (or (plist-get data :lauds-capitulum)
                                    (plist-get data :vespers-capitulum)))
      ('feast-prime-capitulum   (or (plist-get data :prime-capitulum)
                                    (plist-get data :lauds-capitulum)))
      ('feast-terce-capitulum   (or (plist-get data :lauds-capitulum)
                                    (plist-get data :vespers-capitulum)))
      ('feast-sext-capitulum    (or (plist-get data :sext-capitulum)
                                    (plist-get data :vespers-capitulum)))
      ('feast-none-capitulum    (or (plist-get data :prime-capitulum)
                                    (plist-get data :lauds-capitulum)))

      ;; ── Feast versicles ──
      ('feast-vespers-versicle
       (let ((v (if (eq lang 'english)
                    (plist-get data :vespers-versicle-en)
                  (plist-get data :vespers-versicle))))
         (or v (plist-get data :vespers-versicle))))
      ('feast-lauds-versicle
       (let ((v (if (eq lang 'english)
                    (plist-get data :lauds-versicle-en)
                  (plist-get data :lauds-versicle))))
         (or v (plist-get data :lauds-versicle))))
      ;; Minor hour versicles: reuse Lauds versicle as fallback
      ((or 'feast-terce-versicle 'feast-sext-versicle 'feast-none-versicle)
       (let ((v (if (eq lang 'english)
                    (plist-get data :lauds-versicle-en)
                  (plist-get data :lauds-versicle))))
         (or v (plist-get data :lauds-versicle))))

      ;; ── Matins lessons and responsories (used by existing feast ordo) ──
      ((and (pred symbolp)
            (let name (symbol-name key))
            (guard (string-match "\\`matins-lesson-\\([0-9]+\\)\\'" name)))
       (let* ((n (string-to-number (match-string 1 name)))
              (lessons (plist-get data :lessons)))
         (nth (1- n) lessons)))

      ((and (pred symbolp)
            (let name (symbol-name key))
            (guard (string-match "\\`matins-responsory-\\([0-9]+\\)\\'" name)))
       (let* ((n (string-to-number (match-string 1 name)))
              (resps (plist-get data :responsories)))
         (nth (1- n) resps)))

      ;; ── Nocturn versicles ──
      ((and (pred symbolp)
            (let name (symbol-name key))
            (guard (string-match
                    "\\`matins-feast-versicle-\\([1-3]\\)\\'" name)))
       (let* ((n (string-to-number (match-string 1 name)))
              (vkey (if (eq lang 'english)
                        (intern (format ":versicle-%d-en" n))
                      (intern (format ":versicle-%d" n)))))
         (plist-get data vkey)))

      ;; ── Fall through to standard resolver ──
      (_ (bcp-roman-breviary--resolve key)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Collect registrations (extracted from DO Sancti)

(bcp-roman-collectarium-register
 'adesto-domine-supplicationibus-nostris-ut
 (list :latin "Adésto, Dómine, supplicatiónibus nostris: ut, qui ex iniquitáte nostra reos nos esse cognóscimus, beatórum Mártyrum tuórum Vincéntii et Anastásii intercessióne liberémur."
       :conclusion 'per-dominum
       :translations
       '((do . "Let thy merciful ears, O Lord, be open unto our prayers, and whereas we do feel ourselves burdened by the guilt of our sins, do Thou graciously relieve us at the petition of thy blessed Martyrs, Vincent and Anastasius."))))

(bcp-roman-collectarium-register
 'adesto-supplicationibus-nostris-omnipotens-deus
 (list :latin "Adésto supplicatiónibus nostris, omnípotens Deus: et, quibus fidúciam sperándæ pietátis indúlges, intercedénte beáto Augustíno Confessóre tuo atque Pontífice, consuétæ misericórdiæ tríbue benígnus efféctum."
       :conclusion 'per-dominum
       :translations
       '((do . "Graciously hear our supplications, O Almighty God, and as Thou hast given unto us the hope that we are of the number of them upon whom Thou wilt show mercy, grant unto us in thy goodness, that, helped by the prayers of thy blessed Confessor and Bishop Augustine, we may experience the fulfillment of thine accustomed loving-kindness."))))

(bcp-roman-collectarium-register
 'auxilium-tuum-nobis-domine-quaesumus
 (list :latin "Auxílium tuum nobis, Dómine, quǽsumus, placátus impénde: et, intercessióne beáti Ubáldi Confessóris tui atque Pontíficis, contra omnes diáboli nequítias déxteram super nos tuæ propitiatiónis exténde."
       :conclusion 'per-dominum
       :translations
       '((do . "Graciously help us, we beseech thee, O Lord, and at the petition of thy blessed Confessor and Bishop Ubald, stretch forth the right hand of thy mercy to shield us against all the fiery darts of the wicked one."))))

(bcp-roman-collectarium-register
 'beatae-mariae-magdalenae-quaesumus-domine
 (list :latin "Beátæ Maríæ Magdalénæ, quǽsumus, Dómine, suffrágiis adjuvémur: cujus précibus exorátus, quatriduánum fratrem Lázarum vivum ab ínferis resuscitásti:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O Lord, we pray thee, that we may be helped by the pleading of Blessed Mary Magdalen, whose prayers so much availed with thee, that Thou didst call up her brother Lazarus living from the dead, when he had lain in the grave four days already."))))

(bcp-roman-collectarium-register
 'beati-apostoli-et-evangelistae-matthaei
 (list :latin "Beáti Apóstoli et Evangelístæ Matthǽi, Dómine, précibus adjuvémur: ut, quod possibílitas nostra non óbtinet, ejus nobis intercessióne donétur."
       :conclusion 'per-dominum
       :translations
       '((do . "Help us, O Lord, by the prayers of thine holy Apostle and Evangelist Matthew, that what for ourselves we are not able to obtain, may be freely given us at his petition."))))

(bcp-roman-collectarium-register
 'beatorum-martyrum-cypriani-et-justinae
 (list :latin "Beatórum Mártyrum Cypriáni et Justínæ nos, Dómine, fóveant continuáta præsídia: quia non désinis propítius intuéri, quos tálibus auxíliis concésseris adjuvári."
       :conclusion 'per-dominum
       :translations
       '((do . "Lord, let the succour of thy blessed martyrs Cyprian and Justina never fail us, since Thou never ceasest to look in mercy upon any unto whom Thou dost grant the stay of such helpers."))))

(bcp-roman-collectarium-register
 'beatorum-martyrum-tuorum-domine-chrysanthi
 (list :latin "Beatórum Mártyrum tuórum, Dómine, Chrysánthi et Daríæ, quǽsumus, adsit nobis orátio: ut, quos venerámur obséquio, eórum pium júgiter experiámur auxílium."
       :conclusion 'per-dominum
       :translations
       '((do . "Lord, may Your holy Martyrs Chrysanthus and Daria assist us by their prayers. We offer them our homage; may we always experience their loving aid."))))

(bcp-roman-collectarium-register
 'beatorum-martyrum-tuorum-proti-et
 (list :latin "Beatórum Mártyrum tuórum Proti et Hyacínthi nos, Dómine, fóveat pretiósa conféssio: et pia júgiter intercéssio tueátur."
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we beseech thee, that the feast of thy blessed Martyrs and Bishops Protus and Hyacinth may keep us, and their worshipful prayers commend us."))))

(bcp-roman-collectarium-register
 'bonorum-omnium-largitor-omnipotens-deus
 (list :latin "Bonórum ómnium largítor, omnípotens Deus, qui beátam Rosam, cæléstis grátiæ rore prævéntam, virginitátis et patiéntiæ decóre Indis floréscere voluísti: da nobis fámulis tuis; ut, in odórem suavitátis ejus curréntes, Christi bonus odor éffici mereámur:"
       :conclusion 'qui-vivis
       :translations
       '((do . "Almighty God, from Whom cometh down every good and perfect gift, and Who didst cause the dew of thy grace to fall early from heaven upon this blessed Rose, making the same to blossom in the Indies, as a flower whose loveliness was virginity and long-suffering, grant unto thy servants, who do run after the smell of her perfumes, worthily themselves to become a sweet savour unto Christ."))))

(bcp-roman-collectarium-register
 'caelestium-donorum-distributor-deus-qui
 (list :latin "Cæléstium donórum distribútor, Deus, qui in angélico júvene Aloísio miram vitæ innocéntiam pari cum pœniténtia sociásti: ejus méritis et précibus concéde; ut, innocéntem non secúti, pœniténtem imitémur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, bestower of heavenly gifts, Who in the angelic youth Aloysius joined wondrous innocence of life to an equally wondrous love of penance; grant, by his merits and prayers, that we who have not followed him in his innocence may imitate him in his penance."))))

(bcp-roman-collectarium-register
 'clementissime-deus-qui-beatam-elisabeth
 (list :latin "Clementíssime Deus, qui beátam Elísabeth regínam, inter céteras egrégias dotes, béllici furóris sedándi prærogatíva decorásti: da nobis, ejus intercessióne; post mortális vitæ, quam supplíciter pétimus, pacem, ad ætérna gáudia perveníre."
       :conclusion 'per-dominum
       :translations
       '((do . "O most merciful God, Who didst ennoble the blessed Queen Elizabeth with diverse excellent graces, and withal with a gift of stilling the tempest of war, grant unto us through her pleading, in this dying life that peace for which we humbly pray, and hereafter to attain unto everlasting joy in thy Presence."))))

(bcp-roman-collectarium-register
 'clementissime-deus-qui-sanctum-silvestrum
 (list :latin "Clementíssime Deus, qui sanctum Silvéstrum Abbátem, sǽculi hujus vanitátem in apérto túmulo pie meditántem, ad erémum vocáre, et præcláris vitæ méritis decoráre dignátus es: te súpplices exorámus; ut, ejus exémplo terréna despiciéntes, tui consórtio perfruámur ætérno."
       :conclusion 'per-dominum
       :translations
       '((do . "Most merciful God, Who when the holy Abbot Sylvester was devoutly meditating upon the vanity of this world beside an open grave, graciously willed to call him into the desert and enrich him with unusual merits, we humbly pray that, following his example, despising the things of earth, we may thoroughly enjoy Thy everlasting presence."))))

(bcp-roman-collectarium-register
 'concede-nobis-quaesumus-domine-ut
 (list :latin "Concéde nobis, quǽsumus, Dómine: ut, qui solemnitátem beatæ Maríæ Vírginis Regínæ nostræ celebrámus; ejus muníti præsídio, pacem in præsénti et glóriam in futúro cónsequi mereámur."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, O Lord, we beseech Thee, to those who are celebrating this solemnity of the Blessed Virgin Mary our Queen: that safe in her protection we may deserve to enjoy present peace and future glory."))))

(bcp-roman-collectarium-register
 'concede-quaesumus-ecclesiae-tuae-omnipotens
 (list :latin "Concéde, quǽsumus, Ecclésiæ tuæ, omnípotens Deus: ut beátum Stéphanum Confessórem tuum, quem regnántem in terris propagatórem hábuit, propugnatórem habére mereátur gloriósum in cælis."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant unto thy Church, we beseech thee, O Almighty God, that even as thy blessed Confessor Stephen, while he was a King upon earth, was her forwarder, so, now that he is a glorious Saint in heaven, he may be her defender."))))

(bcp-roman-collectarium-register
 'concede-quaesumus-omnipotens-deus-ut
 (list :latin "Concéde, quǽsumus, omnípotens Deus: ut fidéles tui, qui sub sanctíssimæ Vírginis Maríæ Nómine et protectióne lætántur; ejus pia intercessióne, a cunctis malis liberéntur in terris, et ad gáudia ætérna perveníre mereántur in cælis."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant we beseech thee, O Almighty God, that thy faithful people, who rejoice in the Name and keeping of the most holy Virgin Mary, may by her Motherly prayers be freed from all ills upon earth, and worthily attain unto thine everlasting joy in heaven."))))

(bcp-roman-collectarium-register
 'da-ecclesiae-tuae-quaesumus-domine
 (list :latin "Da Ecclésiæ tuæ, quǽsumus, Dómine, sanctis Martýribus tuis Vito, Modésto atque Crescéntia intercedéntibus, supérbe non sápere, sed tibi plácita humilitáte profícere: ut, prava despíciens, quæcúmque recta sunt, líbera exérceat caritáte."
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we pray thee to grant unto thy Church through the prayers of thine Holy Martyrs Vitus, Modestus, and Crescentia, to mind not high things, but in all lowliness to do ever such things as be pleasing in thy sight, looking down upon all such things as be corrupt, and working ever in love unfeigned such things as be righteous."))))

(bcp-roman-collectarium-register
 'da-nobis-quaesumus-domine-beati
 (list :latin "Da nobis, quǽsumus, Dómine, beáti Apóstoli tui Thomæ solemnitátibus gloriári: ut ejus semper et patrocíniis sublevémur; et fidem cóngrua devotióne sectémur."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant us, Lord, we beseech thee, to glory in the solemnity of thy blessed Apostle Thomas, that we may ever be aided by his patronage, and follow his faith with true devotion."))))

(bcp-roman-collectarium-register
 'da-nobis-quaesumus-domine-imitari
 (list :latin "Da nobis, quǽsumus, Dómine, imitári quod cólimus: ut discámus et inimícos dilígere; quia ejus natalícia celebrámus, qui novit étiam pro persecutóribus exoráre Dóminum nostrum Jesum Christum Fílium tuum:"
       :conclusion 'qui-vivis
       :translations
       '((do . "Grant us, we beseech thee, O Lord, so to imitate what we revere, that we may learn to love even our enemies; for we celebrate the heavenly birthday of him who knew how to pray for his very persecutors to our Lord Jesus Christ:"))))

(bcp-roman-collectarium-register
 'da-nobis-quaesumus-omnipotens-deus
 (list :latin "Da nobis, quǽsumus, omnípotens Deus, beato Cyríllo Pontífice intercedénte: te solum verum Deum, et quem misísti Jesum Christum ita cognóscere; ut inter oves, quæ vocem ejus áudiunt, perpétuo connumerári mereámur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O Almighty God, grant unto us, we beseech thee, at the prayers of thy blessed Bishop Cyril, so to know thee, the only true God, and Jesus Christ Whom Thou hast sent, that we may hear His Voice, and He may give unto us eternal life."))))

(bcp-roman-collectarium-register
 'da-nobis-quaesumus-omnipotens-deus-0810
 (list :latin "Da nobis, quǽsumus, omnípotens Deus: vitiórum nostrórum flammas exstínguere; qui beáto Lauréntio tribuísti tormentórum suórum incéndia superáre."
       :conclusion 'per-dominum
       :translations
       '((do . "O Almighty God, Who didst give unto Blessed Lawrence power to be more than conqueror in his fiery torment, grant unto us, we beseech thee, the power to quench the flames of our sinful lusts."))))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut
 (list :latin "Da, quǽsumus, omnípotens Deus: ut, qui beátæ Catharínæ Vírginis tuæ natalícia cólimus; et ánnua solemnitáte lætémur, et tantæ virtútis proficiámus exémplo."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech thee, O Almighty God, that we which do keep the birthday of thy blessed Virgin Katharine, and do year by year renew her memorial with solemn gladness in thy presence, may likewise be conformed to the pattern of her saintly walk with thee."))))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0514
 (list :latin "Da, quǽsumus, omnípotens Deus: ut qui beáti Bonifátii Mártyris tui solémnia cólimus, ejus apud te intercessiónibus adjuvémur."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech thee, O Almighty God, that we who do make solemn remembrance of thine holy Martyr, Boniface, may be helped in thy presence by his prayers."))))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0813
 (list :latin "Da, quǽsumus, omnípotens Deus: ut beatórum Mártyrum tuórum Hippólyti et Cassiáni veneránda solémnitas, et devotiónem nobis áugeat, et salútem."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech Thee, O Almighty God, that the worshipful Feast of Thy blessed Martyrs Hippolytus and Cassian may avail us to the increase both of godliness toward Thee, and healthfulness to our own souls."))))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-1020
 (list :latin "Da, quǽsumus, omnípotens Deus: ut, sancti Joánnis Confessóris exémplo in sciéntia Sanctórum proficiéntes, atque áliis misericórdiam exhibéntes; ejus méritis, indulgéntiam apud te consequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech thee, O Almighty God, that we may so follow after the example of thy blessed Confessor John in learning ever more and more the knowledge which maketh thy Saints, and in showing mercy to our neighbour, that Thou for the same thy servant's sake mayest forgive us our trespasses."))))

(bcp-roman-collectarium-register
 'deus-auctor-pacis-et-amator
 (list :latin "Deus, auctor pacis et amátor caritátis, qui beátum Joánnem Confessórem tuum mirífica dissidéntes componéndi grátia decorásti: ejus méritis et intercessióne concéde; ut, in tua caritáte firmáti, nullis a te tentatiónibus separémur."
       :conclusion 'per-dominum
       :translations
       '((do . "God, the Author of peace and Lover of concord, Who didst wonderfully adorn thy blessed Confessor John with the grace of making peace between them that were at war, grant unto us for his sake and by his prayers, to be so solidly established in the love of thyself, that no trials whatsoever may be able to part us from thee."))))

(bcp-roman-collectarium-register
 'deus-cujus-hodierna-die-praeconium
 (list :latin "Deus, cujus hodiérna die præcónium Innocéntes Mártyres non loquéndo, sed moriéndo conféssi sunt: ómnia in nobis vitiórum mala mortífica; ut fidem tuam, quam lingua nostra lóquitur, étiam móribus vita fateátur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, whose praise the martyred Innocents on this day confessed, not by speaking, but by dying, destroy all the evils of sin in us, that our life also may proclaim in deeds, thy faith which our tongues profess."))))

(bcp-roman-collectarium-register
 'deus-cujus-unigenitus-per-vitam
 (list :latin "Deus, cujus Unigénitus per vitam, mortem et resurrectiónem suam nobis salútis ætérnæ prǽmia comparávit: concéde, quǽsumus; ut hæc mystéria sacratíssimo beátæ Maríæ Vírginis Rosário recoléntes, et imitémur quod cóntinent, et quod promíttunt, assequámur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Whose only-begotten Son, by His life, death and resurrection, has merited for us the grace of eternal salvation, grant, we beseech You, that, meditating upon those mysteries in the most holy Rosary of the Blessed Virgin Mary, we may imitate what they contain and obtain what they promise."))))

(bcp-roman-collectarium-register
 'deus-fidelium-remunerator-animarum-qui
 (list :latin "Deus, fidélium remunerátor animárum, qui hunc diem beáti Apollináris Sacerdótis tui martýrio consecrásti: tríbue nobis, quǽsumus, fámulis tuis; ut, cujus venerándam celebrámus festivitátem, précibus ejus indulgéntiam consequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who art thyself the exceeding great Reward of all faithful souls, and in Whose sight this day is holy because thy blessed Priest Apollinaris did hereon lift up his last earthly testimony, we beseech thee to grant unto us thy servants, who do keep his worshipful Feast-day, to obtain by his prayers thy gracious remission for our offences."))))

(bcp-roman-collectarium-register
 'deus-humilium-celsitudo-qui-beatum
 (list :latin "Deus, humílium celsitúdo, qui beátum Francíscum Confessórem Sanctórum tuórum glória sublimásti: tríbue, quǽsumus; ut, ejus méritis et imitatióne, promíssa humílibus prǽmia felíciter consequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who exaltest the meek, and hast raised up thy Blessed Confessor Francis even unto the glory of thy Saints, grant unto us, we beseech thee, for his sake, so to walk after him in lowliness of heart, that in the end we may attain, as he hath, to that great reward which Thou hast promised unto all such as be so minded."))))

(bcp-roman-collectarium-register
 'deus-in-cujus-passione-secundum
 (list :latin "Deus, in cujus passióne, secúndum Simeónis prophetíam, dulcíssimam ánimam gloriósæ Vírginis et Matris Maríæ dolóris gládius pertransívit: concéde propítius; ut, qui dolóres ejus venerándo recólimus, passiónis tuæ efféctum felícem consequámur:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, at Whose suffering the prophecy of Simeon was fulfilled, and a sword of sorrow pierced through the gentle soul of the glorious Virgin and Mother Mary, mercifully grant that we who speak worshipfully of her woes, may obtain the saving purchase of thy suffering."))))

(bcp-roman-collectarium-register
 'deus-in-te-sperantium-fortitudo
 (list :latin "Deus, in te sperántium fortitúdo, qui beátum Gregórium Confessórem tuum atque Pontíficem, pro tuénda Ecclésiæ libertáte, virtúte constántiæ roborásti: da nobis, ejus exémplo et intercessióne, ómnia adversántia fórtiter superáre."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, the might of all them which put their trust in thee, Who to keep thy Church free, didst make thy blessed Confessor and Bishop Gregory strong to wrestle and to suffer, grant unto us, following his example, and helped by his prayers, that with us as with him, if they fight against us, they shall not prevail against us."))))

(bcp-roman-collectarium-register
 'deus-misericordiarum-pater-per-merita
 (list :latin "Deus, misericordiárum pater, per mérita et intercessiónem beáti Hierónymi, quem órphanis adjutórem et patrem esse voluísti: concéde; ut spíritum adoptiónis, quo fílii tui nominámur et sumus, fidéliter custodiámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, the Father of mercies, Who wast pleased that blessed Jerome should be an helper and a father to the fatherless, grant unto us for his sake and at his prayers, the grace ever to hold fast to the spirit of adoption, whereby we cry to thee, Father, and are called and are thy sons."))))

(bcp-roman-collectarium-register
 'deus-omnium-largitor-bonorum-qui
 (list :latin "Deus, ómnium largítor bonórum, qui in fámula tua Bibiána cum virginitátis flore martýrii palmam conjunxísti: mentes nostras ejus intercessióne tibi caritáte conjúnge; ut, amótis perículis, prǽmia consequámur ætérna."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, the Giver of all good gifts, Who unto the lily of pure maidenhood in the hand of thy servant Bibiana, didst join the palm of a glorious martyrdom, grant us, we beseech thee, at her pleading, that our hearts and minds being joined to thee by thy love, we may escape all dangers which do presently beset us, and finally attain unto thine everlasting joy."))))

(bcp-roman-collectarium-register
 'deus-pro-cujus-ecclesia-gloriosus
 (list :latin "Deus, pro cujus Ecclésia gloriósus Póntifex Thomas gládiis impiórum occúbuit: præsta, quǽsumus; ut omnes, qui ejus implórant auxílium, petitiónis suæ salutárem consequántur efféctum."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, in defence of Whose Church the glorious Bishop Thomas fell by the swords of wicked men, grant, we beseech thee, that all that ask his help, may obtain wholesome fruit of their petition."))))

(bcp-roman-collectarium-register
 'deus-pro-cujus-honore-gloriosus
 (list :latin "Deus, pro cujus honóre gloriósus Póntifex Stanisláus gládiis impiórum occúbuit: præsta, quǽsumus; ut omnes, qui ejus implórant auxílium, petitiónis suæ salutárem consequántur efféctum."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, for Whose glory the noble Bishop Stanislaw fell by the swords of sinful men, grant, we beseech thee, that all whosoever ask his help, may find such answer to their petition as may profit them to the everlasting salvation of their souls."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-animarum-salutem
 (list :latin "Deus, qui ad animárum salútem beátum Francíscum Confessórem tuum atque Pontíficem ómnibus ómnia factum esse voluísti: concéde propítius; ut caritátis tuæ dulcédine perfúsi, ejus dirigéntibus mónitis ac suffragántibus méritis, ætérna gáudia consequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst will that thy Blessed Confessor and Bishop Francis should become all things to all men, mercifully grant unto us, that we being filled with the sweetness of thy heavenly love, may so take to ourselves his admonitions and be succoured by his prayers, that in the end we may with him attain unto thine everlasting joy."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-christianam-pauperum
 (list :latin "Deus, qui, ad christiánam páuperum eruditiónem et ad juvéntam in via veritátis firmándam, sanctum Joánnem Baptístam Confessórem excitásti, et novam per eum in Ecclésia famíliam collegísti: concéde propítius; ut ejus intercessióne et exémplo, stúdio glóriæ tuæ in animárum salúte fervéntes, ejus in cælis corónæ partícipes fíeri valeámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst raise up the Confessor, St. John Baptist, to promote the Christian education of the poor and to strengthen the young in the way of truth, and, through him, didst gather together a new family within thy Church, mercifully grant through his intercession and example, that we may burn with zeal for thy glory, through the salvation of souls, and may share his crown in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-conterendos-ecclesiae
 (list :latin "Deus, qui, ad conteréndos Ecclésiæ tuæ hostes et ad divínum cultum reparándum, beátum Pium Pontíficem Máximum elígere dignátus es: fac nos ipsíus deféndi præsídiis et ita tuis inhærére obséquiis; ut, ómnium hóstium superátis insídiis, perpétua pace lætémur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who when Thou wast pleased to break the teeth of them that hate thy Church, and to restore again the solemn worship of thyself, didst choose the blessed Pope Pius to work for thee in that matter, grant that he may still be a tower of strength for us. Grant that we also may be more than conquerors over all that make war upon our souls, and in the end may enter into perfect peace in thy presence."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-errorum-insidias
 (list :latin "Deus, qui ad errórum insídias repelléndas et apostólicæ Sedis jura propugnánda, beátum Robértum Pontíficem tuum atque Doctórem mira eruditióne et virtúte decorásti: ejus méritis et intercessióne concéde; ut nos in veritátis amóre crescámus et errántium corda ad Ecclésiæ tuæ rédeant unitátem."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst endow blessed Robert, thy bishop and doctor, with wondrous learning and strength to foil the wiles of error and to defend the rights of the Holy See; grant through his merits and intercession that we may grow in the love of truth, and that the hearts of those gone astray may return to the unity of the Church."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-evangelizandum-pauperibus
 (list :latin "Deus, qui, ad evangelizándum paupéribus et ecclesiástici órdinis decórem promovéndum, beátum Vincéntium apostólica virtúte roborásti: præsta, quǽsumus; ut, cujus pia mérita venerámur, virtútum quoque instruámur exémplis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst make blessed Vincent strong with the strength of an Apostle, to preach the Gospel to the poor, and to adorn the clergy of thy Church, grant, we beseech thee, that we who worshipfully recall his godly and worthy conversation, may also order our own goings upon the mighty example of his good life."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-majorem-tui
 (list :latin "Deus, qui ad majórem tui nóminis glóriam propagándam, novo per beátum Ignátium subsídio militántem Ecclésiam roborásti: concéde; ut, ejus auxílio et imitatióne certántes in terris, coronári cum ipso mereámur in cælis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who, to spread abroad the greater glory of Thy name through St. Ignatius, strengthened the Church militant with new power; grant that we, who are struggling on earth, may, by his help and after his example, be found worthy to be crowned with him in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-praedicandam-gentibus
 (list :latin "Deus, qui ad prædicándam géntibus glóriam tuam beátum Patrícium Confessórem atque Pontíficem míttere dignátus es: ejus méritis et intercessióne concéde; ut, quæ nobis agénda prǽcipis, te miseránte adimplére possímus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst send forth thy Blessed Confessor and Bishop Patrick to preach thy glory among the Gentiles, mercifully grant unto us, for his sake and at his petition, whatsoever Thou commandest us to do, to have grace and power faithfully to fulfill the same."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-tuendam-catholicam
 (list :latin "Deus, qui ad tuéndam cathólicam fidem beátum Petrum Confessórem tuum virtúte et doctrína roborásti: concéde propítius; ut ejus exémplis et mónitis errántes ad salútem resipíscant, et fidéles in veritátis confessióne persevérent."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst give strength and learning to blessed Peter thy Confessor for the defense of the Catholic faith, mercifully grant, that by his example and teaching, the erring may be saved and the faithful remain constant in the confession of truth."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-tuendam-catholicam-0903
 (list :latin "Deus, qui ad tuéndam cathólicam fidem, et univérsa in Christo instauránda sanctum Pium, Summum Pontíficem, cælésti sapiéntia et apostólica fortitúdine replevísti: concéde propítius; ut, ejus institúta et exémpla sectántes, prǽmia consequámur ætérna."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, who to safeguard Catholic faith and to restore all things in Christ, didst fill the Supreme Pontiff, Saint Pius, with heavenly wisdom and apostolic fortitude: grant in thy mercy: that by striving to fulfill his ordinances and to follow his example, we may reap eternal rewards."))))

(bcp-roman-collectarium-register
 'deus-qui-ad-unigenitum-filium
 (list :latin "Deus, qui ad unigénitum Fílium tuum exaltátum a terra ómnia tráhere disposuísti: pérfice propítius; ut, méritis et exémplo seráphici Confessóris tui Joséphi, supra terrénas omnes cupiditátes eleváti, ad eum perveníre mereámur:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Who art pleased that thine Only-begotten Son being lifted up from the earth should draw all things unto Him, be entreated for the sake of thy servant Joseph, whom Thou didst make like unto one of the Seraphim, and so effectually work in us, that even as he, we also may be drawn up above all earthly lusts, and worthily attain unto Him:"))))

(bcp-roman-collectarium-register
 'deus-qui-anglorum-gentes-praedicatione
 (list :latin "Deus, qui Anglórum gentes, prædicatióne et miráculis beáti Augustíni Confessóris tui atque Pontíficis, veræ fídei luce illustráre dignátus es: concéde; ut, ipso interveniénte, errántium corda ad veritátis tuæ rédeant unitátem, et nos in tua simus voluntáte concórdes."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who graciously enlightened the English peoples with the light of the true faith by the preaching and miracles of blessed Augustine, thy Confessor and Bishop, grant, through his intercession, that the hearts of those who have strayed may return to the unity of the true faith and that we may be in harmony with thy will."))))

(bcp-roman-collectarium-register
 'deus-qui-animae-famuli-tui
 (list :latin "Deus, qui ánimæ fámuli tui Gregórii ætérnæ beatitúdinis prǽmia contulísti: concéde propítius; ut, qui peccatórum nostrórum póndere prémimur, ejus apud te précibus sublevémur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who hast blessed the soul of thy servant Gregory with an everlasting blessing, mercifully grant that we, who groan under the burden of our sins, may by his prayers be relieved."))))

(bcp-roman-collectarium-register
 'deus-qui-animam-beatae-virginis
 (list :latin "Deus, qui ánimam beátæ Vírginis tuæ Scholásticæ ad ostendéndam innocéntiæ viam in colúmbæ spécie cælum penetráre fecísti: da nobis ejus méritis et précibus ita innocénter vívere; ut ad ætérna mereámur gáudia perveníre."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who, to show the way of the undefiled, wast pleased that the soul of thy blessed Virgin Scholastica should fly to heaven in a bodily shape, like a dove, mercifully grant unto us thy servants, for her sake, and at her petition, worthily to attain unto thine everlasting joy."))))

(bcp-roman-collectarium-register
 'deus-qui-beatae-annae-gratiam
 (list :latin "Deus, qui beátæ Annæ grátiam conférre dignátus es, ut Genetrícis unigéniti Fílii tui mater éffici mererétur: concéde propítius; ut, cujus solémnia celebrámus, ejus apud te patrocíniis adjuvémur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who in thy kindness gave blessed Anne the grace to be the mother of her who mothered thy only-begotten Son, graciously grant that we who keep her feast may be helped by her intercession with thee."))))

(bcp-roman-collectarium-register
 'deus-qui-beatam-franciscam-famulam
 (list :latin "Deus, qui beátam Francíscam fámulam tuam, inter cétera grátiæ tuæ dona, familiári Angeli consuetúdine decorásti: concéde, quǽsumus; ut, intercessiónis ejus auxílio, Angelórum consórtium cónsequi mereámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who along with other gifts of thy grace honored blessed Frances, thy handmaid, with the close companionship of an angel, grant, we beseech thee, that by the help of her intercession we may be made worthy to attain the companionship of angels."))))

(bcp-roman-collectarium-register
 'deus-qui-beatam-hedwigem-a
 (list :latin "Deus, qui beátam Hedwígem a sǽculi pompa ad húmilem tuæ crucis sequélam toto corde transíre docuísti: concéde; ut ejus méritis et exémplo discámus peritúras mundi calcáre delícias, et in ampléxu tuæ crucis ómnia nobis adversántia superáre:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Who didst teach thy blessed hand-maid Hedwig to turn away from the glory of the world, and with all her heart to take up her Cross and follow thee, teach us, for her sake and after her example, to hold light the perishing pleasures of this present world, and cleaving ever unto thy Cross to rest in the end more than conquerors over all things that would hurt us."))))

(bcp-roman-collectarium-register
 'deus-qui-beatam-julianam-virginem
 (list :latin "Deus, qui beátam Juliánam Vírginem tuam extrémo morbo laborántem, pretióso Fílii tui Córpore mirabíliter recreáre dignátus es: concéde, quǽsumus; ut, ejus intercedéntibus méritis, nos quoque eódem in mortis agóne refécti ac roboráti, ad cæléstem pátriam perducámur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who, when thy blessed hand-maiden Juliana was lying sick unto death wast pleased in wondrous wise to comfort her with the Precious Body of thy Son, be Thou entreated for the same thy servant's sake, and grant unto us also the same Comfort in our last agony, that we may go in the strength of that Meat unto our very Fatherland, which is in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-beatam-margaritam-reginam
 (list :latin "Deus, qui beátam Margarítam regínam exímia in páuperes caritáte mirábilem effecísti: da; ut, ejus intercessióne et exémplo, tua in córdibus nostris cáritas júgiter augeátur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst make Margaret, that blessed Queen, wonderful for tender love toward the poor, grant that her intercession and example may be effectual to gain for our hearts a thorough love toward thee."))))

(bcp-roman-collectarium-register
 'deus-qui-beatam-mariam-semper
 (list :latin "Deus, qui beátam Maríam semper Vírginem, Spíritus Sancti habitáculum, hodiérna die in templo præsentári voluísti: præsta, quǽsumus; ut, ejus intercessióne, in templo glóriæ tuæ præsentári mereámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who wast pleased that the blessed Mary always a Virgin, being herself the dwelling-place of the Holy Ghost, should, as on this day, be presented in thine earthly Temple, grant, we beseech thee, that by her prayers we may worthily be presented in the heavenly Temple of thy glory."))))

(bcp-roman-collectarium-register
 'deus-qui-beatissimae-semper-virginis
 (list :latin "Deus, qui beatíssimæ semper Vírginis et Genetrícis tuæ Maríæ singulári título Carméli órdinem decorásti: concéde propítius; ut, cujus hódie Commemoratiónem solémni celebrámus offício, ejus muníti præsídiis, ad gáudia sempitérna perveníre mereámur:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O Lord, Who hast given this excellency unto the Order of Carmel that the same should be especially styled the Order of the Most Blessed Mary, always a Virgin, thine Own Mother, mercifully grant that we who on this day do renew her memory in solemn worship, may worthily be shielded by her protection, and finally attain unto thine everlasting joy."))))

(bcp-roman-collectarium-register
 'deus-qui-beato-cajetano-confessori
 (list :latin "Deus, qui beáto Cajetáno Confessóri tuo apostólicam vivéndi formam imitári tribuísti: da nobis, ejus intercessióne et exémplo, in te semper confídere et sola cæléstia desideráre."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst give grace unto thy blessed confessor Cajetan to order his life on the pattern of thine Apostles, grant unto us through his prayers, and after his example ever to put all our trust in thee, and to seek only heavenly things."))))

(bcp-roman-collectarium-register
 'deus-qui-beato-irenaeo-martyri
 (list :latin "Deus, qui beáto Irenǽo Mártyri tuo atque Pontífici tribuísti, ut et veritáte doctrínæ expugnáret hǽreses, et pacem Ecclésiæ felíciter confirmáret: da, quǽsumus, plebi tuæ in sancta religióne constántiam; et pacem tuam nostris concéde tempóribus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who enabled blessed Irenaeus thy Martyr, and Bishop, to overcome heresy by the truth of his teaching, and happily to establish peace in the Church, give to thy people, we pray, steadfastness in holy religion, and grant us thy peace in our days."))))

(bcp-roman-collectarium-register
 'deus-qui-beato-petro-apostolo
 (list :latin "Deus, qui beáto Petro Apóstolo tuo, collátis clávibus regni cæléstis, ligándi atque solvéndi pontifícium tradidísti: concéde; ut, intercessiónis ejus auxílio, a peccatórum nostrórum néxibus liberémur:

_
@Sancti/02-22:Commemoratio4"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Who hast given unto thy Blessed Apostle Peter the keys of the kingdom of heaven, and the power to bind and to loose, loose us, we beseech thee, at his mighty intercession, from all the bands of our sins.

_
@Sancti/02-22:Commemoratio4"))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-albertum-pontificem
 (list :latin "Deus, qui beátum Albértum Pontíficem tuum atque Doctórem in humána sapiéntia divínæ fídei subiciénda magnum effecísti: da nobis, quǽsumus; ita ejus magistérii inhærére vestígiis, ut luce perfécta fruámur in cælis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who made blessed Albert, thy Bishop and Doctor, eminent in the submission of human wisdom to divine faith, grant us, we beseech thee, so to follow the path of his teaching, that we may enjoy perfect light in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-cyrillum-confessorem
 (list :latin "Deus, qui beátum Cyríllum Confessórem tuum atque Pontíficem divínæ maternitátis beatíssimæ Vírginis Maríæ assertórem invíctum effecísti: concéde, ipso intercedénte; ut, qui vere eam Genetrícem Dei crédimus, matérna eíusdem protectióne salvémur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who didst make thy blessed Confessor and Bishop Cyril to be an unconquered teacher that the Most Blessed Virgin Mary is Mother of God, grant unto us that through his prayers we who believe her to be Mother of God in very deed may find safety under her motherly protection."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-felicem-confessorem
 (list :latin "Deus, qui beátum Felícem Confessórem tuum ex erémo ad munus rediméndi captívos cǽlitus vocáre dignátus es: præsta, quǽsumus; ut per grátiam tuam ex peccatórum nostrórum captivitáte, ejus intercessióne, liberáti, ad cæléstem pátriam perducámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who by a sign from heaven didst call thy blessed Confessor Felix out of the desert to become a redeemer of bondsmen, grant, we beseech thee, unto his prayers, that thy grace may deliver us from the bondage of sin, and bring us home unto our very fatherland, which is in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-fidelem-seraphico
 (list :latin "Deus, qui beátum Fidélem, seráphico spíritus ardóre succénsum, in veræ fídei propagatióne martýrii palma et gloriósis miráculis decoráre dignátus es: ejus, quǽsumus, méritis et intercessióne, ita nos per grátiam tuam in fide et caritáte confírma; ut in servítio tuo fidéles usque ad mortem inveníri mereámur."
       :conclusion 'per-dominum
       :translations
       '((do . "God, Who didst vouchsafe to enkindle in blessed Fidelis the fire of thy Seraphim, and to glorify his toil to give men a true knowledge of thee by the palm-branch of martyrdom and by great signs and wonders, be entreated, we beseech thee, for his sake and by his prayers, and so establish us in the knowledge and love of thee, that we also, like him, may be found faithful even unto death in serving of thee."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-franciscum-novi
 (list :latin "Deus, qui beátum Francíscum, novi órdinis institutórem, orándi stúdio et pœniténtiæ amóre decorásti: da fámulis tuis in ejus imitatióne ita profícere; ut, semper orántes et corpus in servitútem redigéntes, ad cæléstem glóriam perveníre mereántur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst raise up thy blessed servant Francis to found a new Order in thy Church, and didst ennoble him through earnestness in prayer and love of penance, grant unto us after his example so to pray without ceasing and to bring our bodies into subjection, that, in the end, we, like him, may worthily attain unto thy heavenly glory."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-gabrielem-dulcissimae
 (list :latin "Deus, qui beátum Gabriélem dulcíssimæ Matris tuæ dolóres assídue recólere docuísti, ac per illam sanctitátis et miraculórum glória sublimásti: da nobis, ejus intercessióne et exémplo; ita Genetrícis tuæ consociári flétibus, ut matérna ejúsdem protectióne salvémur:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, who didst teach blessed Gabriel to ponder well the sorrows of thy gentle Mother, whereby thou didst also exalt him to the glory of holiness and mighty works: grant us, after his example, in such wise to become one with thy Mother in her sorrows; that under her kindly protection we may attain everlasting salvation."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-hermenegildum-martyrem
 (list :latin "Deus, qui beátum Hermenegíldum Mártyrem tuum cælésti regno terrénum postpónere docuísti: da quǽsumus nobis; ejus exémplo cadúca despícere, atque ætérna sectári."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst teach thy blessed Martyr Hermenegild to choose an heavenly rather than an earthly crown, grant, we beseech thee, that we, like him, may so pass through things temporal that we finally miss not those which are eternal."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-joannem-confessorem
 (list :latin "Deus, qui beátum Joánnem, Confessórem tuum, ad cultum sacrórum Córdium Jesu et Maríæ rite promovéndum, mirabíliter inflammásti, et per eum novas in Ecclésia tua famílias congregáre voluísti: præsta, quǽsumus; ut, cujus pia mérita venerámur, virtútum quoque instruámur exémplis."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, who did wondrously inspire blessed John, thy Confessor in promoting veneration to the sacred hearts of Jesus and Mary, and didst will to found through him new religious families in the Church, grant we pray, that we, who venerate his holy merits, may be taught also by the example of his virtues."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-joannem-confessorem-1009
 (list :latin "Deus, qui beátum Joánnem Confessórem tuum ad fidem in géntibus propagándam mirabíliter excitáre dignátus es, ac per eum in erudiéndis fidélibus novam in Ecclésia tua famíliam congregásti: da nobis fámulis tuis; ita ejus institútis profícere, ut prǽmia consequámur ætérna."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst deign wonderfully to rise up blessed John thy confessor, for the propagation of the faith among the Gentiles, and through him didst organize in Thy Church a new family for the instruction of the faithful, grant to us, Thy servants, so to profit by his works that we may attain unto eternal rewards"))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-joannem-tuo
 (list :latin "Deus, qui beátum Joánnem, tuo amóre succénsum, inter flammas innóxium incédere fecísti, et per eum Ecclésiam tuam nova prole fecundásti: præsta, ipsíus suffragántibus méritis; ut igne caritátis tuæ vítia nostra curéntur, et remédia nobis ætérna provéniant."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst so enkindle in thy servant John the fire of thy Divine love, that when he walked in the midst of earthly fire the flame thereof had on his body no power, and Who didst choose him for a means whereby Thou hast given unto thy Church a new family of sons, mercifully grant unto us, for his sake, that the fire of thy love may burn up in us all things that displease thee, and make us meet for thy heavenly kingdom."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-ludovicum-confessorem
 (list :latin "Deus, qui beátum Ludovícum Confessórem tuum de terréno regno ad cæléstis regni glóriam transtulísti: ejus, quǽsumus, méritis et intercessióne; Regis regum Jesu Christi, Fílii tui, fácias nos esse consórtes:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Who didst give unto thy blessed Confessor Louis a glorious change from an earthly kingdom unto an heavenly, grant unto us, we beseech thee, for his sake and by his prayers, one day to enter like him into the Presence of the King of kings, even thy Son Jesus Christ."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-marcum-evangelistam
 (list :latin "Deus, qui beátum Marcum Evangelístam tuum evangélicæ prædicatiónis grátia sublimásti: tríbue, quǽsumus; ejus nos semper et eruditióne profícere et oratióne deféndi."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst exalt thy blessed Evangelist Mark, by giving him grace to preach thine Evangel, grant unto us, we beseech thee, ever to follow more and more what he teacheth, and ever to be shielded from all evil by his prayers."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-matthiam-apostolorum
 (list :latin "Deus, qui beátum Matthíam Apostolórum tuórum collégio sociásti: tríbue, quǽsumus; ut, ejus interventióne, tuæ circa nos pietátis semper víscera sentiámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who added blessed Matthias to the company of Thy Apostles; grant, we beseech Thee, that by his intercession we may ever be aware of the depth of Thy love for us."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-nicolaum-pontificem
 (list :latin "Deus, qui beátum Nicoláum Pontíficem innúmeris decorásti miráculis: tríbue, quǽsumus; ut ejus méritis et précibus a gehénnæ incéndiis liberémur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst glorify the blessed Bishop Nicholas with innumerable miracles; grant, we beseech thee, that, by his merits and prayers, we may be saved from the fires of hell."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-norbertum-confessorem
 (list :latin "Deus, qui beátum Norbértum Confessórem tuum atque Pontíficem verbi tui præcónem exímium effecísti, et per eum Ecclésiam tuam nova prole fecundásti: præsta, quǽsumus; ut, ejúsdem suffragántibus méritis, quod ore simul et ópere dócuit, te adjuvánte, exercére valeámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who made blessed Norbert, thy Confessor and Bishop, a brilliant preacher of thy word, and through him enriched thy Church with a new religious family, grant, we beseech thee, that by his prayerful intercession and thy help, we may be able to do what he has taught us by his words and deeds."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-paschalem-confessorem
 (list :latin "Deus, qui beátum Paschálem Confessórem tuum mirífica erga Córporis et Sánguinis tui sacra mystéria dilectióne decorásti: concéde propítius; ut, quam ille ex hoc divíno convívio spíritus percépit pinguédinem, eándem et nos percípere mereámur:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Who endowed blessed Paschal, thy Confessor, with a wondrous love for the sacred mysteries of thy Body and Blood, mercifully grant that we may be found worthy to share in the same spiritual abundance he received in this divine banquet."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-petrum-apostolum
 (list :latin "Deus, qui beátum Petrum Apóstolum, a vínculis absolútum, illǽsum abíre fecísti: nostrórum, quæsumus, absólve víncula peccatórum; et ómnia mala a nobis propitiátus exclúde.

_
@Sancti/02-22:Commemoratio4:s/\\$Per Dominum//"
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst loose the blessed Apostle, Peter, from his chains and didst make him go forth unharmed, loose, we pray, the chains of our sins, and in thy mercy ward off from us every evil.

_
@Sancti/02-22:Commemoratio4:s/\\$Per Dominum//"))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-petrum-caelestinum
 (list :latin "Deus, qui beátum Petrum Cælestínum ad summi pontificátus ápicem sublimásti, quique illum humilitáti postpónere docuísti: concéde propítius; ut ejus exémplo cuncta mundi despícere, et ad promíssa humílibus prǽmia perveníre felíciter mereámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who raised blessed Peter Celestine to the lofty dignity of Supreme Pontiff and taught him to prefer self-abasement instead; mercifully grant that by his example we may look upon all worldly things as naught, and may be worthy to reap in joy the rewards promised to the humble."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-petrum-chrysologum
 (list :latin "Deus, qui beátum Petrum Chrysólogum Doctórem egrégium, divínitus præmonstrátum, ad regéndam et instruéndam Ecclésiam tuam éligi voluísti: præsta, quǽsumus; ut, quem Doctórem vitæ habúimus in terris, intercessórem habére mereámur in cælis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst miraculously point out the glorious doctor Peter Chrysologus, and choose him to be a ruler and teacher of thy Church; grant, we beseech thee, that as on earth he taught us the way of life, so in heaven he may be our continual intercessor with thee."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-petrum-confessorem
 (list :latin "Deus, qui beátum Petrum Confessórem tuum admirábilis pœniténtiæ et altíssimæ contemplatiónis múnere illustráre dignátus es: da nobis, quǽsumus; ut, ejus suffragántibus méritis, carne mortificáti, facílius cæléstia capiámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who hast been pleased to set before us in thy blessed Confessor Peter a wondrous example of penance and of a mind unfathomably rapt in thee, let, we beseech thee, the same thy servant pray for us, and him do Thou accept, that we may so die unto earthly things, as to take lively hold on heavenly things."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-philippum-confessorem
 (list :latin "Deus, qui beátum Philíppum Confessórem tuum Sanctórum tuórum glória sublimásti: concéde propítius; ut, cujus solemnitáte lætámur, ejus virtútum proficiámus exémplo."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who hast exalted thy blessed Confessor Philip to the glory of thy saints be appeased and grant that as we rejoice in his feast we may profit by the example of his virtues."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-raphaelem-archangelum
 (list :latin "Deus, qui beátum Raphaélem Archángelum Tobíæ fámulo tuo cómitem dedísti in via: concéde nobis fámulis tuis; ut ejúsdem semper protegámur custódia et muniámur auxílio."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst give thy blessed Archangel Raphael unto thy servant Tobias to be his fellow wayfarer, grant unto us, thy servants, that the same may ever keep and shield us, help and defend us."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-raymundum-poenitentiae
 (list :latin "Deus, qui beátum Raymúndum pœniténtiæ sacraménti insígnem minístrum elegísti, et per maris undas mirabíliter traduxísti: concéde; ut ejus intercessióne dignos pœniténtiæ fructus fácere, et ad ætérnæ salútis portum perveníre valeámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst choose the blessed Raymond to be an eminent minister of the Sacrament of Penance, and in a wonderful manner didst make him to pass over the waves of the sea, grant unto us, at his petition, the grace to bring forth fruits worthy of repentance, and in the end to attain unto the harbour of eternal salvation."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-regem-eduardum
 (list :latin "Deus, qui beátum regem Eduárdum Confessórem tuum æternitátis glória coronásti: fac nos, quǽsumus; ita eum venerári in terris, ut cum eo regnáre possímus in cælis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who hast set upon the head of thy blessed Confessor King Edward a crown of everlasting glory, grant unto us, we beseech thee, so to use our reverence for him here upon earth, as to make the same a mean whereby to come to reign with him hereafter in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-thomam-pontificem
 (list :latin "Deus, qui beátum Thomam Pontíficem insígnis in páuperes misericórdiæ virtúte decorásti: quǽsumus; ut, ejus intercessióne, in omnes, qui te deprecántur, divítias misericórdiæ tuæ benígnus effúndas."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst adorn the blessed Bishop Thomas with the grace of an excellent pitifulness toward the needy, we entreat thee for the same thy servant's sake mercifully to pour forth the riches of thine own pitifulness upon all them which cry unto thee."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-titum-confessorem
 (list :latin "Deus, qui beátum Titum Confessórem tuum atque Pontíficem apostólicis virtútibus decorásti: ejus méritis et intercessióne concéde; ut juste et pie vivéntes in hoc sǽculo, ad cæléstem pátriam perveníre mereámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst glorify thy blessed Confessor and Bishop Titus with the graces of an Apostle, grant unto us for his sake and at his prayers, that we may so live soberly, righteously, and godly in this present world, that hereafter we may worthily attain unto the Fatherland which is in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-beatum-wenceslaum-per
 (list :latin "Deus, qui beátum Wencesláum per martýrii palmam a terréno principátu ad cæléstem glóriam transtulísti: ejus précibus nos ab omni adversitáte custódi; et ejúsdem tríbue gaudére consórtio."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst make thy blessed servant Wenceslaus to pass by the palm of martyrdom from dominion on earth to glory in heaven, keep us, at his prayers, from all hurt here, and grant unto us the joy of fellowship with him hereafter."))))

(bcp-roman-collectarium-register
 'deus-qui-conspicis-quia-ex
 (list :latin "Deus, qui cónspicis, quia ex nulla nostra virtúte subsístimus: concéde propítius; ut, intercessióne beáti Martíni Confessóris tui atque Pontíficis, contra ómnia advérsa muniámur."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech thee, O Almighty God, that the worshipful Feast of thy blessed Confessor and Bishop Martin, may avail us to the increase both of godliness toward thee, and healthfulness to our own souls."))))

(bcp-roman-collectarium-register
 'deus-qui-conspicis-quia-nos
 (list :latin "Deus, qui conspicis, quia nos undique mala nostra perturbant: præsta, quǽsumus; ut beáti Joánnis Apóstoli tui et Evangelistæ intercéssio gloriósa nos prótegat."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Which seest that sins and sufferings do on every side rise up to trouble us, grant, we beseech thee, that we may find a shield in time of need through the glorious intercession of thy blessed Apostle and Evangelist John."))))

(bcp-roman-collectarium-register
 'deus-qui-de-beatae-mariae
 (list :latin "Deus, qui de beátæ Maríæ Vírginis útero Verbum tuum, Angelo nuntiánte, carnem suscípere voluísti: præsta supplícibus tuis: ut qui vere eam Genetrícem Dei crédimus, ejus apud te intercessiónibus adjuvémur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, who didst will that, at the announcement of an Angel, thy Word should take flesh in the womb of the Blessed Virgin Mary, grant to us thy suppliants, that we who believe her to be truly the Mother of God may be helped by her intercession with thee."))))

(bcp-roman-collectarium-register
 'deus-qui-dedisti-legem-moysi
 (list :latin "Deus, qui dedísti legem Móysi in summitáte montis Sínai, et in eódem loco per sanctos Angelos tuos corpus beátæ Catharínæ Vírginis et Mártyris tuæ mirabíliter collocásti: præsta, quǽsumus; ut, ejus méritis et intercessióne, ad montem, qui Christus est, perveníre valeámus:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Who didst give the Law unto Moses upon the top of Mount Sinai, and there didst cause the body of thy blessed Virgin and Martyr Catharine to be marvelously laid by thine holy Angels, grant unto us, we beseech thee, for her sake and at her prayers, that we may finally attain unto that mountain which is Christ."))))

(bcp-roman-collectarium-register
 'deus-qui-ecclesiae-tuae-in
 (list :latin "Deus, qui Ecclésiæ tuæ in exponéndis sacris Scriptúris beátum Hierónymum, Confessórem tuum, Doctórem máximum providére dignátus es: præsta, quǽsumus; ut, ejus suffragántibus méritis, quod ore simul et ópere dócuit, te adjuvánte, exercére valeámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who wast pleased to give unto thy Church thy blessed Confessor Jerome to be unto her a great teacher in the way of expounding thine Holy Scriptures, be entreated, we beseech thee, for that thy servant's sake, and grant unto us the strength to put in practice what he taught both by his doctrine and by his life."))))

(bcp-roman-collectarium-register
 'deus-qui-ecclesiam-tuam-beati
 (list :latin "Deus, qui Ecclésiam tuam beáti Thomæ Confessóris tui mira eruditióne claríficas, et sancta operatióne fœcúndas: da nobis, quǽsumus; et quæ dócuit, intelléctu conspícere, et quæ egit, imitatióne complére."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who dost enlighten thy Church by the wonderful learning of thy blessed Confessor Thomas, and quickenest her through his godly labours, grant unto thy people, we humbly beseech thee, ever to apprehend by their understanding what he teacheth, and in their life faithfully to practice the same."))))

(bcp-roman-collectarium-register
 'deus-qui-ecclesiam-tuam-beati-0405
 (list :latin "Deus, qui Ecclésiam tuam beáti Vincéntii Confessóris tui méritis et prædicatióne illustráre dignátus es: concéde nobis fámulis tuis; ut et ipsíus instruámur exémplis et ab ómnibus ejus patrocínio liberémur advérsis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who wast pleased to enlighten thy Church through the worthy deeds and Gospel preaching of thy blessed Confessor Vincent, grant unto us thy servants grace so to order our lives after his example, that we, being helped by his protection, may by thee be ever delivered from all evil."))))

(bcp-roman-collectarium-register
 'deus-qui-ecclesiam-tuam-beati-0527
 (list :latin "Deus, qui Ecclésiam tuam beáti Bedæ Confessóris tui atque Doctóris eruditióne claríficas: concéde propítius fámulis tuis; ejus semper illustrári sapiéntia et méritis adjuvári."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who dost enlighten Thy Church by the learning of blessed Bede Thy Confessor and our teacher, mercifully grant unto Thy servants ever to be enlightened by his wisdom and helped for his sake."))))

(bcp-roman-collectarium-register
 'deus-qui-ecclesiam-tuam-beati-0618
 (list :latin "Deus, qui Ecclésiam tuam beáti Ephræm Confessóris tui et Doctóris mira eruditióne et præcláris vitæ méritis illustráre voluísti: te súpplices exorámus; ut, ipso intercedénte, eam advérsus erróris et pravitátis insídias perénni tua virtúte deféndas."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst will to illumine thy Church by the wondrous learning and glorious merits of blessed Ephrem, thy Confessor and Doctor, do thou, we humbly entreat thee, by his intercession and thy continual power, defend her against the wiles of heresy and wickedness."))))

(bcp-roman-collectarium-register
 'deus-qui-ecclesiam-tuam-beati-0804
 (list :latin "Deus, qui Ecclésiam tuam beáti Domínici Confessóris tui illumináre dignátus es méritis et doctrínis: concéde; ut ejus intercessióne temporálibus non destituátur auxíliis, et spirituálibus semper profíciat increméntis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who hast been pleased to shed throughout thy Church the light of the worthy deeds and healthful teaching of thy blessed Confessor Dominic, grant unto the same, with the help of his prayers, that she may never be either helpless in things temporal, or barren in things spiritual."))))

(bcp-roman-collectarium-register
 'deus-qui-ecclesiam-tuam-beati-1004
 (list :latin "Deus, qui Ecclésiam tuam beáti Francísci méritis fœtu novæ prolis amplíficas: tríbue nobis; ex ejus imitatióne, terréna despícere, et cæléstium donórum semper participatióne gaudére."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst use the worthy deeds of thy blessed servant Francis as a mean whereby to make thy Church again the mother of children, grant that we like him may set little price by earthly things, and attain unto a portion of those good things which Thou givest in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-fidei-sacramenta-in
 (list :latin "Deus, qui fídei sacraménta in Unigéniti tui gloriósa Transfiguratióne patrum testimónio roborásti, et adoptiónem filiórum perféctam, voce delápsa in nube lúcida, mirabíliter præsignásti: concéde propítius; ut ipsíus Regis glóriæ nos coherédes effícias, et ejúsdem glóriæ tríbuas esse consórtes."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who, in the glorious Transfiguration of thine Only Begotten Son didst attest the mysteries of the Faith by the witness of the Fathers, and didst wonderfully signify by a voice out of a bright cloud, the adoption of sons, mercifully grant unto us to be made co-heirs with the very King of glory, and bestow upon us a partaking of His glory."))))

(bcp-roman-collectarium-register
 'deus-qui-hodierna-die-beatum
 (list :latin "Deus, qui hodiérna die beátum Henrícum Confessórem tuum e terréni cúlmine impérii ad regnum ætérnum transtulísti: te súpplices exorámus; ut, sicut illum, grátiæ tuæ ubertáte prævéntum, illécebras sǽculi superáre fecísti, ita nos fácias, ejus imitatióne, mundi hujus blandiménta vitáre, et ad te puris méntibus perveníre."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who on this day took St. Henry, thy Confessor, to the everlasting kingdom from the throne of an earthly empire; we humbly beseech thee, that as thou enabled him, protected by the abundance of thy grace, to overcome the temptations of the world, so grant that we, in emulation of him, may shun the allurements of this world and come to thee with pure hearts."))))

(bcp-roman-collectarium-register
 'deus-qui-hodiernam-diem-apostolorum
 (list :latin "Deus, qui hodiérnam diem Apostolórum tuórum Petri et Pauli martýrio consecrásti: da Ecclésiæ tuæ, eórum in ómnibus sequi præcéptum; per quos religiónis sumpsit exórdium."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst hallow this day by the Testifying of thine Holy Apostles Peter and Paul, grant unto thy Church, whose foundations Thou wast pleased to lay by their hands, the grace always in all things to remain faithful to their teaching."))))

(bcp-roman-collectarium-register
 'deus-qui-hunc-diem-beati
 (list :latin "Deus, qui hunc diem beáti Venántii Mártyris tui triúmpho consecrásti: exáudi preces pópuli tui et præsta: ut, qui ejus mérita venerámur, fídei constántiam imitémur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, in Whose sight this day is holy, because thy blessed Martyr Venantius did become more than conqueror thereon, graciously hear the prayers of thy people, and grant that all who reverence his right worthy loyalty to thee, may be like him in godly endurance."))))

(bcp-roman-collectarium-register
 'deus-qui-in-corde-beatae
 (list :latin "Deus, qui in corde beátæ Gertrúdis Vírginis jucúndam tibi mansiónem præparásti: ipsíus méritis et intercessióne; cordis nostri máculas cleménter abstérge, et ejúsdem tríbue gaudére consórtio."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst make unto thyself a pleasant dwelling-place in the heart of thy blessed hand-maiden Gertrude, be Thou entreated for the same thy servant's sake, and by her prayers, to purge away in thy mercy all defilement from our hearts, and to grant us one day to rejoice with her in thy presence."))))

(bcp-roman-collectarium-register
 'deus-qui-in-corde-beati
 (list :latin "Deus, qui in corde beáti Andréæ Confessóris tui, per árduum cotídie in virtútibus proficiéndi votum, admirábiles ad te ascensiónes disposuísti: concéde nobis, ipsíus méritis et intercessióne, ita ejúsdem grátiæ partícipes fíeri; ut, perfectióra semper exsequéntes, ad glóriæ tuæ fastígium felíciter perducámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst make thy blessed Confessor Andrew to settle in his heart to go up wondrously toward thee by a stern vow daily to advance to the utmost of his power in godliness, grant unto us for the same thy servant's sake and at his prayers the like grace, so that we, seeking ever that which is more perfect, may happily attain the crown of thine everlasting glory."))))

(bcp-roman-collectarium-register
 'deus-qui-in-ecclesia-tua
 (list :latin "Deus, qui in Ecclésia tua, nova semper instáuras exémpla virtútum: da pópulo tuo beáti Andréæ Confessóris tui atque Pontíficis ita sequi vestígia; ut assequátur et prǽmia."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who dost continually raise up in thy Church new examples of godly living, grant unto thy people so to follow in the steps of thy blessed Bishop and Confessor Andrew, that at the last they may, together with him, attain unto thine eternal reward."))))

(bcp-roman-collectarium-register
 'deus-qui-in-liberandis-fidelibus
 (list :latin "Deus, qui in liberándis fidélibus tuis ab impiórum captivitáte beátum Raymúndum Confessórem tuum mirábilem effecísti: ejus nobis intercessióne concéde; ut, a peccatórum vínculis absolúti, quæ tibi sunt plácita, líberis méntibus exsequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst make thy blessed Confessor Raymond to do a wonderful work in delivering thy faithful ones from bondage to the unbelievers, grant unto us at his prayers to be delivered from the chains of sin, and with all willingness of mind to do those things that are pleasing in thy sight."))))

(bcp-roman-collectarium-register
 'deus-qui-in-praeclara-salutiferae
 (list :latin "Deus, qui in præclára salutíferæ Crucis Inventióne, passiónis tuæ mirácula suscitásti: concéde; ut vitális ligni prétio, ætérnæ vitæ suffrágia consequámur:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Who didst cause that the Cross of our salvation should in most honourable wise be found again, and Who didst manifest thereby the marvellous efficacy of thy sufferings, mercifully grant that by the Ransom which Thou didst pay upon that tree of life we may finally attain unto life eternal."))))

(bcp-roman-collectarium-register
 'deus-qui-in-tuae-caritatis
 (list :latin "Deus, qui in tuæ caritátis exémplum ad fidélium redemptiónem sanctum Petrum Ecclésiam tuam nova prole fecundáre divínitus docuísti: ipsíus nobis intercessióne concéde; a peccáti servitúte solútis, in cælésti pátria perpétua libertáte gaudére:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Thou Who, as an example of Thy charity, divinely taught St. Peter to enrich Thy Church with new offspring, a family of religious devoted to the ransom of the faithful, grant by his intercession, that we may be released from the slavery of sin, and rejoice in lasting freedom in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-indiarum-gentes-beati
 (list :latin "Deus, qui Indiárum gentes beáti Francísci prædicatióne et miráculis Ecclésiæ tuæ aggregáre voluísti: concéde propítius; ut cujus gloriósa mérita venerámur, virtútum quoque imitémur exémpla."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who wast pleased, by the preaching and miracles of blessed Francis, to add the nations of the Indies to thy Church; mercifully grant that, as we venerate his glorious merits, so we may also follow the example of his virtues."))))

(bcp-roman-collectarium-register
 'deus-qui-ineffabili-providentia-sanctos
 (list :latin "Deus, qui ineffábili providéntia sanctos Angelos tuos ad nostram custódiam míttere dignáris: largíre supplícibus tuis; et eórum semper protectióne deféndi, et ætérna societáte gaudére."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who in thine unspeakable Providence hast been pleased to give thine holy Angels charge over us, to keep us, mercifully grant unto our prayers, that we be both ever fenced by their wardship here, and everlastingly blessed by their fellowship hereafter."))))

(bcp-roman-collectarium-register
 'deus-qui-infirmitati-nostrae-ad
 (list :latin "Deus, qui infirmitáti nostræ ad teréndam salútis viam in Sanctis tuis exémplum et præsídium collocásti: da nobis, ita beáti Guliélmi abbátis mérita venerári; ut ejúsdem excipiámus suffrágia, et vestígia prosequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who made Your Saints an example and a help for our weakness; grant us, as we walk the path of salvation, so to venerate the virtues of the blessed Abbot William that we may obtain his intercession and follow in his footsteps."))))

(bcp-roman-collectarium-register
 'deus-qui-inter-ceteros-angelos
 (list :latin "Deus, qui inter céteros Angelos, ad annuntiándum Incarnatiónis tuæ mystérium, Gabriélem Archángelum elegísti: concéde propítius; ut qui festum ejus celebrámus in terris, ipsíus patrocínium sentiámus in cælis:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, Who didst choose the Archangel Gabriel from among all Thine other Angels, and send him to herald the mystery of Thine Incarnation, mercifully grant that we who keep his feast upon earth may feel his protection in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-inter-regales-delicias
 (list :latin "Deus, qui inter regáles delícias et mundi illécebras sanctum Casimírum virtúte constántiæ roborásti: quǽsumus; ut ejus intercessióne fidéles tui terréna despíciant, et ad cæléstia semper aspírent."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who strengthened St. Casimir with the virtue of steadfastness amid the luxuries of a royal court and the allurements of the world, we beseech thee that, through his intercession, thy faithful may treat earthly things as naught and ever aspire to those of heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-miro-ordine-angelorum
 (list :latin "Deus, qui, miro órdine, Angelórum ministéria hominúmque dispénsas: concéde propítius; ut, a quibus tibi ministrántibus in cælo semper assístitur, ab his in terra vita nostra muniátur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who hast ordained and constituted the services of angels and men in a wonderful order, mercifully grant that as thy holy angels alway do thee service in heaven, so, by thy appointment, they may succour and defend us on earth."))))

(bcp-roman-collectarium-register
 'deus-qui-multitudinem-gentium-beati
 (list :latin "Deus, qui multitúdinem géntium beáti Pauli Apóstoli prædicatióne docuísti: da nobis, quǽsumus; ut, cujus natalícia cólimus, ejus apud te patrocínia sentiámus.

_
@Sancti/01-25:Commemoratio4"
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who, through the preaching of the Blessed Apostle Paul, hast caused the light of the Gospel to shine gloriously among the Gentiles, we beseech thee that we who keep the Feast of his birth, may, now that he is with thee, feel to our comfort that his prayer availeth much with thee.

_
@Sancti/01-25:Commemoratio4"))))

(bcp-roman-collectarium-register
 'deus-qui-multitudinem-populorum-beati
 (list :latin "Deus, qui multitúdinem populórum, beáti Bonifátii Mártyris tui atque Pontíficis zelo, ad agnitiónem tui nóminis vocáre dignátus es: concéde propítius; ut, cujus solémnia cólimus, étiam patrocínia sentiámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who, through the zeal of blessed Boniface, thy Martyr and Bishop, graciously called a multitude of people to the knowledge of thy Name, mercifully grant that we who keep his feast may also enjoy his patronage."))))

(bcp-roman-collectarium-register
 'deus-qui-nos-annua-apostolorum
 (list :latin "Deus, qui nos ánnua Apostolórum tuórum Philíppi et Jacóbi solemnitáte lætíficas: præsta, quǽsumus; ut, quorum gaudémus méritis, instruámur exémplis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who dost every year gladden us by the solemn memorial of thine Apostles Philip and James, grant us grace, we beseech thee, not only to rejoice because of their worthy deeds, but also to tread in their footsteps."))))

(bcp-roman-collectarium-register
 'deus-qui-nos-annua-beatae
 (list :latin "Deus, qui nos ánnua beátæ Cæcíliæ Vírginis et Mártyris tuæ solemnitáte lætíficas: da, ut, quam venerámur offício, étiam piæ conversatiónis sequámur exémplo."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who year by year dost gladden thy people by the solemn feast of thy blessed Virgin and Martyr Cecilia, grant unto us, we beseech thee, not only devoutly to observe the same, but also to follow after the pattern of her godly conversation."))))

(bcp-roman-collectarium-register
 'deus-qui-nos-annua-beatorum
 (list :latin "Deus, qui nos ánnua beatórum Mártyrum tuórum Marcellíni, Petri atque Erásmi solemnitáte lætíficas: præsta, quǽsumus; ut, quorum gaudémus méritis, accendámur exémplis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who dost every year gladden us by the solemn memorial of your blessed Martyrs Marcellinus, Peter, and Erasmus, grant us grace, we beseech thee, not only to rejoice because of their worthy deeds, but also to tread in their footsteps."))))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-barnabae
 (list :latin "Deus, qui nos beáti Bárnabæ Apóstoli tui méritis et intercessióne lætíficas: concéde propítius; ut, qui tua per eum benefícia póscimus, dono tuæ grátiæ consequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who dost gladden us through the worthy deeds and prayers of thy blessed apostle Barnabas, mercifully grant that all they which seek thy mercy through him may effectually obtain the gift of thy grace."))))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-georgii
 (list :latin "Deus, qui nos beáti Geórgii Mártyris tui méritis et intercessióne lætíficas: concéde propítius; ut, qui tua per eum benefícia póscimus, dono tuæ grátiæ consequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who dost gladden us through the worthy deeds and prayers of thy blessed martyr George, mercifully grant that all they which seek thy mercy through him may effectually obtain the gift of thy grace."))))

(bcp-roman-collectarium-register
 'deus-qui-nos-conspicis-ex
 (list :latin "Deus, qui nos cónspicis ex nostra infirmitáte defícere: ad amórem tuum nos misericórditer per Sanctórum tuórum exémpla restáura."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who seest that in our own weakness we do continually fall, make, in thy mercy, the examples of thy holy children a mean whereby to renew in us the love of thyself."))))

(bcp-roman-collectarium-register
 'deus-qui-nos-hodierna-die
 (list :latin "Deus, qui nos hodiérna die Exaltatiónis sanctæ Crucis ánnua solemnitáte lætíficas: præsta, quǽsumus; ut, cujus mystérium in terra cognóvimus, ejus redemptiónis prǽmia in cælo mereámur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who dost this day gladden us by the yearly Feast of the Exaltation of the Holy Cross, grant, we beseech thee, that even as we have understood the mystery thereof upon earth, so we may worthily enjoy in heaven the fruits of the redemption which was paid thereon."))))

(bcp-roman-collectarium-register
 'deus-qui-nos-per-beatos
 (list :latin "Deus, qui nos per beátos Apóstolos tuos Simónem et Judam ad agnitiónem tui nóminis veníre tribuísti: da nobis eórum glóriam sempitérnam et proficiéndo celebráre, et celebrándo profícere."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst use thine holy Apostles Simon and Jude to make known unto us thy Name, grant unto us so to profit by their doctrine as to do honour to their everlasting glory, and so to honour that glory as to gain profit to ourselves."))))

(bcp-roman-collectarium-register
 'deus-qui-novum-per-beatam
 (list :latin "Deus, qui novum per beátam Angelam sacrárum Vírginum collégium in Ecclésia tua floréscere voluísti: da nobis, ejus intercessióne, angélicis móribus vívere; ut, terrénis ómnibus abdicátis, gáudiis pérfrui mereámur ætérnis."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Whose will it hath been to use blessed Angela as a means whereby to make a new fellowship of virgins to grow and flourish in Thy Church, grant unto us, at her prayers, so angelically to live, that we may freely lay aside all earthly things, and worthily enter upon the enjoyment of those things which are eternal."))))

(bcp-roman-collectarium-register
 'deus-qui-omnia-pro-te
 (list :latin "Deus, qui ómnia pro te in hoc sǽculo relinquéntibus, céntuplum in futúro et vitam ætérnam promisísti: concéde propítius; ut, sancti Pontíficis Paulíni vestígiis inhæréntes, valeámus terréna despícere et sola cæléstia desideráre:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O God, who hast promised to them that leave all things in this world for thy sake to receive an hundredfold, and everlasting life in that which is to come: mercifully grant; that, following in the footsteps of thy blessed Saint Paulinus, we may be enabled to despise all things that are earthly, and to desire only those things that are heavenly."))))

(bcp-roman-collectarium-register
 'deus-qui-per-beatum-alfonsum
 (list :latin "Deus, qui per beátum Alfónsum Maríam Confessórem tuum atque Pontíficem, animárum zelo succénsum, Ecclésiam tuam nova prole fecundásti: quǽsumus; ut, ejus salutáribus mónitis edócti et exémplis roboráti, ad te perveníre felíciter valeámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst enkindle in thy Blessed Confessor and Bishop Alphonsus Mary a burning love of souls, and by him didst make thy Church the Mother of a new family, we pray thee to give us such strength that, taught by his wholesome doctrine and nerved by his example, we also may in the end happily attain unto thee."))))

(bcp-roman-collectarium-register
 'deus-qui-per-beatum-joannem
 (list :latin "Deus, qui per beátum Joánnem fidéles tuos in virtúte sanctíssimi nóminis Jesu de crucis inimícis triumpháre fecísti: præsta, quǽsumus; ut, spirituálium hóstium, ejus intercessióne, superátis insídiis, corónam justítiæ a te accípere mereámur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who by Thy blessed servant John didst cause Thy faithful people, through the power of the most Holy Name of Jesus, to prevail against the enemies of His Cross, grant unto us, we beseech Thee, the help of the prayers of the same Thy servant that we may prevail against our ghostly enemies, and may be made worthy to receive from Thee a crown of righteousness."))))

(bcp-roman-collectarium-register
 'deus-qui-per-beatum-philippum
 (list :latin "Deus, qui per beátum Philíppum Confessórem tuum, exímium nobis humilitátis exémplum tribuísti: da fámulis tuis próspera mundi ex ejus imitatióne despícere, et cæléstia semper inquírere."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who hast given us in thy blessed Confessor Philip a wonderful example of lowliness, grant unto thy servants walking in his steps to set little store by the pleasant things of this life, and to seek ever for that glory which Thou hast prepared in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-per-gloriosissimam-filii
 (list :latin "Deus, qui per gloriosíssimam Fílii tui Matrem, ad liberándos Christi fidéles a potestáte paganórum nova Ecclésiam tuam prole amplificáre dignátus es: præsta, quǽsumus; ut, quam pie venerámur tanti operis institutrícem, ejus páriter méritis et intercessióne, a peccátis ómnibus et captivitáte dǽmonis liberémur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who didst use the glorious Mother of thy Son as a mean to ransom Christ's faithful people out of the hands of the unbelievers, by enriching thy Church with yet another family, grant, we beseech thee, that we who reverently honour her as the Foundress of that great work, may for her sake and by her prayers, be redeemed from all sin and all bondage unto the evil one."))))

(bcp-roman-collectarium-register
 'deus-qui-per-immaculatam-virginis
 (list :latin "Deus, qui per immaculátam Vírginis Conceptiónem dignum Fílio tuo habitáculum præparásti: quǽsumus; ut qui ex morte ejúsdem Fílii tui prævísa, eam ab omni labe præservásti, nos quoque mundos ejus intercessióne ad te perveníre concédas."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, by the Immaculate Conception of the Virgin, thou prepared a worthy habitation for thy Son; we beseech thee, that, as by the foreseen death of thy same Son thou preserved her from all stain of sin, so thou would grant us also, through her intercession, to come to thee with pure hearts."))))

(bcp-roman-collectarium-register
 'deus-qui-per-sanctum-joannem
 (list :latin "Deus, qui per sanctum Joánnem órdinem sanctíssimæ Trinitátis ad rediméndum de potestáte Saracenórum captívos cǽlitus institúere dignátus es: præsta, quǽsumus; ut, ejus suffragántibus méritis, a captivitáte córporis et ánimæ, te adjuvánte, liberémur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who by a sign from heaven didst choose thy holy servant John to be the founder of the Order of the Most Holy Trinity for the Ransom of Prisoners held in the power of the Saracens, mercifully grant unto us for his sake that we may be delivered by thine Almighty power from all bonds and chains of sin, whether in our bodies or in our souls."))))

(bcp-roman-collectarium-register
 'deus-qui-per-sanctum-josephum
 (list :latin "Deus, qui per sanctum Joséphum Confessórem tuum, ad erudiéndam spíritu intellegéntiæ ac pietátis juventútem, novum Ecclésiæ tuæ subsídium providére dignátus es: præsta, quǽsumus; nos, ejus exémplo et intercessióne, ita fácere et docére, ut prǽmia consequámur ætérna."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who wast pleased to provide a new help for thy Church by raising up thine holy Confessor Joseph to train up the young in the spirit of understanding and godliness, we beseech thee for his sake, and by his prayers, to grant us the grace always so to work and so to teach, that we may finally attain unto thine everlasting joy."))))

(bcp-roman-collectarium-register
 'deus-qui-per-stultitiam-crucis
 (list :latin "Deus, qui per stultítiam crucis eminéntem Jesu Christi sciéntiam beátum Justínum Mártyrem mirabíliter docuísti: ejus nobis intercessióne concéde; ut, errórum circumventióne depúlsa, fídei firmitátem consequámur."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who through the preaching of the Cross, which is to them that perish foolishness, didst wonderfully teach unto thy blessed martyr Justin the excellency of the knowledge of Christ Jesus Our Lord, grant unto us at his prayers the grace to cast off all false teaching and ever to hold fast to the faith."))))

(bcp-roman-collectarium-register
 'deus-qui-prae-omnibus-sanctis
 (list :latin "Deus, qui præ ómnibus Sanctis tuis beátum Jóachim Genetrícis Fílii tui patrem esse voluísti: concéde, quǽsumus; ut, cujus festa venerámur, ejus quoque perpétuo patrocínia sentiámus."
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who, out of all thy Saints, didst choose blessed Joachim to be the father of the mother of thy Son, mercifully grant that as we hold his Festival in honour, we may ever feel his protection."))))

(bcp-roman-collectarium-register
 'deus-qui-praesentem-diem-honorabilem
 (list :latin "Deus, qui præséntem diem honorábilem nobis in beáti Joánnis nativitáte fecísti: da pópulis tuis spirituálium grátiam gaudiórum; et ómnium fidélium mentes dírige in viam salútis ætérnæ."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who hast made this day to be honourable in our eyes because of the Birth of the blessed John, graciously quicken thy people with spiritual joy, and order the minds of all the faithful in the way of everlasting salvation."))))

(bcp-roman-collectarium-register
 'deus-qui-sanctis-tuis-abdon
 (list :latin "Deus, qui sanctis tuis Abdon et Sennen ad hanc glóriam veniéndi copiósum munus grátiæ contulísti: da fámulis tuis suórum véniam peccatórum; ut, Sanctórum tuórum intercedéntibus méritis, ab ómnibus mereántur adversitátibus liberári."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst give unto thy saints Abdon and Sennen the abundant grace whereby to attain unto this glory, Grant unto thy servants the remission of all their sins, that, with the pleading of the worthy deeds of thy Saints, they may worthily be delivered from all things hurtful."))))

(bcp-roman-collectarium-register
 'deus-qui-sanctum-camillum-ad
 (list :latin "Deus, qui sanctum Camíllum, ad animárum in extrémo agóne luctántium subsídium, singulári caritátis prærogatíva decorásti: ejus, quǽsumus, méritis, spíritum nobis tuæ dilectiónis infúnde; ut in hora éxitus nostri hostem víncere, et ad cæléstem mereámur corónam perveníre."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who, to succour the souls of the dying in their last agony, didst ennoble the holy Camillus with an extraordinary grace of charity, we beseech thee to pour into our hearts, for his sake, the Spirit of thy love, that we may worthily prevail against the enemy in the hour when we depart hence, and pass to receive a crown of glory in heaven."))))

(bcp-roman-collectarium-register
 'deus-qui-sanctum-joannem-baptistam
 (list :latin "Deus, qui sanctum Joánnem Baptistam Confessorem tuum in evangelizandis pauperibus caritate et patientia decorasti: concede quǽsumus; ut cujus pia merita veneramur, virtutum quoque imitemur exempla."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who didst beautify Thine holy Confessor John Baptist with the graces of love and longsuffering in preaching Thy Gospel unto the poor, grant, we beseech Thee, unto us who honour his godly and worthy life the grace to follow after the example of his good works."))))

(bcp-roman-collectarium-register
 'deus-qui-sanctum-joannem-confessorem
 (list :latin "Deus, qui sanctum Joánnem Confessórem tuum adolescéntium patrem et magístrum excitásti, ac per eum, auxiliatríce Vírgine María, novas in Ecclésia tua famílias floréscere voluísti: concéde, quǽsumus; ut eódem caritátis igne succénsi, ánimas quǽrere, tibíque soli servíre valeámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, who didst raise up thy blessed Confessor John, to be a father and teacher of youth, and didst will that through him, with the help of the Virgin Mary, new families should flourish in the Church, grant we pray that enkindled with the same fire of charity we may be strong to seek after souls and to serve thee alone."))))

(bcp-roman-collectarium-register
 'deus-qui-universum-mundum-beati
 (list :latin "Deus, qui univérsum mundum beáti Pauli Apóstoli prædicatióne docuísti: da nobis, quǽsumus; ut, qui ejus hódie Conversiónem cólimus, per ejus ad te exémpla gradiámur.

_
@Sancti/01-25:Commemoratio4"
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who, through the teaching of the Blessed Apostle Paul, hast caused the light of the Gospel to shine throughout the world, grant, we beseech thee, that we, having his wonderful conversion as on this day in remembrance, may show forth our thankfulness unto thee for the same, by following the holy example which he hath set.

_
@Sancti/01-25:Commemoratio4"))))

(bcp-roman-collectarium-register
 'deus-virginitatis-amator-qui-beatam
 (list :latin "Deus, virginitátis amátor, qui beátam Maríam Magdalénam Vírginem, tuo amóre succénsam, cæléstibus donis decorásti: da; ut, quam festíva celebritáte venerámur, puritáte et caritáte imitémur."
       :conclusion 'per-dominum
       :translations
       '((do . "O God, lover of chastity, Who endowed with heavenly gifts blessed Mary Magdalen, a virgin on fire with love for You, grant that we who keep this feast-day in her honor may imitate her by purity and love."))))

(bcp-roman-collectarium-register
 'domine-deus-noster-qui-beatae
 (list :latin "Dómine, Deus noster, qui beátæ Birgíttæ per Fílium tuum unigénitum secréta cæléstia revelásti: ipsíus pia intercessióne da nobis fámulis tuis; in revelatióne sempitérnæ glóriæ tuæ gaudére lætántes."
       :conclusion 'per-eumdem
       :translations
       '((do . "O Lord our God, Who, through thine Only-begotten Son, didst cause thy blessed hand-maid Bridget to see certain things which are naturally known not on earth but in heaven, grant unto us thy servants at her motherly prayers, to be one day blessed for ever in the vision of thine eternal glory."))))

(bcp-roman-collectarium-register
 'domine-jesu-christe-qui-ad
 (list :latin "Dómine Jesu Christe, qui ad recoléndam memóriam dolórum sanctíssimæ Genetrícis tuæ, per septem beátos Patres nova Servórum ejus família Ecclésiam tuam fecundásti: concéde propítius; ita nos eórum consociári flétibus, ut perfruámur et gáudiis."
       :conclusion 'qui-vivis
       :translations
       '((do . "Lord Jesus Christ, who, that thou mightest recall to mind the woes of thy most holy Mother, didst through the Seven blessed Fathers make thy Church herself the mother of a new household of her servants, grant unto us in mercy that we may so share their tears as to share their blessedness also."))))

(bcp-roman-collectarium-register
 'domine-jesu-christe-qui-ad-0428
 (list :latin "Dómine Jesu Christe, qui, ad mystérium crucis prædicándum, sanctum Paulum singulári caritáte donásti, et per eum novam in Ecclésia famíliam floréscere voluísti: ipsíus nobis intercessióne concéde; ut, passiónem tuam júgiter recoléntes in terris, ejúsdem fructum cónsequi mereámur in cælis:"
       :conclusion 'qui-vivis
       :translations
       '((do . "Lord Jesus Christ, Who didst gift thine holy servant Paul with great love that he might preach the mystery of thy cross, and hast been pleased that through him a new family should grow up in thy Church, grant unto us at his prayers that upon earth we may so call thy sufferings to mind as worthily to gain the fruit thereof in heaven."))))

(bcp-roman-collectarium-register
 'domine-jesu-christe-qui-frigescente
 (list :latin "Dómine Jesu Christe, qui, frigescénte mundo, ad inflammándum corda nostra tui amóris igne, in carne beatíssimi Francísci passiónis tuæ sacra Stígmata renovásti: concéde propítius; ut ejus méritis et précibus crucem júgiter ferámus, et dignos fructus pæniténtiæ faciámus:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O Lord Jesus Christ, Who, when the love of many was waxing cold, didst manifest once more the holy marks of thine own Suffering in the flesh of thy most blessed servant Francis, to the end that our hearts might kindle again with the fire of the love of thyself, be Thou entreated for thy servant's sake, and grant to his and our prayers that we may effectually carry thy Cross and bring forth fruits meet for repentance."))))

(bcp-roman-collectarium-register
 'domine-jesu-christe-qui-investigabiles
 (list :latin "Dómine Jesu Christe, qui investigábiles divítias Cordis tui beátæ Margarítæ Maríæ Vírgini mirabíliter revelásti; da nobis ejus méritis et imitatióne; ut te in ómnibus et super ómnia diligéntes, jugem in eódem Corde tuo mansiónem habére mereámur:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O Lord Jesus Christ, who unto the holy virgin Margaret Mary didst in wondrous manner reveal the unsearchable riches of thy Heart, grant us, by her merits and example, that loving thee in all things and above all things, we may obtain an abode in thy Heart for evermore."))))

(bcp-roman-collectarium-register
 'domine-jesu-christe-verae-humilitatis
 (list :latin "Dómine Jesu Christe, veræ humilitátis et exémplar et prǽmium: quǽsumus; ut, sicut beátum Francíscum in terréni honóris contémptu imitatórem tui gloriósum effecísti, ita nos ejúsdem imitatiónis et glóriæ tríbuas esse consórtes:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O Lord Jesus Christ, model of true humility and its reward, we beseech Thee, that as Thou made blessed Francis one of Thy glorious imitators by his contempt for earthly honors, grant us to follow his example and to share in his glory."))))

(bcp-roman-collectarium-register
 'domine-jesu-qui-beato-bernardino
 (list :latin "Dómine Jesu, qui beáto Bernardíno Confessóri tuo exímium sancti nóminis tui amórem tribuísti: ejus, quǽsumus, méritis et intercessióne, spíritum nobis tuæ dilectiónis benígnus infúnde:"
       :conclusion 'qui-vivis
       :translations
       '((do . "O Lord Jesus, Which didst give unto thy blessed Confessor Bernardine the grace to love thy Holy Name exceeding well, be entreated, we beseech thee, for his sake and by his prayers, and mercifully pour into our hearts also the Spirit of thy love."))))

(bcp-roman-collectarium-register
 'domine-qui-dixisti-nisi-efficiamini
 (list :latin "Dómine, qui dixísti: Nisi efficiámini sicut párvuli, non intrábitis in regnum cælórum: da nobis, quǽsumus: ita sanctæ Terésiæ Vírginis in humilitáte et simplicitáte cordis vestígia sectári, ut prǽmia consequámur ætérna."
       :conclusion 'qui-vivis
       :translations
       '((do . "O Lord, who hast said: Unless you become as little children you shall not enter the kingdom of heaven, grant us, we pray, so to follow, in humility and simplicity of heart, the footsteps of the virgin blessed Theresa, that we may attain to an everlasting reward."))))

(bcp-roman-collectarium-register
 'ecclesiam-tuam-domine-benignus-illustra
 (list :latin "Ecclésiam tuam, Dómine, benígnus illústra: ut beáti Joánnis Apóstoli tui et Evangelístæ, illumináta doctrínis, ad dona pervéniat sempitérna."
       :conclusion 'per-dominum
       :translations
       '((do . "Shine upon thy Church, O Lord, in thy goodness, that, enlightened by the teachings of Blessed John, thy Apostle and Evangelist, she may attain to everlasting gifts."))))

(bcp-roman-collectarium-register
 'ecclesiam-tuam-domine-sancti-caroli
 (list :latin "Ecclésiam tuam, Dómine, sancti Cároli Confessóris tui atque Pontíficis contínua protectióne custódi: ut, sicut illum pastorális sollicitúdo gloriósum réddidit; ita nos ejus intercéssio in tuo semper fáciat amóre fervéntes."
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, give unto thy Church for an unsleeping warder thine holy Confessor Bishop Charles; upon earth his carefulness did make him glorious as a shepherd, there where he is may his prayerfulness make him effectual as a bedesman, pleading with thee to make us to love thee more."))))

(bcp-roman-collectarium-register
 'ecclesiam-tuam-quaesumus-domine-gratia
 (list :latin "Ecclésiam tuam, quǽsumus, Dómine, grátia cæléstis amplíficet: quam beáti Joánnis Chrysóstomi Confessóris tui atque Pontíficis illustráre voluísti gloriósis méritis et doctrínis."
       :conclusion 'per-dominum
       :translations
       '((do . "May heavenly grace, we beseech thee, O Lord, prosper thy Church, which thou mercifully enlightened by the blessed virtues and teachings of glorious and blessed John Chrysostom, thy Confessor and Bishop."))))

(bcp-roman-collectarium-register
 'esto-domine-plebi-tuae-sanctificator
 (list :latin "Esto, Dómine, plebi tuæ sanctificátor et custos: ut, Apóstoli tui Jacóbi muníta præsídiis, et conversatióne tibi pláceat, et secúra mente desérviat."
       :conclusion 'per-dominum
       :translations
       '((do . "Be Thou thyself, O Lord, the Sanctifier and the Shepherd of thy people, that we who are overshadowed by the help of thine Apostle James may, in our conversation, walk with thee, and in all quietness of spirit serve thee."))))

(bcp-roman-collectarium-register
 'exaudi-domine-populum-tuum-cum
 (list :latin "Exáudi, Dómine, pópulum tuum cum Sanctórum tuórum patrocínio supplicántem: ut et temporális vitæ nos tríbuas pace gaudére; et ætérnæ reperíre subsídium."
       :conclusion 'per-dominum
       :translations
       '((do . "Graciously hear, O Lord, the prayers of thy people who draw near unto thee under the protection of thy blessed Saints, granting us in this world thy peace, and in that which is to come life everlasting."))))

(bcp-roman-collectarium-register
 'exaudi-nos-deus-salutaris-noster
 (list :latin "Exáudi nos, Deus, salutáris noster: ut sicut de beátæ Terésiæ Vírginis tuæ festivitáte gaudémus; ita cæléstis ejus doctrínæ pábulo nutriámur, et piæ devotiónis erudiámur afféctu."
       :conclusion 'per-dominum
       :translations
       '((do . "Hear us, O God, our Savior, that as we rejoice in the feast of Blessed Teresa, thy Virgin, so we may be fed with the food of her heavenly teaching and be instructed in the affection of pious devotion."))))

(bcp-roman-collectarium-register
 'excita-quaesumus-domine-in-ecclesia
 (list :latin "Excita, quǽsumus, Dómine, in Ecclésia tua Spíritum, quo replétus beátus Jósaphat Martyr et Póntifex tuus ánimam suam pro óvibus pósuit: ut, eo intercedénte, nos quoque eódem Spíritu moti ac roboráti, ánimam nostram pro frátribus pónere non vereámur."
       :conclusion 'per-dominum
       :translations
       '((do . "Stir up in thy Church, we beseech thee, O Lord, that Spirit which so filled blessed Josaphat, thy Martyr and Bishop, that he laid down his life for his flock; that by his intercession we, being likewise animated and strengthened by that same Spirit, may not fear to lay down our lives for our brethren."))))

(bcp-roman-collectarium-register
 'fac-nos-domine-deus-supereminentem
 (list :latin "Fac nos, Dómine Deus, supereminéntem Jesu Christi sciéntiam, spíritu Pauli Apóstoli, edíscere: qua beátus Antónius María mirabíliter erudítus, novas in Ecclésia tua clericórum et vírginum famílias congregávit."
       :conclusion 'per-eumdem
       :translations
       '((do . "Make us able, O Lord God, in the Spirit of Thy blessed Apostle Paul, to know the love of Christ which passeth knowledge, wherein Thy blessed servant Anthony Mary was so wonderfully taught when he gathered together in thy Church new households of clerks and of virgins."))))

(bcp-roman-collectarium-register
 'fac-nos-quaesumus-domine-sanctorum
 (list :latin "Fac nos, quǽsumus, Dómine, sanctórum Mártyrum tuórum Primi et Feliciáni semper festa sectári: quorum suffrágiis protectiónis tuæ dona sentiámus."
       :conclusion 'per-dominum
       :translations
       '((do . "Make us, O Lord, we beseech thee, ever heartily to rejoice over thine holy martyrs Primus and Felician, and grant to us at their prayer the gift of thy safe-keeping."))))

(bcp-roman-collectarium-register
 'famulis-tuis-quaesumus-domine-caelestis
 (list :latin "Fámulis tuis, quǽsumus, Dómine, cæléstis grátiæ munus impertíre: ut, quibus beátæ Vírginis partus éxstitit salútis exórdium; Nativitátis ejus votíva solémnitas pacis tríbuat increméntum."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant unto us thy servants, we beseech thee, O Lord, the gift of thy heavenly grace, unto whom Thou didst give the first sight of a Saviour as the offspring of a Blessed Virgin, and grant that this Feast, which they keep in honour of the same Virgin, may avail them unto the increase of peace."))))

(bcp-roman-collectarium-register
 'interveniat-pro-nobis-quaesumus-domine
 (list :latin "Intervéniat pro nobis, quǽsumus, Dómine, sanctus tuus Lucas Evangelísta: qui crucis mortificatiónem júgiter in suo córpore, pro tui nóminis honóre, portávit."
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we beseech thee, that Luke, thy holy Evangelist, who for the honor of thy name bore continually in his body the suffering of the cross, may intercede in our behalf."))))

(bcp-roman-collectarium-register
 'majestatem-tuam-domine-suppliciter-exoramus
 (list :latin "Majestátem tuam, Dómine, supplíciter exorámus: ut, sicut Ecclésiæ tuæ beátus Andréas Apóstolus éxstitit prædicátor et rector; ita apud te sit pro nobis perpétuus intercéssor."
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we humbly beseech thy Majesty, that even as Thou didst give thy blessed Apostle Andrew to thy Church to be a teacher and a ruler on earth, so, now that he is with thee, he may continually make intercession for us."))))

(bcp-roman-collectarium-register
 'omnipotens-et-misericors-deus-qui
 (list :latin "Omnípotens et miséricors Deus, qui sanctum Joánnem Maríam pastoráli stúdio et jugi oratiónis ac pœniténtiæ ardóre mirábilem effecísti: da, quǽsumus; ut, ejus exémplo et intercessióne, ánimas fratrum lucrári Christo, et cum eis ætérnam glóriam cónsequi valeámus."
       :conclusion 'per-eumdem
       :translations
       '((do . "Almighty and merciful God, who didst make St. John Mary to be wonderful in pastoral zeal and unchanging love for prayer and penance, grant we beseech thee, that by his example and intercession we may be able to gain the souls of our brethren in Christ, and with them to arrive at the glory of eternity."))))

(bcp-roman-collectarium-register
 'omnipotens-et-misericors-deus-qui-0821
 (list :latin "Omnípotens et miséricors Deus, qui beátam Joánnam Francíscam, tuo amóre succénsam, admirábili spíritus fortitúdine per omnes vitæ sémitas in via perfectiónis donásti, quique per illam illustráre Ecclésiam tuam nova prole voluísti: ejus méritis et précibus concéde; ut, qui infirmitátis nostræ cónscii de tua virtúte confídimus, cæléstis grátiæ auxílio cuncta nobis adversántia vincámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O Almighty and merciful God, Who didst enkindle the love of thyself in the blessed Jeanne Frances, Who didst give unto her the grace to make every path of life temporal the straight and narrow way which leadeth unto life eternal, and Who wast pleased to use her as a mean whereby to adorn thy Church with a new sisterhood, grant unto us for that thine handmaid's sake, and at her prayers, that we who know that we have no strength as of ourselves to help ourselves, and therefore do put all our trust in thine Almighty power, may by the assistance of thy heavenly grace, always prevail in all things against whatsoever shall arise to fight against us."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-majestatem-tuam
 (list :latin "Omnípotens sempitérne Deus, majestátem tuam súpplices exorámus: ut, sicut unigénitus Fílius tuus hodiérna die cum nostræ carnis substántia in templo est præsentátus; ita nos fácias purificátis tibi méntibus præsentári."
       :conclusion 'per-eumdem
       :translations
       '((do . "Almighty and everliving God, we humbly beseech thy Majesty, that as thy Only-begotten Son was this day presented in the temple in substance of our flesh, so we may be presented unto thee with pure and clean hearts."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-ad
 (list :latin "Omnípotens sempitérne Deus, qui ad cultum sacrárum imáginum asseréndum, beátum Joánnem cælésti doctrína et admirábili spíritus fortitúdine imbuísti: concéde nobis ejus intercessióne et exémplo; ut, quorum cólimus imágines, virtútes imitémur et patrocínia sentiámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O Almighty and everlasting God, Who didst fill Thy blessed servant John with heavenly teaching, and wondrous strength of spirit to maintain the honouring of holy images. Grant unto us at his prayers and after his example to take pattern by their holy lives whose images we honour, and ever to feel the power of their help."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-dispositione
 (list :latin "Omnípotens sempitérne Deus, qui dispositióne mirábili infírma mundi éligis, ut fórtia quæque confúndas: concéde propítius humilitáti nostræ; ut, piis beáti Dídaci Confessóris tui précibus, ad perénnem in cælis glóriam sublimári mereámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O Almighty and everlasting God, Who in thy wonderful ordinance dost choose the weak things of the world to bring to nought the things that are strong, mercifully grant unto us thine unworthy servants, at the kindly prayers of thy blessed Confessor Diego, worthily to attain unto everlasting glory in heaven."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-hujus
 (list :latin "Omnípotens sempitérne Deus, qui hujus diéi venerándam sanctámque lætítiam in beáti Apóstoli tui Bartholomǽi festivitáte tribuísti: da Ecclésiæ tuæ, quǽsumus; et amáre quod crédidit, et prædicáre quod dócuit."
       :conclusion 'per-dominum
       :translations
       '((do . "O Almighty and everlasting God, Who hast given unto us this day to be a day worshipful, and holy, and joyful, because of the Feast of thy blessed Apostle Bartholomew, grant, we beseech thee, unto thy Church both to love that which he believed, and to preach that which he taught."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-immaculatam
 (list :latin "Omnípotens sempitérne Deus, qui Immaculátam Vírginem Maríam, Fílii tui Genetrícem, córpore et ánima ad cæléstem glóriam assumpsísti: concéde, quǽsumus; ut ad supérna semper inténti, ipsíus glóriæ mereámur esse consórtes."
       :conclusion 'per-eumdem
       :translations
       '((do . "Almighty everlasting God, who hast taken body and soul into heaven the Immaculate Virgin Mary, Mother of thy Son: grant, we beseech thee, that by steadfastly keeping heaven as our goal we may be counted worthy to join her in glory."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-in
 (list :latin "Omnípotens sempitérne Deus, qui in Corde beátæ Maríæ Vírginis dignum Spíritus Sancti habitáculum præparásti: concéde propítius; ut ejúsdem immaculáti Cordis festivitátem devóta mente recoléntes, secúndum Cor tuum vívere valeámus."
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty everlasting God, who hast prepared in the heart of Blessed Virgin Mary a worthy dwelling of the Holy Ghost, grant favourably to us that we may keep the feast of the same Immaculate Heart devoutly, and may be able to live according to thy heart."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-infirma
 (list :latin "Omnípotens sempitérne Deus, qui infírma mundi éligis, ut fórtia quæque confúndas: concéde propítius; ut, qui beátæ Agnétis Vírginis et Mártyris tuæ solémnia cólimus, ejus apud te patrocínia sentiámus."
       :conclusion 'per-dominum
       :translations
       '((do . "O Almighty and everlasting God, Who hast chosen the weak things of the world to confound the things which are mighty, mercifully grant unto us that we who keep the solemn feast of thy blessed Virgin and Martyr Agnes, may feel the power of her intercession with thee."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-nos
 (list :latin "Omnípotens sempitérne Deus, qui nos ómnium Sanctórum tuórum mérita sub una tribuísti celebritáte venerári: quǽsumus; ut desiderátam nobis tuæ propitiatiónis abundántiam, multiplicátis intercessóribus, largiáris."
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty, eternal God, Who granted us to honor the merits of all Thy Saints in a single solemn festival, bestow on us, we beseech Thee, through their manifold intercession, that abundance of Thy mercy for which we yearn."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-slavoniae
 (list :latin "Omnípotens sempitérne Deus, qui Slavóniæ gentes per beátos Confessóres tuos atque Pontífices Cyríllum et Methódium ad agnitiónem tui nóminis veníre tribuísti: præsta; ut, quorum festivitáte gloriámur, eórum consórtio copulémur."
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty and everlasting God, Who hast granted unto the Slavic peoples the knowledge of thy Name through the mean of thy blessed Confessors and Bishops Cyril and Methodius, grant that we, who here keep gladly the festival of the same thy Saints, may hereafter be gathered unto their company."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-unigenitum
 (list :latin "Omnípotens sempitérne Deus, qui unigénitum Fílium tuum mundi Redemptórem constituísti, ac ejus Sánguine placári voluísti: concéde, quǽsumus, salútis nostræ prétium solémni cultu ita venerári, atque a præséntis vitæ malis ejus virtúte deféndi in terris; ut fructu perpétuo lætémur in cælis."
       :conclusion 'per-eumdem
       :translations
       '((do . "Almighty, eternal God, Who made thy only-begotten Son the Redeemer of the world, and willed to be reconciled by His Blood, grant us, we beseech thee, so to worship in this sacred rite the price of our salvation, and to be so protected by its power against the evils of the present life on earth, that we may enjoy its everlasting fruit in heaven."))))

(bcp-roman-collectarium-register
 'praesta-quaesumus-omnipotens-deus-ut
 (list :latin "Præsta, quǽsumus, omnípotens Deus: ut, qui sanctórum Mártyrum tuórum Cosmæ et Damiáni natalícia cólimus, a cunctis malis imminéntibus, eórum intercessiónibus, liberémur."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech thee, O Almighty God, that we who keep the birthday of thine holy Martyrs Cosmas and Damian may at their prayers be delivered from all dangers that presently hang over us."))))

(bcp-roman-collectarium-register
 'praesta-quaesumus-omnipotens-deus-ut-0429
 (list :latin "Præsta, quǽsumus, omnípotens Deus: ut beáti Petri Mártyris tui fidem cóngrua devotióne sectémur; qui, pro ejúsdem fídei dilatatióne, martýrii palmam méruit obtinére."
       :conclusion 'per-dominum
       :translations
       '((do . "Grant us grace, we beseech thee, O Almighty God, to follow with zeal conformable thereto after the pattern of that great example of faith, thy blessed Martyr Peter, who, for the spreading of the same faith, did so run as to obtain the palm of martyrdom."))))

(bcp-roman-collectarium-register
 'preces-populi-tui-quaesumus-domine
 (list :latin "Preces pópuli tui, quǽsumus, Dómine, cleménter exáudi: ut beáti Marcélli Mártyris tui atque Pontíficis méritis adjuvémur, cujus passióne lætámur."
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we pray thee, mercifully give ear unto the prayers of thy people who rejoice at the memory of the victory through suffering of thy blessed Martyr and Bishop Marcellus, and for his sake succour us."))))

(bcp-roman-collectarium-register
 'quaesumus-omnipotens-deus-ut-nos
 (list :latin "Quǽsumus, omnípotens Deus: ut nos gemináta lætítia hodiérnæ festivitátis excípiat, quæ de beatórum Joánnis et Pauli glorificatióne procédit; quos éadem fides et pássio vere fecit esse germános."
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty God, fill us, we beseech thee, with the twofold gladness which doth flow down upon this bright day from the glory of thy blessed servants John and Paul, whom one faith and one suffering made to be brothers indeed."))))

(bcp-roman-collectarium-register
 'sancti-antonini-domine-confessoris-tui
 (list :latin "Sancti Antoníni, Dómine, Confessóris tui atque Pontíficis méritis adjuvémur: ut, sicut te in illo mirábilem prædicámus, ita in nos misericórdem fuísse gloriémur."
       :conclusion 'per-dominum
       :translations
       '((do . "Help us, O Lord, we beseech thee, for the sake of thine holy Bishop and Confessor Antonine, and so show thyself merciful in us, Who didst show thyself wondrous in him."))))

(bcp-roman-collectarium-register
 'sancti-brunonis-confessoris-tui-quaesumus
 (list :latin "Sancti Brunónis Confessóris tui, quǽsumus, Dómine, intercessiónibus adjuvémur: ut, qui majestátem tuam gráviter delinquéndo offéndimus, ejus méritis et précibus, nostrórum delictórum véniam consequámur."
       :conclusion 'per-dominum
       :translations
       '((do . "May we be aided by the intercession of St. Bruno, thy Confessor, we beseech thee, O Lord; that we, who have grievously offended thy Majesty by sin, may, by his merits and prayers, obtain forgiveness for our offenses."))))

(bcp-roman-collectarium-register
 'sancti-joannis-baptistae-praecursoris-et
 (list :latin "Sancti Joánnis Baptístæ Præcursóris et Mártyris tui, quǽsumus, Dómine, veneránda festívitas: salutáris auxílii nobis præstet efféctum:"
       :conclusion 'qui-vivis
       :translations
       '((do . "Lord, we beseech thee, that the keeping of this honourable feastday in memory of the holy Baptist John, thy Fore-runner, and thy Martyr, may be a mean to draw upon us the effectual outpouring of thy saving help."))))

(bcp-roman-collectarium-register
 'sanctissimae-genetricis-tuae-sponsi-quaesumus
 (list :latin "Sanctíssimæ Genetrícis tuæ sponsi, quǽsumus, Dómine, méritis adjuvémur; ut quod possibílitas nostra non óbtinet, ejus nobis intercessióne donétur."
       :conclusion 'qui-vivis
       :translations
       '((do . "Help us, we beseech thee, O Lord, for the sake of the Husband of thy most holy Mother, that what we cannot for ourselves obtain, Thou mayest grant us at his petition."))))

(bcp-roman-collectarium-register
 'sanctorum-martyrum-tuorum-tiburtii-et
 (list :latin "Sanctórum Mártyrum tuórum Tibúrtii et Susánnæ nos, Dómine, fóveant continuáta præsídia: quia non désinis propítius intuéri; quos tálibus auxíliis concésseris adjuvári."
       :conclusion 'per-dominum
       :translations
       '((do . "Lord, let the constant succour of Thine holy Martyrs Tiburtius and Susanna continually defend us, for Thou never failest to look in mercy upon all them unto whom Thou dost grant the aid of such helpers."))))

(bcp-roman-collectarium-register
 'sanctorum-tuorum-nos-domine-nazarii
 (list :latin "Sanctórum tuórum nos, Dómine, Nazárii, Celsi, Victóris et Innocéntii conféssio beáta commúniat: et fragilitáti nostræ subsídium dignánter exóret."
       :conclusion 'per-dominum
       :translations
       '((do . "Upon us, O Lord, be somewhat of the blessing of the testification of thine holy servants Nazarius, Celsus, Victor, and Innocent, and may the same ever plead with thee on behalf of our weakness, and ever obtain for us thy succour."))))

(bcp-roman-collectarium-register
 'sanctus-tuus-domine-gorgonius-sua
 (list :latin "Sanctus tuus, Dómine, Gorgónius sua nos intercessióne lætíficet: et pia fáciat solemnitáte gaudére."
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, may thine holy servant Gorgonius gladden us by his prayers, and make this his blessed Festival to be unto us indeed a day of rejoicing."))))

(bcp-roman-collectarium-register
 'semper-nos-domine-martyrum-tuorum
 (list :latin "Semper nos, Dómine, Mártyrum tuórum Nérei, Achíllei, Domitíllæ atque Pancrátii fóveat, quǽsumus, beáta solémnitas: et tuo dignos reddat obséquio."
       :conclusion 'per-dominum
       :translations
       '((do . "May the holy feast of thy Martyrs, Nereus, Achilleus, Domitilla and Pancras, ever comfort us, we beseech thee, O Lord, and make us worthy to serve thee."))))

(bcp-roman-collectarium-register
 'tuorum-corda-fidelium-deus-miserator
 (list :latin "Tuórum corda fidélium, Deus miserátor, illústra: et, beátæ Elísabeth précibus gloriósis; fac nos próspera mundi despícere, et cælésti semper consolatióne gaudére."
       :conclusion 'per-dominum
       :translations
       '((do . "Enlighten, O God of mercy, the hearts of thy faithful people, and by the glorious prayers of thy blessed handmaid Elizabeth, make us to set little store by the good things of this world, and to rejoice ever in thy heavenly comfort."))))

;;;; Commune-based collects (N. → saint name substitution)
;;; :COLLECT-REGISTRATIONS-COMMUNE-START:
(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0114
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Hilárium Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Hilary thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-pauli
 '(:latin "Deus, qui nos beáti Pauli Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Paul, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-antonii
 '(:latin "Deus, qui nos beáti Antónii Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Anthony, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0118
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti N. Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of N. thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti N. Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Be mindful of our weakness, almighty God, and since the burden of our sins weighs heavily upon us, may the glorious intercession of thy holy Martyrs Fabian and Sebastian sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0124
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Timóthei Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Timothy, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0126
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Polycárpi Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Polycarp, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-inter-cetera-potentiae
 '(:latin "Deus, qui inter cétera poténtiæ tuæ mirácula étiam in sexu frágili victóriam martýrii contulísti: concéde propítius; ut, qui beátæ Martínæ Vírginis et Mártyris tuæ natalícia cólimus, per ejus ad te exémpla gradiámur."
   :translations ((do . "O God, Who among the other miracles of thy power have bestowed the victory of martyrdom even upon the weaker sex, graciously grant that we who commemorate the anniversary of the death of blessed Martina, thy Virgin and Martyr, may come to thee by the path of her example."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0201
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Ignátii Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Ignatius, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0203
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Blásii Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Blaise, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-inter-cetera-potentiae-0205
 '(:latin "Deus, qui inter cétera poténtiæ tuæ mirácula étiam in sexu frágili victóriam martýrii contulísti: concéde propítius; ut, qui beátæ Agathæ Vírginis et Mártyris tuæ natalícia cólimus, per ejus ad te exémpla gradiámur."
   :translations ((do . "O God, Who among the other miracles of thy power have bestowed the victory of martyrdom even upon the weaker sex, graciously grant that we who commemorate the anniversary of the death of blessed Agatha, thy Virgin and Martyr, may come to thee by the path of her example."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-romualdi
 '(:latin "Deus, qui nos beáti Romuáldi Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Romuald, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'beatorum-martyrum-pariterque-pontificum-faustini
 '(:latin "Beatórum Mártyrum paritérque Pontíficum Faustíni et Jovítæ et Faustíni et Jovítæ nos, quǽsumus, Dómine, festa tueántur: et eórum comméndet orátio veneránda."
   :translations ((do . "May the feast of the blessed Martyrs and Bishops Faustinus and Jovita and Faustinus and Jovita, protect us, O Lord, we beseech You, and may their holy prayer recommend us unto You."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0218
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Simeónis Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Simeon, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-inter-cetera-potentiae-0306
 '(:latin "Deus, qui inter cétera poténtiæ tuæ mirácula étiam in sexu frágili victóriam martýrii contulísti: concéde propítius; ut, qui beátæ Perpétuæ et Felicitátis Mártyris tuæ natalícia cólimus, per ejus ad te exémpla gradiámur."
   :translations ((do . "O God, Who, amidst the wondrous work of thy divine power, dost make even weak women to be more than conquerors in the uplifting of their testimony, mercifully grant unto all us which do keep the birthday of thy blessed witness Perpetua and Felicitas, grace to follow her steps toward thee."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-benedicti
 '(:latin "Deus, qui nos beáti Benedícti Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Benedict, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0404
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Isidórum Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Isidore thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0411
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Leónem Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Leo thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0417
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Anicéti Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Anciet, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0421
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Ansélmum Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Anselm thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'beatorum-martyrum-pariterque-pontificum-soteris
 '(:latin "Beatórum Mártyrum paritérque Pontíficum Sotéris et Caji et Sotéris et Caji nos, quǽsumus, Dómine, festa tueántur: et eórum comméndet orátio veneránda."
   :translations ((do . "May the feast of the blessed Martyrs and Bishops Soter and Caius and Soter and Caius, protect us, O Lord, we beseech You, and may their holy prayer recommend us unto You."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'beatorum-martyrum-pariterque-pontificum-cleti
 '(:latin "Beatórum Mártyrum paritérque Pontíficum Cleti et Marcellíni et Cleti et Marcellíni nos, quǽsumus, Dómine, festa tueántur: et eórum comméndet orátio veneránda."
   :translations ((do . "May the feast of the blessed Martyrs and Bishops Cletus and Marcellinus and Cletus and Marcellinus, protect us, O Lord, we beseech You, and may their holy prayer recommend us unto You."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'exaudi-quaesumus-domine-preces-nostras
 '(:latin "Exáudi, quǽsumus, Dómine, preces nostras, quas in beáti N. Confessóris tui atque Pontíficis solemnitáte deférimus: et, qui tibi digne méruit famulári, ejus intercedéntibus méritis, ab ómnibus nos absólve peccátis."
   :translations nil
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-inter-cetera-potentiae-0504
 '(:latin "Deus, qui inter cétera poténtiæ tuæ mirácula étiam in sexu frágili victóriam martýrii contulísti: concéde propítius; ut, qui beátæ Mónicæ Mártyris tuæ natalícia cólimus, per ejus ad te exémpla gradiámur."
   :translations ((do . "O God, Who, amidst the wondrous work of thy divine power, dost make even weak women to be more than conquerors in the uplifting of their testimony, mercifully grant unto all us which do keep the birthday of thy blessed witness Monica, grace to follow her steps toward thee."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0509
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Gregórium Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Gregory thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0530
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Felícis Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Felix, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-antoni
 '(:latin "Deus, qui nos beáti Antóni Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Anthony, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'exaudi-quaesumus-domine-preces-nostras-0614
 '(:latin "Exáudi, quǽsumus, Dómine, preces nostras, quas in beáti N. Confessóris tui atque Pontíficis solemnitáte deférimus: et, qui tibi digne méruit famulári, ejus intercedéntibus méritis, ab ómnibus nos absólve peccátis."
   :translations nil
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0620
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Silvérii Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Silverius, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0703
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Leónem Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Leo thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0711
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Pii Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Pius, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-joannis
 '(:latin "Deus, qui nos beáti Joánnis Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor John, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0713
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Anacléti Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Anacletus, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0714
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Bonaventúram Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Bonaventure thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-alexii
 '(:latin "Deus, qui nos beáti Aléxii Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Alexis, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-inter-cetera-potentiae-0721
 '(:latin "Deus, qui inter cétera poténtiæ tuæ mirácula étiam in sexu frágili victóriam martýrii contulísti: concéde propítius; ut, qui beátæ Praxédis Vírginis et Mártyris tuæ natalícia cólimus, per ejus ad te exémpla gradiámur."
   :translations ((do . "O God, Who among the other miracles of thy power have bestowed the victory of martyrdom even upon the weaker sex, graciously grant that we who commemorate the anniversary of the death of blessed Praxedes, thy Virgin and Martyr, may come to thee by the path of her example."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0727
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Pantaleóne Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Pantaleon, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-inter-cetera-potentiae-0729
 '(:latin "Deus, qui inter cétera poténtiæ tuæ mirácula étiam in sexu frágili victóriam martýrii contulísti: concéde propítius; ut, qui beátæ Marthæ Vírginis et Mártyris tuæ natalícia cólimus, per ejus ad te exémpla gradiámur."
   :translations ((do . "O God, Who among the other miracles of thy power have bestowed the victory of martyrdom even upon the weaker sex, graciously grant that we who commemorate the anniversary of the death of blessed Martha, thy Virgin and Martyr, may come to thee by the path of her example."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'concede-nos-famulos-tuos
 '(:latin "Concéde nos fámulos tuos, quǽsumus, Dómine Deus, perpétua mentis et córporis sanitáte gaudére: et, gloriósa beátæ Maríæ semper Vírginis intercessióne, a præsénti liberári tristítia, et ætérna pérfrui lætítia."
   :translations ((do . "Grant, we beseech thee, O Lord God, unto all thy servants, that they may remain continually in the enjoyment of soundness both of mind and body, and by the glorious intercession of the Blessed Mary, always a Virgin, may be delivered from present sadness, and enter into the joy of thine eternal gladness."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'beatorum-martyrum-pariterque-pontificum-cyriaci
 '(:latin "Beatórum Mártyrum paritérque Pontíficum Cyríaci, Largi et Smarágdi et Cyríaci, Largi et Smarágdi nos, quǽsumus, Dómine, festa tueántur: et eórum comméndet orátio veneránda."
   :translations ((do . "May the feast of the blessed Martyrs and Bishops Cyriacus, Largus, and Smaragdus and Cyriacus, Largus, and Smaragdus, protect us, O Lord, we beseech You, and may their holy prayer recommend us unto You."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-inter-cetera-potentiae-0812
 '(:latin "Deus, qui inter cétera poténtiæ tuæ mirácula étiam in sexu frágili victóriam martýrii contulísti: concéde propítius; ut, qui beátæ Claræ Vírginis et Mártyris tuæ natalícia cólimus, per ejus ad te exémpla gradiámur."
   :translations ((do . "O God, Who among the other miracles of thy power have bestowed the victory of martyrdom even upon the weaker sex, graciously grant that we who commemorate the anniversary of the death of blessed Clare, thy Virgin and Martyr, may come to thee by the path of her example."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-hyacinthi
 '(:latin "Deus, qui nos beáti Hyacínthi Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Hyacinth, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-bernardum
 '(:latin "Deus, qui nos beáti Bernárdum Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Bernard, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0826
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Zephyrínum Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Zephyrinus, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-aegidii
 '(:latin "Deus, qui nos beáti Ægídii Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Giles, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-0905
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Lauréntii Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Laurence thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-nicolai
 '(:latin "Deus, qui nos beáti Nicolái Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Nicolaus, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'beatorum-martyrum-pariterque-pontificum-cornelii
 '(:latin "Beatórum Mártyrum paritérque Pontíficum Cornélii et Cypriáni et Cornélii et Cypriáni nos, quǽsumus, Dómine, festa tueántur: et eórum comméndet orátio veneránda."
   :translations ((do . "May the feast of the blessed Martyrs and Bishops Cornelius and Cyprian and Cornelius and Cyprian, protect us, O Lord, we beseech You, and may their holy prayer recommend us unto You."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'beatorum-martyrum-pariterque-pontificum-januarii
 '(:latin "Beatórum Mártyrum paritérque Pontíficum Januárii et Sociórum ejus et Januárii et Sociórum ejus nos, quǽsumus, Dómine, festa tueántur: et eórum comméndet orátio veneránda."
   :translations ((do . "May the feast of the blessed Martyrs and Bishops Januarius and companions and Januarius and companions, protect us, O Lord, we beseech You, and may their holy prayer recommend us unto You."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'beatorum-martyrum-pariterque-pontificum-eustachii
 '(:latin "Beatórum Mártyrum paritérque Pontíficum Eustáchii et Sociórum ejus et Eustáchii et Sociórum ejus nos, quǽsumus, Dómine, festa tueántur: et eórum comméndet orátio veneránda."
   :translations ((do . "May the feast of the blessed Martyrs and Bishops Eustache and his companions and Eustache and his companions, protect us, O Lord, we beseech You, and may their holy prayer recommend us unto You."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-0923
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Lini Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Linus, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-miro-ordine-angelorum-0929
 '(:latin "Deus, qui, miro órdine, Angelórum ministéria hominúmque dispénsas: concéde propítius; ut, a quibus tibi ministrántibus in cælo semper assístitur, ab his in terra vita nostra muniátur."
   :translations nil
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-1001
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Remígii Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Remigius thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-concedis-sanctorum
 '(:latin "Deus, qui nos concédis sanctórum Mártyrum tuórum N. et N. natalítia cólere: da nobis in ætérna beatitúdine de eórum societáte gaudére."
   :translations nil
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-hilarionis
 '(:latin "Deus, qui nos beáti Hilariónis Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Hilarion, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-1026
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Evarísti Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Evaristus, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-1112
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Martíni Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Martin, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-1117
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Gregórii Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Gregory thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-1123
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Cleméntem Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Clement, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-joannes
 '(:latin "Deus, qui nos beáti Joánnes Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor John, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'deus-qui-nos-beati-sabbae
 '(:latin "Deus, qui nos beáti Sabbæ Confessóris tui ánnua solemnitáte lætíficas: concéde propítius; ut cujus natalítia cólimus, étiam actiónes imitémur."
   :translations ((do . "O God, Who, year by year, dost gladden us by the solemn feast-day of thy blessed confessor Sabbas, mercifully grant unto all who keep his birthday, grace to follow after the pattern of his godly conversation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-1207
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Ambrósium Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Ambrose thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-1211
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Dámaso Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Damasus thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'exaudi-nos-deus-salutaris-noster-1213
 '(:latin "Exáudi nos, Deus, salutáris noster: ut sicut de beátæ N. festivitáte gaudémus; ita piæ devotiónis erudiámur afféctu."
   :translations nil
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'infirmitatem-nostram-respice-omnipotens-deus-1216
 '(:latin "Infirmitátem nostram réspice, omnípotens Deus: et, quia pondus própriæ actiónis gravat, beáti Eusébii Mártyris tui atque Pontíficis intercéssio gloriósa nos prótegat."
   :translations ((do . "Mercifully consider our weakness, O Almighty God, and whereas by the burden of our sins we are sore, may the glorious intercession of blessed Eusebius, Your Martyr and Bishop, sustain us."))
   :conclusion per-dominum))

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-1231
 '(:latin "Da, quǽsumus, omnípotens Deus: ut beáti Silvéstri Confessóris tui atque Pontíficis veneránda solémnitas, et devotiónem nobis áugeat et salútem."
   :translations ((do . "Grant, we beseech thee, almighty God, that the venerable feast of Sylvester thy blessed Confessor and Bishop may increase our devotion and promote our salvation."))
   :conclusion per-dominum))

;;;; Moveable feast collects

(bcp-roman-collectarium-register
 'deus-qui-nobis-sub-sacramento
 '(:latin "Deus, qui nobis sub Sacraménto mirábili passiónis tuæ memóriam reliquísti: tríbue, quǽsumus, ita nos Córporis, et Sánguinis tui sacra mystéria venerári; ut redemptiónis tuæ fructum in nobis júgiter sentiámus:"
   :translations ((do . "O God, under a marvelous sacrament you have left us the memorial of thy Passion; grant us, we beseech thee, so to venerate the sacred mysteries of thy Body and Blood, that we may ever perceive within us the fruit of thy Redemption."))
   :conclusion qui-vivis))

(bcp-roman-collectarium-register
 'deus-qui-nobis-in-corde
 '(:latin "Deus, qui nobis in Corde Fílii tui, nostris vulneráto peccátis, infinítos dilectiónis thesáuros misericórditer largíri dignáris; concéde, quǽsumus, ut illi devótum pietátis nostræ præstántes obséquium, dignæ quoque satisfactiónis exhibeámus offícium."
   :translations ((do . "O God, who hast suffered the Heart of thy Son to be wounded by our sins, and in that very Heart hast bestowed on us the abundant riches of thy love: grant that the devout homage of our hearts, which we render unto him, may of thy mercy be deemed a recompence acceptable in thy sight."))
   :conclusion per-eumdem))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-in-dilecto
 '(:latin "Omnípotens sempitérne Deus, qui in dilécto Fílio tuo, universórum Rege, ómnia instauráre voluísti: concéde propítius; ut cunctæ famíliæ géntium, peccáti vúlnere disgregátæ, ejus suavíssimo subdántur império:"
   :translations ((do . "Almighty and everlasting God, who in thy beloved Son, the King of the whole world, hast willed to restore all things: mercifully grant that all the families of nations, now kept apart by the wound of sin, may be brought under the sweet yoke of his rule."))
   :conclusion qui-tecum))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Calendar data

(defconst bcp-roman-proprium--calendar
  '(
    ;; ── JANUARY ────────────────────────────────────────────────

    ((1 . 14) . (:name "St. Hilary, Bishop of Poitiers, C.D."
                  :latin "S. Hilarii Episcopi Confessoris Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0114))

    ((1 . 15) . (:name "St. Paul the First Hermit, C."
                  :latin "S. Pauli Primi Eremitæ et Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-pauli))

    ((1 . 16) . (:name "St. Marcellus, P.M."
                  :latin "S. Marcelli Papæ et Martyris"
                  :rank semiduplex
                  :commune C2
                  :collect preces-populi-tui-quaesumus-domine))

    ((1 . 17) . (:name "S. Anthony, Ab."
                  :latin "S. Antonii Abbatis"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-antonii))

    ((1 . 18) . (:name "Chair of St. Peter at Rome"
                  :latin "Cathedræ S. Petri Romæ"
                  :rank duplex-majus
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0118))

    ((1 . 19) . (:name "Ss. Marius, Martha, Audifax, and Abachum, M.s"
                  :latin "Ss. Marii, Marthæ, Audifacis, et Abachum Martyrum"
                  :rank simplex
                  :commune C3
                  :collect exaudi-domine-populum-tuum-cum))

    ((1 . 20) . (:name "Ss. Fabian and Sebastian, M.s"
                  :latin "Ss. Fabiani et Sebastiani Martyrum"
                  :rank duplex
                  :commune C3
                  :collect infirmitatem-nostram-respice-omnipotens-deus))

    ((1 . 21) . (:name "S. Agnes, V.M."
                  :latin "S. Agnetis Virginis et Martyris"
                  :rank duplex
                  :commune C6
                  :collect omnipotens-sempiterne-deus-qui-infirma))

    ((1 . 22) . (:name "Ss. Vincent and Anastasius, M.s"
                  :latin "Ss. Vincentii et Anastasii Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect adesto-domine-supplicationibus-nostris-ut))

    ((1 . 23) . (:name "S. Raymond of Penafort, C."
                  :latin "S. Raymundi de Peñafort Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect deus-qui-beatum-raymundum-poenitentiae))

    ((1 . 24) . (:name "St. Timothy, Bp.M."
                  :latin "S. Timothei Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0124))

    ((1 . 25) . (:name "Conversion of St. Paul the Apostle"
                  :latin "In Conversione S. Pauli Apostoli"
                  :rank duplex-majus
                  :commune nil
                  :collect deus-qui-universum-mundum-beati

                  ;; ── Matins ──
                  ;; ex Sancti/06-30 base; own invitatory and Noc I-II lessons.
                  ;; Antiphons, hymn, and responsories from Jun 30.
                  ;; Noc III lessons from C1 (in 2 loco): Bede on Matt 19:27-29.
                  :invitatory laudemus-deum-nostrum-in-conversione
                  :hymn egregie-doctor-paule
                  :psalms-1 ((qui-operatus-est-petro . 18)
                             (scio-cui-credidi . 33)
                             (mihi-vivere-christus-est . 44))
                  :psalms-2 ((tu-es-vas-electionis . 46)
                             (magnus-sanctus-paulus . 60)
                             (bonum-certamen . 63))
                  :psalms-3 ((saulus-qui-et-paulus . 74)
                             (ne-magnitudo-revelationum . 96)
                             (reposita-est-mihi . 98))
                  :versicle-1 ("In omnem terram exívit sonus eórum."
                               "Et in fines orbis terræ verba eórum.")
                  :versicle-1-en ("Their sound hath gone forth into all the earth."
                                  "And their words unto the ends of the world.")
                  :versicle-2 ("Constítues eos príncipes super omnem terram."
                               "Mémores erunt nóminis tui, Dómine.")
                  :versicle-2-en ("Thou shalt make them princes over all the earth."
                                  "They shall be mindful of thy name, O Lord.")
                  :versicle-3 ("Nimis honoráti sunt amíci tui, Deus."
                               "Nimis confortátus est principátus eórum.")
                  :versicle-3-en ("Thy friends, O God, are made exceedingly honourable."
                                  "Their principality is exceedingly strengthened.")

                  :lessons
                  (;; ── Nocturn I: Acts 9 (Conversion on the Damascus Road) ──

                   (:ref "Act 9:1-5"
                    :source "De Actibus Apostolórum"
                    :text "\
Saulus autem adhuc spirans minárum et cædis in discípulos Dómini, accéssit ad príncipem sacerdótum, \
et pétiit ab eo epístolas in Damáscum ad synagógas: ut si quos invenísset hujus viæ viros ac mulíeres, \
vinctos perdúceret in Jerúsalem. Et cum iter fáceret, cóntigit ut appropinquáret Damásco: et súbito \
circumfúlsit eum lux de cælo. Et cadens in terram audívit vocem dicéntem sibi: Saule, Saule, quid me \
perséqueris? Qui dixit: Quis es, dómine? Et ille: Ego sum Jesus, quem tu perséqueris: durum est tibi \
contra stímulum calcitráre.")

                   (:ref "Act 9:6-9"
                    :text "\
Et tremens ac stupens dixit: Dómine, quid me vis fácere? Et Dóminus ad eum: Surge, et ingrédere \
civitátem, et ibi dicétur tibi quid te opórteat fácere. Viri autem illi qui comitabántur cum eo, \
stabant stupefácti, audiéntes quidem vocem, néminem autem vidéntes. Surréxit autem Saulus de terra, \
apertísque óculis nihil vidébat. Ad manus autem illum trahéntes, introduxérunt Damáscum. Et erat ibi \
tribus diébus non videns, et non manducávit, neque bibit.")

                   (:ref "Act 9:10-16"
                    :text "\
Erat autem quidam discípulus Damásci, nómine Ananías: et dixit ad illum in visu Dóminus: Ananía. \
At ille ait: Ecce ego, Dómine. Et Dóminus ad eum: Surge, et vade in vicum qui vocátur Rectus: et \
quære in domo Judæ Saulum nómine Tarsénsem: ecce enim orat. Et vidit virum Ananíam nómine, introeúntem, \
et imponéntem sibi manus ut visum recípiat. Respóndit autem Ananías: Dómine, audívi a multis de viro \
hoc, quanta mala fécerit sanctis tuis in Jerúsalem: et hic habet potestátem a princípibus sacerdótum \
alligándi omnes qui ínvocant nomen tuum. Dixit autem ad eum Dóminus: Vade, quóniam vas electiónis est \
mihi iste, ut portet nomen meum coram géntibus, et régibus, et fíliis Israël. Ego enim osténdam illi \
quanta opórteat eum pro nómine meo pati.")

                   ;; ── Nocturn II: St. Augustine, Sermo 14 de Sanctis ──

                   (:ref "Hom."
                    :source "Sermo sancti Augustíni Epíscopi\nSermo 14 de Sanctis"
                    :text "\
Hódie de Actibus Apostolórum léctio hæc pronuntiáta est, ubi Paulus Apóstolus, ex persecutóre \
Christianórum, annuntiátor factus est Christi. Prostrávit enim Christus persecutórem, ut fáceret \
Ecclésiæ doctórem: percútiens eum, et sanans; occídens, et vivíficans: occísus agnus a lupis, et \
fáciens agnos de lupis. Ita enim in præclára prophetía cum Jacob Patriárcha benedíceret fíliis suis \
(præséntes tangens, futúra prospíciens) prædíctum erat quod in Paulo cóntigit. Erat autem Paulus, sicut \
ipse testátur, de tribu Bénjamin. Cum autem Jacob, benedícens fílios suos, venísset ad benedicéndum \
Bénjamin, ait de illo: Bénjamin lupus rapax.")

                   (:ref "Hom."
                    :text "\
Quid ergo? lupus rapax semper? Absit; sed qui mane rapit prædam, ad vésperam dívidit escas. Hoc in \
Apóstolo Paulo implétum est, quia et de illo dictum erat. Jam, si placet, audiámus illum mane rapiéntem, \
ad vésperam escas dividéntem. Mane et véspere pósita sunt pro eo, ac si dicerétur, prius et póstea. Sic \
ergo accipiámus: Prius rápiet, póstea dívidet escas. Atténdite raptórem: Saulus, inquit, accéptis \
epístolis a princípibus sacerdótum, ibat, ut ubicúmque inveníret Christiános, ad sacerdótes attráheret \
et addúceret, útique puniéndos.")

                   (:ref "Hom."
                    :text "\
Ibat spirans et anhélans cædes: hoc est, mane rápiens. Nam et quando lapidátus est Stéphanus primus \
Martyr pro nómine Christi, evidéntius áderat et Saulus; et sic áderat lapidántibus, ut non ei suffíceret, \
si tantum suis mánibus lapidáret. Ut enim esset in ómnium lapidántium mánibus, ipse ómnium vestiménta \
servábat; magis sǽviens omnes adjuvándo, quam suis mánibus lapidándo. Audívimus, mane rápiet: videámus \
ad vésperam quáliter dívidat escas. Voce Christi prostrátus de cælo, et accípiens désuper interdíctum \
jam sæviéndi, cécidit in fáciem suam, prius prosternéndus, póstea erigéndus; prius percutiéndus, \
póstea sanándus.")

                   ;; ── Nocturn III: C1 in 2 loco — Bede on Matt 19:27-29 ──

                   (:ref "Matt 19:27-29"
                    :source "Homilía sancti Bedæ Venerábilis Presbýteri\nHomilia in Natali S. Benedicti Ep."
                    :text "\
Perféctus ille est, qui ábiens vendit ómnia quæ habet, et dat paupéribus, ac véniens séquitur Christum; \
habébit enim thesáurum non deficiéntem in cælis. Unde bene, interrogánte Petro, dixit tálibus Jesus: \
Amen dico vobis, quod vos qui secúti estis me, in regeneratióne, cum séderit Fílius hóminis in sede \
majestátis suæ, sedébitis et vos super sedes duódecim, judicántes duódecim tribus Israël. In hac \
quippe vita pro ejus nómine laborántes, in ália prǽmium speráre dócuit, id est, in regeneratióne; cum \
vidélicet in vitam immortálem fuérimus resurgéndo regeneráti, qui in vitam cadúcam mortáliter erámus \
géniti.")

                   (:ref "Matt 19:27-29"
                    :text "\
Et justa prorsus retribútio, ut, qui hic pro Christo humánæ glóriam celsitúdinis neglexérunt, illic a \
Christo júdices glorificáti singuláriter cum eo assídeant qui a sequéndis ejus vestígiis nulla ratióne \
póterant avélli. Nemo autem putet duódecim tantum Apóstolos, quia pro Juda prævaricánte Matthías eléctus \
est, tunc esse judicatúros; sicut nec duódecim solæ sunt tribus Israël judicándæ: alióquin tribus Levi, \
quæ tertiadécima est, injudicáta recédet.")

                   (:ref "Matt 19:27-29"
                    :text "\
Et Paulus, qui tertiusdécimus est Apóstolus, judicándi sorte privábitur? cum ipse dicat: Nescítis \
quóniam ángelos judicábimus, quanto magis sæculária? Sciéndum namque est, omnes, qui ad exémplum \
Apostolórum, sua reliquérunt ómnia et secúti sunt Christum, júdices cum eo ventúros, sicut étiam omne \
mortálium genus esse judicándum. Quia enim duodenário sæpe número solet in Scriptúris univérsitas \
designári, per duódecim sedes Apostolórum ómnium numerósitas judicántium, et, per duódecim tribus \
Israël, univérsitas eórum qui judicándi sunt, osténditur."))

                  :responsories
                  (;; Inherited from Jun 30 (Commemoratio S. Pauli)
                   (:respond "Qui operátus est Petro in apostolátum, operátus est et mihi inter gentes:"
                    :verse "Grátia Dei in me vácua non fuit, sed grátia ejus semper in me manet."
                    :repeat "Et cognovérunt grátiam Dei, quæ data est mihi.")
                   (:respond "Bonum certámen certávi, cursum consummávi, fidem servávi:"
                    :verse "Scio cui crédidi, et certus sum quia potens est depósitum meum serváre in illum diem."
                    :repeat "Ideóque repósita est mihi coróna justítiæ.")
                   (:respond "Repósita est mihi coróna justítiæ,"
                    :verse "Scio cui crédidi, et certus sum quia potens est depósitum meum serváre in illum diem."
                    :repeat "Quam reddet mihi Dóminus in illum diem justus judex."
                    :gloria t)
                   (:respond "Tu es vas electiónis, sancte Paule Apóstole, prædicator veritátis in univérso mundo,"
                    :verse "Intercéde pro nobis ad Deum, qui te elégit."
                    :repeat "Per quem omnes gentes cognovérunt grátiam Dei.")
                   (:respond "Grátia Dei sum id quod sum:"
                    :verse "Qui operátus est Petro in apostolátum, operátus est et mihi inter gentes."
                    :repeat "Et grátia ejus in me vacua non fuit, sed semper in me manet.")
                   (:respond "Saulus, qui et Paulus, magnus prædicátor,"
                    :verse "Osténdens quia hic est Christus, Fílius Dei."
                    :repeat "A Deo confortátus convalescébat, et confundébat Judæos."
                    :gloria t)
                   (:respond "Sancte Paule Apóstole, prædicátor veritátis et doctor géntium,"
                    :verse "Tu es vas electiónis, sancte Paule Apostole, prædicátor veritátis."
                    :repeat "Intercéde pro nobis ad Deum, qui te elégit, ut digni efficiámur grátia Dei.")
                   (:respond "Damasci, præpósitus gentis Aretæ regis vóluit me comprehéndere:"
                    :verse "Deus et Pater Dómini nostri Jesu Christi scit quia non mentior."
                    :repeat "Et a frátribus per murum demíssus sum in sporta, et sic evasi manus ejus in nómine Dómini."
                    :gloria t))))

    ((1 . 26) . (:name "St. Polycarp, Bp.M."
                  :latin "S. Polycarpi Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0126))

    ((1 . 27) . (:name "St. John Chrysostom, Bishop, C., and Doctor of the Church"
                  :latin "S. Joannis Chrysostomi Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect ecclesiam-tuam-quaesumus-domine-gratia))

    ((1 . 28) . (:name "St. Peter Nolasco, C."
                  :latin "S. Petri Nolasci Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-in-tuae-caritatis))

    ((1 . 29) . (:name "St. Francis de Sales, Bishop, C., and Doctor of the Church"
                  :latin "S. Francisci Salesii Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-ad-animarum-salutem))

    ((1 . 30) . (:name "St. Martina, V.M."
                  :latin "S. Martinæ Virginis et Martyris"
                  :rank semiduplex
                  :commune C6
                  :collect deus-qui-inter-cetera-potentiae))

    ((1 . 31) . (:name "St. John Bosco, C."
                  :latin "S. Joannis Bosco Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-sanctum-joannem-confessorem))

    ;; ── FEBRUARY ───────────────────────────────────────────────

    ((2 . 1) . (:name "St. Ignatius, Bp.M."
                  :latin "S. Ignatii Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0201))

    ((2 . 2) . (:name "Purification of the Blessed Virgin Mary"
                  :latin "In Purificatione Beatæ Mariæ Virginis"
                  :rank duplex-ii
                  :commune C11
                  :collect omnipotens-sempiterne-deus-majestatem-tuam))

    ((2 . 3) . (:name "St. Blase, Bp.M."
                  :latin "S. Blasii Episcopi et Martyris"
                  :rank simplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0203))

    ((2 . 4) . (:name "St. Andrew Corsini, Bp.C."
                  :latin "S. Andreæ Corsini Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-in-ecclesia-tua))

    ((2 . 5) . (:name "St. Agatha, V.M."
                  :latin "S. Agathæ Virginis et Martyris"
                  :rank duplex
                  :commune C6
                  :collect deus-qui-inter-cetera-potentiae-0205))

    ((2 . 6) . (:name "St. Titus, Bp.C."
                  :latin "S. Titi Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-beatum-titum-confessorem))

    ((2 . 7) . (:name "St. Romuald, Ab."
                  :latin "S. Romualdi Abbatis"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-romualdi))

    ((2 . 8) . (:name "St. John of Matha, C."
                  :latin "S. Joannis de Matha Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-per-sanctum-joannem))

    ((2 . 9) . (:name "St. Cyril of Alexandria, Bishop, C., and Doctor of the Church"
                  :latin "S. Cyrilli Episc. Alexandrini Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-beatum-cyrillum-confessorem))

    ((2 . 10) . (:name "St. Scholastica, V."
                  :latin "S. Scholasticæ Virginis"
                  :rank duplex
                  :commune C6
                  :collect deus-qui-animam-beatae-virginis))

    ((2 . 11) . (:name "The Apparition of the Blessed Virgin Mary at Lourdes"
                  :latin "In Apparitione Beatæ Mariæ Virginis Immaculatæ"
                  :rank duplex-majus
                  :commune C11
                  :collect deus-qui-per-immaculatam-virginis))

    ((2 . 12) . (:name "Seven Holy Founders of the Order of the Servants of the Blessed Virgin Mary"
                  :latin "Ss. Septem Fundatorum Ordinis Servorum B. M. V."
                  :rank duplex
                  :commune C5
                  :collect domine-jesu-christe-qui-ad))

    ((2 . 14) . (:name "St. Valentine, Pr.M."
                  :latin "S. Valentini Presbyteri et Martyris"
                  :rank simplex
                  :commune C2a
                  :collect praesta-quaesumus-omnipotens-deus-ut))

    ((2 . 15) . (:name "Sts. Faustinus and Jovita, M.s"
                  :latin "SS. Faustini et Jovitæ"
                  :rank simplex
                  :commune C3
                  :collect beatorum-martyrum-pariterque-pontificum-faustini))

    ((2 . 18) . (:name "St. Simeon, Bp.M."
                  :latin "S. Simeonis Episcopi et Martyris"
                  :rank simplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0218))

    ((2 . 22) . (:name "Chair of St. Peter at Antioch"
                  :latin "In Cathedra S. Petri Apostoli Antiochiæ"
                  :rank duplex-majus
                  :commune C4
                  :collect deus-qui-beato-petro-apostolo))

    ((2 . 24) . (:name "St. Matthias the Apostle"
                  :latin "S. Matthiæ Apostoli"
                  :rank duplex-ii
                  :commune C1
                  :collect deus-qui-beatum-matthiam-apostolorum))

    ((2 . 27) . (:name "St. Gabriel of the Sorrowful Virgin, C."
                  :latin "S. Gabrielis a Virgine Perdolente Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-gabrielem-dulcissimae))

    ;; ── MARCH ──────────────────────────────────────────────────

    ((3 . 4) . (:name "St. Casimir, C."
                  :latin "S. Casimiri Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect deus-qui-inter-regales-delicias))

    ((3 . 6) . (:name "Sts. Perpetua and Felicity, M.s"
                  :latin "Ss. Perpetuæ et Felicitatis Martyrum"
                  :rank duplex
                  :commune C7
                  :collect deus-qui-inter-cetera-potentiae-0306))

    ((3 . 7) . (:name "St. Thomas Aquinas, C.D."
                  :latin "S. Thomæ de Aquino Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ecclesiam-tuam-beati))

    ((3 . 8) . (:name "St. John of God, C."
                  :latin "S. Joannis de Deo Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-joannem-tuo))

    ((3 . 9) . (:name "St. Frances of Rome, W."
                  :latin "S. Franciscæ Romanæ Viduæ"
                  :rank duplex
                  :commune C7
                  :collect deus-qui-beatam-franciscam-famulam))

    ((3 . 10) . (:name "Forty Holy Martyrs"
                  :latin "Ss. Quadraginta Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect praesta-quaesumus-omnipotens-deus-ut))

    ((3 . 12) . (:name "S. Gregory the Great, Pope, C.D."
                  :latin "S. Gregorii Papæ Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-animae-famuli-tui))

    ((3 . 17) . (:name "St. Patrick, Bp.C."
                  :latin "S. Patricii Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-ad-praedicandam-gentibus))

    ((3 . 18) . (:name "St. Cyril of Jerusalem, C.D."
                  :latin "S. Cyrilli Episcopi Hierosolymitani Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-nobis-quaesumus-omnipotens-deus))

    ((3 . 19) . (:name "St. Joseph, Spouse of the Blessed Virgin Mary, C."
                  :latin "S. Joseph Sponsi B.M.V. Confessoris"
                  :rank duplex-i
                  :commune nil
                  :collect sanctissimae-genetricis-tuae-sponsi-quaesumus

                  ;; ── Matins ──
                  ;; Proper office. Noc I: Genesis (Patriarch Joseph).
                  ;; Noc II: St. Bernard. Noc III: St. Jerome on Matt 1:18-21.
                  :invitatory christum-dei-filium-putari
                  :hymn caelitum-joseph-decus
                  :psalms-1 ((ascendit-joseph-a-galilaea . 1)
                             (venerunt-pastores . 2)
                             (ecce-angelus-domini-apparuit-joseph . 3))
                  :psalms-2 ((consurgens-joseph . 4)
                             (defuncto-herode . 5)
                             (accepit-joseph-puerum . 8))
                  :psalms-3 ((audiens-joseph . 14)
                             (admonitus-in-somnis . 20)
                             (erat-pater-jesu . 23))
                  :versicle-1 ("Constítuit eum dóminum domus suæ."
                               "Et príncipem omnis possessiónis suæ.")
                  :versicle-1-en ("He made him lord of his house."
                                  "And ruler of all his possessions.")
                  :versicle-2 ("Magna est glória ejus in salutári tuo."
                               "Glóriam et magnum decórem impónes super eum.")
                  :versicle-2-en ("Great is his glory in thy salvation."
                                  "Glory and great beauty shalt thou lay upon him.")
                  :versicle-3 ("Justus germinábit sicut lílium."
                               "Et florébit in ætérnum ante Dóminum.")
                  :versicle-3-en ("The just shall spring as a lily."
                                  "And shall flourish for ever before the Lord.")

                  :lessons
                  (;; ── Nocturn I: Genesis (Patriarch Joseph as type) ──

                   (:ref "Gen 39:1-5"
                    :source "De libro Génesis"
                    :text "\
Joseph ígitur ductus est in Ægýptum, emítque eum Putíphar eunúchus Pharaónis, princeps exércitus, vir \
Ægýptius, de manu Ismaelitárum, a quibus perdúctus erat. Fuítque Dóminus cum eo, et erat vir in cunctis \
próspere agens: habitavítque in domo dómini sui, qui óptime nóverat Dóminum esse cum eo, et ómnia, quæ \
gerébat, ab eo dírigi in manu illíus. Invenítque Joseph grátiam coram dómino suo, et ministrábat ei: a \
quo præpósitus ómnibus gubernábat créditam sibi domum, et univérsa quæ ei trádita fúerant: \
benedixítque Dóminus dómui Ægýptii propter Joseph.")

                   (:ref "Gen 41:37-40"
                    :text "\
Plácuit Pharaóni consílium et cunctis minístris ejus: locutúsque est ad eos: Num inveníre potérimus \
talem virum, qui spíritu Dei plenus sit? Dixit ergo ad Joseph: Quia osténdit tibi Deus ómnia quæ locútus \
es, numquid sapientiórem et consímilem tui inveníre pótero? Tu eris super domum meam, et ad tui oris \
impérium cunctus pópulus obédiet: uno tantum regni sólio te præcédam.")

                   (:ref "Gen 41:41-44"
                    :text "\
Dixítque rursus Phárao ad Joseph: Ecce, constítui te super univérsam terram Ægýpti. Tulítque ánnulum \
de manu sua, et dedit eum in manu ejus: vestivítque eum stola býssina, et collo torquem áuream \
circumpósuit. Fecítque eum ascéndere super currum suum secúndum, clamánte præcóne, ut omnes coram eo \
genu flécterent, et præpósitum esse scirent univérsæ terræ Ægýpti. Dixit quoque rex ad Joseph: Ego sum \
Phárao: absque tuo império non movébit quisquam manum aut pedem in omni terra Ægýpti.")

                   ;; ── Nocturn II: St. Bernard, Hom. 2 super Missus est ──

                   (:ref "Hom."
                    :source "Sermo sancti Bernárdi Abbátis\nHomil. 2 super Missus est, prope finem"
                    :text "\
Quis et qualis homo fúerit beátus Joseph, cónice ex appellatióne, qua, licet dispensatória, méruit \
honorári ádeo, ut pater Dei et dictus et créditus sit; cónice et ex próprio vocábulo, quod augméntum \
non dúbitas interpretári. Simul et meménto magni illíus quondam Patriárchæ vénditi in Ægýpto; et scito \
ipsíus istum non solum vocábulum fuísse sortítum, sed et castimóniam adéptum, innocéntiam assecútum \
et grátiam.")

                   (:ref "Hom."
                    :text "\
Síquidem ille Joseph, fratérna ex invídia vénditus et ductus in Ægýptum, Christi venditiónem \
præfigurávit: iste Joseph, Herodiánam invídiam fúgiens, Christum in Ægýptum portávit. Ille dómino suo \
fidem servans, dóminæ nóluit commiscéri: iste Dóminam suam, Dómini sui matrem, vírginem agnóscens et \
ipse cóntinens, fidéliter custodívit. Illi data est intellegéntia in mystériis somniórum: isti datum \
est cónscium fíeri atque partícipem cæléstium sacramentórum.")

                   (:ref "Hom."
                    :text "\
Ille fruménta servávit non sibi, sed omni pópulo: iste Panem vivum e cælo servándum accépit tam sibi \
quam toti mundo. Non est dúbium, quin bonus et fidélis homo fúerit iste Joseph, cui Mater desponsáta \
est Salvatóris. Fidélis, inquam, servus, et prudens, quem constítuit Dóminus suæ Matris solátium, suæ \
carnis nutrítium, solum dénique in terris magni consílii coadjutórem fidelíssimum.")

                   ;; ── Nocturn III: St. Jerome on Matt 1:18-21 (from 12-24) ──

                   (:ref "Matt 1:18-21"
                    :source "Homilía sancti Hierónymi Presbýteri\nLib. 1 Comment. in c. 1 Matth."
                    :text "\
Quare non de símplici vírgine, sed de desponsáta concípitur? Primum, ut per generatiónem Joseph, orígo \
Maríæ monstrarétur: secúndo, ne lapidarétur a Judǽis ut adúltera: tértio, ut in Ægýptum fúgiens \
habéret solátium. Martyr Ignátius étiam quartam áddidit causam, cur a desponsáta concéptus sit: Ut \
partus, ínquiens, ejus celarétur diábolo, dum eum putat non de vírgine, sed de uxóre generátum.")

                   (:ref "Matt 1:18-21"
                    :text "\
Antequam convenírent, invénta est in útero habens de Spíritu Sancto. Non ab álio invénta est, nisi a \
Joseph, qui pene licéntia maritáli futúræ uxóris ómnia nóverat. Quod autem dícitur, Antequam \
convenírent, non séquitur ut póstea convénerint: sed Scriptúra quod factum non sit, osténdit.")

                   (:ref "Matt 1:18-21"
                    :text "\
Joseph autem vir ejus, cum esset justus, et nollet eam tradúcere, vóluit occúlte dimíttere eam. Si \
quis fornicáriæ conjúngitur, unum corpus effícitur, et in lege præcéptum est, non solum reos, sed et \
cónscios críminum obnóxios esse peccáti: quómodo Joseph, cum crimen celáret uxóris, justus scríbitur? \
Sed hoc testimónium Maríæ est, quod Joseph sciens illíus castitátem, et admírans quod evénerat, celat \
siléntio, cujus mystérium nesciébat."))

                  :responsories
                  ((:respond "Fuit Dóminus cum Joseph, et dedit ei grátiam in conspéctu príncipis cárceris:"
                    :verse "Quidquid fiébat, sub ipso erat: Dóminus enim erat cum illo, et ómnia ópera ejus dirigébat."
                    :repeat "Qui trádidit in manu illíus univérsos vinctos.")
                   (:respond "Esuriénte terra Ægýpti, clamávit pópulus ad regem, aliménta petens. Quibus ille respóndit:"
                    :verse "Crescébat cotídie fames in omni terra, aperuítque Joseph univérsa hórrea, et vendébat Ægýptiis."
                    :repeat "Ite ad Joseph, et quidquid vobis díxerit, fácite.")
                   (:respond "Fecit me Dóminus quasi patrem regis, et dóminum univérsæ domus ejus: nolíte pavére;"
                    :verse "Veníte ad me, et ego dabo vobis ómnia bona Ægýpti, et comedétis medúllam terræ."
                    :repeat "Pro salúte enim vestra misit me Deus ante vos in Ægýptum."
                    :gloria t)
                   (:respond "Ascéndit Joseph a Galilǽa de civitáte Názareth in Judǽam, in civitátem David, quæ vocátur Béthlehem:"
                    :verse "Ut profiterétur cum María desponsáta sibi uxóre."
                    :repeat "Eo quod esset de domo et família David.")
                   (:respond "Surge, et áccipe Púerum et Matrem ejus, et fuge in Ægýptum;"
                    :verse "Ut adimplerétur quod dictum est a Dómino per prophétam dicéntem: Ex Ægýpto vocávi Fílium meum."
                    :repeat "Et esto ibi, usque dum dicam tibi.")
                   (:respond "Cum indúcerent púerum Jesum paréntes ejus, ut fácerent secúndum consuetúdinem legis pro eo,"
                    :verse "Et erat Pater ejus et Mater mirántes super his, quæ dicebántur de illo."
                    :repeat "Accépit eum Símeon in ulnas suas, et benedíxit Deum."
                    :gloria t)
                   (:respond "Dicit Mater Jesu ad illum: Fili, quid fecísti nobis sic?"
                    :verse "Et ait ad illos: Quid est, quod me quærebátis? nesciebátis, quia in his quæ Patris mei sunt, opórtet me esse?"
                    :repeat "Ecce pater tuus et ego doléntes quærebámus te.")
                   (:respond "Descéndit Jesus cum eis, et venit Názareth:"
                    :verse "Proficiébat sapiéntia, et ætáte, et grátia apud Deum et hómines."
                    :repeat "Et erat súbditus illis."
                    :gloria t))))

    ((3 . 21) . (:name "St. Benedict, Ab."
                  :latin "S. Benedicti Abbatis"
                  :rank duplex-majus
                  :commune C5
                  :collect deus-qui-nos-beati-benedicti))

    ((3 . 24) . (:name "St. Gabriel the Archangel"
                  :latin "S. Gabrielis Archangeli"
                  :rank duplex-majus
                  :commune nil
                  :collect deus-qui-inter-ceteros-angelos

                  ;; ── Matins ──
                  ;; ex Sancti/05-08 base; own antiphons, hymn, lessons, responsories.
                  ;; Invitatory inherited from May 8.
                  :invitatory regem-archangelorum-dominum
                  :hymn christe-sanctorum-gabriel
                  :psalms-1 ((dixit-angelus-gabriel-danieli . 8)
                             (ecce-vir-gabriel . 10)
                             (cumque-gabriel-loqueretur . 14))
                  :psalms-2 ((gabriel-angelus-apparuit-zachariae . 18)
                             (et-dixit-zacharias . 23)
                             (respondens-autem-angelus-gabriel . 33))
                  :psalms-3 ((missus-est-gabriel-angelus . 95)
                             (gabriel-angelus-mariae-dixit . 96)
                             (suscipe-verbum-virgo-maria . 102))
                  :versicle-1 ("Stetit Angelus juxta aram templi."
                               "Habens thuríbulum áureum in manu sua.")
                  :versicle-1-en ("An Angel stood by the altar of the temple."
                                  "Having a golden censer in his hand.")
                  :versicle-2 ("Ascéndit fumus arómatum in conspéctu Dómini."
                               "De manu Angeli.")
                  :versicle-2-en ("The smoke of incense ascended before the Lord."
                                  "From the hand of the Angel.")
                  :versicle-3 ("In conspéctu Angelórum psallam tibi, Deus meus."
                               "Adorábo ad templum sanctum tuum, et confitébor nómini tuo.")
                  :versicle-3-en ("In the sight of the Angels I will sing unto thee, O my God."
                                  "I will worship toward thy holy temple, and give thanks unto thy name.")

                  :lessons
                  (;; ── Nocturn I: Daniel 9 (Seventy Weeks prophecy) ──

                   (:ref "Dan 9:20-23"
                    :source "De Daniéle Prophéta"
                    :text "\
Ego Dániel, cum adhuc lóquerer, et orárem, et confitérer peccáta mea, et peccáta pópuli mei Israël, et \
prostérnerem preces meas in conspéctu Dei mei, pro monte sancto Dei mei: Adhuc me loquénte in oratióne, \
ecce vir Gábriel, quem víderam in visióne a princípio, cito volans tétigit me in témpore sacrifícii \
vespertíni, et dócuit me, et locútus est mihi, dixítque: Dániel, nunc egréssus sum ut docérem te, et \
intellígeres: ab exórdio precum tuárum egréssus est sermo; ego autem veni ut indicárem tibi, quia vir \
desideriórum es; tu ergo animadvérte sermónem, et intéllige visiónem.")

                   (:ref "Dan 9:24-25"
                    :text "\
Septuagínta hebdómades abbreviátæ sunt super pópulum tuum et super urbem sanctam tuam, ut consummétur \
prævaricátio, et finem accípiat peccátum, et deleátur iníquitas, et adducátur justítia sempitérna, et \
impleátur vísio et prophetía, et ungátur Sanctus sanctórum. Scito ergo, et animadvérte: Ab éxitu \
sermónis, ut íterum ædificétur Jerúsalem, usque ad Christum ducem, hebdómades septem et hebdómades \
sexagínta duæ erunt: et rursum ædificábitur platéa, et muri in angústia témporum.")

                   (:ref "Dan 9:26-27"
                    :text "\
Et post hebdómades sexagínta duas occidétur Christus, et non erit ejus pópulus qui eum negatúrus est; \
et civitátem et sanctuárium dissipábit pópulus cum duce ventúro: et finis ejus vástitas, et post finem \
belli statúta desolátio. Confirmábit autem pactum multis hebdómada una: et in dimídio hebdómadis \
defíciet hóstia et sacrifícium, et erit in templo abominátio desolatiónis: et usque ad consummatiónem \
et finem perseverábit desolátio.")

                   ;; ── Nocturn II: Bede on Luke 1:11-20 ──

                   (:ref "Luc 1:11-20"
                    :source "Sermo sancti Bedæ venerábilis Presbýteri\nExpositio in Luc. 1, 11-20."
                    :text "\
Appáruit Zacharíæ Angelus, stans a dextris altáris incénsi. Bene Angelus et in templo, et juxta altáre, \
et dextris appáret; quia vidélicet et veri sacerdótis advéntum, et mystérium sacrifícii universális, et \
cæléstis doni gáudium prǽdicat. Nam, sicut per sinístram præséntia, sic per déxteram sæpe bona \
prænuntiántur ætérna. Juxta quod in sapiéntiæ laude cánitur: Longitúdo diérum in déxtera ejus; in \
sinístra illíus divítiæ et glória. Treméntem Zacharíam confórtet Angelus, quia, sicut humánæ \
fragilitátis est spiritális creatúræ visióne turbári, ita et angélicas benignitátis est pavéntes de \
aspéctu suo mortáles mox blandiéndo solári. At contra dæmónicæ est ferocitátis, quos sui præséntia \
térritos sénserit, amplióri semper horróre concútere, qua nulla mélius ratióne quam fide superátur \
intrépida.")

                   (:ref "Luc 1:11-20"
                    :text "\
Angelus, deprecatiónem dicens exaudítam, partum contínuo promíttit uxóris. Non quod ille, qui pro \
pópulo oblatúrus intráverat, relíctis públicis votis, pro accipiéndis fíliis oráre potúerit, præsértim \
quia nemo orat quod se acceptúrum despérat. Adeo autem ille, jam suæ ætátis et infœcúndæ cónjugis \
memor, nasci sibi fílios desperábat, ut nec Angelo hoc promitténti créderet. Sed quod dicit: Exaudíta \
est deprecátio tua, pro pópuli redemptióne signíficat; Et uxor tua páriet tibi fílium, ejúsdem \
redemptiónis órdinem pandit, quod vidélicet natus Zacharíæ fílius Redemptóri illíus pópuli præconándo \
sit iter factúrus.")

                   (:ref "Luc 1:11-20"
                    :text "\
Zacharías ob altitúdinem promissórum hǽsitans, signum quo crédere váleat, inquírit cui sola Angeli \
vísio vel allocútio pro signo suffícere debúerat. Unde méritam diffidéntiæ tacéndo pœnam luit, cui \
tacitúrnitas eádem et signum fídei quod quæsívit, et infidelitátis esset pœna quem méruit. Vult \
intélligi quod si homo tália promítteret, impúne signum flagitáre licéret, at cum ángelus promíttat, \
jam dubitári non déceat. Datque signum quod rogátur, ut qui discredéndo locútus est, jam tacéndo crédere \
discat. Ubi notándo quod Angelus se et ante Deum adstáre, et ad evangelizándum Zacharíæ missum esse \
testátur; quia et cum ad nos véniunt Angeli, sic extérius implent ministérium, ut tamen nunquam desint \
intérius per contemplatiónem.")

                   ;; ── Nocturn III: St. Bernard on Luke 1:26-38 ──

                   (:ref "Luc 1:26-38"
                    :source "Homilía Sancti Bernárdi Abbátis\nHomilia 1 supra Missus est n. 2"
                    :text "\
Non árbitror hunc ángelum de minóribus esse, qui quálibet ex causa crebra sóleant ad terras fungi \
legatióne. Quod ex ejus nómine palam intélligi dícitur, quod interpretátio Fortitúdo Dei dícitur; et \
quia non ab álio áliquo forte excellentióre se (ut ássolet) spíritu, sed ab ipso Deo mitti perhibétur. \
Propter hoc ergo pósitum est, A Deo. Vel ídeo dictum est, A Deo, ne cui, vel beatórum spirítuum suum \
Deus, ántequam Vírgini, revelásse putétur consílium, excépto dumtáxat Archángelo Gabriéle; qui útique \
tantæ inter suos inveníri potúerit excelléntiæ, ut tali et nómine dignus haberétur et núntio.")

                   (:ref "Luc 1:26-38"
                    :text "\
Nec discórdat nomen a núntio. Dei quippe virtútem Christum quem mélius nuntiáre decébat quam hunc, \
quem símile nomen honórat? Nam quid est áliud fortitúdo, quam virtus? Non autem dedécens aut incóngruum \
videátur, Dóminum et núntium commúni censéri vocábulo; cum símilis in utróque appellatiónis, non sit \
tamen utriúsque símilis causa. Aliter quippe Christus fortitúdo vel virtus Dei dícitur, áliter Angelus; \
Angelus enim tantum nuncupatíve, Christus autem étiam substantíve.")

                   (:ref "Luc 1:26-38"
                    :text "\
Christus Dei virtus et dícitur et est, qui forti armáto, qui suum átrium in pace custodíre solébat, \
fórtior supervéniens, ipsum suo bráchio debellávit: et sic ei vasa captivitátis poténter erípuit. \
Angelus vero fortitúdo Dei appellátus est, vel quod hujúsmodi merúerit, prærogatívam offícii, quo \
ejúsdem nuntiáret advéntum virtútis: vel quia vírginem natúra pávidam, símplicem, verecúndam, de \
miráculi novitáte ne expavésceret, confortáre debéret; quod et fecit, Ne tímeas, ínquiens, María, \
invenísti enim grátiam apud Deum. Conveniénter ítaque Gábriel ad hoc opus elígitur, immo quia tale \
illi negótium injúngitur, recte tali nómine designátur."))

                  :responsories
                  ((:respond "Cum oráret Dániel et confiterétur peccáta sua, et peccáta pópuli sui:"
                    :verse "Cumque prostérneret preces suas in conspéctu Dei sui,"
                    :repeat "Ecce Archángelus Gábriel cito volans tétigit eum in témpore sacrifícii vespertíni.")
                   (:respond "Locútus est Gábriel Daniéli et dixit: Ab exórdio precum tuárum egréssus est sermo."
                    :verse "Tu autem animadvérte sermónem, et intéllige visiónem."
                    :repeat "Ego autem veni ut indicárem tibi, quia vir desideriórum es.")
                   (:respond "Ecce vir Gábriel quem víderam in visióne a princípio cito volans tétigit me in témpore sacrifícii vespertíni et dócuit me et locútus est mihi dixítque"
                    :verse "Gábriel fac me intellígere istam visiónem: et venit et stetit juxta ubi ego stabam, et ait ad me:"
                    :repeat "Dániel nunc egréssus sum ut docérem te et intellígeres"
                    :gloria t)
                   (:respond "Factum est, cum sacerdótio fungerétur Zacharías in órdine vicis sufflánte Deum,"
                    :verse "Cumque, ingréssus in templum Dómini, incénsum póneret secúndum consuetúdinem sacerdótii sui."
                    :repeat "Appáruit ei Angelus Gábriel, stans a dextris altáris incénsi.")
                   (:respond "Descéndit Gábriel Angelus ad Zacharíam dicens:"
                    :verse "Et Zacharías turbátus est videns, et timor írruit super eum: ait autem ad illum Angelus:"
                    :repeat "Ne tímeas quóniam exaudíta est deprecátio tua, et uxor tua Elísabeth paret tibi fílium, et vocábis nomen ejus Joánnem.")
                   (:respond "Ego sum Gábriel Angelus, qui asto ante Dóminum; et missus sum loqui te, et hæc evangelizáre:"
                    :verse "Pro eo quod non credidísti verbis meis, quæ implebúntur témpore suo,"
                    :repeat "Ecce eris tacens, et non póteris loqui usque in diem quo hæc fiant."
                    :gloria t)
                   (:respond "Missus est Gábriel Angelus ad Maríam Vírginem desponsátam Joseph, núntians ei verbum: et expavéscit Virgo de lúmine."
                    :verse "Quæ cum audísset turbáta est in sermóne ejus, et cogitábat qualis esset ista salutátio; et ait Angelus ei."
                    :repeat "Ne tímeas, María, invenísti enim grátiam apud Dóminum: ecce concípies, et páries, et vocábitur Altíssimi Fílius.")
                   (:respond "Gaude, María Virgo cunctas hǽreses sola interemísti:"
                    :verse "Benedícta tu in muliéribus, et benedíctus fructus ventris tui."
                    :repeat "Quæ Gabriéli Archángeli dictis credidísti, dum Virgo Deum et hóminem genuísti, et post partum, Virgo, invioláta permansísti."
                    :gloria t))))

    ((3 . 25) . (:name "Annunciation of the Blessed Virgin Mary"
                  :latin "In Annuntiatione Beatæ Mariæ Virginis"
                  :rank duplex-i
                  :commune C11
                  :collect deus-qui-de-beatae-mariae))

    ((3 . 27) . (:name "St. John Damascene, C."
                  :latin "S. Joannis Damasceni Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C5
                  :collect omnipotens-sempiterne-deus-qui-ad))

    ((3 . 28) . (:name "St. John of Capistrano, C."
                  :latin "S. Joannis a Capistrano Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect deus-qui-per-beatum-joannem))

    ;; ── APRIL ──────────────────────────────────────────────────

    ((4 . 2) . (:name "St. Francis of Paula, C."
                  :latin "S. Francisci de Paula Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-humilium-celsitudo-qui-beatum))

    ((4 . 4) . (:name "S. Isidore of Seville, Bishop, C.D."
                  :latin "S. Isidori Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0404))

    ((4 . 5) . (:name "St. Vincent Ferrer, C."
                  :latin "S. Vincentii Ferrerii Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ecclesiam-tuam-beati-0405))

    ((4 . 11) . (:name "St. Leo the Great, Pope, C.D."
                  :latin "S. Leonis I Papæ Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0411))

    ((4 . 13) . (:name "St. Hermenegild, M."
                  :latin "S. Hermenegildi Martyris"
                  :rank semiduplex
                  :commune C2a
                  :collect deus-qui-beatum-hermenegildum-martyrem))

    ((4 . 14) . (:name "St. Justini Martyr"
                  :latin "S. Justini Martyris"
                  :rank duplex
                  :commune C2a
                  :collect deus-qui-per-stultitiam-crucis))

    ((4 . 17) . (:name "St. Anicetus, P.M."
                  :latin "S. Aniceti Papæ et Martyris"
                  :rank simplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0417))

    ((4 . 21) . (:name "St. Anselm, Bishop, C.D."
                  :latin "S. Anselmi Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0421))

    ((4 . 22) . (:name "Sts. Soter and Caius, Popes and Martyrs"
                  :latin "SS. Soteris et Caji Summorum Pontificum et Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect exaudi-quaesumus-domine-preces-nostras))

    ((4 . 23) . (:name "St. George, M."
                  :latin "S. Georgii Martyris"
                  :rank semiduplex
                  :commune C2a
                  :collect deus-qui-nos-beati-georgii))

    ((4 . 24) . (:name "St. Fidelis of Sigmaringen, M."
                  :latin "S. Fidelis de Sigmaringa Martyris"
                  :rank duplex
                  :commune C2a
                  :collect deus-qui-beatum-fidelem-seraphico))

    ((4 . 25) . (:name "St. Mark the Evangelist"
                  :latin "S. Marci Evangelistæ"
                  :rank duplex-ii
                  :commune C1
                  :collect deus-qui-beatum-marcum-evangelistam))

    ((4 . 26) . (:name "Sts. Cletus and Marcellinus, Popes and Martyrs"
                  :latin "SS. Cleti et Marcellini Summorum Pontificum et Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect deus-qui-inter-cetera-potentiae-0426))

    ((4 . 27) . (:name "St. Peter Canisius, C.D."
                  :latin "S. Petri Canisii Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ad-tuendam-catholicam))

    ((4 . 28) . (:name "St. Paul of the Cross, C."
                  :latin "S. Pauli a Cruce Confessoris"
                  :rank duplex
                  :commune C5
                  :collect domine-jesu-christe-qui-ad-0428))

    ((4 . 29) . (:name "St. Peter the Martyr"
                  :latin "S. Petri Martyris"
                  :rank duplex
                  :commune C2a
                  :collect praesta-quaesumus-omnipotens-deus-ut-0429))

    ((4 . 30) . (:name "St. Catherine of Siena, V."
                  :latin "S. Catharinæ Senensis Virginis"
                  :rank duplex
                  :commune C6
                  :collect da-quaesumus-omnipotens-deus-ut))

    ;; ── MAY ────────────────────────────────────────────────────

    ((5 . 1) . (:name "Sts. Philip and James, Apostles"
                  :latin "Ss. Philippi et Jacobi Apostolorum"
                  :rank duplex-ii
                  :commune C1
                  :collect deus-qui-nos-annua-apostolorum))

    ((5 . 2) . (:name "S. Athanasius, C.D."
                  :latin "S. Athanasii Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0502))

    ((5 . 3) . (:name "Finding of the Holy Cross"
                  :latin "Inventione Sanctæ Crucis"
                  :rank duplex-ii
                  :commune nil
                  :collect deus-qui-in-praeclara-salutiferae

                  ;; ── Matins ──
                  :invitatory christum-regem-crucifixum
                  :hymn pange-lingua-gloriosi
                  :psalms-1 ((inventae-crucis . 1)
                             (inventae-crucis . 2)
                             (inventae-crucis . 3))
                  :psalms-2 ((felix-ille-triumphus . 4)
                             (felix-ille-triumphus . 5)
                             (felix-ille-triumphus . 8))
                  :psalms-3 ((adoramus-te-christe-et-benedicimus . 95)
                             (adoramus-te-christe-et-benedicimus . 96)
                             (adoramus-te-christe-et-benedicimus . 97))
                  :versicle-1 ("Hoc signum Crucis erit in cælo."
                               "Cum Dóminus ad judicándum vénerit.")
                  :versicle-1-en ("This sign of the Cross shall be in heaven."
                                  "When the Lord shall come to judge.")
                  :versicle-2 ("Adorámus te, Christe, et benedícimus tibi."
                               "Quia per Crucem tuam redemísti mundum.")
                  :versicle-2-en ("We adore thee, O Christ, and we bless thee."
                                  "Because by thy Cross thou hast redeemed the world.")
                  :versicle-3 ("Omnis terra adóret te, et psallat tibi."
                               "Psalmum dicat nómini tuo, Dómine.")
                  :versicle-3-en ("Let all the earth adore thee, and sing unto thee."
                                  "Let it sing a psalm to thy name, O Lord.")

                  :lessons
                  (;; ── Nocturn I: Scripture (Galatians, Philippians, Colossians) ──

                   (:ref "Gal 3:10-14"
                    :source "De Epístola beáti Pauli Apóstoli ad Gálatas"
                    :text "\
Quicúmque ex opéribus legis sunt, sub maledícto sunt. Scriptum est enim: \
Maledíctus omnis qui non permánserit in ómnibus quæ scripta sunt in libro legis ut fáciat ea. \
Quóniam autem in lege nemo justificátur apud Deum, maniféstum est: quia justus ex fide vivit. \
Lex autem non est ex fide, sed, Qui fécerit ea, vivet in illis. \
Christus nos redémit de maledícto legis, factus pro nobis maledíctum: quia scriptum est: \
Maledíctus omnis qui pendet in ligno: \
ut in géntibus benedíctio Ábrahæ fíeret in Christo Jesu, ut pollicitatiónem Spíritus accipiámus per fidem.")

                   (:ref "Phil 2:5-11"
                    :source "De Epístola ad Philippénses"
                    :text "\
Hoc enim sentíte in vobis, quod et in Christo Jesu: \
qui, cum in forma Dei esset, non rapínam arbitrátus est esse se æquálem Deo: \
sed semetípsum exinanívit, formam servi accípiens, in similitúdinem hóminum factus, et hábitu invéntus ut homo. \
Humiliávit semetípsum factus obédiens usque ad mortem, mortem autem crucis. \
Propter quod et Deus exaltávit illum, et donávit illi nomen, quod est super omne nomen: \
ut in nómine Jesu omne genu flectátur cæléstium, terréstrium et infernórum, \
et omnis lingua confiteátur, quia Dóminus Jesus Christus in glória est Dei Patris.")

                   (:ref "Col 2:9-15"
                    :source "De Epístola ad Colossénses"
                    :text "\
In Christo inhábitat omnis plenitúdo divinitátis corporáliter: \
et estis in illo repléti, qui est caput omnis principátus et potestátis; \
in quo et circumcísi estis circumcisióne non manu facta in exspoliatióne córporis carnis, \
sed in circumcisióne Christi; \
consepúlti ei in baptísmo, in quo et resurrexístis per fidem operatiónis Dei, \
qui suscitávit illum a mórtuis. \
Et vos, cum mórtui essétis in delíctis, et præpútio carnis vestræ, convivificávit cum illo, \
donans vobis ómnia delícta: \
delens quod advérsus nos erat chirógraphum decréti, quod erat contrárium nobis, \
et ipsum tulit de médio, affígens illud cruci: \
et expólians principátus, et potestátes tradúxit confidénter, palam triúmphans illos in semetípso.")

                   ;; ── Nocturn II: Historical (Finding of the Cross) ──

                   (:ref "Hist."
                    :source "Ex historia"
                    :text "\
Post insígnem victóriam, quam Constantínus imperátor, divínitus accépto signo Domínicæ Crucis, \
ex Maxéntio reportávit, Hélena Constantíni mater, in somnis admónita, conquiréndæ Crucis stúdio \
Jerosólymam venit; ubi marmóream Véneris státuam, in Crucis loco a Géntibus collocátam ad \
tolléndam Christi Dómini passiónis memóriam, post centum círciter octogínta annos, everténdam curávit. \
Quod item fecit ad præsépe Salvatóris et in loco resurrectiónis, inde Adónidis hinc Jovis subláto simulácro.")

                   (:ref "Hist."
                    :text "\
Itaque loco Crucis purgáto, alte defóssæ tres cruces érutæ sunt, repertúsque seórsum ab illis \
Crucis Domínicæ títulus: qui cum ex tribus cui affíxus fuísset, non apparéret, eam dubitatiónem \
sústulit miráculum. Nam Macárius Jerosolymórum epíscopus, factis Deo précibus, síngulas cruces \
cuídam féminæ, gravi morbo laboránti, admóvit; cui cum réliquæ nihil profuíssent, adhíbita tértia \
Crux statim eam sanávit.")

                   (:ref "Hist."
                    :text "\
Hélena, salutári Cruce invénta, magnificentíssimam ibi exstrúxit ecclésiam, in qua partem Crucis \
relíquit thecis argénteis inclúsam, partem Constantíno fílio détulit; quæ Romæ repósita fuit in \
ecclésia sanctæ Crucis in Jerúsalem, ædificáta in ædibus Sessoriánis. Clavos étiam áttulit fílio, \
quibus sanctíssimum Jesu Christi corpus fixum fúerat. Quo ex témpore Constantínus legem sancívit, \
ne crux ad supplícium cuíquam adhiberétur. Ita res, quæ ántea homínibus probro ac ludíbrio fúerat, \
veneratióni et glóriæ esse cœpit.")

                   ;; ── Nocturn III: St. Augustine on John 3 ──

                   (:ref "Joann 3:1-15"
                    :source "Homilía sancti Augustíni Epíscopi\nTract. 11 in Joann., post init."
                    :text "\
Nicodémus ex his erat, qui credíderant in nómine Jesu, vidéntes signa et prodígia quæ faciébat. \
Supérius enim hoc dixit: Cum autem esset Jerosólymis in Pascha in die festo, multi credidérunt in \
nómine ejus. Quare credidérunt in nómine ejus? Séquitur, et dicit: Vidéntes signa ejus, quæ faciébat. \
Et de Nicodémo quid dicit? Erat princeps Judæórum, nómine Nicodémus. Hic venit ad eum nocte, et ait illi: \
Rabbi, scimus quia a Deo venísti magíster. Et iste ergo credíderat in nómine ejus. Et ipse unde credíderat? \
Séquitur: Nemo enim potest hæc signa fácere, quæ tu facis, nisi fúerit Deus cum eo.")

                   (:ref "Joann 3:1-15"
                    :text "\
Si ergo Nicodémus de illis multis erat, qui credíderant in nómine ejus, jam in isto Nicodémo \
attendámus, quare Jesus non se credébat eis. Respóndit Jesus et dixit ei: Amen, amen dico tibi, \
nisi quis renátus fúerit dénuo, non potest vidére regnum Dei. Ipsis ergo se credit Jesus, qui nati \
fúerint dénuo. Ecce illi credíderant in eum, et Jesus non se credébat eis. Tales sunt omnes \
catechúmeni: ipsi jam credunt in nómine Christi, sed Jesus non se credit eis. Inténdat et intélligat \
cáritas vestra. Si dixérimus catechúmeno: Credis in Christum? respóndet, Credo, et signat se Cruce \
Christi: portat in fronte, et non erubéscit de Cruce Dómini sui. Ecce credit in nómine ejus. \
Interrogémus eum: Mandúcas carnem Fílii hóminis, et bibis sánguinem Fílii hóminis? nescit quid \
dícimus, quia Jesus non se crédidit ei.")

                   ;; Lectio 9: not in DO source for this feast
                   nil)

                  :responsories
                  ((:respond "Gloriósum diem sacra venerátur Ecclésia, dum triumphále reserátur lignum:"
                    :verse "In ligno pendens nostræ salútis sémitam Verbum Patris invénit."
                    :repeat "In quo Redémptor noster, mortis víncula rumpens, cállidum áspidem superávit.")
                   (:respond "Crux fidélis, inter omnes arbor una nóbilis: nulla silva talem profert, fronde, flore, gérmine:"
                    :verse "Super ómnia ligna cedrórum tu sola excélsior."
                    :repeat "Dulce lignum, dulces clavos, dulce pondus sustínuit.")
                   (:respond "Hæc est arbor digníssima, in paradísi médio situáta,"
                    :verse "Crux præcellénti decóre fúlgida, quam Hélena Constantíni mater concupiscénti ánimo requisívit."
                    :repeat "In qua salútis auctor própria morte mortem ómnium superávit."
                    :gloria t)
                   (:respond "Nos autem gloriári opórtet in Cruce Dómini nostri Jesu Christi, in quo est salus, vita, et resurréctio nostra:"
                    :verse "Tuam Crucem adorámus, Dómine, et recólimus tuam gloriósam passiónem."
                    :repeat "Per quem salváti et liberáti sumus.")
                   (:respond "Dum sacrum pignus cǽlitus exaltátur, Christi fides roborátur:"
                    :verse "Ad Crucis contáctum resúrgunt mórtui, et Dei magnália reserántur."
                    :repeat "Adsunt prodígia divína in virga Móysi prímitus figuráta.")
                   (:respond "Hoc signum Crucis erit in cælo, cum Dóminus ad judicándum vénerit:"
                    :verse "Cum séderit Fílius hóminis in sede majestátis suæ, et cœ́perit judicáre sǽculum per ignem."
                    :repeat "Tunc manifésta erunt abscóndita cordis nostri."
                    :gloria t)
                   (:respond "Dulce lignum, dulces clavos, dulce pondus sustínuit:"
                    :verse "Hoc signum Crucis erit in cælo cum Dóminus ad judicándum vénerit."
                    :repeat "Quæ sola digna fuit portáre prétium hujus sǽculi.")
                   (:respond "Sicut Móyses exaltávit serpéntem in desérto, ita exaltári opórtet Fílium hóminis:"
                    :verse "Non misit Deus Fílium suum in mundum ut júdicet mundum, sed ut salvétur mundus per ipsum."
                    :repeat "Ut omnis qui credit in ipsum, non péreat, sed hábeat vitam ætérnam."
                    :gloria t))))

    ((5 . 4) . (:name "St. Monica, W."
                  :latin "S. Monicæ Viduæ"
                  :rank duplex
                  :commune C7
                  :collect deus-qui-inter-cetera-potentiae-0504))

    ((5 . 5) . (:name "St. Pius V, P.C."
                  :latin "S. Pii V Papæ et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-ad-conterendos-ecclesiae))

    ((5 . 6) . (:name "St. John the Apostle Before the Latin Gate"
                  :latin "S. Joannis Apostoli ante Portam Latinam"
                  :rank duplex-majus
                  :commune C1
                  :collect deus-qui-conspicis-quia-nos))

    ((5 . 7) . (:name "St. Stanislaus, Bp.M."
                  :latin "S. Stanislai Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect deus-pro-cujus-honore-gloriosus))

    ((5 . 8) . (:name "Apparition of St. Michael the Archangel"
                  :latin "In Apparitione S. Michaëlis Archangeli"
                  :rank duplex-majus
                  :commune nil
                  :collect deus-qui-miro-ordine-angelorum

                  ;; ── Matins ──
                  :invitatory regem-archangelorum-dominum
                  :hymn te-splendor-et-virtus-patris
                  :psalms-1 ((concussum-est-mare . 8)
                             (concussum-est-mare . 10)
                             (concussum-est-mare . 14))
                  :psalms-2 ((michael-archangele-veni . 18)
                             (michael-archangele-veni . 23)
                             (michael-archangele-veni . 33))
                  :psalms-3 ((angelus-archangelus-michael . 95)
                             (angelus-archangelus-michael . 96)
                             (angelus-archangelus-michael . 102))
                  :versicle-1 ("Stetit Angelus juxta aram templi."
                               "Habens thuríbulum áureum in manu sua.")
                  :versicle-1-en ("An Angel stood by the altar of the temple."
                                  "Having a golden censer in his hand.")
                  :versicle-2 ("Ascéndit fumus arómatum in conspéctu Dómini."
                               "De manu Angeli.")
                  :versicle-2-en ("The smoke of incense ascended before the Lord."
                                  "From the hand of the Angel.")
                  :versicle-3 ("In conspéctu Angelórum psallam tibi, Deus meus."
                               "Adorábo ad templum sanctum tuum, et confitébor nómini tuo.")
                  :versicle-3-en ("In the sight of the Angels I will sing unto thee, O my God."
                                  "I will worship toward thy holy temple, and give thanks unto thy name.")

                  :lessons
                  (;; ── Nocturn I: Daniel ──

                   (:ref "Dan 7:9-11"
                    :source "De Daniéle Prophéta"
                    :text "\
Aspiciébam donec throni pósiti sunt, et antíquus diérum sedit. Vestiméntum ejus cándidum quasi nix, \
et capílli cápitis ejus quasi lana munda, thronus ejus flammæ ignis, rotæ ejus ignis accénsus. \
Flúvius ígneus rapidúsque egrediebátur a fácie ejus; míllia míllium ministrábant ei, et décies \
míllies centéna míllia assistébant ei. Judícium sedit, et libri apérti sunt. \
Aspiciébam propter vocem sermónum grándium, quos cornu illud loquebátur; et vidi quóniam interfécta \
esset béstia, et perísset corpus ejus, et tráditum esset ad comburéndum igni.")

                   (:ref "Dan 10:4-8"
                    :text "\
Die autem vigésima et quarta mensis primi, eram juxta flúvium magnum, qui est Tigris. \
Et levávi óculos meos, et vidi: et ecce vir unus vestítus líneis, et renes ejus accíncti auro obrýzo; \
et corpus ejus quasi chrysólithus, et fácies ejus velut spécies fúlguris, et óculi ejus ut lampas ardens, \
et brácchia ejus, et quæ deórsum sunt usque ad pedes, quasi spécies æris candéntis; et vox sermónum ejus \
ut vox multitúdinis. \
Vidi autem ego Dániel solus visiónem; porro viri qui erant mecum non vidérunt; sed terror nímius \
írruit super eos, et fugérunt in abscónditum. \
Ego autem, relíctus solus, vidi visiónem grandem hanc, et non remánsit in me fortitúdo, sed et spécies \
mea immutáta est in me, et emárcui nec hábui quidquam vírium.")

                   (:ref "Dan 10:9-14"
                    :text "\
Et audívi vocem sermónum ejus: et áudiens jacébam consternátus super fáciem meam, et vultus meus \
hærébat terræ. Et ecce manus tétigit me, et eréxit me super génua mea et super artículos mánuum meárum. \
Et dixit ad me: Dániel, vir desideriórum, intéllege verba quæ ego loquor ad te, et sta in gradu tuo; \
nunc enim sum missus ad te. Cumque dixísset mihi sermónem istum, steti tremens. \
Et ait ad me: Noli metúere, Dániel; quia, ex die primo quo posuísti cor tuum ad intellegéndum, \
ut te afflígeres in conspéctu Dei tui, exaudíta sunt verba tua, et ego veni propter sermónes tuos. \
Princeps autem regni Persárum réstitit mihi vigínti et uno diébus; et ecce Míchaël, unus de \
princípibus primis, venit in adjutórium meum, et ego remánsi ibi juxta regem Persárum. \
Veni autem ut docérem te quæ ventúra sunt pópulo tuo in novíssimis diébus, quóniam adhuc vísio in dies.")

                   ;; ── Nocturn II: Historical (Gargano apparition) ──

                   (:ref "Hist."
                    :source "Ex historia"
                    :text "\
Beátum Michaélem Archángelum sǽpius homínibus apparuísse, et sacrórum Librórum auctoritáte et \
véteri Sanctórum traditióne comprobátur. Quam ob rem multis in locis facti memória celebrátur. \
Eum, ut olim synagóga Judæórum, sic nunc custódem et patrónum Dei venerátur Ecclésia. \
Gelásio autem primo, Pontífice máximo, in Apúlia in vértice Gargáni montis, ad cujus radíces \
íncolunt Sipontíni, Archángeli Michaélis fuit illústris apparítio.")

                   (:ref "Hist."
                    :text "\
Factum est enim, ut ex grégibus armentórum Gargáni cujúsdam taurus longe discéderet; quem diu \
conquisítum, in áditu spelúncæ hæréntem invenérunt. Cum vero quidam ex illis, ut taurum confígeret, \
sagíttam emisísset retórta sagítta in ipsum récidit sagittárium. Quæ res cum præséntes ac deínceps \
céteros tanto timóre affecísset, ut ad eam spelúncam própius accédere nemo audéret, Sipontíni \
epíscopum cónsulunt; qui, indícto trium diérum jejúnio et oratióne, rem a Deo respóndit quæri oportére.")

                   (:ref "Hist."
                    :text "\
Post tríduum Míchaël Archángelus epíscopum monet in sua tutéla esse eum locum, eóque indício \
demonstrásse, velle ibi cultum Deo in sui et Angelórum memóriam adhibéri. Quare epíscopus una cum \
cívibus ad eam spelúncam ire pergit. Quam cum in templi cujúsdam similitúdinem conformátam vidíssent, \
locum illum divínis offíciis celebráre cœpérunt: qui multis póstea miráculis illustrátus est. Nec ita \
multo post Bonifátius Papa, Romæ in summo circo, sancti Michaélis ecclésiam dedicávit tértio Kaléndas \
Octóbris; quo die étiam ómnium Angelórum memóriam Ecclésia celébrat. Hodiérnus autem dies Archángeli \
Michaélis apparitióne consecrátus est.")

                   ;; ── Nocturn III: St. Hilary on Matthew 18 ──

                   (:ref "Matt 18:1-10"
                    :source "Homilía sancti Hilárii Epíscopi\nComment in Matth. can. 18"
                    :text "\
Nónnisi revérsos in natúram puerórum introíre regnum cælórum Dóminus docet: id est, per simplicitátem \
puerílem vítia córporum nostrórum animǽque revocánda. Púeros autem, credéntes omnes per audiéntiæ \
fidem nuncupávit. Hi enim patrem sequúntur, matrem amant, próximo velle malum nésciunt, curam opum \
négligunt; non insoléscunt, non odérunt, non mentiúntur, dictis credunt, et quod áudiunt, verum habent. \
Reverténdum ígitur est ad simplicitátem infántium; quia, in ea collocáti, spéciem humilitátis Domínicæ \
circumferémus.")

                   (:ref "Matt 18:1-10"
                    :text "\
Væ huic mundo ab scándalis. Humílitas passiónis scándalum mundo est. In hoc enim máxime ignorántia \
detinétur humána, quod sub deformitáte crucis, ætérnæ glóriæ Dóminum nóluit accípere. Et quid mundo \
tam periculósum, quam non recepísse Christum? Ideo vero necésse esse ait veníre scándala; quia, ad \
sacraméntum reddéndæ nobis æternitátis, omnis in eo passiónis humílitas esset explénda.")

                   (:ref "Matt 18:1-10"
                    :text "\
Vidéte ne contemnátis unum de pusíllis istis, qui credunt in me. Aptíssimum vínculum mútui amóris \
impósuit, ad eos præcípue qui vere in Dómino credidíssent. Pusillórum enim Angeli quotídie Deum vident: \
quia Fílius hóminis venit salváre quæ pérdita sunt. Ergo et Fílius hóminis salvat, et Deum Angeli \
vident, et Angeli pusillórum præsunt fidélium oratiónibus. Præésse Angelos absolúta auctóritas est. \
Salvatórum ígitur per Christum oratiónes Angeli quotídie Deo ófferunt. Ergo periculóse ille \
contémnitur, cujus desidéria ac postulatiónes ad ætérnum et invisíbilem Deum, ambitióso Angelórum \
famulátu ac ministério, pervehúntur."))

                  :responsories
                  ((:respond "Factum est siléntium in cælo, dum commítteret bellum draco cum Michaéle Archángelo:"
                    :verse "Míllia míllium ministrábant ei, et décies centéna míllia assistébant ei."
                    :repeat "Audíta est vox míllia míllium dicéntium: Salus, honor et virtus omnipoténti Deo.")
                   (:respond "Stetit Angelus juxta aram templi, habens thuríbulum áureum in manu sua, et data sunt ei incénsa multa:"
                    :verse "In conspéctu Angelórum psallam tibi: adorábo ad templum sanctum tuum, et confitébor nómini tuo, Dómine."
                    :repeat "Et ascéndit fumus arómatum de manu Angeli in conspéctu Dómini.")
                   (:respond "In conspéctu Angelórum psallam tibi, et adorábo ad templum sanctum tuum:"
                    :verse "Super misericórdia tua et veritáte tua: quóniam magnificásti super nos nomen sanctum tuum."
                    :repeat "Et confitébor nómini tuo, Dómine."
                    :gloria t)
                   (:respond "Hic est Míchaël Archángelus, princeps milítiæ Angelórum,"
                    :verse "Archángelus Míchaël præpósitus paradísi, quem honoríficant Angelórum cives."
                    :repeat "Cujus honor præstat benefícia populórum, et orátio perdúcit ad regna cælórum.")
                   (:respond "Venit Míchaël Archángelus cum multitúdine Angelórum, cui trádidit Deus ánimas Sanctórum,"
                    :verse "Emítte, Dómine, Spíritum sanctum tuum de cælis, spíritum sapiéntiæ et intelléctus."
                    :repeat "Ut perdúcat eas in paradísum exsultatiónis.")
                   (:respond "In témpore illo consúrget Míchaël, qui stat pro fíliis vestris:"
                    :verse "In témpore illo salvábitur pópulus tuus omnis, qui invéntus fúerit scriptus in libro vitæ."
                    :repeat "Et véniet tempus, quale non fuit, ex quo gentes esse cœpérunt, usque ad illud."
                    :gloria t)
                   (:respond "In conspéctu géntium nolíte timére; vos enim in córdibus vestris adoráte et timéte Dóminum;"
                    :verse "Stetit Angelus juxta aram templi, habens thuríbulum áureum in manu sua."
                    :repeat "Angelus enim ejus vobíscum est.")
                   (:respond "Míchaël Archángelus venit in adjutórium pópulo Dei,"
                    :verse "Stetit Angelus juxta aram templi, habens thuríbulum áureum in manu sua."
                    :repeat "Stetit in auxílium pro animábus justis."
                    :gloria t))))

    ((5 . 9) . (:name "St. Gregory Nazianzen, Bishop, C.D."
                  :latin "S. Gregorii Nazianzeni Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0509))

    ((5 . 10) . (:name "St. Antoninus, Bp.C."
                  :latin "S. Antonini Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect sancti-antonini-domine-confessoris-tui))

    ((5 . 12) . (:name "Ss. Nereus, Achilleus and Domitilla the Virgin and Pancras, M.s"
                  :latin "Ss. Nerei, Achillei et Domitillæ Virg. atque Pancratii Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect semper-nos-domine-martyrum-tuorum))

    ((5 . 13) . (:name "St. Robert Bellarmine, Bishop, C.D."
                  :latin "S. Roberti Bellarmino Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-ad-errorum-insidias))

    ((5 . 14) . (:name "St. Boniface, M."
                  :latin "S. Bonifatii Martyris"
                  :rank simplex
                  :commune C2a
                  :collect da-quaesumus-omnipotens-deus-ut-0514))

    ((5 . 15) . (:name "St. John Baptist de la Salle, C."
                  :latin "S. Joannis Baptistæ de la Salle Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ad-christianam-pauperum))

    ((5 . 16) . (:name "St. Ubald, Bp.C."
                  :latin "S. Ubaldi Episcopi et Confessoris"
                  :rank semiduplex
                  :commune C4
                  :collect auxilium-tuum-nobis-domine-quaesumus))

    ((5 . 17) . (:name "St. Pascal Baylon Confessor"
                  :latin "S. Paschalis Baylon Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-paschalem-confessorem))

    ((5 . 18) . (:name "St. Venantius, M."
                  :latin "S. Venantii Martyris"
                  :rank duplex
                  :commune C2a
                  :collect deus-qui-hunc-diem-beati))

    ((5 . 19) . (:name "St. Peter Celestine, P.C."
                  :latin "S. Petri Celestini Papæ et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-beatum-petrum-caelestinum))

    ((5 . 20) . (:name "St. Bernardine of Siena, C."
                  :latin "S. Bernardini Senensis Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect domine-jesu-qui-beato-bernardino))

    ((5 . 23) . (:name "St. John Baptist de Rossi Confessor"
                  :latin "S. Joannis Baptistæ de Rossi Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-sanctum-joannem-baptistam))

    ((5 . 25) . (:name "St. Gregory VII, P.C."
                  :latin "S. Gregorii VII Papæ et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-in-te-sperantium-fortitudo))

    ((5 . 26) . (:name "St. Philip Neri, C."
                  :latin "S. Philippi Neri Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-philippum-confessorem))

    ((5 . 27) . (:name "St. Bede the Venerable, C.D."
                  :latin "S. Bedæ Venerabilis Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ecclesiam-tuam-beati-0527))

    ((5 . 28) . (:name "St. Augustine of Canterbury, Bp.C."
                  :latin "S. Augustini Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-anglorum-gentes-praedicatione))

    ((5 . 29) . (:name "St. Mary Magdalene de Pazzi, V."
                  :latin "S. Mariæ Magdalenæ de Pazzis Virginis"
                  :rank semiduplex
                  :commune C6
                  :collect deus-virginitatis-amator-qui-beatam))

    ((5 . 30) . (:name "St. Felix, P.M."
                  :latin "S. Felicis I Papæ et Martyris"
                  :rank simplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0530))

    ((5 . 31) . (:name "Queenship of the Blessed Virgin Mary"
                  :latin "Beatæ Mariæ Virginis Reginæ"
                  :rank duplex-ii
                  :commune C11
                  :collect concede-nobis-quaesumus-domine-ut))

    ;; ── JUNE ───────────────────────────────────────────────────

    ((6 . 1) . (:name "St. Angela Merici, V."
                  :latin "S. Angelæ Mericiæ Virginis"
                  :rank duplex
                  :commune C6
                  :collect deus-qui-novum-per-beatam))

    ((6 . 2) . (:name "Sts. Marcellinus, Peter, and Erasmus, M.s"
                  :latin "Ss. Marcellini, Petri, atque Erasmi, Episcopi, Martyrum"
                  :rank simplex
                  :commune C3
                  :collect deus-qui-nos-annua-beatorum))

    ((6 . 4) . (:name "St. Francis Caracciolo, C."
                  :latin "S. Francisci Caracciolo Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-franciscum-novi))

    ((6 . 5) . (:name "St. Boniface, Bp.M."
                  :latin "S. Bonifatii Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect deus-qui-multitudinem-populorum-beati))

    ((6 . 6) . (:name "St. Norbert, Bp.C."
                  :latin "S. Norberti Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-beatum-norbertum-confessorem))

    ((6 . 9) . (:name "Sts. Primus and Felician, M.s"
                  :latin "Ss. Primi et Feliciani Martyrum"
                  :rank simplex
                  :commune C3
                  :collect fac-nos-quaesumus-domine-sanctorum))

    ((6 . 10) . (:name "St. Margaret, Q.W."
                  :latin "S. Margaritæ Reginæ Viduæ"
                  :rank semiduplex
                  :commune C7
                  :collect deus-qui-beatam-margaritam-reginam))

    ((6 . 11) . (:name "St. Barnabas the Apostle"
                  :latin "S. Barnabæ Apostoli"
                  :rank duplex-majus
                  :commune C1
                  :collect deus-qui-nos-beati-barnabae))

    ((6 . 12) . (:name "St. John of St. Facundus, C."
                  :latin "S. Joannis a S. Facundo Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-auctor-pacis-et-amator))

    ((6 . 13) . (:name "St. Anthony of Padua, C."
                  :latin "S. Antonii de Padua Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-antonii-0613))

    ((6 . 14) . (:name "St. Basil the Great, C.D."
                  :latin "S. Basilii Magni, Episcopis Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0614))

    ((6 . 15) . (:name "Sts. Vitus, Modestus and Crescentia, M.s"
                  :latin "Ss. Viti, Modesti atque Crescentiæ Martyrum"
                  :rank simplex
                  :commune C3
                  :collect da-ecclesiae-tuae-quaesumus-domine))

    ((6 . 18) . (:name "St. Ephraem of Syria, C.D."
                  :latin "S. Ephræm Syri Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ecclesiam-tuam-beati-0618))

    ((6 . 19) . (:name "St. Juliana Falconeri, V."
                  :latin "S. Julianæ de Falconeriis Virginis"
                  :rank duplex
                  :commune C6
                  :collect deus-qui-beatam-julianam-virginem))

    ((6 . 20) . (:name "St. Silverius, P.M."
                  :latin "S. Silverii Papæ et Martyris"
                  :rank simplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0620))

    ((6 . 21) . (:name "St. Aloysius Gonzaga, C."
                  :latin "S. Aloisii Gonzagæ Confessoris"
                  :rank duplex
                  :commune C5
                  :collect caelestium-donorum-distributor-deus-qui))

    ((6 . 22) . (:name "St. Paulinus of Nola, Bp.C."
                  :latin "S. Paulini Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-omnia-pro-te))

    ((6 . 24) . (:name "Nativity of St. John the Baptist"
                  :latin "In Nativitate S. Joannis Baptistæ"
                  :rank duplex-i
                  :commune nil
                  :collect deus-qui-praesentem-diem-honorabilem

                  ;; ── Matins ──
                  :invitatory regem-praecursoris-dominum
                  :hymn antra-deserti
                  :psalms-1 ((priusquam-te-formarem . 1)
                             (ad-omnia-quae-mittam-te . 2)
                             (ne-timeas-a-facie . 3))
                  :psalms-2 ((misit-dominus-manum-suam . 4)
                             (ecce-dedi-verba-mea . 5)
                             (dominus-ab-utero-vocavit-me . 8))
                  :psalms-3 ((posuit-os-meum . 14)
                             (formans-me-ex-utero . 20)
                             (reges-videbunt . 33))
                  :versicle-1 ("Fuit homo missus a Deo."
                               "Cui nomen erat Joánnes.")
                  :versicle-1-en ("There was a man sent from God."
                                  "Whose name was John.")
                  :versicle-2 ("Inter natos mulíerum non surréxit major."
                               "Joánne Baptísta.")
                  :versicle-2-en ("Among them that are born of women there hath not risen a greater."
                                  "Than John the Baptist.")
                  :versicle-3 ("Elísabeth Zacharíæ magnum virum génuit."
                               "Joánnem Baptístam, præcursórem Dómini.")
                  :versicle-3-en ("Elisabeth, wife of Zachary, brought forth a great man."
                                  "John the Baptist, the forerunner of the Lord.")

                  :lessons
                  (;; ── Nocturn I: Jeremiah ──

                   (:ref "Jer 1:1-5"
                    :source "Incipit liber Jeremíæ Prophétæ"
                    :text "\
Verba Jeremíæ fílii Helcíæ, de sacerdótibus, qui fuérunt in Anathoth, in terra Bénjamin. \
Quod factum est verbum Dómini ad eum in diébus Josíæ fílii Amon regis Juda, in tertiodécimo anno \
regni ejus. Et factum est in diébus Jóakim fílii Josíæ regis Juda, usque ad consummatiónem undécimi \
anni Sedecíæ fílii Josíæ regis Juda, usque ad transmigratiónem Jerúsalem, in mense quinto. \
Et factum est verbum Dómini ad me, dicens: \
Priúsquam te formárem in útero, novi te: et ántequam exíres de vulva, sanctificávi te, et prophétam \
in géntibus dedi te.")

                   (:ref "Jer 1:6-10"
                    :text "\
Et dixi, A a a, Dómine Deus: ecce néscio loqui, quia puer ego sum. Et dixit Dóminus ad me: \
Noli dícere, Puer sum: quóniam ad ómnia, quæ mittam te, ibis: et univérsa, quæcúmque mandávero \
tibi, loquéris. Ne tímeas a fácie eórum: quia tecum ego sum, ut éruam te, dicit Dóminus. \
Et misit Dóminus manum suam, et tétigit os meum: et dixit Dóminus ad me: Ecce dedi verba mea in ore tuo: \
ecce constítui te hódie super gentes, et super regna, ut evéllas, et déstruas, et dispérdas, et díssipes, \
et ædífices, et plantes.")

                   (:ref "Jer 1:17-19"
                    :text "\
Tu ergo accínge lumbos tuos, et surge, et lóquere ad eos ómnia quæ ego præcípio tibi. Ne formídes a \
fácie eórum: nec enim timére te fáciam vultum eórum. Ego quippe dedi te hódie in civitátem munítam, \
et in colúmnam férream, et in murum ǽreum, super omnem terram, régibus Juda, princípibus ejus, et \
sacerdótibus, et pópulo terræ. Et bellábunt advérsum te, et non prævalébunt: quia ego tecum sum, \
ait Dóminus, ut líberem te.")

                   ;; ── Nocturn II: St. Augustine, Sermo 20 de Sanctis ──

                   (:ref "Sermo 20 de Sanctis"
                    :source "Sermo sancti Augustíni Epíscopi"
                    :text "\
Post illum sacrosánctum Dómini natális diem, nullíus hóminum nativitátem légimus celebrári, nisi \
solíus beáti Joánnis Baptístæ. In áliis Sanctis et eléctis Dei nóvimus illum diem coli, quo illos, \
post consummatiónem labórum et devíctum triumphatúmque mundum, in perpétuas æternitátes præsens hæc \
vita partúriit. In áliis consummáta últimi diéi mérita celebrántur: in hoc étiam prima dies, et ipsa \
étiam hóminis inítia consecrántur; pro hac absque dúbio causa, quia per hunc Dóminus advéntum suum, \
ne súbito hómines insperátum non agnóscerent, vóluit esse testátum. Joánnes autem figúra fuit véteris \
Testaménti, et in se formam prǽtulit legis; et ídeo Joánnes prænuntiávit Salvatórem, sicut lex \
grátiam præcucúrrit.")

                   (:ref "Sermo 20 de Sanctis"
                    :text "\
Quod autem nondum natus de secréto matérni úteri prophetávit, et expers lucis jam testis est veritátis; \
hoc est intellegéndum, quod latens sub velámine et carne lítteræ, et Redemptórem mundo spíritu \
prædicávit, et nobis Dóminum nostrum de quodam legis útero proclamávit. Ergo quia Judǽi erravérunt \
a ventre, id est, a lege quæ a Christo grávida erat, erravérunt a ventre, locúti sunt falsa; ídeo \
hic venit in testimónium, ut testimónium perhibéret de lúmine.")

                   (:ref "Sermo 20 de Sanctis"
                    :text "\
Quod autem Joánnes in cárcere constitútus ad Christum discípulos suos órdinat; lex ad Evangélium \
transmíttit. Quæ lex juxta typum Joánnis, quasi ignorántiæ clausa cárcere, in obscúro et in occúlto \
jacébat, et Judáica cæcitáte sensus intra lítteram tenebátur inclúsus. De hoc beátus Evangelísta \
prolóquitur: Ille erat lucérna ardens, id est, Spíritus Sancti igne succénsus, ut mundo ignorántiæ \
nocte possésso lumen salútis osténderet, et quasi inter densíssimas delictórum ténebras splendidíssimus \
justítiæ solem lucis suæ rádio demonstráret, et de seípso dicens: Ego vox clamántis in desérto.")

                   ;; ── Nocturn III: St. Ambrose on Luke 1 ──

                   (:ref "Luc 1:57-69"
                    :source "Homilía sancti Ambrósii Epíscopi\nLiber 2 Comm. in Lucæ cap. 1, ante finem"
                    :text "\
Péperit fílium Elísabeth, et congratulabántur vicíni. Habet Sanctórum edítio lætítiam plurimórum, \
quia commúne est bonum; justítia enim commúnis est virtus. Et ídeo in ortu justi futúræ vitæ insígne \
præmíttitur, et grátia secutúræ virtútis exsultatióne vicinórum præfiguránte signátur. Pulchre autem \
tempus, quo fuit in útero Prophéta, descríbitur, ne Maríæ præséntia taceátur; sed tempus silétur \
infántiæ, eo quia infántiæ impediménta nescívit. Et ídeo in Evangélio nihil super eo légimus, nisi \
ortum ejus, et oráculum, exsultatiónem in útero, vocem in desérto.")

                   (:ref "Luc 1:57-69"
                    :text "\
Neque enim ullam infántiæ sensit ætátem, qui supra natúram, supra ætátem in útero pósitus matris, \
a mensúra cœpit ætátis plenitúdinis Christi. Mire sanctus Evangelísta præmitténdum putávit, quod \
plúrimi infántem patris nómine Zacharíam appellándum putáverint; ut advértas matri non nomen alicújus \
displicuísse degéneris, sed id Sancto infúsum Spíritu, quod ab Angelo ante Zacharíæ fúerat \
prænuntiátum. Et quidem ille mutus intimáre vocábulum fílii nequívit uxóri; sed per prophetíam \
Elísabeth dídicit, quod non didícerat a maríto.")

                   (:ref "Luc 1:57-69"
                    :text "\
Joánnes est, inquit, nomen ejus; hoc est, non nos ei nomen impónimus, qui jam a Deo nomen accépit. \
Habet vocábulum suum, quod agnóvimus, non quod elégimus. Habent hoc mérita Sanctórum, ut a Deo nomen \
accípiant. Sic Jacob Israël dícitur, quia Deum vidit. Sic Dóminus noster Jesus nominátus est, \
ántequam natus; cui non Angelus, sed Pater nomen impósuit. Vides Angelos quæ audíerint, non quæ \
usurpáverint, nuntiáre. Nec miréris, si nomen múlier, quod non audívit, asséruit; quando Spíritus \
ei Sanctus, qui Angelo mandáverat, revelávit."))

                  :responsories
                  ((:respond "Fuit homo missus a Deo, cui nomen erat Joánnes:"
                    :verse "Erat Joánnes in desérto prǽdicans baptísmum pœniténtiæ."
                    :repeat "Hic venit in testimónium, ut testimónium perhibéret de lúmine, et paráret Dómino plebem perféctam.")
                   (:respond "Elísabeth Zacharíæ magnum virum génuit, Joánnem Baptístam, præcursórem Dómini:"
                    :verse "Fuit homo missus a Deo, cui nomen erat Joánnes."
                    :repeat "Qui viam Dómino præparávit in erémo.")
                   (:respond "Priúsquam te formárem in útero, novi te: et ántequam exíres de ventre, sanctificávi te,"
                    :verse "Vir diléctus a Deo, et homínibus honorátus est."
                    :repeat "Et prophétam in géntibus dedi te."
                    :gloria t)
                   (:respond "Descéndit Angelus Dómini ad Zacharíam dicens: Accipe púerum in senectúte tua:"
                    :verse "Iste puer magnus coram Dómino: nam et manus ejus cum ipso est."
                    :repeat "Et habébit nomen Joánnes Baptísta.")
                   (:respond "Hic est præcúrsor diléctus, et lucérna lucens ante Dóminum:"
                    :verse "Ipse præíbit ante illum in spíritu et virtúte Elíæ."
                    :repeat "Ipse est enim Joánnes, qui viam Dómino præparávit in erémo; sed et Agnum Dei demonstrávit, et illuminávit mentes hóminum.")
                   (:respond "Innuébant patri ejus quem vellet vocári eum: et póstulans pugillárem, scripsit dicens:"
                    :verse "Apértum est os Zacharíæ, et prophetávit dicens."
                    :repeat "Joánnes est nomen ejus."
                    :gloria t)
                   (:respond "Præcúrsor Dómini venit, de quo ipse testátur:"
                    :verse "Hic est enim prophéta, et plus quam prophéta, de quo Salvátor ait."
                    :repeat "Nullus major inter natos mulíerum Joánne Baptísta.")
                   (:respond "Gábriel Angelus appáruit Zacharíæ dicens: Nascétur tibi fílius, nomen ejus Joánnes vocábitur:"
                    :verse "Erit enim magnus coram Dómino, vinum et síceram non bibet."
                    :repeat "Et multi in nativitáte ejus gaudébunt."
                    :gloria t))))

    ((6 . 25) . (:name "St. William, Ab."
                  :latin "S. Gulielmi Abbatis"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-infirmitati-nostrae-ad))

    ((6 . 26) . (:name "Sts. John and Paul, M.s"
                  :latin "Ss. Joannis et Pauli Martyrum"
                  :rank duplex
                  :commune C3
                  :collect quaesumus-omnipotens-deus-ut-nos))

    ((6 . 28) . (:name "St. Irenaeus, Bp.M."
                  :latin "S. Irenæi Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect deus-qui-beato-irenaeo-martyri))

    ((6 . 29) . (:name "Sts. Peter and Paul, Apostles"
                  :latin "SS. Apostolorum Petri et Pauli"
                  :rank duplex-i
                  :commune C1
                  :collect deus-qui-hodiernam-diem-apostolorum))

    ((6 . 30) . (:name "Commemoration of St. Paul the Apostle"
                  :latin "In Commemoratione S. Pauli Apostoli"
                  :rank duplex-majus
                  :commune C1
                  :collect deus-qui-multitudinem-gentium-beati))

    ;; ── JULY ───────────────────────────────────────────────────

    ((7 . 1) . (:name "Most Precious Blood of Our Lord Jesus Christ"
                  :latin "Pretiosissimi Sanguinis Domini Nostri Jesu Christi"
                  :rank duplex-i
                  :commune nil
                  :collect omnipotens-sempiterne-deus-qui-unigenitum

                  ;; ── Matins ──
                  :invitatory christum-dei-filium-qui-suo-nos
                  :hymn ira-justa-conditoris
                  :psalms-1 ((postquam-consummati-sunt . 2)
                             (factus-in-agonia . 3)
                             (judas-qui-eum-tradidit . 15))
                  :psalms-2 ((pilatus-volens-populo . 22)
                             (videns-autem-quia-nihil . 29)
                             (et-respondens-universus-populus . 63))
                  :psalms-3 ((exivit-ergo-jesus . 73)
                             (et-bajulans-sibi-crucem . 87)
                             (ut-viderunt-eum-jam-mortuum . 93))
                  :versicle-1 ("Redemísti nos, Dómine."
                               "In sánguine tuo.")
                  :versicle-1-en ("Thou hast redeemed us, O Lord."
                                  "In thy Blood.")
                  :versicle-2 ("Sanguis Jesu Christi Fílii Dei."
                               "Emúndat nos ab omni peccáto.")
                  :versicle-2-en ("The Blood of Jesus Christ the Son of God."
                                  "Cleanseth us from all sin.")
                  :versicle-3 ("Christus diléxit nos."
                               "Et lavit nos a peccátis nostris in sánguine suo.")
                  :versicle-3-en ("Christ hath loved us."
                                  "And washed us from our sins in his Blood.")

                  :lessons
                  (;; ── Nocturn I: Hebrews ──

                   (:ref "Heb 9:11-15"
                    :source "De Epístola beáti Pauli Apóstoli ad Hebrǽos"
                    :text "\
Christus assístens póntifex futurórum bonórum, per ámplius et perféctius tabernáculum, non manufáctum, \
id est, non hujus creatiónis: neque per sánguinem hircórum aut vitulórum, sed per próprium sánguinem \
introívit semel in Sancta, ætérna redemptióne invénta. Si enim sanguis hircórum et taurórum, et cinis \
vítulæ aspérsus inquinátos sanctíficat ad emundatiónem carnis: quanto magis sanguis Christi, qui per \
Spíritum Sanctum semetípsum óbtulit immaculátum Deo, emundábit consciéntiam nostram ab opéribus \
mórtuis, ad serviéndum Deo vivénti? Et ídeo novi testaménti mediátor est: ut morte intercedénte, in \
redemptiónem eárum prævaricatiónum, quæ erant sub prióri testaménto, repromissiónem accípiant qui \
vocáti sunt ætérnæ hereditátis.")

                   (:ref "Heb 9:16-22"
                    :text "\
Ubi enim testaméntum est, mors necésse est intercédat testatóris. Testaméntum enim in mórtuis \
confirmátum est: alióquin nondum valet, dum vivit qui testátus est. Unde nec primum quidem sine \
sánguine dedicátum est. Lecto enim omni mandáto legis a Móyse univérso pópulo, accípiens sánguinem \
vitulórum et hircórum cum aqua, et lana coccínea, et hyssópo, ipsum quoque librum, et omnem pópulum \
aspérsit, dicens: Hic sanguis testaménti, quod mandávit ad vos Deus. Etiam tabernáculum et ómnia \
vasa ministérii sánguine simíliter aspérsit. Et ómnia pene in sánguine secúndum legem mundántur: \
et sine sánguinis effusióne non fit remíssio.")

                   (:ref "Heb 10:19-24"
                    :text "\
Habéntes ítaque, fratres, fidúciam in intróitu sanctórum in sánguine Christi, quam initiávit nobis \
viam novam, et vivéntem per velámen, id est, carnem suam, et sacerdótem magnum super domum Dei: \
accedámus cum vero corde in plenitúdine fídei, aspérsi corda a consciéntia mala, et ablúti corpus \
aqua munda, teneámus spei nostræ confessiónem indeclinábilem (fidélis enim est qui repromísit), \
et considerémus ínvicem in provocatiónem caritátis, et bonórum óperum.")

                   ;; ── Nocturn II: St. John Chrysostom, Hom. ad Neophytos ──

                   (:ref "Hom. ad Neophytos"
                    :source "Sermo sancti Joánnis Chrysóstomi"
                    :text "\
Vis sánguinis Christi audíre virtútem? Redeámus ad ejus exémplum, et priórem typum recordémur, et \
prístinam Scriptúram narrémus. In Ægýpto, nocte média, Ægýptiis Deus plagam décimam minabátur, ut \
eórum primogénita deperírent, quia primogénitum ejus pópulum detinébant. Sed, ne amáta plebs \
Judæórum una cum illis periclitarétur, quia unus locus continébat univérsos, remédium discretiónis \
invéntum est. Proínde exémplum mirábile, ut discas in veritáte virtútem. Ira divínæ indignatiónis \
operabátur, et domos síngulas mórtifer circuíbat. Quid ígitur Móyses? Occídite, inquit, agnum \
annículum, et sánguine ejus liníte jánuas. Quid ais, Móyses? Sanguis ovis rationálem hóminem \
liberáre consuévit? Valde, inquit; non eo quod sanguis est, sed quia Domínici sánguinis per eum \
demonstrátur exémplum.")

                   (:ref "Hom. ad Neophytos"
                    :text "\
Nam, sicut regnántium státuæ, quæ sine causa sunt et sermóne, nonnúmquam ad se confugiéntibus \
homínibus, ánima et ratióne decorátis, subveníre consuevérunt, non quia sunt ære conféctæ, sed quia \
rétinent imáginem principálem; ita et sanguis ille, qui irrationális fuit, ánimas habéntes hómines \
liberávit, non quia sanguis fuit, sed quia hujus sánguinis ostendébat advéntum. Et tunc Angelus ille \
vastátor, cum linítos postes atque áditus pervidéret, transjécit gressus et non est ausus intráre. \
Nunc ergo si víderit inimícus, non póstibus impósitum sánguinem typi, sed fidélium ore lucéntem \
sánguinem veritátis Christi, templi póstibus dedicátum, multo magis se súbtrahet. Si enim Angelus \
cessit exémplo, quanto magis terrébitur inimícus, si ipsam perspéxerit veritátem? Vis et áliam hujus \
sánguinis scrutári virtútem? Volo. Unde primum occúrrit, inspícias, et de quo fonte manávit. De ipsa \
primum cruce procéssit; latus illud Domínicum inítium fuit. Latus miles apéruit, et templi sancti \
paríetem patefécit; et ego thesáurum præclárum invéni, et fulgéntes divítias me grátulor reperíre.")

                   (:ref "Hom. ad Neophytos"
                    :text "\
Sic et de illo agno factum est: Judǽi ovem occidérunt, et ego fructum de sacraménto cognóvi. De \
látere sanguis et aqua. Nolo tam fácile, audítor, tránseas tanti secréta mystérii; restat enim mihi \
mýstica atque secretális orátio. Dixi baptísmatis sýmbolum et mysteriórum, aquam illam et sánguinem \
demonstráre. Ex his enim sancta fundáta est Ecclésia per lavácri regeneratiónem, et renovatiónem \
Spíritus Sancti. Per baptísma, inquam, et mystéria, quæ ex látere vidéntur esse proláta. Ex látere \
ígitur suo Christus ædificávit Ecclésiam, sicut de látere Adam ejus conjux Heva proláta est. Nam \
hac de causa Paulus quoque testátur dicens: De córpore ejus et de óssibus ejus sumus; latus vidélicet \
illud signíficans. Nam, sicut de illo látere Deus fecit féminam procreári, sic et de suo látere \
Christus aquam nobis et sánguinem dedit, unde repararétur Ecclésia.")

                   ;; ── Nocturn III: St. Augustine on John 19 ──

                   (:ref "Joann 19:30-35"
                    :source "Homilía sancti Augustíni Epíscopi\nTractatus 120 in Joannem"
                    :text "\
Vigilánti verbo Evangelísta usus est, ut non díceret: Latus ejus percússit, aut vulnerávit, aut quid \
áliud, sed Apéruit; ut illic quodámmodo vitæ óstium panderétur, unde sacraménta Ecclésiæ manavérunt, \
sine quibus ad vitam, quæ vera vita est, non intrátur. Ille sanguis qui fusus est, in remissiónem \
fusus est peccatórum. Aqua illa salutáre témperat póculum; hæc et lavácrum præstat et potum. Hoc \
prænuntiábat quod Noë in látere arcæ óstium fácere jussus est, quo intrárent animália quæ non erant \
dilúvio peritúra, quibus præfigurabátur Ecclésia. Propter hoc prima múlier facta est de látere viri \
dormiéntis, et appelláta est vita matérque vivórum. Magnum quippe significávit bonum, ante magnum \
prævaricatiónis malum. Hic secúndus Adam, inclináto cápite, in cruce dormívit, ut inde formarétur \
ei conjux, quæ de látere dormiéntis efflúxit. O mors, unde mórtui revivíscunt! Quid isto sánguine \
múndius? Quid vúlnere isto salúbrius?")

                   (:ref "Enarrat. in Psalm. 95, n. 5"
                    :source "Sancti Augustíni Epíscopi"
                    :text "\
Tenebántur hómines captívi sub diábolo, et dæmónibus serviébant; sed redémpti sunt a captivitáte. \
Véndere enim se potuérunt, sed redímere non potuérunt. Venit Redémptor, et dedit prétium; fudit \
sánguinem suum, et emit orbem terrárum. Quǽritis quid émerit? Vidéte quid déderit, et inveniétis \
quid émerit. Sanguis Christi prétium est. Tanti quid valet? quid, nisi totus orbis? quid, nisi \
omnes gentes? Valde ingráti sunt prétio suo, aut multum supérbi sunt, qui dicunt, aut illud tam \
parum esse ut solos Afros émerit, aut se tam magnos esse pro quibus solis illud sit datum. Non ergo \
exsúltent, non supérbiant. Pro toto dedit, quantum dedit.")

                   (:ref "Sermo 31, alias 344"
                    :source "Sancti Augustíni Epíscopi"
                    :text "\
Hábuit ille sánguinem, unde nos redímeret; et ad hoc accépit sánguinem, ut esset quem pro nobis \
rediméndis effúnderet. Sanguis Dómini tui, si vis, datus est pro te; si nolúeris esse, non est \
datus pro te. Forte enim dicis: Hábuit sánguinem Deus meus, quo me redímeret, sed jam, cum passus \
est, totum dedit; quid illi remánsit, quod det et pro me? Hoc est magnum, quia semel dedit, et pro \
ómnibus dedit. Sanguis Christi volénti est salus, nolénti supplícium. Quid ergo dúbitas, qui mori \
non vis, a secúnda pótius morte liberári? Qua liberáris, si vis tóllere crucem tuam, et sequi \
Dóminum; quia ille tulit suam, et quæsívit servum."))

                  :responsories
                  ((:respond "Jesus, ut sanctificáret per suum sánguinem pópulum, extra portam passus est:"
                    :verse "Nondum enim usque ad sánguinem restitístis advérsus peccátum repugnántes."
                    :repeat "Exeámus ígitur ad eum extra castra, impropérium ejus portántes.")
                   (:respond "Móyses sumptum sánguinem respérsit in pópulum:"
                    :verse "Fide celebrávit Pascha et sánguinis effusióne, ne qui vastábat primitíva, tángeret eos."
                    :repeat "Et ait: Hic est sanguis fœ́deris, quod pépigit Dóminus vobíscum.")
                   (:respond "Vos, qui aliquándo erátis longe, facti estis prope in sánguine Christi:"
                    :verse "Complácuit per eum reconciliáre ómnia in ipsum, pacíficans per sánguinem crucis ejus, sive quæ in cælis sunt."
                    :repeat "Ipse enim est pax nostra, qui fecit útraque unum."
                    :gloria t)
                   (:respond "In timóre incolátus vestri témpore conversámini"
                    :verse "Sed pretióso sánguine quasi agni immaculáti Christi."
                    :repeat "Sciéntes quod non corruptibílibus auro vel argénto redémpti estis.")
                   (:respond "Empti estis prétio magno:"
                    :verse "Prétio empti estis: nolíte fíeri servi hóminum."
                    :repeat "Glorificáte et portáte Deum in córpore vestro.")
                   (:respond "Comméndat caritátem suam Deus in nobis:"
                    :verse "Multo ígitur magis nunc justificáti in sánguine ipsíus, salvi érimus ab ira per ipsum."
                    :repeat "Quóniam cum adhuc peccatóres essémus, secúndum tempus Christus pro nobis mórtuus est."
                    :gloria t)
                   (:respond "Hic est, qui venit per aquam et sánguinem, Jesus Christus:"
                    :verse "In die illa erit fons patens dómui David et habitántibus Jerúsalem in ablutiónem peccatóris."
                    :repeat "Non in aqua solum, sed in aqua et sánguine.")
                   (:respond "Prædestinávit nos Deus in adoptiónem filiórum per Jesum Christum,"
                    :verse "Remissiónem peccatórum secúndum divítias grátiæ ejus, quæ superabundávit in nobis."
                    :repeat "In quo habémus redemptiónem per sánguinem ejus."
                    :gloria t))))

    ((7 . 2) . (:name "Visitation of the Blessed Virgin Mary"
                  :latin "In Visitatione Beatæ Mariæ Virginis"
                  :rank duplex-ii
                  :commune C11
                  :collect famulis-tuis-quaesumus-domine-caelestis))

    ((7 . 3) . (:name "St. Leo II, P.C."
                  :latin "S. Leonis Papæ et Confessoris"
                  :rank semiduplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0703))

    ((7 . 5) . (:name "St. Anthony Mary Zaccaria, C."
                  :latin "S. Antonii Mariæ Zaccaria Confessoris"
                  :rank duplex
                  :commune C5
                  :collect fac-nos-domine-deus-supereminentem))

    ((7 . 7) . (:name "Sts. Cyril and Methodius, Bishops and Confessors"
                  :latin "Ss. Cyrilli et Methodii Pont. et Conf."
                  :rank duplex
                  :commune C4
                  :collect omnipotens-sempiterne-deus-qui-slavoniae))

    ((7 . 8) . (:name "St. Elizabeth of Portugal, Q.W."
                  :latin "S. Elisabeth Reg. Portugaliæ Viduæ"
                  :rank semiduplex
                  :commune C7
                  :collect clementissime-deus-qui-beatam-elisabeth))

    ((7 . 10) . (:name "Seven Brothers, M.s, and Sts. Rufina and Secunda, V.s and Martyrs"
                  :latin "Ss. Septem Fratrum Martyrum, ac Rufinæ et Secundæ Virginum et Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect praesta-quaesumus-omnipotens-deus-ut))

    ((7 . 11) . (:name "St. Pius I, P.M."
                  :latin "S. Pii I Papæ et Martyris"
                  :rank simplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0711))

    ((7 . 12) . (:name "St. John Gualbert, Ab."
                  :latin "S. Joannis Gualberti Abbatis"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-joannis))

    ((7 . 13) . (:name "St. Anacletus, P.M."
                  :latin "S. Anacleti Papæ et Martyris"
                  :rank semiduplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0713))

    ((7 . 14) . (:name "St. Bonaventure, Bishop, C.D."
                  :latin "S. Bonaventuræ Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0714))

    ((7 . 15) . (:name "St. Henry the Emperor, C."
                  :latin "S. Henrici Imperatoris Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect deus-qui-hodierna-die-beatum))

    ((7 . 16) . (:name "Our Lady of Mt. Carmel"
                  :latin "In Commemoratione Beatæ Mariæ Virgine de Monte Carmelo"
                  :rank duplex-majus
                  :commune C11
                  :collect deus-qui-beatissimae-semper-virginis))

    ((7 . 17) . (:name "St. Alexis, C."
                  :latin "S. Alexii Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect deus-qui-nos-beati-alexii))

    ((7 . 18) . (:name "St. Camillus de Lellis, C."
                  :latin "S. Camilli de Lellis Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-sanctum-camillum-ad))

    ((7 . 19) . (:name "St. Vincent de Paul, C."
                  :latin "S. Vincentii a Paulo Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ad-evangelizandum-pauperibus))

    ((7 . 20) . (:name "St. Jerome Emiliani, C."
                  :latin "S. Hieronymi Æmiliani Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-misericordiarum-pater-per-merita))

    ((7 . 21) . (:name "St. Praxedes, V."
                  :latin "S. Praxedis Virginis"
                  :rank simplex
                  :commune C6
                  :collect deus-qui-inter-cetera-potentiae-0721))

    ((7 . 22) . (:name "St. Mary Magdalene, Penitent"
                  :latin "S. Mariæ Magdalenæ Pœnitentis"
                  :rank duplex
                  :commune C7
                  :collect beatae-mariae-magdalenae-quaesumus-domine))

    ((7 . 23) . (:name "St. Apollinaris, Bp.M."
                  :latin "S. Apollinaris Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect deus-fidelium-remunerator-animarum-qui))

    ((7 . 25) . (:name "St. James the Apostle"
                  :latin "S. Jacobi Apostoli"
                  :rank duplex-ii
                  :commune C1
                  :collect esto-domine-plebi-tuae-sanctificator))

    ((7 . 26) . (:name "St. Anne, Mother of the Blessed Virgin Mary"
                  :latin "S. Annæ Matris B.M.V."
                  :rank duplex-ii
                  :commune C7
                  :collect deus-qui-beatae-annae-gratiam))

    ((7 . 27) . (:name "S. Pantaleon Martyr"
                  :latin "S. Pantaleonis Martyris"
                  :rank simplex
                  :commune C2a
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0727))

    ((7 . 28) . (:name "Sts. Nazarius and Celsus, M., Pope Victor I, M., and Pope Innocent I, C."
                  :latin "Ss. Nazarii et Celsi Martyrum, Victoris I Papæ et Martyris ac Innocentii I Papæ et Confessoris"
                  :rank semiduplex
                  :commune C3
                  :collect sanctorum-tuorum-nos-domine-nazarii))

    ((7 . 29) . (:name "St. Martha, V."
                  :latin "S. Marthæ Virginis"
                  :rank semiduplex
                  :commune C6
                  :collect deus-qui-inter-cetera-potentiae-0729))

    ((7 . 30) . (:name "St. Abdon and Sennen, M."
                  :latin "S. Abdon et Sennen Martyrum"
                  :rank simplex
                  :commune C3
                  :collect deus-qui-sanctis-tuis-abdon))

    ((7 . 31) . (:name "St. Ignatius of Loyola, C."
                  :latin "S. Ignatii Confessoris"
                  :rank duplex-majus
                  :commune C5
                  :collect deus-qui-ad-majorem-tui))

    ;; ── AUGUST ─────────────────────────────────────────────────

    ((8 . 1) . (:name "St. Peter in Chains"
                  :latin "S. Petri ad Vincula"
                  :rank duplex-majus
                  :commune C1
                  :collect deus-qui-beatum-petrum-apostolum))

    ((8 . 2) . (:name "St. Alphonsus Liguori, Bishop, C.D."
                  :latin "S. Alfonsi Mariæ de Ligorio Episc. Conf. et Eccles. Doct."
                  :rank duplex
                  :commune C4
                  :collect deus-qui-per-beatum-alfonsum))

    ((8 . 4) . (:name "St. Dominic the Confessor"
                  :latin "S. Dominici Confessoris"
                  :rank duplex-majus
                  :commune C5
                  :collect deus-qui-ecclesiam-tuam-beati-0804))

    ((8 . 5) . (:name "Our Lady of the Snows"
                  :latin "Sanctæ Mariæ Virginis ad Nives"
                  :rank duplex-majus
                  :commune C11
                  :collect concede-nos-famulos-tuos))

    ((8 . 6) . (:name "Transfiguration of Our Lord Jesus Christ"
                  :latin "In Transfiguratione Domini Nostri Jesu Christi"
                  :rank duplex-ii
                  :commune nil
                  :collect deus-qui-fidei-sacramenta-in

                  ;; ── Matins ──
                  :invitatory summum-regem-gloriae
                  :hymn quicumque-christum-quaeritis
                  :psalms-1 ((paulo-minus-ab-angelis . 8)
                             (revelavit-dominus-condensa . 28)
                             (speciosus-forma . 44))
                  :psalms-2 ((illuminans-tu-mirabiliter . 75)
                             (melior-est-dies-una . 83)
                             (gloriosa-dicta-sunt . 86))
                  :psalms-3 ((thabor-et-hermon . 88)
                             (lux-orta-est-justo-transfig . 96)
                             (confessionem-et-decorem . 103))
                  :versicle-1 ("Gloriósus apparuísti in conspéctu Dómini."
                               "Proptérea decórem índuit te Dóminus.")
                  :versicle-1-en ("Glorious hast thou appeared in the sight of the Lord."
                                  "Therefore hath the Lord clothed thee with beauty.")
                  :versicle-2 ("Glória et honóre coronásti eum, Dómine."
                               "Et constituísti eum super ópera mánuum tuárum.")
                  :versicle-2-en ("Thou hast crowned him with glory and honour, O Lord."
                                  "And hast set him over the works of thy hands.")
                  :versicle-3 ("Magna est glória ejus in salutári tuo."
                               "Glóriam et magnum decórem impónes super eum.")
                  :versicle-3-en ("Great is his glory in thy salvation."
                                  "Glory and great beauty shalt thou lay upon him.")

                  :lessons
                  (;; ── Nocturn I: 2 Peter ──

                   (:ref "2 Pet 1:10-14"
                    :source "De Epístola secúnda beáti Petri Apóstoli"
                    :text "\
Fratres: Magis satágite, ut per bona ópera certam vestram vocatiónem et electiónem faciátis: hæc \
enim faciéntes, non peccábitis aliquándo. Sic enim abundánter ministrábitur vobis intróitus in \
ætérnum regnum Dómini nostri, et Salvatóris Jesu Christi. Propter quod incípiam vos semper commonére \
de his: et quidem sciéntes et confirmátos vos in præsénti veritáte. Justum autem árbitror, quámdiu \
sum in hoc tabernáculo, suscitáre vos in commonitióne: certus quod velox est deposítio tabernáculi \
mei secúndum quod et Dóminus noster Jesus Christus significávit mihi.")

                   (:ref "2 Pet 1:15-17"
                    :text "\
Dabo autem óperam et frequénter habére vos post óbitum meum, ut horum memóriam faciátis. Non enim \
doctas fábulas secúti notam fécimus vobis Dómini nostri Jesu Christi virtútem et præséntiam, sed \
speculatóres facti illíus magnitúdinis. Accípiens enim a Deo Patre honórem et glóriam, voce delápsa \
ad eum hujuscémodi a magnífica glória: Hic est Fílius meus diléctus, in quo mihi complácui; ipsum audíte.")

                   (:ref "2 Pet 1:18-21"
                    :text "\
Et hanc vocem nos audívimus de cælo allátam, cum essémus cum ipso in monte sancto. Et habémus \
firmiórem prophéticum sermónem, cui bene fácitis attendéntes quasi lucérnæ lucénti in caliginóso \
loco, donec dies elucéscat et lúcifer oriátur in córdibus vestris, hoc primum intellegéntes quod \
omnis prophetía Scriptúræ própria interpretatióne non fit. Non enim voluntáte humána alláta est \
aliquándo prophetía; sed Spíritu Sancto inspiráti locúti sunt sancti Dei hómines.")

                   ;; ── Nocturn II: St. Leo, Sermo de Transfiguratione ──

                   (:ref "Sermo de Transfig., ante med."
                    :source "Sermo sancti Leónis Papæ"
                    :text "\
Aperit Dóminus coram eléctis téstibus glóriam suam, et commúnem illam cum céteris córporis formam \
tanto splendóre claríficat, ut et fácies ejus solis fulgóri símilis, et vestítus candóri nívium esset \
æquális. In qua transfiguratióne illud quidem principáliter agebátur, ut de córdibus discipulórum \
crucis scándalum tollerétur; nec conturbáret eórum fidem voluntáriæ humílitas passiónis, quibus \
reveláta esset abscónditæ excelléntia dignitátis. Sed non minóre providéntia spes sanctæ Ecclésiæ \
fundabátur, ut totum Christi corpus agnósceret quali esset commutatióne donándum, ut ejus sibi honóris \
consórtium membra promítterent, qui in cápite præfulsísset.")

                   (:ref "Sermo de Transfig., ante med."
                    :text "\
Confirmándis vero Apóstolis et ad omnem sciéntiam provehéndis, ália quoque in illo miráculo accéssit \
instrúctio. Móyses enim et Elías, lex scílicet et prophétæ apparuérunt cum Dómino loquéntes; ut \
veríssime in illa quinque virórum præséntia complerétur quod dictum est: in duóbus vel tribus téstibus \
stat omne verbum. Quid hoc stabílius, quid fírmius verbo, in cujus prædicatióne véteris et novi \
Testaménti cóncinit tuba, et cum evangélica doctrína, antiquárum protestatiónum instruménta concúrrunt? \
Astipulántur enim sibi ínvicem utriúsque Fœ́deris páginæ; et, quem sub velámine mysteriórum \
præcedéntia signa promíserant, maniféstum atque perspícuum præséntis glóriæ splendor osténdit.")

                   (:ref "Sermo de Transfig., ante med."
                    :text "\
His ergo sacramentórum revelatiónibus Petrus Apóstolus incitátus, mundána spernens et terréna \
fastídiens, in æternórum desidérium quodam mentis rapiebátur excéssu; et, gáudio totíus visiónis \
implétus, ibi cum Jesu optábat habitáre, ubi manifésta ejus glória lætabátur. Unde et ait: Dómine, \
bonum est nos hic esse: si vis, faciámus hic tria tabernácula; tibi unum, Móysi unum et Elíæ unum. \
Sed huic suggestióni Dóminus non respóndit, signíficans, non quidem ímprobum, sed inordinátum esse \
quod cúperet; cum salvári mundus, nisi Christi morte, non posset, et exémplo Dómini in hoc vocarétur \
credéntium fides, ut licet non oportéret de beatitúdinis promissiónibus dubitári, intellegerémus tamen \
inter tentatiónes hujus vitæ prius nobis tolerántiam postulándam esse, quam glóriam.")

                   ;; ── Nocturn III: St. John Chrysostom on Matthew 17 ──

                   (:ref "Matt 17:1-9"
                    :source "Homilía sancti Joánnis Chrysóstomi\nHomilia 57 in Matth., in init."
                    :text "\
Quóniam multa de perículis, multa de passióne sua, multa de morte et de cæde discipulórum locútus \
est Dóminus, et áspera complúra atque árdua eis injúnxit; et illa quidem in præsénti vita, et jam \
imminébant; bona vero in spe et exspectatióne erant: ut puta, quia servárent ánimam suam, si \
pérderent eam; quia in glória Patris sui ventúrus sit, et prǽmia redditúrus: ut visu étiam certióres \
fáceret, et osténderet quidnam sit illa glória, cum qua ventúrus sit, quantum cápere póterant in hac \
præsénti vita, illis osténdit eámque détegit, ne aut sua aut Dómini morte dóleant, et máxime Petrus.")

                   (:ref "Matt 17:1-9"
                    :text "\
Et vide quid agit, cum de regno et de gehénna disserúerit. Nam in eo quod dixit: Qui ínvenit ánimam \
suam, perdet eam; et quicúmque perdet eam grátia mei, invéniet ipsam; et in eo quod ait: Reddet \
unicuíque secúndum ópera sua; et regnum et gehénnam designávit. Cum ígitur de utrísque disserúerit, \
regnum quidem ut óculis cernátur, concédit, gehénnam autem mínime; quóniam rudióribus atque \
ineptióribus illud necessárium fuísset, sed, cum illi probi essent ac perspicáces, satis fuit eos a \
melióribus confirmári. Hoc étiam multo magis ipsum decébat. Non tamen omníno illud prætermísit, sed \
et aliquándo atrocitátem gehénnæ quasi ante óculos propónit, véluti cum Lázari imáginem descrípsit, \
et ejus méminit qui denários centum repétiit.")

                   (:ref "Matt 17:1-9"
                    :text "\
Tu vero Matthǽi philosophíam consídera, qui non celávit nómina eórum qui præpósiti fúerant. Quod \
et Joánnes sǽpius facit, cum exímias Petri laudes veríssime ac diligentíssime descríbat. Nullum \
enim in hoc Apostolórum consórtio livor aut inánis glória locum habébat. Primos ígitur Apostolórum \
seórsum assúmpsit. Quam ob rem eos solos accépit? Quia excellentióres céteris vidélicet erant. Cur \
autem non íllico, sed post sex dies hoc fecit? Ne céteri discípuli seu hómines moveréntur; qua de \
re nec eos nominávit, quos acceptúrus erat."))

                  :responsories
                  ((:respond "Surge, illumináre, Jerúsalem, quia venit lumen tuum,"
                    :verse "Et ambulábunt gentes in lúmine tuo, et reges in splendóre ortus tui."
                    :repeat "Et glória Dómini super te orta est.")
                   (:respond "In splendénte nube Spíritus Sanctus visus est, Patérna vox audíta est:"
                    :verse "Appáruit nubes obúmbrans, et vox Patris intónuit."
                    :repeat "Hic est Fílius meus diléctus, in quo mihi bene complácui; ipsum audíte.")
                   (:respond "Vidéte qualem caritátem dedit nobis Deus Pater,"
                    :verse "Scimus quóniam, cum apparúerit, símiles ei érimus, quóniam vidébimus eum sícuti est."
                    :repeat "Ut fílii Dei nominémur et simus."
                    :gloria t)
                   (:respond "Inebriáti sunt ab ubertáte domus tuæ:"
                    :verse "Quóniam apud te est fons vitæ, et in lúmine tuo vidébimus lumen."
                    :repeat "Et torrénte voluptátis tuæ potásti eos.")
                   (:respond "Præcéptor, bonum est nos hic esse:"
                    :verse "Non enim sciébat quid díceret."
                    :repeat "Faciámus hic tria tabernácula; tibi unum, Móysi unum et Elíæ unum.")
                   (:respond "Si ministrátio mortis, lítteris deformáta in lapídibus, fuit in glória, ita ut non possent inténdere fílii Israël in fáciem Móysi propter glóriam vultus ejus, quæ evacuátur:"
                    :verse "Amplióris enim glóriæ Christus præ Móyse dignus est hábitus, quanto ampliórem honórem habet domo, qui fabricávit eam."
                    :repeat "Multo magis ministrátio spíritus, quæ manet, erit in glória."
                    :gloria t)
                   (:respond "Vocávit nos Deus vocatióne sua sancta, secúndum grátiam suam, quæ manifestáta est nunc;"
                    :verse "Qui destrúxit mortem, illuminávit autem vitam in incorruptiónem."
                    :repeat "Per illuminatiónem Salvatóris nostri Jesu Christi.")
                   (:respond "Deus, qui fecit de ténebris lumen splendéscere, illúxit in córdibus nostris"
                    :verse "Exórtum est in ténebris lumen rectis corde, miséricors et miserátor, et justus."
                    :repeat "Ad illuminatiónem sciéntiæ claritátis Dei, in fácie Jesu Christi."
                    :gloria t))))

    ((8 . 7) . (:name "St. Cajetan, C."
                  :latin "S. Cajetani Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beato-cajetano-confessori))

    ((8 . 8) . (:name "Sts. Cyriacus, Largus and Smaragdus, M.s"
                  :latin "Ss. Cyriaci, Largi et Smaragdi Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect beatorum-martyrum-pariterque-pontificum-cyriaci))

    ((8 . 9) . (:name "St. Jean-Marie Vianney, C."
                  :latin "S. Joannis Mariæ Vianney Confessoris"
                  :rank duplex
                  :commune C5
                  :collect omnipotens-et-misericors-deus-qui))

    ((8 . 10) . (:name "St. Lawrence, M."
                  :latin "S. Laurentii Martyris"
                  :rank duplex-ii
                  :commune C2a
                  :collect da-nobis-quaesumus-omnipotens-deus-0810))

    ((8 . 11) . (:name "Sts. Tiburtius and Susanna, M.s"
                  :latin "Ss. Tiburtii et Susannæ Virginis, Martyrum"
                  :rank simplex
                  :commune C3
                  :collect sanctorum-martyrum-tuorum-tiburtii-et))

    ((8 . 12) . (:name "St. Clare, V."
                  :latin "S. Claræ Virginis"
                  :rank duplex
                  :commune C6
                  :collect deus-qui-inter-cetera-potentiae-0812))

    ((8 . 13) . (:name "Sts. Hippolytus and Cassian, M.s"
                  :latin "Ss. Hippolyti et Cassiani Martyrum"
                  :rank simplex
                  :commune C3
                  :collect da-quaesumus-omnipotens-deus-ut-0813))

    ((8 . 15) . (:name "Assumption of the Blessed Virgin Mary"
                  :latin "In Assumptione Beatæ Mariæ Virginis"
                  :rank duplex-i
                  :commune C11
                  :collect omnipotens-sempiterne-deus-qui-immaculatam))

    ((8 . 16) . (:name "St. Joachim, C., Father of the Blessed Virgin Mary"
                  :latin "S. Joachim Confessoris, Patris B. M. V."
                  :rank duplex-ii
                  :commune C5
                  :collect deus-qui-prae-omnibus-sanctis))

    ((8 . 17) . (:name "St. Hyacinth, C."
                  :latin "S. Hyacinthi Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-hyacinthi))

    ((8 . 19) . (:name "St. John Eudes, C."
                  :latin "S. Joannis Eudes Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-joannem-confessorem))

    ((8 . 20) . (:name "St. Bernard of Clairvaux, Ab. and Doctor of the Church"
                  :latin "S. Bernardi Abbatis et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-bernardum))

    ((8 . 21) . (:name "St. Jeanne-Françoise Frémiot de Chantal, W.;Duplex"
                  :latin "S. Joannæ Franciscæ Frémiot de Chantal Viduæ"
                  :rank duplex
                  :commune C7
                  :collect omnipotens-et-misericors-deus-qui-0821))

    ((8 . 22) . (:name "Immaculate Heart of the Blessed Virgin Mary"
                  :latin "Immaculati Cordis Beatæ Mariæ Virginis"
                  :rank duplex-ii
                  :commune C11
                  :collect omnipotens-sempiterne-deus-qui-in))

    ((8 . 23) . (:name "St. Philip Benizi, C."
                  :latin "S. Philippi Benitii Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-per-beatum-philippum))

    ((8 . 24) . (:name "St. Bartholomew the Apostle"
                  :latin "S. Bartholomæi Apostoli"
                  :rank duplex-ii
                  :commune C1
                  :collect omnipotens-sempiterne-deus-qui-hujus))

    ((8 . 25) . (:name "St. Louis, C."
                  :latin "S. Ludovici Regis Franciæ Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect deus-qui-beatum-ludovicum-confessorem))

    ((8 . 26) . (:name "St. Zephyrinus, P.M."
                  :latin "S. Zephyrini Papæ et Martyris"
                  :rank simplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0826))

    ((8 . 27) . (:name "St. Joseph Calasanz, C."
                  :latin "S. Josephi Calasanctii Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-per-sanctum-josephum))

    ((8 . 28) . (:name "St. Augustine of Hippo, Bishop, C., and Doctor of the Church"
                  :latin "S. Augustini Episcopi et Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect adesto-supplicationibus-nostris-omnipotens-deus))

    ((8 . 29) . (:name "Beheading of St. John the Baptist"
                  :latin "In Decollatione S. Joannis Baptistæ"
                  :rank duplex-majus
                  :commune C2a
                  :collect sancti-joannis-baptistae-praecursoris-et))

    ((8 . 30) . (:name "St. Rose of Lima, V."
                  :latin "S. Rosæ a Sancta Maria Limanæ Virginis"
                  :rank duplex
                  :commune C6
                  :collect bonorum-omnium-largitor-omnipotens-deus))

    ((8 . 31) . (:name "St. Raymond Nonnatus, C."
                  :latin "S. Raymundi Nonnati Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-in-liberandis-fidelibus))

    ;; ── SEPTEMBER ──────────────────────────────────────────────

    ((9 . 1) . (:name "St. Giles, Ab."
                  :latin "S. Ægidii Abbatis"
                  :rank simplex
                  :commune C5
                  :collect deus-qui-nos-beati-aegidii))

    ((9 . 2) . (:name "St. Stephen, King of Hungary, C."
                  :latin "S. Stephani Hungariæ Regis Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect concede-quaesumus-ecclesiae-tuae-omnipotens))

    ((9 . 3) . (:name "St. Pius X, P.C."
                  :latin "S. Pii X Papæ Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-ad-tuendam-catholicam-0903))

    ((9 . 5) . (:name "St. Lawrence Justinian, Bp.C."
                  :latin "S. Laurentii Justiniani Episcopi et Confessoris"
                  :rank semiduplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-0905))

    ((9 . 8) . (:name "Nativity of the Blessed Virgin Mary"
                  :latin "In Nativitate Beatæ Mariæ Virginis"
                  :rank duplex-ii
                  :commune C11
                  :collect famulis-tuis-quaesumus-domine-caelestis))

    ((9 . 9) . (:name "S. Gorgonius, M."
                  :latin "S. Gorgonii Martyris"
                  :rank simplex
                  :commune C2a
                  :collect sanctus-tuus-domine-gorgonius-sua))

    ((9 . 10) . (:name "St. Nicholas of Tolentino Confessor"
                  :latin "S. Nicolai de Tolentino Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-nicolai))

    ((9 . 11) . (:name "Sts. Protus and Hyacinth Martyrs"
                  :latin "Ss. Proti et Hyacinthi Martyrum"
                  :rank simplex
                  :commune C3
                  :collect beatorum-martyrum-tuorum-proti-et))

    ((9 . 12) . (:name "Holy Name of the Blessed Virgin Mary"
                  :latin "S. Nominis Beatæ Mariæ Virginis"
                  :rank duplex-majus
                  :commune C11
                  :collect concede-quaesumus-omnipotens-deus-ut))

    ((9 . 14) . (:name "Exaltation of the Holy Cross"
                  :latin "In Exaltatione Sanctæ Crucis"
                  :rank duplex-majus
                  :commune nil
                  :collect deus-qui-nos-hodierna-die

                  ;; ── Matins ──
                  ;; ex Sancti/05-03 base; own invitatory, antiphons, lessons;
                  ;; shares hymn and most responsories with May 3 (R3 differs).
                  :invitatory christum-regem-in-cruce-exaltatum
                  :hymn pange-lingua-gloriosi
                  :psalms-1 ((nobile-lignum-exaltatur . 1)
                             (sancta-crux-extollitur . 2)
                             (o-crux-venerabilis . 3))
                  :psalms-2 ((o-crucis-victoria . 4)
                             (funestae-mortis . 10)
                             (rex-exaltatur . 20))
                  :psalms-3 ((adoramus-te-christe-exalt . 95)
                             (per-lignum-servi . 96)
                             (salvator-mundi-salva-nos . 97))
                  :versicle-1 ("Hoc signum Crucis erit in cælo."
                               "Cum Dóminus ad judicándum vénerit.")
                  :versicle-1-en ("This sign of the Cross shall be in heaven."
                                  "When the Lord shall come to judge.")
                  :versicle-2 ("Adorámus te, Christe, et benedícimus tibi."
                               "Quia per Crucem tuam redemísti mundum.")
                  :versicle-2-en ("We adore thee, O Christ, and we bless thee."
                                  "Because by thy Cross thou hast redeemed the world.")
                  :versicle-3 ("Omnis terra adóret te, et psallat tibi."
                               "Psalmum dicat nómini tuo, Dómine.")
                  :versicle-3-en ("Let all the earth adore thee, and sing unto thee."
                                  "Let it sing a psalm to thy name, O Lord.")

                  :lessons
                  (;; ── Nocturn I: Numbers 21 (Brazen Serpent) ──

                   (:ref "Num 21:1-3"
                    :source "De libro Númeri"
                    :text "\
Cum audísset Chananǽus rex Arad, qui habitábat ad merídiem, venísse scílicet Israël per \
exploratórum viam, pugnávit contra illum et victor exsístens duxit ex eo prædam. \
At Israël, voto se Dómino óbligans, ait: Si tradíderis pópulum istum in manu mea, delébo urbes ejus. \
Exaudivítque Dóminus preces Israël, et trádidit Chananǽum, quem ille interfécit, subvérsis úrbibus ejus, \
et vocávit nomen loci illíus Horma, id est, anáthema.")

                   (:ref "Num 21:4-6"
                    :text "\
Profécti sunt autem et de monte Hor per viam quæ ducit ad Mare Rubrum, ut circumírent terram Edom. \
Et tædére cœpit pópulum itíneris ac labóris. \
Locutúsque contra Deum et Móysen ait: Cur eduxísti nos de Ægýpto ut morerémur in solitúdine? \
Deest panis, non sunt aquæ, ánima nostra jam náuseat super cibo isto levíssimo. \
Quam ob rem misit Dóminus in pópulum ignítos serpéntes.")

                   (:ref "Num 21:6-9"
                    :text "\
Ad quorum plagas et mortes plurimórum \
venérunt ad Móysen atque dixérunt: Peccávimus, quia locúti sumus contra Dóminum et te: \
ora ut tollat a nobis serpéntes. Oravítque Móyses pro pópulo. \
Et locútus est Dóminus ad eum: Fac serpéntem ǽneum et pone eum pro signo: \
qui percússus aspéxerit eum, vivet. \
Fecit ergo Móyses serpéntem ǽneum et pósuit eum pro signo; quem cum percússi aspícerent, sanabántur.")

                   ;; ── Nocturn II: Historical (Heraclius and Chosroas) ──

                   (:ref "Hist."
                    :source "Ex historia"
                    :text "\
Chósroas, Persárum rex, extrémis Phocæ impérii tempóribus, Ægýpto et Africa occupáta ac Jerosólyma \
capta multísque ibi cæsis Christianórum míllibus, Christi Dómini Crucem, quam Hélena in monte Calváriæ \
collocárat, in Pérsidem ábstulit. Itaque Heraclíus, qui Phocæ succésserat, multis belli incómmodis et \
calamitátibus afféctus, pacem petébat; quam a Chósroa, victóriis insolénte, ne iníquis quidem \
conditiónibus impetráre póterat. Quare in summo discrímine se assíduis jejúniis et oratiónibus exércens, \
opem a Deo veheménter implorábat; cujus mónitu exércitu comparáto, signa cum hoste cóntulit, ac tres \
duces Chósroæ cum tribus exercítibus superávit.")

                   (:ref "Hist."
                    :text "\
Quibus cládibus fractus Chósroas, in fuga, qua traícere Tigrim parábat, Medársen fílium sócium regni \
desígnat. Sed eam contuméliam cum Síroës, Chósroæ major natu fílius, ferret atróciter, patri simul et \
fratri necem machinátur; quam paulo post utríque ex fuga retrácto áttulit, regnúmque ab Heraclío \
impetrávit quibúsdam accéptis conditiónibus, quarum ea prima fuit, ut Crucem Christi Dómini restitúeret. \
Ergo Crux, quatuórdecim annis postquam vénerat in potestátem Persárum, recépta est. Quam rédiens \
Jerosólymam Heraclíus solémni celebritáte suis húmeris rétulit in eum montem, quo eam Salvátor túlerat.")

                   (:ref "Hist."
                    :text "\
Quod factum illústri miráculo commendátum est. Nam Heraclíus, ut erat auro et gemmis ornátus, insístere \
coáctus est in porta, quæ ad Calváriæ montem ducébat. Quo enim magis prógredi conabátur, eo magis \
retinéri videbátur. Cumque ea re et ipse Heraclíus et réliqui omnes obstupéscerent; Zacharías, \
Jerosolymórum antístes, Vide, inquit, imperátor, ne isto triumpháli ornátu, in Cruce ferénda parum \
Jesu Christi paupertátem et humilitátem imitére. Tum Heraclíus, abjécto amplíssimo vestítu detractísque \
cálceis ac plebéjo amíctu indútus, réliquum viæ fácile confécit, et in eódem Calváriæ loco Crucem \
státuit, unde fúerat a Persis asportáta. Itaque Exaltatiónis sanctæ Crucis solémnitas, quæ hac die \
quotánnis celebrabátur, illústrior habéri cœpit ob ejus rei memóriam, quod ibídem fúerit repósita ab \
Heraclío, ubi Salvatóri primum fúerat constitúta.")

                   ;; ── Nocturn III: St. Leo, Sermo 8 de Passione on John 12:31-36 ──

                   (:ref "Joann 12:31-36"
                    :source "Homilía sancti Leónis Papæ\nSermo 8 de Passione Domini, post medium"
                    :text "\
Exaltáto, dilectíssimi, per Crucem Christo, non illa tantum spécies aspéctui mentis occúrrat, quæ fuit \
in óculis impiórum, quibus per Móysen dictum est: Et erit pendens vita tua ante óculos tuos, et timébis \
die ac nocte, et non credes vitæ tuæ. Isti enim nihil in crucifíxo Dómino præter fácinus suum cogitáre \
potuérunt, habéntes timórem, non quo fides vera justificátur, sed quo consciéntia iníqua torquétur. \
Noster vero intelléctus, quem spíritus veritátis illúminat, glóriam Crucis, cælo terráque radiántem, \
puro ac líbero corde suscípiat; et interióre ácie vídeat, quale sit quod Dóminus, cum de passiónis suæ \
loquerétur instántia, dixit: Nunc judícium mundi est, nunc princeps hujus mundi eiciétur foras. Et ego, \
si exaltátus fúero a terra, ómnia traham ad meípsum.")

                   (:ref "Joann 12:31-36"
                    :text "\
O admirábilis poténtia Crucis! o ineffábilis glória Passiónis, in qua et tribúnal Dómini, et judícium \
mundi, et potéstas est Crucifíxi! Traxísti enim, Dómine, ómnia ad te, et cum expandísses tota die \
manus tuas ad pópulum non credéntem et contradicéntem, tibi, confiténdæ majestátis tuæ sensum totus \
mundus accépit. Traxísti, Dómine, ómnia ad te, cum in exsecratiónem Judáici scéleris, unam protulérunt \
ómnia eleménta senténtiam; cum, obscurátis lumináribus cæli et convérso in noctem die, terra quoque \
mótibus quaterétur insólitis, univérsaque creatúra impiórum úsui se negáret. Traxísti, Dómine, ómnia \
ad te, quóniam, scisso templi velo, Sancta sanctórum ab indígnis pontifícibus recessérunt; ut figúra in \
veritátem, prophetía in manifestatiónem, et lex in Evangélium verterétur.")

                   (:ref "Joann 12:31-36"
                    :text "\
Traxísti, Dómine, ómnia ad te, ut, quod in uno Judǽæ templo obumbrátis significatiónibus tegebátur, \
pleno apertóque sacraménto universárum ubíque natiónum devótio celebráret. Nunc étenim et ordo clárior \
levitárum, et dígnitas ámplior seniórum, et sacrátior est únctio sacerdótum: quia Crux tua ómnium fons \
benedictiónum, ómnium est causa gratiárum; per quam credéntibus datur virtus de infirmitáte, glória de \
oppróbrio, vita de morte. Nunc étiam, carnálium sacrificiórum varietáte cessánte, omnes differéntias \
hostiárum una córporis et sánguinis tui implet oblátio: quóniam tu es verus Agnus Dei, qui tollis \
peccáta mundi; et ita in te univérsa pérficis mystéria, ut sicut unum est pro omni víctima sacrifícium, \
ita unum de omni gente sit regnum."))

                  :responsories
                  (;; R1-R2 same as May 3
                   (:respond "Gloriósum diem sacra venerátur Ecclésia, dum triumphále reserátur lignum:"
                    :verse "In ligno pendens nostræ salútis sémitam Verbum Patris invénit."
                    :repeat "In quo Redémptor noster, mortis víncula rumpens, cállidum áspidem superávit.")
                   (:respond "Crux fidélis, inter omnes arbor una nóbilis: nulla silva talem profert, fronde, flore, gérmine:"
                    :verse "Super ómnia ligna cedrórum tu sola excélsior."
                    :repeat "Dulce lignum, dulces clavos, dulce pondus sustínuit.")
                   ;; R3: Heraclius variant (May 3 has Helena)
                   (:respond "Hæc est arbor digníssima, in paradísi médio situáta,"
                    :verse "Crux præcellénti decóre fúlgida, quam Heraclíus imperátor concupiscénti ánimo recuperávit."
                    :repeat "In qua salútis auctor própria morte mortem ómnium superávit."
                    :gloria t)
                   ;; R4-R8 same as May 3
                   (:respond "Nos autem gloriári opórtet in Cruce Dómini nostri Jesu Christi, in quo est salus, vita, et resurréctio nostra:"
                    :verse "Tuam Crucem adorámus, Dómine, et recólimus tuam gloriósam passiónem."
                    :repeat "Per quem salváti et liberáti sumus.")
                   (:respond "Dum sacrum pignus cǽlitus exaltátur, Christi fides roborátur:"
                    :verse "Ad Crucis contáctum resúrgunt mórtui, et Dei magnália reserántur."
                    :repeat "Adsunt prodígia divína in virga Móysi prímitus figuráta.")
                   (:respond "Hoc signum Crucis erit in cælo, cum Dóminus ad judicándum vénerit:"
                    :verse "Cum séderit Fílius hóminis in sede majestátis suæ, et cœ́perit judicáre sǽculum per ignem."
                    :repeat "Tunc manifésta erunt abscóndita cordis nostri."
                    :gloria t)
                   (:respond "Dulce lignum, dulces clavos, dulce pondus sustínuit:"
                    :verse "Hoc signum Crucis erit in cælo cum Dóminus ad judicándum vénerit."
                    :repeat "Quæ sola digna fuit portáre prétium hujus sǽculi.")
                   (:respond "Sicut Móyses exaltávit serpéntem in desérto, ita exaltári opórtet Fílium hóminis:"
                    :verse "Non misit Deus Fílium suum in mundum ut júdicet mundum, sed ut salvétur mundus per ipsum."
                    :repeat "Ut omnis qui credit in ipsum, non péreat, sed hábeat vitam ætérnam."
                    :gloria t))))

    ((9 . 15) . (:name "Seven Sorrows of the Blessed Virgin Mary"
                  :latin "Septem Dolorum Beatæ Mariæ Virginis"
                  :rank duplex-ii
                  :commune C11
                  :collect deus-in-cujus-passione-secundum))

    ((9 . 16) . (:name "Sts. Cornelius, Pope and Cyprian, Bishop, M.s"
                  :latin "Ss. Cornelii Papæ et Cypriani Episcopi, Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect beatorum-martyrum-pariterque-pontificum-cornelii))

    ((9 . 17) . (:name "Impression of the Stigmata of St. Francis"
                  :latin "Impressionis Stigmatum S. Francisci"
                  :rank duplex
                  :commune C5
                  :collect domine-jesu-christe-qui-frigescente))

    ((9 . 18) . (:name "St. Joseph of Cupertino Confessor"
                  :latin "S. Josephi de Cupertino Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ad-unigenitum-filium))

    ((9 . 19) . (:name "St. Januarius, Bishop and Companions, M.s"
                  :latin "S. Januarii Episcopi et Sociorum Martyrum"
                  :rank duplex
                  :commune C3
                  :collect beatorum-martyrum-pariterque-pontificum-januarii))

    ((9 . 20) . (:name "S. Eustachius and Companions, M.s"
                  :latin "Ss. Eustachii et Sociorum Martyrum"
                  :rank duplex
                  :commune C3
                  :collect beatorum-martyrum-pariterque-pontificum-eustachii))

    ((9 . 21) . (:name "St. Matthew, Apostle and Evangelist"
                  :latin "S. Matthæi Apostoli et Evangelistæ"
                  :rank duplex-ii
                  :commune C1
                  :collect beati-apostoli-et-evangelistae-matthaei))

    ((9 . 22) . (:name "St. Thomas of Villanova, Bp.C."
                  :latin "S. Thomæ de Villanova Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-beatum-thomam-pontificem))

    ((9 . 23) . (:name "St. Linus, P.M."
                  :latin "S. Lini Papæ et Martyris"
                  :rank semiduplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-0923))

    ((9 . 24) . (:name "Our Lady of Ransom"
                  :latin "Beatæ Mariæ Virginis de Mercede"
                  :rank duplex-majus
                  :commune C11
                  :collect deus-qui-per-gloriosissimam-filii))

    ((9 . 26) . (:name "Sts. Cyprian and Justina, M.s"
                  :latin "Ss. Cypriani et Justinæ Virginis, Martyrum"
                  :rank simplex
                  :commune C3
                  :collect beatorum-martyrum-cypriani-et-justinae))

    ((9 . 27) . (:name "Sts. Cosmas and Damian, M.s"
                  :latin "Ss. Cosmæ et Damiani Martyrum"
                  :rank semiduplex
                  :commune C3
                  :collect praesta-quaesumus-omnipotens-deus-ut))

    ((9 . 28) . (:name "St. Wenceslaus, Duke and Martyr"
                  :latin "S. Wenceslai Ducis et Martyris"
                  :rank semiduplex
                  :commune C2a
                  :collect deus-qui-beatum-wenceslaum-per))

    ((9 . 29) . (:name "Dedication of the Archbasilica of St. Michael the Archangel"
                  :latin "In Dedicatione S. Michaëlis Archangelis"
                  :rank duplex-i
                  :commune nil
                  :collect deus-qui-miro-ordine-angelorum-0929

                  ;; ── Matins ──
                  ;; Invitatory, hymn, and responsories same as May 8
                  :invitatory regem-archangelorum-dominum
                  :hymn te-splendor-et-virtus-patris
                  :psalms-1 ((concussum-est-mare . 8)
                             (laudemus-dominum . 10)
                             (ascendit-fumus-aromatum . 14))
                  :psalms-2 ((michael-archangele-veni . 18)
                             (michael-praepositus-paradisi . 23)
                             (gloriosus-apparuisti . 33))
                  :psalms-3 ((angelus-archangelus-michael . 95)
                             (data-sunt-ei-incensa . 96)
                             (multa-magnalia . 102))
                  :versicle-1 ("Stetit Angelus juxta aram templi."
                               "Habens thuríbulum áureum in manu sua.")
                  :versicle-1-en ("An Angel stood by the altar of the temple."
                                  "Having a golden censer in his hand.")
                  :versicle-2 ("Ascéndit fumus arómatum in conspéctu Dómini."
                               "De manu Angeli.")
                  :versicle-2-en ("The smoke of incense ascended before the Lord."
                                  "From the hand of the Angel.")
                  :versicle-3 ("In conspéctu Angelórum psallam tibi, Deus meus."
                               "Adorábo ad templum sanctum tuum, et confitébor nómini tuo.")
                  :versicle-3-en ("In the sight of the Angels I will sing unto thee, O my God."
                                  "I will worship toward thy holy temple, and give thanks unto thy name.")

                  :lessons
                  (;; ── Nocturn I: Daniel (same as May 8) ──

                   (:ref "Dan 7:9-11"
                    :source "De Daniéle Prophéta"
                    :text "\
Aspiciébam donec throni pósiti sunt, et antíquus diérum sedit. Vestiméntum ejus cándidum quasi nix, \
et capílli cápitis ejus quasi lana munda, thronus ejus flammæ ignis, rotæ ejus ignis accénsus. \
Flúvius ígneus rapidúsque egrediebátur a fácie ejus; míllia míllium ministrábant ei, et décies \
míllies centéna míllia assistébant ei. Judícium sedit, et libri apérti sunt. \
Aspiciébam propter vocem sermónum grándium, quos cornu illud loquebátur; et vidi quóniam interfécta \
esset béstia, et perísset corpus ejus, et tráditum esset ad comburéndum igni.")

                   (:ref "Dan 10:4-8"
                    :text "\
Die autem vigésima et quarta mensis primi, eram juxta flúvium magnum, qui est Tigris. \
Et levávi óculos meos, et vidi: et ecce vir unus vestítus líneis, et renes ejus accíncti auro obrýzo; \
et corpus ejus quasi chrysólithus, et fácies ejus velut spécies fúlguris, et óculi ejus ut lampas ardens, \
et brácchia ejus, et quæ deórsum sunt usque ad pedes, quasi spécies æris candéntis; et vox sermónum ejus \
ut vox multitúdinis. \
Vidi autem ego Dániel solus visiónem; porro viri qui erant mecum non vidérunt; sed terror nímius \
írruit super eos, et fugérunt in abscónditum. \
Ego autem, relíctus solus, vidi visiónem grandem hanc, et non remánsit in me fortitúdo, sed et spécies \
mea immutáta est in me, et emárcui nec hábui quidquam vírium.")

                   (:ref "Dan 10:9-14"
                    :text "\
Et audívi vocem sermónum ejus: et áudiens jacébam consternátus super fáciem meam, et vultus meus \
hærébat terræ. Et ecce manus tétigit me, et eréxit me super génua mea et super artículos mánuum meárum. \
Et dixit ad me: Dániel, vir desideriórum, intéllege verba quæ ego loquor ad te, et sta in gradu tuo; \
nunc enim sum missus ad te. Cumque dixísset mihi sermónem istum, steti tremens. \
Et ait ad me: Noli metúere, Dániel; quia, ex die primo quo posuísti cor tuum ad intellegéndum, \
ut te afflígeres in conspéctu Dei tui, exaudíta sunt verba tua, et ego veni propter sermónes tuos. \
Princeps autem regni Persárum réstitit mihi vigínti et uno diébus; et ecce Míchaël, unus de \
princípibus primis, venit in adjutórium meum, et ego remánsi ibi juxta regem Persárum. \
Veni autem ut docérem te quæ ventúra sunt pópulo tuo in novíssimis diébus, quóniam adhuc vísio in dies.")

                   ;; ── Nocturn II: St. Gregory, Hom. 34 in Evang. ──

                   (:ref "Hom. 34 in Evang. ante med."
                    :source "Sermo sancti Gregórii Papæ"
                    :text "\
Novem Angelórum órdines dícimus, quia vidélicet esse, testánte sacro elóquio, scimus: Angelos, \
Archángelos, Virtútes, Potestátes, Principátus, Dominatiónes, Thronos, Chérubim atque Séraphim. \
Esse namque Angelos et Archángelos pene omnes sacri elóquii páginæ testántur. Chérubim vero atque \
Séraphim sæpe, ut notum est, libri prophetárum loquúntur. Quátuor quoque órdinum nómina Paulus \
Apóstolus ad Ephésios enúmerat, dicens: Supra omnem Principátum, et Potestátem, et Virtútem, et \
Dominatiónem. Qui rursus ad Colossénses scribens, ait: Sive Throni, sive Potestátes, sive \
Principátus, sive Dominatiónes. Dum ergo illis quátuor, quæ ad Ephésios dixit, conjungúntur Throni, \
quinque sunt órdines; quibus dum Angeli et Archángeli, Chérubim atque Séraphim adjúncta sunt, procul \
dúbio novem esse Angelórum órdines inveniúntur.")

                   (:ref "Hom. 34 in Evang. ante med."
                    :text "\
Sciéndum vero quod Angelórum vocábulum nomen est offícii, non natúræ. Nam sancti illi cæléstis \
pátriæ Spíritus, semper quidem sunt Spíritus, sed semper vocári Angeli nequáquam possunt; quia tunc \
solum sunt Angeli, cum per eos áliqua nuntiántur. Unde et per Psalmístam dícitur: Qui facit Angelos \
suos spíritus; ac si paténter dicat: Qui eos, quos semper habet Spíritus, étiam, cum volúerit, \
Angelos facit. Hi autem qui mínima núntiant, Angeli; qui vero summa annúntiant, Archángeli vocántur. \
Hinc est enim quod ad Maríam Vírginem non quílibet Angelus, sed Gábriel Archángelus míttitur. Ad \
hoc quippe ministérium, summum Angelum veníre dignum fúerat, qui summum ómnium nuntiábat. Qui idcírco \
étiam privátis nomínibus censéntur, ut signétur per vocábula, étiam in operatióne quid váleant. \
Míchaël namque, Quis ut Deus? Gábriel autem, Fortitúdo Dei; Ráphaël vero dícitur Medicína Dei.")

                   (:ref "Hom. 34 in Evang. ante med."
                    :text "\
Et quóties miræ virtútis áliquid ágitur, Míchaël mitti perhibétur; ut ex ipso actu et nómine detur \
intéllegi quia nullus potest fácere, quod fácere prǽvalet Deus. Unde et ille antíquus hostis, qui \
Deo esse per supérbiam símilis concupívit, dicens: In cælum conscéndam, super astra cæli exaltábo \
sólium meum, símilis ero Altíssimo; dum in fine mundi in sua virtúte relinquétur extrémo supplício \
periméndus, cum Michaéle Archángelo præliatúrus esse perhibétur, sicut per Joánnem dícitur: Factum \
est prǽlium cum Michaéle Archángelo. Ad Maríam quoque Gábriel míttitur, qui Dei Fortitúdo nominátur; \
illum quippe nuntiáre veniébat, qui ad debellándas aéreas potestátes húmilis apparére dignátus est. \
Ráphaël quoque interpretátur, ut díximus, Medicína Dei; quia vidélicet, dum Tobíæ óculos quasi per \
offícium curatiónis tétigit, cæcitátis ejus ténebras tersit.")

                   ;; ── Nocturn III: St. Jerome on Matthew 18 ──

                   (:ref "Matt 18:1-10"
                    :source "Homilía sancti Hierónymi Presbýteri\nLib. 3 Comm. in cap. 18 Matth."
                    :text "\
Post invéntum statérem, post tribúta réddita, quid sibi vult Apostolórum repentína interrogátio, \
Quis, putas, major est in regno cælórum? Quia víderant pro Petro et Dómino idem tribútum rédditum, \
ex æqualitáte prétii arbitráti sunt Petrum ómnibus Apóstolis esse prælátum, qui in redditióne tribúti \
Dómino fúerat comparátus; ídeo intérrogant quis major sit in regno cælórum. Vidénsque Jesus \
cogitatiónes eórum, et causas erróris intéllegens, vult desidérium glóriæ, humilitátis contentióne, sanáre.")

                   (:ref "Matt 18:1-10"
                    :text "\
Si autem manus tua vel pes tuus scandalízat te, abscínde eum et próice abs te. Necésse est quidem \
veníre scándala; væ tamen ei est hómini, qui, quod necésse est ut fiat in mundo, vítio suo facit ut \
per se fiat. Igitur omnis truncátur afféctus et univérsa propínquitas amputátur, ne per occasiónem \
pietátis unusquísque credéntium scándalis páteat. Si, inquit, ita est quis tibi conjúnctus, ut manus, \
pes, óculus; et est útilis atque sollícitus, et acútus ad perspiciéndum, scándalum autem tibi facit, \
et propter dissonántiam morum te pértrahit in gehénnam: mélius est ut et propinquitáte ejus et \
emoluméntis carnálibus cáreas, ne, dum vis lucri fácere cognátos et necessários, causam hábeas ruinárum.")

                   (:ref "Matt 18:1-10"
                    :text "\
Dico vobis quia Angeli eórum in cælis semper vident fáciem Patris mei. Supra díxerat, per manum et \
pedem et óculum, omnes propinquitátes et necessitúdines, quæ scándalum fácere póterant, amputándas; \
austeritátem, ítaque senténtiæ subjécto præcépto témperat, dicens: Vidéte ne contemnátis unum ex \
pusíllis istis. Sic, inquit, præcípio severitátem, ut commiscéri cleméntiam dóceam. Quia Angeli \
eórum in cælis vident semper fáciem Patris. Magna dígnitas animárum, ut unaquǽque hábeat ab ortu \
nativitátis, in custódiam sui, Angelum delegátum. Unde légimus in Apocalýpsi Joánnis: Angelo Ephesi, \
et reliquárum ecclesiárum, scribe hæc. Apóstolus quoque prǽcipit velári cápita, in ecclésiis, \
feminárum propter Angelos."))

                  ;; Responsories same as May 8
                  :responsories
                  ((:respond "Factum est siléntium in cælo, dum commítteret bellum draco cum Michaéle Archángelo:"
                    :verse "Míllia míllium ministrábant ei, et décies centéna míllia assistébant ei."
                    :repeat "Audíta est vox míllia míllium dicéntium: Salus, honor et virtus omnipoténti Deo.")
                   (:respond "Stetit Angelus juxta aram templi, habens thuríbulum áureum in manu sua, et data sunt ei incénsa multa:"
                    :verse "In conspéctu Angelórum psallam tibi: adorábo ad templum sanctum tuum, et confitébor nómini tuo, Dómine."
                    :repeat "Et ascéndit fumus arómatum de manu Angeli in conspéctu Dómini.")
                   (:respond "In conspéctu Angelórum psallam tibi, et adorábo ad templum sanctum tuum:"
                    :verse "Super misericórdia tua et veritáte tua: quóniam magnificásti super nos nomen sanctum tuum."
                    :repeat "Et confitébor nómini tuo, Dómine."
                    :gloria t)
                   (:respond "Hic est Míchaël Archángelus, princeps milítiæ Angelórum,"
                    :verse "Archángelus Míchaël præpósitus paradísi, quem honoríficant Angelórum cives."
                    :repeat "Cujus honor præstat benefícia populórum, et orátio perdúcit ad regna cælórum.")
                   (:respond "Venit Míchaël Archángelus cum multitúdine Angelórum, cui trádidit Deus ánimas Sanctórum,"
                    :verse "Emítte, Dómine, Spíritum sanctum tuum de cælis, spíritum sapiéntiæ et intelléctus."
                    :repeat "Ut perdúcat eas in paradísum exsultatiónis.")
                   (:respond "In témpore illo consúrget Míchaël, qui stat pro fíliis vestris:"
                    :verse "In témpore illo salvábitur pópulus tuus omnis, qui invéntus fúerit scriptus in libro vitæ."
                    :repeat "Et véniet tempus, quale non fuit, ex quo gentes esse cœpérunt, usque ad illud."
                    :gloria t)
                   (:respond "In conspéctu géntium nolíte timére; vos enim in córdibus vestris adoráte et timéte Dóminum;"
                    :verse "Stetit Angelus juxta aram templi, habens thuríbulum áureum in manu sua."
                    :repeat "Angelus enim ejus vobíscum est.")
                   (:respond "Míchaël Archángelus venit in adjutórium pópulo Dei,"
                    :verse "Stetit Angelus juxta aram templi, habens thuríbulum áureum in manu sua."
                    :repeat "Stetit in auxílium pro animábus justis."
                    :gloria t))))

    ((9 . 30) . (:name "St. Jerome, Priest, C.D."
                  :latin "S. Hieronymi Presbyteris Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-ecclesiae-tuae-in))

    ;; ── OCTOBER ────────────────────────────────────────────────

    ((10 . 1) . (:name "St. Remigius, Bp.C."
                  :latin "S. Remigii Episcopi et Confessoris"
                  :rank simplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-1001))

    ((10 . 2) . (:name "Guardian Angels"
                  :latin "Ss. Angelorum Custodum"
                  :rank duplex-majus
                  :commune C4
                  :collect deus-qui-ineffabili-providentia-sanctos))

    ((10 . 3) . (:name "St. Thérèse of the Child Jesus, V."
                  :latin "S. Theresiæ a Jesu Infante Virginis"
                  :rank duplex
                  :commune C6
                  :collect domine-qui-dixisti-nisi-efficiamini))

    ((10 . 4) . (:name "St. Francis of Assisi, C."
                  :latin "S. Francisci Confessoris"
                  :rank duplex-majus
                  :commune C5
                  :collect deus-qui-ecclesiam-tuam-beati-1004))

    ((10 . 5) . (:name "Sts. Placidus and Companions Martyrs"
                  :latin "Ss. Placidi et Sociorum Martyrum"
                  :rank simplex
                  :commune C3
                  :collect deus-qui-nos-concedis-sanctorum))

    ((10 . 6) . (:name "St. Bruno, C."
                  :latin "S. Brunonis Confessoris"
                  :rank duplex
                  :commune C5
                  :collect sancti-brunonis-confessoris-tui-quaesumus))

    ((10 . 7) . (:name "Our Lady of the Rosary"
                  :latin "Sacratissimi Rosarii Beatæ Mariæ Virginis"
                  :rank duplex-ii
                  :commune C11
                  :collect deus-cujus-unigenitus-per-vitam))

    ((10 . 8) . (:name "St. Birgitta, W."
                  :latin "S. Birgittæ Viduæ"
                  :rank duplex
                  :commune C7
                  :collect domine-deus-noster-qui-beatae))

    ((10 . 9) . (:name "St. John Leonard, C."
                  :latin "S. Joannis Leonardi Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-joannem-confessorem-1009))

    ((10 . 10) . (:name "St. Francis Borgia, C."
                  :latin "S. Francisci Borgiæ Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect domine-jesu-christe-verae-humilitatis))

    ((10 . 11) . (:name "Maternity of the Blessed Virgin Mary"
                  :latin "Maternitatis Beatæ Mariæ Virginis"
                  :rank duplex-ii
                  :commune C11
                  :collect deus-qui-de-beatae-mariae))

    ((10 . 13) . (:name "St. Edward the Confessor, King"
                  :latin "S. Eduardi Regis Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect deus-qui-beatum-regem-eduardum))

    ((10 . 14) . (:name "St. Callistus, P.M."
                  :latin "S. Callisti Papæ et Martyris"
                  :rank duplex
                  :commune C2
                  :collect deus-qui-nos-conspicis-ex))

    ((10 . 15) . (:name "St. Teresa of Avila, V."
                  :latin "S. Teresiæ Virginis"
                  :rank duplex
                  :commune C6
                  :collect exaudi-nos-deus-salutaris-noster))

    ((10 . 16) . (:name "St. Hedwig, W."
                  :latin "S. Hedwigis Viduæ"
                  :rank semiduplex
                  :commune C7
                  :collect deus-qui-beatam-hedwigem-a))

    ((10 . 17) . (:name "St. Marguerite-Marie Alacoque, V."
                  :latin "S. Margaritæ Mariæ Alacoque Virginis"
                  :rank duplex
                  :commune C6
                  :collect domine-jesu-christe-qui-investigabiles))

    ((10 . 18) . (:name "St. Luke the Evangelist"
                  :latin "S. Lucæ Evangelistæ"
                  :rank duplex-ii
                  :commune C1
                  :collect interveniat-pro-nobis-quaesumus-domine))

    ((10 . 19) . (:name "St. Peter of Alcantara, C."
                  :latin "S. Petri de Alcantara Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-petrum-confessorem))

    ((10 . 20) . (:name "St. John Cantius, C."
                  :latin "S. Joannis Cantii Confessoris"
                  :rank duplex
                  :commune C5
                  :collect da-quaesumus-omnipotens-deus-ut-1020))

    ((10 . 21) . (:name "St. Hilarion, Ab."
                  :latin "S. Hilarionis Abbatis"
                  :rank simplex
                  :commune C5
                  :collect deus-qui-nos-beati-hilarionis))

    ((10 . 24) . (:name "St. Raphael the Archangel"
                  :latin "S. Raphaëlis Archangeli"
                  :rank duplex-majus
                  :commune nil
                  :collect deus-qui-beatum-raphaelem-archangelum

                  ;; ── Matins ──
                  ;; ex Sancti/05-08 base; own antiphons, hymn, lessons, responsories.
                  ;; Invitatory inherited from May 8.
                  :invitatory regem-archangelorum-dominum
                  :hymn christe-sanctorum-decus-angelorum
                  :psalms-1 ((egressus-tobias . 8)
                             (angelus-raphael-seipsum . 10)
                             (sanum-ducam . 14))
                  :psalms-2 ((dixit-autem-angelus-apprehende . 18)
                             (obsecro-te-azaria . 23)
                             (lumina-fel-sanat . 33))
                  :psalms-3 ((est-hic-sara . 95)
                             (septem-viros-habuit . 96)
                             (per-tres-dies . 102))
                  :versicle-1 ("Data sunt Angelo incénsa multa."
                               "Ut adoléret ea ante altáre áureum, quod est ante óculos Dómini.")
                  :versicle-1-en ("There was given to the Angel much incense."
                                  "That he should offer it upon the golden altar, which is before the eyes of the Lord.")
                  :versicle-2 ("Ascéndit fumus arómatum in conspéctu Dómini."
                               "De manu Angeli.")
                  :versicle-2-en ("The smoke of incense ascended before the Lord."
                                  "From the hand of the Angel.")
                  :versicle-3 ("Apprehéndit Angelus Ráphaël dæmónium."
                               "Et religávit illud in desérto superióris Ægýpti.")
                  :versicle-3-en ("The Angel Raphael seized the demon."
                                  "And bound it in the desert of upper Egypt.")

                  :lessons
                  (;; ── Nocturn I: Tobit 12 ──

                   (:ref "Tob 12:1-4"
                    :source "De libro Tobíæ"
                    :text "\
Vocávit ad se Tobías fílium suum, dixítque ei: Quid póssumus dare viro isti sancto, qui venit tecum? \
Respóndens Tobías, dixit patri suo: Pater, quam mercédem dábimus ei? aut quid dignum póterit esse \
benefíciis ejus? Me duxit et redúxit sanum, pecúniam a Gabélo ipse recépit, uxórem ipse me habére \
fecit, et dæmónium ab ea ipse compéscuit: gáudium paréntibus ejus fecit, meípsum a devoratióne piscis \
erípuit, te quoque vidére fecit lumen cæli, et bonis ómnibus per eum repléti sumus. Quid illi ad hæc \
potérimus dignum dare? Sed peto te, pater mi, ut roges eum, si forte dignábitur medietátem de ómnibus \
quæ alláta sunt, sibi assúmere.")

                   (:ref "Tob 12:5-13"
                    :text "\
Et vocántes eum, pater scílicet et fílius, tulérunt eum in partem; et rogáre cœpérunt ut dignarétur \
dimídiam partem ómnium quæ attúlerant, accéptam habére. Tunc dixit eis occúlte: Benedícite Deum cæli, \
et coram ómnibus vivéntibus confitémini ei, quia fecit vobíscum misericórdiam suam. Etenim sacraméntum \
regis abscóndere bonum est, ópera autem Dei reveláre et confitéri honoríficum est. Bona est orátio cum \
jejúnio, et eleemósyna magis quam thesáuros auri recóndere; quóniam eleemósyna a morte líberat, et ipsa \
est quæ purgat peccáta, et facit inveníre misericórdiam et vitam ætérnam. Qui autem fáciunt peccátum et \
iniquitátem, hostes sunt ánimæ suæ. Manifésto ergo vobis veritátem et non abscóndam a vobis occúltum \
sermónem. Quando orábas cum lácrimis, et sepeliébas mórtuos, et derelinquébas prándium tuum, et mórtuos \
abscondébas per diem in domo tua, et nocte sepeliébas eos, ego óbtuli oratiónem tuam Dómino. Et quia \
accéptus eras Deo, necésse fuit ut tentátio probáret te.")

                   (:ref "Tob 12:14-22"
                    :text "\
Et nunc misit me Dóminus ut curárem te, et Saram uxórem fílii tui a dæmónio liberárem; ego enim sum \
Ráphaël Angelus, unus ex septem qui astámus ante Dóminum. Cumque hæc audíssent, turbáti sunt, et \
treméntes cecidérunt super terram in fáciem suam. Dixítque eis Angelus: Pax vobis, nolíte timére. \
Etenim cum essem vobíscum, per voluntátem Dei eram: ipsum benedícite, et cantáte illi. Vidébar quidem \
vobíscum manducáre, et bíbere: sed ego cibo invisíbili, et potu, qui ab homínibus vidéri non potest, \
utor. Tempus est ergo ut revértar ad eum, qui me misit: vos autem benedícite Deum, et narráte ómnia \
mirabília ejus. Et cum hæc dixísset, ab aspéctu eórum ablátus est, et ultra eum vidére non potuérunt. \
Tunc prostráti per horas tres in fáciem, benedixérunt Deum: et exsurgéntes narravérunt ómnia \
mirabília ejus.")

                   ;; ── Nocturn II: St. Bonaventure, De Sanctis Angelis Sermo 5 ──

                   (:ref "Hom."
                    :source "Sermo Sancti Bonaventuræ Epíscopi\nDe Sanctis Angelis Sermo 5, sub fine"
                    :text "\
Ráphaël interpretátur medicina Dei. Et debémus notare quod eductio a malo est per tria beneficia, a \
Raphaéle nobis colláta medicante nos. Educit ergo nos Ráphaël médicus ab infirmitáte animi, inducéndo \
nos ad amaritúdinem contritiónis; unde in Tobía dicit Ráphaël: Ubi introíeris domum tuam, lini super \
óculos ejus ex felle. Sic fecit, et vidit. Quare Ráphaël non pótuit ipse fácere? Quia Angelus non dat \
compunctiónem, sed osténdit viam. Per fel intellígitur amaritúdo contritiónis, quæ sanat óculos \
interioris mentis; Psalmus: Qui sanat contritos corde. Hoc est optimum collyrium. In Júdicum secundo \
dícitur quod Angelus ascéndit ad locum fléntium, et dixit pópulo: Eduxi vos de terra Ægypti, feci vobis \
tot et tanta bona; et flevit omnis pópulus, ita ut locus ille appellarétur locus fléntium. Caríssimi, \
Angeli tota die narrant nobis benefícia Dei, et reducunt ea nobis ad memóriam: Quis est qui te creávit, \
qui te redémit? Quid fecísti, quem offendísti? Hoc si consideráveris, nullum habes remédium nisi flere.")

                   (:ref "Hom."
                    :text "\
Secundo Ráphaël edúcit de servitute diaboli, persuadéndo nobis memóriam passiónis Christi; in cujus \
figuram dictum est Tobíæ sexto: Cordis ejus particulam si super carbónes ponas, fumus ejus éxtricat \
omne genus dæmoniórum. Dícitur Tobíæ octavo quod pósuit Tobías particulam cordis super carbónes, et \
Ráphaël religávit dæmónium in desérto superioris Ægypti. Quid est hoc? Non poterat Ráphaël religare \
dæmónium nisi ponerétur cor super carbónes? Numquid cor piscis dabat Angelo tantam virtútem? Nequaquam! \
Nihil posset, nisi ibi mystérium esset. In hoc enim nobis datur intelligi quod nihil est quod ita nos \
líberet hódie a servitute diaboli sicut passio Christi, quæ processit ex radíce cordis sive caritátis. \
Cor enim fons est caloris cunctæ vitæ. Si ergo Cor Christi, hoc est passiónem quam sustinuit, \
procedéntem ex radíce caritátis et fonte caloris, ponas super carbónes, hoc est super inflammatam \
memóriam; statim dæmon religábitur, ut tibi nocére non possit.")

                   (:ref "Hom."
                    :text "\
Tertio liberat nos a contrarietáte Dei, quam incurrimus per offensam Dei, et hoc inducéndo nos ad \
instantiam oratiónis; et hoc est quod dixit angelus Ráphaël Tobíæ duodecimo: Quando orabas cum lácrimis, \
ego óbtuli oratiónem tuam Dómino. Ipsi enim Angeli reconciliant nos Deo, quantum possunt. Accusatores \
nostri coram Deo sunt dæmones. Angeli autem excusant nos, quando ófferunt oratiónes nostras, ad quas \
devote faciendas nos inducunt; Apocalypsis octavo: Ascéndit fumus arómatum in conspéctu Dómini de manu \
Angeli. Arómata ista suáviter redoléntia sunt oratiónes Sanctórum. Vis placare Deum, quem offendísti? \
Ora devote. Offérunt Deo oratiónem tuam, ut te Deo reconcilient.")

                   ;; ── Nocturn III: St. John Chrysostom on John 5:1-4 ──

                   (:ref "Joann 5:1-4"
                    :source "Homilía sancti Joánnis Chrysóstomi\nHomilia 36 in Joánnem, num. 1"
                    :text "\
Quis hic curatiónis modus? quale mystérium subindicátur? Neque enim sine causa hæc scripta sunt; sed \
futura nobis quasi in figura et imagine describit, ne, si res stupenda accideret inexspéctata, \
auditórum multórum fidem aliquátenus labefactáret. Quænam ígitur hæc descriptio? Futurum baptisma \
dandum erat, plenum virtúte et grátia maxima, baptisma, quod peccáta ómnia ablúeret, quod ex mórtuis \
vivos redderet. Hæc ergo ut in imagine depingúntur in piscina et in aliis multis. Et primo quidem aquam \
dedit, quæ córporum máculas ablúeret, sordesque non veras, sed tales existimátas, ex funere nempe, \
ex lepra, et similes; multaque vidére est eádem de causa in veteri lege per aquam mundata.")

                   (:ref "Joann 5:1-4"
                    :text "\
Sed ad propositum jam redeamus. Primo ítaque, ut diximus, córporum maculas, deínde varias infirmitátes \
per aquam solvi curat. Ut enim nos Deus ad baptismi grátiam propius reduceret, non jam maculas solum, \
sed et morbos sanat. Imagines enim quæ propius ad veritátem accedunt, et in baptismate, et in passióne, \
et in aliis magis conspicuæ sunt quam vetustiores. Quemádmodum enim qui prope regem sunt satéllites, \
remotióribus sunt honoratiores; ita et in figuris factum est. Et Angelus descéndens turbábat aquam, et \
sanándi vim indebat ipsi, ut discerent Judæi, Angelórum Dóminum multo magis posse ánimæ morbos omnes \
curare. Sed, quemádmodum hic aquárum natúra non simpliciter curábat (alioquin enim semper id fáceret), \
sed Angeli operatióne id fiebat; sic in nobis non aqua simpliciter operátur, sed, postquam Spíritus \
grátiam accéperit, tunc ómnia solvit peccáta.")

                   (:ref "Joann 5:1-4"
                    :text "\
Circa hanc piscinam jacebat multitúdo magna infirmórum, cæcórum, claudórum, aridórum, aquæ motum \
exspectántium. Sed tunc infirmitas impediménto erat quóminus is qui vellet, sanarétur; nunc autem \
unusquísque potestátem accedéndi habet. Non enim Angelus est qui aquam movet, sed Angelórum Dóminus \
ómnia éfficit. Nec dicere póssumus: Dum ego accedo, alius ante me descéndit. Sed, si totus orbis \
venerit, grátia non consúmitur, neque vis vel operátio déficit, sed semper éadem manet. Ac, quemádmodum \
solares radii quotídie illúminant, nec absumúntur, neque, quod multis subministréntur, lucis quídpiam \
amittunt; sic, immo multo minus, Spíritus operátio minúitur a multitúdine accipiéntium. Hoc autem \
factum est ut qui díscerent in aqua curándos esse corporis morbos et hac in re diu exercitáti essent, \
facílius crederent étiam morbos animi posse curari."))

                  :responsories
                  ((:respond "In illo témpore exaudítæ sunt preces ambórum in conspéctu glóriæ summi Dei:"
                    :verse "Tobías et Sara in tribulatióne pósiti cum lácrimis oráre cœpérunt."
                    :repeat "Et missus est Angelus Dómini sanctus Ráphaël, ut curáret eos ambos, quorum uno témpore sunt oratiónes in conspéctu Dómini recitátæ.")
                   (:respond "Egréssus Tobías invénit júvenem spléndidum stantem præcínctum, et quasi parátum ad ambulándum, et salutávit eum, et dixit:"
                    :verse "Et, ignórans quod Dómini Angelus esset, salutávit eum, et dixit."
                    :repeat "Unde te habémus, bone júvenis?")
                   (:respond "Ingréssus Angelus ad Tobíam, salutávit eum, et dixit: Gaudium sit tibi semper:"
                    :verse "Et respondens Tobías, ait: Quale gáudium mihi erit, qui in ténebris sedeo, et lumen cæli non video?"
                    :repeat "Forti animo esto, in próximo enim est, ut a Deo cureris."
                    :gloria t)
                   (:respond "Interrogávit Tobías Angelum: De qua domo, aut de qua tribu es tu? Qui respondens, ait:"
                    :verse "Genus quæris mercenarii, an ipsum mercenárium, qui cum fílio tuo eat? Sed ne forte sollícitus sis."
                    :repeat "Ego sum Azarías, Ananíæ magni fílius.")
                   (:respond "Exívit Tobías ut lavaret pedes suos, et ecce piscis immanis exívit ad devorándum eum: qui expavéscens, clamávit voce magna, dicens: Dómine, invadit me. Et dixit ei Angelus: Apprehénde branchiam ejus, et trahe eum ad te."
                    :verse "Attraxit autem Tobías piscem in siccum, et palpitare cœpit ante pedes ejus; et ait Angelus ei."
                    :repeat "Exéntera hunc piscem, et cor ejus, et fel, et jecur repóne tibi: sunt enim necessaria ad medicaménta utíliter.")
                   (:respond "Ubi introíeris domum tuam, dixit Angelus Ráphaël ad Tobíam, statim adora Dóminum Deum tuum, et, grátias agens ei, accede ad patrem tuum, et osculare eum:"
                    :verse "Tolle tecum ex felle isto piscis; erit enim necessárium."
                    :repeat "Statimque lini super óculos ejus ex felle isto piscis, quem portas tecum; sicas enim quóniam mox aperiéntur óculi ejus, et vidébit pater tuus lumen cæli, et in aspectu tuo gaudébit."
                    :gloria t)
                   (:respond "Benedícite Deum cæli, dixit Angelus Ráphaël et coram ómnibus vivéntibus confitémini ei:"
                    :verse "Ipsum benedícite, et cantáte illi, et narráte ómnia mirabília ejus."
                    :repeat "Quia fecit vobíscum misericórdiam suam.")
                   (:respond "Tempus est ut revértar ad eum, qui me misit, dixit Angelus Ráphaël;"
                    :verse "Confitémini ei coram ómnibus vivéntibus, quia fecit vobíscum misericórdiam suam."
                    :repeat "Vos autem benedícite Dóminum, et narráte ómnia mirabília ejus."
                    :gloria t))))

    ((10 . 25) . (:name "Sts. Chrysanthus and Daria, M.s"
                  :latin "Ss. Chrysanthi et Dariæ Martyrum"
                  :rank simplex
                  :commune C3
                  :collect beatorum-martyrum-tuorum-domine-chrysanthi))

    ((10 . 26) . (:name "St. Evaristus, P.M."
                  :latin "S. Evaristi Papæ et Martyris"
                  :rank simplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-1026))

    ((10 . 28) . (:name "Sts. Simon and Jude, Apostles"
                  :latin "Ss. Simonis et Judæ Apostolorum"
                  :rank duplex-ii
                  :commune C1
                  :collect deus-qui-nos-per-beatos))

    ;; ── NOVEMBER ───────────────────────────────────────────────

    ((11 . 1) . (:name "All Saints"
                  :latin "Omnium Sanctorum"
                  :rank duplex-i
                  :commune C3
                  :collect omnipotens-sempiterne-deus-qui-nos))

    ((11 . 4) . (:name "St. Charles Borromeo, Bp.C."
                  :latin "S. Caroli Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect ecclesiam-tuam-domine-sancti-caroli))

    ((11 . 10) . (:name "St. Andrew Avellino Confessor"
                  :latin "S. Andreæ Avellini Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-in-corde-beati))

    ((11 . 11) . (:name "St. Martin, Bishop of Tours, C."
                  :latin "S. Martini Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-conspicis-quia-ex))

    ((11 . 12) . (:name "St. Martin I, P.M."
                  :latin "S. Martini Papæ et Martyris"
                  :rank semiduplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-1112))

    ((11 . 13) . (:name "St. Didacus, C."
                  :latin "S. Didaci Confessoris"
                  :rank semiduplex
                  :commune C5
                  :collect omnipotens-sempiterne-deus-qui-dispositione))

    ((11 . 14) . (:name "St. Josaphat, Bp.M."
                  :latin "S. Josaphat Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect excita-quaesumus-domine-in-ecclesia))

    ((11 . 15) . (:name "St. Albert the Great, Bishop, C.D."
                  :latin "S. Alberti Magni Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-beatum-albertum-pontificem))

    ((11 . 16) . (:name "St. Gertrude, V."
                  :latin "S. Gertrudis Virginis"
                  :rank duplex
                  :commune C6
                  :collect deus-qui-in-corde-beatae))

    ((11 . 17) . (:name "St. Gregory the Wonderworker, Bp.C."
                  :latin "S. Gregorii Thaumaturgi Episcopi et Confessoris"
                  :rank semiduplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-1117))

    ((11 . 19) . (:name "St. Elizabeth, W."
                  :latin "S. Elisabeth Viduæ"
                  :rank duplex
                  :commune C7
                  :collect tuorum-corda-fidelium-deus-miserator))

    ((11 . 20) . (:name "St. Felix de Valois, C."
                  :latin "S. Felicis de Valois Confessoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-beatum-felicem-confessorem))

    ((11 . 21) . (:name "Presentation of the Blessed Virgin Mary"
                  :latin "In Præsentatione Beatæ Mariæ Virginis"
                  :rank duplex-majus
                  :commune C11
                  :collect deus-qui-beatam-mariam-semper))

    ((11 . 22) . (:name "St. Cecilia, V.M."
                  :latin "S. Cæciliæ Virginis et Martyris"
                  :rank duplex
                  :commune C6
                  :collect deus-qui-nos-annua-beatae))

    ((11 . 23) . (:name "St. Clement, P.M."
                  :latin "S. Clementis Papæ et Martyris"
                  :rank duplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-1123))

    ((11 . 24) . (:name "St. John of the Cross, C.D."
                  :latin "S. Joannis a Cruce Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C5
                  :collect deus-qui-nos-beati-joannes))

    ((11 . 25) . (:name "St. Catharine of Alexandria, V.M."
                  :latin "S. Catharinæ Virginis et Martyris"
                  :rank duplex
                  :commune C6
                  :collect deus-qui-dedisti-legem-moysi))

    ((11 . 26) . (:name "St. Sylvester, Ab."
                  :latin "S. Silvestri Abbatis"
                  :rank duplex
                  :commune C5
                  :collect clementissime-deus-qui-sanctum-silvestrum))

    ((11 . 30) . (:name "St. Andrew the Apostle"
                  :latin "S. Andreæ Apostoli"
                  :rank duplex-ii
                  :commune C1
                  :collect majestatem-tuam-domine-suppliciter-exoramus))

    ;; ── DECEMBER ───────────────────────────────────────────────

    ((12 . 2) . (:name "St. Bibiana, V.M."
                  :latin "S. Bibianæ Virginis et Martyris"
                  :rank semiduplex
                  :commune C6
                  :collect deus-omnium-largitor-bonorum-qui))

    ((12 . 3) . (:name "St. Francis Xavier, C."
                  :latin "S. Francisci Xaverii Confessoris"
                  :rank duplex-majus
                  :commune C5
                  :collect deus-qui-indiarum-gentes-beati))

    ((12 . 4) . (:name "St. Peter Chrysologus, Bishop, C.D."
                  :latin "S. Petri Chrysologi Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-beatum-petrum-chrysologum))

    ((12 . 5) . (:name "St. Sabbas, Ab."
                  :latin "S. Sabbæ Abbatis"
                  :rank simplex
                  :commune C5
                  :collect deus-qui-nos-beati-sabbae))

    ((12 . 6) . (:name "St. Nicholas, Bp.C."
                  :latin "S. Nicolai Episcopi et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect deus-qui-beatum-nicolaum-pontificem))

    ((12 . 7) . (:name "St. Ambrose, Bishop, C.D."
                  :latin "S. Ambrosii Episcopi Confessoris et Ecclesiæ Doctoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-1207))

    ((12 . 8) . (:name "Immaculate Conception of the Blessed Virgin Mary"
                  :latin "In Conceptione Immaculata Beatæ Mariæ Virginis"
                  :rank duplex-i
                  :commune C11
                  :collect deus-qui-per-immaculatam-virginis))

    ((12 . 11) . (:name "St. Damasus, P.C."
                  :latin "S. Damasi Papæ et Confessoris"
                  :rank semiduplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-1211))

    ((12 . 13) . (:name "St. Lucy, V.M."
                  :latin "S. Luciæ Virginis et Martyris"
                  :rank duplex
                  :commune C6
                  :collect exaudi-nos-deus-salutaris-noster-1213))

    ((12 . 16) . (:name "St. Eusebius, Bp.M."
                  :latin "S. Eusebii Episcopi et Martyris"
                  :rank semiduplex
                  :commune C2
                  :collect infirmitatem-nostram-respice-omnipotens-deus-1216))

    ((12 . 21) . (:name "St. Thomas the Apostle"
                  :latin "S. Thomæ Apostoli"
                  :rank duplex-ii
                  :commune C1
                  :collect da-nobis-quaesumus-domine-beati))

    ((12 . 26) . (:name "St. Stephen the First Martyr"
                  :latin "S. Stephani Protomartyris"
                  :rank duplex-ii
                  :commune C2a
                  :collect da-nobis-quaesumus-domine-imitari))

    ((12 . 27) . (:name "St. John the Apostle, Evangelist"
                  :latin "S. Joannis Apostoli et Evangelistæ"
                  :rank duplex-ii
                  :commune C1
                  :collect ecclesiam-tuam-domine-benignus-illustra))

    ((12 . 28) . (:name "Holy Innocents"
                  :latin "Ss. Innocentium"
                  :rank duplex-ii
                  :commune C3
                  :collect deus-cujus-hodierna-die-praeconium))

    ((12 . 29) . (:name "St. Thomas of Canterbury, Bp.M."
                  :latin "S. Thomæ Cantuariensis Episcopi et Martyris"
                  :rank duplex
                  :commune C2
                  :collect deus-pro-cujus-ecclesia-gloriosus))

    ((12 . 31) . (:name "St. Sylvester, P.C."
                  :latin "S. Silvestri Papæ et Confessoris"
                  :rank duplex
                  :commune C4
                  :collect da-quaesumus-omnipotens-deus-ut-1231))

    ) ; end calendar
  "Fixed-feast calendar (Proprium Sanctorum) following 1911 DA rubrics.
Each entry: ((MONTH . DAY) . FEAST-PLIST).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(provide 'bcp-roman-proprium)

;;; bcp-roman-proprium.el ends here
