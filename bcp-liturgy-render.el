;;; bcp-liturgy-render.el --- Rite-agnostic Office buffer rendering -*- lexical-binding: t -*-

;; Keywords: liturgy, bcp, office, rendering

;;; Commentary:

;; Rite-agnostic rendering primitives for the Daily Office buffer.
;; Contains no knowledge of any specific prayer book edition or ordo format.
;;
;; This layer owns:
;;   - Buffer setup (text-mode, read-only, visual-line-mode, overlays)
;;   - Heading faces and insert-heading
;;   - insert-rubric, insert-versicles, insert-text-block, insert-canticle-text
;;   - insert-lords-prayer, insert-fixed-text
;;   - normalise-spacing
;;   - day-identity display block (renders the structured identity plist)
;;
;; What does NOT live here (belongs in bcp-1662-render.el or equivalent):
;;   - The ordo walker (render-office)
;;   - Step-type dispatch (the :rubric/:canticle/:lesson cond)
;;   - Rubrical option logic (penitential intro, absolution flow, etc.)
;;   - Any defcustoms governing rubrical behaviour
;;
;; Rite-specific renderers require this file and call into it for all
;; buffer operations.  They never manipulate the buffer directly.

;;; Code:

(require 'cl-lib)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Defgroup and shared rendering defcustoms
;;;; ══════════════════════════════════════════════════════════════════════════

(defgroup bcp-liturgy-render nil
  "Rendering primitives for the Daily Office buffer."
  :prefix "bcp-liturgy-render-"
  :group 'bcp-liturgy)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Heading faces
;;;; ══════════════════════════════════════════════════════════════════════════

(defface bcp-liturgy-heading-1
  '((t :inherit default :weight bold :height 1.4 :underline t))
  "Face for the top-level Office heading (title line)."
  :group 'bcp-liturgy-render)

(defface bcp-liturgy-heading-2
  '((t :inherit default :weight bold :height 1.15))
  "Face for second-level Office headings (major sections)."
  :group 'bcp-liturgy-render)

(defface bcp-liturgy-heading-3
  '((t :inherit default :weight bold))
  "Face for third-level Office headings (canticles, lessons, collects)."
  :group 'bcp-liturgy-render)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Buffer insertion primitives
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-liturgy-render--insert-heading (level text)
  "Insert a heading of LEVEL (1, 2, or 3) with TEXT using a face overlay."
  (let* ((face (pcase level
                 (1 'bcp-liturgy-heading-1)
                 (2 'bcp-liturgy-heading-2)
                 (_ 'bcp-liturgy-heading-3)))
         (start (point)))
    (insert text "\n")
    (overlay-put (make-overlay start (point)) 'face face)))

(defun bcp-liturgy-render--insert-rubric (text rubric-face-fn)
  "Insert TEXT as an indented rubric with a blank line before it.
RUBRIC-FACE-FN is a zero-argument function returning the face to use.
Ensures one blank line before the rubric regardless of what precedes it.
Uses an overlay so the face survives any fontification."
  (let* ((indent   "    ")
         (indented (concat indent text)))
    (unless (string-suffix-p "\n\n"
               (buffer-substring (max (point-min) (- (point) 2))
                                 (point)))
      (insert "\n"))
    (let ((start (point)))
      (insert indented "\n\n")
      (put-text-property start (point) 'wrap-prefix "    ")
      (let ((ov (make-overlay start (point))))
        (overlay-put ov 'face (funcall rubric-face-fn))
        (overlay-put ov 'bcp-liturgy-rubric t)))))

(defun bcp-liturgy-render--insert-versicles (pairs)
  "Insert versicle PAIRS as minister/response lines.
Uses ℣ (U+2123, versiculum) and ℟ (U+211F, responsorium)."
  (dolist (pair pairs)
    (let ((v (car pair))
          (r (cadr pair)))
      (insert (format "℣. %s\n" v))
      (when r (insert (format "℟. %s\n" r))))))

(defun bcp-liturgy-render--insert-lords-prayer ()
  "Insert the Lord's Prayer as a bold placeholder line."
  (let ((start (point)))
    (insert "OUR FATHER...\n")
    (overlay-put (make-overlay start (1- (point)))
                 'face '(:weight bold))))

(defun bcp-liturgy-render--insert-fixed-text (_name text)
  "Insert fixed TEXT.  NAME is for identification only and is not displayed."
  (insert text "\n"))

(defun bcp-liturgy-render--insert-text-block (text)
  "Insert TEXT as plain liturgical or scriptural text.
No leading blank line — callers are responsible for preceding spacing.
Headings flow directly into their text; rubrics supply their own spacing.

Post-processing applied:
  1. Strip display text properties from verse markers (from dom-to-text)
  2. Clean Windows-1252 C1 characters that survived fetch/parse
  3. Set wrap-prefix on each line according to its type"
  (let ((start (point)))
    (insert text "\n")
    ;; 1. Strip display properties (verse marker right-alignment)
    (save-excursion
      (goto-char start)
      (while (< (point) (point-max))
        (let ((next (next-single-property-change (point) 'display nil (point-max))))
          (when (get-text-property (point) 'display)
            (remove-text-properties (point) (or next (point-max)) '(display nil)))
          (goto-char (or next (point-max))))))
    ;; 2. Clean Windows-1252 C1 chars that survived into the buffer
    (save-excursion
      (goto-char start)
      (dolist (pair '(("\u0091" . "\u2018")   ; left single quote
                      ("\u0092" . "\u2019")   ; right single quote / apostrophe
                      ("\u0093" . "\u201C")   ; left double quote
                      ("\u0094" . "\u201D")   ; right double quote
                      ("\u0096" . "\u2013")   ; en dash
                      ("\u0097" . "\u2014")   ; em dash
                      ("\u00a0" . " ")))      ; non-breaking space
        (goto-char start)
        (while (search-forward (car pair) (point-max) t)
          (replace-match (cdr pair) t t))))
    ;; 3. Set wrap-prefix per line
    (save-excursion
      (goto-char start)
      (while (< (point) (point-max))
        (let ((bol (line-beginning-position)))
          (cond
           ;; Verse number line: indent continuation by the verse number width
           ((looking-at "[ \t]*[0-9]+\\.?[ \t]+")
            (put-text-property bol (line-end-position) 'wrap-prefix
                               (make-string (- (match-end 0) bol) ?\s)))
           ;; Already-indented line (canticle verse, continuation)
           ((looking-at "   ")
            (put-text-property bol (line-end-position) 'wrap-prefix "   "))
           ;; Capital-letter start (first word of paragraph/prayer)
           ((looking-at "[A-Z]")
            (put-text-property bol (line-end-position) 'wrap-prefix "   "))))
        (forward-line 1)))))

(defun bcp-liturgy-render--insert-canticle-text (text)
  "Insert canticle TEXT with consistent 3-space indent on all verses.
Canticle strings store the first verse at column 0; subsequent verses
begin with a newline + 3 spaces.  This function prepends the 3-space
indent to the first verse so all verses are visually aligned."
  (bcp-liturgy-render--insert-text-block (concat "   " text)))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Spacing normalisation
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-liturgy-render--normalise-spacing ()
  "Collapse runs of 3+ newlines to exactly 2 in the current buffer.
Called after all content is inserted, before read-only-mode is set."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\n\n\n+" nil t)
      (replace-match "\n\n"))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Buffer setup
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-liturgy-render--setup-buffer (buffer-name)
  "Prepare BUFFER-NAME as a fresh, writable Office buffer.
Returns the buffer.  The caller is responsible for populating it and
then calling `bcp-liturgy-render--finalise-buffer'."
  (let ((buf (get-buffer-create buffer-name)))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (text-mode))
    buf))

(defun bcp-liturgy-render--finalise-buffer ()
  "Finalise the current Office buffer after all content has been inserted.
Normalises spacing, enables visual-line-mode, and sets read-only-mode."
  (goto-char (point-min))
  (bcp-liturgy-render--normalise-spacing)
  (visual-line-mode 1)
  (read-only-mode 1))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Liturgical identity display block
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-liturgy-render--insert-identity-block (day-id feast-name feast-rank)
  "Insert the liturgical identity block into the current buffer.

DAY-ID is a plist from a `bcp-*-day-identity' function with keys:
  :day-name, :week-name, :subdivision, :season-name, :season-symbol

FEAST-NAME is a string or nil.  FEAST-RANK is a symbol or nil.

On feast days the feast leads; on ordinary days the day-id fields
are rendered from most specific to most general, suppressing
redundancies (e.g. subdivision = week-name)."
  (let ((info-start (point))
        (day-name  (plist-get day-id :day-name))
        (week-name (plist-get day-id :week-name))
        (subdiv    (plist-get day-id :subdivision))
        (seas-name (plist-get day-id :season-name)))
    (if feast-name
        ;; Feast day: feast name leads, season context follows
        (progn
          (insert (format "    Feast:  %s (%s)\n" feast-name
                          (symbol-name (or feast-rank 'lesser))))
          (let ((context (or (when subdiv (format "%s — %s" seas-name subdiv))
                             week-name
                             seas-name)))
            (when context
              (insert (format "    Season: %s\n" context)))))
      ;; Ordinary day: render all non-nil, non-redundant fields
      (when day-name
        (insert (format "    Day:    %s\n" day-name)))
      (when (and week-name (not (equal week-name day-name)))
        (insert (format "    Week:   %s\n" week-name)))
      (when (and subdiv (not (equal subdiv week-name)))
        (insert (format "    Period: %s\n" subdiv)))
      (insert (format "    Season: %s\n" seas-name)))
    ;; Apply italic overlay to the whole block
    (let ((ov (make-overlay info-start (point))))
      (overlay-put ov 'face '(:slant italic)))))


(provide 'bcp-liturgy-render)
;;; bcp-liturgy-render.el ends here
