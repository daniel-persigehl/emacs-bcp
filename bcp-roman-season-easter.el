;;; bcp-roman-season-easter.el --- Eastertide Proper of the Time -*- lexical-binding: t -*-

;;; Commentary:

;; Proper of the Time data for the Eastertide season (DA 1911 rubrics).
;; Covers Easter 0 (Easter Sunday) through Easter 7 (Pentecost), providing
;; collects, dominical Matins data, and non-Matins hour data (antiphons,
;; capitula) for all 8 Sundays.
;;
;; Easter 1–6: standard 3-nocturn offices (9 lessons, 8 responsories).
;; Easter 0 (Easter Sunday) and Easter 7 (Pentecost): special 1-nocturn
;; offices (3 lessons, 2 responsories + Te Deum) with proper psalms,
;; antiphons, invitatory, hymn, and versicle.
;;
;; Antiphons and capitula are registered in antiphonary/capitulary and
;; referenced by symbol in the alist entries.
;;
;; Lesson structure follows `bcp-roman-tempora.el' Per Annum pattern:
;;   Nocturn I  (L1-L3): Scripture with :ref, :source, :text
;;   Nocturn II (L4-L6): Patristic with :ref, :source, :text
;;   Nocturn III (L7-L9): Homily with :ref, :source, :text
;;
;; Data extracted from Divinum Officium Latin Tempora files.
;;
;; Key public functions:
;;   `bcp-roman-season-easter-collect'           — Eastertide Sunday collect incipit
;;   `bcp-roman-season-easter-dominical-matins'  — Eastertide dominical Matins data

;;; Code:

(require 'bcp-common-roman)
(require 'bcp-roman-collectarium)
(require 'bcp-roman-antiphonary)
(require 'bcp-roman-capitulary)
(require 'bcp-calendar)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Eastertide Sunday collects (Easter 0–8)

;;; ─── Easter 0: Easter Sunday ───────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-hodierna-die-per-unigenitum
 (list :latin (concat
              "Deus, qui hodiérna die per Unigénitum tuum ætérnitátis nobis \
áditum devícta morte reserásti: vota nostra, quæ præveniéndo aspíras, \
étiam adjuvándo proséquere.\n"
              bcp-roman-per-eumdem)
       :conclusion 'per-eumdem
       :translations
       '((do . "God, who on this day, through thy Only-begotten Son, overcame \
death, and opened to us the gate of everlasting life: as by thy anticipating \
grace, thou breathest good desires into our hearts, so also, by thy gracious \
help, bring them to good effect.\nThrough the same Lord."))))

;;; ─── Easter 1: Low Sunday ──────────────────────────────────────────────

(bcp-roman-collectarium-register
 'praesta-quaesumus-omnipotens-deus-ut-qui-paschalia
 (list :latin (concat
              "Præsta, quǽsumus, omnípotens Deus: ut qui paschália festa \
perégimus, hæc, te largiénte, móribus et vita teneámus.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech thee, almighty God, that we who have \
celebrated the Paschal Feast, may, by thy bounty, retain its fruits in our \
daily habits and behaviour.\nThrough our Lord."))))

;;; ─── Easter 2: Second Sunday after Easter ──────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-in-filii-tui-humilitate
 (list :latin (concat
              "Deus, qui in Fílii tui humilitáte jacéntem mundum erexísti: \
fidélibus tuis perpétuam concéde lætítiam; ut, quos perpétuæ mortis \
eripuísti cásibus, gáudiis fácias pérfrui sempitérnis.\n"
              bcp-roman-per-eumdem)
       :conclusion 'per-eumdem
       :translations
       '((do . "O God, whose Son hath humbled himself, and who hast through \
him raised up the whole world, grant to thy faithful people everlasting joy; \
and as thou hast delivered them from the bitter pains of eternal death, make \
them to be glad for ever in thy presence.\nThrough the same Lord."))))

;;; ─── Easter 3: Third Sunday after Easter ───────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-errantibus
 (list :latin (concat
              "Deus, qui errántibus, ut in viam possint redíre justítiæ, \
veritátis tuæ lumen osténdis: da cunctis, qui christiána professióne \
censéntur, et illa respúere, quæ huic inimíca sunt nómini; et ea, quæ \
sunt apta, sectári.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty God, who showest to them that be in error the light \
of thy truth, to the intent that they may return into the way of \
righteousness, grant unto all them that are admitted into the fellowship of \
Christ's Religion, that they may eschew those things that are contrary to \
their profession, and follow all such things as are agreeable to the same.\n\
Through our Lord."))))

;;; ─── Easter 4: Fourth Sunday after Easter ──────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-fidelium-mentes
 (list :latin (concat
              "Deus, qui fidélium mentes uníus éfficis voluntátis: da pópulis \
tuis id amáre quod prǽcipis, id desideráre quod promíttis; ut inter \
mundánas varietátes ibi nostra fixa sint corda, ubi vera sunt gáudia.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, of whom it cometh that the minds of thy faithful \
people be all of one will, grant unto the same thy people that they may love \
the thing which thou commandest, and desire that which thou dost promise, \
that so, amid the sundry and manifold changes of the world, our hearts may \
surely there be fixed, where true joys are to be found.\nThrough our Lord."))))

;;; ─── Easter 5: Fifth Sunday after Easter / Rogation Sunday ─────────────

(bcp-roman-collectarium-register
 'deus-a-quo-bona-cuncta
 (list :latin (concat
              "Deus, a quo bona cuncta procédunt, largíre supplícibus tuis: \
ut cogitémus, te inspiránte, quæ recta sunt; et, te gubernánte, éadem \
faciámus.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, from whom all good things do come, grant to us thy \
humble servants that by thy holy inspiration we may think those things that \
be good, and by thy merciful guiding may perform the same.\nThrough our Lord."))))

;;; ─── Easter 6: Sunday after Ascension ──────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-fac-nos
 (list :latin (concat
              "Omnípotens sempitérne Deus: fac nos tibi semper et devótam \
gérere voluntátem; et majestáti tuæ sincéro corde servíre.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O Almighty and everlasting God, grant that our will be ever \
meekly subject unto thy will, and our heart ever honestly ready to serve thy \
majesty.\nThrough our Lord."))))

;;; ─── Easter 7: Pentecost ───────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-hodierna-die-corda-fidelium
 (list :latin (concat
              "Deus, qui hodiérna die corda fidélium Sancti Spíritus \
illustratióne docuísti: da nobis in eódem Spíritu recta sápere; et de \
ejus semper consolatióne gaudére.\n"
              bcp-roman-per-dominum-eiusdem)
       :conclusion 'per-dominum-eiusdem
       :translations
       '((do . "O God, who on this day didst teach the hearts of thy faithful \
people, by the sending to them the light of thine Holy Spirit, grant us by \
the same Spirit to have a right judgment in all things, and evermore to \
rejoice in his holy comfort.\nThrough our Lord."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Collect vector (0-indexed by Easter week)

(defconst bcp-roman-season-easter--collects
  [deus-qui-hodierna-die-per-unigenitum             ; Easter 0 — Easter Sunday
   praesta-quaesumus-omnipotens-deus-ut-qui-paschalia ; Easter 1 — Low Sunday
   deus-qui-in-filii-tui-humilitate                 ; Easter 2
   deus-qui-errantibus                              ; Easter 3
   deus-qui-fidelium-mentes                         ; Easter 4
   deus-a-quo-bona-cuncta                           ; Easter 5 — Rogation Sunday
   omnipotens-sempiterne-deus-fac-nos               ; Easter 6 — after Ascension
   deus-qui-hodierna-die-corda-fidelium]            ; Easter 7 — Pentecost
  "Eastertide Sunday collect incipits, 0-indexed by Easter week number.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Eastertide antiphon registrations

;;; ─── Easter 0 antiphons ──────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'vespere-autem-sabbati
 '(:latin "Véspere autem sábbati * quæ lucéscit in prima sábbati, venit María Magdaléne, et áltera María, vidére sepúlcrum, allelúja."
   :translations
   ((do . "And in the end of the sabbath * when it began to dawn towards the first day of the week, came Mary Magdalen and the other Mary, to see the sepulchre, alleluia."))))

(bcp-roman-antiphonary-register
 'et-valde-mane
 '(:latin "Et valde mane * una sabbatórum véniunt ad monuméntum, orto jam sole, allelúja."
   :translations
   ((do . "And very early in the morning * the first day of the week, they come to the sepulchre, the sun being now risen, alleluia."))))

(bcp-roman-antiphonary-register
 'et-respicientes
 '(:latin "Et respiciéntes * vidérunt revolútum lápidem: erat quippe magnus valde, allelúja."
   :translations
   ((do . "And looking * they saw the stone rolled back, for it was very great, alleluia."))))

(bcp-roman-antiphonary-register
 'angelus-autem-domini-descendit
 '(:latin "Angelus autem Dómini * descéndit de cælo, et accédens revólvit lápidem, et sedébat super eum, allelúja, allelúja."
   :translations
   ((do . "For an angel of the Lord * descended from heaven and coming rolled back the stone and sat upon it, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'et-ecce-terraemotus
 '(:latin "Et ecce terræmótus * factus est magnus: Angelus enim Dómini descéndit de cælo, allelúja."
   :translations
   ((do . "There was a great earthquake; * For an angel of the Lord descended from heaven, alleluia."))))

(bcp-roman-antiphonary-register
 'erat-autem-aspectus
 '(:latin "Erat autem * aspéctus ejus sicut fulgur, vestiménta autem ejus sicut nix, allelúja, allelúja."
   :translations
   ((do . "And his countenance * was as lightning and his raiment as snow, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'prae-timore-autem
 '(:latin "Præ timóre autem ejus * extérriti sunt custódes, et facti sunt velut mórtui, allelúja."
   :translations
   ((do . "And for fear of him * the guards were struck with terror and became as dead men, alleluia."))))

(bcp-roman-antiphonary-register
 'respondens-autem-angelus
 '(:latin "Respóndens autem Angelus, * dixit muliéribus: Nolíte timére: scio enim quod Jesum quǽritis, allelúja."
   :translations
   ((do . "And the angel answering * said to the women: Fear not you: for I know that you seek Jesus, alleluia."))))

;;; ─── Easter 1 antiphons ──────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'cum-esset-sero
 '(:latin "Cum esset sero * die illa una sabbatórum, et fores essent clausæ, ubi erant discípuli congregáti in unum, stetit Jesus in médio, et dixit eis: Pax vobis, allelúja."
   :translations
   ((do . "Now when it was late * the same day, the first of the week, and the doors were shut, where the disciples were gathered together, for fear of the Jews, Jesus came and stood in the midst and said to them: Peace be to you, alleluia."))))

(bcp-roman-antiphonary-register
 'post-dies-octo
 '(:latin "Post dies octo * jánuis clausis ingréssus Dóminus dixit eis: Pax vobis, allelúja, allelúja."
   :translations
   ((do . "After eight days * came the Lord, the doors being shut, and said unto them: Peace be unto you, alleluia, alleluia."))))

;;; ─── Easter 2 antiphons ──────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'ego-sum-pastor-ovium
 '(:latin "Ego sum pastor óvium: * ego sum via, véritas, et vita: ego sum pastor bonus, et cognósco oves meas, et cognóscunt me meæ, allelúja, allelúja."
   :translations
   ((do . "I am the Shepherd of the Sheep: * I am the Way, the Truth, and the Life: I am the Good Shepherd, and know My Sheep, and am known of Mine. Alleluia, Alleluia."))))

(bcp-roman-antiphonary-register
 'ego-sum-pastor-bonus
 '(:latin "Ego sum pastor bonus, * qui pasco oves meas, et pro óvibus meis pono ánimam meam, allelúja."
   :translations
   ((do . "I am the Good Shepherd, * Who feed My sheep: and I lay down My life for My sheep. Alleluia."))))

;;; ─── Easter 3 antiphons ──────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'modicum-et-non-videbitis
 '(:latin "Módicum * et non vidébitis me, dicit Dóminus: íterum módicum, et vidébitis me, quia vado ad Patrem, allelúja, allelúja."
   :translations
   ((do . "A little while * and you shall not see me; and again a little while, and you shall see me, saith the Lord, because I go to the Father, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'amen-dico-vobis-quia-plorabitis
 '(:latin "Amen dico vobis, * quia plorábitis et flébitis vos: mundus autem gaudébit, vos vero contristabímini, sed tristítia vestra convertétur in gáudium, allelúja."
   :translations
   ((do . "Amen, amen I say to you * that you shall lament and weep, but the world shall rejoice; and you shall be made sorrowful, but your sorrow shall be turned into joy."))))

;;; ─── Easter 4 antiphons ──────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'vado-ad-eum-qui-misit
 '(:latin "Vado ad eum * qui misit me: et nemo ex vobis intérrogat me: Quo vadis? allelúja, allelúja."
   :translations
   ((do . "I go My way to Him That sent Me, * and none of you asketh Me: Whither goest Thou? Alleluia, Alleluia."))))

(bcp-roman-antiphonary-register
 'vado-ad-eum-sed-quia
 '(:latin "Vado ad eum * qui misit me: sed quia hæc locútus sum vobis, tristítia implévit cor vestrum, allelúja."
   :translations
   ((do . "I go My way to Him That sent Me, * but because I have said this to you, sadness has filled your hearts, alleluia."))))

;;; ─── Easter 5 antiphons ──────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'usque-modo-non-petistis
 '(:latin "Usque modo * non petístis quidquam in nómine meo: pétite, et accipiétis, allelúja."
   :translations
   ((do . "Hitherto * have ye asked nothing in My Name, ask, and ye shall receive. Alleluia."))))

(bcp-roman-antiphonary-register
 'petite-et-accipietis
 '(:latin "Pétite, et accipiétis, * ut gáudium vestrum sit plenum: ipse enim Pater amat vos, quia vos me amástis, et credidístis, allelúja."
   :translations
   ((do . "Ask, and ye shall receive, * that your joy may be full; for the Father Himself loveth you, because ye have loved Me, and have believed in Me, alleluia."))))

;;; ─── Easter 6 antiphons ──────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'cum-venerit-paraclitus
 '(:latin "Cum vénerit Paráclitus, * quem ego mittam vobis Spíritum veritátis, qui a Patre procédit, ille testimónium perhibébit de me, allelúja."
   :translations
   ((do . "But when the Comforter is come * Whom I will send unto you from the Father, He shall testify of Me, alleluia."))))

(bcp-roman-antiphonary-register
 'haec-locutus-sum-vobis
 '(:latin "Hæc locútus sum * vobis, ut cum vénerit hora eórum, reminiscámini quia ego dixi vobis, allelúja."
   :translations
   ((do . "These things have I told * you, that, when the time shall come, ye may remember that I told you of them, alleluia."))))

;;; ─── Easter 7 antiphons ──────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'non-vos-relinquam
 '(:latin "Non vos relínquam * órphanos, allelúja: vado et vénio ad vos, allelúja: et gaudébit cor vestrum, allelúja."
   :translations
   ((do . "I will not leave you orphans, * alleluia; I go away, and come again unto you, alleluia, and your heart shall rejoice, alleluia."))))

(bcp-roman-antiphonary-register
 'accipite-spiritum-sanctum
 '(:latin "Accípite * Spíritum Sanctum: quorum remiséritis peccáta, remittúntur eis, allelúja."
   :translations
   ((do . "Receive ye the Holy Ghost; * whoseoever sins ye remit, they are remitted unto them, alleluia."))))

(bcp-roman-antiphonary-register
 'hodie-completi-sunt
 '(:latin "Hódie * compléti sunt dies Pentecóstes, allelúja: hódie Spíritus Sanctus in igne discípulis appáruit, et tríbuit eis charísmatum dona: misit eos in univérsum mundum prædicáre, et testificári: Qui credíderit et baptizátus fúerit, salvus erit, allelúja."
   :translations
   ((do . "This day * the day of Pentecost is fully come, alleluia. This day the Holy Ghost appeared in fire unto the disciples, and gave unto them gifts of grace. He sent them into all the world, to preach and to testify that he who believeth, and is baptized, shall be saved, alleluia."))))

(bcp-roman-antiphonary-register
 'cum-complerentur-dies
 '(:latin "Cum compleréntur * dies Pentecóstes, erant omnes páriter in eódem loco, allelúja."
   :translations
   ((do . "When the day of Pentecost was fully come * they were all with one accord in one place, alleluia."))))

(bcp-roman-antiphonary-register
 'spiritus-domini-replevit
 '(:latin "Spíritus Dómini * replévit orbem terrárum, allelúja."
   :translations
   ((do . "The Spirit of the Lord * filleth the world, alleluia."))))

(bcp-roman-antiphonary-register
 'repleti-sunt-omnes-spiritu
 '(:latin "Repléti sunt omnes * Spíritu Sancto, et cœpérunt loqui, allelúja, allelúja."
   :translations
   ((do . "They were all filled * with the Holy Ghost, and began to speak, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'fontes-et-omnia
 '(:latin "Fontes, et ómnia * quæ movéntur in aquis, hymnum dícite Deo, allelúja."
   :translations
   ((do . "See ye fountains, * and all that move in the waters, ascribe ye praise to God, alleluia."))))

(bcp-roman-antiphonary-register
 'loquebantur-variis
 '(:latin "Loquebántur * váriis linguis Apóstoli magnália Dei, allelúja, allelúja, allelúja."
   :translations
   ((do . "The Apostles spoke in diverse tongues * the wonderful works of God, alleluia, alleluia, alleluia."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Eastertide capitulum registrations

;;; ─── Easter 1 capitula ──────────────────────────────────────────────

(bcp-roman-capitulary-register
 'omne-quod-natum-est
 '(:latin "Caríssimi: Omne, quod natum est ex Deo, vincit mundum: et hæc est victória, quæ vincit mundum, fides nostra."
   :ref "1 John 5:4"
   :translations
   ((do . "My beloved: For whatsoever is born of God, overcometh the world: and this is the victory which overcometh the world, our faith."))))

(bcp-roman-capitulary-register
 'si-testimonium-hominum
 '(:latin "Si testimónium hóminum accípimus, testimónium Dei majus est: quóniam hoc est testimónium Dei, quod majus est, quóniam testificátus est de Fílio suo. Qui credit in Fílium Dei, habet testimónium Dei in se."
   :ref "1 John 5:9-10"
   :translations
   ((do . "If we receive the testimony of men, the testimony of God is greater. For this is the testimony of God, which is greater, because he hath testified of his Son. He that believeth in the Son of God, hath the testimony of God in himself."))))

;;; ─── Easter 2 capitula ──────────────────────────────────────────────

(bcp-roman-capitulary-register
 'christus-passus-est
 '(:latin "Caríssimi: Christus passus est pro nobis, vobis relínquens exémplum ut sequámini vestígia ejus. Qui peccátum non fecit, nec invéntus est dolus in ore ejus."
   :ref "1 Pet 2:21-22"
   :translations
   ((do . "My beloved: Christ also suffered for us, leaving you an example that you should follow his steps. Who did no sin, neither was guile found in his mouth."))))

(bcp-roman-capitulary-register
 'eratis-enim-sicut-oves
 '(:latin "Erátis enim sicut oves errántes, sed convérsi estis nunc ad pastórem et epíscopum animárum vestrárum."
   :ref "1 Pet 2:25"
   :translations
   ((do . "For you were as sheep going astray; but you are now converted to the shepherd and bishop of your souls."))))

;;; ─── Easter 3 capitula ──────────────────────────────────────────────

(bcp-roman-capitulary-register
 'obsecro-vos-tamquam
 '(:latin "Caríssimi: Obsecro vos tamquam ádvenas et peregrínos abstinére vos a carnálibus desidériis, quæ mílitant advérsus ánimam."
   :ref "1 Pet 2:11"
   :translations
   ((do . "Dearly beloved, I beseech you as strangers and pilgrims, to refrain yourselves from carnal desires which war against the soul."))))

(bcp-roman-capitulary-register
 'servi-subditi-estote
 '(:latin "Servi, súbditi estóte in omni timóre dóminis, non tantum bonis et modéstis, sed étiam dýscolis. Hæc est enim grátia in Christo Jesu Dómino nostro."
   :ref "1 Pet 2:18-19"
   :translations
   ((do . "Servants, be subject to your masters with all fear, not only to the good and gentle, but also to the froward. For this is thankworthy, if for conscience towards God, a man endure sorrows, suffering wrongfully."))))

;;; ─── Easter 4 capitula ──────────────────────────────────────────────

(bcp-roman-capitulary-register
 'omne-datum-optimum
 '(:latin "Caríssimi: Omne datum óptimum, et omne donum perféctum desúrsum est, descéndens a Patre lúminum, apud quem non est transmutátio, nec vicissitúdinis obumbrátio."
   :ref "Jas 1:17"
   :translations
   ((do . "Beloved: Every best gift, and every perfect gift, is from above, coming down from the Father of lights, with whom there is no change, nor shadow of alteration."))))

(bcp-roman-capitulary-register
 'propter-quod-abicientes
 '(:latin "Propter quod abiciéntes omnem immundítiam, et abundántiam malítiæ, in mansuetúdine suscípite ínsitum verbum, quod potest salváre ánimas vestras."
   :ref "Jas 1:21"
   :translations
   ((do . "Wherefore casting away all uncleanness, and abundance of naughtiness, with meekness receive the ingrafted word, which is able to save your souls."))))

;;; ─── Easter 5 capitula ──────────────────────────────────────────────

(bcp-roman-capitulary-register
 'estote-factores-verbi
 '(:latin "Caríssimi: Estóte factóres verbi, et non auditóres tantum: falléntes vosmetípsos. Quia si quis audítor est verbi, et non factor, hic comparábitur viro consideránti vultum nativitátis suæ in spéculo: considerávit enim se, et ábiit, et statim oblítus est qualis fúerit."
   :ref "Jas 1:22-24"
   :translations
   ((do . "My beloved: But be ye doers of the word, and not hearers only, deceiving your own selves. For if a man be a hearer of the word, and not a doer, he shall be compared to a man beholding his own countenance in a glass. For he beheld himself, and went his way, and presently forgot what manner of man he was."))))

(bcp-roman-capitulary-register
 'religio-munda
 '(:latin "Relígio munda et immaculáta apud Deum et Patrem, hæc est: visitáre pupíllos et víduas in tribulatióne eórum, et immaculátum se custodíre ab hoc sǽculo."
   :ref "Jas 1:27"
   :translations
   ((do . "Religion clean and undefiled before God and the Father, is this: to visit the fatherless and widows in their tribulation: and to keep one's self unspotted from this world."))))

;;; ─── Easter 6 capitula ──────────────────────────────────────────────

(bcp-roman-capitulary-register
 'estote-prudentes
 '(:latin "Caríssimi: Estóte prudéntes, et vigiláte in oratiónibus. Ante ómnia autem mútuam in vobismetípsis caritátem contínuam habéntes, quia cáritas óperit multitúdinem peccatórum."
   :ref "1 Pet 4:7-8"
   :translations
   ((do . "My beloved: Be prudent, therefore, and watch in prayers. But before all things have a constant mutual charity among yourselves: for charity covereth a multitude of sins."))))

(bcp-roman-capitulary-register
 'si-quis-loquitur
 '(:latin "Si quis lóquitur, quasi sermónes Dei: si quis minístrat, tamquam ex virtúte, quam adminístrat Deus: ut in ómnibus honorificétur Deus per Jesum Christum, Dóminum nostrum."
   :ref "1 Pet 4:11"
   :translations
   ((do . "If any man speak, let him speak, as the words of God. If any man minister, let him do it, as of the power, which God administereth: that in all things God may be honoured through Jesus Christ our Lord."))))

;;; ─── Easter 7 capitula ──────────────────────────────────────────────

(bcp-roman-capitulary-register
 'cum-complerentur-dies-cap
 '(:latin "Cum compleréntur dies Pentecóstes, erant omnes discípuli páriter in eódem loco: et factus est repénte de cælo sonus, tamquam adveniéntis spíritus veheméntis, et replévit totam domum, ubi erant sedéntes."
   :ref "Acts 2:1-2"
   :translations
   ((do . "When the day of Pentecost was fully come, the disciples were all with one accord in one place and suddenly there came a sound from heaven, as of a rushing mighty wind and it filled all the house where they were sitting."))))

(bcp-roman-capitulary-register
 'judaei-quoque
 '(:latin "Judǽi quoque et Prosélyti, Cretes et Arabes: audívimus eos loquéntes nostris linguis magnália Dei."
   :ref "Acts 2:11"
   :translations
   ((do . "Jews also, and Proselytes, Cretes and Arabians, we do hear them speak in our tongues the wonderful works of God."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sunday number computation

(defun bcp-roman-season-easter--sunday-number (date)
  "Return the Easter week number (0–7) for the Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns nil if DATE is outside Eastertide.
Week 0 = Easter 0 (Easter Sunday), week 1 = Easter 1 (Low Sunday),
..., week 7 = Easter 7 (Pentecost)."
  (let* ((year (caddr date))
         (feasts (bcp-moveable-feasts year))
         (easter (cdr (assq 'easter feasts)))
         (easter-abs (calendar-absolute-from-gregorian easter))
         (date-abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date))
         (sunday-abs (- date-abs dow))
         (weeks (/ (- sunday-abs easter-abs) 7)))
    (when (and (>= weeks 0) (<= weeks 7))
      weeks)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Eastertide dominical Matins lessons and responsories
;;
;; Sunday datasets extracted from Divinum Officium Tempora files.
;;
;; Easter 1–6: Standard 3-nocturn offices.
;;   Each entry: (WEEK . (:lessons (L1..L9) :responsories (R1..R8))).
;;   Same structure as `bcp-roman-tempora--dominical-matins'.
;;
;; Easter 0 (Easter Sunday) and Easter 7 (Pentecost): Special 1-nocturn offices.
;;   Each entry includes :one-nocturn t, :invitatory, :hymn, :psalms,
;;   :versicle, :lessons (3), :responsories (2).

(defconst bcp-roman-season-easter--dominical-matins
  '(

    ;; ── Easter 0: Easter Sunday (Duplex I classis) ──
    ;; 1 nocturn, Psalms 1/2/3, 3 lessons from Gregory Hom. 21 on Mark 16:1-7
    (0
     . (:one-nocturn t
        :invitatory surrexit-dominus-vere
        :hymn primo-dierum-omnium  ; Sunday per-annum hymn
        :psalms ((ego-sum-qui-sum-et-consilium . 1)
                 (postulavi-patrem-meum . 2)
                 (ego-dormivi-et-somnum-cepi . 3))
        :versicle ("Surréxit Dóminus de sepúlcro, allelúja."
                   . "Qui pro nobis pepéndit in ligno, allelúja.")
        :versicle-en ("The Lord is risen from the sepulcher, alleluia."
                      . "He, who hangeth on the tree, alleluia.")
        :lessons
        ((:ref "Marc 16:1-7" :source "Léctio sancti Evangélii secúndum Marcum"
          :text "In illo témpore: María Magdaléne, et María Jacóbi, et Salóme emérunt arómata, ut veniéntes úngerent Jesum. Et réliqua.\n\nHomilía sancti Gregórii Papæ\nHomilia 21 in Evangelia\n\nAudístis, fratres caríssimi, quod sanctæ mulíeres, quæ Dóminum fúerant secútæ, cum aromátibus ad monuméntum venérunt, et ei, quem vivéntem diléxerant, étiam mórtuo, stúdio humanitátis obsequúntur. Sed res gesta áliquid in sancta Ecclésia signat geréndum. Sic quippe necésse est ut audiámus quæ facta sunt, quátenus cogitémus étiam quæ nobis sint ex eórum imitatióne faciénda. Et nos ergo in eum, qui est mórtuus, credéntes, si odóre virtútum reférti, cum opinióne bonórum óperum Dóminum quǽrimus, ad monuméntum profécto illíus cum aromátibus venímus. Illæ autem mulíeres Angelos vident, quæ cum aromátibus venérunt: quia vidélicet illæ mentes supérnos cives aspíciunt, quæ cum virtútum odóribus ad Dóminum per sancta desidéria proficiscúntur.")  ; L1
         (:text "Notándum vero nobis est, quidnam sit, quod in dextris sedére Angelus cérnitur. Quid namque per sinístram, nisi vita præsens: quid vero per déxteram, nisi perpétua vita designátur? Unde in Cánticis canticórum scriptum est: Læva ejus sub cápite meo, et déxtera illíus amplexábitur me. Quia ergo Redémptor noster jam præséntis vitæ corruptiónem transíerat, recte Angelus qui nuntiáre perénnem ejus vitam vénerat, in déxtera sedébat. Qui stola cándida coopértus appáruit: quia festivitátis nostræ gáudia nuntiávit. Candor étenim vestis, splendórem nostræ denúntiat solemnitátis. Nostræ dicámus, an suæ? Sed ut fateámur vérius, et suæ dicámus, et nostræ. Illa quippe Redemptóris nostri resurréctio et nostra festívitas fuit, quia nos ad immortalitátem redúxit: et Angelórum festívitas éxstitit, quia nos revocándo ad cæléstia, eórum númerum implévit.")  ; L2
         (:text "In sua ergo ac nostra festivitáte Angelus in albis véstibus appáruit: quia dum nos per resurrectiónem Domínicam ad supérna redúcimur, cæléstis pátriæ damna reparántur. Sed quid adveniéntes féminas affátur, audiámus: Nolíte expavéscere. Ac si apérte dicat, Páveant illi, qui non amant advéntum supernórum cívium: pertiméscant, qui carnálibus desidériis pressi, ad eórum se societátem pertíngere posse despérant. Vos autem, cur pertiméscitis, quæ vestros concíves vidétis? Unde et Matthǽus Angelum apparuísse descríbens, ait: Erat aspéctus ejus sicut fulgur, et vestiménta ejus sicut nix. In fúlgure étenim terror timóris est, in nive autem blandiméntum candóris.")  ; L3
         )
        :responsories
        ((:respond "Angelus Dómini descéndit de cælo, et accédens revólvit lápidem, et super eum sedit, et dixit muliéribus: * Nolíte timére: scio enim quia crucifíxum quǽritis: jam surréxit: veníte, et vidéte locum, ubi pósitus erat Dóminus, allelúja."
          :verse "Et introëúntes in monuméntum, vidérunt júvenem sedéntem in dextris, coopértum stola cándida, et obstupuérunt: qui dixit illis."
          :repeat "Nolíte timére: scio enim quia crucifíxum quǽritis: jam surréxit: veníte, et vidéte locum, ubi pósitus erat Dóminus, allelúja."
          :gloria t)  ; R1 — with Gloria Patri
         (:respond "Cum transísset sábbatum, María Magdaléne, et María Jacóbi, et Salóme emérunt arómata, * Ut veniéntes úngerent Jesum, allelúja, allelúja."
          :verse "Et valde mane una sabbatórum, véniunt ad monuméntum, orto jam sole."
          :repeat "Ut veniéntes úngerent Jesum, allelúja, allelúja."
          :gloria t)  ; R2 — with Gloria Patri
         )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  vespere-autem-sabbati
        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (angelus-autem-domini-descendit
                          et-ecce-terraemotus
                          erat-autem-aspectus
                          prae-timore-autem
                          respondens-autem-angelus)
        :benedictus-antiphon  et-valde-mane
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon et-respicientes
        ))


    (1
     . (:lessons
        (
        (:ref "Col 3:1-7" :source "De Epístola beáti Pauli Apóstoli ad Colossénses" :text "Si consurrexístis cum Christo: quæ sursum sunt quǽrite, ubi Christus est in déxtera Dei sedens: quæ sursum sunt sápite, non quæ super terram. Mórtui enim estis, et vita vestra est abscóndita cum Christo in Deo. Cum Christus apparúerit, vita vestra: tunc et vos apparébitis cum ipso in glória. Mortificáte ergo membra vestra, quæ sunt super terram: fornicatiónem, immundítiam, libídinem, concupiscéntiam malam, et avarítiam, quæ est simulacrórum servítus: propter quæ venit ira Dei super fílios incredulitátis: in quibus et vos ambulástis aliquándo, cum viveréstis in illis.")  ; L1
        (:ref "Col 3:8-13" :text "Nunc autem depónite et vos ómnia: iram, indignatiónem, malítiam, blasphémiam, turpem sermónem de ore vestro. Nolíte mentíri ínvicem, expoliántes vos véterem hóminem cum áctibus suis, et induéntes novum eum, qui renovátur in agnitiónem secúndum imáginem ejus qui creávit illum: ubi non est géntilis et Judǽus, circumcísio et præpútium, Bárbarus et Scytha, servus et liber: sed ómnia, et in ómnibus Christus. Indúite vos ergo, sicut elécti Dei, sancti, et dilécti, víscera misericórdiæ, benignitátem, humilitátem, modéstiam, patiéntiam: supportántes ínvicem, et donántes vobismetípsis si quis advérsus áliquem habet querélam: sicut et Dóminus donávit vobis, ita et vos.")  ; L2
        (:ref "Col 3:14-17" :text "Super ómnia autem hæc, caritátem habéte, quod est vínculum perfectiónis: et pax Christi exsúltet in córdibus vestris, in qua et vocáti estis in uno córpore: et grati estóte. Verbum Christi hábitet in vobis abundánter, in omni sapiéntia, docéntes, et commonéntes vosmetípsos, psalmis, hymnis, et cánticis spirituálibus, in grátia cantántes in córdibus vestris Deo. Omne, quodcúmque fácitis in verbo aut in ópere, ómnia in nómine Dómini Jesu Christi, grátias agéntes Deo et Patri per ipsum.")  ; L3
        (:ref "Sermo 1 in Octava Paschæ (157 de Tempore)" :source "Sermo sancti Augustíni Epíscopi" :text "Paschális solémnitas hodiérna festivitáte conclúditur, et ídeo hódie Neophytórum hábitus commutátur: ita tamen, ut candor, qui de hábitu depónitur, semper in corde teneátur. In qua quidem primum nobis agéndum est, ut quia pascháles dies sunt, id est, indulgéntiæ ac remissiónis, ita a nobis sanctórum diérum festívitas agátur, ut relaxatióne córporum púritas non obfuscétur: sed pótius abstinéntes ab omni luxu, ebrietáte, lascívia, demus óperam sóbriæ remissióni, ac sanctæ sinceritáti: ut, quidquid modo corporáli abstinéntia non acquírimus, méntium puritáte quærámus.")  ; L4
        (:text "Ad omnes quidem pértinet sermo, quos cura nostra compéctitur: verúmtamen hódie termináta sacraméntórum solemnitáte, vos allóquimur, novélla gérmina sanctitátis, regeneráta ex aqua et Spíritu Sancto: germen pium, exámen novéllum, flos nostri honóris, et fructus labóris, gáudium et coróna mea, omnes qui statis in Dómino. Apostólicis verbis vos allóquor: Ecce nox præcéssit, dies autem appropinquávit: abjícite ópera tenebrárum, et induímini arma lucis. Sicut in die honéste ambulémus: non in comessatiónibus et ebrietátibus, non in cubílibus et impudícítiis, non in contentióne et æmulatióne: sed indúimini Dóminum Jesum Christum.")  ; L5
        (:text "Habémus, inquit, certiórem prophéticum sermónem: cui bene fácitis intendéntes tamquam lucérnæ in obscúro loco, donec dies lucéscat, et lúcifer oriátur in córdibus vestris. Sint ergo lumbi vestri accíncti, et lucérnæ ardéntes in mánibus vestris: et vos símiles homínibus exspectántibus dóminum suum, quando revertátur a núptiis. Ecce dies advéniunt, in quibus Dóminus dicit: Pusíllum, inquit, et non vidébitis me, et íterum pusíllum, et vidébitis me. Hæc est hora, de qua dixit: Vos tristes éritis, sǽculum autem gaudébit: id est, vita ista tentatiónibus plena, in qua peregrinámur ab eo. Sed íterum, inquit, vidébo vos, et gaudébit cor vestrum, et gáudium vestrum nemo tollet a vobis.")  ; L6
        (:ref "Joann 20:19-31" :source "Léctio sancti Evangélii secúndum Joánnem" :text "In illo témpore: Cum sero esset die illo, una sabbatórum, et fores essent clausæ, ubi erant discípuli congregáti propter metum Judæórum: venit Jesus, et stetit in médio, et dixit eis: Pax vobis. Et réliqua. Homília sancti Gregórii Papæ !Homília 26 in Evangélia Prima lectiónis hujus evangélicæ quǽstio ánimum pulsat: quómodo post resurrectiónem corpus Domínicum verum fuit, quod clausis jánuis ad discípulos ingrédi pótuit? Sed sciéndum nobis est, quod divína operátio, si ratióne comprehénditur, non est admirábilis: nec fides habet méritum, cui humána rátio præbet experiméntum. Sed hæc ipsa nostri Redemptóris ópera, quæ ex semetípsis comprehéndi nequáquam possunt, ex ália ejus operatióne pensánda sunt: ut rebus mirábilibus fidem prǽbeant facta mirabílióra. Illud enim corpus Dómini intrávit ad discípulos jánuis clausis, quod vidélicet ad humános óculos per nativitátem suam clauso exívit útero Vírginis. Quid ergo mirum, si clausis jánuis post resurrectiónem suam in ætérnum jam victúrus intrávit, qui moritúrus véniens, non apérto útero Vírginis exívit?")  ; L7
        (:text "Sed quia ad illud corpus, quod vidéri póterat, fides intuéntium dubitábat: osténdit eis prótinus manus et latus, palpándam carnem prǽbuit, quam clausis jánuis introdúxit. Qua in re duo mira, et juxta humánam ratiónem sibi valde contrária osténdit: dum post resurrectiónem suam corpus suum incorruptíbile, et tamen palpábile demonstrávit. Nam et corrúmpi necésse est quod palpátur: et palpári non potest quod non corrúmpitur. Sed miro modo atque inæstimábili Redémptor noster et incorruptíbile post resurrectiónem, et palpábile corpus exhíbuit: ut monstrándo incorruptíbile, invitáret ad prǽmium, et præbéndo palpábile, firmáret ad fidem. Et incorruptíbilem se ergo, et palpábilem demonstrávit: ut proférto esse post resurrectiónem osténderet corpus suum et ejúsdem natúræ, et altérius glóriæ.")  ; L8
        (:text "Dixit eis: Pax vobis. Sicut misit me Pater, et ego mitto vos: id est, sicut misit me Pater Deus Deum, et ego mitto vos homo hómines. Pater Fílium misit, qui hunc pro redemptióne géneris humáni incarnári constítuit. Quem vidélicet in mundum veníre ad passiónem vóluit: sed tamen amávit Fílium, quem ad passiónem misit. Eléctos vero Apóstolos Dóminus non ad mundi gáudia, sed sicut ipse missus est, ad passiónes in mundum mittit. Quia ergo et Fílius amátur a Patre, et tamen ad passiónem míttitur: ita et discípuli a Dómino amántur, qui tamen ad passiónem mittúntur in mundum. Itaque recte dícitur: Sicut misit me Pater, et ego mitto vos: id est, ea vos caritáte díligo, cum inter scándala persecutórum mitto, qua me caritáte Pater díligit, quem veníre ad tolerándas passiónes fecit.")  ; L9
        )
        :responsories
        (
        (:respond "Ángelus Dómini descéndit de cælo, et accédens revólvit lápidem, et super eum sedit, et dixit muliéribus: * Nolíte timére: scio enim quia crucifíxum quǽritis: jam surréxit: veníte, et vidéte locum, ubi pósitus erat Dóminus, allelúja." :verse "Et introeúntes in monuméntum, vidérunt júvenem sedéntem in dextris, coopértum stola cándida, et obstupuérunt: qui dixit illis." :repeat "Nolíte timére: scio enim quia crucifíxum quǽritis: jam surréxit: veníte, et vidéte locum, ubi pósitus erat Dóminus, allelúja.")  ; R1
        (:respond "Ángelus Dómini locútus est muliéribus, dicens: Quem quǽritis? an Jesum quǽritis? Jam surréxit: * Veníte, et vidéte, allelúja, allelúja." :verse "Jesum quǽritis Nazarénum crucifíxum? Surréxit, non est hic." :repeat "Veníte, et vidéte, allelúja, allelúja.")  ; R2
        (:respond "Cum transísset sábbatum, María Magdaléne, et María Jacóbi, et Sálome emérunt arómata, * Ut veniéntes úngerent Jesum, allelúja, allelúja." :verse "Et valde mane una sabbatórum, véniunt ad monuméntum, orto jam sole." :repeat "Ut veniéntes úngerent Jesum, allelúja, allelúja.")  ; R3
        (:respond "María Magdaléne, et áltera María ibant dilúculo ad monuméntum: * Jesum quem quǽritis, non est hic, surréxit sicut locútus est, præcédet vos in Galilǽam, ibi eum vidébitis, allelúja, allelúja." :verse "Et valde mane una sabbatórum véniunt ad monuméntum, orto jam sole: et introeúntes vidérunt júvenem sedéntem in dextris, qui dixit illis." :repeat "Jesum quem quǽritis, non est hic, surréxit sicut locútus est, præcédet vos in Galilǽam, ibi eum vidébitis, allelúja, allelúja.")  ; R4
        (:respond "Surréxit pastor bonus, qui ánimam suam pósuit pro óvibus suis, et pro grege suo mori dignátus est: * Allelúja, allelúja, allelúja." :verse "Étenim Pascha nostrum immolátus est Christus." :repeat "Allelúja, allelúja, allelúja.")  ; R5
        (:respond "Virtúte magna reddébant Apóstoli, * Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja." :verse "Repléti quidem Spíritu Sancto loquebántur cum fidúcia verbum Dei." :repeat "Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja.")  ; R6
        (:respond "De ore prudéntis procédit mel, allelúja: dulcédo mellis est sub lingua ejus, allelúja: * Favus distíllans lábia ejus, allelúja, allelúja." :verse "Sapiéntia requiéscit in corde ejus, et prudéntia in sermóne oris illíus." :repeat "Favus distíllans lábia ejus, allelúja, allelúja.")  ; R7
        (:respond "Surgens Jesus Dóminus noster, stans in médio discipulórum suórum, dixit: * Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja." :verse "Una ergo sabbatórum, cum fores essent clausæ, ubi erant discípuli congregáti, venit Jesus, et stetit in médio eórum, et dixit eis." :repeat "Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  cum-esset-sero
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  cum-esset-sero
        :lauds-capitulum      omne-quod-natum-est
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       si-testimonium-hominum
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon post-dies-octo
        ))


    (2
     . (:lessons
        (
        (:ref "Act 13:13-20" :source "De Áctibus Apostolórum" :text "Cum a Papho navigássent Paulus et qui cum eo erant, venérunt Pergen Pamphýliæ. Joánnes autem discédens ab eis, revérsus est Jerosólymam. Illi vero pertranseúntes Pergen, venérunt Antiochíam Pisídiæ: et ingréssi synagógam die sabbatórum, sedérunt. Post lectiónem autem legis et prophetárum, misérunt príncipes synagógæ ad eos, dicéntes: Viri fratres, si quis est in vobis sermo exhortatiónis ad plebem, dícite. Surgens autem Paulus, et manu siléntium índicens, ait: Viri Israelítæ, et qui timétis Deum, audíte: Deus plebis Israël elégit patres nostros, et plebem exaltávit cum essent íncolæ in terra Ægýpti, et in bráchio excélso edúxit eos ex ea, et per quadragínta annórum tempus mores eórum sustínuit in desérto. Et déstruens gentes septem in terra Chánaan, sorte distribúit eis terram eórum, quasi post quadringéntos et quinquagínta annos: et post hæc dedit júdices, usque ad Sámuel prophétam.")  ; L1
        (:ref "Act 13:21-25" :text "Et exínde postulavérunt regem: et dedit illis Deus Saul fílium Cis, virum de tribu Bénjamin, annis quadragínta: et amóto illo, suscitávit illis David regem: cui testimónium períbens, dixit: Invéni David fílium Jesse, virum secúndum cor meum, qui fáciet omnes voluntátes meas. Hujus Deus ex sémine secúndum promissiónem edúxit Israël salvatórem Jesum, prædicánte Joánne ante fáciem advéntus ejus baptísmum pœniténtiæ omni pópulo Israël. Cum impléret autem Joánnes cursum suum, dicébat: Quem me arbitrámini esse, non sum ego: sed ecce venit post me, cujus non sum dignus calceaménta pedum sólvere.")  ; L2
        (:ref "Act 13:26-33" :text "Viri fratres, fílii géneris Abraham, et qui in vobis timent Deum, vobis verbum salútis hujus missum est. Qui enim habitábant Jerúsalem, et príncipes ejus hunc ignorántes, et voces prophetárum quæ per omne sábbatum legúntur, judicántes implevérunt, et nullam causam mortis inveniéntes in eo, petiérunt a Piláto ut interfícerent eum. Cumque consummássent ómnia quæ de eo scripta erant, deponéntes eum de ligno, posuérunt eum in monuménto. Deus vero suscitávit eum a mórtuis tértia die: qui visus est per dies multos his qui simul ascénderant cum eo de Galilǽa in Jerúsalem: qui usque nunc sunt testes ejus ad plebem. Et nos vobis annuntiámus eam, quæ ad patres nostros repromíssio facta est: quóniam hanc Deus adimplévit fíliis nostris resuscítans Jesum, sicut et in psalmo secúndo scriptum est: Fílius meus es tu, ego hódie génui te.")  ; L3
        (:ref "Sermo 1 de Ascensióne Dómini, post inítium" :source "Sermo sancti Leónis Papæ" :text "Hi dies, dilectíssimi, qui inter resurrectiónem Dómini ascensionémque fluxérunt, non otióso transiére decúrsu, sed magna in eis confirmáta sacraménta, magna sunt reveláta mystéria. In iis metus diræ mortis aufértur, et non solum ánimæ, sed étiam carnis immortálitas declarátur. In iis per insufflatiónem Dómini infúnditur Apóstolis ómnibus Spíritus Sanctus: et beáto Apóstolo Petro supra céteros, post regni claves, ovílis Domínici cura mandátur.")  ; L4
        (:text "In iis diébus, duóbus discípulis tértius in via Dóminus comes júngitur, et ad omnem nostræ ambiguitátis calíginem detergéndam, pavéntium ac trepidántium táritas increpátur. Flammam fídei illumináta corda concípiunt: et quæ erant tépida, reseránte Scriptúras Dómino, efficiúntur ardéntia. In fractióne quoque panis, convescéntium aperiúntur obtútus: multo felícius eórum óculis patefáctis, quibus natúræ suæ manifestáta est glorificátio, quam illórum géneris nostri príncipum, quibus prævaricatiónis suæ est ingésta confúsio.")  ; L5
        (:text "Inter hæc autem, aliáque mirácula, cum discípuli trépidis cogitatiónibus æstuárent, et apparuísset in médio eórum Dóminus, dixissétque, Pax vobis: ne hoc remanéret in eórum opiniónibus, quod volvebátur in córdibus (putábant enim se spíritum vidére, non carnem) redárguit cogitatiónes a veritáte discórdes: ingérit dubitántium óculis manéntia in mánibus suis et pédibus crucis signa; et ut diligéntius pertractétur, invítat. Quia ad sanánda infidélium córdium vúlnera, clavórum et lánceæ erant serváta vestígia: ut non dúbia fide, sed constantíssima sciéntia tenerétur, eam natúram in Dei Patris consessúram throno, quæ jacúerat in sepúlcro.")  ; L6
        (:ref "Joann 10:11-16" :source "Léctio sancti Evangélii secúndum Joánnem" :text "In illo témpore: Dixit Jesus pharisǽis: Ego sum pastor bonus. Bonus pastor ánimam suam dat pro óvibus suis. Et réliqua. Homília sancti Gregórii Papæ !Homília 14 in Evangélia Audístis, fratres caríssimi, ex lectióne evangélica eruditiónem vestram: audístis et perículum nostrum. Ecce enim is, qui non ex accidénti dono, sed essentiáliter bonus est, dicit: Ego sum pastor bonus. Atque ejúsdem bonitátis formam, quam nos imitémur, adjúngit, dicens: Bonus pastor ánimam suam ponit pro óvibus suis. Fecit quod mónuit: osténdit quod jussit. Bonus pastor pro óvibus suis ánimam suam pósuit, ut in sacraménto nostro corpus suum et sánguinem vérteret, et oves quas redémerat, carnis suæ aliménto satiáret.")  ; L7
        (:text "Osténsa nobis est de contémptu mortis via, quam sequámur: appósita est forma, cui imprímamur. Primum nobis est, exterióra nostra misericórditer óvibus ejus impéndere: postrémum vero, si necésse sit, étiam mortem nostram pro eísdem óvibus ministráre. A primo autem hoc mínimo pervenítur ad postrémum majus. Sed cum incomparábiliter longe sit mélior ánima, qua vívimus, quam terréna substántia, quam extérius possidémus: qui non dat pro óvibus substántiam suam, quando pro his datúrus est ánimam suam?")  ; L8
        (:text "Et sunt nonnúlli, qui dum plus terrénam substántiam quam oves díligunt, mérito nomen pastóris perdunt: de quibus prótinus súbditur: Mercenárius autem, et qui non est pastor, cujus non sunt oves própriæ, videt lupum veniéntem, et dimíttit oves, et fugit. Non pastor, sed mercenárius vocátur, qui non pro amóre íntimo oves Domínicas, sed ad temporáles mercédes pascit. Mercenárius quippe est, qui locum quidem pastóris tenet, sed lucra animárum non quǽrit: terrénis cómmodis ínhiat, honóre prælátiónis gaudet, temporálibus lucris páscitur, impénsa sibi ab homínibus reverétia lætátur.")  ; L9
        )
        :responsories
        (
        (:respond "Virtúte magna reddébant Apóstoli, * Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja." :verse "Repléti quidem Spíritu Sancto loquebántur cum fidúcia verbum Dei." :repeat "Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja.")  ; R1
        (:respond "De ore prudéntis procédit mel, allelúja: dulcédo mellis est sub lingua ejus, allelúja: * Favus distíllans lábia ejus, allelúja, allelúja." :verse "Sapiéntia requiéscit in corde ejus, et prudéntia in sermóne oris illíus." :repeat "Favus distíllans lábia ejus, allelúja, allelúja.")  ; R2
        (:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus: * Allelúja, allelúja, allelúja." :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem." :repeat "Allelúja, allelúja, allelúja.")  ; R3
        (:respond "Ego sum vitis vera, et vos pálmites: * Qui manet in me, et ego in eo, hic fert fructum multum, allelúja, allelúja." :verse "Sicut diléxit me Pater, et ego diléxi vos." :repeat "Qui manet in me, et ego in eo, hic fert fructum multum, allelúja, allelúja.")  ; R4
        (:respond "Surgens Jesus Dóminus noster, stans in médio discipulórum suórum, dixit: * Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja." :verse "Una ergo sabbatórum, cum fores essent clausæ, ubi erant discípuli congregáti, venit Jesus, et stetit in médio eórum, et dixit eis." :repeat "Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja.")  ; R5
        (:respond "Expurgáte vetus ferméntum, ut sitis nova conspérsio: étenim Pascha nostrum immolátus est Christus: * Itaque epulémur in Dómino, allelúja." :verse "Mórtuus est propter delícta nostra, et resurréxit propter justificatiónem nostram." :repeat "Itaque epulémur in Dómino, allelúja.")  ; R6
        (:respond "Christus resúrgens ex mórtuis, jam non móritur, mors illi ultra non dominábitur: quod enim mórtuus est peccáto, mórtuus est semel: * Quod autem vivit, vivit Deo, allelúja, allelúja." :verse "Mórtuus est semel propter delícta nostra, et resurréxit propter justificatiónem nostram." :repeat "Quod autem vivit, vivit Deo, allelúja, allelúja.")  ; R7
        (:respond "Surréxit pastor bonus, qui ánimam suam pósuit pro óvibus suis, et pro grege suo mori dignátus est: * Allelúja, allelúja, allelúja." :verse "Étenim Pascha nostrum immolátus est Christus." :repeat "Allelúja, allelúja, allelúja.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  ego-sum-pastor-ovium
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  ego-sum-pastor-ovium
        :lauds-capitulum      christus-passus-est
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       eratis-enim-sicut-oves
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon ego-sum-pastor-bonus
        ))


    (3
     . (:lessons
        (
        (:ref "Apo 1:1-6" :source "Incipit liber Apocalýpsis beáti Joánnis Apóstoli" :text "Apocalýpsis Jesu Christi, quam dedit illi Deus palam fácere servis suis, quæ opórtet fíeri cito: et significávit, mittens per ángelum suum servo suo Joánni, qui testimónium perhíbuit verbo Dei, et testimónium Jesu Christi, quæcúmque vidit. Beátus qui legit, et audit verba prophétíæ hujus, et servat ea, quæ in ea scripta sunt: tempus enim prope est. Joánnes septem ecclésiis, quæ sunt in Asia. Grátia vobis, et pax ab eo, qui est, et qui erat, et qui ventúrus est: et a septem spirítibus qui in conspéctu throni ejus sunt: et a Jesu Christo, qui est testis fidélis, primogénitus mortuórum, et princeps regum terræ, qui diléxit nos, et lavit nos a peccátis nostris in sánguine suo, et fecit nos regnum, et sacerdótes Deo et Patri suo: ipsi glória et impérium in sǽcula sæculórum. Amen.")  ; L1
        (:ref "Apo 1:7-11" :text "Ecce venit cum núbibus, et vidébit eum omnis óculus, et qui eum pupugérunt. Et plangent se super eum omnes tribus terræ. Étiam: amen. Ego sum alpha et oméga, princípium et finis, dicit Dóminus Deus: qui est, et qui erat, et qui ventúrus est, omnípotens. Ego Joánnes frater vester, et párticeps in tribulatióne, et regno, et patiéntia in Christo Jesu: fui in ínsula, quæ appellátur Patmos, propter verbum Dei, et testimónium Jesu: fui in spíritu in domínica die, et audívi post me vocem magnam tamquam tubæ, dicéntis: Quod vides, scribe in libro: et mitte septem ecclésiis, quæ sunt in Asia, Épheso, et Smýrnæ, et Pérgamo, et Thyatíræ, et Sardis, et Philadélphiæ, et Laodíciæ.")  ; L2
        (:ref "Apo 1:12-19" :text "Et convérsus sum ut vidérem vocem, quæ loquebátur mecum: et convérsus vidi septem candelábra áurea: et in médio septem candelabrórum aureórum, símilem Fílio hóminis vestítum podére, et præcínctum ad mamíllas zona áurea: caput autem ejus, et capílli erant cándidi tamquam lana alba, et tamquam nix, et óculi ejus tamquam flamma ignis: et pedes ejus símiles auricalco, sicut in camíno ardénti, et vox illíus tamquam vox aquárum multárum: et habébat in déxtera sua stellas septem: et de ore ejus gládius utráque parte acútus exíbat: et fácies ejus sicut sol lucet in virtúte sua. Et cum vidíssem eum, cécidi ad pedes ejus tamquam mórtuus. Et pósuit déxteram suam super me, dicens: Noli timére: ego sum primus, et novíssimus, et vivus, et fui mórtuus, et ecce sum vivens in sǽcula sæculórum: et hábeo claves mortis, et inférni. Scribe ergo quæ vidísti, et quæ sunt, et quæ opórtet fíeri post hæc.")  ; L3
        (:ref "Sermo 147 de Témpore" :source "Sermo sancti Augustíni Epíscopi" :text "Diébus his sanctis resurrectióni Dómini dedicátis, quantum donánte ipso póssumus, de carnis resurrectióne tractémus. Hæc enim est fides nostra: hoc donum in Dómini nostri Jesu Christi nobis carne promíssum est, et in ipso præcéssit exémplum. Vóluit enim nobis, quod promísit in fine, non solum prænuntiáre, sed étiam demonstráre. Illi quidem qui tunc fuérunt, cum illum vidérent, et cum expaviscerent, et spíritum se vidére créderent, soliditátem córporis tenuérunt. Locútus est enim non solum verbis ad aures eórum, sed étiam spécie ad óculos eórum: parúmque erat se præbére cernéndum, nisi étiam offérret pertractándum atque palpándum.")  ; L4
        (:text "Ait enim: Quid turbáti estis, et cogitatiónes ascéndunt in cor vestrum? Putavérunt enim se spíritum vidére. Quid turbáti estis, inquit, et cogitatiónes ascéndunt in cor vestrum? Vidéte manus meas, et pedes meos: palpáte, et vidéte: quia spíritus ossa et carnem non habet, sicut me vidétis habére. Contra istam evidéntiam disputábant hómines. Quid enim áliud fácerent hómines, qui ea, quæ sunt hóminum, sápiunt, quam sic disputáre de Deo contra Deum? Ille enim Deus est, isti hómines sunt. Sed Deus novit cogitatiónes hóminum, quóniam vanæ sunt.")  ; L5
        (:text "In hómine carnáli tota régula intelligéndi est consuetúdo cernéndi. Quod solent vidére, credunt: quod non solent, non credunt. Præter consuetúdinem facit Deus mirácula, quia Deus est. Majóra quidem mirácula sunt, tot quotídie hómines nasci, qui non erant, quam paucos resurrexísse, qui erant: et tamen ista mirácula non consideratióne comprehénsa sunt, sed assiduitáte viluérunt. Resurréxit Christus: absolúta est res. Corpus erat, caro erat: pepéndit in cruce, emísit ánimam, pósita est caro in sepúlcro. Exhíbuit illam vivam, qui vivébat in illa. Quare mirámur? quare non crédimus? Deus est, qui fecit.")  ; L6
        (:ref "Joann 16:16-22" :source "Léctio sancti Evangélii secúndum Joánnem" :text "In illo témpore: Dixit Jesus discípulis suis: Módicum, et jam non vidébitis me; et íterum módicum, et vidébitis me: quia vado ad Patrem. Et réliqua. Homília sancti Augustíni Epíscopi !Tractátus 101 in Joánnem, sub fine Módicum est hoc totum spátium, quo præsens pervólat sǽculum. Unde dicit idem ipse Evangelísta in Epístola sua: Novíssima hora est. Ídeo namque áddidit: Quia vado ad Patrem: quod ad priórem senténtiam referéndum est, ubi ait: Módicum et jam non vidébitis me: non ad posteriórem, ubi ait: Et íterum módicum, et vidébitis me. Eúndo quippe ad Patrem, factúrus erat ut eum non vidérent. Ac per hoc non ídeo dictum est, quia fúerat moritúrus, et donec resúrgeret, ab eórum aspéctibus recessúrus: sed quod esset itúrus ad Patrem, quod fecit postéaquam resurréxit, et cum eis per quadragínta dies conversátus, ascéndit in cælum.")  ; L7
        (:text "Illis ergo ait: Módicum, et jam non vidébitis me; qui eum corporáliter tunc vidébant: quia itúrus erat ad Patrem, et eum deínceps mortálem visúri non erant, qualem, cum ista loquerétur, vidébant. Quod vero áddidit: Et íterum módicum, et vidébitis me: univérsæ promísit Ecclésiæ, sicut univérsæ promísit: Ecce ego vobíscum sum usque ad consummatiónem sǽculi. Non tardat Dóminus promíssum. Módicum et vidébimus eum: ubi jam nihil rogémus, nihil interrogémus, quia nihil desiderándurn remanébit, nihil quæréndum latébit.")  ; L8
        (:text "Hoc módicum longum nobis vidétur, quóniam adhuc ágitur; cum finítum fúerit, tunc sentiémus quam módicum fúerit. Non ergo sit gáudium nostrum quale habet mundus, de quo dictum est: Mundus autem gaudébit. Nec tamen in hujus desidérii parturitióne sine gáudio tristes simus: sed, sicut ait Apóstolus: Spe gaudéntes: In tribulatióne patiéntes: quia et ipsa parturiens, cui comparáti sumus, plus gaudet de mox futúra prole, quam tristis est de præsénti dolóre. Sed hujus sermónis iste sit finis: habent enim quæstiónem molestíssimam, quæ sequúntur: nec brevitáte coarctánda sunt, ut possint cómmódius, si Dóminus volúerit, explicári.")  ; L9
        )
        :responsories
        (
        (:respond "Dignus es, Dómine, accípere librum, et aperíre signácula ejus, allelúja: quóniam occísus es, et redemísti nos Deo * In sánguine tuo, allelúja." :verse "Fecísti enim nos Deo nostro regnum et sacerdótium." :repeat "In sánguine tuo, allelúja.")  ; R1
        (:respond "Ego sicut vitis fructificávi suavitátem odóris, allelúja: * Tránsíte ad me, omnes qui concupíscitis me, et a generatiónibus meis adimplémini, allelúja, allelúja." :verse "In me omnis grátia viæ et veritátis: in me omnes spes vitæ et virtútis." :repeat "Tránsíte ad me, omnes qui concupíscitis me, et a generatiónibus meis adimplémini, allelúja, allelúja.")  ; R2
        (:respond "Audívi vocem de cælo, tamquam vocem tonítrui magni, allelúja: Regnábit Deus noster in ætérnum, allelúja: * Quia facta est salus, et virtus, et potéstas Christi ejus, allelúja, allelúja." :verse "Et vox de throno exívit, dicens: Laudem dícite Deo nostro, omnes Sancti ejus, et qui timétis Deum, pusílli et magni." :repeat "Quia facta est salus, et virtus, et potéstas Christi ejus, allelúja, allelúja.")  ; R3
        (:respond "Locútus est ad me unus ex septem Ángelis, dicens: Veni, osténdam tibi novam nuptam, sponsam Agni: * Et vidi Jerúsalem descendéntem de cælo, ornátam monílibus suis, allelúja, allelúja, allelúja." :verse "Et sústulit me in spíritu in montem magnum et altum." :repeat "Et vidi Jerúsalem descendéntem de cælo, ornátam monílibus suis, allelúja, allelúja, allelúja.")  ; R4
        (:respond "Audívi vocem in cælo Angelórum multórum dicéntium: * Timéte Dóminum, et date claritátem illi, et adoráte eum, qui fecit cælum et terram, mare et fontes aquárum, allelúja, allelúja." :verse "Vidi Ángelum Dei fortem, volántem per médium cæli, voce magna clamántem et dicéntem." :repeat "Timéte Dóminum, et date claritátem illi, et adoráte eum, qui fecit cælum et terram, mare et fontes aquárum, allelúja, allelúja.")  ; R5
        (:respond "Véniens a Líbano quam pulchra facta est, allelúja: * Et odor vestiméntórum ejus super ómnia arómata, allelúja, allelúja." :verse "Favus distíllans lábia ejus, mel et lac sub lingua ejus." :repeat "Et odor vestiméntórum ejus super ómnia arómata, allelúja, allelúja.")  ; R6
        (:respond "Decantábat pópulus Israël, allelúja: et univérsa multitúdo Jacob canébat legítime: * Et David cum cantóribus cítharam percutiébat in domo Dómini, et laudes Deo canébat, allelúja, allelúja." :verse "Sanctificáti sunt ergo sacerdótes et levítæ: et univérsus Israël dedúcébat arcam fœ́deris Dómini in júbilo." :repeat "Et David cum cantóribus cítharam percutiébat in domo Dómini, et laudes Deo canébat, allelúja, allelúja.")  ; R7
        (:respond "Tristítia vestra, allelúja, * Convertétur in gáudium, allelúja, allelúja." :verse "Mundus autem gaudébit, vos vero contristabímini, sed tristítia vestra." :repeat "Convertétur in gáudium, allelúja, allelúja.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  modicum-et-non-videbitis
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  modicum-et-non-videbitis
        :lauds-capitulum      obsecro-vos-tamquam
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       servi-subditi-estote
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon amen-dico-vobis-quia-plorabitis
        ))


    (4
     . (:lessons
        (
        (:ref "Jac 1:1-6" :source "Incipit Epístola cathólica beáti Jacóbi Apóstoli" :text "Jacóbus, Dei et Dómini nostri Jesu Christi servus, duódecim tríbubus, quæ sunt in dispersióne, salútem. Omne gáudium existimáte fratres mei, cum in tentatiónes várias incidéritis: sciéntes quod probátio fídei vestræ patiéntiam operátur. Patiéntia autem opus perféctum habet: ut sitis perfécti et íntegri in nullo deficiéntes. Si quis autem vestrum índiget sapiéntia, póstulet a Deo, qui dat ómnibus affluénter, et non impróperat: et dábitur ei. Póstulet autem in fide nihil hǽsitans.")  ; L1
        (:ref "Jac 1:6-11" :text "Qui enim hǽsitat, símilis est flúctui maris, qui a vento movétur et circumfértur: non ergo ǽstimet homo ille quod accípiat áliquid a Dómino. Vir duplex ánimo incónstans est in ómnibus viis suis. Gloriétur autem frater húmilis in exaltatióne sua: dives autem in humilitáte sua, quóniam sicut flos fœni transíbit; exórtus est enim sol cum ardóre, et arefécit fœnum, et flos ejus décidit, et decor vultus ejus depériit: ita et dives in itinéribus suis marcéscet.")  ; L2
        (:ref "Jac 1:12-16" :text "Beátus vir qui suffert tentatiónem: quóniam cum probátus fúerit, accípiet corónam vitæ, quam repromísit Deus diligéntibus se. Nemo cum tentátur, dicat quóniam a Deo tentátur: Deus enim intentátor malórum est: ipse autem néminem tentat. Unusquísque vero tentátur a concupiscéntia sua abstráctus, et illéctus. Deínde concupiscéntia cum concéperit, parit peccátum: peccátum vero cum consummátum fúerit, génerat mortem. Nolíte ítaque erráre, fratres mei dilectíssimi.")  ; L3
        (:ref "Sermone 3, inítio" :source "Ex Tractátu sancti Cypriáni Epíscopi et Mártyris de bono patiéntiæ" :text "De patiéntia locutúrus, fratres dilectíssimi, et utilitátes ejus et cómmoda prædicatúrus, unde pótius incípiam, quam quod nunc quoque ad audiéntiam vestram patiéntiam vídeo esse necessáriam: ut nec hoc ipsum, quod audítis et díscitis, sine patiéntia fácere possítis? Tunc enim demum sermo et rátio salutáris efficáciter díscitur, si patiénter, quod dícitur, audiátur. Nec invénio, fratres dilectíssimi, inter céteras cæléstis disciplínæ vias, quibus ad consequénda divínitus prǽmia spei ac fídei nostræ secta dírigitur, quid magis sit vel utílius ad vitam, vel majus ad glóriam, quam ut, qui præcéptis Domínicis obséquio timóris ac devotiónis innítimur, patiéntiam máxime tota observatióne tueámur. Hanc se sectári philósophi quoque profiténtur: sed tam illic patiéntia falsa est, quam et falsa sapiéntia est. Unde enim vel sápiens esse, vel pátiens possit, qui nec sapiéntiam nec patiéntiam Dei novit?")  ; L4
        (:text "Nos autem, fratres dilectíssimi, qui philósophi non verbis, sed factis sumus; nec vestítu sapiéntiam, sed veritáte præférimus: qui virtútum consciéntiam magis quam jactántiam nóvimus: qui non lóquimur magna, sed vívimus quasi servi et cultóres Dei: patiéntiam, quam magistériis cæléstibus díscimus, obséquiis spiritálibus præbeámus. Est enim nobis cum Deo virtus ista commúnis: inde patiéntia íncipit, inde cláritas ejus et dígnitas caput sumit. Orígo et magnitúdo patiéntiæ Deo auctóre procédit. Diligénda res hómini, quæ Deo cara est. Bonum quod amat, majéstas divína comméndat. Si Dóminus nobis et Pater Deus est, sectémur patiéntiam dómini páriter et patris; quia et servos opórtet esse obsequéntes, et fílios non decet esse degéneres.")  ; L5
        (:text "Patiéntia est, quæ nos Deo et comméndat et servat: ipsa est, quæ iram témperat, quæ linguam frenat, quæ mentem gubérnat, pacem custódit, disciplínam regit, libídinis ímpetum frangit, tumóris violéntiam cómprimit, incéndium simultátis exstínguit, coércet poténtiam dívitum, inópiam páuperum réfovet, tuétur in virgínibus beátam integritátem, in víduis laboriósam castitátem, in conjúnctis et maritátis indivíduam caritátem: facit húmiles in prósperis, in advérsis fortes, contra injúrias et contumélias mites: docet delinquéntibus cito ignóscere: si ipse delínquas, diu et multum rogáre: tentatiónes expúgnat, persecutiónes tólerat, passiónes et martýria consúmmat. Ipsa est, quæ fídei nostræ fundaménta fírmiter munit.")  ; L6
        (:ref "Joann 16:5-14" :source "Léctio sancti Evangélii secúndum Joánnem" :text "In illo témpore: Dixit Jesus discípulis suis: Vado ad eum, qui me misit: et nemo ex vobis intérrogat me: Quo vadis? Et réliqua. Homília sancti Augustíni Epíscopi !Tractátus 94 in Joánnem, inítio Cum Dóminus Jesus prædixísset discípulis suis persecutiónes, quas passúri erant post ejus abscéssum, subjúnxit atque ait: Hæc autem vobis ab inítio non dixi, quia vobíscum eram: nunc autem vado ad eum, qui me misit. Ubi primum vidéndum est, utrum eis futúras non prædíxerit ante passiónes. Sed álii tres Evangelístæ satis eum prædixísse ista demónstrant, ántequam ventum esset ad cenam: qua perácta, secúndum Joánnem ista locútus est, ubi ait: Hæc autem vobis ab inítio non dixi, quia vobíscum eram.")  ; L7
        (:text "An forte hinc ista sólvitur quǽstio, quia et illi eum narrant passióni próximum fuísse cum hæc díceret? Non ergo ab inítio, quando cum illis erat: quia jam discessúrus, jamque ad Patrem perrectúrus hæc dixit. Et ídeo étiam secúndum illos Evangelístas verum est, quod hic dictum est: Hæc autem vobis ab inítio non dixi. Sed quid ágimus de fide Evangélii secúndum Matthǽum, qui hæc eis a Dómino non solum cum jam Pascha esset cum discípulis cœnatúrus, imminénte passióne, verum et ab inítio denuntiáta esse commémorat; ubi primum nominátim duódecim exprimúntur Apóstoli, et ad ópera divína mittúntur?")  ; L8
        (:text "Quid sibi ergo vult, quod hic ait: Hæc autem vobis ab inítio non dixi, quia vobíscum eram: nisi quia ea, quæ hic dicit de Spíritu Sancto, quod sit ventúrus ad eos, et testimónium perhibitúrus, quando mala illa passúri sunt, hæc ab inítio eis non dixit, quia cum ipsis erat? Consolátor ergo ille, vel advocátus (utrúmque enim interpretátur, quod erat Græce Paráclitus), Christo abscedénte fúerat necessárius: et ídeo de illo non díxerat ab inítio, quando cum illis erat, quia ejus præséntia consolabántur.")  ; L9
        )
        :responsories
        (
        (:respond "Si oblítus fúero tui, allelúja, obliviscátur mei déxtera mea: * Adhǽreat lingua mea fáucibus meis, si non memínero tui, allelúja, allelúja." :verse "Super flúmina Babylónis illic sédimus et flévimus, dum recordarémur tui, Sion." :repeat "Adhǽreat lingua mea fáucibus meis, si non memínero tui, allelúja, allelúja.")  ; R1
        (:respond "Vidérunt te aquæ, Deus, vidérunt te aquæ, et timuérunt: * Multitúdo sónitus aquárum vocem dedérunt nubes, allelúja, allelúja, allelúja." :verse "Illuxérunt coruscatiónes tuæ orbi terræ: vidit et commóta est terra." :repeat "Multitúdo sónitus aquárum vocem dedérunt nubes, allelúja, allelúja, allelúja.")  ; R2
        (:respond "Narrábo nomen tuum frátribus meis, allelúja: * In médio Ecclésiæ laudábo te, allelúja, allelúja." :verse "Confitébor tibi in pópulis, Dómine, et psalmum dicam tibi in géntibus." :repeat "In médio Ecclésiæ laudábo te, allelúja, allelúja.")  ; R3
        (:respond "In ecclésiis benedícite Deo, allelúja: * Dómino de fóntibus Israël, allelúja, allelúja." :verse "Psalmum dícite nómini ejus, date glóriam laudi ejus." :repeat "Dómino de fóntibus Israël, allelúja, allelúja.")  ; R4
        (:respond "In toto corde meo, allelúja, exquisívi te, allelúja: * Ne repéllas me a mandátis tuis, allelúja, allelúja." :verse "Benedíctus es tu, Dómine, doce me justificatiónes tuas." :repeat "Ne repéllas me a mandátis tuis, allelúja, allelúja.")  ; R5
        (:respond "Hymnum cantáte nobis, allelúja: * Quómodo cantábimus cánticum Dómini in terra aliéna? allelúja, allelúja." :verse "Illic interrogavérunt nos, qui captívos duxérunt nos, verba cantiónum." :repeat "Quómodo cantábimus cánticum Dómini in terra aliéna? allelúja, allelúja.")  ; R6
        (:respond "Deus, cánticum novum cantábo tibi, allelúja: * In psaltério decem chordárum psallam tibi, allelúja, allelúja." :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te." :repeat "In psaltério decem chordárum psallam tibi, allelúja, allelúja.")  ; R7
        (:respond "Bonum est confitéri Dómino, allelúja: * Et psállere, allelúja." :verse "In decachórdo psaltério, cum cántico et cíthara." :repeat "Et psállere, allelúja.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  vado-ad-eum-qui-misit
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  vado-ad-eum-qui-misit
        :lauds-capitulum      omne-datum-optimum
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       propter-quod-abicientes
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon vado-ad-eum-sed-quia
        ))


    (5
     . (:lessons
        (
        (:ref "1 Pet 1:1-5" :source "Incipit Epístola prima beáti Petri Apóstoli" :text "Petrus Apóstolus Jesu Christi, eléctis ádvenis dispersiónis Ponti, Galátiæ, Cappadóciæ, Ásíæ, et Bithýniæ, secúndum præsciéntiam Dei Patris, in sanctificatiónem Spíritus, in obediéntiam, et aspersiónem sánguinis Jesu Christi. Grátia vobis, et pax multiplicétur. Benedíctus Deus et Pater Dómini nostri Jesu Christi, qui secúndum misericórdiam suam magnam regenerávit nos in spem vivam, per resurrectiónem Jesu Christi ex mórtuis, in hæreditátem incorruptíbilem, et incontaminátam, et immarcescíbilem, conservátam in cælis in vobis, qui in virtúte Dei custodímini per fidem in salútem, parátam revelári in témpore novíssimo.")  ; L1
        (:ref "1 Pet 1:6-12" :text "In quo exsultábitis, módicum nunc si opórtet contristári in váriis tentatiónibus: ut probátio vestræ fídei multo pretiósior auro (quod per ignem probátur) inveniátur in laudem, et glóriam, et honórem in revelatióne Jesu Christi: quem cum non vidéritis, dilígitis: in quem nunc quoque non vidéntes créditis: credéntes autem exsultábitis lætítia inenarrábili, et glorificáta: reportántes finem fídei vestræ, salútem animárum. De qua salúte exquisiérunt, atque scrutáti sunt prophétæ, qui de futúra in vobis grátia prophetavérunt: scrutántes in quod vel quale tempus significáret in eis Spíritus Christi: prænúntians eas quæ in Christo sunt passiónes, et posterióres glórias: quibus revelátum est quia non sibimetípsis, vobis autem ministrábant ea quæ nunc nuntiáta sunt vobis per eos qui evangelizavérunt vobis, Spíritu Sancto misso de cælo, in quem desíderant ángeli prospícere.")  ; L2
        (:ref "1 Pet 1:13-21" :text "Propter quod succíncti lumbos mentis vestræ, sóbrii, perfécte speráte in eam, quæ offértur vobis, grátiam, in revelatiónem Jesu Christi: quasi fílii obediéntiæ, non configuráti prióribus ignorántiæ vestræ desidériis: sed secúndum eum qui vocávit vos, Sanctum: et ipsi in omni conversatióne sancti sitis: quóniam scriptum est: Sancti éritis, quóniam ego sanctus sum. Et si patrem invocátis eum, qui sine acceptióne personárum júdicat secúndum uniuscujúsque opus, in timóre incolátus vestri témpore conversámini. Sciéntes quod non corruptibílibus, auro vel argénto, redémpti estis de vana vestra conversatióne patérnæ traditiónis: sed pretióso sánguine quasi agni immaculáti Christi, et incontamináti: præcógniti quidem ante mundi constitutiónem, manifestáti autem novíssimis tempóribus propter vos, qui per ipsum fidéles estis in Deo, qui suscitávit eum a mórtuis, et dedit ei glóriam, ut fides vestra et spes esset in Deo.")  ; L3
        (:ref "Post médium" :source "Ex libro sancti Ambrósii Epíscopi de fide resurrectiónis" :text "Quóniam Dei mori non póterat Sapiéntia, resúrgere autem non póterat quod mórtuum non erat; assúmitur caro, quæ mori posset: ut dum móritur quod solet, quod mórtuum fúerat, hoc resúrgeret. Neque enim póterat esse, nisi per hóminem, resurréctio: quóniam sicut per hóminem mors, ita et per hóminem resurréctio mortuórum. Ergo resurréxit homo, quóniam homo mórtuus est: resuscitátus homo, sed resúscitans Deus. Tunc secúndum carnem homo, nunc per ómnia Deus. Nunc enim secúndum carnem jam nóvimus Christum, sed carnis grátiam tenémus, ut ipsum primítias quiescéntium, ipsum primogénitum ex mórtuis novérimus.")  ; L4
        (:text "Primítiæ útique ejúsdem sunt géneris atque natúræ, cujus et réliqui fructus: quorum pro lætióre provéntu primitíva Deo múnera deferúntur; sacrum munus pro ómnibus, et quasi reparátæ quædam liba natúræ. Primítiæ ergo quiescéntium Christus. Sed utrum suórum quiescéntium, qui quasi mortis exsórtes, dulci quodam sopóre tenéntur, an ómnium mortuórum? Sed sicut in Adam omnes moriúntur, ita et in Christo omnes vivificabúntur. Itaque sicut primítiæ mortis in Adam, ita étiam primítiæ resurrectiónis in Christo omnes resúrgent. Sed nemo despéret, neque justus dóleat commúne consórtium resurgéndi, cum præcípuum fructum virtútis exspéctet. Omnes quidem resúrgent, sed unusquísque, ut ait Apóstolus, in suo órdine. Commúnis est divínæ fructus cleméntiæ, sed distínctus ordo meritórum.")  ; L5
        (:text "Advértimus, quam grave sit sacrilégium, resurrectiónem non crédere. Si enim non resurgémus, ergo Christus gratis mórtuus est, ergo Christus non resurréxit. Si enim nobis non resurréxit, útique non resurréxit, qui sibi cur resúrgeret, non habébat. Resurréxit in eo mundus, resurréxit in eo cælum, resurréxit in eo terra. Erit enim cælum novum, et terra nova. Sibi autem non erat necessária resurréctio, quem mortis víncula non tenébant. Nam etsi secúndum hóminem mórtuus, in ipsis tamen erat liber inférnis. Vis scire quam liber? Factus sum sicut homo sine adjutório, inter mórtuos liber. Et bene liber, qui se póterat suscitáre, juxta quod scriptum est: Sólvite hoc templum, et in tríduo resuscitábo illud. Et bene liber, qui álios descénderat redemptúrus.")  ; L6
        (:ref "Joann 16:23-30" :source "Léctio sancti Evangélii secúndum Joánnem" :text "In illo témpore: Dixit Jesus discípulis suis: Amen, amen dico vobis: si quid petiéritis Patrem in nómine meo, dabit vobis. Et réliqua. Homília sancti Augustíni Epíscopi !Tractátus 102 in Joánnem Dómini verba nunc ista tractánda sunt: Amen, amen, dico vobis: Si quid petiéritis Patrem in nómine meo, dabit vobis. Jam dictum est in superióribus hujus Domínici sermónis pártibus, propter eos, qui nonnúlla petunt a Patre in Christi nómine, nec accípiunt: non peti in nómine Salvatóris, quidquid pétitur contra ratiónem salútis. Non enim sonum litterárum ac syllabárum, sed quod sonus ipse signíficat, et quod eo sono recte ac veráciter intellégitur, hoc accipiéndus est dícere, cum dicit: In nómine meo.")  ; L7
        (:text "Unde qui hoc sentit de Christo, quod non est de único Dei Fílio sentiéndum, non petit in ejus nómine, etiámsi non táceat lítteris ac sýllabis Christum: quóniam in ejus nómine petit, quem cógitat cum petit. Qui vero quod est de illo sentiéndum sentit, ipse in ejus nómine petit: et áccipit quod petit, si non contra suam salútem sempitérnam petit. Accipit autem quando debet accípere. Quædam enim non negántur: sed ut cóngruo dentur témpore differúntur. Ita sane intelligéndum est quod ait: Dabit vobis: ut ea benefícia significáta sciántur his verbis, quæ ad eos, qui petunt, próprie pértinent. Exaudiúntur quippe omnes Sancti pro seípsis, non autem pro ómnibus exaudiúntur vel amícis, vel inimícis suis, vel quibúslibet áliis: quia non utcúmque dictum est, Dabit; sed, Dabit vobis.")  ; L8
        (:text "Usque modo, inquit, non petístis quidquam in nómine meo. Pétite, et accipiétis, ut gáudium vestrum sit plenum. Hoc quod dicit, gáudium plenum, profécto non carnále, sed spiritále gáudium est: et quando tantum erit, ut áliquid ei jam non sit addéndum, proculdúbio tunc erit plenum. Quidquid ergo pétitur, quod pertíneat ad hoc gáudium consequéndum, hoc est in nómine Christi peténdum, si divínam intellígimus grátiam, si vere beátam póscimus vitam. Quidquid autem áliud pétitur, nihil pétitur: non quia nulla omníno res est, sed quia in tantæ rei comparatióne quidquid áliud concupíscitur, nihil est.")  ; L9
        )
        :responsories
        (
        (:respond "Si oblítus fúero tui, allelúja, obliviscátur mei déxtera mea: * Adhǽreat lingua mea fáucibus meis, si non memínero tui, allelúja, allelúja." :verse "Super flúmina Babylónis illic sédimus et flévimus, dum recordarémur tui, Sion." :repeat "Adhǽreat lingua mea fáucibus meis, si non memínero tui, allelúja, allelúja.")  ; R1
        (:respond "Vidérunt te aquæ, Deus, vidérunt te aquæ, et timuérunt: * Multitúdo sónitus aquárum vocem dedérunt nubes, allelúja, allelúja, allelúja." :verse "Illuxérunt coruscatiónes tuæ orbi terræ: vidit et commóta est terra." :repeat "Multitúdo sónitus aquárum vocem dedérunt nubes, allelúja, allelúja, allelúja.")  ; R2
        (:respond "Narrábo nomen tuum frátribus meis, allelúja: * In médio Ecclésiæ laudábo te, allelúja, allelúja." :verse "Confitébor tibi in pópulis, Dómine, et psalmum dicam tibi in géntibus." :repeat "In médio Ecclésiæ laudábo te, allelúja, allelúja.")  ; R3
        (:respond "In ecclésiis benedícite Deo, allelúja: * Dómino de fóntibus Israël, allelúja, allelúja." :verse "Psalmum dícite nómini ejus, date glóriam laudi ejus." :repeat "Dómino de fóntibus Israël, allelúja, allelúja.")  ; R4
        (:respond "In toto corde meo, allelúja, exquisívi te, allelúja: * Ne repéllas me a mandátis tuis, allelúja, allelúja." :verse "Benedíctus es tu, Dómine, doce me justificatiónes tuas." :repeat "Ne repéllas me a mandátis tuis, allelúja, allelúja.")  ; R5
        (:respond "Hymnum cantáte nobis, allelúja: * Quómodo cantábimus cánticum Dómini in terra aliéna? allelúja, allelúja." :verse "Illic interrogavérunt nos, qui captívos duxérunt nos, verba cantiónum." :repeat "Quómodo cantábimus cánticum Dómini in terra aliéna? allelúja, allelúja.")  ; R6
        (:respond "Deus, cánticum novum cantábo tibi, allelúja: * In psaltério decem chordárum psallam tibi, allelúja, allelúja." :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te." :repeat "In psaltério decem chordárum psallam tibi, allelúja, allelúja.")  ; R7
        (:respond "Bonum est confitéri Dómino, allelúja: * Et psállere, allelúja." :verse "In decachórdo psaltério, cum cántico et cíthara." :repeat "Et psállere, allelúja.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  usque-modo-non-petistis
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  usque-modo-non-petistis
        :lauds-capitulum      estote-factores-verbi
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       religio-munda
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon petite-et-accipietis
        ))


    (6
     . (:lessons
        (
        (:ref "1 Joann 1:1-5" :source "Incipit Epístola prima beáti Joánnis Apóstoli" :text "Quod fuit ab inítio, quod audívimus, quod vídimus óculis nostris, quod perspéximus, et manus nostræ contrectavérunt de verbo vitæ: et vita manifestáta est, et vídimus, et testámur, et annuntiámus vobis vitam ætérnam, quæ erat apud Patrem, et appáruit nobis: quod vídimus et audívimus, annuntiámus vobis, ut et vos societátem habeátis nobíscum, et socíetas nostra sit cum Patre, et cum Fílio ejus Jesu Christo. Et hæc scríbimus vobis ut gaudeátis, et gáudium vestrum sit plenum. Et hæc est annuntiátio, quam audívimus ab eo, et annuntiámus vobis: quóniam Deus lux est, et ténebræ in eo non sunt ullæ.")  ; L1
        (:ref "1 Joann 1:6-10" :text "Si dixérimus quóniam societátem habémus cum eo, et in ténebris ambulámus, mentímur, et veritátem non fácimus. Si autem in luce ambulámus sicut et ipse est in luce, societátem habémus ad ínvicem, et sanguis Jesu Christi, Fílii ejus, emúndat nos ab omni peccáto. Si dixérimus quóniam peccátum non habémus, ipsi nos sedúcimus, et véritas in nobis non est. Si confiteámur peccáta nostra: fidélis est, et justus, ut remíttat nobis peccáta nostra, et emúndet nos ab omni iniquitáte. Si dixérimus quóniam non peccávimus, mendácem fácimus eum, et verbum ejus non est in nobis.")  ; L2
        (:ref "1 Joann 2:1-6" :text "Filíoli mei, hæc scribo vobis, ut non peccétis. Sed et si quis peccáverit, advocátum habémus apud Patrem, Jesum Christum justum: et ipse est propitiátio pro peccátis nostris: non pro nostris autem tantum, sed étiam pro totíus mundi. Et in hoc scimus quóniam cognóvimus eum, si mandáta ejus observémus. Qui dicit se nosse eum, et mandáta ejus non custódit, mendax est, et in hoc véritas non est. Qui autem servat verbum ejus, vere in hoc cáritas Dei perfécta est: et in hoc scimus quóniam in ipso sumus. Qui dicit se in ipso manére, debet, sicut ille ambulávit, et ipse ambuláre.")  ; L3
        (:ref "Sermo 2 de Ascensióne Dómini (175 de Témpore)" :source "Sermo sancti Augustíni Epíscopi" :text "Salvátor noster, dilectíssimi fratres, ascéndit in cælum: non ergo turbémur in terra. Ibi sit mens, et hic erit réquies. Ascendámus cum Christo ínterim corde: cum dies ejus promíssus advénerit, sequémur et córpore. Scire tamen debémus, fratres, quia cum Christo non ascéndit supérbia, non avarítia, non luxúria: nullum vítium nostrum ascéndit cum médico nostro. Et ídeo si post médicum desiderámus ascéndere, debémus vítia et peccáta depónere. Omnes enim quasi quibúsdam compédibus nos premunt, et peccatórum nos rétibus ligáre conténdunt: et ídeo cum Dei adjutório, secúndum quod ait Psalmísta: Dirumpámus víncula eórum: ut secúri possímus dícere Dómino: Dirupísti víncula mea, tibi sacrificábo hóstiam laudis.")  ; L4
        (:text "Resurréctio Dómini spes nostra est: ascénsio Dómini glorificátio nostra est. Ascensiónis hódie solémnia celebrámus. Si ergo recte, si fidéliter, si devóte, si sancte, si pie ascensiónem Dómini celebrámus, ascendámus cum illo, et sursum corda habeámus. Ascendéntes autem non extollámur, nec de nostris, quasi de própriis méritis præsumámus. Sursum autem corda habére debémus ad Dóminum. Sursum enim cor non ad Dóminum, supérbia vocátur: sursum autem cor ad Dóminum, refúgium vocátur. Vidéte, fratres, magnum miráculum. Altus est Deus: érigis te, et fugit a te: humílias te, et descéndit ad te. Quare hoc? Quia excélsus est, et humília réspicit, et alta de longe cognóscit. Humília de próximo réspicit, ut attóllat: alta, id est, supérba, de longe cognóscit, ut déprimat.")  ; L5
        (:text "Resurréxit enim Christus, ut spem nobis daret, quia surgit homo, qui móritur: ne moriéndo desperarémus, et vitam nostram in morte finítam putarémus, secúros nos fecit. Sollíciti enim erámus de ipsa ánima: et ille nobis resurgéndo, de carnis resurrectióne fidúciam dedit. Crede ergo, ut mundéris. Prius te opórtet crédere, ut póstea per fidem Deum mereáris aspícere. Deum enim vidére vis? Audi ipsum: Beáti mundo corde: quóniam ipsi Deum vidébunt. Prius ergo cógita de corde mundándo: quidquid ibi vides, quod dísplicet Deo, tolle.")  ; L6
        (:ref "Joann 15:26-27; 16:1-4" :source "Léctio sancti Evangélii secúndum Joánnem" :text "In illo témpore: Dixit Jesus discípulis suis: Cum vénerit Paráclitus, quem ego mittam vobis a Patre, Spíritum veritátis, qui a Patre procédit, ille testimónium perhibébit de me. Et réliqua. Homília sancti Augustíni Epíscopi !Tractátus 92 in Joánnem Dóminus Jesus in sermóne, quem locútus est discípulis suis post cenam, próximus passióni, tamquam itúrus, et relictúrus eos præséntia corporáli, cum ómnibus autem suis usque in consummatiónem sǽculi futúrus præséntia spiritáli, exhortátus est eos ad perferéndas persecutiónes impiórum, quos mundi nómine nuncupávit. Ex quo tamen mundo étiam ipsos discípulos se elegísse dixit: ut scirent se Dei grátia esse, quod sunt; suis autem vítiis fuísse, quod fuérunt.")  ; L7
        (:text "Deínde persecutóres et suos et ipsórum, Judǽos evidénter expréssit: ut omníno apparéret étiam ipsos mundi damnábilis appellatióne conclúsos, qui persequúntur sanctos. Cumque de illis díceret, quod ignorárent eum a quo missus est; et tamen odíssent et Fílium, et Patrem, hoc est, et eum qui missus est, et eum a quo missus est: (de quibus ómnibus in áliis sermónibus jam disserúimus) ad hoc pervénit, ubi ait: Ut adimpleátur sermo, qui in lege eórum scriptus est: Quia ódio habuérunt me gratis.")  ; L8
        (:text "Deínde tamquam consequénter adjúnxit, unde modo disputáre suscépimus: Cum autem vénerit Paráclitus, quem ego mittam vobis a Patre, Spíritum veritátis, qui a Patre procédit, ille testimónium perhibébit de me: et vos testimónium perhibébitis, quia ab inítio mecum estis. Quid hoc pértinet ad illud quod díxerat: Nunc autem et vidérunt, et odérunt et me, et Patrem meum: sed ut impleátur sermo, qui in lege eórum scriptus est: Quia ódio habuérunt me gratis? An quia Paráclitus quando venit Spíritus veritátis, eos, qui vidérunt, et adhuc óderant, testimónio manifestióre convícit? Immo vero étiam áliquos ex illis qui vidérunt, et adhuc óderant, ad fidem, quæ per dilectiónem operátur, sui manifestatióne convértit.")  ; L9
        )
        :responsories
        (
        (:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja: * Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja." :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris." :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja.")  ; R1
        (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera: * Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja." :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus." :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja.")  ; R2
        (:respond "Exaltáre, Dómine, allelúja, * In virtúte tua, allelúja." :verse "Eleváta est magnificéntia tua super cælos, Deus." :repeat "In virtúte tua, allelúja.")  ; R3
        (:respond "Tempus est, ut revértar ad eum, qui me misit, dicit Dóminus: nolíte contristári, nec turbétur cor vestrum: * Rogo pro vobis Patrem, ut ipse vos custódiat, allelúja, allelúja." :verse "Nisi ego abíero, Paráclitus non véniet: cum assúmptus fúero, mittam vobis eum." :repeat "Rogo pro vobis Patrem, ut ipse vos custódiat, allelúja, allelúja.")  ; R4
        (:respond "Non turbétur cor vestrum: ego vado ad Patrem; et cum assúmptus fúero a vobis, mittam vobis, allelúja, * Spíritum veritátis, et gaudébit cor vestrum, allelúja." :verse "Ego rogábo Patrem, et álium Paráclitum dabit vobis." :repeat "Spíritum veritátis, et gaudébit cor vestrum, allelúja.")  ; R5
        (:respond "Ascéndens Christus in altum, captívam duxit captivitátem, * Dedit dona homínibus, allelúja, allelúja, allelúja." :verse "Ascéndit Deus in jubilatióne, et Dóminus in voce tubæ." :repeat "Dedit dona homínibus, allelúja, allelúja, allelúja.")  ; R6
        (:respond "Ego rogábo Patrem, et álium Paráclitum dabit vobis, * Ut máneat vobíscum in ætérnum, Spíritum veritátis, allelúja." :verse "Si enim non abíero, Paráclitus non véniet ad vos: si autem abíero, mittam eum ad vos." :repeat "Ut máneat vobíscum in ætérnum, Spíritum veritátis, allelúja.")  ; R7
        (:respond "Si enim non abíero, Paráclitus non véniet ad vos: si autem abíero, mittam eum ad vos. * Cum autem vénerit ille, docébit vos omnem veritátem, allelúja." :verse "Non enim loquétur a semetípso: sed quæcúmque áudiet, loquétur: et quæ ventúra sunt, annuntiábit vobis." :repeat "Cum autem vénerit ille, docébit vos omnem veritátem, allelúja.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  cum-venerit-paraclitus
        ;; ── Lauds ──────────────────────────────────────────────────
        :benedictus-antiphon  cum-venerit-paraclitus
        :lauds-capitulum      estote-prudentes
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       si-quis-loquitur
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon haec-locutus-sum-vobis
        ))

    ;; ── Easter 7: Pentecost (Duplex I classis) ──
    ;; 1 nocturn, Psalms 47/67/103 (NOT dominical!), 3 lessons from Gregory Hom. 30 on John 14:23-31
    (7
     . (:one-nocturn t
        :invitatory alleluia-spiritus-domini-replevit
        :hymn jam-christus-astra-ascenderat
        :psalms ((factus-est-repente-de-caelo . 47)
                 (confirma-hoc-deus . 67)
                 (emitte-spiritum-tuum . 103))
        :versicle ("Spíritus Dómini replévit orbem terrárum, allelúja."
                   . "Et hoc quod cóntinet ómnia, sciéntiam habet vocis, allelúja.")
        :versicle-en ("The Spirit of the Lord filleth the world, alleluia."
                      . "And That Which containeth all things hath knowledge of the voice, alleluia.")
        :lessons
        ((:ref "Joann 14:23-31" :source "Léctio sancti Evangélii secúndum Joánnem"
          :text "In illo témpore: Dixit Jesus discípulis suis: Si quis díligit me, sermónem meum servábit, et Pater meus díliget eum, et ad eum veniémus, et mansiónem apud eum faciémus. Et réliqua.\n\nHomilía sancti Gregórii Papæ\nHomilia 30 in Evangelia\n\nLibet, fratres caríssimi, evangélicæ verba lectiónis sub brevitáte transcúrrere, ut post diútius líceat in contemplatióne tantæ solemnitátis immorári. Hódie namque Spíritus Sanctus repentíno sónitu super discípulos venit, mentésque carnálium in sui amórem permutávit, et foris apparéntibus linguis ígneis, intus facta sunt corda flammántia; quia dum Deum in ignis visióne suscepérunt, per amórem suáviter arsérunt. Ipse namque Spíritus Sanctus amor est: unde et Joánnes dicit Deus cáritas est. Qui ergo mente íntegra Deum desíderat, profécto jam habet, quem amat. Neque enim quisquam posset Deum dilígere, si eum quem díligit, non habéret.")  ; L1
         (:text "Sed ecce, si unusquísque vestrum requirátur an díligat Deum: tota fidúcia et secúra mente respóndet, Díligo. In ipso autem lectiónis exórdio audístis quid Véritas dicit: Si quis díligit me, sermónem meum servábit. Probátio ergo dilectiónis, exhibítio est óperis. Hinc in epístola sua idem Joánnes dicit: Qui dicit: Díligo Deum, et mandáta ejus non custódit, mendax est. Vere étenim Deum dilígimus et mandáta ejus custodímus, si nos a nostris voluptátibus coarctámus. Nam qui adhuc per illícita desidéria díffluit, profécto Deum non amat: quia ei in sua voluntáte contradícit.")  ; L2
         (:text "Et Pater meus díliget eum, et ad eum veniémus, et mansiónem apud eum faciémus. Pensáte, fratres caríssimi, quanta sit ista dígnitas, habére in cordis hospítio advéntum Dei. Certe, si domum nostram quisquam dives aut prǽpotens amícus intráret, omni festinántia domus tota mundarétur, ne quid fortásse esset, quod óculos amíci intrántis offénderet. Tergat ergo sordes pravi óperis, qui Deo prǽparat domum mentis. Sed vidéte quid Véritas dicat: Veniémus, et mansiónem apud eum faciémus. In quorúmdam étenim corda venit, et mansiónem non facit: quia, per compunctiónem quidem, Dei respéctum percípiunt, sed tentatiónis témpore hoc ipsum quo compúncti fúerant, obliviscúntur; sicque ad perpetránda peccáta rédeunt, ac si hæc mínime planxíssent.")  ; L3
         )
        :responsories
        ((:respond "Cum compleréntur dies Pentecóstes, erant omnes páriter in eódem loco, allelúja: et súbito factus est sonus de cælo, allelúja, * Tamquam spíritus veheméntis, et replévit totam domum, allelúja, allelúja."
          :verse "Dum ergo essent in unum discípuli congregáti propter metum Judæórum, sonus repénte de cælo, venit super eos."
          :repeat "Tamquam spíritus veheméntis, et replévit totam domum, allelúja, allelúja.")  ; R1
         (:respond "Repléti sunt omnes Spíritu Sancto: et cœpérunt loqui, prout Spíritus Sanctus dabat éloqui illis: * Et convénit multitúdo dicéntium, allelúja."
          :verse "Loquebántur váriis linguis Apóstoli magnália Dei."
          :repeat "Et convénit multitúdo dicéntium, allelúja."
          :gloria t)  ; R2 — with Gloria Patri
         )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  non-vos-relinquam
        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (cum-complerentur-dies
                          spiritus-domini-replevit
                          repleti-sunt-omnes-spiritu
                          fontes-et-omnia
                          loquebantur-variis)
        :benedictus-antiphon  accipite-spiritum-sanctum
        :lauds-capitulum      cum-complerentur-dies-cap
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       judaei-quoque
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon hodie-completi-sunt
        ))

    )
  "Eastertide dominical Matins data: lessons and responsories.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-season-easter-collect (date)
  "Return the collect incipit symbol for the Eastertide Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns nil outside Eastertide."
  (let ((n (bcp-roman-season-easter--sunday-number date)))
    (when (and n (< n (length bcp-roman-season-easter--collects)))
      (aref bcp-roman-season-easter--collects n))))

(defun bcp-roman-season-easter-dominical-matins (date)
  "Return dominical Matins data for the Eastertide Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories.
For Easter 0 and Easter 7, the plist also includes :one-nocturn t,
:invitatory, :hymn, :psalms, :versicle, and :versicle-en.
Returns nil if DATE is outside Eastertide."
  (let ((n (bcp-roman-season-easter--sunday-number date)))
    (when n
      (cdr (assq n bcp-roman-season-easter--dominical-matins)))))

(defun bcp-roman-season-easter-dominical-hours (date)
  "Return non-Matins hour data for the Eastertide Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns the same plist as `dominical-matins'
\(which contains both Matins and non-Matins keys), or nil outside Eastertide.
Non-Matins keys are optional; absent means use psalterium default."
  (bcp-roman-season-easter-dominical-matins date))

(provide 'bcp-roman-season-easter)

;;; bcp-roman-season-easter.el ends here
