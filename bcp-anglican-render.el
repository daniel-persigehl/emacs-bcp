;;; bcp-anglican-render.el --- Shared renderer for the classical Anglican BCP family -*- lexical-binding: t -*-

;;; Commentary:
;;
;; Shared rendering layer for the classical Anglican BCP family: 1662 BCP (England),
;; 1928 American BCP, Canadian BCP (1962), and similar traditions.  These books share
;; the same Daily Office structure — opening sentences, confession, Venite, psalms,
;; lessons, canticles, creed, preces, collects — and differ only in which specific
;; texts are used, which rubrical options apply, and what may be omitted.
;;
;; This layer owns:
;;   - Shared utility functions (last-verse-in-text, ref-label-with-text,
;;     psalm-label, psalm-to-passage, office-label)
;;   - bcp-anglican-render--render-ordo-step  — step dispatch, tradition-agnostic
;;   - bcp-anglican-render--render-office     — ordo walker with shared rubrical logic
;;
;; Tradition-specific files build a *context plist* (ctx) and call
;; `bcp-anglican-render--render-office'.  See the slot documentation below.
;;
;; What does NOT live here:
;;   - Rubric faces and their defcustoms (tradition-specific)
;;   - Book expansion tables and ref-to-string utilities (tradition-specific)
;;   - Day identity (each tradition has its own calendar and season logic)
;;   - Venite text manipulation (tradition-specific rubric)
;;   - Opening sentence selectors (tradition-specific text pools)

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-render)
(require 'bcp-liturgy-render)
(require 'bcp-common-canticles)
(require 'bcp-common-prayers)
(require 'bcp-common-anglican)
(require 'bcp-hymnal)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Context plist — slot documentation
;;;; ══════════════════════════════════════════════════════════════════════════
;;
;; The context (ctx) passed to the shared functions is an ordinary plist.
;; Tradition-specific render files build it via their own build-ctx function.
;;
;; Rendering:
;;   :rubric-face-fn              () → face symbol
;;
;; Data access (all tradition-specific):
;;   :collect-text-fn             (key) → string | nil
;;   :ref-to-string-fn            (ref) → passage string for the scripture fetcher
;;   :ref-label-fn                (ref) → short display string
;;   :psalm-label-fn              (psalm-ref) → "Ps N" style string
;;   :psalm-to-passage-fn         (psalm-ref) → passage string for the fetcher
;;   :opening-sentences-fn        (season date office)
;;                                → list; each element is either a plain string
;;                                  (no citation) or a (text citation) pair
;;
;; Canticle options:
;;   :easter-anthems-p-fn         (propers) → bool
;;                                  t if the Venite should be replaced by Easter Anthems
;;   :venite-filter-fn            (raw-text season) → text
;;                                  tradition-specific Venite rubric (e.g. strip verses
;;                                  8–11 in ordinary time); nil means use raw-text as-is
;;   :invitatory-fn               (propers) → string | nil
;;                                  seasonal invitatory antiphon, or nil on ordinary days;
;;                                  rendered before the Venite heading when non-nil
;;
;; Rubrical state (resolved from defcustoms at ctx-build time):
;;   :officiant                   'priest | 'bishop | 'lay | 'deacon
;;   :show-penitential-intro      bool
;;   :absolution-substitute-key   symbol — key for :collect-text-fn (lay substitute)
;;   :absolution-no-priest-rubric-fn  (ordo) → string | nil
;;                                    rubric text shown before the lay substitute;
;;                                    nil if this tradition has no such rubric
;;   :seasonal-collect-rubric-fn  (collect-key) → string
;;   :additional-prayers          list of symbols or plain strings
;;
;; Tradition extension hooks:
;;   :step-override-fn            (step propers) → :skip | :handled | nil
;;                                  :skip    = omit this step entirely
;;                                  :handled = already rendered, skip shared dispatch
;;                                  nil      = proceed with shared handling
;;                                  Use this for options unique to the tradition
;;                                  (e.g. 1662 bidding form, confession form).
;;   :post-office-fn              (propers lesson-texts ctx) → nil
;;                                  Called after the ordo walk, before buffer finalise.
;;                                  Used for communion propers and similar appendices.
;;
;; Display:
;;   :day-id-fn                   (propers) → day-identity plist
;;   :office-label-fn             (office) → string
;;   :buffer-name                 string

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Shared utility functions
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-anglican-render--last-verse-in-text (text)
  "Return the last `bcp-verse' text property value found in TEXT, or nil."
  (let ((pos 0) (len (length text)) (last nil))
    (while (< pos len)
      (let ((v (get-text-property pos 'bcp-verse text)))
        (when v (setq last v)))
      (setq pos (next-single-property-change pos 'bcp-verse text len)))
    last))

(defun bcp-anglican-render--ref-label-with-text (ref text ref-label-fn)
  "Return a display label for REF, appending the actual last verse when known.
REF-LABEL-FN is the tradition-specific ref formatter.
When REF specifies a start verse > 1 with no explicit end, scans TEXT for the
highest `bcp-verse' property and appends it as the range end."
  (let* ((v1 (and (listp ref) (stringp (car ref)) (caddr ref)))
         (v2 (and (listp ref) (stringp (car ref)) (cadddr ref))))
    (if (and text v1 (> v1 1) (null v2))
        (let ((last (bcp-anglican-render--last-verse-in-text text)))
          (if last
              (format "%s-%d" (funcall ref-label-fn ref) last)
            (funcall ref-label-fn ref)))
      (funcall ref-label-fn ref))))

(defun bcp-anglican-render--psalm-label (psalm-ref)
  "Format PSALM-REF as a short heading label (e.g. \"Ps 23\" or \"Ps 119:1-32\")."
  (if (consp psalm-ref)
      (format "Ps 119:%d-%d" (cadr psalm-ref) (caddr psalm-ref))
    (format "Ps %d" psalm-ref)))

(defun bcp-anglican-render--office-label (office)
  "Return a display string for OFFICE symbol ('mattins or 'evensong)."
  (if (eq office 'mattins) "Morning Prayer" "Evening Prayer"))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Step-type renderer
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-anglican-render--render-ordo-step
    (step propers psalms psalm-texts lesson-texts ctx)
  "Render one ordo STEP into the current buffer.
PROPERS, PSALMS, PSALM-TEXTS, LESSON-TEXTS supply the liturgical data.
CTX is the tradition context plist."
  (let* ((type             (car step))
         (rubric-face-fn   (plist-get ctx :rubric-face-fn))
         (collect-text-fn  (plist-get ctx :collect-text-fn))
         (ref-label-fn     (plist-get ctx :ref-label-fn))
         (ref-str-fn       (plist-get ctx :ref-to-string-fn))
         (psalm-label-fn   (plist-get ctx :psalm-label-fn))
         (psalm-pass-fn    (plist-get ctx :psalm-to-passage-fn))
         (sentences-fn     (plist-get ctx :opening-sentences-fn))
         (venite-filter-fn (plist-get ctx :venite-filter-fn))
         (invitatory-fn    (plist-get ctx :invitatory-fn))
         (ea-p-fn          (plist-get ctx :easter-anthems-p-fn))
         (officiant         (plist-get ctx :officiant)))
    (cl-flet
        ((rubric!   (text)
           (bcp-liturgy-render--insert-rubric text rubric-face-fn))
         (heading!  (lvl text)
           (bcp-liturgy-render--insert-heading lvl text))
         (versicles! (pairs)
           (bcp-liturgy-render--insert-versicles pairs))
         (text!     (text)
           (bcp-liturgy-render--insert-text-block text))
         (canticle! (text)
           (bcp-liturgy-render--insert-canticle-text text))
         (fixed!    (name text)
           (bcp-liturgy-render--insert-fixed-text name text)))

      (pcase type

        ;; ── Rubric ───────────────────────────────────────────────────────
        (:rubric
         (when-let* ((text (plist-get step :rubric)))
           (rubric! text)))

        ;; ── Opening sentences ────────────────────────────────────────────
        (:sentences
         (let ((sents (funcall sentences-fn
                               (plist-get propers :season)
                               (plist-get propers :date)
                               (plist-get propers :office))))
           (dolist (sent sents)
             (if (stringp sent)
                 (text! sent)
               (let* ((t1  (car sent))
                      (cit (cadr sent))
                      (lbl (if (and (listp cit) (listp (car cit)))
                               (mapconcat (lambda (c) (funcall ref-label-fn c))
                                          cit " / ")
                             (funcall ref-label-fn cit))))
                 (text! (concat t1 " — " lbl)))))))

        ;; ── Fixed text ───────────────────────────────────────────────────
        (:text
         (let ((name      (plist-get step :text))
               (ref       (plist-get step :ref))
               (alt-creed (plist-get step :alt-creed)))
           (cond
            ((eq name 'lords-prayer)
             (bcp-liturgy-render--insert-lords-prayer))
            ((and (eq name 'apostles-creed)
                  alt-creed
                  (eq bcp-liturgy-creed 'nicene))
             (let ((txt (symbol-value alt-creed)))
               (fixed! 'nicene-creed
                 (if (stringp txt) txt (or (bcp-common-prayers-text txt) "")))))
            (ref
             (let ((txt (symbol-value ref)))
               (fixed! (or name (intern (symbol-name ref)))
                 (if (stringp txt) txt (or (bcp-common-prayers-text txt) "")))))
            (t nil))))

        ;; ── Versicles ────────────────────────────────────────────────────
        (:versicles
         (versicles! (cdr step)))

        ;; ── Preces versicles (officiant-sensitive) ───────────────────────
        ;; Priest/bishop: "The Lord be with you." / "And with thy spirit."
        ;; Lay/deacon:    "Hear my prayer, O Lord." / "And let my cry…"
        (:versicles-preces
         (bcp-liturgy-render--insert-dominus-vobiscum
          bcp-common-anglican-preces-lord-be-with-you
          bcp-common-anglican-preces-lay))

        ;; ── Canticle ─────────────────────────────────────────────────────
        (:canticle
         (let* ((name        (plist-get step :canticle))
                (latin-title (plist-get step :latin))
                (exc-easter  (plist-get step :exception-easter))
                (exc-dom     (plist-get step :exception-day-of-month))
                (date        (plist-get propers :date))
                (dom         (cadr date))
                (is-easter   (and exc-easter
                                  (funcall ea-p-fn propers)
                                  (eq name 'venite)))
                (dom-except  (and exc-dom date (= dom exc-dom))))
           (cond
            (is-easter
             (heading! 3 "Easter Anthems")
             (when-let* ((txt (funcall collect-text-fn 'easter-anthems)))
               (canticle! txt)))
            (dom-except nil)
            (t
             (let* ((title    (or latin-title
                                  (bcp-liturgy-canticle-title name)
                                  (symbol-name name)))
                    (raw-text (bcp-liturgy-canticle-get name))
                    (txt      (if (and (eq name 'venite) venite-filter-fn)
                                  (funcall venite-filter-fn raw-text
                                           (plist-get propers :season))
                                raw-text)))
               (when (and (eq name 'venite) invitatory-fn)
                 (when-let* ((inv (funcall invitatory-fn propers)))
                   (canticle! inv)
                   (insert "\n")))
               (heading! 3 title)
               (insert "\n")
               (if txt
                   (progn
                     (canticle! txt)
                     (when (and bcp-liturgy-canticle-append-gloria
                                (bcp-liturgy-canticle-gloria-p name))
                       (canticle! (bcp-liturgy-canticle-gloria-text))))
                 (rubric! (format "[%s: text not yet available]" title))))))))

        ;; ── Alternatives ─────────────────────────────────────────────────
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
               (heading! 3 title)
               (when rest
                 (rubric!
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
                      (dom        (when date (cadr date)))
                      (is-easter  (and exc-easter
                                       (funcall ea-p-fn propers)
                                       (eq name 'venite)))
                      (dom-except (and exc-dom dom (= dom exc-dom)))
                      (raw-text   (bcp-liturgy-canticle-get name))
                      (txt        (if (and (eq name 'venite) venite-filter-fn)
                                      (funcall venite-filter-fn raw-text
                                               (plist-get propers :season))
                                    raw-text)))
                 (cond
                  (is-easter
                   (when-let* ((at (funcall collect-text-fn 'easter-anthems)))
                     (canticle! at)))
                  (dom-except nil)
                  (txt
                   (canticle! txt)
                   (when (and bcp-liturgy-canticle-append-gloria
                              (bcp-liturgy-canticle-gloria-p name))
                     (canticle! (bcp-liturgy-canticle-gloria-text))))
                  (t (rubric! (format "[%s: text not yet available]" title)))))))))

        ;; ── Psalm slot ───────────────────────────────────────────────────
        (:psalm
         (dolist (p psalms)
           (let* ((key (funcall psalm-label-fn p))
                  (txt (cdr (assoc key psalm-texts))))
             (heading! 3 key)
             (if txt
                 (progn
                   (text! txt)
                   (when bcp-liturgy-canticle-append-gloria
                     (text! (bcp-liturgy-canticle-gloria-text))))
               (bcp-liturgy-render--insert-passage-fallback
                (funcall psalm-pass-fn p) key
                bible-commentary-psalm-translation)))))

        ;; ── Lesson slot ──────────────────────────────────────────────────
        (:lesson
         (let* ((which   (plist-get step :lesson))
                (key     (if (eq which 'second) "lesson2" "lesson1"))
                (lessons (plist-get propers :lessons))
                (ref     (plist-get lessons (if (eq which 'second)
                                                :lesson2 :lesson1)))
                (txt     (cdr (assoc key lesson-texts))))
           (when ref
             (let ((label (bcp-anglican-render--ref-label-with-text
                           ref txt ref-label-fn)))
               (heading! 3
                 (format "%s Lesson: %s"
                         (if (eq which 'second) "Second" "First") label))
               (if txt
                   (text! txt)
                 (bcp-liturgy-render--insert-passage-fallback
                  (funcall ref-str-fn ref) label
                  bible-commentary-translation))))))

        ;; ── Collect slot ─────────────────────────────────────────────────
        (:collect
         (let* ((which         (plist-get step :collect))
                (ref           (plist-get step :ref))
                (sc-rubric-fn  (plist-get ctx :seasonal-collect-rubric-fn)))
           (cond
            ((eq which 'day)
             (let* ((sym (plist-get propers :collect))
                    (txt (when sym (funcall collect-text-fn sym))))
               (heading! 3 "Collect of the Day")
               (if txt
                   (insert txt "\n")
                 (insert (format ";; [collect for %s]\n\n" (or sym "unknown"))))
               (when-let* ((sc  (plist-get propers :seasonal-collect))
                           (sct (funcall collect-text-fn sc)))
                 (rubric! (funcall sc-rubric-fn sc))
                 (fixed! 'seasonal-collect sct))))
            (ref
             (let* ((data  (symbol-value ref))
                    (title (plist-get data :title))
                    (txt   (bcp-common-prayers-text data)))
               (heading! 3 (or title "Collect"))
               (when txt (insert txt "\n")))))))

        ;; ── Anthem ───────────────────────────────────────────────────────
        (:anthem
         (rubric!
          (or (plist-get step :rubric)
              "In Quires and Places where they sing, here followeth the Anthem.")))

        ;; ── Hymn ─────────────────────────────────────────────────────────
        ;; Driven by the controlled-vocabulary tag system in bcp-hymnal.
        ;; Step keys:
        ;;   :slot-kind   SYMBOL (office-hymn / closing / opening / ...)
        ;;   :extra-tags  LIST of tag symbols required on the candidate
        ;;   :heading     STRING override (default "Hymn")
        ;; The selector ranks by appointment, occasion tier, popularity;
        ;; we render the top text record (first-line + stanzas).  When
        ;; no candidate is found the slot degrades to a plain rubric.
        (:hymn
         (let* ((slot-kind  (or (plist-get step :slot-kind) 'office-hymn))
                (extra-tags (plist-get step :extra-tags))
                (date       (plist-get propers :date))
                (results    (bcp-hymnal-select
                             :date       date
                             :slot-kind  slot-kind
                             :language   'english
                             :extra-tags extra-tags))
                (top-id     (car results))
                (text-rec   (when top-id (bcp-hymnal-text top-id))))
           (heading! 3 (or (plist-get step :heading) "Hymn"))
           (cond
            (text-rec
             (insert (format "_%s_\n\n"
                             (or (plist-get text-rec :first-line) "")))
             ;; Meter under the title so the user can see at a glance
             ;; what tunes will fit (no syllable-counting required).
             (when-let ((meter (plist-get text-rec :meter)))
               (insert (format "_Meter: %s_\n\n" meter)))
             (dolist (stanza (or (plist-get text-rec :stanzas) '()))
               (insert stanza "\n\n")))
            (t
             (rubric! "Here followeth a hymn.")))))

        ;; ── Prayer slot ──────────────────────────────────────────────────
        (:prayer
         (let* ((ref   (plist-get step :ref))
                (data  (when ref (symbol-value ref)))
                (title (when data (plist-get data :title)))
                (txt   (when data (bcp-common-prayers-text data))))
           (heading! 3 (or title "Prayer"))
           (when txt
             (fixed! (or (plist-get step :prayer) (intern (symbol-name ref)))
                     txt))))

        ;; ── State versicles (region-resolved) ────────────────────────────
        (:state-versicles
         (versicles!
          (list (bcp-liturgy-state-versicles (plist-get step :tradition)))))

        ;; ── State prayers (region-resolved) ──────────────────────────────
        (:state-prayers
         (dolist (prayer (bcp-liturgy-state-prayers (plist-get step :tradition)))
           (let* ((title (plist-get prayer :title))
                  (txt   (bcp-common-prayers-text prayer)))
             (heading! 3 (or title "Prayer"))
             (when txt
               (fixed! (or (plist-get prayer :name) 'state-prayer) txt)))))

        ;; ── Unknown — ignore silently ─────────────────────────────────────
        (_ nil)))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Shared ordo walker
;;;; ══════════════════════════════════════════════════════════════════════════

(defun bcp-anglican-render--render-office
    (propers psalms psalm-texts date-str lesson-texts ordo ctx)
  "Render a classical Anglican BCP office buffer.

Walks ORDO applying the shared rubrical logic common to the 1662/1928/Canadian
BCP family, dispatching each step to `bcp-anglican-render--render-ordo-step'.

PROPERS PSALMS PSALM-TEXTS DATE-STR LESSON-TEXTS supply the liturgical data.
ORDO is the morning or evening ordo list.
CTX is the tradition context plist (see slot documentation above)."
  (let* ((office              (plist-get propers :office))
         (feast-name           (plist-get propers :feast-name))
         (feast-rank           (plist-get propers :feast-rank))
         (office-label         (funcall (plist-get ctx :office-label-fn) office))
         (day-id               (funcall (plist-get ctx :day-id-fn) propers))
         (officiant            (plist-get ctx :officiant))
         (show-penit           (plist-get ctx :show-penitential-intro))
         (step-override-fn     (plist-get ctx :step-override-fn))
         (post-office-fn       (plist-get ctx :post-office-fn))
         (collect-text-fn      (plist-get ctx :collect-text-fn))
         (abs-sub-key          (plist-get ctx :absolution-substitute-key))
         (no-priest-rubric-fn  (plist-get ctx :absolution-no-priest-rubric-fn))
         (rubric-face-fn       (plist-get ctx :rubric-face-fn))
         (add-prayers          (plist-get ctx :additional-prayers))
         (buffer-name          (plist-get ctx :buffer-name)))
    (with-current-buffer (bcp-liturgy-render--setup-buffer buffer-name)

      ;; ── Title ────────────────────────────────────────────────────────
      (bcp-liturgy-render--insert-heading 1
        (format "%s — %s" office-label date-str))

      ;; ── Liturgical identity block ─────────────────────────────────────
      (bcp-liturgy-render--insert-identity-block day-id feast-name feast-rank)
      (insert "\n")

      ;; ── Ordo walk ────────────────────────────────────────────────────
      (let ((past-venite nil))
        (dolist (step ordo)
          (let* ((type       (car step))
                 (pos-before (point))
                 (skip-p     nil)
                 (handled-p  nil))

            ;; Phase 1: tradition-specific override
            (when step-override-fn
              (pcase (funcall step-override-fn step propers)
                (:skip    (setq skip-p t))
                (:handled (setq handled-p t))))

            ;; Phase 2: shared rubrical logic
            (unless (or skip-p handled-p)
              (cond
               ;; Penitential intro omission: skip rubrics, sentences, and
               ;; fixed texts before the opening versicles
               ((and (not show-penit) (not past-venite)
                     (memq type '(:rubric :sentences :text)))
                (setq skip-p t))
               ;; Opening versicles — render and mark past the penitential section
               ((and (not show-penit) (not past-venite)
                     (eq type :versicles))
                (setq past-venite t))
               ;; Absolution rubric — priest/bishop only
               ((and (eq type :rubric)
                     (string-match-p "Absolution\\|Remission of sins"
                                     (or (plist-get step :rubric) "")))
                (unless (memq officiant '(priest bishop))
                  (setq skip-p t)))
               ;; Absolution text — priest renders normally; lay/deacon receives
               ;; the tradition's substitute collect
               ((and (eq type :text)
                     (eq (plist-get step :text) 'absolution))
                (setq past-venite t)
                (unless (memq officiant '(priest bishop))
                  (when-let* ((fn  no-priest-rubric-fn)
                              (rub (funcall fn ordo)))
                    (bcp-liturgy-render--insert-rubric rub rubric-face-fn))
                  (let ((txt (funcall collect-text-fn abs-sub-key)))
                    (if txt
                        (bcp-liturgy-render--insert-fixed-text 'absolution txt)
                      (bcp-liturgy-render--insert-rubric
                       "[Collect for the Twenty-First Sunday after Trinity]"
                       rubric-face-fn)))
                  (setq handled-p t)))
               ;; All other steps
               (t (setq past-venite t))))

            ;; Phase 3: dispatch to step renderer
            (unless (or skip-p handled-p)
              (bcp-anglican-render--render-ordo-step
               step propers psalms psalm-texts lesson-texts ctx))

            ;; Blank line after each step that produced output
            (when (> (point) pos-before)
              (insert "\n")))))

      ;; ── Additional prayers ───────────────────────────────────────────
      (when add-prayers
        (dolist (prayer add-prayers)
          (cond
           ((stringp prayer)
            (bcp-liturgy-render--insert-fixed-text 'additional-prayer prayer))
           ((symbolp prayer)
            (let ((data (and (boundp prayer) (symbol-value prayer))))
              (when data
                (bcp-liturgy-render--insert-heading 3
                  (or (plist-get data :title) (symbol-name prayer)))
                (bcp-liturgy-render--insert-fixed-text
                 prayer (plist-get data :text))))))))

      ;; ── Tradition post-office hook (communion propers, etc.) ─────────
      (when post-office-fn
        (funcall post-office-fn propers lesson-texts ctx))

      ;; ── Finalise ─────────────────────────────────────────────────────
      (bcp-reader--add-verse-number-overlays)
      (when bcp-reader-paragraph-mode
        (bcp-reader--add-paragraph-overlays))
      (bcp-liturgy-render--finalise-buffer)
      (current-buffer))))

(provide 'bcp-anglican-render)
;;; bcp-anglican-render.el ends here
