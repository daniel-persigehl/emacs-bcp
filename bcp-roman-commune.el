;;; bcp-roman-commune.el --- Commune Sanctorum for the Roman Breviary -*- lexical-binding: t -*-

;;; Commentary:

;; Commune Sanctorum (Common of the Saints) data for the Roman Breviary
;; under DA 1911 rubrics.  Each commune provides a complete Matins template
;; with invitatory, hymn, 9 psalm antiphons (3 per nocturn), 3 nocturn
;; versicle pairs, 9 lessons, and 8 responsories.
;;
;; The sanctorale is a three-tier override system:
;;   feast proper → commune → temporale
;; Most feasts are thin deltas from the commune — they override only the
;; lessons, or only the Nocturn III homily, while inheriting everything
;; else from the commune.
;;
;; The 8 base communes:
;;   C1  — Commune Apostolorum (Apostles)
;;   C2  — Commune Unius Martyris Pontificis (One Martyr, Bishop)
;;   C2a — Commune Unius Martyris (One Martyr, non-Bishop)
;;   C3  — Commune Plurimorum Martyrum (Many Martyrs)
;;   C4  — Commune Confessoris Pontificis (Confessor, Bishop)
;;   C5  — Commune Confessoris non Pontificis (Confessor, non-Bishop)
;;   C6  — Commune Virginis et Martyris (Virgin Martyr)
;;   C7  — Commune non Virginis (Holy Women, neither virgin nor martyr)
;;
;; Plist shape — Matins keys (unprefixed):
;;   :invitatory  SYMBOL  — antiphon incipit for invitatory
;;   :hymn        SYMBOL  — hymn incipit
;;   :psalms-1/2/3        — lists of (ANTIPHON . PSALM-NUMBER) for each nocturn
;;   :versicle-1/2/3      — 2-element list ("V." "R.") Latin
;;   :versicle-1/2/3-en   — 2-element list ("V." "R.") English
;;   :lessons             — list of 9 lesson plists (:ref :source :text)
;;   :responsories        — list of 8 responsory plists (:respond :verse :repeat :gloria)
;;
;; Non-Matins keys (hour-prefixed):
;;   :vespers-psalms      — 5 (ANTIPHON . PSALM) pairs for Vespers I
;;   :vespers-hymn        — hymn incipit
;;   :vespers-capitulum   — plist (:ref :text)
;;   :vespers-versicle    — 2-element list (Latin)
;;   :vespers-versicle-en — 2-element list (English)
;;   :magnificat-antiphon — Magnificat antiphon (Vespers I)
;;   :lauds-psalms        — 5 (ANTIPHON . PSALM) pairs for Lauds
;;   :lauds-hymn          — hymn incipit
;;   :lauds-capitulum     — plist (:ref :text)
;;   :lauds-versicle      — 2-element list
;;   :lauds-versicle-en   — 2-element list
;;   :benedictus-antiphon — Benedictus antiphon (Lauds)
;;   :prime-capitulum     — plist (:ref :text)
;;   :terce-responsory-breve — plist (:respond :repeat :verse)
;;   :sext-capitulum      — plist (:ref :text)
;;   :sext-responsory-breve  — plist (:respond :repeat :verse)
;;   :none-responsory-breve  — plist (:respond :repeat :verse)
;;   :vespers2-psalms     — 5 pairs for Vespers II (nil = same as I)
;;   :vespers2-versicle   — 2-element list (nil = reuse :lauds-versicle)
;;   :vespers2-versicle-en
;;   :magnificat2-antiphon — Magnificat antiphon (Vespers II)
;;
;; Omitted by rubric (derived at runtime):
;;   Terce capitulum = Lauds capitulum
;;   None capitulum  = Prime capitulum
;;   Vespers II hymn/capitulum = Vespers I
;;   Minor-hour psalms = "Psalmi Dominica" from psalterium
;;   Minor-hour antiphon = first Lauds antiphon ("Antiphonas horas")
;;
;; C2a inherits most data from C2 (same antiphons, hymn, psalms),
;; differing only in lessons 7-9.  C5 inherits from C4 (same antiphons,
;; psalms), differing in the nocturn versicles.  C7 inherits the
;; framework of C6 with different antiphons and lessons.
;;
;; Data extracted from Divinum Officium Latin Commune files.

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Commune data

(defconst bcp-roman-commune--data
  `(

    ;; ════════════════════════════════════════════════════════════════════
    ;; C1 — COMMUNE APOSTOLORUM
    ;; Psalms: 18/33/44, 46/60/63, 74/96/98
    ;; Invitatory: Regem Apostolorum Dominum
    ;; Hymn: Aeterna Christi munera (Apostolorum)
    ;; ════════════════════════════════════════════════════════════════════

    (C1
     . (:invitatory regem-apostolorum-dominum
        :hymn aeterna-christi-munera-apostolorum
        :psalms-1 ((in-omnem-terram-exivit . 18)
                   (clamaverunt-justi . 33)
                   (constitues-eos-principes . 44))
        :psalms-2 ((principes-populorum . 46)
                   (dedisti-hereditatem . 60)
                   (annuntiaverunt-opera-dei . 63))
        :psalms-3 ((exaltabuntur-cornua-justi . 74)
                   (lux-orta-est-justo . 96)
                   (custodiebant-testimonia . 98))
        :versicle-1 ("In omnem terram exívit sonus eórum."
                     "Et in fines orbis terræ verba eórum.")
        :versicle-1-en ("Their sound hath gone forth into all the earth."
                        "And their words unto the ends of the world.")
        :versicle-2 ("Constítues eos príncipes super omnem terram."
                     "Mémores erunt nóminis tui, Dómine.")
        :versicle-2-en ("Thou shalt make them princes over all the earth."
                        "They shall remember thy name, O Lord.")
        :versicle-3 ("Nimis honoráti sunt amíci tui, Deus."
                     "Nimis confortátus est principátus eórum.")
        :versicle-3-en ("Thy friends, O God, are made exceedingly honourable."
                        "Their principality is exceedingly strengthened.")

        :lessons
        (
         ;; ── Nocturn I: 1 Corinthians ──

         (:ref "1 Cor 4:1-5"
          :source "De Epístola prima beáti Pauli Apóstoli ad Corínthios"
          :text "\
Sic nos exístimet homo ut minístros Christi, et dispensatóres mysteriórum Dei. \
Hic jam quǽritur inter dispensatóres ut fidélis quis inveniátur. \
Mihi autem pro mínimo est ut a vobis júdicer, aut ab humáno die: sed neque meípsum júdico. \
Nihil enim mihi cónscius sum, sed non in hoc justificátus sum: qui autem júdicat me, Dóminus est. \
Ítaque nolíte ante tempus judicáre, quoadúsque véniat Dóminus: qui et illuminábit abscóndita tenebrárum, \
et manifestábit consília córdium: et tunc laus erit unicuíque a Deo.")

         (:ref "1 Cor 4:6-9"
          :text "\
Hæc autem, fratres, transfigurávi in me et Apóllo, propter vos: ut in nobis discátis, \
ne supra quam scriptum est, unus advérsus álterum inflétur pro álio. \
Quis enim te discérnit? Quid autem habes quod non accepísti? Si autem accepísti, quid gloriáris quasi non accéperis? \
Jam saturáti estis, jam dívites facti estis: sine nobis regnátis: et útinam regnétis, ut et nos vobíscum regnémus. \
Puto enim quod Deus nos Apóstolos novíssimos osténdit, tamquam morti destinátos: \
quia spectáculum facti sumus mundo, et Ángelis, et homínibus.")

         (:ref "1 Cor 4:10-15"
          :text "\
Nos stulti propter Christum, vos autem prudéntes in Christo: nos infírmi, vos autem fortes: \
vos nóbiles, nos autem ignóbiles. Usque in hanc horam et esurímus, et sitímus, et nudi sumus, \
et cólaphis cǽdimur, et instábiles sumus, et laborámus operántes mánibus nostris: \
maledícimur, et benedícimus: persecutiónem pátimur, et sustinémus: blasphemámur, et obsecrámus: \
tamquam purgaménta hujus mundi facti sumus, ómnium peripséma usque adhuc. \
Non ut confúndam vos, hæc scribo, sed ut fílios meos caríssimos móneo. \
Nam si decem míllia pædagogórum habeátis in Christo, sed non multos patres, \
nam in Christo Jesu per Evangélium ego vos génui.")

         ;; ── Nocturn II: St. Gregory (Homilia 30) ──

         (:ref "Hom. 30 in Evang."
          :source "Sermo sancti Gregórii Papæ"
          :text "\
Scriptum est: Spíritus Dómini ornávit cælos. Ornaménta enim cælórum sunt virtútes prædicántium. \
Quæ vidélicet ornaménta Paulus enúmerat, dicens: Álii datur per Spíritum sermo sapiéntiæ, \
álii sermo sciéntiæ secúndum eúndem Spíritum, álteri fides in eódem Spíritu, \
álii grátia sanitátum in uno Spíritu, álii operátio virtútum, álii prophetía, \
álii discrétio spirítuum, álii génera linguárum, álii interpretátio sermónum. \
Hæc autem ómnia operátur unus atque idem Spíritus, dívidens síngulis prout vult.")

         (:ref "Hom. 30 in Evang."
          :source "Sermo sancti Gregórii Papæ"
          :text "\
Quot ergo sunt bona prædicántium, tot sunt ornaménta cælórum. Hinc rursus scriptum est: \
Verbo Dómini cæli firmáti sunt. Verbum enim Dómini Fílius est Patris. \
Sed eósdem cælos, vidélicet sanctos Apóstolos, ut tota simul sancta Trínitas ostendátur operáta, \
repénte de Sancti Spíritus divinitáte adjúngitur: Et Spíritu oris ejus omnis virtus eórum. \
Cælórum ergo virtus de Spíritu sumpta est: quia mundi hujus potestátibus contraíre non præsúmerent, \
nisi eos Sancti Spíritus fortitúdo solidásset. \
Quales namque doctóres sanctæ Ecclésiæ ante advéntum hujus Spíritus fúerint, scimus: \
et post advéntum illíus, cujus fortitúdinis facti sint, conspícimus.")

         (:ref "Hom. 30 in Evang."
          :source "Sermo sancti Gregórii Papæ"
          :text "\
Certe iste ipse pastor Ecclésiæ, ad cujus sacratíssimum corpus sedémus, \
quantæ debilitátis, quantǽque formídinis ante advéntum Spíritus fúerit, ancílla ostiária requisíta dicat. \
Una enim mulíeris voce percúlsus, dum mori tímuit, Vitam negávit. \
Et pensándum, quia eum comprehénsum Petrus negávit in terra, \
quem suspénsum latro conféssus est in cruce. \
Sed vir iste tantæ formídinis, qualis post advéntum Spíritus exsístat, audiámus. \
Fit convéntus magistrátus atque seniórum, cæsis denuntiátur Apóstolis, \
ne in nómine Jesu loqui débeant: Petrus magna auctoritáte respóndet: \
Obedíre opórtet Deo magis quam homínibus.")

         ;; ── Nocturn III: St. Jerome (Matt 19:27-29) ──

         (:ref "Matt 19:27-29"
          :source "Homilía sancti Hierónymi Presbýteri"
          :text "\
Grandis fidúcia! Petrus piscátor erat, dives non fúerat, cibos manu et arte quærébat: \
et tamen lóquitur confidénter: Relíquimus ómnia. Et quia non súfficit tantum relínquere, \
jungit quod perféctum est: Et secúti sumus te. Fécimus quod jussísti: quid ígitur nobis dabis prǽmii? \
Jesus autem dixit illis: Amen dico vobis, quod vos qui secúti estis me, in regeneratióne, \
cum séderit Fílius hóminis in sede majestátis suæ, sedébitis et vos super sedes duódecim, \
judicántes duódecim tribus Ísraël. Non dixit: Qui reliquístis ómnia; \
hoc enim et Crates fecit philósophus, et multi álii divítias contempsérunt: \
sed, Qui secúti estis me: quod próprie Apostolórum est, atque credéntium.")

         (:ref "Matt 19:27-29"
          :source "Homilía sancti Hierónymi Presbýteri"
          :text "\
In regeneratióne, cum séderit Fílius hóminis in sede majestátis suæ \
(quando et mórtui de corruptióne resúrgent incorrúpti) sedébitis et vos in sóliis judicántium, \
condemnántes duódecim tribus Ísraël: quia vobis credéntibus, illi crédere noluérunt. \
Et omnis qui relíquerit domum, vel fratres, aut soróres, aut patrem, aut matrem, aut uxórem, \
aut fílios, aut agros propter nomen meum, céntuplum accípiet, et vitam ætérnam possidébit. \
Locus iste cum illa senténtia cóngruit, in qua Salvátor lóquitur: \
Non veni pacem míttere, sed gládium. Veni enim separáre hóminem a patre suo, \
et matrem a fília, et nurum a socru: et inimíci hóminis doméstici ejus. \
Qui ergo propter fidem Christi, et prædicatiónem Evangélii, omnes afféctus contémpserint, \
atque divítias et sǽculi voluptátes: isti céntuplum recípient, et vitam ætérnam possidébunt.")

         (:ref "Matt 19:27-29"
          :source "Homilía sancti Hierónymi Presbýteri"
          :text "\
Ex occasióne hujus senténtiæ quidam introdúcunt mille annos post resurrectiónem, \
dicéntes, tunc nobis céntuplum ómnium rerum quas dimísimus, et vitam ætérnam esse reddéndam: \
non intelligéntes, quod, si in céteris digna sit repromíssio, in uxóribus appáreat turpitúdo: \
ut qui unam pro Dómino dimíserit centum recípiat in futúro. \
Sensus ergo iste est: Qui carnália pro Salvatóre dimíserit, spirituália recípiet: \
quæ comparatióne et mérito sui ita erunt, quasi si parvo número centenárius númerus comparétur.")
         )  ; end lessons

        :responsories
        (
         (:respond "Ecce ego mitto vos sicut oves in médio lupórum, dicit Dóminus:"
          :verse "Dum lucem habétis, crédite in lucem, ut fílii lucis sitis."
          :repeat "Estóte ergo prudéntes sicut serpéntes, et símplices sicut colúmbæ.")
         (:respond "Tóllite jugum meum super vos, dicit Dóminus, et díscite a me, quia mitis sum et húmilis corde:"
          :verse "Et inveniétis réquiem animábus vestris."
          :repeat "Jugum enim meum suáve est, et onus meum leve.")
         (:respond "Dum stetéritis ante reges et prǽsides, nolíte cogitáre quómodo aut quid loquámini:"
          :verse "Non enim vos estis qui loquímini: sed Spíritus Patris vestri, qui lóquitur in vobis."
          :repeat "Dábitur enim vobis in illa hora, quid loquámini."
          :gloria t)
         (:respond "Vidi conjúnctos viros, habéntes spléndidas vestes, et Ángelus Dómini locútus est ad me, dicens:"
          :verse "Vidi Ángelum Dei fortem, volántem per médium cælum, voce magna clamántem et dicéntem."
          :repeat "Isti sunt viri sancti facti amíci Dei.")
         (:respond "Beáti estis, cum maledíxerint vobis hómines, et persecúti vos fúerint, et díxerint omne malum advérsum vos, mentiéntes, propter me:"
          :verse "Cum vos óderint hómines, et cum separáverint vos, et exprobráverint, et ejécerint nomen vestrum tamquam malum propter Fílium hóminis."
          :repeat "Gaudéte et exsultáte, quóniam merces vestra copiósa est in cælis.")
         (:respond "Isti sunt triumphatóres et amíci Dei, qui contemnéntes jussa príncipum, meruérunt prǽmia ætérna:"
          :verse "Isti sunt qui venérunt ex magna tribulatióne, et lavérunt stolas suas in sánguine Agni."
          :repeat "Modo coronántur, et accípiunt palmam."
          :gloria t)
         (:respond "Isti sunt qui vivéntes in carne, plantavérunt Ecclésiam sánguine suo:"
          :verse "In omnem terram exívit sonus eórum, et in fines orbis terræ verba eórum."
          :repeat "Cálicem Dómini bibérunt, et amíci Dei facti sunt.")
         (:respond "Isti sunt viri sancti, quos elégit Dóminus in caritáte non ficta, et dedit illis glóriam sempitérnam:"
          :verse "Sancti per fidem vicérunt regna: operáti sunt justítiam."
          :repeat "Quorum doctrína fulget Ecclésia, ut sole luna."
          :gloria t)
         )

        ;; ── Vespers I ─────────────────────────────────────────────
        :vespers-psalms ((hoc-est-praeceptum-meum . 109)
                         (majorem-caritatem . 110)
                         (vos-amici-mei-estis . 111)
                         (beati-pacifici . 112)
                         (in-patientia-vestra . 116))
        :vespers-hymn exsultet-orbis-gaudiis
        :vespers-capitulum (:ref "Eph 2:19-20"
                            :text "Fratres: Jam non estis hóspites et ádvenæ: sed estis cives Sanctórum et doméstici Dei: superædificáti super fundaméntum Apostolórum, et Prophetárum, ipso summo angulári lápide Christo Jesu.")
        :vespers-versicle ("In omnem terram exívit sonus eórum."
                           "Et in fines orbis terræ verba eórum.")
        :vespers-versicle-en ("Their sound hath gone forth into all the earth."
                              "And their words unto the ends of the world.")
        :magnificat-antiphon tradent-enim-vos

        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((hoc-est-praeceptum-meum . 92)
                       (majorem-caritatem . 99)
                       (vos-amici-mei-estis . 62)
                       (beati-pacifici . 210)
                       (in-patientia-vestra . 148))
        :lauds-hymn exsultet-orbis-gaudiis
        :lauds-capitulum (:ref "Eph 2:19-20"
                          :text "Fratres: Jam non estis hóspites et ádvenæ: sed estis cives Sanctórum et doméstici Dei: superædificáti super fundaméntum Apostolórum, et Prophetárum, ipso summo angulári lápide Christo Jesu.")
        :lauds-versicle ("Annuntiavérunt ópera Dei."
                         "Et facta ejus intellexérunt.")
        :lauds-versicle-en ("They declared the works of God."
                            "And understood his doings.")
        :benedictus-antiphon vos-qui-reliquistis

        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Act 5:41"
                          :text "Ibant Apóstoli gaudéntes a conspéctu concílii, quóniam digni hábiti sunt pro nómine Jesu contuméliam pati.")
        ;; ── Terce ─────────────────────────────────────────────────
        :terce-responsory-breve (:respond "In omnem terram"
                                 :repeat "Exívit sonus eórum."
                                 :verse "Et in fines orbis terræ verba eórum.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "Act 5:12"
                         :text "Per manus autem Apostolórum fiébant signa et prodígia multa in plebe.")
        :sext-responsory-breve (:respond "Constítues eos príncipes"
                                :repeat "Super omnem terram."
                                :verse "Mémores erunt nóminis tui, Dómine.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Nimis honoráti sunt"
                                :repeat "Amíci tui, Deus."
                                :verse "Nimis confortátus est principátus eórum.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms ((juravit-dominus . 109)
                          (collocet-eum . 112)
                          (dirupisti-domine . 115)
                          (euntes-ibant . 125)
                          (confortatus-est . 138))
        :vespers2-versicle nil
        :vespers2-versicle-en nil
        :magnificat2-antiphon estote-fortes
        ))  ; end C1


    ;; ════════════════════════════════════════════════════════════════════
    ;; C2 — COMMUNE UNIUS MARTYRIS PONTIFICIS
    ;; Psalms: 1/2/3, 4/5/8, 10/14/20
    ;; Invitatory: Regem Martyrum Dominum
    ;; Hymn: Deus tuorum militum
    ;; ════════════════════════════════════════════════════════════════════

    (C2
     . (:invitatory regem-martyrum-dominum
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
        :versicle-1-en ("Thou hast crowned him with glory and honour, O Lord."
                        "And hast set him over the works of thy hands.")
        :versicle-2 ("Posuísti, Dómine, super caput ejus."
                     "Corónam de lápide pretióso.")
        :versicle-2-en ("Thou hast set, O Lord, upon his head."
                        "A crown of precious stones.")
        :versicle-3 ("Magna est glória ejus in salutári tuo."
                     "Glóriam et magnum decórem impónes super eum.")
        :versicle-3-en ("Great is his glory in thy salvation."
                        "Glory and great beauty shalt thou lay upon him.")

        :lessons
        (
         ;; ── Nocturn I: Acts of the Apostles ──

         (:ref "Acts 20:17-24"
          :source "De Áctibus Apostolórum"
          :text "\
A Miléto Paulus mittens Éphesum, vocávit majóres natu Ecclésiæ. \
Qui cum veníssent ad eum, et simul essent, dixit eis: Vos scitis a prima die qua ingréssus sum in Ásiam, \
quáliter vobíscum per omne tempus fúerim, sérviens Dómino cum omni humilitáte, et lácrimis, \
et tentatiónibus, quae mihi accidérunt ex insídiis Judæórum: \
quómodo nihil subtráxerim utílium, quóminus annuntiárem vobis et docérem vos, públice et per domos, \
testíficans Judǽis atque Gentílibus in Deum pœniténtiam, et fidem in Dóminum nostrum Jesum Christum. \
Et nunc ecce alligátus ego spíritu, vado in Jerúsalem: quæ in ea ventúra sint mihi, ignórans: \
nisi quod Spíritus Sanctus per omnes civitátes mihi protestátur, dicens: \
Quóniam víncula et tribulatiónes Jerosólymis me manent. \
Sed nihil horum véreor: nec fácio ánimam meam pretiosiórem quam me, \
dúmmodo consúmmem cursum meum, et ministérium verbi quod accépi a Dómino Jesu, \
testificári Evangélium grátiæ Dei.")

         (:ref "Acts 20:25-31"
          :text "\
Et nunc ecce ego scio quia ámplius non vidébitis fáciem meam vos omnes, per quos transívi prǽdicans regnum Dei. \
Quaprópter contéstor vos hodiérna die, quia mundus sum a sánguine ómnium. \
Non enim subterfúgi, quóminus annuntiárem omne consílium Dei vobis. \
Atténdite vobis, et univérso gregi, in quo vos Spíritus Sanctus pósuit epíscopos \
régere Ecclésiam Dei, quam acquisívit sánguine suo. \
Ego scio quóniam intrábunt post discessiónem meam lupi rapáces in vos, non parcéntes gregi. \
Et ex vobis ipsis exsúrgent viri loquéntes pervérsa, ut abdúcant discípulos post se. \
Propter quod vigiláte, memória retinéntes quóniam per triénnium nocte et die non cessávi, \
cum lácrimis monens unumquémque vestrum.")

         (:ref "Acts 20:32-38"
          :text "\
Et nunc comméndo vos Deo, et verbo grátiæ ipsíus, qui potens est ædificáre, \
et dare hereditátem in sanctificátis ómnibus. \
Argéntum, et aurum, aut vestem nullíus concupívi, sicut ipsi scitis: \
quóniam ad ea quæ mihi opus erant, et his qui mecum sunt, ministravérunt manus istæ. \
Ómnia osténdi vobis, quóniam sic laborántes, opórtet suscípere infírmos \
ac meminísse verbi Dómini Jesu: quóniam ipse dixit: Beátius est magis dare, quam accípere. \
Et cum haec dixísset, pósitis génibus suis orávit cum ómnibus illis. \
Magnus autem fletus factus est ómnium: et procumbéntes super collum Pauli, osculabántur eum, \
doléntes máxime in verbo quod díxerat, quóniam ámplius fáciem ejus non essent visúri. \
Et deducébant eum ad navem.")

         ;; ── Nocturn II: St. Augustine (Sermo 44) ──

         (:ref "Sermo 44 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Triumphális beáti Mártyris N. dies hódie nobis anniversária celebritáte recúrrit: \
cujus glorificatióni sicut congáudet Ecclésia, sic ejus propónit sequénda vestígia. \
Si enim compátimur, et conglorificábimur. In cujus glorióso agóne duo nobis præcípue consideránda sunt: \
induráta vidélicet tortóris sævítia, et Mártyris invícta patiéntia. \
Sævítia tortóris, ut eam detestémur: patiéntia Mártyris, ut eam imitémur. \
Audi Psalmístam advérsus malítiam increpántem: Noli æmulári in malignántibus \
quóniam tamquam fœnum velóciter aréscent. \
Quod autem advérsus malignántes patiéntia exhibénda sit, audi Apóstolum suadéntem: \
Patiéntia vobis necessária est, ut reportétis promissiónes.")

         (:ref "Sermo 44 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Coronáta ítaque est beáti Mártyris patiéntia: mancipáta est ætérnis cruciátibus tortóris incorrécta malítia. \
Hoc atténdens in agóne suo gloriósus Christi Athléta, non exhórruit cárcerem. \
Ad imitatiónem cápitis sui tolerávit probra, sustínuit irrisiónes, flagélla non tímuit: \
et quot ante mortem pro Christo pértulit supplícia, tot ei de se óbtulit sacrifícia. \
Quod enim propinánte Apóstolo bíberat, alte retinébat: Quia non sunt condígnæ passiónes hujus témporis \
ad futúram glóriam, quæ revelábitur in nobis. Et quia momentáneum hoc et leve nostræ tribulatiónis, \
ætérnum glóriæ pondus operátur in cælis. Hujus promissiónis amóre a terrénis suspénsus, \
et prægustáta supérnæ suavitátis dulcédine ineffabíliter afféctus, \
dicébat cum Psalmísta: Quid mihi est in cælo, et a te quid volui super terram? \
Defécit caro mea et cor meum: Deus cordis mei, et pars mea Deus in ætérnum.")

         (:ref "Sermo 44 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Contemplabátur enim quantum in ænígmate infírmitas humána óculum mentis in æternitáte fígere potest, \
quanta sint supérnæ civitátis gáudia: et ea enarráre non suffíciens admirándo clamábat \
Quid mihi est in cælo? Quasi díceret: Excédit vires meas, excédit facultátem eloquéntiæ meæ, \
transcéndit capacitátem intelligéntiæ meæ illud decus, illa glória, illa celsitúdo, \
qua nobis, a conturbatióne hóminum remótis, in abscóndito faciéi suæ Jesus Christus Dóminus noster \
reformábit corpus humilitátis nostræ, configurátum córpori claritátis suæ. \
Hujus perféctæ libertátis contemplatióne nullum vitábat perículum, \
nullum horrébat supplícium: et si mílies posset mori, \
non putábat se hanc digne posse áliqua ratióne promeréri.")

         ;; ── Nocturn III: St. Gregory (Luc 14:26-33) ──

         (:ref "Luc 14:26-33"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Si considerémus fratres caríssimi, quæ et quanta sunt, quæ nobis promittúntur in cælis, \
viléscunt ánimo ómnia quæ habéntur in terris. Terréna namque substántia supérnæ felicitáti comparáta, \
pondus est, non subsídium. Temporális vita ætérnæ vitæ comparáta, mors est pótius dicénda quam vita. \
Ipse enim quotidiánus deféctus corruptiónis quid est áliud, quam quædam prolíxitas mortis? \
Quæ autem lingua dícere, vel quis intelléctus cápere súfficit, illa supérnæ civitátis quanta sint gáudia; \
Angelórum choris interésse, cum beatíssimis spirítibus glóriæ Conditóris assístere, \
præséntem Dei vultum cérnere, incircumscríptum lumen vidére, nullo mortis metu áffici, \
incorruptiónis perpétuæ múnere lætári?")

         (:ref "Luc 14:26-33"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Sed ad hæc audíta inardéscit ánimus, jamque illic cupit assístere, \
ubi se sperat sine fine gaudére. Sed ad magna prǽmia perveníri non potest, nisi per magnos labóres. \
Unde et Paulus egrégius prædicátor dicit: Non coronábitur, nisi qui legítime certáverit. \
Deléctet ergo mentem magnitúdo præmiórum, sed non detérreat certámen labórum. \
Unde ad se veniéntibus Véritas dicit: Si quis venit ad me, et non odit patrem suum, et matrem, \
et uxórem, et fílios, et fratres, et soróres, adhuc autem et ánimam suam, \
non potest meus esse discípulus.")

         (:ref "Luc 14:26-33"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Sed percontári libet, quómodo paréntes et carnáliter propínquos præcípimur odísse, \
qui jubémur et inimícos dilígere? Et certe Véritas de uxóre dicit: Quod Deus conjúnxit, homo non séparet. \
Et Paulus ait: Viri, dilígite uxóres vestras, sicut et Christus Ecclésiam. \
Ecce, discípulus uxórem diligéndam prǽdicat, cum magíster dicat: \
Qui uxórem non odit, non potest meus esse discípulus. \
Numquid áliud judex núntiat, áliud præco clamat? \
An simul et odísse póssumus, et dilígere? \
Sed si vim præcépti perpéndimus, utrúmque ágere per discretiónem valémus: \
ut uxórem, et eos, qui nobis carnis cognatióne conjúncti sunt, et quos próximos nóvimus, diligámus; \
et quos adversários in via Dei pátimur, odiéndo et fugiéndo nesciámus.")
         )  ; end lessons

        :responsories
        (
         (:respond "Iste Sanctus pro lege Dei sui certávit usque ad mortem, et a verbis impiórum non tímuit:"
          :verse "Iste est qui contémpsit vitam mundi, et pervénit ad cæléstia regna."
          :repeat "Fundátus enim erat supra firmam petram.")
         (:respond "Justus germinábit sicut lílium:"
          :verse "Plantátus in domo Dómini, in átriis domus Dei nostri."
          :repeat "Et florébit in ætérnum ante Dóminum.")
         (:respond "Iste cognóvit justítiam, et vidit mirabília magna, et exorávit Altíssimum"
          :verse "Iste est qui contémpsit vitam mundi, et pervénit ad cæléstia regna."
          :repeat "Et invéntus est in número Sanctórum."
          :gloria t)
         (:respond "Honéstum fecit illum Dóminus, et custodívit eum ab inimícis, et a seductóribus tutávit illum:"
          :verse "Descendítque cum illo in fóveam, et in vínculis non derelíquit eum."
          :repeat "Et dedit illi claritátem ætérnam.")
         (:respond "Desidérium ánimæ ejus tribuísti ei Dómine,"
          :verse "Quóniam prævenísti eum in benedictiónibus dulcédinis: posuísti in cápite ejus corónam de lápide pretióso."
          :repeat "Et voluntáte labiórum ejus non fraudásti eum.")
         (:respond "Stola jucunditátis índuit eum Dóminus:"
          :verse "Cibávit illum Dóminus pane vitæ et intelléctus: et aqua sapiéntiæ salutáris potávit illum."
          :repeat "Et corónam pulchritúdinis pósuit super caput ejus."
          :gloria t)
         (:respond "Coróna áurea super caput ejus,"
          :verse "Quóniam prævenísti eum in benedictiónibus dulcédinis, posuísti in cápite ejus corónam de lápide pretióso."
          :repeat "Expréssa signo sanctitátis, glória honóris, et opus fortitúdinis.")
         (:respond "Hic est vere Martyr, qui pro Christi nómine sánguinem suum fudit:"
          :verse "Justum dedúxit Dóminus per vias rectas, et osténdit illi regnum Dei."
          :repeat "Qui minas júdicum non tímuit, nec terrénæ dignitátis glóriam quæsívit, sed ad cæléstia regna pervénit."
          :gloria t)
         )

        ;; ── Vespers I ─────────────────────────────────────────────
        :vespers-psalms ((qui-me-confessus-fuerit . 109)
                         (qui-sequitur-me . 110)
                         (qui-mihi-ministrat . 111)
                         (si-quis-mihi-ministraverit . 112)
                         (volo-pater . 116))
        :vespers-hymn deus-tuorum-militum
        :vespers-capitulum (:ref "Jac 1:12"
                            :text "Beátus vir, qui suffert tentatiónem: quóniam cum probátus fúerit, accípiet corónam vitæ, quam repromísit Deus diligéntibus se.")
        :vespers-versicle ("Glória et honóre coronásti eum, Dómine."
                           "Et constituísti eum super ópera mánuum tuárum.")
        :vespers-versicle-en ("Thou hast crowned him with glory and honour, O Lord."
                              "And madest him to have dominion over the works of thy hands.")
        :magnificat-antiphon iste-sanctus

        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((qui-me-confessus-fuerit . 92)
                       (qui-sequitur-me . 99)
                       (qui-mihi-ministrat . 62)
                       (si-quis-mihi-ministraverit . 210)
                       (volo-pater . 148))
        :lauds-hymn invicte-martyr-unicum
        :lauds-capitulum (:ref "Jac 1:12"
                          :text "Beátus vir, qui suffert tentatiónem: quóniam cum probátus fúerit, accípiet corónam vitæ, quam repromísit Deus diligéntibus se.")
        :lauds-versicle ("Justus ut palma florébit."
                         "Sicut cedrus Líbani multiplicábitur.")
        :lauds-versicle-en ("The righteous shall flourish like the palm-tree."
                            "He shall grow like a cedar in Lebanon.")
        :benedictus-antiphon qui-odit-animam-suam

        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Sir 39:6"
                          :text "Justus cor suum trádidit ad vigilándum dilúculo ad Dóminum, qui fecit illum, et in conspéctu Altíssimi deprecábitur.")
        ;; ── Terce ─────────────────────────────────────────────────
        :terce-responsory-breve (:respond "Glória et honóre"
                                 :repeat "Coronásti eum, Dómine."
                                 :verse "Et constituísti eum super ópera mánuum tuárum.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "Sir 15:3"
                         :text "Cibávit illum pane vitæ et intelléctus, et aqua sapiéntiæ salutáris potávit illum Dóminus Deus noster.")
        :sext-responsory-breve (:respond "Posuísti, Dómine,"
                                :repeat "Super caput ejus."
                                :verse "Corónam de lápide pretióso.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Magna est glória ejus"
                                :repeat "In salutári tuo."
                                :verse "Glóriam et magnum decórem impónes super eum.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms nil
        :vespers2-versicle nil
        :vespers2-versicle-en nil
        :magnificat2-antiphon qui-vult-venire-post-me
        ))  ; end C2


    ;; ════════════════════════════════════════════════════════════════════
    ;; C2a — COMMUNE UNIUS MARTYRIS (non-Bishop)
    ;; Same psalms/antiphons/responsories as C2, different Nocturn I & III lessons.
    ;; Nocturn I: Rom 8:12-19 (from C3); Nocturn III: Matt 16:24-27 (from C2 in 2 loco)
    ;; ════════════════════════════════════════════════════════════════════

    (C2a
     . (:invitatory regem-martyrum-dominum
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
        :versicle-1-en ("Thou hast crowned him with glory and honour, O Lord."
                        "And hast set him over the works of thy hands.")
        :versicle-2 ("Posuísti, Dómine, super caput ejus."
                     "Corónam de lápide pretióso.")
        :versicle-2-en ("Thou hast set, O Lord, upon his head."
                        "A crown of precious stones.")
        :versicle-3 ("Magna est glória ejus in salutári tuo."
                     "Glóriam et magnum decórem impónes super eum.")
        :versicle-3-en ("Great is his glory in thy salvation."
                        "Glory and great beauty shalt thou lay upon him.")

        :lessons
        (
         ;; ── Nocturn I: Romans (from C3) ──

         (:ref "Rom 8:12-19"
          :source "De Epístola beáti Pauli Apóstoli ad Romános"
          :text "\
Fratres: Debitóres sumus non carni, ut secúndum carnem vivámus. \
Si enim secúndum carnem vixéritis, moriémini: si autem spíritu facta carnis mortificavéritis, vivétis. \
Quicúmque enim spíritu Dei agúntur, ii sunt fílii Dei. \
Non enim accepístis spíritum servitútis íterum in timóre, \
sed accepístis spíritum adoptiónis filiórum, in quo clamámus: Abba (Pater). \
Ipse enim Spíritus testimónium reddit spirítui nostro quod sumus fílii Dei. \
Si autem fílii, et herédes: herédes, quidem Dei, coherédes autem Christi: \
si tamen compátimur ut et conglorificémur. \
Exístimo enim quod non sunt condígnæ passiónes hujus témporis ad futúram glóriam, \
quæ revelábitur in nobis. Nam exspectátio creatúræ revelatiónem filiórum Dei exspéctat.")

         (:ref "Rom 8:28-34"
          :text "\
Scimus autem quóniam diligéntibus Deum ómnia cooperántur in bonum \
iis qui secúndum propósitum vocáti sunt sancti. \
Nam quos præscívit et prædestinávit confórmes fíeri imáginis Fílii sui \
ut sit ipse primogénitus in multis frátribus. \
Quos autem prædestinávit, hos et vocávit: et quos vocávit, hos et justificávit: \
quos autem justificávit, illos et glorificávit. \
Quid ergo dicémus ad hæc? Si Deus pro nobis, quis contra nos? \
Qui étiam próprio Fílio suo non pepércit, sed pro nobis ómnibus trádidit illum, \
quómodo non étiam cum illo ómnia nobis donávit? \
Quis accusábit advérsus eléctos Dei? Deus qui justíficat, quis est qui condémnet? \
Christus Jesus, qui mórtuus est, immo qui et resurréxit, qui est ad déxteram Dei, \
qui étiam interpéllat pro nobis.")

         (:ref "Rom 8:35-39"
          :text "\
Quis ergo nos separábit a caritáte Christi? tribulátio? an angústia? an fames? an núditas? \
an perículum? an persecútio? an gládius? \
(sicut scriptum est: Quia propter te mortificámur tota die: æstimáti sumus sicut oves occisiónis.) \
Sed in his ómnibus superámus propter eum qui diléxit nos. \
Certus sum enim quia neque mors, neque vita, neque Ángeli, neque Principátus, neque Virtútes, \
neque instántia, neque futúra, neque fortitúdo, neque altitúdo, neque profúndum, \
neque creatúra ália póterit nos separáre a caritáte Dei, quæ est in Christo Jesu Dómino nostro.")

         ;; ── Nocturn II: St. Augustine (same as C2) ──

         (:ref "Sermo 44 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Triumphális beáti Mártyris N. dies hódie nobis anniversária celebritáte recúrrit: \
cujus glorificatióni sicut congáudet Ecclésia, sic ejus propónit sequénda vestígia. \
Si enim compátimur, et conglorificábimur. In cujus glorióso agóne duo nobis præcípue consideránda sunt: \
induráta vidélicet tortóris sævítia, et Mártyris invícta patiéntia. \
Sævítia tortóris, ut eam detestémur: patiéntia Mártyris, ut eam imitémur. \
Audi Psalmístam advérsus malítiam increpántem: Noli æmulári in malignántibus \
quóniam tamquam fœnum velóciter aréscent. \
Quod autem advérsus malignántes patiéntia exhibénda sit, audi Apóstolum suadéntem: \
Patiéntia vobis necessária est, ut reportétis promissiónes.")

         (:ref "Sermo 44 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Coronáta ítaque est beáti Mártyris patiéntia: mancipáta est ætérnis cruciátibus tortóris incorrécta malítia. \
Hoc atténdens in agóne suo gloriósus Christi Athléta, non exhórruit cárcerem. \
Ad imitatiónem cápitis sui tolerávit probra, sustínuit irrisiónes, flagélla non tímuit: \
et quot ante mortem pro Christo pértulit supplícia, tot ei de se óbtulit sacrifícia. \
Quod enim propinánte Apóstolo bíberat, alte retinébat: Quia non sunt condígnæ passiónes hujus témporis \
ad futúram glóriam, quæ revelábitur in nobis. Et quia momentáneum hoc et leve nostræ tribulatiónis, \
ætérnum glóriæ pondus operátur in cælis. Hujus promissiónis amóre a terrénis suspénsus, \
et prægustáta supérnæ suavitátis dulcédine ineffabíliter afféctus, \
dicébat cum Psalmísta: Quid mihi est in cælo, et a te quid volui super terram? \
Defécit caro mea et cor meum: Deus cordis mei, et pars mea Deus in ætérnum.")

         (:ref "Sermo 44 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Contemplabátur enim quantum in ænígmate infírmitas humána óculum mentis in æternitáte fígere potest, \
quanta sint supérnæ civitátis gáudia: et ea enarráre non suffíciens admirándo clamábat \
Quid mihi est in cælo? Quasi díceret: Excédit vires meas, excédit facultátem eloquéntiæ meæ, \
transcéndit capacitátem intelligéntiæ meæ illud decus, illa glória, illa celsitúdo, \
qua nobis, a conturbatióne hóminum remótis, in abscóndito faciéi suæ Jesus Christus Dóminus noster \
reformábit corpus humilitátis nostræ, configurátum córpori claritátis suæ. \
Hujus perféctæ libertátis contemplatióne nullum vitábat perículum, \
nullum horrébat supplícium: et si mílies posset mori, \
non putábat se hanc digne posse áliqua ratióne promeréri.")

         ;; ── Nocturn III: St. Gregory (Matt 16:24-27), C2 in 2 loco ──

         (:ref "Matt 16:24-27"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Quia Dóminus ac Redémptor noster novus homo venit in mundum, nova præcépta dedit mundo. \
Vitæ étenim nostræ véteri in vítiis enutrítæ contrarietátem oppósuit novitátis suæ. \
Quid enim vetus, quid carnális homo nóverat, nisi sua retinére, aliéna rápere, si posset; \
concupíscere, si non posset? Sed cæléstis médicus síngulis quibúsque vítiis obviántia ádhibet medicaménta. \
Nam sicut arte medicínæ cálida frígidis, frígida cálidis curántur: \
ita Dóminus noster contrária oppósuit medicaménta peccátis, \
ut lúbricis continéntiam, tenácibus largitátem, iracúndis mansuetúdinem, elátis præcíperet humilitátem.")

         (:ref "Matt 16:24-27"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Certe cum se sequéntibus nova mandáta propóneret, dixit: \
Nisi quis renuntiáverit ómnibus quæ póssidet, non potest meus esse discípulus. \
Ac si apérte dicat: Qui per vitam véterem aliéna concupíscitis, \
per novæ conversatiónis stúdium et vestra largímini. \
Quid vero in hac lectióne dicat, audiámus: Qui vult post me veníre, ábneget semetípsum. \
Ibi dícitur, ut abnegémus nostra: hic dícitur, ut abnegémus nos. \
Et fortásse laboriósum non est hómini relínquere sua; sed valde laboriósum est relínquere semetípsum. \
Minus quippe est abnegáre quod habet; valde autem multum est abnegáre quod est.")

         (:ref "Matt 16:24-27"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Ad se autem nobis veniéntibus Dóminus præcépit, ut renuntiémus nostris: \
quia quicúmque ad fídei agónem vénimus, luctámen contra malígnos spíritus súmimus. \
Nihil autem malígni spíritus in hoc mundo próprium póssident: \
nudi ergo cum nudis luctári debémus. \
Nam si vestítus quisque cum nudo luctátur, cítius ad terram dejícitur, quia habet unde teneátur. \
Quid enim sunt terréna ómnia, nisi quædam córporis induménta? \
Qui ergo contra diábolum ad certámen próperat, vestiménta abjíciat, ne succúmbat.")
         )  ; end lessons

        :responsories
        (
         ;; Same responsories as C2
         (:respond "Iste Sanctus pro lege Dei sui certávit usque ad mortem, et a verbis impiórum non tímuit:"
          :verse "Iste est qui contémpsit vitam mundi, et pervénit ad cæléstia regna."
          :repeat "Fundátus enim erat supra firmam petram.")
         (:respond "Justus germinábit sicut lílium:"
          :verse "Plantátus in domo Dómini, in átriis domus Dei nostri."
          :repeat "Et florébit in ætérnum ante Dóminum.")
         (:respond "Iste cognóvit justítiam, et vidit mirabília magna, et exorávit Altíssimum"
          :verse "Iste est qui contémpsit vitam mundi, et pervénit ad cæléstia regna."
          :repeat "Et invéntus est in número Sanctórum."
          :gloria t)
         (:respond "Honéstum fecit illum Dóminus, et custodívit eum ab inimícis, et a seductóribus tutávit illum:"
          :verse "Justum dedúxit Dóminus per vias rectas, et osténdit illi regnum Dei."
          :repeat "Et dedit illi claritátem ætérnam.")
         (:respond "Desidérium ánimæ ejus tribuísti ei Dómine,"
          :verse "Quóniam prævenísti eum in benedictiónibus dulcédinis: posuísti in cápite ejus corónam de lápide pretióso."
          :repeat "Et voluntáte labiórum ejus non fraudásti eum.")
         (:respond "Stola jucunditátis índuit eum Dóminus:"
          :verse "Cibávit illum Dóminus pane vitæ et intelléctus: et aqua sapiéntiæ salutáris potávit illum."
          :repeat "Et corónam pulchritúdinis pósuit super caput ejus."
          :gloria t)
         (:respond "Coróna áurea super caput ejus,"
          :verse "Quóniam prævenísti eum in benedictiónibus dulcédinis, posuísti in cápite ejus corónam de lápide pretióso."
          :repeat "Expréssa signo sanctitátis, glória honóris, et opus fortitúdinis.")
         (:respond "Hic est vere Martyr, qui pro Christi nómine sánguinem suum fudit:"
          :verse "Justum dedúxit Dóminus per vias rectas, et osténdit illi regnum Dei."
          :repeat "Qui minas júdicum non tímuit, nec terrénæ dignitátis glóriam quæsívit, sed ad cæléstia regna pervénit."
          :gloria t)
         )

        ;; Non-Matins hours: identical to C2
        ;; ── Vespers I ─────────────────────────────────────────────
        :vespers-psalms ((qui-me-confessus-fuerit . 109)
                         (qui-sequitur-me . 110)
                         (qui-mihi-ministrat . 111)
                         (si-quis-mihi-ministraverit . 112)
                         (volo-pater . 116))
        :vespers-hymn deus-tuorum-militum
        :vespers-capitulum (:ref "Jac 1:12"
                            :text "Beátus vir, qui suffert tentatiónem: quóniam cum probátus fúerit, accípiet corónam vitæ, quam repromísit Deus diligéntibus se.")
        :vespers-versicle ("Glória et honóre coronásti eum, Dómine."
                           "Et constituísti eum super ópera mánuum tuárum.")
        :vespers-versicle-en ("Thou hast crowned him with glory and honour, O Lord."
                              "And madest him to have dominion over the works of thy hands.")
        :magnificat-antiphon iste-sanctus
        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((qui-me-confessus-fuerit . 92)
                       (qui-sequitur-me . 99)
                       (qui-mihi-ministrat . 62)
                       (si-quis-mihi-ministraverit . 210)
                       (volo-pater . 148))
        :lauds-hymn invicte-martyr-unicum
        :lauds-capitulum (:ref "Jac 1:12"
                          :text "Beátus vir, qui suffert tentatiónem: quóniam cum probátus fúerit, accípiet corónam vitæ, quam repromísit Deus diligéntibus se.")
        :lauds-versicle ("Justus ut palma florébit."
                         "Sicut cedrus Líbani multiplicábitur.")
        :lauds-versicle-en ("The righteous shall flourish like the palm-tree."
                            "He shall grow like a cedar in Lebanon.")
        :benedictus-antiphon qui-odit-animam-suam
        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Sir 39:6"
                          :text "Justus cor suum trádidit ad vigilándum dilúculo ad Dóminum, qui fecit illum, et in conspéctu Altíssimi deprecábitur.")
        ;; ── Terce ─────────────────────────────────────────────────
        :terce-responsory-breve (:respond "Glória et honóre"
                                 :repeat "Coronásti eum, Dómine."
                                 :verse "Et constituísti eum super ópera mánuum tuárum.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "Sir 15:3"
                         :text "Cibávit illum pane vitæ et intelléctus, et aqua sapiéntiæ salutáris potávit illum Dóminus Deus noster.")
        :sext-responsory-breve (:respond "Posuísti, Dómine,"
                                :repeat "Super caput ejus."
                                :verse "Corónam de lápide pretióso.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Magna est glória ejus"
                                :repeat "In salutári tuo."
                                :verse "Glóriam et magnum decórem impónes super eum.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms nil
        :vespers2-versicle nil
        :vespers2-versicle-en nil
        :magnificat2-antiphon qui-vult-venire-post-me
        ))  ; end C2a


    ;; ════════════════════════════════════════════════════════════════════
    ;; C3 — COMMUNE PLURIMORUM MARTYRUM
    ;; Psalms: 1/2/3, 14/15/23, 32/33/45
    ;; Invitatory: Regem Martyrum Dominum (same as C2)
    ;; Hymn: Christo profusum sanguinem
    ;; ════════════════════════════════════════════════════════════════════

    (C3
     . (:invitatory regem-martyrum-dominum
        :hymn christo-profusum-sanguinem
        :psalms-1 ((secus-decursus-aquarum . 1)
                   (tamquam-aurum-in-fornace . 2)
                   (si-coram-hominibus . 3))
        :psalms-2 ((dabo-sanctis-meis . 14)
                   (sanctis-qui-in-terra . 15)
                   (sancti-qui-sperant . 23))
        :psalms-3 ((justi-autem-in-perpetuum . 32)
                   (tradiderunt-corpora-sua . 33)
                   (ecce-merces-sanctorum . 45))
        :versicle-1 ("Lætámini in Dómino, et exsultáte justi."
                     "Et gloriámini omnes recti corde.")
        :versicle-1-en ("Be glad in the Lord, and rejoice, ye just."
                        "And glory, all ye right of heart.")
        :versicle-2 ("Exsúltent justi in conspéctu Dei."
                     "Et delecténtur in lætítia.")
        :versicle-2-en ("Let the just rejoice in the sight of God."
                        "And be delighted with gladness.")
        :versicle-3 ("Justi autem in perpétuum vivent."
                     "Et apud Dóminum est merces eórum.")
        :versicle-3-en ("But the just shall live for evermore."
                        "And their reward is with the Lord.")

        :lessons
        (
         ;; ── Nocturn I: Romans ──

         (:ref "Rom 8:12-19"
          :source "De Epístola beáti Pauli Apóstoli ad Romános"
          :text "\
Fratres: Debitóres sumus non carni, ut secúndum carnem vivámus. \
Si enim secúndum carnem vixéritis, moriémini: si autem spíritu facta carnis mortificavéritis, vivétis. \
Quicúmque enim spíritu Dei agúntur, ii sunt fílii Dei. \
Non enim accepístis spíritum servitútis íterum in timóre, \
sed accepístis spíritum adoptiónis filiórum, in quo clamámus: Abba (Pater). \
Ipse enim Spíritus testimónium reddit spirítui nostro quod sumus fílii Dei. \
Si autem fílii, et herédes: herédes, quidem Dei, coherédes autem Christi: \
si tamen compátimur ut et conglorificémur. \
Exístimo enim quod non sunt condígnæ passiónes hujus témporis ad futúram glóriam, \
quæ revelábitur in nobis. Nam exspectátio creatúræ revelatiónem filiórum Dei exspéctat.")

         (:ref "Rom 8:28-34"
          :text "\
Scimus autem quóniam diligéntibus Deum ómnia cooperántur in bonum \
iis qui secúndum propósitum vocáti sunt sancti. \
Nam quos præscívit et prædestinávit confórmes fíeri imáginis Fílii sui \
ut sit ipse primogénitus in multis frátribus. \
Quos autem prædestinávit, hos et vocávit: et quos vocávit, hos et justificávit: \
quos autem justificávit, illos et glorificávit. \
Quid ergo dicémus ad hæc? Si Deus pro nobis, quis contra nos? \
Qui étiam próprio Fílio suo non pepércit, sed pro nobis ómnibus trádidit illum, \
quómodo non étiam cum illo ómnia nobis donávit? \
Quis accusábit advérsus eléctos Dei? Deus qui justíficat, quis est qui condémnet? \
Christus Jesus, qui mórtuus est, immo qui et resurréxit, qui est ad déxteram Dei, \
qui étiam interpéllat pro nobis.")

         (:ref "Rom 8:35-39"
          :text "\
Quis ergo nos separábit a caritáte Christi? tribulátio? an angústia? an fames? an núditas? \
an perículum? an persecútio? an gládius? \
(sicut scriptum est: Quia propter te mortificámur tota die: æstimáti sumus sicut oves occisiónis.) \
Sed in his ómnibus superámus propter eum qui diléxit nos. \
Certus sum enim quia neque mors, neque vita, neque Ángeli, neque Principátus, neque Virtútes, \
neque instántia, neque futúra, neque fortitúdo, neque altitúdo, neque profúndum, \
neque creatúra ália póterit nos separáre a caritáte Dei, quæ est in Christo Jesu Dómino nostro.")

         ;; ── Nocturn II: St. Augustine (Sermo 47) ──

         (:ref "Serm. 47 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Quotiescúmque fratres caríssimi, sanctórum Mártyrum solémnia celebrámus, \
ita, ipsis intercedéntibus, exspectémus a Dómino cónsequi temporália benefícia, \
ut ipsos Mártyres imitándo accípere mereámur ætérna. \
Ab ipsis enim sanctórum Mártyrum in veritáte festivitátum gáudia celebrántur, \
qui ipsórum Mártyrum exémpla sequúntur. \
Solemnitátes enim Mártyrum exhortatiónes sunt martyriórum: \
ut imitári non pígeat, quod celebráre deléctat.")

         (:ref "Serm. 47 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Sed nos vólumus gaudére cum Sanctis: et tribulatiónem mundi nólumus sustinére cum ipsis. \
Qui enim sanctos Mártyres, in quantum potúerit, imitári nolúerit; \
ad eórum beatitúdinem non póterit perveníre. \
Sed et Paulus Apóstolus prǽdicat dicens: Si fuérimus sócii passiónum, érimus et consolatiónum. \
Et Dóminus in Evangélio: Si mundus vos odit, scitóte quia me priórem vobis ódio hábuit. \
Recúsat esse in córpore, qui ódium non vult sustinére cum cápite.")

         (:ref "Serm. 47 de Sanctis"
          :source "Sermo sancti Augustíni Epíscopi"
          :text "\
Sed dicit áliquis: Et quis est qui possit beatórum Mártyrum vestígia sequi? \
Huic ego respóndeo, quia non solum Mártyres, sed étiam ipsum Dóminum \
cum ipsíus adjutório, si vólumus, póssumus imitári. \
Audi non me, sed ipsum Dóminum géneri humáno clamántem: \
Díscite a me, quia mitis sum et húmilis corde. \
Audi et Petrum Apóstolum admonéntem: \
Christus passus est pro nobis, relínquens nobis exémplum ut sequámur vestígia ejus.")

         ;; ── Nocturn III: St. Gregory (Luc 21:9-19) ──

         (:ref "Luc 21:9-19"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Dóminus ac Redémptor noster peritúri mundi præcurréntia mala denúntiat, \
ut eo minus pertúrbent veniéntia, quo fúerint præscíta. \
Minus enim jácula fériunt, quæ prævidéntur: et nos tolerabílius mundi mala suscípimus, \
si contra hæc per præsciéntiæ clípeum munímur. \
Ecce enim dicit: Cum audiéritis prǽlia et seditiónes, nolíte terréri: \
opórtet enim primum hæc fíeri, sed nondum statim finis. \
Pensánda sunt verba Redemptóris nostri, per quæ nos áliud intérius, áliud extérius passúros esse denúntiat; \
bella quippe ad hostes pértinent, seditiónes ad cives. \
Ut ergo nos índicet intérius exteriúsque turbári, \
áliud nos fatétur ab hóstibus, áliud a frátribus pérpeti.")

         (:ref "Luc 21:9-19"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Sed his malis præveniéntibus, quia non statim finis sequátur, adjúngit: \
Surget gens contra gentem, et regnum advérsus regnum: et terræmótus magni erunt per loca, \
et pestiléntiæ, et fames, terrorésque de cælo: et signa magna erunt. \
Última tribulátio multis tribulatiónibus prævenítur: \
et per crebra mala, quæ prævéniunt, indicántur mala perpétua, quæ subsequéntur. \
Et ídeo post bella et seditiónes non statim finis: \
quia multa debent mala præcúrrere, ut malum váleant sine fine nuntiáre.")

         (:ref "Luc 21:9-19"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Sed cum tot signa perturbatiónis dicta sint, opórtet, ut eórum consideratiónem bréviter per síngula perstringámus: \
quia necésse est, ut ália e cælo, ália e terra, ália ab eleméntis, ália ab homínibus patiámur. \
Ait enim: Surget gens contra gentem, ecce perturbátio hóminum: \
erunt terræmótus magni per loca, ecce respéctus iræ désuper: \
erunt pestiléntiæ ecce inæquálitas córporum: erit fames, ecce sterílitas terræ: \
terrorésque de cælo et tempestátes, ecce inæquálitas áëris. \
Quia ergo ómnia consummánda sunt, ante consummatiónem ómnia perturbántur: \
et qui in cunctis delíquimus, in cunctis ferímur: \
ut impleátur quod dícitur, Et pugnábit pro eo orbis terrárum contra insensátos.")
         )  ; end lessons

        :responsories
        (
         (:respond "Abstérget Deus omnem lácrimam ab óculis Sanctórum: et jam non erit ámplius neque luctus, neque clamor, sed nec ullus dolor:"
          :verse "Non esúrient, neque sítient ámplius, neque cadet super illos sol, neque ullus æstus."
          :repeat "Quóniam prióra transiérunt.")
         (:respond "Viri sancti gloriósum sánguinem fudérunt pro Dómino, amavérunt Christum in vita sua, imitáti sunt eum in morte sua:"
          :verse "Unus spíritus, et una fides erat in eis."
          :repeat "Et ídeo corónas triumpháles meruérunt.")
         (:respond "Tradidérunt córpora sua propter Deum ad supplícia:"
          :verse "Isti sunt qui venérunt ex magna tribulatióne, et lavérunt stolas suas in sánguine Agni."
          :repeat "Et meruérunt habére corónas perpétuas."
          :gloria t)
         (:respond "Sancti tui, Dómine, mirábile consecúti sunt iter, serviéntes præcéptis tuis, ut inveniréntur illǽsi in aquis válidis:"
          :verse "Quóniam percússit petram, et fluxérunt aquæ, et torréntes inundavérunt."
          :repeat "Terra appáruit árida: et in Mari Rubro via sine impediménto.")
         (:respond "Vérbera carníficum non timuérunt Sancti Dei, moriéntes pro Christi nómine:"
          :verse "Tradidérunt córpora sua propter Deum ad supplícia."
          :repeat "Ut herédes fíerent in domo Dómini.")
         (:respond "Tamquam aurum in fornáce probávit eléctos Dóminus, et quasi holocáusti hóstiam accépit illos: et in témpore erit respéctus illórum:"
          :verse "Qui confídunt in illum, intélligent veritátem, et fidéles in dilectióne acquiéscent illi."
          :repeat "Quóniam donum et pax est eléctis Dei."
          :gloria t)
         (:respond "Propter testaméntum Dómini, et leges patérnas, Sancti Dei perstitérunt in amóre fraternitátis:"
          :verse "Ecce quam bonum et quam jucúndum habitáre fratres in unum."
          :repeat "Quia unus fuit semper spíritus in eis, et una fides.")
         (:respond "Sancti mei, qui in carne pósiti, certámen habuístis:"
          :verse "Veníte benedícti Patris mei, percípite regnum."
          :repeat "Mercédem labóris ego reddam vobis."
          :gloria t)
         )

        ;; ── Vespers I ─────────────────────────────────────────────
        :vespers-psalms ((omnes-sancti-quanta . 109)
                         (cum-palma-ad-regna . 110)
                         (corpora-sanctorum . 111)
                         (martyres-domini . 112)
                         (martyrum-chorus . 116))
        :vespers-hymn sanctorum-meritis
        :vespers-capitulum (:ref "Sap 3:1-3"
                            :text "Justórum ánimæ in manu Dei sunt, et non tanget illos torméntum mortis. Visi sunt óculis insipiéntium mori: illi autem sunt in pace.")
        :vespers-versicle ("Lætámini in Dómino, et exsultáte justi."
                           "Et gloriámini omnes recti corde.")
        :vespers-versicle-en ("Be glad in the Lord, and rejoice, ye just."
                              "And glory, all ye right of heart.")
        :magnificat-antiphon istorum-est-enim

        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((omnes-sancti-quanta . 92)
                       (cum-palma-ad-regna . 99)
                       (corpora-sanctorum . 62)
                       (martyres-domini . 210)
                       (martyrum-chorus . 148))
        :lauds-hymn rex-gloriosae-martyrum
        :lauds-capitulum (:ref "Sap 3:1-3"
                          :text "Justórum ánimæ in manu Dei sunt, et non tanget illos torméntum mortis. Visi sunt óculis insipiéntium mori: illi autem sunt in pace.")
        :lauds-versicle ("Exsultábunt Sancti in glória."
                         "Lætabúntur in cubílibus suis.")
        :lauds-versicle-en ("The saints shall rejoice in glory."
                            "They shall be joyful in their beds.")
        :benedictus-antiphon vestri-capilli-capitis

        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Sap 3:7-8"
                          :text "Fulgébunt justi, et tamquam scintíllæ in arundinéto discúrrent. Judicábunt natiónes, et dominabúntur pópulis: et regnábit Dóminus illórum in perpétuum.")
        ;; ── Terce ─────────────────────────────────────────────────
        :terce-responsory-breve (:respond "Lætámini in Dómino,"
                                 :repeat "Et exsultáte justi."
                                 :verse "Et gloriámini omnes recti corde.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "Sap 10:17"
                         :text "Réddidit Deus mercédem labórum sanctórum suórum, et dedúxit illos in via mirábili: et fuit illis in velaménto diéi, et in luce stellárum nocte.")
        :sext-responsory-breve (:respond "Exsúltent justi"
                                :repeat "In conspéctu Dei."
                                :verse "Et delecténtur in lætítia.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Justi autem"
                                :repeat "In perpétuum vivent."
                                :verse "Et apud Dóminum est merces eórum.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms ((isti-sunt-sancti . 109)
                          (sancti-per-fidem . 110)
                          (sanctorum-velut-aquilae . 111)
                          (absterget-deus . 112)
                          (in-caelestibus-regnis . 115))
        :vespers2-versicle nil
        :vespers2-versicle-en nil
        :magnificat2-antiphon gaudent-in-caelis
        ))  ; end C3


    ;; ════════════════════════════════════════════════════════════════════
    ;; C4 — COMMUNE CONFESSORIS PONTIFICIS
    ;; Psalms: 1/2/3, 4/5/8, 14/20/23
    ;; Invitatory: Regem Confessorum Dominum
    ;; Hymn: Iste Confessor
    ;; ════════════════════════════════════════════════════════════════════

    (C4
     . (:invitatory regem-confessorum-dominum
        :hymn iste-confessor
        :psalms-1 ((beatus-vir-qui-in-lege-meditatur . 1)
                   (beatus-iste-sanctus . 2)
                   (tu-es-gloria-mea . 3))
        :psalms-2 ((invocantem-exaudivit . 4)
                   (laetentur-omnes-qui-sperant . 5)
                   (domine-dominus-noster-quam . 8))
        :psalms-3 ((domine-iste-sanctus . 14)
                   (vitam-petiit-a-te . 20)
                   (hic-accipiet-benedictionem . 23))
        :versicle-1 ("Amávit eum Dóminus, et ornávit eum."
                     "Stolam glóriæ índuit eum.")
        :versicle-1-en ("The Lord loved him, and adorned him."
                        "He clothed him with a robe of glory.")
        :versicle-2 ("Elégit eum Dóminus sacerdótem sibi."
                     "Ad sacrificándum ei hóstiam laudis.")
        :versicle-2-en ("The Lord chose him to be a priest unto himself."
                        "To offer unto him the sacrifice of praise.")
        :versicle-3 ("Tu es sacérdos in ætérnum."
                     "Secúndum órdinem Melchísedech.")
        :versicle-3-en ("Thou art a priest for ever."
                        "According to the order of Melchisedech.")

        :lessons
        (
         ;; ── Nocturn I: 1 Timothy / Titus ──

         (:ref "1 Tim 3:1-7"
          :source "De Epístola prima beáti Pauli Apóstoli ad Timótheum"
          :text "\
Fidélis sermo: si quis episcopátum desíderat, bonum opus desíderat. \
Opórtet ergo epíscopum irreprehensíbilem esse, uníus uxóris virum, sóbrium, prudéntem, ornátum, \
pudícum, hospitálem, doctórem, non vinoléntum, non percussórem, sed modéstum; non litigiósum, non cúpidum, sed \
suæ dómui bene præpósitum, fílios habéntem súbditos cum omni castitáte. \
Si quis autem dómui suæ præésse nescit, quómodo Ecclésiæ Dei diligéntiam habébit? \
Non neóphytum, ne in supérbiam elátus, in judícium íncidat diáboli. \
Opórtet autem illum et testimónium habére bonum ab iis qui foris sunt, \
ut non in oppróbrium íncidat, et in láqueum diáboli.")

         (:ref "Titus 1:7-11"
          :source "De Epístola ad Titum"
          :text "\
Opórtet enim epíscopum sine crímine esse, sicut Dei dispensatórem: non supérbum, non iracúndum, \
non vinoléntum, non percussórem, non turpis lucri cúpidum: \
sed hospitálem, benígnum, sóbrium, justum, sanctum, continéntem, \
amplecténtem eum, qui secúndum doctrínam est, fidélem sermónem: \
ut potens sit exhortári in doctrína sana, et eos qui contradícunt, argúere. \
Sunt enim multi étiam inobediéntes, vaníloqui, et seductóres: máxime qui de circumcisióne sunt: \
quos opórtet redárgui: qui univérsas domos subvértunt, docéntes quæ non opórtet, turpis lucri grátia.")

         (:ref "Titus 2:1-8"
          :text "\
Tu autem lóquere quæ decent sanam doctrínam: \
senes ut sóbrii sint, pudíci, prudéntes, sani in fide, in dilectióne, in patiéntia: \
anus simíliter in hábitu sancto, non criminatríces, non multo vino serviéntes, bene docéntes: \
ut prudéntiam dóceant adolescéntulas, ut viros suos ament, fílios suos díligant, \
prudéntes, castas, sóbrias, domus curam habéntes, benígnas, súbditas viris suis, ut non blasphemétur verbum Dei. \
Júvenes simíliter hortáre ut sóbrii sint. \
In ómnibus teípsum præbe exémplum bonórum óperum, in doctrína, in integritáte, in gravitáte, \
verbum sanum, irreprehensíbile: ut is qui ex advérso est, vereátur, nihil habens malum dícere de nobis.")

         ;; ── Nocturn II: St. Maximus ──

         (:ref "Hom. 78, de S. Eusebio 2"
          :source "Sermo sancti Maxími Epíscopi"
          :text "\
Ad sancti ac beatíssimi Patris nostri N., cujus hódie festa celebrámus, laudes addidísse áliquid, \
decerpsísse est; síquidem virtútem ejus grátia, non sermónibus exponénda est, sed opéribus comprobánda. \
Cum enim dicat Scriptúra: Glória patris est fílius sápiens; \
quantæ hujus sunt glóriæ, qui tantórum filiórum sapiéntia et devotióne lætátur? \
In Christo enim Jesu per Evangélium ipse nos génuit.")

         (:ref "Hom. 78, de S. Eusebio 2"
          :source "Sermo sancti Maxími Epíscopi"
          :text "\
Quidquid ígitur in hac sancta plebe potest esse virtútis et grátiæ, de hoc, quasi quodam fonte lucidíssimo, \
ómnium rivulórum púritas emanávit. Etenim, quia castitátis pollébat vigóre, \
quia abstinéntiæ gloriabátur angústiis, quia blandiméntis erat prǽditus lenitátis, \
ómnium cívium in Deum provocávit afféctum; quia Pontíficis administratióne fulgébat, \
plures e discípulis relíquit sui sacerdótii successóres.")

         (:ref "Hom. 78, de S. Eusebio 2"
          :source "Sermo sancti Maxími Epíscopi"
          :text "\
Bene et cóngrue in hac die, quam nobis beáti Patris nostri N. ad paradísum tránsitus exsultábilem reddit, \
præséntis Psalmi versículum decantávimus: In memória ætérna erit justus. \
Digne enim in memóriam vértitur hóminum, qui ad gáudium tránsiit Angelórum. \
Dicit sermo divínus: Ne laudes hóminem in vita sua; tamquam si díceret: \
Lauda post vitam, magnífica post consummatiónem. \
Dúplici enim ex causa utílius est hóminum magis memóriæ laudem dare quam vitæ: \
ut illo potíssimum témpore mérita sanctitátis extóllas, \
quando nec laudántem adulátio movet, nec laudátum tentat elátio.")

         ;; ── Nocturn III: St. Gregory (Matt 25:14-23) ──

         (:ref "Matt 25:14-23"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Léctio sancti Evangélii, fratres caríssimi, solícite consideráre nos ádmonet, \
ne nos, qui plus céteris in hoc mundo accepísse áliquid cérnimur, \
ab Auctóre mundi grávius inde judicémur. \
Cum enim augéntur dona, ratiónes étiam crescunt donórum. \
Tanto ergo esse humílior atque ad serviéndum Deo prómptior quisque debet ex múnere, \
quanto se obligatiórem esse cónspicit in reddénda ratióne. \
Ecce homo, qui péregre proficíscitur, servos suos vocat, eisque ad negótium talénta partítur. \
Post multum vero témporis positúrus ratiónem revértitur: \
bene operántes pro apportáto lucro remúnerat, servum vero a bono ópere torpéntem damnat.")

         (:ref "Matt 25:14-23"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Quis ítaque iste homo est qui péregre proficíscitur, nisi Redémptor noster, \
qui, in ea carne quam assúmpserat, ábiit in cælum? Carnis enim locus próprius terra est; \
quæ quasi ad peregrína dúcitur, dum per Redemptórem nostrum in cælo collocátur. \
Sed homo iste, péregre proficíscens, servis suis bona sua trádidit; \
quia fidélibus suis spirituália dona concéssit. \
Et uni quidem quinque talénta, álii duo, álii vero commísit unum. \
Quinque étenim sunt córporis sensus, vidélicet: visus, audítus, gustus, odorátus et tactus. \
Quinque ergo taléntis, donum quinque sénsuum, id est, exteriórum sciéntia, exprímitur. \
Duóbus vero, intelléctus et operátio designátur. \
Uníus autem talénti nómine, intelléctus tantúmmodo designátur.")

         (:ref "Matt 25:14-23"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Sed is, qui quinque talénta accéperat, ália quinque lucrátus est: \
quia sunt nonnúlli, qui, etsi intérna ac mýstica penetráre nésciunt, \
pro intentióne tamen supérnæ pátriæ docent recta quos possunt; \
de ipsis exterióribus, quæ accepérunt, duplum taléntum portant; \
dumque se a carnis petulántia et a terrenárum rerum ámbitu atque a visibílium voluptáte custódiunt, \
ab his étiam álios admonéndo compéscunt. \
Et sunt nonnúlli, qui, quasi duóbus taléntis ditáti, intelléctum atque operatiónem percípiunt, \
subtília de intérnis intélligunt, mira in exterióribus operántur; \
cumque et intelligéndo et operándo áliis prǽdicant, quasi duplicátum de negótio lucrum repórtant.")
         )  ; end lessons

        :responsories
        (
         (:respond "Euge, serve bone et fidélis, quia in pauca fuísti fidélis, supra multa te constítuam:"
          :verse "Dómine, quinque talénta tradidísti mihi, ecce ália quinque superlucrátus sum."
          :repeat "Intra in gáudium Dómini tui.")
         (:respond "Ecce sacérdos magnus, qui in diébus suis plácuit Deo:"
          :verse "Benedictiónem ómnium géntium dedit illi, et testaméntum suum confirmávit super caput ejus."
          :repeat "Ideo jurejurándo fecit illum Dóminus créscere in plebem suam.")
         (:respond "Jurávit Dóminus, et non pœnitébit eum:"
          :verse "Dixit Dóminus Dómino meo, Sede a dextris meis."
          :repeat "Tu es sacérdos in ætérnum secúndum órdinem Melchísedech."
          :gloria t)
         (:respond "Invéni David servum meum, óleo sancto meo unxi eum:"
          :verse "Nihil profíciet inimícus in eo, et fílius iniquitátis non nocébit ei."
          :repeat "Manus enim mea auxiliábitur ei.")
         (:respond "Pósui adjutórium super poténtem, et exaltávi eléctum de plebe mea:"
          :verse "Invéni David servum meum, óleo sancto meo unxi eum."
          :repeat "Manus enim mea auxiliábitur ei.")
         (:respond "Iste est, qui ante Deum magnas virtútes operátus est, et omnis terra doctrína ejus repléta est:"
          :verse "Iste est, qui contémpsit vitam mundi, et pervénit ad cæléstia regna."
          :repeat "Ipse intercédat pro peccátis ómnium populórum."
          :gloria t)
         (:respond "Amávit eum Dóminus, et ornávit eum: stolam glóriæ índuit eum,"
          :verse "Induit eum Dóminus lorícam fídei, et ornávit eum."
          :repeat "Et ad portas paradísi coronávit eum.")
         (:respond "Sint lumbi vestri præcíncti, et lucérnæ ardéntes in mánibus vestris:"
          :verse "Vigiláte ergo, quia nescítis qua hora Dóminus vester ventúrus sit."
          :repeat "Et vos símiles homínibus exspectántibus dóminum suum, quando revertátur a núptiis."
          :gloria t)
         )

        ;; ── Vespers I ─────────────────────────────────────────────
        :vespers-psalms ((ecce-sacerdos-magnus . 109)
                         (non-est-inventus . 110)
                         (ideo-jurejurando . 111)
                         (sacerdotes-dei . 112)
                         (serve-bone-et-fidelis . 116))
        :vespers-hymn iste-confessor
        :vespers-capitulum (:ref "Sir 44:16-17"
                            :text "Ecce sacérdos magnus, qui in diébus suis plácuit Deo, et invéntus est justus: et in témpore iracúndiæ factus est reconciliátio.")
        :vespers-versicle ("Amávit eum Dóminus, et ornávit eum."
                           "Stolam glóriæ índuit eum.")
        :vespers-versicle-en ("The Lord loved him and beautified him."
                              "He clothed him with a robe of glory.")
        :magnificat-antiphon sacerdos-et-pontifex

        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((ecce-sacerdos-magnus . 92)
                       (non-est-inventus . 99)
                       (ideo-jurejurando . 62)
                       (sacerdotes-dei . 210)
                       (serve-bone-et-fidelis . 148))
        :lauds-hymn jesu-redemptor-omnium-perpes
        :lauds-capitulum (:ref "Sir 44:16-17"
                          :text "Ecce sacérdos magnus, qui in diébus suis plácuit Deo, et invéntus est justus: et in témpore iracúndiæ factus est reconciliátio.")
        :lauds-versicle ("Justum dedúxit Dóminus per vias rectas."
                         "Et osténdit illi regnum Dei.")
        :lauds-versicle-en ("The Lord guided the just in right paths."
                            "And showed him the kingdom of God.")
        :benedictus-antiphon euge-serve-bone

        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Sir 45:19-20"
                          :text "Fungi sacerdótio, et habére laudem in nómine ipsíus, et offérre illi incénsum dignum in odórem suavitátis.")
        ;; ── Terce ─────────────────────────────────────────────────
        :terce-responsory-breve (:respond "Amávit eum Dóminus,"
                                 :repeat "Et ornávit eum."
                                 :verse "Stolam glóriæ índuit eum.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "Sir 44:20; 44:22"
                         :text "Non est invéntus símilis illi, qui conserváret legem Excélsi: ídeo jurejurándo fecit illum Dóminus créscere in plebem suam.")
        :sext-responsory-breve (:respond "Elégit eum Dóminus"
                                :repeat "Sacerdótem sibi."
                                :verse "Ad sacrificándum ei hóstiam laudis.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Tu es sacérdos"
                                :repeat "In ætérnum."
                                :verse "Secúndum órdinem Melchísedech.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms nil
        :vespers2-versicle nil
        :vespers2-versicle-en nil
        :magnificat2-antiphon amavit-eum-dominus
        ))  ; end C4


    ;; ════════════════════════════════════════════════════════════════════
    ;; C5 — COMMUNE CONFESSORIS NON PONTIFICIS
    ;; Inherits from C4: same psalms, antiphons, hymn, lessons, responsories.
    ;; Different nocturn versicles.
    ;; ════════════════════════════════════════════════════════════════════

    (C5
     . (:invitatory regem-confessorum-dominum
        :hymn iste-confessor
        :psalms-1 ((beatus-vir-qui-in-lege-meditatur . 1)
                   (beatus-iste-sanctus . 2)
                   (tu-es-gloria-mea . 3))
        :psalms-2 ((invocantem-exaudivit . 4)
                   (laetentur-omnes-qui-sperant . 5)
                   (domine-dominus-noster-quam . 8))
        :psalms-3 ((domine-iste-sanctus . 14)
                   (vitam-petiit-a-te . 20)
                   (hic-accipiet-benedictionem . 23))
        :versicle-1 ("Amávit eum Dóminus, et ornávit eum."
                     "Stolam glóriæ índuit eum.")
        :versicle-1-en ("The Lord loved him, and adorned him."
                        "He clothed him with a robe of glory.")
        :versicle-2 ("Os justi meditábitur sapiéntiam."
                     "Et lingua ejus loquétur judícium.")
        :versicle-2-en ("The mouth of the just shall meditate wisdom."
                        "And his tongue shall speak judgment.")
        :versicle-3 ("Lex Dei ejus in corde ipsíus."
                     "Et non supplantabúntur gressus ejus.")
        :versicle-3-en ("The law of his God is in his heart."
                        "And his steps shall not be supplanted.")

        :lessons
        (
         ;; ── Nocturn I: Ecclesiasticus ──

         (:ref "Sir 31:8-11"
          :source "De libro Ecclesiastici"
          :text "\
Beátus vir, qui invéntus est sine mácula, et qui post aurum non ábiit, nec sperávit in pecúnia et thesáuris. \
Quis est hic? et laudábimus eum: fecit enim mirabília in vita sua. \
Qui probátus est in illo, et perféctus est, erit illi glória ætérna: \
Qui pótuit tránsgredi, et non est transgréssus; fácere mala, et non fecit: \
ídeo stabilíta sunt bona illíus in Dómino, et eleemósynas illíus enarrábit omnis ecclésia sanctórum.")

         (:ref "Sir 32:18-20; 32:28; 33:1-3"
          :text "\
Qui timet Dóminum excípiet doctrínam ejus: et qui vigiláverint ad illum invénient benedictiónem. \
Qui quærit legem, replébitur ab ea: et qui insidióse agit, scandalizábitur in ea. \
Qui timent Dóminum invénient judícium justum, et justítias quasi lumen accéndent. \
Qui credit Deo atténdit mandátis: et qui confídit in illo non minorábitur. \
Timénti Dóminum non occúrrent mala: sed in tentatióne Deus illum conservábit, et liberábit a malis. \
Sápiens non odit mandáta et justítias, et non illidétur quasi in procélla navis. \
Homo sensátus credit legi Dei, et lex illi fidélis.")

         (:ref "Sir 34:14-20"
          :text "\
Spíritus timéntium Deum quǽritur, et in respéctu illíus benedicétur. \
Spes enim illórum in salvántem illos, et óculi Dei in diligéntes se. \
Qui timet Dóminum nihil trepidábit: et non pavébit, quóniam ipse est spes ejus. \
Timéntis Dóminum, beáta est ánima ejus. Ad quem réspicit, et quis est fortitúdo ejus? \
Óculi Dómini super timéntes eum: protéctor poténtiæ, firmaméntum virtútis, \
tégimen ardóris, et umbráculum meridiáni: deprecátio offensiónis, et adjutórium casus: \
exáltans ánimam, et illúminans óculos, dans sanitátem, et vitam, et benedictiónem.")

         ;; ── Nocturn II: St. John Chrysostom ──

         (:ref "In Orat. de S. Philogonio"
          :source "Sermo sancti Joánnis Chrysóstomi"
          :text "\
Beáti N. dies, cujus festivitátem celebrámus, ad ipsíus recte factórum enarrationem línguam nostram evocavit. \
Síquidem hódie beátus iste ad tranquillam, omnísque perturbationis expertem vitam tránsiit: \
eóque navigium áppulit, ubi deínceps non póterit metuere naufragium, \
nec ullam ánimi perturbationem, aut dolórem. \
Et quid mirum est, si locus ille purus est ab omni molestia ánimi, \
cum Paulus homínibus adhuc in hac vita degentibus loquens dicat: \
Semper gaudéte, sine intermissióne orate?")

         (:ref "In Orat. de S. Philogonio"
          :source "Sermo sancti Joánnis Chrysóstomi"
          :text "\
Quod si hic, ubi morbi, ubi insectatiónes, ubi præmaturæ mortes, ubi calumniæ, ubi invidiæ, \
ubi perturbationes, ubi iræ, ubi cupiditates, ubi innumerábiles insidiæ, \
ubi quotidianæ sollicitudines, ubi perpétua sibíque succedentia mala sunt, \
innúmeros ex omni parte dolóres afferentia, Paulus dixit fíeri posse, ut semper gaudeamus, \
si quis paululum ex rerum mundanarum flúctibus erexerit caput, vitámque suam recte composuerit: \
multo magis, postquam hinc demigraverimus, fácile cómpotes érimus ejus boni, \
cum hæc ómnia sublata fúerint, advérsa valetudo, morbi, peccandi matéria, \
ubi non est meum ac tuum, frígidum illud verbum, \
et quidquid est malórum in vitam nostram invehens, innumeraque gignens bella.")

         (:ref "In Orat. de S. Philogonio"
          :source "Sermo sancti Joánnis Chrysóstomi"
          :text "\
Quam ob rem maximópere gratulor hujus Sancti felicitáti, quod quamquam translátus est, \
atque hanc, quæ apud nos est, civitátem relíquit, tamen in álteram adscríptus est civitátem, nempe Dei. \
Et digréssus ab hac Ecclésia, ad illam pervénit, quæ est primogenitorum descriptorum in cælis: \
ac relíctis hisce festis, tránsiit ad celebritatem Angelórum. \
Étenim quod et cívitas sursum sit, et Ecclésia, et celebritas, audi Paulum dicéntem: \
Accessistis ad civitátem Dei viventis, Jerúsalem cæléstem, \
et Ecclésiam primitivorum, qui conscripti sunt in cælis, \
et ad multórum millium Angelórum frequentiam.")

         ;; ── Nocturn III: St. Gregory (Luc 12:35-40) ──

         (:ref "Luc 12:35-40"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Sancti Evangélii, fratres caríssimi, apérta vobis est léctio recitata. \
Sed ne alíquibus ipsa ejus planíties alta fortásse videátur, \
eam sub brevitáte transcúrrimus, quátenus ejus exposítio ita nesciéntibus fiat cógnita, \
ut tamen sciéntibus non sit onerósa. Dóminus dicit: Sint lumbi vestri præcíncti. \
Lumbos enim præcíngimus, cum carnis luxúriam per continéntiam coarctámus. \
Sed quia minus est, mala non ágere, nisi étiam quisque stúdeat, et bonis opéribus insudáre, \
prótinus ádditur: Et lucérnæ ardéntes in mánibus vestris. \
Lucérnas quippe ardéntes in mánibus tenémus, cum per bona ópera próximis nostris lucis exémpla monstrámus. \
De quibus profécto opéribus Dóminus dicit: Lúceat lux vestra coram homínibus, \
ut vídeant ópera vestra bona, et gloríficent Patrem vestrum qui in cælis est.")

         (:ref "Luc 12:35-40"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Duo autem sunt, quæ jubéntur, et lumbos restríngere, et lucérnas tenére: \
ut et mundítia sit castitátis in córpore, et lumen veritátis in operatióne. \
Redemptóri étenim nostro unum sine áltero placére nequáquam potest: \
si aut is qui bona agit, adhuc luxúriæ inquinaménta non déserit: \
aut is qui castitáte præéminet, necdum se per bona ópera exércet. \
Nec cástitas ergo magna est sine bono ópere, nec opus bonum est áliquod sine castitáte. \
Sed et si utrúmque ágitur, restat, ut quisquis ille est, spe ad supérnam pátriam tendat, \
et nequáquam se a vítiis pro mundi hujus honestáte contíneat.")

         (:ref "Luc 12:35-40"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Et vos símiles homínibus exspectántibus dóminum suum, quando revertátur a núptiis: \
ut cum vénerit et pulsáverit, conféstim apériant ei. \
Venit quippe Dóminus, cum ad judícium próperat: \
pulsat vero, cum jam per ægritúdinis moléstias esse mortem vicínam desígnat. \
Cui conféstim aperímus, si hunc cum amóre suscípimus. \
Aperíre enim júdici pulsánti non vult, qui exíre de córpore trépidat: \
et vidére eum, quem contempsísse se méminit, júdicem formídat. \
Qui autem de sua spe et operatióne secúrus est, pulsanti conféstim áperit, \
quia lætus júdicem sústinet; et, cum tempus propínquæ mortis advénerit, de glória retributiónis hilaréscit.")
         )  ; end lessons

        :responsories
        (
         ;; Same responsories as C4 (Confessor Bishop)
         (:respond "Euge, serve bone et fidélis, quia in pauca fuísti fidélis, supra multa te constítuam:"
          :verse "Dómine, quinque talénta tradidísti mihi, ecce ália quinque superlucrátus sum."
          :repeat "Intra in gáudium Dómini tui.")
         (:respond "Justus germinábit sicut lílium:"
          :verse "Plantátus in domo Dómini, in átriis domus Dei nostri."
          :repeat "Et florébit in ætérnum ante Dóminum.")
         (:respond "Iste cognóvit justítiam, et vidit mirabília magna, et exorávit Altíssimum:"
          :verse "Iste est qui contémpsit vitam mundi, et pervénit ad cæléstia regna."
          :repeat "Et invéntus est in número Sanctórum."
          :gloria t)
         (:respond "Honéstum fecit illum Dóminus, et custodívit eum ab inimícis, et a seductóribus tutávit illum:"
          :verse "Justum dedúxit Dóminus per vias rectas, et osténdit illi regnum Dei."
          :repeat "Et dedit illi claritátem ætérnam.")
         (:respond "Amávit eum Dóminus, et ornávit eum: stolam glóriæ índuit eum,"
          :verse "Índuit eum Dóminus lorícam fídei, et ornávit eum."
          :repeat "Et ad portas paradísi coronávit eum.")
         (:respond "Iste homo perfécit ómnia quæ locútus est ei Deus, et dixit ad eum: Ingrédere in réquiem meam:"
          :verse "Iste est, qui contémpsit vitam mundi, et pervénit ad cæléstia regna."
          :repeat "Quia te vidi justum coram me ex ómnibus géntibus."
          :gloria t)
         (:respond "Iste est qui ante Deum magnas virtútes operátus est, et de omni corde suo laudávit Dóminum:"
          :verse "Ecce homo sine queréla, verus Dei cultor, ábstinens se ab omni ópere malo, et pérmanens in innocéntia sua."
          :repeat "Ipse intercédat pro peccátis ómnium populórum.")
         (:respond "Sint lumbi vestri præcíncti, et lucérnæ ardéntes in mánibus vestris:"
          :verse "Vigiláte ergo, quia nescítis qua hora Dóminus vester ventúrus sit."
          :repeat "Et vos símiles homínibus exspectántibus dóminum suum, quando revertátur a núptiis."
          :gloria t)
         )

        ;; ── Vespers I ─────────────────────────────────────────────
        :vespers-psalms ((domine-quinque-talenta . 109)
                         (euge-serve-bone-in-modico . 110)
                         (fidelis-servus . 111)
                         (beatus-ille-servus . 112)
                         (serve-bone-et-fidelis . 116))
        :vespers-hymn iste-confessor
        :vespers-capitulum (:ref "Sir 31:8-9"
                            :text "Beátus vir, qui invéntus est sine mácula, et qui post aurum non ábiit, nec sperávit in pecúnia et thesáuris. Quis est hic, et laudábimus eum? fecit enim mirabília in vita sua.")
        :vespers-versicle ("Amávit eum Dóminus, et ornávit eum."
                           "Stolam glóriæ índuit eum.")
        :vespers-versicle-en ("The Lord loved him and beautified him."
                              "He clothed him with a robe of glory.")
        :magnificat-antiphon similabo-eum

        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((domine-quinque-talenta . 92)
                       (euge-serve-bone-in-modico . 99)
                       (fidelis-servus . 62)
                       (beatus-ille-servus . 210)
                       (serve-bone-et-fidelis . 148))
        :lauds-hymn jesu-corona-celsior
        :lauds-capitulum (:ref "Sir 31:8-9"
                          :text "Beátus vir, qui invéntus est sine mácula, et qui post aurum non ábiit, nec sperávit in pecúnia et thesáuris. Quis est hic, et laudábimus eum? fecit enim mirabília in vita sua.")
        :lauds-versicle ("Justum dedúxit Dóminus per vias rectas."
                         "Et osténdit illi regnum Dei.")
        :lauds-versicle-en ("The Lord guided the just in right paths."
                            "And showed him the kingdom of God.")
        :benedictus-antiphon euge-serve-bone-in-pauca

        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Sap 10:10"
                          :text "Justum dedúxit Dóminus per vias rectas, et osténdit illi regnum Dei, et dedit illi sciéntiam sanctórum: honestávit illum in labóribus, et complévit labóres illíus.")
        ;; ── Terce ─────────────────────────────────────────────────
        :terce-responsory-breve (:respond "Amávit eum Dóminus,"
                                 :repeat "Et ornávit eum."
                                 :verse "Stolam glóriæ índuit eum.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "Sir 39:6"
                         :text "Justus cor suum trádidit ad vigilándum dilúculo ad Dóminum, qui fecit illum, et in conspéctu Altíssimi deprecábitur.")
        :sext-responsory-breve (:respond "Os justi"
                                :repeat "Meditábitur sapiéntiam."
                                :verse "Et lingua ejus loquétur judícium.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Lex Dei ejus"
                                :repeat "In corde ipsíus."
                                :verse "Et non supplantabúntur gressus ejus.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms nil
        :vespers2-versicle nil
        :vespers2-versicle-en nil
        :magnificat2-antiphon hic-vir-despiciens
        ))  ; end C5


    ;; ════════════════════════════════════════════════════════════════════
    ;; C6 — COMMUNE VIRGINIS ET MARTYRIS
    ;; Psalms: 8/18/23, 44/45/47, 95/96/97
    ;; Invitatory: Regem Virginum Dominum
    ;; Hymn: Virginis Proles
    ;; ════════════════════════════════════════════════════════════════════

    (C6
     . (:invitatory regem-virginum-dominum
        :hymn virginis-proles
        :psalms-1 ((o-quam-pulchra-est . 8)
                   (ante-torum-hujus-virginis . 18)
                   (revertere-revertere-sunamitis . 23))
        :psalms-2 ((specie-tua-et-pulchritudine . 44)
                   (adjuvabit-eam-deus . 45)
                   (aquae-multae-non-potuerunt . 47))
        :psalms-3 ((nigra-sum . 95)
                   (trahe-me-post-te . 96)
                   (veni-sponsa-christi . 97))
        :versicle-1 ("Spécie tua et pulchritúdine tua."
                     "Inténde, próspere procéde, et regna.")
        :versicle-1-en ("With thy comeliness and thy beauty."
                        "Set out, proceed prosperously, and reign.")
        :versicle-2 ("Adjuvábit eam Deus vultu suo."
                     "Deus in médio ejus, non commovébitur.")
        :versicle-2-en ("God shall help her with his countenance."
                        "God is in the midst of her, she shall not be moved.")
        :versicle-3 ("Elégit eam Deus, et præelégit eam."
                     "In tabernáculo suo habitáre facit eam.")
        :versicle-3-en ("God hath chosen her, and fore-chosen her."
                        "He maketh her to dwell in his tabernacle.")

        :lessons
        (
         ;; ── Nocturn I: 1 Corinthians ──

         (:ref "1 Cor 7:25-31"
          :source "De Epístola prima beáti Pauli Apóstoli ad Corínthios"
          :text "\
De virgínibus præcéptum Dómini non hábeo: consílium autem do, tamquam misericórdiam consecútus a Dómino, \
ut sim fidélis. Exístimo ergo hoc bonum esse propter instántem necessitátem, quóniam bonum est hómini sic esse. \
Alligátus es uxóri? noli quǽrere solutiónem. Solútus es ab uxóre? noli quǽrere uxórem. \
Si autem accéperis uxórem, non peccásti. Et si núpserit virgo, non peccávit. \
Tribulatiónem tamen carnis habébunt hujúsmodi. Ego autem vobis parco. \
Hoc ítaque dico, fratres: Tempus breve est: réliquum est, ut et qui habent uxóres, tamquam non habéntes sint; \
et qui flent, tamquam non flentes; et qui gaudent, tamquam non gaudéntes; \
et qui emunt, tamquam non possidéntes; et qui utúntur hoc mundo, tamquam non utántur; \
prǽterit enim figúra hujus mundi.")

         (:ref "1 Cor 7:32-35"
          :text "\
Volo autem vos sine sollicitúdine esse. Qui sine uxóre est, sollícitus est quæ Dómini sunt, quómodo pláceat Deo. \
Qui autem cum uxóre est, sollícitus est quæ sunt mundi, quómodo pláceat uxóri; et divísus est. \
Et múlier innúpta et virgo cógitat quæ Dómini sunt, ut sit sancta córpore et spíritu. \
Quæ autem nupta est, cógitat quæ sunt mundi, quómodo pláceat viro. \
Porro hoc ad utilitátem vestram dico, non ut láqueum vobis iníciam, \
sed ad id, quod honéstum est, et quod facultátem prǽbeat sine impediménto Dóminum obsecrándi.")

         (:ref "1 Cor 7:36-40"
          :text "\
Si quis autem turpem se vidéri exístimat super vírgine sua, quod sit superadúlta, et ita opórtet fíeri; \
quod vult fáciat: non peccat, si nubat. \
Nam, qui státuit in corde suo firmus, non habens necessitátem, potestátem autem habens suæ voluntátis, \
et hoc judicávit in corde suo, serváre vírginem suam, bene facit. \
Ígitur et qui matrimónio jungit vírginem suam, bene facit; et qui non jungit, mélius facit. \
Múlier alligáta est legi quanto témpore, vir ejus vivit. Quod, si dormíerit vir ejus, liberáta est; \
cui vult nubat, tantum in Dómino. Beátior autem erit, si sic permánserit, \
secúndum meum consílium; puto autem quod et ego Spíritum Dei hábeam.")

         ;; ── Nocturn II: St. Ambrose ──

         (:ref "Lib. 1 de Virg."
          :source "Sermo sancti Ambrósii Epíscopi"
          :text "\
Quóniam hódie natális est Vírginis, invítat nunc integritátis amor, ut áliquid de virginitáte dicámus; \
ne, véluti tránsitu quodam præstrícta videátur, quæ principális est virtus. \
Non enim ídeo laudábilis virgínitas, quia in Martýribus reperítur; sed quia ipsa Mártyres fáciat. \
Quis autem humáno eam possit ingénio comprehéndere, quam nec natúra suis inclúsit légibus? \
aut quis naturáli voce complécti, quod supra usum natúræ sit? \
E cælo accersívit quod imitarétur in terris. \
Nec immérito vivéndi sibi usum quæsívit e cælo, quæ Sponsum sibi invénit in cælo.")

         (:ref "Lib. 1 de Virg."
          :source "Sermo sancti Ambrósii Epíscopi"
          :text "\
Hæc nubes, áëra, Ángelos, sidéraque transgrédiens, Verbum Dei in ipso sinu Patris invénit, \
et toto hausit péctore. Nam quis tantum, cum invénerit, relínquat boni? \
Unguéntum enim exinanítum est nomen tuum; proptérea adolescéntulæ dilexérunt te, \
et attraxérunt te. Postrémo, non meum est illud quóniam, \
Quæ non nubunt neque nubéntur, erunt sicut Ángeli Dei in cælo. \
Nemo ergo mirétur, si Ángelis comparéntur, quæ Angelórum Dómino copulántur.")

         (:ref "Lib. 1 de Virg."
          :source "Sermo sancti Ambrósii Epíscopi"
          :text "\
Quis ígitur neget hanc vitam fluxísse de cælo, quam non fácile invenímus in terris, \
nisi postquam Deus in hæc terréni córporis membra descéndit? \
Tunc in útero Virgo concépit, et Verbum caro factum est, ut caro fíeret Deus. \
Dicet áliquis: Sed étiam Elías nullíus corpórei cóitus fuísse permíxtus cupiditátibus invenítur. \
Ideo ergo curru raptus ad cælum; ídeo cum Dómino appáret in glória; \
ídeo Domínici ventúrus est præcúrsor advéntus.")

         ;; ── Nocturn III: St. Gregory (Matt 25:1-13) ──

         (:ref "Matt 25:1-13"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Sæpe vos, fratres caríssimi, admóneo prava ópera fúgere, mundi hujus inquinaménta devitáre, \
sed hodiérna sancti Evangélii lectióne compéllor dícere, ut, et bona, quæ ágitis, cum magna cautéla teneátis; \
ne per hoc, quod a vobis rectum géritur, favor aut grátia humána requirátur; \
ne appetítus laudis subrépat, et, quod foris osténditur, intus a mercéde vacuétur. \
Ecce enim Redemptóris voce decem vírgines, et omnes dicúntur vírgines, \
et tamen intra beatitúdinis jánuam non omnes sunt recéptæ; \
quia eárum quædam, dum de virginitáte sua glóriam foris éxpetunt, in vasis suis óleum habére noluérunt.")

         (:ref "Matt 25:1-13"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Sed prius quæréndum nobis est quid sit regnum cælórum, aut cur decem virgínibus comparétur, \
quæ étiam vírgines prudéntes et fátuæ dicántur. \
Dum enim cælórum regnum constat quia reprobórum nullus ingréditur, \
étiam fátuis virgínibus cur símile esse perhibétur? \
Sed sciéndum nobis est quod sæpe in sacro elóquio regnum cælórum præséntis témporis Ecclésia dícitur. \
De quo álio in loco Dóminus dicit: Mittet Fílius hóminis Ángelos suos, \
et cólligent de regno ejus ómnia scándala. \
Neque enim in illo regno beatitúdinis, in quo pax summa est, \
inveníri scándala póterunt, quæ colligántur.")

         (:ref "Matt 25:1-13"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
In quinque autem córporis sénsibus unusquísque subsístit; geminátus autem quinárius denárium pérficit. \
Et, quia ex utróque sexu fidélium multitúdo collígitur, \
sancta Ecclésia decem virgínibus símilis esse denuntiátur. \
In qua quia mali cum bonis et réprobi cum eléctis admíxti sunt, \
recte símilis virgínibus prudéntibus et fátuis esse perhibétur. \
Sunt namque pleríque continéntes, qui ab appetítu se exterióri custódiunt \
et spe ad interióra rapiúntur, carnem mácerant, et toto desidério ad supérnam pátriam anhélant, \
ætérna prǽmia éxpetunt, pro labóribus suis recípere laudes humánas nolunt. \
Hi nimírum glóriam suam non in ore hóminum ponunt, sed intra consciéntiam cóntegunt. \
Et sunt pleríque, qui corpus per abstinéntiam afflígunt, \
sed de ipsa sua abstinéntia humános favóres éxpetunt.")
         )  ; end lessons

        :responsories
        (
         (:respond "Veni Sponsa Christi, áccipe corónam, quam tibi Dóminus præparávit in ætérnum; pro cujus amóre sánguinem tuum fudísti,"
          :verse "Veni, elécta mea, et ponam in te thronum meum; quia concupívit Rex spéciem tuam."
          :repeat "Et cum Ángelis in paradísum introísti.")
         (:respond "Diffúsa est grátia in lábiis tuis,"
          :verse "Spécie tua et pulchritúdine tua inténde, próspere procéde, et regna."
          :repeat "Proptérea benedíxit te Deus in ætérnum.")
         (:respond "Spécie tua et pulchritúdine tua"
          :verse "Diffúsa est grátia in lábiis tuis, proptérea benedíxit te Deus in ætérnum."
          :repeat "Inténde, próspere procéde, et regna."
          :gloria t)
         (:respond "Propter veritátem, et mansuetúdinem, et justítiam:"
          :verse "Spécie tua et pulchritúdine tua inténde, próspere procéde, et regna."
          :repeat "Et dedúcet te mirabíliter déxtera tua.")
         (:respond "Dilexísti justítiam, et odísti iniquitátem:"
          :verse "Propter veritátem, et mansuetúdinem, et justítiam."
          :repeat "Proptérea unxit te Deus, Deus tuus, óleo lætítiæ.")
         (:respond "Afferéntur Regi vírgines post eam, próximæ ejus;"
          :verse "Spécie tua et pulchritúdine tua; inténde, próspere procéde, et regna."
          :repeat "Afferéntur tibi in lætítia et exsultatióne."
          :gloria t)
         (:respond "Hæc est Virgo sápiens, quam Dóminus vigilántem invénit, quæ accéptis lampádibus sumpsit secum óleum:"
          :verse "Média nocte clamor factus est: Ecce sponsus venit, exíte óbviam ei."
          :repeat "Et veniénte Dómino, introívit cum eo ad núptias.")
         (:respond "Média nocte clamor factus est:"
          :verse "Prudéntes vírgines, aptáte vestras lámpades."
          :repeat "Ecce sponsus venit, exíte óbviam ei."
          :gloria t)
         )

        ;; ── Vespers I ─────────────────────────────────────────────
        ;; C6 Vespers has its own psalm numbers (not Sunday default)
        :vespers-psalms ((haec-est-virgo-sapiens . 109)
                         (haec-est-virgo-sapiens-quam . 112)
                         (haec-est-quae-nescivit . 121)
                         (veni-electa-mea . 126)
                         (ista-est-speciosa . 147))
        :vespers-hymn jesu-corona-virginum
        :vespers-capitulum (:ref "2 Cor 10:17-18"
                            :text "Fratres: Qui gloriátur, in Dómino gloriétur. Non enim qui seípsum comméndat, ille probátus est; sed quem Deus comméndat.")
        :vespers-versicle ("Spécie tua et pulchritúdine tua."
                           "Inténde, próspere procéde, et regna.")
        :vespers-versicle-en ("In thy comeliness and thy beauty."
                              "Go forward, fare prosperously, and reign.")
        :magnificat-antiphon veni-sponsa-christi

        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((haec-est-virgo-sapiens . 92)
                       (haec-est-virgo-sapiens-quam . 99)
                       (haec-est-quae-nescivit . 62)
                       (veni-electa-mea . 210)
                       (ista-est-speciosa . 148))
        :lauds-hymn jesu-corona-virginum
        :lauds-capitulum (:ref "2 Cor 10:17-18"
                          :text "Fratres: Qui gloriátur, in Dómino gloriétur. Non enim qui seípsum comméndat, ille probátus est; sed quem Deus comméndat.")
        :lauds-versicle ("Diffúsa est grátia in lábiis tuis."
                         "Proptérea benedíxit te Deus in ætérnum.")
        :lauds-versicle-en ("Grace is poured into thy lips."
                            "Therefore God hath blessed thee for ever.")
        :benedictus-antiphon simile-est-regnum

        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Sir 51:13-14"
                          :text "Dómine, Deus meus, exaltásti super terram habitatiónem meam, et pro morte defluénte deprecáta sum. Invocávi Dóminum, Patrem Dómini mei, ut non derelínquat me in die tribulatiónis meæ, et in témpore superbórum sine adjutório.")
        ;; ── Terce ─────────────────────────────────────────────────
        :terce-responsory-breve (:respond "Spécie tua"
                                 :repeat "Et pulchritúdine tua."
                                 :verse "Inténde, próspere procéde, et regna.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "2 Cor 11:2"
                         :text "Æmulor enim vos Dei æmulatióne. Despóndi enim vos uni viro vírginem castam exhibére Christo.")
        :sext-responsory-breve (:respond "Adjuvábit eam"
                                :repeat "Deus vultu suo."
                                :verse "Deus in médio ejus, non commovébitur.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Elégit eam Deus,"
                                :repeat "Et præelégit eam."
                                :verse "In tabernáculo suo habitáre facit eam.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms nil
        :vespers2-versicle nil
        :vespers2-versicle-en nil
        :magnificat2-antiphon veni-sponsa-christi
        ))  ; end C6


    ;; ════════════════════════════════════════════════════════════════════
    ;; C7 — COMMUNE NON VIRGINIS (Holy Women)
    ;; Psalms: 8/18/23, 44/45/47, 95/96/97 (same as C6 framework)
    ;; Invitatory: Laudemus Deum nostrum in confessione beatae N.
    ;; Hymn: Fortem virili pectore
    ;; ════════════════════════════════════════════════════════════════════

    (C7
     . (:invitatory laudemus-deum-nostrum
        :hymn fortem-virili-pectore
        :psalms-1 ((o-quam-pulchra-est . 8)
                   (laeva-ejus . 18)
                   (revertere-revertere-sunamitis . 23))
        :psalms-2 ((specie-tua-et-pulchritudine . 44)
                   (adjuvabit-eam-deus . 45)
                   (aquae-multae-non-potuerunt . 47))
        :psalms-3 ((nigra-sum . 95)
                   (trahe-me-post-te . 96)
                   (veni-sponsa-christi . 97))
        :versicle-1 ("Spécie tua et pulchritúdine tua."
                     "Inténde, próspere procéde, et regna.")
        :versicle-1-en ("With thy comeliness and thy beauty."
                        "Set out, proceed prosperously, and reign.")
        :versicle-2 ("Adjuvábit eam Deus vultu suo."
                     "Deus in médio ejus, non commovébitur.")
        :versicle-2-en ("God shall help her with his countenance."
                        "God is in the midst of her, she shall not be moved.")
        :versicle-3 ("Elégit eam Deus, et præelégit eam."
                     "In tabernáculo suo habitáre facit eam.")
        :versicle-3-en ("God hath chosen her, and fore-chosen her."
                        "He maketh her to dwell in his tabernacle.")

        :lessons
        (
         ;; ── Nocturn I: Ecclesiasticus (Sir 51) ──

         (:ref "Sir 51:1-7"
          :source "De libro Ecclesiástici"
          :text "\
Confitébor tibi, Dómine, Rex, et collaudábo te Deum Salvatórem meum. \
Confitébor nómini tuo: quóniam adjútor et protéctor factus es mihi, \
et liberásti corpus meum a perditióne, a láqueo linguæ iníquæ et a lábiis operántium mendácium, \
et in conspéctu astántium factus es mihi adjútor. \
Et liberásti me secúndum multitúdinem misericórdiæ nóminis tui a rugiéntibus, præparátis ad escam: \
de mánibus quæréntium ánimam meam, et de portis tribulatiónum, quæ circumdedérunt me; \
a pressúra flammæ, quæ circúmdedit me, et in médio ignis non sum æstuáta; \
de altitúdine ventris ínferi, et a lingua coinquináta, et a verbo mendácii, \
a rege iníquo, et a lingua injústa.")

         (:ref "Sir 51:8-12"
          :text "\
Laudábit usque ad mortem ánima mea Dóminum, \
et vita mea appropínquans erat in inférno deórsum. \
Circumdedérunt me úndique, et non erat qui adjuváret. \
Respíciens eram ad adjutórium hóminum, et non erat. \
Memoráta sum misericórdiæ tuæ, Dómine, et operatiónis tuæ, quæ a sǽculo sunt: \
quóniam éruis sustinéntes te, Dómine, et líberas eos de mánibus géntium.")

         (:ref "Sir 51:13-17"
          :text "\
Exaltásti super terram habitatiónem meam, et pro morte defluénte deprecáta sum. \
Invocávi Dóminum, Patrem Dómini mei, ut non derelínquat me in die tribulatiónis meæ, \
et in témpore superbórum, sine adjutório. \
Laudábo nomen tuum assídue, et collaudábo illud in confessióne, et exaudíta est orátio mea. \
Et liberásti me de perditióne, et eripuísti me de témpore iníquo. \
Proptérea confitébor, et laudem dicam tibi, et benedícam nómini Dómini.")

         ;; ── Nocturn II: St. Ambrose (De Viduis) ──

         (:ref "De Víduis"
          :source "Ex Libro Sancti Ambrósii Epíscopi de Víduis"
          :text "\
Agrum hunc Ecclésiæ fértilem cerno, nunc integritátis flore vernántem, \
nunc viduitátis gravitáte polléntem, nunc étiam conjúgii frúctibus redundántem. \
Nam, etsi divérsi, uníus tamen agri fructus sunt; \
nec tanta hortórum lília, quantæ arístæ ségetum, méssium spicæ; \
compluriúmque spátia campórum recipiéndis aptántur semínibus, quam rédditis nováles frúctibus feriántur. \
Bona ergo vidúitas, quæ tóties apostólico judício prædicátur. \
Hæc enim magístra fídei, magístra est castitátis.")

         (:ref "De Víduis"
          :source "Ex Libro Sancti Ambrósii Epíscopi de Víduis"
          :text "\
Unde et illi qui deórum suórum adultéria et probra venerántur, \
cælibátus et viduitátis statuére pœnas; \
ut, ǽmuli críminum, mulctárent stúdia virtútum, \
spécie quidem qua fœcunditátem quǽrerent, sed stúdio quo propósitum castitátis abolérent. \
Nam conféctis et miles stipéndiis arma depónit, et relícto offício quod gerébat, \
ad própria veteránus rura dimíttitur; \
ut et ipse exércitæ labóribus vitæ réquiem consequátur \
et álios spes futúræ quiétis subeúndis fáciat opéribus promptióres.")

         (:ref "De Víduis"
          :source "Ex Libro Sancti Ambrósii Epíscopi de Víduis"
          :text "\
Símilis huic vídua, velut eméritis veterána stipéndiis castitátis, \
et si conjúgii arma depónat, domus tamen totíus pacem gubérnat; \
et si vehéndis onéribus otiósa, maritándis tamen junióribus próvida, \
ubi cultus utílior, ubi fructus ubérior sit, quarum cópulam aptiórem seníli gravitáte dispónit. \
Itaque, si maturióribus quam junióribus commítitur ager, cur putes utiliórem nuptam esse quam víduam? \
Quod, si persecutóres fídei persecutóres fuérunt étiam viduitátis; \
útique fidem sequéntibus vidúitas non pro supplício fugiénda est, sed tenénda pro prǽmio.")

         ;; ── Nocturn III: St. Gregory (Matt 13:44-52) ──

         (:ref "Matt 13:44-52"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Cælórum regnum, fratres caríssimi, idcírco terrénis rebus símile dícitur, \
ut, ex his quæ ánimus novit, surgat ad incógnita, quæ non novit: \
quátenus exémplo visibílium se ad invisibília rápiat, \
et, per ea quæ usu dídicit quasi confricátus incaléscat; \
ut per hoc, quod scit notum dilígere, discat et incógnita amáre. \
Ecce enim cælórum regnum thesáuro abscóndito in agro comparátur; \
quem, qui invénit homo, abscóndit, et præ gáudio illíus vadit, \
et vendit univérsa quæ habet, et emit agrum illum.")

         (:ref "Matt 13:44-52"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Qua in re hoc quoque notándum est, quod invéntus thesáurus abscónditur, ut servétur: \
quia stúdium cæléstis desidérii a malígnis spirítibus custodíre non súfficit, \
qui hoc ab humánis láudibus non abscóndit. \
In præsénti étenim vita, quasi in via sumus, qua ad pátriam pérgimus. \
Malígni autem spíritus iter nostrum quasi quidam latrúnculi óbsident. \
Deprædári ergo desíderat, qui thesáurum públice portat in via. \
Hoc autem dico, non ut próximi ópera nostra bona non vídeant, \
cum scriptum sit: Vídeant ópera vestra bona, et gloríficent Patrem vestrum qui in cælis est; \
sed, ut per hoc quod ágimus, laudes extérius non quærámus. \
Sic autem sit opus in público, quátenus inténtio máneat in occúlto; \
ut, et de bono ópere próximis præbeámus exémplum, \
et tamen per intentiónem, qua Deo soli placére quǽrimus, semper optémus secrétum.")

         (:ref "Matt 13:44-52"
          :source "Homilía sancti Gregórii Papæ"
          :text "\
Thesáurus autem cæléste est desidérium; ager vero, in quo thesáurus abscónditur, \
disciplína stúdii cæléstis. Quem profécto agrum, vénditis ómnibus, cómparat, \
qui, voluptátibus carnis renúntians, cuncta sua terréna desidéria \
per disciplínæ cæléstis custódiam calcat: \
ut nihil jam quod caro blandítur, líbeat; nihil, quod carnálem vitam trucídat, spíritus perhorréscat.")
         )  ; end lessons

        :responsories
        (
         (:respond "Veni Sponsa Christi, áccipe corónam, quam tibi Dóminus præparávit in ætérnum; pro cujus amóre sánguinem tuum fudísti,"
          :verse "Veni, elécta mea, et ponam in te thronum meum; quia concupívit Rex spéciem tuam."
          :repeat "Et cum Ángelis in paradísum introísti.")
         (:respond "Diffúsa est grátia in lábiis tuis,"
          :verse "Spécie tua et pulchritúdine tua inténde, próspere procéde, et regna."
          :repeat "Proptérea benedíxit te Deus in ætérnum.")
         (:respond "Spécie tua et pulchritúdine tua"
          :verse "Diffúsa est grátia in lábiis tuis, proptérea benedíxit te Deus in ætérnum."
          :repeat "Inténde, próspere procéde, et regna."
          :gloria t)
         (:respond "Propter veritátem, et mansuetúdinem, et justítiam:"
          :verse "Spécie tua et pulchritúdine tua inténde, próspere procéde, et regna."
          :repeat "Et dedúcet te mirabíliter déxtera tua.")
         (:respond "Dilexísti justítiam, et odísti iniquitátem:"
          :verse "Propter veritátem, et mansuetúdinem, et justítiam."
          :repeat "Proptérea unxit te Deus, Deus tuus, óleo lætítiæ.")
         (:respond "Fallax grátia, et vana est pulchritúdo:"
          :verse "Date ei de fructu mánuum suárum, et laudent eam in portis ópera ejus."
          :repeat "Múlier timens Dóminum, ipsa laudábitur."
          :gloria t)
         (:respond "Os suum apéruit sapiéntiæ, et lex cleméntiæ in lingua ejus: considerávit sémitas domus suæ,"
          :verse "Gustávit et vidit quia bona est negotiátio ejus: non exstinguétur in nocte lucérna ejus."
          :repeat "Et panem otiósa non comédit.")
         (:respond "Regnum mundi et omnem ornátum sǽculi contémpsi, propter amórem Dómini mei Jesu Christi:"
          :verse "Eructávit cor meum verbum bonum: dico ego ópera mea Regi."
          :repeat "Quem vidi, quem amávi, in quem crédidi, quem diléxi."
          :gloria t)
         )

        ;; ── Vespers I ─────────────────────────────────────────────
        ;; C7 Vespers has its own psalm numbers (same as C6)
        :vespers-psalms ((dum-esset-rex . 109)
                         (in-odorem-unguentorum . 112)
                         (jam-hiems-transiit . 121)
                         (veni-electa-mea . 126)
                         (ista-est-speciosa . 147))
        :vespers-hymn fortem-virili-pectore
        :vespers-capitulum (:ref "Sir 51:1-3"
                            :text "Confitébor tibi, Dómine, Rex, et collaudábo te Deum Salvatórem meum. Confitébor nómini tuo: quóniam adjútor et protéctor factus es mihi, et liberásti corpus meum a perditióne.")
        :vespers-versicle ("Spécie tua et pulchritúdine tua."
                           "Inténde, próspere procéde, et regna.")
        :vespers-versicle-en ("In thy comeliness and thy beauty."
                              "Go forward, fare prosperously, and reign.")
        :magnificat-antiphon simile-est-regnum

        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((dum-esset-rex . 92)
                       (in-odorem-unguentorum . 99)
                       (jam-hiems-transiit . 62)
                       (veni-electa-mea . 210)
                       (ista-est-speciosa . 148))
        :lauds-hymn fortem-virili-pectore
        :lauds-capitulum (:ref "Sir 51:1-3"
                          :text "Confitébor tibi, Dómine, Rex, et collaudábo te Deum Salvatórem meum. Confitébor nómini tuo: quóniam adjútor et protéctor factus es mihi, et liberásti corpus meum a perditióne.")
        :lauds-versicle ("Diffúsa est grátia in lábiis tuis."
                         "Proptérea benedíxit te Deus in ætérnum.")
        :lauds-versicle-en ("Grace is poured into thy lips."
                            "Therefore God hath blessed thee for ever.")
        :benedictus-antiphon date-ei

        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Sir 51:8; 51:12"
                          :text "Laudábit usque ad mortem ánima mea Dóminum, quóniam éruis sustinéntes te, et líberas eos de manu angústiæ, Dómine, Deus noster.")
        ;; ── Terce ─────────────────────────────────────────────────
        ;; Inherited from C6
        :terce-responsory-breve (:respond "Spécie tua"
                                 :repeat "Et pulchritúdine tua."
                                 :verse "Inténde, próspere procéde, et regna.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "Sir 51:4-5"
                         :text "Liberásti me secúndum multitúdinem misericórdiæ nóminis tui a rugiéntibus, præparátis ad escam, de mánibus quæréntium ánimam meam, et de multis tribulatiónibus quæ circumdedérunt me.")
        :sext-responsory-breve (:respond "Adjuvábit eam"
                                :repeat "Deus vultu suo."
                                :verse "Deus in médio ejus, non commovébitur.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Elégit eam Deus,"
                                :repeat "Et præelégit eam."
                                :verse "In tabernáculo suo habitáre facit eam.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms nil
        :vespers2-versicle nil
        :vespers2-versicle-en nil
        :magnificat2-antiphon manum-suam
        ))  ; end C7


    ;; ════════════════════════════════════════════════════════════════════
    ;; C11 — COMMUNE FESTORUM B.M.V.
    ;; Psalms: Matins uses 8/18/23, 44/45/47(C6), 86/95/96/97(BVM proper)
    ;; Invitatory: Sancta Maria, Dei Genetrix Virgo
    ;; Hymn Matins: Quem terra, pontus, sidera
    ;; Hymn Vespers: Ave maris stella
    ;; Hymn Lauds: O gloriosa virginum
    ;; ════════════════════════════════════════════════════════════════════

    (C11
     . (:invitatory sancta-maria-dei-genetrix-virgo
        :hymn quem-terra-pontus-sidera
        ;; Nocturn I: BVM proper antiphons
        :psalms-1 ((benedicta-tu-in-mulieribus . 8)
                   (sicut-myrrha-electa . 18)
                   (ante-torum . 23))
        ;; Nocturn II: from C6
        :psalms-2 ((specie-tua-et-pulchritudine . 44)
                   (adjuvabit-eam-deus . 45)
                   (aquae-multae-non-potuerunt . 47))
        ;; Nocturn III: BVM proper antiphons
        :psalms-3 ((sicut-laetantium . 86)
                   (gaude-maria-virgo . 95)
                   (dignare-me-laudare-te . 96)
                   (post-partum-virgo . 97))
        ;; Versicles: same as C6
        :versicle-1 ("Spécie tua et pulchritúdine tua."
                     "Inténde, próspere procéde, et regna.")
        :versicle-1-en ("With thy comeliness and thy beauty."
                        "Set out, proceed prosperously, and reign.")
        :versicle-2 ("Adjuvábit eam Deus vultu suo."
                     "Deus in médio ejus, non commovébitur.")
        :versicle-2-en ("God shall help her with his countenance."
                        "God is in the midst of her, she shall not be moved.")
        :versicle-3 ("Elégit eam Deus, et præelégit eam."
                     "In tabernáculo suo habitáre facit eam.")
        :versicle-3-en ("God hath chosen her, and fore-chosen her."
                        "He maketh her to dwell in his tabernacle.")

        :lessons
        (
         ;; ── Nocturn I: Proverbs 8–9 ──

         (:ref "Prov 8:12-17"
          :source "De Parábolis Salomónis"
          :text "\
Ego sapiéntia hábito in consílio et erudítis intérsum cogitatiónibus. \
Timor Dómini odit malum: arrogántiam, et supérbiam, et viam pravam, et os bilíngue detéstor. \
Meum est consílium et ǽquitas, mea est prudéntia, mea est fortitúdo. \
Per me reges regnant, et legum conditóres justa decérnunt; \
per me príncipes ímperant, et poténtes decérnunt justítiam. \
Ego diligéntes me díligo; et qui mane vígilant ad me, invénient me."
          :text-en "\
I wisdom dwell in counsel, and am present in learned thoughts. \
The fear of the Lord hateth evil: I hate arrogance, and pride, and every wicked way, and a mouth with a double tongue. \
Counsel and equity is mine, prudence is mine, strength is mine. \
By me kings reign, and lawgivers decree just things, \
By me princes rule, and the mighty decree justice. \
I love them that love me: and they that in the morning early watch for me, shall find me.")

         (:ref "Prov 8:18-25"
          :text "\
Mecum sunt divítiæ et glória, opes supérbæ et justítia. \
Mélior est enim fructus meus auro et lápide pretióso, et genímina mea argénto elécto. \
In viis justítiæ ámbulo, in médio semitárum judícii, \
ut ditem diligéntes me et thesáuros eórum répleam. \
Dóminus possidébit me in inítio viárum suárum, ántequam quidquam fáceret a princípio. \
Ab ætérno ordináta sum et ex antíquis, ántequam terra fíeret. \
Nondum erant abýssi, et ego jam concépta eram; \
necdum fontes aquárum erúperant, necdum montes gravi mole constíterant; ante colles ego parturiébar."
          :text-en "\
With me are riches and glory, glorious riches and justice. \
For my fruit is better than gold and the precious stone, and my blossoms than choice silver. \
I walk in the way of justice, in the midst of the paths of judgment, \
That I may enrich them that love me, and may fill their treasures. \
The Lord possessed me in the beginning of his ways, before he made any thing from the beginning. \
I was set up from eternity, and of old before the earth was made. \
The depths were not as yet, and I was already conceived. neither had the fountains of waters as yet sprung out: \
The mountains with their huge bulk had not as yet been established: before the hills I was brought forth:")

         (:ref "Prov 8:34-36; 9:1-5"
          :text "\
Beátus homo qui audit me, et qui vígilat ad fores meas cotídie, et obsérvat ad postes óstii mei. \
Qui me invénerit, invéniet vitam, et háuriet salútem a Dómino; \
qui autem in me peccáverit, lædet ánimam suam. Omnes, qui me odérunt, díligunt mortem. \
Sapiéntia ædificávit sibi domum, excídit colúmnas septem. \
Immolávit víctimas suas, míscuit vinum et propósuit mensam suam. \
Misit ancíllas suas ut vocárent ad arcem et ad mœ́nia civitátis: \
Si quis est párvulus, véniat ad me. Et insipiéntibus locúta est: \
Veníte, comédite panem meum, et bíbite vinum quod míscui vobis."
          :text-en "\
Blessed is the man that heareth me, and that watcheth daily at my gates, and waiteth at the posts of my doors. \
He that shall find me, shall find life, and shall have salvation from the Lord: \
But he that shall sin against me, shall hurt his own soul. All that hate me love death. \
Wisdom hath built herself a house, she hath hewn out her seven pillars. \
She hath slain her victims, mingled her wine, and set forth her table. \
She hath sent her maids to invite to the tower, and to the walls of the city: \
Whosoever is a little one, let him come to me. And to the unwise she said: \
Come, eat my bread, and drink the wine which I have mingled for you")

         ;; ── Nocturn II: St. John Chrysostom (Apud Metaphrasten) ──

         (:ref "Apud Metaphrasten"
          :source "Sermo sancti Joánnis Chrysóstomi"
          :text "\
Dei Fílius non dívitem aut locuplétem áliquam féminam sibi matrem elégit, sed beátam Vírginem illam, \
cujus ánima virtútibus ornáta erat. Cum enim beáta María supra omnem humánam natúram castitátem serváret, \
proptérea Christum Dóminum in ventre concépit. Ad hanc ígitur sanctíssimam Vírginem et Dei Matrem accurréntes, \
ejus patrocínii utilitátem assequámur. Itaque, quæcúmque estis vírgines, ad Matrem Dómini confúgite; \
illa enim pulchérrimam, pretiosíssimam et incorruptíbilem possessiónem, patrocínio suo, vobis conservábit."
          :text-en "\
That is wealth, not a woman of substance, but that blessed maiden whose soul was bright with grace. \
It was because Blessed Mary had preserved a superhuman chastity, that she conceived the Lord Jesus Christ in her womb. \
Let us then fly to the most holy maiden, who is Mother of God, that we may gain the help of her patronage. \
Yea, all ye that be virgins, whosoever ye be, run to the Mother of the Lord. \
She will keep for you by her protection your most beautiful, your most precious, and your most enduring possession.")

         (:ref "Apud Metaphrasten"
          :source "Sermo sancti Joánnis Chrysóstomi"
          :text "\
Magnum revéra miráculum, fratres dilectíssimi, fuit beáta semper Virgo María. \
Quid namque illa majus aut illústrius ullo umquam témpore invéntum est, seu aliquándo inveníri póterit? \
Hæc sola cælum ac terram amplitúdine superávit. Quidnam illa sánctius? \
Non Prophétæ, non Apóstoli, non Mártyres, non Patriárchæ, non Angeli, non Throni, non Dominatiónes, \
non Séraphim, non Chérubim; non deníque áliud quidpíam, inter creátas res visíbiles aut invisíbiles, \
majus aut excelléntius inveníri potest. Eádem ancílla Dei est et mater; eádem Virgo et Génetrix."
          :text-en "\
Dearly beloved brethren, the Blessed Virgin Mary was a great wonder. \
What thing greater or more famous than she, hath ever at any time been found, or can be found? \
She alone is greater than heaven and earth. What thing holier than she hath been, or can be found? \
Neither Prophets, nor Apostles, nor Martyrs, nor Patriarchs, nor Angels, nor Thrones, nor Lordships, \
nor Seraphim, nor Cherubim, nor any other creature, visible or invisible, \
can be found that is greater or more excellent than she. She is at once the hand-maid and the parent of God, at once virgin and mother.")

         (:ref "Apud Metaphrasten"
          :source "Sermo sancti Joánnis Chrysóstomi"
          :text "\
Hæc ejus mater est, qui a Patre ante omne princípium génitus fuit; \
quem Angeli et hómines agnóscunt Dóminum rerum ómnium. \
Visne cognóscere quanto Virgo hæc præstántior sit cæléstibus Poténtiis? \
Illæ cum timóre et tremóre assístunt, fáciem velántes suam: \
hæc humánum genus illi offert, quem génuit. Per hanc et peccatórum véniam conséquimur. \
Ave ígitur, mater, cælum, puélla, virgo, thronus. Ecclésiæ nostræ decus, glória et firmaméntum: \
assídue pro nobis precáre Jesum, Fílium tuum et Dóminum nostrum, \
ut per te misericórdiam inveníre in die judícii, et quæ repósita sunt iis qui díligunt Deum \
bona cónsequi possímus, grátia et benignitáte Dómini nostri Jesu Christi: \
cum quo Patri simul et Sancto Spirítui glória, et honor, et impérium, \
nunc et semper in sǽcula sæculórum. Amen."
          :text-en "\
She is the Mother of him who was begotten of the Father before all ages, \
and who is acknowledged by Angels and men to be Lord of all. \
Wouldst thou know how much nobler is this virgin than any of the heavenly powers? \
They stand before Him with fear and trembling, veiling their faces with their wings, \
but she offereth humanity to Him to Whom she gave birth. Through her we obtain the remission of sins. \
Hail, then, O Mother! heaven! damsel! maiden! throne! adornment, and glory, and foundation, of our Church! \
cease not to pray for us to thy Son and our Lord Jesus Christ \
that through thee we may find mercy in the day of judgment, \
and may be able to obtain those good things which God hath prepared for them that love Him, \
by the grace and goodness of our Lord Jesus Christ \
to Whom, with the Father, and the Holy Ghost, be ascribed all glory, and honour, and power, \
now, and for ever and ever. Amen.")

         ;; ── Nocturn III: Luke 11:27-28, Bede ──

         (:ref "Luke 11:27-28"
          :source "Léctio sancti Evangélii secúndum Lucam"
          :text "\
In illo témpore: Loquénte Jesu ad turbas, extóllens vocem quædam múlier de turba dixit illi: \
Beátus venter qui te portávit. Et réliqua.\n\
Homilía sancti Bedæ Venerábilis Presbýteri\n\
Magnæ devotiónis et fídei hæc múlier osténditur, quæ, scribis et pharisǽis Dóminum \
tentántibus simul et blasphemántibus, tanta ejus incarnatiónem præ ómnibus sinceritáte cognóscit, \
tanta fidúcia confitétur, ut et præséntium prócerum calúmniam, \
et futurórum confúndat hæreticórum perfídiam."
          :text-en "\
At that time, as Jesus spoke unto the multitudes, a certain woman of the company \
lifted up her voice and said unto Him: Blessed is the womb that bore thee. And so on.\n\
Homily by the Venerable Bede\n\
It is plain that this was a woman of great earnestness and faith. The Scribes and Pharisees \
were at once tempting and blaspheming the Lord, but this woman so clearly grasped His Incarnation, \
and so bravely confessed the same, that she confounded both the lies of the great men who were present, \
and the faithlessness of the heretics who were yet to come.")

         (:ref "Luke 11:27-28"
          :source "Léctio sancti Evangélii secúndum Lucam"
          :text "\
Sed, si caro Verbi Dei secúndum carnem nascéntis a carne Vírginis matris pronuntiátur extránea, \
sine causa venter qui eam portásset, úbera quæ lactássent, beatificántur. \
Dicit autem Apóstolus: Quia misit Deus Fílium suum, factum ex mulíere, factum sub lege. \
Neque audiéndi sunt, qui legéndum putant: Natum ex mulíere, factum sub lege, \
sed Factum ex mulíere; quia concéptus ex útero virgináli, \
carnem non de níhilo, non aliúnde, sed matérna traxit ex carne."
          :text-en "\
If we shall say that the Flesh, Wherewith the Son of God was born in the flesh, \
was something outside of the flesh of the Virgin His Mother, \
without reason should we bless the womb that bore Him, and the paps which He hath sucked. \
But the Apostle saith: \"God sent forth His Son, made of a woman, made under the law\", \
and they are not to be listened to who read this passage: \"Born of a woman, made under the law.\" \
He was made of a woman, for He was conceived in a virgin's womb, \
and took His Flesh, not from nothing, not from elsewhere, but from the flesh of His Mother.")

         (:ref "Luke 11:27-28"
          :source "Léctio sancti Evangélii secúndum Lucam"
          :text "\
Quinímmo beáti qui áudiunt verbum Dei et custódiunt. \
Pulchre Salvátor attestatióni mulíeris ánnuit, non eam tantúmmodo quæ Verbum Dei \
corporáliter generáre merúerat, sed et omnes qui idem Verbum spiritáliter audítu fídei concípere, \
et boni óperis custódia vel in suo vel in proximórum corde párere et quasi álere studúerint, \
asséverans esse beátos; quia, et éadem Dei Génetrix, \
et inde quidem beáta quia Verbi incarnándi minístra facta est temporális, \
sed inde multo beátior quia ejúsdem semper amándi custos manébat ætérna."
          :text-en "\
Yea, rather, blessed are they that hear the Word of God and keep it. \
How nobly doth the Saviour say \"Yea\" to the woman's blessing, \
declaring also that not only is she blessed who was meet to give bodily birth to the Word of God, \
but that all they who spiritually conceive the same Word by the hearing of faith, \
and, by keeping it through good works, bring it forth and, as it were, carefully nurse it, \
in their own hearts, and in the hearts of their neighbours, are also blessed. \
Yea, and that the very Mother of God herself was blessed in being for a while \
the handmaid of the Word of God made Flesh, but that she was much more blessed in this, \
that through her love she keepeth Him for ever.")
         )  ; end lessons

        :responsories
        (
         (:respond "Sancta et immaculáta virgínitas, quibus te láudibus éfferam, néscio:"
          :verse "Benedícta tu in muliéribus, et benedíctus fructus ventris tui."
          :repeat "Quia quem cæli cápere non póterant, tuo grémio contulísti.")
         (:respond "Congratulámini mihi, omnes qui dilígitis Dóminum: quia cum essem párvula, plácui Altíssimo,"
          :verse "Beátam me dicent omnes generatiónes, quia ancíllam húmilem respéxit Deus."
          :repeat "Et de meis viscéribus génui Deum et hóminem.")
         (:respond "Beáta es, Virgo María, quæ Dóminum portásti, Creatórem mundi:"
          :verse "Ave, María, grátia plena; Dóminus tecum."
          :repeat "Genuísti qui te fecit, et in ætérnum pérmanes Virgo."
          :gloria t)
         (:respond "Sicut cedrus exaltáta sum in Líbano, et sicut cypréssus in monte Sion: quasi myrrha elécta,"
          :verse "Et sicut cinnamómum et bálsamum aromatízans."
          :repeat "Dedi suavitátem odóris.")
         (:respond "Quæ est ista quæ procéssit sicut sol, et formósa tamquam Jerúsalem?"
          :verse "Et sicut dies verni circúmdabant eam flores rosárum et lília convállium."
          :repeat "Vidérunt eam fíliæ Sion, et beátam dixérunt, et regínæ laudavérunt eam.")
         (:respond "Ornátam monílibus fíliam Jerúsalem Dóminus concupívit:"
          :verse "Astitit regína a dextris tuis in vestítu deauráto, circúmdata varietáte."
          :repeat "Et vidéntes eam fíliæ Sion, beatíssimam prædicavérunt, dicéntes:"
          :repeat2 "Unguéntum effúsum nomen tuum."
          :gloria t)
         (:respond "Felix namque es, sacra Virgo María, et omni laude digníssima:"
          :verse "Ora pro pópulo, intérveni pro clero, intercéde pro devóto femíneo sexu: séntiant omnes tuum juvámen, quicúmque célebrant tuam sanctam festivitátem."
          :repeat "Quia ex te ortus est sol justítiæ, Christus, Deus noster.")
         (:respond "Beátam me dicent omnes generatiónes,"
          :verse "Et misericórdia ejus a progénie in progénies timéntibus eum."
          :repeat "Quia fecit mihi Dóminus magna qui potens est, et sanctum nomen ejus."
          :gloria t)
         )

        ;; ── Vespers I ─────────────────────────────────────────────
        :vespers-psalms ((dum-esset-rex . 109)
                         (laeva-ejus . 112)
                         (nigra-sum . 121)
                         (jam-hiems-transiit . 126)
                         (speciosa-facta-es . 147))
        :vespers-hymn ave-maris-stella
        :vespers-capitulum (:ref "Sir 24:14"
                            :text "Ab inítio et ante sǽcula creáta sum, et usque ad futúrum sǽculum non désinam, et in habitatióne sancta coram ipso ministrávi."
                            :text-en "From the beginning, and before the world, was I created, and unto the world to come I shall not cease to be, and in the holy dwelling place I have ministered before him.")
        :vespers-versicle ("Dignáre me laudáre te, Virgo sacráta."
                           "Da mihi virtútem contra hostes tuos.")
        :vespers-versicle-en ("Holy Virgin, my praise by thee accepted be."
                              "Give me strength against thine enemies.")
        :magnificat-antiphon sancta-maria-succurre-miseris

        ;; ── Lauds ─────────────────────────────────────────────────
        :lauds-psalms ((dum-esset-rex . 92)
                       (laeva-ejus . 99)
                       (nigra-sum . 62)
                       (jam-hiems-transiit . 210)
                       (speciosa-facta-es . 148))
        :lauds-hymn o-gloriosa-virginum
        :lauds-capitulum (:ref "Sir 24:14"
                          :text "Ab inítio et ante sǽcula creáta sum, et usque ad futúrum sǽculum non désinam, et in habitatióne sancta coram ipso ministrávi."
                          :text-en "From the beginning, and before the world, was I created, and unto the world to come I shall not cease to be, and in the holy dwelling place I have ministered before him.")
        :lauds-versicle ("Diffúsa est grátia in lábiis tuis."
                         "Proptérea benedíxit te Deus in ætérnum.")
        :lauds-versicle-en ("Grace is poured into thy lips."
                            "Therefore God hath blessed thee for ever.")
        :benedictus-antiphon beata-es-maria

        ;; ── Prime ─────────────────────────────────────────────────
        :prime-capitulum (:ref "Sir 24:19-20"
                          :text "In platéis sicut cinnamómum et bálsamum aromatízans odórem dedi: quasi myrrha elécta, dedi suavitátem odóris."
                          :text-en "As a plane tree by the water in the streets, I gave a sweet smell like cinnamon and aromatical balm: I yielded a sweet odour like the best myrrh.")
        ;; ── Terce ─────────────────────────────────────────────────
        ;; Responsory breve inherited from C6
        :terce-responsory-breve (:respond "Spécie tua"
                                 :repeat "Et pulchritúdine tua."
                                 :verse "Inténde, próspere procéde, et regna.")
        ;; ── Sext ──────────────────────────────────────────────────
        :sext-capitulum (:ref "Sir 24:15-16"
                         :text "Et sic in Sion firmáta sum, et in civitáte sanctificáta simíliter requiévi, et in Jerúsalem potéstas mea. Et radicávi in pópulo honorificáto, et in parte Dei mei heréditas illíus, et in plenitúdine sanctórum deténtio mea."
                         :text-en "And so was I established in Sion, and in the holy city likewise I rested, and my power was in Jerusalem. And I took root in an honourable people, and in the portion of my God his inheritance, and my abode is in the full assembly of saints.")
        :sext-responsory-breve (:respond "Adjuvábit eam"
                                :repeat "Deus vultu suo."
                                :verse "Deus in médio ejus, non commovébitur.")
        ;; ── None ──────────────────────────────────────────────────
        :none-responsory-breve (:respond "Elégit eam Deus,"
                                :repeat "Et præelégit eam."
                                :verse "In tabernáculo suo habitáre facit eam.")
        ;; ── Vespers II ────────────────────────────────────────────
        :vespers2-psalms nil
        :vespers2-versicle ("Dignáre me laudáre te, Virgo sacráta."
                            "Da mihi virtútem contra hostes tuos.")
        :vespers2-versicle-en ("Holy Virgin, my praise by thee accepted be."
                               "Give me strength against thine enemies.")
        :magnificat2-antiphon beatam-me-dicent
        ))  ; end C11

    )  ; end defconst
  "Commune Sanctorum data for the Roman Breviary.
Alist of (COMMUNE-KEY . PLIST) for each base commune.
COMMUNE-KEY is one of: C1, C2, C2a, C3, C4, C5, C6, C7, C11.")


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-commune-get (commune-key)
  "Return the commune data plist for COMMUNE-KEY.
COMMUNE-KEY is one of: C1, C2, C2a, C3, C4, C5, C6, C7, C11.
Returns nil if not found."
  (alist-get commune-key bcp-roman-commune--data))

(defun bcp-roman-commune-matins (commune-key)
  "Return commune Matins data for COMMUNE-KEY.
Same shape as feast-grade Matins data: a plist with :invitatory,
:hymn, :psalms-1/2/3, :versicle-1/2/3, :lessons, :responsories.
Returns nil if COMMUNE-KEY is not found."
  (bcp-roman-commune-get commune-key))

(defun bcp-roman-commune-lesson (commune-key n)
  "Return lesson N (1-based) from commune COMMUNE-KEY.
Returns a plist with :ref, :source, :text."
  (let ((data (bcp-roman-commune-get commune-key)))
    (when data
      (nth (1- n) (plist-get data :lessons)))))

(defun bcp-roman-commune-responsory (commune-key n)
  "Return responsory N (1-based) from commune COMMUNE-KEY.
Returns a plist with :respond, :verse, :repeat, :gloria."
  (let ((data (bcp-roman-commune-get commune-key)))
    (when data
      (nth (1- n) (plist-get data :responsories)))))

(provide 'bcp-roman-commune)

;;; bcp-roman-commune.el ends here
