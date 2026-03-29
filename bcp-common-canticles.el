;;; bcp-common-canticles.el --- Liturgical canticle texts -*- lexical-binding: t -*-

;;; Commentary:

;; A language-agnostic library of liturgical canticle texts for the
;; BCP — Biblical Commentary and Prayer project.  Contains no references
;; to any specific prayer book edition or ordo.
;;
;; Canticles are indexed by canonical symbol and language.  Stored text
;; is primary — liturgical texts have specific pointing (colons for mediants,
;; asterisks for flexes) that prose Bible fetches cannot reproduce.
;;
;; Pointing conventions (BCP/Sarum):
;;   :   mediant (half-verse division)
;;   *   flex (short verse, additional pause before mediant)
;;
;; User configuration:
;;   `bcp-liturgy-canticle-language'        — default language ('english or 'latin)
;;   `bcp-liturgy-canticle-overrides'       — per-canticle language overrides
;;   `bcp-liturgy-canticle-append-gloria'   — append Gloria Patri after canticles
;;                                    (default nil for private recitation)
;;
;; Latin texts that are nil fall back to English automatically.

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-liturgy-canticles nil
  "Liturgical canticle texts."
  :prefix "bcp-liturgy-canticle-"
  :group 'text)

(defcustom bcp-liturgy-canticle-language 'english
  "Default language for canticles.  `english' or `latin'."
  :type  '(choice (const english) (const latin))
  :group 'bcp-liturgy-canticles)

(defcustom bcp-liturgy-canticle-overrides nil
  "Alist of (CANTICLE-SYMBOL . LANGUAGE) per-canticle language overrides.
Takes precedence over `bcp-liturgy-canticle-language'.

Example: \\='((te-deum . latin) (venite . english))"
  :type  '(alist :key-type symbol :value-type symbol)
  :group 'bcp-liturgy-canticles)

(defcustom bcp-liturgy-canticle-append-gloria nil
  "Whether to append Gloria Patri after each canticle and psalm.
Disabled by default for private recitation.
When enabled the renderer appends Gloria Patri after every canticle
except Te Deum, and after every psalm.
Passiontide suppression is the responsibility of the ordo or renderer."
  :type  'boolean
  :group 'bcp-liturgy-canticles)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Gloria Patri

(defconst bcp-liturgy-canticle-gloria-patri-english
  "Glory be to the Father, and to the Son : and to the Holy Ghost;\n\
   As it was in the beginning, is now, and ever shall be : world without end.  Amen."
  "Gloria Patri in English (BCP pointing).")

(defconst bcp-liturgy-canticle-gloria-patri-latin
  "Glória Patri, et Fílio, * et Spirítui Sancto.\n\
   Sicut erat in princípio, et nunc, et semper, * et in sǽcula sæculórum. Amen."
  "Gloria Patri in Latin (Clementine Vulgate).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Canticle texts

(defconst bcp-liturgy-canticle-texts
  '(
    ;;──── Venite ─────────────────────────────────────────────────────────────

    (venite
     :title   "Venite, exultemus Domino"
     :source  "Psalm 95"
     :gloria  t
     :english "O COME, let us sing unto the Lord : \
let us heartily rejoice in the strength of our salvation.\n\
   Let us come before his presence with thanksgiving : \
and shew ourselves glad in him with Psalms.\n\
   For the Lord is a great God : \
and a great King above all gods.\n\
   In his hand are all the corners of the earth : \
and the strength of the hills is his also.\n\
   The sea is his, and he made it : \
and his hands prepared the dry land.\n\
   O come, let us worship and fall down : \
and kneel before the Lord our Maker.\n\
   For he is the Lord our God : \
and we are the people of his pasture, and the sheep of his hand.\n\
   To day if ye will hear his voice, harden not your hearts : \
as in the provocation, and as in the day of temptation in the wilderness;\n\
   When your fathers tempted me : proved me, and saw my works.\n\
   Forty years long was I grieved with this generation, and said : \
It is a people that do err in their hearts, for they have not known my ways.\n\
   Unto whom I sware in my wrath : \
that they should not enter into my rest."
     :latin   "VENÍTE, exsultémus Dómino: * jubilémus Deo salutári nostro.\n\
   Præoccupémus fáciem ejus in confessióne: * et in psalmis jubilémus ei.\n\
   Quóniam Deus magnus Dóminus: * et Rex magnus super omnes deos.\n\
   Quia in manu ejus sunt omnes fines terræ: * et altitúdines móntium ipsíus sunt.\n\
   Quóniam ipsíus est mare, et ipse fecit illud: * \
et siccam manus ejus formavérunt.\n\
   Veníte, adorémus, et procidámus ante Deum: * \
plorémus coram Dómino, qui fecit nos.\n\
   Quia ipse est Dóminus Deus noster: * \
nos autem pópulus páscuæ ejus, et oves manus ejus.\n\
   Hódie si vocem ejus audiéritis, nolíte obduráre corda vestra: * \
sicut in irritatióne secúndum diem tentatiónis in desérto;\n\
   Ubi tentavérunt me patres vestri, * \
probavérunt me, et vidérunt ópera mea.\n\
   Quadragínta annis offénsus fui generatióni illi, * \
et dixi: Semper hi errant corde.\n\
   Et isti non cognovérunt vias meas, ut jurávi in ira mea: * \
Si introíbunt in réquiem meam.")

    ;;──── Te Deum ────────────────────────────────────────────────────────────

    (te-deum
     :title   "Te Deum Laudamus"
     :source  "Patristic hymn (attr. Niceta of Remesiana, c. 400)"
     :gloria  nil
     :english "WE praise thee, O God : we acknowledge thee to be the Lord.\n\
   All the earth doth worship thee : the Father everlasting.\n\
   To thee all Angels cry aloud : the Heavens, and all the Powers therein.\n\
   To thee Cherubin and Seraphin : continually do cry,\n\
   Holy, Holy, Holy : Lord God of Sabaoth;\n\
   Heaven and earth are full of the Majesty : of thy glory.\n\
   The glorious company of the Apostles : praise thee.\n\
   The goodly fellowship of the Prophets : praise thee.\n\
   The noble army of Martyrs : praise thee.\n\
   The holy Church throughout all the world : doth acknowledge thee;\n\
   The Father : of an infinite Majesty;\n\
   Thine honourable, true : and only Son;\n\
   Also the Holy Ghost : the Comforter.\n\
   Thou art the King of Glory : O Christ.\n\
   Thou art the everlasting Son : of the Father.\n\
   When thou tookest upon thee to deliver man : \
thou didst not abhor the Virgin's womb.\n\
   When thou hadst overcome the sharpness of death : \
thou didst open the Kingdom of Heaven to all believers.\n\
   Thou sittest at the right hand of God : in the glory of the Father.\n\
   We believe that thou shalt come : to be our Judge.\n\
   We therefore pray thee, help thy servants : \
whom thou hast redeemed with thy precious blood.\n\
   Make them to be numbered with thy Saints : in glory everlasting.\n\
   O Lord, save thy people : and bless thine heritage.\n\
   Govern them : and lift them up for ever.\n\
   Day by day : we magnify thee;\n\
   And we worship thy Name : ever world without end.\n\
   Vouchsafe, O Lord : to keep us this day without sin.\n\
   O Lord, have mercy upon us : have mercy upon us.\n\
   O Lord, let thy mercy lighten upon us : as our trust is in thee.\n\
   O Lord, in thee have I trusted : let me never be confounded."
     :latin   "TE Deum laudámus: * te Dóminum confitémur.\n\
   Te ætérnum Patrem * omnis terra venerátur.\n\
   Tibi omnes Ángeli, * tibi Cæli, et univérsæ Potestátes:\n\
   Tibi Chérubim et Séraphim * incessábili voce proclámant:\n\
   Sanctus, Sanctus, Sanctus * Dóminus Deus Sábaoth.\n\
   Pleni sunt cæli et terra * majestátis glóriæ tuæ.\n\
   Te gloriósus * Apostolórum chorus,\n\
   Te Prophetárum * laudábilis númerus,\n\
   Te Mártyrum candidátus * laudat exércitus.\n\
   Te per orbem terrárum * sancta confitétur Ecclésia,\n\
   Patrem * imménsæ majestátis;\n\
   Venerándum tuum verum * et únicum Fílium;\n\
   Sanctum quoque * Paráclitum Spíritum.\n\
   Tu Rex glóriæ, * Christe.\n\
   Tu Patris * sempitérnus es Fílius.\n\
   Tu, ad liberándum susceptúrus hóminem: * \
non horruísti Vírginis úterum.\n\
   Tu, devícto mortis acúleo, * \
aperuísti credéntibus regna cælórum.\n\
   Tu ad déxteram Dei sedes, * in glória Patris.\n\
   Judex créderis * esse ventúrus.\n\
   Te ergo quǽsumus, tuis fámulis súbveni, * \
quos pretióso sánguine redemísti.\n\
   Ætérna fac cum Sanctis tuis * in glória numerári.\n\
   Salvum fac pópulum tuum, Dómine, * et bénedic hereditáti tuæ.\n\
   Et rege eos, * et extólle illos usque in ætérnum.\n\
   Per síngulos dies * benedícimus te.\n\
   Et laudámus nomen tuum in sǽculum, * et in sǽculum sǽculi.\n\
   Dignáre, Dómine, die isto * sine peccáto nos custodíre.\n\
   Miserére nostri, Dómine, * miserére nostri.\n\
   Fiat misericórdia tua, Dómine, super nos, * \
quemádmodum sperávimus in te.\n\
   In te, Dómine, sperávi: * non confúndar in ætérnum.")

    ;;──── Benedicite ─────────────────────────────────────────────────────────

    (benedicite
     :title   "Benedicite, omnia opera"
     :source  "Song of the Three Young Men (Apocrypha)"
     :gloria  t
     :english "O ALL ye Works of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Angels of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Heavens, bless ye the Lord : praise him, and magnify him for ever.\n\
   O ye Waters that be above the firmament, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O all ye Powers of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Sun and Moon, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Stars of heaven, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Showers and Dew, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Winds of God, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Fire and Heat, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Winter and Summer, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Dews and Frosts, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Frost and Cold, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Ice and Snow, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Nights and Days, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Light and Darkness, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Lightnings and Clouds, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O let the Earth bless the Lord : \
yea, let it praise him, and magnify him for ever.\n\
   O ye Mountains and Hills, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O all ye Green Things upon the earth, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Wells, bless ye the Lord : praise him, and magnify him for ever.\n\
   O ye Seas and Floods, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Whales, and all that move in the waters, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O all ye Fowls of the air, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O all ye Beasts and Cattle, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Children of Men, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O let Israel bless the Lord : praise him, and magnify him for ever.\n\
   O ye Priests of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Servants of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Spirits and Souls of the Righteous, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye holy and humble Men of heart, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O Ananias, Azarias, and Misael, bless ye the Lord : \
praise him, and magnify him for ever."
     :latin   "BENEDÍCITE, ómnia ópera Dómini, Dómino: * \
laudáte et superexaltáte eum in sǽcula.\n\
   Benedícite, Ángeli Dómini, Dómino: * benedícite, cæli, Dómino.\n\
   Benedícite, aquæ omnes, quæ super cælos sunt, Dómino: * \
benedícite, omnes virtútes Dómini, Dómino.\n\
   Benedícite, sol et luna, Dómino: * benedícite, stellæ cæli, Dómino.\n\
   Benedícite, omnis imber et ros, Dómino: * \
benedícite, omnes spíritus Dei, Dómino.\n\
   Benedícite, ignis et æstus, Dómino: * \
benedícite, frigus et æstus, Dómino.\n\
   Benedícite, rores et pruína, Dómino: * \
benedícite, gelu et frigus, Dómino.\n\
   Benedícite, glácies et nives, Dómino: * \
benedícite, noctes et dies, Dómino.\n\
   Benedícite, lux et ténebræ, Dómino: * \
benedícite, fúlgura et nubes, Dómino.\n\
   Benedícat terra Dóminum: * laudet et superexáltet eum in sǽcula.\n\
   Benedícite, montes et colles, Dómino: * \
benedícite, univérsa germinántia in terra, Dómino.\n\
   Benedícite, fontes, Dómino: * benedícite, mária et flúmina, Dómino.\n\
   Benedícite, cete, et ómnia, quæ movéntur in aquis, Dómino: * \
benedícite, omnes vólucres cæli, Dómino.\n\
   Benedícite, omnes béstiæ et pécora, Dómino: * \
benedícite, fílii hóminum, Dómino.\n\
   Benedícat Israël Dóminum: * laudet et superexáltet eum in sǽcula.\n\
   Benedícite, sacerdótes Dómini, Dómino: * \
benedícite, servi Dómini, Dómino.\n\
   Benedícite, spíritus, et ánimæ justórum, Dómino: * \
benedícite, sancti, et húmiles corde, Dómino.\n\
   Benedícite, Ananía, Azaría, Mísaël, Dómino: * \
laudáte et superexaltáte eum in sǽcula.")

    ;;──── Benedictus ─────────────────────────────────────────────────────────

    (benedictus
     :title   "Benedictus"
     :source  "Luke 1:68-79"
     :gloria  t
     :english "BLESSED be the Lord God of Israel : \
for he hath visited and redeemed his people;\n\
   And hath raised up a mighty salvation for us : \
in the house of his servant David;\n\
   As he spake by the mouth of his holy Prophets : \
which have been since the world began;\n\
   That we should be saved from our enemies : \
and from the hand of all that hate us.\n\
   To perform the mercy promised to our forefathers : \
and to remember his holy Covenant;\n\
   To perform the oath which he sware to our forefather Abraham : \
that he would give us;\n\
   That we being delivered out of the hand of our enemies : \
might serve him without fear;\n\
   In holiness and righteousness before him : all the days of our life.\n\
   And thou, Child, shalt be called the Prophet of the Highest : \
for thou shalt go before the face of the Lord to prepare his ways;\n\
   To give knowledge of salvation unto his people : \
for the remission of their sins,\n\
   Through the tender mercy of our God : \
whereby the day-spring from on high hath visited us;\n\
   To give light to them that sit in darkness, and in the shadow of death : \
and to guide our feet into the way of peace."
     :latin   "BENEDÍCTUS Dóminus, Deus Israël: * \
quia visitávit, et fecit redemptiónem plebis suæ.\n\
   Et eréxit cornu salútis nobis: * in domo David, púeri sui.\n\
   Sicut locútus est per os sanctórum, * \
qui a sǽculo sunt, prophetárum ejus:\n\
   Salútem ex inimícis nostris, * et de manu ómnium, qui odérunt nos.\n\
   Ad faciéndam misericórdiam cum pátribus nostris: * \
et memorári testaménti sui sancti.\n\
   Jusjurándum, quod jurávit ad Ábraham patrem nostrum, * \
datúrum se nobis:\n\
   Ut sine timóre, de manu inimicórum nostrórum liberáti, * \
serviámus illi.\n\
   In sanctitáte, et justítia coram ipso, * ómnibus diébus nostris.\n\
   Et tu, puer, Prophéta Altíssimi vocáberis: * \
præíbis enim ante fáciem Dómini, paráre vias ejus:\n\
   Ad dandam sciéntiam salútis plebi ejus: * \
in remissiónem peccatórum eórum:\n\
   Per víscera misericórdiæ Dei nostri: * \
in quibus visitávit nos, óriens ex alto:\n\
   Illumináre his, qui in ténebris, et in umbra mortis sedent: * \
ad dirigéndos pedes nostros in viam pacis.")

    ;;──── Jubilate Deo ───────────────────────────────────────────────────────

    (jubilate-deo
     :title   "Jubilate Deo"
     :source  "Psalm 100"
     :gloria  t
     :english "O BE joyful in the Lord, all ye lands : \
serve the Lord with gladness, and come before his presence with a song.\n\
   Be ye sure that the Lord he is God; it is he that hath made us, \
and not we ourselves : we are his people, and the sheep of his pasture.\n\
   O go your way into his gates with thanksgiving, and into his courts with praise : \
be thankful unto him, and speak good of his Name.\n\
   For the Lord is gracious, his mercy is everlasting : \
and his truth endureth from generation to generation."
     :latin   "JUBILÁTE Deo, omnis terra: * servíte Dómino in lætítia.\n\
   Introíte in conspéctu ejus, * in exsultatióne.\n\
   Scitóte quóniam Dóminus ipse est Deus: * ipse fecit nos, et non ipsi nos.\n\
   Pópulus ejus, et oves páscuæ ejus: ‡ introíte portas ejus in confessióne, * \
átria ejus in hymnis: confitémini illi.\n\
   Laudáte nomen ejus: quóniam suávis est Dóminus, † \
in ætérnum misericórdia ejus, * \
et usque in generatiónem et generatiónem véritas ejus.")

    ;;──── Magnificat ─────────────────────────────────────────────────────────

    (magnificat
     :title   "Magnificat"
     :source  "Luke 1:46-55"
     :gloria  t
     :english "MY soul doth magnify the Lord : \
and my spirit hath rejoiced in God my Saviour.\n\
   For he hath regarded : the lowliness of his handmaiden.\n\
   For behold, from henceforth : all generations shall call me blessed.\n\
   For he that is mighty hath magnified me : and holy is his Name.\n\
   And his mercy is on them that fear him : throughout all generations.\n\
   He hath showed strength with his arm : \
he hath scattered the proud in the imagination of their hearts.\n\
   He hath put down the mighty from their seat : \
and hath exalted the humble and meek.\n\
   He hath filled the hungry with good things : \
and the rich he hath sent empty away.\n\
   He remembering his mercy hath holpen his servant Israel : \
as he promised to our forefathers, Abraham and his seed, for ever."
     :latin   "MAGNÍFICAT * ánima mea Dóminum.\n\
   Et exsultávit spíritus meus: * in Deo, salutári meo.\n\
   Quia respéxit humilitátem ancíllæ suæ: * \
ecce enim ex hoc beátam me dicent omnes generatiónes.\n\
   Quia fecit mihi magna qui potens est: * et sanctum nomen ejus.\n\
   Et misericórdia ejus, a progénie in progénies: * timéntibus eum.\n\
   Fecit poténtiam in brácchio suo: * dispérsit supérbos mente cordis sui.\n\
   Depósuit poténtes de sede: * et exaltávit húmiles.\n\
   Esuriéntes implévit bonis: * et dívites dimísit inánes.\n\
   Suscépit Israël púerum suum: * recordátus misericórdiæ suæ.\n\
   Sicut locútus est ad patres nostros: * \
Ábraham, et sémini ejus in sǽcula.")

    ;;──── Cantate Domino ─────────────────────────────────────────────────────

    (cantate-domino
     :title   "Cantate Domino"
     :source  "Psalm 98"
     :gloria  t
     :english "O SING unto the Lord a new song : for he hath done marvellous things.\n\
   With his own right hand, and with his holy arm : \
hath he gotten himself the victory.\n\
   The Lord declared his salvation : \
his righteousness hath he openly showed in the sight of the heathen.\n\
   He hath remembered his mercy and truth toward the house of Israel : \
and all the ends of the world have seen the salvation of our God.\n\
   Show yourselves joyful unto the Lord, all ye lands : \
sing, rejoice, and give thanks.\n\
   Praise the Lord upon the harp : sing to the harp with a psalm of thanksgiving.\n\
   With trumpets also and shawms : \
O shew yourselves joyful before the Lord the King.\n\
   Let the sea make a noise, and all that therein is : \
the round world, and that dwell therein.\n\
   Let the floods clap their hands, and let the hills be joyful together before the Lord : \
for he cometh to judge the earth.\n\
   With righteousness shall he judge the world : and the peoples with equity."
     :latin   "CANTÁTE Dómino cánticum novum: * quia mirabília fecit.\n\
   Salvávit sibi déxtera ejus: * et brácchium sanctum ejus.\n\
   Notum fecit Dóminus salutáre suum: * \
in conspéctu géntium revelávit justítiam suam.\n\
   Recordátus est misericórdiæ suæ, * et veritátis suæ dómui Israël.\n\
   Vidérunt omnes términi terræ * salutáre Dei nostri.\n\
   Jubiláte Deo, omnis terra: * cantáte, et exsultáte, et psállite.\n\
   Psállite Dómino in cíthara, in cíthara et voce psalmi: * \
in tubis ductílibus, et voce tubæ córneæ.\n\
   Jubiláte in conspéctu regis Dómini: * \
moveátur mare, et plenitúdo ejus: orbis terrárum, et qui hábitant in eo.\n\
   Flúmina plaudent manu, simul montes exsultábunt a conspéctu Dómini: * \
quóniam venit judicáre terram.\n\
   Judicábit orbem terrárum in justítia, * et pópulos in æquitáte.")

    ;;──── Nunc Dimittis ──────────────────────────────────────────────────────

    (nunc-dimittis
     :title   "Nunc Dimittis"
     :source  "Luke 2:29-32"
     :gloria  t
     :english "LORD, now lettest thou thy servant depart in peace : \
according to thy word.\n\
   For mine eyes have seen : thy salvation,\n\
   Which thou hast prepared : before the face of all people;\n\
   To be a light to lighten the Gentiles : \
and to be the glory of thy people Israel."
     :latin   "NUNC dimíttis servum tuum, Dómine, * secúndum verbum tuum in pace:\n\
   Quia vidérunt óculi mei * salutáre tuum,\n\
   Quod parásti * ante fáciem ómnium populórum,\n\
   Lumen ad revelatiónem géntium, * et glóriam plebis tuæ Israël.")

    ;;──── Deus Misereatur ────────────────────────────────────────────────────

    (deus-misereatur
     :title   "Deus Misereatur"
     :source  "Psalm 67"
     :gloria  t
     :english "GOD be merciful unto us, and bless us : \
and shew us the light of his countenance, and be merciful unto us;\n\
   That thy way may be known upon earth : \
thy saving health among all nations.\n\
   Let the peoples praise thee, O God : yea, let all the peoples praise thee.\n\
   O let the nations rejoice and be glad : \
for thou shalt judge the folk righteously, and govern the nations upon earth.\n\
   Let the people praise thee, O God : yea, let all the people praise thee.\n\
   Then shall the earth bring forth her increase : \
and God, even our own God, shall give us his blessing.\n\
   God shall bless us : and all the ends of the world shall fear him."
     :latin   "DEUS misereátur nostri, et benedícat nobis: * \
illúminet vultum suum super nos, et misereátur nostri.\n\
   Ut cognoscámus in terra viam tuam, * in ómnibus géntibus salutáre tuum.\n\
   Confiteántur tibi pópuli, Deus: * confiteántur tibi pópuli omnes.\n\
   Læténtur et exsúltent gentes: * \
quóniam júdicas pópulos in æquitáte, et gentes in terra dírigis.\n\
   Confiteántur tibi pópuli, Deus, confiteántur tibi pópuli omnes: * \
terra dedit fructum suum.\n\
   Benedícat nos Deus, Deus noster, benedícat nos Deus: * \
et métuant eum omnes fines terræ.")

    ;;──── Benedictus es Domine ───────────────────────────────────────────────

    (benedictus-es-domine
     :title   "Benedictus es, Domine"
     :source  "Song of the Three Young Men (Dan 3:52-56 Vulg.)"
     :gloria  t
     :english "BLESSED art thou, O Lord God of our fathers : \
praised and exalted above all for ever.\n\
   Blessed art thou for the Name of thy Majesty : \
praised and exalted above all for ever.\n\
   Blessed art thou in the temple of thy holiness : \
praised and exalted above all for ever.\n\
   Blessed art thou that beholdest the depths, and dwellest between the Cherubim : \
praised and exalted above all for ever.\n\
   Blessed art thou on the glorious throne of thy Kingdom : \
praised and exalted above all for ever.\n\
   Blessed art thou in the firmament of heaven : \
praised and exalted above all for ever."
     :latin   "BENEDÍCTUS es, Dómine, Deus patrum nostrórum: * \
et laudábilis, et gloriósus, et superexaltátus in sǽcula.\n\
   Et benedíctum nomen glóriæ tuæ sanctum: * \
et laudábile, et superexaltátum in ómnibus sǽculis.\n\
   Benedíctus es in templo sancto glóriæ tuæ: * \
et superlaudábilis, et supergloriósus in sǽcula.\n\
   Benedíctus es in throno regni tui: * \
et superlaudábilis, et superexaltátus in sǽcula.\n\
   Benedíctus es, qui intuéris abýssos, et sedes super Chérubim: * \
et laudábilis, et superexaltátus in sǽcula.\n\
   Benedíctus es in firmaménto cæli: * \
et laudábilis, et gloriósus in sǽcula.")

    ;;──── Gloria Patri ───────────────────────────────────────────────────────

    (gloria-patri
     :title   "Gloria Patri"
     :source  "Doxology"
     :gloria  nil
     :english "Glory be to the Father, and to the Son : and to the Holy Ghost;\n\
   As it was in the beginning, is now, and ever shall be : \
world without end.  Amen."
     :latin   "Glória Patri, et Fílio, * et Spirítui Sancto.\n\
   Sicut erat in princípio, et nunc, et semper, * \
et in sǽcula sæculórum. Amen."))

  "Alist of canticle data keyed by canonical symbol.
Each entry: (SYMBOL :title STRING :source STRING :gloria BOOL
                    :english VALUE :latin VALUE)

:gloria t means Gloria Patri should follow this canticle when
`bcp-liturgy-canticle-append-gloria' is non-nil.

Values are strings (stored pointed text) or nil (not yet supplied).
nil for a language falls back to English automatically.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Accessors

(defun bcp-liturgy-canticle-data (symbol)
  "Return the data plist for canticle SYMBOL, or nil."
  (cdr (assq symbol bcp-liturgy-canticle-texts)))

(defun bcp-liturgy-canticle-effective-language (symbol)
  "Return the effective language for canticle SYMBOL.
Checks `bcp-liturgy-canticle-overrides' first, then `bcp-liturgy-canticle-language'."
  (or (cdr (assq symbol bcp-liturgy-canticle-overrides))
      bcp-liturgy-canticle-language))

(defun bcp-liturgy-canticle-get (symbol &optional language)
  "Return the text for canticle SYMBOL in LANGUAGE.
LANGUAGE defaults to the effective language for SYMBOL.
Falls back to English if the requested language text is nil.
Returns a string or nil."
  (let* ((data (bcp-liturgy-canticle-data symbol))
         (lang (or language (bcp-liturgy-canticle-effective-language symbol)))
         ;; plist keys are keywords (:english, :latin) — convert symbol
         (key  (intern (format ":%s" lang)))
         (val  (plist-get data key)))
    (if (and (null val) (eq lang 'latin))
        (plist-get data :english)
      val)))

(defun bcp-liturgy-canticle-title (symbol)
  "Return the display title for canticle SYMBOL."
  (plist-get (bcp-liturgy-canticle-data symbol) :title))

(defun bcp-liturgy-canticle-source (symbol)
  "Return the scriptural or patristic source description for canticle SYMBOL."
  (plist-get (bcp-liturgy-canticle-data symbol) :source))

(defun bcp-liturgy-canticle-gloria-p (symbol)
  "Return non-nil if Gloria Patri should follow canticle SYMBOL."
  (plist-get (bcp-liturgy-canticle-data symbol) :gloria))

(defun bcp-liturgy-canticle-gloria-text (&optional language)
  "Return the Gloria Patri text in LANGUAGE (default: effective language)."
  (let ((lang (or language (bcp-liturgy-canticle-effective-language 'gloria-patri))))
    (or (plist-get (bcp-liturgy-canticle-data 'gloria-patri) (intern (format ":%s" lang)))
        (plist-get (bcp-liturgy-canticle-data 'gloria-patri) :english))))


(provide 'bcp-common-canticles)
;;; bcp-common-canticles.el ends here
