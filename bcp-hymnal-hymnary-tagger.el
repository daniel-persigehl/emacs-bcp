;;; bcp-hymnal-hymnary-tagger.el --- Hymnary :topic → controlled tags  -*- lexical-binding: t; -*-

;;; Commentary:

;; Hymnary.org annotates each hymn with a semicolon-separated `:topic'
;; string mixing season, feast day, slot location ("Morning Prayer
;; Closing", "The Holy Communion Sequence"), and theme.  This module
;; parses those strings into the controlled tag vocabulary that
;; drives `bcp-hymnal-select'.
;;
;; The tagger runs as a load-time pass over a registered hymnal
;; manifest: for each slot it derives tag symbols from `:topic' and
;; unions them onto the slot's `:text' record in `bcp-hymnal--texts'.
;; Tags belong to the text, not the tune-variant slot — multiple slots
;; that share a text-id contribute their tags to the same record.
;;
;; The same parser works for any hymnal scraped from Hymnary that
;; carries Episcopal-style topic strings (1940, 1982, English Hymnal,
;; Hymns Ancient & Modern).  Coverage is best-effort: liturgically
;; actionable tags only.  Themes outside the controlled vocabulary
;; (Brotherhood, Loyalty, Confirmation, occasional offices) are
;; intentionally dropped.

;;; Code:

(require 'cl-lib)
(require 'bcp-hymnal)

(defvar bcp-hymnal-hymnary-tagger--rules
  '( ;; ── Seasons & seasonal Sundays ──
    ;; Order: more specific patterns appear before broader ones so that
    ;; a "Christmas Eve" segment also matches the broader "Christmas"
    ;; rule (we collect ALL matches) but the specific ones aren't
    ;; shadowed by the broader.
    ("Advent" . (advent))
    ("Christmas Carols" . (christmastide))
    ("Christmas Eve" . (christmas-eve))
    ("Christmas Day" . (christmas-day))
    ("after Christmas" . (christmastide))
    ("Christmas" . (christmastide))
    ("The Epiphany" . (epiphany-day))
    ("after Epiphany" . (epiphanytide))
    ("Epiphany" . (epiphanytide))
    ("Septuagesima" . (septuagesima pre-lent))
    ("Sexagesima" . (sexagesima pre-lent))
    ("Quinquagesima" . (quinquagesima pre-lent))
    ("Pre-Lenten" . (pre-lent))
    ("Ash Wednesday" . (ash-wednesday))
    ("Lent" . (lent))
    ("Passion Sunday" . (passion-sunday))
    ("Palm Sunday" . (palm-sunday))
    ("Maundy Thursday" . (maundy-thursday))
    ("Good Friday" . (good-friday))
    ("Holy Saturday" . (holy-saturday))
    ("Holy Week" . (holy-week))
    ("Passiontide" . (passiontide))
    ("Easter Day" . (easter-day))
    ("Easter Even" . (holy-saturday))
    ("Easter Eve" . (holy-saturday))
    ("after Easter" . (eastertide))
    ("Easter" . (eastertide))
    ("Rogation" . (rogation))
    ("Ascension Day" . (ascension-day))
    ("Ascensiontide" . (ascensiontide))
    ("Ascension" . (ascensiontide))
    ("Whitsunday" . (whitsunday))
    ("Pentecost" . (whitsunday))
    ("Trinity Sunday" . (trinity-sunday))
    ("after Trinity" . (trinitytide))
    ("Trinity" . (trinitytide))

    ;; ── Fixed-date feasts ──
    ("Holy Name" . (holy-name))
    ("The Circumcision" . (holy-name))
    ("The Purification" . (candlemas))
    ;; "Anunciation" is Hymnary's typo for Annunciation; cover both.
    ("Anunciation" . (annunciation marian))
    ("The Annunciation" . (annunciation marian))
    ("The Transfiguration" . (transfiguration))
    ("Holy Cross" . (holy-cross))
    ("The Assumption" . (assumption marian))
    ("All Saints" . (all-saints))
    ("All Souls" . (all-souls))

    ;; ── Saints (those in the controlled vocab) ──
    ("Holy Innocents" . (sanctorum))
    ("St. Stephen" . (st-stephen))
    ("Nativity of St. John Baptist" . (st-john-baptist-nativity))
    ("St. John Baptist" . (st-john-baptist-nativity))
    ("St. Michael" . (st-michael))
    ("St. Joseph" . (st-joseph))
    ("St. Peter" . (st-peter sanctorum))
    ("St. Mary Magdalene" . (st-mary-magdalene))
    ;; Catch-all for unrecognized saints (apostles, evangelists, etc.)
    ;; Any "Saints' Days and Holy Days:" prefix and any "St. X" segment
    ;; not in the vocab still earns the broad `sanctorum' tag.
    ("Saints' Days and Holy Days" . (sanctorum))
    ("St. " . (sanctorum))
    ("Martyrs" . (sanctorum))

    ;; ── Slot location ──
    ;; "Morning Prayer" / "Evening Prayer" pin the hour; "Opening" /
    ;; "Closing" further pin the slot-kind.  "General" / "Sequence" /
    ;; "Communion" don't pin a slot but do confirm the hour.
    ("Morning Prayer Opening" . (matins opening))
    ("Morning Prayer Closing" . (matins closing))
    ("Morning Prayer" . (matins))
    ("Evening Prayer Opening" . (vespers opening))
    ("Evening Prayer Closing" . (vespers closing))
    ("Evening Prayer" . (vespers))
    ("The Holy Communion Opening" . (opening))
    ("The Holy Communion Closing" . (closing))
    ("The Communion Opening" . (opening))
    ("The Communion Closing" . (closing))

    ;; ── Themes ──
    ("Christ: King" . (christ-the-king))
    ("Christ: Saviour" . (christocentric))
    ("The Holy Spirit" . (holy-spirit paraclete pneumatological))
    ("The Blessed Trinity" . (trinity-sunday trinitarian))
    ("Communion of Saints" . (communion-of-saints))
    ("Holy Scriptures" . (scriptural))
    ("Holy Scripture" . (scriptural))
    ("Mary" . (marian mary))
    ("BVM" . (marian mary))
    ("Mother of" . (marian mary))

    ;; ── Time of day ──
    ("Morning" . (morning))
    ("Evening" . (evening))
    ("Night" . (night))

    ;; ── Mood / character ──
    ("Penitence" . (penitential))
    ("Joy" . (rejoicing))
    ("Hope" . (hope)))
  "Pattern → tag-list rules for `bcp-hymnal-hymnary-tagger-tags-for-topic'.
Each car is a literal substring (matched with `regexp-quote'); each cdr
is a list of tag symbols added when the substring occurs in a topic
segment.  All matching rules fire — patterns don't shadow each other.")

(defun bcp-hymnal-hymnary-tagger--clean-segment (seg)
  "Strip Hymnary's \"(N more...)\" tail and surrounding whitespace from SEG."
  (string-trim
   (replace-regexp-in-string " *([0-9]+ more\\.\\.\\.)\\s-*$" "" seg)))

(defun bcp-hymnal-hymnary-tagger--collect-tags (seg)
  "Return all tag symbols implied by topic segment SEG."
  (let (acc)
    (dolist (rule bcp-hymnal-hymnary-tagger--rules)
      (when (string-match-p (regexp-quote (car rule)) seg)
        (dolist (tag (cdr rule))
          (push tag acc))))
    acc))

(defun bcp-hymnal-hymnary-tagger-tags-for-topic (topic)
  "Parse Hymnary TOPIC into a deduplicated list of valid tag symbols.
Drops tags not recognised by `bcp-hymnal--valid-tag-p'."
  (let (out)
    (when topic
      (dolist (seg (split-string topic ";" t "[ \t]+"))
        (setq seg (bcp-hymnal-hymnary-tagger--clean-segment seg))
        (dolist (tag (bcp-hymnal-hymnary-tagger--collect-tags seg))
          (when (bcp-hymnal--valid-tag-p tag)
            (cl-pushnew tag out)))))
    out))

;;;###autoload
(defun bcp-hymnal-hymnary-tagger-apply (hymnal-id)
  "Walk HYMNAL-ID's manifest; union derived tags onto each slot's :text record.
Multiple slots referencing the same text-id contribute via UNION.  No-op
for slots without :topic or :text.  Existing :tags on a record are
preserved (the union also covers prior runs and authored overrides)."
  (let ((tab (alist-get hymnal-id bcp-hymnal--manifests)))
    (unless tab
      (error "bcp-hymnal-hymnary-tagger: hymnal %S not registered" hymnal-id))
    (maphash
     (lambda (_n slot)
       (let* ((tid   (plist-get slot :text))
              (topic (plist-get slot :topic))
              (text  (and tid (gethash tid bcp-hymnal--texts))))
         (when (and text topic)
           (let ((merged (copy-sequence (plist-get text :tags))))
             (dolist (tag (bcp-hymnal-hymnary-tagger-tags-for-topic topic))
               (cl-pushnew tag merged))
             (puthash tid (plist-put text :tags merged)
                      bcp-hymnal--texts)))))
     tab)))

(provide 'bcp-hymnal-hymnary-tagger)
;;; bcp-hymnal-hymnary-tagger.el ends here
