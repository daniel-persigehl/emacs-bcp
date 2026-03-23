;;; bcp-fetcher.el --- API-agnostic Bible text fetching -*- lexical-binding: t -*-

;;; Commentary:

;; Backend-agnostic fetching layer for the BCP package.  Backends
;; register themselves via `bcp-fetcher-register-backend'; the active
;; backend is selected by `bcp-fetcher-backend' (default: `oremus').
;;
;; The Oremus backend is loaded automatically at the bottom of this file
;; via (require 'bcp-fetcher-oremus).  To use a different backend, load
;; its file and set `bcp-fetcher-backend' before fetching.
;;
;; Public API:
;;   `bcp-fetcher-fetch'                  — async fetch, calls (callback text)
;;   `bcp-fetcher-fetch-passage'          — async fetch, calls (load-fn text label)
;;   `bcp-fetcher-fetch-passage-context'  — async context fetch for omitted verses
;;   `bcp-fetcher-clean-text'             — strip Windows-1252 artefacts from text
;;   `bcp-fetcher-register-backend'       — register a fetch backend
;;   `bcp-fetcher-available-translations' — translations for the active backend
;;
;; Textual-status utilities (translation-agnostic):
;;   `bcp-fetcher-textual-status'
;;   `bcp-fetcher-textual-header-annotation'
;;   `bcp-fetcher-textual-status-property'
;;   `bcp-fetcher-critical-translation-p'
;;   `bcp-fetcher-active-translation'

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Defgroup

(defgroup bcp-fetcher nil
  "Bible text fetching."
  :prefix "bcp-fetcher-"
  :group 'text)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Translation configuration

(defcustom bible-commentary-translation "KJVA"
  "Default translation for the Protestant canon and Catholic deuterocanon.
Defaults to KJVA (KJV with Apocrypha), which covers both the Protestant
books and the Catholic deuterocanon (Tobit, Judith, Sirach, Wisdom, etc.)
in traditional KJV-style language.  The text is identical to KJV for all
Protestant books, so nothing is lost by using KJVA throughout."
  :type 'string
  :group 'bcp-fetcher)

(defcustom bible-commentary-psalm-translation "Coverdale"
  "Translation used automatically for Psalms.
The value is passed to the active backend.  For the Oremus backend,
\"Coverdale\" maps to the BCP 1662 Psalter code \"BCP\".  Other
psalm-specific options depend on the backend in use."
  :type 'string
  :group 'bcp-fetcher)

(defcustom bible-commentary-omitted-verse-context-window 2
  "Number of verses before and after an omitted verse to fetch as context.
When navigating to a verse absent from the critical text (e.g. John 5:4 in
the ESV), the package fetches this many verses on either side so the user
sees the surrounding passage rather than an empty buffer."
  :type 'integer
  :group 'bcp-fetcher)

(defcustom bible-commentary-critical-translation-names
  '("ESV" "NRSV" "NIV" "RSV" "NETS" "NA28" "UBS" "NEB" "REB" "CEB")
  "Translation names that use the critical (Alexandrian) text.
Textual status warnings are shown when the active translation matches
any name in this list (case-insensitive substring match).
Traditional-text translations (KJV, KJVA, Vulgate, Douay-Rheims) do not
receive warnings because the verses in question are present in their text."
  :type '(repeat string)
  :group 'bcp-fetcher)

(defcustom bible-commentary-vulgate-translation-names
  '(;; Latin tradition
    "Vulgate" "Latin" "Vg" "Nova Vulgata" "Neovulgata"
    "Douay" "Douay-Rheims" "Douay Rheims" "Challoner"
    ;; Greek tradition
    "LXX" "Septuagint" "NETS" "Brenton" "OSB"
    ;; Other traditions following LXX numbering
    "NJB" "Jerusalem Bible" "New Jerusalem Bible"
    "Einheitsübersetzung" "TOB" "Peshitta")
  "Translation names that trigger Vulgate/LXX psalm numbering.
All translations in this list share the same psalm numbering scheme,
which originates in the LXX and was followed by Jerome in the Vulgate.
Matching is case-insensitive and checks whether the active translation
name contains any of these strings as a substring."
  :type '(repeat string)
  :group 'bcp-fetcher)

(defcustom bible-commentary-orthodox-translation "NRSV"
  "Translation used for Orthodox-only books absent from the KJV tradition.
This applies to: Psalm 151, 1 Esdras, 2 Esdras (4 Ezra), Prayer of Manasseh,
3 Maccabees, and 4 Maccabees.  These were never translated into the KJV
tradition and are not in KJVA.  NRSV is the most complete ecumenical
translation available."
  :type 'string
  :group 'bcp-fetcher)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Session translation state

(defvar bible-commentary--session-translation nil
  "Translation locked for this session via `bible-commentary-set-translation'.
When non-nil it overrides the Coverdale auto-switch for Psalms.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Canon data needed for translation dispatch

(defconst bcp-fetcher--lxx-only-books
  '("Psalm 151" "3 Maccabees" "4 Maccabees")
  "Books present in Orthodox canons via the LXX but absent from the KJV
Apocrypha entirely.  These require `bible-commentary-orthodox-translation'.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Textual critical data

(defconst bcp-fetcher--omitted-verses
  '(("Matthew" . ((17 . (21))
                  (18 . (11))
                  (23 . (14))))
    ("Mark"    . ((7  . (16))
                  (9  . (44 46))
                  (11 . (26))
                  (15 . (28))))
    ("Luke"    . ((17 . (36))
                  (23 . (17))))
    ("John"    . ((5  . (4))))
    ("Acts"    . ((8  . (37))
                  (15 . (34))
                  (24 . (7))
                  (28 . (29))))
    ("Romans"  . ((16 . (24)))))
  "Verses absent from the critical text (NA28/UBS5) that are present in the TR/KJV.")

(defconst bcp-fetcher--disputed-ranges
  '(("Mark"  16  9  16 20 "Long Ending of Mark")
    ("John"   7 53   8 11 "Pericope Adulterae (Woman Caught in Adultery)")
    ("Luke"  22 43  22 44 "Bloody Sweat — bracketed in critical editions")
    ("Luke"  23 34  23 34 "\"Father, forgive them\" — bracketed in some editions"))
  "Passages present in most translations but textually disputed or relocated.")

(defun bcp-fetcher-textual-status (ref)
  "Return the textual status of REF as a plist, or nil if uncontested.

Returns:
  (:status \\='omitted  :label STRING)  — verse absent from critical text
  (:status \\='disputed :label STRING)  — verse present but bracketed/relocated
  nil                                   — no textual issue"
  (let* ((book (plist-get ref :book))
         (ch   (plist-get ref :chapter))
         (vs   (plist-get ref :verse-start)))
    (when (and book ch vs)
      (let* ((book-entry (cdr (assoc book bcp-fetcher--omitted-verses)))
             (ch-entry   (cdr (assoc ch book-entry))))
        (if (memq vs ch-entry)
            (list :status 'omitted
                  :label  "Absent from critical text (NA28/UBS5)")
          (cl-loop for (b cs cvs ce cve label)
                   in bcp-fetcher--disputed-ranges
                   when (and (equal b book)
                             (or (and (= ch cs) (= ch ce)
                                      (>= vs cvs) (<= vs cve))
                                 (and (= ch cs) (< cs ce)
                                      (>= vs cvs))
                                 (and (= ch ce) (< cs ce)
                                      (<= vs cve))
                                 (and (> ch cs) (< ch ce))))
                   return (list :status 'disputed :label label)))))))

(defun bcp-fetcher-critical-translation-p (translation)
  "Return non-nil if TRANSLATION uses the critical (Alexandrian) text."
  (let ((tr (downcase (or translation ""))))
    (cl-some (lambda (name)
               (string-match-p (regexp-quote (downcase name)) tr))
             bible-commentary-critical-translation-names)))

(defun bcp-fetcher-textual-header-annotation (ref translation)
  "Return a textual status annotation string for REF, or nil.
Only shown when TRANSLATION is a critical-text translation."
  (when (bcp-fetcher-critical-translation-p translation)
    (let ((status (bcp-fetcher-textual-status ref)))
      (when status
        (pcase (plist-get status :status)
          ('omitted  "  ⚠ absent from critical text")
          ('disputed (format "  ⚠ disputed — %s"
                             (plist-get status :label))))))))

(defun bcp-fetcher-textual-status-property (ref translation)
  "Return a :TEXTUAL_STATUS: property string for REF, or nil if uncontested."
  (when (bcp-fetcher-critical-translation-p translation)
    (let ((status (bcp-fetcher-textual-status ref)))
      (when status
        (format ":TEXTUAL_STATUS: %s\n" (plist-get status :label))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Active translation dispatch

(defun bcp-fetcher-active-translation (ref)
  "Return the translation string to use for REF.

Priority order:
  1. `bible-commentary--session-translation' if set this session.
  2. `bible-commentary-psalm-translation' (Coverdale) for Psalms 1-150.
  3. `bible-commentary-orthodox-translation' (NRSV) for LXX-only books
     (Psalm 151, 3-4 Maccabees) absent from the KJV Apocrypha.
  4. `bible-commentary-translation' (KJVA) for everything else."
  (or bible-commentary--session-translation
      (cond
       ((equal (plist-get ref :book) "Psalms")
        bible-commentary-psalm-translation)
       ((member (plist-get ref :book) bcp-fetcher--lxx-only-books)
        bible-commentary-orthodox-translation)
       (t bible-commentary-translation))))

(defun bible-commentary-set-translation (translation)
  "Lock TRANSLATION for this session, overriding the Coverdale auto-switch.
Call with an empty string or \\[universal-argument] to restore automatic behaviour."
  (interactive
   (list (let ((s (completing-read
                   "Translation (blank to reset to automatic): "
                   (bcp-fetcher-available-translations)
                   nil nil nil nil "")))
           (if (string-empty-p s) nil s))))
  (setq bible-commentary--session-translation
        (and translation (not (string-empty-p translation)) translation))
  (message (if bible-commentary--session-translation
               "Translation locked to %s for this session."
             "Translation reset — Coverdale for Psalms, NRSV for Orthodox books, KJVA otherwise.")
           bible-commentary--session-translation))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Text cleaning

(defun bcp-fetcher-clean-text (text)
  "Clean Windows-1252 C1 characters and non-breaking spaces from TEXT.
Operates in a temp buffer so text properties on TEXT are preserved.
Returns the cleaned string with text properties intact."
  (with-temp-buffer
    (insert text)
    (dolist (pair '(("\u0091" . "\u2018")   ; left single quote
                    ("\u0092" . "\u2019")   ; right single quote / apostrophe
                    ("\u0093" . "\u201C")   ; left double quote
                    ("\u0094" . "\u201D")   ; right double quote
                    ("\u0096" . "\u2013")   ; en dash
                    ("\u0097" . "\u2014")   ; em dash
                    ("\u00a0" . " ")))      ; non-breaking space
      (goto-char (point-min))
      (while (search-forward (car pair) nil t)
        (replace-match (cdr pair))))
    ;; Collapse excess blank lines
    (goto-char (point-min))
    (while (re-search-forward "\n\\{3,\\}" nil t)
      (replace-match "\n\n"))
    (string-trim (buffer-string))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Backend registry

(defcustom bcp-fetcher-backend 'oremus
  "Symbol identifying the active Bible text fetch backend.
The backend must be registered via `bcp-fetcher-register-backend'."
  :type 'symbol
  :group 'bcp-fetcher)

(defvar bcp-fetcher--backends nil
  "Alist mapping backend symbols to their property plists.")

(defun bcp-fetcher-register-backend (name &rest plist)
  "Register a fetch backend named NAME (a symbol) with properties PLIST.
Required plist keys:
  :name STRING        — human-readable display name
  :fetch-fn FUNCTION  — (fn passage translation callback)
                        async; calls (callback text) with propertized text
                        or nil on failure
  :translations LIST  — list of supported translation name strings"
  (setf (alist-get name bcp-fetcher--backends) plist))

(defun bcp-fetcher--active-backend ()
  "Return the plist of the active backend, or signal an error if missing."
  (or (alist-get bcp-fetcher-backend bcp-fetcher--backends)
      (error "bcp-fetcher: no backend registered for `%s'" bcp-fetcher-backend)))

(defun bcp-fetcher-available-translations ()
  "Return the list of translation name strings for the active backend."
  (plist-get (bcp-fetcher--active-backend) :translations))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public fetch API

(defun bcp-fetcher-fetch (passage callback &optional translation)
  "Fetch PASSAGE using the active backend and call CALLBACK with formatted text.

TRANSLATION defaults to `bible-commentary-translation'.
CALLBACK is called as (CALLBACK text) where TEXT is a propertized string
with verse numbers formatted for visual-line-mode, or nil on failure.

The text properties from the backend are preserved — do NOT pass the result
through `bcp-fetcher-clean-text' as that would strip them."
  (let* ((tr (or translation bible-commentary-translation))
         (fn (plist-get (bcp-fetcher--active-backend) :fetch-fn)))
    (funcall fn passage tr callback)))

(defun bcp-fetcher-fetch-passage (passage load-fn &optional translation)
  "Fetch PASSAGE using the active backend and call LOAD-FN with (text label).

TRANSLATION defaults to `bible-commentary-translation'.
LOAD-FN is called as (LOAD-FN text label) where:
  TEXT  — propertized passage string (or nil on failure)
  LABEL — display string, e.g. \"Genesis 1  [KJVA]\""
  (let* ((tr (or translation bible-commentary-translation))
         (fn (plist-get (bcp-fetcher--active-backend) :fetch-fn)))
    (message "Fetching %s [%s]…" passage tr)
    (funcall fn passage tr
             (lambda (text)
               (funcall load-fn text (format "%s  [%s]" passage tr))))))

(defun bcp-fetcher-fetch-passage-context (ref translation load-fn banner-fn)
  "Fetch a context window around REF and call LOAD-FN with (text label).

Used for omitted or disputed verses where fetching the bare verse number
returns empty content.  Fetches `bible-commentary-omitted-verse-context-window'
verses on each side.

LOAD-FN is called as (LOAD-FN text label).  If the backend returns nil (fetch
failed), a fallback explanatory text is used.
BANNER-FN is called as (BANNER-FN banner-string) before the fetch if a
textual-status banner is available; pass nil to skip the banner."
  (let* ((ch      (plist-get ref :chapter))
         (vs      (plist-get ref :verse-start))
         (book    (plist-get ref :book))
         (window  bible-commentary-omitted-verse-context-window)
         (vs-from (max 1 (- vs window)))
         (vs-to   (+ vs window))
         (passage (format "%s %d:%d-%d" book ch vs-from vs-to))
         (status  (bcp-fetcher-textual-status ref))
         (banner  (when status
                    (pcase (plist-get status :status)
                      ('omitted
                       (format "┄┄ Context: %s (v%d absent from critical text) ┄┄"
                               passage vs))
                      ('disputed
                       (format "┄┄ Context: %s [⚠ %s] ┄┄"
                               passage (plist-get status :label)))))))
    (message "Fetching context around %s %d:%d [%s]…" book ch vs translation)
    (when (and banner banner-fn)
      (funcall banner-fn banner))
    (let ((fn (plist-get (bcp-fetcher--active-backend) :fetch-fn)))
      (funcall fn passage translation
               (lambda (text)
                 (funcall load-fn
                          (or text
                              (format
                               "Verse %s %d:%d is absent from the critical text.\n\n\
This verse number does not appear in the earliest Greek manuscripts and is \
omitted in %s.  It is present in the Textus Receptus and therefore in the \
KJV/KJVA.\n\nTo read the surrounding passage, navigate to %s %d:%d-%d."
                               book ch vs translation book ch vs-from vs-to))
                          (format "%s  [%s]" passage translation)))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Chapter heading helper

(defun bcp-fetcher--make-chapter-heading (book chapter)
  "Return a propertized chapter heading string for BOOK chapter CHAPTER.
The heading is invisible by default (category `bcp-chapter-headings').
To show headings, call (remove-from-invisibility-spec \\='bcp-chapter-headings).
Text properties:
  `invisible'    — \\='bcp-chapter-headings (hidden until spec is removed)
  `bcp-element'  — \\='chapter-heading
  `bcp-chapter'  — CHAPTER (integer)"
  (let ((label (if (equal book "Psalms")
                   (format "[Psalm %d]" chapter)
                 (format "[Chapter %d]" chapter))))
    (propertize (concat "\n\n" label "\n")
                'bcp-element 'chapter-heading
                'bcp-chapter chapter
                'invisible   'bcp-chapter-headings)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Load default backend

(provide 'bcp-fetcher)                 ; provide before requiring backend to
(require 'bcp-fetcher-oremus)          ; avoid circular-require loop
;;; bcp-fetcher.el ends here
