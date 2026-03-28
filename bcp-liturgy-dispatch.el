;;; bcp-liturgy-dispatch.el --- Rite dispatcher protocol -*- lexical-binding: t -*-

;;; Commentary:

;; A rite-agnostic registry and dispatcher for liturgical Office implementations.
;; Each tradition module registers itself with a rite key, a rubrics key, and
;; a single open-office function.  Rite-family dispatchers (bcp-anglican.el,
;; bcp-roman.el) call `bcp-liturgy-dispatch' with the configured rubrics to
;; invoke the appropriate implementation.
;;
;; Registration:
;;   (bcp-liturgy-register-tradition RITE RUBRICS FN)
;;
;;   RITE    — symbol identifying the rite family (e.g. 'anglican, 'roman)
;;   RUBRICS — symbol identifying the edition/rubrics (e.g. '1662, '1911)
;;   FN      — function (interactive command) to open the Office; receives
;;             one optional argument (prefix arg) forwarded from the dispatcher
;;
;; Dispatch:
;;   (bcp-liturgy-dispatch RITE RUBRICS &optional ARG)
;;
;;   Looks up the registered function for (RITE . RUBRICS) and calls it
;;   with ARG.  Signals an error if no implementation is registered.

;;; Code:

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Registry

(defvar bcp-liturgy--tradition-registry nil
  "Alist mapping (RITE . RUBRICS) to open-office functions.
Do not modify directly; use `bcp-liturgy-register-tradition'.")

(defun bcp-liturgy-register-tradition (rite rubrics fn)
  "Register FN as the open-office function for RITE with RUBRICS.
RITE and RUBRICS are symbols.  FN is called with one optional argument
\(the prefix arg) when the office is opened via the dispatcher.
Registering the same (RITE . RUBRICS) pair twice replaces the first entry."
  (let ((key (cons rite rubrics)))
    (setf (alist-get key bcp-liturgy--tradition-registry nil nil #'equal) fn)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Dispatch

(defun bcp-liturgy-dispatch (rite rubrics &optional arg)
  "Open the Office for RITE and RUBRICS, passing ARG to the registered function.
Signals an error if no implementation has been registered for the combination."
  (let* ((key (cons rite rubrics))
         (fn  (alist-get key bcp-liturgy--tradition-registry nil nil #'equal)))
    (if fn
        (funcall fn arg)
      (error "No Office implementation registered for rite '%s' with rubrics '%s'"
             rite rubrics))))

(provide 'bcp-liturgy-dispatch)
;;; bcp-liturgy-dispatch.el ends here
