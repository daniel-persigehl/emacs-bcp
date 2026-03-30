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

;; Suppress byte-compiler warnings for variables and functions defined
;; in the tradition modules.  bcp-transient is loaded after them.

(declare-function bcp-reload         "bcp-preferences")
(declare-function bcp-1662-open-office   "bcp-1662")
(declare-function bcp-1928-open-office   "bcp-anglican-1928")

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
(defvar bible-commentary-translation)
(defvar bible-commentary-psalm-translation)
(defvar bcp-fetcher-backend)
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
(defvar bcp-roman-hymnal-preferred-translator)

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
;;;; Scripture suffixes

(transient-define-suffix bcp--set-translation ()
  "Select the lesson translation."
  :description (lambda ()
    (format "Lessons: %s" bible-commentary-translation))
  :transient t
  (interactive)
  (setq bible-commentary-translation
        (completing-read "Lesson translation: "
          '("KJVA" "KJV" "NRSV" "NRSVAE") nil t
          bible-commentary-translation)))

(transient-define-suffix bcp--set-psalm-translation ()
  "Select the psalm translation."
  :description (lambda ()
    (format "Psalms: %s" bible-commentary-psalm-translation))
  :transient t
  (interactive)
  (let ((new (completing-read "Psalm translation: "
               '("Coverdale" "BCP" "Vulgate" "Latin" "KJVA" "CW" "LP" "NRSV") nil t
               bible-commentary-psalm-translation)))
    (unless (equal new bible-commentary-psalm-translation)
      (setq bible-commentary-psalm-translation new)
      (bcp-fetcher-clear-cache))))

(transient-define-suffix bcp--set-backend ()
  "Cycle the primary fetch backend: coverdale → vulgate → oremus → ebible."
  :description (lambda ()
    (format "Backend: %s → %s"
      bcp-fetcher-backend
      (or bcp-fetcher-fallback-backend "—")))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-fetcher-backend '(coverdale vulgate oremus ebible))
  (bcp-fetcher-clear-cache))

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
  [["Rendering"
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
  [["Rendering"
    ("r" bcp--set-1928-rubric-style)]
   ["Ordo"
    ("p" bcp--set-1928-penitential-intro)
    ("m" bcp--set-1928-communion-propers)]
   ["Canticles & lessons"
    ("v" bcp--set-1928-venite-lent-verses)
    ("V" bcp--set-1928-venite-ps96)
    ("a" bcp--set-1928-venite-omit-penitential)
    ("l" bcp--set-1928-lectionary)]
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
  (bcp-settings))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Action suffixes

(transient-define-suffix bcp--action-reload ()
  "Reload all BCP modules."
  :description "Reload modules"
  (interactive)
  (bcp-reload))

(transient-define-suffix bcp--action-open-1662 ()
  "Open the BCP 1662 Daily Office."
  :description "Open 1662 office"
  (interactive)
  (bcp-1662-open-office))

(transient-define-suffix bcp--action-open-1928 ()
  "Open the 1928 American BCP Daily Office."
  :description "Open 1928 office"
  (interactive)
  (bcp-1928-open-office))

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
  "Cycle the preferred hymn translator."
  :description (lambda ()
    (format "Hymn translator: %s"
      (symbol-name bcp-roman-hymnal-preferred-translator)))
  :transient t
  (interactive)
  (bcp--cycle 'bcp-roman-hymnal-preferred-translator
    '(britt caswall neale primer)))

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
    ("c" bcp--action-open-lobvm-compline)]])

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Main prefix

;;;###autoload
(transient-define-prefix bcp-settings ()
  "BCP Daily Office settings.

Settings take effect immediately.  Quit with q, then re-open the office
to see the result.  Tradition-specific rubric options are under 1 (BCP 1662)
and 2 (BCP 1928)."
  [["General"
    ("o" bcp--set-officiant)
    ("c" bcp--set-creed)
    ("h" bcp--set-churchmanship)]
   ["Scripture"
    ("t" bcp--set-translation)
    ("p" bcp--set-psalm-translation)
    ("b" bcp--set-backend)]
   ["State prayers"
    ("s" bcp--set-state-versicle-form)
    ("r" bcp--set-region)
    ("k" bcp--set-sovereign-title)
    ("K" bcp--set-sovereign-name)
    ("F" bcp--set-royal-family-names)
    ("T" bcp--set-head-of-state-title)
    ("C" bcp--set-country-name)
    ("P" bcp--set-president-name)]]
  [["Canticles"
    ("l" bcp--set-canticle-language)
    ("g" bcp--set-canticle-append-gloria)]
   ["Traditions"
    ("1" "BCP 1662 rubrics…" bcp-settings-1662)
    ("2" "BCP 1928 rubrics…" bcp-settings-1928)]
   ["Actions"
    ("E" bcp--action-open-1662)
    ("A" bcp--action-open-1928)
    ("r" bcp--action-open-lobvm)
    ("R" "Roman Office hours…" bcp-settings-lobvm)
    ("g" bcp--action-reload)
    ("q" bcp--quit)]])

(provide 'bcp-transient)
;;; bcp-transient.el ends here
