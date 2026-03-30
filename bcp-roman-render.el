;;; bcp-roman-render.el --- Roman Office renderer -*- lexical-binding: t -*-

;;; Commentary:

;; Renderer for the Roman Breviary (DA 1911 rubrics).
;; Parallel to `bcp-anglican-render.el' for the Anglican side.
;;
;; Walks an ordo (list of typed step plists from `bcp-roman-ordo.el')
;; and renders each step into a liturgical text buffer using primitives
;; from `bcp-liturgy-render.el'.
;;
;; The renderer receives a context plist (ctx) with:
;;   :date              — Gregorian date
;;   :season            — liturgical season symbol
;;   :marian-antiphon   — plist for the seasonal Marian antiphon
;;   :data-fn           — (KEY) → text/data resolver
;;   :psalm-fn          — (VULG-NUM) → list of verse strings
;;   :gloria-patri      — Gloria Patri text string
;;   :language          — 'latin or 'english
;;   :buffer-name       — buffer name string
;;   :office-label      — heading label string

;;; Code:

(require 'cl-lib)
(require 'bcp-liturgy-render)
(require 'bcp-common-roman)
(require 'bcp-common-prayers)
(require 'bcp-common-canticles)
(require 'bcp-roman-hymnal)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Scripture fetching for English mode

(defconst bcp-roman-render--breviary-book-map
  '(("Sir"    . "Sirach")
    ("Cant"   . "Song of Solomon")
    ("Luc."   . "Luke")
    ("Luc"    . "Luke")
    ("Dan."   . "Daniel")
    ("Dan"    . "Daniel")
    ("Prov"   . "Proverbs")
    ("Sap"    . "Wisdom")
    ("Is."    . "Isaiah")
    ("Is"     . "Isaiah")
    ("Jer"    . "Jeremiah")
    ("Eccli"  . "Sirach")
    ("Eccl"   . "Ecclesiastes")
    ("Matt"   . "Matthew")
    ("Marc"   . "Mark")
    ("Joan"   . "John")
    ("Rom"    . "Romans")
    ("Cor"    . "Corinthians")
    ("Gal"    . "Galatians")
    ("Eph"    . "Ephesians")
    ("Philip" . "Philippians")
    ("Col"    . "Colossians")
    ("Thess"  . "Thessalonians")
    ("Tim"    . "Timothy")
    ("Tit"    . "Titus")
    ("Hebr"   . "Hebrews")
    ("Heb"    . "Hebrews")
    ("Jac"    . "James")
    ("Petr"   . "Peter")
    ("Apoc"   . "Revelation"))
  "Alist mapping Breviary abbreviations to fetcher book names.")

(defun bcp-roman-render--normalize-ref (ref)
  "Normalize a Breviary scripture REF for the fetcher.
Converts abbreviations like \"Sir 24:14\" to \"Sirach 24:14\"."
  (if (string-match "^\\([A-Za-z.]+\\)\\([ \t]+.*\\)" ref)
      (let* ((abbr (string-trim-right (match-string 1 ref) "\\."))
             (rest (match-string 2 ref))
             (full (cdr (assoc abbr bcp-roman-render--breviary-book-map))))
        (if full
            (concat full rest)
          ref))
    ref))

(defun bcp-roman-render--fetch-scripture (ref)
  "Try to fetch scripture text for Breviary REF synchronously.
Returns the text string, or nil if fetching is unavailable.
Uses the active `bcp-fetcher' backend."
  (condition-case nil
      (let* ((normalized (bcp-roman-render--normalize-ref ref))
             (result nil))
        (require 'bcp-fetcher nil t)
        (when (fboundp 'bcp-fetcher-fetch)
          (bcp-fetcher-fetch normalized (lambda (text) (setq result text)))
          result))
    (error nil)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Rubric face

(defface bcp-roman-rubric
  '((t :foreground "firebrick" :italic t))
  "Face for Roman Office rubrics.")

(defun bcp-roman-render--rubric-face ()
  "Return the rubric face for the Roman Office."
  'bcp-roman-rubric)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Rendering helpers

(defun bcp-roman-render--insert-antiphon (text &optional repeat-p)
  "Insert antiphon TEXT.  If REPEAT-P, prefix with \"Ant.\" marker."
  (let ((prefix (if repeat-p "Ant. " "Ant. ")))
    (insert "\n")
    (let ((start (point)))
      (insert prefix text "\n")
      (put-text-property start (point) 'face 'italic))))

(defun bcp-roman-render--insert-psalm (vulg-num verses gloria-patri &optional language)
  "Insert psalm VULG-NUM with VERSES and GLORIA-PATRI.
VERSES is a list of verse strings with Breviary pointing.
LANGUAGE is \\='latin or \\='english."
  (insert "\n")
  (bcp-liturgy-render--insert-heading
   3 (format (if (eq language 'english) "Psalm %d" "Psalmus %d") vulg-num))
  (dolist (v verses)
    (insert v "\n"))
  (when gloria-patri
    (insert gloria-patri "\n")))

(defun bcp-roman-render--insert-hymn (text &optional language)
  "Insert hymn TEXT, preserving stanza breaks.
LANGUAGE is \\='latin or \\='english."
  (insert "\n")
  (bcp-liturgy-render--insert-heading
   3 (if (eq language 'english) "Hymn" "Hymnus"))
  (insert text "\n"))

(defun bcp-roman-render--insert-capitulum (data &optional language)
  "Insert capitulum from DATA plist (:ref REF :text TEXT).
When LANGUAGE is \\='english, fetch scripture text via `bcp-fetcher'
using the :ref slot; fall back to the embedded Latin :text if
fetching is unavailable."
  (insert "\n")
  (bcp-liturgy-render--insert-heading
   3 (if (eq language 'english) "Chapter" "Capitulum"))
  (let ((ref (plist-get data :ref)))
    (bcp-liturgy-render--insert-rubric
     ref #'bcp-roman-render--rubric-face)
    (if (eq language 'english)
        (let ((fetched (bcp-roman-render--fetch-scripture ref)))
          (if fetched
              (insert fetched "\n")
            (bcp-liturgy-render--insert-rubric
             "(Scripture text from user's configured Bible translation)"
             #'bcp-roman-render--rubric-face)))
      (insert (plist-get data :text) "\n")))
  (insert (if (eq language 'english)
              "℟. Thanks be to God.\n"
            "℟. Deo grátias.\n")))

(defun bcp-roman-render--insert-canticle (data antiphon gloria-patri &optional language)
  "Insert canticle from DATA plist with ANTIPHON and GLORIA-PATRI.
LANGUAGE is \\='latin or \\='english.
Gloria Patri is suppressed when DATA contains :no-gloria t.
When LANGUAGE is \\='english and DATA has a :canticle-key, fetches the
English text from the canticle registry."
  (let* ((ckey (plist-get data :canticle-key))
         (name (plist-get data :name))
         (ref  (plist-get data :ref))
         (text (or (when (and (eq language 'english) ckey)
                     (bcp-liturgy-canticle-get ckey 'english))
                   (plist-get data :text))))
    (insert "\n")
    (bcp-roman-render--insert-antiphon antiphon)
    (bcp-liturgy-render--insert-heading
     3 (format "%s (%s)" name ref))
    (insert text "\n")
    (when (and gloria-patri (not (plist-get data :no-gloria)))
      (insert gloria-patri "\n"))
    (bcp-roman-render--insert-antiphon antiphon t)))

(defun bcp-roman-render--insert-marian-antiphon (data &optional language)
  "Insert seasonal Marian antiphon from DATA plist.
LANGUAGE is \\='latin or \\='english."
  (let ((en (eq language 'english)))
    (insert "\n")
    (bcp-liturgy-render--insert-heading
     3 (if en "Final Antiphon of the B.V.M." "Antiphona finalis B.M.V."))
    (insert (plist-get data :antiphon) "\n\n")
    (bcp-liturgy-render--insert-versicles
     (list (list (plist-get data :versicle)
                 (plist-get data :response))))
    (insert "\n")
    (bcp-roman-render--insert-dominus-vobiscum language)
    (insert "\n" (if en bcp-roman-oremus-en bcp-roman-oremus) "\n")
    (insert (plist-get data :collect) "\n")))

(defun bcp-roman-render--insert-incipit (penitential &optional gloria-patri language)
  "Insert the Deus in adjutorium incipit.
When PENITENTIAL is non-nil, substitute Laus tibi for Alleluia.
GLORIA-PATRI is the language-resolved Gloria Patri text.
LANGUAGE is \\='latin or \\='english."
  (insert "\n")
  (let* ((en (eq language 'english))
         (dia (if en bcp-roman-deus-in-adjutorium-en
                bcp-roman-deus-in-adjutorium)))
    (bcp-liturgy-render--insert-versicles
     (list (list (plist-get dia :versicle)
                 (plist-get dia :response)))))
  (insert (or gloria-patri
              (plist-get bcp-common-prayers-gloria-patri :latin))
          "\n")
  (let ((en (eq language 'english)))
    (if penitential
        (insert (if en bcp-roman-laus-tibi-en bcp-roman-laus-tibi) "\n")
      (insert (if en bcp-roman-alleluia-en bcp-roman-alleluia) "\n"))))

(defun bcp-roman-render--insert-dominus-vobiscum (&optional language)
  "Insert Dominus vobiscum or Domine exaudi based on `office-officiant'.
LANGUAGE is \\='latin or \\='english."
  (let ((en (eq language 'english)))
    (bcp-liturgy-render--insert-dominus-vobiscum
     (list (if en bcp-roman-dominus-vobiscum-en bcp-roman-dominus-vobiscum))
     (list (if en bcp-roman-domine-exaudi-en bcp-roman-domine-exaudi)))))

(defun bcp-roman-render--insert-pre-oratio (&optional language)
  "Insert the Kyrie, Dominus vobiscum/Domine exaudi, Oremus block.
LANGUAGE is \\='latin or \\='english."
  (let ((en (eq language 'english)))
    (insert "\n" (if en bcp-roman-kyrie-en bcp-roman-kyrie) "\n\n")
    (bcp-roman-render--insert-dominus-vobiscum language)
    (insert "\n" (if en bcp-roman-oremus-en bcp-roman-oremus) "\n")))

(defun bcp-roman-render--insert-conclusio (hour &optional language)
  "Insert the closing block for HOUR.
LANGUAGE is \\='latin or \\='english.
For Compline: Dominus vobiscum, Benedicamus, Benedictio, Amen.
For other hours: Dominus vobiscum, Benedicamus, Fidelium animae."
  (let ((en (eq language 'english)))
    (insert "\n")
    (bcp-roman-render--insert-dominus-vobiscum language)
    (bcp-liturgy-render--insert-versicles
     (list (if en bcp-roman-benedicamus-domino-en bcp-roman-benedicamus-domino)))
    (if (eq hour 'compline)
        (progn
          (insert "\n"
                  (if en bcp-roman-benedictio-compline-final-en
                    bcp-roman-benedictio-compline-final)
                  "\n")
          (insert "℟. Amen.\n"))
      (bcp-liturgy-render--insert-versicles
       (list (if en bcp-roman-fidelium-animae-en bcp-roman-fidelium-animae))))))

(defun bcp-roman-render--insert-commemoratio (data &optional language)
  "Insert a commemoratio block from DATA plist.
DATA has :antiphon, :versicle, :response, :collect.
LANGUAGE is \\='latin or \\='english."
  (let ((en (eq language 'english)))
    (insert "\n")
    (bcp-liturgy-render--insert-heading
     3 (if en "Commemoration of the Saints" "Commemoratio de Sanctis"))
    (let ((start (point)))
      (insert "Ant. " (plist-get data :antiphon) "\n")
      (put-text-property start (point) 'face 'italic))
    (bcp-liturgy-render--insert-versicles
     (list (list (plist-get data :versicle)
                 (plist-get data :response))))
    (insert "\n" (if en bcp-roman-oremus-en bcp-roman-oremus) "\n")
    (insert (plist-get data :collect) "\n")))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins rendering helpers

(defconst bcp-roman-render--invitatory-pattern
  '(ant group-1 ant group-2 ant2 group-3 ant group-4 ant2
    group-5 ant gloria ant2 ant)
  "The invitatory antiphon insertion pattern for the Roman Office.
ant = full antiphon, ant2 = first half, group-N = verse group,
gloria = Gloria Patri.")

(defconst bcp-roman-render--invitatory-verse-groups
  '((0 1) (2 3 4) (5 6) (7 8) (9 10))
  "Verse index groupings for the invitatory Psalm 94/95.
Each sub-list gives the 0-based verse indices for one group.")

(defun bcp-roman-render--invitatory-ant-half (antiphon-text)
  "Return the first half of ANTIPHON-TEXT (up to the *).
If the antiphon contains no *, return the full text."
  (if (string-match "\\(.*\\)\\*" antiphon-text)
      (string-trim (match-string 1 antiphon-text))
    antiphon-text))

(defun bcp-roman-render--insert-invitatory (antiphon-text &optional language)
  "Insert the invitatory with ANTIPHON-TEXT interspersed through Psalm 94.
LANGUAGE is \\='latin or \\='english (default \\='latin).
The full antiphon alternates with the first half after verse groups,
following the traditional Roman pattern."
  (insert "\n")
  (bcp-liturgy-render--insert-heading 3 "Invitatorium")
  (let* ((lang   (or language 'latin))
         (ant2   (bcp-roman-render--invitatory-ant-half antiphon-text))
         (raw    (bcp-liturgy-canticle-get 'venite lang))
         (verses (when raw (split-string raw "\n" t "[ \t]+")))
         (gloria (plist-get bcp-common-prayers-gloria-patri
                            (intern (format ":%s" lang)))))
    (if (not verses)
        ;; Fallback if canticle text unavailable
        (progn
          (bcp-roman-render--insert-antiphon antiphon-text)
          (bcp-liturgy-render--insert-rubric
           "(Psalmus 94, Venite exultemus Domino)"
           #'bcp-roman-render--rubric-face)
          (bcp-roman-render--insert-antiphon antiphon-text t))
      ;; Render with interspersed antiphon
      (dolist (elem bcp-roman-render--invitatory-pattern)
        (pcase elem
          ('ant    (bcp-roman-render--insert-antiphon antiphon-text))
          ('ant2   (bcp-roman-render--insert-antiphon ant2))
          ('gloria (when gloria (insert gloria "\n")))
          (_
           ;; :group-N — extract the group index from the symbol name
           (let* ((n (1- (string-to-number
                          (substring (symbol-name elem)
                                     (length "group-")))))
                  (indices (nth n bcp-roman-render--invitatory-verse-groups)))
             (dolist (i indices)
               (when (nth i verses)
                 (insert (nth i verses) "\n"))))))))))

(defun bcp-roman-render--insert-lesson (data n &optional language)
  "Insert a Matins lesson from DATA plist, lesson number N (1-based).
DATA has :ref (scripture reference) and :text (lesson body).
When LANGUAGE is \\='english, fetch scripture text via `bcp-fetcher'."
  (insert "\n")
  (bcp-liturgy-render--insert-heading
   3 (format (if (eq language 'english) "Lesson %s" "Lectio %s")
             (upcase (make-string n ?i))))
  (let ((ref (plist-get data :ref)))
    (when ref
      (bcp-liturgy-render--insert-rubric ref #'bcp-roman-render--rubric-face))
    (if (eq language 'english)
        (let ((fetched (when ref (bcp-roman-render--fetch-scripture ref))))
          (if fetched
              (insert fetched "\n")
            (if ref
                (bcp-liturgy-render--insert-rubric
                 "(Scripture text from user's configured Bible translation)"
                 #'bcp-roman-render--rubric-face)
              (insert (plist-get data :text) "\n"))))
      (insert (plist-get data :text) "\n"))))

(defun bcp-roman-render--insert-responsory (data)
  "Insert a responsory from DATA plist.
DATA has :respond, :verse, and :repeat."
  (insert "\n")
  (let ((start (point)))
    (insert "℟. " (plist-get data :respond) "\n")
    (insert (plist-get data :repeat) "\n")
    (insert "℣. " (plist-get data :verse) "\n")
    (insert "℟. " (plist-get data :repeat) "\n")
    (put-text-property start (point) 'face 'italic)))

(defun bcp-roman-render--insert-te-deum (&optional language)
  "Insert the Te Deum from the canticle registry.
LANGUAGE is \\='latin or \\='english (default \\='latin)."
  (insert "\n")
  (bcp-liturgy-render--insert-heading 3 "Te Deum")
  (let ((text (bcp-liturgy-canticle-get 'te-deum (or language 'latin))))
    (if text
        (insert text "\n")
      (bcp-liturgy-render--insert-rubric
       "(Te Deum laudamus)"
       #'bcp-roman-render--rubric-face))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Prayer name formatting

(defconst bcp-roman-render--hymn-incipits
  '((matins-hymn     . quem-terra-pontus-sidera)
    (lauds-hymn      . o-gloriosa-virginum)
    (vespers-hymn    . ave-maris-stella)
    (minor-hymn      . memento-rerum-conditor)
    (compline-hymn   . memento-rerum-conditor-compl))
  "Alist mapping ordo hymn keys to hymnal incipit symbols.")

(defconst bcp-roman-render--prayer-names
  '((ave-maria    . "Ave Maria")
    (pater-noster . "Pater Noster")
    (credo        . "Credo"))
  "Alist mapping prayer key symbols to display names for rubrics.")

(defun bcp-roman-render--prayer-name (key)
  "Return the display name for prayer KEY, or capitalize the symbol name."
  (or (cdr (assq key bcp-roman-render--prayer-names))
      (capitalize (symbol-name key))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Step dispatch

(defun bcp-roman-render--render-step (step ctx)
  "Render a single ordo STEP using context CTX."
  (let ((data-fn      (plist-get ctx :data-fn))
        (psalm-fn     (plist-get ctx :psalm-fn))
        (gloria-patri (plist-get ctx :gloria-patri))
        (penitential  (plist-get ctx :penitential))
        (hour         (plist-get ctx :hour))
        (language     (or (plist-get ctx :language) 'latin))
        (marian       (plist-get ctx :marian-antiphon)))
    (pcase (car step)
      (:rubric
       (bcp-liturgy-render--insert-rubric
        (cadr step) #'bcp-roman-render--rubric-face))

      (:text
       (let* ((key    (cadr step))
              (silent (plist-get (cddr step) :silent))
              (text   (funcall data-fn key)))
         (if silent
             (bcp-liturgy-render--insert-rubric
              (format (if (eq language 'english) "%s, said silently." "%s, secreto.")
                      (bcp-roman-render--prayer-name key))
              #'bcp-roman-render--rubric-face)
           (bcp-liturgy-render--insert-fixed-text
            (symbol-name key) text))))

      (:versicles
       (let ((key (cadr step)))
         (if (symbolp key)
             ;; Resolve from data layer — returns (V R) list
             (let ((pair (funcall data-fn key)))
               (insert "\n")
               (bcp-liturgy-render--insert-versicles (list pair)))
           ;; Inline pair
           (insert "\n")
           (bcp-liturgy-render--insert-versicles (list key)))))

      (:incipit
       (bcp-roman-render--insert-incipit penitential gloria-patri language))

      (:antiphon
       (let* ((key     (cadr step))
              (repeat  (plist-get (cddr step) :repeat))
              (text    (funcall data-fn key)))
         (bcp-roman-render--insert-antiphon text repeat)))

      (:psalm
       (let* ((num     (cadr step))
              (ant-key (plist-get (cddr step) :antiphon))
              (verses  (funcall psalm-fn num))
              (ant     (when ant-key (funcall data-fn ant-key))))
         (when ant
           (bcp-roman-render--insert-antiphon ant))
         (bcp-roman-render--insert-psalm num verses gloria-patri language)
         (when ant
           (bcp-roman-render--insert-antiphon ant t))))

      (:psalm-group
       (let* ((nums    (cadr step))
              (ant-key (plist-get (cddr step) :antiphon))
              (ant     (when ant-key (funcall data-fn ant-key))))
         (when ant
           (bcp-roman-render--insert-antiphon ant))
         (dolist (num nums)
           (let ((verses (funcall psalm-fn num)))
             ;; Gloria Patri only after the last psalm in the group
             (bcp-roman-render--insert-psalm
              num verses
              (when (eq num (car (last nums))) gloria-patri)
              language)))
         (when ant
           (bcp-roman-render--insert-antiphon ant t))))

      (:hymn
       (let* ((key     (cadr step))
              (incipit (cdr (assq key bcp-roman-render--hymn-incipits)))
              (text    (if incipit
                           (or (bcp-roman-hymnal-get incipit language)
                               (funcall data-fn key))
                         (funcall data-fn key))))
         (bcp-roman-render--insert-hymn text language)))

      (:capitulum
       (let ((data (funcall data-fn (cadr step))))
         (bcp-roman-render--insert-capitulum data language)))

      (:canticle
       (let* ((key      (cadr step))
              (ant-key  (plist-get (cddr step) :antiphon))
              (data     (funcall data-fn key))
              (antiphon (funcall data-fn ant-key)))
         (bcp-roman-render--insert-canticle data antiphon gloria-patri language)))

      (:confession
       (let* ((form (bcp-penitential-form bcp-roman-confession-form))
              (text (plist-get form :confession)))
         (when text
           (insert "\n")
           (bcp-liturgy-render--insert-fixed-text "confession" text))))

      (:absolution
       (let* ((form (bcp-penitential-form bcp-roman-absolution-form))
              (text (plist-get form :absolution)))
         (when text
           (insert "\n")
           (bcp-liturgy-render--insert-fixed-text "absolution" text))))

      (:pre-oratio
       (bcp-roman-render--insert-pre-oratio language))

      (:collect
       (let ((text (funcall data-fn (cadr step))))
         (insert "\n")
         (bcp-liturgy-render--insert-fixed-text "collect" text)))

      (:conclusio
       (bcp-roman-render--insert-conclusio hour language))

      (:marian-antiphon
       (when marian
         (bcp-roman-render--insert-marian-antiphon marian language)))

      (:commemoratio
       (let ((data (funcall data-fn 'commemoratio)))
         (when data
           (bcp-roman-render--insert-commemoratio data language))))

      (:silent-prayers
       (let ((keys (cadr step)))
         (bcp-liturgy-render--insert-rubric
          (format (if (eq language 'english) "%s, said silently." "%s, secreto.")
                  (mapconcat #'bcp-roman-render--prayer-name keys ", "))
          #'bcp-roman-render--rubric-face)))

      (:invitatory
       (let ((text (funcall data-fn (cadr step))))
         (bcp-roman-render--insert-invitatory text language)))

      (:lesson
       (let* ((key  (cadr step))
              (data (funcall data-fn key)))
         (bcp-roman-render--insert-lesson
          data
          (or (plist-get (cddr step) :number)
              ;; Derive lesson number from key name
              (cond
               ((string-match-p "1" (symbol-name key)) 1)
               ((string-match-p "2" (symbol-name key)) 2)
               ((string-match-p "3" (symbol-name key)) 3)
               (t 1)))
          language)))

      (:responsory
       (let ((data (funcall data-fn (cadr step))))
         (bcp-roman-render--insert-responsory data)))

      (:te-deum
       (bcp-roman-render--insert-te-deum language))

      (:lesson-absolutio
       (let* ((idx (cadr step))
              (text (nth idx bcp-roman-absolutiones)))
         (insert "\n")
         (bcp-liturgy-render--insert-rubric
          (if (eq language 'english) "Absolution." "Absolutio.")
          #'bcp-roman-render--rubric-face)
         (insert text "\n")
         (insert "℟. Amen.\n")))

      (:lesson-benedictio
       (let* ((key  (cadr step))
              (idx  (caddr step))
              (list (funcall data-fn key))
              (text (nth idx list)))
         (insert "\n")
         (bcp-liturgy-render--insert-rubric
          (if (eq language 'english) "Blessing." "Benedictio.")
          #'bcp-roman-render--rubric-face)
         (insert (if (eq language 'english)
                     (bcp-roman-jube-domne-en)
                   (bcp-roman-jube-domne))
                 "\n")
         (insert text "\n")))

      (:nocturn-versicle
       (let ((pair (funcall data-fn (cadr step))))
         (insert "\n")
         (bcp-liturgy-render--insert-versicles (list pair))))

      (_
       (insert (format "\n[Unknown step: %S]\n" step))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Office walker

(defun bcp-roman-render--render-office (ordo ctx)
  "Render ORDO (list of steps) with context CTX into a buffer."
  (let* ((buf-name (plist-get ctx :buffer-name))
         (label    (plist-get ctx :office-label))
         (buf      (bcp-liturgy-render--setup-buffer buf-name)))
    (with-current-buffer buf
      ;; Heading
      (bcp-liturgy-render--insert-heading 1 label)
      (insert "\n")
      ;; Walk ordo
      (dolist (step ordo)
        (bcp-roman-render--render-step step ctx))
      ;; Finalise
      (bcp-liturgy-render--finalise-buffer))
    (switch-to-buffer buf)))

(provide 'bcp-roman-render)
;;; bcp-roman-render.el ends here
