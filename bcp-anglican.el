;;; bcp-anglican.el --- Anglican Office dispatcher -*- lexical-binding: t -*-

;;; Commentary:

;; Dispatcher for the Anglican Daily Office.  Provides a single entry point
;; `bcp-anglican-open-office' that routes to the implementation registered
;; for `bcp-anglican-rubrics'.
;;
;; Currently registered implementations:
;;   '1662 — BCP 1662 (bcp-1662.el)
;;
;; Planned:
;;   '1928 — BCP 1928 American (bcp-anglican-1928-)
;;   '1979 — BCP 1979 American (bcp-anglican-1979-)
;;
;; Each implementation registers itself via:
;;   (bcp-liturgy-register-tradition 'anglican RUBRICS #'its-open-office-fn)

;;; Code:

(require 'bcp-liturgy-dispatch)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Configuration

(defgroup bcp-anglican nil
  "Anglican Daily Office dispatcher."
  :prefix "bcp-anglican-"
  :group 'bcp-liturgy)

(defcustom bcp-anglican-rubrics '1662
  "Active rubrics for the Anglican Daily Office.
Determines which prayer book implementation is used when
`bcp-anglican-open-office' is called.
Currently only \\='1662 is implemented."
  :type  '(choice (const 1662)
                  (const 1928)
                  (const 1979))
  :group 'bcp-anglican)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Entry point

(defun bcp-anglican-open-office (&optional arg)
  "Open the Anglican Daily Office using the rubrics in `bcp-anglican-rubrics'.
With a prefix argument ARG, prompts for date and office."
  (interactive "P")
  (bcp-liturgy-dispatch 'anglican bcp-anglican-rubrics arg))

(provide 'bcp-anglican)
;;; bcp-anglican.el ends here
