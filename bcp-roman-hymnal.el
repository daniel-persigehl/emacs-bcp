;;; bcp-roman-hymnal.el --- Hymn translations for the Roman Office -*- lexical-binding: t -*-

;;; Commentary:

;; A hymnal of Latin Office hymns with multiple English verse translations,
;; each attributed to a named translator.  Hymns are keyed by their Latin
;; incipit (a symbol), and each entry carries the Latin text plus one or
;; more English translations stored under translator keys.
;;
;; This file is independent of any particular Office or hour: both the
;; Little Office of the BVM and the full Roman Breviary draw from it.
;;
;; Architecture:
;;   Each hymn is an alist entry: (INCIPIT . PLIST)
;;   The PLIST has:
;;     :latin   STRING — the Latin text (pointed, with accents)
;;     :translations  ALIST of (TRANSLATOR-KEY . STRING)
;;
;; The translator key is a symbol naming the translator or edition:
;;   britt    — Dom Matthew Britt, O.S.B., Hymns of the Breviary and
;;              Missal (1922)
;;   caswall  — Edward Caswall, Lyra Catholica (1849)
;;   neale    — John Mason Neale, Mediaeval Hymns and Sequences (1851)
;;   primer   — The Primer (various editions, 16th-18th c.)
;;
;; User configuration:
;;   `bcp-roman-hymnal-preferred-translator' — default English translator
;;
;; Public API:
;;   `bcp-roman-hymnal-get'        — return hymn text for a given language
;;   `bcp-roman-hymnal-latin'      — return Latin text
;;   `bcp-roman-hymnal-english'    — return English text (preferred translator)
;;   `bcp-roman-hymnal-translators' — list available translators for a hymn

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-roman-hymnal nil
  "Hymn translations for the Roman Office."
  :prefix "bcp-roman-hymnal-"
  :group 'bcp-liturgy)

(defcustom bcp-roman-hymnal-preferred-translator 'britt
  "Default English translator for Office hymns.
Used by `bcp-roman-hymnal-english' when no translator is specified.
Falls back through `bcp-roman-hymnal-fallback-order' if the preferred
translator has no rendering for a given hymn."
  :type  '(choice (const britt)
                  (const caswall)
                  (const neale)
                  (const primer))
  :group 'bcp-roman-hymnal)

(defcustom bcp-roman-hymnal-fallback-order '(britt caswall neale primer do)
  "Translator fallback order when the preferred translator is unavailable.
Tried in sequence until a translation is found."
  :type  '(repeat symbol)
  :group 'bcp-roman-hymnal)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Hymn registry

(defvar bcp-roman-hymnal--hymns nil
  "Alist of (INCIPIT . PLIST) for registered hymns.
Each PLIST has :latin STRING and :translations ALIST.")

(defun bcp-roman-hymnal-register (incipit plist)
  "Register PLIST as hymn INCIPIT.
INCIPIT is a symbol (the Latin first line, kebab-cased).
PLIST has :latin and :translations."
  (setf (alist-get incipit bcp-roman-hymnal--hymns) plist))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-hymnal-latin (incipit)
  "Return the Latin text for hymn INCIPIT, or nil."
  (plist-get (alist-get incipit bcp-roman-hymnal--hymns) :latin))

(defun bcp-roman-hymnal-english (incipit &optional translator)
  "Return the English text for hymn INCIPIT.
TRANSLATOR is a symbol; defaults to `bcp-roman-hymnal-preferred-translator'.
Falls back through `bcp-roman-hymnal-fallback-order'."
  (let* ((entry (alist-get incipit bcp-roman-hymnal--hymns))
         (translations (plist-get entry :translations))
         (preferred (or translator bcp-roman-hymnal-preferred-translator))
         (order (cons preferred
                     (remq preferred bcp-roman-hymnal-fallback-order))))
    (cl-loop for tr in order
             for text = (alist-get tr translations)
             when text return text)))

(defun bcp-roman-hymnal-get (incipit language &optional translator)
  "Return hymn INCIPIT text for LANGUAGE.
LANGUAGE is \\='latin or \\='english.  TRANSLATOR is passed to
`bcp-roman-hymnal-english' for English lookups."
  (pcase language
    ('latin   (bcp-roman-hymnal-latin incipit))
    ('english (bcp-roman-hymnal-english incipit translator))
    (_        (bcp-roman-hymnal-latin incipit))))

(defun bcp-roman-hymnal-translators (incipit)
  "Return a list of translator symbols available for hymn INCIPIT."
  (let ((entry (alist-get incipit bcp-roman-hymnal--hymns)))
    (mapcar #'car (plist-get entry :translations))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Hymn data
;;
;; Each hymn is registered with its Latin text and one or more English
;; translations.  Translator attributions are given in the docstring
;; and as the alist key.
;;
;; The Latin texts are from the Breviarium Romanum (DA 1911 form)
;; as found in divinum-officium-master.

;;; ─── Ave maris stella ─────────────────────────────────────────────────────
;; Vespers hymn of the BVM.
;; English: Edward Caswall (1849), Lyra Catholica.

(bcp-roman-hymnal-register
 'ave-maris-stella
 '(:latin
   "Ave maris stella,\n\
Dei Mater alma,\n\
Atque semper Virgo,\n\
Felix cæli porta.\n\
\n\
Sumens illud Ave\n\
Gabriélis ore,\n\
Funda nos in pace,\n\
Mutans Hevæ nomen.\n\
\n\
Solve vincla reis,\n\
Profer lumen cæcis,\n\
Mala nostra pelle,\n\
Bona cuncta posce.\n\
\n\
Monstra te esse matrem:\n\
Sumat per te preces,\n\
Qui pro nobis natus,\n\
Tulit esse tuus.\n\
\n\
Virgo singuláris,\n\
Inter omnes mitis,\n\
Nos culpis solútos,\n\
Mites fac et castos.\n\
\n\
Vitam præsta puram,\n\
Iter para tutum:\n\
Ut vidéntes Jesum,\n\
Semper collætémur.\n\
\n\
Sit laus Deo Patri,\n\
Summo Christo decus,\n\
Spirítui Sancto,\n\
Tribus honor unus.\n\
Amen."
   :translations
   ((caswall .
     "Ave, star of ocean,\n\
Child divine who barest,\n\
Mother, ever-Virgin,\n\
Heaven's portal fairest.\n\
\n\
Taking that sweet Ave\n\
Erst by Gabriel spoken,\n\
Eva's name reversing,\n\
Be of peace the token.\n\
\n\
Break the sinners' fetters,\n\
Light to blind restoring,\n\
All our ills dispelling,\n\
Every boon imploring.\n\
\n\
Show thyself a mother\n\
In thy supplication;\n\
He will hear who chose thee\n\
At his incarnation.\n\
\n\
Maid all maids excelling,\n\
Passing meek and lowly,\n\
Win for sinners pardon,\n\
Make us chaste and holy.\n\
\n\
As we onward journey\n\
Aid our weak endeavour,\n\
Till we gaze on Jesus\n\
And rejoice forever.\n\
\n\
Father, Son, and Spirit,\n\
Three in One confessing,\n\
Give we equal glory\n\
Equal praise and blessing.\n\
Amen."))))

;;; ─── Quem terra pontus sidera ─────────────────────────────────────────────
;; Matins hymn of the BVM.
;; English: John Mason Neale (1851), Mediaeval Hymns and Sequences.
;; Also appears in Hymns Ancient and Modern (1861).

(bcp-roman-hymnal-register
 'quem-terra-pontus-sidera
 '(:latin
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
   :translations
   ((neale .
     "The God whom earth, and sea, and sky\n\
Adore, and laud, and magnify,\n\
Who o'er their threefold fabric reigns,\n\
The Virgin's spotless womb contains.\n\
\n\
The God, whose will by moon and sun\n\
And all things in due course is done,\n\
Is borne upon a maiden's breast,\n\
By fullest heavenly grace possest.\n\
\n\
How blest that mother, in whose shrine\n\
The great artificer divine,\n\
Whose hand contains the earth and sky,\n\
Vouchsafed, as in his ark, to lie.\n\
\n\
Blest, in the message Gabriel brought;\n\
Blest, by the work the Spirit wrought;\n\
From whom the great desire of earth\n\
Took human flesh and human birth.\n\
\n\
All honour, laud, and glory be,\n\
O Jesu, Virgin-born to thee;\n\
All glory, as is ever meet,\n\
To Father and to Paraclete.\n\
Amen."))))

;;; ─── O gloriosa virginum ──────────────────────────────────────────────────
;; Lauds hymn of the BVM.
;; The original incipit is "O gloriosa virginum" but the revised Roman
;; Breviary (Urban VIII) uses "O gloriosa Domina".
;; English: attributed to the Primer tradition; also appears in Britt.

(bcp-roman-hymnal-register
 'o-gloriosa-virginum
 '(:latin
   "O gloriósa Vírginum,\n\
Sublímis inter sídera,\n\
Qui te creávit, párvulum\n\
Lacténte nutris úbere.\n\
\n\
Quod Heva tristis ábstulit,\n\
Tu reddis almo gérmine:\n\
Intrent ut astra flébiles,\n\
Cæli reclúdis cárdines.\n\
\n\
Tu Regis alti jánua,\n\
Et aula lucis fúlgida:\n\
Vitam datam per Vírginem,\n\
Gentes redémptæ, pláudite.\n\
\n\
Jesu, tibi sit glória,\n\
Qui natus es de Vírgine,\n\
Cum Patre, et almo Spíritu\n\
In sempitérna sǽcula.\n\
Amen."
   :translations
   ((britt .
     "O glorious lady! throned on high\n\
Above the star-illumined sky;\n\
Thereto ordained, thy bosom lent\n\
To thy Creator nourishment.\n\
\n\
Through thy sweet offspring we receive\n\
The bliss once lost through hapless Eve;\n\
And heaven to mortals open lies\n\
Now thou art portal of the skies.\n\
\n\
Thou art the door of heaven's high King,\n\
Light's gateway fair and glistering;\n\
Life through a Virgin is restored;\n\
Ye ransomed nations, praise the Lord!\n\
\n\
All honour, laud, and glory be,\n\
O Jesu, Virgin-born, to thee;\n\
All glory, as is ever meet,\n\
To Father and to Paraclete.\n\
Amen."))))

;;; ─── Memento rerum Conditor ────────────────────────────────────────────────
;; Minor Hours and Compline hymn of the BVM (LOBVM).
;; The Minor Hours form has three stanzas; the Compline form inserts
;; "Enixa est puerpera" as the second stanza.
;;
;; English: Dom Matthew Britt, O.S.B. (1922), Hymns of the Breviary
;; and Missal.
;;
;; Two variants are registered:
;;   memento-rerum-conditor        — Minor Hours (3 stanzas)
;;   memento-rerum-conditor-compl  — Compline (4 stanzas, with Enixa)

(bcp-roman-hymnal-register
 'memento-rerum-conditor
 '(:latin
   "Meménto, rerum Cónditor,\n\
Nostri quod olim córporis,\n\
Sacráta ab alvo Vírginis\n\
Nascéndo formam súmpseris.\n\
\n\
María Mater grátiæ,\n\
Dulcis Parens cleméntiæ,\n\
Tu nos ab hoste prótege,\n\
Et mortis hora súscipe.\n\
\n\
Jesu, tibi sit glória,\n\
Qui natus es de Vírgine,\n\
Cum Patre et almo Spíritu,\n\
In sempitérna sǽcula.\n\
Amen."
   :translations
   ((britt .
     "Remember, O creator Lord,\n\
That in the Virgin's sacred womb\n\
Thou wast conceived, and of her flesh\n\
Didst our mortality assume.\n\
\n\
Mother of grace, O Mary blest,\n\
To thee, sweet fount of love, we fly;\n\
Shield us through life, and take us hence\n\
To thy dear bosom when we die.\n\
\n\
O Jesu, born of Virgin bright,\n\
Immortal glory be to thee;\n\
Praise to the Father infinite,\n\
And Holy Ghost eternally.\n\
Amen."))))

(bcp-roman-hymnal-register
 'memento-rerum-conditor-compl
 '(:latin
   "Meménto, rerum Cónditor,\n\
Nostri quod olim córporis,\n\
Sacráta ab alvo Vírginis\n\
Nascéndo formam súmpseris.\n\
\n\
Eníxa est puérpera,\n\
Quem Gábriel prædíxerat,\n\
Quem matris alvo géstiens,\n\
Clausus Joánnes sénserat.\n\
\n\
María Mater grátiæ,\n\
Dulcis Parens cleméntiæ,\n\
Tu nos ab hoste prótege,\n\
Et mortis hora súscipe.\n\
\n\
Jesu, tibi sit glória,\n\
Qui natus es de Vírgine,\n\
Cum Patre et almo Spíritu,\n\
In sempitérna sǽcula.\n\
Amen."
   :translations
   ((britt .
     "Remember, O creator Lord,\n\
That in the Virgin's sacred womb\n\
Thou wast conceived, and of her flesh\n\
Didst our mortality assume.\n\
\n\
The maid brought forth th' eternal Child,\n\
Whom Gabriel's voice had prophesied,\n\
Whom in his mother's womb enclosed\n\
The Baptist had with joy descried.\n\
\n\
Mother of grace, O Mary blest,\n\
To thee, sweet fount of love, we fly;\n\
Shield us through life, and take us hence\n\
To thy dear bosom when we die.\n\
\n\
O Jesu, born of Virgin bright,\n\
Immortal glory be to thee;\n\
Praise to the Father infinite,\n\
And Holy Ghost eternally.\n\
Amen."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Ferial Vespers hymns (one per day of week)
;;
;; Latin texts from the DA 1911 Roman Breviary (Urban VIII revision).
;; English from divinum-officium (DO).

;;; ─── Lucis creator optime ────────────────────────────────────────────────
;; Sunday Vespers.

(bcp-roman-hymnal-register
 'lucis-creator-optime
 '(:latin
   "Lucis Creátor óptime,\n\
Lucem diérum próferens,\n\
Primórdiis lucis novæ,\n\
Mundi parans oríginem:\n\
\n\
Qui mane junctum vésperi\n\
Diem vocári prǽcipis:\n\
Illábitur tetrum chaos,\n\
Audi preces cum flétibus.\n\
\n\
Ne mens graváta crímine,\n\
Vitæ sit exsul múnere,\n\
Dum nil perénne cógitat,\n\
Seséque culpis ílligat.\n\
\n\
Cæléste pulset óstium:\n\
Vitále tollat prǽmium:\n\
Vitémus omne nóxium:\n\
Purgémus omne péssimum.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O blest Creator of the light,\n\
Who mak'st the day with radiance bright,\n\
And o'er the forming world didst call\n\
The light from chaos first of all;\n\
\n\
Whose wisdom joined in meet array\n\
The morn and eve, and named them day:\n\
Night comes with all its darkling fears;\n\
Regard thy people's prayers and tears.\n\
\n\
Lest, sunk in sin, and whelmed with strife,\n\
They lose the gift of endless life;\n\
While thinking but the thoughts of time,\n\
They weave new chains of woe and crime.\n\
\n\
But grant them grace that they may strain\n\
The heavenly gate and prize to gain:\n\
Each harmful lure aside to cast,\n\
And purge away each error past.\n\
\n\
O Father, that we ask be done,\n\
Through Jesus Christ, thine only Son;\n\
Who, with the Holy Ghost and thee,\n\
Doth live and reign eternally.\n\
Amen."))))

;;; ─── Immense caeli Conditor ──────────────────────────────────────────────
;; Monday Vespers.

(bcp-roman-hymnal-register
 'immense-caeli-conditor
 '(:latin
   "Imménse cæli Cónditor,\n\
Qui mixta ne confúnderent,\n\
Aquæ fluénta dívidens,\n\
Cælum dedísti límitem.\n\
\n\
Firmans locum cæléstibus,\n\
Simúlque terræ rívulis;\n\
Ut unda flammas témperet,\n\
Terræ solum ne díssipent.\n\
\n\
Infúnde nunc, piíssime,\n\
Donum perénnis grátiæ:\n\
Fraudis novæ ne cásibus\n\
Nos error átterat vetus.\n\
\n\
Lucem fides adáugeat:\n\
Sic lúminis jubar ferat:\n\
Hæc vana cuncta próterat:\n\
Hanc falsa nulla cómprimant.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O great Creator of the sky,\n\
Who wouldest not the floods on high\n\
With earthly waters to confound,\n\
But mad'st the firmament their bound;\n\
\n\
The floods above thou didst ordain;\n\
The floods below thou didst restrain:\n\
That moisture might attemper heat,\n\
Lest the parched earth should ruin meet.\n\
\n\
Upon our souls, good Lord, bestow\n\
Thy gift of grace in endless flow:\n\
Lest some renewed deceit or wile\n\
Of former sin should us beguile.\n\
\n\
Let faith discover heav'nly light;\n\
So shall its rays direct us right:\n\
And let this faith each error chase,\n\
And never give to falsehood place.\n\
\n\
Grant this, O Father, ever One\n\
With Christ, thy sole-begotten Son,\n\
And Holy Ghost, whom all adore,\n\
Reigning and blest forevermore.\n\
Amen."))))

;;; ─── Telluris alme Conditor ─────────────────────────────────────────────
;; Tuesday Vespers.

(bcp-roman-hymnal-register
 'telluris-alme-conditor
 '(:latin
   "Tellúris alme Cónditor,\n\
Mundi solum qui séparans,\n\
Pulsis aquæ moléstiis,\n\
Terram dedísti immóbilem:\n\
\n\
Ut germen aptum próferens,\n\
Fulvis decóra flóribus,\n\
Fecúnda fructu sísteret,\n\
Pastúmque gratum rédderet.\n\
\n\
Mentis perústæ vúlnera\n\
Munda viróre grátiæ:\n\
Ut facta fletu díluat,\n\
Motúsque pravos átterat.\n\
\n\
Jussis tuis obtémperet:\n\
Nullis malis appróximet:\n\
Bonis repléri gáudeat,\n\
Et mortis ictum nésciat.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Earth's mighty Maker, whose command\n\
Raised from the sea the solid land;\n\
And drove each billowy heap away,\n\
And bade the earth stand firm for aye:\n\
\n\
That so, with flowers of golden hue,\n\
The seeds of each it might renew;\n\
And fruit-trees bearing fruit might yield,\n\
And pleasant pasture of the field:\n\
\n\
Our spirit's rankling wounds efface\n\
With dewy freshness of thy grace:\n\
That grief may cleanse each deed of ill,\n\
And o'er each lust may triumph still.\n\
\n\
Let every soul thy law obey,\n\
And keep from every evil way;\n\
Rejoice each promised good to win,\n\
And flee from every mortal sin.\n\
\n\
Hear thou our prayer, Almighty King!\n\
Hear thou our praises, while we sing,\n\
Adoring with the heavenly host,\n\
The Father, Son, and Holy Ghost!\n\
Amen."))))

;;; ─── Caeli Deus sanctissime ─────────────────────────────────────────────
;; Wednesday Vespers.

(bcp-roman-hymnal-register
 'caeli-deus-sanctissime
 '(:latin
   "Cæli Deus sanctíssime,\n\
Qui lúcidas mundi plagas\n\
Candóre pingis ígneo,\n\
Augens decóro lúmine:\n\
\n\
Quarto die qui flámmeam\n\
Dum solis accéndis rotam,\n\
Lunæ minístras órdinem,\n\
Vagósque cursus síderum:\n\
\n\
Ut nóctibus, vel lúmini\n\
Diremptiónis términum,\n\
Primórdiis et ménsium\n\
Signum dares notíssimum;\n\
\n\
Expélle noctem córdium:\n\
Abstérge sordes méntium:\n\
Resólve culpæ vínculum:\n\
Evérte moles críminum.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O God, whose hand hath spread the sky,\n\
And all its shining hosts on high,\n\
And painting it with fiery light,\n\
Made it so beauteous and so bright:\n\
\n\
Thou, when the fourth day was begun,\n\
Didst frame the circle of the sun,\n\
And set the moon for ordered change,\n\
And planets for their wider range:\n\
\n\
To night and day, by certain line,\n\
Their varying bounds thou didst assign;\n\
And gav'st a signal, known and meet,\n\
For months begun and months complete.\n\
\n\
Enlighten thou the hearts of men:\n\
Polluted souls make pure again:\n\
Unloose the bands of guilt within:\n\
Remove the burden of our sin.\n\
\n\
Grant this, O Father, ever One\n\
With Christ thy sole-begotten Son,\n\
Whom, with the Spirit we adore,\n\
One God, both now and evermore.\n\
Amen."))))

;;; ─── Magnae Deus potentiae ──────────────────────────────────────────────
;; Thursday Vespers.

(bcp-roman-hymnal-register
 'magne-deus-potentiae
 '(:latin
   "Magnæ Deus poténtiæ,\n\
Qui fértili natos aqua\n\
Partim relínquis gúrgiti,\n\
Partim levas in áëra.\n\
\n\
Demérsa lymphis ímprimens,\n\
Subvécta cælis érigens:\n\
Ut stirpe ab una pródita,\n\
Divérsa répleant loca:\n\
\n\
Largíre cunctis sérvulis,\n\
Quos mundat unda Sánguinis,\n\
Nescíre lapsus críminum,\n\
Nec ferre mortis tǽdium.\n\
\n\
Ut culpa nullum déprimat:\n\
Nullum éfferat jactántia:\n\
Elísa mens ne cóncidat:\n\
Eláta mens ne córruat.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O sovereign Lord of nature's might,\n\
Who bad'st the water's birth divide;\n\
Part in the heavens to take their flight,\n\
And part in ocean's deep to hide;\n\
\n\
These low obscured, on airy wing\n\
Exalted those, that either race,\n\
Though from one element they spring,\n\
Might serve thee in a different place.\n\
\n\
Grant, Lord, that we thy servants all,\n\
Saved by thy tide of cleansing blood,\n\
No more 'neath sin's dominion fall,\n\
Nor fear the thought of death's dark flood!\n\
\n\
Thy varied love each spirit bless,\n\
The humble cheer, the high control;\n\
Check in each heart its proud excess,\n\
But raise the meek and contrite soul!\n\
\n\
This boon, O Father, we entreat,\n\
This blessing grant, Eternal Son,\n\
And Holy Ghost, the Paraclete,\n\
Both now, and while the ages run.\n\
Amen."))))

;;; ─── Hominis superne Conditor ────────────────────────────────────────────
;; Friday Vespers.

(bcp-roman-hymnal-register
 'hominis-superne-conditor
 '(:latin
   "Hóminis supérne Cónditor,\n\
Qui cuncta solus órdinans,\n\
Humum jubes prodúcere\n\
Reptántis et feræ genus:\n\
\n\
Et magna rerum córpora,\n\
Dictu jubéntis vívida,\n\
Per témporum certas vices\n\
Obtemperáre sérvulis:\n\
\n\
Repélle, quod cupídinis\n\
Ciénte vi nos ímpetit,\n\
Aut móribus se súggerit,\n\
Aut áctibus se intérserit.\n\
\n\
Da gaudiórum prǽmia,\n\
Da gratiárum múnera:\n\
Dissólve litis víncula:\n\
Astrínge pacis fœ́dera.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Maker of man, who from thy throne\n\
Dost order all things, God alone;\n\
By whose decree the teeming earth\n\
To reptile and to beast gave birth:\n\
\n\
The mighty forms that fill the land,\n\
Instinct with life at thy command,\n\
Are given subdued to humankind\n\
For service in their rank assigned.\n\
\n\
From all thy servants drive away\n\
Whate'er of thought impure to-day\n\
Hath been with open action blent,\n\
Or mingled with the heart's intent.\n\
\n\
In heaven thine endless joys bestow,\n\
And grant thy gifts of grace below;\n\
From chains of strife our souls release,\n\
Bind fast the gentle bands of peace.\n\
\n\
Grant this, O Father, ever One\n\
With Christ, thy sole-begotten Son,\n\
Whom, with the Spirit we adore,\n\
One God, both now and evermore.\n\
Amen."))))

;;; ─── Jam sol recedit igneus ──────────────────────────────────────────────
;; Saturday Vespers (First Vespers of Sunday).

(bcp-roman-hymnal-register
 'jam-sol-recedit-igneus
 '(:latin
   "Jam sol recédit ígneus:\n\
Tu, lux perénnis, Únitas,\n\
Nostris, beáta Trínitas,\n\
Infúnde lumen córdibus.\n\
\n\
Te mane laudum cármine,\n\
Te deprecámur véspere;\n\
Dignéris ut te súpplices\n\
Laudémus inter cǽlites.\n\
\n\
Patri, simúlque Fílio,\n\
Tibíque, Sancte Spíritus,\n\
Sicut fuit, sit júgiter\n\
Sæclum per omne glória.\n\
Amen."
   :translations
   ((do .
     "As fades the glowing orb of day,\n\
To thee, great source of light, we pray;\n\
Blest Three in One, to every heart\n\
Thy beams of life and love impart.\n\
\n\
At early dawn, at close of day,\n\
To thee our vows we humbly pay;\n\
May we, mid joys that never end,\n\
With thy bright saints in homage bend.\n\
\n\
To God the Father, and the Son,\n\
And Holy Spirit, Three in One,\n\
Be endless glory, as before\n\
The world began, so evermore.\n\
Amen."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Compline hymn (invariant)

;;; ─── Te lucis ante terminum ──────────────────────────────────────────────
;; Compline hymn, same every day (per annum).

(bcp-roman-hymnal-register
 'te-lucis-ante-terminum
 '(:latin
   "Te lucis ante términum,\n\
Rerum Creátor, póscimus,\n\
Ut pro tua cleméntia\n\
Sis præsul et custódia.\n\
\n\
Procul recédant sómnia,\n\
Et nóctium phantásmata;\n\
Hostémque nostrum cómprime,\n\
Ne polluántur córpora.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Before the ending of the day,\n\
Creator of the world, we pray\n\
That with thy wonted favor thou\n\
Wouldst be our guard and keeper now.\n\
\n\
From all ill dreams defend our eyes,\n\
From nightly fears and fantasies;\n\
Tread under foot our ghostly foe,\n\
That no pollution we may know.\n\
\n\
O Father, that we ask be done,\n\
Through Jesus Christ, thine only Son;\n\
Who, with the Holy Ghost and thee,\n\
Doth live and reign eternally.\n\
Amen."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lauds hymns (per annum, Day0–Day6)

;;; ─── Ecce jam noctis (Sunday Lauds) ─────────────────────────────────────

(bcp-roman-hymnal-register
 'ecce-jam-noctis
 '(:latin
   "Ecce, jam noctis tenuátur umbra,\n\
Lux et auróræ rútilans corúscat:\n\
Súpplices rerum Dóminum canóra\n\
Voce precémur:\n\
\n\
Ut reos culpæ miserátus omnem\n\
Pellat angórem, tríbuat salútem,\n\
Donet et nobis bona sempitérnæ\n\
Múnera pacis.\n\
\n\
Præstet hoc nobis Déitas beáta\n\
Patris, ac Nati, paritérque Sancti\n\
Spíritus, cujus résonat per omnem\n\
Glória mundum.\n\
Amen."
   :translations
   ((do .
     "Lo, the dim shadows of the night are waning;\n\
Lightsome and blushing, dawn of day returneth;\n\
Fervent in spirit, to the world's Creator\n\
Pray we devoutly:\n\
\n\
That he may pity sinners in their sighing,\n\
Banish all troubles, kindly health bestowing;\n\
And may he grant us, of his countless blessings,\n\
Peace that is endless.\n\
\n\
This be our portion, God forever blessed,\n\
Father eternal, Son, and Holy Spirit,\n\
Whose is the glory, which through all creation\n\
Ever resoundeth.\n\
Amen."))))

;;; ─── Splendor paternae gloriae (Monday Lauds) ───────────────────────────

(bcp-roman-hymnal-register
 'splendor-paternae-gloriae
 '(:latin
   "Splendor Patérnæ glóriæ,\n\
De luce lucem próferens,\n\
Lux lucis, et fons lúminis,\n\
Diem dies illúminans:\n\
\n\
Verúsque sol illábere,\n\
Micans nitóre pérpeti:\n\
Jubárque Sancti Spíritus\n\
Infúnde nostris sénsibus.\n\
\n\
Votis vocémus et Patrem,\n\
Patrem poténtis grátiæ,\n\
Patrem perénnis glóriæ:\n\
Culpam reléget lúbricam.\n\
\n\
Confírmet actus strénuos:\n\
Dentes retúndat ínvidi:\n\
Casus secúndet ásperos:\n\
Agénda recte dírigat.\n\
\n\
Mentem gubérnet et regat:\n\
Sit pura nobis cástitas:\n\
Fides calóre férveat,\n\
Fraudis venéna nésciat.\n\
\n\
Christúsque nobis sit cibus,\n\
Potúsque noster sit fides:\n\
Læti bibámus sóbriam\n\
Profusiónem Spíritus.\n\
\n\
Lætus dies hic tránseat:\n\
Pudor sit ut dilúculum:\n\
Fides velut merídies:\n\
Crepúsculum mens nésciat.\n\
\n\
Auróra lucem próvehit,\n\
Cum luce nobis pródeat\n\
In Patre totus Fílius,\n\
Et totus in Verbo Pater.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc et per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O splendour of God's glory bright,\n\
O thou that bringest light from light,\n\
O light of light, light's living spring,\n\
O day, all days illumining.\n\
\n\
O thou true sun, on us thy glance\n\
Let fall in royal radiance,\n\
The Spirit's sanctifying beam\n\
Upon our earthly senses stream.\n\
\n\
The Father too our prayers implore,\n\
Father of glory evermore,\n\
The Father of all grace and might,\n\
To banish sin from our delight:\n\
\n\
To guide whate'er we nobly do,\n\
With love all envy to subdue,\n\
To make ill-fortune turn to fair,\n\
And give us grace our wrongs to bear.\n\
\n\
Our mind be in his keeping placed,\n\
Our body true to him and chaste,\n\
Where only faith her fire shall feed,\n\
And burn the tares of Satan's seed.\n\
\n\
And Christ to us for food shall be,\n\
From him our drink that welleth free,\n\
The Spirit's wine, that maketh whole,\n\
And mocking not, exalts the soul.\n\
\n\
Rejoicing may this day go hence,\n\
Like virgin dawn our innocence,\n\
Like fiery noon our faith appear,\n\
Nor know the gloom of twilight drear.\n\
\n\
Morn in her rosy car is borne;\n\
Let him come forth our perfect morn,\n\
The Word in God the Father One,\n\
The Father perfect in the Son.\n\
\n\
All laud to God the Father be;\n\
All praise, Eternal Son, to thee;\n\
All glory, as is ever meet,\n\
To God the Holy Paraclete.\n\
Amen."))))

;;; ─── Ales diei nuntius (Tuesday Lauds) ───────────────────────────────────

(bcp-roman-hymnal-register
 'ales-diei-nuntius
 '(:latin
   "Ales diéi núntius\n\
Lucem propínquam prǽcinit:\n\
Nos excitátor méntium\n\
Jam Christus ad vitam vocat.\n\
\n\
Auférte, clamat, léctulos,\n\
Ægro sopóre désides:\n\
Castíque, recti, ac sóbrii\n\
Vigiláte, jam sum próximus.\n\
\n\
Jesum ciámus vócibus,\n\
Flentes, precántes, sóbrii:\n\
Inténta supplicátio\n\
Dormíre cor mundum vetat.\n\
\n\
Tu, Christe, somnum díscute:\n\
Tu rumpe noctis víncula:\n\
Tu solve peccátum vetus,\n\
Novúmque lumen íngere.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc et per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "As the bird, whose clarion gay\n\
Sounds before the dawn is grey,\n\
Christ, who brings the spirit's day,\n\
Calls us, close at hand:\n\
\n\
Wake! he cries, and for my sake,\n\
From your eyes dull slumbers shake!\n\
Sober, righteous, chaste, awake!\n\
At the door I stand!\n\
\n\
Lord, to thee we lift on high\n\
Fervent prayer and bitter cry:\n\
Hearts aroused to pray and sigh\n\
May not slumber more:\n\
\n\
Break the sleep of death and time,\n\
Forged by Adam's ancient crime;\n\
And the light of Eden's prime\n\
To the world restore!\n\
\n\
Unto God the Father, Son,\n\
Holy Spirit, Three in One,\n\
One in Three, be glory done,\n\
Now and evermore.\n\
Amen."))))

;;; ─── Nox et tenebrae et nubila (Wednesday Lauds) ────────────────────────

(bcp-roman-hymnal-register
 'nox-et-tenebrae
 '(:latin
   "Nox, et tenébræ, et núbila,\n\
Confúsa mundi et túrbida:\n\
Lux intrat, albéscit polus:\n\
Christus venit: discédite.\n\
\n\
Calígo terræ scínditur\n\
Percússa solis spículo,\n\
Rebúsque jam color redit,\n\
Vultu niténtis síderis.\n\
\n\
Te, Christe, solum nóvimus:\n\
Te mente pura et simplici,\n\
Flendo et canéndo quǽsumus,\n\
Inténde nostris sénsibus.\n\
\n\
Sunt multa fucis íllita,\n\
Quæ luce purgéntur tua:\n\
Tu, vera lux cæléstium,\n\
Vultu seréno illúmina.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc et per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Day is breaking, dawn is bright:\n\
Hence, vain shadows of the night!\n\
Mists that dim our mortal sight,\n\
Christ is come! Depart!\n\
\n\
Darkness routed lifts her wings\n\
As the radiance upwards springs:\n\
Through the world of wakened things\n\
Life and colour dart.\n\
\n\
Thee, O Christ, alone we know:\n\
Singing even in our woe,\n\
With pure hearts to thee we go:\n\
On our senses shine!\n\
\n\
In thy beams be purged away\n\
All that leads our thoughts astray!\n\
Through our spirits, King of day,\n\
Pour thy light divine!\n\
\n\
Unto God the Father, Son,\n\
Holy Spirit, Three in One,\n\
One in Three, be glory done,\n\
Now and evermore.\n\
Amen."))))

;;; ─── Lux ecce surgit aurea (Thursday Lauds) ─────────────────────────────

(bcp-roman-hymnal-register
 'lux-ecce-surgit-aurea
 '(:latin
   "Lux ecce surgit áurea,\n\
Pallens facéssat cǽcitas,\n\
Quæ nosmet in præceps diu\n\
Erróre traxit dévio.\n\
\n\
Hæc lux serénum cónferat,\n\
Purósque nos præstet sibi:\n\
Nihil loquámur súbdolum:\n\
Volvámus obscúrum nihil.\n\
\n\
Sic tota decúrrat dies,\n\
Ne lingua mendax, ne manus\n\
Oculíve peccent lúbrici,\n\
Ne noxa corpus ínquinet.\n\
\n\
Speculátor astat désuper,\n\
Qui nos diébus ómnibus,\n\
Actúsque nostros próspicit\n\
A luce prima in vésperum.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc et per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "See the golden sun arise!\n\
Let no more our darkened eyes\n\
Snare us, tangled by surprise\n\
In the maze of sin!\n\
\n\
From false words and thoughts impure\n\
Let this light, serene and sure,\n\
Keep our lips without secure,\n\
Keep our souls within.\n\
\n\
So may we the day-time spend,\n\
That, till life's temptations end,\n\
Tongue, nor hand, nor eye offend!\n\
One, above us all,\n\
\n\
Views in his revealing ray\n\
All we do, and think, and say,\n\
Watching us from break of day\n\
Till the twilight fall.\n\
\n\
Unto God the Father, Son,\n\
Holy Spirit, Three in One,\n\
One in Three, be glory done,\n\
Now and evermore.\n\
Amen."))))

;;; ─── Aeterna caeli gloria (Friday Lauds) ─────────────────────────────────

(bcp-roman-hymnal-register
 'aeterna-caeli-gloria
 '(:latin
   "Ætérna cæli glória,\n\
Beáta spes mortálium,\n\
Summi Tonántis Únice,\n\
Castǽque proles Vírginis:\n\
\n\
Da déxteram surgéntibus,\n\
Exsúrgat et mens sóbria,\n\
Flagrans et in laudem Dei\n\
Grates repéndat débitas.\n\
\n\
Ortus refúlget Lúcifer,\n\
Præítque solem núntius:\n\
Cadunt tenébræ nóctium:\n\
Lux sancta nos illúminet.\n\
\n\
Manénsque nostris sénsibus,\n\
Noctem repéllat sǽculi,\n\
Omníque fine témporis\n\
Purgáta servet péctora.\n\
\n\
Quæsíta jam primum fides\n\
In corde radíces agat:\n\
Secúnda spes congáudeat,\n\
Qua major exstat cáritas.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc et per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O Christ, whose glory fills the heaven,\n\
Our only hope, in mercy given;\n\
Child of a Virgin meek and pure;\n\
Son of the Highest evermore:\n\
\n\
Grant us thine aid thy praise to sing,\n\
As opening days new duties bring;\n\
That with the light our life may be\n\
Renewed and sanctified by thee.\n\
\n\
The morning star fades from the sky,\n\
The sun breaks forth; night's shadows fly:\n\
O Thou, true Light, upon us shine:\n\
Our darkness turn to light divine.\n\
\n\
Within us grant thy light to dwell;\n\
And from our souls dark sins expel;\n\
Cleanse thou our minds from stain of ill,\n\
And with thy peace our bosoms fill.\n\
\n\
To us strong faith forever give,\n\
With joyous hope, in thee to live;\n\
That life's rough way may ever be\n\
Made strong and pure by charity.\n\
\n\
All laud to God the Father be,\n\
All praise, Eternal Son, to thee:\n\
All glory, as is ever meet,\n\
To God the holy Paraclete.\n\
Amen."))))

;;; ─── Aurora jam spargit polum (Saturday Lauds) ───────────────────────────

(bcp-roman-hymnal-register
 'aurora-jam-spargit-polum
 '(:latin
   "Auróra jam spargit polum:\n\
Terris dies illábitur:\n\
Lucis resúltat spículum:\n\
Discédat omne lúbricum.\n\
\n\
Phantásma noctis éxsulet:\n\
Mentis reátus córruat:\n\
Quidquid ténebris hórridum\n\
Nox áttulit culpæ, cadat.\n\
\n\
Ut mane, quod nos últimum\n\
Hic deprecámur cérnui,\n\
Cum luce nobis éffluat,\n\
Hoc dum canóre cóncrepat.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc et per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "The dawn is sprinkling in the east\n\
Its golden shower, as day flows in;\n\
Fast mount the pointed shafts of light:\n\
Farewell to darkness and to sin!\n\
\n\
Away, ye midnight phantoms all!\n\
Away, despondence and despair!\n\
Whatever guilt the night has brought,\n\
Now let it vanish into air.\n\
\n\
So, Lord, when that last morning breaks,\n\
Looking to which we sigh and pray,\n\
O may it to thy minstrels prove\n\
The dawning of a better day.\n\
\n\
To God the Father glory be,\n\
And to his sole-begotten Son;\n\
Glory, O Holy Ghost, to thee,\n\
While everlasting ages run.\n\
Amen."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Prime hymn (invariant per annum)

;;; ─── Jam lucis orto sidere (Prime) ───────────────────────────────────────

(bcp-roman-hymnal-register
 'jam-lucis-orto-sidere
 '(:latin
   "Jam lucis orto sídere,\n\
Deum precémur súpplices,\n\
Ut in diúrnis áctibus\n\
Nos servet a nocéntibus.\n\
\n\
Linguam refrénans témperet,\n\
Ne litis horror ínsonet:\n\
Visum fovéndo cóntegat,\n\
Ne vanitátes háuriat.\n\
\n\
Sint pura cordis íntima,\n\
Absístat et vecórdia;\n\
Carnis terat supérbiam\n\
Potus cibíque párcitas.\n\
\n\
Ut, cum dies abscésserit,\n\
Noctémque sors redúxerit,\n\
Mundi per abstinéntiam\n\
Ipsi canámus glóriam.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc et per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Now in the sun's new dawning ray,\n\
Lowly of heart, our God we pray\n\
That he from harm may keep us free\n\
In all the deeds this day shall see.\n\
\n\
May fear of him our tongues restrain,\n\
Lest strife unguarded speech should stain:\n\
His favouring care our guardian be,\n\
Lest our eyes feed on vanity.\n\
\n\
May every heart be pure from sin\n\
And folly find no place therein:\n\
Scant need of food, excess denied,\n\
Wear down in us the body's pride.\n\
\n\
That when the light of day is gone,\n\
And night in course shall follow on.\n\
We, free from cares the world affords,\n\
May chant the praise that is our Lord's.\n\
\n\
All laud to God the Father be,\n\
All praise, Eternal Son, to thee:\n\
All glory, as is ever meet,\n\
To God the holy Paraclete.\n\
Amen."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Little Hours hymns (invariant per annum)

;;; ─── Nunc Sancte nobis Spiritus (Terce) ─────────────────────────────────

(bcp-roman-hymnal-register
 'nunc-sancte-nobis-spiritus
 '(:latin
   "Nunc, Sancte, nobis, Spíritus,\n\
Unum Patri cum Fílio,\n\
Dignáre promptus íngeri\n\
Nostro refúsus péctori.\n\
\n\
Os, lingua, mens, sensus, vigor\n\
Confessiónem pérsonent.\n\
Flamméscat igne cáritas,\n\
Accéndat ardor próximos.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Come Holy Ghost who ever One\n\
Art with the Father and the Son,\n\
It is the hour, our souls possess\n\
With thy full flood of holiness.\n\
\n\
Let flesh and heart and lips and mind\n\
Sound forth our witness to mankind;\n\
And love light up our mortal frame,\n\
Till others catch the living flame.\n\
\n\
Almighty Father, hear our cry,\n\
Through Jesus Christ, our Lord most High,\n\
Who, with the Holy Ghost and thee,\n\
Doth live and reign eternally.\n\
Amen."))))

;;; ─── Rector potens verax Deus (Sext) ────────────────────────────────────

(bcp-roman-hymnal-register
 'rector-potens-verax-deus
 '(:latin
   "Rector potens, verax Deus,\n\
Qui témperas rerum vices,\n\
Splendóre mane illúminas,\n\
Et ígnibus merídiem:\n\
\n\
Exstíngue flammas lítium,\n\
Aufer calórem nóxium,\n\
Confer salútem córporum,\n\
Verámque pacem córdium.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O God of truth, O Lord of might,\n\
Who orderest time and change aright,\n\
Who send'st the early morning ray,\n\
And light'st the glow of perfect day:\n\
\n\
Extinguish thou each sinful fire,\n\
And banish every ill desire;\n\
And while thou keep'st the body whole,\n\
Shed forth thy peace upon the soul.\n\
\n\
Almighty Father, hear our cry,\n\
Through Jesus Christ, our Lord most High,\n\
Who, with the Holy Ghost and thee,\n\
Doth live and reign eternally.\n\
Amen."))))

;;; ─── Rerum Deus tenax vigor (None) ──────────────────────────────────────

(bcp-roman-hymnal-register
 'rerum-deus-tenax-vigor
 '(:latin
   "Rerum, Deus, tenax vigor,\n\
Immótus in te pérmanens,\n\
Lucis diúrnæ témpora\n\
Succéssibus detérminans:\n\
\n\
Largíre lumen véspere,\n\
Quo vita nusquam décidat,\n\
Sed prǽmium mortis sacræ\n\
Perénnis instet glória.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O strength and stay upholding all creation,\n\
Who ever dost thyself unmoved abide,\n\
Yet day by day the light in due gradation\n\
From hour to hour through all its changes guide:\n\
\n\
Grant to life's day a calm unclouded ending,\n\
An eve untouched by shadows of decay,\n\
The brightness of a holy death-bed blending\n\
With dawning glories of th' eternal day.\n\
\n\
Hear us, O Father, gracious and forgiving,\n\
And thou, O Christ, the co-eternal Word,\n\
Who, with the Holy Ghost, by all things living\n\
Now and to endless ages art adored.\n\
Amen."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins hymns (per-annum, one per day of week)

;;; ─── Primo dierum omnium (Sunday Matins) ────────────────────────────────

(bcp-roman-hymnal-register
 'primo-dierum-omnium
 '(:latin
   "Primo diérum ómnium,\n\
Quo mundus extat cónditus,\n\
Vel quo resúrgens Cónditor\n\
Nos morte victa líberat.\n\
\n\
Pulsis procul torpóribus\n\
Surgámus omnes ócius,\n\
Et nocte quærámus pium\n\
Sicut prophétam nóvimus.\n\
\n\
Nostras preces ut áudiat,\n\
Suámque dextram pórrigat:\n\
Et expiátos sórdibus\n\
Reddat polórum sédibus.\n\
\n\
Ut quique sacratíssimo\n\
Hujus diéi témpore\n\
Horis quiétis psállimus,\n\
Donis beátis múneret.\n\
\n\
Jam nunc patérna cláritas\n\
Te postulámus áffatim:\n\
Absit libído sórdidans\n\
Et omnis actus nóxius.\n\
\n\
Ne fœda sit, vel lúbrica\n\
Compágo nostri córporis,\n\
Per quem Avérni ígnibus\n\
Ipsi cremémur ácrius.\n\
\n\
Ob hoc Redémptor, quǽsumus,\n\
Ut probra nostra díluas,\n\
Vitæ perénnis cómmoda\n\
Nobis benígne cónferas.\n\
\n\
Quo carnis actu éxsules\n\
Effécti ipsi cælibes,\n\
Ut præstolámur cérnui,\n\
Melos canámus glóriæ.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Now, from the slumbers of the night arising,\n\
Chant we the holy psalmody of David,\n\
Hymns to our Master, with a voice concordant,\n\
Sweetly intoning.\n\
\n\
So may our Monarch pitifully hear us,\n\
That we may merit with his saints to enter\n\
Mansions eternal, therewithal possessing\n\
Joy beatific.\n\
\n\
This be our portion, God forever blessed,\n\
Father eternal, Son, and Holy Spirit,\n\
Whose is the glory, which through all creation\n\
Ever resoundeth.\n\
Amen."))))

;;; ─── Somno refectis artubus (Monday Matins) ─────────────────────────────

(bcp-roman-hymnal-register
 'somno-refectis-artubus
 '(:latin
   "Somno reféctis ártubus,\n\
Spreto cubíli, súrgimus:\n\
Nobis, Pater, canéntibus\n\
Adésse te depóscimus.\n\
\n\
Te lingua primum cóncinat,\n\
Te mentis ardor ámbiat:\n\
Ut áctuum sequéntium\n\
Tu, Sancte, sis exórdium.\n\
\n\
Cedant tenébræ lúmini,\n\
Et nox diúrno síderi,\n\
Ut culpa, quam nox íntulit,\n\
Lucis labáscat múnere.\n\
\n\
Precámur iídem súpplices,\n\
Noxas ut omnes ámputes,\n\
Et ore te canéntium\n\
Laudéris omni témpore.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Our limbs refreshed with slumber now,\n\
And sloth cast off, in prayer we bow;\n\
And while we sing thy praises dear,\n\
O Father, be thou present here.\n\
\n\
To thee our earliest morning song,\n\
To thee our hearts full powers belong;\n\
And thou, O Holy One, prevent\n\
Each following action and intent.\n\
\n\
As shades at morning flee away,\n\
And night before the star of day;\n\
So each transgression of the night\n\
Be purged by thee, celestial Light!\n\
\n\
Cut off, we pray thee, each offense,\n\
And every lust of thought and sense:\n\
That by their lips who thee adore\n\
Thou mayst be praised forevermore.\n\
\n\
Grant this, O Father ever One\n\
With Christ, thy sole-begotten Son,\n\
And Holy Ghost, whom all adore,\n\
Reigning and blest forevermore.\n\
Amen."))))

;;; ─── Consors paterni luminis (Tuesday Matins) ───────────────────────────

(bcp-roman-hymnal-register
 'consors-paterni-luminis
 '(:latin
   "Consors patérni lúminis,\n\
Lux ipse lucis, et dies,\n\
Noctem canéndo rúmpimus:\n\
Assíste postulántibus.\n\
\n\
Aufer ténebras méntium,\n\
Fuga catérvas dǽmonum,\n\
Expélle somnoléntiam,\n\
Ne pigritántes óbruat.\n\
\n\
Sic, Christe, nobis ómnibus\n\
Indúlgeas credéntibus,\n\
Ut prosit exorántibus,\n\
Quod præcinéntes psállimus.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O Light of Light, O Day-spring bright,\n\
Co-equal in thy Father's light:\n\
Assist us, as with prayer and psalm\n\
Thy servants break the twilight calm.\n\
\n\
All darkness from our minds dispel,\n\
And turn to flight the hosts of hell:\n\
Bid sleepfulness our eyelids fly,\n\
Lest overwhelmed in sloth we lie.\n\
\n\
Jesu, thy pardon, kind and free,\n\
Bestow on us who trust in thee:\n\
And as thy praises we declare,\n\
O with acceptance hear our prayer.\n\
\n\
O Father, that we ask be done,\n\
Through Jesus Christ, thine only Son;\n\
Who, with the Holy Ghost and thee,\n\
Doth live and reign eternally.\n\
Amen."))))

;;; ─── Rerum Creator optime (Wednesday Matins) ────────────────────────────

(bcp-roman-hymnal-register
 'rerum-creator-optime
 '(:latin
   "Rerum Creátor óptime,\n\
Rectórque noster, áspice:\n\
Nos a quiéte nóxia\n\
Mersos sopóre líbera.\n\
\n\
Te, sancte Christe, póscimus,\n\
Ignósce culpis ómnibus:\n\
Ad confiténdum súrgimus,\n\
Morásque noctis rúmpimus.\n\
\n\
Mentes manúsque tóllimus,\n\
Prophéta sicut nóctibus\n\
Nobis geréndum prǽcipit,\n\
Paulúsque gestis cénsuit.\n\
\n\
Vides malum, quod fécimus:\n\
Occúlta nostra pándimus:\n\
Preces geméntes fúndimus,\n\
Dimítte quod peccávimus.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Who madest all and dost control,\n\
Lord, with thy touch divine,\n\
Cast out the slumbers of the soul,\n\
The rest that is not thine.\n\
\n\
Look down, Eternal Holiness,\n\
And wash the sins away,\n\
Of those, who, rising to confess,\n\
Outstrip the lingering day.\n\
\n\
Our hearts and hands by night, O Lord,\n\
We lift them in Our need;\n\
As holy Psalmists give the word,\n\
And holy Paul the deed.\n\
\n\
Each sin to thee of years gone by,\n\
Each hidden stain lies bare;\n\
We shrink not from thine awful eye,\n\
But pray that thou wouldst spare.\n\
\n\
Grant this, O Father, Only Son\n\
And Spirit, God of grace,\n\
To whom all worship shall be done\n\
In every time and place.\n\
Amen."))))

;;; ─── Nox atra rerum contegit (Thursday Matins) ─────────────────────────

(bcp-roman-hymnal-register
 'nox-atra-rerum-contegit
 '(:latin
   "Nox atra rerum cóntegit\n\
Terræ colóres ómnium:\n\
Nos confiténtes póscimus\n\
Te, juste judex córdium.\n\
\n\
Ut áuferas piácula,\n\
Sordésque mentis ábluas:\n\
Donésque, Christe, grátiam,\n\
Ut arceántur crímina.\n\
\n\
Mens ecce torpet ímpia,\n\
Quam culpa mordet nóxia:\n\
Obscúra gestit tóllere,\n\
Et te, Redémptor, quǽrere.\n\
\n\
Repélle tu calíginem\n\
Intrínsecus quam máxime,\n\
Ut in beáto gáudeat\n\
Se collocári lúmine.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "The dusky veil of night hath laid\n\
The varied hues of earth in shade;\n\
Before Thee, righteous Judge of all,\n\
We contrite in confession fall.\n\
\n\
Take far away our load of sin,\n\
Our soiled minds make clean within:\n\
Thy sov'reign grace, O Christ, impart,\n\
From all offence to guard our heart.\n\
\n\
For lo! our mind is dull and cold,\n\
Envenomed by sin's baneful hold:\n\
Fain would it now the darkness flee,\n\
And seek, Redeemer, unto Thee.\n\
\n\
Far from it drive the shades of night,\n\
Its inmost darkness put to flight;\n\
Till in the daylight of the blest\n\
It joys to find itself at rest.\n\
\n\
Almighty Father, hear our cry,\n\
Through Jesus Christ, our Lord most High,\n\
Who, with the Holy Ghost and Thee,\n\
Doth live and reign eternally.\n\
Amen."))))

;;; ─── Tu Trinitatis Unitas (Friday Matins) ──────────────────────────────

(bcp-roman-hymnal-register
 'tu-trinitatis-unitas
 '(:latin
   "Tu, Trinitátis Unitas,\n\
Orbem poténter quæ regis,\n\
Atténde laudis cánticum,\n\
Quod excubántes psállimus.\n\
\n\
Nam léctulo consúrgimus\n\
Noctis quiéto témpore,\n\
Ut flagitémus ómnium\n\
A te medélam vúlnerum.\n\
\n\
Quo fraude quidquid dǽmonum\n\
In nóctibus delíquimus,\n\
Abstérgat illud cǽlitus\n\
Tuæ potéstas glóriæ.\n\
\n\
Ne corpus astet sórdidum,\n\
Nec torpor instet córdium,\n\
Ne críminis contágio\n\
Tepéscat ardor spíritus.\n\
\n\
Ob hoc, Redémptor, quǽsumus,\n\
Reple tuo nos lúmine,\n\
Per quod diérum círculis\n\
Nullis ruámus áctibus.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "O Three in One, and One in Three,\n\
Who rulest all things mightily:\n\
Bow down to hear the songs of praise\n\
Which, freed from bonds of sleep, we raise.\n\
\n\
While lingers yet the peace of night,\n\
We rouse us from our slumbers light:\n\
That might of instant prayer may win\n\
The healing balm for wounds of sin.\n\
\n\
If, by the wiles of Satan caught,\n\
This night-time we have sinned in aught,\n\
That sin Thy glorious power to-day,\n\
From heaven descending, cleanse away.\n\
\n\
Let naught impure our bodies stain,\n\
No laggard sloth our souls detain,\n\
No taint of sin our spirits know,\n\
To chill the fervor of their glow.\n\
\n\
Wherefore, Redeemer grant that we\n\
Fulfilled with thine own light may be:\n\
That, in our course, from day to day,\n\
By no misdeed we fall away.\n\
\n\
Grant this, O Father ever One\n\
With Christ, thy sole-begotten Son,\n\
And Holy Ghost, whom all adore,\n\
Reigning and blest forevermore.\n\
Amen."))))

;;; ─── Summae Parens clementiae (Saturday Matins) ─────────────────────────

(bcp-roman-hymnal-register
 'summae-parens-clementiae
 '(:latin
   "Summæ Parens cleméntiæ,\n\
Mundi regis qui máchinam,\n\
Uníus et substántiæ,\n\
Trinúsque persónis Deus:\n\
\n\
Nostros pius cum cánticis\n\
Fletus benígne súscipe:\n\
Ut corde puro sórdium\n\
Te perfruámur lárgius.\n\
\n\
Lumbos, jecúrque mórbidum\n\
Flammis adúre cóngruis,\n\
Accíncti ut artus éxcubent,\n\
Luxu remóto péssimo.\n\
\n\
Quicúmque ut horas nóctium\n\
Nunc concinéndo rúmpimus,\n\
Ditémur omnes áffatim\n\
Donis beátæ pátriæ.\n\
\n\
Præsta, Pater piíssime,\n\
Patríque compar Únice,\n\
Cum Spíritu Paráclito\n\
Regnans per omne sǽculum.\n\
Amen."
   :translations
   ((do .
     "Great God of boundless mercy hear;\n\
Thou Ruler of this earthly sphere;\n\
In substance one, in persons three,\n\
Dread Trinity in Unity!\n\
\n\
Do thou in love accept our lays\n\
Of mingled penitence and praise;\n\
And set our hearts from error free,\n\
More fully to rejoice in thee.\n\
\n\
Our reins and hearts in pity heal,\n\
And with thy chastening fires anneal;\n\
Gird Thou our loins, each passion quell,\n\
And every harmful lust expel.\n\
\n\
Now as our anthems, upward borne,\n\
Awake the silence of the morn,\n\
Enrich us with thy gifts of grace,\n\
From heaven, thy blissful dwelling-place!\n\
\n\
Hear thou our prayer, Almighty King!\n\
Hear thou our praises, while we sing,\n\
Adoring with the heavenly host,\n\
The Father, Son, and Holy Ghost!\n\
Amen."))))

(provide 'bcp-roman-hymnal)
;;; bcp-roman-hymnal.el ends here
