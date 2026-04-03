;;; bcp-roman-season-christmas.el --- Christmastide Proper of the Time -*- lexical-binding: t -*-

;;; Commentary:

;; Proper of the Time data for the Christmastide season (DA 1911 rubrics).
;; Covers Dec 25 through the Saturday before Septuagesima, providing:
;;
;;   1. Collects for all 8 Christmastide Sundays
;;   2. Dominical Matins data for 5 post-Epiphany Sundays (Epi2-Epi6)
;;   3. Non-Matins data (Magnificat/Benedictus antiphons, Lauds antiphons,
;;      capitula) for all applicable Christmastide Sundays
;;   4. Feast-grade Matins offices for three fixed feasts:
;;      - Christmas Day (Dec 25): In Nativitate Domini
;;      - St. Stephen (Dec 26): S. Stephanus Protomartyr
;;      - Epiphany (Jan 6): In Epiphania Domini
;;
;; Sunday numbering (0-indexed):
;;   0 = Christmas Octave Sunday (Nat1-0, Dec 26-Jan 1)
;;   1 = Holy Name Sunday (Nat2-0, Jan 2-5)
;;   2 = 1st Sunday after Epiphany (Epi1-0, Holy Family)
;;   3 = 2nd Sunday after Epiphany (Epi2-0)
;;   4–7 = 3rd through 6th Sundays after Epiphany
;;
;; Lesson structure follows `bcp-roman-tempora.el' Per Annum pattern:
;;   Nocturn I  (L1-L3): Scripture with :ref, :source, :text
;;   Nocturn II (L4-L6): Patristic with :ref, :source, :text
;;   Nocturn III (L7-L9): Homily with :ref, :source, :text
;;
;; Feast-grade offices are 3-nocturn structures with proper psalms,
;; antiphons, versicles, 9 lessons, and 8 responsories.  These supersede
;; the day-of-week cursus regardless of what day the feast falls on.
;; Epiphany has a special rubric: invitatory and hymn are omitted on the
;; feast day itself; Ps 94 (Venite) is displaced into Nocturn III.
;;
;; Data extracted from Divinum Officium Latin Sancti files.
;;
;; Key public functions:
;;   `bcp-roman-season-christmas-collect'          -- Christmastide collect incipit
;;   `bcp-roman-season-christmas-dominical-matins' -- Christmastide dominical Matins
;;   `bcp-roman-season-christmas-feast-matins'     -- Feast-grade Matins data

;;; Code:

(require 'bcp-common-roman)
(require 'bcp-roman-antiphonary)
(require 'bcp-roman-capitulary)
(require 'bcp-roman-collectarium)
(require 'bcp-calendar)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Christmastide collects

;;; ─── Christmas Octave Sunday (Nat1-0) ──────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-dirige-actus
 (list :latin (concat
              "Omnípotens sempitérne Deus, dírige actus nostros in \
beneplácito tuo: ut in nómine dilécti Fílii tui mereámur bonis opéribus \
abundáre:\n"
              bcp-roman-qui-tecum)
       :conclusion 'qui-tecum
       :translations
       '((do . "O Almighty and everlasting God, do Thou order all our \
actions in conformity with thy good pleasure, that through the name of \
thy well-beloved Son, we may worthily abound in all good works.\n\
Who with Thee liveth and reigneth."))))

;;; ─── Holy Name Sunday (Nat2-0) ─────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-unigenitum-filium-tuum-constituisti
 (list :latin (concat
              "Deus, qui unigénitum Fílium tuum constituísti humáni \
géneris Salvatórem, et Jesum vocári jussísti: concéde propítius; ut, \
cujus sanctum nomen venerámur in terris, ejus quoque aspéctu perfruámur \
in cælis.\n"
              bcp-roman-per-eumdem)
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, Who hast appointed thine Only-begotten Son to be \
the Saviour of mankind, and hast commanded that His Name should be called \
Jesus, mercifully grant that we who here on earth do worship that most \
Holy Name may be made glad in heaven by His Presence.\n\
Through the same Lord."))))

;;; ─── Epiphany 1: Holy Family (Epi1-0) ─────────────────────────────────

(bcp-roman-collectarium-register
 'domine-jesu-christe-qui-mariae-et-joseph
 (list :latin (concat
              "Dómine Jesu Christe, qui, Maríæ et Joseph súbditus, \
domésticam vitam ineffabílibus virtútibus consecrásti: fac nos, \
utriúsque auxílio, Famíliæ sanctæ tuæ exémplis ínstrui; et consórtium \
cónsequi sempitérnum:\n"
              bcp-roman-qui-vivis)
       :conclusion 'qui-vivis
       :translations
       '((do . "Lord Jesus Christ, who subject to Mary and Joseph, didst \
consecrate family life by thy unspeakable virtues, aid us by their united \
intercession to profit by the examples of thy Holy Family, and attain to \
their everlasting companionship.\nWho livest and reignest."))))

;;; ─── Epiphany 2 (Epi2-0) ──────────────────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-caelestia
 (list :latin (concat
              "Omnípotens sempitérne Deus, qui cæléstia simul et terréna \
moderáris: supplicatiónes pópuli tui cleménter exáudi; et pacem tuam \
nostris concéde tempóribus.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty and eternal God, as thou govern all things in \
heaven and on earth; in thy mercy hear the supplication of thy people, \
and grant thy peace in our times.\nThrough our Lord."))))

;;; ─── Epiphany 3 (Epi3-0) ──────────────────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-infirmitatem
 (list :latin (concat
              "Omnípotens sempitérne Deus, infirmitátem nostram propítius \
réspice: atque, ad protegéndum nos, déxteram tuæ majestátis exténde.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty and everlasting God, mercifully look upon our \
infirmities, and in all our dangers and necessities stretch forth the \
right hand of thy Majesty to help and defend us.\nThrough our Lord."))))

;;; ─── Epiphany 4 (Epi4-0) ──────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-nos-in-tantis-periculis
 (list :latin (concat
              "Deus, qui nos in tantis perículis constitútos, pro humána \
scis fragilitáte non posse subsístere: da nobis salútem mentis et \
córporis; ut ea, quæ pro peccátis nostris pátimur, te adjuvánte \
vincámus.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who knowest us to be set in the midst of so many \
and great dangers, that, by reason of the frailty of our nature, we \
cannot always stand upright; grant to us such health of mind and body, \
that by thy strength and protection we may overcome all evils, whereby \
for our sins we are justly afflicted.\nThrough our Lord."))))

;;; ─── Epiphany 5 (Epi5-0) ──────────────────────────────────────────────

(bcp-roman-collectarium-register
 'familiam-tuam-quaesumus-domine
 (list :latin (concat
              "Famíliam tuam, quǽsumus, Dómine, contínua pietáte custódi: \
ut, quæ in sola spe grátiæ cœléstis innítitur, tua semper protectióne \
muniátur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we beseech thee to keep thy family continually in \
godliness, that they who do lean only upon the hope of thine heavenly \
grace, may evermore be defended by thy mighty power.\n\
Through our Lord."))))

;;; ─── Epiphany 6 (Epi6-0) ──────────────────────────────────────────────

(bcp-roman-collectarium-register
 'praesta-quaesumus-omnipotens-deus-ut-semper
 (list :latin (concat
              "Præsta, quǽsumus, omnípotens Deus: ut, semper rationabília \
meditántes, quæ tibi sunt plácita, et dictis exsequámur et factis.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Grant us, we beseech thee, O Almighty God, ever to think \
such things as be reasonable, and in every word and work of ours, to do \
always that is well pleasing in thy sight.\nThrough our Lord."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sunday-to-collect mapping

(defconst bcp-roman-season-christmas--collects
  [omnipotens-sempiterne-deus-dirige-actus            ; 0: Nat1 (Christmas Octave)
   deus-qui-unigenitum-filium-tuum-constituisti       ; 1: Nat2 (Holy Name)
   domine-jesu-christe-qui-mariae-et-joseph           ; 2: Epi1 (Holy Family)
   omnipotens-sempiterne-deus-qui-caelestia           ; 3: Epi2
   omnipotens-sempiterne-deus-infirmitatem            ; 4: Epi3
   deus-qui-nos-in-tantis-periculis                   ; 5: Epi4
   familiam-tuam-quaesumus-domine                     ; 6: Epi5
   praesta-quaesumus-omnipotens-deus-ut-semper]       ; 7: Epi6
  "Christmastide collect incipits, 0-indexed.
0 = Christmas Octave Sunday, 1 = Holy Name, 2-7 = Epi1-Epi6.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Christmastide antiphon registrations

;;; ─── Nat1 (Christmas Octave Sunday) antiphons ───────────────────────────

(bcp-roman-antiphonary-register
 'dum-medium-silentium
 '(:latin "Dum médium siléntium * tenérent ómnia, et nox in suo cursu médium iter perágeret, omnípotens Sermo tuus, Dómine, a regálibus sédibus venit, allelúja."
   :translations
   ((do . "While all things were in quiet silence * and that night was in the midst of her swift course, thine Almighty Word, O Lord, leapt down out of thy Royal Throne."))))

(bcp-roman-antiphonary-register
 'puer-jesus-proficiebat
 '(:latin "Puer Jesus * proficiébat ætáte et sapiéntia coram Deo et homínibus."
   :translations
   ((do . "And Jesus advanced in wisdom * and age, and grace with God and men."))))

;;; ─── Epi1 (Holy Family) antiphons ──────────────────────────────────────

(bcp-roman-antiphonary-register
 'verbum-caro-factum-est
 '(:latin "Verbum caro * factum est, et habitávit in nobis, plenum grátiæ et veritátis; de cujus plenitúdine omnes nos accépimus, et grátiam pro grátia, allelúja."
   :translations
   ((do . "The Word was made flesh, * and dwelt among us, full of grace and truth; and of his fulness we all have received, and grace for grace, alleluia."))))

(bcp-roman-antiphonary-register
 'illumina-nos-domine
 '(:latin "Illúmina nos, Dómine, * exémplis Famíliæ tuæ, et dírige pedes nostros in viam pacis."
   :translations
   ((do . "Enlighten us, O Lord, * by the example of thy family, and direct our feet into the way of peace."))))

(bcp-roman-antiphonary-register
 'maria-autem-conservabat
 '(:latin "María autem * conservábat ómnia verba hæc, cónferens in corde suo."
   :translations
   ((do . "But Mary * kept all these words, pondering them in her heart."))))

;; Lauds antiphons (5) for Holy Family

(bcp-roman-antiphonary-register
 'post-triduum-invenerunt
 '(:latin "Post tríduum * invenérunt Jesum in templo sedéntem in médio doctórum, audiéntem illos, et interrogántem eos."
   :translations
   ((do . "After three days, * they found him in the temple, sitting in the midst of the doctors, hearing them, and asking them questions."))))

(bcp-roman-antiphonary-register
 'dixit-mater-jesu
 '(:latin "Dixit mater Jesu * ad illum: Fili, quid fecísti nobis sic? Ecce pater tuus et ego doléntes quærebámus te."
   :translations
   ((do . "The mother of Jesus said * to him: Son, why hast thou done so to us? Behold thy father and I have sought thee sorrowing."))))

(bcp-roman-antiphonary-register
 'descendit-jesus-cum-eis
 '(:latin "Descéndit Jesus * cum eis, et venit Názareth, et erat súbditus illis."
   :translations
   ((do . "Jesus went down * with them, and came to Nazareth, and was subject to them."))))

(bcp-roman-antiphonary-register
 'et-jesus-proficiebat
 '(:latin "Et Jesus proficiébat * sapiéntia, et ætáte, et grátia apud Deum et hómines."
   :translations
   ((do . "And Jesus advanced * in wisdom, and age, and grace with God and men."))))

(bcp-roman-antiphonary-register
 'et-dicebant-unde-huic
 '(:latin "Et dicébant: * Unde huic sapiéntia hæc, et virtútes? Nonne hic est fabri fílius?"
   :translations
   ((do . "And they said: * How came this man by this wisdom and miracles? Is not this the carpenter's son?"))))

;;; ─── Epi2 antiphons ────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'suscepit-deus-israel
 '(:latin "Suscépit Deus * Israël, púerum suum: sicut locútus est ad Abraham, et semen ejus usque in sǽculum."
   :translations
   ((do . "God hath received * Israel his servant, as he spoke to our fathers, to Abraham and to his seed for ever."))))

(bcp-roman-antiphonary-register
 'nuptiae-factae-sunt
 '(:latin "Núptiæ factæ sunt * in Cana Galilǽæ, et erat ibi Jesus cum María matre sua."
   :translations
   ((do . "There was a marriage * in Cana of Galilee: and Jesus was there, with Mary, his mother."))))

(bcp-roman-antiphonary-register
 'deficiente-vino
 '(:latin "Deficiénte vino, * jussit Jesus impléri hýdrias aqua, quæ in vinum convérsa est, allelúja."
   :translations
   ((do . "The wine failing, * Jesus commanded the water pots to be filled with water, which was changed into wine, alleluia."))))

;;; ─── Epi3 antiphons ────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'cum-descendisset-jesus
 '(:latin "Cum descendísset Jesus * de monte, ecce leprósus véniens adorábat eum, dicens: Dómine, si vis, potes me mundáre: et exténdens manum, tétigit eum, dicens: Volo, mundáre."
   :translations
   ((do . "When Jesus was come down from the mountain, * behold, there came a leper, and worshipped Him, saying: Lord, if Thou wilt, Thou canst make me clean. And Jesus put forth His Hand, and touched him, saying: I will; be thou clean."))))

(bcp-roman-antiphonary-register
 'domine-si-vis-potes
 '(:latin "Dómine, * si vis, potes me mundáre: et ait Jesus: Volo, mundáre."
   :translations
   ((do . "Lord, if Thou wilt, * Thou canst make me clean; and Jesus saith to him: I will; be thou clean."))))

;;; ─── Epi4 antiphons ────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'ascendente-jesu
 '(:latin "Ascendénte Jesu * in navículam, ecce motus magnus factus est in mari: et suscitavérunt eum discípuli ejus, dicéntes: Dómine, salva nos, perímus."
   :translations
   ((do . "When Jesus was entered into a ship, * there arose a great tempest in the sea and His disciples awoke Him, saying: Lord, save us; we perish."))))

(bcp-roman-antiphonary-register
 'domine-salva-nos-perimus
 '(:latin "Dómine, salva nos, * perímus: ímpera, et fac, Deus, tranquillitátem."
   :translations
   ((do . "Lord, save us: * we perish; give the word, O God, and let there be a great calm!"))))

;;; ─── Epi5 antiphons ────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'domine-nonne-bonum
 '(:latin "Dómine, * nonne bonum semen seminásti in agro tuo? unde ergo habet zizánia? Et ait illis: Hoc fecit inimícus homo."
   :translations
   ((do . "Sir, didst not thou sow good seed in thy field? * From whence then hath it tares? And he saith unto them: An enemy hath done this."))))

(bcp-roman-antiphonary-register
 'colligite-primum-zizania
 '(:latin "Collígite * primum zizánia, et alligáte ea in fascículos ad comburéndum: tríticum autem congregáte in hórreum meum, dicit Dóminus."
   :translations
   ((do . "The master saith: Gather ye together first the tares, * and bind them in bundles to burn them; but gather the wheat into my barn."))))

;;; ─── Epi6 antiphons ────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'simile-est-regnum-caelorum-grano
 '(:latin "Símile est * regnum cælórum grano sinápis, quod mínimum est ómnibus semínibus: cum autem créverit, majus est ómnibus oléribus."
   :translations
   ((do . "The kingdom of heaven * is like to a grain of mustard-seed, which is the least of all seeds, but, when it is grown, it is the greatest among herbs."))))

(bcp-roman-antiphonary-register
 'simile-est-regnum-caelorum-fermento
 '(:latin "Símile est * regnum cælórum ferménto, quod accéptum múlier abscóndit in farínæ satis tribus, donec fermentátum est totum."
   :translations
   ((do . "The kingdom of heaven * is like unto leaven, which a woman took and hid in three measures of meal till the whole was leavened."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Christmastide capitulum registrations

;;; ─── Nat1 (Christmas Octave Sunday) capitula ───────────────────────────

(bcp-roman-capitulary-register
 'quanto-tempore-heres
 '(:latin "Fratres: Quanto témpore heres párvulus est, nihil differt a servo, cum sit dóminus ómnium: sed sub tutóribus et actóribus est usque ad præfínitum tempus a patre."
   :ref "Gal 4:1-2"
   :translations
   ((do . "As long as the heir is a child, he differeth nothing from a servant, though he be lord of all; But is under tutors and governors until the time appointed by the father."))))

(bcp-roman-capitulary-register
 'itaque-jam-non-est-servus
 '(:latin "Itaque jam non est servus, sed fílius: quod si fílius, et hæres per Deum."
   :ref "Gal 4:7"
   :translations
   ((do . "Therefore now he is not a servant, but a son. And if a son, an heir also through God."))))

;;; ─── Epi1 (Holy Family) capitula ───────────────────────────────────────

(bcp-roman-capitulary-register
 'descendit-jesus-cap
 '(:latin "Descéndit Jesus cum María et Joseph, et venit Názareth: et erat súbditus illis."
   :ref "Luke 2:51"
   :translations
   ((do . "Jesus went down with Mary and Joseph, and came to Nazareth, and was subject to them."))))

(bcp-roman-capitulary-register
 'semetipsum-exinanivit
 '(:latin "Semetípsum exinanívit formam servi accípiens, in similitúdinem hóminum factus, et hábitu invéntus ut homo."
   :ref "Phil 2:7"
   :translations
   ((do . "But emptied himself, taking the form of a servant, being made in the likeness of men, and in habit found as a man."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Christmastide Sunday number computation

(defun bcp-roman-season-christmas--sunday-number (date)
  "Return the Christmastide Sunday number (0-7) for the Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns nil if DATE is outside Christmastide.
  0 = Christmas Octave Sunday (Dec 26-Jan 1)
  1 = Holy Name Sunday (Jan 2-5)
  2 = 1st Sunday after Epiphany (Epi1)
  3-7 = 2nd-6th Sunday after Epiphany (Epi2-Epi6)"
  (let* ((date-abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date))
         (sunday-abs (- date-abs dow)))
    ;; Determine the Gregorian date of the preceding Sunday
    (let ((sun-date (calendar-gregorian-from-absolute sunday-abs)))
      (let ((sm (car sun-date))
            (sd (cadr sun-date))
            (sy (caddr sun-date)))
        (cond
         ;; Sunday in Christmas Octave: Dec 26-31
         ((and (= sm 12) (>= sd 26) (<= sd 31))
          0)
         ;; Holy Name period: Jan 1-5
         ((and (= sm 1) (>= sd 1) (<= sd 5))
          1)
         ;; Post-Epiphany Sundays: Jan 6 onward
         ((or (and (= sm 1) (>= sd 6))
              (= sm 2))
          ;; Epiphany is Jan 6; first Sunday after = Epi1 = week 2
          (let* ((epi-abs (calendar-absolute-from-gregorian
                           (list 1 6 sy)))
                 (weeks-after (/ (- sunday-abs epi-abs) 7)))
            ;; weeks-after: 0 = Epi1 (if Jan 6 is Sun, or first Sun after)
            ;; Actually: first Sun on or after Jan 7 = Epi1
            (when (> sunday-abs epi-abs)
              (let ((n (+ 1 weeks-after))) ; 1 = first Sun after Epi
                (when (<= n 6)
                  (1+ n)))))) ; offset: Epi1=2, Epi2=3, ..., Epi6=7
         (t nil))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Christmastide dominical data
;;
;; Matins lessons + responsories for 5 Sundays (Epi2-Epi6), plus non-Matins
;; keys (Magnificat/Benedictus antiphons, Lauds antiphons, capitula) for all
;; applicable Christmastide Sundays.
;;
;; Each entry: (WEEK . (:lessons (L1..L9) :responsories (R1..R8)
;;                       :magnificat-antiphon SYM :benedictus-antiphon SYM
;;                       :lauds-capitulum SYM :none-capitulum SYM
;;                       :magnificat2-antiphon SYM ...))
;;
;; Epi3-6 share Epi2's responsories (R1-R7, resolved inline).
;; R8 is the Trinitarian "Duo Seraphim" from Pent01-0, used across
;; all post-Epiphany Sundays.
;;
;; Nat1 (0) and Epi1 (2) have non-Matins data only (Matins is feast-grade).
;; Epi2-Epi6 (3-7) have both Matins and non-Matins data.

(defconst bcp-roman-season-christmas--dominical-matins
  '(

    ;; ════════════════════════════════════════════════════════════════════
    ;; Christmas Octave Sunday — Dominica infra Oct. Nativitatis (Nat1-0)
    ;; Non-Matins only (Matins is feast-grade)
    ;; ════════════════════════════════════════════════════════════════════

    (0
     . (
        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  dum-medium-silentium
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  dum-medium-silentium
        :lauds-capitulum      quanto-tempore-heres
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       itaque-jam-non-est-servus
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon puer-jesus-proficiebat
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Epiphany 1 — Holy Family (Epi1-0)
    ;; Non-Matins only (Matins is feast-grade)
    ;; ════════════════════════════════════════════════════════════════════

    (2
     . (
        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  verbum-caro-factum-est
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  illumina-nos-domine
        :lauds-antiphons      (post-triduum-invenerunt
                               dixit-mater-jesu
                               descendit-jesus-cum-eis
                               et-jesus-proficiebat
                               et-dicebant-unde-huic)
        :lauds-capitulum      descendit-jesus-cap
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       semetipsum-exinanivit
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon maria-autem-conservabat
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Epiphany 2 — Dominica II post Epiphaniam (DO: Epi2-0)
    ;; Scripture: 2 Cor 1; Patristic: St John Chrysostom;
    ;; Homily: St Augustine (John 2:1-11)
    ;; ════════════════════════════════════════════════════════════════════

    (3
     . (:lessons
        (
        (:ref "2 Cor 1:1-5" :source "Incipit Epístola secúnda beáti Pauli Apóstoli ad Corínthios" :text "\
1 Paulus, Apóstolus Jesu Christi per voluntátem Dei, et Timótheus \
frater, Ecclésiæ Dei, quæ est Corínthi cum ómnibus sanctis, qui sunt \
in univérsa Achája.\n\
2 Grátia vobis, et pax a Deo Patre nostro, et Dómino Jesu Christo.\n\
3 Benedíctus Deus et Pater Dómini nostri Jesu Christi, Pater \
misericordiárum, et Deus totíus consolatiónis,\n\
4 qui consolátur nos in omni tribulatióne nostra: ut possímus et ipsi \
consolári eos qui in omni pressúra sunt, per exhortatiónem, qua \
exhortámur et ipsi a Deo.\n\
5 Quóniam sicut abúndant passiónes Christi in nobis: ita et per \
Christum abúndat consolátio nostra.")  ; L1

        (:ref "2 Cor 1:6-7" :text "\
6 Sive autem tribulámur pro vestra exhortatióne et salúte, sive \
consolámur pro vestra consolatióne, sive exhortámur pro vestra \
exhortatióne et salúte, quæ operátur tolerántiam earúndem passiónum, \
quas et nos pátimur:\n\
7 ut spes nostra firma sit pro vobis: sciéntes quod sicut sócii \
passiónum estis, sic éritis et consolatiónis.")  ; L2

        (:ref "2 Cor 1:8-11" :text "\
8 Non enim vólumus ignoráre vos, fratres, de tribulatióne nostra, quæ \
facta est in Asia, quóniam supra modum graváti sumus supra virtútem, \
ita ut tædéret nos étiam vívere.\n\
9 Sed ipsi in nobismetípsis respónsum mortis habúimus, ut non simus \
fidéntes in nobis, sed in Deo, qui súscitat mórtuos:\n\
10 qui de tantis perículis nos erípuit, et éruit: in quem sperámus \
quóniam et adhuc erípiet,\n\
11 adjuvántibus et vobis in oratióne pro nobis: ut ex multórum \
persónis, ejus quæ in nobis est donatiónis, per multos grátiæ agántur \
pro nobis.")  ; L3

        (:ref "Præfatio in Epistolas Beati Pauli" :source "Sermo sancti Joánnis Chrysóstomi" :text "\
Beáti Pauli Epistolárum lectiónem dum assídue auscúlto, perque \
hebdómadas síngulas bis sæpe, et ter et quater, quotiescúmque sanctórum \
Mártyrum memórias celebrámus, gáudio exsúlto, tuba illa spiritáli \
pérfruens, et éxcitor, ac desidério incalésco, vocem mihi amícam \
agnóscens, et fere præséntem ipsum intuéri, et disseréntem audíre \
vídeor. Sed tamen dóleo et moléste fero, quod virum hunc non omnes, \
sicut par est, cognóscunt: verum ita illum nonnúlli ignórant, ut ne \
Epistolárum quidem ejus númerum plane sciant. Hoc vero non imperítia \
facit: sed quod nolint beáti hujus viri scripta in mánibus habére.")  ; L4

        (:text "\
Neque enim nos, quæ scimus, si quid scimus, ab ingénii bonitáte atque \
acúmine scimus: sed quod erga hunc virum impénse affécti, ab illíus \
lectióne numquam discédimus: síquidem qui amant, ii plus quam céteri \
omnes eórum facta norunt, quos amant, ut qui de iis ipsis sint \
sollíciti. Id quod beátus hic véluti osténdens, ad Philippénses ait: \
Sicut est mihi justum, ut hoc de vobis ómnibus séntiam, eo quod \
hábeam vos in corde, et in vínculis meis, et in defensióne et \
confirmatióne Evangélii.")  ; L5

        (:text "\
Quaprópter si et vos quoque lectióni diligénter atténdere voluéritis, \
nihil áliud vobis erit requiréndum. Verax est enim Christi sermo \
dicéntis: Quǽrite, et inveniétis: pulsáte, et aperiétur vobis. \
Céterum, quandóquidem complúres ex iis, qui huc nobíscum convéniunt, \
et liberórum educatiónem, et uxóris curam, et famíliæ providéntiam \
suscepére, ob idque totos sese huic labóri dare non sústinent: at \
certe ipsi vos excitáte ad ea saltem capiénda, quæ álii collégerint; \
stúdii tantúmdem iis, quæ dicta fúerint, auscultándis, quantum \
pecúniis colligéndis impertiéntes. Nam etsi turpe sit, non nisi tantum \
stúdii a vobis exígere: optábile tamen erit, si tantum saltem \
tribuátis.")  ; L6

        (:ref "Joan 2:1-11" :source "Léctio sancti Evangélii secúndum Joánnem" :text "\
In illo témpore: Núptiæ factæ sunt in Cana Galilǽæ, et erat mater \
Jesu ibi. Vocátus est autem et Jesus, et discípuli ejus ad núptias. \
Et réliqua.\n\
Homilía sancti Augustíni Epíscopi\n\
Quod Dóminus invitátus venit ad núptias, étiam excépta mýstica \
significatióne, confirmáre vóluit, quod ipse fecit núptias. Futúri \
enim erant, de quibus dixit Apóstolus, prohibéntes núbere, et dicéntes \
quod malum essent núptiæ, et quod diábolus eas fecísset: cum idem \
Dóminus dicat in Evangélio interrogátus, utrum líceat hómini dimíttere \
uxórem suam ex quálibet causa, non licére, excépta causa fornicatiónis. \
In qua responsióne, si meminístis, hoc ait: Quod Deus conjúnxit, homo \
non séparet.")  ; L7

        (:text "\
Et qui bene erudíti sunt in fide catholica novérunt, quod Deus fécerit \
nuptias: et sicut conjúnctio a Deo, ita divortium a diabolo sit. Sed \
proptérea in causa fornicatiónis licet uxórem dimíttere: quia ipsa \
esse uxor prior nóluit, quæ fidem conjugalem maríto non servávit. Nec \
illæ, quæ virginitátem Deo vovent, quamquam ampliórem gradum honoris \
et sanctitátis in Ecclésia teneant, sine nuptiis sunt: nam et ipsæ \
pertinent ad nuptias cum tota Ecclésia, in quibus nuptiis sponsus est \
Christus.")  ; L8

        (:text "\
Ac per hoc ergo Dóminus invitátus venit ad nuptias, ut conjugális \
cástitas firmarétur, et ostenderétur sacraméntum nuptiárum: quia et \
illárum nuptiárum sponsus personam Dómini figurábat cui dictum est: \
Servásti vinum bonum usque adhuc. Bonum enim vinum Christus servávit \
usque adhuc, id est, Evangélium suum.")  ; L9
        )

        :responsories
        (
        (:respond "Dómine, ne in ira tua árguas me, neque in furóre tuo corrípias me: * Miserére mei, Dómine, quóniam infírmus sum." :verse "Timor et tremor venérunt super me, et contexérunt me ténebræ." :repeat "Miserére mei, Dómine, quóniam infírmus sum.")  ; R1

        (:respond "Deus, qui sedes super thronum, et júdicas æquitátem, esto refúgium páuperum in tribulatióne: * Quia tu solus labórem et dolórem consíderas." :verse "Tibi enim derelíctus est pauper, pupíllo tu eris adjútor." :repeat "Quia tu solus labórem et dolórem consíderas.")  ; R2

        (:respond "A dextris est mihi Dóminus, ne commóvear: * Propter hoc dilatátum est cor meum, et exsultávit lingua mea." :verse "Dóminus pars hereditátis meæ, et cálicis mei." :repeat "Propter hoc dilatátum est cor meum, et exsultávit lingua mea.")  ; R3

        (:respond "Notas mihi fecísti, Dómine, vias vitæ: * Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem." :verse "Tu es qui restítues hereditátem meam mihi." :repeat "Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem.")  ; R4

        (:respond "Díligam te, Dómine, virtus mea: Dóminus firmaméntum meum, * Et refúgium meum." :verse "Liberátor meus, Deus meus, adjútor meus." :repeat "Et refúgium meum.")  ; R5

        (:respond "Dómini est terra, et plenitúdo ejus: * Orbis terrárum, et univérsi qui hábitant in eo." :verse "Ipse super mária fundávit eam, et super flúmina præparávit illam." :repeat "Orbis terrárum, et univérsi qui hábitant in eo.")  ; R6

        (:respond "Ad te, Dómine, levávi ánimam meam: * Deus meus, in te confído, non erubéscam." :verse "Custódi ánimam meam, et éripe me." :repeat "Deus meus, in te confído, non erubéscam.")  ; R7

        (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: Plena est omnis terra glória ejus.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  suscepit-deus-israel
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  nuptiae-factae-sunt
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon deficiente-vino
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Epiphany 3 — Dominica III post Epiphaniam (DO: Epi3-0)
    ;; Scripture: Gal 1; Patristic: St Augustine, In Ep. ad Gal.;
    ;; Homily: St Jerome (Matt 8:1-13)
    ;; ════════════════════════════════════════════════════════════════════

    (4
     . (:lessons
        (
        (:ref "Gal 1:1-5" :source "Incipit Epístola beáti Pauli Apóstoli ad Gálatas" :text "\
1 Paulus Apóstolus non ab homínibus, neque per hóminem, sed per Jesum \
Christum, et Deum Patrem, qui suscitávit eum a mórtuis:\n\
2 et qui mecum sunt omnes fratres, ecclésiis Galátiæ.\n\
3 Grátia vobis, et pax a Deo Patre, et Dómino nostro Jesu Christo,\n\
4 qui dedit semetípsum pro peccátis nostris, ut eríperet nos de \
præsénti sǽculo nequam, secúndum voluntátem Dei et Patris nostri,\n\
5 cui est glória in sǽcula sæculórum. Amen.")  ; L1

        (:ref "Gal 1:6-10" :text "\
6 Miror quod sic tam cito transferímini ab eo, qui vos vocávit in \
grátiam Christi in áliud Evangélium:\n\
7 quod non est áliud, nisi sunt áliqui, qui vos contúrbant, et volunt \
convértere Evangélium Christi.\n\
8 Sed licet nos, aut Angelus de cælo evangelízet vobis prætérquam quod \
evangelizávimus vobis, anáthema sit.\n\
9 Sicut prædíximus, et nunc íterum dico: Si quis vobis evangelizáverit \
præter id, quod accepístis, anáthema sit.\n\
10 Modo enim homínibus suádeo, an Deo? An quæro homínibus placére? Si \
adhuc homínibus placérem, Christi servus non essem.")  ; L2

        (:ref "Gal 1:11-14" :text "\
11 Notum enim vobis fácio, fratres, Evangélium, quod evangelizátum est \
a me, quia non est secúndum hóminem:\n\
12 neque enim ego ab hómine accépi illud, neque dídici, sed per \
revelatiónem Jesu Christi.\n\
13 Audístis enim conversatiónem meam aliquándo in Judaísmo: quóniam \
supra modum persequébar Ecclésiam Dei, et expugnábam illam,\n\
14 et proficiébam in Judaísmo supra multos coætáneos meos in génere \
meo, abundántius æmulátor exístens paternárum meárum traditiónum.")  ; L3

        (:ref "Præfátio, tom. 4" :source "De Expositióne sancti Augustíni Epíscopi in Epístolam ad Gálatas" :text "\
Causa, propter quam scribit Apóstolus ad Gálatas, hæc est: ut \
intélligant grátiam Dei id secum ágere, ut sub lege jam non sint. Cum \
enim prædicáta eis esset Evangélii grátia, non defuérunt quidam ex \
circumcisióne, quamvis Christiáni nómine, nondum tamen tenéntes ipsum \
gratiæ benefícium, et adhuc voléntes esse sub onéribus legis, quæ \
Dóminus Deus imposúerat non justítiæ serviéntibus, sed peccáto, justam \
scílicet legem injústis homínibus dando ad demonstranda peccáta eórum, \
non auferenda. Non enim aufert peccáta, nisi grátia fidei, quæ per \
dilectiónem operátur.")  ; L4

        (:text "\
Sub hac ergo grátia jam Gálatas constitútos illi volébant constitúere \
sub onéribus legis, asseverántes nihil eis prodésse Evangélium, nisi \
circumcideréntur, et céteras carnáles Judáici ritus observatiónes \
subírent. Et ídeo Paulum Apóstolum suspéctum habére cœ́perant, a quo \
illis Evangélium prædicátum erat, tamquam non tenéntem disciplínam \
ceterórum Apostolórum, qui gentes cogébant judaizáre.")  ; L5

        (:text "\
Talis quidem quǽstio est et in Epístola ad Romános: verúmtamen vidétur \
áliquid interésse, quod ibi contentiónem ipsam dírimit, litémque \
compónit, quæ inter eos, qui ex Judǽis, et eos, qui ex Géntibus \
credíderant, orta erat: cum illi tamquam ex méritis óperum legis, sibi \
rédditum Evangélii prǽmium arbitraréntur, quod prǽmium incircumcísis \
tamquam imméritis nolébant dari: illi contra Judǽis se præférre \
gestírent, tamquam interfectóribus Dómini. In hac vero epístola ad eos \
scribit, qui jam commóti erant auctoritáte illórum, qui ex Judǽis \
erant, et ad observatiónes legis cogébant.")  ; L6

        (:ref "Matt 8:1-13" :source "Léctio sancti Evangélii secúndum Matthǽum" :text "\
In illo témpore: Cum descendísset Jesus de monte, secútæ sunt eum \
turbæ multæ: et ecce leprósus véniens, adorábat eum. Et réliqua.\n\
Homilía sancti Hierónymi Presbýteri\n\
De monte Dómino descendénte, occúrrunt turbæ, quia ad altióra \
ascéndere non valuérunt. Et primus ei occúrrit leprósus: necdum enim \
póterat cum lepra tam multíplicem in monte Salvatóris audíre sermónem. \
Et notándum, quod hic primus speciáliter curátus sit: secúndo, puer \
centuriónis: tértio, socrus Petri fébriens in Caphárnaum: quarto loco, \
qui obláti sunt ei a dæmónio vexáti: quorum spíritus verbo eiciébat, \
quando et omnes male habéntes curávit.")  ; L7

        (:text "\
Et ecce leprósus véniens adorábat eum, dicens. Recte post prædicatiónem \
atque doctrínam, signi offértur occásio, ut per virtútem miráculi, \
prætéritus apud audiéntes sermo firmétur. Dómine, si vis, potes me \
mundáre. Qui voluntátem rogat, de virtúte non dúbitat. Et exténdens \
Jesus manum tétigit eum, dicens: Volo, mundáre. Extendénte manum \
Dómino, statim lepra fugit. Simúlque consídera, quam húmilis, et sine \
jactántia respónsio. Ille díxerat, Si vis: Dóminus respóndit, Volo. \
Ille præmíserat, Potes me mundáre: Dóminus jungit, et dicit, Mundáre. \
Non ergo, ut pleríque Latinórum putant, jungéndum est, et legéndum, \
Volo mundáre: sed separátim, ut primum dicat, Volo; deínde ímperet, \
Mundáre.")  ; L8

        (:text "\
Et ait illi Jesus: Vide, némini díxeris. Et revéra quid erat necésse \
ut sermóne jactáret, quod córpore præferébat? Sed vade, osténde te \
sacerdóti. Várias ob causas mittit eum ad sacerdótem: primum propter \
humilitátem, ut sacerdótibus deférre honórem videátur. Erat enim lege \
præcéptum, ut, qui mundáti fúerant a lepra, offérrent múnera \
sacerdótibus. Deínde, ut mundátum vidéntes leprósum, aut créderent \
Salvatóri, aut non créderent: si créderent, salvaréntur; si non \
créderent, inexcusábiles forent. Et simul, ne, quod in eo sæpíssime \
criminabántur, legem viderétur infríngere.")  ; L9
        )

        :responsories
        (
        (:respond "Dómine, ne in ira tua árguas me, neque in furóre tuo corrípias me: * Miserére mei, Dómine, quóniam infírmus sum." :verse "Timor et tremor venérunt super me, et contexérunt me ténebræ." :repeat "Miserére mei, Dómine, quóniam infírmus sum.")  ; R1
        (:respond "Deus, qui sedes super thronum, et júdicas æquitátem, esto refúgium páuperum in tribulatióne: * Quia tu solus labórem et dolórem consíderas." :verse "Tibi enim derelíctus est pauper, pupíllo tu eris adjútor." :repeat "Quia tu solus labórem et dolórem consíderas.")  ; R2
        (:respond "A dextris est mihi Dóminus, ne commóvear: * Propter hoc dilatátum est cor meum, et exsultávit lingua mea." :verse "Dóminus pars hereditátis meæ, et cálicis mei." :repeat "Propter hoc dilatátum est cor meum, et exsultávit lingua mea.")  ; R3
        (:respond "Notas mihi fecísti, Dómine, vias vitæ: * Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem." :verse "Tu es qui restítues hereditátem meam mihi." :repeat "Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem.")  ; R4
        (:respond "Díligam te, Dómine, virtus mea: Dóminus firmaméntum meum, * Et refúgium meum." :verse "Liberátor meus, Deus meus, adjútor meus." :repeat "Et refúgium meum.")  ; R5
        (:respond "Dómini est terra, et plenitúdo ejus: * Orbis terrárum, et univérsi qui hábitant in eo." :verse "Ipse super mária fundávit eam, et super flúmina præparávit illam." :repeat "Orbis terrárum, et univérsi qui hábitant in eo.")  ; R6
        (:respond "Ad te, Dómine, levávi ánimam meam: * Deus meus, in te confído, non erubéscam." :verse "Custódi ánimam meam, et éripe me." :repeat "Deus meus, in te confído, non erubéscam.")  ; R7
        (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: Plena est omnis terra glória ejus.")  ; R8
        )

        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  cum-descendisset-jesus
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon domine-si-vis-potes
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Epiphany 4 — Dominica IV post Epiphaniam (DO: Epi4-0)
    ;; Scripture: Phil 1; Patristic: St Gregory, Moralia IV;
    ;; Homily: St Jerome (Matt 8:23-27)
    ;; ════════════════════════════════════════════════════════════════════

    (5
     . (:lessons
        (
        (:ref "Phil 1:1-7" :source "Incipit Epístola beáti Pauli Apóstoli ad Philippénses" :text "\
1 Paulus et Timótheus, servi Jesu Christi, ómnibus sanctis in Christo \
Jesu, qui sunt Philíppis, cum epíscopis et diacónibus.\n\
2 Grátia vobis, et pax a Deo Patre nostro, et Dómino Jesu Christo.\n\
3 Grátias ago Deo meo in omni memória vestri,\n\
4 semper in cunctis oratiónibus meis pro ómnibus vobis, cum gáudio \
deprecatiónem fáciens,\n\
5 super communicatióne vestra in Evangélio Christi a prima die usque \
nunc.\n\
6 Confídens hoc ipsum, quia qui cœpit in vobis opus bonum, perfíciet \
usque in diem Christi Jesu:\n\
7 sicut est mihi justum hoc sentíre pro ómnibus vobis: eo quod hábeam \
vos in corde, et in vínculis meis, et in defensióne, et confirmatióne \
Evangélii, sócios gáudii mei omnes vos esse.")  ; L1

        (:ref "Phil 1:8-14" :text "\
8 Testis enim mihi est Deus, quómodo cúpiam omnes vos in viscéribus \
Jesu Christi.\n\
9 Et hoc oro, ut cáritas vestra magis ac magis abúndet in sciéntia, \
et in omni sensu:\n\
10 ut probétis potióra, ut sitis sincéri, et sine offénsa in diem \
Christi,\n\
11 repléti fructu justítiæ per Jesum Christum, in glóriam et laudem \
Dei.\n\
12 Scire autem vos volo fratres, quia quæ circa me sunt, magis ad \
proféctum venérunt Evangélii:\n\
13 ita ut víncula mea manifésta fíerent in Christo in omni prætório, \
et in céteris ómnibus,\n\
14 et plures e frátribus in Dómino confidéntes vínculis meis, \
abundántius audérent sine timóre verbum Dei loqui.")  ; L2

        (:ref "Phil 1:15-18" :text "\
15 Quidam quidem et propter invídiam et contentiónem: quidam autem et \
propter bonam voluntátem Christum prǽdicant:\n\
16 quidam ex caritáte, sciéntes quóniam in defensiónem Evangélii \
pósitus sum.\n\
17 Quidam autem ex contentióne Christum annúntiant non sincére, \
existimántes pressúram se suscitáre vínculis meis.\n\
18 Quid enim? Dum omni modo sive per occasiónem, sive per veritátem, \
Christus annuntiétur: et in hoc gáudeo, sed et gaudébo.")  ; L3

        (:ref "Lib. 4, Cap. 30" :source "Ex libro Morálium sancti Gregórii Papæ" :text "\
Replémus refectiónibus corpus, ne extenuátum defíciat; extenuámus \
abstinéntia, ne nos replétum premat: vegetámus hoc mótibus, ne situ \
immobilitátis intéreat; sed cítius hoc collocándo sístimus, ne ipsa \
sua vegetatióne succúmbat: adjuméntis hoc véstium tégimus, ne frigus \
intérimat; et quæsíta adjuménta projícimus, ne calor exúrat. Tot ígitur \
diversitátibus occurréntes, quid ágimus, nisi corruptibilitáti sérvimus, \
ut saltem multiplícitas impénsi obséquii corpus sustíneat, quod anxíetas \
infírmæ mutabilitátis gravat?")  ; L4

        (:text "\
Unde bene per Paulum dícitur: Vanitáti enim subjécta est creatúra non \
volens, sed propter eum qui subjécit eam in spe: quia et ipsa creatúra \
liberábitur a servitúte corruptiónis, in libertátem glóriæ filiórum Dei. \
Vanitáti quippe creatúra non volens súbditur: quia homo, qui ingénitæ \
constántiæ statum volens deséruit, pressus justæ mortalitátis póndere, \
nolens mutabilitátis suæ corruptióni servit. Sed creatúra hæc tunc a \
servitúte corruptiónis erípitur, cum ad filiórum Dei glóriam incorrúpta \
resurgéndo sublevátur.")  ; L5

        (:text "\
Hic ítaque elécti moléstia vincti sunt, quia adhuc corruptiónis suæ \
pœna deprimúntur: sed cum corruptíbili carne exúimur, quasi ab his, \
quibus nunc astríngimur, moléstiæ vínculis relaxámur. Præsentári namque \
jam Deo cúpimus, sed adhuc mortális córporis obligatióne præpedímur. \
Jure ergo vincti dícimur, quia adhuc incéssum nostri desidérii ad Deum \
líberum non habémus. Unde bene Paulus, ætérna desíderans, sed tamen \
adhuc corruptiónis suæ sárcinam portans, vinctus clamat: Cúpio dissólvi, \
et esse cum Christo. Dissólvi enim non quǽreret, nisi se proculdúbio \
vinctum vidéret.")  ; L6

        (:ref "Matt 8:23-27" :source "Léctio sancti Evangélii secúndum Matthǽum" :text "\
In illo témpore: Ascendénte Jesu in navículam, secúti sunt eum discípuli \
ejus: et ecce motus magnus factus est in mari. Et réliqua.\n\
Homilía sancti Hierónymi Presbýteri\n\
Quintum signum fecit, quando ascéndens navem de Caphárnaum, ventis \
imperávit et mari. Sextum, quando in regióne Gerasenórum dedit \
potestátem dæmónibus in porcos. Séptimum, quando ingrédiens civitátem \
suam, paralýticum secúndum curávit in léctulo. Primus enim paralýticus \
est puer centuriónis.")  ; L7

        (:text "\
Ipse vero dormiébat: et accessérunt ad eum, et suscitavérunt eum, \
dicéntes: Dómine, salva nos. Hujus signi typum in Jona légimus, quando \
céteris periclitántibus, ipse secúrus est, et dormit, et suscitátur; \
et império ac sacraménto passiónis suæ líberat suscitántes. Tunc \
surgens imperávit ventis et mari. Ex hoc loco intellígimus, quod omnes \
creatúræ séntiant Creatórem. Quas enim increpávit, et quibus imperávit, \
sentiunt imperántem: non erróre hæreticórum qui ómnia putant animántia, \
sed majestáte Conditóris, quæ apud nos insensibília, illi sensibília \
sunt.")  ; L8

        (:text "\
Porro hómines miráti sunt, dicéntes: Qualis est hic, quia venti et \
mare obédiunt ei? Non discípuli, sed nautæ, et céteri, qui in navi \
erant, mirabántur. Sin autem quis contentióse volúerit, eos, qui \
mirabántur, fuísse discípulos: respondébimus, recte hómines appellátos, \
qui necdum nóverant poténtiam Salvatóris.")  ; L9
        )

        :responsories
        (
        (:respond "Dómine, ne in ira tua árguas me, neque in furóre tuo corrípias me: * Miserére mei, Dómine, quóniam infírmus sum." :verse "Timor et tremor venérunt super me, et contexérunt me ténebræ." :repeat "Miserére mei, Dómine, quóniam infírmus sum.")  ; R1
        (:respond "Deus, qui sedes super thronum, et júdicas æquitátem, esto refúgium páuperum in tribulatióne: * Quia tu solus labórem et dolórem consíderas." :verse "Tibi enim derelíctus est pauper, pupíllo tu eris adjútor." :repeat "Quia tu solus labórem et dolórem consíderas.")  ; R2
        (:respond "A dextris est mihi Dóminus, ne commóvear: * Propter hoc dilatátum est cor meum, et exsultávit lingua mea." :verse "Dóminus pars hereditátis meæ, et cálicis mei." :repeat "Propter hoc dilatátum est cor meum, et exsultávit lingua mea.")  ; R3
        (:respond "Notas mihi fecísti, Dómine, vias vitæ: * Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem." :verse "Tu es qui restítues hereditátem meam mihi." :repeat "Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem.")  ; R4
        (:respond "Díligam te, Dómine, virtus mea: Dóminus firmaméntum meum, * Et refúgium meum." :verse "Liberátor meus, Deus meus, adjútor meus." :repeat "Et refúgium meum.")  ; R5
        (:respond "Dómini est terra, et plenitúdo ejus: * Orbis terrárum, et univérsi qui hábitant in eo." :verse "Ipse super mária fundávit eam, et super flúmina præparávit illam." :repeat "Orbis terrárum, et univérsi qui hábitant in eo.")  ; R6
        (:respond "Ad te, Dómine, levávi ánimam meam: * Deus meus, in te confído, non erubéscam." :verse "Custódi ánimam meam, et éripe me." :repeat "Deus meus, in te confído, non erubéscam.")  ; R7
        (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: Plena est omnis terra glória ejus.")  ; R8
        )

        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  ascendente-jesu
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon domine-salva-nos-perimus
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Epiphany 5 — Dominica V post Epiphaniam (DO: Epi5-0)
    ;; Scripture: 1 Tim 1; Patristic: St Augustine, De Verbis Apostoli;
    ;; Homily: St Augustine (Matt 13:24-30)
    ;; ════════════════════════════════════════════════════════════════════

    (6
     . (:lessons
        (
        (:ref "1 Tim 1:1-4" :source "Incipit Epístola prima beáti Pauli Apóstoli ad Timótheum" :text "\
1 Paulus Apóstolus Jesu Christi secúndum impérium Dei Salvatóris nostri, \
et Christi Jesu spei nostræ:\n\
2 Timótheo dilécto fílio in fide. Grátia, misericórdia, et pax a Deo \
Patre, et Christo Jesu Dómino nostro.\n\
3 Sicut rogávi te ut remanéres Ephesi, cum irem in Macedóniam, ut \
denuntiáres quibúsdam ne áliter docérent,\n\
4 neque inténderent fábulis, et genealógiis interminátis: quæ \
quæstiónes præstant magis quam ædificatiónem Dei, quæ est in fide.")  ; L1

        (:ref "1 Tim 1:5-11" :text "\
5 Finis autem præcépti est cáritas de corde puro, et consciéntia bona, \
et fide non ficta.\n\
6 A quibus quidam aberrántes, convérsi sunt in vanilóquium,\n\
7 voléntes esse legis doctóres, non intelligéntes neque quæ loquúntur, \
neque de quibus affírmant.\n\
8 Scimus autem quia bona est lex, si quis ea legítime utátur:\n\
9 sciens hoc quia lex justo non est pósita, sed injústis, et non \
súbditis, ímpiis et peccatóribus, scelerátis, et contaminátis, \
parricídis et matricídis, homicídis,\n\
10 fornicáriis, masculórum concubitóribus, plagiáriis, mendácibus et \
perjúris, et si quid áliud sanæ doctrinæ adversátur,\n\
11 quæ est secúndum Evangélium glóriæ beáti Dei, quod créditum est \
mihi.")  ; L2

        (:ref "1 Tim 1:12-16" :text "\
12 Grátias ago ei, qui me confortávit Christo Jesu Dómino nostro, quia \
fidélem me existimávit, ponens in ministério:\n\
13 qui prius blásphémus fui, et persecútor, et contumeliósus: sed \
misericórdiam Dei consecútus sum, quia ignórans feci in incredulitáte.\n\
14 Superabundávit autem grátia Dómini nostri cum fide et dilectióne, \
quæ est in Christo Jesu.\n\
15 Fidélis sermo, et omni acceptióne dignus: quod Christus Jesus venit \
in hunc mundum peccatóres salvos fácere, quorum primus ego sum.\n\
16 Sed ídeo misericórdiam consecútus sum: ut in me primo osténderet \
Christus Jesus omnem patiéntiam ad informatiónem eórum, qui creditúri \
sunt illi, in vitam ætérnam.")  ; L3

        (:ref "De Verbis Apostoli, Sermo 8" :source "Sermo sancti Augustíni Epíscopi" :text "\
Humánus sermo, et omni acceptióne dignus, quia Christus Jesus venit in \
hunc mundum peccatóres salvos fácere. Atténde Evangélium: Venit enim \
Fílius hóminis quǽrere, et salváre, quod períerat. Si homo non \
periísset, Fílius hóminis non venísset. Ergo períerat homo: venit Deus \
homo, et invéntus est homo. Períerat homo per líberam voluntátem: venit \
Deus homo per grátiam liberatrícem.")  ; L4

        (:text "\
Quǽris, quid váleat ad malum líberum arbítrium? Recóle hóminem \
peccántem. Quǽris, quid váleat ad auxílium Deus et homo? Atténde in \
eo grátiam liberántem. Nusquam pótuit sic osténdi, quantum váleat \
volúntas hóminis usurpáta per supérbiam, ad uténdum sine adjutório Dei: \
malum non pótuit plus, et maniféstius éxprimi, quam in hómine primo. \
Ecce perit primus homo, et ubi esset, nisi venísset secúndus homo? \
quia et ille homo, ídeo et iste homo; et ídeo humánus sermo.")  ; L5

        (:text "\
Prorsus nusquam sic appáret benignitas grátiæ, et liberálitas \
omnipoténtiæ Dei, quam in hómine mediatóre Dei et hóminum, hómine \
Christo Jesu. Quid enim dícimus, fratres mei? In fide cathólica \
nutrítis loquor, vel in pacem cathólicam lucrátis. Nóvimus et tenémus, \
mediatórem Dei et hóminum, hóminem Christum Jesum, in quantum homo \
erat, ejus esse natúræ, cujus et nos sumus. Non enim altérius natúræ \
caro nostra, et caro illíus: nec altérius natúræ ánima nostra, et \
ánima illíus. Hanc suscépit natúram, quam salvándam esse judicávit.")  ; L6

        (:ref "Matt 13:24-30" :source "Léctio sancti Evangélii secúndum Matthǽum" :text "\
In illo témpore: Dixit Jesus turbis parábolam hanc: Símile factum est \
regnum cælórum hómini qui seminávit bonum semen in agro suo. Et \
réliqua.\n\
Homilía sancti Augustíni Epíscopi\n\
Cum negligéntius ágerent præpósiti Ecclésiæ, aut cum dormitiónem \
mortis accíperent Apóstoli, venit diábolus, et superseminávit eos, \
quos malos fílios Dóminus interpretátur. Sed quǽritur: utrum hǽretici \
sint, an male vivéntes cathólici? Possunt enim dici fílii mali étiam \
hǽretici, quia ex eódem Evangélii sémine, et Christi nómine procreáti, \
pravis opiniónibus ad falsa dógmata convertúntur.")  ; L7

        (:text "\
Sed quod dicit eos in médio trítici seminátos, quasi vidéntur illi \
significári, qui uníus communiónis sunt. Verúmtamen quóniam Dóminus \
agrum ipsum, non Ecclésiam, sed hunc mundum interpretátus est: bene \
intelligúntur hǽretici, quia non societáte uníus Ecclésiæ, vel uníus \
fídei, sed societáte solíus nóminis christiáni in hoc mundo \
permiscéntur bonis. At illi, qui in eádem fide mali sunt, pálea pótius \
quam zizánia reputántur: quia pálea étiam fundaméntum ipsum habet cum \
fruménto, radícemque commúnem.")  ; L8

        (:text "\
In illa plane sagéna, qua concludúntur et mali et boni pisces, non \
absúrde mali cathólici intelligúntur. Aliud est enim mare, quod magis \
mundum istum signíficat: áliud sagéna, quæ uníus fídei, vel uníus \
Ecclésiæ communiónem vidétur osténdere. Inter hǽreticos et malos \
cathólicos hoc interest, quod hǽretici falsa credunt: illi autem, vera \
credéntes, non vivunt ita ut credunt.")  ; L9
        )

        :responsories
        (
        (:respond "Dómine, ne in ira tua árguas me, neque in furóre tuo corrípias me: * Miserére mei, Dómine, quóniam infírmus sum." :verse "Timor et tremor venérunt super me, et contexérunt me ténebræ." :repeat "Miserére mei, Dómine, quóniam infírmus sum.")  ; R1
        (:respond "Deus, qui sedes super thronum, et júdicas æquitátem, esto refúgium páuperum in tribulatióne: * Quia tu solus labórem et dolórem consíderas." :verse "Tibi enim derelíctus est pauper, pupíllo tu eris adjútor." :repeat "Quia tu solus labórem et dolórem consíderas.")  ; R2
        (:respond "A dextris est mihi Dóminus, ne commóvear: * Propter hoc dilatátum est cor meum, et exsultávit lingua mea." :verse "Dóminus pars hereditátis meæ, et cálicis mei." :repeat "Propter hoc dilatátum est cor meum, et exsultávit lingua mea.")  ; R3
        (:respond "Notas mihi fecísti, Dómine, vias vitæ: * Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem." :verse "Tu es qui restítues hereditátem meam mihi." :repeat "Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem.")  ; R4
        (:respond "Díligam te, Dómine, virtus mea: Dóminus firmaméntum meum, * Et refúgium meum." :verse "Liberátor meus, Deus meus, adjútor meus." :repeat "Et refúgium meum.")  ; R5
        (:respond "Dómini est terra, et plenitúdo ejus: * Orbis terrárum, et univérsi qui hábitant in eo." :verse "Ipse super mária fundávit eam, et super flúmina præparávit illam." :repeat "Orbis terrárum, et univérsi qui hábitant in eo.")  ; R6
        (:respond "Ad te, Dómine, levávi ánimam meam: * Deus meus, in te confído, non erubéscam." :verse "Custódi ánimam meam, et éripe me." :repeat "Deus meus, in te confído, non erubéscam.")  ; R7
        (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: Plena est omnis terra glória ejus.")  ; R8
        )

        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  domine-nonne-bonum
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon colligite-primum-zizania
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Epiphany 6 — Dominica VI post Epiphaniam (DO: Epi6-0)
    ;; Scripture: Heb 1; Patristic: St Athanasius, Contra Arianos II;
    ;; Homily: St Jerome (Matt 13:31-35)
    ;; ════════════════════════════════════════════════════════════════════

    (7
     . (:lessons
        (
        (:ref "Heb 1:1-4" :source "Incipit Epístola beáti Pauli Apóstoli ad Hebrǽos" :text "\
1 Multifáriam, multísque modis olim Deus loquens pátribus in prophétis:\n\
2 novíssime, diébus istis locútus est nobis in Fílio, quem constítuit \
herédem universórum, per quem fecit et sǽcula:\n\
3 qui cum sit splendor glóriæ, et figúra substántiæ ejus, portánsque \
ómnia verbo virtútis suæ, purgatiónem peccatórum fáciens, sedet ad \
déxteram majestátis in excélsis:\n\
4 tanto mélior ángelis efféctus, quanto differéntius præ illis nomen \
hereditávit.")  ; L1

        (:ref "Heb 1:5-9" :text "\
5 Cui enim dixit aliquándo angelórum: Fílius meus es tu, ego hódie \
génui te? Et rursum: Ego ero illi in patrem, et ipse erit mihi in \
fílium?\n\
6 Et cum íterum introdúcit primogénitum in orbem terræ, dicit: Et \
adórent eum omnes ángeli Dei.\n\
7 Et ad ángelos quidem dicit: Qui facit ángelos suos spíritus, et \
minístros suos flammam ignis.\n\
8 Ad Fílium autem: Thronus tuus Deus in sǽculum sǽculi: virga \
æquitátis, virga regni tui.\n\
9 Dilexísti justítiam, et odísti iniquitátem: proptérea unxit te Deus, \
Deus tuus, óleo exultatiónis præ partícipibus tuis.")  ; L2

        (:ref "Heb 1:10-14" :text "\
10 Et: Tu in princípio, Dómine, terram fundásti: et ópera mánuum \
tuárum sunt cæli.\n\
11 Ipsi períbunt, tu autem permanébis, et omnes ut vestiméntum \
veteráscent:\n\
12 et velut amíctum mutábis eos, et mutabúntur: tu autem idem ipse es, \
et anni tui non defícient.\n\
13 Ad quem autem angelórum dixit aliquándo: Sede a dextris meis, \
quoádusque ponam inimícos tuos scabéllum pedum tuórum?\n\
14 Nonne omnes sunt administratórii spíritus, in ministérium missi \
propter eos, qui hereditátem cápient salútis?")  ; L3

        (:ref "Orat. 2 contra Arianos" :source "Sermo sancti Athanásii Epíscopi" :text "\
Si persónam, rem, tempus apostólici dicti cognóscerent hǽretici, \
numquam humána in Deitátem transferéntes, tam ímpie et stulte advérsus \
Christum sese habuíssent. Id intuéri licébit, si inítium lectiónis \
dénuo repétitum probe excípias. Dicit enim Apóstolus: Multifáriam, \
multísque modis olim Deus locútus est pátribus nostris per Prophétas: \
últimis autem diébus locútus est nobis in Fílio. Atque ita paulo post \
dicit: Perfécta ab eo nostrórum peccatórum purificatióne, ipsum sedére \
ad déxteram majestátis in excélsis, tanto meliórem Ángelis factum, \
quanto præstántius nomen præ illis sortítus est.")  ; L4

        (:text "\
De eo ígitur témpore, quo nobis per Fílium locútus est, cum peccatórum \
purgátio fíeret, apostólicum dictum mentiónem facit. Quando autem nobis \
locútus est in Fílio, aut quando purgátio peccatórum facta, aut quando \
natus est homo, nisi post Prophétas, idque in últimis diébus? Deínde \
cum narrátio institúta esset de humána Verbi dispensatióne, deque \
últimis tempóribus: consequénter commemorávit, Deum neque superióríbus \
ætátibus tacuísse, sed locútum esse per Prophétas: et postquam Prophétæ \
suo offício perfúncti sunt, et lex per Ángelos pronuntiáta est, et \
Fílius étiam ad nos descéndit, et ad ministrándum accéssit; tunc demum \
necessário subíntulit: Tanto mélior Ángelis factus: osténdere volens, \
quanto Fílius præ servo excéllit, tanto functióne officióque servórum, \
Fílii administratiónem meliórem fuísse.")  ; L5

        (:text "\
Functiónem ígitur discérnens Apóstolus, tum véterem, tum novam, magna \
dicéndi libertáte útitur, ad Judǽos scribens et loquens. Propter hoc \
ígitur non in univérsum ex própria comparatiónis ratióne dixit, quod \
major aut honorátior esset: ne quis quasi de ejúsdem géneris, et cum \
eo commúnibus rebus hæc verba intellégeret: sed ídeo meliórem illum \
dixit, ut discrímen natúræ Fílii ad res creátas indicáret.")  ; L6

        (:ref "Matt 13:31-35" :source "Léctio sancti Evangélii secúndum Matthǽum" :text "\
In illo témpore: Dixit Jesus turbis parábolam hanc: Símile est regnum \
cælórum grano sinápis. Et réliqua.\n\
Homilía sancti Hierónymi Presbýteri\n\
Regnum cælórum prædicátio Evangélii est, et notítia Scripturárum, quæ \
ducit ad vitam, et de qua dícitur ad Judǽos: Auferétur a vobis regnum \
Dei, et dábitur genti faciénti fructus ejus. Símile est ergo hujusmódi \
regnum grano sinápis, quod accípiens homo seminávit in agro suo. Homo \
qui séminat in agro suo, a plerisque Salvátor intellégitur, quod in \
ánimis credéntium séminet: ab áliis ipse homo séminans in agro suo, \
hoc est in semetípso, et in corde suo.")  ; L7

        (:text "\
Quis est iste, qui séminat, nisi sensus noster et ánimus; qui \
suscípiens granum prædicatiónis, et fovens seméntem, humóre fídei facit \
in agro sui péctoris pullulare? Prædicátio Evangélii mínima est ómnium \
disciplínis. Ad primam quippe doctrínam, fidem non habet veritátis, \
hóminem Deum, Christum mórtuam, et scándalum crucis prǽdicans. Confer \
hujusmódi doctrínam dogmátibus philosophórum, et libris eórum, et \
splendóri eloquéntiæ, et compositióni sermónum: et vidébis quanto \
minor sit céteris semínibus seméntis Evangélii.")  ; L8

        (:text "\
Sed illa cum créverint, nihil mordax, nihil vívidum, nihil vitále \
demónstrant: sed totum fláccidun marcídumque et mollítum ebúllit in \
ólera et in herbas, quæ cito aréscunt et córruunt. Hæc autem \
prædicátio, quæ parva videbátur in princípio, cum vel in ánima \
credéntis, vel in tot mundo sata fúerit, non exsúrgit in ólera, sed \
crescit in árborem: ita ut volúcres cæli (quas vel ánimas credéntium, \
vel fortitúdines, Dei servítio mancipátas, sentíre debémus) véniant \
et hábitent in ramis ejus. Ramos puto evangélicæ árboris, quæ de grano \
sinápis créverit, dógmatum esse diversitátes, in quibus supradictárum \
volúcrum unaquǽque requiéscit.")  ; L9
        )

        :responsories
        (
        (:respond "Dómine, ne in ira tua árguas me, neque in furóre tuo corrípias me: * Miserére mei, Dómine, quóniam infírmus sum." :verse "Timor et tremor venérunt super me, et contexérunt me ténebræ." :repeat "Miserére mei, Dómine, quóniam infírmus sum.")  ; R1
        (:respond "Deus, qui sedes super thronum, et júdicas æquitátem, esto refúgium páuperum in tribulatióne: * Quia tu solus labórem et dolórem consíderas." :verse "Tibi enim derelíctus est pauper, pupíllo tu eris adjútor." :repeat "Quia tu solus labórem et dolórem consíderas.")  ; R2
        (:respond "A dextris est mihi Dóminus, ne commóvear: * Propter hoc dilatátum est cor meum, et exsultávit lingua mea." :verse "Dóminus pars hereditátis meæ, et cálicis mei." :repeat "Propter hoc dilatátum est cor meum, et exsultávit lingua mea.")  ; R3
        (:respond "Notas mihi fecísti, Dómine, vias vitæ: * Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem." :verse "Tu es qui restítues hereditátem meam mihi." :repeat "Adimplébis me lætítia cum vultu tuo: delectatiónes in déxtera tua usque in finem.")  ; R4
        (:respond "Díligam te, Dómine, virtus mea: Dóminus firmaméntum meum, * Et refúgium meum." :verse "Liberátor meus, Deus meus, adjútor meus." :repeat "Et refúgium meum.")  ; R5
        (:respond "Dómini est terra, et plenitúdo ejus: * Orbis terrárum, et univérsi qui hábitant in eo." :verse "Ipse super mária fundávit eam, et super flúmina præparávit illam." :repeat "Orbis terrárum, et univérsi qui hábitant in eo.")  ; R6
        (:respond "Ad te, Dómine, levávi ánimam meam: * Deus meus, in te confído, non erubéscam." :verse "Custódi ánimam meam, et éripe me." :repeat "Deus meus, in te confído, non erubéscam.")  ; R7
        (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: Plena est omnis terra glória ejus.")  ; R8
        )

        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  simile-est-regnum-caelorum-grano
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon simile-est-regnum-caelorum-fermento
        ))

    )
  "Christmastide dominical data alist.
Each entry: (WEEK-NUMBER . plist).  Matins entries have :lessons and
:responsories; non-Matins entries have :magnificat-antiphon,
:benedictus-antiphon, :lauds-antiphons, :lauds-capitulum,
:none-capitulum, :magnificat2-antiphon as applicable.
Week 0 (Nat1) and 2 (Epi1) have non-Matins data only.
Weeks 3-7 (Epi2-Epi6) have both Matins and non-Matins data.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-season-christmas-collect (date)
  "Return the collect incipit symbol for the Christmastide Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns nil outside Christmastide."
  (let ((n (bcp-roman-season-christmas--sunday-number date)))
    (when (and n (< n (length bcp-roman-season-christmas--collects)))
      (aref bcp-roman-season-christmas--collects n))))

(defun bcp-roman-season-christmas-dominical-matins (date)
  "Return dominical Matins data for the Christmastide Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories,
or nil if no data (Nat1/Nat2/Epi1 are deferred)."
  (let ((n (bcp-roman-season-christmas--sunday-number date)))
    (when n
      (cdr (assq n bcp-roman-season-christmas--dominical-matins)))))

(defun bcp-roman-season-christmas-dominical-hours (date)
  "Return non-Matins hour data for the Christmastide Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns the same plist as `dominical-matins'
\(which contains both Matins and non-Matins keys), or nil outside Christmastide.
Non-Matins keys are optional; absent means use psalterium default."
  (bcp-roman-season-christmas-dominical-matins date))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Feast-grade Matins offices
;;
;; Three fixed feasts with proper 3-nocturn Matins:
;;   christmas  — In Nativitate Domini (Dec 25)
;;   stephen    — S. Stephanus Protomartyr (Dec 26)
;;   epiphany   — In Epiphania Domini (Jan 6)
;;
;; Each entry is a plist with:
;;   :invitatory         — antiphon incipit symbol
;;   :hymn               — hymn incipit symbol
;;   :omit-invitatory    — if t, suppress invitatory and hymn (Epiphany)
;;   :psalms-1/2/3       — lists of (ANTIPHON . PSALM-NUMBER) per nocturn
;;   :versicle-1/2/3     — nocturn versicle cons (V . R) in Latin
;;   :versicle-1/2/3-en  — nocturn versicle cons (V . R) in English
;;   :lessons            — list of 9 lesson plists (:ref :source :text)
;;   :responsories       — list of 8 responsory plists (:respond :verse :repeat)

(defconst bcp-roman-season-christmas--feast-matins
  `(

    ;; ════════════════════════════════════════════════════════════════════
    ;; IN NATIVITATE DOMINI — Christmas Day (Dec 25)
    ;; Psalms: 2/18/44, 47/71/84, 88/95/97
    ;; Invitatory: Christus natus est nobis
    ;; Hymn: Christe Redemptor omnium
    ;; ════════════════════════════════════════════════════════════════════

    (christmas
     . (:invitatory christus-natus-est-nobis
        :hymn christe-redemptor-omnium
        :psalms-1 ((dominus-dixit-ad-me . 2)
                   (tamquam-sponsus-dominus . 18)
                   (diffusa-est-gratia . 44))
        :psalms-2 ((suscepimus-deus-misericordiam . 47)
                   (orietur-in-diebus-domini . 71)
                   (veritas-de-terra-orta-est . 84))
        :psalms-3 ((ipse-invocabit-me-alleluia . 88)
                   (laetentur-caeli-et-exsultet . 95)
                   (notum-fecit-dominus-alleluia . 97))
        :versicle-1 ("Tamquam sponsus."
                     "Dóminus procédens de thálamo suo.")
        :versicle-1-en ("As a bridegroom."
                        "The Lord coming forth from His bridal chamber.")
        :versicle-2 ("Speciósus forma præ fíliis hóminum."
                     "Diffúsa est grátia in lábiis tuis.")
        :versicle-2-en ("Thou art fairer than the children of men."
                        "Grace is poured into thy lips.")
        :versicle-3 ("Ipse invocábit me, allelúja."
                     "Pater meus es tu, allelúja.")
        :versicle-3-en ("He shall cry unto me, alleluia."
                        "Thou art my Father, alleluia.")

        :lessons
        (
         ;; ── Nocturn I: Isaiah ──

         (:ref "Isa 9:1-6"
          :source "De Isaía Prophéta"
          :text "\
Primo témpore alleviáta est terra Zábulon, et terra Néphthali: et \
novíssimo aggraváta est via maris trans Jordánem Galilǽæ géntium. \
Pópulus qui ambulábat in ténebris, vidit lucem magnam: habitántibus in \
regióne umbræ mortis, lux orta est eis. Multiplicásti gentem, et non \
magnificásti lætítiam. Lætabúntur coram te, sicut qui lætántur in \
messe, sicut exsúltant victóres, capta præda, quando dívidunt spólia. \
Jugum enim óneris ejus, et virgam húmeri ejus, et sceptrum exactóris \
ejus superásti sicut in die Mádian. Quia omnis violénta prædátio cum \
tumúltu, et vestiméntum mistum sánguine, erit in combustiónem, et \
cibus ignis. Párvulus enim natus est nobis, et fílius datus est nobis, \
et factus est principátus super húmerum ejus: et vocábitur nomen ejus, \
Admirábilis, Consiliárius, Deus, Fortis, Pater futúri sǽculi, \
Princeps pacis.")  ; L1

         (:ref "Isa 40:1-8"
          :text "\
Consolámini, consolámini, pópule meus, dicit Deus vester. Loquímini ad \
cor Jerúsalem, et advocáte eam: quóniam compléta est malítia ejus, \
dimíssa est iníquitas illíus: suscépit de manu Dómini duplícia pro \
ómnibus peccátis suis. Vox clamántis in desérto: Paráte viam Dómini, \
rectas fácite in solitúdine sémitas Dei nostri. Omnis vallis \
exaltábitur, et omnis mons et collis humiliábitur: et erunt prava in \
dirécta, et áspera in vias planas. Et revelábitur glória Dómini: et \
vidébit omnis caro páriter quod os Dómini locútum est. Vox dicéntis: \
Clama. Et dixi: Quid clamábo? Omnis caro fœnum, et omnis glória ejus \
quasi flos agri. Exsiccátum est fœnum, et cécidit flos: quia spíritus \
Dómini sufflávit in eo. Vere fœnum est pópulus: exsiccátum est fœnum, \
et cécidit flos: Verbum autem Dómini nostri manet in ætérnum.")  ; L2

         (:ref "Isa 52:1-6"
          :text "\
Consúrge, consúrge, indúere fortitúdine tua, Sion, indúere vestiméntis \
glóriæ tuæ, Jerúsalem, cívitas sancti: quia non adíciet ultra ut \
pertránseat per te incircumcísus, et immúndus. Excútere de púlvere, \
consúrge, sede, Jerúsalem: solve víncula colli tui, captíva fília \
Sion. Quia hæc dicit Dóminus: Gratis venumdáti estis, et sine argénto \
redimémini. Quia hæc dicit Dóminus Deus: In Ægýptum descéndit pópulus \
meus in princípio, ut colónus esset ibi: et Assur absque ulla causa \
calumniátus est eum. Et nunc quid mihi est hic, dicit Dóminus, \
quóniam ablátus est pópulus meus gratis? Dominatóres ejus iníque agunt, \
dicit Dóminus: et júgiter tota die nomen meum blasphemátur. Propter hoc \
sciet pópulus meus nomen meum, in die illa: quia ego ipse qui loquébar, \
ecce adsum.")  ; L3

         ;; ── Nocturn II: St Leo the Great, Sermo 1 de Nativitate Domini ──

         (:ref "Sermo 1 de Nativitate Domini"
          :source "Sermo sancti Leónis Papæ"
          :text "\
Salvátor noster, dilectíssimi, hódie natus est: gaudeámus. Neque enim \
fas est locum esse tristítiæ, ubi natális est vitæ: quæ, consúmpto \
mortalitátis timóre, nobis íngerit de promíssa æternitáte lætítiam. \
Nemo ab hujus alacritátis participatióne secérnitur. Una cunctis \
lætítiæ commúnis est rátio: quia Dóminus noster, peccáti mortísque \
destrúctor, sicut nullum a reátu líberum réperit, ita liberándis \
ómnibus venit. Exsúltet sanctus, quia appropínquat ad palmam: gáudeat \
peccátor, quia invitátur ad véniam: animétur gentílis, quia vocátur ad \
vitam. Dei namque Fílius secúndum plenitúdinem témporis, quam divíni \
consílii inscrutábilis altitúdo dispósuit, reconciliándam auctóri suo \
natúram géneris assúmpsit humáni, ut invéntor mortis diábolus, per \
ipsam, quam vícerat, vincerétur.")  ; L4

         (:ref "Sermo 1 de Nativitate Domini"
          :text "\
In quo conflíctu pro nobis ínito, magno et mirábili æquitátis jure \
certátum est, dum omnípotens Dóminus cum sævíssimo hoste non in sua \
majestáte, sed in nostra congréditur humilitáte: objíciens ei eándem \
formam eandémque natúram, mortalitátis quidem nostræ partícipem, sed \
peccáti totíus expértem. Aliénum quippe ab hac nativitáte est quod de \
ómnibus légitur: Nemo mundus a sorde, nec infans cujus est uníus diéi \
vita super terram. Nihil ergo in istam singularem nativitátem de carnis \
concupiscéntia transívit, nihil de peccáti lege manávit. Virgo régia \
Davídicæ stirpis elígitur, quæ sacro gravidánda fœtu, divínam \
humanámque prolem príus concíperet mente quam córpore.")  ; L5

         (:ref "Sermo 1 de Nativitate Domini"
          :text "\
Agámus ergo, dilectíssimi, grátias Deo Patri, per Fílium ejus in \
Spíritu Sancto: qui propter multam caritátem suam, qua diléxit nos, \
misértus est nostri: et cum essémus mórtui peccátis, convivificávit nos \
Christo, ut essémus in ipso nova creatúra, novúmque figméntum. \
Deponámus ergo véterem hóminem cum áctibus suis: et adépti \
participatiónem generatiónis Christi, carnis renuntiémus opéribus. \
Agnósce, o Christiáne, dignitátem tuam: et divínæ consors factus \
natúræ, noli in véterem vilítátem degéneri conversatióne redíre. \
Meménto cujus cápitis et cujus córporis sis membrum. Reminíscere quia \
erútus de potestáte tenebrárum, translátus es in Dei lumen et regnum.")  ; L6

         ;; ── Nocturn III: Homilies on Luke 2 and John 1 ──

         (:ref "Luke 2:1-14"
          :source "Homilía sancti Gregórii Papæ, Homilia 8 in Evangelia"
          :text "\
Quia, largiénte Dómino, Missárum solémnia ter hódie celebratúri sumus, \
loqui diu de evangélica lectióne non póssumus. Sed nos ipsa Redemptóris \
nostri Natívitas, ut áliquid bréviter dícere debeámus, admonet. Quid \
est enim quod, nascitúro Dómino, mundus descríbitur, nisi hoc quod \
apérte monstrátur, quia ille apparébat in carne, qui eléctos suos \
adscríberet in æternitáte? Quo contra, de réprobis per Prophétam \
dícitur: Deleántur de libro vivéntium, et cum justis non scribántur.")  ; L7

         (:ref "Luke 2:15-20"
          :source "Homilía sancti Ambrósii Epíscopi, Lib. 2 in cap. 2 Lucæ"
          :text "\
Vidéte Ecclésiæ surgéntis exórdium: Christus náscitur, et pastóres \
vigiláre cœpérunt: qui géntium greges, pecudum modo ante vivéntes, in \
caulas Dómini congregárent, ne quos spiritálium bestiárum per ofúsas \
noctium ténebras paterétur incúrsus. Et bene pastóres vígilant, quos \
bonus Pastor infórmat. Grex ígitur pópulus, nox sǽculum, pastóres \
sunt sacerdótes.")  ; L8

         (:ref "John 1:1-14"
          :source "Homilía sancti Augustíni Epíscopi, Tract. 1 in Joann."
          :text "\
Ne vile áliquid putáres quale consuevísti cogitáre, cum audiíres verbum, \
audi quid cógites: Deus erat Verbum. Exeat nunc nescio quis infidélis \
Ariánus, et dicat quia Verbum Dei factum est. Quómodo potest fíeri ut \
Verbum Dei factum sit, quando Deus per Verbum fecit ómnia? Si et Verbum \
Dei ipsum factum est, per quod áliud verbum factum est? Si hoc dicis, \
quia hoc est verbum Verbi, per quod factum est illud, ipsum dico ego \
unicum Fílium Dei. Si autem non dicis verbum Verbi, concéde non factum, \
per quod facta sunt ómnia. Non enim per seípsum fíeri pótuit, per quod \
facta sunt ómnia. Crede ergo Evangelístæ.")  ; L9
        )

        :responsories
        (
         ;; R1 — Special Christmas structure: V. is "Gloria in excelsis"
         ;; and Gloria Patri returns to full respond (ad repetendum)
         (:respond "Hódie nobis cælórum Rex de Vírgine nasci dignátus est, \
ut hóminem pérditum ad cæléstia regna revocáret: * Gaudet exércitus \
Angelórum: quia salus ætérna humáno géneri appáruit."
          :verse "Glória in excélsis Deo, et in terra pax homínibus bonæ \
voluntátis."
          :repeat "Gaudet exércitus Angelórum: quia salus ætérna humáno \
géneri appáruit."
          :gloria t)  ; R1

         (:respond "Hódie nobis de cælo pax vera descéndit: * Hódie per \
totum mundum mellíflui facti sunt cæli."
          :verse "Hódie illúxit nobis dies redemptiónis novæ, reparatiónis \
antíquæ, felicitátis ætérnæ."
          :repeat "Hódie per totum mundum mellíflui facti sunt cæli.")  ; R2

         (:respond "Quem vidístis, pastóres? dícite, annuntiáte nobis, in \
terris quis appáruit? * Natum vídimus, et choros Angelórum collaudántes \
Dóminum."
          :verse "Dícite, quidnam vidístis? et annuntiáte Christi nativitátem."
          :repeat "Natum vídimus, et choros Angelórum collaudántes Dóminum."
          :gloria t)  ; R3

         (:respond "O magnum mystérium, et admirábile sacraméntum, ut \
animália vidérent Dóminum natum, jacéntem in præsépio: * Beáta Virgo, \
cujus víscera meruérunt portáre Dóminum Christum."
          :verse "Ave, María, grátia plena: Dóminus tecum."
          :repeat "Beáta Virgo, cujus víscera meruérunt portáre Dóminum \
Christum.")  ; R4

         (:respond "Beáta Dei Génetrix María, cujus víscera intácta \
pérmanent: * Hódie génuit Salvatórem sǽculi."
          :verse "Beáta, quæ crédidit: quóniam perfécta sunt ómnia, quæ \
dicta sunt ei a Dómino."
          :repeat "Hódie génuit Salvatórem sǽculi.")  ; R5

         (:respond "Sancta et immaculáta virgínitas, quibus te láudibus \
éfferam, néscio: * Quia quem cæli cápere non póterant, tuo grémio \
contulísti."
          :verse "Benedícta tu in muliéribus, et benedíctus fructus ventris \
tui."
          :repeat "Quia quem cæli cápere non póterant, tuo grémio contulísti."
          :gloria t)  ; R6

         (:respond "Beáta víscera Maríæ Vírginis, quæ portavérunt ætérni \
Patris Fílium: et beáta úbera, quæ lactavérunt Christum Dóminum: * Qui \
hódie pro salúte mundi de Vírgine nasci dignátus est."
          :verse "Dies sanctificátus illúxit nobis: veníte, gentes, et \
adoráte Dóminum."
          :repeat "Qui hódie pro salúte mundi de Vírgine nasci dignátus \
est.")  ; R7

         (:respond "Verbum caro factum est, et habitávit in nobis: * Et \
vídimus glóriam ejus, glóriam quasi Unigéniti a Patre, plenum grátiæ et \
veritátis."
          :verse "Omnia per ipsum facta sunt, et sine ipso factum est nihil."
          :repeat "Et vídimus glóriam ejus, glóriam quasi Unigéniti a \
Patre, plenum grátiæ et veritátis."
          :gloria t)  ; R8
        )))

    ;; ════════════════════════════════════════════════════════════════════
    ;; S. STEPHANUS PROTOMARTYR — St Stephen (Dec 26)
    ;; Psalms: Commune Unius Martyris (C2): 1/2/3, 4/5/8, 10/14/20
    ;; Invitatory: Christum natum qui beatum
    ;; Hymn: Deus tuorum militum
    ;; ════════════════════════════════════════════════════════════════════

    (stephen
     . (:invitatory christum-natum-qui-beatum
        :hymn deus-tuorum-militum
        :psalms-1 ((in-lege-domini-fuit . 1)
                   (praedicans-praeceptum-domini . 2)
                   (voce-mea-ad-dominum-clamavi . 3))
        :psalms-2 ((filii-hominum-scitote . 4)
                   (scuto-bonae-voluntatis . 5)
                   (in-universa-terra-gloria . 8))
        :psalms-3 ((justus-dominus-et-justitiam . 10)
                   (habitabit-in-tabernaculo-tuo . 14)
                   (posuisti-domine-super-caput . 20))
        :versicle-1 ("Glória et honóre coronásti eum, Dómine."
                     "Et constituísti eum super ópera mánuum tuárum.")
        :versicle-1-en ("Thou crownedst him with glory and honour, O Lord."
                        "And didst set him over the works of thy hands.")
        :versicle-2 ("Posuísti, Dómine, super caput ejus."
                     "Corónam de lápide pretióso.")
        :versicle-2-en ("Thou hast set, O Lord, upon his head."
                        "A crown of precious stone.")
        :versicle-3 ("Magna est glória ejus in salutári tuo."
                     "Glóriam et magnum decórem impónes super eum.")
        :versicle-3-en ("His glory is great in thy salvation."
                        "Glory and great worship shalt thou lay upon him.")

        :lessons
        (
         ;; ── Nocturn I: Acts of the Apostles ──

         (:ref "Acts 6:1-6"
          :source "De Actibus Apostolórum"
          :text "\
In diébus illis, crescénte número discipulórum, factum est murmur \
Græcórum advérsus Hebrǽos, eo quod despicerétur in ministério \
quotidiáno víduæ eórum. Convocántes autem duódecim multitúdinem \
discipulórum, dixérunt: Non est æquum nos derelinquere verbum Dei, \
et ministráre mensis. Consideráte ergo, fratres, viros ex vobis boni \
testimónii septem, plenos Spíritu Sancto et sapiéntia, quos \
constituámus super hoc opus. Nos vero oratióni et ministério verbi \
instántes érimus. Et plácuit sermo coram omni multitúdine. Et elegérunt \
Stéphanum, virum plenum fide et Spíritu Sancto, et Philíppum, et \
Próchorum, et Nicanórem, et Timónem, et Parménam, et Nicoláum ádvenam \
Antiochénum. Hos statuérunt ante conspéctum Apostolórum: et orántes \
imposuérunt eis manus.")  ; L1

         (:ref "Acts 6:7-10; 7:54"
          :text "\
Et verbum Dómini crescébat, et multiplicabátur númerus discipulórum in \
Jerúsalem valde: multa étiam turba sacerdótum obediébat fídei. \
Stéphanus autem plenus grátia et fortitúdine, faciébat prodígia et \
signa magna in pópulo. Surrexérunt autem quidam de synagóga, quæ \
appellátur Libertinórum, et Cyrenénsium, et Alexandrinórum, et eórum \
qui erant a Cilícia et Asia, disputántes cum Stéphano: et non póterant \
resístere sapiéntiæ, et Spirítui qui loquebátur. Audiéntes autem hæc, \
dissecabántur córdibus suis, et stridébant déntibus in eum.")  ; L2

         (:ref "Acts 7:55-59"
          :text "\
Cum autem esset plenus Spíritu Sancto, inténdens in cælum, vidit \
glóriam Dei, et Jesum stantem a dextris Dei. Et ait: Ecce vídeo cælos \
apértos, et Fílium hóminis stantem a dextris Dei. Exclamántes autem \
voce magna, continuérunt aures suas, et ímpetum fecérunt unanímiter in \
eum. Et ejiciéntes eum extra civitátem, lapidábant: et testes \
deposuérunt vestiménta sua secus pedes adolescéntis, qui vocabátur \
Saulus. Et lapidábant Stéphanum invocántem, et dicéntem: Dómine Jesu, \
áccipe spíritum meum. Pósitis autem génibus, clamávit voce magna, \
dicens: Dómine, ne státuas illis hoc peccátum. Et cum hoc dixísset, \
obdormívit in Dómino.")  ; L3

         ;; ── Nocturn II: St Fulgentius, Sermo 3 de S. Stephano ──

         (:ref "Sermo 3, de S. Stéphano"
          :source "Sermo sancti Fulgéntii Epíscopi"
          :text "\
Heri celebrávimus temporálem sempitérni Regis nostri natálem: hódie \
celebrámus triumphálem mílitis passiónem. Heri enim Rex noster, \
trabéa carnis indútus, de aula úteri virgínalis egrédiens, visitáre \
dignátus est mundum: hódie miles de tabernáculo córporis éxiens, \
triúmphans migrávit ad cælum. Ille, sempitérnæ deitátis majestátem \
servíli cíngulo astríngit, substérnens: iste mortalitátis exúvias \
deponéndo, ad perénnis vitæ glóriam sublimátur. Ille descéndit carne \
velátus, iste ascéndit sánguine laureátus.")  ; L4

         (:ref "Sermo 3, de S. Stéphano"
          :text "\
Ascéndit iste lapidántibus Judǽis, quia ille descéndit lætántibus \
Angelis. Glória in excélsis Deo, heri sancti Ángeli exsultánter \
clamábant: hódie Stéphanum lætánter in suum consórtium suscepérunt. \
Heri Dóminus exívit de útero Vírginis: hódie miles egréssus est de \
cárcere carnis. Heri Christus pro nobis pannis est invólutus: hódie \
Stéphanus stola ab eo immortalitátis indúitur. Heri angústa prǽsepis \
cunábula Christum portavérunt: hódie immensítas cæli Stéphanum \
suscépit. Solus Dóminus descéndit, ut multos eleváret: humiliávit se \
Rex noster, ut suos mílites exaltáret.")  ; L5

         (:ref "Sermo 3, de S. Stéphano"
          :text "\
Necessárium tamen nobis est, fratres, agnóscere quibus armis prǽditus \
Stéphanus sǽvam Judæórum ségetem supráre potúerit: ut enim gáleas \
corónam victóriæ mererétur, caritátem pro armis habúit, et per ipsam \
ubíque vicit. Per caritátem Dei, sævíssimis persecutóribus non cessit: \
per caritátem próximi, pro lapidántibus intercessit. Per caritátem \
arguébat errántes, ut corrigeréntur: per caritátem pro lapidántibus \
orábat, ne puniéntur. Caritátis virtúte confísus, Saulum lapidántium \
crudéliter persecutántem vicit, et quem hábuit in terra persecutórem, in \
cælo méruit habére consórtem.")  ; L6

         ;; ── Nocturn III: St Jerome on Matt 23:34-39 ──

         (:ref "Matt 23:34-39"
          :source "Homilía sancti Hierónymi Presbýteri, Liber 4 Comment. in cap. 23 Matthæi"
          :text "\
Hoc quod ántea dixerámus, Impléte mensúram patrum vestrórum, ad illud \
tempus refertúr, quo Dóminum erant crucifixúri. Ecce, inquit, ego \
mitto ad vos prophétas, et sapiéntes, et scribas: et ex illis \
occidétis, et crucifigétis, et ex eis flagellábitis in synagógis \
vestris, et persequémini de civitáte in civitátem. Mittens Dóminus ad \
Judǽos prophétas, et sapiéntes, et scribas, misísse se signátur \
Apóstolos: ex quibus lapidátus est Stéphanus, Paulus occísus, \
crucifíxus Petrus, flagelláti in Actibus Apostolórum discípuli.")  ; L7

         (:ref "Matt 23:34-39"
          :text "\
Quǽrimus, quis iste sit Zacharías fílius Barachíæ: quóniam multos \
légimus Zacharías. Et ne líbera nobis tribuerétur errándi facúltas, \
ádditum est: Quem occidístis inter templum et altáre. Divérsi divérsa \
séntiunt: et únusquísque pro auctóris sui sensu interprétem éxhibet. \
Alii Zacharíam patrem Joánnis intellégi volunt, ex quibúsdam \
apocryphárum somníis approbántes, quod proptérea occísus sit, quia \
Salvatóris prǽdicáverit advéntum.")  ; L8

         (:ref "Matt 23:34-39"
          :text "\
Alii istum volunt esse Zacharíam, qui occísus est a Joas rege Judæ \
inter templum et altáre, sicut Regum narrat história. Sed observándum \
quod ille Zacharías non sit fílius Barachíæ, sed fílius Jójadæ \
sacerdótis: unde et Scriptúra ait: Non recordátus est Joas rex \
beneficiórum Jójadæ. Cum ergo et Zacharíæ et Barachíæ multórum sit \
nomen, in Evangélio, quo utúntur Nazaréni, pro fílio Barachíæ, fílium \
Jójadæ reperímus scriptum.")  ; L9
        )

        :responsories
        (
         (:respond "Stéphanus autem plenus grátia et fortitúdine, * Faciébat \
prodígia et signa magna in pópulo."
          :verse "Surrexérunt quidam de synagóga disputántes cum Stéphano: \
et non póterant resístere sapiéntiæ, et Spirítui qui loquebátur."
          :repeat "Faciébat prodígia et signa magna in pópulo.")  ; R1

         (:respond "Vidébant omnes Stéphanum, qui erant in concílio: * Et \
intuebántur vultum ejus tamquam vultum Angeli stantis inter illos."
          :verse "Plenus grátia et fortitúdine, faciébat prodígia et signa \
magna in pópulo."
          :repeat "Et intuebántur vultum ejus tamquam vultum Angeli stantis \
inter illos.")  ; R2

         (:respond "Intuens in cælum beátus Stéphanus, vidit glóriam Dei, \
et ait: * Ecce vídeo cælos apértos, et Fílium hóminis stantem a dextris \
virtútis Dei."
          :verse "Cum autem esset Stéphanus plenus Spíritu Sancto, inténdens \
in cælum, vidit glóriam Dei, et ait."
          :repeat "Ecce vídeo cælos apértos, et Fílium hóminis stantem a \
dextris virtútis Dei."
          :gloria t)  ; R3

         (:respond "Lapidábant Stéphanum invocántem et dicéntem: * Dómine \
Jesu Christe, áccipe spíritum meum: et ne státuas illis hoc peccátum."
          :verse "Pósitis autem génibus, clamávit voce magna, dicens."
          :repeat "Dómine Jesu Christe, áccipe spíritum meum: et ne státuas \
illis hoc peccátum.")  ; R4

         (:respond "Impetum fecérunt unanímiter in eum, et ejecérunt eum \
extra civitátem, invocántem et dicéntem: * Dómine Jesu, áccipe spíritum \
meum."
          :verse "Et testes deposuérunt vestiménta sua secus pedes \
adolescéntis, qui vocabátur Saulus: et lapidábant Stéphanum invocántem \
et dicéntem."
          :repeat "Dómine Jesu, áccipe spíritum meum.")  ; R5

         (:respond "Impii super justum jactúram fecérunt, ut eum morti \
tráderent: * At ille gaudens suscépit lápides, ut mererétur accípere \
corónam glóriæ."
          :verse "Continuérunt aures suas, et ímpetum fecérunt unanímiter in \
eum."
          :repeat "At ille gaudens suscépit lápides, ut mererétur accípere \
corónam glóriæ."
          :gloria t)  ; R6

         (:respond "Stéphanus servus Dei, quem lapidábant Judǽi, vidit \
cælos apértos: vidit, et introívit: * Beátus homo, cui cæli patébant."
          :verse "Cum ígitur saxórum crepitántium túrbine quaterétur, inter \
æthéreos aulæ cæléstis sinus divína ei cláritas fulsit."
          :repeat "Beátus homo, cui cæli patébant.")  ; R7

         (:respond "Patefáctæ sunt jánuæ cæli Christi Mártyri beáto \
Stéphano, qui in número Mártyrum invéntus est primus: * Et ídeo \
triúmphat in cælis coronátus."
          :verse "Mortem enim, quam Salvátor noster dignátus est pro nobis \
pati, hanc ille primus réddidit Salvatóri."
          :repeat "Et ídeo triúmphat in cælis coronátus."
          :gloria t)  ; R8
        )))

    ;; ════════════════════════════════════════════════════════════════════
    ;; IN EPIPHANIA DOMINI — Epiphany (Jan 6)
    ;; Psalms: 28/45/46, 65/71/85, 94/95/96
    ;; Invitatory: Christus apparuit nobis (OMITTED on feast day)
    ;; Hymn: Hostis Herodes impie (OMITTED on feast day)
    ;; Note: Ps 94 (Venite) displaced into Nocturn III
    ;; ════════════════════════════════════════════════════════════════════

    (epiphany
     . (:invitatory christus-apparuit-nobis
        :hymn hostis-herodes-impie
        :omit-invitatory t
        :psalms-1 ((afferte-domino-filii-dei . 28)
                   (fluminis-impetus-laetificat . 45)
                   (psallite-deo-nostro-psallite . 46))
        :psalms-2 ((omnis-terra-adoret-te . 65)
                   (reges-tharsis-et-insulae . 71)
                   (omnes-gentes-quascumque . 85))
        :psalms-3 ((venite-adoremus-eum-quia-ipse . 94)
                   (adorate-dominum-alleluia-in-aula . 95)
                   (adorate-deum-alleluia-omnes . 96))
        :versicle-1 ("Omnis terra adóret te, et psallat tibi."
                     "Psalmum dicat nómini tuo, Dómine.")
        :versicle-1-en ("Let all the earth worship thee, and sing unto thee."
                        "Let it sing praises unto thy Name, O Lord.")
        :versicle-2 ("Reges Tharsis et ínsulæ múnera ófferent."
                     "Reges Arabum et Saba dona addúcent.")
        :versicle-2-en ("The kings of Tarshish and of the isles shall \
bring presents."
                        "The kings of Arabia and Saba shall offer gifts.")
        :versicle-3 ("Adoráte Dóminum, allelúja."
                     "In aula sancta ejus, allelúja.")
        :versicle-3-en ("O worship the Lord, alleluia."
                        "In his holy temple, alleluia.")

        :lessons
        (
         ;; ── Nocturn I: Isaiah ──

         (:ref "Isa 55:1-4"
          :source "De Isaía Prophéta"
          :text "\
Omnes sitiéntes, veníte ad aquas, et qui non habétis argéntum, \
properáte, émite, et comédite: veníte, émite absque argénto, et absque \
ulla commutatióne vinum et lac. Quare appénditis argéntum non in \
pánibus, et labórem vestrum non in saturitáte? Audíte audiéntes me, et \
comédite bonum, et delectábitur in crassitúdine ánima vestra. Inclináte \
aurem vestram, et veníte ad me: audíte, et vivet ánima vestra, et \
fériam vobíscum pactum sempitérnum, misericórdias David fidéles. Ecce \
testem pópulis dedi eum, ducem ac præceptórem géntibus.")  ; L1

         (:ref "Isa 60:1-6"
          :text "\
Surge, illumináre, Jerúsalem, quia venit lumen tuum, et glória Dómini \
super te orta est. Quia ecce ténebræ opérient terram, et calígo \
pópulos: super te autem oriétur Dóminus, et glória ejus in te vidébitur. \
Et ambulábunt gentes in lúmine tuo, et reges in splendóre ortus tui. \
Leva in circúitu óculos tuos, et vide: omnes isti congregáti sunt, \
venérunt tibi: fílii tui de longe vénient, et fíliæ tuæ de látere \
surgent. Tunc vidébis, et áfflues, mirábitur et dilatábitur cor tuum, \
quando convérsa fúerit ad te multitúdo maris, fortitúdo géntium vénerit \
tibi. Inundátio camelórum opériet te, dromedárii Mádian et Epha: omnes \
de Saba vénient, aurum et thus deferéntes, et laudem Dómino \
annuntiántes.")  ; L2

         (:ref "Isa 61:10-11; 62:1"
          :text "\
Gaudens gaudébo in Dómino, et exsultábit ánima mea in Deo meo: quia \
índuit me vestiméntis salútis: et induménto justítiæ circúmdedit me, \
quasi sponsum decorátum coróna, et quasi sponsam ornátam monílibus suis. \
Sicut enim terra proférre germen suum, et sicut hortus semen suum \
gérminat: sic Dóminus Deus germinábat justítiam, et laudem coram \
univérsis géntibus. Propter Sion non tacébo, et propter Jerúsalem non \
quiéscam, donec egrediátur ut splendor justus ejus, et salvátor ejus \
ut lampas accendátur.")  ; L3

         ;; ── Nocturn II: St Leo the Great, Sermo 2 de Epiphania ──

         (:ref "Sermo 2 de Epiphania"
          :source "Sermo sancti Leónis Papæ"
          :text "\
Gaudéte in Dómino, dilectíssimi, íterum dico, gaudéte: quóniam brevi \
intervallo témporis post solemnitátem Nativitátis Christi, festívitas \
Manifestatiónis ejus illúxit: et quem in illo die Virgo péperit, in hoc \
mundus agnóvit. Verbum enim caro factum, ita susceptiónis suæ \
temperávit exórdium, ut natus Jesus et credéntibus manifestárétur, et \
persequéntibus lateéret. Jam tunc ergo cæli enarravérunt glóriam Dei, \
et in omnem terram sonus veritátis exívit: quando et pastóribus \
exércitus Angelórum Salvatóris ortum annúntians appáruit: et Magos ad \
eum adorándum prǽvia stella perdúxit: ut a solis ortu usque ad occásum \
veri Regis generátio coruscáret, cum rerum fidem et regna Oriéntis per \
Magos díscerent, et Románum impérium non latéret.")  ; L4

         (:ref "Sermo 2 de Epiphania"
          :text "\
Nam et sævítia Heródis volens primórdia suspécti sibi Regis exstínguere, \
huic dispensatióni nésciens serviébat: ut dum atróci inténtus facínori, \
ignotum sibi púerum indiscreti cædis immanitáte perséquitur, annuntiátum \
cǽlitus Domíni ortum insígnior ubíque fama loquerétur. Quam rem et \
novítas miráculi et diligéntia exquiréntium et Herodíanæ crudelitátis \
notítia pródidérunt. Tunc autem Salvátor et magísterium doctúrus erat \
grátia, et exercéndus pássio, et illustrándus resurrectióne: elegit \
Béthlehem nativitáti, Jerosólymam passióni. Si autem humilitátis suæ \
magníficat prǽcónem, et quæ nondum ejécerat ab ánimo superstitiónem, \
jam hospítio recíperet veritátem.")  ; L5

         (:ref "Sermo 2 de Epiphania"
          :text "\
Agnoscámus ergo, dilectíssimi, in Magis adoratóribus Christi, vocatiónis \
nostræ fideíque primítias: et exsultántibus ánimis beátæ spei inítia \
celebrémus. Ex inde enim in ætérnam hereditátem cœpímus introíre: ex \
inde nobis Christo enarántia Scripturárum arcána patuérunt, et véritas, \
quam Judæórum cǽcitas non récipit, ómnibus natiónibus lumen suum \
intúlit. Colátur ítaque a nobis sacratíssimus dies, in quo salútis \
nostræ auctor appáruit: et quem Magi veneráti sunt in cunábulis, nos \
omnipoténtem adoémus in cælis. Ac sicut illi de thesáuris suis \
mýsticas Dómino munerum spécies obtulérunt, ita et nos de córdibus \
nostris, quæ Deo sunt digna, promámus.")  ; L6

         ;; ── Nocturn III: St Gregory, Homilia 10 on Matt 2:1-12 ──

         (:ref "Matt 2:1-12"
          :source "Homilía sancti Gregórii Papæ, Homilia 10 in Evang."
          :text "\
Sicut in lectióne evangélica, fratres caríssimi, audístis, cæli Rege \
nato, rex terræ turbátus est: quia nimírum terréna altitúdo confúnditur, \
cum celsitúdo cæléstis aperítur. Sed quǽrendum nobis est, quidnam sit, \
quod, Redemptóre nato, pastóres in Judǽa ángeli appárent, et ab \
Oriénte Magos ad adorándum eum non ángelus, sed stella perdúcit. Quia \
vidélicet Judǽis, tamquam ratióne uténtibus, rationále ánimal, id est \
Ángelus, prǽdicáre débuit: gentíles vero, quia uti ratióne nesciébant, \
non per vocem, sed per signa perdúcuntur. Unde et per Paulum dícitur: \
Prophetíæ fidélibus datæ sunt, non infidélibus: signa autem infidélibus, \
non fidélibus: quia et istis signa tamquam infidélibus, non fidélibus \
data sunt.")  ; L7

         (:ref "Matt 2:1-12"
          :text "\
Et notándum, quod Redemptórem nostrum, cum jam perféctæ esset ætátis, \
eísdem gentílibus Apóstoli prǽdicant: ejus autem, cum loqui adhuc per \
seípsum nesciébat, infántiam stella gentílibus innótuit. Quia nimírum \
ratiónis ordo poscébat, ut loquéntem jam Dóminum loquéntes nobis \
nuntiatóres innótescerent: et necdum loquéntem eleménta muta \
prǽdicárent. Sed in ómnibus signis quæ vel nasciénti Dómino, vel \
moriénti sunt exhibíta, considerándum est quanta sit duritia in \
córdibus Judæórum: qui hunc nec per prophetíæ donum, nec per mirácula \
agnovérunt.")  ; L8

         (:ref "Matt 2:1-12"
          :text "\
Omnia quippe eleménta auctórem suum venísse testáta sunt. Ut enim de eis \
áliquid more hóminum dicam: Deum hunc cæli esse cognovérunt, quia \
stellam míserunt. Mare cognóvit, quia sub plantis se calcábile \
prǽbuit. Terra cognóvit, quia eo moriénte contrémuit. Sol cognóvit, \
quia lucis suæ rádios abscóndit. Saxa et paríetes cognovérunt, quia \
témpore mortis ejus scissa sunt. Inférnus cognóvit, quia eos quos \
tenébat mórtuos réddidit. Et tamen hunc, quem Dóminum ómnia insensibília \
eleménta sensérunt, adhuc infidélium Judæórum corda non agnóscunt: et \
durióra saxis, scindi ad pœniténdum nolunt.")  ; L9
        )

        :responsories
        (
         (:respond "Hódie in Jordáne baptizáto Dómino apérti sunt cæli, et \
sicut colúmba super eum Spíritus mansit, et vox Patris intónuit: * Hic \
est Fílius meus diléctus, in quo mihi bene complácui."
          :verse "Descéndit Spíritus Sanctus corporáli spécie sicut colúmba \
in ipsum, et vox de cælo facta est."
          :repeat "Hic est Fílius meus diléctus, in quo mihi bene \
complácui.")  ; R1

         (:respond "In colúmbæ spécie Spíritus Sanctus visus est, Patérna \
vox audíta est: * Hic est Fílius meus diléctus, in quo mihi bene \
complácui."
          :verse "Cæli apérti sunt super eum, et vox Patris intónuit."
          :repeat "Hic est Fílius meus diléctus, in quo mihi bene \
complácui.")  ; R2

         (:respond "Reges Tharsis et ínsulæ múnera ófferent: * Reges Arabum \
et Saba dona Dómino Deo addúcent."
          :verse "Omnes de Saba vénient, aurum et thus deferéntes."
          :repeat "Reges Arabum et Saba dona Dómino Deo addúcent."
          :gloria t)  ; R3

         (:respond "Illumináre, illumináre Jerúsalem, quia venit lux tua: \
* Et glória Dómini super te orta est."
          :verse "Et ambulábunt gentes in lúmine tuo, et reges in splendóre \
ortus tui."
          :repeat "Et glória Dómini super te orta est.")  ; R4

         (:respond "Omnes de Saba vénient, aurum et thus deferéntes, et \
laudem Dómino annuntiántes, * Allelúja, allelúja, allelúja."
          :verse "Reges Tharsis et ínsulæ múnera ófferent, reges Arabum et \
Saba dona addúcent."
          :repeat "Allelúja, allelúja, allelúja.")  ; R5

         (:respond "Magi véniunt ab Oriénte Jerosólymam, quæréntes, et \
dicéntes: Ubi est qui natus est, cujus stellam vídimus? * Et vénimus \
adoráre Dóminum."
          :verse "Vídimus stellam ejus in Oriénte."
          :repeat "Et vénimus adoráre Dóminum."
          :gloria t)  ; R6

         (:respond "Stella, quam víderant Magi in Oriénte, antecedébat eos, \
donec venírent ad locum, ubi puer erat. * Vidéntes autem eam, gavísi \
sunt gáudio magno."
          :verse "Et intrántes domum, invenérunt púerum cum María matre \
ejus, et procidéntes adoravérunt eum."
          :repeat "Vidéntes autem eam, gavísi sunt gáudio magno.")  ; R7

         ;; R8 — triple-cue structure: two *-sections
         (:respond "Vidéntes stellam Magi, gavísi sunt gáudio magno: * Et \
intrántes domum invenérunt púerum cum María matre ejus, et procidéntes \
adoravérunt eum: * Et apértis thesáuris suis obtulérunt ei múnera, \
aurum, thus, et myrrham."
          :verse "Stella, quam víderant Magi in Oriénte, antecedébat eos, \
usque dum véniens staret supra ubi erat puer."
          :repeat "Et apértis thesáuris suis obtulérunt ei múnera, aurum, \
thus, et myrrham."
          :gloria t)  ; R8
        )))
  )
  "Feast-grade Matins data alist.
Each entry: (FEAST-SYMBOL . plist) with :invitatory, :hymn, :psalms-1/2/3,
:versicle-1/2/3, :lessons (9), :responsories (8).
Feasts: christmas (Dec 25), stephen (Dec 26), epiphany (Jan 6).")

(defun bcp-roman-season-christmas-feast-matins (feast)
  "Return feast-grade Matins data for FEAST symbol.
FEAST is one of `christmas', `stephen', `epiphany'.
Returns a plist with :invitatory, :hymn, :psalms-1/2/3, :versicle-1/2/3,
:lessons (9), :responsories (8), or nil."
  (cdr (assq feast bcp-roman-season-christmas--feast-matins)))

(provide 'bcp-roman-season-christmas)

;;; bcp-roman-season-christmas.el ends here
