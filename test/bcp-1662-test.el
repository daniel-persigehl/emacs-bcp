;;; bcp-1662-test.el --- Automated shakedown tests for bcp-1662 -*- lexical-binding: t -*-

;;; Commentary:

;; Run with:
;;   M-x bcp-1662-run-tests
;;
;; Or from the command line:
;;   emacs --batch -l path/to/bible-commentary.el \
;;                 -l path/to/bcp-1662-calendar.el \
;;                 -l path/to/bcp-1662-data.el \
;;                 -l path/to/bcp-1662-user-feasts.el \
;;                 -l path/to/bcp-1662.el \
;;                 -l path/to/bcp-1662-test.el \
;;                 -f bcp-1662-run-tests
;;
;; Results are written to *BCP 1662 Tests* buffer (interactive)
;; or to stdout (batch mode).

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Test framework

(defvar bcp-1662-test--results nil
  "List of (SECTION NAME PASS EXPECTED ACTUAL) test results.")

(defvar bcp-1662-test--section nil
  "Current test section name.")

(defmacro bcp-1662-test-section (name &rest body)
  "Run BODY as a named test section."
  (declare (indent 1))
  `(progn
     (setq bcp-1662-test--section ,name)
     ,@body))

(defmacro bcp-1662-check (name expected form)
  "Assert that FORM equals EXPECTED, recording result under NAME."
  `(let* ((actual   (condition-case err
                        ,form
                      (error (format "ERROR: %s" err))))
          (pass     (equal actual ,expected)))
     (push (list bcp-1662-test--section ,name pass ,expected actual)
           bcp-1662-test--results)))

(defmacro bcp-1662-check-t (name form)
  "Assert that FORM is non-nil."
  `(bcp-1662-check ,name t (and ,form t)))

(defmacro bcp-1662-check-nil (name form)
  "Assert that FORM is nil."
  `(bcp-1662-check ,name nil ,form))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Test definitions

(defun bcp-1662-test--run-all ()
  "Run all automated tests, populating `bcp-1662-test--results'."
  (setq bcp-1662-test--results nil)

  ;; ── 1. Load check ──────────────────────────────────────────────────────
  (bcp-1662-test-section "1. Load check"
    (bcp-1662-check-t "bcp-reader loaded"  (featurep 'bcp-reader))
    (bcp-1662-check-t "bcp-1662-calendar loaded" (featurep 'bcp-1662-calendar))
    (bcp-1662-check-t "bcp-1662-data loaded"     (featurep 'bcp-1662-data))
    (bcp-1662-check-t "bcp-1662-user-feasts loaded" (featurep 'bcp-1662-user-feasts))
    (bcp-1662-check-t "bcp-1662 loaded"          (featurep 'bcp-1662)))

  ;; ── 2. Easter ──────────────────────────────────────────────────────────
  (bcp-1662-test-section "2. Easter calculation"
    (bcp-1662-check "Easter 2026"   '(4  5 2026) (bcp-1662-easter 2026))
    (bcp-1662-check "Easter 2027"   '(3 28 2027) (bcp-1662-easter 2027))
    (bcp-1662-check "Easter 2028"   '(4 16 2028) (bcp-1662-easter 2028))
    (bcp-1662-check "Easter 2019"   '(4 21 2019) (bcp-1662-easter 2019))
    (bcp-1662-check "Easter 1818 (earliest: Mar 22)" '(3 22 1818) (bcp-1662-easter 1818))
    (bcp-1662-check "Easter 1943 (latest: Apr 25)"   '(4 25 1943) (bcp-1662-easter 1943))
    (bcp-1662-check "Easter 2038 (latest: Apr 25)"   '(4 25 2038) (bcp-1662-easter 2038)))

  ;; ── 3. Advent Sunday ───────────────────────────────────────────────────
  (bcp-1662-test-section "3. Advent Sunday"
    (bcp-1662-check "Advent 2026 = Nov 29" '(11 29 2026) (bcp-1662-advent-1 2026))
    (bcp-1662-check "Advent 2025 = Nov 30 (Nov 30 is Sunday)" '(11 30 2025) (bcp-1662-advent-1 2025))
    (bcp-1662-check "Advent 2024 = Dec 1"  '(12  1 2024) (bcp-1662-advent-1 2024)))

  ;; ── 4. Dominical letter ────────────────────────────────────────────────
  (bcp-1662-test-section "4. Dominical letter"
    (bcp-1662-check "2026 = D"   "D"  (bcp-1662-dominical-letter 2026))
    (bcp-1662-check "2024 = GF (leap)" "GF" (bcp-1662-dominical-letter 2024))
    (bcp-1662-check "2000 = BA (leap)" "BA" (bcp-1662-dominical-letter 2000))
    (bcp-1662-check "2025 = E"   "E"  (bcp-1662-dominical-letter 2025)))

  ;; ── 5. Liturgical seasons ──────────────────────────────────────────────
  (bcp-1662-test-section "5. Liturgical seasons 2026"
    (bcp-1662-check "Jan 6 = epiphany"       'epiphany    (bcp-1662-liturgical-season  1  6 2026))
    (bcp-1662-check "Jan 5 = christmas"      'christmas   (bcp-1662-liturgical-season  1  5 2026))
    (bcp-1662-check "Feb 17 = pre-lent"      'pre-lent    (bcp-1662-liturgical-season  2 17 2026))
    (bcp-1662-check "Feb 18 = lent (Ash Wed)"'lent        (bcp-1662-liturgical-season  2 18 2026))
    (bcp-1662-check "Mar 21 = lent"          'lent        (bcp-1662-liturgical-season  3 21 2026))
    (bcp-1662-check "Mar 22 = passiontide (Passion Sun)" 'passiontide (bcp-1662-liturgical-season 3 22 2026))
    (bcp-1662-check "Apr  4 = passiontide (Easter Even)" 'passiontide (bcp-1662-liturgical-season 4  4 2026))
    (bcp-1662-check "Apr  5 = eastertide (Easter Day)"   'eastertide  (bcp-1662-liturgical-season 4  5 2026))
    (bcp-1662-check "May 24 = eastertide (Whitsunday)"   'eastertide  (bcp-1662-liturgical-season 5 24 2026))
    (bcp-1662-check "May 31 = trinity (Trinity Sunday)"  'trinity     (bcp-1662-liturgical-season 5 31 2026))
    (bcp-1662-check "Jun  1 = trinity"       'trinity     (bcp-1662-liturgical-season  6  1 2026))
    (bcp-1662-check "Nov 28 = trinity"       'trinity     (bcp-1662-liturgical-season 11 28 2026))
    (bcp-1662-check "Nov 29 = advent (Advent Sun)" 'advent (bcp-1662-liturgical-season 11 29 2026))
    (bcp-1662-check "Dec 25 = christmas"     'christmas   (bcp-1662-liturgical-season 12 25 2026)))

  ;; ── 6. Liturgical week ─────────────────────────────────────────────────
  (bcp-1662-test-section "6. Liturgical week 2026"
    (bcp-1662-check "Trinity Sunday = (trinity . 0)"  '(trinity . 0)  (bcp-1662-liturgical-week  5 31 2026))
    (bcp-1662-check "Trinity 1 = (trinity . 1)"       '(trinity . 1)  (bcp-1662-liturgical-week  6  7 2026))
    (bcp-1662-check "Trinity 13 = (trinity . 13)"     '(trinity . 13) (bcp-1662-liturgical-week  8 30 2026))
    (bcp-1662-check "Trinity 14 = (trinity . 14)"     '(trinity . 14) (bcp-1662-liturgical-week  9  6 2026))
    (bcp-1662-check "Advent 1 = (advent . 1)"         '(advent . 1)   (bcp-1662-liturgical-week 11 29 2026))
    (bcp-1662-check "Advent 2 = (advent . 2)"         '(advent . 2)   (bcp-1662-liturgical-week 12  6 2026))
    (bcp-1662-check "Lent 1 (Sun after Ash Wed) = (lent . 1)" '(lent . 1) (bcp-1662-liturgical-week 2 22 2026))
    (bcp-1662-check "Lent mid-week still = (lent . 1)" '(lent . 1)   (bcp-1662-liturgical-week  2 25 2026))
    ;; Epiphany overflow years
    ;; 2025: total=23, overflow=2 — Nov 16 = epiphany-5, Nov 23 = epiphany-6, Nov 23 = Sun Bef Advent (= trinity-25)
    ;; Wait: overflow_start=21, raw 21=epiphany-5, raw 22=epiphany-6, raw 23=trinity-25
    ;; Trinity Jun 15; raw 21 = Jun 15 + 21*7 = Nov 9; raw 22 = Nov 16; raw 23 = Nov 23
    (bcp-1662-check "2025 overflow: Nov 9 = epiphany-5"  '(epiphany . 5) (bcp-1662-liturgical-week 11  9 2025))
    (bcp-1662-check "2025 overflow: Nov 16 = epiphany-6" '(epiphany . 6) (bcp-1662-liturgical-week 11 16 2025))
    (bcp-1662-check "2025 Sun Bef Advent = trinity-25 (Nov 23)" '(trinity . 25) (bcp-1662-liturgical-week 11 23 2025))
    ;; 2028: total=24, overflow=1 — overflow_start=23, raw 23=epiphany-5, raw 24=trinity-25
    ;; Trinity Jun 11; raw 23 = Jun 11 + 23*7 = Nov 19; raw 24 = Nov 26
    (bcp-1662-check "2028 overflow: Nov 19 = epiphany-5" '(epiphany . 5) (bcp-1662-liturgical-week 11 19 2028))
    (bcp-1662-check "2028 Sun Bef Advent = trinity-25 (Nov 26)" '(trinity . 25) (bcp-1662-liturgical-week 11 26 2028))
    ;; 2026: no overflow — all normal
    (bcp-1662-check "2026 no overflow: Nov 15 = trinity-24" '(trinity . 24) (bcp-1662-liturgical-week 11 15 2026))
    (bcp-1662-check "2026 Sun Bef Advent = trinity-25"      '(trinity . 25) (bcp-1662-liturgical-week 11 22 2026))
    ;; 2024: surplus=1 — Nov 17 is omitted (trinity nil), Nov 24 = Sun Bef Advent
    (bcp-1662-check "2024 surplus: Nov 17 = omitted (nil)"  '(trinity . nil) (bcp-1662-liturgical-week 11 17 2024))
    (bcp-1662-check "2024 Sun Bef Advent = trinity-25 (Nov 24)" '(trinity . 25) (bcp-1662-liturgical-week 11 24 2024))
    ;; Epiphany 6 data coverage — verify entries exist
    (bcp-1662-check-t "epiphany-6 has collect"              (bcp-1662-collect-text 'epiphany-6))
    (bcp-1662-check-t "epiphany-6 has communion propers"    (bcp-1662-communion-propers 'epiphany-6))
    (bcp-1662-check "epiphany-5 OT = Dan 12:1-4"     '("Dan" 12 1 4)   (bcp-1662-ot-reading 'epiphany-5))
    (bcp-1662-check "epiphany-6 OT = Isa 63:15-19"   '("Isa" 63 15 19) (bcp-1662-ot-reading 'epiphany-6))
    (bcp-1662-check-t "after-epiphany-6 in Sunday propers"  (assq 'after-epiphany-6 bcp-1662-propers-sunday)))

  ;; ── 7. Moveable feasts ─────────────────────────────────────────────────
  (bcp-1662-test-section "7. Moveable feasts 2026"
    (let ((f (bcp-1662-moveable-feasts 2026)))
      (bcp-1662-check "Ash Wednesday"   '(2 18 2026) (cdr (assq 'ash-wednesday  f)))
      (bcp-1662-check "Passion Sunday"  '(3 22 2026) (cdr (assq 'passion-sunday f)))
      (bcp-1662-check "Palm Sunday"     '(3 29 2026) (cdr (assq 'palm-sunday    f)))
      (bcp-1662-check "Easter"          '(4  5 2026) (cdr (assq 'easter         f)))
      (bcp-1662-check "Ascension"       '(5 14 2026) (cdr (assq 'ascension      f)))
      (bcp-1662-check "Whitsunday"      '(5 24 2026) (cdr (assq 'whitsunday     f)))
      (bcp-1662-check "Trinity Sunday"  '(5 31 2026) (cdr (assq 'trinity-sunday f)))))

  ;; ── 8. Feast lookup ────────────────────────────────────────────────────
  (bcp-1662-test-section "8. Feast lookup"
    (bcp-1662-check "St Luke symbol"       'luke        (bcp-1662-feast-symbol "St. Luke, Evang."))
    (bcp-1662-check "Christmas symbol"     'christmas   (bcp-1662-feast-symbol "Christmas-Day"))
    (bcp-1662-check "Michael symbol"       'michael     (bcp-1662-feast-symbol "St. Michael and all Angels"))
    (bcp-1662-check-nil "Fast. = nil"                   (bcp-1662-feast-symbol "Fast."))
    (bcp-1662-check "Luke rank = greater"  'greater     (plist-get (bcp-1662-feast-data 'luke)      :rank))
    (bcp-1662-check "Christmas rank = principal" 'principal (plist-get (bcp-1662-feast-data 'christmas) :rank))
    (bcp-1662-check "Benedict rank = lesser" 'lesser    (plist-get (bcp-1662-feast-data 'benedict)  :rank))
    (bcp-1662-check "Luke date = Oct 18"   '(10 18)     (plist-get (bcp-1662-feast-data 'luke)      :date))
    (bcp-1662-check "Feast on Oct 18 = luke"     '(luke)
                    (mapcar #'car (bcp-1662-feasts-for-date 10 18)))
    (bcp-1662-check "Feast on Dec 25 = christmas" '(christmas)
                    (mapcar #'car (bcp-1662-feasts-for-date 12 25)))
    (bcp-1662-check "Symbol for Oct 18"    'luke        (bcp-1662--feast-symbol-for-date 10 18))
    (bcp-1662-check "Symbol for Jan 1"     'circumcision (bcp-1662--feast-symbol-for-date  1  1))
    (bcp-1662-check-nil "No feast Jun 3"               (bcp-1662--feast-symbol-for-date  6  3)))

  ;; ── 9. Vigils ──────────────────────────────────────────────────────────
  (bcp-1662-test-section "9. Vigils"
    (bcp-1662-check-t   "Christmas has vigil"          (bcp-1662-feast-has-vigil-p 'christmas))
    (bcp-1662-check-t   "Peter has vigil"              (bcp-1662-feast-has-vigil-p 'peter))
    (bcp-1662-check-t   "All Saints has vigil"         (bcp-1662-feast-has-vigil-p 'all-saints))
    (bcp-1662-check-nil "Luke has no vigil"            (bcp-1662-feast-has-vigil-p 'luke))
    (bcp-1662-check-nil "Michael has no vigil"         (bcp-1662-feast-has-vigil-p 'michael))
    (bcp-1662-check "Dec 24 = vigil of christmas" 'christmas   (bcp-1662-vigil-p 12 24))
    (bcp-1662-check "Jun 28 = vigil of peter"     'peter       (bcp-1662-vigil-p  6 28))
    (bcp-1662-check "Oct 31 = vigil of all-saints" 'all-saints (bcp-1662-vigil-p 10 31))
    (bcp-1662-check "Jun 23 = vigil of john-baptist" 'john-baptist (bcp-1662-vigil-p 6 23))
    (bcp-1662-check-nil "Mar 21 has no vigil"          (bcp-1662-vigil-p  3 21)))

  ;; ── 10. Collects ───────────────────────────────────────────────────────
  (bcp-1662-test-section "10. Collects"
    (bcp-1662-check-t   "Trinity 1 has collect"        (bcp-1662-collect-text 'trinity-1))
    (bcp-1662-check-t   "Ash Wednesday has collect"    (bcp-1662-collect-text 'ash-wednesday))
    (bcp-1662-check-t   "Christmas has collect"        (bcp-1662-collect-text 'christmas))
    (bcp-1662-check-t   "Luke has collect"             (bcp-1662-collect-text 'luke))
    (bcp-1662-check-t   "Good Friday 1 has collect"    (bcp-1662-collect-text 'good-friday))
    (bcp-1662-check-t   "Good Friday 2 has collect"    (bcp-1662-collect-text 'good-friday-2))
    (bcp-1662-check-t   "Good Friday 3 has collect"    (bcp-1662-collect-text 'good-friday-3))
    (bcp-1662-check-t   "trinity-25 alias works"       (bcp-1662-collect 'trinity-25))
    (bcp-1662-check     "trinity-25 = sunday-before-advent" t
                        (equal (bcp-1662-collect 'trinity-25)
                               (bcp-1662-collect 'sunday-before-advent)))
    (bcp-1662-check     "Stir Up Sunday starts STIR"   "STIR"
                        (substring (bcp-1662-collect-text 'sunday-before-advent) 0 4))
    (bcp-1662-check-t   "Ash Wed has rubric"           (plist-get (bcp-1662-collect 'ash-wednesday) :rubric))
    (bcp-1662-check-t   "Advent 1 has rubric"          (plist-get (bcp-1662-collect 'advent-1) :rubric))
    (bcp-1662-check-nil "Trinity 1 has no rubric"      (plist-get (bcp-1662-collect 'trinity-1) :rubric))
    (bcp-1662-check-nil "Nonexistent collect = nil"    (bcp-1662-collect-text 'nonexistent-feast)))

  ;; ── 11. Seasonal collects ──────────────────────────────────────────────
  (bcp-1662-test-section "11. Seasonal collects"
    (bcp-1662-check "Advent Sunday = advent-1"         'advent-1      (bcp-1662-seasonal-collect 11 29 2026))
    (bcp-1662-check "Christmas Eve = advent-1"         'advent-1      (bcp-1662-seasonal-collect 12 24 2026))
    (bcp-1662-check-nil "Christmas Day = nil"                         (bcp-1662-seasonal-collect 12 25 2026))
    (bcp-1662-check "Ash Wednesday = ash-wednesday"    'ash-wednesday (bcp-1662-seasonal-collect  2 18 2026))
    (bcp-1662-check "Passion Sunday = ash-wednesday"   'ash-wednesday (bcp-1662-seasonal-collect  3 22 2026))
    (bcp-1662-check "Easter Even = ash-wednesday"      'ash-wednesday (bcp-1662-seasonal-collect  4  4 2026))
    (bcp-1662-check-nil "Easter Day = nil"                            (bcp-1662-seasonal-collect  4  5 2026))
    (bcp-1662-check-nil "Trinity 1 = nil"                             (bcp-1662-seasonal-collect  6  7 2026))
    (bcp-1662-check-nil "Epiphany = nil"                              (bcp-1662-seasonal-collect  1 25 2026)))

  ;; ── 12. Office lessons ─────────────────────────────────────────────────
  (bcp-1662-test-section "12. Office lessons"
    (bcp-1662-check "Weekday source = calendar"        'calendar
                    (plist-get (bcp-1662-office-lessons  3 21 2026 'mattins) :source))
    (bcp-1662-check "Lesser feast source = calendar"   'calendar
                    (plist-get (bcp-1662-office-lessons  3 21 2026 'mattins) :source))
    (bcp-1662-check "Greater feast source = feast-proper" 'feast-proper
                    (plist-get (bcp-1662-office-lessons 10 18 2026 'mattins) :source))
    (bcp-1662-check "Principal feast source = feast-proper" 'feast-proper
                    (plist-get (bcp-1662-office-lessons 12 25 2026 'mattins) :source))
    (bcp-1662-check "Sunday source = sunday-proper (Trinity 1)"  'sunday-proper
                    (plist-get (bcp-1662-office-lessons  6  7 2026 'mattins) :source))
    (bcp-1662-check-t "Lessons have lesson1"
                    (plist-get (bcp-1662-office-lessons  3 21 2026 'mattins) :lesson1))
    (bcp-1662-check-t "Evening lessons differ from morning"
                    (not (equal (bcp-1662-office-lessons 3 21 2026 'mattins)
                                (bcp-1662-office-lessons 3 21 2026 'evensong)))))

  ;; ── 13. Communion propers ──────────────────────────────────────────────
  (bcp-1662-test-section "13. Communion propers"
    (bcp-1662-check "Advent 1 communion"               'advent-1       (bcp-1662-communion-proper-for-date 11 29 2026))
    (bcp-1662-check "Trinity Sunday communion"         'trinity-sunday (bcp-1662-communion-proper-for-date  5 31 2026))
    (bcp-1662-check "Trinity 1 communion"              'trinity-1      (bcp-1662-communion-proper-for-date  6  7 2026))
    (bcp-1662-check "Easter communion"                 'easter         (bcp-1662-communion-proper-for-date  4  5 2026))
    (bcp-1662-check "Ash Wednesday communion"          'ash-wednesday  (bcp-1662-communion-proper-for-date  2 18 2026))
    (bcp-1662-check "Good Friday communion"            'good-friday    (bcp-1662-communion-proper-for-date  4  3 2026))
    (bcp-1662-check "Ascension communion"              'ascension      (bcp-1662-communion-proper-for-date  5 14 2026))
    (bcp-1662-check "St Luke communion"                'luke           (bcp-1662-communion-proper-for-date 10 18 2026))
    (bcp-1662-check "St Peter communion"               'peter          (bcp-1662-communion-proper-for-date  6 29 2026))
    (bcp-1662-check "St Andrew communion"              'andrew         (bcp-1662-communion-proper-for-date 11 30 2026))
    (bcp-1662-check "Weekday no communion"              nil            (bcp-1662-communion-proper-for-date  6 10 2026))
    (bcp-1662-check-t "trinity-25 alias"               (bcp-1662-communion-propers 'trinity-25))
    (bcp-1662-check "trinity-25 = sunday-before-advent" t
                    (equal (bcp-1662-communion-propers 'trinity-25)
                           (bcp-1662-communion-propers 'sunday-before-advent)))
    (bcp-1662-check "OT for Advent 1"                  '("Isa" 62 10 12) (bcp-1662-ot-reading 'advent-1))
    (bcp-1662-check "OT for Easter"                    '("Isa" 25 6 9)   (bcp-1662-ot-reading 'easter))
    (bcp-1662-check "OT for trinity-25 (alias)"        '("Dan" 12 1 4)   (bcp-1662-ot-reading 'trinity-25))
    (bcp-1662-check-nil "OT for nonexistent"                              (bcp-1662-ot-reading 'nonexistent)))

  ;; ── 14. Full dispatch ──────────────────────────────────────────────────
  (bcp-1662-test-section "14. Full dispatch"
    ;; Lent weekday (Mar 21 2026 — Benedict, lesser)
    (let ((p (bcp-1662-propers-for-date 3 21 2026 'mattins)))
      (bcp-1662-check "Mar 21 season = lent"          'lent        (plist-get p :season))
      (bcp-1662-check "Mar 21 feast = benedict"       'benedict    (plist-get p :feast))
      (bcp-1662-check "Mar 21 rank = lesser"          'lesser      (plist-get p :feast-rank))
      (bcp-1662-check "Mar 21 seasonal = ash-wednesday" 'ash-wednesday (plist-get p :seasonal-collect))
      (bcp-1662-check-nil "Mar 21 no communion (weekday)"           (plist-get p :communion)))
    ;; Easter Day
    (let ((p (bcp-1662-propers-for-date 4 5 2026 'mattins)))
      (bcp-1662-check "Easter season = eastertide"    'eastertide  (plist-get p :season))
      (bcp-1662-check "Easter collect = easter"       'easter      (plist-get p :collect))
      (bcp-1662-check-nil "Easter seasonal = nil"                  (plist-get p :seasonal-collect))
      (bcp-1662-check "Easter communion = easter"     'easter      (plist-get p :communion)))
    ;; Trinity Sunday
    (let ((p (bcp-1662-propers-for-date 5 31 2026 'mattins)))
      (bcp-1662-check "Trinity Sun season = trinity"  'trinity     (plist-get p :season))
      (bcp-1662-check "Trinity Sun collect"           'trinity-sunday (plist-get p :collect))
      (bcp-1662-check "Trinity Sun communion"         'trinity-sunday (plist-get p :communion)))
    ;; St Luke (greater feast)
    (let ((p (bcp-1662-propers-for-date 10 18 2026 'mattins)))
      (bcp-1662-check "Luke feast"                    'luke        (plist-get p :feast))
      (bcp-1662-check "Luke rank = greater"           'greater     (plist-get p :feast-rank))
      (bcp-1662-check "Luke collect"                  'luke        (plist-get p :collect))
      (bcp-1662-check "Luke communion"                'luke        (plist-get p :communion))
      (bcp-1662-check "Luke lessons = feast-proper"   'feast-proper
                      (plist-get (plist-get p :lessons) :source)))
    ;; Christmas Day (principal)
    (let ((p (bcp-1662-propers-for-date 12 25 2026 'mattins)))
      (bcp-1662-check "Christmas rank = principal"    'principal   (plist-get p :feast-rank))
      (bcp-1662-check "Christmas collect"             'christmas   (plist-get p :collect))
      (bcp-1662-check "Christmas communion"           'christmas   (plist-get p :communion)))
    ;; Weekday in Trinity — collect inherited from preceding Sunday
    (let ((p (bcp-1662-propers-for-date 6 10 2026 'mattins))) ; Wed after Trinity 1
      (bcp-1662-check "Wed after Trinity 1 collect"   'trinity-1   (plist-get p :collect))
      (bcp-1662-check-nil "Wed seasonal = nil"                     (plist-get p :seasonal-collect)))
    ;; Sunday Before Advent
    (let ((p (bcp-1662-propers-for-date 11 22 2026 'mattins)))
      (bcp-1662-check "Sun Before Advent collect"     'sunday-before-advent (plist-get p :collect))
      (bcp-1662-check "Sun Before Advent communion"   'sunday-before-advent (plist-get p :communion)))
    ;; Advent Sunday — collect and seasonal collect both advent-1
    (let ((p (bcp-1662-propers-for-date 11 29 2026 'mattins)))
      (bcp-1662-check "Advent Sun collect = advent-1" 'advent-1    (plist-get p :collect))
      (bcp-1662-check "Advent Sun seasonal = advent-1" 'advent-1   (plist-get p :seasonal-collect))))

  ;; ── 15. User feasts ────────────────────────────────────────────────────
  (bcp-1662-test-section "15. User feasts"
    (bcp-1662-check-t   "Luke is user feast"           (bcp-1662-user-feast-p 'luke))
    (bcp-1662-check-t   "conversion-st-paul is user feast" (bcp-1662-user-feast-p 'conversion-st-paul))
    (bcp-1662-check-t   "augustine-hippo is user feast" (bcp-1662-user-feast-p 'augustine-hippo))
    (bcp-1662-check-t   "chair-of-st-peter is user feast" (bcp-1662-user-feast-p 'chair-of-st-peter))
    (bcp-1662-check-t   "st-william-of-york is user feast" (bcp-1662-user-feast-p 'st-william-of-york))
    (bcp-1662-check-nil "Benedict is not user feast"   (bcp-1662-user-feast-p 'benedict))
    (bcp-1662-check "Luke occasion = parish"            'parish          (bcp-1662-user-feast-occasion 'luke))
    (bcp-1662-check "Paul occasion = secondary-parish"  'secondary-parish (bcp-1662-user-feast-occasion 'conversion-st-paul))
    (bcp-1662-check "Augustine occasion = personal"     'personal        (bcp-1662-user-feast-occasion 'augustine-hippo))
    (bcp-1662-check "Chair-Peter occasion = diocese"    'diocese         (bcp-1662-user-feast-occasion 'chair-of-st-peter))
    (bcp-1662-check "William occasion = employer"       'employer        (bcp-1662-user-feast-occasion 'st-william-of-york))
    (bcp-1662-check "Augustine elevated to greater"     'greater
                    (bcp-1662-effective-feast-rank 'augustine-hippo 'lesser))
    (bcp-1662-check "Luke stays greater"                'greater
                    (bcp-1662-effective-feast-rank 'luke 'greater))
    ;; Transfer dates
    (bcp-1662-check "Chair-Peter 2026 no transfer"      '(2 22 2026)
                    (bcp-1662-user-feast-observed-date 'chair-of-st-peter 2026))
    (bcp-1662-check "Chair-Peter 2034 → Fri after Ash Wed" '(2 24 2034)
                    (bcp-1662-user-feast-observed-date 'chair-of-st-peter 2034))
    (bcp-1662-check "William 2026 no transfer"          '(6 8 2026)
                    (bcp-1662-user-feast-observed-date 'st-william-of-york 2026))
    (bcp-1662-check "William 2028 → Tue after Trinity"  '(6 13 2028)
                    (bcp-1662-user-feast-observed-date 'st-william-of-york 2028))

    ;; User feast dispatch integration
    ;; Augustine (personal, lesser elevated to greater) on Aug 28
    (let ((p (bcp-1662-propers-for-date 8 28 2026 'mattins)))
      (bcp-1662-check "Augustine feast symbol"       'augustine-hippo  (plist-get p :feast))
      (bcp-1662-check "Augustine rank = greater"     'greater          (plist-get p :feast-rank))
      (bcp-1662-check "Augustine lessons = feast-proper" 'feast-proper
                      (plist-get (plist-get p :lessons) :source)))
    ;; Chair of St Peter (diocese) on Feb 22 — no conflict in 2026
    (let ((p (bcp-1662-propers-for-date 2 22 2026 'mattins)))
      (bcp-1662-check "Chair-Peter feast symbol"     'chair-of-st-peter (plist-get p :feast))
      (bcp-1662-check "Chair-Peter rank = greater"   'greater           (plist-get p :feast-rank)))
    ;; Luke (parish) on Oct 18 — already a greater BCP feast, patronal keeps it
    (let ((p (bcp-1662-propers-for-date 10 18 2026 'mattins)))
      (bcp-1662-check "Luke feast symbol"            'luke              (plist-get p :feast))
      (bcp-1662-check "Luke rank = greater"          'greater           (plist-get p :feast-rank)))
    ;; Best feast: user custom feast wins over BCP lesser on same day
    ;; Chair of St Peter (greater, user) vs any BCP lesser on Feb 22
    (bcp-1662-check "best-feast Feb 22 = chair-of-st-peter" 'chair-of-st-peter
                    (bcp-1662--best-feast-for-date 2 22 2026)))

  ;; ── 16. Ref conversion ─────────────────────────────────────────────────
  (bcp-1662-test-section "16. Ref conversion"
    (bcp-1662-check "Deut chapter:verse"    "Deuteronomy 11:1-18"
                    (bcp-1662--lectionary-ref-to-string '("Deut" 11 1 18)))
    (bcp-1662-check "Matt whole chapter"    "Matthew 5"
                    (bcp-1662--lectionary-ref-to-string '("Matt" 5)))
    (bcp-1662-check "1 Cor whole chapter"   "1 Corinthians 13"
                    (bcp-1662--lectionary-ref-to-string '("1 Cor" 13)))
    (bcp-1662-check "Isa verse to end"      "Isaiah 40:1"
                    (bcp-1662--lectionary-ref-to-string '("Isa" 40 1 nil)))
    (bcp-1662-check "Ecclus = Sirach"       "Sirach 44:1-15"
                    (bcp-1662--lectionary-ref-to-string '("Ecclus" 44 1 15)))
    (bcp-1662-check "Joined lesson Isa 52-53" "Isaiah 52:13-53:200"
                    (bcp-1662--lectionary-ref-to-string '(("Isa" 52 13 nil) ("Isa" 53))))
    (bcp-1662-check "Label uses abbrev"     "Deut 11:1-18"
                    (bcp-1662--ref-label '("Deut" 11 1 18))))

  ;; ── 17. Psalm passages ─────────────────────────────────────────────────
  (bcp-1662-test-section "17. Psalm passages"
    (bcp-1662-check "Day 21 morning = (105)"         '(105)
                    (bible-commentary-bcp-psalms-for-day 21 :morning))
    (bcp-1662-check "Day 21 evening = (106)"         '(106)
                    (bible-commentary-bcp-psalms-for-day 21 :evening))
    (bcp-1662-check "Ps 105 passage string"          "Psalms 105"
                    (bcp-1662--psalm-to-passage 105))
    (bcp-1662-check "Ps 119 section label"           "Ps 119:1-32"
                    (bcp-1662--psalm-label '(119 . (1 32))))
    (bcp-1662-check "Ps 119 section passage string"  "Psalms 119:1-32"
                    (bcp-1662--psalm-to-passage '(119 . (1 32)))))

  ;; ── 18. Canticles ──────────────────────────────────────────────────────
  (bcp-1662-test-section "18. Canticles"
    ;; Basic retrieval
    (bcp-1662-check-t   "Te Deum has English text"        (bcp-liturgy-canticle-get 'te-deum 'english))
    (bcp-1662-check-t   "Venite has English text"          (bcp-liturgy-canticle-get 'venite 'english))
    (bcp-1662-check-t   "Magnificat has English text"      (bcp-liturgy-canticle-get 'magnificat 'english))
    (bcp-1662-check-t   "Benedictus has English text"      (bcp-liturgy-canticle-get 'benedictus 'english))
    (bcp-1662-check-t   "Nunc Dimittis has English text"   (bcp-liturgy-canticle-get 'nunc-dimittis 'english))
    (bcp-1662-check-t   "Cantate Domino has English text"  (bcp-liturgy-canticle-get 'cantate-domino 'english))
    (bcp-1662-check-t   "Benedicite has English text"      (bcp-liturgy-canticle-get 'benedicite 'english))
    (bcp-1662-check-t   "Jubilate Deo has English text"    (bcp-liturgy-canticle-get 'jubilate-deo 'english))
    (bcp-1662-check-t   "Deus Misereatur has English text" (bcp-liturgy-canticle-get 'deus-misereatur 'english))
    (bcp-1662-check-t   "Gloria Patri has English text"    (bcp-liturgy-canticle-get 'gloria-patri 'english))
    ;; Latin falls back to English when nil
    (bcp-1662-check-t   "Te Deum Latin falls back to English" (bcp-liturgy-canticle-get 'te-deum 'latin))
    (bcp-1662-check-t   "Magnificat Latin falls back to English" (bcp-liturgy-canticle-get 'magnificat 'latin))
    ;; Gloria flags
    (bcp-1662-check-t   "Venite has Gloria flag"           (bcp-liturgy-canticle-gloria-p 'venite))
    (bcp-1662-check-t   "Magnificat has Gloria flag"       (bcp-liturgy-canticle-gloria-p 'magnificat))
    (bcp-1662-check-nil "Te Deum has no Gloria flag"       (bcp-liturgy-canticle-gloria-p 'te-deum))
    (bcp-1662-check-nil "Gloria Patri has no Gloria flag"  (bcp-liturgy-canticle-gloria-p 'gloria-patri))
    ;; Titles
    (bcp-1662-check "Te Deum title"     "Te Deum Laudamus"  (bcp-liturgy-canticle-title 'te-deum))
    (bcp-1662-check "Magnificat title"  "Magnificat"        (bcp-liturgy-canticle-title 'magnificat))
    (bcp-1662-check "Nunc Dimittis title" "Nunc Dimittis"   (bcp-liturgy-canticle-title 'nunc-dimittis))
    ;; Language override
    (let ((bcp-liturgy-canticle-overrides '((te-deum . latin))))
      (bcp-1662-check "Override: te-deum effective lang = latin" 'latin
                      (bcp-liturgy-canticle-effective-language 'te-deum))
      (bcp-1662-check "Override: venite effective lang = english" 'english
                      (bcp-liturgy-canticle-effective-language 'venite)))
    ;; Venite verse stripping
    (bcp-1662-check-t   "Venite full text contains verse 8"
                        (string-match-p "To day if ye will hear"
                                        (bcp-liturgy-canticle-get 'venite)))
    (bcp-1662-check-nil "Venite stripped text omits verse 8"
                        (string-match-p "To day if ye will hear"
                                        (bcp-1662--venite-strip-verses-8-11
                                         (bcp-liturgy-canticle-get 'venite))))
    (bcp-1662-check-t   "Venite stripped text retains verse 12"
                        (string-match-p "Unto whom I sware"
                                        (bcp-1662--venite-strip-verses-8-11
                                         (bcp-liturgy-canticle-get 'venite)))))

  ;; ── 19. Rubrical options ───────────────────────────────────────────────
  (bcp-1662-test-section "19. Rubrical options"
    ;; Seasonal sentence alists — 1928 extended corpus
    (bcp-1662-check-t "Advent has a morning seasonal sentence"
                      (assq 'advent bcp-1662-seasonal-sentences))
    (bcp-1662-check-t "Eastertide has a morning seasonal sentence"
                      (assq 'eastertide bcp-1662-seasonal-sentences))
    (bcp-1662-check-t "Advent has an evening seasonal sentence"
                      (assq 'advent bcp-1662-seasonal-sentences-evensong))
    (bcp-1662-check-t "Eastertide has an evening seasonal sentence"
                      (assq 'eastertide bcp-1662-seasonal-sentences-evensong))
    ;; Officiant defaults
    (bcp-1662-check "Default officiant = lay" 'lay office-officiant)
    ;; Lay absolution: Trinity 21 collect should exist
    (bcp-1662-check-t   "Trinity 21 collect exists (lay absolution fallback)"
                        (bcp-1662-collect-text 'trinity-21))
    ;; Venite stripping is nil-safe
    (bcp-1662-check-nil "Venite strip: nil input returns nil"
                        (bcp-1662--venite-strip-verses-8-11 nil))
    ;; Canticle config defaults
    (bcp-1662-check "bcp-liturgy-canticle-language default = english" 'english bcp-liturgy-canticle-language)
    (bcp-1662-check-nil "bcp-liturgy-canticle-overrides default = nil" bcp-liturgy-canticle-overrides)
    (bcp-1662-check-nil "bcp-liturgy-canticle-append-gloria default = nil"
                        bcp-liturgy-canticle-append-gloria)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Results reporting

(defun bcp-1662-test--report ()
  "Format and return the test results as a string."
  (let* ((results  (nreverse bcp-1662-test--results))
         (total    (length results))
         (passed   (cl-count-if #'caddr results))
         (failed   (- total passed))
         (sections (cl-remove-duplicates (mapcar #'car results) :test #'equal))
         (lines    nil))
    (push (format "BCP 1662 Test Results — %d/%d passed%s\n%s\n"
                  passed total
                  (if (= failed 0) " ✓" (format " (%d FAILED)" failed))
                  (make-string 60 ?─))
          lines)
    (dolist (section sections)
      (let* ((sec-results (cl-remove-if-not (lambda (r) (equal (car r) section)) results))
             (sec-total   (length sec-results))
             (sec-passed  (cl-count-if #'caddr sec-results))
             (sec-failed  (- sec-total sec-passed))
             (sec-status  (if (= sec-failed 0)
                              (format "✓ %d/%d" sec-passed sec-total)
                            (format "✗ %d/%d — %d FAILED" sec-passed sec-total sec-failed))))
        (push (format "\n%s  [%s]\n" section sec-status) lines)
        (dolist (r sec-results)
          (cl-destructuring-bind (sec name pass expected actual) r
            (ignore sec)
            (if pass
                (push (format "  ✓ %s\n" name) lines)
              (push (format "  ✗ %s\n      Expected: %S\n      Actual:   %S\n"
                            name expected actual)
                    lines))))))
    (push (format "\n%s\nTotal: %d passed, %d failed\n"
                  (make-string 60 ?─) passed failed)
          lines)
    (apply #'concat (nreverse lines))))

;;;###autoload
(defun bcp-1662-run-tests ()
  "Run all automated bcp-1662 shakedown tests and display results."
  (interactive)
  (bcp-1662-test--run-all)
  (let ((report (bcp-1662-test--report)))
    (if noninteractive
        (message "%s" report)
      (with-current-buffer (get-buffer-create "*BCP 1662 Tests*")
        (read-only-mode -1)
        (erase-buffer)
        (insert report)
        (goto-char (point-min))
        (read-only-mode 1))
      (pop-to-buffer "*BCP 1662 Tests*"))))

(provide 'bcp-1662-test)
;;; bcp-1662-test.el ends here
