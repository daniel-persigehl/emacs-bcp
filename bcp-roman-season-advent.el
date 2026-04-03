;;; bcp-roman-season-advent.el --- Advent Proper of the Time -*- lexical-binding: t -*-

;;; Commentary:

;; Proper of the Time data for the Advent season (DA 1911 rubrics).
;; Covers the four Sundays of Advent (Adv1-0 through Adv4-0 in DO
;; terminology), providing collects, dominical Matins data (9 lessons,
;; 8 responsories), and non-Matins hour data (antiphons, capitula).
;;
;; Lesson structure follows `bcp-roman-tempora.el' Per Annum pattern:
;;   Nocturn I  (L1-L3): Scripture with :ref, :source, :text
;;   Nocturn II (L4-L6): Patristic with :ref, :source, :text
;;   Nocturn III (L7-L9): Homily with :ref, :source, :text
;;
;; Non-Matins antiphons and capitula are registered in the antiphonary
;; and capitulary respectively, keyed by Latin incipit.  Season file
;; alist entries reference symbols, not inline text.
;;
;; Data extracted from Divinum Officium Latin/English Tempora files.
;;
;; Key public functions:
;;   `bcp-roman-season-advent-collect'           -- Advent Sunday collect incipit
;;   `bcp-roman-season-advent-dominical-matins'  -- Advent dominical Matins data
;;   `bcp-roman-season-advent-dominical-hours'   -- Advent non-Matins hour data

;;; Code:

(require 'bcp-common-roman)
(require 'bcp-roman-antiphonary)
(require 'bcp-roman-capitulary)
(require 'bcp-roman-collectarium)
(require 'bcp-calendar)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Advent Sunday collects (Advent 1–4)

;;; ─── Advent 1 ──────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'excita-quaesumus-domine-potentiam-tuam-et-veni-ut-ab
 (list :latin (concat
              "Excita, quǽsumus, Dómine, poténtiam tuam, et veni: ut ab \
imminéntibus peccatórum nostrórum perículis, te mereámur protegénte éripi, \
te liberánte salvári:\n"
              bcp-roman-qui-vivis)
       :conclusion 'qui-vivis
       :translations
       '((do . "Stir up, O Lord, we pray thee, thy strength, and come among \
us, that whereas through our sins and wickedness we do justly apprehend thy \
wrathful judgments hanging over us, thy bountiful grace and mercy may speedily \
help and deliver us.\nWho livest and reignest."))))

;;; ─── Advent 2 ──────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'excita-domine-corda-nostra
 (list :latin (concat
              "Excita, Dómine, corda nostra ad præparándas Unigéniti tui \
vias: ut, per ejus advéntum, purificátis tibi méntibus servíre mereámur:\n"
              bcp-roman-qui-tecum)
       :conclusion 'qui-tecum
       :translations
       '((do . "Stir up our hearts, O Lord, to make ready the ways of thine \
Only-begotten Son, that by His coming our minds being purified, we may the \
more worthily give up ourselves to thy service.\n\
Who with Thee liveth and reigneth."))))

;;; ─── Advent 3 ──────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'aurem-tuam-quaesumus-domine
 (list :latin (concat
              "Aurem tuam, quǽsumus, Dómine, précibus nostris accómmoda: \
et mentis nostræ ténebras, grátia tuæ visitatiónis illústra:\n"
              bcp-roman-qui-vivis)
       :conclusion 'qui-vivis
       :translations
       '((do . "O Lord, we beseech thee, mercifully incline thine ears unto \
our prayers, and lighten the darkness of our minds by the grace of thy \
heavenly visitation.\nWho livest and reignest."))))

;;; ─── Advent 4 ──────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'excita-quaesumus-domine-potentiam-tuam-et-veni-et-magna
 (list :latin (concat
              "Excita, quǽsumus, Dómine, poténtiam tuam, et veni: et magna \
nobis virtúte succúrre; ut per auxílium grátiæ tuæ, quod nostra peccáta \
præpédiunt, indulgéntia tuæ propitiatiónis accéleret:\n"
              bcp-roman-qui-vivis)
       :conclusion 'qui-vivis
       :translations
       '((do . "Stir up, we beseech thee, O Lord, thy power, and come; make \
haste to our aid with thy great might; that, by the help of thy grace, that \
which is hindered by our sins may be hastened by thy merciful forgiveness.\n\
Who livest and reignest."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Advent antiphon registrations

;;; ─── Advent 1 antiphons ────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'ecce-nomen-domini
 '(:latin "Ecce nomen Dómini * venit de longínquo, et cláritas ejus replet orbem terrárum."
   :translations
   ((do . "Behold, the name of the Lord * cometh from far, and the whole earth is full of His glory."))))

(bcp-roman-antiphonary-register
 'spiritus-sanctus-in-te
 '(:latin "Spíritus Sanctus * in te descéndet, María: ne tímeas, habébis in útero Fílium Dei, allelúja."
   :translations
   ((do . "The Holy Ghost shall come upon thee, * O Mary; fear not, thou shalt bear in thy womb the Son of God. Alleluia."))))

(bcp-roman-antiphonary-register
 'ne-timeas-maria
 '(:latin "Ne tímeas, María, * invenísti enim grátiam apud Dóminum: ecce concípies, et páries fílium, allelúja."
   :translations
   ((do . "Fear not, Mary, * for thou hast found grace with the Lord; behold, thou shalt conceive in thy womb, and bring forth a son. Alleluia."))))

(bcp-roman-antiphonary-register
 'in-illa-die-stillabunt
 '(:latin "In illa die * stillábunt montes dulcédinem, et colles fluent lac et mel, allelúja."
   :translations
   ((do . "In that day * the mountains shall drop down sweet wine, and the hills shall flow with milk and honey. Alleluia."))))

(bcp-roman-antiphonary-register
 'jucundare-filia-sion
 '(:latin "Jucundáre, * fília Sion, et exsúlta satis, fília Jerúsalem, allelúja."
   :translations
   ((do . "Sing, O daughter of Zion, * and rejoice with all the heart, O daughter of Jerusalem. Alleluia."))))

(bcp-roman-antiphonary-register
 'ecce-dominus-veniet-et-omnes
 '(:latin "Ecce Dóminus véniet, * et omnes Sancti ejus cum eo: et erit in die illa lux magna, allelúja."
   :translations
   ((do . "Behold, the Lord shall come, * and all His saints with Him; and it shall come to pass in that day that the light shall be great. Alleluia."))))

(bcp-roman-antiphonary-register
 'omnes-sitientes-venite
 '(:latin "Omnes sitiéntes, * veníte ad aquas: quǽrite Dóminum, dum inveníri potest, allelúja."
   :translations
   ((do . "Lo, every one that thirsteth * come ye to the waters: seek ye the Lord while He may be found. Alleluia."))))

(bcp-roman-antiphonary-register
 'ecce-veniet-propheta-magnus
 '(:latin "Ecce véniet * Prophéta magnus, et ipse renovábit Jerúsalem, allelúja."
   :translations
   ((do . "Behold, a great Prophet * shall arise, and He shall build up a new Jerusalem. Alleluia."))))

;;; ─── Advent 2 antiphons ────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'veni-domine-visitare-nos
 '(:latin "Veni, Dómine, * visitáre nos in pace, ut lætémur coram te corde perfécto."
   :translations
   ((do . "Come, O Lord, * visit us in peace, that we may rejoice before thee with all our heart."))))

(bcp-roman-antiphonary-register
 'joannes-autem-cum-audisset
 '(:latin "Joánnes autem * cum audísset in vínculis ópera Christi, mittens duos ex discípulis suis, ait illi: Tu es qui ventúrus es, an álium exspectámus?"
   :translations
   ((do . "Now when John * had heard in the prison the works of Christ, he sent two of his disciples and said unto Him: Art Thou He That should come, or do we look for another?"))))

(bcp-roman-antiphonary-register
 'tu-es-qui-venturus-es
 '(:latin "Tu es, qui ventúrus es, * an álium exspectámus? Dícite Joánni quæ vidístis: Ad lumen rédeunt cæci, mórtui resúrgunt, páuperes evangelizántur, allelúja."
   :translations
   ((do . "Art thou he that art to come * or look we for another? Go and relate to John what you have seen: the blind see, the dead rise again, to the poor the gospel is preached. Alleluia."))))

(bcp-roman-antiphonary-register
 'ecce-in-nubibus-caeli
 '(:latin "Ecce in núbibus cæli * Dóminus véniet cum potestáte magna, allelúja."
   :translations
   ((do . "Behold, the Lord * cometh in the clouds of heaven with great power. Alleluia."))))

(bcp-roman-antiphonary-register
 'urbs-fortitudinis-nostrae
 '(:latin "Urbs fortitúdinis * nostræ Sion, Salvátor ponétur in ea murus et antemurále: aperíte portas, quia nobíscum Deus, allelúja."
   :translations
   ((do . "Our Zion is a strong city, * the Saviour will God appoint in her for walls and bulwarks; open ye the gates, for God is with us. Alleluia."))))

(bcp-roman-antiphonary-register
 'ecce-apparebit-dominus
 '(:latin "Ecce apparébit * Dóminus, et non mentiétur: si moram fécerit, exspécta eum, quia véniet, et non tardábit, allelúja."
   :translations
   ((do . "Behold, the Lord * shall appear and not lie though He tarry, wait for Him, because He will come and will not tarry. Alleluia."))))

(bcp-roman-antiphonary-register
 'montes-et-colles-cantabunt
 '(:latin "Montes et colles * cantábunt coram Deo laudem, et ómnia ligna silvárum plaudent mánibus: quóniam véniet Dominátor Dóminus in regnum ætérnum, allelúja, allelúja."
   :translations
   ((do . "The mountains and the hills * shall break forth before God into singing, and all the trees of the wood shall clap their hands for the Lord the Ruler cometh, and He shall reign for ever and ever. Alleluia, Alleluia."))))

(bcp-roman-antiphonary-register
 'ecce-dominus-noster-cum
 '(:latin "Ecce Dóminus * noster cum virtúte véniet, et illuminábit óculos servórum suórum, allelúja."
   :translations
   ((do . "Behold, our Lord * cometh with power, and He shall lighten the eyes of His servants. Alleluia."))))

;;; ─── Advent 3 antiphons ────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'ante-me-non-est-formatus
 '(:latin "Ante me * non est formátus Deus, et post me non erit: quia mihi curvábitur omne genu, et confitébitur omnis lingua."
   :translations
   ((do . "Before Me * there was no god formed, neither shall there be after Me; for unto Me every knee shall bow, and every tongue shall swear."))))

(bcp-roman-antiphonary-register
 'super-solium-david
 '(:latin "Super sólium * David, et super regnum ejus sedébit in ætérnum, allelúja."
   :translations
   ((do . "He shall sit * upon the throne of David, and upon his kingdom for ever. Alleluia."))))

(bcp-roman-antiphonary-register
 'beata-es-maria-quae-credidisti
 '(:latin "Beáta es, María, * quæ credidísti Dómino: perficiéntur in te, quæ dicta sunt tibi a Dómino, allelúja."
   :translations
   ((do . "Blessed art thou, * O Mary, who hast believed the Lord, for there shall be a performance of those things which were told thee from the Lord. Alleluia."))))

(bcp-roman-antiphonary-register
 'veniet-dominus-et-non
 '(:latin "Véniet Dóminus, * et non tardábit, et illuminábit abscóndita tenebrárum, et manifestábit se ad omnes gentes, allelúja."
   :translations
   ((do . "The Lord will come, * and will not tarry; He both will bring to light the hidden things of darkness, and will make Himself manifest to all people. Alleluia."))))

(bcp-roman-antiphonary-register
 'jerusalem-gaude-gaudio
 '(:latin "Jerúsalem, gaude * gáudio magno, quia véniet tibi Salvátor, allelúja."
   :translations
   ((do . "Rejoice greatly, O Jerusalem, * for thy Saviour cometh unto thee. Alleluia."))))

(bcp-roman-antiphonary-register
 'dabo-in-sion-salutem
 '(:latin "Dabo in Sion * salútem, et in Jerúsalem glóriam meam, allelúja."
   :translations
   ((do . "I will place salvation in Zion, * and My glory in Jerusalem. Alleluia."))))

(bcp-roman-antiphonary-register
 'montes-et-omnes-colles
 '(:latin "Montes et omnes colles * humiliabúntur: et erunt prava in dirécta, et áspera in vias planas: veni, Dómine, et noli tardáre, allelúja."
   :translations
   ((do . "Every mountain and hill * shall be made low, and the crooked shall be made straight, and the rough places plain; O Lord, come and make no tarrying. Alleluia."))))

(bcp-roman-antiphonary-register
 'juste-et-pie-vivamus
 '(:latin "Juste et pie * vivámus, exspectántes beátam spem, et advéntum Dómini."
   :translations
   ((do . "We should live * righteously and godly, looking for that blessed hope and the coming of the Lord."))))

;;; ─── Advent 4 antiphons ────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'ave-maria-gratia-plena
 '(:latin "Ave, María, * grátia plena: Dóminus tecum: benedícta tu in muliéribus, allelúja."
   :translations
   ((do . "Hail, Mary, full of grace, * the Lord is with thee; blessed art thou among women. Alleluia."))))

(bcp-roman-antiphonary-register
 'canite-tuba-in-sion
 '(:latin "Cánite tuba * in Sion, quia prope est dies Dómini: ecce véniet ad salvándum nos, allelúja, allelúja."
   :translations
   ((do . "Blow ye the trumpet * in Zion, for the day of the Lord is nigh at hand: behold, He cometh to save us! Alleluia, Alleluia."))))

(bcp-roman-antiphonary-register
 'ecce-veniet-desideratus
 '(:latin "Ecce véniet * desiderátus cunctis géntibus: et replébitur glória domus Dómini, allelúja."
   :translations
   ((do . "Behold, the desire * of all nations shall come; and the house of the Lord shall be filled with glory. Alleluia."))))

(bcp-roman-antiphonary-register
 'erunt-prava-in-directa
 '(:latin "Erunt prava * in dirécta, et áspera in vias planas: veni, Dómine, et noli tardáre, allelúja."
   :translations
   ((do . "The crooked * shall be made straight, and the rough places plain; O Lord, come, and make no tarrying. Alleluia."))))

(bcp-roman-antiphonary-register
 'dominus-veniet-occurrite
 '(:latin "Dóminus véniet, * occúrrite illi, dicéntes: Magnum princípium, et regni ejus non erit finis: Deus, Fortis, Dominátor, Princeps pacis, allelúja, allelúja."
   :translations
   ((do . "The Lord cometh! * Go ye out to meet Him, and say: How great is His dominion, and of His kingdom there shall be no end! He is the mighty God, the Ruler, the Prince of Peace. Alleluia, Alleluia."))))

(bcp-roman-antiphonary-register
 'omnipotens-sermo-tuus
 '(:latin "Omnípotens Sermo tuus, * Dómine, a regálibus sédibus véniet, allelúja."
   :translations
   ((do . "Thine Almighty Word, * O Lord, shall leap down out of thy royal throne. Alleluia."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Advent capitulum registrations

;;; ─── Advent 1 capitula ─────────────────────────────────────────────────

(bcp-roman-capitulary-register
 'hora-est-jam-nos
 '(:latin "Fratres: Hora est jam nos de somno súrgere: nunc enim própior est nostra salus, quam cum credídimus."
   :ref "Rom 13:11"
   :translations
   ((do . "And that knowing the season; that it is now the hour for us to rise from sleep. For now our salvation is nearer than when we believed."))))

(bcp-roman-capitulary-register
 'sicut-in-die-honeste
 '(:latin "Sicut in die honéste ambulémus, non in comessatiónibus et ebrietátibus, non in cubílibus et impudicítiis, non in contentióne et æmulatióne; sed induímini Dóminum Jesum Christum."
   :ref "Rom 13:13-14"
   :translations
   ((do . "Let us walk honestly, as in the day: not in rioting and drunkenness, not in chambering and impurities, not in contention and envy: But put ye on the Lord Jesus Christ."))))

;;; ─── Advent 2 capitula ─────────────────────────────────────────────────

(bcp-roman-capitulary-register
 'quaecumque-scripta-sunt
 '(:latin "Fratres: Quæcúmque scripta sunt, ad nostram doctrínam scripta sunt: ut per patiéntiam, et consolatiónem Scripturárum spem habeámus."
   :ref "Rom 15:4"
   :translations
   ((do . "For what things soever were written, were written for our learning: that through patience and the comfort of the scriptures, we might have hope."))))

(bcp-roman-capitulary-register
 'deus-autem-spei
 '(:latin "Deus autem spei répleat vos omni gáudio et pace in credéndo: ut abundétis in spe, et in virtúte Spíritus Sancti."
   :ref "Rom 15:13"
   :translations
   ((do . "Now the God of hope fill you with all joy and peace in believing; that you may abound in hope, and in the power of the Holy Ghost."))))

;;; ─── Advent 3 capitula ─────────────────────────────────────────────────

(bcp-roman-capitulary-register
 'gaudete-in-domino-semper
 '(:latin "Fratres: Gaudéte in Dómino semper: íterum dico, gaudéte. Modéstia vestra nota sit ómnibus homínibus: Dóminus enim prope est."
   :ref "Phil 4:4-5"
   :translations
   ((do . "Rejoice in the Lord always; again, I say, rejoice. Let your modesty be known to all men. The Lord is nigh."))))

(bcp-roman-capitulary-register
 'et-pax-dei-quae-exsuperat
 '(:latin "Et pax Dei, quæ exsúperat omnem sensum, custódiat corda vestra, et intellegéntias vestras in Christo Jesu Dómino nostro."
   :ref "Phil 4:7"
   :translations
   ((do . "And the peace of God, which surpasseth all understanding, keep your hearts and minds in Christ Jesus."))))

;;; ─── Advent 4 capitula ─────────────────────────────────────────────────

(bcp-roman-capitulary-register
 'sic-nos-existimet-homo
 '(:latin "Fratres: Sic nos exístimet homo ut minístros Christi, et dispensatóres mysteriórum Dei. Hic jam quǽritur inter dispensatóres, ut fidélis quis inveniátur."
   :ref "1 Cor 4:1-2"
   :translations
   ((do . "Let a man so account of us as of the ministers of Christ, and the dispensers of the mysteries of God. Here now it is required among the dispensers, that a man be found faithful."))))

(bcp-roman-capitulary-register
 'itaque-nolite-ante-tempus
 '(:latin "Itaque nolíte ante tempus judicáre, quoadúsque véniat Dóminus: qui et illuminábit abscóndita tenebrárum, et manifestábit consília córdium: et tunc laus erit unicuíque a Deo."
   :ref "1 Cor 4:5"
   :translations
   ((do . "Therefore judge not before the time; until the Lord come, who both will bring to light the hidden things of darkness, and will make manifest the counsels of the hearts; and then shall every man have praise from God."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sunday-to-collect mapping

(defconst bcp-roman-season-advent--collects
  [nil ; slot 0 unused (1-indexed)
   excita-quaesumus-domine-potentiam-tuam-et-veni-ut-ab   ; Advent 1
   excita-domine-corda-nostra                              ; Advent 2
   aurem-tuam-quaesumus-domine                             ; Advent 3
   excita-quaesumus-domine-potentiam-tuam-et-veni-et-magna]; Advent 4
  "Advent Sunday collect incipits, 1-indexed by Advent Sunday number.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Advent Sunday number computation

(defun bcp-roman-season-advent--sunday-number (date)
  "Return the Advent Sunday number (1–4) for the Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns nil if DATE is outside Advent."
  (let* ((year (caddr date))
         (adv1 (bcp-advent-1 year))
         (adv1-abs (calendar-absolute-from-gregorian adv1))
         (date-abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date))
         (sunday-abs (- date-abs dow))
         (weeks (/ (- sunday-abs adv1-abs) 7)))
    (when (and (>= weeks 0) (<= weeks 3))
      (1+ weeks))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Advent dominical Matins lessons and responsories (Advent 1–4)
;;
;; 4 Sunday datasets extracted from Divinum Officium Tempora files.
;; Each entry: (WEEK . (:lessons (L1..L9) :responsories (R1..R8))).
;; Same structure as `bcp-roman-tempora--dominical-matins'.

(defconst bcp-roman-season-advent--dominical-matins
  '(

    ;; ════════════════════════════════════════════════════════════════════
    ;; Advent 1 — Dominica I Adventus (DO: Adv1-0)
    ;; Scripture: Isaias 1; Patristic: St Leo, Sermo 8 de jejunio;
    ;; Homily: St Gregory, Hom. 1 in Evang. (Luke 21:25-33)
    ;; ════════════════════════════════════════════════════════════════════

    (1
     . (:lessons
        (
        (:ref "Isa 1:1-3" :source "Incipit liber Isaíæ Prophétæ" :text "\
1 Vísio Isaíæ fílii Amos, quam vidit super Judam et Jerúsalem, in diébus \
Ozíæ, Jóatham, Achaz, et Ezechíæ, regum Juda.\n\
2 Audíte, cæli, et áuribus pércipe, terra, quóniam Dóminus locútus est: \
Fílios enutrívi, et exaltávi: ipsi autem sprevérunt me.\n\
3 Cognóvit bos possessórem suum, et ásinus præsépe dómini sui: Israël \
autem me non cognóvit, et pópulus meus non intelléxit.")  ; L1

        (:ref "Isa 1:4-6" :text "\
4 Væ genti peccatríci, pópulo gravi iniquitáte, sémini nequam, fíliis \
scelerátis: dereliquérunt Dóminum, blasphemavérunt Sanctum Israël, \
abalienáti sunt retrórsum.\n\
5 Super quo percútiam vos ultra, addéntes prævaricatiónem? omne caput \
lánguidum, et omne cor mærens.\n\
6 A planta pedis usque ad vérticem non est in eo sánitas: vulnus, et \
livor, et plaga tumens non est circumligáta, nec curáta medicámine, \
neque fota óleo.")  ; L2

        (:ref "Isa 1:7-9" :text "\
7 Terra vestra desérta, civitátes vestræ succénsæ igni: regiónem vestram \
coram vobis aliéni dévorant, et desolábitur sicut in vastitáte hostíli.\n\
8 Et derelinquétur fília Sion ut umbráculum in vínea, et sicut tugúrium \
in cucumerário, et sicut cívitas quæ vastátur.\n\
9 Nisi Dóminus exercítuum reliquísset nobis semen, quasi Sódoma \
fuissémus, et quasi Gomórrha símiles essémus.")  ; L3

        (:ref "Sermo 8 de jejunio decimi mensis" :source "Sermo sancti Leónis Papæ" :text "\
Cum de advéntu regni Dei, et de mundi fine ac témporum, discípulos suos \
Salvátor instrúeret, totámque Ecclésiam suam in Apóstolis erudíret: \
Cavéte, inquit, ne forte gravéntur corda vestra in crápula, et ebrietáte, \
et cogitatiónibus sæculáribus. Quod útique præcéptum, dilectíssimi, ad \
nos speciálius pertinére cognóscimus, quibus denuntiátus dies, etiámsi \
est occúltus, non dubitátur esse vicínus.")  ; L4

        (:text "\
Ad cujus advéntum omnem hóminem cónvenit præparári: ne quem aut ventri \
déditum, aut curis sæculáribus invéniat implicátum. Quotidiáno enim, \
dilectíssimi, experiménto probátur, potus satietáte áciem mentis obtúndi, \
et cibórum nimietáte vigórem cordis hebetári; ita ut delectátio edéndi \
étiam córporum contrária sit salúti, nisi rátio temperántiæ obsístat \
illécebræ, et quod futúrum est óneri, súbtrahat voluptáti.")  ; L5

        (:text "\
Quamvis enim sine ánima nihil caro desíderet, et inde accípiat sensus, \
unde sumit et motus: ejúsdem tamen est ánimæ, quædam sibi súbditæ negáre \
substántiæ, et interióri judício ab inconveniéntibus exterióra frenáre: \
ut a corpóreis cupiditátibus sǽpius líbera, in aula mentis possit divínæ \
vacáre sapiéntiæ: ubi omni strépitu terrenárum silénte curárum, in \
meditatiónibus sanctis, et in delíciis lætétur ætérnis.")  ; L6

        (:ref "Luc 21:25-33" :source "Léctio sancti Evangélii secúndum Lucam" :text "\
In illo témpore: Dixit Jesus discípulis suis: Erunt signa in sole, et \
luna, et stellis, et in terris pressúra géntium. Et réliqua.\n\
Homilía sancti Gregórii Papæ\n\
Dóminus ac Redémptor noster parátos nos inveníre desíderans, senescéntem \
mundum quæ mala sequántur denúntiat, ut nos ab ejus amóre compéscat. \
Appropinquántem ejus términum quantæ percussiónes prævéniant, innotéscit: \
ut, si Deum metúere in tranquillitáte nólumus, saltem vicínum ejus \
judícium vel percussiónibus attríti timeámus.")  ; L7

        (:text "\
Huic étenim lectióni sancti Evangélii, quam modo vestra fratérnitas \
audívit, paulo supérius Dóminus præmísit, dicens: Exsúrget gens contra \
gentem, et regnum advérsus regnum: et erunt terræmótus magni per loca, \
et pestiléntiæ, et fames. Et quibúsdam interpósitis, hoc, quod modo \
audístis, adjúnxit: Erunt signa in sole, et luna, et stellis, et in \
terris pressúra géntium præ confusióne sónitus maris, et flúctuum. Ex \
quibus profécto ómnibus ália jam facta cérnimus, ália in próximo ventúra \
formidámus.")  ; L8

        (:text "\
Nam gentem contra gentem exsúrgere, earúmque pressúram terris insístere, \
plus jam in nostris tempóribus cérnimus, quam in codícibus légimus. Quod \
terræmótus urbes innúmeras óbruat, ex áliis mundi pártibus scitis quam \
frequénter audívimus. Pestiléntias sine cessatióne pátimur. Signa vero \
in sole, et luna, et stellis, adhuc apérte mínime vídimus: sed quia et \
hæc non longe sint, ex ipsa jam áëris immutatióne collígimus.")  ; L9
        )

        :responsories
        (
        ;; R1: Aspiciens a longe — the Great Responsory (simplified to first verse)
        (:respond "Aspíciens a longe, ecce vídeo Dei poténtiam veniéntem, et nébulam totam terram tegéntem. Ite óbviam ei, et dícite: Núntia nobis, si tu es ipse, * Qui regnatúrus es in pópulo Israël." :verse "Quique terrígenæ, et fílii hóminum, simul in unum dives et pauper." :repeat "Qui regnatúrus es in pópulo Israël.")  ; R1

        (:respond "Aspiciébam in visu noctis, et ecce in núbibus cæli Fílius hóminis veniébat: et datum est ei regnum, et honor: * Et omnis pópulus, tribus, et linguæ sérvient ei." :verse "Potéstas ejus, potéstas ætérna, quæ non auferétur: et regnum ejus, quod non corrumpétur." :repeat "Et omnis pópulus, tribus, et linguæ sérvient ei.")  ; R2

        (:respond "Missus est Gábriel Angelus ad Maríam Vírginem desponsátam Joseph, núntians ei verbum; et expavéscit Virgo de lúmine: ne tímeas, María, invenísti grátiam apud Dóminum: * Ecce concípies, et páries, et vocábitur Altíssimi Fílius." :verse "Dabit ei Dóminus Deus sedem David, patris ejus, et regnábit in domo Jacob in ætérnum." :repeat "Ecce concípies, et páries, et vocábitur Altíssimi Fílius.")  ; R3

        (:respond "Ave, María, grátia plena, Dóminus tecum: * Spíritus Sanctus supervéniet in te, et virtus Altíssimi obumbrábit tibi: quod enim ex te nascétur Sanctum, vocábitur Fílius Dei." :verse "Quómodo fiet istud, quóniam virum non cognósco? Et respóndens Angelus, dixit ei." :repeat "Spíritus Sanctus supervéniet in te, et virtus Altíssimi obumbrábit tibi: quod enim ex te nascétur Sanctum, vocábitur Fílius Dei.")  ; R4

        (:respond "Salvatórem exspectámus, Dóminum Jesum Christum, * Qui reformábit corpus humilitátis nostræ configurátum córpori claritátis suæ." :verse "Sóbrie, et juste, et pie vivámus in hoc sǽculo, exspectántes beátam spem, et advéntum glóriæ magni Dei." :repeat "Qui reformábit corpus humilitátis nostræ configurátum córpori claritátis suæ.")  ; R5

        (:respond "Obsecro, Dómine, mitte quem missúrus es: vide afflictiónem pópuli tui: * Sicut locútus es, veni, * Et líbera nos." :verse "Qui regis Israël, inténde, qui dedúcis velut ovem Joseph, qui sedes super Chérubim." :repeat "Sicut locútus es, veni, et líbera nos.")  ; R6

        (:respond "Ecce virgo concípiet, et páriet fílium, dicit Dóminus: * Et vocábitur nomen ejus Admirábilis, Deus, Fortis." :verse "Super sólium David, et super regnum ejus sedébit in ætérnum." :repeat "Et vocábitur nomen ejus Admirábilis, Deus, Fortis.")  ; R7

        (:respond "Audíte verbum Dómini, gentes, et annuntiáte illud in fínibus terræ: * Et ínsulis, quæ procul sunt, dícite: Salvátor noster advéniet." :verse "Annuntiáte, et audítum fácite: loquímini, et clamáte." :repeat "Et ínsulis, quæ procul sunt, dícite: Salvátor noster advéniet.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  ecce-nomen-domini
        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (in-illa-die-stillabunt
                          jucundare-filia-sion
                          ecce-dominus-veniet-et-omnes
                          omnes-sitientes-venite
                          ecce-veniet-propheta-magnus)
        :benedictus-antiphon  spiritus-sanctus-in-te
        :lauds-capitulum      hora-est-jam-nos
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       sicut-in-die-honeste
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon ne-timeas-maria
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Advent 2 — Dominica II Adventus (DO: Adv2-0)
    ;; Scripture: Isaias 11; Patristic: St Jerome, In Isaiam IV, c. 11;
    ;; Homily: St Gregory, Hom. 6 in Evang. (Matt 11:2-10)
    ;; ════════════════════════════════════════════════════════════════════

    (2
     . (:lessons
        (
        (:ref "Isa 11:1-4a" :source "De Isaía Prophéta" :text "\
1 Et egrediétur virga de radíce Jesse, et flos de radíce ejus ascéndet.\n\
2 Et requiéscet super eum Spíritus Dómini: spíritus sapiéntiæ et \
intelléctus, spíritus consílii et fortitúdinis, spíritus sciéntiæ et \
pietátis;\n\
3 Et replébit eum spíritus timóris Dómini: non secúndum visiónem \
oculórum judicábit, neque secúndum audítum áurium árguet:\n\
4 Sed judicábit in justítia páuperes, et árguet in æquitáte pro \
mansuétis terræ:")  ; L1

        (:ref "Isa 11:4b-7" :text "\
4 Et percútiet terram virga oris sui, et spíritu labiórum suórum \
interfíciet ímpium.\n\
5 Et erit justítia cíngulum lumbórum ejus: et fides cinctórium renis \
ejus.\n\
6 Habitábit lupus cum agno, et pardus cum hædo accubábit, vitúlus et \
leo et ovis simul morabúntur, et puer párvulus minábit eos.\n\
7 Vítulus et ursus pascéntur, simul requiéscent cátuli eórum, et leo \
quasi bos cómedet páleas.")  ; L2

        (:ref "Isa 11:8-10" :text "\
8 Et delectábitur infans ab úbere super forámine áspidis, et in \
cavérna réguli, qui ablactátus fúerit, manum suam mittet.\n\
9 Non nocébunt, et non occídent in univérso monte sancto meo: quia \
repléta est terra sciéntia Dómini, sicut aquæ maris operiéntes.\n\
10 In die illa radix Jesse, qui stat in signum populórum, ipsum gentes \
deprecabúntur, et erit sepúlcrum ejus gloriósum.")  ; L3

        (:ref "In Isaiam IV, c. 11" :source "De Expositióne sancti Hierónymi Presbýteri in Isaíam Prophétam" :text "\
Et egrediétur virga de radíce Jesse. Usque ad principium visiónis, vel \
pónderis Babylónis, quod vidit Isaías, fílius Amos, omnis hæc prophetía \
de Christo est: quam per partes vólumus explanare, ne simul propósita \
atque disserta lectóris confundat memóriam. Virgam et florem de radíce \
Jesse ipsum Dóminum Judæi interpretántur: quod scilicet in virga \
regnántis poténtia, in flore pulchritúdo monstrétur.")  ; L4

        (:text "\
Nos autem virgam de radíce Jesse sanctam Mariam Vírginem intelligámus, \
quæ nullum hábuit sibi frúticem cohæréntem, de qua et supra légimus: \
Ecce virgo concípiet et pariet fílium. Et florem, Dóminum Salvatórem, \
qui dicit in Cántico canticórum: Ego flos campi, et lílium convallium.")  ; L5

        (:text "\
Super hunc ígitur florem, qui de trunco et radíce Jesse per Mariam \
Vírginem repénte consúrget, requiéscet Spíritus Dómini: quia in ipso \
complácuit omnem plenitúdinem divinitátis habitáre corporáliter: \
nequáquam per partes, ut in ceteris Sanctis: sed juxta Evangélium \
eórum, quod Hebræo sermóne conscríptum legunt Nazaræi: Descéndet super \
eum omnis fons Spíritus Sancti. Dóminus autem Spíritus est: et ubi \
Spíritus Dómini, ibi libertas.")  ; L6

        (:ref "Matt 11:2-10" :source "Léctio sancti Evangélii secúndum Matthǽum" :text "\
In illo témpore: Cum audísset Joánnes in vínculis ópera Christi, mittens \
duos de discípulis suis, ait illi: Tu es qui ventúrus es, an álium \
exspectámus? Et réliqua.\n\
Homilía sancti Gregórii Papæ\n\
Visis tot signis tantísque virtútibus, non scandalizári quisque pótuit, \
sed admirári. Sed infidélium mens grave in illo scándalum pértulit, cum \
eum post tot mirácula moriéntem vidit. Unde et Paulus dicit: Nos autem \
prædicámus Christum crucifíxum, Judǽis quidem scándalum, géntibus autem \
stultítiam. Stultum quippe homínibus visum est, ut pro homínibus Auctor \
vitæ morerétur: et inde contra eum homo scándalum sumpsit, unde ei \
ámplius débitor fíeri débuit. Nam tanto Deus ab homínibus dígnius \
honorándus est, quanto pro homínibus et indígna suscépit.")  ; L7

        (:text "\
Quid est ergo dicere: Beátus qui non fúerit scandalizátus in me; nisi \
apérta voce abjectiónem mortis suæ humilitátemque signare? Ac si patenter \
dicat: Mira quidem facio, sed abjecta pérpeti non dedignor. Quia ergo \
moriéndo te súbsequor, cavéndum valde est homínibus, ne in me mortem \
despíciant, qui signa venerántur.")  ; L8

        (:text "\
Sed dimissis Joánnis discípulis, quid de eodem Joánne turbis dicat, \
audiámus: Quid exístis in desértum vidére? Arúndinem vento agitatam? \
Quod videlicet non asseréndo, sed negando intulit. Arúndinem quippe mox \
ut aura contígerit, in partem álteram inflectit. Et quid per arúndinem, \
nisi carnalis animus designátur? Qui mox ut favore vel detractióne \
tangitur, statim in partem quámlibet inclinátur?")  ; L9
        )

        :responsories
        (
        (:respond "Jerúsalem, cito véniet salus tua: Quare mœróre consúmeris? numquid consiliárius non est tibi, quia innovávit te dolor? * Salvábo te, et liberábo te, noli timére." :verse "Ego enim sum Dóminus, Deus tuus, Sanctus Israël, Redémptor tuus." :repeat "Salvábo te, et liberábo te, noli timére.")  ; R1

        (:respond "Ecce Dóminus véniet, et omnes Sancti ejus cum eo, et erit in die illa lux magna: et exíbunt de Jerúsalem sicut aqua munda: et regnábit Dóminus in ætérnum * Super omnes gentes." :verse "Ecce Dóminus cum virtúte véniet: et regnum in manu ejus, et potéstas, et impérium." :repeat "Super omnes gentes.")  ; R2

        (:respond "Cívitas Jerúsalem, noli flere: quóniam dóluit Dóminus super te: * Et áuferet a te omnem tribulatiónem." :verse "Ecce Dóminus in fortitúdine véniet: et brácchium ejus dominábitur." :repeat "Et áuferet a te omnem tribulatiónem.")  ; R3

        (:respond "Ecce véniet Dóminus, protéctor noster, Sanctus Israël, * Corónam regni habens in cápite suo." :verse "Et dominábitur a mari usque ad mare, et a flúmine usque ad términos orbis terrárum." :repeat "Corónam regni habens in cápite suo.")  ; R4

        (:respond "Sicut mater consolátur fílios suos, ita consolábor vos, dicit Dóminus: et de Jerúsalem civitáte quam elégi, véniet vobis auxílium: * Et vidébitis et gaudébit cor vestrum." :verse "Dabo in Sion salútem, et in Jerúsalem glóriam meam." :repeat "Et vidébitis et gaudébit cor vestrum.")  ; R5

        (:respond "Jerúsalem, plantábis víneam in móntibus tuis: exsultábis, quóniam dies Dómini véniet: surge, Sion, convértere ad Dóminum Deum tuum: gaude et lætáre, Jacob: * Quia de médio géntium Salvátor tuus véniet." :verse "Exsúlta satis, fília Sion: júbila, fília Jerúsalem." :repeat "Quia de médio géntium Salvátor tuus véniet.")  ; R6

        (:respond "Egrediétur Dóminus de Samaría ad portam, quæ réspicit ad Oriéntem: et véniet in Béthlehem ámbulans super aquas redemptiónis Judæ: * Tunc salvus erit omnis homo: quia ecce véniet." :verse "Et præparábitur in misericórdia sólium ejus, et sedébit super illud in veritáte." :repeat "Tunc salvus erit omnis homo: quia ecce véniet.")  ; R7

        (:respond "Festína, ne tardáveris, Dómine: * Et líbera pópulum tuum." :verse "Veni, Dómine, et noli tardáre: reláxa facínora plebi tuæ." :repeat "Et líbera pópulum tuum.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  veni-domine-visitare-nos
        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (ecce-in-nubibus-caeli
                          urbs-fortitudinis-nostrae
                          ecce-apparebit-dominus
                          montes-et-colles-cantabunt
                          ecce-dominus-noster-cum)
        :benedictus-antiphon  joannes-autem-cum-audisset
        :lauds-capitulum      quaecumque-scripta-sunt
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       deus-autem-spei
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon tu-es-qui-venturus-es
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Advent 3 — Dominica III Adventus (DO: Adv3-0)
    ;; Scripture: Isaias 26; Patristic: St Leo, Sermo 2 de jejunio;
    ;; Homily: St Gregory, Hom. 7 in Evang. (John 1:19-28)
    ;; ════════════════════════════════════════════════════════════════════

    (3
     . (:lessons
        (
        (:ref "Isa 26:1-6" :source "De Isaía Prophéta" :text "\
In die illa cantábitur cánticum istud in terra Juda: Urbs fortitúdinis \
nostræ Sion Salvátor, ponétur in ea murus et antemurále. Apérite portas \
et ingrediátur gens justa, custódiens veritátem. Vetus error ábiit: \
servábis pacem: pacem, quia in te sperávimus. Sperástis in Dómino in \
sǽculis ætérnis, in Dómino Deo forti, in perpétuum. Quia incurvábit \
habitántes in excélso, civitátem sublímem humiliábit. Humiliábit eam \
usque ad terram, detráhet eam usque ad púlverem. Conculcábit eam pes, \
pedes páuperis, gressus egenórum.")  ; L1

        (:ref "Isa 26:7-10" :text "\
Sémita justi recta est, rectus callis justi ad ambulándum. Et in sémita \
judiciórum tuórum, Dómine, sustínuimus te: nomen tuum, et memoriále tuum \
in desidério ánimæ. Anima mea desiderávit te in nocte, sed et spíritu meo \
in præcórdiis meis de mane vigilábo ad te. Cum féceris judícia tua in \
terra, justítiam discent habitatóres orbis. Misereámur ímpio, et non \
discet justítiam: in terra sanctórum iníqua gessit, et non vidébit \
glóriam Dómini.")  ; L2

        (:ref "Isa 26:11-14" :text "\
Dómine, exaltétur manus tua, et non vídeant: vídeant, et confundántur \
zelántes pópuli: et ignis hostes tuos dévoret. Dómine, dabis pacem \
nobis: ómnia enim ópera nostra operátus es nobis. Dómine Deus noster, \
possedérunt nos dómini absque te, tantum in te recordémur nóminis tui. \
Moriéntes non vivant, gigántes non resúrgant: proptérea visitásti et \
contrivísti eos, et perdidísti omnem memóriam eórum.")  ; L3

        (:ref "Sermo 2 de jejunio decimi mensis" :source "Sermo sancti Leónis Papæ" :text "\
Quod témporis rátio, et devotiónis nostræ admónet consuetúdo, pastorali \
vobis, dilectíssimi, sollicitúdine prædicámus, décimi mensis celebrándum \
esse jejúnium, quo pro consummáta perceptióne ómnium frúctuum, digníssime \
largitóri eórum Deo continéntiæ libámen offértur. Quid enim potest \
efficácius esse jejúnio? cujus observántia appropinquámus Deo, et \
resisténtes diábolo, vítia blanda superámus.")  ; L4

        (:text "\
Semper enim virtúti cibus jejúnium fuit. De abstinéntia dénique pródeunt \
castæ cogitatiónes, rationábiles voluntátes, salubriora consília: et per \
voluntárias afflictiónes caro concupiscéntiis móritur, virtútibus spíritus \
innovátur. Sed quia non solo jejúnio animárum nostrárum salus acquíritur, \
jejúnium nostrum misericórdiis páuperum suppleámus. Impendámus virtúti, \
quod subtráhimus voluptáti. Fiat reféctio páuperis abstinéntia \
jejunántis.")  ; L5

        (:text "\
Studeámus viduárum defensióni, pupillórum utilitáti, lugéntium \
consolatióni, dissidéntium paci. Suscipiátur peregrínus, adjuvétur \
oppréssus, vestiátur nudus, foveátur ǽgrotus: ut quicúmque nostrum de \
justis labóribus auctóri bonórum ómnium Deo sacrifícium hujus pietátis \
obtúlerit, ab eódem regni cæléstis prǽmium percípere mereátur. Quarta \
ígitur et sexta Féria jejunémus; Sábbato autem apud beátum Petrum \
Apóstolum páriter vigilémus: cujus suffragántibus méritis, quæ \
póscimus, impetrare possímus per Dóminum nostrum Jesum Christum, qui \
cum Patre et Sancto Spíritu vivit et regnat in sǽcula sæculórum. Amen.")  ; L6

        (:ref "Joan 1:19-28" :source "Léctio sancti Evangélii secúndum Joánnem" :text "\
In illo témpore: Misérunt Judǽi ab Jerosólymis sacerdótes et levítas ad \
Joánnem, ut interrogárent eum: Tu quis es? Et réliqua.\n\
Homilía sancti Gregórii Papæ\n\
Ex hujus nobis lectiónis verbis, fratres caríssimi, Joánnis humílitas \
commendátur: qui cum tantæ virtútis esset, ut Christus credi potuísset, \
elégit sólide subsístere in se, ne humána opinióne raperétur ináníter \
super se. Nam conféssus est, et non negávit: et conféssus est, Quia non \
sum ego Christus. Sed qui dixit, Non sum; negávit plane quod non erat, \
sed non negávit quod erat: ut veritátem loquens, ejus membrum fíeret, \
cujus sibi nomen falláciter non usurpáret. Cum ergo non vult appétere \
nomen Christi, factus est membrum Christi: quia dum infirmitátem suam \
stúduit humíliter agnóscere, illíus celsitúdinem méruit veráciter \
obtinére.")  ; L7

        (:text "\
Sed cum ex lectióne ália, Redemptóris nostri senténtia ad mentem \
redúcitur, ex hujus lectiónis verbis nobis quǽstio valde impléxa \
generátur. Alio quippe in loco inquisítus a discípulis Dóminus de Elíæ \
advéntu, respóndit: Elías jam venit, et non cognovérunt eum, sed \
fecérunt in eum quæcúmque voluérunt: et, si vultis scire, Joánnes ipse \
est Elías. Requisítus autem Joánnes dicit: Non sum Elías. Quid est hoc, \
fratres caríssimi, quia quod Véritas affírmat, hoc prophéta Veritátis \
negat? Valde namque inter se divérsa sunt: Ipse est: et, Non sum. \
Quómodo ergo prophéta veritátis est, si ejúsdem Veritátis sermónibus \
concors non est?")  ; L8

        (:text "\
Sed si subtíliter véritas ipsa requirátur, hoc quod inter se contrárium \
sonat, quómodo contrárium non sit, invenítur. Ad Zacharíam namque de \
Joánne Angelus dicit: Ipse præcédet ante illum in spíritu et virtúte \
Elíæ. Qui idcírco ventúrus in spíritu et virtúte Elíæ dícitur, quia \
sicut Elías secúndum Dómini advéntum prævéniet, ita Joánnes prævénit \
primum. Sicut ille præcúrsor ventúrus est Júdicis, ita iste præcúrsor \
est factus Redemptóris. Joánnes ígitur in spíritu Elías erat, in \
persóna Elías non erat. Quod ergo Dóminus fatétur de spíritu, hoc \
Joánnes dénegat de persóna.")  ; L9
        )

        :responsories
        (
        (:respond "Ecce apparébit Dóminus super nubem cándidam, et cum eo Sanctórum míllia: et habébit in vestiménto, et in fémore suo scriptum: * Rex regum, et Dóminus dominántium." :verse "Apparébit in finem, et non mentiétur; si moram fécerit, exspécta eum, quia véniens véniet." :repeat "Rex regum, et Dóminus dominántium.")  ; R1

        (:respond "Béthlehem cívitas Dei summi, ex te exíet Dominátor Israël, et egréssus ejus sicut a princípio diérum æternitátis, et magnificábitur in médio univérsæ terræ: * Et pax erit in terra nostra, dum vénerit." :verse "Loquétur pacem in géntibus, et potéstas ejus a mari usque ad mare." :repeat "Et pax erit in terra nostra, dum vénerit.")  ; R2

        (:respond "Qui ventúrus est, véniet, et non tardábit: et jam non erit timor in fínibus nostris: * Quóniam ipse est Salvátor noster." :verse "Depónet omnes iniquitátes nostras, et proíciet in profúndum maris ómnia peccáta nostra." :repeat "Quóniam ipse est Salvátor noster.")  ; R3

        (:respond "Ægýpte, noli flere, quia Dominátor tuus véniet tibi, ante cujus conspéctum movebúntur abýssi, * Liberáre pópulum suum de manu poténtiæ." :verse "Ecce véniet Dóminus exercítuum, Deus tuus cum potestáte magna." :repeat "Liberáre pópulum suum de manu poténtiæ.")  ; R4

        (:respond "Prope est ut véniat tempus ejus, et dies ejus non elongabúntur: miserébitur Dóminus Jacob, * Et Israël salvábitur." :verse "Revértere, virgo Israël, revértere ad civitátes tuas." :repeat "Et Israël salvábitur.")  ; R5

        (:respond "Descéndet Dóminus sicut plúvia in vellus: oriétur in diébus ejus justítia, * Et abundántia pacis." :verse "Et adorábunt eum omnes reges, omnes gentes sérvient ei." :repeat "Et abundántia pacis.")  ; R6

        (:respond "Veni, Dómine, et noli tardáre: reláxa facínora plebi tuæ, * Et révoca dispérsos in terram suam." :verse "Excita, Dómine, poténtiam tuam, et veni, ut salvos fácias nos." :repeat "Et révoca dispérsos in terram suam.")  ; R7

        (:respond "Ecce radix Jesse descéndet in salútem populórum, ipsum gentes deprecabúntur: * Et erit nomen ejus gloriósum." :verse "Dabit ei Dóminus Deus sedem David, patris ejus, et regnábit in domo Jacob in ætérnum." :repeat "Et erit nomen ejus gloriósum.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  ante-me-non-est-formatus
        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (veniet-dominus-et-non
                          jerusalem-gaude-gaudio
                          dabo-in-sion-salutem
                          montes-et-omnes-colles
                          juste-et-pie-vivamus)
        :benedictus-antiphon  super-solium-david
        :lauds-capitulum      gaudete-in-domino-semper
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       et-pax-dei-quae-exsuperat
        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon beata-es-maria-quae-credidisti
        ))


    ;; ════════════════════════════════════════════════════════════════════
    ;; Advent 4 — Dominica IV Adventus (DO: Adv4-0)
    ;; Scripture: Isaias 35, 41; Patristic: St Leo, Sermo 1 de jejunio;
    ;; Homily: St Gregory, Hom. 20 in Evang. (Luke 3:1-6)
    ;; ════════════════════════════════════════════════════════════════════

    (4
     . (:lessons
        (
        (:ref "Isa 35:1-7" :source "De Isaía Prophéta" :text "\
Lætábitur desérta et ínvia, et exsultábit solitúdo, et florébit quasi \
lílium. Gérminans germinábit, et exsultábit lætabúnda et laudans: glória \
Líbani data est ei: decor Carméli et Saron, ipsi vidébunt glóriam \
Dómini, et decórem Dei nostri. Confortáte manus dissolútas, et génua \
debília roboráte. Dícite pusillánimis: Confortámini, et nolíte timére: \
ecce Deus vester ultiónem addúcet retributiónis: Deus ipse véniet, et \
salvábit vos. Tunc aperiéntur óculi cæcórum, et aures surdórum patébunt. \
Tunc sáliet sicut cervus claudus, et apérta erit lingua mutórum: quia \
scissæ sunt in desérto aquæ, et torréntes in solitúdine. Et quæ erat \
árida, erit in stagnum, et sítiens in fontes aquárum.")  ; L1

        (:ref "Isa 35:7-10" :text "\
In cubílibus, in quibus prius dracónes habitábant, oriétur viror cálami \
et junci. Et erit ibi sémita et via, et via sancta vocábitur: non \
transíbit per eam pollútus, et hæc erit vobis dirécta via, ita ut \
stulti non errent per eam. Non erit ibi leo, et mala béstia non \
ascéndet per eam, nec inveniétur ibi: et ambulábunt, qui liberáti \
fúerint. Et redémpti a Dómino converténtur, et vénient in Sion cum \
laude: et lætítia sempitérna super caput eórum: gáudium et lætítiam \
obtinébunt, et fúgiet dolor et gémitus.")  ; L2

        (:ref "Isa 41:1-4" :text "\
Táceant ad me ínsulæ, et gentes mutent fortitúdinem: accédant, et tunc \
loquántur, simul ad judícium propinquémus. Quis suscitávit ab Oriénte \
justum, vocávit eum ut sequerétur se? dabit in conspéctu ejus gentes \
et reges obtinébit: dabit quasi púlverem gládio ejus, sicut stípulam \
vento raptam árcui ejus. Persequétur eos, transíbit in pace, sémita in \
pédibus ejus non apparébit. Quis hæc operátus est, et fecit, vocans \
generatiónes ab exórdio? Ego Dóminus, primus et novíssimus ego sum.")  ; L3

        (:ref "Sermo 1 de jejunio decimi mensis" :source "Sermo sancti Leónis Papæ" :text "\
Si fidéliter, dilectíssimi, atque sapiénter creatiónis nostræ \
intelligámus exórdium, inveniémus hóminem ideo ad imáginem Dei cónditum, \
ut imitátor sui esset auctóris: et hanc esse naturálem nostri géneris \
dignitátem, si in nobis, quasi in quodam spéculo, divínæ benignitátis \
forma respléndeat. Ad quam quotídie nos útique réparat grátia Salvatóris, \
dum quod cécidit in Adam primo, erígitur in secúndo.")  ; L4

        (:text "\
Causa autem reparatiónis nostræ non est nisi misericórdia Dei: quem non \
diligéremus, nisi prius nos ipse dilígeret, et ténebras ignorántiæ \
nostræ, suæ veritátis luce discúteret. Quod per sanctum Isaíam Dóminus \
denúntians, ait: Addúcam cæcos in viam quam ignorábant, et sémitas quas \
nesciébant, fáciam illos calcáre: fáciam illis ténebras in lucem, et \
prava in dirécta. Hæc verba fáciam illis, et non relínquam eos. Et \
íterum: Invéntus sum, inquit, a non quæréntibus me, et palam appárui \
iis qui me non interrogábant.")  ; L5

        (:text "\
Quod quómodo implétum sit, Joánnes Apóstolus docet, dicens: Scimus \
quóniam Fílius Dei venit, et dedit nobis sensum, ut cognoscámus verum, \
et simus in vero Fílio ejus. Et íterum: Nos ergo diligámus Deum, \
quóniam ipse prior diléxit nos. Diligéndo ítaque nos Deus, ad imáginem \
suam nos réparat: et ut in nobis formam suæ bonitátis invéniat, dat \
unde ipsi quoque quod operátur operémur, accéndens scílicet méntium \
nostrárum lucérnas, et igne nos suæ caritátis inflámmas, ut non solum \
ipsum, sed étiam quidquid díligit, diligámus.")  ; L6

        (:ref "Luc 3:1-6" :source "Léctio sancti Evangélii secúndum Lucam" :text "\
Anno quintodécimo impérii Tibérii Cǽsaris, procuránte Póntio Piláto \
Judǽam. Et réliqua.\n\
De Homilía sancti Gregórii Papæ\n\
Dicébat Joánnes ad turbas, quæ exíbant ut baptizaréntur ab eo: Genímina \
viperárum, quis osténdit vobis fúgere a ventúra ira? Ventúra enim ira \
est animadvérsio ultiónis extrémæ: quam tunc fúgere peccátor non valet, \
qui nunc ad laménta pœniténtiæ non recúrrit. Et notándum, quod malæ \
sóboles, malórum paréntum actiónem imitántes, genímina viperárum \
vocántur: quia per hoc quod bonis invídent, eósque persequúntur, quod \
quibúsdam mala retríbuunt, quod læsiónes próximis exquírunt: quóniam in \
his ómnibus patrum suórum carnálium vias sequúntur, quasi venenáti fílii \
de venenátis paréntibus nati sunt.")  ; L7

        (:text "\
Sed quia jam peccávimus, quia usu malæ consuetúdinis involúti sumus: \
dicat quid nobis faciéndum sit, ut fúgere a ventúra ira valeámus. \
Séquitur: Fácite ergo fructus dignos pœniténtiæ. In quibus verbis \
notándum est, quod amícus Sponsi non solum fructus pœniténtiæ, sed \
dignos pœniténtiæ admónet esse faciéndos. Aliud namque est fructum \
fácere pœniténtiæ, áliud, dignum pœniténtiæ fructum fácere. Ut enim \
secúndum dignos pœniténtiæ fructus loquámur, sciéndum est, quia \
quisquis illícita nulla commísit, huic jure concéditur, ut lícitis \
utátur: sicque pietátis ópera fáciat, ut tamen si volúerit, ea quæ \
mundi sunt, non relínquat.")  ; L8

        (:text "\
At si quis in fornicatiónis culpam, vel fortásse, quod est grávius, in \
adultérium lapsus est: tanto a se lícita debet abscíndere, quanto se \
méminit et illícita perpetrásse. Neque enim par fructus boni óperis esse \
debet, ejus qui minus, et ejus qui ámplius delíquit: aut ejus qui in \
nullis, et ejus qui in quibúsdam facínoribus cécidit, et ejus qui in \
multis est lapsus. Per hoc ergo quod dícitur: Fácite fructus dignos \
pœniténtiæ: uniuscujúsque consciéntia convenítur, ut tanto majóra \
acquírat bonórum óperum lucra per pœniténtiam, quanto gravióra sibi \
íntulit damna per culpam.")  ; L9
        )

        :responsories
        (
        (:respond "Cánite tuba in Sion, vocáte gentes, annuntiáte pópulis, et dícite: * Ecce Deus Salvátor noster advéniet." :verse "Annuntiáte, et audítum fácite: loquímini, et clamáte." :repeat "Ecce Deus Salvátor noster advéniet.")  ; R1

        (:respond "Non auferétur sceptrum de Juda, et dux de fémore ejus, donec véniat qui mitténdus est: * Et ipse erit exspectátio géntium." :verse "Pulchrióres sunt óculi ejus vino, et dentes ejus lacte candidióres." :repeat "Et ipse erit exspectátio géntium.")  ; R2

        (:respond "Me opórtet mínui, illum autem créscere: qui autem post me venit, ante me factus est: * Cujus non sum dignus corrígiam calceamentórum sólvere." :verse "Ego baptizávi vos aqua: ille autem baptizábit vos Spíritu Sancto." :repeat "Cujus non sum dignus corrígiam calceamentórum sólvere.")  ; R3

        (:respond "Nascétur nobis párvulus, et vocábitur Deus, Fortis: ipse sedébit super thronum David patris sui, et imperábit: * Cujus potéstas super húmerum ejus." :verse "In ipso benedicéntur omnes tribus terræ, omnes gentes sérvient ei." :repeat "Cujus potéstas super húmerum ejus.")  ; R4

        (:respond "Ecce jam venit plenitúdo témporis, in quo misit Deus Fílium suum in terras, natum de Vírgine, factum sub lege: * Ut eos, qui sub lege erant, redímeret." :verse "Propter nímiam caritátem suam, qua diléxit nos Deus, Fílium suum misit in similitúdinem carnis peccáti." :repeat "Ut eos, qui sub lege erant, redímeret.")  ; R5

        (:respond "Virgo Israël, revértere ad civitátes tuas: úsquequo dolens avérteris? generábis Dóminum Salvatórem, oblatiónem novam in terra: * Ambulábunt hómines in salvatiónem." :verse "In caritáte perpétua diléxi te: ídeo attráxi te míserans tui." :repeat "Ambulábunt hómines in salvatiónem.")  ; R6

        (:respond "Jurávi, dicit Dóminus, ut ultra jam non iráscar super terram: montes enim et colles suscípient justítiam meam, * Et testaméntum pacis erit in Jerúsalem." :verse "Juxta est salus mea, ut véniat: et justítia mea, ut revelétur." :repeat "Et testaméntum pacis erit in Jerúsalem.")  ; R7

        (:respond "Non discédimus a te, vivificábis nos, Dómine, et nomen tuum invocábimus: osténde nobis fáciem tuam, * Et salvi érimus." :verse "Meménto nostri, Dómine, in beneplácito pópuli tui: vísita nos in salutári tuo." :repeat "Et salvi érimus.")  ; R8
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        ;; No fixed Magnificat antiphon — O Antiphons (Dec 17-23) are date-keyed
        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (canite-tuba-in-sion
                          ecce-veniet-desideratus
                          erunt-prava-in-directa
                          dominus-veniet-occurrite
                          omnipotens-sermo-tuus)
        :benedictus-antiphon  ave-maria-gratia-plena
        :lauds-capitulum      sic-nos-existimet-homo
        ;; ── None ───────────────────────────────────────────────────
        :none-capitulum       itaque-nolite-ante-tempus
        ;; ── Vespers II ─────────────────────────────────────────────
        ;; No fixed Magnificat antiphon — O Antiphons (Dec 17-23) are date-keyed
        ))

    )
  "Advent dominical data alist.
Each entry: (WEEK-NUMBER . PLIST).
Week numbers 1–4 correspond to Advent Sundays I–IV.

Matins keys:
  :lessons       — list of 9 plists (:ref :source :text)
  :responsories  — list of 8 plists (:respond :verse :repeat)

Non-Matins keys (antiphonary/capitulary symbols):
  :magnificat-antiphon  — Vespers I Magnificat antiphon (antiphonary symbol)
  :benedictus-antiphon  — Lauds Benedictus antiphon (antiphonary symbol)
  :magnificat2-antiphon — Vespers II Magnificat antiphon (antiphonary symbol)
  :lauds-antiphons      — list of 5 antiphonary symbols
  :lauds-capitulum      — capitulary symbol
  :none-capitulum       — capitulary symbol

Advent 4 omits :magnificat-antiphon and :magnificat2-antiphon because
the O Antiphons (Dec 17-23) are date-keyed, not Sunday-keyed.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-season-advent-collect (date)
  "Return the collect incipit symbol for the Advent Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns nil outside Advent."
  (let ((n (bcp-roman-season-advent--sunday-number date)))
    (when (and n (<= n (1- (length bcp-roman-season-advent--collects))))
      (aref bcp-roman-season-advent--collects n))))

(defun bcp-roman-season-advent-dominical-matins (date)
  "Return dominical Matins data for the Advent Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories,
or nil outside Advent."
  (let ((n (bcp-roman-season-advent--sunday-number date)))
    (when n
      (cdr (assq n bcp-roman-season-advent--dominical-matins)))))

(defun bcp-roman-season-advent-dominical-hours (date)
  "Return non-Matins hour data for the Advent Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns the same plist as `dominical-matins'
\(which contains both Matins and non-Matins keys), or nil outside Advent.
Non-Matins keys are optional; absent means use psalterium default."
  (bcp-roman-season-advent-dominical-matins date))

(provide 'bcp-roman-season-advent)

;;; bcp-roman-season-advent.el ends here
