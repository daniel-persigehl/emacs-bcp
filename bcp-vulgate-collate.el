;;; bcp-vulgate-collate.el --- Collate Latin Vulgate psalter from DO sources -*- lexical-binding: t -*-

;; One-time utility to produce bcp-liturgy-psalter-vulgate.txt from
;; the Divinum Officium Latin psalm files.  The output format matches
;; the Coverdale psalter: "Psalm N" headers, tab-separated sequential
;; verse numbers, one blank line between psalms.  Vulgate numbering
;; (1-150) is used throughout.

;;; Code:

(defvar bcp-vulgate-collate-src-dir
  (expand-file-name
   "divinum-officium-master/web/www/horas/Latin/Psalterium/Psalmorum/"
   (file-name-directory (or load-file-name buffer-file-name)))
  "Directory containing the DO Latin psalm source files.")

(defvar bcp-vulgate-collate-out-file
  (expand-file-name
   "bcp-liturgy-psalter-vulgate.txt"
   (file-name-directory (or load-file-name buffer-file-name)))
  "Output file for the collated Vulgate psalter.")

(defun bcp-vulgate-collate--parse-psalm-file (file)
  "Parse a single DO psalm FILE and return a list of verse-text strings.
Strips verse-number prefixes, inline parenthetical references,
section labels like (Aleph), and $ant markers.  Preserves Breviary
pointing marks (*, †, ‡) and all accented characters."
  (when (file-exists-p file)
    (with-temp-buffer
      (insert-file-contents file)
      (let (verses)
        (goto-char (point-min))
        (while (not (eobp))
          (let ((line (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position))))
            (unless (or (string-empty-p (string-trim line))
                        (string-prefix-p "$" line))
              ;; Strip verse-number prefix: "N:N[a-z]? "
              (when (string-match "^[0-9]+:[0-9]+[a-z]? " line)
                (setq line (substring line (match-end 0))))
              ;; Strip inline section labels: (Aleph), (Beth), etc.
              (setq line (replace-regexp-in-string "([A-Z][a-z]+) ?" "" line))
              ;; Strip inline verse refs: (4a), (8), (10b), etc.
              (setq line (replace-regexp-in-string "([0-9]+[a-z]?) ?" "" line))
              ;; Trim whitespace
              (setq line (string-trim line))
              (unless (string-empty-p line)
                (push line verses))))
          (forward-line 1))
        (nreverse verses)))))

(defun bcp-vulgate-collate (&optional src-dir out-file)
  "Collate 150 DO Latin psalm files into a single psalter file.
SRC-DIR defaults to `bcp-vulgate-collate-src-dir'.
OUT-FILE defaults to `bcp-vulgate-collate-out-file'."
  (interactive)
  (let ((src (or src-dir bcp-vulgate-collate-src-dir))
        (out (or out-file bcp-vulgate-collate-out-file))
        (psalm-count 0))
    (with-temp-file out
      (dotimes (i 150)
        (let* ((n (1+ i))
               (filename (if (= n 94) "Psalm94C.txt"
                           (format "Psalm%d.txt" n)))
               (file (expand-file-name filename src))
               (verses (bcp-vulgate-collate--parse-psalm-file file)))
          (when verses
            (when (> psalm-count 0)
              (insert "\n"))
            (insert (format "Psalm %d\n" n))
            (let ((v 1))
              (dolist (text verses)
                (insert (format "%d\t%s\n" v text))
                (setq v (1+ v))))
            (setq psalm-count (1+ psalm-count))))))
    (message "Collated %d psalms to %s" psalm-count out)))

(provide 'bcp-vulgate-collate)
;;; bcp-vulgate-collate.el ends here
