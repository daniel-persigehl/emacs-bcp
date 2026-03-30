;;; bcp-liturgy-hours.el --- Canonical hours framework -*- lexical-binding: t -*-

;;; Commentary:

;; A rite-agnostic library defining the eight canonical hours and a
;; time-to-hour lookup function for the BCP package.  Contains no
;; references to any specific prayer book edition or ordo.
;;
;; The canonical hours are indexed by symbol and ordered by start time.
;; Any rite-specific module (e.g. bcp-1662) may group canonical hours
;; into its own offices (e.g. mattins/evensong) via its own alist, and
;; register that grouping here so navigation and other generic code can
;; query it without knowing the rite module.
;;
;; User configuration:
;;   `bcp-canonical-hours'  — alist of (CANONICAL-HOUR . START-HOUR)
;;
;; Primary public functions:
;;   `bcp-canonical-hour-from-time'      — given clock hour 0-23, return symbol
;;   `bcp-liturgy-register-hour-grouping' — register a rite's hour-to-office map
;;   `bcp-liturgy-hour-grouping'          — retrieve a registered grouping

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-liturgy-hours nil
  "Canonical hours time boundaries."
  :prefix "bcp-canonical-"
  :group 'bcp-liturgy)

(defcustom bcp-canonical-hours
  '((matins   . 0)
    (lauds    . 5)
    (prime    . 6)
    (terce    . 9)
    (sext     . 12)
    (none     . 15)
    (vespers  . 18)
    (compline . 21))
  "Alist of (CANONICAL-HOUR . START-HOUR) defining the eight canonical hours.
START-HOUR is the clock hour (0-23) at which that hour begins.
The list must be sorted by START-HOUR in ascending order.

`bcp-canonical-hour-from-time' finds the last entry whose START-HOUR
is <= the given clock hour."
  :type  '(alist :key-type symbol :value-type integer)
  :group 'bcp-liturgy-hours)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-canonical-hour-from-time (clock-hour)
  "Return the canonical hour symbol for CLOCK-HOUR (0-23).
Scans `bcp-canonical-hours' for the last entry whose start time is <=
CLOCK-HOUR.  If CLOCK-HOUR is before the first entry's start time,
returns the last canonical hour (wrapping from the previous day).
Returns a symbol such as \\='matins, \\='lauds, \\='prime, \\='terce,
\\='sext, \\='none, \\='vespers, or \\='compline."
  (let ((result nil))
    (dolist (entry bcp-canonical-hours)
      (when (<= (cdr entry) clock-hour)
        (setq result (car entry))))
    (or result (caar (last bcp-canonical-hours)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Hour-grouping registry

(defvar bcp-liturgy--hour-grouping-registry nil
  "Alist of (RITE . GROUPING-ALIST) registered by rite modules.
Each GROUPING-ALIST maps canonical hour symbols to tradition-specific
office symbols (e.g. \\='mattins, \\='evensong).
Populated via `bcp-liturgy-register-hour-grouping'.")

(defun bcp-liturgy-register-hour-grouping (rite grouping)
  "Register GROUPING as the canonical-hour mapping for RITE.
RITE is an arbitrary identifier (typically a symbol).
GROUPING is an alist of (CANONICAL-HOUR . OFFICE-SYMBOL)."
  (setf (alist-get rite bcp-liturgy--hour-grouping-registry nil nil #'equal)
        grouping))

(defun bcp-liturgy-hour-grouping (rite)
  "Return the hour-grouping alist for RITE, or nil if not registered."
  (alist-get rite bcp-liturgy--hour-grouping-registry nil nil #'equal))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Built-in hour groupings

(bcp-liturgy-register-hour-grouping
 'roman-lobvm
 '((matins   . matins)
   (lauds    . lauds)
   (prime    . prime)
   (terce    . terce)
   (sext     . sext)
   (none     . none)
   (vespers  . vespers)
   (compline . compline)))

(provide 'bcp-liturgy-hours)
;;; bcp-liturgy-hours.el ends here
