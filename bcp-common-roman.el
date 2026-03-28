;;; bcp-common-roman.el --- Shared Roman Rite prayer texts -*- lexical-binding: t -*-

;;; Commentary:

;; Prayers shared across Roman Rite implementations within this framework.
;; The target form is the pre-1955 Roman Breviary as reformed by Pius X's
;; Divino Afflatu (1911), which is the form the Anglican Breviary follows.
;; The domain prefix for the Roman Office implementation is `bcp-roman-1911-'.
;;
;; Primary data source: the Divinum Officium project, Divino Afflatu (DA)
;; rubrics.  Before using DA data extensively, verify that its pre-1955
;; octave structure is intact (the 1955 suppressions must not have been
;; silently applied in DA mode).
;;
;; Scope: Divine Office (Breviary) only.  Mass propers and occasional rites
;; are out of scope.
;;
;; Texts here are Latin-primary.  The :latin key carries the authoritative
;; text; :english is optional and may be added later.  Use
;; `bcp-common-prayers-text' to resolve text for the current language.
;;
;; Relationship to other common layers:
;;   `bcp-common-prayers'  — truly ecumenical texts shared with this layer
;;                           (Lord's Prayer, Gloria Patri, Apostles' Creed)
;;   `bcp-common-anglican' — Anglican-family texts; not shared here
;;
;; TODO: populate with Roman Office fixed texts as bcp-roman-1911- is built:
;;
;;   Confiteor
;;     - The Confiteor as said at Prime and Compline; note the two forms
;;       (hebdomadary's form and choir repetition at Prime; Compline form)
;;
;;   Preces
;;     - Ferial preces at Lauds, Prime, Vespers, and Compline: the fixed
;;       series of versicles, Kyrie, Pater Noster, Credo (Prime only), and
;;       closing versicles; vary by season (omitted in Paschaltide, etc.)
;;
;;   Benedictiones (Nocturn blessings)
;;     - The fixed blessings before each Matins lesson: "Jube, Domine,
;;       benedicere" with the set of nine responses (Noctem quietam,
;;       Divinum auxilium, etc.) and the concluding absolution
;;
;;   Orationes
;;     - Fixed closing prayers said after the collect at the end of Hours:
;;       Sacrosanctae et individuae Trinitati, Retribuere dignare Domine,
;;       and the final blessing form
;;
;;   Responsoria brevia
;;     - The short responsories said after the chapter at each Hour;
;;       the fixed forms (e.g. Compline: "In manus tuas") and seasonal
;;       variants; distinct from the longer Matins responsories which are
;;       proper to the office of the day and belong in bcp-roman-1911-

;;; Code:

(require 'bcp-common-prayers)

(provide 'bcp-common-roman)
;;; bcp-common-roman.el ends here
