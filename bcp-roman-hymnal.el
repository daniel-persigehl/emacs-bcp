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

(defcustom bcp-roman-hymnal-fallback-order '(britt caswall neale primer)
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

(provide 'bcp-roman-hymnal)
;;; bcp-roman-hymnal.el ends here
