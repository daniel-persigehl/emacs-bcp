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

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Ferial Matins lessons and responsories

;; Eastertide ferial Matins (DA 1911): 1 nocturn, 3 scripture lessons + 3 responsories.
;; Easter octave and Pentecost octave days have Te Deum instead of R3
;; (only 2 responsories in the data for those days).
;;
;; Key: (WEEK . DOW) where WEEK is 0 (Easter octave), 1-6 (post-octave), 7 (Pentecost);
;;      DOW is 1=Mon..6=Sat.
;; Pentecost Vigil Saturday (Pasc6-6) excluded — special vigil office.

(defconst bcp-roman-season-easter--ferial-matins
  '(
    ;; Pasc0-1: Die II infra octavam Paschæ
    ((0 . 1) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Homilia 23 in Evangelia"
               :text "In illo témpore: Duo ex discípulis Jesu ibant ipsa die in castéllum, quod erat in spátio stadiórum sexagínta ab Jerúsalem, nómine Emmaus. Et réliqua.
Homilía sancti Gregórii Papæ
Audístis, fratres caríssimi, quia duóbus discípulis ambulántibus in via, non quidem credéntibus, sed tamen de se loquéntibus, Dóminus appáruit: sed eis spéciem, quam recognóscerent, non osténdit. Hoc ergo egit foris Dóminus in óculis córporis, quod apud ipsos agebátur intus in óculis cordis. Ipsi namque apud semetípsos intus et amábant, et dubitábant: eis autem Dóminus foris et præsens áderat, et quis esset non ostendébat. De se ergo loquéntibus præséntiam exhíbuit: sed de se dubitántibus cognitiónis suæ spéciem abscóndit.")
               (:text "Verba quidem cóntulit, durítiam intelléctus increpávit, sacræ Scriptúræ mystéria, quæ de seípso erant, apéruit: et tamen quia adhuc in eórum córdibus peregrínus erat a fide, se ire lóngius finxit. Fíngere namque, compónere dícimus: unde et compositóres luti, fígulos vocámus. Nihil ergo simplex Véritas per duplicitátem fecit: sed talem se eis exhíbuit in córpore, qualis apud illos erat in mente. Probándi autem erant, si hi, qui eum etsi necdum ut Deum dilígerent, saltem ut peregrínum amáre potuíssent.")
               (:text "Sed quia esse extránei a caritáte non póterant hi, cum quibus Véritas gradiebátur: eum ad hospítium quasi peregrínum vocant. Cur autem dícimus, vocant, cum illic scriptum sit: Et coëgérunt eum? Ex quo nimírum exémplo collígitur, quia peregríni ad hospítium non solum invitándi sunt, sed étiam trahéndi. Mensam ígitur ponunt, panes cibósque ófferunt: et Deum, quem in Scriptúræ sacræ expositióne non cognóverant, in panis fractióne cognóscunt. Audiéndo ergo præcépta Dei illumináti non sunt, faciéndo illumináti sunt: quia scriptum est: Non auditóres legis justi sunt apud Deum, sed factóres legis justificabúntur. Quisquis ergo vult audíta intellégere, festínet ea, quæ jam audíre pótuit, ópere implére. Ecce Dóminus non est cógnitus dum loquerétur, et dignátus est cognósci, dum páscitur."))
              :responsories
              ((:respond "María Magdaléne, et áltera María ibant dilúculo ad monuméntum:"
                  :verse "Et valde mane una sabbatórum véniunt ad monuméntum, orto jam sole: et introëúntes vidérunt júvenem sedéntem in dextris, qui dixit illis."
                  :repeat "Jesum quem quǽritis, non est hic, surréxit sicut locútus est, præcédet vos in Galilǽam, ibi eum vidébitis, allelúja, allelúja."
                  :gloria nil)
               (:respond "Surréxit pastor bonus, qui ánimam suam pósuit pro óvibus suis, et pro grege suo mori dignátus est:"
                  :verse "Etenim Pascha nostrum immolátus est Christus."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc0-2: Die III infra octavam Paschæ
    ((0 . 2) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Liber 10. Comment. in Lucam, cap. 24, ante finem"
               :text "In illo témpore: Stetit Jesus in médio discipulórum, et dicit eis: Pax vobis: ego sum, nolíte timére. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Mirum, quo modo se natúra corpórea per impenetrábile corpus infúderit invisíbili áditu, visíbili conspéctu: tangi fácilis, diffícilis æstimári. Dénique conturbáti discípuli æstimábant se spíritum vidére. Et ídeo Dóminus, ut spéciem nobis resurrectiónis osténderet: Palpáte, inquit, et vidéte, quia spíritus carnem et ossa non habet, sicut me vidétis habére. Non ergo per incorpóream natúram, sed per resurrectiónis qualitátem, impérvia usu clausa penetrávit. Nam quod tángitur, corpus est: quod palpátur, corpus est.")
               (:text "In córpore autem resurgémus. Seminátur enim corpus animále, surgit corpus spiritále: sed illud subtílius, hoc crássius, útpote adhuc terrénæ labis qualitáte concrétum. Nam quómodo non corpus, in quo manébant insígnia vúlnerum, vestígia cicatrícum, quæ Dóminus palpánda óbtulit? In quo non solum fidem firmat, sed étiam devotiónem ácuit, quod vúlnera suscépta pro nobis cælo inférre máluit, abolére nóluit: ut Deo Patri nostræ prétia libertátis osténderet. Talem sibi Pater ad déxteram locat, trophǽum nostræ salútis ampléctens: tales illic Mártyres nobis cicatrícis suæ coróna monstrávit.")
               (:text "Et quóniam sermo huc noster evásit, considerémus qua grátia secúndum Joánnem credíderint Apóstoli, qui gavísi sunt; secúndum Lucam quasi incréduli redarguántur: ibi Spíritum Sanctum accéperint, hic sedére in civitáte jubeántur, quoadúsque induántur virtúte ex alto. Et vidétur mihi ille quasi Apóstolus majóra et altióra tetigísse, hic sequéntia et humánis próxima: hic histórico usus circúitu, ille compéndio: quia et de illo dubitári non potest, qui testimónium pérhibet de iis, quibus ipse intérfuit, et verum est testimónium ejus: et ab hoc quoque, qui Evangelísta esse méruit, vel negligéntiæ, vel mendácii suspiciónem æquum est propulsári. Et ídeo verum putámus utrúmque, non sententiárum varietáte, nec personárum diversitáte distínctum. Nam etsi primo Lucas eos non credidísse dicat, póstea tamen credidísse demónstrat: et si prima considerémus, contrária sunt: si sequéntia, certum est conveníre."))
              :responsories
              ((:respond "Virtúte magna reddébant Apóstoli,"
                  :verse "Repléti quidem Spíritu Sancto loquebántur cum fidúcia verbum Dei."
                  :repeat "Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja."
                  :gloria nil)
               (:respond "De ore prudéntis procédit mel, allelúja: dulcédo mellis est sub língua ejus, allelúja:"
                  :verse "Sapiéntia requiéscit in corde ejus, et prudéntia in sermóne oris illíus."
                  :repeat "Favus distíllans lábia ejus, allelúja, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc0-3: Die IV infra octavam Paschæ
    ((0 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Homilia 24 in Evangelia"
               :text "In illo témpore: Manifestávit se íterum Jesus discípulis ad mare Tiberíadis. Manifestávit autem sic: Erant simul Simon Petrus, et Thomas, qui dícitur Dídymus. Et réliqua.
Homilía sancti Gregórii Papæ
Léctio sancti Evangélii, quæ modo in áuribus vestris lecta est, fratres mei, quæstióne ánimum pulsat, sed pulsatióne sua vim discretiónis índicat. Quæri étenim potest, cur Petrus, qui piscátor ante conversiónem fuit, post conversiónem ad piscatiónem rédiit: et cum Véritas dicat: Nemo mittens manum suam ad arátrum, et aspíciens retro, aptus est regno Dei: cur repétiit quod derelíquit? Sed si virtus discretiónis inspícitur, cítius vidétur: quia nimírum negótium, quod ante conversiónem sine peccáto éxstitit, hoc étiam post conversiónem repétere culpa non fuit.")
               (:text "Nam piscatórem Petrum, Matthǽum vero teloneárium scimus: et post conversiónem suam ad piscatiónem Petrus rédiit, Matthǽus vero ad telónei negótium non resédit: quia áliud est victum per piscatiónem quǽrere, áliud autem telónei lucris pecúnias augére. Sunt enim pléraque negótia, quæ sine peccátis exhibéri aut vix, aut nullátenus possunt. Quæ ergo ad peccátum ímplicant, ad hæc necésse est, ut post conversiónem ánimus non recúrrat.")
               (:text "Quæri étiam potest, cur discípulis in mari laborántibus, post resurrectiónem suam Dóminus in líttore stetit, qui ante resurrectiónem suam coram discípulis in flúctibus maris ambulávit. Cujus rei rátio festíne cognóscitur, si ipsa, quæ tunc ínerat, causa pensétur. Quid enim mare, nisi præsens sǽculum signat, quod se cásuum tumúltibus, et undis vitæ corruptíbilis illídit? Quid per soliditátem líttoris, nisi illa perpetúitas quiétis ætérnæ figurátur? Quia ergo discípuli adhuc flúctibus mortális vitæ ínerant, in mari laborábant: quia autem Redémptor noster jam corruptiónem carnis excésserat, post resurrectiónem suam in líttore stabat."))
              :responsories
              ((:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus:"
                  :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria nil)
               (:respond "Ego sum vitis vera, et vos pálmites:"
                  :verse "Sicut diléxit me Pater, et ego diléxi vos."
                  :repeat "Qui manet in me, et ego in eo, hic fert fructum multum, allelúja, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc0-4: Die V infra octavam Paschæ
    ((0 . 4) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Homilia 25 in Evangelia"
               :text "In illo témpore: María stabat ad monuméntum foris, plorans. Dum ergo fleret, inclinávit se, et prospéxit in monuméntum: et vidit duos Angelos in albis, sedéntes. Et réliqua.
Homilía sancti Gregórii Papæ
María Magdaléne, quæ fúerat in civitáte peccátrix, amándo veritátem, lavit lácrimis máculas críminis: et vox Veritátis implétur, qua dícitur: Dimíssa sunt ei peccáta multa, quia diléxit multum. Quæ enim prius frígida peccándo remánserat, póstmodum amándo fórtiter ardébat. Nam postquam venit ad monuméntum, ibíque corpus Domínicum non invénit, sublátum crédidit, atque discípulis nuntiávit: qui veniéntes vidérunt, atque ita esse, ut múlier díxerat, credidérunt. Et de eis prótinus scriptum est: Abiérunt ergo discípuli ad semetípsos: ac deínde subjúngitur: María autem stabat ad monuméntum foris, plorans.")
               (:text "Qua in re pensándum est, hujus mulíeris mentem quanta vis amóris accénderat, quæ a monuménto Dómini, étiam discípulis recedéntibus, non recedébat. Exquirébat quem non invénerat: flebat inquírendo, et amóris sui igne succénsa, ejus, quem ablátum crédidit, ardébat desidério. Unde cóntigit, ut eum sola tunc vidéret, quæ remánserat ut quǽreret: quia nimírum virtus boni óperis, perseverántia est: et voce Veritátis dícitur: Qui autem perseveráverit usque in finem, hic salvus erit.")
               (:text "María ergo cum fleret, inclinávit se, et prospéxit in monuméntum. Certe jam monuméntum vácuum víderat, jam sublátum Dóminum nuntiáverat: quid est, quod se íterum inclínat, íterum vidére desíderat? Sed amánti semel aspexísse non súfficit: quia vis amóris intentiónem multíplicat inquisitiónis. Quæsívit ergo prius, et mínime invénit: perseverávit ut quǽreret, unde et cóntigit, ut inveníret: actúmque est, ut desidéria diláta créscerent, et crescéntia cáperent quod inveníssent."))
              :responsories
              ((:respond "Tulérunt Dóminum meum, et néscio ubi posuérunt eum. Dicunt ei Angeli: Múlier, quid ploras? surréxit sicut dixit:"
                  :verse "Cum ergo fleret, inclinávit se, et prospéxit in monuméntum: et vidit duos Angelos in albis, sedéntes, qui dicunt ei."
                  :repeat "Præcédet vos in Galilǽam: ibi eum vidébitis, allelúja, allelúja."
                  :gloria nil)
               (:respond "Congratulámini mihi omnes qui dilígitis Dóminum, quia quem quærébam, appáruit mihi:"
                  :verse "Recedéntibus discípulis, non recedébam, et amóris ejus igne succénsa, ardébam desidério."
                  :repeat "Et dum flerem ad monuméntum, vidi Dóminum, allelúja, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc0-5: Die VI infra octavam Paschæ
    ((0 . 5) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 4 Comment. in Matth., in fine"
               :text "In illo témpore: Undecim discípuli abiérunt in Galilǽam in montem, ubi constitúerat illis Jesus. Et réliqua.
Homilía sancti Hierónymi Presbýteri
Post resurrectiónem Jesus in monte Galilǽæ conspícitur, ibíque adorátur; licet quidam dúbitent, et dubitátio eórum nostram áugeat fidem. Tunc maniféstius osténditur Thomæ, et latus láncea vulnerátum, et manus fixas demónstrat clavis. Accédens Jesus locútus est eis, dicens: Data est mihi omnis potéstas in cælo et in terra. Illi potéstas data est, qui paulo ante crucifíxus, qui sepúltus in túmulo, qui mórtuus jacúerat, qui póstea resurréxit. In cælo autem et in terra potéstas data est: ut qui ante regnábat in cælo, per fidem credéntium regnet et in terris.")
               (:text "Eúntes autem docéte omnes gentes, baptizántes eos in nómine Patris, et Fílii, et Spíritus Sancti. Primum docent omnes gentes, deínde doctas intíngunt aqua. Non enim potest fíeri, ut corpus baptísmi recípiat sacraméntum, nisi ante ánima fídei suscéperit veritátem. Baptizántur autem in nómine Patris, et Fílii, et Spíritus Sancti: ut quorum una est divínitas, una sit largítio: noménque Trinitátis, unus Deus est.")
               (:text "Docéntes eos serváre ómnia, quæcúmque mandávi vobis. Ordo præcípuus: jussit Apóstolis, ut primum docérent univérsas gentes, deínde fídei intíngerent sacraménto, et post fidem ac baptísma, quæ essent observánda præcíperent. Ac ne putémus lévia esse, quæ jussa sunt, et pauca, áddidit: Omnia quæcúmque mandávi vobis: ut quicúmque credíderint, qui in Trinitáte fúerint baptizáti, ómnia fáciant, quæ præcépta sunt. Et ecce ego vobíscum sum usque ad consummatiónem sǽculi. Qui usque ad consummatiónem sǽculi cum discípulis se futúrum esse promíttit, et illos osténdit semper esse victúros, et se nunquam a credéntibus recessúrum."))
              :responsories
              ((:respond "Surgens Jesus Dóminus noster, stans in médio discipulórum suórum, dixit:"
                  :verse "Una ergo sabbatórum, cum fores essent clausæ, ubi erant discípuli congregáti, venit Jesus, et stetit in medio eórum, et dixit eis."
                  :repeat "Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja."
                  :gloria nil)
               (:respond "Expurgáte vetus ferméntum, ut sitis nova conspérsio: étenim Pascha nostrum immolátus est Christus:"
                  :verse "Mórtuus est propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Itaque epulémur in Dómino, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc0-6: Sabbato in Albis
    ((0 . 6) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Homilia 22 in Evangelia"
               :text "In illo témpore: Una sábbati María Magdaléne venit mane, cum adhuc ténebræ essent, ad monuméntum. Et réliqua.
Homilía sancti Gregórii Papæ
Léctio sancti Evangélii, quam modo, fratres, audístis, valde in superfície histórica est apérta: sed ejus nobis sunt mystéria sub brevitáte requirénda. María Magdaléne, cum adhuc ténebræ essent, venit ad monuméntum. Juxta históriam notátur hora: juxta intelléctum vero mýsticum, requiréntis signátur intellegéntia. María étenim auctórem ómnium, quem in carne víderat mórtuum, quærébat in monuménto; et quia hunc mínime invénit, furátum crédidit. Adhuc ergo erant ténebræ, cum venit ad monuméntum. Cucúrrit cítius, discípulis nuntiávit: sed illi præ céteris cucurrérunt, qui præ céteris amavérunt, vidélicet Petrus et Joánnes.")
               (:text "Currébant autem duo simul: sed Joánnes præcucúrrit cítius Petro. Venit prior ad monuméntum, et íngredi non præsúmpsit. Venit ergo postérior Petrus, et intrávit. Quid, fratres, quid cursus signíficat? Numquid hæc tam subtílis Evangelístæ descríptio a mystériis vacáre credénda est? Mínime. Neque enim se Joánnes et præísse, et non intrásse díceret, si in ipsa sui trepidatióne mystérium defuísse credidísset. Quid ergo per Joánnem, nisi synagóga: quid per Petrum, nisi Ecclésia designátur?")
               (:text "Nec mirum esse videátur, quod per juniórem synagóga, per seniórem vero Ecclésia signári perhibétur: quia etsi ad Dei cultum prior est synagóga, quam Ecclésia géntium, ad usum tamen sǽculi prior est multitúdo géntium, quam synagóga, Paulo attestánte, qui ait: Quia non prius quod spiritále est, sed quod animále. Per seniórem ergo Petrum significátur Ecclésia géntium: per juniórem vero Joánnem synagóga Judæórum. Currunt ambo simul: quia ab ortus sui témpore usque ad occásum, pari et commúni via, etsi non pari et commúni sensu, gentílitas cum synagóga cucúrrit. Venit synagóga prior ad monuméntum, sed mínime intrávit: quia legis quidem mandáta percépit, prophetías de incarnatióne ac passióne Domínica audívit, sed crédere in mórtuum nóluit."))
              :responsories
              ((:respond "Christus resúrgens ex mórtuis, jam non móritur, mors illi ultra non dominábitur: quod enim mórtuus est peccáto, mórtuus est semel:"
                  :verse "Mórtuus est semel propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Quod autem vivit, vivit Deo, allelúja, allelúja."
                  :gloria nil)
               (:respond "Isti sunt agni novélli, qui annuntiavérunt, allelúja: modo venérunt ad fontes,"
                  :verse "In conspéctu Agni amícti sunt stolis albis, et palmæ in mánibus eórum."
                  :repeat "Repléti sunt claritáte, allelúja, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc1-1: Feria Secunda infra Hebdomadam I post Octavam Paschæ
    ((1 . 1) . (:lessons
              ((:source "Incipit liber Actuum Apostolórum"
               :ref "Act. 1:1-8"
               :text "1 Primum quidem sermónem feci de ómnibus, o Theóphile, quæ cœpit Jesus fácere et docére
2 usque in diem qua præcípiens Apóstolis per Spíritum Sanctum, quos elégit, assúmptus est:
3 quibus et prǽbuit seípsum vivum post passiónem suam in multis arguméntis, per dies quadragínta appárens eis, et loquens de regno Dei.
4 Et convéscens, præcépit eis ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris, quam audístis (inquit) per os meum:
5 quia Joánnes quidem baptizávit aqua, vos autem baptizabímini Spíritu Sancto non post multos hos dies.
6 Igitur qui convénerant, interrogábant eum, dicéntes: Dómine, si in témpore hoc restítues regnum Israël?
7 Dixit autem eis: Non est vestrum nosse témpora vel moménta quæ Pater pósuit in sua potestáte:
8 sed accipiétis virtútem superveniéntis Spíritus Sancti in vos, et éritis mihi testes in Jerúsalem, et in omni Judǽa, et Samaría, et usque ad últimum terræ.")
               (:ref "Act. 1:9-14"
               :text "9 Et cum hæc dixísset, vidéntibus illis, elevátus est: et nubes suscépit eum ab óculis eórum.
10 Cumque intueréntur in cælum eúntem illum, ecce duo viri astitérunt juxta illos in véstibus albis,
11 qui et dixérunt: Viri Galilǽi, quid statis aspiciéntes in cælum? Hic Jesus, qui assúmptus est a vobis in cælum, sic véniet quemádmodum vidístis eum eúntem in cælum.
12 Tunc revérsi sunt Jerosólymam a monte qui vocátur Olivéti, qui est juxta Jerúsalem, sábbati habens iter.
13 Et cum introíssent in cœnáculum, ascendérunt ubi manébant Petrus, et Joánnes, Jacóbus, et Andréas, Philíppus, et Thomas, Bartholomǽus, et Matthǽus, Jacóbus Alphǽi, et Simon Zelótes, et Judas Jacóbi.
14 Hi omnes erant perseverántes unanímiter in oratióne cum muliéribus, et María matre Jesu, et frátribus ejus.")
               (:ref "Act. 1:15-26"
               :text "15 In diébus illis, exsúrgens Petrus in médio fratrum, dixit (erat autem turba hóminum simul, fere centum vigínti):
16 Viri fratres, opórtet impléri Scriptúram quam prædíxit Spíritus Sanctus per os David de Juda, qui fuit dux eórum qui comprehendérunt Jesum:
17 qui connumerátus erat in nobis, et sortítus est sortem ministérii hujus.
18 Et hic quidem possédit agrum de mercéde iniquitátis, et suspénsus crépuit médius: et diffúsa sunt ómnia víscera ejus.
19 Et notum factum est ómnibus habitántibus Jerúsalem, ita ut appellarétur ager ille, lingua eórum, Hacéldama, hoc est, ager sánguinis.
20 Scriptum est enim in libro Psalmórum: Fiat commorátio eórum desérta, et non sit qui inhábitet in ea: et episcopátum ejus accípiat alter.
21 Opórtet ergo ex his viris qui nobíscum sunt congregáti in omni témpore quo intrávit et exívit inter nos Dóminus Jesus,
22 incípiens a baptísmate Joánnis usque in diem qua assúmptus est a nobis, testem resurrectiónis ejus nobíscum fíeri unum ex istis.
23 Et statuérunt duos, Joseph, qui vocabátur Bársabas, qui cognominátus est Justus, et Matthíam.
24 Et orántes dixérunt: Tu Dómine, qui corda nosti ómnium, osténde quem elégeris ex his duóbus unum,
25 accípere locum ministérii hujus et apostolátus, de quo prævaricátus est Judas ut abíret in locum suum.
26 Et dedérunt sortes eis, et cécidit sors super Matthíam: et annumerátus est cum úndecim Apóstolis."))
              :responsories
              ((:respond "Virtúte magna reddébant Apóstoli,"
                  :verse "Repléti quidem Spíritu Sancto loquebántur cum fidúcia verbum Dei."
                  :repeat "Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja."
                  :gloria nil)
               (:respond "De ore prudéntis procédit mel, allelúja: dulcédo mellis est sub língua ejus, allelúja:"
                  :verse "Sapiéntia requiéscit in corde ejus, et prudéntia in sermóne oris illíus."
                  :repeat "Favus distíllans lábia ejus, allelúja, allelúja."
                  :gloria t)
               (:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus:"
                  :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc1-2: Feria Tertia infra Hebdomadam I post Octavam Paschæ
    ((1 . 2) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 2:1-8"
               :text "1 Et cum compleréntur dies Pentecóstes, erant omnes páriter in eódem loco:
2 et factus est repénte de cælo sonus, tamquam adveniéntis spíritus veheméntis, et replévit totam domum ubi erant sedéntes.
3 Et apparuérunt illis dispertítæ linguæ tamquam ignis, sedítque supra síngulos eórum:
4 et repléti sunt omnes Spíritu Sancto, et cœpérunt loqui váriis linguis, prout Spíritus Sanctus dabat éloqui illis.
5 Erant autem in Jerúsalem habitántes Judǽi, viri religiósi ex omni natióne quæ sub cælo est.
6 Facta autem hac voce, convénit multitúdo, et mente confúsa est, quóniam audiébat unusquísque lingua sua illos loquéntes.
7 Stupébant autem omnes, et mirabántur, dicéntes: Nonne ecce omnes isti qui loquúntur, Galilǽi sunt?
8 et quómodo nos audívimus unusquísque linguam nostram in qua nati sumus?")
               (:ref "Act. 2:14-21"
               :text "14 Stans autem Petrus cum úndecim, levávit vocem suam, et locútus est eis: Viri Judǽi, et qui habitátis Jerúsalem univérsi, hoc vobis notum sit, et áuribus percípite verba mea.
15 Non enim, sicut vos æstimátis, hi ébrii sunt, cum sit hora diéi tértia:
16 sed hoc est quod dictum est per prophétam Joël:
17 Et erit in novíssimis diébus, dicit Dóminus, effúndam de Spíritu meo super omnem carnem: et prophetábunt fílii vestri et fíliæ vestræ, et júvenes vestri visiónes vidébunt, et senióres vestri sómnia somniábunt.
18 Et quidem super servos meos, et super ancíllas meas, in diébus illis effúndam de Spíritu meo, et prophetábunt:
19 et dabo prodígia in cælo sursum, et signa in terra deórsum, sánguinem, et ignem, et vapórem fumi:
20 sol convertétur in ténebras, et luna in sánguinem, ántequam véniat dies Dómini magnus et maniféstus.
21 Et erit: omnis quicúmque invocáverit nomen Dómini, salvus erit.")
               (:ref "Act. 2:22-27"
               :text "22 Viri Israëlítæ, audíte verba hæc: Jesum Nazarénum, virum approbátum a Deo in vobis, virtútibus, et prodígiis, et signis, quæ fecit Deus per illum in médio vestri, sicut et vos scitis:
23 hunc, definíto consílio et præsciéntia Dei tráditum, per manus iniquórum affligéntes interemístis:
24 quem Deus suscitávit, solútis dolóribus inférni, juxta quod impossíbile erat tenéri illum ab eo.
25 David enim dicit in eum: Providébam Dóminum in conspéctu meo semper: quóniam a dextris est mihi, ne commóvear:
26 propter hoc lætátum est cor meum, et exsultávit lingua mea, ínsuper et caro mea requiéscet in spe:
27 quóniam non derelínques ánimam meam in inférno, nec dabis sanctum tuum vidére corruptiónem."))
              :responsories
              ((:respond "Ego sum vitis vera, et vos pálmites:"
                  :verse "Sicut diléxit me Pater, et ego diléxi vos."
                  :repeat "Qui manet in me, et ego in eo, hic fert fructum multum, allelúja, allelúja."
                  :gloria t)
               (:respond "Surgens Jesus Dóminus noster, stans in médio discipulórum suórum, dixit:"
                  :verse "Una ergo sabbatórum, cum fores essent clausæ, ubi erant discípuli congregáti, venit Jesus, et stetit in medio eórum, et dixit eis."
                  :repeat "Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja."
                  :gloria nil)
               (:respond "Expurgáte vetus ferméntum, ut sitis nova conspérsio: étenim Pascha nostrum immolátus est Christus:"
                  :verse "Mórtuus est propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Itaque epulémur in Dómino, allelúja."
                  :gloria t))))

    ;; Pasc1-3: Feria Quarta infra Hebdomadam I post Octavam Paschæ
    ((1 . 3) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 3:1-6"
               :text "1 Petrus autem et Joánnes ascendébant in templum ad horam oratiónis nonam.
2 Et quidam vir, qui erat claudus ex útero matris suæ, bajulabátur; quem ponébant cotídie ad portam templi, quæ dícitur Speciósa, ut péteret eleemósynam ab introëúntibus in templum.
3 Is, cum vidísset Petrum et Joánnem incipiéntes introíre in templum, rogábat ut eleemósynam accíperet.
4 Intuens autem in eum Petrus cum Joánne, dixit: Réspice in nos.
5 At ille intendébat in eos, sperans se áliquid acceptúrum ab eis.
6 Petrus autem dixit: Argéntum et aurum non est mihi: quod autem hábeo, hoc tibi do: In nómine Jesu Christi Nazaréni surge, et ámbula.")
               (:ref "Act. 3:7-11"
               :text "7 Et, apprehénsa manu ejus déxtera, allevávit eum, et prótinus consolidátæ sunt bases ejus, et plantæ.
8 Et exsíliens stetit, et ambulábat; et intrávit cum illis in templum ámbulans, et exsíliens, et laudans Deum.
9 Et vidit omnis pópulus eum ambulántem, et laudántem Deum.
10 Cognoscébant autem illum, quod ipse erat, qui ad eleemósynam sedébat ad Speciósam portam templi; et impléti sunt stupóre et éxtasi in eo, quod contígerat illi.
11 Cum tenéret autem Petrum et Joánnem, cucúrrit omnis pópulus ad eos ad pórticum, quæ appellátur Salomónis, stupéntes.")
               (:ref "Act. 3:12-16"
               :text "12 Videns autem Petrus, respóndit ad pópulum: Viri Israëlítæ, quid mirámini in hoc, aut nos quid intuémini, quasi nostra virtúte aut potestáte fecérimus hunc ambuláre?
13 Deus Abraham, et Deus Isaac, et Deus Jacob, Deus patrum nostrórum glorificávit Fílium suum Jesum, quem vos quidem tradidístis et negástis ante fáciem Piláti, judicánte illo dimítti.
14 Vos autem Sanctum et Justum negástis, et petístis virum homicídam donári vobis:
15 Auctórem vero vitæ interfecístis, quem Deus suscitávit a mórtuis, cujus nos testes sumus.
16 Et in fide nóminis ejus, hunc, quem vos vidístis et nostis, confirmávit nomen ejus: et fides, quæ per eum est, dedit íntegram sanitátem istam in conspéctu ómnium vestrum."))
              :responsories
              ((:respond "Christus resúrgens ex mórtuis, jam non móritur, mors illi ultra non dominábitur: quod enim mórtuus est peccáto, mórtuus est semel:"
                  :verse "Mórtuus est semel propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Quod autem vivit, vivit Deo, allelúja, allelúja."
                  :gloria nil)
               (:respond "Surréxit pastor bonus, qui ánimam suam pósuit pro óvibus suis, et pro grege suo mori dignátus est:"
                  :verse "Etenim Pascha nostrum immolátus est Christus."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria t)
               (:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus:"
                  :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc1-4: Feria Quinta infra Hebdomadam I post Octavam Paschæ
    ((1 . 4) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 5:1-6"
               :text "1 Vir autem quidam nómine Ananías, cum Saphíra uxóre suo véndidit agrum,
2 et fraudávit de prétio agri, cónscia uxóre sua: et áfferens partem quamdam, ad pedes Apostolórum pósuit.
3 Dixit autem Petrus: Ananía, cur tentávit Sátanas cor tuum, mentíri te Spirítui Sancto, et fraudáre de prétio agri?
4 nonne manens tibi manébat, et venúndatum in tua erat potestáte? quare posuísti in corde tuo hanc rem? non es mentítus homínibus, sed Deo.
5 Audiens autem Ananías hæc verba, cécidit, et expirávit. Et factus est timor magnus super omnes qui audiérunt.
6 Surgéntes autem júvenes amovérunt eum, et efferéntes sepeliérunt.")
               (:ref "Act. 5:7-11"
               :text "7 Factum est autem quasi horárum trium spátium, et uxor ipsíus, nésciens quod factum fúerat, introívit.
8 Dixit autem ei Petrus: Dic mihi múlier, si tanti agrum vendidístis? At illa dixit: Etiam tanti.
9 Petrus autem ad eam: Quid útique convénit vobis tentáre Spíritum Dómini? Ecce pedes eórum qui sepeliérunt virum tuum ad óstium, et éfferent te.
10 Conféstim cécidit ante pedes ejus, et expirávit. Intrántes autem júvenes invenérunt illam mórtuam: et extulérunt, et sepeliérunt ad virum suum.
11 Et factus est timor magnus in univérsa ecclésia, et in omnes qui audiérunt hæc.")
               (:ref "Act. 5:12-16"
               :text "12 Per manus autem Apostolórum fiébant signa et prodígia multa in plebe. Et erant unanímiter omnes in pórticu Salomónis.
13 Ceterórum autem nemo audébat se conjúngere illis: sed magnificábat eos pópulus.
14 Magis autem augebátur credéntium in Dómino multitúdo virórum ac mulíerum,
15 ita ut in platéas eícerent infírmos, et pónerent in léctulis et grabátis, ut, veniénte Petro, saltem umbra illíus obumbráret quemquam illórum, et liberaréntur ab infirmitátibus suis.
16 Concurrébat autem et multitúdo vicinárum civitátum Jerúsalem, afferéntes ægros, et vexátos a spirítibus immúndis: qui curabántur omnes."))
              :responsories
              ((:respond "Virtúte magna reddébant Apóstoli,"
                  :verse "Repléti quidem Spíritu Sancto loquebántur cum fidúcia verbum Dei."
                  :repeat "Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja."
                  :gloria nil)
               (:respond "De ore prudéntis procédit mel, allelúja: dulcédo mellis est sub língua ejus, allelúja:"
                  :verse "Sapiéntia requiéscit in corde ejus, et prudéntia in sermóne oris illíus."
                  :repeat "Favus distíllans lábia ejus, allelúja, allelúja."
                  :gloria t)
               (:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus:"
                  :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc1-5: Feria Sexta infra Hebdomadam I post Octavam Paschæ
    ((1 . 5) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 8:9-13"
               :text "9 Vir autem quidam nómine Simon, qui ante fúerat in civitáte magus, sedúcens gentem Samaríæ, dicens se esse áliquem magnum:
10 cui auscultábant omnes a mínimo usque ad máximum, dicéntes: Hic est virtus Dei, quæ vocátur magna.
11 Attendébant autem eum: propter quod multo témpore magíis suis dementásset eos.
12 Cum vero credidíssent Philíppo evangelizánti de regno Dei, in nómine Jesu Christi baptizabántur viri ac mulíeres.
13 Tunc Simon et ipse crédidit: et cum baptizátus esset, adhærébat Philíppo. Videns étiam signa et virtútes máximas fíeri, stupens admirabátur.")
               (:ref "Act. 8:14-19"
               :text "14 Cum autem audíssent Apóstoli qui erant Jerosólymis, quod recepísset Samaría verbum Dei, misérunt ad eos Petrum et Joánnem.
15 Qui cum veníssent, oravérunt pro ipsis ut accíperent Spíritum Sanctum:
16 nondum enim in quemquam illórum vénerat, sed baptizáti tantum erant in nómine Dómini Jesu.
17 Tunc imponébant manus super illos, et accipiébant Spíritum Sanctum.
18 Cum vidísset autem Simon quia per impositiónem manus Apostolórum darétur Spíritus Sanctus, óbtulit eis pecúniam,
19 dicens: Date et mihi hanc potestátem, ut cuicúmque imposúero manus, accípiat Spíritum Sanctum.")
               (:ref "Act. 8:19-24"
               :text "19 Petrus autem dixit ad eum:
20 Pecúnia tua tecum sit in perditiónem: quóniam donum Dei existimásti pecúnia possidéri.
21 Non est tibi pars neque sors in sermóne isto: cor enim tuum non est rectum coram Deo.
22 Pœniténtiam ítaque age ab hac nequítia tua: et roga Deum, si forte remittátur tibi hæc cogitátio cordis tui.
23 In felle enim amaritúdinis, et obligatióne iniquitátis, vídeo te esse.
24 Respóndens autem Simon, dixit: Precámini vos pro me ad Dóminum, ut nihil véniat super me horum quæ dixístis."))
              :responsories
              ((:respond "Ego sum vitis vera, et vos pálmites:"
                  :verse "Sicut diléxit me Pater, et ego diléxi vos."
                  :repeat "Qui manet in me, et ego in eo, hic fert fructum multum, allelúja, allelúja."
                  :gloria t)
               (:respond "Surgens Jesus Dóminus noster, stans in médio discipulórum suórum, dixit:"
                  :verse "Una ergo sabbatórum, cum fores essent clausæ, ubi erant discípuli congregáti, venit Jesus, et stetit in medio eórum, et dixit eis."
                  :repeat "Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja."
                  :gloria nil)
               (:respond "Expurgáte vetus ferméntum, ut sitis nova conspérsio: étenim Pascha nostrum immolátus est Christus:"
                  :verse "Mórtuus est propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Itaque epulémur in Dómino, allelúja."
                  :gloria t))))

    ;; Pasc1-6: Sabbato infra Hebdomadam I post Octavam Paschæ
    ((1 . 6) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 10:1-8"
               :text "1 Vir autem quidam erat in Cæsaréa, nómine Cornélius, centúrio cohórtis quæ dícitur Itálica,
2 religiósus, ac timens Deum cum omni domo sua, fáciens eleemósynas multas plebi, et déprecans Deum semper.
3 Is vidit in visu maniféste, quasi hora diéi nona, ángelum Dei introëúntem ad se, et dicéntem sibi: Cornéli.
4 At ille íntuens eum, timóre corréptus, dixit: Quid est, dómine? Dixit autem illi: Oratiónes tuæ et eleemósynæ tuæ ascendérunt in memóriam in conspéctu Dei.
5 Et nunc mitte viros in Joppen, et accérsi Simónem quemdam, qui cognominátur Petrus:
6 hic hospitátur apud Simónem quemdam coriárium, cujus est domus juxta mare: hic dicet tibi quid te opórteat fácere.
7 Et cum discessísset ángelus qui loquebátur illi, vocávit duos domésticos suos, et mílitem metuéntem Dóminum ex his qui illi parébant.
8 Quibus cum narrásset ómnia, misit illos in Joppen.")
               (:ref "Act. 10:9-17"
               :text "9 Póstera autem die, iter illis faciéntibus, et appropinquántibus civitáti, ascéndit Petrus in superióra ut oráret circa horam sextam.
10 Et cum esuríret, vóluit gustáre. Parántibus autem illis, cécidit super eum mentis excéssus:
11 et vidit cælum apértum, et descéndens vas quoddam, velut línteum magnum, quátuor inítiis submítti de cælo in terram,
12 in quo erant ómnia quadrupédia, et serpéntia terræ, et volatília cæli.
13 Et facta est vox ad eum: Surge, Petre: occíde, et mandúca.
14 Ait autem Petrus: Absit Dómine, quia nunquam manducávi omne commúne et immúndum.
15 Et vox íterum secúndo ad eum: Quod Deus purificávit, tu commúne ne díxeris.
16 Hoc autem factum est per ter: et statim recéptum est vas in cælum.
17 Et dum intra se hæsitáret Petrus quidnam esset vísio quam vidísset, ecce viri qui missi erant a Cornélio, inquiréntes domum Simónis astitérunt ad jánuam.")
               (:ref "Act. 10:34-41"
               :text "34 Apériens autem Petrus os suum, dixit: In veritáte cómperi quia non est personárum accéptor Deus;
35 sed in omni gente qui timet eum, et operátur justítiam, accéptus est illi.
36 Verbum misit Deus fíliis Israël, annúntians pacem per Jesum Christum (hic est ómnium Dóminus).
37 Vos scitis quod factum est verbum per univérsam Judǽam: incípiens enim a Galilǽa post baptísmum quod prædicávit Joánnes,
38 Jesum a Názareth: quómodo unxit eum Deus Spíritu Sancto, et virtúte, qui pertránsiit benefaciéndo, et sanándo omnes oppréssos a diábolo, quóniam Deus erat cum illo.
39 Et nos testes sumus ómnium quæ fecit in regióne Judæórum, et Jerúsalem, quem occidérunt suspendéntes in ligno.
40 Hunc Deus suscitávit tértia die, et dedit eum maniféstum fíeri,
41 non omni pópulo, sed téstibus præordinátis a Deo: nobis, qui manducávimus et bíbimus cum illo postquam resurréxit a mórtuis."))
              :responsories
              ((:respond "Christus resúrgens ex mórtuis, jam non móritur, mors illi ultra non dominábitur: quod enim mórtuus est peccáto, mórtuus est semel:"
                  :verse "Mórtuus est semel propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Quod autem vivit, vivit Deo, allelúja, allelúja."
                  :gloria nil)
               (:respond "Surréxit pastor bonus, qui ánimam suam pósuit pro óvibus suis, et pro grege suo mori dignátus est:"
                  :verse "Etenim Pascha nostrum immolátus est Christus."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria t)
               (:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus:"
                  :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc2-1: Feria Secunda infra Hebdomadam II post Octavam Paschæ
    ((2 . 1) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 15:5-12"
               :text "5 Surrexérunt autem quidam de hǽresi Pharisæórum, qui credidérunt, dicéntes quia opórtet circumcídi eos, præcípere quoque serváre legem Móysi.
6 Convenerúntque Apóstoli et senióres vidére de verbo hoc.
7 Cum autem magna conquisítio fíeret, surgens Petrus dixit ad eos: Viri fratres, vos scitis quóniam ab antíquis diébus Deus in nobis elégit, per os meum audíre gentes verbum Evangélii et crédere.
8 Et qui novit corda Deus, testimónium perhíbuit, dans illis Spíritum Sanctum, sicut et nobis,
9 et nihil discrévit inter nos et illos, fide puríficans corda eórum.
10 Nunc ergo quid tentátis Deum, impónere jugum super cervíces discipulórum quod neque patres nostri, neque nos portáre potúimus?
11 sed per grátiam Dómini Jesu Christi crédimus salvári, quemádmodum et illi.
12 Tácuit autem omnis multitúdo: et audiébant Bárnabam et Paulum narrántes quanta Deus fecísset signa et prodígia in géntibus per eos.")
               (:ref "Act. 15:13-21"
               :text "13 Et postquam tacuérunt, respóndit Jacóbus, dicens: Viri fratres, audíte me.
14 Simon narrávit quemádmodum primum Deus visitávit súmere ex géntibus pópulum nómini suo.
15 Et huic concórdant verba prophetárum: sicut scriptum est:
16 Post hæc revértar, et reædificábo tabernáculum David quod décidit: et díruta ejus reædificábo, et érigam illud:
17 ut requírant céteri hóminum Dóminum, et omnes gentes super quas invocátum est nomen meum, dicit Dóminus fáciens hæc.
18 Notum a sǽculo est Dómino opus suum.
19 Propter quod ego júdico non inquietári eos qui ex géntibus convertúntur ad Deum,
20 sed scríbere ad eos ut abstíneant se a contaminatiónibus simulacrórum, et fornicatióne, et suffocátis, et sánguine.
21 Móyses enim a tempóribus antíquis habet in síngulis civitátibus qui eum prǽdicent in synagógis, ubi per omne sábbatum légitur.")
               (:ref "Act. 15:22-29"
               :text "22 Tunc plácuit Apóstolis et senióribus cum omni ecclésia elígere viros ex eis, et míttere Antiochíam cum Paulo et Bárnaba: Judam, qui cognominabátur Bársabas, et Silam, viros primos in frátribus:
23 scribéntes per manus eórum: Apóstoli et senióres fratres, his qui sunt Antiochíæ, et Sýriæ, et Cilíciæ, frátribus ex géntibus, salútem.
24 Quóniam audívimus quia quidam ex nobis exeúntes, turbavérunt vos verbis, everténtes ánimas vestras, quibus non mandávimus,
25 plácuit nobis colléctis in unum elígere viros, et míttere ad vos cum caríssimis nostris Bárnaba et Paulo,
26 homínibus qui tradidérunt ánimas suas pro nómine Dómini nostri Jesu Christi.
27 Mísimus ergo Judam et Silam, qui et ipsi vobis verbis réferent éadem.
28 Visum est enim Spirítui Sancto et nobis nihil ultra impónere vobis óneris quam hæc necessária:
29 ut abstineátis vos ab immolátis simulacrórum, et sánguine, et suffocáto, et fornicatióne: a quibus custodiéntes vos, bene agétis. Valéte."))
              :responsories
              ((:respond "Virtúte magna reddébant Apóstoli,"
                  :verse "Repléti quidem Spíritu Sancto loquebántur cum fidúcia verbum Dei."
                  :repeat "Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja."
                  :gloria nil)
               (:respond "De ore prudéntis procédit mel, allelúja: dulcédo mellis est sub língua ejus, allelúja:"
                  :verse "Sapiéntia requiéscit in corde ejus, et prudéntia in sermóne oris illíus."
                  :repeat "Favus distíllans lábia ejus, allelúja, allelúja."
                  :gloria t)
               (:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus:"
                  :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc2-2: Feria Tertia infra Hebdomadam II post Octavam Paschæ
    ((2 . 2) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 17:22-27"
               :text "22 Stans autem Paulus in médio Areópagi, ait: Viri Atheniénses, per ómnia quasi superstitiosióres vos vídeo.
23 Prætériens enim, et videns simulácra vestra, invéni et aram in qua scriptum erat: Ignóto Deo. Quod ergo ignorántes cólitis, hoc ego annúntio vobis.
24 Deus, qui fecit mundum, et ómnia quæ in eo sunt, hic cæli et terræ cum sit Dóminus, non in manufáctis templis hábitat,
25 nec mánibus humánis cólitur índigens áliquo, cum ipse det ómnibus vitam, et inspiratiónem, et ómnia:
26 fecítque ex uno omne genus hóminum inhabitáre super univérsam fáciem terræ, defíniens statúta témpora, et términos habitatiónis eórum,
27 quǽrere Deum si forte attréctent eum, aut invéniant, quamvis non longe sit ab unoquóque nostrum.")
               (:ref "Act. 17:28-33"
               :text "28 In ipso enim vívimus, et movémur, et sumus: sicut et quidam vestrórum poëtárum dixérunt: Ipsíus enim et genus sumus.
29 Genus ergo cum simus Dei, non debémus æstimáre auro, aut argénto, aut lápidi, sculptúræ artis, et cogitatiónis hóminis, divínum esse símile.
30 Et témpora quidem hujus ignorántiæ despíciens Deus, nunc annúntiat homínibus ut omnes ubíque pœniténtiam agant,
31 eo quod státuit diem in quo judicatúrus est orbem in æquitáte, in viro in quo státuit, fidem præbens ómnibus, súscitans eum a mórtuis.
32 Cum audíssent autem resurrectiónem mortuórum, quidam quidem irridébant, quidam vero dixérunt: Audiémus te de hoc íterum.
33 Sic Paulus exívit de médio eórum.")
               (:ref "Act. 17:34; 18:1-4"
               :text "34 Quidam vero viri adhæréntes ei, credidérunt: in quibus et Dionýsius Areopagíta, et múlier nómine Dámaris, et álii cum eis.
1 Post hæc egréssus ab Athénis, venit Corínthum:
2 et invéniens quemdam Judǽum nómine Aquilam, Pónticum génere, qui nuper vénerat ab Itália, et Priscíllam uxórem ejus (eo quod præcepísset Cláudius discédere omnes Judǽos a Roma), accéssit ad eos.
3 Et quia ejúsdem erat artis, manébat apud eos, et operabátur. (Erant autem scenofactóriæ artis.)
4 Et disputábat in synagóga per omne sábbatum, interpónens nomen Dómini Jesu: suadebátque Judǽis et Græcis."))
              :responsories
              ((:respond "Ego sum vitis vera, et vos pálmites:"
                  :verse "Sicut diléxit me Pater, et ego diléxi vos."
                  :repeat "Qui manet in me, et ego in eo, hic fert fructum multum, allelúja, allelúja."
                  :gloria t)
               (:respond "Surgens Jesus Dóminus noster, stans in médio discipulórum suórum, dixit:"
                  :verse "Una ergo sabbatórum, cum fores essent clausæ, ubi erant discípuli congregáti, venit Jesus, et stetit in medio eórum, et dixit eis."
                  :repeat "Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja."
                  :gloria nil)
               (:respond "Expurgáte vetus ferméntum, ut sitis nova conspérsio: étenim Pascha nostrum immolátus est Christus:"
                  :verse "Mórtuus est propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Itaque epulémur in Dómino, allelúja."
                  :gloria t))))

    ;; Pasc2-3: Patrocinii St. Joseph Confessoris Sponsi B.M.V. Confessoris
    ((2 . 3) . (:lessons
              ((:source "De libro Génesis"
               :ref "Gen 39:1-6"
               :text "1 Ígitur Joseph ductus est in Ægýptum, emítque eum Putíphar eunúchus Pharaónis, princeps exércitus, vir Ægýptius, de manu Ismaelitárum, a quibus perdúctus erat.
2 Fuítque Dóminus cum eo, et erat vir in cunctis próspere agens: habitavítque in domo dómini sui,
3 qui óptime nóverat Dóminum esse cum eo, et ómnia, quæ gerébat, ab eo dírigi in manu illíus.
4 Invenítque Joseph grátiam coram dómino suo, et ministrábat ei: a quo præpósitus ómnibus gubernábat créditam sibi domum, et univérsa quæ ei trádita fúerant:
5 benedixítque Dóminus dómui Ægýptii propter Joseph, et multiplicávit tam in ǽdibus quam in agris cunctam ejus substántiam:
6 nec quidquam áliud nóverat, nisi panem quo vescebátur. Erat autem Joseph pulchra fácie, et decórus aspéctu.")
               (:ref "Gen 41:37-43"
               :text "37 Plácuit Pharaóni consílium et cunctis minístris ejus:
38 locutúsque est ad eos: Num inveníre potérimus talem virum, qui Spíritu Dei plenus sit?
39 Dixit ergo ad Joseph: Quia osténdit tibi Deus ómnia quæ locútus es, numquid sapientiórem et consímilem tui inveníre pótero?
40 Tu eris super domum meam, et ad tui oris impérium cunctus pópulus obédiet: uno tantum regni sólio te præcédam.
41 Dixítque rursus Phárao ad Joseph: Ecce, constítui te super univérsam terram Ægýpti.
42 Tulítque ánnulum de manu sua, et dedit eum in manu ejus: vestivítque eum stola býssina, et collo torquem áuream circumpósuit.
43 Fecítque eum ascéndere super currum suum secúndum, clamánte præcóne, ut omnes coram eo genu flécterent, et præpósitum esse scirent univérsæ terræ Ægýpti.")
               (:ref "Gen 41:44-49"
               :text "44 Dixit quoque rex ad Joseph: Ego sum Phárao: absque tuo império non movébit quisquam manum aut pedem in omni terra Ægýpti.
45 Vertítque nomen ejus, et vocávit eum, lingua Ægyptíaca, Salvatórem mundi. Dedítque illi uxórem Áseneth fíliam Putíphare sacerdótis Heliopóleos. Egréssus est ítaque Joseph ad terram Ægýpti
46 (trigínta autem annórum erat quando stetit in conspéctu regis Pharaónis), et circuívit omnes regiónes Ægýpti.
47 Venítque fertílitas septem annórum: et in manípulos redáctæ ségetes congregátæ sunt in hórrea Ægýpti.
48 Omnis étiam frugum abundántia in síngulis úrbibus cóndita est.
49 Tantáque fuit abundántia trítici, ut arénæ maris coæquarétur, et cópia mensúram excéderet."))
              :responsories
              ((:respond "Clamávit pópulus ad regem, aliménta petens:"
                  :verse "Salus nostra in manu tua est: réspice nos tantum, et læti serviémus regi."
                  :repeat "Quibus ille respóndit: Ite ad Joseph, allelúja."
                  :gloria nil)
               (:respond "Fecit me Deus quasi patrem regis, et dóminum univérsæ domus ejus:"
                  :verse "Veníte ad me, et ego dabo vobis ómnia bona Ægýpti, ut comedátis medúllam terræ."
                  :repeat "Exaltávit me, ut salvos fáceret multos pópulos, allelúja."
                  :gloria nil)
               (:respond "Jam lætus móriar, quia vidi fáciem tuam, et supérstitem te relínquo. Non sum fraudátus aspéctu tuo:"
                  :verse "Qui pascit me ab adolescéntia mea, benedícat púeris istis, et invocétur super eos nomen meum."
                  :repeat "Ínsuper osténdit mihi Dóminus semen tuum, allelúja."
                  :gloria t))))

    ;; Pasc2-4: De II die infra Octavam S. Joseph
    ((2 . 4) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 24:10-16"
               :text "10 Respóndit autem Paulus (annuénte sibi prǽside dícere): Ex multis annis te esse júdicem genti huic sciens, bono ánimo pro me satisfáciam.
11 Potes enim cognóscere quia non plus sunt mihi dies quam duódecim, ex quo ascéndi adoráre in Jerúsalem:
12 et neque in templo invenérunt me cum áliquo disputántem, aut concúrsum faciéntem turbæ, neque in synagógis, neque in civitáte:
13 neque probáre possunt tibi de quibus nunc me accúsant.
14 Confíteor autem hoc tibi, quod secúndum sectam quam dicunt hǽresim, sic desérvio Patri et Deo meo, credens ómnibus quæ in lege et prophétis scripta sunt:
15 spem habens in Deum, quam et hi ipsi exspéctant, resurrectiónem futúram justórum et iniquórum.
16 In hoc et ipse stúdeo sine offendículo consciéntiam habére ad Deum et ad hómines semper.")
               (:ref "Act. 24:17-21"
               :text "17 Post annos autem plures eleemósynas factúrus in gentem meam, veni, et oblatiónes, et vota,
18 in quibus invenérunt me purificátum in templo: non cum turba, neque cum tumúltu.
19 Quidam autem ex Asia Judǽi, quos oportébat apud te præsto esse, et accusáre si quid habérent advérsum me:
20 aut hi ipsi dicant si quid invenérunt in me iniquitátis cum stem in concílio,
21 nisi de una hac solúmmodo voce qua clamávi inter eos stans: Quóniam de resurrectióne mortuórum ego júdicor hódie a vobis.")
               (:ref "Act. 24:22-27"
               :text "22 Dístulit autem illos Felix, certíssime sciens de via hac, dicens: Cum tribúnus Lýsias descénderit, áudiam vos.
23 Jussítque centurióni custodíre eum, et habére réquiem, nec quemquam de suis prohibére ministráre ei.
24 Post áliquot autem dies véniens Felix cum Drusílla uxóre sua, quæ erat Judǽa, vocávit Paulum, et audívit ab eo fidem quæ est in Christum Jesum.
25 Disputánte autem illo de justítia, et castitáte, et de judício futúro, tremefáctus Felix, respóndit: Quod nunc áttinet, vade: témpore autem opportúno accérsam te:
26 simul et sperans quod pecúnia ei darétur a Paulo, propter quod et frequénter accérsens eum, loquebátur cum eo.
27 Biénnio autem expléto, accépit successórem Felix Pórtium Festum. Volens autem grátiam præstáre Judǽis Felix, relíquit Paulum vinctum."))
              :responsories
              ((:respond "Virtúte magna reddébant Apóstoli,"
                  :verse "Repléti quidem Spíritu Sancto loquebántur cum fidúcia verbum Dei."
                  :repeat "Testimónium resurrectiónis Jesu Christi Dómini nostri, allelúja, allelúja."
                  :gloria nil)
               (:respond "De ore prudéntis procédit mel, allelúja: dulcédo mellis est sub língua ejus, allelúja:"
                  :verse "Sapiéntia requiéscit in corde ejus, et prudéntia in sermóne oris illíus."
                  :repeat "Favus distíllans lábia ejus, allelúja, allelúja."
                  :gloria t)
               (:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus:"
                  :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc2-5: De III die infra Octavam S. Joseph
    ((2 . 5) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 25:1-5"
               :text "1 Festus ergo cum venísset in provínciam, post tríduum ascéndit Jerosólymam a Cæsaréa.
2 Adierúntque eum príncipes sacerdótum et primi Judæórum advérsus Paulum: et rogábant eum,
3 postulántes grátiam advérsus eum, ut jubéret perdúci eum in Jerúsalem, insídias tendéntes ut interfícerent eum in via.
4 Festus autem respóndit servári Paulum in Cæsaréa: se autem matúrius profectúrum.
5 Qui ergo in vobis, ait, poténtes sunt, descendéntes simul, si quod est in viro crimen, accúsent eum.")
               (:ref "Act. 25:6-8"
               :text "6 Demorátus autem inter eos dies non ámplius quam octo aut decem, descéndit Cæsaréam, et áltera die sedit pro tribunáli, et jussit Paulum addúci.
7 Qui cum perdúctus esset, circumstetérunt eum, qui ab Jerosólyma descénderant Judǽi, multas et graves causas obiciéntes, quas non póterant probáre:
8 Paulo ratiónem reddénte: Quóniam neque in legem Judæórum, neque in templum, neque in Cǽsarem quidquam peccávi.")
               (:ref "Act. 25:9-12"
               :text "9 Festus autem volens grátiam præstáre Judǽis, respóndens Paulo, dixit: Vis Jerosólymam ascéndere, et ibi de his judicári apud me?
10 Dixit autem Paulus: Ad tribúnal Cǽsaris sto: ibi me opórtet judicári: Judǽis non nócui, sicut tu mélius nosti.
11 Si enim nócui, aut dignum morte áliquid feci, non recúso mori: si vero nihil est eórum quæ hi accúsant me, nemo potest me illis donáre. Cǽsarem appéllo.
12 Tunc Festus cum concílio locútus, respóndit: Cǽsarem appellásti? ad Cǽsarem ibis."))
              :responsories
              ((:respond "Ego sum vitis vera, et vos pálmites:"
                  :verse "Sicut diléxit me Pater, et ego diléxi vos."
                  :repeat "Qui manet in me, et ego in eo, hic fert fructum multum, allelúja, allelúja."
                  :gloria t)
               (:respond "Surgens Jesus Dóminus noster, stans in médio discipulórum suórum, dixit:"
                  :verse "Una ergo sabbatórum, cum fores essent clausæ, ubi erant discípuli congregáti, venit Jesus, et stetit in medio eórum, et dixit eis."
                  :repeat "Pax vobis, allelúja: gavísi sunt discípuli viso Dómino, allelúja."
                  :gloria nil)
               (:respond "Expurgáte vetus ferméntum, ut sitis nova conspérsio: étenim Pascha nostrum immolátus est Christus:"
                  :verse "Mórtuus est propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Itaque epulémur in Dómino, allelúja."
                  :gloria t))))

    ;; Pasc2-6: De IV die infra Octavam S. Joseph
    ((2 . 6) . (:lessons
              ((:source "De Actibus Apostolórum"
               :ref "Act. 28:16-20"
               :text "16 Cum autem venissémus Romam, permíssum est Paulo manére síbimet cum custodiénte se mílite.
17 Post tértium autem diem convocávit primos Judæórum. Cumque conveníssent, dicébat eis: Ego, viri fratres, nihil advérsus plebem fáciens, aut morem patérnum, vinctus ab Jerosólymis tráditus sum in manus Romanórum,
18 qui cum interrogatiónem de me habuíssent, voluérunt me dimíttere, eo quod nulla esset causa mortis in me.
19 Contradicéntibus autem Judǽis, coáctus sum appelláre Cǽsarem, non quasi gentem meam habens áliquid accusáre.
20 Propter hanc ígitur causam rogávi vos vidére, et álloqui. Propter spem enim Israël caténa hac circúmdatus sum.")
               (:ref "Act. 28:21-24"
               :text "21 At illi dixérunt ad eum: Nos neque lítteras accépimus de te a Judǽa, neque advéniens áliquis fratrum nuntiávit, aut locútus est quid de te malum.
22 Rogámus autem a te audíre quæ sentis: nam de secta hac notum est nobis quia ubíque ei contradícitur.
23 Cum constituíssent autem illi diem, venérunt ad eum in hospítium plúrimi, quibus exponébat testíficans regnum Dei, suadénsque eis de Jesu ex lege Móysi et prophétis a mane usque ad vésperam.
24 Et quidam credébant his quæ dicebántur: quidam vero non credébant.")
               (:ref "Act. 28:25-31"
               :text "25 Cumque ínvicem non essent consentiéntes, discedébant, dicénte Paulo unum verbum: Quia bene Spíritus Sanctus locútus est per Isaíam prophétam ad patres nostros,
26 dicens: Vade ad pópulum istum, et dic ad eos: Aure audiétis, et non intellegétis, et vidéntes vidébitis, et non perspiciétis.
27 Incrassátum est enim cor pópuli hujus, et áuribus gráviter audiérunt, et óculos suos compressérunt: ne forte vídeant óculis, et áuribus áudiant, et corde intéllegant, et convertántur, et sanem eos.
28 Notum ergo sit vobis, quóniam géntibus missum est hoc salutáre Dei, et ipsi áudient.
29 Et cum hæc dixísset, exiérunt ab eo Judǽi, multam habéntes inter se quæstiónem.
30 Mansit autem biénnio toto in suo condúcto: et suscipiébat omnes qui ingrediebántur ad eum,
31 prǽdicans regnum Dei, et docens quæ sunt de Dómino Jesu Christo cum omni fidúcia, sine prohibitióne."))
              :responsories
              ((:respond "Christus resúrgens ex mórtuis, jam non móritur, mors illi ultra non dominábitur: quod enim mórtuus est peccáto, mórtuus est semel:"
                  :verse "Mórtuus est semel propter delícta nostra, et resurréxit propter justificatiónem nostram."
                  :repeat "Quod autem vivit, vivit Deo, allelúja, allelúja."
                  :gloria nil)
               (:respond "Surréxit pastor bonus, qui ánimam suam pósuit pro óvibus suis, et pro grege suo mori dignátus est:"
                  :verse "Etenim Pascha nostrum immolátus est Christus."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria t)
               (:respond "Ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus:"
                  :verse "Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem."
                  :repeat "Allelúja, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc3-1: De VI die infra Octavam S. Joseph
    ((3 . 1) . (:lessons
              ((:source "De libro Apocalýpsis beáti Joánnis Apóstoli"
               :ref "Apo 2:1-7"
               :text "1 Angelo Ephesi ecclésiæ scribe: Hæc dicit, qui tenet septem stellas in déxtera sua, qui ámbulat in médio septem candelabrórum aureórum:
2 Scio ópera tua, et labórem, et patiéntiam tuam, et quia non potes sustinére malos: et tentásti eos, qui se dicunt apóstolos esse, et non sunt: et invenísti eos mendáces:
3 et patiéntiam habes, et sustinuísti propter nomen meum, et non defecísti.
4 Sed hábeo advérsum te, quod caritátem tuam primam reliquísti.
5 Memor esto ítaque unde excíderis: et age pœniténtiam, et prima ópera fac: sin autem, vénio tibi, et movébo candelábrum tuum de loco suo, nisi pœniténtiam égeris.
6 Sed hoc habes, quia odísti facta Nicolaitárum, quæ et ego odi.
7 Qui habet aurem, áudiat quid Spíritus dicat ecclésiis: Vincénti dabo édere de ligno vitæ, quod est in paradíso Dei mei.")
               (:ref "Apo 2:8-11"
               :text "8 Et ángelo Smyrnæ ecclésiæ scribe: Hæc dicit primus, et novíssimus, qui fuit mórtuus, et vivit:
9 Scio tribulatiónem tuam, et paupertátem tuam, sed dives es: et blasphemáris ab his, qui se dicunt Judǽos esse, et non sunt, sed sunt synagóga Sátanæ.
10 Nihil horum tímeas quæ passúrus es. Ecce missúrus est diábolus áliquos ex vobis in cárcerem ut tentémini: et habébitis tribulatiónem diébus decem. Esto fidélis usque ad mortem, et dabo tibi corónam vitæ.
11 Qui habet aurem, áudiat quid Spíritus dicat ecclésiis: Qui vícerit, non lædétur a morte secúnda.")
               (:ref "Apo 2:12-17"
               :text "12 Et ángelo Pérgami ecclésiæ scribe: Hæc dicit qui habet rhomphǽam utráque parte acútam:
13 Scio ubi hábitas, ubi sedes est Sátanæ: et tenes nomen meum, et non negásti fidem meam. Et in diébus illis Antipas testis meus fidélis, qui occísus est apud vos ubi Sátanas hábitat.
14 Sed hábeo advérsus te pauca: quia habes illic tenéntes doctrínam Bálaam, qui docébat Balac míttere scándalum coram fíliis Israël, édere, et fornicári:
15 ita habes et tu tenéntes doctrínam Nicolaitárum.
16 Simíliter pœniténtiam age: si quóminus véniam tibi cito, et pugnábo cum illis in gládio oris mei.
17 Qui habet aurem, áudiat quid Spíritus dicat ecclésiis: Vincénti dabo manna abscónditum, et dabo illi cálculum cándidum: et in cálculo nomen novum scriptum, quod nemo scit, nisi qui áccipit."))
              :responsories
              ((:respond "Vidi portam civitátis ad Oriéntem pósitam, et Apostolórum nómina et Agni super eam scripta:"
                  :verse "Vidi cælum novum, et terram novam, et civitátem novam descendéntem de cælo."
                  :repeat "Et super muros ejus Angelórum custódiam, allelúja."
                  :gloria nil)
               (:respond "Osténdit mihi Angelus fontem aquæ vivæ, et dixit ad me, allelúja:"
                  :verse "Postquam audíssem et vidíssem, cécidi ut adorárem ante pedes Angeli, qui mihi hæc ostendébat, et dixit mihi."
                  :repeat "Hic Deum adóra, allelúja, allelúja, allelúja."
                  :gloria t)
               (:respond "Audívi vocem de cælo, tamquam vocem tonítrui magni, allelúja: Regnábit Deus noster in ætérnum, allelúja:"
                  :verse "Et vox de throno exívit, dicens: Laudem dícite Deo nostro, omnes Sancti ejus, et qui timétis Deum, pusílli et magni."
                  :repeat "Quia facta est salus, et virtus, et potéstas Christi ejus, allelúja, allelúja."
                  :gloria t))))

    ;; Pasc3-2: De VII die infra Octavam S. Joseph
    ((3 . 2) . (:lessons
              ((:source "De libro Apocalýpsis beáti Joánnis Apóstoli"
               :ref "Apo 4:1-5"
               :text "1 Post hæc vidi: et ecce óstium apértum in cælo, et vox prima, quam audívi tamquam tubæ loquéntis mecum, dicens: Ascénde huc, et osténdam tibi quæ opórtet fíeri post hæc.
2 Et statim fui in spíritu: et ecce sedes pósita erat in cælo, et supra sedem sedens.
3 Et qui sedébat símilis erat aspéctui lápidis jáspidis, et sárdinis: et iris erat in circúitu sedis símilis visióni smarágdinæ.
4 Et in circúitu sedis sedília vigínti quátuor: et super thronos vigínti quátuor senióres sedéntes, circumamícti vestiméntis albis, et in capítibus eórum corónæ áureæ.
5 Et de throno procedébant fúlgura, et voces, et tonítrua: et septem lámpades ardéntes ante thronum, qui sunt septem spíritus Dei.")
               (:ref "Apo 4:6-8"
               :text "6 Et in conspéctu sedis tamquam mare vítreum símile crystállo: et in médio sedis, et in circúitu sedis quátuor animália plena óculis ante et retro.
7 Et ánimal primum símile leóni, et secúndum ánimal símile vítulo, et tértium ánimal habens fáciem quasi hóminis, et quartum ánimal símile áquilæ volánti.
8 Et quátuor animália, síngula eórum habébant alas senas: et in circúitu, et intus plena sunt óculis: et réquiem non habébant die ac nocte, dicéntia: Sanctus, Sanctus, Sanctus Dóminus Deus omnípotens, qui erat, et qui est, et qui ventúrus est.")
               (:ref "Apo 4:9-11"
               :text "9 Et cum darent illa animália glóriam, et honórem, et benedictiónem sedénti super thronum, vivénti in sǽcula sæculórum,
10 procidébant vigínti quátuor senióres ante sedéntem in throno, et adorábant vivéntem in sǽcula sæculórum, et mittébant corónas suas ante thronum, dicéntes:
11 Dignus es, Dómine, Deus noster, accípere glóriam, et honórem, et virtútem: quia tu creásti ómnia, et propter voluntátem tuam erant, et creáta sunt."))
              :responsories
              ((:respond "Vidi Jerúsalem descendéntem de cælo, ornátam auro mundo, et lapídibus pretiósis intéxtam:"
                  :verse "Et erat structúra muri ejus ex lápide jáspide; ipsa vero aurum mundum, símile vitro mundo."
                  :repeat "Allelúja, allelúja."
                  :gloria nil)
               (:respond "In diadémate cápitis Aaron magnificéntia Dómini sculpta erat:"
                  :verse "In veste enim podéris quam habébat, totus erat orbis terrárum, et paréntum magnália in quátuor ordínibus lápidum sculpta erant."
                  :repeat "Dum perficerétur opus Dei, allelúja, allelúja, allelúja."
                  :gloria t)
               (:respond "Véniens a Líbano quam pulchra facta est, allelúja:"
                  :verse "Favus distíllans lábia ejus, mel et lac sub lingua ejus."
                  :repeat "Et odor vestimentórum ejus super ómnia arómata, allelúja, allelúja."
                  :gloria t))))

    ;; Pasc3-3: In Octava Patrocinii S. Joseph
    ((3 . 3) . (:lessons
              ((:source "De libro Apocalýpsis beáti Joánnis Apóstoli"
               :ref "Apo 5:1-7"
               :text "1 Et vidi in déxtera sedéntis supra thronum, librum scriptum intus et foris, signátum sigíllis septem.
2 Et vidi ángelum fortem, prædicántem voce magna: Quis est dignus aperíre librum, et sólvere signácula ejus?
3 Et nemo póterat neque in cælo, neque in terra, neque subtus terram aperíre librum, neque respícere illum.
4 Et ego flebam multum, quóniam nemo dignus invéntus est aperíre librum, nec vidére eum.
5 Et unus de senióribus dixit mihi: Ne fléveris: ecce vicit leo de tribu Juda, radix David, aperíre librum, et sólvere septem signácula ejus.
6 Et vidi: et ecce in médio throni et quátuor animálium, et in médio seniórum, Agnum stantem tamquam occísum, habéntem córnua septem, et óculos septem: qui sunt septem spíritus Dei, missi in omnem terram.
7 Et venit: et accépit de déxtera sedéntis in throno librum.")
               (:ref "Apo 5:8-10"
               :text "8 Et cum aperuísset librum, quátuor animália, et vigínti quátuor senióres cecidérunt coram Agno, habéntes sínguli cítharas, et phíalas áureas plenas odoramentórum, quæ sunt oratiónes sanctórum:
9 et cantábant cánticum novum, dicéntes: Dignus es, Dómine, accípere librum, et aperíre signácula ejus: quóniam occísus es, et redemísti nos Deo in sánguine tuo ex omni tribu, et lingua, et pópulo, et natióne:
10 et fecísti nos Deo nostro regnum, et sacerdótes: et regnábimus super terram.")
               (:ref "Apo 5:11-14"
               :text "11 Et vidi, et audívi vocem angelórum multórum in circúitu throni, et animálium, et seniórum: et erat númerus eórum míllia míllium,
12 dicéntium voce magna: Dignus est Agnus, qui occísus est, accípere virtútem, et divinitátem, et sapiéntiam, et fortitúdinem, et honórem, et glóriam, et benedictiónem.
13 Et omnem creatúram, quæ in cælo est, et super terram, et sub terra, et quæ sunt in mari, et quæ in eo: omnes audívi dicéntes: Sedénti in throno, et Agno, benedíctio et honor, et glória, et potéstas in sǽcula sæculórum.
14 Et quátuor animália dicébant: Amen. Et vigínti quátuor senióres cecidérunt in fácies suas: et adoravérunt vivéntem in sǽcula sæculórum."))
              :responsories
              ((:respond "Platéæ tuæ, Jerúsalem, sternéntur auro mundo, allelúja: et cantábitur in te cánticum lætítiæ, allelúja:"
                  :verse "Luce spléndida fulgébis, et omnes fines terræ adorábunt te."
                  :repeat "Et per omnes vicos tuos ab univérsis dicétur, allelúja, allelúja."
                  :gloria nil)
               (:respond "Decantábat pópulus Israël, allelúja: et univérsa multitúdo Jacob canébat legítime:"
                  :verse "Sanctificáti sunt ergo sacerdótes et levítæ: et univérsus Israël deducébat arcam fœ́deris Dómini in júbilo."
                  :repeat "Et David cum cantóribus cítharam percutiébat in domo Dómini, et laudes Deo canébat, allelúja, allelúja."
                  :gloria nil)
               (:respond "Vidi portam civitátis ad Oriéntem pósitam, et Apostolórum nómina et Agni super eam scripta:"
                  :verse "Vidi cælum novum, et terram novam, et civitátem novam descendéntem de cælo."
                  :repeat "Et super muros ejus Angelórum custódiam, allelúja."
                  :gloria nil))))

    ;; Pasc3-4: Feria Quinta infra Hebdomadam III post Octavam Paschæ
    ((3 . 4) . (:lessons
              ((:source "De libro Apocalýpsis beáti Joánnis Apóstoli"
               :ref "Apo 15:1-4"
               :text "1 Et vidi áliud signum in cælo magnum et mirábile, ángelos septem, habéntes plagas septem novíssimas: quóniam in illis consummáta est ira Dei.
2 Et vidi tamquam mare vítreum mistum igne, et eos, qui vicérunt béstiam, et imáginem ejus, et númerum nóminis ejus, stantes super mare vítreum, habéntes cítharas Dei:
3 et cantántes cánticum Móysi servi Dei, et cánticum Agni, dicéntes: Magna et mirabília sunt ópera tua, Dómine Deus omnípotens: justæ et veræ sunt viæ tuæ, Rex sæculórum.
4 Quis non timébit te, Dómine, et magnificábit nomen tuum? quia solus pius es: quóniam omnes gentes vénient, et adorábunt in conspéctu tuo, quóniam judícia tua manifésta sunt.")
               (:ref "Apo 15:5-8"
               :text "5 Et post hæc vidi: et ecce apértum est templum tabernáculi testimónii in cælo,
6 et exiérunt septem ángeli habéntes septem plagas de templo, vestíti lino mundo et cándido, et præcíncti circa péctora zonis áureis.
7 Et unum de quátuor animálibus dedit septem ángelis septem phíalas áureas, plenas iracúndiæ Dei vivéntis in sǽcula sæculórum.
8 Et implétum est templum fumo a majestáte Dei, et de virtúte ejus: et nemo póterat introíre in templum, donec consummaréntur septem plagæ septem angelórum.")
               (:ref "Apo 16:1-6"
               :text "1 Et audívi vocem magnam de templo, dicéntem septem ángelis: Ite, et effúndite septem phíalas iræ Dei in terram.
2 Et ábiit primus, et effúdit phíalam suam in terram, et factum est vulnus sævum et péssimum in hómines, qui habébant caractérem béstiæ, et in eos qui adoravérunt imáginem ejus.
3 Et secúndus ángelus effúdit phíalam suam in mare, et factus est sanguis tamquam mórtui: et omnis ánima vivens mórtua est in mari.
4 Et tértius effúdit phíalam suam super flúmina, et super fontes aquárum, et factus est sanguis.
5 Et audívi ángelum aquárum dicéntem: Justus es, Dómine, qui es, et qui eras sanctus, qui hæc judicásti:
6 quia sánguinem sanctórum et prophetárum effudérunt, et sánguinem eis dedísti bíbere: digni enim sunt."))
              :responsories
              ((:respond "Dignus es, Dómine, accípere librum, et aperíre signácula ejus, allelúja: quóniam occísus es, et redemísti nos Deo"
                  :verse "Fecísti enim nos Deo nostro regnum et sacerdótium."
                  :repeat "In sánguine tuo, allelúja."
                  :gloria nil)
               (:respond "Ego sicut vitis fructificávi suavitátem odóris, allelúja:"
                  :verse "In me omnis grátia viæ et veritátis: in me omnes spes vitæ et virtútis."
                  :repeat "Transíte ad me, omnes qui concupíscitis me, et a generatiónibus meis adimplémini, allelúja, allelúja."
                  :gloria nil)
               (:respond "Audívi vocem de cælo, tamquam vocem tonítrui magni, allelúja: Regnábit Deus noster in ætérnum, allelúja:"
                  :verse "Et vox de throno exívit, dicens: Laudem dícite Deo nostro, omnes Sancti ejus, et qui timétis Deum, pusílli et magni."
                  :repeat "Quia facta est salus, et virtus, et potéstas Christi ejus, allelúja, allelúja."
                  :gloria t))))

    ;; Pasc3-5: Feria Sexta infra Hebdomadam III post Octavam Paschæ
    ((3 . 5) . (:lessons
              ((:source "De libro Apocalýpsis beáti Joánnis Apóstoli"
               :ref "Apo 19:1-5"
               :text "1 Post hæc audívi quasi vocem turbárum multárum in cælo dicéntium: Allelúja: salus, et glória, et virtus Deo nostro est:
2 quia vera et justa judícia sunt ejus, qui judicávit de meretríce magna, quæ corrúpit terram in prostitutióne sua, et vindicávit sánguinem servórum suórum de mánibus ejus.
3 Et íterum dixérunt: Allelúja. Et fumus ejus ascéndit in sǽcula sæculórum.
4 Et cecidérunt senióres vigínti quátuor, et quátuor animália, et adoravérunt Deum sedéntem super thronum, dicéntes: Amen: allelúja.
5 Et vox de throno exívit, dicens: Laudem dícite Deo nostro omnes servi ejus: et qui timétis eum pusílli et magni.")
               (:ref "Apo 19:6-10"
               :text "6 Et audívi quasi vocem turbæ magnæ, et sicut vocem aquárum multárum, et sicut vocem tonitruórum magnórum, dicéntium: Allelúja: quóniam regnávit Dóminus Deus noster omnípotens.
7 Gaudeámus, et exsultémus: et demus glóriam ei: quia venérunt núptiæ Agni, et uxor ejus præparávit se.
8 Et datum est illi ut coopériat se býssino splendénti et cándido. Býssinum enim justificatiónes sunt sanctórum.
9 Et dixit mihi: Scribe: Beáti qui ad cœnam nuptiárum Agni vocáti sunt; et dixit mihi: Hæc verba Dei vera sunt.
10 Et cécidi ante pedes ejus, ut adorárem eum. Et dicit mihi: Vide ne féceris: consérvus tuus sum, et fratrum tuórum habéntium testimónium Jesu. Deum adóra. Testimónium enim Jesu est spíritus prophetíæ.")
               (:ref "Apo 19:11-16"
               :text "11 Et vidi cælum apértum, et ecce equus albus, et qui sedébat super eum, vocabátur Fidélis, et Verax, et cum justítia júdicat et pugnat.
12 Oculi autem ejus sicut flamma ignis, et in cápite ejus diadémata multa, habens nomen scriptum, quod nemo novit nisi ipse.
13 Et vestítus erat veste aspérsa sánguine: et vocátur nomen ejus: Verbum Dei.
14 Et exércitus qui sunt in cælo, sequebántur eum in equis albis, vestíti býssino albo et mundo.
15 Et de ore ejus procédit gládius ex utráque parte acútus, ut in ipso percútiat gentes. Et ipse reget eas in virga férrea: et ipse calcat tórcular vini furóris iræ Dei omnipoténtis.
16 Et habet in vestiménto et in fémore suo scriptum: Rex regum et Dóminus dominántium."))
              :responsories
              ((:respond "Locútus est ad me unus ex septem Angelis, dicens: Veni, osténdam tibi novam nuptam, sponsam Agni:"
                  :verse "Et sústulit me in spíritu in montem magnum et altum."
                  :repeat "Et vidi Jerúsalem descendéntem de cælo, ornátam monílibus suis, allelúja, allelúja, allelúja."
                  :gloria nil)
               (:respond "Audívi vocem in cælo Angelórum multórum dicéntium:"
                  :verse "Vidi Angelum Dei fortem, volántem per médium cæli, voce magna clamántem et dicéntem."
                  :repeat "Timéte Dóminum, et date claritátem illi, et adoráte eum, qui fecit cælum et terram, mare et fontes aquárum, allelúja, allelúja."
                  :gloria nil)
               (:respond "Véniens a Líbano quam pulchra facta est, allelúja:"
                  :verse "Favus distíllans lábia ejus, mel et lac sub lingua ejus."
                  :repeat "Et odor vestimentórum ejus super ómnia arómata, allelúja, allelúja."
                  :gloria t))))

    ;; Pasc3-6: Sabbato infra Hebdomadam III post Octavam Paschæ
    ((3 . 6) . (:lessons
              ((:source "De libro Apocalýpsis beáti Joánnis Apóstoli"
               :ref "Apo 22:1-7"
               :text "1 Et osténdit mihi flúvium aquæ vitæ, spléndidum tamquam crystállum, procedéntem de sede Dei et Agni.
2 In médio platéæ ejus, et ex utráque parte flúminis, lignum vitæ, áfferens fructus duódecim per menses síngulos, reddens fructum suum et fólia ligni ad sanitátem géntium.
3 Et omne maledíctum non erit ámplius: sed sedes Dei et Agni in illa erunt, et servi ejus sérvient illi.
4 Et vidébunt fáciem ejus: et nomen ejus in fróntibus eórum.
5 Et nox ultra non erit: et non egébunt lúmine lucérnæ, neque lúmine solis, quóniam Dóminus Deus illuminábit illos, et regnábunt in sǽcula sæculórum.
6 Et dixit mihi: Hæc verba fidelíssima sunt, et vera. Et Dóminus Deus spirítuum prophetárum misit ángelum suum osténdere servis suis quæ opórtet fíeri cito.
7 Et ecce vénio velóciter. Beátus, qui custódit verba prophetíæ libri hujus.")
               (:ref "Apo 22:8-12"
               :text "8 Et ego Joánnes, qui audívi, et vidi hæc. Et postquam audíssem, et vidíssem, cécidi ut adorárem ante pedes ángeli, qui mihi hæc ostendébat:
9 et dixit mihi: Vide ne féceris: consérvus enim tuus sum, et fratrum tuórum prophetárum, et eórum qui servant verba prophetíæ libri hujus: Deum adóra.
10 Et dicit mihi: Ne signáveris verba prophetíæ libri hujus: tempus enim prope est.
11 Qui nocet, nóceat adhuc: et qui in sórdibus est, sordéscat adhuc: et qui justus est, justificétur adhuc: et sanctus, sanctificétur adhuc.
12 Ecce vénio cito, et merces mea mecum est, réddere unicuíque secúndum ópera sua.")
               (:ref "Apo 22:13-21"
               :text "13 Ego sum alpha et ómega, primus et novíssimus, princípium et finis.
14 Beáti, qui lavant stolas suas in sánguine Agni: ut sit potéstas eórum in ligno vitæ, et per portas intrent in civitátem.
15 Foris canes, et venéfici, et impudíci, et homicídæ, et idólis serviéntes, et omnis qui amat et facit mendácium.
16 Ego Jesus misi ángelum meum testificári vobis hæc in ecclésiis. Ego sum radix, et genus David, stella spléndida et matutína.
17 Et spíritus, et sponsa dicunt: Veni. Et qui audit, dicat: Veni. Et qui sitit, véniat: et qui vult, accípiat aquam vitæ, gratis.
18 Contéstor enim omni audiénti verba prophetíæ libri hujus: si quis apposúerit ad hæc, appónet Deus super illum plagas scriptas in libro isto.
19 Et si quis diminúerit de verbis libri prophetíæ hujus, áuferet Deus partem ejus de libro vitæ, et de civitáte sancta, et de his quæ scripta sunt in libro isto:
20 dicit qui testimónium pérhibet istórum. Etiam vénio cito: amen. Veni, Dómine Jesu.
21 Grátia Dómini nostri Jesu Christi cum ómnibus vobis. Amen."))
              :responsories
              ((:respond "Decantábat pópulus Israël, allelúja: et univérsa multitúdo Jacob canébat legítime:"
                  :verse "Sanctificáti sunt ergo sacerdótes et levítæ: et univérsus Israël deducébat arcam fœ́deris Dómini in júbilo."
                  :repeat "Et David cum cantóribus cítharam percutiébat in domo Dómini, et laudes Deo canébat, allelúja, allelúja."
                  :gloria nil)
               (:respond "Osténdit mihi Angelus fontem aquæ vivæ, et dixit ad me, allelúja:"
                  :verse "Postquam audíssem et vidíssem, cécidi ut adorárem ante pedes Angeli, qui mihi hæc ostendébat, et dixit mihi."
                  :repeat "Hic Deum adóra, allelúja, allelúja, allelúja."
                  :gloria t)
               (:respond "Vidi Jerúsalem descendéntem de cælo, ornátam auro mundo, et lapídibus pretiósis intéxtam:"
                  :verse "Et erat structúra muri ejus ex lápide jáspide; ipsa vero aurum mundum, símile vitro mundo."
                  :repeat "Allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc4-1: Feria Secunda infra Hebdomadam IV post Octavam Paschæ
    ((4 . 1) . (:lessons
              ((:source "De Epístola beáti Jacóbi Apóstoli"
               :ref "Jas 1:17-20"
               :text "17 Omne datum óptimum, et omne donum perféctum desúrsum est, descéndens a Patre lúminum, apud quem non est transmutátio, nec vicissitúdinis obumbrátio.
18 Voluntárie enim génuit nos verbo veritátis, ut simus inítium áliquod creatúræ ejus.
19 Scitis, fratres mei dilectíssimi. Sit autem omnis homo velox ad audiéndum: tardus autem ad loquéndum, et tardus ad iram.
20 Ira enim viri justítiam Dei non operátur.")
               (:ref "Jas 1:21-24"
               :text "21 Propter quod abiciéntes omnem immundítiam, et abundántiam malítiæ, in mansuetúdine suscípite ínsitum verbum, quod potest salváre ánimas vestras.
22 Estóte autem factóres verbi, et non auditóres tantum: falléntes vosmetípsos.
23 Quia si quis audítor est verbi, et non factor, hic comparábitur viro consideránti vultum nativitátis suæ in spéculo:
24 considerávit enim se, et ábiit, et statim oblítus est qualis fúerit.")
               (:ref "Jas 1:25-27"
               :text "25 Qui autem perspéxerit in legem perféctam libertátis, et permánserit in ea, non audítor obliviósus factus, sed factor óperis: hic beátus in facto suo erit.
26 Si quis autem putat se religiósum esse, non refrénans linguam suam, sed sedúcens cor suum, hujus vana est relígio.
27 Relígio munda et immaculáta apud Deum et Patrem, hæc est: visitáre pupíllos et víduas in tribulatióne eórum, et immaculátum se custodíre ab hoc sǽculo."))
              :responsories
              ((:respond "Dicant nunc, qui redémpti sunt, allelúja,"
                  :verse "Quos redémit de manu inimíci, et de regiónibus congregávit eos."
                  :repeat "A Dómino, allelúja, allelúja."
                  :gloria nil)
               (:respond "Cantáte Dómino, allelúja:"
                  :verse "Afférte Dómino glóriam et honórem, afférte Dómino glóriam nómini ejus."
                  :repeat "Psalmum dícite ei, allelúja."
                  :gloria t)
               (:respond "Narrábo nomen tuum frátribus meis, allelúja:"
                  :verse "Confitébor tibi in pópulis, Dómine, et psalmum dicam tibi in géntibus."
                  :repeat "In médio Ecclésiæ laudábo te, allelúja, allelúja."
                  :gloria t))))

    ;; Pasc4-2: Feria Tertia infra Hebdomadam IV post Octavam Paschæ
    ((4 . 2) . (:lessons
              ((:source "De Epístola beáti Jacóbi Apóstoli"
               :ref "Jas 2:1-4"
               :text "1 Fratres mei, nolíte in personárum acceptióne habére fidem Dómini nostri Jesu Christi glóriæ.
2 Etenim si introíerit in convéntum vestrum vir áureum ánnulum habens in veste cándida, introíerit autem et pauper in sórdido hábitu,
3 et intendátis in eum qui indútus est veste præclára, et dixéritis ei: Tu sede hic bene: páuperi autem dicátis: Tu sta illic; aut sede sub scabéllo pedum meórum:
4 nonne judicátis apud vosmetípsos, et facti estis júdices cogitatiónum iniquárum?")
               (:ref "Jas 2:5-9"
               :text "5 Audíte, fratres mei dilectíssimi: nonne Deus elégit páuperes in hoc mundo, dívites in fide, et hærédes regni, quod repromísit Deus diligéntibus se?
6 vos autem exhonorástis páuperem. Nonne dívites per poténtiam ópprimunt vos, et ipsi trahunt vos ad judícia?
7 nonne ipsi blasphémant bonum nomen, quod invocátum est super vos?
8 Si tamen legem perfícitis regálem secúndum Scriptúras: Díliges próximum tuum sicut teípsum: bene fácitis:
9 si autem persónas accípitis, peccátum operámini, redargúti a lege quasi transgressóres.")
               (:ref "Jas 2:10-13"
               :text "10 Quicúmque autem totam legem serváverit, offéndat autem in uno, factus est ómnium reus.
11 Qui enim dixit: Non mœcháberis, dixit et: Non occídes. Quod si non mœcháberis, occídes autem, factus es transgréssor legis.
12 Sic loquímini, et sic fácite sicut per legem libertátis incipiéntes judicári.
13 Judícium enim sine misericórdia illi qui non fecit misericórdiam: superexáltat autem misericórdia judícium."))
              :responsories
              ((:respond "In ecclésiis benedícite Deo, allelúja:"
                  :verse "Psalmum dícite nómini ejus, date glóriam laudi ejus."
                  :repeat "Dómino de fóntibus Israël, allelúja, allelúja."
                  :gloria nil)
               (:respond "In toto corde meo, allelúja, exquisívi te, allelúja:"
                  :verse "Benedíctus es tu, Dómine, doce me justificatiónes tuas."
                  :repeat "Ne repéllas me a mandátis tuis, allelúja, allelúja."
                  :gloria nil)
               (:respond "Hymnum cantáte nobis, allelúja:"
                  :verse "Illic interrogavérunt nos, qui captívos duxérunt nos, verba cantiónum."
                  :repeat "Quómodo cantábimus cánticum Dómini in terra aliéna? allelúja, allelúja."
                  :gloria t))))

    ;; Pasc4-3: Feria Quarta infra Hebdomadam IV post Octavam Paschæ
    ((4 . 3) . (:lessons
              ((:source "De Epístola beáti Jacóbi Apóstoli"
               :ref "Jas 2:14-17"
               :text "14 Quid próderit, fratres mei, si fidem quis dicat se habére, ópera autem non hábeat? numquid póterit fides salváre eum?
15 Si autem frater et soror nudi sint, et indígeant victu cotidiáno,
16 dicat autem áliquis ex vobis illis: Ite in pace, calefacímini et saturámini: non dedéritis autem eis quæ necessária sunt córpori, quid próderit?
17 Sic et fides, si non hábeat ópera, mórtua est in semetípsa.")
               (:ref "Jas 2:18-22"
               :text "18 Sed dicet quis: Tu fidem habes, et ego ópera hábeo: osténde mihi fidem tuam sine opéribus: et ego osténdam tibi ex opéribus fidem meam.
19 Tu credis quóniam unus est Deus: bene facis: et dǽmones credunt, et contremíscunt.
20 Vis autem scire, o homo inánis, quóniam fides sine opéribus mórtua est?
21 Abraham pater noster nonne ex opéribus justificátus est, ófferens Isaac fílium suum super altáre?
22 Vides quóniam fides cooperabátur opéribus illíus: et ex opéribus fides consummáta est?")
               (:ref "Jas 2:23-26"
               :text "23 Et suppléta est Scriptúra, dicens: Crédidit Abraham Deo, et reputátum est illi ad justítiam, et amícus Dei appellátus est.
24 Vidétis quóniam ex opéribus justificátur homo, et non ex fide tantum?
25 Simíliter et Rahab méretrix, nonne ex opéribus justificáta est, suscípiens núntios, et ália via eíciens?
26 Sicut enim corpus sine spíritu mórtuum est, ita et fides sine opéribus mórtua est."))
              :responsories
              ((:respond "Deus, cánticum novum cantábo tibi, allelúja:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "In psaltério decem chordárum psallam tibi, allelúja, allelúja."
                  :gloria nil)
               (:respond "Bonum est confitéri Dómino, allelúja:"
                  :verse "In decachórdo psaltério, cum cántico et cíthara."
                  :repeat "Et psállere, allelúja."
                  :gloria t)
               (:respond "Dicant nunc, qui redémpti sunt, allelúja,"
                  :verse "Quos redémit de manu inimíci, et de regiónibus congregávit eos."
                  :repeat "A Dómino, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc4-4: Feria Quinta infra Hebdomadam IV post Octavam Paschæ
    ((4 . 4) . (:lessons
              ((:source "De Epístola beáti Jacóbi Apóstoli"
               :ref "Jas 3:1-3"
               :text "1 Nolíte plures magístri fíeri fratres mei, sciéntes quóniam majus judícium súmitis.
2 In multis enim offéndimus omnes. Si quis in verbo non offéndit, hic perféctus est vir: potest étiam freno circumdúcere totum corpus.
3 Si autem equis frena in ora míttimus ad consentiéndum nobis, et omne corpus illórum circumférimus.")
               (:ref "Jas 3:4-6"
               :text "4 Ecce et naves, cum magnæ sint, et a ventis válidis minéntur, circumferúntur a módico gubernáculo ubi ímpetus dirigéntis volúerit.
5 Ita et lingua módicum quidem membrum est, et magna exáltat. Ecce quantus ignis quam magnam silvam incéndit!
6 Et lingua ignis est, univérsitas iniquitátis.")
               (:ref "Jas 3:6-10"
               :text "6 Lingua constitúitur in membris nostris, quæ máculat totum corpus, et inflámmat rotam nativitátis nostræ inflammáta a gehénna.
7 Omnis enim natúra bestiárum, et vólucrum, et serpéntium, et ceterórum domántur, et dómita sunt a natúra humána:
8 linguam autem nullus hóminum domáre potest: inquiétum malum, plena venéno mortífero.
9 In ipsa benedícimus Deum et Patrem: et in ipsa maledícimus hómines, qui ad similitúdinem Dei facti sunt.
10 Ex ipso ore procédit benedíctio et maledíctio."))
              :responsories
              ((:respond "Si oblítus fúero tui, allelúja, obliviscátur mei déxtera mea:"
                  :verse "Super flúmina Babylónis illic sédimus et flévimus, dum recordarémur tui, Sion."
                  :repeat "Adhǽreat lingua mea fáucibus meis, si non memínero tui, allelúja, allelúja."
                  :gloria nil)
               (:respond "Vidérunt te aquæ, Deus, vidérunt te aquæ, et timuérunt:"
                  :verse "Illuxérunt coruscatiónes tuæ orbi terræ: vidit et commóta est terra."
                  :repeat "Multitúdo sónitus aquárum vocem dedérunt nubes, allelúja, allelúja, allelúja."
                  :gloria nil)
               (:respond "Narrábo nomen tuum frátribus meis, allelúja:"
                  :verse "Confitébor tibi in pópulis, Dómine, et psalmum dicam tibi in géntibus."
                  :repeat "In médio Ecclésiæ laudábo te, allelúja, allelúja."
                  :gloria t))))

    ;; Pasc4-5: Feria Sexta infra Hebdomadam IV post Octavam Paschæ
    ((4 . 5) . (:lessons
              ((:source "De Epístola beáti Jacóbi Apóstoli"
               :ref "Jas 4:1-4"
               :text "1 Unde bella et lites in vobis? nonne hinc: ex concupiscéntiis vestris, quæ mílitant in membris vestris?
2 concupíscitis, et non habétis: occíditis, et zelátis: et non potéstis adipísci: litigátis, et belligerátis, et non habétis, propter quod non postulátis.
3 Pétitis, et non accípitis: eo quod male petátis: ut in concupiscéntiis vestris insumátis.
4 Adúlteri, nescítis quia amicítia hujus mundi inimíca est Dei? quicúmque ergo volúerit amícus esse sǽculi hujus, inimícus Dei constitúitur.")
               (:ref "Jas 4:5-10"
               :text "5 An putátis quia inániter Scriptúra dicat: Ad invídiam concupíscit spíritus qui hábitat in vobis?
6 majórem autem dat grátiam. Propter quod dicit: Deus supérbis resístit, humílibus autem dat grátiam.
7 Súbditi ergo estóte Deo, resístite autem diábolo, et fúgiet a vobis.
8 Appropinquáte Deo, et appropinquábit vobis. Emundáte manus, peccatóres: et purificáte corda, dúplices ánimo.
9 Míseri estóte, et lugéte, et ploráte: risus vester in luctum convertátur, et gáudium in mœrórem.
10 Humiliámini in conspéctu Dómini, et exaltábit vos.")
               (:ref "Jas 4:11-15"
               :text "11 Nolíte detráhere altérutrum fratres. Qui détrahit fratri, aut qui júdicat fratrem suum, détrahit legi, et júdicat legem. Si autem júdicas legem, non es factor legis, sed judex.
12 Unus est legislátor et judex, qui potest pérdere et liberáre.
13 Tu autem quis es, qui júdicas próximum? Ecce nunc qui dícitis: Hódie, aut crástino íbimus in illam civitátem, et faciémus ibi quidem annum, et mercábimur, et lucrum faciémus:
14 qui ignorátis quid erit in crástino.
15 Quæ est enim vita vestra? vapor est ad módicum parens, et deínceps exterminábitur; pro eo ut dicátis: Si Dóminus volúerit. Et: Si vixérimus, faciémus hoc, aut illud."))
              :responsories
              ((:respond "In ecclésiis benedícite Deo, allelúja:"
                  :verse "Psalmum dícite nómini ejus, date glóriam laudi ejus."
                  :repeat "Dómino de fóntibus Israël, allelúja, allelúja."
                  :gloria nil)
               (:respond "In toto corde meo, allelúja, exquisívi te, allelúja:"
                  :verse "Benedíctus es tu, Dómine, doce me justificatiónes tuas."
                  :repeat "Ne repéllas me a mandátis tuis, allelúja, allelúja."
                  :gloria nil)
               (:respond "Hymnum cantáte nobis, allelúja:"
                  :verse "Illic interrogavérunt nos, qui captívos duxérunt nos, verba cantiónum."
                  :repeat "Quómodo cantábimus cánticum Dómini in terra aliéna? allelúja, allelúja."
                  :gloria t))))

    ;; Pasc4-6: Sabbato infra Hebdomadam IV post Octavam Paschæ
    ((4 . 6) . (:lessons
              ((:source "De Epístola beáti Jacóbi Apóstoli"
               :ref "Jas 5:1-6"
               :text "1 Agite nunc dívites, ploráte ululántes in misériis vestris, quæ advénient vobis.
2 Divítiæ vestræ putrefáctæ sunt, et vestiménta vestra a tíneis comésta sunt.
3 Aurum et argéntum vestrum æruginávit: et ærúgo eórum in testimónium vobis erit, et manducábit carnes vestras sicut ignis. Thesaurizástis vobis iram in novíssimis diébus.
4 Ecce merces operariórum, qui messuérunt regiónes vestras, quæ fraudáta est a vobis, clamat: et clamor eórum in aures Dómini sábbaoth introívit.
5 Epuláti estis super terram, et in luxúriis enutrístis corda vestra in die occisiónis.
6 Addixístis, et occidístis justum, et non resístit vobis.")
               (:ref "Jas 5:7-11"
               :text "7 Patiéntes ígitur estóte, fratres, usque ad advéntum Dómini. Ecce agrícola exspéctat pretiósum fructum terræ, patiénter ferens donec accípiat temporáneum et serótinum.
8 Patiéntes ígitur estóte et vos, et confirmáte corda vestra: quóniam advéntus Dómini appropinquávit.
9 Nolíte ingemíscere, fratres, in altérutrum, ut non judicémini. Ecce judex ante jánuam assístit.
10 Exémplum accípite, fratres, éxitus mali, labóris, et patiéntiæ, prophétas qui locúti sunt in nómine Dómini.
11 Ecce beatificámus eos qui sustinuérunt. Sufferéntiam Job audístis, et finem Dómini vidístis, quóniam miséricors Dóminus est, et miserátor.")
               (:ref "Jas 5:12-16"
               :text "12 Ante ómnia autem, fratres mei, nolíte juráre, neque per cælum, neque per terram, neque áliud quodcúmque juraméntum. Sit autem sermo vester: Est, est: Non, non: ut non sub judício decidátis.
13 Tristátur áliquis vestrum? oret. Æquo ánimo est? psallat.
14 Infirmátur quis in vobis? indúcat presbýteros ecclésiæ, et orent super eum, ungéntes eum óleo in nómine Dómini:
15 et orátio fídei salvábit infírmum, et alleviábit eum Dóminus: et si in peccátis sit, remitténtur ei.
16 Confitémini ergo altérutrum peccáta vestra, et oráte pro ínvicem ut salvémini: multum enim valet deprecátio justi assídua."))
              :responsories
              ((:respond "Deus, cánticum novum cantábo tibi, allelúja:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "In psaltério decem chordárum psallam tibi, allelúja, allelúja."
                  :gloria nil)
               (:respond "Bonum est confitéri Dómino, allelúja:"
                  :verse "In decachórdo psaltério, cum cántico et cíthara."
                  :repeat "Et psállere, allelúja."
                  :gloria t)
               (:respond "Cantáte Dómino, allelúja:"
                  :verse "Afférte Dómino glóriam et honórem, afférte Dómino glóriam nómini ejus."
                  :repeat "Psalmum dícite ei, allelúja."
                  :gloria t))))

    ;; Pasc5-1: Feria Secunda in Rogationibus
    ((5 . 1) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Liber 7 in Lucæ cap. 11"
               :text "In illo témpore: Dixit Jesus discípulis suis: Quis vestrum habébit amícum, et ibit ad illum media nocte, et dicet illi: Amice, cómmoda mihi tres panes. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Alius præcépti locus est, ut ómnibus moméntis, non solum diébus, sed étiam noctibus, orátio deferátur. Vides enim, quod iste qui media nocte perréxit, tres panes ab amico suo póstulans, et in ipsa peténdi intentióne persístens, non defraudétur oratis. Qui sunt isti tres panes, nisi mysterii cæléstis aliméntum? Quod si diligas Dóminum Deum tuum, non solum tibi, sed étiam aliis póteris emereri. Quis autem amicior nobis, quam qui pro nobis corpus suum trádidit?")
               (:text "Ab hoc media nocte panes David pétiit, et accépit. Petiit enim, quando dicebat: Media nocte surgébam ad confiténdum tibi. Ideo meruit hos panes, quos appósuit nobis edendos. Petiit cum dicit: Lavábo per síngulas noctes lectum meum. Neque enim tímuit, ne excitaret dormiéntem, quem scit semper vigilántem. Et ideo scriptórum mémores, noctibus ac diébus oratióni instántes, peccátis nostris véniam postulemus.")
               (:text "Nam si ille tam sanctus, et qui regni erat necessitátibus occupatus, septies in die laudem Dómino dicebat, matutínis, et vespertinis sacrifíciis semper intentus; quid nos fácere oportet, qui eo ámplius rogare debemus, quo frequéntius carnis ac mentis fragilitáte delinquimus, ut de via lassis, et istíus ævi cursu, ac vitæ hujus anfractu gráviter fatigátis, panis refectiónis deésse non possit, qui hóminis corda confírmet? Nec solum media nocte Dóminus, sed ómnibus prope docet vigilándum esse moméntis. Venit enim et vespertína, et secunda, et tertia vigília: et pulsáre consuévit. Beáti ítaque servi illi, quos cum venerit Dóminus, invénerit vigilántes."))
              :responsories
              ((:respond "Dicant nunc, qui redémpti sunt, allelúja,"
                  :verse "Quos redémit de manu inimíci, et de regiónibus congregávit eos."
                  :repeat "A Dómino, allelúja, allelúja."
                  :gloria nil)
               (:respond "Cantáte Dómino, allelúja:"
                  :verse "Afférte Dómino glóriam et honórem, afférte Dómino glóriam nómini ejus."
                  :repeat "Psalmum dícite ei, allelúja."
                  :gloria t)
               (:respond "Narrábo nomen tuum frátribus meis, allelúja:"
                  :verse "Confitébor tibi in pópulis, Dómine, et psalmum dicam tibi in géntibus."
                  :repeat "In médio Ecclésiæ laudábo te, allelúja, allelúja."
                  :gloria t))))

    ;; Pasc5-2: Feria Tertia in Rogationibus
    ((5 . 2) . (:lessons
              ((:source "De Epístola prima beáti Petri Apóstoli"
               :ref "1 Pet 4:1-7"
               :text "1 Christo ígitur passo in carne, et vos eádem cogitatióne armámini: quia qui passus est in carne, désiit a peccátis:
2 ut jam non desidériis hóminum, sed voluntáti Dei, quod réliquum est in carne vivat témporis.
3 Súfficit enim prætéritum tempus ad voluntátem géntium consummándam his qui ambulavérunt in luxúriis, desidériis, vinoléntiis, comessatiónibus, potatiónibus, et illícitis idolórum cúltibus.
4 In quo admirántur non concurréntibus vobis in eándem luxúriæ confusiónem, blasphemántes.
5 Qui reddent ratiónem ei qui parátus est judicáre vivos et mórtuos.
6 Propter hoc enim et mórtuis evangelizátum est: ut judicéntur quidem secúndum hómines in carne, vivant autem secúndum Deum in spíritu.
7 Omnium autem finis appropinquávit.")
               (:ref "1 Pet 4:7-11"
               :text "7 Estóte ítaque prudéntes, et vigiláte in oratiónibus.
8 Ante ómnia autem, mútuam in vobismetípsis caritátem contínuam habéntes: quia cáritas óperit multitúdinem peccatórum.
9 Hospitáles ínvicem sine murmuratióne.
10 Unusquísque, sicut accépit grátiam, in altérutrum illam administrántes, sicut boni dispensatóres multifórmis grátiæ Dei.
11 Si quis lóquitur, quasi sermónes Dei: si quis minístrat, tamquam ex virtúte, quam adminístrat Deus: ut in ómnibus honorificétur Deus per Jesum Christum: cui est glória et impérium in sǽcula sæculórum. Amen.")
               (:ref "1 Pet 4:12-17"
               :text "12 Caríssimi, nolíte peregrinári in fervóre, qui ad tentatiónem vobis fit, quasi novi áliquid vobis contíngat:
13 sed communicántes Christi passiónibus gaudéte, ut et in revelatióne glóriæ ejus gaudeátis exsultántes.
14 Si exprobrámini in nómine Christi, beáti éritis: quóniam quod est honóris, glóriæ, et virtútis Dei, et qui est ejus Spíritus, super vos requiéscit.
15 Nemo autem vestrum patiátur ut homicída, aut fur, aut malédicus, aut alienórum appetítor.
16 Si autem ut Christiánus, non erubéscat: gloríficet autem Deum in isto nómine:
17 quóniam tempus est ut incípiat judícium a domo Dei."))
              :responsories
              ((:respond "In ecclésiis benedícite Deo, allelúja:"
                  :verse "Psalmum dícite nómini ejus, date glóriam laudi ejus."
                  :repeat "Dómino de fóntibus Israël, allelúja, allelúja."
                  :gloria nil)
               (:respond "In toto corde meo, allelúja, exquisívi te, allelúja:"
                  :verse "Benedíctus es tu, Dómine, doce me justificatiónes tuas."
                  :repeat "Ne repéllas me a mandátis tuis, allelúja, allelúja."
                  :gloria nil)
               (:respond "Hymnum cantáte nobis, allelúja:"
                  :verse "Illic interrogavérunt nos, qui captívos duxérunt nos, verba cantiónum."
                  :repeat "Quómodo cantábimus cánticum Dómini in terra aliéna? allelúja, allelúja."
                  :gloria t))))

    ;; Pasc5-3: In Vigilia Ascensionis
    ((5 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tractatus 104 in Joannem, sub med."
               :text "In illo témpore: Sublevátis Jesus óculis in cælum, dixit: Pater, venit hora, clarífica Fílium tuum. Et réliqua.
Homilía sancti Augustíni Epíscopi
Póterat Dóminus noster, unigénitus et coætérnus Patri, in forma servi, et ex forma servi, si hoc opus esset, oráre siléntio: sed ita se Patri exhibére vóluit precatórem, ut meminísset nostrum se esse doctórem. Proínde eam, quam fecit oratiónem pro nobis, notam fecit et nobis: quóniam tanti magístri non solum ad ipsos sermocinátio, sed étiam pro ipsis ad Patrem orátio, discipulórum est ædificátio: et si illórum, qui hæc dicta áderant auditúri, profécto et nostra, qui fuerámus conscrípta lectúri.")
               (:text "Quaprópter hoc quod ait: Pater, venit hora, clarífica Fílium tuum: osténdit, omne tempus, et quid, quando fáceret vel fíeri síneret, ab illo esse dispósitum, qui témpori súbditus non est: quóniam quæ futúra erant per síngula témpora, in Dei sapiéntia causas efficiéntes habent, in qua nulla sunt témpora. Non ergo credátur hæc hora fato urgénte venísse, sed Deo pótius ordinánte. Nec sidérea necéssitas Christi connéxuit passiónem: absit enim ut sídera mori cógerent síderum Conditórem.")
               (:text "Clarificátum a Patre Fílium nonnúlli accípiunt in hoc, quod ei non pepércit, sed pro nobis ómnibus trádidit eum. Sed si passióne clarificátus dícitur, quanto magis resurrectióne? Nam in passióne magis ejus humílitas quam cláritas commendátur, Apóstolo teste, qui dicit: Humiliávit semetípsum, factus obédiens usque ad mortem, mortem autem crucis. Deínde séquitur, et de ejus clarificatióne jam dicit: Propter quod et Deus illum exaltávit, et donávit ei nomen, quod est super omne nomen: ut in nómine Jesu omne genu flectátur, cæléstium, terréstrium, et infernórum. Et omnis lingua confiteátur, quia Dóminus Jesus Christus in glória est Dei Patris. Hæc est clarificátio Dómini nostri Jesu Christi, quæ ab ejus resurrectióne sumpsit exórdium."))
              :responsories
              ((:respond "Deus, cánticum novum cantábo tibi, allelúja:"
                  :verse "Deus meus es tu, et confitébor tibi: Deus meus es tu, et exaltábo te."
                  :repeat "In psaltério decem chordárum psallam tibi, allelúja, allelúja."
                  :gloria nil)
               (:respond "Bonum est confitéri Dómino, allelúja:"
                  :verse "In decachórdo psaltério, cum cántico et cíthara."
                  :repeat "Et psállere, allelúja."
                  :gloria t)
               (:respond "Dicant nunc, qui redémpti sunt, allelúja,"
                  :verse "Quos redémit de manu inimíci, et de regiónibus congregávit eos."
                  :repeat "A Dómino, allelúja, allelúja."
                  :gloria nil))))

    ;; Pasc5-4: In Ascensione Domini
    ((5 . 4) . (:lessons
              ((:source "Incipit liber Actuum Apostolórum"
               :ref "Act. 1:1-5"
               :text "1 Primum quidem sermónem feci de ómnibus, o Theóphile, quæ cœpit Jesus fácere, et docére,
2 usque in diem, qua præcípiens Apóstolis per Spíritum Sanctum, quos elégit, assúmptus est:
3 quibus et prǽbuit seípsum vivum post passiónem suam in multis arguméntis, per dies quadragínta appárens eis, et loquens de regno Dei.
4 Et convéscens, præcépit eis ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris, quam audístis (inquit) per os meum:
5 quia Joánnes quidem baptizávit aqua, vos autem baptizabímini Spíritu Sancto non post multos hos dies.")
               (:ref "Act. 1:6-9"
               :text "6 Igitur qui convénerant, interrogábant eum, dicéntes: Dómine, si in témpore hoc restítues regnum Israël?
7 Dixit autem eis: Non est vestrum nosse témpora vel moménta, quæ Pater pósuit in sua potestáte:
8 sed accipiétis virtútem superveniéntis Spíritus Sancti in vos, et éritis mihi testes in Jerúsalem, et in omni Judǽa, et Samaría, et usque ad últimum terræ.
9 Et cum hæc dixísset, vidéntibus illis, elevátus est: et nubes suscépit eum ab óculis eórum.")
               (:ref "Act. 1:10-14"
               :text "10 Cumque intueréntur in cælum eúntem illum, ecce duo viri astitérunt juxta illos in véstibus albis,
11 qui et dixérunt: Viri Galilǽi, quid statis aspiciéntes in cælum? Hic Jesus qui assúmptus est a vobis in cælum, sic véniet, quemádmodum vidístis eum eúntem in cælum.
12 Tunc revérsi sunt Jerosólymam a monte, qui vocátur Olivéti, qui est juxta Jerúsalem, sábbati habens iter.
13 Et cum introíssent in cœnáculum, ascendérunt ubi manébant Petrus et Joánnes, Jacóbus et Andréas, Philíppus et Thomas, Bartholomǽus et Matthǽus, Jacóbus Alphǽi et Simon Zelótes, et Judas Jacóbi.
14 Hi omnes erant perseverántes unanímiter in oratióne cum muliéribus, et María Matre Jesu, et frátribus ejus."))
              :responsories
              ((:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja:"
                  :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris."
                  :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja."
                  :gloria nil)
               (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera:"
                  :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus."
                  :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja."
                  :gloria nil)
               (:respond "Exaltáre, Dómine, allelúja,"
                  :verse "Eleváta est, magnificéntia tua super cælos, Deus."
                  :repeat "In virtúte tua, allelúja."
                  :gloria t))))

    ;; Pasc5-5: Feria VI post Ascensionem
    ((5 . 5) . (:lessons
              ((:source "Incipit Epístola secúnda beáti Petri Apóstoli"
               :ref "2 Pet 1:1-4"
               :text "1 Simon Petrus, servus et apóstolus Jesu Christi, iis qui coæquálem nobíscum sortíti sunt fidem in justítia Dei nostri, et Salvatóris Jesu Christi.
2 Grátia vobis, et pax adimpleátur in cognitióne Dei, et Christi Jesu Dómini nostri:
3 Quómodo ómnia nobis divínæ virtútis suæ, quæ ad vitam et pietátem donáta sunt, per cognitiónem ejus, qui vocávit nos própria glória, et virtúte,
4 per quem máxima, et pretiósa nobis promíssa donávit: ut per hæc efficiámini divínæ consórtes natúræ: fugiéntes ejus, quæ in mundo est, concupiscéntiæ corruptiónem.")
               (:ref "2 Pet 1:5-9"
               :text "5 Vos autem curam omnem subinferéntes, ministráte in fide vestra virtútem, in virtúte autem sciéntiam,
6 in sciéntia autem abstinéntiam, in abstinéntia autem patiéntiam, in patiéntia autem pietátem,
7 in pietáte autem amórem fraternitátis, in amóre autem fraternitátis caritátem.
8 Hæc enim si vobíscum adsint, et súperent, non vácuos nec sine fructu vos constítuent in Dómini nostri Jesu Christi cognitióne.
9 Cui enim non præsto sunt hæc, cæcus est, et manu tentans, obliviónem accípiens purgatiónis véterum suórum delictórum.")
               (:ref "2 Pet 1:10-15"
               :text "10 Quaprópter fratres, magis satágite ut per bona ópera certam vestram vocatiónem, et electiónem faciátis: hæc enim faciéntes, non peccábitis aliquándo.
11 Sic enim abundánter ministrábitur vobis intróitus in ætérnum regnum Dómini nostri et Salvatóris Jesu Christi.
12 Propter quod incípiam vos semper commonére de his: et quidem sciéntes et confirmátos vos in præsénti veritáte.
13 Justum autem árbitror quámdiu sum in hoc tabernáculo, suscitáre vos in commonitióne:
14 certus quod velox est deposítio tabernáculi mei secúndum quod et Dóminus noster Jesus Christus significávit mihi.
15 Dabo autem óperam et frequénter habére vos post óbitum meum, ut horum memóriam faciátis."))
              :responsories
              ((:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja:"
                  :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris."
                  :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja."
                  :gloria nil)
               (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera:"
                  :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus."
                  :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja."
                  :gloria nil)
               (:respond "Exaltáre, Dómine, allelúja,"
                  :verse "Eleváta est, magnificéntia tua super cælos, Deus."
                  :repeat "In virtúte tua, allelúja."
                  :gloria t))))

    ;; Pasc5-6: Sabbato post Ascensionem
    ((5 . 6) . (:lessons
              ((:source "De Epístola secúnda beáti Petri Apóstoli"
               :ref "2 Pet 3:1-7"
               :text "1 Hanc ecce vobis, caríssimi, secúndam scribo epístolam, in quibus vestram éxcito in commonitióne sincéram mentem:
2 ut mémores sitis eórum, quæ prædíxi, verbórum, a sanctis prophétis et apostolórum vestrórum, præceptórum Dómini et Salvatóris.
3 Hoc primum sciéntes, quod vénient in novíssimis diébus in deceptióne illusóres, juxta próprias concupiscéntias ambulántes,
4 dicéntes: Ubi est promíssio, aut advéntus ejus? ex quo enim patres dormiérunt, ómnia sic perséverant ab inítio creatúræ.
5 Latet enim eos hoc voléntes, quod cæli erant prius, et terra de aqua, et per aquam consístens Dei verbo:
6 per quæ, ille tunc mundus aqua inundátus, périit.
7 Cæli autem, qui nunc sunt, et terra eódem verbo repósiti sunt, igni reserváti in diem judícii, et perditiónis impiórum hóminum.")
               (:ref "2 Pet 3:8-13"
               :text "8 Unum vero hoc non láteat vos, caríssimi, quia unus dies apud Dóminum sicut mille anni, et mille anni sicut dies unus.
9 Non tardat Dóminus promissiónem suam, sicut quidam exístimant: sed patiénter agit propter vos, nolens áliquos períre, sed omnes ad pœniténtiam revérti.
10 Advéniet autem dies Dómini ut fur: in quo cæli magno ímpetu tránsient, eleménta vero calóre solvéntur, terra autem et quæ in ipsa sunt ópera, exuréntur.
11 Cum ígitur hæc ómnia dissolvénda sunt, quales opórtet vos esse in sanctis conversatiónibus, et pietátibus,
12 exspectántes, et properántes in advéntum diéi Dómini, per quem cæli ardéntes solvéntur, et eleménta ignis ardóre tabéscent?
13 Novos vero cælos, et novam terram secúndum promíssa ipsíus exspectámus, in quibus justítia hábitat.")
               (:ref "2 Pet 3:14-18"
               :text "14 Propter quod, caríssimi, hæc exspectántes, satágite immaculáti, et invioláti ei inveníri in pace:
15 et Dómini nostri longanimitátem, salútem arbitrémini: sicut et caríssimus frater noster Paulus secúndum datam sibi sapiéntiam scripsit vobis,
16 sicut et in ómnibus epístolis, loquens in eis de his in quibus sunt quædam difficília intelléctu, quæ indócti et instábiles deprávant, sicut et céteras Scriptúras, ad suam ipsórum perditiónem.
17 Vos ígitur fratres, præsciéntes custodíte, ne insipiéntium erróre tradúcti excidátis a própria firmitáte:
18 créscite vero in grátia, et in cognitióne Dómini nostri, et Salvatóris Jesu Christi. Ipsi glória et nunc, et in diem æternitátis. Amen."))
              :responsories
              ((:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja:"
                  :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris."
                  :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja."
                  :gloria nil)
               (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera:"
                  :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus."
                  :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja."
                  :gloria nil)
               (:respond "Exaltáre, Dómine, allelúja,"
                  :verse "Eleváta est, magnificéntia tua super cælos, Deus."
                  :repeat "In virtúte tua, allelúja."
                  :gloria t))))

    ;; Pasc6-1: Feria II post Ascensionem
    ((6 . 1) . (:lessons
              ((:source "De Epístola prima beáti Joánnis Apóstoli"
               :ref "1 Joannes 3:1-6"
               :text "1 Vidéte qualem caritátem dedit nobis Pater, ut fílii Dei nominémur et simus. Propter hoc mundus non novit nos: quia non novit eum.
2 Caríssimi, nunc fílii Dei sumus: et nondum appáruit quid érimus. Scimus quóniam cum apparúerit, símiles ei érimus: quóniam vidébimus eum sícuti est.
3 Et omnis qui habet hanc spem in eo, sanctíficat se, sicut et ille sanctus est.
4 Omnis qui facit peccátum, et iniquitátem facit: et peccátum est iníquitas.
5 Et scitis quia ille appáruit ut peccáta nostra tólleret: et peccátum in eo non est.
6 Omnis qui in eo manet, non peccat: et omnis qui peccat, non vidit eum, nec cognóvit eum.")
               (:ref "1 Joannes 3:7-12"
               :text "7 Filíoli, nemo vos sedúcat. Qui facit justítiam, justus est, sicut et ille justus est.
8 Qui facit peccátum, ex diábolo est: quóniam ab inítio diábolus peccat. In hoc appáruit Fílius Dei, ut dissólvat ópera diáboli.
9 Omnis qui natus est ex Deo, peccátum non facit: quóniam semen ipsíus in eo manet, et non potest peccáre, quóniam ex Deo natus est.
10 In hoc manifésti sunt fílii Dei, et fílii diáboli. Omnis qui non est justus, non est ex Deo, et qui non díligit fratrem suum:
11 quóniam hæc est annuntiátio, quam audístis ab inítio, ut diligátis altérutrum.
12 Non sicut Cain, qui ex malígno erat, et occídit fratrem suum. Et propter quid occídit eum? Quóniam ópera ejus malígna erant: fratris autem ejus, justa.")
               (:ref "1 Joannes 3:13-18"
               :text "13 Nolíte mirári, fratres, si odit vos mundus.
14 Nos scimus quóniam transláti sumus de morte ad vitam, quóniam dilígimus fratres. Qui non díligit, manet in morte:
15 omnis qui odit fratrem suum, homicída est. Et scitis quóniam omnis homicída non habet vitam ætérnam in semetípso manéntem.
16 In hoc cognóvimus caritátem Dei, quóniam ille ánimam suam pro nobis pósuit: et nos debémus pro frátribus ánimas pónere.
17 Qui habúerit substántiam hujus mundi, et víderit fratrem suum necessitátem habére, et cláuserit víscera sua ab eo: quómodo cáritas Dei manet in eo?
18 Filíoli mei, non diligámus verbo neque lingua, sed ópere et veritáte:"))
              :responsories
              ((:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja:"
                  :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris."
                  :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja."
                  :gloria nil)
               (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera:"
                  :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus."
                  :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja."
                  :gloria nil)
               (:respond "Exaltáre, Dómine, allelúja,"
                  :verse "Eleváta est, magnificéntia tua super cælos, Deus."
                  :repeat "In virtúte tua, allelúja."
                  :gloria t))))

    ;; Pasc6-2: Feria III post Ascensionem
    ((6 . 2) . (:lessons
              ((:source "De Epístola prima beáti Joánnis Apóstoli"
               :ref "1 Joannes 4:1-6"
               :text "1 Caríssimi, nolíte omni spirítui crédere, sed probáte spíritus si ex Deo sint: quóniam multi pseudoprophétæ exiérunt in mundum.
2 In hoc cognóscitur Spíritus Dei: omnis spíritus qui confitétur Jesum Christum in carne venísse, ex Deo est:
3 et omnis spíritus qui solvit Jesum, ex Deo non est, et hic est Antichrístus, de quo audístis quóniam venit, et nunc jam in mundo est.
4 Vos ex Deo estis filíoli, et vicístis eum, quóniam major est qui in vobis est, quam qui in mundo.
5 Ipsi de mundo sunt: ídeo de mundo loquúntur, et mundus eos audit.
6 Nos ex Deo sumus. Qui novit Deum, audit nos; qui non est ex Deo, non audit nos: in hoc cognóscimus Spíritum veritátis, et spíritum erróris.")
               (:ref "1 Joannes 4:7-14"
               :text "7 Caríssimi, diligámus nos ínvicem: quia cáritas ex Deo est. Et omnis qui díligit, ex Deo natus est, et cognóscit Deum.
8 Qui non díligit, non novit Deum: quóniam Deus cáritas est.
9 In hoc appáruit cáritas Dei in nobis, quóniam Fílium suum unigénitum misit Deus in mundum, ut vivámus per eum.
10 In hoc est cáritas: non quasi nos dilexérimus Deum, sed quóniam ipse prior diléxit nos, et misit Fílium suum propitiatiónem pro peccátis nostris.
11 Caríssimi, si sic Deus diléxit nos: et nos debémus altérutrum dilígere.
12 Deum nemo vidit umquam. Si diligámus ínvicem, Deus in nobis manet, et cáritas ejus in nobis perfécta est.
13 In hoc cognóscimus quóniam in eo manémus, et ipse in nobis: quóniam de Spíritu suo dedit nobis.
14 Et nos vídimus, et testificámur quóniam Pater misit Fílium suum Salvatórem mundi.")
               (:ref "1 Joannes 4:15-21"
               :text "15 Quisquis conféssus fúerit quóniam Jesus est Fílius Dei, Deus in eo manet, et ipse in Deo.
16 Et nos cognóvimus, et credídimus caritáti, quam habet Deus in nobis. Deus cáritas est: et qui manet in caritáte, in Deo manet, et Deus in eo.
17 In hoc perfécta est cáritas Dei nobíscum, ut fidúciam habeámus in die judícii: quia sicut ille est, et nos sumus in hoc mundo.
18 Timor non est in caritáte: sed perfécta cáritas foras mittit timórem, quóniam timor pœnam habet: qui autem timet, non est perféctus in caritáte.
19 Nos ergo diligámus Deum, quóniam Deus prior diléxit nos.
20 Si quis díxerit: Quóniam díligo Deum, et fratrem suum óderit, mendax est. Qui enim non díligit fratrem suum quem vidit, Deum, quem non vidit, quómodo potest dilígere?
21 Et hoc mandátum habémus a Deo: ut qui díligit Deum, díligat et fratrem suum."))
              :responsories
              ((:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja:"
                  :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris."
                  :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja."
                  :gloria nil)
               (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera:"
                  :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus."
                  :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja."
                  :gloria nil)
               (:respond "Exaltáre, Dómine, allelúja,"
                  :verse "Eleváta est, magnificéntia tua super cælos, Deus."
                  :repeat "In virtúte tua, allelúja."
                  :gloria t))))

    ;; Pasc6-3: Feria IV post Ascensionem
    ((6 . 3) . (:lessons
              ((:source "Incipit Epístola secúnda beáti Joánnis Apóstoli"
               :ref "2 Joannes 1:1-5"
               :text "1 Sénior Eléctæ dóminæ, et natis ejus, quos ego díligo in veritáte, et non ego solus, sed et omnes qui cognovérunt veritátem,
2 propter veritátem, quæ pérmanet in nobis, et nobíscum erit in ætérnum.
3 Sit vobíscum grátia, misericórdia, pax a Deo Patre, et a Christo Jesu Fílio Patris in veritáte, et caritáte.
4 Gavísus sum valde, quóniam invéni de fíliis tuis ambulántes in veritáte, sicut mandátum accépimus a Patre.
5 Et nunc rogo te dómina, non tamquam mandátum novum scribens tibi, sed quod habúimus ab inítio, ut diligámus altérutrum.")
               (:ref "2 Joannes 1:6-9"
               :text "6 Et hæc est cáritas, ut ambulémus secúndum mandáta ejus. Hoc est enim mandátum, ut quemádmodum audístis ab inítio, in eo ambulétis.
7 Quóniam multi seductóres exiérunt in mundum, qui non confiténtur Jesum Christum venísse in carnem: hic est sedúctor, et Antichrístus.
8 Vidéte vosmetípsos, ne perdátis quæ operáti estis: sed ut mercédem plenam accipiátis.
9 Omnis qui recédit, et non pérmanet in doctrína Christi, Deum non habet: qui pérmanet in doctrína, hic et Patrem et Fílium habet.")
               (:ref "2 Joannes 1:10-13"
               :text "10 Si quis venit ad vos, et hanc doctrínam non affert, nolíte recípere eum in domum, nec Ave ei dixéritis.
11 Qui enim dicit illi Ave, commúnicat opéribus ejus malígnis.
12 Plura habens vobis scríbere, nólui per cartam et atraméntum: spero enim me futúrum apud vos, et os ad os loqui: ut gáudium vestrum plenum sit.
13 Salútant te fílii soróris tuæ Eléctæ."))
              :responsories
              ((:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja:"
                  :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris."
                  :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja."
                  :gloria nil)
               (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera:"
                  :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus."
                  :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja."
                  :gloria nil)
               (:respond "Exaltáre, Dómine, allelúja,"
                  :verse "Eleváta est, magnificéntia tua super cælos, Deus."
                  :repeat "In virtúte tua, allelúja."
                  :gloria t))))

    ;; Pasc6-4: Feria V post Ascensionem
    ((6 . 4) . (:lessons
              ((:source "De Epístola beáti Pauli Apóstoli ad Ephésios"
               :ref "Eph 4:1-8"
               :text "1 Obsecro ítaque vos ego vinctus in Dómino, ut digne ambulétis vocatióne, qua vocáti estis,
2 cum omni humilitáte, et mansuetúdine, cum patiéntia, supportántes ínvicem in caritáte,
3 sollíciti serváre unitátem Spíritus in vínculo pacis.
4 Unum corpus, et unus Spíritus, sicut vocáti estis in una spe vocatiónis vestræ.
5 Unus Dóminus, una fides, unum baptísma.
6 Unus Deus et Pater ómnium, qui est super omnes, et per ómnia, et in ómnibus nobis.
7 Unicuíque autem nostrum data est grátia secúndum mensúram donatiónis Christi.
8 Propter quod dicit: Ascéndens in altum, captívam duxit captivitátem: dedit dona homínibus.")
               (:ref "Eph 4:9-14"
               :text "9 Quod autem ascéndit, quid est, nisi quia et descéndit primum in inferióres partes terræ?
10 Qui descéndit, ipse est et qui ascéndit super omnes cælos, ut impléret ómnia.
11 Et ipse dedit quosdam quidem apóstolos, quosdam autem prophétas, álios vero evangelístas, álios autem pastóres et doctóres,
12 ad consummatiónem sanctórum in opus ministérii, in ædificatiónem córporis Christi:
13 donec occurrámus omnes in unitátem fídei, et agnitiónis Fílii Dei, in virum perféctum, in mensúram ætátis plenitúdinis Christi:
14 ut jam non simus párvuli fluctuántes, et circumferámur omni vento doctrínæ in nequítia hóminum, in astútia ad circumventiónem erróris.")
               (:ref "Eph 4:15-21"
               :text "15 Veritátem autem faciéntes in caritáte, crescámus in illo per ómnia, qui est caput Christus:
16 ex quo totum corpus compáctum et connéxum per omnem junctúram subministratiónis, secúndum operatiónem in mensúram uniuscujúsque membri, augméntum córporis facit in ædificatiónem sui in caritáte.
17 Hoc ígitur dico, et testíficor in Dómino, ut jam non ambulétis, sicut et gentes ámbulant in vanitáte sensus sui,
18 ténebris obscurátum habéntes intelléctum, alienáti a vita Dei per ignorántiam, quæ est in illis, propter cæcitátem cordis ipsórum,
19 qui desperántes, semetípsos tradidérunt impudicítiæ, in operatiónem immundítiæ omnis in avarítiam.
20 Vos autem non ita didicístis Christum,
21 si tamen illum audístis, et in ipso edócti estis."))
              :responsories
              ((:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja:"
                  :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris."
                  :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja."
                  :gloria nil)
               (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera:"
                  :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus."
                  :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja."
                  :gloria nil)
               (:respond "Exaltáre, Dómine, allelúja,"
                  :verse "Eleváta est, magnificéntia tua super cælos, Deus."
                  :repeat "In virtúte tua, allelúja."
                  :gloria t))))

    ;; Pasc6-5: Feria VI infra Hebdomadam post Ascensionem
    ((6 . 5) . (:lessons
              ((:source "Incipit Epístola cathólica beáti Judæ Apóstoli"
               :ref "Judas 1:1-4"
               :text "1 Judas, Jesu Christi servus, frater autem Jacóbi, his qui sunt in Deo Patre diléctis, et Christo Jesu conservátis, et vocátis.
2 Misericórdia vobis, et pax, et cáritas adimpleátur.
3 Caríssimi, omnem sollicitúdinem fáciens scribéndi vobis de commúni vestra salúte, necésse hábui scríbere vobis: déprecans supercertári semel tráditæ sanctis fídei.
4 Subintroiérunt enim quidam hómines (qui olim præscrípti sunt in hoc judícium) ímpii, Dei nostri grátiam transferéntes in luxúriam, et solum Dominatórem, et Dóminum nostrum Jesum Christum negántes.")
               (:ref "Judas 1:5-8"
               :text "5 Commonére autem vos volo, sciéntes semel ómnia, quóniam Jesus pópulum de terra Ægýpti salvans, secúndo eos, qui non credidérunt, pérdidit:
6 ángelos vero, qui non servavérunt suum principátum, sed dereliquérunt suum domicílium, in judícium magni diéi, vínculis ætérnis sub calígine reservávit.
7 Sicut Sódoma, et Gomórrha, et finítimæ civitátes símili modo exfornicátæ, et abeúntes post carnem álteram, factæ sunt exémplum, ignis ætérni pœnam sustinéntes.
8 Simíliter et hi carnem quidem máculant, dominatiónem autem spernunt, majestátem autem blasphémant.")
               (:ref "Judas 1:9-13"
               :text "9 Cum Míchael Archángelus cum diábolo dísputans altercarétur de Móysi córpore, non est ausus judícium inférre blasphémiæ: sed dixit: Imperet tibi Dóminus.
10 Hi autem quæcúmque quidem ignórant, blasphémant: quæcúmque autem naturáliter, tamquam muta animália, norunt, in his corrumpúntur.
11 Væ illis, quia in via Cain abiérunt, et erróre Bálaam mercéde effúsi sunt, et in contradictióne Core periérunt!
12 Hi sunt in épulis suis máculæ, convivántes sine timóre, semetípsos pascéntes, nubes sine aqua, quæ a ventis circumferéntur, árbores autumnáles, infructuósæ, bis mórtuæ, eradicátæ,
13 fluctus feri maris, despumántes suas confusiónes, sídera errántia: quibus procélla tenebrárum serváta est in ætérnum."))
              :responsories
              ((:respond "Post passiónem suam per dies quadragínta appárens eis, et loquens de regno Dei, allelúja:"
                  :verse "Et convéscens, præcépit eis, ab Jerosólymis ne discéderent, sed exspectárent promissiónem Patris."
                  :repeat "Et, vidéntibus illis, elevátus est, allelúja: et nubes suscépit eum ab óculis eórum, allelúja."
                  :gloria nil)
               (:respond "Omnis pulchritúdo Dómini exaltáta est super sídera:"
                  :verse "A summo cælo egréssio ejus, et occúrsus ejus usque ad summum ejus."
                  :repeat "Spécies ejus in núbibus cæli, et nomen ejus in ætérnum pérmanet, allelúja."
                  :gloria nil)
               (:respond "Exaltáre, Dómine, allelúja,"
                  :verse "Eleváta est, magnificéntia tua super cælos, Deus."
                  :repeat "In virtúte tua, allelúja."
                  :gloria t))))

    ;; Pasc6-6: Sabbato in Vigilia Pentecostes

    ;; Pasc7-1: Die II infra octavam Pentecostes
    ((7 . 1) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 12 in Joann., sub fin."
               :text "In illo témpore: Dixit Jesus Nicodémo: Sic Deus diléxit mundum, ut Fílium suum unigénitum daret: ut omnis, qui credit in eum, non péreat, sed hábeat vitam ætérnam. Et réliqua.
Homilía sancti Augustíni Epíscopi
Quantum in médico est, sanáre venit ægrótum. Ipse se intérimit, qui præcépta médici observáre non vult. Venit Salvátor in mundum. Quare Salvátor dictus est mundi, nisi ut salvet mundum, non ut júdicet mundum? Salvári non vis ab ipso: ex te judicáberis. Et quid dicam, Judicáberis? Vide quid ait: Qui credit in eum, non judicátur. Qui autem non credit: quid dictúrum sperábas, nisi: Judicátur? Quod addit: Jam, inquit, judicátus est: nondum appáruit judícium, et jam factum est judícium.")
               (:text "Novit enim Dóminus qui sunt ejus: novit qui permáneant ad corónam, qui permáneant ad flammam. Novit in área sua tríticum, novit et páleam: novit ségetem, novit et zizánia. Jam judicátus est, qui non credit. Quare judicátus? Quia non crédidit in nómine unigéniti Fílii Dei. Hoc est autem judícium: quia lux venit in mundum, et dilexérunt hómines magis ténebras, quam lucem: erant enim mala ópera eórum. Fratres mei, quorum ópera bona invénit Dóminus? Nullórum. Omnia ópera mala invénit. Quómodo ergo quidam fecérunt veritátem, et venérunt ad lucem? Et hoc enim séquitur: Qui autem facit veritátem, venit ad lucem.")
               (:text "Sed dilexérunt, inquit, ténebras magis quam lucem. Ibi pósuit vim. Multi enim dilexérunt peccáta sua, multi conféssi sunt peccáta sua: quia qui confitétur peccáta sua, et accúsat peccáta sua, jam cum Deo facit. Accúsat Deus peccáta tua: si et tu accúsas, conjúngeris Deo. Quasi duæ res sunt, homo et peccátor. Quod audis homo, Deus fecit: quod audis peccátor, ipse homo fecit. Dele, quod fecísti, ut Deus salvet, quod fecit. Opórtet ut óderis in te opus tuum, et ames in te opus Dei. Cum autem cœ́perit tibi displicére quod fecísti, inde incípiunt bona ópera tua, quia accúsas mala ópera tua. Inítium óperum bonórum, conféssio est óperum malórum."))
              :responsories
              ((:respond "Jam non dicam vos servos, sed amícos meos; quia ómnia cognovístis, quæ operátus sum in médio vestri, allelúja:"
                  :verse "Vos amíci mei estis, si fecéritis quæ ego præcípio vobis."
                  :repeat "Accípite Spíritum Sanctum in vobis Paráclitum: ille est, quem Pater mittet vobis, allelúja."
                  :gloria nil)
               (:respond "Spíritus Sanctus, procédens a throno, Apostolórum péctora invisibíliter penetrávit novo sanctificatiónis signo:"
                  :verse "Advénit ignis divínus, non combúrens, sed illúminans, et tríbuit eis charísmatum dona."
                  :repeat "Ut in ore eórum ómnium génera nasceréntur linguárum, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc7-2: Die III infra octavam Pentecostes
    ((7 . 2) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 45 in Joann. post initium"
               :text "In illo témpore: Dixit Jesus pharisǽis: Amen, amen dico vobis: qui non intrat per óstium in ovíle óvium, sed ascéndit aliúnde, ille fur est, et latro. Qui autem intrat per óstium, pastor est óvium. Et réliqua.
Homilía sancti Augustíni Epíscopi
Dóminus de grege suo, et de óstio quo intrátur ad ovíle, similitúdinem propósuit in hodiérna lectióne. Dicant ergo pagáni: Bene vívimus! Si per óstium non intrant, quid prodest eis unde gloriántur? Ad hoc enim debet unicuíque prodésse bene vívere, ut detur illi semper vívere: nam cui non datur semper vívere, quid prodest bene vívere? Quia nec bene vívere dicéndi sunt, qui finem bene vivéndi vel cæcitáte nésciunt, vel inflatióne contémnunt. Non est autem cuíquam spes vera et certa semper vivéndi, nisi agnóscat vitam, quod est Christus, et per jánuam intret in ovíle.")
               (:text "Quærunt ergo plerúmque tales hómines étiam persuadére homínibus, ut bene vivant, et Christiáni non sint. Per áliam partem volunt ascéndere, rápere et occídere; non, ut bonus pastor, conserváre atque salváre. Fuérunt ergo quidam philósophi de virtútibus et vítiis subtília multa tractántes, dividéntes, definiéntes, ratiocinatiónes acutíssimas concludéntes, libros impléntes, suam sapiéntiam buccis crepántibus ventilántes, qui étiam dícere audérent homínibus: Nos sequímini, sectam nostram tenéte, si vultis beáte vívere. Sed non intrábant per óstium: pérdere volébant, mactáre et occídere.")
               (:text "Quid de istis dicam? Ecce ipsi pharisǽi legébant, et in eo quod legébant, Christum sonábant, ventúrum sperábant, et præséntem non agnoscébant. Jactábant se étiam ipsi inter Vidéntes, hoc est, inter sapiéntes, et negábant Christum, et non intrábant per óstium. Ergo et ipsi, si quos forte sedúcerent, mactándos et occidéndos, non liberándos sedúcerent. Et hos dimittámus. Videámus illos, si forte ipsi intrant per óstium, qui ipsíus Christi nómine gloriántur. Innumerábiles enim sunt, qui se Vidéntes non solum jactant, sed a Christo illuminátos vidéri volunt: sunt autem hærétici."))
              :responsories
              ((:respond "Apparuérunt Apóstolis dispertítæ linguæ tamquam ignis, allelúja:"
                  :verse "Et cœpérunt loqui váriis linguis, prout Spíritus Sanctus dabat éloqui illis."
                  :repeat "Sedítque supra síngulos eórum Spíritus Sanctus, allelúja, allelúja."
                  :gloria nil)
               (:respond "Loquebántur váriis linguis Apóstoli magnália Dei,"
                  :verse "Repléti sunt omnes Spíritu Sancto, et cœpérunt loqui."
                  :repeat "Prout Spíritus Sanctus dabat éloqui illis, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc7-3: Feria Quarta Quattuor Temporum Pentecostes
    ((7 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 26 in Joann., post init."
               :text "In illo témpore: Dixit Jesus turbis Judæórum: Nemo potest veníre ad me, nisi Pater, qui misit me, tráxerit eum. Et réliqua.
Homilía sancti Augustíni Epíscopi
Noli cogitáre te invítum trahi: tráhitur ánimus et amóre. Nec timére debémus, ne ab homínibus, qui verba perpéndunt, et a rebus máxime divínis intellegéndis longe remóti sunt, in hoc Scripturárum sanctárum evangélico verbo fórsitan reprehendámur, et dicátur nobis: Quómodo voluntáte credo, si trahor? Ego dico: Parum est voluntáte: étiam voluptáte tráheris. Quid est, trahi voluptáte? Delectáre in Dómino: et dabit tibi petitiónes cordis tui. Est quædam volúptas cordis, cui panis dulcis est ille cæléstis. Porro si poétæ dícere lícuit: Trahit sua quemque volúptas: non necéssitas, sed volúptas; non obligátio, sed delectátio: quanto fórtius nos dícere debémus, trahi hóminem ad Christum, qui delectátur veritáte, delectátur beatitúdine, delectátur justítia, delectátur sempitérna vita, quod totum Christus est? An vero habent córporis sensus voluptátes suas, et ánimus deséritur a voluptátibus suis? Si ánimus non habet voluptátes suas, unde dícitur: Fílii autem hóminum sub tégmine alárum tuárum sperábunt: inebriabúntur ab ubertáte domus tuæ, et torrénte voluptátis tuæ potábis eos. Quóniam apud te est fons vitæ: et in lúmine tuo vidébimus lumen.")
               (:text "Da amántem, et sentit quod dico: da desiderántem, da esuriéntem, da in ista solitúdine peregrinántem, atque sitiéntem, et fontem ætérnæ pátriæ suspirántem: da talem, et scit quid dicam. Si autem frígido loquor, nescit, quid loquor. Tales erant isti, qui ínvicem murmurábant. Pater, inquit, quem tráxerit, venit ad me. Quid est autem, Pater quem tráxerit, cum ipse Christus trahat? Quare vóluit dícere, Pater quem tráxerit? Si trahéndi sumus, ab illo trahámur, cui dicit quædam, quæ díligit: Post odórem unguentórum tuórum currémus. Sed quid intéllegi vóluit, advertámus fratres, et, quantum póssumus, capiámus. Trahit Pater ad Fílium eos, qui proptérea credunt in Fílium, quia eum cógitant Patrem habére Deum. Deus enim Pater æquálem sibi génuit Fílium; et qui cógitat, atque in fide sua sentit et rúminat, æquálem esse Patri eum, in quem credit, ipsum trahit Pater ad Fílium.")
               (:text "Aríus crédidit creatúram, non eum traxit Pater; quia non consíderat Patrem, qui Fílium non credit æquálem. Quid dicis, o Ari? quid dicis, hærétice? quid loquéris? Quid est Christus? Non, inquit, Deus verus, sed quem fecit Deus verus. Non te traxit Pater; non enim intellexísti Patrem, cujus Fílium negas. Aliud cógitas, non est ipse Fílius: nec a Patre tráheris, nec ad Fílium tráheris. Aliud est enim Fílius, áliud quod tu dicis. Photínus dicit: Homo solum est Christus, non est et Deus. Qui sic credit, non Pater eum traxit. Quem traxit Pater? Illum qui dicit: Tu es Christus Fílius Dei vivi. Ramum víridem osténdis ovi, et trahis illam. Nuces púero demonstrántur, et tráhitur: et quod currit, tráhitur, amándo tráhitur, sine læsióne córporis tráhitur, cordis vínculo tráhitur. Si ergo ista, quæ inter delícias et voluptátes terrénas revelántur amántibus, trahunt, quóniam verum est, Trahit sua quemque volúptas; non trahit revelátus Christus a Patre? Quid enim fórtius desíderat ánima, quam veritátem?"))
              :responsories
              ((:respond "Disciplínam et sapiéntiam dócuit eos Dóminus, allelúja: firmávit in illis grátiam Spíritus sui,"
                  :verse "Repentíno namque sónitu Spíritus Sanctus super eos venit."
                  :repeat "Et intelléctu implévit corda eórum, allelúja."
                  :gloria nil)
               (:respond "Ite in univérsum orbem, et prædicáte Evangélium, allelúja:"
                  :verse "In nómine meo dæmónia ejícient, linguis loquéntur novis, serpéntes tollent."
                  :repeat "Qui credíderit et baptizátus fúerit, salvus erit, allelúja, allelúja, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc7-4: Feria Quinta infra octavam Pentecostes
    ((7 . 4) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Liber 6 in cap. 9 Lucæ"
               :text "In illo témpore: Convocátis Jesus duódecim Apóstolis, dedit illis virtútem et potestátem super ómnia dæmónia, et ut languóres curárent. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Qualis débeat esse, qui evangelízat regnum Dei, præcéptis evangélicis designátur: ut sine virga, sine pera, sine calceaménto, sine pane, sine pecúnia, hoc est, subsídii sæculáris adminícula non requírens, fidéque tutus, putet sibi quo minus ea requírat, magis posse suppétere. Quæ possunt, qui volunt, ad eum deriváre tractátum, ut spiritálem tantúmmodo locus iste formáre videátur afféctum: qui velut induméntum quoddam videátur córporis exuísse, non solum potestáte rejécta contemptísque divítiis, sed étiam carnis ipsíus illécebris abdicátis. Quibus primo ómnium datur pacis atque constántiæ generále mandátum, ut pacem ferant, constántiam servent, hospitális necessitúdinis jura custódiant: aliénum a prædicatóre regni cæléstis ástruens cursitáre per domos, et inviolábilis hospítii jura mutáre.")
               (:text "Sed, ut hospítii grátia deferénda censétur: ita étiam, si non recipiántur, excutiéndum púlverem, et egrediéndum de civitáte mandátur. Quo non medíocris boni remunerátio docétur hospítii: ut non solum pacem tribuámus hospítibus, verum étiam, si qua eos terrénæ obúmbrant delícta levitátis, recéptis apostólicæ prædicatiónis vestígiis auferántur. Nec otióse secúndum Matthǽum, domus, quam ingrediántur Apóstoli, eligénda decérnitur: ut mutándi hospítii, necessitudinísque violándæ causa non súppetat. Non tamen éadem cáutio receptóri mandátur hospítii: ne, dum hospes elígitur, hospitálitas ipsa minuátur.")
               (:text "Sed hæc, ut secúndum lítteram de hospítii religióne venerábilis est forma præcépti: ita étiam de mystério senténtia cæléstis arrídet. Etenim cum domus elígitur, dignus hospes inquíritur. Videámus ígitur, ne forte Ecclésia præferénda designétur, et Christus. Quæ enim dígnior domus apostólicæ prædicatiónis ingréssu, quam sancta Ecclésia? Aut quis præferéndus magis ómnibus vidétur esse quam Christus, qui pedes suis laváre consuévit hospítibus: et quoscúmque sua recéperit domo, pollútis non patiátur habitáre vestígiis; sed maculósos licet vitæ prióris, in réliquum tamen dignétur mundáre procéssus? Hic est ígitur solus, quem nemo debet desérere, nemo mutáre. Cui bene dícitur: Dómine, ad quem íbimus? verba vitæ ætérnæ habes, et nos crédimus."))
              :responsories
              ((:respond "Advénit ignis divínus, non combúrens sed illúminans, non consúmens sed lucens: et invénit corda discipulórum receptácula munda:"
                  :verse "Invénit eos concórdes caritáte, et collustrávit eos inúndans grátia Deitátis."
                  :repeat "Et tríbuit eis charísmatum dona, allelúja, allelúja."
                  :gloria nil)
               (:respond "Spíritus Sanctus replévit totam domum, ubi erant Apóstoli: et apparuérunt illis dispertítæ linguæ, tamquam ignis, sedítque supra síngulos eórum:"
                  :verse "Dum ergo essent in unum discípuli congregáti propter metum Judæórum, sonus repénte de cælo venit super eos."
                  :repeat "Et repléti sunt omnes Spíritu Sancto, et cœpérunt loqui váriis linguis, prout Spíritus Sanctus dabat éloqui illis, allelúja, allelúja, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc7-5: Feria Sexta Quattuor Temporum Pentecostes
    ((7 . 5) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Liber 5 in cap. 5 Lucæ, post initium"
               :text "In illo témpore: Factum est in una diérum, et Jesus sedébat docens. Et erant pharisǽi sedéntes, et legis doctóres, qui vénerant ex omni castéllo Galilǽæ et Judǽæ, et Jerúsalem: et virtus Dómini erat ad sanándum eos. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Non otiósa hujus paralýtici, nec angústa medicína est, quando Dóminus et orásse præmíttitur; non útique propter suffrágium, sed propter exémplum. Imitándi enim spécimen dedit, non precándi ámbitum requisívit. Et conveniéntibus ex omni Galilǽa, et Judǽa, et Jerúsalem, legis doctóribus, inter ceterórum remédia debílium, paralýtici istíus medicína descríbitur. Primum ómnium, quod ante díximus, unusquísque æger peténdæ precatóres salútis debet adhibére, per quos nostræ vitæ compágo resolúta, actuúmque nostrórum clauda vestígia, verbi cæléstis remédio reforméntur.")
               (:text "Sint ígitur áliqui monitóres mentis, qui ánimum hóminis, quamvis exterióris córporis debilitáte torpéntem, ad superióra érigant. Quorum rursus adminículis et attóllere et humiliáre se fácilis ante Jesum locétur, Domínico vidéri dignus aspéctu. Humilitátem enim réspicit Dóminus: quia respéxit humilitátem ancíllæ suæ. Quorum fidem ut vidit, dixit: Homo, remittúntur tibi peccáta tua. Magnus Dóminus, qui aliórum mérito ignóscit áliis: et dum álios probat, áliis reláxat erráta. Cur apud te, homo, colléga non váleat, cum apud Deum servus et interveniéndi méritum, et jus hábeat impetrándi?")
               (:text "Disce, qui júdicas, ignóscere: disce, qui æger es, impetráre. Si grávium peccatórum diffídis véniam, ádhibe precatóres, ádhibe Ecclésiam, quæ pro te precétur, cujus contemplatióne, quod tibi Dóminus negáre posset, ignóscat. Et quamvis históriæ fidem non debeámus omíttere, ut vere paralýtici istíus corpus credámus esse sanátum: cognósce tamen interióris hóminis sanitátem, cui peccáta donántur. Cum Judǽi ásserunt peccáta a solo Deo posse concédi, Deum útique eum confiténtur; suóque judício perfídiam suam produnt, qui opus ástruunt, ut persónam negent."))
              :responsories
              ((:respond "Non vos me elegístis, sed ego elégi vos, et pósui vos:"
                  :verse "Sicut misit me Pater, et ego mitto vos."
                  :repeat "Ut eátis, et fructum afferátis, et fructus vester máneat, allelúja, allelúja."
                  :gloria nil)
               (:respond "Spíritus Dómini replévit orbem terrárum:"
                  :verse "Omnium est enim ártifex, omnem habens virtútem, ómnia prospíciens."
                  :repeat "Et hoc quod cóntinet ómnia, sciéntiam habet vocis, allelúja, allelúja."
                  :gloria t)
               nil)))

    ;; Pasc7-6: Sabbato Quattuor Temporum Pentecostes
    ((7 . 6) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Liber 4 in cap. 4 Lucæ, circa finem"
               :text "In illo témpore: Surgens Jesus de synagóga, introívit in domum Simónis. Socrus autem Simónis tenebátur magnis fébribus. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Vide cleméntiam Dómini Salvatóris: nec indignatióne commótus nec scélere offénsus, nec injúria violátus Judǽam déserit: quin étiam ímmemor injúriæ, memor cleméntiæ, nunc docéndo, nunc liberándo, nunc sanándo, infídæ plebis corda demúlcet. Et bene sanctus Lucas virum ab spíritu nequítiæ liberátum ante præmísit, et subdit féminæ sanitátem. Utrúmque enim sexum Dóminus curatúrus advénerat: sed prior sanári débuit, qui prior creátus est; nec prætermítti illa, quæ mobilitáte magis ánimi, quam pravitáte peccáverat.")
               (:text "Sábbato medicínæ Domínicæ ópera cœpta signíficat, ut inde nova creatúra cœ́perit, ubi vetus creatúra ante desívit: nec sub lege esse Dei Fílium, sed supra legem in ipso princípio designáret: nec solvi legem, sed impléri. Neque enim per legem, sed verbo factus est mundus, sicut légimus: Verbo Dómini cæli firmáti sunt. Non sólvitur ergo lex, sed implétur: ut fiat renovátio hóminis jam labéntis. Unde et Apóstolus ait: Exspoliántes vos véterem hóminem, indúite novum, qui secúndum Deum creátus est.")
               (:text "Et bene sábbato cœpit, ut ipsum se osténderet Creatórem, qui ópera opéribus intéxeret, et prosequerétur opus, quod ipse jam cœ́perat: ut si domum faber renováre dispónat, non a fundaméntis, sed a culmínibus íncipit sólvere vetustátem. Itaque ibi prius manum ádmovet, ubi ante desíerat: deínde a minóribus íncipit, ut ad majóra pervéniat. Liberáre a dǽmone et hómines, sed in verbo Dei possunt: resurrectiónem mórtuis imperáre, divínæ solíus est potestátis. Fortássis étiam in typo mulíeris illíus socrus Simónis et Andréæ, váriis críminum fébribus caro nostra languébat, et diversárum cupiditátum immódicis æstuábat illécebris. Nec minórem febrem amóris esse díxerim, quam calóris. Itaque illa ánimum, hæc corpus inflámmat. Febris enim nostra, avarítia est: febris nostra, libído est: febris nostra, luxúria est: febris nostra, ambítio est: febris nostra, iracúndia est."))
              :responsories
              ((:respond "Repléti sunt omnes Spíritu Sancto: et cœpérunt loqui, prout Spíritus Sanctus dabat éloqui illis:"
                  :verse "Loquebántur váriis linguis Apóstoli magnália Dei."
                  :repeat "Et convénit multitúdo dicéntium, allelúja."
                  :gloria t)
               (:respond "Jam non dicam vos servos, sed amícos meos; quia ómnia cognovístis, quæ operátus sum in médio vestri, allelúja:"
                  :verse "Vos amíci mei estis, si fecéritis quæ ego præcípio vobis."
                  :repeat "Accípite Spíritum Sanctum in vobis Paráclitum: ille est, quem Pater mittet vobis, allelúja."
                  :gloria nil)
               nil)))
    )
  "Ferial Matins data for Eastertide weekdays.
Each entry is ((WEEK . DOW) . (:lessons (L1 L2 L3) :responsories (R1 R2 R3))).
WEEK 0 = Easter octave, weeks 1-6 = post-octave, week 7 = Pentecost octave.
Easter/Pentecost octave entries may have only 2 responsories (Te Deum
replaces R3 on those days).")

(defun bcp-roman-season-easter--ferial-week-dow (date)
  "Return (WEEK . DOW) for DATE within Eastertide feriae, or nil.
WEEK is 0 (Easter octave) through 7 (Pentecost octave).
DOW is 1=Mon..6=Sat.  Returns nil on Sundays and outside Eastertide."
  (let* ((year (caddr date))
         (feasts (bcp-moveable-feasts year))
         (easter (cdr (assq 'easter feasts)))
         (easter-abs (calendar-absolute-from-gregorian easter))
         (date-abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date))
         (diff (- date-abs easter-abs)))
    ;; Skip Sundays; Eastertide feriae run from Easter Monday (diff=1)
    ;; through Saturday after Pentecost (diff=55)
    (when (and (> dow 0) (>= diff 1) (<= diff 55))
      (let ((week (/ diff 7)))
        (cons week dow)))))

(defun bcp-roman-season-easter-ferial-matins (date)
  "Return ferial Matins data for DATE if it is an Eastertide weekday.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories,
or nil if DATE is a Sunday or outside Eastertide."
  (let ((key (bcp-roman-season-easter--ferial-week-dow date)))
    (when key
      (cdr (assoc key bcp-roman-season-easter--ferial-matins)))))


(provide 'bcp-roman-season-easter)

;;; bcp-roman-season-easter.el ends here
