;;; bcp-roman-season-holyweek.el --- Holy Week and Sacred Triduum -*- lexical-binding: t -*-

;;; Commentary:

;; Data for Holy Week (Quad6): Mon–Wed weekday propers and
;; Sacred Triduum (Thu/Fri/Sat) Tenebrae offices.
;;
;; Source: Divinum Officium Tempora/Quad6-1 through Quad6-6.
;;
;; The Triduum Tenebrae is the most structurally unique office in
;; the Roman Breviary: no incipit, invitatory, hymn, or Gloria Patri
;; after psalms; 9 proper psalms with individual antiphons; Lamentations
;; of Jeremiah with Hebrew letter prefixes; and the concluding
;; "Christus factus est" versicle that accumulates across three days.
;;
;; Public API:
;;   `bcp-roman-season-holyweek-triduum'     — return Triduum data plist
;;   `bcp-roman-season-holyweek-collect'      — return collect for date
;;   `bcp-roman-season-holyweek-hours'        — return non-Matins hour data

;;; Code:

(require 'bcp-roman-antiphonary)
(require 'bcp-roman-collectarium)
(require 'bcp-common-roman)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Maundy Thursday antiphon registrations

;;; Matins antiphons (9, each with proper psalm)

(bcp-roman-antiphonary-register
 'zelus-domus-tuae
 '(:latin "Zelus domus tuæ * comédit me, et oppróbria exprobrántium tibi cecidérunt super me."
   :source gallican
   :ref "Ps 68:10"
   :translations
   ((do . "The zeal of thine house * hath eaten me up, and the reproaches of them that reproached thee are fallen upon me."))))

(bcp-roman-antiphonary-register
 'avertantur-retrorsum
 '(:latin "Avertántur retrórsum, * et erubéscant, qui cógitant mihi mala."
   :source gallican
   :ref "Ps 69:3"
   :translations
   ((do . "Let them be turned backward * and put to confusion that desire my hurt."))))

(bcp-roman-antiphonary-register
 'deus-meus-eripe-me
 '(:latin "Deus meus, * éripe me de manu peccatóris."
   :source gallican
   :ref "Ps 70:4"
   :translations
   ((do . "Deliver me, my God, * out of the hand of the wicked."))))

(bcp-roman-antiphonary-register
 'liberavit-dominus-pauperem
 '(:latin "Liberávit Dóminus * páuperem a poténte, et ínopem, cui non erat adjútor."
   :source paraphrase
   :ref "Ps 71:12"
   :translations
   ((do . "The Lord shall deliver * the needy from the strong: the poor also, that hath no helper."))))

(bcp-roman-antiphonary-register
 'cogitaverunt-impii
 '(:latin "Cogitavérunt ímpii, * et locúti sunt nequítiam: iniquitátem in excélso locúti sunt."
   :source gallican
   :ref "Ps 72:8"
   :translations
   ((do . "The ungodly think * and speak wickedness: they speak loftily concerning oppression."))))

(bcp-roman-antiphonary-register
 'exsurge-domine-et-judica
 '(:latin "Exsúrge, Dómine, * et júdica causam meam."
   :source gallican
   :ref "Ps 73:22"
   :translations
   ((do . "Arise, O Lord, * and judge my cause."))))

(bcp-roman-antiphonary-register
 'dixi-iniquis-nolite
 '(:latin "Dixi iníquis: * Nolíte loqui advérsus Deum iniquitátem."
   :source gallican
   :ref "Ps 74:5"
   :translations
   ((do . "I said unto the wicked: * Speak not wickedness against God."))))

(bcp-roman-antiphonary-register
 'terra-tremuit
 '(:latin "Terra trémuit * et quiévit, dum exsúrgeret in judício Deus."
   :source gallican
   :ref "Ps 75:9-10"
   :translations
   ((do . "The earth trembled * and was still, when God arose to judgment."))))

(bcp-roman-antiphonary-register
 'in-die-tribulationis-meae-deum
 '(:latin "In die tribulatiónis * meæ Deum exquisívi mánibus meis."
   :source gallican
   :ref "Ps 76:3"
   :translations
   ((do . "In the day of my trouble * I sought God with my hands."))))

;;; Lauds antiphons (5)

(bcp-roman-antiphonary-register
 'justificeris-domine
 '(:latin "Justificéris, Dómine, * in sermónibus tuis, et vincas cum judicáris."
   :source gallican
   :ref "Ps 50:6"
   :translations
   ((do . "O Lord, Thou shalt be justified * when Thou speakest, and be clear when Thou art judged."))))

(bcp-roman-antiphonary-register
 'dominus-tamquam-ovis
 '(:latin "Dóminus * tamquam ovis ad víctimam ductus est, et non apéruit os suum."
   :source vulgate
   :ref "Isa 53:7"
   :translations
   ((do . "The Lord was brought as a lamb * to the slaughter, and He opened not His mouth."))))

(bcp-roman-antiphonary-register
 'contritum-est-cor-meum
 '(:latin "Contrítum est * cor meum in médio mei, contremuérunt ómnia ossa mea."
   :source gallican
   :ref "Jer 23:9"
   :translations
   ((do . "Mine heart is broken within me * all my bones tremble."))))

(bcp-roman-antiphonary-register
 'exhortatus-es-in-virtute
 '(:latin "Exhortátus es * in virtúte tua, et in refectióne sancta tua, Dómine."
   :source paraphrase
   :ref "Exod 15:13"
   :translations
   ((do . "O Lord, Thou hast spoken unto us * in thy strength, and in thy Holy Banquet."))))

(bcp-roman-antiphonary-register
 'oblatus-est-quia-ipse-voluit
 '(:latin "Oblátus est * quia ipse vóluit, et peccáta nostra ipse portávit."
   :source vulgate
   :ref "Isa 53:7,4"
   :translations
   ((do . "He was offered up because He willed it * and He bore our sins."))))

;;; Benedictus antiphon

(bcp-roman-antiphonary-register
 'traditor-autem-dedit
 '(:latin "Tráditor autem * dedit eis signum, dicens: Quem osculátus fúero, ipse est, tenéte eum."
   :source vulgate
   :ref "Matt 26:48"
   :translations
   ((do . "Now he that betrayed Him * gave them a sign, saying: Whomsoever I shall kiss, That Same is He: hold Him fast."))))

;;; Magnificat antiphon (Vespers II / Ant 3 in DO)

(bcp-roman-antiphonary-register
 'cenantibus-autem-illis
 '(:latin "Cenántibus autem illis * accépit Jesus panem, et benedíxit, ac fregit, dedítque discípulis suis."
   :source vulgate
   :ref "Matt 26:26"
   :translations
   ((do . "And, as they were eating * Jesus took bread, and blessed, and broke it, and gave to His disciples."))))

;;; Vespers antiphons (5, with psalm numbers)

(bcp-roman-antiphonary-register
 'calicem-salutaris
 '(:latin "Cálicem * salutáris accípiam et nomen Dómini invocábo."
   :source gallican
   :ref "Ps 115:4"
   :translations
   ((do . "I will take the cup of salvation; * and call upon the Name of the Lord."))))

(bcp-roman-antiphonary-register
 'cum-his-qui-oderunt
 '(:latin "Cum his, * qui odérunt pacem eram pacíficus: dum loquébar illis, impugnábant me gratis."
   :source gallican
   :ref "Ps 119:7"
   :translations
   ((do . "With them * that hate peace I was peaceable; when I spoke unto them they fought against me without a cause."))))

(bcp-roman-antiphonary-register
 'ab-hominibus-iniquis
 '(:latin "Ab homínibus * iníquis líbera me, Dómine."
   :source gallican
   :ref "Ps 139:2"
   :translations
   ((do . "O Lord, preserve me * from the wicked man."))))

(bcp-roman-antiphonary-register
 'custodi-me-a-laqueo
 '(:latin "Custódi me * a láqueo, quem statuérunt mihi, et a scándalis operántium iniquitátem."
   :source gallican
   :ref "Ps 140:9"
   :translations
   ((do . "Keep me * from the snare which they have laid for me, and the gins of the workers of iniquity."))))

(bcp-roman-antiphonary-register
 'considerabam-ad-dexteram
 '(:latin "Considerábam * ad déxteram, et vidébam, et non erat qui cognósceret me."
   :source gallican
   :ref "Ps 141:5"
   :translations
   ((do . "I looked * on my right hand and beheld: but there was no man that would know me."))))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Good Friday antiphon registrations

;;; Matins antiphons (9, each with proper psalm)

(bcp-roman-antiphonary-register
 'astiterunt-reges-terrae
 '(:latin "Astitérunt reges terræ, * et príncipes convenérunt in unum, advérsus Dóminum, et advérsus Christum ejus."
   :source gallican
   :ref "Ps 2:2"
   :translations
   ((do . "The kings of the earth set themselves, * and the rulers take counsel together, against the Lord, and against His Anointed."))))

(bcp-roman-antiphonary-register
 'diviserunt-sibi
 '(:latin "Divisérunt sibi * vestiménta mea, et super vestem meam misérunt sortem."
   :source gallican
   :ref "Ps 21:19"
   :translations
   ((do . "They part my garments among them, * and cast lots upon my vesture."))))

(bcp-roman-antiphonary-register
 'insurrexerunt-in-me
 '(:latin "Insurrexérunt in me * testes iníqui, et mentíta est iníquitas sibi."
   :source gallican
   :ref "Ps 26:12"
   :translations
   ((do . "False witnesses are risen up against me, * and iniquity hath belied itself."))))

(bcp-roman-antiphonary-register
 'vim-faciebant
 '(:latin "Vim faciébant, * qui quærébant ánimam meam."
   :source gallican
   :ref "Ps 37:13"
   :translations
   ((do . "They that sought after my life * have used violence against me."))))

(bcp-roman-antiphonary-register
 'confundantur-et-revereantur
 '(:latin "Confundántur * et revereántur, qui quærunt ánimam meam, ut áuferant eam."
   :source gallican
   :ref "Ps 39:15"
   :translations
   ((do . "Let them be ashamed and confounded * together that seek after my soul, to destroy it."))))

(bcp-roman-antiphonary-register
 'alieni-insurrexerunt
 '(:latin "Aliéni * insurrexérunt in me, et fortes quæsiérunt ánimam meam."
   :source gallican
   :ref "Ps 53:5"
   :translations
   ((do . "Strangers are risen up against me, * and oppressors seek after my soul."))))

(bcp-roman-antiphonary-register
 'ab-insurgentibus-in-me
 '(:latin "Ab insurgéntibus in me * líbera me, Dómine, quia occupavérunt ánimam meam."
   :source gallican
   :ref "Ps 58:4"
   :translations
   ((do . "O Lord, defend me from them that rise up against me, * for they lie in wait for my life."))))

(bcp-roman-antiphonary-register
 'longe-fecisti-notos
 '(:latin "Longe fecísti * notos meos a me: tráditus sum, et non egrediébar."
   :source gallican
   :ref "Ps 87:9"
   :translations
   ((do . "Thou hast put away mine acquaintance far from me; * I am shut up, and cannot come forth."))))

(bcp-roman-antiphonary-register
 'captabunt-in-animam
 '(:latin "Captábunt * in ánimam justi, et sánguinem innocéntem condemnábunt."
   :source gallican
   :ref "Ps 93:21"
   :translations
   ((do . "They gather themselves together * against the soul of the righteous, and condemn the innocent blood."))))

;;; Good Friday Lauds antiphons (5)

(bcp-roman-antiphonary-register
 'proprio-filio-suo
 '(:latin "Próprio * Fílio suo non pepércit Deus, sed pro nobis ómnibus trádidit illum."
   :source vulgate
   :ref "Rom 8:32"
   :translations
   ((do . "God spared not His Own Son * but delivered Him up for us all."))))

(bcp-roman-antiphonary-register
 'anxiatus-est-super-me
 '(:latin "Anxiátus est super me * spíritus meus, in me turbátum est cor meum."
   :source gallican
   :ref "Ps 142:4"
   :translations
   ((do . "My spirit is overwhelmed within me; * my heart within me is troubled."))))

(bcp-roman-antiphonary-register
 'ait-latro-ad-latronem
 '(:latin "Ait latro ad latrónem: * Nos quidem digna factis recípimus, hic autem quid fecit? Meménto mei, Dómine, dum véneris in regnum tuum."
   :source vulgate
   :ref "Luke 23:41-42"
   :translations
   ((do . "One thief said unto the other: * We indeed receive the due reward of our deeds, but what hath this man done? Lord, remember me, when thou comest into thy kingdom."))))

(bcp-roman-antiphonary-register
 'cum-conturbata-fuerit
 '(:latin "Cum conturbáta fúerit * ánima mea, Dómine, misericórdiæ memor eris."
   :source paraphrase
   :ref "Hab 3:2"
   :translations
   ((do . "Lord, when my soul is troubled, * thou wilt remember mercy."))))

(bcp-roman-antiphonary-register
 'memento-mei-domine
 '(:latin "Meménto mei, * Dómine, dum véneris in regnum tuum."
   :source vulgate
   :ref "Luke 23:42"
   :translations
   ((do . "Lord, remember me * when thou comest into thy kingdom."))))

;;; Good Friday Benedictus antiphon

(bcp-roman-antiphonary-register
 'posuerunt-super-caput
 '(:latin "Posuérunt * super caput ejus causam ipsíus scriptam: Jesus Nazarénus, Rex Judæórum."
   :source vulgate
   :ref "Matt 27:37"
   :translations
   ((do . "They set up over his head his accusation written: * Jesus of Nazareth, King of the Jews."))))

;;; Good Friday Magnificat antiphon

(bcp-roman-antiphonary-register
 'cum-accepisset-acetum
 '(:latin "Cum accepísset acétum, * dixit: Consummátum est: et inclináto cápite, emísit spíritum."
   :source vulgate
   :ref "John 19:30"
   :translations
   ((do . "When He had received the vinegar, * he said: It is finished! and he bowed His Head, and gave up the Ghost."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Holy Saturday antiphon registrations

;;; Matins antiphons (9, each with proper psalm — peaceful psalms)

(bcp-roman-antiphonary-register
 'in-pace-in-idipsum
 '(:latin "In pace * in idípsum, dórmiam et requiéscam."
   :source gallican
   :ref "Ps 4:9"
   :translations
   ((do . "I will both lay me down in peace, * and sleep."))))

(bcp-roman-antiphonary-register
 'habitabit-in-tabernaculo
 '(:latin "Habitábit * in tabernáculo tuo, requiéscet in monte sancto tuo."
   :source gallican
   :ref "Ps 14:1"
   :translations
   ((do . "He shall abide in thy tabernacle: * he shall dwell in thy holy hill."))))

(bcp-roman-antiphonary-register
 'caro-mea-requiescet
 '(:latin "Caro mea * requiéscet in spe."
   :source gallican
   :ref "Ps 15:9"
   :translations
   ((do . "My flesh * shall rest in hope."))))

(bcp-roman-antiphonary-register
 'elevamini-portae
 '(:latin "Elevámini, * portæ æternáles, et introíbit Rex glóriæ."
   :source gallican
   :ref "Ps 23:7"
   :translations
   ((do . "Be ye lift up, * ye everlasting doors, and the King of glory shall come in."))))

(bcp-roman-antiphonary-register
 'credo-videre-bona
 '(:latin "Credo vidére * bona Dómini in terra vivéntium."
   :source gallican
   :ref "Ps 26:13"
   :translations
   ((do . "I believe that I shall yet see * the goodness of the Lord in the land of the living."))))

(bcp-roman-antiphonary-register
 'domine-abstraxisti
 '(:latin "Dómine, * abstraxísti ab ínferis ánimam meam."
   :source gallican
   :ref "Ps 29:4"
   :translations
   ((do . "O Lord, Thou hast brought up * my soul from the grave."))))

(bcp-roman-antiphonary-register
 'deus-adjuvat-me
 '(:latin "Deus ádjuvat me, * et Dóminus suscéptor est ánimæ meæ."
   :source gallican
   :ref "Ps 53:6"
   :translations
   ((do . "God is my helper, * and the Lord upholdeth my soul."))))

(bcp-roman-antiphonary-register
 'in-pace-factus-est
 '(:latin "In pace * factus est locus ejus, et in Sion habitátio ejus."
   :source gallican
   :ref "Ps 75:3"
   :translations
   ((do . "His place is in peace * and His dwelling-place in Zion."))))

(bcp-roman-antiphonary-register
 'factus-sum-sicut-homo
 '(:latin "Factus sum * sicut homo sine adjutório, inter mórtuos liber."
   :source gallican
   :ref "Ps 87:5"
   :translations
   ((do . "I am as a man that hath no strength, * lying nerveless among the dead."))))

;;; Holy Saturday Lauds antiphons (5)

(bcp-roman-antiphonary-register
 'o-mors-ero-mors-tua
 '(:latin "O mors, * ero mors tua, morsus tuus ero, inférne."
   :source vulgate
   :ref "Hos 13:14"
   :translations
   ((do . "O death, I will be thy death; * O grave, I will be thy destruction."))))

(bcp-roman-antiphonary-register
 'plangent-eum-quasi
 '(:latin "Plangent eum * quasi unigénitum, quia ínnocens Dóminus occísus est."
   :source paraphrase
   :ref "Zech 12:10"
   :translations
   ((do . "They shall mourn for Him * as one mourneth for his only son, for the innocent Lord hath been put to death."))))

(bcp-roman-antiphonary-register
 'attendite-universi-populi
 '(:latin "Atténdite * univérsi pópuli, et vidéte dolórem meum."
   :source paraphrase
   :ref "Lam 1:18"
   :translations
   ((do . "O all ye nations, behold * and see my sorrow."))))

(bcp-roman-antiphonary-register
 'a-porta-inferi
 '(:latin "A porta ínferi * érue, Dómine, ánimam meam."
   :source composition
   :translations
   ((do . "O Lord, deliver my soul * from the gates of the grave."))))

(bcp-roman-antiphonary-register
 'o-vos-omnes-qui-transitis
 '(:latin "O vos omnes, * qui transítis per viam, atténdite et vidéte, si est dolor sicut dolor meus."
   :source vulgate
   :ref "Lam 1:12"
   :translations
   ((do . "O all ye that pass by * behold, and see if there be any sorrow like unto my sorrow."))))

;;; Holy Saturday Benedictus antiphon

(bcp-roman-antiphonary-register
 'mulieres-sedentes
 '(:latin "Mulíeres * sedéntes ad monuméntum lamentabántur, flentes Dóminum."
   :source composition
   :translations
   ((do . "There were women sitting over against the sepulchre * weeping, and making lamentation for the Lord."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Mon–Wed Holy Week collect registrations

(bcp-roman-collectarium-register
 'da-quaesumus-omnipotens-deus-ut-qui
 (list :latin (concat
              "Da, quǽsumus, omnípotens Deus: ut, qui in tot advérsis ex nostra \
infirmitáte defícimus; intercedénte unigéniti Fílii tui passióne respirémus:\n"
              bcp-roman-qui-tecum)
       :conclusion 'qui-tecum
       :translations
       '((bute . "O Almighty God, Which knowest that we be set in such straits \
that we have no power of ourselves to help ourselves, we pray thee mercifully \
to relieve us, for whom continually pleadeth the suffering of thine Only \
Begotten Son.\nWho liveth and reigneth with Thee."))))

(bcp-roman-collectarium-register
 'adjuva-nos-deus-salutaris
 (list :latin (concat
              "Adjuva nos, Deus, salutáris noster: et ad benefícia recolénda, \
quibus nos instauráre dignátus es, tríbue veníre gaudéntes.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((bute . "Help us, O God of our salvation, and grant us grace to draw \
near with joy to the memorial of thy great mercies whereby Thou wast pleased \
to make us new creatures.\nThrough our Lord."))))

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-da-nobis-dominicae
 (list :latin (concat
              "Omnípotens sempitérne Deus: da nobis ita Domínicæ passiónis \
sacraménta perágere; ut indulgéntiam percípere mereámur.\n"
              bcp-roman-per-eumdem)
       :conclusion 'per-eumdem
       :translations
       '((bute . "O Almighty and everlasting God, give us grace so to use the \
solemn and mysterious memorial of the Lord's Suffering, that the same may be \
unto us a mean whereby worthily to win thy forgiveness.\nThrough the same Lord."))))

(bcp-roman-collectarium-register
 'tua-nos-misericordia
 (list :latin (concat
              "Tua nos misericórdia, Deus, et ab omni subreptióne vetustátis \
expúrget: et capáces sanctæ novitátis effíciat.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((bute . "May thy mercy, O God, cleanse us from the deceits of our old \
nature, and enable us to be formed anew unto holiness.\nThrough our Lord."))))

(bcp-roman-collectarium-register
 'praesta-quaesumus-omnipotens-deus-ut-nostris
 (list :latin (concat
              "Præsta, quǽsumus, omnípotens Deus: ut, qui nostris excéssibus \
incessánter afflígimur, per unigéniti Fílii tui passiónem liberémur:\n"
              bcp-roman-qui-tecum)
       :conclusion 'qui-tecum
       :translations
       '((bute . "O Almighty God, we beseech Thee that we whose transgressions \
do unceasingly harm us, may find freedom in the Suffering of Thine \
Only-begotten Son.\nWho liveth and reigneth with Thee."))))

(bcp-roman-collectarium-register
 'respice-quaesumus-domine-super-hanc
 (list :latin (concat
              "Réspice, quǽsumus, Dómine, super hanc famíliam tuam, pro qua \
Dóminus noster Jesus Christus non dubitávit mánibus tradi nocéntium, et crucis \
subíre torméntum:\n"
              bcp-roman-qui-tecum)
       :conclusion 'qui-tecum
       :translations
       '((bute . "O Lord, we beseech Thee, behold this Thy family, for which \
our Lord Jesus Christ was contented to be betrayed, and given up into the \
hands of wicked men, and to suffer death upon the Cross.\nWho liveth and \
reigneth with Thee."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Monday of Holy Week antiphon registrations

(bcp-roman-antiphonary-register
 'faciem-meam-non-averti
 '(:latin "Fáciem meam * non avérti ab increpántibus, et conspuéntibus in me."
   :source composition
   :ref "Isa 50:6"
   :translations
   ((do . "I hid not my face * from shame and spitting."))))

(bcp-roman-antiphonary-register
 'framea-suscitare
 '(:latin "Frámea, suscitáre * advérsus eos, qui dispérgunt gregem meum."
   :source composition
   :ref "Zech 13:7"
   :translations
   ((do . "Awake, O sword, * against them that scatter my flock."))))

(bcp-roman-antiphonary-register
 'appenderunt-mercedem
 '(:latin "Appendérunt * mercédem meam trigínta argénteis: quibus appretiátus sum ab eis."
   :source composition
   :ref "Zech 11:12"
   :translations
   ((do . "They took the thirty pieces of silver, * my price, that I was prized at of them."))))

(bcp-roman-antiphonary-register
 'inundaverunt-aquae
 '(:latin "Inundavérunt aquæ * super caput meum: dixi, Périi: invocábo nomen tuum, Dómine Deus."
   :source composition
   :ref "Lam 3:54"
   :translations
   ((do . "Waters flowed over mine head; * I said I am cut off; I will call upon thy Name, O Lord God."))))

(bcp-roman-antiphonary-register
 'labia-insurgentium
 '(:latin "Lábia insurgéntium, * et cogitatiónes eórum vide, Dómine."
   :source composition
   :ref "Lam 3:61-62"
   :translations
   ((do . "O Lord, behold the lips * of those that rose up against me, and their device."))))

(bcp-roman-antiphonary-register
 'clarifica-me-pater
 '(:latin "Clarífica me, Pater, * apud temetípsum claritáte, quam hábui priúsquam mundus fíeret."
   :source composition
   :ref "John 17:5"
   :translations
   ((do . "And now, O Father, glorify Thou Me * with thine Own Self, with the glory which I had with thee before the world was."))))

(bcp-roman-antiphonary-register
 'non-haberes-in-me
 '(:latin "Non habéres * in me potestátem, nisi désuper tibi datum fuísset."
   :source composition
   :ref "John 19:11"
   :translations
   ((do . "Thou couldest have no power * at all against Me, except it were given thee from above."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Tuesday of Holy Week antiphon registrations

(bcp-roman-antiphonary-register
 'vide-domine-et-considera
 '(:latin "Vide, Dómine, * et consídera, quóniam tríbulor: velóciter exáudi me."
   :source composition
   :ref "Lam 1:11, Ps 68:18"
   :translations
   ((do . "Behold, O Lord, and see, * for I am in trouble; hear me speedily."))))

(bcp-roman-antiphonary-register
 'discerne-causam-meam-domine
 '(:latin "Discérne causam meam, * Dómine: ab hómine iníquo et dolóso éripe me."
   :source gallican
   :ref "Ps 42:1"
   :translations
   ((do . "Plead my cause, * O Lord; deliver me from the unjust and deceitful man."))))

(bcp-roman-antiphonary-register
 'dum-tribularer-clamavi
 '(:latin "Dum tribulárer, * clamávi ad Dóminum de ventre ínferi, et exaudívit me."
   :source composition
   :ref "Jonah 2:3"
   :translations
   ((do . "I cried by reason of mine affliction unto the Lord, * and He heard me out of the belly of hell."))))

(bcp-roman-antiphonary-register
 'domine-vim-patior
 '(:latin "Dómine, vim pátior, * respónde pro me: quia néscio quid dicam inimícis meis."
   :source composition
   :ref "Isa 38:14"
   :translations
   ((do . "O Lord, I am oppressed, * undertake Thou for me; for I know not what to say unto mine enemies."))))

(bcp-roman-antiphonary-register
 'dixerunt-impii-opprimamus
 '(:latin "Dixérunt ímpii: * Opprimámus virum justum, quóniam contrárius est opéribus nostris."
   :source composition
   :ref "Wis 2:12"
   :translations
   ((do . "The ungodly said Let us oppress the righteous man, * because he is clean contrary to our doings."))))

(bcp-roman-antiphonary-register
 'ante-diem-festum-paschae
 '(:latin "Ante diem festum * Paschæ, sciens Jesus quia venit hora ejus, cum dilexísset suos, in finem diléxit eos."
   :source composition
   :ref "John 13:1"
   :translations
   ((do . "Now, before the Feast of the Passover, as Jesus knew that His hour was come, * having loved His Own which were in the world, He loved them unto the end."))))

(bcp-roman-antiphonary-register
 'potestatem-habeo
 '(:latin "Potestátem hábeo * ponéndi ánimam meam, et íterum suméndi eam."
   :source composition
   :ref "John 10:18"
   :translations
   ((do . "I have power * to lay down my life: and to take it up again."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Wednesday of Holy Week antiphon registrations

(bcp-roman-antiphonary-register
 'libera-me-de-sanguinibus
 '(:latin "Líbera me * de sanguínibus, Deus, Deus meus: et exsultábit lingua mea justítiam tuam."
   :source gallican
   :ref "Ps 50:16"
   :translations
   ((do . "Deliver me * from blood, O God, thou God of my salvation: and my tongue shall extol thy justice."))))

(bcp-roman-antiphonary-register
 'contumelias-et-terrores
 '(:latin "Contumélias * et terróres passus sum ab eis: et Dóminus mecum est tamquam bellátor fortis."
   :source composition
   :ref "Jer 20:10-11"
   :translations
   ((do . "I received * injuries and terrors from them: but the Lord is with me as a strong warrior."))))

(bcp-roman-antiphonary-register
 'tu-autem-domine-scis-omne
 '(:latin "Tu autem, Dómine, * scis omne consílium eórum advérsum me in mortem."
   :source composition
   :ref "Jer 18:23"
   :translations
   ((do . "But thou, O Lord, * knowest all their plans to put me to death."))))

(bcp-roman-antiphonary-register
 'omnes-inimici-mei
 '(:latin "Omnes inimíci mei * audiérunt malum meum: Dómine, lætáti sunt, quóniam tu fecísti."
   :source composition
   :ref "Lam 1:21"
   :translations
   ((do . "All my enemies have heard of my evil, * they have rejoiced that thou, O Lord, hast done it."))))

(bcp-roman-antiphonary-register
 'fac-domine-judicium
 '(:latin "Fac, Dómine, * judícium injúriam patiéntibus: et vias peccatórum dispérde."
   :source composition
   :ref "Ps 145:7-9"
   :translations
   ((do . "The Lord helpeth them * to right that suffer wrong, but as for the way of the ungodly, he turneth it upside down."))))

(bcp-roman-antiphonary-register
 'simon-dormis
 '(:latin "Simon, dormis? * non potuísti una hora vigiláre mecum?"
   :source composition
   :ref "Mark 14:37"
   :translations
   ((do . "Simon, do you sleep? * Could you not watch one hour with me?"))))

(bcp-roman-antiphonary-register
 'ancilla-dixit-petro
 '(:latin "Ancílla dixit * Petro: Vere tu ex illis es: nam et loquéla tua maniféstum te facit."
   :source composition
   :ref "Matt 26:73"
   :translations
   ((do . "The handmaid said to Peter: * Surely thou also art one of them; for even thy speech doth discover thee."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Mon–Wed Holy Week weekday propers
;;
;; Each day: (:name, :name-en, :lessons (3), :responsories (3),
;;   :lauds-antiphons (5), :benedictus-antiphon, :magnificat-antiphon,
;;   :collect, :vespers-collect)
;;
;; These are ferial days with proper homily/scripture lessons (not the
;; standard lectio brevis).  The existing 1-nocturn ordo builder handles
;; the structure; psalms come from the weekly psalterium.

(defconst bcp-roman-season-holyweek--weekday-propers
  `(

    ;; ════════════════════════════════════════════════════════════════════════
    ;; MONDAY — Feria Secunda Majoris Hebdomadæ
    ;; ════════════════════════════════════════════════════════════════════════

    (mon
     . (:name "Feria Secunda Majoris Hebdomadæ"
        :name-en "Monday of Holy Week"

        ;; ── Lessons (Augustine on John) ──────────────────────────────────
        :lessons
        ((:source "Augustine, Tract. 50 in Joann."
          :text "Léctio sancti Evangélii secúndum Joánnem.\n¶ Joann. 12, 1-9.\nAnte sex dies Paschæ venit Jesus Bethániam, ubi Lázarus fúerat mórtuus, quem suscitávit Jesus. Et réliqua.\n\nHomilía sancti Augustíni Epíscopi.\n¶ Tractus 50 in Joann., post initium.\nNe putárent hómines phantásma esse factum, quia mórtuus resurréxit, Lázarus unus erat ex recumbéntibus: vivébat, loquebátur, epulabátur, véritas ostendebátur, infidélitas Judæórum confundebátur. Discumbébat ergo Jesus cum Lázaro, et céteris: ministrábat Martha, una ex soróribus Lázari. María vero, áltera soror Lázari, accépit libram unguénti nardi pístici pretiósi, et unxit pedes Jesu, et extérsit capíllis suis pedes ejus, et domus impléta est ex odóre unguénti. Factum audívimus: mystérium requirámus."
          :text-en "Continuation of the Holy Gospel according to John.\n¶ John 12:1-9.\nSix days before the pasch, Jesus came to Bethania, where Lazarus had been dead, whom Jesus raised to life.\n\nHomily by St. Augustine, Bishop (of Hippo.)\n¶ 50th Tract on John.\nThere they made Him a supper and Lazarus was one of them that sat at the table lest men should deem that it was but by an ocular delusion that they had seen him arise from the dead. He lived therefore, spake, and ate; to the manifestation of the truth, and the confusion of the unbelieving Jews. Jesus, then, sat down to meat with Lazarus and others, and Martha, being one of Lazarus' sisters, served. But Mary, Lazarus' other sister, took a pound of ointment of spikenard, very costly, and anointed the Feet of Jesus, and wiped His Feet with her hair; and the house was filled with the odour of the ointment. We have now heard that which was done; let us search out the mystic meaning thereof.")

         (:source "Augustine, Tract. 50 in Joann."
          :text "Quæcúmque ánima fidélis vis esse, cum María unge pedes Dómini pretióso unguénto. Unguéntum illud justítia fuit, ídeo libra fuit: erat autem unguéntum nardi pístici pretiósi. Quod ait, pístici, locum áliquem crédere debémus, unde hoc erat unguéntum pretiósum: nec tamen hoc vacat, et sacraménto óptime cónsonat. Pistis Græce, fides Latíne dícitur. Quærébas operári justítiam. Justus ex fide vivit. Unge pedes Jesu bene vivéndo: Domínica sectáre vestígia. Capíllis terge: si habes supérflua, da paupéribus, et Dómini pedes tersísti: capílli enim supérflua córporis vidéntur. Habes quod agas de supérfluis tuis: tibi supérflua sunt, sed Dómini pédibus necessária sunt. Forte in terra Dómini pedes índigent."
          :text-en "Whatsover thou art that wilt be a faithful soul, seek with Mary to anoint the Feet of the Lord with costly ointment. This ointment was a figure of justice, and therefore is there said to have been a pound thereof, a pound being a weight used in scales. The word pistikes used by the Evangelist as the name of this ointment, we must believe to be that of some place, from which this costly perfume was imported. Neither is this name meaningless for us, but agreeth well with our mystic interpretation, since Pistis is the Greek word which signifieth Faith, and whosoever will do justice must know that: The just shall live by faith. Anoint therefore the Feet of Jesus by thy good life, following in the marks which those Feet of the Lord have traced. Wipe His Feet likewise with thy hair; that is, if thou have aught which is not needful to thee, give it to the poor; and then thou hast wiped the Feet of Jesus with thy hair, that is, with that which thou needest not, and which is therefore to thee as is hair, being a needless out-growth to the body. Here thou hast what to do with that which thou needest not. To thee it is needless, but the Lord's Feet have need of it; yea, the Feet which the Lord hath on earth are sorely needy.")

         (:source "Augustine, Tract. 50 in Joann."
          :text "De quibus enim, nisi de membris suis in fine dictúrus est: Cum uni ex mínimis meis fecístis, mihi fecístis? Supérflua vestra impendístis: sed pédibus meis obsecúti estis. Domus autem impléta est odóre: mundus implétus est fama bona: nam odor bonus, fama bona est. Qui male vivunt, et Christiáni vocántur, injúriam Christo fáciunt: de quálibus dictum est, quod per eos nomen Dómini blasphemátur. Si per tales nomen Dei blasphemátur, per bonos nomen Dómini laudátur. Audi Apóstolum: Christi bonus odor sumus, inquit, in omni loco."
          :text-en "For of whom save of His members, will He say at the latter day: Inasmuch as ye have done it unto one of the least of these My brethren, ye have done it unto Me. That is, ye have spent nothing save that which ye needed not, but ye have ministered unto My Feet. And the house was filled with the odour of the ointment. That is, the fragrance of your good example filleth the world; for this odour is a figure of reputation. They which are called Christians, and yet live bad lives, cast a slur on Christ and it is even such as they unto whom it is said: The Name of God is blasphemed among the Gentiles through you. But if, through such, the Name of God be blasphemed, through the godly is praise ascribed to the Same His Holy Name, as the Apostle doth likewise say: In every place we are unto God a sweet savour of Christ, in them that are saved, and in them that perish."))

        ;; ── Responsories ─────────────────────────────────────────────────
        :responsories
        ((:respond "Viri ímpii dixérunt: Opprimámus virum justum injúste, et deglutiámus eum tamquam inférnus vivum: auferámus memóriam illíus de terra: et de spóliis ejus sortem mittámus inter nos: ipsi enim homicídæ thesaurizavérunt sibi mala." :verse "Hæc cogitavérunt, et erravérunt: et excæcávit illos malítia eórum." :repeat "Insipiéntes et malígni odérunt sapiéntiam: et rei facti sunt in cogitatiónibus suis."
          :respond-en "The ungodly said: Let us oppress the righteous man without cause, and swallow him up alive, as the grave; let us make his memorial to perish from the earth, and cast lots among us for his spoils and those murderers laid by store for themselves, but of evil." :verse-en "Such things they did imagine, and were deceived, for their own wickedness blinded them." :repeat-en "Fools and haters loathe wisdom, and are guilty in their thoughts.")  ; R1

         (:respond "Oppróbrium factus sum nimis inimícis meis: vidérunt me, et movérunt cápita sua:" :verse "Locúti sunt advérsum me lingua dolósa, et sermónibus ódii circumdedérunt me." :repeat "Adjuva me, Dómine, Deus meus."
          :respond-en "I became a reproach unto mine enemies they looked upon me and shaked their heads." :verse-en "They have spoken against me with a lying tongue they compassed me about also with words of hatred." :repeat-en "Help me, O Lord my God!")  ; R2

         (:respond "Insurrexérunt in me viri iníqui absque misericórdia, quæsiérunt me interfícere: et non pepercérunt in fáciem meam spúere, et lánceis suis vulneravérunt me: et concússa sunt ómnia ossa mea:" :verse "Effudérunt furórem suum in me: fremuérunt contra me déntibus suis." :repeat "Ego autem existimábam me tamquam mórtuum super terram." :gloria t
          :respond-en "False witnesses are risen up against me, and such as breathe out cruelty they have gone about to kill me, neither spared they to spit in my face; their spears have wounded me, and all my bones are out of joint." :verse-en "They poured forth their fury upon me, they gnashed upon me with their teeth." :repeat-en "But as for me, I counted myself as one that is dead upon the earth."))  ; R3

        ;; ── Lauds ────────────────────────────────────────────────────────
        :lauds-antiphons (faciem-meam-non-averti
                          framea-suscitare
                          appenderunt-mercedem
                          inundaverunt-aquae
                          labia-insurgentium)
        :benedictus-antiphon clarifica-me-pater
        :magnificat-antiphon non-haberes-in-me

        ;; ── Collect ──────────────────────────────────────────────────────
        :collect da-quaesumus-omnipotens-deus-ut-qui
        :vespers-collect adjuva-nos-deus-salutaris
        ))

    ;; ════════════════════════════════════════════════════════════════════════
    ;; TUESDAY — Feria Tertia Majoris Hebdomadæ
    ;; ════════════════════════════════════════════════════════════════════════

    (tue
     . (:name "Feria Tertia Majoris Hebdomadæ"
        :name-en "Tuesday of Holy Week"

        ;; ── Lessons (Jeremiah) ───────────────────────────────────────────
        :lessons
        ((:source "Jeremiah"
          :ref "Jer 11:15-20"
          :text "De Jeremía Prophéta.\n¶ Jer. 11, 15-20.\nQuid est quod diléctus meus in domo mea fecit scélera multa? Numquid carnes sanctæ áuferent a te malítias tuas, in quibus gloriáta es? Olívam úberem, pulchram, fructíferam, speciósam vocávit Dóminus nomen tuum: ad vocem loquélæ, grandis exársit ignis in ea, et combústa sunt frutéta ejus. Et Dóminus exercítuum, qui plantávit te, locútus est super te malum: pro malis domus Israël et domus Juda, quæ fecérunt sibi ad irritándum me, libántes Báalim. Tu autem, Dómine, demonstrásti mihi, et cognóvi: tunc ostendísti mihi stúdia eórum. Et ego quasi agnus mansuétus, qui portátur ad víctimam: et non cognóvi quia cogitavérunt super me consília, dicéntes: Mittámus lignum in panem ejus, et eradámus eum de terra vivéntium, et nomen ejus non memorétur ámplius. Tu autem, Dómine Sábaoth, qui júdicas juste, et probas renes et corda, vídeam ultiónem tuam ex eis: tibi enim revelávi causam meam."
          :text-en "Lesson from the book of Jeremias.\n¶ Jer. 11:15-20.\nWhat is the meaning that my beloved hath wrought much wickedness in my house? shall the holy flesh take away from thee thy crimes, in which thou hast boasted? The Lord called thy name, a plentiful olive tree, fair, fruitful, and beautiful: at the noise of a word, a great fire was kindled in it and the branches thereof are burnt. And the Lord of hosts that planted thee, hath pronounced evil against thee: for the evils of the house of Israel, and the house of Juda, which they have done to themselves, to provoke me, offering sacrifice to Baalim. But thou, O Lord, hast shewn me, and I have known: then thou shewedst me their doings. And I was as a meek lamb, that is carried to be a victim: and I knew not that they had devised counsels against me, saying: Let us put wood on his bread, and cut him off from the land of the living, and let his name be remembered no more. But thou, O Lord of Sabaoth, who judgest justly, and triest the reins and hearts, let me see thy revenge on them: for to thee I have revealed my cause.")

         (:source "Jeremiah"
          :ref "Jer 12:1-4"
          :text "¶ Jer. 12, 1-4.\nJustus quidem tu es, Dómine, si dispútem tecum: verúmtamen justa loquar ad te: Quare via impiórum prosperátur: bene est ómnibus, qui prævaricántur, et iníque agunt? Plantásti eos, et radícem misérunt: profíciunt et fáciunt fructum: prope es tu ori eórum, et longe a rénibus eórum. Et tu, Dómine, nosti me, vidísti me, et probásti cor meum tecum: cóngrega eos quasi gregem ad víctimam, et sanctífica eos in die occisiónis. Usquequo lugébit terra, et herba omnis regiónis siccábitur propter malítiam habitántium in ea? Consúmptum est ánimal et vólucre, quóniam dixérunt: Non vidébit novíssima nostra."
          :text-en "¶ Jer. 12:1-4.\nThou indeed, O Lord, art just, if I plead with thee, but yet I will speak what is just to thee: Why doth the way of the wicked prosper: why is it well with all them that transgress, and do wickedly? Thou hast planted them, and they have taken root: they prosper and bring forth fruit: thou art near in their mouth, and far from their reins. And thou, O Lord, hast known me, thou hast seen me, and proved my heart with thee: gather them together as sheep for a sacrifice, and prepare them for the day of slaughter. How long shall the land mourn, and the herb of every field wither for the wickedness of them that dwell therein? The beasts and the birds are consumed: because they have said: He shall not see our last end.")

         (:source "Jeremiah"
          :ref "Jer 12:7-11"
          :text "¶ Jer. 12, 7-11.\nRelíqui domum meam, dimísi hereditátem meam: dedi diléctam ánimam meam in manu inimicórum ejus. Facta est mihi heréditas mea quasi leo in silva: dedit contra me vocem, ídeo odívi eam. Numquid avis díscolor heréditas mea mihi? numquid avis tincta per totum? Veníte, congregámini, omnes béstiæ terræ, properáte ad devorándum. Pastóres multi demolíti sunt víneam meam, conculcavérunt partem meam: dedérunt portiónem meam desiderábilem in desértum solitúdinis. Posuérunt eam in dissipatiónem, luxítque super me: desolatióne desoláta est omnis terra, quia nullus est qui recógitet corde."
          :text-en "¶ Jer. 12:7-11.\nI have forsaken my house, I have left my inheritance: I have given my dear soul into the land of her enemies. My inheritance is become to me as a lion in the wood: it hath cried out against me, therefore have I hated it. Is my inheritance to me as a speckled bird? Is it as a bird died throughout? come ye, assemble yourselves, all the beasts of the earth, make haste to devour. Many pastors have destroyed my vineyard, they have trodden my portion under foot: they have changed my delightful portion into a desolate wilderness. They have laid it waste, and it hath mourned for me. With desolation is all the land made desolate; because there is none that considereth in the heart."))

        ;; ── Responsories ─────────────────────────────────────────────────
        :responsories
        ((:respond "Contumélias et terróres passus sum ab eis, qui erant pacífici mei, et custodiéntes latus meum, dicéntes: Decipiámus eum, et prævaleámus illi: sed tu, Dómine, mecum es tamquam bellátor fortis." :verse "Júdica, Dómine, causam ánimæ meæ, defénsor vitæ meæ." :repeat "Cadant in oppróbrium sempitérnum, ut vídeam vindíctam in eis, quia tibi revelávi causam meam."
          :respond-en "I have suffered defaming and fear from them that were my familiars they watched for my halting, saying Let us entice him, and prevail against him. But Thou, O Lord, art with me, as a Mighty Terrible One." :verse-en "O Lord, plead Thou the cause of my soul, Thou That art the Redeemer of my life." :repeat-en "Let them stumble into everlasting confusion, that I may see thy vengeance upon them, for unto thee have I opened my cause.")  ; R1

         (:respond "Deus Israël, propter te sustínui impropérium, opéruit reveréntia fáciem meam, extráneus factus sum frátribus meis, et hospes fíliis matris meæ:" :verse "Inténde ánimæ meæ, et líbera eam, propter inimícos meos éripe me." :repeat "Quóniam zelus domus tuæ comédit me."
          :respond-en "For thy sake, O God of Israel, I have borne reproach; shame hath covered my face; I am become a stranger unto my brethren, and an alien unto my mother's children." :verse-en "Draw nigh unto my soul, and redeem it; deliver me, because of mine enemies." :repeat-en "For the zeal of thine house hath eaten me up.")  ; R2

         (:respond "Synagóga populórum circumdedérunt me: et non réddidi retribuéntibus mihi mala." :verse "Júdica me, Dómine, secúndum justítiam meam, et secúndum innocéntiam meam super me." :repeat "Consumétur, Dómine, nequítia peccatórum, et díriges justum." :gloria t
          :respond-en "The congregation of the people hath compassed me about, but I rewarded no evil unto him that rewarded evil unto me." :verse-en "Judge me, O Lord, according to my righteousness, and according to mine integrity that is in me." :repeat-en "O Lord, let the wickedness of the wicked come to an end, but establish the just."))  ; R3

        ;; ── Lauds ────────────────────────────────────────────────────────
        :lauds-antiphons (vide-domine-et-considera
                          discerne-causam-meam-domine
                          dum-tribularer-clamavi
                          domine-vim-patior
                          dixerunt-impii-opprimamus)
        :benedictus-antiphon ante-diem-festum-paschae
        :magnificat-antiphon potestatem-habeo

        ;; ── Collect ──────────────────────────────────────────────────────
        :collect omnipotens-sempiterne-deus-da-nobis-dominicae
        :vespers-collect tua-nos-misericordia
        ))

    ;; ════════════════════════════════════════════════════════════════════════
    ;; WEDNESDAY — Feria Quarta Majoris Hebdomadæ
    ;; ════════════════════════════════════════════════════════════════════════

    (wed
     . (:name "Feria Quarta Majoris Hebdomadæ"
        :name-en "Wednesday of Holy Week"

        ;; ── Lessons (Jeremiah) ───────────────────────────────────────────
        :lessons
        ((:source "Jeremiah"
          :ref "Jer 17:13-18"
          :text "De Jeremía Prophéta.\n¶ Jer. 17, 13-18.\nExspectátio Israël, Dómine: omnes, qui te derelínquunt, confundéntur: recedéntes a te, in terra scribéntur: quóniam dereliquérunt venam aquárum vivéntium Dóminum. Sana me, Dómine, et sanábor: salvum me fac, et salvus ero: quóniam laus mea tu es. Ecce ipsi dicunt ad me: Ubi est verbum Dómini? véniat. Et ego non sum turbátus, te pastórem sequens: et diem hóminis non desiderávi, tu scis. Quod egréssum est de lábiis meis, rectum in conspéctu tuo fuit. Non sis tu mihi formídini, spes mea tu in die afflictiónis. Confundántur qui me persequúntur, et non confúndar ego: páveant illi, et non páveam ego: induc super eos diem afflictiónis, et dúplici contritióne cóntere eos."
          :text-en "Lesson from the book of Jeremias.\n¶ Jer. 17:13-18.\nO Lord, the hope of Israel: all that forsake thee shall be confounded: they that depart from thee, shall be written in the earth: because they have forsaken the Lord, the vein of living waters. Heal me, O Lord, and I shall be healed: save me, and I shall be saved, for thou art my praise. Behold they say to me: Where is the word of the Lord? let it come. And I am not troubled, following thee for my pastor, and I have not desired the day of man, thou knowest. That which went out of my lips, hath been right in thy sight. Be not thou a terror unto me, thou art my hope in the day of affliction. Let them be confounded that persecute me, and let not me be confounded: let them be afraid, and let not me be afraid: bring upon them the day of affliction, and with a double destruction, destroy them.")

         (:source "Jeremiah"
          :ref "Jer 18:13-18"
          :text "¶ Jer. 18, 13-18.\nQuis audívit tália horribília, quæ fecit nimis virgo Israël? Numquid defíciet de petra agri nix Líbani? aut evélli possunt aquæ erumpéntes frígidæ, et defluéntes? Quia oblítus est mei pópulus meus, frustra libántes, et impingéntes in viis suis, in sémitis sǽculi, ut ambulárent per eas in itínere non trito: ut fíeret terra eórum in desolatiónem, et in síbilum sempitérnum: omnis qui præteríerit per eam obstupéscet, et movébit caput suum. Sicut ventus urens dispérgam eos coram inimíco: dorsum, et non fáciem osténdam eis in die perditiónis eórum. Et dixérunt: Veníte et cogitémus contra Jeremíam cogitatiónes: non enim períbit lex a sacerdóte, neque consílium a sapiénte, nec sermo a prophéta: veníte, et percutiámus eum lingua, et non attendámus ad univérsos sermónes ejus."
          :text-en "¶ Jer. 18:13-18.\nThus saith the Lord: Ask among the nations: Who hath heard such horrible things, as the virgin of Israel hath done to excess? Shall the snow of Libanus fail from the rock of the field? or can the cold waters that gush out and run down, be taken away? Because my people have forgotten me, sacrificing in vain, and stumbling in their ways, in ancient paths, to walk by them in a way not trodden: That their land might be given up to desolation, and to a perpetual hissing: every one that shall pass by it, shall be astonished, and wag his head. As a burning will I scatter them before the enemy: I will shew them the back, and not the face, in the day of their destruction. And they said: Come, and let us invent devices against Jeremias: for the law shall not perish from the priest, nor counsel from the wise, nor the word from the prophet: come, and let us strike him with the tongue, and let us give no heed to all his words.")

         (:source "Jeremiah"
          :ref "Jer 18:19-23"
          :text "¶ Jer. 18, 19-23.\nAtténde, Dómine, ad me, et audi vocem adversariórum meórum. Numquid rédditur pro bono malum, quia fodérunt fóveam ánimæ meæ? Recordáre quod stéterim in conspéctu tuo, ut lóquerer pro eis bonum, et avérterem indignatiónem tuam ab eis. Proptérea da fílios eórum in famem, et deduc eos in manus gládii: fiant uxóres eórum absque líberis, et víduæ: et viri eárum interficiántur morte: júvenes eórum confodiántur gládio in prǽlio. Audiátur clamor de dómibus eórum: addúces enim super eos latrónem repénte: quia fodérunt fóveam ut cáperent me, et láqueos abscondérunt pédibus meis. Tu autem, Dómine, scis omne consílium eórum advérsum me in mortem: ne propitiéris iniquitáti eórum, et peccátum eórum a fácie tua non deleátur: fiant corruéntes in conspéctu tuo, in témpore furóris tui abútere eis."
          :text-en "¶ Jer. 18:19-23.\nGive heed to me, O Lord, and hear the voice of my adversaries. Shall evil be rendered for good, because they have digged a pit for my soul? Remember that I have stood in thy sight, to speak good for them, and turn away thy indignation from them. Therefore deliver up their children to famine, and bring them into the hands of the sword: let their wives be bereaved of children and widows: and let their husbands be slain by death: let their young men be stabbed with the sword in battle. Let a cry be heard out of their houses: for thou shalt bring the robber upon them suddenly: because they have digged a pit to take me, and have hid snares for my feet. But thou, O Lord, knowest all their counsel against me unto death: forgive not their iniquity, and let not their sin be blotted out from thy sight: let them be overthrown before thy eyes, in the time of thy wrath do thou destroy them."))

        ;; ── Responsories ─────────────────────────────────────────────────
        ;; R2 and R3 are borrowed from Palm Sunday (Quad6-0) R8 and R9
        :responsories
        ((:respond "Locúti sunt advérsum me lingua dolósa, et sermónibus ódii circumdedérunt me: pro eo ut me dilígerent, detrahébant mihi:" :verse "Et posuérunt advérsum me mala pro bonis, et ódium pro dilectióne mea." :repeat "Ego autem orábam, et exaudísti me, Dómine, Deus meus."
          :respond-en "They have spoken against me with a lying tongue; they compassed me about also with words of hatred: in return for my love they were my adversaries:" :verse-en "And they have rewarded me evil for good, and hatred for my love." :repeat-en "But I gave myself unto prayer; and Thou hast heard me, Lord my God!")  ; R1

         (:respond "Dixérunt ímpii apud se, non recte cogitántes: Circumveniámus justum, quóniam contrárius est opéribus nostris: promíttit se sciéntiam Dei habére, Fílium Dei se nóminat, et gloriátur patrem se habére Deum:" :verse "Tamquam nugáces æstimáti sumus ab illo, et ábstinet se a viis nostris tamquam ab immundítiis: et præfert novíssima justórum." :repeat "Videámus si sermónes illíus veri sunt: et si est vere Fílius Dei, líberet eum de mánibus nostris: morte turpíssima condemnémus eum."
          :respond-en "The ungodly said, reasoning with themselves, but not aright; Let us lie in wait for the righteous, because he is clean contrary to our doings he professeth to have the knowledge of God, he calleth himself the Son of God, and boasteth that he hath God to his Father." :verse-en "We are esteemed of him as counterfeits, and he abstaineth from our ways as from filthiness, and commendeth the end of the just." :repeat-en "Let us see if his words be true; and, if he be indeed the Son of God, let Him deliver him from our hand; let us condemn him with a shameful death.")  ; R2 (= Palm Sunday R8)

         (:respond "Circumdedérunt me viri mendáces: sine causa flagéllis cecidérunt me:" :verse "Quóniam tribulátio próxima est, et non est qui ádjuvet." :repeat "Sed tu, Dómine defénsor, víndica me." :gloria t
          :respond-en "Liars are come round about me, they have fallen upon me with scourges without a cause." :verse-en "For trouble is near, and there is none to help." :repeat-en "But do Thou, O Lord my Redeemer, avenge me!"))  ; R3 (= Palm Sunday R9)

        ;; ── Lauds ────────────────────────────────────────────────────────
        :lauds-antiphons (libera-me-de-sanguinibus
                          contumelias-et-terrores
                          tu-autem-domine-scis-omne
                          omnes-inimici-mei
                          fac-domine-judicium)
        :benedictus-antiphon simon-dormis
        :magnificat-antiphon ancilla-dixit-petro

        ;; ── Collect ──────────────────────────────────────────────────────
        :collect praesta-quaesumus-omnipotens-deus-ut-nostris
        :vespers-collect respice-quaesumus-domine-super-hanc
        ))

    )
  "Mon–Wed Holy Week weekday propers.
Each entry: (DAY-KEY . PLIST) where DAY-KEY is mon, tue, or wed.
These are ferial days with proper homily/scripture lessons.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sacred Triduum data
;;
;; Each day: (:name, :name-en, :psalms ((ant . ps) ...),
;;   :versicles, :lessons, :responsories, :lauds-antiphons,
;;   :lauds-versicle, :benedictus-antiphon, :oratio, :christus-factus)

(defconst bcp-roman-season-holyweek--triduum
  `(

    ;; ════════════════════════════════════════════════════════════════════════
    ;; MAUNDY THURSDAY — Feria Quinta in Cena Domini
    ;; ════════════════════════════════════════════════════════════════════════

    (thu
     . (:name "Feria Quinta in Cena Domini"
        :name-en "Maundy Thursday"

        ;; ── Matins psalms (9 proper) ──────────────────────────────────
        :psalms ((zelus-domus-tuae . 68)
                 (avertantur-retrorsum . 69)
                 (deus-meus-eripe-me . 70)
                 (liberavit-dominus-pauperem . 71)
                 (cogitaverunt-impii . 72)
                 (exsurge-domine-et-judica . 73)
                 (dixi-iniquis-nolite . 74)
                 (terra-tremuit . 75)
                 (in-die-tribulationis-meae-deum . 76))

        ;; ── Nocturn versicles ─────────────────────────────────────────
        :versicle-1 ("Avertántur retrórsum, et erubéscant."
                     . "Qui cógitant mihi mala.")
        :versicle-1-en ("Let them be turned backward and put to confusion."
                        . "That desire my hurt.")
        :versicle-2 ("Deus meus, éripe me de manu peccatóris."
                     . "Et de manu contra legem agéntis et iníqui.")
        :versicle-2-en ("Deliver me, O my God, out of the hand of the wicked."
                        . "Out of the hand of the unrighteous and cruel man.")
        :versicle-3 ("Exsúrge, Dómine."
                     . "Et júdica causam meam.")
        :versicle-3-en ("Arise, O Lord."
                        . "Judge Thou my cause.")

        ;; ── Lessons (9) ──────────────────────────────────────────────
        :lessons
        (
        ;; Nocturn I: Lamentations of Jeremiah (Lam 1:1-14)
        (:ref "Lam 1:1-5" :source "Incipit Lamentátio Jeremíæ Prophétæ"
         :text "ALEPH. Quómodo sedet sola cívitas plena pópulo: facta est quasi vídua dómina géntium: princeps provinciárum facta est sub tribúto.\nBETH. Plorans plorávit in nocte, et lácrimæ ejus in maxíllis ejus: non est qui consolétur eam ex ómnibus caris ejus: omnes amíci ejus sprevérunt eam, et facti sunt ei inimíci.\nGHIMEL. Migrávit Judas propter afflictiónem, et multitúdinem servitútis: habitávit inter gentes, nec invénit réquiem: omnes persecutóres ejus apprehendérunt eam inter angústias.\nDALETH. Viæ Sion lugent eo quod non sint qui véniant ad solemnitátem: omnes portæ ejus destrúctæ: sacerdótes ejus geméntes: vírgines ejus squálidæ, et ipsa oppréssa amaritúdine.\nHE. Facti sunt hostes ejus in cápite, inimíci ejus locupletáti sunt: quia Dóminus locútus est super eam propter multitúdinem iniquitátum ejus: párvuli ejus ducti sunt in captivitátem, ante fáciem tribulántis.\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L1
        (:ref "Lam 1:6-9"
         :text "VAU. Et egréssus est a fília Sion omnis decor ejus: facti sunt príncipes ejus velut aríetes non inveniéntes páscua: et abiérunt absque fortitúdine ante fáciem subsequéntis.\nZAIN. Recordáta est Jerúsalem diérum afflictiónis suæ, et prævaricatiónis ómnium desiderabílium suórum, quæ habúerat a diébus antíquis, cum cáderet pópulus ejus in manu hostíli, et non esset auxiliátor: vidérunt eam hostes, et derisérunt sábbata ejus.\nHETH. Peccátum peccávit Jerúsalem, proptérea instábilis facta est: omnes, qui glorificábant eam, sprevérunt illam, quia vidérunt ignomíniam ejus: ipsa autem gemens convérsa est retrórsum.\nTETH. Sordes ejus in pédibus ejus, nec recordáta est finis sui: depósita est veheménter, non habens consolatórem: vide, Dómine, afflictiónem meam, quóniam eréctus est inimícus.\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L2
        (:ref "Lam 1:10-14"
         :text "JOD. Manum suam misit hostis ad ómnia desiderabília ejus: quia vidit gentes ingréssas sanctuárium suum, de quibus præcéperas ne intrárent in ecclésiam tuam.\nCAPH. Omnis pópulus ejus gemens, et quærens panem: dedérunt pretiósa quæque pro cibo ad refocillándam ánimam. Vide, Dómine, et consídera, quóniam facta sum vilis.\nLAMED. O vos omnes, qui transítis per viam, atténdite, et vidéte, si est dolor sicut dolor meus: quóniam vindemiávit me, ut locútus est Dóminus in die iræ furóris sui.\nMEM. De excélso misit ignem in óssibus meis, et erudívit me: expándit rete pédibus meis, convértit me retrórsum: pósuit me desolátam, tota die mæróre conféctam.\nNUN. Vigilávit jugum iniquitátum meárum: in manu ejus convolútæ sunt, et impósitæ collo meo: infirmáta est virtus mea: dedit me Dóminus in manu, de qua non pótero súrgere.\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L3
        ;; Nocturn II: Augustine on Psalm 54
        (:source "Ex tractátu sancti Augustíni Epíscopi super Psalmos"
         :text "Exáudi, Deus, oratiónem meam, et ne despéxeris deprecatiónem meam: inténde mihi, et exáudi me. Satagéntis, sollíciti, in tribulatióne pósiti, verba sunt ista. Orat multa pátiens, de malo liberári desíderans. Súperest ut videámus in quo malo sit: et cum dícere cœ́perit, agnoscámus ibi nos esse: ut communicáta tribulatióne, conjungámus oratiónem. Contristátus sum, inquit, in exercitatióne mea, et conturbátus sum. Ubi contristátus? ubi conturbátus? In exercitatióne mea, inquit. Hómines malos, quos pátitur, commemorátus est: eandémque passiónem malórum hóminum exercitatiónem suam dixit. Ne putétis gratis esse malos in hoc mundo, et nihil boni de illis ágere Deum. Omnis malus aut ídeo vivit, ut corrigátur; aut ídeo vivit, ut per illum bonus exerceátur.")  ; L4
        (:text "Utinam ergo qui nos modo exércent, convertántur, et nobíscum exerceántur: tamen quámdiu ita sunt ut exérceant, non eos odérimus: quia in eo quod malus est quis eórum, utrum usque in finem perseveratúrus sit, ignorámus. Et plerúmque cum tibi vidéris odísse inimícum, fratrem odísti, et nescis. Diábolus, et ángeli ejus in Scriptúris sanctis manifestáti sunt nobis, quod ad ignem ætérnum sint destináti. Ipsórum tantum desperánda est corréctio, contra quos habémus occúltam luctam: ad quam luctam nos armat Apóstolus, dicens: Non est nobis colluctátio advérsus carnem et sánguinem: id est, non advérsus hómines, quos vidétis, sed advérsus príncipes, et potestátes, et rectóres mundi, tenebrárum harum. Ne forte cum dixísset, mundi, intellégeres dǽmones esse rectóres cæli et terræ. Mundi dixit, tenebrárum harum: mundi dixit, amatórum mundi: mundi dixit, impiórum et iniquórum: mundi dixit, de quo dicit Evangélium: Et mundus eum non cognóvit.")  ; L5
        (:text "Quóniam vidi iniquitátem, et contradictiónem in civitáte. Atténde glóriam crucis ipsíus. Jam in fronte regum crux illa fixa est, cui inimíci insultavérunt. Efféctus probávit virtútem: dómuit orbem non ferro, sed ligno. Lignum crucis contuméliis dignum visum est inimícis, et ante ipsum lignum stantes caput agitábant, et dicébant: Si Fílius Dei est, descéndat de cruce. Extendébat ille manus suas ad pópulum non credéntem, et contradicéntem. Si enim justus est, qui ex fide vivit; iníquus est, qui non habet fidem. Quod ergo hic ait, iniquitátem: perfídiam intéllege. Vidébat ergo Dóminus in civitáte iniquitátem et contradictiónem, et extendébat manus suas ad pópulum non credéntem et contradicéntem: et tamen et ipsos exspéctans dicébat: Pater, ignósce illis, quia nésciunt quid fáciunt.")  ; L6
        ;; Nocturn III: 1 Corinthians 11
        (:ref "1 Cor 11:17-22" :source "De Epístola prima beáti Pauli Apóstoli ad Corínthios"
         :text "17 Hoc autem præcípio: non laudans quod non in mélius, sed in detérius convenítis. 18 Primum quidem conveniéntibus vobis in Ecclésiam, áudio scissúras esse inter vos, et ex parte credo. 19 Nam opórtet et hǽreses esse, ut et qui probáti sunt, manifésti fiant in vobis. 20 Conveniéntibus ergo vobis in unum, jam non est Domínicam cenam manducáre. 21 Unusquísque enim suam cenam præsúmit ad manducándum. Et álius quidem ésurit, álius autem ébrius est. 22 Numquid domos non habétis ad manducándum et bibéndum? aut Ecclésiam Dei contémnitis, et confúnditis eos, qui non habent? Quid dicam vobis? Laudo vos? In hoc non laudo.")  ; L7
        (:ref "1 Cor 11:23-26"
         :text "23 Ego enim accépi a Dómino quod et trádidi vobis, quóniam Dóminus Jesus, in qua nocte tradebátur, accépit panem, 24 et grátias agens fregit, et dixit: Accípite, et manducáte: hoc est corpus meum, quod pro vobis tradétur: hoc fácite in meam commemoratiónem. 25 Simíliter et cálicem, postquam cœnávit, dicens: Hic calix novum testaméntum est in meo sánguine: hoc fácite, quotiescúmque bibétis, in meam commemoratiónem. 26 Quotiescúmque enim manducábitis panem hunc, et cálicem bibétis, mortem Dómini annuntiábitis donec véniat.")  ; L8
        (:ref "1 Cor 11:27-34"
         :text "27 Itaque quicúmque manducáverit panem hunc, vel bíberit cálicem Dómini indígne, reus erit córporis et sánguinis Dómini. 28 Probet autem seípsum homo: et sic de pane illo edat, et de cálice bibat. 29 Qui enim mandúcat et bibit indígne, judícium sibi mandúcat et bibit, non dijúdicans corpus Dómini. 30 Ideo inter vos multi infírmi et imbecílles, et dórmiunt multi. 31 Quod, si nosmetípsos dijudicarémus, non útique judicarémur. 32 Dum judicámur autem, a Dómino corrípimur, ut non cum hoc mundo damnémur. 33 Itaque, fratres mei, cum convenítis ad manducándum, ínvicem exspectáte. 34 Si quis ésurit, domi mandúcet: ut non in judícium conveniátis. Cétera autem, cum vénero, dispónam.")  ; L9
        )

        ;; ── Responsories (9) ─────────────────────────────────────────
        :responsories
        (
        (:respond "In monte Olivéti orávit ad Patrem: Pater, si fíeri potest, tránseat a me calix iste: * Spíritus quidem promptus est, caro autem infírma." :verse "Vigiláte, et oráte, ut non intrétis in tentatiónem." :repeat "Spíritus quidem promptus est, caro autem infírma.")  ; R1
        (:respond "Tristis est ánima mea usque ad mortem: sustinéte hic, et vigiláte mecum: nunc vidébitis turbam, quæ circúmdabit me: * Vos fugam capiétis, et ego vadam immolári pro vobis." :verse "Ecce appropínquat hora, et Fílius hóminis tradétur in manus peccatórum." :repeat "Vos fugam capiétis, et ego vadam immolári pro vobis.")  ; R2
        (:respond "Ecce vídimus eum non habéntem spéciem, neque decórem: aspéctus ejus in eo non est: hic peccáta nostra portávit, et pro nobis dolet: ipse autem vulnerátus est propter iniquitátes nostras: * Cujus livóre sanáti sumus." :verse "Vere languóres nostros ipse tulit, et dolóres nostros ipse portávit." :repeat "Cujus livóre sanáti sumus." :gloria t)  ; R3
        (:respond "Amicus meus ósculi me trádidit signo: Quem osculátus fúero, ipse est, tenéte eum: hoc malum fecit signum, qui per ósculum adimplévit homicídium. * Infélix prætermísit prétium sánguinis, et in fine láqueo se suspéndit." :verse "Bonum erat ei, si natus non fuísset homo ille." :repeat "Infélix prætermísit prétium sánguinis, et in fine láqueo se suspéndit.")  ; R4
        (:respond "Judas mercátor péssimus ósculo pétiit Dóminum: ille ut agnus ínnocens non negávit Judæ ósculum: * Denariórum número Christum Judǽis trádidit." :verse "Mélius illi erat, si natus non fuísset." :repeat "Denariórum número Christum Judǽis trádidit.")  ; R5
        (:respond "Unus ex discípulis meis tradet me hódie: Væ illi per quem tradar ego: * Mélius illi erat, si natus non fuísset." :verse "Qui intíngit mecum manum in parópside, hic me traditúrus est in manus peccatórum." :repeat "Mélius illi erat, si natus non fuísset." :gloria t)  ; R6
        (:respond "Eram quasi agnus ínnocens: ductus sum ad immolándum, et nesciébam: consílium fecérunt inimíci mei advérsum me, dicéntes: * Veníte, mittámus lignum in panem ejus, et eradámus eum de terra vivéntium." :verse "Omnes inimíci mei advérsum me cogitábant mala mihi: verbum iníquum mandavérunt advérsum me, dicéntes." :repeat "Veníte, mittámus lignum in panem ejus, et eradámus eum de terra vivéntium.")  ; R7
        (:respond "Una hora non potuístis vigiláre mecum, qui exhortabámini mori pro me? * Vel Judam non vidétis, quómodo non dormit, sed festínat trádere me Judǽis." :verse "Quid dormítis? súrgite, et oráte, ne intrétis in tentatiónem." :repeat "Vel Judam non vidétis, quómodo non dormit, sed festínat trádere me Judǽis.")  ; R8
        (:respond "Senióres pópuli consílium fecérunt, * Ut Jesum dolo tenérent, et occíderent: cum gládiis et fústibus exiérunt tamquam ad latrónem." :verse "Collegérunt pontífices et pharisǽi concílium." :repeat "Ut Jesum dolo tenérent, et occíderent: cum gládiis et fústibus exiérunt tamquam ad latrónem." :gloria t)  ; R9
        )

        ;; ── Lauds ────────────────────────────────────────────────────
        :lauds-antiphons (justificeris-domine
                          dominus-tamquam-ovis
                          contritum-est-cor-meum
                          exhortatus-es-in-virtute
                          oblatus-est-quia-ipse-voluit)
        :lauds-versicle ("Homo pacis meæ, in quo sperávi."
                         . "Qui edébat panes meos, ampliávit advérsum me supplantatiónem.")
        :lauds-versicle-en ("Mine own familiar friend, in whom I trusted;"
                            . "Which did eat of my bread, hath lifted up his heel against me.")
        :benedictus-antiphon traditor-autem-dedit

        ;; ── Vespers ──────────────────────────────────────────────────
        :vespers-antiphons ((calicem-salutaris . 115)
                            (cum-his-qui-oderunt . 119)
                            (ab-hominibus-iniquis . 139)
                            (custodi-me-a-laqueo . 140)
                            (considerabam-ad-dexteram . 141))
        :magnificat-antiphon cenantibus-autem-illis

        ;; ── Concluding prayer ────────────────────────────────────────
        :oratio "Réspice, quǽsumus, Dómine, super hanc famíliam tuam, pro qua Dóminus noster Jesus Christus non dubitávit mánibus tradi nocéntium, et crucis subíre torméntum:"
        :oratio-en "Look down, we beseech thee, O Lord, on this thy family, for which our Lord Jesus Christ did not hesitate to be delivered up into the hands of wicked men, and to suffer the torment of the Cross."
        :oratio-conclusion "Qui tecum"

        ;; ── Christus factus est (accumulative) ──────────────────────
        :christus-factus "Christus factus est pro nobis obédiens usque ad mortem."
        :christus-factus-en "Christ became obedient for us unto death."
        ))


    ;; ════════════════════════════════════════════════════════════════════════
    ;; GOOD FRIDAY — Feria Sexta in Parasceve
    ;; ════════════════════════════════════════════════════════════════════════

    (fri
     . (:name "Feria Sexta in Parasceve"
        :name-en "Good Friday"

        ;; ── Matins psalms (9 proper) ──────────────────────────────────
        :psalms ((astiterunt-reges-terrae . 2)
                 (diviserunt-sibi . 21)
                 (insurrexerunt-in-me . 26)
                 (vim-faciebant . 37)
                 (confundantur-et-revereantur . 39)
                 (alieni-insurrexerunt . 53)
                 (ab-insurgentibus-in-me . 58)
                 (longe-fecisti-notos . 87)
                 (captabunt-in-animam . 93))

        ;; ── Nocturn versicles ─────────────────────────────────────────
        :versicle-1 ("Divisérunt sibi vestiménta mea."
                     . "Et super vestem meam misérunt sortem.")
        :versicle-1-en ("They part my garments among them."
                        . "And cast lots upon my vesture.")
        :versicle-2 ("Insurrexérunt in me testes iníqui."
                     . "Et mentíta est iníquitas sibi.")
        :versicle-2-en ("False witnesses are risen up against me."
                        . "And iniquity hath belied itself.")
        :versicle-3 ("Locúti sunt advérsum me lingua dolósa."
                     . "Et sermónibus ódii circumdedérunt me, et expugnavérunt me gratis.")
        :versicle-3-en ("They have spoken against me with a lying tongue."
                        . "They compassed me about also with words of hatred, and fought against me without a cause.")

        ;; ── Lessons (9) ──────────────────────────────────────────────
        :lessons
        (
        ;; Nocturn I: Lamentations (Lam 2:8-11; 2:12-15; 3:1-9)
        (:ref "Lam 2:8-11" :source "De Lamentatióne Jeremíæ Prophétæ"
         :text "HETH. Cogitávit Dóminus dissipáre murum fíliæ Sion: teténdit funículum suum, et non avértit manum suam a perditióne: luxítque antemurále, et murus páriter dissipátus est.\nTETH. Defíxæ sunt in terra portæ ejus: pérdidit, et contrívit vectes ejus: regem ejus et príncipes ejus in géntibus: non est lex, et prophétæ ejus non invenérunt visiónem a Dómino.\nJOD. Sedérunt in terra, conticuérunt senes fíliæ Sion: conspersérunt cínere cápita sua, accíncti sunt cilíciis, abjecérunt in terram cápita sua vírgines Jerúsalem.\nCAPH. Defecérunt præ lácrimis óculi mei, conturbáta sunt víscera mea: effúsum est in terra jecur meum super contritióne fíliæ pópuli mei, cum defíceret párvulus et lactens in platéis óppidi.\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L1
        (:ref "Lam 2:12-15"
         :text "LAMED. Mátribus suis dixérunt: Ubi est tríticum et vinum? cum defícerent quasi vulneráti in platéis civitátis: cum exhalárent ánimas suas in sinu matrum suárum.\nMEM. Cui comparábo te? vel cui assimilábo te, fília Jerúsalem? cui exæquábo te, et consolábor te, virgo fília Sion? Magna est enim velut mare contrítio tua: quis medébitur tui?\nNUN. Prophétæ tui vidérunt tibi falsa et stulta, nec aperiébant iniquitátem tuam, ut te ad pœniténtiam provocárent: vidérunt autem tibi assumptiónes falsas, et ejectiónes.\nSAMECH. Plausérunt super te mánibus omnes transeúntes per viam: sibilavérunt, et movérunt caput suum super fíliam Jerúsalem: Hǽccine est urbs, dicéntes, perfécti decóris, gáudium univérsæ terræ?\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L2
        (:ref "Lam 3:1-9"
         :text "ALEPH. Ego vir videns paupertátem meam in virga indignatiónis ejus.\nALEPH. Me minávit, et addúxit in ténebras, et non in lucem.\nALEPH. Tantum in me vertit, et convértit manum suam tota die.\nBETH. Vetústam fecit pellem meam, et carnem meam, contrívit ossa mea.\nBETH. Ædificávit in gyro meo, et circúmdedit me felle et labóre.\nBETH. In tenebrósis collocávit me, quasi mórtuos sempitérnos.\nGHIMEL. Circumædificávit advérsum me, ut non egrédiar: aggravávit cómpedem meum.\nGHIMEL. Sed et, cum clamávero et rogávero, exclúsit oratiónem meam.\nGHIMEL. Conclúsit vias meas lapídibus quadris, sémitas meas subvértit.\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L3
        ;; Nocturn II: Augustine on Psalm 63
        (:source "Ex tractátu sancti Augustíni Epíscopi super Psalmos"
         :text "Protexísti me, Deus, a convéntu malignántium, a multitúdine operántium iniquitátem. Jam ipsum caput nostrum intueámur. Multi Mártyres tália passi sunt, sed nihil sic elúcet, quómodo caput Mártyrum: ibi mélius intuémur, quod illi expérti sunt. Protéctus est a multitúdine malignántium, protegénte se Deo, protegénte carnem suam ipso Fílio, et hómine, quem gerébat: quia fílius hóminis est, et Fílius Dei est. Fílius Dei, propter formam Dei: fílius hóminis, propter formam servi, habens in potestáte pónere ánimam suam, et recípere eam. Quid ei potuérunt fácere inimíci? Occidérunt corpus, ánimam non occidérunt. Inténdite. Parum ergo erat, Dóminum hortári Mártyres verbo, nisi firmáret exémplo.")  ; L4
        (:text "Nostis qui convéntus erat malignántium Judæórum, et quæ multitúdo erat operántium iniquitátem. Quam iniquitátem? Quia voluérunt occídere Dóminum Jesum Christum. Tanta ópera bona, inquit, osténdi vobis: propter quod horum me vultis occídere? Pértulit omnes infírmos eórum, curávit omnes lánguidos eórum, prædicávit regnum cælórum, non tácuit vítia eórum, ut ipsa pótius eis displicérent, non médicus, a quo sanabántur. His ómnibus curatiónibus ejus ingráti, tamquam multa febre phrenétici, insaniéntes in médicum, qui vénerat curáre eos, excogitavérunt consílium perdéndi eum: tamquam ibi voléntes probáre, utrum vere homo sit, qui mori possit, an áliquid super hómines sit, et mori se non permíttat. Verbum ipsórum agnóscimus in Sapiéntia Salomónis: Morte turpíssima, ínquiunt, condemnémus eum. Interrogémus eum: erit enim respéctus in sermónibus illíus. Si enim vere Fílius Dei est, líberet eum.")  ; L5
        (:text "Exacuérunt tamquam gládium linguas suas. Non dicant Judǽi: Non occídimus Christum. Etenim proptérea eum dedérunt júdici Piláto, ut quasi ipsi a morte ejus videréntur immúnes. Nam cum dixísset eis Pilátus: Vos eum occídite: respondérunt, Nobis non licet occídere quemquam. Iniquitátem facínoris sui in júdicem hóminem refúndere volébant: sed numquid Deum júdicem fallébant? Quod fecit Pilátus, in eo ipso quod fecit, aliquántum párticeps fuit: sed in comparatióne illórum multo ipse innocéntior. Institit enim quantum pótuit, ut illum ex eórum mánibus liberáret: nam proptérea flagellátum prodúxit ad eos. Non persequéndo Dóminum flagellávit, sed eórum furóri satisfácere volens: ut vel sic jam mitéscerent, et desínerent velle occídere, cum flagellátum vidérent. Fecit et hoc. At ubi perseveravérunt, nostis illum lavísse manus, et dixísse, quod ipse non fecísset, mundum se esse a morte illíus. Fecit tamen. Sed si reus, quia fecit vel invítus: illi innocéntes, qui coëgérunt ut fáceret? Nullo modo. Sed ille dixit in eum senténtiam, et jussit eum crucifígi, et quasi ipse occídit: et vos, o Judǽi, occidístis. Unde occidístis? Gládio linguæ: acuístis enim linguas vestras. Et quando percussístis, nisi quando clamástis: Crucifíge, crucifíge?")  ; L6
        ;; Nocturn III: Hebrews 4–5
        (:ref "Heb 4:11-15" :source "De Epístola beáti Pauli Apóstoli ad Hebrǽos"
         :text "11 Festinémus íngredi in illam réquiem: ut ne in idípsum quis íncidat incredulitátis exémplum. 12 Vivus est enim sermo Dei, et éfficax et penetrabílior omni gládio ancípiti: et pertíngens usque ad divisiónem ánimæ ac spíritus, compágum quoque ac medullárum, et discrétor cogitatiónum et intentiónum cordis. 13 Et non est ulla creatúra invisíbilis in conspéctu ejus: ómnia autem nuda et apérta sunt óculis ejus, ad quem nobis sermo. 14 Habéntes ergo Pontíficem magnum, qui penetrávit cælos, Jesum Fílium Dei: teneámus confessiónem. 15 Non enim habémus Pontíficem, qui non possit cómpati infirmitátibus nostris: tentátum autem per ómnia pro similitúdine absque peccáto.")  ; L7
        (:ref "Heb 4:16; 5:1-3"
         :text "16 Adeámus ergo cum fidúcia ad thronum grátiæ: ut misericórdiam consequámur, et grátiam inveniámus in auxílio opportúno. 1 Omnis namque Póntifex ex homínibus assúmptus, pro homínibus constitúitur in iis, quæ sunt ad Deum, ut ófferat dona, et sacrifícia pro peccátis: 2 qui condolére possit iis, qui ignórant et errant: quóniam et ipse circúmdatus est infirmitáte: 3 et proptérea debet quemádmodum pro pópulo, ita étiam pro semetípso offérre pro peccátis.")  ; L8
        (:ref "Heb 5:4-10"
         :text "4 Nec quisquam sumit sibi honórem, sed qui vocátur a Deo, tamquam Aaron. 5 Sic et Christus non semetípsum clarificávit ut Póntifex fíeret, sed qui locútus est ad eum: Fílius meus es tu, ego hódie génui te. 6 Quemádmodum et in álio loco dicit: Tu es sacérdos in ætérnum, secúndum órdinem Melchísedech. 7 Qui in diébus carnis suæ preces, supplicationésque ad eum, qui possit illum salvum fácere a morte, cum clamóre válido et lácrimis ófferens, exaudítus est pro sua reveréntia. 8 Et quidem cum esset Fílius Dei, dídicit ex iis, quæ passus est, obediéntiam: 9 et consummátus, factus est ómnibus obtemperántibus sibi causa salútis ætérnæ, 10 appellátus a Deo Póntifex juxta órdinem Melchísedech.")  ; L9
        )

        ;; ── Responsories (9) ─────────────────────────────────────────
        :responsories
        (
        (:respond "Omnes amíci mei dereliquérunt me, et prævaluérunt insidiántes mihi: trádidit me quem diligébam: * Et terribílibus óculis plaga crudéli percutiéntes, acéto potábant me." :verse "Inter iníquos projecérunt me, et non pepercérunt ánimæ meæ." :repeat "Et terribílibus óculis plaga crudéli percutiéntes, acéto potábant me.")  ; R1
        (:respond "Velum templi scissum est, * Et omnis terra trémuit: latro de cruce clamábat, dicens: Meménto mei, Dómine, dum véneris in regnum tuum." :verse "Petræ scissæ sunt, et monuménta apérta sunt, et multa córpora sanctórum, qui dormíerant, surrexérunt." :repeat "Et omnis terra trémuit: latro de cruce clamábat, dicens: Meménto mei, Dómine, dum véneris in regnum tuum.")  ; R2
        (:respond "Vínea mea elécta, ego te plantávi: * Quómodo convérsa es in amaritúdinem, ut me crucifígeres et Barábbam dimítteres?" :verse "Sepívi te, et lápides elégi ex te, et ædificávi turrim." :repeat "Quómodo convérsa es in amaritúdinem, ut me crucifígeres et Barábbam dimítteres?" :gloria t)  ; R3
        (:respond "Tamquam ad latrónem exístis cum gládiis et fústibus comprehéndere me: * Cotídie apud vos eram in templo docens, et non me tenuístis: et ecce flagellátum dúcitis ad crucifigéndum." :verse "Cumque injecíssent manus in Jesum, et tenuíssent eum, dixit ad eos." :repeat "Cotídie apud vos eram in templo docens, et non me tenuístis: et ecce flagellátum dúcitis ad crucifigéndum.")  ; R4
        (:respond "Ténebræ factæ sunt, dum crucifixíssent Jesum Judǽi: et circa horam nonam exclamávit Jesus voce magna: Deus meus, ut quid me dereliquísti? * Et inclináto cápite, emísit spíritum." :verse "Exclámans Jesus voce magna, ait: Pater, in manus tuas comméndo spíritum meum." :repeat "Et inclináto cápite, emísit spíritum.")  ; R5
        (:respond "Animam meam diléctam trádidi in manus iniquórum, et facta est mihi heréditas mea sicut leo in silva: dedit contra me voces adversárius, dicens: Congregámini, et properáte ad devorándum illum: posuérunt me in desérto solitúdinis, et luxit super me omnis terra: * Quia non est invéntus qui me agnósceret, et fáceret bene." :verse "Insurrexérunt in me viri absque misericórdia, et non pepercérunt ánimæ meæ." :repeat "Quia non est invéntus qui me agnósceret, et fáceret bene." :gloria t)  ; R6
        (:respond "Tradidérunt me in manus impiórum, et inter iníquos projecérunt me, et non pepercérunt ánimæ meæ: congregáti sunt advérsum me fortes: * Et sicut gigántes stetérunt contra me." :verse "Aliéni insurrexérunt advérsum me, et fortes quæsiérunt ánimam meam." :repeat "Et sicut gigántes stetérunt contra me.")  ; R7
        (:respond "Jesum trádidit ímpius summis princípibus sacerdótum, et senióribus pópuli: * Petrus autem sequebátur eum a longe, ut vidéret finem." :verse "Adduxérunt autem eum ad Cáipham príncipem sacerdótum, ubi scribæ et pharisǽi convénerant." :repeat "Petrus autem sequebátur eum a longe, ut vidéret finem.")  ; R8
        (:respond "Caligavérunt óculi mei a fletu meo: quia elongátus est a me, qui consolabátur me: Vidéte omnes pópuli, * Si est dolor símilis sicut dolor meus." :verse "O vos omnes, qui transítis per viam, atténdite et vidéte." :repeat "Si est dolor símilis sicut dolor meus." :gloria t)  ; R9
        )

        ;; ── Lauds ────────────────────────────────────────────────────
        :lauds-antiphons (proprio-filio-suo
                          anxiatus-est-super-me
                          ait-latro-ad-latronem
                          cum-conturbata-fuerit
                          memento-mei-domine)
        :lauds-versicle ("Collocávit me in obscúris."
                         . "Sicut mórtuos sǽculi.")
        :lauds-versicle-en ("He hath set me in dark places."
                            . "As they that be dead of old.")
        :benedictus-antiphon posuerunt-super-caput

        ;; ── Vespers (use Thursday's antiphons per rubric) ────────────
        :magnificat-antiphon cum-accepisset-acetum

        ;; ── Concluding prayer (same as Thursday) ─────────────────────
        :oratio "Réspice, quǽsumus, Dómine, super hanc famíliam tuam, pro qua Dóminus noster Jesus Christus non dubitávit mánibus tradi nocéntium, et crucis subíre torméntum:"
        :oratio-en "Look down, we beseech thee, O Lord, on this thy family, for which our Lord Jesus Christ did not hesitate to be delivered up into the hands of wicked men, and to suffer the torment of the Cross."
        :oratio-conclusion "Qui tecum"

        ;; ── Christus factus est (accumulative: + mortem crucis) ──────
        :christus-factus "Christus factus est pro nobis obédiens usque ad mortem, mortem autem crucis."
        :christus-factus-en "Christ became obedient for us unto death, even to the death of the cross."
        ))


    ;; ════════════════════════════════════════════════════════════════════════
    ;; HOLY SATURDAY — Sabbato Sancto
    ;; ════════════════════════════════════════════════════════════════════════

    (sat
     . (:name "Sabbato Sancto"
        :name-en "Holy Saturday"

        ;; ── Matins psalms (9 proper — peaceful psalms) ───────────────
        :psalms ((in-pace-in-idipsum . 4)
                 (habitabit-in-tabernaculo . 14)
                 (caro-mea-requiescet . 15)
                 (elevamini-portae . 23)
                 (credo-videre-bona . 26)
                 (domine-abstraxisti . 29)
                 (deus-adjuvat-me . 53)
                 (in-pace-factus-est . 75)
                 (factus-sum-sicut-homo . 87))

        ;; ── Nocturn versicles ─────────────────────────────────────────
        :versicle-1 ("In pace in idípsum."
                     . "Dórmiam et requiéscam.")
        :versicle-1-en ("I will both lay me down in peace."
                        . "And sleep.")
        :versicle-2 ("Tu autem, Dómine, miserére mei."
                     . "Et resúscita me, et retríbuam eis.")
        :versicle-2-en ("But Thou, O Lord, be merciful unto me."
                        . "And raise me up; and I will requite them.")
        :versicle-3 ("In pace factus est locus ejus."
                     . "Et in Sion habitátio ejus.")
        :versicle-3-en ("His place is in peace."
                        . "And His dwelling-place in Zion.")

        ;; ── Lessons (9) ──────────────────────────────────────────────
        :lessons
        (
        ;; Nocturn I: Lamentations (Lam 3:22-30; 4:1-6; 5:1-11)
        (:ref "Lam 3:22-30" :source "De Lamentatióne Jeremíæ Prophétæ"
         :text "HETH. Misericórdiæ Dómini quia non sumus consúmpti: quia non defecérunt miseratiónes ejus.\nHETH. Novi dilúculo, multa est fides tua.\nHETH. Pars mea Dóminus, dixit ánima mea: proptérea exspectábo eum.\nTETH. Bonus est Dóminus sperántibus in eum, ánimæ quærénti illum.\nTETH. Bonum est præstolári cum siléntio salutáre Dei.\nTETH. Bonum est viro cum portáverit jugum ab adulescéntia sua.\nJOD. Sedébit solitárius, et tacébit: quia levávit super se.\nJOD. Ponet in púlvere os suum, si forte sit spes.\nJOD. Dabit percutiénti se maxíllam, saturábitur oppróbriis.\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L1
        (:ref "Lam 4:1-6"
         :text "ALEPH. Quómodo obscurátum est aurum, mutátus est color óptimus, dispérsi sunt lápides sanctuárii in cápite ómnium plateárum?\nBETH. Fílii Sion íncliti, et amícti auro primo: quómodo reputáti sunt in vasa téstea, opus mánuum fíguli?\nGHIMEL. Sed et lámiæ nudavérunt mammam, lactavérunt cátulos suos: fília pópuli mei crudélis, quasi strúthio in desérto.\nDALETH. Adhǽsit lingua lacténtis ad palátum ejus in siti: párvuli petiérunt panem, et non erat qui frángeret eis.\nHE. Qui vescebántur voluptuóse, interiérunt in viis: qui nutriebántur in cróceis, amplexáti sunt stércora.\nVAU. Et major effécta est iníquitas fíliæ pópuli mei peccáto Sodomórum, quæ subvérsa est in moménto, et non cepérunt in ea manus.\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L2
        (:ref "Lam 5:1-11" :source "Incipit Orátio Jeremíæ Prophétæ"
         :text "Recordáre, Dómine, quid accíderit nobis: intuére, et réspice oppróbrium nostrum. Heréditas nostra versa est ad aliénos: domus nostræ ad extráneos. Pupílli facti sumus absque patre, matres nostræ quasi víduæ. Aquam nostram pecúnia bíbimus: ligna nostra prétio comparávimus. Cervícibus nostris minabámur, lassis non dabátur réquies. Ægýpto dédimus manum, et Assýriis, ut saturarémur pane. Patres nostri peccavérunt, et non sunt: et nos iniquitátes eórum portávimus. Servi domináti sunt nostri: non fuit qui redímeret de manu eórum. In animábus nostris afferebámus panem nobis, a fácie gládii in desérto. Pellis nostra quasi clíbanus exústa est a fácie tempestátum famis. Mulíeres in Sion humiliavérunt, et vírgines in civitátibus Juda.\n\nJerúsalem, Jerúsalem, convértere ad Dóminum Deum tuum.")  ; L3
        ;; Nocturn II: Augustine on Psalm 63 (continued)
        (:source "Ex Tractátu sancti Augustíni Epíscopi super Psalmos"
         :text "Accédet homo ad cor altum, et exaltábitur Deus. Illi dixérunt: Quis nos vidébit? Defecérunt scrutántes scrutatiónes, consília mala. Accéssit homo ad ipsa consília, passus est se tenéri ut homo. Non enim tenerétur nisi homo, aut viderétur nisi homo, aut cæderétur nisi homo, aut crucifigerétur, aut morerétur nisi homo. Accéssit ergo homo ad illas omnes passiónes, quæ in illo nihil valérent, nisi esset homo. Sed si ille non esset homo, non liberarétur homo. Accéssit homo ad cor altum, id est, cor secrétum, obíciens aspéctibus humánis hóminem, servans intus Deum: celans formam Dei, in qua æquális est Patri, et ófferens formam servi, qua minor est Patre.")  ; L4
        (:text "Quo perduxérunt illas scrutatiónes suas, quas perscrutántes defecérunt, ut étiam mórtuo Dómino et sepúlto, custódes pónerent ad sepúlcrum? Dixérunt enim Piláto: Sedúctor ille: hoc appellabátur nómine Dóminus Jesus Christus, ad solátium servórum suórum, quando dicúntur seductóres: ergo illi Piláto: Sedúctor ille, ínquiunt, dixit adhuc vivens: Post tres dies resúrgam. Jube ítaque custodíri sepúlcrum usque in diem tértium, ne forte véniant discípuli ejus, et furéntur eum, et dicant plebi: Surréxit a mórtuis: et erit novíssimus error pejor prióre. Ait illis Pilátus: Habétis custódiam, ite, custodíte sicut scitis. Illi autem abeúntes, muniérunt sepúlcrum, signántes lápidem cum custódibus.")  ; L5
        (:text "Posuérunt custódes mílites ad sepúlcrum. Concússa terra Dóminus resurréxit: mirácula facta sunt tália circa sepúlcrum, ut et ipsi mílites, qui custódes advénerant, testes fíerent, si vellent vera nuntiáre. Sed avarítia illa, quæ captivávit discípulum cómitem Christi, captivávit et mílitem custódem sepúlcri. Damus, ínquiunt, vobis pecúniam: et dícite, quia vobis dormiéntibus venérunt discípuli ejus, et abstulérunt eum. Vere defecérunt scrutántes scrutatiónes. Quid est quod dixísti, o infélix astútia? Tantúmne déseris lucem consílii pietátis, et in profúnda versútiæ demérgeris, ut hoc dicas: Dícite quia vobis dormiéntibus venérunt discípuli ejus, et abstulérunt eum? Dormiéntes testes ádhibes: vere tu ipse obdormísti, qui scrutándo tália defecísti.")  ; L6
        ;; Nocturn III: Hebrews 9
        (:ref "Heb 9:11-14" :source "De Epístola beáti Pauli Apóstoli ad Hebrǽos"
         :text "11 Christus assístens Póntifex futurórum bonórum, per ámplius et perféctius tabernáculum non manufáctum, id est, non hujus creatiónis: 12 neque per sánguinem hircórum, aut vitulórum, sed per próprium sánguinem introívit semel in Sancta, ætérna redemptióne invénta. 13 Si enim sanguis hircórum, et taurórum, et cinis vítulæ aspérsus inquinátos sanctíficat ad emundatiónem carnis: 14 quanto magis sanguis Christi, qui per Spíritum Sanctum semetípsum óbtulit immaculátum Deo, emundábit consciéntiam nostram ab opéribus mórtuis, ad serviéndum Deo vivénti?")  ; L7
        (:ref "Heb 9:15-18"
         :text "15 Et ídeo novi testaménti mediátor est: ut, morte intercedénte, in redemptiónem eárum prævaricatiónum, quæ erant sub prióri testaménto, repromissiónem accípiant, qui vocáti sunt ætérnæ hereditátis. 16 Ubi enim testaméntum est: mors necésse est intercédat testatóris. 17 Testaméntum enim in mórtuis confirmátum est: alióquin nondum valet, dum vivit qui testátus est. 18 Unde nec primum quidem sine sánguine dedicátum est.")  ; L8
        (:ref "Heb 9:19-22"
         :text "19 Lecto enim omni mandáto legis a Móyse univérso pópulo: accípiens sánguinem vitulórum, et hircórum cum aqua et lana coccínea, et hyssópo: ipsum quoque librum, et omnem pópulum aspérsit, 20 dicens: Hic sanguis testaménti, quod mandávit ad vos Deus. 21 Etiam tabernáculum, et ómnia vasa ministérii sánguine simíliter aspérsit: 22 et ómnia pene in sánguine secúndum legem mundántur: et sine sánguinis effusióne non fit remíssio.")  ; L9
        )

        ;; ── Responsories (9) ─────────────────────────────────────────
        :responsories
        (
        (:respond "Sicut ovis ad occisiónem ductus est, et dum male tractarétur, non apéruit os suum: tráditus est ad mortem, * Ut vivificáret pópulum suum." :verse "Trádidit in mortem ánimam suam, et inter scelerátos reputátus est." :repeat "Ut vivificáret pópulum suum.")  ; R1
        (:respond "Jerúsalem, surge, et éxue te véstibus jucunditátis: indúere cínere et cilício, * Quia in te occísus est Salvátor Israël." :verse "Deduc quasi torréntem lácrimas per diem et noctem, et non táceat pupílla óculi tui." :repeat "Quia in te occísus est Salvátor Israël.")  ; R2
        (:respond "Plange quasi virgo, plebs mea: ululáte, pastóres, in cínere et cilício: * Quia venit dies Dómini magna, et amára valde." :verse "Accíngite vos, sacerdótes, et plángite, minístri altáris, aspérgite vos cínere." :repeat "Quia venit dies Dómini magna, et amára valde." :gloria t)  ; R3
        (:respond "Recéssit pastor noster, fons aquæ vivæ, ad cujus tránsitum sol obscurátus est: * Nam et ille captus est, qui captívum tenébat primum hóminem: hódie portas mortis et seras páriter Salvátor noster disrúpit." :verse "Destrúxit quidem claustra inférni, et subvértit poténtias diáboli." :repeat "Nam et ille captus est, qui captívum tenébat primum hóminem: hódie portas mortis et seras páriter Salvátor noster disrúpit.")  ; R4
        (:respond "O vos omnes, qui transítis per viam, atténdite, et vidéte, * Si est dolor símilis sicut dolor meus." :verse "Atténdite, univérsi pópuli, et vidéte dolórem meum." :repeat "Si est dolor símilis sicut dolor meus.")  ; R5
        (:respond "Ecce quómodo móritur justus, et nemo pércipit corde: et viri justi tollúntur, et nemo consíderat: a fácie iniquitátis sublátus est justus: * Et erit in pace memória ejus." :verse "Tamquam agnus coram tondénte se obmútuit, et non apéruit os suum: de angústia et de judício sublátus est." :repeat "Et erit in pace memória ejus." :gloria t)  ; R6
        (:respond "Astitérunt reges terræ, et príncipes convenérunt in unum, * Advérsus Dóminum, et advérsus Christum ejus." :verse "Quare fremuérunt gentes, et pópuli meditáti sunt inánia?" :repeat "Advérsus Dóminum, et advérsus Christum ejus.")  ; R7
        (:respond "Æstimátus sum cum descendéntibus in lacum: * Factus sum sicut homo sine adjutório, inter mórtuos liber." :verse "Posuérunt me in lacu inferióri, in tenebrósis, et in umbra mortis." :repeat "Factus sum sicut homo sine adjutório, inter mórtuos liber.")  ; R8
        (:respond "Sepúlto Dómino, signátum est monuméntum, volvéntes lápidem ad óstium monuménti: * Ponéntes mílites, qui custodírent illum." :verse "Accedéntes príncipes sacerdótum ad Pilátum, petiérunt illum." :repeat "Ponéntes mílites, qui custodírent illum." :gloria t)  ; R9
        )

        ;; ── Lauds ────────────────────────────────────────────────────
        :lauds-antiphons (o-mors-ero-mors-tua
                          plangent-eum-quasi
                          attendite-universi-populi
                          a-porta-inferi
                          o-vos-omnes-qui-transitis)
        :lauds-versicle ("Caro mea requiéscet in spe."
                         . "Et non dabis Sanctum tuum vidére corruptiónem.")
        :lauds-versicle-en ("My flesh shall rest in hope."
                            . "Neither wilt Thou suffer thine Holy One to see corruption.")
        :benedictus-antiphon mulieres-sedentes

        ;; ── Concluding prayer (same as Thursday) ─────────────────────
        :oratio "Réspice, quǽsumus, Dómine, super hanc famíliam tuam, pro qua Dóminus noster Jesus Christus non dubitávit mánibus tradi nocéntium, et crucis subíre torméntum:"
        :oratio-en "Look down, we beseech thee, O Lord, on this thy family, for which our Lord Jesus Christ did not hesitate to be delivered up into the hands of wicked men, and to suffer the torment of the Cross."
        :oratio-conclusion "Qui tecum"

        ;; ── Christus factus est (full accumulation) ──────────────────
        :christus-factus "Christus factus est pro nobis obédiens usque ad mortem, mortem autem crucis: propter quod et Deus exaltávit illum, et dedit illi nomen quod est super omne nomen."
        :christus-factus-en "Christ became obedient for us unto death, even to the death of the cross. For which cause God also hath exalted him, and hath given him a name which is above all names."
        ))

    )
  "Sacred Triduum Tenebrae data.
Each entry: (DAY-KEY . PLIST) where DAY-KEY is thu, fri, or sat.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-season-holyweek-triduum (day-key)
  "Return the Triduum data plist for DAY-KEY (thu, fri, or sat)."
  (cdr (assq day-key bcp-roman-season-holyweek--triduum)))

(defun bcp-roman-season-holyweek-weekday (day-key)
  "Return the weekday propers plist for DAY-KEY (mon, tue, or wed)."
  (cdr (assq day-key bcp-roman-season-holyweek--weekday-propers)))

(defun bcp-roman-season-holyweek-collect (date)
  "Return the collect incipit symbol for Holy Week DATE.
Dispatches to the weekday or Triduum collect as appropriate."
  (let* ((year (caddr date))
         (feasts (bcp-moveable-feasts year))
         (easter (cdr (assq 'easter feasts)))
         (easter-abs (calendar-absolute-from-gregorian easter))
         (date-abs (calendar-absolute-from-gregorian date))
         (diff (- date-abs easter-abs)))
    (pcase diff
      (-6 (plist-get (bcp-roman-season-holyweek-weekday 'mon) :collect))
      (-5 (plist-get (bcp-roman-season-holyweek-weekday 'tue) :collect))
      (-4 (plist-get (bcp-roman-season-holyweek-weekday 'wed) :collect))
      ((or -3 -2 -1) 'respice-quaesumus-domine-super-hanc)
      (_ nil))))

(defun bcp-roman-season-holyweek-hours (date)
  "Return non-Matins hour data for Holy Week DATE, or nil.
For Triduum days, returns the Triduum plist; for Mon–Wed,
returns the weekday propers plist."
  (let* ((year (caddr date))
         (feasts (bcp-moveable-feasts year))
         (easter (cdr (assq 'easter feasts)))
         (easter-abs (calendar-absolute-from-gregorian easter))
         (date-abs (calendar-absolute-from-gregorian date))
         (diff (- date-abs easter-abs)))
    (pcase diff
      (-6 (bcp-roman-season-holyweek-weekday 'mon))
      (-5 (bcp-roman-season-holyweek-weekday 'tue))
      (-4 (bcp-roman-season-holyweek-weekday 'wed))
      (-3 (bcp-roman-season-holyweek-triduum 'thu))
      (-2 (bcp-roman-season-holyweek-triduum 'fri))
      (-1 (bcp-roman-season-holyweek-triduum 'sat))
      (_ nil))))

(provide 'bcp-roman-season-holyweek)

;;; bcp-roman-season-holyweek.el ends here
