;;; bcp-roman-antiphonary.el --- Antiphon registry for the Roman Office -*- lexical-binding: t -*-

;;; Commentary:

;; Registry of Roman Office antiphons, keyed by Latin incipit.
;; Each entry stores the Latin text and one or more English translations
;; under named translator keys (same shape as `bcp-roman-hymnal.el').
;;
;; Architecture:
;;   Each antiphon is an alist entry: (INCIPIT . PLIST)
;;   PLIST has:
;;     :latin        STRING — the Latin text (pointed, with accents)
;;     :translations ALIST of (TRANSLATOR-KEY . STRING)
;;
;; Public API:
;;   `bcp-roman-antiphonary-get'     — return text for a given language
;;   `bcp-roman-antiphonary-latin'   — return Latin text
;;   `bcp-roman-antiphonary-english' — return English text (fallback chain)

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Shared registry resolver (used by antiphonary, collectarium, responsory)

(defun bcp-roman-registry--resolve-translation (translations chain)
  "Walk CHAIN, return first hit from TRANSLATIONS alist.
TRANSLATIONS is an alist of (TRANSLATOR . TEXT).
CHAIN is a list of translator symbols to try in order."
  (cl-loop for translator in chain
           thereis (alist-get translator translations)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-roman-antiphonary nil
  "Antiphon translations for the Roman Office."
  :prefix "bcp-roman-antiphonary-"
  :group 'bcp-liturgy)

(defcustom bcp-roman-antiphonary-translators '(bute do)
  "Translator fallback chain for antiphons.
Tried in sequence until a translation is found."
  :type  '(repeat symbol)
  :group 'bcp-roman-antiphonary)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Registry

(defvar bcp-roman-antiphonary--entries nil
  "Alist of (INCIPIT . PLIST) for registered antiphons.
Each PLIST has :latin STRING and :translations ALIST.")

(defun bcp-roman-antiphonary-register (incipit plist)
  "Register PLIST as antiphon INCIPIT.
INCIPIT is a symbol (the Latin first line, kebab-cased).
PLIST has :latin and :translations."
  (setf (alist-get incipit bcp-roman-antiphonary--entries) plist))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-antiphonary-latin (incipit)
  "Return the Latin text for antiphon INCIPIT, or nil."
  (plist-get (alist-get incipit bcp-roman-antiphonary--entries) :latin))

(defun bcp-roman-antiphonary-english (incipit)
  "Return the English text for antiphon INCIPIT.
Walks `bcp-roman-antiphonary-translators' fallback chain."
  (let* ((entry (alist-get incipit bcp-roman-antiphonary--entries))
         (translations (plist-get entry :translations)))
    (bcp-roman-registry--resolve-translation
     translations bcp-roman-antiphonary-translators)))

(defun bcp-roman-antiphonary-get (incipit language)
  "Return antiphon INCIPIT text for LANGUAGE.
LANGUAGE is \\='latin or \\='english."
  (pcase language
    ('latin   (bcp-roman-antiphonary-latin incipit))
    ('english (or (bcp-roman-antiphonary-english incipit)
                  (bcp-roman-antiphonary-latin incipit)))
    (_        (bcp-roman-antiphonary-latin incipit))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Vespers antiphons

(bcp-roman-antiphonary-register
 'dum-esset-rex
 '(:latin "Dum esset Rex in accúbitu suo, nardus mea dedit odórem suavitátis."
   :translations
   ((bute . "While the King sitteth at his table, my spikenard sendeth forth the smell thereof."))))

(bcp-roman-antiphonary-register
 'laeva-ejus
 '(:latin "Læva ejus sub cápite meo, et déxtera illíus amplexábitur me."
   :translations
   ((bute . "His left hand is under my head, and his right hand doth embrace me."))))

(bcp-roman-antiphonary-register
 'nigra-sum
 '(:latin "Nigra sum, sed formósa, fíliæ Jerúsalem; ídeo diléxit me Rex, et introdúxit me in cubículum suum."
   :translations
   ((bute . "I am black but comely, O ye daughters of Jerusalem; therefore hath the King loved me, and brought me into his chamber."))))

(bcp-roman-antiphonary-register
 'jam-hiems-transiit
 '(:latin "Jam hiems tránsiit, imber ábiit et recéssit: surge, amíca mea, et veni."
   :translations
   ((bute . "Lo the winter is past, the rain is over and gone. Rise up, my love, and come away."))))

(bcp-roman-antiphonary-register
 'speciosa-facta-es
 '(:latin "Speciósa facta es et suávis in delíciis tuis, sancta Dei Génetrix."
   :translations
   ((bute . "O Holy Mother of God, thou art become beautiful and gentle in thy gladness."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Vespers canticle antiphons

(bcp-roman-antiphonary-register
 'beata-mater-et-intacta
 '(:latin "Beáta Mater et intácta Virgo, gloriósa Regína mundi, intercéde pro nobis ad Dóminum."
   :translations
   ((bute . "Blessed Mother and inviolate Maiden! Glorious Queen of the world! Plead for us with the Lord!"))))

(bcp-roman-antiphonary-register
 'regina-caeli
 '(:latin "Regína cæli, lætáre, allelúja; quia quem meruísti portáre, allelúja; \
resurréxit, sicut dixit, allelúja: ora pro nobis Deum, allelúja."
   :translations
   ((bute . "O Queen of heaven, rejoice! alleluia: For He whom thou didst merit to bear, alleluia, Hath arisen as he said, alleluia. Pray for us to God, alleluia."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Lauds antiphons

(bcp-roman-antiphonary-register
 'assumpta-est-maria
 '(:latin "Assúmpta est María in cælum: gaudent Angeli, laudántes benedícunt Dóminum."
   :translations
   ((bute . "Mary hath been taken to heaven; the Angels rejoice; they praise and bless the Lord."))))

(bcp-roman-antiphonary-register
 'maria-virgo-assumpta
 '(:latin "María Virgo assúmpta est ad æthéreum thálamum, in quo Rex regum stelláto sedet sólio."
   :translations
   ((bute . "The Virgin Mary hath been taken into the chamber on high, where the King of kings sitteth on a throne amid the stars."))))

(bcp-roman-antiphonary-register
 'in-odorem-unguentorum
 '(:latin "In odórem unguentórum tuórum cúrrimus: adolescéntulæ dilexérunt te nimis."
   :translations
   ((bute . "We run after thee, on the scent of thy perfumes; the virgins love thee heartily."))))

(bcp-roman-antiphonary-register
 'benedicta-filia
 '(:latin "Benedícta fília tu a Dómino: quia per te fructum vitæ communicávimus."
   :translations
   ((bute . "Blessed of the Lord art thou, O daughter, for by thee we have been given to eat of the fruit of the tree of Life."))))

(bcp-roman-antiphonary-register
 'pulchra-es-et-decora
 '(:latin "Pulchra es, et decóra, fília Jerúsalem: terríbilis ut castrórum ácies ordináta."
   :translations
   ((bute . "Fair and comely art thou, O daughter of Jerusalem, terrible as a fenced camp set in battle array."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Lauds canticle antiphons

(bcp-roman-antiphonary-register
 'beata-dei-genetrix
 '(:latin "Beáta Dei Génetrix, María, Virgo perpétua, templum Dómini, \
sacrárium Spíritus Sancti, sola sine exémplo placuísti Dómino nostro \
Jesu Christo: ora pro pópulo, intérveni pro clero, intercéde pro devóto femíneo sexu."
   :translations
   ((bute . "O Blessed Mary, Mother of God, Virgin for ever, temple of the Lord, \
sanctuary of the Holy Ghost, thou, without any example before thee, didst \
make thyself well-pleasing in the sight of our Lord Jesus Christ; pray for \
the people, plead for the clergy, make intercession for all women vowed to God."))))

;; Lauds Eastertide canticle antiphon is the same text as regina-caeli (already registered)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Matins antiphons

(bcp-roman-antiphonary-register
 'ave-maria-invitatory
 '(:latin "Ave María, grátia plena, * Dóminus tecum."
   :translations
   ((bute . "Hail Mary, full of grace, * The Lord is with thee."))))

(bcp-roman-antiphonary-register
 'benedicta-tu-in-mulieribus
 '(:latin "Benedícta tu in muliéribus, et benedíctus fructus ventris tui."
   :translations
   ((bute . "Blessed art thou among women, and blessed is the fruit of thy womb."))))

(bcp-roman-antiphonary-register
 'sicut-myrrha-electa
 '(:latin "Sicut myrrha elécta, odórem dedísti suavitátis, sancta Dei Génetrix."
   :translations
   ((bute . "O Holy Mother of God, thou hast yielded a pleasant odor like the best myrrh."))))

(bcp-roman-antiphonary-register
 'ante-torum
 '(:latin "Ante torum hujus Vírginis frequentáte nobis dúlcia cántica drámatis."
   :translations
   ((bute . "Sing for us again and again before this maiden's bed the tender idylls of the play."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Compline antiphons

(bcp-roman-antiphonary-register
 'sub-tuum-praesidium
 '(:latin "Sub tuum præsídium confúgimus, sancta Dei Génetrix: \
nostras deprecatiónes ne despícias in necessitátibus, \
sed a perículis cunctis líbera nos semper, Virgo gloriósa et benedícta."
   :translations
   ((bute . "We take refuge under thy protection, O holy Mother of God! Despise not \
our supplications in our need, but deliver us always from all dangers, O \
Virgin, glorious and blessed!"))))

;; Compline Eastertide antiphon is the same text as regina-caeli (already registered)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Commemoratio antiphon

(bcp-roman-antiphonary-register
 'sancti-dei-omnes
 '(:latin "Sancti Dei omnes, intercédere dignémini pro nostra omniúmque salúte."
   :translations
   ((bute . "All ye saints of God, vouchsafe to plead for our salvation and for that of all mankind."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Sunday Vespers antiphons

(bcp-roman-antiphonary-register
 'dixit-dominus
 '(:latin "Dixit Dóminus * Dómino meo: Sede a dextris meis."
   :translations
   ((do . "The Lord said to my Lord: * Sit thou at my right hand."))))

(bcp-roman-antiphonary-register
 'magna-opera-domini
 '(:latin "Magna ópera Dómini: * exquisíta in omnes voluntátes ejus."
   :translations
   ((do . "Great are the works of the Lord, * sought out according to all his wills."))))

(bcp-roman-antiphonary-register
 'qui-timet-dominum
 '(:latin "Qui timet Dóminum, * in mandátis ejus cupit nimis."
   :translations
   ((do . "Blessed is the man that feareth the Lord; * he shall delight exceedingly in his commandments."))))

(bcp-roman-antiphonary-register
 'sit-nomen-domini
 '(:latin "Sit nomen Dómini * benedíctum in sǽcula."
   :translations
   ((do . "Blessed be the name of the Lord * from henceforth now and for ever."))))

(bcp-roman-antiphonary-register
 'deus-autem-noster
 '(:latin "Deus autem noster * in cælo: ómnia quæcúmque vóluit, fecit."
   :translations
   ((do . "But our God is in heaven, * he hath done all things whatsoever he would."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Monday Vespers antiphons

(bcp-roman-antiphonary-register
 'inclinavit-dominus
 '(:latin "Inclinávit Dóminus * aurem suam mihi."
   :translations
   ((do . "The Lord hath inclined * his ear unto me."))))

(bcp-roman-antiphonary-register
 'vota-mea
 '(:latin "Vota mea * Dómino reddam coram omni pópulo ejus."
   :translations
   ((do . "I will pay my vows * in the sight of all his people."))))

(bcp-roman-antiphonary-register
 'clamavi-et-dominus
 '(:latin "Clamávi * et Dóminus exaudívit me."
   :translations
   ((do . "I have cried to the Lord, * and he hath heard me."))))

(bcp-roman-antiphonary-register
 'auxilium-meum
 '(:latin "Auxílium meum * a Dómino, qui fecit cælum et terram."
   :translations
   ((do . "My help is from the Lord, * who made heaven and earth."))))

(bcp-roman-antiphonary-register
 'laetatus-sum
 '(:latin "Lætátus sum * in his, quæ dicta sunt mihi."
   :translations
   ((do . "I rejoiced * at the things that were said to me."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Tuesday Vespers antiphons

(bcp-roman-antiphonary-register
 'qui-habitas-in-caelis
 '(:latin "Qui hábitas in cælis, * miserére nobis."
   :translations
   ((do . "Thou who dwellest in heaven, * have mercy on us."))))

(bcp-roman-antiphonary-register
 'adjutorium-nostrum
 '(:latin "Adjutórium nostrum * in nómine Dómini."
   :translations
   ((do . "Our help is * in the name of the Lord."))))

(bcp-roman-antiphonary-register
 'in-circuitu-populi
 '(:latin "In circúitu pópuli sui * Dóminus, ex hoc nunc et usque in sǽculum."
   :translations
   ((do . "The Lord standeth round his people * from this time forth and for evermore."))))

(bcp-roman-antiphonary-register
 'magnificavit-dominus
 '(:latin "Magnificávit Dóminus * fácere nobíscum: facti sumus lætántes."
   :translations
   ((do . "The Lord hath * done great things for us, whereof we rejoice."))))

(bcp-roman-antiphonary-register
 'dominus-aedificet
 '(:latin "Dóminus ædíficet * nobis domum, et custódiat civitátem."
   :translations
   ((do . "The Lord builds * the house and keeps the city."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Wednesday Vespers antiphons

(bcp-roman-antiphonary-register
 'beati-omnes
 '(:latin "Beáti omnes * qui timent Dóminum."
   :translations
   ((do . "Blessed are all * they that fear the Lord."))))

(bcp-roman-antiphonary-register
 'confundantur-omnes
 '(:latin "Confundántur omnes * qui odérunt Sion."
   :translations
   ((do . "Let them all be confounded * who hate Sion."))))

(bcp-roman-antiphonary-register
 'de-profundis
 '(:latin "De profúndis * clamávi ad te, Dómine."
   :translations
   ((do . "Out of the depths * I have cried to thee, O Lord."))))

(bcp-roman-antiphonary-register
 'domine-non-est-exaltatum
 '(:latin "Dómine, * non est exaltátum cor meum."
   :translations
   ((do . "O Lord * my heart is not exalted."))))

(bcp-roman-antiphonary-register
 'elegit-dominus
 '(:latin "Elégit Dóminus * Sion in habitatiónem sibi."
   :translations
   ((do . "The Lord hath chosen * Sion for his dwelling."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Thursday Vespers antiphons

(bcp-roman-antiphonary-register
 'ecce-quam-bonum
 '(:latin "Ecce quam bonum * et quam jucúndum habitáre fratres in unum."
   :translations
   ((do . "Behold how good * and how pleasant it is for brethren to dwell together in unity."))))

(bcp-roman-antiphonary-register
 'confitemini-domino-quoniam
 '(:latin "Confitémini Dómino * quóniam in ætérnum misericórdia ejus."
   :translations
   ((do . "Give ye glory to the Lord * for his mercy endureth for ever."))))

(bcp-roman-antiphonary-register
 'confitemini-domino-quia
 '(:latin "Confitémini Dómino * quia in humilitáte nostra memor fuit nostri."
   :translations
   ((do . "Give ye glory to the Lord * for he was mindful of us in our affliction."))))

(bcp-roman-antiphonary-register
 'adhaereat-lingua-mea
 '(:latin "Adhǽreat lingua mea * fáucibus meis, si non memínero tui Jerúsalem."
   :translations
   ((do . "Let my tongue cleave to my jaws * if I do not remember thee, Jerusalem."))))

(bcp-roman-antiphonary-register
 'confitebor-nomini-tuo
 '(:latin "Confitébor * nómini tuo, Dómine, super misericórdia et veritáte tua."
   :translations
   ((do . "I will give glory * to thy name, for thy mercy, and for thy truth."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Friday Vespers antiphons

(bcp-roman-antiphonary-register
 'domine-probasti-me
 '(:latin "Dómine, * probásti me et cognovísti me."
   :translations
   ((do . "Lord, * thou hast proved me, and known me."))))

(bcp-roman-antiphonary-register
 'mirabilia-opera-tua
 '(:latin "Mirabília ópera tua, * Dómine, et ánima mea cognóscit nimis."
   :translations
   ((do . "Wonderful are thy works * and my soul knoweth right well."))))

(bcp-roman-antiphonary-register
 'ne-derelinquas-me
 '(:latin "Ne derelínquas me, * Dómine, virtus salútis meæ."
   :translations
   ((do . "Do not thou forsake me, * O Lord, the strength of my salvation."))))

(bcp-roman-antiphonary-register
 'domine-clamavi-ad-te
 '(:latin "Dómine, * clamávi ad te, exáudi me."
   :translations
   ((do . "I have cried to thee, * O Lord, hear me."))))

(bcp-roman-antiphonary-register
 'educ-de-custodia
 '(:latin "Educ de custódia * ánimam meam, Dómine, ad confiténdum nómini tuo."
   :translations
   ((do . "Bring my soul * out of prison, O Lord, that I may praise thy name."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Saturday Vespers antiphons

(bcp-roman-antiphonary-register
 'benedictus-dominus-susceptor
 '(:latin "Benedíctus Dóminus * suscéptor meus et liberátor meus."
   :translations
   ((do . "Blessed be the Lord * my support, and my deliverer."))))

(bcp-roman-antiphonary-register
 'beatus-populus
 '(:latin "Beátus pópulus * cujus Dóminus Deus ejus."
   :translations
   ((do . "Happy is that people * whose God is the Lord."))))

(bcp-roman-antiphonary-register
 'magnus-dominus-et-laudabilis
 '(:latin "Magnus Dóminus * et laudábilis nimis: et magnitúdinis ejus non est finis."
   :translations
   ((do . "For the Lord is great * and exceedingly to be praised: His greatness has no end."))))

(bcp-roman-antiphonary-register
 'suavis-dominus
 '(:latin "Suávis Dóminus * univérsis: et miseratiónes ejus super ómnia ópera ejus."
   :translations
   ((do . "The Lord is sweet * to all: and his tender mercies are over all his works."))))

(bcp-roman-antiphonary-register
 'fidelis-dominus
 '(:latin "Fidélis Dóminus * in ómnibus verbis suis: et sanctus in ómnibus opéribus suis."
   :translations
   ((do . "The Lord is faithful * in all his words: and holy in all his works."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Compline antiphons (one per day, covering 3 psalms)

(bcp-roman-antiphonary-register
 'miserere-mihi-domine
 '(:latin "Miserére * mihi, Dómine, et exáudi oratiónem meam."
   :translations
   ((do . "Have mercy * on me, O Lord, and hear my prayer."))))

(bcp-roman-antiphonary-register
 'salvum-me-fac-domine
 '(:latin "Salvum me fac, * Dómine, propter misericórdiam tuam."
   :translations
   ((do . "Deliver my soul, * O Lord, save me for thy mercy's sake."))))

(bcp-roman-antiphonary-register
 'tu-domine-servabis
 '(:latin "Tu, Dómine, * servábis nos: et custódies nos in ætérnum."
   :translations
   ((do . "Thou, O Lord, * wilt preserve us: and keep us for ever."))))

(bcp-roman-antiphonary-register
 'immittet-angelus
 '(:latin "Immíttet Ángelus Dómini * in circúitu timéntium eum: et erípiet eos."
   :translations
   ((do . "The angel of the Lord * shall encamp round about them that fear him: and shall deliver them."))))

(bcp-roman-antiphonary-register
 'adjutor-meus
 '(:latin "Adjútor meus * et liberátor meus esto, Dómine."
   :translations
   ((do . "Thou art my helper * and my deliverer, O Lord."))))

(bcp-roman-antiphonary-register
 'voce-mea-ad-dominum
 '(:latin "Voce mea * ad Dóminum clamávi: neque obliviscétur miseréri Deus."
   :translations
   ((do . "I have cried * to the Lord with my voice, do not forget to show mercy, O God."))))

(bcp-roman-antiphonary-register
 'intret-oratio-mea
 '(:latin "Intret orátio mea * in conspéctu tuo, Dómine."
   :translations
   ((do . "May my request * come before thee, O Lord."))))

;;; ─── Compline Nunc dimittis antiphon (invariant) ──────────────────────────

(bcp-roman-antiphonary-register
 'salva-nos-domine
 '(:latin "Salva nos, * Dómine, vigilántes, custódi nos dormiéntes; ut vigilémus cum Christo, et requiescámus in pace."
   :translations
   ((do . "Protect us, * Lord, while we are awake and safeguard us while we sleep; that we may keep watch with Christ, and rest in peace."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: ferial Magnificat antiphons (Vespers, per-annum)

(bcp-roman-antiphonary-register
 'magnificat-anima-mea-quia
 '(:latin "Magníficat * ánima mea Dóminum, quia respéxit Deus humilitátem meam."
   :translations
   ((do . "My soul * magnifies the Lord, because God has regarded my lowliness."))))

(bcp-roman-antiphonary-register
 'exsultavit-spiritus
 '(:latin "Exsultávit * spíritus meus in Deo salutári meo."
   :translations
   ((do . "My spirit rejoices * in God, in my Saviour."))))

(bcp-roman-antiphonary-register
 'respexit-dominus-humilitatem
 '(:latin "Respéxit Dóminus * humilitátem meam, et fecit in me magna, qui potens est."
   :translations
   ((do . "The Lord has regarded * my lowliness, and he who is mighty has done great things through me."))))

(bcp-roman-antiphonary-register
 'fecit-deus-potentiam
 '(:latin "Fecit Deus * poténtiam in brácchio suo: dispérsit supérbos mente cordis sui."
   :translations
   ((do . "God has shown * the power of his arm: he has scattered the proud in the imagination of their hearts."))))

(bcp-roman-antiphonary-register
 'deposuit-dominus
 '(:latin "Depósuit Dóminus * poténtes de sede, et exaltávit húmiles."
   :translations
   ((do . "The Lord has put down * the mighty from their seat, and exalted the humble and meek."))))

(bcp-roman-antiphonary-register
 'suscepit-deus-israel
 '(:latin "Suscépit Deus * Israël, púerum suum: sicut locútus est ad Ábraham, et semen ejus usque in sǽculum."
   :translations
   ((do . "God hath received * Israel his servant: as he spoke to our fathers, to Abraham and to his seed for ever."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Lauds antiphons (Laudes1, per-annum)

;;; ─── Sunday Lauds ────────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'alleluia-dominus-regnavit
 '(:latin "Allelúja, * Dóminus regnávit, decórem índuit, allelúja, allelúja."
   :translations
   ((do . "Alleluia, * The Lord hath reigned, he is clothed with beauty, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'jubilate-deo-omnis-terra
 '(:latin "Jubiláte * Deo omnis terra, allelúja."
   :translations
   ((do . "Shout with joy to God * all the earth, alleluia."))))

(bcp-roman-antiphonary-register
 'benedicam-te-in-vita
 '(:latin "Benedícam te * in vita mea, Dómine: et in nómine tuo levábo manus meas, allelúja."
   :translations
   ((do . "I will bless thee all my life long * and in thy name I will lift up my hands, alleluia."))))

(bcp-roman-antiphonary-register
 'tres-pueri
 '(:latin "Tres púeri * jussu regis in fornácem missi sunt, non timéntes flammam ignis, dicéntes: Benedíctus Deus, allelúja."
   :translations
   ((do . "The three young boys * cast into the furnace by the king, fearing not the flames of fire, said: Blessed be God, alleluia."))))

(bcp-roman-antiphonary-register
 'alleluia-laudate-dominum-de-caelis
 '(:latin "Allelúja, * laudáte Dóminum de cælis, allelúja, allelúja."
   :translations
   ((do . "Alleluia, * praise ye the Lord from the heavens, alleluia, alleluia."))))

;;; ─── Monday Lauds ────────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'jubilate-deo-in-voce
 '(:latin "Jubiláte * Deo in voce exsultatiónis."
   :translations
   ((do . "All ye nations * shout unto God with the voice of joy."))))

(bcp-roman-antiphonary-register
 'intende-voci
 '(:latin "Inténde * voci oratiónis meæ, Rex meus et Deus meus."
   :translations
   ((do . "Hearken to the voice * of my prayer, O my King and my God."))))

(bcp-roman-antiphonary-register
 'deus-majestatis
 '(:latin "Deus majestátis * intónuit: afférte glóriam nómini ejus."
   :translations
   ((do . "The God of majesty * hath thundered, ascribe to the Lord glory to his name."))))

(bcp-roman-antiphonary-register
 'laudamus-nomen-tuum
 '(:latin "Laudámus nomen tuum * ínclitum, Deus noster."
   :translations
   ((do . "O God of majesty, * we praise thy glorious name."))))

(bcp-roman-antiphonary-register
 'laudate-dominum-omnes-gentes
 '(:latin "Laudáte * Dóminum omnes gentes."
   :translations
   ((do . "O praise the Lord, * all ye nations."))))

;;; ─── Tuesday Lauds ───────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'cantate-domino-et-benedicite
 '(:latin "Cantáte * Dómino et benedícite nómini ejus."
   :translations
   ((do . "Sing ye * to the Lord and bless his name."))))

(bcp-roman-antiphonary-register
 'salutare-vultus-mei
 '(:latin "Salutáre vultus mei, * Deus meus."
   :translations
   ((do . "The salvation of my countenance * and my God."))))

(bcp-roman-antiphonary-register
 'illumina-domine-vultum
 '(:latin "Illúmina, Dómine, * vultum tuum super nos."
   :translations
   ((do . "May the Lord shine the light * of his countenance upon us."))))

(bcp-roman-antiphonary-register
 'exaltate-regem
 '(:latin "Exaltáte * Regem sæculórum in opéribus vestris."
   :translations
   ((do . "Give ye glory to him * in your works."))))

(bcp-roman-antiphonary-register
 'laudate-nomen-domini
 '(:latin "Laudáte * nomen Dómini, qui statis in domo Dómini."
   :translations
   ((do . "Praise * the name of the Lord, ye who stand in the house of the Lord."))))

;;; ─── Wednesday Lauds ─────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'dominus-regnavit-exsultet
 '(:latin "Dóminus regnávit, * exsúltet terra."
   :translations
   ((do . "The Lord hath reigned * let the earth rejoice."))))

(bcp-roman-antiphonary-register
 'te-decet-hymnus
 '(:latin "Te decet hymnus, * Deus, in Sion."
   :translations
   ((do . "A hymn, O God, * becometh thee in Sion."))))

(bcp-roman-antiphonary-register
 'tibi-domine-psallam
 '(:latin "Tibi, Dómine, psallam, * et intéllegam in via immaculáta."
   :translations
   ((do . "I shall sing to thee, O Lord * and I shall understand with a perfect heart."))))

(bcp-roman-antiphonary-register
 'domine-magnus-es-tu
 '(:latin "Dómine, magnus es tu, * et præclárus in virtúte tua."
   :translations
   ((do . "O Lord, great art thou * and glorious in thy power."))))

(bcp-roman-antiphonary-register
 'laudabo-deum-meum
 '(:latin "Laudábo Deum meum * in vita mea."
   :translations
   ((do . "I shall praise the Lord * in my life."))))

;;; ─── Thursday Lauds ──────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'jubilate-in-conspectu
 '(:latin "Jubiláte * in conspéctu regis Dómini."
   :translations
   ((do . "Make a joyful noise * before the Lord our King."))))

(bcp-roman-antiphonary-register
 'domine-refugium
 '(:latin "Dómine, * refúgium factus es nobis."
   :translations
   ((do . "Lord, * thou hast been our refuge."))))

(bcp-roman-antiphonary-register
 'domine-in-caelo-misericordia
 '(:latin "Dómine, * in cælo misericórdia tua."
   :translations
   ((do . "O Lord, * thy mercy is in heaven."))))

(bcp-roman-antiphonary-register
 'populus-meus-bonis
 '(:latin "Pópulus meus, * ait Dóminus, bonis meis adimplébitur."
   :translations
   ((do . "My people, * said the Lord, shall be filled with good things."))))

(bcp-roman-antiphonary-register
 'deo-nostro-jucunda
 '(:latin "Deo nostro * jucúnda sit laudátio."
   :translations
   ((do . "To our God * be joyful and fitting praise."))))

;;; ─── Friday Lauds ────────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'exaltate-dominum-deum
 '(:latin "Exaltáte * Dóminum Deum nostrum, et adoráte in monte sancto ejus."
   :translations
   ((do . "Exalt ye the Lord * our God, and worship him upon his holy mountain."))))

(bcp-roman-antiphonary-register
 'eripe-me-de-inimicis
 '(:latin "Éripe me * de inimícis meis, Dómine, ad te confúgi."
   :translations
   ((do . "Deliver me from my enemies, * O Lord, to thee have I fled."))))

(bcp-roman-antiphonary-register
 'benedixisti-domine
 '(:latin "Benedixísti, * Dómine, terram tuam: remisísti iniquitátem plebis tuæ."
   :translations
   ((do . "Lord, thou hast blessed thy land; * Thou hast forgiven the iniquity of thy people."))))

(bcp-roman-antiphonary-register
 'in-domino-justificabitur
 '(:latin "In Dómino justificábitur * et laudábitur omne semen Israël."
   :translations
   ((do . "In the Lord * shall all the seed of Israel be justified and praised."))))

(bcp-roman-antiphonary-register
 'lauda-jerusalem
 '(:latin "Lauda, * Jerúsalem, Dóminum."
   :translations
   ((do . "Praise the Lord, * O Jerusalem."))))

;;; ─── Saturday Lauds ──────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'filii-sion-exsultent
 '(:latin "Fílii Sion * exsúltent in Rege suo."
   :translations
   ((do . "Let the children of Sion * be joyful in their king."))))

(bcp-roman-antiphonary-register
 'quam-magnificata
 '(:latin "Quam magnificáta * sunt ópera tua, Dómine."
   :translations
   ((do . "O Lord, * how great are thy works!"))))

(bcp-roman-antiphonary-register
 'laetabitur-justus
 '(:latin "Lætábitur justus * in Dómino et sperábit in eo."
   :translations
   ((do . "The just shall rejoice * in the Lord, and shall hope in him."))))

(bcp-roman-antiphonary-register
 'ostende-nobis-domine
 '(:latin "Osténde nobis, Dómine, * lucem miseratiónum tuárum."
   :translations
   ((do . "Show us, O Lord, * the light of thy mercies."))))

(bcp-roman-antiphonary-register
 'omnis-spiritus-laudet
 '(:latin "Omnis spíritus * laudet Dóminum."
   :translations
   ((do . "Let every thing that hath breath * praise the Lord."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: ferial Benedictus antiphons (Lauds, per-annum)

(bcp-roman-antiphonary-register
 'benedictus-dominus-deus-israel
 '(:latin "Benedíctus * Dóminus Deus Israël, quia visitávit et liberávit nos."
   :translations
   ((do . "Blessed be the Lord * the God of Israel, because he has visited and redeemed his people."))))

(bcp-roman-antiphonary-register
 'erexit-nobis
 '(:latin "Eréxit nobis * Dóminus cornu salútis in domo David púeri sui."
   :translations
   ((do . "The Lord has raised up * a horn of salvation for us in the house of David his servant."))))

(bcp-roman-antiphonary-register
 'de-manu-omnium
 '(:latin "De manu ómnium * qui odérunt nos, liberávit nos Dóminus."
   :translations
   ((do . "From the hand of all * who hate us, the Lord has delivered us."))))

(bcp-roman-antiphonary-register
 'in-sanctitate-serviamus
 '(:latin "In sanctitáte * serviámus Dómino, et liberábit nos ab inimícis nostris."
   :translations
   ((do . "In holiness * let us serve the Lord, and he will deliver us from our enemies."))))

(bcp-roman-antiphonary-register
 'per-viscera-misericordiae
 '(:latin "Per víscera misericórdiæ * Dei nostri visitávit nos Óriens ex alto."
   :translations
   ((do . "Through the tender mercy * of our God, the dayspring from on high has visited us."))))

(bcp-roman-antiphonary-register
 'illumina-domine-sedentes
 '(:latin "Illúmina, Dómine, * sedéntes in ténebris et umbra mortis, et dírige pedes nostros in viam pacis."
   :translations
   ((do . "O Lord, give light * to those who sit in darkness and in the shadow of death, and guide our feet into the way of peace."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Prime antiphons (one per day, per-annum)

(bcp-roman-antiphonary-register
 'alleluia-confitemini-domino
 '(:latin "Allelúja, * confitémini Dómino, quóniam in sǽculum misericórdia ejus, allelúja, allelúja."
   :translations
   ((do . "Alleluia, * Give glory to the Lord, for his mercy endureth for ever, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'innocens-manibus
 '(:latin "Ínnocens mánibus * et mundo corde ascéndet in montem Dómini."
   :translations
   ((do . "The innocent in hands * and clean of heart shall ascend the mountain of the Lord."))))

(bcp-roman-antiphonary-register
 'deus-meus-in-te-confido
 '(:latin "Deus meus * in te confído non erubéscam."
   :translations
   ((do . "In thee, O my God, * I put my trust; let me not be ashamed."))))

(bcp-roman-antiphonary-register
 'misericordia-tua-domine
 '(:latin "Misericórdia tua, * Dómine, ante óculos meos: et complácui in veritáte tua."
   :translations
   ((do . "For thy mercy, * O Lord, is before my eyes; and I am well pleased with thy truth."))))

(bcp-roman-antiphonary-register
 'in-loco-pascuae
 '(:latin "In loco páscuæ * ibi Dóminus me collocávit."
   :translations
   ((do . "The Lord hath set me * in a place of pasture."))))

(bcp-roman-antiphonary-register
 'ne-discedas-a-me
 '(:latin "Ne discédas a me, * Dómine: quóniam tribulátio próxima est: quóniam non est qui ádjuvet."
   :translations
   ((do . "Depart not from me, * O Lord, for tribulation is very near; for there is none to help me."))))

(bcp-roman-antiphonary-register
 'exaltare-domine-qui-judicas
 '(:latin "Exaltáre, Dómine, * qui júdicas terram: redde retributiónem supérbis."
   :translations
   ((do . "Lift up thyself, O Lord, * thou that judgest the earth: render retribution to the proud."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Terce antiphons (one per day, per-annum)

(bcp-roman-antiphonary-register
 'alleluia-deduc-me
 '(:latin "Allelúja, * deduc me, Dómine, in sémitam mandatórum tuórum, allelúja, allelúja."
   :translations
   ((do . "Alleluia, * Lead me into the path of thy commandments, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'illuminatio-mea
 '(:latin "Illuminátio mea * et salus mea Dóminus."
   :translations
   ((do . "My light * and my salvation is the Lord."))))

(bcp-roman-antiphonary-register
 'respexit-me
 '(:latin "Respéxit me * et exaudívit deprecatiónem meam Dóminus."
   :translations
   ((do . "The Lord hath heard * my supplication: the Lord hath received my prayer."))))

(bcp-roman-antiphonary-register
 'deus-adjuvat-me
 '(:latin "Deus ádjuvat me: * et Dóminus suscéptor est ánimæ meæ."
   :translations
   ((do . "For behold God is my helper: * and the Lord is the protector of my soul."))))

(bcp-roman-antiphonary-register
 'quam-bonus-israel
 '(:latin "Quam bonus * Israël Deus, his, qui recto sunt corde."
   :translations
   ((do . "How good is God * to Israel, to them that are of a right heart!"))))

(bcp-roman-antiphonary-register
 'excita-domine-potentiam
 '(:latin "Éxcita, Dómine, * poténtiam tuam, ut salvos fácias nos."
   :translations
   ((do . "Stir up thy might, O Lord, * and come to save us."))))

(bcp-roman-antiphonary-register
 'clamor-meus-domine
 '(:latin "Clamor meus, * Dómine, ad te pervéniat: non avértas fáciem tuam a me."
   :translations
   ((do . "Let my cry reach unto thee, O Lord: * turn not away thy face from me."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Sext antiphons (one per day, per-annum)

(bcp-roman-antiphonary-register
 'alleluia-tuus-sum-ego
 '(:latin "Allelúja, * tuus sum ego, salvum me fac, Dómine, allelúja, allelúja."
   :translations
   ((do . "Alleluia, * I am thine, save thou me, O Lord, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'in-tua-justitia
 '(:latin "In tua justítia * líbera me, Dómine."
   :translations
   ((do . "Deliver me * in thy justice, O Lord."))))

(bcp-roman-antiphonary-register
 'suscepisti-me-domine
 '(:latin "Suscepísti me, Dómine: * et confirmásti me in conspéctu tuo."
   :translations
   ((do . "But thou hast upheld me, O Lord, * and hast established me in thy sight for ever."))))

(bcp-roman-antiphonary-register
 'in-deo-speravi-non-timebo
 '(:latin "In Deo sperávi * non timébo quid fáciat mihi homo."
   :translations
   ((do . "In God I have put my trust * I will not fear what flesh can do against me."))))

(bcp-roman-antiphonary-register
 'memor-esto-congregationis
 '(:latin "Memor esto * congregatiónis tuæ, Dómine, quam possedísti ab inítio."
   :translations
   ((do . "Remember * thy congregation, which thou hast possessed from the beginning."))))

(bcp-roman-antiphonary-register
 'beati-qui-habitant
 '(:latin "Beáti, qui hábitant * in domo tua, Dómine."
   :translations
   ((do . "Blessed are they * that dwell in thy house, O Lord."))))

(bcp-roman-antiphonary-register
 'domine-deus-meus-magnificatus
 '(:latin "Dómine, Deus meus * magnificátus es veheménter."
   :translations
   ((do . "O Lord, my God, * thou art exceedingly great."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: None antiphons (one per day, per-annum)

(bcp-roman-antiphonary-register
 'alleluia-faciem-tuam
 '(:latin "Allelúja, * fáciem tuam, Dómine, illúmina super servum tuum, allelúja, allelúja."
   :translations
   ((do . "Alleluia, * make thy face to shine upon thy servant, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'exsultate-justi
 '(:latin "Exsultáte, justi, * et gloriámini, omnes recti corde."
   :translations
   ((do . "Rejoice ye just, * and glory, all ye right of heart."))))

(bcp-roman-antiphonary-register
 'salvasti-nos-domine
 '(:latin "Salvásti nos, * Dómine, et in nómine tuo confitébimur in sǽcula."
   :translations
   ((do . "Thou hast saved us, O Lord, * and in thy name we will give praise for ever."))))

(bcp-roman-antiphonary-register
 'deus-meus-misericordia
 '(:latin "Deus meus * misericórdia tua prævéniet me."
   :translations
   ((do . "My God, * his mercy shall prevent me."))))

(bcp-roman-antiphonary-register
 'invocabimus-nomen-tuum
 '(:latin "Invocábimus * nomen tuum, Dómine: narrábimus mirabília tua."
   :translations
   ((do . "We will call * upon thy name O Lord. We will relate thy wondrous works."))))

(bcp-roman-antiphonary-register
 'misericordia-et-veritas
 '(:latin "Misericórdia et véritas * præcédent fáciem tuam, Dómine."
   :translations
   ((do . "Mercy and truth * shall go before thy face, O Lord."))))

(bcp-roman-antiphonary-register
 'ne-tacueris-deus
 '(:latin "Ne tacúeris Deus, * quia sermónibus ódii circumdedérunt me."
   :translations
   ((do . "O God, be thou not silent * for the mouth of the wicked man is opened against me."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Invitatory antiphons (per-annum, one per day)

(bcp-roman-antiphonary-register
 'dominum-qui-fecit-nos
 '(:latin "Dóminum, qui fecit nos, * Veníte, adorémus."
   :translations
   ((do . "The Lord it is who made us * Come, let us adore Him."))))

(bcp-roman-antiphonary-register
 'venite-exsultemus-domino
 '(:latin "Veníte, * Exsultémus Dómino."
   :translations
   ((do . "Come * Let us glorify the Lord."))))

(bcp-roman-antiphonary-register
 'jubilemus-deo-salutari
 '(:latin "Jubilémus Deo, * Salutári nostro."
   :translations
   ((do . "Let us adore God * Our Saviour."))))

(bcp-roman-antiphonary-register
 'deum-magnum-dominum
 '(:latin "Deum magnum Dóminum, * Veníte, adorémus."
   :translations
   ((do . "God is the great Lord * Come, let us adore Him."))))

(bcp-roman-antiphonary-register
 'regem-magnum-dominum
 '(:latin "Regem magnum Dóminum, * Veníte, adorémus."
   :translations
   ((do . "The Lord is a great King * Come, let us adore Him."))))

(bcp-roman-antiphonary-register
 'dominum-deum-nostrum
 '(:latin "Dóminum, Deum nostrum, * Veníte, adorémus."
   :translations
   ((do . "The Lord is our God * Come, let us adore Him."))))

(bcp-roman-antiphonary-register
 'populus-domini-et-oves
 '(:latin "Pópulus Dómini, et oves páscuæ ejus: * Veníte, adorémus."
   :translations
   ((do . "We are God's people and the sheep of His pasture, * Come, let us adore Him."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: ferial Matins antiphons (Daya cursus, per-annum)
;;
;; 1 nocturn per ferial day (Mon–Sat), 6 antiphons each covering 2 psalms.

;;; ─── Monday Matins (Daya1: Psalms 26–37) ────────────────────────────────

(bcp-roman-antiphonary-register
 'dominus-defensor
 '(:latin "Dóminus defénsor * vitæ meæ."
   :translations
   ((do . "The Lord is the defence * of my life."))))

(bcp-roman-antiphonary-register
 'adorate-dominum-in-aula
 '(:latin "Adoráte * Dóminum in aula sancta ejus."
   :translations
   ((do . "Worship the Lord * in His holy courts."))))

(bcp-roman-antiphonary-register
 'rectos-decet
 '(:latin "Rectos decet * collaudátio."
   :translations
   ((do . "Praise is comely * for the upright."))))

(bcp-roman-antiphonary-register
 'expugna-impugnantes
 '(:latin "Expúgna * impugnántes me."
   :translations
   ((do . "Fight against them * that fight against me."))))

(bcp-roman-antiphonary-register
 'revela-domino
 '(:latin "Revéla * Dómino viam tuam."
   :translations
   ((do . "Show * thy way unto the Lord."))))

;;; ─── Tuesday Matins (Daya2: Psalms 38–51) ───────────────────────────────

(bcp-roman-antiphonary-register
 'ut-non-delinquam
 '(:latin "Ut non delínquam * in lingua mea."
   :translations
   ((do . "That I sin not * with my tongue."))))

(bcp-roman-antiphonary-register
 'sana-domine-animam
 '(:latin "Sana * Dómine ánimam meam, qui peccávi tibi."
   :translations
   ((do . "Heal * my soul, O Lord, for I have sinned against Thee."))))

(bcp-roman-antiphonary-register
 'eructavit-cor-meum
 '(:latin "Eructávit * cor meum verbum bonum."
   :translations
   ((do . "Mine heart * is overflowing with a good matter."))))

(bcp-roman-antiphonary-register
 'adjutor-in-tribulationibus
 '(:latin "Adjútor * in tribulatiónibus."
   :translations
   ((do . "Our help * in trouble."))))

(bcp-roman-antiphonary-register
 'magnus-dominus-laudabilis
 '(:latin "Magnus Dóminus * et laudábilis nimis."
   :translations
   ((do . "Great is the Lord * and greatly to be praised."))))

(bcp-roman-antiphonary-register
 'deus-deorum
 '(:latin "Deus deórum * Dóminus locútus est."
   :translations
   ((do . "The God of gods * even the Lord, hath spoken."))))

;;; ─── Wednesday Matins (Daya3: Psalms 52–67) ─────────────────────────────

(bcp-roman-antiphonary-register
 'avertit-dominus
 '(:latin "Avértit Dóminus * captivitátem plebis suæ."
   :translations
   ((do . "God bringeth back * the captivity of His people."))))

(bcp-roman-antiphonary-register
 'quoniam-in-te-confidit
 '(:latin "Quóniam * in te confídit ánima mea."
   :translations
   ((do . "For my soul * trusteth in Thee."))))

(bcp-roman-antiphonary-register
 'juste-judicate
 '(:latin "Juste judicáte * fílii hóminum."
   :translations
   ((do . "Judge uprightly * O ye sons of men."))))

(bcp-roman-antiphonary-register
 'da-nobis-domine-auxilium
 '(:latin "Da nobis * Dómine auxílium de tribulatióne."
   :translations
   ((do . "Give us * help from trouble, O Lord."))))

(bcp-roman-antiphonary-register
 'nonne-deo-subjecta
 '(:latin "Nonne Deo * subjécta erit ánima mea."
   :translations
   ((do . "Doth not my soul * wait upon God?"))))

(bcp-roman-antiphonary-register
 'benedicite-gentes
 '(:latin "Benedícite * gentes Deum nostrum."
   :translations
   ((do . "O bless our God * ye people."))))

;;; ─── Thursday Matins (Daya4: Psalms 68–79) ──────────────────────────────

(bcp-roman-antiphonary-register
 'domine-deus-in-adjutorium
 '(:latin "Dómine Deus, * in adjutórium meum inténde."
   :translations
   ((do . "Make haste * O Lord God, to deliver me."))))

(bcp-roman-antiphonary-register
 'esto-mihi-in-deum
 '(:latin "Esto mihi, * Dómine, in Deum protectórem."
   :translations
   ((do . "Be Thou my God * my protector."))))

(bcp-roman-antiphonary-register
 'liberasti-virgam
 '(:latin "Liberásti virgam * hereditátis tuæ."
   :translations
   ((do . "Thou hast redeemed the rod * of Thine inheritance."))))

(bcp-roman-antiphonary-register
 'et-invocabimus-nomen
 '(:latin "Et invocábimus * nomen tuum, Dómine."
   :translations
   ((do . "And we will call * upon Thy name, O Lord."))))

(bcp-roman-antiphonary-register
 'tu-es-deus-qui-facis
 '(:latin "Tu es Deus * qui facis mirabília."
   :translations
   ((do . "Thou art the God * That doest wonders."))))

(bcp-roman-antiphonary-register
 'propitius-esto-peccatis
 '(:latin "Propítius esto * peccátis meis, Dómine."
   :translations
   ((do . "Be merciful * unto our sins, O Lord."))))

;;; ─── Friday Matins (Daya5: Psalms 80–96) ────────────────────────────────

(bcp-roman-antiphonary-register
 'exsultate-deo-adjutori
 '(:latin "Exsultáte Deo * adjutóri nostro."
   :translations
   ((do . "Sing aloud * unto God our strength."))))

(bcp-roman-antiphonary-register
 'tu-solus-altissimus
 '(:latin "Tu solus * Altíssimus super omnem terram."
   :translations
   ((do . "Thou alone * art the Most High over all the earth."))))

(bcp-roman-antiphonary-register
 'benedixisti-domine-terram
 '(:latin "Benedixísti * Dómine terram tuam."
   :translations
   ((do . "Lord * Thou hast been favourable unto Thy land."))))

(bcp-roman-antiphonary-register
 'fundamenta-ejus
 '(:latin "Fundaménta ejus * in móntibus sanctis."
   :translations
   ((do . "Her foundation * is in the holy mountains."))))

(bcp-roman-antiphonary-register
 'benedictus-dominus-in-aeternum
 '(:latin "Benedíctus Dóminus * in ætérnum: fiat, fiat."
   :translations
   ((do . "Blessed be * the Lord for evermore."))))

(bcp-roman-antiphonary-register
 'cantate-domino-benedicite-nominis
 '(:latin "Cantáte Dómino * et benedícite nóminis ejus."
   :translations
   ((do . "Sing * unto the Lord, and bless His name."))))

;;; ─── Saturday Matins (Daya6: Psalms 97–108, 91, 100) ────────────────────

(bcp-roman-antiphonary-register
 'quia-mirabilia-fecit
 '(:latin "Quia mirabília * fecit Dóminus."
   :translations
   ((do . "For the Lord * hath done marvellous things."))))

(bcp-roman-antiphonary-register
 'jubilate-deo-omnis
 '(:latin "Jubiláte * Deo omnis terra."
   :translations
   ((do . "Sing joyfully * to God, all the earth."))))

(bcp-roman-antiphonary-register
 'clamor-meus-ad-te-veniat
 '(:latin "Clamor meus * ad te véniat Deus."
   :translations
   ((do . "O God, * let my cry come unto Thee."))))

(bcp-roman-antiphonary-register
 'benedic-anima-mea-domino
 '(:latin "Bénedic * ánima mea Dómino."
   :translations
   ((do . "Bless the Lord, * O my soul."))))

(bcp-roman-antiphonary-register
 'visita-nos-domine
 '(:latin "Vísita nos * Dómine in salutári tuo."
   :translations
   ((do . "Visit us * with Thy salvation, O Lord."))))

(bcp-roman-antiphonary-register
 'confitebor-domino-nimis
 '(:latin "Confitébor Dómino * nimis in ore meo."
   :translations
   ((do . "I will greatly praise * the Lord with my mouth."))))

(bcp-roman-antiphonary-register
 'bonum-est-confiteri
 '(:latin "Bonum est * confitéri Dómino."
   :translations
   ((do . "It is good * to give praise to God."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sunday Matins antiphons (Psalterium, 3 nocturns × 3)

;; Nocturn I

(bcp-roman-antiphonary-register
 'beatus-vir-qui-in-lege
 '(:latin "Beátus vir * qui in lege Dómini meditátur."
   :translations
   ((do . "Blessed is the man * who studieth the law of the Lord."))))

(bcp-roman-antiphonary-register
 'servite-domino-in-timore
 '(:latin "Servíte Dómino * in timóre, et exsultáte ei cum tremóre."
   :translations
   ((do . "Serve ye the Lord * with fear: and rejoice unto him with trembling."))))

(bcp-roman-antiphonary-register
 'exsurge-domine-salvum
 '(:latin "Exsúrge, * Dómine, salvum me fac, Deus meus."
   :translations
   ((do . "Arise, * O Lord; save me, O my God."))))

;; Nocturn II

(bcp-roman-antiphonary-register
 'quam-admirabile
 '(:latin "Quam admirábile * est nomen tuum, Dómine, in univérsa terra!"
   :translations
   ((do . "How admirable * is thy name, O Lord, in the whole earth!"))))

(bcp-roman-antiphonary-register
 'sedisti-super-thronum
 '(:latin "Sedísti super thronum * qui júdicas justítiam."
   :translations
   ((do . "Thou hast sat on the throne * who judgest justice."))))

(bcp-roman-antiphonary-register
 'exsurge-domine-non-praevaleat
 '(:latin "Exsúrge, Dómine, * non præváleat homo."
   :translations
   ((do . "Arise, O Lord, * let not man prevail."))))

;; Nocturn III

(bcp-roman-antiphonary-register
 'ut-quid-domine-recessisti
 '(:latin "Ut quid, Dómine, * recessísti longe?"
   :translations
   ((do . "Why, O Lord, * hast thou retired afar off?"))))

(bcp-roman-antiphonary-register
 'exsurge-domine-deus-exaltetur
 '(:latin "Exsúrge, * Dómine Deus, exaltétur manus tua."
   :translations
   ((do . "Arise, O Lord God, * let thy hand be exalted."))))

(bcp-roman-antiphonary-register
 'justus-dominus
 '(:latin "Justus Dóminus * et justítiam diléxit."
   :translations
   ((do . "The Lord is just * and He hath loved justice."))))

(provide 'bcp-roman-antiphonary)

;;; bcp-roman-antiphonary.el ends here
