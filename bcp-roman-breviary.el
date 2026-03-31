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
(require 'bcp-roman-hymnal)
(require 'bcp-roman-collectarium)
(require 'bcp-roman-psalterium)
(require 'bcp-fetcher)
(require 'bcp-calendar)
(require 'bcp-roman-tempora)

(declare-function bcp-roman-lobvm--marian-season "bcp-roman-lobvm")
(declare-function bcp-roman-render--render-office "bcp-roman-render")

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

(defvar bcp-roman-breviary--canticle-cache (make-hash-table :test 'eql)
  "Cache of canticle verse vectors, keyed by DO canticle number (200+).")

(defun bcp-roman-breviary--load-canticle (num)
  "Load canticle NUM from the DO Psalmorum directory.
Returns a vector of verse strings, or nil."
  (or (gethash num bcp-roman-breviary--canticle-cache)
      (let ((file (expand-file-name
                   (format "divinum-officium-master/web/www/horas/Latin/\
Psalterium/Psalmorum/Psalm%d.txt" num)
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
              (puthash num vec bcp-roman-breviary--canticle-cache)
              vec))))))

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

(defun bcp-roman-breviary--psalm-verses (spec)
  "Return verse list for psalm SPEC.
SPEC is an integer (full psalm, Vulgate numbering) or a list
\(PSALM-NUM START-VERSE END-VERSE\) for a subsection.
Numbers >= 200 are treated as DO canticle numbers.
Uses the Coverdale psalter when `bcp-roman-office-language' is \\='english."
  (let* ((vulg-num (if (listp spec) (car spec) spec))
         (english (eq bcp-roman-office-language 'english)))
    (cond
     ;; Canticles: always from DO files (Latin only for now)
     ((>= vulg-num 200)
      (let ((all (bcp-roman-breviary--load-canticle vulg-num)))
        (when all (append all nil))))
     ;; English: Coverdale psalter with BCP numbering
     (english
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
  "Return a (:collect SYMBOL) step for the preceding Sunday of DATE.
Falls back to a rubric if DATE is outside Per Annum."
  (let ((incipit (bcp-roman-tempora-collect date)))
    (if incipit
        `(:collect ,incipit)
      '(:rubric "[Oratio dominicæ præcedentis]"))))

(defun bcp-roman-breviary--vespers-ordo (dow date)
  "Build Vespers ordo for day-of-week DOW (0-6) on DATE."
  (let ((psalms  (bcp-roman-psalterium-vespers-psalms dow))
        (hymn    (bcp-roman-psalterium-vespers-hymn dow))
        (mag-ant (bcp-roman-psalterium-magnificat-antiphon dow)))
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
      ;; Suffragium sanctorum
      (:suffragium)
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

(defun bcp-roman-breviary--lauds-ordo (dow date)
  "Build Lauds ordo for day-of-week DOW (0-6) on DATE."
  (let ((psalms  (bcp-roman-psalterium-lauds-psalms dow))
        (hymn    (bcp-roman-psalterium-lauds-hymn dow))
        (ben-ant (bcp-roman-psalterium-benedictus-antiphon dow)))
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
      ;; Suffragium sanctorum
      (:suffragium)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-breviary--prime-ordo (dow date)
  "Build Prime ordo for day-of-week DOW (0-6) on DATE."
  (let* ((data   (bcp-roman-psalterium-prime-psalms dow))
         (ant    (plist-get data :antiphon))
         (pss    (plist-get data :psalms))
         (potd   (plist-get data :psalm-of-day)))
    `((:text ave-maria :silent t)
      (:incipit)
      ;; Hymnus
      (:hymn jam-lucis-orto-sidere)
      ;; Psalmi
      (:antiphon ,ant)
      ,@(mapcar (lambda (ps) `(:psalm ,ps)) pss)
      ,@(when potd `((:psalm ,potd)))
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

(defun bcp-roman-breviary--matins-ordo (dow date)
  "Build ferial Matins ordo for day-of-week DOW (1-6) on DATE.
Uses the Daya cursus: 1 nocturn, 12 psalms under 6 antiphons."
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
      ;; Psalmi cum Antiphonis (6 antiphons × 2 psalms each)
      ,@(cl-loop for (ant . ps-pair) in psalms
                 collect `(:antiphon ,ant)
                 append (mapcar (lambda (ps) `(:psalm ,ps)) ps-pair)
                 collect `(:antiphon ,ant :repeat t))
      ;; Versus
      (:versicles matins-versicle)
      ;; Lectio brevis
      (:lectio-brevis matins-lectio-brevis)
      ;; Capitulum et Versus
      (:capitulum matins-capitulum)
      (:versicles matins-capitulum-versicle)
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

(defun bcp-roman-breviary--matins-dominical-nocturn (n lesson-offset bene-key)
  "Build ordo steps for dominical Matins nocturn N (1-3).
LESSON-OFFSET is the 0-based offset for the first lesson in this nocturn
\(0 for Nocturn I, 3 for II, 6 for III\).
BENE-KEY is the resolver key for the benedictions list."
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
      ,@(if (= n 3)
            '((:te-deum))
          `((:responsory ,(intern (format "matins-responsory-%d"
                                          (+ lesson-offset 3)))))))))

(defun bcp-roman-breviary--matins-dominical-ordo (date)
  "Build dominical (Sunday) Matins ordo for DATE.
Uses 3 nocturns of 3 psalms each, with 9 lessons and 8 responsories."
  (let ((invit (bcp-roman-psalterium-invitatory-antiphon 0))
        (hymn  (bcp-roman-psalterium-matins-hymn 0)))
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
         3 6 'matins-benedictiones-nocturn-3)
      ;; Oratio
      (:pre-oratio)
      ,(bcp-roman-breviary--collect-step date)
      ;; Conclusio
      (:conclusio))))

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

(defun bcp-roman-breviary--resolve (key)
  "Resolve data KEY for the ferial Breviary.
Returns the appropriate text, plist, or data structure."
  (let ((lang bcp-roman-office-language)
        (variant (if (= bcp-roman-breviary--current-dow 0) :dominical :ferial)))
    (pcase key
      ;; ── Capitula (return plist with :ref and :text) ──
      ('vespers-capitulum  bcp-roman-psalterium--vespers-capitulum)
      ('compline-capitulum bcp-roman-psalterium--compline-capitulum)
      ('lauds-capitulum    bcp-roman-psalterium--lauds-capitulum)
      ('prime-capitulum    bcp-roman-psalterium--prime-capitulum)
      ('terce-capitulum    (plist-get bcp-roman-psalterium--terce-capitulum
                                      variant))
      ('sext-capitulum     (plist-get bcp-roman-psalterium--sext-capitulum
                                      variant))
      ('none-capitulum     (plist-get bcp-roman-psalterium--none-capitulum
                                      variant))
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

      ;; ── Dominical Matins: lessons (return plist with :ref, :text, etc.) ──
      ((and (pred symbolp)
            (let name (symbol-name key))
            (guard (string-match "\\`matins-lesson-\\([0-9]+\\)\\'" name)))
       (let* ((n (string-to-number (match-string 1 name)))
              (data (bcp-roman-tempora-dominical-matins
                     bcp-roman-breviary--current-date))
              (lessons (plist-get data :lessons)))
         (nth (1- n) lessons)))

      ;; ── Dominical Matins: responsories (return plist with :respond, :verse, :repeat) ──
      ((and (pred symbolp)
            (let name (symbol-name key))
            (guard (string-match "\\`matins-responsory-\\([0-9]+\\)\\'" name)))
       (let* ((n (string-to-number (match-string 1 name)))
              (data (bcp-roman-tempora-dominical-matins
                     bcp-roman-breviary--current-date))
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

      ;; ── Registry fallback: antiphonary → hymnal → collectarium ──
      (_
       (or (bcp-roman-antiphonary-get key lang)
           (bcp-roman-hymnal-get key lang)
           (bcp-roman-collectarium-get key lang)
           (error "Unknown Breviary data key: %s" key))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Render dispatch

(defun bcp-roman-breviary--render-hour (hour ordo buffer-name label &optional date)
  "Render ferial HOUR with ORDO, BUFFER-NAME, LABEL, and optional DATE.
HOUR is a symbol (lauds, prime, terce, sext, none, vespers, compline).
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
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
           :data-fn #'bcp-roman-breviary--resolve
           :psalm-fn #'bcp-roman-breviary--psalm-verses
           :gloria-patri (plist-get bcp-common-prayers-gloria-patri
                                    (intern (format ":%s" lang)))
           :buffer-name buffer-name
           :office-label label))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public entry points

(defun bcp-roman-breviary-vespers (&optional date)
  "Render ferial Vespers of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (day  (nth dow '("Sunday" "Monday" "Tuesday" "Wednesday"
                          "Thursday" "Friday" "Saturday")))
         (ordo (bcp-roman-breviary--vespers-ordo dow date)))
    (bcp-roman-breviary--render-hour
     'vespers ordo
     (format "*Breviary — %s Vespers*" day)
     (format "Vesperæ — Feria %s (per annum)" day)
     date)))

(defun bcp-roman-breviary-compline (&optional date)
  "Render ferial Compline of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (day  (nth dow '("Sunday" "Monday" "Tuesday" "Wednesday"
                          "Thursday" "Friday" "Saturday")))
         (ordo (bcp-roman-breviary--compline-ordo dow)))
    (bcp-roman-breviary--render-hour
     'compline ordo
     (format "*Breviary — %s Compline*" day)
     (format "Completorium — Feria %s (per annum)" day)
     date)))

(defconst bcp-roman-breviary--day-names
  '("Sunday" "Monday" "Tuesday" "Wednesday"
    "Thursday" "Friday" "Saturday")
  "Day-of-week names for buffer/label formatting.")

(defun bcp-roman-breviary-lauds (&optional date)
  "Render ferial Lauds of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (day  (nth dow bcp-roman-breviary--day-names))
         (ordo (bcp-roman-breviary--lauds-ordo dow date)))
    (bcp-roman-breviary--render-hour
     'lauds ordo
     (format "*Breviary — %s Lauds*" day)
     (format "Laudes — Feria %s (per annum)" day)
     date)))

(defun bcp-roman-breviary-prime (&optional date)
  "Render ferial Prime of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (day  (nth dow bcp-roman-breviary--day-names))
         (ordo (bcp-roman-breviary--prime-ordo dow date)))
    (bcp-roman-breviary--render-hour
     'prime ordo
     (format "*Breviary — %s Prime*" day)
     (format "Prima — Feria %s (per annum)" day)
     date)))

(defun bcp-roman-breviary-terce (&optional date)
  "Render ferial Terce of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (day  (nth dow bcp-roman-breviary--day-names))
         (ordo (bcp-roman-breviary--minor-hour-ordo dow 'terce date)))
    (bcp-roman-breviary--render-hour
     'terce ordo
     (format "*Breviary — %s Terce*" day)
     (format "Tertia — Feria %s (per annum)" day)
     date)))

(defun bcp-roman-breviary-sext (&optional date)
  "Render ferial Sext of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (day  (nth dow bcp-roman-breviary--day-names))
         (ordo (bcp-roman-breviary--minor-hour-ordo dow 'sext date)))
    (bcp-roman-breviary--render-hour
     'sext ordo
     (format "*Breviary — %s Sext*" day)
     (format "Sexta — Feria %s (per annum)" day)
     date)))

(defun bcp-roman-breviary-none (&optional date)
  "Render ferial None of the Roman Breviary.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (day  (nth dow bcp-roman-breviary--day-names))
         (ordo (bcp-roman-breviary--minor-hour-ordo dow 'none date)))
    (bcp-roman-breviary--render-hour
     'none ordo
     (format "*Breviary — %s None*" day)
     (format "Nona — Feria %s (per annum)" day)
     date)))

(defun bcp-roman-breviary-matins (&optional date)
  "Render Matins of the Roman Breviary.
On Sundays, renders dominical Matins (3 nocturns, 9 lessons).
On weekdays, renders ferial Matins (1 nocturn, 12 psalms, lectio brevis).
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (let* ((date (or date (calendar-current-date)))
         (dow  (calendar-day-of-week date))
         (day  (nth dow bcp-roman-breviary--day-names))
         (ordo (if (= dow 0)
                   (bcp-roman-breviary--matins-dominical-ordo date)
                 (bcp-roman-breviary--matins-ordo dow date))))
    (bcp-roman-breviary--render-hour
     'matins ordo
     (format "*Breviary — %s Matins*" day)
     (if (= dow 0)
         "Matutinum — Dominica (per annum)"
       (format "Matutinum — Feria %s (per annum)" day))
     date)))

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
