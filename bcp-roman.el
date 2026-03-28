;;; bcp-roman.el --- Roman Rite Office dispatcher -*- lexical-binding: t -*-

;;; Commentary:

;; Dispatcher for the Roman Rite Divine Office.  Provides a single entry
;; point `bcp-roman-open-office' that routes to the implementation registered
;; for `bcp-roman-rubrics'.
;;
;; Planned implementations:
;;   '1911 — Roman Breviary, Divino Afflatu / pre-1955 form (bcp-roman-1911-)
;;   '1962 — Roman Breviary, 1962 edition
;;   'monastic — Monastic Breviary
;;
;; Data source for '1911: Divinum Officium project, Divino Afflatu (DA)
;; rubrics.  Importer: bcp-fetcher-officium.el (planned).
;;
;; Each implementation registers itself via:
;;   (bcp-liturgy-register-tradition 'roman RUBRICS #'its-open-office-fn)

;;; Code:

(require 'bcp-liturgy-dispatch)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Configuration

(defgroup bcp-roman nil
  "Roman Rite Divine Office dispatcher."
  :prefix "bcp-roman-"
  :group 'bcp-liturgy)

(defcustom bcp-roman-rubrics '1911
  "Active rubrics for the Roman Rite Divine Office.
Determines which breviary implementation is used when
`bcp-roman-open-office' is called.
No implementations are registered yet."
  :type  '(choice (const 1911)
                  (const 1962)
                  (const monastic))
  :group 'bcp-roman)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Entry point

(defun bcp-roman-open-office (&optional arg)
  "Open the Roman Rite Divine Office using the rubrics in `bcp-roman-rubrics'.
With a prefix argument ARG, prompts for date and office.
Signals an error until a Roman Office implementation is registered."
  (interactive "P")
  (bcp-liturgy-dispatch 'roman bcp-roman-rubrics arg))

(provide 'bcp-roman)
;;; bcp-roman.el ends here
