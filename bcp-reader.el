;;; bcp-reader.el --- Bible reader, study environment and commentary with org-roam backlinks -*- lexical-binding: t -*-

;; Author: You
;; Version: 0.2.0
;; Package-Requires: ((emacs "28.1") (org "9.6") (org-roam "2.2"))
;; Keywords: bible, commentary, theology, org, org-roam
;; URL: https://github.com/yourname/bible-commentary

;;; Commentary:

;; bible-commentary.el provides a two-buffer environment for writing
;; Bible commentary, backed by org-roam for automatic cross-reference
;; backlinks and org-capture for quick marginal notes.
;;
;; Core features:
;;   - Side-by-side Bible text and org commentary buffers, synchronised scroll
;;   - Default translation: KJVA (KJV with Apocrypha), covering Protestant
;;     and Catholic deuterocanonical books in traditional KJV language.
;;     Psalms 1-150 default to BCP Coverdale Psalter.
;;     Orthodox-only books (Ps 151, 1-2 Esdras, etc.) fall back to NRSV.
;;   - Full canonical Bible: Protestant + Catholic deuterocanon + Orthodox books
;;   - Load a local plain-text Bible or fetch any passage from Oremus
;;   - Each verse heading is an org-roam node; cross-references create backlinks
;;   - `bible-commentary-backlinks' shows every note linking to the current verse
;;     — the key feature for surfacing NT quotations of OT passages and vice versa
;;   - org-capture template for quick marginal notes filed under the verse node
;;   - Navigate by verse/chapter; export to HTML or PDF
;;
;; Quick start:
;;
;;   (require 'bcp-reader)
;;   (bible-commentary-open)
;;
;; Recommended binding:
;;   (global-set-key (kbd "C-c B") #'bible-commentary)
;;
;; See README.org for full documentation.

;;; Code:

(require 'org)
(require 'org-capture)
(require 'ox)
(require 'url)
(require 'cl-lib)
(require 'bcp-fetcher)
(require 'bcp-fetcher)

;; org-roam is optional; every call guards with `bible-commentary--roam-p'.
(declare-function org-roam-buffer-display-dedicated "org-roam-buffer")
(declare-function org-roam-db-autosync-mode         "org-roam")
(declare-function org-roam-node-at-point            "org-roam-node")
(declare-function org-id-get-create                 "org-id")
(declare-function org-id-get                        "org-id")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Customisation

(defgroup bible-commentary nil
  "Bible commentary environment."
  :group 'applications
  :prefix "bible-commentary-")

(defcustom bible-commentary-file
  (expand-file-name "~/bible-commentary.org")
  "Path to the master org commentary file."
  :type 'file)

(defcustom bible-commentary-bible-file nil
  "Path to a local plain-text Bible (KJVA recommended).
If nil, Oremus is used for individual passage fetches."
  :type '(choice file (const nil)))

(defcustom bible-commentary-coverdale-file nil
  "Path to a local plain-text BCP Coverdale Psalter.
Loaded automatically for Psalms unless the user has called
`bible-commentary-set-translation' this session."
  :type '(choice file (const nil)))


(defcustom bible-commentary-window-layout 'side-by-side
  "Window layout: `side-by-side' (default) or `top-bottom'."
  :type '(choice (const side-by-side) (const top-bottom)))

(defcustom bible-commentary-sync-scroll t
  "Non-nil: scrolling either buffer proportionally scrolls the other."
  :type 'boolean)

(defcustom bible-commentary-use-roam t
  "Non-nil: use org-roam nodes and backlinks when org-roam is loaded."
  :type 'boolean)

(defcustom bible-commentary-capture-key "B"
  "Key used in `org-capture-templates' for quick marginal notes."
  :type 'string)

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Internal state

(defvar bible-commentary--bible-buffer nil
  "Buffer showing the Bible text.")
(defvar bible-commentary--commentary-buffer nil
  "Org buffer for commentary.")
(defvar bible-commentary--current-verse nil
  "Current verse plist: (:book :chapter :verse-start :verse-end).")

(defvar bible-commentary--inhibit-scroll nil
  "Non-nil while a scroll-sync is running, prevents recursion.")

(defvar bible-commentary--session-scheme nil
  "Psalm numbering scheme override for this session.
Either \='mt, \='vg, or nil (auto-detect from active translation).
Set via `bible-commentary-set-scheme'.")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Book alias table — Protestant + Catholic deuterocanon + Orthodox books

(defconst bible-commentary--book-aliases
  '(;;──── Old Testament ──────────────────────────────────────────────────
    ("gen"        . "Genesis")
    ("exod"       . "Exodus")          ("ex"         . "Exodus")
    ("lev"        . "Leviticus")
    ("num"        . "Numbers")         ("nu"         . "Numbers")
    ("deut"       . "Deuteronomy")     ("dt"         . "Deuteronomy")
    ("josh"       . "Joshua")          ("jos"        . "Joshua")
    ("judg"       . "Judges")          ("jdg"        . "Judges")
    ("ruth"       . "Ruth")
    ("1sam"       . "1 Samuel")        ("1sa"        . "1 Samuel")
    ("2sam"       . "2 Samuel")        ("2sa"        . "2 Samuel")
    ("1kgs"       . "1 Kings")         ("1ki"        . "1 Kings")
    ("2kgs"       . "2 Kings")         ("2ki"        . "2 Kings")
    ("1chr"       . "1 Chronicles")    ("1ch"        . "1 Chronicles")
    ("2chr"       . "2 Chronicles")    ("2ch"        . "2 Chronicles")
    ("ezra"       . "Ezra")
    ("neh"        . "Nehemiah")
    ("esth"       . "Esther")
    ("job"        . "Job")
    ("ps"         . "Psalms")          ("pss"        . "Psalms")
    ("psalm"      . "Psalms")          ("psalms"     . "Psalms")
    ("prov"       . "Proverbs")        ("pr"         . "Proverbs")
    ("eccl"       . "Ecclesiastes")    ("qoh"        . "Ecclesiastes")
    ("song"       . "Song of Solomon") ("sos"        . "Song of Solomon")
    ("cant"       . "Song of Solomon")
    ("isa"        . "Isaiah")
    ("jer"        . "Jeremiah")
    ("lam"        . "Lamentations")
    ("ezek"       . "Ezekiel")         ("eze"        . "Ezekiel")
    ("dan"        . "Daniel")
    ("hos"        . "Hosea")
    ("joel"       . "Joel")
    ("amos"       . "Amos")
    ("obad"       . "Obadiah")         ("ob"         . "Obadiah")
    ("jonah"      . "Jonah")           ("jon"        . "Jonah")
    ("mic"        . "Micah")
    ("nah"        . "Nahum")
    ("hab"        . "Habakkuk")
    ("zeph"       . "Zephaniah")       ("zep"        . "Zephaniah")
    ("hag"        . "Haggai")
    ("zech"       . "Zechariah")       ("zec"        . "Zechariah")
    ("mal"        . "Malachi")
    ;;──── New Testament ──────────────────────────────────────────────────
    ("matt"       . "Matthew")         ("mt"         . "Matthew")
    ("mark"       . "Mark")            ("mk"         . "Mark")
    ("luke"       . "Luke")            ("lk"         . "Luke")
    ("john"       . "John")            ("jn"         . "John")
    ("acts"       . "Acts")
    ("rom"        . "Romans")
    ("1cor"       . "1 Corinthians")   ("1co"        . "1 Corinthians")
    ("2cor"       . "2 Corinthians")   ("2co"        . "2 Corinthians")
    ("gal"        . "Galatians")
    ("eph"        . "Ephesians")
    ("phil"       . "Philippians")     ("php"        . "Philippians")
    ("col"        . "Colossians")
    ("1thess"     . "1 Thessalonians") ("1th"        . "1 Thessalonians")
    ("2thess"     . "2 Thessalonians") ("2th"        . "2 Thessalonians")
    ("1tim"       . "1 Timothy")       ("1ti"        . "1 Timothy")
    ("2tim"       . "2 Timothy")       ("2ti"        . "2 Timothy")
    ("titus"      . "Titus")           ("tit"        . "Titus")
    ("phlm"       . "Philemon")        ("phm"        . "Philemon")
    ("heb"        . "Hebrews")
    ("jas"        . "James")
    ("1pet"       . "1 Peter")         ("1pe"        . "1 Peter")
    ("2pet"       . "2 Peter")         ("2pe"        . "2 Peter")
    ("1john"      . "1 John")          ("1jn"        . "1 John")
    ("2john"      . "2 John")          ("2jn"        . "2 John")
    ("3john"      . "3 John")          ("3jn"        . "3 John")
    ("jude"       . "Jude")
    ("rev"        . "Revelation")      ("apoc"       . "Revelation")
    ;;──── Catholic Deuterocanon ───────────────────────────────────────────
    ("tob"        . "Tobit")           ("tobit"      . "Tobit")
    ("jdt"        . "Judith")          ("judith"     . "Judith")
    ("1macc"      . "1 Maccabees")     ("1mac"       . "1 Maccabees")
    ("2macc"      . "2 Maccabees")     ("2mac"       . "2 Maccabees")
    ("wis"        . "Wisdom of Solomon") ("wisdom"   . "Wisdom of Solomon")
    ("sir"        . "Sirach")          ("ecclus"     . "Sirach")
    ("ben sira"   . "Sirach")
    ("bar"        . "Baruch")
    ;; Additions to Daniel
    ("pr azar"    . "Prayer of Azariah")
    ("prayer of azariah" . "Prayer of Azariah")
    ("sg3"        . "Song of the Three Young Men")
    ("sus"        . "Susanna")
    ("bel"        . "Bel and the Dragon")
    ;; Additions to Esther
    ("add esth"   . "Additions to Esther")
    ("addesth"    . "Additions to Esther")
    ;; Letter of Jeremiah (= Baruch ch. 6 in some canons)
    ("ep jer"     . "Letter of Jeremiah")
    ("ljer"       . "Letter of Jeremiah")
    ;;──── Additional Orthodox books ──────────────────────────────────────
    ("1esd"       . "1 Esdras")        ("1esdr"      . "1 Esdras")
    ;; 2 Esdras = 4 Ezra in the Vulgate tradition
    ("2esd"       . "2 Esdras")        ("2esdr"      . "2 Esdras")
    ("4ezra"      . "2 Esdras")        ("4 ezra"     . "2 Esdras")
    ("pr man"     . "Prayer of Manasseh")
    ("prman"      . "Prayer of Manasseh")
    ("prayer of manasseh" . "Prayer of Manasseh")
    ("ps151"      . "Psalm 151")       ("psalm 151"  . "Psalm 151")
    ("3macc"      . "3 Maccabees")     ("3mac"       . "3 Maccabees")
    ("4macc"      . "4 Maccabees")     ("4mac"       . "4 Maccabees"))
  "Alist of (abbreviation . canonical-name) for the full ecumenical corpus.")

(defconst bible-commentary--protestant-books
  '("Genesis" "Exodus" "Leviticus" "Numbers" "Deuteronomy" "Joshua" "Judges"
    "Ruth" "1 Samuel" "2 Samuel" "1 Kings" "2 Kings" "1 Chronicles" "2 Chronicles"
    "Ezra" "Nehemiah" "Esther" "Job" "Psalms" "Proverbs" "Ecclesiastes"
    "Song of Solomon" "Isaiah" "Jeremiah" "Lamentations" "Ezekiel" "Daniel"
    "Hosea" "Joel" "Amos" "Obadiah" "Jonah" "Micah" "Nahum" "Habakkuk"
    "Zephaniah" "Haggai" "Zechariah" "Malachi"
    "Matthew" "Mark" "Luke" "John" "Acts" "Romans"
    "1 Corinthians" "2 Corinthians" "Galatians" "Ephesians" "Philippians"
    "Colossians" "1 Thessalonians" "2 Thessalonians" "1 Timothy" "2 Timothy"
    "Titus" "Philemon" "Hebrews" "James" "1 Peter" "2 Peter"
    "1 John" "2 John" "3 John" "Jude" "Revelation")
  "Books present in the KJV Protestant canon.")

(defconst bible-commentary--catholic-deuterocanon
  '("Tobit" "Judith" "1 Maccabees" "2 Maccabees" "Wisdom of Solomon" "Sirach"
    "Baruch" "Letter of Jeremiah" "Prayer of Azariah"
    "Song of the Three Young Men" "Susanna" "Bel and the Dragon"
    "Additions to Esther")
  "Books in the Catholic deuterocanon; absent from KJV.")

(defconst bible-commentary--orthodox-books
  '("1 Esdras" "2 Esdras" "Prayer of Manasseh" "Psalm 151"
    "3 Maccabees" "4 Maccabees")
  "Books in Orthodox canons but absent from standard Protestant editions.")

(defconst bible-commentary--kjv-apocrypha-books
  '("1 Esdras" "2 Esdras" "Prayer of Manasseh")
  "Orthodox books that ARE present in the 1611 KJV Apocrypha.
Oremus serves these under the AV code.  They are a subset of
`bible-commentary--orthodox-books'.")


(defun bible-commentary--psalm-display-string (ref &optional scheme)
  "Return a display string for REF using singular \"Psalm N\" for psalm headings.
Under Vg SCHEME, shows the Vg number with MT equivalent in parentheses.
Under MT scheme, shows the MT number with Vg equivalent in parentheses.
Uses the liturgically natural singular \"Psalm\" rather than \"Psalms\"."
  (if (bible-commentary--psalm-p ref)
      (let* ((ch     (plist-get ref :chapter))
             (vs     (plist-get ref :verse-start))
             (ve     (plist-get ref :verse-end))
             (tr     (bcp-fetcher-active-translation ref))
             (scheme (or scheme (bible-commentary--active-scheme tr)))
             (ann    (bible-commentary--psalm-header-annotation ref scheme))
             (verse-suffix
              (cond ((and vs ve (not (= vs ve))) (format ":%d-%d" vs ve))
                    (vs                           (format ":%d" vs))
                    (t                             ""))))
        (format "Psalm %d%s%s" ch verse-suffix (or ann "")))
    (bible-commentary--ref-to-string ref)))

(defun bible-commentary--psalm-header-annotation (ref &optional scheme)
  "Return concise cross-scheme annotation for REF, or nil if both agree.

Under MT scheme (default): shows Vg equivalent, e.g. \" (Vg 22)\".
Under Vg scheme: shows MT equivalent(s), e.g. \" (MT 9 & 10)\"."
  (when (and (bible-commentary--psalm-p ref)
             (plist-get ref :chapter))
    (let* ((ch     (plist-get ref :chapter))
           (tr     (bcp-fetcher-active-translation ref))
           (scheme (or scheme (bible-commentary--active-scheme tr))))
      (if (eq scheme 'vg)
          ;; Vg number → show MT equivalent(s)
          (let* ((units   (bible-commentary--psalm-canonical-units ref 'vg))
                 (mt-nums (mapcar #'bible-commentary--unit-to-mt units))
                 (mt-nums (cl-remove-duplicates mt-nums)))
            (if (equal mt-nums (list ch))
                nil   ; same number — no annotation
              (format " (MT %s)"
                      (mapconcat #'number-to-string mt-nums " & "))))
        ;; MT number → show Vg equivalent (existing logic)
        (let ((ann (bible-commentary--psalm-numbering-annotation ch)))
          (when ann (format " (%s)" ann)))))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Textual status: omitted and disputed verses in critical text editions

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Reference validation: chapter bounds for the full ecumenical canon

(defconst bible-commentary--chapter-counts
  '(;; Old Testament
    ("Genesis" . 50)          ("Exodus" . 40)          ("Leviticus" . 27)
    ("Numbers" . 36)          ("Deuteronomy" . 34)      ("Joshua" . 24)
    ("Judges" . 21)           ("Ruth" . 4)              ("1 Samuel" . 31)
    ("2 Samuel" . 24)         ("1 Kings" . 22)          ("2 Kings" . 25)
    ("1 Chronicles" . 29)     ("2 Chronicles" . 36)     ("Ezra" . 10)
    ("Nehemiah" . 13)         ("Esther" . 10)           ("Job" . 42)
    ("Psalms" . 150)          ("Proverbs" . 31)         ("Ecclesiastes" . 12)
    ("Song of Solomon" . 8)   ("Isaiah" . 66)           ("Jeremiah" . 52)
    ("Lamentations" . 5)      ("Ezekiel" . 48)          ("Daniel" . 12)
    ("Hosea" . 14)            ("Joel" . 3)              ("Amos" . 9)
    ("Obadiah" . 1)           ("Jonah" . 4)             ("Micah" . 7)
    ("Nahum" . 3)             ("Habakkuk" . 3)          ("Zephaniah" . 3)
    ("Haggai" . 2)            ("Zechariah" . 14)        ("Malachi" . 4)
    ;; New Testament
    ("Matthew" . 28)          ("Mark" . 16)             ("Luke" . 24)
    ("John" . 21)             ("Acts" . 28)             ("Romans" . 16)
    ("1 Corinthians" . 16)    ("2 Corinthians" . 13)    ("Galatians" . 6)
    ("Ephesians" . 6)         ("Philippians" . 4)       ("Colossians" . 4)
    ("1 Thessalonians" . 5)   ("2 Thessalonians" . 3)   ("1 Timothy" . 6)
    ("2 Timothy" . 4)         ("Titus" . 3)             ("Philemon" . 1)
    ("Hebrews" . 13)          ("James" . 5)             ("1 Peter" . 5)
    ("2 Peter" . 3)           ("1 John" . 5)            ("2 John" . 1)
    ("3 John" . 1)            ("Jude" . 1)              ("Revelation" . 22)
    ;; Catholic deuterocanon
    ("Tobit" . 14)            ("Judith" . 16)           ("1 Maccabees" . 16)
    ("2 Maccabees" . 15)      ("Wisdom of Solomon" . 19) ("Sirach" . 51)
    ("Baruch" . 6)            ("Letter of Jeremiah" . 1) ("Prayer of Azariah" . 1)
    ("Song of the Three Young Men" . 1) ("Susanna" . 1) ("Bel and the Dragon" . 1)
    ("Additions to Esther" . 7)
    ;; Orthodox books
    ("1 Esdras" . 9)          ("2 Esdras" . 16)         ("Prayer of Manasseh" . 1)
    ("Psalm 151" . 1)         ("3 Maccabees" . 7)       ("4 Maccabees" . 18))
  "Alist of (book-name . chapter-count) for the full ecumenical canon.")

(defun bible-commentary--validate-ref (ref)
  "Validate REF against known chapter bounds.
Returns nil if REF is valid, or a human-readable error string if not.

Validates:
  - Book name is recognised (already guaranteed by parse-reference, but
    checked here as a safety net)
  - Chapter number, if present, is within the book's chapter count
  - Verse number, if present, is not implausibly large (> 200)

Does NOT validate per-chapter verse counts — that would require a large
lookup table and Oremus will report gracefully for out-of-range verses."
  (let* ((book (plist-get ref :book))
         (ch   (plist-get ref :chapter))
         (vs   (plist-get ref :verse-start))
         (max-ch (cdr (assoc book bible-commentary--chapter-counts))))
    (cond
     ;; Book not in our table (shouldn't happen after parse-reference, but
     ;; guards against future alias additions without corresponding counts)
     ((null max-ch)
      (format "'%s' is not a recognised book of the Bible" book))
     ;; Chapter out of range
     ((and ch (< ch 1))
      (format "%s has no chapter 0 or below" book))
     ((and ch (> ch max-ch))
      (format "%s has %d chapter%s (chapter %d does not exist)"
              book max-ch (if (= max-ch 1) "" "s") ch))
     ;; Implausibly large verse (no biblical chapter has > 200 verses)
     ((and vs (> vs 200))
      (format "Verse %d is too large to be a valid biblical verse" vs))
     ;; Valid
     (t nil))))

(defun bible-commentary--canonicalize-book (raw)
  "Return canonical book name for RAW string, or nil if unrecognised."
  (let ((key (downcase (string-trim raw))))
    (or (cdr (assoc key bible-commentary--book-aliases))
        (cl-loop for (_abbr . canon) in bible-commentary--book-aliases
                 when (string-prefix-p key (downcase canon))
                 return canon))))

(defun bible-commentary--psalm-p (ref)
  "Return non-nil when REF points to the canonical Psalter (Psalms 1-150).
Psalm 151 is intentionally excluded: it is not in the Coverdale Psalter."
  (equal (plist-get ref :book) "Psalms"))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Psalm numbering scheme detection and canonical unit resolution

(defun bible-commentary--active-scheme (&optional translation)
  "Return the active psalm numbering scheme: \='vg or \='mt.

Priority:
  1. `bible-commentary--session-scheme' if non-nil (explicit override).
  2. If TRANSLATION (or the session/default translation) matches any name
     in `bible-commentary-vulgate-translation-names', return \='vg.
  3. Otherwise \='mt."
  (or bible-commentary--session-scheme
      (let ((tr (downcase
                 (or translation
                     bible-commentary--session-translation
                     bible-commentary-translation
                     ""))))
        (if (cl-some (lambda (name)
                       (string-match-p (regexp-quote (downcase name)) tr))
                     bible-commentary-vulgate-translation-names)
            'vg
          'mt))))

(defun bible-commentary--psalm-canonical-units (ref &optional scheme)
  "Return a list of canonical unit IDs for psalm REF under SCHEME (\='mt or \='vg).

Canonical units are MT-based strings: 1-150 for simple psalms,
116a/116b for the two halves of MT 116, 147a/147b for MT 147.
They are the keys used to find and store org headings, ensuring that notes
written from either numbering scheme resolve to the same headings.

Under MT scheme: returns the unit(s) for the given MT chapter number.
Under Vg scheme: returns all MT units covered by that Vg psalm number,
so Vg 9 returns the list (9 10) and Vg 113 returns (114 115)."
  (when (bible-commentary--psalm-p ref)
  (let* ((ch     (plist-get ref :chapter))
         (scheme (or scheme
                     (bible-commentary--active-scheme
                      (bcp-fetcher-active-translation ref)))))
    (when ch
      (if (eq scheme 'vg)
          ;; Interpret chapter as a Vulgate number
          (cond
           ((= ch 9)   '("9" "10"))
           ((= ch 113) '("114" "115"))
           ((= ch 114) '("116a"))
           ((= ch 115) '("116b"))
           ((= ch 146) '("147a"))
           ((= ch 147) '("147b"))
           ((<= ch 8)          (list (number-to-string ch)))
           ((<= ch 112)        (list (number-to-string (1+ ch))))
           ((<= ch 145)        (list (number-to-string (1+ ch))))
           (t                  (list (number-to-string ch))))
        ;; MT scheme
        (cond
         ((= ch 116) '("116a" "116b"))
         ((= ch 147) '("147a" "147b"))
         (t          (list (number-to-string ch)))))))))

(defun bible-commentary--unit-to-mt (unit)
  "Return the MT psalm number for canonical UNIT string."
  (unless (stringp unit)
    (error "bible-commentary--unit-to-mt: expected string, got %S" unit))
  (string-to-number (string-trim-right unit "ab")))

(defun bible-commentary--unit-to-vg (unit)
  "Return the Vulgate psalm number(s) for canonical UNIT string."
  (unless (stringp unit)
    (error "bible-commentary--unit-to-vg: expected string, got %S" unit))
  (let* ((has-suffix (memq (aref unit (1- (length unit))) '(?a ?b)))
         (suffix     (when has-suffix (aref unit (1- (length unit)))))
         (n          (string-to-number (if has-suffix
                                           (substring unit 0 -1)
                                         unit))))
    (cond
     ((<= n 8)   (list n))
     ((= n 9)    '(9))
     ((= n 10)   '(9))
     ((<= n 113) (list (1- n)))
     ((= n 114)  '(113))
     ((= n 115)  '(113))
     ((= n 116)  (cond ((eq suffix ?a) '(114))
                       ((eq suffix ?b) '(115))
                       (t              '(114 115))))
     ((<= n 146) (list (1- n)))
     ((= n 147)  (cond ((eq suffix ?a) '(146))
                       ((eq suffix ?b) '(147))
                       (t              '(146 147))))
     (t          (list n)))))

(defun bible-commentary--psalm-spans-p (ref &optional scheme)
  "Return non-nil when REF under SCHEME resolves to more than one canonical unit.
This is true for Vg 9 (spans MT 9+10), Vg 113 (spans MT 114+115), and
MT 116 and MT 147 (which each split into two Vg psalms).
Returns nil immediately for non-psalm refs."
  (and (bible-commentary--psalm-p ref)
       (> (length (bible-commentary--psalm-canonical-units ref scheme)) 1)))

(defun bible-commentary--unit-ref (base-ref unit)
  "Return a copy of BASE-REF with :chapter set to the MT number for UNIT."
  (let ((new (copy-sequence base-ref)))
    (plist-put new :chapter (bible-commentary--unit-to-mt unit))))

(defun bible-commentary-set-scheme (scheme)
  "Override the psalm numbering scheme for this session.
SCHEME is \='mt, \='vg, or nil (restore automatic detection).
Interactively, prompts for mt / vg / auto."
  (interactive
   (list (let ((s (completing-read
                   "Psalm numbering scheme (mt/vg/auto): "
                   '("mt" "vg" "auto") nil t nil nil "auto")))
           (cond ((equal s "mt")   'mt)
                 ((equal s "vg")   'vg)
                 (t                 nil)))))
  (setq bible-commentary--session-scheme scheme)
  (message "Psalm numbering: %s"
           (cond ((eq scheme 'mt) "MT (Hebrew/KJV) — locked for this session")
                 ((eq scheme 'vg) "Vg (Vulgate/LXX) — locked for this session")
                 (t               "automatic (follows active translation)"))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Reference parsing & formatting

(defun bible-commentary--parse-reference (ref-string)
  "Parse REF-STRING → plist (:book :chapter :verse-start :verse-end), or nil.

Handles:
  \"Gen 1:1\"       → Genesis, ch 1, v 1
  \"Gen 1:1-3\"     → Genesis, ch 1, vv 1-3
  \"Ps 23\"         → Psalms, ch 23
  \"Psalm 151\"     → Psalm 151 (the book), no chapter
  \"4 Ezra 7:1\"    → 2 Esdras (= 4 Ezra), ch 7, v 1
  \"1 Macc 2:1\"    → 1 Maccabees, ch 2, v 1

The parser splits on the first colon, then tries two strategies for the
left-hand side:
  1. Try the full string as a book name (catches \"Psalm 151\", \"4 Ezra\").
  2. Peel the last token as a chapter number if the remainder canonicalises."
  (let* ((s         (string-trim ref-string))
         (colon     (string-match ":" s))
         (book-ch   (string-trim (if colon (substring s 0 colon) s)))
         (verse-raw (when colon (string-trim (substring s (1+ colon)))))
         (chapter   nil)
         (book-raw  book-ch))
    ;; Step 1: try the full left-hand string as a book name.
    ;; Step 2: if that fails, peel a trailing integer as the chapter number.
    (unless (bible-commentary--canonicalize-book book-ch)
      (when (string-match
             (rx (group (+ anything)) (+ space) (group (+ digit)) eos)
             book-ch)
        (let ((cand-book (match-string 1 book-ch))
              (cand-ch   (string-to-number (match-string 2 book-ch))))
          (when (bible-commentary--canonicalize-book cand-book)
            (setq book-raw cand-book
                  chapter  cand-ch)))))
    (let ((book (bible-commentary--canonicalize-book (string-trim book-raw))))
      (when book
        (if (and verse-raw
                 (string-match (rx bos (group (+ digit))
                                   (optional (: (? space) "-" (? space))
                                             (group (+ digit)))
                                   eos)
                               verse-raw))
            (let ((vs (string-to-number (match-string 1 verse-raw)))
                  (ve (when (match-string 2 verse-raw)
                        (string-to-number (match-string 2 verse-raw)))))
              (list :book book :chapter chapter
                    :verse-start vs :verse-end (or ve vs)))
          (list :book book :chapter chapter
                :verse-start nil :verse-end nil))))))

(defun bible-commentary--ref-to-string (ref)
  "Format REF plist to a readable string like \"John 3:16\"."
  (let ((book (plist-get ref :book))
        (ch   (plist-get ref :chapter))
        (vs   (plist-get ref :verse-start))
        (ve   (plist-get ref :verse-end)))
    (cond
     ((and vs ve (not (= vs ve))) (format "%s %d:%d-%d" book ch vs ve))
     (vs                          (format "%s %d:%d"    book ch vs))
     (ch                          (format "%s %d"       book ch))
     (t                            book))))

(defun bible-commentary--ref-to-string-safe ()
  "Return current verse ref string, or empty string (for capture templates)."
  (if bible-commentary--current-verse
      (bible-commentary--ref-to-string bible-commentary--current-verse)
    ""))

(defun bible-commentary--ref-to-org-anchor (ref)
  "Return a CUSTOM_ID/filename-safe string for REF."
  (let ((book (replace-regexp-in-string "[ ()]" "_" (plist-get ref :book)))
        (ch   (plist-get ref :chapter))
        (vs   (plist-get ref :verse-start)))
    (cond (vs (format "%s_%d_%d" book ch vs))
          (ch (format "%s_%d"   book ch))
          (t   book))))

(defun bible-commentary--ref-overlaps-p (nav note)
  "Non-nil when NOTE is relevant to someone navigating to NAV.

Implements containment/overlap at every granularity level:
  - Book-level ref overlaps everything in that book
  - Chapter-level ref overlaps every verse in that chapter
  - Verse/range ref overlaps any note whose range intersects it

This means navigating to John 3 surfaces notes on John 3:16,
John 3:10-20, and the whole chapter equally.  Navigating to
John 3:16 surfaces a note on John 3:10-20 (which contains it)
but not John 3:1-9 (which ends before it)."
  (and nav note
       ;; Must be same book
       (equal (plist-get nav :book) (plist-get note :book))
       (let ((nav-ch  (plist-get nav  :chapter))
             (note-ch (plist-get note :chapter)))
         ;; If either is book-level: always overlaps within the same book
         (or (null nav-ch) (null note-ch)
             ;; Both have chapters: must match
             (and (= nav-ch note-ch)
                  (let ((nav-vs  (plist-get nav  :verse-start))
                        (note-vs (plist-get note :verse-start)))
                    ;; If either is chapter-level: overlaps all verses
                    (or (null nav-vs) (null note-vs)
                        ;; Both have verses: check range intersection
                        (let ((nav-ve  (or (plist-get nav  :verse-end) nav-vs))
                              (note-ve (or (plist-get note :verse-end) note-vs)))
                          (and (<= nav-vs note-ve)
                               (<= note-vs nav-ve))))))))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Translation management & Coverdale auto-switch


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
                ;; Prefix with "unit-" so org never interprets
                ;; values like "116a" as Lisp symbols during property scanning
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
;;;; Bible text loading & Oremus fetch

(defun bible-commentary--load-text (text &optional label)
  "Replace Bible buffer contents with TEXT; display LABEL in header."
  (with-current-buffer bible-commentary--bible-buffer
    (let ((inhibit-read-only t))
      (erase-buffer)
      (when label (insert "=== " label " ===\n\n"))
      (insert (bible-commentary--clean-display-text text))
      (goto-char (point-min))
      (set-buffer-modified-p nil))))

(defun bible-commentary--clean-display-text (text)
  "Clean up TEXT for display in the Bible buffer.

Handles two encoding issues with raw Oremus text:
1. C1 control characters U+0091-U+0097 — Windows-1252 typographic
   characters decoded as Latin-1 — mapped to correct Unicode equivalents.
2. Non-breaking spaces (U+00A0) replaced with regular spaces.

Verse numbers and chapter headings are handled upstream by
`bcp-fetcher-dom-to-text' when libxml is available."
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


(defun bible-commentary--load-local-file (path)
  "Insert plain-text Bible from PATH into the Bible buffer."
  (with-temp-buffer
    (insert-file-contents path)
    (bible-commentary--load-text (buffer-string)
                                  (file-name-nondirectory path))))


(defun bible-commentary--load-verse-text (ref)
  "Load Bible text for REF, honouring translation, Coverdale, and textual status.

For verses flagged as omitted in the critical text (e.g. John 5:4 in ESV),
fetches a context window of surrounding verses with footnotes enabled rather
than the bare verse — which would return empty content.  A banner is prepended
to the Bible buffer explaining the textual situation.

For disputed passages (Long Ending of Mark, Pericope Adulterae, etc.), fetches
normally — these passages are present in the ESV/NRSV text, preceded by a
section note that survives HTML stripping and explains the textual status."
  (let* ((tr     (bcp-fetcher-active-translation ref))
         (status (when (bcp-fetcher-critical-translation-p tr)
                   (bcp-fetcher-textual-status ref))))
    (cond
     ;; Omitted verse in a critical translation → widen context + fnote=yes
     ((and status (eq (plist-get status :status) 'omitted))
      (bcp-fetcher-fetch-oremus-context
       ref tr
       (lambda (text label)
         (bible-commentary--load-text text label))
       (lambda (banner)
         (with-current-buffer bible-commentary--bible-buffer
           (let ((inhibit-read-only t))
             (goto-char (point-min))
             (when (re-search-forward "^===.*===\n" nil t)
               (insert banner "\n\n")))))))
     ;; Coverdale Psalter — local file preferred
     ((and (string= tr bible-commentary-psalm-translation)
           bible-commentary-coverdale-file
           (file-exists-p bible-commentary-coverdale-file))
      (bible-commentary--load-local-file bible-commentary-coverdale-file)
      (bible-commentary--seek-verse-in-bible-buffer ref))
     ;; Any translation — local Bible file
     ((and bible-commentary-bible-file
           (file-exists-p bible-commentary-bible-file))
      (bible-commentary--load-local-file bible-commentary-bible-file)
      (bible-commentary--seek-verse-in-bible-buffer ref))
     ;; Oremus — normal fetch
     (t
      (bcp-fetcher-fetch-oremus
       (bible-commentary--ref-to-string ref)
       (lambda (text label) (bible-commentary--load-text text label))
       tr)))))

(defun bible-commentary--seek-verse-in-bible-buffer (ref)
  "Scroll the Bible buffer to the line that contains REF."
  (with-current-buffer bible-commentary--bible-buffer
    (goto-char (point-min))
    (when (re-search-forward
           (regexp-quote (bible-commentary--ref-to-string ref)) nil t)
      (beginning-of-line)
      (recenter 2))))

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
REF is the parsed psalm ref (e.g. Vg 9, MT 116); SCHEME is \='vg or \='mt.

The buffer contains one org heading per canonical MT unit, separated by a
visible divider, and is fully editable.  Use \\[bible-commentary-spanning-sync]
(C-c C-w) to write changes back to the master commentary file.  Use
\\[bible-commentary-spanning-jump] (C-c C-1, C-c C-2, …) to jump to a specific
unit in the master file."
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
REF may be a psalm unit plist or any verse/chapter/book ref plist.
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
    (let* ((ch  (or (plist-get bible-commentary--current-verse :chapter) 2))
           (new (copy-sequence bible-commentary--current-verse)))
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
the connection — this is what makes the backlinks panel work.  Without roam,
inserts a plain CUSTOM_ID internal link."
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
Results are ordered from broadest scope (book) to narrowest (verse),
so the collation view reads from context down to the specific passage."
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
  "Return a symbol describing the granularity of REF: \'book, \'chapter, or \'verse."
  (cond ((null (plist-get ref :chapter))     'book)
        ((null (plist-get ref :verse-start)) 'chapter)
        (t                                    'verse)))

(defun bible-commentary--contextual-title (ref hits)
  "Return a descriptive title string for a contextual collation view.
REF is the navigation target; HITS is the list from
`bible-commentary--collect-overlapping-headings'."
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
  "Open an editable contextual view of all notes overlapping REF-STRING.

This is the primary note-reading surface.  It surfaces notes at every
granularity that intersects the navigation target:
  - Navigate to John 3:16 → shows John 3:16, John 3:10-20, John 3, John
  - Navigate to John 3    → shows all verse notes in chapter 3
  - Navigate to John      → shows all notes in the book of John

Each overlapping heading appears as an editable section.  Use
\[bible-commentary-spanning-sync] (C-c C-w) to write changes back to the
master commentary file."
  (interactive "sCollate notes for: ")
  (let* ((ref   (bible-commentary--parse-reference ref-string))
         (label (bible-commentary--ref-to-string ref)))
    (unless ref (user-error "Cannot parse: %s" ref-string))
    (bible-commentary--open-contextual-view ref label)))

(defun bible-commentary--open-contextual-view (ref label)
  "Open an editable contextual view for REF, titled LABEL.
Collects all overlapping headings from the master commentary, ensures the
navigation target heading exists, and presents everything in an editable
spanning buffer with C-c C-w sync."
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
          (insert (format "#+TITLE: %s
" title))
          (insert "# C-c C-w = sync to master | C-c C-j = jump section in master

")
          ;; One section per overlapping heading
          (let ((idx 1) (total (length hits)))
            (dolist (hit hits)
              (let* ((hit-ref  (car hit))
                     (hit-text (cdr hit))
                     (hit-label (bible-commentary--ref-to-string hit-ref))
                     (is-nav   (equal hit-ref ref)))
                ;; Separator between sections
                (when (> idx 1)
                  (insert "#+BEGIN_COMMENT
")
                  (insert (make-string 60 ?─) "
")
                  (insert "#+END_COMMENT

"))
                ;; Section heading — mark the navigation target clearly
                (insert (format "* %s%s
"
                                hit-label
                                (if is-nav "  ← current" "")))
                (insert ":PROPERTIES:
")
                (insert (format ":VERSE_REF:   %s
" hit-label))
                (insert (format ":SECTION_IDX: %d
" idx))
                (insert ":END:

")
                ;; Body: extract from master heading (below properties drawer)
                (let ((body (bible-commentary--spanning-extract-unit
                             master hit-ref)))
                  (when body (insert body "
")))
                (insert "
")
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
;;;; Synchronized scrolling

(defun bible-commentary--scroll-fraction ()
  (/ (float (line-number-at-pos (window-start)))
     (max 1 (line-number-at-pos (point-max)))))

(defun bible-commentary--scroll-to-fraction (frac)
  (let ((target (round (* frac (line-number-at-pos (point-max))))))
    (goto-char (point-min))
    (forward-line (max 0 (1- target)))
    (recenter 0)))

(defun bible-commentary--sync-scroll ()
  "Proportionally sync scroll between the two commentary buffers."
  (when (and bible-commentary-sync-scroll
             (not bible-commentary--inhibit-scroll)
             (memq (current-buffer)
                   (list bible-commentary--bible-buffer
                         bible-commentary--commentary-buffer)))
    (let* ((bible-commentary--inhibit-scroll t)
           (frac  (bible-commentary--scroll-fraction))
           (other (if (eq (current-buffer) bible-commentary--bible-buffer)
                      bible-commentary--commentary-buffer
                    bible-commentary--bible-buffer))
           (win   (get-buffer-window other)))
      (when win
        (with-selected-window win
          (bible-commentary--scroll-to-fraction frac))))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Buffer & window setup

(defun bible-commentary--setup-bible-buffer (buf)
  (with-current-buffer buf
    (read-only-mode 1)
    (visual-line-mode 1)
    ;; Ensure Unicode characters (curly quotes, em-dashes, etc.) display correctly
    (set-buffer-file-coding-system 'utf-8)
    ;; No line numbers needed in a reading buffer
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


(defun bible-commentary-psalm-lookup (psalm-num &optional scheme)
  "Show the equivalent psalm number in the other numbering scheme.
PSALM-NUM is an integer.  SCHEME is either \='mt (default, Masoretic/KJV)
or \='vg (Vulgate/LXX).  Result is shown in the minibuffer.

Interactively, prompts for the number and scheme."
  (interactive
   (list (read-number "Psalm number: ")
         (intern (completing-read "Scheme (mt/vg): " '("mt" "vg") nil t nil nil "mt"))))
  (let ((scheme (or scheme 'mt)))
    (if (eq scheme 'mt)
        (let* ((vg  (bible-commentary--psalm-mt-to-vg psalm-num))
               (ann (bible-commentary--psalm-numbering-annotation psalm-num)))
          (if ann
              (message "Psalm %d  (%s)" psalm-num ann)
            (message "Psalm %d  — same in both systems" psalm-num)))
      (let* ((mt  (bible-commentary--psalm-vg-to-mt psalm-num))
             (mt-str (mapconcat #'number-to-string mt " & ")))
        (if (equal mt (list psalm-num))
            (message "Vg Psalm %d  — same in both systems" psalm-num)
          (message "Vg Psalm %d  =  MT Psalm %s" psalm-num mt-str))))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Spanning buffer minor mode and state variables

(defvar bible-commentary--spanning-units  nil "Units in the current spanning buffer.")
(defvar bible-commentary--spanning-master nil "Master commentary buffer for spanning sync.")
(defvar bible-commentary--spanning-label  nil "Display label for the current spanning psalm.")

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
  "Minor mode for editable spanning psalm buffers.
These buffers show multiple canonical MT psalm units together when a single
Vulgate (or MT) psalm number spans more than one unit.  Use C-c C-w to sync
changes back to the master commentary file."
  :lighter " BSpan"
  :keymap bible-commentary-spanning-mode-map)

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Keymaps

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

;;;###autoload
(defun bible-commentary-fetch-passage (passage &optional translation)
  "Fetch PASSAGE from Oremus into the Bible buffer.
TRANSLATION defaults to `bible-commentary-translation' (KJVA)."
  (interactive
   (list (read-string "Passage (e.g. Tobit 12:1-22): ")
         (let ((s (read-string "Translation (blank for KJVA): ")))
           (if (string-empty-p s) nil s))))
  (unless bible-commentary--bible-buffer
    (user-error "Run `bible-commentary-open' first."))
  (bcp-fetcher-fetch-oremus
   passage
   (lambda (text label) (bible-commentary--load-text text label))
   (or (and translation (not (string-empty-p translation)) translation)
       bible-commentary-translation)))

(defun bible-commentary-migrate-canonical-units ()
  "Fix :CANONICAL_UNIT: properties written by older versions of this package.
Earlier versions wrote bare values like \"116a\" which org-mode can
misinterpret as Lisp symbols.  This command adds the \"unit-\" prefix
to all affected properties in the master commentary file.
Run this once after upgrading if you see \"void-variable 116a\" errors."
  (interactive)
  (with-current-buffer (find-file-noselect bible-commentary-file)
    (save-excursion
      (goto-char (point-min))
      (let ((count 0))
        (while (re-search-forward
                "^\\([ \t]*:CANONICAL_UNIT:[ \t]+\\)\\([0-9][0-9]*[ab]?\\)[ \t]*$"
                nil t)
          (let ((prefix (match-string 1))
                (value  (match-string 2)))
            ;; Only fix bare values without the unit- prefix
            (unless (string-prefix-p "unit-" value)
              (replace-match (concat prefix "unit-" value))
              (cl-incf count))))
        (if (> count 0)
            (progn (save-buffer)
                   (message "Migrated %d :CANONICAL_UNIT: propert%s in %s"
                            count (if (= count 1) "y" "ies")
                            bible-commentary-file))
          (message "No migration needed — all :CANONICAL_UNIT: values already correct."))))))


(provide 'bcp-reader)
;;; bcp-reader.el ends here

;;;; ──────────────────────────────────────────────────────────────────────
;;;; BCP Psalter generation — one-time utility

(defun bible-commentary-generate-bcp-psalter (output-dir)
  "Fetch all 150 psalms from Oremus BCP and write them as SWORD plain text files.
OUTPUT-DIR should be your SWORD translation subdirectory, e.g.
\"~/sword/Coverdale/\".  Files are named eng-bcp_020_PSA_NNN_read.txt.

This is a one-time utility function — it makes 150 synchronous HTTP
requests to Oremus, so it will take a few minutes.  Progress is shown
in the minibuffer."
  (interactive "DOutput directory for BCP Psalter files: ")
  (unless (file-directory-p output-dir)
    (make-directory output-dir t))
  (let ((success 0)
        (failed  '()))
    (dotimes (i 150)
      (let* ((psalm-num (1+ i))
             (filename  (format "eng-bcp_020_PSA_%03d_read.txt" psalm-num))
             (filepath  (expand-file-name filename output-dir))
             (passage   (format "Psalms %d" psalm-num))
             (url       (format "https://bible.oremus.org/?passage=%s&version=BCP&fnote=no&show_ref=no&omit_cr=no&vnum=yes"
                                (url-hexify-string passage))))
        (message "Fetching Psalm %d/150..." psalm-num)
        (condition-case err
            (let* ((buf    (url-retrieve-synchronously url t t 30))
                   (verses (when buf
                             (with-current-buffer buf
                               (bible-commentary--bcp-parse-psalm)))))
              (when buf (kill-buffer buf))
              (if verses
                  (progn
                    (with-temp-file filepath
                      (insert "The Psalter, or Psalms of David.\n")
                      (insert (format "Psalm %d.\n" psalm-num))
                      (dolist (v verses)
                        (insert v "\n")))
                    (cl-incf success))
                (push psalm-num failed)))
          (error
           (message "Error fetching Psalm %d: %s" psalm-num (error-message-string err))
           (push psalm-num failed)))))
    (if failed
        (message "Done: %d psalms written. Failed: %s"
                 success
                 (mapconcat #'number-to-string (nreverse failed) ", "))
      (message "Done: all 150 psalms written to %s" output-dir))))

(defun bible-commentary--bcp-parse-psalm ()
  "Parse BCP psalm HTML from the current url-retrieve buffer.
Returns a list of verse text strings, one per verse, with the
BCP pointing asterisk (*) preserved."
  (goto-char (point-min))
  ;; Skip HTTP headers
  (re-search-forward "\r\n\r\n\\|\n\n" nil t)
  (let* ((body  (buffer-substring-no-properties (point) (point-max)))
         ;; Decode Windows-1252
         (decoded (decode-coding-string
                   (encode-coding-string body 'raw-text)
                   'windows-1252)))
    (when (fboundp 'libxml-parse-html-region)
      (with-temp-buffer
        (insert decoded)
        (let* ((dom     (libxml-parse-html-region (point-min) (point-max)))
               (btexts  (dom-by-class dom "bibletext"))
               (verses  '()))
          (dolist (btext btexts)
            (dolist (child (dom-children btext))
              ;; Look for cwvnum spans
              (when (and (listp child)
                         (or (eq (dom-tag child) 'p)
                             (eq (dom-tag child) 'span)))
                (bible-commentary--bcp-collect-verses child verses))))
          (nreverse verses))))))

(defun bible-commentary--bcp-collect-verses (node acc)
  "Recursively collect verse texts from NODE into ACC."
  ;; Walk children looking for cwvnum spans
  (let ((children (dom-children node)))
    (let ((i 0))
      (while (< i (length children))
        (let ((child (nth i children)))
          (when (and (listp child)
                     (string-match-p "\\bcwvnum\\b"
                                     (or (dom-attr child 'class) "")))
            ;; Found a verse number — collect text until next cwvnum
            (let ((verse-text ""))
              (setq i (1+ i))
              (while (and (< i (length children))
                          (let ((c (nth i children)))
                            (not (and (listp c)
                                      (string-match-p
                                       "\\bcwvnum\\b"
                                       (or (dom-attr c 'class) ""))))))
                (let ((c (nth i children)))
                  (cond
                   ;; Text node
                   ((stringp c)
                    (setq verse-text (concat verse-text c)))
                   ;; br — suppress
                   ((and (listp c) (eq (dom-tag c) 'br))
                    nil)
                   ;; Other element — get its text
                   ((listp c)
                    (setq verse-text
                          (concat verse-text (dom-texts c "")))))
                  (setq i (1+ i))))
              ;; Clean up verse text
              (let ((cleaned (bible-commentary--bcp-clean-verse verse-text)))
                (when (not (string-empty-p cleaned))
                  (push cleaned acc)))))
          (when (not (and (listp child)
                          (string-match-p "\\bcwvnum\\b"
                                          (or (dom-attr child 'class) ""))))
            (setq i (1+ i)))))))
  acc)

(defun bible-commentary--bcp-clean-verse (text)
  "Clean up raw verse text from Oremus BCP HTML."
  (let ((s text))
    ;; Replace non-breaking spaces with regular spaces
    (setq s (replace-regexp-in-string "\u00a0" " " s))
    ;; Collapse multiple spaces
    (setq s (replace-regexp-in-string "[ \t]+" " " s))
    ;; Trim
    (string-trim s)))
