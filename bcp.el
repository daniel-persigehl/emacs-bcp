;;; bcp.el --- Book of Common Prayer Daily Office package -*- lexical-binding: t -*-

;;; Commentary:

;; Entry point for the BCP package.  Wires together the modules,
;; defines `bcp-reload' and `bcp-reset', and applies the active
;; language profile.
;;
;; Usage:
;;   (require 'bcp)
;;   M-x bcp-settings    ; configure via menu, press S to save
;;
;; Power users can drop a `bcp-preferences.el' anywhere on the
;; load-path; it will be auto-loaded after the package bootstrap.
;; Use `bcp-pref' (preferred) or `setq' inside it; `bcp-pref' yields
;; to anything the user has saved through `bcp-settings', while
;; `setq' overrides Customize unconditionally.  The file is purely
;; optional — the menu's Save action persists everything to your
;; `custom-file' on its own.

;;; Code:

(require 'cl-lib)
(require 'bcp-notebook)
(require 'bcp-profile)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Package directory

(defvar bcp--package-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing the BCP package files.  Set at load time.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Preference helper for `bcp-preferences.el'

(eval-and-compile
  (defun bcp-pref (var val)
    "Set VAR to VAL unless the user has customised it via Customize.
Use this inside `bcp-preferences.el' to declare scripted defaults
that yield to anything saved via `bcp-settings' → Save.  Plain
`setq' always wins over Customize and is appropriate when you want
the file to override interactive customisation."
    (unless (or (get var 'saved-value)
                (get var 'customized-value))
      (set-default var val))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Reload / reset

(defun bcp--reload-modules (refire-preferences)
  "Internal: reload all BCP package modules.
When REFIRE-PREFERENCES is non-nil, also clear the `bcp-preferences'
feature so its `setq'/`bcp-pref' forms run again on reload.  When
nil, the feature is preserved and `bcp-preferences.el' is not
re-evaluated, leaving current variable values untouched.  Returns
the count of reloaded module files."
  (let* ((dir bcp--package-directory)
         (load-prefer-newer t)
         (all (directory-files dir nil "\\`bcp\\(-.*\\)?\\.el\\'"))
         (excludes (if refire-preferences
                       '("bcp.el")
                     '("bcp.el" "bcp-preferences.el")))
         (files (cl-set-difference all excludes :test #'string=)))
    ;; Clear features for everything we are about to load, plus bcp.el.
    (dolist (file (cons "bcp.el" files))
      (setq features (delq (intern (file-name-sans-extension file)) features)))
    ;; Load the discovered modules.
    (dolist (file files)
      (load (file-name-sans-extension (expand-file-name file dir)) nil t))
    ;; bcp.el last (re-runs the `(require 'bcp-preferences nil 'noerror)' at
    ;; its tail; that require is a no-op when REFIRE-PREFERENCES is nil since
    ;; we left the feature in place).
    (load (file-name-sans-extension
           (expand-file-name "bcp.el" dir)) nil t)
    ;; Drop lazy-loaded psalter/Bible caches.
    (when (fboundp 'bcp-fetcher-clear-cache)
      (bcp-fetcher-clear-cache))
    ;; Reset the unified hymn store so corpus exporters re-run.
    (when (boundp 'bcp-hymnal--texts)
      (setq bcp-hymnal--texts nil))
    (length files)))

(defun bcp-reload ()
  "Reload BCP package modules without re-applying user preferences.
Picks up code changes while preserving menu-saved settings and
in-session edits.  Use `bcp-reset' to revert to scripted defaults."
  (interactive)
  (let ((n (bcp--reload-modules nil)))
    (message "BCP reloaded (%d modules; preferences preserved)." (1+ n))))

(defun bcp-reset ()
  "Re-apply scripted defaults from `bcp-preferences.el' and reload.
Discards in-session changes to variables that the file sets, and
applies its `setq' forms unconditionally (its `bcp-pref' forms still
yield to Customize-saved values)."
  (interactive)
  (let ((n (bcp--reload-modules t)))
    (message "BCP reset to scripted defaults (%d modules)." (1+ n))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Optional user config
;;
;; If a `bcp-preferences.el' is on the load-path, load it now so its
;; `setq'/`bcp-pref' forms can override `defcustom' defaults before
;; the profile is applied.  Silently no-ops when no such file exists.
;;
;; Order of precedence:
;;   1. plain `setq' in bcp-preferences.el      (always wins)
;;   2. Customize-saved values (via custom-file, applied at startup)
;;   3. `bcp-pref' in bcp-preferences.el        (yields to Customize)
;;   4. `defcustom' default

(require 'bcp-preferences nil 'noerror)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Apply language profile (must run after all overrides above)

(bcp-profile-apply)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Transient settings menu

(require 'bcp-transient)

(provide 'bcp)
;;; bcp.el ends here
