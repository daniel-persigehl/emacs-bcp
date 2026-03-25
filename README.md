# emacs-bcp — Bible Commentary & Prayer

An Emacs Lisp framework for Bible study and liturgical prayer. It has two equal purposes: a scripture reader and annotation environment built around org and org-roam, and a Daily Office engine that renders complete liturgies with scripture lessons fetched and inserted inline. The BCP 1662 Daily Office is the first fully implemented tradition; the architecture is designed to accommodate additional prayer books and the Roman Breviary.

---

## Purpose

This project began as a simple solution to a simple problem: a dislike of marking up physical books and a desire to keep, organise, and cross-reference notes on scripture in a way that was easily searchable. Reconfiguring Emacs so that it could generate a feature-complete Daily Office with lessons inserted inline, Bea Psalter, and pre-1955 Holy Week was the obvious method of achieving this, naturally.

### Scripture study

The core of the project is a scripture reader (`bcp-reader`) and study notebook (`bcp-notebook`). Open any passage by reference, read it in a dedicated buffer with verse navigation, and work alongside a linked org commentary file. With org-roam loaded, backlinks surface every note that touches the current passage, and org-capture provides one-keystroke marginal annotation. The same fetch layer that supplies Office lessons supplies the reader, so the same translation settings and fallback chain apply throughout.

### Daily Office

The prayer side renders the full text of the BCP 1662 Daily Office — Morning and Evening Prayer — as a read-only buffer. The complete ordo is present: opening sentences, confession, absolution, psalms, canticles, lessons, collects, and prayers, with lessons fetched and inserted inline. No external browser or PDF viewer is required. The liturgical calendar engine handles the full 1662 feast calendar, moveable feasts, and user-defined observances.

The 1662 implementation is the proof of concept for a tradition-agnostic Office framework. Support for the 1928 and 1979 American BCPs and the Roman Breviary is planned.

---

## Scope

The current implementation covers:

**Scripture study:**
- Passage fetch by reference (`John 3:16`, `Psalm 23`, `Genesis 1:1-2:3`)
- Side-by-side or top-bottom layout: scripture buffer and org commentary file
- Proportional scroll synchronisation between the two buffers
- org-roam backlink panel for the current passage
- org-capture integration for quick marginal notes
- Verse number display with toggle; verse-based navigation

**BCP 1662 Daily Office:**
- Complete Morning and Evening Prayer ordos with rubrical options throughout
- Seasonal opening sentences (1662 pool and extended 1928 BCP corpus)
- Configurable canticles with optional Latin texts and per-canticle language overrides
- Lessons (OT and NT) fetched and inserted inline; Communion propers optionally appended
- Collects of the Day resolved from the full liturgical calendar
- Support for user-defined additional prayers

**Liturgical calendar:**
- Full BCP 1662 calendar including fixed feasts, moveable feasts, and occurrences
- User-defined feast overrides

**Scripture backends:**
- `coverdale` — Miles Coverdale's Psalter served locally from a bundled text file; no network required for psalms
- `oremus` — Oremus Bible Browser (online); KJVA, KJV, NRSV, NRSVAE, and psalm-specific versions
- `ebible` — local eBible.org plain-text chapter files; fully offline

---

## How It Works

### Architecture

The codebase is divided into four domains:

| Prefix | Domain |
|--------|--------|
| `bcp-` | Shared framework: computus, feast rank taxonomy, fetch/parse layer, buffer primitives |
| `bcp-liturgy-` | Generic Office machinery: canticle registry, ordo walker protocol |
| `bcp-1662-` | BCP 1662 implementation: calendar, lectionary, ordo, renderer |
| `bcp-reader` / `bcp-notebook` | Scripture reader and study notebook |

The fetch layer (`bcp-fetcher`) is shared by both the scripture reader and the Office engine. Translation settings, fallback chains, and caching apply uniformly across both.

### Rendering pipeline

1. `bcp-1662-open-office` determines the office (Morning or Evening Prayer) from the current time and date
2. `bcp-1662-propers-for-date` resolves the liturgical day: feast, season, week, collect, lessons, and communion propers
3. All psalm and lesson passages are fetched in parallel via the `bcp-fetcher` layer
4. Once all fetches complete (or time out), `bcp-1662--render-office` walks the ordo step sequence and inserts the full liturgy into the office buffer
5. The buffer is rendered read-only with overlays for verse numbers, rubric colouring, and heading styles

### Fetch backends

Fetch requests pass through a fallback chain:

1. **Primary backend** with preferred translation
2. **Primary backend** with fallback translation (default: KJVA)
3. **Fallback backend** with preferred translation

Available backends:

- `coverdale` — serves psalms from `bcp-liturgy-psalter-coverdale.txt` (local, no network required); returns `nil` for non-psalm passages so the chain continues
- `oremus` — fetches from [Oremus Bible Browser](https://bible.oremus.org) (online); supports KJVA, KJV, NRSV, NRSVAE, and psalm-specific versions (Coverdale/BCP, Common Worship, Liturgical Psalter)
- `ebible` — fetches from a local directory of eBible.org plain-text chapter files; fully offline

The default configuration is `coverdale` primary, `oremus` fallback. Psalms are served locally; lessons come from Oremus.

---

## Installation

1. Clone or download this repository into a directory on your Emacs load path, e.g. `~/.emacs.d/elisp/`.

2. Add the following to your `init.el`:

```elisp
(add-to-list 'load-path "~/.emacs.d/elisp")

(require 'bcp-fetcher)
(require 'bcp-fetcher-oremus)
(require 'bcp-calendar)
(require 'bcp-liturgy-canticles)
(require 'bcp-liturgy-render)
(require 'bcp-render)
(require 'bcp-1662-calendar)
(require 'bcp-1662-data)
(require 'bcp-1662-user-feasts)
(require 'bcp-1662-ordo)
(require 'bcp-1662-render)
(require 'bcp-1662)
(require 'bcp-reader)
(require 'bcp-notebook)

(load "~/.emacs.d/elisp/bcp-preferences.el")
```

3. Optionally bind the entry command:

```elisp
(global-set-key (kbd "C-c o") #'bcp-1662-open-office)
```

### Coverdale Psalter

The file `bcp-liturgy-psalter-coverdale.txt` is included in the repository. It contains all 150 psalms in Miles Coverdale's translation (the BCP 1662 Psalter) in a tab-separated format parsed by the Coverdale backend. No additional setup is required.

If you need to regenerate it (e.g. after updating the source files), load `bcp-coverdale-download.el` and call `M-x bcp-coverdale-download-collate`.

### eBible backend (optional, fully offline)

Download the plain-text KJV chapter files from [eBible.org](https://ebible.org) and set:

```elisp
(require 'bcp-fetcher-ebible)
(setq bcp-fetcher-backend 'ebible
      bcp-fetcher-ebible-directory "/path/to/eng-kjv/")
```

---

## Customisation

All settings are collected in `bcp-preferences.el`. Copy this file and edit it, or set variables directly in your `init.el`.

### Scripture translation

```elisp
;; Translation for lessons, epistles, and gospels
(setq bible-commentary-translation "KJVA")   ; KJVA KJV NRSV NRSVAE

;; Translation for the Psalter
(setq bible-commentary-psalm-translation "Coverdale")  ; Coverdale BCP KJVA CW LP NRSV
```

### Fetch backend

```elisp
;; Default: local Coverdale psalms, Oremus for lessons
(setq bcp-fetcher-backend 'coverdale
      bcp-fetcher-fallback-backend 'oremus)

;; Fully online (Oremus only)
(setq bcp-fetcher-backend 'oremus
      bcp-fetcher-fallback-backend nil)

;; Fully offline (eBible chapter files)
(setq bcp-fetcher-backend 'ebible
      bcp-fetcher-fallback-backend nil)
```

### Officiant order

Affects the form of the Absolution:

```elisp
(setq office-officiant 'lay)   ; lay deacon priest bishop
```

### Rubrical options

```elisp
;; Omit penitential introduction on weekdays
(setq bcp-1662-omit-penitential-intro nil)

;; Opening sentence corpus
(setq bcp-1662-opening-sentence-corpus '1662)
;;   '1662     — eleven penitential sentences from the BCP 1662
;;   'extended — seasonal sentence from 1928 BCP; falls back to 1662 pool

;; Opening sentence selection (when corpus is '1662)
(setq bcp-1662-opening-sentence-selection 'auto)
;;   'auto — one sentence, rotated by date
;;   'all  — all sentences read

;; Form of the Bidding ("Dearly beloved brethren...")
(setq bcp-1662-bidding-form 'full)
;;   'full  — complete 1662 text
;;   'brief — "Let us humbly confess our sins unto Almighty God." (1928 BCP)
;;   'omit  — omit entirely

;; General Confession variant
(setq bcp-1662-general-confession-form nil)
;;   nil      — standard 1662 text
;;   'variant — adds "And apart from thy grace, there is no health in us."
;;   'omit    — omit entirely

;; Venite: omit verses 8-11 outside Lent and Passiontide
(setq bcp-1662-omit-venite-passiontide nil)

;; Easter Anthems throughout all of Eastertide (not just Easter Day)
(setq bcp-1662-easter-anthems-throughout-eastertide nil)

;; Show Communion propers (OT reading, Epistle, Gospel) in the office buffer
(setq bcp-1662-show-communion-propers t)
```

### Canticles

```elisp
;; Append Gloria Patri after each canticle and psalm
(setq bcp-liturgy-canticle-append-gloria nil)

;; Default canticle language
(setq bcp-liturgy-canticle-language 'english)   ; 'english or 'latin

;; Per-canticle language overrides
(setq bcp-liturgy-canticle-overrides '((te-deum . latin)))
```

### Rendering

```elisp
;; Rubric style
(setq bcp-1662-rubric-style 'red)
;;   'red     — traditional liturgical red
;;   'comment — inherits font-lock-comment-face (theme-aware grey)

;; Morning Prayer cutoff hour (0-23)
(setq bcp-1662-morning-prayer-hour-limit 12)
```

### User-defined feasts

Add local or diocesan observances in `bcp-1662-user-feasts.el`. Each entry specifies a date, rank, collect, and lessons. See the file for format documentation.

### Additional prayers

```elisp
;; Append extra prayers after the five state prayers
(setq bcp-1662-additional-prayers
      '(my-prayer-for-the-sick
        "Almighty God, the fountain of all wisdom…"))
```

### Reload after changes

```elisp
M-x bcp-reload
```

Reloads all package files in dependency order without restarting Emacs.

---

## Acknowledgements

**Oremus Bible Browser** ([bible.oremus.org](https://bible.oremus.org)) is maintained by the Church of England and has provided free public access to scripture texts since the late 1990s. This project depends on it as its primary online scripture source.

**The Book of Common Prayer 1662** is a work of the Church of England and is in the public domain. The text of the 1662 BCP used here follows the standard edition.

**The Coverdale Psalter** — Miles Coverdale's translation of the Psalms, appointed in the BCP 1662 — is in the public domain. The bundled `bcp-liturgy-psalter-coverdale.txt` was prepared from the Oremus Bible Browser's BCP psalter texts.

**The Book of Common Prayer 1928** (American) is in the public domain. Opening sentences and the brief bidding form in this project are drawn from the 1928 Morning and Evening Prayer services.

**eBible.org** provides freely downloadable plain-text scripture files used by the optional `bcp-fetcher-ebible` backend.

The author would like to extend thanks to the creators of the [*1662 Daily Office Podcast*](https://creators.spotify.com/pod/profile/1662pod/) produced by [Trinity Anglican Church](https://trinityconnersville.com/) (Connersville, IN), for lowering the barrier of regularly praying Morning and Evening Prayer.

The author also wishes to thank the many wonderful members of the Personal Ordinariate of St. Peter for their personal kindness and their work in raising awareness of the richness of the Anglican traditions.

This project was inspired by [Divinum Officium](https://divinumofficium.com/), and represents the author's attempt to create a comparable service for the Book of Common Prayer.

This project was developed with the assistance of [Claude Code](https://claude.ai/claude-code) (Anthropic).

---

## Status

This project is in active personal use and development; both the scripture study and Office sides are in regular use. It is shared in the hope that others in the Anglican tradition who use Emacs may find it useful. Contributions, corrections, and suggestions are welcome.

Planned additions include: 1928 and 1979 American BCPs, canonical hours framework (Prime, Terce, Sext, None, Compline), multi-language prayer texts (*Liber Precum Publicarum*, Roman Breviary), and a `transient`-based preferences interface.
