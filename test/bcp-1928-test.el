;;; bcp-1928-test.el --- Automated shakedown tests for the 1928 BCP -*- lexical-binding: t -*-

;;; Commentary:

;; Run with:
;;   M-x bcp-1928-run-tests
;;
;; Or from the command line:
;;   emacs --batch -L . \
;;     -l bcp-calendar.el \
;;     -l bcp-common-prayers.el \
;;     -l bcp-common-anglican.el \
;;     -l bcp-liturgy-canticles.el \
;;     -l bcp-liturgy-render.el \
;;     -l bcp-liturgy-hours.el \
;;     -l bcp-liturgy-dispatch.el \
;;     -l bcp-1662-calendar.el \
;;     -l bcp-anglican-1928-calendar.el \
;;     -l bcp-anglican-1928-lectionary.el \
;;     -l bcp-anglican-1928-data.el \
;;     -l bcp-anglican-1928-ordo.el \
;;     -l bcp-render.el \
;;     -l bcp-anglican-render.el \
;;     -l bcp-anglican-1928-render.el \
;;     -l bcp-anglican-1928.el \
;;     -l bcp-1928-test.el \
;;     -f bcp-1928-run-tests
;;
;; Results are written to *BCP 1928 Tests* buffer (interactive)
;; or to stdout (batch mode).
;;
;; All date examples use 2026 (Easter April 5):
;;   Ash Wed Feb 18 · Palm Sun Mar 29 · Easter Apr 5
;;   Ascension May 14 · Whitsunday May 24 · Trinity May 31
;;   Advent Sunday Nov 29 · Sunday Next Before Advent Nov 22

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Test framework (mirrors bcp-1662-test.el)

(defvar bcp-1928-test--results nil
  "List of (SECTION NAME PASS EXPECTED ACTUAL) test results.")

(defvar bcp-1928-test--section nil
  "Current test section name.")

(defmacro bcp-1928-test-section (name &rest body)
  "Run BODY as a named test section."
  (declare (indent 1))
  `(progn
     (setq bcp-1928-test--section ,name)
     ,@body))

(defmacro bcp-1928-check (name expected form)
  "Assert that FORM equals EXPECTED, recording result under NAME."
  `(let* ((actual (condition-case err
                      ,form
                    (error (format "ERROR: %s" err))))
          (pass   (equal actual ,expected)))
     (push (list bcp-1928-test--section ,name pass ,expected actual)
           bcp-1928-test--results)))

(defmacro bcp-1928-check-t (name form)
  "Assert that FORM is non-nil."
  `(bcp-1928-check ,name t (and ,form t)))

(defmacro bcp-1928-check-nil (name form)
  "Assert that FORM is nil."
  `(bcp-1928-check ,name nil ,form))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Test definitions

(defun bcp-1928-test--run-all ()
  "Run all automated tests, populating `bcp-1928-test--results'."
  (setq bcp-1928-test--results nil)

  ;; ── 1. Load check ──────────────────────────────────────────────────────
  (bcp-1928-test-section "1. Load check"
    (bcp-1928-check-t "bcp-anglican-1928-calendar loaded"
                      (featurep 'bcp-anglican-1928-calendar))
    (bcp-1928-check-t "bcp-anglican-1928-lectionary loaded"
                      (featurep 'bcp-anglican-1928-lectionary))
    (bcp-1928-check-t "bcp-anglican-1928-data loaded"
                      (featurep 'bcp-anglican-1928-data))
    (bcp-1928-check-t "bcp-anglican-1928 loaded"
                      (featurep 'bcp-anglican-1928)))

  ;; ── 2. Anchors and Easter ────────────────────────────────────────────────
  (bcp-1928-test-section "2. Anchors 2026"
    (let ((a (bcp-1928--anchors 2026)))
      (bcp-1928-check "Easter 2026"
                      (calendar-absolute-from-gregorian '(4 5 2026))
                      (plist-get a :easter))
      (bcp-1928-check "Ash Wednesday 2026"
                      (calendar-absolute-from-gregorian '(2 18 2026))
                      (plist-get a :ash-wednesday))
      (bcp-1928-check "Ascension 2026"
                      (calendar-absolute-from-gregorian '(5 14 2026))
                      (plist-get a :ascension))
      (bcp-1928-check "Whitsunday 2026"
                      (calendar-absolute-from-gregorian '(5 24 2026))
                      (plist-get a :pentecost))
      (bcp-1928-check "Trinity Sunday 2026"
                      (calendar-absolute-from-gregorian '(5 31 2026))
                      (plist-get a :trinity))))

  ;; ── 3. Liturgical day classification ────────────────────────────────────
  (bcp-1928-test-section "3. Liturgical day 2026"
    ;; Pre-Lent (Easter 2026 = Apr 5; Septuagesima = Apr5-63 = Feb 1)
    (bcp-1928-check "Feb 1 (Septuagesima Sun)"
                    '(septuagesima . sunday)  (bcp-1928-liturgical-day  2  1 2026))
    (bcp-1928-check "Feb 8 (Sexagesima Sun)"
                    '(sexagesima . sunday)    (bcp-1928-liturgical-day  2  8 2026))
    (bcp-1928-check "Feb 15 (Quinquagesima Sun)"
                    '(quinquagesima . sunday) (bcp-1928-liturgical-day  2 15 2026))
    ;; Lent
    (bcp-1928-check "Feb 18 (Ash Wed)"
                    '(ash-wednesday . wednesday) (bcp-1928-liturgical-day 2 18 2026))
    ;; Days after Ash Wednesday (before next Sunday) are lent-1
    (bcp-1928-check "Feb 20 (Fri after Ash Wed = lent-1)"
                    '(lent-1 . friday)           (bcp-1928-liturgical-day 2 20 2026))
    (bcp-1928-check "Mar 8 (Lent 3 Sun)"
                    '(lent-3 . sunday)        (bcp-1928-liturgical-day  3  8 2026))
    ;; Holy Week
    (bcp-1928-check "Mar 29 (Palm Sun)"
                    '(palm-sunday . sunday)   (bcp-1928-liturgical-day  3 29 2026))
    (bcp-1928-check "Apr 3 (Good Friday)"
                    '(palm-sunday . friday)   (bcp-1928-liturgical-day  4  3 2026))
    (bcp-1928-check "Apr 4 (Easter Even)"
                    '(palm-sunday . saturday) (bcp-1928-liturgical-day  4  4 2026))
    ;; Easter octave
    (bcp-1928-check "Apr 5 (Easter Day)"
                    '(easter . sunday)        (bcp-1928-liturgical-day  4  5 2026))
    (bcp-1928-check "Apr 6 (Easter Monday)"
                    '(easter . monday)        (bcp-1928-liturgical-day  4  6 2026))
    (bcp-1928-check "Apr 12 (After Easter 1 Sun)"
                    '(after-easter-1 . sunday) (bcp-1928-liturgical-day 4 12 2026))
    ;; Ascension through Whitsun
    (bcp-1928-check "May 14 (Ascension)"
                    '(ascension . thursday)   (bcp-1928-liturgical-day  5 14 2026))
    (bcp-1928-check "May 17 (Sun after Ascension)"
                    '(sunday-after-ascension . sunday) (bcp-1928-liturgical-day 5 17 2026))
    (bcp-1928-check "May 24 (Whitsunday)"
                    '(whitsunday . sunday)    (bcp-1928-liturgical-day  5 24 2026))
    (bcp-1928-check "May 25 (Whit Monday)"
                    '(whitsunday . monday)    (bcp-1928-liturgical-day  5 25 2026))
    ;; Trinity
    (bcp-1928-check "May 31 (Trinity Sunday)"
                    '(trinity . sunday)       (bcp-1928-liturgical-day  5 31 2026))
    (bcp-1928-check "Jun 7 (After Trinity 1 Sun)"
                    '(after-trinity-1 . sunday) (bcp-1928-liturgical-day 6 7 2026))
    (bcp-1928-check "Nov 22 (Sunday Next Before Advent)"
                    '(sunday-before-advent . sunday) (bcp-1928-liturgical-day 11 22 2026))
    ;; Advent
    (bcp-1928-check "Nov 29 (Advent 1 Sun)"
                    '(advent-1 . sunday)      (bcp-1928-liturgical-day 11 29 2026))
    (bcp-1928-check "Dec 6 (Advent 2 Sun)"
                    '(advent-2 . sunday)      (bcp-1928-liturgical-day 12  6 2026))
    ;; Christmas/Epiphany octave
    (bcp-1928-check "Dec 25 (Christmas)"
                    '(christmas . friday)     (bcp-1928-liturgical-day 12 25 2026))
    (bcp-1928-check "Dec 26 (St Stephen)"
                    '(st-stephen . saturday)  (bcp-1928-liturgical-day 12 26 2026))
    (bcp-1928-check "Jan 1 (Circumcision)"
                    '(circumcision . thursday) (bcp-1928-liturgical-day 1  1 2026))
    (bcp-1928-check "Jan 6 (Epiphany)"
                    '(epiphany . tuesday)     (bcp-1928-liturgical-day  1  6 2026)))

  ;; ── 4. Day-key resolution ───────────────────────────────────────────────
  (bcp-1928-test-section "4. Day-key resolution"
    ;; Holy Week
    (bcp-1928-check "palm-sunday+monday = holy-monday"
                    'holy-monday    (bcp-1928--resolve-day-key 'palm-sunday 'monday))
    (bcp-1928-check "palm-sunday+thursday = maundy-thursday"
                    'maundy-thursday (bcp-1928--resolve-day-key 'palm-sunday 'thursday))
    (bcp-1928-check "palm-sunday+friday = good-friday"
                    'good-friday    (bcp-1928--resolve-day-key 'palm-sunday 'friday))
    (bcp-1928-check "palm-sunday+saturday = easter-even"
                    'easter-even    (bcp-1928--resolve-day-key 'palm-sunday 'saturday))
    (bcp-1928-check "palm-sunday+sunday = palm-sunday"
                    'palm-sunday    (bcp-1928--resolve-day-key 'palm-sunday 'sunday))
    ;; Easter octave
    (bcp-1928-check "easter+monday = easter-monday"
                    'easter-monday  (bcp-1928--resolve-day-key 'easter 'monday))
    (bcp-1928-check "easter+tuesday = easter-tuesday"
                    'easter-tuesday (bcp-1928--resolve-day-key 'easter 'tuesday))
    (bcp-1928-check "easter+sunday = easter"
                    'easter         (bcp-1928--resolve-day-key 'easter 'sunday))
    ;; Whitsun week
    (bcp-1928-check "whitsunday+monday = whit-monday"
                    'whit-monday    (bcp-1928--resolve-day-key 'whitsunday 'monday))
    (bcp-1928-check "whitsunday+tuesday = whit-tuesday"
                    'whit-tuesday   (bcp-1928--resolve-day-key 'whitsunday 'tuesday))
    (bcp-1928-check "whitsunday+sunday = whitsunday"
                    'whitsunday     (bcp-1928--resolve-day-key 'whitsunday 'sunday))
    ;; Special Sundays
    (bcp-1928-check "trinity+sunday = trinity-sunday"
                    'trinity-sunday (bcp-1928--resolve-day-key 'trinity 'sunday))
    (bcp-1928-check "sunday-after-ascension → after-ascension"
                    'after-ascension (bcp-1928--resolve-day-key 'sunday-after-ascension 'sunday))
    (bcp-1928-check "sunday-before-advent → after-trinity-25"
                    'after-trinity-25 (bcp-1928--resolve-day-key 'sunday-before-advent 'sunday))
    ;; Passthrough
    (bcp-1928-check "after-trinity-3 passes through"
                    'after-trinity-3 (bcp-1928--resolve-day-key 'after-trinity-3 'wednesday))
    (bcp-1928-check "advent-2 passes through"
                    'advent-2        (bcp-1928--resolve-day-key 'advent-2 'monday)))

  ;; ── 5. Feast table ──────────────────────────────────────────────────────
  (bcp-1928-test-section "5. Feast table"
    ;; Rank checks
    (bcp-1928-check "St Luke rank = 2"       2 (bcp-1928-feast-rank 'st-luke))
    (bcp-1928-check "All Saints rank = 2"    2 (bcp-1928-feast-rank 'all-saints))
    (bcp-1928-check "St Peter rank = 2"      2 (bcp-1928-feast-rank 'st-peter))
    (bcp-1928-check "Transfiguration rank=2" 2 (bcp-1928-feast-rank 'transfiguration))
    (bcp-1928-check "Unknown rank = 3"       3 (bcp-1928-feast-rank 'some-lesser-feast))
    ;; feasts-for-date
    (bcp-1928-check "Oct 18 feasts = (st-luke)"
                    '(st-luke)   (bcp-1928-feasts-for-date 10 18))
    (bcp-1928-check "Jun 29 feasts = (st-peter)"
                    '(st-peter)  (bcp-1928-feasts-for-date  6 29))
    (bcp-1928-check "Nov 1 feasts = (all-saints)"
                    '(all-saints) (bcp-1928-feasts-for-date 11  1))
    (bcp-1928-check "Jun 10 = no fixed feast"
                    nil          (bcp-1928-feasts-for-date  6 10))
    ;; feast-info
    (bcp-1928-check "St Luke title"
                    "St. Luke, Evangelist"
                    (plist-get (bcp-1928-feast-info 'st-luke) :title))
    (bcp-1928-check "All Saints date = Nov 1"
                    '(11 1)
                    (plist-get (bcp-1928-feast-info 'all-saints) :date))
    ;; Tier classification
    (bcp-1928-check-t "advent-1 is Tier 1"
                      (memq 'advent-1 bcp-1928-rank-tier-1))
    (bcp-1928-check-t "easter is Tier 1"
                      (memq 'easter bcp-1928-rank-tier-1))
    (bcp-1928-check-t "st-luke is Tier 2"
                      (memq 'st-luke bcp-1928-rank-tier-2))
    (bcp-1928-check-t "all-saints is Tier 2"
                      (memq 'all-saints bcp-1928-rank-tier-2)))

  ;; ── 6. Collect data ─────────────────────────────────────────────────────
  (bcp-1928-test-section "6. Collect data"
    (bcp-1928-check-t "Advent 1 text"          (bcp-1928-collect-text 'advent-1))
    (bcp-1928-check-t "Advent 1 rubric"        (plist-get (bcp-1928-collect 'advent-1) :rubric))
    (bcp-1928-check-t "Ash Wednesday text"     (bcp-1928-collect-text 'ash-wednesday))
    (bcp-1928-check-t "Palm Sunday text"       (bcp-1928-collect-text 'palm-sunday))
    (bcp-1928-check-t "Good Friday text"       (bcp-1928-collect-text 'good-friday))
    (bcp-1928-check-t "Easter text"            (bcp-1928-collect-text 'easter))
    (bcp-1928-check-t "Ascension text"         (bcp-1928-collect-text 'ascension))
    (bcp-1928-check-t "Whitsunday text"        (bcp-1928-collect-text 'whitsunday))
    (bcp-1928-check-t "Trinity Sunday text"    (bcp-1928-collect-text 'trinity-sunday))
    (bcp-1928-check-t "After Trinity 1 text"   (bcp-1928-collect-text 'after-trinity-1))
    (bcp-1928-check-t "After Trinity 25 text"  (bcp-1928-collect-text 'after-trinity-25))
    (bcp-1928-check-t "St Luke text"           (bcp-1928-collect-text 'st-luke))
    (bcp-1928-check-t "All Saints text"        (bcp-1928-collect-text 'all-saints))
    (bcp-1928-check-t "Christmas text"         (bcp-1928-collect-text 'christmas))
    (bcp-1928-check-t "Epiphany text"          (bcp-1928-collect-text 'epiphany))
    (bcp-1928-check-nil "Nonexistent = nil"    (bcp-1928-collect-text 'no-such-feast))
    ;; Text content spot-check
    (bcp-1928-check "Advent 1 starts ALMIGHTY"
                    "ALMI"
                    (substring (bcp-1928-collect-text 'advent-1) 0 4))
    (bcp-1928-check "After-Trin-25 (Stir Up) starts STIR"
                    "STIR"
                    (substring (bcp-1928-collect-text 'after-trinity-25) 0 4)))

  ;; ── 7. Collect of the day ────────────────────────────────────────────────
  (bcp-1928-test-section "7. Collect of the day"
    ;; Fixed Sundays
    (bcp-1928-check "Advent 1 collect = advent-1"
                    'advent-1        (bcp-1928-collect-of-day 11 29 2026))
    (bcp-1928-check "Trinity Sunday collect = trinity-sunday"
                    'trinity-sunday  (bcp-1928-collect-of-day  5 31 2026))
    (bcp-1928-check "After Trinity 1 Sun = after-trinity-1"
                    'after-trinity-1 (bcp-1928-collect-of-day  6  7 2026))
    (bcp-1928-check "Sun Next Before Advent = after-trinity-25"
                    'after-trinity-25 (bcp-1928-collect-of-day 11 22 2026))
    ;; Ferias inherit preceding Sunday
    (bcp-1928-check "Wed after Trinity 1 = after-trinity-1"
                    'after-trinity-1 (bcp-1928-collect-of-day  6 10 2026))
    (bcp-1928-check "Fri after Advent 1 = advent-1"
                    'advent-1        (bcp-1928-collect-of-day 12  4 2026))
    ;; Feasts take precedence
    (bcp-1928-check "St Luke = st-luke"
                    'st-luke         (bcp-1928-collect-of-day 10 18 2026))
    (bcp-1928-check "All Saints = all-saints"
                    'all-saints      (bcp-1928-collect-of-day 11  1 2026))
    (bcp-1928-check "St Peter = st-peter"
                    'st-peter        (bcp-1928-collect-of-day  6 29 2026))
    ;; Special days
    (bcp-1928-check "Good Friday = good-friday"
                    'good-friday     (bcp-1928-collect-of-day  4  3 2026))
    (bcp-1928-check "Ascension = ascension"
                    'ascension       (bcp-1928-collect-of-day  5 14 2026))
    (bcp-1928-check "Easter = easter"
                    'easter          (bcp-1928-collect-of-day  4  5 2026))
    (bcp-1928-check "Christmas = christmas"
                    'christmas       (bcp-1928-collect-of-day 12 25 2026)))

  ;; ── 8. Seasonal collects ─────────────────────────────────────────────────
  (bcp-1928-test-section "8. Seasonal collects"
    ;; Advent: repeated through Christmas Eve
    (bcp-1928-check "Advent 1 seasonal = advent-1"
                    'advent-1        (bcp-1928-seasonal-collect 11 29 2026))
    (bcp-1928-check "Advent 3 weekday seasonal = advent-1"
                    'advent-1        (bcp-1928-seasonal-collect 12 16 2026))
    (bcp-1928-check "Christmas Eve seasonal = advent-1"
                    'advent-1        (bcp-1928-seasonal-collect 12 24 2026))
    ;; Christmas/Epiphany: none
    (bcp-1928-check-nil "Christmas Day = nil"
                        (bcp-1928-seasonal-collect 12 25 2026))
    (bcp-1928-check-nil "Epiphany = nil"
                        (bcp-1928-seasonal-collect  1  6 2026))
    ;; Lent: ash-wednesday repeated through Holy Week
    (bcp-1928-check "Ash Wed itself: no seasonal (it IS the seasonal)"
                    nil              (bcp-1928-seasonal-collect  2 18 2026))
    (bcp-1928-check "Lent 3 weekday seasonal = ash-wednesday"
                    'ash-wednesday   (bcp-1928-seasonal-collect  3 11 2026))
    ;; Holy Week (passiontide): palm-sunday repeated Mon-Sat
    (bcp-1928-check "Palm Sun itself: no seasonal"
                    nil              (bcp-1928-seasonal-collect  3 29 2026))
    (bcp-1928-check "Mon Holy Week seasonal = palm-sunday"
                    'palm-sunday     (bcp-1928-seasonal-collect  3 30 2026))
    (bcp-1928-check "Good Friday seasonal = palm-sunday"
                    'palm-sunday     (bcp-1928-seasonal-collect  4  3 2026))
    ;; Easter: no seasonal
    (bcp-1928-check-nil "Easter Day = nil"
                        (bcp-1928-seasonal-collect  4  5 2026))
    ;; Ascensiontide: ascension Mon-Sat
    (bcp-1928-check "Ascension itself: no seasonal"
                    nil              (bcp-1928-seasonal-collect  5 14 2026))
    (bcp-1928-check "Mon after Ascension seasonal = ascension"
                    'ascension       (bcp-1928-seasonal-collect  5 15 2026))
    (bcp-1928-check "Fri before Whitsunday seasonal = ascension"
                    'ascension       (bcp-1928-seasonal-collect  5 22 2026))
    ;; Trinity: no seasonal
    (bcp-1928-check-nil "Trinity Sunday = nil"
                        (bcp-1928-seasonal-collect  5 31 2026))
    (bcp-1928-check-nil "Trinity 1 weekday = nil"
                        (bcp-1928-seasonal-collect  6 10 2026)))

  ;; ── 9. Office lessons ────────────────────────────────────────────────────
  (bcp-1928-test-section "9. Office lessons"
    ;; Source routing
    (bcp-1928-check "St Luke source = feast-proper"
                    'feast-proper
                    (plist-get (bcp-1928-office-lessons 10 18 2026 'mattins) :source))
    (bcp-1928-check "All Saints source = feast-proper"
                    'feast-proper
                    (plist-get (bcp-1928-office-lessons 11  1 2026 'mattins) :source))
    (bcp-1928-check "Easter Day source = calendar"
                    'calendar
                    (plist-get (bcp-1928-office-lessons  4  5 2026 'mattins) :source))
    (bcp-1928-check "Trinity 1 Sunday source = calendar"
                    'calendar
                    (plist-get (bcp-1928-office-lessons  6  7 2026 'mattins) :source))
    (bcp-1928-check "Weekday source = calendar"
                    'calendar
                    (plist-get (bcp-1928-office-lessons  6 10 2026 'mattins) :source))
    ;; Lesson presence
    (bcp-1928-check-t "Easter lesson1 present"
                      (plist-get (bcp-1928-office-lessons 4 5 2026 'mattins) :lesson1))
    (bcp-1928-check-t "St Luke lesson1 present"
                      (plist-get (bcp-1928-office-lessons 10 18 2026 'mattins) :lesson1))
    ;; Morning/Evening distinction
    (bcp-1928-check-t "Morning and evening lessons differ on typical day"
                      (not (equal (bcp-1928-office-lessons 6 7 2026 'mattins)
                                  (bcp-1928-office-lessons 6 7 2026 'evensong)))))

  ;; ── 10. Communion propers ────────────────────────────────────────────────
  (bcp-1928-test-section "10. Communion propers"
    (bcp-1928-check "Advent 1 communion = advent-1"
                    'advent-1         (bcp-1928-communion-proper-for-date 11 29 2026))
    (bcp-1928-check "Trinity Sunday communion = trinity-sunday"
                    'trinity-sunday   (bcp-1928-communion-proper-for-date  5 31 2026))
    (bcp-1928-check "Easter communion = easter"
                    'easter           (bcp-1928-communion-proper-for-date  4  5 2026))
    (bcp-1928-check "Ascension communion = ascension"
                    'ascension        (bcp-1928-communion-proper-for-date  5 14 2026))
    (bcp-1928-check "Whitsunday communion = whitsunday"
                    'whitsunday       (bcp-1928-communion-proper-for-date  5 24 2026))
    (bcp-1928-check "St Luke communion = st-luke"
                    'st-luke          (bcp-1928-communion-proper-for-date 10 18 2026))
    (bcp-1928-check "St Peter communion = st-peter"
                    'st-peter         (bcp-1928-communion-proper-for-date  6 29 2026))
    (bcp-1928-check "All Saints communion = all-saints"
                    'all-saints       (bcp-1928-communion-proper-for-date 11  1 2026))
    ;; Data spot-checks
    (bcp-1928-check-t "Advent 1 epistle exists"
                      (plist-get (bcp-1928-communion-proper 'advent-1) :epistle))
    (bcp-1928-check-t "Advent 1 gospel exists"
                      (plist-get (bcp-1928-communion-proper 'advent-1) :gospel))
    (bcp-1928-check-t "St Luke epistle exists"
                      (plist-get (bcp-1928-communion-proper 'st-luke) :epistle)))

  ;; ── 11. Full dispatch ────────────────────────────────────────────────────
  (bcp-1928-test-section "11. Full dispatch"
    ;; Lent weekday (Ash Wednesday itself)
    (let ((p (bcp-1928-propers-for-date 2 18 2026 'mattins)))
      (bcp-1928-check "Ash Wed week = ash-wednesday"
                      'ash-wednesday  (plist-get p :week))
      (bcp-1928-check "Ash Wed season = lent"
                      'lent           (plist-get p :season))
      (bcp-1928-check "Ash Wed collect = ash-wednesday"
                      'ash-wednesday  (plist-get p :collect))
      ;; No seasonal: Ash Wed IS the seasonal collect
      (bcp-1928-check-nil "Ash Wed seasonal = nil"
                          (plist-get p :seasonal-collect)))
    ;; Good Friday
    (let ((p (bcp-1928-propers-for-date 4 3 2026 'mattins)))
      (bcp-1928-check "Good Friday week = good-friday"
                      'good-friday    (plist-get p :week))
      (bcp-1928-check "Good Friday season = passiontide"
                      'passiontide    (plist-get p :season))
      (bcp-1928-check "Good Friday collect = good-friday"
                      'good-friday    (plist-get p :collect))
      (bcp-1928-check "Good Friday seasonal = palm-sunday"
                      'palm-sunday    (plist-get p :seasonal-collect)))
    ;; Easter Day
    (let ((p (bcp-1928-propers-for-date 4 5 2026 'mattins)))
      (bcp-1928-check "Easter week = easter"
                      'easter         (plist-get p :week))
      (bcp-1928-check "Easter season = eastertide"
                      'eastertide     (plist-get p :season))
      (bcp-1928-check "Easter collect = easter"
                      'easter         (plist-get p :collect))
      (bcp-1928-check-nil "Easter seasonal = nil"
                          (plist-get p :seasonal-collect))
      (bcp-1928-check "Easter communion = easter"
                      'easter         (plist-get p :communion)))
    ;; Trinity Sunday
    (let ((p (bcp-1928-propers-for-date 5 31 2026 'mattins)))
      (bcp-1928-check "Trinity week = trinity-sunday"
                      'trinity-sunday (plist-get p :week))
      (bcp-1928-check "Trinity season = trinity"
                      'trinity        (plist-get p :season))
      (bcp-1928-check "Trinity collect = trinity-sunday"
                      'trinity-sunday (plist-get p :collect))
      (bcp-1928-check "Trinity communion = trinity-sunday"
                      'trinity-sunday (plist-get p :communion)))
    ;; St Luke (Tier 2 feast)
    (let ((p (bcp-1928-propers-for-date 10 18 2026 'mattins)))
      (bcp-1928-check "St Luke feast = st-luke"
                      'st-luke        (plist-get p :feast))
      (bcp-1928-check "St Luke feast-rank = 2"
                      2               (plist-get p :feast-rank))
      (bcp-1928-check "St Luke collect = st-luke"
                      'st-luke        (plist-get p :collect))
      (bcp-1928-check "St Luke communion = st-luke"
                      'st-luke        (plist-get p :communion))
      (bcp-1928-check "St Luke lessons = feast-proper"
                      'feast-proper   (plist-get (plist-get p :lessons) :source)))
    ;; All Saints (Tier 2 feast)
    (let ((p (bcp-1928-propers-for-date 11 1 2026 'mattins)))
      (bcp-1928-check "All Saints feast = all-saints"
                      'all-saints     (plist-get p :feast))
      (bcp-1928-check "All Saints collect = all-saints"
                      'all-saints     (plist-get p :collect))
      (bcp-1928-check "All Saints lessons = feast-proper"
                      'feast-proper   (plist-get (plist-get p :lessons) :source)))
    ;; Weekday in Trinity season (inherits Sunday collect)
    (let ((p (bcp-1928-propers-for-date 6 10 2026 'mattins))) ; Wed after Trinity 1
      (bcp-1928-check "Wed Trin-1 week = after-trinity-1"
                      'after-trinity-1 (plist-get p :week))
      (bcp-1928-check "Wed Trin-1 collect = after-trinity-1"
                      'after-trinity-1 (plist-get p :collect))
      (bcp-1928-check-nil "Wed Trin-1 seasonal = nil"
                          (plist-get p :seasonal-collect)))
    ;; Sunday Next Before Advent
    (let ((p (bcp-1928-propers-for-date 11 22 2026 'mattins)))
      (bcp-1928-check "Sun Bef Adv week = after-trinity-25"
                      'after-trinity-25 (plist-get p :week))
      (bcp-1928-check "Sun Bef Adv collect = after-trinity-25"
                      'after-trinity-25 (plist-get p :collect))
      (bcp-1928-check "Sun Bef Adv season = trinity"
                      'trinity          (plist-get p :season)))
    ;; Advent Sunday — collect and seasonal both advent-1
    (let ((p (bcp-1928-propers-for-date 11 29 2026 'mattins)))
      (bcp-1928-check "Advent 1 Sun collect = advent-1"
                      'advent-1         (plist-get p :collect))
      (bcp-1928-check "Advent 1 Sun seasonal = advent-1"
                      'advent-1         (plist-get p :seasonal-collect)))
    ;; Christmas Day
    (let ((p (bcp-1928-propers-for-date 12 25 2026 'mattins)))
      (bcp-1928-check "Christmas collect = christmas"
                      'christmas        (plist-get p :collect))
      (bcp-1928-check "Christmas season = christmas"
                      'christmas        (plist-get p :season))
      (bcp-1928-check-nil "Christmas seasonal = nil"
                          (plist-get p :seasonal-collect))))

  ;; ── 12. Week-key season mapping ──────────────────────────────────────────
  (bcp-1928-test-section "12. Week-key season mapping"
    (bcp-1928-check "advent-1 → advent"
                    'advent       (bcp-1928--week-key-season 'advent-1))
    (bcp-1928-check "advent-4 → advent"
                    'advent       (bcp-1928--week-key-season 'advent-4))
    (bcp-1928-check "christmas → christmas"
                    'christmas    (bcp-1928--week-key-season 'christmas))
    (bcp-1928-check "st-stephen → christmas"
                    'christmas    (bcp-1928--week-key-season 'st-stephen))
    (bcp-1928-check "epiphany → christmas"
                    'christmas    (bcp-1928--week-key-season 'epiphany))
    (bcp-1928-check "after-epiphany-3 → epiphany"
                    'epiphany     (bcp-1928--week-key-season 'after-epiphany-3))
    (bcp-1928-check "septuagesima → pre-lent"
                    'pre-lent     (bcp-1928--week-key-season 'septuagesima))
    (bcp-1928-check "ash-wednesday → lent"
                    'lent         (bcp-1928--week-key-season 'ash-wednesday))
    (bcp-1928-check "lent-4 → lent"
                    'lent         (bcp-1928--week-key-season 'lent-4))
    (bcp-1928-check "palm-sunday → passiontide"
                    'passiontide  (bcp-1928--week-key-season 'palm-sunday))
    (bcp-1928-check "good-friday → passiontide"
                    'passiontide  (bcp-1928--week-key-season 'good-friday))
    (bcp-1928-check "easter → eastertide"
                    'eastertide   (bcp-1928--week-key-season 'easter))
    (bcp-1928-check "ascension → eastertide"
                    'eastertide   (bcp-1928--week-key-season 'ascension))
    (bcp-1928-check "after-ascension → ascensiontide"
                    'ascensiontide (bcp-1928--week-key-season 'after-ascension))
    (bcp-1928-check "whitsunday → eastertide"
                    'eastertide   (bcp-1928--week-key-season 'whitsunday))
    (bcp-1928-check "trinity-sunday → trinity"
                    'trinity      (bcp-1928--week-key-season 'trinity-sunday))
    (bcp-1928-check "after-trinity-14 → trinity"
                    'trinity      (bcp-1928--week-key-season 'after-trinity-14))
    (bcp-1928-check "sunday-before-advent → trinity"
                    'trinity      (bcp-1928--week-key-season 'sunday-before-advent)))

  ;; ── 13. Seasonal invitatories ────────────────────────────────────────────
  ;; All dates use 2026 (Easter April 5):
  ;;   Advent Sunday Nov 29 2026 (for the 2026-2027 church year)
  ;;   Advent 1 (2025-2026): Nov 30 2025
  ;;   Christmas 2025: Dec 25
  ;;   Epiphany 2026: Jan 6
  ;;   Ash Wed: Feb 18 · Good Friday: Apr 3 · Easter: Apr 5
  ;;   Ascension: May 14 · Whitsunday: May 24 · Trinity: May 31
  ;;   Purification: Feb 2 · Annunciation: Mar 25
  ;;   Transfiguration: Aug 6 · St Luke: Oct 18

  (bcp-1928-test-section "13. Invitatory dispatch"
    ;; Advent Sunday
    (let ((p (bcp-1928-propers-for-date 11 30 2025 'mattins)))
      (bcp-1928-check "Advent 1 Sunday"
                      bcp-common-anglican-invitatory-advent-sundays
                      (bcp-1928--invitatory p)))
    ;; Advent weekday — no invitatory
    (let ((p (bcp-1928-propers-for-date 12 3 2025 'mattins)))
      (bcp-1928-check-nil "Advent 1 Wednesday: nil"
                          (bcp-1928--invitatory p)))
    ;; Christmas Day
    (let ((p (bcp-1928-propers-for-date 12 25 2025 'mattins)))
      (bcp-1928-check "Christmas Day"
                      bcp-common-anglican-invitatory-christmas
                      (bcp-1928--invitatory p)))
    ;; Dec 31 (still Christmas → Epiphany)
    (let ((p (bcp-1928-propers-for-date 12 31 2025 'mattins)))
      (bcp-1928-check "Dec 31 (Christmas)"
                      bcp-common-anglican-invitatory-christmas
                      (bcp-1928--invitatory p)))
    ;; Jan 5 — last day before Epiphany
    (let ((p (bcp-1928-propers-for-date 1 5 2026 'mattins)))
      (bcp-1928-check "Jan 5 (Christmas)"
                      bcp-common-anglican-invitatory-christmas
                      (bcp-1928--invitatory p)))
    ;; Epiphany (Jan 6)
    (let ((p (bcp-1928-propers-for-date 1 6 2026 'mattins)))
      (bcp-1928-check "Epiphany Jan 6"
                      bcp-common-anglican-invitatory-epiphany
                      (bcp-1928--invitatory p)))
    ;; Jan 13 — last day of Epiphany octave
    (let ((p (bcp-1928-propers-for-date 1 13 2026 'mattins)))
      (bcp-1928-check "Jan 13 (Epiphany octave)"
                      bcp-common-anglican-invitatory-epiphany
                      (bcp-1928--invitatory p)))
    ;; Jan 14 — outside octave, ordinary day
    (let ((p (bcp-1928-propers-for-date 1 14 2026 'mattins)))
      (bcp-1928-check-nil "Jan 14: nil (ordinary)"
                          (bcp-1928--invitatory p)))
    ;; Transfiguration (Aug 6)
    (let ((p (bcp-1928-propers-for-date 8 6 2026 'mattins)))
      (bcp-1928-check "Transfiguration"
                      bcp-common-anglican-invitatory-epiphany
                      (bcp-1928--invitatory p)))
    ;; Easter Monday (Apr 6)
    (let ((p (bcp-1928-propers-for-date 4 6 2026 'mattins)))
      (bcp-1928-check "Easter Monday"
                      bcp-common-anglican-invitatory-easter
                      (bcp-1928--invitatory p)))
    ;; Easter Wednesday (Apr 8 — resolved :week = easter, dow ≠ 0)
    (let ((p (bcp-1928-propers-for-date 4 8 2026 'mattins)))
      (bcp-1928-check "Easter Wednesday"
                      bcp-common-anglican-invitatory-easter
                      (bcp-1928--invitatory p)))
    ;; After Easter 3 weekday (Apr 29 = Wednesday)
    (let ((p (bcp-1928-propers-for-date 4 29 2026 'mattins)))
      (bcp-1928-check "After Easter 3 (Wed)"
                      bcp-common-anglican-invitatory-easter
                      (bcp-1928--invitatory p)))
    ;; Ascension Day (May 14)
    (let ((p (bcp-1928-propers-for-date 5 14 2026 'mattins)))
      (bcp-1928-check "Ascension Day"
                      bcp-common-anglican-invitatory-ascension
                      (bcp-1928--invitatory p)))
    ;; Friday after Ascension (May 15)
    (let ((p (bcp-1928-propers-for-date 5 15 2026 'mattins)))
      (bcp-1928-check "Fri after Ascension"
                      bcp-common-anglican-invitatory-ascension
                      (bcp-1928--invitatory p)))
    ;; Whitsunday (May 24)
    (let ((p (bcp-1928-propers-for-date 5 24 2026 'mattins)))
      (bcp-1928-check "Whitsunday"
                      bcp-common-anglican-invitatory-whitsun
                      (bcp-1928--invitatory p)))
    ;; Whit Monday (May 25)
    (let ((p (bcp-1928-propers-for-date 5 25 2026 'mattins)))
      (bcp-1928-check "Whit Monday"
                      bcp-common-anglican-invitatory-whitsun
                      (bcp-1928--invitatory p)))
    ;; Whit Saturday (May 30 — last day)
    (let ((p (bcp-1928-propers-for-date 5 30 2026 'mattins)))
      (bcp-1928-check "Whit Saturday"
                      bcp-common-anglican-invitatory-whitsun
                      (bcp-1928--invitatory p)))
    ;; Trinity Sunday (May 31)
    (let ((p (bcp-1928-propers-for-date 5 31 2026 'mattins)))
      (bcp-1928-check "Trinity Sunday"
                      bcp-common-anglican-invitatory-trinity
                      (bcp-1928--invitatory p)))
    ;; Trinity 1 weekday — no invitatory
    (let ((p (bcp-1928-propers-for-date 6 3 2026 'mattins)))
      (bcp-1928-check-nil "Trinity 1 Wednesday: nil"
                          (bcp-1928--invitatory p)))
    ;; Purification (Feb 2)
    (let ((p (bcp-1928-propers-for-date 2 2 2026 'mattins)))
      (bcp-1928-check "Purification"
                      bcp-common-anglican-invitatory-incarnation
                      (bcp-1928--invitatory p)))
    ;; Annunciation (Mar 25)
    (let ((p (bcp-1928-propers-for-date 3 25 2026 'mattins)))
      (bcp-1928-check "Annunciation"
                      bcp-common-anglican-invitatory-incarnation
                      (bcp-1928--invitatory p)))
    ;; St Luke (Oct 18) — tier 2 feast, generic saints invitatory
    (let ((p (bcp-1928-propers-for-date 10 18 2026 'mattins)))
      (bcp-1928-check "St Luke (feast)"
                      bcp-common-anglican-invitatory-saints
                      (bcp-1928--invitatory p)))
    ;; Ordinary Trinity weekday — no invitatory
    (let ((p (bcp-1928-propers-for-date 7 15 2026 'mattins)))
      (bcp-1928-check-nil "ordinary weekday: nil"
                          (bcp-1928--invitatory p))))

  ;; ── 14. Venite omission (Ash Wed / Good Friday) ─────────────────────────
  (bcp-1928-test-section "14. Venite Ash/GF omission"
    ;; Default: Venite NOT omitted
    (let ((bcp-1928-venite-omit-ash-good-friday nil)
          (step '(:canticle venite :latin "Venite, exultemus Domino.")))
      (let ((p (bcp-1928-propers-for-date 2 18 2026 'mattins)))
        (bcp-1928-check-nil "Ash Wed default: not skipped"
                            (bcp-1928--step-override step p)))
      (let ((p (bcp-1928-propers-for-date 4 3 2026 'mattins)))
        (bcp-1928-check-nil "Good Fri default: not skipped"
                            (bcp-1928--step-override step p))))
    ;; Enabled: Venite skipped on Ash Wed and Good Friday
    (let ((bcp-1928-venite-omit-ash-good-friday t)
          (step '(:canticle venite :latin "Venite, exultemus Domino.")))
      (let ((p (bcp-1928-propers-for-date 2 18 2026 'mattins)))
        (bcp-1928-check "Ash Wed omit: skip"
                        :skip
                        (bcp-1928--step-override step p)))
      (let ((p (bcp-1928-propers-for-date 4 3 2026 'mattins)))
        (bcp-1928-check "Good Fri omit: skip"
                        :skip
                        (bcp-1928--step-override step p))))
    ;; Enabled but not on Ash Wed or Good Friday — no skip
    (let ((bcp-1928-venite-omit-ash-good-friday t)
          (step '(:canticle venite :latin "Venite, exultemus Domino.")))
      (let ((p (bcp-1928-propers-for-date 4 5 2026 'mattins)))
        (bcp-1928-check-nil "Easter Day: not skipped"
                            (bcp-1928--step-override step p)))))) ; end of bcp-1928-test--run-all


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Runner and output

(defun bcp-1928-test--format-result (result)
  "Return a formatted string for a single test RESULT."
  (cl-destructuring-bind (section name pass expected actual) result
    (ignore section)
    (if pass
        (format "  ✓ %s" name)
      (format "  ✗ %s\n    expected: %S\n    actual:   %S" name expected actual))))

(defun bcp-1928-test--print-results ()
  "Print test results to the appropriate output sink."
  (let* ((results  (nreverse bcp-1928-test--results))
         (sections (delete-dups (mapcar #'car results)))
         (total    (length results))
         (passed   (cl-count-if (lambda (r) (nth 2 r)) results))
         (failed   (- total passed)))
    (dolist (sec sections)
      (let ((sec-results (cl-remove-if-not
                          (lambda (r) (string= (car r) sec)) results)))
        (let* ((s-total  (length sec-results))
               (s-passed (cl-count-if (lambda (r) (nth 2 r)) sec-results))
               (header   (format "%s  [%s %d/%d]"
                                 sec
                                 (if (= s-passed s-total) "✓" "✗")
                                 s-passed s-total)))
          (if noninteractive
              (progn
                (message "%s" header)
                (dolist (r sec-results)
                  (unless (nth 2 r)
                    (message "%s" (bcp-1928-test--format-result r)))))
            (insert header "\n")
            (dolist (r sec-results)
              (insert (bcp-1928-test--format-result r) "\n"))))))
    (let ((sep (make-string 60 ?─)))
      (if noninteractive
          (progn
            (message "%s" sep)
            (message "Total: %d passed, %d failed" passed failed))
        (insert sep "\n")
        (insert (format "Total: %d passed, %d failed\n" passed failed))))))

;;;###autoload
(defun bcp-1928-run-tests ()
  "Run all BCP 1928 shakedown tests and display results."
  (interactive)
  (bcp-1928-test--run-all)
  (if noninteractive
      (bcp-1928-test--print-results)
    (with-current-buffer (get-buffer-create "*BCP 1928 Tests*")
      (read-only-mode -1)
      (erase-buffer)
      (bcp-1928-test--print-results)
      (read-only-mode 1)
      (goto-char (point-min))
      (pop-to-buffer (current-buffer)))))

(provide 'bcp-1928-test)
;;; bcp-1928-test.el ends here
