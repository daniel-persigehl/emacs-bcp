;;; bcp-roman-ordo.el --- Roman Office ordo step definitions -*- lexical-binding: t -*-

;;; Commentary:

;; Ordo step definitions for the Roman Breviary (DA 1911 rubrics).
;; Parallel to `bcp-1662-ordo.el' for the Anglican side.
;;
;; Structure of each step:
;;
;;   (:rubric TEXT)
;;     — a rubrical direction (red text)
;;
;;   (:text KEY)
;;     — a fixed text resolved from the data layer by KEY
;;     — :silent t means the text is said silently (secreto)
;;
;;   (:versicles (V R) ...)
;;     — one or more versicle/response pairs
;;     — :key KEY resolves the pair(s) from the data layer
;;
;;   (:incipit)
;;     — Deus in adjutorium + Gloria Patri + Alleluia/Laus tibi
;;     — Alleluia suppressed in penitential seasons
;;
;;   (:antiphon KEY)
;;     — an antiphon text resolved by KEY from the data layer
;;     — :repeat t marks the closing repetition after the psalm group
;;
;;   (:psalm N)
;;     — a psalm by Vulgate number
;;     — :antiphon KEY gives each psalm its own antiphon (Lauds/Vespers)
;;
;;   (:hymn KEY)
;;     — a hymn resolved by KEY from the data layer
;;
;;   (:capitulum KEY)
;;     — a short chapter (capitulum) resolved by KEY
;;     — includes the scripture reference and the text
;;
;;   (:canticle KEY)
;;     — a canticle resolved by KEY, with wrapping antiphon
;;     — :antiphon KEY specifies the antiphon key
;;
;;   (:confession)
;;     — the penitential rite, resolved from `bcp-penitential-forms'
;;     — via `bcp-roman-confession-form' defcustom
;;
;;   (:absolution)
;;     — the absolution, resolved from `bcp-penitential-forms'
;;     — via `bcp-roman-absolution-form' defcustom
;;
;;   (:pre-oratio)
;;     — Kyrie, Dominus vobiscum, Oremus block before the collect
;;
;;   (:collect KEY)
;;     — a collect/oratio resolved by KEY from the data layer
;;
;;   (:conclusio)
;;     — Dominus vobiscum, Benedicamus Domino, Benedictio
;;
;;   (:marian-antiphon)
;;     — the seasonal final antiphon of the BVM, resolved by
;;     — the current liturgical season
;;
;;   (:silent-prayers KEYS)
;;     — one or more prayers said silently (Pater noster, Ave, Credo)
;;
;;   (:invitatory KEY)
;;     — the invitatory antiphon with Psalm 94 (Venite)
;;     — KEY resolves the invitatory antiphon text from the data layer
;;
;;   (:lesson N)
;;     — a Matins lesson by number (1-based within the nocturn)
;;     — :nocturn M gives the nocturn number (default 1)
;;     — resolved from the data layer by key
;;
;;   (:responsory KEY)
;;     — a responsory after a lesson
;;     — resolved from the data layer; plist (:respond TEXT :verse TEXT :repeat TEXT)
;;
;;   (:te-deum)
;;     — the Te Deum hymn, rendered via bcp-common-canticles
;;     — replaces the final responsory at Matins
;;
;;   (:lesson-absolutio N)
;;     — the absolutio before the lessons of nocturn N
;;     — resolved from bcp-roman-absolutiones or tradition-specific override
;;
;;   (:lesson-benedictio KEY N)
;;     — the benediction before lesson N within the nocturn
;;     — KEY resolves the benediction list; N is 0-based index
;;
;;   (:nocturn-versicle KEY)
;;     — versicle after the psalms of a nocturn, before the lessons

;;; Code:

(require 'bcp-common-roman)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Compline ordo

(defconst bcp-roman-lobvm-compline-ordo
  '(;; Incipit
    (:text jube-domne)
    (:text benedictio-compline)
    (:text ave-maria :silent t)
    (:versicles converte-nos)
    (:incipit)

    ;; Psalmi
    (:antiphon compline-antiphon)
    (:psalm 128)
    (:psalm 129)
    (:psalm 130)
    (:antiphon compline-antiphon :repeat t)

    ;; Hymnus
    (:hymn compline-hymn)

    ;; Capitulum et Versus
    (:capitulum compline-capitulum)
    (:versicles compline-versicle)

    ;; Canticum: Nunc dimittis
    (:canticle nunc-dimittis :antiphon compline-antiphon)

    ;; Oratio
    (:pre-oratio)
    (:collect compline-collect)

    ;; Conclusio
    (:conclusio)

    ;; Antiphona finalis B.M.V.
    (:marian-antiphon)

    ;; Prayers said silently
    (:text divinum-auxilium)
    (:silent-prayers (pater-noster ave-maria credo)))
  "Ordo for Compline of the Little Office of the Blessed Virgin Mary.
The structure is fixed across all seasons; seasonal variation is handled
by the data layer resolving different texts for antiphon and hymn keys.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Matins ordo
;;
;; The LOBVM Matins has one nocturn (votive nocturn) with three psalms,
;; three lessons from Sirach 24, and the Te Deum in place of the third
;; responsory.  The psalms are the Sunday Nocturn I set (8, 18, 23)
;; with Marian antiphons.

(defconst bcp-roman-lobvm-matins-ordo
  '(;; Incipit
    (:text ave-maria :silent t)
    (:incipit)

    ;; Invitatorium
    (:invitatory matins-invitatory)

    ;; Hymnus
    (:hymn matins-hymn)

    ;; Psalmi cum Antiphonis (Nocturn I)
    (:psalm 8   :antiphon matins-antiphon-1)
    (:psalm 18  :antiphon matins-antiphon-2)
    (:psalm 23  :antiphon matins-antiphon-3)

    ;; Versus post Nocturnum
    (:versicles matins-nocturn-versicle)

    ;; Pater noster (secreto)
    (:silent-prayers (pater-noster))

    ;; Absolutio
    (:lesson-absolutio 0)

    ;; Lectio I
    (:lesson-benedictio matins-benedictiones 0)
    (:lesson matins-lectio-1)
    (:responsory matins-responsory-1)

    ;; Lectio II
    (:lesson-benedictio matins-benedictiones 1)
    (:lesson matins-lectio-2)
    (:responsory matins-responsory-2)

    ;; Lectio III
    (:lesson-benedictio matins-benedictiones 2)
    (:lesson matins-lectio-3)
    (:te-deum)

    ;; Oratio
    (:pre-oratio)
    (:collect matins-collect)

    ;; Conclusio (not the full conclusio — Matins ends with the collect
    ;; when followed immediately by Lauds; standalone gets the conclusio)
    (:conclusio))
  "Ordo for Matins of the Little Office of the Blessed Virgin Mary.
One nocturn with three psalms, three lessons, Te Deum.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Lauds ordo

(defconst bcp-roman-lobvm-lauds-ordo
  '(;; Incipit
    (:text ave-maria :silent t)
    (:incipit)

    ;; Psalmi cum Antiphonis
    (:psalm 92  :antiphon lauds-antiphon-1)
    (:psalm 99  :antiphon lauds-antiphon-2)
    (:psalm 62  :antiphon lauds-antiphon-3)
    (:canticle benedicite :antiphon lauds-antiphon-4)
    (:psalm-group (148 149 150) :antiphon lauds-antiphon-5)

    ;; Hymnus
    (:hymn lauds-hymn)

    ;; Capitulum et Versus
    (:capitulum lauds-capitulum)
    (:versicles lauds-versicle)

    ;; Canticum: Benedictus
    (:canticle benedictus :antiphon lauds-canticle-antiphon)

    ;; Oratio
    (:pre-oratio)
    (:collect lauds-collect)

    ;; Commemoratio
    (:commemoratio)

    ;; Conclusio
    (:conclusio))
  "Ordo for Lauds of the Little Office of the Blessed Virgin Mary.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Vespers ordo

(defconst bcp-roman-lobvm-vespers-ordo
  '(;; Incipit
    (:text ave-maria :silent t)
    (:incipit)

    ;; Psalmi cum Antiphonis
    (:psalm 109 :antiphon vespers-antiphon-1)
    (:psalm 112 :antiphon vespers-antiphon-2)
    (:psalm 121 :antiphon vespers-antiphon-3)
    (:psalm 126 :antiphon vespers-antiphon-4)
    (:psalm 147 :antiphon vespers-antiphon-5)

    ;; Hymnus
    (:hymn vespers-hymn)

    ;; Capitulum et Versus
    (:capitulum vespers-capitulum)
    (:versicles vespers-versicle)

    ;; Canticum: Magnificat
    (:canticle magnificat :antiphon vespers-canticle-antiphon)

    ;; Oratio
    (:pre-oratio)
    (:collect vespers-collect)

    ;; Commemoratio
    (:commemoratio)

    ;; Conclusio
    (:conclusio))
  "Ordo for Vespers of the Little Office of the Blessed Virgin Mary.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Minor Hours ordines
;;
;; The four Little Hours share an identical structure (the "minor intro"
;; pattern from C12): Ave Maria, Deus in adjutorium, Hymnus minor, three
;; psalms under one antiphon, capitulum, versicle, collect, conclusio.

(defun bcp-roman-lobvm--minor-hour-ordo (hour ps1 ps2 ps3)
  "Build a minor hour ordo for HOUR with psalms PS1, PS2, PS3.
HOUR is a symbol used to construct data keys (e.g. `prime')."
  (let ((ant-key  (intern (format "%s-antiphon" hour)))
        (cap-key  (intern (format "%s-capitulum" hour)))
        (vers-key (intern (format "%s-versicle" hour)))
        (coll-key (intern (format "%s-collect" hour))))
    `((:text ave-maria :silent t)
      (:incipit)
      (:hymn minor-hymn)
      (:antiphon ,ant-key)
      (:psalm ,ps1)
      (:psalm ,ps2)
      (:psalm ,ps3)
      (:antiphon ,ant-key :repeat t)
      (:capitulum ,cap-key)
      (:versicles ,vers-key)
      (:pre-oratio)
      (:collect ,coll-key)
      (:conclusio))))

(defconst bcp-roman-lobvm-prime-ordo
  (bcp-roman-lobvm--minor-hour-ordo 'prime 53 84 116)
  "Ordo for Prime of the Little Office of the Blessed Virgin Mary.")

(defconst bcp-roman-lobvm-terce-ordo
  (bcp-roman-lobvm--minor-hour-ordo 'terce 119 120 121)
  "Ordo for Terce of the Little Office of the Blessed Virgin Mary.")

(defconst bcp-roman-lobvm-sext-ordo
  (bcp-roman-lobvm--minor-hour-ordo 'sext 122 123 124)
  "Ordo for Sext of the Little Office of the Blessed Virgin Mary.")

(defconst bcp-roman-lobvm-none-ordo
  (bcp-roman-lobvm--minor-hour-ordo 'none 125 126 127)
  "Ordo for None of the Little Office of the Blessed Virgin Mary.")

(provide 'bcp-roman-ordo)
;;; bcp-roman-ordo.el ends here
