;;; bcp-roman-lobvm.el --- Little Office of the BVM -*- lexical-binding: t -*-

;;; Commentary:

;; Pre-extracted data and entry point for the Little Office of the
;; Blessed Virgin Mary (Officium Parvum BMV), DA 1911 rubrics.
;;
;; Source: divinum-officium-master Commune/C12.txt and related files.
;;
;; Implements all eight hours: Matins, Lauds, Prime, Terce, Sext,
;; None, Vespers, and Compline.
;;
;; Season keys for text variants:
;;   per-annum, advent, christmastide, eastertide
;; Lent is a sub-period of per-annum with its own Marian antiphon;
;; handled via `bcp-roman-lobvm--marian-season'.

;;; Code:

(require 'cl-lib)
(require 'calendar)
(require 'bcp-calendar)
(require 'bcp-common-roman)
(require 'bcp-common-prayers)
(require 'bcp-roman-ordo)
(require 'bcp-roman-antiphonary)
(require 'bcp-roman-collectarium)
(require 'bcp-roman-responsory)
(require 'bcp-roman-hymnal)
(require 'bcp-liturgy-dispatch)

(declare-function bcp-roman-render--render-office "bcp-roman-render")
(declare-function bcp-office-nav-init "bcp-office-nav")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline psalms (Vulgate, embedded)
;;
;; These three short psalms are fixed for LOBVM Compline and do not vary
;; by season.  Embedded here to keep the Roman Office self-contained.
;; Verse numbers are stripped; Breviary pointing (* † ‡) preserved.

(defconst bcp-roman-lobvm--psalm-128
  '("Sæpe expugnavérunt me a juventúte mea, * dicat nunc Israël."
    "Sæpe expugnavérunt me a juventúte mea: * étenim non potuérunt mihi."
    "Supra dorsum meum fabricavérunt peccatóres: * prolongavérunt iniquitátem suam."
    "Dóminus justus concídit cervíces peccatórum: * confundántur et convertántur retrórsum omnes, qui odérunt Sion."
    "Fiant sicut fænum tectórum: * quod priúsquam evellátur, exáruit:"
    "De quo non implévit manum suam qui metit, * et sinum suum qui manípulos cólligit."
    "Et non dixérunt qui præteríbant: Benedíctio Dómini super vos: * benedíximus vobis in nómine Dómini.")
  "Psalm 128 (Vulg): Sæpe expugnaverunt.")

(defconst bcp-roman-lobvm--psalm-129
  '("De profúndis clamávi ad te, Dómine: * Dómine, exáudi vocem meam:"
    "Fiant aures tuæ intendéntes, * in vocem deprecatiónis meæ."
    "Si iniquitátes observáveris, Dómine: * Dómine, quis sustinébit?"
    "Quia apud te propitiátio est: * et propter legem tuam sustínui te, Dómine."
    "Sustínuit ánima mea in verbo ejus: * sperávit ánima mea in Dómino."
    "A custódia matutína usque ad noctem: * speret Israël in Dómino."
    "Quia apud Dóminum misericórdia: * et copiósa apud eum redémptio."
    "Et ipse rédimet Israël, * ex ómnibus iniquitátibus ejus.")
  "Psalm 129 (Vulg): De profundis.")

(defconst bcp-roman-lobvm--psalm-130
  '("Dómine, non est exaltátum cor meum: * neque eláti sunt óculi mei."
    "Neque ambulávi in magnis: * neque in mirabílibus super me."
    "Si non humíliter sentiébam: * sed exaltávi ánimam meam:"
    "Sicut ablactátus est super matre sua, * ita retribútio in ánima mea."
    "Speret Israël in Dómino, * ex hoc nunc et usque in sǽculum.")
  "Psalm 130 (Vulg): Domine, non est exaltatum.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Vespers psalms (Vulgate, embedded)

(defconst bcp-roman-lobvm--psalm-109
  '("Dixit Dóminus Dómino meo: * Sede a dextris meis:"
    "Donec ponam inimícos tuos, * scabéllum pedum tuórum."
    "Virgam virtútis tuæ emíttet Dóminus ex Sion: * domináre in médio inimicórum tuórum."
    "Tecum princípium in die virtútis tuæ in splendóribus sanctórum: * ex útero ante lucíferum génui te."
    "Jurávit Dóminus, et non pœnitébit eum: * Tu es sacérdos in ætérnum secúndum órdinem Melchísedech."
    "Dóminus a dextris tuis, * confrégit in die iræ suæ reges."
    "Judicábit in natiónibus, implébit ruínas: * conquassábit cápita in terra multórum."
    "De torrénte in via bibet: * proptérea exaltábit caput.")
  "Psalm 109 (Vulg): Dixit Dominus.")

(defconst bcp-roman-lobvm--psalm-112
  '("Laudáte, púeri, Dóminum: * laudáte nomen Dómini."
    "Sit nomen Dómini benedíctum, * ex hoc nunc, et usque in sǽculum."
    "A solis ortu usque ad occásum, * laudábile nomen Dómini."
    "Excélsus super omnes gentes Dóminus, * et super cælos glória ejus."
    "Quis sicut Dóminus, Deus noster, qui in altis hábitat, * et humília réspicit in cælo et in terra?"
    "Súscitans a terra ínopem, * et de stércore érigens páuperem:"
    "Ut cóllocet eum cum princípibus, * cum princípibus pópuli sui."
    "Qui habitáre facit stérilem in domo, * matrem filiórum lætántem.")
  "Psalm 112 (Vulg): Laudate pueri.")

(defconst bcp-roman-lobvm--psalm-121
  '("Lætátus sum in his, quæ dicta sunt mihi: * In domum Dómini íbimus."
    "Stantes erant pedes nostri, * in átriis tuis, Jerúsalem."
    "Jerúsalem, quæ ædificátur ut cívitas: * cujus participátio ejus in idípsum."
    "Illuc enim ascendérunt tribus, tribus Dómini: * testimónium Israël ad confiténdum nómini Dómini."
    "Quia illic sedérunt sedes in judício, * sedes super domum David."
    "Rogáte quæ ad pacem sunt Jerúsalem: * et abundántia diligéntibus te:"
    "Fiat pax in virtúte tua: * et abundántia in túrribus tuis."
    "Propter fratres meos, et próximos meos, * loquébar pacem de te:"
    "Propter domum Dómini, Dei nostri, * quæsívi bona tibi.")
  "Psalm 121 (Vulg): Laetatus sum.")

(defconst bcp-roman-lobvm--psalm-126
  '("Nisi Dóminus ædificáverit domum, * in vanum laboravérunt qui ædíficant eam."
    "Nisi Dóminus custodíerit civitátem, * frustra vígilat qui custódit eam."
    "Vanum est vobis ante lucem súrgere: * súrgite postquam sedéritis, qui manducátis panem dolóris."
    "Cum déderit diléctis suis somnum: * ecce heréditas Dómini fílii: merces, fructus ventris."
    "Sicut sagíttæ in manu poténtis: * ita fílii excussórum."
    "Beátus vir, qui implévit desidérium suum ex ipsis: * non confundétur cum loquétur inimícis suis in porta.")
  "Psalm 126 (Vulg): Nisi Dominus.")

(defconst bcp-roman-lobvm--psalm-147
  '("Lauda, Jerúsalem, Dóminum: * lauda Deum tuum, Sion."
    "Quóniam confortávit seras portárum tuárum: * benedíxit fíliis tuis in te."
    "Qui pósuit fines tuos pacem: * et ádipe fruménti sátiat te."
    "Qui emíttit elóquium suum terræ: * velóciter currit sermo ejus."
    "Qui dat nivem sicut lanam: * nébulam sicut cínerem spargit."
    "Mittit crystállum suam sicut buccéllas: * ante fáciem frígoris ejus quis sustinébit?"
    "Emíttet verbum suum, et liquefáciet ea: * flabit spíritus ejus, et fluent aquæ."
    "Qui annúntiat verbum suum Jacob: * justítias, et judícia sua Israël."
    "Non fecit táliter omni natióni: * et judícia sua non manifestávit eis.")
  "Psalm 147 (Vulg): Lauda Jerusalem.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds psalms (Vulgate, embedded)

(defconst bcp-roman-lobvm--psalm-92
  '("Dóminus regnávit, decórem indútus est: * indútus est Dóminus fortitúdinem, et præcínxit se."
    "Étenim firmávit orbem terræ, * qui non commovébitur."
    "Paráta sedes tua ex tunc: * a sǽculo tu es."
    "Elevavérunt flúmina, Dómine: * elevavérunt flúmina vocem suam."
    "Elevavérunt flúmina fluctus suos, * a vócibus aquárum multárum."
    "Mirábiles elatiónes maris: * mirábilis in altis Dóminus."
    "Testimónia tua credibília facta sunt nimis: * domum tuam decet sanctitúdo, Dómine, in longitúdinem diérum.")
  "Psalm 92 (Vulg): Dominus regnavit.")

(defconst bcp-roman-lobvm--psalm-99
  '("Jubiláte Deo, omnis terra: * servíte Dómino in lætítia."
    "Introíte in conspéctu ejus, * in exsultatióne."
    "Scitóte quóniam Dóminus ipse est Deus: * ipse fecit nos, et non ipsi nos."
    "Pópulus ejus, et oves páscuæ ejus: ‡ introíte portas ejus in confessióne, * átria ejus in hymnis: confitémini illi."
    "Laudáte nomen ejus: quóniam suávis est Dóminus, † in ætérnum misericórdia ejus, * et usque in generatiónem et generatiónem véritas ejus.")
  "Psalm 99 (Vulg): Jubilate Deo.")

(defconst bcp-roman-lobvm--psalm-62
  '("Deus, Deus meus, * ad te de luce vígilo."
    "Sitívit in te ánima mea, * quam multiplíciter tibi caro mea."
    "In terra desérta, et ínvia, et inaquósa: ‡ sic in sancto appárui tibi, * ut vidérem virtútem tuam, et glóriam tuam."
    "Quóniam mélior est misericórdia tua super vitas: * lábia mea laudábunt te."
    "Sic benedícam te in vita mea: * et in nómine tuo levábo manus meas."
    "Sicut ádipe et pinguédine repleátur ánima mea: * et lábiis exsultatiónis laudábit os meum."
    "Si memor fui tui super stratum meum, † in matutínis meditábor in te: * quia fuísti adjútor meus."
    "Et in velaménto alárum tuárum exsultábo, † adhǽsit ánima mea post te: * me suscépit déxtera tua."
    "Ipsi vero in vanum quæsiérunt ánimam meam, † introíbunt in inferióra terræ: * tradéntur in manus gládii, partes vúlpium erunt."
    "Rex vero lætábitur in Deo, † laudabúntur omnes qui jurant in eo: * quia obstrúctum est os loquéntium iníqua.")
  "Psalm 62 (Vulg): Deus, Deus meus.")

(defconst bcp-roman-lobvm--psalm-148
  '("Laudáte Dóminum de cælis: * laudáte eum in excélsis."
    "Laudáte eum, omnes Ángeli ejus: * laudáte eum, omnes virtútes ejus."
    "Laudáte eum, sol et luna: * laudáte eum, omnes stellæ et lumen."
    "Laudáte eum, cæli cælórum: * et aquæ omnes, quæ super cælos sunt, laudent nomen Dómini."
    "Quia ipse dixit, et facta sunt: * ipse mandávit, et creáta sunt."
    "Státuit ea in ætérnum, et in sǽculum sǽculi: * præcéptum pósuit, et non præteríbit."
    "Laudáte Dóminum de terra, * dracónes, et omnes abýssi."
    "Ignis, grando, nix, glácies, spíritus procellárum: * quæ fáciunt verbum ejus:"
    "Montes, et omnes colles: * ligna fructífera, et omnes cedri."
    "Béstiæ, et univérsa pécora: * serpéntes, et vólucres pennátæ:"
    "Reges terræ, et omnes pópuli: * príncipes, et omnes júdices terræ."
    "Júvenes, et vírgines: † senes cum junióribus laudent nomen Dómini: * quia exaltátum est nomen ejus solíus."
    "Conféssio ejus super cælum et terram: * et exaltávit cornu pópuli sui."
    "Hymnus ómnibus sanctis ejus: * fíliis Israël, pópulo appropinquánti sibi.")
  "Psalm 148 (Vulg): Laudate Dominum de caelis.")

(defconst bcp-roman-lobvm--psalm-149
  '("Cantáte Dómino cánticum novum: * laus ejus in ecclésia sanctórum."
    "Lætétur Israël in eo, qui fecit eum: * et fílii Sion exsúltent in rege suo."
    "Laudent nomen ejus in choro: * in týmpano, et psaltério psallant ei:"
    "Quia beneplácitum est Dómino in pópulo suo: * et exaltábit mansuétos in salútem."
    "Exsultábunt sancti in glória: * lætabúntur in cubílibus suis."
    "Exaltatiónes Dei in gútture eórum: * et gládii ancípites in mánibus eórum."
    "Ad faciéndam vindíctam in natiónibus: * increpatiónes in pópulis."
    "Ad alligándos reges eórum in compédibus: * et nóbiles eórum in mánicis férreis."
    "Ut fáciant in eis judícium conscríptum: * glória hæc est ómnibus sanctis ejus.")
  "Psalm 149 (Vulg): Cantate Domino.")

(defconst bcp-roman-lobvm--psalm-150
  '("Laudáte Dóminum in sanctis ejus: * laudáte eum in firmaménto virtútis ejus."
    "Laudáte eum in virtútibus ejus: * laudáte eum secúndum multitúdinem magnitúdinis ejus."
    "Laudáte eum in sono tubæ: * laudáte eum in psaltério, et cíthara."
    "Laudáte eum in týmpano, et choro: * laudáte eum in chordis, et órgano."
    "Laudáte eum in cýmbalis benesonántibus: † laudáte eum in cýmbalis jubilatiónis: * omnis spíritus laudet Dóminum.")
  "Psalm 150 (Vulg): Laudate Dominum in sanctis.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins psalms (Vulgate, embedded)
;;
;; Sunday Nocturn I: Psalms 8, 18, 23 (Vulgate numbering).

(defconst bcp-roman-lobvm--psalm-8
  '("Dómine, Dóminus noster, * quam admirábile est nomen tuum in univérsa terra!"
    "Quóniam eleváta est magnificéntia tua, * super cælos."
    "Ex ore infántium et lacténtium perfecísti laudem propter inimícos tuos, * ut déstruas inimícum et ultórem."
    "Quóniam vidébo cælos tuos, ópera digitórum tuórum: * lunam et stellas, quæ tu fundásti."
    "Quid est homo, quod memor es ejus? * aut fílius hóminis, quóniam vísitas eum?"
    "Minuísti eum paulo minus ab Ángelis, glória et honóre coronásti eum: * et constituísti eum super ópera mánuum tuárum."
    "Ómnia subjecísti sub pédibus ejus, * oves et boves univérsas: ínsuper et pécora campi."
    "Vólucres cæli, et pisces maris, * qui perámbulant sémitas maris."
    "Dómine, Dóminus noster, * quam admirábile est nomen tuum in univérsa terra!")
  "Psalm 8 (Vulg): Domine, Dominus noster.")

(defconst bcp-roman-lobvm--psalm-18
  '("Cæli enárrant glóriam Dei, * et ópera mánuum ejus annúntiat firmaméntum."
    "Dies diéi erúctat verbum, * et nox nocti índicat sciéntiam."
    "Non sunt loquélæ, neque sermónes, * quorum non audiántur voces eórum."
    "In omnem terram exívit sonus eórum: * et in fines orbis terræ verba eórum."
    "In sole pósuit tabernáculum suum: * et ipse tamquam sponsus procédens de thálamo suo:"
    "Exsultávit ut gigas ad curréndam viam, * a summo cælo egréssio ejus:"
    "Et occúrsus ejus usque ad summum ejus: * nec est qui se abscóndat a calóre ejus."
    "Lex Dómini immaculáta, convértens ánimas: * testimónium Dómini fidéle, sapiéntiam præstans párvulis."
    "Justítiæ Dómini rectæ, lætificántes corda: * præcéptum Dómini lúcidum, illúminans óculos."
    "Timor Dómini sanctus, pérmanens in sǽculum sǽculi: * judícia Dómini vera, justificáta in semetípsa."
    "Desiderabília super aurum et lápidem pretiósum multum: * et dulcióra super mel et favum."
    "Étenim servus tuus custódit ea, * in custodiéndis illis retribútio multa."
    "Delícta quis intélligit? ab occúltis meis munda me: * et ab aliénis parce servo tuo."
    "Si mei non fúerint domináti, tunc immaculátus ero: * et emundábor a delícto máximo."
    "Et erunt ut compláceant elóquia oris mei: * et meditátio cordis mei in conspéctu tuo semper."
    "Dómine, adjútor meus, * et redémptor meus.")
  "Psalm 18 (Vulg): Caeli enarrant.")

(defconst bcp-roman-lobvm--psalm-23
  '("Dómini est terra, et plenitúdo ejus: * orbis terrárum, et univérsi qui hábitant in eo."
    "Quia ipse super mária fundávit eum: * et super flúmina præparávit eum."
    "Quis ascéndet in montem Dómini? * aut quis stabit in loco sancto ejus?"
    "Ínnocens mánibus et mundo corde, * qui non accépit in vano ánimam suam, nec jurávit in dolo próximo suo."
    "Hic accípiet benedictiónem a Dómino: * et misericórdiam a Deo, salutári suo."
    "Hæc est generátio quæréntium eum, * quæréntium fáciem Dei Jacob."
    "Attóllite portas, príncipes, vestras, et elevámini, portæ æternáles: * et introíbit Rex glóriæ."
    "Quis est iste Rex glóriæ? * Dóminus fortis et potens: Dóminus potens in prǽlio."
    "Attóllite portas, príncipes, vestras, et elevámini, portæ æternáles: * et introíbit Rex glóriæ."
    "Quis est iste Rex glóriæ? * Dóminus virtútum ipse est Rex glóriæ.")
  "Psalm 23 (Vulg): Domini est terra.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Minor Hours psalms (Vulgate, embedded)

;; Prime: 53, 84, 116

(defconst bcp-roman-lobvm--psalm-53
  '("Deus, in nómine tuo salvum me fac: * et in virtúte tua júdica me."
    "Deus, exáudi oratiónem meam: * áuribus pércipe verba oris mei."
    "Quóniam aliéni insurrexérunt advérsum me, et fortes quæsiérunt ánimam meam: * et non proposuérunt Deum ante conspéctum suum."
    "Ecce enim, Deus ádjuvat me: * et Dóminus suscéptor est ánimæ meæ."
    "Avérte mala inimícis meis: * et in veritáte tua dispérde illos."
    "Voluntárie sacrificábo tibi, * et confitébor nómini tuo, Dómine: quóniam bonum est:"
    "Quóniam ex omni tribulatióne eripuísti me: * et super inimícos meos despéxit óculus meus.")
  "Psalm 53 (Vulg): Deus, in nomine tuo.")

(defconst bcp-roman-lobvm--psalm-84
  '("Benedixísti, Dómine, terram tuam: * avertísti captivitátem Jacob."
    "Remisísti iniquitátem plebis tuæ: * operuísti ómnia peccáta eórum."
    "Mitigásti omnem iram tuam: * avertísti ab ira indignatiónis tuæ."
    "Convérte nos, Deus, salutáris noster: * et avérte iram tuam a nobis."
    "Numquid in ætérnum irascéris nobis? * aut exténdes iram tuam a generatióne in generatiónem?"
    "Deus, tu convérsus vivificábis nos: * et plebs tua lætábitur in te."
    "Osténde nobis, Dómine, misericórdiam tuam: * et salutáre tuum da nobis."
    "Áudiam quid loquátur in me Dóminus Deus: * quóniam loquétur pacem in plebem suam."
    "Et super sanctos suos: * et in eos, qui convertúntur ad cor."
    "Verúmtamen prope timéntes eum salutáre ipsíus: * ut inhábitet glória in terra nostra."
    "Misericórdia, et véritas obviavérunt sibi: * justítia, et pax osculátæ sunt."
    "Véritas de terra orta est: * et justítia de cælo prospéxit."
    "Étenim Dóminus dabit benignitátem: * et terra nostra dabit fructum suum."
    "Justítia ante eum ambulábit: * et ponet in via gressus suos.")
  "Psalm 84 (Vulg): Benedixisti, Domine.")

(defconst bcp-roman-lobvm--psalm-116
  '("Laudáte Dóminum, omnes gentes: * laudáte eum, omnes pópuli:"
    "Quóniam confirmáta est super nos misericórdia ejus: * et véritas Dómini manet in ætérnum.")
  "Psalm 116 (Vulg): Laudate Dominum, omnes gentes.")

;; Terce: 119, 120 (121 already embedded from Vespers)

(defconst bcp-roman-lobvm--psalm-119
  '("Ad Dóminum cum tribulárer clamávi: * et exaudívit me."
    "Dómine, líbera ánimam meam a lábiis iníquis, * et a lingua dolósa."
    "Quid detur tibi, aut quid apponátur tibi * ad linguam dolósam?"
    "Sagíttæ poténtis acútæ, * cum carbónibus desolatóriis."
    "Heu mihi, quia incolátus meus prolongátus est: † habitávi cum habitántibus Cedar: * multum íncola fuit ánima mea."
    "Cum his, qui odérunt pacem, eram pacíficus: * cum loquébar illis, impugnábant me gratis.")
  "Psalm 119 (Vulg): Ad Dominum cum tribularer.")

(defconst bcp-roman-lobvm--psalm-120
  '("Levávi óculos meos in montes, * unde véniet auxílium mihi."
    "Auxílium meum a Dómino, * qui fecit cælum et terram."
    "Non det in commotiónem pedem tuum: * neque dormítet qui custódit te."
    "Ecce, non dormitábit neque dórmiet, * qui custódit Israël."
    "Dóminus custódit te, Dóminus protéctio tua, * super manum déxteram tuam."
    "Per diem sol non uret te: * neque luna per noctem."
    "Dóminus custódit te ab omni malo: * custódiat ánimam tuam Dóminus."
    "Dóminus custódiat intróitum tuum, et éxitum tuum: * ex hoc nunc, et usque in sǽculum.")
  "Psalm 120 (Vulg): Levavi oculos meos.")

;; Sext: 122, 123, 124

(defconst bcp-roman-lobvm--psalm-122
  '("Ad te levávi óculos meos, * qui hábitas in cælis."
    "Ecce, sicut óculi servórum * in mánibus dominórum suórum,"
    "Sicut óculi ancíllæ in mánibus dóminæ suæ: * ita óculi nostri ad Dóminum, Deum nostrum, donec misereátur nostri."
    "Miserére nostri, Dómine, miserére nostri: * quia multum repléti sumus despectióne:"
    "Quia multum repléta est ánima nostra: * oppróbrium abundántibus, et despéctio supérbis.")
  "Psalm 122 (Vulg): Ad te levavi oculos meos.")

(defconst bcp-roman-lobvm--psalm-123
  '("Nisi quia Dóminus erat in nobis, dicat nunc Israël: * nisi quia Dóminus erat in nobis,"
    "Cum exsúrgerent hómines in nos, * forte vivos deglutíssent nos:"
    "Cum irascerétur furor eórum in nos, * fórsitan aqua absorbuísset nos."
    "Torréntem pertransívit ánima nostra: * fórsitan pertransísset ánima nostra aquam intolerábilem."
    "Benedíctus Dóminus * qui non dedit nos in captiónem déntibus eórum."
    "Ánima nostra sicut passer erépta est * de láqueo venántium:"
    "Láqueus contrítus est, * et nos liberáti sumus."
    "Adjutórium nostrum in nómine Dómini, * qui fecit cælum et terram.")
  "Psalm 123 (Vulg): Nisi quia Dominus.")

(defconst bcp-roman-lobvm--psalm-124
  '("Qui confídunt in Dómino, sicut mons Sion: * non commovébitur in ætérnum, qui hábitat in Jerúsalem."
    "Montes in circúitu ejus: ‡ et Dóminus in circúitu pópuli sui, * ex hoc nunc et usque in sǽculum."
    "Quia non relínquet Dóminus virgam peccatórum super sortem justórum: * ut non exténdant justi ad iniquitátem manus suas."
    "Bénefac, Dómine, bonis, * et rectis corde."
    "Declinántes autem in obligatiónes addúcet Dóminus cum operántibus iniquitátem: * pax super Israël.")
  "Psalm 124 (Vulg): Qui confidunt in Domino.")

;; None: 125, 127 (126 already embedded from Vespers)

(defconst bcp-roman-lobvm--psalm-125
  '("In converténdo Dóminus captivitátem Sion: * facti sumus sicut consoláti:"
    "Tunc replétum est gáudio os nostrum: * et lingua nostra exsultatióne."
    "Tunc dicent inter gentes: * Magnificávit Dóminus fácere cum eis."
    "Magnificávit Dóminus fácere nobíscum: * facti sumus lætántes."
    "Convérte, Dómine, captivitátem nostram, * sicut torrens in Austro."
    "Qui séminant in lácrimis, * in exsultatióne metent."
    "Eúntes ibant et flebant, * mitténtes sémina sua."
    "Veniéntes autem vénient cum exsultatióne, * portántes manípulos suos.")
  "Psalm 125 (Vulg): In convertendo Dominus.")

(defconst bcp-roman-lobvm--psalm-127
  '("Beáti, omnes, qui timent Dóminum, * qui ámbulant in viis ejus."
    "Labóres mánuum tuárum quia manducábis: * beátus es, et bene tibi erit."
    "Uxor tua sicut vitis abúndans, * in latéribus domus tuæ."
    "Fílii tui sicut novéllæ olivárum, * in circúitu mensæ tuæ."
    "Ecce, sic benedicétur homo, * qui timet Dóminum."
    "Benedícat tibi Dóminus ex Sion: * et vídeas bona Jerúsalem ómnibus diébus vitæ tuæ."
    "Et vídeas fílios filiórum tuórum, * pacem super Israël.")
  "Psalm 127 (Vulg): Beati, omnes, qui timent Dominum.")

;;;; All LOBVM psalms alist

(defconst bcp-roman-lobvm--psalms
  `((8   . ,bcp-roman-lobvm--psalm-8)
    (18  . ,bcp-roman-lobvm--psalm-18)
    (23  . ,bcp-roman-lobvm--psalm-23)
    (53  . ,bcp-roman-lobvm--psalm-53)
    (62  . ,bcp-roman-lobvm--psalm-62)
    (84  . ,bcp-roman-lobvm--psalm-84)
    (92  . ,bcp-roman-lobvm--psalm-92)
    (99  . ,bcp-roman-lobvm--psalm-99)
    (109 . ,bcp-roman-lobvm--psalm-109)
    (112 . ,bcp-roman-lobvm--psalm-112)
    (116 . ,bcp-roman-lobvm--psalm-116)
    (119 . ,bcp-roman-lobvm--psalm-119)
    (120 . ,bcp-roman-lobvm--psalm-120)
    (121 . ,bcp-roman-lobvm--psalm-121)
    (122 . ,bcp-roman-lobvm--psalm-122)
    (123 . ,bcp-roman-lobvm--psalm-123)
    (124 . ,bcp-roman-lobvm--psalm-124)
    (125 . ,bcp-roman-lobvm--psalm-125)
    (126 . ,bcp-roman-lobvm--psalm-126)
    (127 . ,bcp-roman-lobvm--psalm-127)
    (128 . ,bcp-roman-lobvm--psalm-128)
    (129 . ,bcp-roman-lobvm--psalm-129)
    (130 . ,bcp-roman-lobvm--psalm-130)
    (147 . ,bcp-roman-lobvm--psalm-147)
    (148 . ,bcp-roman-lobvm--psalm-148)
    (149 . ,bcp-roman-lobvm--psalm-149)
    (150 . ,bcp-roman-lobvm--psalm-150))
  "Alist of (VULG-NUM . VERSE-LIST) for all LOBVM psalms.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Canticles

(defconst bcp-roman-lobvm--benedicite
  '(:name "Canticum Trium Puerorum"
    :ref "Dan. 3:57-88, 56"
    :no-gloria t
    :canticle-key benedicite
    :text
    "Benedícite, ómnia ópera Dómini, Dómino: * laudáte et superexaltáte eum in sǽcula.
Benedícite, Ángeli Dómini, Dómino: * benedícite, cæli, Dómino.
Benedícite, aquæ omnes, quæ super cælos sunt, Dómino: * benedícite, omnes virtútes Dómini, Dómino.
Benedícite, sol et luna, Dómino: * benedícite, stellæ cæli, Dómino.
Benedícite, omnis imber et ros, Dómino: * benedícite, omnes spíritus Dei, Dómino.
Benedícite, ignis et æstus, Dómino: * benedícite, frigus et æstus, Dómino.
Benedícite, rores et pruína, Dómino: * benedícite, gelu et frigus, Dómino.
Benedícite, glácies et nives, Dómino: * benedícite, noctes et dies, Dómino.
Benedícite, lux et ténebræ, Dómino: * benedícite, fúlgura et nubes, Dómino.
Benedícat terra Dóminum: * laudet et superexáltet eum in sǽcula.
Benedícite, montes et colles, Dómino: * benedícite, univérsa germinántia in terra, Dómino.
Benedícite, fontes, Dómino: * benedícite, mária et flúmina, Dómino.
Benedícite, cete, et ómnia, quæ movéntur in aquis, Dómino: * benedícite, omnes vólucres cæli, Dómino.
Benedícite, omnes béstiæ et pécora, Dómino: * benedícite, fílii hóminum, Dómino.
Benedícat Israël Dóminum: * laudet et superexáltet eum in sǽcula.
Benedícite, sacerdótes Dómini, Dómino: * benedícite, servi Dómini, Dómino.
Benedícite, spíritus, et ánimæ justórum, Dómino: * benedícite, sancti, et húmiles corde, Dómino.
Benedícite, Ananía, Azaría, Mísaël, Dómino: * laudáte et superexaltáte eum in sǽcula.
Benedicámus Patrem et Fílium cum Sancto Spíritu: * laudémus et superexaltémus eum in sǽcula.
Benedíctus es, Dómine, in firmaménto cæli: * et laudábilis, et gloriósus, et superexaltátus in sǽcula.")
  "Benedicite (Dan. 3:57-88, 56). No Gloria Patri is appended.")

(defconst bcp-roman-lobvm--benedictus
  '(:name "Benedictus"
    :ref "Luc. 1:68-79"
    :canticle-key benedictus
    :text
    "Benedíctus Dóminus, Deus Israël: * quia visitávit, et fecit redemptiónem plebis suæ:
Et eréxit cornu salútis nobis: * in domo David, púeri sui.
Sicut locútus est per os sanctórum, * qui a sǽculo sunt, prophetárum ejus:
Salútem ex inimícis nostris, * et de manu ómnium, qui odérunt nos.
Ad faciéndam misericórdiam cum pátribus nostris: * et memorári testaménti sui sancti.
Jusjurándum, quod jurávit ad Ábraham patrem nostrum, * datúrum se nobis:
Ut sine timóre, de manu inimicórum nostrórum liberáti, * serviámus illi.
In sanctitáte, et justítia coram ipso, * ómnibus diébus nostris.
Et tu, puer, Prophéta Altíssimi vocáberis: * præíbis enim ante fáciem Dómini, paráre vias ejus:
Ad dandam sciéntiam salútis plebi ejus: * in remissiónem peccatórum eórum:
Per víscera misericórdiæ Dei nostri: * in quibus visitávit nos, óriens ex alto:
Illumináre his, qui in ténebris, et in umbra mortis sedent: * ad dirigéndos pedes nostros in viam pacis.")
  "Benedictus (Canticum Zachariæ, Luc. 1:68-79).")

(defconst bcp-roman-lobvm--magnificat
  '(:name "Magnificat"
    :ref "Luc. 1:46-55"
    :canticle-key magnificat
    :text
    "Magníficat * ánima mea Dóminum.
Et exsultávit spíritus meus: * in Deo, salutári meo.
Quia respéxit humilitátem ancíllæ suæ: * ecce enim ex hoc beátam me dicent omnes generatiónes.
Quia fecit mihi magna qui potens est: * et sanctum nomen ejus.
Et misericórdia ejus, a progénie in progénies: * timéntibus eum.
Fecit poténtiam in brácchio suo: * dispérsit supérbos mente cordis sui.
Depósuit poténtes de sede: * et exaltávit húmiles.
Esuriéntes implévit bonis: * et dívites dimísit inánes.
Suscépit Israël púerum suum: * recordátus misericórdiæ suæ.
Sicut locútus est ad patres nostros: * Ábraham, et sémini ejus in sǽcula.")
  "Magnificat (Canticum B.M.V., Luc. 1:46-55).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Vespers antiphons and hymn: now in antiphonary and hymnal registries

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Vespers capitulum, versicle, canticle antiphon, collect

(defconst bcp-roman-lobvm--vespers-capitulum
  '(:ref "Sir 24:14"
    :text "Ab inítio et ante sǽcula creáta sum, et usque ad futúrum \
sǽculum non désinam, et in habitatióne sancta coram ipso ministrávi.")
  "Vespers capitulum: Sir 24:14.")

(defconst bcp-roman-lobvm--vespers-versicle
  '("Diffúsa est grátia in lábiis tuis."
    "Proptérea benedíxit te Deus in ætérnum.")
  "Vespers versicle (from C6 [Versum 2]).")

;; Vespers canticle antiphons → antiphonary (beata-mater-et-intacta, regina-caeli)
;; Vespers collect → collectarium (concede-nos-famulos)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds antiphons: now in antiphonary registry

;; Lauds hymn → hymnal (o-gloriosa-virginum)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds capitulum and versicle

(defconst bcp-roman-lobvm--lauds-capitulum
  '(:ref "Cant 6:8"
    :text "Vidérunt eam fíliæ Sion, et beatíssimam prædicavérunt \
et regínæ laudavérunt eam.")
  "Lauds capitulum: Cant 6:8.")

(defconst bcp-roman-lobvm--lauds-versicle
  '("Benedícta tu in muliéribus."
    "Et benedíctus fructus ventris tui.")
  "Lauds versicle (from C10 [Versum 2]).")

;; Lauds canticle antiphons → antiphonary (beata-dei-genetrix, regina-caeli)
;; Lauds collect → collectarium (deus-qui-de-beatae)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Commemoratio de Sanctis (shared, from C12 [Commemoratio])
;; Omitted under 1955/1962 rubrics; included under DA 1911.

(defconst bcp-roman-lobvm--commemoratio
  (list :antiphon "Sancti Dei omnes, intercédere dignémini pro nostra omniúmque salúte."
        :versicle "Lætámini in Dómino et exsultáte, justi."
        :response "Et gloriámini, omnes recti corde."
        :collect (concat
                  "Prótege, Dómine, pópulum tuum, et, Apostolórum tuórum \
Petri et Pauli et aliórum Apostolórum patrocínio confidéntem, perpétua \
defensióne consérva.\n\n\
Omnes Sancti tui, quǽsumus, Dómine, nos ubíque ádjuvent: ut, dum \
eórum mérita recólimus, patrocínia sentiámus: et pacem tuam nostris \
concéde tempóribus, et ab Ecclésia tua cunctam repélle nequítiam; \
iter, actus et voluntátes nostras et ómnium famulórum tuórum, in \
salútis tuæ prosperitáte dispóne, benefactóribus nostris sempitérna \
bona retríbue, et ómnibus fidélibus defúnctis réquiem ætérnam concéde.\n"
                  bcp-roman-per-dominum))
  "Commemoratio de Sanctis (DA 1911 rubrics).")

;; Minor Hours hymn → hymnal (memento-rerum-conditor)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Prime propers

(defconst bcp-roman-lobvm--prime-capitulum
  '(:ref "Cant 6:9"
    :text "Quæ est ista, quæ progréditur quasi auróra consúrgens, \
pulchra ut luna, elécta ut sol, terríbilis ut castrórum ácies ordináta?")
  "Prime capitulum: Cant 6:9.")

(defconst bcp-roman-lobvm--prime-versicle
  '("Dignáre me laudáre te, Virgo sacráta."
    "Da mihi virtútem contra hostes tuos.")
  "Prime versicle (from C11 [Versum 1]).")

;; Prime collect → collectarium (deus-qui-virginalem)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Terce propers

(defconst bcp-roman-lobvm--terce-capitulum
  '(:ref "Sir 24:15"
    :text "Et sic in Sion firmáta sum, et in civitáte sanctificáta \
simíliter requiévi, et in Jerúsalem potéstas mea.")
  "Terce capitulum: Sir 24:15.")

(defconst bcp-roman-lobvm--terce-versicle
  '("Diffúsa est grátia in lábiis tuis."
    "Proptérea benedíxit te Deus in ætérnum.")
  "Terce versicle (from C6 [Versum 2]).")

;; Terce collect → collectarium (deus-qui-salutis)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sext propers

(defconst bcp-roman-lobvm--sext-capitulum
  '(:ref "Sir 24:16"
    :text "Et radicávi in pópulo honorificáto, et in parte Dei mei \
heréditas illíus, et in plenitúdine sanctórum deténtio mea.")
  "Sext capitulum: Sir 24:16.")

(defconst bcp-roman-lobvm--sext-versicle
  '("Benedícta tu in muliéribus."
    "Et benedíctus fructus ventris tui.")
  "Sext versicle (from C10 [Versum 2]).")

;; Sext collect → collectarium (concede-misericors-deus)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; None propers

(defconst bcp-roman-lobvm--none-capitulum
  '(:ref "Sir 24:19-20"
    :text "In platéis sicut cinnamómum et bálsamum aromatízans odórem \
dedi: quasi myrrha elécta, dedi suavitátem odóris.")
  "None capitulum: Sir 24:19-20.")

(defconst bcp-roman-lobvm--none-versicle
  '("Post partum, Virgo, invioláta permansísti."
    "Dei Génitrix, intercéde pro nobis.")
  "None versicle (from C12 [Verse Nona]).")

;; None collect → collectarium (famulorum-tuorum)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins propers
;;
;; Invitatory, antiphons → antiphonary registry
;; Hymn → hymnal (quem-terra-pontus-sidera)
;; Nocturn versicle, lessons, benedictions stay local.

(defconst bcp-roman-lobvm--matins-nocturn-versicle
  '("Diffúsa est grátia in lábiis tuis."
    "Proptérea benedíxit te Deus in ætérnum.")
  "Versicle after the nocturn psalms (from C6 [Versum 2]).")

;; Lessons (Sirach 24, from C12 [Lectio1-3])
(defconst bcp-roman-lobvm--matins-lectio-1
  '(:ref "Sir 24:11-13"
    :text "In ómnibus réquiem quæsívi, et in hereditáte Dómini morábor. \
Tunc præcépit, et dixit mihi Creátor ómnium: et qui creávit me, \
requiévit in tabernáculo meo. Et dixit mihi: In Jacob inhábita, \
et in Israël hereditáre, et in eléctis meis mitte radíces.")
  "Matins Lectio I: Sir 24:11-13.")

(defconst bcp-roman-lobvm--matins-lectio-2
  '(:ref "Sir 24:15-16"
    :text "Et sic in Sion firmáta sum, et in civitáte sanctificáta simíliter \
requiévi, et in Jerúsalem potéstas mea. Et radicávi in pópulo \
honorificáto, et in parte Dei mei heréditas illíus, et in plenitúdine \
sanctórum deténtio mea.")
  "Matins Lectio II: Sir 24:15-16.")

(defconst bcp-roman-lobvm--matins-lectio-3
  '(:ref "Sir 24:17-20"
    :text "Quasi cedrus exaltáta sum in Líbano, et quasi cypréssus in monte \
Sion: quasi palma exaltáta sum in Cades, et quasi plantátio rosæ in \
Jéricho: quasi olíva speciósa in campis, et quasi plátanus exaltáta \
sum juxta aquam in platéis. Sicut cinnamómum et bálsamum aromatízans \
odórem dedi: quasi myrrha elécta dedi suavitátem odóris.")
  "Matins Lectio III: Sir 24:17-20.")

;; Responsories → responsory registry (sancta-et-immaculata, beata-es-virgo-maria)

;; Benedictions (LOBVM-specific, from C10 [Benedictio])
(defconst bcp-roman-lobvm--matins-benedictiones
  bcp-roman-benedictiones-lobvm
  "Matins benedictions: the three LOBVM-specific forms from C10.")

;; Matins collect → collectarium (deus-qui-de-beatae-per-dominum)

;; Compline antiphons → antiphonary (sub-tuum-praesidium, regina-caeli)
;; Compline hymn → hymnal (memento-rerum-conditor-compl)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline capitulum and versicle

(defconst bcp-roman-lobvm--compline-capitulum
  '(:ref "Sir 24:24"
    :text "Ego mater pulchræ dilectiónis, et timóris, et agnitiónis, \
et sanctæ spei.")
  "Compline capitulum: Sir 24:24.")

(defconst bcp-roman-lobvm--compline-versicle
  '("Ora pro nobis sancta Dei Génetrix."
    "Ut digni efficiámur promissiónibus Christi.")
  "Compline versicle after the capitulum.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Nunc dimittis

(defconst bcp-roman-lobvm--nunc-dimittis
  '(:name "Nunc dimittis"
    :ref "Luc. 2:29-32"
    :canticle-key nunc-dimittis
    :text
    "Nunc dimíttis servum tuum, Dómine, * secúndum verbum tuum in pace:
Quia vidérunt óculi mei * salutáre tuum,
Quod parásti * ante fáciem ómnium populórum,
Lumen ad revelatiónem géntium, * et glóriam plebis tuæ Israël.")
  "The Nunc dimittis (Canticum Simeonis, Luc. 2:29-32).")

;; Compline collect → collectarium (beatae-et-gloriosae)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Season resolution

(defun bcp-roman-lobvm--marian-season (date)
  "Return the Marian antiphon season key for DATE.
DATE is a Gregorian date (MONTH DAY YEAR).
Returns one of: advent, christmastide, lent, eastertide, per-annum.

Note: the Marian antiphon seasons do not coincide exactly with the
liturgical seasons.  In particular, Ave Regina caelorum begins on
Feb 2 (Purification), not Ash Wednesday; and Salve Regina begins
the Saturday after Pentecost, not Trinity Sunday."
  (let* ((month (car date))
         (day   (cadr date))
         (year  (caddr date))
         (feasts (bcp-moveable-feasts year))
         (advent-abs (calendar-absolute-from-gregorian
                      (cdr (assq 'advent-1 feasts))))
         (easter-abs (calendar-absolute-from-gregorian
                      (cdr (assq 'easter feasts))))
         (whit-abs   (calendar-absolute-from-gregorian
                      (cdr (assq 'whitsunday feasts))))
         (abs (calendar-absolute-from-gregorian date))
         ;; Feb 2 of the current year
         (feb2-abs (calendar-absolute-from-gregorian (list 2 2 year)))
         ;; Wednesday of Holy Week = Maundy Thursday - 1
         (holy-wed-abs (- easter-abs 4)))
    (cond
     ;; Advent: first vespers of Advent I through Dec 24
     ((and (>= abs advent-abs)
           (<= month 12)
           (or (< month 12) (<= day 24)))
      'advent)
     ;; Christmastide: Dec 25 through Feb 1
     ((or (and (= month 12) (>= day 25))
          (and (= month 1))
          (and (= month 2) (= day 1)))
      'christmastide)
     ;; Eastertide: Easter through Friday after Pentecost
     ((and (>= abs easter-abs)
           (<= abs (+ whit-abs 5)))
      'eastertide)
     ;; Lent (for Marian antiphon): Feb 2 through Wednesday of Holy Week
     ((and (>= abs feb2-abs)
           (<= abs holy-wed-abs))
      'lent)
     ;; Per annum: everything else (Saturday after Pentecost – Advent)
     (t 'per-annum))))

(defun bcp-roman-lobvm--compline-antiphon-for-season (season)
  "Return the antiphonary incipit symbol for Compline antiphon in SEASON."
  (if (eq season 'eastertide) 'regina-caeli 'sub-tuum-praesidium))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Data resolver
;;
;; Maps ordo step keys to pre-extracted data.  Antiphons, collects, and
;; responsories are looked up from incipit-keyed registries; versicles,
;; capitula, and structural texts remain as local constants.

(defun bcp-roman-lobvm--canticle-antiphon-for-season (hour season)
  "Return the antiphonary incipit symbol for canticle antiphon in HOUR and SEASON.
HOUR is one of `lauds' or `vespers'."
  (if (eq season 'eastertide)
      'regina-caeli
    (if (eq hour 'lauds) 'beata-dei-genetrix 'beata-mater-et-intacta)))

;; Slot → incipit mapping for LOBVM antiphons.
;; Keys are ordo step symbols; values are antiphonary incipit symbols.
(defconst bcp-roman-lobvm--antiphon-map
  '((vespers-antiphon-1 . dum-esset-rex)
    (vespers-antiphon-2 . laeva-ejus)
    (vespers-antiphon-3 . nigra-sum)
    (vespers-antiphon-4 . jam-hiems-transiit)
    (vespers-antiphon-5 . speciosa-facta-es)
    (lauds-antiphon-1   . assumpta-est-maria)
    (lauds-antiphon-2   . maria-virgo-assumpta)
    (lauds-antiphon-3   . in-odorem-unguentorum)
    (lauds-antiphon-4   . benedicta-filia)
    (lauds-antiphon-5   . pulchra-es-et-decora)
    (matins-invitatory   . ave-maria-invitatory)
    (matins-antiphon-1   . benedicta-tu-in-mulieribus)
    (matins-antiphon-2   . sicut-myrrha-electa)
    (matins-antiphon-3   . ante-torum)
    ;; Minor hour antiphons are aliases to Lauds antiphons
    (prime-antiphon      . assumpta-est-maria)
    (terce-antiphon      . maria-virgo-assumpta)
    (sext-antiphon       . in-odorem-unguentorum)
    (none-antiphon       . pulchra-es-et-decora))
  "Map ordo slot keys to antiphonary incipit symbols.")

;; Slot → incipit mapping for LOBVM collects.
(defconst bcp-roman-lobvm--collect-map
  '((vespers-collect  . concede-nos-famulos)
    (lauds-collect    . deus-qui-de-beatae)
    (matins-collect   . deus-qui-de-beatae-per-dominum)
    (prime-collect    . deus-qui-virginalem)
    (terce-collect    . deus-qui-salutis)
    (sext-collect     . concede-misericors-deus)
    (none-collect     . famulorum-tuorum)
    (compline-collect . beatae-et-gloriosae))
  "Map ordo slot keys to collectarium incipit symbols.")

;; Slot → incipit mapping for LOBVM responsories.
(defconst bcp-roman-lobvm--responsory-map
  '((matins-responsory-1 . sancta-et-immaculata)
    (matins-responsory-2 . beata-es-virgo-maria))
  "Map ordo slot keys to responsory incipit symbols.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; English prose texts (Bute 1908 translation)
;;
;; Versicles and composite texts that remain local (not registry material).
;; Antiphons, collects, and responsories have moved to the incipit-keyed
;; registries: bcp-roman-antiphonary.el, bcp-roman-collectarium.el,
;; bcp-roman-responsory.el.

(defconst bcp-roman-lobvm--vespers-versicle-en
  '("Blessed art thou amongst women."
    "And blessed is the fruit of thy womb.")
  "Vespers versicle, English — Bute.")

(defconst bcp-roman-lobvm--lauds-versicle-en
  '("Holy Virgin, my praise by thee accepted be."
    "Give me strength against thine enemies.")
  "Lauds versicle, English — Bute.")

(defconst bcp-roman-lobvm--matins-nocturn-versicle-en
  '("Holy Virgin, my praise by thee accepted be."
    "Give me strength against thine enemies.")
  "Matins nocturn versicle, English — Bute.")

(defconst bcp-roman-lobvm--matins-benedictiones-en
  '("May the prayers and merits of blessed Mary ever Virgin and all the Saints bring us to the kingdom of heaven."
    "May the Virgin Mary with her Loving Offspring bless us."
    "May the Virgin of virgins, intercede for us to the Lord.")
  "Matins benedictions, English — Bute.")

(defconst bcp-roman-lobvm--prime-versicle-en
  '("Holy Virgin, my praise by thee accepted be."
    "Give me strength against thine enemies.")
  "Prime versicle, English — Bute.")

(defconst bcp-roman-lobvm--terce-versicle-en
  '("Grace is poured into thy lips."
    "Therefore God hath blessed thee for ever.")
  "Terce versicle, English — Bute.")

(defconst bcp-roman-lobvm--sext-versicle-en
  '("Blessed art thou amongst women."
    "And blessed is the fruit of thy womb.")
  "Sext versicle, English — Bute.")

(defconst bcp-roman-lobvm--none-versicle-en
  '("After thy delivery, thou still remainest a Virgin undefiled."
    "Mother of God, pray for us.")
  "None versicle, English — Bute.")

(defconst bcp-roman-lobvm--compline-versicle-en
  '("Pray for us, O holy Mother of God."
    "That we may be made worthy of the promises of Christ.")
  "Compline versicle, English — Bute.")

(defconst bcp-roman-lobvm--commemoratio-en
  '(:antiphon "All ye saints of God, vouchsafe to plead for our salvation and for that of all mankind."
    :versicle "Be glad in the Lord and rejoice, ye just."
    :response "And be joyful, all ye that are upright of heart."
    :collect "Shield, O Lord, thy people, and ever keep them in thy care, who put their trust in the pleading of thy Apostles Peter and Paul, and of the other Apostles.\nMay all thy saints, we beseech thee, O Lord, everywhere come to our help, that while we do honor to their merits, we may also enjoy their intercession: grant thy own peace unto our times, and drive away all wickedness from thy Church; direct our way, our actions, and our wishes and those of all thy servants in the way of salvation; to our benefactors render everlasting blessings, and to all the faithful departed grant eternal rest.\nThrough our Lord.")
  "Commemoratio de Sanctis, English — Bute.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Unified resolver

(defun bcp-roman-lobvm--resolve (key season)
  "Resolve data KEY for the current SEASON.
Returns the appropriate text, plist, or data structure for the
ordo step identified by KEY.  Antiphons, collects, and responsories
are resolved via incipit-keyed registries; everything else via
local constants."
  (let ((lang bcp-roman-office-language))
    ;; Seasonal antiphons (dispatch by season → incipit → registry)
    (pcase key
      ('compline-antiphon
       (bcp-roman-antiphonary-get
        (bcp-roman-lobvm--compline-antiphon-for-season season) lang))
      ('vespers-canticle-antiphon
       (bcp-roman-antiphonary-get
        (bcp-roman-lobvm--canticle-antiphon-for-season 'vespers season) lang))
      ('lauds-canticle-antiphon
       (bcp-roman-antiphonary-get
        (bcp-roman-lobvm--canticle-antiphon-for-season 'lauds season) lang))

      ;; Static antiphons (slot → incipit → registry)
      ((guard (alist-get key bcp-roman-lobvm--antiphon-map))
       (bcp-roman-antiphonary-get
        (alist-get key bcp-roman-lobvm--antiphon-map) lang))

      ;; Collects (slot → incipit → registry)
      ((guard (alist-get key bcp-roman-lobvm--collect-map))
       (bcp-roman-collectarium-get
        (alist-get key bcp-roman-lobvm--collect-map) lang))

      ;; Responsories (slot → incipit → registry)
      ((guard (alist-get key bcp-roman-lobvm--responsory-map))
       (bcp-roman-responsory-get
        (alist-get key bcp-roman-lobvm--responsory-map) lang))

      ;; Hymns (already in hymnal registry)
      ('vespers-hymn  (bcp-roman-hymnal-get 'ave-maris-stella lang))
      ('lauds-hymn    (bcp-roman-hymnal-get 'o-gloriosa-virginum lang))
      ('matins-hymn   (bcp-roman-hymnal-get 'quem-terra-pontus-sidera lang))
      ('minor-hymn    (bcp-roman-hymnal-get 'memento-rerum-conditor lang))
      ('compline-hymn (bcp-roman-hymnal-get 'memento-rerum-conditor-compl lang))

      ;; Structural texts from bcp-common-roman.el (not registry material)
      ('jube-domne
       (if (eq lang 'english) (bcp-roman-jube-domne-en) (bcp-roman-jube-domne)))
      ('benedictio-compline
       (if (eq lang 'english) bcp-roman-benedictio-compline-en bcp-roman-benedictio-compline))
      ('ave-maria           bcp-roman-ave-maria)
      ('converte-nos
       (if (eq lang 'english) bcp-roman-converte-nos-en bcp-roman-converte-nos))
      ('divinum-auxilium
       (if (eq lang 'english) bcp-roman-divinum-auxilium-en bcp-roman-divinum-auxilium))
      ('pater-noster
       (plist-get bcp-common-prayers-lords-prayer (if (eq lang 'english) :english :latin)))
      ('credo
       (plist-get bcp-common-prayers-apostles-creed (if (eq lang 'english) :english :latin)))

      ;; Canticles (stay local — special plist shape with :canticle-key)
      ('nunc-dimittis       bcp-roman-lobvm--nunc-dimittis)
      ('benedicite          bcp-roman-lobvm--benedicite)
      ('benedictus          bcp-roman-lobvm--benedictus)
      ('magnificat          bcp-roman-lobvm--magnificat)

      ;; Versicles (stay local — not incipit-keyed)
      ('vespers-versicle
       (if (eq lang 'english) bcp-roman-lobvm--vespers-versicle-en bcp-roman-lobvm--vespers-versicle))
      ('lauds-versicle
       (if (eq lang 'english) bcp-roman-lobvm--lauds-versicle-en bcp-roman-lobvm--lauds-versicle))
      ('matins-nocturn-versicle
       (if (eq lang 'english) bcp-roman-lobvm--matins-nocturn-versicle-en bcp-roman-lobvm--matins-nocturn-versicle))
      ('compline-versicle
       (if (eq lang 'english) bcp-roman-lobvm--compline-versicle-en bcp-roman-lobvm--compline-versicle))
      ('prime-versicle
       (if (eq lang 'english) bcp-roman-lobvm--prime-versicle-en bcp-roman-lobvm--prime-versicle))
      ('terce-versicle
       (if (eq lang 'english) bcp-roman-lobvm--terce-versicle-en bcp-roman-lobvm--terce-versicle))
      ('sext-versicle
       (if (eq lang 'english) bcp-roman-lobvm--sext-versicle-en bcp-roman-lobvm--sext-versicle))
      ('none-versicle
       (if (eq lang 'english) bcp-roman-lobvm--none-versicle-en bcp-roman-lobvm--none-versicle))

      ;; Capitula (stay local — scripture citations with :ref)
      ('vespers-capitulum   bcp-roman-lobvm--vespers-capitulum)
      ('lauds-capitulum     bcp-roman-lobvm--lauds-capitulum)
      ('compline-capitulum  bcp-roman-lobvm--compline-capitulum)
      ('prime-capitulum     bcp-roman-lobvm--prime-capitulum)
      ('terce-capitulum     bcp-roman-lobvm--terce-capitulum)
      ('sext-capitulum      bcp-roman-lobvm--sext-capitulum)
      ('none-capitulum      bcp-roman-lobvm--none-capitulum)

      ;; Lessons and benedictions (stay local)
      ('matins-lectio-1     bcp-roman-lobvm--matins-lectio-1)
      ('matins-lectio-2     bcp-roman-lobvm--matins-lectio-2)
      ('matins-lectio-3     bcp-roman-lobvm--matins-lectio-3)
      ('matins-benedictiones
       (if (eq lang 'english) bcp-roman-lobvm--matins-benedictiones-en bcp-roman-lobvm--matins-benedictiones))

      ;; Commemoratio (composite plist — stays local)
      ('commemoratio
       (if (eq lang 'english) bcp-roman-lobvm--commemoratio-en bcp-roman-lobvm--commemoratio))

      (_ (error "Unknown LOBVM data key: %s" key)))))

(defun bcp-roman-lobvm--psalm-verses (vulg-num)
  "Return the verse list for Vulgate psalm VULG-NUM, or nil."
  (cdr (assq vulg-num bcp-roman-lobvm--psalms)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Entry point

(defconst bcp-roman-lobvm--hour-entry-fns
  '((matins   . bcp-roman-lobvm-matins)
    (lauds    . bcp-roman-lobvm-lauds)
    (vespers  . bcp-roman-lobvm-vespers)
    (compline . bcp-roman-lobvm-compline)
    (prime    . bcp-roman-lobvm-prime)
    (terce    . bcp-roman-lobvm-terce)
    (sext     . bcp-roman-lobvm-sext)
    (none     . bcp-roman-lobvm-none))
  "Map from hour symbol to public entry-point function.")

(defun bcp-roman-lobvm--render-hour (hour ordo buffer-name label &optional date)
  "Render an LOBVM HOUR with ORDO, BUFFER-NAME, LABEL, and optional DATE.
HOUR is a symbol: `matins', `lauds', `prime', `terce', `sext',
`none', `vespers', or `compline'."
  (let* ((date (or date (bcp-roman--current-date)))
         (year  (caddr date))
         (season (bcp-roman-lobvm--marian-season date))
         (marian-data (cdr (assq season
                                   (if (eq bcp-roman-office-language 'english)
                                       bcp-roman-marian-antiphons-en
                                     bcp-roman-marian-antiphons))))
         ;; Penitential season (Ash Wednesday – Holy Saturday) for
         ;; Alleluia suppression — distinct from the Marian antiphon season.
         (feasts (bcp-moveable-feasts year))
         (ash-abs (calendar-absolute-from-gregorian
                   (cdr (assq 'ash-wednesday feasts))))
         (easter-abs (calendar-absolute-from-gregorian
                      (cdr (assq 'easter feasts))))
         (abs (calendar-absolute-from-gregorian date))
         (penitential (and (>= abs ash-abs) (< abs easter-abs))))
    (require 'bcp-roman-render)
    (let ((lang bcp-roman-office-language))
      (bcp-roman-render--render-office
       ordo
       (list :date date
             :season season
             :penitential penitential
             :hour hour
             :language lang
             :marian-antiphon marian-data
             :data-fn (lambda (key)
                        (bcp-roman-lobvm--resolve key season))
             :psalm-fn #'bcp-roman-lobvm--psalm-verses
             :gloria-patri (plist-get bcp-common-prayers-gloria-patri
                                      (intern (format ":%s" lang)))
             :buffer-name buffer-name
             :office-label label)))
    ;; Init navigation mode for refresh/day-navigation
    (require 'bcp-office-nav)
    (let ((entry-fn (alist-get hour bcp-roman-lobvm--hour-entry-fns)))
      (with-current-buffer (get-buffer buffer-name)
        (bcp-office-nav-init
         (decode-time (encode-time 0 0 12
                                   (cadr date) (car date) (caddr date)))
         'roman-lobvm
         (lambda ()
           (let ((d (if (bound-and-true-p bcp-office-nav--override-time)
                        (let ((dt bcp-office-nav--override-time))
                          (list (nth 4 dt) (nth 3 dt) (nth 5 dt)))
                      date)))
             (funcall entry-fn d))))))))

(defun bcp-roman-lobvm-matins (&optional date)
  "Render Matins of the Little Office of the BVM.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-lobvm--render-hour
   'matins
   bcp-roman-lobvm-matins-ordo
   "*Little Office — Matins*"
   "Matutinum — Officium Parvum B.M.V."
   date))

(defun bcp-roman-lobvm-lauds (&optional date)
  "Render Lauds of the Little Office of the BVM.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-lobvm--render-hour
   'lauds
   bcp-roman-lobvm-lauds-ordo
   "*Little Office — Lauds*"
   "Laudes — Officium Parvum B.M.V."
   date))

(defun bcp-roman-lobvm-vespers (&optional date)
  "Render Vespers of the Little Office of the BVM.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-lobvm--render-hour
   'vespers
   bcp-roman-lobvm-vespers-ordo
   "*Little Office — Vespers*"
   "Vesperæ — Officium Parvum B.M.V."
   date))

(defun bcp-roman-lobvm-compline (&optional date)
  "Render Compline of the Little Office of the BVM.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-lobvm--render-hour
   'compline
   bcp-roman-lobvm-compline-ordo
   "*Little Office — Compline*"
   "Completorium — Officium Parvum B.M.V."
   date))

(defun bcp-roman-lobvm-prime (&optional date)
  "Render Prime of the Little Office of the BVM.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-lobvm--render-hour
   'prime
   bcp-roman-lobvm-prime-ordo
   "*Little Office — Prime*"
   "Prima — Officium Parvum B.M.V."
   date))

(defun bcp-roman-lobvm-terce (&optional date)
  "Render Terce of the Little Office of the BVM.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-lobvm--render-hour
   'terce
   bcp-roman-lobvm-terce-ordo
   "*Little Office — Terce*"
   "Tertia — Officium Parvum B.M.V."
   date))

(defun bcp-roman-lobvm-sext (&optional date)
  "Render Sext of the Little Office of the BVM.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-lobvm--render-hour
   'sext
   bcp-roman-lobvm-sext-ordo
   "*Little Office — Sext*"
   "Sexta — Officium Parvum B.M.V."
   date))

(defun bcp-roman-lobvm-none (&optional date)
  "Render None of the Little Office of the BVM.
DATE is a Gregorian date (MONTH DAY YEAR); defaults to today."
  (interactive)
  (bcp-roman-lobvm--render-hour
   'none
   bcp-roman-lobvm-none-ordo
   "*Little Office — None*"
   "Nona — Officium Parvum B.M.V."
   date))

(defun bcp-roman-lobvm (&optional date)
  "Render the Little Office of the BVM for the current hour.
Dispatches based on the time of day:
  Before 4:  Matins
  4–7:       Lauds
  7–9:       Prime
  9–12:      Terce
  12–14:     Sext
  14–17:     None
  17–20:     Vespers
  After 20:  Compline
With optional DATE, renders for that date."
  (interactive)
  (let ((hour (string-to-number (format-time-string "%H"))))
    (cond
     ((< hour 4)  (bcp-roman-lobvm-matins date))
     ((< hour 7)  (bcp-roman-lobvm-lauds date))
     ((< hour 9)  (bcp-roman-lobvm-prime date))
     ((< hour 12) (bcp-roman-lobvm-terce date))
     ((< hour 14) (bcp-roman-lobvm-sext date))
     ((< hour 17) (bcp-roman-lobvm-none date))
     ((< hour 20) (bcp-roman-lobvm-vespers date))
     (t           (bcp-roman-lobvm-compline date)))))

(bcp-liturgy-register-tradition 'roman '1911 #'bcp-roman-lobvm)

(provide 'bcp-roman-lobvm)
;;; bcp-roman-lobvm.el ends here
