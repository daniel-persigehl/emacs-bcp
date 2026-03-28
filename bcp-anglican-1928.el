;;; bcp-anglican-1928.el --- 1928 American BCP Daily Office -*- lexical-binding: t -*-

;;; Commentary:

;; Main entry point for the 1928 American Book of Common Prayer Daily
;; Office implementation.
;;
;; Domain: bcp-anglican-1928-
;;
;; File plan:
;;   bcp-anglican-1928-ordo.el      — ordos (DONE)
;;   bcp-anglican-1928-calendar.el  — feast days, rankings, lectionary (TODO)
;;   bcp-anglican-1928-data.el      — lesson table, collect table (TODO)
;;   bcp-anglican-1928-render.el    — office renderer (TODO)
;;   bcp-anglican-1928.el           — entry point, open-office fn (this file)
;;
;; Depends on:
;;   bcp-calendar.el          — computus, rank taxonomy (shared)
;;   bcp-common-prayers.el    — Lord's Prayer (1928 form), Nicene Creed, etc.
;;   bcp-common-anglican.el   — 1928 sentences, state prayers, collects
;;   bcp-liturgy-canticles.el — canticle registry (Benedictus es Domine needed)
;;   bcp-liturgy-dispatch.el  — rite dispatcher
;;
;; TODO: bcp-liturgy-canticles.el needs a Benedictus es Domine entry
;;   (Dan 3:29-34, 52-56 in traditional Anglican versification).
;;
;; TODO: The 1928 calendar differs from 1662 in several feasts (adds
;;   Independence Day, Thanksgiving Day as proper feasts) and uses a
;;   different lectionary.  Implement bcp-anglican-1928-calendar.el and
;;   bcp-anglican-1928-data.el before wiring up the renderer.

;;; Code:

(require 'bcp-liturgy-dispatch)
(require 'bcp-anglican-1928-ordo)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Entry point (stub — renderer not yet implemented)

(defun bcp-anglican-1928-open-office (&optional _arg)
  "Open the 1928 American BCP Daily Office.
Not yet implemented: calendar, lectionary, and renderer are pending."
  (interactive "P")
  (error "1928 BCP Office not yet implemented"))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Dispatcher registration

(bcp-liturgy-register-tradition 'anglican '1928 #'bcp-anglican-1928-open-office)

(provide 'bcp-anglican-1928)
;;; bcp-anglican-1928.el ends here
