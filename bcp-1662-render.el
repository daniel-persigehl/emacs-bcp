;;; bcp-1662-render.el --- BCP 1662 Office renderer -*- lexical-binding: t -*-

;; Keywords: liturgy, bcp, office, 1662

;;; Commentary:

;; BCP 1662-specific Office renderer.  Depends on bcp-liturgy-render.el
;; for all buffer primitives and calls into it for every buffer operation.
;;
;; This file owns:
;;   - The rubric face (red/comment) and its defcustom
;;   - bcp-1662--rubric-face-fn (passed to bcp-liturgy-render--insert-rubric)
;;   - bcp-1662--render-ordo-step — step-type dispatch for the 1662 ordo format
;;   - bcp-1662--render-office — the main ordo walker with rubrical option logic:
;;       penitential intro omission, venite exception handling,
;;       absolution flow (priest vs. lay/deacon), confession variant,
;;       bidding form, additional prayers, communion propers
;;   - bcp-1662--day-identity — BCP-specific liturgical identity plist
;;   - bcp-1662--season-label — compatibility shim
;;   - bcp-1662--office-label
;;
;; What does NOT live here:
;;   - Shared rendering framework (bcp-render.el)
;;   - Buffer primitives (bcp-liturgy-render.el)
;;   - Ordo plist data (bcp-1662-ordo.el)
;;   - Collect/lesson/propers dispatch (bcp-1662.el)
;;   - Defcustoms for rubrical options (bcp-1662.el)

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-render)
(require 'bcp-liturgy-render)
(require 'bcp-liturgy-canticles)
(require 'bcp-1662-calendar)
(require 'bcp-1662-data)
(require 'bcp-1662-ordo)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Lesson label helpers

(defun bcp-1662--last-verse-in-text (text)
  "Return the last `bcp-verse' property value found in TEXT, or nil."
  (let ((pos 0) (len (length text)) (last nil))
    (while (< pos len)
      (let ((v (get-text-property pos 'bcp-verse text)))
        (when v (setq last v)))
      (setq pos (next-single-property-change pos 'bcp-verse text len)))
    last))

(defun bcp-1662--ref-label-with-text (ref text)
  "Return a display label for REF, appending the actual last verse when known.
When REF specifies a start verse > 1 with no explicit end, scans TEXT for the
highest `bcp-verse' property value and appends it as the end of the range."
  (let* ((v1 (and (listp ref) (stringp (car ref)) (caddr ref)))
         (v2 (and (listp ref) (stringp (car ref)) (cadddr ref))))
    (if (and text v1 (> v1 1) (null v2))
        (let ((last (bcp-1662--last-verse-in-text text)))
          (if last
              (format "%s-%d" (bcp-1662--ref-label ref) last)
            (bcp-1662--ref-label ref)))
      (bcp-1662--ref-label ref))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Rubric face
;;;; ══════════════════════════════════════════════════════════════════════════

(defface bcp-1662-rubric-red
  '((((background light)) :foreground "#8B0000" :height 0.85 :slant italic)
    (((background dark))  :foreground "#CD5C5C" :height 0.85 :slant italic)
    (t                    :foreground "red"     :height 0.85 :slant italic))
  "Face for BCP 1662 rubrics — traditional liturgical red."
  :group 'bcp-1662)

(defface bcp-1662-rubric-comment
  '((t :inherit font-lock-comment-face :height 0.85 :slant italic))
  "Face for BCP 1662 rubrics — muted comment colour."
  :group 'bcp-1662)

(defun bcp-1662--rubric-face ()
  "Return the rubric face according to `bcp-1662-rubric-style'."
  (if (eq bcp-1662-rubric-style 'comment)
      'bcp-1662-rubric-comment
    'bcp-1662-rubric-red))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Thin wrappers that bind the BCP rubric face
;;;; ══════════════════════════════════════════════════════════════════════════
;;
;; These keep call sites inside this file clean.  External callers should
;; use the bcp-liturgy-render-- primitives directly where possible.

(defun bcp-1662--insert-heading (level text)
  "Insert a heading at LEVEL with TEXT."
  (bcp-liturgy-render--insert-heading level text))

(defun bcp-1662--insert-rubric (text)
  "Insert TEXT as a BCP-styled rubric."
  (bcp-liturgy-render--insert-rubric text #'bcp-1662--rubric-face))

(defun bcp-1662--insert-versicles (pairs)
  "Insert versicle PAIRS."
  (bcp-liturgy-render--insert-versicles pairs))

(defun bcp-1662--insert-lords-prayer ()
  "Insert the Lord's Prayer placeholder."
  (bcp-liturgy-render--insert-lords-prayer))


(defun bcp-1662--insert-fixed-text (name text)
  "Insert fixed TEXT identified by NAME."
  (bcp-liturgy-render--insert-fixed-text name text))

(defun bcp-1662--insert-text-block (text)
  "Insert a plain text block."
  (bcp-liturgy-render--insert-text-block text))

(defun bcp-1662--insert-canticle-text (text)
  "Insert canticle TEXT with consistent indent."
  (bcp-liturgy-render--insert-canticle-text text))

(defun bcp-1662--normalise-spacing ()
  "Normalise spacing in the current Office buffer."
  (bcp-liturgy-render--normalise-spacing))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Office and season labels
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1662--office-label (office)
  "Return a display string for OFFICE symbol."
  (if (eq office 'mattins) "Morning Prayer" "Evening Prayer"))

(defun bcp-1662--day-identity (propers)
  "Return a plist describing the liturgical identity of the day in PROPERS.

The plist carries all the ways a day can be named, from most specific
to most general.  The renderer decides which fields to display and how
to format them.  All values are strings or nil.

Keys:
  :day-name       — the specific named day, if any
                    e.g. Passion Sunday, Palm Sunday, Whit Sunday,
                    First Sunday in Advent, Good Friday
  :week-name      — the week within its season
                    e.g. Fifth Week of Lent, Trinity 14
  :subdivision    — ceremonial subdivision of a season, if applicable
                    e.g. Passiontide, Holy Week, Whitsun Week, Octave of Easter
  :season-name    — the broad liturgical season
                    e.g. Lent, Eastertide, Trinity, Advent
  :season-symbol  — the raw season symbol for programmatic use"
  (let* ((season    (plist-get propers :season))
         (week      (plist-get propers :week))
         (date      (plist-get propers :date))
         (is-sunday (when date (= (calendar-day-of-week date) 0)))
         (week-num  (cdr week)))
    (cond

      ((eq season 'advent)
       (let* ((n (or week-num 0))
              (day-name (when is-sunday
                          (pcase n
                            (1 "First Sunday in Advent")
                            (2 "Second Sunday in Advent")
                            (3 "Third Sunday in Advent")
                            (4 "Fourth Sunday in Advent")
                            (_ (format "Sunday in Advent %d" n)))))
              (week-name (when n (format "Advent %d" n))))
         (list :day-name    day-name
               :week-name   week-name
               :subdivision nil
               :season-name "Advent"
               :season-symbol 'advent)))

      ((eq season 'christmas)
       (list :day-name    (when is-sunday "Sunday after Christmas")
             :week-name   nil
             :subdivision nil
             :season-name "Christmas"
             :season-symbol 'christmas))

      ((eq season 'epiphany)
       (let* ((n (or week-num 0))
              (day-name (when is-sunday
                          (if (= n 1) "First Sunday after Epiphany"
                            (format "Sunday after Epiphany %d" n)))))
         (list :day-name    day-name
               :week-name   (when (> n 0) (format "Epiphany %d" n))
               :subdivision nil
               :season-name "Epiphany"
               :season-symbol 'epiphany)))

      ((eq season 'pre-lent)
       (let ((day-name (when is-sunday
                         (pcase week-num
                           (1 "Septuagesima Sunday")
                           (2 "Sexagesima Sunday")
                           (3 "Quinquagesima Sunday")))))
         (list :day-name    day-name
               :week-name   nil
               :subdivision nil
               :season-name "Pre-Lent"
               :season-symbol 'pre-lent)))

      ((eq season 'lent)
       (let* ((n (or week-num 0))
              (day-name
               (cond
                ((and is-sunday (= n 1)) "First Sunday in Lent")
                ((and is-sunday (= n 2)) "Second Sunday in Lent")
                ((and is-sunday (= n 3)) "Third Sunday in Lent (Oculi)")
                ((and is-sunday (= n 4)) "Fourth Sunday in Lent (Laetare)")
                (t nil)))
              (week-name (if (> n 0) (format "Week %d of Lent" n) "Lent")))
         (list :day-name    day-name
               :week-name   week-name
               :subdivision nil
               :season-name "Lent"
               :season-symbol 'lent)))

      ((eq season 'passiontide)
       ;; (lent . 5) = Passion Sunday week; (lent . 6) = Holy Week
       ;; BCP reckons Passiontide as the final two weeks of Lent.
       (let* ((n (or week-num 5))
              (in-holy-week (= n 6))
              (day-name
               (cond
                ((and is-sunday (= n 5)) "Passion Sunday")
                ((and is-sunday (= n 6)) "Palm Sunday")
                (t nil)))
              (week-name
               (if in-holy-week "Holy Week" "Fifth Week of Lent"))
              (subdivision
               (if in-holy-week "Holy Week" "Passiontide")))
         (list :day-name    day-name
               :week-name   week-name
               :subdivision subdivision
               :season-name "Lent"
               :season-symbol 'passiontide)))

      ((eq season 'eastertide)
       (let* ((n (or week-num 0))
              (day-name
               (cond
                ((= n 0) "Easter Day")
                ((and is-sunday (= n 1)) "Low Sunday (Easter I)")
                ((and is-sunday (= n 6)) "Ascension Sunday")
                ((and is-sunday (= n 7)) "Whit Sunday")
                (is-sunday (format "Sunday after Easter %d" n))
                (t nil)))
              (subdivision
               (cond
                ((= n 0) "Easter Octave")
                ((= n 1) "Easter Octave")
                ((= n 7) "Whitsun Week")
                (t nil)))
              (week-name
               (cond
                ((= n 0) "Easter Week")
                ((= n 7) "Whitsun Week")
                ((> n 0) (format "Eastertide %d" n))
                (t "Eastertide"))))
         (list :day-name    day-name
               :week-name   week-name
               :subdivision subdivision
               :season-name "Eastertide"
               :season-symbol 'eastertide)))

      ((eq season 'trinity)
       (let* ((n (or week-num 0))
              (day-name
               (cond
                ((= n 0)  "Trinity Sunday")
                ((= n 25) (when is-sunday "Sunday next before Advent"))
                (is-sunday (format "Trinity %d" n))
                (t nil)))
              (week-name
               (cond
                ((= n 0)  "Trinity Sunday")
                ((= n 25) "Sunday next before Advent")
                ((> n 0)  (format "Trinity %d" n))
                (t "Trinity"))))
         (list :day-name    day-name
               :week-name   week-name
               :subdivision nil
               :season-name "Trinity"
               :season-symbol 'trinity)))

      (t
       (list :day-name    nil
             :week-name   nil
             :subdivision nil
             :season-name (symbol-name season)
             :season-symbol season)))))

(defun bcp-1662--season-label (season week &optional date)
  "Return a single display string for the season/week.
Compatibility shim over `bcp-1662--day-identity' for simple use cases."
  (let* ((fake-propers (list :season season :week week :date date))
         (id   (bcp-1662--day-identity fake-propers))
         (day  (plist-get id :day-name))
         (wk   (plist-get id :week-name))
         (sub  (plist-get id :subdivision))
         (seas (plist-get id :season-name)))
    (or day
        (when sub (format "%s — %s" seas sub))
        wk
        seas)))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Venite helpers
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1662--venite-strip-verses-8-11 (text)
  "Return TEXT with Venite verses 8-11 removed.
Verses 8-11 begin with \"To day if ye will hear\" and end before
verse 12 \"Unto whom I sware\".  Returns TEXT unchanged if not found."
  (if (null text) nil
    (let ((start (string-match "To day if ye will hear" text)))
      (if (null start)
          text
        (let ((end (string-match "Unto whom I sware" text start)))
          (if (null end)
              text
            (concat (substring text 0 start)
                    (substring text end))))))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Step-type renderer
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1662--render-ordo-step (step propers psalms psalm-texts lesson-texts)
  "Render a single ordo STEP using data from PROPERS, PSALMS, PSALM-TEXTS, LESSON-TEXTS."
  (let ((type (car step)))
    (pcase type

      ;; ── Rubric ─────────────────────────────────────────────────────────
      (:rubric
       (when-let* ((text (plist-get step :rubric)))
         (bcp-1662--insert-rubric text)))

      ;; ── Opening sentences ───────────────────────────────────────────────
      (:sentences
       (let ((sents (bcp-1662--select-opening-sentences
                     (plist-get propers :season)
                     (plist-get propers :date)
                     (plist-get propers :office))))
         (dolist (sent sents)
           (if (stringp sent)
               ;; Plain string — seasonal sentence, no citation
               (bcp-1662--insert-text-block sent)
             ;; (TEXT CITATION) pair from the general pool
             (let* ((text  (car sent))
                    (cit   (cadr sent))
                    (label (if (and (listp cit) (listp (car cit)))
                               (mapconcat #'bcp-1662--ref-label cit " / ")
                             (bcp-1662--ref-label cit))))
               (bcp-1662--insert-text-block
                (concat text " — " label)))))))

      ;; ── Fixed text ─────────────────────────────────────────────────────
      (:text
       (let ((name      (plist-get step :text))
             (ref       (plist-get step :ref))
             (alt-creed (plist-get step :alt-creed)))
         (cond
          ((eq name 'lords-prayer)
           (bcp-1662--insert-lords-prayer))
          ;; Creed: swap to Nicene when bcp-liturgy-creed says so and an
          ;; alt-creed ref is present on the step.
          ((and (eq name 'apostles-creed)
                alt-creed
                (eq bcp-liturgy-creed 'nicene))
           (let ((text (symbol-value alt-creed)))
             (bcp-1662--insert-fixed-text
              'nicene-creed
              (if (stringp text) text
                (or (bcp-common-prayers-text text) "")))))
          (ref
           (let ((text (symbol-value ref)))
             (bcp-1662--insert-fixed-text
              (or name (intern (symbol-name ref)))
              (if (stringp text) text
                (or (bcp-common-prayers-text text) "")))))
          (t nil))))

      ;; ── Versicles ──────────────────────────────────────────────────────
      (:versicles
       (bcp-1662--insert-versicles (cdr step)))

      ;; ── Canticle ───────────────────────────────────────────────────────
      (:canticle
       (let* ((name        (plist-get step :canticle))
              (latin-title (plist-get step :latin))
              (exc-easter  (plist-get step :exception-easter))
              (exc-dom     (plist-get step :exception-day-of-month))
              (date        (plist-get propers :date))
              (dom         (cadr date))
              (easter-day  (and exc-easter
                                (eq (plist-get propers :season) 'eastertide)
                                (equal (bcp-1662-easter (caddr date)) date)))
              (dom-except  (and exc-dom (= dom exc-dom))))
         (cond
          ((or easter-day
               (and bcp-1662-easter-anthems-throughout-eastertide
                    (eq (plist-get propers :season) 'eastertide)
                    (eq name 'venite)))
           (bcp-1662--insert-heading 3 "Easter Anthems")
           (when-let* ((text (bcp-1662-collect-text 'easter-anthems)))
             (bcp-1662--insert-canticle-text text)))
          (dom-except nil)
          (t
           (let* ((title    (or latin-title
                                (bcp-liturgy-canticle-title name)
                                (symbol-name name)))
                  (raw-text (bcp-liturgy-canticle-get name))
                  (text     (if (and (eq name 'venite)
                                     bcp-1662-omit-venite-passiontide
                                     (not (memq (plist-get propers :season)
                                                '(lent passiontide))))
                                (bcp-1662--venite-strip-verses-8-11 raw-text)
                              raw-text)))
             (bcp-1662--insert-heading 3 title)
             (insert "\n")
             (if text
                 (progn
                   (bcp-1662--insert-canticle-text text)
                   (when (and bcp-liturgy-canticle-append-gloria
                              (bcp-liturgy-canticle-gloria-p name))
                     (bcp-1662--insert-canticle-text
                      (bcp-liturgy-canticle-gloria-text))))
               (bcp-1662--insert-rubric
                (format "[%s: text not yet available]" title))))))))

      ;; ── Alternatives (Te Deum / Benedicite etc.) ───────────────────────
      (:alternatives
       (let* ((opts  (cl-remove-if #'keywordp
                                   (cl-remove-if-not #'listp (cdr step))))
              (first (car opts))
              (rest  (cdr opts)))
         (when first
           (let* ((name        (plist-get first :canticle))
                  (latin-title (plist-get first :latin))
                  (title       (or latin-title
                                   (bcp-liturgy-canticle-title name)
                                   (symbol-name name))))
             (bcp-1662--insert-heading 3 title)
             (when rest
               (bcp-1662--insert-rubric
                (format "[or: %s]"
                        (mapconcat
                         (lambda (o)
                           (or (plist-get o :latin)
                               (bcp-liturgy-canticle-title (plist-get o :canticle))
                               "alternative"))
                         rest " / "))))
             (let* ((exc-easter (plist-get first :exception-easter))
                    (exc-dom    (plist-get first :exception-day-of-month))
                    (date       (plist-get propers :date))
                    (dom        (cadr date))
                    (easter-day (and exc-easter
                                     (eq (plist-get propers :season) 'eastertide)
                                     (equal (bcp-1662-easter (caddr date)) date)))
                    (dom-except (and exc-dom (= dom exc-dom)))
                    (raw-text   (bcp-liturgy-canticle-get name))
                    (text       (if (and (eq name 'venite)
                                         bcp-1662-omit-venite-passiontide
                                         (not (memq (plist-get propers :season)
                                                    '(lent passiontide))))
                                    (bcp-1662--venite-strip-verses-8-11 raw-text)
                                  raw-text)))
               (cond
                ((or easter-day
                     (and bcp-1662-easter-anthems-throughout-eastertide
                          (eq (plist-get propers :season) 'eastertide)
                          (eq name 'venite)))
                 (when-let* ((at (bcp-1662-collect-text 'easter-anthems)))
                   (bcp-1662--insert-canticle-text at)))
                (dom-except nil)
                (text
                 (bcp-1662--insert-canticle-text text)
                 (when (and bcp-liturgy-canticle-append-gloria
                            (bcp-liturgy-canticle-gloria-p name))
                   (bcp-1662--insert-canticle-text
                    (bcp-liturgy-canticle-gloria-text))))
                (t
                 (bcp-1662--insert-rubric
                  (format "[%s: text not yet available]" title)))))))))

      ;; ── Psalm slot ─────────────────────────────────────────────────────
      (:psalm
       (dolist (p psalms)
         (let* ((key  (bcp-1662--psalm-label p))
                (text (cdr (assoc key psalm-texts))))
           (bcp-1662--insert-heading 3 key)
           (if text
               (progn
                 (bcp-1662--insert-text-block text)
                 (when bcp-liturgy-canticle-append-gloria
                   (bcp-1662--insert-text-block
                    (bcp-liturgy-canticle-gloria-text))))
             (insert (format "[[bible:%s][%s]]\n\n"
                             (bcp-1662--psalm-to-passage p) key))))))

      ;; ── Lesson slot ────────────────────────────────────────────────────
      (:lesson
       (let* ((which   (plist-get step :lesson))
              (key     (if (eq which 'second) "lesson2" "lesson1"))
              (lessons (plist-get propers :lessons))
              (ref     (plist-get lessons (if (eq which 'second)
                                              :lesson2 :lesson1)))
              (text    (cdr (assoc key lesson-texts))))
         (when ref
           (let ((label (bcp-1662--ref-label-with-text ref text)))
             (bcp-1662--insert-heading 3
               (format "%s Lesson: %s"
                       (if (eq which 'second) "Second" "First")
                       label))
             (if text
                 (bcp-1662--insert-text-block text)
               (insert (format "[[bible:%s][%s]]\n\n"
                               (bcp-1662--lectionary-ref-to-string ref)
                               label)))))))

      ;; ── Collect slot ───────────────────────────────────────────────────
      (:collect
       (let* ((which (plist-get step :collect))
              (ref   (plist-get step :ref)))
         (cond
          ((eq which 'day)
           (let* ((sym  (plist-get propers :collect))
                  (text (when sym (bcp-1662-collect-text sym))))
             (bcp-1662--insert-heading 3 "Collect of the Day")
             (if text
                 (insert text "\n")
               (insert (format ";; [collect for %s]\n\n"
                               (or sym "unknown"))))
             (when-let* ((sc  (plist-get propers :seasonal-collect))
                         (sct (bcp-1662-collect-text sc)))
               (bcp-1662--insert-rubric
                (pcase sc
                  ('advent-1      "The Collect of Advent (said daily until Christmas Eve):")
                  ('ash-wednesday "The Collect of Ash Wednesday (said daily throughout Lent):")
                  (_              "Seasonal Collect:")))
               (bcp-1662--insert-fixed-text 'seasonal-collect sct))))
          (ref
           (let* ((data  (symbol-value ref))
                  (title (plist-get data :title))
                  (text  (bcp-common-prayers-text data)))
             (bcp-1662--insert-heading 3 (or title "Collect"))
             (when text (insert text "\n")))))))

      ;; ── Anthem ─────────────────────────────────────────────────────────
      (:anthem
       (bcp-1662--insert-rubric
        (or (plist-get step :rubric)
            "In Quires and Places where they sing here followeth the Anthem.")))

      ;; ── Prayer slot ────────────────────────────────────────────────────
      (:prayer
       (let* ((ref   (plist-get step :ref))
              (data  (when ref (symbol-value ref)))
              (title (when data (plist-get data :title)))
              (text  (when data (bcp-common-prayers-text data))))
         (bcp-1662--insert-heading 3 (or title "Prayer"))
         (when text
           (bcp-1662--insert-fixed-text
            (or (plist-get step :prayer) (intern (symbol-name ref)))
            text))))

      ;; ── State versicle (region-resolved) ───────────────────────────────
      (:state-versicles
       (let ((tradition (plist-get step :tradition)))
         (bcp-1662--insert-versicles
          (list (bcp-liturgy-state-versicles tradition)))))

      ;; ── State prayers (region-resolved) ────────────────────────────────
      (:state-prayers
       (let ((tradition (plist-get step :tradition)))
         (dolist (prayer (bcp-liturgy-state-prayers tradition))
           (let* ((title (plist-get prayer :title))
                  (text  (bcp-common-prayers-text prayer)))
             (bcp-1662--insert-heading 3 (or title "Prayer"))
             (when text
               (bcp-1662--insert-fixed-text
                (or (plist-get prayer :name) 'state-prayer)
                text))))))

      ;; ── Unknown — ignore silently ───────────────────────────────────────
      (_ nil))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Main ordo walker
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1662--render-office (propers psalms psalm-texts date-str lesson-texts)
  "Render the BCP 1662 Office buffer.

Walks `bcp-1662-ordo-morning' or `bcp-1662-ordo-evening' in order,
applying rubrical options and filling variable slots from PROPERS,
PSALMS, PSALM-TEXTS, and LESSON-TEXTS."
  (let* ((office       (plist-get propers :office))
         (feast-name   (plist-get propers :feast-name))
         (feast-rank   (plist-get propers :feast-rank))
         (ordo         (if (eq office 'mattins)
                           bcp-1662-ordo-morning
                         bcp-1662-ordo-evening))
         (office-label (bcp-1662--office-label office))
         (day-id       (bcp-1662--day-identity propers))
         (communion-sym (plist-get propers :communion))
         (ot-ref        (plist-get propers :ot-reading)))
    (with-current-buffer
        (bcp-liturgy-render--setup-buffer bcp-1662-office-buffer-name)

      ;; ── Title ────────────────────────────────────────────────────────
      (bcp-1662--insert-heading 1
        (format "%s — %s" office-label date-str))

      ;; ── Liturgical identity block ────────────────────────────────────
      (bcp-liturgy-render--insert-identity-block day-id feast-name feast-rank)
      (insert "\n")

      ;; ── Ordo walk ────────────────────────────────────────────────────
      (let* ((season     (plist-get propers :season))
             (is-sunday  (= (calendar-day-of-week (plist-get propers :date)) 0))
             (is-weekday (not is-sunday))
             (show-penit (not (and bcp-1662-omit-penitential-intro is-weekday)))
             (past-venite nil))

        (dolist (step ordo)
          (let ((type       (car step))
                (pos-before (point)))
            (cond
             ;; Penitential intro omission: skip rubrics, sentences, and
             ;; fixed texts before the opening versicles
             ((and (not show-penit) (not past-venite)
                   (memq type '(:rubric :sentences :text)))
              nil)
             ;; Opening versicles end the penitential section
             ((and (not show-penit) (not past-venite)
                   (eq type :versicles))
              (setq past-venite t)
              (bcp-1662--render-ordo-step
               step propers psalms psalm-texts lesson-texts))
             ;; General Confession — honour confession form option
             ((and (eq type :text)
                   (eq (plist-get step :text) 'general-confession))
              (pcase bcp-1662-general-confession-form
                ('omit nil)
                ('variant
                 (bcp-1662--insert-fixed-text
                  'general-confession
                  bcp-1662-text-general-confession-variant))
                (_
                 (bcp-1662--render-ordo-step
                  step propers psalms psalm-texts lesson-texts))))
             ;; Exhortation (Bidding) — honour bidding form option
             ((and (eq type :text)
                   (eq (plist-get step :text) 'exhortation))
              (pcase bcp-1662-bidding-form
                ('full
                 (bcp-1662--render-ordo-step
                  step propers psalms psalm-texts lesson-texts))
                ('brief
                 (if bcp-1662-bidding-brief
                     (bcp-1662--insert-fixed-text
                      'exhortation bcp-1662-bidding-brief)
                   (bcp-1662--render-ordo-step
                    step propers psalms psalm-texts lesson-texts)))
                ('omit nil)))
             ;; General Confession rubric — suppress if confession is omitted
             ((and (eq type :rubric)
                   (string-match-p "general Confession"
                                   (or (plist-get step :rubric) "")))
              (unless (eq bcp-1662-general-confession-form 'omit)
                (bcp-1662--render-ordo-step
                 step propers psalms psalm-texts lesson-texts)))
             ;; "No priest" rubric — suppressed here; rendered via absolution handler
             ((and (eq type :rubric)
                   (plist-get step :alt-collect))
              nil)
             ;; Absolution rubric — priest/bishop only
             ((and (eq type :rubric)
                   (string-match-p "Absolution\\|Remission of sins"
                                   (or (plist-get step :rubric) "")))
              (when (memq office-officiant '(priest bishop))
                (bcp-1662--render-ordo-step
                 step propers psalms psalm-texts lesson-texts)))
             ;; Absolution text — priest gets absolution; lay/deacon gets
             ;; the "no priest" rubric then the Trinity 21 collect
             ((and (eq type :text)
                   (eq (plist-get step :text) 'absolution))
              (if (memq office-officiant '(priest bishop))
                  (bcp-1662--render-ordo-step
                   step propers psalms psalm-texts lesson-texts)
                (let ((no-priest-step
                       (cl-find-if (lambda (s) (plist-get s :alt-collect))
                                   ordo)))
                  (when no-priest-step
                    (bcp-1662--render-ordo-step
                     no-priest-step propers psalms psalm-texts lesson-texts))
                  (let ((text (bcp-1662-collect-text 'trinity-21)))
                    (if text
                        (bcp-1662--insert-fixed-text 'absolution text)
                      (bcp-1662--insert-rubric
                       "[Collect for the Twenty-First Sunday after Trinity]"))))))
             ;; All other steps
             (t
              (setq past-venite t)
              (bcp-1662--render-ordo-step
               step propers psalms psalm-texts lesson-texts)))
            ;; Blank line after each step that produced output
            (when (> (point) pos-before)
              (insert "\n"))))

        ;; Additional prayers
        (when bcp-1662-additional-prayers
          (dolist (prayer bcp-1662-additional-prayers)
            (cond
             ((stringp prayer)
              (bcp-1662--insert-fixed-text 'additional-prayer prayer))
             ((symbolp prayer)
              (let ((data (and (boundp prayer) (symbol-value prayer))))
                (when data
                  (bcp-1662--insert-heading 3
                    (or (plist-get data :title) (symbol-name prayer)))
                  (bcp-1662--insert-fixed-text
                   prayer (plist-get data :text)))))))))

      ;; ── Communion propers ────────────────────────────────────────────
      (when (and bcp-1662-show-communion-propers communion-sym)
        (bcp-1662--insert-heading 2 "Communion Propers")
        (when ot-ref
          (let* ((label (bcp-1662--ref-label ot-ref))
                 (text  (cdr (assoc "ot" lesson-texts))))
            (bcp-1662--insert-heading 3 (format "OT Lesson: %s" label))
            (if text
                (bcp-1662--insert-text-block text)
              (insert (format "[[bible:%s][%s]]\n\n"
                              (bcp-1662--lectionary-ref-to-string ot-ref)
                              label)))))
        (when-let* ((cp (bcp-1662-communion-propers communion-sym))
                    (ep (plist-get cp :epistle))
                    (go (plist-get cp :gospel)))
          (let* ((ep-label (bcp-1662--ref-label ep))
                 (go-label (bcp-1662--ref-label go))
                 (ep-text  (cdr (assoc "epistle" lesson-texts)))
                 (go-text  (cdr (assoc "gospel"  lesson-texts))))
            (bcp-1662--insert-heading 3 (format "Epistle: %s" ep-label))
            (if ep-text
                (bcp-1662--insert-text-block ep-text)
              (insert (format "[[bible:%s][%s]]\n\n"
                              (bcp-1662--lectionary-ref-to-string ep) ep-label)))
            (bcp-1662--insert-heading 3 (format "Gospel: %s" go-label))
            (if go-text
                (bcp-1662--insert-text-block go-text)
              (insert (format "[[bible:%s][%s]]\n\n"
                              (bcp-1662--lectionary-ref-to-string go)
                              go-label))))))

      ;; ── Finalise ─────────────────────────────────────────────────────
      (bcp-reader--add-verse-number-overlays)
      (when bcp-reader-paragraph-mode
        (bcp-reader--add-paragraph-overlays))
      (bcp-liturgy-render--finalise-buffer)
      (current-buffer))))


(provide 'bcp-1662-render)
;;; bcp-1662-render.el ends here
