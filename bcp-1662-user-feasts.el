;;; bcp-1662-user-feasts.el --- User-defined patronal and custom feasts -*- lexical-binding: t -*-

;; Author: You
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1") (bcp-1662-calendar "0.1.0"))
;; Keywords: bible, bcp, liturgy, calendar, patronal

;;; Commentary:

;; User-defined patronal feasts and custom overrides for the 1662 BCP
;; Daily Office.
;;
;; OCCASION TYPES and their precedence under BCP Rule 3:
;;
;;   parish           — Feast of Title / Dedication of the parish church.
;;                      Highest patronal rank; takes precedence over all
;;                      other greater Holy Days on or transferred to the
;;                      same day.
;;
;;   secondary-parish — Feast of Title of a second cure or chaplaincy.
;;                      Treated as greater; yields to the primary parish
;;                      feast if they conflict.
;;
;;   employer         — Patronal feast of the church by whom one is employed
;;                      (but which is not one's own cure).  Treated as greater
;;                      for the purposes of the Office said in that building,
;;                      but does not travel with the minister.
;;
;;   diocese          — Patron of the diocese.  Treated as greater throughout
;;                      the diocese; takes precedence over personal patrons
;;                      but yields to parish feasts.
;;
;;   personal         — Personal patron saint.  Treated as greater for the
;;                      individual; lowest precedence among patronal types.
;;
;; RANK VALUES:
;;   principal  — displaces everything (not normally used for patronals)
;;   greater    — red-letter day behaviour; transfers under Rules 1 & 2
;;   lesser     — black-letter day behaviour; lapses under Rule 3
;;              — NB: any feast with a patronal occasion is automatically
;;                elevated to at least `greater' per Rule 3 exception
;;
;; FEAST SYMBOLS must match keys in `bcp-1662-feast-data' (the standard BCP
;; feast table, to be implemented) or in `bcp-1662-user-feast-data' below
;; (for feasts not in the 1662 BCP calendar).

;;; Code:

(require 'bcp-1662-calendar)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defcustom bcp-1662-user-feast-list
  '(;; St Luke the Evangelist — Oct 18
    ;; Greater feast in BCP 1662.  Parish feast: takes precedence over all
    ;; other greater Holy Days on or transferred to the same day.
    (luke
     :rank     greater
     :occasion parish)

    ;; Conversion of St Paul — Jan 25
    ;; Greater feast in BCP 1662.  Feast of title of secondary parish.
    (conversion-st-paul
     :rank     greater
     :occasion secondary-parish)

    ;; Augustine of Hippo — Aug 28
    ;; Lesser feast in BCP 1662.  Personal patron; elevated to greater
    ;; per Rule 3 patronal exception.
    (augustine-hippo
     :rank     greater
     :occasion personal)

    ;; Chair of St Peter — Feb 22
    ;; Not in 1662 BCP.  Diocesan patron; treated as greater.
    ;; Lesson data defined in `bcp-1662-user-feast-data' below.
    (chair-of-st-peter
     :rank     greater
     :occasion diocese)

    ;; St William of York — Jun 8
    ;; Not in 1662 BCP.  Patron of employing church; treated as greater
    ;; when Office is said in that building.
    ;; Lesson data defined in `bcp-1662-user-feast-data' below.
    (st-william-of-york
     :rank     greater
     :occasion employer))

  "List of user-defined patronal and elevated feasts.

Each entry: (FEAST-SYMBOL :rank RANK :occasion OCCASION)

  RANK is `principal', `greater', or `lesser'.
  OCCASION is one of: `parish', `secondary-parish', `employer',
  `diocese', `personal'.

The feast symbol must match a key in `bcp-1662-feast-data' (standard
BCP feasts) or `bcp-1662-user-feast-data' (custom feasts below).

Patronal precedence order (highest first):
  parish > diocese > secondary-parish > employer > personal"
  :type  '(repeat sexp)
  :group 'bcp-1662)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Custom feast data (feasts not in the BCP 1662 calendar)

(defconst bcp-1662-user-feast-data
  '(;; Augustine of Hippo — Aug 28
    ;; Lesser in BCP 1662 (black-letter).
    (augustine-hippo
     :name     "Augustine of Hippo, Bishop and Doctor"
     :date     (8 28)
     :rank     lesser
     :mattins  nil
     :evensong nil)

    ;; Chair of St Peter — Feb 22
    ;; Not in 1662 BCP.
    (chair-of-st-peter
     :name     "The Chair of St Peter the Apostle"
     :date     (2 22)
     :rank     lesser
     :mattins  nil
     :evensong nil)

    ;; St William of York — Jun 8
    ;; Not in 1662 BCP.  Archbishop of York, died 1154.
    (st-william-of-york
     :name     "William of York, Archbishop"
     :date     (6 8)
     :rank     lesser
     :mattins  nil
     :evensong nil))

  "Feast data for feasts not in the standard BCP 1662 calendar.

Each entry: (FEAST-SYMBOL KEYWORD VALUE ...)

  :name STRING       — display name
  :date (MONTH DAY)  — fixed calendar date
  :rank SYMBOL       — base rank before patronal elevation
  :mattins PLIST     — (:lesson1 REF :lesson2 REF), or nil
  :evensong PLIST    — (:lesson1 REF :lesson2 REF), or nil

Lessons are nil where no authoritative BCP provision exists.
The dispatch layer will fall back to the Common of Saints when
lessons are nil and bcp-1662-feast-data is available.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Occasion precedence

(defconst bcp-1662--occasion-precedence
  '(parish diocese secondary-parish employer personal)
  "Patronal occasion types in descending order of precedence.")

(defun bcp-1662-occasion-rank (occasion)
  "Return the numeric precedence of OCCASION (lower = higher precedence)."
  (or (cl-position occasion bcp-1662--occasion-precedence) 99))

(defun bcp-1662-higher-occasion-p (occ1 occ2)
  "Return t if OCC1 has higher (or equal) precedence than OCC2."
  (<= (bcp-1662-occasion-rank occ1)
      (bcp-1662-occasion-rank occ2)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Query functions

(defun bcp-1662-user-feast-p (feast-symbol)
  "Return t if FEAST-SYMBOL appears in `bcp-1662-user-feast-list'."
  (and (assq feast-symbol bcp-1662-user-feast-list) t))

(defun bcp-1662-user-feast-plist (feast-symbol)
  "Return the configuration plist for FEAST-SYMBOL, or nil."
  (when-let* ((entry (assq feast-symbol bcp-1662-user-feast-list)))
    (cdr entry)))

(defun bcp-1662-user-feast-rank (feast-symbol)
  "Return the configured rank for FEAST-SYMBOL, or nil if not listed."
  (plist-get (bcp-1662-user-feast-plist feast-symbol) :rank))

(defun bcp-1662-user-feast-occasion (feast-symbol)
  "Return the occasion symbol for FEAST-SYMBOL, or nil."
  (plist-get (bcp-1662-user-feast-plist feast-symbol) :occasion))

(defun bcp-1662-effective-feast-rank (feast-symbol base-rank)
  "Return the effective rank of FEAST-SYMBOL after any patronal elevation.

BASE-RANK is the rank from the standard BCP feast table.
A patronal designation can only elevate a feast, never demote it."
  (let* ((user-rank (bcp-1662-user-feast-rank feast-symbol))
         (rank-order '(principal greater lesser)))
    (if (null user-rank)
        base-rank
      (if (<= (cl-position user-rank rank-order)
              (cl-position base-rank rank-order))
          user-rank
        base-rank))))

(defun bcp-1662-user-feast-for-date (month day)
  "Return a list of user feast symbols whose fixed date is (MONTH DAY).

Checks both `bcp-1662-user-feast-data' (for custom feasts) and
`bcp-1662-user-feast-list' cross-referenced against `bcp-1662-feast-data'
(standard BCP feasts, when that table is available).

Returns a list of symbols, sorted by patronal precedence."
  (let ((found
         (cl-remove-if-not
          (lambda (entry)
            (let ((date (plist-get (cdr entry) :date)))
              (and date
                   (= (car date) month)
                   (= (cadr date) day))))
          bcp-1662-user-feast-data)))
    (sort (mapcar #'car found)
          (lambda (a b)
            (bcp-1662-higher-occasion-p
             (bcp-1662-user-feast-occasion a)
             (bcp-1662-user-feast-occasion b))))))

(defun bcp-1662-user-feast-lessons (feast-symbol office)
  "Return lessons for FEAST-SYMBOL at OFFICE (\\='mattins or \\='evensong).

Looks in `bcp-1662-user-feast-data'.  Returns a plist
(:lesson1 REF :lesson2 REF), or nil if not found."
  (when-let* ((entry (assq feast-symbol bcp-1662-user-feast-data)))
    (plist-get (cdr entry) office)))

(defun bcp-1662-user-feast-name (feast-symbol)
  "Return the display name for FEAST-SYMBOL, or nil."
  (when-let* ((entry (assq feast-symbol bcp-1662-user-feast-data)))
    (plist-get (cdr entry) :name)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Listing / introspection

(defun bcp-1662-list-user-feasts ()
  "Display a summary of all configured patronal and custom feasts."
  (interactive)
  (with-output-to-temp-buffer "*BCP User Feasts*"
    (princ "Configured patronal feasts\n")
    (princ (make-string 50 ?─))
    (princ "\n\n")
    (let ((sorted
           (sort (copy-sequence bcp-1662-user-feast-list)
                 (lambda (a b)
                   (bcp-1662-higher-occasion-p
                    (plist-get (cdr a) :occasion)
                    (plist-get (cdr b) :occasion))))))
      (dolist (entry sorted)
        (let* ((sym      (car entry))
               (rank     (plist-get (cdr entry) :rank))
               (occasion (plist-get (cdr entry) :occasion))
               (udata    (cdr (assq sym bcp-1662-user-feast-data)))
               (name     (or (and udata (plist-get udata :name))
                             (symbol-name sym)))
               (date     (and udata (plist-get udata :date)))
               (date-str (if date
                             (format "%02d/%02d" (car date) (cadr date))
                           "(BCP calendar)")))
          (princ (format "  %-38s  %-12s  %-18s  %s\n"
                         name
                         date-str
                         (symbol-name occasion)
                         (symbol-name rank))))))))

(provide 'bcp-1662-user-feasts)
;;; bcp-1662-user-feasts.el ends here

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Transfer logic (Rule 1 applied to user feasts)

(defun bcp-1662-user-feast-observed-date (feast-symbol year)
  "Return the date on which FEAST-SYMBOL is actually observed in YEAR.

Applies BCP Rule 1: if the feast's fixed date falls on a protected
period (Ash Wednesday, Passiontide, Easter octave, Ascension Day, or
Whitsuntide), it is transferred to the appropriate day.

Transfer targets:
  Ash Wednesday conflict       → Friday after Ash Wednesday
  Passiontide / Easter octave  → Tuesday after Easter 1
  Ascension Day conflict        → Friday after Ascension Day
  Whitsuntide conflict          → Tuesday after Trinity Sunday

Returns (MONTH DAY YEAR) of the observed date."
  (let* ((udata (cdr (assq feast-symbol bcp-1662-user-feast-data)))
         (fixed (plist-get udata :date)))
    (unless fixed
      (error "No fixed date for feast %s" feast-symbol))
    (let* ((month    (car fixed))
           (day      (cadr fixed))
           (feast    (calendar-absolute-from-gregorian (list month day year)))
           (feasts   (bcp-1662-moveable-feasts year))
           (ash      (calendar-absolute-from-gregorian
                      (cdr (assq 'ash-wednesday feasts))))
           (passion  (calendar-absolute-from-gregorian
                      (cdr (assq 'passion-sunday feasts))))
           (easter   (calendar-absolute-from-gregorian
                      (cdr (assq 'easter feasts))))
           (easter-1 (calendar-absolute-from-gregorian
                      (cdr (assq 'easter-1 feasts))))
           (asc      (calendar-absolute-from-gregorian
                      (cdr (assq 'ascension feasts))))
           (whit     (calendar-absolute-from-gregorian
                      (cdr (assq 'whitsunday feasts))))
           (trinity  (calendar-absolute-from-gregorian
                      (cdr (assq 'trinity-sunday feasts)))))
      (cond
       ;; Ash Wednesday itself
       ((= feast ash)
        (calendar-gregorian-from-absolute (+ ash 2)))  ; Friday after Ash Wed

       ;; Passiontide (Passion Sunday through Holy Saturday = easter - 1)
       ;; and Easter octave (Easter Day through Low Sunday)
       ((or (and (>= feast passion) (<= feast (1- easter)))
            (and (>= feast easter) (<= feast easter-1)))
        (calendar-gregorian-from-absolute (+ easter-1 2)))  ; Tuesday after Easter 1

       ;; Ascension Day itself
       ((= feast asc)
        (calendar-gregorian-from-absolute (+ asc 1)))  ; Friday after Ascension
       ;; (Ascension is always Thursday; +1 = Friday)

       ;; Whitsunday through 7 days following
       ((and (>= feast whit) (<= feast (+ whit 7)))
        (calendar-gregorian-from-absolute (+ trinity 2)))  ; Tuesday after Trinity

       ;; No conflict — observed on its fixed date
       (t (list month day year))))))

(defun bcp-1662-user-feasts-for-date (month day year)
  "Return all user feasts observed on (MONTH DAY YEAR) in YEAR.

Accounts for transfers: a feast whose fixed date has been displaced
will appear on its transfer date, not its calendar date.

Returns a list of feast symbols sorted by patronal precedence."
  (let ((observed
         (cl-remove-if-not
          (lambda (entry)
            (let* ((sym  (car entry))
                   (date (bcp-1662-user-feast-observed-date sym year)))
              (and date
                   (= (car date) month)
                   (= (cadr date) day)
                   (= (caddr date) year))))
          ;; Only feasts with fixed dates (custom feasts)
          ;; Standard BCP feasts are handled by the main feast table
          (cl-remove-if-not
           (lambda (e) (plist-get (cdr e) :date))
           bcp-1662-user-feast-data))))
    (sort (mapcar #'car observed)
          (lambda (a b)
            (bcp-1662-higher-occasion-p
             (bcp-1662-user-feast-occasion a)
             (bcp-1662-user-feast-occasion b))))))
