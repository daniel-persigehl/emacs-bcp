;;; bcp-notebook.el --- Bible study notebook: annotation, backlinks, navigation -*- lexical-binding: t -*-

;; Version: 0.3.0
;; Package-Requires: ((emacs "28.1") (org "9.6") (org-roam "2.2"))
;; Keywords: bible, bcp, org-roam, annotation

;;; Commentary:

;; Full two-buffer Bible study environment built on bcp-reader.
;; Adds: commentary org-file management, org-roam backlinks, org-capture,
;; contextual collation views, spanning psalm editor, cross-references,
;; and export.
;;
;; Quick start:
;;   (require 'bcp-notebook)
;;   (bible-commentary-open)
;;
;; Recommended binding:
;;   (global-set-key (kbd "C-c B") #'bible-commentary)

;;; Code:

(require 'bcp-reader)
(require 'org)
(require 'org-capture)
(require 'ox)

;; org-roam is optional; every call guards with `bible-commentary--roam-p'.
(declare-function org-roam-buffer-display-dedicated "org-roam-buffer")
(declare-function org-roam-db-autosync-mode         "org-roam")
(declare-function org-roam-node-at-point            "org-roam-node")
(declare-function org-id-get-create                 "org-id")
(declare-function org-id-get                        "org-id")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Notebook-specific customisation

(defcustom bible-commentary-file
  (expand-file-name "~/bible-commentary.org")
  "Path to the master org commentary file."
  :type 'file
  :group 'bible-commentary)

(defcustom bible-commentary-use-roam t
  "Non-nil: use org-roam nodes and backlinks when org-roam is loaded."
  :type 'boolean
  :group 'bible-commentary)

(defcustom bible-commentary-capture-key "B"
  "Key used in `org-capture-templates' for quick marginal notes."
  :type 'string
  :group 'bible-commentary)

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Notebook state

(defvar bible-commentary--spanning-units  nil "Units in the current spanning buffer.")
(defvar bible-commentary--spanning-master nil "Master commentary buffer for spanning sync.")
(defvar bible-commentary--spanning-label  nil "Display label for the current spanning psalm.")
(defvar bible-commentary--spanning-hit-refs nil "Hit refs in the current contextual buffer.")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; org-roam integration

(defun bible-commentary--roam-p ()
  "Non-nil when org-roam is available and `bible-commentary-use-roam' is set."
  (and bible-commentary-use-roam (featurep 'org-roam)))

(defun bible-commentary--roam-ensure-node ()
  "Give the heading at point an :ID: property, making it an org-roam node.
Must be called with point at or inside the target heading."
  (when (bible-commentary--roam-p)
    (require 'org-id)
    (save-excursion
      (org-back-to-heading t)
      (org-id-get-create))))

(defun bible-commentary-backlinks ()
  "Show the org-roam backlinks panel for the current verse node.

This is the primary cross-reference feature: if your note on Matthew 4:4
links to Deuteronomy 8:3, opening backlinks on the Deuteronomy node will
list the Matthew note — surfacing NT quotations of OT passages and vice versa."
  (interactive)
  (unless (bible-commentary--roam-p)
    (user-error
     (concat "org-roam is not loaded.  "
             "Install org-roam and ensure `bible-commentary-use-roam' is t.")))
  (require 'org-roam-buffer)
  (with-current-buffer bible-commentary--commentary-buffer
    (when bible-commentary--current-verse
      (bible-commentary--find-or-create-heading bible-commentary--current-verse))
    (call-interactively #'org-roam-buffer-display-dedicated)))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; org-capture integration

(defun bible-commentary-setup-capture ()
  "Register a bible-commentary capture template in `org-capture-templates'.
The template uses `bible-commentary-capture-key' (default \"B\") and files
the new note as a child of the current verse heading."
  (let ((key   bible-commentary-capture-key)
        (label "Bible marginal note"))
    ;; Remove stale entry if re-running setup
    (setq org-capture-templates
          (cl-remove-if (lambda (tmpl) (equal (car tmpl) key))
                        org-capture-templates))
    (push
     `(,key ,label entry
            (file+function
             ,bible-commentary-file
             (lambda ()
               (if bible-commentary--current-verse
                   (bible-commentary--find-or-create-heading
                    bible-commentary--current-verse)
                 (goto-char (point-max)))))
            ,(concat "* %?\n"
                     ":PROPERTIES:\n"
                     ":CREATED:   %U\n"
                     ":VERSE_REF: %(bible-commentary--ref-to-string-safe)\n"
                     ":END:\n")
            :prepend t
            :empty-lines 1)
     org-capture-templates)))

(defun bible-commentary-capture-note ()
  "Fire org-capture to add a quick marginal note to the current verse."
  (interactive)
  (unless bible-commentary--current-verse
    (user-error "No verse selected — use `bible-commentary-goto-verse' first."))
  (org-capture nil bible-commentary-capture-key))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Commentary org-file management

(defun bible-commentary--ensure-file ()
  "Create the master org file with boilerplate if it does not yet exist."
  (unless (file-exists-p bible-commentary-file)
    (with-temp-file bible-commentary-file
      (insert
       "#+TITLE: Bible Commentary\n"
       "#+AUTHOR: \n"
       "#+DATE: " (format-time-string "%Y-%m-%d") "\n"
       "#+STARTUP: overview\n"
       "#+TODO: OPEN(o) IN-DEVELOPMENT(d) | SETTLED(s)\n"
       "#+TAGS: verse(v) chapter(c) book(b) xref(x) theme(t) question(q) note(n)\n"
       (if (bible-commentary--roam-p)
           "#+ROAM_TAGS: bible-commentary\n" "")
       "\n* Commentary\n\n"))
    (message "Created %s" bible-commentary-file)))

(defun bible-commentary--find-or-create-heading (ref)
  "Navigate to (creating if needed) the heading for REF in the commentary buffer.
Returns point at the heading."
  (with-current-buffer bible-commentary--commentary-buffer
    (let ((anchor (bible-commentary--ref-to-org-anchor ref)))
      (goto-char (point-min))
      (if (re-search-forward
           (format "^[ \t]*:CUSTOM_ID:[ \t]+%s[ \t]*$"
                   (regexp-quote anchor))
           nil t)
          (progn (org-back-to-heading t) (point))
        (bible-commentary--insert-heading ref)))))

(defun bible-commentary--insert-heading (ref)
  "Insert a complete heading hierarchy for REF; return point at the leaf heading."
  (let* ((book    (plist-get ref :book))
         (chapter (plist-get ref :chapter))
         (vs      (plist-get ref :verse-start))
         (label   (bible-commentary--ref-to-string ref))
         (anchor  (bible-commentary--ref-to-org-anchor ref))
         (tr      (bcp-fetcher-active-translation ref)))
    ;; Ensure ancestor headings
    (bible-commentary--ensure-heading
     1 book (replace-regexp-in-string "[ ()]" "_" book))
    (when chapter
      (bible-commentary--ensure-heading
       2 (format "%s %d" book chapter)
       (format "%s_%d" (replace-regexp-in-string "[ ()]" "_" book) chapter)))
    ;; Insert the target heading
    (goto-char (point-max))
    (unless (bolp) (insert "\n"))
    (let ((level (cond (vs 3) (chapter 2) (t 1))))
      ;; Build psalm-specific properties: CANONICAL_UNIT and PSALM_VG
      (let* ((is-psalm  (and (bible-commentary--psalm-p ref)
                             (plist-get ref :chapter)))
             (unit-prop
              (when is-psalm
                (format ":CANONICAL_UNIT: unit-%d\n"
                        (plist-get ref :chapter))))
             (vg-prop
              (when is-psalm
                (let* ((mt  (plist-get ref :chapter))
                       (ann (bible-commentary--psalm-numbering-annotation mt)))
                  (when ann
                    (format ":PSALM_VG:    %s\n" ann)))))
             (tx-prop
              (bcp-fetcher-textual-status-property ref tr)))
        (insert (make-string level ?*) " " label "\n"
                ":PROPERTIES:\n"
                ":CUSTOM_ID:   " anchor "\n"
                ":VERSE_REF:   " label  "\n"
                ":TRANSLATION: " tr     "\n"
                (or unit-prop "")
                (or vg-prop   "")
                (or tx-prop   "")
                ":END:\n\n")))
    (org-back-to-heading t)
    ;; Give heading an org-id for roam
    (bible-commentary--roam-ensure-node)
    (point)))

(defun bible-commentary--ensure-heading (level title anchor)
  "Ensure a heading of LEVEL with TITLE and CUSTOM_ID ANCHOR exists."
  (with-current-buffer bible-commentary--commentary-buffer
    (goto-char (point-min))
    (unless (re-search-forward
             (format "^[ \t]*:CUSTOM_ID:[ \t]+%s[ \t]*$" (regexp-quote anchor))
             nil t)
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (insert (make-string level ?*) " " title "\n"
              ":PROPERTIES:\n"
              ":CUSTOM_ID: " anchor "\n"
              ":END:\n\n"))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Navigation

(defun bible-commentary-goto-verse (ref-string)
  "Navigate both buffers to REF-STRING.

Opens the contextual collation view in the commentary buffer, which shows
all notes overlapping the navigation target — the target itself plus any
broader notes that contain it (ranges, chapter notes, book notes).

For a fresh verse with no notes yet, lands directly on the new heading.
For chapter or book navigation, always opens the contextual view since
those granularities inherently span multiple headings.

Psalm numbering, Coverdale switching, and Vg/MT scheme detection all apply
as normal; spanning psalms open the dedicated spanning buffer instead."
  (interactive "sGo to verse (e.g. John 3:16 / John 3 / Ps 23 / Tob 12:1): ")
  (let* ((ref    (bible-commentary--parse-reference ref-string))
         (scheme (when (and ref (bible-commentary--psalm-p ref))
                   (bible-commentary--active-scheme
                    (bcp-fetcher-active-translation ref)))))
    (unless ref (user-error "Cannot parse '%s' — book not recognised" ref-string))
    ;; Validate chapter and verse bounds
    (let ((validation-error (bible-commentary--validate-ref ref)))
      (when validation-error
        (user-error "%s" validation-error)))
    (setq bible-commentary--current-verse ref)
    (bible-commentary--load-verse-text ref)
    (cond
     ;; Spanning psalm (Vg 9, MT 116, etc.) → dedicated spanning buffer
     ((bible-commentary--psalm-spans-p ref scheme)
      (bible-commentary--open-spanning-psalm ref scheme))
     ;; Chapter or book level → always open contextual view
     ((memq (bible-commentary--ref-granularity ref) '(chapter book))
      (bible-commentary--open-contextual-view
       ref (bible-commentary--ref-to-string ref)))
     ;; Verse or range → contextual view if overlapping notes exist,
     ;; else land directly on the heading
     (t
      (let* ((nav-ref (if (and (bible-commentary--psalm-p ref)
                               (eq scheme 'vg))
                          (bible-commentary--unit-ref
                           ref
                           (car (bible-commentary--psalm-canonical-units
                                 ref 'vg)))
                        ref))
             (hits (bible-commentary--collect-overlapping-headings nav-ref)))
        (if (or (null hits)
                ;; Only hit is the exact verse itself — no broader context
                (and (= (length hits) 1)
                     (equal (plist-get (caar hits) :verse-start)
                            (plist-get nav-ref :verse-start))
                     (equal (plist-get (caar hits) :chapter)
                            (plist-get nav-ref :chapter))))
            ;; No meaningful context — land directly
            (with-current-buffer bible-commentary--commentary-buffer
              (bible-commentary--find-or-create-heading nav-ref)
              (recenter 2))
          ;; Context exists — open contextual view
          (bible-commentary--open-contextual-view
           nav-ref (bible-commentary--ref-to-string nav-ref))))))
    (force-mode-line-update t)
    (let ((display-ref (if (and (bible-commentary--psalm-p ref) scheme)
                           (bible-commentary--psalm-display-string ref scheme)
                         (bible-commentary--ref-to-string ref))))
      (message "→ %s  [%s]" display-ref
               (bcp-fetcher-active-translation ref)))))

(defun bible-commentary--open-spanning-psalm (ref scheme)
  "Open an editable transient buffer for a psalm spanning multiple canonical units.
REF is the parsed psalm ref (e.g. Vg 9, MT 116); SCHEME is \\='vg or \\='mt."
  (let* ((units    (bible-commentary--psalm-canonical-units ref scheme))
         (label    (bible-commentary--psalm-display-string ref scheme))
         (tr       (bcp-fetcher-active-translation ref))
         (buf-name (format "*Commentary (editable): %s*" label))
         (master   bible-commentary--commentary-buffer))
    ;; Ensure all constituent headings exist in the master file
    (with-current-buffer master
      (dolist (unit units)
        (bible-commentary--find-or-create-heading
         (bible-commentary--unit-ref ref unit))))
    ;; Build the editable transient buffer
    (let ((buf (get-buffer-create buf-name)))
      (with-current-buffer buf
        (erase-buffer)
        (org-mode)
        (bible-commentary-spanning-mode 1)
        ;; Store metadata as buffer-local vars for the sync command
        (setq-local bible-commentary--spanning-units  units)
        (setq-local bible-commentary--spanning-master master)
        (setq-local bible-commentary--spanning-label  label)
        ;; Header comment
        (insert (format "#+TITLE: %s  [%s]\n" label tr))
        (insert "# Editable spanning view.  ")
        (insert "C-c C-w = sync to master | C-c C-j = jump to section in master\n\n")
        ;; One section per unit
        (let ((idx 1))
          (dolist (unit units)
            (let* ((mt-ref    (bible-commentary--unit-ref ref unit))
                   (mt-num    (bible-commentary--unit-to-mt unit))
                   (vg-nums   (bible-commentary--unit-to-vg unit))
                   (vg-str    (mapconcat #'number-to-string vg-nums "/"))
                   (sec-label (if (eq scheme 'vg)
                                  (format "MT %d  (= Vg %s)" mt-num vg-str)
                                (format "Vg %s  (= MT %d)" vg-str mt-num)))
                   ;; Pull existing content from master
                   (existing  (bible-commentary--spanning-extract-unit
                                master mt-ref)))
              ;; Separator between sections (not before first)
              (when (> idx 1)
                (insert "#+BEGIN_COMMENT\n")
                (insert (make-string 60 ?═) "\n")
                (let* ((prev-unit (nth (- idx 2) units))
                       (prev-mt   (bible-commentary--unit-to-mt prev-unit))
                       (curr-mt   mt-num))
                  (insert (format "  ↑  MT %d above   │   MT %d below  ↓\n"
                                  prev-mt curr-mt)))
                (insert (make-string 60 ?═) "\n")
                (insert "#+END_COMMENT\n\n"))
              ;; Section heading
              (insert (format "* %s\n" sec-label))
              (insert ":PROPERTIES:\n")
              (insert (format ":CANONICAL_UNIT: unit-%s\n" unit))
              (insert (format ":SECTION_IDX:   %d\n" idx))
              (insert ":END:\n\n")
              ;; Existing notes (body only, not the heading line itself)
              (when existing
                (insert existing)
                (unless (string-suffix-p "\n" existing) (insert "\n")))
              (insert "\n")
              (cl-incf idx))))
        (goto-char (point-min))
        ;; Move past the header comments to first editable section
        (re-search-forward "^\\* " nil t)
        (beginning-of-line))
      (pop-to-buffer buf))))

(defun bible-commentary--spanning-extract-unit (master ref)
  "Extract body text (below properties drawer) of REF heading in MASTER.
Returns the body as a string, or nil if the heading has no body yet."
  (with-current-buffer master
    (save-excursion
      (let ((anchor (bible-commentary--ref-to-org-anchor ref)))
        (goto-char (point-min))
        (when (re-search-forward
               (format "^[ 	]*:CUSTOM_ID:[ 	]+%s[ 	]*$"
                       (regexp-quote anchor))
               nil t)
          (org-back-to-heading t)
          (let* ((beg  (point))
                 (end  (save-excursion (org-end-of-subtree t t) (point)))
                 (text (buffer-substring-no-properties beg end)))
            (with-temp-buffer
              (insert text)
              (goto-char (point-min))
              (forward-line 1) ; skip heading
              (when (looking-at "[ 	]*:PROPERTIES:")
                (re-search-forward "^[ 	]*:END:[ 	]*
?" nil t))
              (let ((body (string-trim
                           (buffer-substring (point) (point-max)))))
                (unless (string-empty-p body) body)))))))))

(defun bible-commentary-spanning-sync ()
  "Write all sections of this spanning buffer back to the master commentary file.
Each section is identified by its :CANONICAL_UNIT: property and synced
independently.  Reports a summary in the minibuffer."
  (interactive)
  (unless (bound-and-true-p bible-commentary--spanning-units)
    (user-error "Not in a spanning commentary buffer"))
  (let* ((master  bible-commentary--spanning-master)
         (label   bible-commentary--spanning-label)
         (synced  0))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "^\\* " nil t)
        (org-back-to-heading t)
                  (let* ((raw-unit (org-entry-get (point) "CANONICAL_UNIT"))
                 ;; Strip "unit-" prefix added to prevent org Lisp interpretation
                 (unit     (when raw-unit
                             (if (string-prefix-p "unit-" raw-unit)
                                 (substring raw-unit 5)
                               raw-unit)))
                 (mt-num (when unit
                           (string-to-number (string-trim-right unit "ab")))))
          (let* ((verse-ref-str (org-entry-get (point) "VERSE_REF"))
                 (lookup-ref
                  (cond
                   ;; Psalm spanning buffer: use CANONICAL_UNIT → MT number
                   (unit
                    (list :book "Psalms"
                          :chapter (string-to-number
                                    (string-trim-right unit "ab"))
                          :verse-start nil :verse-end nil))
                   ;; Contextual buffer: use VERSE_REF property
                   (verse-ref-str
                    (bible-commentary--parse-reference
                     (string-trim verse-ref-str)))
                   (t nil))))
          (when lookup-ref
            ;; Get body content from this section (below properties drawer)
            (let* ((sec-beg  (point))
                   (sec-end  (save-excursion (org-end-of-subtree t t) (point)))
                   (sec-text (buffer-substring-no-properties sec-beg sec-end))
                   (anchor   (bible-commentary--ref-to-org-anchor lookup-ref)))
              ;; Extract body (strip transient heading + properties)
              (let ((body (with-temp-buffer
                            (insert sec-text)
                            (goto-char (point-min))
                            (forward-line 1) ; skip heading
                            (when (looking-at "[ \t]*:PROPERTIES:")
                              (re-search-forward "^[ \t]*:END:[ \t]*\n?" nil t))
                            (buffer-substring (point) (point-max)))))
                ;; Write body into master heading
                (with-current-buffer master
                  (save-excursion
                    (goto-char (point-min))
                    (when (re-search-forward
                           (format "^[ \t]*:CUSTOM_ID:[ \t]+%s[ \t]*$"
                                   (regexp-quote anchor))
                           nil t)
                      (org-back-to-heading t)
                      (org-end-of-meta-data t) ; past heading + properties
                      (let ((content-beg (point))
                            (content-end (save-excursion
                                           (org-end-of-subtree t t) (point))))
                        (delete-region content-beg content-end)
                        (insert body)
                        (cl-incf synced))))))))))))
    (with-current-buffer master (save-buffer))
    (message "Synced %d section%s to %s"
             synced (if (= synced 1) "" "s") label)))

(defun bible-commentary-spanning-jump (n)
  "Jump to the Nth canonical unit of this spanning psalm in the master file.
Prompts for N if not supplied as a prefix argument."
  (interactive "NJump to section number: ")
  (unless (bound-and-true-p bible-commentary--spanning-units)
    (user-error "Not in a spanning commentary buffer"))
  (let* ((units  bible-commentary--spanning-units)
         (unit   (nth (1- n) units)))
    (unless unit
      (user-error "No section %d (buffer has %d sections)" n (length units)))
    (let* ((mt-num (bible-commentary--unit-to-mt unit))
           (mt-ref (list :book "Psalms" :chapter mt-num
                         :verse-start nil :verse-end nil))
           (anchor (bible-commentary--ref-to-org-anchor mt-ref)))
      (with-current-buffer bible-commentary--spanning-master
        (goto-char (point-min))
        (if (re-search-forward
             (format "^[ \t]*:CUSTOM_ID:[ \t]+%s[ \t]*$"
                     (regexp-quote anchor))
             nil t)
            (progn
              (org-back-to-heading t)
              (pop-to-buffer bible-commentary--spanning-master)
              (recenter 2)
              (message "Jumped to MT %d in master file" mt-num))
          (message "Heading for MT %d not found in master file" mt-num))))))

(defun bible-commentary-next-chapter ()
  "Advance one chapter in both buffers."
  (interactive)
  (when bible-commentary--current-verse
    (let ((new (copy-sequence bible-commentary--current-verse)))
      (setq new (plist-put new :chapter (1+ (or (plist-get new :chapter) 1)))
            new (plist-put new :verse-start nil)
            new (plist-put new :verse-end   nil))
      (bible-commentary-goto-verse (bible-commentary--ref-to-string new)))))

(defun bible-commentary-prev-chapter ()
  "Go back one chapter in both buffers."
  (interactive)
  (when bible-commentary--current-verse
    (let* ((new (copy-sequence bible-commentary--current-verse))
           (ch  (or (plist-get new :chapter) 2)))
      (when (> ch 1)
        (setq new (plist-put new :chapter (1- ch))
              new (plist-put new :verse-start nil)
              new (plist-put new :verse-end   nil))
        (bible-commentary-goto-verse (bible-commentary--ref-to-string new))))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Cross-references (roam-aware)

(defun bible-commentary-insert-xref (ref-string)
  "Insert a cross-reference to REF-STRING at point in the commentary buffer.

With org-roam active, inserts an =id:= link so the roam database records
the connection.  Without roam, inserts a plain CUSTOM_ID internal link."
  (interactive "sCross-reference (e.g. Isa 53:5 / Wis 3:1 / Ps 22): ")
  (let ((ref (bible-commentary--parse-reference ref-string)))
    (unless ref (user-error "Cannot parse: %s" ref-string))
    (with-current-buffer bible-commentary--commentary-buffer
      (save-excursion (bible-commentary--find-or-create-heading ref))
      (let ((label (bible-commentary--ref-to-string ref)))
        (if (bible-commentary--roam-p)
            (let ((node-id
                   (save-excursion
                     (bible-commentary--find-or-create-heading ref)
                     (require 'org-id)
                     (org-id-get))))
              (insert (if node-id
                          (format "[[id:%s][%s]]" node-id label)
                        (format "[[#%s][%s]]"
                                (bible-commentary--ref-to-org-anchor ref)
                                label))))
          (insert (format "[[#%s][%s]]"
                          (bible-commentary--ref-to-org-anchor ref)
                          label))))
      (message "Cross-reference inserted: %s"
               (bible-commentary--ref-to-string ref)))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Collation view (non-roam fallback; works alongside roam too)

(defun bible-commentary--collect-overlapping-headings (ref)
  "Return an alist of (ref-plist . heading-text) for every heading in the
commentary buffer whose :VERSE_REF: overlaps REF.
Results are ordered from broadest scope (book) to narrowest (verse)."
  (let ((hits '()))
    (with-current-buffer bible-commentary--commentary-buffer
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward
                "^[ 	]*:VERSE_REF:[ 	]+\(.*\)$" nil t)
          (let ((other (bible-commentary--parse-reference
                        (string-trim (match-string 1)))))
            (when (bible-commentary--ref-overlaps-p ref other)
              (save-excursion
                (org-back-to-heading t)
                (push (cons other
                             (buffer-substring-no-properties
                              (point)
                              (save-excursion
                                (org-end-of-subtree t t) (point))))
                      hits)))))))
    ;; Sort: book-level first, then chapter, then verse — broadest context first
    (sort hits
          (lambda (a b)
            (let* ((ra (car a)) (rb (car b))
                   (ca (plist-get ra :chapter))   (cb (plist-get rb :chapter))
                   (va (plist-get ra :verse-start)) (vb (plist-get rb :verse-start)))
              (cond
               ((and (null ca) cb)  t)   ; book-level sorts before chapter
               ((and ca (null cb)) nil)
               ((and (null va) vb)  t)   ; chapter-level sorts before verse
               ((and va (null vb)) nil)
               ((and va vb) (< va vb))   ; earlier verse first
               (t nil)))))))

(defun bible-commentary--ref-granularity (ref)
  "Return a symbol describing the granularity of REF: \\='book, \\='chapter, or \\='verse."
  (cond ((null (plist-get ref :chapter))     'book)
        ((null (plist-get ref :verse-start)) 'chapter)
        (t                                    'verse)))

(defun bible-commentary--contextual-title (ref hits)
  "Return a descriptive title string for a contextual collation view."
  (let* ((label       (bible-commentary--ref-to-string ref))
         (tr          (bcp-fetcher-active-translation ref))
         (granularity (bible-commentary--ref-granularity ref))
         (hit-refs    (mapcar #'car hits))
         (broader     (cl-remove-if-not
                       (lambda (r)
                         (and (bible-commentary--ref-overlaps-p r ref)
                              (not (equal r ref))))
                       hit-refs))
         ;; Textual status annotation (shown regardless of hit count)
         (tx-ann      (let ((s (bcp-fetcher-textual-status ref)))
                        (when (and s (bcp-fetcher-critical-translation-p tr))
                          (format "  [⚠ %s]"
                                  (pcase (plist-get s :status)
                                    ('omitted  "absent from critical text")
                                    ('disputed (plist-get s :label))))))))
    (pcase granularity
      ('book    (format "Notes for %s  (all chapters)%s" label (or tx-ann "")))
      ('chapter (format "Notes for %s  (all verses)%s"   label (or tx-ann "")))
      (_        (if broader
                    (format "Notes for %s  (+ context: %s)%s"
                            label
                            (mapconcat #'bible-commentary--ref-to-string
                                       (seq-take broader 3) ", ")
                            (or tx-ann ""))
                  (format "Notes for %s%s" label (or tx-ann "")))))))

(defun bible-commentary-collate-verse (ref-string)
  "Open an editable contextual view of all notes overlapping REF-STRING."
  (interactive "sCollate notes for: ")
  (let* ((ref   (bible-commentary--parse-reference ref-string))
         (label (bible-commentary--ref-to-string ref)))
    (unless ref (user-error "Cannot parse: %s" ref-string))
    (bible-commentary--open-contextual-view ref label)))

(defun bible-commentary--open-contextual-view (ref label)
  "Open an editable contextual view for REF, titled LABEL."
  (let* ((master (or bible-commentary--commentary-buffer
                     (user-error "No commentary buffer open")))
         (tr     (bcp-fetcher-active-translation ref))
         ;; Ensure the navigation target heading exists
         (_      (with-current-buffer master
                   (bible-commentary--find-or-create-heading ref)))
         ;; Collect all overlapping headings (sorted broadest → narrowest)
         (hits   (bible-commentary--collect-overlapping-headings ref))
         (title  (bible-commentary--contextual-title ref hits))
         (buf-name (format "*Commentary: %s*" label)))
    (if (null hits)
        ;; Nothing yet — land directly on the new heading in the master file
        (progn
          (with-current-buffer master
            (bible-commentary--find-or-create-heading ref)
            (recenter 2))
          (pop-to-buffer master))
      ;; Build editable contextual buffer
      (let ((buf (get-buffer-create buf-name)))
        (with-current-buffer buf
          (erase-buffer)
          (org-mode)
          (bible-commentary-spanning-mode 1)
          (setq-local bible-commentary--spanning-units  nil)
          (setq-local bible-commentary--spanning-master master)
          (setq-local bible-commentary--spanning-label  label)
          ;; Store hit refs for sync
          (setq-local bible-commentary--spanning-hit-refs
                      (mapcar #'car hits))
          (insert (format "#+TITLE: %s\n" title))
          (insert "# C-c C-w = sync to master | C-c C-j = jump section in master\n\n")
          ;; One section per overlapping heading
          (let ((idx 1) (total (length hits)))
            (dolist (hit hits)
              (let* ((hit-ref  (car hit))
                     (hit-text (cdr hit))
                     (hit-label (bible-commentary--ref-to-string hit-ref))
                     (is-nav   (equal hit-ref ref)))
                ;; Separator between sections
                (when (> idx 1)
                  (insert "#+BEGIN_COMMENT\n")
                  (insert (make-string 60 ?─) "\n")
                  (insert "#+END_COMMENT\n\n"))
                ;; Section heading — mark the navigation target clearly
                (insert (format "* %s%s\n"
                                hit-label
                                (if is-nav "  ← current" "")))
                (insert ":PROPERTIES:\n")
                (insert (format ":VERSE_REF:   %s\n" hit-label))
                (insert (format ":SECTION_IDX: %d\n" idx))
                (insert ":END:\n\n")
                ;; Body: extract from master heading (below properties drawer)
                (let ((body (bible-commentary--spanning-extract-unit
                             master hit-ref)))
                  (when body (insert body "\n")))
                (insert "\n")
                (cl-incf idx))))
          ;; Position at the nav-target section
          (goto-char (point-min))
          (when (re-search-forward " ← current" nil t)
            (org-back-to-heading t)
            (org-show-subtree)))
        (pop-to-buffer buf)))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Export

(defun bible-commentary-export-to-html ()
  "Export the master commentary org file to HTML."
  (interactive)
  (with-current-buffer bible-commentary--commentary-buffer
    (org-html-export-to-html)
    (message "HTML export complete.")))

(defun bible-commentary-export-to-pdf ()
  "Export the master commentary org file to PDF via ox-latex."
  (interactive)
  (with-current-buffer bible-commentary--commentary-buffer
    (org-latex-export-to-pdf)
    (message "PDF export complete.")))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Buffer & window setup

(defun bible-commentary--setup-bible-buffer (buf)
  (with-current-buffer buf
    (read-only-mode 1)
    (visual-line-mode 1)
    ;; Ensure Unicode characters display correctly
    (set-buffer-file-coding-system 'utf-8)
    (when (fboundp 'display-line-numbers-mode)
      (display-line-numbers-mode -1))
    (use-local-map bible-commentary-bible-mode-map)
    (setq-local header-line-format
                '(:eval
                  (if bible-commentary--current-verse
                      (let* ((ref    bible-commentary--current-verse)
                             (tr     (bcp-fetcher-active-translation ref))
                             (scheme (when (bible-commentary--psalm-p ref)
                                       (bible-commentary--active-scheme tr)))
                             (tx-ann (bcp-fetcher-textual-header-annotation
                                      ref tr)))
                        (format " 📖  %s  [%s]%s"
                                (bible-commentary--psalm-display-string ref scheme)
                                tr
                                (or tx-ann "")))
                    " 📖  Bible — no verse selected")))
    (when bible-commentary-sync-scroll
      (add-hook 'post-command-hook #'bible-commentary--sync-scroll nil t))))

(defun bible-commentary--setup-commentary-buffer (buf)
  (with-current-buffer buf
    (unless (eq major-mode 'org-mode) (org-mode))
    (bible-commentary-mode 1)
    (setq-local header-line-format
                '(:eval
                  (if bible-commentary--current-verse
                      (format " ✍   Commentary — %s"
                              (bible-commentary--ref-to-string
                               bible-commentary--current-verse))
                    " ✍   Commentary")))
    (when bible-commentary-sync-scroll
      (add-hook 'post-command-hook #'bible-commentary--sync-scroll nil t))
    (when (bible-commentary--roam-p)
      (require 'org-roam)
      (unless (bound-and-true-p org-roam-db-autosync-mode)
        (org-roam-db-autosync-mode 1)))))

(defun bible-commentary--setup-windows ()
  (delete-other-windows)
  (let* ((bible-win (selected-window))
         (comm-win  (if (eq bible-commentary-window-layout 'top-bottom)
                        (split-window-below)
                      (split-window-right))))
    (set-window-buffer bible-win bible-commentary--bible-buffer)
    (set-window-buffer comm-win  bible-commentary--commentary-buffer)
    (when (eq bible-commentary-window-layout 'side-by-side)
      (with-selected-window comm-win (enlarge-window-horizontally 10)))
    (select-window comm-win)))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Spanning buffer minor mode and keymaps

(defvar bible-commentary-spanning-mode-map
  (let ((m (make-sparse-keymap)))
    (define-key m (kbd "C-c C-w") #'bible-commentary-spanning-sync)
    (define-key m (kbd "C-c C-j") #'bible-commentary-spanning-jump)
    ;; Numbered shortcuts for up to 4 sections (covers all real cases)
    (define-key m (kbd "C-c C-1") (lambda () (interactive) (bible-commentary-spanning-jump 1)))
    (define-key m (kbd "C-c C-2") (lambda () (interactive) (bible-commentary-spanning-jump 2)))
    (define-key m (kbd "C-c C-3") (lambda () (interactive) (bible-commentary-spanning-jump 3)))
    (define-key m (kbd "C-c C-4") (lambda () (interactive) (bible-commentary-spanning-jump 4)))
    m)
  "Keymap for `bible-commentary-spanning-mode'.")

(define-minor-mode bible-commentary-spanning-mode
  "Minor mode for editable spanning psalm buffers."
  :lighter " BSpan"
  :keymap bible-commentary-spanning-mode-map)

(defvar bible-commentary-bible-mode-map
  (let ((m (make-sparse-keymap)))
    (define-key m (kbd "g")     #'bible-commentary-goto-verse)
    (define-key m (kbd "n")     #'bible-commentary-next-chapter)
    (define-key m (kbd "p")     #'bible-commentary-prev-chapter)
    (define-key m (kbd "x")     #'bible-commentary-insert-xref)
    (define-key m (kbd "c")     #'bible-commentary-capture-note)
    (define-key m (kbd "b")     #'bible-commentary-backlinks)
    (define-key m (kbd "C-c v") #'bible-commentary-collate-verse)
    (define-key m (kbd "N")     #'bible-commentary-psalm-lookup)
    (define-key m (kbd "C-c s") #'bible-commentary-set-scheme)
    (define-key m (kbd "C-c t") #'bible-commentary-set-translation)
    (define-key m (kbd "C-c h") #'bible-commentary-export-to-html)
    (define-key m (kbd "C-c p") #'bible-commentary-export-to-pdf)
    m)
  "Keymap active in the Bible text buffer.")

(defvar bible-commentary-mode-map
  (let ((m (make-sparse-keymap)))
    (define-key m (kbd "C-c g")   #'bible-commentary-goto-verse)
    (define-key m (kbd "C-c n")   #'bible-commentary-next-chapter)
    (define-key m (kbd "C-c p")   #'bible-commentary-prev-chapter)
    (define-key m (kbd "C-c x")   #'bible-commentary-insert-xref)
    (define-key m (kbd "C-c c")   #'bible-commentary-capture-note)
    (define-key m (kbd "C-c b")   #'bible-commentary-backlinks)
    (define-key m (kbd "C-c C-v") #'bible-commentary-collate-verse)
    (define-key m (kbd "C-c N")   #'bible-commentary-psalm-lookup)
    (define-key m (kbd "C-c S")   #'bible-commentary-set-scheme)
    (define-key m (kbd "C-c C-t") #'bible-commentary-set-translation)
    (define-key m (kbd "C-c C-h") #'bible-commentary-export-to-html)
    (define-key m (kbd "C-c C-P") #'bible-commentary-export-to-pdf)
    m)
  "Keymap for `bible-commentary-mode' minor mode in the commentary buffer.")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Minor mode

(define-minor-mode bible-commentary-mode
  "Minor mode for the bible-commentary org buffer.
Adds keybindings and a header line showing the current verse."
  :lighter " BComm"
  :keymap bible-commentary-mode-map)

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Entry point

;;;###autoload
(defun bible-commentary-open (&optional bible-path commentary-path)
  "Open the Bible commentary environment.

BIBLE-PATH       — path to a local plain-text Bible (KJV recommended).
                   Overrides `bible-commentary-bible-file'.
COMMENTARY-PATH  — path to the master org file.
                   Defaults to `bible-commentary-file'.

On first run, if no Bible path is configured, you are asked:
  [l] local file   [o] Oremus fetch   [e] empty buffer

Keybindings (Bible buffer):
  g  goto-verse        n/p  next/prev chapter
  x  insert-xref       c    capture-note
  b  backlinks         C-c t  set-translation"
  (interactive)
  (let ((cpath (or commentary-path bible-commentary-file)))
    (setq bible-commentary-file cpath)
    (bible-commentary--ensure-file)
    (setq bible-commentary--commentary-buffer (find-file-noselect cpath)
          bible-commentary--bible-buffer      (get-buffer-create "*Bible Text*"))
    (let ((bpath (or bible-path bible-commentary-bible-file)))
      (if bpath
          (bible-commentary--load-local-file bpath)
        (pcase (read-char-choice
                "Bible source: [l]ocal file  [o]remus  [e]mpty  "
                '(?l ?o ?e))
          (?l (bible-commentary--load-local-file
               (read-file-name "Plain-text Bible file: ")))
          (?o (bcp-fetcher-fetch-oremus
               (read-string "Passage (e.g. Genesis 1): ")
               (lambda (text label) (bible-commentary--load-text text label))
               bible-commentary-translation))
          (_ nil))))
    (bible-commentary--setup-bible-buffer      bible-commentary--bible-buffer)
    (bible-commentary--setup-commentary-buffer bible-commentary--commentary-buffer)
    (bible-commentary-setup-capture)
    (bible-commentary--setup-windows)
    (message "Bible commentary ready — KJVA default, Coverdale for Psalms, NRSV for Orthodox books%s"
             (if (bible-commentary--roam-p) ", org-roam backlinks active" ""))))

;;;###autoload
(defalias 'bible-commentary #'bible-commentary-open)


(provide 'bcp-notebook)
;;; bcp-notebook.el ends here
