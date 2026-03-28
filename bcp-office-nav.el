;;; bcp-office-nav.el --- Date and canonical-hour navigation for office buffers -*- lexical-binding: t -*-

;;; Commentary:

;; Provides a minor mode and navigation commands for moving forward and
;; backward by one day, or switching canonical hour, within an office
;; buffer — without re-invoking the top-level entry command interactively.
;;
;; Usage:
;;   Call `bcp-office-nav-init' from inside the render callback of any
;;   open-office function, passing the decoded-time used for this render,
;;   the rite identifier, and the zero-argument open-office function to
;;   call for re-renders.
;;
;; Keybindings (active in `bcp-office-nav-mode'):
;;   n  — next day (same canonical hour)
;;   p  — previous day (same canonical hour)
;;   h  — change canonical hour (prompts from `bcp-canonical-hours')
;;
;; The dynamic variable `bcp-office-nav--override-time' is checked by
;; rite open-office functions (e.g. `bcp-1662--current-time') so that
;; navigation commands can supply a new time without triggering the
;; interactive date prompt.

;;; Code:

(require 'bcp-liturgy-hours)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Dynamic override

(defvar bcp-office-nav--override-time nil
  "When non-nil, overrides the current time in rite open-office functions.
Bound dynamically by `bcp-office-nav--rerender' around its open-office call.
Rite modules should check this before falling back to their own time sources.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Buffer-local state

(defvar-local bcp-office-nav--time nil
  "Decoded-time list for the office currently displayed in this buffer.
Set by `bcp-office-nav-init' after each successful render.")

(defvar-local bcp-office-nav--rite nil
  "Rite identifier for the office displayed in this buffer (e.g. \\='bcp-1662).
Reserved for future use by generic navigation UI.")

(defvar-local bcp-office-nav--open-fn nil
  "Zero-argument function that re-renders this office buffer.
Set by `bcp-office-nav-init'.  Navigation commands call it via
`bcp-office-nav--rerender' with `bcp-office-nav--override-time' bound.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Minor mode

(defvar-keymap bcp-office-nav-mode-map
  :doc "Keymap for `bcp-office-nav-mode'."
  "n" #'bcp-office-nav-next-day
  "p" #'bcp-office-nav-prev-day
  "h" #'bcp-office-nav-change-hour)

(define-minor-mode bcp-office-nav-mode
  "Minor mode for date and canonical-hour navigation in office buffers.
\\{bcp-office-nav-mode-map}"
  :lighter " Nav"
  :keymap bcp-office-nav-mode-map)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Initialisation

(defun bcp-office-nav-init (time rite open-fn)
  "Initialise navigation state for the current buffer and enable nav mode.
TIME is the decoded-time list used for this render.
RITE is the rite identifier (e.g. \\='bcp-1662).
OPEN-FN is the zero-argument function that re-renders this office."
  (setq-local bcp-office-nav--time    time
              bcp-office-nav--rite    rite
              bcp-office-nav--open-fn open-fn)
  (bcp-office-nav-mode 1))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Internal helpers

(defun bcp-office-nav--prompt-canonical-hour ()
  "Prompt the user to choose a canonical hour from `bcp-canonical-hours'.
Returns the START-HOUR integer for the chosen hour."
  (let* ((choices (mapcar (lambda (e) (symbol-name (car e))) bcp-canonical-hours))
         (chosen  (completing-read "Canonical hour: " choices nil t))
         (entry   (assq (intern chosen) bcp-canonical-hours)))
    (cdr entry)))

(defun bcp-office-nav--shift-days (time n)
  "Return a decoded-time list N days after TIME (or before, if N is negative)."
  (decode-time (time-add (encode-time time) (days-to-time n))))

(defun bcp-office-nav--rerender (new-time)
  "Re-render the office buffer using NEW-TIME.
Binds `bcp-office-nav--override-time' dynamically so that the open-office
function picks up NEW-TIME from `bcp-1662--current-time' (or its equivalent)
without prompting.  Navigation state is updated when `bcp-office-nav-init'
is called from inside the render callback."
  (let ((bcp-office-nav--override-time new-time))
    (funcall bcp-office-nav--open-fn)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Interactive commands

(defun bcp-office-nav-next-day ()
  "Re-render the office for the next calendar day at the same canonical hour."
  (interactive)
  (unless bcp-office-nav--time
    (user-error "No navigation state; re-open the office first"))
  (bcp-office-nav--rerender
   (bcp-office-nav--shift-days bcp-office-nav--time 1)))

(defun bcp-office-nav-prev-day ()
  "Re-render the office for the previous calendar day at the same canonical hour."
  (interactive)
  (unless bcp-office-nav--time
    (user-error "No navigation state; re-open the office first"))
  (bcp-office-nav--rerender
   (bcp-office-nav--shift-days bcp-office-nav--time -1)))

(defun bcp-office-nav-change-hour ()
  "Re-render the office for the same day at a different canonical hour.
Prompts for a canonical hour from `bcp-canonical-hours' by name."
  (interactive)
  (unless bcp-office-nav--time
    (user-error "No navigation state; re-open the office first"))
  (let* ((new-hour (bcp-office-nav--prompt-canonical-hour))
         (new-time (copy-sequence bcp-office-nav--time)))
    (setf (nth 2 new-time) new-hour)
    (bcp-office-nav--rerender new-time)))

(provide 'bcp-office-nav)
;;; bcp-office-nav.el ends here
