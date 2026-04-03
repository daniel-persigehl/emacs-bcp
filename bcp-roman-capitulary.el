;;; bcp-roman-capitulary.el --- Capitulum registry for the Roman Office -*- lexical-binding: t -*-

;;; Commentary:

;; Registry of Roman Office capitula (short scripture readings at the
;; Little Hours), keyed by Latin incipit.  Same architecture as
;; `bcp-roman-collectarium.el' and `bcp-roman-antiphonary.el'.
;;
;; Each entry stores the Latin text, a scripture reference, and one or
;; more English translations under named translator keys.
;;
;; Architecture:
;;   Each capitulum is an alist entry: (INCIPIT . PLIST)
;;   PLIST has:
;;     :latin        STRING — the Latin text (pointed, with accents)
;;     :ref          STRING — scripture reference (e.g., "Rom 13:11")
;;     :translations ALIST of (TRANSLATOR-KEY . STRING)
;;
;; Public API:
;;   `bcp-roman-capitulary-get'     — return text for a given language
;;   `bcp-roman-capitulary-latin'   — return Latin text
;;   `bcp-roman-capitulary-english' — return English text (fallback chain)
;;   `bcp-roman-capitulary-ref'     — return scripture reference

;;; Code:

(require 'cl-lib)
(require 'bcp-roman-antiphonary)  ; for bcp-roman-registry--resolve-translation

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-roman-capitulary nil
  "Capitulum translations for the Roman Office."
  :prefix "bcp-roman-capitulary-"
  :group 'bcp-liturgy)

(defcustom bcp-roman-capitulary-translators '(do)
  "Translator fallback chain for capitula.
Tried in sequence until a translation is found."
  :type  '(repeat symbol)
  :group 'bcp-roman-capitulary)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Registry

(defvar bcp-roman-capitulary--entries nil
  "Alist of (INCIPIT . PLIST) for registered capitula.
Each PLIST has :latin STRING, :ref STRING, and :translations ALIST.")

(defun bcp-roman-capitulary-register (incipit plist)
  "Register PLIST as capitulum INCIPIT.
INCIPIT is a symbol (the Latin first words, kebab-cased).
PLIST has :latin, :ref, and :translations."
  (setf (alist-get incipit bcp-roman-capitulary--entries) plist))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-capitulary-latin (incipit)
  "Return the Latin text for capitulum INCIPIT, or nil."
  (plist-get (alist-get incipit bcp-roman-capitulary--entries) :latin))

(defun bcp-roman-capitulary-english (incipit)
  "Return the English text for capitulum INCIPIT.
Walks `bcp-roman-capitulary-translators' fallback chain."
  (let* ((entry (alist-get incipit bcp-roman-capitulary--entries))
         (translations (plist-get entry :translations)))
    (bcp-roman-registry--resolve-translation
     translations bcp-roman-capitulary-translators)))

(defun bcp-roman-capitulary-ref (incipit)
  "Return the scripture reference for capitulum INCIPIT, or nil."
  (plist-get (alist-get incipit bcp-roman-capitulary--entries) :ref))

(defun bcp-roman-capitulary-get (incipit language)
  "Return capitulum INCIPIT text for LANGUAGE.
LANGUAGE is \\='latin or \\='english."
  (pcase language
    ('latin   (bcp-roman-capitulary-latin incipit))
    ('english (or (bcp-roman-capitulary-english incipit)
                  (bcp-roman-capitulary-latin incipit)))
    (_        (bcp-roman-capitulary-latin incipit))))

(provide 'bcp-roman-capitulary)

;;; bcp-roman-capitulary.el ends here
