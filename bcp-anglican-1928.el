;;; bcp-anglican-1928.el --- 1928 American BCP Daily Office -*- lexical-binding: t -*-

;; Keywords: bible, bcp, liturgy, daily-office
;; Package-Requires: ((emacs "28.1") (bible-commentary "0.2.0"))

;;; Commentary:

;; Main module for the 1928 American Book of Common Prayer Daily Office.
;; Contains:
;;   - Lesson and collect dispatch layer
;;   - Communion-proper lookup
;;   - Interactive Office commands
;;
;; Primary entry point: M-x bcp-1928-open-office
;;
;; Load order:
;;   (require 'bcp-anglican-1928-calendar)
;;   (require 'bcp-anglican-1928-data)
;;   (require 'bcp-anglican-1928-lectionary)
;;   (require 'bcp-anglican-1928-render)
;;   (require 'bcp-anglican-1928)

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-fetcher)
(require 'bcp-reader)
(require 'bcp-anglican-1928-calendar)
(require 'bcp-anglican-1928-data)
(require 'bcp-anglican-1928-lectionary)
(require 'bcp-anglican-1928-render)
(require 'bcp-liturgy-hours)
(require 'bcp-liturgy-dispatch)


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Customisation
;;;; ──────────────────────────────────────────────────────────────────────────

(defcustom bcp-1928-office-buffer-name "*BCP 1928 Daily Office*"
  "Name of the buffer used for the 1928 Daily Office."
  :type  'string
  :group 'bcp-1928)

(defcustom bcp-1928-show-communion-propers t
  "Whether to include Communion propers (Epistle, Gospel) in the Office buffer."
  :type  'boolean
  :group 'bcp-1928)

(defcustom bcp-1928-office-date nil
  "Override date/time for the 1928 Office.
A decoded-time list (SEC MIN HOUR DAY MONTH YEAR ...).
If nil, uses the current date and time."
  :type  '(choice (const nil) (repeat integer))
  :group 'bcp-1928)

(defcustom bcp-1928-omit-penitential-intro nil
  "Whether to omit the penitential introduction on weekdays.
When non-nil, the opening sentences through the absolution are omitted.
Permitted by rubric on weekdays; not recommended on Sundays or principal feasts."
  :type  'boolean
  :group 'bcp-1928)

(defcustom bcp-1928-canonical-hour-grouping
  '((matins   . mattins)
    (lauds    . mattins)
    (prime    . mattins)
    (terce    . mattins)
    (sext     . evensong)
    (none     . evensong)
    (vespers  . evensong)
    (compline . evensong))
  "Alist mapping canonical hour symbols to 1928 BCP office symbols.
Values are \\='mattins or \\='evensong."
  :type  '(alist :key-type symbol
                 :value-type (choice (const mattins) (const evensong)))
  :group 'bcp-1928)

(defcustom bcp-1928-rubric-style 'red
  "Display style for rubrics in the 1928 Daily Office buffer.
  `red'     — traditional liturgical red (default)
  `comment' — inherits `font-lock-comment-face' (muted, theme-aware)"
  :type  '(choice (const red) (const comment))
  :group 'bcp-1928)

(defcustom bcp-1928-venite-lent-verses 'lent
  "How to handle Venite verses 8–11 (\"To day if ye will hear his voice...\").
The 1928 American BCP omits these penitential verses outside Lent,
optionally substituting verses from Psalm 96 in their place.

  `always' — retain vv.8–11 throughout the year
  `lent'   — retain in Lent; omit (or substitute) otherwise (1928 default)
  `never'  — always omit (or substitute) vv.8–11

See also `bcp-1928-venite-ps96-substitute'.
Note: the Venite is not read at all on the nineteenth day of the month,
when Psalm 95 falls in the regular course of psalms."
  :type  '(choice (const :tag "Always" always)
                  (const :tag "Lent only" lent)
                  (const :tag "Never" never))
  :group 'bcp-1928)

(defcustom bcp-1928-venite-ps96-substitute t
  "Whether to substitute Psalm 96 verses for Venite vv.8–11 when they are absent.
When non-nil and `bcp-1928-venite-lent-verses' causes vv.8–11 to be omitted,
selected verses from Psalm 96 are inserted in their place, per the 1928
American BCP rubric.
Note: the Psalm 96 substitute is not yet implemented; this setting is
recorded but has no effect until the fetch and insertion logic is added."
  :type  'boolean
  :group 'bcp-1928)

(defcustom bcp-1928-lectionary 'original-1928
  "Lectionary to use for the 1928 American BCP Daily Office.

  `original-1928' — the original lectionary as printed in the 1928 edition
                    (default; currently the only implemented option)
  `revised-1945'  — the substantially revised lectionary adopted in 1945;
                    not yet implemented"
  :type  '(choice (const :tag "Original 1928 edition" original-1928)
                  (const :tag "Revised 1945 edition (not yet implemented)" revised-1945))
  :group 'bcp-1928)


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Internal: day-key resolution
;;;; ──────────────────────────────────────────────────────────────────────────

;; The calendar module returns a week-key + DOW pair.  For most days, the
;; week-key is the right liturgical identifier.  But for a few seasons the
;; 1928 BCP assigns different collect/communion-proper keys to individual
;; days within the same calendar week.  This table captures those mappings.

(defun bcp-1928--resolve-day-key (week-key dow)
  "Return the specific liturgical day key for WEEK-KEY and DOW.
For most days returns WEEK-KEY unchanged.  Handles:
  Holy Week weekdays → holy-monday, holy-tuesday, …, easter-even
  Easter octave Mon/Tue → easter-monday, easter-tuesday
  Whitsun week Mon/Tue → whit-monday, whit-tuesday
  Trinity Sunday → trinity-sunday
  Sunday after Ascension → after-ascension
  Sunday Next Before Advent → after-trinity-25"
  (cond
   ;; Holy Week
   ((and (eq week-key 'palm-sunday) (eq dow 'monday))    'holy-monday)
   ((and (eq week-key 'palm-sunday) (eq dow 'tuesday))   'holy-tuesday)
   ((and (eq week-key 'palm-sunday) (eq dow 'wednesday)) 'holy-wednesday)
   ((and (eq week-key 'palm-sunday) (eq dow 'thursday))  'maundy-thursday)
   ((and (eq week-key 'palm-sunday) (eq dow 'friday))    'good-friday)
   ((and (eq week-key 'palm-sunday) (eq dow 'saturday))  'easter-even)
   ;; Easter octave
   ((and (eq week-key 'easter) (eq dow 'monday))         'easter-monday)
   ((and (eq week-key 'easter) (eq dow 'tuesday))        'easter-tuesday)
   ;; Whitsun week
   ((and (eq week-key 'whitsunday) (eq dow 'monday))     'whit-monday)
   ((and (eq week-key 'whitsunday) (eq dow 'tuesday))    'whit-tuesday)
   ;; Trinity Sunday (calendar returns 'trinity; collect key is 'trinity-sunday)
   ((eq week-key 'trinity)                               'trinity-sunday)
   ;; Sunday after Ascension (calendar: 'sunday-after-ascension;
   ;; collect/proper key: 'after-ascension)
   ((eq week-key 'sunday-after-ascension)                'after-ascension)
   ;; Sunday Next Before Advent (calendar: 'sunday-before-advent;
   ;; collect/proper key: 'after-trinity-25)
   ((eq week-key 'sunday-before-advent)                  'after-trinity-25)
   ;; Default: use week-key as-is
   (t week-key)))

;; A few feasts have different keys between bcp-1928-feast-data (calendar)
;; and bcp-1928-communion-propers (data).
(defconst bcp-1928--feast-proper-sym-alist
  '((st-philip-and-james . ss-philip-and-james)
    (st-simon-and-jude   . ss-simon-and-jude))
  "Alist mapping feast-data symbols to their communion-proper symbols.")

(defun bcp-1928--proper-sym-for-feast (feast-sym)
  "Return the communion-proper key for FEAST-SYM, accounting for name variants."
  (or (cdr (assq feast-sym bcp-1928--feast-proper-sym-alist))
      feast-sym))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Seasonal collect
;;;; ──────────────────────────────────────────────────────────────────────────

;; The 1928 BCP directs certain collects to be repeated as seasonal collects
;; (appended after the collect of the day):
;;   Advent 1  — "repeated every day…until Christmas Eve"
;;   Ash Wed   — "to be read every day in Lent after the Collect of the Day"
;;   Palm Sun  — "repeated every day…until Good Friday" (Mon-Sat Holy Week)
;;   Ascension — "to be said daily throughout the Octave" (Mon-Sat only)

(defconst bcp-1928-seasonal-collect-table
  '((advent      . advent-1)
    (christmas   . nil)
    (epiphany    . nil)
    (pre-lent    . nil)
    (lent        . ash-wednesday)
    (passiontide . palm-sunday)   ; Mon-Sat of Holy Week (not Palm Sunday itself)
    (eastertide  . nil)
    (ascensiontide . ascension)   ; Mon-Sat between Ascension and Whitsunday
    (trinity     . nil))
  "Alist mapping season symbols to the seasonal collect appended after the day's collect.
nil means no seasonal collect for that season.")

(defun bcp-1928-seasonal-collect (month day year)
  "Return the seasonal collect symbol for (MONTH DAY YEAR), or nil.
Returns nil on days that have their OWN collect (Palm Sunday, Ascension Day,
Easter Day) so the seasonal collect is not duplicated."
  (let* ((pos      (bcp-1928-liturgical-day month day year))
         (week-key (car pos))
         (dow      (cdr pos))
         (day-key  (bcp-1928--resolve-day-key week-key dow))
         (season   (bcp-1928--week-key-season day-key)))
    ;; Do not add a seasonal collect when the collect of the day IS the
    ;; seasonal collect (Palm Sunday, Easter Day, Ascension Day, Ash Wednesday)
    (unless (memq day-key '(palm-sunday easter ascension ash-wednesday
                            easter-monday easter-tuesday))
      (cdr (assq season bcp-1928-seasonal-collect-table)))))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Preceding Sunday helper
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928--preceding-sunday (month day year)
  "Return the date of the most recent Sunday on or before (MONTH DAY YEAR)."
  (let* ((abs (calendar-absolute-from-gregorian (list month day year)))
         (dow (calendar-day-of-week (list month day year))))
    (calendar-gregorian-from-absolute (- abs dow))))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Collect of the day
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928-collect-of-day (month day year)
  "Return the collect symbol for (MONTH DAY YEAR).

Checks fixed feasts (tier 2) first, then the liturgical day key.
Falls back to the preceding Sunday's collect for ferial days without
a proper collect."
  (let* ((pos      (bcp-1928-liturgical-day month day year))
         (week-key (car pos))
         (dow      (cdr pos))
         (day-key  (bcp-1928--resolve-day-key week-key dow))
         ;; Fixed feasts on this date
         (feast-syms (bcp-1928-feasts-for-date month day))
         ;; Pick the highest-rank fixed feast that has a collect
         (feast-sym
          (cl-find-if
           (lambda (fs)
             (and (<= (bcp-1928-feast-rank fs) 2)
                  (bcp-1928-collect fs)))
           feast-syms)))
    (or
     ;; Tier 2 fixed feast with a proper collect
     (when feast-sym feast-sym)
     ;; Liturgical day key has a proper collect
     (when (bcp-1928-collect day-key) day-key)
     ;; Fall back to the preceding Sunday's collect
     (let* ((sun   (bcp-1928--preceding-sunday month day year))
            (sm    (car sun)) (sd (cadr sun)) (sy (caddr sun))
            (s-pos (bcp-1928-liturgical-day sm sd sy))
            (s-key (car s-pos))
            (s-dow (cdr s-pos))
            (s-day (bcp-1928--resolve-day-key s-key s-dow)))
       (when (bcp-1928-collect s-day) s-day)))))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Office lessons
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928--holy-day-lessons (feast-sym office)
  "Return the lesson plist for FEAST-SYM at OFFICE, or nil.
Looks up FEAST-SYM in `bcp-1928-holy-day-lessons'.
OFFICE is \\='mattins or \\='evensong."
  (when-let* ((entry      (assq feast-sym bcp-1928-holy-day-lessons))
              (day-entry  (assq 'day (cdr entry)))
              (off-key    (if (eq office 'mattins) :mattins :evensong))
              (off-plist  (plist-get (cdr day-entry) off-key)))
    (when (or (plist-get off-plist :lesson1)
              (plist-get off-plist :lesson2))
      off-plist)))

(defun bcp-1928--lesson-table-lookup (week-key dow office)
  "Return the lesson plist for WEEK-KEY + DOW at OFFICE, or nil.
Looks up in `bcp-1928-lesson-table'.
OFFICE is \\='mattins or \\='evensong."
  (when-let* ((week-entry (assq week-key bcp-1928-lesson-table))
              (dow-entry  (assq dow (cdr week-entry)))
              (off-key    (if (eq office 'mattins) :mattins :evensong))
              (off-plist  (plist-get (cdr dow-entry) off-key)))
    (when (or (plist-get off-plist :lesson1)
              (plist-get off-plist :lesson2))
      off-plist)))

(defun bcp-1928-office-lessons (month day year office)
  "Return the Office lessons for (MONTH DAY YEAR) at OFFICE.

OFFICE is \\='mattins or \\='evensong.

Returns a plist (:lesson1 REF :lesson2 REF :source SYMBOL) where
SOURCE is one of:
  feast-proper  — proper lessons for a fixed feast day
  calendar      — from the ordinary 1928 lesson table

Precedence:
  1. Tier 2 fixed feast proper lessons (from bcp-1928-holy-day-lessons)
  2. Christmas/Epiphany octave date-specific lessons (same table)
  3. Ordinary weekly lessons (from bcp-1928-lesson-table)"
  (let* ((pos      (bcp-1928-liturgical-day month day year))
         (week-key (car pos))
         (dow      (cdr pos))
         ;; Check for fixed feasts (tier 2)
         (feast-syms (bcp-1928-feasts-for-date month day))
         (feast-sym  (cl-find-if
                      (lambda (fs) (<= (bcp-1928-feast-rank fs) 2))
                      feast-syms))
         ;; Feast proper lessons (tier-2 fixed feast)
         (feast-off  (when feast-sym
                       (bcp-1928--holy-day-lessons feast-sym office)))
         ;; Christmas/Epiphany octave: week-key is a date-specific symbol
         ;; (christmas, st-stephen, december-29, circumcision, january-2, etc.)
         ;; These are also in bcp-1928-holy-day-lessons.
         (date-key-off (unless feast-off
                         (bcp-1928--holy-day-lessons week-key office)))
         ;; Ordinary lesson table
         (table-off  (unless (or feast-off date-key-off)
                       (bcp-1928--lesson-table-lookup week-key dow office))))
    (cond
     (feast-off
      (list :lesson1 (plist-get feast-off :lesson1)
            :lesson2 (plist-get feast-off :lesson2)
            :source  'feast-proper))
     (date-key-off
      (list :lesson1 (plist-get date-key-off :lesson1)
            :lesson2 (plist-get date-key-off :lesson2)
            :source  'feast-proper))
     (table-off
      (list :lesson1 (plist-get table-off :lesson1)
            :lesson2 (plist-get table-off :lesson2)
            :source  'calendar))
     (t nil))))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Communion propers
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928-communion-proper-for-date (month day year)
  "Return the communion proper symbol for (MONTH DAY YEAR), or nil.

Checks fixed feasts first, then the liturgical day key, then Sunday propers."
  (let* ((pos      (bcp-1928-liturgical-day month day year))
         (week-key (car pos))
         (dow      (cdr pos))
         (day-key  (bcp-1928--resolve-day-key week-key dow))
         ;; Fixed feasts
         (feast-syms (bcp-1928-feasts-for-date month day))
         ;; Tier-2 feasts take precedence over the ordinary propers
         (feast-sym  (cl-find-if
                      (lambda (fs)
                        (and (<= (bcp-1928-feast-rank fs) 2)
                             (bcp-1928-communion-proper
                              (bcp-1928--proper-sym-for-feast fs))))
                      feast-syms)))
    (or
     ;; Tier-2 fixed feast proper
     (when feast-sym
       (bcp-1928--proper-sym-for-feast feast-sym))
     ;; Day-key has its own communion proper
     (when (bcp-1928-communion-proper day-key) day-key)
     ;; On Sundays, use the Sunday week-key proper (already resolved for
     ;; e.g. after-trinity-N Sundays which are the same as day-key on sunday)
     nil)))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Feast display info
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928--best-feast-for-date (month day year)
  "Return the highest-ranking feast symbol observed on (MONTH DAY YEAR), or nil."
  (let* ((feast-syms (bcp-1928-feasts-for-date month day))
         ;; Also check what the calendar says (for Christmas/Epiphany octave
         ;; days which aren't in bcp-1928-feast-data but ARE liturgical feasts)
         (pos        (bcp-1928-liturgical-day month day year))
         (week-key   (car pos))
         (cal-feast  (when (assq week-key bcp-1928-feast-data) week-key)))
    ;; Fixed feasts sorted by rank; pick best
    (or (cl-find-if (lambda (fs) (= (bcp-1928-feast-rank fs) 1)) feast-syms)
        (cl-find-if (lambda (fs) (= (bcp-1928-feast-rank fs) 2)) feast-syms)
        cal-feast
        (car feast-syms))))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Top-level dispatch
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928-propers-for-date (month day year office)
  "Return all liturgical propers for (MONTH DAY YEAR) at OFFICE.

OFFICE is \\='mattins or \\='evensong.

Returns a plist:
  :date              (MONTH DAY YEAR)
  :office            OFFICE
  :week              resolved liturgical day key
  :dow               day-of-week symbol
  :season            liturgical season symbol
  :feast             feast symbol or nil
  :feast-name        feast display name or nil
  :feast-rank        feast rank (1-3) or nil
  :lessons           (:lesson1 REF :lesson2 REF :source SYMBOL)
  :collect           collect symbol
  :seasonal-collect  seasonal collect symbol or nil
  :communion         communion proper symbol or nil"
  (let* ((pos        (bcp-1928-liturgical-day month day year))
         (week-key   (car pos))
         (dow        (cdr pos))
         (day-key    (bcp-1928--resolve-day-key week-key dow))
         (season     (bcp-1928--week-key-season day-key))
         (feast-sym  (bcp-1928--best-feast-for-date month day year))
         (feast-info (when feast-sym (bcp-1928-feast-info feast-sym)))
         (feast-name (when feast-info (plist-get feast-info :title)))
         (feast-rank (when feast-sym (bcp-1928-feast-rank feast-sym)))
         (lessons    (bcp-1928-office-lessons month day year office))
         (collect    (bcp-1928-collect-of-day month day year))
         (seas-coll  (bcp-1928-seasonal-collect month day year))
         (communion  (bcp-1928-communion-proper-for-date month day year)))
    (list :date            (list month day year)
          :office          office
          :week            day-key
          :dow             dow
          :season          season
          :feast           feast-sym
          :feast-name      feast-name
          :feast-rank      feast-rank
          :lessons         lessons
          :collect         collect
          :seasonal-collect seas-coll
          :communion       communion)))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Convenience accessors
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928-lesson1 (propers)
  "Return lesson 1 REF from a PROPERS plist."
  (plist-get (plist-get propers :lessons) :lesson1))

(defun bcp-1928-lesson2 (propers)
  "Return lesson 2 REF from a PROPERS plist."
  (plist-get (plist-get propers :lessons) :lesson2))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Office date helpers
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928--current-time ()
  "Return the effective time for the 1928 Office.
Checks `bcp-office-nav--override-time' first, then `bcp-1928-office-date',
then the current time."
  (or (and (boundp 'bcp-office-nav--override-time) bcp-office-nav--override-time)
      bcp-1928-office-date
      (decode-time)))

(defun bcp-1928--office-from-time (time)
  "Return \\='mattins or \\='evensong based on the hour in TIME.
Maps clock hour through `bcp-canonical-hour-from-time' and then through
`bcp-1928-canonical-hour-grouping'."
  (let* ((hour      (nth 2 time))
         (canonical (bcp-canonical-hour-from-time hour)))
    (or (cdr (assq canonical bcp-1928-canonical-hour-grouping))
        'mattins)))

(defun bcp-1928--date-from-time (time)
  "Return (MONTH DAY YEAR) from a decoded-time list."
  (list (nth 4 time) (nth 3 time) (nth 5 time)))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Oremus fetch helpers
;;;; ──────────────────────────────────────────────────────────────────────────

(defun bcp-1928--fetch-text (passage callback &optional translation)
  "Fetch PASSAGE from Oremus and call CALLBACK with formatted text."
  (bcp-fetcher-fetch passage callback translation))

(defun bcp-1928--fetch-all (passages callback)
  "Fetch all PASSAGES from Oremus, then call CALLBACK with an alist of results.

PASSAGES is a list of (KEY PASSAGE-STRING . TRANSLATION) triples.
CALLBACK receives an alist of (KEY . TEXT-OR-NIL).
Fetches are issued in parallel; CALLBACK is called once all complete."
  (if (null passages)
      (funcall callback nil)
    (let* ((total   (length passages))
           (results (make-vector total nil))
           (done    (cons 0 nil)))
      (cl-loop for entry in passages
               for idx from 0
               do (let* ((i  idx)
                         (k  (car entry))
                         (ps (cadr entry))
                         (tr (caddr entry)))
                    (bcp-1928--fetch-text
                     ps
                     (lambda (text)
                       (aset results i (cons k text))
                       (setcar done (1+ (car done)))
                       (when (= (car done) total)
                         (funcall callback (append results nil))))
                     tr))))))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Interactive commands
;;;; ──────────────────────────────────────────────────────────────────────────

;;;###autoload
(defun bcp-1928-open-office (&optional arg)
  "Open the 1928 American BCP Daily Office for today.

Determines Morning or Evening Prayer from the current hour.
Fetches all psalm and lesson texts before rendering.

With a prefix argument ARG, prompts for date and office."
  (interactive "P")
  (let* ((time     (if arg
                       (bcp-1928--prompt-office-time)
                     (bcp-1928--current-time)))
         (office   (bcp-1928--office-from-time time))
         (date     (bcp-1928--date-from-time time))
         (month    (car date))
         (day      (cadr date))
         (year     (caddr date))
         (propers  (bcp-1928-propers-for-date month day year office))
         (lessons  (plist-get propers :lessons))
         (l1       (plist-get lessons :lesson1))
         (l2       (plist-get lessons :lesson2))
         (comm-sym (plist-get propers :communion))
         (comm-d   (when comm-sym (bcp-1928-communion-proper comm-sym)))
         (ep-ref   (when comm-d (plist-get comm-d :epistle)))
         (go-ref   (when comm-d (plist-get comm-d :gospel)))
         (dow-sym  (if (eq office 'mattins) :morning :evening))
         (psalms   (bible-commentary-bcp-psalms-for-day day dow-sym))
         (date-str (format-time-string
                    "%A, %d %B %Y"
                    (encode-time (append '(0 0 12)
                                         (list day month year)
                                         '(nil nil nil)))))
         (psalm-tr   bible-commentary-psalm-translation)
         (lesson-tr  bible-commentary-translation)
         (psalm-passages
          (mapcar (lambda (p)
                    (list (bcp-1928--psalm-label p)
                          (bcp-1928--psalm-to-passage p)
                          psalm-tr))
                  psalms))
         (lesson-passages
          (delq nil
                (list
                 (when l1
                   (list "lesson1" (bcp-1928--lectionary-ref-to-string l1) lesson-tr))
                 (when l2
                   (list "lesson2" (bcp-1928--lectionary-ref-to-string l2) lesson-tr))
                 (when (and bcp-1928-show-communion-propers ep-ref)
                   (list "epistle" (bcp-1928--lectionary-ref-to-string ep-ref) lesson-tr))
                 (when (and bcp-1928-show-communion-propers go-ref)
                   (list "gospel"  (bcp-1928--lectionary-ref-to-string go-ref) lesson-tr))))))
    ;; Show buffer immediately with a loading message
    (with-current-buffer (get-buffer-create bcp-1928-office-buffer-name)
      (read-only-mode -1)
      (remove-overlays)
      (erase-buffer)
      (insert (format "Loading %s — %s…\n\nFetching %d passage(s) from Oremus.\n"
                      (bcp-anglican-render--office-label office)
                      date-str
                      (+ (length psalm-passages) (length lesson-passages))))
      (read-only-mode 1))
    (pop-to-buffer bcp-1928-office-buffer-name)
    (message "Fetching 1928 Office texts [psalms: %s, lessons: %s]…"
             (symbol-name bcp-fetcher-backend)
             (symbol-name (or bcp-fetcher-fallback-backend bcp-fetcher-backend)))
    ;; Fetch psalms first, then lessons, then render
    (bcp-1928--fetch-all
     psalm-passages
     (lambda (psalm-texts)
       (bcp-1928--fetch-all
        lesson-passages
        (lambda (lesson-texts)
          (bcp-1928--render-office
           propers psalms psalm-texts date-str lesson-texts)
          (with-current-buffer (get-buffer bcp-1928-office-buffer-name)
            (bcp-office-nav-init time 'bcp-1928 #'bcp-1928-open-office))
          (message "%s — %s"
                   (bcp-anglican-render--office-label office)
                   date-str)))))))

(defun bcp-1928--prompt-office-time ()
  "Interactively prompt for a date and office, returning a decoded-time list."
  (let* ((year   (read-number "Year: "  (nth 5 (decode-time))))
         (month  (read-number "Month: " (nth 4 (decode-time))))
         (day    (read-number "Day: "   (nth 3 (decode-time))))
         (office (completing-read "Office: "
                                  '("Morning Prayer" "Evening Prayer")
                                  nil t))
         (hour   (if (string= office "Morning Prayer") 9 18)))
    (list 0 0 hour day month year nil nil nil)))

;;;###autoload
(defun bcp-1928-set-office-date (year month day hour)
  "Set `bcp-1928-office-date' for a specific date and hour.
HOUR < 12 = Morning Prayer; HOUR >= 12 = Evening Prayer.
Call with \\[universal-argument] to reset to automatic (current date/time)."
  (interactive
   (if current-prefix-arg
       (list nil nil nil nil)
     (list (read-number "Year: "  (nth 5 (decode-time)))
           (read-number "Month: " (nth 4 (decode-time)))
           (read-number "Day: "   (nth 3 (decode-time)))
           (read-number "Hour (0-23): " (nth 2 (decode-time))))))
  (if (null year)
      (progn
        (setq bcp-1928-office-date nil)
        (message "1928 Office date reset — using current date and time."))
    (setq bcp-1928-office-date
          (list 0 0 hour day month year nil nil nil))
    (message "%s Prayer, %d-%02d-%02d"
             (if (< hour 12) "Morning" "Evening")
             year month day)))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Dispatcher and navigation registration
;;;; ──────────────────────────────────────────────────────────────────────────

(bcp-liturgy-register-tradition 'anglican '1928 #'bcp-1928-open-office)

(require 'bcp-office-nav)
(bcp-liturgy-register-hour-grouping 'bcp-1928 bcp-1928-canonical-hour-grouping)

(provide 'bcp-anglican-1928)
;;; bcp-anglican-1928.el ends here
