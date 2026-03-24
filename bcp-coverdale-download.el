;;; bcp-coverdale-download.el --- One-time Coverdale Psalter download from Oremus -*- lexical-binding: t -*-

;;; Commentary:

;; One-time utility that fetches the entire Coverdale Psalter from Oremus
;; Bible Browser in a single request (version "BCP") and writes 150
;; chapter files in the eBible format used by `bcp-fetcher-ebible'.
;;
;; The Coverdale Psalter text (Great Bible, 1539/40) is public domain.
;; This is a single personal fetch, not ongoing scraping.
;;
;; Output files are named:
;;   eng-bcp_020_PSA_NNN_read.txt
;; in the directory `bcp-coverdale-download-directory'.
;;
;; Usage — interactive:
;;   M-x bcp-coverdale-download-psalter
;;   (prefix argument forces re-download even if files already exist)
;;
;; Usage — batch:
;;   emacs --batch --load bcp-coverdale-download.el \
;;         --eval '(bcp-coverdale-download-psalter)'

;;; Code:

(require 'url)
(require 'dom)
(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Configuration

(defgroup bcp-coverdale-download nil
  "One-time Coverdale Psalter download utility."
  :prefix "bcp-coverdale-download-"
  :group 'bcp-fetcher)

(defcustom bcp-coverdale-download-directory
  (expand-file-name "eng-bcp_readaloud/"
                    (file-name-directory
                     (or load-file-name buffer-file-name default-directory)))
  "Directory where the downloaded Coverdale Psalter chapter files are written.
Files are named eng-bcp_020_PSA_NNN_read.txt in the eBible chapter-file
format used by `bcp-fetcher-ebible'."
  :type 'directory
  :group 'bcp-coverdale-download)

(defcustom bcp-coverdale-download-timeout 120
  "Seconds to wait for the Oremus response.
The whole-psalter response is large; 120 seconds is a safe margin."
  :type 'integer
  :group 'bcp-coverdale-download)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Fetch

(defconst bcp-coverdale-download--url
  "https://bible.oremus.org/?passage=Psalms+1-150&version=BCP&fnote=no&show_ref=no&omit_cr=no"
  "Oremus URL for the complete Coverdale Psalter in one request.")

(defun bcp-coverdale-download--fetch ()
  "Fetch the whole Coverdale Psalter from Oremus synchronously.
Returns the decoded HTML body string, or signals an error."
  (message "bcp-coverdale-download: fetching Psalms 1-150 from Oremus…")
  (let ((buf (url-retrieve-synchronously
              bcp-coverdale-download--url t t
              bcp-coverdale-download-timeout)))
    (unless (buffer-live-p buf)
      (error "bcp-coverdale-download: url-retrieve-synchronously returned nil"))
    (unwind-protect
        (with-current-buffer buf
          (goto-char (point-min))
          (unless (re-search-forward "\r?\n\r?\n" nil t)
            (error "bcp-coverdale-download: could not find HTTP header boundary"))
          (let ((raw (buffer-substring-no-properties (point) (point-max))))
            (decode-coding-string
             (encode-coding-string raw 'raw-text)
             'windows-1252)))
      (kill-buffer buf))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Parsing

(defun bcp-coverdale-download--parse (html)
  "Parse the Oremus BCP HTML and return a vector of 150 verse-text lists.
Element 0 = Psalm 1, element 149 = Psalm 150.  Each element is a list of
verse strings in order.  Asterisks (*) are preserved — they mark the
half-verse inflection point for chanting in the BCP Psalter."
  (unless (fboundp 'libxml-parse-html-region)
    (error "bcp-coverdale-download: Emacs must be built with libxml support"))
  (with-temp-buffer
    (insert html)
    (let* ((dom  (libxml-parse-html-region (point-min) (point-max)))
           (node (car (dom-by-class dom "bibletext"))))
      (unless node
        (error "bcp-coverdale-download: no bibletext div in Oremus response; \
the server may have returned an error page"))
      ;; Walk the DOM, collecting verses and detecting psalm boundaries.
      ;; Psalm boundary: cwvnum = 1 after having seen a verse number > 1.
      (let ((psalms  (make-vector 150 nil))   ; result: 0-indexed
            (ps-idx  -1)                      ; current psalm index (0-based)
            (verses  nil)                     ; accumulator for current psalm
            (text    "")                      ; accumulator for current verse
            (in-verse nil)
            (prev-vnum nil))
        (cl-labels
            ((flush-verse ()
               (when in-verse
                 (let ((v (string-trim
                           (replace-regexp-in-string "[\n\r\t \xa0]+" " " text))))
                   (unless (string-empty-p v)
                     (push v verses)))
                 (setq text "" in-verse nil)))
             (flush-psalm ()
               (flush-verse)
               (when (and (>= ps-idx 0) (< ps-idx 150))
                 (aset psalms ps-idx (nreverse verses)))
               (setq verses nil))
             (walk (n)
               (dolist (child (dom-children n))
                 (cond
                  ;; cwvnum span — BCP verse number
                  ((and (listp child)
                        (string-match-p "\\bcwvnum\\b"
                                        (or (dom-attr child 'class) "")))
                   (let ((vnum (string-to-number
                                (string-trim (dom-texts child "")))))
                     (if (and (= vnum 1) prev-vnum (> prev-vnum 1))
                         ;; Verse 1 after higher verse = new psalm
                         (progn
                           (flush-psalm)
                           (cl-incf ps-idx))
                       ;; First verse ever, or continuation within psalm
                       (progn
                         (flush-verse)
                         (when (< ps-idx 0) (cl-incf ps-idx))))
                     (setq prev-vnum vnum
                           in-verse t)))
                  ;; <br> — soft break within verse; collapse to space
                  ((and (listp child) (eq (dom-tag child) 'br))
                   (when in-verse (setq text (concat text " "))))
                  ;; Plain text
                  ((stringp child)
                   (when in-verse (setq text (concat text child))))
                  ;; Any other element — recurse
                  ((listp child) (walk child))))))
          (walk node)
          ;; Flush the final psalm (still within cl-labels scope)
          (flush-psalm))
        (let ((found (cl-count-if #'identity psalms)))
          (message "bcp-coverdale-download: parsed %d psalms." found)
          (unless (= found 150)
            (message "bcp-coverdale-download: WARNING — expected 150 psalms, \
got %d.  Oremus may have truncated the response." found)))
        psalms))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; File writing

(defun bcp-coverdale-download--write-files (psalms dir force)
  "Write PSALMS (150-element vector of verse lists) to DIR.
Skips existing files unless FORCE is non-nil.
Returns (fetched skipped empty) counts."
  (let ((written 0) (skipped 0) (empty 0))
    (dotimes (i 150)
      (let* ((n      (1+ i))
             (verses (aref psalms i))
             (fname  (format "eng-bcp_020_PSA_%03d_read.txt" n))
             (path   (expand-file-name fname dir)))
        (cond
         ((and (file-exists-p path) (not force))
          (cl-incf skipped))
         ((null verses)
          (message "bcp-coverdale-download: Psalm %d — no verses, skipping." n)
          (cl-incf empty))
         (t
          (with-temp-file path
            (insert "The Psalms.\n")
            (insert (format "Psalm %d.\n" n))
            (dolist (v verses) (insert v "\n")))
          (cl-incf written)))))
    (list written skipped empty)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Entry point

;;;###autoload
(defun bcp-coverdale-download-psalter (&optional dir force)
  "Download the complete Coverdale Psalter from Oremus in one request.

Fetches Psalms 1-150 as a single HTTP call, parses psalm and verse
boundaries, and writes 150 files in eBible chapter-file format to DIR
(default: `bcp-coverdale-download-directory').

Existing files are skipped unless FORCE is non-nil or a prefix argument
is supplied interactively.

After completion, point `bcp-fetcher-ebible-directory' (or a second
eBible backend instance) at the output directory to use the local psalter."
  (interactive
   (list (read-directory-name "Output directory: "
                              bcp-coverdale-download-directory)
         current-prefix-arg))
  (let ((out (or dir bcp-coverdale-download-directory)))
    (make-directory out t)
    (let* ((html   (bcp-coverdale-download--fetch))
           (psalms (bcp-coverdale-download--parse html))
           (counts (bcp-coverdale-download--write-files psalms out force))
           (written (nth 0 counts))
           (skipped (nth 1 counts))
           (empty   (nth 2 counts)))
      (message "bcp-coverdale-download: done. Written: %d  Skipped: %d  Empty: %d"
               written skipped empty)
      (when (> empty 0)
        (message "bcp-coverdale-download: %d empty psalms suggest Oremus \
truncated the response.  Re-run or fetch missing psalms individually." empty)))))

;;;###autoload
(defun bcp-coverdale-download-clean-files (&optional dir)
  "Clean whitespace in already-downloaded Coverdale Psalter files in DIR.
Replaces non-breaking spaces and runs of whitespace (including \\r, \\n)
with a single plain space on each verse line, without re-fetching from Oremus.
Operates on all eng-bcp_020_PSA_*_read.txt files in DIR."
  (interactive
   (list (read-directory-name "Psalter directory: "
                              bcp-coverdale-download-directory)))
  (let* ((out   (or dir bcp-coverdale-download-directory))
         (files (directory-files out t "eng-bcp_020_PSA_[0-9]+_read\\.txt"))
         (count 0))
    (dolist (path files)
      (with-temp-buffer
        (insert-file-contents path)
        (goto-char (point-min))
        (while (search-forward (string 160) nil t)
          (replace-match " " t t))
        (let ((coding-system-for-write 'utf-8-unix))
          (write-region (point-min) (point-max) path nil 'quiet)))
      (cl-incf count))
    (message "bcp-coverdale-download-clean-files: cleaned %d files." count)))

;;;###autoload
(defun bcp-coverdale-download-collate (&optional src-dir out-file)
  "Collate 150 downloaded chapter files in SRC-DIR into a single OUT-FILE.
SRC-DIR defaults to `bcp-coverdale-download-directory'.
OUT-FILE defaults to bcp-liturgy-psalter-coverdale.txt in the parent of SRC-DIR.

The output format is:
  Psalm N
  1\\tverse text
  2\\tverse text
  ...
with a blank line between psalms."
  (interactive
   (list (read-directory-name "Source directory: "
                              bcp-coverdale-download-directory)
         (read-file-name "Output file: "
                         (file-name-directory
                          (directory-file-name bcp-coverdale-download-directory))
                         nil nil "bcp-liturgy-psalter-coverdale.txt")))
  (let* ((src  (or src-dir bcp-coverdale-download-directory))
         (dest (or out-file
                   (expand-file-name
                    "bcp-liturgy-psalter-coverdale.txt"
                    (file-name-directory (directory-file-name src)))))
         (written 0)
         (empty   0))
    (with-temp-buffer
      (dotimes (i 150)
        (let* ((n     (1+ i))
               (fname (format "eng-bcp_020_PSA_%03d_read.txt" n))
               (path  (expand-file-name fname src)))
          (if (not (file-exists-p path))
              (progn
                (message "bcp-coverdale-download-collate: missing %s, skipping." fname)
                (cl-incf empty))
            (let ((verses nil))
              (with-temp-buffer
                (insert-file-contents path)
                (goto-char (point-min))
                (forward-line 2)            ; skip "The Psalms." and "Psalm N."
                (let ((vnum 0))
                  (while (not (eobp))
                    (let ((line (string-trim (buffer-substring-no-properties
                                              (line-beginning-position)
                                              (line-end-position)))))
                      (unless (string-empty-p line)
                        (cl-incf vnum)
                        (push (format "%d\t%s" vnum line) verses)))
                    (forward-line 1))))
              (insert (format "Psalm %d\n" n))
              (dolist (v (nreverse verses)) (insert v "\n"))
              (insert "\n")
              (cl-incf written)))))
      (let ((coding-system-for-write 'utf-8-unix))
        (write-region (point-min) (point-max) dest nil 'quiet)))
    (message "bcp-coverdale-download-collate: wrote %d psalms to %s%s."
             written dest
             (if (> empty 0) (format " (%d missing)" empty) ""))))

(provide 'bcp-coverdale-download)
;;; bcp-coverdale-download.el ends here
