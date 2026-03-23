;;; bcp-preferences.el --- User preferences for the BCP package -*- lexical-binding: t -*-

;;; Commentary:

;; Single place to configure the bible-commentary package and all
;; associated Daily Office modules (bcp-1662, and future traditions).
;;
;; Load this file after all package files are loaded, or place
;; individual settings directly in your init.el instead.
;;
;; Load order in init.el:
;;   (require 'bible-fetcher)        ; core fetch/parse layer — load first
(require 'bcp-notebook)
;;   (require 'bcp-1662-calendar)
;;   (require 'bcp-1662-data)
;;   (require 'bcp-1662-user-feasts)
;;   (require 'bcp-1662)
;;   (load "bcp-preferences.el")  ; or setq in init.el

;;; Code:

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Translation preferences

;; Translation used for all lessons, epistles, and gospels.
;; Supported values (via Oremus):
;;   "KJVA"    — King James Version with Apocrypha (recommended for 1662 BCP)
;;   "KJV"     — King James Version (Protestant canon only)
;;   "NRSV"    — New Revised Standard Version (US spelling)
;;   "NRSVAE"  — NRSV Anglicized Edition (British spelling)
(setq bible-commentary-translation "KJVA")

;; Translation used for the Psalter.
;; Supported values (via Oremus):
;;   "Coverdale" — Miles Coverdale's Psalter as in the BCP 1662 (recommended)
;;   "BCP"       — Alias for Coverdale
;;   "KJVA"      — KJV Psalms
;;   "CW"        — Common Worship Psalter (Church of England, 2000)
;;   "LP"        — Liturgical Psalter (ASB 1980)
;;   "NRSV"      — NRSV Psalms
;; For Latin: add ("Vulgate" . "VUL") to bible-commentary-oremus-version-codes
;; and set this to "Vulgate" — see Oremus documentation for availability.
(setq bible-commentary-psalm-translation "Coverdale")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Local file paths (optional — Oremus used as fallback if nil)

;; Path to a local plain-text Bible file (KJVA recommended).
;; If nil, all passages are fetched from Oremus.
(setq bible-commentary-bible-file nil)

;; Path to a local plain-text Coverdale Psalter.
;; If nil, psalms are fetched from Oremus using bible-commentary-psalm-translation.
(setq bible-commentary-coverdale-file nil)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Commentary file

;; Path to your master Org commentary file.
(setq bible-commentary-file (expand-file-name "~/bible-commentary.org"))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Bible commentary display

;; Window layout: 'side-by-side or 'top-bottom
(setq bible-commentary-window-layout 'side-by-side)

;; Non-nil: scrolling either buffer proportionally scrolls the other.
(setq bible-commentary-sync-scroll t)

;; Non-nil: use org-roam nodes and backlinks when org-roam is loaded.
(setq bible-commentary-use-roam t)

;; Key used in org-capture-templates for quick marginal notes.
(setq bible-commentary-capture-key "B")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daily Office — general

;; Non-nil: include Communion propers (OT lesson, Epistle, Gospel)
;; in the Daily Office buffer.
(setq bcp-1662-show-communion-propers t)

;; Name of the Daily Office buffer.
(setq bcp-1662-office-buffer-name "*BCP 1662 Daily Office*")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daily Office — rendering

;; Whether to append Gloria Patri after each canticle and psalm.
;; Disabled by default for private recitation.
(setq bcp-liturgy-canticle-append-gloria nil)

;; Default language for canticles: 'english or 'latin
;; (Latin texts are nil until supplied; falls back to English automatically)
(setq bcp-liturgy-canticle-language 'english)

;; Per-canticle language overrides — e.g. Latin Te Deum with English Benedictus:
;; (setq bcp-liturgy-canticle-overrides '((te-deum . latin)))
(setq bcp-liturgy-canticle-overrides nil)

;; Style for rubric text in the Office buffer.
;; `red'     — traditional liturgical red (default; dark red on light themes,
;;             indian red on dark themes)
;; `comment' — inherits font-lock-comment-face (muted grey, fully theme-aware)
(setq bcp-1662-rubric-style 'red)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daily Office — officiant

;; The order of the officiant.  Affects absolution form and may affect
;; other rubrics in future ordos.
;; Options: 'lay 'deacon 'priest 'bishop
(setq office-officiant 'lay)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daily Office — rubrical options (1662 BCP)

;; Omit the penitential introduction (opening sentences through absolution)
;; on weekdays.  Off by default.
(setq bcp-1662-omit-penitential-intro nil)

;; Prepend a seasonal sentence before the penitential sentences.
;; On by default; seasonal texts are nil until supplied.
(setq bcp-1662-use-seasonal-sentences t)

;; Form of the General Confession:
;; nil (default) — standard 1662 text
;; 'omit         — omit entirely
;; 'variant      — ". And apart from thy grace, there is no health in us."
(setq bcp-1662-general-confession-form nil)

;; Form of the Bidding (exhortation "Dearly beloved brethren..."):
;; 'full (default), 'brief (abbreviated text, nil until supplied), 'omit
(setq bcp-1662-bidding-form 'full)

;; Omit Venite verses 8-11 ("To day if ye will hear his voice...")
;; outside Lent and Passiontide.  Off by default.
(setq bcp-1662-omit-venite-passiontide nil)

;; Use Easter Anthems in place of Venite throughout all of Eastertide
;; (not just on Easter Day).  Off by default.
(setq bcp-1662-easter-anthems-throughout-eastertide nil)

;; Additional prayers to append after the five state prayers.
;; Each element is a string or a symbol resolving to a :title/:text plist.
(setq bcp-1662-additional-prayers nil)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daily Office — 1662 BCP specific

;; Hour (0-23) at which Morning Prayer gives way to Evening Prayer.
;; The 1662 BCP has two offices only; other traditions may define
;; their own cutoffs in their respective configuration variables.
(setq bcp-1662-morning-prayer-hour-limit 12)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Reload utility

(defvar bcp--package-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing the BCP package files.  Set at load time.")

(defun bcp-reload ()
  "Reload all BCP package files in dependency order.
Run this after pulling updates to pick up any changed files without
restarting Emacs."
  (interactive)
  (let ((dir bcp--package-directory)
        (files '("bcp-fetcher.el"
                 "bcp-fetcher-oremus.el"
                 "bcp-fetcher-ebible.el"
                 "bcp-calendar.el"
                 "bcp-liturgy-canticles.el"
                 "bcp-liturgy-render.el"
                 "bcp-render.el"
                 "bcp-1662-calendar.el"
                 "bcp-1662-data.el"
                 "bcp-1662-user-feasts.el"
                 "bcp-1662-ordo.el"
                 "bcp-1662-render.el"
                 "bcp-1662.el"
                 "bcp-reader.el"
                 "bcp-notebook.el")))
    (dolist (file files)
      (let ((path (expand-file-name file dir)))
        (when (file-readable-p path)
          (load path nil t))))
    (load (expand-file-name "bcp-preferences.el" dir) nil t)
    (message "BCP reloaded.")))

(provide 'bcp-preferences)
;;; bcp-preferences.el ends here
