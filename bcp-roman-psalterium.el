;;; bcp-roman-psalterium.el --- Weekly psalter cycle for the Roman Office -*- lexical-binding: t -*-

;;; Commentary:

;; Weekly psalter data for the Roman Breviary (DA 1911 rubrics).
;; Pre-extracted from Divinum Officium Psalterium files.
;;
;; Each hour's data is an alist keyed by day-of-week (0=Sunday through
;; 6=Saturday).  Antiphons are referenced by incipit symbols registered
;; in `bcp-roman-antiphonary.el'.  Psalm specs are integers (full psalm)
;; or lists (PSALM-NUM START-VERSE END-VERSE) for subsections.
;;
;; This file provides only the psalm/antiphon assignments and ferial
;; propers (capitula, versicles).  Psalm verse text comes from the
;; Vulgate/Coverdale psalter files via `bcp-fetcher'.
;;
;; Subsection specs use 1-based verse numbers matching the psalter
;; FILE's numbering (title verses excluded, renumbered from 1).
;; For psalms where the Vulgate numbers the title as v.1, the file's
;; v.1 corresponds to the Vulgate's v.2.

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Vespers psalm assignments
;;
;; 5 psalms per day, each with its own antiphon.
;; Entry shape: ((ANTIPHON-INCIPIT . PSALM-SPEC) ...)

(defconst bcp-roman-psalterium--vespers
  '((0 . ((dixit-dominus         . 109)
          (magna-opera-domini    . 110)
          (qui-timet-dominum     . 111)
          (sit-nomen-domini      . 112)
          (deus-autem-noster     . 113)))
    (1 . ((inclinavit-dominus    . 114)
          (vota-mea              . 115)
          (clamavi-et-dominus    . 119)
          (auxilium-meum         . 120)
          (laetatus-sum          . 121)))
    (2 . ((qui-habitas-in-caelis . 122)
          (adjutorium-nostrum    . 123)
          (in-circuitu-populi    . 124)
          (magnificavit-dominus  . 125)
          (dominus-aedificet     . 126)))
    (3 . ((beati-omnes           . 127)
          (confundantur-omnes    . 128)
          (de-profundis          . 129)
          (domine-non-est-exaltatum . 130)
          (elegit-dominus        . 131)))
    (4 . ((ecce-quam-bonum       . 132)
          (confitemini-domino-quoniam . (135 1 9))
          (confitemini-domino-quia    . (135 10 26))
          (adhaereat-lingua-mea  . 136)
          (confitebor-nomini-tuo . 137)))
    (5 . ((domine-probasti-me    . (138 1 13))
          (mirabilia-opera-tua   . (138 14 23))
          (ne-derelinquas-me     . 139)
          (domine-clamavi-ad-te  . 140)
          (educ-de-custodia      . 141)))
    (6 . ((benedictus-dominus-susceptor . (143 1 8))
          (beatus-populus        . (143 9 15))
          (magnus-dominus-et-laudabilis . (144 1 7))
          (suavis-dominus        . (144 8 13))
          (fidelis-dominus       . (144 13 21)))))
  "Vespers psalm assignments by day of week.
Each entry is ((ANTIPHON-INCIPIT . PSALM-SPEC) ...).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline psalm assignments
;;
;; 3 psalms under one antiphon per day.
;; Entry shape: (:antiphon INCIPIT :psalms (SPEC ...))

(defconst bcp-roman-psalterium--compline
  '((0 . (:antiphon miserere-mihi-domine
          :psalms (4 90 133)))
    (1 . (:antiphon salvum-me-fac-domine
          :psalms (6 (7 1 9) (7 10 18))))
    (2 . (:antiphon tu-domine-servabis
          :psalms (11 12 15)))
    (3 . (:antiphon immittet-angelus
          :psalms ((33 1 10) (33 11 22) 60)))
    (4 . (:antiphon adjutor-meus
          :psalms (69 (70 1 12) (70 13 24))))
    (5 . (:antiphon voce-mea-ad-dominum
          :psalms ((76 1 12) (76 13 20) 85)))
    (6 . (:antiphon intret-oratio-mea
          :psalms (87 (102 1 12) (102 13 22)))))
  "Compline psalm assignments by day of week.
Each entry is (:antiphon INCIPIT :psalms (SPEC ...)).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds psalm assignments
;;
;; 5 units per day: 3 psalms + 1 OT canticle + 1 praise psalm.
;; Laudes1 set (per annum, non-penitential).
;; Canticle numbers (210–216) are handled as special keys by the resolver.
;; Entry shape: ((ANTIPHON-INCIPIT . PSALM-SPEC) ...)

(defconst bcp-roman-psalterium--lauds
  '((0 . ((alleluia-dominus-regnavit       . 92)
          (jubilate-deo-omnis-terra        . 99)
          (benedicam-te-in-vita            . 62)
          (tres-pueri                      . 210)
          (alleluia-laudate-dominum-de-caelis . 148)))
    (1 . ((jubilate-deo-in-voce            . 46)
          (intende-voci                    . 5)
          (deus-majestatis                 . 28)
          (laudamus-nomen-tuum             . 211)
          (laudate-dominum-omnes-gentes    . 116)))
    (2 . ((cantate-domino-et-benedicite    . 95)
          (salutare-vultus-mei             . 42)
          (illumina-domine-vultum          . 66)
          (exaltate-regem                  . 212)
          (laudate-nomen-domini            . 134)))
    (3 . ((dominus-regnavit-exsultet       . 96)
          (te-decet-hymnus                 . 64)
          (tibi-domine-psallam             . 100)
          (domine-magnus-es-tu             . 213)
          (laudabo-deum-meum               . 145)))
    (4 . ((jubilate-in-conspectu            . 97)
          (domine-refugium                 . 89)
          (domine-in-caelo-misericordia    . 35)
          (populus-meus-bonis              . 214)
          (deo-nostro-jucunda              . 146)))
    (5 . ((exaltate-dominum-deum           . 98)
          (eripe-me-de-inimicis            . 142)
          (benedixisti-domine              . 84)
          (in-domino-justificabitur        . 215)
          (lauda-jerusalem                 . 147)))
    (6 . ((filii-sion-exsultent            . 149)
          (quam-magnificata                . 91)
          (laetabitur-justus               . 63)
          (ostende-nobis-domine            . 216)
          (omnis-spiritus-laudet           . 150))))
  "Lauds (Laudes1) psalm assignments by day of week.
Each entry is ((ANTIPHON-INCIPIT . PSALM-SPEC) ...).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Prime psalm assignments
;;
;; 3 psalms under one antiphon, plus a bracketed psalm-of-the-day.
;; Entry shape: (:antiphon INCIPIT :psalms (SPEC ...) :psalm-of-day NUM)

(defconst bcp-roman-psalterium--prime
  '((0 . (:antiphon alleluia-confitemini-domino
          :psalms (117 (118 1 16) (118 17 32))))
    (1 . (:antiphon innocens-manibus
          :psalms (23 (18 1 7) (18 8 16))
          :psalm-of-day 46))
    (2 . (:antiphon deus-meus-in-te-confido
          :psalms ((24 1 8) (24 9 15) (24 16 23))
          :psalm-of-day 95))
    (3 . (:antiphon misericordia-tua-domine
          :psalms (25 51 52)
          :psalm-of-day 96))
    (4 . (:antiphon in-loco-pascuae
          :psalms (22 (71 1 8) (71 9 20))
          :psalm-of-day 97))
    (5 . (:antiphon ne-discedas-a-me
          :psalms ((21 1 11) (21 12 22) (21 23 34))
          :psalm-of-day 98))
    (6 . (:antiphon exaltare-domine-qui-judicas
          :psalms ((93 1 11) (93 12 23) 107)
          :psalm-of-day 149)))
  "Prime psalm assignments by day of week.
Each entry is (:antiphon INCIPIT :psalms (SPEC ...) [:psalm-of-day NUM]).
The psalm-of-the-day is recited in addition to the three main psalms.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Terce psalm assignments
;;
;; 3 psalms under one antiphon per day.
;; Entry shape: (:antiphon INCIPIT :psalms (SPEC ...))

(defconst bcp-roman-psalterium--terce
  '((0 . (:antiphon alleluia-deduc-me
          :psalms ((118 33 48) (118 49 64) (118 65 80))))
    (1 . (:antiphon illuminatio-mea
          :psalms ((26 1 11) (26 12 20) 27)))
    (2 . (:antiphon respexit-me
          :psalms ((39 1 11) (39 12 18) (39 19 24))))
    (3 . (:antiphon deus-adjuvat-me
          :psalms (53 (54 1 17) (54 18 27))))
    (4 . (:antiphon quam-bonus-israel
          :psalms ((72 1 9) (72 10 17) (72 18 28))))
    (5 . (:antiphon excita-domine-potentiam
          :psalms ((79 1 8) (79 9 20) 81)))
    (6 . (:antiphon clamor-meus-domine
          :psalms ((101 1 13) (101 14 23) (101 24 29)))))
  "Terce psalm assignments by day of week.
Each entry is (:antiphon INCIPIT :psalms (SPEC ...)).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sext psalm assignments

(defconst bcp-roman-psalterium--sext
  '((0 . (:antiphon alleluia-tuus-sum-ego
          :psalms ((118 81 96) (118 97 112) (118 113 128))))
    (1 . (:antiphon in-tua-justitia
          :psalms ((30 1 9) (30 10 22) (30 23 31))))
    (2 . (:antiphon suscepisti-me-domine
          :psalms (40 (41 1 5) (41 6 16))))
    (3 . (:antiphon in-deo-speravi-non-timebo
          :psalms (55 56 57)))
    (4 . (:antiphon memor-esto-congregationis
          :psalms ((73 1 10) (73 11 17) (73 18 24))))
    (5 . (:antiphon beati-qui-habitant
          :psalms ((83 1 7) (83 8 13) 86)))
    (6 . (:antiphon domine-deus-meus-magnificatus
          :psalms ((103 1 13) (103 14 24) (103 25 36)))))
  "Sext psalm assignments by day of week.
Each entry is (:antiphon INCIPIT :psalms (SPEC ...)).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; None psalm assignments

(defconst bcp-roman-psalterium--none
  '((0 . (:antiphon alleluia-faciem-tuam
          :psalms ((118 129 144) (118 145 160) (118 161 176))))
    (1 . (:antiphon exsultate-justi
          :psalms (31 (32 1 11) (32 12 22))))
    (2 . (:antiphon salvasti-nos-domine
          :psalms ((43 1 10) (43 11 21) (43 22 28))))
    (3 . (:antiphon deus-meus-misericordia
          :psalms ((58 1 11) (58 12 20) 59)))
    (4 . (:antiphon invocabimus-nomen-tuum
          :psalms (74 (75 1 6) (75 7 12))))
    (5 . (:antiphon misericordia-et-veritas
          :psalms ((88 1 18) (88 19 36) (88 37 51))))
    (6 . (:antiphon ne-tacueris-deus
          :psalms ((108 1 12) (108 13 20) (108 21 30)))))
  "None psalm assignments by day of week.
Each entry is (:antiphon INCIPIT :psalms (SPEC ...)).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Benedictus antiphons (ferial per-annum, by day of week)

(defconst bcp-roman-psalterium--benedictus-antiphons
  '((1 . benedictus-dominus-deus-israel)
    (2 . erexit-nobis)
    (3 . de-manu-omnium)
    (4 . in-sanctitate-serviamus)
    (5 . per-viscera-misericordiae)
    (6 . illumina-domine-sedentes))
  "Ferial per-annum Benedictus antiphon incipits by day of week.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Magnificat antiphons (ferial per-annum, by day of week)

(defconst bcp-roman-psalterium--magnificat-antiphons
  '((1 . magnificat-anima-mea-quia)
    (2 . exsultavit-spiritus)
    (3 . respexit-dominus-humilitatem)
    (4 . fecit-deus-potentiam)
    (5 . deposuit-dominus)
    (6 . suscepit-deus-israel))
  "Ferial per-annum Magnificat antiphon incipits by day of week.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Vespers ferial capitulum and versicle
;;
;; Ferial Vespers uses the same capitulum as the Sunday office (from
;; Major Special.txt [Dominica Vespera] / [Feria Vespera]).

(defconst bcp-roman-psalterium--vespers-capitulum
  '(:ref "2 Cor. 1:3-4"
    :text "Benedíctus Deus et Pater Dómini nostri Jesu Christi, Pater \
misericordiárum, et Deus totíus consolatiónis, qui consolátur nos in \
omni tribulatióne nostra.")
  "Ferial/Dominical Vespers capitulum (per-annum).")

(defconst bcp-roman-psalterium--vespers-versicle
  '("Vespertína orátio ascéndat ad te, Dómine."
    "Et descéndat super nos misericórdia tua.")
  "Ferial Vespers versicle (per-annum).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline ferial capitulum and versicle

(defconst bcp-roman-psalterium--compline-capitulum
  '(:ref "Jer. 14:9"
    :text "Tu autem in nobis es, Dómine, et nomen sanctum tuum \
invocátum est super nos: ne derelínquas nos, Dómine, Deus noster.")
  "Compline capitulum (invariant).")

(defconst bcp-roman-psalterium--compline-versicle
  '("Custódi nos, Dómine, ut pupíllam óculi."
    "Sub umbra alárum tuárum prótege nos.")
  "Compline versicle (invariant).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds ferial capitulum and versicle

(defconst bcp-roman-psalterium--lauds-capitulum
  '(:ref "Rom. 13:12-13"
    :text "Nox præcéssit, dies autem appropinquávit. Abiciámus ergo \
ópera tenebrárum, et induámur arma lucis. Sicut in die honéste \
ambulémus.")
  "Ferial Lauds capitulum (per-annum).")

(defconst bcp-roman-psalterium--lauds-versicle
  '("Repléti sumus mane misericórdia tua."
    "Exsultávimus, et delectáti sumus.")
  "Ferial Lauds versicle (per-annum).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Prime ferial capitulum, responsory, and versicle

(defconst bcp-roman-psalterium--prime-capitulum
  '(:ref "2 Thess. 3:5"
    :text "Dóminus autem dírigat corda et córpora nostra in caritáte \
Dei et patiéntia Christi.")
  "Prime capitulum (per annum).")

(defconst bcp-roman-psalterium--prime-responsory
  '(:respond "Christe, Fili Dei vivi, * Miserére nobis."
    :versus  "Qui sedes ad déxteram Patris."
    :repeat  "Miserére nobis.")
  "Prime short responsory (per annum).")

(defconst bcp-roman-psalterium--prime-versicle
  '("Exsúrge, Christe, ádjuva nos."
    "Et líbera nos propter nomen tuum.")
  "Prime versicle.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Minor hours (Terce/Sext/None) capitula and versicles
;;
;; Each has a dominical (Sunday) and ferial form.

(defconst bcp-roman-psalterium--terce-capitulum
  '(:dominical (:ref "1 Joann. 4:16"
                :text "Deus cáritas est: et qui manet in caritáte, in \
Deo manet, et Deus in eo.")
    :ferial    (:ref "Jer. 17:14"
                :text "Sana me, Dómine, et sanábor: salvum me fac, et \
salvus ero: quóniam laus mea tu es."))
  "Terce capitulum (dominical and ferial per-annum).")

(defconst bcp-roman-psalterium--terce-versicle
  '(:dominical ("Ego dixi: Dómine, miserére mei."
                "Sana ánimam meam, quia peccávi tibi.")
    :ferial    ("Adjútor meus, esto, ne derelínquas me."
                "Neque despícias me, Deus, salutáris meus."))
  "Terce versicle (dominical and ferial per-annum).")

(defconst bcp-roman-psalterium--sext-capitulum
  '(:dominical (:ref "Gal. 6:2"
                :text "Alter altérius ónera portáte, et sic adimplébitis \
legem Christi.")
    :ferial    (:ref "Rom. 13:8"
                :text "Némini quidquam debeátis, nisi ut ínvicem \
diligátis: qui enim díligit próximum, legem implévit."))
  "Sext capitulum (dominical and ferial per-annum).")

(defconst bcp-roman-psalterium--sext-versicle
  '("Dóminus regit me, et nihil mihi déerit."
    "In loco páscuæ ibi me collocávit.")
  "Sext versicle (invariant per-annum).")

(defconst bcp-roman-psalterium--none-capitulum
  '(:dominical (:ref "1 Cor. 6:20"
                :text "Empti enim estis prétio magno. Glorificáte et \
portáte Deum in córpore vestro.")
    :ferial    (:ref "1 Pet. 1:17-19"
                :text "In timóre incolátus vestri témpore conversámini: \
sciéntes quod non corruptibílibus auro vel argénto redémpti estis, sed \
pretióso sánguine quasi Agni immaculáti Christi."))
  "None capitulum (dominical and ferial per-annum).")

(defconst bcp-roman-psalterium--none-versicle
  '("Ab occúltis meis munda me, Dómine."
    "Et ab aliénis parce servo tuo.")
  "None versicle (invariant per-annum).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Vespers hymn assignment by day of week

(defconst bcp-roman-psalterium--vespers-hymns
  '((0 . lucis-creator-optime)
    (1 . immense-caeli-conditor)
    (2 . telluris-alme-conditor)
    (3 . caeli-deus-sanctissime)
    (4 . magne-deus-potentiae)
    (5 . hominis-superne-conditor)
    (6 . jam-sol-recedit-igneus))
  "Vespers hymn incipit by day of week.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds hymn assignment by day of week

(defconst bcp-roman-psalterium--lauds-hymns
  '((0 . ecce-jam-noctis)
    (1 . splendor-paternae-gloriae)
    (2 . ales-diei-nuntius)
    (3 . nox-et-tenebrae)
    (4 . lux-ecce-surgit-aurea)
    (5 . aeterna-caeli-gloria)
    (6 . aurora-jam-spargit-polum))
  "Lauds hymn incipit by day of week.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Prime, Terce, Sext, None hymns (invariant per annum)

(defconst bcp-roman-psalterium--prime-hymn 'jam-lucis-orto-sidere
  "Prime hymn incipit (invariant, per annum).")

(defconst bcp-roman-psalterium--terce-hymn 'nunc-sancte-nobis-spiritus
  "Terce hymn incipit (invariant, per annum).")

(defconst bcp-roman-psalterium--sext-hymn 'rector-potens-verax-deus
  "Sext hymn incipit (invariant, per annum).")

(defconst bcp-roman-psalterium--none-hymn 'rerum-deus-tenax-vigor
  "None hymn incipit (invariant, per annum).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline hymn and Nunc dimittis antiphon (invariant)

(defconst bcp-roman-psalterium--compline-hymn 'te-lucis-ante-terminum
  "Compline hymn incipit (invariant, per annum).")

(defconst bcp-roman-psalterium--compline-nunc-dimittis-antiphon
  'salva-nos-domine
  "Nunc dimittis antiphon at Compline (invariant).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public accessors

(defun bcp-roman-psalterium-vespers-psalms (dow)
  "Return Vespers psalm/antiphon list for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--vespers))

(defun bcp-roman-psalterium-compline-psalms (dow)
  "Return Compline plist for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--compline))

(defun bcp-roman-psalterium-magnificat-antiphon (dow)
  "Return the ferial per-annum Magnificat antiphon incipit for DOW."
  (alist-get dow bcp-roman-psalterium--magnificat-antiphons))

(defun bcp-roman-psalterium-vespers-hymn (dow)
  "Return the Vespers hymn incipit for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--vespers-hymns))

(defun bcp-roman-psalterium-lauds-psalms (dow)
  "Return Lauds psalm/antiphon list for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--lauds))

(defun bcp-roman-psalterium-lauds-hymn (dow)
  "Return the Lauds hymn incipit for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--lauds-hymns))

(defun bcp-roman-psalterium-benedictus-antiphon (dow)
  "Return the ferial per-annum Benedictus antiphon incipit for DOW."
  (alist-get dow bcp-roman-psalterium--benedictus-antiphons))

(defun bcp-roman-psalterium-prime-psalms (dow)
  "Return Prime plist for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--prime))

(defun bcp-roman-psalterium-terce-psalms (dow)
  "Return Terce plist for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--terce))

(defun bcp-roman-psalterium-sext-psalms (dow)
  "Return Sext plist for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--sext))

(defun bcp-roman-psalterium-none-psalms (dow)
  "Return None plist for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--none))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Ferial preces
;;
;; V./R. pairs from DO Preces.txt.  Each preces set is a list of
;; (VERSICLE RESPONSE) pairs.  Rubrical notes like "(deinde dicitur)"
;; are omitted; the renderer inserts all pairs sequentially.
;;
;; Lauds/Vespers ferial preces are split into three parts:
;;   1. Initial V/R pairs (before the psalm)
;;   2. Psalm (129 for Lauds, 50 for Vespers) — rendered as a step
;;   3. Closing V/R pairs (after the psalm)

;;; ─── Lauds/Vespers ferial preces (shared initial block) ─────────────────

(defconst bcp-roman-psalterium--preces-feriales-major
  '(("Ego dixi: Dómine, miserére mei."
     "Sana ánimam meam quia peccávi tibi.")
    ("Convértere, Dómine, úsquequo?"
     "Et deprecábilis esto super servos tuos.")
    ("Fiat misericórdia tua, Dómine, super nos."
     "Quemádmodum sperávimus in te.")
    ("Sacerdótes tui induántur justítiam."
     "Et sancti tui exsúltent.")
    ("Dómine, salvum fac regem."
     "Et exáudi nos in die, qua invocavérimus te.")
    ("Salvum fac pópulum tuum, Dómine, et bénedic hereditáti tuæ."
     "Et rege eos, et extólle illos usque in ætérnum.")
    ("Meménto Congregatiónis tuæ."
     "Quam possedísti ab inítio.")
    ("Fiat pax in virtúte tua."
     "Et abundántia in túrribus tuis.")
    ("Orémus pro fidélibus defúnctis."
     "Réquiem ætérnam dona eis, Dómine, et lux perpétua lúceat eis.")
    ("Requiéscant in pace."
     "Amen.")
    ("Pro frátribus nostris abséntibus."
     "Salvos fac servos tuos, Deus meus, sperántes in te.")
    ("Pro afflíctis et captívis."
     "Líbera eos, Deus Israël, ex ómnibus tribulatiónibus suis.")
    ("Mitte eis, Dómine, auxílium de sancto."
     "Et de Sion tuére eos.")
    ("Dómine, exáudi oratiónem meam."
     "Et clamor meus ad te véniat."))
  "Ferial preces for Lauds/Vespers — initial V./R. pairs (Latin).")

(defconst bcp-roman-psalterium--preces-feriales-major-en
  '(("I said: Lord, be merciful unto me:"
     "Heal my soul, for I have sinned against thee.")
    ("Turn thee again, O Lord; how long will it be?"
     "And be gracious unto thy servants.")
    ("Let thy mercy, O Lord, be upon us."
     "As we have hoped in thee.")
    ("Let thy priests be clothed with justice:"
     "And may thy saints rejoice.")
    ("O Lord, save our leaders."
     "And mercifully hear us when we call upon thee.")
    ("O Lord, save thy people, and bless thine inheritance:"
     "Govern them and lift them up for ever.")
    ("Remember thy congregation,"
     "Which thou hast possessed from the beginning.")
    ("Let peace be in thy strength:"
     "And abundance in thy towers.")
    ("Let us pray for the faithful departed."
     "Eternal rest grant unto them, O Lord, and let perpetual light shine upon them.")
    ("May they rest in peace."
     "Amen.")
    ("Let us pray for our absent brothers."
     "Save thy servants, O God, who put their trust in thee.")
    ("Let us pray for the afflicted and imprisoned."
     "Deliver them, God of Israel, from all their tribulations.")
    ("O Lord, send them help from thy sanctuary."
     "And defend them out of Sion.")
    ("O Lord, hear my prayer:"
     "And let my cry come unto thee."))
  "Ferial preces for Lauds/Vespers — initial V./R. pairs (English).")

;;; ─── Lauds/Vespers closing preces (after the psalm) ─────────────────────

(defconst bcp-roman-psalterium--preces-feriales-major-coda
  '(("Dómine, Deus virtútum, convérte nos."
     "Et osténde fáciem tuam, et salvi érimus.")
    ("Exsúrge, Christe, ádjuva nos."
     "Et líbera nos propter nomen tuum."))
  "Ferial preces for Lauds/Vespers — closing V./R. pairs (Latin).")

(defconst bcp-roman-psalterium--preces-feriales-major-coda-en
  '(("Turn us again, O Lord, God of Hosts."
     "Show us thy face, and we shall be whole.")
    ("Arise, O Christ, and help us."
     "And redeem us for thy name's sake."))
  "Ferial preces for Lauds/Vespers — closing V./R. pairs (English).")

;;; ─── Prime ferial preces ─────────────────────────────────────────────────

(defconst bcp-roman-psalterium--preces-feriales-prime
  '(("Éripe me, Dómine, ab hómine malo."
     "A viro iníquo éripe me.")
    ("Éripe me de inimícis meis, Deus meus."
     "Et ab insurgéntibus in me líbera me.")
    ("Éripe me de operántibus iniquitátem."
     "Et de viris sánguinum salva me.")
    ("Sic psalmum dicam nómini tuo in sǽculum sǽculi."
     "Ut reddam vota mea de die in diem.")
    ("Exáudi nos, Deus, salutáris noster."
     "Spes ómnium fínium terræ, et in mari longe.")
    ("Deus in adjutórium meum inténde."
     "Dómine, ad adjuvándum me festína.")
    ("Sanctus Deus, Sanctus fortis, Sanctus immortális."
     "Miserére nobis.")
    ("Bénedic, ánima mea, Dómino."
     "Et ómnia, quæ intra me sunt, nómini sancto ejus.")
    ("Bénedic, ánima mea, Dómino."
     "Et noli oblivísci omnes retributiónes ejus.")
    ("Qui propitiátur ómnibus iniquitátibus tuis."
     "Qui sanat omnes infirmitátes tuas.")
    ("Qui rédimit de intéritu vitam tuam."
     "Qui corónat te in misericórdia et miseratiónibus.")
    ("Qui replet in bonis desidérium tuum."
     "Renovábitur ut áquilæ juvéntus tua."))
  "Ferial preces at Prime (Latin).")

(defconst bcp-roman-psalterium--preces-feriales-prime-en
  '(("Deliver me, O Lord, from the evil man."
     "Rescue me from the unjust man.")
    ("Deliver me from my enemies, O my God."
     "And defend me from them that rise up against me.")
    ("Deliver me from them that work iniquity."
     "And save me from bloody men.")
    ("So will I sing a psalm to thy name for ever and ever."
     "That I may pay my vows from day to day.")
    ("Hear us, O God our saviour."
     "Who art the hope of all the ends of the earth, and of the sea afar off.")
    ("O God come to my assistance;"
     "O Lord, make haste to help me.")
    ("O holy God, Oh holy strength, Oh holy and immortal one."
     "Have mercy on us.")
    ("Bless the Lord, O my soul."
     "And let all that is within me bless his holy name.")
    ("Bless the Lord, O my soul."
     "And forget not all his benefits.")
    ("Who forgives all thy iniquities."
     "Who heals all thy infirmities.")
    ("Who has redeemed thy life from destruction."
     "Who crowns thee with mercy and compassion.")
    ("Who satisfies thy desire with good things."
     "Thy youth shall be renewed like the eagle's."))
  "Ferial preces at Prime (English).")

;;; ─── Minor hours ferial preces ───────────────────────────────────────────

(defconst bcp-roman-psalterium--preces-feriales-minor
  '(("Dómine, Deus virtútum, convérte nos."
     "Et osténde fáciem tuam, et salvi érimus.")
    ("Exsúrge, Christe, ádjuva nos."
     "Et líbera nos propter nomen tuum.")
    ("Dómine, exáudi oratiónem meam."
     "Et clamor meus ad te véniat."))
  "Ferial preces at minor hours — Terce, Sext, None (Latin).")

(defconst bcp-roman-psalterium--preces-feriales-minor-en
  '(("Turn us again, O Lord God of hosts:"
     "Show us thy face, and we shall be saved.")
    ("Arise, O Christ, and help us"
     "And deliver us for thy name's sake.")
    ("O Lord, hear my prayer:"
     "And let my cry come unto thee."))
  "Ferial preces at minor hours — Terce, Sext, None (English).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Suffragium sanctorum (DA form)
;;
;; Three commemorations at Lauds and Vespers on simple ferias:
;;   1. De Cruce (or De Resurrectione in Eastertide)
;;   2. De Omnibus Sanctis (Suffragium Divino — DA consolidated form)
;;   3. De Pace
;;
;; Each is a plist with :antiphon, :versicle, :response, :collect.

;;; ─── De Cruce ────────────────────────────────────────────────────────────

(defconst bcp-roman-psalterium--suffragium-de-cruce
  '(:heading "De Cruce"
    :antiphon "Per signum Crucis de inimícis nostris líbera nos, Deus noster."
    :versicle "Omnis terra adóret te, et psallat tibi."
    :response "Psalmum dicat nómini tuo, Dómine."
    :collect "Perpétua nos, quǽsumus, Dómine, pace custódi, quos per lignum \
sanctæ Crucis redímere dignátus es.")
  "Suffragium de Cruce (Latin).")

(defconst bcp-roman-psalterium--suffragium-de-cruce-en
  '(:heading "Of the Cross"
    :antiphon "Deliver us from our enemies, O thou our God, by the sign of the Cross."
    :versicle "Let all the earth adore thee, and sing to thee."
    :response "Let it sing a psalm to thy name, O Lord."
    :collect "Keep us, we beseech thee, O Lord, in everlasting peace, whom thou \
didst deign to redeem by the wood of the holy Cross.")
  "Suffragium de Cruce (English).")

;;; ─── De Omnibus Sanctis (Suffragium Divino) ─────────────────────────────

(defconst bcp-roman-psalterium--suffragium-divino
  '(:heading "De Omnibus Sanctis"
    :antiphon "Beáta Dei Génitrix Virgo María, Sanctíque omnes intercédant \
pro nobis ad Dóminum."
    :versicle "Mirificávit Dóminus Sanctos suos."
    :response "Et exaudívit eos clamántes ad se."
    :collect "A cunctis nos, quǽsumus, Dómine, mentis et córporis defénde \
perículis: et, intercedénte beáta et gloriósa semper Vírgine Dei Genitríce \
María, cum beáto Joseph, beátis Apóstolis tuis Petro et Paulo, atque beáto \
N. et ómnibus Sanctis, salútem nobis tríbue benígnus et pacem; ut, \
destrúctis adversitátibus et erróribus univérsis, Ecclésia tua secúra tibi \
sérviat libertáte.\nPer Dóminum.")
  "Suffragium Divino — DA consolidated form (Latin).")

(defconst bcp-roman-psalterium--suffragium-divino-en
  '(:heading "Of All Saints"
    :antiphon "May the Blessed Virgin Mary, Mother of God, and all the Saints \
intercede for us with the Lord."
    :versicle "The Lord hath made his holy one wonderful."
    :response "The Lord will hear me when I cry unto him."
    :collect "O Lord, we ask thee to save us from dangers to mind and to body: \
and, by the intercession of the blessed and glorious Virgin Mother of God, \
blessed Joseph, the blessed Apostles Peter and Paul, blessed N. and all the \
Saints, to eliminate all enmity and errors, that thy Church may safely serve \
thee in freedom.\nThrough our Lord.")
  "Suffragium Divino — DA consolidated form (English).")

;;; ─── De Pace ─────────────────────────────────────────────────────────────

(defconst bcp-roman-psalterium--suffragium-de-pace
  '(:heading "Pro Pace"
    :antiphon "Da pacem Dómine in diébus nostris, quia non est álius, qui \
pugnet pro nobis, nisi tu Deus noster."
    :versicle "Fiat pax in virtúte tua."
    :response "Et abundántia in túrribus tuis."
    :collect "Deus, a quo sancta desidéria, recta consília, et justa sunt \
ópera: da servis tuis illam, quam mundus dare non potest, pacem; ut et \
corda nostra mandátis tuis dédita, et hóstium subláta formídine, témpora \
sint tua protectióne tranquílla.\nPer Dóminum.")
  "Suffragium de Pace (Latin).")

(defconst bcp-roman-psalterium--suffragium-de-pace-en
  '(:heading "For Peace"
    :antiphon "Give peace in our time, O Lord, because there is no one else \
who fights for us, if not You, our God."
    :versicle "Peace be within thy walls."
    :response "And prosperity within thy palaces."
    :collect "O God, from whom all holy desires, all good counsels, and all just \
works do proceed; Give unto thy servants that peace which the world cannot give; \
so that, with our hearts set to obey thy commandments, and freed from the fear \
of the enemy, we may pass our lives in peace under thy protection.\n\
Through our Lord.")
  "Suffragium de Pace (English).")

;;; ─── Suffragium assembly ─────────────────────────────────────────────────

(defun bcp-roman-psalterium-suffragium (language)
  "Return the list of suffragium commemorations for LANGUAGE.
Each element is a plist with :heading, :antiphon, :versicle,
:response, :collect."
  (let ((en (eq language 'english)))
    (list (if en bcp-roman-psalterium--suffragium-de-cruce-en
            bcp-roman-psalterium--suffragium-de-cruce)
          (if en bcp-roman-psalterium--suffragium-divino-en
            bcp-roman-psalterium--suffragium-divino)
          (if en bcp-roman-psalterium--suffragium-de-pace-en
            bcp-roman-psalterium--suffragium-de-pace))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins psalm assignments (ferial Daya cursus)
;;
;; Ferial weekday Matins (DA 1911): 1 nocturn, 12 psalms under 6 antiphons.
;; Each antiphon covers 2 psalms.  Sunday uses the 3-nocturn dominical
;; arrangement (deferred — Sundays are not ferial).
;; Entry shape: ((ANTIPHON-INCIPIT . (PSALM-A PSALM-B)) ...)

(defconst bcp-roman-psalterium--matins
  '((1 . ((dominus-defensor               . (26 27))
          (adorate-dominum-in-aula         . (28 29))
          (in-tua-justitia                 . (30 31))
          (rectos-decet                    . (32 33))
          (expugna-impugnantes             . (34 35))
          (revela-domino                   . (36 37))))
    (2 . ((ut-non-delinquam               . (38 39))
          (sana-domine-animam              . (40 41))
          (eructavit-cor-meum              . (43 44))
          (adjutor-in-tribulationibus      . (45 46))
          (magnus-dominus-laudabilis       . (47 48))
          (deus-deorum                     . (49 51))))
    (3 . ((avertit-dominus                 . (52 54))
          (quoniam-in-te-confidit          . (55 56))
          (juste-judicate                  . (57 58))
          (da-nobis-domine-auxilium        . (59 60))
          (nonne-deo-subjecta              . (61 63))
          (benedicite-gentes               . (65 67))))
    (4 . ((domine-deus-in-adjutorium       . (68 69))
          (esto-mihi-in-deum               . (70 71))
          (liberasti-virgam                . (72 73))
          (et-invocabimus-nomen            . (74 75))
          (tu-es-deus-qui-facis            . (76 77))
          (propitius-esto-peccatis         . (78 79))))
    (5 . ((exsultate-deo-adjutori          . (80 81))
          (tu-solus-altissimus             . (82 83))
          (benedixisti-domine-terram       . (84 85))
          (fundamenta-ejus                 . (86 87))
          (benedictus-dominus-in-aeternum  . (88 93))
          (cantate-domino-benedicite-nominis . (95 96))))
    (6 . ((quia-mirabilia-fecit            . (97 98))
          (jubilate-deo-omnis              . (99 100))
          (clamor-meus-ad-te-veniat        . (101 102))
          (benedic-anima-mea-domino        . (103 104))
          (visita-nos-domine               . (105 106))
          (confitebor-domino-nimis         . (107 108)))))
  "Ferial Matins psalm assignments by day of week (Daya cursus).
Each entry is ((ANTIPHON-INCIPIT . (PSALM-A PSALM-B)) ...).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Dominical (Sunday) Matins psalm data — 3 nocturns
;;
;; Sunday Matins uses 3 nocturns of 3 psalms each (9 total),
;; with antiphons from the Psalterium.  Psalm specs are either
;; a number or (PSALM START END) for subsections.

(defconst bcp-roman-psalterium--matins-dominical
  '(:nocturn-1 ((beatus-vir-qui-in-lege          . 1)
                (servite-domino-in-timore         . 2)
                (exsurge-domine-salvum            . 3))
    :nocturn-2 ((quam-admirabile                  . 8)
                (sedisti-super-thronum             . (9 2 11))
                (exsurge-domine-non-praevaleat    . (9 12 21)))
    :nocturn-3 ((ut-quid-domine-recessisti        . (9 22 32))
                (exsurge-domine-deus-exaltetur    . (9 33 39))
                (justus-dominus                   . 10)))
  "Dominical (Sunday) Matins psalm assignments: 3 nocturns of 3 psalms each.
Each nocturn is a list of (ANTIPHON-INCIPIT . PSALM-SPEC) where PSALM-SPEC
is either a number or (PSALM START END).")

(defconst bcp-roman-psalterium--matins-dominical-versicles
  '((:nocturn-1 . ("Memor fui nocte nóminis tui, Dómine."
                    "Et custodívi legem tuam."))
    (:nocturn-2 . ("Média nocte surgébam ad confiténdum tibi."
                    "Super judícia justificatiónis tuæ."))
    (:nocturn-3 . ("Prævenérunt óculi mei ad te dilúculo."
                    "Ut meditárer elóquia tua, Dómine.")))
  "Versicles after each nocturn on Sunday Matins (Latin).")

(defconst bcp-roman-psalterium--matins-dominical-versicles-en
  '((:nocturn-1 . ("I have remembered Thy Name, O Lord, in the night."
                    "And have kept Thy law."))
    (:nocturn-2 . ("At midnight I rose to give Thee thanks."
                    "Because of Thy righteous judgments."))
    (:nocturn-3 . ("Mine eyes have prevented the dawning of the day."
                    "That I might meditate upon Thy words, O Lord.")))
  "Versicles after each nocturn on Sunday Matins (English).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins invitatory antiphons (per-annum, by day of week)

(defconst bcp-roman-psalterium--invitatory-antiphons
  '((0 . dominum-qui-fecit-nos)
    (1 . venite-exsultemus-domino)
    (2 . jubilemus-deo-salutari)
    (3 . deum-magnum-dominum)
    (4 . regem-magnum-dominum)
    (5 . dominum-deum-nostrum)
    (6 . populus-domini-et-oves))
  "Per-annum invitatory antiphon incipits by day of week.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins hymns (per-annum, by day of week)

(defconst bcp-roman-psalterium--matins-hymns
  '((0 . primo-dierum-omnium)
    (1 . somno-refectis-artubus)
    (2 . consors-paterni-luminis)
    (3 . rerum-creator-optime)
    (4 . nox-atra-rerum-contegit)
    (5 . tu-trinitatis-unitas)
    (6 . summae-parens-clementiae))
  "Per-annum Matins hymn incipits by day of week.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins versicles (per-annum, by day of week)

(defconst bcp-roman-psalterium--matins-versicles
  '((1 . ("Dómine in cælo misericórdia tua."
          "Et véritas tua usque ad nubes."))
    (2 . ("Ímmola Deo sacrifícium laudis."
          "Et redde altíssimo vota tua."))
    (3 . ("Deus, vitam meam annuntiávi tibi."
          "Posuísti lácrimas meas in conspéctu tuo."))
    (4 . ("Gaudébunt lábia mea cum cantávero tibi."
          "Et ánima mea, quam redemísti."))
    (5 . ("Intret orátio mea in conspéctu tuo, Dómine."
          "Inclína aurem tuam ad precem meam."))
    (6 . ("Dómine, exáudi oratiónem meam."
          "Et clamor meus ad te véniat.")))
  "Ferial Matins versicle/response by day of week (per-annum).")

(defconst bcp-roman-psalterium--matins-versicles-en
  '((1 . ("Thy mercy, O Lord, is in the heavens."
          "And thy faithfulness reacheth unto the clouds."))
    (2 . ("Offer unto God the sacrifice of praise."
          "And pay thy vows unto the Most High."))
    (3 . ("God, I have declared my life unto Thee."
          "Thou hast put my tears in Thy sight."))
    (4 . ("My lips shall be fain when I sing unto Thee."
          "And my soul, which Thou hast redeemed."))
    (5 . ("Let my prayer come before Thee, O Lord."
          "Incline Thine ear unto my cry."))
    (6 . ("O Lord, hear my prayer."
          "And let my cry come unto Thee.")))
  "Ferial Matins versicle/response by day of week (English).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins capitulum (per-annum, invariant)

(defconst bcp-roman-psalterium--matins-capitulum
  '(:ref "1 Cor. 16:13-14"
    :text "Vigiláte, state in fide, viríliter ágite, et confortámini. \
Ómnia vestra in caritáte fiant.")
  "Matins capitulum (per-annum, invariant).")

(defconst bcp-roman-psalterium--matins-capitulum-versicle
  '("Beáti qui hábitant in domo tua, Dómine."
    "In sǽcula sæculórum laudábunt te.")
  "Matins capitulum versicle (per-annum).")

(defconst bcp-roman-psalterium--matins-capitulum-versicle-en
  '("Blessed are they that dwell in thy house, O Lord."
    "They shall praise thee for ever and ever.")
  "Matins capitulum versicle (English).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins lectio brevis (ferial, per day of week)
;;
;; Each entry: (:ref STRING :text STRING :responsory PLIST)
;; The responsory is a short responsory with :respond, :versus, :repeat.

(defconst bcp-roman-psalterium--matins-lectio-brevis
  `((1 . (:ref "Lam. 2:19"
          :text "Consúrge, lauda in nocte in princípio vigiliárum: \
effúnde sicut aquam cor tuum ante conspéctum Dómini: leva ad eum manus tuas."
          :responsory (:respond "Benedícam Dóminum * In omni témpore."
                       :versus "Semper laus ejus in ore meo."
                       :repeat "In omni témpore.")))
    (2 . (:ref "Prov. 3:19-20"
          :text "Dóminus sapiéntia fundávit terram: stabilívit cælos \
prudéntia. Sapiéntia illíus erupérunt abýssi, et nubes rore concréscunt."
          :responsory (:respond "Deus, in nómine tuo * Salvum me fac."
                       :versus "Et in misericórdia tua líbera me."
                       :repeat "Salvum me fac.")))
    (3 . (:ref "Sap. 1:1-2"
          :text "Dilígite justítiam, qui judicátis terram. Sentíte de \
Dómino in bonitáte, et in simplicitáte cordis quǽrite illum: quóniam \
invenítur ab his qui non tentant illum, appáret autem eis qui fidem habent \
in illum."
          :responsory (:respond "In te, Dómine, sperávi: * Non confúndar in ætérnum."
                       :versus "In justítia tua líbera me, et éripe me."
                       :repeat "Non confúndar in ætérnum.")))
    (4 . (:ref "Sap. 3:9"
          :text "Qui confídunt in illo intélligent veritátem, et fidéles \
in dilectióne acquiéscent illi: quóniam donum et pax est eléctis ejus."
          :responsory (:respond "Exsultáte Deo, * Adjutóri nostro."
                       :versus "Jubiláte Deo Jacob."
                       :repeat "Adjutóri nostro.")))
    (5 . (:ref "Sap. 1:6-7"
          :text "Benígnus est enim spíritus sapiéntiæ, et non liberábit \
malédicum a lábiis suis: quóniam renum illíus testis est Deus, et cordis \
illíus scrutátor est verus, et linguæ ejus audítor. Quóniam Spíritus \
Dómini replévit orbem terrárum, et hoc quod cóntinet ómnia, sciéntiam \
habet vocis."
          :responsory (:respond "Misericórdias tuas Dómine * In ætérnum cantábo."
                       :versus "In generatióne et progénie."
                       :repeat "In ætérnum cantábo.")))
    (6 . (:ref "Eccli. 12:2-3"
          :text "Bénefac justo, et invénies retributiónem magnam: et si \
non ab ipso, certe a Dómino. Non est enim ei bene qui assíduus est in \
malis, et eleemósynas non danti: quóniam et Altíssimus ódio habet \
peccatóres, et misértus est pœniténtibus."
          :responsory (:respond "Dómine, * Exáudi oratiónem meam."
                       :versus "Et clamor meus ad te véniat."
                       :repeat "Exáudi oratiónem meam."))))
  "Ferial Matins lectio brevis by day of week (Latin).")

(defconst bcp-roman-psalterium--matins-lectio-brevis-en
  `((1 . (:ref "Lam. 2:19"
          :text "Arise, give praise in the night, in the beginning of the \
watches: pour out thy heart like water before the face of the Lord: lift up \
thy hands to him for the life of your little children."
          :responsory (:respond "I will bless the Lord * at all times."
                       :versus "His praise shall be always in my mouth."
                       :repeat "At all times.")))
    (2 . (:ref "Prov. 3:19-20"
          :text "The Lord by wisdom hath founded the earth, hath established \
the heavens by prudence. By his wisdom the depths have broken out, and the \
clouds grow thick with dew."
          :responsory (:respond "Save me, O God, * by thy name."
                       :versus "And deliver me in your mercy."
                       :repeat "By thy name.")))
    (3 . (:ref "Sap. 1:1-2"
          :text "Love justice, you that are the judges of the earth. Think \
of the Lord in goodness, and seek him in simplicity of heart. For he is \
found by them that tempt him not: and he sheweth himself to them that have \
faith in him."
          :responsory (:respond "In thee, O Lord, have I hoped, * let me never be confounded."
                       :versus "Deliver me in thy justice, and rescue me."
                       :repeat "Let me never be confounded.")))
    (4 . (:ref "Sap. 3:9"
          :text "They that trust in him, shall understand the truth: and \
they that are faithful in love shall rest in him: for grace and peace is \
to his elect."
          :responsory (:respond "Sing aloud * unto God our strength."
                       :versus "Sing aloud to the God of Jacob."
                       :repeat "Unto God our strength.")))
    (5 . (:ref "Sap. 1:6-7"
          :text "For the spirit of wisdom is benevolent, and will not \
acquit the evil speaker from his lips: for God is witness of his reins, \
and he is a true searcher of his heart, and a hearer of his tongue. For \
the spirit of the Lord hath filled the whole world: and that, which \
containeth all things, hath knowledge of the voice."
          :responsory (:respond "The mercies of the Lord * I will sing for ever."
                       :versus "Through all generations and posterities."
                       :repeat "I will sing for ever.")))
    (6 . (:ref "Eccli. 12:2-3"
          :text "Do good to the just, and thou shalt find great recompense: \
and if not of him, assuredly of the Lord. For there is no good for him that \
is always occupied in evil, and that giveth no alms: for the Highest hateth \
sinners, and hath mercy on the penitent."
          :responsory (:respond "Lord, * hear my prayer."
                       :versus "And let my cry come unto thee."
                       :repeat "Hear my prayer."))))
  "Ferial Matins lectio brevis by day of week (English).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins public accessors

(defun bcp-roman-psalterium-matins-psalms (dow)
  "Return Matins psalm/antiphon list for day-of-week DOW (Daya cursus)."
  (alist-get dow bcp-roman-psalterium--matins))

(defun bcp-roman-psalterium-invitatory-antiphon (dow)
  "Return the per-annum invitatory antiphon incipit for DOW."
  (alist-get dow bcp-roman-psalterium--invitatory-antiphons))

(defun bcp-roman-psalterium-matins-hymn (dow)
  "Return the Matins hymn incipit for day-of-week DOW."
  (alist-get dow bcp-roman-psalterium--matins-hymns))

(defun bcp-roman-psalterium-matins-versicle (dow)
  "Return the ferial Matins versicle pair for DOW."
  (alist-get dow bcp-roman-psalterium--matins-versicles))

(defun bcp-roman-psalterium-matins-versicle-en (dow)
  "Return the ferial Matins versicle pair for DOW (English)."
  (alist-get dow bcp-roman-psalterium--matins-versicles-en))

(defun bcp-roman-psalterium-matins-lectio-brevis (dow)
  "Return the ferial Matins lectio brevis plist for DOW (Latin)."
  (alist-get dow bcp-roman-psalterium--matins-lectio-brevis))

(defun bcp-roman-psalterium-matins-lectio-brevis-en (dow)
  "Return the ferial Matins lectio brevis plist for DOW (English)."
  (alist-get dow bcp-roman-psalterium--matins-lectio-brevis-en))

(defun bcp-roman-psalterium-matins-dominical-nocturn (n)
  "Return the psalm/antiphon list for Sunday Matins nocturn N (1-3)."
  (plist-get bcp-roman-psalterium--matins-dominical
             (intern (format ":nocturn-%d" n))))

(defun bcp-roman-psalterium-matins-dominical-versicle (n &optional english)
  "Return the versicle pair for Sunday Matins nocturn N (1-3).
When ENGLISH is non-nil, return the English version."
  (let ((key (intern (format ":nocturn-%d" n))))
    (alist-get key (if english
                       bcp-roman-psalterium--matins-dominical-versicles-en
                     bcp-roman-psalterium--matins-dominical-versicles))))

(provide 'bcp-roman-psalterium)

;;; bcp-roman-psalterium.el ends here
