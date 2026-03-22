;;; bcp-fetcher.el --- Oremus Bible text fetching and parsing -*- lexical-binding: t -*-

;;; Commentary:

;; Low-level machinery for fetching Bible passages from Oremus Bible Browser
;; and parsing the HTML response into plain text with verse formatting.
;;
;; This library is shared by both bible-commentary.el (study buffer) and
;; bcp-1662.el (Daily Office renderer).  It has no dependencies on either
;; and can be used by any package that needs to fetch Bible text.
;;
;; Public API:
;;   `bcp-fetcher-fetch'                 — async fetch, returns propertized text
;;   `bcp-fetcher-fetch-for-commentary'  — async fetch, returns cleaned text
;;   `bcp-fetcher-dom-to-text'           — parse Oremus HTML DOM to formatted string
;;   `bcp-fetcher-clean-text'            — clean Windows-1252 chars from plain text
;;
;; Configuration defcustoms live in bible-commentary.el (their canonical home):
;;   `bible-commentary-translation'
;;   `bible-commentary-psalm-translation'
;;   `bible-commentary-oremus-base-url'
;;   `bible-commentary-oremus-version-codes'

;;; Code:

(require 'cl-lib)
(require 'url)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Defgroup

(defgroup bcp-fetcher nil
  "Oremus Bible text fetching and parsing."
  :prefix "bcp-fetcher-"
  :group 'text)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Translation configuration
;;
;; These defcustoms are the canonical home for all Oremus fetch configuration.
;; bible-commentary.el reads them via (require 'bcp-fetcher).

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
The value is looked up in `bible-commentary-oremus-version-codes' to get
the Oremus version code.  \"Coverdale\" maps to the BCP 1662 Psalter code
\"BCP\".  Other psalm-specific options: \"CW\" (Common Worship), \"LP\"
(Liturgical Psalter/ASB 1980)."
  :type 'string
  :group 'bcp-fetcher)

(defcustom bible-commentary-oremus-base-url
  "https://bible.oremus.org/?passage=%s&version=%s&fnote=no&show_ref=no&omit_cr=no"
  "Oremus URL template.  First %%s = passage string, second %%s = version code.
This template suppresses footnotes (fnote=no), which is appropriate for
normal passages.  For omitted verses, see `bible-commentary-oremus-context-url'."
  :type 'string
  :group 'bcp-fetcher)

(defcustom bible-commentary-oremus-context-url
  "https://bible.oremus.org/?passage=%s&version=%s&fnote=yes&show_ref=yes&omit_cr=no"
  "Oremus URL template used when fetching context around omitted verses.
Enables footnotes (fnote=yes) and reference display (show_ref=yes) so that
the explanatory footnote for an omitted verse is visible in the Bible buffer."
  :type 'string
  :group 'bcp-fetcher)

(defcustom bible-commentary-omitted-verse-context-window 2
  "Number of verses before and after an omitted verse to fetch as context.
When navigating to a verse absent from the critical text (e.g. John 5:4 in
the ESV), the package fetches this many verses on either side so the user
sees the surrounding passage rather than an empty buffer."
  :type 'integer
  :group 'bcp-fetcher)

(defcustom bible-commentary-oremus-version-codes
  '(("KJVA"      . "AV")        ; KJV/KJVA — Oremus code is "AV"
    ("KJV"       . "AV")
    ("NRSV"      . "NRSV")      ; New Revised Standard Version (US spelling)
    ("NRSVAE"    . "NRSVAE")    ; NRSV Anglicized Edition (British spelling)
    ;; Note: Oremus only officially supports AV, NRSV, NRSVAE.
    ;; ESV and RSV are included in case Oremus adds them; they
    ;; will fall back gracefully (Oremus returns an error page).
    ("ESV"       . "ESV")
    ("RSV"       . "RSV")
    ;; Psalm-specific versions (only valid for Psalms passages)
    ("Coverdale" . "BCP")       ; BCP 1662 Psalter = Miles Coverdale's translation
    ("BCP"       . "BCP")       ; Alias: Book of Common Prayer 1662
    ("CW"        . "CW")        ; Common Worship Psalter (Church of England)
    ("LP"        . "LP"))       ; Liturgical Psalter (ASB 1980)
  "Alist mapping translation names to Oremus version code strings."
  :type '(alist :key-type string :value-type string)
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
translation available on Oremus."
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
Apocrypha entirely.  Oremus cannot serve these under the AV code;
they require `bible-commentary-orthodox-translation' (NRSV).")

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
                   (mapcar #'car bible-commentary-oremus-version-codes)
                   nil nil nil nil "")))
           (if (string-empty-p s) nil s))))
  (setq bible-commentary--session-translation
        (and translation (not (string-empty-p translation)) translation))
  (message (if bible-commentary--session-translation
               "Translation locked to %s for this session."
             "Translation reset — Coverdale for Psalms, NRSV for Orthodox books, KJVA otherwise.")
           bible-commentary--session-translation))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Internal helpers

(defun bcp-fetcher--oremus-version (translation)
  "Return the Oremus version code for TRANSLATION."
  (or (cdr (assoc translation bible-commentary-oremus-version-codes))
      translation))

(defun bcp-fetcher--decode-response ()
  "Decode the HTTP response body in current buffer from Windows-1252.
Returns the decoded string."
  (goto-char (point-min))
  (re-search-forward "\r\n\r\n\\|\n\n" nil t)
  (let ((raw (buffer-substring-no-properties (point) (point-max))))
    (decode-coding-string
     (encode-coding-string raw 'raw-text)
     'windows-1252)))

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
;;;; DOM parsing

(defun bcp-fetcher-dom-to-text (node book &optional start-psalm)
  "Walk DOM NODE, building a formatted string for BOOK.

Returns a string with text properties:
  `display'      — right-aligns verse numbers to column 0
  `wrap-prefix'  — indents continuation lines to column 4

START-PSALM is the starting psalm number for multi-psalm BCP fetches."
  (let ((result "")
        (is-psalm   (equal book "Psalms"))
        (psalm-num  (or start-psalm 1))
        (prev-verse 0))
    (dolist (child (dom-children node))
      (cond
       ;; Chapter dropcap (AV) — [Chapter N] heading, then auto-insert verse 1
       ((and (listp child)
             (string-match-p "\\bcc\\b" (or (dom-attr child 'class) "")))
        (let* ((num   (string-trim (dom-texts child "")))
               (label (if is-psalm
                          (format "[Psalm %s]" num)
                        (format "[Chapter %s]" num)))
               (v1    (if is-psalm "1." "1"))
               (pad   (make-string (max 0 (- 4 (length v1))) ?\s))
               (v1-marker (concat "\n" pad v1 " ")))
          (setq result
                (concat result
                        "\n\n" label "\n"
                        (propertize
                         v1-marker
                         'display
                         (concat "\n"
                                 (propertize (concat pad v1 " ")
                                             'display `(space :align-to 0)))
                         'wrap-prefix
                         (propertize "    " 'display '(space :align-to 4)))))
          (setq prev-verse 1)))
       ;; Verse number — AV "ww vnumVis" or BCP "cwvnum vnumVis"
       ((and (listp child)
             (let ((class (or (dom-attr child 'class) "")))
               (or (string-match-p "\\bww\\b" class)
                   (string-match-p "\\bcwvnum\\b" class))))
        (let* ((num-str (string-trim (dom-texts child "")))
               (num     (string-to-number num-str))
               (display (if is-psalm (concat num-str ".") num-str))
               (pad     (make-string (max 0 (- 4 (length display))) ?\s))
               (marker  (concat "\n" pad display " ")))
          (when (and is-psalm (= num 1) (> prev-verse 1))
            (cl-incf psalm-num)
            (let ((label (format "[Psalm %d]" psalm-num)))
              (setq result (concat result "\n\n" label "\n\n"))))
          (setq result
                (concat result
                        (propertize
                         marker
                         'display
                         (concat "\n"
                                 (propertize (concat pad display " ")
                                             'display `(space :align-to 0)))
                         'wrap-prefix
                         (propertize "    " 'display '(space :align-to 4)))))
          (setq prev-verse num)))
       ;; Suppress <br>
       ((and (listp child) (eq (dom-tag child) 'br)) nil)
       ;; Plain text node
       ((stringp child)
        (setq result (concat result child)))
       ;; Recurse
       ((listp child)
        (setq result
              (concat result
                      (bcp-fetcher-dom-to-text child book psalm-num))))))
    result))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; HTML extraction fallbacks

(defun bcp-fetcher--extract-bibletext (html)
  "Regex fallback: extract bibletext div from HTML, return plain text or nil."
  (when (string-match
         "<[^>]*class=[\"']bibletext[\"'][^>]*>\\(\\(?:.\\|\n\\)*?\\)</div>"
         html)
    (let ((inner (match-string 1 html)))
      (with-temp-buffer
        (insert inner)
        (goto-char (point-min))
        (while (re-search-forward "<[^>]+>" nil t) (replace-match ""))
        (dolist (pair '(("&amp;" . "&") ("&lt;" . "<") ("&gt;" . ">")
                        ("&nbsp;" . " ") ("&#160;" . " ") ("&copy;" . "©")))
          (goto-char (point-min))
          (while (re-search-forward (car pair) nil t) (replace-match (cdr pair))))
        (goto-char (point-min))
        (while (re-search-forward "&#\\([0-9]+\\);" nil t)
          (replace-match (string (string-to-number (match-string 1)))))
        (goto-char (point-min))
        (while (search-forward "\r" nil t) (replace-match ""))
        (goto-char (point-min))
        (while (re-search-forward "\n\\{3,\\}" nil t) (replace-match "\n\n"))
        (let ((result (string-trim (buffer-string))))
          (unless (string-empty-p result) result))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public fetch API

(defun bcp-fetcher-fetch (passage callback &optional translation)
  "Fetch PASSAGE from Oremus and call CALLBACK with formatted text.

TRANSLATION defaults to `bible-commentary-translation'.
CALLBACK is called with a propertized string (verse numbers formatted,
wrap-prefix set for visual-line-mode) or nil on failure.

The text properties from `bcp-fetcher-dom-to-text' are preserved —
do NOT pass the result through `bcp-fetcher-clean-text' as that would
strip them.  Character cleaning is done before DOM parsing instead."
  (let* ((tr  (or translation bible-commentary-translation))
         (ver (bcp-fetcher--oremus-version tr))
         (url (format bible-commentary-oremus-base-url
                      (url-hexify-string passage)
                      (url-hexify-string ver))))
    (url-retrieve
     url
     (lambda (status psg cb)
       (if (plist-get status :error)
           (progn
             (message "bcp-fetcher: fetch failed for %s — %s" psg
                      (plist-get status :error))
             (funcall cb nil))
         (let* ((decoded (bcp-fetcher--decode-response))
                ;; DOM path: returns propertized string, no further cleaning
                (dom-result
                 (when (fboundp 'libxml-parse-html-region)
                   (ignore-errors
                     (require 'dom)
                     (with-temp-buffer
                       (insert decoded)
                       (let* ((dom      (libxml-parse-html-region
                                         (point-min) (point-max)))
                              (node     (car (dom-by-class dom "bibletext")))
                              (book     (replace-regexp-in-string " .*" "" psg))
                              (start-ps (when (string-match "[0-9]+" psg)
                                          (string-to-number (match-string 0 psg)))))
                         (when node
                           (let ((result (bcp-fetcher-dom-to-text
                                          node book start-ps)))
                             (unless (string-empty-p (string-trim result))
                               result))))))))
                ;; Regex fallback: plain text, safe to clean
                (text (or dom-result
                          (let ((fb (bcp-fetcher--extract-bibletext decoded)))
                            (when fb (bcp-fetcher-clean-text fb))))))
           (funcall cb text))))
     (list passage callback)
     t t)))

(defun bcp-fetcher-fetch-for-commentary (passage translation callback)
  "Fetch PASSAGE in TRANSLATION and call CALLBACK with cleaned text.

Like `bcp-fetcher-fetch' but passes the result through
`bcp-fetcher-clean-text', stripping text properties.  Used by
`bcp-fetcher-oremus-process' which inserts into its own buffer
and applies its own formatting."
  (let* ((ver (bcp-fetcher--oremus-version translation))
         (url (format bible-commentary-oremus-base-url
                      (url-hexify-string passage)
                      (url-hexify-string ver))))
    (url-retrieve
     url
     (lambda (status psg trans cb)
       (if (plist-get status :error)
           (progn
             (message "bcp-fetcher: fetch failed for %s — %s" psg
                      (plist-get status :error))
             (funcall cb nil nil))
         (let* ((decoded (bcp-fetcher--decode-response))
                (book    (replace-regexp-in-string " .*" "" psg))
                (text
                 (when (fboundp 'libxml-parse-html-region)
                   (ignore-errors
                     (require 'dom)
                     (with-temp-buffer
                       (insert decoded)
                       (let* ((dom  (libxml-parse-html-region (point-min) (point-max)))
                              (node (car (dom-by-class dom "bibletext"))))
                         (when node
                           (let* ((start-ps (when (string-match "[0-9]+" psg)
                                              (string-to-number (match-string 0 psg))))
                                  (result   (bcp-fetcher-dom-to-text
                                             node book start-ps)))
                             (unless (string-empty-p (string-trim result))
                               result)))))))))
           (funcall cb
                    (or text
                        (bcp-fetcher--extract-bibletext decoded)
                        (bcp-fetcher--oremus-strip-fallback decoded))
                    trans))))
     (list passage translation callback)
     t t)))

(defun bcp-fetcher--oremus-strip-fallback (html)
  "Last-resort HTML stripper: remove script blocks then all tags."
  (with-temp-buffer
    (insert html)
    (goto-char (point-min))
    (while (search-forward "\r" nil t) (replace-match ""))
    (goto-char (point-min))
    (let ((case-fold-search t))
      (while (re-search-forward "<script\\b[^>]*>\\(?:.\\|\n\\)*?</script>" nil t)
        (replace-match "")))
    (goto-char (point-min))
    (while (re-search-forward "<[^>]+>" nil t) (replace-match ""))
    (dolist (pair '(("&amp;" . "&") ("&lt;" . "<") ("&gt;" . ">")
                    ("&nbsp;" . " ") ("&#160;" . " ") ("&copy;" . "©")))
      (goto-char (point-min))
      (while (re-search-forward (car pair) nil t) (replace-match (cdr pair))))
    (goto-char (point-min))
    (while (re-search-forward "\n\\{3,\\}" nil t) (replace-match "\n\n"))
    (string-trim (buffer-string))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Commentary-facing fetch API
;;
;; These functions replace what was bible-commentary--fetch-oremus,
;; bible-commentary--fetch-oremus-context, and bible-commentary--oremus-process.
;; They are called by bible-commentary.el but live here because they are
;; pure fetch-layer concerns.

(defun bcp-fetcher-oremus-process (passage translation load-fn)
  "Fetch PASSAGE in TRANSLATION from Oremus and call LOAD-FN with the result.

LOAD-FN is called as (LOAD-FN text label) where TEXT is the cleaned string
and LABEL is a display string like \"Genesis 1  [KJVA]\".

This replaces the old bible-commentary--oremus-process."
  (bcp-fetcher-fetch-for-commentary
   passage translation
   (lambda (text trans)
     (funcall load-fn text (format "%s  [%s]" passage trans)))))

(defun bcp-fetcher-fetch-oremus (passage load-fn &optional translation)
  "Fetch PASSAGE from Oremus asynchronously and call LOAD-FN with the result.

TRANSLATION defaults to `bible-commentary-translation'.
LOAD-FN is called as (LOAD-FN text label).

This replaces the old bible-commentary--fetch-oremus."
  (let ((tr (or translation bible-commentary-translation)))
    (message "Fetching %s [%s] from Oremus…" passage tr)
    (bcp-fetcher-oremus-process passage tr load-fn)))

(defun bcp-fetcher-fetch-oremus-context (ref translation load-fn banner-fn)
  "Fetch a context window around REF from Oremus with footnotes enabled.

Used for omitted verses where fetching the bare verse number returns empty
content.  Fetches `bible-commentary-omitted-verse-context-window' verses on
each side with fnote=yes so the explanatory footnote is visible.

LOAD-FN is called as (LOAD-FN text label) on success or failure fallback.
BANNER-FN is called as (BANNER-FN banner-string) after a successful fetch,
or nil to skip the banner.  The caller is responsible for inserting the
banner into the appropriate buffer."
  (let* ((ch      (plist-get ref :chapter))
         (vs      (plist-get ref :verse-start))
         (window  bible-commentary-omitted-verse-context-window)
         (vs-from (max 1 (- vs window)))
         (vs-to   (+ vs window))
         (book    (plist-get ref :book))
         (passage (format "%s %d:%d-%d" book ch vs-from vs-to))
         (ver     (bcp-fetcher--oremus-version translation))
         (url     (format bible-commentary-oremus-context-url
                          (url-hexify-string passage)
                          (url-hexify-string ver)))
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
    (url-retrieve
     url
     (lambda (fetch-status passage-str trans-str banner-str lfn bfn)
       (if (plist-get fetch-status :error)
           (funcall lfn
                    (format "Verse %s is absent from the critical text.\n\n\
This verse number does not appear in the earliest Greek manuscripts \
and is omitted in the %s.  It is present in the Textus Receptus \
and therefore in the KJV/KJVA.\n\nTo read the surrounding passage, \
navigate to %s %d:%d-%d."
                            passage-str trans-str book ch
                            (max 1 (- vs window)) (+ vs window))
                    (format "%s  [%s]" passage-str trans-str))
         (bcp-fetcher-oremus-process passage-str trans-str lfn)
         (when (and banner-str bfn)
           (funcall bfn banner-str))))
     (list passage translation banner load-fn banner-fn)
     t t)))

(provide 'bcp-fetcher)
;;; bcp-fetcher.el ends here
