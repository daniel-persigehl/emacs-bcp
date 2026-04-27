;;; bcp-kjva-collate.el --- Collate KJV-with-Apocrypha bundle from eBible -*- lexical-binding: t -*-

;;; Commentary:

;; One-time utility to produce `bcp-liturgy-bible-kjva.txt' from the
;; eBible "readaloud" plain-text distribution of the King James Version
;; with Apocrypha (eng-kjv).  Output format mirrors
;; `bcp-liturgy-bungo-yaku.txt': one verse per line, tab-separated,
;; with the SWORD canonical book name as the line prefix:
;;
;;   Genesis 1:1<TAB>In the beginning God created the heaven and the earth.
;;
;; The KJV (1769 Blayney revision) and its Apocrypha are public domain.
;; Source files come from https://ebible.org/Scriptures/eng-kjv_readaloud.zip,
;; expected to be unpacked into `bcp-kjva-collate-src-dir'.
;;
;; Usage:
;;   M-x bcp-kjva-collate

;;; Code:

(defvar bcp-kjva-collate-src-dir
  (expand-file-name
   "eng-kjv_readaloud/"
   (file-name-directory (or load-file-name buffer-file-name)))
  "Directory containing the eBible eng-kjv readaloud chapter files.")

(defvar bcp-kjva-collate-out-file
  (expand-file-name
   "bcp-liturgy-bible-kjva.txt"
   (file-name-directory (or load-file-name buffer-file-name)))
  "Output file for the collated KJVA bundle.")

(defconst bcp-kjva-collate--book-name-map
  '(;; Old Testament
    ("GEN" . "Genesis")           ("EXO" . "Exodus")
    ("LEV" . "Leviticus")         ("NUM" . "Numbers")
    ("DEU" . "Deuteronomy")       ("JOS" . "Joshua")
    ("JDG" . "Judges")            ("RUT" . "Ruth")
    ("1SA" . "I Samuel")          ("2SA" . "II Samuel")
    ("1KI" . "I Kings")           ("2KI" . "II Kings")
    ("1CH" . "I Chronicles")      ("2CH" . "II Chronicles")
    ("EZR" . "Ezra")              ("NEH" . "Nehemiah")
    ("EST" . "Esther")            ("JOB" . "Job")
    ("PSA" . "Psalms")            ("PRO" . "Proverbs")
    ("ECC" . "Ecclesiastes")      ("SNG" . "Song of Solomon")
    ("ISA" . "Isaiah")            ("JER" . "Jeremiah")
    ("LAM" . "Lamentations")      ("EZK" . "Ezekiel")
    ("DAN" . "Daniel")            ("HOS" . "Hosea")
    ("JOL" . "Joel")              ("AMO" . "Amos")
    ("OBA" . "Obadiah")           ("JON" . "Jonah")
    ("MIC" . "Micah")             ("NAM" . "Nahum")
    ("HAB" . "Habakkuk")          ("ZEP" . "Zephaniah")
    ("HAG" . "Haggai")            ("ZEC" . "Zechariah")
    ("MAL" . "Malachi")
    ;; Apocrypha
    ("TOB" . "Tobit")             ("JDT" . "Judith")
    ("ESG" . "Esther (Greek)")    ("WIS" . "Wisdom of Solomon")
    ("SIR" . "Sirach")            ("BAR" . "Baruch")
    ("S3Y" . "Song of the Three Holy Children")
    ("SUS" . "Susanna")           ("BEL" . "Bel and the Dragon")
    ("MAN" . "Prayer of Manasseh")
    ("1MA" . "I Maccabees")       ("2MA" . "II Maccabees")
    ("1ES" . "I Esdras")          ("2ES" . "II Esdras")
    ;; New Testament
    ("MAT" . "Matthew")           ("MRK" . "Mark")
    ("LUK" . "Luke")              ("JHN" . "John")
    ("ACT" . "Acts")              ("ROM" . "Romans")
    ("1CO" . "I Corinthians")     ("2CO" . "II Corinthians")
    ("GAL" . "Galatians")         ("EPH" . "Ephesians")
    ("PHP" . "Philippians")       ("COL" . "Colossians")
    ("1TH" . "I Thessalonians")   ("2TH" . "II Thessalonians")
    ("1TI" . "I Timothy")         ("2TI" . "II Timothy")
    ("TIT" . "Titus")             ("PHM" . "Philemon")
    ("HEB" . "Hebrews")           ("JAS" . "James")
    ("1PE" . "I Peter")           ("2PE" . "II Peter")
    ("1JN" . "I John")            ("2JN" . "II John")
    ("3JN" . "III John")          ("JUD" . "Jude")
    ("REV" . "Revelation of John"))
  "Map from eBible 3-letter SWORD codes to canonical book names.")

(defun bcp-kjva-collate--parse-chapter-file (file)
  "Return the list of verse strings parsed from chapter FILE.
Strips the two header lines (book title, chapter heading), trims
trailing whitespace, and drops the UTF-8 BOM if present."
  (with-temp-buffer
    (insert-file-contents file)
    ;; Strip BOM if present.
    (goto-char (point-min))
    (when (eq (char-after) ?﻿)
      (delete-char 1))
    ;; Discard the first two header lines.
    (goto-char (point-min))
    (forward-line 2)
    (let (verses)
      (while (not (eobp))
        (let ((line (string-trim
                     (buffer-substring-no-properties
                      (line-beginning-position) (line-end-position)))))
          (unless (string-empty-p line)
            (push line verses)))
        (forward-line 1))
      (nreverse verses))))

(defun bcp-kjva-collate--parse-filename (filename)
  "Return (BOOK-CODE . CHAPTER) parsed from FILENAME, or nil if it does not match.
FILENAME is the basename without directory."
  (when (string-match
         "^eng-kjv_[0-9]+_\\([A-Z0-9]+\\)_\\([0-9]+\\)_read\\.txt$"
         filename)
    (cons (match-string 1 filename)
          (string-to-number (match-string 2 filename)))))

(defun bcp-kjva-collate (&optional src-dir out-file)
  "Collate eBible eng-kjv chapter files into a single bundled KJVA file.
SRC-DIR defaults to `bcp-kjva-collate-src-dir'.
OUT-FILE defaults to `bcp-kjva-collate-out-file'."
  (interactive)
  (let* ((src   (or src-dir bcp-kjva-collate-src-dir))
         (out   (or out-file bcp-kjva-collate-out-file))
         (files (sort (directory-files src nil "^eng-kjv_[0-9]+_[A-Z0-9]+_[0-9]+_read\\.txt$")
                      #'string<))
         (chapter-count 0)
         (verse-count   0)
         (unknown-codes '()))
    (with-temp-file out
      (dolist (filename files)
        (let* ((parsed (bcp-kjva-collate--parse-filename filename)))
          (when parsed
            (let* ((code   (car parsed))
                   (ch     (cdr parsed))
                   (book   (cdr (assoc code bcp-kjva-collate--book-name-map))))
              (cond
               ((null book)
                (cl-pushnew code unknown-codes :test #'string=))
               (t
                (let ((verses (bcp-kjva-collate--parse-chapter-file
                               (expand-file-name filename src))))
                  (when verses
                    (let ((v 1))
                      (dolist (text verses)
                        (insert (format "%s %d:%d\t%s\n" book ch v text))
                        (setq v (1+ v))
                        (setq verse-count (1+ verse-count))))
                    (setq chapter-count (1+ chapter-count)))))))))))
    (when unknown-codes
      (message "bcp-kjva-collate: unmapped book codes skipped: %s"
               (string-join (sort unknown-codes #'string<) ", ")))
    (message "Collated %d chapters / %d verses to %s"
             chapter-count verse-count out)))

(provide 'bcp-kjva-collate)
;;; bcp-kjva-collate.el ends here
