;;; bcp-fetcher-oremus.el --- Oremus Bible Browser backend -*- lexical-binding: t -*-

;;; Commentary:

;; Oremus Bible Browser (bible.oremus.org) backend for bcp-fetcher.
;; Registers itself as the `oremus' backend on load.
;;
;; Supported translations: AV (KJV/KJVA), NRSV, NRSVAE, and the
;; psalm-specific versions BCP (Coverdale), CW (Common Worship),
;; and LP (Liturgical Psalter / ASB 1980).
;;
;; Configuration defcustoms:
;;   `bible-commentary-oremus-base-url'
;;   `bible-commentary-oremus-context-url'
;;   `bible-commentary-oremus-version-codes'

;;; Code:

(require 'bcp-fetcher)
(require 'cl-lib)
(require 'url)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Defgroup

(defgroup bcp-fetcher-oremus nil
  "Oremus Bible Browser fetch backend."
  :prefix "bible-commentary-oremus-"
  :group 'bcp-fetcher)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Defcustoms

(defcustom bible-commentary-oremus-base-url
  "https://bible.oremus.org/?passage=%s&version=%s&fnote=no&show_ref=no&omit_cr=no"
  "Oremus URL template.  First %%s = passage string, second %%s = version code.
This template suppresses footnotes (fnote=no), which is appropriate for
normal passages.  For omitted verses, see `bible-commentary-oremus-context-url'."
  :type 'string
  :group 'bcp-fetcher-oremus)

(defcustom bible-commentary-oremus-context-url
  "https://bible.oremus.org/?passage=%s&version=%s&fnote=yes&show_ref=yes&omit_cr=no"
  "Oremus URL template used when fetching context around omitted verses.
Enables footnotes (fnote=yes) and reference display (show_ref=yes) so that
the explanatory footnote for an omitted verse is visible in the Bible buffer."
  :type 'string
  :group 'bcp-fetcher-oremus)

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
  :group 'bcp-fetcher-oremus)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Internal helpers

(defun bcp-fetcher-oremus--version (translation)
  "Return the Oremus version code for TRANSLATION."
  (or (cdr (assoc translation bible-commentary-oremus-version-codes))
      translation))

(defun bcp-fetcher-oremus--decode-response ()
  "Decode the HTTP response body in current buffer from Windows-1252.
Returns the decoded string."
  (goto-char (point-min))
  (re-search-forward "\r\n\r\n\\|\n\n" nil t)
  (let ((raw (buffer-substring-no-properties (point) (point-max))))
    (decode-coding-string
     (encode-coding-string raw 'raw-text)
     'windows-1252)))

(defun bcp-fetcher-oremus--dom-to-text (node book &optional start-psalm cv cc)
  "Walk DOM NODE building a formatted string for BOOK.

The first character of each verse is propertized with:
  `bcp-verse'   — verse number (integer)
  `bcp-book'    — BOOK string (verse 1 of each chapter only)
  `bcp-chapter' — chapter number (verse 1 of each chapter only)
Verse separators are plain \\n (\\n\\n for chapter/psalm boundaries).

START-PSALM is the psalm number for multi-psalm BCP fetches.
CV and CC are current verse/chapter state threaded into recursive calls."
  (let ((result        "")
        (is-psalm      (equal book "Psalms"))
        (psalm-num     (or start-psalm 1))
        (prev-verse    0)
        (current-verse cv)
        (current-chap  cc)
        (verse-started nil))
    (dolist (child (dom-children node))
      (cond
       ;; Chapter dropcap (AV) — begins verse 1 of a new chapter
       ((and (listp child)
             (string-match-p "\\bcc\\b" (or (dom-attr child 'class) "")))
        (let ((num (string-to-number (string-trim (dom-texts child "")))))
          (unless (string-empty-p result)
            (setq result (concat result "\n\n")))
          (setq current-verse 1
                current-chap  num
                verse-started nil
                prev-verse    1)))
       ;; Verse number — AV "ww" or BCP "cwvnum"
       ((and (listp child)
             (let ((class (or (dom-attr child 'class) "")))
               (or (string-match-p "\\bww\\b" class)
                   (string-match-p "\\bcwvnum\\b" class))))
        (let ((num (string-to-number (string-trim (dom-texts child "")))))
          (when (and is-psalm (= num 1) (> prev-verse 1))
            (cl-incf psalm-num)
            (setq current-chap psalm-num))
          (unless (string-empty-p result)
            (setq result (concat result (if (= num 1) "\n\n" "\n"))))
          (setq current-verse num
                verse-started  nil)
          (unless (= num 1) (setq current-chap nil))
          (setq prev-verse num)))
       ;; Suppress <br>
       ((and (listp child) (eq (dom-tag child) 'br)) nil)
       ;; Plain text node
       ((stringp child)
        (unless (string-empty-p (string-trim child))
          (cond
           ((not current-verse)
            (setq result (concat result child)))
           (verse-started
            (setq result (concat result child)))
           (t
            (let ((props (list 'bcp-verse current-verse)))
              (when current-chap
                (setq props (nconc props
                                   (list 'bcp-chapter current-chap
                                         'bcp-book    book)))
                (setq current-chap nil))
              (setq result
                    (concat result
                            (apply #'propertize (substring child 0 1) props)
                            (substring child 1)))
              (setq verse-started t))))))
       ;; Recurse into inline elements (italic, bold, etc.)
       ((listp child)
        (let ((inner (bcp-fetcher-oremus--dom-to-text
                      child book psalm-num current-verse current-chap)))
          (unless (string-empty-p inner)
            (when current-verse
              (setq verse-started t)
              (setq current-chap nil))
            (setq result (concat result inner)))))))
    result))

(defun bcp-fetcher-oremus--extract-bibletext (html)
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

(defun bcp-fetcher-oremus--strip-fallback (html)
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
;;;; Fetch implementation

(defun bcp-fetcher-oremus--fetch (passage translation callback)
  "Fetch PASSAGE in TRANSLATION from Oremus and call CALLBACK with text.
CALLBACK is called as (CALLBACK text) where TEXT is a propertized string
with verse numbers formatted for visual-line-mode, or nil on failure.
Implements the bcp-fetcher backend :fetch-fn protocol."
  (let* ((ver (bcp-fetcher-oremus--version translation))
         (url (format bible-commentary-oremus-base-url
                      (url-hexify-string passage)
                      (url-hexify-string ver))))
    (url-retrieve
     url
     (lambda (status psg cb)
       (if (plist-get status :error)
           (progn
             (message "bcp-fetcher-oremus: fetch failed for %s — %s" psg
                      (plist-get status :error))
             (funcall cb nil))
         (let* ((decoded (bcp-fetcher-oremus--decode-response))
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
                           (let ((result (bcp-fetcher-oremus--dom-to-text
                                          node book start-ps)))
                             (unless (string-empty-p (string-trim result))
                               result))))))))
                (text (or dom-result
                          (let ((fb (bcp-fetcher-oremus--extract-bibletext decoded)))
                            (when fb (bcp-fetcher-clean-text fb))))))
           (funcall cb text))))
     (list passage callback)
     t t)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Backend registration

(bcp-fetcher-register-backend
 'oremus
 :name         "Oremus Bible Browser"
 :fetch-fn     #'bcp-fetcher-oremus--fetch
 :translations (mapcar #'car bible-commentary-oremus-version-codes))

(provide 'bcp-fetcher-oremus)
;;; bcp-fetcher-oremus.el ends here
