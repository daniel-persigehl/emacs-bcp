;;; bcp-anglican-versicles.el --- Translated BCP versicles -*- lexical-binding: t -*-

;;; Commentary:

;; Registry of BCP versicle/response pairs with Latin and Bungo-yaku
;; translations.  The English form is the canonical one (taken verbatim
;; from the 1662 ordo); Latin and Bungo are alternates served when
;; `bcp-common-prayers-language' selects them.
;;
;; Lookup is keyed by the English versicle text — the (V R) pair that
;; already flows through the renderer.  The renderer calls
;; `bcp-anglican-versicles-localize-pairs' before emitting, which swaps
;; in the alternate-language pair when the English V matches a known
;; entry; misses pass through unchanged.
;;
;; Sources, by entry:
;;   - Direct overlap with the Roman Office Lauds/Vespers ferial preces
;;     supplies canonical Latin for `endue-thy-ministers' (Ps 132:9
;;     paraphrase, "Sacerdotes tui induantur"), `save-thy-people'
;;     (Ps 28:9), and `hear-my-prayer' (Ps 102:1).  Reused verbatim from
;;     `bcp-roman-psalterium--preces-feriales-major'.
;;   - Universal Office incipits supply Latin for `open-our-lips' and
;;     `make-speed-to-save-us' — the verse that opens every hour, sung
;;     in the singular by ancient custom even when used corporately.
;;   - The Vulgate, with corporate singular→plural pronoun adaptations
;;     mirroring the BCP, supplies Latin for `make-clean-hearts'
;;     (Ps 50:12-13).
;;   - "Da pacem" is a non-scriptural composition with a fixed
;;     liturgical Latin form (cf. `bcp-roman-psalterium--suffragium-de-pace').
;;   - Kyrie eleison is universally retained in Greek across Latin
;;     liturgy; the Bungo form is the standard 主よあはれみたまへ.
;;   - Bungo entries derive from the 文語訳 (Bungo-yaku) Bible at the
;;     cited verse, with わが→われら corporate adaptations to match
;;     the BCP plural form.

;;; Code:

(require 'cl-lib)
(require 'bcp-common-prayers)  ; for bcp-common-prayers-language

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Registry

(defconst bcp-anglican-versicles--entries
  '((open-our-lips
     :ref "Ps 51:15"
     :english ("O Lord, open thou our lips."
               "And our mouth shall shew forth thy praise.")
     :latin   ("Dómine, lábia nostra apéries."
               "Et os nostrum annuntiábit laudem tuam.")
     :bungo   ("主よ、われらの口唇をひらきたまへ。"
               "さらばわれらの口、なんぢの頌美をあらはさん。"))

    (make-speed-to-save-us
     :ref "Ps 70:1"
     ;; Latin retains the singular by ancient Office custom — "in
     ;; adjutorium meum" / "ad adjuvandum me" — even said corporately.
     :english ("O God, make speed to save us."
               "O Lord, make haste to help us.")
     :latin   ("Deus, in adjutórium meum inténde."
               "Dómine, ad adjuvándum me festína.")
     :bungo   ("神よ、ねがはくはわれらを救はんとて、急ぎたまへ。"
               "ヱホバよ、われらを助けんとて、速かに来たりたまへ。"))

    (praise-ye-the-lord
     :ref "Ps 113:1-2"
     :english ("Praise ye the Lord."
               "The Lord's Name be praised.")
     :latin   ("Laudáte Dóminum."
               "Laudétur nomen Dómini.")
     :bungo   ("ヱホバを讃美たてまつれ。"
               "ヱホバの御名はほめたたへられたまへ。"))

    (kyrie-eleison
     ;; Greek; Latin liturgy retains the Greek form verbatim.
     :english ("Lord, have mercy upon us."
               "Christ, have mercy upon us.")
     :latin   ("Kýrie, eléison."
               "Christe, eléison.")
     :bungo   ("主よ、あはれみたまへ。"
               "キリストよ、あはれみたまへ。"))

    (kyrie-eleison-third
     :english ("Lord, have mercy upon us." nil)
     :latin   ("Kýrie, eléison." nil)
     :bungo   ("主よ、あはれみたまへ。" nil))

    (shew-thy-mercy
     :ref "Ps 85:7"
     :english ("O Lord, shew thy mercy upon us."
               "And grant us thy salvation.")
     :latin   ("Osténde nobis, Dómine, misericórdiam tuam."
               "Et salutáre tuum da nobis.")
     :bungo   ("ヱホバよ、なんぢの憐憫をわれらに示したまへ。"
               "またなんぢの救をわれらに賜へ。"))

    (endue-thy-ministers
     :ref "Ps 132:9"
     ;; BCP form is a paraphrase; the Latin here is the canonical Office
     ;; preces form — the Roman Lauds/Vespers ferial preces verbatim.
     :english ("Endue thy Ministers with righteousness."
               "And make thy chosen people joyful.")
     :latin   ("Sacerdótes tui induántur justítiam."
               "Et sancti tui exsúltent.")
     :bungo   ("なんぢの祭司に義を着せたまへ。"
               "またなんぢの聖徒に喜びを與へたまへ。"))

    (save-thy-people
     :ref "Ps 28:9"
     ;; Verbatim Roman ferial preces — Vulgate verse split V/R at the
     ;; same point as the BCP.
     :english ("O Lord, save thy people."
               "And bless thine inheritance.")
     :latin   ("Salvum fac pópulum tuum, Dómine."
               "Et bénedic hereditáti tuæ.")
     :bungo   ("ヱホバよ、なんぢの民を救ひたまへ。"
               "またなんぢの嗣業をめぐみたまへ。"))

    (give-peace
     ;; A liturgical composition (not a scripture verse).  The Latin
     ;; antiphon "Da pacem" is the canonical form, also used in the
     ;; Roman Suffragium de Pace.
     :english ("Give peace in our time, O Lord."
               "Because there is none other that fighteth for us, but only thou, O God.")
     :latin   ("Da pacem, Dómine, in diébus nostris."
               "Quia non est álius qui pugnet pro nobis, nisi tu, Deus noster.")
     :bungo   ("主よ、われらの代に平安を賜へ。"
               "われらの為に戦ひたまふものは、ただわが神なるなんぢのみなればなり。"))

    (make-clean-hearts
     :ref "Ps 51:10-11"
     :english ("O God, make clean our hearts within us."
               "And take not thy Holy Spirit from us.")
     ;; Vulgate Ps 50:12-13 with corporate adaptations: in me → in
     ;; nobis, a me → a nobis.
     :latin   ("Deus, cor mundum crea in nobis."
               "Et Spíritum Sanctum tuum ne áuferas a nobis.")
     :bungo   ("神よ、われらのうちに清き心をつくりたまへ。"
               "なんぢの聖霊をわれらより取りたまふなかれ。"))

    (lord-be-with-you
     ;; Universal liturgical greeting.  Scriptural echoes (Ruth 2:4,
     ;; 2 Thess 3:16, 2 Tim 4:22) but the form is liturgical, not
     ;; scriptural.
     :english ("The Lord be with you."
               "And with thy spirit.")
     :latin   ("Dóminus vobíscum."
               "Et cum spíritu tuo.")
     :bungo   ("主、なんぢらと偕にいませ。"
               "またなんぢの霊と偕に。"))

    (hear-my-prayer
     :ref "Ps 102:1"
     ;; Lay-preces substitute for "The Lord be with you."  Latin and
     ;; Bungo retain the singular ("my prayer/cry"), matching the BCP
     ;; English here.  Latin is verbatim Roman ferial preces.
     :english ("Hear my prayer, O Lord."
               "And let my cry come unto thee.")
     :latin   ("Dómine, exáudi oratiónem meam."
               "Et clamor meus ad te véniat.")
     :bungo   ("ヱホバよ、わが祈をききたまへ。"
               "わが叫びをなんぢに達らしめたまへ。")))
  "Alist of (KEY . PLIST) for translated BCP versicle pairs.
Each PLIST has :english (V R), :latin (V R), :bungo (V R), and
optionally :ref (scripture citation).  R may be nil for orphan
versicles such as the third Kyrie.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lookup

(defvar bcp-anglican-versicles--english-index nil
  "Hash table mapping English (V . R) cons to entry plist.  Lazy-built.
Keying by (V . R) rather than V alone so that distinct entries with the
same V but different R — e.g. the doubled Kyrie and the orphan third
Kyrie — resolve to different entries.")

(defun bcp-anglican-versicles--rebuild-index ()
  "Rebuild the (V . R) → entry table from `bcp-anglican-versicles--entries'."
  (let ((tbl (make-hash-table :test 'equal)))
    (dolist (entry bcp-anglican-versicles--entries)
      (let* ((plist (cdr entry))
             (en    (plist-get plist :english))
             (v     (car en))
             (r     (cadr en)))
        (when v (puthash (cons v r) plist tbl))))
    (setq bcp-anglican-versicles--english-index tbl)))

(defun bcp-anglican-versicles--lookup (english-v english-r)
  "Return the entry plist matching the English (V . R), or nil."
  (unless bcp-anglican-versicles--english-index
    (bcp-anglican-versicles--rebuild-index))
  (gethash (cons english-v english-r) bcp-anglican-versicles--english-index))

(defun bcp-anglican-versicles-localize-pair (pair language)
  "Return PAIR translated into LANGUAGE, or PAIR unchanged on lookup miss.
PAIR is a (V R) list.  LANGUAGE is a symbol — `english', `latin', or
`bungo'.  For `english' (or any unknown language), PAIR is returned as-is."
  (if (eq language 'english) pair
    (let* ((v     (car pair))
           (r     (cadr pair))
           (entry (and v (bcp-anglican-versicles--lookup v r)))
           (key   (intern (format ":%s" language)))
           (alt   (and entry (plist-get entry key))))
      (or alt pair))))

(defun bcp-anglican-versicles-localize-pairs (pairs &optional language)
  "Localize each element of PAIRS via `bcp-anglican-versicles-localize-pair'.
LANGUAGE defaults to `bcp-common-prayers-language'."
  (let ((lang (or language bcp-common-prayers-language)))
    (mapcar (lambda (p) (bcp-anglican-versicles-localize-pair p lang))
            pairs)))

;; Rebuild index now so the registered pairs are immediately resolvable
;; without waiting for the first call.
(bcp-anglican-versicles--rebuild-index)

(provide 'bcp-anglican-versicles)

;;; bcp-anglican-versicles.el ends here
