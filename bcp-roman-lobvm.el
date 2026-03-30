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
(require 'bcp-liturgy-dispatch)

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
;;;; Vespers antiphons (from C11 [Ant Vespera])

(defconst bcp-roman-lobvm--vespers-antiphon-1
  "Dum esset Rex in accúbitu suo, nardus mea dedit odórem suavitátis."
  "Vespers antiphon 1 (Ps 109).")

(defconst bcp-roman-lobvm--vespers-antiphon-2
  "Læva ejus sub cápite meo, et déxtera illíus amplexábitur me."
  "Vespers antiphon 2 (Ps 112).")

(defconst bcp-roman-lobvm--vespers-antiphon-3
  "Nigra sum, sed formósa, fíliæ Jerúsalem; ídeo diléxit me Rex, et introdúxit me in cubículum suum."
  "Vespers antiphon 3 (Ps 121).")

(defconst bcp-roman-lobvm--vespers-antiphon-4
  "Jam hiems tránsiit, imber ábiit et recéssit: surge, amíca mea, et veni."
  "Vespers antiphon 4 (Ps 126).")

(defconst bcp-roman-lobvm--vespers-antiphon-5
  "Speciósa facta es et suávis in delíciis tuis, sancta Dei Génetrix."
  "Vespers antiphon 5 (Ps 147).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Vespers hymn: Ave maris stella (from C11 [Hymnus Vespera])

(defconst bcp-roman-lobvm--vespers-hymn
  "Ave maris stella,
Dei Mater alma,
Atque semper Virgo,
Felix cæli porta.

Sumens illud Ave
Gabriélis ore,
Funda nos in pace,
Mutans Hevæ nomen.

Solve vincla reis,
Profer lumen cæcis,
Mala nostra pelle,
Bona cuncta posce.

Monstra te esse matrem,
Sumat per te preces,
Qui pro nobis natus,
Tulit esse tuus.

Virgo singuláris,
Inter omnes mitis,
Nos culpis solútos
Mites fac et castos.

Vitam præsta puram,
Iter para tutum,
Ut vidéntes Jesum,
Semper collætémur.

Sit laus Deo Patri,
Summo Christo decus,
Spirítui Sancto,
Tribus honor unus.
Amen."
  "Vespers hymn: Ave maris stella.")

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

(defconst bcp-roman-lobvm--vespers-canticle-antiphon
  "Beáta Mater et intácta Virgo, gloriósa Regína mundi, intercéde pro nobis ad Dóminum."
  "Vespers Magnificat antiphon (per annum).")

(defconst bcp-roman-lobvm--vespers-canticle-antiphon-eastertide
  "Regína cæli, lætáre, allelúja; quia quem meruísti portáre, allelúja; \
resurréxit, sicut dixit, allelúja: ora pro nobis Deum, allelúja."
  "Vespers Magnificat antiphon (Eastertide).")

(defconst bcp-roman-lobvm--vespers-collect
  (concat
   "Concéde nos fámulos tuos, quǽsumus, Dómine Deus, perpétua mentis \
et córporis sanitáte gaudére: et, gloriósa beátæ Maríæ semper Vírginis \
intercessióne, a præsénti liberári tristítia, et ætérna pérfrui lætítia.\n"
   bcp-roman-per-dominum)
  "Vespers collect: Concede nos famulos + Per Dominum.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds antiphons (from C12 [Ant Laudes])

(defconst bcp-roman-lobvm--lauds-antiphon-1
  "Assúmpta est María in cælum: gaudent Angeli, laudántes benedícunt Dóminum."
  "Lauds antiphon 1 (Ps 92).")

(defconst bcp-roman-lobvm--lauds-antiphon-2
  "María Virgo assúmpta est ad æthéreum thálamum, in quo Rex regum stelláto sedet sólio."
  "Lauds antiphon 2 (Ps 99).")

(defconst bcp-roman-lobvm--lauds-antiphon-3
  "In odórem unguentórum tuórum cúrrimus: adolescéntulæ dilexérunt te nimis."
  "Lauds antiphon 3 (Ps 62).")

(defconst bcp-roman-lobvm--lauds-antiphon-4
  "Benedícta fília tu a Dómino: quia per te fructum vitæ communicávimus."
  "Lauds antiphon 4 (Benedicite).")

(defconst bcp-roman-lobvm--lauds-antiphon-5
  "Pulchra es, et decóra, fília Jerúsalem: terríbilis ut castrórum ácies ordináta."
  "Lauds antiphon 5 (Ps 148-150).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds hymn: O gloriosa virginum (from C11 [Hymnus Laudes])

(defconst bcp-roman-lobvm--lauds-hymn
  "O gloriósa vírginum,
Sublímis inter sídera,
Qui te creávit, párvulum
Lacténte nutris úbere.

Quod Heva tristis ábstulit,
Tu reddis almo gérmine:
Intrent ut astra flébiles,
Cæli reclúdis cárdines.

Tu Regis alti jánua
Et aula lucis fúlgida:
Vitam datam per Vírginem,
Gentes redémptæ, pláudite.

Jesu, tibi sit glória,
Qui natus es de Vírgine,
Cum Patre et almo Spíritu,
In sempitérna sǽcula.
Amen."
  "Lauds hymn: O gloriosa virginum.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds capitulum, versicle, canticle antiphon, collect

(defconst bcp-roman-lobvm--lauds-capitulum
  '(:ref "Cant 6:8"
    :text "Vidérunt eam fíliæ Sion, et beatíssimam prædicavérunt \
et regínæ laudavérunt eam.")
  "Lauds capitulum: Cant 6:8.")

(defconst bcp-roman-lobvm--lauds-versicle
  '("Benedícta tu in muliéribus."
    "Et benedíctus fructus ventris tui.")
  "Lauds versicle (from C10 [Versum 2]).")

(defconst bcp-roman-lobvm--lauds-canticle-antiphon
  "Beáta Dei Génetrix, María, Virgo perpétua, templum Dómini, \
sacrárium Spíritus Sancti, sola sine exémplo placuísti Dómino nostro \
Jesu Christo: ora pro pópulo, intérveni pro clero, intercéde pro devóto femíneo sexu."
  "Lauds Benedictus antiphon (per annum).")

(defconst bcp-roman-lobvm--lauds-canticle-antiphon-eastertide
  "Regína cæli, lætáre, allelúja; quia quem meruísti portáre, allelúja; \
resurréxit, sicut dixit, allelúja: ora pro nobis Deum, allelúja."
  "Lauds Benedictus antiphon (Eastertide).")

(defconst bcp-roman-lobvm--lauds-collect
  (concat
   "Deus, qui de beátæ Maríæ Vírginis útero Verbum tuum, Angelo \
nuntiánte, carnem suscípere voluísti: præsta supplícibus tuis; ut, \
qui vere eam Genetrícem Dei crédimus, ejus apud te intercessiónibus \
adjuvémur.\n"
   bcp-roman-per-eumdem)
  "Lauds collect: Deus qui de beatae Mariae + Per eumdem.")

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

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Minor Hours shared hymn
;;
;; All four Little Hours use the same hymn: Memento rerum Conditor
;; (DA form) with Maria Mater gratiae + Nativity doxology.
;; This is the same as the Compline hymn but WITHOUT the Enixa est
;; puerpera stanza.

(defconst bcp-roman-lobvm--minor-hymn
  "Meménto, rerum Cónditor,
Nostri quod olim córporis,
Sacráta ab alvo Vírginis
Nascéndo formam súmpseris.

María Mater grátiæ,
Dulcis Parens cleméntiæ,
Tu nos ab hoste prótege,
Et mortis hora súscipe.

Jesu, tibi sit glória,
Qui natus es de Vírgine,
Cum Patre et almo Spíritu,
In sempitérna sǽcula.
Amen."
  "Minor Hours hymn: Memento rerum Conditor (without Compline stanza).")

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

(defconst bcp-roman-lobvm--prime-collect
  (concat
   "Deus, qui virginálem aulam beátæ Maríæ, in qua habitáres, \
elígere dignátus es: da, quǽsumus; ut, sua nos defensióne munítos, \
jucúndos fácias suæ interésse commemoratióni.\n"
   bcp-roman-qui-vivis)
  "Prime collect: Deus, qui virginalem aulam + Qui vivis.")

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

(defconst bcp-roman-lobvm--terce-collect
  (concat
   "Deus, qui salútis ætérnæ, beátæ Maríæ virginitáte fecúnda, \
humáno géneri prǽmia præstitísti: tríbue, quǽsumus; ut ipsam pro \
nobis intercédere sentiámus, per quam merúimus auctórem vitæ \
suscípere, Dóminum nostrum Jesum Christum Fílium tuum:\n"
   bcp-roman-qui-tecum)
  "Terce collect: Circumcision (Sancti/01-01) + Qui tecum.")

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

(defconst bcp-roman-lobvm--sext-collect
  (concat
   "Concéde, miséricors Deus, fragilitáti nostræ præsídium; ut, qui \
sanctæ Dei Genetrícis memóriam ágimus; intercessiónis ejus auxílio, \
a nostris iniquitátibus resurgámus.\n"
   bcp-roman-per-eumdem)
  "Sext collect: Concede, misericors Deus + Per eumdem.")

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

(defconst bcp-roman-lobvm--none-collect
  (concat
   "Famulórum tuórum, quǽsumus, Dómine, delíctis ignósce: ut qui \
tibi placére de áctibus nostris non valémus: Genitrícis Fílii tui \
Dómini nostri intercessióne salvémur:\n"
   bcp-roman-qui-tecum)
  "None collect: Famulorum tuorum + Qui tecum.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins propers
;;
;; Invitatory, hymn, antiphons, nocturn versicle, lessons, responsories,
;; benedictions, and collect for LOBVM Matins.

(defconst bcp-roman-lobvm--matins-invitatory
  "Ave María, grátia plena, * Dóminus tecum."
  "Matins invitatory antiphon (from C10 [Invit]).")

(defconst bcp-roman-lobvm--matins-hymn
  "Quem terra, pontus, sídera\n\
Colunt, adórant, prædicant,\n\
Trinam regéntem máchinam,\n\
Claustrum Maríæ bájulat.\n\
\n\
Cui luna, sol, et ómnia\n\
Desérviunt per témpora,\n\
Perfúsa cæli grátia,\n\
Gestant puéllæ víscera.\n\
\n\
Beáta Mater múnere,\n\
Cujus supérnus ártifex\n\
Mundum pugíllo cóntinens,\n\
Ventris sub arca clausus est.\n\
\n\
Beáta cæli núntio,\n\
Fœcúnda sancto Spíritu,\n\
Desiderátus géntibus,\n\
Cujus per alvum fusus est.\n\
\n\
Jesu, tibi sit glória,\n\
Qui natus es de Vírgine,\n\
Cum Patre, et almo Spíritu\n\
In sempitérna sǽcula.\n\
Amen."
  "Matins hymn: Quem terra, pontus, sidera (from C11 [Hymnus Matutinum]).")

;; Matins antiphons (from C11 [Ant MatutinumBMV], first three for one nocturn)
(defconst bcp-roman-lobvm--matins-antiphon-1
  "Benedícta tu in muliéribus, et benedíctus fructus ventris tui."
  "Matins antiphon 1 (Psalm 8).")

(defconst bcp-roman-lobvm--matins-antiphon-2
  "Sicut myrrha elécta, odórem dedísti suavitátis, sancta Dei Génetrix."
  "Matins antiphon 2 (Psalm 18).")

(defconst bcp-roman-lobvm--matins-antiphon-3
  "Ante torum hujus Vírginis frequentáte nobis dúlcia cántica drámatis."
  "Matins antiphon 3 (Psalm 23).")

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

;; Responsories
(defconst bcp-roman-lobvm--matins-responsory-1
  '(:respond "Sancta et immaculáta virgínitas, quibus te láudibus éfferam, néscio:"
    :repeat "Quia quem cæli cápere non póterant, tuo grémio contulísti."
    :verse "Benedícta tu in muliéribus, et benedíctus fructus ventris tui.")
  "Matins Responsory I (from C11 [Responsory1]).")

(defconst bcp-roman-lobvm--matins-responsory-2
  '(:respond "Beáta es, Virgo María, quæ Dóminum portásti, Creatórem mundi:"
    :repeat "Genuísti qui te fecit, et in ætérnum pérmanes Virgo."
    :verse "Ave María, grátia plena, Dóminus tecum.")
  "Matins Responsory II (from C12 [Responsory2]).")

;; Benedictions (LOBVM-specific, from C10 [Benedictio])
(defconst bcp-roman-lobvm--matins-benedictiones
  bcp-roman-benedictiones-lobvm
  "Matins benedictions: the three LOBVM-specific forms from C10.")

;; Collect (same as Lauds collect — the LOBVM uses the same oratio at Matins)
(defconst bcp-roman-lobvm--matins-collect
  (concat
   "Deus, qui de beátæ Maríæ Vírginis útero, Verbum tuum, Ángelo \
nuntiánte, carnem suscípere voluísti: præsta supplícibus tuis; ut, \
qui vere eam Genetrícem Dei crédimus, ejus apud te intercessiónibus \
adjuvémur.\n"
   bcp-roman-per-dominum)
  "Matins collect: Deus qui de beatae Mariae + Per Dominum.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline antiphon

(defconst bcp-roman-lobvm--compline-antiphon
  "Sub tuum præsídium confúgimus, sancta Dei Génetrix: \
nostras deprecatiónes ne despícias in necessitátibus, \
sed a perículis cunctis líbera nos semper, Virgo gloriósa et benedícta."
  "Compline antiphon: Sub tuum praesidium (per annum).")

(defconst bcp-roman-lobvm--compline-antiphon-eastertide
  "Regína cæli, lætáre, allelúja; \
quia quem meruísti portáre, allelúja; \
resurréxit, sicut dixit, allelúja: \
ora pro nobis Deum, allelúja."
  "Compline antiphon: Regina caeli (Eastertide).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline hymn
;;
;; Memento rerum Conditor (DA form) with LOBVM Compline stanza
;; "Enixa est puerpera" and Nativity doxology.

(defconst bcp-roman-lobvm--compline-hymn
  "Meménto, rerum Cónditor,
Nostri quod olim córporis,
Sacráta ab alvo Vírginis
Nascéndo formam súmpseris.

Eníxa est puérpera,
Quem Gábriel prædíxerat,
Quem matris alvo géstiens,
Clausus Joánnes sénserat.

María Mater grátiæ,
Dulcis Parens cleméntiæ,
Tu nos ab hoste prótege,
Et mortis hora súscipe.

Jesu, tibi sit glória,
Qui natus es de Vírgine,
Cum Patre et almo Spíritu,
In sempitérna sǽcula.
Amen."
  "LOBVM Compline hymn: Memento rerum Conditor with Compline stanza.")

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

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline collect

(defconst bcp-roman-lobvm--compline-collect
  (concat
   "Beátæ et gloriósæ semper Vírginis Maríæ, quǽsumus, Dómine, \
intercéssio gloriósa nos prótegat, et ad vitam perdúcat ætérnam.\n"
   bcp-roman-per-dominum)
  "Compline collect: Beatae et gloriosae + Per Dominum.")

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
  "Return the Compline antiphon string for SEASON."
  (if (eq season 'eastertide)
      bcp-roman-lobvm--compline-antiphon-eastertide
    bcp-roman-lobvm--compline-antiphon))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Data resolver
;;
;; Maps ordo step keys to pre-extracted data.

(defun bcp-roman-lobvm--canticle-antiphon-for-season (hour season)
  "Return the canticle antiphon for HOUR and SEASON.
HOUR is one of `lauds' or `vespers'."
  (if (eq season 'eastertide)
      (if (eq hour 'lauds)
          bcp-roman-lobvm--lauds-canticle-antiphon-eastertide
        bcp-roman-lobvm--vespers-canticle-antiphon-eastertide)
    (if (eq hour 'lauds)
        bcp-roman-lobvm--lauds-canticle-antiphon
      bcp-roman-lobvm--vespers-canticle-antiphon)))

(defun bcp-roman-lobvm--resolve (key season)
  "Resolve data KEY for the current SEASON.
Returns the appropriate text, plist, or data structure for the
ordo step identified by KEY."
  (pcase key
    ;; Compline
    ('jube-domne          (bcp-roman-jube-domne))
    ('benedictio-compline bcp-roman-benedictio-compline)
    ('ave-maria           bcp-roman-ave-maria)
    ('converte-nos        bcp-roman-converte-nos)
    ('compline-antiphon   (bcp-roman-lobvm--compline-antiphon-for-season season))
    ('compline-hymn       bcp-roman-lobvm--compline-hymn)
    ('compline-capitulum  bcp-roman-lobvm--compline-capitulum)
    ('compline-versicle   bcp-roman-lobvm--compline-versicle)
    ('nunc-dimittis       bcp-roman-lobvm--nunc-dimittis)
    ('compline-collect    bcp-roman-lobvm--compline-collect)
    ('divinum-auxilium    bcp-roman-divinum-auxilium)
    ('pater-noster        (plist-get bcp-common-prayers-lords-prayer :latin))
    ('credo               (plist-get bcp-common-prayers-apostles-creed :latin))

    ;; Vespers
    ('vespers-antiphon-1  bcp-roman-lobvm--vespers-antiphon-1)
    ('vespers-antiphon-2  bcp-roman-lobvm--vespers-antiphon-2)
    ('vespers-antiphon-3  bcp-roman-lobvm--vespers-antiphon-3)
    ('vespers-antiphon-4  bcp-roman-lobvm--vespers-antiphon-4)
    ('vespers-antiphon-5  bcp-roman-lobvm--vespers-antiphon-5)
    ('vespers-hymn        bcp-roman-lobvm--vespers-hymn)
    ('vespers-capitulum   bcp-roman-lobvm--vespers-capitulum)
    ('vespers-versicle    bcp-roman-lobvm--vespers-versicle)
    ('vespers-canticle-antiphon
     (bcp-roman-lobvm--canticle-antiphon-for-season 'vespers season))
    ('magnificat          bcp-roman-lobvm--magnificat)
    ('vespers-collect     bcp-roman-lobvm--vespers-collect)

    ;; Lauds
    ('lauds-antiphon-1    bcp-roman-lobvm--lauds-antiphon-1)
    ('lauds-antiphon-2    bcp-roman-lobvm--lauds-antiphon-2)
    ('lauds-antiphon-3    bcp-roman-lobvm--lauds-antiphon-3)
    ('lauds-antiphon-4    bcp-roman-lobvm--lauds-antiphon-4)
    ('lauds-antiphon-5    bcp-roman-lobvm--lauds-antiphon-5)
    ('lauds-hymn          bcp-roman-lobvm--lauds-hymn)
    ('lauds-capitulum     bcp-roman-lobvm--lauds-capitulum)
    ('lauds-versicle      bcp-roman-lobvm--lauds-versicle)
    ('lauds-canticle-antiphon
     (bcp-roman-lobvm--canticle-antiphon-for-season 'lauds season))
    ('benedicite          bcp-roman-lobvm--benedicite)
    ('benedictus          bcp-roman-lobvm--benedictus)
    ('lauds-collect       bcp-roman-lobvm--lauds-collect)

    ;; Matins
    ('matins-invitatory   bcp-roman-lobvm--matins-invitatory)
    ('matins-hymn         bcp-roman-lobvm--matins-hymn)
    ('matins-antiphon-1   bcp-roman-lobvm--matins-antiphon-1)
    ('matins-antiphon-2   bcp-roman-lobvm--matins-antiphon-2)
    ('matins-antiphon-3   bcp-roman-lobvm--matins-antiphon-3)
    ('matins-nocturn-versicle bcp-roman-lobvm--matins-nocturn-versicle)
    ('matins-lectio-1     bcp-roman-lobvm--matins-lectio-1)
    ('matins-lectio-2     bcp-roman-lobvm--matins-lectio-2)
    ('matins-lectio-3     bcp-roman-lobvm--matins-lectio-3)
    ('matins-responsory-1 bcp-roman-lobvm--matins-responsory-1)
    ('matins-responsory-2 bcp-roman-lobvm--matins-responsory-2)
    ('matins-benedictiones bcp-roman-lobvm--matins-benedictiones)
    ('matins-collect      bcp-roman-lobvm--matins-collect)

    ;; Minor Hours — shared hymn
    ('minor-hymn          bcp-roman-lobvm--minor-hymn)

    ;; Prime
    ('prime-antiphon      bcp-roman-lobvm--lauds-antiphon-1)
    ('prime-capitulum     bcp-roman-lobvm--prime-capitulum)
    ('prime-versicle      bcp-roman-lobvm--prime-versicle)
    ('prime-collect       bcp-roman-lobvm--prime-collect)

    ;; Terce
    ('terce-antiphon      bcp-roman-lobvm--lauds-antiphon-2)
    ('terce-capitulum     bcp-roman-lobvm--terce-capitulum)
    ('terce-versicle      bcp-roman-lobvm--terce-versicle)
    ('terce-collect       bcp-roman-lobvm--terce-collect)

    ;; Sext
    ('sext-antiphon       bcp-roman-lobvm--lauds-antiphon-3)
    ('sext-capitulum      bcp-roman-lobvm--sext-capitulum)
    ('sext-versicle       bcp-roman-lobvm--sext-versicle)
    ('sext-collect        bcp-roman-lobvm--sext-collect)

    ;; None
    ('none-antiphon       bcp-roman-lobvm--lauds-antiphon-5)
    ('none-capitulum      bcp-roman-lobvm--none-capitulum)
    ('none-versicle       bcp-roman-lobvm--none-versicle)
    ('none-collect        bcp-roman-lobvm--none-collect)

    ;; Shared
    ('commemoratio        bcp-roman-lobvm--commemoratio)

    (_ (error "Unknown LOBVM data key: %s" key))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; English prose texts (Bute 1908 translation)
;;
;; Marquess of Bute, The Roman Breviary (1908).  These are the fallback
;; English translations for Office prose — antiphons, collects, versicles,
;; responsories.  Hymns are resolved through `bcp-roman-hymnal'; scripture
;; (capitula, lessons) through `bcp-fetcher'.

;; Vespers antiphons (English)
(defconst bcp-roman-lobvm--vespers-antiphon-1-en
  "While the King sitteth at his table, my spikenard sendeth forth the smell thereof."
  "Vespers antiphon 1 (Ps 109), English — Bute.")

(defconst bcp-roman-lobvm--vespers-antiphon-2-en
  "His left hand is under my head, and his right hand doth embrace me."
  "Vespers antiphon 2 (Ps 112), English — Bute.")

(defconst bcp-roman-lobvm--vespers-antiphon-3-en
  "I am black but comely, O ye daughters of Jerusalem; therefore hath the King loved me, and brought me into his chamber."
  "Vespers antiphon 3 (Ps 121), English — Bute.")

(defconst bcp-roman-lobvm--vespers-antiphon-4-en
  "Lo the winter is past, the rain is over and gone. Rise up, my love, and come away."
  "Vespers antiphon 4 (Ps 126), English — Bute.")

(defconst bcp-roman-lobvm--vespers-antiphon-5-en
  "O Holy Mother of God, thou art become beautiful and gentle in thy gladness."
  "Vespers antiphon 5 (Ps 147), English — Bute.")

;; Vespers versicle, canticle antiphon, collect (English)
(defconst bcp-roman-lobvm--vespers-versicle-en
  '("Blessed art thou amongst women."
    "And blessed is the fruit of thy womb.")
  "Vespers versicle, English — Bute.")

(defconst bcp-roman-lobvm--vespers-canticle-antiphon-en
  "Blessed Mother and inviolate Maiden! Glorious Queen of the world! Plead for us with the Lord!"
  "Vespers Magnificat antiphon (per annum), English — Bute.")

(defconst bcp-roman-lobvm--vespers-canticle-antiphon-eastertide-en
  "O Queen of heaven, rejoice! alleluia: For He whom thou didst merit to bear, alleluia, Hath arisen as he said, alleluia. Pray for us to God, alleluia."
  "Vespers Magnificat antiphon (Eastertide), English — Bute.")

(defconst bcp-roman-lobvm--vespers-collect-en
  "Grant, we beseech thee, O Lord God, unto all thy servants, that they \
may remain continually in the enjoyment of soundness both of mind and body, \
and by the glorious intercession of the Blessed Mary, always a Virgin, may \
be delivered from present sadness, and enter into the joy of thine eternal \
gladness.\nThrough our Lord."
  "Vespers collect, English — Bute.")

;; Lauds antiphons (English)
(defconst bcp-roman-lobvm--lauds-antiphon-1-en
  "Mary hath been taken to heaven; the Angels rejoice; they praise and bless the Lord."
  "Lauds antiphon 1 (Ps 92), English — Bute.")

(defconst bcp-roman-lobvm--lauds-antiphon-2-en
  "The Virgin Mary hath been taken into the chamber on high, where the King of kings sitteth on a throne amid the stars."
  "Lauds antiphon 2 (Ps 99), English — Bute.")

(defconst bcp-roman-lobvm--lauds-antiphon-3-en
  "We run after thee, on the scent of thy perfumes; the virgins love thee heartily."
  "Lauds antiphon 3 (Ps 62), English — Bute.")

(defconst bcp-roman-lobvm--lauds-antiphon-4-en
  "Blessed of the Lord art thou, O daughter, for by thee we have been given to eat of the fruit of the tree of Life."
  "Lauds antiphon 4 (Benedicite), English — Bute.")

(defconst bcp-roman-lobvm--lauds-antiphon-5-en
  "Fair and comely art thou, O daughter of Jerusalem, terrible as a fenced camp set in battle array."
  "Lauds antiphon 5 (Ps 148-150), English — Bute.")

;; Lauds versicle, canticle antiphon, collect (English)
(defconst bcp-roman-lobvm--lauds-versicle-en
  '("Holy Virgin, my praise by thee accepted be."
    "Give me strength against thine enemies.")
  "Lauds versicle, English — Bute.")

(defconst bcp-roman-lobvm--lauds-canticle-antiphon-en
  "O Blessed Mary, Mother of God, Virgin for ever, temple of the Lord, \
sanctuary of the Holy Ghost, thou, without any example before thee, didst \
make thyself well-pleasing in the sight of our Lord Jesus Christ; pray for \
the people, plead for the clergy, make intercession for all women vowed to God."
  "Lauds Benedictus antiphon (per annum), English — Bute.")

(defconst bcp-roman-lobvm--lauds-canticle-antiphon-eastertide-en
  "O Queen of heaven, rejoice! alleluia: For He whom thou didst merit to bear, alleluia, Hath arisen as he said, alleluia. Pray for us to God, alleluia."
  "Lauds Benedictus antiphon (Eastertide), English — Bute.")

(defconst bcp-roman-lobvm--lauds-collect-en
  "O God, who didst will that, at the announcement of an Angel, thy Word \
should take flesh in the womb of the Blessed Virgin Mary, grant to us thy \
suppliants, that we who believe her to be truly the Mother of God may be \
helped by her intercession with thee.\nThrough the same Lord."
  "Lauds collect, English — Bute.")

;; Matins antiphons (English)
(defconst bcp-roman-lobvm--matins-invitatory-en
  "Hail Mary, full of grace, * The Lord is with thee."
  "Matins invitatory antiphon, English — Bute.")

(defconst bcp-roman-lobvm--matins-antiphon-1-en
  "Blessed art thou among women, and blessed is the fruit of thy womb."
  "Matins antiphon 1 (Psalm 8), English — Bute.")

(defconst bcp-roman-lobvm--matins-antiphon-2-en
  "O Holy Mother of God, thou hast yielded a pleasant odor like the best myrrh."
  "Matins antiphon 2 (Psalm 18), English — Bute.")

(defconst bcp-roman-lobvm--matins-antiphon-3-en
  "Sing for us again and again before this maiden's bed the tender idylls of the play."
  "Matins antiphon 3 (Psalm 23), English — Bute.")

;; Matins nocturn versicle (English)
(defconst bcp-roman-lobvm--matins-nocturn-versicle-en
  '("Holy Virgin, my praise by thee accepted be."
    "Give me strength against thine enemies.")
  "Matins nocturn versicle, English — Bute.")

;; Matins responsories (English)
(defconst bcp-roman-lobvm--matins-responsory-1-en
  '(:respond "O how holy and how spotless is thy virginity; I am too dull to praise thee:"
    :repeat "For thou hast borne in thy breast Him Whom the heavens cannot contain."
    :verse "Blessed art thou among women, and blessed is the fruit of thy womb.")
  "Matins responsory 1, English — Bute.")

(defconst bcp-roman-lobvm--matins-responsory-2-en
  '(:respond "Blessed art thou, O Virgin Mary, who hast carried the Lord, the Maker of the world."
    :repeat "Thou hast borne Him Who created thee, and thou abidest a virgin for ever."
    :verse "Hail, Mary, full of grace, the Lord is with thee.")
  "Matins responsory 2, English — Bute.")

;; Matins collect (English)
(defconst bcp-roman-lobvm--matins-collect-en
  "O God, who didst will that, at the announcement of an Angel, thy Word \
should take flesh in the womb of the Blessed Virgin Mary, grant to us thy \
suppliants, that we who believe her to be truly the Mother of God may be \
helped by her intercession with thee.\nThrough the same Lord."
  "Matins collect, English — Bute.")

;; Matins benedictions (English)
(defconst bcp-roman-lobvm--matins-benedictiones-en
  '("May the prayers and merits of blessed Mary ever Virgin and all the Saints bring us to the kingdom of heaven."
    "May the Virgin Mary with her Loving Offspring bless us."
    "May the Virgin of virgins, intercede for us to the Lord.")
  "Matins benedictions, English — Bute.")

;; Prime propers (English)
(defconst bcp-roman-lobvm--prime-versicle-en
  '("Holy Virgin, my praise by thee accepted be."
    "Give me strength against thine enemies.")
  "Prime versicle, English — Bute.")

(defconst bcp-roman-lobvm--prime-collect-en
  "O God, Who wast pleased to choose for thy dwelling-place the maiden palace \
of Blessed Mary, grant, we beseech thee, that her protection may shield us, \
and make us glad in her commemoration.\nWho livest and reignest."
  "Prime collect, English — Bute.")

;; Terce propers (English)
(defconst bcp-roman-lobvm--terce-versicle-en
  '("Grace is poured into thy lips."
    "Therefore God hath blessed thee for ever.")
  "Terce versicle, English — Bute.")

(defconst bcp-roman-lobvm--terce-collect-en
  "O God, Who, by the fruitful virginity of Blessed Mary, hast bestowed upon \
mankind the reward of eternal salvation; grant, we beseech thee, that we \
may feel the power of her intercession, through whom we have been made \
worthy to receive the Author of Life, our Lord Jesus Christ thy Son.\n\
Who livest and reignest with thee."
  "Terce collect, English — Bute.")

;; Sext propers (English)
(defconst bcp-roman-lobvm--sext-versicle-en
  '("Blessed art thou amongst women."
    "And blessed is the fruit of thy womb.")
  "Sext versicle, English — Bute.")

(defconst bcp-roman-lobvm--sext-collect-en
  "Most merciful God, grant, we beseech thee, a succour unto the frailty of \
our nature, that as we keep ever alive the memory of the holy Mother of God, \
so by the help of her intercession we may be raised up from the bondage of \
our sins.\nThrough the same Lord."
  "Sext collect, English — Bute.")

;; None propers (English)
(defconst bcp-roman-lobvm--none-versicle-en
  '("After thy delivery, thou still remainest a Virgin undefiled."
    "Mother of God, pray for us.")
  "None versicle, English — Bute.")

(defconst bcp-roman-lobvm--none-collect-en
  "O Lord, we beseech thee, forgive the transgressions of thy servants, \
and, forasmuch as by our own deeds we cannot please thee, may we find \
safety through the prayers of the Mother of thy Son and our Lord.\n\
Who livest and reignest with thee."
  "None collect, English — Bute.")

;; Compline propers (English)
(defconst bcp-roman-lobvm--compline-antiphon-en
  "We take refuge under thy protection, O holy Mother of God! Despise not \
our supplications in our need, but deliver us always from all dangers, O \
Virgin, glorious and blessed!"
  "Compline antiphon (Sub tuum praesidium), English — Bute.")

(defconst bcp-roman-lobvm--compline-antiphon-eastertide-en
  "O Queen of heaven, rejoice! alleluia: For He whom thou didst merit to bear, alleluia, Hath arisen as he said, alleluia. Pray for us to God, alleluia."
  "Compline antiphon (Eastertide), English — Bute.")

(defconst bcp-roman-lobvm--compline-versicle-en
  '("Pray for us, O holy Mother of God."
    "That we may be made worthy of the promises of Christ.")
  "Compline versicle, English — Bute.")

(defconst bcp-roman-lobvm--compline-collect-en
  "O Lord, we pray thee, that the glorious intercession of Mary, blessed, \
and glorious, and everlastingly Virgin, may shield us and bring us on \
toward eternal life.\nThrough our Lord."
  "Compline collect, English — Bute.")

;; Commemoratio (English)
(defconst bcp-roman-lobvm--commemoratio-en
  '(:antiphon "All ye saints of God, vouchsafe to plead for our salvation and for that of all mankind."
    :versicle "Be glad in the Lord and rejoice, ye just."
    :response "And be joyful, all ye that are upright of heart."
    :collect "Shield, O Lord, thy people, and ever keep them in thy care, who put their trust in the pleading of thy Apostles Peter and Paul, and of the other Apostles.\nMay all thy saints, we beseech thee, O Lord, everywhere come to our help, that while we do honor to their merits, we may also enjoy their intercession: grant thy own peace unto our times, and drive away all wickedness from thy Church; direct our way, our actions, and our wishes and those of all thy servants in the way of salvation; to our benefactors render everlasting blessings, and to all the faithful departed grant eternal rest.\nThrough our Lord.")
  "Commemoratio de Sanctis, English — Bute.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; English data resolver

(defun bcp-roman-lobvm--compline-antiphon-en-for-season (season)
  "Return the English Compline antiphon for SEASON."
  (if (eq season 'eastertide)
      bcp-roman-lobvm--compline-antiphon-eastertide-en
    bcp-roman-lobvm--compline-antiphon-en))

(defun bcp-roman-lobvm--canticle-antiphon-en-for-season (hour season)
  "Return the English canticle antiphon for HOUR and SEASON."
  (if (eq season 'eastertide)
      (if (eq hour 'lauds)
          bcp-roman-lobvm--lauds-canticle-antiphon-eastertide-en
        bcp-roman-lobvm--vespers-canticle-antiphon-eastertide-en)
    (if (eq hour 'lauds)
        bcp-roman-lobvm--lauds-canticle-antiphon-en
      bcp-roman-lobvm--vespers-canticle-antiphon-en)))

(defun bcp-roman-lobvm--resolve-english (key season)
  "Resolve English text for data KEY and SEASON.
Returns the English translation, or nil if none available (falls
back to Latin via the caller)."
  (pcase key
    ;; Compline
    ('compline-antiphon   (bcp-roman-lobvm--compline-antiphon-en-for-season season))
    ('compline-versicle   bcp-roman-lobvm--compline-versicle-en)
    ('compline-collect    bcp-roman-lobvm--compline-collect-en)

    ;; Vespers
    ('vespers-antiphon-1  bcp-roman-lobvm--vespers-antiphon-1-en)
    ('vespers-antiphon-2  bcp-roman-lobvm--vespers-antiphon-2-en)
    ('vespers-antiphon-3  bcp-roman-lobvm--vespers-antiphon-3-en)
    ('vespers-antiphon-4  bcp-roman-lobvm--vespers-antiphon-4-en)
    ('vespers-antiphon-5  bcp-roman-lobvm--vespers-antiphon-5-en)
    ('vespers-versicle    bcp-roman-lobvm--vespers-versicle-en)
    ('vespers-canticle-antiphon
     (bcp-roman-lobvm--canticle-antiphon-en-for-season 'vespers season))
    ('vespers-collect     bcp-roman-lobvm--vespers-collect-en)

    ;; Lauds
    ('lauds-antiphon-1    bcp-roman-lobvm--lauds-antiphon-1-en)
    ('lauds-antiphon-2    bcp-roman-lobvm--lauds-antiphon-2-en)
    ('lauds-antiphon-3    bcp-roman-lobvm--lauds-antiphon-3-en)
    ('lauds-antiphon-4    bcp-roman-lobvm--lauds-antiphon-4-en)
    ('lauds-antiphon-5    bcp-roman-lobvm--lauds-antiphon-5-en)
    ('lauds-versicle      bcp-roman-lobvm--lauds-versicle-en)
    ('lauds-canticle-antiphon
     (bcp-roman-lobvm--canticle-antiphon-en-for-season 'lauds season))
    ('lauds-collect       bcp-roman-lobvm--lauds-collect-en)

    ;; Matins
    ('matins-invitatory   bcp-roman-lobvm--matins-invitatory-en)
    ('matins-antiphon-1   bcp-roman-lobvm--matins-antiphon-1-en)
    ('matins-antiphon-2   bcp-roman-lobvm--matins-antiphon-2-en)
    ('matins-antiphon-3   bcp-roman-lobvm--matins-antiphon-3-en)
    ('matins-nocturn-versicle bcp-roman-lobvm--matins-nocturn-versicle-en)
    ('matins-responsory-1 bcp-roman-lobvm--matins-responsory-1-en)
    ('matins-responsory-2 bcp-roman-lobvm--matins-responsory-2-en)
    ('matins-benedictiones bcp-roman-lobvm--matins-benedictiones-en)
    ('matins-collect      bcp-roman-lobvm--matins-collect-en)

    ;; Minor Hours
    ('prime-versicle      bcp-roman-lobvm--prime-versicle-en)
    ('prime-collect       bcp-roman-lobvm--prime-collect-en)
    ('terce-versicle      bcp-roman-lobvm--terce-versicle-en)
    ('terce-collect       bcp-roman-lobvm--terce-collect-en)
    ('sext-versicle       bcp-roman-lobvm--sext-versicle-en)
    ('sext-collect        bcp-roman-lobvm--sext-collect-en)
    ('none-versicle       bcp-roman-lobvm--none-versicle-en)
    ('none-collect        bcp-roman-lobvm--none-collect-en)

    ;; Shared
    ('commemoratio        bcp-roman-lobvm--commemoratio-en)

    ;; Structural texts from bcp-common-roman.el
    ('jube-domne          (bcp-roman-jube-domne-en))
    ('benedictio-compline bcp-roman-benedictio-compline-en)
    ('converte-nos        bcp-roman-converte-nos-en)
    ('divinum-auxilium    bcp-roman-divinum-auxilium-en)
    ('ave-maria           bcp-roman-ave-maria)  ;; same in both languages
    ('pater-noster        (plist-get bcp-common-prayers-lords-prayer :english))
    ('credo               (plist-get bcp-common-prayers-apostles-creed :english))

    ;; Keys with no English translation → return nil, fall back to Latin
    (_ nil)))

(defun bcp-roman-lobvm--psalm-verses (vulg-num)
  "Return the verse list for Vulgate psalm VULG-NUM, or nil."
  (cdr (assq vulg-num bcp-roman-lobvm--psalms)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Entry point

(defun bcp-roman-lobvm--render-hour (hour ordo buffer-name label &optional date)
  "Render an LOBVM HOUR with ORDO, BUFFER-NAME, LABEL, and optional DATE.
HOUR is a symbol: `matins', `lauds', `prime', `terce', `sext',
`none', `vespers', or `compline'."
  (let* ((date (or date (calendar-current-date)))
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
                        (if (eq lang 'english)
                            (or (bcp-roman-lobvm--resolve-english key season)
                                (bcp-roman-lobvm--resolve key season))
                          (bcp-roman-lobvm--resolve key season)))
             :psalm-fn #'bcp-roman-lobvm--psalm-verses
             :gloria-patri (plist-get bcp-common-prayers-gloria-patri
                                      (intern (format ":%s" lang)))
             :buffer-name buffer-name
             :office-label label)))))

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
