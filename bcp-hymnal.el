;;; bcp-hymnal.el --- Shared hymnal framework -*- lexical-binding: t -*-

;;; Commentary:

;; A shared registry and render layer for hymnals.  Per the project plan
;; ("metrical psalters are hymns"), one framework serves:
;;   - Traditional hymnals (Hymnal 1940, Hymnal 1982, English Hymnal, ...)
;;   - Metrical psalters (Scottish Psalter 1650, Anglo-Genevan 1987,
;;     Japanese Genevan, ...)
;;   - Office hymnal (Roman incipit-keyed — provides the Latin corpus
;;     for the Divine Office; cross-referenced here via translator records)
;;
;; Three registries, normalized so a single text or tune record serves
;; every hymnal that uses it:
;;
;;   * `bcp-hymnal--texts'  — text-id -> plist.  One record per
;;     translation/original pair.  A single Latin hymn with three
;;     English renderings is three text records (plus the Latin),
;;     each keyed by (:original, :translator).
;;
;;   * `bcp-hymnal--tunes'  — tune-id -> plist.  One record per tune,
;;     keyed by canonical name (NICAEA, EVENTIDE, SINE-NOMINE, ...).
;;     Shared across every hymnal that uses that tune.
;;
;;   * `bcp-hymnal--manifests' — hymnal-id -> number -> slot-plist.
;;     The per-hymnal number->text+tune mapping.  The only thing that
;;     differs between hymnals for a shared text.
;;
;; Copyright is recorded on the thing that is or isn't copyrighted
;; (text/translation/tune/harmonization), not on the hymnal slot.
;; Hymnal-slot entries can override with a local note.

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-calendar)
(require 'bcp-1662-calendar)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Customization group

(defgroup bcp-hymnal nil
  "Shared hymnal framework for the BCP package."
  :prefix "bcp-hymnal-"
  :group 'bcp-liturgy)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defcustom bcp-hymnal-available nil
  "List of hymnal IDs the user has enabled.
Each entry is a symbol identifying a hymnal; the matching manifest
file `bcp-hymnal-<id>.el' is loaded on demand.  Example:
  (setq bcp-hymnal-available \\='(hymnal-1940 hymnal-1982))"
  :type '(repeat symbol)
  :group 'bcp-hymnal)

(defcustom bcp-hymnal-primary nil
  "The hymnal whose numbering is authoritative for appointed references.
When an ordo or proper specifies \"Hymn N\", this is the book whose
slot N is used.  Must be a member of `bcp-hymnal-available' (or nil
when no hymnal is primary)."
  :type 'symbol
  :group 'bcp-hymnal)

(defcustom bcp-hymnal-preferred-translator 'neale
  "Default English translator for Latin/Greek office hymns.
Used when a hymn record offers multiple English renderings.  Falls
back through `bcp-hymnal-translator-fallback' if the preferred is
unavailable."
  :type 'symbol
  :group 'bcp-hymnal)

(defcustom bcp-hymnal-translator-fallback
  '(neale caswall newman chambers riley primer britt do)
  "Translator fallback order, tried in sequence.
`do' is the Divinum Officium project's composite translations,
used when no named 19th-c translator is on file."
  :type '(repeat symbol)
  :group 'bcp-hymnal)

(defcustom bcp-private-data-dir nil
  "Directory containing user-private hymnal/psalter data (copyrighted).
When non-nil, hymnal manifests check this directory before falling
back to shipped data, so users who hold valid copies of copyrighted
editions (Hymnal 1982, Anglo-Genevan 1987, Japanese Genevan,
Patterson's The Shaker Spiritual, etc.) can drop the matching text
files here and have them render like any shipped source.  Never
commit content from this directory to the repo."
  :type '(choice (const :tag "None" nil) directory)
  :group 'bcp-hymnal)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Translator registry
;;
;; Translators are first-class.  Each hymn text record names its
;; translator (when applicable); the user picks a preferred translator
;; via `bcp-hymnal-preferred-translator'.  Dates and copyright status
;; live here, not duplicated into every text record.

(defvar bcp-hymnal--translators
  '((neale        :name "John Mason Neale"        :dates "1818-1866"
                  :copyright :public-domain
                  :notes "Most prolific English translator of Greek/Latin office hymns")
    (caswall      :name "Edward Caswall"          :dates "1814-1878"
                  :copyright :public-domain
                  :notes "Roman Catholic; Lyra Catholica (1849)")
    (newman       :name "John Henry Newman"       :dates "1801-1890"
                  :copyright :public-domain
                  :notes "Tractarian; Tracts for the Times No. 75 (1836)")
    (chambers     :name "John David Chambers"     :dates "1805-1893"
                  :copyright :public-domain
                  :notes "Sarum use; The Psalter, or Seven Ordinary Hours (1852)")
    (riley        :name "Athelstan Riley"         :dates "1858-1945"
                  :copyright :public-domain
                  :notes "English Hymnal (1906)")
    (winkworth    :name "Catherine Winkworth"     :dates "1827-1878"
                  :copyright :public-domain
                  :notes "German chorales; Lyra Germanica (1855)")
    (britt        :name "Matthew Britt, OSB"      :dates "1922"
                  :copyright :public-domain
                  :notes "Hymns of the Breviary and Missal (1922)")
    (primer       :name "The Primer"              :dates "16c-18c"
                  :copyright :public-domain
                  :notes "Various editions, 16th-18th century")
    (bland-tucker :name "F. Bland Tucker"         :dates "1895-1984"
                  :copyright (:restricted :text)
                  :notes "Episcopal; 1940 Hymnal Commission; translations restricted")
    (do           :name "Divinum Officium"        :dates "open project"
                  :copyright :public-domain
                  :notes "Composite English translations from divinumofficium.com"))
  "Alist of translator records.
Each entry: (TRANSLATOR-ID :name :dates :copyright :notes).")

(defun bcp-hymnal-translator (id)
  "Return plist for translator ID, or nil."
  (cdr (assq id bcp-hymnal--translators)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Text registry
;;
;; Hash table keyed by text-id symbol.  Lazy-loaded from
;; `bcp-hymnal-texts-file' on first access.  A text record:
;;
;;   :first-line   STRING
;;   :stanzas      LIST of STRING (each stanza preserves internal newlines)
;;   :author       STRING or nil
;;   :author-dates STRING or nil  ("1707-1788")
;;   :translator   SYMBOL or nil  (id in `bcp-hymnal--translators')
;;   :original     SYMBOL or nil  (Latin incipit-id, cross-ref to
;;                                 `bcp-roman-hymnal')
;;   :first-published  INTEGER or nil  (year)
;;   :copyright    :public-domain | (:restricted :text ...)
;;   :meter        STRING        ("87.87", "L.M.", "C.M.", ...)
;;   :language     SYMBOL        (english / latin / greek / german / ...)

(defvar bcp-hymnal--texts nil
  "Hash table mapping text-id symbols to text plist records.
Lazy-loaded by `bcp-hymnal--ensure-texts'.")

(defcustom bcp-hymnal-texts-file
  (expand-file-name "bcp-hymnal-texts.txt"
                    (file-name-directory
                     (or load-file-name buffer-file-name default-directory)))
  "Path to the shared hymnal text file.
Plain text, block-structured, one block per text record.  Parsed
into `bcp-hymnal--texts' on first access."
  :type 'file
  :group 'bcp-hymnal)

(defvar bcp-hymnal--exporters nil
  "Zero-arg functions run after the main texts file is parsed.
Each may insert additional records into `bcp-hymnal--texts'.
Use `bcp-hymnal-register-exporter' to add one.  Exporters are the
mechanism by which incipit-keyed corpora (the Roman office hymnal,
future Lutheran chorales, etc.) plug their records into the
unified text store while keeping their own authoring shape.")

(defun bcp-hymnal-register-exporter (fn)
  "Register FN as a texts exporter; runs after the file parse.
FN takes no arguments and may `puthash' into `bcp-hymnal--texts'."
  (cl-pushnew fn bcp-hymnal--exporters))

(defun bcp-hymnal--ensure-texts ()
  "Load texts file into `bcp-hymnal--texts' if not already loaded.
After the file parse, every registered exporter is run so that
incipit-keyed corpora can contribute records.  Returns the table."
  (unless (hash-table-p bcp-hymnal--texts)
    (setq bcp-hymnal--texts (make-hash-table :test 'eq))
    (when (file-exists-p bcp-hymnal-texts-file)
      (bcp-hymnal--parse-texts-file bcp-hymnal-texts-file))
    (dolist (fn (reverse bcp-hymnal--exporters))
      (funcall fn)))
  bcp-hymnal--texts)

(defconst bcp-hymnal--text-symbol-list-keys
  '(:tags :appointments :alt-tunes)
  "Keys in the texts file whose values are whitespace-separated
symbol tokens (tags) or symbol/symbol pairs (appointments).")

(defconst bcp-hymnal--text-symbol-keys
  '(:language :tradition :origin-tradition)
  "Keys in the texts file whose value is a single symbol.")

(defun bcp-hymnal--parse-field-value (key value)
  "Coerce VALUE (string) into the right type for KEY.
Special handling: integer strings, bare keywords, symbol lists, and
symbol-pair lists (`a/b c/d' → `((a . b) (c . d))')."
  (cond
   ;; Symbol-list keys
   ((memq key bcp-hymnal--text-symbol-list-keys)
    (let ((tokens (split-string value nil t)))
      (mapcar (lambda (tok)
                (if (string-match-p "/" tok)
                    (let ((parts (split-string tok "/")))
                      (cons (intern (nth 0 parts))
                            (intern (nth 1 parts))))
                  (intern tok)))
              tokens)))
   ;; Single-symbol keys
   ((memq key bcp-hymnal--text-symbol-keys)
    (intern value))
   ;; Integer
   ((string-match "\\`[0-9]+\\'" value)
    (string-to-number value))
   ;; Keyword (value starts with `:')
   ((string-prefix-p ":" value)
    (intern value))
   ;; Default: string
   (t value)))

(defun bcp-hymnal--parse-texts-file (path)
  "Parse PATH, populating `bcp-hymnal--texts'.
File format: blocks separated by `[text-id]' headers, followed by
`:key value' metadata lines, a blank line, then stanza text
(stanzas separated by blank lines)."
  (with-temp-buffer
    (insert-file-contents path)
    (goto-char (point-min))
    (let (id plist stanzas cur-stanza in-stanzas)
      (cl-flet ((flush ()
                  (when id
                    (when cur-stanza
                      (push (string-trim-right
                             (mapconcat #'identity (nreverse cur-stanza) "\n"))
                            stanzas))
                    (setq plist (plist-put plist :stanzas (nreverse stanzas)))
                    (puthash id plist bcp-hymnal--texts))
                  (setq id nil plist nil stanzas nil
                        cur-stanza nil in-stanzas nil)))
        (while (not (eobp))
          (let ((line (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position))))
            (cond
             ((string-match "\\`\\[\\([^]]+\\)\\]\\'" line)
              (flush)
              (setq id (intern (match-string 1 line))))
             ((and (not in-stanzas)
                   (string-match "\\`:\\([-a-z]+\\)\\s-+\\(.*\\)\\'" line))
              (let ((k (intern (concat ":" (match-string 1 line))))
                    (v (match-string 2 line)))
                (setq plist (plist-put plist k
                                       (bcp-hymnal--parse-field-value k v)))))
             ((and id (string-empty-p line))
              (cond (in-stanzas
                     (when cur-stanza
                       (push (string-trim-right
                              (mapconcat #'identity
                                         (nreverse cur-stanza) "\n"))
                             stanzas)
                       (setq cur-stanza nil)))
                    (plist (setq in-stanzas t))))
             (id
              (when in-stanzas
                (push line cur-stanza)))))
          (forward-line 1))
        (flush)))))

(defun bcp-hymnal-text (id)
  "Return plist for text ID, or nil."
  (gethash id (bcp-hymnal--ensure-texts)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Tune registry
;;
;; Tune records are pure metadata (no large content), so stored inline
;; in `bcp-hymnal-tunes.el' rather than externalized.  A tune record:
;;
;;   :name            STRING        (canonical; matches the key)
;;   :meter           STRING
;;   :composer        STRING or nil
;;   :composer-dates  STRING or nil
;;   :first-published INTEGER or nil
;;   :source          STRING or nil ("Plainsong Mode VIII", "Genevan 1551", ...)
;;   :harmonizations  LIST of PLIST (each: :by :dates :first-published :copyright)
;;   :copyright       :public-domain | (:restricted :tune ...)

(defvar bcp-hymnal--tunes (make-hash-table :test 'eq)
  "Hash table mapping tune-id symbols to tune plist records.
Populated by `bcp-hymnal-register-tune'.")

(defun bcp-hymnal-register-tune (id &rest plist)
  "Register a tune with symbol ID and PLIST metadata."
  (puthash id plist bcp-hymnal--tunes))

(defun bcp-hymnal-tune (id)
  "Return plist for tune ID, or nil."
  (gethash id bcp-hymnal--tunes))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Hymnal manifest registry
;;
;; Each hymnal (1940, 1982, English Hymnal, Tate & Brady, ...) registers
;; a manifest: number -> slot-plist.  A slot-plist:
;;
;;   :text           SYMBOL      (text-id in `bcp-hymnal--texts')
;;   :tune           SYMBOL      (tune-id in `bcp-hymnal--tunes')
;;   :tune-alt       LIST SYMBOL (alternate tune ids)
;;   :harmonization  SYMBOL or nil  (harmonization id if separately restricted)
;;   :copyright      override of per-component copyright
;;   :notes          STRING or nil  ("Office Hymn, Compline", etc.)

(defvar bcp-hymnal--manifests nil
  "Alist of (HYMNAL-ID . HASH-TABLE-NUMBER-TO-SLOT).
A hymnal registers via `bcp-hymnal-register-hymnal'.")

(defvar bcp-hymnal--hymnal-info nil
  "Alist of (HYMNAL-ID . INFO-PLIST).
Info-plist keys: :name :year :editor :kind (:hymnal or :psalter).")

(defun bcp-hymnal-register-hymnal (id info entries)
  "Register hymnal ID with INFO plist and ENTRIES alist.
ENTRIES is a list of (NUMBER-STRING . SLOT-PLIST).  NUMBER-STRING
may be \"164b\" or \"\\='150\"; it's preserved as given."
  (setf (alist-get id bcp-hymnal--hymnal-info) info)
  (let ((table (make-hash-table :test 'equal)))
    (dolist (e entries)
      (puthash (car e) (cdr e) table))
    (setf (alist-get id bcp-hymnal--manifests) table)))

(defun bcp-hymnal-lookup (hymnal-id number)
  "Return the slot plist for NUMBER in HYMNAL-ID, or nil.
NUMBER is a string (may include letter suffix: \"164b\")."
  (let ((table (alist-get hymnal-id bcp-hymnal--manifests)))
    (and table (gethash number table))))

(defun bcp-hymnal-info (hymnal-id)
  "Return the info plist for HYMNAL-ID, or nil."
  (alist-get hymnal-id bcp-hymnal--hymnal-info))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Copyright resolution

(defun bcp-hymnal--copyright-restricted-p (status)
  "Return non-nil if STATUS indicates any restricted component."
  (and status (not (eq status :public-domain))))

(defun bcp-hymnal-available-p (hymnal-id number)
  "Return non-nil if HYMNAL-ID/NUMBER can render without restriction.
Checks the slot, its text record, and its tune record.  A slot is
available if all components are PD, or if restricted components
have a counterpart in `bcp-private-data-dir'."
  (let* ((slot (bcp-hymnal-lookup hymnal-id number))
         (text (bcp-hymnal-text (plist-get slot :text)))
         (tune (bcp-hymnal-tune (plist-get slot :tune)))
         (restricted
          (or (bcp-hymnal--copyright-restricted-p
               (plist-get slot :copyright))
              (bcp-hymnal--copyright-restricted-p
               (plist-get text :copyright))
              (bcp-hymnal--copyright-restricted-p
               (plist-get tune :copyright)))))
    (cond
     ((null slot) nil)
     ((not restricted) t)
     ((and bcp-private-data-dir
           (file-exists-p
            (expand-file-name (format "hymnal-%s-%s.el" hymnal-id number)
                              bcp-private-data-dir)))
      t)
     (t nil))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Slot profiles
;;
;; A slot profile names which hymn/anthem slots exist in an Office
;; rendering.  The ordo emits every defined slot position; the profile
;; controls which positions actually render.

(defvar bcp-hymnal--office-slot-profiles
  '((none
     ())

    (anthem-only
     ((after-third-collect :kind anthem :required nil)))

    (opening-and-close
     ((pre-office          :kind hymn)
      (after-third-collect :kind anthem)
      (post-office         :kind hymn)))

    (opening-full
     ((pre-office          :kind hymn)
      (after-psalter       :kind hymn)
      (after-third-collect :kind anthem)
      (after-sermon        :kind hymn)
      (post-office         :kind hymn)))

    (roman-office
     ((office-hymn         :kind hymn   :required t)))

    (monastic-office
     ((office-hymn         :kind hymn   :required t)
      (after-lesson        :kind hymn)
      (after-responsory    :kind hymn))))
  "Registry of office slot profiles.
Each entry: (PROFILE-ID . SLOT-SPEC-LIST).  A slot-spec is a list
(POSITION :kind KIND [:required BOOL]).  Selection policy (whether
the appointed hymn is mandatory, suggested, or ignored) is governed
by `bcp-hymnal-appointment-policy', not the slot profile itself.")

(defun bcp-hymnal-office-slots (profile-id)
  "Return the slot spec list for PROFILE-ID, or nil."
  (cdr (assq profile-id bcp-hymnal--office-slot-profiles)))

(defcustom bcp-hymnal-office-profile 'auto
  "Which hymn slots render in the Daily Office.
Value is a profile id from `bcp-hymnal--office-slot-profiles', or
\\='auto to derive from the active language profile.
Common choices:
  `anthem-only'        — 1662 strict: one anthem after Third Collect.
  `opening-and-close'  — 1662 parish custom with hymn bookends.
  `opening-full'       — 1928 American: five hymn slots.
  `roman-office'       — Roman breviary: fixed office hymn.
  `none'               — no hymn slots."
  :type '(choice (const auto) symbol)
  :group 'bcp-hymnal)

(defun bcp-hymnal-effective-office-profile ()
  "Return the profile id currently in effect.
Resolves \\='auto by inspecting the language profile."
  (if (eq bcp-hymnal-office-profile 'auto)
      (pcase (and (boundp 'bcp-language-profile) bcp-language-profile)
        ('LAT      'roman-office)
        ('ENG      'anthem-only)
        ('ENG-TB   'anthem-only)
        ('ENG-1928 'opening-full)
        ('JAP      'anthem-only)
        (_         'anthem-only))
    bcp-hymnal-office-profile))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Tag system
;;
;; Hymns are tagged with symbols drawn from a controlled vocabulary
;; grouped into axes (season, occasion, hour, slot, character, mood,
;; theme).  Tags attach to text records (not slots): a hymn's character
;; is a property of the text, not of which hymnal prints it.
;;
;; Occasion tags reuse the calendar's day-id vocabulary conceptually
;; but use flat symbols (low-sunday, maundy-thursday, all-saints) for
;; readability; `bcp-hymnal-occasions-for-date' translates a date into
;; a specificity-ordered list of occasion tags.

(defvar bcp-hymnal--tag-axes
  '((season
     . (advent christmas christmastide epiphany epiphanytide
        pre-lent lent passiontide holy-week
        eastertide ascensiontide pentecost-octave trinitytide
        ordinary-time))
    (occasion
     . ( ;; fixed-date feasts
        christmas-eve christmas-day holy-name epiphany-day candlemas
        annunciation transfiguration assumption holy-cross
        st-john-baptist-nativity st-michael st-peter st-mary-magdalene
        st-joseph st-stephen
        all-saints all-souls
        ;; moveable temporal
        ash-wednesday septuagesima sexagesima quinquagesima
        passion-sunday palm-sunday
        maundy-thursday good-friday holy-saturday
        easter-day easter-monday easter-tuesday low-sunday
        rogation ascension-day whitsunday-eve whitsunday
        trinity-sunday corpus-christi sacred-heart christ-the-king
        ;; octaves
        easter-octave christmas-octave
        ;; weeks governed by a Sunday (grow on demand)
        easter-week-1 easter-week-2 easter-week-3
        easter-week-4 easter-week-5 easter-week-6
        ;; fallback
        ferial))
    (hour
     . (matins lauds prime terce sext none vespers compline))
    (slot
     . (pre-office opening opening-anthem office-hymn
        after-psalter after-lesson after-responsory
        after-third-collect after-sermon
        post-office closing recessional anthem))
    (character
     . (communal horizontal theocentric christocentric
        pneumatological marian trinitarian scriptural
        eschatological didactic devotional))
    (mood
     . (jubilant penitential contemplative pastoral
        militant peaceful mournful rejoicing))
    (theme
     . (resurrection paschal incarnation nativity
        passion cross suffering
        holy-spirit paraclete
        second-coming hope judgment
        fellowship love communion-of-saints
        creation providence
        sanctorum saints mary
        baptism
        morning evening night
        heaven glory
        popular)))
  "Controlled tag vocabulary, grouped by axis.
A tag not listed under any axis will be rejected by
`bcp-hymnal--valid-tag-p'.  Grow on demand — add a symbol to the
relevant axis as new hymns drive the need.")

(defvar bcp-hymnal--tag-implications
  '((easter        . (eastertide resurrection paschal))
    (easter-day    . (easter-octave eastertide resurrection paschal))
    (easter-monday . (easter-octave eastertide resurrection paschal))
    (easter-tuesday . (easter-octave eastertide resurrection paschal))
    (low-sunday    . (easter-octave eastertide resurrection paschal))
    (easter-octave . (eastertide resurrection paschal))
    (eastertide    . (resurrection))
    (ascension-day . (ascensiontide eastertide))
    (ascensiontide . (eastertide))
    (whitsunday    . (pentecost-octave holy-spirit paraclete))
    (pentecost-octave . (holy-spirit paraclete))
    (christmas-day . (christmas-octave christmastide incarnation nativity))
    (christmas-eve . (christmastide incarnation nativity))
    (christmas-octave . (christmastide incarnation nativity))
    (christmastide . (incarnation))
    (holy-name     . (christmastide))
    (epiphany-day  . (epiphanytide))
    (candlemas     . (christmastide))
    (advent        . (hope second-coming))
    (ash-wednesday . (lent penitential))
    (passion-sunday . (passiontide passion cross))
    (palm-sunday   . (passiontide holy-week passion cross))
    (maundy-thursday . (holy-week passion fellowship))
    (good-friday   . (holy-week passion cross suffering mournful))
    (holy-saturday . (holy-week passion))
    (holy-week     . (passiontide passion cross suffering))
    (passiontide   . (lent passion cross))
    (lent          . (penitential))
    (trinity-sunday . (trinitarian))
    (corpus-christi . (eucharist))
    (all-saints    . (sanctorum saints communion-of-saints))
    (all-souls     . (sanctorum communion-of-saints))
    (annunciation  . (mary marian))
    (assumption    . (mary marian))
    (holy-cross    . (cross passion))
    (compline      . (evening night peaceful))
    (vespers       . (evening))
    (lauds         . (morning))
    (matins        . (night)))
  "One-directional tag-implication graph: TAG → list of implied tags.
Expanded at match time by `bcp-hymnal--expand-tags'.  Direction is
specific → general: `low-sunday' implies `eastertide' (and transitively
`resurrection'), not the other way around.")

(defun bcp-hymnal--valid-tag-p (tag)
  "Return non-nil if TAG is a registered vocabulary symbol."
  (seq-some (lambda (axis) (memq tag (cdr axis)))
            bcp-hymnal--tag-axes))

(defun bcp-hymnal--expand-tags (tags)
  "Return TAGS expanded through the implication graph.
Transitive closure; duplicates removed; order undefined."
  (let ((seen (copy-sequence tags))
        (queue (copy-sequence tags)))
    (while queue
      (let ((implied (cdr (assq (pop queue) bcp-hymnal--tag-implications))))
        (dolist (i implied)
          (unless (memq i seen)
            (push i seen)
            (push i queue)))))
    seen))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Occasion translator — date → specificity-ordered occasion tags

(defvar bcp-hymnal--fixed-date-occasions
  '(((12 . 25) . christmas-day)
    ((12 . 24) . christmas-eve)
    ((12 . 26) . st-stephen)
    ((1  .  1) . holy-name)
    ((1  .  6) . epiphany-day)
    ((2  .  2) . candlemas)
    ((3  . 25) . annunciation)
    ((5  . 31) . visitation)
    ((6  . 24) . st-john-baptist-nativity)
    ((6  . 29) . st-peter)
    ((7  . 22) . st-mary-magdalene)
    ((8  .  6) . transfiguration)
    ((8  . 15) . assumption)
    ((9  . 14) . holy-cross)
    ((9  . 29) . st-michael)
    ((11 .  1) . all-saints)
    ((11 .  2) . all-souls)
    ((3  . 19) . st-joseph))
  "Alist of ((MONTH . DAY) . OCCASION-SYMBOL) for fixed feasts.")

(defun bcp-hymnal--occasions-superset (date)
  "Return EVERY occasion any tradition recognizes for DATE.
This is the maximal set: 1662 + 1928 + Roman pre-1955 fixed feasts
and standard temporal moveables, in specificity order.  Calendar
translators (`bcp-hymnal--occasions-anglican-1662' etc.) project
this down to a tradition-specific subset.  Direct callers should
use `bcp-hymnal-occasions-for-date', not this function."
  (let* ((month (nth 0 date))
         (day   (nth 1 date))
         (year  (nth 2 date))
         ;; push in narrative order (specific first → tail); nreverse
         ;; at end so specific ends up at HEAD.  See `push' LIFO.
         (tags nil)
         (feasts      (bcp-moveable-feasts year))
         (abs         (calendar-absolute-from-gregorian date))
         (easter-abs  (calendar-absolute-from-gregorian
                       (cdr (assq 'easter feasts))))
         (ash-abs     (calendar-absolute-from-gregorian
                       (cdr (assq 'ash-wednesday feasts))))
         (palm-abs    (- easter-abs 7))
         (passion-abs (- easter-abs 14))
         (whitsun-abs (+ easter-abs 49))
         (ascension-abs (+ easter-abs 39))
         (trinity-abs (+ easter-abs 56)))
    ;; --- Specific-day occasions (push first so they end up at head) ---
    ;; Fixed-date feasts
    (let ((occ (cdr (assoc (cons month day) bcp-hymnal--fixed-date-occasions))))
      (when occ (push occ tags)))
    ;; Moveable specific days
    (cond
     ((= abs easter-abs)        (push 'easter-day tags))
     ((= abs (1+ easter-abs))   (push 'easter-monday tags))
     ((= abs (+ easter-abs 2))  (push 'easter-tuesday tags))
     ((= abs (+ easter-abs 7))  (push 'low-sunday tags))
     ((= abs (- easter-abs 1))  (push 'holy-saturday tags))
     ((= abs (- easter-abs 2))  (push 'good-friday tags))
     ((= abs (- easter-abs 3))  (push 'maundy-thursday tags))
     ((= abs palm-abs)          (push 'palm-sunday tags))
     ((= abs passion-abs)       (push 'passion-sunday tags))
     ((= abs ash-abs)           (push 'ash-wednesday tags))
     ((= abs ascension-abs)     (push 'ascension-day tags))
     ((= abs whitsun-abs)       (push 'whitsunday tags))
     ((= abs trinity-abs)       (push 'trinity-sunday tags)))
    ;; --- Mid-specificity: octaves / weeks / holy-week ---
    (when (and (>= abs palm-abs) (< abs easter-abs))
      (push 'holy-week tags))
    (when (and (>= abs easter-abs) (<= abs (+ easter-abs 7)))
      (push 'easter-octave tags))
    (when (and (>= abs whitsun-abs) (<= abs (+ whitsun-abs 7)))
      (push 'pentecost-octave tags))
    (when (and (>= abs (calendar-absolute-from-gregorian (list 12 25 year)))
               (<= abs (calendar-absolute-from-gregorian (list 12 31 year))))
      (push 'christmas-octave tags))
    ;; Easter weeks 1..6, numbered per 1662/Roman convention: Low
    ;; Sunday begins week 1.  Easter Day through Easter Saturday is
    ;; the Octave only (no week-N tag).
    (when (and (>= abs (+ easter-abs 7)) (< abs whitsun-abs))
      (let* ((days-after-low-sunday (- abs easter-abs 7))
             (week (1+ (/ days-after-low-sunday 7))))
        (when (<= week 6)
          (push (intern (format "easter-week-%d" week)) tags))))
    ;; --- Season (least specific; pushed last → tail) ---
    (let ((season (and (fboundp 'bcp-1662-liturgical-season)
                       (bcp-1662-liturgical-season month day year))))
      (pcase season
        ('advent      (push 'advent tags))
        ('christmas   (push 'christmastide tags))
        ('epiphany    (push 'epiphanytide tags))
        ('pre-lent    (push 'pre-lent tags))
        ('lent        (push 'lent tags))
        ('passiontide (push 'passiontide tags))
        ('eastertide  (push 'eastertide tags))
        ('trinity     (push 'trinitytide tags))))
    ;; `push' LIFO: things pushed first are now at the tail.  Specific
    ;; feasts were pushed first → at tail; reverse to bring them to head.
    (nreverse tags)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Calendar dispatch
;;
;; The day a feast is observed depends on whose calendar is consulted.
;; A strict-1662 user does not keep Sacred Heart, Corpus Christi,
;; Christ the King, the Assumption, the Transfiguration, St Joseph,
;; or post-1662 commemorations as red-letter days; a 1662 user with
;; an Anglo-Catholic supplemental kalendar may keep some or all of
;; them.  The hymn selector therefore consults the calendar in effect
;; for the Office being rendered, not a fixed canonical calendar.
;;
;; Each calendar registers a translator function (date → occasion-tag
;; list) under a calendar id.  The defcustom `bcp-hymnal-calendar'
;; selects which translator to use; `auto' picks based on
;; `bcp-language-profile'.

(defvar bcp-hymnal--calendar-translators nil
  "Alist of (CALENDAR-ID . FN).
FN takes a date (MONTH DAY YEAR) and returns a specificity-ordered
list of occasion tag symbols recognized by that calendar.
Register via `bcp-hymnal-register-calendar'.")

(defun bcp-hymnal-register-calendar (id fn)
  "Register FN as the date→occasion translator for CALENDAR-ID."
  (setf (alist-get id bcp-hymnal--calendar-translators) fn))

(defcustom bcp-hymnal-calendar 'auto
  "Calendar consulted for date→occasion translation in hymn selection.
Must be a calendar id registered via `bcp-hymnal-register-calendar',
or `auto' to derive from `bcp-language-profile':
  LAT      → roman-pre-1955
  ENG-1928 → anglican-1928
  others   → anglican-1662
A 1662 user with a supplemental kalendar that lists Pope Pius V or
the Sacred Heart can register a custom calendar id and bind this
variable to it; the hymn selector will then surface those feasts."
  :type '(choice (const auto) symbol)
  :group 'bcp-hymnal)

(defun bcp-hymnal-effective-calendar ()
  "Resolve `bcp-hymnal-calendar' to a concrete calendar id."
  (if (eq bcp-hymnal-calendar 'auto)
      (pcase (and (boundp 'bcp-language-profile) bcp-language-profile)
        ('LAT      'roman-pre-1955)
        ('ENG-1928 'anglican-1928)
        (_         'anglican-1662))
    bcp-hymnal-calendar))

(defun bcp-hymnal-occasions-for-date (date &optional calendar)
  "Return occasion tags for DATE per CALENDAR, most specific first.
DATE is (MONTH DAY YEAR).  CALENDAR defaults to
`bcp-hymnal-effective-calendar'.  If no translator is registered
for that calendar id, returns the maximal superset."
  (let* ((cal (or calendar (bcp-hymnal-effective-calendar)))
         (fn  (alist-get cal bcp-hymnal--calendar-translators)))
    (if fn
        (funcall fn date)
      (bcp-hymnal--occasions-superset date))))

;; --- Built-in calendar translators ------------------------------------------
;;
;; These are minimal v1 filters over the superset.  As each tradition's
;; calendar module grows a richer feast set, the translator can be moved
;; into that module and the registration relocated.

(defconst bcp-hymnal--occasions-non-1662
  '(transfiguration assumption holy-cross st-joseph
    sacred-heart corpus-christi christ-the-king
    visitation st-mary-magdalene)
  "Occasion tags for feasts not in the 1662 BCP red-letter calendar.")

(defconst bcp-hymnal--occasions-non-1928
  '(assumption sacred-heart corpus-christi christ-the-king st-joseph)
  "Occasion tags for feasts not in the 1928 American BCP calendar.
The 1928 BCP added Transfiguration, Holy Cross is also kept; St
Mary Magdalene appears in the calendar (without proper).")

(defun bcp-hymnal--occasions-anglican-1662 (date)
  "Anglican-1662 occasion tags: superset minus non-1662 feasts."
  (cl-remove-if (lambda (tag)
                  (memq tag bcp-hymnal--occasions-non-1662))
                (bcp-hymnal--occasions-superset date)))

(defun bcp-hymnal--occasions-anglican-1928 (date)
  "Anglican-1928 occasion tags: superset minus non-1928 feasts."
  (cl-remove-if (lambda (tag)
                  (memq tag bcp-hymnal--occasions-non-1928))
                (bcp-hymnal--occasions-superset date)))

(defun bcp-hymnal--occasions-roman-pre-1955 (date)
  "Roman pre-1955 occasions: superset plus Roman moveable feasts.
Adds Corpus Christi (Thursday after Trinity Sunday), Sacred Heart
(Friday after Corpus Christi octave), and Christ the King (last
Sunday of October per Quas primas, 1925)."
  (let* ((tags  (bcp-hymnal--occasions-superset date))
         (year  (nth 2 date))
         (abs   (calendar-absolute-from-gregorian date))
         (feasts (bcp-moveable-feasts year))
         (easter-abs (calendar-absolute-from-gregorian
                     (cdr (assq 'easter feasts)))))
    (cond
     ((= abs (+ easter-abs 60)) (push 'corpus-christi tags))
     ((= abs (+ easter-abs 68)) (push 'sacred-heart tags)))
    (let* ((oct-31     (list 10 31 year))
           (oct-31-abs (calendar-absolute-from-gregorian oct-31))
           (oct-31-dow (calendar-day-of-week oct-31))
           (ctk-abs    (- oct-31-abs oct-31-dow)))
      (when (= abs ctk-abs) (push 'christ-the-king tags)))
    tags))

(bcp-hymnal-register-calendar 'anglican-1662
                              #'bcp-hymnal--occasions-anglican-1662)
(bcp-hymnal-register-calendar 'anglican-1928
                              #'bcp-hymnal--occasions-anglican-1928)
(bcp-hymnal-register-calendar 'roman-pre-1955
                              #'bcp-hymnal--occasions-roman-pre-1955)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Appointment policy

(defcustom bcp-hymnal-appointment-policy
  '((office-hymn . suggest)
    (default     . suggest))
  "Per-slot-kind alist controlling how rubric appointments are honoured.
Each entry is (SLOT-KIND . POLICY).  The special key `default'
applies to slot-kinds not explicitly listed.

POLICY values:
- `appointed': rubrical appointment wins; no picker is shown, the
  appointed hymn fills the slot (Pian rigorist mode).
- `suggest':   appointed hymn heads the picker, tier-matches follow.
- `free':      appointments ignored; slot is a tier-matched pool."
  :type '(alist :key-type symbol
                :value-type (choice (const appointed)
                                    (const suggest)
                                    (const free)))
  :group 'bcp-hymnal)

(defun bcp-hymnal-policy-for-slot (slot-kind)
  "Return the appointment policy for SLOT-KIND.
Falls back to `default' entry, then to `suggest'."
  (or (cdr (assq slot-kind bcp-hymnal-appointment-policy))
      (cdr (assq 'default bcp-hymnal-appointment-policy))
      'suggest))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matcher / selector (v1)
;;
;; `bcp-hymnal-select' takes a context (date, slot-kind, language,
;; tradition hint) and returns text-ids ranked by: appointment status,
;; occasion tier, popular tag, alphabetical.  Consumers may call it
;; with policy-override if they want to force `appointed' for a
;; one-off render.

(defun bcp-hymnal--all-text-ids ()
  "Return a list of every known text-id (loads texts if needed)."
  (let ((table (bcp-hymnal--ensure-texts))
        ids)
    (maphash (lambda (k _v) (push k ids)) table)
    ids))

(defun bcp-hymnal--text-language-matches (text lang)
  "Return non-nil if TEXT's :language matches LANG, or LANG is nil."
  (or (null lang)
      (let ((tl (plist-get text :language)))
        (or (eq tl lang)
            (and (stringp tl) (eq (intern tl) lang))))))

(defun bcp-hymnal--appointment-matches (text slot-kind occasion-tags)
  "Return non-nil if TEXT is rubrically appointed for SLOT-KIND on any
of OCCASION-TAGS.  Appointment format: ((SLOT-KIND . OCCASION) ...)."
  (let ((apps (plist-get text :appointments)))
    (cl-some (lambda (a)
               (and (eq (car a) slot-kind)
                    (memq (cdr a) occasion-tags)))
             apps)))

(defun bcp-hymnal--best-tier (text occasion-tags)
  "Return the lowest (best) tier index at which TEXT's expanded tags
match OCCASION-TAGS, or nil if no match.  Tier = position in
OCCASION-TAGS (0 = most specific).  A hymn with no occasion-class
tags still matches the broadest tier if its expansion intersects."
  (let ((expanded (bcp-hymnal--expand-tags (plist-get text :tags))))
    (cl-loop for occ in occasion-tags
             for i from 0
             when (memq occ expanded) return i)))

(defun bcp-hymnal-select (&rest args)
  "Return a ranked list of text-ids for the requested context.
Keyword ARGS:
  :date        (MONTH DAY YEAR) — drives occasion tagging
  :calendar    CALENDAR-ID — override `bcp-hymnal-effective-calendar'
  :occasion    OCCASION-TAG or list of tags — if set, bypasses :date
  :slot-kind   SYMBOL (office-hymn / closing / anthem / ...)
  :language    SYMBOL (english / latin / japanese / ...)
  :extra-tags  LIST of tag symbols a candidate must match (AND)
  :policy      override for `bcp-hymnal-policy-for-slot'

Returns a list of text-ids in rank order.  If policy is `appointed'
and any candidate is rubrically appointed, only those are returned."
  (let* ((date       (plist-get args :date))
         (calendar   (plist-get args :calendar))
         (occ-arg    (plist-get args :occasion))
         (occ-tags   (cond
                      ((and occ-arg (listp occ-arg)) occ-arg)
                      (occ-arg (list occ-arg))
                      (date (bcp-hymnal-occasions-for-date date calendar))
                      (t nil)))
         (slot-kind  (plist-get args :slot-kind))
         (language   (plist-get args :language))
         (extra-tags (plist-get args :extra-tags))
         (policy     (or (plist-get args :policy)
                         (and slot-kind (bcp-hymnal-policy-for-slot slot-kind))))
         (texts      (bcp-hymnal--ensure-texts))
         ranked)
    (maphash
     (lambda (id text)
       (when (bcp-hymnal--text-language-matches text language)
         (let* ((expanded  (bcp-hymnal--expand-tags (plist-get text :tags)))
                (appointed (and slot-kind
                                (bcp-hymnal--appointment-matches
                                 text slot-kind occ-tags)))
                (tier      (bcp-hymnal--best-tier text occ-tags))
                (popular   (memq 'popular expanded))
                (extra-ok  (cl-every (lambda (t_) (memq t_ expanded))
                                     extra-tags)))
           (when extra-ok
             ;; Occasion is a ranking signal, not a filter: candidates
             ;; with no tier match fall to the deepest tier but still
             ;; appear.  Language and extra-tags do the filtering.
             (push (list :id id
                         :appointed appointed
                         :tier (or tier 9999)
                         :popular popular
                         :first-line (plist-get text :first-line))
                   ranked)))))
     texts)
    ;; Apply policy filter
    (when (and (eq policy 'appointed)
               (cl-some (lambda (c) (plist-get c :appointed)) ranked))
      (setq ranked (cl-remove-if-not
                    (lambda (c) (plist-get c :appointed)) ranked)))
    (when (eq policy 'free)
      (setq ranked (mapcar (lambda (c) (plist-put c :appointed nil)) ranked)))
    ;; Sort: appointed first, then tier ascending, then popular, then first-line
    (setq ranked
          (sort ranked
                (lambda (a b)
                  (cond
                   ((and (plist-get a :appointed)
                         (not (plist-get b :appointed))) t)
                   ((and (plist-get b :appointed)
                         (not (plist-get a :appointed))) nil)
                   ((< (plist-get a :tier) (plist-get b :tier)) t)
                   ((> (plist-get a :tier) (plist-get b :tier)) nil)
                   ((and (plist-get a :popular)
                         (not (plist-get b :popular))) t)
                   ((and (plist-get b :popular)
                         (not (plist-get a :popular))) nil)
                   (t (string< (or (plist-get a :first-line) "")
                               (or (plist-get b :first-line) "")))))))
    (mapcar (lambda (c) (plist-get c :id)) ranked)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Bootstrap: load manifests for enabled hymnals

(defun bcp-hymnal--load-enabled ()
  "Load manifest files for every hymnal in `bcp-hymnal-available'."
  (dolist (id bcp-hymnal-available)
    (let ((feat (intern (format "bcp-hymnal-%s" id))))
      (unless (featurep feat)
        (ignore-errors (require feat nil t))))))

(add-hook 'after-init-hook #'bcp-hymnal--load-enabled)

(provide 'bcp-hymnal)
;;; bcp-hymnal.el ends here
