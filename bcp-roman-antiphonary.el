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
Tried in sequence until a translation is found.
The special translator `scripture' dynamically fetches verse text
from the user's configured Bible translation via `bcp-fetcher'.
Only active for antiphon source types listed in
`bcp-roman-antiphonary-scripture-sources'."
  :type  '(repeat symbol)
  :group 'bcp-roman-antiphonary)

(defcustom bcp-roman-antiphonary-scripture-sources '(vulgate)
  "Antiphon source types eligible for scripture-translation fetching.
When `scripture' appears in `bcp-roman-antiphonary-translators',
only antiphons whose :source is in this list will be fetched.
Possible values: `vulgate' (NT/OT direct quotes),
`gallican' (psalter antiphons), `paraphrase' (adapted scripture).
`composition' antiphons have no scripture reference and are never fetched."
  :type '(repeat symbol)
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

(defun bcp-roman-antiphonary--fetch-scripture (ref)
  "Fetch scripture text for breviary REF synchronously, or nil.
Uses `bcp-fetcher' with the render layer's reference normalizer."
  (condition-case nil
      (progn
        (require 'bcp-roman-render nil t)
        (require 'bcp-fetcher nil t)
        (when (and (fboundp 'bcp-roman-render--normalize-ref)
                   (fboundp 'bcp-fetcher-fetch))
          (let* ((normalized (bcp-roman-render--normalize-ref ref))
                 (done nil)
                 (result nil))
            (bcp-fetcher-fetch normalized
                               (lambda (text)
                                 (setq result text done t)))
            (let ((deadline (+ (float-time) 10)))
              (while (and (not done) (< (float-time) deadline))
                (accept-process-output nil 0.1)))
            result)))
    (error nil)))

(defun bcp-roman-antiphonary-english (incipit)
  "Return the English text for antiphon INCIPIT.
Walks `bcp-roman-antiphonary-translators' fallback chain.
The special translator `scripture' dynamically fetches the verse
from the user's configured Bible translation when the antiphon's
source type is in `bcp-roman-antiphonary-scripture-sources'."
  (let* ((entry (alist-get incipit bcp-roman-antiphonary--entries))
         (translations (plist-get entry :translations)))
    (cl-loop
     for translator in bcp-roman-antiphonary-translators
     thereis
     (if (eq translator 'scripture)
         ;; Dynamic scripture fetch
         (let ((cached (alist-get 'scripture translations)))
           (or cached
               (let* ((source (plist-get entry :source))
                      (ref    (plist-get entry :ref)))
                 (when (and ref
                            (memq source bcp-roman-antiphonary-scripture-sources))
                   (let ((text (bcp-roman-antiphonary--fetch-scripture ref)))
                     (when text
                       ;; Cache in the translations alist for subsequent calls
                       (setf (alist-get 'scripture
                                        (plist-get (alist-get incipit
                                                              bcp-roman-antiphonary--entries)
                                                   :translations))
                             text)
                       text))))))
       ;; Normal static translator lookup
       (alist-get translator translations)))))

(defun bcp-roman-antiphonary-get (incipit language)
  "Return antiphon INCIPIT text for LANGUAGE.
LANGUAGE is \\='latin or \\='english."
  (pcase language
    ('latin   (bcp-roman-antiphonary-latin incipit))
    ('english (or (bcp-roman-antiphonary-english incipit)
                  (bcp-roman-antiphonary-latin incipit)))
    (_        (bcp-roman-antiphonary-latin incipit))))

(defun bcp-roman-antiphonary-source (incipit)
  "Return the source classification for antiphon INCIPIT.
Returns a symbol: `vulgate', `gallican', `paraphrase', or `composition'."
  (plist-get (alist-get incipit bcp-roman-antiphonary--entries) :source))

(defun bcp-roman-antiphonary-ref (incipit)
  "Return the scripture reference for antiphon INCIPIT, or nil.
E.g. \"Cant 1:11\" or \"Ps 109\"."
  (plist-get (alist-get incipit bcp-roman-antiphonary--entries) :ref))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Vespers antiphons

(bcp-roman-antiphonary-register
 'dum-esset-rex
 '(:latin "Dum esset Rex in accúbitu suo, nardus mea dedit odórem suavitátis."
   :source vulgate
   :ref "Cant 1:11"
   :translations
   ((bute . "While the King sitteth at his table, my spikenard sendeth forth the smell thereof."))))

(bcp-roman-antiphonary-register
 'laeva-ejus
 '(:latin "Læva ejus sub cápite meo, et déxtera illíus amplexábitur me."
   :source vulgate
   :ref "Cant 2:6"
   :translations
   ((bute . "His left hand is under my head, and his right hand doth embrace me."))))

(bcp-roman-antiphonary-register
 'nigra-sum
 '(:latin "Nigra sum, sed formósa, fíliæ Jerúsalem; ídeo diléxit me Rex, et introdúxit me in cubículum suum."
   :source vulgate
   :ref "Cant 1:4-5"
   :translations
   ((bute . "I am black but comely, O ye daughters of Jerusalem; therefore hath the King loved me, and brought me into his chamber."))))

(bcp-roman-antiphonary-register
 'jam-hiems-transiit
 '(:latin "Jam hiems tránsiit, imber ábiit et recéssit: surge, amíca mea, et veni."
   :source vulgate
   :ref "Cant 2:11-13"
   :translations
   ((bute . "Lo the winter is past, the rain is over and gone. Rise up, my love, and come away."))))

(bcp-roman-antiphonary-register
 'speciosa-facta-es
 '(:latin "Speciósa facta es et suávis in delíciis tuis, sancta Dei Génetrix."
   :source composition
   :translations
   ((bute . "O Holy Mother of God, thou art become beautiful and gentle in thy gladness."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Vespers canticle antiphons

(bcp-roman-antiphonary-register
 'beata-mater-et-intacta
 '(:latin "Beáta Mater et intácta Virgo, gloriósa Regína mundi, intercéde pro nobis ad Dóminum."
   :source composition
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
   :source composition
   :translations
   ((bute . "Mary hath been taken to heaven; the Angels rejoice; they praise and bless the Lord."))))

(bcp-roman-antiphonary-register
 'maria-virgo-assumpta
 '(:latin "María Virgo assúmpta est ad æthéreum thálamum, in quo Rex regum stelláto sedet sólio."
   :source composition
   :translations
   ((bute . "The Virgin Mary hath been taken into the chamber on high, where the King of kings sitteth on a throne amid the stars."))))

(bcp-roman-antiphonary-register
 'in-odorem-unguentorum
 '(:latin "In odórem unguentórum tuórum cúrrimus: adolescéntulæ dilexérunt te nimis."
   :source vulgate
   :ref "Cant 1:3"
   :translations
   ((bute . "We run after thee, on the scent of thy perfumes; the virgins love thee heartily."))))

(bcp-roman-antiphonary-register
 'benedicta-filia
 '(:latin "Benedícta fília tu a Dómino: quia per te fructum vitæ communicávimus."
   :source vulgate
   :ref "Judith 13:23"
   :translations
   ((bute . "Blessed of the Lord art thou, O daughter, for by thee we have been given to eat of the fruit of the tree of Life."))))

(bcp-roman-antiphonary-register
 'pulchra-es-et-decora
 '(:latin "Pulchra es, et decóra, fília Jerúsalem: terríbilis ut castrórum ácies ordináta."
   :source vulgate
   :ref "Cant 6:3"
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
   :source vulgate
   :ref "Luc 1:28"
   :translations
   ((bute . "Hail Mary, full of grace, * The Lord is with thee."))))

(bcp-roman-antiphonary-register
 'benedicta-tu-in-mulieribus
 '(:latin "Benedícta tu in muliéribus, et benedíctus fructus ventris tui."
   :source vulgate
   :ref "Luc 1:42"
   :translations
   ((bute . "Blessed art thou among women, and blessed is the fruit of thy womb."))))

(bcp-roman-antiphonary-register
 'sicut-myrrha-electa
 '(:latin "Sicut myrrha elécta, odórem dedísti suavitátis, sancta Dei Génetrix."
   :source composition
   :translations
   ((bute . "O Holy Mother of God, thou hast yielded a pleasant odor like the best myrrh."))))

(bcp-roman-antiphonary-register
 'ante-torum
 '(:latin "Ante torum hujus Vírginis frequentáte nobis dúlcia cántica drámatis."
   :source composition
   :translations
   ((bute . "Sing for us again and again before this maiden's bed the tender idylls of the play."))))

(bcp-roman-antiphonary-register
 'sicut-laetantium
 '(:latin "Sicut lætántium ómnium nostrum habitátio est in te, sancta Dei Génetrix."
   :source gallican
   :ref "Ps 86"
   :translations
   ((bute . "O Holy Mother of God, all we who dwell in thee are in gladness."))))

(bcp-roman-antiphonary-register
 'gaude-maria-virgo
 '(:latin "Gaude, María Virgo: cunctas hǽreses sola interemísti in univérso mundo."
   :source composition
   :translations
   ((bute . "Joy to thee, O Virgin Mary, thou hast trampled down all the heresies in the whole world."))))

(bcp-roman-antiphonary-register
 'dignare-me-laudare-te
 '(:latin "Dignáre me laudáre te, Virgo sacráta: da mihi virtútem contra hostes tuos."
   :source composition
   :translations
   ((bute . "Holy Virgin, my praise by thee accepted be; give me strength against thine enemies."))))

(bcp-roman-antiphonary-register
 'post-partum-virgo
 '(:latin "Post partum, Virgo, invioláta permansísti: Dei Génetrix, intercéde pro nobis."
   :source composition
   :translations
   ((bute . "After thy delivery thou still remainest a virgin; undefiled Mother of God, pray for us."))))

(bcp-roman-antiphonary-register
 'sancta-maria-succurre-miseris
 '(:latin "Sancta María, succúrre míseris, juva pusillánimes, réfove flébiles, ora pro pópulo, intérveni pro clero, intercéde pro devóto femíneo sexu: séntiant omnes tuum juvámen, quicúmque célebrant tuam sanctam festivitátem."
   :source composition
   :translations
   ((bute . "O Holy Mary, be thou an help to the helpless, a strength to the fearful, a comfort to the sorrowful; pray for the people, plead for the clergy, make intercession for all women vowed to God: may all that are keeping this thine holy Feast-day feel the might of thine assistance."))))

(bcp-roman-antiphonary-register
 'beata-es-maria
 '(:latin "Beáta es, María, quæ credidísti: perficiéntur in te, quæ dicta sunt tibi a Dómino, allelúja."
   :source composition
   :translations
   ((bute . "O Mary, blessed art thou that didst believe! for there shall be a performance of those things which were told thee from the Lord. Alleluia."))))

(bcp-roman-antiphonary-register
 'beatam-me-dicent
 '(:latin "Beátam me dicent omnes generatiónes, quia ancíllam húmilem respéxit Deus."
   :source vulgate
   :ref "Luc 1:48"
   :translations
   ((bute . "All generations shall call me blessed, for God hath regarded the lowliness of His hand-maiden."))))

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
   :source composition
   :translations
   ((bute . "All ye saints of God, vouchsafe to plead for our salvation and for that of all mankind."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Sunday Vespers antiphons

(bcp-roman-antiphonary-register
 'dixit-dominus
 '(:latin "Dixit Dóminus * Dómino meo: Sede a dextris meis."
   :source gallican
   :ref "Ps 109"
   :translations
   ((do . "The Lord said to my Lord: * Sit thou at my right hand."))))

(bcp-roman-antiphonary-register
 'magna-opera-domini
 '(:latin "Magna ópera Dómini: * exquisíta in omnes voluntátes ejus."
   :source gallican
   :ref "Ps 110"
   :translations
   ((do . "Great are the works of the Lord, * sought out according to all his wills."))))

(bcp-roman-antiphonary-register
 'qui-timet-dominum
 '(:latin "Qui timet Dóminum, * in mandátis ejus cupit nimis."
   :source gallican
   :ref "Ps 111"
   :translations
   ((do . "Blessed is the man that feareth the Lord; * he shall delight exceedingly in his commandments."))))

(bcp-roman-antiphonary-register
 'sit-nomen-domini
 '(:latin "Sit nomen Dómini * benedíctum in sǽcula."
   :source gallican
   :ref "Ps 112"
   :translations
   ((do . "Blessed be the name of the Lord * from henceforth now and for ever."))))

(bcp-roman-antiphonary-register
 'deus-autem-noster
 '(:latin "Deus autem noster * in cælo: ómnia quæcúmque vóluit, fecit."
   :source gallican
   :ref "Ps 113"
   :translations
   ((do . "But our God is in heaven, * he hath done all things whatsoever he would."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Monday Vespers antiphons

(bcp-roman-antiphonary-register
 'inclinavit-dominus
 '(:latin "Inclinávit Dóminus * aurem suam mihi."
   :source gallican
   :ref "Ps 114"
   :translations
   ((do . "The Lord hath inclined * his ear unto me."))))

(bcp-roman-antiphonary-register
 'vota-mea
 '(:latin "Vota mea * Dómino reddam coram omni pópulo ejus."
   :source gallican
   :ref "Ps 115:9"
   :translations
   ((do . "I will pay my vows * in the sight of all his people."))))

(bcp-roman-antiphonary-register
 'clamavi-et-dominus
 '(:latin "Clamávi * et Dóminus exaudívit me."
   :source gallican
   :ref "Ps 119:1"
   :translations
   ((do . "I have cried to the Lord, * and he hath heard me."))))

(bcp-roman-antiphonary-register
 'auxilium-meum
 '(:latin "Auxílium meum * a Dómino, qui fecit cælum et terram."
   :source gallican
   :ref "Ps 120:2"
   :translations
   ((do . "My help is from the Lord, * who made heaven and earth."))))

(bcp-roman-antiphonary-register
 'laetatus-sum
 '(:latin "Lætátus sum * in his, quæ dicta sunt mihi."
   :source gallican
   :ref "Ps 121"
   :translations
   ((do . "I rejoiced * at the things that were said to me."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Tuesday Vespers antiphons

(bcp-roman-antiphonary-register
 'qui-habitas-in-caelis
 '(:latin "Qui hábitas in cælis, * miserére nobis."
   :source gallican
   :ref "Ps 122"
   :translations
   ((do . "Thou who dwellest in heaven, * have mercy on us."))))

(bcp-roman-antiphonary-register
 'adjutorium-nostrum
 '(:latin "Adjutórium nostrum * in nómine Dómini."
   :source gallican
   :ref "Ps 123"
   :translations
   ((do . "Our help is * in the name of the Lord."))))

(bcp-roman-antiphonary-register
 'in-circuitu-populi
 '(:latin "In circúitu pópuli sui * Dóminus, ex hoc nunc et usque in sǽculum."
   :source gallican
   :ref "Ps 124"
   :translations
   ((do . "The Lord standeth round his people * from this time forth and for evermore."))))

(bcp-roman-antiphonary-register
 'magnificavit-dominus
 '(:latin "Magnificávit Dóminus * fácere nobíscum: facti sumus lætántes."
   :source gallican
   :ref "Ps 125"
   :translations
   ((do . "The Lord hath * done great things for us, whereof we rejoice."))))

(bcp-roman-antiphonary-register
 'dominus-aedificet
 '(:latin "Dóminus ædíficet * nobis domum, et custódiat civitátem."
   :source gallican
   :ref "Ps 126"
   :translations
   ((do . "The Lord builds * the house and keeps the city."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Wednesday Vespers antiphons

(bcp-roman-antiphonary-register
 'beati-omnes
 '(:latin "Beáti omnes * qui timent Dóminum."
   :source gallican
   :ref "Ps 127"
   :translations
   ((do . "Blessed are all * they that fear the Lord."))))

(bcp-roman-antiphonary-register
 'confundantur-omnes
 '(:latin "Confundántur omnes * qui odérunt Sion."
   :source gallican
   :ref "Ps 128"
   :translations
   ((do . "Let them all be confounded * who hate Sion."))))

(bcp-roman-antiphonary-register
 'de-profundis
 '(:latin "De profúndis * clamávi ad te, Dómine."
   :source gallican
   :ref "Ps 129"
   :translations
   ((do . "Out of the depths * I have cried to thee, O Lord."))))

(bcp-roman-antiphonary-register
 'domine-non-est-exaltatum
 '(:latin "Dómine, * non est exaltátum cor meum."
   :source gallican
   :ref "Ps 130:1"
   :translations
   ((do . "O Lord * my heart is not exalted."))))

(bcp-roman-antiphonary-register
 'elegit-dominus
 '(:latin "Elégit Dóminus * Sion in habitatiónem sibi."
   :source gallican
   :ref "Ps 131"
   :translations
   ((do . "The Lord hath chosen * Sion for his dwelling."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Thursday Vespers antiphons

(bcp-roman-antiphonary-register
 'ecce-quam-bonum
 '(:latin "Ecce quam bonum * et quam jucúndum habitáre fratres in unum."
   :source gallican
   :ref "Ps 132"
   :translations
   ((do . "Behold how good * and how pleasant it is for brethren to dwell together in unity."))))

(bcp-roman-antiphonary-register
 'confitemini-domino-quoniam
 '(:latin "Confitémini Dómino * quóniam in ætérnum misericórdia ejus."
   :source gallican
   :ref "Ps 135:1"
   :translations
   ((do . "Give ye glory to the Lord * for his mercy endureth for ever."))))

(bcp-roman-antiphonary-register
 'confitemini-domino-quia
 '(:latin "Confitémini Dómino * quia in humilitáte nostra memor fuit nostri."
   :source gallican
   :ref "Ps 135"
   :translations
   ((do . "Give ye glory to the Lord * for he was mindful of us in our affliction."))))

(bcp-roman-antiphonary-register
 'adhaereat-lingua-mea
 '(:latin "Adhǽreat lingua mea * fáucibus meis, si non memínero tui Jerúsalem."
   :source gallican
   :ref "Ps 136"
   :translations
   ((do . "Let my tongue cleave to my jaws * if I do not remember thee, Jerusalem."))))

(bcp-roman-antiphonary-register
 'confitebor-nomini-tuo
 '(:latin "Confitébor * nómini tuo, Dómine, super misericórdia et veritáte tua."
   :source gallican
   :ref "Ps 107"
   :translations
   ((do . "I will give glory * to thy name, for thy mercy, and for thy truth."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Friday Vespers antiphons

(bcp-roman-antiphonary-register
 'domine-probasti-me
 '(:latin "Dómine, * probásti me et cognovísti me."
   :source gallican
   :ref "Ps 138:1"
   :translations
   ((do . "Lord, * thou hast proved me, and known me."))))

(bcp-roman-antiphonary-register
 'mirabilia-opera-tua
 '(:latin "Mirabília ópera tua, * Dómine, et ánima mea cognóscit nimis."
   :source gallican
   :ref "Ps 138"
   :translations
   ((do . "Wonderful are thy works * and my soul knoweth right well."))))

(bcp-roman-antiphonary-register
 'ne-derelinquas-me
 '(:latin "Ne derelínquas me, * Dómine, virtus salútis meæ."
   :source gallican
   :ref "Ps 139"
   :translations
   ((do . "Do not thou forsake me, * O Lord, the strength of my salvation."))))

(bcp-roman-antiphonary-register
 'domine-clamavi-ad-te
 '(:latin "Dómine, * clamávi ad te, exáudi me."
   :source gallican
   :ref "Ps 140:1"
   :translations
   ((do . "I have cried to thee, * O Lord, hear me."))))

(bcp-roman-antiphonary-register
 'educ-de-custodia
 '(:latin "Educ de custódia * ánimam meam, Dómine, ad confiténdum nómini tuo."
   :source gallican
   :ref "Ps 141"
   :translations
   ((do . "Bring my soul * out of prison, O Lord, that I may praise thy name."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Saturday Vespers antiphons

(bcp-roman-antiphonary-register
 'benedictus-dominus-susceptor
 '(:latin "Benedíctus Dóminus * suscéptor meus et liberátor meus."
   :source gallican
   :ref "Ps 88"
   :translations
   ((do . "Blessed be the Lord * my support, and my deliverer."))))

(bcp-roman-antiphonary-register
 'beatus-populus
 '(:latin "Beátus pópulus * cujus Dóminus Deus ejus."
   :source gallican
   :ref "Ps 143"
   :translations
   ((do . "Happy is that people * whose God is the Lord."))))

(bcp-roman-antiphonary-register
 'magnus-dominus-et-laudabilis
 '(:latin "Magnus Dóminus * et laudábilis nimis: et magnitúdinis ejus non est finis."
   :source gallican
   :ref "Ps 47"
   :translations
   ((do . "For the Lord is great * and exceedingly to be praised: His greatness has no end."))))

(bcp-roman-antiphonary-register
 'suavis-dominus
 '(:latin "Suávis Dóminus * univérsis: et miseratiónes ejus super ómnia ópera ejus."
   :source gallican
   :ref "Ps 144"
   :translations
   ((do . "The Lord is sweet * to all: and his tender mercies are over all his works."))))

(bcp-roman-antiphonary-register
 'fidelis-dominus
 '(:latin "Fidélis Dóminus * in ómnibus verbis suis: et sanctus in ómnibus opéribus suis."
   :source gallican
   :ref "Ps 144"
   :translations
   ((do . "The Lord is faithful * in all his words: and holy in all his works."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Compline antiphons (one per day, covering 3 psalms)

(bcp-roman-antiphonary-register
 'miserere-mihi-domine
 '(:latin "Miserére * mihi, Dómine, et exáudi oratiónem meam."
   :source gallican
   :ref "Ps 50:3"
   :translations
   ((do . "Have mercy * on me, O Lord, and hear my prayer."))))

(bcp-roman-antiphonary-register
 'salvum-me-fac-domine
 '(:latin "Salvum me fac, * Dómine, propter misericórdiam tuam."
   :source gallican
   :ref "Ps 68"
   :translations
   ((do . "Deliver my soul, * O Lord, save me for thy mercy's sake."))))

(bcp-roman-antiphonary-register
 'tu-domine-servabis
 '(:latin "Tu, Dómine, * servábis nos: et custódies nos in ætérnum."
   :source gallican
   :ref "Ps 11:8"
   :translations
   ((do . "Thou, O Lord, * wilt preserve us: and keep us for ever."))))

(bcp-roman-antiphonary-register
 'immittet-angelus
 '(:latin "Immíttet Ángelus Dómini * in circúitu timéntium eum: et erípiet eos."
   :source gallican
   :ref "Ps 33:8"
   :translations
   ((do . "The angel of the Lord * shall encamp round about them that fear him: and shall deliver them."))))

(bcp-roman-antiphonary-register
 'adjutor-meus
 '(:latin "Adjútor meus * et liberátor meus esto, Dómine."
   :source gallican
   :ref "Ps 53:6"
   :translations
   ((do . "Thou art my helper * and my deliverer, O Lord."))))

(bcp-roman-antiphonary-register
 'voce-mea-ad-dominum
 '(:latin "Voce mea * ad Dóminum clamávi: neque obliviscétur miseréri Deus."
   :source gallican
   :ref "Ps 141:2"
   :translations
   ((do . "I have cried * to the Lord with my voice, do not forget to show mercy, O God."))))

(bcp-roman-antiphonary-register
 'intret-oratio-mea
 '(:latin "Intret orátio mea * in conspéctu tuo, Dómine."
   :source gallican
   :ref "Ps 87:3"
   :translations
   ((do . "May my request * come before thee, O Lord."))))

;;; ─── Compline Nunc dimittis antiphon (invariant) ──────────────────────────

(bcp-roman-antiphonary-register
 'salva-nos-domine
 '(:latin "Salva nos, * Dómine, vigilántes, custódi nos dormiéntes; ut vigilémus cum Christo, et requiescámus in pace."
   :source gallican
   :ref "Ps 43:4"
   :translations
   ((do . "Protect us, * Lord, while we are awake and safeguard us while we sleep; that we may keep watch with Christ, and rest in peace."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: ferial Magnificat antiphons (Vespers, per-annum)

(bcp-roman-antiphonary-register
 'magnificat-anima-mea-quia
 '(:latin "Magníficat * ánima mea Dóminum, quia respéxit Deus humilitátem meam."
   :source vulgate
   :ref "Luc 1:46"
   :translations
   ((do . "My soul * magnifies the Lord, because God has regarded my lowliness."))))

(bcp-roman-antiphonary-register
 'exsultavit-spiritus
 '(:latin "Exsultávit * spíritus meus in Deo salutári meo."
   :source vulgate
   :ref "Luc 1:47"
   :translations
   ((do . "My spirit rejoices * in God, in my Saviour."))))

(bcp-roman-antiphonary-register
 'respexit-dominus-humilitatem
 '(:latin "Respéxit Dóminus * humilitátem meam, et fecit in me magna, qui potens est."
   :source vulgate
   :ref "Luc 1:48"
   :translations
   ((do . "The Lord has regarded * my lowliness, and he who is mighty has done great things through me."))))

(bcp-roman-antiphonary-register
 'fecit-deus-potentiam
 '(:latin "Fecit Deus * poténtiam in brácchio suo: dispérsit supérbos mente cordis sui."
   :source vulgate
   :ref "Luc 1:51"
   :translations
   ((do . "God has shown * the power of his arm: he has scattered the proud in the imagination of their hearts."))))

(bcp-roman-antiphonary-register
 'deposuit-dominus
 '(:latin "Depósuit Dóminus * poténtes de sede, et exaltávit húmiles."
   :source vulgate
   :ref "Luc 1:52"
   :translations
   ((do . "The Lord has put down * the mighty from their seat, and exalted the humble and meek."))))

(bcp-roman-antiphonary-register
 'suscepit-deus-israel
 '(:latin "Suscépit Deus * Israël, púerum suum: sicut locútus est ad Ábraham, et semen ejus usque in sǽculum."
   :source vulgate
   :ref "Luc 1:54"
   :translations
   ((do . "God hath received * Israel his servant: as he spoke to our fathers, to Abraham and to his seed for ever."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Lauds antiphons (Laudes1, per-annum)

;;; ─── Sunday Lauds ────────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'alleluia-dominus-regnavit
 '(:latin "Allelúja, * Dóminus regnávit, decórem índuit, allelúja, allelúja."
   :source gallican
   :ref "Ps 92:1"
   :translations
   ((do . "Alleluia, * The Lord hath reigned, he is clothed with beauty, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'jubilate-deo-omnis-terra
 '(:latin "Jubiláte * Deo omnis terra, allelúja."
   :source gallican
   :ref "Ps 99:2"
   :translations
   ((do . "Shout with joy to God * all the earth, alleluia."))))

(bcp-roman-antiphonary-register
 'benedicam-te-in-vita
 '(:latin "Benedícam te * in vita mea, Dómine: et in nómine tuo levábo manus meas, allelúja."
   :source gallican
   :ref "Ps 62"
   :translations
   ((do . "I will bless thee all my life long * and in thy name I will lift up my hands, alleluia."))))

(bcp-roman-antiphonary-register
 'tres-pueri
 '(:latin "Tres púeri * jussu regis in fornácem missi sunt, non timéntes flammam ignis, dicéntes: Benedíctus Deus, allelúja."
   :source composition
   :translations
   ((do . "The three young boys * cast into the furnace by the king, fearing not the flames of fire, said: Blessed be God, alleluia."))))

(bcp-roman-antiphonary-register
 'alleluia-laudate-dominum-de-caelis
 '(:latin "Allelúja, * laudáte Dóminum de cælis, allelúja, allelúja."
   :source gallican
   :ref "Ps 148:1"
   :translations
   ((do . "Alleluia, * praise ye the Lord from the heavens, alleluia, alleluia."))))

;;; ─── Monday Lauds ────────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'jubilate-deo-in-voce
 '(:latin "Jubiláte * Deo in voce exsultatiónis."
   :source gallican
   :ref "Ps 46:2"
   :translations
   ((do . "All ye nations * shout unto God with the voice of joy."))))

(bcp-roman-antiphonary-register
 'intende-voci
 '(:latin "Inténde * voci oratiónis meæ, Rex meus et Deus meus."
   :source gallican
   :ref "Ps 5:3"
   :translations
   ((do . "Hearken to the voice * of my prayer, O my King and my God."))))

(bcp-roman-antiphonary-register
 'deus-majestatis
 '(:latin "Deus majestátis * intónuit: afférte glóriam nómini ejus."
   :source gallican
   :ref "Ps 28"
   :translations
   ((do . "The God of majesty * hath thundered, ascribe to the Lord glory to his name."))))

(bcp-roman-antiphonary-register
 'laudamus-nomen-tuum
 '(:latin "Laudámus nomen tuum * ínclitum, Deus noster."
   :source gallican
   :ref "Ps 211"
   :translations
   ((do . "O God of majesty, * we praise thy glorious name."))))

(bcp-roman-antiphonary-register
 'laudate-dominum-omnes-gentes
 '(:latin "Laudáte * Dóminum omnes gentes."
   :source gallican
   :ref "Ps 116:1"
   :translations
   ((do . "O praise the Lord, * all ye nations."))))

;;; ─── Tuesday Lauds ───────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'cantate-domino-et-benedicite
 '(:latin "Cantáte * Dómino et benedícite nómini ejus."
   :source gallican
   :ref "Ps 95"
   :translations
   ((do . "Sing ye * to the Lord and bless his name."))))

(bcp-roman-antiphonary-register
 'salutare-vultus-mei
 '(:latin "Salutáre vultus mei, * Deus meus."
   :source gallican
   :ref "Ps 42:5"
   :translations
   ((do . "The salvation of my countenance * and my God."))))

(bcp-roman-antiphonary-register
 'illumina-domine-vultum
 '(:latin "Illúmina, Dómine, * vultum tuum super nos."
   :source gallican
   :ref "Ps 62"
   :translations
   ((do . "May the Lord shine the light * of his countenance upon us."))))

(bcp-roman-antiphonary-register
 'exaltate-regem
 '(:latin "Exaltáte * Regem sæculórum in opéribus vestris."
   :source gallican
   :ref "Ps 98:5"
   :translations
   ((do . "Give ye glory to him * in your works."))))

(bcp-roman-antiphonary-register
 'laudate-nomen-domini
 '(:latin "Laudáte * nomen Dómini, qui statis in domo Dómini."
   :source gallican
   :ref "Ps 134:1"
   :translations
   ((do . "Praise * the name of the Lord, ye who stand in the house of the Lord."))))

;;; ─── Wednesday Lauds ─────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'dominus-regnavit-exsultet
 '(:latin "Dóminus regnávit, * exsúltet terra."
   :source gallican
   :ref "Ps 96"
   :translations
   ((do . "The Lord hath reigned * let the earth rejoice."))))

(bcp-roman-antiphonary-register
 'te-decet-hymnus
 '(:latin "Te decet hymnus, * Deus, in Sion."
   :source gallican
   :ref "Ps 64"
   :translations
   ((do . "A hymn, O God, * becometh thee in Sion."))))

(bcp-roman-antiphonary-register
 'tibi-domine-psallam
 '(:latin "Tibi, Dómine, psallam, * et intéllegam in via immaculáta."
   :source gallican
   :ref "Ps 100"
   :translations
   ((do . "I shall sing to thee, O Lord * and I shall understand with a perfect heart."))))

(bcp-roman-antiphonary-register
 'domine-magnus-es-tu
 '(:latin "Dómine, magnus es tu, * et præclárus in virtúte tua."
   :source gallican
   :ref "Ps 213"
   :translations
   ((do . "O Lord, great art thou * and glorious in thy power."))))

(bcp-roman-antiphonary-register
 'laudabo-deum-meum
 '(:latin "Laudábo Deum meum * in vita mea."
   :source gallican
   :ref "Ps 145"
   :translations
   ((do . "I shall praise the Lord * in my life."))))

;;; ─── Thursday Lauds ──────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'jubilate-in-conspectu
 '(:latin "Jubiláte * in conspéctu regis Dómini."
   :source gallican
   :ref "Ps 97:6"
   :translations
   ((do . "Make a joyful noise * before the Lord our King."))))

(bcp-roman-antiphonary-register
 'domine-refugium
 '(:latin "Dómine, * refúgium factus es nobis."
   :source gallican
   :ref "Ps 89:1"
   :translations
   ((do . "Lord, * thou hast been our refuge."))))

(bcp-roman-antiphonary-register
 'domine-in-caelo-misericordia
 '(:latin "Dómine, * in cælo misericórdia tua."
   :source gallican
   :ref "Ps 35:6"
   :translations
   ((do . "O Lord, * thy mercy is in heaven."))))

(bcp-roman-antiphonary-register
 'populus-meus-bonis
 '(:latin "Pópulus meus, * ait Dóminus, bonis meis adimplébitur."
   :source gallican
   :ref "Ps 65:12"
   :translations
   ((do . "My people, * said the Lord, shall be filled with good things."))))

(bcp-roman-antiphonary-register
 'deo-nostro-jucunda
 '(:latin "Deo nostro * jucúnda sit laudátio."
   :source gallican
   :ref "Ps 146:1"
   :translations
   ((do . "To our God * be joyful and fitting praise."))))

;;; ─── Friday Lauds ────────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'exaltate-dominum-deum
 '(:latin "Exaltáte * Dóminum Deum nostrum, et adoráte in monte sancto ejus."
   :source gallican
   :ref "Ps 98:9"
   :translations
   ((do . "Exalt ye the Lord * our God, and worship him upon his holy mountain."))))

(bcp-roman-antiphonary-register
 'eripe-me-de-inimicis
 '(:latin "Éripe me * de inimícis meis, Dómine, ad te confúgi."
   :source gallican
   :ref "Ps 58:2"
   :translations
   ((do . "Deliver me from my enemies, * O Lord, to thee have I fled."))))

(bcp-roman-antiphonary-register
 'benedixisti-domine
 '(:latin "Benedixísti, * Dómine, terram tuam: remisísti iniquitátem plebis tuæ."
   :source gallican
   :ref "Ps 83"
   :translations
   ((do . "Lord, thou hast blessed thy land; * Thou hast forgiven the iniquity of thy people."))))

(bcp-roman-antiphonary-register
 'in-domino-justificabitur
 '(:latin "In Dómino justificábitur * et laudábitur omne semen Israël."
   :source gallican
   :ref "Ps 215"
   :translations
   ((do . "In the Lord * shall all the seed of Israel be justified and praised."))))

(bcp-roman-antiphonary-register
 'lauda-jerusalem
 '(:latin "Lauda, * Jerúsalem, Dóminum."
   :source gallican
   :ref "Ps 147:1"
   :translations
   ((do . "Praise the Lord, * O Jerusalem."))))

;;; ─── Saturday Lauds ──────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'filii-sion-exsultent
 '(:latin "Fílii Sion * exsúltent in Rege suo."
   :source gallican
   :ref "Ps 149"
   :translations
   ((do . "Let the children of Sion * be joyful in their king."))))

(bcp-roman-antiphonary-register
 'quam-magnificata
 '(:latin "Quam magnificáta * sunt ópera tua, Dómine."
   :source gallican
   :ref "Ps 91"
   :translations
   ((do . "O Lord, * how great are thy works!"))))

(bcp-roman-antiphonary-register
 'laetabitur-justus
 '(:latin "Lætábitur justus * in Dómino et sperábit in eo."
   :source gallican
   :ref "Ps 63"
   :translations
   ((do . "The just shall rejoice * in the Lord, and shall hope in him."))))

(bcp-roman-antiphonary-register
 'ostende-nobis-domine
 '(:latin "Osténde nobis, Dómine, * lucem miseratiónum tuárum."
   :source gallican
   :ref "Ps 84:8"
   :translations
   ((do . "Show us, O Lord, * the light of thy mercies."))))

(bcp-roman-antiphonary-register
 'omnis-spiritus-laudet
 '(:latin "Omnis spíritus * laudet Dóminum."
   :source gallican
   :ref "Ps 150"
   :translations
   ((do . "Let every thing that hath breath * praise the Lord."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: ferial Benedictus antiphons (Lauds, per-annum)

(bcp-roman-antiphonary-register
 'benedictus-dominus-deus-israel
 '(:latin "Benedíctus * Dóminus Deus Israël, quia visitávit et liberávit nos."
   :source vulgate
   :ref "Luc 1:68"
   :translations
   ((do . "Blessed be the Lord * the God of Israel, because he has visited and redeemed his people."))))

(bcp-roman-antiphonary-register
 'erexit-nobis
 '(:latin "Eréxit nobis * Dóminus cornu salútis in domo David púeri sui."
   :source vulgate
   :ref "Luc 1:69"
   :translations
   ((do . "The Lord has raised up * a horn of salvation for us in the house of David his servant."))))

(bcp-roman-antiphonary-register
 'de-manu-omnium
 '(:latin "De manu ómnium * qui odérunt nos, liberávit nos Dóminus."
   :source vulgate
   :ref "Luc 1:71"
   :translations
   ((do . "From the hand of all * who hate us, the Lord has delivered us."))))

(bcp-roman-antiphonary-register
 'in-sanctitate-serviamus
 '(:latin "In sanctitáte * serviámus Dómino, et liberábit nos ab inimícis nostris."
   :source vulgate
   :ref "Luc 1:74-75"
   :translations
   ((do . "In holiness * let us serve the Lord, and he will deliver us from our enemies."))))

(bcp-roman-antiphonary-register
 'per-viscera-misericordiae
 '(:latin "Per víscera misericórdiæ * Dei nostri visitávit nos Óriens ex alto."
   :source vulgate
   :ref "Luc 1:78"
   :translations
   ((do . "Through the tender mercy * of our God, the dayspring from on high has visited us."))))

(bcp-roman-antiphonary-register
 'illumina-domine-sedentes
 '(:latin "Illúmina, Dómine, * sedéntes in ténebris et umbra mortis, et dírige pedes nostros in viam pacis."
   :source vulgate
   :ref "Luc 1:79"
   :translations
   ((do . "O Lord, give light * to those who sit in darkness and in the shadow of death, and guide our feet into the way of peace."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Prime antiphons (one per day, per-annum)

(bcp-roman-antiphonary-register
 'alleluia-confitemini-domino
 '(:latin "Allelúja, * confitémini Dómino, quóniam in sǽculum misericórdia ejus, allelúja, allelúja."
   :source gallican
   :ref "Ps 117:1"
   :translations
   ((do . "Alleluia, * Give glory to the Lord, for his mercy endureth for ever, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'innocens-manibus
 '(:latin "Ínnocens mánibus * et mundo corde ascéndet in montem Dómini."
   :source gallican
   :ref "Ps 23:4"
   :translations
   ((do . "The innocent in hands * and clean of heart shall ascend the mountain of the Lord."))))

(bcp-roman-antiphonary-register
 'deus-meus-in-te-confido
 '(:latin "Deus meus * in te confído non erubéscam."
   :source gallican
   :ref "Ps 24:2"
   :translations
   ((do . "In thee, O my God, * I put my trust; let me not be ashamed."))))

(bcp-roman-antiphonary-register
 'misericordia-tua-domine
 '(:latin "Misericórdia tua, * Dómine, ante óculos meos: et complácui in veritáte tua."
   :source gallican
   :ref "Ps 25:3"
   :translations
   ((do . "For thy mercy, * O Lord, is before my eyes; and I am well pleased with thy truth."))))

(bcp-roman-antiphonary-register
 'in-loco-pascuae
 '(:latin "In loco páscuæ * ibi Dóminus me collocávit."
   :source gallican
   :ref "Ps 22:2"
   :translations
   ((do . "The Lord hath set me * in a place of pasture."))))

(bcp-roman-antiphonary-register
 'ne-discedas-a-me
 '(:latin "Ne discédas a me, * Dómine: quóniam tribulátio próxima est: quóniam non est qui ádjuvet."
   :source gallican
   :ref "Ps 21:12"
   :translations
   ((do . "Depart not from me, * O Lord, for tribulation is very near; for there is none to help me."))))

(bcp-roman-antiphonary-register
 'exaltare-domine-qui-judicas
 '(:latin "Exaltáre, Dómine, * qui júdicas terram: redde retributiónem supérbis."
   :source gallican
   :ref "Ps 93:2"
   :translations
   ((do . "Lift up thyself, O Lord, * thou that judgest the earth: render retribution to the proud."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Terce antiphons (one per day, per-annum)

(bcp-roman-antiphonary-register
 'alleluia-deduc-me
 '(:latin "Allelúja, * deduc me, Dómine, in sémitam mandatórum tuórum, allelúja, allelúja."
   :source gallican
   :ref "Ps 118:35"
   :translations
   ((do . "Alleluia, * Lead me into the path of thy commandments, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'illuminatio-mea
 '(:latin "Illuminátio mea * et salus mea Dóminus."
   :source gallican
   :ref "Ps 26:1"
   :translations
   ((do . "My light * and my salvation is the Lord."))))

(bcp-roman-antiphonary-register
 'respexit-me
 '(:latin "Respéxit me * et exaudívit deprecatiónem meam Dóminus."
   :source gallican
   :ref "Ps 39:2"
   :translations
   ((do . "The Lord hath heard * my supplication: the Lord hath received my prayer."))))

(bcp-roman-antiphonary-register
 'deus-adjuvat-me
 '(:latin "Deus ádjuvat me: * et Dóminus suscéptor est ánimæ meæ."
   :source gallican
   :ref "Ps 53:6"
   :translations
   ((do . "For behold God is my helper: * and the Lord is the protector of my soul."))))

(bcp-roman-antiphonary-register
 'quam-bonus-israel
 '(:latin "Quam bonus * Israël Deus, his, qui recto sunt corde."
   :source gallican
   :ref "Ps 72:1"
   :translations
   ((do . "How good is God * to Israel, to them that are of a right heart!"))))

(bcp-roman-antiphonary-register
 'excita-domine-potentiam
 '(:latin "Éxcita, Dómine, * poténtiam tuam, ut salvos fácias nos."
   :source gallican
   :ref "Ps 79:3"
   :translations
   ((do . "Stir up thy might, O Lord, * and come to save us."))))

(bcp-roman-antiphonary-register
 'clamor-meus-domine
 '(:latin "Clamor meus, * Dómine, ad te pervéniat: non avértas fáciem tuam a me."
   :source gallican
   :ref "Ps 101:2"
   :translations
   ((do . "Let my cry reach unto thee, O Lord: * turn not away thy face from me."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Sext antiphons (one per day, per-annum)

(bcp-roman-antiphonary-register
 'alleluia-tuus-sum-ego
 '(:latin "Allelúja, * tuus sum ego, salvum me fac, Dómine, allelúja, allelúja."
   :source gallican
   :ref "Ps 118:94"
   :translations
   ((do . "Alleluia, * I am thine, save thou me, O Lord, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'in-tua-justitia
 '(:latin "In tua justítia * líbera me, Dómine."
   :source gallican
   :ref "Ps 30:2"
   :translations
   ((do . "Deliver me * in thy justice, O Lord."))))

(bcp-roman-antiphonary-register
 'suscepisti-me-domine
 '(:latin "Suscepísti me, Dómine: * et confirmásti me in conspéctu tuo."
   :source gallican
   :ref "Ps 40:13"
   :translations
   ((do . "But thou hast upheld me, O Lord, * and hast established me in thy sight for ever."))))

(bcp-roman-antiphonary-register
 'in-deo-speravi-non-timebo
 '(:latin "In Deo sperávi * non timébo quid fáciat mihi homo."
   :source gallican
   :ref "Ps 55:12"
   :translations
   ((do . "In God I have put my trust * I will not fear what flesh can do against me."))))

(bcp-roman-antiphonary-register
 'memor-esto-congregationis
 '(:latin "Memor esto * congregatiónis tuæ, Dómine, quam possedísti ab inítio."
   :source gallican
   :ref "Ps 73:2"
   :translations
   ((do . "Remember * thy congregation, which thou hast possessed from the beginning."))))

(bcp-roman-antiphonary-register
 'beati-qui-habitant
 '(:latin "Beáti, qui hábitant * in domo tua, Dómine."
   :source gallican
   :ref "Ps 83:5"
   :translations
   ((do . "Blessed are they * that dwell in thy house, O Lord."))))

(bcp-roman-antiphonary-register
 'domine-deus-meus-magnificatus
 '(:latin "Dómine, Deus meus * magnificátus es veheménter."
   :source gallican
   :ref "Ps 103:1"
   :translations
   ((do . "O Lord, my God, * thou art exceedingly great."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: None antiphons (one per day, per-annum)

(bcp-roman-antiphonary-register
 'alleluia-faciem-tuam
 '(:latin "Allelúja, * fáciem tuam, Dómine, illúmina super servum tuum, allelúja, allelúja."
   :source gallican
   :ref "Ps 118:135"
   :translations
   ((do . "Alleluia, * make thy face to shine upon thy servant, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'exsultate-justi
 '(:latin "Exsultáte, justi, * et gloriámini, omnes recti corde."
   :source gallican
   :ref "Ps 31:11"
   :translations
   ((do . "Rejoice ye just, * and glory, all ye right of heart."))))

(bcp-roman-antiphonary-register
 'salvasti-nos-domine
 '(:latin "Salvásti nos, * Dómine, et in nómine tuo confitébimur in sǽcula."
   :source gallican
   :ref "Ps 43:8"
   :translations
   ((do . "Thou hast saved us, O Lord, * and in thy name we will give praise for ever."))))

(bcp-roman-antiphonary-register
 'deus-meus-misericordia
 '(:latin "Deus meus * misericórdia tua prævéniet me."
   :source gallican
   :ref "Ps 58:18"
   :translations
   ((do . "My God, * his mercy shall prevent me."))))

(bcp-roman-antiphonary-register
 'invocabimus-nomen-tuum
 '(:latin "Invocábimus * nomen tuum, Dómine: narrábimus mirabília tua."
   :source gallican
   :ref "Ps 74:2"
   :translations
   ((do . "We will call * upon thy name O Lord. We will relate thy wondrous works."))))

(bcp-roman-antiphonary-register
 'misericordia-et-veritas
 '(:latin "Misericórdia et véritas * præcédent fáciem tuam, Dómine."
   :source gallican
   :ref "Ps 88:15"
   :translations
   ((do . "Mercy and truth * shall go before thy face, O Lord."))))

(bcp-roman-antiphonary-register
 'ne-tacueris-deus
 '(:latin "Ne tacúeris Deus, * quia sermónibus ódii circumdedérunt me."
   :source gallican
   :ref "Ps 82:2"
   :translations
   ((do . "O God, be thou not silent * for the mouth of the wicked man is opened against me."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: Invitatory antiphons (per-annum, one per day)

(bcp-roman-antiphonary-register
 'dominum-qui-fecit-nos
 '(:latin "Dóminum, qui fecit nos, * Veníte, adorémus."
   :source gallican
   :ref "Ps 94:6"
   :translations
   ((do . "The Lord it is who made us * Come, let us adore Him."))))

(bcp-roman-antiphonary-register
 'venite-exsultemus-domino
 '(:latin "Veníte, * Exsultémus Dómino."
   :source gallican
   :ref "Ps 94:1"
   :translations
   ((do . "Come * Let us glorify the Lord."))))

(bcp-roman-antiphonary-register
 'jubilemus-deo-salutari
 '(:latin "Jubilémus Deo, * Salutári nostro."
   :source gallican
   :ref "Ps 94:1"
   :translations
   ((do . "Let us adore God * Our Saviour."))))

(bcp-roman-antiphonary-register
 'deum-magnum-dominum
 '(:latin "Deum magnum Dóminum, * Veníte, adorémus."
   :source gallican
   :ref "Ps 94:3"
   :translations
   ((do . "God is the great Lord * Come, let us adore Him."))))

(bcp-roman-antiphonary-register
 'regem-magnum-dominum
 '(:latin "Regem magnum Dóminum, * Veníte, adorémus."
   :source gallican
   :ref "Ps 94:3"
   :translations
   ((do . "The Lord is a great King * Come, let us adore Him."))))

(bcp-roman-antiphonary-register
 'dominum-deum-nostrum
 '(:latin "Dóminum, Deum nostrum, * Veníte, adorémus."
   :source gallican
   :ref "Ps 94:6"
   :translations
   ((do . "The Lord is our God * Come, let us adore Him."))))

(bcp-roman-antiphonary-register
 'populus-domini-et-oves
 '(:latin "Pópulus Dómini, et oves páscuæ ejus: * Veníte, adorémus."
   :source gallican
   :ref "Ps 94:7"
   :translations
   ((do . "We are God's people and the sheep of His pasture, * Come, let us adore Him."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Daya-cursus antiphons (obsolete — retained for shared Little Hours symbols)

(bcp-roman-antiphonary-register
 'dominus-defensor
 '(:latin "Dóminus defénsor * vitæ meæ."
   :source gallican
   :ref "Ps 26:1"
   :translations
   ((do . "The Lord is the defence * of my life."))))

(bcp-roman-antiphonary-register
 'adorate-dominum-in-aula
 '(:latin "Adoráte * Dóminum in aula sancta ejus."
   :source gallican
   :ref "Ps 28:2"
   :translations
   ((do . "Worship the Lord * in His holy courts."))))

(bcp-roman-antiphonary-register
 'rectos-decet
 '(:latin "Rectos decet * collaudátio."
   :source gallican
   :ref "Ps 32"
   :translations
   ((do . "Praise is comely * for the upright."))))

(bcp-roman-antiphonary-register
 'expugna-impugnantes
 '(:latin "Expúgna * impugnántes me."
   :source gallican
   :ref "Ps 34:1"
   :translations
   ((do . "Fight against them * that fight against me."))))

(bcp-roman-antiphonary-register
 'revela-domino
 '(:latin "Revéla * Dómino viam tuam."
   :source gallican
   :ref "Ps 36:5"
   :translations
   ((do . "Show * thy way unto the Lord."))))

(bcp-roman-antiphonary-register
 'ut-non-delinquam
 '(:latin "Ut non delínquam * in lingua mea."
   :source gallican
   :ref "Ps 38"
   :translations
   ((do . "That I sin not * with my tongue."))))

(bcp-roman-antiphonary-register
 'sana-domine-animam
 '(:latin "Sana * Dómine ánimam meam, qui peccávi tibi."
   :source gallican
   :ref "Ps 40"
   :translations
   ((do . "Heal * my soul, O Lord, for I have sinned against Thee."))))

(bcp-roman-antiphonary-register
 'eructavit-cor-meum
 '(:latin "Eructávit * cor meum verbum bonum."
   :source gallican
   :ref "Ps 44:2"
   :translations
   ((do . "Mine heart * is overflowing with a good matter."))))

(bcp-roman-antiphonary-register
 'adjutor-in-tribulationibus
 '(:latin "Adjútor * in tribulatiónibus."
   :source gallican
   :ref "Ps 45"
   :translations
   ((do . "Our help * in trouble."))))

(bcp-roman-antiphonary-register
 'magnus-dominus-laudabilis
 '(:latin "Magnus Dóminus * et laudábilis nimis."
   :source gallican
   :ref "Ps 47"
   :translations
   ((do . "Great is the Lord * and greatly to be praised."))))

(bcp-roman-antiphonary-register
 'deus-deorum
 '(:latin "Deus deórum * Dóminus locútus est."
   :source gallican
   :ref "Ps 49"
   :translations
   ((do . "The God of gods * even the Lord, hath spoken."))))

(bcp-roman-antiphonary-register
 'avertit-dominus
 '(:latin "Avértit Dóminus * captivitátem plebis suæ."
   :source gallican
   :ref "Ps 52"
   :translations
   ((do . "God bringeth back * the captivity of His people."))))

(bcp-roman-antiphonary-register
 'quoniam-in-te-confidit
 '(:latin "Quóniam * in te confídit ánima mea."
   :source gallican
   :ref "Ps 56:2"
   :translations
   ((do . "For my soul * trusteth in Thee."))))

(bcp-roman-antiphonary-register
 'juste-judicate
 '(:latin "Juste judicáte * fílii hóminum."
   :source gallican
   :ref "Ps 57"
   :translations
   ((do . "Judge uprightly * O ye sons of men."))))

(bcp-roman-antiphonary-register
 'da-nobis-domine-auxilium
 '(:latin "Da nobis * Dómine auxílium de tribulatióne."
   :source gallican
   :ref "Ps 59"
   :translations
   ((do . "Give us * help from trouble, O Lord."))))

(bcp-roman-antiphonary-register
 'nonne-deo-subjecta
 '(:latin "Nonne Deo * subjécta erit ánima mea."
   :source gallican
   :ref "Ps 61:2"
   :translations
   ((do . "Doth not my soul * wait upon God?"))))

(bcp-roman-antiphonary-register
 'benedicite-gentes
 '(:latin "Benedícite * gentes Deum nostrum."
   :source gallican
   :ref "Ps 61"
   :translations
   ((do . "O bless our God * ye people."))))

(bcp-roman-antiphonary-register
 'domine-deus-in-adjutorium
 '(:latin "Dómine Deus, * in adjutórium meum inténde."
   :source gallican
   :ref "Ps 68"
   :translations
   ((do . "Make haste * O Lord God, to deliver me."))))

(bcp-roman-antiphonary-register
 'esto-mihi-in-deum
 '(:latin "Esto mihi, * Dómine, in Deum protectórem."
   :source gallican
   :ref "Ps 30:3"
   :translations
   ((do . "Be Thou my God * my protector."))))

(bcp-roman-antiphonary-register
 'liberasti-virgam
 '(:latin "Liberásti virgam * hereditátis tuæ."
   :source gallican
   :ref "Ps 73"
   :translations
   ((do . "Thou hast redeemed the rod * of Thine inheritance."))))

(bcp-roman-antiphonary-register
 'et-invocabimus-nomen
 '(:latin "Et invocábimus * nomen tuum, Dómine."
   :source gallican
   :ref "Ps 74"
   :translations
   ((do . "And we will call * upon Thy name, O Lord."))))

(bcp-roman-antiphonary-register
 'tu-es-deus-qui-facis
 '(:latin "Tu es Deus * qui facis mirabília."
   :source gallican
   :ref "Ps 76"
   :translations
   ((do . "Thou art the God * That doest wonders."))))

(bcp-roman-antiphonary-register
 'propitius-esto-peccatis
 '(:latin "Propítius esto * peccátis meis, Dómine."
   :source gallican
   :ref "Ps 78"
   :translations
   ((do . "Be merciful * unto our sins, O Lord."))))

(bcp-roman-antiphonary-register
 'exsultate-deo-adjutori
 '(:latin "Exsultáte Deo * adjutóri nostro."
   :source gallican
   :ref "Ps 79"
   :translations
   ((do . "Sing aloud * unto God our strength."))))

(bcp-roman-antiphonary-register
 'tu-solus-altissimus
 '(:latin "Tu solus * Altíssimus super omnem terram."
   :source gallican
   :ref "Ps 82:19"
   :translations
   ((do . "Thou alone * art the Most High over all the earth."))))

(bcp-roman-antiphonary-register
 'benedixisti-domine-terram
 '(:latin "Benedixísti * Dómine terram tuam."
   :source gallican
   :ref "Ps 83"
   :translations
   ((do . "Lord * Thou hast been favourable unto Thy land."))))

(bcp-roman-antiphonary-register
 'fundamenta-ejus
 '(:latin "Fundaménta ejus * in móntibus sanctis."
   :source gallican
   :ref "Ps 86"
   :translations
   ((do . "Her foundation * is in the holy mountains."))))

(bcp-roman-antiphonary-register
 'benedictus-dominus-in-aeternum
 '(:latin "Benedíctus Dóminus * in ætérnum: fiat, fiat."
   :source gallican
   :ref "Ps 88"
   :translations
   ((do . "Blessed be * the Lord for evermore."))))

(bcp-roman-antiphonary-register
 'cantate-domino-benedicite-nominis
 '(:latin "Cantáte Dómino * et benedícite nóminis ejus."
   :source gallican
   :ref "Ps 95"
   :translations
   ((do . "Sing * unto the Lord, and bless His name."))))

(bcp-roman-antiphonary-register
 'quia-mirabilia-fecit
 '(:latin "Quia mirabília * fecit Dóminus."
   :source gallican
   :ref "Ps 97"
   :translations
   ((do . "For the Lord * hath done marvellous things."))))

(bcp-roman-antiphonary-register
 'jubilate-deo-omnis
 '(:latin "Jubiláte * Deo omnis terra."
   :source gallican
   :ref "Ps 99:2"
   :translations
   ((do . "Sing joyfully * to God, all the earth."))))

(bcp-roman-antiphonary-register
 'clamor-meus-ad-te-veniat
 '(:latin "Clamor meus * ad te véniat Deus."
   :source gallican
   :ref "Ps 101"
   :translations
   ((do . "O God, * let my cry come unto Thee."))))

(bcp-roman-antiphonary-register
 'benedic-anima-mea-domino
 '(:latin "Bénedic * ánima mea Dómino."
   :source gallican
   :ref "Ps 102:1"
   :translations
   ((do . "Bless the Lord, * O my soul."))))

(bcp-roman-antiphonary-register
 'visita-nos-domine
 '(:latin "Vísita nos * Dómine in salutári tuo."
   :source gallican
   :ref "Ps 105"
   :translations
   ((do . "Visit us * with Thy salvation, O Lord."))))

(bcp-roman-antiphonary-register
 'confitebor-domino-nimis
 '(:latin "Confitébor Dómino * nimis in ore meo."
   :source gallican
   :ref "Ps 107"
   :translations
   ((do . "I will greatly praise * the Lord with my mouth."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Psalterium: ferial Matins antiphons (pre-1911 Roman cursus, per-annum)
;;
;; 3 nocturns per ferial day (Mon–Sat), 3 antiphons per nocturn = 9 total.

;;; ─── Monday Matins (Psalms 13, 14, 16, 17a, 17b, 17c, 19, 20, 29) ─────

(bcp-roman-antiphonary-register
 'dominus-de-caelo
 '(:latin "Dóminus de cælo * prospéxit super fílios hóminum."
   :source gallican
   :ref "Ps 13"
   :translations
   ((do . "The Lord hath looked down from heaven * upon the children of men."))))

(bcp-roman-antiphonary-register
 'qui-operatur-justitiam
 '(:latin "Qui operátur justítiam * requiéscet in monte sancto tuo, Dómine."
   :source gallican
   :ref "Ps 14"
   :translations
   ((do . "He who worketh justice * may rest on thy holy mountain, O Lord."))))

(bcp-roman-antiphonary-register
 'inclina-domine-aurem
 '(:latin "Inclína, Dómine, * aurem tuam mihi, et exáudi verba mea."
   :source gallican
   :ref "Ps 85"
   :translations
   ((do . "O Lord, incline * thy ear to me, and hear my voice, my Lord."))))

(bcp-roman-antiphonary-register
 'diligam-te
 '(:latin "Díligam te, * Dómine, virtus mea."
   :source gallican
   :ref "Ps 17"
   :translations
   ((do . "I will love thee, * O Lord, who art my strength."))))

(bcp-roman-antiphonary-register
 'retribuet-mihi-dominus
 '(:latin "Retríbuet mihi Dóminus * secúndum justítiam meam."
   :source gallican
   :ref "Ps 17"
   :translations
   ((do . "The Lord will reward me * according to my justice."))))

(bcp-roman-antiphonary-register
 'vivit-dominus
 '(:latin "Vivit Dóminus * et benedíctus Deus salútis meæ."
   :source gallican
   :ref "Ps 17"
   :translations
   ((do . "The Lord liveth, * and blessed be my God, my salvation."))))

(bcp-roman-antiphonary-register
 'exaudiat-te
 '(:latin "Exáudiat te * Dóminus in die tribulatiónis."
   :source gallican
   :ref "Ps 19"
   :translations
   ((do . "May the Lord hear * thee in the day of tribulation."))))

(bcp-roman-antiphonary-register
 'domine-in-virtute-tua
 '(:latin "Dómine, * in virtúte tua lætábitur rex."
   :source gallican
   :ref "Ps 20:2"
   :translations
   ((do . "The king rejoices * in Thy strength, O Lord."))))

(bcp-roman-antiphonary-register
 'exaltabo-te
 '(:latin "Exaltábo te, * Dómine, quóniam suscepísti me."
   :source gallican
   :ref "Ps 29"
   :translations
   ((do . "I will extol thee, * O Lord, for thou hast upheld me."))))

;;; ─── Tuesday Matins (Psalms 34a, 34b, 34c, 36a, 36b, 36c, 37a, 37b, 38) ──

(bcp-roman-antiphonary-register
 'expugna-domine-impugnantes
 '(:latin "Expúgna, Dómine, * impugnántes me."
   :source gallican
   :ref "Ps 34"
   :translations
   ((do . "Overthrow, O Lord, * them that fight against me."))))

(bcp-roman-antiphonary-register
 'restitue-animam-meam
 '(:latin "Restítue ánimam meam * a malefáctis eórum, Dómine."
   :source gallican
   :ref "Ps 34"
   :translations
   ((do . "Rescue, O Lord, * my soul from their malice."))))

(bcp-roman-antiphonary-register
 'exsurge-domine-intende
 '(:latin "Exsúrge, Dómine, * et inténde judício meo."
   :source gallican
   :ref "Ps 34"
   :translations
   ((do . "Arise, O Lord, * and be attentive to my judgment."))))

(bcp-roman-antiphonary-register
 'noli-aemulari
 '(:latin "Noli æmulári * in eo qui prosperátur et facit iniquitátem."
   :source gallican
   :ref "Ps 36"
   :translations
   ((do . "Envy not * the man who prospereth in his way; the man who doth unjust things."))))

(bcp-roman-antiphonary-register
 'bracchia-peccatorum
 '(:latin "Brácchia peccatórum * conteréntur, confírmat autem justos Dóminus."
   :source gallican
   :ref "Ps 36"
   :translations
   ((do . "The arms of the wicked * shall be broken in pieces; but the Lord strengtheneth the just."))))

(bcp-roman-antiphonary-register
 'custodi-innocentiam
 '(:latin "Custódi innocéntiam * et vide æquitátem."
   :source gallican
   :ref "Ps 36"
   :translations
   ((do . "Keep innocence * and behold justice."))))

(bcp-roman-antiphonary-register
 'ne-in-ira-tua
 '(:latin "Ne in ira tua * corrípias me, Dómine."
   :source gallican
   :ref "Ps 37"
   :translations
   ((do . "O Lord, * do not chastise me in thy wrath."))))

(bcp-roman-antiphonary-register
 'intende-in-adjutorium
 '(:latin "Inténde in adjutórium meum, * Dómine, virtus salútis meæ."
   :source gallican
   :ref "Ps 37"
   :translations
   ((do . "Attend unto my help, * O Lord, the God of my salvation."))))

(bcp-roman-antiphonary-register
 'amove-domine
 '(:latin "Ámove, Dómine, * a me plagas tuas."
   :source gallican
   :ref "Ps 38"
   :translations
   ((do . "Remove, O Lord, * thy scourges from me."))))

;;; ─── Wednesday Matins (Psalms 44a, 44b, 45, 47, 48a, 48b, 49a, 49b, 50) ──

(bcp-roman-antiphonary-register
 'speciosus-forma
 '(:latin "Speciósus forma * præ fíliis hóminum, diffúsa est grátia in lábiis tuis."
   :source gallican
   :ref "Ps 44"
   :translations
   ((do . "Thou art beautiful * above the sons of men: grace is poured abroad in thy lips."))))

(bcp-roman-antiphonary-register
 'confitebuntur-tibi
 '(:latin "Confitebúntur tibi * pópuli Deus in ætérnum."
   :source gallican
   :ref "Ps 44"
   :translations
   ((do . "Let people confess to thee, * O God, forever."))))

(bcp-roman-antiphonary-register
 'adjutor-in-tribulationibus-deus
 '(:latin "Adjútor in tribulatiónibus * Deus noster."
   :source gallican
   :ref "Ps 45"
   :translations
   ((do . "Our God * is our helper in troubles."))))

(bcp-roman-antiphonary-register
 'magnus-dominus-laudabilis-nimis
 '(:latin "Magnus Dóminus * et laudábilis nimis in civitáte Dei nostri."
   :source gallican
   :ref "Ps 47"
   :translations
   ((do . "Great is the Lord * and exceedingly to be praised in the city of our God."))))

(bcp-roman-antiphonary-register
 'os-meum-loquetur
 '(:latin "Os meum loquétur * sapiéntiam: et meditátio cordis mei prudéntiam."
   :source gallican
   :ref "Ps 48"
   :translations
   ((do . "My mouth shall speak * wisdom: and the meditation of my heart understanding."))))

(bcp-roman-antiphonary-register
 'ne-timueris
 '(:latin "Ne timúeris * cum dívite non descéndet in sepúlcrum glória ejus."
   :source gallican
   :ref "Ps 48"
   :translations
   ((do . "Be not thou afraid * the things which made him rich, or his glory shall not descend with him to the sepulchre."))))

;; NOTE: `deus-deorum' already registered above (Daya compat block).

(bcp-roman-antiphonary-register
 'intelligite-qui-obliscimini
 '(:latin "Intellégite, * qui obliviscímini Deum."
   :source gallican
   :ref "Ps 49"
   :translations
   ((do . "Understand these things, * you that forget God."))))

(bcp-roman-antiphonary-register
 'acceptabis-sacrificium
 '(:latin "Acceptábis sacrifícium * justítiæ super altáre tuum, Dómine."
   :source gallican
   :ref "Ps 50"
   :translations
   ((do . "Thou shalt accept the sacrifice * of justice, upon thy altar, O Lord."))))

;;; ─── Thursday Matins (Psalms 61, 65a, 65b, 67a, 67b, 67c, 68a, 68b, 68c) ──

(bcp-roman-antiphonary-register
 'in-deo-salutare-meum
 '(:latin "In Deo salutáre meum * et glória mea: et spes mea in Deo est."
   :source gallican
   :ref "Ps 61"
   :translations
   ((do . "In God is my salvation * and my glory: and my hope is in God."))))

(bcp-roman-antiphonary-register
 'videte-opera-domini
 '(:latin "Vidéte ópera Dómini, * et audítam fácite vocem laudis ejus."
   :source gallican
   :ref "Ps 65"
   :translations
   ((do . "Behold the works of the Lord * and make the voice of his praise to be heard."))))

(bcp-roman-antiphonary-register
 'audite-omnes
 '(:latin "Audíte, omnes * qui timétis Deum, quanta fecit ánimæ meæ."
   :source gallican
   :ref "Ps 65"
   :translations
   ((do . "Come and hear, all ye that fear God * what great things he hath done for my soul."))))

(bcp-roman-antiphonary-register
 'exsurgat-deus
 '(:latin "Exsúrgat Deus, * et dissipéntur inimíci ejus."
   :source gallican
   :ref "Ps 67"
   :translations
   ((do . "Let God arise, * and let his enemies be scattered."))))

(bcp-roman-antiphonary-register
 'deus-noster-deus-salvos
 '(:latin "Deus noster, * Deus salvos faciéndi: et Dómini sunt éxitus mortis."
   :source gallican
   :ref "Ps 67"
   :translations
   ((do . "Our God * is the God of salvation: and the Lord of the issues from death."))))

(bcp-roman-antiphonary-register
 'in-ecclesiis
 '(:latin "In ecclésiis * benedícite Dómino Deo."
   :source gallican
   :ref "Ps 67"
   :translations
   ((do . "In the churches * bless ye God the Lord."))))

(bcp-roman-antiphonary-register
 'salvum-me-fac-deus
 '(:latin "Salvum me fac, * Deus, quóniam intravérunt aquæ usque ad ánimam meam."
   :source gallican
   :ref "Ps 68"
   :translations
   ((do . "Save me, O God * for the waters are come in even unto my soul."))))

(bcp-roman-antiphonary-register
 'propter-inimicos-meos
 '(:latin "Propter inimícos meos * éripe me, Dómine."
   :source gallican
   :ref "Ps 68"
   :translations
   ((do . "O Lord, save me * from my enemies."))))

(bcp-roman-antiphonary-register
 'quaerite-dominum
 '(:latin "Quǽrite Dóminum, * et vivet ánima vestra."
   :source gallican
   :ref "Ps 68"
   :translations
   ((do . "Look for the Lord * and your soul shall live."))))

;;; ─── Friday Matins (Psalms 77a, 77b, 77c, 77d, 77e, 77f, 78, 80, 82) ──

(bcp-roman-antiphonary-register
 'suscitavit-dominus
 '(:latin "Suscitávit Dóminus * testimónium in Jacob: et legem pósuit in Israël."
   :source gallican
   :ref "Ps 77"
   :translations
   ((do . "The Lord set up a testimony in Jacob: * and made a law in Israel."))))

(bcp-roman-antiphonary-register
 'coram-patribus-eorum
 '(:latin "Coram pátribus eórum * fecit Deus mirabília."
   :source gallican
   :ref "Ps 77"
   :translations
   ((do . "The Lord did wonderful things * in the sight of their fathers."))))

(bcp-roman-antiphonary-register
 'januas-caeli
 '(:latin "Jánuas cæli apéruit * Dóminus, et pluit illis manna ad manducándum."
   :source gallican
   :ref "Ps 77"
   :translations
   ((do . "The Lord opened * the doors of heaven and had rained down manna upon them to eat."))))

(bcp-roman-antiphonary-register
 'deus-adjutor
 '(:latin "Deus adjútor * est eórum: et Excélsus redémptor eórum est."
   :source gallican
   :ref "Ps 77"
   :translations
   ((do . "God is their helper, * and the most high God their redeemer."))))

(bcp-roman-antiphonary-register
 'redemit-eos
 '(:latin "Redémit eos * Dóminus de manu tribulántis."
   :source gallican
   :ref "Ps 77"
   :translations
   ((do . "The Lord redeemed them * from the hand of him that afflicted them."))))

(bcp-roman-antiphonary-register
 'aedificavit-deus
 '(:latin "Ædificávit * Deus sanctifícium suum in terra."
   :source gallican
   :ref "Ps 77"
   :translations
   ((do . "God built * his sanctuary in the earth."))))

(bcp-roman-antiphonary-register
 'adjuva-nos-deus
 '(:latin "Ádjuva nos, * Deus, salutáris noster: et propítius esto peccátis nostris."
   :source gallican
   :ref "Ps 78"
   :translations
   ((do . "Help us, O God, our Saviour, * deliver us: and forgive us our sins."))))

(bcp-roman-antiphonary-register
 'ego-sum-dominus
 '(:latin "Ego sum Dóminus * Deus tuus Israël, qui edúxi te de terra Ægýpti."
   :source gallican
   :ref "Ps 80"
   :translations
   ((do . "I am the Lord * God of Israel, who brought you out from the land of Egypt."))))

(bcp-roman-antiphonary-register
 'ne-taceas-deus
 '(:latin "Ne táceas Deus * quóniam inimíci tui extulérunt caput."
   :source gallican
   :ref "Ps 82"
   :translations
   ((do . "Be not thou silent, O Lord, * for Thy enemies lifted up their head."))))

;;; ─── Saturday Matins (Psalms 104a, 104b, 104c, 105a, 105b, 105c, 106a, 106b, 106c) ──

(bcp-roman-antiphonary-register
 'memor-fuit-in-saeculum
 '(:latin "Memor fuit in sǽculum * testaménti sui Dóminus Deus noster."
   :source gallican
   :ref "Ps 104"
   :translations
   ((do . "The memory of thy testament * will live forever, O Lord our God."))))

(bcp-roman-antiphonary-register
 'auxit-dominus
 '(:latin "Auxit Dóminus * pópulum suum: et firmávit eum super inimícos ejus."
   :source gallican
   :ref "Ps 104"
   :translations
   ((do . "The Lord increased his people exceedingly * and strengthened them over their enemies."))))

(bcp-roman-antiphonary-register
 'eduxit-deus
 '(:latin "Edúxit Deus * pópulum suum in exsultatióne, et eléctos suos in lætítia."
   :source gallican
   :ref "Ps 104"
   :translations
   ((do . "The Lord brought forth * his people with joy, and his chosen with gladness."))))

(bcp-roman-antiphonary-register
 'salvavit-eos-dominus
 '(:latin "Salvávit eos Dóminus * propter nomen suum."
   :source gallican
   :ref "Ps 105"
   :translations
   ((do . "The Lord saved them * for his own name's sake."))))

(bcp-roman-antiphonary-register
 'obliti-sunt-deum
 '(:latin "Oblíti sunt Deum * qui salvávit eos."
   :source gallican
   :ref "Ps 105"
   :translations
   ((do . "They forgot God * who saved them."))))

(bcp-roman-antiphonary-register
 'cum-tribularentur
 '(:latin "Cum tribularéntur * vidit Dóminus: et audívit oratiónem eórum."
   :source gallican
   :ref "Ps 105"
   :translations
   ((do . "And he saw when they were in tribulation * and he heard their prayer."))))

(bcp-roman-antiphonary-register
 'clamaverunt-ad-dominum
 '(:latin "Clamavérunt ad Dóminum * et de necessitátibus eórum liberávit eos."
   :source gallican
   :ref "Ps 106"
   :translations
   ((do . "Then they cried to the Lord * and he delivered them out of their distresses."))))

(bcp-roman-antiphonary-register
 'ipsi-viderunt
 '(:latin "Ipsi vidérunt * ópera Dei et mirabília ejus."
   :source gallican
   :ref "Ps 106"
   :translations
   ((do . "These have seen * the works of the Lord, and his wonders."))))

(bcp-roman-antiphonary-register
 'videbunt-recti
 '(:latin "Vidébunt recti * et lætabúntur, et intéllegent misericórdias Dómini."
   :source gallican
   :ref "Ps 106"
   :translations
   ((do . "The just see and rejoice * and understand the mercy of the Lord."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sunday Matins antiphons (Psalterium, 3 nocturns × 3)

;; Nocturn I

(bcp-roman-antiphonary-register
 'beatus-vir-qui-in-lege
 '(:latin "Beátus vir * qui in lege Dómini meditátur."
   :source gallican
   :ref "Ps 1"
   :translations
   ((do . "Blessed is the man * who studieth the law of the Lord."))))

(bcp-roman-antiphonary-register
 'servite-domino-in-timore
 '(:latin "Servíte Dómino * in timóre, et exsultáte ei cum tremóre."
   :source gallican
   :ref "Ps 1"
   :translations
   ((do . "Serve ye the Lord * with fear: and rejoice unto him with trembling."))))

(bcp-roman-antiphonary-register
 'exsurge-domine-salvum
 '(:latin "Exsúrge, * Dómine, salvum me fac, Deus meus."
   :source gallican
   :ref "Ps 34"
   :translations
   ((do . "Arise, * O Lord; save me, O my God."))))

;; Nocturn II

(bcp-roman-antiphonary-register
 'quam-admirabile
 '(:latin "Quam admirábile * est nomen tuum, Dómine, in univérsa terra!"
   :source gallican
   :ref "Ps 8"
   :translations
   ((do . "How admirable * is thy name, O Lord, in the whole earth!"))))

(bcp-roman-antiphonary-register
 'sedisti-super-thronum
 '(:latin "Sedísti super thronum * qui júdicas justítiam."
   :source gallican
   :ref "Ps 9"
   :translations
   ((do . "Thou hast sat on the throne * who judgest justice."))))

(bcp-roman-antiphonary-register
 'exsurge-domine-non-praevaleat
 '(:latin "Exsúrge, Dómine, * non præváleat homo."
   :source gallican
   :ref "Ps 34"
   :translations
   ((do . "Arise, O Lord, * let not man prevail."))))

;; Nocturn III

(bcp-roman-antiphonary-register
 'ut-quid-domine-recessisti
 '(:latin "Ut quid, Dómine, * recessísti longe?"
   :source gallican
   :ref "Ps 9"
   :translations
   ((do . "Why, O Lord, * hast thou retired afar off?"))))

(bcp-roman-antiphonary-register
 'exsurge-domine-deus-exaltetur
 '(:latin "Exsúrge, * Dómine Deus, exaltétur manus tua."
   :source gallican
   :ref "Ps 34"
   :translations
   ((do . "Arise, O Lord God, * let thy hand be exalted."))))

(bcp-roman-antiphonary-register
 'justus-dominus
 '(:latin "Justus Dóminus * et justítiam diléxit."
   :source gallican
   :ref "Ps 10"
   :translations
   ((do . "The Lord is just * and He hath loved justice."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Laudes2 (penitential) antiphons
;;
;; Used on Advent weekdays and Lent/Passiontide weekdays.
;; Psalm 50 (Miserere) replaces the first Lauds psalm; penitential
;; canticles (221–226) replace the per-annum canticles (211–216).

;;; ─── Monday Laudes2 ─────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'miserere-mei-deus-secundum
 '(:latin "Miserére * mei, Deus, secúndum magnam misericórdiam tuam."
   :source gallican
   :ref "Ps 50:3"
   :translations
   ((do . "Have mercy on me, * O God, according to thy great mercy."))))

(bcp-roman-antiphonary-register
 'deduc-me-in-justitia
 '(:latin "Deduc me * in justítia tua, Dómine."
   :source gallican
   :ref "Ps 5:9"
   :translations
   ((do . "Conduct me, * O Lord, in thy justice."))))

(bcp-roman-antiphonary-register
 'dominus-dabit-virtutem
 '(:latin "Dóminus dabit virtútem * et benedícet pópulo suo in pace."
   :source gallican
   :ref "Ps 28"
   :translations
   ((do . "God will give * power and strength to his people."))))

(bcp-roman-antiphonary-register
 'conversus-est-furor-tuus
 '(:latin "Convérsus est furor tuus, * Dómine, et consolátus es me."
   :source vulgate
   :ref "Isa 12:1"
   :translations
   ((do . "Thy wrath is turned away * and thou hast comforted me."))))

(bcp-roman-antiphonary-register
 'laudate-dominum-quoniam-confirmata
 '(:latin "Laudáte * Dóminum quóniam confirmáta est super nos misericórdia ejus."
   :source gallican
   :ref "Ps 116:2"
   :translations
   ((do . "Praise * the Lord, for his mercy is confirmed upon us."))))

;;; ─── Tuesday Laudes2 ────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'dele-iniquitatem-meam
 '(:latin "Dele iniquitátem meam, * Dómine, secúndum multitúdinem miseratiónum tuárum."
   :source gallican
   :ref "Ps 50"
   :translations
   ((do . "According to the multitude of thy tender mercies * blot out my iniquity."))))

(bcp-roman-antiphonary-register
 'discerne-causam-meam
 '(:latin "Discérne causam meam, * Deus, de gente non sancta."
   :source gallican
   :ref "Ps 42"
   :translations
   ((do . "Distinguish my cause, O Lord, * from the nation that is not holy."))))

(bcp-roman-antiphonary-register
 'deus-misereatur-nostri
 '(:latin "Deus misereátur * nostri, et benedícat nobis."
   :source gallican
   :ref "Ps 66"
   :translations
   ((do . "May God have mercy on us * and bless us."))))

(bcp-roman-antiphonary-register
 'corripies-me-domine
 '(:latin "Corrípies me, Dómine, * et vivificábis me."
   :source gallican
   :ref "Ps 222"
   :translations
   ((do . "Thou shalt correct me, O Lord, * and make me to live."))))

(bcp-roman-antiphonary-register
 'laudate-dominum-quia-benignus
 '(:latin "Laudáte * Dóminum quia benígnus est, et in servis suis deprecábitur."
   :source gallican
   :ref "Ps 134:3"
   :translations
   ((do . "Praise * the Lord, for he will judge his people, and be gracious unto his servants."))))

;;; ─── Wednesday Laudes2 ──────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'amplius-lava-me
 '(:latin "Ámplius lava me, * Dómine, ab injustítia mea."
   :source gallican
   :ref "Ps 50"
   :translations
   ((do . "O Lord, wash me * yet more from my iniquity."))))

(bcp-roman-antiphonary-register
 'impietatibus-nostris
 '(:latin "Impietátibus nostris * tu propitiáberis Deus."
   :source gallican
   :ref "Ps 64"
   :translations
   ((do . "O Lord, * thou wilt pardon our transgressions."))))

(bcp-roman-antiphonary-register
 'in-innocentia-cordis
 '(:latin "In innocéntia * cordis mei perambulábo, Dómine."
   :source gallican
   :ref "Ps 100"
   :translations
   ((do . "I walked in the innocence * of my heart, O Lord."))))

(bcp-roman-antiphonary-register
 'exsultavit-cor-meum
 '(:latin "Exsultávit cor meum * in Dómino, qui humíliat et súblevat."
   :source vulgate
   :ref "I Reg 2:1"
   :translations
   ((do . "My heart hath rejoiced * in the Lord, he humbleth and he exalteth."))))

(bcp-roman-antiphonary-register
 'lauda-anima-mea-dominum
 '(:latin "Lauda * ánima mea Dóminum, qui érigit elísos et díligit justos."
   :source gallican
   :ref "Ps 145:1"
   :translations
   ((do . "Praise * the Lord my soul, he lifts up those who fall, and loves the just."))))

;;; ─── Thursday Laudes2 ───────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'tibi-soli-peccavi
 '(:latin "Tibi soli peccávi, * Dómine, miserére mei."
   :source gallican
   :ref "Ps 50"
   :translations
   ((do . "Before thee only have I sinned, * O Lord, have mercy on me."))))

(bcp-roman-antiphonary-register
 'convertere-domine
 '(:latin "Convértere, Dómine, * et deprecábilis esto super servos tuos."
   :source gallican
   :ref "Ps 89"
   :translations
   ((do . "Turn thee again, O Lord, * and be gracious unto thy servants."))))

(bcp-roman-antiphonary-register
 'multiplicasti-deus
 '(:latin "Multiplicásti, Deus, * misericórdiam tuam."
   :source gallican
   :ref "Ps 35"
   :translations
   ((do . "O God, * thou hast multiplied thy mercy."))))

(bcp-roman-antiphonary-register
 'fortitudo-mea-et-laus
 '(:latin "Fortitúdo mea * et laus mea Dóminus: et factus est mihi in salútem."
   :source vulgate
   :ref "Exod 15:2"
   :translations
   ((do . "The Lord is my strength * and my praise, and he is become my salvation."))))

(bcp-roman-antiphonary-register
 'laudate-dominum-qui-sanat
 '(:latin "Laudáte * Dóminum qui sanat contrítos corde, et álligat contritiónes eórum."
   :source gallican
   :ref "Ps 146:3"
   :translations
   ((do . "Praise the Lord * who healeth the broken of heart, and bindeth up their wounds."))))

;;; ─── Friday Laudes2 ─────────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'cor-contritum
 '(:latin "Cor contrítum * et humiliátum, Deus, non despícies."
   :source gallican
   :ref "Ps 50"
   :translations
   ((do . "A contrite and a humbled heart, * O God, thou wilt not despise."))))

(bcp-roman-antiphonary-register
 'propter-nomen-tuum-domine
 '(:latin "Propter nomen tuum, * Dómine, vivificábis me in æquitáte tua."
   :source gallican
   :ref "Ps 142"
   :translations
   ((do . "For thy name's sake, * O Lord, thou wilt quicken me in thy justice."))))

(bcp-roman-antiphonary-register
 'deus-tu-conversus
 '(:latin "Deus, tu convérsus * vivificábis nos, et plebs tua lætábitur in te."
   :source gallican
   :ref "Ps 84"
   :translations
   ((do . "Thou wilt turn, O God, * Thou wilt quicken us and bring us to life."))))

(bcp-roman-antiphonary-register
 'cum-iratus-fueris
 '(:latin "Cum irátus fúeris, * Dómine, misericórdiæ recordáberis."
   :source gallican
   :ref "Ps 225"
   :translations
   ((do . "When thou art angry, * O Lord, thou wilt remember mercy."))))

(bcp-roman-antiphonary-register
 'lauda-deum-tuum-sion
 '(:latin "Lauda * Deum tuum, Sion, qui annúntiat judícia sua Israël."
   :source gallican
   :ref "Ps 147:1"
   :translations
   ((do . "Praise thy God, * O Sion, who declareth his judgments to Israel."))))

;;; ─── Saturday Laudes2 ───────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'benigne-fac-domine
 '(:latin "Benígne fac, Dómine, * in bona voluntáte tua Sion."
   :source gallican
   :ref "Ps 50"
   :translations
   ((do . "In thy good will, O Lord, * deal favourably with Sion."))))

(bcp-roman-antiphonary-register
 'rectus-dominus
 '(:latin "Rectus Dóminus, * Deus noster, et non est iníquitas in eo."
   :source gallican
   :ref "Ps 91"
   :translations
   ((do . "The Lord our God is righteous * and there is no iniquity in him."))))

(bcp-roman-antiphonary-register
 'a-timore-inimici
 '(:latin "A timóre inimíci * éripe, Dómine, ánimam meam."
   :source gallican
   :ref "Ps 63"
   :translations
   ((do . "Deliver my soul, * O Lord, from the fear of the enemy."))))

(bcp-roman-antiphonary-register
 'in-servis-suis
 '(:latin "In servis suis * miserébitur Dóminus et propítius erit terræ pópuli sui."
   :source gallican
   :ref "Ps 134:14"
   :translations
   ((do . "The Lord will judge * his servants, and will have mercy on the people of his land."))))

(bcp-roman-antiphonary-register
 'laudate-dominum-secundum
 '(:latin "Laudáte * Dóminum secúndum multitúdinem magnitúdinis ejus."
   :source gallican
   :ref "Ps 150:2"
   :translations
   ((do . "Praise ye the Lord * according to the excellence of his greatness."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Easter Sunday (Pasc0) — Matins antiphons and invitatory

;;; ─── Easter Sunday Invitatory ─────────────────────────────────────────

(bcp-roman-antiphonary-register
 'surrexit-dominus-vere
 '(:latin "Surréxit Dóminus vere, * Allelúja."
   :source vulgate
   :ref "Luc 24:34"
   :translations
   ((do . "The Lord is risen, indeed, * Alleluia."))))

;;; ─── Easter Sunday Matins Psalm Antiphons ─────────────────────────────

(bcp-roman-antiphonary-register
 'ego-sum-qui-sum-et-consilium
 '(:latin "Ego sum qui sum, * et consílium meum non est cum ímpiis, sed in lege Dómini volúntas mea est, allelúja."
   :source composition
   :translations
   ((do . "I am who I am * and my counsel is not with the ungodly, my will is in the law of God, alleluia."))))

(bcp-roman-antiphonary-register
 'postulavi-patrem-meum
 '(:latin "Postulávi Patrem meum, * allelúja: dedit mihi gentes, allelúja, in hereditátem, allelúja."
   :source gallican
   :ref "Ps 2:8"
   :translations
   ((do . "I asked my Father, * alleluia, and he gave me nations, alleluia, as inheritance, alleluia."))))

(bcp-roman-antiphonary-register
 'ego-dormivi-et-somnum-cepi
 '(:latin "Ego dormívi, * et somnum cepi: et exsurréxi, quóniam Dóminus suscépit me, allelúja, allelúja."
   :source gallican
   :ref "Ps 3:6"
   :translations
   ((do . "I have slept * and have taken my rest: and I have risen up, because the Lord hath protected me, alleluia, alleluia."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Pentecost (Pasc7) — Matins antiphons and invitatory

;;; ─── Pentecost Invitatory ─────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'alleluia-spiritus-domini-replevit
 '(:latin "Allelúja, Spíritus Dómini replévit orbem terrárum: * Veníte, adorémus, allelúja."
   :source vulgate
   :ref "Sap 1:7"
   :translations
   ((do . "Alleluia, the Spirit of the Lord filleth the world: * O come, let us worship Him, alleluia."))))

;;; ─── Pentecost Matins Psalm Antiphons ─────────────────────────────────

(bcp-roman-antiphonary-register
 'factus-est-repente-de-caelo
 '(:latin "Factus est * repénte de cælo sonus adveniéntis spíritus veheméntis, allelúja, allelúja."
   :source vulgate
   :ref "Act 2:2"
   :translations
   ((do . "Suddenly there came a sound from heaven * as of a rushing mighty wind, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'confirma-hoc-deus
 '(:latin "Confírma hoc, Deus, * quod operátus es in nobis: a templo sancto tuo, quod est in Jerúsalem, allelúja, allelúja."
   :source gallican
   :ref "Ps 67:29"
   :translations
   ((do . "Strengthen, O God, that which Thou hast wrought for us, * because of thy holy Temple at Jerusalem, alleluia, alleluia."))))

(bcp-roman-antiphonary-register
 'emitte-spiritum-tuum
 '(:latin "Emítte Spíritum tuum, * et creabúntur: et renovábis fáciem terræ, allelúja, allelúja."
   :source gallican
   :ref "Ps 103:30"
   :translations
   ((do . "Send forth thy Spirit, and they shall be created * and Thou shalt renew the face of the earth, alleluia, alleluia."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Christmas Day — Matins antiphons and invitatory

;;; ─── Christmas Day Invitatory ──────────────────────────────────────────

(bcp-roman-antiphonary-register
 'christus-natus-est-nobis
 '(:latin "Christus natus est nobis: * Veníte, adorémus."
   :source composition
   :translations
   ((do . "Unto us a Christ is born, * O come, let us worship Him."))))

;;; ─── Christmas Day Matins Psalm Antiphons ───────────────────────────────

(bcp-roman-antiphonary-register
 'dominus-dixit-ad-me
 '(:latin "Dóminus dixit * ad me: Fílius meus es tu, ego hódie génui te."
   :source gallican
   :ref "Ps 2:7"
   :translations
   ((do . "The Lord hath said unto Me: * Thou art My Son, this day have I begotten thee."))))

(bcp-roman-antiphonary-register
 'tamquam-sponsus-dominus
 '(:latin "Tamquam sponsus * Dóminus procédens de thálamo suo."
   :source gallican
   :ref "Ps 18:6"
   :translations
   ((do . "The Lord is as a bridegroom * coming out of his chamber."))))

(bcp-roman-antiphonary-register
 'diffusa-est-gratia
 '(:latin "Diffúsa est * grátia in lábiis tuis, proptérea benedíxit te Deus in ætérnum."
   :source gallican
   :ref "Ps 44:3"
   :translations
   ((do . "Grace is poured into thy lips, * therefore God hath blessed thee for ever."))))

(bcp-roman-antiphonary-register
 'suscepimus-deus-misericordiam
 '(:latin "Suscépimus, * Deus, misericórdiam tuam in médio templi tui."
   :source gallican
   :ref "Ps 47:10"
   :translations
   ((do . "We have drunk in thy loving-kindness, * O God, in the midst of thy temple."))))

(bcp-roman-antiphonary-register
 'orietur-in-diebus-domini
 '(:latin "Oriétur * in diébus Dómini abundántia pacis, et dominábitur."
   :source gallican
   :ref "Ps 71:7"
   :translations
   ((do . "In the Lord's days * shall abundance of peace arise and flourish."))))

(bcp-roman-antiphonary-register
 'veritas-de-terra-orta-est
 '(:latin "Véritas de terra * orta est, et justítia de cælo prospéxit."
   :source gallican
   :ref "Ps 84:12"
   :translations
   ((do . "Truth is sprung out of the earth, * and righteousness hath looked down from heaven."))))

(bcp-roman-antiphonary-register
 'ipse-invocabit-me-alleluia
 '(:latin "Ipse invocábit * me, allelúja: Pater meus es tu, allelúja."
   :source gallican
   :ref "Ps 88:27"
   :translations
   ((do . "He shall cry unto Me, alleluia, * Thou art My Father, alleluia."))))

(bcp-roman-antiphonary-register
 'laetentur-caeli-et-exsultet
 '(:latin "Læténtur cæli, * et exsúltet terra ante fáciem Dómini, quóniam venit."
   :source gallican
   :ref "Ps 95:11"
   :translations
   ((do . "Let the heavens rejoice, * and let the earth be glad before the Lord, for He cometh."))))

(bcp-roman-antiphonary-register
 'notum-fecit-dominus-alleluia
 '(:latin "Notum fecit * Dóminus, allelúja, salutáre suum, allelúja."
   :source gallican
   :ref "Ps 97:2"
   :translations
   ((do . "The Lord hath made known, alleluia, * His salvation, alleluia."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; St. Stephen — Matins antiphons and invitatory

;;; ─── St. Stephen Invitatory ────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'christum-natum-qui-beatum
 '(:latin "Christum natum, qui beátum hódie coronávit Stéphanum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "Christ, who this day crowned the blessed Stephen, * O come, let us worship Him."))))

;;; ─── St. Stephen Matins Psalm Antiphons ─────────────────────────────────

(bcp-roman-antiphonary-register
 'in-lege-domini-fuit
 '(:latin "In lege Dómini * fuit volúntas ejus die ac nocte."
   :source gallican
   :ref "Ps 1:2"
   :translations
   ((do . "His delight * was in the law of the Lord day and night."))))

(bcp-roman-antiphonary-register
 'praedicans-praeceptum-domini
 '(:latin "Prǽdicans * præcéptum Dómini constitútus est in monte sancto ejus."
   :source gallican
   :ref "Ps 2:7"
   :translations
   ((do . "The Lord hath set him * upon His holy hill, to declare His decree."))))

(bcp-roman-antiphonary-register
 'voce-mea-ad-dominum-clamavi
 '(:latin "Voce mea * ad Dóminum clamávi: et exaudívit me de monte sancto suo."
   :source gallican
   :ref "Ps 141:2"
   :translations
   ((do . "I cried unto the Lord * with my voice, and He heard me out of His holy hill."))))

(bcp-roman-antiphonary-register
 'filii-hominum-scitote
 '(:latin "Fílii hóminum * scitóte quia Dóminus sanctum suum mirificávit."
   :source gallican
   :ref "Ps 4"
   :translations
   ((do . "O ye sons of men, * know that the Lord hath set apart him that is holy for Himself."))))

(bcp-roman-antiphonary-register
 'scuto-bonae-voluntatis
 '(:latin "Scuto bonæ voluntátis * tuæ coronásti eum Dómine."
   :source gallican
   :ref "Ps 5"
   :translations
   ((do . "O Lord, Thou hast compassed him * with thy favour as with a shield."))))

(bcp-roman-antiphonary-register
 'in-universa-terra-gloria
 '(:latin "In univérsa terra * glória et honóre coronásti eum."
   :source gallican
   :ref "Ps 8"
   :translations
   ((do . "Thou hast crowned him * with glory and honour in all the earth."))))

(bcp-roman-antiphonary-register
 'justus-dominus-et-justitiam
 '(:latin "Justus Dóminus, * et justítiam diléxit: æquitátem vidit vultus ejus."
   :source gallican
   :ref "Ps 10"
   :translations
   ((do . "The righteous Lord * loveth righteousness; His countenance doth behold uprightness."))))

(bcp-roman-antiphonary-register
 'habitabit-in-tabernaculo-tuo
 '(:latin "Habitábit * in tabernáculo tuo: requiéscet in monte sancto tuo."
   :source gallican
   :ref "Ps 14:1"
   :translations
   ((do . "He shall dwell * in thy tabernacle, He shall rest upon thy holy hill."))))

(bcp-roman-antiphonary-register
 'posuisti-domine-super-caput
 '(:latin "Posuísti, Dómine, * super caput ejus corónam de lápide pretióso."
   :source gallican
   :ref "Ps 20"
   :translations
   ((do . "O Lord, Thou hast set a crown * of precious stones upon his head."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Epiphany — Matins antiphons and invitatory

;;; ─── Epiphany Invitatory ───────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'christus-apparuit-nobis
 '(:latin "Christus appáruit nobis, * Veníte adorémus."
   :source composition
   :translations
   ((do . "Christ appeared to us, * O come, let us worship Him."))))

;;; ─── Epiphany Matins Psalm Antiphons ────────────────────────────────────

(bcp-roman-antiphonary-register
 'afferte-domino-filii-dei
 '(:latin "Afférte Dómino * fílii Dei, adoráte Dóminum in aula sancta ejus."
   :source gallican
   :ref "Ps 28:1-2"
   :translations
   ((do . "Give unto the Lord, O ye sons of God, * worship the Lord in His holy courts."))))

(bcp-roman-antiphonary-register
 'fluminis-impetus-laetificat
 '(:latin "Flúminis ímpetus * lætíficat, allelúja, civitátem Dei, allelúja."
   :source gallican
   :ref "Ps 45:5"
   :translations
   ((do . "It is a river, the streams whereof make glad, * alleluia, the city of God, alleluia."))))

(bcp-roman-antiphonary-register
 'psallite-deo-nostro-psallite
 '(:latin "Psállite Deo nostro, * psállite: psállite Regi nostro, psállite sapiénter."
   :source gallican
   :ref "Ps 46:7"
   :translations
   ((do . "Sing praises to our God, sing praises * sing praises unto our King, sing ye praises with understanding."))))

(bcp-roman-antiphonary-register
 'omnis-terra-adoret-te
 '(:latin "Omnis terra adóret te, * et psallat tibi: psalmum dicat nómini tuo, Dómine."
   :source gallican
   :ref "Ps 65:4"
   :translations
   ((do . "Let all the earth worship thee, and sing unto thee * let them sing praises to thy name, O Lord."))))

(bcp-roman-antiphonary-register
 'reges-tharsis-et-insulae
 '(:latin "Reges Tharsis * et ínsulæ múnera ófferent Regi Dómino."
   :source gallican
   :ref "Ps 71:10"
   :translations
   ((do . "The kings of Tarshish and the isles shall bring presents * unto the Lord the King."))))

(bcp-roman-antiphonary-register
 'omnes-gentes-quascumque
 '(:latin "Omnes gentes * quascúmque fecísti, vénient, et adorábunt coram te, Dómine."
   :source gallican
   :ref "Ps 85:9"
   :translations
   ((do . "All nations whom Thou hast made shall come * and worship before thee, O Lord."))))

(bcp-roman-antiphonary-register
 'venite-adoremus-eum-quia-ipse
 '(:latin "Veníte adorémus eum: * quia ipse est Dóminus Deus noster."
   :source composition
   :translations
   ((do . "O come, let us worship Him: * for He is the Lord our God."))))

(bcp-roman-antiphonary-register
 'adorate-dominum-alleluia-in-aula
 '(:latin "Adoráte Dóminum, * allelúja: in aula sancta ejus, allelúja."
   :source gallican
   :ref "Ps 28:2"
   :translations
   ((do . "O worship the Lord, * alleluia, in His holy temple, alleluia."))))

(bcp-roman-antiphonary-register
 'adorate-deum-alleluia-omnes
 '(:latin "Adoráte Deum, * allelúja: omnes Angeli ejus, allelúja."
   :source gallican
   :ref "Ps 96:7"
   :translations
   ((do . "Worship God, * alleluia, all ye His Angels, alleluia."))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Commune Antiphons — Matins
;;;; ══════════════════════════════════════════════════════════════════════════

;;; ─── Commune Invitatory Antiphons ──────────────────────────────────────

(bcp-roman-antiphonary-register
 'regem-apostolorum-dominum
 '(:latin "Regem Apostolórum Dóminum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "The Lord, the King of Apostles, * O come, let us worship."))))

(bcp-roman-antiphonary-register
 'regem-martyrum-dominum
 '(:latin "Regem Mártyrum Dóminum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "The Lord, the King of Martyrs, * O come, let us worship."))))

(bcp-roman-antiphonary-register
 'regem-confessorum-dominum
 '(:latin "Regem Confessórum Dóminum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "The Lord, the King of Confessors, * O come, let us worship."))))

(bcp-roman-antiphonary-register
 'regem-virginum-dominum
 '(:latin "Regem Vírginum Dóminum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "The Lord, the King of Virgins, * O come, let us worship."))))

(bcp-roman-antiphonary-register
 'laudemus-deum-nostrum
 '(:latin "Laudémus Deum nostrum * In confessióne beátæ N.."
   :source composition
   :translations
   ((do . "Let us praise our God * In the confession of blessed N.."))))

(bcp-roman-antiphonary-register
 'sancta-maria-dei-genetrix-virgo
 '(:latin "Sancta María, Dei Génetrix Virgo, * Intercéde pro nobis."
   :source composition
   :translations
   ((do . "Holy Virgin Mary, Mother of God, * pray for us."))))

;;; ─── C1: Apostles — Matins Psalm Antiphons ────────────────────────────

(bcp-roman-antiphonary-register
 'in-omnem-terram-exivit
 '(:latin "In omnem terram * exívit sonus eórum, et in fines orbis terræ verba eórum."
   :source gallican
   :ref "Ps 18:5"
   :translations
   ((do . "Their sound hath gone forth * into all the earth, and their words unto the ends of the world."))))

(bcp-roman-antiphonary-register
 'clamaverunt-justi
 '(:latin "Clamavérunt justi, * et Dóminus exaudívit eos."
   :source gallican
   :ref "Ps 33:18"
   :translations
   ((do . "The just cried, * and the Lord heard them."))))

(bcp-roman-antiphonary-register
 'constitues-eos-principes
 '(:latin "Constítues eos * príncipes super omnem terram: mémores erunt nóminis tui, Dómine."
   :source gallican
   :ref "Ps 44:17"
   :translations
   ((do . "Thou shalt make them * princes over all the earth: they shall remember thy name, O Lord."))))

(bcp-roman-antiphonary-register
 'principes-populorum
 '(:latin "Príncipes populórum * congregáti sunt cum Deo Ábraham."
   :source gallican
   :ref "Ps 46:10"
   :translations
   ((do . "The princes of the people * are gathered together with the God of Abraham."))))

(bcp-roman-antiphonary-register
 'dedisti-hereditatem
 '(:latin "Dedísti hereditátem * timéntibus nomen tuum, Dómine."
   :source gallican
   :ref "Ps 60:6"
   :translations
   ((do . "Thou hast given an inheritance * to them that fear thy name, O Lord."))))

(bcp-roman-antiphonary-register
 'annuntiaverunt-opera-dei
 '(:latin "Annuntiavérunt * ópera Dei, et facta ejus intellexérunt."
   :source gallican
   :ref "Ps 63:10"
   :translations
   ((do . "They declared * the works of God, and understood his doings."))))

(bcp-roman-antiphonary-register
 'exaltabuntur-cornua-justi
 '(:latin "Exaltabúntur * córnua justi, allelúja."
   :source gallican
   :ref "Ps 74:11"
   :translations
   ((do . "The horns of the just * shall be exalted, alleluia."))))

(bcp-roman-antiphonary-register
 'lux-orta-est-justo
 '(:latin "Lux orta est * justo, allelúja, rectis corde lætítia, allelúja."
   :source gallican
   :ref "Ps 96:11"
   :translations
   ((do . "Light is risen * to the just, alleluia, and gladness to the right of heart, alleluia."))))

(bcp-roman-antiphonary-register
 'custodiebant-testimonia
 '(:latin "Custodiébant * testimónia ejus, et præcépta ejus, allelúja."
   :source gallican
   :ref "Ps 98:7"
   :translations
   ((do . "They kept * his testimonies, and his commandments, alleluia."))))

;;; ─── C2: One Martyr (Bishop) — Matins Psalm Antiphons ─────────────────
;;; NOTE: All 9 C2 antiphons already registered under St. Stephen Matins
;;; (lines ~2002-2054). The commune should reference these existing symbols:
;;;   in-lege-domini-fuit
;;;   praedicans-praeceptum-domini  (NOT praedicans-praeceptum)
;;;   voce-mea-ad-dominum-clamavi   (NOT voce-mea-ad-dominum)
;;;   filii-hominum-scitote
;;;   scuto-bonae-voluntatis
;;;   in-universa-terra-gloria
;;;   justus-dominus-et-justitiam
;;;   habitabit-in-tabernaculo-tuo  (NOT habitabit-in-tabernaculo)
;;;   posuisti-domine-super-caput

;;; ─── C3: Many Martyrs — Matins Psalm Antiphons ────────────────────────

(bcp-roman-antiphonary-register
 'secus-decursus-aquarum
 '(:latin "Secus decúrsus aquárum * plantávit víneam justórum, et in lege Dómini fuit volúntas eórum."
   :source gallican
   :ref "Ps 1:3"
   :translations
   ((do . "By the waterside * he planted the vineyard of the just, and in the law of the Lord was their delight."))))

(bcp-roman-antiphonary-register
 'tamquam-aurum-in-fornace
 '(:latin "Tamquam aurum * in fornáce probávit eléctos Dóminus: et quasi holocáusta accépit eos in ætérnum."
   :source vulgate
   :ref "Sap 3:6"
   :translations
   ((do . "As gold in the furnace * the Lord proved his elect: and as a holocaust he received them for ever."))))

(bcp-roman-antiphonary-register
 'si-coram-hominibus
 '(:latin "Si coram homínibus * torménta passi sunt, spes electórum est immortális in ætérnum."
   :source vulgate
   :ref "Sap 3:4"
   :translations
   ((do . "If before men * they suffered torments, the hope of the elect is immortal for ever."))))

(bcp-roman-antiphonary-register
 'dabo-sanctis-meis
 '(:latin "Dabo Sanctis meis * locum nominátum in regno Patris mei, dicit Dóminus."
   :source composition
   :translations
   ((do . "I will give unto my Saints * a named place in the kingdom of my Father, saith the Lord."))))

(bcp-roman-antiphonary-register
 'sanctis-qui-in-terra
 '(:latin "Sanctis, qui in terra sunt ejus, * mirificávit omnes voluntátes meas inter illos."
   :source gallican
   :ref "Ps 15:3"
   :translations
   ((do . "To the Saints that are in his land, * he hath made all my desires wonderful among them."))))

(bcp-roman-antiphonary-register
 'sancti-qui-sperant
 '(:latin "Sancti qui sperant in Dómino, * habébunt fortitúdinem, assúment pennas ut áquilæ, volábunt, et non defícient."
   :source composition
   :translations
   ((do . "The Saints that hope in the Lord * shall have strength, they shall take wings as eagles, they shall fly, and shall not faint."))))

(bcp-roman-antiphonary-register
 'justi-autem-in-perpetuum
 '(:latin "Justi autem * in perpétuum vivent, et apud Dóminum est merces eórum."
   :source paraphrase
   :ref "Sap 5:16"
   :translations
   ((do . "But the just * shall live for evermore, and their reward is with the Lord."))))

(bcp-roman-antiphonary-register
 'tradiderunt-corpora-sua
 '(:latin "Tradidérunt * córpora sua in mortem, ne servírent idólis: ídeo coronáti póssident palmam."
   :source vulgate
   :ref "Dan 3:95"
   :translations
   ((do . "They gave * their bodies to death, that they might not serve idols: therefore crowned, they possess the palm."))))

(bcp-roman-antiphonary-register
 'ecce-merces-sanctorum
 '(:latin "Ecce merces * Sanctórum copiósa est apud Deum: ipsi vero mórtui sunt pro Christo, et vivent in ætérnum."
   :source gallican
   :ref "Ps 45"
   :translations
   ((do . "Behold, the reward * of the Saints is plenteous with God: they died for Christ, and shall live for ever."))))

;;; ─── C4/C5: Confessor — Matins Psalm Antiphons ────────────────────────
;;; NOTE: beatus-vir-qui-in-lege already registered (line ~1604) with
;;; shorter Latin text for a specific feast. The commune version below uses
;;; a distinct symbol to avoid collision.

(bcp-roman-antiphonary-register
 'beatus-vir-qui-in-lege-meditatur
 '(:latin "Beátus vir, * qui in lege Dómini meditátur: volúntas ejus pérmanet die ac nocte, et ómnia quæcúmque fáciet, semper prosperabúntur."
   :source gallican
   :ref "Ps 1"
   :translations
   ((do . "Blessed is the man * that meditateth on the law of the Lord: his will abideth day and night, and whatsoever he doeth shall prosper."))))

(bcp-roman-antiphonary-register
 'beatus-iste-sanctus
 '(:latin "Beátus iste Sanctus, * qui confísus est in Dómino, prædicávit præcéptum Dómini, constitútus est in monte sancto ejus."
   :source composition
   :translations
   ((do . "Blessed is this Saint, * who trusted in the Lord, preached the commandment of the Lord, and was set upon his holy hill."))))

(bcp-roman-antiphonary-register
 'tu-es-gloria-mea
 '(:latin "Tu es glória mea, * tu es suscéptor meus, Dómine; tu exáltans caput meum, et exaudísti me de monte sancto tuo."
   :source gallican
   :ref "Ps 3:4"
   :translations
   ((do . "Thou art my glory, * thou art my upholder, O Lord; thou exaltest my head, and didst hear me from thy holy hill."))))

(bcp-roman-antiphonary-register
 'invocantem-exaudivit
 '(:latin "Invocántem * exaudívit Dóminus Sanctum suum; Dóminus exaudívit eum, et constítuit eum in pace."
   :source gallican
   :ref "Ps 4:2"
   :translations
   ((do . "The Lord heard * his holy one when he called upon him; the Lord heard him, and established him in peace."))))

(bcp-roman-antiphonary-register
 'laetentur-omnes-qui-sperant
 '(:latin "Læténtur omnes * qui sperant in te, Dómine; quóniam tu benedixísti justo, scuto bonæ voluntátis tuæ coronásti eum."
   :source gallican
   :ref "Ps 5:12"
   :translations
   ((do . "Let all rejoice * that hope in thee, O Lord; for thou hast blessed the just man, and crowned him with the shield of thy good will."))))

(bcp-roman-antiphonary-register
 'domine-dominus-noster-quam
 '(:latin "Dómine, Dóminus noster, * quam admirábile est nomen tuum in univérsa terra! quia glória et honóre coronásti Sanctum tuum, et constituísti eum super ópera mánuum tuárum."
   :source gallican
   :ref "Ps 8:2"
   :translations
   ((do . "O Lord our Lord, * how wonderful is thy name in all the earth! for thou hast crowned thy Saint with glory and honour, and hast set him over the works of thy hands."))))

(bcp-roman-antiphonary-register
 'domine-iste-sanctus
 '(:latin "Dómine, * iste Sanctus habitábit in tabernáculo tuo, operátus est justítiam, requiéscet in monte sancto tuo."
   :source composition
   :translations
   ((do . "O Lord, * this Saint shall dwell in thy tabernacle, he hath wrought justice, and shall rest upon thy holy hill."))))

(bcp-roman-antiphonary-register
 'vitam-petiit-a-te
 '(:latin "Vitam pétiit * a te, et tribuísti ei, Dómine: glóriam et magnum decórem imposuísti super eum; posuísti in cápite ejus corónam de lápide pretióso."
   :source gallican
   :ref "Ps 20:5"
   :translations
   ((do . "He asked life of thee, * and thou gavest it to him, O Lord: glory and great beauty hast thou laid upon him; thou hast set upon his head a crown of precious stones."))))

(bcp-roman-antiphonary-register
 'hic-accipiet-benedictionem
 '(:latin "Hic accípiet * benedictiónem a Dómino, et misericórdiam a Deo salutári suo: quia hæc est generátio quæréntium Dóminum."
   :source gallican
   :ref "Ps 23:5"
   :translations
   ((do . "This man shall receive * a blessing from the Lord, and mercy from God his Saviour: for this is the generation of them that seek the Lord."))))

;;; ─── C6: Virgin Martyr — Matins Psalm Antiphons ───────────────────────

(bcp-roman-antiphonary-register
 'o-quam-pulchra-est
 '(:latin "O quam pulchra * est casta generátio cum claritáte!"
   :source composition
   :translations
   ((do . "O how fair * is the chaste generation with glory!"))))

;;; NOTE: ante-torum already registered (line ~205) with translator 'bute'.
;;; The commune version below uses a distinct symbol with DO translation.
(bcp-roman-antiphonary-register
 'ante-torum-hujus-virginis
 '(:latin "Ante torum * hujus Vírginis frequentáte nobis dúlcia cántica drámatis."
   :source composition
   :translations
   ((do . "Before the bed * of this Virgin, sing unto us the sweet canticles of the play."))))

(bcp-roman-antiphonary-register
 'revertere-revertere-sunamitis
 '(:latin "Revértere, * revértere, Sunamítis; revértere, ut intueámur te."
   :source vulgate
   :ref "Cant 6:12"
   :translations
   ((do . "Return, * return, O Sunamitess; return, that we may behold thee."))))

(bcp-roman-antiphonary-register
 'specie-tua-et-pulchritudine
 '(:latin "Spécie tua * et pulchritúdine tua inténde, próspere procéde, et regna."
   :source gallican
   :ref "Ps 44:5"
   :translations
   ((do . "With thy comeliness * and thy beauty set out, proceed prosperously, and reign."))))

(bcp-roman-antiphonary-register
 'adjuvabit-eam-deus
 '(:latin "Adjuvábit eam * Deus vultu suo: Deus in médio ejus, non commovébitur."
   :source gallican
   :ref "Ps 45:6"
   :translations
   ((do . "God shall help her * with his countenance: God is in the midst of her, she shall not be moved."))))

(bcp-roman-antiphonary-register
 'aquae-multae-non-potuerunt
 '(:latin "Aquæ multæ * non potuérunt exstínguere caritátem."
   :source vulgate
   :ref "Cant 8:7"
   :translations
   ((do . "Many waters * could not quench charity."))))

;;; NOTE: nigra-sum already registered (line ~101) with translator 'bute'.
;;; The commune (C6) should reference the existing symbol 'nigra-sum'.
;;; Do NOT use 'nigra-sum-sed-formosa-filiae'.

(bcp-roman-antiphonary-register
 'trahe-me-post-te
 '(:latin "Trahe me post te, * in odórem currémus unguentórum tuórum: óleum effúsum nomen tuum."
   :source vulgate
   :ref "Cant 1:3"
   :translations
   ((do . "Draw me after thee, * we will run to the odour of thy ointments: thy name is as oil poured out."))))

(bcp-roman-antiphonary-register
 'veni-sponsa-christi
 '(:latin "Veni, Sponsa Christi, * áccipe corónam, quam tibi Dóminus præparávit in ætérnum."
   :source composition
   :translations
   ((do . "Come, Bride of Christ, * receive the crown which the Lord hath prepared for thee for ever."))))

;;; ─── C7: Holy Women — Matins Psalm Antiphons ──────────────────────────
;;; NOTE: C7 shares all C6 antiphons except uses 'laeva-ejus' (already
;;; registered at line ~94) in place of 'ante-torum-hujus-virginis'.
;;; The commune file (bcp-roman-commune.el) should use the existing symbol
;;; 'laeva-ejus', NOT 'laeva-ejus-sub-capite'.

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Commune Non-Matins Antiphons
;;;; ══════════════════════════════════════════════════════════════════════════

;;; ─── C1: Apostles — Vespers I Antiphons ──────────────────────────────────

(bcp-roman-antiphonary-register
 'hoc-est-praeceptum-meum
 '(:latin "Hoc est præcéptum meum, * ut diligátis ínvicem, sicut diléxi vos."
   :source vulgate
   :ref "Joh 15:12"
   :translations
   ((do . "This is my commandment * that you love one another, as I have loved you."))))

(bcp-roman-antiphonary-register
 'majorem-caritatem
 '(:latin "Majórem caritátem * nemo habet, ut ánimam suam ponat quis pro amícis suis."
   :source vulgate
   :ref "Joh 15:13"
   :translations
   ((do . "Greater love than this no man hath, * that a man lay down his life for his friends."))))

(bcp-roman-antiphonary-register
 'vos-amici-mei-estis
 '(:latin "Vos amíci mei estis, * si fecéritis quæ præcípio vobis, dicit Dóminus."
   :source vulgate
   :ref "Joh 15:14"
   :translations
   ((do . "You are my friends * if you do the things that I command you, said the Lord."))))

(bcp-roman-antiphonary-register
 'beati-pacifici
 '(:latin "Beáti pacífici, * beáti mundo corde: quóniam ipsi Deum vidébunt."
   :source vulgate
   :ref "Matt 5:9"
   :translations
   ((do . "Blessed are the peacemakers * the clean of heart, they shall see God."))))

(bcp-roman-antiphonary-register
 'in-patientia-vestra
 '(:latin "In patiéntia vestra * possidébitis ánimas vestras."
   :source vulgate
   :ref "Luc 21:19"
   :translations
   ((do . "In your patience * you shall possess your souls."))))

;;; ─── C1: Apostles — Canticle Antiphons ───────────────────────────────────

(bcp-roman-antiphonary-register
 'tradent-enim-vos
 '(:latin "Tradent enim vos * in concíliis, et in synagógis suis flagellábunt vos, et ante reges et prǽsides ducémini propter me in testimónium illis, et Géntibus."
   :source vulgate
   :ref "Matt 10:17-18"
   :translations
   ((do . "For they shall deliver you * up to councils: and in the synagogues you shall be beaten: and you shall stand before governors and kings for my sake, for a testimony unto them."))))

(bcp-roman-antiphonary-register
 'vos-qui-reliquistis
 '(:latin "Vos qui reliquístis * ómnia, et secúti estis me, céntuplum accipiétis, et vitam ætérnam possidébitis."
   :source vulgate
   :ref "Matt 19:28-29"
   :translations
   ((do . "You who left all * and follow me, you will receive hundredfolds, and you will have eternal life."))))

(bcp-roman-antiphonary-register
 'estote-fortes
 '(:latin "Estóte fortes * in bello, et pugnáte cum antíquo serpénte: et accipiétis regnum ætérnum, allelúja."
   :source paraphrase
   :ref "Apoc 2-3"
   :translations
   ((do . "Be valiant * in battle, fight the ancient serpent and accept the eternal kingdom. Alleluia."))))

;;; ─── C1: Apostles — Vespers II Antiphons ─────────────────────────────────

(bcp-roman-antiphonary-register
 'juravit-dominus
 '(:latin "Jurávit Dóminus, * et non pœnitébit eum: Tu es sacérdos in ætérnum."
   :source gallican
   :ref "Ps 109"
   :translations
   ((do . "The Lord hath sworn * and will not repent: thou art a Priest for ever."))))

(bcp-roman-antiphonary-register
 'collocet-eum
 '(:latin "Cóllocet eum * Dóminus cum princípibus pópuli sui."
   :source gallican
   :ref "Ps 112:8"
   :translations
   ((do . "That the Lord may set him * with the princes of his people."))))

(bcp-roman-antiphonary-register
 'dirupisti-domine
 '(:latin "Dirupísti, Dómine, * víncula mea: tibi sacrificábo hóstiam laudis."
   :source gallican
   :ref "Ps 115:7"
   :translations
   ((do . "O Lord, thou hast loosed my bonds; * I will offer thee the sacrifice of thanksgiving."))))

(bcp-roman-antiphonary-register
 'euntes-ibant
 '(:latin "Eúntes ibant * et flebant, mitténtes sémina sua."
   :source gallican
   :ref "Ps 125:6"
   :translations
   ((do . "They went forth weeping * sowing their seed."))))

(bcp-roman-antiphonary-register
 'confortatus-est
 '(:latin "Confortátus est * principátus eórum, et honoráti sunt amíci tui, Deus."
   :source gallican
   :ref "Ps 138:3"
   :translations
   ((do . "O God, thy friends are honourable; * their power is waxen right strong."))))

;;; ─── C2: One Martyr — Vespers Antiphons ──────────────────────────────────

(bcp-roman-antiphonary-register
 'qui-me-confessus-fuerit
 '(:latin "Qui me conféssus fúerit * coram homínibus, confitébor et ego eum coram Patre meo."
   :source vulgate
   :ref "Matt 10:32"
   :translations
   ((do . "Whosoever shall confess Me * before men, him will I confess also before My Father."))))

(bcp-roman-antiphonary-register
 'qui-sequitur-me
 '(:latin "Qui séquitur me, * non ámbulat in ténebris, sed habébit lumen vitæ, dicit Dóminus."
   :source vulgate
   :ref "Joh 8:12"
   :translations
   ((do . "He that followeth Me * walketh not in darkness, but shall have the light of life, saith the Lord."))))

(bcp-roman-antiphonary-register
 'qui-mihi-ministrat
 '(:latin "Qui mihi minístrat, * me sequátur: et ubi ego sum, illic sit et miníster meus."
   :source vulgate
   :ref "Joh 12:26"
   :translations
   ((do . "If any man serve Me, * let him follow Me and where I am, there shall also My servant be."))))

(bcp-roman-antiphonary-register
 'si-quis-mihi-ministraverit
 '(:latin "Si quis mihi ministráverit, * honorificábit eum Pater meus, qui est in cælis, dicit Dóminus."
   :source vulgate
   :ref "Joh 12:26"
   :translations
   ((do . "If any man serve Me, * him will My Father, who is in heaven, honour."))))

(bcp-roman-antiphonary-register
 'volo-pater
 '(:latin "Volo Pater, * ut ubi ego sum, illic sit et miníster meus."
   :source vulgate
   :ref "Joh 17:24"
   :translations
   ((do . "Father, I will * that where I am, there shall also My servant be."))))

;;; ─── C2: One Martyr — Canticle Antiphons ─────────────────────────────────

(bcp-roman-antiphonary-register
 'iste-sanctus
 '(:latin "Iste Sanctus * pro lege Dei sui certávit usque ad mortem, et a verbis impiórum non tímuit: fundátus enim erat supra firmam petram."
   :source paraphrase
   :ref "Heb 11"
   :translations
   ((do . "This man is holy * for he hath striven for the law of his God even unto death, and hath not feared for the words of the ungodly; For he had his foundation upon a strong rock."))))

(bcp-roman-antiphonary-register
 'qui-odit-animam-suam
 '(:latin "Qui odit * ánimam suam in hoc mundo, in vitam ætérnam custódit eam."
   :source vulgate
   :ref "Joh 12:25"
   :translations
   ((do . "He that hateth his life * in this world, shall keep it unto life eternal."))))

(bcp-roman-antiphonary-register
 'qui-vult-venire-post-me
 '(:latin "Qui vult veníre post me, * ábneget semetípsum, et tollat crucem suam, et sequátur me."
   :source vulgate
   :ref "Matt 16:24"
   :translations
   ((do . "If any man will come after me, * let him deny himself and take up his cross daily and follow me."))))

;;; ─── C3: Many Martyrs — Vespers I Antiphons ──────────────────────────────

(bcp-roman-antiphonary-register
 'omnes-sancti-quanta
 '(:latin "Omnes Sancti, * quanta passi sunt torménta, ut secúri pervenírent ad palmam martýrii."
   :source composition
   :translations
   ((do . "O how many torments have all the Saints suffered, * that they might attain safely unto the palm of martyrdom."))))

(bcp-roman-antiphonary-register
 'cum-palma-ad-regna
 '(:latin "Cum palma * ad regna pervenérunt Sancti, corónas decóris meruérunt de manu Dei."
   :source composition
   :translations
   ((do . "The Saints have attained unto the kingdom, * with palms in their hands; they have earned crowns of Majesty from the Lord's hand."))))

(bcp-roman-antiphonary-register
 'corpora-sanctorum
 '(:latin "Córpora Sanctórum * in pace sepúlta sunt: et vivent nómina eórum in ætérnum."
   :source paraphrase
   :ref "Sir 44:14"
   :translations
   ((do . "The bodies of the Saints are buried in peace, * and their name liveth for evermore."))))

(bcp-roman-antiphonary-register
 'martyres-domini
 '(:latin "Mártyres Dómini * Dóminum benedícite in ætérnum."
   :source composition
   :translations
   ((do . "O all ye Martyrs of the Lord, bless ye the Lord * for ever."))))

(bcp-roman-antiphonary-register
 'martyrum-chorus
 '(:latin "Mártyrum chorus * laudáte Dóminum de cælis, allelúja."
   :source composition
   :translations
   ((do . "O ye Martyrs, * praise ye the Lord from the heavens, praise Him with the dance, alleluia."))))

;;; ─── C3: Many Martyrs — Canticle Antiphons ───────────────────────────────

(bcp-roman-antiphonary-register
 'istorum-est-enim
 '(:latin "Istórum est enim * regnum cælórum qui contempsérunt vitam mundi, et pervenérunt ad prǽmia regni, et lavérunt stolas suas in sánguine Agni."
   :source vulgate
   :ref "Matt 5:10"
   :translations
   ((do . "For theirs is the Kingdom of heaven * who love not their lives in this world, and have attained unto the reward of the Kingdom, and have washed their robes in the blood of the Lamb."))))

(bcp-roman-antiphonary-register
 'vestri-capilli-capitis
 '(:latin "Vestri capílli cápitis * omnes numeráti sunt: nolíte timére: multis passéribus melióres estis vos."
   :source vulgate
   :ref "Luc 21:18"
   :translations
   ((do . "Even the very hairs of your head are all numbered: * fear not therefore; ye are of more value than many sparrows."))))

(bcp-roman-antiphonary-register
 'gaudent-in-caelis
 '(:latin "Gaudent in cælis * ánimæ Sanctórum, qui Christi vestígia sunt secúti: et quia pro ejus amóre sánguinem suum fudérunt, ídeo cum Christo exsúltant sine fine."
   :source composition
   :translations
   ((do . "In heaven do rejoice the souls of the Saints * who have followed the steps of Christ; and because they shed their blood for the love of Christ, therefore shall they be made glad for ever with Christ."))))

;;; ─── C3: Many Martyrs — Vespers II Antiphons ─────────────────────────────

(bcp-roman-antiphonary-register
 'isti-sunt-sancti
 '(:latin "Isti sunt Sancti, * qui pro testaménto Dei sua córpora tradidérunt, et in sánguine Agni lavérunt stolas suas."
   :source composition
   :translations
   ((do . "These men are holy, * for they have given up their bodies unto death for the sake of the covenant of their God, and have washed their robes in the Blood of the Lamb."))))

(bcp-roman-antiphonary-register
 'sancti-per-fidem
 '(:latin "Sancti per fidem * vicérunt regna, operáti sunt justítiam, adépti sunt repromissiónes."
   :source paraphrase
   :ref "Heb 11"
   :translations
   ((do . "The Saints through faith subdued kingdoms, * wrought righteousness, obtained promises."))))

(bcp-roman-antiphonary-register
 'sanctorum-velut-aquilae
 '(:latin "Sanctórum velut áquilæ * juvéntus renovábitur: florébunt sicut lílium in civitáte Dómini."
   :source paraphrase
   :ref "Isa 40:31"
   :translations
   ((do . "The youth of the Saints shall be renewed * like the eagle's they shall grow as the lily in the city of the Lord."))))

(bcp-roman-antiphonary-register
 'absterget-deus
 '(:latin "Abstérget Deus * omnem lácrimam ab óculis Sanctórum: et jam non erit ámplius neque luctus, neque clamor, sed nec ullus dolor: quóniam prióra transiérunt."
   :source vulgate
   :ref "Apoc 21:4"
   :translations
   ((do . "God shall wipe away all tears from the eyes of His Saints * and there shall be no more sorrow, nor crying, neither shall there be any more pain; for the former things are passed away."))))

(bcp-roman-antiphonary-register
 'in-caelestibus-regnis
 '(:latin "In cæléstibus regnis * Sanctórum habitátio est, et in ætérnum réquies eórum."
   :source composition
   :translations
   ((do . "In the heavenly kingdoms, * there is the dwelling of the Saints there shall be their rest for ever and ever."))))

;;; ─── C4: Confessor Bishop — Vespers Antiphons ────────────────────────────

(bcp-roman-antiphonary-register
 'ecce-sacerdos-magnus
 '(:latin "Ecce sacérdos magnus, * qui in diébus suis plácuit Deo, et invéntus est justus."
   :source paraphrase
   :ref "Sir 50:1"
   :translations
   ((do . "Behold an high priest, * who in his days pleased God, and was found righteous."))))

(bcp-roman-antiphonary-register
 'non-est-inventus
 '(:latin "Non est invéntus * símilis illi, qui conserváret legem Excélsi."
   :source paraphrase
   :ref "Sir 44:20"
   :translations
   ((do . "None was found like unto him, * to keep the Law of the Most High."))))

(bcp-roman-antiphonary-register
 'ideo-jurejurando
 '(:latin "Ideo jurejurándo * fecit illum Dóminus créscere in plebem suam."
   :source paraphrase
   :ref "Sir 44:22"
   :translations
   ((do . "Therefore the Lord assured him * by an oath that He would multiply his seed among His people."))))

(bcp-roman-antiphonary-register
 'sacerdotes-dei
 '(:latin "Sacerdótes Dei, * benedícite Dóminum: servi Dómini, hymnum dícite Deo. Allelúja."
   :source composition
   :translations
   ((do . "O all ye Priests of God, * bless ye the Lord O all ye servants of the Lord, sing praises unto our God."))))

(bcp-roman-antiphonary-register
 'serve-bone-et-fidelis
 '(:latin "Serve bone * et fidélis, intra in gáudium Dómini tui."
   :source vulgate
   :ref "Matt 25:21"
   :translations
   ((do . "Good and faithful servant, * enter thou into the joy of thy Lord."))))

;;; ─── C4: Confessor Bishop — Canticle Antiphons ───────────────────────────

(bcp-roman-antiphonary-register
 'sacerdos-et-pontifex
 '(:latin "Sacérdos et Póntifex, * et virtútum ópifex, pastor bone in pópulo, ora pro nobis Dóminum."
   :source composition
   :translations
   ((do . "O thou Priest and Bishop, * thou worker of mighty works, thou good shepherd over God's people, pray for us unto the Lord."))))

(bcp-roman-antiphonary-register
 'euge-serve-bone
 '(:latin "Euge, serve bone * et fidélis, quia in pauca fuísti fidélis, supra multa te constítuam, dicit Dóminus."
   :source vulgate
   :ref "Matt 25:21"
   :translations
   ((do . "Well done, thou good and faithful servant * thou hast been faithful over a few things, I will make thee ruler over many things, saith the Lord."))))

(bcp-roman-antiphonary-register
 'amavit-eum-dominus
 '(:latin "Amávit eum Dóminus, * et ornávit eum: stolam glóriæ índuit eum, et ad portas paradísi coronávit eum."
   :source paraphrase
   :ref "Sir 45:9"
   :translations
   ((do . "The Lord loved him * and beautified him. He clothed him with a robe of glory, and crowned him at the gates of Paradise."))))

;;; ─── C5: Confessor Non-Bishop — Vespers Antiphons ────────────────────────

(bcp-roman-antiphonary-register
 'domine-quinque-talenta
 '(:latin "Dómine, quinque talénta * tradidísti mihi, ecce ália quinque superlucrátus sum."
   :source vulgate
   :ref "Matt 25:20"
   :translations
   ((do . "Lord, Thou deliverest unto me five talents * behold, I have gained beside them five talents more."))))

(bcp-roman-antiphonary-register
 'euge-serve-bone-in-modico
 '(:latin "Euge, serve bone * in módico fidélis, intra in gáudium Dómini tui."
   :source vulgate
   :ref "Matt 25:21"
   :translations
   ((do . "Well done, thou good servant, * thou hast been faithful in a very little, enter thou into the joy of thy Lord."))))

(bcp-roman-antiphonary-register
 'fidelis-servus
 '(:latin "Fidélis servus * et prudens, quem constítuit Dóminus super famíliam suam."
   :source vulgate
   :ref "Matt 24:45"
   :translations
   ((do . "A faithful and wise servant * whom his Lord hath made ruler over His household."))))

(bcp-roman-antiphonary-register
 'beatus-ille-servus
 '(:latin "Beátus ille servus, * quem, cum vénerit Dóminus ejus et pulsáverit jánuam, invénerit vigilántem."
   :source vulgate
   :ref "Matt 24:46"
   :translations
   ((do . "Blessed is that servant * whom his Lord, when He cometh and knocketh at the door, shall find watching."))))

;;; NOTE: C5 shares 'serve-bone-et-fidelis with C4 (same text).

;;; ─── C5: Confessor Non-Bishop — Canticle Antiphons ───────────────────────

(bcp-roman-antiphonary-register
 'similabo-eum
 '(:latin "Similábo eum * viro sapiénti, qui ædificávit domum suam supra petram."
   :source vulgate
   :ref "Matt 7:24"
   :translations
   ((do . "I will liken him unto a wise man, * which built his house upon a rock."))))

(bcp-roman-antiphonary-register
 'euge-serve-bone-in-pauca
 '(:latin "Euge, serve bone * et fidélis, quia in pauca fuísti fidélis, supra multa te constítuam, intra in gáudium Dómini tui."
   :source vulgate
   :ref "Matt 25:21"
   :translations
   ((do . "Well done, thou good and faithful servant; * thou hast been faithful over a few things, I will make thee ruler over many things; enter thou into the joy of thy Lord."))))

(bcp-roman-antiphonary-register
 'hic-vir-despiciens
 '(:latin "Hic vir despíciens mundum * et terréna, triúmphans, divítias cælo cóndidit ore, manu."
   :source composition
   :translations
   ((do . "Lo, a servant of God * who esteemed but little things earthly. And by word and work laid him up treasure in heaven."))))

;;; ─── C6: Virgin Martyr — Vespers Antiphons ───────────────────────────────

(bcp-roman-antiphonary-register
 'haec-est-virgo-sapiens
 '(:latin "Hæc est Virgo sápiens, * et una de número prudéntum."
   :source paraphrase
   :ref "Matt 25:1-4"
   :translations
   ((do . "This is one of the wise virgins, * one chosen out of the number of the careful."))))

(bcp-roman-antiphonary-register
 'haec-est-virgo-sapiens-quam
 '(:latin "Hæc est Virgo sápiens, * quam Dóminus vigilántem invénit."
   :source paraphrase
   :ref "Matt 25:1-4"
   :translations
   ((do . "This is one of the wise virgins, * whom the Lord found watching."))))

(bcp-roman-antiphonary-register
 'haec-est-quae-nescivit
 '(:latin "Hæc est quæ nescívit * torum in delícto: habébit fructum in respectióne animárum sanctárum."
   :source paraphrase
   :ref "Sap 3:13"
   :translations
   ((do . "This, is one which hath not known the sinful bed, * she shall have fruit in the visitation of holy souls."))))

(bcp-roman-antiphonary-register
 'veni-electa-mea
 '(:latin "Veni, elécta mea, * et ponam in te thronum meum, allelúja."
   :source vulgate
   :ref "Cant 2:10-13"
   :translations
   ((do . "Come, O my chosen one, * and I will establish My throne in thee."))))

(bcp-roman-antiphonary-register
 'ista-est-speciosa
 '(:latin "Ista est speciósa * inter fílias Jerúsalem."
   :source composition
   :translations
   ((do . "She is beautiful * among the daughters of Jerusalem."))))

;;; ─── C6: Virgin Martyr — Canticle Antiphons ──────────────────────────────
;;; NOTE: C6 [Ant 1] = [Ant 3] = 'veni-sponsa-christi (already registered).

(bcp-roman-antiphonary-register
 'simile-est-regnum
 '(:latin "Símile est regnum cælórum * hómini negotiatóri quærénti bonas margarítas: invénta una pretiósa, dedit ómnia sua, et comparávit eam."
   :source vulgate
   :ref "Matt 13:45"
   :translations
   ((do . "The kingdom of heaven is like unto a merchantman * seeking goodly pearls, who, when he had found one pearl of great price, went and sold all that he had, and bought it."))))

;;; ─── C7: Holy Women — Vespers Antiphons ──────────────────────────────────
;;; NOTE: C7 shares three Vespers antiphons with LOBVM BVM:
;;;   'dum-esset-rex, 'in-odorem-unguentorum, 'jam-hiems-transiit
;;;   (already registered). C7 also shares 'veni-electa-mea and
;;;   'ista-est-speciosa with C6 (registered above).

;;; ─── C7: Holy Women — Canticle Antiphons ─────────────────────────────────
;;; NOTE: C7 [Ant 1] = C6 [Ant 2] = 'simile-est-regnum (registered above).

(bcp-roman-antiphonary-register
 'date-ei
 '(:latin "Date ei * de fructu mánuum suárum, et laudent eam in portis ópera ejus."
   :source paraphrase
   :ref "Prov 31:31"
   :translations
   ((do . "Give her of the fruit of her hands, * and let her own works praise her in the gates."))))

(bcp-roman-antiphonary-register
 'manum-suam
 '(:latin "Manum suam * apéruit ínopi, et palmas suas exténdit ad páuperem, et panem otiósa non comédit."
   :source paraphrase
   :ref "Prov 31:20"
   :translations
   ((do . "She spreadeth out her hand to the poor, * yea, she reacheth forth her hands to the needy, and eateth not the bread of idleness."))))

;;; ═══════════════════════════════════════════════════════════════════════════
;;; Proprium Sanctorum — Matins antiphons for feasts with :commune nil
;;; ═══════════════════════════════════════════════════════════════════════════

;;; ─── May 3: Inventione Sanctæ Crucis — Invitatory ───────────────────────

(bcp-roman-antiphonary-register
 'christum-regem-crucifixum
 '(:latin "Christum Regem crucifíxum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "Christ the King crucified, * O come, let us worship Him."))))

;;; ─── May 3: Inventione Sanctæ Crucis — Nocturn antiphons ───────────────

(bcp-roman-antiphonary-register
 'inventae-crucis
 '(:latin "Invéntæ Crucis festa recólimus, cujus præcónium univérsum per orbem micánti lúmine fulget, allelúja."
   :source composition
   :translations
   ((do . "We celebrate the feast of the Finding of the Cross, whose renown shineth with gleaming light throughout the whole world, alleluia."))))

(bcp-roman-antiphonary-register
 'felix-ille-triumphus
 '(:latin "Felix ille triúmphus fit salus ægris, vitæ lignum, mortis remédium, allelúja."
   :source composition
   :translations
   ((do . "That blessed triumph becometh health to the sick, the tree of life, the remedy of death, alleluia."))))

(bcp-roman-antiphonary-register
 'adoramus-te-christe-et-benedicimus
 '(:latin "Adorámus te, Christe, et benedícimus tibi, quia per Crucem tuam redemísti mundum, allelúja."
   :source composition
   :translations
   ((do . "We adore thee, O Christ, and we bless thee, because by thy Cross thou hast redeemed the world, alleluia."))))

;;; ─── May 8: Apparitione S. Michaëlis — Invitatory ──────────────────────

(bcp-roman-antiphonary-register
 'regem-archangelorum-dominum
 '(:latin "Regem Archangelórum Dóminum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "The Lord, King of the Archangels, * O come, let us worship Him."))))

;;; ─── May 8: Apparitione S. Michaëlis — Nocturn antiphons ───────────────

(bcp-roman-antiphonary-register
 'concussum-est-mare
 '(:latin "Concússum est mare, et contrémuit terra, ubi Archángelus Míchaël descendébat de cælo, allelúja."
   :source composition
   :translations
   ((do . "The sea was shaken, and the earth trembled, when the Archangel Michael came down from heaven, alleluia."))))

(bcp-roman-antiphonary-register
 'michael-archangele-veni
 '(:latin "Míchaël Archángele, veni in adjutórium pópulo Dei, allelúja."
   :source composition
   :translations
   ((do . "Michael the Archangel, come to the help of the people of God, alleluia."))))

(bcp-roman-antiphonary-register
 'angelus-archangelus-michael
 '(:latin "Angelus Archángelus Míchaël, Dei núntius pro animábus justis, allelúja, allelúja."
   :source composition
   :translations
   ((do . "The Angel, the Archangel Michael, God's messenger for the souls of the just, alleluia, alleluia."))))

;;; ─── Jun 24: Nativitate S. Joannis Baptistæ — Invitatory ──────────────

(bcp-roman-antiphonary-register
 'regem-praecursoris-dominum
 '(:latin "Regem Præcursóris Dóminum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "The Lord, King of the Forerunner, * O come, let us worship Him."))))

;;; ─── Jun 24: Nativitate S. Joannis Baptistæ — Nocturn I antiphons ─────

(bcp-roman-antiphonary-register
 'priusquam-te-formarem
 '(:latin "Priúsquam te formárem in útero, novi te; et ántequam progrederéris, sanctificávi te."
   :source vulgate
   :ref "Jer 1:5"
   :translations
   ((do . "Before I formed thee in the womb, I knew thee; and before thou camest forth, I sanctified thee."))))

(bcp-roman-antiphonary-register
 'ad-omnia-quae-mittam-te
 '(:latin "Ad ómnia quæ mittam te, dicit Dóminus, ibis: ne tímeas, et quæ mandávero tibi, loquéris ad eos."
   :source vulgate
   :ref "Jer 1:7-8"
   :translations
   ((do . "To all that I shall send thee, saith the Lord, thou shalt go; be not afraid, and whatsoever I command thee, thou shalt speak unto them."))))

(bcp-roman-antiphonary-register
 'ne-timeas-a-facie
 '(:latin "Ne tímeas a fácie eórum, quia ego tecum sum, dicit Dóminus."
   :source vulgate
   :ref "Jer 1:8"
   :translations
   ((do . "Be not afraid of their faces, for I am with thee, saith the Lord."))))

;;; ─── Jun 24: Nativitate S. Joannis Baptistæ — Nocturn II antiphons ────

(bcp-roman-antiphonary-register
 'misit-dominus-manum-suam
 '(:latin "Misit Dóminus manum suam, et tétigit os meum, et prophétam in géntibus dedit me Dóminus."
   :source vulgate
   :ref "Jer 1:9-10"
   :translations
   ((do . "The Lord put forth his hand, and touched my mouth, and the Lord gave me to be a prophet unto the nations."))))

(bcp-roman-antiphonary-register
 'ecce-dedi-verba-mea
 '(:latin "Ecce dedi verba mea in ore tuo: ecce constítui te super gentes et regna."
   :source vulgate
   :ref "Jer 1:9-10"
   :translations
   ((do . "Behold, I have put my words in thy mouth: behold, I have set thee over the nations and over the kingdoms."))))

(bcp-roman-antiphonary-register
 'dominus-ab-utero-vocavit-me
 '(:latin "Dóminus ab útero vocávit me, de ventre matris meæ recordátus est nóminis mei."
   :source vulgate
   :ref "Isa 49:1"
   :translations
   ((do . "The Lord hath called me from the womb; from the bowels of my mother hath he made mention of my name."))))

;;; ─── Jun 24: Nativitate S. Joannis Baptistæ — Nocturn III antiphons ───

(bcp-roman-antiphonary-register
 'posuit-os-meum
 '(:latin "Pósuit os meum Dóminus quasi gládium acútum: sub umbra manus suæ protéxit me."
   :source vulgate
   :ref "Isa 49:2"
   :translations
   ((do . "The Lord hath made my mouth like a sharp sword; in the shadow of his hand hath he hid me."))))

(bcp-roman-antiphonary-register
 'formans-me-ex-utero
 '(:latin "Formans me ex útero servum sibi Dóminus, dicit: Dedi te in lucem géntium, ut sis salus mea usque ad extrémum terræ."
   :source vulgate
   :ref "Isa 49:5-6"
   :translations
   ((do . "The Lord that formed me from the womb to be his servant saith: I have given thee for a light of the Gentiles, that thou mayest be my salvation unto the end of the earth."))))

(bcp-roman-antiphonary-register
 'reges-videbunt
 '(:latin "Reges vidébunt, et consúrgent príncipes et adorábunt Dóminum Deum tuum, qui elégit te."
   :source vulgate
   :ref "Isa 49:7"
   :translations
   ((do . "Kings shall see and arise, princes also shall worship the Lord thy God, who hath chosen thee."))))

;;; ─── Jul 1: Pretiosissimi Sanguinis D.N.J.C. — Invitatory ─────────────

(bcp-roman-antiphonary-register
 'christum-dei-filium-qui-suo-nos
 '(:latin "Christum Dei Fílium, qui suo nos redémit sánguine, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "Christ, the Son of God, who redeemed us with his Blood, * O come, let us worship Him."))))

;;; ─── Jul 1: Pretiosissimi Sanguinis — Nocturn antiphons ────────────────

(bcp-roman-antiphonary-register
 'postquam-consummati-sunt
 '(:latin "Postquam consummáti sunt dies octo, ut circumciderétur Puer, vocátum est nomen ejus Jesus."
   :source vulgate
   :ref "Luc 2:21"
   :translations
   ((do . "When eight days were accomplished for the circumcising of the Child, his name was called Jesus."))))

(bcp-roman-antiphonary-register
 'factus-in-agonia
 '(:latin "Factus in agonía prolíxius orábat, et factus est sudor ejus sicut guttæ sánguinis decurréntis in terram."
   :source vulgate
   :ref "Luc 22:43-44"
   :translations
   ((do . "Being in an agony he prayed more earnestly, and his sweat was as it were great drops of blood falling down to the ground."))))

(bcp-roman-antiphonary-register
 'judas-qui-eum-tradidit
 '(:latin "Judas, qui eum trádidit, pœniténtia ductus rétulit trigínta argénteos, dicens: Peccávi tradens sánguinem justum."
   :source vulgate
   :ref "Matt 27:3-4"
   :translations
   ((do . "Judas, which had betrayed him, repented, and brought again the thirty pieces of silver, saying: I have sinned in that I have betrayed the innocent blood."))))

(bcp-roman-antiphonary-register
 'pilatus-volens-populo
 '(:latin "Pilátus, volens pópulo satisfácere, trádidit illis Jesum flagéllis cæsum."
   :source vulgate
   :ref "Marc 15:15"
   :translations
   ((do . "Pilate, willing to content the people, delivered Jesus, when he had scourged him."))))

(bcp-roman-antiphonary-register
 'videns-autem-quia-nihil
 '(:latin "Videns autem quia nihil profíceret, accépta aqua, lavit manus coram pópulo dicens: Innocens ego sum a sánguine Justi hujus."
   :source vulgate
   :ref "Matt 27:24"
   :translations
   ((do . "When he saw that he could prevail nothing, he took water, and washed his hands before the multitude, saying: I am innocent of the blood of this just person."))))

(bcp-roman-antiphonary-register
 'et-respondens-universus-populus
 '(:latin "Et respóndens univérsus pópulus dixit: Sanguis ejus super nos et super fílios nostros."
   :source vulgate
   :ref "Matt 27:25"
   :translations
   ((do . "Then answered all the people, and said: His blood be on us and on our children."))))

(bcp-roman-antiphonary-register
 'exivit-ergo-jesus
 '(:latin "Exívit ergo Jesus portans corónam spíneam et purpúreum vestiméntum. Et dixit eis: Ecce homo."
   :source vulgate
   :ref "Joann 19:5"
   :translations
   ((do . "Then came Jesus forth, wearing the crown of thorns and the purple robe. And he saith unto them: Behold the man."))))

(bcp-roman-antiphonary-register
 'et-bajulans-sibi-crucem
 '(:latin "Et bájulans sibi crucem, exívit in eum, qui dícitur Calváriæ, locum, ubi crucifixérunt eum."
   :source vulgate
   :ref "Joann 19:17-18"
   :translations
   ((do . "And he bearing his cross went forth unto a place called Calvary, where they crucified him."))))

(bcp-roman-antiphonary-register
 'ut-viderunt-eum-jam-mortuum
 '(:latin "Ut vidérunt eum jam mórtuum, non fregérunt ejus crura, sed unus mílitum láncea latus ejus apéruit, et contínuo exívit sanguis et aqua."
   :source vulgate
   :ref "Joann 19:33-34"
   :translations
   ((do . "When they saw that he was dead already, they brake not his legs, but one of the soldiers with a spear opened his side, and forthwith came there out blood and water."))))

;;; ─── Aug 6: Transfiguratione D.N.J.C. — Invitatory ────────────────────

(bcp-roman-antiphonary-register
 'summum-regem-gloriae
 '(:latin "Summum Regem glóriæ, * Christum adorémus."
   :source composition
   :translations
   ((do . "The most high King of glory, * Let us adore Christ."))))

;;; ─── Aug 6: Transfiguratione D.N.J.C. — Nocturn antiphons ─────────────

(bcp-roman-antiphonary-register
 'paulo-minus-ab-angelis
 '(:latin "Paulo minus ab Angelis minorátus, glória et honóre coronátus est, et constitútus super ópera mánuum Dei."
   :source gallican
   :ref "Ps 8:6-7"
   :translations
   ((do . "Thou madest him a little lower than the Angels; thou crownedst him with glory and honour, and didst set him over the works of thy hands."))))

(bcp-roman-antiphonary-register
 'revelavit-dominus-condensa
 '(:latin "Revelávit Dóminus condénsa, et in templo ejus omnes dicent glóriam."
   :source gallican
   :ref "Ps 28:9"
   :translations
   ((do . "The Lord uncovereth the thick places, and in his temple doth every one speak of his glory."))))

(bcp-roman-antiphonary-register
 'speciosus-forma
 '(:latin "Speciósus forma præ fíliis hóminum, diffúsa est grátia in lábiis tuis."
   :source gallican
   :ref "Ps 44:3"
   :translations
   ((do . "Thou art fairer than the children of men; grace is poured into thy lips."))))

(bcp-roman-antiphonary-register
 'illuminans-tu-mirabiliter
 '(:latin "Illúminans tu mirabíliter a móntibus ætérnis: turbáti sunt omnes insipiéntes corde."
   :source gallican
   :ref "Ps 75:5-6"
   :translations
   ((do . "Thou dost wonderfully shine forth from the everlasting mountains; all the foolish of heart were troubled."))))

(bcp-roman-antiphonary-register
 'melior-est-dies-una
 '(:latin "Mélior est dies una in átriis tuis, super míllia."
   :source gallican
   :ref "Ps 83:11"
   :translations
   ((do . "One day in thy courts is better than a thousand."))))

(bcp-roman-antiphonary-register
 'gloriosa-dicta-sunt
 '(:latin "Gloriósa dicta sunt de te, cívitas Dei."
   :source gallican
   :ref "Ps 86:3"
   :translations
   ((do . "Glorious things are spoken of thee, O city of God."))))

(bcp-roman-antiphonary-register
 'thabor-et-hermon
 '(:latin "Thabor et Hermon in nómine tuo exsultábunt: tuum brácchium cum poténtia."
   :source gallican
   :ref "Ps 88:13-14"
   :translations
   ((do . "Tabor and Hermon shall rejoice in thy name; thy arm is with power."))))

(bcp-roman-antiphonary-register
 'lux-orta-est-justo-transfig
 '(:latin "Lux orta est justo, et rectis corde lætítia."
   :source gallican
   :ref "Ps 96:11"
   :translations
   ((do . "Light is risen to the just, and gladness to the right of heart."))))

(bcp-roman-antiphonary-register
 'confessionem-et-decorem
 '(:latin "Confessiónem et decórem índuit, amíctus lúmine sicut vestiménto."
   :source gallican
   :ref "Ps 103:1-2"
   :translations
   ((do . "He putteth on praise and beauty, and is clothed with light as with a garment."))))

;;; ─── Sep 29: Dedicatione S. Michaëlis — Nocturn antiphons ─────────────
;;; Invitatory, hymn, and responsories inherited from May 8.
;;; Noc1 Ps1, Noc2 Ps1, Noc3 Ps1 reuse May 8 antiphons (already registered).

(bcp-roman-antiphonary-register
 'laudemus-dominum
 '(:latin "Laudémus Dóminum, quem laudant Ángeli, quem Chérubim et Séraphim, Sanctus, Sanctus, Sanctus proclámant."
   :source composition
   :translations
   ((do . "Let us praise the Lord, whom the Angels praise, whom the Cherubim and Seraphim proclaim: Holy, Holy, Holy."))))

(bcp-roman-antiphonary-register
 'ascendit-fumus-aromatum
 '(:latin "Ascéndit fumus arómatum in conspéctu Dómini de manu Ángeli."
   :source vulgate
   :ref "Apo 8:4"
   :translations
   ((do . "The smoke of the incense ascended up before the Lord out of the Angel's hand."))))

(bcp-roman-antiphonary-register
 'michael-praepositus-paradisi
 '(:latin "Míchaël præpósitus paradísi, quem honoríficant Angelórum cives."
   :source composition
   :translations
   ((do . "Michael, chief of paradise, whom the citizens of the Angels honour."))))

(bcp-roman-antiphonary-register
 'gloriosus-apparuisti
 '(:latin "Gloriósus apparuísti in conspéctu Dómini: proptérea decórem índuit te Dóminus."
   :source gallican
   :ref "Ps 20:6"
   :translations
   ((do . "Glorious hast thou appeared in the sight of the Lord; therefore hath the Lord clothed thee with beauty."))))

(bcp-roman-antiphonary-register
 'data-sunt-ei-incensa
 '(:latin "Data sunt ei incénsa multa, ut adoléret ea ante altáre áureum, quod est ante óculos Dómini."
   :source vulgate
   :ref "Apo 8:3"
   :translations
   ((do . "There was given unto him much incense, that he should offer it upon the golden altar, which is before the eyes of the Lord."))))

(bcp-roman-antiphonary-register
 'multa-magnalia
 '(:latin "Multa magnália de Michaéle Archángelo, qui, fortis in prǽlio, fecit victóriam."
   :source composition
   :translations
   ((do . "Great are the wonders of Michael the Archangel, who, mighty in battle, won the victory."))))

;;; ─── Sep 14: Exaltatione Sanctæ Crucis — Invitatory ───────────────────

(bcp-roman-antiphonary-register
 'christum-regem-in-cruce-exaltatum
 '(:latin "Christum Regem pro nobis in Cruce exaltátum, * Veníte, adorémus."
   :source composition
   :translations
   ((do . "Christ the King for us exalted upon the Cross, * Come, let us adore him."))))

;;; ─── Sep 14: Exaltatione Sanctæ Crucis — Nocturn antiphons ───────────

(bcp-roman-antiphonary-register
 'nobile-lignum-exaltatur
 '(:latin "Nóbile lignum exaltátur, Christi fides rútilat, dum Crux ab ómnibus venerátur."
   :source composition
   :translations
   ((do . "The noble wood is exalted, the faith of Christ shineth bright, while the Cross is venerated by all."))))

(bcp-roman-antiphonary-register
 'sancta-crux-extollitur
 '(:latin "Sancta Crux extóllitur a cunctis régibus, virga régia erígitur, in qua Salvátor triumphávit."
   :source composition
   :translations
   ((do . "The Holy Cross is lifted up by all kings, the royal rod is raised, on which the Saviour triumphed."))))

(bcp-roman-antiphonary-register
 'o-crux-venerabilis
 '(:latin "O Crux venerábilis, quæ salútem attulísti míseris, quibus te éfferam præcóniis, quóniam vitam nobis cǽlitem præparásti."
   :source composition
   :translations
   ((do . "O venerable Cross, which didst bring salvation to the wretched, with what praises shall I extol thee, for thou hast prepared for us the life of heaven."))))

(bcp-roman-antiphonary-register
 'o-crucis-victoria
 '(:latin "O Crucis victória et admirábile signum, in cælésti cúria fac nos captáre triúmphum."
   :source composition
   :translations
   ((do . "O victory of the Cross and wondrous sign, in the heavenly court make us to attain triumph."))))

(bcp-roman-antiphonary-register
 'funestae-mortis
 '(:latin "Funéstæ mortis damnátur supplícium, dum Christus, in Cruce, nostra destrúxit víncula críminum."
   :source composition
   :translations
   ((do . "The punishment of grievous death is condemned, while Christ on the Cross destroyed the chains of our sins."))))

(bcp-roman-antiphonary-register
 'rex-exaltatur
 '(:latin "Rex exaltátur in ǽthera, cum nóbile trophǽum Crucis ab univérsis christícolis adorátur per sǽcula."
   :source composition
   :translations
   ((do . "The King is exalted to the heavens, when the noble trophy of the Cross is adored by all Christians through the ages."))))

(bcp-roman-antiphonary-register
 'adoramus-te-christe-exalt
 '(:latin "Adorámus te, Christe, et benedícimus tibi, quia per Crucem tuam redemísti mundum."
   :source composition
   :translations
   ((do . "We adore thee, O Christ, and we bless thee, because by thy Cross thou hast redeemed the world."))))

(bcp-roman-antiphonary-register
 'per-lignum-servi
 '(:latin "Per lignum servi facti sumus, et per sanctam Crucem liberáti sumus: fructus árboris sedúxit nos, Fílius Dei redémit nos, allelúja."
   :source composition
   :translations
   ((do . "By wood we were made servants, and by the Holy Cross we are set free: the fruit of the tree seduced us, the Son of God redeemed us, alleluia."))))

(bcp-roman-antiphonary-register
 'salvator-mundi-salva-nos
 '(:latin "Salvátor mundi, salva nos: qui per Crucem et sánguinem tuum redemísti nos, auxiliáre nobis, te deprecámur, Deus noster."
   :source composition
   :translations
   ((do . "Saviour of the world, save us: who by thy Cross and Blood hast redeemed us, help us, we beseech thee, our God."))))

;;; ─── Oct 24: S. Raphaëlis Archangeli — Nocturn antiphons ─────────────
;;; Invitatory inherited from May 8 (regem-archangelorum-dominum).

(bcp-roman-antiphonary-register
 'egressus-tobias
 '(:latin "Egréssus Tobías invénit júvenem præcínctum, et quasi parátum ad ambulándum, et, ignórans quod Angelus esset, salutávit eum."
   :source vulgate
   :ref "Tob 5:5-6"
   :translations
   ((do . "Tobias going forth found a young man girded, and as it were ready to walk, and not knowing him to be an Angel, saluted him."))))

(bcp-roman-antiphonary-register
 'angelus-raphael-seipsum
 '(:latin "Angelus Ráphaël seípsum occúltans, ait: Ego sum Azarías, magni Ananíæ fílius."
   :source vulgate
   :ref "Tob 5:18"
   :translations
   ((do . "The Angel Raphael, concealing himself, said: I am Azarias, the son of the great Ananias."))))

(bcp-roman-antiphonary-register
 'sanum-ducam
 '(:latin "Sanum ducam fílium tuum in regiónem Medórum, et sanum tibi redúcam, allelúja."
   :source vulgate
   :ref "Tob 5:21"
   :translations
   ((do . "I will lead thy son safe into the country of the Medes, and bring him back safe to thee, alleluia."))))

(bcp-roman-antiphonary-register
 'dixit-autem-angelus-apprehende
 '(:latin "Dixit autem Angelus: Apprehénde bránchiam piscis, et trahe eum extra aquas."
   :source vulgate
   :ref "Tob 6:4"
   :translations
   ((do . "And the Angel said: Take hold of the gill of the fish, and draw him out of the water."))))

(bcp-roman-antiphonary-register
 'obsecro-te-azaria
 '(:latin "Obsecro te, Azaría frater, ut dicas mihi, quod remédium habébunt ista, quæ de pisce serváre jussísti."
   :source vulgate
   :ref "Tob 6:7"
   :translations
   ((do . "I beseech thee, brother Azarias, tell me, what remedy shall these things have, which thou didst bid me keep of the fish."))))

(bcp-roman-antiphonary-register
 'lumina-fel-sanat
 '(:latin "Lúmina fel sanat, sed virtus cordis et jécoris diáboli expéllit potestátem."
   :source vulgate
   :ref "Tob 6:8-9"
   :translations
   ((do . "The gall cureth the eyes, but the virtue of the heart and liver driveth away the power of the devil."))))

(bcp-roman-antiphonary-register
 'est-hic-sara
 '(:latin "Est hic Sara Raguélis fília; quæ tibi conjúgio dábitur, et omnis substántia ejus."
   :source vulgate
   :ref "Tob 6:12"
   :translations
   ((do . "Here is Sara, the daughter of Raguel, who shall be given to thee in marriage, and all her substance."))))

(bcp-roman-antiphonary-register
 'septem-viros-habuit
 '(:latin "Septem viros hábuit, quos dæmónium oppréssit; tímeo ne mihi símile contíngat."
   :source vulgate
   :ref "Tob 6:14-15"
   :translations
   ((do . "She hath had seven husbands, whom a devil oppressed; I fear lest the like befall me."))))

(bcp-roman-antiphonary-register
 'per-tres-dies
 '(:latin "Per tres dies oratióni cum uxóre tua vacábis, ut in sémine Abrahæ benedictiónem in fíliis consequáris."
   :source vulgate
   :ref "Tob 6:22"
   :translations
   ((do . "For three days thou shalt give thyself to prayer with thy wife, that thou mayest obtain the blessing of children in the seed of Abraham."))))

;;; ─── Jan 25: Conversione S. Pauli — Invitatory ───────────────────────

(bcp-roman-antiphonary-register
 'laudemus-deum-nostrum-in-conversione
 '(:latin "Laudémus Deum nostrum, * In conversióne Doctóris géntium."
   :source composition
   :translations
   ((do . "Let us praise our God, * In the conversion of the Doctor of the Gentiles."))))

;;; ─── Mar 19: S. Joseph Sponsi B.M.V. — Invitatory ────────────────────

(bcp-roman-antiphonary-register
 'christum-dei-filium-putari
 '(:latin "Christum Dei Fílium, qui putári dignátus est fílius Joseph, * Veníte adorémus."
   :source composition
   :translations
   ((do . "Christ the Son of God, who deigned to be thought the son of Joseph, * Come, let us adore him."))))

;;; ─── Mar 19: S. Joseph Sponsi B.M.V. — Nocturn antiphons ────────────

(bcp-roman-antiphonary-register
 'ascendit-joseph-a-galilaea
 '(:latin "Ascéndit Joseph, a Galilǽa de civitáte Názareth in Judǽam, in civitátem David, quæ vocátur Béthlehem, ut profiterétur cum María."
   :source vulgate
   :ref "Luc 2:4"
   :translations
   ((do . "Joseph went up from Galilee, out of the city of Nazareth, into Judea, unto the city of David, which is called Bethlehem, to be enrolled with Mary."))))

(bcp-roman-antiphonary-register
 'venerunt-pastores
 '(:latin "Venérunt pastóres festinántes; et invenérunt Maríam, et Joseph, et Infántem pósitum in præsépio."
   :source vulgate
   :ref "Luc 2:16"
   :translations
   ((do . "The shepherds came with haste, and found Mary and Joseph, and the Infant laid in a manger."))))

(bcp-roman-antiphonary-register
 'ecce-angelus-domini-apparuit-joseph
 '(:latin "Ecce Angelus Dómini appáruit in somnis Joseph, dicens: Surge, et áccipe Púerum et Matrem ejus, et fuge in Ægýptum."
   :source vulgate
   :ref "Matt 2:13"
   :translations
   ((do . "Behold, the Angel of the Lord appeared to Joseph in a dream, saying: Arise, and take the Child and his Mother, and flee into Egypt."))))

(bcp-roman-antiphonary-register
 'consurgens-joseph
 '(:latin "Consúrgens Joseph, accépit Púerum et Matrem ejus nocte, et secéssit in Ægýptum; et erat ibi usque ad óbitum Heródis."
   :source vulgate
   :ref "Matt 2:14-15"
   :translations
   ((do . "Joseph arose and took the Child and his Mother by night, and withdrew into Egypt; and was there until the death of Herod."))))

(bcp-roman-antiphonary-register
 'defuncto-herode
 '(:latin "Defúncto Heróde, Angelus Dómini appáruit in somnis Joseph in Ægýpto, dicens: Surge, et áccipe Púerum et Matrem ejus, et vade in terram Israël; defúncti sunt enim qui quærébant ánimam Púeri."
   :source vulgate
   :ref "Matt 2:19-20"
   :translations
   ((do . "When Herod was dead, the Angel of the Lord appeared in a dream to Joseph in Egypt, saying: Arise, and take the Child and his Mother, and go into the land of Israel; for they are dead who sought the life of the Child."))))

(bcp-roman-antiphonary-register
 'accepit-joseph-puerum
 '(:latin "Accépit Joseph Púerum et Matrem ejus, et venit in terram Israël."
   :source vulgate
   :ref "Matt 2:21"
   :translations
   ((do . "Joseph took the Child and his Mother, and came into the land of Israel."))))

(bcp-roman-antiphonary-register
 'audiens-joseph
 '(:latin "Audiens Joseph, quod Archeláus regnáret in Judǽa pro Heróde patre suo, tímuit illo ire."
   :source vulgate
   :ref "Matt 2:22"
   :translations
   ((do . "When Joseph heard that Archelaus reigned in Judea in the room of Herod his father, he was afraid to go thither."))))

(bcp-roman-antiphonary-register
 'admonitus-in-somnis
 '(:latin "Admónitus in somnis, Joseph secéssit in partes Galilǽæ: et véniens habitávit in civitáte, quæ vocátur Názareth; ut adimplerétur quod dictum est per prophétas: Quóniam Nazarǽus vocábitur."
   :source vulgate
   :ref "Matt 2:22-23"
   :translations
   ((do . "Being warned in a dream, Joseph withdrew into the parts of Galilee; and coming he dwelt in a city called Nazareth; that it might be fulfilled which was said by the prophets: He shall be called a Nazarene."))))

(bcp-roman-antiphonary-register
 'erat-pater-jesu
 '(:latin "Erat Pater Jesu et Mater mirántes super his, quæ dicebántur de illo; et benedíxit illis Símeon."
   :source vulgate
   :ref "Luc 2:33-34"
   :translations
   ((do . "His father and mother were wondering at those things which were spoken concerning him; and Simeon blessed them."))))

;;; ─── Mar 24: S. Gabrielis Archangeli — Nocturn antiphons ─────────────
;;; Invitatory inherited from May 8 (regem-archangelorum-dominum).

(bcp-roman-antiphonary-register
 'dixit-angelus-gabriel-danieli
 '(:latin "Dixit Angelus Gábriel ad Daniélem: Intéllige, fílii hóminis, quóniam in témpore finis implébitur vísio."
   :source vulgate
   :ref "Dan 8:17"
   :translations
   ((do . "The Angel Gabriel said to Daniel: Understand, O son of man, for in the time of the end the vision shall be fulfilled."))))

(bcp-roman-antiphonary-register
 'ecce-vir-gabriel
 '(:latin "Ecce vir Gábriel quem víderam in visióne cito volans tétigit me in témpore sacrifícii vespertíni et dócuit me."
   :source vulgate
   :ref "Dan 9:21-22"
   :translations
   ((do . "Behold the man Gabriel, whom I had seen in the vision, flying swiftly, touched me at the time of the evening sacrifice, and taught me."))))

(bcp-roman-antiphonary-register
 'cumque-gabriel-loqueretur
 '(:latin "Cumque Gábriel loquerétur ad me collápsus sum pronus in terram et tétigit me, et státuit me in gradu meo."
   :source vulgate
   :ref "Dan 8:18"
   :translations
   ((do . "And when Gabriel spoke to me, I fell on my face upon the ground; and he touched me, and set me upright."))))

(bcp-roman-antiphonary-register
 'gabriel-angelus-apparuit-zachariae
 '(:latin "Gábriel Angelus appáruit Zacharíæ, dicens: Uxor tua Elísabeth páriet tibi fílium, et vocábitur nomen ejus Joánnem."
   :source vulgate
   :ref "Luc 1:11-13"
   :translations
   ((do . "The Angel Gabriel appeared to Zacharias, saying: Thy wife Elizabeth shall bear thee a son, and thou shalt call his name John."))))

(bcp-roman-antiphonary-register
 'et-dixit-zacharias
 '(:latin "Et dixit Zacharías ad Angelum: Unde hoc sciam? ego enim sum senex, et uxor mea procéssit in diébus suis."
   :source vulgate
   :ref "Luc 1:18"
   :translations
   ((do . "And Zacharias said to the Angel: Whereby shall I know this? for I am an old man, and my wife is advanced in years."))))

(bcp-roman-antiphonary-register
 'respondens-autem-angelus-gabriel
 '(:latin "Respóndens autem Angelus dixit ei: Ego sum Gábriel, qui asto ante Deum: et missus sum loqui ad te, et hæc tibi evangelizáre."
   :source vulgate
   :ref "Luc 1:19"
   :translations
   ((do . "And the Angel answering, said to him: I am Gabriel, who stand before God: and am sent to speak to thee, and to bring thee these good tidings."))))

(bcp-roman-antiphonary-register
 'missus-est-gabriel-angelus
 '(:latin "Missus est Gábriel Angelus ad Maríam Vírginem desponsátam Joseph."
   :source vulgate
   :ref "Luc 1:26-27"
   :translations
   ((do . "The Angel Gabriel was sent to Mary, a Virgin espoused to Joseph."))))

(bcp-roman-antiphonary-register
 'gabriel-angelus-mariae-dixit
 '(:latin "Gábriel Angelus Maríæ dixit: Ecce Elísabeth cognáta tua, et ipsa concépit fílium in senectúte sua."
   :source vulgate
   :ref "Luc 1:36"
   :translations
   ((do . "The Angel Gabriel said to Mary: Behold thy cousin Elizabeth, she also hath conceived a son in her old age."))))

(bcp-roman-antiphonary-register
 'suscipe-verbum-virgo-maria
 '(:latin "Súscipe Verbum Virgo María, quod tibi a Dómino per Angelum Gabriélem transmíssum est."
   :source composition
   :translations
   ((do . "Receive the Word, O Virgin Mary, which hath been sent to thee from the Lord by the Angel Gabriel."))))

;;; ─── Jan 25 / Jun 30: S. Pauli Apostoli — Nocturn antiphons ─────────

(bcp-roman-antiphonary-register
 'qui-operatus-est-petro
 '(:latin "Qui operátus est Petro in apostolátum, operátus est et mihi inter gentes: et cognovérunt grátiam, quæ data est mihi a Christo Dómino."
   :source vulgate
   :ref "Gal 2:8-9"
   :translations
   ((do . "He who wrought in Peter to the apostleship, wrought also in me among the Gentiles: and they knew the grace which was given to me by Christ the Lord."))))

(bcp-roman-antiphonary-register
 'scio-cui-credidi
 '(:latin "Scio cui crédidi, et certus sum quia potens est depósitum meum serváre in illum diem justus judex."
   :source vulgate
   :ref "2 Tim 1:12"
   :translations
   ((do . "I know whom I have believed, and I am certain that he is able to keep that which I have committed unto him against that day, the just judge."))))

(bcp-roman-antiphonary-register
 'mihi-vivere-christus-est
 '(:latin "Mihi vívere Christus est, et mori lucrum: gloriári me opórtet in cruce Dómini nostri Jesu Christi."
   :source vulgate
   :ref "Phil 1:21; Gal 6:14"
   :translations
   ((do . "For me to live is Christ, and to die is gain: God forbid that I should glory, save in the cross of our Lord Jesus Christ."))))

(bcp-roman-antiphonary-register
 'tu-es-vas-electionis
 '(:latin "Tu es vas electiónis, sancte Paule Apóstole, prædicátor veritátis in univérso mundo."
   :source composition
   :translations
   ((do . "Thou art a chosen vessel, holy Paul the Apostle, a preacher of the truth throughout the whole world."))))

(bcp-roman-antiphonary-register
 'magnus-sanctus-paulus
 '(:latin "Magnus sanctus Paulus vas electiónis, vere digne est glorificándus, qui et méruit thronum duodécimum possidére."
   :source composition
   :translations
   ((do . "Great is the holy Paul, a chosen vessel, truly worthy to be glorified, who also merited to possess the twelfth throne."))))

(bcp-roman-antiphonary-register
 'bonum-certamen
 '(:latin "Bonum certámen certávi, cursum consummávi, fidem servávi."
   :source vulgate
   :ref "2 Tim 4:7"
   :translations
   ((do . "I have fought the good fight, I have finished my course, I have kept the faith."))))

(bcp-roman-antiphonary-register
 'saulus-qui-et-paulus
 '(:latin "Saulus, qui et Paulus, magnus prædicátor, a Deo confortátus convalescébat, et confundébat Judǽos."
   :source vulgate
   :ref "Act 9:22"
   :translations
   ((do . "Saul, who is also Paul, a great preacher, strengthened by God, increased in power, and confounded the Jews."))))

(bcp-roman-antiphonary-register
 'ne-magnitudo-revelationum
 '(:latin "Ne magnitúdo revelatiónum extóllat me, datus est mihi stímulus carnis meæ, ángelus sátanæ, qui me colaphízet: propter quod ter Dóminum rogávi ut auferrétur a me, et dixit mihi Dóminus: Súfficit tibi, Paule, grátia mea."
   :source vulgate
   :ref "2 Cor 12:7-9"
   :translations
   ((do . "Lest the greatness of the revelations should exalt me, there was given me a thorn in my flesh, an angel of Satan to buffet me: for which thing I thrice besought the Lord that it might depart from me, and the Lord said unto me: My grace is sufficient for thee, Paul."))))

(bcp-roman-antiphonary-register
 'reposita-est-mihi
 '(:latin "Repósita est mihi coróna justítiæ, quam reddet mihi Dóminus in illa die justus judex."
   :source vulgate
   :ref "2 Tim 4:8"
   :translations
   ((do . "There is laid up for me a crown of justice, which the Lord the just judge will render to me in that day."))))

;;; ─── Corpus Christi — Nocturn antiphons ──────────────────────────────

(bcp-roman-antiphonary-register
 'christum-regem-adoremus-dominantem
 '(:latin "Christum Regem adorémus dominántem géntibus: qui se manducántibus dat spíritus pinguédinem."
   :source composition
   :translations
   ((do . "O come, and let us worship Christ, Of all the nations Lord, Who doth, to them that feed on Him, The Bread of Life afford."))))

(bcp-roman-antiphonary-register
 'fructum-salutiferum
 '(:latin "Fructum salutíferum gustándum dedit Dóminus mortis suæ témpore."
   :source composition
   :translations
   ((do . "The Lord brought forth His fruit in the season of His death, even that fruit whereof if any man eat, he shall live for ever."))))

(bcp-roman-antiphonary-register
 'a-fructu-frumenti
 '(:latin "A fructu fruménti et vini multiplicáti fidéles in pace Christi requiéscunt."
   :source gallican
   :ref "Ps 4:8-9"
   :translations
   ((do . "His faithful ones which are increased by the fruit of His corn and His wine do lay them down in peace and sleep in Christ."))))

(bcp-roman-antiphonary-register
 'communione-calicis
 '(:latin "Communióne cálicis, quo Deus ipse súmitur, non vitulórum sánguine, congregávit nos Dóminus."
   :source composition
   :translations
   ((do . "Us, being many, hath the Lord made one body, for we are all partakers of that one cup, which is not the communion of the blood of bulls, but of God Himself."))))

(bcp-roman-antiphonary-register
 'memor-sit-dominus
 '(:latin "Memor sit Dóminus sacrifícii nostri: et holocáustum nostrum pingue fiat."
   :source gallican
   :ref "Ps 19:4"
   :translations
   ((do . "The Lord remember our offering, and accept our burnt-sacrifice."))))

(bcp-roman-antiphonary-register
 'paratur-nobis-mensa
 '(:latin "Parátur nobis mensa Dómini advérsus omnes, qui tríbulant nos."
   :source gallican
   :ref "Ps 22:5"
   :translations
   ((do . "The Lord prepareth His Table before us in the presence of our enemies."))))

(bcp-roman-antiphonary-register
 'in-voce-exsultationis
 '(:latin "In voce exsultatiónis résonent epulántes in mensa Dómini."
   :source gallican
   :ref "Ps 41:5"
   :translations
   ((do . "Let them that keep holiday around the table of the Lord make the voice of joy and praise to be heard."))))

(bcp-roman-antiphonary-register
 'introibo-ad-altare-sumam
 '(:latin "Introíbo ad altáre Dei: sumam Christum, qui rénovat juventútem meam."
   :source gallican
   :ref "Ps 42:4"
   :translations
   ((do . "I will go unto the Altar of God; I will feed on Christ, Which is the Renewer of my youth."))))

(bcp-roman-antiphonary-register
 'cibavit-nos-dominus-ex-adipe
 '(:latin "Cibávit nos Dóminus ex ádipe fruménti: et de petra, melle saturávit nos."
   :source gallican
   :ref "Ps 80:17"
   :translations
   ((do . "The Lord hath fed us with the finest of the wheat, and with honey out of the Rock hath He satisfied us."))))

(bcp-roman-antiphonary-register
 'ex-altari-tuo-domine
 '(:latin "Ex altári tuo, Dómine, Christum súmimus: in quem cor et caro nostra exsúltant."
   :source gallican
   :ref "Ps 83:4"
   :translations
   ((do . "It is at thine Altar, O Lord, that we do feed on Christ, for Whom our heart and our flesh crieth out."))))

;;; ─── Sacred Heart — Nocturn antiphons ───────────────────────────────

(bcp-roman-antiphonary-register
 'cor-jesu-amore-nostri
 '(:latin "Cor Jesu amóre nostri vulnerátum: Veníte, adorémus."
   :source composition
   :translations
   ((do . "The Sacred Heart of Jesus, which was wounded for love of us, O come, let us worship."))))

(bcp-roman-antiphonary-register
 'cogitationes-cordis-ejus
 '(:latin "Cogitatiónes Cordis ejus in generatióne et generatiónem."
   :source gallican
   :ref "Ps 32:11"
   :translations
   ((do . "The thoughts of his Heart shall endure from generation to generation."))))

(bcp-roman-antiphonary-register
 'apud-te-est-fons-vitae
 '(:latin "Apud te est fons vitæ; torrénte voluptátis tuæ potábis nos, Dómine."
   :source gallican
   :ref "Ps 35:10"
   :translations
   ((do . "For with thee is the well of life, O Lord; and thou shalt give them drink of thy pleasures."))))

(bcp-roman-antiphonary-register
 'homo-pacis-meae
 '(:latin "Homo pacis meæ, qui edébat panes meos, magnificávit super me supplantatiónem."
   :source gallican
   :ref "Ps 40:10"
   :translations
   ((do . "Even mine own familiar friend who did eat of my Bread, hath laid great wait for me."))))

(bcp-roman-antiphonary-register
 'rex-omnis-terrae-deus
 '(:latin "Rex omnis terræ Deus; regnábit super gentes."
   :source gallican
   :ref "Ps 46:8-9"
   :translations
   ((do . "God is King upon all the earth: he reigneth over the heathen."))))

(bcp-roman-antiphonary-register
 'dum-anxiaretur-cor-meum
 '(:latin "Dum anxiarétur Cor meum, in petra exaltásti me."
   :source gallican
   :ref "Ps 60:3"
   :translations
   ((do . "When my Heart was in heaviness, thou didst set me up upon a rock."))))

(bcp-roman-antiphonary-register
 'secundum-multitudinem-dolorum
 '(:latin "Secúndum multitúdinem dolórum meórum in Corde meo, consolatiónes tuæ lætificavérunt ánimam meam."
   :source gallican
   :ref "Ps 93:19"
   :translations
   ((do . "In the multitude of the sorrows that I had in my Heart, thy comforts have given joy to my soul."))))

(bcp-roman-antiphonary-register
 'qui-diligitis-dominum-confitemini
 '(:latin "Qui dilígitis Dóminum, confitémini memóriæ sanctificatiónis ejus."
   :source gallican
   :ref "Ps 96:12"
   :translations
   ((do . "O ye that love the Lord, give thanks for a remembrance of his holiness."))))

(bcp-roman-antiphonary-register
 'viderunt-omnes-termini
 '(:latin "Vidérunt omnes términi terræ salutáre Dei nostri."
   :source gallican
   :ref "Ps 97:3"
   :translations
   ((do . "All the ends of the world have seen the salvation of our God."))))

(bcp-roman-antiphonary-register
 'psallam-tibi-in-nationibus
 '(:latin "Psallam tibi in natiónibus, quia magna est super cælos misericórdia tua."
   :source gallican
   :ref "Ps 107:4"
   :translations
   ((do . "I will sing praises unto thee among the nations, for thy mercy is greater than the heavens."))))

;;; ─── Christ the King — Nocturn antiphons ────────────────────────────

(bcp-roman-antiphonary-register
 'jesum-christum-regem-regum
 '(:latin "Jesum Christum, Regem regum: Veníte adorémus."
   :source composition
   :translations
   ((do . "Jesus Christ, the King of kings: Come, let us adore!"))))

(bcp-roman-antiphonary-register
 'ego-autem-constitutus-sum-rex
 '(:latin "Ego autem constitútus sum Rex ab eo super Sion montem sanctum ejus, prǽdicans præcéptum ejus."
   :source gallican
   :ref "Ps 2:6-7"
   :translations
   ((do . "I have been set up as King by Him on Sion, His holy mountain, proclaiming His decree."))))

(bcp-roman-antiphonary-register
 'gloria-et-honore-coronasti
 '(:latin "Glória et honóre coronásti eum, Dómine: ómnia subjecísti sub pédibus ejus."
   :source gallican
   :ref "Ps 8:6-7"
   :translations
   ((do . "Thou hast crowned him with glory and honor, O Lord, putting all things under His feet."))))

(bcp-roman-antiphonary-register
 'elevamini-portae-aeternales
 '(:latin "Elevámini, portæ æternáles, et introíbit Rex glóriæ."
   :source gallican
   :ref "Ps 23:7"
   :translations
   ((do . "Reach up you ancient portals, that the King of glory may come in."))))

(bcp-roman-antiphonary-register
 'sedebit-dominus-rex
 '(:latin "Sedébit Dóminus Rex in ætérnum: Dóminus benedícet pópulo suo in pace."
   :source gallican
   :ref "Ps 28:10-11"
   :translations
   ((do . "The Lord is enthroned as King forever; may the Lord bless his people with peace."))))

(bcp-roman-antiphonary-register
 'virga-directionis
 '(:latin "Virga directiónis, virga regni tui: proptérea pópuli confitebúntur tibi in ætérnum, et in sǽculum sǽculi."
   :source gallican
   :ref "Ps 44:7,18"
   :translations
   ((do . "A tempered rod is thy royal scepter; therefore shall nations praise thee forever and ever."))))

(bcp-roman-antiphonary-register
 'psallite-regi-nostro
 '(:latin "Psállite Regi nostro, psállite: quóniam Rex magnus super omnem terram."
   :source gallican
   :ref "Ps 46:7-8"
   :translations
   ((do . "Sing praise to our King, sing praise; for he is the great King over all earth."))))

(bcp-roman-antiphonary-register
 'benedicentur-in-ipso
 '(:latin "Benedicéntur in ipso omnes tribus terræ; omnes gentes magnificábunt eum."
   :source gallican
   :ref "Ps 71:17"
   :translations
   ((do . "In Him shall all the tribes of the earth be blessed; all the nations shall proclaim His greatness."))))

(bcp-roman-antiphonary-register
 'et-ego-primogenitum
 '(:latin "Et ego primogénitum ponam illum: excélsum præ régibus terræ."
   :source gallican
   :ref "Ps 88:28"
   :translations
   ((do . "And I will make Him the firstborn, highest of the kings of the earth."))))

(bcp-roman-antiphonary-register
 'thronus-ejus-sicut-sol
 '(:latin "Thronus ejus sicut sol in conspéctu meo: et sicut luna perfécta in ætérnum."
   :source gallican
   :ref "Ps 88:37-38"
   :translations
   ((do . "His throne shall be like the sun before Me; like the moon, which remains forever."))))

(provide 'bcp-roman-antiphonary)

;;; bcp-roman-antiphonary.el ends here
