;;; bcp-vulgate-bible-collate.el --- Collate Latin Vulgate Bible from eBible -*- lexical-binding: t -*-

;;; Commentary:

;; One-time utility to produce `bcp-liturgy-bible-vulgate.txt' from the
;; eBible "readaloud" plain-text distribution of the Bibbia Vulgata
;; Clementina (latVUC).  Output format mirrors the KJVA bundle:
;;
;;   Genesis 1:1<TAB>In principio creavit Deus cælum et terram.
;;
;; Book names are SWORD canonical English forms ("Genesis", "I Samuel",
;; "Tobit") so the bundle and resolver align with `bcp-fetcher-kjva' and
;; `bcp-fetcher--bungo-yaku-bible'.  Psalm numbering follows the Vulgate
;; (LXX) convention as distributed by eBible — Psalm 50 is "Miserere".
;;
;; Source files come from
;; https://ebible.org/Scriptures/latVUC_readaloud.zip,
;; expected to be unpacked into `bcp-vulgate-bible-collate-src-dir'.
;;
;; The Clementine Vulgate (1592–1598) is in the public domain.
;;
;; Usage:
;;   M-x bcp-vulgate-bible-collate

;;; Code:

(defvar bcp-vulgate-bible-collate-src-dir
  (expand-file-name
   "latVUC_readaloud/"
   (file-name-directory (or load-file-name buffer-file-name)))
  "Directory containing the eBible latVUC readaloud chapter files.")

(defvar bcp-vulgate-bible-collate-out-file
  (expand-file-name
   "bcp-liturgy-bible-vulgate.txt"
   (file-name-directory (or load-file-name buffer-file-name)))
  "Output file for the collated Vulgate Bible bundle.")

(defconst bcp-vulgate-bible-collate--book-name-map
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
    ;; Deuterocanonicals integrated into the Clementine canon.
    ;; Susanna, Bel, and the Song of the Three are integrated into
    ;; Daniel (chs 3, 13, 14) and so do not appear as separate books.
    ;; The Esther additions are integrated into Esther.  1/2 Esdras
    ;; and the Prayer of Manasseh sit in the Clementine appendix and
    ;; are not in the eBible distribution.
    ("TOB" . "Tobit")             ("JDT" . "Judith")
    ("WIS" . "Wisdom of Solomon") ("SIR" . "Sirach")
    ("BAR" . "Baruch")
    ("1MA" . "I Maccabees")       ("2MA" . "II Maccabees")
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

(defun bcp-vulgate-bible-collate--parse-chapter-file (file)
  "Return the list of verse strings parsed from chapter FILE.
Strips the two header lines (book title, chapter heading), trims
trailing whitespace, and drops the UTF-8 BOM if present."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (when (eq (char-after) ?﻿)
      (delete-char 1))
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

(defun bcp-vulgate-bible-collate--parse-filename (filename)
  "Return (BOOK-CODE . CHAPTER) parsed from FILENAME, or nil if it does not match."
  (when (string-match
         "^latVUC_[0-9]+_\\([A-Z0-9]+\\)_\\([0-9]+\\)_read\\.txt$"
         filename)
    (cons (match-string 1 filename)
          (string-to-number (match-string 2 filename)))))

(defun bcp-vulgate-bible-collate (&optional src-dir out-file)
  "Collate eBible latVUC chapter files into a single bundled Vulgate file.
SRC-DIR defaults to `bcp-vulgate-bible-collate-src-dir'.
OUT-FILE defaults to `bcp-vulgate-bible-collate-out-file'."
  (interactive)
  (let* ((src   (or src-dir bcp-vulgate-bible-collate-src-dir))
         (out   (or out-file bcp-vulgate-bible-collate-out-file))
         (files (sort (directory-files src nil "^latVUC_[0-9]+_[A-Z0-9]+_[0-9]+_read\\.txt$")
                      #'string<))
         (chapter-count 0)
         (verse-count   0)
         (unknown-codes '()))
    (with-temp-file out
      (dolist (filename files)
        (let* ((parsed (bcp-vulgate-bible-collate--parse-filename filename)))
          (when parsed
            (let* ((code   (car parsed))
                   (ch     (cdr parsed))
                   (book   (cdr (assoc code bcp-vulgate-bible-collate--book-name-map))))
              (cond
               ((null book)
                (cl-pushnew code unknown-codes :test #'string=))
               (t
                (let ((verses (bcp-vulgate-bible-collate--parse-chapter-file
                               (expand-file-name filename src))))
                  (when verses
                    (let ((v 1))
                      (dolist (text verses)
                        (insert (format "%s %d:%d\t%s\n" book ch v text))
                        (setq v (1+ v))
                        (setq verse-count (1+ verse-count))))
                    (setq chapter-count (1+ chapter-count)))))))))))
    (when unknown-codes
      (message "bcp-vulgate-bible-collate: unmapped book codes skipped: %s"
               (string-join (sort unknown-codes #'string<) ", ")))
    (message "Collated %d chapters / %d verses to %s"
             chapter-count verse-count out)))

(provide 'bcp-vulgate-bible-collate)
;;; bcp-vulgate-bible-collate.el ends here
