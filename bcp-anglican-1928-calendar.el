;;; bcp-anglican-1928-calendar.el --- Calendar for 1928 American BCP -*- lexical-binding: t -*-

;;; Commentary:

;; Calendar module for the 1928 American Book of Common Prayer.
;;
;; Primary public functions:
;;   `bcp-1928-liturgical-day'   — (month day year) → (WEEK-KEY . DOW-SYMBOL)
;;   `bcp-1928-feast-rank'       — precedence tier for a feast symbol
;;   `bcp-1928-feasts-for-date'  — fixed feasts falling on a calendar date
;;   `bcp-1928-transfer-p'       — t when a feast must be transferred
;;
;; Precedence (Tables of Precedence, 1928 BCP):
;;
;;   Tier 1 — Immoveable (any clashing feast is transferred):
;;     Sundays in Advent; Christmas Day; Epiphany; Septuagesima, Sexagesima,
;;     Quinquagesima; Ash Wednesday; Sundays in Lent; all days of Holy Week;
;;     Easter Day + 7 days; Rogation Sunday; Ascension Day + Sunday after;
;;     Whitsunday + 6 days; Trinity Sunday.
;;
;;   Tier 2 — Transferable (displace ordinary days; yield to Tier 1):
;;     St. Stephen, St. John Ev., Holy Innocents, Circumcision, Conversion
;;     of St. Paul, Purification, St. John Baptist, all Apostles/Evangelists,
;;     Transfiguration, St. Michael and All Angels, All Saints.
;;
;;   Tier 3 — Lesser / commons (observed when convenient):
;;     All other saints' days and occasions.
;;
;; Day-of-week keys:
;;   0 = sunday, 1 = monday, … 6 = saturday
;;
;; Week keys follow the naming convention of bcp-1662-propers-sunday and
;; bcp-1928-lesson-table:
;;   advent-N, after-christmas-N, after-epiphany-N,
;;   septuagesima, sexagesima, quinquagesima,
;;   ash-wednesday, lent-N, palm-sunday,
;;   easter, after-easter-N, sunday-after-ascension,
;;   whitsunday, trinity, after-trinity-N,
;;   sunday-before-advent.
;;
;; Fixed-date Christmas/Epiphany octave keys:
;;   christmas, st-stephen, st-john-evangelist, holy-innocents,
;;   december-29, december-30, december-31,
;;   circumcision, january-2, january-3, january-4, january-5, epiphany.
;;
;; These date-specific keys are returned for weekdays in the octave.
;; On a Sunday in the octave the floating Sunday key is returned instead.

;;; Code:

(require 'calendar)
(require 'bcp-calendar)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Day-of-week utilities
;;;; ══════════════════════════════════════════════════════════════════════════

(defconst bcp-1928--dow-symbols
  [sunday monday tuesday wednesday thursday friday saturday]
  "Day-of-week index → symbol (0 = Sunday).")

(defun bcp-1928--dow (date)
  "Return the day-of-week symbol for DATE (MONTH DAY YEAR list)."
  (aref bcp-1928--dow-symbols (calendar-day-of-week date)))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Church-year anchors
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928--anchors (year)
  "Return an alist of absolute-day anchors for the church year containing YEAR.

YEAR is the calendar year in which Easter falls.  All moveable
dates are derived from Easter.  Fixed dates (Christmas, Epiphany)
use YEAR-1 and YEAR respectively to span the Advent–Trinity arc."
  (let* ((easter     (bcp-easter year))
         (easter-abs (calendar-absolute-from-gregorian easter))
         (advent-abs (calendar-absolute-from-gregorian
                      (bcp-advent-1 (1- year))))
         (christmas-abs (calendar-absolute-from-gregorian
                         (list 12 25 (1- year))))
         (epiphany-abs  (calendar-absolute-from-gregorian (list 1 6 year)))
         (septuagesima-abs (- easter-abs 63))
         (sexagesima-abs   (- easter-abs 56))
         (quinquagesima-abs (- easter-abs 49))
         (ash-abs          (- easter-abs 46))
         (palm-abs         (- easter-abs 7))
         (ascension-abs    (+ easter-abs 39))
         (pentecost-abs    (+ easter-abs 49))
         (trinity-abs      (+ easter-abs 56))
         (advent-next-abs  (calendar-absolute-from-gregorian
                            (bcp-advent-1 year))))
    (list :advent         advent-abs
          :christmas      christmas-abs
          :epiphany       epiphany-abs
          :septuagesima   septuagesima-abs
          :sexagesima     sexagesima-abs
          :quinquagesima  quinquagesima-abs
          :ash-wednesday  ash-abs
          :easter         easter-abs
          :palm-sunday    palm-abs
          :ascension      ascension-abs
          :pentecost      pentecost-abs
          :trinity        trinity-abs
          :advent-next    advent-next-abs)))

(defun bcp-1928--easter-year (month day year)
  "Return the calendar year in which Easter falls for the church year
that contains (MONTH DAY YEAR).
The church year starts on Advent Sunday of YEAR-1 and ends on the
Saturday before Advent Sunday of YEAR."
  (let* ((advent-this (calendar-absolute-from-gregorian
                       (bcp-advent-1 year)))
         (abs (calendar-absolute-from-gregorian (list month day year))))
    ;; If date is on or after Advent Sunday of this year → Easter is next year
    (if (>= abs advent-this)
        (1+ year)
      year)))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Liturgical day classification
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1928-liturgical-day (month day year)
  "Return the liturgical position of (MONTH DAY YEAR) as (WEEK-KEY . DOW).

WEEK-KEY is a symbol identifying the liturgical week; DOW is a
day-of-week symbol (`sunday'…`saturday').

For fixed-date entries in the Christmas/Epiphany octaves, WEEK-KEY is a
date-specific symbol on weekdays.  On Sundays within those octaves the
floating Sunday key (`after-christmas-N') is returned instead.

Returns nil if the date cannot be classified."
  (let* ((date    (list month day year))
         (dow     (bcp-1928--dow date))
         (abs     (calendar-absolute-from-gregorian date))
         (ey      (bcp-1928--easter-year month day year))
         (anchors (bcp-1928--anchors ey))
         ;; Anchor shortcuts
         (advent-abs        (plist-get anchors :advent))
         (christmas-abs     (plist-get anchors :christmas))
         (epiphany-abs      (plist-get anchors :epiphany))
         (septuagesima-abs  (plist-get anchors :septuagesima))
         (sexagesima-abs    (plist-get anchors :sexagesima))
         (quinquagesima-abs (plist-get anchors :quinquagesima))
         (ash-abs           (plist-get anchors :ash-wednesday))
         (easter-abs        (plist-get anchors :easter))
         (palm-abs          (plist-get anchors :palm-sunday))
         (ascension-abs     (plist-get anchors :ascension))
         (pentecost-abs     (plist-get anchors :pentecost))
         (trinity-abs       (plist-get anchors :trinity))
         (advent-next-abs   (plist-get anchors :advent-next))
         ;; Most recent Sunday ≤ abs
         (dow-n       (calendar-day-of-week date))
         (last-sun    (- abs dow-n)))

    (cond

     ;; ── Advent ────────────────────────────────────────────────────────────
     ;; Advent runs from Advent Sunday (advent-abs) through Christmas Eve.
     ;; Note: advent-abs = bcp-advent-1(ey-1), which is the correct
     ;; start of the Advent season for the church year whose Easter falls in ey.
     ((and (>= abs advent-abs)
           (< abs christmas-abs))
      (let ((n (1+ (/ (- last-sun advent-abs) 7))))
        (cons (intern (format "advent-%d" n)) dow)))

     ;; ── Christmas octave (Dec 25 – Dec 31) ───────────────────────────────
     ;; On Sundays, use the floating Sunday key; on weekdays, date-specific key.
     ((and (>= abs christmas-abs) (< abs (+ christmas-abs 7)))
      (if (eq dow 'sunday)
          ;; First or second Sunday after Christmas (within Dec 25-31)
          (let ((n (1+ (/ (- last-sun christmas-abs) 7))))
            (cons (intern (format "after-christmas-%d" n)) 'sunday))
        (let* ((offset (- abs christmas-abs))
               (key (pcase offset
                      (0 'christmas)
                      (1 'st-stephen)
                      (2 'st-john-evangelist)
                      (3 'holy-innocents)
                      (4 'december-29)
                      (5 'december-30)
                      (6 'december-31))))
          (cons key dow))))

     ;; ── Circumcision and Epiphany octave (Jan 1 – Jan 6) ─────────────────
     ((and (>= abs (+ christmas-abs 7)) (<= abs epiphany-abs))
      (if (eq dow 'sunday)
          ;; Sunday in the octave: after-christmas-N
          (let ((n (1+ (/ (- last-sun christmas-abs) 7))))
            (cons (intern (format "after-christmas-%d" n)) 'sunday))
        (let* ((jan-abs  (calendar-absolute-from-gregorian (list 1 1 year)))
               (jan-day  (- abs jan-abs -1))   ; 1 = Jan 1
               (key (pcase jan-day
                      (1  'circumcision)
                      (2  'january-2)
                      (3  'january-3)
                      (4  'january-4)
                      (5  'january-5)
                      (6  'epiphany)
                      (_  nil))))
          (cons key dow))))

     ;; ── Epiphany + Sundays after Epiphany ─────────────────────────────────
     ;; Epiphany itself: date-specific key on weekday, after-epiphany-1 on Sunday
     ;; Post-Epiphany weeks up to Septuagesima
     ((and (> abs epiphany-abs) (< abs septuagesima-abs))
      (let ((n (1+ (/ (- last-sun epiphany-abs) 7))))
        (cons (intern (format "after-epiphany-%d" n)) dow)))

     ;; ── Pre-Lent ──────────────────────────────────────────────────────────
     ((= abs septuagesima-abs)
      (cons 'septuagesima dow))
     ((and (> abs septuagesima-abs) (< abs sexagesima-abs))
      (cons 'septuagesima dow))
     ((= abs sexagesima-abs)
      (cons 'sexagesima dow))
     ((and (> abs sexagesima-abs) (< abs quinquagesima-abs))
      (cons 'sexagesima dow))
     ((= abs quinquagesima-abs)
      (cons 'quinquagesima dow))
     ((and (> abs quinquagesima-abs) (< abs ash-abs))
      (cons 'quinquagesima dow))

     ;; ── Ash Wednesday ─────────────────────────────────────────────────────
     ((= abs ash-abs)
      (cons 'ash-wednesday dow))

     ;; ── Lent 1-5 ──────────────────────────────────────────────────────────
     ((and (> abs ash-abs) (< abs palm-abs))
      (let ((n (1+ (/ (- last-sun ash-abs) 7))))
        (cons (intern (format "lent-%d" n)) dow)))

     ;; ── Holy Week (Palm Sunday through Holy Saturday) ─────────────────────
     ((and (>= abs palm-abs) (< abs easter-abs))
      (cons 'palm-sunday dow))

     ;; ── Easter Day + Easter octave (7 following days) ─────────────────────
     ((and (>= abs easter-abs) (< abs (+ easter-abs 7)))
      (cons 'easter dow))

     ;; ── Sundays after Easter (Easter 1-5) ─────────────────────────────────
     ((and (>= abs (+ easter-abs 7)) (< abs ascension-abs))
      (let ((n (/ (- last-sun easter-abs) 7)))
        (cons (intern (format "after-easter-%d" n)) dow)))

     ;; ── Ascension Day ─────────────────────────────────────────────────────
     ((= abs ascension-abs)
      (cons 'ascension dow))

     ;; ── Sunday after Ascension ────────────────────────────────────────────
     ((and (> abs ascension-abs) (< abs pentecost-abs))
      (cons 'sunday-after-ascension dow))

     ;; ── Whitsunday + 6 following days ─────────────────────────────────────
     ((and (>= abs pentecost-abs) (< abs trinity-abs))
      (cons 'whitsunday dow))

     ;; ── Trinity Sunday ────────────────────────────────────────────────────
     ((= abs trinity-abs)
      (cons 'trinity 'sunday))

     ;; ── Sundays after Trinity ─────────────────────────────────────────────
     ((and (> abs trinity-abs) (< abs advent-next-abs))
      (let* ((raw-n       (/ (- last-sun trinity-abs) 7))
             (sun-bef-adv (- advent-next-abs 7))
             ;; Last Epiphany Sunday actually observed this church year.
             ;; Epiphany Sundays n-max-epi+1 … 6 were omitted and are
             ;; transferred to the end of Trinity (BCP rubric).
             (n-max-epi   (/ (- septuagesima-abs epiphany-abs) 7)))
        (cond
         ;; Sunday Before Advent is always the last Sunday
         ((= last-sun sun-bef-adv)
          (cons 'sunday-before-advent dow))
         ;; Trinity 25+: use the omitted Epiphany propers in order
         ((>= raw-n 25)
          (let* ((overflow-index (- raw-n 24)) ; 1 for Trin-25, 2 for Trin-26…
                 (epi-n          (+ n-max-epi overflow-index)))
            (cons (if (<= epi-n 6)
                      (intern (format "after-epiphany-%d" epi-n))
                    ;; No overflow propers remain; fall back to Trinity 24
                    'after-trinity-24)
                  dow)))
         (t
          (cons (intern (format "after-trinity-%d" raw-n)) dow)))))

     ;; ── Fallback ──────────────────────────────────────────────────────────
     (t nil))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Precedence / rank
;;;; ══════════════════════════════════════════════════════════════════════════

;; Tier 1: immoveable — clash → feast transferred to next open day.
;; Tier 2: transferable — displace ordinary days; yield to Tier 1.
;; Tier 3: lesser / commons.

(defconst bcp-1928-rank-tier-1
  '(;; Advent Sundays — whole weeks count as tier 1
    advent-1 advent-2 advent-3 advent-4
    ;; Christmas to Epiphany sequence
    christmas epiphany
    ;; Pre-Lent principal Sundays
    septuagesima sexagesima quinquagesima
    ;; Lent
    ash-wednesday lent-1 lent-2 lent-3 lent-4 lent-5
    ;; Holy Week through Easter octave
    palm-sunday easter
    ;; Rogation, Ascension, Whitsun, Trinity
    rogation-sunday ascension sunday-after-ascension
    whitsunday trinity)
  "Symbols for Tier 1 (immoveable) liturgical positions in the 1928 BCP.
Any feast falling on one of these days is transferred to the next open day.")

(defconst bcp-1928-rank-tier-2
  '(st-stephen st-john-evangelist holy-innocents circumcision
    conversion-of-st-paul purification st-john-baptist
    st-matthias st-mark st-philip-and-james st-barnabas
    st-peter st-james st-bartholomew st-matthew
    st-simon-and-jude st-luke st-andrew st-thomas st-paul
    transfiguration st-michael-and-all-angels all-saints)
  "Symbols for Tier 2 (transferable) feasts in the 1928 BCP.
These displace ordinary days but yield to Tier 1 days.")

(defun bcp-1928-feast-rank (symbol)
  "Return the precedence tier (1, 2, or 3) for feast or day SYMBOL."
  (cond
   ((memq symbol bcp-1928-rank-tier-1) 1)
   ((memq symbol bcp-1928-rank-tier-2) 2)
   (t 3)))

(defun bcp-1928-tier-1-day-p (month day year)
  "Return non-nil when (MONTH DAY YEAR) is a Tier 1 immoveable day."
  (let* ((pos (bcp-1928-liturgical-day month day year))
         (key (car pos)))
    (memq key bcp-1928-rank-tier-1)))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Fixed feast table
;;;; ══════════════════════════════════════════════════════════════════════════

(defconst bcp-1928-feast-data
  ;; Each entry: (SYMBOL :date (MONTH DAY) :rank TIER :title STRING)
  '((st-andrew
     :date (11 30) :rank 2 :title "St. Andrew, Apostle and Evangelist")
    (st-thomas
     :date (12 21) :rank 2 :title "St. Thomas, Apostle")
    (st-stephen
     :date (12 26) :rank 2 :title "St. Stephen, Deacon and Martyr")
    (st-john-evangelist
     :date (12 27) :rank 2 :title "St. John, Apostle and Evangelist")
    (holy-innocents
     :date (12 28) :rank 2 :title "The Holy Innocents")
    (circumcision
     :date (1 1)   :rank 2 :title "The Circumcision of Christ")
    (conversion-of-st-paul
     :date (1 25)  :rank 2 :title "The Conversion of St. Paul")
    (purification
     :date (2 2)   :rank 2 :title "The Purification of St. Mary the Virgin")
    (st-matthias
     :date (2 24)  :rank 2 :title "St. Matthias, Apostle")
    (annunciation
     :date (3 25)  :rank 2 :title "The Annunciation of the Blessed Virgin Mary")
    (st-mark
     :date (4 25)  :rank 2 :title "St. Mark, Evangelist")
    (st-philip-and-james
     :date (5 1)   :rank 2 :title "St. Philip and St. James, Apostles")
    (st-barnabas
     :date (6 11)  :rank 2 :title "St. Barnabas, Apostle")
    (st-john-baptist
     :date (6 24)  :rank 2 :title "The Nativity of St. John the Baptist")
    (st-peter
     :date (6 29)  :rank 2 :title "St. Peter, Apostle")
    (st-james
     :date (7 25)  :rank 2 :title "St. James, Apostle")
    (transfiguration
     :date (8 6)   :rank 2 :title "The Transfiguration of Christ")
    (st-bartholomew
     :date (8 24)  :rank 2 :title "St. Bartholomew, Apostle")
    (st-matthew
     :date (9 21)  :rank 2 :title "St. Matthew, Apostle and Evangelist")
    (st-michael-and-all-angels
     :date (9 29)  :rank 2 :title "St. Michael and All Angels")
    (st-luke
     :date (10 18) :rank 2 :title "St. Luke, Evangelist")
    (st-simon-and-jude
     :date (10 28) :rank 2 :title "St. Simon and St. Jude, Apostles")
    (all-saints
     :date (11 1)  :rank 2 :title "All Saints"))
  "Fixed feast day data for the 1928 American BCP.
Each entry: (SYMBOL :date (MONTH DAY) :rank TIER :title STRING).")

(defun bcp-1928-feast-info (symbol)
  "Return the data plist for feast SYMBOL, or nil."
  (cdr (assq symbol bcp-1928-feast-data)))

(defun bcp-1928-feasts-for-date (month day)
  "Return a list of feast symbols falling on MONTH DAY (any year)."
  (cl-loop for (sym . data) in bcp-1928-feast-data
           when (equal (plist-get data :date) (list month day))
           collect sym))

(defun bcp-1928-transfer-p (feast-symbol month day year)
  "Return non-nil if FEAST-SYMBOL must be transferred from (MONTH DAY YEAR).
A feast is transferred when it falls on a Tier 1 immoveable day."
  (bcp-1928-tier-1-day-p month day year))

(provide 'bcp-anglican-1928-calendar)
;;; bcp-anglican-1928-calendar.el ends here
