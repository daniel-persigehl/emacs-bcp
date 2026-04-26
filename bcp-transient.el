;;; bcp-transient.el --- Transient settings menu for the BCP Daily Office -*- lexical-binding: t -*-

;;; Commentary:

;; A transient-based settings interface for the BCP Daily Office.
;;
;; Entry point: M-x bcp-settings  (bind to a key of your choice)
;;
;; The menu is organised into three sections:
;;   General         — officiant role, creed
;;   Scripture       — lesson and psalm translations, fetch backend
;;   State prayers   — versicle form, region, sovereign and president names
;;
;; Tradition-specific rubrics are reached via sub-prefixes:
;;   1  BCP 1662 settings
;;   2  BCP 1928 settings
;;
;; Canticle settings and office-open actions round out the main menu.
;;
;; Changing a setting immediately updates the variable; press q to quit
;; and re-open the office to see the effect.

;;; Code:

(require 'transient)
(require 'cl-lib)
(require 'bcp-profile)

;; Suppress byte-compiler warnings for variables and functions defined
;; in the tradition modules.  bcp-transient is loaded after them.

(declare-function bcp-reload                    "bcp")
(declare-function bcp-reset                     "bcp")
(declare-function bcp-fetcher-toggle-furigana    "bcp-fetcher")
(declare-function bcp-fetcher--rubi-target-buffer "bcp-fetcher")
(declare-function bcp-toggle-shinjitai           "bcp-shinjitai")
(declare-function bcp-shinjitai--target-buffer    "bcp-shinjitai")
(declare-function bcp-fetcher-clear-cache        "bcp-fetcher")
(declare-function bcp-profile-apply              "bcp-profile")
(declare-function bcp-profile-reset              "bcp-profile")
(declare-function bcp-profile-effective          "bcp-profile")
(declare-function bcp-profile-overridden-p       "bcp-profile")
(declare-function bcp-1662-open-office   "bcp-1662")
(declare-function bcp-1662--current-time "bcp-1662")
(declare-function bcp-1928-open-office   "bcp-anglican-1928")
(declare-function bcp-1928--current-time "bcp-anglican-1928")
(declare-function bcp-roman-lobvm        "bcp-roman-lobvm")
(declare-function bcp-roman-lobvm-matins "bcp-roman-lobvm")
(declare-function bcp-roman-lobvm-lauds  "bcp-roman-lobvm")
(declare-function bcp-roman-lobvm-prime  "bcp-roman-lobvm")
(declare-function bcp-roman-lobvm-terce  "bcp-roman-lobvm")
(declare-function bcp-roman-lobvm-sext   "bcp-roman-lobvm")
(declare-function bcp-roman-lobvm-none   "bcp-roman-lobvm")
(declare-function bcp-roman-lobvm-vespers   "bcp-roman-lobvm")
(declare-function bcp-roman-lobvm-compline  "bcp-roman-lobvm")
(declare-function bcp-roman-breviary         "bcp-roman-breviary")
(declare-function bcp-roman-breviary-matins  "bcp-roman-breviary")
(declare-function bcp-roman-breviary-lauds   "bcp-roman-breviary")
(declare-function bcp-roman-breviary-prime   "bcp-roman-breviary")
(declare-function bcp-roman-breviary-terce   "bcp-roman-breviary")
(declare-function bcp-roman-breviary-sext    "bcp-roman-breviary")
(declare-function bcp-roman-breviary-none    "bcp-roman-breviary")
(declare-function bcp-roman-breviary-vespers "bcp-roman-breviary")
(declare-function bcp-roman-breviary-compline "bcp-roman-breviary")

(defvar office-officiant)
(defvar bcp-liturgy-creed)
(defvar bcp-liturgy-churchmanship)
(defvar bcp-liturgy-region)
(defvar bcp-liturgy-state-versicle-form)
(defvar bcp-liturgy-sovereign-title)
(defvar bcp-liturgy-sovereign-name)
(defvar bcp-liturgy-royal-family-names)
(defvar bcp-liturgy-head-of-state-title)
(defvar bcp-liturgy-country-name)
(defvar bcp-liturgy-president-name)
(defvar bcp-liturgy-canticle-language)
(defvar bcp-liturgy-canticle-append-gloria)
(defvar bcp-anglican-include-opening-hymn)
(defvar bcp-anglican-include-gradual-hymn)
(defvar bcp-anglican-include-anthem)
(defvar bcp-anglican-include-closing-hymn)
(defvar bible-commentary-translation)
(defvar bible-commentary-psalm-translation)
(defvar bcp-fetcher-backend)
(defvar bcp-fetcher-psalter)
(defvar bcp-fetcher-fallback-backend)
(defvar bcp-1662-venite-lent-verses)
(defvar bcp-1662-venite-ps96-substitute)
(defvar bcp-1928-venite-lent-verses)
(defvar bcp-1928-venite-ps96-substitute)
(defvar bcp-1928-venite-omit-ash-good-friday)
(defvar bcp-1662-lectionary)
(defvar bcp-1662-rubric-style)
(defvar bcp-1662-omit-penitential-intro)
(defvar bcp-1662-opening-sentence-corpus)
(defvar bcp-1662-opening-sentence-selection)
(defvar bcp-1662-bidding-form)
(defvar bcp-1662-general-confession-form)
(defvar bcp-1662-easter-anthems-throughout-eastertide)
(defvar bcp-1662-show-communion-propers)
(defvar bcp-1928-lectionary)
(defvar bcp-1928-rubric-style)
(defvar bcp-1928-omit-penitential-intro)
(defvar bcp-1928-show-communion-propers)
(defvar bcp-roman-office-language)
(defvar bcp-roman-hymnal-translator-order)
(defvar bcp-fetcher-furigana-display)
(defvar bcp-1662-office-date)
(defvar bcp-1928-office-date)
(defvar bcp-roman-office-date)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Helpers

(defun bcp--cycle (var choices)
  "Set VAR to the next element in CHOICES after its current value.
Comparison uses `equal'; wraps around after the last choice."
  (let* ((cur (symbol-value var))
         (pos (or (cl-position cur choices :test #'equal) -1)))
    (set var (nth (mod (1+ pos) (length choices)) choices))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; General suffixes

(transient-define-suffix bcp--set-officiant ()
  "Cycle the officiant role: lay → deacon → priest → bishop."
  :description (lambda ()
    (format "Officiant: %s" (symbol-name office-officiant)))
  :transient t
  (interactive)
  (bcp--cycle 'office-officiant '(lay deacon priest bishop)))

(transient-define-suffix bcp--set-creed ()
  "Toggle between Apostles' Creed and Nicene Creed."
  :description (lambda ()
    (if (eq bcp-liturgy-creed 'apostles)
        "Creed: Apostles'"
      "Creed: Nicene"))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-liturgy-creed '(apostles nicene)))

(transient-define-suffix bcp--set-churchmanship ()
  "Toggle between Catholic and Reformed churchmanship."
  :description (lambda ()
    (if (eq bcp-liturgy-churchmanship 'catholic)
        "Churchmanship: Catholic"
      "Churchmanship: Reformed"))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-liturgy-churchmanship '(catholic reformed)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Language profile suffixes

(defun bcp--bungo-yaku-label ()
  "Return the display label for the Bungo-yaku translation.
Uses 文語訳 in GUI Emacs, Bungo-yaku in terminal."
  (if (display-graphic-p) "文語訳" "Bungo-yaku"))

(defun bcp--profile-desc (setting fmt &optional val-fn)
  "Return a description for SETTING showing effective value and source.
FMT is a format string with one %s slot.  VAL-FN, if given, is
called on the effective value to produce the display string."
  (let* ((val (bcp-profile-effective setting))
         (display (if val-fn (funcall val-fn val) (format "%s" val)))
         (source (if (bcp-profile-overridden-p setting) "override" "profile")))
    (format (concat fmt " (%s)") display source)))

(transient-define-suffix bcp--set-language-profile ()
  "Cycle the language profile: ENG → LAT → JAP."
  :description (lambda ()
    (format "Profile: %s" bcp-language-profile))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-language-profile '(ENG LAT JAP))
  (bcp-profile-reset))

(transient-define-suffix bcp--toggle-furigana ()
  "Toggle furigana visibility in the current office buffer."
  :description "Toggle furigana"
  :transient t
  :if (lambda () (bcp-fetcher--rubi-target-buffer))
  (interactive)
  (bcp-fetcher-toggle-furigana))

(transient-define-suffix bcp--toggle-shinjitai ()
  "Toggle 旧字体→新字体 display in the current office buffer."
  :description "Toggle shinjitai"
  :transient t
  :if (lambda () (bcp-shinjitai--target-buffer))
  (interactive)
  (bcp-toggle-shinjitai))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Advanced override suffixes

(defun bcp--cycle-override (var choices)
  "Cycle override VAR through (default . CHOICES) and re-apply profile."
  (bcp--cycle var (cons 'default choices))
  (bcp-profile-apply))

(transient-define-suffix bcp--override-lesson-translation ()
  "Override lesson translation or inherit from profile."
  :description (lambda ()
    (bcp--profile-desc :lesson-translation "Lessons: %s"))
  :transient t
  (interactive)
  (let ((bungo (bcp--bungo-yaku-label)))
    (setq bcp-profile-lesson-translation
          (let ((new (completing-read "Lesson translation (RET for default): "
                       (list "default" "KJVA" "KJV" "NRSV" "NRSVAE"
                             "Vulgate" bungo)
                       nil t)))
            (if (equal new "default") 'default new)))
    (bcp-profile-apply)))

(transient-define-suffix bcp--override-psalm-translation ()
  "Override psalm translation or inherit from profile.
The translation name also drives `bcp-fetcher-psalter': picking
Coverdale / Tate & Brady / Vulgate routes psalms through the matching
local psalter; any other name lets the Bible backend serve them."
  :description (lambda ()
    (bcp--profile-desc :psalm-translation "Psalms: %s"))
  :transient t
  (interactive)
  (let ((bungo (bcp--bungo-yaku-label)))
    (setq bcp-profile-psalm-translation
          (let ((new (completing-read "Psalm translation (RET for default): "
                       (list "default"
                             "Coverdale" "BCP"
                             "Tate & Brady" "T&B"
                             "Vulgate" "Latin"
                             "KJVA" "CW" "LP" "NRSV" bungo)
                       nil t)))
            (if (equal new "default") 'default new)))
    (bcp-profile-apply)))

(transient-define-suffix bcp--override-backend ()
  "Override primary Bible backend or inherit from profile."
  :description (lambda ()
    (bcp--profile-desc :backend "Backend: %s"))
  :transient t
  (interactive)
  (bcp--cycle-override 'bcp-profile-backend
                       '(oremus ebible bungo-yaku)))

(transient-define-suffix bcp--override-fallback-backend ()
  "Override fallback fetch backend or inherit from profile."
  :description (lambda ()
    (bcp--profile-desc :fallback-backend "Fallback: %s"
                       (lambda (v) (if v (format "%s" v) "none"))))
  :transient t
  (interactive)
  (bcp--cycle-override 'bcp-profile-fallback-backend '(oremus ebible nil)))

(transient-define-suffix bcp--override-roman-language ()
  "Override Roman Office language or inherit from profile."
  :description (lambda ()
    (bcp--profile-desc :roman-language "Roman Office: %s"))
  :transient t
  (interactive)
  (bcp--cycle-override 'bcp-profile-roman-language '(latin english)))

(transient-define-suffix bcp--override-canticle-language ()
  "Override canticle language or inherit from profile."
  :description (lambda ()
    (bcp--profile-desc :canticle-language "Canticles: %s"))
  :transient t
  (interactive)
  (bcp--cycle-override 'bcp-profile-canticle-language '(english latin)))

(transient-define-suffix bcp--override-canticle-gloria ()
  "Override Gloria Patri after canticles or inherit from profile."
  :description (lambda ()
    (bcp--profile-desc :canticle-gloria "Gloria Patri: %s"
                       (lambda (v) (if v "yes" "no"))))
  :transient t
  (interactive)
  (bcp--cycle-override 'bcp-profile-canticle-gloria '(t nil)))

(transient-define-suffix bcp--override-furigana ()
  "Override furigana display mode or inherit from profile."
  :description (lambda ()
    (bcp--profile-desc :furigana "Furigana: %s"))
  :transient t
  (interactive)
  (bcp--cycle-override 'bcp-profile-furigana '(normal comment hidden rubi)))

(transient-define-suffix bcp--profile-reset-all ()
  "Reset all overrides to profile defaults."
  :description "Reset all to profile defaults"
  :transient t
  (interactive)
  (bcp-profile-reset))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Advanced overrides sub-prefix

(transient-define-prefix bcp-settings-advanced ()
  "Override individual language-profile settings.
Each setting shows (profile) when inherited or (override) when
explicitly set.  Use Reset to clear all overrides."
  [["Backend"
    ("b" bcp--override-backend)
    ("B" bcp--override-fallback-backend)]
   ["Language"
    ("r" bcp--override-roman-language)
    ("c" bcp--override-canticle-language)
    ("g" bcp--override-canticle-gloria)]
   ["Display"
    ("f" bcp--override-furigana)
    ("J" bcp--toggle-shinjitai)]
   [""
    ("R" bcp--profile-reset-all)]])

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; State prayer suffixes

(transient-define-suffix bcp--set-state-versicle-form ()
  "Cycle the state versicle theological form."
  :description (lambda ()
    (pcase bcp-liturgy-state-versicle-form
      ('monarchy       "Versicle: save the King/Queen")
      ('state          "Versicle: save the State")
      ('them-that-rule "Versicle: them that rule")))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-liturgy-state-versicle-form
    '(monarchy state them-that-rule)))

(transient-define-suffix bcp--set-region ()
  "Cycle the state prayers region."
  :description (lambda ()
    (pcase bcp-liturgy-region
      ('monarchy "Region: monarchy")
      ('us       "Region: United States")
      ('republic "Region: republic")))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-liturgy-region '(monarchy us republic)))

(transient-define-suffix bcp--set-sovereign-title ()
  "Toggle sovereign title between King and Queen."
  :description (lambda ()
    (if (eq bcp-liturgy-sovereign-title 'king)
        "Sovereign: King"
      "Sovereign: Queen"))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-liturgy-sovereign-title '(king queen)))

(transient-define-suffix bcp--set-sovereign-name ()
  "Set the sovereign's name (used when versicle form is monarchy)."
  :description (lambda ()
    (format "Sovereign name: %s"
      (or bcp-liturgy-sovereign-name "(defconst)")))
  :transient t
  (interactive)
  (let ((s (read-string "Sovereign name (RET to use defconst default): "
              bcp-liturgy-sovereign-name)))
    (setq bcp-liturgy-sovereign-name
          (if (string-empty-p s) nil s))))

(transient-define-suffix bcp--set-royal-family-names ()
  "Set the royal family members named in the prayer."
  :description (lambda ()
    (if bcp-liturgy-royal-family-names
        (format "Royal family: %s"
          (truncate-string-to-width bcp-liturgy-royal-family-names 30 nil nil "…"))
      "Royal family: (defconst)"))
  :transient t
  (interactive)
  (let ((s (read-string "Royal family names (RET to use defconst default): "
              bcp-liturgy-royal-family-names)))
    (setq bcp-liturgy-royal-family-names
          (if (string-empty-p s) nil s))))

(transient-define-suffix bcp--set-head-of-state-title ()
  "Set the head of state's title (republic contexts), or clear to use generic wording."
  :description (lambda ()
    (format "Title: %s"
      (or bcp-liturgy-head-of-state-title "(generic)")))
  :transient t
  (interactive)
  (let ((s (read-string "Head of state title (RET for generic, e.g. \"the President\"): "
              bcp-liturgy-head-of-state-title)))
    (setq bcp-liturgy-head-of-state-title
          (if (string-empty-p s) nil s))))

(transient-define-suffix bcp--set-country-name ()
  "Set the country name for republic state prayers, or clear to omit."
  :description (lambda ()
    (format "Country: %s"
      (or bcp-liturgy-country-name "(omit)")))
  :transient t
  (interactive)
  (let ((s (read-string "Country name (RET to omit, e.g. \"the United States\"): "
              bcp-liturgy-country-name)))
    (setq bcp-liturgy-country-name
          (if (string-empty-p s) nil s))))

(transient-define-suffix bcp--set-president-name ()
  "Set the head of state's personal name."
  :description (lambda ()
    (format "Name: %s"
      (or bcp-liturgy-president-name "(omit)")))
  :transient t
  (interactive)
  (let ((s (read-string "Head of state name (RET to omit): "
              bcp-liturgy-president-name)))
    (setq bcp-liturgy-president-name
          (if (string-empty-p s) nil s))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; State prayers sub-prefix

(transient-define-prefix bcp-settings-state-prayers ()
  "Settings for the state prayers (versicle and intercessions)."
  [["Versicle & region"
    ("s" bcp--set-state-versicle-form)
    ("r" bcp--set-region)]
   ["Monarchy"
    ("k" bcp--set-sovereign-title)
    ("K" bcp--set-sovereign-name)
    ("F" bcp--set-royal-family-names)]
   ["Republic"
    ("T" bcp--set-head-of-state-title)
    ("C" bcp--set-country-name)
    ("P" bcp--set-president-name)]
   [""
    ("q" bcp--back-to-settings)]])

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; BCP 1662 rubric suffixes

(transient-define-suffix bcp--set-1662-rubric-style ()
  "Toggle 1662 rubric rendering between red and comment face."
  :description (lambda ()
    (format "Rubric style: %s" bcp-1662-rubric-style))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1662-rubric-style '(red comment)))

(transient-define-suffix bcp--set-1662-penitential-intro ()
  "Toggle whether to include the penitential introduction."
  :description (lambda ()
    (if bcp-1662-omit-penitential-intro
        "Penitential intro: omit"
      "Penitential intro: include"))
  :transient t
  (interactive)
  (setq bcp-1662-omit-penitential-intro
        (not bcp-1662-omit-penitential-intro)))

(transient-define-suffix bcp--set-1662-opening-sentence-corpus ()
  "Toggle 1662 opening sentence corpus between 1662-only and extended."
  :description (lambda ()
    (if (equal bcp-1662-opening-sentence-corpus 1662)
        "Opening sentences: 1662"
      "Opening sentences: extended"))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1662-opening-sentence-corpus (list 1662 'extended)))

(transient-define-suffix bcp--set-1662-opening-sentence-selection ()
  "Toggle whether one or all opening sentences are read."
  :description (lambda ()
    (if (eq bcp-1662-opening-sentence-selection 'auto)
        "Sentence selection: one (auto)"
      "Sentence selection: all"))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1662-opening-sentence-selection '(auto all)))

(transient-define-suffix bcp--set-1662-bidding-form ()
  "Cycle the Bidding form: full → brief → omit."
  :description (lambda ()
    (format "Bidding: %s" bcp-1662-bidding-form))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1662-bidding-form '(full brief omit)))

(transient-define-suffix bcp--set-1662-general-confession-form ()
  "Cycle the General Confession form: standard → variant → omit."
  :description (lambda ()
    (pcase bcp-1662-general-confession-form
      ('nil     "Confession: standard")
      ('variant "Confession: variant")
      ('omit    "Confession: omit")))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1662-general-confession-form '(nil variant omit)))

(transient-define-suffix bcp--set-1662-venite-lent-verses ()
  "Cycle Venite vv.8–11 inclusion for the BCP 1662 office."
  :description (lambda ()
    (format "Venite vv.8–11: %s" bcp-1662-venite-lent-verses))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1662-venite-lent-verses '(always lent never)))

(transient-define-suffix bcp--set-1662-venite-ps96 ()
  "Toggle Ps.96 substitute for absent Venite vv.8–11 (1662 office)."
  :description (lambda ()
    (if bcp-1662-venite-ps96-substitute
        "Ps.96 substitute: yes"
      "Ps.96 substitute: no"))
  :transient t
  (interactive)
  (setq bcp-1662-venite-ps96-substitute (not bcp-1662-venite-ps96-substitute)))

(transient-define-suffix bcp--set-1928-venite-lent-verses ()
  "Cycle Venite vv.8–11 inclusion for the 1928 BCP office."
  :description (lambda ()
    (format "Venite vv.8–11: %s" bcp-1928-venite-lent-verses))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1928-venite-lent-verses '(always lent never)))

(transient-define-suffix bcp--set-1928-venite-ps96 ()
  "Toggle Ps.96 substitute for absent Venite vv.8–11 (1928 office)."
  :description (lambda ()
    (if bcp-1928-venite-ps96-substitute
        "Ps.96 substitute: yes"
      "Ps.96 substitute: no"))
  :transient t
  (interactive)
  (setq bcp-1928-venite-ps96-substitute (not bcp-1928-venite-ps96-substitute)))

(transient-define-suffix bcp--set-1928-venite-omit-penitential ()
  "Toggle Venite omission on Ash Wednesday and Good Friday (1928 office)."
  :description (lambda ()
    (if bcp-1928-venite-omit-ash-good-friday
        "Omit Venite Ash/GF: yes"
      "Omit Venite Ash/GF: no"))
  :transient t
  (interactive)
  (setq bcp-1928-venite-omit-ash-good-friday
        (not bcp-1928-venite-omit-ash-good-friday)))

(transient-define-suffix bcp--set-1662-easter-anthems ()
  "Toggle Easter Anthems throughout Eastertide vs. Easter Day only."
  :description (lambda ()
    (if bcp-1662-easter-anthems-throughout-eastertide
        "Easter Anthems: throughout Eastertide"
      "Easter Anthems: Easter Day only"))
  :transient t
  (interactive)
  (setq bcp-1662-easter-anthems-throughout-eastertide
        (not bcp-1662-easter-anthems-throughout-eastertide)))

(transient-define-suffix bcp--set-1662-communion-propers ()
  "Toggle display of Communion propers in the 1662 office."
  :description (lambda ()
    (if bcp-1662-show-communion-propers
        "Communion propers: show"
      "Communion propers: hide"))
  :transient t
  (interactive)
  (setq bcp-1662-show-communion-propers
        (not bcp-1662-show-communion-propers)))

(transient-define-suffix bcp--set-1662-lectionary ()
  "Cycle the lectionary for the BCP 1662 office."
  :description (lambda ()
    (format "Lectionary: %s" bcp-1662-lectionary))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1662-lectionary '(standard)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; BCP 1662 sub-prefix

(transient-define-prefix bcp-settings-1662 ()
  "Settings for the BCP 1662 Daily Office."
  [["Office"
    ("o" bcp--action-open-1662)
    ("M" bcp--action-open-1662-mattins)
    ("E" bcp--action-open-1662-evensong)]
   ["Rendering"
    ("r" bcp--set-1662-rubric-style)]
   ["Ordo"
    ("p" bcp--set-1662-penitential-intro)
    ("s" bcp--set-1662-opening-sentence-corpus)
    ("S" bcp--set-1662-opening-sentence-selection)
    ("b" bcp--set-1662-bidding-form)
    ("c" bcp--set-1662-general-confession-form)]
   ["Canticles & lessons"
    ("l" bcp--set-1662-lectionary)
    ("v" bcp--set-1662-venite-lent-verses)
    ("V" bcp--set-1662-venite-ps96)
    ("e" bcp--set-1662-easter-anthems)
    ("m" bcp--set-1662-communion-propers)]
   ["Hymns"
    ("h" bcp--toggle-opening-hymn)
    ("g" bcp--toggle-gradual-hymn)
    ("a" bcp--toggle-anthem)
    ("C" bcp--toggle-closing-hymn)]
   [""
    ("q" bcp--back-to-settings)]])

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; BCP 1928 rubric suffixes

(transient-define-suffix bcp--set-1928-rubric-style ()
  "Toggle 1928 rubric rendering between red and comment face."
  :description (lambda ()
    (format "Rubric style: %s" bcp-1928-rubric-style))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1928-rubric-style '(red comment)))

(transient-define-suffix bcp--set-1928-penitential-intro ()
  "Toggle whether to include the penitential introduction."
  :description (lambda ()
    (if bcp-1928-omit-penitential-intro
        "Penitential intro: omit"
      "Penitential intro: include"))
  :transient t
  (interactive)
  (setq bcp-1928-omit-penitential-intro
        (not bcp-1928-omit-penitential-intro)))

(transient-define-suffix bcp--set-1928-communion-propers ()
  "Toggle display of Communion propers in the 1928 office."
  :description (lambda ()
    (if bcp-1928-show-communion-propers
        "Communion propers: show"
      "Communion propers: hide"))
  :transient t
  (interactive)
  (setq bcp-1928-show-communion-propers
        (not bcp-1928-show-communion-propers)))

(transient-define-suffix bcp--set-1928-lectionary ()
  "Cycle the lectionary for the 1928 BCP office."
  :description (lambda ()
    (pcase bcp-1928-lectionary
      ('original-1928 "Lectionary: original 1928")
      ('revised-1945  "Lectionary: revised 1945")))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-1928-lectionary '(original-1928 revised-1945)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; BCP 1928 sub-prefix

(transient-define-prefix bcp-settings-1928 ()
  "Settings for the 1928 American BCP Daily Office."
  [["Office"
    ("o" bcp--action-open-1928)
    ("M" bcp--action-open-1928-mattins)
    ("E" bcp--action-open-1928-evensong)]
   ["Rendering"
    ("r" bcp--set-1928-rubric-style)]
   ["Ordo"
    ("p" bcp--set-1928-penitential-intro)
    ("m" bcp--set-1928-communion-propers)]
   ["Canticles & lessons"
    ("v" bcp--set-1928-venite-lent-verses)
    ("V" bcp--set-1928-venite-ps96)
    ("P" bcp--set-1928-venite-omit-penitential)
    ("l" bcp--set-1928-lectionary)]
   ["Hymns"
    ("h" bcp--toggle-opening-hymn)
    ("g" bcp--toggle-gradual-hymn)
    ("a" bcp--toggle-anthem)
    ("C" bcp--toggle-closing-hymn)]
   [""
    ("q" bcp--back-to-settings)]])

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Canticle suffixes

(transient-define-suffix bcp--set-canticle-language ()
  "Toggle canticle language between English and Latin."
  :description (lambda ()
    (format "Canticle language: %s" bcp-liturgy-canticle-language))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-liturgy-canticle-language '(english latin)))

(transient-define-suffix bcp--set-canticle-append-gloria ()
  "Toggle appending Gloria Patri after each canticle and psalm."
  :description (lambda ()
    (if bcp-liturgy-canticle-append-gloria
        "Append Gloria Patri: yes"
      "Append Gloria Patri: no"))
  :transient t
  (interactive)
  (setq bcp-liturgy-canticle-append-gloria
        (not bcp-liturgy-canticle-append-gloria)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Hymn-slot toggles (shared between 1662 and 1928)

(transient-define-suffix bcp--toggle-opening-hymn ()
  "Toggle the opening hymn (after the Venite)."
  :description (lambda ()
    (if bcp-anglican-include-opening-hymn
        "Opening hymn: include"
      "Opening hymn: omit"))
  :transient t
  (interactive)
  (setq bcp-anglican-include-opening-hymn
        (not bcp-anglican-include-opening-hymn)))

(transient-define-suffix bcp--toggle-gradual-hymn ()
  "Toggle the gradual-style hymn between the Lessons."
  :description (lambda ()
    (if bcp-anglican-include-gradual-hymn
        "Gradual hymn: include"
      "Gradual hymn: omit"))
  :transient t
  (interactive)
  (setq bcp-anglican-include-gradual-hymn
        (not bcp-anglican-include-gradual-hymn)))

(transient-define-suffix bcp--toggle-anthem ()
  "Toggle the anthem after the Third Collect."
  :description (lambda ()
    (if bcp-anglican-include-anthem
        "Anthem: include"
      "Anthem: omit"))
  :transient t
  (interactive)
  (setq bcp-anglican-include-anthem
        (not bcp-anglican-include-anthem)))

(transient-define-suffix bcp--toggle-closing-hymn ()
  "Toggle the closing hymn at the end of the Office."
  :description (lambda ()
    (if bcp-anglican-include-closing-hymn
        "Closing hymn: include"
      "Closing hymn: omit"))
  :transient t
  (interactive)
  (setq bcp-anglican-include-closing-hymn
        (not bcp-anglican-include-closing-hymn)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Navigation suffixes

(transient-define-suffix bcp--quit ()
  "Quit the settings menu."
  :description "Quit"
  (interactive)
  (transient-quit-all))

(transient-define-suffix bcp--back-to-settings ()
  "Return to the main settings menu."
  :description "← Main menu"
  (interactive)
  (call-interactively #'bcp-settings))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Office date override

(defun bcp--office-date-active-p ()
  "Non-nil when an office date override is currently set."
  (or (and (boundp 'bcp-1662-office-date) bcp-1662-office-date)
      (and (boundp 'bcp-1928-office-date) bcp-1928-office-date)
      (and (boundp 'bcp-roman-office-date) bcp-roman-office-date)))

(transient-define-suffix bcp--set-office-date ()
  "Set the override date used by all BCP Daily Office launches.
Sets both `bcp-1662-office-date' and `bcp-1928-office-date' so the
override applies to whichever tradition you open next.  The current
clock hour is preserved so the auto-pick of Mattins/Evensong still
works; pick a specific office from the tradition's submenu to
bypass the hour-based dispatch."
  :description (lambda ()
    (let ((d (bcp--office-date-active-p)))
      (if d
          (format "Office date: %d-%02d-%02d"
                  (nth 5 d) (nth 4 d) (nth 3 d))
        "Office date: today")))
  :transient t
  (interactive)
  (let* ((now   (decode-time))
         (year  (read-number "Year: "  (nth 5 now)))
         (month (read-number "Month: " (nth 4 now)))
         (day   (read-number "Day: "   (nth 3 now)))
         (hour  (nth 2 now))
         (time  (list 0 0 hour day month year nil nil nil)))
    (setq bcp-1662-office-date time
          bcp-1928-office-date time
          bcp-roman-office-date time)
    (message "Office date set to %d-%02d-%02d." year month day)))

(transient-define-suffix bcp--clear-office-date ()
  "Clear the office date override (resume using current date)."
  :description "Clear office date"
  :transient t
  :if (lambda () (bcp--office-date-active-p))
  (interactive)
  (setq bcp-1662-office-date nil
        bcp-1928-office-date nil
        bcp-roman-office-date nil)
  (message "Office date reset — using current date."))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Save settings

(defconst bcp--saveable-settings
  '(bcp-language-profile
    bcp-profile-lesson-translation
    bcp-profile-psalm-translation
    bcp-profile-backend
    bcp-profile-fallback-backend
    bcp-profile-roman-language
    bcp-profile-canticle-language
    bcp-profile-canticle-gloria
    bcp-profile-furigana
    office-officiant
    bcp-liturgy-creed
    bcp-liturgy-churchmanship
    bcp-liturgy-state-versicle-form
    bcp-liturgy-region
    bcp-liturgy-sovereign-title
    bcp-liturgy-sovereign-name
    bcp-liturgy-royal-family-names
    bcp-liturgy-head-of-state-title
    bcp-liturgy-country-name
    bcp-liturgy-president-name
    bcp-liturgy-canticle-language
    bcp-liturgy-canticle-append-gloria
    bcp-anglican-include-opening-hymn
    bcp-anglican-include-gradual-hymn
    bcp-anglican-include-anthem
    bcp-anglican-include-closing-hymn
    bcp-1662-rubric-style
    bcp-1662-omit-penitential-intro
    bcp-1662-opening-sentence-corpus
    bcp-1662-opening-sentence-selection
    bcp-1662-bidding-form
    bcp-1662-general-confession-form
    bcp-1662-easter-anthems-throughout-eastertide
    bcp-1662-show-communion-propers
    bcp-1662-venite-lent-verses
    bcp-1662-venite-ps96-substitute
    bcp-1662-lectionary
    bcp-1928-rubric-style
    bcp-1928-omit-penitential-intro
    bcp-1928-show-communion-propers
    bcp-1928-lectionary
    bcp-1928-venite-lent-verses
    bcp-1928-venite-ps96-substitute
    bcp-1928-venite-omit-ash-good-friday
    bcp-roman-office-language
    bcp-roman-hymnal-translator-order
    bcp-fetcher-furigana-display)
  "BCP `defcustom' variables persisted by `bcp--save-all-settings'.")

(transient-define-suffix bcp--save-all-settings ()
  "Persist current BCP settings to `custom-file'.
Each variable is written via `customize-save-variable', which records
its current value into your Custom file so it survives Emacs restarts."
  :description "Save settings to file"
  :transient t
  (interactive)
  (unless (or custom-file user-init-file)
    (user-error "Neither `custom-file' nor `user-init-file' is set; cannot save"))
  (let ((n 0))
    (dolist (var bcp--saveable-settings)
      (when (boundp var)
        (customize-save-variable var (symbol-value var))
        (cl-incf n)))
    (message "BCP: saved %d setting%s to %s."
             n (if (= n 1) "" "s")
             (or custom-file user-init-file))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Action suffixes

(transient-define-suffix bcp--action-reload ()
  "Reload BCP modules without re-applying preferences."
  :description "Reload modules"
  :transient t
  (interactive)
  (bcp-reload))

(transient-define-suffix bcp--action-reset ()
  "Re-apply scripted defaults from bcp-preferences.el and reload."
  :description "Reset to defaults"
  :transient t
  (interactive)
  (bcp-reset))

(transient-define-suffix bcp--action-open-1662 ()
  "Open the BCP 1662 Daily Office (auto-pick Mattins/Evensong by hour)."
  :description "Open (auto)"
  (interactive)
  (bcp-1662-open-office))

(transient-define-suffix bcp--action-open-1662-mattins ()
  "Open BCP 1662 Morning Prayer for the office date (or today)."
  :description "Open Mattins"
  (interactive)
  (let* ((base (bcp-1662--current-time))
         (bcp-1662-office-date
          (list 0 0 9 (nth 3 base) (nth 4 base) (nth 5 base) nil nil nil)))
    (bcp-1662-open-office)))

(transient-define-suffix bcp--action-open-1662-evensong ()
  "Open BCP 1662 Evening Prayer for the office date (or today)."
  :description "Open Evensong"
  (interactive)
  (let* ((base (bcp-1662--current-time))
         (bcp-1662-office-date
          (list 0 0 18 (nth 3 base) (nth 4 base) (nth 5 base) nil nil nil)))
    (bcp-1662-open-office)))

(transient-define-suffix bcp--action-open-1928 ()
  "Open the 1928 American BCP Daily Office (auto-pick Mattins/Evensong)."
  :description "Open (auto)"
  (interactive)
  (bcp-1928-open-office))

(transient-define-suffix bcp--action-open-1928-mattins ()
  "Open 1928 BCP Morning Prayer for the office date (or today)."
  :description "Open Mattins"
  (interactive)
  (let* ((base (bcp-1928--current-time))
         (bcp-1928-office-date
          (list 0 0 9 (nth 3 base) (nth 4 base) (nth 5 base) nil nil nil)))
    (bcp-1928-open-office)))

(transient-define-suffix bcp--action-open-1928-evensong ()
  "Open 1928 BCP Evening Prayer for the office date (or today)."
  :description "Open Evensong"
  (interactive)
  (let* ((base (bcp-1928--current-time))
         (bcp-1928-office-date
          (list 0 0 18 (nth 3 base) (nth 4 base) (nth 5 base) nil nil nil)))
    (bcp-1928-open-office)))

(transient-define-suffix bcp--action-open-lobvm ()
  "Open the Little Office of the BVM (auto-selects hour)."
  :description "LOBVM (auto)"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm))

(transient-define-suffix bcp--action-open-lobvm-lauds ()
  "Open Lauds of the Little Office of the BVM."
  :description "LOBVM Lauds"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm-lauds))

(transient-define-suffix bcp--action-open-lobvm-vespers ()
  "Open Vespers of the Little Office of the BVM."
  :description "LOBVM Vespers"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm-vespers))

(transient-define-suffix bcp--action-open-lobvm-matins ()
  "Open Matins of the Little Office of the BVM."
  :description "LOBVM Matins"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm-matins))

(transient-define-suffix bcp--action-open-lobvm-prime ()
  "Open Prime of the Little Office of the BVM."
  :description "LOBVM Prime"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm-prime))

(transient-define-suffix bcp--action-open-lobvm-terce ()
  "Open Terce of the Little Office of the BVM."
  :description "LOBVM Terce"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm-terce))

(transient-define-suffix bcp--action-open-lobvm-sext ()
  "Open Sext of the Little Office of the BVM."
  :description "LOBVM Sext"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm-sext))

(transient-define-suffix bcp--action-open-lobvm-none ()
  "Open None of the Little Office of the BVM."
  :description "LOBVM None"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm-none))

(transient-define-suffix bcp--action-open-lobvm-compline ()
  "Open Compline of the Little Office of the BVM."
  :description "LOBVM Compline"
  (interactive)
  (require 'bcp-roman-lobvm)
  (bcp-roman-lobvm-compline))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Roman Office suffixes

(transient-define-suffix bcp--set-roman-language ()
  "Toggle the Roman Office language between Latin and English."
  :description (lambda ()
    (format "Language: %s"
      (if (eq bcp-roman-office-language 'english) "English" "Latin")))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-roman-office-language '(latin english)))

(transient-define-suffix bcp--set-roman-hymn-translator ()
  "Cycle the preferred hymn translator (head of the order list)."
  :description (lambda ()
    (format "Hymn translator: %s"
      (symbol-name (car bcp-roman-hymnal-translator-order))))
  :transient t
  (interactive)
  (let* ((picks '(britt caswall neale primer))
         (cur (car bcp-roman-hymnal-translator-order))
         (pos (or (cl-position cur picks) -1))
         (next (nth (mod (1+ pos) (length picks)) picks)))
    (setq bcp-roman-hymnal-translator-order
          (cons next (remq next bcp-roman-hymnal-translator-order)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Breviary action suffixes

(transient-define-suffix bcp--action-open-breviary ()
  "Open the ferial Breviary (auto-selects hour)."
  :description "Breviary (auto)"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary))

(transient-define-suffix bcp--action-open-breviary-matins ()
  "Open Matins of the ferial Breviary."
  :description "Breviary Matins"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary-matins))

(transient-define-suffix bcp--action-open-breviary-lauds ()
  "Open Lauds of the ferial Breviary."
  :description "Breviary Lauds"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary-lauds))

(transient-define-suffix bcp--action-open-breviary-prime ()
  "Open Prime of the ferial Breviary."
  :description "Breviary Prime"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary-prime))

(transient-define-suffix bcp--action-open-breviary-terce ()
  "Open Terce of the ferial Breviary."
  :description "Breviary Terce"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary-terce))

(transient-define-suffix bcp--action-open-breviary-sext ()
  "Open Sext of the ferial Breviary."
  :description "Breviary Sext"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary-sext))

(transient-define-suffix bcp--action-open-breviary-none ()
  "Open None of the ferial Breviary."
  :description "Breviary None"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary-none))

(transient-define-suffix bcp--action-open-breviary-vespers ()
  "Open Vespers of the ferial Breviary."
  :description "Breviary Vespers"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary-vespers))

(transient-define-suffix bcp--action-open-breviary-compline ()
  "Open Compline of the ferial Breviary."
  :description "Breviary Compline"
  (interactive)
  (require 'bcp-roman-breviary)
  (bcp-roman-breviary-compline))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Little Office submenu

(transient-define-prefix bcp-settings-lobvm ()
  "Roman Office — Little Office of the BVM."
  [["Settings"
    ("L" bcp--set-roman-language)
    ("H" bcp--set-roman-hymn-translator)]
   ["Hours"
    ("a" bcp--action-open-lobvm)
    ("m" bcp--action-open-lobvm-matins)
    ("l" bcp--action-open-lobvm-lauds)
    ("p" bcp--action-open-lobvm-prime)
    ("t" bcp--action-open-lobvm-terce)
    ("s" bcp--action-open-lobvm-sext)
    ("n" bcp--action-open-lobvm-none)
    ("v" bcp--action-open-lobvm-vespers)
    ("c" bcp--action-open-lobvm-compline)]
   [""
    ("q" bcp--back-to-settings)]])

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Breviary submenu

(transient-define-prefix bcp-settings-breviary ()
  "Roman Office — Ferial Breviary."
  [["Settings"
    ("L" bcp--set-roman-language)
    ("H" bcp--set-roman-hymn-translator)]
   ["Hours"
    ("a" bcp--action-open-breviary)
    ("m" bcp--action-open-breviary-matins)
    ("l" bcp--action-open-breviary-lauds)
    ("p" bcp--action-open-breviary-prime)
    ("t" bcp--action-open-breviary-terce)
    ("s" bcp--action-open-breviary-sext)
    ("n" bcp--action-open-breviary-none)
    ("v" bcp--action-open-breviary-vespers)
    ("c" bcp--action-open-breviary-compline)]
   [""
    ("q" bcp--back-to-settings)]])

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Main prefix

;;;###autoload
(transient-define-prefix bcp-settings ()
  "BCP Daily Office settings.

Settings take effect immediately.  Each tradition (1–4) has its own
submenu containing rubric options and an Open action.  Press `S' to
persist current settings to your Custom file; `q' to quit."
  [["Language"
    ("L" bcp--set-language-profile)
    ("t" bcp--override-lesson-translation)
    ("p" bcp--override-psalm-translation)
    ("A" "Advanced overrides…" bcp-settings-advanced)
    ("j" bcp--toggle-furigana)]
   ["General"
    ("o" bcp--set-officiant)
    ("c" bcp--set-creed)
    ("h" bcp--set-churchmanship)
    ("s" "State prayers…" bcp-settings-state-prayers)]]
  [["Traditions"
    ("1" "BCP 1662…"        bcp-settings-1662)
    ("2" "BCP 1928…"        bcp-settings-1928)
    ("3" "Little Office…"   bcp-settings-lobvm)
    ("4" "Roman Breviary…"  bcp-settings-breviary)]
   ["Actions"
    ("d" bcp--set-office-date)
    ("D" bcp--clear-office-date)
    ("S" bcp--save-all-settings)
    ("g" bcp--action-reload)
    ("G" bcp--action-reset)
    ("q" bcp--quit)]])

(provide 'bcp-transient)
;;; bcp-transient.el ends here
