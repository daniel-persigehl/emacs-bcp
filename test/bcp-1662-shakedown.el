;;; bcp-1662-shakedown.el --- Shakedown tests for bcp-1662 -*- lexical-binding: t -*-

;;; Commentary:

;; Evaluation-based shakedown tests.  Load all bcp-1662 files first, then
;; evaluate each form with C-x C-e and check the result matches the comment.
;;
;; Sections:
;;   1. Load check
;;   2. Calendar — Easter, seasons, dominical letters
;;   3. Calendar — edge cases (earliest/latest Easter, leap years)
;;   4. Feast lookup
;;   5. Vigils and fasts
;;   6. Collect retrieval — standard and aliases
;;   7. Seasonal collect boundaries
;;   8. Office lessons — weekday, Sunday proper, feast
;;   9. Communion propers
;;  10. Dispatch — representative dates
;;  11. User feasts
;;  12. Fetch and render (interactive)

;;; Code:

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 1. LOAD CHECK
;;;; ══════════════════════════════════════════════════════════════════════════

;; Evaluate this block — should return t with no errors.
(and (featurep 'bcp-reader)
     (featurep 'bcp-1662-calendar)
     (featurep 'bcp-1662-data)
     (featurep 'bcp-1662-user-feasts)
     (featurep 'bcp-1662))
;; Expected: t


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 2. CALENDAR — EASTER, SEASONS, DOMINICAL LETTERS
;;;; ══════════════════════════════════════════════════════════════════════════

;; Easter Sunday for several years
(bcp-1662-easter 2026) ;; Expected: (4 5 2026)
(bcp-1662-easter 2027) ;; Expected: (3 28 2027)
(bcp-1662-easter 2028) ;; Expected: (4 16 2028)
(bcp-1662-easter 2019) ;; Expected: (4 21 2019)

;; Advent Sunday — should always be the Sunday nearest Nov 30
(bcp-1662-advent-1 2026) ;; Expected: (11 29 2026)  Sun nearest Nov 30
(bcp-1662-advent-1 2025) ;; Expected: (11 30 2025)  Nov 30 IS a Sunday

;; Liturgical seasons — check boundaries carefully
(bcp-1662-liturgical-season 3 21 2026) ;; Expected: lent       (today, before Passion Sun Mar 22)
(bcp-1662-liturgical-season 3 22 2026) ;; Expected: passiontide (Passion Sunday)
(bcp-1662-liturgical-season 4  4 2026) ;; Expected: passiontide (Easter Even / Holy Saturday)
(bcp-1662-liturgical-season 4  5 2026) ;; Expected: eastertide  (Easter Day)
(bcp-1662-liturgical-season 5 24 2026) ;; Expected: eastertide  (Whitsunday)
(bcp-1662-liturgical-season 5 31 2026) ;; Expected: trinity     (Trinity Sunday — first day of trinity)
(bcp-1662-liturgical-season 6  1 2026) ;; Expected: trinity
(bcp-1662-liturgical-season 11 29 2026) ;; Expected: advent     (Advent Sunday)
(bcp-1662-liturgical-season 11 28 2026) ;; Expected: trinity    (Saturday before Advent)
(bcp-1662-liturgical-season 12 25 2026) ;; Expected: christmas
(bcp-1662-liturgical-season  1  5 2026) ;; Expected: christmas  (day before Epiphany)
(bcp-1662-liturgical-season  1  6 2026) ;; Expected: epiphany

;; Liturgical week
(bcp-1662-liturgical-week 5 31 2026)  ;; Expected: (trinity . 0)  (Trinity Sunday itself)
(bcp-1662-liturgical-week 6 7 2026)   ;; Expected: (trinity . 1)  (First Sunday after Trinity)
(bcp-1662-liturgical-week 12 6 2026)  ;; Expected: (advent . 2)
(bcp-1662-liturgical-week 11 29 2026) ;; Expected: (advent . 1)

;; Dominical letter
(bcp-1662-dominical-letter 2026) ;; Expected: "D"       (2026 is not a leap year)
(bcp-1662-dominical-letter 2024) ;; Expected: "GF"      (2024 is a leap year)
(bcp-1662-dominical-letter 2000) ;; Expected: "BA"      (2000 leap year)

;; Moveable feasts 2026
(let ((f (bcp-1662-moveable-feasts 2026)))
  (list (cdr (assq 'ash-wednesday   f))  ;; Expected: (2 18 2026)
        (cdr (assq 'easter          f))  ;; Expected: (4  5 2026)
        (cdr (assq 'ascension       f))  ;; Expected: (5 14 2026)
        (cdr (assq 'whitsunday      f))  ;; Expected: (5 24 2026)
        (cdr (assq 'trinity-sunday  f))));; Expected: (5 31 2026)


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 3. CALENDAR — EDGE CASES
;;;; ══════════════════════════════════════════════════════════════════════════

;; Earliest possible Easter: March 22
(bcp-1662-easter 1818) ;; Expected: (3 22 1818)
(bcp-1662-easter 2285) ;; Expected: (3 22 2285)

;; Latest possible Easter: April 25
(bcp-1662-easter 1943) ;; Expected: (4 25 1943)
(bcp-1662-easter 2038) ;; Expected: (4 25 2038)

;; Leap year Feb 29 — should have dominical nil
(let ((entry (cl-some (lambda (e)
                         (when (and (= (car e) 2) (= (cadr e) 29)) e))
                       bcp-1662-propers-year)))
  (plist-get (cddr entry) :dominical))
;; Expected: nil  (Feb 29 has no dominical letter by design)

;; Year where Advent Sunday = Dec 1 (Nov 30 is Saturday, Sunday is Dec 1)
(bcp-1662-advent-1 2024) ;; Expected: (12 1 2024)

;; Chair of St Peter (Feb 22) falls on Ash Wednesday in 2034
(bcp-1662-user-feast-observed-date 'chair-of-st-peter 2034)
;; Expected: (2 24 2034)  — Friday after Ash Wednesday

;; St William of York (Jun 8) falls in Whitsuntide in 2028
(bcp-1662-user-feast-observed-date 'st-william-of-york 2028)
;; Expected: (6 13 2028)  — Tuesday after Trinity Sunday


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 4. FEAST LOOKUP
;;;; ══════════════════════════════════════════════════════════════════════════

;; Symbol lookup from calendar name
(bcp-1662-feast-symbol "St. Luke, Evang.")    ;; Expected: luke
(bcp-1662-feast-symbol "Christmas-Day")        ;; Expected: christmas
(bcp-1662-feast-symbol "St. Michael and all Angels") ;; Expected: michael
(bcp-1662-feast-symbol "Fast.")                ;; Expected: nil  (fasts are not feasts)

;; Feast data
(plist-get (bcp-1662-feast-data 'luke)      :rank) ;; Expected: greater
(plist-get (bcp-1662-feast-data 'christmas) :rank) ;; Expected: principal
(plist-get (bcp-1662-feast-data 'benedict)  :rank) ;; Expected: lesser
(plist-get (bcp-1662-feast-data 'luke)      :date) ;; Expected: (10 18)

;; Feasts on a given date
(mapcar #'car (bcp-1662-feasts-for-date 10 18)) ;; Expected: (luke)
(mapcar #'car (bcp-1662-feasts-for-date 12 25)) ;; Expected: (christmas)
(mapcar #'car (bcp-1662-feasts-for-date  3 21)) ;; Expected: (benedict)

;; Feast symbol from calendar entry on a specific date
(bcp-1662--feast-symbol-for-date 10 18) ;; Expected: luke
(bcp-1662--feast-symbol-for-date  1  1) ;; Expected: circumcision
(bcp-1662--feast-symbol-for-date  7 15) ;; Expected: swithun  (lesser)
(bcp-1662--feast-symbol-for-date  6  3) ;; Expected: nil  (no feast)


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 5. VIGILS AND FASTS
;;;; ══════════════════════════════════════════════════════════════════════════

;; Days with vigils (fast the day before)
(bcp-1662-feast-has-vigil-p 'christmas)          ;; Expected: t
(bcp-1662-feast-has-vigil-p 'peter)              ;; Expected: t
(bcp-1662-feast-has-vigil-p 'luke)               ;; Expected: nil  (no vigil for Luke)
(bcp-1662-feast-has-vigil-p 'all-saints)         ;; Expected: t   (All Hallows Eve)
(bcp-1662-feast-has-vigil-p 'michael)            ;; Expected: nil

;; Vigil lookup by date — is this date a vigil?
(bcp-1662-vigil-p 12 24) ;; Expected: christmas  (Christmas Eve is vigil of Christmas)
(bcp-1662-vigil-p  6 28) ;; Expected: peter      (vigil of St Peter)
(bcp-1662-vigil-p 10 31) ;; Expected: all-saints (All Hallows Eve)
(bcp-1662-vigil-p  6 23) ;; Expected: john-baptist
(bcp-1662-vigil-p  3 21) ;; Expected: nil        (today — no vigil)


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 6. COLLECT RETRIEVAL
;;;; ══════════════════════════════════════════════════════════════════════════

;; Standard collects return text
(and (bcp-1662-collect-text 'trinity-1)      t) ;; Expected: t  (not nil)
(and (bcp-1662-collect-text 'ash-wednesday)  t) ;; Expected: t
(and (bcp-1662-collect-text 'christmas)      t) ;; Expected: t
(and (bcp-1662-collect-text 'luke)           t) ;; Expected: t
(and (bcp-1662-collect-text 'good-friday)    t) ;; Expected: t  (first collect)
(and (bcp-1662-collect-text 'good-friday-2)  t) ;; Expected: t  (second collect)
(and (bcp-1662-collect-text 'good-friday-3)  t) ;; Expected: t  (third collect)

;; Trinity-25 alias
(bcp-1662-collect 'trinity-25)
;; Expected: non-nil plist  (alias for sunday-before-advent)
(equal (bcp-1662-collect 'trinity-25)
       (bcp-1662-collect 'sunday-before-advent))
;; Expected: t

;; Stir Up Sunday — check opening word
(substring (bcp-1662-collect-text 'sunday-before-advent) 0 4)
;; Expected: "STIR"

;; Rubric present on Ash Wednesday and Advent 1
(plist-get (bcp-1662-collect 'ash-wednesday) :rubric) ;; Expected: non-nil string
(plist-get (bcp-1662-collect 'advent-1)      :rubric) ;; Expected: non-nil string
(plist-get (bcp-1662-collect 'trinity-1)     :rubric) ;; Expected: nil  (no rubric)

;; Missing collect returns nil gracefully
(bcp-1662-collect-text 'nonexistent-feast)   ;; Expected: nil


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 7. SEASONAL COLLECT BOUNDARIES
;;;; ══════════════════════════════════════════════════════════════════════════

;; Advent — seasonal collect is advent-1
(bcp-1662-seasonal-collect 11 29 2026) ;; Expected: advent-1   (Advent Sunday)
(bcp-1662-seasonal-collect 12 24 2026) ;; Expected: advent-1   (Christmas Eve)
(bcp-1662-seasonal-collect 12 25 2026) ;; Expected: nil        (Christmas Day)

;; Lent — seasonal collect is ash-wednesday
(bcp-1662-seasonal-collect  2 18 2026) ;; Expected: ash-wednesday  (Ash Wednesday)
(bcp-1662-seasonal-collect  3 22 2026) ;; Expected: ash-wednesday  (Passion Sunday)
(bcp-1662-seasonal-collect  4  4 2026) ;; Expected: ash-wednesday  (Easter Even)
(bcp-1662-seasonal-collect  4  5 2026) ;; Expected: nil            (Easter Day — drops)

;; Other seasons — nil
(bcp-1662-seasonal-collect  6  7 2026) ;; Expected: nil  (Trinity 1)
(bcp-1662-seasonal-collect  1 25 2026) ;; Expected: nil  (Epiphany season)


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 8. OFFICE LESSONS — WEEKDAY, SUNDAY PROPER, FEAST
;;;; ══════════════════════════════════════════════════════════════════════════

;; Ordinary weekday — should come from calendar
(let* ((lessons (bcp-1662-office-lessons 3 21 2026 'mattins)))
  (list (plist-get lessons :source)
        (plist-get lessons :lesson1)))
;; Expected: (calendar ("Deut" 11 ...))  source=calendar, Deut lesson

;; Sunday — should use Sunday proper if available
(let* ((lessons (bcp-1662-office-lessons 3 22 2026 'mattins))) ; Passion Sunday
  (plist-get lessons :source))
;; Expected: sunday-proper  (or calendar if no proper for passiontide)

;; Trinity 1 Sunday (June 7 2026)
(let* ((lessons (bcp-1662-office-lessons 6 7 2026 'mattins)))
  (list (plist-get lessons :source)
        (plist-get lessons :lesson1)))
;; Expected: (sunday-proper ...) — proper lesson for Trinity 1

;; Greater feast — St Luke (Oct 18)
(let* ((lessons (bcp-1662-office-lessons 10 18 2026 'mattins)))
  (list (plist-get lessons :source)
        (plist-get lessons :lesson1)))
;; Expected: (feast-proper ...) — proper lesson for St Luke's Day

;; Lesser feast — should NOT override calendar lessons
(let* ((lessons (bcp-1662-office-lessons 3 21 2026 'mattins))) ; Benedict (lesser)
  (plist-get lessons :source))
;; Expected: calendar  (Benedict is lesser — calendar lessons used)

;; Christmas Day
(let* ((lessons (bcp-1662-office-lessons 12 25 2026 'mattins)))
  (plist-get lessons :source))
;; Expected: feast-proper  (Christmas is principal)


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 9. COMMUNION PROPERS
;;;; ══════════════════════════════════════════════════════════════════════════

;; Sunday proper lookup
(bcp-1662-communion-proper-for-date 11 29 2026) ;; Expected: advent-1
(bcp-1662-communion-proper-for-date  5 31 2026) ;; Expected: trinity-sunday
(bcp-1662-communion-proper-for-date  6  7 2026) ;; Expected: trinity-1
(bcp-1662-communion-proper-for-date  4  5 2026) ;; Expected: easter

;; Fixed feast proper
(bcp-1662-communion-proper-for-date 10 18 2026) ;; Expected: luke
(bcp-1662-communion-proper-for-date  6 29 2026) ;; Expected: peter
(bcp-1662-communion-proper-for-date 11 30 2026) ;; Expected: andrew

;; Moveable specials
(bcp-1662-communion-proper-for-date  2 18 2026) ;; Expected: ash-wednesday
(bcp-1662-communion-proper-for-date  4  3 2026) ;; Expected: good-friday
(bcp-1662-communion-proper-for-date  5 14 2026) ;; Expected: ascension

;; Trinity-25 alias in communion propers
(bcp-1662-communion-propers 'trinity-25)
;; Expected: non-nil plist  (alias maps trinity-25 → sunday-before-advent)
(equal (bcp-1662-communion-propers 'trinity-25)
       (bcp-1662-communion-propers 'sunday-before-advent))
;; Expected: t

;; OT reading lookup
(bcp-1662-ot-reading 'advent-1)        ;; Expected: ("Isa" 62 10 12)
(bcp-1662-ot-reading 'easter)          ;; Expected: ("Isa" 25 6 9)
(bcp-1662-ot-reading 'trinity-25)      ;; Expected: ("Dan" 12 1 4)  alias works
(bcp-1662-ot-reading 'nonexistent)     ;; Expected: nil


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 10. DISPATCH — REPRESENTATIVE DATES
;;;; ══════════════════════════════════════════════════════════════════════════

;; Today (Lent 4, Benedict lesser feast)
(let* ((p (bcp-1662-propers-for-date 3 21 2026 'mattins)))
  (list :season           (plist-get p :season)
        :feast            (plist-get p :feast)
        :feast-rank       (plist-get p :feast-rank)
        :collect          (plist-get p :collect)
        :seasonal-collect (plist-get p :seasonal-collect)
        :communion        (plist-get p :communion)))
;; Expected:
;;   :season lent
;;   :feast benedict
;;   :feast-rank lesser
;;   :collect  — something (lent-4 if Sunday, or preceding Sunday's collect)
;;   :seasonal-collect ash-wednesday
;;   :communion nil  (weekday, no Sunday proper)

;; Easter Day
(let* ((p (bcp-1662-propers-for-date 4 5 2026 'mattins)))
  (list :season           (plist-get p :season)
        :collect          (plist-get p :collect)
        :seasonal-collect (plist-get p :seasonal-collect)
        :communion        (plist-get p :communion)))
;; Expected:
;;   :season eastertide
;;   :collect easter
;;   :seasonal-collect nil  (seasonal collect drops on Easter Day)
;;   :communion easter

;; Advent Sunday
(let* ((p (bcp-1662-propers-for-date 11 29 2026 'mattins)))
  (list :season           (plist-get p :season)
        :collect          (plist-get p :collect)
        :seasonal-collect (plist-get p :seasonal-collect)
        :communion        (plist-get p :communion)))
;; Expected:
;;   :season advent
;;   :collect advent-1
;;   :seasonal-collect advent-1  (same — both are advent-1 on Advent Sunday itself)
;;   :communion advent-1

;; St Luke's Day (greater feast, Oct 18)
(let* ((p (bcp-1662-propers-for-date 10 18 2026 'mattins)))
  (list :feast      (plist-get p :feast)
        :feast-rank (plist-get p :feast-rank)
        :collect    (plist-get p :collect)
        :communion  (plist-get p :communion)))
;; Expected:
;;   :feast luke
;;   :feast-rank greater
;;   :collect luke
;;   :communion luke

;; Christmas Day (principal feast)
(let* ((p (bcp-1662-propers-for-date 12 25 2026 'mattins)))
  (list :feast      (plist-get p :feast)
        :feast-rank (plist-get p :feast-rank)
        :collect    (plist-get p :collect)
        :communion  (plist-get p :communion)))
;; Expected:
;;   :feast christmas
;;   :feast-rank principal
;;   :collect christmas
;;   :communion christmas

;; Wednesday in Trinity season — collect inherited from preceding Sunday
(let* ((p (bcp-1662-propers-for-date 6 10 2026 'mattins))) ; Wed after Trinity 1
  (list :season  (plist-get p :season)
        :collect (plist-get p :collect)))
;; Expected:
;;   :season trinity
;;   :collect trinity-1  (inherited from Trinity 1 Sunday, Jun 7)

;; Sunday Before Advent
(let* ((p (bcp-1662-propers-for-date 11 22 2026 'mattins)))
  (list :collect   (plist-get p :collect)
        :communion (plist-get p :communion)))
;; Expected:
;;   :collect sunday-before-advent  (Stir Up Sunday)
;;   :communion sunday-before-advent

;; Good Friday — three collects
(bcp-1662-collect-of-day 4 3 2026) ;; Expected: good-friday
;; NB: good-friday-2 and good-friday-3 must be retrieved separately


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 11. USER FEASTS
;;;; ══════════════════════════════════════════════════════════════════════════

;; All five patronal feasts are recognised
(bcp-1662-user-feast-p 'luke)              ;; Expected: t  (parish)
(bcp-1662-user-feast-p 'conversion-st-paul) ;; Expected: t  (secondary parish)
(bcp-1662-user-feast-p 'augustine-hippo)   ;; Expected: t  (personal)
(bcp-1662-user-feast-p 'chair-of-st-peter) ;; Expected: t  (diocese)
(bcp-1662-user-feast-p 'st-william-of-york);; Expected: t  (employer)
(bcp-1662-user-feast-p 'benedict)          ;; Expected: nil (not a user feast)

;; Occasion types
(bcp-1662-user-feast-occasion 'luke)              ;; Expected: parish
(bcp-1662-user-feast-occasion 'conversion-st-paul);; Expected: secondary-parish
(bcp-1662-user-feast-occasion 'augustine-hippo)   ;; Expected: personal
(bcp-1662-user-feast-occasion 'chair-of-st-peter) ;; Expected: diocese
(bcp-1662-user-feast-occasion 'st-william-of-york);; Expected: employer

;; Effective rank — patronal elevation
(bcp-1662-effective-feast-rank 'luke         'greater) ;; Expected: greater
(bcp-1662-effective-feast-rank 'augustine-hippo 'lesser) ;; Expected: greater (elevated)
(bcp-1662-effective-feast-rank 'chair-of-st-peter 'lesser) ;; Expected: greater (elevated)

;; Transfer dates
(bcp-1662-user-feast-observed-date 'chair-of-st-peter 2026)
;; Expected: (2 22 2026)  — no conflict in 2026

(bcp-1662-user-feast-observed-date 'chair-of-st-peter 2034)
;; Expected: (2 24 2034)  — transferred from Ash Wednesday to Friday

(bcp-1662-user-feast-observed-date 'st-william-of-york 2026)
;; Expected: (6 8 2026)   — no conflict in 2026

(bcp-1662-user-feast-observed-date 'st-william-of-york 2028)
;; Expected: (6 13 2028)  — transferred from Whitsuntide to Tue after Trinity


;;;; ══════════════════════════════════════════════════════════════════════════
;;;; 12. FETCH AND RENDER (interactive)
;;;; ══════════════════════════════════════════════════════════════════════════

;; Run the Office for today
;; M-x bcp-1662-open-office
;; Expected: buffer appears with "Loading…" then fills in with:
;;   - Season: Lent 4  (today Mar 21 2026)
;;   - Feast: Benedict, Abbot (lesser)
;;   - Psalms: Ps 105 (morning, day 21) with Coverdale text
;;   - First Lesson: Deut 11:... with AV text
;;   - Second Lesson: NT passage with AV text
;;   - Collect of the Day: Lent 4 collect
;;   - Seasonal Collect: Ash Wednesday collect

;; Run with date override — St Luke's Day (greater feast)
(bcp-1662-set-office-date 2026 10 18 9)
;; Then: M-x bcp-1662-open-office
;; Expected:
;;   - Season: Trinity (18)
;;   - Feast: Luke, Evangelist (greater)
;;   - Psalms: Ps 102, 103 (morning, day 18) with Coverdale text
;;   - Lessons: proper lessons for St Luke
;;   - Collect: Luke collect ("ALMIGHTY God, who calledst Luke…")
;;   - No seasonal collect

;; Reset date override
(bcp-1662-set-office-date nil nil nil nil)
;; Then verify M-x bcp-1662-open-office returns to today

;; Evening Prayer check
(bcp-1662-set-office-date 2026 3 21 18)
;; Then: M-x bcp-1662-open-office
;; Expected: "Evening Prayer" heading, evening psalms (Ps 106)

;; Reset
(bcp-1662-set-office-date nil nil nil nil)

;; Translation check — temporarily switch psalm translation
(setq bible-commentary-psalm-translation "KJVA")
;; Then: M-x bcp-1662-open-office
;; Expected: psalms in KJV rather than Coverdale
;; (text will differ subtly — e.g. Coverdale has "O give thanks"
;;  while KJV has "O give thanks")

;; Restore
(setq bible-commentary-psalm-translation "Coverdale")

(provide 'bcp-1662-shakedown)
;;; bcp-1662-shakedown.el ends here
