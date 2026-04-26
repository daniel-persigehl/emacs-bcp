;;; bcp-1662-render.el --- BCP 1662 Office renderer -*- lexical-binding: t -*-

;; Keywords: liturgy, bcp, office, 1662

;;; Commentary:

;; BCP 1662-specific Office renderer.  Builds a tradition context (ctx) and
;; delegates the shared step dispatch and ordo walk to bcp-anglican-render.el.
;;
;; This file owns:
;;   - Rubric face (red/comment) and its defcustom
;;   - bcp-1662--rubric-face     — :rubric-face-fn for the ctx
;;   - bcp-1662--day-identity    — 1662-specific liturgical identity plist
;;   - bcp-1662--season-label    — compatibility shim
;;   - bcp-1662--venite-strip-verses-8-11 — low-level Venite text editor
;;   - bcp-1662--venite-filter   — :venite-filter-fn for the ctx
;;   - bcp-1662--seasonal-collect-rubric — :seasonal-collect-rubric-fn for the ctx
;;   - bcp-1662--easter-anthems-p — :easter-anthems-p-fn for the ctx
;;   - bcp-1662--no-priest-rubric — :absolution-no-priest-rubric-fn for the ctx
;;   - bcp-1662--step-override   — :step-override-fn (bidding, confession options)
;;   - bcp-1662--post-office     — :post-office-fn (communion propers)
;;   - bcp-1662--build-ctx       — assembles the full tradition context
;;   - bcp-1662--render-office   — thin wrapper calling the shared walker
;;
;; What does NOT live here:
;;   - Buffer primitives (bcp-liturgy-render.el)
;;   - Shared step dispatch and ordo walker (bcp-anglican-render.el)
;;   - Ordo plist data (bcp-1662-ordo.el)
;;   - Collect/lesson/propers dispatch and ref utilities (bcp-1662.el)
;;   - Defcustoms for rubrical options (bcp-1662.el)

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-render)
(require 'bcp-liturgy-render)
(require 'bcp-common-canticles)
(require 'bcp-anglican-render)
(require 'bcp-1662-calendar)
(require 'bcp-1662-data)
(require 'bcp-1662-ordo)

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
;;;; Day identity and season labels
;;;; ══════════════════════════════════════════════════════════════════════════

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

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Tradition context helpers
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1662--venite-filter (text season)
  "Apply Venite vv.8–11 handling for the 1662 tradition.
Delegates to `bcp-anglican--venite-filter' with `bcp-1662-venite-lent-verses'
and `bcp-1662-venite-ps96-substitute'."
  (bcp-anglican--venite-filter text season
    bcp-1662-venite-lent-verses
    bcp-1662-venite-ps96-substitute))

(defun bcp-1662--seasonal-collect-rubric (sc)
  "Return the rubric string for seasonal collect SC."
  (pcase sc
    ('advent-1      "The Collect of Advent (said daily until Christmas Eve):")
    ('ash-wednesday "The Collect of Ash Wednesday (said daily throughout Lent):")
    (_              "Seasonal Collect:")))

(defun bcp-1662--easter-anthems-p (propers)
  "Return t if Easter Anthems should replace the Venite."
  (let* ((date   (plist-get propers :date))
         (season (plist-get propers :season))
         (year   (caddr date))
         (easter (and date (bcp-1662-easter year))))
    (or (and easter (equal easter date))
        (and bcp-1662-easter-anthems-throughout-eastertide
             (eq season 'eastertide)))))

(defun bcp-1662--no-priest-rubric (ordo)
  "Return the 'no priest' rubric text found in ORDO, or nil.
This rubric (whose step carries :alt-collect) is suppressed in the main
ordo walk and re-emitted before the lay absolution substitute."
  (when-let* ((step (cl-find-if (lambda (s) (plist-get s :alt-collect)) ordo)))
    (plist-get step :rubric)))

(defun bcp-1662--step-override (step _propers)
  "Handle 1662-specific rubrical options for STEP.
Returns :skip (omit), :handled (already rendered), or nil (shared handling)."
  (let ((type   (car step))
        (name   (plist-get step :text))
        (rubric (plist-get step :rubric)))
    (cond
     ;; Suppress the "no priest" rubric — re-emitted by the absolution handler
     ((and (eq type :rubric) (plist-get step :alt-collect))
      :skip)
     ;; Suppress General Confession rubric when confession is omitted
     ((and (eq type :rubric)
           (string-match-p "general Confession" (or rubric "")))
      (when (eq bcp-1662-general-confession-form 'omit) :skip))
     ;; Exhortation (Bidding) — honour bidding form option
     ((and (eq type :text) (eq name 'exhortation))
      (pcase bcp-1662-bidding-form
        ('omit :skip)
        ('brief
         (bcp-liturgy-render--insert-fixed-text
          'exhortation (or bcp-1662-bidding-brief ""))
         :handled)
        (_ nil)))
     ;; General Confession — honour confession form option
     ((and (eq type :text) (eq name 'general-confession))
      (pcase bcp-1662-general-confession-form
        ('omit :skip)
        ('variant
         (bcp-liturgy-render--insert-fixed-text
          'general-confession bcp-1662-text-general-confession-variant)
         :handled)
        (_ nil)))
     (t nil))))

(defun bcp-1662--post-office (propers lesson-texts ctx)
  "Render 1662 communion propers after the office when configured."
  (let ((communion-sym (plist-get propers :communion))
        (ot-ref        (plist-get propers :ot-reading))
        (ref-label-fn  (plist-get ctx :ref-label-fn))
        (ref-str-fn    (plist-get ctx :ref-to-string-fn)))
    (when (and bcp-1662-show-communion-propers communion-sym)
      (bcp-liturgy-render--insert-heading 2 "Communion Propers")
      (when ot-ref
        (let* ((label (funcall ref-label-fn ot-ref))
               (txt   (cdr (assoc "ot" lesson-texts))))
          (bcp-liturgy-render--insert-heading 3 (format "OT Lesson: %s" label))
          (if txt
              (bcp-liturgy-render--insert-text-block txt)
            (bcp-liturgy-render--insert-passage-fallback
             (funcall ref-str-fn ot-ref) label
             bible-commentary-translation))))
      (when-let* ((cp (bcp-1662-communion-propers communion-sym))
                  (ep (plist-get cp :epistle))
                  (go (plist-get cp :gospel)))
        (let* ((ep-label (funcall ref-label-fn ep))
               (go-label (funcall ref-label-fn go))
               (ep-txt   (cdr (assoc "epistle" lesson-texts)))
               (go-txt   (cdr (assoc "gospel"  lesson-texts))))
          (when ot-ref (insert "\n"))
          (bcp-liturgy-render--insert-heading 3 (format "Epistle: %s" ep-label))
          (if ep-txt
              (bcp-liturgy-render--insert-text-block ep-txt)
            (bcp-liturgy-render--insert-passage-fallback
             (funcall ref-str-fn ep) ep-label
             bible-commentary-translation))
          (insert "\n")
          (bcp-liturgy-render--insert-heading 3 (format "Gospel: %s" go-label))
          (if go-txt
              (bcp-liturgy-render--insert-text-block go-txt)
            (bcp-liturgy-render--insert-passage-fallback
             (funcall ref-str-fn go) go-label
             bible-commentary-translation)))
        (insert "\n")))))

(defun bcp-1662--build-ctx (propers)
  "Build the Anglican render context for the 1662 BCP.
Resolves current defcustom values and registers all tradition callbacks."
  (let* ((date      (plist-get propers :date))
         (is-sunday (when date (= (calendar-day-of-week date) 0))))
    (list
     :rubric-face-fn                #'bcp-1662--rubric-face
     :collect-text-fn               #'bcp-1662-collect-text
     :ref-to-string-fn              #'bcp-1662--lectionary-ref-to-string
     :ref-label-fn                  #'bcp-1662--ref-label
     :psalm-label-fn                #'bcp-1662--psalm-label
     :psalm-to-passage-fn           #'bcp-1662--psalm-to-passage
     :opening-sentences-fn          #'bcp-1662--select-opening-sentences
     :easter-anthems-p-fn           #'bcp-1662--easter-anthems-p
     :venite-filter-fn              #'bcp-1662--venite-filter
     :officiant                     office-officiant
     :show-penitential-intro        (not (and bcp-1662-omit-penitential-intro
                                              (not is-sunday)))
     :absolution-substitute-key     'trinity-21
     :absolution-no-priest-rubric-fn #'bcp-1662--no-priest-rubric
     :seasonal-collect-rubric-fn    #'bcp-1662--seasonal-collect-rubric
     :additional-prayers            bcp-1662-additional-prayers
     :step-override-fn              #'bcp-1662--step-override
     :post-office-fn                #'bcp-1662--post-office
     :day-id-fn                     #'bcp-1662--day-identity
     :office-label-fn               #'bcp-anglican-render--office-label
     :office-order                  '(mattins evensong)
     :propers-fn                    #'bcp-1662--propers-fn
     :ordo-for-office               #'bcp-1662--ordo-for-office
     :buffer-name                   bcp-1662-office-buffer-name)))

(defun bcp-1662--propers-fn (date office)
  "Return propers for DATE (M D Y) at OFFICE — used by prior-office simulation."
  (bcp-1662-propers-for-date (nth 0 date) (nth 1 date) (nth 2 date) office))

(defun bcp-1662--ordo-for-office (office)
  "Return the 1662 ordo list for OFFICE (mattins or evensong)."
  (if (eq office 'mattins) bcp-1662-ordo-morning bcp-1662-ordo-evening))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Main entry point
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-1662--render-office (propers psalms psalm-texts date-str lesson-texts)
  "Render the BCP 1662 Office buffer.
Builds the tradition context and delegates to the shared Anglican walker."
  (let* ((office (plist-get propers :office))
         (ordo   (if (eq office 'mattins)
                     bcp-1662-ordo-morning
                   bcp-1662-ordo-evening))
         (ctx    (bcp-1662--build-ctx propers)))
    (bcp-anglican-render--render-office
     propers psalms psalm-texts date-str lesson-texts ordo ctx)))

(provide 'bcp-1662-render)
;;; bcp-1662-render.el ends here
