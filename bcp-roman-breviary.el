;;; bcp-roman-breviary.el --- Ferial Roman Breviary -*- lexical-binding: t -*-

;;; Commentary:

;; Ferial (weekday) office of the Roman Breviary (DA 1911 rubrics).
;; This file provides Vespers and Compline using the weekly psalter cycle
;; from `bcp-roman-psalterium.el'.  Psalm text comes from the Vulgate
;; psalter via `bcp-fetcher'; antiphons, hymns, and collects from the
;; incipit-keyed registries.
;;
;; Architecture follows `bcp-roman-lobvm.el': each hour has an ordo
;; builder that returns a step list, a resolver (data-fn) that maps
;; symbolic keys to text, and a psalm-fn that retrieves verse text.
;;
;; Public entry points:
;;   `bcp-roman-breviary-vespers'  — render ferial Vespers
;;   `bcp-roman-breviary-compline' — render ferial Compline

;;; Code:

(require 'cl-lib)
(require 'seq)
(require 'bcp-common-roman)
(require 'bcp-common-prayers)
(require 'bcp-roman-antiphonary)
(require 'bcp-roman-capitulary)
(require 'bcp-roman-hymnal)
(require 'bcp-roman-collectarium)
(require 'bcp-roman-psalterium)
(require 'bcp-fetcher)
(require 'bcp-calendar)
(require 'bcp-roman-tempora)
(require 'bcp-roman-season-lent)
(require 'bcp-roman-season-easter)
(require 'bcp-roman-season-advent)
(require 'bcp-roman-season-christmas)
(require 'bcp-roman-season-holyweek)
(require 'bcp-roman-proprium)

(declare-function bcp-roman-lobvm--marian-season "bcp-roman-lobvm")
(declare-function bcp-roman-render--render-office "bcp-roman-render")
(declare-function bcp-roman-season-christmas-feast-matins "bcp-roman-season-christmas")
(declare-function bcp-office-nav-init "bcp-office-nav")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Canticle data
;;
;; The renderer expects canticle plists with :name, :ref, :canticle-key,
;; :text.  English text is fetched automatically via :canticle-key from
;; `bcp-common-canticles'.

(defconst bcp-roman-breviary--magnificat
  '(:name "Magnificat"
    :ref "Luc. 1:46-55"
    :canticle-key magnificat
    :text
    "Magníficat * ánima mea Dóminum.
Et exsultávit spíritus meus: * in Deo, salutári meo.
Quia respéxit humilitátem ancíllæ suæ: * ecce enim ex hoc beátam me dicent omnes generatiónes.
Quia fecit mihi magna qui potens est: * et sanctum nomen ejus.
Et misericórdia ejus, a progénie in progénies: * timéntibus eum.
Fecit poténtiam in brácchio suo: * dispérsit supérbos mente cordis sui.
Depósuit poténtes de sede: * et exaltávit húmiles.
Esuriéntes implévit bonis: * et dívites dimísit inánes.
Suscépit Israël púerum suum: * recordátus misericórdiæ suæ.
Sicut locútus est ad patres nostros: * Abraham et sémini ejus in sǽcula.")
  "Magnificat (Canticum B.M.V., Luc. 1:46-55).")

(defconst bcp-roman-breviary--nunc-dimittis
  '(:name "Nunc dimittis"
    :ref "Luc. 2:29-32"
    :canticle-key nunc-dimittis
    :text
    "Nunc dimíttis servum tuum, Dómine, * secúndum verbum tuum in pace:
Quia vidérunt óculi mei * salutáre tuum,
Quod parásti * ante fáciem ómnium populórum,
Lumen ad revelatiónem géntium, * et glóriam plebis tuæ Israël.")
  "Nunc dimittis (Canticum Simeonis, Luc. 2:29-32).")

(defconst bcp-roman-breviary--benedictus
  '(:name "Benedictus"
    :ref "Luc. 1:68-79"
    :canticle-key benedictus
    :text
    "Benedíctus * Dóminus, Deus Israël: * quia visitávit et fecit redemptiónem plebis suæ:
Et eréxit cornu salútis nobis: * in domo David, púeri sui.
Sicut locútus est per os sanctórum, * qui a sǽculo sunt, prophetárum ejus:
Salútem ex inimícis nostris, * et de manu ómnium, qui odérunt nos.
Ad faciéndam misericórdiam cum pátribus nostris: * et memorári testaménti sui sancti.
Jusjurándum, quod jurávit ad Abraham patrem nostrum, * datúrum se nobis:
Ut sine timóre, de manu inimicórum nostrórum liberáti, * serviámus illi.
In sanctitáte et justítia coram ipso, * ómnibus diébus nostris.
Et tu, puer, Prophéta Altíssimi vocáberis: * præíbis enim ante fáciem Dómini paráre vias ejus:
Ad dandam sciéntiam salútis plebi ejus: * in remissiónem peccatórum eórum:
Per víscera misericórdiæ Dei nostri: * in quibus visitávit nos, Óriens ex alto:
Illumináre his, qui in ténebris et in umbra mortis sedent: * ad dirigéndos pedes nostros in viam pacis.")
  "Benedictus (Canticum Zachariae, Luc. 1:68-79).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline collect (Visita quaesumus — invariant)

(bcp-roman-collectarium-register
 'visita-quaesumus
 (list :latin (concat
              "Vísita, quǽsumus, Dómine, habitatiónem istam, et omnes \
insídias inimíci ab ea longe repélle: Ángeli tui sancti hábitent in \
ea, qui nos in pace custódiant; et benedíctio tua sit super nos \
semper.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((bute . "Visit, we beseech thee, O Lord, this dwelling, and drive far \
from it all the snares of the enemy: let thy holy Angels dwell herein, \
who may keep us in peace: and let thy blessing be upon us always.\n\
Through our Lord."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalm verse function
;;
;; Retrieves psalm text from the Vulgate psalter (Latin) or Coverdale
;; psalter (English), with support for subsection specs.

(defvar bcp-roman-breviary--canticle-cache (make-hash-table :test 'equal)
  "Cache of canticle verse vectors, keyed by (LANG . NUM).")

(defun bcp-roman-breviary--load-canticle (num &optional lang)
  "Load canticle NUM from the DO Psalmorum directory.
LANG is \\='latin or \\='english (default \\='latin).
Returns a vector of verse strings, or nil."
  (let* ((lang (or lang 'latin))
         (key (cons lang num)))
    (or (gethash key bcp-roman-breviary--canticle-cache)
        (let ((file (expand-file-name
                     (format "divinum-officium-master/web/www/horas/%s/\
Psalterium/Psalmorum/Psalm%d.txt"
                             (if (eq lang 'english) "English" "Latin") num)
                     (file-name-directory
                      (or load-file-name buffer-file-name
                          default-directory)))))
          (when (file-exists-p file)
            (let ((verses nil))
              (with-temp-buffer
                (insert-file-contents file)
                (goto-char (point-min))
                (while (not (eobp))
                  (let ((line (buffer-substring-no-properties
                               (line-beginning-position) (line-end-position))))
                    ;; Skip header line "(Canticum...)" and blank lines
                    (unless (or (string-empty-p line)
                                (string-prefix-p "(" line))
                      ;; Strip verse-number prefix "3:57 " etc.
                      (push (replace-regexp-in-string
                             "\\`[0-9]+:[0-9]+[a-z]? " "" line)
                            verses)))
                  (forward-line 1)))
              (let ((vec (vconcat (nreverse verses))))
                (puthash key vec bcp-roman-breviary--canticle-cache)
                vec)))))))

(defun bcp-roman-breviary--vulgate-to-coverdale (vulg-num &optional v-start v-end)
  "Map Vulgate psalm VULG-NUM (with optional verse range) to Coverdale lookup.
Returns a list of (BCP-NUM START END) specs to concatenate.
Verse numbers are adjusted for BCP/Coverdale numbering.
END of nil means \\='to end of psalm\\='."
  (cond
   ((<= vulg-num 8)
    `((,vulg-num ,v-start ,v-end)))
   ((= vulg-num 9)
    ;; Vulgate 9 = BCP 9 (vv.1-20) + BCP 10 (vv.21+, renumbered from 1)
    (let ((split 20))  ; BCP 9 covers Vulgate vv.1-20
      (cond
       ((and v-start (> v-start split))
        ;; Entirely in BCP 10
        `((10 ,(- v-start split) ,(when v-end (- v-end split)))))
       ((and v-end (<= v-end split))
        ;; Entirely in BCP 9
        `((9 ,v-start ,v-end)))
       (v-start
        ;; Spans both — nil end for first part means "to end"
        `((9 ,v-start nil) (10 1 ,(when v-end (- v-end split)))))
       (t
        ;; Whole psalm 9 = BCP 9 + BCP 10
        '((9 nil nil) (10 nil nil))))))
   ((<= vulg-num 112)
    `((,(1+ vulg-num) ,v-start ,v-end)))
   ((= vulg-num 113)
    ;; Vulgate 113 = BCP 114 (vv.1-8) + BCP 115 (vv.9+, renumbered)
    (let ((split 8))
      (cond
       ((and v-start (> v-start split))
        `((115 ,(- v-start split) ,(when v-end (- v-end split)))))
       ((and v-end (<= v-end split))
        `((114 ,v-start ,v-end)))
       (v-start
        `((114 ,v-start nil) (115 1 ,(when v-end (- v-end split)))))
       (t '((114 nil nil) (115 nil nil))))))
   ((or (= vulg-num 114) (= vulg-num 115))
    ;; Vulgate 114 + 115 = BCP 116
    `((116 ,v-start ,v-end)))
   ((<= vulg-num 145)
    `((,(1+ vulg-num) ,v-start ,v-end)))
   ((or (= vulg-num 146) (= vulg-num 147))
    ;; Vulgate 146 + 147 = BCP 147
    `((147 ,v-start ,v-end)))
   (t
    `((,vulg-num ,v-start ,v-end)))))

(defun bcp-roman-breviary--fetch-psalm-text (hebrew-num)
  "Fetch psalm HEBREW-NUM via the active fetcher, returning text or nil.
Uses `bible-commentary-psalm-translation' as the translation and
spins the event loop up to `bcp-roman-render--fetch-timeout' seconds."
  (let ((done nil) (result nil))
    (bcp-fetcher-fetch
     (format "Psalm %d" hebrew-num)
     (lambda (text) (setq result text done t))
     (and (boundp 'bible-commentary-psalm-translation)
          bible-commentary-psalm-translation))
    (let ((deadline (+ (float-time)
                       (if (boundp 'bcp-roman-render--fetch-timeout)
                           bcp-roman-render--fetch-timeout
                         10))))
      (while (and (not done) (< (float-time) deadline))
        (accept-process-output nil 0.1)))
    result))

(defun bcp-roman-breviary--psalm-verses (spec)
  "Return verse list for psalm SPEC.
SPEC is an integer (full psalm, Vulgate numbering) or a list
\(PSALM-NUM START-VERSE END-VERSE\) for a subsection.
Numbers >= 200 are treated as DO canticle numbers.
Uses the Coverdale psalter when the active psalter is \\='coverdale,
the Vulgate psalter when the psalter is \\='vulgate or language is
\\='latin, and the active fetcher for any other psalter (or none)."
  (let* ((vulg-num (if (listp spec) (car spec) spec))
         (latin   (eq bcp-roman-office-language 'latin))
         (psalter (and (boundp 'bcp-fetcher-psalter) bcp-fetcher-psalter)))
    (cond
     ;; Canticles: from DO files in the appropriate language
     ((>= vulg-num 200)
      (let ((all (bcp-roman-breviary--load-canticle
                  vulg-num (if latin 'latin 'english))))
        (when all (append all nil))))
     ;; Non-Latin with a non-standard psalter: fetch via the active fetcher
     ((and (not latin)
           (not (memq psalter '(coverdale vulgate))))
      (let* ((v-start (when (listp spec) (nth 1 spec)))
             (v-end   (when (listp spec) (nth 2 spec)))
             (lookups (bcp-roman-breviary--vulgate-to-coverdale
                       vulg-num v-start v-end))
             (result nil))
        (dolist (lookup lookups)
          (let* ((hebrew-num (nth 0 lookup))
                 (start (nth 1 lookup))
                 (end   (nth 2 lookup))
                 (text (bcp-roman-breviary--fetch-psalm-text hebrew-num)))
            (when text
              (let* ((verses (split-string text "\n" t "[ \t]+"))
                     (len (length verses))
                     (from (1- (or start 1)))
                     (to (if end (min end len) len)))
                (setq result
                      (nconc result
                             (seq-subseq verses from to)))))))
        result))
     ;; Coverdale psalter with BCP numbering (English profile)
     ((eq psalter 'coverdale)
      (let* ((table (bcp-fetcher--coverdale-psalms))
             (v-start (when (listp spec) (nth 1 spec)))
             (v-end   (when (listp spec) (nth 2 spec)))
             (lookups (bcp-roman-breviary--vulgate-to-coverdale
                       vulg-num v-start v-end))
             (result nil))
        (when table
          (dolist (lookup lookups)
            (let* ((bcp-num (nth 0 lookup))
                   (start   (nth 1 lookup))
                   (end     (nth 2 lookup))
                   (all     (gethash bcp-num table)))
              (when all
                (let* ((verses (append all nil))
                       (len (length verses))
                       (from (1- (or start 1)))
                       (to (if end (min end len) len)))
                  (setq result
                        (nconc result
                               (seq-subseq verses from to)))))))
          result)))
     ;; Latin: Vulgate psalter
     (t
      (let* ((table (bcp-fetcher--vulgate-psalms))
             (all (when table (gethash vulg-num table))))
        (when all
          (let ((verses (append all nil)))
            (if (listp spec)
                (let ((start (nth 1 spec))
                      (end   (nth 2 spec)))
                  (seq-subseq verses (1- start) end))
              verses))))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Ordo builders
;;
;; Each builder takes a day-of-week (0=Sunday..6=Saturday) and returns
;; the ordo step list for that hour.

(defun bcp-roman-breviary--collect-step (date)
  "Return a (:collect SYMBOL) step for DATE.
Checks the liturgical season first: Triduum and Holy Week privileged
feriae always use their proper collects.  Otherwise checks the
Proprium Sanctorum; if no feast or feast is displaced by a Sunday,
dispatches to the appropriate seasonal data source.
Falls back to a rubric if no collect is found."
  (let* ((season (bcp-roman-breviary--liturgical-season date))
         (feast (bcp-roman-proprium-feast date))
         ;; Triduum and HW Mon-Wed are privileged feriae: feast never wins
         (feast-wins (and feast
                         (not (memq season '(triduum-thu triduum-fri triduum-sat)))
                         (not (and (eq season 'passiontide)
                                   (bcp-roman-season-holyweek-hours date)))
                         (bcp-roman-proprium--feast-wins-p feast date)))
         (incipit
          (if feast-wins
              (plist-get feast :collect)
            (pcase season
              ((or 'triduum-thu 'triduum-fri 'triduum-sat)
               (bcp-roman-season-holyweek-collect date))
              ((or 'lent 'passiontide)
               (or (bcp-roman-season-holyweek-collect date)
                   (bcp-roman-season-lent-collect date)))
              ((or 'easter-sunday 'easter-octave 'eastertide)
               (bcp-roman-season-easter-collect date))
              ('advent
               (bcp-roman-season-advent-collect date))
              ('christmastide
               (bcp-roman-season-christmas-collect date))
              (_ (bcp-roman-tempora-collect date))))))
    (if incipit
        `(:collect ,incipit)
      '(:rubric "[Oratio dominicæ præcedentis]"))))

(defun bcp-roman-breviary--commemoration-steps (date)
  "Return commemoration steps for any displaced feast on DATE.
When a feast is displaced (by a Sunday or by a transferred feast),
returns steps inserting a rubric and the displaced feast's collect."
  (let ((com (bcp-roman-proprium--commemoration-collect date)))
    (when com
      (let ((collect (car com))
            (feast   (cdr com)))
        (when collect
          `((:rubric ,(format "[Commemorátio %s]" (plist-get feast :latin)))
            (:collect ,collect)))))))

(defun bcp-roman-breviary--vespers-ordo (dow date)
  "Build Vespers ordo for day-of-week DOW (0-6) on DATE.
On Saturday (dow=6), this is I Vespers of the following Sunday;
on Sunday (dow=0), this is II Vespers of that Sunday."
  (let* ((psalms  (bcp-roman-psalterium-vespers-psalms dow))
         (hymn    (bcp-roman-psalterium-vespers-hymn dow))
         (mag-ant (bcp-roman-psalterium-magnificat-antiphon dow))
         (season  (bcp-roman-breviary--liturgical-season date))
         ;; Saturday evening = I Vespers of Sunday: look ahead one day
         (sunday-date (if (= dow 6)
                          (calendar-gregorian-from-absolute
                           (1+ (calendar-absolute-from-gregorian date)))
                        date))
         (sdata   (bcp-roman-breviary--season-hours-data-for
                   (if (= dow 6) 0 dow) sunday-date))
         (mag-ant (or (plist-get sdata (if (= dow 6)
                                           :magnificat-antiphon
                                         :magnificat2-antiphon))
                      (plist-get sdata :magnificat-antiphon)
                      mag-ant))
         (omit-suffragium (memq season '(lent passiontide
                                         triduum-thu triduum-fri triduum-sat
                                         easter-sunday easter-octave eastertide))))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Psalmi cum Antiphonis
      ,@(mapcar (lambda (pair)
                  `(:psalm ,(cdr pair) :antiphon ,(car pair)))
                psalms)
      ;; Capitulum
      (:capitulum vespers-capitulum)
      ;; Hymnus
      (:hymn ,hymn)
      ;; Versus
      (:versicles vespers-versicle)
      ;; Canticum: Magnificat
      (:canticle magnificat :antiphon ,(or mag-ant 'magnificat-anima-mea-quia))
      ;; Preces feriales
      (:preces preces-feriales-major)
      (:psalm 50)
      (:preces preces-feriales-major-coda)
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Commemoratio (displaced feast collect)
      ,@(bcp-roman-breviary--commemoration-steps date)
      ;; Suffragium sanctorum (omitted in Lent, Eastertide, etc.)
      ,@(unless omit-suffragium '((:suffragium)))
      ;; Conclusio
      (:conclusio)
      ;; Antiphona finalis B.M.V.
      (:marian-antiphon))))

(defun bcp-roman-breviary--compline-ordo (dow)
  "Build Compline ordo for day-of-week DOW (0-6)."
  (let* ((data  (bcp-roman-psalterium-compline-psalms dow))
         (ant   (plist-get data :antiphon))
         (pss   (plist-get data :psalms)))
    `(;; Incipit
      (:text jube-domne)
      (:text benedictio-compline)
      (:text ave-maria :silent t)
      (:versicles converte-nos)
      (:incipit)
      ;; Psalmi
      (:antiphon ,ant)
      ,@(mapcar (lambda (ps) `(:psalm ,ps)) pss)
      (:antiphon ,ant :repeat t)
      ;; Hymnus
      (:hymn te-lucis-ante-terminum)
      ;; Capitulum et Versus
      (:capitulum compline-capitulum)
      (:versicles compline-versicle)
      ;; Canticum: Nunc dimittis
      (:canticle nunc-dimittis :antiphon salva-nos-domine)
      ;; Oratio
      (:pre-oratio)
      (:collect visita-quaesumus)
      ;; Conclusio
      (:conclusio)
      ;; Antiphona finalis B.M.V.
      (:marian-antiphon)
      ;; Post-office
      (:text divinum-auxilium)
      (:silent-prayers (pater-noster ave-maria credo)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Triduum Lauds ordo builder
;;
;; Lauds of the Sacred Triduum omits capitulum, hymn, and preces.
;; Proper antiphons replace the psalterium antiphons; the psalms follow
;; the weekday cursus.  After the Benedictus and collect, the
;; "Christus factus est" versicle is said in secret, followed by
;; Pater noster, Ps 50 (Miserere), and the concluding prayer (silent).

(defun bcp-roman-breviary--lauds-triduum-ordo (dow date data)
  "Build Triduum Lauds ordo for DOW on DATE using DATA plist.
Omits capitulum, hymn, and preces per the Triduum rubrics.
Psalms follow the day-of-week cursus with proper antiphons."
  (let* ((psalms  (bcp-roman-psalterium-lauds-psalms dow t))  ; always penitential
         (lauds-ants (plist-get data :lauds-antiphons))
         (ben-ant (plist-get data :benedictus-antiphon))
         ;; Override psalm antiphons with Triduum proper antiphons
         (psalms  (if lauds-ants
                      (cl-mapcar (lambda (ant ps) (cons ant (cdr ps)))
                                 lauds-ants psalms)
                    psalms)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Psalmi cum Antiphonis (5 psalms with proper antiphons)
      ,@(mapcar (lambda (pair)
                  `(:psalm ,(cdr pair) :antiphon ,(car pair)))
                psalms)
      ;; NO Capitulum — omitted in Triduum
      ;; NO Hymn — omitted in Triduum
      ;; Versus (proper versicle)
      (:versicles lauds-versicle)
      ;; Canticum: Benedictus
      (:canticle benedictus :antiphon ,(or ben-ant 'benedictus-dominus-deus-israel))
      ;; NO Preces — omitted in Triduum
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Christus factus est (secreto) + Pater noster + Ps 50
      (:rubric "[Secreto:]")
      (:text christus-factus)
      (:silent-prayers (pater-noster))
      (:psalm 50)
      ;; Concluding prayer (said silently)
      ,(bcp-roman-breviary--collect-step date)
      (:rubric "[Et sub silentio concluditur.]"))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Triduum Vespers ordo builder
;;
;; Thursday has proper Vespers psalms and antiphons for those not
;; assisting at the evening Mass.  Friday and Saturday omit Vespers
;; entirely.

(defun bcp-roman-breviary--vespers-triduum-ordo (date data)
  "Build Triduum Vespers ordo for DATE using DATA plist.
Only Thursday has proper Vespers; Friday and Saturday omit Vespers."
  (let ((vps (plist-get data :vespers-antiphons))
        (mag-ant (plist-get data :magnificat-antiphon)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Psalmi cum Antiphonis (proper psalms)
      ,@(mapcar (lambda (pair)
                  `(:psalm ,(cdr pair) :antiphon ,(car pair)))
              vps)
      ;; NO Capitulum — omitted in Triduum
      ;; NO Hymn — omitted in Triduum
      ;; Canticum: Magnificat
      (:canticle magnificat :antiphon ,(or mag-ant 'magnificat-anima-mea-quia))
      ;; NO Preces — omitted in Triduum
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Christus factus est (secreto) + Pater noster + Ps 50
      (:rubric "[Secreto:]")
      (:text christus-factus)
      (:silent-prayers (pater-noster))
      (:psalm 50)
      ;; Concluding prayer (said silently)
      ,(bcp-roman-breviary--collect-step date)
      (:rubric "[Et sub silentio concluditur.]"))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Triduum Prime ordo builder
;;
;; During the Sacred Triduum, Prime uses Sunday psalms (Psalmi minores
;; Dominica) without antiphon, hymn, capitulum, responsory, or preces.
;; Concludes with Christus factus est.

(defun bcp-roman-breviary--prime-triduum-ordo (date)
  "Build Triduum Prime ordo for DATE.
Sunday psalms, no antiphon/hymn/capitulum/responsory/preces.
Ends with Christus factus est + Pater noster + Ps 50."
  (let* ((data (bcp-roman-psalterium-prime-psalms 0))  ; Sunday psalms
         (pss  (plist-get data :psalms)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; NO Hymn — omitted in Triduum
      ;; Psalmi (Sunday, no antiphon)
      ,@(mapcar (lambda (ps) `(:psalm ,ps :no-gloria t)) pss)
      ;; NO Capitulum, NO Responsory, NO Preces
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Christus factus est (secreto) + Pater noster + Ps 50
      (:rubric "[Secreto:]")
      (:text christus-factus)
      (:silent-prayers (pater-noster))
      (:psalm 50)
      ;; Concluding prayer (said silently)
      ,(bcp-roman-breviary--collect-step date)
      (:rubric "[Et sub silentio concluditur.]"))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Triduum minor hour ordo builder
;;
;; Terce, Sext, and None during the Sacred Triduum use Sunday psalms
;; (Psalmi minores Dominica) without antiphon (Minores sine Antiphona),
;; and omit hymn, capitulum, versicle, and preces.
;; Conclude with Christus factus est.

(defun bcp-roman-breviary--minor-hour-triduum-ordo (hour date)
  "Build Triduum minor HOUR ordo for DATE.
HOUR is terce, sext, or none.  Uses Sunday psalms, no antiphon/hymn/
capitulum/versicle/preces.  Ends with Christus factus est."
  (let* ((psalms-fn (pcase hour
                      ('terce #'bcp-roman-psalterium-terce-psalms)
                      ('sext  #'bcp-roman-psalterium-sext-psalms)
                      ('none  #'bcp-roman-psalterium-none-psalms)))
         (data      (funcall psalms-fn 0))  ; Sunday psalms
         (pss       (plist-get data :psalms)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; NO Hymn — omitted in Triduum
      ;; Psalmi (Sunday, no antiphon)
      ,@(mapcar (lambda (ps) `(:psalm ,ps :no-gloria t)) pss)
      ;; NO Capitulum, NO Versicle, NO Preces
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Christus factus est (secreto) + Pater noster + Ps 50
      (:rubric "[Secreto:]")
      (:text christus-factus)
      (:silent-prayers (pater-noster))
      (:psalm 50)
      ;; Concluding prayer (said silently)
      ,(bcp-roman-breviary--collect-step date)
      (:rubric "[Et sub silentio concluditur.]"))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Triduum Special Compline ordo builder
;;
;; The Sacred Triduum replaces standard Compline with a special form:
;; Confiteor, psalms (4, 30:1-6, 90, 133), "Christus factus est"
;; (in secret), Pater noster, Ps 50, concluding prayer (silent).
;; No hymn, capitulum, Nunc dimittis, or Marian antiphon.

(defun bcp-roman-breviary--compline-triduum-ordo (data)
  "Build Special Compline ordo for a Triduum day using DATA plist."
  `(;; Confiteor and penitential rite
    (:text confiteor)
    (:text misereatur)
    (:text indulgentiam)
    ;; Psalmi (no antiphon, no Gloria Patri)
    (:psalm 4 :no-gloria t)
    (:psalm (30 1 6) :no-gloria t)
    (:psalm 90 :no-gloria t)
    (:psalm 133 :no-gloria t)
    ;; Christus factus est (secreto)
    (:rubric "[Secreto:]")
    (:text christus-factus)
    ;; Pater noster (aliquantulum altius)
    (:silent-prayers (pater-noster))
    ;; Psalm 50 (Miserere)
    (:psalm 50)
    ;; Concluding prayer (silent)
    (:pre-oratio)
    (:collect respice-quaesumus-domine-super-hanc)
    (:rubric "[Et sub silentio concluditur.]")))

(defun bcp-roman-breviary--lauds-ordo (dow date)
  "Build Lauds ordo for day-of-week DOW (0-6) on DATE."
  (let* ((season  (bcp-roman-breviary--liturgical-season date))
         (penitential (and (> dow 0)
                          (memq season '(advent lent passiontide))))
         (psalms  (bcp-roman-psalterium-lauds-psalms dow penitential))
         (hymn    (bcp-roman-psalterium-lauds-hymn dow))
         (ben-ant (bcp-roman-psalterium-benedictus-antiphon dow))
         (sdata   (bcp-roman-breviary--season-hours-data-for dow date))
         (lauds-ants (plist-get sdata :lauds-antiphons))
         (ben-ant (or (plist-get sdata :benedictus-antiphon) ben-ant))
         ;; Override psalm antiphons with season-specific ones
         (psalms  (if lauds-ants
                      (cl-mapcar (lambda (ant ps) (cons ant (cdr ps)))
                                 lauds-ants psalms)
                    psalms))
         (omit-suffragium (memq season '(lent passiontide
                                         triduum-thu triduum-fri triduum-sat
                                         easter-sunday easter-octave eastertide))))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Psalmi cum Antiphonis (3 psalms + OT canticle + praise psalm)
      ,@(mapcar (lambda (pair)
                  `(:psalm ,(cdr pair) :antiphon ,(car pair)))
                psalms)
      ;; Capitulum
      (:capitulum lauds-capitulum)
      ;; Hymnus
      (:hymn ,hymn)
      ;; Versus
      (:versicles lauds-versicle)
      ;; Canticum: Benedictus
      (:canticle benedictus :antiphon ,(or ben-ant 'benedictus-dominus-deus-israel))
      ;; Preces feriales
      (:preces preces-feriales-major)
      (:psalm 129)
      (:preces preces-feriales-major-coda)
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Commemoratio (displaced feast collect)
      ,@(bcp-roman-breviary--commemoration-steps date)
      ;; Suffragium sanctorum (omitted in Lent, Eastertide, etc.)
      ,@(unless omit-suffragium '((:suffragium)))
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-breviary--prime-ordo (dow date)
  "Build Prime ordo for day-of-week DOW (0-6) on DATE."
  (let* ((data   (bcp-roman-psalterium-prime-psalms dow))
         (ant    (plist-get data :antiphon))
         (pss    (plist-get data :psalms))
         (sdata  (bcp-roman-breviary--season-hours-data-for dow date))
         (ant    (or (plist-get sdata :prime-antiphon) ant)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Hymnus
      (:hymn jam-lucis-orto-sidere)
      ;; Psalmi
      (:antiphon ,ant)
      ,@(mapcar (lambda (ps) `(:psalm ,ps)) pss)
      (:antiphon ,ant :repeat t)
      ;; Capitulum
      (:capitulum prime-capitulum)
      ;; Responsorium breve
      (:versicles prime-versicle)
      ;; Preces feriales
      (:rubric "[Confíteor... Misereátur... Indulgéntiam...]")
      (:preces preces-feriales-prime)
      ;; Martyrologium
      (:rubric "[Martyrológium]")
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-breviary--minor-hour-ordo (dow hour date)
  "Build minor hour ordo for DOW (0-6) and HOUR (terce/sext/none) on DATE."
  (let* ((psalms-fn (pcase hour
                      ('terce #'bcp-roman-psalterium-terce-psalms)
                      ('sext  #'bcp-roman-psalterium-sext-psalms)
                      ('none  #'bcp-roman-psalterium-none-psalms)))
         (data      (funcall psalms-fn dow))
         (ant       (plist-get data :antiphon))
         (pss       (plist-get data :psalms))
         (sdata     (bcp-roman-breviary--season-hours-data-for dow date))
         (ant-key   (pcase hour
                      ('terce :terce-antiphon)
                      ('sext  :sext-antiphon)
                      ('none  :none-antiphon)))
         (ant       (or (plist-get sdata ant-key) ant))
         (hymn-key  (pcase hour
                      ('terce 'nunc-sancte-nobis-spiritus)
                      ('sext  'rector-potens-verax-deus)
                      ('none  'rerum-deus-tenax-vigor)))
         (cap-key   (pcase hour
                      ('terce 'terce-capitulum)
                      ('sext  'sext-capitulum)
                      ('none  'none-capitulum)))
         (vers-key  (pcase hour
                      ('terce 'terce-versicle)
                      ('sext  'sext-versicle)
                      ('none  'none-versicle))))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Hymnus
      (:hymn ,hymn-key)
      ;; Psalmi
      (:antiphon ,ant)
      ,@(mapcar (lambda (ps) `(:psalm ,ps)) pss)
      (:antiphon ,ant :repeat t)
      ;; Capitulum
      (:capitulum ,cap-key)
      ;; Versus
      (:versicles ,vers-key)
      ;; Preces feriales
      (:preces preces-feriales-minor)
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-breviary--ferial-matins-data (date)
  "Return ferial Matins lesson data for DATE, or nil.
Dispatches to the appropriate season-specific function.
Returns a plist with :lessons and :responsories when proper
ferial lessons are available."
  (let ((season (bcp-roman-breviary--liturgical-season date)))
    (pcase season
      ('advent (bcp-roman-season-advent-ferial-matins date))
      ((or 'lent 'passiontide)
       (bcp-roman-season-lent-ferial-matins date))
      ((or 'easter-octave 'eastertide)
       (bcp-roman-season-easter-ferial-matins date))
      ('christmastide
       (bcp-roman-season-christmas-ferial-matins date))
      ('per-annum
       (bcp-roman-tempora-ferial-matins date))
      (_ nil))))

(defun bcp-roman-breviary--matins-ordo (dow date)
  "Build ferial Matins ordo for day-of-week DOW (1-6) on DATE.
Uses the DA 1911 cursus: 1 nocturn, 9 psalms each under its own antiphon.
When proper ferial lessons are available (e.g. Advent), inserts absolutio,
3 benedictions, 3 lessons, and 3 responsories instead of lectio brevis."
  (let ((psalms   (bcp-roman-psalterium-matins-psalms dow))
        (invit    (bcp-roman-psalterium-invitatory-antiphon dow))
        (hymn     (bcp-roman-psalterium-matins-hymn dow))
        (has-lessons (bcp-roman-breviary--ferial-matins-data date)))
    `(;; Preparatory prayers (silent)
      (:silent-prayers (pater-noster ave-maria credo))
      ;; Incipit
      (:incipit)
      ;; Invitatorium: antiphon + Ps 94 (Venite)
      (:invitatory ,invit)
      ;; Hymnus
      (:hymn ,hymn)
      ;; Psalmi cum Antiphonis (9 psalms, each under its own antiphon)
      ,@(cl-loop for (ant . ps) in psalms
                 collect `(:antiphon ,ant)
                 collect `(:psalm ,ps)
                 collect `(:antiphon ,ant :repeat t))
      ;; Versus
      (:versicles matins-versicle)
      ;; Lessons or lectio brevis
      ,@(if has-lessons
            ;; Proper ferial lessons: absolutio + 3x (benedictio, lesson, responsory)
            ;; On Te Deum days (Easter/Pentecost octave), R3 is nil — emit Te Deum instead
            (let ((te-deum-p (not (nth 2 (plist-get has-lessons :responsories)))))
              `((:silent-prayers (pater-noster))
                (:lesson-absolutio 0)
                (:lesson-benedictio matins-benedictiones-nocturn-1 0)
                (:lesson matins-lesson-1)
                (:responsory matins-responsory-1)
                (:lesson-benedictio matins-benedictiones-nocturn-1 1)
                (:lesson matins-lesson-2)
                (:responsory matins-responsory-2)
                (:lesson-benedictio matins-benedictiones-nocturn-1 2)
                (:lesson matins-lesson-3)
                ,@(if te-deum-p
                      '((:te-deum))
                    '((:responsory matins-responsory-3)))))
          `((:lectio-brevis matins-lectio-brevis)))
      ;; Capitulum et Versus
      (:capitulum matins-capitulum)
      (:versicles matins-capitulum-versicle)
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-breviary--matins-dominical-nocturn
    (n lesson-offset bene-key &optional no-te-deum)
  "Build ordo steps for dominical Matins nocturn N (1-3).
LESSON-OFFSET is the 0-based offset for the first lesson in this nocturn
\(0 for Nocturn I, 3 for II, 6 for III\).
BENE-KEY is the resolver key for the benedictions list.
When NO-TE-DEUM is non-nil, nocturn III ends with R9 instead of Te Deum
\(Lent, Advent, penitential seasons\)."
  (let ((psalms (bcp-roman-psalterium-matins-dominical-nocturn n)))
    `(;; Psalmi cum Antiphonis (3 psalms, each under its own antiphon)
      ,@(cl-loop for (ant . ps) in psalms
                 collect `(:antiphon ,ant)
                 collect `(:psalm ,ps)
                 collect `(:antiphon ,ant :repeat t))
      ;; Versus post Nocturnum
      (:nocturn-versicle ,(intern (format "matins-dominical-versicle-%d" n)))
      ;; Pater noster (secreto)
      (:silent-prayers (pater-noster))
      ;; Absolutio
      (:lesson-absolutio ,(1- n))
      ;; Three lessons with benedictions and responsories
      (:lesson-benedictio ,bene-key 0)
      (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 1))))
      (:responsory ,(intern (format "matins-responsory-%d" (+ lesson-offset 1))))
      (:lesson-benedictio ,bene-key 1)
      (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 2))))
      (:responsory ,(intern (format "matins-responsory-%d" (+ lesson-offset 2))))
      (:lesson-benedictio ,bene-key 2)
      (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 3))))
      ;; After the last lesson: responsory or Te Deum
      ,@(if (and (= n 3) (not no-te-deum))
            '((:te-deum))
          `((:responsory ,(intern (format "matins-responsory-%d"
                                          (+ lesson-offset 3)))))))))

(defun bcp-roman-breviary--matins-1nocturn-ordo (date data)
  "Build a 1-nocturn dominical Matins ordo for DATE using DATA.
DATA is a plist with :one-nocturn, :invitatory, :hymn, :psalms,
:versicle/:versicle-en, :lessons (3), and :responsories (2).
Used for Easter Sunday and Pentecost."
  (let ((invit  (plist-get data :invitatory))
        (hymn   (plist-get data :hymn))
        (psalms (plist-get data :psalms)))
    `(;; Preparatory prayers (silent)
      (:silent-prayers (pater-noster ave-maria credo))
      ;; Incipit
      (:incipit)
      ;; Invitatorium: antiphon + Ps 94 (Venite)
      (:invitatory ,invit)
      ;; Hymnus
      (:hymn ,hymn)
      ;; ── Single Nocturn ──
      ;; Psalmi cum Antiphonis (3 psalms, each under its own antiphon)
      ,@(cl-loop for (ant . ps) in psalms
                 collect `(:antiphon ,ant)
                 collect `(:psalm ,ps)
                 collect `(:antiphon ,ant :repeat t))
      ;; Versus post Nocturnum
      (:nocturn-versicle matins-1nocturn-versicle)
      ;; Pater noster (secreto)
      (:silent-prayers (pater-noster))
      ;; Absolutio
      (:lesson-absolutio 0)
      ;; Three lessons with benedictions and responsories
      (:lesson-benedictio matins-benedictiones-nocturn-1 0)
      (:lesson matins-lesson-1)
      (:responsory matins-responsory-1)
      (:lesson-benedictio matins-benedictiones-nocturn-1 1)
      (:lesson matins-lesson-2)
      (:responsory matins-responsory-2)
      (:lesson-benedictio matins-benedictiones-nocturn-1 2)
      (:lesson matins-lesson-3)
      ;; Te Deum after 3rd lesson
      (:te-deum)
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-breviary--matins-feast-nocturn (n lesson-offset bene-key psalms)
  "Build ordo steps for feast Matins nocturn N (1-3).
LESSON-OFFSET is the 0-based offset for the first lesson (0, 3, or 6).
BENE-KEY is the resolver key for the benedictions list.
PSALMS is a list of (ANTIPHON . PSALM-NUMBER) pairs for this nocturn."
  `(;; Psalmi cum Antiphonis
    ,@(cl-loop for (ant . ps) in psalms
               collect `(:antiphon ,ant)
               collect `(:psalm ,ps)
               collect `(:antiphon ,ant :repeat t))
    ;; Versus post Nocturnum
    (:nocturn-versicle ,(intern (format "matins-feast-versicle-%d" n)))
    ;; Pater noster (secreto)
    (:silent-prayers (pater-noster))
    ;; Absolutio
    (:lesson-absolutio ,(1- n))
    ;; Three lessons with benedictions and responsories
    (:lesson-benedictio ,bene-key 0)
    (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 1))))
    (:responsory ,(intern (format "matins-responsory-%d" (+ lesson-offset 1))))
    (:lesson-benedictio ,bene-key 1)
    (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 2))))
    (:responsory ,(intern (format "matins-responsory-%d" (+ lesson-offset 2))))
    (:lesson-benedictio ,bene-key 2)
    (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 3))))
    ;; After the last lesson: responsory or Te Deum
    ,@(if (= n 3)
          '((:te-deum))
        `((:responsory ,(intern (format "matins-responsory-%d"
                                        (+ lesson-offset 3))))))))

(defun bcp-roman-breviary--matins-feast-ordo (date data)
  "Build a feast-grade 3-nocturn Matins ordo for DATE using DATA.
DATA is a plist with :invitatory, :hymn, :psalms-1/:psalms-2/:psalms-3
\(each a list of (ANT . PS) pairs), and optionally :omit-invitatory."
  (let ((invit  (plist-get data :invitatory))
        (hymn   (plist-get data :hymn))
        (omit   (plist-get data :omit-invitatory)))
    `(;; Preparatory prayers (silent)
      (:silent-prayers (pater-noster ave-maria credo))
      ;; Incipit
      (:incipit)
      ;; Invitatorium (may be omitted, e.g., Epiphany)
      ,@(unless omit `((:invitatory ,invit)))
      ;; Hymnus (may be omitted, e.g., Epiphany)
      ,@(unless omit `((:hymn ,hymn)))
      ;; ── Nocturn I ──
      ,@(bcp-roman-breviary--matins-feast-nocturn
         1 0 'matins-benedictiones-nocturn-1
         (plist-get data :psalms-1))
      ;; ── Nocturn II ──
      ,@(bcp-roman-breviary--matins-feast-nocturn
         2 3 'matins-benedictiones-nocturn-2
         (plist-get data :psalms-2))
      ;; ── Nocturn III ──
      ,@(bcp-roman-breviary--matins-feast-nocturn
         3 6 'matins-benedictiones-nocturn-3
         (plist-get data :psalms-3))
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-breviary--matins-dominical-ordo (date)
  "Build dominical (Sunday) Matins ordo for DATE.
Checks for 1-nocturn special offices (Easter Sunday, Pentecost);
otherwise builds 3 nocturns of 3 psalms each, with 9 lessons."
  (let* ((season (bcp-roman-breviary--liturgical-season date))
         (data (pcase season
                 ((or 'easter-sunday 'easter-octave 'eastertide)
                  (bcp-roman-season-easter-dominical-matins date))
                 (_ nil))))
    (if (and data (plist-get data :one-nocturn))
        (bcp-roman-breviary--matins-1nocturn-ordo date data)
      (let* ((invit (bcp-roman-psalterium-invitatory-antiphon 0))
             (hymn  (bcp-roman-psalterium-matins-hymn 0))
             (no-td (memq season '(advent lent passiontide lent-holy-week))))
        `(;; Preparatory prayers (silent)
          (:silent-prayers (pater-noster ave-maria credo))
          ;; Incipit
          (:incipit)
          ;; Invitatorium: antiphon + Ps 94 (Venite)
          (:invitatory ,invit)
          ;; Hymnus
          (:hymn ,hymn)
          ;; ── Nocturn I ──
          ,@(bcp-roman-breviary--matins-dominical-nocturn
             1 0 'matins-benedictiones-nocturn-1)
          ;; ── Nocturn II ──
          ,@(bcp-roman-breviary--matins-dominical-nocturn
             2 3 'matins-benedictiones-nocturn-2)
          ;; ── Nocturn III ──
          ,@(bcp-roman-breviary--matins-dominical-nocturn
             3 6 'matins-benedictiones-nocturn-3 no-td)
          ;; Oratio
          (:pre-oratio)
          ,(bcp-roman-breviary--collect-step date)
          ;; Conclusio
          (:conclusio))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Tenebrae ordo builder

(defun bcp-roman-breviary--matins-tenebrae-nocturn (n psalms versicle-key)
  "Build ordo steps for Tenebrae nocturn N (1-3).
PSALMS is a list of 3 (ANTIPHON . PSALM-NUMBER) pairs.
VERSICLE-KEY is the resolver key for the nocturn versicle.
Unlike regular Matins, there is no Gloria Patri after psalms."
  (let ((lesson-offset (* (1- n) 3)))
    `(;; Psalmi cum Antiphonis (3 psalms, each under its own antiphon)
      ,@(cl-loop for (ant . ps) in psalms
                 collect `(:antiphon ,ant)
                 collect `(:psalm ,ps :no-gloria t)
                 collect `(:antiphon ,ant :repeat t))
      ;; Versus post Nocturnum
      (:nocturn-versicle ,versicle-key)
      ;; Pater noster (secreto)
      (:silent-prayers (pater-noster))
      ;; Absolutio
      (:lesson-absolutio ,(1- n))
      ;; Three lessons with benedictions and responsories
      (:lesson-benedictio ,(intern (format "matins-benedictiones-nocturn-%d" n)) 0)
      (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 1))))
      (:responsory ,(intern (format "matins-responsory-%d" (+ lesson-offset 1))))
      (:lesson-benedictio ,(intern (format "matins-benedictiones-nocturn-%d" n)) 1)
      (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 2))))
      (:responsory ,(intern (format "matins-responsory-%d" (+ lesson-offset 2))))
      (:lesson-benedictio ,(intern (format "matins-benedictiones-nocturn-%d" n)) 2)
      (:lesson ,(intern (format "matins-lesson-%d" (+ lesson-offset 3))))
      ;; Every nocturn ends with a responsory (no Te Deum in Tenebrae)
      (:responsory ,(intern (format "matins-responsory-%d" (+ lesson-offset 3)))))))

(defun bcp-roman-breviary--matins-tenebrae-ordo (date data)
  "Build Tenebrae Matins ordo for DATE using Triduum DATA plist.
Tenebrae omits incipit, invitatory, hymn, and Gloria Patri after psalms.
Uses 9 proper psalms under 9 individual antiphons from DATA."
  (let* ((psalms (plist-get data :psalms))
         (ps1 (seq-take psalms 3))
         (ps2 (seq-subseq psalms 3 6))
         (ps3 (seq-subseq psalms 6 9)))
    `(;; Preparatory prayers (silent)
      (:silent-prayers (pater-noster ave-maria credo))
      ;; NO incipit, NO invitatory, NO hymn
      ;; ── Nocturn I ──
      ,@(bcp-roman-breviary--matins-tenebrae-nocturn
         1 ps1 'tenebrae-versicle-1)
      ;; ── Nocturn II ──
      ,@(bcp-roman-breviary--matins-tenebrae-nocturn
         2 ps2 'tenebrae-versicle-2)
      ;; ── Nocturn III ──
      ,@(bcp-roman-breviary--matins-tenebrae-nocturn
         3 ps3 'tenebrae-versicle-3)
      ;; NO Te Deum — Tenebrae ends with R9
      ;; Oratio (said silently)
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Holy Week weekday ordo builder

(defun bcp-roman-breviary--matins-holyweek-weekday-ordo (dow date data)
  "Build Holy Week weekday Matins ordo for DOW on DATE using DATA plist.
Mon–Wed of Holy Week: ferial structure with 3 proper lessons + responsories.
Psalms come from the weekly psalterium (standard ferial cursus)."
  (let ((psalms   (bcp-roman-psalterium-matins-psalms dow))
        (invit    (bcp-roman-psalterium-invitatory-antiphon dow))
        (hymn     (bcp-roman-psalterium-matins-hymn dow)))
    `(;; Preparatory prayers (silent)
      (:silent-prayers (pater-noster ave-maria credo))
      ;; Incipit
      (:incipit)
      ;; Invitatorium: antiphon + Ps 94 (Venite)
      (:invitatory ,invit)
      ;; Hymnus
      (:hymn ,hymn)
      ;; Psalmi cum Antiphonis (9 psalms, each under its own antiphon)
      ,@(cl-loop for (ant . ps) in psalms
                 collect `(:antiphon ,ant)
                 collect `(:psalm ,ps)
                 collect `(:antiphon ,ant :repeat t))
      ;; Versus
      (:versicles matins-versicle)
      ;; Pater noster (secreto)
      (:silent-prayers (pater-noster))
      ;; Absolutio
      (:lesson-absolutio 0)
      ;; Three lessons with benedictions and responsories
      (:lesson-benedictio matins-benedictiones-nocturn-1 0)
      (:lesson matins-lesson-1)
      (:responsory matins-responsory-1)
      (:lesson-benedictio matins-benedictiones-nocturn-1 1)
      (:lesson matins-lesson-2)
      (:responsory matins-responsory-2)
      (:lesson-benedictio matins-benedictiones-nocturn-1 2)
      (:lesson matins-lesson-3)
      ;; R3 with Gloria (no Te Deum in Lent/Passiontide)
      (:responsory matins-responsory-3)
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Holy Week data resolver

(defun bcp-roman-breviary--holyweek-resolver (data)
  "Return a resolver closure that resolves keys from Holy Week DATA plist.
Handles matins-lesson-N, matins-responsory-N, and tenebrae-versicle-N.
Falls back to the default resolver for all other keys."
  (lambda (key)
    (let ((name (and (symbolp key) (symbol-name key))))
      (cond
       ;; ── Lessons ──
       ((and name (string-match "\\`matins-lesson-\\([0-9]+\\)\\'" name))
        (let ((lesson (nth (1- (string-to-number (match-string 1 name)))
                           (plist-get data :lessons))))
          ;; Swap in English text if available and language is English
          (if (and (eq bcp-roman-office-language 'english)
                   (plist-get lesson :text-en))
              (plist-put (copy-sequence lesson) :text
                         (plist-get lesson :text-en))
            lesson)))
       ;; ── Responsories ──
       ((and name (string-match "\\`matins-responsory-\\([0-9]+\\)\\'" name))
        (let ((resp (nth (1- (string-to-number (match-string 1 name)))
                         (plist-get data :responsories))))
          ;; Swap in English text if available
          (if (and (eq bcp-roman-office-language 'english)
                   (plist-get resp :respond-en))
              (let ((r (copy-sequence resp)))
                (setq r (plist-put r :respond (plist-get r :respond-en)))
                (setq r (plist-put r :verse (plist-get r :verse-en)))
                (setq r (plist-put r :repeat (plist-get r :repeat-en)))
                r)
            resp)))
       ;; ── Tenebrae nocturn versicles ──
       ((and name (string-match "\\`tenebrae-versicle-\\([1-3]\\)\\'" name))
        (let* ((n (string-to-number (match-string 1 name)))
               (vkey (intern (format ":versicle-%d" n)))
               (vkey-en (intern (format ":versicle-%d-en" n)))
               (pair (if (eq bcp-roman-office-language 'english)
                         (or (plist-get data vkey-en) (plist-get data vkey))
                       (plist-get data vkey))))
          ;; Convert cons pair ("V" . "R") to list ("V" "R")
          (when pair (list (car pair) (cdr pair)))))
       ;; ── Lauds versicle (Triduum proper) ──
       ((eq key 'lauds-versicle)
        (let ((pair (if (eq bcp-roman-office-language 'english)
                        (or (plist-get data :lauds-versicle-en)
                            (plist-get data :lauds-versicle))
                      (plist-get data :lauds-versicle))))
          (if pair
              (list (car pair) (cdr pair))
            ;; Fall back to default resolver if no proper versicle
            (bcp-roman-breviary--resolve key))))
       ;; ── Christus factus est (Triduum concluding versicle) ──
       ((eq key 'christus-factus)
        (let ((text (if (eq bcp-roman-office-language 'english)
                        (or (plist-get data :christus-factus-en)
                            (plist-get data :christus-factus))
                      (plist-get data :christus-factus))))
          text))
       ;; ── Everything else: default resolver ──
       (t (bcp-roman-breviary--resolve key))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Resolver (data-fn)
;;
;; Maps symbolic keys from ordo steps to actual text/data.
;; Registry incipits (antiphons, hymns, collects) are resolved via
;; a fallback chain; fixed liturgical texts via bcp-common-roman.

(defvar bcp-roman-breviary--current-dow 1
  "Day-of-week for the current render pass (0=Sunday..6=Saturday).
Let-bound in `bcp-roman-breviary--render-hour'.")

(defvar bcp-roman-breviary--current-date nil
  "Date for the current render pass, (MONTH DAY YEAR).
Let-bound in `bcp-roman-breviary--render-hour'.")

(defun bcp-roman-breviary--season-hours-data-for (dow date)
  "Return non-Matins hour data for DOW on DATE, or nil.
Returns data on Sundays (DOW=0) and Holy Week weekdays (Mon–Wed)."
  (let ((season (bcp-roman-breviary--liturgical-season date)))
    (cond
     ;; Holy Week weekdays (Mon–Wed): proper antiphons
     ((and (memq dow '(1 2 3))
           (eq season 'passiontide)
           (bcp-roman-season-holyweek-hours date)))
     ;; Sundays: seasonal antiphon overrides
     ((= dow 0)
      (pcase season
        ('advent
         (bcp-roman-season-advent-dominical-hours date))
        ((or 'lent 'passiontide)
         (bcp-roman-season-lent-dominical-hours date))
        ((or 'easter-sunday 'easter-octave 'eastertide)
         (bcp-roman-season-easter-dominical-hours date))
        ('christmastide
         (bcp-roman-season-christmas-dominical-hours date))
        (_ nil))))))

(defun bcp-roman-breviary--season-hours-data ()
  "Return non-Matins hour data for the current Sunday, or nil.
Uses `bcp-roman-breviary--current-dow' and `bcp-roman-breviary--current-date'."
  (bcp-roman-breviary--season-hours-data-for
   bcp-roman-breviary--current-dow
   bcp-roman-breviary--current-date))

(defun bcp-roman-breviary--capitulum-from-season (key)
  "If season data has a capitulary symbol for KEY, build a capitulum plist.
Returns (:ref REF :text LATIN :text-en ENGLISH) or nil."
  (let* ((data (bcp-roman-breviary--season-hours-data))
         (sym (and data (plist-get data key))))
    (when sym
      (let ((latin (bcp-roman-capitulary-latin sym)))
        (when latin
          (list :ref (bcp-roman-capitulary-ref sym)
                :text latin
                :text-en (bcp-roman-capitulary-english sym)))))))

(defun bcp-roman-breviary--resolve (key)
  "Resolve data KEY for the ferial Breviary.
Returns the appropriate text, plist, or data structure."
  (let ((lang bcp-roman-office-language)
        (variant (if (= bcp-roman-breviary--current-dow 0) :dominical :ferial)))
    (pcase key
      ;; ── Capitula (return plist with :ref and :text) ──
      ('vespers-capitulum
       (or (bcp-roman-breviary--capitulum-from-season :vespers-capitulum)
           bcp-roman-psalterium--vespers-capitulum))
      ('compline-capitulum bcp-roman-psalterium--compline-capitulum)
      ('lauds-capitulum
       (or (bcp-roman-breviary--capitulum-from-season :lauds-capitulum)
           bcp-roman-psalterium--lauds-capitulum))
      ('prime-capitulum    bcp-roman-psalterium--prime-capitulum)
      ('terce-capitulum
       (or (bcp-roman-breviary--capitulum-from-season :terce-capitulum)
           (plist-get bcp-roman-psalterium--terce-capitulum variant)))
      ('sext-capitulum
       (or (bcp-roman-breviary--capitulum-from-season :sext-capitulum)
           (plist-get bcp-roman-psalterium--sext-capitulum variant)))
      ('none-capitulum
       (or (bcp-roman-breviary--capitulum-from-season :none-capitulum)
           (plist-get bcp-roman-psalterium--none-capitulum variant)))
      ('matins-capitulum   bcp-roman-psalterium--matins-capitulum)

      ;; ── Versicles (return pair of strings) ──
      ('vespers-versicle   bcp-roman-psalterium--vespers-versicle)
      ('compline-versicle  bcp-roman-psalterium--compline-versicle)
      ('lauds-versicle     bcp-roman-psalterium--lauds-versicle)
      ('prime-versicle     bcp-roman-psalterium--prime-versicle)
      ('terce-versicle     (plist-get bcp-roman-psalterium--terce-versicle
                                      variant))
      ('sext-versicle      bcp-roman-psalterium--sext-versicle)
      ('none-versicle      bcp-roman-psalterium--none-versicle)
      ('matins-versicle    (if (eq lang 'english)
                               (bcp-roman-psalterium-matins-versicle-en
                                bcp-roman-breviary--current-dow)
                             (bcp-roman-psalterium-matins-versicle
                              bcp-roman-breviary--current-dow)))
      ('matins-capitulum-versicle
       (if (eq lang 'english)
           bcp-roman-psalterium--matins-capitulum-versicle-en
         bcp-roman-psalterium--matins-capitulum-versicle))

      ;; ── Lectio brevis (return plist with :ref, :text, :responsory) ──
      ('matins-lectio-brevis
       (if (eq lang 'english)
           (bcp-roman-psalterium-matins-lectio-brevis-en
            bcp-roman-breviary--current-dow)
         (bcp-roman-psalterium-matins-lectio-brevis
          bcp-roman-breviary--current-dow)))

      ;; ── Dominical Matins: nocturn versicles ──
      ('matins-dominical-versicle-1
       (bcp-roman-psalterium-matins-dominical-versicle 1 (eq lang 'english)))
      ('matins-dominical-versicle-2
       (bcp-roman-psalterium-matins-dominical-versicle 2 (eq lang 'english)))
      ('matins-dominical-versicle-3
       (bcp-roman-psalterium-matins-dominical-versicle 3 (eq lang 'english)))

      ;; ── 1-nocturn Matins: versicle from season data ──
      ('matins-1nocturn-versicle
       (let* ((season (bcp-roman-breviary--liturgical-season
                       bcp-roman-breviary--current-date))
              (data (pcase season
                      ((or 'easter-sunday 'easter-octave 'eastertide)
                       (bcp-roman-season-easter-dominical-matins
                        bcp-roman-breviary--current-date))
                      (_ nil))))
         (when data
           (plist-get data (if (eq lang 'english) :versicle-en :versicle)))))

      ;; ── Feast Matins: nocturn versicles from feast data ──
      ((and (pred symbolp)
            (let name (symbol-name key))
            (guard (string-match "\\`matins-feast-versicle-\\([1-3]\\)\\'" name)))
       (let* ((n (string-to-number (match-string 1 name)))
              (feast-data (bcp-roman-breviary--feast-matins-data
                           bcp-roman-breviary--current-date))
              (vkey (if (eq lang 'english)
                        (intern (format ":versicle-%d-en" n))
                      (intern (format ":versicle-%d" n)))))
         (when feast-data
           (plist-get feast-data vkey))))

      ;; ── Dominical Matins: benedictions (return list of 3 strings) ──
      ('matins-benedictiones-nocturn-1
       (if (eq lang 'english) bcp-roman-benedictiones-nocturn-1-en
         bcp-roman-benedictiones-nocturn-1))
      ('matins-benedictiones-nocturn-2
       (if (eq lang 'english) bcp-roman-benedictiones-nocturn-2-en
         bcp-roman-benedictiones-nocturn-2))
      ('matins-benedictiones-nocturn-3
       (if (eq lang 'english) bcp-roman-benedictiones-nocturn-3-dominical-en
         bcp-roman-benedictiones-nocturn-3-dominical))

      ;; ── Matins: lessons (return plist with :ref, :text, etc.) ──
      ;; Used by dominical, ferial, and feast-grade Matins.
      ((and (pred symbolp)
            (let name (symbol-name key))
            (guard (string-match "\\`matins-lesson-\\([0-9]+\\)\\'" name)))
       (let* ((n (string-to-number (match-string 1 name)))
              (feast-data (bcp-roman-breviary--feast-matins-data
                           bcp-roman-breviary--current-date))
              (data (or feast-data
                        (bcp-roman-breviary--ferial-matins-data
                         bcp-roman-breviary--current-date)
                        (let ((season (bcp-roman-breviary--liturgical-season
                                       bcp-roman-breviary--current-date)))
                          (pcase season
                            ((or 'lent 'passiontide)
                             (bcp-roman-season-lent-dominical-matins
                              bcp-roman-breviary--current-date))
                            ((or 'easter-sunday 'easter-octave 'eastertide)
                             (bcp-roman-season-easter-dominical-matins
                              bcp-roman-breviary--current-date))
                            ('advent
                             (bcp-roman-season-advent-dominical-matins
                              bcp-roman-breviary--current-date))
                            ('christmastide
                             (bcp-roman-season-christmas-dominical-matins
                              bcp-roman-breviary--current-date))
                            (_ (bcp-roman-tempora-dominical-matins
                                bcp-roman-breviary--current-date))))))
              (lessons (plist-get data :lessons)))
         (nth (1- n) lessons)))

      ;; ── Matins: responsories (return plist with :respond, :verse, :repeat) ──
      ;; Used by dominical, ferial, and feast-grade Matins.
      ((and (pred symbolp)
            (let name (symbol-name key))
            (guard (string-match "\\`matins-responsory-\\([0-9]+\\)\\'" name)))
       (let* ((n (string-to-number (match-string 1 name)))
              (feast-data (bcp-roman-breviary--feast-matins-data
                           bcp-roman-breviary--current-date))
              (data (or feast-data
                        (bcp-roman-breviary--ferial-matins-data
                         bcp-roman-breviary--current-date)
                        (let ((season (bcp-roman-breviary--liturgical-season
                                       bcp-roman-breviary--current-date)))
                          (pcase season
                            ((or 'lent 'passiontide)
                             (bcp-roman-season-lent-dominical-matins
                              bcp-roman-breviary--current-date))
                            ((or 'easter-sunday 'easter-octave 'eastertide)
                             (bcp-roman-season-easter-dominical-matins
                              bcp-roman-breviary--current-date))
                            ('advent
                             (bcp-roman-season-advent-dominical-matins
                              bcp-roman-breviary--current-date))
                            ('christmastide
                             (bcp-roman-season-christmas-dominical-matins
                              bcp-roman-breviary--current-date))
                            (_ (bcp-roman-tempora-dominical-matins
                                bcp-roman-breviary--current-date))))))
              (resps (plist-get data :responsories)))
         (nth (1- n) resps)))

      ;; ── Preces (return list of (V R) pairs) ──
      ('preces-feriales-major
       (if (eq lang 'english) bcp-roman-psalterium--preces-feriales-major-en
         bcp-roman-psalterium--preces-feriales-major))
      ('preces-feriales-major-coda
       (if (eq lang 'english) bcp-roman-psalterium--preces-feriales-major-coda-en
         bcp-roman-psalterium--preces-feriales-major-coda))
      ('preces-feriales-prime
       (if (eq lang 'english) bcp-roman-psalterium--preces-feriales-prime-en
         bcp-roman-psalterium--preces-feriales-prime))
      ('preces-feriales-minor
       (if (eq lang 'english) bcp-roman-psalterium--preces-feriales-minor-en
         bcp-roman-psalterium--preces-feriales-minor))

      ;; ── Canticles (return plist with :name, :ref, :canticle-key, :text) ──
      ('magnificat         bcp-roman-breviary--magnificat)
      ('nunc-dimittis      bcp-roman-breviary--nunc-dimittis)
      ('benedictus         bcp-roman-breviary--benedictus)

      ;; ── Structural texts from bcp-common-roman.el ──
      ('confiteor           bcp-roman-confiteor)
      ('misereatur          bcp-roman-misereatur)
      ('indulgentiam        bcp-roman-indulgentiam)
      ('jube-domne
       (if (eq lang 'english) (bcp-roman-jube-domne-en) (bcp-roman-jube-domne)))
      ('benedictio-compline
       (if (eq lang 'english) bcp-roman-benedictio-compline-en
         bcp-roman-benedictio-compline))
      ('ave-maria           bcp-roman-ave-maria)
      ('converte-nos
       (if (eq lang 'english) bcp-roman-converte-nos-en bcp-roman-converte-nos))
      ('divinum-auxilium
       (if (eq lang 'english) bcp-roman-divinum-auxilium-en bcp-roman-divinum-auxilium))
      ('pater-noster
       (plist-get bcp-common-prayers-lords-prayer
                  (if (eq lang 'english) :english :latin)))
      ('credo
       (plist-get bcp-common-prayers-apostles-creed
                  (if (eq lang 'english) :english :latin)))

      ;; ── Registry fallback: antiphonary → hymnal → collectarium → capitulary ──
      (_
       (or (bcp-roman-antiphonary-get key lang)
           (bcp-roman-hymnal-get key lang)
           (bcp-roman-collectarium-get key lang)
           (bcp-roman-capitulary-get key lang)
           (error "Unknown Breviary data key: %s" key))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Liturgical season detection

(defun bcp-roman-breviary--liturgical-season (date)
  "Return the liturgical season symbol for DATE.
DATE is a Gregorian date (MONTH DAY YEAR).
Returns one of:
  lent          — Ash Wednesday through day before Passion Sunday
  passiontide   — Passion Sunday through Wednesday of Holy Week
  triduum-thu   — Maundy Thursday (Easter - 3)
  triduum-fri   — Good Friday (Easter - 2)
  triduum-sat   — Holy Saturday (Easter - 1)
  easter-sunday — Easter Day
  easter-octave — Monday through Saturday of Easter week
  eastertide    — Low Sunday through Saturday after Pentecost
  advent        — Advent I through December 24
  christmastide — December 25 through Saturday before Septuagesima
  per-annum     — everything else"
  (let* ((year (caddr date))
         (month (car date))
         (day (cadr date))
         (feasts (bcp-moveable-feasts year))
         (easter (cdr (assq 'easter feasts)))
         (easter-abs (calendar-absolute-from-gregorian easter))
         (ash-abs (calendar-absolute-from-gregorian
                   (cdr (assq 'ash-wednesday feasts))))
         (abs (calendar-absolute-from-gregorian date))
         (diff (- abs easter-abs)))
    (cond
     ;; Triduum: the three sacred days before Easter
     ((= diff -3) 'triduum-thu)
     ((= diff -2) 'triduum-fri)
     ((= diff -1) 'triduum-sat)
     ;; Easter Sunday
     ((= diff 0) 'easter-sunday)
     ;; Easter Octave: Mon-Sat after Easter
     ((<= 1 diff 6) 'easter-octave)
     ;; Eastertide: Low Sunday through Saturday after Pentecost
     ((<= 7 diff 55) 'eastertide)
     ;; Passiontide: Passion Sunday (Easter - 14) through Wed of Holy Week
     ((<= -17 diff -4) 'passiontide)
     ;; Lent: Ash Wednesday through day before Passion Sunday first vespers
     ((<= ash-abs abs (+ easter-abs -18)) 'lent)
     ;; Advent: Advent I through December 24
     ((let ((adv1-abs (calendar-absolute-from-gregorian (bcp-advent-1 year))))
        (and (>= abs adv1-abs)
             (or (< month 12)  ; Jan-Nov can't be Advent (adv1 is Nov 27-Dec 3)
                 (<= day 24))))
      'advent)
     ;; Christmastide: Dec 25 through Saturday before Septuagesima
     ;; Septuagesima = Easter - 63; Saturday before = Easter - 64
     ((and (= month 12) (>= day 25))
      'christmastide)
     ((and (or (= month 1) (= month 2))
           (< abs (+ easter-abs -63)))
      'christmastide)
     ;; Per annum (Pentecost season, etc.)
     (t 'per-annum))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Render dispatch

(defconst bcp-roman-breviary--hour-entry-fns
  '((vespers  . bcp-roman-breviary-vespers)
    (compline . bcp-roman-breviary-compline)
    (lauds    . bcp-roman-breviary-lauds)
    (prime    . bcp-roman-breviary-prime)
    (terce    . bcp-roman-breviary-terce)
    (sext     . bcp-roman-breviary-sext)
    (none     . bcp-roman-breviary-none)
    (matins   . bcp-roman-breviary-matins))
  "Map from hour symbol to public entry-point function.")

(defun bcp-roman-breviary--render-hour (hour ordo buffer-name label &optional date data-fn)
  "Render HOUR with ORDO, BUFFER-NAME, LABEL, and optional DATE and DATA-FN.
HOUR is a symbol (lauds, prime, terce, sext, none, vespers, compline).
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today.
DATA-FN is the resolver function; defaults to `bcp-roman-breviary--resolve'."
  (let* ((date (or date (calendar-current-date)))
         (year  (caddr date))
         (bcp-roman-breviary--current-dow (calendar-day-of-week date))
         (bcp-roman-breviary--current-date date)
         (_     (require 'bcp-roman-lobvm))
         (season (bcp-roman-lobvm--marian-season date))
         (marian-data (cdr (assq season
                                  (if (eq bcp-roman-office-language 'english)
                                      bcp-roman-marian-antiphons-en
                                    bcp-roman-marian-antiphons))))
         ;; Penitential season (Ash Wednesday – Holy Saturday)
         (feasts (bcp-moveable-feasts year))
         (ash-abs (calendar-absolute-from-gregorian
                   (cdr (assq 'ash-wednesday feasts))))
         (easter-abs (calendar-absolute-from-gregorian
                      (cdr (assq 'easter feasts))))
         (abs (calendar-absolute-from-gregorian date))
         (penitential (and (>= abs ash-abs) (< abs easter-abs)))
         (lang bcp-roman-office-language))
    (require 'bcp-roman-render)
    (bcp-roman-render--render-office
     ordo
     (list :date date
           :season season
           :penitential penitential
           :hour hour
           :language lang
           :marian-antiphon marian-data
           :data-fn (or data-fn #'bcp-roman-breviary--resolve)
           :psalm-fn #'bcp-roman-breviary--psalm-verses
           :gloria-patri (plist-get bcp-common-prayers-gloria-patri
                                    (intern (format ":%s" lang)))
           :buffer-name buffer-name
           :office-label label))
    ;; Init navigation mode for refresh/day-navigation
    (require 'bcp-office-nav)
    (let ((entry-fn (alist-get hour bcp-roman-breviary--hour-entry-fns)))
      (with-current-buffer (get-buffer buffer-name)
        (bcp-office-nav-init
         (decode-time (encode-time 0 0 12
                                   (cadr date) (car date) (caddr date)))
         'roman-breviary
         (lambda ()
           (let ((d (if (bound-and-true-p bcp-office-nav--override-time)
                        (let ((dt bcp-office-nav--override-time))
                          (list (nth 4 dt) (nth 3 dt) (nth 5 dt)))
                      date)))
             (funcall entry-fn d))))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public entry points

(defun bcp-roman-breviary-vespers (&optional date)
  "Render Vespers of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (season (bcp-roman-breviary--liturgical-season date))
         (hw-triduum (pcase season
                       ('triduum-thu (bcp-roman-season-holyweek-triduum 'thu))
                       (_ nil)))
         ;; Good Friday and Holy Saturday omit Vespers entirely
         (triduum-no-vespers (memq season '(triduum-fri triduum-sat)))
         (feast (bcp-roman-proprium-feast date))
         (feast-p (and (not hw-triduum) (not triduum-no-vespers)
                       feast (bcp-roman-proprium--feast-wins-p feast date)))
         (day  (cond
                (hw-triduum       (plist-get hw-triduum :name-en))
                (triduum-no-vespers
                 (pcase season
                   ('triduum-fri "Good Friday")
                   ('triduum-sat "Holy Saturday")))
                (feast-p          (plist-get feast :name))
                (t                (nth dow bcp-roman-breviary--day-names))))
         (ordo (cond
                (triduum-no-vespers
                 ;; Rubric: Vespers are omitted
                 '((:rubric "[Vesperæ hodie non dicuntur.]")))
                (hw-triduum
                 (bcp-roman-breviary--vespers-triduum-ordo date hw-triduum))
                (feast-p
                 (bcp-roman-proprium--vespers-ordo date feast 2))
                (t
                 (bcp-roman-breviary--vespers-ordo dow date))))
         (bcp-roman-proprium--current-feast
          (when feast-p (bcp-roman-proprium--merged-data feast)))
         (data-fn (cond
                   (hw-triduum
                    (bcp-roman-breviary--holyweek-resolver hw-triduum))
                   (feast-p #'bcp-roman-proprium--resolve))))
    (bcp-roman-breviary--render-hour
     'vespers ordo
     (format "*Breviary — %s Vespers*" day)
     (cond
      (hw-triduum       (plist-get hw-triduum :name))
      (triduum-no-vespers
       (pcase season
         ('triduum-fri "Feria Sexta in Parasceve")
         ('triduum-sat "Sabbato Sancto")))
      (feast-p          (plist-get feast :latin))
      (t                (bcp-roman-breviary--season-label date "Vesperæ" "Vespers")))
     date data-fn)))

(defun bcp-roman-breviary-compline (&optional date)
  "Render Compline of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (season (bcp-roman-breviary--liturgical-season date))
         (hw-triduum (pcase season
                       ('triduum-thu (bcp-roman-season-holyweek-triduum 'thu))
                       ('triduum-fri (bcp-roman-season-holyweek-triduum 'fri))
                       ('triduum-sat (bcp-roman-season-holyweek-triduum 'sat))
                       (_ nil)))
         (day  (if hw-triduum
                   (plist-get hw-triduum :name-en)
                 (nth dow bcp-roman-breviary--day-names)))
         (ordo (if hw-triduum
                   (bcp-roman-breviary--compline-triduum-ordo hw-triduum)
                 (bcp-roman-breviary--compline-ordo dow)))
         (data-fn (when hw-triduum
                    (bcp-roman-breviary--holyweek-resolver hw-triduum))))
    (bcp-roman-breviary--render-hour
     'compline ordo
     (format "*Breviary — %s Compline*" day)
     (if hw-triduum
         (plist-get hw-triduum :name)
       (bcp-roman-breviary--season-label date "Completorium" "Compline"))
     date data-fn)))

(defconst bcp-roman-breviary--day-names
  '("Sunday" "Monday" "Tuesday" "Wednesday"
    "Thursday" "Friday" "Saturday")
  "Day-of-week names for buffer/label formatting.")

(defun bcp-roman-breviary-lauds (&optional date)
  "Render Lauds of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (season (bcp-roman-breviary--liturgical-season date))
         (hw-triduum (pcase season
                       ('triduum-thu (bcp-roman-season-holyweek-triduum 'thu))
                       ('triduum-fri (bcp-roman-season-holyweek-triduum 'fri))
                       ('triduum-sat (bcp-roman-season-holyweek-triduum 'sat))
                       (_ nil)))
         (feast (bcp-roman-proprium-feast date))
         (feast-p (and (not hw-triduum)
                       feast (bcp-roman-proprium--feast-wins-p feast date)))
         (day  (cond
                (hw-triduum (plist-get hw-triduum :name-en))
                (feast-p    (plist-get feast :name))
                (t          (nth dow bcp-roman-breviary--day-names))))
         (ordo (cond
                (hw-triduum
                 (bcp-roman-breviary--lauds-triduum-ordo dow date hw-triduum))
                (feast-p
                 (bcp-roman-proprium--lauds-ordo date feast))
                (t
                 (bcp-roman-breviary--lauds-ordo dow date))))
         (bcp-roman-proprium--current-feast
          (when feast-p (bcp-roman-proprium--merged-data feast)))
         (data-fn (cond
                   (hw-triduum
                    (bcp-roman-breviary--holyweek-resolver hw-triduum))
                   (feast-p #'bcp-roman-proprium--resolve))))
    (bcp-roman-breviary--render-hour
     'lauds ordo
     (format "*Breviary — %s Lauds*" day)
     (cond
      (hw-triduum (plist-get hw-triduum :name))
      (feast-p    (plist-get feast :latin))
      (t          (bcp-roman-breviary--season-label date "Laudes" "Lauds")))
     date data-fn)))

(defun bcp-roman-breviary-prime (&optional date)
  "Render Prime of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (season (bcp-roman-breviary--liturgical-season date))
         (hw-triduum (pcase season
                       ('triduum-thu (bcp-roman-season-holyweek-triduum 'thu))
                       ('triduum-fri (bcp-roman-season-holyweek-triduum 'fri))
                       ('triduum-sat (bcp-roman-season-holyweek-triduum 'sat))
                       (_ nil)))
         (feast (unless hw-triduum (bcp-roman-proprium-feast date)))
         (feast-p (and feast (bcp-roman-proprium--feast-wins-p feast date)))
         (day  (cond
                (hw-triduum (plist-get hw-triduum :name-en))
                (feast-p    (plist-get feast :name))
                (t          (nth dow bcp-roman-breviary--day-names))))
         (ordo (cond
                (hw-triduum (bcp-roman-breviary--prime-triduum-ordo date))
                (feast-p    (bcp-roman-proprium--prime-ordo date feast))
                (t          (bcp-roman-breviary--prime-ordo dow date))))
         (bcp-roman-proprium--current-feast
          (when feast-p (bcp-roman-proprium--merged-data feast)))
         (data-fn (cond
                   (hw-triduum
                    (bcp-roman-breviary--holyweek-resolver hw-triduum))
                   (feast-p #'bcp-roman-proprium--resolve))))
    (bcp-roman-breviary--render-hour
     'prime ordo
     (format "*Breviary — %s Prime*" day)
     (cond
      (hw-triduum (plist-get hw-triduum :name))
      (feast-p    (plist-get feast :latin))
      (t          (bcp-roman-breviary--season-label date "Prima" "Prime")))
     date data-fn)))

(defun bcp-roman-breviary-terce (&optional date)
  "Render Terce of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-breviary--minor-hour-entry 'terce "Terce" "Tertia" date))

(defun bcp-roman-breviary-sext (&optional date)
  "Render Sext of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-breviary--minor-hour-entry 'sext "Sext" "Sexta" date))

(defun bcp-roman-breviary-none (&optional date)
  "Render None of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-breviary--minor-hour-entry 'none "None" "Nona" date))

(defun bcp-roman-breviary--minor-hour-entry (hour english-name latin-name &optional date)
  "Dispatch minor HOUR with feast and Triduum awareness.
ENGLISH-NAME and LATIN-NAME are for buffer/label formatting."
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (season (bcp-roman-breviary--liturgical-season date))
         (hw-triduum (pcase season
                       ('triduum-thu (bcp-roman-season-holyweek-triduum 'thu))
                       ('triduum-fri (bcp-roman-season-holyweek-triduum 'fri))
                       ('triduum-sat (bcp-roman-season-holyweek-triduum 'sat))
                       (_ nil)))
         (feast (unless hw-triduum (bcp-roman-proprium-feast date)))
         (feast-p (and feast (bcp-roman-proprium--feast-wins-p feast date)))
         (day  (cond
                (hw-triduum (plist-get hw-triduum :name-en))
                (feast-p    (plist-get feast :name))
                (t          (nth dow bcp-roman-breviary--day-names))))
         (ordo (cond
                (hw-triduum
                 (bcp-roman-breviary--minor-hour-triduum-ordo hour date))
                (feast-p
                 (bcp-roman-proprium--minor-hour-ordo date feast hour))
                (t
                 (bcp-roman-breviary--minor-hour-ordo dow hour date))))
         (bcp-roman-proprium--current-feast
          (when feast-p (bcp-roman-proprium--merged-data feast)))
         (data-fn (cond
                   (hw-triduum
                    (bcp-roman-breviary--holyweek-resolver hw-triduum))
                   (feast-p #'bcp-roman-proprium--resolve))))
    (bcp-roman-breviary--render-hour
     hour ordo
     (format "*Breviary — %s %s*" day english-name)
     (cond
      (hw-triduum (plist-get hw-triduum :name))
      (feast-p    (plist-get feast :latin))
      (t          (bcp-roman-breviary--season-label date latin-name english-name)))
     date data-fn)))

(defconst bcp-roman-breviary--easter-sunday-labels
  ["Dominica Resurrectionis"             ; Easter 0
   "Dominica in Albis"                   ; Easter 1
   "Dominica II Post Pascha"             ; Easter 2
   "Dominica III Post Pascha"            ; Easter 3
   "Dominica IV Post Pascha"             ; Easter 4
   "Dominica V Post Pascha"              ; Easter 5
   "Dominica infra Oct. Ascensionis"     ; Easter 6
   "Dominica Pentecostes"]               ; Easter 7
  "Latin labels for Eastertide Sundays, 0-indexed.")

(defconst bcp-roman-breviary--easter-sunday-labels-en
  ["Easter Day"                          ; Easter 0
   "Low Sunday"                          ; Easter 1
   "Second Sunday after Easter"          ; Easter 2
   "Third Sunday after Easter"           ; Easter 3
   "Fourth Sunday after Easter"          ; Easter 4
   "Fifth Sunday after Easter"           ; Easter 5
   "Sunday after Ascension"              ; Easter 6
   "Whitsunday"]                         ; Easter 7
  "English labels for Eastertide Sundays, 0-indexed.")

(defconst bcp-roman-breviary--lent-sunday-labels
  ["" ; slot 0 unused
   "Dominica I in Quadragesima"
   "Dominica II in Quadragesima"
   "Dominica III in Quadragesima"
   "Dominica IV in Quadragesima"
   "Dominica de Passione"
   "Dominica in Palmis"]
  "Latin labels for Lenten Sundays, 1-indexed.")

(defconst bcp-roman-breviary--lent-sunday-labels-en
  ["" ; slot 0 unused
   "First Sunday in Lent"
   "Second Sunday in Lent"
   "Third Sunday in Lent"
   "Fourth Sunday in Lent"
   "Passion Sunday"
   "Palm Sunday"]
  "English labels for Lenten Sundays, 1-indexed.")

(defconst bcp-roman-breviary--advent-sunday-labels
  ["" ; slot 0 unused
   "Dominica I Adventus"
   "Dominica II Adventus"
   "Dominica III Adventus"
   "Dominica IV Adventus"]
  "Latin labels for Advent Sundays, 1-indexed.")

(defconst bcp-roman-breviary--advent-sunday-labels-en
  ["" ; slot 0 unused
   "First Sunday in Advent"
   "Second Sunday in Advent"
   "Third Sunday in Advent"
   "Fourth Sunday in Advent"]
  "English labels for Advent Sundays, 1-indexed.")

(defconst bcp-roman-breviary--christmas-sunday-labels
  ["Dominica infra Octavam Nativitatis"   ; 0: Nat1
   "Sanctissimi Nominis Jesu"             ; 1: Nat2
   "Dominica I post Epiphaniam"           ; 2: Epi1
   "Dominica II post Epiphaniam"          ; 3: Epi2
   "Dominica III post Epiphaniam"         ; 4: Epi3
   "Dominica IV post Epiphaniam"          ; 5: Epi4
   "Dominica V post Epiphaniam"           ; 6: Epi5
   "Dominica VI post Epiphaniam"]         ; 7: Epi6
  "Latin labels for Christmastide Sundays, 0-indexed.")

(defconst bcp-roman-breviary--christmas-sunday-labels-en
  ["Sunday within the Octave of Christmas" ; 0: Nat1
   "The Holy Name of Jesus"               ; 1: Nat2
   "First Sunday after Epiphany"          ; 2: Epi1
   "Second Sunday after Epiphany"         ; 3: Epi2
   "Third Sunday after Epiphany"          ; 4: Epi3
   "Fourth Sunday after Epiphany"         ; 5: Epi4
   "Fifth Sunday after Epiphany"          ; 6: Epi5
   "Sixth Sunday after Epiphany"]         ; 7: Epi6
  "English labels for Christmastide Sundays, 0-indexed.")

(defun bcp-roman-breviary--season-label (date hour-latin hour-english)
  "Return an office label for DATE with seasonal awareness.
HOUR-LATIN and HOUR-ENGLISH are the hour names (e.g. \"Matutinum\", \"Matins\")."
  (let* ((season (bcp-roman-breviary--liturgical-season date))
         (dow (calendar-day-of-week date))
         (day (nth dow bcp-roman-breviary--day-names))
         (lang bcp-roman-office-language))
    (let ((hour (if (eq lang 'english) hour-english hour-latin)))
      (pcase season
        ((or 'lent 'passiontide)
         (if (= dow 0)
             (let* ((n (bcp-roman-season-lent--sunday-number date))
                    (labels (if (eq lang 'english)
                                bcp-roman-breviary--lent-sunday-labels-en
                              bcp-roman-breviary--lent-sunday-labels)))
               (if n
                   (format "%s — %s" hour (aref labels n))
                 (if (eq lang 'english)
                     (format "%s — %s (Lent)" hour day)
                   (format "%s — %s (Tempore Quadragesimae)" hour day))))
           (if (eq lang 'english)
               (format "%s — %s (Lent)" hour day)
             (format "%s — Feria %s (Tempore Quadragesimae)" hour day))))
        ((or 'easter-sunday 'easter-octave 'eastertide)
         (if (= dow 0)
             (let* ((n (bcp-roman-season-easter--sunday-number date))
                    (labels (if (eq lang 'english)
                                bcp-roman-breviary--easter-sunday-labels-en
                              bcp-roman-breviary--easter-sunday-labels)))
               (if (and n (< n (length labels)))
                   (format "%s — %s" hour (aref labels n))
                 (if (eq lang 'english)
                     (format "%s — Sunday (Eastertide)" hour)
                   (format "%s — Dominica (Tempore Paschali)" hour))))
           (pcase season
             ('easter-octave
              (if (eq lang 'english)
                  (format "%s — %s (Easter Octave)" hour day)
                (format "%s — Feria %s in Octava Paschæ" hour day)))
             (_
              (if (eq lang 'english)
                  (format "%s — %s (Eastertide)" hour day)
                (format "%s — Feria %s (Tempore Paschali)" hour day))))))
        ('advent
         (if (= dow 0)
             (let* ((n (bcp-roman-season-advent--sunday-number date))
                    (labels (if (eq lang 'english)
                                bcp-roman-breviary--advent-sunday-labels-en
                              bcp-roman-breviary--advent-sunday-labels)))
               (if (and n (< n (length labels)))
                   (format "%s — %s" hour (aref labels n))
                 (if (eq lang 'english)
                     (format "%s — Sunday (Advent)" hour)
                   (format "%s — Dominica (Tempore Adventus)" hour))))
           (if (eq lang 'english)
               (format "%s — %s (Advent)" hour day)
             (format "%s — Feria %s (Tempore Adventus)" hour day))))
        ('christmastide
         (if (= dow 0)
             (let* ((n (bcp-roman-season-christmas--sunday-number date))
                    (labels (if (eq lang 'english)
                                bcp-roman-breviary--christmas-sunday-labels-en
                              bcp-roman-breviary--christmas-sunday-labels)))
               (if (and n (< n (length labels)))
                   (format "%s — %s" hour (aref labels n))
                 (if (eq lang 'english)
                     (format "%s — Sunday (Christmastide)" hour)
                   (format "%s — Dominica (Tempore Nativitatis)" hour))))
           (if (eq lang 'english)
               (format "%s — %s (Christmastide)" hour day)
             (format "%s — Feria %s (Tempore Nativitatis)" hour day))))
        (_
         (if (= dow 0)
             (if (eq lang 'english)
                 (format "%s — Sunday (per annum)" hour)
               (format "%s — Dominica (per annum)" hour))
           (if (eq lang 'english)
               (format "%s — %s (per annum)" hour day)
             (format "%s — Feria %s (per annum)" hour day))))))))

(defun bcp-roman-breviary--feast-matins-data (date)
  "Return feast-grade Matins data for DATE, or nil if no feast.
Checks Christmastide proper feasts (Christmas, St. Stephen, Epiphany)
first, then the Proprium Sanctorum calendar."
  (let ((month (car date))
        (day   (cadr date)))
    (cond
     ;; Christmastide proper feasts (Temporale)
     ((and (= month 12) (= day 25))
      (bcp-roman-season-christmas-feast-matins 'christmas))
     ((and (= month 12) (= day 26))
      (bcp-roman-season-christmas-feast-matins 'stephen))
     ((and (= month 1) (= day 6))
      (bcp-roman-season-christmas-feast-matins 'epiphany))
     ;; Proprium Sanctorum
     (t (let ((feast (bcp-roman-proprium-feast date)))
          (when (and feast (bcp-roman-proprium--full-office-p feast))
            (bcp-roman-proprium--merged-data feast)))))))

(defun bcp-roman-breviary-matins (&optional date)
  "Render Matins of the Roman Breviary.
Feast days with proper offices take precedence over the day-of-week
cursus.  Otherwise: Sundays get dominical Matins (3 nocturns, 9 lessons),
weekdays get ferial Matins (1 nocturn, 12 psalms, lectio brevis).
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (feast-data (bcp-roman-breviary--feast-matins-data date))
         (proprium-feast (bcp-roman-proprium-feast date))
         (proprium-p (and proprium-feast
                         (bcp-roman-proprium--full-office-p proprium-feast)
                         ;; Only use proprium resolver for proprium feasts,
                         ;; not Christmastide feasts (which have their own data)
                         (equal feast-data
                                (bcp-roman-proprium--merged-data proprium-feast))))
         (season (bcp-roman-breviary--liturgical-season date))
         (hw-data (pcase season
                    ('triduum-thu (bcp-roman-season-holyweek-triduum 'thu))
                    ('triduum-fri (bcp-roman-season-holyweek-triduum 'fri))
                    ('triduum-sat (bcp-roman-season-holyweek-triduum 'sat))
                    (_ nil)))
         (hw-weekday (and (not hw-data)
                          (memq dow '(1 2 3))
                          (eq season 'passiontide)
                          (bcp-roman-season-holyweek-hours date)))
         (day  (cond
                (hw-data
                 (plist-get hw-data :name-en))
                (hw-weekday
                 (plist-get hw-weekday :name-en))
                (proprium-p
                 (plist-get proprium-feast :name))
                (t (nth dow bcp-roman-breviary--day-names))))
         (ordo (cond
                ;; Triduum: Tenebrae Matins
                (hw-data
                 (bcp-roman-breviary--matins-tenebrae-ordo date hw-data))
                ;; Mon–Wed Holy Week: ferial with proper lessons
                (hw-weekday
                 (bcp-roman-breviary--matins-holyweek-weekday-ordo
                  dow date hw-weekday))
                (feast-data
                 (bcp-roman-breviary--matins-feast-ordo date feast-data))
                ((= dow 0)
                 (bcp-roman-breviary--matins-dominical-ordo date))
                (t
                 (bcp-roman-breviary--matins-ordo dow date))))
         (bcp-roman-proprium--current-feast
          (when proprium-p feast-data))
         (data-fn (cond
                   ((or hw-data hw-weekday)
                    (bcp-roman-breviary--holyweek-resolver
                     (or hw-data hw-weekday)))
                   (proprium-p #'bcp-roman-proprium--resolve))))
    (bcp-roman-breviary--render-hour
     'matins ordo
     (format "*Breviary — %s Matins*" day)
     (cond
      (hw-data    (plist-get hw-data :name))
      (hw-weekday (plist-get hw-weekday :name))
      (proprium-p (plist-get proprium-feast :latin))
      (t          (bcp-roman-breviary--season-label date "Matutinum" "Matins")))
     date data-fn)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Auto-hour dispatch

(defun bcp-roman-breviary (&optional date)
  "Render the ferial Breviary hour for the current time of day.
Dispatches based on the clock:
  Before 4:  Matins (anticipation)
  4–7:       Lauds
  7–9:       Prime
  9–12:      Terce
  12–14:     Sext
  14–17:     None
  17–20:     Vespers
  After 20:  Compline
With optional DATE, renders for that date."
  (interactive)
  (let ((hour (string-to-number (format-time-string "%H"))))
    (cond
     ((< hour 4)  (bcp-roman-breviary-matins date))
     ((< hour 7)  (bcp-roman-breviary-lauds date))
     ((< hour 9)  (bcp-roman-breviary-prime date))
     ((< hour 12) (bcp-roman-breviary-terce date))
     ((< hour 14) (bcp-roman-breviary-sext date))
     ((< hour 17) (bcp-roman-breviary-none date))
     ((< hour 20) (bcp-roman-breviary-vespers date))
     (t           (bcp-roman-breviary-compline date)))))

(provide 'bcp-roman-breviary)

;;; bcp-roman-breviary.el ends here
