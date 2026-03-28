;;; bcp-angular-1928-render.el --- 1928 American BCP Office renderer -*- lexical-binding: t -*-

;;; Commentary:

;; BCP 1928-specific Office renderer.  Depends on bcp-liturgy-render.el
;; for all buffer primitives.
;;
;; This file owns:
;;   - Book-expansion table and ref utilities (Roman-numeral abbreviations)
;;   - Rubric face and defcustom
;;   - Thin insert wrappers binding the 1928 rubric face
;;   - bcp-1928--day-identity — liturgical identity plist
;;   - bcp-1928--render-ordo-step — step-type dispatch
;;   - bcp-1928--render-office   — main ordo walker

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-render)
(require 'bcp-liturgy-render)
(require 'bcp-liturgy-canticles)
(require 'bcp-anglican-1928-calendar)
(require 'bcp-anglican-1928-data)
(require 'bcp-anglican-1928-ordo)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Ref utilities
;;;; ══════════════════════════════════════════════════════════════════════════

(defconst bcp-1928--book-expansions
  '(;; Old Testament
    ("Gen"      . "Genesis")
    ("Exod"     . "Exodus")
    ("Lev"      . "Leviticus")
    ("Num"      . "Numbers")
    ("Deut"     . "Deuteronomy")
    ("Josh"     . "Joshua")
    ("Judg"     . "Judges")
    ("Ruth"     . "Ruth")
    ("I Sam"    . "1 Samuel")
    ("II Sam"   . "2 Samuel")
    ("I Kgs"    . "1 Kings")
    ("II Kgs"   . "2 Kings")
    ("I Chr"    . "1 Chronicles")
    ("II Chr"   . "2 Chronicles")
    ("Ezra"     . "Ezra")
    ("Neh"      . "Nehemiah")
    ("Esth"     . "Esther")
    ("Job"      . "Job")
    ("Ps"       . "Psalms")
    ("Prov"     . "Proverbs")
    ("Eccl"     . "Ecclesiastes")
    ("Song"     . "Song of Solomon")
    ("Isa"      . "Isaiah")
    ("Jer"      . "Jeremiah")
    ("Lam"      . "Lamentations")
    ("Ezek"     . "Ezekiel")
    ("Dan"      . "Daniel")
    ("Hos"      . "Hosea")
    ("Joel"     . "Joel")
    ("Amos"     . "Amos")
    ("Obad"     . "Obadiah")
    ("Jonah"    . "Jonah")
    ("Mic"      . "Micah")
    ("Nah"      . "Nahum")
    ("Hab"      . "Habakkuk")
    ("Zeph"     . "Zephaniah")
    ("Hag"      . "Haggai")
    ("Zech"     . "Zechariah")
    ("Mal"      . "Malachi")
    ;; New Testament
    ("Matt"     . "Matthew")
    ("Mark"     . "Mark")
    ("Luke"     . "Luke")
    ("John"     . "John")
    ("Acts"     . "Acts")
    ("Rom"      . "Romans")
    ("I Cor"    . "1 Corinthians")
    ("II Cor"   . "2 Corinthians")
    ("Gal"      . "Galatians")
    ("Eph"      . "Ephesians")
    ("Phil"     . "Philippians")
    ("Col"      . "Colossians")
    ("I Thess"  . "1 Thessalonians")
    ("II Thess" . "2 Thessalonians")
    ("I Tim"    . "1 Timothy")
    ("II Tim"   . "2 Timothy")
    ("Tit"      . "Titus")
    ("Titus"    . "Titus")
    ("Phlm"     . "Philemon")
    ("Heb"      . "Hebrews")
    ("Jas"      . "James")
    ("I Pet"    . "1 Peter")
    ("II Pet"   . "2 Peter")
    ("I John"   . "1 John")
    ("II John"  . "2 John")
    ("III John" . "3 John")
    ("Jude"     . "Jude")
    ("Rev"      . "Revelation")
    ;; Apocrypha
    ("Tob"      . "Tobit")
    ("Jdt"      . "Judith")
    ("I Macc"   . "1 Maccabees")
    ("II Macc"  . "2 Maccabees")
    ("Wis"      . "Wisdom of Solomon")
    ("Ecclus"   . "Sirach")
    ("Sir"      . "Sirach")
    ("Bar"      . "Baruch"))
  "Lectionary book abbreviations (Roman-numeral style) to full Oremus names.")

(defun bcp-1928--expand-book (abbrev)
  "Expand a lectionary book ABBREV to its full Oremus name."
  (or (cdr (assoc abbrev bcp-1928--book-expansions))
      abbrev))

(defun bcp-1928--last-verse-in-text (text)
  "Return the last `bcp-verse' property value in TEXT, or nil."
  (let ((pos 0) (len (length text)) (last nil))
    (while (< pos len)
      (let ((v (get-text-property pos 'bcp-verse text)))
        (when v (setq last v)))
      (setq pos (next-single-property-change pos 'bcp-verse text len)))
    last))

(defun bcp-1928--ref-label (ref)
  "Return a short human-readable label for REF."
  (cond
   ;; :multiple (:multiple REF1 REF2 ...)
   ((and (listp ref) (keywordp (car ref)) (eq (car ref) :multiple))
    (mapconcat #'bcp-1928--ref-label (cdr ref) ", "))
   ;; Joined lesson: ((BOOK CH V) (BOOK CH V))
   ((and (listp ref) (listp (car ref)))
    (let* ((r1  (car ref))
           (r2  (cadr ref))
           (bk  (car r1))
           (ch1 (cadr r1))
           (v1  (caddr r1))
           (ch2 (cadr r2))
           (v2e (cadddr r2)))
      (cond
       ((and v1 v2e) (format "%s %d:%d-%d:%d" bk ch1 v1 ch2 v2e))
       ((and v1 ch2) (format "%s %d:%d-%d"    bk ch1 v1 ch2))
       (t            (format "%s %d-%d"        bk ch1 ch2)))))
   ;; Single ref: (BOOK CH) or (BOOK CH V1 V2)
   ((and (listp ref) (stringp (car ref)))
    (let ((bk (car ref))
          (ch (cadr ref))
          (v1 (caddr ref))
          (v2 (cadddr ref)))
      (cond
       ((null v1)    (format "%s %d"      bk ch))
       ((null v2)    (format "%s %d:%d"   bk ch v1))
       ((eq v2 'nil) (format "%s %d:%d"   bk ch v1))
       (t            (format "%s %d:%d-%d" bk ch v1 v2)))))
   (t (format "%s" ref))))

(defun bcp-1928--lectionary-ref-to-string (ref)
  "Convert REF to a passage string for Oremus."
  (cond
   ;; :multiple — join each sub-ref on its own line
   ((and (listp ref) (keywordp (car ref)) (eq (car ref) :multiple))
    (mapconcat #'bcp-1928--lectionary-ref-to-string (cdr ref) "\n"))
   ;; Joined lesson: ((BOOK CH1 V1 ?) (BOOK CH2 V2 V2e))
   ((and (listp ref) (listp (car ref)))
    (let* ((r1   (car ref))
           (r2   (cadr ref))
           (book (bcp-1928--expand-book (car r1)))
           (ch1  (cadr r1))
           (v1   (caddr r1))
           (ch2  (cadr r2))
           (v2   (caddr r2))
           (v2e  (cadddr r2)))
      (cond
       ((and v1 ch2 (null v2) (null v2e))
        (format "%s %d:%d-%d:200" book ch1 v1 ch2))
       ((and v1 ch2 v2e)
        (format "%s %d:%d-%d:%d" book ch1 v1 ch2 v2e))
       ((and v1 ch2 v2)
        (format "%s %d:%d-%d:%d" book ch1 v1 ch2 v2))
       (t
        (format "%s %d-%d" book ch1 ch2)))))
   ;; Single ref
   ((and (listp ref) (stringp (car ref)))
    (let ((book (bcp-1928--expand-book (car ref)))
          (ch   (cadr ref))
          (v1   (caddr ref))
          (v2   (cadddr ref)))
      (cond
       ((null v1)  (format "%s %d" book ch))
       ((null v2)  (if (> v1 1)
                       (format "%s %d:%d-%d" book ch v1 200)
                     (format "%s %d:%d" book ch v1)))
       ((eq v2 'nil) (format "%s %d:%d" book ch v1))
       (t          (format "%s %d:%d-%d" book ch v1 v2)))))
   (t (format "%s" ref))))

(defun bcp-1928--ref-label-with-text (ref text)
  "Return a display label for REF, appending the actual last verse when known."
  (let* ((v1 (and (listp ref) (stringp (car ref)) (caddr ref)))
         (v2 (and (listp ref) (stringp (car ref)) (cadddr ref))))
    (if (and text v1 (> v1 1) (null v2))
        (let ((last (bcp-1928--last-verse-in-text text)))
          (if last
              (format "%s-%d" (bcp-1928--ref-label ref) last)
            (bcp-1928--ref-label ref)))
      (bcp-1928--ref-label ref))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Rubric face
;;;; ══════════════════════════════════════════════════════════════════════════

(defface bcp-1928-rubric-red
  '((((background light)) :foreground "#8B0000" :height 0.85 :slant italic)
    (((background dark))  :foreground "#CD5C5C" :height 0.85 :slant italic)
    (t                    :foreground "red"     :height 0.85 :slant italic))
  "Face for 1928 BCP rubrics — traditional red."
  :group 'bcp-1928)

(defface bcp-1928-rubric-comment
  '((t :inherit font-lock-comment-face :height 0.85 :slant italic))
  "Face for 1928 BCP rubrics — muted comment colour."
  :group 'bcp-1928)

(defun bcp-1928--rubric-face ()
  "Return the rubric face per `bcp-1928-rubric-style'."
  (if (eq bcp-1928-rubric-style 'comment)
      'bcp-1928-rubric-comment
    'bcp-1928-rubric-red))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Thin insert wrappers
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--insert-heading (level text)
  "Insert a heading at LEVEL with TEXT."
  (bcp-liturgy-render--insert-heading level text))

(defun bcp-1928--insert-rubric (text)
  "Insert TEXT as a 1928-styled rubric."
  (bcp-liturgy-render--insert-rubric text #'bcp-1928--rubric-face))

(defun bcp-1928--insert-versicles (pairs)
  "Insert versicle PAIRS."
  (bcp-liturgy-render--insert-versicles pairs))

(defun bcp-1928--insert-fixed-text (name text)
  "Insert fixed TEXT identified by NAME."
  (bcp-liturgy-render--insert-fixed-text name text))

(defun bcp-1928--insert-text-block (text)
  "Insert a plain text block."
  (bcp-liturgy-render--insert-text-block text))

(defun bcp-1928--insert-canticle-text (text)
  "Insert canticle TEXT."
  (bcp-liturgy-render--insert-canticle-text text))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Office label and day identity
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--office-label (office)
  "Return a display string for OFFICE symbol."
  (if (eq office 'mattins) "Morning Prayer" "Evening Prayer"))

;; bcp-1928--week-key-season is defined in bcp-anglican-1928-data.el

(defun bcp-1928--day-identity (propers)
  "Return a plist describing the liturgical identity of the day in PROPERS.
Keys: :day-name :week-name :subdivision :season-name :season-symbol."
  (let* ((week-key (plist-get propers :week))
         (dow      (plist-get propers :dow))
         (season   (plist-get propers :season))
         (n        (symbol-name (or week-key 'unknown))))
    (cond

     ;; Advent
     ((string-match "^advent-\\([0-9]+\\)$" n)
      (let* ((num (string-to-number (match-string 1 n)))
             (suf (when (eq dow 'sunday)
                    (pcase num
                      (1 "First Sunday in Advent")
                      (2 "Second Sunday in Advent")
                      (3 "Third Sunday in Advent")
                      (4 "Fourth Sunday in Advent")))))
        (list :day-name suf :week-name (format "Advent %d" num)
              :subdivision nil :season-name "Advent" :season-symbol 'advent)))

     ;; Christmas Day itself
     ((eq week-key 'christmas)
      (list :day-name "Christmas Day" :week-name nil
            :subdivision nil :season-name "Christmas" :season-symbol 'christmas))

     ;; Christmas/Epiphany octave fixed days
     ((memq week-key '(st-stephen st-john-evangelist holy-innocents
                       december-29 december-30 december-31
                       circumcision epiphany
                       january-2 january-3 january-4 january-5))
      (let ((feast-name (plist-get propers :feast-name)))
        (list :day-name (or feast-name
                            (capitalize (replace-regexp-in-string "-" " " n)))
              :week-name nil
              :subdivision (if (memq week-key '(circumcision january-2 january-3
                                                january-4 january-5 epiphany))
                               "Epiphany Octave" "Christmas Octave")
              :season-name "Christmas" :season-symbol 'christmas)))

     ;; Sundays after Christmas
     ((string-match "^after-christmas-\\([0-9]+\\)$" n)
      (let ((num (string-to-number (match-string 1 n))))
        (list :day-name (when (eq dow 'sunday)
                          (format "Sunday after Christmas"))
              :week-name (format "After Christmas %d" num)
              :subdivision nil :season-name "Christmas" :season-symbol 'christmas)))

     ;; After Epiphany
     ((string-match "^after-epiphany-\\([0-9]+\\)$" n)
      (let* ((num (string-to-number (match-string 1 n)))
             (suf (when (eq dow 'sunday)
                    (pcase num
                      (1 "First Sunday after Epiphany")
                      (2 "Second Sunday after Epiphany")
                      (3 "Third Sunday after Epiphany")
                      (4 "Fourth Sunday after Epiphany")
                      (5 "Fifth Sunday after Epiphany")
                      (6 "Sixth Sunday after Epiphany")
                      (_ (format "%d. Sunday after Epiphany" num))))))
        (list :day-name suf :week-name (format "After Epiphany %d" num)
              :subdivision nil :season-name "Epiphany" :season-symbol 'epiphany)))

     ;; Pre-Lent
     ((eq week-key 'septuagesima)
      (list :day-name (when (eq dow 'sunday) "Septuagesima Sunday")
            :week-name "Septuagesima" :subdivision nil
            :season-name "Pre-Lent" :season-symbol 'pre-lent))
     ((eq week-key 'sexagesima)
      (list :day-name (when (eq dow 'sunday) "Sexagesima Sunday")
            :week-name "Sexagesima" :subdivision nil
            :season-name "Pre-Lent" :season-symbol 'pre-lent))
     ((eq week-key 'quinquagesima)
      (list :day-name (when (eq dow 'sunday) "Quinquagesima Sunday")
            :week-name "Quinquagesima" :subdivision nil
            :season-name "Pre-Lent" :season-symbol 'pre-lent))

     ;; Ash Wednesday
     ((eq week-key 'ash-wednesday)
      (list :day-name "Ash Wednesday" :week-name "Ash Wednesday"
            :subdivision nil :season-name "Lent" :season-symbol 'lent))

     ;; Lent
     ((string-match "^lent-\\([0-9]+\\)$" n)
      (let* ((num (string-to-number (match-string 1 n)))
             (suf (when (eq dow 'sunday)
                    (pcase num
                      (1 "First Sunday in Lent")
                      (2 "Second Sunday in Lent")
                      (3 "Third Sunday in Lent")
                      (4 "Fourth Sunday in Lent (Laetare)")
                      (5 "Fifth Sunday in Lent (Passion Sunday)")))))
        (list :day-name suf :week-name (format "Week %d of Lent" num)
              :subdivision nil :season-name "Lent" :season-symbol 'lent)))

     ;; Holy Week
     ((eq week-key 'palm-sunday)
      (list :day-name "Sunday next before Easter (Palm Sunday)"
            :week-name "Palm Sunday" :subdivision "Holy Week"
            :season-name "Lent" :season-symbol 'passiontide))
     ((eq week-key 'holy-monday)
      (list :day-name "Monday in Holy Week" :week-name "Holy Week"
            :subdivision "Holy Week" :season-name "Lent" :season-symbol 'passiontide))
     ((eq week-key 'holy-tuesday)
      (list :day-name "Tuesday in Holy Week" :week-name "Holy Week"
            :subdivision "Holy Week" :season-name "Lent" :season-symbol 'passiontide))
     ((eq week-key 'holy-wednesday)
      (list :day-name "Wednesday in Holy Week" :week-name "Holy Week"
            :subdivision "Holy Week" :season-name "Lent" :season-symbol 'passiontide))
     ((eq week-key 'maundy-thursday)
      (list :day-name "Thursday in Holy Week (Maundy Thursday)"
            :week-name "Holy Week" :subdivision "Holy Week"
            :season-name "Lent" :season-symbol 'passiontide))
     ((eq week-key 'good-friday)
      (list :day-name "Good Friday" :week-name "Holy Week"
            :subdivision "Holy Week" :season-name "Lent" :season-symbol 'passiontide))
     ((eq week-key 'easter-even)
      (list :day-name "Easter Even" :week-name "Holy Week"
            :subdivision "Holy Week" :season-name "Lent" :season-symbol 'passiontide))

     ;; Easter
     ((eq week-key 'easter)
      (list :day-name "Easter Day" :week-name "Easter Week"
            :subdivision "Easter Octave" :season-name "Eastertide"
            :season-symbol 'eastertide))
     ((eq week-key 'easter-monday)
      (list :day-name "Monday in Easter Week" :week-name "Easter Week"
            :subdivision "Easter Octave" :season-name "Eastertide"
            :season-symbol 'eastertide))
     ((eq week-key 'easter-tuesday)
      (list :day-name "Tuesday in Easter Week" :week-name "Easter Week"
            :subdivision "Easter Octave" :season-name "Eastertide"
            :season-symbol 'eastertide))

     ;; After Easter
     ((string-match "^after-easter-\\([0-9]+\\)$" n)
      (let* ((num (string-to-number (match-string 1 n)))
             (suf (when (eq dow 'sunday)
                    (pcase num
                      (1 "First Sunday after Easter (Low Sunday)")
                      (2 "Second Sunday after Easter")
                      (3 "Third Sunday after Easter")
                      (4 "Fourth Sunday after Easter")
                      (5 "Fifth Sunday after Easter (Rogation Sunday)")))))
        (list :day-name suf :week-name (format "After Easter %d" num)
              :subdivision nil :season-name "Eastertide" :season-symbol 'eastertide)))

     ;; Ascension
     ((eq week-key 'ascension)
      (list :day-name "Ascension Day" :week-name "Ascension"
            :subdivision nil :season-name "Eastertide" :season-symbol 'eastertide))
     ((eq week-key 'after-ascension)
      (list :day-name (when (eq dow 'sunday) "Sunday after Ascension")
            :week-name "After Ascension" :subdivision nil
            :season-name "Eastertide" :season-symbol 'eastertide))

     ;; Whitsuntide
     ((eq week-key 'whitsunday)
      (list :day-name "Whitsunday (Pentecost)" :week-name "Whitsun Week"
            :subdivision "Whitsun Week" :season-name "Eastertide"
            :season-symbol 'eastertide))
     ((eq week-key 'whit-monday)
      (list :day-name "Monday in Whitsun Week" :week-name "Whitsun Week"
            :subdivision "Whitsun Week" :season-name "Eastertide"
            :season-symbol 'eastertide))
     ((eq week-key 'whit-tuesday)
      (list :day-name "Tuesday in Whitsun Week" :week-name "Whitsun Week"
            :subdivision "Whitsun Week" :season-name "Eastertide"
            :season-symbol 'eastertide))

     ;; Trinity
     ((eq week-key 'trinity-sunday)
      (list :day-name "Trinity Sunday" :week-name "Trinity Sunday"
            :subdivision nil :season-name "Trinity" :season-symbol 'trinity))

     ((string-match "^after-trinity-\\([0-9]+\\)$" n)
      (let* ((num (string-to-number (match-string 1 n)))
             (suf (when (eq dow 'sunday)
                    (if (= num 25)
                        "Sunday next before Advent"
                      (format "Trinity %d" num)))))
        (list :day-name suf :week-name (format "Trinity %d" num)
              :subdivision nil :season-name "Trinity" :season-symbol 'trinity)))

     ;; Saints' days and everything else
     (t
      (let ((feast-name (plist-get propers :feast-name)))
        (list :day-name (or feast-name
                            (capitalize
                             (replace-regexp-in-string "-" " " n)))
              :week-name nil :subdivision nil
              :season-name "Saints' Days" :season-symbol 'saints))))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Opening sentences selector
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--select-opening-sentence (season date office)
  "Return one opening sentence for SEASON on DATE at OFFICE.
Returns a (TEXT CITATION) pair from the appropriate 1928 pool."
  (require 'bcp-common-anglican)
  (let* ((pool (if (eq office 'evensong)
                   bcp-common-anglican-opening-sentences-1928-evensong
                 bcp-common-anglican-opening-sentences-1928))
         ;; Try to pick a seasonally appropriate sentence
         (seasonal
          (cl-find-if
           (lambda (entry)
             ;; Simple heuristic: match season-relevant sentences by
             ;; checking comment structure (not reliable — fall through to pool)
             nil)
           pool))
         (fallback (nth (mod (calendar-absolute-from-gregorian date)
                             (length pool))
                        pool)))
    (or seasonal fallback)))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Step-type renderer
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--render-ordo-step (step propers psalms psalm-texts lesson-texts)
  "Render one ordo STEP using PROPERS, PSALMS, PSALM-TEXTS, LESSON-TEXTS."
  (let ((type (car step)))
    (pcase type

      ;; ── Rubric ─────────────────────────────────────────────────────────
      (:rubric
       (when-let* ((text (plist-get step :rubric)))
         (bcp-1928--insert-rubric text)))

      ;; ── Opening sentences ───────────────────────────────────────────────
      (:sentences
       (let* ((season (plist-get propers :season))
              (date   (plist-get propers :date))
              (office (plist-get propers :office))
              (sent   (bcp-1928--select-opening-sentence season date office))
              (text   (car sent))
              (cit    (cadr sent)))
         (when sent
           (let ((label (if (and (listp cit) (listp (car cit)))
                            (mapconcat #'bcp-1928--ref-label cit " / ")
                          (bcp-1928--ref-label cit))))
             (bcp-1928--insert-text-block
              (concat text " — " label))))))

      ;; ── Fixed text ─────────────────────────────────────────────────────
      (:text
       (let ((name      (plist-get step :text))
             (ref       (plist-get step :ref))
             (alt-creed (plist-get step :alt-creed)))
         (cond
          ((eq name 'lords-prayer)
           (bcp-liturgy-render--insert-lords-prayer))
          ;; Creed swap
          ((and (eq name 'apostles-creed)
                alt-creed
                (eq bcp-liturgy-creed 'nicene))
           (let ((text (symbol-value alt-creed)))
             (bcp-1928--insert-fixed-text
              'nicene-creed
              (if (stringp text) text
                (or (bcp-common-prayers-text text) "")))))
          (ref
           (let ((text (symbol-value ref)))
             (bcp-1928--insert-fixed-text
              (or name (intern (symbol-name ref)))
              (if (stringp text) text
                (or (bcp-common-prayers-text text) "")))))
          (t nil))))

      ;; ── Versicles ──────────────────────────────────────────────────────
      (:versicles
       (bcp-1928--insert-versicles (cdr step)))

      ;; ── Canticle ───────────────────────────────────────────────────────
      (:canticle
       (let* ((name        (plist-get step :canticle))
              (latin-title (plist-get step :latin))
              (exc-easter  (plist-get step :exception-easter))
              (exc-dom     (plist-get step :exception-day-of-month))
              (date        (plist-get propers :date))
              (dom         (cadr date))
              (is-easter   (and exc-easter
                                (eq (plist-get propers :season) 'eastertide)
                                (eq (plist-get propers :week) 'easter)))
              (dom-except  (and exc-dom date (= dom exc-dom))))
         (cond
          ;; Easter anthems replace Venite on Easter Day
          ((and is-easter (eq name 'venite))
           (bcp-1928--insert-heading 3 "Easter Anthems")
           (when-let* ((text (bcp-1928-collect-text 'easter-anthems)))
             (bcp-1928--insert-canticle-text text)))
          ;; Day-of-month exception: skip this canticle slot
          (dom-except nil)
          (t
           (let* ((title    (or latin-title
                                (bcp-liturgy-canticle-title name)
                                (symbol-name name)))
                  (text     (bcp-liturgy-canticle-get name)))
             (bcp-1928--insert-heading 3 title)
             (insert "\n")
             (if text
                 (progn
                   (bcp-1928--insert-canticle-text text)
                   (when (and bcp-liturgy-canticle-append-gloria
                              (bcp-liturgy-canticle-gloria-p name))
                     (bcp-1928--insert-canticle-text
                      (bcp-liturgy-canticle-gloria-text))))
               (bcp-1928--insert-rubric
                (format "[%s: text not yet available]" title))))))))

      ;; ── Alternatives ───────────────────────────────────────────────────
      (:alternatives
       (let* ((opts  (cl-remove-if #'keywordp
                                   (cl-remove-if-not #'listp (cdr step))))
              (first (car opts))
              (rest  (cdr opts)))
         (when first
           (let* ((name        (plist-get first :canticle))
                  (latin-title (plist-get first :latin))
                  (title       (or latin-title
                                   (bcp-liturgy-canticle-title name)
                                   (symbol-name name))))
             (bcp-1928--insert-heading 3 title)
             (when rest
               (bcp-1928--insert-rubric
                (format "[or: %s]"
                        (mapconcat
                         (lambda (o)
                           (or (plist-get o :latin)
                               (bcp-liturgy-canticle-title (plist-get o :canticle))
                               "alternative"))
                         rest " / "))))
             (let* ((exc-dom  (plist-get first :exception-day-of-month))
                    (date     (plist-get propers :date))
                    (dom      (when date (cadr date)))
                    (dom-exc  (and exc-dom dom (= dom exc-dom)))
                    (text     (bcp-liturgy-canticle-get name)))
               (cond
                (dom-exc nil)
                (text
                 (bcp-1928--insert-canticle-text text)
                 (when (and bcp-liturgy-canticle-append-gloria
                            (bcp-liturgy-canticle-gloria-p name))
                   (bcp-1928--insert-canticle-text
                    (bcp-liturgy-canticle-gloria-text))))
                (t
                 (bcp-1928--insert-rubric
                  (format "[%s: text not yet available]" title)))))))))

      ;; ── Psalm slot ─────────────────────────────────────────────────────
      (:psalm
       (dolist (p psalms)
         (let* ((key  (bcp-1928--psalm-label p))
                (text (cdr (assoc key psalm-texts))))
           (bcp-1928--insert-heading 3 key)
           (if text
               (progn
                 (bcp-1928--insert-text-block text)
                 (when bcp-liturgy-canticle-append-gloria
                   (bcp-1928--insert-text-block
                    (bcp-liturgy-canticle-gloria-text))))
             (insert (format "[[bible:%s][%s]]\n\n"
                             (bcp-1928--psalm-to-passage p) key))))))

      ;; ── Lesson slot ────────────────────────────────────────────────────
      (:lesson
       (let* ((which   (plist-get step :lesson))
              (key     (if (eq which 'second) "lesson2" "lesson1"))
              (lessons (plist-get propers :lessons))
              (ref     (plist-get lessons (if (eq which 'second)
                                              :lesson2 :lesson1)))
              (text    (cdr (assoc key lesson-texts))))
         (when ref
           (let ((label (bcp-1928--ref-label-with-text ref text)))
             (bcp-1928--insert-heading 3
               (format "%s Lesson: %s"
                       (if (eq which 'second) "Second" "First")
                       label))
             (if text
                 (bcp-1928--insert-text-block text)
               (insert (format "[[bible:%s][%s]]\n\n"
                               (bcp-1928--lectionary-ref-to-string ref)
                               label)))))))

      ;; ── Collect slot ───────────────────────────────────────────────────
      (:collect
       (let* ((which (plist-get step :collect))
              (ref   (plist-get step :ref)))
         (cond
          ((eq which 'day)
           (let* ((sym  (plist-get propers :collect))
                  (text (when sym (bcp-1928-collect-text sym))))
             (bcp-1928--insert-heading 3 "Collect of the Day")
             (if text
                 (insert text "\n")
               (insert (format ";; [collect for %s]\n\n"
                               (or sym "unknown"))))
             ;; Seasonal/repeated collect
             (when-let* ((sc  (plist-get propers :seasonal-collect))
                         (sct (bcp-1928-collect-text sc)))
               (bcp-1928--insert-rubric
                (pcase sc
                  ('advent-1   "The Collect of Advent (said daily until Christmas Eve):")
                  ('palm-sunday "The Collect for Palm Sunday (said daily until Good Friday):")
                  ('easter     "The Collect for Easter (said daily throughout Easter Week):")
                  (_           "Seasonal Collect:")))
               (bcp-1928--insert-fixed-text 'seasonal-collect sct))))
          (ref
           (let* ((data  (symbol-value ref))
                  (title (plist-get data :title))
                  (text  (bcp-common-prayers-text data)))
             (bcp-1928--insert-heading 3 (or title "Collect"))
             (when text (insert text "\n")))))))

      ;; ── Anthem ─────────────────────────────────────────────────────────
      (:anthem
       (bcp-1928--insert-rubric
        (or (plist-get step :rubric)
            "In Quires and Places where they sing, here followeth the Anthem.")))

      ;; ── Prayer slot ────────────────────────────────────────────────────
      (:prayer
       (let* ((ref   (plist-get step :ref))
              (data  (when ref (symbol-value ref)))
              (title (when data (plist-get data :title)))
              (text  (when data (bcp-common-prayers-text data))))
         (bcp-1928--insert-heading 3 (or title "Prayer"))
         (when text
           (bcp-1928--insert-fixed-text
            (or (plist-get step :prayer) (intern (symbol-name ref)))
            text))))

      ;; ── State prayers ──────────────────────────────────────────────────
      (:state-prayers
       (let ((tradition (plist-get step :tradition)))
         (dolist (prayer (bcp-liturgy-state-prayers tradition))
           (let* ((title (plist-get prayer :title))
                  (text  (bcp-common-prayers-text prayer)))
             (bcp-1928--insert-heading 3 (or title "Prayer"))
             (when text
               (bcp-1928--insert-fixed-text
                (or (plist-get prayer :name) 'state-prayer)
                text))))))

      (_ nil))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Main ordo walker
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--render-office (propers psalms psalm-texts date-str lesson-texts)
  "Render the 1928 BCP Office buffer.
Walks the morning or evening ordo, filling slots from PROPERS,
PSALMS, PSALM-TEXTS, and LESSON-TEXTS."
  (let* ((office        (plist-get propers :office))
         (feast-name    (plist-get propers :feast-name))
         (feast-rank    (plist-get propers :feast-rank))
         (ordo          (if (eq office 'mattins)
                            bcp-1928-ordo-morning
                          bcp-1928-ordo-evening))
         (office-label  (bcp-1928--office-label office))
         (day-id        (bcp-1928--day-identity propers))
         (communion-sym (plist-get propers :communion)))
    (with-current-buffer
        (bcp-liturgy-render--setup-buffer bcp-1928-office-buffer-name)

      ;; ── Title ────────────────────────────────────────────────────────
      (bcp-1928--insert-heading 1
        (format "%s — %s" office-label date-str))

      ;; ── Liturgical identity block ────────────────────────────────────
      (bcp-liturgy-render--insert-identity-block day-id feast-name feast-rank)
      (insert "\n")

      ;; ── Ordo walk ────────────────────────────────────────────────────
      (let* ((is-sunday  (let ((date (plist-get propers :date)))
                           (when date
                             (= (calendar-day-of-week date) 0))))
             (is-weekday (not is-sunday))
             (show-penit (not (and bcp-1928-omit-penitential-intro is-weekday)))
             (past-venite nil))

        (dolist (step ordo)
          (let ((type       (car step))
                (pos-before (point)))
            (cond
             ;; Penitential intro omission
             ((and (not show-penit) (not past-venite)
                   (memq type '(:rubric :sentences :text)))
              nil)
             ((and (not show-penit) (not past-venite)
                   (eq type :versicles))
              (setq past-venite t)
              (bcp-1928--render-ordo-step
               step propers psalms psalm-texts lesson-texts))
             ;; Absolution rubric — priest/bishop only
             ((and (eq type :rubric)
                   (string-match-p "Absolution\\|Remission of sins"
                                   (or (plist-get step :rubric) "")))
              (when (memq office-officiant '(priest bishop))
                (bcp-1928--render-ordo-step
                 step propers psalms psalm-texts lesson-texts)))
             ;; Absolution text — priest gets absolution; lay/deacon
             ;; substitutes the Trinity 21 collect
             ((and (eq type :text)
                   (eq (plist-get step :text) 'absolution))
              (if (memq office-officiant '(priest bishop))
                  (bcp-1928--render-ordo-step
                   step propers psalms psalm-texts lesson-texts)
                ;; Lay substitute: Trinity 21 collect
                (let ((text (bcp-1928-collect-text 'after-trinity-21)))
                  (if text
                      (bcp-1928--insert-fixed-text 'absolution text)
                    (bcp-1928--insert-rubric
                     "[Collect for the Twenty-First Sunday after Trinity]")))))
             ;; All other steps
             (t
              (setq past-venite t)
              (bcp-1928--render-ordo-step
               step propers psalms psalm-texts lesson-texts)))
            ;; Blank line after each step that produced output
            (when (> (point) pos-before)
              (insert "\n")))))

      ;; ── Communion propers ────────────────────────────────────────────
      (when (and bcp-1928-show-communion-propers communion-sym)
        (let ((cp (bcp-1928-communion-proper communion-sym)))
          (when cp
            (bcp-1928--insert-heading 2 "Communion Propers")
            (when-let* ((ep (plist-get cp :epistle))
                        (go (plist-get cp :gospel)))
              (let* ((ep-label (bcp-1928--ref-label ep))
                     (go-label (bcp-1928--ref-label go))
                     (ep-text  (cdr (assoc "epistle" lesson-texts)))
                     (go-text  (cdr (assoc "gospel"  lesson-texts))))
                (bcp-1928--insert-heading 3 (format "Epistle: %s" ep-label))
                (if ep-text
                    (bcp-1928--insert-text-block ep-text)
                  (insert (format "[[bible:%s][%s]]\n\n"
                                  (bcp-1928--lectionary-ref-to-string ep)
                                  ep-label)))
                (bcp-1928--insert-heading 3 (format "Gospel: %s" go-label))
                (if go-text
                    (bcp-1928--insert-text-block go-text)
                  (insert (format "[[bible:%s][%s]]\n\n"
                                  (bcp-1928--lectionary-ref-to-string go)
                                  go-label))))
            (insert "\n"))))

      ;; ── Finalise ─────────────────────────────────────────────────────
      (bcp-reader--add-verse-number-overlays)
      (when bcp-reader-paragraph-mode
        (bcp-reader--add-paragraph-overlays))
      (bcp-liturgy-render--finalise-buffer)
      (current-buffer)))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Psalm helpers (delegate to shared BCP cycle)
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--psalm-label (psalm-ref)
  "Format a BCP psalm reference as a short label."
  (if (consp psalm-ref)
      (format "Ps 119:%d-%d" (car (cdr psalm-ref)) (cadr (cdr psalm-ref)))
    (format "Ps %d" psalm-ref)))

(defun bcp-1928--psalm-to-passage (psalm-ref)
  "Convert a psalm reference to an Oremus passage string."
  (if (consp psalm-ref)
      (format "Psalms 119:%d-%d" (car (cdr psalm-ref)) (cadr (cdr psalm-ref)))
    (format "Psalms %d" psalm-ref)))

(provide 'bcp-angular-1928-render)
;;; bcp-angular-1928-render.el ends here
