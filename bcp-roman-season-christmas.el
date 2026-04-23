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

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Christmastide ferial Matins data
;;
;; Two data sets:
;;   1. Fixed-date period: Dec 29-31, Jan 2-12 — keyed by (MONTH . DAY)
;;   2. Post-Epiphany weeks: Epi1-6 weekdays — keyed by (WEEK . DOW)
;;
;; Excludes feast days: Dec 25-28 (Christmas/Stephen/John/Innocents),
;; Jan 1 (Circumcision), Jan 6 (Epiphany).
;;
;; Each entry: ((KEY) . (:lessons (L1 L2 L3) :responsories (R1 R2 R3)))
;; Lessons: (:source SRC :ref REF :text TEXT) — some keys omitted when absent.
;; Responsories: (:respond R :verse V :repeat REP :gloria BOOL)

(defconst bcp-roman-season-christmas--ferial-matins-fixed
  '(
    ;; Nat29: Diei V infra Octavam Nativitatis
    ((12 . 29) . (:lessons
              ((:source "Incipit Epístola beáti Pauli Apóstoli ad Romános"
               :ref "Rom 1:1-7"
               :text "1 Paulus, servus Jesu Christi, vocátus Apóstolus, segregátus in Evangélium Dei,
2 quod ante promíserat per prophétas suos in Scriptúris sanctis
3 de Fílio suo, qui factus est ei ex sémine David secúndum carnem,
4 qui prædestinátus est Fílius Dei in virtúte secúndum spíritum sanctificatiónis ex resurrectióne mortuórum Jesu Christi Dómini nostri:
5 per quem accépimus grátiam, et apostolátum ad obediéndum fídei in ómnibus géntibus pro nómine ejus,
6 in quibus estis et vos vocáti Jesu Christi:
7 ómnibus qui sunt Romæ, diléctis Dei, vocátis sanctis. Grátia vobis, et pax a Deo Patre nostro, et Dómino Jesu Christo.")
               (:ref "Rom 1:8-12"
               :text "8 Primum quidem grátias ago Deo meo per Jesum Christum pro ómnibus vobis: quia fides vestra annuntiátur in univérso mundo.
9 Testis enim mihi est Deus, cui sérvio in spíritu meo in Evangélio Fílii ejus, quod sine intermissióne memóriam vestri fácio
10 semper in oratiónibus meis: óbsecrans, si quómodo tandem aliquándo prósperum iter hábeam in voluntáte Dei veniéndi ad vos.
11 Desídero enim vidére vos, ut áliquid impértiar vobis grátiæ spirituális ad confirmándos vos:
12 id est, simul consolári in vobis per eam quæ ínvicem est, fidem vestram atque meam.")
               (:ref "Rom 1:13-19"
               :text "13 Nolo autem vos ignoráre fratres: quia sæpe propósui veníre ad vos (et prohíbitus sum usque adhuc) ut áliquem fructum hábeam et in vobis, sicut et in céteris géntibus.
14 Græcis ac bárbaris, sapiéntibus, et insipiéntibus débitor sum:
15 ita (quod in me) promptum est et vobis, qui Romæ estis, evangelizáre.
16 Non enim erubésco Evangélium. Virtus enim Dei est in salútem omni credénti, Judǽo primum, et Græco.
17 Justítia enim Dei in eo revelátur ex fide in fidem: sicut scriptum est: Justus autem ex fide vivit.
18 Revelátur enim ira Dei de cælo super omnem impietátem, et injustítiam hóminum eórum, qui veritátem Dei in injustítia détinent:
19 quia quod notum est Dei, maniféstum est in illis. Deus enim illis manifestávit."))
              :responsories
              ((:respond "Hódie nobis de cælo pax vera descéndit:"
                  :verse "Hódie illúxit nobis dies redemptiónis novæ, reparatiónis antíquæ, felicitátis ætérnæ."
                  :repeat "Hódie per totum mundum mellíflui facti sunt cæli."
                  :gloria nil)
               (:respond "Quem vidístis, pastóres? dícite, annuntiáte nobis, in terris quis appáruit?"
                  :verse "Dícite, quidnam vidístis? et annuntiáte Christi nativitátem."
                  :repeat "Natum vídimus, et choros Angelórum collaudántes Dóminum."
                  :gloria t)
               (:respond "O magnum mystérium, et admirábile sacraméntum, ut animália vidérent Dóminum natum, jacéntem in præsépio:"
                  :verse "Ave, María, grátia plena: Dóminus tecum."
                  :repeat "Beáta Virgo, cujus víscera meruérunt portáre Dóminum Christum."
                  :gloria nil))))

    ;; Nat30: Diei VI infra Octavam Nativitatis
    ((12 . 30) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 2:1-4"
               :text "1 Propter quod inexcusábilis es, o homo omnis qui júdicas. In quo enim júdicas álterum, teípsum condémnas: éadem enim agis quæ júdicas.
2 Scimus enim quóniam judícium Dei est secúndum veritátem in eos qui tália agunt.
3 Exístimas autem hoc, o homo, qui júdicas eos qui tália agunt, et facis ea, quia tu effúgies judícium Dei?
4 an divítias bonitátis ejus, et patiéntiæ, et longanimitátis contémnis? Ignóras quóniam benígnitas Dei ad pœniténtiam te addúcit?")
               (:ref "Rom 2:5-8"
               :text "5 Secúndum autem durítiam tuam, et impǽnitens cor, thesaurízas tibi iram in die iræ, et revelatiónis justi judícii Dei,
6 qui reddet unicuíque secúndum ópera ejus:
7 iis quidem qui secúndum patiéntiam boni óperis, glóriam, et honórem, et incorruptiónem quærunt, vitam ætérnam:
8 iis autem qui sunt ex contentióne, et qui non acquiéscunt veritáti, credunt autem iniquitáti, ira et indignátio.")
               (:ref "Rom 2:9-13"
               :text "9 Tribulátio et angústia in omnem ánimam hóminis operántis malum, Judǽi primum, et Græci:
10 glória autem, et honor, et pax omni operánti bonum, Judǽo primum, et Græco:
11 non enim est accéptio personárum apud Deum.
12 Quicúmque enim sine lege peccavérunt, sine lege períbunt: et quicúmque in lege peccavérunt, per legem judicabúntur.
13 Non enim auditóres legis justi sunt apud Deum, sed factóres legis justificabúntur."))
              :responsories
              ((:respond "Hódie nobis de cælo pax vera descéndit:"
                  :verse "Hódie illúxit nobis dies redemptiónis novæ, reparatiónis antíquæ, felicitátis ætérnæ."
                  :repeat "Hódie per totum mundum mellíflui facti sunt cæli."
                  :gloria nil)
               (:respond "Quem vidístis, pastóres? dícite, annuntiáte nobis, in terris quis appáruit?"
                  :verse "Dícite, quidnam vidístis? et annuntiáte Christi nativitátem."
                  :repeat "Natum vídimus, et choros Angelórum collaudántes Dóminum."
                  :gloria t)
               (:respond "O magnum mystérium, et admirábile sacraméntum, ut animália vidérent Dóminum natum, jacéntem in præsépio:"
                  :verse "Ave, María, grátia plena: Dóminus tecum."
                  :repeat "Beáta Virgo, cujus víscera meruérunt portáre Dóminum Christum."
                  :gloria nil))))

    ;; Nat31: Diei VII infra Octavam Nativitatis
    ((12 . 31) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 3:19-22"
               :text "19 Scimus autem quóniam quæcúmque lex lóquitur, iis, qui in lege sunt, lóquitur: ut omne os obstruátur, et súbditus fiat omnis mundus Deo:
20 quia ex opéribus legis non justificábitur omnis caro coram illo. Per legem enim cognítio peccáti.
21 Nunc autem sine lege justítia Dei manifestáta est: testificáta a lege et prophétis.
22 Justítia autem Dei per fidem Jesu Christi in omnes, et super omnes, qui credunt in eum: non enim est distínctio.")
               (:ref "Rom 3:23-26"
               :text "23 Omnes enim peccavérunt et egent glória Dei.
24 Justificáti gratis per grátiam ipsíus, per redemptiónem, quæ est in Christo Jesu,
25 quem propósuit Deus propitiatiónem per fidem in sánguine ipsíus, ad ostensiónem justítiæ suæ propter remissiónem præcedéntium delictórum
26 in sustentatióne Dei, ad ostensiónem justítiæ ejus in hoc témpore: ut sit ipse justus, et justíficans eum, qui est ex fide Jesu Christi.")
               (:ref "Rom 3:27-31"
               :text "27 Ubi est ergo gloriátio tua? Exclúsa est. Per quam legem? Factórum? Non: sed per legem fídei.
28 Arbitrámur enim justificári hóminem per fidem sine opéribus legis.
29 An Judæórum Deus tantum? nonne et géntium? Immo et géntium:
30 quóniam quidem unus est Deus, qui justíficat circumcisiónem ex fide, et præpútium per fidem.
31 Legem ergo destrúimus per fidem? Absit: sed legem statúimus."))
              :responsories
              ((:respond "Hódie nobis de cælo pax vera descéndit:"
                  :verse "Hódie illúxit nobis dies redemptiónis novæ, reparatiónis antíquæ, felicitátis ætérnæ."
                  :repeat "Hódie per totum mundum mellíflui facti sunt cæli."
                  :gloria nil)
               (:respond "Quem vidístis, pastóres? dícite, annuntiáte nobis, in terris quis appáruit?"
                  :verse "Dícite, quidnam vidístis? et annuntiáte Christi nativitátem."
                  :repeat "Natum vídimus, et choros Angelórum collaudántes Dóminum."
                  :gloria t)
               (:respond "O magnum mystérium, et admirábile sacraméntum, ut animália vidérent Dóminum natum, jacéntem in præsépio:"
                  :verse "Ave, María, grátia plena: Dóminus tecum."
                  :repeat "Beáta Virgo, cujus víscera meruérunt portáre Dóminum Christum."
                  :gloria nil))))

    ;; Nat02: Ad Romános, cap. 5
    ((1 . 2) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 5:1-5"
               :text "1 Justificáti ergo ex fide, pacem habeámus ad Deum per Dóminum nostrum Jesum Christum:
2 per quem et habémus accéssum per fidem in grátiam istam, in qua stamus, et gloriámur in spe glóriæ filiórum Dei.
3 Non solum autem, sed et gloriámur in tribulatiónibus: sciéntes quod tribulátio patiéntiam operátur:
4 patiéntia autem probatiónem, probátio vero spem:
5 spes autem non confúndit: quia cáritas Dei diffúsa est in córdibus nostris per Spíritum Sanctum, qui datus est nobis.")
               (:ref "Rom 5:6-9"
               :text "6 Ut quid enim Christus, cum adhuc infírmi essémus, secúndum tempus, pro ímpiis mórtuus est?
7 Vix enim pro justo quis móritur: nam pro bono fórsitan quis áudeat mori.
8 Comméndat autem caritátem suam Deus in nobis: quóniam cum adhuc peccatóres essémus, secúndum tempus,
9 Christus pro nobis mórtuus est: multo ígitur magis nunc justificáti in sánguine ipsíus, salvi érimus ab ira per ipsum.")
               (:ref "Rom 5:10-12"
               :text "10 Si enim cum inimíci essémus, reconciliáti sumus Deo per mortem Fílii ejus: multo magis reconciliáti, salvi érimus in vita ipsíus.
11 Non solum autem: sed et gloriámur in Deo per Dóminum nostrum Jesum Christum, per quem nunc reconciliatiónem accépimus.
12 Proptérea sicut per unum hóminem peccátum in hunc mundum intrávit, et per peccátum mors, et ita in omnes hómines mors pertránsiit, in quo omnes peccavérunt."))
              :responsories
              ((:respond "Ecce Agnus Dei, ecce qui tollit peccáta mundi: ecce de quo dicébam vobis: Qui post me venit, ante me factus est:"
                  :verse "Qui de terra est, de terra lóquitur: qui de cælo venit, super omnes est."
                  :repeat "Cujus non sum dignus corrígiam calceaménti sólvere."
                  :gloria nil)
               (:respond "Dies sanctificátus illúxit nobis: veníte, gentes, et adoráte Dóminum:"
                  :verse "Hæc dies quam fecit Dóminus, exsultémus et lætémur in ea."
                  :repeat "Quia hódie descéndit lux magna in terris."
                  :gloria nil)
               (:respond "Benedíctus qui venit in nómine Dómini, Deus Dóminus, et illúxit nobis:"
                  :verse "Hæc dies quam fecit Dóminus, exsultémus et lætémur in ea."
                  :repeat "Allelúja, allelúja."
                  :gloria t))))

    ;; Nat03: Ad Romános, cap. 6
    ((1 . 3) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 6:1-5"
               :text "1 Quid ergo dicémus? permanébimus in peccáto ut grátia abúndet?
2 Absit. Qui enim mórtui sumus peccáto, quómodo adhuc vivémus in illo?
3 an ignorátis quia quicúmque baptizáti sumus in Christo Jesu, in morte ipsíus baptizáti sumus?
4 Consepúlti enim sumus cum illo per baptísmum in mortem: ut quómodo Christus surréxit a mórtuis per glóriam Patris, ita et nos in novitáte vitæ ambulémus.
5 Si enim complantáti facti sumus similitúdini mortis ejus: simul et resurrectiónis érimus.")
               (:ref "Rom 6:6-11"
               :text "6 Hoc sciéntes, quia vetus homo noster simul crucifíxus est, ut destruátur corpus peccáti, et ultra non serviámus peccáto.
7 Qui enim mórtuus est, justificátus est a peccáto.
8 Si autem mórtui sumus cum Christo, crédimus quia simul étiam vivémus cum Christo,
9 sciéntes quod Christus resúrgens ex mórtuis jam non móritur: mors illi ultra non dominábitur.
10 Quod enim mórtuus est peccáto, mórtuus est semel: quod autem vivit, vivit Deo.
11 Ita et vos existimáte vos mórtuos quidem esse peccáto, vivéntes autem Deo, in Christo Jesu Dómino nostro.")
               (:ref "Rom 6:12-18"
               :text "12 Non ergo regnet peccátum in vestro mortáli córpore ut obediátis concupiscéntiis ejus.
13 Sed neque exhibeátis membra vestra arma iniquitátis peccáto: sed exhibéte vos Deo, tamquam ex mórtuis vivéntes: et membra vestra arma justítiæ Deo.
14 Peccátum enim vobis non dominábitur: non enim sub lege estis, sed sub grátia.
15 Quid ergo? peccábimus, quóniam non sumus sub lege, sed sub grátia? Absit.
16 Nescítis quóniam cui exhibétis vos servos ad obediéndum, servi estis ejus, cui obedítis, sive peccáti ad mortem, sive obeditiónis ad justítiam?
17 Grátias autem Deo quod fuístis servi peccáti, obedístis autem ex corde in eam formam doctrínæ, in quam tráditi estis.
18 Liberáti autem a peccáto, servi facti estis justítiæ."))
              :responsories
              ((:respond "Congratulámini mihi, omnes qui dilígitis Dóminum:"
                  :verse "Beátam me dicent omnes generatiónes, quia ancíllam húmilem respéxit Deus."
                  :repeat "Quia, cum essem párvula, plácui Altíssimo, et de meis viscéribus génui Deum et hóminem."
                  :gloria nil)
               (:respond "Confirmátum est cor Vírginis, in quo divína mystéria, Angelo nuntiánte, concépit: tunc speciósum forma præ fíliis hóminum castis suscépit viscéribus:"
                  :verse "Domus pudíci péctoris templum repénte fit Dei: intácta nésciens virum, verbo concépit Fílium."
                  :repeat "Et benedícta in ætérnum, Deum nobis prótulit et hóminem."
                  :gloria nil)
               (:respond "Benedícta et venerábilis es, Virgo María, quæ sine tactu pudóris invénta es mater Salvatóris:"
                  :verse "Dómine, audívi audítum tuum, et tímui: considerávi ópera tua, et expávi: in médio duórum animálium."
                  :repeat "Jacébat in præsépio, et fulgébat in cælo."
                  :gloria t))))

    ;; Nat04: Ad Romános, cap. 7
    ((1 . 4) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 7:1-3"
               :text "1 An ignorátis, fratres, (sciéntibus enim legem loquor) quia lex in hómine dominátur, quanto témpore vivit?
2 Nam quæ sub viro est múlier, vivénte viro, alligáta est legi: si autem mórtuus fúerit vir ejus, solúta est a lege viri.
3 Igitur, vivénte viro, vocábitur adúltera si fúerit cum álio viro: si autem mórtuus fúerit vir ejus, liberáta est a lege viri, ut non sit adúltera si fúerit cum álio viro.")
               (:ref "Rom 7:4-6"
               :text "4 Itaque, fratres mei, et vos mortificáti estis legi per corpus Christi: ut sitis altérius, qui ex mórtuis resurréxit, ut fructificémus Deo.
5 Cum enim essémus in carne, passiónes peccatórum, quæ per legem erant, operabántur in membris nostris, ut fructificárent morti.
6 Nunc autem solúti sumus a lege mortis, in qua detinebámur, ita ut serviámus in novitáte spíritus, et non in vetustáte lítteræ.")
               (:ref "Rom 7:7-9"
               :text "7 Quid ergo dicémus? lex peccátum est? Absit. Sed peccátum non cognóvi, nisi per legem: nam concupiscéntiam nesciébam, nisi lex díceret: Non concupísces.
8 Occasióne autem accépta, peccátum per mandátum operátum est in me omnem concupiscéntiam. Sine lege enim peccátum mórtuum erat.
9 Ego autem vivébam sine lege aliquándo. Sed cum venísset mandátum, peccátum revíxit."))
              :responsories
              ((:respond "Sancta et immaculáta virgínitas, quibus te láudibus éfferam, néscio:"
                  :verse "Benedícta tu in muliéribus, et benedíctus fructus ventris tui."
                  :repeat "Quia quem cæli cápere non póterant, tuo grémio contulísti."
                  :gloria t)
               (:respond "Nésciens Mater Virgo virum, péperit sine dolóre:"
                  :verse "Domus pudíci péctoris templum repénte fit Dei: intácta nésciens virum, verbo concépit Fílium."
                  :repeat "Salvatórem sæculórum, ipsum Regem Angelórum, sola Virgo lactábat úbere de cælo pleno."
                  :gloria t)
               (:respond "Benedíctus qui venit in nómine Dómini, Deus Dóminus, et illúxit nobis:"
                  :verse "Hæc dies quam fecit Dóminus, exsultémus et lætémur in ea."
                  :repeat "Allelúja, allelúja."
                  :gloria t))))

    ;; Nat05: Ad Romános, cap. 8
    ((1 . 5) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 8:1-4"
               :text "1 Nihil ergo nunc damnatiónis est iis, qui sunt in Christo Jesu, qui non secúndum carnem ámbulant.
2 Lex enim spíritus vitæ in Christo Jesu liberávit me a lege peccáti et mortis.
3 Nam quod impossíbile erat legi, in quo infirmabátur per carnem: Deus Fílium suum mittens in similitúdinem carnis peccáti, et de peccáto damnávit peccátum in carne,
4 ut justificátio legis implerétur in nobis, qui non secúndum carnem ambulámus, sed secúndum spíritum.")
               (:ref "Rom 8:5-9"
               :text "5 Qui enim secúndum carnem sunt: quæ carnis sunt, sápiunt. Qui vero secúndum spíritum sunt, quæ sunt spíritus, séntiunt.
6 Nam prudéntia carnis, mors est: prudéntia autem spíritus, vita et pax.
7 Quóniam sapiéntia carnis inimíca est Deo: legi enim Dei non est subjécta: nec enim potest.
8 Qui autem in carne sunt, Deo placére non possunt.
9 Vos autem in carne non estis, sed in spíritu: si tamen Spíritus Dei hábitat in vobis.")
               (:ref "Rom 8:9-11"
               :text "9 Si quis autem Spíritum Christi non habet: hic non est ejus.
10 Si autem Christus in vobis est: corpus quidem mórtuum est propter peccátum, spíritus vero vivit propter justificatiónem.
11 Quod si Spíritus ejus, qui suscitávit Jesum a mórtuis, hábitat in vobis: qui suscitávit Jesum Christum a mórtuis, vivificábit, et mortália córpora vestra, propter inhabitántem Spíritum ejus in vobis."))
              :responsories
              ((:respond "Ecce Agnus Dei, ecce qui tollit peccáta mundi: ecce de quo dicébam vobis: Qui post me venit, ante me factus est:"
                  :verse "Qui de terra est, de terra lóquitur: qui de cælo venit, super omnes est."
                  :repeat "Cujus non sum dignus corrígiam calceaménti sólvere."
                  :gloria nil)
               (:respond "Dies sanctificátus illúxit nobis: veníte, gentes, et adoráte Dóminum:"
                  :verse "Hæc dies quam fecit Dóminus, exsultémus et lætémur in ea."
                  :repeat "Quia hódie descéndit lux magna in terris."
                  :gloria nil)
               (:respond "Benedíctus qui venit in nómine Dómini, Deus Dóminus, et illúxit nobis:"
                  :verse "Hæc dies quam fecit Dóminus, exsultémus et lætémur in ea."
                  :repeat "Allelúja, allelúja."
                  :gloria t))))

    ;; Nat07: Ad Romános, cap. 9
    ((1 . 7) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 9:1-5"
               :text "1 Veritátem dico in Christo, non méntior: testimónium mihi perhibénte consciéntia mea in Spíritu Sancto:
2 quóniam tristítia mihi magna est, et contínuus dolor cordi meo.
3 Optábam enim ego ipse anáthema esse a Christo pro frátribus meis, qui sunt cognáti mei secúndum carnem,
4 qui sunt Israëlítæ, quorum adóptio est filiórum, et glória, et testaméntum, et legislátio, et obséquium, et promíssa:
5 quorum patres, et ex quibus est Christus secúndum carnem, qui est super ómnia Deus benedíctus in sǽcula. Amen.")
               (:ref "Rom 9:6-10"
               :text "6 Non autem quod excíderit verbum Dei. Non enim omnes qui ex Israël sunt, ii sunt Israëlítæ:
7 neque qui semen sunt Abrahæ, omnes fílii: sed in Isaac vocábitur tibi semen:
8 id est, non qui fílii carnis, hi fílii Dei: sed qui fílii sunt promissiónis, æstimántur in sémine.
9 Promissiónis enim verbum hoc est: Secúndum hoc tempus véniam: et erit Saræ fílius.
10 Non solum autem illa: sed et Rebécca ex uno concúbitu habens, Isaac patris nostri.")
               (:ref "Rom 9:11-16"
               :text "11 Cum enim nondum nati fuíssent, aut áliquid boni egíssent, aut mali, (ut secúndum electiónem propósitum Dei manéret),
12 non ex opéribus, sed ex vocánte dictum est ei: Quia major sérviet minóri,
13 sicut scriptum est: Jacob diléxi, Esau autem ódio hábui.
14 Quid ergo dicémus? numquid iníquitas apud Deum? Absit.
15 Móysi enim dicit: Miserébor cujus miséreor: et misericórdiam præstábo cujus miserébor.
16 Igitur non voléntis, neque curréntis, sed miseréntis est Dei."))
              :responsories
              ((:respond "Tria sunt múnera pretiósa, quæ obtulérunt Magi Dómino in die ista, et habent in se divína mystéria:"
                  :verse "Salútis nostræ auctórem Magi veneráti sunt in cunábulis, et de thesáuris suis mýsticas ei múnerum spécies obtulérunt."
                  :repeat "In auro, ut ostendátur Regis poténtia: in thure, Sacerdótem magnum consídera: et in myrrha, Domínicam sepultúram."
                  :gloria nil)
               (:respond "In colúmbæ spécie Spíritus Sanctus visus est, Patérna vox audíta est:"
                  :verse "Cæli apérti sunt super eum, et vox Patris intónuit."
                  :repeat "Hic est Fílius meus diléctus, in quo mihi bene complácui."
                  :gloria nil)
               (:respond "Reges Tharsis et ínsulæ múnera ófferent:"
                  :verse "Omnes de Saba vénient, aurum et thus deferéntes."
                  :repeat "Reges Arabum et Saba dona Dómino Deo addúcent."
                  :gloria t))))

    ;; Nat08: Ad Romános, cap. 12
    ((1 . 8) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 12:1-3"
               :text "1 Obsecro ítaque vos, fratres, per misericórdiam Dei, ut exhibeátis córpora vestra hóstiam vivéntem, sanctam, Deo placéntem, rationábile obséquium vestrum.
2 Et nolíte conformári huic sǽculo, sed reformámini in novitáte sensus vestri: ut probétis quæ sit volúntas Dei bona, et benéplacens, et perfécta.
3 Dico enim per grátiam quæ data est mihi, ómnibus qui sunt inter vos: Non plus sápere quam opórtet sápere, sed sápere ad sobrietátem: et unicuíque sicut Deus divísit mensúram fídei.")
               (:ref "Rom 12:4-8"
               :text "4 Sicut enim in uno córpore multa membra habémus, ómnia autem membra non eúndem actum habent:
5 ita multi unum corpus sumus in Christo, sínguli autem alter altérius membra.
6 Habéntes autem donatiónes secúndum grátiam, quæ data est nobis, differéntes: sive prophetíam secúndum ratiónem fídei,
7 sive ministérium in ministrándo, sive qui docet in doctrína,
8 qui exhortátur in exhortándo, qui tríbuit in simplicitáte, qui præest in sollicitúdine, qui miserétur in hilaritáte.")
               (:ref "Rom 12:9-16"
               :text "9 Diléctio sine simulatióne. Odiéntes malum, adhæréntes bono:
10 Caritáte fraternitátis ínvicem diligéntes: Honóre ínvicem præveniéntes:
11 Sollicitúdine non pigri: Spíritu fervéntes: Dómino serviéntes:
12 Spe gaudéntes: In tribulatióne patiéntes: Oratióni instántes:
13 Necessitátibus sanctórum communicántes: Hospitalitátem sectántes.
14 Benedícite persequéntibus vos: benedícite, et nolíte maledícere.
15 Gaudére cum gaudéntibus, flere cum fléntibus:
16 Idípsum ínvicem sentiéntes: Non alta sapiéntes, sed humílibus consentiéntes."))
              :responsories
              ((:respond "Tria sunt múnera pretiósa, quæ obtulérunt Magi Dómino in die ista, et habent in se divína mystéria:"
                  :verse "Salútis nostræ auctórem Magi veneráti sunt in cunábulis, et de thesáuris suis mýsticas ei múnerum spécies obtulérunt."
                  :repeat "In auro, ut ostendátur Regis poténtia: in thure, Sacerdótem magnum consídera: et in myrrha, Domínicam sepultúram."
                  :gloria nil)
               (:respond "In colúmbæ spécie Spíritus Sanctus visus est, Patérna vox audíta est:"
                  :verse "Cæli apérti sunt super eum, et vox Patris intónuit."
                  :repeat "Hic est Fílius meus diléctus, in quo mihi bene complácui."
                  :gloria nil)
               (:respond "Reges Tharsis et ínsulæ múnera ófferent:"
                  :verse "Omnes de Saba vénient, aurum et thus deferéntes."
                  :repeat "Reges Arabum et Saba dona Dómino Deo addúcent."
                  :gloria t))))

    ;; Nat09: Ad Romános, cap. 13
    ((1 . 9) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 13:1-4"
               :text "1 Omnis ánima potestátibus sublimióribus súbdita sit: non est enim potéstas nisi a Deo: quæ autem sunt, a Deo ordinátæ sunt.
2 Itaque qui resístit potestáti, Dei ordinatióni resístit. Qui autem resístunt, ipsi sibi damnatiónem acquírunt:
3 nam príncipes non sunt timóri boni óperis, sed mali. Vis autem non timére potestátem? Bonum fac: et habébis laudem ex illa;
4 Dei enim miníster est tibi in bonum.")
               (:ref "Rom 13:4-7"
               :text "4 Si autem malum féceris, time: non enim sine causa gládium portat. Dei enim miníster est: vindex in iram ei, qui malum agit.
5 Ideo necessitáte súbditi estóte non solum propter iram, sed étiam propter consciéntiam.
6 Ideo enim et tribúta præstátis: minístri enim Dei sunt, in hoc ipsum serviéntes.
7 Réddite ómnibus débita: cui tribútum, tribútum: cui vectígal, vectígal: cui timórem, timórem: cui honórem, honórem.")
               (:ref "Rom 13:8-10"
               :text "8 Némini quidquam debeátis, nisi ut ínvicem diligátis: qui enim díligit próximum, legem implévit.
9 Nam, Non adulterábis, Non occídes, Non furáberis, Non falsum testimónium dices, Non concupísces: et si quod est áliud mandátum, in hoc verbo instaurátur: Díliges próximum tuum sicut teípsum.
10 Diléctio próximi malum non operátur. Plenitúdo ergo legis est diléctio."))
              :responsories
              ((:respond "Tria sunt múnera pretiósa, quæ obtulérunt Magi Dómino in die ista, et habent in se divína mystéria:"
                  :verse "Salútis nostræ auctórem Magi veneráti sunt in cunábulis, et de thesáuris suis mýsticas ei múnerum spécies obtulérunt."
                  :repeat "In auro, ut ostendátur Regis poténtia: in thure, Sacerdótem magnum consídera: et in myrrha, Domínicam sepultúram."
                  :gloria nil)
               (:respond "In colúmbæ spécie Spíritus Sanctus visus est, Patérna vox audíta est:"
                  :verse "Cæli apérti sunt super eum, et vox Patris intónuit."
                  :repeat "Hic est Fílius meus diléctus, in quo mihi bene complácui."
                  :gloria nil)
               (:respond "Reges Tharsis et ínsulæ múnera ófferent:"
                  :verse "Omnes de Saba vénient, aurum et thus deferéntes."
                  :repeat "Reges Arabum et Saba dona Dómino Deo addúcent."
                  :gloria t))))

    ;; Nat10: Ad Romános, cap. 14
    ((1 . 10) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 14:1-4"
               :text "1 Infírmum autem in fide assúmite, non in disceptatiónibus cogitatiónum.
2 Alius enim credit se manducáre ómnia: qui autem infírmus est, olus mandúcet.
3 Is qui mandúcat, non manducántem non spernat: et qui non mandúcat, manducántem non júdicet: Deus enim illum assúmpsit.
4 Tu quis es, qui júdicas aliénum servum? Dómino suo stat, aut cadit: stabit autem: potens est enim Deus statúere illum.")
               (:ref "Rom 14:5-8"
               :text "5 Nam álius júdicat diem inter diem, álius autem júdicat omnem diem: unusquísque in suo sensu abúndet.
6 Qui sapit diem, Dómino sapit. Et qui mandúcat, Dómino mandúcat: grátias enim agit Deo. Et qui non mandúcat, Dómino non mandúcat, et grátias agit Deo.
7 Nemo enim nostrum sibi vivit, et nemo sibi móritur.
8 Sive enim vívimus, Dómino vívimus: sive mórimur, Dómino mórimur. Sive ergo vívimus, sive mórimur, Dómini sumus.")
               (:ref "Rom 14:9-13"
               :text "9 In hoc enim Christus mórtuus est, et resurréxit: ut et mortuórum et vivórum dominétur.
10 Tu autem, quid júdicas fratrem tuum? aut tu quare spernis fratrem tuum? Omnes enim stábimus ante tribúnal Christi.
11 Scriptum est enim: Vivo ego, dicit Dóminus, quóniam mihi flectétur omne genu: et omnis lingua confitébitur Deo.
12 Itaque unusquísque nostrum pro se ratiónem reddet Deo.
13 Non ergo ámplius ínvicem judicémus."))
              :responsories
              ((:respond "Tria sunt múnera pretiósa, quæ obtulérunt Magi Dómino in die ista, et habent in se divína mystéria:"
                  :verse "Salútis nostræ auctórem Magi veneráti sunt in cunábulis, et de thesáuris suis mýsticas ei múnerum spécies obtulérunt."
                  :repeat "In auro, ut ostendátur Regis poténtia: in thure, Sacerdótem magnum consídera: et in myrrha, Domínicam sepultúram."
                  :gloria nil)
               (:respond "In colúmbæ spécie Spíritus Sanctus visus est, Patérna vox audíta est:"
                  :verse "Cæli apérti sunt super eum, et vox Patris intónuit."
                  :repeat "Hic est Fílius meus diléctus, in quo mihi bene complácui."
                  :gloria nil)
               (:respond "Reges Tharsis et ínsulæ múnera ófferent:"
                  :verse "Omnes de Saba vénient, aurum et thus deferéntes."
                  :repeat "Reges Arabum et Saba dona Dómino Deo addúcent."
                  :gloria t))))

    ;; Nat11: Ad Romános, cap. 15
    ((1 . 11) . (:lessons
              ((:source "De Epístola ad Romános"
               :ref "Rom 15:1-4"
               :text "1 Debémus autem nos firmióres imbecillitátes infirmórum sustinére, et non nobis placére.
2 Unusquísque vestrum próximo suo pláceat in bonum, ad ædificatiónem.
3 Etenim Christus non sibi plácuit, sed sicut scriptum est: Impropéria improperántium tibi cecidérunt super me.
4 Quæcúmque enim scripta sunt, ad nostram doctrínam scripta sunt: ut per patiéntiam et consolatiónem Scripturárum, spem habeámus.")
               (:ref "Rom 15:5-11"
               :text "5 Deus autem patiéntiæ et solátii, det vobis idípsum sápere in altérutrum secúndum Jesum Christum:
6 ut unánimes, uno ore honorificétis Deum, et Patrem Dómini nostri Jesu Christi.
7 Propter quod suscípite ínvicem, sicut et Christus suscépit vos in honórem Dei.
8 Dico enim Christum Jesum minístrum fuísse circumcisiónis propter veritátem Dei, ad confirmándas promissiónes patrum:
9 Gentes autem super misericórdiam honoráre Deum, sicut scriptum est: Proptérea confitébor tibi in géntibus, Dómine, et nómini tuo cantábo.
10 Et íterum dicit: Lætámini, gentes, cum plebe ejus.
11 Et íterum: Laudáte, omnes gentes, Dóminum, et magnificáte eum, omnes pópuli.")
               (:ref "Rom 15:12-16"
               :text "12 Et rursus Isaías ait: Erit radix Jesse, et qui exsúrget régere gentes, in eum gentes sperábunt.
13 Deus autem spei répleat vos omni gáudio et pace in credéndo: ut abundétis in spe, et virtúte Spíritus Sancti.
14 Certus sum autem, fratres mei, et ego ipse de vobis, quóniam et ipsi pleni estis dilectióne, repléti omni sciéntia, ita ut possítis altérutrum monére.
15 Audácius autem scripsi vobis, fratres, ex parte, tamquam in memóriam vos redúcens: propter grátiam, quæ data est mihi a Deo,
16 ut sim miníster Christi Jesu in géntibus: sanctíficans Evangélium Dei, ut fiat oblátio géntium accépta, et sanctificáta in Spíritu Sancto."))
              :responsories
              ((:respond "Tria sunt múnera pretiósa, quæ obtulérunt Magi Dómino in die ista, et habent in se divína mystéria:"
                  :verse "Salútis nostræ auctórem Magi veneráti sunt in cunábulis, et de thesáuris suis mýsticas ei múnerum spécies obtulérunt."
                  :repeat "In auro, ut ostendátur Regis poténtia: in thure, Sacerdótem magnum consídera: et in myrrha, Domínicam sepultúram."
                  :gloria nil)
               (:respond "In colúmbæ spécie Spíritus Sanctus visus est, Patérna vox audíta est:"
                  :verse "Cæli apérti sunt super eum, et vox Patris intónuit."
                  :repeat "Hic est Fílius meus diléctus, in quo mihi bene complácui."
                  :gloria nil)
               (:respond "Reges Tharsis et ínsulæ múnera ófferent:"
                  :verse "Omnes de Saba vénient, aurum et thus deferéntes."
                  :repeat "Reges Arabum et Saba dona Dómino Deo addúcent."
                  :gloria t))))

    ;; Nat12: Ad Romános, cap. 16
    ((1 . 12) . (:lessons
              ((:source "Incipit Epístola prima beáti Pauli Apóstoli ad Corínthios"
               :ref "1 Cor 1:1-3"
               :text "1 Paulus vocátus Apóstolus Jesu Christi per voluntátem Dei, et Sósthenes frater,
2 ecclésiæ Dei, quæ est Corínthi, sanctificátis in Christo Jesu, vocátis sanctis, cum ómnibus qui ínvocant nomen Dómini nostri Jesu Christi, in omni loco ipsórum et nostro.
3 Grátia vobis, et pax a Deo Patre nostro, et Dómino Jesu Christo.")
               (:ref "1 Cor 1:4-9"
               :text "4 Grátias ago Deo meo semper pro vobis in grátia Dei, quæ data est vobis in Christo Jesu:
5 quod in ómnibus dívites facti estis in illo, in omni verbo, et in omni sciéntia.
6 Sicut testimónium Christi confirmátum est in vobis:
7 ita ut nihil vobis desit in ulla grátia, exspectántibus revelatiónem Dómini nostri Jesu Christi,
8 qui et confirmábit vos usque in finem sine crímine, in die advéntus Dómini nostri Jesu Christi.
9 Fidélis Deus: per quem vocáti estis in societátem fílii ejus Jesu Christi Dómini nostri.")
               (:ref "1 Cor 1:10-13"
               :text "10 Obsécro autem vos fratres per nomen Dómini nostri Jesu Christi: ut idípsum dicátis omnes, et non sint in vobis schísmata: sitis autem perfécti in eódem sensu, et in eádem senténtia.
11 Significátum est enim mihi de vobis fratres mei ab iis, qui sunt Chloes, quia contentiónes sunt inter vos.
12 Hoc autem dico, quod unusquísque vestrum dicit: Ego quidem sum Pauli: ego autem Apóllo: ego vero Cephæ: ego autem Christi.
13 Divísus est Christus? numquid Paulus crucifíxus est pro vobis? aut in nómine Pauli baptizáti estis?"))
              :responsories
              ((:respond "Tria sunt múnera pretiósa, quæ obtulérunt Magi Dómino in die ista, et habent in se divína mystéria:"
                  :verse "Salútis nostræ auctórem Magi veneráti sunt in cunábulis, et de thesáuris suis mýsticas ei múnerum spécies obtulérunt."
                  :repeat "In auro, ut ostendátur Regis poténtia: in thure, Sacerdótem magnum consídera: et in myrrha, Domínicam sepultúram."
                  :gloria nil)
               (:respond "In colúmbæ spécie Spíritus Sanctus visus est, Patérna vox audíta est:"
                  :verse "Cæli apérti sunt super eum, et vox Patris intónuit."
                  :repeat "Hic est Fílius meus diléctus, in quo mihi bene complácui."
                  :gloria nil)
               (:respond "Reges Tharsis et ínsulæ múnera ófferent:"
                  :verse "Omnes de Saba vénient, aurum et thus deferéntes."
                  :repeat "Reges Arabum et Saba dona Dómino Deo addúcent."
                  :gloria t))))
    )
  "Christmastide ferial Matins data for fixed dates.
Keyed by (MONTH . DAY): Dec 29-31, Jan 2-12.")

(defconst bcp-roman-season-christmas--ferial-matins-weekly
  '(
    ;; Epi1-1: Feria II infra Hebdomadam I post Epiphaniam
    ((1 . 1) . (:lessons
              ((:source "De Epístola prima ad Corínthios"
               :ref "1 Cor 2:1-5"
               :text "1 Et ego, cum veníssem ad vos, fratres, veni non in sublimitáte sermónis, aut sapiéntiæ, annúntians vobis testimónium Christi.
2 Non enim judicávi me scire áliquid inter vos, nisi Jesum Christum, et hunc crucifíxum.
3 Et ego in infirmitáte, et timóre, et tremóre multo fui apud vos:
4 et sermo meus, et prædicátio mea non in persuasibílibus humánæ sapiéntiæ verbis, sed in ostensióne spíritus et virtútis:
5 ut fides vestra non sit in sapiéntia hóminum, sed in virtúte Dei.")
               (:ref "1 Cor 2:6-9"
               :text "6 Sapiéntiam autem lóquimur inter perféctos: sapiéntiam vero non hujus sǽculi, neque príncipum hujus sǽculi, qui destruúntur:
7 sed lóquimur Dei sapiéntiam in mystério, quæ abscóndita est, quam prædestinávit Deus ante sǽcula in glóriam nostram,
8 quam nemo príncipum hujus sǽculi cognóvit: si enim cognovíssent, nunquam Dóminum glóriæ crucifixíssent.
9 Sed sicut scriptum est: Quod óculus non vidit, nec auris audívit, nec in cor hóminis ascéndit, quæ præparávit Deus iis, qui díligunt illum.")
               (:ref "1 Cor 2:10-13"
               :text "10 Nobis autem revelávit Deus per Spíritum suum: Spíritus enim ómnia scrutátur, étiam profúnda Dei.
11 Quis enim hóminum scit quæ sunt hóminis, nisi spíritus hóminis, qui in ipso est? ita et quæ Dei sunt, nemo cognóvit, nisi Spíritus Dei.
12 Nos autem non spíritum hujus mundi accépimus, sed Spíritum, qui ex Deo est, ut sciámus, quæ a Deo donáta sunt nobis:
13 quæ et lóquimur non in doctis humánæ sapiéntiæ verbis, sed in doctrína Spíritus, spirituálibus spirituália comparántes."))
              :responsories
              ((:respond "Dómine, ne in ira tua árguas me, neque in furóre tuo corrípias me:"
                  :verse "Timor et tremor venérunt super me, et contexérunt me ténebræ."
                  :repeat "Miserére mei, Dómine, quóniam infírmus sum."
                  :gloria nil)
               (:respond "Deus, qui sedes super thronum, et júdicas æquitátem, esto refúgium páuperum in tribulatióne:"
                  :verse "Tibi enim derelíctus est pauper, pupíllo tu eris adjútor."
                  :repeat "Quia tu solus labórem et dolórem consíderas."
                  :gloria nil)
               (:respond "A dextris est mihi Dóminus, ne commóvear:"
                  :verse "Dóminus pars hereditátis meæ, et cálicis mei."
                  :repeat "Propter hoc dilatátum est cor meum, et exsultávit lingua mea."
                  :gloria t))))

    ;; Epi1-2: Feria III infra Hebdomadam I post Epiphaniam
    ((1 . 2) . (:lessons
              ((:source "De Epístola prima ad Corínthios"
               :ref "1 Cor 5:1-5"
               :text "1 Omníno audítur inter vos fornicátio, et talis fornicátio qualis nec inter gentes, ita ut uxórem patris sui áliquis hábeat.
2 Et vos infláti estis: et non magis luctum habuístis, ut tollátur de médio vestrum qui hoc opus fecit.
3 Ego quidem absens córpore, præsens autem spíritu, jam judicávi ut præsens, eum, qui sic operátus est,
4 in nómine Dómini nostri Jesu Christi, congregátis vobis et meo spíritu, cum virtúte Dómini nostri Jesu,
5 trádere hujúsmodi sátanæ in intéritum carnis, ut spíritus salvus sit in die Dómini nostri Jesu Christi.")
               (:ref "1 Cor 5:6-8"
               :text "6 Non est bona gloriátio vestra. Nescítis, quia módicum ferméntum totam massam corrúmpit?
7 Expurgáte vetus ferméntum, ut sitis nova conspérsio, sicut estis ázymi. Etenim Pascha nostrum immolátus est Christus.
8 Itaque epulémur: non in ferménto véteri, neque in ferménto malítiæ, et nequítiæ: sed in ázymis sinceritátis et veritátis.")
               (:ref "1 Cor 5:9-11"
               :text "9 Scripsi vobis in epístola: Ne commisceámini fornicáriis.
10 Non útique fornicáriis hujus mundi, aut aváris, aut rapácibus, aut idólis serviéntibus: alióquin debuerátis de hoc mundo exiísse.
11 Nunc autem scripsi vobis non commiscéri: si is, qui frater nominátur, est fornicátor, aut avárus, aut idólis sérviens, aut malédicus, aut ebriósus, aut rapax: cum hujúsmodi nec cibum súmere."))
              :responsories
              ((:respond "Auribus pércipe, Deus, lácrimas meas: ne síleas a me, remítte mihi:"
                  :verse "Compláceat tibi, ut erípias me: Dómine, ad adjuvándum me festína."
                  :repeat "Quóniam íncola ego sum apud te, et peregrínus."
                  :gloria nil)
               (:respond "Státuit Dóminus supra petram pedes meos, et diréxit gressus meos Deus:"
                  :verse "Exaudívit preces meas: et edúxit me de lacu misériæ."
                  :repeat "Et misit in os meum cánticum novum."
                  :gloria nil)
               (:respond "Ego dixi, Dómine, miserére mei:"
                  :verse "Ab ómnibus iniquitátibus meis éripe me, Dómine."
                  :repeat "Sana ánimam meam, quia peccávi tibi."
                  :gloria t))))

    ;; Epi1-3: Feria IV infra Hebdomadam I post Epiphaniam
    ((1 . 3) . (:lessons
              ((:source "De Epístola prima ad Corínthios"
               :ref "1 Cor 6:1-6"
               :text "1 Audet áliquis vestrum, habens negótium advérsus álterum, judicári apud iníquos, et non apud sanctos?
2 An nescítis quóniam sancti de hoc mundo judicábunt? Et si in vobis judicábitur mundus, indígni estis qui de mínimis judicétis?
3 Nescítis quóniam ángelos judicábimus? quanto magis sæculária?
4 Sæculária ígitur judícia, si habuéritis: contemptíbiles, qui sunt in Ecclésia, illos constitúite ad judicándum.
5 Ad verecúndiam vestram dico. Sic non est inter vos sapiens quisquam, qui possit judicáre inter fratrem suum?
6 Sed frater cum fratre judício conténdit: et hoc apud infidéles?")
               (:ref "1 Cor 6:7-11"
               :text "7 Jam quidem omníno delíctum est in vobis, quod judícia habétis inter vos. Quare non magis injúriam accípitis? quare non magis fraudem patímini?
8 Sed vos injúriam fácitis, et fraudátis: et hoc frátribus.
9 An nescítis quia iníqui regnum Dei non possidébunt? Nolíte erráre: neque fornicárii, neque idólis serviéntes, neque adúlteri,
10 neque molles, neque masculórum concubitóres, neque fures, neque avári, neque ebriósi, neque malédici, neque rapáces, regnum Dei possidébunt.
11 Et hæc quidam fuístis: sed ablúti estis, sed sanctificáti estis, sed justificáti estis in nómine Dómini nostri Jesu Christi, et in Spíritu Dei nostri.")
               (:ref "1 Cor 6:12-18"
               :text "12 Omnia mihi licent, sed non ómnia expédiunt. Omnia mihi licent, sed ego sub nullíus rédigar potestáte.
13 Esca ventri, et venter escis: Deus autem et hunc, et has déstruet: corpus autem non fornicatióni, sed Dómino: et Dóminus córpori.
14 Deus vero et Dóminum suscitávit: et nos suscitábit per virtútem suam.
15 Nescítis quóniam córpora vestra membra sunt Christi? Tollens ergo membra Christi, fáciam membra meretrícis? Absit.
16 An nescítis quóniam qui adhǽret meretríci, unum corpus effícitur? Erunt enim (inquit) duo in carne una.
17 Qui autem adhǽret Dómino, unus spíritus est.
18 Fúgite fornicatiónem."))
              :responsories
              ((:respond "Ne perdíderis me cum iniquitátibus meis:"
                  :verse "Non intres in judícium cum servo tuo, Dómine."
                  :repeat "Neque in finem irátus resérves mala mea."
                  :gloria nil)
               (:respond "Parátum cor meum, Deus, parátum cor meum:"
                  :verse "Exsúrge, glória mea, exsúrge, psaltérium et cíthara, exsúrgam dilúculo."
                  :repeat "Cantábo et psalmum dicam Dómino."
                  :gloria nil)
               (:respond "Adjútor meus, tibi psallam, quia, Deus, suscéptor meus es:"
                  :verse "Lætábor, et exsultábo in te, psallam nómini tuo, Altíssime."
                  :repeat "Deus meus, misericórdia mea."
                  :gloria t))))

    ;; Epi1-4: Feria V infra Hebdomadam I post Epiphaniam
    ((1 . 4) . (:lessons
              ((:source "De Epístola prima ad Corínthios"
               :ref "1 Cor 7:1-4"
               :text "1 De quibus autem scripsístis mihi: Bonum est hómini mulíerem non tángere:
2 propter fornicatiónem autem, unusquísque suam uxórem hábeat, et unaquǽque suum virum hábeat.
3 Uxóri vir débitum reddat: simíliter autem et uxor viro.
4 Múlier sui córporis potestátem non habet, sed vir. Simíliter autem et vir sui córporis potestátem non habet, sed múlier.")
               (:ref "1 Cor 7:5-9"
               :text "5 Nolíte fraudáre ínvicem, nisi forte ex consénsu ad tempus, ut vacétis oratióni: et íterum revertímini in idípsum, ne tentet vos sátanas propter incontinéntiam vestram.
6 Hoc autem dico secúndum indulgéntiam, non secúndum impérium.
7 Volo enim omnes vos esse sicut meípsum: sed unusquísque próprium donum habet ex Deo: álius quidem sic, álius vero sic.
8 Dico autem non nuptis, et víduis: bonum est illis si sic permáneant, sicut et ego.
9 Quod si non se cóntinent, nubant. Mélius est enim núbere, quam uri.")
               (:ref "1 Cor 7:10-14"
               :text "10 Iis autem, qui matrimónio juncti sunt, præcípio non ego, sed Dóminus, uxórem a viro non discédere:
11 quod si discésserit, manére innúptam, aut viro suo reconciliári. Et vir uxórem non dimíttat.
12 Nam céteris ego dico, non Dóminus. Si quis frater uxórem habet infidélem et hæc conséntit habitáre cum illo, non dimíttat illam.
13 Et si qua múlier fidélis habet virum infidélem, et hic conséntit habitáre cum illa, non dimíttat virum:
14 sanctificátus est enim vir infidélis per mulíerem fidélem, et sanctificáta est múlier infidélis per virum fidélem: alióquin fílii vestri immúndi essent, nunc autem sancti sunt."))
              :responsories
              ((:respond "Deus, in te sperávi, Dómine, non confúndar in ætérnum: in justítia tua líbera me,"
                  :verse "Inclína ad me aurem tuam, et salva me."
                  :repeat "Et éripe me."
                  :gloria nil)
               (:respond "Repleátur os meum laude tua, ut hymnum dicam glóriæ tuæ, tota die magnitúdinem tuam: noli me proícere in témpore senectútis:"
                  :verse "Gaudébunt lábia mea cum cantávero tibi."
                  :repeat "Dum defécerit in me virtus mea, ne derelínquas me."
                  :gloria nil)
               (:respond "Gaudébunt lábia mea cum cantávero tibi:"
                  :verse "Sed et lingua mea meditábitur justítiam tuam, tota die laudem tuam."
                  :repeat "Et ánima mea, quam redemísti, Dómine."
                  :gloria t))))

    ;; Epi1-5: Feria VI infra Hebdomadam I post Epiphaniam
    ((1 . 5) . (:lessons
              ((:source "De Epístola prima ad Corínthios"
               :ref "1 Cor 13:1-3"
               :text "1 Si linguis hóminum loquar et Angelórum, caritátem autem non hábeam, factus sum velut æs sonans, aut cýmbalum tínniens.
2 Et si habúero prophetíam, et nóverim mystéria ómnia, et omnem sciéntiam: et si habúero omnem fidem, ita ut montes tránsferam, caritátem autem non habúero, nihil sum.
3 Et si distribúero in cibos páuperum omnes facultátes meas, et si tradídero corpus meum, ita ut árdeam, caritátem autem non habúero, nihil mihi prodest.")
               (:ref "1 Cor 13:4-10"
               :text "4 Cáritas pátiens est, benígna est: cáritas non æmulátur, non agit pérperam, non inflátur,
5 non est ambitiósa, non quærit quæ sua sunt, non irritátur, non cógitat malum,
6 non gaudet super iniquitáte, congáudet autem veritáti:
7 ómnia suffert, ómnia credit, ómnia sperat, ómnia sústinet.
8 Cáritas nunquam éxcidit: sive prophetíæ evacuabúntur, sive linguæ cessábunt, sive sciéntia destruétur.
9 Ex parte enim cognóscimus, et ex parte prophetámus.
10 Cum autem vénerit quod perféctum est, evacuábitur quod ex parte est.")
               (:ref "1 Cor 13:11-13"
               :text "11 Cum essem párvulus, loquébar ut párvulus, sapiébam ut párvulus, cogitábam ut párvulus. Quando autem factus sum vir, evacuávi quæ erant párvuli.
12 Vidémus nunc per spéculum in ænígmate: tunc autem fácie ad fáciem. Nunc cognósco ex parte: tunc autem cognóscam sicut et cógnitus sum.
13 Nunc autem manent fides, spes, cáritas: tria hæc. Major autem horum est cáritas."))
              :responsories
              ((:respond "Confitébor tibi, Dómine Deus, in toto corde meo, et honorificábo nomen tuum in ætérnum:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "Quia misericórdia tua, Dómine, magna est super me."
                  :gloria nil)
               (:respond "Misericórdia tua, Dómine, magna est super me:"
                  :verse "In die tribulatiónis meæ clamávi ad te, quia exaudísti me."
                  :repeat "Et liberásti ánimam meam ex inférno inferióri."
                  :gloria nil)
               (:respond "Factus est mihi Dóminus in refúgium:"
                  :verse "Erípuit me de inimícis meis fortíssimis, et factus est Dóminus protéctor meus."
                  :repeat "Et Deus meus in auxílium spei meæ."
                  :gloria t))))

    ;; Epi1-6: Sabbato infra Hebdomadam I post Epiphaniam
    ((1 . 6) . (:lessons
              ((:source "De Epístola prima ad Corínthios"
               :ref "1 Cor 16:1-4"
               :text "1 De colléctis autem, quæ fiunt in sanctos, sicut ordinávi ecclésiis Galátiæ, ita et vos fácite.
2 Per unam sábbati, unusquísque vestrum apud se sepónat, recóndens quod ei bene placúerit: ut non, cum vénero, tunc colléctæ fiant.
3 Cum autem præsens fúero: quos probavéritis per epístolas, hos mittam perférre grátiam vestram in Jerúsalem.
4 Quod si dignum fúerit, ut et ego eam, mecum ibunt.")
               (:ref "1 Cor 16:5-9"
               :text "5 Véniam autem ad vos, cum Macedóniam pertransíero: nam Macedóniam pertransíbo.
6 Apud vos autem fórsitan manébo, vel étiam hiemábo: ut vos me deducátis, quocúmque íero.
7 Nolo enim vos modo in tránsitu vidére: spero enim me aliquántulum témporis manére apud vos, si Dóminus permíserit.
8 Permanébo autem Ephesi usque ad Pentecósten.
9 Ostium enim mihi apértum est magnum, et évidens: et adversárii multi.")
               (:ref "1 Cor 16:10-14"
               :text "10 Si autem vénerit Timótheus, vidéte ut sine timóre sit apud vos: opus enim Dómini operátur, sicut et ego.
11 Ne quis ergo illum spernat: dedúcite autem illum in pace, ut véniat ad me: exspécto enim illum cum frátribus.
12 De Apóllo autem fratre vobis notum fácio, quóniam multum rogávi eum, ut veníret ad vos cum frátribus: et útique non fuit volúntas, ut nunc veníret: véniet autem, cum ei vácuum fúerit.
13 Vigiláte, state in fide, viríliter ágite, et confortámini.
14 Omnia vestra in caritáte fiant."))
              :responsories
              ((:respond "Misericórdiam et judícium cantábo tibi, Dómine:"
                  :verse "Perambulábam in innocéntia cordis mei, in médio domus meæ."
                  :repeat "Psallam et intéllegam in via immaculáta, quando vénies ad me."
                  :gloria nil)
               (:respond "Dómine, exáudi oratiónem meam, et clamor meus ad te pervéniat:"
                  :verse "Fiant aures tuæ intendéntes in oratiónem servi tui."
                  :repeat "Quia non spernis, Deus, preces páuperum."
                  :gloria nil)
               (:respond "Velóciter exáudi me, Deus,"
                  :verse "Dies mei sicut umbra declinavérunt, et ego sicut fœnum árui."
                  :repeat "Tu autem idem ipse es, et anni tui non defícient."
                  :gloria t))))

    ;; Epi2-1: Feria II infra Hebdomadam II post Epiphaniam
    ((2 . 1) . (:lessons
              ((:source "De Epístola secúnda ad Corínthios"
               :ref "2 Cor 3:1-3"
               :text "1 Incípimus íterum nosmetípsos commendáre? aut numquid egémus (sicut quidam) commendatítiis epístolis ad vos, aut ex vobis?
2 Epístola nostra vos estis, scripta in córdibus nostris, quæ scitur, et legitur ab ómnibus homínibus:
3 manifestáti quod epístola estis Christi, ministráta a nobis, et scripta non atraménto, sed Spíritu Dei vivi: non in tábulis lapídeis, sed in tábulis cordis carnálibus.")
               (:ref "2 Cor 3:4-8"
               :text "4 Fidúciam autem talem habémus per Christum ad Deum:
5 non quod sufficiéntes simus cogitáre áliquid a nobis, quasi ex nobis: sed sufficiéntia nostra ex Deo est:
6 qui et idóneos nos fecit minístros novi Testaménti, non líttera, sed Spíritu: líttera enim occídit, Spíritus autem vivíficat.
7 Quod si ministrátio mortis lítteris deformáta in lapídibus, fuit in glória, ita ut non possent inténdere fílii Israël in fáciem Móysi propter glóriam vultus ejus, quæ evacuátur:
8 quómodo non magis ministrátio Spíritus erit in glória?")
               (:ref "2 Cor 3:9-14"
               :text "9 Nam si ministrátio damnatiónis glória est: multo magis abúndat ministérium justítiæ in glória.
10 Nam nec glorificátum est, quod cláruit in hac parte, propter excelléntem glóriam.
11 Si enim quod evacuátur, per glóriam est: multo magis quod manet, in glória est.
12 Habéntes ígitur talem spem, multa fidúcia útimur:
13 et non sicut Móyses ponébat velámen super fáciem suam, ut non inténderent fílii Israël in fáciem ejus, quod evacuátur,
14 sed obtúsi sunt sensus eórum. Usque in hodiérnum enim diem idípsum velámen in lectióne véteris Testaménti manet non revelátum, quóniam in Christo evacuátur."))
              :responsories
              ((:respond "Quam magna multitúdo dulcédinis tuæ, Dómine,"
                  :verse "Et perfecísti eis qui sperant in te, Dómine, in conspéctu filiórum hóminum."
                  :repeat "Quam abscondísti timéntibus te!"
                  :gloria nil)
               (:respond "Adjútor meus esto, Deus:"
                  :verse "Neque despícias me, Deus, salutáris meus."
                  :repeat "Ne derelínquas me."
                  :gloria nil)
               (:respond "Benedícam Dóminum in omni témpore:"
                  :verse "In Dómino laudábitur ánima mea, áudiant mansuéti, et læténtur."
                  :repeat "Semper laus ejus in ore meo."
                  :gloria t))))

    ;; Epi2-2: Feria III infra Hebdomadam II post Epiphaniam
    ((2 . 2) . (:lessons
              ((:source "De Epístola secúnda ad Corínthios"
               :ref "2 Cor 5:1-4"
               :text "1 Scimus enim quóniam, si terréstris domus nostra hujus habitatiónis dissolvátur, quod ædificatiónem ex Deo habémus, domum non manufáctam, ætérnam in cælis.
2 Nam et in hoc ingemíscimus, habitatiónem nostram, quæ de cælo est, superíndui cupiéntes:
3 si tamen vestíti, non nudi inveniámur.
4 Nam et qui sumus in hoc tabernáculo, ingemíscimus graváti: eo quod nólumus exspoliári, sed supervestíri, ut absorbeátur quod mortále est, a vita.")
               (:ref "2 Cor 5:6-10"
               :text "6 Audéntes ígitur semper, sciéntes, quóniam dum sumus in córpore, peregrinámur a Dómino:
7 (per fidem enim ambulámus, et non per spéciem)
8 audémus autem, et bonam voluntátem habémus magis peregrinári a córpore, et præséntes esse ad Dóminum.
9 Et ídeo conténdimus sive abséntes, sive præséntes, placére illi.
10 Omnes enim nos manifestári opórtet ante tribúnal Christi, ut réferat unusquísque própria córporis, prout gessit, sive bonum, sive malum.")
               (:ref "2 Cor 5:11-15"
               :text "11 Sciéntes ergo timórem Dómini homínibus suadémus, Deo autem manifésti sumus. Spero autem et in consciéntiis vestris maniféstos nos esse.
12 Non íterum commendámus nos vobis, sed occasiónem damus vobis gloriándi pro nobis: ut habeátis ad eos qui in fácie gloriántur, et non in corde.
13 Sive enim mente excédimus, Deo: sive sóbrii sumus, vobis.
14 Cáritas enim Christi urget nos: æstimántes hoc, quóniam si unus pro ómnibus mórtuus est, ergo omnes mórtui sunt:
15 et pro ómnibus mórtuus est Christus: ut et qui vivunt, jam non sibi vivant, sed ei qui pro ipsis mórtuus est et resurréxit."))
              :responsories
              ((:respond "Auribus pércipe, Deus, lácrimas meas: ne síleas a me, remítte mihi:"
                  :verse "Compláceat tibi, ut erípias me: Dómine, ad adjuvándum me festína."
                  :repeat "Quóniam íncola ego sum apud te, et peregrínus."
                  :gloria nil)
               (:respond "Státuit Dóminus supra petram pedes meos, et diréxit gressus meos Deus:"
                  :verse "Exaudívit preces meas: et edúxit me de lacu misériæ."
                  :repeat "Et misit in os meum cánticum novum."
                  :gloria nil)
               (:respond "Ego dixi, Dómine, miserére mei:"
                  :verse "Ab ómnibus iniquitátibus meis éripe me, Dómine."
                  :repeat "Sana ánimam meam, quia peccávi tibi."
                  :gloria t))))

    ;; Epi2-3: Feria IV infra Hebdomadam II post Epiphaniam
    ((2 . 3) . (:lessons
              ((:source "De Epístola secúnda ad Corínthios"
               :ref "2 Cor 7:1-3"
               :text "1 Has ergo habéntes promissiónes, caríssimi, mundémus nos ab omni inquinaménto carnis et spíritus, perficiéntes sanctificatiónem in timóre Dei.
2 Cápite nos. Néminem lǽsimus, néminem corrúpimus, néminem circumvénimus.
3 Non ad condemnatiónem vestram dico. Prædíximus enim, quod in córdibus nostris estis ad commoriéndum, et ad convivéndum.")
               (:ref "2 Cor 7:4-7"
               :text "4 Multa mihi fidúcia est apud vos, multa mihi gloriátio pro vobis, replétus sum consolatióne, superabúndo gáudio in omni tribulatióne nostra.
5 Nam et cum venissémus in Macedóniam, nullam réquiem hábuit caro nostra, sed omnem tribulatiónem passi sumus: foris pugnæ, intus timóres.
6 Sed qui consolátur húmiles, consolátus est nos Deus in advéntu Titi.
7 Non solum autem in advéntu ejus, sed étiam in consolatióne, qua consolátus est in vobis, réferens nobis vestrum desidérium, vestrum fletum, vestram æmulatiónem pro me, ita ut magis gaudérem.")
               (:ref "2 Cor 7:8-10"
               :text "8 Quóniam etsi contristávi vos in epístola, non me pœ́nitet: et si pœnitéret, videns quod epístola illa (etsi ad horam) vos contristávit;
9 nunc gáudeo: non quia contristáti estis, sed quia contristáti estis ad pœniténtiam. Contristáti enim estis secúndum Deum, ut in nullo detriméntum patiámini ex nobis.
10 Quæ enim secúndum Deum tristítia est, pœniténtiam in salútem stábilem operátur: sǽculi autem tristítia mortem operátur."))
              :responsories
              ((:respond "Ne perdíderis me cum iniquitátibus meis:"
                  :verse "Non intres in judícium cum servo tuo, Dómine."
                  :repeat "Neque in finem irátus resérves mala mea."
                  :gloria nil)
               (:respond "Parátum cor meum, Deus, parátum cor meum:"
                  :verse "Exsúrge, glória mea, exsúrge, psaltérium et cíthara, exsúrgam dilúculo."
                  :repeat "Cantábo et psalmum dicam Dómino."
                  :gloria nil)
               (:respond "Adjútor meus, tibi psallam, quia, Deus, suscéptor meus es:"
                  :verse "Lætábor, et exsultábo in te, psallam nómini tuo, Altíssime."
                  :repeat "Deus meus, misericórdia mea."
                  :gloria t))))

    ;; Epi2-4: Feria V infra Hebdomadam II post Epiphaniam
    ((2 . 4) . (:lessons
              ((:source "De Epístola secúnda ad Corínthios"
               :ref "2 Cor 10:1-3"
               :text "1 Ipse autem ego Paulus óbsecro vos per mansuetúdinem et modéstiam Christi, qui in fácie quidem húmilis sum inter vos, absens autem confído in vobis.
2 Rogo autem vos, ne præsens áudeam per eam confidéntiam, qua exístimor audére in quosdam, qui arbitrántur nos tamquam secúndum carnem ambulémus.
3 In carne enim ambulántes, non secúndum carnem militámus.")
               (:ref "2 Cor 10:4-7"
               :text "4 Nam arma milítiæ nostræ non carnália sunt, sed poténtia Deo ad destructiónem munitiónum, consília destruéntes,
5 et omnem altitúdinem extolléntem se advérsus sciéntiam Dei, et in captivitátem redigéntes omnem intelléctum in obséquium Christi,
6 et in promptu habéntes ulcísci omnem inobediéntiam, cum impléta fúerit vestra obediéntia.
7 Quæ secúndum fáciem sunt, vidéte. Si quis confídit sibi Christi se esse, hoc cógitet íterum apud se: quia sicut ipse Christi est, ita et nos.")
               (:ref "2 Cor 10:8-12"
               :text "8 Nam, et si ámplius áliquid gloriátus fúero de potestáte nostra, quam dedit nobis Dóminus in ædificatiónem, et non in destructiónem vestram: non erubéscam.
9 Ut autem non exístimer tamquam terrére vos per epístolas:
10 quóniam quidem epístolæ, ínquiunt, graves sunt et fortes: præséntia autem córporis infírma, et sermo contemptíbilis:
11 hoc cógitet qui ejúsmodi est, quia quales sumus verbo per epístolas abséntes, tales et præséntes in facto.
12 Non enim audémus insérere, aut comparáre nos quibúsdam, qui seípsos comméndant: sed ipsi in nobis nosmetípsos metiéntes, et comparántes nosmetípsos nobis."))
              :responsories
              ((:respond "Deus, in te sperávi, Dómine, non confúndar in ætérnum: in justítia tua líbera me,"
                  :verse "Inclína ad me aurem tuam, et salva me."
                  :repeat "Et éripe me."
                  :gloria nil)
               (:respond "Repleátur os meum laude tua, ut hymnum dicam glóriæ tuæ, tota die magnitúdinem tuam: noli me proícere in témpore senectútis:"
                  :verse "Gaudébunt lábia mea cum cantávero tibi."
                  :repeat "Dum defécerit in me virtus mea, ne derelínquas me."
                  :gloria nil)
               (:respond "Gaudébunt lábia mea cum cantávero tibi:"
                  :verse "Sed et lingua mea meditábitur justítiam tuam, tota die laudem tuam."
                  :repeat "Et ánima mea, quam redemísti, Dómine."
                  :gloria t))))

    ;; Epi2-5: Feria VI infra Hebdomadam II post Epiphaniam
    ((2 . 5) . (:lessons
              ((:source "De Epístola secúnda ad Corínthios"
               :ref "2 Cor 12:1-4"
               :text "1 Si gloriári opórtet (non éxpedit quidem) véniam autem ad visiónes, et revelatiónes Dómini.
2 Scio hóminem in Christo ante annos quatuórdecim (sive in córpore néscio, sive extra corpus, néscio, Deus scit:) raptum hujúsmodi usque ad tértium cælum.
3 Et scio hujúsmodi hóminem, (sive in córpore, sive extra corpus, néscio, Deus scit:)
4 quóniam raptus est in paradísum: et audívit arcána verba, quæ non licet hómini loqui.")
               (:ref "2 Cor 12:5-9"
               :text "5 Pro hujúsmodi gloriábor: pro me autem nihil gloriábor, nisi in infirmitátibus meis.
6 Nam, et si volúero gloriári, non ero insípiens: veritátem enim dicam: parco autem, ne quis me exístimet supra id, quod videt in me, aut áliquid audit ex me.
7 Et ne magnitúdo revelatiónum extóllat me, datus est mihi stímulus carnis meæ ángelus sátanæ, qui me colaphízet.
8 Propter quod ter Dóminum rogávi, ut discéderet a me:
9 et dixit mihi: Súfficit tibi grátia mea: nam virtus in infirmitáte perfícitur.")
               (:ref "2 Cor 12:9-11"
               :text "9 Libénter ígitur gloriábor in infirmitátibus meis, ut inhábitet in me virtus Christi.
10 Propter quod pláceo mihi in infirmitátibus meis, in contuméliis, in necessitátibus, in persecutiónibus, in angústiis pro Christo: Cum enim infírmor, tunc potens sum.
11 Factus sum insípiens, vos me coëgístis. Ego enim a vobis débui commendári: nihil enim minus fui ab iis, qui sunt supra modum, Apóstoli: tamétsi nihil sum."))
              :responsories
              ((:respond "Confitébor tibi, Dómine Deus, in toto corde meo, et honorificábo nomen tuum in ætérnum:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "Quia misericórdia tua, Dómine, magna est super me."
                  :gloria nil)
               (:respond "Misericórdia tua, Dómine, magna est super me:"
                  :verse "In die tribulatiónis meæ clamávi ad te, quia exaudísti me."
                  :repeat "Et liberásti ánimam meam ex inférno inferióri."
                  :gloria nil)
               (:respond "Factus est mihi Dóminus in refúgium:"
                  :verse "Erípuit me de inimícis meis fortíssimis, et factus est Dóminus protéctor meus."
                  :repeat "Et Deus meus in auxílium spei meæ."
                  :gloria t))))

    ;; Epi2-6: Sabbato infra Hebdomadam II post Epiphaniam
    ((2 . 6) . (:lessons
              ((:source "De Epístola secúnda ad Corínthios"
               :ref "2 Cor 13:1-4"
               :text "1 Ecce tértio hoc vénio ad vos: In ore duórum vel trium téstium stabit omne verbum.
2 Prædíxi, et prædíco, ut præsens, et nunc absens iis, qui ante peccavérunt, et céteris ómnibus, quóniam si vénero íterum, non parcam.
3 An experiméntum quǽritis, ejus, qui in me lóquitur Christus, qui in vobis non infirmátur, sed potens est in vobis?
4 Nam etsi crucifíxus est ex infirmitáte: sed vivit ex virtúte Dei. Nam et nos infírmi sumus in illo: sed vivémus cum eo ex virtúte Dei in vobis.")
               (:ref "2 Cor 13:5-9"
               :text "5 Vosmetípsos tentáte si estis in fide: ipsi vos probáte. An non cognóscitis vosmetípsos, quia Christus Jesus in vobis est? nisi forte réprobi estis.
6 Spero autem quod cognoscétis, quia nos non sumus réprobi.
7 Orámus autem Deum, ut nihil mali faciátis, non ut nos probáti appareámus, sed ut vos quod bonum est faciátis: nos autem ut réprobi simus.
8 Non enim póssumus áliquid advérsus veritátem, sed pro veritáte.
9 Gaudémus enim, quóniam nos infírmi sumus, vos autem poténtes estis. Hoc et orámus vestram consummatiónem.")
               (:ref "2 Cor 13:10-13"
               :text "10 Ideo hæc absens scribo, ut non præsens dúrius agam secúndum potestátem, quam Dóminus dedit mihi in ædificatiónem, et non in destructiónem.
11 De cétero, fratres, gaudéte, perfécti estóte, exhortámini, idem sápite, pacem habéte, et Deus pacis et dilectiónis erit vobíscum.
12 Salutáte ínvicem in ósculo sancto. Salútant vos omnes sancti.
13 Grátia Dómini nostri Jesu Christi, et cáritas Dei, et communicátio Sancti Spíritus sit cum ómnibus vobis. Amen."))
              :responsories
              ((:respond "Misericórdiam et judícium cantábo tibi, Dómine:"
                  :verse "Perambulábam in innocéntia cordis mei, in médio domus meæ."
                  :repeat "Psallam et intéllegam in via immaculáta, quando vénies ad me."
                  :gloria nil)
               (:respond "Dómine, exáudi oratiónem meam, et clamor meus ad te pervéniat:"
                  :verse "Fiant aures tuæ intendéntes in oratiónem servi tui."
                  :repeat "Quia non spernis, Deus, preces páuperum."
                  :gloria nil)
               (:respond "Velóciter exáudi me, Deus,"
                  :verse "Dies mei sicut umbra declinavérunt, et ego sicut fœnum árui."
                  :repeat "Tu autem idem ipse es, et anni tui non defícient."
                  :gloria t))))

    ;; Epi3-1: Feria II infra Hebdomadam III post Epiphaniam
    ((3 . 1) . (:lessons
              ((:source "De Epístola ad Gálatas"
               :ref "Gal 3:1-6"
               :text "1 O insensáti Gálatæ, quis vos fascinávit non obedíre veritáti, ante quorum óculos Jesus Christus præscríptus est, in vobis crucifíxus?
2 Hoc solum a vobis volo díscere: ex opéribus legis Spíritum accepístis, an ex audítu fídei?
3 sic stulti estis, ut cum Spíritu cœpéritis, nunc carne consummémini?
4 tanta passi estis sine causa? si tamen sine causa.
5 Qui ergo tríbuit vobis Spíritum, et operátur virtútes in vobis: ex opéribus legis, an ex audítu fídei?
6 Sicut scriptum est: Abraham crédidit Deo, et reputátum est illi ad justítiam:")
               (:ref "Gal 3:7-10"
               :text "7 Cognóscite ergo quia qui ex fide sunt, ii sunt fílii Abrahæ.
8 Próvidens autem Scriptúra quia ex fide justíficat gentes Deus, prænuntiávit Abrahæ: Quia benedicéntur in te omnes gentes.
9 Igitur qui ex fide sunt, benedicéntur cum fidéli Abraham.
10 Quicúmque enim ex opéribus legis sunt, sub maledícto sunt. Scriptum est enim: Maledíctus omnis qui non permánserit in ómnibus quæ scripta sunt in libro legis ut fáciat ea.")
               (:ref "Gal 3:11-14"
               :text "11 Quóniam autem in lege nemo justificátur apud Deum, maniféstum est: quia justus ex fide vivit.
12 Lex autem non est ex fide, sed: Qui fécerit ea, vivet in illis.
13 Christus nos redémit de maledícto legis, factus pro nobis maledíctum: quia scriptum est: Maledíctus omnis qui pendet in ligno:
14 ut in géntibus benedíctio Abrahæ fíeret in Christo Jesu, ut pollicitatiónem Spíritus accipiámus per fidem."))
              :responsories
              ((:respond "Quam magna multitúdo dulcédinis tuæ, Dómine,"
                  :verse "Et perfecísti eis qui sperant in te, Dómine, in conspéctu filiórum hóminum."
                  :repeat "Quam abscondísti timéntibus te!"
                  :gloria nil)
               (:respond "Adjútor meus esto, Deus:"
                  :verse "Neque despícias me, Deus, salutáris meus."
                  :repeat "Ne derelínquas me."
                  :gloria nil)
               (:respond "Benedícam Dóminum in omni témpore:"
                  :verse "In Dómino laudábitur ánima mea, áudiant mansuéti, et læténtur."
                  :repeat "Semper laus ejus in ore meo."
                  :gloria t))))

    ;; Epi3-2: Feria III infra Hebdomadam III post Epiphaniam
    ((3 . 2) . (:lessons
              ((:source "De Epístola ad Gálatas"
               :ref "Gal 5:1-5"
               :text "1 State, et nolíte íterum jugo servitútis continéri.
2 Ecce ego Paulus dico vobis: quóniam si circumcidámini, Christus vobis nihil próderit.
3 Testíficor autem rursus omni hómini circumcidénti se, quóniam débitor est univérsæ legis faciéndæ.
4 Evacuáti estis a Christo, qui in lege justificámini: a grátia excidístis.
5 Nos enim spíritu ex fide, spem justítiæ exspectámus.")
               (:ref "Gal 5:6-10"
               :text "6 Nam in Christo Jesu neque circumcísio áliquid valet, neque præpútium: sed fides, quæ per caritátem operátur.
7 Currebátis bene: quis vos impedívit veritáti non obedíre?
8 persuásio hæc non est ex eo, qui vocat vos.
9 Módicum ferméntum totam massam corrúmpit.
10 Ego confído in vobis in Dómino, quod nihil áliud sapiétis: qui autem contúrbat vos, portábit judícium, quicúmque est ille.")
               (:ref "Gal 5:11-17"
               :text "11 Ego autem, fratres, si circumcisiónem adhuc prǽdico: quid adhuc persecutiónem pátior? ergo evacuátum est scándalum crucis.
12 Utinam et abscindántur qui vos contúrbant.
13 Vos enim in libertátem vocáti estis, fratres: tantum ne libertátem in occasiónem detis carnis, sed per caritátem Spíritus servíte ínvicem.
14 Omnis enim lex in uno sermóne implétur: Díliges próximum tuum sicut teípsum.
15 Quod si ínvicem mordétis, et coméditis: vidéte ne ab ínvicem consumámini.
16 Dico autem: Spíritu ambuláte, et desidéria carnis non perficiétis.
17 Caro enim concupíscit advérsus spíritum, spíritus autem advérsus carnem: hæc enim sibi ínvicem adversántur, ut non quæcúmque vultis, illa faciátis."))
              :responsories
              ((:respond "Auribus pércipe, Deus, lácrimas meas: ne síleas a me, remítte mihi:"
                  :verse "Compláceat tibi, ut erípias me: Dómine, ad adjuvándum me festína."
                  :repeat "Quóniam íncola ego sum apud te, et peregrínus."
                  :gloria nil)
               (:respond "Státuit Dóminus supra petram pedes meos, et diréxit gressus meos Deus:"
                  :verse "Exaudívit preces meas: et edúxit me de lacu misériæ."
                  :repeat "Et misit in os meum cánticum novum."
                  :gloria nil)
               (:respond "Ego dixi, Dómine, miserére mei:"
                  :verse "Ab ómnibus iniquitátibus meis éripe me, Dómine."
                  :repeat "Sana ánimam meam, quia peccávi tibi."
                  :gloria t))))

    ;; Epi3-3: Feria IV infra Hebdomadam III post Epiphaniam
    ((3 . 3) . (:lessons
              ((:source "Incipit Epístola beáti Pauli Apóstoli ad Ephésios"
               :ref "Eph 1:1-4"
               :text "1 Paulus Apóstolus Jesu Christi per voluntátem Dei, ómnibus sanctis qui sunt Ephesi, et fidélibus in Christo Jesu.
2 Grátia vobis, et pax a Deo Patre nostro, et Dómino Jesu Christo.
3 Benedíctus Deus et Pater Dómini nostri Jesu Christi, qui benedíxit nos in omni benedictióne spirituáli in cæléstibus in Christo,
4 sicut elégit nos in ipso ante mundi constitutiónem, ut essémus sancti et immaculáti in conspéctu ejus in caritáte.")
               (:ref "Eph 1:5-10"
               :text "5 Qui prædestinávit nos in adoptiónem filiórum per Jesum Christum in ipsum: secúndum propósitum voluntátis suæ,
6 in laudem glóriæ grátiæ suæ, in qua gratificávit nos in dilécto Fílio suo.
7 In quo habémus redemptiónem per sánguinem ejus, remissiónem peccatórum secúndum divítias grátiæ ejus,
8 quæ superabundávit in nobis in omni sapiéntia et prudéntia:
9 ut notum fáceret nobis sacraméntum voluntátis suæ, secúndum beneplácitum ejus, quod propósuit in eo,
10 in dispensatióne plenitúdinis témporum, instauráre ómnia in Christo, quæ in cælis et quæ in terra sunt, in ipso;")
               (:ref "Eph 1:11-14"
               :text "11 In quo étiam et nos sorte vocáti sumus prædestináti secúndum propósitum ejus qui operátur ómnia secúndum consílium voluntátis suæ:
12 ut simus in laudem glóriæ ejus nos, qui ante sperávimus in Christo;
13 in quo et vos, cum audissétis verbum veritátis, Evangélium salútis vestræ, in quo et credéntes signáti estis Spíritu promissiónis Sancto,
14 qui est pignus hereditátis nostræ, in redemptiónem acquisitiónis, in laudem glóriæ ipsíus."))
              :responsories
              ((:respond "Ne perdíderis me cum iniquitátibus meis:"
                  :verse "Non intres in judícium cum servo tuo, Dómine."
                  :repeat "Neque in finem irátus resérves mala mea."
                  :gloria nil)
               (:respond "Parátum cor meum, Deus, parátum cor meum:"
                  :verse "Exsúrge, glória mea, exsúrge, psaltérium et cíthara, exsúrgam dilúculo."
                  :repeat "Cantábo et psalmum dicam Dómino."
                  :gloria nil)
               (:respond "Adjútor meus, tibi psallam, quia, Deus, suscéptor meus es:"
                  :verse "Lætábor, et exsultábo in te, psallam nómini tuo, Altíssime."
                  :repeat "Deus meus, misericórdia mea."
                  :gloria t))))

    ;; Epi3-4: Feria V infra Hebdomadam III post Epiphaniam
    ((3 . 4) . (:lessons
              ((:source "De Epístola ad Ephésios"
               :ref "Eph 4:1-6"
               :text "1 Obsecro ítaque vos ego vinctus in Dómino, ut digne ambulétis vocatióne, qua vocáti estis,
2 cum omni humilitáte, et mansuetúdine, cum patiéntia, supportántes ínvicem in caritáte,
3 sollíciti serváre unitátem Spíritus in vínculo pacis.
4 Unum corpus, et unus Spíritus, sicut vocáti estis in una spe vocatiónis vestræ.
5 Unus Dóminus, una fides, unum baptísma.
6 Unus Deus et Pater ómnium, qui est super omnes, et per ómnia, et in ómnibus nobis.")
               (:ref "Eph 4:7-10"
               :text "7 Unicuíque autem nostrum data est grátia secúndum mensúram donatiónis Christi.
8 Propter quod dicit: Ascéndens in altum, captívam duxit captivitátem: dedit dona homínibus.
9 Quod autem ascéndit, quid est, nisi quia et descéndit primum in inferióres partes terræ?
10 Qui descéndit, ipse est et qui ascéndit super omnes cælos, ut impléret ómnia.")
               (:ref "Eph 4:11-15"
               :text "11 Et ipse dedit quosdam quidem apóstolos, quosdam autem prophétas, álios vero evangelístas, álios autem pastóres et doctóres,
12 ad consummatiónem sanctórum in opus ministérii, in ædificatiónem córporis Christi:
13 donec occurrámus omnes in unitátem fídei, et agnitiónis Fílii Dei, in virum perféctum, in mensúram ætátis plenitúdinis Christi:
14 ut jam non simus párvuli fluctuántes, et circumferámur omni vento doctrínæ in nequítia hóminum, in astútia ad circumventiónem erróris.
15 Veritátem autem faciéntes in caritáte, crescámus in illo per ómnia, qui est caput Christus:"))
              :responsories
              ((:respond "Deus, in te sperávi, Dómine, non confúndar in ætérnum: in justítia tua líbera me,"
                  :verse "Inclína ad me aurem tuam, et salva me."
                  :repeat "Et éripe me."
                  :gloria nil)
               (:respond "Repleátur os meum laude tua, ut hymnum dicam glóriæ tuæ, tota die magnitúdinem tuam: noli me proícere in témpore senectútis:"
                  :verse "Gaudébunt lábia mea cum cantávero tibi."
                  :repeat "Dum defécerit in me virtus mea, ne derelínquas me."
                  :gloria nil)
               (:respond "Gaudébunt lábia mea cum cantávero tibi:"
                  :verse "Sed et lingua mea meditábitur justítiam tuam, tota die laudem tuam."
                  :repeat "Et ánima mea, quam redemísti, Dómine."
                  :gloria t))))

    ;; Epi3-5: Feria VI infra Hebdomadam III post Epiphaniam
    ((3 . 5) . (:lessons
              ((:source "De Epístola ad Ephésios"
               :ref "Eph 5:1-4"
               :text "1 Estóte ergo imitatóres Dei, sicut fílii caríssimi,
2 et ambuláte in dilectióne, sicut et Christus diléxit nos, et trádidit semetípsum pro nobis, oblatiónem et hóstiam Deo in odórem suavitátis.
3 Fornicátio autem, et omnis immundítia, aut avarítia, nec nominétur in vobis, sicut decet sanctos:
4 aut turpitúdo, aut stultilóquium, aut scurrílitas, quæ ad rem non pértinet: sed magis gratiárum áctio.")
               (:ref "Eph 5:5-8"
               :text "5 Hoc enim scitóte intellegéntes: quod omnis fornicátor, aut immúndus, aut avárus, quod est idolórum sérvitus, non habet hereditátem in regno Christi et Dei.
6 Nemo vos sedúcat inánibus verbis: propter hæc enim venit ira Dei in fílios diffidéntiæ.
7 Nolíte ergo éffici partícipes eórum.
8 Erátis enim aliquándo ténebræ: nunc autem lux in Dómino. Ut fílii lucis ambuláte:")
               (:ref "Eph 5:9-14"
               :text "9 fructus enim lucis est in omni bonitáte, et justítia, et veritáte:
10 probántes quid sit beneplácitum Deo:
11 et nolíte communicáre opéribus infructuósis tenebrárum, magis autem redargúite.
12 Quæ enim in occúlto fiunt ab ipsis, turpe est et dícere.
13 Omnia autem, quæ arguúntur, a lúmine manifestántur: omne enim, quod manifestátur, lumen est.
14 Propter quod dicit: Surge qui dormis, et exsúrge a mórtuis, et illuminábit te Christus."))
              :responsories
              ((:respond "Confitébor tibi, Dómine Deus, in toto corde meo, et honorificábo nomen tuum in ætérnum:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "Quia misericórdia tua, Dómine, magna est super me."
                  :gloria nil)
               (:respond "Misericórdia tua, Dómine, magna est super me:"
                  :verse "In die tribulatiónis meæ clamávi ad te, quia exaudísti me."
                  :repeat "Et liberásti ánimam meam ex inférno inferióri."
                  :gloria nil)
               (:respond "Factus est mihi Dóminus in refúgium:"
                  :verse "Erípuit me de inimícis meis fortíssimis, et factus est Dóminus protéctor meus."
                  :repeat "Et Deus meus in auxílium spei meæ."
                  :gloria t))))

    ;; Epi3-6: Sabbato infra Hebdomadam III post Epiphaniam
    ((3 . 6) . (:lessons
              ((:source "De Epístola ad Ephésios"
               :ref "Eph 6:1-4"
               :text "1 Fílii, obedíte paréntibus vestris in Dómino: hoc enim justum est.
2 Honóra patrem tuum, et matrem tuam, quod est mandátum primum in promissióne:
3 ut bene sit tibi, et sis longǽvus super terram.
4 Et vos patres, nolíte ad iracúndiam provocáre fílios vestros: sed educáte illos in disciplína et correptióne Dómini.")
               (:ref "Eph 6:5-9"
               :text "5 Servi, obedíte dóminis carnálibus cum timóre et tremóre, in simplicitáte cordis vestri, sicut Christo:
6 non ad óculum serviéntes, quasi homínibus placéntes, sed ut servi Christi, faciéntes voluntátem Dei ex ánimo,
7 cum bona voluntáte serviéntes, sicut Dómino, et non homínibus:
8 sciéntes quóniam unusquísque quodcúmque fécerit bonum, hoc recípiet a Dómino, sive servus, sive liber.
9 Et vos dómini, éadem fácite illis, remitténtes minas: sciéntes quia et illórum et vester Dóminus est in cælis: et personárum accéptio non est apud eum.")
               (:ref "Eph 6:10-13"
               :text "10 De cétero, fratres, confortámini in Dómino, et in poténtia virtútis ejus.
11 Indúite vos armatúram Dei, ut possítis stare advérsus insídias diáboli:
12 quóniam non est nobis colluctátio advérsus carnem et sánguinem, sed advérsus príncipes, et potestátes, advérsus mundi rectóres tenebrárum harum, contra spirituália nequítiæ, in cæléstibus.
13 Proptérea accípite armatúram Dei, ut possítis resístere in die malo, et in ómnibus perfécti stare."))
              :responsories
              ((:respond "Misericórdiam et judícium cantábo tibi, Dómine:"
                  :verse "Perambulábam in innocéntia cordis mei, in médio domus meæ."
                  :repeat "Psallam et intéllegam in via immaculáta, quando vénies ad me."
                  :gloria nil)
               (:respond "Dómine, exáudi oratiónem meam, et clamor meus ad te pervéniat:"
                  :verse "Fiant aures tuæ intendéntes in oratiónem servi tui."
                  :repeat "Quia non spernis, Deus, preces páuperum."
                  :gloria nil)
               (:respond "Velóciter exáudi me, Deus,"
                  :verse "Dies mei sicut umbra declinavérunt, et ego sicut fœnum árui."
                  :repeat "Tu autem idem ipse es, et anni tui non defícient."
                  :gloria t))))

    ;; Epi4-1: Feria Secunda infra Hebdomadam IV post Epiphaniam
    ((4 . 1) . (:lessons
              ((:source "De Epístola ad Philippénses"
               :ref "Phil 4:1-3"
               :text "1 Itaque fratres mei caríssimi, et desideratíssimi, gáudium meum, et coróna mea: sic state in Dómino, caríssimi.
2 Evódiam rogo, et Sýntychen déprecor, idípsum sápere in Dómino.
3 Etiam rogo et te, germáne compar, ádjuva illas, quæ mecum laboravérunt in Evangélio cum Cleménte, et céteris adjutóribus meis, quorum nómina sunt in libro vitæ.")
               (:ref "Phil 4:4-7"
               :text "4 Gaudéte in Dómino semper: íterum dico gaudéte.
5 Modéstia vestra nota sit ómnibus homínibus: Dóminus prope est.
6 Nihil sollíciti sitis: sed in omni oratióne, et obsecratióne, cum gratiárum actióne petitiónes vestræ innotéscant apud Deum.
7 Et pax Dei, quæ exúperat omnem sensum, custódiat corda vestra, et intellegéntias vestras in Christo Jesu.")
               (:ref "Phil 4:8-10"
               :text "8 De cétero fratres, quæcúmque sunt vera, quæcúmque pudíca, quæcúmque justa, quæcúmque sancta, quæcúmque amabília, quæcúmque bonæ famæ, siqua virtus, siqua laus disciplínæ, hæc cogitáte.
9 Quæ et didicístis, et accepístis, et audístis, et vidístis in me, hæc ágite: et Deus pacis erit vobíscum.
10 Gavísus sum autem in Dómino veheménter, quóniam tandem aliquándo refloruístis pro me sentíre, sicut et sentiebátis: occupáti autem erátis."))
              :responsories
              ((:respond "Quam magna multitúdo dulcédinis tuæ, Dómine,"
                  :verse "Et perfecísti eis qui sperant in te, Dómine, in conspéctu filiórum hóminum."
                  :repeat "Quam abscondísti timéntibus te!"
                  :gloria nil)
               (:respond "Adjútor meus esto, Deus:"
                  :verse "Neque despícias me, Deus, salutáris meus."
                  :repeat "Ne derelínquas me."
                  :gloria nil)
               (:respond "Benedícam Dóminum in omni témpore:"
                  :verse "In Dómino laudábitur ánima mea, áudiant mansuéti, et læténtur."
                  :repeat "Semper laus ejus in ore meo."
                  :gloria t))))

    ;; Epi4-2: Feria Tertia infra Hebdomadam IV post Epiphaniam
    ((4 . 2) . (:lessons
              ((:source "Incipit Epístola beáti Pauli Apóstoli ad Colossénses"
               :ref "Col 1:1-8"
               :text "1 Paulus Apóstolus Jesu Christi per voluntátem Dei, et Timótheus frater:
2 eis, qui sunt Colóssis, sanctis, et fidélibus frátribus in Christo Jesu.
3 Grátia vobis, et pax a Deo Patre nostro, et Dómino Jesu Christo. Grátias ágimus Deo, et Patri Dómini nostri Jesu Christi semper pro vobis orántes:
4 audiéntes fidem vestram in Christo Jesu, et dilectiónem quam habétis in sanctos omnes
5 propter spem, quæ repósita est vobis in cælis: quam audístis in verbo veritátis Evangélii:
6 quod pervénit ad vos, sicut et in univérso mundo est, et fructíficat, et crescit sicut in vobis, ex ea die, qua audístis, et cognovístis grátiam Dei in veritáte,
7 sicut didicístis ab Epaphra caríssimo consérvo nostro, qui est fidélis pro vobis miníster Christi Jesu,
8 qui étiam manifestávit nobis dilectiónem vestram in spíritu.")
               (:ref "Col 1:9-12"
               :text "9 Ideo et nos ex qua die audívimus, non cessámus pro vobis orántes, et postulántes ut impleámini agnitióne voluntátis ejus, in omni sapiéntia et intelléctu spiritáli:
10 ut ambulétis digne Deo per ómnia placéntes: in omni ópere bono fructificántes, et crescéntes in sciéntia Dei:
11 in omni virtúte confortáti secúndum poténtiam claritátis ejus, in omni patiéntia et longanimitáte cum gáudio,
12 grátias agéntes Deo Patri, qui dignos nos fecit in partem sortis sanctórum in lúmine:")
               (:ref "Col 1:13-18"
               :text "13 qui erípuit nos de potestáte tenebrárum, et tránstulit in regnum fílii dilectiónis suæ,
14 in quo habémus redemptiónem per sánguinem ejus, remissiónem peccatórum:
15 qui est imágo Dei invisíbilis, primogénitus omnis creatúræ:
16 quóniam in ipso cóndita sunt univérsa in cælis, et in terra, visibília, et invisibília, sive throni, sive dominatiónes, sive principátus, sive potestátes: ómnia per ipsum et in ipso creáta sunt:
17 et ipse est ante omnes, et ómnia in ipso constant.
18 Et ipse est caput córporis Ecclésiæ, qui est princípium, primogénitus ex mórtuis: ut sit in ómnibus ipse primátum tenens:"))
              :responsories
              ((:respond "Auribus pércipe, Deus, lácrimas meas: ne síleas a me, remítte mihi:"
                  :verse "Compláceat tibi, ut erípias me: Dómine, ad adjuvándum me festína."
                  :repeat "Quóniam íncola ego sum apud te, et peregrínus."
                  :gloria nil)
               (:respond "Státuit Dóminus supra petram pedes meos, et diréxit gressus meos Deus:"
                  :verse "Exaudívit preces meas: et edúxit me de lacu misériæ."
                  :repeat "Et misit in os meum cánticum novum."
                  :gloria nil)
               (:respond "Ego dixi, Dómine, miserére mei:"
                  :verse "Ab ómnibus iniquitátibus meis éripe me, Dómine."
                  :repeat "Sana ánimam meam, quia peccávi tibi."
                  :gloria t))))

    ;; Epi4-3: Feria IV infra Hebdomadam IV post Epiphaniam
    ((4 . 3) . (:lessons
              ((:source "De Epístola ad Colossénses"
               :ref "Col 3:12-15"
               :text "12 Indúite vos ergo, sicut elécti Dei, sancti, et dilécti, víscera misericórdiæ, benignitátem, humilitátem, modéstiam, patiéntiam:
13 supportántes ínvicem, et donántes vobismetípsis si quis advérsus áliquem habet querélam: sicut et Dóminus donávit vobis, ita et vos.
14 Super ómnia autem hæc, caritátem habéte, quod est vínculum perfectiónis:
15 et pax Christi exsúltet in córdibus vestris, in qua et vocáti estis in uno córpore: et grati estóte.")
               (:ref "Col 3:16-21"
               :text "16 Verbum Christi hábitet in vobis abundánter, in omni sapiéntia, docéntes, et commonéntes vosmetípsos, psalmis, hymnis, et cánticis spirituálibus, in grátia cantántes in córdibus vestris Deo.
17 Omne, quodcúmque fácitis in verbo aut in ópere, ómnia in nómine Dómini Jesu Christi, grátias agéntes Deo et Patri per ipsum.
18 Mulíeres, súbditæ estóte viris, sicut opórtet, in Dómino.
19 Viri, dilígite uxóres vestras, et nolíte amári esse ad illas.
20 Fílii, obedíte paréntibus per ómnia: hoc enim plácitum est in Dómino.
21 Patres, nolíte ad indignatiónem provocáre fílios vestros, ut non pusíllo ánimo fiant.")
               (:ref "Col 3:22-25;4:1-2"
               :text "22 Servi, obedíte per ómnia dóminis carnálibus, non ad óculum serviéntes, quasi homínibus placéntes, sed in simplicitáte cordis, timéntes Deum.
23 Quodcúmque fácitis, ex ánimo operámini sicut Dómino, et non homínibus:
24 sciéntes quod a Dómino accipiétis retributiónem hæreditátis. Dómino Christo servíte.
25 Qui enim injúriam facit, recípiet id quod iníque gessit: et non est personárum accéptio apud Deum.
1 Dómini, quod justum est et æquum, servis præstáte: sciéntes quod et vos Dóminum habétis in cælo.
2 Oratióni instáte, vigilántes in ea in gratiárum actióne:"))
              :responsories
              ((:respond "Ne perdíderis me cum iniquitátibus meis:"
                  :verse "Non intres in judícium cum servo tuo, Dómine."
                  :repeat "Neque in finem irátus resérves mala mea."
                  :gloria nil)
               (:respond "Parátum cor meum, Deus, parátum cor meum:"
                  :verse "Exsúrge, glória mea, exsúrge, psaltérium et cíthara, exsúrgam dilúculo."
                  :repeat "Cantábo et psalmum dicam Dómino."
                  :gloria nil)
               (:respond "Adjútor meus, tibi psallam, quia, Deus, suscéptor meus es:"
                  :verse "Lætábor, et exsultábo in te, psallam nómini tuo, Altíssime."
                  :repeat "Deus meus, misericórdia mea."
                  :gloria t))))

    ;; Epi4-4: Feria V infra Hebdomadam IV post Epiphaniam
    ((4 . 4) . (:lessons
              ((:source "Incipit Epístola prima beáti Pauli Apóstoli ad Thessalonicénses"
               :ref "1 Thess 1:1-5"
               :text "1 Paulus, et Silvánus, et Timótheus ecclésiæ Thessalonicénsium in Deo Patre, et Dómino Jesu Christo.
2 Grátia vobis, et pax. Grátias ágimus Deo semper pro ómnibus vobis, memóriam vestri faciéntes in oratiónibus nostris sine intermissióne,
3 mémores óperis fídei vestræ, et labóris, et caritátis, et sustinéntiæ spei Dómini nostri Jesu Christi, ante Deum et Patrem nostrum:
4 sciéntes, fratres dilécti a Deo, electiónem vestram:
5 quia Evangélium nostrum non fuit ad vos in sermóne tantum, sed et in virtúte, et in Spíritu Sancto, et in plenitúdine multa, sicut scitis quales fuérimus in vobis propter vos.")
               (:ref "1 Thess 1:6-10"
               :text "6 Et vos imitatóres nostri facti estis, et Dómini, excipiéntes verbum in tribulatióne multa, cum gáudio Spíritus Sancti:
7 ita ut facti sitis forma ómnibus credéntibus in Macedónia, et in Achája.
8 A vobis enim diffamátus est sermo Dómini, non solum in Macedónia, et in Achája, sed et in omni loco fides vestra, quæ est ad Deum, profécta est ita ut non sit nobis necésse quidquam loqui.
9 Ipsi enim de nobis annúntiant qualem intróitum habuérimus ad vos: et quómodo convérsi estis ad Deum a simulácris, servíre Deo vivo, et vero,
10 et exspectáre Fílium ejus de cælis (quem suscitávit a mórtuis) Jesum, qui erípuit nos ab ira ventúra.")
               (:ref "1 Thess 2:1-6"
               :text "1 Nam ipsi scitis, fratres, intróitum nostrum ad vos, quia non inánis fuit:
2 sed ante passi, et contuméliis affécti (sicut scitis) in Philíppis, fidúciam habúimus in Deo nostro, loqui ad vos Evangélium Dei in multa sollicitúdine.
3 Exhortátio enim nostra non de erróre, neque de immundítia, neque in dolo,
4 sed sicut probáti sumus a Deo ut crederétur nobis Evangélium: ita lóquimur non quasi homínibus placéntes, sed Deo, qui probat corda nostra.
5 Neque enim aliquándo fúimus in sermóne adulatiónis, sicut scitis: neque in occasióne avarítiæ: Deus testis est:
6 nec quæréntes ab homínibus glóriam, neque a vobis, neque ab áliis."))
              :responsories
              ((:respond "Deus, in te sperávi, Dómine, non confúndar in ætérnum: in justítia tua líbera me,"
                  :verse "Inclína ad me aurem tuam, et salva me."
                  :repeat "Et éripe me."
                  :gloria nil)
               (:respond "Repleátur os meum laude tua, ut hymnum dicam glóriæ tuæ, tota die magnitúdinem tuam: noli me proícere in témpore senectútis:"
                  :verse "Gaudébunt lábia mea cum cantávero tibi."
                  :repeat "Dum defécerit in me virtus mea, ne derelínquas me."
                  :gloria nil)
               (:respond "Gaudébunt lábia mea cum cantávero tibi:"
                  :verse "Sed et lingua mea meditábitur justítiam tuam, tota die laudem tuam."
                  :repeat "Et ánima mea, quam redemísti, Dómine."
                  :gloria t))))

    ;; Epi4-5: Feria VI infra Hebdomadam IV post Epiphaniam
    ((4 . 5) . (:lessons
              ((:source "De Epístola prima ad Thessalonicénses"
               :ref "1 Thess 4:1-5"
               :text "1 De cétero ergo, fratres, rogámus vos et obsecrámus in Dómino Jesu, ut quemádmodum accepístis a nobis quómodo opórteat vos ambuláre, et placére Deo, sic et ambulétis ut abundétis magis.
2 Scitis enim quæ præcépta déderim vobis per Dóminum Jesum.
3 Hæc est enim volúntas Dei, sanctificátio vestra: ut abstineátis vos a fornicatióne,
4 ut sciat unusquísque vestrum vas suum possidére in sanctificatióne, et honóre:
5 non in passióne desidérii, sicut et gentes, quæ ignórant Deum:")
               (:ref "1 Thess 4:6-8"
               :text "6 et ne quis supergrediátur, neque circumvéniat in negótio fratrem suum: quóniam vindex est Dóminus de his ómnibus, sicut prædíximus vobis, et testificáti sumus.
7 Non enim vocávit nos Deus in immundítiam, sed in sanctificatiónem.
8 Itaque qui hæc spernit, non hóminem spernit, sed Deum: qui étiam dedit Spíritum suum Sanctum in nobis.")
               (:ref "1 Thess 4:9-12"
               :text "9 De caritáte autem fraternitátis non necésse habémus scríbere vobis: ipsi enim vos a Deo didicístis ut diligátis ínvicem.
10 Etenim illud fácitis in omnes fratres in univérsa Macedónia. Rogámus autem vos, fratres, ut abundétis magis,
11 et óperam detis ut quiéti sitis, et ut vestrum negótium agátis, et operémini mánibus vestris, sicut præcépimus vobis:
12 et ut honéste ambulétis ad eos qui foris sunt: et nullíus áliquid desiderétis."))
              :responsories
              ((:respond "Confitébor tibi, Dómine Deus, in toto corde meo, et honorificábo nomen tuum in ætérnum:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "Quia misericórdia tua, Dómine, magna est super me."
                  :gloria nil)
               (:respond "Misericórdia tua, Dómine, magna est super me:"
                  :verse "In die tribulatiónis meæ clamávi ad te, quia exaudísti me."
                  :repeat "Et liberásti ánimam meam ex inférno inferióri."
                  :gloria nil)
               (:respond "Factus est mihi Dóminus in refúgium:"
                  :verse "Erípuit me de inimícis meis fortíssimis, et factus est Dóminus protéctor meus."
                  :repeat "Et Deus meus in auxílium spei meæ."
                  :gloria t))))

    ;; Epi4-6: Sabbato infra Hebdomadam IV post Epiphaniam
    ((4 . 6) . (:lessons
              ((:source "Incipit Epístola secúnda beáti Pauli Apóstoli ad Thessalonicénses"
               :ref "2 Thess 1:1-5"
               :text "1 Paulus, et Sylvánus, et Timótheus, ecclésiæ Thessalonicénsium in Deo Patre nostro, et Dómino Jesu Christo.
2 Grátia vobis, et pax a Deo Patre nostro, et Dómino Jesu Christo.
3 Grátias ágere debémus semper Deo pro vobis, fratres, ita ut dignum est, quóniam supercréscit fides vestra, et abúndat cáritas uniuscujúsque vestrum in ínvicem:
4 ita ut et nos ipsi in vobis gloriémur in ecclésiis Dei, pro patiéntia vestra, et fide, et in ómnibus persecutiónibus vestris, et tribulatiónibus, quas sustinétis
5 in exémplum justi judícii Dei, ut digni habeámini in regno Dei, pro quo et patímini.")
               (:ref "2 Thess 1:6-12"
               :text "6 Si tamen justum est apud Deum retribúere tribulatiónem iis qui vos tríbulant:
7 et vobis, qui tribulámini, réquiem nobíscum in revelatióne Dómini Jesu de cælo cum ángelis virtútis ejus,
8 in flamma ignis dantis vindíctam iis qui non novérunt Deum, et qui non obédiunt Evangélio Dómini nostri Jesu Christi,
9 qui pœnas dabunt in intéritu ætérnas a fácie Dómini, et a glória virtútis ejus:
10 cum vénerit glorificári in sanctis suis, et admirábilis fíeri in ómnibus, qui credidérunt, quia créditum est testimónium nostrum super vos in die illo.
11 In quo étiam orámus semper pro vobis: ut dignétur vos vocatióne sua Deus noster, et ímpleat omnem voluntátem bonitátis, et opus fídei in virtúte,
12 ut clarificétur nomen Dómini nostri Jesu Christi in vobis, et vos in illo secúndum grátiam Dei nostri, et Dómini Jesu Christi.")
               (:ref "2 Thess 2:1-4"
               :text "1 Rogámus autem vos, fratres, per advéntum Dómini nostri Jesu Christi, et nostræ congregatiónis in ipsum:
2 ut non cito moveámini a vestro sensu, neque terreámini, neque per spíritum, neque per sermónem, neque per epístolam tamquam per nos missam, quasi instet dies Dómini.
3 Ne quis vos sedúcat ullo modo: quóniam nisi vénerit discéssio primum, et revelátus fúerit homo peccáti fílius perditiónis,
4 qui adversátur, et extóllitur supra omne, quod dícitur Deus, aut quod cólitur, ita ut in templo Dei sédeat osténdens se tamquam sit Deus."))
              :responsories
              ((:respond "Misericórdiam et judícium cantábo tibi, Dómine:"
                  :verse "Perambulábam in innocéntia cordis mei, in médio domus meæ."
                  :repeat "Psallam et intéllegam in via immaculáta, quando vénies ad me."
                  :gloria nil)
               (:respond "Dómine, exáudi oratiónem meam, et clamor meus ad te pervéniat:"
                  :verse "Fiant aures tuæ intendéntes in oratiónem servi tui."
                  :repeat "Quia non spernis, Deus, preces páuperum."
                  :gloria nil)
               (:respond "Velóciter exáudi me, Deus,"
                  :verse "Dies mei sicut umbra declinavérunt, et ego sicut fœnum árui."
                  :repeat "Tu autem idem ipse es, et anni tui non defícient."
                  :gloria t))))

    ;; Epi5-1: Feria II infra Hebdomadam V post Epiphaniam
    ((5 . 1) . (:lessons
              ((:source "De Epístola prima ad Timótheum"
               :ref "1 Tim 3:1-7"
               :text "1 Fidélis sermo: si quis episcopátum desíderat, bonum opus desíderat.
2 Opórtet ergo epíscopum irreprehensíbilem esse, uníus uxóris virum, sóbrium, prudéntem, ornátum, pudícum, hospitálem, doctórem,
3 non vinoléntum, non percussórem, sed modéstum: non litigiósum, non cúpidum, sed
4 suæ dómui bene præpósitum: fílios habéntem súbditos cum omni castitáte.
5 Si quis autem dómui suæ præésse nescit, quómodo ecclésiæ Dei diligéntiam habébit?
6 Non neóphytum: ne in supérbiam elátus, in judícium íncidat diáboli.
7 Opórtet autem illum et testimónium habére bonum ab iis qui foris sunt, ut non in oppróbrium íncidat, et in láqueum diáboli.")
               (:ref "1 Tim 3:8-13"
               :text "8 Diáconos simíliter pudícos, non bilíngues, non multo vino déditos, non turpe lucrum sectántes:
9 habéntes mystérium fídei in consciéntia pura.
10 Et hi autem probéntur primum: et sic minístrent, nullum crimen habéntes.
11 Mulíeres simíliter pudícas, non detrahéntes, sóbrias, fidéles in ómnibus.
12 Diáconi sint uníus uxóris viri, qui fíliis suis bene præsint, et suis dómibus.
13 Qui enim bene ministráverint, gradum bonum sibi acquírent, et multam fidúciam in fide, quæ est in Christo Jesu.")
               (:ref "1 Tim 3:14-16; 4:1"
               :text "14 Hæc tibi scribo, sperans me ad te veníre cito:
15 si autem tardávero, ut scias quómodo opórteat te in domo Dei conversári, quæ est ecclésia Dei vivi, colúmna et firmaméntum veritátis.
16 Et maniféste magnum est pietátis sacraméntum, quod manifestátum est in carne, justificátum est in spíritu, appáruit ángelis, prædicátum est géntibus, créditum est in mundo, assúmptum est in glória.
1 Spíritus autem maniféste dicit, quia in novíssimis tempóribus discédent quidam a fide, attendéntes spirítibus erróris, et doctrínis dæmoniórum."))
              :responsories
              ((:respond "Quam magna multitúdo dulcédinis tuæ, Dómine,"
                  :verse "Et perfecísti eis qui sperant in te, Dómine, in conspéctu filiórum hóminum."
                  :repeat "Quam abscondísti timéntibus te!"
                  :gloria nil)
               (:respond "Adjútor meus esto, Deus:"
                  :verse "Neque despícias me, Deus, salutáris meus."
                  :repeat "Ne derelínquas me."
                  :gloria nil)
               (:respond "Benedícam Dóminum in omni témpore:"
                  :verse "In Dómino laudábitur ánima mea, áudiant mansuéti, et læténtur."
                  :repeat "Semper laus ejus in ore meo."
                  :gloria t))))

    ;; Epi5-2: Feria III infra Hebdomadam V post Epiphaniam
    ((5 . 2) . (:lessons
              ((:source "Incipit Epístola secúnda beáti Pauli Apóstoli ad Timótheum"
               :ref "2 Tim 1:1-5"
               :text "1 Paulus Apóstolus Jesu Christi per voluntátem Dei, secúndum promissiónem vitæ, quæ est in Christo Jesu,
2 Timótheo caríssimo fílio: grátia, misericórdia, pax a Deo Patre, et Christo Jesu Dómino nostro.
3 Grátias ago Deo, cui sérvio a progenitóribus in consciéntia pura, quod sine intermissióne hábeam tui memóriam in oratiónibus meis, nocte ac die
4 desíderans te vidére, memor lacrimárum tuárum, ut gáudio ímplear,
5 recordatiónem accípiens ejus fídei, quæ est in te non ficta, quæ et habitávit primum in ávia tua Loíde, et matre tua Euníce, certus sum autem quod et in te.")
               (:ref "2 Tim 1:6-9"
               :text "6 Propter quam causam admóneo te ut resúscites grátiam Dei, quæ est in te per impositiónem mánuum meárum.
7 Non enim dedit nobis Deus spíritum timóris: sed virtútis, et dilectiónis, et sobrietátis.
8 Noli ítaque erubéscere testimónium Dómini nostri, neque me vinctum ejus: sed collabóra Evangélio secúndum virtútem Dei:
9 qui nos liberávit, et vocávit vocatióne sua sancta, non secúndum ópera nostra, sed secúndum propósitum suum, et grátiam, quæ data est nobis in Christo Jesu ante témpora sæculária.")
               (:ref "2 Tim 1:10-13"
               :text "10 Manifestáta est autem nunc per illuminatiónem Salvatóris nostri Jesu Christi, qui destrúxit quidem mortem, illuminávit autem vitam, et incorruptiónem per Evangélium:
11 in quo pósitus sum ego prædicátor, et Apóstolus, et magíster géntium.
12 Ob quam causam étiam hæc pátior, sed non confúndor. Scio enim cui crédidi, et certus sum quia potens est depósitum meum serváre in illum diem.
13 Formam habe sanórum verbórum, quæ a me audísti in fide, et in dilectióne in Christo Jesu."))
              :responsories
              ((:respond "Auribus pércipe, Deus, lácrimas meas: ne síleas a me, remítte mihi:"
                  :verse "Compláceat tibi, ut erípias me: Dómine, ad adjuvándum me festína."
                  :repeat "Quóniam íncola ego sum apud te, et peregrínus."
                  :gloria nil)
               (:respond "Státuit Dóminus supra petram pedes meos, et diréxit gressus meos Deus:"
                  :verse "Exaudívit preces meas: et edúxit me de lacu misériæ."
                  :repeat "Et misit in os meum cánticum novum."
                  :gloria nil)
               (:respond "Ego dixi, Dómine, miserére mei:"
                  :verse "Ab ómnibus iniquitátibus meis éripe me, Dómine."
                  :repeat "Sana ánimam meam, quia peccávi tibi."
                  :gloria t))))

    ;; Epi5-3: Feria IV infra Hebdomadam V post Epiphaniam
    ((5 . 3) . (:lessons
              ((:source "De Epístola secúnda ad Timótheum"
               :ref "2 Tim 3:1-5"
               :text "1 Hoc autem scito, quod in novíssimis diébus instábunt témpora periculósa:
2 erunt hómines seípsos amántes, cúpidi, eláti, supérbi, blasphémi, paréntibus non obediéntes, ingráti, scelésti,
3 sine affectióne, sine pace, criminatóres, incontinéntes, immítes, sine benignitáte,
4 proditóres, protérvi, túmidi, et voluptátum amatóres magis quam Dei:
5 habéntes spéciem quidem pietátis, virtútem autem ejus abnegántes. Et hos devíta:")
               (:ref "2 Tim 3:6-9"
               :text "6 ex his enim sunt qui pénetrant domos, et captívas ducunt muliérculas onerátas peccátis, quæ ducúntur váriis desidériis:
7 semper discéntes, et nunquam ad sciéntiam veritátis perveniéntes.
8 Quemádmodum autem Jannes et Mambres restitérunt Móysi: ita et hi resístunt veritáti, hómines corrúpti mente, réprobi circa fidem;
9 sed ultra non profícient: insipiéntia enim eórum manifésta erit ómnibus, sicut et illórum fuit.")
               (:ref "2 Tim 3:10-13"
               :text "10 Tu autem assecútus es meam doctrínam, institutiónem, propósitum, fidem, longanimitátem, dilectiónem, patiéntiam,
11 persecutiónes, passiónes: quália mihi facta sunt Antiochíæ, Icónii, et Lystris: quales persecutiónes sustínui, et ex ómnibus erípuit me Dóminus.
12 Et omnes, qui pie volunt vívere in Christo Jesu, persecutiónem patiéntur.
13 Mali autem hómines et seductóres profícient in pejus, errántes, et in errórem mitténtes."))
              :responsories
              ((:respond "Ne perdíderis me cum iniquitátibus meis:"
                  :verse "Non intres in judícium cum servo tuo, Dómine."
                  :repeat "Neque in finem irátus resérves mala mea."
                  :gloria nil)
               (:respond "Parátum cor meum, Deus, parátum cor meum:"
                  :verse "Exsúrge, glória mea, exsúrge, psaltérium et cíthara, exsúrgam dilúculo."
                  :repeat "Cantábo et psalmum dicam Dómino."
                  :gloria nil)
               (:respond "Adjútor meus, tibi psallam, quia, Deus, suscéptor meus es:"
                  :verse "Lætábor, et exsultábo in te, psallam nómini tuo, Altíssime."
                  :repeat "Deus meus, misericórdia mea."
                  :gloria t))))

    ;; Epi5-4: Feria V infra Hebdomadam V post Epiphaniam
    ((5 . 4) . (:lessons
              ((:source "Incipit Epístola beáti Pauli Apóstoli ad Titum"
               :ref "Titus 1:1-4"
               :text "1 Paulus servus Dei, Apóstolus autem Jesu Christi secúndum fidem electórum Dei, et agnitiónem veritátis, quæ secúndum pietátem est
2 in spem vitæ ætérnæ, quam promísit qui non mentítur, Deus, ante témpora sæculária:
3 manifestávit autem tempóribus suis verbum suum in prædicatióne, quæ crédita est mihi secúndum præcéptum Salvatóris nostri Dei:
4 Tito dilécto fílio secúndum commúnem fidem, grátia, et pax a Deo Patre, et Christo Jesu Salvatóre nostro.")
               (:ref "Titus 1:5-9"
               :text "5 Hujus rei grátia relíqui te Cretæ, ut ea quæ desunt, córrigas, et constítuas per civitátes presbýteros, sicut et ego dispósui tibi,
6 si quis sine crímine est, uníus uxóris vir, fílios habens fidéles, non in accusatióne luxúriæ, aut non súbditos.
7 Opórtet enim epíscopum sine crímine esse, sicut Dei dispensatórem: non supérbum, non iracúndum, non vinoléntum, non percussórem, non turpis lucri cúpidum:
8 sed hospitálem, benígnum, sóbrium, justum, sanctum, continéntem,
9 amplecténtem eum, qui secúndum doctrínam est, fidélem sermónem: ut potens sit exhortári in doctrína sana, et eos qui contradícunt, argúere.")
               (:ref "Titus 1:10-15"
               :text "10 Sunt enim multi étiam inobediéntes, vaníloqui, et seductóres: máxime qui de circumcisióne sunt:
11 quos opórtet redárgui: qui univérsas domos subvértunt, docéntes quæ non opórtet, turpis lucri grátia.
12 Dixit quidam ex illis, próprius ipsórum prophéta: Creténses semper mendáces, malæ béstiæ, ventres pigri.
13 Testimónium hoc verum est. Quam ob causam íncrepa illos dure, ut sani sint in fide,
14 non intendéntes Judáicis fábulis, et mandátis hóminum, aversántium se a veritáte.
15 Omnia munda mundis: coinquinátis autem et infidélibus, nihil est mundum."))
              :responsories
              ((:respond "Deus, in te sperávi, Dómine, non confúndar in ætérnum: in justítia tua líbera me,"
                  :verse "Inclína ad me aurem tuam, et salva me."
                  :repeat "Et éripe me."
                  :gloria nil)
               (:respond "Repleátur os meum laude tua, ut hymnum dicam glóriæ tuæ, tota die magnitúdinem tuam: noli me proícere in témpore senectútis:"
                  :verse "Gaudébunt lábia mea cum cantávero tibi."
                  :repeat "Dum defécerit in me virtus mea, ne derelínquas me."
                  :gloria nil)
               (:respond "Gaudébunt lábia mea cum cantávero tibi:"
                  :verse "Sed et lingua mea meditábitur justítiam tuam, tota die laudem tuam."
                  :repeat "Et ánima mea, quam redemísti, Dómine."
                  :gloria t))))

    ;; Epi5-5: Feria VI infra Hebdomadam V post Epiphaniam
    ((5 . 5) . (:lessons
              ((:source "De epístola ad Titum"
               :ref "Titus 2:15; 3:1-2"
               :text "15 Hæc lóquere, et exhortáre, et árgue cum omni império. Nemo te contémnat.
1 Admone illos princípibus, et potestátibus súbditos esse, dicto obedíre, ad omne opus bonum parátos esse:
2 néminem blasphemáre, non litigiósos esse, sed modéstos, omnem ostendéntes mansuetúdinem ad omnes hómines.")
               (:ref "Titus 3:3-7"
               :text "3 Erámus enim aliquándo et nos insipiéntes, incréduli, errántes, serviéntes desidériis, et voluptátibus váriis, in malítia et invídia agéntes, odíbiles, odiéntes ínvicem.
4 Cum autem benígnitas et humánitas appáruit Salvatóris nostri Dei,
5 non ex opéribus justítiæ, quæ fécimus nos, sed secúndum suam misericórdiam salvos nos fecit per lavácrum regeneratiónis et renovatiónis Spíritus Sancti,
6 quem effúdit in nos abúnde per Jesum Christum Salvatórem nostrum:
7 ut justificáti grátia ipsíus, hærédes simus secúndum spem vitæ ætérnæ.")
               (:ref "Titus 3:8-11"
               :text "8 Fidélis sermo est: et de his volo te confirmáre: ut curent bonis opéribus præésse qui credunt Deo. Hæc sunt bona, et utília homínibus.
9 Stultas autem quæstiónes, et genealógias, et contentiónes, et pugnas legis devíta: sunt enim inútiles, et vanæ.
10 Hæréticum hóminem post unam et secúndam correptiónem devíta:
11 sciens quia subvérsus est, qui ejúsmodi est, et delínquit, cum sit próprio judício condemnátus."))
              :responsories
              ((:respond "Confitébor tibi, Dómine Deus, in toto corde meo, et honorificábo nomen tuum in ætérnum:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "Quia misericórdia tua, Dómine, magna est super me."
                  :gloria nil)
               (:respond "Misericórdia tua, Dómine, magna est super me:"
                  :verse "In die tribulatiónis meæ clamávi ad te, quia exaudísti me."
                  :repeat "Et liberásti ánimam meam ex inférno inferióri."
                  :gloria nil)
               (:respond "Factus est mihi Dóminus in refúgium:"
                  :verse "Erípuit me de inimícis meis fortíssimis, et factus est Dóminus protéctor meus."
                  :repeat "Et Deus meus in auxílium spei meæ."
                  :gloria t))))

    ;; Epi5-6: Sabbato infra Hebdomadam V post Epiphaniam
    ((5 . 6) . (:lessons
              ((:source "Incipit epístola beáti Pauli Apóstoli ad Philémonem"
               :ref "Phlm 1:1-6"
               :text "1 Paulus vinctus Christi Jesu, et Timótheus frater, Philémoni dilécto, et adjutóri nostro,
2 et Appíæ soróri caríssimæ, et Archíppo commilitóni nostro, et ecclésiæ, quæ in domo tua est.
3 Grátia vobis, et pax a Deo Patre nostro, et Dómino Jesu Christo.
4 Grátias ago Deo meo, semper memóriam tui fáciens in oratiónibus meis,
5 áudiens caritátem tuam, et fidem, quam habes in Dómino Jesu, et in omnes sanctos:
6 ut communicátio fídei tuæ évidens fiat in agnitióne omnis óperis boni, quod est in vobis in Christo Jesu.")
               (:ref "Phlm 1:7-11"
               :text "7 Gáudium enim magnum hábui, et consolatiónem in caritáte tua: quia víscera sanctórum requievérunt per te, frater.
8 Propter quod multam fidúciam habens in Christo Jesu imperándi tibi quod ad rem pértinet:
9 propter caritátem magis óbsecro, cum sis talis, ut Paulus senex, nunc autem et vinctus Jesu Christi:
10 óbsecro te pro meo fílio, quem génui in vínculis, Onésimo,
11 qui tibi aliquándo inútilis fuit, nunc autem et mihi et tibi útilis,")
               (:ref "Phlm 1:12-19"
               :text "12 quem remísi tibi. Tu autem illum, ut mea víscera, súscipe:
13 quem ego volúeram mecum detinére, ut pro te mihi ministráret in vínculis Evangélii:
14 sine consílio autem tuo nihil vólui fácere, uti ne velut ex necessitáte bonum tuum esset, sed voluntárium.
15 Fórsitan enim ídeo discéssit ad horam a te, ut ætérnum illum recíperes:
16 jam non ut servum, sed pro servo caríssimum fratrem, máxime mihi: quanto autem magis tibi et in carne, et in Dómino?
17 Si ergo habes me sócium, súscipe illum sicut me:
18 si autem áliquid nócuit tibi, aut debet, hoc mihi ímputa.
19 Ego Paulus scripsi mea manu."))
              :responsories
              ((:respond "Misericórdiam et judícium cantábo tibi, Dómine:"
                  :verse "Perambulábam in innocéntia cordis mei, in médio domus meæ."
                  :repeat "Psallam et intéllegam in via immaculáta, quando vénies ad me."
                  :gloria nil)
               (:respond "Dómine, exáudi oratiónem meam, et clamor meus ad te pervéniat:"
                  :verse "Fiant aures tuæ intendéntes in oratiónem servi tui."
                  :repeat "Quia non spernis, Deus, preces páuperum."
                  :gloria nil)
               (:respond "Velóciter exáudi me, Deus,"
                  :verse "Dies mei sicut umbra declinavérunt, et ego sicut fœnum árui."
                  :repeat "Tu autem idem ipse es, et anni tui non defícient."
                  :gloria t))))

    ;; Epi6-1: Feria II infra Hebdomadam VI post Epiphaniam
    ((6 . 1) . (:lessons
              ((:source "De Epístola ad Hebrǽos"
               :ref "Heb 3:1-4"
               :text "1 Unde, fratres sancti, vocatiónis cæléstis partícipes, consideráte Apóstolum, et pontíficem confessiónis nostræ Jesum:
2 qui fidélis est ei, qui fecit illum, sicut et Móyses in omni domo ejus.
3 Amplióris enim glóriæ iste præ Móyse dignus est hábitus, quanto ampliórem honórem habet domus, qui fabricávit illam.
4 Omnis namque domus fabricátur ab áliquo: qui autem ómnia creávit, Deus est.")
               (:ref "Heb 3:5-8"
               :text "5 Et Móyses quidem fidélis erat in tota domo ejus tamquam fámulus, in testimónium eórum, quæ dicénda erant:
6 Christus vero tamquam fílius in domo sua: quæ domus sumus nos, si fidúciam, et glóriam spei usque ad finem, firmam retineámus.
7 Quaprópter sicut dicit Spíritus Sanctus: Hódie si vocem ejus audiéritis,
8 nolíte obduráre corda vestra, sicut in exacerbatióne secúndum diem tentatiónis in desérto.")
               (:ref "Heb 3:12-16"
               :text "12 Vidéte fratres, ne forte sit in áliquo vestrum cor malum incredulitátis, discedéndi a Deo vivo:
13 sed adhortámini vosmetípsos per síngulos dies, donec hódie cognominátur, ut non obdurétur quis ex vobis fallácia peccáti.
14 Partícipes enim Christi effécti sumus, si tamen inítium substántiæ ejus usque ad finem firmum retineámus.
15 Dum dícitur: Hódie si vocem ejus audiéritis, nolíte obduráre corda vestra, quemádmodum in illa exacerbatióne.
16 Quidam enim audiéntes exacerbavérunt: sed non univérsi qui profécti sunt ex Ægýpto per Móysen."))
              :responsories
              ((:respond "Quam magna multitúdo dulcédinis tuæ, Dómine,"
                  :verse "Et perfecísti eis qui sperant in te, Dómine, in conspéctu filiórum hóminum."
                  :repeat "Quam abscondísti timéntibus te!"
                  :gloria nil)
               (:respond "Adjútor meus esto, Deus:"
                  :verse "Neque despícias me, Deus, salutáris meus."
                  :repeat "Ne derelínquas me."
                  :gloria nil)
               (:respond "Benedícam Dóminum in omni témpore:"
                  :verse "In Dómino laudábitur ánima mea, áudiant mansuéti, et læténtur."
                  :repeat "Semper laus ejus in ore meo."
                  :gloria t))))

    ;; Epi6-2: Feria III infra Hebdomadam VI post Epiphaniam
    ((6 . 2) . (:lessons
              ((:source "De Epístola ad Hebrǽos"
               :ref "Heb 4:1-3"
               :text "1 Timeámus ergo ne forte relícta pollicitatióne introeúndi in réquiem ejus, existimétur áliquis ex vobis deésse.
2 Etenim et nobis nuntiátum est, quemádmodum et illis: sed non prófuit illis sermo audítus, non admístus fídei ex iis quæ audiérunt.
3 Ingrediémur enim in réquiem, qui credídimus: quemádmodum dixit: Sicut jurávi in ira mea: Si introíbunt in réquiem meam: et quidem opéribus ab institutióne mundi perféctis.")
               (:ref "Heb 4:4-7"
               :text "4 Dixit enim in quodam loco de die séptima sic: Et requiévit Deus die séptima ab ómnibus opéribus suis.
5 Et in isto rursum: Si introíbunt in réquiem meam.
6 Quóniam ergo súperest introíre quosdam in illam, et ii, quibus prióribus annuntiátum est, non introiérunt propter incredulitátem:
7 íterum términat diem quemdam, Hódie, in David dicéndo, post tantum témporis, sicut supra dictum est: Hódie si vocem ejus audiéritis, nolíte obduráre corda vestra.")
               (:ref "Heb 4:8-12"
               :text "8 Nam si eis Jesus réquiem præstitísset, numquam de ália loquerétur, posthac, die.
9 Itaque relínquitur sabbatísmus pópulo Dei.
10 Qui enim ingréssus est in réquiem ejus, étiam ipse requiévit ab opéribus suis, sicut a suis Deus.
11 Festinémus ergo íngredi in illam réquiem: ut ne in idípsum quis íncidat incredulitátis exémplum.
12 Vivus est enim sermo Dei, et éfficax et penetrabílior omni gládio ancípiti: et pertíngens usque ad divisiónem ánimæ ac spíritus: compágum quoque ac medullárum, et discrétor cogitatiónum et intentiónum cordis."))
              :responsories
              ((:respond "Auribus pércipe, Deus, lácrimas meas: ne síleas a me, remítte mihi:"
                  :verse "Compláceat tibi, ut erípias me: Dómine, ad adjuvándum me festína."
                  :repeat "Quóniam íncola ego sum apud te, et peregrínus."
                  :gloria nil)
               (:respond "Adjútor meus esto, Deus:"
                  :verse "Neque despícias me, Deus, salutáris meus."
                  :repeat "Ne derelínquas me."
                  :gloria nil)
               (:respond "Benedícam Dóminum in omni témpore:"
                  :verse "In Dómino laudábitur ánima mea, áudiant mansuéti, et læténtur."
                  :repeat "Semper laus ejus in ore meo."
                  :gloria t))))

    ;; Epi6-3: Feria IV infra Hebdomadam VI post Epiphaniam
    ((6 . 3) . (:lessons
              ((:source "De Epístola ad Hebrǽos"
               :ref "Heb 6:1-3"
               :text "1 Quaprópter intermitténtes inchoatiónis Christi sermónem, ad perfectióra ferámur, non rursum jaciéntes fundaméntum pœniténtiæ ab opéribus mórtuis, et fídei ad Deum,
2 baptísmatum doctrínæ, impositiónis quoque mánuum, ac resurrectiónis mortuórum, et judícii ætérni.
3 Et hoc faciémus, si quidem permíserit Deus.")
               (:ref "Heb 6:4-6"
               :text "4 Impossíbile est enim eos qui semel sunt illumináti, gustavérunt étiam donum cæléste, et partícipes facti sunt Spíritus Sancti,
5 gustavérunt nihilóminus bonum Dei verbum, virtutésque sǽculi ventúri,
6 et prolápsi sunt; rursus renovári ad pœniténtiam, rursum crucifigéntes sibimetípsis Fílium Dei, et osténtui habéntes.")
               (:ref "Heb 6:7-10"
               :text "7 Terra enim sæpe veniéntem super se bibens imbrem, et génerans herbam opportúnam illis, a quibus cólitur, áccipit benedictiónem a Deo:
8 próferens autem spinas ac tríbulos, réproba est, et maledícto próxima: cujus consummátio in combustiónem.
9 Confídimus autem de vobis dilectíssimi melióra, et vicinióra salúti: tamétsi ita lóquimur.
10 Non enim injústus Deus, ut obliviscátur óperis vestri, et dilectiónis, quam ostendístis in nómine ipsíus, qui ministrástis sanctis, et ministrátis."))
              :responsories
              ((:respond "Ne perdíderis me cum iniquitátibus meis:"
                  :verse "Non intres in judícium cum servo tuo, Dómine."
                  :repeat "Neque in finem irátus resérves mala mea."
                  :gloria nil)
               (:respond "Parátum cor meum, Deus, parátum cor meum:"
                  :verse "Exsúrge, glória mea, exsúrge, psaltérium et cíthara, exsúrgam dilúculo."
                  :repeat "Cantábo et psalmum dicam Dómino."
                  :gloria nil)
               (:respond "Adjútor meus, tibi psallam, quia, Deus, suscéptor meus es:"
                  :verse "Lætábor, et exsultábo in te, psallam nómini tuo, Altíssime."
                  :repeat "Deus meus, misericórdia mea."
                  :gloria t))))

    ;; Epi6-4: Feria V infra Hebdomadam VI post Epiphaniam
    ((6 . 4) . (:lessons
              ((:source "De Epístola ad Hebrǽos"
               :ref "Heb 7:1-3"
               :text "1 Hic enim Melchísedech, rex Salem, sacérdos Dei summi, qui obviávit Abrahæ regrésso a cæde regum, et benedíxit ei:
2 cui et décimas ómnium divísit Abraham: primum quidem qui interpretátur rex justítiæ: deínde autem et rex Salem, quod est, rex pacis,
3 sine patre, sine matre, sine genealógia, neque inítium diérum, neque finem vitæ habens, assimilátus autem Fílio Dei, manet sacérdos in perpétuum.")
               (:ref "Heb 7:4-6"
               :text "4 Intuémini autem quantus sit hic, cui et décimas dedit de præcípuis Abraham patriárcha.
5 Et quidem de fíliis Levi sacerdótium accipiéntes, mandátum habent décimas súmere a pópulo secúndum legem, id est, a frátribus suis: quamquam et ipsi exíerint de lumbis Abrahæ.
6 Cujus autem generátio non annumerátur in eis, décimas sumpsit ab Abraham, et hunc, qui habébat repromissiónes, benedíxit.")
               (:ref "Heb 7:7-12"
               :text "7 Sine ulla autem contradictióne, quod minus est, a melióre benedícitur.
8 Et hic quidem, décimas moriéntes hómines accípiunt: ibi autem contestátur, quia vivit.
9 Et (ut ita dictum sit) per Abraham, et Levi, qui décimas accépit, decimátus est:
10 adhuc enim in lumbis patris erat, quando obviávit ei Melchísedech.
11 Si ergo consummátio per sacerdótium Levíticum erat (pópulus enim sub ipso legem accépit) quid adhuc necessárium fuit secúndum órdinem Melchísedech, álium súrgere sacerdótem, et non secúndum órdinem Aaron dici?
12 Transláto enim sacerdótio, necésse est ut et legis translátio fiat."))
              :responsories
              ((:respond "Deus, in te sperávi, Dómine, non confúndar in ætérnum: in justítia tua líbera me,"
                  :verse "Inclína ad me aurem tuam, et salva me."
                  :repeat "Et éripe me."
                  :gloria nil)
               (:respond "Repleátur os meum laude tua, ut hymnum dicam glóriæ tuæ, tota die magnitúdinem tuam: noli me proícere in témpore senectútis:"
                  :verse "Gaudébunt lábia mea cum cantávero tibi."
                  :repeat "Dum defécerit in me virtus mea, ne derelínquas me."
                  :gloria nil)
               (:respond "Gaudébunt lábia mea cum cantávero tibi:"
                  :verse "Sed et lingua mea meditábitur justítiam tuam, tota die laudem tuam."
                  :repeat "Et ánima mea, quam redemísti, Dómine."
                  :gloria t))))

    ;; Epi6-5: Feria VI infra Hebdomadam VI post Epiphaniam
    ((6 . 5) . (:lessons
              ((:source "De Epístola ad Hebrǽos"
               :ref "Heb 11:1-4"
               :text "1 Est autem fides sperandárum substántia rerum, arguméntum non apparéntium.
2 In hac enim testimónium consecúti sunt senes.
3 Fide intellígimus aptáta esse sǽcula verbo Dei: ut ex invisibílibus visibília fíerent.
4 Fide plúrimam hóstiam Abel, quam Cain, óbtulit Deo, per quam testimónium consecútus est esse justus, testimónium perhibénte munéribus ejus Deo, et per illam defúnctus adhuc lóquitur.")
               (:ref "Heb 11:5-7"
               :text "5 Fide Henoch translátus est ne vidéret mortem, et non inveniebátur, quia tránstulit illum Deus: ante translatiónem enim testimónium hábuit placuísse Deo.
6 Sine fide autem impossíbile est placére Deo. Crédere enim opórtet accedéntem ad Deum quia est, et inquiréntibus se remunerátor sit.
7 Fide Noe respónso accépto de iis quæ adhuc non videbántur, métuens aptávit arcam in salútem domus suæ, per quam damnávit mundum: et justítiæ, quæ per fidem est, hæres est institútus.")
               (:ref "Heb 11:8-10"
               :text "8 Fide qui vocátur Abraham obedívit in locum exíre, quem acceptúrus erat in hæreditátem: et éxiit, nésciens quo iret.
9 Fide demorátus est in terra repromissiónis, tamquam in aliéna, in cásulis habitándo cum Isaac et Jacob cohærédibus repromissiónis ejúsdem.
10 Exspectábat enim fundaménta habéntem civitátem: cujus ártifex et cónditor Deus."))
              :responsories
              ((:respond "Confitébor tibi, Dómine Deus, in toto corde meo, et honorificábo nomen tuum in ætérnum:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "Quia misericórdia tua, Dómine, magna est super me."
                  :gloria nil)
               (:respond "Misericórdia tua, Dómine, magna est super me:"
                  :verse "In die tribulatiónis meæ clamávi ad te, quia exaudísti me."
                  :repeat "Et liberásti ánimam meam ex inférno inferióri."
                  :gloria nil)
               (:respond "Factus est mihi Dóminus in refúgium:"
                  :verse "Erípuit me de inimícis meis fortíssimis, et factus est Dóminus protéctor meus."
                  :repeat "Et Deus meus in auxílium spei meæ."
                  :gloria t))))

    ;; Epi6-6: Sabbato infra Hebdomadam VI post Epiphaniam
    ((6 . 6) . (:lessons
              ((:source "De Epístola ad Hebrǽos"
               :ref "Heb 13:1-4"
               :text "1 Cáritas fraternitátis máneat in vobis,
2 et hospitalitátem nolíte oblivísci: per hanc enim latuérunt quidam, ángelis hospítio recéptis.
3 Mementóte vinctórum, tamquam simul vincti: et laborántium, tamquam et ipsi in córpore morántes.
4 Honorábile connúbium in ómnibus, et thorus immaculátus. Fornicatóres enim, et adúlteros judicábit Deus.")
               (:ref "Heb 13:5-8"
               :text "5 Sint mores sine avarítia, conténti præséntibus: ipse enim dixit: Non te déseram, neque derelínquam:
6 ita ut confidénter dicámus: Dóminus mihi adjútor: non timébo quid fáciat mihi homo.
7 Mementóte præpositórum vestrórum, qui vobis locúti sunt verbum Dei: quorum intuéntes éxitum conversatiónis, imitámini fidem.
8 Jesus Christus heri, et hódie: ipse et in sǽcula.")
               (:ref "Heb 13:9-12"
               :text "9 Doctrínis váriis et peregrínis nolíte abdúci. Optimum est enim grátia stabilíre cor, non escis: quæ non profuérunt ambulántibus in eis.
10 Habémus altáre, de quo édere non habent potestátem, qui tabernáculo desérviunt.
11 Quorum enim animálium infértur sanguis pro peccáto in Sancta per pontíficem, horum córpora cremántur extra castra.
12 Propter quod et Jesus, ut sanctificáret per suum sánguinem pópulum, extra portam passus est."))
              :responsories
              ((:respond "Misericórdiam et judícium cantábo tibi, Dómine:"
                  :verse "Perambulábam in innocéntia cordis mei, in médio domus meæ."
                  :repeat "Psallam et intéllegam in via immaculáta, quando vénies ad me."
                  :gloria nil)
               (:respond "Dómine, exáudi oratiónem meam, et clamor meus ad te pervéniat:"
                  :verse "Fiant aures tuæ intendéntes in oratiónem servi tui."
                  :repeat "Quia non spernis, Deus, preces páuperum."
                  :gloria nil)
               (:respond "Velóciter exáudi me, Deus,"
                  :verse "Dies mei sicut umbra declinavérunt, et ego sicut fœnum árui."
                  :repeat "Tu autem idem ipse es, et anni tui non defícient."
                  :gloria t))))
    )
  "Christmastide ferial Matins data for post-Epiphany weeks.
Keyed by (WEEK . DOW): Epi1-6, DOW 1=Mon..6=Sat.")

(defun bcp-roman-season-christmas--ferial-key (date)
  "Return the ferial Matins lookup key for DATE, or nil.
DATE is (MONTH DAY YEAR).  Returns either:
  - (MONTH . DAY) for fixed-date period (Dec 29-31, Jan 2-12)
  - (WEEK . DOW) for post-Epiphany weeks (Epi1-6)
  - nil for Sundays, feast days, or out-of-range dates.

Feast exclusions: Dec 25-28, Jan 1, Jan 6."
  (let* ((month (car date))
         (day (cadr date))
         (year (caddr date))
         (abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date)))
    ;; Skip Sundays
    (when (/= dow 0)
      (cond
       ;; Dec 29-31
       ((and (= month 12) (>= day 29))
        (cons 12 day))
       ;; Jan 2-5 (Jan 1 = Circumcision, excluded)
       ((and (= month 1) (>= day 2) (<= day 5))
        (cons 1 day))
       ;; Jan 7-12 (Jan 6 = Epiphany, excluded)
       ((and (= month 1) (>= day 7) (<= day 12))
        (cons 1 day))
       ;; Post-Epiphany weeks: first Mon after Jan 13
       ((or (and (= month 1) (> day 12))
            (= month 2))
        (let* ((epi-abs (calendar-absolute-from-gregorian (list 1 6 year)))
               ;; First Monday after Epiphany octave (Jan 13)
               (epi-oct-end (+ epi-abs 7)) ; Jan 13
               (first-mon (+ epi-oct-end (% (- 8 (calendar-day-of-week
                                                    (calendar-gregorian-from-absolute
                                                     epi-oct-end)))
                                             7)))
               (week (1+ (/ (- abs first-mon) 7)))
               (epi-dow (calendar-day-of-week date)))
          (when (and (>= abs first-mon)
                     (<= week 6)
                     (>= epi-dow 1)
                     (<= epi-dow 6))
            (cons week epi-dow))))))))

(defun bcp-roman-season-christmas-ferial-matins (date)
  "Return ferial Matins data for Christmastide DATE, or nil.
Returns a plist (:lessons (L1 L2 L3) :responsories (R1 R2 R3))."
  (let ((key (bcp-roman-season-christmas--ferial-key date)))
    (when key
      (or (cdr (assoc key bcp-roman-season-christmas--ferial-matins-fixed))
          (cdr (assoc key bcp-roman-season-christmas--ferial-matins-weekly))))))


(provide 'bcp-roman-season-christmas)

;;; bcp-roman-season-christmas.el ends here
