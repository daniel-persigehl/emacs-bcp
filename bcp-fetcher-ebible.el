;;; bcp-fetcher-ebible.el --- eBible plain-text chapter-file backend -*- lexical-binding: t -*-

;;; Commentary:

;; bcp-fetcher backend for eBible.org plain-text chapter files.
;; Each chapter is stored as a separate file named:
;;   eng-kjv_NNN_BBB_CC_read.txt
;; where NNN is a zero-padded book ordinal, BBB is the USFM book code,
;; and CC is the zero-padded chapter number (2 digits for most books,
;; 3 digits for Psalms).
;;
;; File format:
;;   Line 1  — book title (e.g. "The First Book of Moses, called Genesis.")
;;   Line 2  — "Chapter N."
;;   Lines 3+ — one verse per line (no verse numbers); ¶ marks paragraphs
;;
;; This backend inserts verse numbers in the same propertized format as
;; the Oremus backend, so the reader's verse-navigation works unchanged.
;;
;; To use this backend, set `bcp-fetcher-backend' to 'ebible after loading:
;;   (require 'bcp-fetcher-ebible)
;;   (setq bcp-fetcher-backend 'ebible)
;;
;; Configuration:
;;   `bcp-fetcher-ebible-directory' — path to the chapter-file directory

;;; Code:

(require 'bcp-fetcher)
(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Defgroup / defcustom

(defgroup bcp-fetcher-ebible nil
  "eBible plain-text chapter-file backend."
  :prefix "bcp-fetcher-ebible-"
  :group 'bcp-fetcher)

(defcustom bcp-fetcher-ebible-directory
  (expand-file-name "eng-kjv_readaloud/"
                    (file-name-directory
                     (or load-file-name buffer-file-name default-directory)))
  "Directory containing the eBible plain-text chapter files.
The directory should contain files named eng-kjv_NNN_BBB_CC_read.txt."
  :type 'directory
  :group 'bcp-fetcher-ebible)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Book table — canonical name → (ordinal code)

(defconst bcp-fetcher-ebible--books
  '(;; Old Testament
    ("Genesis"              "002" "GEN")
    ("Exodus"               "003" "EXO")
    ("Leviticus"            "004" "LEV")
    ("Numbers"              "005" "NUM")
    ("Deuteronomy"          "006" "DEU")
    ("Joshua"               "007" "JOS")
    ("Judges"               "008" "JDG")
    ("Ruth"                 "009" "RUT")
    ("1 Samuel"             "010" "1SA")
    ("2 Samuel"             "011" "2SA")
    ("1 Kings"              "012" "1KI")
    ("2 Kings"              "013" "2KI")
    ("1 Chronicles"         "014" "1CH")
    ("2 Chronicles"         "015" "2CH")
    ("Ezra"                 "016" "EZR")
    ("Nehemiah"             "017" "NEH")
    ("Esther"               "018" "EST")
    ("Job"                  "019" "JOB")
    ("Psalms"               "020" "PSA")
    ("Proverbs"             "021" "PRO")
    ("Ecclesiastes"         "022" "ECC")
    ("Song of Solomon"      "023" "SNG")
    ("Isaiah"               "024" "ISA")
    ("Jeremiah"             "025" "JER")
    ("Lamentations"         "026" "LAM")
    ("Ezekiel"              "027" "EZK")
    ("Daniel"               "028" "DAN")
    ("Hosea"                "029" "HOS")
    ("Joel"                 "030" "JOL")
    ("Amos"                 "031" "AMO")
    ("Obadiah"              "032" "OBA")
    ("Jonah"                "033" "JON")
    ("Micah"                "034" "MIC")
    ("Nahum"                "035" "NAM")
    ("Habakkuk"             "036" "HAB")
    ("Zephaniah"            "037" "ZEP")
    ("Haggai"               "038" "HAG")
    ("Zechariah"            "039" "ZEC")
    ("Malachi"              "040" "MAL")
    ;; Deuterocanon / Apocrypha
    ("Tobit"                "041" "TOB")
    ("Judith"               "042" "JDT")
    ("Esther (Greek)"       "043" "ESG")
    ("Wisdom"               "045" "WIS")
    ("Sirach"               "046" "SIR")
    ("Baruch"               "047" "BAR")
    ("Prayer of Azariah"    "049" "S3Y")
    ("Susanna"              "050" "SUS")
    ("Bel and the Dragon"   "051" "BEL")
    ("1 Maccabees"          "052" "1MA")
    ("2 Maccabees"          "053" "2MA")
    ("1 Esdras"             "054" "1ES")
    ("Prayer of Manasseh"   "055" "MAN")
    ("2 Esdras"             "058" "2ES")
    ;; New Testament
    ("Matthew"              "070" "MAT")
    ("Mark"                 "071" "MRK")
    ("Luke"                 "072" "LUK")
    ("John"                 "073" "JHN")
    ("Acts"                 "074" "ACT")
    ("Romans"               "075" "ROM")
    ("1 Corinthians"        "076" "1CO")
    ("2 Corinthians"        "077" "2CO")
    ("Galatians"            "078" "GAL")
    ("Ephesians"            "079" "EPH")
    ("Philippians"          "080" "PHP")
    ("Colossians"           "081" "COL")
    ("1 Thessalonians"      "082" "1TH")
    ("2 Thessalonians"      "083" "2TH")
    ("1 Timothy"            "084" "1TI")
    ("2 Timothy"            "085" "2TI")
    ("Titus"                "086" "TIT")
    ("Philemon"             "087" "PHM")
    ("Hebrews"              "088" "HEB")
    ("James"                "089" "JAS")
    ("1 Peter"              "090" "1PE")
    ("2 Peter"              "091" "2PE")
    ("1 John"               "092" "1JN")
    ("2 John"               "093" "2JN")
    ("3 John"               "094" "3JN")
    ("Jude"                 "095" "JUD")
    ("Revelation"           "096" "REV"))
  "Alist mapping canonical book names to (ordinal code) for eBible filenames.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Internal helpers

(defun bcp-fetcher-ebible--book-entry (book)
  "Return (ordinal code) for canonical BOOK name, or nil if unknown."
  (cdr (assoc book bcp-fetcher-ebible--books)))

(defun bcp-fetcher-ebible--chapter-file (book chapter)
  "Return the full path to the eBible file for BOOK chapter CHAPTER.
CHAPTER is an integer.  Returns nil if BOOK is not in the book table."
  (let ((entry (bcp-fetcher-ebible--book-entry book)))
    (when entry
      (let* ((ordinal (car entry))
             (code    (cadr entry))
             ;; Psalms (150 chapters) uses 3-digit chapter numbers; all others 2
             (ch-fmt  (if (string= code "PSA") "%03d" "%02d"))
             (ch-str  (format ch-fmt chapter))
             (fname   (format "eng-kjv_%s_%s_%s_read.txt" ordinal code ch-str)))
        (expand-file-name fname bcp-fetcher-ebible-directory)))))

(defun bcp-fetcher-ebible--propertize-verse (verse-num verse-text is-psalm
                                              &optional book chapter)
  "Return a propertized string for VERSE-NUM with VERSE-TEXT.
IS-PSALM non-nil formats the verse number with a trailing dot (Psalms style).
When BOOK and CHAPTER are provided and VERSE-NUM is 1, the marker carries
`bcp-book' and `bcp-chapter' text properties for later chapter-heading display.
Matches the display format of the Oremus backend."
  (let* ((stripped (string-trim
                    (replace-regexp-in-string "^¶[ \t]*" "" verse-text)))
         (display  (if is-psalm
                       (format "%d." verse-num)
                     (format "%d" verse-num)))
         (pad      (make-string (max 0 (- 4 (length display))) ?\s))
         (marker   (concat "\n" pad display " "))
         (m        (propertize
                    marker
                    'display
                    (concat "\n"
                            (propertize (concat pad display " ")
                                        'display `(space :align-to 0)))
                    'wrap-prefix
                    (propertize "    " 'display '(space :align-to 4)))))
    (when (and (= verse-num 1) book chapter)
      (add-text-properties 0 (length m)
                           (list 'bcp-book book 'bcp-chapter chapter)
                           m))
    (concat m stripped)))

(defun bcp-fetcher-ebible--read-chapter (book chapter vs-from vs-to)
  "Read eBible chapter file for BOOK CHAPTER and return propertized text.
VS-FROM and VS-TO are 1-based integers (inclusive); nil means start/end.
Returns nil if the file does not exist."
  (let ((path (bcp-fetcher-ebible--chapter-file book chapter)))
    (when (and path (file-readable-p path))
      (let* ((is-psalm (equal book "Psalms"))
             (lines    (with-temp-buffer
                         (insert-file-contents path)
                         (split-string (buffer-string) "\n")))
             ;; Lines 0 and 1 are book title and "Chapter N." — skip them
             (verse-lines (cddr lines))
             (result ""))
        (let ((verse-num 0))
          (dolist (line verse-lines)
            (unless (string-empty-p (string-trim line))
              (cl-incf verse-num)
              (when (and (or (null vs-from) (>= verse-num vs-from))
                         (or (null vs-to)
                             (= vs-to 200)   ; sentinel: end of chapter
                             (<= verse-num vs-to)))
                (setq result
                      (concat result
                              (bcp-fetcher-ebible--propertize-verse
                               verse-num line is-psalm book chapter)))))))
        result))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Passage parser

(defun bcp-fetcher-ebible--parse-passage (passage)
  "Parse PASSAGE into a list of (book chapter vs-from vs-to) segment plists.

Handles:
  \"Book N\"           — whole chapter
  \"Book N:V\"         — single verse
  \"Book N:V1-V2\"     — verse range within chapter
  \"Book N:V1-N2:V2\"  — cross-chapter range (expands to two segments)
  Multiple refs separated by newlines — each parsed independently"
  (let (segments)
    (dolist (ref (split-string passage "\n" t "[ \t]+"))
      (cond
       ;; "Book CH:V1-CH2:V2" — cross-chapter
       ((string-match
         (concat "^\\(.*?\\)[ \t]+\\([0-9]+\\):\\([0-9]+\\)"
                 "-\\([0-9]+\\):\\([0-9]+\\)$")
         ref)
        (let ((book (match-string 1 ref))
              (ch1  (string-to-number (match-string 2 ref)))
              (vs1  (string-to-number (match-string 3 ref)))
              (ch2  (string-to-number (match-string 4 ref)))
              (vs2  (string-to-number (match-string 5 ref))))
          (if (= ch1 ch2)
              (push (list book ch1 vs1 vs2) segments)
            ;; Expand to one segment per chapter
            (push (list book ch1 vs1 nil) segments)
            (let ((ch (1+ ch1)))
              (while (< ch ch2)
                (push (list book ch nil nil) segments)
                (cl-incf ch)))
            (push (list book ch2 1 vs2) segments))))
       ;; "Book CH:V1-V2" — verse range within chapter
       ((string-match
         "^\\(.*?\\)[ \t]+\\([0-9]+\\):\\([0-9]+\\)-\\([0-9]+\\)$"
         ref)
        (push (list (match-string 1 ref)
                    (string-to-number (match-string 2 ref))
                    (string-to-number (match-string 3 ref))
                    (string-to-number (match-string 4 ref)))
              segments))
       ;; "Book CH:V" — single verse
       ((string-match
         "^\\(.*?\\)[ \t]+\\([0-9]+\\):\\([0-9]+\\)$"
         ref)
        (let ((v (string-to-number (match-string 3 ref))))
          (push (list (match-string 1 ref)
                      (string-to-number (match-string 2 ref))
                      v v)
                segments)))
       ;; "Book CH" — whole chapter
       ((string-match "^\\(.*?\\)[ \t]+\\([0-9]+\\)$" ref)
        (push (list (match-string 1 ref)
                    (string-to-number (match-string 2 ref))
                    nil nil)
              segments))
       (t
        (message "bcp-fetcher-ebible: could not parse ref %S" ref))))
    (nreverse segments)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Fetch implementation

(defun bcp-fetcher-ebible--fetch (passage _translation callback)
  "Fetch PASSAGE from the eBible chapter files and call CALLBACK with text.
CALLBACK is called as (CALLBACK text) where TEXT is a propertized string
with verse numbers formatted for visual-line-mode, or nil on failure.
_TRANSLATION is ignored — this backend always serves KJV text.
Implements the bcp-fetcher backend :fetch-fn protocol."
  (let* ((segments (bcp-fetcher-ebible--parse-passage passage))
         (result   ""))
    (if (null segments)
        (funcall callback nil)
      (dolist (seg segments)
        (let* ((book    (nth 0 seg))
               (chapter (nth 1 seg))
               (vs-from (nth 2 seg))
               (vs-to   (nth 3 seg))
               (text    (bcp-fetcher-ebible--read-chapter
                         book chapter vs-from vs-to)))
          (if text
              (setq result (concat result text))
            (message "bcp-fetcher-ebible: file not found for %s %d"
                     book chapter))))
      (funcall callback (if (string-empty-p (string-trim result))
                            nil
                          result)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Backend registration

(bcp-fetcher-register-backend
 'ebible
 :name         "eBible KJV"
 :fetch-fn     #'bcp-fetcher-ebible--fetch
 :translations '("KJV" "KJVA"))

(provide 'bcp-fetcher-ebible)
;;; bcp-fetcher-ebible.el ends here
