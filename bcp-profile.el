;;; bcp-profile.el --- Language profile system for the BCP package -*- lexical-binding: t -*-

;;; Commentary:

;; A language profile sets sensible defaults for all scripture and
;; liturgical language settings at once.  Individual settings can be
;; overridden via the "Advanced overrides" subpage in bcp-settings,
;; or by setting the override variables directly.
;;
;; Public API:
;;   `bcp-language-profile'     — active profile (defcustom)
;;   `bcp-profile-apply'        — push profile+overrides to real variables
;;   `bcp-profile-reset'        — clear all overrides back to 'default
;;   `bcp-profile-effective'    — return effective value for a setting key
;;
;; Override variables:
;;   `bcp-profile-lesson-translation'
;;   `bcp-profile-psalm-translation'   — also drives `bcp-fetcher-psalter'
;;   `bcp-profile-backend'
;;   `bcp-profile-fallback-backend'
;;   `bcp-profile-roman-language'
;;   `bcp-profile-canticle-language'
;;   `bcp-profile-prayer-language'
;;   `bcp-profile-canticle-gloria'
;;   `bcp-profile-furigana'

;;; Code:

(require 'cl-lib)
(require 'bcp-common-prayers)  ; for bcp-common-prayers-language

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Profile definitions

(defgroup bcp-profile nil
  "Language profile settings for the BCP Daily Office."
  :group 'bcp)

(defconst bcp-profile--definitions
  '((ENG . (:lesson-translation       "KJVA"
            :psalm-translation        "Coverdale"
            :backend                  oremus
            :fallback-backend         oremus
            :roman-language           english
            :canticle-language        english
            :prayer-language          english
            :canticle-gloria          nil
            :furigana                 hidden))
    (ENG-TB . (:lesson-translation    "KJVA"
               :psalm-translation     "Tate & Brady"
               :backend               oremus
               :fallback-backend      oremus
               :roman-language        english
               :canticle-language     english
               :prayer-language       english
               :canticle-gloria       nil
               :furigana              hidden))
    (LAT . (:lesson-translation       "Vulgate"
            :psalm-translation        "Vulgate"
            :backend                  oremus
            :fallback-backend         oremus
            :roman-language           latin
            :canticle-language        latin
            :prayer-language          latin
            :canticle-gloria          t
            :furigana                 hidden))
    (JAP . (:lesson-translation       "Bungo-yaku"
            :psalm-translation        "Bungo-yaku"
            :backend                  bungo-yaku
            :fallback-backend         oremus
            ;; Roman office: bungo activates the fetcher path for scripture
            ;; content (capitula, lessons, psalms, scripture-eligible
            ;; antiphons, NT canticles via :ref) while leaving structural
            ;; texts (hymns, collects, responsories, Marian antiphons,
            ;; headers) in Latin — the office's original tongue surrounds
            ;; vernacular scripture readings.  No Bute-equivalent Bungo
            ;; corpus exists, so non-scripture texts stay Latin.
            ;; BCP side: canticle-language stays English (the BCP's own
            ;; tradition); prayer-language is bungo where the versicle
            ;; registry supplies it.
            :roman-language           bungo
            :canticle-language        english
            :prayer-language          bungo
            :canticle-gloria          nil
            :furigana                 rubi)))
  "Built-in language profile definitions.
Each profile maps setting keywords to their default values.
The active psalter is derived from `:psalm-translation' at apply time.")

(defconst bcp-profile--setting-to-variable
  '((:lesson-translation  . bible-commentary-translation)
    (:psalm-translation   . bible-commentary-psalm-translation)
    (:backend             . bcp-fetcher-backend)
    (:fallback-backend    . bcp-fetcher-fallback-backend)
    (:roman-language      . bcp-roman-office-language)
    (:canticle-language   . bcp-liturgy-canticle-language)
    (:prayer-language     . bcp-common-prayers-language)
    (:canticle-gloria     . bcp-liturgy-canticle-append-gloria)
    (:furigana            . bcp-fetcher-furigana-display))
  "Mapping from profile setting keywords to the real variables they govern.
`bcp-fetcher-psalter' is derived from `:psalm-translation', not listed here.")

(defconst bcp-profile--setting-to-override
  '((:lesson-translation  . bcp-profile-lesson-translation)
    (:psalm-translation   . bcp-profile-psalm-translation)
    (:backend             . bcp-profile-backend)
    (:fallback-backend    . bcp-profile-fallback-backend)
    (:roman-language      . bcp-profile-roman-language)
    (:canticle-language   . bcp-profile-canticle-language)
    (:prayer-language     . bcp-profile-prayer-language)
    (:canticle-gloria     . bcp-profile-canticle-gloria)
    (:furigana            . bcp-profile-furigana))
  "Mapping from profile setting keywords to override variable symbols.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Profile selector

(defcustom bcp-language-profile 'ENG
  "Active language profile.
Sets defaults for scripture translations, fetch backend, office
language, canticle language, and furigana display.  Individual
settings can be overridden in the Advanced Overrides menu."
  :type '(choice (const :tag "English (Coverdale psalter)" ENG)
                 (const :tag "English (Tate & Brady metrical psalter)" ENG-TB)
                 (const :tag "Latin" LAT)
                 (const :tag "Japanese (文語訳)" JAP))
  :group 'bcp-profile)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Override variables — 'default means "inherit from profile"

(defcustom bcp-profile-lesson-translation 'default
  "Override for lesson/epistle/gospel translation, or `default'."
  :type '(choice (const :tag "Profile default" default)
                 (string :tag "Translation name"))
  :group 'bcp-profile)

(defcustom bcp-profile-psalm-translation 'default
  "Override for psalm translation, or `default'."
  :type '(choice (const :tag "Profile default" default)
                 (string :tag "Translation name"))
  :group 'bcp-profile)

(defcustom bcp-profile-backend 'default
  "Override for the primary Bible backend, or `default'.
Psalters are selected separately via `bcp-profile-psalter'."
  :type '(choice (const :tag "Profile default" default)
                 (const bungo-yaku) (const oremus) (const ebible))
  :group 'bcp-profile)

(defcustom bcp-profile-fallback-backend 'default
  "Override for fallback fetch backend, or `default'."
  :type '(choice (const :tag "Profile default" default)
                 (const oremus) (const ebible) (const :tag "None" nil))
  :group 'bcp-profile)

(defcustom bcp-profile-roman-language 'default
  "Override for Roman Office language, or `default'."
  :type '(choice (const :tag "Profile default" default)
                 (const latin) (const english) (const bungo))
  :group 'bcp-profile)

(defcustom bcp-profile-canticle-language 'default
  "Override for canticle language, or `default'."
  :type '(choice (const :tag "Profile default" default)
                 (const english) (const latin))
  :group 'bcp-profile)

(defcustom bcp-profile-prayer-language 'default
  "Override for the language of fixed common-prayer texts, or `default'.
Governs `bcp-common-prayers-language', which controls the language used
for the Lord's Prayer, Apostles' Creed, Gloria Patri, the Grace, the
Oremus bidding, and the BCP versicle/preces inventory."
  :type '(choice (const :tag "Profile default" default)
                 (const english) (const latin) (const bungo))
  :group 'bcp-profile)

(defcustom bcp-profile-canticle-gloria 'default
  "Override for appending Gloria Patri after canticles, or `default'."
  :type '(choice (const :tag "Profile default" default)
                 (const :tag "Yes" t) (const :tag "No" nil))
  :group 'bcp-profile)

(defcustom bcp-profile-furigana 'default
  "Override for furigana display mode, or `default'."
  :type '(choice (const :tag "Profile default" default)
                 (const normal) (const comment) (const hidden)
                 (const :tag "Overhead rubi" rubi))
  :group 'bcp-profile)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Resolution and application

(defun bcp-profile-effective (setting)
  "Return the effective value of SETTING (a keyword like :lesson-translation).
If the override variable is `default', returns the profile's value."
  (let* ((override-sym (cdr (assq setting bcp-profile--setting-to-override)))
         (override (when override-sym (symbol-value override-sym))))
    (if (eq override 'default)
        (plist-get (cdr (assq bcp-language-profile bcp-profile--definitions))
                   setting)
      override)))

(defun bcp-profile-apply ()
  "Set all governed variables from the active profile and overrides.
Call this after changing `bcp-language-profile' or any override variable."
  (interactive)
  (dolist (entry bcp-profile--setting-to-variable)
    (let ((setting (car entry))
          (real-var (cdr entry)))
      (set real-var (bcp-profile-effective setting))))
  ;; Derive the active psalter from the psalm translation: if a registered
  ;; psalter serves that translation, route through it; otherwise the Bible
  ;; backend serves psalms directly.
  (when (fboundp 'bcp-fetcher--psalter-for-translation)
    (set 'bcp-fetcher-psalter
         (bcp-fetcher--psalter-for-translation
          (bcp-profile-effective :psalm-translation))))
  ;; Auto-promote furigana when backend is bungo-yaku but furigana would
  ;; be hidden and the user hasn't explicitly overridden it.
  (when (and (eq (symbol-value 'bcp-fetcher-backend) 'bungo-yaku)
             (eq (symbol-value 'bcp-fetcher-furigana-display) 'hidden)
             (eq bcp-profile-furigana 'default)
             (not (eq bcp-language-profile 'JAP)))
    (set 'bcp-fetcher-furigana-display 'rubi))
  ;; Clear cache since backend/translation may have changed
  (when (fboundp 'bcp-fetcher-clear-cache)
    (bcp-fetcher-clear-cache))
  (message "Language profile: %s%s"
           bcp-language-profile
           (let ((overrides (cl-count-if-not
                             (lambda (e)
                               (eq (symbol-value (cdr e)) 'default))
                             bcp-profile--setting-to-override)))
             (if (zerop overrides) ""
               (format " (%d override%s)" overrides
                       (if (= overrides 1) "" "s"))))))

(defun bcp-profile-reset ()
  "Reset all override variables to `default' and re-apply the profile."
  (interactive)
  (dolist (entry bcp-profile--setting-to-override)
    (set (cdr entry) 'default))
  (bcp-profile-apply))

(defun bcp-profile-overridden-p (setting)
  "Return non-nil if SETTING has been overridden (not `default')."
  (let ((sym (cdr (assq setting bcp-profile--setting-to-override))))
    (and sym (not (eq (symbol-value sym) 'default)))))

(provide 'bcp-profile)
;;; bcp-profile.el ends here
