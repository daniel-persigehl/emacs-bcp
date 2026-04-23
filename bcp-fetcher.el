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

(declare-function svg-create "svg" (width height &rest args))
(declare-function svg-text   "svg" (svg text &rest args))
(declare-function svg-image  "svg" (svg &rest props))

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
  (when (boundp 'bcp-fetcher--rubi-svg-cache)
    (clrhash bcp-fetcher--rubi-svg-cache))
  (setq bcp-fetcher--coverdale-psalms nil
        bcp-fetcher--tate-brady-psalms nil
        bcp-fetcher--vulgate-psalms nil
        bcp-fetcher--bungo-yaku-bible nil)
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
  :translations LIST  — list of supported translation name strings
Optional:
  :psalm-numbering SYM — psalm numbering scheme: hebrew (alias: kjv,
                         masoretic) or lxx (alias: vulgate, septuagint).
                         Used by the psalm-mapping layer to convert
                         between numbering systems when caller and
                         backend disagree.  Default: hebrew."
  (when-let ((pn (plist-get plist :psalm-numbering)))
    (plist-put plist :psalm-numbering (bcp-fetcher--normalize-psalm-numbering pn)))
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
  5. Fallback backend, `bcp-fetcher-fallback-translation'
Step 5 covers the case where the preferred translation isn't a non-psalm
source (e.g. Vulgate psalter-only) AND the fallback backend can't serve
the preferred translation either — the final rescue is fallback-backend
with fallback-translation.
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
                                 (when fb-fn (cons fb-fn tr))
                                 (when (and fb-fn fb-tr)
                                   (cons fb-fn fb-tr))))))
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
;;;; Psalm numbering: Hebrew ↔ LXX (Septuagint/Vulgate) conversion

(defun bcp-fetcher--normalize-psalm-numbering (scheme)
  "Normalize SCHEME to canonical psalm-numbering symbol.
Accepts aliases: kjv/masoretic → hebrew; vulgate/septuagint → lxx."
  (pcase scheme
    ((or 'hebrew 'kjv 'masoretic) 'hebrew)
    ((or 'lxx 'vulgate 'septuagint) 'lxx)
    (_ (error "Unknown psalm-numbering scheme: %s" scheme))))

(defun bcp-fetcher--hebrew-to-lxx (n)
  "Map Hebrew psalm number N to LXX/Vulgate psalm resolution.
Returns one of:
  (LXX-N)                    — whole psalm
  (LXX-N V-FROM V-TO)       — partial psalm (verse range)
  ((LXX-A) (LXX-B))         — concatenation of two whole psalms
  nil                        — no content (Hebrew 10, subsumed by LXX 9)"
  (cond
   ((<= n 8)   (list n))
   ((= n 9)    '(9))
   ((= n 10)   nil)                     ; content is in LXX 9
   ((<= n 113) (list (1- n)))
   ((= n 114)  '(113 1 8))             ; LXX 113 vv.1-8
   ((= n 115)  '(113 9 nil))           ; LXX 113 vv.9-end
   ((= n 116)  '((114) (115)))         ; LXX 114 + 115
   ((<= n 146) (list (1- n)))
   ((= n 147)  '((146) (147)))         ; LXX 146 + 147
   (t          (list n))))              ; 148-150 same

(defun bcp-fetcher--lxx-to-hebrew (n)
  "Map LXX/Vulgate psalm number N to Hebrew psalm resolution.
Returns one of:
  (HEB-N)                    — whole psalm
  (HEB-N V-FROM V-TO)       — partial psalm (verse range)
  ((HEB-A) (HEB-B))         — concatenation of two whole psalms"
  (cond
   ((<= n 8)   (list n))
   ((= n 9)    '((9) (10)))            ; Hebrew 9 + 10
   ((<= n 112) (list (1+ n)))
   ((= n 113)  '((114) (115)))         ; Hebrew 114 + 115
   ((= n 114)  '(116 1 9))             ; Hebrew 116 vv.1-9
   ((= n 115)  '(116 10 nil))          ; Hebrew 116 vv.10-end
   ((<= n 145) (list (1+ n)))
   ((= n 146)  '(147 1 11))            ; Hebrew 147 vv.1-11
   ((= n 147)  '(147 12 nil))          ; Hebrew 147 vv.12-end
   (t          (list n))))              ; 148-150 same

(defun bcp-fetcher--convert-psalm-ref (ref from-scheme to-scheme)
  "Convert a psalm scripture REF string between numbering schemes.
FROM-SCHEME and TO-SCHEME are canonical symbols (hebrew or lxx).
Returns the converted ref string, or REF unchanged if not a psalm
or if the schemes match."
  (if (eq from-scheme to-scheme)
      ref
    (let ((map-fn (if (eq from-scheme 'lxx)
                      #'bcp-fetcher--lxx-to-hebrew
                    #'bcp-fetcher--hebrew-to-lxx)))
      (cond
       ;; "Psalm N:V..." — convert the psalm number, keep the verse part
       ((string-match "^\\(Psalms?\\) \\([0-9]+\\)\\(.*\\)" ref)
        (let* ((prefix (match-string 1 ref))
               (ps-num (string-to-number (match-string 2 ref)))
               (rest   (match-string 3 ref))
               (mapping (funcall map-fn ps-num)))
          (if (and mapping (numberp (car mapping)))
              (format "%s %d%s" prefix (car mapping) rest)
            ;; Split/merge — just convert the number, caller handles complexity
            (if (and mapping (consp (car mapping)))
                (format "%s %d%s" prefix (caar mapping) rest)
              ref))))
       (t ref)))))

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
 :name            "Coverdale Psalter (local)"
 :fetch-fn        #'bcp-fetcher--coverdale-fetch
 :psalm-numbering 'hebrew
 :translations    '("Coverdale" "BCP"))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Tate & Brady Metrical Psalter (local)

(defcustom bcp-fetcher-tate-brady-file
  (expand-file-name "bcp-liturgy-psalter-tate-brady.txt"
                    (file-name-directory
                     (or load-file-name buffer-file-name default-directory)))
  "Path to the local Tate & Brady metrical psalter text file.
Format: \"Psalm N\" headings, verse lines starting with an integer
followed by a space, continuation lines indented by two spaces,
blank lines between stanzas, and \"--- Part N ---\" markers for
the long psalms the 1698 edition sub-divides for performance."
  :type 'file
  :group 'bcp-fetcher)

(defvar bcp-fetcher--tate-brady-psalms nil
  "Hash table mapping psalm numbers to parsed Tate & Brady records.
Each record is an ordered list of blocks.  A block is one of:
  (:stanza VERSES TEXT)  — VERSES is a list of verse numbers the
                           stanza contains; TEXT is the rendered
                           stanza with newlines preserved.
  (:part NAME)           — a Part heading (e.g. \"Part II\").
Populated lazily by `bcp-fetcher--tate-brady-load'.")

(defun bcp-fetcher--tate-brady-load ()
  "Parse `bcp-fetcher-tate-brady-file' into `bcp-fetcher--tate-brady-psalms'.
Returns the hash table, or sets the variable to \\='unavailable and
signals an error if the file is missing."
  (unless (file-exists-p bcp-fetcher-tate-brady-file)
    (setq bcp-fetcher--tate-brady-psalms 'unavailable)
    (error "bcp-fetcher: Tate & Brady psalter file not found: %s"
           bcp-fetcher-tate-brady-file))
  (let ((table         (make-hash-table :test 'eql))
        (psalm         nil)
        (blocks        nil)
        (stanza-lines  nil)
        (stanza-verses nil))
    (cl-labels
        ((flush-stanza ()
           (when stanza-lines
             (push (list :stanza
                         (nreverse stanza-verses)
                         (mapconcat #'identity (nreverse stanza-lines) "\n"))
                   blocks)
             (setq stanza-lines nil
                   stanza-verses nil)))
         (flush-psalm ()
           (flush-stanza)
           (when psalm
             (puthash psalm (nreverse blocks) table)
             (setq psalm nil blocks nil))))
      (with-temp-buffer
        (insert-file-contents bcp-fetcher-tate-brady-file)
        (goto-char (point-min))
        (while (not (eobp))
          (let ((line (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position))))
            (cond
             ((string-prefix-p ";" line) nil)
             ((string-match "^Psalm \\([0-9]+\\)$" line)
              (flush-psalm)
              (setq psalm (string-to-number (match-string 1 line))))
             ((string-match "^--- \\(Part [IVX]+\\) ---$" line)
              (flush-stanza)
              (push (list :part (match-string 1 line)) blocks))
             ((string-empty-p line)
              (flush-stanza))
             ((string-match "^\\([0-9]+\\) .*$" line)
              (push (string-to-number (match-string 1 line)) stanza-verses)
              (push line stanza-lines))
             ((string-match "^  .+$" line)
              (push line stanza-lines))))
          (forward-line 1))
        (flush-psalm)))
    (setq bcp-fetcher--tate-brady-psalms table)))

(defun bcp-fetcher--tate-brady-psalms ()
  "Return the Tate & Brady psalms hash table, loading it if needed.
Returns nil if the file was previously found to be unavailable."
  (cond
   ((eq bcp-fetcher--tate-brady-psalms 'unavailable) nil)
   (bcp-fetcher--tate-brady-psalms)
   (t (bcp-fetcher--tate-brady-load))))

(defun bcp-fetcher--tate-brady-stanza-overlaps-p (block v-from v-to)
  "Non-nil if stanza BLOCK contains any verse in [V-FROM, V-TO]."
  (when (eq (car block) :stanza)
    (cl-some (lambda (v)
               (and (>= v v-from) (or (null v-to) (<= v v-to))))
             (nth 1 block))))

(defun bcp-fetcher--tate-brady-filter-blocks (blocks v-from v-to)
  "Return BLOCKS trimmed to stanzas overlapping [V-FROM, V-TO].
Part-heads are retained when any stanza after them survives; leading
and trailing orphan Part-heads are dropped."
  (if (and (or (null v-from) (<= v-from 1)) (null v-to))
      blocks
    (let ((kept nil)
          (pending-part nil))
      (dolist (b blocks)
        (pcase (car b)
          (:part (setq pending-part b))
          (:stanza
           (when (bcp-fetcher--tate-brady-stanza-overlaps-p b v-from v-to)
             (when pending-part
               (push pending-part kept)
               (setq pending-part nil))
             (push b kept)))))
      (nreverse kept))))

(defun bcp-fetcher--tate-brady-render-psalm (n blocks v-from v-to)
  "Render T&B psalm N for verses V-FROM..V-TO as propertized text.
V-FROM nil or 1 means from the start; V-TO nil means through the end."
  (let* ((kept (bcp-fetcher--tate-brady-filter-blocks blocks v-from v-to))
         (rendered
          (mapconcat
           (lambda (b)
             (pcase (car b)
               (:stanza (nth 2 b))
               (:part (concat "    " (nth 1 b)))))
           kept "\n\n")))
    (when (> (length rendered) 0)
      (let ((pos 0))
        (while (string-match "^\\([0-9]+\\) " rendered pos)
          (let* ((vstart (match-beginning 0))
                 (vnum   (string-to-number (match-string 1 rendered)))
                 (props  (list 'bcp-verse vnum 'bcp-book "Psalms")))
            (when (= vnum 1)
              (setq props (nconc props (list 'bcp-chapter n))))
            (add-text-properties vstart (1+ vstart) props rendered)
            (setq pos (match-end 0)))))
      rendered)))

(defun bcp-fetcher--tate-brady-render (passage psalms)
  "Render PASSAGE from PSALMS hash table as propertized text, or nil."
  (cond
   ((string-match "^Psalms? \\([0-9]+\\)-\\([0-9]+\\)$" passage)
    (let ((from  (string-to-number (match-string 1 passage)))
          (to    (string-to-number (match-string 2 passage)))
          (parts nil))
      (cl-loop for n from from to to
               for blocks = (gethash n psalms)
               when blocks do
               (let ((rendered (bcp-fetcher--tate-brady-render-psalm
                                n blocks nil nil)))
                 (when rendered (push rendered parts))))
      (when parts
        (mapconcat #'identity (nreverse parts) "\n\n"))))
   ((string-match "^Psalms? \\([0-9]+\\):\\([0-9]+\\)\\(?:-\\([0-9]+\\)\\)?$" passage)
    (let* ((n      (string-to-number (match-string 1 passage)))
           (v1     (string-to-number (match-string 2 passage)))
           (v2     (when (match-string 3 passage)
                     (string-to-number (match-string 3 passage))))
           (blocks (gethash n psalms)))
      (when blocks
        (bcp-fetcher--tate-brady-render-psalm n blocks v1 v2))))
   ((string-match "^Psalms? \\([0-9]+\\)$" passage)
    (let* ((n      (string-to-number (match-string 1 passage)))
           (blocks (gethash n psalms)))
      (when blocks
        (bcp-fetcher--tate-brady-render-psalm n blocks nil nil))))
   (t nil)))

(defun bcp-fetcher--tate-brady-fetch (passage _translation callback)
  "Serve PASSAGE from the local Tate & Brady psalter and call CALLBACK.
Returns nil for non-Psalms passages so the fallback chain continues."
  (let ((text (condition-case err
                  (bcp-fetcher--tate-brady-render
                   passage (bcp-fetcher--tate-brady-psalms))
                (error
                 (message "bcp-fetcher-tate-brady: %s"
                          (error-message-string err))
                 nil))))
    (when text
      (message "bcp-fetcher: %s served from Tate & Brady metrical psalter."
               passage))
    (funcall callback text)))

(bcp-fetcher-register-backend
 'tate-brady
 :name            "Tate & Brady Metrical Psalter (local, 1698)"
 :fetch-fn        #'bcp-fetcher--tate-brady-fetch
 :psalm-numbering 'hebrew
 :translations    '("Tate & Brady" "T&B"))

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
  "Map BCP/Hebrew psalm number N to Vulgate/LXX psalm resolution.
Wrapper around `bcp-fetcher--hebrew-to-lxx' for backward compatibility."
  (bcp-fetcher--hebrew-to-lxx n))

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
 :name            "Vulgate Psalter (local)"
 :fetch-fn        #'bcp-fetcher--vulgate-fetch
 :psalm-numbering 'lxx
 :translations    '("Vulgate" "Latin"))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Bungo-yaku 文語訳 (local full Bible)

(defcustom bcp-fetcher-furigana-display 'comment
  "How to display furigana (《reading》) in Bungo-yaku text.
`normal'  — display as normal text, same as surrounding kanji.
`comment' — display in a muted face (inherits `font-lock-comment-face').
`hidden'  — hide furigana entirely (can be toggled with
            `bcp-fetcher-toggle-furigana').
`rubi'    — hide the inline 《…》 markers and render the reading as a
            half-height strip above the kanji span (overhead rubi)."
  :type '(choice (const :tag "Normal text" normal)
                 (const :tag "Comment face (muted)" comment)
                 (const :tag "Hidden" hidden)
                 (const :tag "Overhead rubi" rubi))
  :group 'bcp-fetcher)

(defface bcp-fetcher-furigana
  '((t :inherit font-lock-comment-face :height 0.85))
  "Face for furigana readings in Bungo-yaku text.
Used when `bcp-fetcher-furigana-display' is `comment'."
  :group 'bcp-fetcher)

(defun bcp-fetcher--rubi-kanji-char-p (c)
  "Non-nil if C is a CJK ideograph eligible to carry a rubi reading.
Covers the Basic, Ext-A, and Ext-B ranges plus compatibility block."
  (or (and (>= c #x3400) (<= c #x4DBF))     ; CJK Ext A
      (and (>= c #x4E00) (<= c #x9FFF))     ; CJK Unified
      (and (>= c #xF900) (<= c #xFAFF))     ; Compatibility
      (and (>= c #x20000) (<= c #x2A6DF)))) ; CJK Ext B

(defun bcp-fetcher--kanji-span-start (str end)
  "Return index in STR of the start of the kanji run ending at END.
Scans backward from END while characters are CJK ideographs."
  (let ((i end))
    (while (and (> i 0)
                (bcp-fetcher--rubi-kanji-char-p (aref str (1- i))))
      (setq i (1- i)))
    i))

(defun bcp-fetcher--propertize-furigana (str)
  "Apply furigana display properties to 《reading》 spans in STR.
Respects `bcp-fetcher-furigana-display'.
Also stamps the first character of each preceding kanji span with
`bcp-rubi-reading' (the kana reading) and `bcp-rubi-base-width'
(visual width of the kanji span in default-face columns), so the
rubi renderer can locate and align spans at finalise time."
  (let ((result (copy-sequence str))
        (start 0))
    (while (string-match "《\\([^》]+\\)》" result start)
      (let* ((beg       (match-beginning 0))
             (end       (match-end 0))
             (reading   (match-string 1 result))
             (kanji-beg (bcp-fetcher--kanji-span-start result beg))
             (kanji-width (when (< kanji-beg beg)
                            (string-width (substring result kanji-beg beg)))))
        (put-text-property beg end 'bcp-furigana t result)
        (when kanji-width
          (put-text-property kanji-beg (1+ kanji-beg)
                             'bcp-rubi-reading reading result)
          (put-text-property kanji-beg (1+ kanji-beg)
                             'bcp-rubi-base-width kanji-width result))
        (pcase bcp-fetcher-furigana-display
          ('comment
           (put-text-property beg end 'face 'bcp-fetcher-furigana result))
          ((or 'hidden 'rubi)
           (put-text-property beg end 'invisible 'bcp-furigana result)))
        (setq start end)))
    result))

(defun bcp-fetcher--walk-furigana (prop value)
  "Set PROP to VALUE on all `bcp-furigana' spans in the current buffer."
  (let ((inhibit-read-only t)
        (pos (point-min)))
    (while (setq pos (text-property-any pos (point-max) 'bcp-furigana t))
      (let ((end (next-single-property-change pos 'bcp-furigana nil
                                              (point-max))))
        (put-text-property pos end prop value)
        (setq pos end)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Overhead rubi rendering — SVG images
;;;;
;;;; For each kanji span carrying a `bcp-rubi-reading' property, we generate
;;;; an inline SVG image containing the kanji at the baseline and the
;;;; reading kana at roughly half-size centered above, then replace the
;;;; kanji-span's display with that image via a `display' text property.
;;;; The underlying characters stay in the buffer, so search, copy, and
;;;; cursor navigation work normally.
;;;;
;;;; Width of each SVG equals the kanji span's natural width
;;;; (2 × frame-char-width × N-kanji), so text flow is unchanged regardless
;;;; of reading length — a long reading just shrinks to fit.
;;;;
;;;; Requires Emacs built with SVG support.  When `(image-type-available-p
;;;; 'svg)' is nil, the finalise step skips the SVG pass and leaves the
;;;; 《…》 markers visible as a graceful fallback.

(defcustom bcp-fetcher-rubi-svg-font
  "Noto Serif CJK JP, Noto Sans CJK JP, Sazanami Mincho, IPAMincho, serif"
  "CSS font-family used for overhead rubi SVGs.
Comma-separated fallback chain as in CSS; the first family
available in the rendering backend (librsvg/fontconfig) wins."
  :type 'string
  :group 'bcp-fetcher)

(defcustom bcp-fetcher-rubi-svg-kanji-scale 0.62
  "Kanji font-size as a fraction of `frame-char-height' inside rubi SVGs.
SVG text at font-size = full line-height renders visually larger
than the same glyph in buffer, so a value under 1.0 usually looks
right.  Call `bcp-fetcher-clear-cache' after changing this."
  :type 'number
  :group 'bcp-fetcher)

(defcustom bcp-fetcher-rubi-svg-reading-scale 0.5
  "Reading font-size as a fraction of the SVG kanji font-size.
0.5 is the classic half-size rubi proportion.  Call
`bcp-fetcher-clear-cache' after changing this."
  :type 'number
  :group 'bcp-fetcher)

(defvar bcp-fetcher--rubi-svg-cache (make-hash-table :test 'equal)
  "Hash table caching rubi SVG images keyed by (kanji . reading).
Cleared by `bcp-fetcher-clear-cache'.")

(defun bcp-fetcher--rubi-svg-build (kanji reading)
  "Return an image spec showing READING above KANJI, or nil if no SVG support."
  (when (image-type-available-p 'svg)
    (require 'svg)
    (let* ((fw            (frame-char-width))
           (fh            (frame-char-height))
           (nkanji        (length kanji))
           (width         (* 2 nkanji fw))
           (kanji-size    (max 2 (round (* fh bcp-fetcher-rubi-svg-kanji-scale))))
           (reading-size  (max 2 (round (* kanji-size
                                           bcp-fetcher-rubi-svg-reading-scale))))
           (rubi-gap      1)
           (height        (+ reading-size rubi-gap kanji-size 1))
           ;; If the reading is wider than the span at the nominal size, shrink
           ;; it further so it still fits above the kanji.  CJK kana at font-
           ;; size N render ≈ N pixels wide; leave a ~5% margin so edges don't
           ;; clip against the SVG viewport.
           (safe-width        (* width 0.95))
           (approx-reading-px (* (length reading) reading-size))
           (reading-size  (if (> approx-reading-px safe-width)
                              (max 4 (floor (* reading-size
                                               (/ safe-width
                                                  approx-reading-px))))
                            reading-size))
           (reading-y     (+ reading-size 0))
           (kanji-y       (- height 2))
           (fg            (or (face-attribute 'default :foreground nil 'default)
                              "black"))
           (svg           (svg-create width height)))
      (svg-text svg reading
                :x (/ width 2) :y reading-y
                :text-anchor "middle"
                :font-size reading-size
                :font-family bcp-fetcher-rubi-svg-font
                :fill fg)
      (svg-text svg kanji
                :x (/ width 2) :y kanji-y
                :text-anchor "middle"
                :font-size kanji-size
                :font-family bcp-fetcher-rubi-svg-font
                :fill fg)
      (svg-image svg :ascent (round (* 100.0 (/ (float kanji-y) height)))))))

(defun bcp-fetcher--rubi-svg (kanji reading)
  "Return a cached image spec for KANJI+READING, or nil if no SVG support."
  (let ((key (cons kanji reading)))
    (or (gethash key bcp-fetcher--rubi-svg-cache)
        (let ((img (bcp-fetcher--rubi-svg-build kanji reading)))
          (when img (puthash key img bcp-fetcher--rubi-svg-cache))
          img))))

(defun bcp-fetcher--rubi-apply-svg ()
  "Replace every kanji+reading span with its rubi SVG image.
No-op when SVG is unavailable — caller should leave the 《…》
markers visible as the fallback."
  (when (image-type-available-p 'svg)
    (save-excursion
      (let ((inhibit-read-only t))
        (goto-char (point-min))
        (while (not (eobp))
          (let ((reading (get-text-property (point) 'bcp-rubi-reading))
                (width   (get-text-property (point) 'bcp-rubi-base-width)))
            (cond
             ((and reading width)
              (let* ((end   (+ (point) (/ width 2)))
                     (kanji (buffer-substring-no-properties (point) end))
                     (image (bcp-fetcher--rubi-svg kanji reading)))
                (when image
                  (put-text-property (point) end 'display image)
                  (put-text-property (point) end 'bcp-rubi-svg t))
                (goto-char end)))
             (t
              (goto-char (or (next-single-property-change
                              (point) 'bcp-rubi-reading nil (point-max))
                             (point-max)))))))))))

(defun bcp-fetcher--rubi-remove-svg ()
  "Strip any rubi-SVG display properties from the current buffer."
  (save-excursion
    (let ((inhibit-read-only t)
          (pos (point-min)))
      (while (setq pos (text-property-any pos (point-max) 'bcp-rubi-svg t))
        (let ((end (or (next-single-property-change
                        pos 'bcp-rubi-svg nil (point-max))
                       (point-max))))
          (remove-text-properties pos end '(display nil bcp-rubi-svg nil))
          (setq pos end))))))

(defvar-local bcp-fetcher--furigana-toggled-off nil
  "Non-nil when `bcp-fetcher-toggle-furigana' has hidden furigana in this buffer.
Cleared when the user toggles it back on.")

(defun bcp-fetcher--furigana-hide-all ()
  "Hide every furigana annotation in the current buffer.
Strips any rubi SVGs and marks every 《…》 span invisible."
  (when (text-property-any (point-min) (point-max) 'bcp-rubi-svg t)
    (bcp-fetcher--rubi-remove-svg))
  (add-to-invisibility-spec 'bcp-furigana)
  (bcp-fetcher--walk-furigana 'face nil)
  (bcp-fetcher--walk-furigana 'invisible 'bcp-furigana)
  (setq bcp-fetcher--furigana-toggled-off t))

(defun bcp-fetcher--furigana-show-configured ()
  "Display furigana in the current buffer per `bcp-fetcher-furigana-display'."
  (bcp-fetcher--rubi-remove-svg)
  (pcase bcp-fetcher-furigana-display
    ('normal
     (remove-from-invisibility-spec 'bcp-furigana)
     (bcp-fetcher--walk-furigana 'invisible nil)
     (bcp-fetcher--walk-furigana 'face nil))
    ('comment
     (remove-from-invisibility-spec 'bcp-furigana)
     (bcp-fetcher--walk-furigana 'invisible nil)
     (bcp-fetcher--walk-furigana 'face 'bcp-fetcher-furigana))
    ('hidden
     (add-to-invisibility-spec 'bcp-furigana)
     (bcp-fetcher--walk-furigana 'face nil)
     (bcp-fetcher--walk-furigana 'invisible 'bcp-furigana))
    ('rubi
     (cond
      ((image-type-available-p 'svg)
       (add-to-invisibility-spec 'bcp-furigana)
       (bcp-fetcher--walk-furigana 'face nil)
       (bcp-fetcher--walk-furigana 'invisible 'bcp-furigana)
       (bcp-fetcher--rubi-apply-svg))
      (t
       (remove-from-invisibility-spec 'bcp-furigana)
       (bcp-fetcher--walk-furigana 'invisible nil)
       (bcp-fetcher--walk-furigana 'face nil)))))
  (setq bcp-fetcher--furigana-toggled-off nil))

(defun bcp-fetcher-rubi-svg-diagnose ()
  "Report the pixel dimensions currently used for rubi SVGs."
  (interactive)
  (let* ((fw (frame-char-width))
         (fh (frame-char-height))
         (kanji-size (max 2 (round (* fh bcp-fetcher-rubi-svg-kanji-scale))))
         (reading-size (max 2 (round (* kanji-size
                                        bcp-fetcher-rubi-svg-reading-scale)))))
    (message
     "rubi SVG: frame-char %dx%dpx | kanji-scale %.3f → %dpx | reading-scale %.3f → %dpx"
     fw fh bcp-fetcher-rubi-svg-kanji-scale kanji-size
     bcp-fetcher-rubi-svg-reading-scale reading-size)))

(defun bcp-fetcher--buffer-has-rubi-p (buf)
  "Non-nil if BUF contains any `bcp-rubi-reading' or `bcp-furigana' property."
  (and (buffer-live-p buf)
       (with-current-buffer buf
         (save-excursion
           (goto-char (point-min))
           (let (found)
             (while (and (not found) (not (eobp)))
               (if (or (get-text-property (point) 'bcp-rubi-reading)
                       (get-text-property (point) 'bcp-furigana))
                   (setq found t)
                 (goto-char
                  (min (or (next-single-property-change
                            (point) 'bcp-rubi-reading nil (point-max))
                           (point-max))
                       (or (next-single-property-change
                            (point) 'bcp-furigana nil (point-max))
                           (point-max))))))
             found)))))

(defun bcp-fetcher--rubi-target-buffer ()
  "Return a buffer containing furigana annotations.
Prefers the current buffer; otherwise returns the first live buffer
with `bcp-rubi-reading' or `bcp-furigana' properties, or nil."
  (if (bcp-fetcher--buffer-has-rubi-p (current-buffer))
      (current-buffer)
    (seq-find #'bcp-fetcher--buffer-has-rubi-p (buffer-list))))

(defun bcp-fetcher-toggle-furigana ()
  "Toggle furigana visibility in a buffer with furigana content.
Switches between the configured display mode (per
`bcp-fetcher-furigana-display', settable under Advanced settings)
and fully hidden.  Operates on the current buffer if it contains
furigana annotations, otherwise the first buffer that does."
  (interactive)
  (let ((buf (bcp-fetcher--rubi-target-buffer)))
    (unless buf
      (user-error "No buffer with furigana annotations is open"))
    (with-current-buffer buf
      (if bcp-fetcher--furigana-toggled-off
          (progn (bcp-fetcher--furigana-show-configured)
                 (message "Furigana shown (%s) in %s."
                          bcp-fetcher-furigana-display (buffer-name)))
        (bcp-fetcher--furigana-hide-all)
        (message "Furigana hidden in %s." (buffer-name))))))

(defcustom bcp-fetcher-bungo-yaku-file
  (expand-file-name "bcp-liturgy-bungo-yaku.txt"
                    (file-name-directory
                     (or load-file-name buffer-file-name default-directory)))
  "Path to the local Japanese Bungo-yaku Bible text file.
Extracted from the JapBungo SWORD module (Public Domain).
Format: \"Book Ch:Vs\\ttext\" lines with furigana as kanji《reading》."
  :type 'file
  :group 'bcp-fetcher)

(defvar bcp-fetcher--bungo-yaku-bible nil
  "Hash table mapping book names to chapter hash tables.
Each chapter hash maps chapter numbers to verse vectors (1-indexed).
Populated lazily by `bcp-fetcher--bungo-yaku-load'.")

(defconst bcp-fetcher--book-name-aliases
  '(;; OT
    ("Gen"          . "Genesis")
    ("Exod"         . "Exodus")
    ("Lev"          . "Leviticus")
    ("Num"          . "Numbers")
    ("Deut"         . "Deuteronomy")
    ("Josh"         . "Joshua")
    ("Judg"         . "Judges")
    ("I Sam"        . "I Samuel")
    ("1 Sam"        . "I Samuel")
    ("II Sam"       . "II Samuel")
    ("2 Sam"        . "II Samuel")
    ("I Kgs"        . "I Kings")
    ("1 Kgs"        . "I Kings")
    ("II Kgs"       . "II Kings")
    ("2 Kgs"        . "II Kings")
    ("I Chron"      . "I Chronicles")
    ("I Chr"        . "I Chronicles")
    ("1 Chr"        . "I Chronicles")
    ("1 Chron"      . "I Chronicles")
    ("II Chr"       . "II Chronicles")
    ("II Chron"     . "II Chronicles")
    ("2 Chr"        . "II Chronicles")
    ("2 Chron"      . "II Chronicles")
    ("Neh"          . "Nehemiah")
    ("Esth"         . "Esther")
    ("Ps"           . "Psalms")
    ("Psalm"        . "Psalms")
    ("Prov"         . "Proverbs")
    ("Prov."        . "Proverbs")
    ("Eccl"         . "Ecclesiastes")
    ("Cant"         . "Song of Solomon")
    ("Isa"          . "Isaiah")
    ("Jer"          . "Jeremiah")
    ("Jer."         . "Jeremiah")
    ("Lam"          . "Lamentations")
    ("Lam."         . "Lamentations")
    ("Ezek"         . "Ezekiel")
    ("Dan"          . "Daniel")
    ("Dan."         . "Daniel")
    ("Hos"          . "Hosea")
    ("Obad"         . "Obadiah")
    ("Mic"          . "Micah")
    ("Nah"          . "Nahum")
    ("Hab"          . "Habakkuk")
    ("Hag"          . "Haggai")
    ("Zech"         . "Zechariah")
    ("Zeph"         . "Zephaniah")
    ("Mal"          . "Malachi")
    ;; NT
    ("Matt"         . "Matthew")
    ("Marc"         . "Mark")
    ("Luc"          . "Luke")
    ("Luc."         . "Luke")
    ("Joh"          . "John")
    ("Joan"         . "John")
    ("Joann"        . "John")
    ("Joannes"      . "John")
    ("Act"          . "Acts")
    ("Rom"          . "Romans")
    ("Rom."         . "Romans")
    ("I Cor"        . "I Corinthians")
    ("1 Cor"        . "I Corinthians")
    ("II Cor"       . "II Corinthians")
    ("2 Cor"        . "II Corinthians")
    ("Gal"          . "Galatians")
    ("Gal."         . "Galatians")
    ("Eph"          . "Ephesians")
    ("Phil"         . "Philippians")
    ("Col"          . "Colossians")
    ("I Thess"      . "I Thessalonians")
    ("1 Thess"      . "I Thessalonians")
    ("II Thess"     . "II Thessalonians")
    ("2 Thess"      . "II Thessalonians")
    ("I Tim"        . "I Timothy")
    ("1 Tim"        . "I Timothy")
    ("II Tim"       . "II Timothy")
    ("2 Tim"        . "II Timothy")
    ("Tit"          . "Titus")
    ("Phlm"         . "Philemon")
    ("Heb"          . "Hebrews")
    ("Jas"          . "James")
    ("Jac"          . "James")
    ("I Pet"        . "I Peter")
    ("1 Pet"        . "I Peter")
    ("II Pet"       . "II Peter")
    ("2 Pet"        . "II Peter")
    ("I John"       . "I John")
    ("1 John"       . "I John")
    ("II John"      . "II John")
    ("2 John"       . "II John")
    ("III John"     . "III John")
    ("3 John"       . "III John")
    ("Rev"          . "Revelation of John")
    ("Apo"          . "Revelation of John")
    ("Apoc"         . "Revelation of John"))
  "Alist mapping common abbreviations to SWORD canonical book names.
Used by `bcp-fetcher--bungo-yaku-resolve-book'.")

(defun bcp-fetcher--bungo-yaku-resolve-book (name)
  "Resolve book NAME to its canonical SWORD form.
Returns NAME unchanged if it is already canonical or unrecognized."
  (or (cdr (assoc name bcp-fetcher--book-name-aliases))
      name))

(defun bcp-fetcher--bungo-yaku-load ()
  "Parse `bcp-fetcher-bungo-yaku-file' into `bcp-fetcher--bungo-yaku-bible'.
Returns the hash table, or sets the variable to \\='unavailable on error."
  (unless (file-exists-p bcp-fetcher-bungo-yaku-file)
    (setq bcp-fetcher--bungo-yaku-bible 'unavailable)
    (error "bcp-fetcher: Bungo-yaku file not found: %s"
           bcp-fetcher-bungo-yaku-file))
  (let ((books (make-hash-table :test 'equal)))
    (with-temp-buffer
      (insert-file-contents bcp-fetcher-bungo-yaku-file)
      (goto-char (point-min))
      (let ((current-book nil)
            (current-ch   nil)
            (verses       nil))
        (while (not (eobp))
          (let ((line (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position))))
            (when (string-match
                   "^\\(.+\\) \\([0-9]+\\):\\([0-9]+\\)\t\\(.*\\)$" line)
              (let ((book (match-string 1 line))
                    (ch   (string-to-number (match-string 2 line)))
                    (text (match-string 4 line)))
                ;; Flush previous chapter when book or chapter changes
                (when (and current-book
                          (or (not (string= book current-book))
                              (/= ch current-ch)))
                  (let ((ch-table (or (gethash current-book books)
                                      (let ((h (make-hash-table :test 'eql)))
                                        (puthash current-book h books)
                                        h))))
                    (puthash current-ch (vconcat (nreverse verses)) ch-table))
                  (setq verses nil))
                (setq current-book book
                      current-ch   ch)
                ;; Collect verses (we trust sequential ordering from mod2imp)
                (push text verses))))
          (forward-line 1))
        ;; Flush final chapter
        (when current-book
          (let ((ch-table (or (gethash current-book books)
                              (let ((h (make-hash-table :test 'eql)))
                                (puthash current-book h books)
                                h))))
            (puthash current-ch (vconcat (nreverse verses)) ch-table)))))
    (setq bcp-fetcher--bungo-yaku-bible books)))

(defun bcp-fetcher--bungo-yaku-bible ()
  "Return the Bungo-yaku Bible hash table, loading if necessary."
  (cond
   ((eq bcp-fetcher--bungo-yaku-bible 'unavailable) nil)
   (bcp-fetcher--bungo-yaku-bible)
   (t (bcp-fetcher--bungo-yaku-load))))

(defun bcp-fetcher--bungo-yaku-render-verses (book ch verses v-from v-to)
  "Render verse vector VERSES of BOOK chapter CH from V-FROM to V-TO.
Returns a propertized string or nil.  The entire returned string
carries `bcp-cjk-body' t so the rubi renderer can identify it as
a CJK-body region at finalise time."
  (let* ((len   (length verses))
         (start (1- (max 1 (or v-from 1))))
         (end   (min len (or v-to len)))
         (result ""))
    (cl-loop for i from start below end
             for vnum = (1+ i)
             for raw = (aref verses i)
             for text = (bcp-fetcher--propertize-furigana raw)
             when (> (length text) 0) do
             (unless (string-empty-p result)
               (setq result (concat result "\n")))
             (let ((props (list 'bcp-verse vnum 'bcp-book book)))
               (when (= vnum 1)
                 (setq props (nconc props (list 'bcp-chapter ch))))
               (setq result
                     (concat result
                             (apply #'propertize (substring text 0 1) props)
                             (substring text 1)))))
    (unless (string-empty-p result)
      (put-text-property 0 (length result) 'bcp-cjk-body t result)
      result)))

(defun bcp-fetcher--bungo-yaku-render (passage bible)
  "Render PASSAGE from Bungo-yaku BIBLE hash table as propertized text, or nil."
  (cond
   ;; "Book Ch:V1-V2" or "Book Ch:V"
   ((string-match
     "^\\(.+\\) \\([0-9]+\\):\\([0-9]+\\)\\(?:-\\([0-9]+\\)\\)?$" passage)
    (let* ((book   (bcp-fetcher--bungo-yaku-resolve-book
                    (match-string 1 passage)))
           (ch     (string-to-number (match-string 2 passage)))
           (v1     (string-to-number (match-string 3 passage)))
           (v2     (if (match-string 4 passage)
                       (string-to-number (match-string 4 passage))
                     v1))
           (ch-tbl (gethash book bible))
           (verses (when ch-tbl (gethash ch ch-tbl))))
      (when verses
        (bcp-fetcher--bungo-yaku-render-verses book ch verses v1 v2))))
   ;; "Book Ch" — whole chapter
   ((string-match "^\\(.+\\) \\([0-9]+\\)$" passage)
    (let* ((book   (bcp-fetcher--bungo-yaku-resolve-book
                    (match-string 1 passage)))
           (ch     (string-to-number (match-string 2 passage)))
           (ch-tbl (gethash book bible))
           (verses (when ch-tbl (gethash ch ch-tbl))))
      (when verses
        (bcp-fetcher--bungo-yaku-render-verses book ch verses 1 nil))))
   ;; "Psalms N-M" — range of whole psalms
   ((string-match "^Psalms? \\([0-9]+\\)-\\([0-9]+\\)$" passage)
    (let* ((book   "Psalms")
           (from   (string-to-number (match-string 1 passage)))
           (to     (string-to-number (match-string 2 passage)))
           (ch-tbl (gethash book bible))
           (parts  nil))
      (when ch-tbl
        (cl-loop for n from from to to
                 for verses = (gethash n ch-tbl)
                 when verses do
                 (let ((rendered (bcp-fetcher--bungo-yaku-render-verses
                                 book n verses 1 nil)))
                   (when rendered (push rendered parts))))
        (when parts
          (mapconcat #'identity (nreverse parts) "\n\n")))))
   (t nil)))

(defun bcp-fetcher--bungo-yaku-fetch (passage _translation callback)
  "Serve PASSAGE from the local Bungo-yaku Bible and call CALLBACK with text."
  (let ((text (condition-case err
                  (bcp-fetcher--bungo-yaku-render
                   passage (bcp-fetcher--bungo-yaku-bible))
                (error
                 (message "bcp-fetcher-bungo-yaku: %s" (error-message-string err))
                 nil))))
    (when text
      (message "bcp-fetcher: %s served from local Bungo-yaku." passage))
    (funcall callback text)))

(bcp-fetcher-register-backend
 'bungo-yaku
 :name            "文語訳聖書 Bungo-yaku (local)"
 :fetch-fn        #'bcp-fetcher--bungo-yaku-fetch
 :psalm-numbering 'hebrew
 :translations    '("Bungo-yaku" "文語訳" "Japanese"))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Load default backend

(provide 'bcp-fetcher)                 ; provide before requiring backend to
(require 'bcp-fetcher-oremus)          ; avoid circular-require loop
;;; bcp-fetcher.el ends here
