;;; bcp-anglican-1928-render.el --- 1928 American BCP Office renderer -*- lexical-binding: t -*-

;;; Commentary:

;; BCP 1928-specific Office renderer.  Builds a tradition context (ctx) and
;; delegates the shared step dispatch and ordo walk to bcp-anglican-render.el.
;;
;; This file owns:
;;   - Book expansion table and ref utilities (Roman-numeral abbreviations)
;;   - Rubric face (red/comment) and its defcustom
;;   - bcp-1928--rubric-face       — :rubric-face-fn for the ctx
;;   - bcp-1928--day-identity      — 1928-specific liturgical identity plist
;;   - bcp-1928--select-opening-sentence — single sentence selector
;;   - bcp-1928--seasonal-collect-rubric — :seasonal-collect-rubric-fn for ctx
;;   - bcp-1928--easter-anthems-p  — :easter-anthems-p-fn for the ctx
;;   - bcp-1928--opening-sentences — :opening-sentences-fn for the ctx
;;   - bcp-1928--post-office       — :post-office-fn (communion propers)
;;   - bcp-1928--psalm-label / bcp-1928--psalm-to-passage
;;   - bcp-1928--no-priest-rubric  — :absolution-no-priest-rubric-fn for the ctx
;;   - bcp-1928--step-override     — :step-override-fn for the ctx
;;   - bcp-1928--build-ctx         — assembles the full tradition context
;;   - bcp-1928--render-office     — thin wrapper calling the shared walker
;;
;; What does NOT live here:
;;   - Buffer primitives (bcp-liturgy-render.el)
;;   - Shared step dispatch and ordo walker (bcp-anglican-render.el)
;;   - Ordo plist data (bcp-anglican-1928-ordo.el)
;;   - Collect/lesson/calendar dispatch (bcp-anglican-1928.el)
;;   - Defcustoms for rubrical options (bcp-anglican-1928.el)

;;; Code:


(require 'cl-lib)
(require 'calendar)
(require 'bcp-render)
(require 'bcp-liturgy-render)
(require 'bcp-common-canticles)
(require 'bcp-anglican-render)
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

(defun bcp-1928--ref-label (ref)
  "Return a short human-readable label for REF.
String REF is returned as-is (it is already an abbreviated passage
string, e.g. \"Luke 1:46-55\")."
  (cond
   ((stringp ref) ref)
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
  "Convert REF to a passage string for Oremus.
Also accepts string form \"Book CH[:V[-V2]]\" (used for canticle :ref
in bcp-anglican-1928-ordo.el); the leading book abbreviation is
expanded if known."
  (cond
   ;; String form — expand leading book abbreviation, pass rest through.
   ((stringp ref)
    (if (string-match "\\`\\(.+?\\) \\([0-9].*\\)\\'" ref)
        (format "%s %s"
                (bcp-1928--expand-book (match-string 1 ref))
                (match-string 2 ref))
      ref))
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


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Tradition context helpers
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--seasonal-collect-rubric (sc)
  "Return the rubric string for seasonal collect SC."
  (pcase sc
    ('advent-1    "The Collect of Advent (said daily until Christmas Eve):")
    ('palm-sunday "The Collect for Palm Sunday (said daily until Good Friday):")
    ('easter      "The Collect for Easter (said daily throughout Easter Week):")
    (_            "Seasonal Collect:")))

(defun bcp-1928--easter-anthems-p (propers)
  "Return t if Easter Anthems should replace the Venite (Easter Day only)."
  (eq (plist-get propers :week) 'easter))

(defun bcp-1928--opening-sentences (season date office)
  "Return a list of opening sentences for SEASON on DATE at OFFICE.
Wraps `bcp-1928--select-opening-sentence' in a single-element list."
  (when-let* ((sent (bcp-1928--select-opening-sentence season date office)))
    (list sent)))

(defun bcp-1928--post-office (propers lesson-texts ctx)
  "Render 1928 communion propers after the office when configured."
  (let ((communion-sym (plist-get propers :communion))
        (ref-label-fn  (plist-get ctx :ref-label-fn))
        (ref-str-fn    (plist-get ctx :ref-to-string-fn)))
    (when (and bcp-1928-show-communion-propers communion-sym)
      (let ((cp (bcp-1928-communion-proper communion-sym)))
        (when cp
          (bcp-liturgy-render--insert-heading 2 "Communion Propers")
          (when-let* ((ep (plist-get cp :epistle))
                      (go (plist-get cp :gospel)))
            (let* ((ep-label (funcall ref-label-fn ep))
                   (go-label (funcall ref-label-fn go))
                   (ep-txt   (cdr (assoc "epistle" lesson-texts)))
                   (go-txt   (cdr (assoc "gospel"  lesson-texts))))
              (bcp-liturgy-render--insert-heading 3 (format "Epistle: %s" ep-label))
              (if ep-txt
                  (bcp-liturgy-render--insert-text-block ep-txt)
                (bcp-liturgy-render--insert-passage-fallback
                 (funcall ref-str-fn ep) ep-label
                 bible-commentary-translation))
              (insert "\n")
              (bcp-liturgy-render--insert-heading 3 (format "Gospel: %s" go-label))
              (if go-txt
                  (bcp-liturgy-render--insert-text-block go-txt)
                (bcp-liturgy-render--insert-passage-fallback
                 (funcall ref-str-fn go) go-label
                 bible-commentary-translation)))
            (insert "\n")))))))

(defun bcp-1928--invitatory (propers)
  "Return the seasonal invitatory antiphon for PROPERS, or nil.
Called from the Anglican render layer before the Venite heading.
Returns nil on ordinary weekdays and Sundays after Trinity."
  (require 'bcp-common-anglican)
  (let* ((week  (plist-get propers :week))
         (date  (plist-get propers :date))
         (feast (plist-get propers :feast))
         (rank  (or (plist-get propers :feast-rank) 0))
         (dow   (when date (calendar-day-of-week date)))
         (month (when date (car date)))
         (day   (when date (cadr date))))
    (cond
     ;; Sundays in Advent (advent-1 through advent-4)
     ((and (memq week '(advent-1 advent-2 advent-3 advent-4))
           (eql dow 0))
      bcp-common-anglican-invitatory-advent-sundays)
     ;; Christmas Day until the Epiphany (Dec 25 – Jan 5)
     ((or (and (eql month 12) (>= day 25))
          (and (eql month 1) (<= day 5)))
      bcp-common-anglican-invitatory-christmas)
     ;; Epiphany and seven days after (Jan 6–13), and Transfiguration
     ((or (and (eql month 1) (>= day 6) (<= day 13))
          (eq feast 'transfiguration))
      bcp-common-anglican-invitatory-epiphany)
     ;; Monday in Easter Week until Ascension Day
     ;; Easter Day itself uses Easter Anthems (excluded upstream).
     ;; Resolved keys: easter (Wed-Sat), easter-monday, easter-tuesday,
     ;; after-easter-1 … after-easter-5.
     ((or (memq week '(easter-monday easter-tuesday))
          (and (eq week 'easter) (not (eql dow 0)))
          (and week (string-match-p "\\`after-easter-" (symbol-name week))))
      bcp-common-anglican-invitatory-easter)
     ;; Ascension Day until Whitsunday
     ;; Resolved: ascension, after-ascension (from sunday-after-ascension)
     ((memq week '(ascension after-ascension))
      bcp-common-anglican-invitatory-ascension)
     ;; Whitsunday and six days after
     ;; Resolved: whitsunday (Sun, Wed-Sat), whit-monday, whit-tuesday
     ((memq week '(whitsunday whit-monday whit-tuesday))
      bcp-common-anglican-invitatory-whitsun)
     ;; Trinity Sunday (resolved from 'trinity to 'trinity-sunday)
     ((eq week 'trinity-sunday)
      bcp-common-anglican-invitatory-trinity)
     ;; Purification (Feb 2) and Annunciation (Mar 25)
     ((memq feast '(purification annunciation))
      bcp-common-anglican-invitatory-incarnation)
     ;; Other festivals with proper Epistle and Gospel (tier 2 rank)
     ((and feast (>= rank 2))
      bcp-common-anglican-invitatory-saints)
     (t nil))))

(defun bcp-1928--venite-filter (text season)
  "Apply Venite vv.8–11 handling for the 1928 tradition.
Delegates to `bcp-anglican--venite-filter' with `bcp-1928-venite-lent-verses'
and `bcp-1928-venite-ps96-substitute'."
  (bcp-anglican--venite-filter text season
    bcp-1928-venite-lent-verses
    bcp-1928-venite-ps96-substitute))

(defun bcp-1928--no-priest-rubric (ordo)
  "Return the 'no priest' rubric text found in ORDO, or nil.
The rubric step carries :alt-collect; it is suppressed in the main ordo
walk by `bcp-1928--step-override' and re-emitted before the substitute collect."
  (when-let* ((step (cl-find-if (lambda (s) (plist-get s :alt-collect)) ordo)))
    (plist-get step :rubric)))

(defun bcp-1928--step-override (step propers)
  "Handle 1928-specific rubrical options for STEP.
Returns :skip, :handled, or nil (shared handling)."
  (cond
   ;; No-priest rubric: suppress the conditional rubric from the main ordo walk
   ((and (eq (car step) :rubric) (plist-get step :alt-collect))
    :skip)
   ;; Venite omission on Ash Wednesday and Good Friday (rubrical option)
   ((and bcp-1928-venite-omit-ash-good-friday
         (eq (car step) :canticle)
         (eq (plist-get step :canticle) 'venite))
    (let ((week (plist-get propers :week)))
      (when (memq week '(ash-wednesday good-friday))
        :skip)))))

(defun bcp-1928--build-ctx (propers)
  "Build the Anglican render context for the 1928 American BCP.
Resolves current defcustom values and registers all tradition callbacks."
  (let* ((date      (plist-get propers :date))
         (is-sunday (when date (= (calendar-day-of-week date) 0))))
    (list
     :rubric-face-fn                #'bcp-1928--rubric-face
     :collect-text-fn               #'bcp-1928-collect-text
     :ref-to-string-fn              #'bcp-1928--lectionary-ref-to-string
     :ref-label-fn                  #'bcp-1928--ref-label
     :psalm-label-fn                #'bcp-1928--psalm-label
     :psalm-to-passage-fn           #'bcp-1928--psalm-to-passage
     :opening-sentences-fn          #'bcp-1928--opening-sentences
     :easter-anthems-p-fn           #'bcp-1928--easter-anthems-p
     :venite-filter-fn              #'bcp-1928--venite-filter
     :invitatory-fn                 #'bcp-1928--invitatory
     :officiant                     office-officiant
     :show-penitential-intro        (not (and bcp-1928-omit-penitential-intro
                                              (not is-sunday)))
     :absolution-substitute-key     'after-trinity-21
     :absolution-no-priest-rubric-fn #'bcp-1928--no-priest-rubric
     :seasonal-collect-rubric-fn    #'bcp-1928--seasonal-collect-rubric
     :additional-prayers            nil
     :step-override-fn              #'bcp-1928--step-override
     :post-office-fn                #'bcp-1928--post-office
     :day-id-fn                     #'bcp-1928--day-identity
     :office-label-fn               #'bcp-anglican-render--office-label
     :office-order                  '(mattins evensong)
     :propers-fn                    #'bcp-1928--propers-fn
     :ordo-for-office               #'bcp-1928--ordo-for-office
     :buffer-name                   bcp-1928-office-buffer-name
     ;; Rubric default for the state-prayer slot.  US 1928 BCP defaults
     ;; to the President-and-Civil-Authority form; users override per
     ;; language via `bcp-state-set-override-by-language'.
     :state-set                     'us-1928)))

(defun bcp-1928--propers-fn (date office)
  "Return propers for DATE (M D Y) at OFFICE — used by prior-office simulation."
  (bcp-1928-propers-for-date (nth 0 date) (nth 1 date) (nth 2 date) office))

(defun bcp-1928--ordo-for-office (office)
  "Return the 1928 ordo list for OFFICE (mattins or evensong)."
  (if (eq office 'mattins) bcp-1928-ordo-morning bcp-1928-ordo-evening))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Main entry point
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--render-office (propers psalms psalm-texts date-str lesson-texts)
  "Render the 1928 American BCP Office buffer.
Builds the tradition context and delegates to the shared Anglican walker."
  (let* ((office (plist-get propers :office))
         (ordo   (if (eq office 'mattins)
                     bcp-1928-ordo-morning
                   bcp-1928-ordo-evening))
         (ctx    (bcp-1928--build-ctx propers)))
    (bcp-anglican-render--render-office
     propers psalms psalm-texts date-str lesson-texts ordo ctx)))

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

(provide 'bcp-anglican-1928-render)
;;; bcp-anglican-1928-render.el ends here
