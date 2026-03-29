;;; bcp-fetcher-officium.el --- Divinum Officium data importer -*- lexical-binding: t -*-

;;; Commentary:

;; One-time importer that reads English Tempora files from a local
;; Divinum Officium checkout and emits resolved plist data for use
;; by the BCP liturgy layer.
;;
;; Usage (interactive):
;;   M-x bcp-officium-import-tempora
;;   — prompts for the DO checkout root and the output directory.
;;
;; Usage (programmatic):
;;   (bcp-officium-import-tempora "/path/to/divinum-officium"
;;                                 bcp--package-directory)
;;
;; Strategy: all @ cross-references are fully resolved at import time.
;; The emitted data files contain only concrete text and scripture citations;
;; no DO source is required at runtime.
;;
;; Scope:
;;   • English Tempora, DA rubric only.
;;   • Base files only; 'o' suffix (Office of Readings override) files are skipped.
;;   • Scripture lectiones → citation only (text fetched by bcp-fetcher at runtime).
;;   • Patristic / homily lectiones → full body text embedded.
;;   • Responsories included as raw text (useful for context; not fetched).
;;   • TODO (low priority): Sanctorale.

;;; Code:

(require 'cl-lib)

;;;; ── Path constants ───────────────────────────────────────────────────────────

(defconst bcp-officium--english-base "web/www/horas/English"
  "Path to English horas within a Divinum Officium checkout.")

(defconst bcp-officium--tempora-subdir "Tempora"
  "Subdirectory within the English base for Tempora files.")

;;;; ── Biblical book abbreviations ─────────────────────────────────────────────

(defconst bcp-officium--biblical-books
  '("Gen" "Ex" "Lev" "Num" "Deut" "Josh" "Judg" "Ruth"
    "1Sam" "2Sam" "1Kgs" "2Kgs" "1Chr" "2Chr" "Ezra" "Neh"
    "Tob" "Jdt" "Esth" "1Macc" "2Macc" "Job" "Ps" "Prov"
    "Eccl" "Song" "Wis" "Sir" "Is" "Isa" "Jer" "Lam" "Bar"
    "Ezek" "Dan" "Hos" "Joel" "Amos" "Obad" "Jon" "Mic"
    "Nah" "Hab" "Zeph" "Hag" "Zech" "Mal"
    "Matt" "Mark" "Luke" "John" "Acts" "Rom"
    "1Cor" "2Cor" "Gal" "Eph" "Phil" "Col"
    "1Thess" "2Thess" "1Tim" "2Tim" "Tit" "Phlm"
    "Heb" "Jas" "1Pet" "2Pet" "1John" "2John" "3John"
    "Jude" "Rev")
  "Biblical book abbreviations used in Divinum Officium citation lines.")

(defconst bcp-officium--book-rx
  (concat "\\(?:" (regexp-opt bcp-officium--biblical-books) "\\)")
  "Regexp matching any recognized biblical book abbreviation (no word boundary).")

;;;; ── File parser ──────────────────────────────────────────────────────────────
;;
;; A DO file is a sequence of sections.  Each section begins with a header line:
;;
;;   [SectionName]
;;   [SectionName] (rubrica Tridentina)   ← non-DA variant; skip
;;   [SectionName](rubrica 1960)          ← non-DA variant; skip (no space)
;;
;; Everything between one header and the next is the section body.
;; We keep only DA sections (headers without a rubrica qualifier).

(defun bcp-officium--parse-file (path)
  "Parse a DO file at PATH.
Returns an alist of (SECTION-KEY . BODY-TEXT) for DA sections only.
SECTION-KEY is the bare name inside the brackets.
BODY-TEXT is the body with leading/trailing blank lines stripped."
  (with-temp-buffer
    (insert-file-contents path)
    (let ((sections '())
          (current-key nil)
          (current-lines '())
          (da-current t))              ; is the current section DA?
      (goto-char (point-min))
      (while (not (eobp))
        (let ((line (buffer-substring-no-properties
                     (line-beginning-position) (line-end-position))))
          (if (string-match "^\\[\\([^]]+\\)\\]\\(.*\\)$" line)
              ;; Section header
              (let* ((key (match-string 1 line))
                     (rest (match-string 2 line))
                     (rubrica-p (string-match-p "(rubrica" rest)))
                (when (and current-key da-current)
                  (push (cons current-key
                               (string-trim
                                (string-join (nreverse current-lines) "\n")))
                        sections))
                (setq current-key key
                      current-lines '()
                      da-current (not rubrica-p)))
            ;; Body line
            (push line current-lines)))
        (forward-line 1))
      ;; Flush final section
      (when (and current-key da-current)
        (push (cons current-key
                     (string-trim
                      (string-join (nreverse current-lines) "\n")))
              sections))
      (nreverse sections))))

;;;; ── File cache ───────────────────────────────────────────────────────────────

(defvar bcp-officium--file-cache (make-hash-table :test #'equal)
  "Cache: absolute file path → parsed DA sections alist.
Reset via `bcp-officium--clear-cache' before each import run.")

(defun bcp-officium--clear-cache ()
  "Clear the parsed-file cache."
  (clrhash bcp-officium--file-cache))

(defun bcp-officium--get-sections (full-path)
  "Return parsed DA sections alist for FULL-PATH, using cache."
  (or (gethash full-path bcp-officium--file-cache)
      (when (file-readable-p full-path)
        (let ((sections (bcp-officium--parse-file full-path)))
          (puthash full-path sections bcp-officium--file-cache)
          sections))))

(defun bcp-officium--resolve-file-path (file-part do-root)
  "Expand a cross-file reference FILE-PART to an absolute path.
FILE-PART is like \"Tempora/Adv1-1\" or \"Sancti/03-25\" (no extension).
These paths are relative to the English horas base."
  (expand-file-name (concat file-part ".txt")
                    (expand-file-name bcp-officium--english-base do-root)))

;;;; ── @ reference resolver ─────────────────────────────────────────────────────
;;
;; Reference syntax (after stripping the leading @):
;;
;;   file:section              cross-file, whole section
;;   file:section:extra        cross-file, with modifier
;;   :section                  self-reference (same file)
;;   :section:extra            self-reference with modifier
;;   file::extra               cross-file, same section name as context
;;
;; where 'extra' is one of:
;;
;;   N-M                       extract lines N through M (1-based)
;;   N-M:s/pat/rep/[flags]     extract lines N-M, then apply sed
;;   N-M append-text           extract lines N-M, then append literal text
;;   N                         extract single line N
;;   s/pat/rep/[flags]         global substitution
;;   N s/pat/rep/[flags]       substitution on line N only
;;   s/p1/r1/ s/p2/r2/ ...     multiple substitutions applied in sequence
;;
;; flags: s = dotall (. matches \n), m = multiline (^ and $ per line)

(defun bcp-officium--parse-ref (ref)
  "Split REF (no leading @) into (FILE-PART SECTION-PART EXTRA-OR-NIL).
Splits only on the first two colons, so extra may itself contain colons."
  (let* ((c1 (string-match ":" ref))
         (file (if c1 (substring ref 0 c1) ref))
         (tail (if c1 (substring ref (1+ c1)) ""))
         (c2 (string-match ":" tail))
         (section (if c2 (substring tail 0 c2) tail))
         (extra (when c2 (substring tail (1+ c2)))))
    (list file section extra)))

(defun bcp-officium--preprocess-rep (rep)
  "Convert a DO sed replacement string REP for use with `replace-regexp-in-string'.
Translates DO escape conventions to Emacs replacement conventions:
  \\n          → actual newline character
  \\u          → dropped (TODO: proper capitalise-next-char)
  $N  or \\N   → \\N  (Emacs capture-group back-reference; N = 1-9)
Everything else passes through unchanged."
  ;; Work at the character level to avoid cascading substitution issues.
  (with-temp-buffer
    (insert rep)
    (goto-char (point-min))
    (while (not (eobp))
      (if (not (= (char-after) ?\\))
          (forward-char 1)
        ;; Current char is backslash; look at the next char.
        (let ((next (char-after (1+ (point)))))
          (cond
           ;; \n → newline
           ((eq next ?n)
            (delete-char 2)
            (insert "\n"))
           ;; \u → drop (skip both chars)
           ((eq next ?u)
            (delete-char 2))
           ;; \1..\9 — already correct for Emacs; skip past both chars
           ((and next (>= next ?1) (<= next ?9))
            (forward-char 2))
           ;; \\ → keep as-is (Emacs literal-backslash escape); skip both
           ((eq next ?\\)
            (forward-char 2))
           ;; Unknown \X — drop the backslash, leave X
           (t
            (delete-char 1))))))
    ;; Convert $N → \N (backslash + digit) for Emacs group refs.
    (goto-char (point-min))
    (while (re-search-forward "\\$\\([1-9]\\)" nil t)
      (let ((digit (match-string 1)))
        (replace-match (concat "\\" digit) t t)))
    (buffer-string)))

(defun bcp-officium--apply-sed-command (text cmd)
  "Apply a single sed-style command CMD to TEXT.
CMD is of one of these forms:
  s/pat/rep/[flags]      — global substitute
  N s/pat/rep/[flags]    — substitute on line N only (1-based)
Flags (s, m, g, i) are accepted but ignored; Emacs regexps use multiline
anchoring by default."
  (let ((cmd (string-trim cmd)))
    (cond
     ;; Line-specific: "N s/pat/rep/[flags]"
     ((string-match "^\\([0-9]+\\) s/\\(.*\\)/\\([^/]*\\)/[smgi]*$" cmd)
      (let* ((n      (string-to-number (match-string 1 cmd)))
             (pat    (match-string 2 cmd))
             (rep    (bcp-officium--preprocess-rep (match-string 3 cmd)))
             (lines  (split-string text "\n" nil))
             (target (nth (1- n) lines)))
        (when target
          (setf (nth (1- n) lines)
                (replace-regexp-in-string pat rep target)))
        (string-join lines "\n")))
     ;; Global: "s/pat/rep/[flags]"
     ((string-match "^s/\\(.*\\)/\\([^/]*\\)/[smgi]*$" cmd)
      (replace-regexp-in-string
       (match-string 1 cmd)
       (bcp-officium--preprocess-rep (match-string 2 cmd))
       text))
     (t text))))

(defun bcp-officium--apply-extra (text extra context-section)
  "Apply EXTRA modifier to TEXT; return modified text.
CONTEXT-SECTION is the key of the enclosing section (used only for logging).
Returns TEXT unchanged when EXTRA is nil or empty."
  (if (or (null extra) (string-empty-p extra))
      text
    (cond
     ;; Line range: "N-M" optionally followed by ":sed-cmd" or " append-text"
     ((string-match "^\\([0-9]+\\)-\\([0-9]+\\)\\(.*\\)$" extra)
      (let* ((m    (string-to-number (match-string 1 extra)))
             (n    (string-to-number (match-string 2 extra)))
             (rest (match-string 3 extra))
             (lines (split-string text "\n" nil))
             (count (length lines))
             (slice (cl-subseq lines (1- (min m count)) (min n count)))
             (sliced (string-join slice "\n")))
        (cond
         ;; ":sed-cmd" after range
         ((string-match "^:\\(s/.*\\)$" rest)
          (bcp-officium--apply-extra sliced (match-string 1 rest)
                                     context-section))
         ;; " append-text" after range
         ((string-match "^[ \t]\\(.*\\)$" rest)
          (let ((appended (match-string 1 rest)))
            (if (string-empty-p appended)
                sliced
              (concat sliced "\n" appended))))
         (t sliced))))
     ;; Single line: "N" (digits only)
     ((string-match "^\\([0-9]+\\)$" extra)
      (let* ((n     (string-to-number (match-string 1 extra)))
             (lines (split-string text "\n" nil)))
        (or (nth (1- n) lines) "")))
     ;; One or more sed commands — parse them with the character-level reader
     (t
      (let ((result text))
        (dolist (cmd (bcp-officium--read-sed-commands extra) result)
          (setq result (bcp-officium--apply-sed-command result cmd))))))))

(defun bcp-officium--read-sed-commands (str)
  "Parse STR into a list of sed command strings.
Handles multiple space-separated commands; tracks delimiter balance so
that `/` inside patterns and replacements is not mistaken for a boundary.
Understands escaped delimiters (\\/) and the optional `N ' line prefix."
  (let ((pos 0)
        (len (length str))
        (cmds '()))
    (while (< pos len)
      ;; Skip whitespace
      (while (and (< pos len) (memq (aref str pos) '(?\s ?\t)))
        (cl-incf pos))
      (when (< pos len)
        (let ((cmd-start pos))
          ;; Optional line-number prefix: "N "
          (when (and (< pos len) (<= ?0 (aref str pos) ?9))
            (let ((numstart pos))
              (while (and (< pos len) (<= ?0 (aref str pos) ?9))
                (cl-incf pos))
              ;; Only a real prefix if followed by space then "s"
              (if (and (< (1+ pos) len)
                       (= (aref str pos) ?\s)
                       (= (aref str (1+ pos)) ?s))
                  (cl-incf pos)   ; consume the space
                (setq pos numstart))))  ; not a line prefix — reset
          ;; Must be "s" followed by a delimiter character
          (when (and (< pos len) (= (aref str pos) ?s)
                     (< (1+ pos) len))
            (cl-incf pos)
            (let ((delim (aref str pos)))
              (cl-incf pos)
              ;; Read two delimited fields (pattern, replacement)
              (dotimes (_ 2)
                (while (and (< pos len) (/= (aref str pos) delim))
                  (when (and (= (aref str pos) ?\\) (< (1+ pos) len))
                    (cl-incf pos))    ; skip escaped char
                  (cl-incf pos))
                (when (< pos len) (cl-incf pos)))  ; consume closing delimiter
              ;; Read optional flags
              (while (and (< pos len) (memq (aref str pos) '(?s ?m ?g ?i)))
                (cl-incf pos))
              (push (substring str cmd-start pos) cmds))))))
    (nreverse cmds)))

(defun bcp-officium--resolve-ref-line
    (line current-key self-path self-sections do-root depth)
  "Resolve a single @ reference LINE; return the resolved text string.
CURRENT-KEY is the section key in whose body LINE appears (for empty-section refs).
SELF-PATH and SELF-SECTIONS describe the containing file.
DO-ROOT is the DO checkout root.
DEPTH guards against runaway recursion."
  (if (> depth 8)
      (progn
        (message "bcp-officium: ref depth exceeded in %s [%s]: %s"
                 (file-name-nondirectory self-path) current-key line)
        line)
  (let* ((ref (if (string-prefix-p "@" line) (substring line 1) line))
         (parsed (bcp-officium--parse-ref ref))
         (file-part    (car parsed))
         (section-part (cadr parsed))
         (extra        (caddr parsed))
         ;; Empty section = same section as the enclosing context
         (effective-section (if (string-empty-p (or section-part ""))
                                current-key
                              section-part))
         ;; Empty file = self-reference
         (sections (if (string-empty-p file-part)
                       self-sections
                     (let ((full (bcp-officium--resolve-file-path
                                   file-part do-root)))
                       (bcp-officium--get-sections full))))
         (raw-text (cdr (assoc effective-section sections))))
    (if raw-text
        ;; Recursively resolve any @ refs within the fetched text, then
        ;; apply any extra modifier.
        (let ((resolved
               (bcp-officium--resolve-section-text
                effective-section raw-text
                (if (string-empty-p file-part)
                    self-path
                  (bcp-officium--resolve-file-path file-part do-root))
                sections do-root (1+ depth))))
          (bcp-officium--apply-extra resolved extra effective-section))
      ;; Section not found — return the original line unchanged
      (progn
        (message "bcp-officium: unresolved ref in %s [%s]: %s"
                 self-path current-key line)
        line)))))

(defun bcp-officium--resolve-section-text
    (key text self-path self-sections do-root depth)
  "Return TEXT with all @ ref lines resolved.
KEY is the section key; used when a ref uses an empty section name.
SELF-PATH and SELF-SECTIONS identify the containing file.
DO-ROOT is the DO checkout root.
DEPTH is the current recursion depth."
  (let ((lines (split-string text "\n")))
    (string-join
     (mapcar
      (lambda (line)
        (if (string-match-p "^@" line)
            (bcp-officium--resolve-ref-line
             line key self-path self-sections do-root depth)
          line))
      lines)
     "\n")))

;;;; ── Scripture citation detection ────────────────────────────────────────────
;;
;; Scriptural lectiones contain a line starting with "!" followed by a
;; recognized book abbreviation and a chapter:verse citation, e.g.:
;;   !Isa 1:16-18
;;   !Matt 5:1-12
;;
;; Patristic or homily lectiones may contain free-form "!Source" lines
;; (not matching a known book) or no "!" at all.
;;
;; Mixed lectiones interleave a scripture pericope, a "_" separator line,
;; and a homily.  For these we extract only the citation and ignore the homily.

(defun bcp-officium--find-scripture-citation (text)
  "Return the citation string if TEXT contains a scripture marker, else nil.
The citation is the content of the first '!Book Ch:Vv' line, stripped of '!'."
  (cl-dolist (line (split-string text "\n"))
    (when (string-match
           (concat "^!" bcp-officium--book-rx "[ \t]+[0-9]")
           line)
      (cl-return (substring line 1)))))    ; strip leading !

(defun bcp-officium--classify-lectio (text)
  "Classify a lectio TEXT as a plist.
Scripture:  (:type scripture :citation \"Isa 1:16-18\")
Patristic:  (:type text     :body    TEXT)"
  (let ((citation (bcp-officium--find-scripture-citation text)))
    (if citation
        (list :type 'scripture :citation (string-trim citation))
      (list :type 'text :body (string-trim text)))))

;;;; ── Section key classifiers ─────────────────────────────────────────────────

(defun bcp-officium--lectio-index (key)
  "Return the integer lectio index from KEY, or nil.
Handles \"Lectio1\" through \"Lectio9\" and \"Lectio1a\", \"Lectio8a\", etc."
  (when (string-match "^Lectio\\([0-9]+\\)" key)
    (string-to-number (match-string 1 key))))

(defun bcp-officium--nocturn (index)
  "Return the Matutinum nocturn (1–3) for lectio INDEX (1–9)."
  (cond ((<= index 3) 1)
        ((<= index 6) 2)
        (t 3)))

;;;; ── Day record assembly ──────────────────────────────────────────────────────

(defun bcp-officium--build-day-record (name sections self-path do-root)
  "Build a day record plist from resolved SECTIONS for a file named NAME.
SELF-PATH is the absolute path of the source file.
DO-ROOT is the DO checkout root."
  (let* (;; Resolve all @ refs in every section
         (resolved
          (mapcar
           (lambda (pair)
             (cons (car pair)
                   (bcp-officium--resolve-section-text
                    (car pair) (cdr pair) self-path sections do-root 0)))
           sections))
         ;; Title from [Officium] section
         (title (string-trim (or (cdr (assoc "Officium" resolved)) "")))
         ;; Collect and classify lectiones
         (lectiones
          (cl-loop
           for (key . text) in resolved
           for idx = (bcp-officium--lectio-index key)
           when idx
           collect (append
                    (list :key     key
                          :nocturn (bcp-officium--nocturn idx)
                          :index   idx)
                    (bcp-officium--classify-lectio text)))))
    (when (or title lectiones)
      (list :day name
            :title title
            :lectiones lectiones))))

;;;; ── Top-level importer ───────────────────────────────────────────────────────

;;;###autoload
(defun bcp-officium-import-tempora (do-root output-dir)
  "Import English Tempora lectiones from DO-ROOT; write data to OUTPUT-DIR.

DO-ROOT is the path to a Divinum Officium git checkout.
OUTPUT-DIR is the directory to write `bcp-officium-tempora-data.el' into.

Only base '.txt' files are processed; 'o.txt' override variants are skipped.
Only DA sections (no rubrica qualifier) are imported.
All @ cross-references are resolved at import time — no DO source is needed
at runtime."
  (interactive
   (list (read-directory-name "Divinum Officium checkout: ")
         (read-directory-name "Output directory: " bcp--package-directory)))
  (bcp-officium--clear-cache)
  (let* ((tempora-dir (expand-file-name
                        (concat bcp-officium--english-base "/"
                                bcp-officium--tempora-subdir)
                        do-root))
         ;; Base files only: no 'o' suffix, .txt extension
         (files (cl-remove-if
                  (lambda (f) (string-suffix-p "o.txt" f))
                  (directory-files tempora-dir t "\\.txt\\'")))
         (all-records '())
         (skipped 0))
    (dolist (path files)
      (let* ((name     (file-name-base path))
             (sections (bcp-officium--get-sections path))
             (record   (bcp-officium--build-day-record
                         name sections path do-root)))
        (if record
            (push record all-records)
          (cl-incf skipped))))
    (let* ((records    (nreverse all-records))
           (count      (length records))
           (output-path (expand-file-name "bcp-officium-tempora-data.el"
                                           output-dir)))
      (with-temp-file output-path
        (insert ";;; bcp-officium-tempora-data.el")
        (insert " --- Generated DO Tempora data -*- lexical-binding: t -*-\n")
        (insert ";; Generated by bcp-fetcher-officium.el — do not edit by hand.\n")
        (insert ";; Source: Divinum Officium (English, DA rubric, Tempora only).\n\n")
        (insert "(defconst bcp-officium-tempora-data\n  '")
        (let ((print-level nil)
              (print-length nil))
          (prin1 records (current-buffer)))
        (insert "\n  \"Resolved Tempora lectio data imported from Divinum Officium.\n")
        (insert "Each element: (:day NAME :title TITLE :lectiones LECTIONES).\n")
        (insert "Each lectio: (:key KEY :nocturn N :index I :type TYPE ...) where\n")
        (insert "  TYPE `scripture' adds :citation STRING;\n")
        (insert "  TYPE `text' adds :body STRING.\")\n\n")
        (insert "(provide 'bcp-officium-tempora-data)\n")
        (insert ";;; bcp-officium-tempora-data.el ends here\n"))
      (message "bcp-officium: wrote %d day records (%d skipped) to %s"
               count skipped output-path)
      output-path)))

(provide 'bcp-fetcher-officium)
;;; bcp-fetcher-officium.el ends here
