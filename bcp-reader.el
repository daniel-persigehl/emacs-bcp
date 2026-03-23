;;; bcp-reader.el --- Scripture passage reader -*- lexical-binding: t -*-

;; Version: 0.3.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: bible, bcp, scripture, reader

;;; Commentary:

;; Standalone scripture reader: passage display, reference parsing,
;; translation management, local file loading, psalm scheme detection.
;; No org-roam or annotation dependencies.
;;
;; For the full two-buffer study environment with commentary, backlinks,
;; and annotation, require bcp-notebook instead.
;;
;; Quick start:
;;   (require 'bcp-reader)
;;   (bible-commentary-fetch-passage "John 3:16")

;;; Code:

(require 'cl-lib)
(require 'url)
(require 'bcp-fetcher)

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Customisation

(defgroup bible-commentary nil
  "Bible commentary environment."
  :group 'applications
  :prefix "bible-commentary-")

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
Either \\='mt, \\='vg, or nil (auto-detect from active translation).
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
        ;; MT number → show Vg equivalent
        (let ((ann (bible-commentary--psalm-numbering-annotation ch)))
          (when ann (format " (%s)" ann)))))))

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
Returns nil if REF is valid, or a human-readable error string if not."
  (let* ((book (plist-get ref :book))
         (ch   (plist-get ref :chapter))
         (vs   (plist-get ref :verse-start))
         (max-ch (cdr (assoc book bible-commentary--chapter-counts))))
    (cond
     ((null max-ch)
      (format "'%s' is not a recognised book of the Bible" book))
     ((and ch (< ch 1))
      (format "%s has no chapter 0 or below" book))
     ((and ch (> ch max-ch))
      (format "%s has %d chapter%s (chapter %d does not exist)"
              book max-ch (if (= max-ch 1) "" "s") ch))
     ((and vs (> vs 200))
      (format "Verse %d is too large to be a valid biblical verse" vs))
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
  "Return the active psalm numbering scheme: \\='vg or \\='mt.

Priority:
  1. `bible-commentary--session-scheme' if non-nil (explicit override).
  2. If TRANSLATION (or the session/default translation) matches any name
     in `bible-commentary-vulgate-translation-names', return \\='vg.
  3. Otherwise \\='mt."
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
  "Return a list of canonical unit IDs for psalm REF under SCHEME (\\='mt or \\='vg).

Canonical units are MT-based strings: 1-150 for simple psalms,
116a/116b for the two halves of MT 116, 147a/147b for MT 147."
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
  "Return non-nil when REF under SCHEME resolves to more than one canonical unit."
  (and (bible-commentary--psalm-p ref)
       (> (length (bible-commentary--psalm-canonical-units ref scheme)) 1)))

(defun bible-commentary--unit-ref (base-ref unit)
  "Return a copy of BASE-REF with :chapter set to the MT number for UNIT."
  (let ((new (copy-sequence base-ref)))
    (plist-put new :chapter (bible-commentary--unit-to-mt unit))))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Psalm numbering cross-scheme helpers

(defun bible-commentary--psalm-numbering-annotation (mt-num)
  "Return a Vg annotation string for MT-NUM, or nil if the numbers coincide."
  (let* ((unit    (number-to-string mt-num))
         (vg-nums (bible-commentary--unit-to-vg unit)))
    (unless (equal vg-nums (list mt-num))
      (format "Vg %s"
              (mapconcat #'number-to-string vg-nums "/")))))

(defun bible-commentary--psalm-mt-to-vg (mt-num)
  "Return the list of Vulgate psalm numbers covering MT-NUM."
  (bible-commentary--unit-to-vg (number-to-string mt-num)))

(defun bible-commentary--psalm-vg-to-mt (vg-num)
  "Return the list of MT psalm numbers covered by VG-NUM."
  (let* ((fake-ref (list :book "Psalms" :chapter vg-num
                         :verse-start nil :verse-end nil))
         (units (bible-commentary--psalm-canonical-units fake-ref 'vg)))
    (mapcar #'bible-commentary--unit-to-mt units)))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Session overrides

(defun bible-commentary-set-scheme (scheme)
  "Override the psalm numbering scheme for this session.
SCHEME is \\='mt, \\='vg, or nil (restore automatic detection).
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
  "Parse REF-STRING → plist (:book :chapter :verse-start :verse-end), or nil."
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
  - Verse/range ref overlaps any note whose range intersects it"
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
                               (<= note-vs nav-ve)))))))))))

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


(defun bible-commentary--load-local-file (path)
  "Insert plain-text Bible from PATH into the Bible buffer."
  (with-temp-buffer
    (insert-file-contents path)
    (bible-commentary--load-text (buffer-string)
                                  (file-name-nondirectory path))))


(defun bible-commentary--load-verse-text (ref)
  "Load Bible text for REF, honouring translation, Coverdale, and textual status."
  (let* ((tr     (bcp-fetcher-active-translation ref))
         (status (when (bcp-fetcher-critical-translation-p tr)
                   (bcp-fetcher-textual-status ref))))
    (cond
     ;; Omitted verse in a critical translation → widen context window
     ((and status (eq (plist-get status :status) 'omitted))
      (bcp-fetcher-fetch-passage-context
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
     ;; Network fetch
     (t
      (bcp-fetcher-fetch-passage
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
;;;; Standalone reader commands

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
  (bcp-fetcher-fetch-passage
   passage
   (lambda (text label) (bible-commentary--load-text text label))
   (or (and translation (not (string-empty-p translation)) translation)
       bible-commentary-translation)))

(defun bible-commentary-psalm-lookup (psalm-num &optional scheme)
  "Show the equivalent psalm number in the other numbering scheme.
PSALM-NUM is an integer.  SCHEME is either \\='mt (default, Masoretic/KJV)
or \\='vg (Vulgate/LXX).  Result is shown in the minibuffer."
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
;;;; BCP Psalter generation — one-time utility

(defun bible-commentary-generate-bcp-psalter (output-dir)
  "Fetch all 150 psalms from Oremus BCP and write them as SWORD plain text files.
OUTPUT-DIR should be your SWORD translation subdirectory, e.g.
\"~/sword/Coverdale/\".  Files are named eng-bcp_020_PSA_NNN_read.txt.

This is a one-time utility function — it makes 150 synchronous HTTP
requests to Oremus, so it will take a few minutes."
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
Returns a list of verse text strings, one per verse."
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


(provide 'bcp-reader)
;;; bcp-reader.el ends here
