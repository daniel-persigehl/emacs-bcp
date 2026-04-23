;;; bcp-roman-season-lent.el --- Lenten Proper of the Time -*- lexical-binding: t -*-

;;; Commentary:

;; Proper of the Time data for the Lenten season (DA 1911 rubrics).
;; Covers the five Sundays of Lent (Quad1-0 through Quad5-0 in DO
;; terminology), providing collects, dominical Matins data (9 lessons,
;; 8 responsories), and non-Matins hour data (antiphons, capitula).
;; Lent has per-Sunday minor hour antiphons (Prime through None).
;;
;; Antiphons and capitula are registered in antiphonary/capitulary and
;; referenced by symbol in the alist entries.
;;
;; Lesson structure follows `bcp-roman-tempora.el' Per Annum pattern:
;;   Nocturn I  (L1-L3): Scripture with :ref, :source, :text
;;   Nocturn II (L4-L6): Patristic with :ref, :source, :text
;;   Nocturn III (L7-L9): Homily with :ref, :source, :text
;;
;; Data extracted from Divinum Officium Latin Tempora files.
;;
;; Key public functions:
;;   `bcp-roman-season-lent-collect'           — Lenten Sunday collect incipit
;;   `bcp-roman-season-lent-dominical-matins'  — Lenten dominical Matins data

;;; Code:

(require 'bcp-common-roman)
(require 'bcp-roman-collectarium)
(require 'bcp-roman-antiphonary)
(require 'bcp-roman-capitulary)
(require 'bcp-calendar)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lenten Sunday collects (Lent 1–5)

;;; ─── Lent Sunday 1 ──────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-ecclesiam-tuam-annua
 (list :latin (concat
              "Deus, qui Ecclésiam tuam ánnua quadragesimáli observatióne \
puríficas: præsta famíliæ tuæ; ut, quod a te obtinére abstinéndo nítitur, \
hoc bonis opéribus exsequátur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who dost every year purge thy Church by the Fast of \
Forty Days, grant unto this thy family, that what things soever they strive \
to obtain at thy hand by abstaining from meats, they may ever turn to profit \
by good works.\nThrough our Lord."))))

;;; ─── Lent Sunday 2 ──────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-conspicis-omni-nos
 (list :latin (concat
              "Deus, qui cónspicis omni nos virtúte destítui: intérius \
exteriúsque custódi; ut ab ómnibus adversitátibus muniámur in córpore, \
et a pravis cogitatiónibus mundémur in mente.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who seest that we have no power of ourselves to help \
ourselves, keep us both outwardly in our bodies, and inwardly in our souls, \
that we may be defended from all adversities which may happen to the body, \
and from all evil thoughts which may assault and hurt the soul.\n\
Through our Lord."))))

;;; ─── Lent Sunday 3 ──────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'quaesumus-omnipotens-deus-vota-humilium
 (list :latin (concat
              "Quǽsumus, omnípotens Deus, vota humílium réspice: atque ad \
defensiónem nostram, déxteram tuæ majestátis exténde.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "We beeseech thee, almighty God, look upon the hearty desires \
of thy humble servants, and stretch forth the right hand of thy Majesty to \
be our defense against all our enemies.\nThrough our Lord."))))

;;; ─── Lent Sunday 4 ──────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'concede-quaesumus-omnipotens-deus-ut-qui-ex-merito
 (list :latin (concat
              "Concéde, quǽsumus, omnípotens Deus: ut, qui ex mérito nostræ \
actiónis afflígimur, tuæ grátiæ consolatióne respirémus.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech thee, Almighty God, that we who for our \
evil deeds are worthily punished, may, by the comfort of thy grace, \
mercifully be relieved.\nThrough our Lord."))))

;;; ─── Lent Sunday 5 (Passion Sunday) ─────────────────────────────────────

(bcp-roman-collectarium-register
 'quaesumus-omnipotens-deus-familiam-tuam-propitius
 (list :latin (concat
              "Quǽsumus, omnípotens Deus, famíliam tuam propítius réspice: \
ut, te largiénte, regátur in córpore; et, te servánte, custodiátur in \
mente.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "We beseech thee, Almighty God, mercifully to look upon this \
thy family, that by thy great goodness they may be governed and preserved \
evermore, both in body and soul.\nThrough our Lord."))))

;;; ─── Palm Sunday (Dominica in Palmis) ────────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-humano-generi
 (list :latin (concat
              "Omnípotens sempitérne Deus, qui humáno géneri, ad imitándum \
humilitátis exémplum, Salvatórem nostrum carnem súmere, et crucem subíre \
fecísti: concéde propítius; ut et patiéntiæ ipsíus habére documénta, et \
resurrectiónis consórtia mereámur.\n"
              bcp-roman-per-eumdem)
       :conclusion 'per-eumdem
       :translations
       '((do . "Almighty and everlasting God, Who, of thy tender love towards \
mankind, hast sent thy Son our Saviour Jesus Christ to take upon Him our \
flesh and to suffer death upon the Cross, that all mankind should follow the \
example of His great humility; mercifully grant, that we may both follow the \
example of His patience, and also be made partakers of His resurrection.\n\
Through the same."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sunday-to-collect mapping

(defconst bcp-roman-season-lent--collects
  [nil ; slot 0 unused (1-indexed)
   deus-qui-ecclesiam-tuam-annua                     ; Lent 1
   deus-qui-conspicis-omni-nos                       ; Lent 2
   quaesumus-omnipotens-deus-vota-humilium            ; Lent 3
   concede-quaesumus-omnipotens-deus-ut-qui-ex-merito ; Lent 4
   quaesumus-omnipotens-deus-familiam-tuam-propitius  ; Lent 5 (Passion Sunday)
   omnipotens-sempiterne-deus-qui-humano-generi]      ; Lent 6 (Palm Sunday)
  "Lenten Sunday collect incipits, 1-indexed by Lent Sunday number.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lenten Sunday number computation

(defun bcp-roman-season-lent--sunday-number (date)
  "Return the Lent Sunday number (1–6) for the Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns nil if DATE is outside Lent/Passiontide.
Lent 1 = first Sunday of Lent (Ash Wednesday + 4 days).
Lent 5 = Passion Sunday (2 weeks before Easter).
Lent 6 = Palm Sunday (1 week before Easter)."
  (let* ((year (caddr date))
         (feasts (bcp-moveable-feasts year))
         (easter (cdr (assq 'easter feasts)))
         (easter-abs (calendar-absolute-from-gregorian easter))
         ;; Lent 1 = Easter - 42 (6 weeks before Easter)
         (lent1-abs (- easter-abs 42))
         (date-abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date))
         (sunday-abs (- date-abs dow))
         (weeks (/ (- sunday-abs lent1-abs) 7)))
    (when (and (>= weeks 0) (<= weeks 5))
      (1+ weeks))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Public API

(defun bcp-roman-season-lent-collect (date)
  "Return the collect incipit symbol for the Lenten Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns nil outside Lent/Passiontide."
  (let ((n (bcp-roman-season-lent--sunday-number date)))
    (when (and n (<= n (1- (length bcp-roman-season-lent--collects))))
      (aref bcp-roman-season-lent--collects n))))

(defun bcp-roman-season-lent-dominical-matins (date)
  "Return dominical Matins data for the Lenten Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories,
or nil outside Lent/Passiontide."
  (let ((n (bcp-roman-season-lent--sunday-number date)))
    (when n
      (cdr (assq n bcp-roman-season-lent--dominical-matins)))))

(defun bcp-roman-season-lent-dominical-hours (date)
  "Return non-Matins hour data for the Lenten Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns the same plist as `dominical-matins'
\(which contains both Matins and non-Matins keys), or nil outside Lent.
Lent includes per-Sunday minor hour antiphons (:prime-antiphon etc.)."
  (bcp-roman-season-lent-dominical-matins date))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lenten antiphon registrations

;;; ─── Lent 1 antiphons ─────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'tunc-invocabis
 '(:latin "Tunc invocábis, * et Dóminus exáudiet: clamábis, et dicet: Ecce adsum."
   :translations
   ((do . "Then shalt thou call, * and the Lord shall answer; thou shalt cry, and He shall say: Here I am."))))

(bcp-roman-antiphonary-register
 'ductus-est-jesus
 '(:latin "Ductus est Jesus * in desértum a Spíritu, ut tentarétur a diábolo: et cum jejunásset quadragínta diébus et quadragínta nóctibus, póstea esúriit."
   :translations
   ((do . "Jesus was led up of the Spirit into the wilderness, * to be tempted of the devil and when He had fasted forty days and forty nights, He was afterward hungry."))))

(bcp-roman-antiphonary-register
 'ecce-nunc-tempus-acceptabile
 '(:latin "Ecce nunc tempus * acceptábile, ecce nunc dies salútis: in his ergo diébus exhibeámus nosmetípsos sicut Dei minístros in multa patiéntia, in jejúniis, in vigíliis, et in caritáte non ficta."
   :translations
   ((do . "Behold, now is the accepted time * behold, now is the day of salvation; in these days therefore let us approve ourselves as the ministers of God, in much patience, in fastings, in watchings, and in love unfeigned."))))

(bcp-roman-antiphonary-register
 'cor-mundum-crea
 '(:latin "Cor mundum * crea in me Deus, et spíritum rectum ínnova in viscéribus meis."
   :translations
   ((do . "Create in me a clean heart, * O God, and renew a right spirit within me."))))

(bcp-roman-antiphonary-register
 'o-domine-salvum-me-fac
 '(:latin "O Dómine, * salvum me fac; o Dómine, bene prosperáre."
   :translations
   ((do . "Save me now, O Lord; * O Lord, send Thou prosperity."))))

(bcp-roman-antiphonary-register
 'sic-benedicam-te
 '(:latin "Sic benedícam * te in vita mea, Dómine: et in nómine tuo levábo manus meas."
   :translations
   ((do . "Thus will I bless thee, * O Lord, while I live; and will lift up my hands in thy Name."))))

(bcp-roman-antiphonary-register
 'in-spiritu-humilitatis
 '(:latin "In spíritu humilitátis, * et in ánimo contríto suscipiámur, Dómine, a te: et sic fiat sacrifícium nostrum, ut a te suscipiátur hódie, et pláceat tibi, Dómine Deus."
   :translations
   ((do . "In an humble spirit * and a contrite heart may we be accepted by thee, O Lord; and so let our sacrifice be this day, that it may be acceptable and pleasant in thy sight, O Lord our God!"))))

(bcp-roman-antiphonary-register
 'laudate-deum-caeli-caelorum
 '(:latin "Laudáte Deum * cæli cælórum, et aquæ omnes."
   :translations
   ((do . "Praise God, * ye heavens of heavens, and all ye waters."))))

(bcp-roman-antiphonary-register
 'jesus-autem-cum-jejunasset
 '(:latin "Jesus autem * cum jejunásset quadragínta diébus et quadragínta nóctibus, póstea esúriit."
   :translations
   ((do . "When Jesus had fasted forty days * and forty nights, He was afterward hungry."))))

(bcp-roman-antiphonary-register
 'tunc-assumpsit-eum
 '(:latin "Tunc assúmpsit * eum diábolus in sanctam civitátem, et státuit eum supra pinnáculum templi, et dixit ei: Si Fílius Dei es, mitte te deórsum."
   :translations
   ((do . "Then the devil taketh Him up into the holy city, * and setteth Him on a pinnacle of the temple, and saith unto Him: If Thou be the Son of God, cast thyself down."))))

(bcp-roman-antiphonary-register
 'non-in-solo-pane
 '(:latin "Non in solo pane * vivit homo, sed in omni verbo, quod procédit de ore Dei."
   :translations
   ((do . "Man shall not live by bread alone, * but by every word that proceedeth out of the mouth of God."))))

(bcp-roman-antiphonary-register
 'dominum-deum-tuum-adorabis
 '(:latin "Dóminum Deum tuum * adorábis, et illi soli sérvies."
   :translations
   ((do . "Thou shalt worship the Lord thy God, * and Him only shalt thou serve."))))

;;; ─── Lent 2 antiphons ─────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'visionem-quam-vidistis
 '(:latin "Visiónem quam vidístis, * némini dixéritis, donec a mórtuis resúrgat Fílius hóminis."
   :translations
   ((do . "Tell the vision that ye have seen to no man, * until the Son of man be risen again from the dead."))))

(bcp-roman-antiphonary-register
 'assumpsit-jesus-discipulos
 '(:latin "Assúmpsit Jesus * discípulos suos, et ascéndit in montem, et transfigurátus est ante eos."
   :translations
   ((do . "Jesus took His disciples, * and went up into a mountain, and was transfigured before them."))))

(bcp-roman-antiphonary-register
 'domine-labia-mea
 '(:latin "Dómine, * lábia mea apéries, et os meum annuntiábit laudem tuam."
   :translations
   ((do . "O Lord, open Thou my lips, * and my mouth shall show forth thy praise."))))

(bcp-roman-antiphonary-register
 'dextera-domini-fecit
 '(:latin "Déxtera Dómini * fecit virtútem: déxtera Dómini exaltávit me."
   :translations
   ((do . "The right hand of the Lord * hath done valiantly, the right hand of the Lord hath exalted me."))))

(bcp-roman-antiphonary-register
 'factus-est-adjutor
 '(:latin "Factus est * adjútor meus, Deus meus."
   :translations
   ((do . "My God * hath been my help."))))

(bcp-roman-antiphonary-register
 'trium-puerorum-cantemus
 '(:latin "Trium puerórum * cantémus hymnum, quem cantábant in camíno ignis, benedicéntes Dóminum."
   :translations
   ((do . "Let us sing the Song of the Three Children, * even the Song that they sang when they blessed the Lord in the burning fiery furnace."))))

(bcp-roman-antiphonary-register
 'statuit-ea-in-aeternum
 '(:latin "Státuit ea * in ætérnum, et in sǽculum sǽculi: præcéptum pósuit, et non præteríbit."
   :translations
   ((do . "He hath established them * for ever and ever: He hath made a decree which shall not pass."))))

(bcp-roman-antiphonary-register
 'domine-bonum-est-nos
 '(:latin "Dómine, * bonum est nos hic esse: si vis, faciámus hic tria tabernácula; tibi unum, Móysi unum, et Elíæ unum."
   :translations
   ((do . "Lord, it is good for us to be here; * if Thou wilt, let us make here three tabernacles, one for thee, and one for Moses, and one for Elias."))))

(bcp-roman-antiphonary-register
 'faciamus-hic-tria
 '(:latin "Faciámus hic * tria tabernácula; tibi unum, Móysi unum, et Elíæ unum."
   :translations
   ((do . "Let us make here three tabernacles, * one for thee, and one for Moses, and one for Elias."))))

;;; ─── Lent 3 antiphons ─────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'dixit-autem-pater-ad-servos
 '(:latin "Dixit autem pater * ad servos suos: Cito proférte stolam primam, et indúite illum, et date ánulum in manu ejus, et calceaménta in pédibus ejus."
   :translations
   ((do . "But the father said * to his servants: Bring forth quickly the first robe, and put it on him, and put a ring on his hand, and shoes on his feet."))))

(bcp-roman-antiphonary-register
 'cum-fortis-armatus
 '(:latin "Cum fortis armátus * custódit átrium suum, in pace sunt ómnia quæ póssidet."
   :translations
   ((do . "When a strong man armed keepeth his palace, * his goods are in peace."))))

(bcp-roman-antiphonary-register
 'extollens-vocem
 '(:latin "Extóllens vocem * quædam múlier de turba, dixit: Beátus venter qui te portávit, et úbera quæ suxísti. At Jesus ait illi: Quinímmo beáti, qui áudiunt verbum Dei, et custódiunt illud."
   :translations
   ((do . "A certain woman of the company lifted up her voice and said: * Blessed is the womb that bare thee, and the paps which Thou hast sucked. But Jesus said unto her: Yea, rather, blessed are they that hear the word of God, and keep it."))))

(bcp-roman-antiphonary-register
 'fac-benigne-in-bona
 '(:latin "Fac benígne * in bona voluntáte tua, ut ædificéntur, Dómine, muri Jerúsalem."
   :translations
   ((do . "O Lord, do good in thy good pleasure * unto Zion; to build the walls of Jerusalem."))))

(bcp-roman-antiphonary-register
 'dominus-mihi-adjutor
 '(:latin "Dóminus * mihi adjútor est, non timébo quid fáciat mihi homo."
   :translations
   ((do . "The Lord is on my side; * I will not fear what can man do unto me."))))

(bcp-roman-antiphonary-register
 'adhaesit-anima-mea
 '(:latin "Adhǽsit ánima mea * post te, Deus meus."
   :translations
   ((do . "O my God, my soul cleaveth fast * after thee, O God."))))

(bcp-roman-antiphonary-register
 'vim-virtutis-suae
 '(:latin "Vim virtútis suæ * oblítus est ignis: ut púeri tui liberaréntur illǽsi."
   :translations
   ((do . "The fire forgot his strength * that thy children might be delivered therefrom."))))

(bcp-roman-antiphonary-register
 'sol-et-luna-laudate
 '(:latin "Sol et luna * laudáte Deum: quia exaltátum est nomen ejus solíus."
   :translations
   ((do . "Praise God, O ye sun and moon, * for His Name alone is exalted!"))))

(bcp-roman-antiphonary-register
 'et-cum-ejecisset
 '(:latin "Et cum ejecísset Jesus * dæmónium, locútus est mutus, et admirátæ sunt turbæ."
   :translations
   ((do . "When Jesus had cast out the devil, * the dumb spake, and the people wondered."))))

(bcp-roman-antiphonary-register
 'si-in-digito-dei
 '(:latin "Si in dígito Dei * eício dæmónia, profécto pervénit in vos regnum Dei."
   :translations
   ((do . "If I with the finger of God * cast out devils, no doubt the kingdom of God is come upon you."))))

(bcp-roman-antiphonary-register
 'qui-non-colligit-mecum
 '(:latin "Qui non cólligit mecum * dispérgit, et qui non est mecum, contra me est."
   :translations
   ((do . "He that gathereth not with Me scattereth, * and he that is not with Me is against Me."))))

(bcp-roman-antiphonary-register
 'cum-immundus-spiritus
 '(:latin "Cum immúndus spíritus * exíerit ab hómine, ámbulat per loca inaquósa, quærens réquiem et non ínvenit."
   :translations
   ((do . "When the unclean spirit * is gone out of a man, he walketh through dry places, seeking rest, and finding none."))))

;;; ─── Lent 4 antiphons ─────────────────────────────────────────────────

(bcp-roman-antiphonary-register
 'nemo-te-condemnavit
 '(:latin "Nemo te condemnávit, múlier? * Nemo, Dómine. Nec ego te condemnábo: jam ámplius noli peccáre."
   :translations
   ((do . "Woman, hath no man condemned thee? * No man, Lord. Neither do I condemn thee; go, and sin no more."))))

(bcp-roman-antiphonary-register
 'cum-sublevasset-oculos
 '(:latin "Cum sublevásset óculos * Jesus, et vidísset máximam multitúdinem veniéntem ad se, dixit ad Philíppum: Unde emémus panes, ut mandúcent hi? Hoc autem dicébat tentans eum: ipse enim sciébat quid esset factúrus."
   :translations
   ((do . "When Jesus lifted up His Eyes, * and saw a great company come unto Him, He saith unto Philip: Whence shall we buy bread that these may eat? And this He said to prove him; for He Himself knew what He would do."))))

(bcp-roman-antiphonary-register
 'subiit-ergo-in-montem
 '(:latin "Súbiit ergo, * in montem Jesus, et ibi sedébat cum discípulis suis."
   :translations
   ((do . "And Jesus went up into a mountain, * and there He sat with His disciples."))))

(bcp-roman-antiphonary-register
 'tunc-acceptabis
 '(:latin "Tunc acceptábis * sacrifícium justítiæ, si avérteris fáciem tuam a peccátis meis."
   :translations
   ((do . "Then shalt Thou be pleased * with the sacrifices of righteousness, when Thou hast hidden thy face from my sins."))))

(bcp-roman-antiphonary-register
 'bonum-est-sperare
 '(:latin "Bonum est * speráre in Dómino, quam speráre in princípibus."
   :translations
   ((do . "It is better to trust * in the Lord, than to trust in princes."))))

(bcp-roman-antiphonary-register
 'me-suscepit-dextera
 '(:latin "Me suscépit * déxtera tua, Dómine."
   :translations
   ((do . "Thy right hand hath * received me, O Lord."))))

(bcp-roman-antiphonary-register
 'potens-es-domine
 '(:latin "Potens es, Dómine, * erípere nos de manu forti: líbera nos, Deus noster."
   :translations
   ((do . "O Lord, Thou art mighty * to save us; with a strong hand deliver us, O our God."))))

(bcp-roman-antiphonary-register
 'reges-terrae-et-omnes
 '(:latin "Reges terræ * et omnes pópuli, laudáte Deum."
   :translations
   ((do . "Kings of the earth, * and all people, praise God."))))

(bcp-roman-antiphonary-register
 'accepit-ergo-jesus
 '(:latin "Accépit ergo * Jesus panes, et, cum grátias egísset, distríbuit discumbéntibus."
   :translations
   ((do . "And Jesus took the loaves, * and when He had given thanks, He distributed to them that were set down."))))

(bcp-roman-antiphonary-register
 'de-quinque-panibus
 '(:latin "De quinque pánibus * et duobus píscibus satiávit Dóminus quinque míllia hóminum."
   :translations
   ((do . "With five loaves and two fishes * did the Lord satisfy five thousand men."))))

(bcp-roman-antiphonary-register
 'satiavit-dominus
 '(:latin "Satiávit Dóminus * quinque míllia hóminum de quinque pánibus et duobus píscibus."
   :translations
   ((do . "With five loaves and two fishes * did the Lord satisfy five thousand men."))))

(bcp-roman-antiphonary-register
 'illi-ergo-homines
 '(:latin "Illi ergo * hómines, cum vidíssent quod fécerat Jesus signum, intra se dicébant: quia hic est vere Prophéta, qui ventúrus est in mundum."
   :translations
   ((do . "Then those men, * when they had seen the miracle that Jesus did, said amongst themselves: This is of a truth that Prophet that should come into the world."))))

;;; ─── Lent 5 (Passion Sunday) antiphons ────────────────────────────────

(bcp-roman-antiphonary-register
 'ego-sum-qui-testimonium
 '(:latin "Ego sum * qui testimónium perhíbeo de meípso: et testimónium pérhibet de me, qui misit me, Pater."
   :translations
   ((do . "I am One * That bear witness of Myself, and the Father That sent Me beareth witness of Me."))))

(bcp-roman-antiphonary-register
 'dicebat-jesus-turbis
 '(:latin "Dicébat Jesus * turbis Judæórum, et princípibus sacerdótum: Qui ex Deo est, verba Dei audit: proptérea vos non audítis, quia ex Deo non estis."
   :translations
   ((do . "Jesus said * unto the multitudes of the Jews and unto the Chief Priests: He that is of God heareth God's words; ye, therefore, hear them not, because ye are not of God."))))

(bcp-roman-antiphonary-register
 'abraham-pater-vester
 '(:latin "Abraham pater vester * exsultávit ut vidéret diem meum: vidit, et gavísus est."
   :translations
   ((do . "Your father Abraham rejoiced to see My day * and he saw it, and was glad."))))

(bcp-roman-antiphonary-register
 'vide-domine-afflictionem
 '(:latin "Vide, Dómine, * afflictiónem meam, quóniam eréctus est inimícus meus."
   :translations
   ((do . "O Lord, behold my affliction; * for the enemy hath magnified himself."))))

(bcp-roman-antiphonary-register
 'in-tribulatione-invocavi
 '(:latin "In tribulatióne * invocávi Dóminum, et exaudívit me in latitúdine."
   :translations
   ((do . "I called upon the Lord * in my distress; and He answered me, and set me at large."))))

(bcp-roman-antiphonary-register
 'judicasti-domine-causam
 '(:latin "Judicásti, Dómine, * causam ánimæ meæ, defénsor vitæ meæ, Dómine Deus meus."
   :translations
   ((do . "O Lord, Thou hast pleaded the cause of my soul; * Thou hast redeemed my life, O Lord my God."))))

(bcp-roman-antiphonary-register
 'popule-meus-quid-feci
 '(:latin "Pópule meus, * quid feci tibi, aut quid moléstus fui? Respónde mihi."
   :translations
   ((do . "O My people, what have I done unto thee? * or wherein have I wearied thee? testify against Me."))))

(bcp-roman-antiphonary-register
 'numquid-redditur
 '(:latin "Numquid rédditur * pro bono malum, quia fodérunt fóveam ánimæ meæ."
   :translations
   ((do . "Shall evil be recompensed for good? * for they have digged a pit for My soul."))))

(bcp-roman-antiphonary-register
 'ego-daemonium-non-habeo
 '(:latin "Ego dæmónium non hábeo, * sed honorífico Patrem meum, dicit Dóminus."
   :translations
   ((do . "I have not a devil; * but I honour My Father, and ye do dishonour Me, saith the Lord."))))

(bcp-roman-antiphonary-register
 'ego-gloriam-meam
 '(:latin "Ego glóriam meam * non quæro: est qui quærat, et júdicet."
   :translations
   ((do . "I seek not Mine Own glory; * there is One That seeketh and judgeth."))))

(bcp-roman-antiphonary-register
 'amen-amen-dico-vobis-si-quis
 '(:latin "Amen, amen, dico vobis: * si quis sermónem meum serváverit, mortem non gustábit in ætérnum."
   :translations
   ((do . "Amen, Amen, * I say unto you: If a man keep My saying, he shall never see death."))))

(bcp-roman-antiphonary-register
 'tulerunt-lapides
 '(:latin "Tulérunt lápides * Judǽi, ut jácerent in eum: Jesus autem abscóndit se, et exívit de templo."
   :translations
   ((do . "Then took the Jews up stones * to cast at Him, but Jesus hid Himself, and went out of the temple."))))

;;; ─── Lent 6 (Palm Sunday) antiphons ──────────────────────────────────

;; Benedictus antiphon (Ant 2 in DO Quad6-0)
(bcp-roman-antiphonary-register
 'turba-multa
 '(:latin "Turba multa, * quæ convénerat ad diem festum, clamábat Dómino: Benedíctus qui venit in nómine Dómini: Hosánna in excélsis."
   :source composition
   :translations
   ((do . "Much people that were come to the Feast, cried * unto the Lord: Blessed is He That cometh in the Name of the Lord! Hosanna in the highest!"))))

;; Magnificat antiphon for Vespers I (Ant 1 in DO Quad6-0)
(bcp-roman-antiphonary-register
 'pater-juste-mundus
 '(:latin "Pater juste, * mundus te non cognóvit: ego autem novi te, quia tu me misísti."
   :source vulgate
   :ref "John 17:25"
   :translations
   ((do . "O just Father, * the world has not known thee: I however have known thee, for thou hast sent me."))))

;; Magnificat antiphon for Vespers II (Ant 3 in DO Quad6-0)
(bcp-roman-antiphonary-register
 'scriptum-est-enim-percutiam
 '(:latin "Scriptum est enim: * Percútiam pastórem, et dispergéntur oves gregis: postquam autem resurréxero, præcédam vos in Galilǽam: ibi me vidébitis, dicit Dóminus."
   :source vulgate
   :ref "Matt 26:31-32"
   :translations
   ((do . "It is written: I will smite the Shepherd, * and the sheep of the flock shall be scattered abroad, but after I am risen again, I will go before you into Galilee: there shall ye see Me, saith the Lord."))))

;; Lauds antiphons (Ant Laudes 1–5 in DO Quad6-0)
(bcp-roman-antiphonary-register
 'dominus-deus-auxiliator
 '(:latin "Dóminus Deus * auxiliátor meus: et ídeo non sum confúsus."
   :source vulgate
   :ref "Isa 50:7"
   :translations
   ((do . "The Lord God will help me * and therefore I am not confounded."))))

(bcp-roman-antiphonary-register
 'circumdantes-circumdederunt
 '(:latin "Circumdántes * circumdedérunt me: et in nómine Dómini vindicábor in eis."
   :source gallican
   :ref "Ps 117:11-12"
   :translations
   ((do . "They compassed me about, * yea, they compassed me about but in the Name of the Lord! I will destroy them."))))

(bcp-roman-antiphonary-register
 'judica-causam-meam
 '(:latin "Júdica causam meam: * defénde, quia potens es, Dómine."
   :source gallican
   :ref "Ps 118:154"
   :translations
   ((do . "Judge Thou my cause, * and redeem me, O Lord, for Thou art mighty to save."))))

(bcp-roman-antiphonary-register
 'cum-angelis-et-pueris
 '(:latin "Cum Angelis * et púeris fidéles inveniámur, triumphatóri mortis clamántes: Hosánna in excélsis."
   :source composition
   :translations
   ((do . "Fare we with Angels and men in faith to meet the Redeemer, * hailing the Slayer of death with joyful shouts of \"Hosanna in the highest!\""))))

(bcp-roman-antiphonary-register
 'confundantur-qui-me-persequuntur
 '(:latin "Confundántur * qui me persequúntur, et non confúndar ego, Dómine, Deus meus."
   :source gallican
   :ref "Jer 17:18"
   :translations
   ((do . "Let them be confounded that persecute me; * but let not me be confounded, O Lord my God."))))

;; Prime antiphon
(bcp-roman-antiphonary-register
 'pueri-hebraeorum-tollentes
 '(:latin "Púeri Hebræórum * tolléntes ramos olivárum, obviavérunt Dómino clamántes et dicéntes: Hosánna in excélsis."
   :source composition
   :translations
   ((do . "The Hebrew children took branches of olive-trees, * and went forth to meet the Lord, crying and saying: Hosanna in the highest!"))))

;; Terce antiphon
(bcp-roman-antiphonary-register
 'pueri-hebraeorum-vestimenta
 '(:latin "Púeri Hebræórum * vestiménta prosternébant in via, et clamábant, dicéntes: Hosánna Fílio David: benedíctus qui venit in nómine Dómini."
   :source composition
   :translations
   ((do . "The Hebrew children spread their garments in the way, * and cried, saying: Hosanna to the Son of David! Blessed is He that cometh in the Name of the Lord!"))))

;; Sext antiphon
(bcp-roman-antiphonary-register
 'tibi-revelavi-causam
 '(:latin "Tibi revelávi * causam meam, defénsor vitæ meæ, Dómine, Deus meus."
   :source gallican
   :ref "Jer 20:12"
   :translations
   ((do . "Unto thee have I opened my cause, * O Lord my God, Which art the Redeemer of my life."))))

;; None antiphon
(bcp-roman-antiphonary-register
 'invocabo-nomen-tuum
 '(:latin "Invocábo * nomen tuum, Dómine: ne avértas fáciem tuam a clamóre meo."
   :source gallican
   :ref "Lam 3:55-56"
   :translations
   ((do . "I will call * upon thy Name, O Lord: hide not thy face at my cry."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lenten capitulum registrations

;;; ─── Lent 1 capitula ──────────────────────────────────────────────────

(bcp-roman-capitulary-register
 'hortamur-vos
 '(:latin "Fratres: Hortámur vos, ne in vácuum grátiam Dei recipiátis. Ait enim: Témpore accépto exaudívi te, et in die salútis adjúvi te."
   :ref "2 Cor 6:1-2"
   :translations
   ((do . "Brothers, we exhort you, that you receive not the grace of God in vain. For he saith: In an accepted time have I heard thee; and in the day of salvation have I helped thee."))))

(bcp-roman-capitulary-register
 'ecce-nunc-tempus-cap
 '(:latin "Ecce nunc tempus acceptábile, ecce nunc dies salútis: némini dantes ullam offensiónem, ut non vituperétur ministérium nostrum."
   :ref "2 Cor 6:2-3"
   :translations
   ((do . "Behold, now is the acceptable time; behold, now is the day of salvation, giving no offense to any man, that our ministry be not blamed."))))

(bcp-roman-capitulary-register
 'ut-castigati
 '(:latin "Ut castigáti, et non mortificáti: quasi tristes, semper autem gaudéntes: sicut egéntes, multos autem locupletántes tamquam nihil habéntes, et ómnia possidéntes."
   :ref "2 Cor 6:9-10"
   :translations
   ((do . "As dying, and behold we live; as chastised, and not killed; as sorrowful, yet always rejoicing; as needy, yet enriching many; as having nothing, and possessing all things."))))

;;; ─── Lent 2 capitula ──────────────────────────────────────────────────

(bcp-roman-capitulary-register
 'rogamus-vos
 '(:latin "Fratres: Rogámus vos, et obsecrámus in Dómino Jesu: ut, quemádmodum accepístis a nobis, quómodo vos opórteat ambuláre, et placére Deo, sic et ambulétis, ut abundétis magis."
   :ref "1 Thess 4:1"
   :translations
   ((do . "For the rest therefore, brethren, we pray and beseech you in the Lord Jesus, that as you have received from us, how you ought to walk, and to please God, so also you would walk, that you may abound the more."))))

(bcp-roman-capitulary-register
 'haec-est-enim-voluntas
 '(:latin "Hæc est enim volúntas Dei, sanctificátio vestra: ut abstineátis vos a fornicatióne, ut sciat unusquísque vestrum vas suum possidére in sanctificatióne et honóre."
   :ref "1 Thess 4:3-4"
   :translations
   ((do . "For this is the will of God, your sanctification; that you should abstain from fornication, that every one of you should know how to possess his vessel in sanctification and honour."))))

(bcp-roman-capitulary-register
 'non-enim-vocavit
 '(:latin "Non enim vocávit nos Deus in immundítiam, sed in sanctificatiónem, in Christo Jesu Dómino nostro."
   :ref "1 Thess 4:7"
   :translations
   ((do . "For God hath not called us unto uncleanness, but unto sanctification in Christ Jesus our Lord."))))

;;; ─── Lent 3 capitula ──────────────────────────────────────────────────

(bcp-roman-capitulary-register
 'estote-imitatores-dei
 '(:latin "Fratres: Estóte imitatóres Dei, sicut fílii caríssimi: et ambuláte in dilectióne, sicut et Christus diléxit nos, et trádidit semetípsum pro nobis oblatiónem et hóstiam Deo in odórem suavitátis."
   :ref "Eph 5:1-2"
   :translations
   ((do . "Be ye, therefore, followers of God, as most dear children; And walk in love, as Christ also hath loved us, and hath delivered himself for us, an oblation and a sacrifice to God for an odour of sweetness."))))

(bcp-roman-capitulary-register
 'hoc-enim-scitote
 '(:latin "Hoc enim scitóte intellegéntes, quod omnis fornicátor, aut immúndus, aut avarus, quod est idolórum sérvitus, non habet hereditátem in regno Christi et Dei."
   :ref "Eph 5:5"
   :translations
   ((do . "For know you this and understand, that no fornicator, or unclean, or covetous person (which is a serving of idols), hath inheritance in the kingdom of Christ and of God."))))

(bcp-roman-capitulary-register
 'eratis-enim-aliquando
 '(:latin "Erátis enim aliquándo ténebræ, nunc autem lux in Dómino: ut fílii lucis ambuláte: fructus enim lucis est in omni bonitáte, et justítia, et veritáte."
   :ref "Eph 5:8-9"
   :translations
   ((do . "For you were heretofore darkness, but now light in the Lord. Walk then as children of the light. For the fruit of the light is in all goodness, and justice, and truth."))))

;;; ─── Lent 4 capitula ──────────────────────────────────────────────────

(bcp-roman-capitulary-register
 'scriptum-est-quoniam-abraham
 '(:latin "Fratres: Scriptum est, quóniam Abraham duos fílios hábuit: unum de ancílla, et unum de líbera: sed qui de ancílla, secúndum carnem natus est: qui autem de líbera, per repromissiónem: quæ sunt per allegoríam dicta."
   :ref "Gal 4:22-24"
   :translations
   ((do . "For it is written that Abraham had two sons: the one by a bondwoman, and the other by a free woman. But he who was of the bondwoman, was born according to the flesh: but he of the free woman, was by promise, which things are said by an allegory."))))

(bcp-roman-capitulary-register
 'laetare-sterilis
 '(:latin "Lætáre, stérilis, quæ non paris: erúmpe et clama, quæ non párturis: quia multi fílii desértæ, magis quam ejus, quæ habet virum."
   :ref "Gal 4:27"
   :translations
   ((do . "Rejoice, thou barren, that bearest not: break forth and cry, thou that travailest not: for many are the children of the desolate, more than of her that hath a husband."))))

(bcp-roman-capitulary-register
 'itaque-fratres-non-sumus
 '(:latin "Itaque, fratres, non sumus ancíllæ fílii, sed líberæ: qua libertáte Christus nos liberávit."
   :ref "Gal 4:31"
   :translations
   ((do . "So then, brethren, we are not the children of the bondwoman, but of the free: by the freedom wherewith Christ has made us free."))))

;;; ─── Lent 5 (Passion Sunday) capitula ─────────────────────────────────

(bcp-roman-capitulary-register
 'christus-assistens-pontifex
 '(:latin "Fratres: Christus assístens Póntifex futurórum bonórum, per ámplius et perféctius tabernáculum non manu factum, id est, non hujus creatiónis: neque per sánguinem hircórum aut vitulórum, sed per próprium sánguinem introívit semel in Sancta, ætérna redemptióne invénta."
   :ref "Heb 9:11-12"
   :translations
   ((do . "But Christ, being come an high priest of the good things to come, by a greater and more perfect tabernacle not made with hand, that is, not of this creation: Neither by the blood of goats, or of calves, but by his own blood, entered once into the holies, having obtained eternal redemption."))))

(bcp-roman-capitulary-register
 'si-enim-sanguis
 '(:latin "Si enim sanguis hircórum, et taurórum, et cinis vítulæ aspérsus inquinátos sanctíficat ad emundatiónem carnis: quanto magis sanguis Christi, qui per Spíritum Sanctum semetípsum óbtulit immaculátum Deo, emundábit consciéntiam nostram ab opéribus mórtuis, ad serviéndum Deo vivénti?"
   :ref "Heb 9:13-14"
   :translations
   ((do . "For if the blood of goats and of oxen, and the ashes of an heifer being sprinkled, sanctify such as are defiled, to the cleansing of the flesh: How much more shall the blood of Christ, who by the Holy Ghost offered himself unspotted unto God, cleanse our conscience from dead works, to serve the living God?"))))

(bcp-roman-capitulary-register
 'et-ideo-novi-testamenti
 '(:latin "Et ídeo novi testaménti mediátor est: ut, morte intercedénte, in redemptiónem eárum prævaricatiónum, quæ erant sub prióri testaménto, repromissiónem accípiant, qui vocáti sunt ætérnæ hereditátis in Christo Jesu, Dómino nostro."
   :ref "Heb 9:15"
   :translations
   ((do . "And therefore he is the mediator of the new testament: that by means of his death, for the redemption of those trangressions, which were under the former testament, they that are called may receive the promise of eternal inheritance."))))

;;; ─── Lent 6 (Palm Sunday) capitula ───────────────────────────────────

(bcp-roman-capitulary-register
 'hoc-enim-sentite
 '(:latin "Fratres: Hoc enim sentíte in vobis, quod et in Christo Jesu: qui, cum in forma Dei esset, non rapínam arbitrátus est esse se æquálem Deo: sed semetípsum exinanívit, formam servi accípiens, in similitúdinem hóminum factus, et hábitu invéntus ut homo."
   :ref "Phil 2:5-7"
   :translations
   ((do . "Brothers: For let this mind be in you, which was also in Christ Jesus: Who being in the form of God, thought it not robbery to be equal with God: But emptied himself, taking the form of a servant, being made in the likeness of men, and in habit found as a man."))))

(bcp-roman-capitulary-register
 'humiliavit-semetipsum
 '(:latin "Humiliávit semetípsum factus obédiens usque ad mortem, mortem autem crucis. Propter quod et Deus exaltávit illum, et donávit illi nomen, quod est super omne nomen."
   :ref "Phil 2:8-9"
   :translations
   ((do . "He humbled himself, becoming obedient unto death, even to the death of the cross. For which cause God also hath exalted him, and hath given him a name which is above all names."))))

(bcp-roman-capitulary-register
 'in-nomine-jesu
 '(:latin "In nómine Jesu omne genu flectátur cæléstium, terréstrium, et infernórum: et omnis lingua confiteátur, quia Dóminus Jesus Christus in glória est Dei Patris."
   :ref "Phil 2:10-11"
   :translations
   ((do . "That in the name of Jesus every knee should bow, of those that are in heaven, on earth, and under the earth: And that every tongue should confess that the Lord Jesus Christ is in the glory of God the Father."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lenten dominical Matins lessons and responsories (Lent 1–6)
;;
;; 6 Sunday datasets extracted from Divinum Officium Tempora files.
;; Each entry: (WEEK . (:lessons (L1..L9) :responsories (R1..R8))).
;; Same structure as `bcp-roman-tempora--dominical-matins'.
;; Non-Matins antiphons and capitula use antiphonary/capitulary symbols.

(defconst bcp-roman-season-lent--dominical-matins
  '(


    (1
     . (:lessons
        (
        (:ref "2 Cor 6:1-10" :source "De Epístola secúnda beáti Pauli Apóstoli ad Corínthios" :text "1 Adjuvántes autem exhortámur ne in vácuum grátiam Dei recipiátis. 2 Ait enim: Témpore accépto exaudívi te, et in die salútis adjúvi te. Ecce nunc tempus acceptábile, ecce nunc dies salútis. 3 Némini dantes ullam offensiónem, ut non vituperétur ministérium nostrum: 4 sed in ómnibus exhibeámus nosmetípsos sicut Dei minístros in multa patiéntia, in tribulatiónibus, in necessitátibus, in angústiis, 5 in plagis, in carcéribus, in seditiónibus, in labóribus, in vigíliis, in jejúniis, 6 in castitáte, in sciéntia, in longanimitáte, in suavitáte, in Spíritu Sancto, in caritáte non ficta, 7 in verbo veritátis, in virtúte Dei, per arma justítiæ a dextris et a sinístris, 8 per glóriam, et ignobilitátem, per infámiam, et bonam famam: ut seductóres, et veráces, sicut qui ignóti, et cógniti: 9 quasi moriéntes, et ecce vívimus: ut castigáti, et non mortificáti: 10 quasi tristes, semper autem gaudéntes: sicut egéntes, multos autem locupletántes: tamquam nihil habéntes, et ómnia possidéntes.")  ; L1
        (:ref "2 Cor 6:11-16" :text "11 Os nostrum patet ad vos, o Corínthii; cor nostrum dilatátum est. 12 Non angustiámini in nobis: angustiámini autem in viscéribus vestris: 13 eándem autem habéntes remuneratiónem, tamquam fíliis dico, dilatámini et vos. 14 Nolíte jugum dúcere cum infidélibus. Quæ enim participátio justítiæ cum iniquitáte? aut quæ socíetas luci ad ténebras? 15 quæ autem convéntio Christi ad Bélial? aut quæ pars fidéli cum infidéli? 16 qui autem consénsus templo Dei cum idólis? vos enim estis templum Dei vivi, sicut dicit Deus: Quóniam inhabitábo in illis, et inambulábo inter eos, et ero illórum Deus, et ipsi erunt mihi pópulus.")  ; L2
        (:ref "2 Cor 7:4-9" :text "4 Replétus sum consolatióne; superabúndo gáudio in omni tribulatióne nostra. 5 Nam et cum venissémus in Macedóniam, nullam réquiem hábuit caro nostra, sed omnem tribulatiónem passi sumus: foris pugnæ, intus timóres. 6 Sed qui consolátur húmiles, consolátus est nos Deus in advéntu Titi. 7 Non solum autem in advéntu ejus, sed étiam in consolatióne, qua consolátus est in vobis, réferens nobis vestrum desidérium, vestrum fletum, vestram æmulatiónem pro me, ita ut magis gaudérem. 8 Quóniam etsi contristávi vos in epístola, non me pœ́nitet: etsi pœnitéret, videns quod epístola illa (etsi ad horam) vos contristávit, 9 nunc gáudeo: non quia contristáti estis, sed quia contristáti estis ad pœniténtiam.")  ; L3
        (:ref "Sermo 4 de Quadragesima" :source "Sermo sancti Leónis Papæ" :text "Prædicatúrus vobis, dilectíssimi, sacratíssimum maximúmque jejúnium, quo áptius utar exórdio, quam ut verbis Apóstoli, in quo Christus loquebátur, incípiam, dicámque quod lectum est: Ecce nunc tempus acceptábile: ecce nunc dies salútis? Quamvis enim nulla sint témpora, quæ divínis non sint plena munéribus, et semper nobis ad misericórdiam Dei per ipsíus grátiam præstétur accéssus: nunc tamen ómnium mentes majóri stúdio ad spiritáles proféctus movéri, et amplióri fidúcia opórtet animári, quando ad univérsa pietátis offícia, illíus nos diéi, in quo redémpti sumus, recúrsus invítat: ut excéllens super ómnia passiónis Domínicæ sacraméntum, purificátis et corpóribus et ánimis celebrémus.")  ; L4
        (:text "Debebátur quidem tantis mystériis ita incessábilis devótio, et continuáta reveréntia, ut tales permanerémus in conspéctu Dei, quales nos in ipso Pascháli festo dignum est inveníri. Sed quia hæc fortitúdo paucórum est: et dum carnis fragilitáte austérior observántia relaxátur, dumque per várias actiónes vitæ hujus sollicitúdo disténditur, necésse est de mundáno púlvere étiam religiósa corda sordéscere: magna divínæ institutiónis salubritáte provísum est, ut ad reparándam méntium puritátem quadragínta nobis diérum exercitátio mederétur, in quibus aliórum témporum culpas, et pia ópera redímerent, et jejúnia casta decóquerent.")  ; L5
        (:text "Ingressúri ígitur, dilectíssimi, dies mýsticos, et purificándis ánimis atque corpóribus sacrátius institútos, præcéptis apostólicis obedíre curémus, emundántes nos ab omni inquinaménto carnis ac spíritus: ut castigátis colluctatiónibus, quæ sunt inter utrámque substántiam, ánimus, quem sub Dei gubernáculis constitútum, córporis sui decet esse rectórem, dominatiónis suæ obtíneat dignitátem: ut némini dantes ullam offensiónem, vituperatiónibus obloquéntium non simus obnóxii. Digna enim ab infidélibus reprehensióne carpémur, et nostro vítio linguæ ímpiæ in injúriam se religiónis armábunt, si jejunántium mores a puritáte perféctæ continéntiæ discrepárint. Non enim in sola abstinéntia cibi stat nostri summa jejúnii: aut fructuóse córpori esca subtráhitur, nisi mens ab iniquitáte revocétur.")  ; L6
        (:ref "Matt 4:1-11" :source "Léctio sancti Evangélii secúndum Matthǽum" :text "In illo témpore: Ductus est Jesus in desértum a Spíritu, ut tentarétur a diábolo. Et cum jejunásset quadragínta diébus et quadragínta nóctibus, póstea esúriit. Et réliqua. Homilía sancti Gregórii Papæ !Homilia 16 in Evangelia Dubitári a quibúsdam solet, a quo spíritu sit Jesus ductus in desértum, propter hoc quod súbditur: Assúmpsit eum diábolus in sanctam civitátem: et rursum: Assúmpsit eum in montem excélsum valde. Sed vere et absque ulla quæstióne conveniénter accípitur, ut a Sancto Spíritu in desértum ductus credátur: ut illuc eum suus Spíritus dúceret, ubi hunc ad tentándum malígnus spíritus inveníret. Sed ecce cum dícitur Deus homo vel in excélsum montem, vel in sanctam civitátem a diábolo assúmptus, mens réfugit crédere, humánæ hoc audíre aures expavéscunt. Qui tamen non esse incredibília ista cognóscimus, si in illo et ália facta pensámus.")  ; L7
        (:text "Certe iniquórum ómnium caput diábolus est: et hujus cápitis membra sunt omnes iníqui. An non diáboli membrum fuit Pilátus? an non diáboli membra Judǽi persequéntes, et mílites crucifigéntes Christum fuérunt? Quid ergo mirum, si se ab illo permísit in montem duci, qui se pértulit étiam a membris illíus crucifígi? Non est ergo indígnum Redemptóri nostro quod tentári vóluit, qui vénerat occídi. Justum quippe erat, ut sic tentatiónes nostras suis tentatiónibus vínceret, sicut mortem nostram vénerat sua morte superáre.")  ; L8
        (:text "Sed sciéndum nobis est, quia tribus modis tentátio ágitur: suggestióne, delectatióne et consénsu. Et nos cum tentámur, plerúmque in delectatiónem, aut étiam in consénsum lábimur: quia de carnis peccáto propagáti, in nobis ipsis étiam gérimus, unde certámina tolerámus. Deus vero, qui in útero Vírginis incarnátus, in mundum sine peccáto vénerat, nihil contradictiónis in semetípso tolerábat. Tentári ergo per suggestiónem pótuit: sed ejus mentem peccáti delectátio non momórdit. Atque ídeo omnis diabólica illa tentátio foris, non intus fuit.")  ; L9
        )
        :responsories
        (
        (:respond "Ecce nunc tempus acceptábile, ecce nunc dies salútis: commendémus nosmetípsos in multa patiéntia, in jejúniis multis, * Per arma justítiæ virtútis Dei." :verse "In ómnibus exhibeámus nosmetípsos sicut Dei minístros, in multa patiéntia, in jejúniis multis." :repeat "Per arma justítiæ virtútis Dei.")  ; R1
        (:respond "In ómnibus exhibeámus nosmetípsos sicut Dei minístros in multa patiéntia: * Ut non vituperétur ministérium nostrum." :verse "Ecce nunc tempus acceptábile, ecce nunc dies salútis: commendémus nosmetípsos in multa patiéntia." :repeat "Ut non vituperétur ministérium nostrum.")  ; R2
        (:respond "In jejúnio et fletu orábunt sacerdótes, dicéntes: * Parce, Dómine, parce pópulo tuo; et ne des hereditátem tuam in perditiónem." :verse "Inter vestíbulum et altáre plorábunt sacerdótes, dicéntes." :repeat "Parce, Dómine, parce pópulo tuo; et ne des hereditátem tuam in perditiónem.")  ; R3
        (:respond "Emendémus in mélius, quæ ignoránter peccávimus: ne súbito præoccupáti die mortis, quærámus spátium pœniténtiæ, et inveníre non possímus: * Atténde, Dómine, et miserére, quia peccávimus tibi." :verse "Adjuva nos, Deus salutáris noster, et propter honórem nóminis tui, Dómine, líbera nos." :repeat "Atténde, Dómine, et miserére, quia peccávimus tibi.")  ; R4
        (:respond "Derelínquat ímpius viam suam, et vir iníquus cogitatiónes suas, et revertátur ad Dóminum, et miserébitur ejus: * Quia benígnus et miséricors est, et præstábilis super malítia Dóminus Deus noster." :verse "Non vult Dóminus mortem peccatóris, sed ut convertátur et vivat." :repeat "Quia benígnus et miséricors est, et præstábilis super malítia Dóminus Deus noster.")  ; R5
        (:respond "Paradísi portas apéruit nobis jejúnii tempus: suscipiámus illud orántes, et deprecántes: * Ut in die resurrectiónis cum Dómino gloriémur." :verse "In ómnibus exhibeámus nosmetípsos sicut Dei minístros in multa patiéntia." :repeat "Ut in die resurrectiónis cum Dómino gloriémur.")  ; R6
        (:respond "Scíndite corda vestra, et non vestiménta vestra: et convertímini ad Dóminum Deum vestrum: * Quia benígnus et miséricors est." :verse "Derelínquat ímpius viam suam, et vir iníquus cogitatiónes suas, et revertátur ad Dóminum, et miserébitur ejus." :repeat "Quia benígnus et miséricors est.")  ; R7
        (:respond "Frange esuriénti panem tuum, et egénos vagósque induc in domum tuam: * Tunc erúmpet quasi mane lumen tuum, et anteíbit fáciem tuam justítia tua." :verse "Cum víderis nudum, óperi eum, et carnem tuam ne despéxeris." :repeat "Tunc erúmpet quasi mane lumen tuum, et anteíbit fáciem tuam justítia tua.")  ; R8
        (:respond "Angelis suis Deus mandávit de te, ut custódiant te in ómnibus viis tuis: * In mánibus portábunt te, ne umquam offéndas ad lápidem pedem tuum." :verse "Super áspidem et basilíscum ambulábis, et conculcábis leónem et dracónem." :repeat "In mánibus portábunt te, ne umquam offéndas ad lápidem pedem tuum.")  ; R9
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  tunc-invocabis

        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (cor-mundum-crea
                          o-domine-salvum-me-fac
                          sic-benedicam-te
                          in-spiritu-humilitatis
                          laudate-deum-caeli-caelorum)
        :benedictus-antiphon  ductus-est-jesus
        :lauds-capitulum      hortamur-vos

        ;; ── Prime ──────────────────────────────────────────────────
        :prime-antiphon        jesus-autem-cum-jejunasset
        ;; ── Terce ──────────────────────────────────────────────────
        :terce-antiphon        tunc-assumpsit-eum
        ;; ── Sext ───────────────────────────────────────────────────
        :sext-antiphon         non-in-solo-pane
        :sext-capitulum        ecce-nunc-tempus-cap
        ;; ── None ───────────────────────────────────────────────────
        :none-antiphon         dominum-deum-tuum-adorabis
        :none-capitulum        ut-castigati

        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon  ecce-nunc-tempus-acceptabile
        ))


    (2
     . (:lessons
        (
        (:ref "Gen 27:1-10" :source "De libro Génesis" :text "1 Sénuit autem Isaac, et calligavérunt óculi ejus, et vidére non póterat: vocavítque Esau fílium suum majórem, et dixit ei: Fili mi! Qui respóndit: Adsum. 2 Cui pater: Vides, inquit, quod senúerim et ignórem diem mortis meæ. 3 Sume arma tua, pháretram, et arcum, et egrédere foras: cumque venátu áliquid apprehénderis, 4 fac mihi inde pulméntum sicut velle me nosti, et affer ut cómedam: et benedícat tibi ánima mea ántequam móriar. 5 Quod cum audísset Rebécca, et ille abiísset in agrum ut jussiónem patris impléret, 6 dixit fílio suo Jacob: Audívi patrem tuum loquéntem cum Esau fratre tuo, et dicéntem ei: 7 Affer mihi de venatióne tua, et fac cibos ut cómedam, et benedícam tibi coram Dómino ántequam móriar. 8 Nunc ergo fili mi, acquiésce consíliis meis; 9 et pergens ad gregem, affer mihi duos hædos óptimos, ut fáciam ex eis escas patri tuo, quibus libénter véscitur: 10 quas cum intúleris, et coméderit, benedícat tibi priúsquam moriátur.")  ; L1
        (:ref "Gen 27:11-20" :text "11 Cui ille respóndit: Nosti quod Esau frater meus homo pilósus sit, et ego lenis: 12 si attractáverit me pater meus, et sénserit, tímeo ne putet sibi voluísse illúdere, et indúcam super me maledictiónem pro benedictióne. 13 Ad quem mater: In me sit, ait, ista maledíctio, fili mi: tantum audi vocem meam, et pergens, affer quæ dixi. 14 Abiit, et áttulit, dedítque matri. Parávit illa cibos, sicut velle nóverat patrem illíus. 15 Et véstibus Esau valde bonis, quas apud se habébat domi, índuit eum: 16 pelliculásque hædórum circúmdedit mánibus, et colli nuda protéxit. 17 Dedítque pulméntum, et panes, quos cóxerat, trádidit. 18 Quibus illátis, dixit: Pater mi! At ille respóndit: Audio. Quis es tu, fili mi? 19 Dixítque Jacob: Ego sum primogénitus tuus Esau: feci sicut præcepísti mihi: surge, sede, et cómede de venatióne mea, ut benedícat mihi ánima tua. 20 Rursúmque Isaac ad fílium suum: Quómodo, inquit, tam cito inveníre potuísti, fili mi? Qui respóndit: Volúntas Dei fuit ut cito occúrreret mihi quod volébam.")  ; L2
        (:ref "Gen 27:21-29" :text "21 Dixítque Isaac: Accéde huc ut tangam te, fili mi, et probem utrum tu sis fílius meus Esau, an non. 22 Accéssit ille ad patrem, et, palpáto eo, dixit Isaac: Vox quidem, vox Jacob est: sed manus, manus sunt Esau. 23 Et non cognóvit eum, quia pilósæ manus similitúdinem majóris exprésserant. Benedícens ergo illi, 24 ait: Tu es fílius meus Esau? Respóndit: Ego sum. 25 At ille: Affer mihi, inquit, cibos de venatióne tua, fili mi, ut benedícat tibi ánima mea. Quos cum oblátos comedísset, óbtulit ei étiam vinum. Quo hausto, 26 dixit ad eum: Accéde ad me, et da mihi ósculum, fili mi. 27 Accéssit, et osculátus est eum. Statímque ut sensit vestimentórum illíus flagrántiam, benedícens illi, ait: Ecce odor fílii mei sicut odor agri pleni, cui benedíxit Dóminus. 28 Det tibi Deus de rore cæli, et de pinguédine terræ abundántiam fruménti et vini. 29 Et sérviant tibi pópuli, et adórent te tribus: esto dóminus fratrum tuórum, et incurvéntur ante te fílii matris tuæ. Qui maledíxerit tibi, sit ille maledíctus: et qui benedíxerit tibi, benedictiónibus repleátur.")  ; L3
        (:ref "Cap. 10, tom. 4; post init." :source "Ex libro sancti Augustíni Epíscopi contra mendacium" :text "Jacob quod matre fecit auctóre, ut patrem fállere viderétur, si diligénter et fidéliter attendátur, non est mendácium, sed mystérium. Quæ si mendácia dixérimus, omnes étiam parábolæ ac figúræ significandárum quarumcúmque rerum, quæ non ad proprietátem accipiéndæ sunt, sed in eis áliud ex álio est intelligéndum, dicéntur esse mendácia: quod absit omníno. Nam qui hoc putat, trópicis étiam tam multis locutiónibus ómnibus potest hanc importáre calúmniam; ita ut et hæc ipsa, quæ appellátur metáphora, hoc est, de re própria ad rem non própriam verbi alicújus usurpáta translátio, possit ista ratióne mendácium nuncupári.")  ; L4
        (:text "Quæ significántur enim, útique ipsa dicúntur: putántur autem mendácia, quóniam non ea quæ vere significántur, dicta intelligúntur; sed ea, quæ falsa sunt, dicta esse credúntur. Hoc ut exémplis fiat plánius, idípsum quod Jacob fecit, atténde. Hædínis certe péllibus membra contéxit. Si causam próximam requirámus, mentítum putábimus: hoc enim fecit, ut putarétur esse qui non erat. Si autem hoc factum ad illud, propter quod significándum revéra factum est, referátur: per hædínas pelles, peccáta; per eum vero, qui eis se opéruit, ille significátus est, qui non sua, sed aliéna peccáta portávit.")  ; L5
        (:text "Verax ergo significátio nullo modo mendácium recte dici potest: ut autem in facto, ita et in verbo. Nam cum ei pater dixísset: Quis es tu, fili? ille respóndit: Ego sum Esau primogénitus tuus. Hoc si referátur ad duos illos géminos, mendácium vidébitur: si autem ad illud, propter quod significándum ista gesta dictáque conscrípta sunt; ille est hic intelligéndus in córpore suo, quod est ejus Ecclésia, qui de hac re loquens, ait: Cum vidéritis Abraham, et Isaac et Jacob et omnes Prophétas in regno Dei, vos autem expélli foras. Et, Vénient ab Oriénte et Occidénte, et Aquilóne et Austro, et accúmbent in regno Dei. Et, Ecce sunt novíssimi qui erant primi: et sunt primi, qui erant novíssimi. Sic enim quodámmodo minor majóris primátum frater ábstulit, atque in se tránstulit fratris.")  ; L6
        (:ref "Matt 17:1-9" :source "Léctio sancti Evangélii secúndum Matthǽum" :text "In illo témpore: Assúmpsit Jesus Petrum, et Jacóbum, et Joánnem fratrem ejus, et duxit illos in montem excélsum seórsum: et transfigurátus est ante eos. Et réliqua. De Homilía sancti Leónis Papæ !Ex Homil. de Transfiguratione Domini Assúmpsit Jesus Petrum, et Jacóbum, et fratrem ejus Joánnem, et conscénso cum eis seórsum monte præcélso, claritátem suæ glóriæ demonstrávit: quia licet intellexíssent in eo majestátem Dei, ipsíus tamen córporis, quo divínitas tegebátur, poténtiam nesciébant. Et ídeo próprie signantérque promíserat, quosdam de astántibus discípulis non prius gustáre mortem, quam vidérent Fílium hóminis veniéntem in regno suo, id est, in régia claritáte, quam spiritáliter ad natúram suscépti hóminis pertinéntem, his tribus viris vóluit esse conspícuam. Nam illam ipsíus Deitátis ineffábilem et inaccessíbilem visiónem, quæ in ætérnam vitam mundis corde servátur, nullo modo mortáli adhuc carne circúmdati intuéri póterant et vidére.")  ; L7
        (:text "Dicénte Patre: Hic est Fílius meus diléctus, in quo mihi bene complácui, ipsum audíte: nonne evidénter audítum est: Hic est Fílius meus, cui ex me et mecum esse sine témpore est? quia nec génitor génito prior, nec génitus est genitóre postérior. Hic est Fílius meus, quem a me non séparat Déitas, non dívidit potéstas, non discérnit ætérnitas. Hic est Fílius meus, non adoptívus, sed próprius: non aliúnde creátus, sed ex me génitus: nec de ália natúra mihi factus comparábilis, sed de mea esséntia mihi natus æquális.")  ; L8
        (:text "Hic est Fílius meus, per quem ómnia facta sunt, et sine quo factum est nihil: qui ómnia quæ fácio, simíliter facit; et quidquid óperor, inseparabíliter mecum atque indifferénter operátur. Hic est Fílius meus, qui eam, quam mecum habet æqualitátem, non rapína appétiit, nec usurpatióne præsúmpsit: sed manens in forma glóriæ meæ, ut ad reparándum genus humánum exsequerétur commúne consílium, usque ad formam servílem inclinávit incommutábilem Deitátem. Hunc ergo, in quo mihi per ómnia bene compláceo, et cujus prædicatióne maniféstor, cujus humilitáte claríficor, incunctánter audíte: quia ipse est véritas et vita, ipse virtus mea atque sapiéntia.")  ; L9
        )
        :responsories
        (
        (:respond "Tolle arma tua, pháretram et arcum, et affer de venatióne tua, ut cómedam: * Et benedícat tibi ánima mea." :verse "Cumque venátu áliquid attúleris, fac mihi inde pulméntum, ut cómedam." :repeat "Et benedícat tibi ánima mea.")  ; R1
        (:respond "Ecce odor fílii mei sicut odor agri pleni, cui benedíxit Dóminus: créscere te fáciat Deus meus sicut arénam maris: * Et donet tibi de rore cæli benedictiónem." :verse "Deus autem omnípotens benedícat tibi, atque multíplicet." :repeat "Et donet tibi de rore cæli benedictiónem.")  ; R2
        (:respond "Det tibi Deus de rore cæli et de pinguédine terræ abundántiam: sérviant tibi tribus et pópuli: * Esto dóminus fratrum tuórum." :verse "Et incurvéntur ante te fílii matris tuæ." :repeat "Esto dóminus fratrum tuorum.")  ; R3
        (:respond "Dum exíret Jacob de terra sua, vidit glóriam Dei, et ait: Quam terríbilis est locus iste! * Non est hic áliud, nisi domus Dei, et porta cæli." :verse "Vere Deus est in loco isto, et ego nesciébam." :repeat "Non est hic áliud, nisi domus Dei, et porta cæli.")  ; R4
        (:respond "Si Dóminus Deus meus fúerit mecum in via ista, per quam ego ámbulo, et custodíerit me, et déderit mihi panem ad edéndum, et vestiméntum quo opériar, et revocáverit me cum salúte: * Erit mihi Dóminus in refúgium, et lapis iste in signum." :verse "Surgens ergo mane Jacob, tulit lápidem quem supposúerat cápiti suo, et eréxit in títulum, fundénsque óleum désuper, dixit." :repeat "Erit mihi Dóminus in refúgium, et lapis iste in signum.")  ; R5
        (:respond "Erit mihi Dóminus in Deum, et lapis iste quem eréxi in títulum, vocábitur domus Dei: et de univérsis quæ déderis mihi, * Décimas et hóstias pacíficas ófferam tibi." :verse "Si revérsus fúero próspere ad domum patris mei." :repeat "Décimas et hóstias pacíficas ófferam tibi.")  ; R6
        (:respond "Dixit Angelus ad Jacob: * Dimítte me, auróra est. Respóndit ei: Non dimíttam te, nisi benedíxeris mihi. Et benedíxit ei in eódem loco." :verse "Cumque surrexísset Jacob, ecce vir luctabátur cum eo usque mane: et cum vidéret quod eum superáre non posset, dixit ad eum." :repeat "Dimítte me, auróra est. Respóndit ei: Non dimíttam te, nisi benedíxeris mihi. Et benedíxit ei in eódem loco.")  ; R7
        (:respond "Vidi Dóminum fácie ad fáciem: * Et salva facta est ánima mea." :verse "Et dixit mihi: Nequáquam vocáberis Jacob, sed Israël erit nomen tuum." :repeat "Et salva facta est ánima mea.")  ; R8
        (:respond "Cum audísset Jacob quod Esau veníret contra eum, divísit fílios suos et uxóres, dicens: Si percússerit Esau unam turmam, salvábitur áltera. * Líbera me, Dómine, qui dixísti mihi: * Multiplicábo semen tuum sicut stellas cæli, et sicut arénam maris, quæ præ multitúdine numerári non potest." :verse "Dómine, qui dixísti mihi, Revértere in terram nativitátis tuæ: Dómine, qui pascis me a juventúte mea." :repeat "Líbera me, Dómine, qui dixísti mihi.")  ; R9
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  visionem-quam-vidistis

        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (domine-labia-mea
                          dextera-domini-fecit
                          factus-est-adjutor
                          trium-puerorum-cantemus
                          statuit-ea-in-aeternum)
        :benedictus-antiphon  assumpsit-jesus-discipulos
        :lauds-capitulum      rogamus-vos

        ;; ── Prime ──────────────────────────────────────────────────
        :prime-antiphon        domine-bonum-est-nos
        ;; ── Terce ──────────────────────────────────────────────────
        :terce-antiphon        domine-bonum-est-nos
        ;; ── Sext ───────────────────────────────────────────────────
        :sext-antiphon         faciamus-hic-tria
        :sext-capitulum        haec-est-enim-voluntas
        ;; ── None ───────────────────────────────────────────────────
        :none-antiphon         visionem-quam-vidistis
        :none-capitulum        non-enim-vocavit

        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon  visionem-quam-vidistis
        ))


    (3
     . (:lessons
        (
        (:ref "Gen 37:2-10" :source "De libro Génesis" :text "2 Joseph, cum sédecim esset annórum, pascébat gregem cum frátribus suis adhuc puer: et erat cum fíliis Balæ et Zelphæ uxórum patris sui: accusavítque fratres suos apud patrem crímine péssimo. 3 Israël autem diligébat Joseph super omnes fílios suos, eo quod in senectúte genuísset eum: fecítque ei túnicam polýmitam. 4 Vidéntes autem fratres ejus quod a patre plus cunctis fíliis amarétur, óderant eum, nec póterant ei quidquam pacífice loqui. 5 Accidit quoque ut visum sómnium reférret frátribus suis: quæ causa majóris ódii seminárium fuit. 6 Dixítque ad eos: Audíte sómnium meum quod vidi: 7 putábam nos ligáre manípulos in agro: et quasi consúrgere manípulum meum, et stare, vestrósque manípulos circumstántes adoráre manípulum meum. 8 Respondérunt fratres ejus: Numquid rex noster eris? aut subiciémur ditióni tuæ? Hæc ergo causa somniórum atque sermónum, invídiæ et ódii fómitem ministrávit. 9 Aliud quoque vidit sómnium, quod narrans frátribus, ait: Vidi per sómnium, quasi solem, et lunam, et stellas úndecim adoráre me. 10 Quod cum patri suo, et frátribus retulísset, increpávit eum pater suus, et dixit: Quid sibi vult hoc sómnium quod vidísti? num ego et mater tua, et fratres tui adorábimus te super terram?")  ; L1
        (:ref "Gen 37:11-20" :text "11 Invidébant ei ígitur fratres sui: pater vero rem tácitus considerábat. 12 Cumque fratres illíus in pascéndis grégibus patris moraréntur in Sichem, 13 dixit ad eum Israël: Fratres tui pascunt oves in Síchimis: veni, mittam te ad eos. Quo respondénte, 14 Præsto sum, ait ei: Vade, et vide si cuncta próspera sint erga fratres tuos, et pécora: et renúntia mihi quid agátur. Missus de valle Hebron, venit in Sichem: 15 invenítque eum vir errántem in agro, et interrogávit quid quǽreret. 16 At ille respóndit: Fratres meos quæro: índica mihi ubi pascant greges. 17 Dixítque ei vir: Recessérunt de loco isto: audívi autem eos dicéntes: Eámus in Dóthain. Perréxit ergo Joseph post fratres suos, et invénit eos in Dóthain. 18 Qui cum vidíssent eum procul, ántequam accéderet ad eos, cogitavérunt illum occídere: 19 et mútuo loquebántur: Ecce somniátor venit: 20 veníte, occidámus eum, et mittámus in cistérnam véterem: dicemúsque: Fera péssima devorávit eum: et tunc apparébit quid illi prosint sómnia sua.")  ; L2
        (:ref "Gen 37:21-28" :text "21 Audiens autem hoc Ruben, nitebátur liberáre eum de mánibus eórum, et dicébat: 22 Non interficiátis ánimam ejus, nec effundátis sánguinem: sed proícite eum in cistérnam hanc, quæ est in solitúdine, manúsque vestras serváte innóxias: hoc autem dicébat, volens erípere eum de mánibus eórum, et réddere patri suo. 23 Conféstim ígitur ut pervénit ad fratres suos, nudavérunt eum túnica talári et polýmita: 24 miserúntque eum in cistérnam véterem, quæ non habébat aquam. 25 Et sedéntes ut coméderent panem, vidérunt Ismaëlítas viatóres veníre de Gálaad, et camélos eórum portántes arómata, et resínam, et stacten in Ægýptum. 26 Dixit ergo Judas frátribus suis: Quid nobis prodest si occidérimus fratrem nostrum, et celavérimus sánguinem ipsíus? 27 mélius est ut venundétur Ismaëlítis, et manus nostræ non polluántur: frater enim et caro nostra est. Acquievérunt fratres sermónibus illíus. 28 Et prætereúntibus Madianítis negotiatóribus, extrahéntes eum de cistérna, vendidérunt eum Ismaëlítis, vigínti argénteis: qui duxérunt eum in Ægýptum.")  ; L3
        (:ref "Cap. 1." :source "Ex libro sancti Ambrósii Epíscopi de sancto Joseph" :text "Sanctórum vita céteris norma vivéndi est. Ideóque digéstam plénius accépimus sériem Scripturárum; ut dum Abraham, Isaac, et Jacob, ceterósque justos legéndo cognóscimus, velut quemdam nobis innocéntiæ trámitem, virtúte eórum reserátum imitántibus vestígiis persequámur. De quibus mihi cum frequens tractátus fúerit, hódie sancti Joseph história occúrrit: in quo cum plúrima fúerint génera virtútum, præcípue tamen insígne effúlsit castimóniæ. Justum est ígitur, ut cum in Abraham didicéritis ímpigram fídei devotiónem, in Isaac sincéræ mentis puritátem, in Jacob singulárem ánimi laborúmque patiéntiam: ex illa generalitáte virtútum in ipsas spécies disciplinárum intendátis ánimum.")  ; L4
        (:text "Sit ígitur nobis propósitus sanctus Joseph tamquam spéculum castitátis. In ejus enim móribus, in ejus áctibus lucet pudicítia, et quidam splendet castimóniæ comes, nitor grátiæ. Unde étiam a paréntibus plus quam céteri fílii diligebátur. Sed ea res invídiæ fuit: quod siléntio prætereúndum non fuit: hinc enim arguméntum totíus históriæ procéssit: simul ut cognoscámus, perféctum virum non movéri ulciscéndi dolóris invídia, nec malórum repéndere vicem. Unde et David ait: Si réddidi retribuéntibus mihi mala.")  ; L5
        (:text "Quid autem esset, quod præférri Joseph mererétur céteris, si aut lædéntes læsísset, aut diligéntes dilexísset? Hoc enim pleríque fáciunt. Sed illud mirábile, si díligas inimícum tuum: quod Salvátor docet. Jure ergo mirándus, qui hoc fecit ante Evangélium, ut læsus párceret, appetítus ignósceret, vénditus non reférret injúriam, sed grátiam pro contumélia sólveret: quod post Evangélium omnes didícimus, et serváre non póssumus. Discámus ergo et Sanctórum invídiam, ut imitémur patiéntiam: et cognoscámus, illos non natúræ præstantióris fuísse, sed observantióris: nec vítia nescísse, sed emendásse. Quod si invídia étiam Sanctos adússit, quanto magis cavéndum est, ne inflámmet peccatóres?")  ; L6
        (:ref "Luc 11:14-28" :source "Léctio sancti Evangélii secúndum Lucam" :text "In illo témpore: Erat Jesus eíciens dæmónium, et illud erat mutum. Et cum ejecísset dæmónium, locútus est mutus, et admirátæ sunt turbæ. Et réliqua. Homilía sancti Bedæ Venerábilis Presbýteri !Lib. 4, cap. 48, in cap. 11 Lucæ Dæmoníacus iste apud Matthǽum non solum mutus, sed et cæcus fuísse narrátur: curatúsque dícitur a Dómino, ita ut loquerétur, et vidéret. Tria ergo signa simul in uno hómine perpetráta sunt: cæcus videt, mutus lóquitur, posséssus a dǽmone liberátur. Quod et tunc quidem carnáliter factum est, sed et cotídie complétur in conversióne credéntium: ut, expúlso primum dǽmone, fídei lumen aspíciant; deínde ad laudes Dei tacéntia prius ora laxéntur. Quidam autem ex eis dixérunt: in Beélzebub príncipe dæmoniórum éicit dæmónia. Non hæc áliqui de turba, sed pharisǽi calumniabántur, et scribæ, sicut álii Evangelístæ testántur.")  ; L7
        (:text "Turbis quippe, quæ minus erudítæ videbántur, Dómini semper facta mirántibus; illi contra, vel negáre hæc, vel quæ negáre nequíverant, sinístra interpretatióne pervértere laborábant: quasi non hæc divinitátis, sed immúndi spíritus ópera fuíssent. Et álii tentántes, signum de cælo quærébant ab eo. Vel in morem Elíæ ignem de sublími veníre cupiébant; vel in similitúdinem Samuélis témpore æstívo mugíre tonítrua, coruscáre fúlgura, imbres rúere: quasi non possent et illa calumniári, et dícere, ex occúltis et váriis aëris passiónibus accidísse. At tu, qui calumniáris ea, quæ óculis vides, manu tenes, utilitáte sentis; quid féceris de iis, quæ de cælo vénerint? Utique respondébis, et magos in Ægýpto multa signa fecísse de cælo.")  ; L8
        (:text "Ipse autem ut vidit cogitatiónes eórum, dixit eis: Omne regnum in seípsum divísum desolábitur, et domus supra domum cadet. Non ad dicta, sed ad cogitáta respóndit: ut vel sic compelleréntur crédere poténtiæ ejus, qui cordis vidébat occúlta. Si autem omne regnum in seípsum divísum desolátur; ergo Patris et Fílii et Spíritus Sancti regnum non est divísum; quod sine ulla contradictióne, non áliquo impúlsu desolándum, sed ætérna est stabilitáte mansúrum. Si autem sátanas in seípsum divísus est: quómodo stabit regnum ipsíus, quia dícitis, in Beélzebub ejícere me dæmónia? Hoc dicens, ex ipsórum confessióne volébat intélligi, quod in eum non credéndo, in regno diáboli esse elegíssent, quod útique advérsum se divísum stare non posset.")  ; L9
        )
        :responsories
        (
        (:respond "Vidéntes Joseph a longe, loquebántur mútuo fratres, dicéntes: Ecce somniátor venit: * Veníte, occidámus eum, et videámus si prosint illi sómnia sua." :verse "Cumque vidíssent Joseph fratres sui, quod a patre cunctis frátribus plus amarétur, óderant eum, nec póterant ei quidquam pacífice loqui, unde et dicébant." :repeat "Veníte, occidámus eum, et videámus si prosint illi sómnia sua.")  ; R1
        (:respond "Dixit Judas frátribus suis: Ecce Ismaëlítæ tránseunt; veníte, venumdétur, et manus nostræ non polluántur: * Caro enim et frater noster est." :verse "Quid enim prodest, si occidérimus fratrem nostrum, et celavérimus sánguinem ipsíus? mélius est ut venumdétur." :repeat "Caro enim et frater noster est.")  ; R2
        (:respond "Extrahéntes Joseph de lacu, vendidérunt Ismaëlítæ vigínti argénteis: * Reversúsque Ruben ad púteum, cum non invenísset eum, scidit vestiménta sua cum fletu, et dixit: * Puer non compáret, et ego quo ibo?" :verse "At illi, intíncta túnica Joseph in sánguine hædi, misérunt qui ferret eam ad patrem, et díceret: Vide, si túnica fílii tui sit, an non." :repeat "Puer non compáret, et ego quo ibo?")  ; R3
        (:respond "Videns Jacob vestiménta Joseph, scidit vestiménta sua cum fletu, et dixit: * Fera péssima devorávit fílium meum Joseph." :verse "Tulérunt autem fratres ejus túnicam illíus, mitténtes ad patrem: quam cum cognovísset pater, ait." :repeat "Fera péssima devorávit fílium meum Joseph.")  ; R4
        (:respond "Joseph dum intráret in terram Ægýpti, linguam quam non nóverat, audívit: manus ejus in labóribus serviérunt: * Et lingua ejus inter príncipes loquebátur sapiéntiam." :verse "Humiliavérunt in compédibus pedes ejus: ferrum petránsiit ánimam ejus, donec veníret verbum ejus." :repeat "Et lingua ejus inter príncipes loquebátur sapiéntiam.")  ; R5
        (:respond "Meménto mei, dum bene tibi fúerit: * Ut súggeras pharaóni, ut edúcat me de isto cárcere: * Quia furtim sublátus sum, et hic ínnocens in lacum missus sum." :verse "Tres enim adhuc dies sunt, post quos recordábitur phárao ministérii tui, et restítuet te in gradum prístinum: tunc meménto mei." :repeat "Quia furtim sublátus sum, et hic ínnocens in lacum missus sum.")  ; R6
        (:respond "Mérito hæc pátimur, quia peccávimus in fratrem nostrum, vidéntes angústias ánimæ ejus, dum deprecarétur nos, et non audívimus: * Idcírco venit super nos tribulátio." :verse "Dixit Ruben frátribus suis: Numquid non dixi vobis, Nolíte peccáre in púerum; et non audístis me?" :repeat "Idcírco venit super nos tribulatio.")  ; R7
        (:respond "Dixit Ruben frátribus suis: Numquid non dixi vobis, Nolíte peccáre in púerum, et non audístis me? * En sanguis ejus exquíritur." :verse "Mérito hæc pátimur, quia peccávimus in fratrem nostrum, vidéntes angústias ánimæ ejus, dum deprecarétur nos, et non audívimus." :repeat "En sanguis ejus exquíritur.")  ; R8
        (:respond "Lamentabátur Jacob de duóbus fíliis suis: Heu me, dolens sum de Joseph pérdito, et tristis nimis de Bénjamin ducto pro alimóniis: * Precor cæléstem Regem, ut me doléntem nímium fáciat eos cérnere." :verse "Prostérnens se Jacob veheménter cum lácrimis pronus in terram, et adórans ait." :repeat "Precor cæléstem Regem, ut me doléntem nímium fáciat eos cérnere.")  ; R9
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  dixit-autem-pater-ad-servos

        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (fac-benigne-in-bona
                          dominus-mihi-adjutor
                          adhaesit-anima-mea
                          vim-virtutis-suae
                          sol-et-luna-laudate)
        :benedictus-antiphon  cum-fortis-armatus
        :lauds-capitulum      estote-imitatores-dei

        ;; ── Prime ──────────────────────────────────────────────────
        :prime-antiphon        et-cum-ejecisset
        ;; ── Terce ──────────────────────────────────────────────────
        :terce-antiphon        si-in-digito-dei
        ;; ── Sext ───────────────────────────────────────────────────
        :sext-antiphon         qui-non-colligit-mecum
        :sext-capitulum        hoc-enim-scitote
        ;; ── None ───────────────────────────────────────────────────
        :none-antiphon         cum-immundus-spiritus
        :none-capitulum        eratis-enim-aliquando

        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon  extollens-vocem
        ))


    (4
     . (:lessons
        (
        (:ref "Exod 3:1-6" :source "De libro Exodi" :text "1 Móyses autem pascébat oves Jethro sóceri sui sacerdótis Mádian; cumque minásset gregem ad interióra desérti, venit ad montem Dei Horeb. 2 Apparuítque ei Dóminus in flamma ignis de médio rubi; et vidébat quod rubus ardéret et non comburerétur. 3 Dixit ergo Móyses: Vadam, et vidébo visiónem hanc magnam, quare non comburátur rubus. 4 Cernens autem Dóminus quod pérgeret ad vidéndum, vocávit eum de médio rubi, et ait: Móyses, Móyses! Qui respóndit: Adsum. 5 At ille: Ne apprópies, inquit, huc: solve calceaméntum de pédibus tuis; locus enim, in quo stas, terra sancta est. 6 Et ait: Ego sum Deus patris tui, Deus Abraham, Deus Isaac, et Deus Jacob. Abscóndit Móyses fáciem suam: non enim audébat aspícere contra Deum.")  ; L1
        (:ref "Exod 3:7-10" :text "7 Cui ait Dóminus: Vidi afflictiónem pópuli mei in Ægýpto, et clamórem ejus audívi propter durítiam eórum qui præsunt opéribus: 8 et sciens dolórem ejus, descéndi ut líberem eum de mánibus Ægyptiórum, et edúcam de terra illa in terram bonam et spatiósam, in terram quæ fluit lacte et melle, ad loca Chananǽi, et Hethǽi, et Amorrhǽi, et Pherezǽi, et Hevǽi, et Jebusǽi. 9 Clamor ergo filiórum Israël venit ad me: vidíque afflictiónem eórum, qua ab Ægýptiis opprimúntur. 10 Sed veni, et mittam te ad Pharaónem, ut edúcas pópulum meum, fílios Israël de Ægýpto.")  ; L2
        (:ref "Exod 3:11-15" :text "11 Dixítque Móyses ad Deum: Quis sum ego, ut vadam ad Pharaónem, et edúcam fílios Israël de Ægýpto? 12 Qui dixit ei: Ego ero tecum: et hoc habébis signum, quod míserim te: Cum edúxeris pópulum de Ægýpto, immolábis Deo super montem istum. 13 Ait Móyses ad Deum: Ecce, ego vadam ad fílios Israël, et dicam eis: Deus patrum vestrórum misit me ad vos. Si díxerint mihi: Quod est nomen ejus? quid dicam eis? 14 Dixit Deus ad Móysen: Ego sum qui sum. Ait: Sic dices fíliis Israël: Qui est, misit me ad vos. 15 Dixítque íterum Deus ad Móysen: Hæc dices fíliis Israël: Dóminus Deus patrum vestrórum, Deus Abraham, Deus Isaac, et Deus Jacob, misit me ad vos; hoc nomen mihi est in ætérnum, et hoc memoriále meum in generatiónem et generatiónem.")  ; L3
        (:ref "Homilia 1 de jejúnio, ante med." :source "Sermo sancti Basilíi Magni" :text "Móysen per jejúnium nóvimus in montem ascendísse: neque enim áliter ausus esset vérticem fumántem adíre, atque in calíginem íngredi, nisi jejúnio munítus. Per jejúnium mandáta dígito Dei in tábulis conscrípta suscépit. Item supra montem jejúnium legis latæ conciliátor fuit: inférius vero, gula ad idololatríam pópulum dedúxit, ac contaminávit. Sedit, inquit, pópulus manducáre et bíbere, et surrexérunt lúdere. Quadragínta diérum labórem ac perseverántiam, Dei servo contínuo jejunánte ac oránte, una tantum pópuli ebríetas cassam irritámque réddidit. Quas enim tábulas Dei dígito conscríptas jejúnium accépit, has ebríetas contrívit: Prophéta sanctíssimo indígnum existimánte, vinoléntum pópulum a Deo legem accípere.")  ; L4
        (:text "Uno témporis moménto ob gulam pópulus ille per máxima prodígia Dei cultum edóctus, in Ægyptíacam idololatríam turpíssime devolútus est. Ex quo si utrúmque simul cónferas, vidére licet, jejúnium ad Deum dúcere, delícias vero salútem pérdere. Quid Esau inquinávit, servúmque fratris réddidit? nonne esca una, propter quam primogénita véndidit? Samuélem vero nonne per jejúnium orátio largíta est matri? Quid fortíssimum Samsónem inexpugnábilem réddidit? nonne jejúnium, cum quo in matris ventre concéptus est? Jejúnium concépit, jejúnium nutrívit, jejúnium virum effécit. Quod sane Angelus matri præcépit, monens quæcúmque ex vite procéderent, ne attíngeret, non vinum, non síceram bíberet. Jejúnium prophétas génuit, poténtes confírmat atque róborat.")  ; L5
        (:text "Jejúnium legislatóres sapiéntes facit: ánimæ óptima custódia, córporis sócius secúrus, fórtibus viris muniméntum et arma, athlétis et certántibus exercitátio. Hoc prætérea tentatiónes propúlsat, ad pietátem armat, cum sobrietáte hábitat, temperántiæ ópifex est: in bellis fortitúdinem affert, in pace quiétem docet: nazarǽum sanctíficat, sacerdótem pérficit: neque enim fas est sine jejúnio sacrifícium attíngere, non solum in mýstica nunc et vera Dei adoratióne, sed nec in illa, in qua sacrifícium secúndum legem in figúra offerebátur. Jejúnium Elíam magnæ visiónis spectatórem fecit: quadragínta namque diérum jejúnio cum ánimam purgásset, in spelúnca méruit, quantum fas est hómini, Deum vidére. Móyses íterum legem accípiens, íterum jejúnia secútus est. Ninivítæ, nisi cum illis et bruta jejunássent, ruínæ minas nequáquam evasíssent. In desérto autem quorúmnam membra cecidérunt? nonne illórum, qui carnes appetivére?")  ; L6
        (:ref "Joannes 6:1-15" :source "Léctio sancti Evangélii secúndum Joánnem" :text "In illo témpore: Abiit Jesus trans mare Galilǽæ, quod est Tiberíadis: et sequebátur eum multitúdo magna, quia vidébant signa, quæ faciébat super his qui infirmabántur. Et réliqua. Homilía sancti Augustíni Epíscopi !Tract. 24 in Joannem Mirácula, quæ fecit Dóminus noster Jesus Christus, sunt quidem divína ópera, et ad intellegéndum Deum de visibílibus ádmonent humánam mentem. Quia enim ille non est talis substántia, quæ vidéri óculis possit; et mirácula ejus, quibus totum mundum regit, universámque creatúram adminístrat, assiduitáte viluérunt, ita ut pene nemo dignétur atténdere ópera Dei mira et stupénda in quólibet séminis grano: secúndum ipsam suam misericórdiam, servávit sibi quædam, quæ fáceret opportúno témpore præter usitátum cursum ordinémque natúræ; ut non majóra, sed insólita vidéndo stupérent, quibus cotidiána vilúerant.")  ; L7
        (:text "Majus enim miráculum est gubernátio totíus mundi, quam saturátio quinque míllium hóminum de quinque pánibus. Et tamen hoc nemo mirátur: illud mirántur hómines, non quia majus est, sed quia rarum est. Quis enim et nunc pascit univérsum mundum, nisi ille, qui de paucis granis ségetes creat? Fecit ergo quo modo Deus. Unde enim multíplicat de paucis granis ségetes, inde in mánibus suis multiplicávit quinque panes: potéstas enim erat in mánibus Christi. Panes autem illi quinque, quasi sémina erant, non quidem terræ mandáta, sed ab eo, qui terram fecit, multiplicáta.")  ; L8
        (:text "Hoc ergo admótum est sénsibus, quo erigerétur mens: et exhíbitum óculis, ubi exercerétur intelléctus: ut invisíbilem Deum per visibília ópera mirarémur, et erécti ad fidem, et purgáti per fidem, étiam ipsum invisíbilem vidére cuperémus, quem de rebus visibílibus invisíbilem noscerémus. Nec tamen súfficit hæc intuéri in miráculis Christi. Interrogémus ipsa mirácula, quid nobis loquántur de Christo: habent enim, si intelligántur, linguam suam. Nam quia ipse Christus Verbum Dei est: étiam factum Verbi, verbum nobis est.")  ; L9
        )
        :responsories
        (
        (:respond "Locútus est Dóminus ad Móysen, dicens: Descénde in Ægýptum, et dic Pharaóni: * Ut dimíttat pópulum meum: indurátum est cor Pharaónis: non vult dimíttere pópulum meum, nisi in manu forti." :verse "Clamor filiórum Israël venit ad me, vidíque afflictiónem eórum: sed veni, mittam te ad Pharaónem." :repeat "Ut dimíttat pópulum meum: indurátum est cor Pharaónis: non vult dimíttere pópulum meum, nisi in manu forti.")  ; R1
        (:respond "Stetit Móyses coram Pharaóne, et dixit: Hæc dicit Dóminus: * Dimítte pópulum meum, ut sacríficet mihi in desérto." :verse "Dóminus Deus Hebræórum misit me ad te, dicens." :repeat "Dimítte pópulum meum, ut sacríficet mihi in desérto.")  ; R2
        (:respond "Cantémus Dómino: glorióse enim honorificátus est, equum et ascensórem projécit in mare: * Adjútor et protéctor factus est mihi Dóminus in salútem." :verse "Dóminus quasi vir pugnátor, Omnípotens nomen ejus." :repeat "Adjútor et protéctor factus est mihi Dóminus in salútem.")  ; R3
        (:respond "In mare viæ tuæ, et sémitæ tuæ in aquis multis: * Deduxísti sicut oves pópulum tuum in manu Móysi et Aaron." :verse "Transtulísti illos per mare Rubrum, et transvexísti eos per aquam nímiam." :repeat "Deduxísti sicut oves pópulum tuum in manu Móysi et Aaron.")  ; R4
        (:respond "Qui persequebántur pópulum tuum, Dómine, demersísti eos in profúndum: * Et in colúmna nubis ductor eórum fuísti." :verse "Deduxísti sicut oves pópulum tuum in manu Móysi et Aaron." :repeat "Et in colúmna nubis ductor eórum fuísti.")  ; R5
        (:respond "Móyses fámulus Dei jejunávit quadragínta diébus et quadragínta nóctibus: * Ut legem Dómini mererétur accípere." :verse "Ascéndens Móyses in montem Sínai ad Dóminum, fuit ibi quadragínta diébus et quadragínta nóctibus." :repeat "Ut legem Dómini mererétur accípere.")  ; R6
        (:respond "Spléndida facta est fácies Móysi, dum respíceret in eum Dóminus: * Vidéntes senióres claritátem vultus ejus, admirántes timuérunt valde." :verse "Cumque descendísset de monte Sínai, portábat duas tábulas testimónii, ignórans quod cornúta esset fácies ejus ex consórtio sermónis Dei." :repeat "Vidéntes senióres claritátem vultus ejus, admirántes timuérunt valde.")  ; R7
        (:respond "Ecce mitto Angelum meum, qui præcédat te, et custódiat semper: * Obsérva et audi vocem meam, et inimícus ero inimícis tuis, et affligéntes te afflígam: et præcédet te Angelus meus." :verse "Israël, si me audíeris, non erit in te deus recens, neque adorábis deum aliénum: ego enim Dóminus." :repeat "Obsérva et audi vocem meam, et inimícus ero inimícis tuis, et affligéntes te afflígam: et præcédet te Angelus meus.")  ; R8
        (:respond "Atténdite, pópule meus, legem meam: * Inclináte aurem vestram in verba oris mei." :verse "Apériam in parábolis os meum: loquar propositiónes ab inítio sǽculi." :repeat "Inclináte aurem vestram in verba oris mei.")  ; R9
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  nemo-te-condemnavit

        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (tunc-acceptabis
                          bonum-est-sperare
                          me-suscepit-dextera
                          potens-es-domine
                          reges-terrae-et-omnes)
        :benedictus-antiphon  cum-sublevasset-oculos
        :lauds-capitulum      scriptum-est-quoniam-abraham

        ;; ── Prime ──────────────────────────────────────────────────
        :prime-antiphon        accepit-ergo-jesus
        ;; ── Terce ──────────────────────────────────────────────────
        :terce-antiphon        de-quinque-panibus
        ;; ── Sext ───────────────────────────────────────────────────
        :sext-antiphon         satiavit-dominus
        :sext-capitulum        laetare-sterilis
        ;; ── None ───────────────────────────────────────────────────
        :none-antiphon         illi-ergo-homines
        :none-capitulum        itaque-fratres-non-sumus

        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon  subiit-ergo-in-montem
        ))


    (5
     . (:lessons
        (
        (:ref "Jer 1:1-6" :source "Incipit liber Jeremíæ Prophétæ" :text "1 Verba Jeremíæ fílii Helcíæ, de sacerdótibus, qui fuérunt in Anathoth, in terra Bénjamin. 2 Quod factum est verbum Dómini ad eum in diébus Josíæ fílii Amon regis Juda, in tertiodécimo anno regni ejus. 3 Et factum est in diébus Joakim fílii Josíæ regis Juda, usque ad consummatiónem undécimi anni Sedecíæ fílii Josíæ regis Juda, usque ad transmigratiónem Jerúsalem, in mense quinto. 4 Et factum est verbum Dómini ad me, dicens: 5 Priúsquam te formárem in útero, novi te: et ántequam exíres de vulva, sanctificávi te, et prophétam in géntibus dedi te. 6 Et dixi: A, a, a, Dómine Deus: ecce néscio loqui, quia puer ego sum.")  ; L1
        (:ref "Jer 1:7-13" :text "7 Et dixit Dóminus ad me: Noli dícere: Puer sum: quóniam ad ómnia, quæ mittam te, ibis: et univérsa, quæcúmque mandávero tibi, loquéris. 8 Ne tímeas a fácie eórum: quia tecum ego sum, ut éruam te, dicit Dóminus. 9 Et misit Dóminus manum suam, et tétigit os meum: et dixit Dóminus ad me: Ecce dedi verba mea in ore tuo: 10 ecce constítui te hódie super gentes, et super regna, ut evéllas, et déstruas, et dispérdas, et díssipes, et ædífices, et plantes. 11 Et factum est verbum Dómini ad me, dicens: Quid tu vides, Jeremía? Et dixi: Virgam vigilántem ego vídeo. 12 Et dixit Dóminus ad me: Bene vidísti, quia vigilábo ego super verbo meo, ut fáciam illud. 13 Et factum est verbum Dómini secúndo ad me, dicens: Quid tu vides? Et dixi: Ollam succénsam ego vídeo, et fáciem ejus a fácie Aquilónis.")  ; L2
        (:ref "Jer 1:14-19" :text "14 Et dixit Dóminus ad me: Ab Aquilóne pandétur malum super omnes habitatóres terræ. 15 Quia ecce ego convocábo omnes cognatiónes regnórum Aquilónis, ait Dóminus: et vénient et ponent unusquísque sólium suum in intróitu portárum Jerúsalem, et super omnes muros ejus in circúitu, et super univérsas urbes Juda. 16 Et loquar judícia mea cum eis super omnem malítiam eórum, qui dereliquérunt me, et libavérunt diis aliénis, et adoravérunt opus mánuum suárum. 17 Tu ergo, accínge lumbos tuos, et surge, et lóquere ad eos ómnia quæ ego præcípio tibi. Ne formídes a fácie eórum: nec enim timére te fáciam vultum eórum. 18 Ego quippe dedi te hódie in civitátem munítam, et in colúmnam férream, et in murum ǽreum, super omnem terram, régibus Juda, princípibus ejus, et sacerdótibus et pópulo terræ. 19 Et bellábunt advérsum te, et non prævalébunt: quia ego tecum sum, ait Dóminus, ut líberem te.")  ; L3
        (:ref "Sermo 9 de Quadragesima" :source "Sermo sancti Leónis Papæ" :text "In ómnibus, dilectíssimi, solemnitátibus christiánis non ignorámus paschále sacraméntum esse præcípuum: cui condígne et cóngrue suscipiéndo, totíus quidem nos témporis institúta refórmant: sed devotiónem nostram præséntes vel máxime dies éxigunt, quos illi sublimíssimo divínæ misericórdiæ sacraménto scimus esse contíguos. In quibus mérito a sanctis Apóstolis per doctrínam Spíritus Sancti majóra sunt ordináta jejúnia: ut per commúne consórtium crucis Christi, étiam nos áliquid in eo quod propter nos gessit, agerémus, sicut Apóstolus ait: Si compátimur, et conglorificábimur. Certa atque secúra est exspectátio promíssæ beatitúdinis, ubi est participátio Domínicæ passiónis.")  ; L4
        (:text "Nemo est, dilectíssimi, cui per conditiónem témporis socíetas hujus glóriæ denegétur, tamquam tranquíllitas pacis vácua sit occasióne virtútis. Apóstolus enim prǽdicat, dicens: Omnes qui pie volunt vívere in Christo, persecutiónem patiéntur: et ídeo numquam deest tribulátio persecutiónis, si numquam desit observántia pietátis. Dóminus enim in exhortatiónibus suis dicit: Qui non áccipit crucem suam, et séquitur me, non est me dignus. Nec dubitáre debémus, hanc vocem non solum ad discípulos Christi, sed ad cunctos fidéles, totámque Ecclésiam pertinére, quæ salutáre suum in his qui áderant, universáliter audiébat.")  ; L5
        (:text "Sicut ergo totíus est córporis pie vívere, ita totíus est témporis crucem ferre: quæ mérito ferri unicuíque suadétur, quia própriis modis atque mensúris ab unoquóque tolerátur. Unum nomen est persecutiónis, sed non una est causa certáminis: et plus plerúmque perículi est in insidiatóre occúlto, quam in hoste manifésto. Beátus Job alternántibus bonis ac malis mundi hujus erudítus, pie veracitérque dicébat: Nonne tentátio est vita hóminis super terram? Quóniam non solis dolóribus córporis atque supplíciis ánima fidélis impétitur, verum étiam, salva incolumitáte membrórum, gravi morbo urgétur, si carnis voluptáte mollítur. Sed cum caro concupíscit advérsus spíritum, spíritus autem advérsus carnem; præsídio crucis Christi mens rationális instrúitur, nec cupiditátibus nóxiis illécta conséntit, quóniam continéntiæ clavis et Dei timóre transfígitur.")  ; L6
        (:ref "Joannes 8:46-59" :source "Léctio sancti Evangélii secúndum Joánnem" :text "In illo témpore: Dicébat Jesus turbis Judæórum: Quis ex vobis árguet me de peccáto? Si veritátem dico vobis, quare non créditis mihi? Et réliqua. Homilía sancti Gregórii Papæ !Homilia 18 in Evangelia Pensáte, fratres caríssimi, mansuetúdinem Dei. Relaxáre peccáta vénerat, et dicébat: Quis ex vobis árguet me de peccáto? Non dedignátur ex ratióne osténdere se peccatórem non esse, qui ex virtúte divinitátis póterat peccatóres justificáre. Sed terríbile est valde, quod súbditur: Qui ex Deo est, verba Dei audit: proptérea vos non audítis, quia ex Deo non estis. Si enim ipse verba Dei audit qui ex Deo est, et audíre verba ejus non potest quisquis ex illo non est: intérroget se unusquísque, si verba Dei in aure cordis pércipit; et intélleget unde sit. Cæléstem pátriam desideráre Véritas jubet, carnis desidéria cónteri, mundi glóriam declináre, aliéna non appétere, própria largíri.")  ; L7
        (:text "Penset ergo apud se unusquísque vestrum, si hæc vox Dei in cordis ejus aure conváluit, et quia jam ex Deo sit, agnóscit. Nam sunt nonnúlli, qui præcépta Dei nec aure córporis percípere dignántur. Et sunt nonnúlli, qui hæc quidem córporis aure percípiunt, sed nullo ea mentis desidério complectúntur. Et sunt nonnúlli, qui libénter verba Dei suscípiunt, ita ut étiam in flétibus compungántur, sed post lacrimárum tempus ad iniquitátem rédeunt. Hi profécto verba Dei non áudiunt, qui hæc exercére in ópere contémnunt. Vitam ergo vestram, fratres caríssimi, ante mentis óculos revocáte, et alta consideratióne pertiméscite hoc quod ex ore Veritátis sonat: Proptérea vos non audítis, quia ex Deo non estis.")  ; L8
        (:text "Sed hoc quod de réprobis Véritas lóquitur, ipsi hoc de semetípsis réprobi iníquis suis opéribus osténdunt: nam séquitur: Respondérunt ígitur Judǽi et dixérunt ei: Nonne bene dícimus nos, quia Samaritánus es tu, et dæmónium habes? Accépta autem tanta contumélia, quid Dóminus respóndeat, audiámus: Ego dæmónium non hábeo, sed honorífico Patrem meum, et vos inhonorástis me. Quia enim Samaritánus interpretátur custos: et ipse veráciter custos est, de quo Psalmísta ait: Nisi Dóminus custodíerit civitátem, in vanum vígilant qui custódiunt eam: et cui per Isaíam dícitur: Custos quid de nocte? custos quid de nocte? respondére nóluit Dóminus, Samaritánus non sum; sed, Ego dæmónium non hábeo. Duo quippe ei illáta fuérunt: unum negávit, áliud tacéndo consénsit.")  ; L9
        )
        :responsories
        (
        (:respond "Isti sunt dies, quos observáre debétis tempóribus suis: * Quartadécima die ad vésperum Pascha Dómini est: et in quintadécima solemnitátem celebrábitis altíssimo Dómino." :verse "Locútus est Dóminus ad Móysen, dicens: Lóquere fíliis Israël, et dices ad eos." :repeat "Quartadécima die ad vésperum Pascha Dómini est: et in quintadécima solemnitátem celebrábitis altíssimo Dómino.")  ; R1
        (:respond "Multiplicáti sunt qui tríbulant me, et dicunt: Non est salus illi in Deo ejus: * Exsúrge, Dómine, salvum me fac, Deus meus." :verse "Nequándo dicat inimícus meus: Præválui advérsus eum." :repeat "Exsúrge, Dómine, salvum me fac, Deus meus.")  ; R2
        (:respond "Usquequo exaltábitur inimícus meus super me? * Réspice, et exáudi me, Dómine, Deus meus." :verse "Qui tríbulant me, exsultábunt si motus fúero: ego autem in misericórdia tua sperábo." :repeat "Usquequo exaltábitur inimícus meus super me? * Réspice, et exáudi me, Dómine, Deus meus.")  ; R3
        (:respond "Deus meus es tu, ne discédas a me: * Quóniam tribulátio próxima est, et non est qui ádjuvet." :verse "Tu autem, Dómine, ne elongáveris auxílium tuum a me: ad defensiónem meam áspice." :repeat "Quóniam tribulátio próxima est, et non est qui ádjuvet.")  ; R4
        (:respond "In te jactátus sum ex útero, de ventre matris meæ Deus meus es tu, ne discédas a me: * Quóniam tribulátio próxima est, et non est qui ádjuvet." :verse "Salva me ex ore leónis, et a córnibus unicórnium humilitátem meam." :repeat "Quóniam tribulátio próxima est, et non est qui ádjuvet.")  ; R5
        (:respond "In próximo est tribulátio mea, Dómine, et non est qui ádjuvet; ut fódiant manus meas et pedes meos: líbera me de ore leónis, * Ut enárrem nomen tuum frátribus meis." :verse "Erue a frámea, Deus, ánimam meam, et de manu canis únicam meam." :repeat "In próximo est tribulátio mea, Dómine, et non est qui ádjuvet; ut fódiant manus meas et pedes meos: líbera me de ore leónis, * Ut enárrem nomen tuum frátribus meis.")  ; R6
        (:respond "Tota die contristátus ingrediébar, Dómine: quóniam ánima mea compléta est illusiónibus: * Et vim faciébant, qui quærébant ánimam meam." :verse "Amíci mei et próximi mei advérsum me appropinquavérunt et stetérunt: et qui juxta me erant, de longe stetérunt." :repeat "Et vim faciébant, qui quærébant ánimam meam.")  ; R7
        (:respond "Ne avértas fáciem tuam a púero tuo, Dómine: * Quóniam tríbulor, velóciter exáudi me." :verse "Inténde ánimæ meæ, et líbera eam: propter inimícos meos éripe me." :repeat "Quóniam tríbulor, velóciter exáudi me.")  ; R8
        (:respond "Quis dabit cápiti meo aquam, et óculis meis fontem lacrimárum, et plorábo die ac nocte? quia frater propínquus supplantávit me, * Et omnis amícus fraudulénter incéssit in me." :verse "Fiant viæ eórum ténebræ et lúbricum: et Angelus Dómini pérsequens eos." :repeat "Et omnis amícus fraudulénter incéssit in me.")  ; R9
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  ego-sum-qui-testimonium

        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (vide-domine-afflictionem
                          in-tribulatione-invocavi
                          judicasti-domine-causam
                          popule-meus-quid-feci
                          numquid-redditur)
        :benedictus-antiphon  dicebat-jesus-turbis
        :lauds-capitulum      christus-assistens-pontifex

        ;; ── Prime ──────────────────────────────────────────────────
        :prime-antiphon        ego-daemonium-non-habeo
        ;; ── Terce ──────────────────────────────────────────────────
        :terce-antiphon        ego-gloriam-meam
        ;; ── Sext ───────────────────────────────────────────────────
        :sext-antiphon         amen-amen-dico-vobis-si-quis
        :sext-capitulum        si-enim-sanguis
        ;; ── None ───────────────────────────────────────────────────
        :none-antiphon         tulerunt-lapides
        :none-capitulum        et-ideo-novi-testamenti

        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon  abraham-pater-vester
        ))


    (6
     . (:lessons
        (
        (:ref "Jer 2:12-17" :source "De Jeremía Prophéta" :text "12 Obstupéscite, cæli, super hoc, et, portæ ejus, desolámini veheménter, dicit Dóminus. 13 Duo enim mala fecit pópulus meus: Me dereliquérunt fontem aquæ vivæ, et fodérunt sibi cistérnas, cistérnas dissipátas, quæ continére non valent aquas. 14 Numquid servus est Israël, aut vernáculus? Quare ergo factus est in prædam? 15 Super eum rugiérunt leónes, et dedérunt vocem suam, posuérunt terram ejus in solitúdinem: civitátes ejus exústæ sunt, et non est qui hábitet in eis. 16 Fílii quoque Mémpheos et Taphnes constupravérunt te usque ad vérticem. 17 Numquid non istud factum est tibi, quia dereliquísti Dóminum Deum tuum eo témpore, quo ducébat te per viam?")  ; L1
        (:ref "Jer 2:18-22" :text "18 Et nunc quid tibi vis in via Ægýpti, ut bibas aquam túrbidam? et quid tibi cum via Assyriórum, ut bibas aquam flúminis? 19 Arguet te malítia tua, et avérsio tua increpábit te. Scito, et vide quia malum et amárum est reliquísse te Dóminum Deum tuum, et non esse timórem mei apud te, dicit Dóminus Deus exercítuum. 20 A sǽculo confregísti jugum meum, rupísti víncula mea, et dixísti: Non sérviam. In omni enim colle sublími, et sub omni ligno frondóso, tu prosternebáris méretrix. 21 Ego autem plantávi te víneam eléctam, omne semen verum: quómodo ergo convérsa es mihi in pravum, vínea aliéna? 22 Si láveris te nitro, et multiplicáveris tibi herbam borith, maculáta es in iniquitáte tua coram me, dicit Dóminus Deus.")  ; L2
        (:ref "Jer 2:29-32" :text "29 Quid vultis mecum judício conténdere? Omnes dereliquístis me, dicit Dóminus. 30 Frustra percússi fílios vestros, disciplínam non recepérunt: devorávit gládius vester prophétas vestros, quasi leo vastátor 31 generátio vestra. Vidéte verbum Dómini: Numquid solitúdo factus sum Israéli, aut terra serótina? Quare ergo dixit pópulus meus: Recéssimus, non veniémus ultra ad te? 32 Numquid obliviscétur virgo ornaménti sui, aut sponsa fásciæ pectorális suæ? pópulus vero meus oblítus est mei diébus innúmeris.")  ; L3
        (:ref "Sermo 11 de Passióne Dómini" :source "Sermo sancti Leónis Papæ" :text "Desideráta nobis, dilectíssimi, et univérso optábilis mundo adest festívitas Domínicæ passiónis, quæ nos inter exsultatiónes spirituálium gaudiórum silére non pátitur. Quia etsi diffícile est, de eádem solemnitáte sǽpius digne aptéque dissérere: non est tamen líberum sacerdóti in tanto divínæ misericórdiæ sacraménto fidélibus pópulis subtráhere sermónis offícium: cum ipsa matéria ex eo quod est ineffábilis, fandi tríbuat facultátem: nec possit defícere quod dicátur, dum numquam potest satis esse quod dícitur. Succúmbat ergo humána infírmitas glóriæ Dei, et in explicándis opéribus misericórdiæ ejus, ímparem se semper invéniat. Laborémus sensu, hæreámus ingénio, deficiámus elóquio: bonum est ut nobis parum sit, quod étiam recte de Dómini majestáte sentímus.")  ; L4
        (:text "Dicénte enim prophéta: Quǽrite Dóminum, et confirmámini, quǽrite fáciem ejus semper: némini præsuméndum est, quod totum quod quærit, invénerit, ne désinat propinquáre, qui cessárit accédere. Quid autem inter ómnia ópera Dei, in quibus humánæ admiratiónis fatigátur inténtio, ita contemplatiónem mentis nostræ et obléctat et súperat, sicut pássio Salvatóris? Qui ut humánum genus vínculis mortíferæ prævaricatiónis absólveret, et sæviénti diábolo poténtiam suæ majestátis occúluit, et infirmitátem nostræ humilitátis objécit. Si enim crudélis et supérbus inimícus consílium misericórdiæ Dei nosse potuísset, Judæórum ánimos mansuetúdine pótius temperáre, quam injústis ódiis studuísset accéndere: ne ómnium captivórum amítteret servitútem, dum nihil sibi debéntis perséquitur libertátem.")  ; L5
        (:text "Feféllit ergo illum malígnitas sua, íntulit supplícium Fílio Dei, quod cunctis fíliis hóminum in remédium verterétur. Fudit sánguinem justum, qui reconciliándo mundo et prétium esset, et póculum. Suscépit Dóminus, quod secúndum propósitum suæ voluntátis elégit. Admísit in se ímpias manus furéntium: quæ dum próprio incúmbunt scéleri, famulátæ sunt Redemptóri. Cujus étiam circa interfectóres suos tanta erat pietátis afféctio, ut de cruce súpplicans Patri, non se vindicári, sed illis postuláret ignósci.")  ; L6
        (:ref "Matt 21:1-9" :source "Léctio sancti Evangélii secúndum Matthǽum" :text "In illo témpore: Cum appropinquásset Jesus Jerosólymis, et venísset Béthphage ad montem Olivéti: tunc misit duos discípulos, dicens eis. Et réliqua.\n\nHomilía sancti Ambrósii Epíscopi\n\nPulchre relíctis Judǽis, habitatúrus in afféctibus géntium, templum Dóminus ascéndit. Hoc enim templum est verum, in quo non in líttera, sed in spíritu Dóminus adorátur. Hoc Dei templum est, quod fídei séries, non lápidum structúra fundávit. Deserúntur ergo qui óderant: eligúntur qui amatúri erant. Et ídeo ad montem venit Olivéti, ut novéllas óleas in sublími virtúte plantáret, quarum mater est illa, quæ sursum est, Jerúsalem. In hoc monte est ille cæléstis agrícola: ut plantáti omnes in domo Dei, possint virítim dícere: Ego autem sicut olíva fructífera in domo Dómini.")  ; L7
        (:text "Et fortásse ipse mons Christus est. Quis enim álius tales fructus ferret oleárum, non curvescéntium ubertáte baccárum, sed spíritus plenitúdine géntium fœcundárum? Ipse est per quem ascéndimus, et ad quem ascéndimus. Ipse est jánua, ipse est via, qui aperítur, et qui áperit: qui pulsátur ab ingrediéntibus, et ab eméritis adorátur. Ergo in castéllo erat, et ligátus erat pullus cum ásina: non póterat solvi nisi jussu Dómini. Solvit eum manus apostólica. Talis actus, talis vita, talis grátia. Esto talis et tu, ut possis ligátos sólvere.")  ; L8
        (:text "Nunc considerémus qui fúerint illi, qui erróre detécto, de paradíso ejécti, in castéllum sint relegáti. Et vides, quemádmodum quos mors expúlerat, vita revocáverit. Et ídeo secúndum Matthǽum, et ásinam et pullum légimus: ut quia in duóbus homínibus utérque fúerat sexus expúlsus, in duóbus animálibus sexus utérque revocétur. Ergo illic in ásina matre quasi Hevam figurávit erróris: hic autem in pullo generalitátem pópuli Gentílis expréssit: et ídeo pullo sedétur ásinæ. Et bene, in quo nemo sedit: quia nullus, ántequam Christus, natiónum pópulos vocávit ad Ecclésiam. Dénique secúndum Marcum sic habes: Quem nemo adhuc sedit hóminum.")  ; L9
        )
        :responsories
        (
        (:respond "In die qua invocávi te, Dómine, dixísti: Noli timére: * Judicásti causam meam, et liberásti me, Dómine, Deus meus." :verse "In die tribulatiónis meæ clamávi ad te, quia exaudísti me." :repeat "Judicásti causam meam, et liberásti me, Dómine, Deus meus.")  ; R1
        (:respond "Fratres mei elongavérunt se a me: et noti mei * Quasi aliéni recessérunt a me." :verse "Dereliquérunt me próximi mei, et qui me novérunt." :repeat "Quasi aliéni recessérunt a me.")  ; R2
        (:respond "Atténde, Dómine, ad me, et audi voces adversariórum meórum: * Numquid rédditur pro bono malum, quia fodérunt fóveam ánimæ meæ?" :verse "Recordáre quod stéterim in conspéctu tuo, ut lóquerer pro eis bonum, et avérterem indignatiónem tuam ab eis." :repeat "Numquid rédditur pro bono malum, quia fodérunt fóveam ánimæ meæ?")  ; R3
        (:respond "Conclúsit vias meas inimícus, insidiátor factus est mihi sicut leo in abscóndito, replévit et inebriávit me amaritúdine: deduxérunt in lacum mortis vitam meam, et posuérunt lápidem contra me. * Vide, Dómine, iniquitátes illórum: et júdica causam ánimæ meæ, defénsor vitæ meæ." :verse "Factus sum in derísum omni pópulo meo, cánticum eórum tota die." :repeat "Vide, Dómine, iniquitátes illórum: et júdica causam ánimæ meæ, defénsor vitæ meæ.")  ; R4
        (:respond "Salvum me fac, Deus, quóniam intravérunt aquæ usque ad ánimam meam: ne avértas fáciem tuam a me: * Quóniam tríbulor, exáudi me, Dómine, Deus meus." :verse "Inténde ánimæ meæ, et líbera eam: propter inimícos meos éripe me." :repeat "Quóniam tríbulor, exáudi me, Dómine, Deus meus.")  ; R5
        (:respond "Noli esse mihi, Dómine, aliénus: parce mihi in die mala: confundántur omnes qui me persequúntur, * Et non confúndar ego." :verse "Confundántur omnes inimíci mei, qui quærunt ánimam meam." :repeat "Et non confúndar ego.")  ; R6
        (:respond "Dóminus mecum est tamquam bellátor fortis: proptérea persecúti sunt me, et intellégere non potuérunt: Dómine, probas renes et corda: * Tibi revelávi causam meam." :verse "Vidísti, Dómine, iniquitátes eórum advérsum me: júdica judícium meum." :repeat "Tibi revelávi causam meam.")  ; R7
        (:respond "Dixérunt ímpii apud se, non recte cogitántes: Circumveniámus justum, quóniam contrárius est opéribus nostris: promíttit se sciéntiam Dei habére, Fílium Dei se nóminat, et gloriátur patrem se habére Deum: * Videámus si sermónes illíus veri sunt: et si est vere Fílius Dei, líberet eum de mánibus nostris: morte turpíssima condemnémus eum." :verse "Tamquam nugáces æstimáti sumus ab illo, et ábstinet se a viis nostris tamquam ab immundítiis: et præfert novíssima justórum." :repeat "Videámus si sermónes illíus veri sunt: et si est vere Fílius Dei, líberet eum de mánibus nostris: morte turpíssima condemnémus eum.")  ; R8
        (:respond "Circumdedérunt me viri mendáces: sine causa flagéllis cecidérunt me: * Sed tu, Dómine defénsor, víndica me." :verse "Quóniam tribulátio próxima est, et non est qui ádjuvet." :repeat "Sed tu, Dómine defénsor, víndica me.")  ; R9
        )

        ;; ── Vespers I ──────────────────────────────────────────────
        :magnificat-antiphon  pater-juste-mundus

        ;; ── Lauds ──────────────────────────────────────────────────
        :lauds-antiphons (dominus-deus-auxiliator
                          circumdantes-circumdederunt
                          judica-causam-meam
                          cum-angelis-et-pueris
                          confundantur-qui-me-persequuntur)
        :benedictus-antiphon  turba-multa
        :lauds-capitulum      hoc-enim-sentite

        ;; ── Prime ──────────────────────────────────────────────────
        :prime-antiphon        pueri-hebraeorum-tollentes
        ;; ── Terce ──────────────────────────────────────────────────
        :terce-antiphon        pueri-hebraeorum-vestimenta
        ;; ── Sext ───────────────────────────────────────────────────
        :sext-antiphon         tibi-revelavi-causam
        :sext-capitulum        humiliavit-semetipsum
        ;; ── None ───────────────────────────────────────────────────
        :none-antiphon         invocabo-nomen-tuum
        :none-capitulum        in-nomine-jesu

        ;; ── Vespers II ─────────────────────────────────────────────
        :magnificat2-antiphon  scriptum-est-enim-percutiam
        ))

    )
  "Lenten dominical Matins data, indexed by Lent Sunday number (1-6).
Scripture (L1-L3), patristic (L4-L6), and homily (L7-L9) lessons,
plus 8 responsories per Sunday.  Non-Matins antiphons and capitula
reference antiphonary/capitulary symbols.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Ferial Matins lessons and responsories

;; Lent ferial Matins (DA 1911): 1 nocturn, 3 homily lessons + 3 responsories.
;; Lesson 1 typically has Gospel incipit + patristic homily; lessons 2-3 are
;; homily continuations.
;;
;; Key: (WEEK . DOW) where WEEK is 0 (Ash Wed week), 1-4 (Lent), 5 (Passion);
;;      DOW is 1=Mon..6=Sat (week 0 starts at DOW 3=Wed).
;; Holy Week Mon-Wed (Quad6) excluded — handled by bcp-roman-season-holyweek.

(defconst bcp-roman-season-lent--ferial-matins
  '(
    ;; Quadp3-3: Feria IV Cinerum
    ((0 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 2 de Serm. Domini in monte, cap. 12 tom. 4"
               :text "In illo témpore: Dixit Jesus discípulis suis: Cum jejunátis, nolíte fíeri sicut hypócritæ, tristes. Et réliqua.
Homilía sancti Augustíni Epíscopi
Maniféstum est, his præcéptis omnem nostram intentiónem in interióra gáudia dírigi: ne foris quæréntes mercédem, huic sǽculo conformémur, et amittámus promissiónem tanto solidióris atque firmióris, quanto interióris beatitúdinis, qua nos elégit Deus confórmes fíeri imáginis Fílii sui. In hoc autem capítulo máxime adverténdum est, non in solo rerum corporeárum nitóre atque pompa, sed étiam in ipsis sórdibus luctuósis esse posse jactántiam et eo periculosiórem, quo sub nómine servitútis Dei décipit.")
               (:text "Qui ergo immoderáto cultu córporis atque vestítu, vel ceterárum rerum nitóre præfúlget, fácile convíncitur rebus ipsis, pompárum sǽculi esse sectátor, nec quemquam fallit dolósa imágine sanctitátis. Qui autem in professióne christianitátis, inusitáto squalóre ac sórdibus inténtos in se óculos hóminum facit, cum id voluntáte fáciat, non necessitáte patiátur: ex céteris ejus opéribus potest cónici, utrum hoc contémptu supérflui cultus, an ambitióne áliqua fáciat: quia et sub ovína pelle cavéndos lupos Dóminus præcépit: Sed ex frúctibus, inquit, eórum cognoscétis eos.")
               (:text "Cum enim cœ́perint alíquibus tentatiónibus ea ipsa scílicet illis súbtrahi, vel negári, quæ isto velámine vel consecúti sunt, vel cónsequi cúpiunt: tunc necésse est ut appáreat, utrum lupus in ovína pelle sit, an ovis in sua. Non tamen proptérea ornátu supérfluo debet aspéctus hóminum mulcére Christiánus, quia illum parcum hábitum ac necessárium étiam simulatóres sǽpius usúrpant, ut incáutos decípiant: quia et illæ oves non debent pelles suas depónere, si aliquándo eis lupi se cóntegant."))
              :responsories
              ((:respond "Veni hódie ad fontem aquæ, et orávi Dóminum, dicens:"
                  :verse "Igitur puélla, cui díxero, Da mihi aquam de hýdria tua, ut bibam: et illa díxerit, Bibe, dómine, et camélis tuis potum tríbuam: ipsa est, quam præparávit Dóminus fílio dómini mei."
                  :repeat "Dómine, Deus Abraham, tu prósperum fecísti desidérium meum."
                  :gloria nil)
               (:respond "Factus est sermo Dómini ad Abram, dicens:"
                  :verse "Ego enim sum Dóminus Deus tuus, qui edúxi te de Ur Chaldæórum."
                  :repeat "Noli timére, Abram: ego protéctor tuus sum, et merces tua magna nimis."
                  :gloria nil)
               (:respond "Movens Abram tabernáculum suum, venit et habitávit juxta convállem Mambre:"
                  :verse "Dixit autem Dóminus ad eum: Leva óculos tuos, et vide: omnem terram, quam cónspicis tibi dabo, et sémini tuo in sempitérnum."
                  :repeat "Ædificavítque ibi altáre Dómino."
                  :gloria nil))))

    ;; Quadp3-4: Feria V post Cineres
    ((0 . 4) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 2 de Consensu Evangelist. cap. 20, tom. 4"
               :text "In illo témpore: Cum introísset Jesus Caphárnaum, accéssit ad eum centúrio, rogans eum, et dicens: Dómine, puer meus jacet in domo paralýticus, et male torquétur. Et réliqua.
Homilía sancti Augustíni Epíscopi
Videámus, utrum sibi de hoc servo centuriónis Matthǽus Lucásque conséntiant. Matthǽus enim dicit: Accéssit ad eum centúrio, rogans eum, et dicens: Puer meus jacet in domo paralýticus. Cui vidétur repugnáre quod ait Lucas: Et cum audísset de Jesu, misit ad eum senióres Judæórum, rogans eum ut veníret, et sanáret servum ejus. At illi cum veníssent ad Jesum, rogábant eum sollícite, dicéntes ei: Quia dignus est ut hoc illi præstes: díligit enim gentem nostram, et synagógam ipse ædificávit nobis. Jesus autem ibat cum illis: et cum jam non longe esset a domo, misit ad eum centúrio amícos, dicens: Dómine, noli vexári: non enim dignus sum ut sub tectum meum intres.")
               (:text "Si enim hoc ita gestum est, quómodo erit verum, quod Matthǽus narrat: Accéssit ad eum quidam centúrio, cum ipse non accésserit, sed amícos míserit: nisi diligénter adverténtes intellegámus Matthǽum non omnímodo deseruísse usitátum morem loquéndi? Non solum enim dícere solémus, accessísse áliquem étiam antequam pervéniat illuc, quo dícitur accessísse: unde étiam dícimus: Parum accéssit, vel multum accéssit eo, quo áppetit perveníre: verum étiam ipsam perventiónem cujus adipiscéndi causa accéditur, dícimus plerúmque factam, etsi eum, ad quem pérvenit, non vídeat ille qui pérvenit, cum per amícum pérvenit ad áliquem, cujus ei favor est necessárius. Quod ita ténuit consuetúdo, ut jam étiam vulgo perventóres appelléntur, qui poténtium quorúmlibet tamquam inaccessíbiles ánimos, per conveniéntium personárum interpositiónem, ambitiónis arte pertíngunt.")
               (:text "Non ergo absúrde Matthǽus, étiam quod vulgo possit intéllegi, per álios facto accéssu centuriónis ad Dóminum, compéndio dícere vóluit: Accéssit ad eum centúrio. Verúmtamen non negligénter intuénda est étiam sancti Evangelístæ altitúdo mýsticæ locutiónis, secúndum quam scriptum est in Psalmo: Accédite ad eum, et illuminámini. Proínde quia fidem centuriónis, qua vere accéditur ad Jesum, ipse ita laudávit, ut díceret: Non invéni tantam fidem in Israël: ipsum pótius accessísse ad Christum dícere vóluit prudens Evangelísta, quam illos, per quos verba sua míserat."))
              :responsories
              ((:respond "Dómine, puer meus jacet paralýticus in domo, et male torquétur:"
                  :verse "Dómine, non sum dignus ut intres sub tectum meum: sed tantum dic verbo, et sanábitur puer meus."
                  :repeat "Amen dico tibi, ego véniam, et curábo eum."
                  :gloria nil)
               (:respond "Dum staret Abraham ad ílicem Mambre, vidit tres viros ascendéntes per viam:"
                  :verse "Ecce Sara uxor tua páriet tibi fílium, et vocábis nomen ejus Isaac."
                  :repeat "Tres vidit, et unum adorávit."
                  :gloria nil)
               (:respond "Tentávit Dóminus Abraham, et dixit ad eum:"
                  :verse "Vocátus quoque a Dómino, respóndit, Adsum: et ait ei Dóminus."
                  :repeat "Tolle fílium tuum, quem díligis, Isaac, et offer illum ibi in holocáustum super unum móntium, quem díxero tibi."
                  :gloria t))))

    ;; Quadp3-5: Feria VI post Cineres
    ((0 . 5) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 1 Comm. in cap. 5 et 6 Matth."
               :text "In illo témpore: Dixit Jesus discípulis suis: Audístis quia dictum est: Díliges próximum tuum, et ódio habébis inimícum tuum. Et réliqua.
Homilía sancti Hierónymi Presbýteri
Ego autem dico vobis: Dilígite inimícos vestros; benefácite his qui odérunt vos. Multi præcépta Dei, imbecillitáte sua, non Sanctórum víribus æstimántes, putant esse impossibília quæ præcépta sunt: et dicunt suffícere virtútibus, non odísse inimícos: céterum dilígere, plus prǽcipi, quam humána natúra patiátur. Sciéndum est ergo, Christum non impossibília præcípere, sed perfécta. Quæ fecit David in Saul, et in Absalom: Stéphanus quoque Martyr pro inimícis lapidántibus deprecátus est: et Paulus anáthema cupit esse pro persecutóribus suis. Hæc autem Jesus et dócuit et fecit, dicens: Pater, ignósce illis: quod enim fáciunt, nésciunt.")
               (:text "Ut sitis fílii Patris vestri, qui in cælis est. Si Dei præcépta custódiens, fílius quis effícitur Dei: ergo non est natúra fílius, sed arbítrio suo. Cum ergo facis eleemósynam, noli tuba cánere ante te, sicut hypócritæ fáciunt in synagógis et in vicis, ut honorificéntur ab homínibus. Qui tuba canit, eleemósynam fáciens, hypócrita est. Qui jejúnans demolítur fáciem suam, ut ventris inanitátem monstret in vultu, et hic hypócrita est. Qui in synagógis et in ángulis plateárum orat, ut videátur ab homínibus, hypócrita est.")
               (:text "Ex quibus ómnibus collígitur hypócritas esse, qui quódlibet fáciunt ut ab homínibus glorificéntur. Mihi vidétur et ille, qui dicit fratri suo: Dimítte ut tollam festúcam de óculo tuo: nam propter glóriam hoc fácere vidétur, ut ipse justus esse videátur. Unde dícitur ei a Dómino: Hypócrita, éice primum trabem de óculo tuo. Non ítaque virtus, sed causa virtútis apud Deum mercédem habet. Et si a recta via páululum declináveris, non ínterest, utrum ad déxteram vadas, an ad sinístram, cum verum iter amíseris."))
              :responsories
              ((:respond "Angelus Dómini vocávit Abraham, dicens:"
                  :verse "Cumque extendísset manum ut immoláret fílium, ecce Angelus Dómini de cælo clamávit, dicens."
                  :repeat "Ne exténdas manum tuam super púerum, eo quod tímeas Dóminum."
                  :gloria nil)
               (:respond "Vocávit Angelus Dómini Abraham de cælo, secúndo, dicens: Benedícam tibi,"
                  :verse "Possidébit semen tuum portas inimicórum tuórum, et benedicéntur in sémine tuo omnes tribus terræ."
                  :repeat "Et multiplicábo te sicut stellas cæli."
                  :gloria nil)
               (:respond "Deus dómini mei Abraham, dírige viam meam:"
                  :verse "Obsecro, Dómine, fac misericórdiam cum servo tuo."
                  :repeat "Ut cum salúte revértar in domum dómini mei."
                  :gloria t))))

    ;; Quadp3-6: Sabbato post Cineres
    ((0 . 6) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Marcum"
               :ref "Lib. 2, cap. 28 in cap. 6 Marci, tom. 4"
               :text "In illo témpore: Cum sero esset, erat navis in médio mari, et Jesus solus in terra. Et réliqua.
Homilía sancti venerábilis Bedæ Presbýteri
Labor discipulórum in remigándo, et contrárius eis ventus, labóres sanctæ Ecclésiæ varios desígnat: quæ inter undas sǽculi adversántis, et immundórum flatus spirítuum, ad quiétem pátriæ cæléstis, quasi ad fidam líttoris statiónem, perveníre conátur. Ubi bene dícitur, quia navis erat in médio mari, et ipse solus in terra: quia nonnúnquam Ecclésia tantis gentílium pressúris non solum afflícta, sed et fœdáta est, ut, si fíeri posset, Redémptor ipsíus eam prorsus deseruísse ad tempus viderétur.")
               (:text "Unde est illa vox ejus inter undas procellásque tentatiónum irruéntium deprehénsæ, atque auxílium protectiónis illíus gemebúndo clamóre quæréntis: Ut quid, Dómine, recessísti longe, déspicis in opportunitátibus, in tribulatióne? Quæ páriter vocem inimíci persequéntibus expónit, in sequéntibus Psalmi subíciens: Dixit enim in corde suo: Oblítus est Deus, avértit fáciem suam, ne vídeat usque in finem.")
               (:text "Verum ille non oblivíscitur oratiónem páuperum, neque avértit fáciem suam a sperántibus in se: quin pótius et certántes cum hóstibus, ut vincant, ádjuvat, et victóres in ætérnum corónat. Unde hic quoque apérte dícitur, quia vidit eos laborántes in remigándo. Videt quippe Dóminus laborántes in mari, quamvis ipse pósitus in terra: quia etsi ad horam différre videátur auxílium tribulátis impéndere, nihilóminus eos, ne in tribulatiónibus defíciant, suæ respéctu pietátis corróborat: et aliquándo étiam manifésto adjutório, victis adversitátibus, quasi calcátis sedatísque flúctuum volumínibus líberat."))
              :responsories
              ((:respond "Veni hódie ad fontem aquæ, et orávi Dóminum, dicens:"
                  :verse "Igitur puélla, cui díxero, Da mihi aquam de hýdria tua, ut bibam: et illa díxerit, Bibe, dómine, et camélis tuis potum tríbuam: ipsa est, quam præparávit Dóminus fílio dómini mei."
                  :repeat "Dómine, Deus Abraham, tu prósperum fecísti desidérium meum."
                  :gloria nil)
               (:respond "Factus est sermo Dómini ad Abram, dicens:"
                  :verse "Ego enim sum Dóminus Deus tuus, qui edúxi te de Ur Chaldæórum."
                  :repeat "Noli timére, Abram: ego protéctor tuus sum, et merces tua magna nimis."
                  :gloria nil)
               (:respond "Movens Abram tabernáculum suum, venit et habitávit juxta convállem Mambre:"
                  :verse "Dixit autem Dóminus ad eum: Leva óculos tuos, et vide: omnem terram, quam cónspicis tibi dabo, et sémini tuo in sempitérnum."
                  :repeat "Ædificavítque ibi altáre Dómino."
                  :gloria nil))))

    ;; Quad1-1: Feria Secunda infra Hebdomadam I in Quadragesima
    ((1 . 1) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. de fide et operibus. cap. 15 tom. 4, circa medium"
               :text "In illo témpore: Dixit Jesus discípulis suis: Cum vénerit Fílius hóminis in majestáte sua, et omnes Angeli cum eo, tunc sedébit super sedem majestátis suæ: et congregabúntur ante eum omnes gentes. Et réliqua.
Homilía sancti Augustíni Epíscopi
Si mandátis non servátis, ad vitam veníri potest per solam fidem, quæ sine opéribus mórtua est: illud deínde quómodo verum erit, quod eis, quos ad sinístram positúrus est, dicet: Ite in ignem ætérnum, qui parátus est diábolo, et ángelis ejus: nec íncrepat, quia in eum non credidérunt; sed quia bona ópera non fecérunt? Nam profécto, ne sibi quisquam de fide, quæ sine opéribus mórtua est, promíttat ætérnam vitam; proptérea omnes gentes segregatúrum se dixit, quæ permíxtæ eisdem páscuis utebántur: ut appáreat, eos illi dictúros: Dómine, quando te vídimus illa et illa patiéntem, et non ministrávimus tibi? qui in eum credíderant, sed bona operári non curáverant, tamquam de ipsa fide mórtua ad vitam pervenirétur ætérnam.")
               (:text "An forte ibunt in ignem ætérnum, qui ópera misericórdiæ non fecérunt: et non ibunt, qui aliéna rapuérunt? vel corrumpéndo in se templum Dei, in seípsos immisericórdes fuérunt: quasi ópera misericórdiæ prosint áliquid sine dilectióne, dicénte Apóstolo: Si distríbuam ómnia mea paupéribus, caritátem autem non hábeam, nihil mihi prodest? Aut díligat quisquam próximum sicut seípsum, qui non díligit seípsum? Qui enim díligit iniquitátem, odit ánimam suam.")
               (:text "Neque illud dici hic póterit, in quo nonnúlli seípsos sedúcunt, ignem ætérnum dictum, non ipsam combustiónem ætérnam. Per ignem quippe, qui ætérnus erit, transitúros arbitrántur eos, quibus propter fidem mórtuam per ignem promíttunt salútem: ut vidélicet ipse ignis ætérnus sit, combústio vero eórum, hoc est, operátio ignis, non sit in eos ætérna: cum et hoc prǽvidens Dóminus senténtiam suam conclúsit ita dicens: Sic ibunt illi in combustiónem ætérnam, justi autem in vitam ætérnam. Erit ergo ætérna combústio, sicut ignis: et eos in illam itúros Véritas dicit, quorum non fidem, sed bona ópera defuísse declarávit."))
              :responsories
              ((:respond "Ecce nunc tempus acceptábile, ecce nunc dies salútis: commendémus nosmetípsos in multa patiéntia, in jejúniis multis,"
                  :verse "In ómnibus exhibeámus nosmetípsos sicut Dei minístros, in multa patiéntia, in jejúniis multis."
                  :repeat "Per arma justítiæ virtútis Dei."
                  :gloria nil)
               (:respond "In ómnibus exhibeámus nosmetípsos sicut Dei minístros in multa patiéntia:"
                  :verse "Ecce nunc tempus acceptábile, ecce nunc dies salútis: commendémus nosmetípsos in multa patiéntia."
                  :repeat "Ut non vituperétur ministérium nostrum."
                  :gloria nil)
               (:respond "In jejúnio et fletu orábunt sacerdótes, dicéntes:"
                  :verse "Inter vestíbulum et altáre plorábunt sacerdótes, dicéntes."
                  :repeat "Parce, Dómine, parce pópulo tuo; et ne des hereditátem tuam in perditiónem."
                  :gloria t))))

    ;; Quad1-2: Feria Tertia infra Hebdomadam I in Quadragesima
    ((1 . 2) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Homil. 7 in Quadrag. tom. 7"
               :text "In illo témpore: Cum intrásset Jesus Jerosólymam, commóta est univérsa cívitas, dicens: Quis est hic? Et réliqua.
Homilía sancti Bedæ Venerábilis Presbýteri
Quod maledicéndo ficum infructuósam per figúram fecit Dóminus, hoc idem mox apértius osténdit, eiciéndo ímprobos e templo. Neque enim áliquid peccávit arbor, quod esuriénte Dómino poma non hábuit, quorum necdum tempus advénerat: sed peccavére sacerdótes, qui in domo Dómini negótia sæculária gerébant, et fructum pietátis, quem debúerant, quemque in eis Dóminus esuriébat, ferre superséderant. Arefécit Dóminus árborem maledícto, ut hómines hæc vidéntes, sive audiéntes, multo magis intellégerent sese divíno condemnándos esse judício, si absque óperum fructu, de plausu tantum sibi religiósi sermónis, velut de sónitu et teguménto blandiréntur viridántium foliórum.")
               (:text "Verum quia non intellexérunt, in ipsos consequénter districtiónem méritæ ultiónis exércuit: et ejécit commércia rerum humanárum de domo illa, in qua divínas tantum res agi, hóstias et oratiónes Dei offérri, verbum Dei legi, audíri, et decantári præcéptum erat. Et quidem credéndum est, quia ea tantum vendi vel emi repérerit in templo quæ ad ministérium necessária essent ejúsdem templi, juxta hoc quod álias factum légimus, cum idem templum ingrédiens, invénit in eo vendéntes et eméntes oves, et boves, et colúmbas: quia nimírum hæc ómnia non nisi ut offerréntur in domo Dómini, eos qui de longe vénerant, ab indígenis comparáre credéndum est.")
               (:text "Si ergo Dóminus nec ea volébat venúmdari in templo, quæ in templo volébat offérri, vidélicet propter stúdium avarítiæ, sive fraudis, quod próprium solet esse negotiántium fácinus: quanta putas animadversióne puníret, si invenísset ibi áliquos rísui vel vanilóquio vacántes aut álii cuílibet vítio mancipátos? Si enim ea quæ álibi líbere geri póterant, Dóminus in domo sua temporália negótia geri non pátitur: quanto magis ea quæ nusquam fíeri licet, plus cæléstis iræ meréntur, si in ǽdibus Deo sacrátis agúntur? Verum quia Spíritus Sanctus in colúmba super Dóminum appáruit, recte per colúmbas Sancti Spíritus charísmata signántur. Qui autem sunt in templo Dei hódie, qui colúmbas vendunt, nisi qui in Ecclésia prétium de impositióne manus accípiunt, per quam vidélicet impositiónem Spíritus Sanctus cǽlitus datur?"))
              :responsories
              ((:respond "Emendémus in mélius, quæ ignoránter peccávimus: ne súbito præoccupáti die mortis, quærámus spátium pœniténtiæ, et inveníre non possímus:"
                  :verse "Adjuva nos, Deus salutáris noster, et propter honórem nóminis tui, Dómine, líbera nos."
                  :repeat "Atténde, Dómine, et miserére, quia peccávimus tibi."
                  :gloria nil)
               (:respond "Derelínquat ímpius viam suam, et vir iníquus cogitatiónes suas, et revertátur ad Dóminum, et miserébitur ejus:"
                  :verse "Non vult Dóminus mortem peccatóris, sed ut convertátur et vivat."
                  :repeat "Quia benígnus et miséricors est, et præstábilis super malítia Dóminus Deus noster."
                  :gloria nil)
               (:respond "Paradísi portas apéruit nobis jejúnii tempus: suscipiámus illud orántes, et deprecántes:"
                  :verse "In ómnibus exhibeámus nosmetípsos sicut Dei minístros in multa patiéntia."
                  :repeat "Ut in die resurrectiónis cum Dómino gloriémur."
                  :gloria t))))

    ;; Quad1-3: Feria Quarta Quattuor Temporum Quadragesimæ
    ((1 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 7 in Lucæ cap. 11"
               :text "In illo témpore: Respondérunt Jesu quidam de scribis et pharisǽis, dicéntes: Magíster, vólumus a te signum vidére. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Judæórum plebe damnáta, Ecclésiæ mystérium evidénter exprímitur, quæ in Ninivítis per pœniténtiam, et in regína Austri per stúdium percipiéndæ sapiéntiæ, de totíus orbis fínibus congregátur, ut pacífici Salomónis verba cognóscat. Regína plane, cujus regnum est indivísum, de divérsis et distántibus pópulis in unum corpus assúrgens.")
               (:text "Itaque sacraméntum illud magnum est de Christo et Ecclésia. Sed tamen hoc majus est, quia illud in figúra ante præcéssit, nunc autem plenum in veritáte mystérium est. Illic enim Sálomon typus, hic autem Christus in suo córpore est. Ex duóbus ígitur constat Ecclésia: ut aut peccáre nésciat, aut peccáre désinat. Pœniténtia enim delíctum ábolet, sapiéntia cavet.")
               (:text "Céterum Jonæ signum, ut typus Domínicæ passiónis, ita étiam grávium, quæ Judǽi commíserint, testificátio peccatórum est. Simul advértere licet et majestátis oráculum, et pietátis indícium. Namque Ninivitárum exémplo et denuntiátur supplícium, et remédium demonstrátur. Unde étiam Judǽi debent non desperáre indulgéntiam, si velint ágere pœniténtiam."))
              :responsories
              ((:respond "Scíndite corda vestra, et non vestiménta vestra: et convertímini ad Dóminum Deum vestrum:"
                  :verse "Derelínquat ímpius viam suam, et vir iníquus cogitatiónes suas, et revertátur ad Dóminum, et miserébitur ejus."
                  :repeat "Quia benígnus et miséricors est."
                  :gloria nil)
               (:respond "Frange esuriénti panem tuum, et egénos vagósque induc in domum tuam:"
                  :verse "Cum víderis nudum, óperi eum, et carnem tuam ne despéxeris."
                  :repeat "Tunc erúmpet quasi mane lumen tuum, et anteíbit fáciem tuam justítia tua."
                  :gloria nil)
               (:respond "Abscóndite eleemósynam in sinu páuperum, et ipsa orábit pro vobis ad Dóminum:"
                  :verse "Date eleemósynam, et ecce ómnia munda sunt vobis."
                  :repeat "Quia sicut aqua extínguit ignem, ita eleemósyna extínguit peccátum."
                  :gloria t))))

    ;; Quad1-4: Feria Quinta infra Hebdomadam I in Quadragesima
    ((1 . 4) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Liber 2 Comm. in cap. 15. Matthæi"
               :text "In illo témpore: Egréssus Jesus secéssit in partes Tyri et Sidónis. Et réliqua.
Homilía sancti Hierónymi Presbýteri
Scribis et pharisǽis calumniatóribus derelíctis, transgréditur in partes Tyri et Sidónis, ut Týrios Sidoniósque curáret. Múlier autem Chananǽa egréditur de fínibus prístinis, ut clamans fíliæ ímpetret sanitátem. Obsérva quod in quintodécimo loco fília Chananǽæ sanétur. Miserére mei, Dómine, Fili David. Inde novit vocáre Fílium David, quia egréssa jam fúerat de fínibus suis, et errórem Tyriórum ac Sidoniórum loci et fídei commutatióne dimíserat.")
               (:text "Fília mea male a dæmónio vexátur. Ego fíliam Chananǽæ puto ánimas esse credéntium, quæ male a dæmónio vexabántur, ignorántes Creatórem, et adorántes lápidem. Qui non respóndit ei verbum: non de supérbia pharisáica, nec de scribárum supercílio: sed ne ipse senténtiæ suæ viderétur esse contrárius, per quam jússerat: In viam géntium ne abiéritis, et in civitátes Samaritanórum ne intravéritis. Nolébat enim occasiónem calumniatóribus dare: perfectámque salútem géntium passiónis et resurrectiónis témpori reservábat.")
               (:text "Et accedéntes discípuli ejus, rogábant eum, dicéntes: Dimítte eam, quia clamat post nos. Discípuli illo adhuc témpore mystéria Dómini nesciéntes, vel misericórdia commóti, rogábant pro Chananǽa mulíere, quam alter Evangelísta Syrophœníssam appéllat: vel importunitáte ejus carére cupiéntes, quia non ut cleméntem, sed ut durum médicum crébrius inclamáret. Ipse autem respóndens ait: Non sum missus, nisi ad oves quæ periérunt domus Israël. Non quo et ad gentes non missus sit, sed quo primum missus sit ad Israël: ut illis non recipiéntibus Evangélium, justa fíeret ad gentes transmigrátio."))
              :responsories
              ((:respond "Tribulárer, si nescírem misericórdias tuas, Dómine; tu dixísti: Nolo mortem peccatóris, sed ut magis convertátur et vivat:"
                  :verse "Secúndum multitúdinem dolórum meórum in corde meo, consolatiónes tuæ lætificavérunt ánimam meam."
                  :repeat "Qui Chananǽam et publicánum vocásti ad pœniténtiam."
                  :gloria nil)
               (:respond "In ómnibus exhibeámus nosmetípsos sicut Dei minístros in multa patiéntia:"
                  :verse "Ecce nunc tempus acceptábile, ecce nunc dies salútis: commendémus nosmetípsos in multa patiéntia."
                  :repeat "Ut non vituperétur ministérium nostrum."
                  :gloria nil)
               (:respond "In jejúnio et fletu orábunt sacerdótes, dicéntes:"
                  :verse "Inter vestíbulum et altáre plorábunt sacerdótes, dicéntes."
                  :repeat "Parce, Dómine, parce pópulo tuo; et ne des hereditátem tuam in perditiónem."
                  :gloria t))))

    ;; Quad1-5: Feria Sexta Quattuor Temporum Quadragesimæ
    ((1 . 5) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tractatus 17 in Joannem, post initium"
               :text "In illo témpore: Erat dies festus Judæórum, et ascéndit Jesus Jerosólymam. Et réliqua.
Homilía sancti Augustíni Epíscopi
Videámus quid volúerit significáre in illo uno, quem étiam ipse servans unitátis mystérium, de tot languéntibus unum sanáre dignátus est. Invénit in annis ejus númerum quemdam languóris: trigínta et octo annos habébat in infirmitáte. Hic númerus quómodo magis ad languórem pertíneat, quam ad sanitátem, paulo diligéntius exponéndum est. Inténtos vos volo: áderit Dóminus, ut cóngrue loquar, et sufficiénter audiátis. Quadragenárius númerus sacrátus nobis in quadam perfectióne commendátur; notum esse árbitror caritáti vestræ: testántur sæpíssime divínæ Scriptúræ: jejúnium hoc número consecrátum esse, bene nostis. Nam et Móyses quadragínta diébus jejunávit, et Elías tótidem: et ipse Dóminus noster et Salvátor Jesus Christus hunc jejúnii númerum implévit. Per Móysen significátur Lex, per Elíam significántur Prophétæ, per Dóminum significátur Evangélium. Ideo in illo monte tres apparuérunt, ubi se discípulis osténdit in claritáte vultus et vestis suæ: appáruit enim médius inter Móysen et Elíam, tamquam Evangélium testimónium habéret a Lege et Prophétis.")
               (:text "Sive ergo in Lege, sive in Prophétis, sive in Evangélio, quadragenárius númerus nobis in jejúnio commendátur. Jejúnium autem magnum et generále est, abstinére ab iniquitátibus et illícitis voluptátibus sǽculi, quod est perféctum jejúnium: Ut abnegántes impietátem et sæculáres cupiditátes, temperánter et juste et pie vivámus in hoc sǽculo. Huic jejúnio quam mercédem addit Apóstolus? Séquitur et dicit: Exspectántes illam beátam spem, et manifestatiónem glóriæ beáti Dei et Salvatóris nostri Jesu Christi. In hoc ergo sǽculo quasi quadragésimam abstinéntiæ celebrámus, cum bene vívimus, cum ab iniquitátibus et ab illícitis voluptátibus abstinémus: sed quia hæc abstinéntia sine mercéde non erit, exspectámus beátam illam spem, et revelatiónem glóriæ magni Dei et Salvatóris nostri Jesu Christi. In illa spe, cum fúerit de spe facta res, acceptúri sumus mercédem denárium. Ipsa enim merces rédditur operáriis in vínea laborántibus, secúndum Evangélium, quod vos credo reminísci: neque enim ómnia commemoránda sunt tamquam rúdibus et imperítis. Denárius ergo, qui accépit nomen a número decem, rédditur, et conjúnctus quadragenário fit quinquagenárius: unde cum labóre celebrámus Quadragésimam ante Pascha; cum lætítia vero, tamquam accépta mercéde, Quinquagésimam post Pascha.")
               (:text "Mementóte quod proposúerim númerum trigínta octo annórum in illo lánguido. Volo expónere, quare númerus ille trigésimus et octávus, languóris sit pótius quam sanitátis. Ergo, ut dicébam, cáritas implet Legem: ad plenitúdinem Legis in ómnibus opéribus pértinet quadragenárius númerus. In caritáte autem duo præcépta nobis commendántur: Díliges Dóminum Deum tuum ex toto corde tuo, et ex tota ánima tua, et ex tota mente tua: et díliges próximum tuum sicut teípsum. In his duóbus præcéptis tota Lex pendet, et Prophétæ. Mérito et illa vídua omnes facultátes suas, duo minúta misit in dona Dei: mérito et pro illo lánguido a latrónibus sauciáto stabulárius duos nummos accépit, unde sanarétur: mérito apud Samaritános bíduum fecit Jesus, ut eos caritáte firmáret. Binário ergo isto número cum áliquid boni significátur, máxime bipertíta cáritas commendátur. Si ergo quadragenárius númerus habet perfectiónem Legis, et Lex non implétur nisi in gémino præcépto caritátis: quid miráris, quia languébat, qui ad quadragínta, duo minus habébat?"))
              :responsories
              ((:respond "Emendémus in mélius, quæ ignoránter peccávimus: ne súbito præoccupáti die mortis, quærámus spátium pœniténtiæ, et inveníre non possímus:"
                  :verse "Adjuva nos, Deus salutáris noster, et propter honórem nóminis tui, Dómine, líbera nos."
                  :repeat "Atténde, Dómine, et miserére, quia peccávimus tibi."
                  :gloria nil)
               (:respond "Derelínquat ímpius viam suam, et vir iníquus cogitatiónes suas, et revertátur ad Dóminum, et miserébitur ejus:"
                  :verse "Non vult Dóminus mortem peccatóris, sed ut convertátur et vivat."
                  :repeat "Quia benígnus et miséricors est, et præstábilis super malítia Dóminus Deus noster."
                  :gloria nil)
               (:respond "Paradísi portas apéruit nobis jejúnii tempus: suscipiámus illud orántes, et deprecántes:"
                  :verse "In ómnibus exhibeámus nosmetípsos sicut Dei minístros in multa patiéntia."
                  :repeat "Ut in die resurrectiónis cum Dómino gloriémur."
                  :gloria t))))

    ;; Quad1-6: Sabbato Quattuor Temporum Quadragesimæ
    ((1 . 6) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Homilia de Transfiguratione Domini"
               :text "In illo témpore: Assúmpsit Jesus Petrum, et Jacóbum, et Joánnem fratrem ejus, et duxit illos in montem excélsum seórsum: et transfigurátus est ante eos. Et réliqua.
Homilía sancti Leónis Papæ
Evangélica lectio, dilectíssimi, quæ per aures córporis interiórem méntium nostrárum pulsávit audítum, ad magni sacraménti nos intellegéntiam vocat: quam, aspiránte grátia Dei, facílius assequémur, si consideratiónem nostram ad ea, quæ paulo supérius sunt narráta, referámus. Salvátor enim humáni géneris Jesus Christus, condens eam fidem, quæ et ímpios ad justítiam, et mórtuos révocat ad vitam, ad hoc discípulos suos doctrínæ mónitis, et óperum miráculis imbuébat, ut idem Christus et Unigénitus Dei, et hóminis Fílius crederétur. Nam unum horum sine áltero non próderat ad salútem: et æquális erat perículi, Dóminum Jesum Christum aut Deum tantúmmodo sine hómine, aut sine Deo solum hóminem credidísse: cum utrúmque esset páriter confiténdum: quia sicut Deo vera humánitas, ita hómini ínerat vera divínitas.")
               (:text "Ad confírmandam ergo hujus fídei salubérrimam cognitiónem interrogáverat discípulos suos Dóminus, inter divérsas aliórum opiniónes quid ipsi de eo créderent, quidve sentírent. Ubi Petrus Apóstolus, per revelatiónem summi Patris corpórea súperans, et humána transcéndens, vidit mentis óculis Fílium Dei vivi, et conféssus est glóriam Deitátis; quia non ad solam respéxit substántiam carnis et sánguinis: tantúmque in hac fídei sublimitáte complácuit, ut beatitúdinis felicitáte donátus, sacram inviolábilis petræ accíperet firmitátem: super quam fundáta Ecclésia, portis ínferi et mortis légibus prævaléret: nec in solvéndis aut ligándis quorumcúmque causis áliud ratum esset in cælis, quam quod Petri sedísset arbítrio.")
               (:text "Hæc autem, dilectíssimi, laudátæ intellegéntiæ celsitúdo instruénda erat de inferióris substántiæ sacraménto: ne apostólica fides ad glóriam confiténdæ in Christo Deitátis evécta, infirmitátis nostræ receptiónem indígnam impassíbili Deo atque incóngruam judicáret: et ita jam in Christo humánam créderet glorificátam esse natúram, ut nec supplício posset áffici, nec morte dissólvi. Et ídeo dicénte Dómino, quod oportéret eum ire Jerosólymam, et multa pati a senióribus et scribis, ac princípibus sacerdótum, et occídi, et tértia die resúrgere: cum beátus Petrus, qui supérno illustrátus lúmine, de ardentíssima Fílii Dei confessióne fervébat, contumélias illusiónum et crudelíssimæ mortis oppróbrium religióso, ut putábat, et líbero fastídio respuísset; benígna a Jesu increpatióne corréptus, et ad cupiditátem participándæ cum eo passiónis animátus est."))
              :responsories
              ((:respond "Scíndite corda vestra, et non vestiménta vestra: et convertímini ad Dóminum Deum vestrum:"
                  :verse "Derelínquat ímpius viam suam, et vir iníquus cogitatiónes suas, et revertátur ad Dóminum, et miserébitur ejus."
                  :repeat "Quia benígnus et miséricors est."
                  :gloria nil)
               (:respond "Frange esuriénti panem tuum, et egénos vagósque induc in domum tuam:"
                  :verse "Cum víderis nudum, óperi eum, et carnem tuam ne despéxeris."
                  :repeat "Tunc erúmpet quasi mane lumen tuum, et anteíbit fáciem tuam justítia tua."
                  :gloria nil)
               (:respond "Abscóndite eleemósynam in sinu páuperum, et ipsa orábit pro vobis ad Dóminum:"
                  :verse "Date eleemósynam, et ecce ómnia munda sunt vobis."
                  :repeat "Quia sicut aqua extínguit ignem, ita eleemósyna extínguit peccátum."
                  :gloria t))))

    ;; Quad2-1: Feria Secunda infra Hebdomadam II in Quadragesima
    ((2 . 1) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 38 in Joann. post init."
               :text "In illo témpore: Dixit Jesus turbis Judæórum: Ego vado, et quærétis me, et in peccáto vestro moriémini. Et réliqua.
Homilía sancti Augustíni Epíscopi
Locútus est Dóminus Judǽis, dicens: Ego vado. Christo enim Dómino mors proféctio fuit illo, unde vénerat, et unde non discésserat. Ego, inquit, vado, et quærétis me, non desidério, sed ódio. Nam illum póstea quam abscéssit ab óculis hóminum, inquisiérunt et qui óderant, et qui amábant: illi persequéndo, isti habére cupiéndo. In Psalmis ait ipse Dóminus per Prophétam: Périit fuga a me, et non est qui requírat ánimam meam. Et íterum ait álio loco in Psalmo: Confundántur et revereántur requiréntes ánimam meam.")
               (:text "Culpávit, qui non requírerent: damnávit requiréntes. Bonum est enim quǽrere ánimam Christi, sed quo modo eam quæsiérunt discípuli: et malum est quǽrere ánimam Christi, sed quo modo eam Judǽi quæsiérunt: illi enim ut habérent, isti ut pérderent. Dénique istis, quia sic quærébant more malo, corde pervérso, quid secutus adjúnxit? Quærétis me; et ne putétis, quia bene me quærétis, in peccáto vestro moriémini. Hoc est Christum male quǽrere, in peccáto suo mori: hoc est illum odísse, per quem possit solum salvus esse.")
               (:text "Cum enim hómines, quorum spes in Deo est, non débeant mala réddere nec pro malis; reddébant isti mala pro bonis. Prænuntiávit ergo illis Dóminus, dixítque senténtiam prǽscius, quod in suo peccáto moreréntur. Deínde adjúnxit: Quo ego vado, vos non potéstis veníre. Hoc et discípulis suis álio loco dixit: nec tamen eis dixit: In peccáto vestro moriémini. Quid autem dixit? quod et istis: Quo ego vado, vos non potéstis veníre. Non ábstulit spem, sed prædíxit dilatiónem. Quando enim hoc discípulis Dóminus loquebátur, tunc non póterant veníre, quo ille ibat, sed póstea ventúri erant: isti autem nunquam, quibus prǽscius dixit, In peccáto vestro moriémini."))
              :responsories
              ((:respond "Dum iret Jacob de Bersabée, et pérgeret Haram, locútus est ei Dóminus, dicens:"
                  :verse "Ædificávit ex lapídibus altáre in honórem Dómini, fundens óleum désuper: et benedíxit eum Deus, dicens."
                  :repeat "Terram, in qua dormis, tibi dabo, et sémini tuo."
                  :gloria nil)
               (:respond "Appáruit Deus Jacob, et benedíxit eum, et dixit: Ego sum Deus Bethel, ubi unxísti lápidem, et votum vovísti mihi:"
                  :verse "Vere Dóminus est in loco isto, et ego nesciébam."
                  :repeat "Créscere te fáciam, et multiplicábo te."
                  :gloria nil)
               (:respond "Det tibi Deus de rore cæli et de pinguédine terræ abundántiam: sérviant tibi tribus et pópuli:"
                  :verse "Et incurvéntur ante te fílii matris tuæ."
                  :repeat "Esto dóminus fratrum tuórum."
                  :gloria t))))

    ;; Quad2-2: Feria Tertia infra Hebdomadam II in Quadragesima
    ((2 . 2) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 4 Comment. in cap. 23 Matthæi"
               :text "In illo témpore: Locútus est Jesus ad turbas, et ad discípulos suos, dicens: Super cáthedram Móysi sedérunt scribæ et pharisǽi. Omnia ergo quæcúmque díxerint vobis, serváte, et fácite: secúndum ópera vero eórum nolíte fácere. Et réliqua.
Homilía sancti Hierónymi Presbýteri
Quid mansuétius, quid benígnius Dómino? Tentátur a pharisǽis, confringúntur insídiæ eórum, et secúndum Psalmístam: Sagíttæ parvulórum factæ sunt plagæ eórum: et nihilóminus propter sacerdótii et nóminis dignitátem hortátur pópulos, ut subiciántur eis, non ópera, sed doctrínam considerántes. Quod autem ait, Super cáthedram Móysi sedérunt scribæ et pharisǽi: per cáthedram, doctrínam Legis osténdit. Ergo et illud quod dícitur in Psalmo: In cáthedra pestiléntiæ non sedit: et, Cáthedras vendéntium colúmbas evértit: doctrínam debémus accípere.")
               (:text "Alligant enim ónera grávia et importabília, et impónunt in húmeros hóminum, dígito autem suo nolunt ea movére. Hoc generáliter advérsus omnes magístros, qui grávia jubent, et minóra non fáciunt. Notándum autem, quod et húmeri, et dígitus, et ónera, et víncula quibus alligántur ónera, spirituáliter intellegénda sunt. Omnia vero ópera sua fáciunt, ut videántur ab homínibus. Quicúmque ígitur ita facit quódlibet, ut videátur ab homínibus, scriba et pharisǽus est.")
               (:text "Dilátant enim phylactéria sua, et magníficant fímbrias. Amant quoque primos recúbitus in cenis, et primas cáthedras in synagógis, et salutatiónes in foro, et vocári ab homínibus Rabbi. Væ nobis míseris, ad quos pharisæórum vítia transiérunt. Dóminus cum dedísset mandáta Legis per Móysen, ad extrémum íntulit: Ligábis ea in manu tua, et erunt immóta ante óculos tuos. Et est sensus: Præcépta mea sint in manu tua, ut ópere compleántur: sint ante óculos tuos, ut die ac nocte meditéris in eis. Hoc pharisǽi male interpretántes, scribébant in membránis decálogum Móysi, id est, decem verba Legis, complicántes ea et ligántes in fronte, et quasi corónam cápiti faciéntes: ut semper ante óculos moveréntur."))
              :responsories
              ((:respond "Dum exíret Jacob de terra sua, vidit glóriam Dei, et ait: Quam terríbilis est locus iste!"
                  :verse "Vere Deus est in loco isto, et ego nesciébam."
                  :repeat "Non est hic áliud, nisi domus Dei, et porta cæli."
                  :gloria nil)
               (:respond "Si Dóminus Deus meus fúerit mecum in via ista, per quam ego ámbulo, et custodíerit me, et déderit mihi panem ad edéndum, et vestiméntum quo opériar, et revocáverit me cum salúte:"
                  :verse "Surgens ergo mane Jacob, tulit lápidem quem supposúerat cápiti suo, et eréxit in títulum, fundénsque óleum désuper, dixit."
                  :repeat "Erit mihi Dóminus in refúgium, et lapis iste in signum."
                  :gloria nil)
               (:respond "Erit mihi Dóminus in Deum, et lapis iste quem eréxi in títulum, vocábitur domus Dei: et de univérsis quæ déderis mihi,"
                  :verse "Si revérsus fúero próspere ad domum patris mei."
                  :repeat "Décimas et hóstias pacíficas ófferam tibi."
                  :gloria t))))

    ;; Quad2-3: Feria Quarta infra Hebdomadam II in Quadragesima
    ((2 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 5 de Fide ad Gratianum, cap. 2, post initium"
               :text "In illo témpore: Ascéndens Jesus Jerosólymam, assúmpsit duódecim discípulos secréto, et ait illis: Ecce ascéndimus Jerosólymam, et Fílius hóminis tradétur princípibus sacerdótum, et scribis, et condemnábunt eum morte. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Consideráte, quæ mater filiórum Zebedǽi cum fíliis et pro fíliis petat: mater est útique, cui pro filiórum honóre sollícitæ, immoderátior quidem, sed tamen ignoscénda mensúra votórum est. Atque mater ætáte longǽva, stúdio religiósa, solátio destitúta, quæ tunc témporis, quando vel juvánda, vel alénda foret válidæ prolis auxílio, abésse sibi líberos patiebátur, et voluptáti suæ mercédem sequéntium Christum prætúlerat filiórum. Qui prima voce vocáti a Dómino (ut légimus) relíctis rétibus et patre, secúti sunt eum.")
               (:text "Hæc ígitur, stúdio matérnæ sedulitátis indulgéntior, obsecrábat Salvatórem, dicens: Ut sédeant hi duo fílii mei, unus ad déxteram tuam, et alter ad sinístram in regno tuo. Etsi error, pietátis tamen error est. Nésciunt enim matérna víscera patiéntiam: etsi voti avára, tamen veniábilis cupíditas, quæ non pecúniæ est ávida, sed grátiæ. Nec inverecúnda petítio, quæ non sibi, sed líberis consulébat. Matrem consideráte, matrem cogitáte.")
               (:text "Considerábat Christus matris dilectiónem, quæ filiórum mercéde grandǽvam solabátur senéctam: et desidériis licet fessa matérnis, carissimórum pignórum tolerábat abséntiam. Consideráte étiam féminam, hoc est, sexum fragiliórem, quem Dóminus própria nondum confirmáverat passióne. Consideráte, inquam, Hevæ illíus primæ mulíeris herédem, transfúsa in omnes immoderátæ cupiditátis successióne labéntem: quam Dóminus adhuc próprio sánguine non redémerat, nondum inólitam afféctibus ómnium immódici contra fas honóris appeténtiam suo Christus cruóre dilúerat. Hereditário ígitur múlier delinquébat erróre."))
              :responsories
              ((:respond "Dixit Angelus ad Jacob:"
                  :verse "Cumque surrexísset Jacob, ecce vir luctabátur cum eo usque mane: et cum vidéret quod eum superáre non posset, dixit ad eum."
                  :repeat "Dimítte me, auróra est. Respóndit ei: Non dimíttam te, nisi benedíxeris mihi. Et benedíxit ei in eódem loco."
                  :gloria nil)
               (:respond "Vidi Dóminum fácie ad fáciem:"
                  :verse "Et dixit mihi: Nequáquam vocáberis Jacob, sed Israël erit nomen tuum."
                  :repeat "Et salva facta est ánima mea."
                  :gloria nil)
               (:respond "Cum audísset Jacob quod Esau veníret contra eum, divísit fílios suos et uxóres, dicens: Si percússerit Esau unam turmam, salvábitur áltera."
                  :verse "Dómine, qui dixísti mihi, Revértere in terram nativitátis tuæ: Dómine, qui pascis me a juventúte mea."
                  :repeat "Líbera me, Dómine, qui dixísti mihi: * Multiplicábo semen tuum sicut stellas cæli, et sicut arénam maris, quæ præ multitúdine numerári non potest."
                  :gloria t))))

    ;; Quad2-4: Feria Quinta infra Hebdomadam II in Quadragesima
    ((2 . 4) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Homilia 40 in Evangelia"
               :text "In illo témpore: Dixit Jesus pharisǽis: Homo quidam erat dives, qui induebátur púrpura et bysso: et epulabátur cotídie spléndide. Et réliqua.
Homilía sancti Gregórii Papæ
Quem, fratres caríssimi, quem dives iste, qui induebátur púrpura et bysso, et epulabátur cotídie spléndide, nisi Judáicum pópulum signat: qui cultum vitæ extérius hábuit, qui accéptæ legis delíciis ad nitórem usus est, non ad utilitátem? Quem vero Lázarus ulcéribus plenus, nisi gentílem pópulum figuráliter éxprimit? Qui dum convérsus ad Deum peccáta confitéri sua non erúbuit, huic vulnus in cute fuit. In cutis quippe vúlnere virus a viscéribus tráhitur, et foras erúmpit.")
               (:text "Quid est ergo peccatórum conféssio, nisi quædam vúlnerum rúptio? Quia peccáti virus salúbriter aperítur in confessióne, quod pestífere latébat in mente. Vúlnera étenim cutis in superfíciem trahunt humórem putrédinis. Et confiténdo peccáta, quid áliud ágimus, nisi malum, quod in nobis latébat, aperímus? Sed Lázarus vulnerátus cupiébat saturári de micis, quæ cadébant de mensa dívitis, et nemo illi dabat: quia gentílium quemque ad cognitiónem legis admíttere supérbus ille pópulus despiciébat.")
               (:text "Qui dum doctrínam legis non ad caritátem hábuit, sed ad elatiónem, quasi de accéptis ópibus túmuit: et quia ei verba defluébant de sciéntia, quasi micæ cadébant de mensa. At contra, jacéntis páuperis vúlnera lingébant canes. Nonnúnquam solent in sacro elóquio, per canes prædicatóres intéllegi. Canum étenim lingua, vulnus dum lingit, curat: quia et doctóres sancti, dum in confessióne peccáti nostri nos ínstruunt, quasi vulnus mentis per linguam tangunt."))
              :responsories
              ((:respond "Tolle arma tua, pháretram et arcum, et affer de venatióne tua, ut cómedam:"
                  :verse "Cumque venátu áliquid attúleris, fac mihi inde pulméntum, ut cómedam."
                  :repeat "Et benedícat tibi ánima mea."
                  :gloria nil)
               (:respond "Ecce odor fílii mei sicut odor agri pleni, cui benedíxit Dóminus: créscere te fáciat Deus meus sicut arénam maris:"
                  :verse "Deus autem omnípotens benedícat tibi, atque multíplicet."
                  :repeat "Et donet tibi de rore cæli benedictiónem."
                  :gloria nil)
               (:respond "Det tibi Deus de rore cæli et de pinguédine terræ abundántiam: sérviant tibi tribus et pópuli:"
                  :verse "Et incurvéntur ante te fílii matris tuæ."
                  :repeat "Esto dóminus fratrum tuórum."
                  :gloria t))))

    ;; Quad2-5: Feria Sexta infra Hebdomadam II in Quadragesima
    ((2 . 5) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 9 in cap. 20 Lucæ"
               :text "In illo témpore: Dixit Jesus turbis Judæórum, et princípibus sacerdótum parábolam hanc: Homo erat paterfamílias, qui plantávit víneam, et sepem circúmdedit ei. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Pleríque várias significatiónes de víneæ appellatióne derívant: sed evidénter Isaías víneam Dómini Sábaoth, domum Israël esse memorávit. Hanc víneam quis álius, nisi Deus, cóndidit? Hic est ergo qui eam locávit colónis, et ipse péregre fuit: non quia ex loco ad locum proféctus est Dóminus, qui ubíque semper præsens est: sed quia est præséntior diligéntibus, negligéntibus abest. Multis tempóribus ábfuit, ne præprópera viderétur exáctio. Nam quo indulgéntior liberálitas, eo inexcusabílior pervicácia.")
               (:text "Unde bene secúndum Matthǽum habes, quia et sepem circúmdedit: hoc est, divínæ custódiæ munitióne vallávit, ne fácile spiritálium patéret incúrsibus bestiárum. Et fodit in ea tórcular. Quómodo intellégimus quid sit tórcular, nisi forte quia Psalmi pro torculáribus inscribúntur; eo quod in his mystéria Domínicæ passiónis, modo musti Sancto fervéntis Spíritu, redundántius æstuáverint? Unde ébrii putabántur, quibus Spíritus Sanctus inundábat. Ergo et hic fodit tórcular, in quod uvæ rationábilis fructus intérior spiritáli infusióne deflúeret.")
               (:text "Ædificávit turrim, vérticem scílicet legis attóllens: atque ita hanc víneam munítam, instrúctam, ornátam, locávit Judǽis. Et témpore frúctuum sérvulos misit. Bene tempus frúctuum pósuit, non provéntuum. Nullus enim fructus éxstitit Judæórum, nullus víneæ hujus provéntus, de qua Dóminus ait: Exspectávi ut fáceret uvas, fecit autem spinas. Itaque non lætítiæ vino, non spiritáli musto, sed cruénto Prophetárum sánguine torculária redundárunt."))
              :responsories
              ((:respond "Dum exíret Jacob de terra sua, vidit glóriam Dei, et ait: Quam terríbilis est locus iste!"
                  :verse "Vere Deus est in loco isto, et ego nesciébam."
                  :repeat "Non est hic áliud, nisi domus Dei, et porta cæli."
                  :gloria nil)
               (:respond "Si Dóminus Deus meus fúerit mecum in via ista, per quam ego ámbulo, et custodíerit me, et déderit mihi panem ad edéndum, et vestiméntum quo opériar, et revocáverit me cum salúte:"
                  :verse "Surgens ergo mane Jacob, tulit lápidem quem supposúerat cápiti suo, et eréxit in títulum, fundénsque óleum désuper, dixit."
                  :repeat "Erit mihi Dóminus in refúgium, et lapis iste in signum."
                  :gloria nil)
               (:respond "Erit mihi Dóminus in Deum, et lapis iste quem eréxi in títulum, vocábitur domus Dei: et de univérsis quæ déderis mihi,"
                  :verse "Si revérsus fúero próspere ad domum patris mei."
                  :repeat "Décimas et hóstias pacíficas ófferam tibi."
                  :gloria t))))

    ;; Quad2-6: Sabbato infra Hebdomadam II in Quadragesima
    ((2 . 6) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Lib. 8 Comment. in cap. 15 Lucæ, post initium"
               :text "In illo témpore: Dixit Jesus pharisǽis et scribis parábolam istam: Homo quidam hábuit duos fílios: et dixit adolescéntior ex illis patri: Pater, da mihi portiónem substántiæ, quæ me contíngit. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Vides, quod divínum patrimónium peténtibus datur. Nec putes culpam patris, quod adolescentióri dedit. Nulla Dei regno infírma ætas: nec fides gravátur annis. Ipse certe se judicávit idóneum, qui popóscit. Atque útinam non recessísset a patre, impediméntum nescísset ætátis. Sed posteáquam domum pátriam derelínquens péregre proféctus est, cœpit egére. Mérito ergo prodégit patrimónium, qui recéssit ab Ecclésia.")
               (:text "Péregre proféctus est in regiónem longínquam. Quid longínquius, quam a se recédere: nec regiónibus, sed móribus separári: stúdiis discrétum esse, non terris; et quasi interfúso luxúriæ sæculáris æstu, divórtia habére sanctórum? Etenim qui se a Christo séparat, exsul est pátriæ, civis est mundi. Sed nos non sumus ádvenæ atque peregríni, sed cives sumus Sanctórum, et doméstici Dei. Qui enim erámus longe, facti sumus prope in sánguine Christi. Non invideámus de longínqua regióne remeántibus: quia et nos fúimus in regióne longínqua, sicut Isaías docet. Sic enim habes: Qui sedébant in regióne umbræ mortis, lux orta est illis. Régio ergo longínqua, umbra est mortis.")
               (:text "Nos autem, quibus spíritus ante fáciem Christus est Dóminus, in umbra vívimus Christi. Et ídeo dicit Ecclésia: In umbra ejus concupívi, et sedi. Ille ígitur vivéndo luxurióse, consúmpsit ómnia ornaménta natúræ. Unde tu, qui accepísti imáginem Dei, qui habes similitúdinem ejus, noli eam irrationábili fœditáte consúmere. Opus Dei es: noli ligno dícere, Pater meus es tu: ne accípias similitúdinem ligni, quia scriptum est: Símiles illis fiant qui fáciunt ea."))
              :responsories
              ((:respond "Pater, peccávi in cælum, et coram te: jam non sum dignus vocári fílius tuus:"
                  :verse "Quanti mercenárii in domo patris mei abúndant pánibus, ego autem hic fame péreo! Surgam, et ibo ad patrem meum, et dicam ei."
                  :repeat "Fac me sicut unum ex mercenáriis tuis."
                  :gloria nil)
               (:respond "Vidi Dóminum fácie ad fáciem:"
                  :verse "Et dixit mihi: Nequáquam vocáberis Jacob, sed Israël erit nomen tuum."
                  :repeat "Et salva facta est ánima mea."
                  :gloria nil)
               (:respond "Cum audísset Jacob quod Esau veníret contra eum, divísit fílios suos et uxóres, dicens: Si percússerit Esau unam turmam, salvábitur áltera."
                  :verse "Dómine, qui dixísti mihi, Revértere in terram nativitátis tuæ: Dómine, qui pascis me a juventúte mea."
                  :repeat "Líbera me, Dómine, qui dixísti mihi: * Multiplicábo semen tuum sicut stellas cæli, et sicut arénam maris, quæ præ multitúdine numerári non potest."
                  :gloria t))))

    ;; Quad3-1: Feria Secunda infra Hebdomadam III in Quadragesima
    ((3 . 1) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Lib. 4 in c. 4 Lucæ, post med."
               :text "In illo témpore: Dixit Jesus pharisǽis: Utique dicétis mihi hanc similitúdinem: Médice, cura te ipsum: quanta audívimus facta in Caphárnaum, fac et hic in pátria tua. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Non medíocris invídia próditur, quæ cívicæ caritátis oblíta, in acérba ódia causas amóris infléctit. Simul hoc exémplo páriter et oráculo declarátur, quod frustra opem misericórdiæ cæléstis exspéctes, si aliénæ frúctibus virtútis invídeas. Aspernátor enim Dóminus invidórum est: et ab iis qui divína benefícia in áliis persequúntur, mirácula suæ potestátis avértit. Domínicæ quippe carnis actus, divinitátis exémplum est: et invisibília nobis ejus, per ea quæ sunt visibília, demonstrántur.")
               (:text "Non otióse ítaque Salvátor excúsat, quod nulla in pátria sua mirácula virtútis operátus sit: ne fortássis áliquis viliórem pátriæ nobis esse debére putáret afféctum. Neque enim cives póterat non amáre, qui amáret omnes: sed ipsi se caritáte pátriæ, dum ínvident, abdicárunt. In veritáte dico vobis: multæ víduæ fuérunt in diébus Elíæ. Non quia Elíæ dies fuérunt, sed in quibus Elías operátus est: aut quia Elías dies faciébat illis, qui in ejus opéribus lucem vidébant grátiæ spiritális, et convertebántur ad Dóminum. Et ídeo aperiebátur cælum vidéntibus ætérna et divína mystéria: claudebátur, et fames erat, quando nulla erat cognoscéndæ divinitátis ubértas. Sed de hoc plénius díximus, cum de víduis scriberémus.")
               (:text "Et multi leprósi erant in Judǽa tempóribus Eliséi prophétæ: et nemo eórum mundátus est, nisi Náaman Syrus. Evidénter hic sermo nos Dómini salutáris infórmat, et ad stúdium venerándæ divinitátis hortátur: quod nemo sanátus osténditur, et maculósi morbo córporis absolútus, nisi qui religióso offício stúduit sanitáti. Non enim dormiéntibus divína benefícia, sed observántibus deferúntur. Díximus in libro álio, in vídua illa, ad quam Elías diréctus est, typum Ecclésiæ præmíssum. Pópulus Ecclésiam congregávit, ut sequátur pópulus ille ex alienígenis congregátus. Pópulus ille ante leprósus, pópulus ille ante maculósus, priúsquam mýstico baptizarétur in flúmine: idem post sacraménta baptísmatis máculis córporis et mentis ablútus, jam non lepra, sed immaculáta virgo cœpit esse sine ruga."))
              :responsories
              ((:respond "Tóllite hinc vobíscum múnera, et ite ad dóminum terræ: et cum invenéritis, adoráte eum super terram:"
                  :verse "Súmite de óptimis terræ frúgibus in vasis vestris, et deférte viro múnera."
                  :repeat "Deus autem meus fáciat eum vobis placábilem: et remíttat et hunc fratrem vestrum vobíscum, et eum quem tenet in vínculis."
                  :gloria nil)
               (:respond "Iste est frater vester mínimus, de quo dixerátis mihi? Deus misereátur tibi, fili mi."
                  :verse "Attóllens autem Joseph óculos, vidit Bénjamin stantem: et commóta sunt ómnia víscera ejus super fratre suo."
                  :repeat "Festinavítque in domum, et plorávit: quia erumpébant lácrimæ, et non póterat se continére."
                  :gloria nil)
               (:respond "Dixit Joseph úndecim frátribus suis: Ego sum Joseph, quem vendidístis in Ægýptum: adhuc vivit pater noster sénior, de quo dixerátis mihi?"
                  :verse "Biénnium enim est, quod cœpit esse fames in terra: et adhuc restant anni quinque, quibus nec arári póterit, nec meti."
                  :repeat "Ite, addúcite eum ad me, ut possit vívere."
                  :gloria t))))

    ;; Quad3-2: Feria Tertia infra Hebdomadam III in Quadragesima
    ((3 . 2) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Sermo 16 de Verbis Domini, tomus 10, post initium"
               :text "In illo témpore: Dixit Jesus discípulis suis: Si peccáverit in te frater tuus, vade, et córripe eum inter te et ipsum solum. Et réliqua.
Homilía sancti Augustíni Epíscopi
Quare illum córripis? Quia tu doles, quod peccáverit in te? Absit. Si amóre tui id facis, nihil facis: si amóre illíus facis, óptime facis. Dénique in ipsis verbis atténde, cujus amóre id fácere débeas, utrum tui, an illíus. Si te audíerit, inquit, lucrátus es fratrem tuum. Ergo propter illum fac, ut lucréris illum. Sic faciéndo lucráris: nisi fecísses, períerat. Quid est ergo, quod pleríque hómines ista peccáta contémnunt, et dicunt: Quid magnum feci? In hóminem peccávi. Noli contémnere: in hóminem peccásti.")
               (:text "Vis nosse, quia in hóminem peccándo perísti? Si te ille, in quem peccásti, corripúerit inter te et ipsum solum, et audíeris illum, lucrátus est te. Quid est, Lucrátus est te; nisi quia períeras, si non lucrarétur te? Nam si non períeras, quómodo te lucrátus est? Nemo ergo contémnat, quando peccat in fratrem. Ait enim quodam loco Apóstolus: Sic autem peccántes in fratres, et percutiéntes consciéntiam eórum infírmam, in Christum peccátis: ídeo quia membra Christi omnes facti sumus. Quómodo non peccas in Christum, qui peccas in membrum Christi?")
               (:text "Nemo ergo dicat, quia non peccávi in Deum, sed peccávi in fratrem: in hóminem peccávi, leve, vel nullum peccátum est. Forte inde dicis: Leve est, quia cito curátur. Peccásti in fratrem: fac satis, et sanátus es. Cito fecísti mortíferam rem, sed remédium cito invenísti. Quis nostrum speret regnum cælórum, fratres mei, quando dicit Evangélium: Qui díxerit fratri suo, Fátue: reus erit gehénnæ ignis? Magnus terror: sed vide ibi remédium. Si obtúleris munus tuum ad altáre, et ibi recordátus fúeris, quia frater tuus habet áliquid advérsum te, relínque ibi munus tuum ante altáre. Non iráscitur Deus, quia differs impónere munus tuum: te quærit Deus magis, quam munus tuum."))
              :responsories
              ((:respond "Nuntiavérunt Jacob dicéntes: Joseph fílius tuus vivit, et ipse dominátur in tota terra Ægýpti: quo audíto revíxit spíritus ejus, et dixit:"
                  :verse "Cumque audísset Jacob quod fílius ejus víveret, quasi de gravi somno evígilans, ait."
                  :repeat "Súfficit mihi, vadam et vidébo eum ántequam móriar."
                  :gloria nil)
               (:respond "Joseph dum intráret in terram Ægýpti, linguam quam non nóverat, audívit: manus ejus in labóribus serviérunt:"
                  :verse "Humiliavérunt in compédibus pedes ejus: ferrum petránsiit ánimam ejus, donec veníret verbum ejus."
                  :repeat "Et lingua ejus inter príncipes loquebátur sapiéntiam."
                  :gloria nil)
               (:respond "Meménto mei, dum bene tibi fúerit:"
                  :verse "Tres enim adhuc dies sunt, post quos recordábitur phárao ministérii tui, et restítuet te in gradum prístinum: tunc meménto mei."
                  :repeat "Ut súggeras pharaóni, ut edúcat me de isto cárcere: * Quia furtim sublátus sum, et hic ínnocens in lacum missus sum."
                  :gloria t))))

    ;; Quad3-3: Feria Quarta infra Hebdomadam III in Quadragesima
    ((3 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Matthǽum"
               :ref "Lib. 2 Comment. in cap. 15 Matthæi"
               :text "In illo témpore: Accessérunt ad Jesum ab Jerosólymis scribæ et pharisǽi, dicéntes: Quare discípuli tui transgrediúntur traditiónem seniórum? Et réliqua.
Homilía sancti Hierónymi Presbýteri
Mira pharisæórum scribarúmque stultítia. Dei Fílium árguunt, quare hóminum traditiónes et præcépta non servet: Non enim lavant manus suas, cum panem mandúcant. Manus, id est ópera, non córporis útique, sed ánimæ lavándæ sunt, ut fiat in illis verbum Dei. Ipse autem respóndens ait illis: Quare et vos transgredímini mandátum Dei propter traditiónem vestram? Falsam calúmniam vera responsióne confútat. Cum, inquit, vos propter traditiónem hóminum præcépta Dómini negligátis: quare discípulos meos arguéndos putátis, quod seniórum jussa parvipéndant, ut Dei scita custódiant?")
               (:text "Nam Deus dixit: Honóra patrem et matrem; et, Qui maledíxerit patri, vel matri, morte moriátur. Vos autem dícitis: Quicúmque díxerit patri, vel matri: Munus quodcúmque est ex me, tibi próderit: et non honorificábit patrem suum, aut matrem suam. Honor in Scriptúris non tantum in salutatiónibus et offíciis deferéndis, quantum in eleemósynis, ac múnerum oblatióne sentítur. Honóra, inquit Apóstolus, víduas, quæ vere víduæ sunt. Hic honor donum intellégitur. Et in álio loco: Presbýteri dúplici honóre honorándi sunt, máxime qui labórant in verbo et doctrína Dei. Et per hoc mandátum jubémur bovi trituránti os non cláudere: et dignus sit operárius mercéde sua.")
               (:text "Præcéperat Dóminus, vel imbecillitátes, vel ætátes, vel penúrias paréntum consíderans, ut fílii honorárent, étiam in vitæ necessáriis ministrándis, paréntes suos. Hanc providentíssimam Dei legem voléntes scribæ et pharisǽi subvértere, ut impietátem sub nómine pietátis indúcerent, docuérunt péssimos fílios, ut si quis ea, quæ paréntibus offerénda sunt, Deo vovére volúerit, qui verus est pater, oblátio Dómini præponátur paréntum munéribus: vel certe ipsi paréntes, quæ Deo consecráta cernébant, ne sacrilégii crimen incúrrerent, declinántes, egestáte conficiebántur. Atque ita fiébat, ut oblátio liberórum sub occasióne templi et Dei, in sacerdótum lucra céderet."))
              :responsories
              ((:respond "Mérito hæc pátimur, quia peccávimus in fratrem nostrum, vidéntes angústias ánimæ ejus, dum deprecarétur nos, et non audívimus:"
                  :verse "Dixit Ruben frátribus suis: Numquid non dixi vobis, Nolíte peccáre in púerum; et non audístis me?"
                  :repeat "Idcírco venit super nos tribulátio."
                  :gloria nil)
               (:respond "Dixit Ruben frátribus suis: Numquid non dixi vobis, Nolíte peccáre in púerum, et non audístis me?"
                  :verse "Mérito hæc pátimur, quia peccávimus in fratrem nostrum, vidéntes angústias ánimæ ejus, dum deprecarétur nos, et non audívimus."
                  :repeat "En sanguis ejus exquíritur."
                  :gloria nil)
               (:respond "Lamentabátur Jacob de duóbus fíliis suis: Heu me, dolens sum de Joseph pérdito, et tristis nimis de Bénjamin ducto pro alimóniis:"
                  :verse "Prostérnens se Jacob veheménter cum lácrimis pronus in terram, et adórans ait."
                  :repeat "Precor cæléstem Regem, ut me doléntem nímium fáciat eos cérnere."
                  :gloria t))))

    ;; Quad3-4: Feria Quinta infra Hebdomadam III in Quadragesima
    ((3 . 4) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Liber 4 in cap. 4 Lucæ, circa finem"
               :text "In illo témpore: Surgens Jesus de synagóga, introívit in domum Simónis. Socrus autem Simónis tenebátur magnis fébribus. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Vide cleméntiam Dómini Salvatóris: nec indignatióne commótus nec scélere offénsus, nec injúria violátus Judǽam déserit: quin étiam ímmemor injúriæ, memor cleméntiæ, nunc docéndo, nunc liberándo, nunc sanándo, infídæ plebis corda demúlcet. Et bene sanctus Lucas virum ab spíritu nequítiæ liberátum ante præmísit, et subdit féminæ sanitátem. Utrúmque enim sexum Dóminus curatúrus advénerat: sed prior sanári débuit, qui prior creátus est; nec prætermítti illa, quæ mobilitáte magis ánimi, quam pravitáte peccáverat.")
               (:text "Sábbato medicínæ Domínicæ ópera cœpta signíficat, ut inde nova creatúra cœ́perit, ubi vetus creatúra ante desívit: nec sub lege esse Dei Fílium, sed supra legem in ipso princípio designáret: nec solvi legem, sed impléri. Neque enim per legem, sed verbo factus est mundus, sicut légimus: Verbo Dómini cæli firmáti sunt. Non sólvitur ergo lex, sed implétur: ut fiat renovátio hóminis jam labéntis. Unde et Apóstolus ait: Exspoliántes vos véterem hóminem, indúite novum, qui secúndum Deum creátus est.")
               (:text "Et bene sábbato cœpit, ut ipsum se osténderet Creatórem, qui ópera opéribus intéxeret, et prosequerétur opus, quod ipse jam cœ́perat: ut si domum faber renováre dispónat, non a fundaméntis, sed a culmínibus íncipit sólvere vetustátem. Itaque ibi prius manum ádmovet, ubi ante desíerat: deínde a minóribus íncipit, ut ad majóra pervéniat. Liberáre a dǽmone et hómines, sed in verbo Dei possunt: resurrectiónem mórtuis imperáre, divínæ solíus est potestátis. Fortássis étiam in typo mulíeris illíus socrus Simónis et Andréæ, váriis críminum fébribus caro nostra languébat, et diversárum cupiditátum immódicis æstuábat illécebris. Nec minórem febrem amóris esse díxerim, quam calóris. Itaque illa ánimum, hæc corpus inflámmat. Febris enim nostra, avarítia est: febris nostra, libído est: febris nostra, luxúria est: febris nostra, ambítio est: febris nostra, iracúndia est."))
              :responsories
              ((:respond "Vidéntes Joseph a longe, loquebántur mútuo fratres, dicéntes: Ecce somniátor venit:"
                  :verse "Cumque vidíssent Joseph fratres sui, quod a patre cunctis frátribus plus amarétur, óderant eum, nec póterant ei quidquam pacífice loqui, unde et dicébant."
                  :repeat "Veníte, occidámus eum, et videámus si prosint illi sómnia sua."
                  :gloria nil)
               (:respond "Dixit Judas frátribus suis: Ecce Ismaëlítæ tránseunt; veníte, venumdétur, et manus nostræ non polluántur:"
                  :verse "Quid enim prodest, si occidérimus fratrem nostrum, et celavérimus sánguinem ipsíus? mélius est ut venumdétur."
                  :repeat "Caro enim et frater noster est."
                  :gloria nil)
               (:respond "Extrahéntes Joseph de lacu, vendidérunt Ismaëlítæ vigínti argénteis:"
                  :verse "At illi, intíncta túnica Joseph in sánguine hædi, misérunt qui ferret eam ad patrem, et díceret: Vide, si túnica fílii tui sit, an non."
                  :repeat "Reversúsque Ruben ad púteum, cum non invenísset eum, scidit vestiménta sua cum fletu, et dixit: Puer non compáret, et ego quo ibo?"
                  :gloria nil))))

    ;; Quad3-5: Feria Sexta infra Hebdomadam III in Quadragesima
    ((3 . 5) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 15 in Joánnem, post init."
               :text "In illo témpore: Venit Jesus in civitátem Samaríæ, quæ dícitur Sichar: juxta prǽdium, quod dedit Jacob Joseph fílio suo. Et réliqua.
Homilía sancti Augustíni Epíscopi
Jam incípiunt mystéria. Non enim frustra fatigátur Jesus: non enim frustra fatigátur virtus Dei: non enim frustra fatigátur, per quem fatigáti recreántur: non enim frustra fatigátur, quo deserénte fatigámur, quo præsénte firmámur. Fatigátur tamen Jesus, et fatigátur ab itínere, et sedet, et juxta púteum sedet, et hora sexta fatigátus sedet. Omnia ista ínnuunt áliquid, indicáre volunt áliquid: ut pulsémus, hortántur. Ipse ergo apériat et nobis et vobis, qui dignátus est ita hortári, ut díceret: Pulsáte, et aperiétur vobis.")
               (:text "Tibi fatigátus est ab itínere Jesus. Invenímus virtútem Jesum, et invenímus infírmum Jesum: fortem, et infírmum. Fortem, quia in princípio erat Verbum, et Verbum erat apud Deum, et Deus erat Verbum: hoc erat in princípio apud Deum. Vis vidére quam iste Fílius Dei fortis sit? Omnia per ipsum facta sunt, et sine ipso factum est nihil: et sine labóre facta sunt. Quid ergo illo fórtius, per quem sine labóre facta sunt ómnia? Infírmum vis nosse? Verbum caro factum est, et habitávit in nobis. Fortitúdo Christi te creávit: infírmitas Christi te recreávit. Fortitúdo Christi fecit, ut quod non erat, esset: infírmitas Christi fecit, ut quod erat, non períret. Cóndidit nos fortitúdine sua, quæsívit nos infirmitáte sua.")
               (:text "Nutrit ergo ipse infírmus infírmos, tamquam gallína pullos suos: huic enim se símilem fecit. Quóties vólui, inquit ad Jerúsalem, congregáre fílios tuos sub alas tamquam gallína pullos suos, et noluísti? Vidétis autem, fratres, quemádmodum gallína infirmétur cum pullis suis. Nulla enim ália avis, quod sit mater, agnóscitur. Vidémus nidificáre pásseres quóslibet ante óculos nostros: hirúndines, cicónias, colúmbas cotídie vidémus nidificáre: quos, nisi quando in nidis vidémus, paréntes esse non agnóscimus. Gallína vero sic infirmátur in pullis suis, ut étiam si ipsi pulli non sequántur, fílios non vídeas, matrem tamen intéllegas."))
              :responsories
              ((:respond "Videns Jacob vestiménta Joseph, scidit vestiménta sua cum fletu, et dixit:"
                  :verse "Tulérunt autem fratres ejus túnicam illíus, mitténtes ad patrem: quam cum cognovísset pater, ait."
                  :repeat "Fera péssima devorávit fílium meum Joseph."
                  :gloria nil)
               (:respond "Joseph dum intráret in terram Ægýpti, linguam quam non nóverat, audívit: manus ejus in labóribus serviérunt:"
                  :verse "Humiliavérunt in compédibus pedes ejus: ferrum petránsiit ánimam ejus, donec veníret verbum ejus."
                  :repeat "Et lingua ejus inter príncipes loquebátur sapiéntiam."
                  :gloria nil)
               (:respond "Meménto mei, dum bene tibi fúerit:"
                  :verse "Tres enim adhuc dies sunt, post quos recordábitur phárao ministérii tui, et restítuet te in gradum prístinum: tunc meménto mei."
                  :repeat "Ut súggeras pharaóni, ut edúcat me de isto cárcere: * Quia furtim sublátus sum, et hic ínnocens in lacum missus sum."
                  :gloria t))))

    ;; Quad3-6: Sabbato infra Hebdomadam III in Quadragesima
    ((3 . 6) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 33 in Joannem, post init."
               :text "In illo témpore: Perréxit Jesus in montem Olivéti, et dilúculo íterum venit in templum. Et réliqua.
Homilía sancti Augustíni Epíscopi
Jesus perréxit in montem Olivéti, in montem fructuósum, in montem unguénti, in montem chrísmatis. Ubi enim decébat docére Christum, nisi in monte Olivéti? Christi enim nomen a chrísmate dictum est: chrisma autem Græce, Latíne únctio nominátur. Ideo autem nos unxit, quia luctatóres contra diábolum fecit. Et dilúculo íterum venit in templum, et omnis pópulus venit ad eum: et sedens docébat eos, et non tenebátur, quia nondum pati dignabátur. Nunc jam atténdite, ubi ab inimícis tentáta sit Dómini mansuetúdo.")
               (:text "Addúcunt autem illi scribæ et pharisǽi mulíerem in adultério deprehénsam, et statuérunt eam in médio, et dixérunt ei: Magíster, hæc múlier modo deprehénsa est in adultério: in lege autem Móyses mandávit nobis hujúsmodi lapidáre: tu ergo quid dicis? Hæc autem dicébant tentántes eum: ut possent accusáre eum. Unde accusáre? Numquid ipsum in áliquo facínore deprehénderant, aut illa múlier ad eum áliquo modo pertinuísse dicebátur?")
               (:text "Intellegámus, fratres, admirábilem mansuetúdinem in Dómino fuísse. Animadvertérunt eum nímium esse mitem, nímium esse mansuétum. De illo quippe fúerat ante prædíctum: Accíngere gládio tuo circa femur tuum, potentíssime. Spécie tua et pulchritúdine tua inténde, próspere procéde, et regna: propter veritátem, et mansuetúdinem, et justítiam. Ergo áttulit veritátem ut doctor, mansuetúdinem ut liberátor, justítiam ut cógnitor. Propter hæc eum esse regnatúrum in Spíritu Sancto prophéta prædíxerat. Cum loquerétur, véritas agnoscebátur: cum advérsus inimícos non moverétur, mansuetúdo laudabátur. Cum ergo de duóbus istis, id est, de veritáte et mansuetúdine ejus, inimíci livóre et invídia torqueréntur; in tértio, id est justítia, scándalum posuérunt."))
              :responsories
              ((:respond "Mérito hæc pátimur, quia peccávimus in fratrem nostrum, vidéntes angústias ánimæ ejus, dum deprecarétur nos, et non audívimus:"
                  :verse "Dixit Ruben frátribus suis: Numquid non dixi vobis, Nolíte peccáre in púerum; et non audístis me?"
                  :repeat "Idcírco venit super nos tribulátio."
                  :gloria nil)
               (:respond "Dixit Ruben frátribus suis: Numquid non dixi vobis, Nolíte peccáre in púerum, et non audístis me?"
                  :verse "Mérito hæc pátimur, quia peccávimus in fratrem nostrum, vidéntes angústias ánimæ ejus, dum deprecarétur nos, et non audívimus."
                  :repeat "En sanguis ejus exquíritur."
                  :gloria nil)
               (:respond "Lamentabátur Jacob de duóbus fíliis suis: Heu me, dolens sum de Joseph pérdito, et tristis nimis de Bénjamin ducto pro alimóniis:"
                  :verse "Prostérnens se Jacob veheménter cum lácrimis pronus in terram, et adórans ait."
                  :repeat "Precor cæléstem Regem, ut me doléntem nímium fáciat eos cérnere."
                  :gloria t))))

    ;; Quad4-1: Feria Secunda infra Hebdomadam IV in Quadragesima
    ((4 . 1) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 10 in Joannem, post init."
               :text "In illo témpore: Prope erat Pascha Judæórum, et ascéndit Jesus Jerosólymam: et invénit in templo vendéntes boves, et oves, et colúmbas. Et réliqua.
Homilía sancti Augustíni Epíscopi
Quid audívimus, fratres? Ecce templum illud figúra adhuc erat, et ejécit inde Dóminus omnes qui sua quærébant, qui ad núndinas vénerant. Et quæ ibi vendébant illi? Quæ opus habébant hómines in sacrifíciis illíus témporis. Novit enim cáritas vestra, quod sacrifícia illi pópulo pro ejus carnalitáte, et corde adhuc lapídeo, tália data sunt, quibus tenerétur, ne in idóla deflúeret: et immolábant ibi sacrifícia, boves, oves et colúmbas. Nostis, quia legístis.")
               (:text "Non ergo magnum peccátum, si hoc vendébant in templo, quod emebátur ut offerétur in templo: et tamen ejécit inde illos. Quid si ibi ebriósos inveníret, quid fáceret Dóminus, si vendéntes ea quæ lícita sunt, et contra justítiam non sunt (quæ enim honéste emúntur, non illícite vendúntur) éxpulit tamen, et non est passus domum oratiónis fíeri domum negotiatiónis?")
               (:text "Si negotiatiónis domus non debet fíeri domus Dei, potatiónis debet fíeri? Nos autem quando ista dícimus, strident déntibus suis advérsus nos: et consolátur nos Psalmus, quem audístis: Stridérunt in me déntibus suis. Nóvimus et nos audíre unde curémur: etsi ingeminántur flagélla Christo, quia flagellátur sermo ipsíus. Congregáta sunt, inquit, in me flagélla, et nesciébant. Flagellátus est flagéllis Judæórum: flagellátur blasphémiis falsórum Christianórum: multíplicant flagélla Dómino Deo suo, et nésciunt. Faciámus nos, quantum ipse ádjuvat. Ego autem, cum mihi molésti essent, induébam me cilício, et humiliábam in jejúnio ánimam meam."))
              :responsories
              ((:respond "Vos, qui transitúri estis Jordánem, ædificáte altáre Dómino"
                  :verse "Cumque intravéritis terram, quam Dóminus datúrus est vobis, ædificáte ibi altáre Dómino."
                  :repeat "De lapídibus, quos ferrum non tétigit: et offérte super illud holocáusta, et hóstias pacíficas Deo vestro."
                  :gloria nil)
               (:respond "Audi, Israël, præcépta Dómini, et ea in corde tuo quasi in libro scribe:"
                  :verse "Obsérva ígitur, et audi vocem meam: et inimícus ero inimícis tuis."
                  :repeat "Et dabo tibi terram fluéntem lac et mel."
                  :gloria nil)
               (:respond "Sicut fui cum Moyse ita ero tecum, dicit Dóminus:"
                  :verse "Noli timére, quóniam tecum sum: ad quæcúmque perréxeris, non dimíttam te, neque derelínquam."
                  :repeat "Confortáre, et esto robústus: introdúces pópulum meum ad terram lacte et melle manántem."
                  :gloria t))))

    ;; Quad4-2: Feria Tertia infra Hebdomadam IV in Quadragesima
    ((4 . 2) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 29 in Joannem, sub init."
               :text "In illo témpore: Jam die festo mediánte, ascéndit Jesus in templum, et docébat. Et mirabántur Judǽi. Et réliqua.
Homilía sancti Augustíni Epíscopi
Ille qui latébat, docébat, et palam loquebátur, et non tenebátur. Illud enim ut latéret, erat causa exémpli, hoc potestátis. Sed cum docéret, mirabántur Judǽi. Omnes quidem, quantum árbitror, mirabántur, sed non omnes convertebántur. Et unde admirátio? Quia multi nóverant ubi natus, quemádmodum fúerit educátus. Nunquam eum víderant lítteras discéntem: audiébant autem de lege disputántem, legis testimónia proferéntem, quæ nemo posset proférre, nisi legísset, nemo légeret, nisi lítteras didicísset: et ídeo mirabántur. Eórum autem admirátio, magístro facta est insinuándæ áltius veritátis occásio.")
               (:text "Ex eórum quippe admiratióne et verbis, dixit Dóminus profúndum áliquid, et diligéntius ínspici et discúti dignum. Quid ergo Dóminus respóndit eis, admirántibus quómodo sciret lítteras, quas non didícerat? Mea, inquit, doctrína non est mea, sed ejus qui misit me. Hæc est profúnditas prima: vidétur enim paucis verbis quasi contrária locútus. Non enim ait: Ista doctrína non est mea: sed, Mea doctrína non est mea. Si non tua, quómodo tua? si tua, quómodo non tua? Tu enim dicis utrúmque: et mea doctrína, et non mea.")
               (:text "Si ergo intueámur diligénter quod ipse in exórdio dicit sanctus Evangelísta: In princípio erat Verbum, et Verbum erat apud Deum, et Deus erat Verbum: inde pendet hujus solútio quæstiónis. Quæ est doctrína Patris, nisi Verbum Patris? Ipse ergo Christus doctrína Patris, si Verbum Patris. Sed quia Verbum, non potest esse nullíus, sed alicújus: et suam doctrínam dixit seípsum, et non suam, quia Patris est Verbum. Quid enim tam tuum quam tu? Et quid tam non tuum quam tu, si alicújus est, quod es?"))
              :responsories
              ((:respond "Quid me quǽritis interfícere, hóminem qui vera locútus sum vobis?"
                  :verse "Multa bona ópera operátus sum vobis: propter quod opus vultis me occídere?"
                  :repeat "Si male locútus sum, testimónium pérhibe de malo: si autem bene, cur me cædis?"
                  :gloria nil)
               (:respond "Addúxi vos per desértum quadragínta annis ego Dóminus, et non sunt attríta vestiménta vestra:"
                  :verse "Ego addúxi vos de terra Ægýpti, et de domo servitútis liberávi vos."
                  :repeat "Manna de cælo plui vobis, et oblíti estis me, dicit Dóminus."
                  :gloria nil)
               (:respond "Móyses fámulus Dei jejunávit quadragínta diébus et quadragínta nóctibus:"
                  :verse "Ascéndens Móyses in montem Sínai ad Dóminum, fuit ibi quadragínta diébus et quadragínta nóctibus."
                  :repeat "Ut legem Dómini mererétur accípere."
                  :gloria t))))

    ;; Quad4-3: Feria Quarta infra Hebdomadam IV in Quadragesima
    ((4 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 44 in Joannem, circa initium"
               :text "In illo témpore: Prætériens Jesus, vidit hóminem cæcum a nativitáte: et interrogavérunt eum discípuli ejus: Rabbi, quis peccávit, hic, aut paréntes ejus, ut cæcus nascerétur? Et réliqua.
Homilía sancti Augustíni Epíscopi
Ea quæ fecit Dóminus noster Jesus Christus, stupénda atque miránda, et ópera, et verba sunt: ópera, quia facta sunt: verba, quia signa sunt. Si ergo quid signíficet hoc quod factum est, cogitémus: genus humánum est iste cæcus. Hæc enim cǽcitas cóntigit in primo hómine per peccátum, de quo omnes oríginem dúximus, non solum mortis, sed étiam iniquitátis. Si enim cǽcitas est infidélitas, et illuminátio fides: quem fidélem, quando venit Christus, invénit? Quandóquidem Apóstolus natus in gente prophetárum dicit: Fúimus et nos aliquándo natúra fílii iræ, sicut et céteri. Si fílii iræ, fílii vindíctæ, fílii pœnæ, fílii gehénnæ: quómodo natúra, nisi quia peccánte primo hómine vítium pro natúra inolévit? Si vítium pro natúra inolévit, secúndum mentem omnis homo cæcus natus est.")
               (:text "Venit Dóminus: quid fecit? Magnum mystérium commendávit. Exspuit in terram, de salíva sua lutum fecit: quia Verbum caro factum est, et inúnxit óculos cæci. Inúnctus erat, et nondum vidébat. Misit illum ad piscínam, quæ vocátur Síloë. Pertínuit autem ad Evangelístam commendáre nobis nomen hujus piscínæ, et ait: Quod interpretátur Missus. Jam quis sit missus agnóscitis. Nisi enim ille fuísset missus, nemo nostrum esset ab iniquitáte dimíssus. Lavit ergo óculos in ea piscína, quæ interpretátur Missus; baptizátus est in Christo. Si ergo quando eum in seípso quodámmodo baptizávit, tunc illuminávit: quando inúnxit, fortásse catechúmenum fecit.")
               (:text "Audístis grande mystérium. Intérroga hóminem: Christiánus es? Respóndet tibi: Non sum. Si pagánus es, aut Judǽus? Si autem díxerit, Non sum: adhuc quæris ab eo, Catechúmenus, an fidélis? Si respónderit tibi, Catechúmenus: inúnctus est, nondum lotus. Sed unde inúnctus? Quære, et respóndet. Quære ab illo, in quem credat? Eo ipso quo catechúmenus est, dicit: In Christum. Ecce modo loquor et fidélibus et catechúmenis. Quid dixi de sputo et luto? Quia Verbum caro factum est; hoc catechúmeni áudiunt: sed non eis súfficit ad quod inúncti sunt: festínent ad lavácrum, si lumen inquírunt."))
              :responsories
              ((:respond "Spléndida facta est fácies Móysi, dum respíceret in eum Dóminus:"
                  :verse "Cumque descendísset de monte Sínai, portábat duas tábulas testimónii, ignórans quod cornúta esset fácies ejus ex consórtio sermónis Dei."
                  :repeat "Vidéntes senióres claritátem vultus ejus, admirántes timuérunt valde."
                  :gloria nil)
               (:respond "Ecce mitto Angelum meum, qui præcédat te, et custódiat semper:"
                  :verse "Israël, si me audíeris, non erit in te deus recens, neque adorábis deum aliénum: ego enim Dóminus."
                  :repeat "Obsérva et audi vocem meam, et inimícus ero inimícis tuis, et affligéntes te afflígam: et præcédet te Angelus meus."
                  :gloria nil)
               (:respond "Atténdite, pópule meus, legem meam:"
                  :verse "Apériam in parábolis os meum: loquar propositiónes ab inítio sǽculi."
                  :repeat "Inclináte aurem vestram in verba oris mei."
                  :gloria t))))

    ;; Quad4-4: Feria Quinta infra Hebdomadam IV in Quadragesima
    ((4 . 4) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Lib. 5 Comment. in Lucæ cap. 7, post initium"
               :text "In illo témpore: Ibat Jesus in civitátem, quæ vocátur Naim: et ibant cum eo discípuli ejus, et turba copiósa. Et réliqua.
Homilía sancti Ambrósii Epíscopi
Et hic locus ad utrámque redúndat grátiam; et ut cito flecti divínam misericórdiam matris víduæ lamentatióne credámus, ejus præcípue, quæ únici fílii vel labóre, vel morte frangátur; cui tamen víduæ gravitátis méritum exsequiárum turba concíliet: et ut hanc víduam populórum turba septam, plus vidéri esse quam féminam, quæ resurrectiónem únici et adolescéntis fílii suis lácrimis merúerit impetráre: eo quod sancta Ecclésia pópulum juniórem a pompa fúneris atque a suprémis sepúlcri, suárum révocet ad vitam contemplatióne lacrimárum: quæ flere prohibétur eum, cui resurréctio debebátur.")
               (:text "Qui quidem mórtuus in lóculo materiálibus quátuor ad sepúlcrum ferebátur eleméntis, sed spem resurgéndi habébat, quia ferebátur in ligno. Quod etsi nobis ante non próderat, tamen posteáquam Jesus id tétigit, profícere cœpit ad vitam: ut esset indício, salútem pópulo per crucis patíbulum refundéndam. Audíto ígitur Dei verbo, stetérunt acérbi illi fúneris portitóres, qui corpus humánum letháli fluxu natúræ materiális urgébant. Quid enim áliud, nisi quasi in quodam féretro, hoc est, suprémi fúneris instruménto, jacémus exánimes, cum vel ignis immódicæ cupiditátis exǽstuat, vel frígidus humor exúndat, vel pigra quadam terréni córporis habitúdine vigor hebetátur animórum; vel concréta noster spíritus labe, puræ lucis vácuus mentem alit? Hi sunt nostri fúneris portitóres.")
               (:text "Sed quamvis supréma mortis spem vitæ omnis aboléverint, et túmulo próxima córpora jáceant defunctórum: verbo tamen Dei jam mórtua resúrgunt cadávera: vox redit, rédditur fílius matri, revocátur a túmulo, erípitur a sepúlcro. Quis iste est túmulus tuus, nisi mali mores? Túmulus tuus perfídia est: sepúlcrum tuum guttur est. Sepúlcrum enim patens, est guttur eórum, unde verba mórtua proferúntur. Ab hoc sepúlcro te líberat Christus: ab hoc túmulo surges, si áudias verbum Dei. Et si grave peccátum est, quod pœniténtiæ lácrimis ipse laváre non possis; fleat pro te mater Ecclésia, quæ pro síngulis tamquam pro únicis fíliis vídua mater intérvenit. Compátitur enim quodam spiritáli dolóre natúræ, cum suos líberos lethálibus vítiis ad mortem cernit urgéri."))
              :responsories
              ((:respond "Locútus est Dóminus ad Móysen, dicens: Descénde in Ægýptum, et dic Pharaóni:"
                  :verse "Clamor filiórum Israël venit ad me, vidíque afflictiónem eórum: sed veni, mittam te ad Pharaónem."
                  :repeat "Ut dimíttat pópulum meum: indurátum est cor Pharaónis: non vult dimíttere pópulum meum, nisi in manu forti."
                  :gloria nil)
               (:respond "Stetit Móyses coram Pharaóne, et dixit: Hæc dicit Dóminus:"
                  :verse "Dóminus Deus Hebræórum misit me ad te, dicens."
                  :repeat "Dimítte pópulum meum, ut sacríficet mihi in desérto."
                  :gloria nil)
               (:respond "Cantémus Dómino: glorióse enim honorificátus est, equum et ascensórem projécit in mare:"
                  :verse "Dóminus quasi vir pugnátor, Omnípotens nomen ejus."
                  :repeat "Adjútor et protéctor factus est mihi Dóminus in salútem."
                  :gloria t))))

    ;; Quad4-5: Feria Sexta infra Hebdomadam IV in Quadragesima
    ((4 . 5) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 49 in Joannem, post init."
               :text "In illo témpore: Erat quidam languens Lázarus a Bethánia, de castéllo Maríæ et Marthæ soróris ejus. Et réliqua.
Homilía sancti Augustíni Epíscopi
In superióri lectióne meminístis, quod Dóminus éxiit de mánibus eórum, qui lapidáre illum volúerant, et discéssit trans Jordánem, ubi Joánnes baptizábat. Ibi ergo Dómino constitúto, infirmabátur in Bethánia Lázarus: quod castéllum erat próximum Jerosólymis. María autem erat, quæ unxit Dóminum unguénto, et extérsit pedes ejus capíllis suis, cujus frater Lázarus infirmabátur. Misérunt ergo soróres ejus ad eum. Jam intellégimus quo misérunt, ubi erat Jesus: quóniam absens erat, trans Jordánem scílicet. Misérunt ad Dóminum, nuntiántes quod ægrotáret frater eárum, ut si dignarétur, veníret, et eum ab ægritúdine liberáret. Ille dístulit sanáre, ut posset resuscitáre.")
               (:text "Quid ergo nuntiavérunt soróres ejus? Dómine, ecce quem amas, infirmátur. Non dixérunt: Veni: amánti enim tantúmmodo nuntiándum fuit. Non ausæ sunt dícere: Veni, et sana. Non ausæ sunt dícere: Ibi jube, et hic fiet. Cur enim non et istæ, si fides illíus centuriónis inde laudátur? Ait enim: Non sum dignus ut intres sub tectum meum; sed tantum dic verbo, et sanábitur puer meus. Nihil horum istæ, sed tantúmmodo: Dómine, ecce quem amas, infirmátur. Súfficit ut nóveris: non enim amas, et déseris.")
               (:text "Dicit áliquis: Quómodo per Lázarum peccátor significabátur, et a Dómino sic amabátur? Audiat enim dicéntem: Non veni vocáre justos, sed peccatóres. Si enim peccatóres Deus non amáret, de cælo ad terram non descénderet. Audiens autem Jesus, dixit eis: Infírmitas hæc non est ad mortem, sed pro glória Dei, ut glorificétur Fílius Dei. Talis glorificátio ipsíus non ipsum auxit, sed nobis prófuit. Hoc est ergo quod ait: Non est ad mortem, sed pótius ad miráculum: quo facto créderent hómines in Christum, et vitárent veram mortem. Sane vidéte quemádmodum tamquam ex oblíquo Dóminus Deum se dixit: propter quosdam qui negant Fílium Dei Deum esse."))
              :responsories
              ((:respond "In mare viæ tuæ, et sémitæ tuæ in aquis multis:"
                  :verse "Transtulísti illos per mare Rubrum, et transvexísti eos per aquam nímiam."
                  :repeat "Deduxísti sicut oves pópulum tuum in manu Móysi et Aaron."
                  :gloria nil)
               (:respond "Qui persequebántur pópulum tuum, Dómine, demersísti eos in profúndum:"
                  :verse "Deduxísti sicut oves pópulum tuum in manu Móysi et Aaron."
                  :repeat "Et in colúmna nubis ductor eórum fuísti."
                  :gloria nil)
               (:respond "Móyses fámulus Dei jejunávit quadragínta diébus et quadragínta nóctibus:"
                  :verse "Ascéndens Móyses in montem Sínai ad Dóminum, fuit ibi quadragínta diébus et quadragínta nóctibus."
                  :repeat "Ut legem Dómini mererétur accípere."
                  :gloria t))))

    ;; Quad4-6: Sabbato infra Hebdomadam IV in Quadragesima
    ((4 . 6) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 34 in Joannem, post init."
               :text "In illo témpore: Locútus est Jesus turbis Judæórum, dicens: Ego sum lux mundi: qui séquitur me, non ámbulat in ténebris, sed habébit lumen vitæ. Et réliqua.
Homilía sancti Augustíni Epíscopi
Quod ait Dóminus: Ego sum lux mundi: clarum puto esse eis, qui habent óculos, unde hujus lucis partícipes fiant: qui autem non habent óculos, nisi in sola carne, mirántur quod dictum est a Dómino Jesu Christo: Ego sum lux mundi. Et forte non desit qui dicat apud semetípsum: Numquid forte Dóminus Christus est sol iste, qui ortu et occásu péragit diem? Non enim defuérunt hærétici, qui ista sensérunt. Manichǽi solem istum óculis cárneis visíbilem, expósitum et públicum non tantum homínibus, sed étiam pecóribus ad vidéndum, Christum Dóminum esse putavérunt.")
               (:text "Sed cathólicæ Ecclésiæ recta fides ímprobat tale comméntum, et diabólicam doctrínam esse cognóscit: nec solum agnóscit credéndo, sed in quibus potest convíncit étiam disputándo. Improbémus ítaque hujúsmodi errórem, quem sancta ab inítio anathematizávit Ecclésia. Non arbitrémur Dóminum Jesum Christum hunc esse solem, quem vidémus oríri ab Oriénte, occídere in Occidénte: cujus cúrsui nox succédit, cujus rádii nube obumbrántur: qui certa de loco in locum motióne cómmigrat. Non est hoc Dóminus Christus. Non est Dóminus Christus sol factus, sed per quem sol factus est. Omnia enim per ipsum facta sunt, et sine ipso factum est nihil.")
               (:text "Est ergo lux, quæ fecit hanc lucem. Hanc amémus, hanc intellégere cupiámus, ipsam sitíamus, ut ad ipsam duce ipsa aliquándo veniámus: et in illa ita vivámus, ut nunquam omníno moriámur. Ista enim lux est, de qua prophetía olim præmíssa ita in Psalmo cécinit: Quóniam apud te est fons vitæ, et in lúmine tuo vidébimus lumen. Advértite quid de tali luce antíquus sanctórum hóminum Dei sermo præmíserit. Hómines, inquit, et juménta salvos fácies, Dómine: sicut multiplicáta est misericórdia tua, Deus."))
              :responsories
              ((:respond "Spléndida facta est fácies Móysi, dum respíceret in eum Dóminus:"
                  :verse "Cumque descendísset de monte Sínai, portábat duas tábulas testimónii, ignórans quod cornúta esset fácies ejus ex consórtio sermónis Dei."
                  :repeat "Vidéntes senióres claritátem vultus ejus, admirántes timuérunt valde."
                  :gloria nil)
               (:respond "Ecce mitto Angelum meum, qui præcédat te, et custódiat semper:"
                  :verse "Israël, si me audíeris, non erit in te deus recens, neque adorábis deum aliénum: ego enim Dóminus."
                  :repeat "Obsérva et audi vocem meam, et inimícus ero inimícis tuis, et affligéntes te afflígam: et præcédet te Angelus meus."
                  :gloria nil)
               (:respond "Atténdite, pópule meus, legem meam:"
                  :verse "Apériam in parábolis os meum: loquar propositiónes ab inítio sǽculi."
                  :repeat "Inclináte aurem vestram in verba oris mei."
                  :gloria t))))

    ;; Quad5-1: Feria Secunda infra Hebdomadam Passionis
    ((5 . 1) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tract. 31 in Joannem, circa medium"
               :text "In illo témpore: Misérunt príncipes et pharisǽi minístros, ut apprehénderent Jesum. Et réliqua.
Homilía sancti Augustíni Epíscopi
Quómodo apprehénderent adhuc noléntem? Quia ergo non póterant apprehéndere noléntem, missi sunt, ut audírent docéntem. Quid docéntem? Dicit ergo Jesus: Adhuc módicum tempus vobíscum sum. Quod modo vultis fácere, factúri estis; sed non modo, quia modo nolo. Quare adhuc modo nolo? Quia adhuc módicum tempus vobíscum sum, et tunc vado ad eum qui me misit. Implére débeo dispensatiónem meam, et sic perveníre ad passiónem meam.")
               (:text "Quærétis me, et non inveniétis, et ubi sum ego, vos non potéstis veníre. Hic jam resurrectiónem suam prædíxit: noluérunt enim agnóscere præséntem, et póstea quæsiérunt, cum vidérent in eum multitúdinem jam credéntem. Magna enim signa facta sunt étiam cum Dóminus resurréxit, et ascéndit in cælum. Tunc per discípulos facta sunt magna: sed ille per illos, qui et per seípsum: ipse quippe illis díxerat: Sine me nihil potéstis fácere. Quando claudus ille, qui sedébat ad portam, ad vocem Petri surréxit, et suis pédibus ambulávit, ita ut hómines miraréntur, sic eos allocútus est Petrus, quia non in sua potestáte ista fecit, sed in virtúte illíus, quem ipsi occidérunt. Multi compúncti dixérunt: Quid faciémus?")
               (:text "Vidérunt enim se ingénti crímine impietátis adstríctos, quando illum occidérunt, quem venerári et adoráre debuérunt: et hoc putábant esse inexpiábile. Magnum enim fácinus erat, cujus considerátio illos fáceret desperáre: sed non debébant desperáre, pro quibus in cruce pendens Dóminus est dignátus oráre. Díxerat enim: Pater, ignósce illis, quia nésciunt quid fáciunt. Vidébat quosdam suos inter multos aliénos: illis jam petébat véniam, a quibus adhuc accipiébat injúriam. Non enim attendébat quod ab ipsis moriebátur, sed quia pro ipsis moriebátur."))
              :responsories
              ((:respond "Deus meus, éripe me de manu peccatóris: et de manu contra legem agéntis, et iníqui:"
                  :verse "Deus meus, ne elongéris a me: Deus meus, in auxílium meum réspice."
                  :repeat "Quóniam tu es patiéntia mea."
                  :gloria nil)
               (:respond "Qui custodiébant ánimam meam, consílium fecérunt in unum, dicéntes: Deus derelíquit eum,"
                  :verse "Omnes inimíci advérsum me cogitábant mala mihi: verbum iníquum mandavérunt advérsum me, dicéntes."
                  :repeat "Persequímini et comprehéndite eum: quia non est qui líberet eum: Deus meus, ne elongéris a me: Deus meus, in adjutórium meum inténde."
                  :gloria nil)
               (:respond "Pacífice loquebántur mihi inimíci mei, et in ira molésti erant mihi:"
                  :verse "Ego autem cum mihi molésti essent, induébam me cilício, et humiliábam in jejúnio ánimam meam."
                  :repeat "Vidísti, Dómine, ne síleas, ne discédas a me."
                  :gloria t))))

    ;; Quad5-2: Feria Tertia infra Hebdomadam Passionis
    ((5 . 2) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tractatus 28 in Joannem"
               :text "In illo témpore: Ambulábat Jesus in Galilǽam: non enim volébat in Judǽam ambuláre, quia quærébant eum Judǽi interfícere. Et réliqua.
Homilía sancti Augustíni Epíscopi
In isto Evangélii capítulo, fratres, Dóminus noster Jesus Christus secúndum hóminem se plúrimum commendávit fídei nostræ. Etenim semper hoc egit dictis et factis suis, ut Deus credátur et homo: Deus qui nos fecit, homo qui nos quæsívit: Deus cum Patre semper, homo nobíscum ex témpore. Non enim quǽreret quem fécerat, nisi fíeret ipse quod fécerat. Verum hoc mementóte, et de córdibus vestris nolíte dimíttere: sic esse Christum hóminem factum, ut non destíterit Deus esse. Manens Deus accépit hóminem, qui fecit hóminem.")
               (:text "Quando ergo látuit ut homo, non poténtiam perdidísse putándus est, sed exémplum infirmitáti præbuísse. Ille enim quando vóluit, deténtus est: quando vóluit, occísus est. Sed quóniam futúra erant membra ejus, id est, fidéles ejus, qui non habérent illam potestátem, quam habébat ipse Deus noster: quod latébat, quod se tamquam ne occiderétur, occultábat, hoc indicábat factúra esse membra sua, in quibus útique membris suis ipse erat.")
               (:text "Non enim Christus in cápite, et non in córpore: sed Christus totus in cápite, et in córpore. Quod ergo membra ejus, ipse: quod autem ipse, non contínuo membra ejus. Nam si non ipsi essent membra ejus, non díceret Saulo: Quid me perséqueris? Non enim Saulus ipsum, sed membra ejus, id est, fidéles ejus, in terra persequebátur. Nóluit tamen dícere sanctos meos, servos meos, postrémo honorabílius, fratres meos: sed me, hoc est membra mea, quibus ego sum caput."))
              :responsories
              ((:respond "Adjútor et suscéptor meus es tu, Dómine: et in verbum tuum sperávi:"
                  :verse "Iníquos ódio hábui: et legem tuam diléxi."
                  :repeat "Declináte a me, malígni: et scrutábor mandáta Dei mei."
                  :gloria nil)
               (:respond "Docébo iníquos vias tuas: et ímpii ad te converténtur:"
                  :verse "Dómine, lábia mea apéries: et os meum annuntiábit laudem tuam."
                  :repeat "Líbera me de sanguínibus, Deus, Deus salútis meæ."
                  :gloria nil)
               (:respond "Ne perdas cum ímpiis, Deus, ánimam meam, et cum viris sánguinum vitam meam:"
                  :verse "Eripe me, Dómine, ab hómine malo, a viro iníquo líbera me."
                  :repeat "Rédime me, Dómine."
                  :gloria t))))

    ;; Quad5-3: Feria Quarta infra Hebdomadam Passionis
    ((5 . 3) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tractatus 48 in Joannem, circa init."
               :text "In illo témpore: Facta sunt encǽnia in Jerosólymis: et hiems erat. Et ambulábat Jesus in templo, in pórticu Salomónis. Et réliqua.
Homilía sancti Augustíni Epíscopi
Encǽnia festívitas erat dedicatiónis templi. Græce enim cænon dícitur novum. Quandocúmque novum áliquid fúerit dedicátum, encǽnia vocántur. Jam et usus habet hoc verbum. Si quis nova túnica induátur, encæniáre dícitur. Illum enim diem, quo templum dedicátum est, Judǽi solémniter celebrábant: ipse dies festus agebátur, cum ea quæ lecta sunt, locútus est Dóminus.")
               (:text "Hiems erat, et ambulábat Jesus in templo, in pórticu Salomónis. Circumdedérunt ergo eum Judǽi, et dicébant ei: Quoúsque ánimam nostram tollis? Si tu es Christus, dic nobis palam. Non veritátem desiderábant, sed calúmniam præparábant. Hiems erat, et frígidi erant: ad illum enim divínum ignem accédere pigri erant. Si accédere est crédere: qui credit, accédit: qui negat, recédit. Non movétur ánima pédibus, sed afféctibus.")
               (:text "Frigúerant diligéndi caritáte, et ardébant nocéndi cupiditáte. Longe áberant, et ibi erant: non accedébant credéndo, et premébant persequéndo. Quærébant audíre a Dómino, Ego sum Christus: et fortásse de Christo secúndum hóminem sapiébant. Prædicavérunt enim prophétæ Christum: sed divinitátem Christi et in prophétis et in ipso Evangélio nec hærétici intéllegunt: quanto minus Judǽi, quámdiu velámen est super cor eórum?"))
              :responsories
              ((:respond "Tota die contristátus ingrediébar, Dómine: quóniam ánima mea compléta est illusiónibus:"
                  :verse "Amíci mei et próximi mei advérsum me appropinquavérunt et stetérunt: et qui juxta me erant, de longe stetérunt."
                  :repeat "Et vim faciébant, qui quærébant ánimam meam."
                  :gloria nil)
               (:respond "Ne avértas fáciem tuam a púero tuo, Dómine:"
                  :verse "Inténde ánimæ meæ, et líbera eam: propter inimícos meos éripe me."
                  :repeat "Quóniam tríbulor, velóciter exáudi me."
                  :gloria nil)
               (:respond "Quis dabit cápiti meo aquam, et óculis meis fontem lacrimárum, et plorábo die ac nocte? quia frater propínquus supplantávit me,"
                  :verse "Fiant viæ eórum ténebræ et lúbricum: et Angelus Dómini pérsequens eos."
                  :repeat "Et omnis amícus fraudulénter incéssit in me."
                  :gloria t))))

    ;; Quad5-4: Feria Quinta infra Hebdomadam Passionis
    ((5 . 4) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Lucam"
               :ref "Homilia 33 in Evangelia"
               :text "In illo témpore: Rogábat Jesum quidam de pharisǽis, ut manducáret cum illo. Et ingréssus domum pharisǽi discúbuit. Et réliqua.
Homilía sancti Gregórii Papæ
Cogitánti mihi de Maríæ Magdalénæ pœniténtia, flere magis libet, quam áliquid dícere. Cujus enim vel sáxeum pectus illæ hujus peccatrícis lácrimæ ad exémplum pœniténdi non emólliant? Considerávit namque quid fecit, et nóluit moderári quid fáceret. Super convivántes ingréssa est, non jussa venit, inter épulas lácrimas óbtulit. Díscite, quo dolóre ardet, quæ flere et inter épulas non erubéscit.")
               (:text "Hanc vero, quam Lucas peccatrícem mulíerem, Joánnes Maríam nóminat, illam esse Maríam crédimus, de qua Marcus septem dæmónia ejécta fuísse testátur. Et quid per septem dæmónia, nisi univérsa vítia designántur? Quia enim septem diébus omne tempus comprehénditur, recte septenário número univérsitas figurátur. Septem ergo dæmónia María hábuit, quæ univérsis vítiis plena fuit.")
               (:text "Sed ecce quia turpitúdinis suæ máculas aspéxit, lavánda ad fontem misericórdiæ cucúrrit, convivántes non erúbuit. Nam quia semetípsam gráviter erubescébat intus, nihil esse crédidit, quod verecundarétur foris. Quid ergo mirámur, fratres? Maríam veniéntem, an Dóminum suscipiéntem? Suscipiéntem dicam, an trahéntem? Sed mélius trahéntem dicam, et suscipiéntem: quia nimírum ipse eam per misericórdiam traxit intus, qui per mansuetúdinem suscépit foris."))
              :responsories
              ((:respond "Deus meus, éripe me de manu peccatóris: et de manu contra legem agéntis, et iníqui:"
                  :verse "Deus meus, ne elongéris a me: Deus meus, in auxílium meum réspice."
                  :repeat "Quóniam tu es patiéntia mea."
                  :gloria nil)
               (:respond "Multiplicáti sunt qui tríbulant me, et dicunt: Non est salus illi in Deo ejus:"
                  :verse "Nequándo dicat inimícus meus: Præválui advérsus eum."
                  :repeat "Exsúrge, Dómine, salvum me fac, Deus meus."
                  :gloria nil)
               (:respond "Usquequo exaltábitur inimícus meus super me?"
                  :verse "Qui tríbulant me, exsultábunt si motus fúero: ego autem in misericórdia tua sperábo."
                  :repeat "Réspice, et exáudi me, Dómine, Deus meus."
                  :gloria t))))

    ;; Quad5-5: Septem Dolorum Beatæ Mariæ Virginis
    ((5 . 5) . (:lessons
              ((:source "De Isaía Prophéta"
               :ref "Isa 53:1-5"
               :text "1 Quis crédidit audítui nostro? et bráchium Dómini cui revelátum est?
2 Et ascéndet sicut virgúltum coram eo, et sicut radix de terra sitiénti. Non est spécies ei, neque decor, et vídimus eum, et non erat aspéctus, et desiderávimus eum:
3 despéctum, et novíssimum virórum, virum dolórum, et sciéntem infirmitátem, et quasi abscónditus vultus ejus et despéctus, unde nec reputávimus eum.
4 Vere languóres nostros ipse tulit, et dolóres nostros ipse portávit; et nos putávimus eum quasi leprósum, et percússum a Deo, et humiliátum.
5 Ipse autem vulnerátus est propter iniquitátes nostras; attrítus est propter scélera nostra: disciplína pacis nostræ super eum, et livóre ejus sanáti sumus.")
               (:ref "Isa 53:6-9"
               :text "6 Omnes nos quasi oves errávimus, unusquísque in viam suam declinávit: et pósuit Dóminus in eo iniquitátem ómnium nostrum.
7 Oblátus est quia ipse vóluit, et non apéruit os suum; sicut ovis ad occisiónem ducétur, et quasi agnus coram tondénte se obmutéscet, et non apériet os suum.
8 De angústia, et de judício sublátus est. Generatiónem ejus quis enarrábit? quia abscíssus est de terra vivéntium: propter scelus pópuli mei percússi eum.
9 Et dabit ímpios pro sepultúra, et dívitem pro morte sua, eo quod iniquitátem non fécerit, neque dolus fúerit in ore ejus.")
               (:ref "Isa 53:10-12"
               :text "10 Et Dóminus vóluit contérere eum in infirmitáte. Si posúerit pro peccáto ánimam suam, vidébit semen longǽvum, et volúntas Dómini in manu ejus dirigétur.
11 Pro eo quod laborávit ánima ejus, vidébit et saturábitur. In sciéntia sua justificábit ipse justus servus meus multos, et iniquitátes eórum ipse portábit.
12 Ideo dispértiam ei plúrimos, et fórtium dívidet spólia, pro eo quod trádidit in mortem ánimam suam, et cum scelerátis reputátus est, et ipse peccáta multórum tulit, et pro transgressóribus rogávit."))
              :responsories
              ((:respond "Diléctus meus cándidus, et rubicúndus, et totus desiderábilis:"
                  :verse "Piis, o Virgo, spectas eum óculis, contémplans in eo non tam vúlnerum livórem, quam mundi salútem."
                  :repeat "Omnis enim figúra ejus amórem spirat, et ad redamándum próvocat caput inclinátum, manus expánsæ, pectus apértum."
                  :gloria nil)
               (:respond "Manus ejus tornátiles, clavórum cúspide terebrátæ,"
                  :verse "Córnua in mánibus ejus: ibi abscóndita est fortitúdo ejus: sunt enim manus ejus."
                  :repeat "Humánæ salútis prétio quasi hyacínthis refértæ."
                  :gloria nil)
               (:respond "Diligébat Jesus Joánnem, quóniam speciális prærogatíva castitátis amplióri dilectióne fécerat dignum:"
                  :verse "In cruce dénique moritúrus huic Matrem suam vírginem vírgini commendávit."
                  :repeat "Quia virgo eléctus ab ipso, virgo in ævum permánsit."
                  :gloria t))))

    ;; Quad5-6: Sabbato infra Hebdomadam Passionis
    ((5 . 6) . (:lessons
              ((:source "Léctio sancti Evangélii secúndum Joánnem"
               :ref "Tractatus 50 in Joannem, in fine"
               :text "In illo témpore: Cogitavérunt príncipes sacerdótum ut et Lázarum interfícerent: quia multi propter illum abíbant ex Judǽis, et credébant in Jesum. Et réliqua.
Homilía sancti Augustíni Epíscopi
Viso Lázaro resuscitáto, quia tantum miráculum Dómini tanta erat evidéntia diffamátum, tanta manifestatióne declarátum, ut non possent vel occultáre quod factum est, vel negáre: quid invenérunt, vidéte. Cogitavérunt autem príncipes sacerdótum ut et Lázarum interfícerent. O stulta cogitátio, et cæca sævítia! Dóminus Christus, qui suscitáre pótuit mórtuum, non posset occísum! Quando Lázaro inferebátis necem, numquid auferebátis Dómino potestátem? Si áliud vobis vidétur mórtuus, áliud occísus: ecce Dóminus utrúmque fecit, et Lázarum mórtuum, et seípsum suscitávit occísum.")
               (:text "In crástinum autem turba multa, quæ vénerat ad diem festum, cum audíssent quia venit Jesus Jerosólymam: accepérunt ramos palmárum, et processérunt óbviam ei, et clamábant: Hosánna, benedíctus qui venit in nómine Dómini, Rex Israël. Rami palmárum laudes sunt, significántes victóriam: quia erat Dóminus mortem moriéndo superatúrus, et trophǽo crucis de diábolo mortis príncipe triumphatúrus. Vox autem obsecrántis est Hosánna, sicut nonnúlli dicunt, qui Hebrǽam linguam novérunt, magis afféctum índicans, quam rem áliquam signíficans, sicut sunt in lingua Latína, quas interjectiónes vocant: velut cum doléntes dícimus, heu; vel cum delectámur, vah dícimus.")
               (:text "Has ei laudes turba dicébat: Hosánna, benedíctus, qui venit in nómine Dómini, Rex Israël. Quam crucem mentis invidéntia príncipum Judæórum pérpeti potúerat, quando Regem suum Christum tanta multitúdo clamábat? Sed quid fuit Dómino Regem esse Israël? Quid magnum fuit Regi sæculórum, Regem fíeri hóminum? Non enim Rex Israël Christus ad exigéndum tribútum, vel exércitum ferro armándum, hostésque visibíliter debellándos: sed Rex Israël, quod mentes regat, quod in ætérnum cónsulat, quod in regnum cælórum credéntes, sperántes, amantésque perdúcat."))
              :responsories
              ((:respond "Tota die contristátus ingrediébar, Dómine: quóniam ánima mea compléta est illusiónibus:"
                  :verse "Amíci mei et próximi mei advérsum me appropinquavérunt et stetérunt: et qui juxta me erant, de longe stetérunt."
                  :repeat "Et vim faciébant, qui quærébant ánimam meam."
                  :gloria nil)
               (:respond "Ne avértas fáciem tuam a púero tuo, Dómine:"
                  :verse "Inténde ánimæ meæ, et líbera eam: propter inimícos meos éripe me."
                  :repeat "Quóniam tríbulor, velóciter exáudi me."
                  :gloria nil)
               (:respond "Quis dabit cápiti meo aquam, et óculis meis fontem lacrimárum, et plorábo die ac nocte? quia frater propínquus supplantávit me,"
                  :verse "Fiant viæ eórum ténebræ et lúbricum: et Angelus Dómini pérsequens eos."
                  :repeat "Et omnis amícus fraudulénter incéssit in me."
                  :gloria t))))
    )
  "Ferial Matins data for Lent and Passiontide weekdays.
Each entry is ((WEEK . DOW) . (:lessons (L1 L2 L3) :responsories (R1 R2 R3))).
WEEK 0 = Ash Wednesday week (DOW 3-6), weeks 1-4 = Lent proper,
week 5 = Passion week.  Holy Week excluded.")

(defun bcp-roman-season-lent--ferial-week-dow (date)
  "Return (WEEK . DOW) for DATE within Lent/Passiontide feriae, or nil.
WEEK is 0 (Ash Wed week), 1-4 (Lent), or 5 (Passion week).
DOW is 1=Mon..6=Sat.  Returns nil on Sundays and outside Lent/Passiontide.
Holy Week Mon-Wed are excluded (handled by holyweek module)."
  (let* ((year (caddr date))
         (feasts (bcp-moveable-feasts year))
         (easter (cdr (assq 'easter feasts)))
         (easter-abs (calendar-absolute-from-gregorian easter))
         (ash-abs (- easter-abs 46))
         (date-abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date))
         (diff (- date-abs ash-abs)))
    ;; Skip Sundays
    (when (and (> dow 0) (>= diff 0))
      (cond
       ;; Week 0: Ash Wed (diff=0, Wed) through Sat (diff=3)
       ((< diff 4)
        (cons 0 dow))
       ;; Weeks 1-5: Lent 1 Mon through Passion Sat
       ;; Lent 1 Sunday = diff 4; Mon = diff 5
       (t
        (let* ((days-from-lent1 (- diff 4))
               (week (1+ (/ days-from-lent1 7))))
          (when (<= week 5)
            (cons week dow))))))))

(defun bcp-roman-season-lent-ferial-matins (date)
  "Return ferial Matins data for DATE if it is a Lent/Passiontide weekday.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories,
or nil if DATE is a Sunday, outside Lent, or in Holy Week."
  (let ((key (bcp-roman-season-lent--ferial-week-dow date)))
    (when key
      (cdr (assoc key bcp-roman-season-lent--ferial-matins)))))


(provide 'bcp-roman-season-lent)

;;; bcp-roman-season-lent.el ends here
