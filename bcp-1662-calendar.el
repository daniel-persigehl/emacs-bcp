;;; bcp-1662-calendar.el --- Liturgical calendar for 1662 BCP -*- lexical-binding: t -*-

;; Keywords: bible, bcp, liturgy, calendar

;;; Commentary:

;; BCP 1662-specific calendar layer.  Depends on bcp-calendar.el for all
;; rite-agnostic computus (Easter, Advent Sunday, moveable feasts, Ember
;; Days, Rogation Days, date arithmetic, and the rank taxonomy).
;;
;; This file provides only what is specific to the 1662 BCP:
;;   - Liturgical season identification (BCP season names and boundaries)
;;   - Liturgical week numbering (Trinity counting, Epiphany overflow)
;;   - BCP feast table (symbols, dates, ranks, vigil flags)
;;   - Feast name → symbol mapping
;;   - Backwards-compatible aliases for the public bcp-1662- API
;;
;; Public functions that were previously defined here but now live in
;; bcp-calendar.el are re-exported as aliases so existing callers continue
;; to work without modification:
;;   bcp-1662-easter            → bcp-easter
;;   bcp-1662-dominical-letter  → bcp-dominical-letter
;;   bcp-1662-advent-sunday     → bcp-advent-sunday
;;   bcp-1662-moveable-feasts   → bcp-moveable-feasts
;;   bcp-1662-ember-days        → bcp-ember-days
;;   bcp-1662-rogation-days     → bcp-rogation-days
;;   bcp-1662-date=             → bcp-date=
;;   bcp-1662-date-in-list-p    → bcp-date-in-list-p
;;   bcp-1662-days-after-easter → bcp-days-after-easter

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-calendar)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Backwards-compatible aliases for the public bcp-1662- API
;;;; All calendar computation now lives in bcp-calendar.el.
;;;; ══════════════════════════════════════════════════════════════════════════

;; Computus
(defalias 'bcp-1662-easter            #'bcp-easter)
(defalias 'bcp-1662-dominical-letter  #'bcp-dominical-letter)
(defalias 'bcp-1662-advent-sunday     #'bcp-advent-sunday)
(defalias 'bcp-1662-moveable-feasts   #'bcp-moveable-feasts)
(defalias 'bcp-1662-ember-days        #'bcp-ember-days)
(defalias 'bcp-1662-rogation-days     #'bcp-rogation-days)

;; Date utilities
(defalias 'bcp-1662-date=             #'bcp-date=)
(defalias 'bcp-1662-date-in-list-p    #'bcp-date-in-list-p)
(defalias 'bcp-1662-days-after-easter #'bcp-days-after-easter)

;; Rank comparison (bcp-1662--rank-value used internally in bcp-1662.el)
;; The old function returned a numeric value where lower = higher precedence,
;; using only 'principal / 'greater / 'lesser.  bcp-rank-value now handles
;; these via the alias table in bcp-calendar.el.
(defun bcp-1662--rank-value (rank)
  "Return numeric precedence for RANK (lower = higher precedence).
Delegates to `bcp-rank-value'; kept for internal compatibility."
  (bcp-rank-value rank))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; BCP 1662 liturgical season and week identification
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1662-liturgical-season (month day year)
  "Return the BCP 1662 liturgical season for (MONTH DAY YEAR).

Returns a symbol.  Season boundaries follow the 1662 BCP:
  advent          — Advent Sunday through Christmas Eve
  christmas       — Christmas Day through Eve of Epiphany
  epiphany        — Epiphany through Septuagesima Sunday eve
  pre-lent        — Septuagesima, Sexagesima, Quinquagesima
  lent            — Ash Wednesday through Passion Sunday eve
  passiontide     — Passion Sunday through Holy Saturday
  eastertide      — Easter Day through Saturday before Trinity
  trinity         — Trinity Sunday through last Saturday before Advent

Note: the Roman Rite uses different season names and boundaries
\(e.g. \"per annum\" instead of Trinity season).  This function is
specific to the BCP family of rites."
  (let* ((feasts   (bcp-moveable-feasts year))
         (abs      (calendar-absolute-from-gregorian (list month day year)))
         (easter   (calendar-absolute-from-gregorian
                    (cdr (assq 'easter feasts))))
         (ash      (calendar-absolute-from-gregorian
                    (cdr (assq 'ash-wednesday feasts))))
         (passion  (calendar-absolute-from-gregorian
                    (cdr (assq 'passion-sunday feasts))))
         (whit     (calendar-absolute-from-gregorian
                    (cdr (assq 'whitsunday feasts))))
         (trinity  (calendar-absolute-from-gregorian
                    (cdr (assq 'trinity-sunday feasts))))
         (advent   (calendar-absolute-from-gregorian
                    (bcp-advent-sunday year)))
         ;; Septuagesima = 9 Sundays before Easter = Easter - 63
         (septuagesima (- easter 63))
         ;; Christmas Day
         (christmas (calendar-absolute-from-gregorian (list 12 25 year)))
         ;; Epiphany
         (epiphany  (calendar-absolute-from-gregorian (list 1 6 year)))
         ;; Advent of previous year (for dates in Jan–Nov)
         (prev-advent (calendar-absolute-from-gregorian
                       (bcp-advent-sunday (1- year)))))
    (cond
     ;; Advent (current year: from Advent Sunday to Dec 24)
     ((and (>= abs advent) (<= abs (+ christmas -1)))
      'advent)
     ;; Christmas (Dec 25 to Jan 5)
     ((or (and (>= abs christmas) (<= abs (calendar-absolute-from-gregorian (list 1 5 (1+ year)))))
          (and (>= abs (calendar-absolute-from-gregorian (list 12 25 (1- year))))
               (<= abs (calendar-absolute-from-gregorian (list 1 5 year)))))
      'christmas)
     ;; Epiphanytide (Jan 6 to Septuagesima eve)
     ((and (>= abs epiphany) (< abs septuagesima))
      'epiphany)
     ;; Pre-Lent / Gesimas (Septuagesima to Ash Wednesday eve)
     ((and (>= abs septuagesima) (< abs ash))
      'pre-lent)
     ;; Passiontide (Passion Sunday to Holy Saturday = Easter - 1)
     ((and (>= abs passion) (< abs easter))
      'passiontide)
     ;; Lent proper (Ash Wednesday to Passion Sunday eve)
     ((and (>= abs ash) (< abs passion))
      'lent)
     ;; Eastertide (Easter Day to Saturday after Whitsun week = Trinity - 1)
     ((and (>= abs easter) (< abs trinity))
      'eastertide)
     ;; Trinity (Trinity Sunday to Advent eve)
     ((and (>= abs trinity) (< abs advent))
      'trinity)
     ;; Fallback for dates in Advent/Christmas of previous year
     ;; or Epiphanytide before Jan 6 of next year
     (t 'trinity))))

(defun bcp-1662-liturgical-week (month day year)
  "Return the liturgical week identifier for (MONTH DAY YEAR).

Returns a cons cell (SEASON . WEEK-NUMBER) where WEEK-NUMBER is an
integer counting from 1, or nil for seasons where week number is not
conventionally used (e.g. Christmas, Epiphany).

Examples:
  (trinity . 14)       — 14th Sunday after Trinity
  (advent . 2)         — 2nd Sunday in Advent
  (lent . 3)           — 3rd Sunday in Lent (Oculi)
  (easter . 1)         — Low Sunday (1st Sunday after Easter)
  (epiphany . 3)       — 3rd Sunday after Epiphany"
  (let* ((feasts     (bcp-moveable-feasts year))
         (abs        (calendar-absolute-from-gregorian (list month day year)))
         (easter     (calendar-absolute-from-gregorian
                      (cdr (assq 'easter feasts))))
         (ash        (calendar-absolute-from-gregorian
                      (cdr (assq 'ash-wednesday feasts))))
         (trinity    (calendar-absolute-from-gregorian
                      (cdr (assq 'trinity-sunday feasts))))
         (advent     (calendar-absolute-from-gregorian
                      (bcp-advent-sunday year)))
         (epiphany   (calendar-absolute-from-gregorian (list 1 6 year)))
         (septuagesima (- easter 63))
         (season     (bcp-1662-liturgical-season month day year))
         ;; Find the most recent Sunday on or before this date
         (dow        (calendar-day-of-week (list month day year)))
         (last-sun   (- abs dow)))
    (pcase season
      ('advent
       (cons 'advent (1+ (/ (- last-sun advent) 7))))
      ('pre-lent
       ;; Septuagesima=1, Sexagesima=2, Quinquagesima=3
       (cons 'pre-lent (1+ (/ (- last-sun septuagesima) 7))))
      ('lent
       ;; Ash Wednesday week = Lent 1, etc.
       (cons 'lent (1+ (/ (- last-sun ash) 7))))
      ('passiontide
       ;; Passion Sunday = Lent 5, Palm Sunday = Lent 6
       (let ((passion (calendar-absolute-from-gregorian
                       (cdr (assq 'passion-sunday feasts)))))
         (cons 'lent (+ 5 (/ (- last-sun passion) 7)))))
      ('eastertide
       ;; Easter Day = Easter 0, Low Sunday = Easter 1, etc.
       (cons 'easter (/ (- last-sun easter) 7)))
      ('trinity
       ;; Trinity Sunday itself = 0 (it is not "after" Trinity)
       ;; First Sunday after Trinity = 1, etc.
       ;; The BCP rubric says omitted Epiphany Sundays are inserted before
       ;; the Sunday Next Before Advent (Trinity 25) to fill any shortfall.
       ;; Calculate how many Sundays after Trinity there are in this year;
       ;; if fewer than 25, the gap is filled by Epiphany overflow (5 and/or 6),
       ;; inserted at the positions just before Trinity 25.
       (let* ((raw-num      (/ (- last-sun trinity) 7))
              ;; Sunday Before Advent is always Trinity 25
              ;; Find actual number of Sundays between Trinity and Advent
              (sun-bef-adv  (- advent 7))  ; Sunday before Advent Sunday
              (total-trin   (/ (- sun-bef-adv trinity) 7))
              ;; Number of overflow Sundays needed (0, 1, or 2)
              (overflow     (max 0 (- 25 total-trin)))
              ;; Overflow starts total-trin - overflow weeks after Trinity
              (overflow-start (- total-trin overflow)))
         (cond
          ;; Trinity Sunday itself
          ((= raw-num 0) (cons 'trinity 0))
          ;; Sunday Before Advent is always Trinity 25
          ((= raw-num total-trin) (cons 'trinity 25))
          ;; Overflow zone: use Epiphany propers
          ;; overflow=1: last slot before Sun Bef Advent → epiphany-5
          ;; overflow=2: two slots before Sun Bef Advent → epiphany-5, epiphany-6
          ((and (> overflow 0) (>= raw-num overflow-start) (< raw-num total-trin))
           (let ((epiphany-num (+ 5 (- raw-num overflow-start))))
             (cons 'epiphany epiphany-num)))
          ;; Surplus Sundays (total-trin > 25): omit silently per BCP rubric
          ;; These fall between Trinity 24 and the Sunday Before Advent
          ((and (> total-trin 25) (> raw-num 24) (< raw-num total-trin))
           (cons 'trinity nil))
          ;; Normal Trinity week
          (t (cons 'trinity raw-num)))))
      ('epiphany
       (cons 'epiphany (1+ (/ (- last-sun epiphany) 7))))
      (_
       ;; Christmas and other seasons — no conventional week number
       (cons season nil)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Feast Name → Symbol Mapping
;;;; ──────────────────────────────────────────────────────────────────────

(defconst bcp-1662-feast-name-to-symbol
  '(("Circumcision of our Lord"              . circumcision)
    ("Epiphany of our Lord"                  . epiphany)
    ("Lucian, P. & M."                       . lucian)
    ("Hilary, Bp. & C."                      . hilary)
    ("Prisca, V. & M."                       . prisca)
    ("Fabian, Bp. & M."                      . fabian)
    ("Agnes, V. & M."                        . agnes)
    ("Vincent, Mart."                        . vincent)
    ("Conversion of St. Paul"                . conversion-st-paul)
    ("Purific. of V. M."                     . purification-bvm)
    ("Agatha, V. & M."                       . agatha)
    ("Valentine, Bishop"                     . valentine)
    ("St. Matthias, Ap."                     . matthias)
    ("David, Archbp."                        . david)
    ("Chad, Bishop"                          . chad)
    ("Perpetua, M."                          . perpetua)
    ("Gregory, M. B."                        . gregory)
    ("Edward, King of the West-Sax."         . edward)
    ("Benedict, Abbot."                      . benedict)
    ("Annunc. of Vir. Mary"                  . annunciation)
    ("Richard, Bp."                          . richard)
    ("S. Ambrose, Bp."                       . ambrose)
    ("Alphege, Abp."                         . alphege)
    ("St. George, M."                        . george)
    ("St. Mark, Evan."                       . mark)
    ("St. Philip and St. James, Ap."         . philip-and-james)
    ("Invent. of Cross"                      . cross-invention)
    ("St. John, E. ante Port. Lat."          . john-before-gate)
    ("Dunstan, Archbp."                      . dunstan)
    ("Augustine, Archbp."                    . augustine-canterbury)
    ("Ven. Bede, Presb."                     . bede)
    ("Nicomede, M."                          . nicomede)
    ("Boniface, Bishop."                     . boniface)
    ("St. Barnabas, Ap."                     . barnabas)
    ("St. Alban, Mart."                      . alban)
    ("Tr. of King Edw."                      . edward-translation)
    ("St. John Baptist"                      . john-baptist)
    ("St. Peter, Apostle."                   . peter)
    ("Visitation of the Blessed Virgin Mary" . visitation-bvm)
    ("Tr. of St. Martin"                     . martin-translation)
    ("Swithun, Bishop"                       . swithun)
    ("Margaret V. & M."                      . margaret)
    ("St. Mary Magdalen"                     . mary-magdalene)
    ("St. James, Apostle"                    . james)
    ("St. Anne"                              . anne)
    ("Lammas Day"                            . lammas)
    ("Transfiguration"                       . transfiguration)
    ("Name of Jesus"                         . name-of-jesus)
    ("St. Lawrence, M."                      . laurence)
    ("St. Bartholomew"                       . bartholomew)
    ("St. Augustine, B."                     . augustine-hippo)
    ("Beheading of St. John Baptist"         . john-beheading)
    ("Giles, Abbot."                         . giles)
    ("Enurchus, Bishop."                     . enurchus)
    ("Nat. of Vir. Mary."                    . nativity-bvm)
    ("Holy-Cross Day"                        . holy-cross)
    ("Lambert, Bishop"                       . lambert)
    ("St. Matthew, Apos."                    . matthew)
    ("St. Cyprian, Abp."                     . cyprian)
    ("St. Michael and all Angels"            . michael)
    ("St. Jerome"                            . jerome)
    ("Remigius, Bp."                         . remigius)
    ("Faith, V. & M."                        . faith)
    ("St. Denys, Bishop"                     . denys)
    ("Trans. K. Edw."                        . edward-translation)
    ("Etheldreda, V."                        . etheldreda)
    ("St. Luke, Evang."                      . luke)
    ("Crispin, Martyr"                       . crispin)
    ("St. Simon & St. Jude"                  . simon-and-jude)
    ("All Saints' Day"                       . all-saints)
    ("Leonard, Conf."                        . leonard)
    ("St. Martin, Bp."                       . martin)
    ("Britius, Bishop"                       . britius)
    ("Machutus, Bp."                         . machutus)
    ("Hugh, Bishop"                          . hugh)
    ("Edmund, King"                          . edmund)
    ("Cecilia, V. & M."                      . cecilia)
    ("St. Clement, Bp."                      . clement)
    ("Catherine, V. & M."                    . catherine)
    ("St. Andrew, Ap."                       . andrew)
    ("Nicolas, Bishop"                       . nicolas)
    ("Conception of Vir. Mary"               . conception-bvm)
    ("Lucy, Vir. & M."                       . lucy)
    ("O Sapientia"                           . o-sapientia)
    ("St. Thomas, Apos."                     . thomas)
    ("Christmas-Day"                         . christmas)
    ("St. Stephen, M."                       . stephen)
    ("St. John, Evang."                      . john-evangelist)
    ("Innocents' Day"                        . innocents)
    ("Silvester, Bishop"                     . silvester))
  "Alist mapping BCP 1662 calendar feast name strings to canonical symbols.

Fast days (\"Fast.\") are not included — they are vigil markers on the
calendar entry of the feast they precede, not feasts in their own right.

The symbol `translation-of-king-edward' appears twice, for Jun 20 and
Oct 13, as both are translations of the same king.")

(defun bcp-1662-feast-symbol (name)
  "Return the canonical symbol for feast NAME string, or nil."
  (cdr (assoc name bcp-1662-feast-name-to-symbol)))

(defun bcp-1662-feast-name (symbol)
  "Return the BCP calendar name string for feast SYMBOL, or nil."
  (car (rassq symbol bcp-1662-feast-name-to-symbol)))


;;;; ──────────────────────────────────────────────────────────────────────
;;;; Feast Data Table
;;;; ──────────────────────────────────────────────────────────────────────

(defconst bcp-1662-feast-data
  '(
    ;; ---- January ----
    (circumcision
     :name    "Circumcision of our Lord"
     :date    (1 1)
     :rank    greater
     :vigil   nil)

    (epiphany
     :name    "Epiphany of our Lord"
     :date    (1 6)
     :rank    principal
     :vigil   nil)

    (lucian
     :name    "Lucian, Priest and Martyr"
     :date    (1 8)
     :rank    lesser
     :vigil   nil)

    (hilary
     :name    "Hilary, Bishop and Confessor"
     :date    (1 13)
     :rank    lesser
     :vigil   nil)

    (prisca
     :name    "Prisca, Virgin and Martyr"
     :date    (1 18)
     :rank    lesser
     :vigil   nil)

    (fabian
     :name    "Fabian, Bishop and Martyr"
     :date    (1 20)
     :rank    lesser
     :vigil   nil)

    (agnes
     :name    "Agnes, Virgin and Martyr"
     :date    (1 21)
     :rank    lesser
     :vigil   nil)

    (vincent
     :name    "Vincent, Martyr"
     :date    (1 22)
     :rank    lesser
     :vigil   nil)

    (conversion-st-paul
     :name    "Conversion of St Paul"
     :date    (1 25)
     :rank    greater
     :vigil   nil)

    ;; ---- February ----
    (purification-bvm
     :name    "Purification of the Blessed Virgin Mary"
     :date    (2 2)
     :rank    greater
     :vigil   nil)

    (agatha
     :name    "Agatha, Virgin and Martyr"
     :date    (2 5)
     :rank    lesser
     :vigil   nil)

    (valentine
     :name    "Valentine, Bishop"
     :date    (2 14)
     :rank    lesser
     :vigil   nil)

    (matthias
     :name    "Matthias, Apostle"
     :date    (2 24)
     :rank    greater
     :vigil   t)

    ;; ---- March ----
    (david
     :name    "David, Archbishop"
     :date    (3 1)
     :rank    lesser
     :vigil   nil)

    (chad
     :name    "Chad, Bishop"
     :date    (3 2)
     :rank    lesser
     :vigil   nil)

    (perpetua
     :name    "Perpetua, Martyr"
     :date    (3 7)
     :rank    lesser
     :vigil   nil)

    (gregory
     :name    "Gregory, Bishop"
     :date    (3 12)
     :rank    lesser
     :vigil   nil)

    (edward
     :name    "Edward, King of the West Saxons"
     :date    (3 18)
     :rank    lesser
     :vigil   nil)

    (benedict
     :name    "Benedict, Abbot"
     :date    (3 21)
     :rank    lesser
     :vigil   nil)

    (annunciation
     :name    "Annunciation of the Blessed Virgin Mary"
     :date    (3 25)
     :rank    greater
     :vigil   nil)

    ;; ---- April ----
    (richard
     :name    "Richard, Bishop"
     :date    (4 3)
     :rank    lesser
     :vigil   nil)

    (ambrose
     :name    "Ambrose, Bishop"
     :date    (4 4)
     :rank    lesser
     :vigil   nil)

    (alphege
     :name    "Alphege, Archbishop"
     :date    (4 19)
     :rank    lesser
     :vigil   nil)

    (george
     :name    "George, Martyr"
     :date    (4 23)
     :rank    greater
     :vigil   nil)

    (mark
     :name    "Mark, Evangelist"
     :date    (4 25)
     :rank    greater
     :vigil   t)

    ;; ---- May ----
    (philip-and-james
     :name    "Philip and James, Apostles"
     :date    (5 1)
     :rank    greater
     :vigil   t)

    (cross-invention
     :name    "Invention of the Cross"
     :date    (5 3)
     :rank    lesser
     :vigil   nil)

    (john-before-gate
     :name    "John the Evangelist before the Latin Gate"
     :date    (5 6)
     :rank    lesser
     :vigil   nil)

    (dunstan
     :name    "Dunstan, Archbishop"
     :date    (5 19)
     :rank    lesser
     :vigil   nil)

    (augustine-canterbury
     :name    "Augustine, Archbishop of Canterbury"
     :date    (5 26)
     :rank    lesser
     :vigil   nil)

    (bede
     :name    "Bede, Presbyter"
     :date    (5 27)
     :rank    lesser
     :vigil   nil)

    ;; ---- June ----
    (nicomede
     :name    "Nicomede, Martyr"
     :date    (6 1)
     :rank    lesser
     :vigil   nil)

    (boniface
     :name    "Boniface, Bishop"
     :date    (6 5)
     :rank    lesser
     :vigil   nil)

    (barnabas
     :name    "Barnabas, Apostle"
     :date    (6 11)
     :rank    greater
     :vigil   t)

    (alban
     :name    "Alban, Martyr"
     :date    (6 17)
     :rank    lesser
     :vigil   nil)

    (edward-translation
     :name    "Translation of King Edward"
     :date    (6 20)
     :rank    lesser
     :vigil   nil)

    (john-baptist
     :name    "John the Baptist"
     :date    (6 24)
     :rank    greater
     :vigil   t)

    (peter
     :name    "Peter, Apostle"
     :date    (6 29)
     :rank    greater
     :vigil   t)

    ;; ---- July ----
    (visitation-bvm
     :name    "Visitation of the Blessed Virgin Mary"
     :date    (7 2)
     :rank    lesser
     :vigil   nil)

    (martin-translation
     :name    "Translation of St Martin"
     :date    (7 4)
     :rank    lesser
     :vigil   nil)

    (swithun
     :name    "Swithun, Bishop"
     :date    (7 15)
     :rank    lesser
     :vigil   nil)

    (margaret
     :name    "Margaret, Virgin and Martyr"
     :date    (7 20)
     :rank    lesser
     :vigil   nil)

    (mary-magdalene
     :name    "Mary Magdalene"
     :date    (7 22)
     :rank    lesser
     :vigil   nil)

    (james
     :name    "James, Apostle"
     :date    (7 25)
     :rank    greater
     :vigil   t)

    (anne
     :name    "Anne, Mother of the Blessed Virgin Mary"
     :date    (7 26)
     :rank    lesser
     :vigil   nil)

    ;; ---- August ----
    (lammas
     :name    "Lammas Day"
     :date    (8 1)
     :rank    lesser
     :vigil   nil)

    (transfiguration
     :name    "Transfiguration of our Lord"
     :date    (8 6)
     :rank    lesser
     :vigil   nil)

    (name-of-jesus
     :name    "Name of Jesus"
     :date    (8 7)
     :rank    lesser
     :vigil   nil)

    (laurence
     :name    "Laurence, Martyr"
     :date    (8 10)
     :rank    lesser
     :vigil   nil)

    (bartholomew
     :name    "Bartholomew, Apostle"
     :date    (8 24)
     :rank    greater
     :vigil   t)

    (augustine-hippo
     :name    "Augustine of Hippo, Bishop"
     :date    (8 28)
     :rank    lesser
     :vigil   nil)

    (john-beheading
     :name    "Beheading of John the Baptist"
     :date    (8 29)
     :rank    lesser
     :vigil   nil)

    ;; ---- September ----
    (giles
     :name    "Giles, Abbot"
     :date    (9 1)
     :rank    lesser
     :vigil   nil)

    (enurchus
     :name    "Enurchus, Bishop"
     :date    (9 7)
     :rank    lesser
     :vigil   nil)

    (nativity-bvm
     :name    "Nativity of the Blessed Virgin Mary"
     :date    (9 8)
     :rank    lesser
     :vigil   nil)

    (holy-cross
     :name    "Holy Cross Day"
     :date    (9 14)
     :rank    lesser
     :vigil   nil)

    (lambert
     :name    "Lambert, Bishop"
     :date    (9 17)
     :rank    lesser
     :vigil   nil)

    (matthew
     :name    "Matthew, Apostle and Evangelist"
     :date    (9 21)
     :rank    greater
     :vigil   t)

    (cyprian
     :name    "Cyprian, Archbishop"
     :date    (9 26)
     :rank    lesser
     :vigil   nil)

    (michael
     :name    "Michael and All Angels"
     :date    (9 29)
     :rank    greater
     :vigil   nil)

    (jerome
     :name    "Jerome, Presbyter"
     :date    (9 30)
     :rank    lesser
     :vigil   nil)

    ;; ---- October ----
    (remigius
     :name    "Remigius, Bishop"
     :date    (10 1)
     :rank    lesser
     :vigil   nil)

    (faith
     :name    "Faith, Virgin and Martyr"
     :date    (10 6)
     :rank    lesser
     :vigil   nil)

    (denys
     :name    "Denys, Bishop"
     :date    (10 9)
     :rank    lesser
     :vigil   nil)

    (edward-translation
     :name    "Translation of King Edward"
     :date    (10 13)
     :rank    lesser
     :vigil   nil)

    (etheldreda
     :name    "Etheldreda, Virgin"
     :date    (10 17)
     :rank    lesser
     :vigil   nil)

    (luke
     :name    "Luke, Evangelist"
     :date    (10 18)
     :rank    greater
     :vigil   nil)

    (crispin
     :name    "Crispin, Martyr"
     :date    (10 25)
     :rank    lesser
     :vigil   nil)

    (simon-and-jude
     :name    "Simon and Jude, Apostles"
     :date    (10 28)
     :rank    greater
     :vigil   t)

    ;; ---- November ----
    (all-saints
     :name    "All Saints' Day"
     :date    (11 1)
     :rank    greater
     :vigil   t)

    (leonard
     :name    "Leonard, Confessor"
     :date    (11 6)
     :rank    lesser
     :vigil   nil)

    (martin
     :name    "Martin, Bishop"
     :date    (11 11)
     :rank    lesser
     :vigil   nil)

    (britius
     :name    "Britius, Bishop"
     :date    (11 13)
     :rank    lesser
     :vigil   nil)

    (machutus
     :name    "Machutus, Bishop"
     :date    (11 15)
     :rank    lesser
     :vigil   nil)

    (hugh
     :name    "Hugh of Lincoln, Bishop"
     :date    (11 17)
     :rank    lesser
     :vigil   nil)

    (edmund
     :name    "Edmund, King and Martyr"
     :date    (11 20)
     :rank    lesser
     :vigil   nil)

    (cecilia
     :name    "Cecilia, Virgin and Martyr"
     :date    (11 22)
     :rank    lesser
     :vigil   nil)

    (clement
     :name    "Clement, Bishop"
     :date    (11 23)
     :rank    lesser
     :vigil   nil)

    (catherine
     :name    "Catherine, Virgin and Martyr"
     :date    (11 25)
     :rank    lesser
     :vigil   nil)

    (andrew
     :name    "Andrew, Apostle"
     :date    (11 30)
     :rank    greater
     :vigil   t)

    ;; ---- December ----
    (nicolas
     :name    "Nicolas, Bishop"
     :date    (12 6)
     :rank    lesser
     :vigil   nil)

    (conception-bvm
     :name    "Conception of the Blessed Virgin Mary"
     :date    (12 8)
     :rank    lesser
     :vigil   nil)

    (lucy
     :name    "Lucy, Virgin and Martyr"
     :date    (12 13)
     :rank    lesser
     :vigil   nil)

    (o-sapientia
     :name    "O Sapientia"
     :date    (12 16)
     :rank    greater
     :vigil   nil)

    (thomas
     :name    "Thomas, Apostle"
     :date    (12 21)
     :rank    greater
     :vigil   t)

    (christmas
     :name    "Christmas Day"
     :date    (12 25)
     :rank    principal
     :vigil   t)

    (stephen
     :name    "Stephen, Deacon and First Martyr"
     :date    (12 26)
     :rank    greater
     :vigil   nil)

    (john-evangelist
     :name    "John, Apostle and Evangelist"
     :date    (12 27)
     :rank    greater
     :vigil   nil)

    (innocents
     :name    "Innocents' Day"
     :date    (12 28)
     :rank    greater
     :vigil   nil)

    (silvester
     :name    "Silvester, Bishop"
     :date    (12 31)
     :rank    lesser
     :vigil   nil))

  "BCP 1662 feast table.

Each entry: (SYMBOL :name STRING :date (MONTH DAY) :rank RANK :vigil BOOL)

  RANK is `principal', `greater', or `lesser'.
  VIGIL t means the day before is a Fast day (vigil) in the BCP calendar.

Proper lessons (:mattins and :evensong) are not yet included; they will
be added from the Table of Proper Lessons.

Note: Easter, Ascension, Whitsunday, and Trinity Sunday are moveable
feasts handled in bcp-1662-calendar.el and do not appear here.")

(defun bcp-1662-feast-data (symbol)
  "Return the data plist for feast SYMBOL, or nil."
  (cdr (assq symbol bcp-1662-feast-data)))

(defun bcp-1662-feast-rank (symbol)
  "Return the rank of feast SYMBOL: `principal', `greater', `lesser', or nil."
  (plist-get (bcp-1662-feast-data symbol) :rank))

(defun bcp-1662-feast-date (symbol)
  "Return the fixed date of feast SYMBOL as (MONTH DAY), or nil."
  (plist-get (bcp-1662-feast-data symbol) :date))

(defun bcp-1662-feast-has-vigil-p (symbol)
  "Return t if feast SYMBOL is preceded by a Fast (vigil) day."
  (plist-get (bcp-1662-feast-data symbol) :vigil))

(defun bcp-1662-feasts-for-date (month day)
  "Return a list of feast symbols whose fixed date is (MONTH DAY)."
  (cl-remove-if-not
   (lambda (entry)
     (let ((date (plist-get (cdr entry) :date)))
       (and date
            (= (car date) month)
            (= (cadr date) day))))
   bcp-1662-feast-data))

(defun bcp-1662-vigil-p (month day)
  "Return the feast symbol if (MONTH DAY) is a vigil (Fast) day, else nil.

A vigil is the day immediately before a feast that has :vigil t."
  (cl-some
   (lambda (entry)
     (when (plist-get (cdr entry) :vigil)
       (let* ((sym   (car entry))
              (date  (plist-get (cdr entry) :date))
              (fmonth (car date))
              (fday   (cadr date))
              (feast-abs (calendar-absolute-from-gregorian
                          (list fmonth fday 2000)))  ; year arbitrary
              (vigil-abs (1- feast-abs))
              (vigil-date (calendar-gregorian-from-absolute vigil-abs))
              (vmonth (car vigil-date))
              (vday   (cadr vigil-date)))
         (when (and (= month vmonth) (= day vday))
           sym))))
   bcp-1662-feast-data))

(provide 'bcp-1662-calendar)
;;; bcp-1662-calendar.el ends here
