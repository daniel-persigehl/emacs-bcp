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
;;   `bcp-fetcher-fetch'                  — async fetch with full fallback chain
;;   `bcp-fetcher-fetch-passage'          — async fetch, calls (load-fn text label)
;;   `bcp-fetcher-fetch-passage-context'  — async context fetch for omitted verses
;;   `bcp-fetcher-clean-text'             — strip Windows-1252 artefacts from text
;;   `bcp-fetcher-register-backend'       — register a fetch backend
;;   `bcp-fetcher-available-translations' — translations for the active backend
;;   `bcp-fetcher-clear-cache'            — clear the in-memory passage cache
;;
;; Fallback chain (attempted in order, first success wins):
;;   1. Primary backend, preferred translation
;;   2. Primary backend, `bcp-fetcher-fallback-translation' (default: KJVA)
;;   3. `bcp-fetcher-fallback-backend' (e.g. ebible), preferred translation
;;   → nil → render shows scriptural citation only
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

(defcustom bcp-fetcher-backend 'coverdale
  "Symbol identifying the active Bible text fetch backend.
Defaults to \\='coverdale, which serves the Psalter from the local
`bcp-fetcher-coverdale-file' and returns nil for all other passages,
allowing the fallback backend to handle them.
The backend must be registered via `bcp-fetcher-register-backend'."
  :type 'symbol
  :group 'bcp-fetcher)

(defcustom bcp-fetcher-fallback-backend 'oremus
  "Symbol identifying a fallback backend to try when the primary fails.
When the primary backend returns nil (fetch failed, timed out, or the
passage is outside its scope), this backend is tried next.  Defaults
to \\='oremus so non-Psalms passages pass through transparently when
the primary is \\='coverdale.  Nil means no fallback."
  :type '(choice (const :tag "None" nil) symbol)
  :group 'bcp-fetcher)

(defcustom bcp-fetcher-fallback-translation "KJVA"
  "Translation to try when the preferred translation fetch fails.
When a fetch returns nil (e.g. Coverdale unavailable or a network error),
this translation is tried with the primary backend before attempting the
fallback backend.  Nil disables translation fallback.
Defaults to \\\"KJVA\\\" — KJV with Apocrypha, reliably available on Oremus."
  :type '(choice string (const :tag "None" nil))
  :group 'bcp-fetcher)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; In-memory passage cache

(defcustom bcp-fetcher-cache-enable t
  "When non-nil, cache successfully fetched passages for the session.
Repeated fetches of the same passage and translation (e.g. on successive
office openings) are served from cache without a network round-trip.
Cache is per-session only; it is cleared when Emacs restarts or when
`bcp-fetcher-clear-cache' is called."
  :type 'boolean
  :group 'bcp-fetcher)

(defvar bcp-fetcher--cache (make-hash-table :test 'equal)
  "In-memory cache mapping (PASSAGE . TRANSLATION) keys to text strings.")

(defun bcp-fetcher-clear-cache ()
  "Clear the in-memory passage cache and reset local psalters."
  (interactive)
  (clrhash bcp-fetcher--cache)
  (setq bcp-fetcher--coverdale-psalms nil
        bcp-fetcher--vulgate-psalms nil)
  (message "bcp-fetcher: passage cache cleared."))

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

(defun bcp-fetcher--backend-for-translation (translation)
  "Return the fetch-fn for the backend that supports TRANSLATION, or nil.
Searches all registered backends (case-insensitive match on :translations)."
  (let ((tr-down (downcase translation))
        (result nil))
    (dolist (entry bcp-fetcher--backends result)
      (let* ((plist (cdr entry))
             (translations (plist-get plist :translations)))
        (when (cl-some (lambda (t-name) (string= tr-down (downcase t-name)))
                       translations)
          (setq result (plist-get plist :fetch-fn)))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public fetch API

(defun bcp-fetcher--try-attempts (passage attempts callback)
  "Try each (FETCH-FN . TRANSLATION) pair in ATTEMPTS in order.
For each attempt, check the cache first.  On success, store in cache and
call CALLBACK with the text.  On failure, try the next attempt.
If all attempts are exhausted, call CALLBACK with nil."
  (if (null attempts)
      (funcall callback nil)
    (let* ((attempt  (car attempts))
           (fetch-fn (car attempt))
           (tr       (cdr attempt))
           (key      (cons passage tr))
           (cached   (and bcp-fetcher-cache-enable
                          (gethash key bcp-fetcher--cache))))
      (if cached
          (funcall callback cached)
        (funcall fetch-fn passage tr
                 (lambda (text)
                   (if text
                       (progn
                         (when bcp-fetcher-cache-enable
                           (puthash key text bcp-fetcher--cache))
                         (funcall callback text))
                     (bcp-fetcher--try-attempts
                      passage (cdr attempts) callback))))))))

(defun bcp-fetcher-fetch (passage callback &optional translation)
  "Fetch PASSAGE using the active backend and call CALLBACK with formatted text.

TRANSLATION defaults to `bible-commentary-translation'.
CALLBACK is called as (CALLBACK text) where TEXT is a propertized string
with verse numbers formatted for visual-line-mode, or nil if every
attempt in the fallback chain fails.

The text properties from the backend are preserved — do NOT pass the result
through `bcp-fetcher-clean-text' as that would strip them.

Fallback chain (each step tried in order until one succeeds):
  1. Translation-matched backend (if a registered backend claims TRANSLATION)
  2. Primary backend, preferred translation
  3. Primary backend, `bcp-fetcher-fallback-translation' (default: KJVA)
  4. Fallback backend (`bcp-fetcher-fallback-backend'), preferred translation
Results are cached when `bcp-fetcher-cache-enable' is non-nil; the cache
is checked at each step before issuing a network fetch."
  (let* ((tr         (or translation bible-commentary-translation))
         (primary-fn (plist-get (bcp-fetcher--active-backend) :fetch-fn))
         (tr-fn      (bcp-fetcher--backend-for-translation tr))
         (fb-tr      (and bcp-fetcher-fallback-translation
                          (not (equal tr bcp-fetcher-fallback-translation))
                          bcp-fetcher-fallback-translation))
         (fb-fn      (let ((fb (and bcp-fetcher-fallback-backend
                                    (alist-get bcp-fetcher-fallback-backend
                                               bcp-fetcher--backends))))
                       (when fb (plist-get fb :fetch-fn))))
         (attempts   (delq nil
                           (list (when (and tr-fn (not (eq tr-fn primary-fn)))
                                   (cons tr-fn tr))
                                 (cons primary-fn tr)
                                 (when fb-tr (cons primary-fn fb-tr))
                                 (when fb-fn (cons fb-fn tr))))))
    (bcp-fetcher--try-attempts passage attempts callback)))
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
;;;; Coverdale Psalter local backend

(defcustom bcp-fetcher-coverdale-file
  (expand-file-name "bcp-liturgy-psalter-coverdale.txt"
                    (file-name-directory
                     (or load-file-name buffer-file-name default-directory)))
  "Path to the local Coverdale Psalter text file.
Generated by `bcp-coverdale-download-collate' and shipped with the BCP
package.  Format: psalm headers (\"Psalm N\") followed by tab-separated
verse lines (\"N\\tverse text\")."
  :type 'file
  :group 'bcp-fetcher)

(defvar bcp-fetcher--coverdale-psalms nil
  "Hash table mapping psalm numbers (integers) to verse vectors.
Populated lazily on first access by `bcp-fetcher--coverdale-load'.
Each vector element is a verse string (1-indexed: element 0 = verse 1).")

(defun bcp-fetcher--coverdale-load ()
  "Parse `bcp-fetcher-coverdale-file' into `bcp-fetcher--coverdale-psalms'.
Returns the hash table, or sets the variable to \\='unavailable and
signals an error if the file is missing."
  (unless (file-exists-p bcp-fetcher-coverdale-file)
    (setq bcp-fetcher--coverdale-psalms 'unavailable)
    (error "bcp-fetcher: Coverdale psalter file not found: %s"
           bcp-fetcher-coverdale-file))
  (let ((table  (make-hash-table :test 'eql))
        (psalm  nil)
        (verses nil))
    (with-temp-buffer
      (insert-file-contents bcp-fetcher-coverdale-file)
      (goto-char (point-min))
      (while (not (eobp))
        (let ((line (buffer-substring-no-properties
                     (line-beginning-position) (line-end-position))))
          (cond
           ((string-match "^Psalm \\([0-9]+\\)$" line)
            (when psalm
              (puthash psalm (vconcat (nreverse verses)) table))
            (setq psalm  (string-to-number (match-string 1 line))
                  verses nil))
           ((string-match "^[0-9]+\t\\(.*\\)$" line)
            (push (match-string 1 line) verses))))
        (forward-line 1))
      (when psalm
        (puthash psalm (vconcat (nreverse verses)) table)))
    (setq bcp-fetcher--coverdale-psalms table)))

(defun bcp-fetcher--coverdale-psalms ()
  "Return the Coverdale psalms hash table, loading it if not yet loaded.
Returns nil if the file was previously found to be unavailable."
  (cond
   ((eq bcp-fetcher--coverdale-psalms 'unavailable) nil)
   (bcp-fetcher--coverdale-psalms)
   (t (bcp-fetcher--coverdale-load))))

(defun bcp-fetcher--coverdale-render-psalm (n verses v-from v-to)
  "Render psalm N verse vector VERSES from V-FROM to V-TO as propertized text.
V-TO nil means render to end of psalm."
  (let* ((len   (length verses))
         (start (1- (max 1 (or v-from 1))))
         (end   (min len (or v-to len)))
         (result ""))
    (cl-loop for i from start below end
             for vnum = (1+ i)
             for text = (aref verses i)
             when (> (length text) 0) do
             (unless (string-empty-p result)
               (setq result (concat result "\n")))
             (let ((props (list 'bcp-verse vnum 'bcp-book "Psalms")))
               (when (= vnum 1)
                 (setq props (nconc props (list 'bcp-chapter n))))
               (setq result
                     (concat result
                             (apply #'propertize (substring text 0 1) props)
                             (substring text 1)))))
    (unless (string-empty-p result) result)))

(defun bcp-fetcher--coverdale-render (passage psalms)
  "Render PASSAGE from PSALMS hash table as propertized text, or nil."
  (cond
   ;; "Psalms N-M" — range of whole psalms
   ((string-match "^Psalms? \\([0-9]+\\)-\\([0-9]+\\)$" passage)
    (let ((from  (string-to-number (match-string 1 passage)))
          (to    (string-to-number (match-string 2 passage)))
          (parts nil))
      (cl-loop for n from from to to
               for verses = (gethash n psalms)
               when verses do
               (let ((rendered (bcp-fetcher--coverdale-render-psalm n verses 1 nil)))
                 (when rendered (push rendered parts))))
      (when parts
        (mapconcat #'identity (nreverse parts) "\n\n"))))
   ;; "Psalms N:V1-V2" or "Psalms N:V"
   ((string-match "^Psalms? \\([0-9]+\\):\\([0-9]+\\)\\(?:-\\([0-9]+\\)\\)?$" passage)
    (let* ((n      (string-to-number (match-string 1 passage)))
           (v1     (string-to-number (match-string 2 passage)))
           (v2     (when (match-string 3 passage)
                     (string-to-number (match-string 3 passage))))
           (verses (gethash n psalms)))
      (when verses
        (bcp-fetcher--coverdale-render-psalm n verses v1 v2))))
   ;; "Psalms N" — whole psalm
   ((string-match "^Psalms? \\([0-9]+\\)$" passage)
    (let* ((n      (string-to-number (match-string 1 passage)))
           (verses (gethash n psalms)))
      (when verses
        (bcp-fetcher--coverdale-render-psalm n verses 1 nil))))
   ;; Not a Psalms passage — let the fallback chain handle it
   (t nil)))

(defun bcp-fetcher--coverdale-fetch (passage _translation callback)
  "Serve PASSAGE from the local Coverdale psalter and call CALLBACK with text.
Returns nil for non-Psalms passages so the fallback chain continues."
  (let ((text (condition-case err
                  (bcp-fetcher--coverdale-render passage (bcp-fetcher--coverdale-psalms))
                (error
                 (message "bcp-fetcher-coverdale: %s" (error-message-string err))
                 nil))))
    (when text
      (message "bcp-fetcher: %s served from local Coverdale psalter." passage))
    (funcall callback text)))

(bcp-fetcher-register-backend
 'coverdale
 :name         "Coverdale Psalter (local)"
 :fetch-fn     #'bcp-fetcher--coverdale-fetch
 :translations '("Coverdale" "BCP"))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Vulgate Psalter (local)

(defcustom bcp-fetcher-vulgate-file
  (expand-file-name "bcp-liturgy-psalter-vulgate.txt"
                    (file-name-directory
                     (or load-file-name buffer-file-name default-directory)))
  "Path to the local Latin Vulgate Psalter text file.
Generated by `bcp-vulgate-collate' from the Divinum Officium source
files.  Format matches the Coverdale psalter: \"Psalm N\" headers under
Vulgate numbering followed by tab-separated verse lines."
  :type 'file
  :group 'bcp-fetcher)

(defvar bcp-fetcher--vulgate-psalms nil
  "Hash table mapping Vulgate psalm numbers (integers) to verse vectors.
Populated lazily by `bcp-fetcher--vulgate-load'.")

(defun bcp-fetcher--vulgate-load ()
  "Parse `bcp-fetcher-vulgate-file' into `bcp-fetcher--vulgate-psalms'."
  (unless (file-exists-p bcp-fetcher-vulgate-file)
    (setq bcp-fetcher--vulgate-psalms 'unavailable)
    (error "bcp-fetcher: Vulgate psalter file not found: %s"
           bcp-fetcher-vulgate-file))
  (let ((table  (make-hash-table :test 'eql))
        (psalm  nil)
        (verses nil))
    (with-temp-buffer
      (insert-file-contents bcp-fetcher-vulgate-file)
      (goto-char (point-min))
      (while (not (eobp))
        (let ((line (buffer-substring-no-properties
                     (line-beginning-position) (line-end-position))))
          (cond
           ((string-match "^Psalm \\([0-9]+\\)$" line)
            (when psalm
              (puthash psalm (vconcat (nreverse verses)) table))
            (setq psalm  (string-to-number (match-string 1 line))
                  verses nil))
           ((string-match "^[0-9]+\t\\(.*\\)$" line)
            (push (match-string 1 line) verses))))
        (forward-line 1))
      (when psalm
        (puthash psalm (vconcat (nreverse verses)) table)))
    (setq bcp-fetcher--vulgate-psalms table)))

(defun bcp-fetcher--vulgate-psalms ()
  "Return the Vulgate psalms hash table, loading if necessary."
  (cond
   ((eq bcp-fetcher--vulgate-psalms 'unavailable) nil)
   (bcp-fetcher--vulgate-psalms)
   (t (bcp-fetcher--vulgate-load))))

(defun bcp-fetcher--bcp-to-vulgate (n)
  "Map BCP/Hebrew psalm number N to Vulgate psalm resolution.
Returns one of:
  (VULG-N)                   — whole psalm
  (VULG-N V-FROM V-TO)      — partial psalm (verse range)
  ((VULG-A) (VULG-B))       — concatenation of two whole psalms
  nil                        — no content (BCP 10, subsumed by Vulg 9)"
  (cond
   ((<= n 8)   (list n))
   ((= n 9)    '(9))
   ((= n 10)   nil)                     ; content is in Vulgate 9
   ((<= n 113) (list (1- n)))
   ((= n 114)  '(113 1 8))              ; Vulgate 113 vv.1-8
   ((= n 115)  '(113 9 nil))            ; Vulgate 113 vv.9-end
   ((= n 116)  '((114) (115)))          ; Vulgate 114 + 115
   ((<= n 146) (list (1- n)))
   ((= n 147)  '((146) (147)))          ; Vulgate 146 + 147
   (t          (list n))))              ; 148-150 same

(defun bcp-fetcher--vulgate-render (passage psalms)
  "Render PASSAGE from Vulgate PSALMS hash table, applying BCP→Vulgate mapping."
  (cond
   ;; "Psalms N-M" — range of whole psalms
   ((string-match "^Psalms? \\([0-9]+\\)-\\([0-9]+\\)$" passage)
    (let ((from  (string-to-number (match-string 1 passage)))
          (to    (string-to-number (match-string 2 passage)))
          (parts nil))
      (cl-loop for bcp from from to to
               for mapping = (bcp-fetcher--bcp-to-vulgate bcp)
               when mapping do
               (let ((rendered (bcp-fetcher--vulgate-render-mapping mapping psalms)))
                 (when rendered (push rendered parts))))
      (when parts
        (mapconcat #'identity (nreverse parts) "\n\n"))))
   ;; "Psalms N:V1-V2" — verse range (BCP numbering on the psalm)
   ((string-match "^Psalms? \\([0-9]+\\):\\([0-9]+\\)\\(?:-\\([0-9]+\\)\\)?$" passage)
    (let* ((bcp-n  (string-to-number (match-string 1 passage)))
           (v1     (string-to-number (match-string 2 passage)))
           (v2     (when (match-string 3 passage)
                     (string-to-number (match-string 3 passage))))
           (mapping (bcp-fetcher--bcp-to-vulgate bcp-n)))
      (when mapping
        ;; For whole-psalm mappings, apply the verse range
        (if (numberp (car mapping))
            (let ((vulg-n (car mapping))
                  (verses (gethash (car mapping) psalms)))
              (when verses
                (bcp-fetcher--coverdale-render-psalm vulg-n verses v1 v2)))
          ;; For concatenated psalms, render fully (verse sub-range
          ;; across a concatenation boundary is unusual)
          (bcp-fetcher--vulgate-render-mapping mapping psalms)))))
   ;; "Psalms N" — whole psalm
   ((string-match "^Psalms? \\([0-9]+\\)$" passage)
    (let* ((bcp-n   (string-to-number (match-string 1 passage)))
           (mapping (bcp-fetcher--bcp-to-vulgate bcp-n)))
      (when mapping
        (bcp-fetcher--vulgate-render-mapping mapping psalms))))
   (t nil)))

(defun bcp-fetcher--vulgate-render-mapping (mapping psalms)
  "Render a single MAPPING result from `bcp-fetcher--bcp-to-vulgate' using PSALMS."
  (if (and (consp (car mapping)) (listp (car mapping)))
      ;; Concatenation: ((VULG-A) (VULG-B))
      (let ((parts nil))
        (dolist (sub mapping)
          (let* ((vulg-n (car sub))
                 (verses (gethash vulg-n psalms)))
            (when verses
              (let ((rendered (bcp-fetcher--coverdale-render-psalm vulg-n verses 1 nil)))
                (when rendered (push rendered parts))))))
        (when parts
          (mapconcat #'identity (nreverse parts) "\n")))
    ;; Single psalm, possibly with verse range
    (let* ((vulg-n (car mapping))
           (v-from (nth 1 mapping))
           (v-to   (nth 2 mapping))
           (verses (gethash vulg-n psalms)))
      (when verses
        (bcp-fetcher--coverdale-render-psalm vulg-n verses
                                             (or v-from 1) v-to)))))

(defun bcp-fetcher--vulgate-fetch (passage _translation callback)
  "Serve PASSAGE from the local Vulgate psalter and call CALLBACK with text."
  (let ((text (condition-case err
                  (bcp-fetcher--vulgate-render passage (bcp-fetcher--vulgate-psalms))
                (error
                 (message "bcp-fetcher-vulgate: %s" (error-message-string err))
                 nil))))
    (when text
      (message "bcp-fetcher: %s served from local Vulgate psalter." passage))
    (funcall callback text)))

(bcp-fetcher-register-backend
 'vulgate
 :name         "Vulgate Psalter (local)"
 :fetch-fn     #'bcp-fetcher--vulgate-fetch
 :translations '("Vulgate" "Latin"))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Load default backend

(provide 'bcp-fetcher)                 ; provide before requiring backend to
(require 'bcp-fetcher-oremus)          ; avoid circular-require loop
;;; bcp-fetcher.el ends here
