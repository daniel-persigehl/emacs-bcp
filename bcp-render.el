;;; bcp-render.el --- Shared rendering framework for BCP buffers -*- lexical-binding: t -*-

;;; Commentary:

;; Shared rendering framework used by both the scripture reader
;; (bcp-reader.el) and the Daily Office renderer (bcp-1662-render.el).
;;
;; Provides:
;;   - `bcp-reader-paragraph-mode' — defcustom controlling paragraph flow
;;   - `bible-commentary--clean-display-text' — encoding/whitespace cleanup
;;   - `bcp-reader--add-verse-number-overlays' — overlay-based verse numbers
;;   - `bcp-reader-toggle-verse-numbers' — interactive toggle
;;   - `bcp-reader--add-paragraph-overlays' — overlay-based paragraph joining
;;   - `bcp-reader-toggle-paragraph-mode' — interactive toggle
;;
;; All overlay functions operate on the *current buffer* so they work in
;; both the reader's bible buffer and the Office buffer.

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Customisation

(defgroup bcp-render nil
  "Shared rendering framework for BCP scripture and Office buffers."
  :prefix "bcp-render-"
  :group 'applications)

(defcustom bcp-reader-paragraph-mode nil
  "If non-nil, join verses within a chapter into a single paragraph by default.
Verses are separated by spaces rather than newlines; chapter boundaries
are preserved.  Toggle interactively with `bcp-reader-toggle-paragraph-mode'."
  :type 'boolean
  :group 'bcp-render)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Text cleanup

(defun bible-commentary--clean-display-text (text)
  "Clean up TEXT for display in a Bible or Office buffer.

Handles two encoding issues with raw Oremus text:
1. C1 control characters U+0091-U+0097 — Windows-1252 typographic
   characters decoded as Latin-1 — mapped to correct Unicode equivalents.
2. Non-breaking spaces (U+00A0) replaced with regular spaces."
  (with-temp-buffer
    (insert text)
    ;; Map C1 control chars (Windows-1252 typographic characters)
    (dolist (pair '(("\u0091" . "\u2018")   ; left single quote
                    ("\u0092" . "\u2019")   ; right single quote / apostrophe
                    ("\u0093" . "\u201C")   ; left double quote
                    ("\u0094" . "\u201D")   ; right double quote
                    ("\u0096" . "\u2013")   ; en dash
                    ("\u0097" . "\u2014"))) ; em dash
      (goto-char (point-min))
      (while (search-forward (car pair) nil t)
        (replace-match (cdr pair))))
    ;; Replace non-breaking spaces with regular spaces
    (goto-char (point-min))
    (while (search-forward "\u00a0" nil t)
      (replace-match " "))
    ;; Leave the BCP pointing asterisk (*) as-is —
    ;; it marks the half-verse inflection point for chanting.
    ;; Collapse excess blank lines
    (goto-char (point-min))
    (while (re-search-forward "\n\\{3,\\}" nil t)
      (replace-match "\n\n"))
    (string-trim (buffer-string))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Verse number overlays

(defun bcp-reader--add-verse-number-overlays ()
  "Add verse-number display overlays to the current buffer.

Scans for positions where `bcp-verse' is set (the first character of each
verse's text), collects them in order, then creates one overlay per verse
spanning from that position to the start of the next verse (or end of
buffer).  Each overlay carries:
  `before-string'    — the verse number, right-aligned in a 4-char field
  `wrap-prefix'      — 5-space indent for continuation lines
  `bcp-verse-number' — t (used to identify and remove these overlays)

Does nothing if the buffer contains no `bcp-verse' properties."
  (let (positions)
    ;; Pass 1 — collect verse-start positions in document order
    (let ((pos (point-min)))
      (while (< pos (point-max))
        (if (get-text-property pos 'bcp-verse)
            (progn
              (push pos positions)
              (setq pos (next-single-property-change pos 'bcp-verse
                                                     nil (point-max))))
          (setq pos (next-single-property-change pos 'bcp-verse
                                                 nil (point-max))))))
    (setq positions (nreverse positions))
    ;; Pass 2 — create overlays
    (cl-loop for (start next) on positions
             for vnum     = (get-text-property start 'bcp-verse)
             for book     = (get-text-property start 'bcp-book)
             for is-psalm = (equal book "Psalms")
             for end      = (or next (point-max))
             for disp     = (if is-psalm (format "%d." vnum) (format "%d" vnum))
             for pad      = (make-string (max 0 (- 4 (length disp))) ?\s)
             for ov       = (make-overlay start end)
             do
             (overlay-put ov 'bcp-verse-number t)
             (overlay-put ov 'before-string (concat pad disp " "))
             (overlay-put ov 'wrap-prefix "     "))))

(defun bcp-reader-toggle-verse-numbers ()
  "Toggle verse-number display in the current buffer."
  (interactive)
  (if (cl-some (lambda (ov) (overlay-get ov 'bcp-verse-number))
               (overlays-in (point-min) (point-max)))
      (remove-overlays (point-min) (point-max) 'bcp-verse-number t)
    (bcp-reader--add-verse-number-overlays)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Paragraph mode overlays

(defun bcp-reader--add-paragraph-overlays ()
  "Join verses within each chapter into a single paragraph.
Overlays the \\n before each verse ≥ 2 with a space, causing verse text
to flow continuously.  Chapter boundaries (\\n\\n before verse 1) are
left intact.  Overlays carry `bcp-paragraph t' for identification."
  (let ((pos (point-min)))
    (while (< pos (point-max))
      (let ((vnum (get-text-property pos 'bcp-verse)))
        (if (not vnum)
            (setq pos (next-single-property-change pos 'bcp-verse
                                                   nil (point-max)))
          (when (and (> vnum 1)
                     (> pos (point-min))
                     (eq (char-before pos) ?\n))
            (let ((ov (make-overlay (1- pos) pos)))
              (overlay-put ov 'bcp-paragraph t)
              (overlay-put ov 'display " ")))
          (setq pos (next-single-property-change pos 'bcp-verse
                                                 nil (point-max))))))))

(defun bcp-reader-toggle-paragraph-mode ()
  "Toggle paragraph mode in the current buffer.
When on, verses within a chapter flow as a single paragraph."
  (interactive)
  (if (cl-some (lambda (ov) (overlay-get ov 'bcp-paragraph))
               (overlays-in (point-min) (point-max)))
      (remove-overlays (point-min) (point-max) 'bcp-paragraph t)
    (bcp-reader--add-paragraph-overlays)))

(provide 'bcp-render)
;;; bcp-render.el ends here
