;;; bcp-1662.el --- 1662 BCP Daily Office for Emacs -*- lexical-binding: t -*-

;; Keywords: bible, bcp, liturgy, daily-office
;; Package-Requires: ((emacs "28.1") (bible-commentary "0.2.0"))

;;; Commentary:

;; Main module for the 1662 Book of Common Prayer Daily Office.
;; Contains:
;;   - BCP psalm cycle (monthly, 30-day)
;;   - Lesson and collect dispatch layer
;;   - Interactive Office commands
;;
;; Primary entry point: M-x bcp-1662-open-office
;;
;; Load order:
;;   (require 'bcp-1662-calendar)
;;   (require 'bcp-1662-data)
;;   (require 'bcp-1662-user-feasts)
;;   (require 'bcp-1662)

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-fetcher)
(require 'bcp-reader)
(require 'bcp-1662-calendar)
(require 'bcp-1662-data)
(require 'bcp-1662-ordo)
(require 'bcp-1662-render)
(require 'bcp-liturgy-canticles)


;;;; ──────────────────────────────────────────────────────────────────────
;;;; BCP Psalm Cycle
;;;; ──────────────────────────────────────────────────────────────────────

;;;; ──────────────────────────────────────────────────────────────────────
;;;; BCP psalm cycle data

(defconst bible-commentary-bcp-psalm-cycle
  '((1  :morning (1 2 3 4 5)               :evening (6 7 8))
    (2  :morning (9 10 11)                  :evening (12 13 14))
    (3  :morning (15 16 17)                 :evening (18))
    (4  :morning (19 20 21)                 :evening (22 23))
    (5  :morning (24 25 26)                 :evening (27 28 29))
    (6  :morning (30 31)                    :evening (32 33 34))
    (7  :morning (35 36)                    :evening (37))
    (8  :morning (38 39 40)                 :evening (41 42 43))
    (9  :morning (44 45 46)                 :evening (47 48 49))
    (10 :morning (50 51 52)                 :evening (53 54 55))
    (11 :morning (56 57 58)                 :evening (59 60 61))
    (12 :morning (62 63 64)                 :evening (65 66 67))
    (13 :morning (68)                       :evening (69 70))
    (14 :morning (71 72)                    :evening (73 74))
    (15 :morning (75 76 77)                 :evening (78))
    (16 :morning (79 80 81)                 :evening (82 83 84 85))
    (17 :morning (86 87 88)                 :evening (89))
    (18 :morning (90 91 92)                 :evening (93 94))
    (19 :morning (95 96 97)                 :evening (98 99 100 101))
    (20 :morning (102 103)                  :evening (104))
    (21 :morning (105)                      :evening (106))
    (22 :morning (107)                      :evening (108 109))
    (23 :morning (110 111 112 113)          :evening (114 115))
    (24 :morning (116 117 118)              :evening ((119 . (1 32))))
    (25 :morning ((119 . (33 72)))          :evening ((119 . (73 104))))
    (26 :morning ((119 . (105 144)))        :evening ((119 . (145 176))))
    (27 :morning (120 121 122 123 124 125)  :evening (126 127 128 129 130 131))
    (28 :morning (132 133 134 135)          :evening (136 137 138))
    (29 :morning (139 140)                  :evening (141 142 143))
    (30 :morning (144 145 146)              :evening (147 148 149 150))
    (31 :morning (144 145 146)              :evening (147 148 149 150)))
  "BCP 2019 traditional one-month psalm cycle (p. 743).
Each entry is (DAY :morning PSALMS :evening PSALMS).
Plain integers are whole psalms.
Psalm 119 sections are represented as (119 . (START END))
where START and END are verse numbers.
Day 31 repeats day 30 per BCP convention.")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Helper functions

(defun bible-commentary-bcp-psalms-for-day (day office)
  "Return the psalm list for DAY (1-31) and OFFICE (\\='morning or \\='evening).

Each element of the returned list is either:
  N              — an integer, meaning the whole of Psalm N
  (119 . (S E))  — Psalm 119 verses S through E

Returns nil if DAY is out of range or OFFICE is invalid."
  (when-let* ((entry  (assq day bible-commentary-bcp-psalm-cycle))
              (psalms (plist-get (cdr entry) office)))
    psalms))

(defun bible-commentary-bcp-psalm-ref-to-string (p)
  "Format a psalm reference P as a passage string for Oremus.
P is either an integer (whole psalm) or (119 . (START END))."
  (if (consp p)
      (format "Psalms 119:%d-%d" (car (cdr p)) (cadr (cdr p)))
    (format "Psalms %d" p)))

(defun bible-commentary-bcp-psalm-ref-to-label (p)
  "Format a psalm reference P as a short human-readable label.
P is either an integer or (119 . (START END))."
  (if (consp p)
      (format "119:%d-%d" (car (cdr p)) (cadr (cdr p)))
    (number-to-string p)))

(defun bible-commentary-bcp-psalms-today ()
  "Return psalms for the current office based on `bible-commentary-office-date'.
If `bible-commentary-office-date' is nil, uses the current date and time.

Returns a plist (:day DAY :office OFFICE :psalms LIST)."
  (let* ((time   (or bible-commentary-office-date (decode-time)))
         (day    (nth 3 time))
         (hour   (nth 2 time))
         (office (if (< hour 12) 'morning 'evening))
         (psalms (bible-commentary-bcp-psalms-for-day day office)))
    (list :day day :office office :psalms psalms)))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Interactive commands

(defun bible-commentary-bcp-open-todays-psalms ()
  "Open today's BCP Daily Office psalms in the Bible buffer.

Uses `bible-commentary-office-date' if set, otherwise the current
date and time.  Morning Prayer is selected for hours 0-11, Evening
Prayer for hours 12-23.

All psalms are fetched in a single Oremus request using the BCP
Coverdale Psalter."
  (interactive)
  (unless bible-commentary--bible-buffer
    (user-error "Run `bible-commentary-open' first."))
  (let* ((result  (bible-commentary-bcp-psalms-today))
         (day     (plist-get result :day))
         (office  (plist-get result :office))
         (psalms  (plist-get result :psalms))
         (passage (mapconcat #'bible-commentary-bcp-psalm-ref-to-string
                             psalms "\n"))
         (label   (mapconcat #'bible-commentary-bcp-psalm-ref-to-label
                             psalms ", ")))
    (message "%s Prayer, day %d — Psalms %s"
             (capitalize (symbol-name office))
             day
             label)
    (bcp-fetcher-fetch-passage
     passage
     (lambda (text label) (bible-commentary--load-text text label))
     "Coverdale")))

(defun bible-commentary-bcp-set-office-date (year month day hour)
  "Set `bible-commentary-office-date' for a specific date and hour.
HOUR (0-23) determines the office: < 12 = Morning, >= 12 = Evening.
Call with no arguments or \\[universal-argument] to reset to automatic."
  (interactive
   (if current-prefix-arg
       (list nil nil nil nil)
     (list (read-number "Year: "  (nth 5 (decode-time)))
           (read-number "Month: " (nth 4 (decode-time)))
           (read-number "Day: "   (nth 3 (decode-time)))
           (read-number "Hour (0-23, <12=Morning >=12=Evening): "
                        (nth 2 (decode-time))))))
  (if (null year)
      (progn
        (setq bible-commentary-office-date nil)
        (message "Office date reset — using current date and time."))
    (setq bible-commentary-office-date
          (list 0 0 hour day month year nil nil nil))
    (message "%s Prayer, %d-%02d-%02d"
             (if (< hour 12) "Morning" "Evening")
             year month day)))


;;;; ──────────────────────────────────────────────────────────────────────
;;;; Dispatch Layer
;;;; ──────────────────────────────────────────────────────────────────────

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Seasonal collect table

(defconst bcp-1662-seasonal-collect-table
  '((advent      . advent-1)
    (christmas   . nil)
    (epiphany    . nil)
    (pre-lent    . nil)
    (lent        . ash-wednesday)
    (passiontide . ash-wednesday)  ; includes Holy Saturday (Easter Even)
    (eastertide  . nil)
    (trinity     . nil))
  "Alist mapping liturgical season symbols to their seasonal collect symbols.
The seasonal collect is appended after the collect of the day.
nil means no seasonal collect for that season.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Internal helpers

(defun bcp-1662--calendar-entry (month day year)
  "Return the calendar entry plist for (MONTH DAY YEAR), or nil."
  (cl-some (lambda (entry)
              (when (and (= (car entry) month)
                         (= (cadr entry) day))
                entry))
           bcp-1662-propers-year))

(defun bcp-1662--feast-symbol-for-date (month day)
  "Return the feast symbol for calendar date (MONTH DAY), or nil."
  (when-let* ((entry (bcp-1662--calendar-entry month day 0))
              (name  (plist-get (cddr entry) :feast)))
    (bcp-1662-feast-symbol name)))

(defun bcp-1662--best-feast-for-date (month day year)
  "Return the highest-ranking feast symbol observed on (MONTH DAY YEAR).

Considers both BCP calendar feasts and user patronal feasts (with
transfer logic).  Returns the single best feast symbol, or nil.

Precedence: principal > greater (patronal-elevated > standard) > lesser."
  (let* (;; BCP calendar feast on this fixed date
         (cal-sym   (bcp-1662--feast-symbol-for-date month day))
         (cal-rank  (when cal-sym
                      (bcp-1662-effective-feast-rank
                       cal-sym
                       (or (plist-get (bcp-1662-feast-data cal-sym) :rank)
                           'lesser))))
         ;; User custom feasts observed on this date (after transfers)
         (user-syms (when (fboundp 'bcp-1662-user-feasts-for-date)
                      (bcp-1662-user-feasts-for-date month day year)))
         ;; Best user feast is first in precedence-sorted list
         (user-sym  (car user-syms))
         (user-rank (when user-sym
                      (bcp-1662-effective-feast-rank user-sym 'lesser))))
    (cond
     ;; No feasts at all
     ((and (null cal-sym) (null user-sym)) nil)
     ;; Only one type present
     ((null user-sym) cal-sym)
     ((null cal-sym)  user-sym)
     ;; Both present — pick higher rank; user feast wins ties (patronal precedence)
     ((<= (bcp-1662--rank-value user-rank)
          (bcp-1662--rank-value cal-rank))
      user-sym)
     (t cal-sym))))

(defun bcp-1662--preceding-sunday (month day year)
  "Return the date of the most recent Sunday on or before (MONTH DAY YEAR)."
  (let* ((abs (calendar-absolute-from-gregorian (list month day year)))
         (dow (calendar-day-of-week (list month day year))))
    (calendar-gregorian-from-absolute (- abs dow))))

(defun bcp-1662--rank-value (rank)
  "Return numeric precedence for RANK (lower = higher precedence)."
  (pcase rank
    ('principal 0)
    ('greater   1)
    ('lesser    2)
    (_          3)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Seasonal collect

(defun bcp-1662-seasonal-collect (month day year)
  "Return the seasonal collect symbol for (MONTH DAY YEAR), or nil."
  (let* ((season (bcp-1662-liturgical-season month day year))
         (sym    (cdr (assq season bcp-1662-seasonal-collect-table))))
    sym))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Collect of the day

(defun bcp-1662-collect-of-day (month day year)
  "Return the collect symbol for (MONTH DAY YEAR).

If the day has a proper collect, returns that symbol.
Otherwise returns the collect symbol of the most recent Sunday,
implementing the BCP rule that the Sunday collect serves all week."
  ;; Check for a proper collect on this day
  (let* ((feast-sym (bcp-1662--best-feast-for-date month day year))
         ;; Also check moveable feasts / special days
         (feasts    (bcp-1662-moveable-feasts year))
         (abs       (calendar-absolute-from-gregorian (list month day year)))
         (easter    (calendar-absolute-from-gregorian
                     (cdr (assq 'easter feasts))))
         (moveable-sym
          (cond
           ((= abs (calendar-absolute-from-gregorian
                    (cdr (assq 'ash-wednesday feasts))))    'ash-wednesday)
           ((= abs (calendar-absolute-from-gregorian
                    (cdr (assq 'ascension feasts))))        'ascension)
           ((= abs (+ easter -7))                           'palm-sunday)
           ((= abs (+ easter -3))                           'thursday-holy-week)
           ((= abs (+ easter -2))                           'good-friday)
           ((= abs (+ easter -1))                           'easter-eve)
           ((= abs easter)                                  'easter)
           ((= abs (+ easter 1))                            'easter-monday)
           ((= abs (+ easter 2))                            'easter-tuesday)
           ((= abs (+ easter 49))                           'whitsunday)
           ((= abs (+ easter 50))                           'whit-monday)
           ((= abs (+ easter 51))                           'whit-tuesday)
           (t nil)))
         ;; Determine best collect symbol
         (day-sym (or moveable-sym feast-sym)))
    (if (and day-sym (bcp-1662-collect day-sym))
        day-sym
      ;; Fall back to preceding Sunday's collect
      (let* ((sun   (bcp-1662--preceding-sunday month day year))
             (sm    (car sun))
             (sd    (cadr sun))
             (sy    (caddr sun))
             (sun-feast (bcp-1662--feast-symbol-for-date sm sd))
             (sun-moveable
              (cond
               ((= (calendar-absolute-from-gregorian sun)
                   (calendar-absolute-from-gregorian
                    (cdr (assq 'passion-sunday feasts))))   'lent-5)
               ((= (calendar-absolute-from-gregorian sun)
                   (calendar-absolute-from-gregorian
                    (cdr (assq 'palm-sunday feasts))))      'palm-sunday)
               ((= (calendar-absolute-from-gregorian sun)
                   easter)                                   'easter)
               ((= (calendar-absolute-from-gregorian sun)
                   (+ easter 7))                             'easter-1)
               ((= (calendar-absolute-from-gregorian sun)
                   (+ easter 49))                            'whitsunday)
               ((= (calendar-absolute-from-gregorian sun)
                   (+ easter 56))                            'trinity-sunday)
               (t nil)))
             (sun-sym (or sun-moveable
                          ;; On a Sunday, prefer the liturgical week collect
                          ;; over a lesser feast that has no proper collect
                          (let* ((week   (bcp-1662-liturgical-week sm sd sy))
                                 (season (car week))
                                 (num    (cdr week))
                                 (week-sym
                                  (when num
                                    (cond
                                     ((and (eq season 'trinity) (= num 0))  'trinity-sunday)
                                     ((and (eq season 'trinity) (= num 25)) 'sunday-before-advent)
                                     (t (intern (format "%s-%d" season num)))))))
                            (if (and week-sym (bcp-1662-collect week-sym))
                                week-sym
                              ;; Fall back to feast symbol if week has no collect
                              ;; or if not a Sunday
                              (or (and sun-feast (bcp-1662-collect sun-feast) sun-feast)
                                  week-sym
                                  sun-feast))))))
        sun-sym))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Office lessons

(defun bcp-1662--sunday-proper-lessons (month day year office)
  "Return Sunday proper lessons for (MONTH DAY YEAR) at OFFICE, or nil.

Looks up the liturgical week symbol and retrieves lessons from
`bcp-1662-propers-sunday'.  Returns a plist (:lesson1 REF :lesson2 REF)
or nil if no Sunday proper is found."
  (let* ((week    (bcp-1662-liturgical-week month day year))
         (season  (car week))
         (num     (cdr week))
         (sym     (when (and season num)
                    (cond
                     ((and (eq season 'trinity) (= num 0))  'trinity-sunday)
                     ((and (eq season 'trinity) (= num 25)) 'sunday-before-advent)
                     ;; bcp-1662-propers-sunday uses after-trinity-N keys
                     ((eq season 'trinity) (intern (format "after-trinity-%d" num)))
                     ;; Epiphany overflow Sundays use after-epiphany-N keys
                     ((eq season 'epiphany) (intern (format "after-epiphany-%d" num)))
                     (t (intern (format "%s-%d" season num))))))
         (entry   (when sym (assq sym bcp-1662-propers-sunday)))
         (office-plist (when entry
                         (plist-get (cdr entry)
                                    (if (eq office 'mattins)
                                        :mattins
                                      :evensong)))))
    (when (and office-plist
               (or (plist-get office-plist :lesson1)
                   (plist-get office-plist :lesson2)))
      office-plist)))

(defun bcp-1662-office-lessons (month day year office)
  "Return the Office lessons for (MONTH DAY YEAR) at OFFICE.

OFFICE is \\='mattins or \\='evensong.

Returns a plist (:lesson1 REF :lesson2 REF :source SYMBOL) where
SOURCE indicates which table the lessons came from:
  feast-proper   — proper lessons for a fixed greater/principal feast
  sunday-proper  — proper lessons for a Sunday from bcp-1662-propers-sunday
  calendar       — ordinary course from bcp-1662-propers-year

Lesson precedence:
  1. Principal feast proper lessons
  2. Greater feast proper lessons (including patronal elevations)
  3. Sunday proper lessons (on Sundays)
  4. Ordinary calendar lessons"
  (let* ((feast-sym  (bcp-1662--best-feast-for-date month day year))
         (feast-data (when feast-sym (bcp-1662-feast-data feast-sym)))
         (rank       (when feast-data (plist-get feast-data :rank)))
         (eff-rank   (when feast-sym
                       (bcp-1662-effective-feast-rank feast-sym
                                                      (or rank 'lesser))))
         (cal-entry  (bcp-1662--calendar-entry month day year))
         (cal-office (when cal-entry
                       (plist-get (cddr cal-entry)
                                  (if (eq office 'mattins)
                                      :mattins
                                    :evensong))))
         (is-sunday  (= (calendar-day-of-week (list month day year)) 0)))
    (cond
     ;; Greater or principal feast — use calendar lessons
     ((and feast-sym
           (memq eff-rank '(principal greater))
           cal-office)
      (list :lesson1 (plist-get cal-office :lesson1)
            :lesson2 (plist-get cal-office :lesson2)
            :source  'feast-proper))
     ;; Sunday — check for Sunday proper lessons, falling back to calendar
     (is-sunday
      (let* ((sun-propers (bcp-1662--sunday-proper-lessons month day year office))
             (cal-l1 (when cal-office (plist-get cal-office :lesson1)))
             (cal-l2 (when cal-office (plist-get cal-office :lesson2)))
             (l1 (or (and sun-propers (plist-get sun-propers :lesson1)) cal-l1))
             (l2 (or (and sun-propers (plist-get sun-propers :lesson2)) cal-l2)))
        (when (or l1 l2)
          (list :lesson1 l1
                :lesson2 l2
                :source  (if sun-propers 'sunday-proper 'calendar)))))
     ;; Ordinary calendar lessons
     (cal-office
      (list :lesson1 (plist-get cal-office :lesson1)
            :lesson2 (plist-get cal-office :lesson2)
            :source  'calendar))
     (t nil))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Communion propers

(defun bcp-1662-communion-proper-for-date (month day year)
  "Return the communion proper symbol for (MONTH DAY YEAR), or nil.

Checks fixed feasts first, then moveable feasts and Sunday propers."
  (let* ((feast-sym (bcp-1662--best-feast-for-date month day year))
         (feasts    (bcp-1662-moveable-feasts year))
         (abs       (calendar-absolute-from-gregorian (list month day year)))
         (easter    (calendar-absolute-from-gregorian
                     (cdr (assq 'easter feasts))))
         (advent    (calendar-absolute-from-gregorian
                     (bcp-1662-advent-sunday year))))
    (or
     ;; Fixed feast communion proper
     (when (and feast-sym (bcp-1662-communion-propers feast-sym))
       feast-sym)
     ;; Moveable feasts and special days
     (cond
      ((= abs (calendar-absolute-from-gregorian
               (cdr (assq 'ash-wednesday feasts))))  'ash-wednesday)
      ((= abs (+ easter -7))                          'palm-sunday)
      ((= abs (+ easter -6))                          'monday-holy-week)
      ((= abs (+ easter -5))                          'tuesday-holy-week)
      ((= abs (+ easter -4))                          'wednesday-holy-week)
      ((= abs (+ easter -3))                          'thursday-holy-week)
      ((= abs (+ easter -2))                          'good-friday)
      ((= abs (+ easter -1))                          'easter-eve)
      ((= abs easter)                                 'easter)
      ((= abs (+ easter 1))                           'easter-monday)
      ((= abs (+ easter 2))                           'easter-tuesday)
      ((= abs (+ easter 39))                          'ascension)
      ((= abs (+ easter 49))                          'whitsunday)
      ((= abs (+ easter 50))                          'whit-monday)
      ((= abs (+ easter 51))                          'whit-tuesday)
      ((= abs (+ easter 56))                          'trinity-sunday)
      (t
       ;; Sunday proper
       (when (= (calendar-day-of-week (list month day year)) 0)
         (let* ((week   (bcp-1662-liturgical-week month day year))
                (season (car week))
                (num    (cdr week)))
           (when num
             (let ((sym (cond
                          ((and (eq season 'trinity) (= num 0))  'trinity-sunday)
                          ((and (eq season 'trinity) (= num 25)) 'sunday-before-advent)
                          (t (intern (format "%s-%d" season num))))))
               (when (bcp-1662-communion-propers sym) sym))))))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Top-level dispatch

(defun bcp-1662-propers-for-date (month day year office)
  "Return all liturgical propers for (MONTH DAY YEAR) at OFFICE.

OFFICE is \\='mattins or \\='evensong.

Returns a plist:
  :date              (MONTH DAY YEAR)
  :office            OFFICE
  :season            liturgical season symbol
  :week              liturgical week cons (SEASON . NUM)
  :feast             feast symbol or nil
  :feast-name        feast display name or nil
  :feast-rank        feast rank or nil
  :lessons           (:lesson1 REF :lesson2 REF :source SYMBOL)
  :collect           collect symbol (day proper or preceding Sunday)
  :seasonal-collect  seasonal collect symbol or nil
  :communion         communion proper symbol or nil
  :ot-reading        OT/first lesson for Communion or nil"
  (let* ((season       (bcp-1662-liturgical-season month day year))
         (week         (bcp-1662-liturgical-week month day year))
         (feast-sym    (bcp-1662--best-feast-for-date month day year))
         ;; Feast display name: check user feast data first, then BCP feast data
         (feast-data   (when feast-sym (bcp-1662-feast-data feast-sym)))
         (user-data    (when (and feast-sym (fboundp 'bcp-1662-user-feast-name))
                         (bcp-1662-user-feast-name feast-sym)))
         (feast-name   (or user-data
                           (when feast-data (plist-get feast-data :name))))
         (feast-rank   (when feast-sym
                         (bcp-1662-effective-feast-rank
                          feast-sym
                          (or (and feast-data (plist-get feast-data :rank))
                              'lesser))))
         (lessons      (bcp-1662-office-lessons month day year office))
         (collect-sym  (bcp-1662-collect-of-day month day year))
         (seas-collect (bcp-1662-seasonal-collect month day year))
         (communion    (bcp-1662-communion-proper-for-date month day year))
         (ot           (bcp-1662-ot-reading communion)))
    (list :date             (list month day year)
          :office           office
          :season           season
          :week             week
          :feast            feast-sym
          :feast-name       feast-name
          :feast-rank       feast-rank
          :lessons          lessons
          :collect          collect-sym
          :seasonal-collect seas-collect
          :communion        communion
          :ot-reading       ot)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Convenience accessors

(defun bcp-1662-lesson1 (propers)
  "Return lesson 1 REF from a PROPERS plist."
  (plist-get (plist-get propers :lessons) :lesson1))

(defun bcp-1662-lesson2 (propers)
  "Return lesson 2 REF from a PROPERS plist."
  (plist-get (plist-get propers :lessons) :lesson2))

(defun bcp-1662-collect-text-for-date (month day year)
  "Return the collect text for (MONTH DAY YEAR), or nil."
  (bcp-1662-collect-text
   (bcp-1662-collect-of-day month day year)))

(defun bcp-1662-seasonal-collect-text (month day year)
  "Return the seasonal collect text for (MONTH DAY YEAR), or nil."
  (when-let* ((sym (bcp-1662-seasonal-collect month day year)))
    (bcp-1662-collect-text sym)))


;;;; ──────────────────────────────────────────────────────────────────────
;;;; Interactive Commands
;;;; ──────────────────────────────────────────────────────────────────────

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Customisation

(defcustom bcp-1662-office-buffer-name "*BCP 1662 Daily Office*"
  "Name of the buffer used for the Daily Office."
  :type  'string
  :group 'bcp-1662)

(defcustom bcp-1662-show-communion-propers t
  "Whether to include Communion propers (Epistle, Gospel, OT) in the Office buffer."
  :type  'boolean
  :group 'bcp-1662)

(defcustom bcp-1662-office-date nil
  "Override date/time for the Office.
A decoded-time list (SEC MIN HOUR DAY MONTH YEAR ...).
If nil, uses the current date and time."
  :type  '(choice (const nil) (repeat integer))
  :group 'bcp-1662)

(defcustom bcp-1662-morning-prayer-hour-limit 12
  "Hour (0-23) before which Morning Prayer is used; at or after = Evening Prayer.
The 1662 BCP has two offices only.  Other traditions should define their
own cutoff variables in their respective modules."
  :type  'integer
  :group 'bcp-1662)

(defcustom bcp-1662-rubric-style 'red
  "Display style for rubrics in the Daily Office buffer.
  `red'     — traditional liturgical red (default)
  `comment' — inherits `font-lock-comment-face' (muted, theme-aware)"
  :type  '(choice (const red) (const comment))
  :group 'bcp-1662)

;;── Rubrical options ────────────────────────────────────────────────────────

(defcustom office-officiant 'lay
  "The order of the officiant saying the Office.
Affects which form of the absolution is used and may affect other
order-specific rubrics in future ordos.
Values: `lay', `deacon', `priest', `bishop'."
  :type  '(choice (const lay)
                  (const deacon)
                  (const priest)
                  (const bishop))
  :group 'bcp-1662)

(defcustom bcp-1662-general-confession-form 'nil
  "Which form of the General Confession to use.
  nil       — standard 1662 text (default):
              \\\"...And there is no health in us.\\\"
  `omit'    — omit the General Confession entirely
  `variant' — variant form:
              \\\". And apart from thy grace, there is no health in us.\\\""
  :type  '(choice (const nil) (const omit) (const variant))
  :group 'bcp-1662)


(defcustom bcp-1662-omit-penitential-intro nil
  "Whether to omit the penitential introduction on weekdays.
When non-nil, everything from the opening sentences through the absolution
is omitted.  Permitted by rubric on weekdays; not recommended on Sundays
or principal feasts."
  :type  'boolean
  :group 'bcp-1662)

(defcustom bcp-1662-opening-sentence-selection 'auto
  "How many opening sentences to display at Morning and Evening Prayer.
`auto' — the engine selects one sentence appropriate to the day.
`all'  — all sentences in the active corpus are displayed."
  :type  '(choice (const :tag "One (auto-selected)" auto)
                  (const :tag "All" all))
  :group 'bcp-1662)

(defcustom bcp-1662-opening-sentence-corpus '1662
  "Which corpus of opening sentences to draw from.
`1662'     — only the eleven penitential sentences from the BCP 1662.
`extended' — prefer a seasonal sentence for the current season (from
             `bcp-1662-seasonal-sentences'); fall back to the 1662
             sentences when no seasonal sentence is defined."
  :type  '(choice (const :tag "BCP 1662 only" 1662)
                  (const :tag "Extended (other BCP editions)" extended))
  :group 'bcp-1662)

(defcustom bcp-1662-bidding-form 'full
  "Which form of the Bidding (exhortation) to use.
  `full'   — the full text \"Dearly beloved brethren...\" (default)
  `brief'  — an abbreviated form (text in `bcp-1662-bidding-brief')
  `omit'   — omit the bidding entirely"
  :type  '(choice (const full) (const brief) (const omit))
  :group 'bcp-1662)

(defcustom bcp-1662-omit-venite-passiontide nil
  "Whether to omit Venite verses 8-11 outside Lent and Passiontide.
When non-nil, verses 8-11 (\\\"To day if ye will hear his voice...\\\")
are omitted except during Lent.  Per rubric, they may be omitted
on any day outside Lent."
  :type  'boolean
  :group 'bcp-1662)

(defcustom bcp-1662-easter-anthems-throughout-eastertide nil
  "Whether to use Easter Anthems in place of Venite throughout Eastertide.
When nil (default), Easter Anthems replace Venite on Easter Day only.
When non-nil, they replace Venite throughout the whole Eastertide season."
  :type  'boolean
  :group 'bcp-1662)

(defcustom bcp-1662-additional-prayers nil
  "List of additional prayers to append after the five state prayers.
Each element is either a string (prayer text) or a symbol that resolves
to a plist with :title and :text keys (same format as the state prayers).
These are appended after the Prayer of St Chrysostom and before the Grace."
  :type  '(repeat (choice string symbol))
  :group 'bcp-1662)

;;── Seasonal sentences (extended corpus) ────────────────────────────────────

(defcustom bcp-1662-seasonal-sentences
  '((advent      . nil)
    (christmas   . nil)
    (epiphany    . nil)
    (pre-lent    . nil)
    (lent        . nil)
    (passiontide . nil)
    (eastertide  . nil)
    (trinity     . nil))
  "Alist of (SEASON . SENTENCE-TEXT) for seasonal opening sentences.
Used when `bcp-1662-opening-sentence-corpus' is `extended'.
Nil entries mean no seasonal sentence is available for that season.
Texts should be supplied as plain strings."
  :type  '(alist :key-type symbol :value-type (choice string (const nil)))
  :group 'bcp-1662)

(defconst bcp-1662-bidding-brief
  nil
  "Abbreviated form of the Bidding (exhortation).
Nil until supplied.  Should be a plain string.")

(defconst bcp-1662--fallback-sentence
  '("If we say that we have no sin, we deceive ourselves, and the truth is not in us; but if we confess our sins, God is faithful and just to forgive us our sins, and to cleanse us from all unrighteousness."
    ("1 John" 1 8 9))
  "Fallback opening sentence used when normal sentence selection yields nothing.
This is the last of the 1662 sentences (1 John 1:8-9), chosen for its
direct relevance to the penitential introduction that follows.")

(defun bcp-1662--select-opening-sentences (season date)
  "Return the list of opening sentences to display for SEASON on DATE.
DATE is a Gregorian calendar date (MONTH DAY YEAR).

Each element is either a (TEXT CITATION) pair from
`bcp-1662-opening-sentences' (general pool), or a plain string
(seasonal sentence from `bcp-1662-seasonal-sentences').

Respects `bcp-1662-opening-sentence-corpus' and
`bcp-1662-opening-sentence-selection'.  Falls back to
`bcp-1662--fallback-sentence' if the result would otherwise be empty."
  (let* ((seasonal (when (eq bcp-1662-opening-sentence-corpus 'extended)
                     (cdr (assq season bcp-1662-seasonal-sentences))))
         (pool     bcp-1662-opening-sentences)
         (result
          (cond
           ;; Extended corpus with a seasonal sentence available
           (seasonal
            (list seasonal))
           ;; General pool (1662 only, or extended with no seasonal sentence defined)
           ((eq bcp-1662-opening-sentence-selection 'all)
            pool)
           (t
            (when pool
              (list (nth (mod (calendar-absolute-from-gregorian date)
                              (length pool))
                         pool)))))))
    (or result (list bcp-1662--fallback-sentence))))

;;;; Ref conversion

(defconst bcp-1662--book-expansions
  '(;; Old Testament
    ("Gen"      . "Genesis")
    ("Exod"     . "Exodus")
    ("Lev"      . "Leviticus")
    ("Num"      . "Numbers")
    ("Deut"     . "Deuteronomy")
    ("Josh"     . "Joshua")
    ("Judg"     . "Judges")
    ("Ruth"     . "Ruth")
    ("1 Sam"    . "1 Samuel")
    ("2 Sam"    . "2 Samuel")
    ("1 Kgs"    . "1 Kings")
    ("2 Kgs"    . "2 Kings")
    ("1 Chr"    . "1 Chronicles")
    ("2 Chr"    . "2 Chronicles")
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
    ("1 Cor"    . "1 Corinthians")
    ("2 Cor"    . "2 Corinthians")
    ("Gal"      . "Galatians")
    ("Eph"      . "Ephesians")
    ("Phil"     . "Philippians")
    ("Col"      . "Colossians")
    ("1 Thess"  . "1 Thessalonians")
    ("2 Thess"  . "2 Thessalonians")
    ("1 Tim"    . "1 Timothy")
    ("2 Tim"    . "2 Timothy")
    ("Titus"    . "Titus")
    ("Phlm"     . "Philemon")
    ("Heb"      . "Hebrews")
    ("Jas"      . "James")
    ("1 Pet"    . "1 Peter")
    ("2 Pet"    . "2 Peter")
    ("1 John"   . "1 John")
    ("2 John"   . "2 John")
    ("3 John"   . "3 John")
    ("Jude"     . "Jude")
    ("Rev"      . "Revelation")
    ;; Apocrypha
    ("Tob"      . "Tobit")
    ("Jdt"      . "Judith")
    ("1 Macc"   . "1 Maccabees")
    ("2 Macc"   . "2 Maccabees")
    ("Wis"      . "Wisdom of Solomon")
    ("Ecclus"   . "Sirach")
    ("Sir"      . "Sirach")
    ("Bar"      . "Baruch"))
  "Mapping from lectionary book abbreviations to full Oremus book names.")

(defun bcp-1662--expand-book (abbrev)
  "Expand a lectionary book ABBREV to its full Oremus name."
  (or (cdr (assoc abbrev bcp-1662--book-expansions))
      abbrev))

(defun bcp-1662--lectionary-ref-to-string (ref)
  "Convert a lectionary REF to a passage string for Oremus.

Handles all ref formats from bcp-1662-propers-year.el:
  (\"Book\" CH)           → \"Full Book Name CH\"
  (\"Book\" CH V nil)     → \"Full Book Name CH:V\"
  (\"Book\" CH V1 V2)     → \"Full Book Name CH:V1-V2\"
  (REF1 REF2)             → joined lesson spanning two refs"
  (cond
   ;; Joined lesson: list of two refs (REF1 REF2)
   ((and (listp ref) (listp (car ref)))
    (let* ((r1   (car ref))
           (r2   (cadr ref))
           (book (bcp-1662--expand-book (car r1)))
           (ch1  (cadr r1))
           (v1   (caddr r1))
           (ch2  (cadr r2))
           (v2   (caddr r2))
           (v2e  (cadddr r2)))
      (cond
       ;; Book CH1:V1 - CH2 (to end of chapter 2) — use sentinel verse 200
       ;; so Oremus returns from V1 to the last verse of CH2
       ((and v1 ch2 (null v2) (null v2e))
        (format "%s %d:%d-%d:200" book ch1 v1 ch2))
       ;; Book CH1:V1 - CH2:V2e
       ((and v1 ch2 v2e)
        (format "%s %d:%d-%d:%d" book ch1 v1 ch2 v2e))
       ;; Book CH1:V1 to end of CH1, then start of CH2 (v2 present)
       ((and v1 ch2 v2)
        (format "%s %d:%d-%d:%d" book ch1 v1 ch2 v2))
       ;; Book CH1 - CH2 (whole chapters)
       (t
        (format "%s %d-%d" book ch1 ch2)))))
   ;; Single ref
   ((and (listp ref) (stringp (car ref)))
    (let ((book (bcp-1662--expand-book (car ref)))
          (ch   (cadr ref))
          (v1   (caddr ref))
          (v2   (cadddr ref)))
      (cond
       ((null v1)  (format "%s %d" book ch))
       ((null v2)  (format "%s %d:%d" book ch v1))
       ((eq v2 'nil) (format "%s %d:%d" book ch v1))
       (t          (format "%s %d:%d-%d" book ch v1 v2)))))
   (t (format "%s" ref))))

(defun bcp-1662--ref-label (ref)
  "Return a short human-readable label for REF using abbreviated book names."
  (cond
   ((and (listp ref) (listp (car ref)))
    ;; Joined lesson — use abbreviated form
    (let* ((r1  (car ref))
           (r2  (cadr ref))
           (bk  (car r1))
           (ch1 (cadr r1))
           (v1  (caddr r1))
           (ch2 (cadr r2))
           (v2e (cadddr r2)))
      (cond
       ((and v1 v2e) (format "%s %d:%d-%d:%d" bk ch1 v1 ch2 v2e))
       ((and v1 ch2) (format "%s %d:%d-%d" bk ch1 v1 ch2))
       (t            (format "%s %d-%d" bk ch1 ch2)))))
   ((and (listp ref) (stringp (car ref)))
    (let ((bk (car ref))
          (ch (cadr ref))
          (v1 (caddr ref))
          (v2 (cadddr ref)))
      (cond
       ((null v1)    (format "%s %d" bk ch))
       ((null v2)    (format "%s %d:%d" bk ch v1))
       ((eq v2 'nil) (format "%s %d:%d" bk ch v1))
       (t            (format "%s %d:%d-%d" bk ch v1 v2)))))
   (t (format "%s" ref))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalm formatting

(defun bcp-1662--psalm-label (psalm-ref)
  "Format a BCP psalm reference as a short label.
PSALM-REF is either an integer or (119 . (START END))."
  (if (consp psalm-ref)
      (format "Ps 119:%d-%d" (car (cdr psalm-ref)) (cadr (cdr psalm-ref)))
    (format "Ps %d" psalm-ref)))

(defun bcp-1662--psalm-to-passage (psalm-ref)
  "Convert a BCP psalm reference to an Oremus passage string.
Delegates to `bible-commentary-bcp-psalm-ref-to-string'."
  (bible-commentary-bcp-psalm-ref-to-string psalm-ref))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Office date helpers

(defun bcp-1662--current-time ()
  "Return the effective time for the Office.
Uses `bcp-1662-office-date' if set, otherwise current time."
  (or bcp-1662-office-date (decode-time)))

(defun bcp-1662--office-from-time (time)
  "Return \\='mattins or \\='evensong based on HOUR in TIME.
Uses `bcp-1662-morning-prayer-hour-limit' as the cutoff."
  (if (< (nth 2 time) bcp-1662-morning-prayer-hour-limit)
      'mattins
    'evensong))

(defun bcp-1662--date-from-time (time)
  "Return (MONTH DAY YEAR) from a decoded-time list."
  (list (nth 4 time) (nth 3 time) (nth 5 time)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Oremus fetch helpers

(defun bcp-1662--fetch-text (passage callback &optional translation)
  "Fetch PASSAGE from Oremus and call CALLBACK with formatted text.
Delegates to `bcp-fetcher-fetch'."
  (bcp-fetcher-fetch passage callback translation))

(defun bcp-1662--fetch-all (passages callback)
  "Fetch all PASSAGES from Oremus, then call CALLBACK with an alist of results.

PASSAGES is a list of (KEY PASSAGE-STRING . TRANSLATION) triples,
where TRANSLATION is optional (nil uses `bible-commentary-translation').
CALLBACK receives an alist of (KEY . TEXT-OR-NIL).

Fetches are issued in parallel; CALLBACK is called once all complete."
  (if (null passages)
      (funcall callback nil)
    (let* ((total   (length passages))
           (results (make-vector total nil))
           (done    (cons 0 nil)))
      (cl-loop for entry in passages
               for idx from 0
               do (let* ((i   idx)
                         (k   (car entry))
                         (psg (cadr entry))
                         (tr  (caddr entry)))
                    (bcp-1662--fetch-text
                     psg
                     (lambda (text)
                       (aset results i (cons k text))
                       (setcar done (1+ (car done)))
                       (when (= (car done) total)
                         (funcall callback (append results nil))))
                     tr))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Interactive commands

;;;###autoload
(defun bcp-1662-open-office (&optional arg)
  "Open the 1662 BCP Daily Office for today.

Determines Morning or Evening Prayer from the current hour
(before noon = Morning Prayer; noon or after = Evening Prayer).
Fetches all psalm and lesson texts from Oremus before rendering.

With a prefix argument ARG, prompts for date and office."
  (interactive "P")
  (let* ((time      (if arg
                        (bcp-1662--prompt-office-time)
                      (bcp-1662--current-time)))
         (office    (bcp-1662--office-from-time time))
         (date      (bcp-1662--date-from-time time))
         (month     (car date))
         (day       (cadr date))
         (year      (caddr date))
         (propers   (bcp-1662-propers-for-date month day year office))
         (lessons   (plist-get propers :lessons))
         (l1        (plist-get lessons :lesson1))
         (l2        (plist-get lessons :lesson2))
         (comm-sym  (plist-get propers :communion))
         (ot-ref    (plist-get propers :ot-reading))
         (comm-data (when comm-sym (bcp-1662-communion-propers comm-sym)))
         (ep-ref    (when comm-data (plist-get comm-data :epistle)))
         (go-ref    (when comm-data (plist-get comm-data :gospel)))
         (dow-sym   (if (eq office 'mattins) :morning :evening))
         (psalms    (bible-commentary-bcp-psalms-for-day day dow-sym))
         (date-str  (format-time-string
                     "%A, %d %B %Y"
                     (encode-time (append '(0 0 12)
                                          (list day month year)
                                          '(nil nil nil)))))
         ;; Build passage lists for batch fetch
         (psalm-tr      bible-commentary-psalm-translation)
         (lesson-tr     bible-commentary-translation)
         (psalm-passages
          (mapcar (lambda (p)
                    (list (bcp-1662--psalm-label p)
                          (bcp-1662--psalm-to-passage p)
                          psalm-tr))
                  psalms))
         (lesson-passages
          (delq nil
                (list
                 (when l1   (list "lesson1" (bcp-1662--lectionary-ref-to-string l1) lesson-tr))
                 (when l2   (list "lesson2" (bcp-1662--lectionary-ref-to-string l2) lesson-tr))
                 (when (and bcp-1662-show-communion-propers ot-ref)
                   (list "ot"      (bcp-1662--lectionary-ref-to-string ot-ref) lesson-tr))
                 (when (and bcp-1662-show-communion-propers ep-ref)
                   (list "epistle" (bcp-1662--lectionary-ref-to-string ep-ref) lesson-tr))
                 (when (and bcp-1662-show-communion-propers go-ref)
                   (list "gospel"  (bcp-1662--lectionary-ref-to-string go-ref) lesson-tr))))))
    ;; Show buffer immediately with a loading message
    (with-current-buffer (get-buffer-create bcp-1662-office-buffer-name)
      (read-only-mode -1)
      (erase-buffer)
      (insert (format "Loading %s — %s…\n\nFetching %d passage(s) from Oremus.\n"
                      (bcp-1662--office-label office)
                      date-str
                      (+ (length psalm-passages) (length lesson-passages))))
      (read-only-mode 1))
    (pop-to-buffer bcp-1662-office-buffer-name)
    (message "Fetching Office texts from Oremus…")
    ;; Fetch psalms first, then lessons, then render
    (bcp-1662--fetch-all
     psalm-passages
     (lambda (psalm-texts)
       (bcp-1662--fetch-all
        lesson-passages
        (lambda (lesson-texts)
          (bcp-1662--render-office
           propers psalms psalm-texts date-str lesson-texts)
          (message "%s — %s"
                   (bcp-1662--office-label office)
                   date-str)))))))

(defun bcp-1662--prompt-office-time ()
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
(defun bcp-1662-set-office-date (year month day hour)
  "Set `bcp-1662-office-date' for a specific date and hour.
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
        (setq bcp-1662-office-date nil)
        (message "Office date reset — using current date and time."))
    (setq bcp-1662-office-date
          (list 0 0 hour day month year nil nil nil))
    (message "%s Prayer, %d-%02d-%02d"
             (if (< hour 12) "Morning" "Evening")
             year month day)))


(provide 'bcp-1662)
;;; bcp-1662.el ends here
