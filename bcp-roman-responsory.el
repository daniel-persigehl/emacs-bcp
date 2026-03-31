;;; bcp-roman-responsory.el --- Responsory registry for the Roman Office -*- lexical-binding: t -*-

;;; Commentary:

;; Registry of Roman Office responsories, keyed by Latin incipit.
;; Same architecture as `bcp-roman-antiphonary.el' and `bcp-roman-hymnal.el'.
;;
;; Responsory entries have a nested plist structure:
;;   :latin        PLIST with :respond, :verse, :repeat
;;   :translations ALIST of (TRANSLATOR . PLIST-with-:respond-:verse-:repeat)
;;
;; Public API:
;;   `bcp-roman-responsory-get'     — return plist for a given language
;;   `bcp-roman-responsory-latin'   — return Latin plist
;;   `bcp-roman-responsory-english' — return English plist (fallback chain)

;;; Code:

(require 'cl-lib)
(require 'bcp-roman-antiphonary)  ; for bcp-roman-registry--resolve-translation

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-roman-responsory nil
  "Responsory translations for the Roman Office."
  :prefix "bcp-roman-responsory-"
  :group 'bcp-liturgy)

(defcustom bcp-roman-responsory-translators '(bute)
  "Translator fallback chain for responsories.
Tried in sequence until a translation is found."
  :type  '(repeat symbol)
  :group 'bcp-roman-responsory)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Registry

(defvar bcp-roman-responsory--entries nil
  "Alist of (INCIPIT . PLIST) for registered responsories.
Each PLIST has :latin PLIST and :translations ALIST.
The inner plists have :respond, :verse, :repeat.")

(defun bcp-roman-responsory-register (incipit plist)
  "Register PLIST as responsory INCIPIT.
INCIPIT is a symbol (the Latin respond's first words, kebab-cased).
PLIST has :latin (a plist) and :translations (an alist of plists)."
  (setf (alist-get incipit bcp-roman-responsory--entries) plist))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-responsory-latin (incipit)
  "Return the Latin plist for responsory INCIPIT, or nil."
  (plist-get (alist-get incipit bcp-roman-responsory--entries) :latin))

(defun bcp-roman-responsory-english (incipit)
  "Return the English plist for responsory INCIPIT.
Walks `bcp-roman-responsory-translators' fallback chain."
  (let* ((entry (alist-get incipit bcp-roman-responsory--entries))
         (translations (plist-get entry :translations)))
    (bcp-roman-registry--resolve-translation
     translations bcp-roman-responsory-translators)))

(defun bcp-roman-responsory-get (incipit language)
  "Return responsory INCIPIT plist for LANGUAGE.
LANGUAGE is \\='latin or \\='english."
  (pcase language
    ('latin   (bcp-roman-responsory-latin incipit))
    ('english (or (bcp-roman-responsory-english incipit)
                  (bcp-roman-responsory-latin incipit)))
    (_        (bcp-roman-responsory-latin incipit))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; LOBVM Matins responsories

(bcp-roman-responsory-register
 'sancta-et-immaculata
 '(:latin (:respond "Sancta et immaculáta virgínitas, quibus te láudibus éfferam, néscio:"
           :repeat  "Quia quem cæli cápere non póterant, tuo grémio contulísti."
           :verse   "Benedícta tu in muliéribus, et benedíctus fructus ventris tui.")
   :translations
   ((bute . (:respond "O how holy and how spotless is thy virginity; I am too dull to praise thee:"
             :repeat  "For thou hast borne in thy breast Him Whom the heavens cannot contain."
             :verse   "Blessed art thou among women, and blessed is the fruit of thy womb.")))))

(bcp-roman-responsory-register
 'beata-es-virgo-maria
 '(:latin (:respond "Beáta es, Virgo María, quæ Dóminum portásti, Creatórem mundi:"
           :repeat  "Genuísti qui te fecit, et in ætérnum pérmanes Virgo."
           :verse   "Ave María, grátia plena, Dóminus tecum.")
   :translations
   ((bute . (:respond "Blessed art thou, O Virgin Mary, who hast carried the Lord, the Maker of the world."
             :repeat  "Thou hast borne Him Who created thee, and thou abidest a virgin for ever."
             :verse   "Hail, Mary, full of grace, the Lord is with thee.")))))

(provide 'bcp-roman-responsory)

;;; bcp-roman-responsory.el ends here
