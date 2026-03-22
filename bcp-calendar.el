;;; bcp-calendar.el --- Generic Western liturgical calendar engine -*- lexical-binding: t -*-

;; Author: You
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1") (cl-lib "0.5"))
;; Keywords: liturgy, calendar, bcp, breviary, office

;;; Commentary:

;; Rite-agnostic calendar engine for Western liturgical prayer books.
;; Provides the mathematical and structural foundation shared by all
;; Western rites: the BCP family (1662, Divine Worship), the Roman
;; Breviary (Breviarium Romanum), the Little Office of the BVM, etc.
;;
;; What lives HERE (rite-agnostic):
;;   - Easter calculation (Gregorian algorithm)
;;   - Dominical letter
;;   - Leap-year predicate
;;   - Date arithmetic helpers
;;   - Moveable feast offsets from Easter (universal Western computus)
;;   - Advent Sunday calculation
;;   - Ember Days and Rogation Days
;;   - The full Western feast-rank taxonomy (see below)
;;   - Rank comparison and precedence utilities
;;
;; What does NOT live here (rite-specific, belongs in bcp-1662-calendar.el
;; or equivalent):
;;   - Season names and boundaries (differ by rite: BCP has pre-lent/
;;     passiontide/trinity; Roman rite has per annum/etc.)
;;   - Liturgical week numbering schemes (Trinity counting vs. per annum)
;;   - Feast tables (the actual saints and their dates)
;;   - Vigil / fast rules
;;   - Octave classifications
;;   - Transfer / occurrence rules
;;
;; ──────────────────────────────────────────────────────────────────────
;; THE WESTERN FEAST-RANK TAXONOMY
;; ──────────────────────────────────────────────────────────────────────
;;
;; This is the most granular ranking system used in the Western church,
;; drawn from the pre-1955 Tridentine rubrics (the Breviarium Romanum
;; / Missale Romanum in their historic form).  Later reforms simplified
;; it; the 1962 Missale collapsed it to four classes; the post-Vatican II
;; Ordinary Form reduced it further.  We preserve the full historic
;; taxonomy so that any rite can map its own categories onto a subset.
;;
;; RANK SYMBOLS (highest → lowest precedence, numeric value 0 → 12):
;;
;;   Sundays and privileged seasons:
;;     sunday-1cl        — Sunday of the 1st class (e.g. Easter Sunday,
;;                         Pentecost Sunday, Christmas Day [Sunday])
;;     sunday-2cl        — Sunday of the 2nd class (e.g. Palm Sunday,
;;                         Sundays of Advent / Lent in some rites)
;;     sunday-common     — Common Sunday (Sundays after Epiphany/Pentecost)
;;
;;   Feasts proper:
;;     double-1cl        — Double of the 1st class
;;                         1962: "First Class Feast"
;;                         OF equivalent: Solemnity
;;                         Examples: Christmas, Easter, Epiphany,
;;                         Ascension, Pentecost, Corpus Christi,
;;                         Sacred Heart, Immaculate Conception,
;;                         Assumption, All Saints, patron of diocese/parish
;;     double-2cl        — Double of the 2nd class
;;                         1962: "Second Class Feast"
;;                         OF equivalent: Feast
;;                         Examples: Feasts of Apostles (generally),
;;                         Holy Family, Christ the King, most Marian feasts
;;     greater-double    — Greater Double (duplex maius)
;;                         1962: collapsed into 2nd or 3rd class
;;                         Feasts such as the Doctors of the Church,
;;                         some Confessors of higher standing
;;     double            — Double (duplex)
;;                         1962: "Third Class Feast" (upper tier)
;;                         OF equivalent: Memorial (obligatory)
;;                         Examples: most saint's days with full propers
;;     semidouble        — Semidouble (semiduplex)
;;                         1962: abolished (merged into simple/3rd class)
;;                         Pre-1955: ferias of lower rank, some octave days,
;;                         feasts of moderate standing
;;     simple            — Simple (simplex)
;;                         1962: "Fourth Class Feast" / Commemoration
;;                         OF equivalent: Optional Memorial
;;                         Examples: minor saints, Saturday BVM,
;;                         votive masses, the lowest feast days
;;
;;   Ferias (non-feast weekdays):
;;     feria-privileged  — Privileged Feria (feria privilegiata)
;;                         Ash Wednesday and the days of Holy Week;
;;                         these cannot be displaced by any feast
;;     feria-major       — Major Feria (feria major)
;;                         Weekdays of Advent, Lent, and the Ember Days;
;;                         can displace simples and commemorations
;;     feria-minor       — Minor Feria (feria minor)
;;                         Ordinary weekdays throughout the year
;;
;;   Octaves:
;;     octave-1cl        — Octave of the 1st class (privileged octave):
;;                         Easter and Pentecost octaves; no feast may
;;                         displace a day within these octaves
;;     octave-2cl        — Octave of the 2nd class (common octave):
;;                         Christmas, Epiphany, Ascension, Corpus Christi,
;;                         Sacred Heart; days may be displaced by
;;                         double-1cl or double-2cl feasts
;;     octave-3cl        — Octave of the 3rd class (simple octave):
;;                         All Saints and some others; easily displaced
;;
;;   Vigils:
;;     vigil-1cl         — Vigil of the 1st class (privileged vigil):
;;                         Vigil of Christmas and Pentecost; rank similar
;;                         to double-2cl in practice
;;     vigil-2cl         — Vigil of the 2nd class:
;;                         Vigils of Epiphany, Ascension, and some Apostles
;;     vigil-common      — Common vigil: all other vigils with propers
;;
;;   Commemorations:
;;     commemoration     — A commemoration (not a full feast): the collect,
;;                         secret, and postcommunion of a displaced feast
;;                         added to the principal Mass.  Has no rank of its
;;                         own in the modern sense; included here as a
;;                         structural category.
;;
;; MAPPING TO SIMPLIFIED SYSTEMS:
;;
;;   BCP 1662 (principal / greater / lesser):
;;     principal  ← double-1cl, sunday-1cl
;;     greater    ← double-2cl, greater-double, sunday-2cl
;;     lesser     ← double, semidouble, simple, sunday-common
;;
;;   1962 Missale (First / Second / Third / Fourth class):
;;     first-class   ← double-1cl, sunday-1cl
;;     second-class  ← double-2cl, sunday-2cl
;;     third-class   ← greater-double, double, semidouble, feria-major
;;     fourth-class  ← simple, feria-minor, commemoration
;;
;;   Ordinary Form (Solemnity / Feast / Memorial / Optional Memorial):
;;     solemnity         ← double-1cl
;;     feast             ← double-2cl
;;     memorial          ← double (obligatory memorial)
;;     optional-memorial ← simple
;;     feria             ← feria-minor / feria-major

;;; Code:

(require 'cl-lib)
(require 'calendar)


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Rank taxonomy
;;;; ══════════════════════════════════════════════════════════════════════════

(defconst bcp-rank-order
  '(sunday-1cl
    double-1cl
    octave-1cl
    vigil-1cl
    sunday-2cl
    double-2cl
    octave-2cl
    vigil-2cl
    greater-double
    sunday-common
    double
    semidouble
    octave-3cl
    vigil-common
    feria-privileged
    feria-major
    simple
    feria-minor
    commemoration)
  "All Western liturgical rank symbols in descending precedence order.
Index 0 is highest precedence.  This is the full pre-1955 Tridentine
taxonomy; rite-specific modules map their own rank names onto a subset
of these symbols via `bcp-rank-aliases'.")

(defconst bcp-rank-descriptions
  '((sunday-1cl       . "Sunday of the 1st class")
    (double-1cl       . "Double of the 1st class (1962: First Class; OF: Solemnity)")
    (octave-1cl       . "Privileged Octave (1st class)")
    (vigil-1cl        . "Privileged Vigil (1st class)")
    (sunday-2cl       . "Sunday of the 2nd class")
    (double-2cl       . "Double of the 2nd class (1962: Second Class; OF: Feast)")
    (octave-2cl       . "Common Octave (2nd class)")
    (vigil-2cl        . "Vigil of the 2nd class")
    (greater-double   . "Greater Double (duplex maius)")
    (sunday-common    . "Common Sunday")
    (double           . "Double (duplex; 1962: Third Class; OF: Obligatory Memorial)")
    (semidouble       . "Semidouble (semiduplex; abolished 1955)")
    (octave-3cl       . "Simple Octave (3rd class)")
    (vigil-common     . "Common Vigil")
    (feria-privileged . "Privileged Feria (Ash Wednesday, Holy Week)")
    (feria-major      . "Major Feria (Advent/Lent weekdays, Ember Days)")
    (simple           . "Simple (simplex; 1962: Fourth Class; OF: Optional Memorial)")
    (feria-minor      . "Minor Feria (ordinary weekday)")
    (commemoration    . "Commemoration"))
  "Human-readable descriptions for each rank symbol.")

(defconst bcp-rank-aliases
  '(;; BCP 1662 names → canonical rank
    (principal . double-1cl)
    (greater   . double-2cl)
    (lesser    . double)
    ;; 1962 class names → canonical rank
    (first-class   . double-1cl)
    (second-class  . double-2cl)
    (third-class   . double)
    (fourth-class  . simple)
    ;; Ordinary Form names → canonical rank
    (solemnity        . double-1cl)
    (feast            . double-2cl)
    (memorial         . double)
    (optional-memorial . simple))
  "Alist mapping rite-specific rank aliases to canonical `bcp-rank-order' symbols.
Rite modules may extend this list with their own aliases.")


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Rank utilities

(defun bcp-rank-canonical (rank)
  "Return the canonical rank symbol for RANK.
If RANK is an alias (see `bcp-rank-aliases'), return its canonical form.
If RANK is already canonical, return it unchanged.
Return nil if RANK is not recognised."
  (or (cdr (assq rank bcp-rank-aliases))
      (and (memq rank bcp-rank-order) rank)))

(defun bcp-rank-value (rank)
  "Return the numeric precedence for RANK (lower number = higher precedence).
Resolves aliases.  Returns nil if RANK is not recognised."
  (let ((canonical (bcp-rank-canonical rank)))
    (when canonical
      (cl-position canonical bcp-rank-order))))

(defun bcp-rank< (rank-a rank-b)
  "Return t if RANK-A has strictly higher precedence than RANK-B.
\(i.e. RANK-A outranks RANK-B; lower numeric value wins.)"
  (let ((va (bcp-rank-value rank-a))
        (vb (bcp-rank-value rank-b)))
    (and va vb (< va vb))))

(defun bcp-rank<= (rank-a rank-b)
  "Return t if RANK-A has equal or higher precedence than RANK-B."
  (let ((va (bcp-rank-value rank-a))
        (vb (bcp-rank-value rank-b)))
    (and va vb (<= va vb))))

(defun bcp-rank-higher (rank-a rank-b)
  "Return whichever of RANK-A and RANK-B has higher precedence.
If equal, return RANK-A.  Resolves aliases."
  (if (bcp-rank<= rank-a rank-b) rank-a rank-b))

(defun bcp-rank-description (rank)
  "Return a human-readable description string for RANK, or nil."
  (let ((canonical (bcp-rank-canonical rank)))
    (cdr (assq canonical bcp-rank-descriptions))))


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Date arithmetic helpers
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-date= (d1 d2)
  "Return t if dates D1 and D2 are the same calendar day.
Each date is a list (MONTH DAY YEAR)."
  (and (= (car d1) (car d2))
       (= (cadr d1) (cadr d2))
       (= (caddr d1) (caddr d2))))

(defun bcp-date-in-list-p (date date-list)
  "Return t if DATE appears in DATE-LIST."
  (cl-some (lambda (d) (bcp-date= date d)) date-list))

(defun bcp-date+ (month day year n)
  "Return the date N days after (MONTH DAY YEAR) as (MONTH DAY YEAR)."
  (calendar-gregorian-from-absolute
   (+ (calendar-absolute-from-gregorian (list month day year)) n)))

(defun bcp-date- (month day year n)
  "Return the date N days before (MONTH DAY YEAR) as (MONTH DAY YEAR)."
  (bcp-date+ month day year (- n)))

(defun bcp-day-of-week (month day year)
  "Return the day of week for (MONTH DAY YEAR): 0 = Sunday … 6 = Saturday."
  (calendar-day-of-week (list month day year)))

(defun bcp-next-weekday (month day year weekday)
  "Return the first date on or after (MONTH DAY YEAR) with day-of-week WEEKDAY.
WEEKDAY is 0 (Sunday) through 6 (Saturday)."
  (let* ((abs  (calendar-absolute-from-gregorian (list month day year)))
         (dow  (calendar-day-of-week (list month day year)))
         (diff (mod (- weekday dow) 7)))
    (calendar-gregorian-from-absolute (+ abs diff))))

(defun bcp-prev-weekday (month day year weekday)
  "Return the last date on or before (MONTH DAY YEAR) with day-of-week WEEKDAY."
  (let* ((abs  (calendar-absolute-from-gregorian (list month day year)))
         (dow  (calendar-day-of-week (list month day year)))
         (diff (mod (- dow weekday) 7)))
    (calendar-gregorian-from-absolute (- abs diff))))

(defun bcp-days-between (m1 d1 y1 m2 d2 y2)
  "Return the number of days from (M1 D1 Y1) to (M2 D2 Y2).
Positive if the second date is later."
  (- (calendar-absolute-from-gregorian (list m2 d2 y2))
     (calendar-absolute-from-gregorian (list m1 d1 y1))))

(defun bcp-days-after-easter (month day year)
  "Return the number of days (MONTH DAY YEAR) falls after Easter of YEAR.
Negative if the date precedes Easter."
  (let* ((easter (bcp-easter year))
         (e-abs  (calendar-absolute-from-gregorian easter))
         (d-abs  (calendar-absolute-from-gregorian (list month day year))))
    (- d-abs e-abs)))


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Easter & the Computus
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-leap-year-p (year)
  "Return t if YEAR is a Gregorian leap year."
  (or (and (= (mod year 4) 0)
           (not (= (mod year 100) 0)))
      (= (mod year 400) 0)))

(defun bcp-easter (year)
  "Return Easter Sunday for YEAR as (MONTH DAY YEAR).

Uses the Anonymous Gregorian algorithm (Meeus/Jones/Butcher).
Easter falls between March 22 and April 25 inclusive.

This is the standard Gregorian computus, valid for all Western rites
that observe Easter.  The Julian-calendar Easter (used by Eastern
Orthodox churches) is a different calculation and not implemented here."
  (let* ((a (mod year 19))
         (b (/ year 100))
         (c (mod year 100))
         (d (/ b 4))
         (e (mod b 4))
         (f (/ (+ b 8) 25))
         (g (/ (+ (- b f) 1) 3))
         (h (mod (+ (* 19 a) (- b d g) 15) 30))
         (i (/ c 4))
         (k (mod c 4))
         (l (mod (+ 32 (* 2 e) (* 2 i) (- h) (- k)) 7))
         (m (/ (+ a (* 11 h) (* 22 l)) 451))
         (month (/ (+ h l (* -7 m) 114) 31))
         (day   (1+ (mod (+ h l (* -7 m) 114) 31))))
    (list month day year)))


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Dominical Letter
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-dominical-letter (year)
  "Return the dominical letter(s) for YEAR as a string.

For common years: a single letter \"A\"–\"G\".
For leap years: two letters, e.g. \"GF\", where the first applies
January 1 – February 28, and the second applies from March 1 onward.

Valid through 2199."
  (let* ((century-add (if (< year 2100) 6 5))
         (rem  (mod (+ year (/ year 4) century-add) 7))
         (letters "AGFEDCB"))
    (if (bcp-leap-year-p year)
        (let* ((second (substring letters rem (1+ rem)))
               (first  (substring letters (mod (1- rem) 7)
                                   (1+ (mod (1- rem) 7)))))
          (concat first second))
      (substring letters rem (1+ rem)))))


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Advent Sunday
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-advent-sunday (year)
  "Return Advent Sunday for YEAR as (MONTH DAY YEAR).

Advent Sunday is the nearest Sunday to St Andrew's Day (November 30).
If November 30 is itself a Sunday, that day is Advent Sunday.
Advent Sunday always falls between November 27 and December 3."
  (let* ((nov30-abs (calendar-absolute-from-gregorian (list 11 30 year)))
         (dow (calendar-day-of-week (list 11 30 year))))
    (if (= dow 0)
        (list 11 30 year)
      (let* ((back dow)
             (fwd  (- 7 dow))
             (target (if (<= back fwd)
                         (- nov30-abs back)
                       (+ nov30-abs fwd))))
        (calendar-gregorian-from-absolute target)))))


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Moveable feasts (universal Western computus)
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-moveable-feasts (year)
  "Return an alist of standard moveable feast dates for YEAR.

All dates derive from Easter Sunday by fixed offsets that are common
across all Western rites.  Each entry is (FEAST-SYMBOL . (MONTH DAY YEAR)).

Feasts returned:
  easter           — Easter Sunday (the anchor of the computus)
  ash-wednesday    — Easter − 46
  passion-sunday   — Easter − 14  (5th Sunday of Lent)
  palm-sunday      — Easter − 7
  easter-1         — Easter + 7   (Low Sunday / Quasimodo)
  rogation-sunday  — Easter + 35  (5th Sunday after Easter)
  ascension        — Easter + 39  (Thursday)
  whitsunday       — Easter + 49  (Pentecost Sunday)
  trinity-sunday   — Easter + 56
  advent-sunday    — nearest Sunday to November 30

Note: Corpus Christi (Easter + 60), Sacred Heart (Easter + 68), and
Christ the King (last Sunday before Advent in some calendars) are not
included here as their observance is rite-specific."
  (let* ((easter (bcp-easter year))
         (e (calendar-absolute-from-gregorian easter)))
    (list
     (cons 'easter          easter)
     (cons 'ash-wednesday   (calendar-gregorian-from-absolute (- e 46)))
     (cons 'passion-sunday  (calendar-gregorian-from-absolute (- e 14)))
     (cons 'palm-sunday     (calendar-gregorian-from-absolute (- e 7)))
     (cons 'easter-1        (calendar-gregorian-from-absolute (+ e 7)))
     (cons 'rogation-sunday (calendar-gregorian-from-absolute (+ e 35)))
     (cons 'ascension       (calendar-gregorian-from-absolute (+ e 39)))
     (cons 'whitsunday      (calendar-gregorian-from-absolute (+ e 49)))
     (cons 'trinity-sunday  (calendar-gregorian-from-absolute (+ e 56)))
     (cons 'advent-sunday   (bcp-advent-sunday year)))))

(defun bcp-moveable-feast-date (feast year)
  "Return the date of moveable FEAST in YEAR as (MONTH DAY YEAR), or nil."
  (cdr (assq feast (bcp-moveable-feasts year))))


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Ember Days and Rogation Days
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-ember-days (year)
  "Return the Ember Days for YEAR as a list of dates (MONTH DAY YEAR).

Ember Days are Wednesday, Friday, and Saturday in each of four weeks:
  1. The week of Ash Wednesday            (Winter Ember Days)
  2. The week of Whit Sunday              (Summer Ember Days)
  3. The week after Holy Cross Day Sep 14 (Autumn Ember Days)
  4. The week after St Lucy's Day Dec 13  (Advent Ember Days)

Ember Days are observed in both the Roman Rite and the BCP tradition.
In the 1962 Missale they are Major Ferias; in the BCP they are Fast Days.
The post-Vatican II Ordinary Form does not mandate Ember Days by fixed
dates but leaves them to national conferences."
  (let* ((feasts (bcp-moveable-feasts year))
         (ash    (cdr (assq 'ash-wednesday feasts)))
         (whit   (cdr (assq 'whitsunday feasts))))
    (append
     (bcp--ember-triad-from ash)
     (bcp--ember-triad-from whit)
     (bcp--ember-triad-after (list 9 14 year))
     (bcp--ember-triad-after (list 12 13 year)))))

(defun bcp--ember-triad-from (anchor-date)
  "Return Wed, Fri, Sat of the same week as ANCHOR-DATE."
  (let* ((abs (calendar-absolute-from-gregorian anchor-date))
         (dow (calendar-day-of-week anchor-date))
         (sun (- abs dow)))                   ; Sunday of the same week
    (list
     (calendar-gregorian-from-absolute (+ sun 3))   ; Wednesday
     (calendar-gregorian-from-absolute (+ sun 5))   ; Friday
     (calendar-gregorian-from-absolute (+ sun 6))))) ; Saturday

(defun bcp--ember-triad-after (anchor-date)
  "Return the first Wed, Fri, Sat strictly after ANCHOR-DATE."
  (let* ((abs (calendar-absolute-from-gregorian anchor-date))
         (dow (calendar-day-of-week anchor-date))
         (to-wed (mod (- 3 dow) 7))
         (to-wed (if (= to-wed 0) 7 to-wed))
         (wed (+ abs to-wed)))
    (list
     (calendar-gregorian-from-absolute wed)
     (calendar-gregorian-from-absolute (+ wed 2))   ; Friday
     (calendar-gregorian-from-absolute (+ wed 3))))) ; Saturday

(defun bcp-rogation-days (year)
  "Return the three Rogation Days for YEAR as a list of dates (MONTH DAY YEAR).

Rogation Days are the Monday, Tuesday, and Wednesday immediately before
Ascension Day (Easter + 39).  They are observed in both the Roman Rite
and the BCP tradition as days of prayer and fasting."
  (let* ((feasts    (bcp-moveable-feasts year))
         (ascension (cdr (assq 'ascension feasts)))
         (abs       (calendar-absolute-from-gregorian ascension)))
    (list
     (calendar-gregorian-from-absolute (- abs 3))   ; Monday
     (calendar-gregorian-from-absolute (- abs 2))   ; Tuesday
     (calendar-gregorian-from-absolute (- abs 1))))) ; Wednesday


(provide 'bcp-calendar)
;;; bcp-calendar.el ends here
