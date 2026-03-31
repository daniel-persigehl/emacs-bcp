;;; bcp-roman-collectarium.el --- Collect registry for the Roman Office -*- lexical-binding: t -*-

;;; Commentary:

;; Registry of Roman Office collects, keyed by Latin incipit.
;; Same architecture as `bcp-roman-antiphonary.el' and `bcp-roman-hymnal.el'.
;;
;; Each entry stores the full collect text including conclusion formula
;; (Per Dominum, Qui vivis, etc.).  The `:conclusion' slot records which
;; formula was used, for future use when multiple rites share a collect
;; body with different conclusions.
;;
;; Public API:
;;   `bcp-roman-collectarium-get'     — return text for a given language
;;   `bcp-roman-collectarium-latin'   — return Latin text
;;   `bcp-roman-collectarium-english' — return English text (fallback chain)

;;; Code:

(require 'cl-lib)
(require 'bcp-roman-antiphonary)  ; for bcp-roman-registry--resolve-translation
(require 'bcp-common-roman)       ; for collect conclusion formulae

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-roman-collectarium nil
  "Collect translations for the Roman Office."
  :prefix "bcp-roman-collectarium-"
  :group 'bcp-liturgy)

(defcustom bcp-roman-collectarium-translators '(cranmer bute do)
  "Translator fallback chain for collects.
Tried in sequence until a translation is found."
  :type  '(repeat symbol)
  :group 'bcp-roman-collectarium)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Registry

(defvar bcp-roman-collectarium--entries nil
  "Alist of (INCIPIT . PLIST) for registered collects.
Each PLIST has :latin STRING, :translations ALIST, and optionally
:conclusion SYMBOL (per-dominum, per-eumdem, qui-vivis, qui-tecum).")

(defun bcp-roman-collectarium-register (incipit plist)
  "Register PLIST as collect INCIPIT.
INCIPIT is a symbol (the Latin first words, kebab-cased).
PLIST has :latin, :translations, and optionally :conclusion."
  (setf (alist-get incipit bcp-roman-collectarium--entries) plist))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-collectarium-latin (incipit)
  "Return the Latin text for collect INCIPIT, or nil."
  (plist-get (alist-get incipit bcp-roman-collectarium--entries) :latin))

(defun bcp-roman-collectarium-english (incipit)
  "Return the English text for collect INCIPIT.
Walks `bcp-roman-collectarium-translators' fallback chain."
  (let* ((entry (alist-get incipit bcp-roman-collectarium--entries))
         (translations (plist-get entry :translations)))
    (bcp-roman-registry--resolve-translation
     translations bcp-roman-collectarium-translators)))

(defun bcp-roman-collectarium-get (incipit language)
  "Return collect INCIPIT text for LANGUAGE.
LANGUAGE is \\='latin or \\='english."
  (pcase language
    ('latin   (bcp-roman-collectarium-latin incipit))
    ('english (or (bcp-roman-collectarium-english incipit)
                  (bcp-roman-collectarium-latin incipit)))
    (_        (bcp-roman-collectarium-latin incipit))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM collects
;;
;; Full text including conclusion formula.  The :conclusion slot records
;; which formula was used (informational; the renderer consumes the
;; complete string).

;;; ─── Vespers / Lauds / Matins collect (same prayer, different conclusions) ─

;; Vespers uses Per Dominum; Lauds and Matins use Per eumdem (Christ named).
;; Since the full text differs, these are separate entries.

(bcp-roman-collectarium-register
 'concede-nos-famulos
 (list :latin (concat
              "Concéde nos fámulos tuos, quǽsumus, Dómine Deus, perpétua mentis \
et córporis sanitáte gaudére: et, gloriósa beátæ Maríæ semper Vírginis \
intercessióne, a præsénti liberári tristítia, et ætérna pérfrui lætítia.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((bute . "Grant, we beseech thee, O Lord God, unto all thy servants, that they \
may remain continually in the enjoyment of soundness both of mind and body, \
and by the glorious intercession of the Blessed Mary, always a Virgin, may \
be delivered from present sadness, and enter into the joy of thine eternal \
gladness.\nThrough our Lord."))))

(bcp-roman-collectarium-register
 'deus-qui-de-beatae
 (list :latin (concat
              "Deus, qui de beátæ Maríæ Vírginis útero Verbum tuum, Angelo \
nuntiánte, carnem suscípere voluísti: præsta supplícibus tuis; ut, \
qui vere eam Genetrícem Dei crédimus, ejus apud te intercessiónibus \
adjuvémur.\n"
              bcp-roman-per-eumdem)
       :conclusion 'per-eumdem
       :translations
       '((bute . "O God, who didst will that, at the announcement of an Angel, thy Word \
should take flesh in the womb of the Blessed Virgin Mary, grant to us thy \
suppliants, that we who believe her to be truly the Mother of God may be \
helped by her intercession with thee.\nThrough the same Lord."))))

;; Matins uses Per Dominum (different from Lauds despite same body text).
(bcp-roman-collectarium-register
 'deus-qui-de-beatae-per-dominum
 (list :latin (concat
              "Deus, qui de beátæ Maríæ Vírginis útero, Verbum tuum, Ángelo \
nuntiánte, carnem suscípere voluísti: præsta supplícibus tuis; ut, \
qui vere eam Genetrícem Dei crédimus, ejus apud te intercessiónibus \
adjuvémur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((bute . "O God, who didst will that, at the announcement of an Angel, thy Word \
should take flesh in the womb of the Blessed Virgin Mary, grant to us thy \
suppliants, that we who believe her to be truly the Mother of God may be \
helped by her intercession with thee.\nThrough our Lord."))))

;;; ─── Prime collect ─────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-virginalem
 (list :latin (concat
              "Deus, qui virginálem aulam beátæ Maríæ, in qua habitáres, \
elígere dignátus es: da, quǽsumus; ut, sua nos defensióne munítos, \
jucúndos fácias suæ interésse commemoratióni.\n"
              bcp-roman-qui-vivis)
       :conclusion 'qui-vivis
       :translations
       '((bute . "O God, Who wast pleased to choose for thy dwelling-place the maiden palace \
of Blessed Mary, grant, we beseech thee, that her protection may shield us, \
and make us glad in her commemoration.\nWho livest and reignest."))))

;;; ─── Terce collect ─────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-salutis
 (list :latin (concat
              "Deus, qui salútis ætérnæ, beátæ Maríæ virginitáte fecúnda, \
humáno géneri prǽmia præstitísti: tríbue, quǽsumus; ut ipsam pro \
nobis intercédere sentiámus, per quam merúimus auctórem vitæ \
suscípere, Dóminum nostrum Jesum Christum Fílium tuum:\n"
              bcp-roman-qui-tecum)
       :conclusion 'qui-tecum
       :translations
       '((bute . "O God, Who, by the fruitful virginity of Blessed Mary, hast bestowed upon \
mankind the reward of eternal salvation; grant, we beseech thee, that we \
may feel the power of her intercession, through whom we have been made \
worthy to receive the Author of Life, our Lord Jesus Christ thy Son.\n\
Who livest and reignest with thee."))))

;;; ─── Sext collect ──────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'concede-misericors-deus
 (list :latin (concat
              "Concéde, miséricors Deus, fragilitáti nostræ præsídium; ut, qui \
sanctæ Dei Genetrícis memóriam ágimus; intercessiónis ejus auxílio, \
a nostris iniquitátibus resurgámus.\n"
              bcp-roman-per-eumdem)
       :conclusion 'per-eumdem
       :translations
       '((bute . "Most merciful God, grant, we beseech thee, a succour unto the frailty of \
our nature, that as we keep ever alive the memory of the holy Mother of God, \
so by the help of her intercession we may be raised up from the bondage of \
our sins.\nThrough the same Lord."))))

;;; ─── None collect ──────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'famulorum-tuorum
 (list :latin (concat
              "Famulórum tuórum, quǽsumus, Dómine, delíctis ignósce: ut qui \
tibi placére de áctibus nostris non valémus: Genitrícis Fílii tui \
Dómini nostri intercessióne salvémur:\n"
              bcp-roman-qui-tecum)
       :conclusion 'qui-tecum
       :translations
       '((bute . "O Lord, we beseech thee, forgive the transgressions of thy servants, \
and, forasmuch as by our own deeds we cannot please thee, may we find \
safety through the prayers of the Mother of thy Son and our Lord.\n\
Who livest and reignest with thee."))))

;;; ─── Compline collect ──────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'beatae-et-gloriosae
 (list :latin (concat
              "Beátæ et gloriósæ semper Vírginis Maríæ, quǽsumus, Dómine, \
intercéssio gloriósa nos prótegat, et ad vitam perdúcat ætérnam.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((bute . "O Lord, we pray thee, that the glorious intercession of Mary, blessed, \
and glorious, and everlastingly Virgin, may shield us and bring us on \
toward eternal life.\nThrough our Lord."))))

(provide 'bcp-roman-collectarium)

;;; bcp-roman-collectarium.el ends here
