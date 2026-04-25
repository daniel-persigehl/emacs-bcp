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
;;     :translations         ALIST of (TRANSLATOR-KEY . STRING)
;;     :translation-meters   ALIST of (TRANSLATOR-KEY . METER-STRING).
;;                           Optional; per-translator because translators
;;                           recast the metre freely (e.g. Caswall's C.M.
;;                           rendering of an L.M. Latin original).
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
(eval-when-compile (require 'bcp-hymnal))
(declare-function bcp-hymnal-register-exporter "bcp-hymnal" (fn))

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
;;;; Export to the unified hymnal text store
;;
;; The Roman registry is the authoring surface (Latin original plus
;; translator-keyed translations grouped by incipit).  At unified-store
;; load time, every entry is unpacked into one text-record per
;; (incipit, language, translator) so the shared selector and renderer
;; treat Roman hymns identically to manifest hymnals.  Roman renderers
;; continue to call `bcp-roman-hymnal-get'; the export is purely
;; additive.

(defun bcp-roman-hymnal--first-line (body)
  "Return the first non-empty line of BODY, trimmed of trailing comma."
  (let* ((line (car (split-string body "\n" t))))
    (replace-regexp-in-string "[,;]\\'" "" (or line ""))))

(defun bcp-roman-hymnal--split-stanzas (body)
  "Split BODY on blank lines, returning a list of stanza strings."
  (mapcar #'string-trim (split-string body "\n[ \t]*\n" t)))

(defun bcp-roman-hymnal--export-to-unified ()
  "Insert one record per (incipit, language, translator) into
`bcp-hymnal--texts'.  Latin record id is the incipit symbol;
each English record id is `incipit/translator'.  Tags from the
Roman entry are copied to every record produced from it.  Per-
translator meter from `:translation-meters' is attached to each
English record's `:meter' slot."
  (require 'bcp-hymnal)
  (dolist (cell bcp-roman-hymnal--hymns)
    (let* ((incipit      (car cell))
           (plist        (cdr cell))
           (latin        (plist-get plist :latin))
           (translations (plist-get plist :translations))
           (meters       (plist-get plist :translation-meters))
           (tags         (plist-get plist :tags)))
      (when latin
        (puthash incipit
                 (list :first-line (bcp-roman-hymnal--first-line latin)
                       :stanzas    (bcp-roman-hymnal--split-stanzas latin)
                       :language   'latin
                       :tags       tags
                       :copyright  :public-domain)
                 bcp-hymnal--texts))
      (dolist (tr translations)
        (let* ((translator (car tr))
               (body       (cdr tr))
               (meter      (alist-get translator meters))
               (tid (intern (format "%s/%s" incipit translator))))
          (puthash tid
                   (list :first-line (bcp-roman-hymnal--first-line body)
                         :stanzas    (bcp-roman-hymnal--split-stanzas body)
                         :language   'english
                         :translator translator
                         :original   incipit
                         :meter      meter
                         :tags       tags
                         :copyright  :public-domain)
                   bcp-hymnal--texts))))))

(with-eval-after-load 'bcp-hymnal
  (bcp-hymnal-register-exporter #'bcp-roman-hymnal--export-to-unified))

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
 '(:tags (vespers marian)
   :latin
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
   :translation-meters ((caswall . "66. 66."))
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
 '(:tags (matins marian)
   :latin
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
   :translation-meters ((neale . "L.M."))
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
 '(:tags (lauds marian)
   :latin
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
   :translation-meters ((britt . "L.M."))
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
 '(:tags (marian)
   :latin
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
   :translation-meters ((britt . "L.M."))
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
 '(:tags (compline marian)
   :latin
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
   :translation-meters ((britt . "L.M."))
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
 '(:tags (vespers creation)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (vespers creation)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (vespers creation)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (vespers creation)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (vespers creation)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (vespers creation)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (vespers trinitarian)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (compline)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (lauds)
   :latin
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
   :translation-meters ((do . "11. 11. 11. 5."))
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
 '(:tags (lauds)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (lauds)
   :latin
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
   :translation-meters ((do . "77. 77. 5."))
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
 '(:tags (lauds)
   :latin
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
   :translation-meters ((do . "77. 77. 5."))
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
 '(:tags (lauds)
   :latin
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
   :translation-meters ((do . "77. 77. 5."))
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
 '(:tags (lauds)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (lauds)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (prime morning)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (terce holy-spirit paraclete)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (sext)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (none)
   :latin
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
   :translation-meters ((do . "11. 10. 11. 10."))
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
 '(:tags (matins)
   :latin
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
   :translation-meters ((do . "11. 11. 11. 5."))
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
 '(:tags (matins)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (matins)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (matins)
   :latin
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
   :translation-meters ((do . "C.M."))
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
 '(:tags (matins)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (matins trinitarian)
   :latin
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
   :translation-meters ((do . "L.M."))
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
 '(:tags (matins)
   :latin
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
   :translation-meters ((do . "L.M."))
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

;;; ─── Jam Christus astra ascenderat ────────────────────────────────────────
;; Pentecost Matins hymn.
;; English: DO translation.

(bcp-roman-hymnal-register
 'jam-christus-astra-ascenderat
 '(:tags (matins pentecost-octave holy-spirit paraclete)
   :latin
   "Jam Christus astra ascénderat,\n\
Revérsus unde vénerat,\n\
Promíssum Patris múnere,\n\
Sanctum datúrus Spíritum.\n\
\n\
Solémnis urgébat dies,\n\
Quo mýstico septémplici\n\
Orbis volútus sépties,\n\
Signat beáta témpora.\n\
\n\
Cum lucis hora tértia\n\
Repénte mundus íntonat,\n\
Orántibus Apóstolis\n\
Deum venísse núntiat.\n\
\n\
De Patris ergo lúmine\n\
Decórus ignis almus est,\n\
Qui fida Christi péctora\n\
Calóre Verbi cómpleat.\n\
\n\
Impléta gaudent víscera,\n\
Affláta Sancto Spíritu,\n\
Voces divérsas íntonant,\n\
Fantur Dei magnália.\n\
\n\
Ex omni gente cógniti,\n\
Græcis, Latínis, Bárbaris,\n\
Cunctísque admirántibus,\n\
Linguis loquúntur ómnium.\n\
\n\
Judǽa tunc incrédula,\n\
Vesána torvo spíritu,\n\
Ructáre musti crápulam,\n\
Alúmnos Christi cóncrepat.\n\
\n\
Sed signis et virtútibus\n\
Occúrrit, et docet Petrus,\n\
Falsa profári pérfidos,\n\
Joéle teste cómprobans.\n\
\n\
Glória Patri Dómino,\n\
Natóque, qui a mórtuis\n\
Surréxit, ac Paráclito,\n\
In sæculórum sǽcula.\n\
Amen."
   :translation-meters ((do . "L.M."))
   :translations
   ((do .
     "Now Christ, ascending whence he came,\n\
Had mounted o'er the starry frame,\n\
The Holy Ghost on man below,\n\
The Father's promise, to bestow.\n\
\n\
The solemn time was drawing nigh,\n\
Replete with heav'nly mystery,\n\
On seven days' sevenfold circles borne,\n\
That first and blessèd Whitsun-morn.\n\
\n\
When the third hour shone all around,\n\
There came a rushing mighty sound,\n\
And told the Apostles, while in prayer,\n\
That, as was promised, God was there.\n\
\n\
Forth from the Father's light it came,\n\
That beautiful and kindly flame:\n\
To fill with fervour of his word\n\
The spirits faithful to their Lord.\n\
\n\
With joy the Apostles' breasts are fired,\n\
By God the Holy Ghost inspired:\n\
And straight, in diverse kinds of speech,\n\
The wondrous works of God they preach.\n\
\n\
To men of every race they speak,\n\
Alike barbarian, Roman, Greek:\n\
From the same lips, with awe and fear,\n\
All men their native accents hear.\n\
\n\
But Juda's sons, e'en faithless yet,\n\
With mad infuriate rage beset,\n\
To mock Christ's followers combine,\n\
As drunken all with new-made wine.\n\
\n\
When lo! with signs and mighty deeds,\n\
Stands Peter in the midst, and pleads;\n\
Confounding their malignant lie\n\
By Joel's ancient prophecy.\n\
\n\
To God the Father let us sing,\n\
To God the Son, our risen King,\n\
And equally let us adore\n\
The Spirit, God forevermore.\n\
Amen."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Proper feast Matins hymns

;;; ─── Christe Redemptor omnium (Christmas Matins) ─────────────────────────
;; English: DO translation.

(bcp-roman-hymnal-register
 'christe-redemptor-omnium
 '(:tags (matins christmastide nativity)
   :latin
   "Christe Redémptor ómnium,\n\
Ex Patre Patris únice,\n\
Solus ante princípium\n\
Natus ineffabíliter.\n\
\n\
Tu lumen, tu splendor Patris,\n\
Tu spes perénnis ómnium:\n\
Inténde quas fundunt preces\n\
Tui per orbem fámuli.\n\
\n\
Meménto salútis Auctor,\n\
Quod nostri quondam córporis,\n\
Ex illibáta Vírgine\n\
Nascéndo, formam súmpseris.\n\
\n\
Sic præsens testátur dies,\n\
Currens per anni círculum,\n\
Quod solus a sede Patris\n\
Mundi salus advéneris.\n\
\n\
Hunc cælum, terra, hunc mare,\n\
Hunc omne quod in eis est,\n\
Auctórem advéntus tui,\n\
Laudans exsúltat cántico.\n\
\n\
Nos quoque, qui sancto tuo\n\
Redémpti sánguine sumus,\n\
Ob diem natális tui,\n\
Hymnum novum concínimus.\n\
\n\
Glória tibi Dómine,\n\
Qui natus es de Vírgine,\n\
Cum Patre et Sancto Spíritu,\n\
In sempitérna sǽcula.\n\
Amen."
   :translation-meters ((do . "L.M."))
   :translations
   ((do .
     "Jesus, the Ransomer of man,\n\
Who, ere created light began,\n\
Didst from the sovereign Father spring,\n\
His power and glory equalling.\n\
\n\
The Father's light and splendour thou,\n\
Their endless hope to thee that bow;\n\
Accept the prayers and praise to-day\n\
That through the world thy servants pay.\n\
\n\
Salvation's author, call to mind,\n\
How, taking form of humankind,\n\
Born of a Virgin undefiled,\n\
Thou in man's flesh becam'st a child.\n\
\n\
Thus testifies the present day,\n\
Through every year in long array,\n\
That thou, salvation's source alone,\n\
Proceededst from the Father's throne.\n\
\n\
Him heaven and earth, Him land and sea,\n\
Him all that is both land and sea,\n\
Salutes the Author of thy birth,\n\
Singing a new glad song of mirth.\n\
\n\
And we who, by thy precious blood\n\
From sin redeemed, are marked for God,\n\
On this the day that saw thy birth,\n\
Sing the new song of ransomed earth.\n\
\n\
All honour, laud, and glory be,\n\
O Jesu, Virgin-born, to thee:\n\
All glory, as is ever meet,\n\
To Father, and to Paraclete.\n\
Amen."))))

;;; ─── Deus tuorum militum (Commune Martyris Matins) ───────────────────────
;; English: DO translation.

(bcp-roman-hymnal-register
 'deus-tuorum-militum
 '(:tags (matins sanctorum)
   :latin
   "Deus tuórum mílitum\n\
Sors, et coróna, prǽmium,\n\
Laudes canéntes Mártyris\n\
Absólve nexu críminis.\n\
\n\
Hic nempe mundi gáudia,\n\
Et blandiménta nóxia\n\
Cadúca rite députans,\n\
Pervénit ad cæléstia.\n\
\n\
Pœnas cucúrrit fórtiter,\n\
Et sústulit viríliter,\n\
Pro te effúndens sánguinem,\n\
Ætérna dona póssidet.\n\
\n\
Ob hoc precátu súpplici\n\
Te póscimus, piíssime;\n\
In hoc triúmpho Mártyris\n\
Dimítte noxam sérvulis.\n\
\n\
Deo Patri sit glória,\n\
Et Fílio, qui a mórtuis\n\
Surréxit, ac Paráclito,\n\
In sempitérna sǽcula.\n\
Amen."
   :translation-meters ((do . "L.M."))
   :translations
   ((do .
     "O God, of those that fought thy fight,\n\
Portion, and prize, and crown of light,\n\
Break every bond of sin and shame\n\
As now we praise thy martyr's name.\n\
\n\
He, counting earthly pleasures dross,\n\
And all the lure of wanton joys,\n\
Passed, rightly judging, from the earth,\n\
And reached the home of heavenly mirth.\n\
\n\
With brave endurance, manfully,\n\
He bore his torturer's cruelty;\n\
For thee he poured his blood abroad,\n\
And won an everlasting reward.\n\
\n\
We therefore pray thee, full of love,\n\
Regard us from thy throne above;\n\
On this thy Martyr's triumph day,\n\
Wash every stain of sin away.\n\
\n\
To God the Father, laud and praise,\n\
To God the Son, who rose again,\n\
And Holy Ghost, whom both did raise,\n\
In endless glory. Amen."))))

;;; ─── Hostis Herodes impie (Epiphany Matins) ──────────────────────────────
;; English: DO translation.

(bcp-roman-hymnal-register
 'hostis-herodes-impie
 '(:tags (matins epiphanytide epiphany-day)
   :latin
   "Hostis Heródes ímpie,\n\
Christum veníre quid times?\n\
Non éripit mortália,\n\
Qui regna dat cæléstia.\n\
\n\
Ibant magi, quam víderant,\n\
Stellam sequéntes prǽviam:\n\
Lumen requírunt lúmine:\n\
Deum faténtur múnere.\n\
\n\
Lavácra puri gúrgitis\n\
Cæléstis Agnus áttigit:\n\
Peccáta, quæ non détulit,\n\
Nos abluéndo sústulit.\n\
\n\
Novum genus poténtiæ:\n\
Aquæ rubéscunt hýdriæ,\n\
Vinúmque jussa fúndere,\n\
Mutávit unda oríginem.\n\
\n\
Jesu, tibi sit glória,\n\
Qui apparuísti géntibus,\n\
Cum Patre, et almo Spíritu,\n\
In sempitérna sǽcula.\n\
Amen."
   :translation-meters ((do . "L.M."))
   :translations
   ((do .
     "Why, impious Herod, vainly fear\n\
That Christ the Saviour cometh here?\n\
He takes no earthly realms away\n\
Who gives the crown that lasts for aye.\n\
\n\
The eastern sages saw from far\n\
And followed on His guiding star;\n\
By light their way to Light they trod,\n\
And by their gifts confessed their God.\n\
\n\
Within the Jordan's sacred flood\n\
The heavenly Lamb in meekness stood,\n\
That He, to whom no sin was known,\n\
Might cleanse His people from their own.\n\
\n\
And oh, what miracle divine,\n\
When water reddened into wine!\n\
He spake the word, and forth it flowed\n\
In streams that nature ne'er bestowed.\n\
\n\
All glory, Jesu, be to Thee\n\
For this Thy glad Epiphany:\n\
Whom with the Father we adore,\n\
And Holy Ghost, for evermore.\n\
Amen."))))

;;;; Commune Sanctorum hymns

;;; ─── Aeterna Christi munera — Apostolorum (C1 Apostles Matins) ────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'aeterna-christi-munera-apostolorum
 '(:tags (matins sanctorum)
   :latin
   "Ætérna Christi múnera,\n\
Apostolórum glóriam,\n\
Palmas et hymnos débitos\n\
Lætis canámus méntibus.\n\
\n\
Ecclesiárum Príncipes,\n\
Belli triumpháles duces,\n\
Cæléstis aulæ mílites,\n\
Et vera mundi lúmina.\n\
\n\
Devóta Sanctórum fides,\n\
Invícta spes credéntium,\n\
Perfécta Christi cáritas\n\
Mundi tyránnum cónterit.\n\
\n\
In his Patérna glória,\n\
In his triúmphat Fílius,\n\
In his volúntas Spíritus,\n\
Cælum replétur gáudio.\n\
\n\
Patri, simúlque Fílio,\n\
Tibíque Sancte Spíritus,\n\
Sicut fuit, sit júgiter\n\
Sæclum per omne glória.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt .
     "The eternal gifts of Christ the King,\n\
The Apostles' glory, let us sing;\n\
And all, with hearts of gladness, raise\n\
Due hymns of thankful love and praise.\n\
\n\
For they the Church's princes are,\n\
Triumphant leaders in the war,\n\
In heavenly courts a warrior band,\n\
True lights to lighten every land.\n\
\n\
Theirs is the steadfast faith of Saints,\n\
And hope that never yields nor faints,\n\
And love of Christ in perfect glow\n\
That lays the prince of this world low.\n\
\n\
In them the Father's glory shone,\n\
In them the will of God the Son,\n\
In them exults the Holy Ghost,\n\
Through them rejoice the heavenly host.\n\
\n\
To Thee, Redeemer, now we cry,\n\
That Thou wouldst join to them on high\n\
Thy servants, who this grace implore,\n\
For ever and for evermore.\n\
Amen."))))

;;; ─── Christo profusum sanguinem (C3 Many Martyrs Matins) ──────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'christo-profusum-sanguinem
 '(:tags (matins sanctorum)
   :latin
   "Christo profúsum sánguinem,\n\
Et Mártyrum victórias,\n\
Dignámque cælo láuream\n\
Lætis sequámur vócibus.\n\
\n\
Terróre victo sǽculi,\n\
Pœnísque spretis córporis,\n\
Mortis sacræ compéndio\n\
Vitam beátam póssident.\n\
\n\
Tradúntur igni Mártyres,\n\
Et bestiárum déntibus;\n\
Armáta sævit úngulis\n\
Tortóris insáni manus.\n\
\n\
Nudáta pendent víscera,\n\
Sanguis sacrátus fúnditur;\n\
Sed pérmanent immóbiles,\n\
Vitæ perénnis grátia.\n\
\n\
Te nunc, Redémptor, quǽsumus,\n\
Ut mártyrum consórtio\n\
Jungas precántes sérvulos\n\
In sempitérna sǽcula.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt .
     "The martyr's blood for Christ outpoured,\n\
The martyrs' triumphs let us sing;\n\
The garland worthy heaven's reward,\n\
With joyful voices echoing.\n\
\n\
They conquered all the fears of earth,\n\
Nor recked they of the body's pain;\n\
Through blessed death they won new birth,\n\
And life in bliss for aye to reign.\n\
\n\
To flames the Martyrs were consigned,\n\
And torn by teeth of savage beasts;\n\
With cruel claws of every kind\n\
Were armed the hands of torturing priests.\n\
\n\
Their naked limbs were hung on high,\n\
Their sacred blood was shed amain;\n\
Yet they remained unmoved thereby,\n\
By grace of life that doth not wane.\n\
\n\
Thee, now, Redeemer, we entreat,\n\
Among thy Martyrs grant a place\n\
To us thy suppliants at thy feet,\n\
Through everlasting years of grace.\n\
Amen."))))

;;; ─── Iste Confessor (C4/C5 Confessor Matins) ─────────────────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'iste-confessor
 '(:tags (matins sanctorum)
   :latin
   "Iste Conféssor Dómini, coléntes\n\
Quem pie laudant pópuli per orbem,\n\
Hac die lætus méruit beátas\n\
Scándere sedes.\n\
\n\
Qui pius, prudens, húmilis, pudícus,\n\
Sóbriam duxit sine labe vitam,\n\
Donec humános animávit auræ\n\
Spíritus artus.\n\
\n\
Cujus ob præstans méritum, frequénter,\n\
Ægra quæ passim jacuére membra,\n\
Víribus morbi dómitis, salúti\n\
Restituúntur.\n\
\n\
Noster hinc illi chorus obsequéntem\n\
Cóncinit laudem celebrésque palmas,\n\
Ut piis ejus précibus juvémur\n\
Omne per ævum.\n\
\n\
Sit salus illi, decus atque virtus,\n\
Qui, super cæli sólio corúscans,\n\
Tótius mundi sériem gubérnat,\n\
Trinus et unus.\n\
Amen."
   :translation-meters ((britt . "11. 11. 11. 5."))
   :translations
   ((britt .
     "This the Confessor of the Lord, whose triumph\n\
Now all the faithful celebrate, with gladness\n\
On this feast day year by year receiving\n\
Worthy the glory.\n\
\n\
Saintly and prudent, modest in behavior,\n\
Peaceful and sober, chaste was he, and lowly,\n\
While that life's vigor, coursing through his members,\n\
Quickened his being.\n\
\n\
Sick ones of old time, to his tomb repairing,\n\
Sorely by ailments manifold afflicted,\n\
Oft-times have won the health for which they pleaded,\n\
Healed by his merits.\n\
\n\
Whence we in chorus gladly do him honor,\n\
Chanting his praises with devout affection,\n\
That in his merits we may have a portion,\n\
Now and for ever.\n\
\n\
His be the glory, power, and salvation,\n\
Who over all things reigneth in the highest,\n\
Earth's mighty fabric ruling and directing,\n\
Onely and Trinal.\n\
Amen."))))

;;; ─── Virginis Proles (C6 Virgin Martyr Matins) ───────────────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'virginis-proles
 '(:tags (matins sanctorum)
   :latin
   "Vírginis Proles Opiféxque Matris,\n\
Virgo quem gessit, peperítque Virgo:\n\
Vírginis partos cánimus decóra\n\
Morte triúmphos.\n\
\n\
Hæc enim palmæ dúplicis beáta\n\
Sorte, dum gestit frágilem domáre\n\
Córporis sexum, dómuit cruéntum\n\
Cæde tyránnum.\n\
\n\
Unde nec mortem, nec amíca mortis\n\
Mille pœnárum génera expavéscens,\n\
Sánguine effúso méruit serénum\n\
Scándere cælum.\n\
\n\
Hujus orátu, Deus alme, nobis\n\
Débitas pœnas scélerum remítte;\n\
Ut tibi puro resonémus almum\n\
Péctore carmen.\n\
\n\
Sit decus Patri, genitǽque Proli,\n\
Et tibi, compar utriúsque virtus,\n\
Spíritus semper, Deus unus, omni\n\
Témporis ævo.\n\
Amen."
   :translation-meters ((britt . "11. 11. 11. 5."))
   :translations
   ((britt .
     "Son of a Virgin, Maker of thy Mother,\n\
Thou, Rod of Jesse, whom the Virgin bore,\n\
While yet in her was virginity kept spotless,\n\
We sing thy triumphs in a virgin's death.\n\
\n\
Doubly blest she with the palms of glory,\n\
For while she strove to curb the weaker body,\n\
She overcame the blood-stained foe, and triumphed\n\
In her own slaughter.\n\
\n\
Neither death itself, nor death's companion torments,\n\
Thousand forms of cruelty could dismay her;\n\
And by her blood outpoured she earned the glory\n\
Of heaven's portal.\n\
\n\
By this virgin's prayer, O God almighty,\n\
Free us from the punishment we merit;\n\
That with pure heart we may to thee be singing\n\
Songs everlasting.\n\
\n\
To the Father, glory, and the Son begotten,\n\
Equal glory, Spirit, unto Thee be given,\n\
Power coeternal, Godhead undivided,\n\
Through every age.\n\
Amen."))))

;;; ─── Fortem virili pectore (C7 Holy Women Matins) ─────────────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'fortem-virili-pectore
 '(:tags (matins sanctorum)
   :latin
   "Fortem viríli péctore\n\
Laudémus omnes féminam,\n\
Quæ sanctitátis glória\n\
Ubíque fulget ínclita.\n\
\n\
Hæc sancto amóre sáucia,\n\
Dum mundi amórem nóxium\n\
Horréscit, ad cæléstia\n\
Iter perégit árduum.\n\
\n\
Carnem domans jejúniis,\n\
Dulcíque mentem pábulo\n\
Oratiónis nútriens,\n\
Cæli potítur gáudiis.\n\
\n\
Rex Christe, virtus fórtium,\n\
Qui magna solus éfficis,\n\
Hujus precátu, quǽsumus,\n\
Audi benígnus súpplices.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc, et per omne sǽculum.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt .
     "With manly heart we praise aloud\n\
This woman who for glory shone,\n\
Whose holiness throughout the world\n\
Is celebrated and well known.\n\
\n\
Wounded with love of God most high,\n\
She shrank from earthly love's allure,\n\
And, treading hard the heavenward way,\n\
Won entrance to the realms secure.\n\
\n\
Her flesh she tamed with fasting hard,\n\
Her mind she nourished with the sweet\n\
And sacred food of prayer, and thus\n\
Attained to joys of heaven's seat.\n\
\n\
O Christ the King, the strength of those\n\
Who strive, who dost great deeds alone,\n\
By this saint's prayers we beg of thee,\n\
Hear us who humbly seek thy throne.\n\
\n\
To God the Father glory be,\n\
And to his sole-begotten Son,\n\
With God the Holy Paraclete,\n\
Both now and evermore. Amen."))))

;;;; Commune Non-Matins Hymns

;;; ─── Exsultet orbis gaudiis (C1 Apostles Vespers/Lauds) ────────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'exsultet-orbis-gaudiis
 '(:tags (vespers lauds sanctorum)
   :latin
   "Exsúltet orbis gáudiis:\n\
Cælum resúltet láudibus:\n\
Apostolórum glóriam\n\
Tellus et astra cóncinunt.\n\
\n\
Vos sæculórum júdices,\n\
Et vera mundi lúmina:\n\
Votis precámur córdium,\n\
Audíte voces súpplicum.\n\
\n\
Qui templa cæli cláuditis,\n\
Serásque verbo sólvitis,\n\
Nos a reátu nóxios\n\
Solvi jubéte, quǽsumus.\n\
\n\
Præcépta quorum prótinus\n\
Languor salúsque séntiunt:\n\
Sanáte mentes lánguidas:\n\
Augéte nos virtútibus.\n\
\n\
Ut, cum redíbit árbiter\n\
In fine Christus sǽculi,\n\
Nos sempitérni gáudii\n\
Concédat esse cómpotes.\n\
\n\
Patri, simúlque Fílio,\n\
Tibíque Sancte Spíritus,\n\
Sicut fuit, sit júgiter\n\
Sæclum per omne glória.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt .
     "Now let the earth with joy resound,\n\
And heaven the chant re-echo round;\n\
Nor heaven nor earth too high can raise\n\
The great Apostles' glorious praise.\n\
\n\
O ye who, throned in glory dread,\n\
Shall judge the living and the dead,\n\
Lights of the world forevermore!\n\
To you the suppliant prayer we pour.\n\
\n\
Ye close the sacred gates on high;\n\
At your command apart they fly:\n\
Oh! loose for us the guilty chain\n\
We strive to break, and strive in vain.\n\
\n\
Sickness and health your voice obey;\n\
At your command they go or stay:\n\
From sin's disease our souls restore;\n\
In good confirm us more and more.\n\
\n\
So when the world is at its end,\n\
And Christ to judgement shall descend,\n\
May we be called those joys to see\n\
Prepared from all eternity.\n\
\n\
Praise to the Father, with the Son,\n\
And Holy Spirit, Three in One;\n\
As ever was in ages past,\n\
And so shall be while ages last.\n\
Amen."))))

;;; ─── Invicte Martyr unicum (C2 One Martyr Lauds) ───────────────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'invicte-martyr-unicum
 '(:tags (lauds sanctorum)
   :latin
   "Invícte Martyr, únicum\n\
Patris secútus Fílium,\n\
Victis triúmphas hóstibus,\n\
Victor fruens cæléstibus.\n\
\n\
Tui precátus múnere\n\
Nostrum reátum dílue,\n\
Arcens mali contágium,\n\
Vitæ repéllens tǽdium.\n\
\n\
Solúta sunt jam víncula\n\
Tui sacráti córporis:\n\
Nos solve vinclis sǽculi,\n\
Dono supérni Núminis.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc, et per omne sǽculum.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt .
     "Martyr of God, whose strength was steeled\n\
To follow close God's only Son,\n\
Well didst thou brave thy battlefield,\n\
And well thy heavenly bliss was won!\n\
\n\
Now join thy prayers with ours, who pray\n\
That God may pardon us and bless;\n\
For prayer keeps evil's plague away,\n\
And draws from life its weariness.\n\
\n\
Long, long ago, were loosed the chains\n\
That held thy body once in thrall;\n\
For us how many a bond remains!\n\
O love of God release us all.\n\
\n\
All praise to God the Father be,\n\
All praise to thee, Eternal Son;\n\
All praise, O Holy Ghost, to thee,\n\
While never-ending ages run.\n\
Amen."))))

;;; ─── Sanctorum meritis (C3 Many Martyrs Vespers) ───────────────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'sanctorum-meritis
 '(:tags (vespers sanctorum)
   :latin
   "Sanctórum méritis ínclita gáudia\n\
Pangámus, sócii, géstaque fórtia:\n\
Gliscens fert ánimus prómere cántibus\n\
Victórum genus óptimum.\n\
\n\
Hi sunt, quos fátue mundus abhórruit;\n\
Hunc fructu vácuum, flóribus áridum\n\
Contempsére tui nóminis ásseclæ\n\
Jesu, Rex bone cǽlitum.\n\
\n\
Hi pro te fúrias, atque minas truces\n\
Calcárunt hóminum, sǽvaque vérbera:\n\
His cessit lácerans fórtiter úngula,\n\
Nec carpsit penetrália.\n\
\n\
Cædúntur gládiis more bidéntium:\n\
Non murmur résonat, non quærimónia;\n\
Sed corde impávido mens bene cónscia\n\
Consérvat patiéntiam.\n\
\n\
Quæ vox, quæ póterit lingua retéxere,\n\
Quæ tu Martýribus múnera prǽparas?\n\
Rubri nam flúido sánguine fúlgidis\n\
Cingunt témpora láureis.\n\
\n\
Te, summa o Déitas, únaque póscimus;\n\
Ut culpas ábigas, nóxia súbtrahas,\n\
Des pacem fámulis; ut tibi glóriam,\n\
Annórum in sériem, canant.\n\
Amen."
   :translation-meters ((britt . "12. 12. 12. 8."))
   :translations
   ((britt .
     "Sing, O sons of the Church sounding the martyrs' praise!\n\
God's true soldiers applaud, who, in their weary days,\n\
Won bright trophies of good, glad be the voice ye raise,\n\
While these heroes of Christ ye sing!\n\
\n\
They, while yet in the world were by the world abhorred;\n\
Felt how fading the joys, fleeting the wealth it stored;\n\
Spurned all pleasure for thee, and at thy call, O Lord,\n\
Came forth strong in thy name, as King.\n\
\n\
Lord, how bravely they bore fury and pain for thee!\n\
Scourge, rod, sword, and the rack strongly endured; but free\n\
Sang out, bold in thy love, longing on high to be;\n\
Earth's might never their souls could bend.\n\
\n\
While they, shedding their blood, victims for Jesus fell,\n\
No sound out of their lips came of their throes to tell;\n\
Bowed low, patient and meek, loving the Lord so well,\n\
Turned they still to the Christ, their friend.\n\
\n\
What joys, bright with the blood shed for thy love they share,\n\
Those brave martyrs of thine crowned with thy laurels rare;\n\
Man's tongue never can tell, never can half declare,\n\
How pure now is their bliss above!\n\
\n\
Yet we, Father on high, God of eternal might,\n\
Lift weak voices in prayer asking for peace and light;\n\
Cleanse thou out of our hearts every stain and blight,\n\
So our songs may be songs of love.\n\
Amen."))))

;;; ─── Rex gloriosae Martyrum (C3 Many Martyrs Lauds) ────────────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'rex-gloriosae-martyrum
 '(:tags (lauds sanctorum)
   :latin
   "Rex glorióse Mártyrum,\n\
Coróna confiténtium,\n\
Qui respuéntes térrea\n\
Perdúcis ad cæléstia:\n\
\n\
Aurem benígnam prótinus\n\
Inténde nostris vócibus:\n\
Trophǽa sacra pángimus:\n\
Ignósce quod delíquimus.\n\
\n\
Tu vincis inter Mártyres\n\
Parcísque Confessóribus:\n\
Tu vince nostra crímina,\n\
Largítor indulgéntiæ.\n\
\n\
Deo Patri sit glória,\n\
Ejúsque soli Fílio,\n\
Cum Spíritu Paráclito,\n\
Nunc, et per omne sǽculum.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt .
     "O glorious King of martyr hosts,\n\
Thou crown that each confessor boasts,\n\
Who leadest to celestial day\n\
Those who have cast earth's joys away:\n\
\n\
Thine ear in mercy, Saviour, lend,\n\
While unto thee our prayers ascend;\n\
And as we count their triumphs won,\n\
Forgive the sins that we have done.\n\
\n\
Martyrs in thee their triumphs gain,\n\
From thee confessors grace obtain;\n\
O'ercome in us the lust of sin,\n\
That we thy pardoning love may win.\n\
\n\
To thee who, dead, again dost live,\n\
All glory, Lord, thy people give;\n\
All glory, as is ever meet,\n\
To Father and to Paraclete.\n\
Amen."))))

;;; ─── Jesu Redemptor omnium perpes (C4 Confessor Bishop Lauds) ──────────────
;; English: Britt translation.
;; NB: Distinguished from the Christmas "Jesu Redemptor omnium" by longer incipit.

(bcp-roman-hymnal-register
 'jesu-redemptor-omnium-perpes
 '(:tags (lauds sanctorum)
   :latin
   "Jesu Redémptor ómnium,\n\
Perpes coróna Prǽsulum,\n\
In hac die cleméntius\n\
Indúlgeas precántibus.\n\
\n\
Tui sacri qua nóminis\n\
Conféssor almus cláruit:\n\
Hujus celébrat ánnua\n\
Devóta plebs solémnia.\n\
\n\
Qui rite mundi gáudia\n\
Hujus cadúca réspuens,\n\
Æternitátis prǽmio\n\
Potítur inter Ángelos.\n\
\n\
Hujus benígnus ánnue\n\
Nobis sequi vestígia:\n\
Hujus precátu, sérvulis\n\
Dimítte noxam críminis.\n\
\n\
Sit Christe, Rex piíssime,\n\
Tibi, Patríque glória,\n\
Cum Spíritu Paráclito,\n\
Nunc, et per omne sǽculum.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt .
     "Jesu, the world's Redeemer, O hear;\n\
thy bishops' fadeless crown, draw near:\n\
Accept with gentlest love today\n\
The prayers and praises that we pay.\n\
\n\
The meek confessor of thy name\n\
Today attained a glorious fame;\n\
Whose yearly feast, in solemn state,\n\
Thy faithful people celebrate.\n\
\n\
The world and all its boasted good,\n\
As vain and passing, he eschewed;\n\
And therefore with angelic bands,\n\
In endless joy forever stands.\n\
\n\
Grant then that we, most gracious God,\n\
May follow in the steps he trod:\n\
And, at his prayer, thy servants free\n\
From stain of all iniquity.\n\
\n\
To thee, O Christ, our loving King,\n\
All glory, praise, and thanks we bring:\n\
All glory, as is ever meet,\n\
To Father and to Paraclete.\n\
Amen."))))

;;; ─── Jesu corona celsior (C5 Confessor non-Bishop Lauds) ───────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'jesu-corona-celsior
 '(:tags (lauds sanctorum)
   :latin
   "Jesu, coróna célsior,\n\
Et véritas sublímior,\n\
Qui confiténti sérvulo\n\
Reddis perénne prǽmium:\n\
\n\
Da supplicánti cœ́tui,\n\
Hujus rogátu, nóxii\n\
Remissiónem críminis,\n\
Rumpéndo nexum vínculi.\n\
\n\
Anni revérso témpore,\n\
Dies refúlsit lúmine,\n\
Quo Sanctus hic de córpore\n\
Migrávit inter sídera.\n\
\n\
Hic vana terræ gáudia,\n\
Et luculénta prǽdia,\n\
Pollúta sorde députans,\n\
Ovans tenet cæléstia.\n\
\n\
Te, Christe, Rex piíssime,\n\
Hic confiténdo júgiter,\n\
Calcávit artes dǽmonum,\n\
Sævúmque avérni príncipem.\n\
\n\
Virtúte clarus, et fide,\n\
Confessióne sédulus,\n\
Jejúna membra déferens,\n\
Dapes supérnas óbtinet.\n\
\n\
Proínde te piíssime\n\
Precámur omnes súpplices:\n\
Nobis ut hujus grátia\n\
Pœnas remíttas débitas.\n\
\n\
Patri perénnis glória,\n\
Natóque Patris único,\n\
Sanctóque sit Paráclito,\n\
Per omne semper sǽculum.\n\
Amen."
   :translation-meters ((britt . "C.M."))
   :translations
   ((britt .
     "Jesu, eternal truth sublime,\n\
Through endless years the same!\n\
Thou crown of those who through all time\n\
Confess thy holy name:\n\
\n\
Thy suppliant people, through the prayer\n\
Of thy blest saint, forgive;\n\
For his dear sake, thy wrath forbear,\n\
And bid our spirits live.\n\
\n\
Again returns the sacred day,\n\
With heavenly glory bright,\n\
Which saw him go upon his way\n\
Into the realms of light.\n\
\n\
All objects of our vain desire,\n\
All earthly joys and gains,\n\
To him were but as filthy mire;\n\
And now with thee he reigns.\n\
\n\
Thee, Jesu, his all-gracious Lord,\n\
Confessing to the last,\n\
He trod beneath him Satan's fraud,\n\
And stood forever fast.\n\
\n\
In holy deeds of faith and love,\n\
In fastings and in prayers,\n\
His days were spent; and now above\n\
Thy heavenly feast he shares.\n\
\n\
Then, for his sake thy wrath lay by,\n\
And hear us while we pray;\n\
And pardon us, O thou most high,\n\
On this his festal day.\n\
\n\
All glory to the Father be;\n\
And sole Incarnate Son;\n\
Praise, holy Paraclete, to thee;\n\
While endless ages run.\n\
Amen."))))

;;; ─── Jesu corona Virginum (C6 Virgins Vespers/Lauds) ───────────────────────
;; English: Britt translation.

(bcp-roman-hymnal-register
 'jesu-corona-virginum
 '(:tags (vespers lauds sanctorum)
   :latin
   "Jesu, coróna Vírginum,\n\
Quem Mater illa cóncipit\n\
Quæ sola Virgo párturit,\n\
Hæc vota clemens áccipe:\n\
\n\
Qui pergis inter lília\n\
Septus choréis Vírginum,\n\
Sponsus decórus glória\n\
Sponsísque reddens prǽmia.\n\
\n\
Quocúmque tendis, Vírgines\n\
Sequúntur, atque láudibus\n\
Post te canéntes cúrsitant,\n\
Hymnósque dulces pérsonant;\n\
\n\
Te deprecámur súpplices,\n\
Nostris ut addas sénsibus\n\
Nescíre prorsus ómnia\n\
Corruptiónis vúlnera.\n\
\n\
Virtus, honor, laus, glória\n\
Deo Patri cum Fílio,\n\
Sancto simul Paráclito,\n\
In sæculórum sǽcula.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt .
     "Jesu, the virgins' crown, do thou\n\
Accept us as in prayer we bow;\n\
Born of that Virgin, whom alone\n\
The mother and the maid we own.\n\
\n\
Amongst the lilies thou dost feed,\n\
By virgin choirs accompanied;\n\
With glory decked, the spotless brides\n\
Whose bridal gifts thy love provides.\n\
\n\
They, wheresoe'er thy footsteps bend,\n\
With hymns and praises still attend:\n\
In blessèd troops they follow thee,\n\
With dance, and song, and melody.\n\
\n\
We pray thee therefore to bestow\n\
Upon our senses here below\n\
Thy grace, that so we may endure\n\
From taint of all corruption pure.\n\
\n\
All laud to God the Father be,\n\
All praise, eternal Son, to thee;\n\
All glory as is ever meet,\n\
To God, the holy Paraclete.\n\
Amen."))))

;;; ═══════════════════════════════════════════════════════════════════════════
;;; Proprium Sanctorum — Matins hymns for feasts with :commune nil
;;; ═══════════════════════════════════════════════════════════════════════════

;;; ─── May 3: Inventione Sanctæ Crucis (= Passiontide Matins hymn) ───────

(bcp-roman-hymnal-register
 'pange-lingua-gloriosi
 '(:tags (matins passiontide holy-cross passion cross)
   :latin "\
Pange, lingua, gloriósi\n\
Láuream certáminis,\n\
Et super Crucis trophǽo\n\
Dic triúmphum nóbilem,\n\
Quáliter Redémptor orbis\n\
Immolátus vícerit.\n\
\n\
De paréntis protoplásti\n\
Fraude Factor cóndolens,\n\
Quando pomi noxiális\n\
In necem morsu ruit,\n\
Ipse lignum tunc notávit,\n\
Damna ligni ut sólveret.\n\
\n\
Hoc opus nostræ salútis\n\
Ordo depopóscerat,\n\
Multifórmis proditóris\n\
Ars ut artem fálleret,\n\
Et medélam ferret inde,\n\
Hostis unde lǽserat.\n\
\n\
Quando venit ergo sacri\n\
Plenitúdo témporis,\n\
Missus est ab arce Patris\n\
Natus, orbis Cónditor,\n\
Atque ventre virgináli\n\
Carne amíctus pródiit.\n\
\n\
Glória et honor Deo\n\
Usquequáque Altíssimo,\n\
Una Patri, Filióque;\n\
Inclyto Paráclito:\n\
Cui laus est et potéstas,\n\
Per ætérna sǽcula.\n\
Amen."
   :translation-meters ((britt . "87. 87. 87."))
   :translations
   ((britt . "\
Sing, my tongue, the Saviour's glory,\n\
Of his flesh the mystery sing;\n\
Of the Blood, all price exceeding,\n\
Shed by our immortal King,\n\
Destined, for the world's redemption,\n\
From a noble womb to spring.\n\
\n\
Of a pure and spotless Virgin\n\
Born for us on earth below,\n\
He, as Man, with man conversing,\n\
Stayed, the seeds of truth to sow;\n\
Then he closed in solemn order\n\
Wondrously his life of woe.\n\
\n\
On the night of that last supper\n\
Seated with his chosen band,\n\
He the Paschal victim eating,\n\
First fulfils the law's command;\n\
Then as food to all his brethren\n\
Gives himself with his own hand.\n\
\n\
Word made flesh, the bread of nature\n\
By his word to flesh he turns;\n\
Wine into his Blood he changes:\n\
What though sense no change discerns?\n\
Only be the heart in earnest,\n\
Faith her lesson quickly learns.\n\
\n\
Glory let us give, and blessing\n\
To the Father and the Son;\n\
Honour, might, and praise addressing,\n\
While eternal ages run;\n\
Ever too his love confessing,\n\
Who from both with both is one.\n\
Amen."))))

;;; ─── May 8: Apparitione S. Michaëlis Archangeli ────────────────────────

(bcp-roman-hymnal-register
 'te-splendor-et-virtus-patris
 '(:tags (st-michael)
   :latin "\
Te, splendor et virtus Patris,\n\
Te vita, Jesu, córdium,\n\
Ab ore qui pendent tuo,\n\
Laudámus inter Angelos.\n\
\n\
Tibi mille densa míllium\n\
Ducum coróna mílitat;\n\
Sed éxplicat victor Crucem\n\
Míchaël salútis sígnifer.\n\
\n\
Dracónis hic dirum caput\n\
In ima pellit tártara,\n\
Ducémque cum rebéllibus\n\
Cælésti ab arce fúlminat.\n\
\n\
Contra ducem supérbiæ\n\
Sequámur hunc nos príncipem,\n\
Ut detur ex Agni throno\n\
Nobis coróna glóriæ.\n\
\n\
Deo Patri sit glória,\n\
Qui, quos redémit Fílius,\n\
Et Sanctus unxit Spíritus,\n\
Per Angelos custódiat.\n\
Amen."
   :translation-meters ((britt . "87. 87. 87."))
   :translations
   ((britt . "\
Thee, O splendour, thee, O power,\n\
Thee, O life of hearts, we praise;\n\
We who from thy lips dependent,\n\
Mid the Angels songs do raise;\n\
Thousand thousands round thee standing,\n\
Captain chiefs in war's array.\n\
\n\
But the warrior prince of heaven,\n\
Michael, 'tis who bears the palm;\n\
He unfurls the cross victorious,\n\
Standard of our saving calm;\n\
He the dragon's head infernal\n\
Hurtles down to deepest realm.\n\
\n\
He from heaven's exalted citadel\n\
Flings the rebel chief below,\n\
With the leaders of his legions,\n\
Lightning-smitten, down they go;\n\
Against the prince of pride we follow\n\
This our chief, to lay him low.\n\
\n\
That from the throne of the Lamb eternal\n\
May be given the crown of glory;\n\
Glory to God the Father be,\n\
Who, whom the Son redeemed in love,\n\
And the Spirit sanctified,\n\
By Angels guards from above.\n\
Amen."))))

;;; ─── Jun 24: Nativitate S. Joannis Baptistæ ───────────────────────────

(bcp-roman-hymnal-register
 'antra-deserti
 '(:tags (st-john-baptist-nativity)
   :latin "\
Antra desérti téneris sub annis,\n\
Cívium turmas fúgiens, petísti,\n\
Ne levi posses maculáre vitam\n\
Crímine linguæ.\n\
\n\
Prǽbuit durum tégumen camélus\n\
Artubus sacris, stróphium bidéntes;\n\
Cui latex haustum, sociáta pastum\n\
Mella locústis.\n\
\n\
Céteri tantum cecinére Vatum\n\
Corde præságo jubar affutúrum;\n\
Tu quidem mundi scelus auferéntem\n\
Indice prodis.\n\
\n\
Non fuit vasti spátium per orbis\n\
Sánctior quisquam génitus Joánne,\n\
Qui nefas sæcli méruit lavántem\n\
Tíngere lymphis.\n\
\n\
Sit decus Patri, genitǽque Proli,\n\
Et tibi, compar utriúsque virtus,\n\
Spíritus semper, Deus unus omni\n\
Témporis ævo.\n\
Amen."
   :translation-meters ((britt . "11. 11. 11. 5."))
   :translations
   ((britt . "\
Midst the desert caves, while yet a stripling,\n\
From the haunts of men thy footsteps straying,\n\
Lest a word unkind should stain thy pure lips,\n\
Silence thou didst cherish.\n\
\n\
Camel's hair around thy members girded,\n\
And a belt of sheep-skin, were thy vesture;\n\
Water was thy drink, and wild-born locusts\n\
Mixed with honey.\n\
\n\
Other prophets only dimly saw him,\n\
In their hearts foretelling his appearing;\n\
Thou didst see him, Lamb of God, and show him\n\
With thy finger.\n\
\n\
Holier birth hath none of woman's children;\n\
Greater prophet none in earth's wide compass;\n\
He was worthy him who cleansed the nations\n\
Dip in waters.\n\
\n\
Glory to the Father, and the Son, who\n\
Rose from death, and thee, O Holy Spirit,\n\
Now and evermore be praise and honour\n\
Through the ages.\n\
Amen."))))

;;; ─── Jul 1: Pretiosissimi Sanguinis D.N.J.C. ──────────────────────────

(bcp-roman-hymnal-register
 'ira-justa-conditoris
 '(:tags (passion)
   :latin "\
Ira justa Conditóris,\n\
Imbre aquárum víndice,\n\
Criminósum mersit orbem\n\
Noë in arca sóspite:\n\
Mira tandem vis amóris\n\
Lavit orbem sánguine.\n\
\n\
Tam salúbri terra felix\n\
Irrigáta plúvia,\n\
Ante spinas quæ scatébat,\n\
Germinávit flósculos;\n\
Inque néctaris sapórem\n\
Transiére absýnthia.\n\
\n\
Triste prótinus venénum\n\
Dirus anguis pósuit,\n\
Et cruénta belluárum\n\
Désiit ferócia:\n\
Mitis Agni vulneráti\n\
Hæc fuit victória.\n\
\n\
O sciéntiæ supérnæ\n\
Altitúdo impérvia!\n\
O suávitas benígni\n\
Prædicánda péctoris!\n\
Servus erat morte dignus,\n\
Rex luit pœnam óptimus.\n\
\n\
Quando culpis provocámus\n\
Ultiónem júdicis,\n\
Tunc loquéntis protegámur\n\
Sánguinis præséntia;\n\
Ingruéntium malórum\n\
Tunc recédant ágmina.\n\
\n\
Te redémptus laudet orbis\n\
Grata servans múnera,\n\
O salútis sempitérnæ\n\
Dux et Auctor ínclite,\n\
Qui tenes beáta regna\n\
Cum Parénte et Spíritu.\n\
Amen."
   :translation-meters ((britt . "888. 888."))
   :translations
   ((britt . "\
The just Creator's wrath once fell\n\
On guilty man condemned to die;\n\
Beneath the flood's avenging swell\n\
All flesh was doomed, save Noë nigh;\n\
But Love at last, by wondrous power,\n\
In Blood hath washed the world's dark hour.\n\
\n\
The earth, refreshed by saving rain,\n\
That once with thorns was overgrown,\n\
Now blossoms forth in beauty's train,\n\
And bitter things to sweet are grown;\n\
The serpent's deadly venom dies,\n\
The fierceness of the beast now lies.\n\
\n\
O depth of knowledge, passing height!\n\
O sweetness of a loving breast!\n\
The slave deserved death's bitter blight,\n\
The noblest King paid all the rest;\n\
When by our sins we rouse the Judge,\n\
The speaking Blood doth intercede.\n\
\n\
Let all the ransomed world give praise,\n\
Preserving gifts of grace divine;\n\
O glorious Author of our days,\n\
Who holdest blest the realms that shine\n\
With Father and with Spirit blest,\n\
Through endless ages, ever rest.\n\
Amen."))))

;;; ─── Aug 6: Transfiguratione D.N.J.C. ─────────────────────────────────

(bcp-roman-hymnal-register
 'quicumque-christum-quaeritis
 '(:tags (transfiguration)
   :latin "\
Quicúmque Christum quǽritis,\n\
Oculos in altum tóllite:\n\
Illic licébit vísere\n\
Signum perénnis glóriæ.\n\
\n\
Illústre quiddam cérnimus,\n\
Quod nésciat finem pati,\n\
Sublíme, celsum, intérminum,\n\
Antíquius cælo et chao.\n\
\n\
Hic ille Rex est géntium\n\
Populíque Rex judáici,\n\
Promíssus Abrahæ patri\n\
Ejúsque in ævum sémini.\n\
\n\
Hunc, et prophétis téstibus\n\
Iisdémque signatóribus,\n\
Testátor et Pater jubet\n\
Audíre nos et crédere.\n\
\n\
Jesu, tibi sit glória,\n\
Qui te revélas párvulis,\n\
Cum Patre, et almo Spíritu,\n\
In sempitérna sǽcula.\n\
Amen."
   :translation-meters ((britt . "C.M."))
   :translations
   ((britt . "\
All ye who seek a comfort sure\n\
In trouble and distress,\n\
Whatever sorrow vex the mind,\n\
Or guilt the soul oppress;\n\
\n\
Jesus, who gave himself for you\n\
Upon the Cross to die,\n\
Opens to you his sacred Heart;\n\
O, to that Heart draw nigh.\n\
\n\
Ye hear how kindly he invites;\n\
Ye hear his words so blest:\n\
'All ye that labour come to me,\n\
And I will give you rest.'\n\
\n\
O Jesus, joy of saints on high,\n\
The hope of sinners here,\n\
Attracted by those loving words\n\
To thee I lift my prayer.\n\
\n\
To God the Father, and the Son,\n\
All glory, praise be done;\n\
And to the Holy Spirit, praise\n\
While endless ages run.\n\
Amen."))))

;;; ─── Oct 24: S. Raphaëlis Archangeli ────────────────────────────────────

(bcp-roman-hymnal-register
 'christe-sanctorum-decus-angelorum
 '(:tags (sanctorum)
   :latin "\
Christe, sanctórum decus Angelórum,\n\
Gentis humánæ Sator et Redémptor,\n\
Cǽlitum nobis tríbuas beátas\n\
Scándere sedes.\n\
\n\
Angelus nostræ médicus salútis,\n\
Adsit e cælo Ráphaël, ut omnes\n\
Sanet ægrótos, dubiósque vitæ\n\
Dírigat actus.\n\
\n\
Virgo dux pacis Genetríxque lucis,\n\
Et sacer nobis chorus Angelórum\n\
Semper assístat, simul et micántis\n\
Régia cæli.\n\
\n\
Præstet hoc nobis Déitas beáta\n\
Patris, ac Nati, paritérque Sancti\n\
Spíritus, cujus résonat per omnem\n\
Glória mundum.\n\
Amen."
   :translation-meters ((britt . "11. 11. 11. 5."))
   :translations
   ((britt . "\
O Christ, the glory of the Angel choir,\n\
Of man the Maker and Redeemer blest,\n\
Grant us one day to reach the seats of heaven\n\
Among the blessed.\n\
\n\
Send Raphael, the Angel-healer, down,\n\
That he from heaven may heal our every ill,\n\
May guide our doubtful steps aright, and keep\n\
Our lives from evil.\n\
\n\
May Mary, Virgin-guide to paths of peace,\n\
The Mother-source of light, and Angels' band\n\
Attend us ever, and the shining courts\n\
Of heaven guard us.\n\
\n\
This grace on us bestow, O Godhead blest,\n\
Of Father, Son, and Spirit, Love divine,\n\
Whose glory through the universe resounds\n\
For ever. Amen."))))

;;; ─── Mar 19: S. Joseph Sponsi B.M.V. — Matins ──────────────────────────

(bcp-roman-hymnal-register
 'caelitum-joseph-decus
 '(:tags (matins st-joseph)
   :latin "\
Cǽlitum Joseph, decus atque nostræ\n\
Certa spes vitæ, columénque mundi,\n\
Quas tibi læti cánimus, benígnus\n\
Súscipe laudes.\n\
\n\
Te Sator rerum státuit pudícæ\n\
Vírginis sponsum, voluítque Verbi\n\
Te patrem dici, dedit et minístrum\n\
Esse salútis.\n\
\n\
Tu Redemptórem stábulo jacéntem,\n\
Quem chorus Vatum cécinit futúrum,\n\
Aspicis gaudens, humilísque natum\n\
Numen adóras.\n\
\n\
Rex Deus regum, Dominátor orbis,\n\
Cujus ad nutum tremit inferórum\n\
Turba, cui pronus famulátur æther,\n\
Se tibi subdit.\n\
\n\
Laus sit excélsæ Tríadi perénnis,\n\
Quæ tibi præbens súperos honóres,\n\
Det tuis nobis méritis beátæ\n\
Gáudia vitæ.\n\
Amen."
   :translation-meters ((britt . "11. 11. 11. 5."))
   :translations
   ((britt . "\
Joseph, the glory of the court of heaven,\n\
The sure hope of our life, the prop and stay\n\
Of all the world, accept the praise and homage\n\
We gladly pay.\n\
\n\
The Lord of all chose thee to be the husband\n\
Of the chaste Virgin; willed that thou be called\n\
The Word's own father, made thee minister\n\
Of our salvation.\n\
\n\
Thou gazedst on the Redeemer in the manger,\n\
Whom prophets' voices had foretold would come,\n\
And, humbly kneeling, didst adore the Godhead\n\
Of that new-born Babe.\n\
\n\
The King of kings, the Ruler of the nations,\n\
At whose dread nod the hosts of hell do tremble,\n\
Whom heaven obeys with reverence bowing lowly,\n\
Submitted to thee.\n\
\n\
Praise to the exalted Trinity for ever,\n\
Who, granting thee the honours of the blessed,\n\
Through thy dear merits may bestow upon us\n\
The joys of heaven.\n\
Amen."))))

;;; ─── Mar 24: S. Gabrielis Archangeli ───────────────────────────────────

(bcp-roman-hymnal-register
 'christe-sanctorum-gabriel
 '(:tags (sanctorum)
   :latin "\
Christe, sanctórum decus Angelórum,\n\
Gentis humánæ Sator et Redémptor,\n\
Cǽlitum nobis tríbuas beátas\n\
Scándere sedes.\n\
\n\
Angelus fortis Gábriel, ut hostes\n\
Pellat antíquos, et amíca cælo,\n\
Quæ triumphátor státuit per orbem,\n\
Templa revísat.\n\
\n\
Virgo dux pacis, Genitríxque lucis,\n\
Et sacer nobis chorus Angelórum\n\
Semper assístat, simul et micántis\n\
Régia cæli.\n\
\n\
Præstet hoc nobis Déitas beáta\n\
Patris, ac Nati, paritérque Sancti\n\
Spíritus, cujus résonat per omnem\n\
Glória mundum.\n\
Amen."
   :translation-meters ((britt . "11. 11. 11. 5."))
   :translations
   ((britt . "\
O Christ, the glory of the Angel choir,\n\
Of man the Maker and Redeemer blest,\n\
Grant us one day to reach the seats of heaven\n\
Among the blessed.\n\
\n\
Send Gabriel, the Angel strong, to scatter\n\
The ancient foe, and visit graciously\n\
The temples which the Victor hath established\n\
Throughout the world.\n\
\n\
May Mary, Virgin-guide to paths of peace,\n\
The Mother-source of light, and Angels' band\n\
Attend us ever, and the shining courts\n\
Of heaven guard us.\n\
\n\
This grace on us bestow, O Godhead blest,\n\
Of Father, Son, and Spirit, Love divine,\n\
Whose glory through the universe resounds\n\
For ever. Amen."))))

;;; ─── Corpus Christi — Matins ─────────────────────────────────────────

(bcp-roman-hymnal-register
 'sacris-solemniis
 '(:tags (matins corpus-christi)
   :latin "\
Sacris solémniis juncta sint gáudia,\n\
Et ex præcórdiis sonent præcónia;\n\
Recédant vétera, nova sint ómnia,\n\
Corda, voces, et ópera.\n\
\n\
Noctis recólitur cœna novíssima,\n\
Qua Christus créditur agnum et ázyma\n\
Dedísse frátribus, juxta legítima\n\
Priscis indúlta pátribus.\n\
\n\
Post agnum týpicum, explétis épulis,\n\
Corpus Domínicum datum discípulis,\n\
Sic totum ómnibus, quod totum síngulis,\n\
Ejus fatémur mánibus.\n\
\n\
Dedit fragílibus córporis férculum,\n\
Dedit et trístibus sánguinis póculum,\n\
Dicens: Accípite quod trado vásculum;\n\
Omnes ex eo bíbite.\n\
\n\
Sic sacrifícium istud instítuit,\n\
Cujus offícium commítti vóluit\n\
Solis presbýteris, quibus sic cóngruit,\n\
Ut sumant, et dent céteris.\n\
\n\
Panis angélicus fit panis hóminum;\n\
Dat panis cǽlicus figúris términum;\n\
O res mirábilis: mandúcat Dóminum\n\
Pauper, servus et húmilis.\n\
\n\
Te, trina Déitas únaque, póscimus;\n\
Sic nos tu vísita, sicut te cólimus:\n\
Per tuas sémitas duc nos quo téndimus,\n\
Ad lucem quam inhábitas.\n\
Amen."
   :translation-meters ((britt . "66. 66. 66. 8."))
   :translations
   ((britt . "\
At this our solemn feast,\n\
Let holy joys abound,\n\
And from the inmost breast\n\
Let songs of praise resound;\n\
Let ancient rites depart,\n\
And all be new around,\n\
In ev'ry act and voice and heart.\n\
\n\
Remember we that eve,\n\
When, the last supper spread,\n\
Christ, as we all believe,\n\
The lamb, with leavenless bread,\n\
Among his brethren shared,\n\
And thus the law obeyed,\n\
Of old unto their sires declared.\n\
\n\
The typic lamb consumed,\n\
The legal feast complete,\n\
The Lord unto the twelve\n\
His body gave to eat;\n\
The whole to all, no less\n\
The whole to each, did mete\n\
With his own hands, as we confess.\n\
\n\
He gave them, weak and frail,\n\
His flesh, their food to be;\n\
On them, downcast and sad,\n\
His blood bestowed he:\n\
And thus to them he spake,\n\
'Receive this cup from me,\n\
And all of you of this partake.'\n\
\n\
So he this sacrifice\n\
To institute did will,\n\
And charged his priests alone\n\
That office to fulfil:\n\
In them he did confide:\n\
To whom pertaineth still\n\
To take, and to the rest divide.\n\
\n\
Thus angels' bread is made\n\
The bread of man today:\n\
The living bread from heaven\n\
With figures doth away:\n\
O wondrous gift indeed!\n\
The poor and lowly may\n\
Upon their Lord and Master feed.\n\
\n\
O Triune Deity,\n\
To thee we meekly pray,\n\
So mayst thou visit us,\n\
As we our homage pay;\n\
Lead us on thine own paths\n\
To where thou dwell'st in day,\n\
The light wherein thou showest us.\n\
Amen."))))

;;; ─── Sacred Heart — Matins ──────────────────────────────────────────

(bcp-roman-hymnal-register
 'auctor-beate-saeculi
 '(:tags (matins sacred-heart)
   :latin "\
Auctor beáte sǽculi,\n\
Christe, Redémptor ómnium,\n\
Lumen Patris de lúmine,\n\
Deúsque verus de Deo.\n\
\n\
Amor coégit te tuus\n\
Mortále corpus súmere,\n\
Ut novus Adam rédderes,\n\
Quod vetus ille abstúlerat.\n\
\n\
Ille amor, almus ártifex\n\
Terræ marísque, et síderum,\n\
Erráta patrum míserans,\n\
Et nostra rumpens víncula.\n\
\n\
Non Corde discédat tuo\n\
Vis illa amóris íncliti:\n\
Hoc fonte gentes háuriant\n\
Remissiónis grátiam.\n\
\n\
Percússum ad hoc est láncea,\n\
Passúmque ad hoc est vúlnera:\n\
Ut nos laváret sórdibus,\n\
Unda fluénte, et sánguine.\n\
\n\
Jesu, tibi sit glória,\n\
Qui Corde fundis grátiam,\n\
Cum Patre, et almo Spíritu,\n\
In sempitérna sǽcula.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt . "\
O Christ, the world's Creator bright,\n\
Who didst mankind from sin redeem,\n\
Light from the Father's glorious light,\n\
True God of God, in bliss supreme.\n\
\n\
Thy love compelled thee to assume\n\
A mortal body, man to save;\n\
Reversing the old Adam's doom;\n\
Our ransom the new Adam gave.\n\
\n\
That love which gloriously framed all\n\
The earth, the stars, and wondrous sea\n\
Took pity on our parents' fall,\n\
Broke all our bonds and set us free.\n\
\n\
O Saviour, let thy potent love\n\
Flow ever from thy bounteous heart;\n\
To nations that pure fount above\n\
The grace of pardon will impart.\n\
\n\
His heart for this was opened wide,\n\
And wounded by the soldier's spear,\n\
That freely from his sacred side\n\
Might flow the streams our souls to clear.\n\
\n\
Glory to Father and to Son,\n\
And to the Holy Ghost the same,\n\
To whom all power, when time is done,\n\
And endless rule, in endless fame.\n\
Amen."))))

;;; ─── Christ the King — Matins ───────────────────────────────────────

(bcp-roman-hymnal-register
 'aeterna-imago-altissimi
 '(:tags (matins christ-the-king)
   :latin "\
Ætérna Imago Altíssimi,\n\
Lumen, Deus, de Lúmine,\n\
Tibi, Redémptor glória,\n\
Honor, potéstas régia.\n\
\n\
Tu solus ante sǽcula\n\
Spes atque centrum témporum,\n\
Cui jure sceptrum géntium\n\
Pater suprémum crédidit.\n\
\n\
Tu flos pudícæ Vírginis,\n\
Nostræ caput propáginis,\n\
Lapis cadúcus vértice\n\
Ac mole terras óccupans.\n\
\n\
Diro tyránno súbdita,\n\
Damnáta stirps mortálium,\n\
Per te refrégit víncula\n\
Sibíque cælum víndicat.\n\
\n\
Doctor, Sacérdos, Légifer\n\
Præfers notátum sánguine\n\
In veste « Princeps príncipum\n\
Regúmque Rex Altíssimus ».\n\
\n\
Tibi voléntes súbdimur,\n\
Qui jure cunctis ímperas:\n\
Hæc cívium beátitas\n\
Tuis subésse légibus.\n\
\n\
Jesu, tibi sit glória,\n\
Qui sceptra mundi témperas,\n\
Cum Patre, et almo Spíritu,\n\
In sempitérna sǽcula.\n\
Amen."
   :translation-meters ((britt . "L.M."))
   :translations
   ((britt . "\
O thou eternal Image bright\n\
Of God most high, thou Light of Light,\n\
To thee, Redeemer, glory be,\n\
And might and kingly majesty.\n\
\n\
Sole hope of all created things,\n\
Thou art the Lord and King of kings,\n\
Whom God, long ere creation's morn,\n\
Had crowned to rule earth yet unborn.\n\
\n\
Fair flower from the Virgin's breast,\n\
Our race's Head for ever blest,\n\
The stone that Daniel saw on high,\n\
Which falling, o'er the world doth lie.\n\
\n\
The race of men, condemned to lie\n\
Beneath the direful tyrant's yoke,\n\
By thee at length the shackles broke\n\
And claimed the fatherland on high.\n\
\n\
Priest, Teacher, Giver of the law,\n\
Thy Name the rapt Apostle saw\n\
Writ on thy vesture and thy thigh:\n\
The King Of Kings, The Lord Most High.\n\
\n\
Fain would we own thy blessed sway,\n\
Whose rule all creatures must obey;\n\
For happy is that state and throne\n\
Whose subjects seek thy will alone.\n\
\n\
All praise, King Jesu, be to thee,\n\
The Lord of all in majesty;\n\
Whom with the Father we adore,\n\
And Holy Ghost, for evermore.\n\
Amen."))))

;;; ─── Jan 25 / Jun 30: S. Pauli Apostoli ────────────────────────────────

(bcp-roman-hymnal-register
 'egregie-doctor-paule
 '(:tags (st-peter sanctorum)
   :latin "\
Egrégie Doctor, Paule, mores ínstrue,\n\
Et nostra tecum péctora in cælum trahe;\n\
Veláta dum merídiem cernat fides,\n\
Et solis instar sola regnet cáritas.\n\
\n\
Sit Trinitáti sempitérna glória,\n\
Honor, potéstas atque jubilátio,\n\
In unitáte, quæ gubérnat ómnia,\n\
Per univérsa æternitátis sǽcula.\n\
Amen."
   :translation-meters ((britt . "10. 10. 10. 10."))
   :translations
   ((britt . "\
O glorious Doctor Paul, instruct our ways,\n\
And draw our hearts with thine to heavenly heights;\n\
Till faith, unveiled, behold the noonday blaze,\n\
And love, like sunlight, reign o'er all our rights.\n\
\n\
To God the Trinity be glory paid,\n\
Honour and power, and joyful praise be done,\n\
In Unity that governs all things made,\n\
Through everlasting ages, Three in One.\n\
Amen."))))

(provide 'bcp-roman-hymnal)
;;; bcp-roman-hymnal.el ends here
