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

(require 'bcp-profile)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Language profile
;;
;; The language profile sets all scripture and language defaults at once.
;; Use `bcp-settings' (M-x bcp-settings) → Language → Advanced to
;; override individual settings.
;;
;; Profiles: ENG (English/Coverdale/KJVA), LAT (Latin/Vulgate),
;;           JAP (Japanese/Bungo-yaku)
(setq bcp-language-profile 'LAT)

;; Per-setting overrides (set to 'default to inherit from the profile):
;; (setq bcp-profile-lesson-translation 'default)
;; (setq bcp-profile-psalm-translation  'default)
;; (setq bcp-profile-backend            'default)
;; (setq bcp-profile-fallback-backend   'default)
;; (setq bcp-profile-roman-language     'default)
;; (setq bcp-profile-canticle-language  'default)
;; (setq bcp-profile-canticle-gloria    'default)
;; (setq bcp-profile-furigana           'default)

;; Path to the local Coverdale Psalter file (auto-detected by default).
;; Override only if you keep the file in a non-standard location:
;; (setq bcp-fetcher-coverdale-file "/path/to/bcp-liturgy-psalter-coverdale.txt")

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
;;;; Daily Office — tradition

;; Anglican rubrics to use when opening the Office via bcp-anglican-open-office.
(setq bcp-anglican-rubrics '1662)

;;;; Daily Office — general

;; Non-nil: include Communion propers (OT lesson, Epistle, Gospel)
;; in the Daily Office buffer.
(setq bcp-1662-show-communion-propers t)

;; Name of the Daily Office buffer.
(setq bcp-1662-office-buffer-name "*BCP 1662 Daily Office*")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daily Office — rendering

;; Gloria Patri and canticle language are now governed by the language
;; profile.  Override via bcp-profile-canticle-gloria and
;; bcp-profile-canticle-language (see above).

;; Creed used at Morning and Evening Prayer.
;; 'apostles (default) or 'nicene (1928 rubrical option; no effect on 1662 BCP)
(setq bcp-liturgy-creed 'apostles)

;; Per-canticle language overrides — e.g. Latin Te Deum with English Benedictus:
;; (setq bcp-liturgy-canticle-overrides '((te-deum . latin)))
(setq bcp-liturgy-canticle-overrides nil)

;; Style for rubric text in the Office buffer.
;; `red'     — traditional liturgical red (default; dark red on light themes,
;;             indian red on dark themes)
;; `comment' — inherits font-lock-comment-face (muted grey, fully theme-aware)
(setq bcp-1662-rubric-style 'red)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daily Office — region

;; Region for state prayer selection (controls which prayers are said after the Office).
;; 'monarchy  — pray for the King and Royal Family (default; BCP 1662 / Commonwealth)
;; 'us        — pray for the President (uses 1928 American BCP wording)
;; 'republic  — generic prayer for civil authority (other republics)
(setq bcp-liturgy-region 'us)

;; Form of the civil-authority versicle in the Preces.
;; Independent of region — choose on theological grounds:
;; 'monarchy       — "O Lord, save the King." (or Queen per bcp-liturgy-sovereign-title)
;; 'state          — "O Lord, save the State."  (1928 American republican form)
;; 'them-that-rule — "O Lord, save them that rule."  (1662 international form)
(setq bcp-liturgy-state-versicle-form 'state)

;; Sovereign title, used when bcp-liturgy-state-versicle-form is 'monarchy.
;; 'king or 'queen — controls both versicle and prayer selection.
(setq bcp-liturgy-sovereign-title 'king)

;; Sovereign's Christian name, inserted into the prayer as "King [NAME]" / "Queen [NAME]".
;; nil uses the name hard-coded in the defconst.
(setq bcp-liturgy-sovereign-name "Charles")

;; Royal family members named in the prayer, before "and all the Royal Family".
;; nil uses the names hard-coded in the defconst.
(setq bcp-liturgy-royal-family-names
      "Queen Camilla, William Prince of Wales, the Princess of Wales")

;; Name of the current President, inserted per the 1928 rubric N.
;; Set to nil to omit, or a string e.g. "Donald".
(setq bcp-liturgy-president-name "Donald")

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

;; Opening sentence selection mode:
;;   'auto — engine picks one sentence appropriate to the day (default)
;;   'all  — all sentences in the active corpus are read
(setq bcp-1662-opening-sentence-selection 'auto)

;; Opening sentence corpus:
;;   '1662     — only the eleven penitential sentences from the BCP 1662 (default)
;;   'extended — prefer a seasonal sentence when one is defined in
;;               `bcp-1662-seasonal-sentences'; fall back to the 1662 sentences
(setq bcp-1662-opening-sentence-corpus '1662)

;; Form of the General Confession:
;; nil (default) — standard 1662 text
;; 'omit         — omit entirely
;; 'variant      — ". And apart from thy grace, there is no health in us."
(setq bcp-1662-general-confession-form nil)

;; Form of the Bidding (exhortation "Dearly beloved brethren..."):
;; 'full (default), 'brief ("Let us humbly confess..." — 1928 BCP alternate rubric), 'omit
(setq bcp-1662-bidding-form 'full)

;; Venite vv.8-11 ("To day if ye will hear his voice...").
;; Values: 'always 'lent 'never.  Ps.96 substitute: t or nil.
(setq bcp-1662-venite-lent-verses 'always)
(setq bcp-1662-venite-ps96-substitute nil)
(setq bcp-1928-venite-lent-verses 'lent)
(setq bcp-1928-venite-ps96-substitute t)

;; Use Easter Anthems in place of Venite throughout all of Eastertide
;; (not just on Easter Day).  Off by default.
(setq bcp-1662-easter-anthems-throughout-eastertide nil)

;; Additional prayers to append after the five state prayers.
;; Each element is a string or a symbol resolving to a :title/:text plist.
(setq bcp-1662-additional-prayers nil)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daily Office — 1662 BCP specific

;; Office selection uses the canonical hours framework by default.
;; Hours matins–none map to Morning Prayer; vespers and compline to Evening Prayer.
;; To revert to the legacy noon cutoff, uncomment:
;; (setq bcp-1662-morning-prayer-hour-limit 12)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Reload utility

(defvar bcp--package-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing the BCP package files.  Set at load time.")

(defun bcp-reload ()
  "Reload all BCP package files, discovering them automatically.
Run this after pulling updates to pick up any changed or new files
without restarting Emacs.  Discovers all bcp-*.el files in the
package directory, clears them from `features', then loads each one.
Internal `require' chains resolve dependency order automatically.
bcp-preferences.el is always loaded last."
  (interactive)
  (let* ((dir bcp--package-directory)
         (load-prefer-newer t)
         (all (directory-files dir nil "\\`bcp-.*\\.el\\'"))
         ;; Exclude bcp-preferences.el — loaded last
         (files (cl-remove "bcp-preferences.el" all :test #'string=)))
    ;; Clear all bcp- features so require chains re-fire
    (dolist (file (cons "bcp-preferences.el" files))
      (setq features (delq (intern (file-name-sans-extension file)) features)))
    ;; Load all discovered files
    (dolist (file files)
      (load (file-name-sans-extension (expand-file-name file dir)) nil t))
    ;; Reload bcp-preferences.el last (picks up this function itself)
    (load (file-name-sans-extension
           (expand-file-name "bcp-preferences.el" dir)) nil t)
    ;; Drop lazy-loaded psalter/Bible caches so updates to the shipped
    ;; text files (Coverdale, Tate & Brady, Vulgate, Bungo-yaku) take effect.
    (when (fboundp 'bcp-fetcher-clear-cache)
      (bcp-fetcher-clear-cache))
    ;; Reset the unified hymn store so corpus exporters re-run with
    ;; whatever new fields (`:meter`, `:tags`, etc.) the reload defined.
    (when (boundp 'bcp-hymnal--texts)
      (setq bcp-hymnal--texts nil))
    (message "BCP reloaded (%d files)." (1+ (length files)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Apply language profile (must run after all overrides above)

(bcp-profile-apply)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Transient settings menu

(require 'bcp-transient)

;; Suggested binding — uncomment and adjust as desired:
;; (global-set-key (kbd "C-c ,") #'bcp-settings)

(provide 'bcp-preferences)
;;; bcp-preferences.el ends here
