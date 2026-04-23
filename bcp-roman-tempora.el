;;; bcp-roman-tempora.el --- Proper of the Time for the Roman Breviary -*- lexical-binding: t -*-

;;; Commentary:

;; Proper of the Time (Proprium de Tempore) data for the ferial Roman
;; Breviary (DA 1911 rubrics).  Initially covers Per Annum only: the
;; 24 Sunday collects of the post-Pentecost season (Pent01–Pent24).
;;
;; Collect texts sourced from Divinum Officium DA Latin and English
;; Tempora files.  Conclusion formulae appended from `bcp-common-roman'.
;;
;; Key public function:
;;   `bcp-roman-tempora-collect' — return the collect incipit symbol for
;;     the preceding Sunday of a given date.

;;; Code:

(require 'bcp-common-roman)
(require 'bcp-roman-collectarium)
(require 'bcp-calendar)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Per Annum Sunday collects (Pent01–Pent24)
;;
;; All 24 use $Per Dominum.  Registered in the collectarium under
;; incipit symbols like `omnipotens-sempiterne-deus-qui-dedisti' (Pent01).
;;
;; Pent01 = Trinity Sunday = Easter + 56
;; Pent02 = Easter + 63, ... PentNN = Easter + 56 + (N-1)*7

;;; ─── Pent01 — Trinity Sunday ─────────────────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-dedisti
 (list :latin (concat
              "Omnípotens sempitérne Deus, qui dedísti fámulis tuis in \
confessióne veræ fídei, ætérnæ Trinitátis glóriam agnóscere, et in \
poténtia majestátis adoráre Unitátem: quǽsumus; ut, ejúsdem fídei \
firmitáte, ab ómnibus semper muniámur advérsis.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty and everlasting God, you have given thy servants in \
the confession of the true faith, to acknowledge the glory of the Eternal \
Trinity, and to adore the unity in the power of thy Majesty; grant, that by \
steadfastness in this faith we may ever be defended from all adversities.\n\
Through our Lord."))))

;;; ─── Pent02 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'sancti-nominis-tui
 (list :latin (concat
              "Sancti nóminis tui, Dómine, timórem páriter et amórem fac \
nos habére perpétuum: quia nunquam tua gubernatióne destítuis, quos in \
soliditáte tuæ dilectiónis instítuis.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, Who never failest to help and govern them whom Thou \
dost bring up in thy steadfast fear and love keep us, we beseech thee, under \
the protection of thy good providence, and make us to have a perpetual fear \
and love of thy Holy Name.\nThrough our Lord."))))

;;; ─── Pent03 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'protector-in-te-sperantium
 (list :latin (concat
              "Protéctor in te sperántium, Deus, sine quo nihil est válidum, \
nihil sanctum; multíplica super nos misericórdiam tuam; ut, te rectóre, te \
duce, sic transeámus per bona temporália, ut non amittámus ætérna.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, the protector of all them that trust in thee, without \
whom nothing is strong, nothing is holy; increase and multiply upon us thy \
mercy, that thou being our ruler and guide, we may so pass through things \
temporal, that we finally lose not the things eternal.\nThrough our Lord."))))

;;; ─── Pent04 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'da-nobis-quaesumus-domine-ut-et-mundi
 (list :latin (concat
              "Da nobis, quǽsumus, Dómine: ut et mundi cursus pacífice \
nobis tuo órdine dirigátur; et Ecclésia tua tranquílla devotióne lætétur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, O Lord, we beseech thee, that the course of this world \
may be so peaceably ordered by thy governance, that thy Church may joyfully \
serve thee in all godly quietness.\nThrough our Lord."))))

;;; ─── Pent05 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-diligentibus-te
 (list :latin (concat
              "Deus, qui diligéntibus te bona invisibília præparásti: \
infúnde córdibus nostris tui amóris afféctum; ut te in ómnibus et super \
ómnia diligéntes, promissiónes tuas, quæ omne desidérium súperant, \
consequámur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who hast prepared for them that love thee such good \
things as pass man's understanding; pour into our hearts such love toward \
thee, that we, loving thee in all things and above all things, may obtain thy \
promises, which exceed all that we can desire.\nThrough our Lord."))))

;;; ─── Pent06 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-virtutum-cujus-est-totum
 (list :latin (concat
              "Deus virtútum, cujus est totum quod est óptimum: ínsere \
pectóribus nostris amórem tui nóminis, et præsta in nobis religiónis \
augméntum; ut, quæ sunt bona, nútrias, ac pietátis stúdio, quæ sunt \
nutríta, custódias.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Lord of all power and might, Who art the Author and Giver of \
all good things, graft in our hearts the love of thy Name, increase in us true \
religion, nourish us with all goodness, and, of thy great mercy, keep us in \
the same.\nThrough our Lord."))))

;;; ─── Pent07 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-cujus-providentia
 (list :latin (concat
              "Deus, cujus providéntia in sui dispositióne non fállitur: te \
súpplices exorámus; ut nóxia cuncta submóveas, et ómnia nobis profutúra \
concédas.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Whose never-failing Providence ordereth all things both \
in heaven and earth, we humbly beseech thee to put away from us all hurtful \
things, and to give us those things which be profitable for us.\n\
Through our Lord."))))

;;; ─── Pent08 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'largire-nobis-quaesumus-domine-semper
 (list :latin (concat
              "Largíre nobis, quǽsumus, Dómine, semper spíritum cogitándi \
quæ recta sunt, propítius et agéndi: ut, qui sine te esse non póssumus, \
secúndum te vívere valeámus.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Grant to us, Lord, we beseech thee, the spirit to think and do \
always such things as be rightful, that we, who cannot do anything that is good \
without thee, may by thee be enabled to live according to thy will.\n\
Through our Lord."))))

;;; ─── Pent09 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'pateant-aures-misericordiae
 (list :latin (concat
              "Páteant aures misericórdiæ tuæ, Dómine, précibus supplicántium: \
et, ut peténtibus desideráta concédas; fac eos, quæ tibi sunt plácita, \
postuláre.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Let thy merciful ears, O Lord, be open to the prayers of thy \
humble servants; and, that they may obtain their petitions, make them to ask \
such things as shall please thee.\nThrough our Lord."))))

;;; ─── Pent10 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-qui-omnipotentiam-tuam
 (list :latin (concat
              "Deus, qui omnipoténtiam tuam parcéndo máxime et miserándo \
maniféstas: multíplica super nos misericórdiam tuam; ut, ad tua promíssa \
curréntes, cæléstium bonórum fácias esse consórtes.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, Who declarest thine Almighty power most chiefly in \
showing mercy and pity, mercifully grant unto us such a measure of thy grace, \
that we, running the way of thy commandments, may obtain thy gracious promises, \
and be made partakers of thy heavenly treasure.\nThrough our Lord."))))

;;; ─── Pent11 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-qui-abundantia
 (list :latin (concat
              "Omnípotens sempitérne Deus, qui, abundántia pietátis tuæ, et \
mérita súpplicum excédis et vota: effúnde super nos misericórdiam tuam; \
ut dimíttas quæ consciéntia métuit, et adícias quod orátio non præsúmit.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty and everlasting God, Who art always more ready to hear \
than we to pray, and art wont to give more than either we desire or deserve, \
pour down upon us the abundance of thy mercy, forgiving us those things whereof \
our conscience is afraid, and giving us those good things which we are not \
worthy to ask.\nThrough our Lord."))))

;;; ─── Pent12 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-et-misericors-deus-de-cujus
 (list :latin (concat
              "Omnípotens et miséricors Deus, de cujus múnere venit, ut tibi \
a fidélibus tuis digne et laudabíliter serviátur: tríbue, quǽsumus, nobis; \
ut ad promissiónes tuas sine offensióne currámus.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty and merciful God, of Whose only gift it cometh that \
thy faithful people do unto thee true and laudable service, grant, we beseech \
thee, that we may so faithfully serve thee in this life, that we fail not \
finally to attain thy heavenly promises.\nThrough our Lord."))))

;;; ─── Pent13 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-sempiterne-deus-da-nobis-fidei
 (list :latin (concat
              "Omnípotens sempitérne Deus, da nobis fídei, spei et caritátis \
augméntum: et, ut mereámur ássequi quod promíttis, fac nos amáre quod \
prǽcipis.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Almighty and everlasting God, give unto us the increase of \
faith, hope, and charity, and that we may worthily obtain that which Thou dost \
promise, make us to love that which Thou dost command.\nThrough our Lord."))))

;;; ─── Pent14 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'custodi-domine-quaesumus-ecclesiam
 (list :latin (concat
              "Custódi, Dómine, quǽsumus, Ecclésiam tuam propitiatióne \
perpétua: et quia sine te lábitur humána mortálitas; tuis semper auxíliis \
et abstrahátur a nóxiis et ad salutária dirigátur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Keep, we beseech thee, O Lord, thy Church with thy perpetual \
mercy, and because the frailty of man without thee cannot but fall, keep us \
ever by thy help from all things hurtful, and lead us to all things profitable \
to our salvation.\nThrough our Lord."))))

;;; ─── Pent15 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'ecclesiam-tuam-domine-miseratio
 (list :latin (concat
              "Ecclésiam tuam, Dómine, miserátio continuáta mundet et \
múniat: et quia sine te non potest salva consístere; tuo semper múnere \
gubernétur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we beseech thee, let thy continual pity cleanse and \
defend thy Church, and because it cannot continue in safety without thy \
succour, preserve it evermore by thy help and goodness.\nThrough our Lord."))))

;;; ─── Pent16 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'tua-nos-quaesumus-domine-gratia
 (list :latin (concat
              "Tua nos, quǽsumus, Dómine, grátia semper et prævéniat et \
sequátur: ac bonis opéribus júgiter præstet esse inténtos.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Lord, we pray thee, that thy grace may always prevent and \
follow us, and make us continually to be given to all good works.\n\
Through our Lord."))))

;;; ─── Pent17 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'da-quaesumus-domine-populo-tuo
 (list :latin (concat
              "Da, quǽsumus, Dómine, pópulo tuo diabólica vitáre contágia: \
et te solum Deum pura mente sectári.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we beseech thee, grant thy people grace to withstand \
the temptations of the devil, and with pure hearts to follow thee the only \
God.\nThrough our Lord."))))

;;; ─── Pent18 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'dirigat-corda-nostra
 (list :latin (concat
              "Dírigat corda nostra, quǽsumus, Dómine, tuæ miseratiónis \
operátio: quia tibi sine te placére non póssumus.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Mercifully grant, O Lord, that thine effectual goodness may in \
all things direct our hearts, forasmuch as without thee we are not able to \
please thee.\nThrough our Lord."))))

;;; ─── Pent19 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'omnipotens-et-misericors-deus-universa
 (list :latin (concat
              "Omnípotens et miséricors Deus, univérsa nobis adversántia \
propitiátus exclúde: ut mente et córpore páriter expedíti, quæ tua sunt, \
líberis méntibus exsequámur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O Almighty and most merciful God, of thy bountiful goodness \
keep us, we beseech thee, from all things that may hurt us; that we, being \
ready both in body and soul, may cheerfully accomplish those things that Thou \
wouldest have done.\nThrough our Lord."))))

;;; ─── Pent20 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'largire-quaesumus-domine-fidelibus
 (list :latin (concat
              "Largíre, quǽsumus, Dómine, fidélibus tuis indulgéntiam \
placátus et pacem: ut páriter ab ómnibus mundéntur offénsis, et secúra \
tibi mente desérviant.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Grant, we beseech thee, O Lord, to thy faithful people pardon \
and peace, that they may be cleansed from all their sins, and serve thee with \
a quiet mind.\nThrough our Lord."))))

;;; ─── Pent21 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'familiam-tuam-quaesumus-domine
 (list :latin (concat
              "Famíliam tuam, quǽsumus, Dómine, contínua pietáte custódi: \
ut a cunctis adversitátibus te protegénte, sit líbera; et in bonis áctibus \
tuo nómini sit devóta.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we beseech thee to keep thine household in continual \
godliness, that, through thy protection, it may be free from all adversities, \
and devoutly given to serve thee in good works, to the glory of thy Name.\n\
Through our Lord."))))

;;; ─── Pent22 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'deus-refugium-nostrum-et-virtus
 (list :latin (concat
              "Deus, refúgium nostrum et virtus: adésto piis Ecclésiæ tuæ \
précibus, auctor ipse pietátis, et præsta; ut, quod fidéliter pétimus, \
efficáciter consequámur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O God, our Refuge and Strength, Who art the author of all \
godliness, be ready, we beseech thee, to hear the devout prayers of thy \
Church, and grant that those things which we ask faithfully, we may obtain \
effectually.\nThrough our Lord."))))

;;; ─── Pent23 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'absolve-quaesumus-domine-tuorum
 (list :latin (concat
              "Absólve, quǽsumus, Dómine, tuórum delícta populórum: ut a \
peccatórum néxibus, quæ pro nostra fragilitáte contráximus, tua benignitáte \
liberémur.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "O Lord, we beseech thee, absolve thy people from their \
offences, that through thy bountiful goodness we may all be delivered from \
the bands of those sins, which by our frailty we have committed.\n\
Through our Lord."))))

;;; ─── Pent24 ──────────────────────────────────────────────────────────────

(bcp-roman-collectarium-register
 'excita-quaesumus-domine-tuorum-fidelium
 (list :latin (concat
              "Excita, quǽsumus, Dómine, tuórum fidélium voluntátes: ut, \
divíni óperis fructum propénsius exsequéntes; pietátis tuæ remédia \
majóra percípiant.\n"
              bcp-roman-per-dominum)
       :conclusion 'per-dominum
       :translations
       '((do . "Stir up, we beseech thee, Lord, the wills of thy faithful \
people, that they, plenteously bringing forth the fruit of good works, may of \
thee be plenteously rewarded.\nThrough our Lord."))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Sunday-to-collect mapping

(defconst bcp-roman-tempora--pent-collects
  [nil ; slot 0 unused (1-indexed)
   omnipotens-sempiterne-deus-qui-dedisti   ; Pent01 — Trinity
   sancti-nominis-tui                        ; Pent02
   protector-in-te-sperantium                ; Pent03
   da-nobis-quaesumus-domine-ut-et-mundi    ; Pent04
   deus-qui-diligentibus-te                  ; Pent05
   deus-virtutum-cujus-est-totum             ; Pent06
   deus-cujus-providentia                    ; Pent07
   largire-nobis-quaesumus-domine-semper     ; Pent08
   pateant-aures-misericordiae               ; Pent09
   deus-qui-omnipotentiam-tuam               ; Pent10
   omnipotens-sempiterne-deus-qui-abundantia ; Pent11
   omnipotens-et-misericors-deus-de-cujus    ; Pent12
   omnipotens-sempiterne-deus-da-nobis-fidei ; Pent13
   custodi-domine-quaesumus-ecclesiam        ; Pent14
   ecclesiam-tuam-domine-miseratio           ; Pent15
   tua-nos-quaesumus-domine-gratia           ; Pent16
   da-quaesumus-domine-populo-tuo            ; Pent17
   dirigat-corda-nostra                      ; Pent18
   omnipotens-et-misericors-deus-universa    ; Pent19
   largire-quaesumus-domine-fidelibus        ; Pent20
   familiam-tuam-quaesumus-domine            ; Pent21
   deus-refugium-nostrum-et-virtus           ; Pent22
   absolve-quaesumus-domine-tuorum           ; Pent23
   excita-quaesumus-domine-tuorum-fidelium]  ; Pent24
  "Per Annum Sunday collect incipits, 1-indexed by Pent number.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Preceding-Sunday computation

(defun bcp-roman-tempora--pent-number (date)
  "Return the Pent number (1–24) for the Sunday preceding or on DATE.
DATE is (MONTH DAY YEAR).  Returns nil if DATE is outside the
Per Annum season (before Trinity Sunday or after Pent24 Saturday)."
  (let* ((year (caddr date))
         (feasts (bcp-moveable-feasts year))
         ;; Trinity Sunday = Pent01 = Easter + 56
         (trinity (cdr (assq 'trinity-sunday feasts)))
         (trinity-abs (calendar-absolute-from-gregorian trinity))
         ;; Find the preceding (or current) Sunday
         (date-abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date))
         (sunday-abs (- date-abs dow))
         ;; Weeks after Trinity
         (weeks (/ (- sunday-abs trinity-abs) 7)))
    (when (and (>= weeks 0) (<= weeks 23))
      (1+ weeks))))

(defun bcp-roman-tempora-collect (date)
  "Return the collect incipit symbol for the preceding Sunday of DATE.
DATE is (MONTH DAY YEAR).  Returns nil outside Per Annum."
  (let ((n (bcp-roman-tempora--pent-number date)))
    (when (and n (<= n (1- (length bcp-roman-tempora--pent-collects))))
      (aref bcp-roman-tempora--pent-collects n))))


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Dominical Matins lessons and responsories (Pent01–Pent24)
;;
;; 24 Sunday datasets extracted from Divinum Officium Tempora files.
;; Each entry: (WEEK . (:lessons (L1..L9) :responsories (R1..R8))).
;; Nocturn I lessons (1-3): scripture with :ref, fetched via bcp-fetcher in English.
;; Nocturn II lessons (4-6): patristic, embedded Latin.
;; Nocturn III lessons (7-9): homily, :ref + :gospel-incipit + :source + :text.
;; Responsories: nil where sourced from weekday files (not yet extracted).

(defconst bcp-roman-tempora--dominical-matins
  '(
    (1
     . (:lessons
        (
         (:ref "Isa 6:1-4"
             :text "1 In anno, quo mórtuus est rex Ozías, vidi Dóminum sedéntem super sólium excélsum et elevátum: et ea, quæ sub ipso erant, replébant templum.
2 Séraphim stabant super illud: sex alæ uni, et sex alæ álteri, duábus velábant fáciem ejus, et duábus velábant pedes ejus, et duábus volábant.
3 Et clamábant alter ad álterum, et dicébant: Sanctus, sanctus, sanctus, Dóminus exercítuum, plena est omnis terra glória ejus.
4 Et commóta sunt superliminária cárdinum a voce clamántis, et domus repléta est fumo.")  ; Lesson 1
         (:ref "Isa 6:5-8"
             :text "5 Et dixi: Væ mihi, quia tácui, quia vir pollútus lábiis ego sum, et in médio pópuli pollúta lábia habéntis ego hábito, et Regem Dóminum exercítuum vidi óculis meis.
6 Et volávit ad me unus de Séraphim, et in manu ejus cálculus, quem fórcipe túlerat de altári.
7 Et tétigit os meum, et dixit: Ecce tétigit hoc lábia tua, et auferétur iníquitas tua, et peccátum tuum mundábitur.
8 Et audívi vocem Dómini dicéntis: Quem mittam? et quis ibit nobis? Et dixi: Ecce ego, mitte me.")  ; Lesson 2
         (:ref "Isa 6:9-12"
             :text "9 Et dixit: Vade, et dices pópulo huic: Audíte audiéntes, et nolíte intellégere: et vidéte visiónem, et nolíte cognóscere.
10 Excǽca cor pópuli hujus, et aures ejus ággrava, et óculos ejus claude, ne forte vídeat óculis suis, et áuribus suis áudiat, et corde suo intéllegat, et convertátur, et sanem eum.
11 Et dixi: Usquequo, Dómine? Et dixit: Donec desoléntur civitátes absque habitatóre, et domus sine hómine, et terra relinquétur desérta,
12 et longe fáciet Dóminus hómines, et multiplicábitur quæ derelícta fúerat in médio terræ.")  ; Lesson 3
         (:source "Ex libro sancti Fulgéntii Epíscopi, de fide ad Petrum
Inter Opera Augustini, tom. 3"
             :text "Fides, quam sancti Patriárchæ atque Prophétæ ante incarnatiónem Fílii Dei divínitus accepérunt, quam étiam sancti Apóstoli ab ipso Dómino in carne pósito audiérunt, et Spíritus Sancti magistério instrúcti non solum sermóne prædicavérunt, verum étiam ad instructiónem salubérrimam posterórum scriptis suis índitam reliquérunt; unum Deum prǽdicat Trinitátem, id est, Patrem, et Fílium, et Spíritum Sanctum. Sed Trínitas vera non esset, si una eadémque persóna dicerétur Pater et Fílius et Spíritus Sanctus.")  ; Lesson 4
         (:text "Si enim, sicut est Patris, et Fílii, et Spíritus Sancti una substántia, sic esset una persóna; nihil omníno esset in quo veráciter Trínitas dicerétur. Rursus quidem Trínitas esset vera, sed unus Deus Trínitas ipsa non esset, si quemádmodum Pater, et Fílius, et Spíritus Sanctus personárum sunt ab ínvicem proprietáte distíncti, sic fuíssent naturárum quoque diversitáte discréti. Sed quia in illo uno vero Deo Trinitáte, non solum quod unus Deus est, sed étiam quod Trínitas est, naturáliter verum est; proptérea ipse verus Deus in persónis Trínitas est, et in una natúra unus est.")  ; Lesson 5
         (:text "Per hanc unitátem naturálem totus Pater in Fílio et Spíritu Sancto est, totus Fílius in Patre et Spíritu Sancto est, totus quoque Spíritus Sanctus in Patre et Fílio. Nullus horum extra quémlibet ipsórum est: quia nemo álium aut præcédit æternitáte, aut excédit magnitúdine, aut súperat potestáte: quia nec Fílio nec Spíritu Sancto, quantum ad natúræ divínæ unitátem pértinet, aut antérior aut major Pater est; nec Fílii ætérnitas atque imménsitas, velut antérior aut major, Spíritus Sancti immensitátem æternitatémque aut præcédere aut excédere naturáliter potest.")  ; Lesson 6
         (:ref "Matt 28:18-20"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis: Data est mihi omnis potéstas in cælo et in terra. Eúntes ergo docéte omnes gentes, baptizántes eos in nómine Patris, et Fílii, et Spíritus Sancti. Et réliqua."
             :source "Homilía sancti Gregórii Nazianzéni
In Tractatu de fide, post init."
             :text "Quis catholicórum ignórat Patrem vere esse Patrem, Fílium vere esse Fílium, et Spíritum Sanctum vere esse Spíritum Sanctum? sicut ipse Dóminus ad Apóstolos suos dicit: Eúntes baptizáte omnes gentes in nómine Patris, et Fílii, et Spíritus Sancti. Hæc est perfécta Trínitas in unitáte consístens, quam scílicet uníus substántiæ profitémur. Non enim nos secúndum córporum conditiónem, divisiónem in Deo fácimus; sed secúndum divínæ natúræ poténtiam, quæ in matéria non est, et nóminum persónas vere constáre crédimus, et unitátem divinitátis esse testámur.")  ; Lesson 7
         (:text "Nec extensiónem partis alicújus ex parte, ut quidam putavérunt, Dei Fílium dícimus: nec verbum sine re, velut sonum vocis, accípimus: sed tria nómina et tres persónas uníus esse esséntiæ, uníus majestátis atque poténtiæ crédimus. Et ídeo unum Deum confitémur: quia únitas majestátis, plúrium vocábulo deos próhibet appellári. Dénique Patrem et Fílium cathólice nominámus; duos autem Deos dícere, nec póssumus, nec debémus. Non quod Fílius Dei Deus non sit, immo verus Deus de Deo vero; sed quia non aliúnde, quam de ipso uno Patre, Dei Fílium nóvimus, perínde unum Deum dícimus. Hoc enim Prophétæ, hoc Apóstoli tradidérunt: hoc ipse Dóminus dócuit, cum dicit: Ego et Pater unum sumus. Unum ad unitátem divinitátis, ut dixi, refert; Sumus autem, persónis assígnat.")  ; Lesson 8
         (:ref "Luc 6:36-42"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis: Estóte misericórdes, sicut et Pater vester miséricors est. Et réliqua."
             :source "Homilía sancti Augustíni Epíscopi
Serm. 15. in Evang. Matthǽi de Verbis Dómini, post inítium"
             :text "Duo sunt ópera misericórdiæ, quæ nos líberant, quæ bréviter ipse Dóminus pósuit in Evangélio: Dimíttite, et dimittétur vobis: date, et dábitur vobis. Dimíttite, et dimittétur vobis, ad ignoscéndum pértinet: Date, et dábitur vobis, ad præstándum benefícium pértinet. Quod ait de ignoscéndo, et tu vis tibi ignósci quod peccas, et habes álium, cui tu possis ignóscere. Rursus, quod pértinet ad tribuéndum benefícium, petit te mendícus, et tu es Dei mendícus. Omnes enim quando orámus, mendíci Dei sumus: ante jánuam magni Patrisfamílias stamus, immo et prostérnimur, súpplices ingemíscimus, áliquid voléntes accípere; et ipsum áliquid ipse Deus est. Quid a te petit mendícus? Panem. Et tu quid petis a Deo, nisi Christum, qui dicit: Ego sum panis vivus, qui de cælo descéndi? Ignósci vobis vultis? ignóscite: Remíttite, et remittétur vobis. Accípere vultis? date, et dábitur vobis.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Vidi Dóminum sedéntem super sólium excélsum et elevátum, et plena erat omnis terra majestáte ejus:"
             :repeat "Et ea, quæ sub ipso erant, replébant templum."
             :verse "Séraphim stabant super illud: sex alæ uni, et sex alæ álteri.")  ; R1
         (:respond "Benedíctus Dóminus Deus Israël, qui facit mirabília magna solus:"
             :repeat "Et benedíctum nomen majestátis ejus in ætérnum."
             :verse "Replébitur majestáte ejus omnis terra: fiat, fiat.")  ; R2
         (:respond "Benedícat nos Deus, Deus noster, benedícat nos Deus:"
             :repeat "Et métuant eum omnes fines terræ."
             :verse "Deus misereátur nostri, et benedícat nos Deus."
             :gloria t)  ; R3
         (:respond "Quis Deus magnus sicut Deus noster?"
             :repeat "Tu es Deus, qui facis mirabília."
             :verse "Notam fecísti in pópulis virtútem tuam: redemísti in brácchio tuo pópulum tuum.")  ; R4
         (:respond "Tibi laus, tibi glória, tibi gratiárum áctio in sǽcula sempitérna,"
             :repeat "O beáta Trínitas."
             :verse "Et benedíctum nomen glóriæ tuæ sanctum: et laudábile et superexaltátum in sǽcula.")  ; R5
         (:respond "Magnus Dóminus, et laudábilis nimis:"
             :repeat "Et sapiéntiæ ejus non est númerus."
             :verse "Magnus Dóminus, et magna virtus ejus: et sapiéntiæ ejus non est finis."
             :gloria t)  ; R6
         (:respond "Benedicámus Patrem et Fílium cum Sancto Spíritu:"
             :repeat "Laudémus et superexaltémus eum in sǽcula."
             :verse "Benedíctus es, Dómine, in firmaménto cæli: et laudábilis et gloriósus in sǽcula.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (2
     . (:lessons
        (
         (:ref "1 Reg 4:1-3"
             :text "1 Et factum est in diébus illis, convenérunt Philísthiim in pugnam: et egréssus est Israël óbviam Philísthiim in prǽlium, et castrametátus est juxta lápidem Adiutórii. Porro Philísthiim venérunt in Aphec,
2 et instruxérunt áciem contra Israël. Inito autem certámine, terga vertit Israël Philisthǽis: et cæsa sunt in illo certámine passim per agros, quasi quátuor míllia virórum.
3 Et revérsus est pópulus ad castra: dixerúntque majóres natu de Israël: Quare percússit nos Dóminus hódie coram Philísthiim? afferámus ad nos de Silo arcam fœ́deris Dómini, et véniat in médium nostri, ut salvet nos de manu inimicórum nostrórum.")  ; Lesson 1
         (:ref "1 Reg 4:4-6"
             :text "4 Misit ergo pópulus in Silo, et tulérunt inde arcam fœ́deris Dómini exercítuum sedéntis super chérubim: erántque duo fílii Heli cum arca fœ́deris Dei, Ophni et Phínees.
5 Cumque venísset arca fœ́deris Dómini in castra, vociferátus est omnis Israël clamóre grandi, et persónuit terra.
6 Et audiérunt Philísthiim vocem clamóris, dixerúntque: Quænam est hæc vox clamóris magni in castris Hebræórum? Et cognovérunt quod arca Dómini venísset in castra.")  ; Lesson 2
         (:ref "1 Reg 4:7-11"
             :text "7 Timuerúntque Philísthiim, dicéntes: Venit Deus in castra. Et ingemuérunt, dicéntes:
8 Væ nobis: non enim fuit tanta exultátio heri et nudiustértius: væ nobis. Quis nos salvábit de manu deórum sublímium istórum? hi sunt dii, qui percussérunt Ægýptum omni plaga in desérto.
9 Confortámini, et estóte viri, Philísthiim, ne serviátis Hebrǽis, sicut et illi serviérunt vobis: confortámini, et belláte.
10 Pugnavérunt ergo Philísthiim, et cæsus est Israël, et fugit unusquísque in tabernáculum suum: et facta est plaga magna nimis, et cecidérunt de Israël trigínta míllia péditum.
11 Et arca Dei capta est: duo quoque fílii Heli mórtui sunt, Ophni et Phínees.")  ; Lesson 3
         (:source "Sermo sancti Joánnis Chrysostomi
Ex Hom. 60 ad pop. Antioch"
             :text "Quóniam Verbum dicit: Hoc est corpus meum; et assentiámur et credámus et intellectuálibus ipsum óculis intueámur. Nihil enim sensíbile nobis Christus trádidit; sed sensibílibus quidem rebus, at ómnia intelligibília. Itidem et in baptísmate: per rem nempe sensíbilem, aquam, donum confértur; intelligíbile vero quod perfícitur, generátio et renovátio. Si enim incorpóreus esses, nuda et incorpórea tibi dedísset ipse dona; sed quóniam ánima córpori consérta est, in sensibílibus intelligibília tibi præbet. Quot nunc dicunt: Vellem ipsíus formam aspícere, figúram, vestiménta, calceaménta? Ecce eum vides, ipsum tangis, ipsum mandúcas. Et tu quidem vestiménta cupis vidére; ipse vero tibi concédit non tantum vidére, verum et manducáre, et tángere, et intra te súmere.")  ; Lesson 4
         (:text "Igitur accédat nemo cum náusea, nemo resolútus; omnes accénsi, omnes fervéntes et excitáti. Nam si Judǽi stantes, et calceaménta in pédibus habéntes, et báculos mánibus gestántes, agnum cum festinatióne comedébant; te multo magis opórtet esse solértem. Nam illi quidem in Palæstínam erant profectúri, et proptérea viatórum figúram habébant: tu vero debes in cælum migráre. Quaprópter in ómnibus opórtet te vigiláre; nec enim parva pœna propónitur indígne suméntibus. Cógita quantum advérsus proditórem indignáris, et contra eos qui illum crucifixérunt: ítaque consídera, ne tu quoque sis reus córporis et sánguinis Christi. Illi sanctíssimum corpus occidérunt, tu vero pollúta súscipis ánima, post tot benefícia. Neque enim illi satis fuit, hóminem fíeri, cólaphis cædi, et crucifígi; verum et semetípsum nobis commíscet; et non fide tantum, verum et ipsa re, nos suum éfficit corpus.")  ; Lesson 5
         (:text "Quo non opórtet ígitur esse puriórem, tali fruéntem sacrifício? quo solári rádio non splendidiórem manum, carnem hanc dividéntem? os quod igni spiritáli replétur, linguam quæ treméndo nimis sánguine rubéscit? Cógita quali sis insignítus honóre, quali mensa fruáris. Quod Angeli vidéntes horréscunt, neque líbere audent intuéri propter emicántem inde splendórem; hoc nos páscimur, huic nos unímur, et facti sumus unum Christi corpus, et una caro. Quis loquétur poténtias Dómini, audítas fáciet omnes laudes ejus? Quis pastor oves próprio pascit cruóre? Et quid dico, pastor? Matres multæ sunt, quæ post partus dolóres, fílios áliis tradunt nutrícibus. Hoc autem ipse non est passus; sed ipse nos próprio sánguine pascit, et per ómnia nos sibi coagméntat.")  ; Lesson 6
         (:ref "Luc 14:16-24"
             :gospel-incipit "In illo témpore: Dixit Jesus pharisǽis parábolam hanc: Homo quidam fecit cenam magnam, et vocávit multos. Et réliqua."
             :source "Homilía sancti Gregórii Papæ
Homilia 36 in Evangelia"
             :text "Hoc distáre, fratres caríssimi, inter delícias córporis et cordis solet: quod corporáles delíciæ, cum non habéntur, grave in se desidérium accéndunt; cum vero ávide edúntur, comedéntem prótinus in fastídium per satietátem vertunt. At contra, spiritáles delíciæ, cum non habéntur, in fastídio sunt; cum vero habéntur, in desidério: tantóque a comedénte ámplius esuriúntur, quanto et ab esuriénte ámplius comedúntur. In illis appetítus placet, experiéntia dísplicet; in istis appetítus saturitátem, satúritas fastídium génerat: in istis autem appetítus saturitátem, satúritas appetítum parit.")  ; Lesson 7
         (:text "Augent enim spiritáles delíciæ desidérium in mente, dum sátiant: quia quanto magis eárum sapor percípitur, eo ámplius cognóscitur quod avídius amétur; et idcírco non hábitæ amári non possunt, quia eárum sapor ignorátur. Quis enim amáre váleat quod ignórat? Proínde Psalmísta nos ádmonet, dicens: Gustáte et vidéte, quóniam suávis est Dóminus. Ac si apérte dicat: Suavitátem ejus non cognóscitis, si hanc mínime gustátis; sed cibum vitæ ex paláto cordis tángite, ut probántes ejus dulcédinem, amáre valeátis. Has autem homo delícias tunc amísit, cum in paradíso peccávit; extra éxiit, cum os a cibo ætérnæ dulcédinis clausit.")  ; Lesson 8
         (:text "Unde nos quoque, nati in hujus peregrinatiónis ærúmna, huc fastidiósi jam vénimus, nescímus quid desideráre debeámus. Tantóque se ámplius fastídii nostri morbus exággerat, quanto se magis ab esu illíus dulcédinis ánimus elóngat; et eo jam intérnas delícias non áppetit, quo eas comédere, diu longéque desuévit. Fastídio ergo nostro tabéscimus, et longa inédiæ peste fatigámur. Et quia gustáre intus nólumus parátam dulcédinem, amámus foris míseri famem nostram.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli: * Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri."
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei: * Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
             :repeat "Et unxit me unctióne misericórdiæ suæ.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me, * Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia: * Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël.")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos, * Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
             :repeat "Ubi cecidérunt fortes Israël.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei: * Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam, * Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
             :repeat "Et malum coram te feci.")  ; R7
         (:respond "Homo quidam fecit cœnam magnam, et misit servum suum hora cœnæ dícere invitátis ut venírent,"
             :repeat "Quia paráta sunt ómnia."
             :verse "Veníte, comédite panem meum, et bíbite vinum quod míscui vobis."
             :gloria t)  ; R8
         )))

    (3
     . (:lessons
        (
         (:ref "1 Reg 9:18-21"
             :text "18 Accéssit autem Saul ad Samuélem in médio portæ, et ait: Indica, oro, mihi, ubi est domus vidéntis.
19 Et respóndit Sámuel Sauli, dicens: Ego sum videns: ascénde ante me in excélsum, ut comedátis mecum hódie, et dimíttam te mane: et ómnia quæ sunt in corde tuo indicábo tibi.
20 Et de ásinis quas nudiustértius perdidísti, ne sollícitus sis, quia invéntæ sunt. Et cujus erunt óptima quæque Israël? nonne tibi et omni dómui patris tui?
21 Respóndens autem Saul, ait: Numquid non fílius Jémini ego sum de mínima tribu Israël, et cognátio mea novíssima inter omnes famílias de tribu Bénjamin? quare ergo locútus est mihi sermónem istum?")  ; Lesson 1
         (:ref "1 Reg 9:22-25"
             :text "22 Assúmens ítaque Sámuel Saulem et púerum ejus, introdúxit eos in triclínium, et dedit eis locum in cápite eórum qui fúerant invitáti: erant enim quasi trigínta viri.
23 Dixítque Sámuel coco: Da partem quam dedi tibi, et præcépi ut repóneres seórsum apud te.
24 Levávit autem cocus armum, et pósuit ante Saul. Dixítque Sámuel: Ecce quod remánsit: pone ante te, et cómede, quia de indústria servátum est tibi quando pópulum vocávi. Et comédit Saul cum Samuéle in die illa.
25 Et descendérunt de excélso in óppidum, et locútus est cum Saule in solário: stravítque Saul in solário, et dormívit.")  ; Lesson 2
         (:ref "1 Reg 9:26-27; 10:1"
             :text "26 Cumque mane surrexíssent, et jam elucésceret, vocávit Sámuel Saulem in solário, dicens: Surge, et dimíttam te. Et surréxit Saul: egressíque sunt ambo, ipse vidélicet, et Sámuel.
27 Cumque descénderent in extréma parte civitátis, Sámuel dixit ad Saul: Dic púero ut antecédat nos et tránseat: tu autem subsíste paulísper, ut índicem tibi verbum Dómini.
1 Tulit autem Sámuel lentículam ólei, et effúdit super caput ejus: et deosculátus est eum, et ait: Ecce unxit te Dóminus super hereditátem suam in príncipem, et liberábis pópulum suum de mánibus inimicórum ejus qui in circúitu ejus sunt.")  ; Lesson 3
         (:source "Ex lítteris Encyclicis Pii Papæ undécimi"
             :text "At certe inter cétera illa, quæ próprie ad sacratíssimi Cordis cultum pértinent, pia éminet ac memoránda est consecrátio, qua, nos nostráque ómnia ætérnæ Núminis caritáti accépta referéntes, divíno Jesu Cordi devovémus. Verum, áliud accédat opórtet, honéstæ satisfactiónis, ínquimus, seu reparatiónis, quam dicunt, offícium sacratíssimo Cordi Jesu præstándum. Nam, si illud est in consecratióne primum ac præcípuum ut amóri Creatóris creatúræ amor rependátur, álterum sponte hinc séquitur, ut eídem increáto Amóri, si quando aut oblivióne negléctus, aut offénsa violátus sit, illátæ quoquo modo injúriæ compensári débeant: quod quidem débitum reparatiónem vulgáto nómine vocámus.")  ; Lesson 4
         (:text "Quodsi ad utrámque rem iísdem prorsus ratiónibus impéllimur, reparándi tamen expiandíque offício ob validiórem quemdam justítiæ et amóris títulum tenémur: justítiæ quidem, ut irrogáta Deo nostris flagítiis expiétur offénsa et violátus ordo pœniténtia redintegrétur; amóris vero, ut Christo patiénti ac « saturáto oppróbriis » compatiámur eíque nonníhil solácii pro tenuitáte nostra afferámus. Peccatóres enim cum simus omnes, multísque oneráti culpis, non eo solo cultu Deus noster nobis est honorándus, quo vel ejus summam Majestátem débitis obséquiis adorémus, vel ejus suprémum domínium precándo agnoscámus, vel ejus infinítam largitátem gratiárum actiónibus laudémus; sed prætérea Deo justo víndici satisfaciámus opórtet « pro innumerabílibus peccátis et offensiónibus et negligéntiis » nostris. Consecratióni ígitur, qua Deo devovémur et sancti Deo vocámur, ea sanctitáte ac firmitáte quæ, ut docet Angélicus, consecratiónis est própria, addénda est expiátio, qua pénitus peccáta exstinguántur, ne forte indignitátem nostram impudéntem revérberet summæ justítiæ sánctitas, munúsque nostrum pótius árceat invísum quam gratum suscípiat.")  ; Lesson 5
         (:text "Hoc autem expiatiónis offícium humáno géneri univérso incúmbit, quippe quod, ut christiána docémur fide, post Adæ miserándum casum, hereditária labe inféctum, concupiscéntiis obnóxium et misérrime depravátum, in perníciem detrudéndum fuísset sempitérnam. Id quidem supérbi hac nostra ætáte sapiéntes, véterem Pelágii errórem secúti, inficiántur, natívam quandam virtútem humánæ natúræ jactántes quæ suápte vi ad altióra usque progrediátur; sed falsa hæc humánæ supérbiæ comménta réjicit Apóstolus, illud nos ádmonens: « natúra erámus fílii iræ ». Et sane jam ab inítio commúnis illíus expiatiónis débitum quasi agnovére hómines et Deo sacrifíciis vel públicis placándo, naturáli quodam sensu ducti, óperam dare cœpérunt.")  ; Lesson 6
         (:ref "Luc 15:1-10"
             :gospel-incipit "In illo témpore: Erant appropinquántes ad Jesum publicáni et peccatóres, ut audírent illum. Et réliqua."
             :source "Homilía sancti Gregórii Papæ
Homilia 34 in Evangelium, n. 2-3, post initium"
             :text "Audístis in lectióne evangélica, fratres mei, quia peccatóres et publicáni accessérunt ad Redemptórem nostrum; et non solum ad colloquéndum, sed étiam ad convescéndum recépti sunt. Quod vidéntes pharisǽi dedignáti sunt. Ex qua re collígite quia vera justítia compassiónem habet, falsa justítia dedignatiónem. Quamvis et justi sóleant recte peccatóribus dedignári: sed áliud est quod ágitur typho supérbiæ, áliud quod zelo disciplínæ.")  ; Lesson 7
         (:text "Dedignántur étenim, sed non dedignántes: despérant, sed non desperántes: persecutiónem cómmovent, sed amántes: quia etsi foris increpatiónes per disciplínam exággerant, intus tamen dulcédinem per caritátem servant. Præpónunt sibi in ánimo ipsos plerúmque quos córrigunt: melióres exístimant eos quoque quos júdicant. Quod vidélicet agéntes, et per disciplínam súbditos, et per humilitátem custódiunt semetípsos.")  ; Lesson 8
         (:text "At contra, hi qui de falsa justítia superbíre solent, céteros quosque despíciunt, nulla infirmántibus misericórdia condescéndunt: quo se peccatóres esse non credunt, eo detérius peccatóres fiunt. De quorum profécto número pharisǽi exstíterant, qui diiudicántes Dóminum quod peccatóres suscíperet, arénti corde ipsum fontem misericórdiæ reprehendébant. Sed quia ægri erant, ita ut ægros se esse nescírent; quátenus quod erant agnóscerent, cæléstis eos médicus blandis foméntis curat, benígnum paradígma óbjicit, et in eórum corde vúlneris tumórem premit.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli: * Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri."
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei: * Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
             :repeat "Et unxit me unctióne misericórdiæ suæ.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me, * Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia: * Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël.")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos, * Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
             :repeat "Ubi cecidérunt fortes Israël.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei: * Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam, * Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
             :repeat "Et malum coram te feci.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :repeat "Plena est omnis terra glória ejus."
             :gloria t)  ; R8
         )))

    (4
     . (:lessons
        (
         (:ref "1 Reg 17:1-7"
             :text "1 Congregántes autem Philísthiim ágmina sua in prǽlium convenérunt in Socho Judæ, et castrametáti sunt inter Socho et Azéca in fínibus Dommim.
2 Porro Saul et fílii Israël congregáti venérunt in Vallem terebínthi, et direxérunt áciem ad pugnándum contra Philísthiim.
3 Et Philísthiim stabant super montem ex parte hac, et Israël stabat supra montem ex áltera parte, vallísque erat inter eos.
4 Et egréssus est vir spúrius de castris Philisthinórum nómine Góliath de Geth altitúdinis sex cubitórum et palmi.
5 Et cassis ǽrea super caput ejus, et loríca squamáta induebátur; porro pondus lorícæ ejus quinque míllia siclórum æris erat.
6 Et ócreas ǽreas habébat in crúribus, et clípeus ǽreus tegébat húmeros ejus.
7 Hastíle autem hastæ ejus erat quasi liciatórium texéntium; ipsum autem ferrum hastæ ejus sexcéntos siclos habébat ferri; et ármiger ejus antecedébat eum.")  ; Lesson 1
         (:ref "1 Reg 17:8-11"
             :text "8 Stansque clamábat advérsum phalángas Israël et dicébat eis: Quare venístis paráti ad prǽlium? Numquid ego non sum Philisthǽus, et vos servi Saul? Elígite ex vobis virum, et descéndat ad singuláre certámen:
9 si quíverit pugnáre mecum et percússerit me, érimus vobis servi; si autem ego prævalúero et percússero eum, vos servi éritis et serviétis nobis.
10 Et ajébat Philisthǽus: Ego exprobrávi agmínibus Israël hódie: Date mihi virum, et íneat mecum singuláre certámen.
11 Audiens autem Saul et omnes Israëlítæ sermónes Philisthǽi hujuscémodi, stupébant et metuébant nimis.")  ; Lesson 2
         (:ref "1 Reg 17:12-16"
             :text "12 David autem erat fílius viri Ephrathǽi, de quo supra dictum est, de Béthlehem Juda, cui nomen erat Isai, qui habébat octo fílios, et erat vir in diébus Saul senex et grandǽvus inter viros.
13 Abiérunt autem tres fílii ejus majóres post Saul in prǽlium; et nómina trium filiórum ejus, qui perrexérunt ad bellum, Eliab primogénitus et secúndus Abínadab tertiúsque Samma;
14 David autem erat mínimus. Tribus ergo majóribus secútis Saulem,
15 ábiit David et revérsus est a Saul, ut pásceret gregem patris sui in Béthlehem.
16 Procedébat vero Philisthǽus mane et véspere, et stabat quadragínta diébus.")  ; Lesson 3
         (:source "Sermo sancti Augustíni Epíscopi
Sermo 197 de Temp. circa med."
             :text "Stabant fílii Israël contra adversários quadragínta diébus. Quadragínta dies, propter quátuor témpora et quátuor partes orbis terræ, vitam præséntem signíficant, in qua contra Góliath vel exércitum ejus, id est, contra diábolum et ángelos ejus, Christianórum pópulus pugnáre non désinit. Nec tamen víncere posset, nisi verus David Christus cum báculo, id est, cum crucis mystério descendísset. Ante advéntum enim Christi, fratres caríssimi, solútus erat diábolus; véniens Christus fecit de eo, quod in Evangélio dictum est: Nemo potest intráre in domum fortis et vasa ejus dirípere, nisi prius alligáverit fortem. Venit ergo Christus et alligávit diábolum.")  ; Lesson 4
         (:text "Sed dicit áliquis: Si alligátus est, quare adhuc tantum prǽvalet? Verum est, fratres caríssimi, quia multum prǽvalet: sed tépidis, et negligéntibus, et Deum in veritáte non timéntibus dominátur. Alligátus est enim tamquam innéxus canis caténis et néminem potest mordére, nisi eum qui se illi mortífera securitáte conjúnxerit. Jam vidéte, fratres, quam stultus est homo ille, quem canis in caténa pósitus mordet. Tu te illi per voluntátes et cupiditátes sǽculi noli conjúngere, et ille ad te non præsúmit accédere. Latráre potest, sollicitáre potest; mordére omníno non potest, nisi voléntem. Non enim cogéndo, sed suadéndo nocet; nec extórquet a nobis consénsum, sed petit.")  ; Lesson 5
         (:text "Venit ergo David et invénit Judæórum pópulum contra diábolum præliántem; et cum nullus esset qui præsúmeret ad singuláre certámen accédere, ille qui figúram Christi gerébat, procéssit ad prǽlium, tulit báculum in manu sua et éxiit contra Góliath. Et in illo quidem tunc figurátum est, quod in Dómino Jesu Christo complétum est. Venit enim verus David Christus, qui contra spiritálem Góliath, id est, contra diábolum pugnatúrus crucem suam ipse portávit. Vidéte, fratres, ubi David Góliath percússerit: in fronte útique, ubi crucis signáculum non habébat. Sicut enim báculus crucis typum hábuit, ita étiam et lapis ille, de quo percússus est, Christum Dóminum figurábat.")  ; Lesson 6
         (:ref "Luc 5:1-11"
             :gospel-incipit "In illo témpore: Cum turbæ irrúerent in Jesum, ut audírent verbum Dei, et ipse stabat secus stagnum Genésareth. Et réliqua."
             :source "Homilía sancti Ambrósii Epíscopi
Liber 4 in Lucæ cap. 5 prope finem libri"
             :text "Ubi Dóminus multis impartívit varia génera sanitátum, nec témpore, nec loco pótuit ab stúdio sanándi turba cohibéri. Vesper incúbuit sequebántur: stagnum occúrrit, urgébant: et ídeo ascéndit in Petri navim. Hæc est illa navis, quæ adhuc secúndum Matthǽum flúctuat, secúndum Lucam replétur píscibus: ut et princípia Ecclésiæ fluctuántis, et posterióra exuberántis agnóscas. Pisces enim sunt, qui hanc enávigant vitam. Ibi adhuc discípulis Christus dormit, hic prǽcipit; dormit enim tépidis, perféctis vígilat.")  ; Lesson 7
         (:text "Non turbátur hæc navis, in qua prudéntia navigat, abest perfidia, fides aspirat. Quemádmodum enim turbari poterat, cui præerat is, in quo Ecclésiæ firmaméntum est? Illic ergo turbátio, ubi módica fides; hic securitas, ubi perfécta diléctio. Et si aliis imperátur ut laxent rétia sua, soli tamen Petro dícitur: Duc in altum; hoc est, in profúndum disputatiónum. Quid enim tam altum, quam altitúdinem divitiárum vidére, scire Dei Fílium, et professiónem divinæ generatiónis assúmere? Quam licet mens non queat humana plene ratiónis investigatióne comprehéndere, fidei tamen plenitúdo compléctitur.")  ; Lesson 8
         (:text "Nam, etsi non licet mihi scire quemádmodum natus sit, non licete tamen nescire quod natus sit. Seriem generatiónis ignoro; sed auctórem generatiónis agnosco. Non interfúimus cum ex Patre Dei Fílius nascerétur; sed interfúimus cum a Patre Dei Fílius dicerétur. Si Deo non crédimus, cui credémus? Omnia enim quæ crédimus, vel visu crédimus, vel audítu: visus sæpe fállitur, audítus in fide est.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
             :repeat "Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia:"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
             :repeat "Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
             :repeat "Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (5
     . (:lessons
        (
         (:ref "2 Reg 1:1-4"
             :text "1 Factum est autem, postquam mórtuus est Saul, ut David reverterétur a cæde Amalec et manéret in Síceleg duos dies.
2 In die autem tértia appáruit homo véniens de castris Saul veste conscíssa et púlvere conspérsus caput et, ut venit ad David, cécidit super fáciem suam et adorávit.
3 Dixítque ad eum David: Unde venis? Qui ait ad eum: De castris Israël fugi.
4 Et dixit ad eum David: Quod est verbum quod factum est? Indica mihi. Qui ait: Fugit pópulus ex prǽlio, et multi corruéntes e pópulo mórtui sunt; sed et Saul et Jónathas fílius ejus interiérunt.")  ; Lesson 1
         (:ref "2 Reg 1:5-10"
             :text "5 Dixítque David ad adolescéntem qui nuntiábat ei: Unde scis quia mórtuus est Saul et Jónathas fílius ejus?
6 Et ait adoléscens qui nuntiábat ei: Casu veni in montem Gélboë, et Saul incumbébat super hastam suam. Porro currus et équites appropinquábant ei,
7 et convérsus post tergum suum vidénsque me vocávit; cui cum respondíssem: Adsum,
8 dixit mihi: Quisnam es tu? Et ajo ad eum: Amalecítes ego sum.
9 Et locútus est mihi: Sta super me et intérfice me, quóniam tenent me angústiæ, et adhuc tota ánima mea in me est.
10 Stansque super eum, occídi illum, sciébam enim quod vívere non póterat post ruínam; et tuli diadéma, quod erat in cápite ejus et armíllam de brácchio illíus et áttuli ad te dóminum meum huc.")  ; Lesson 2
         (:ref "2 Reg 1:11-15"
             :text "11 Apprehéndens autem David, vestiménta sua scidit, omnésque viri, qui erant cum eo,
12 et planxérunt, et flevérunt, et jejunavérunt usque ad vésperam super Saul, et super Jónathan fílium ejus, et super pópulum Dómini et super domum Israël, eo quod corruíssent gládio.
13 Dixítque David ad júvenem qui nuntiáverat ei: Unde es tu? Qui respóndit: Fílius hóminis ádvenæ Amalecítæ ego sum.
14 Et ait ad eum David: Quare non timuísti míttere manum tuam, ut occíderes christum Dómini?
15 Vocánsque David unum de púeris suis ait: Accédens írrue in eum. Qui percússit illum, et mórtuus est.")  ; Lesson 3
         (:source "Ex libro Morálium sancti Gregórii Papæ
Liber 4, Cap. 3 et 4"
             :text "Quid est quod David, qui retribuéntibus sibi mala non réddidit, cum Saul et Jónathas bello occúmberent, Gélboë móntibus maledíxit, dicens: Montes Gélboë, nec ros nec plúvia véniant super vos: neque sint agri primitiárum: quia ibi abjéctus est clýpeus fórtius, clýpeus Saul, quasi non esset unctus óleo? Quid est quod Jeremías, cum prædicatiónem suam cérneret audiéntium difficultáte præpedíri, maledíxit dicens: Maledíctus vir, qui annuntiávit patri meo, dicens: Natus est tibi puer másculus?")  ; Lesson 4
         (:text "Quid ergo montes Gélboë, Saul moriénte, deliquérunt, quátenus in eos nec ros nec plúvia cáderet et ab omni eos viriditátis gérmine senténtiæ sermo siccáret? Sed quia Gélboë interpretátur decúrsus, per Saul autem unctum et mórtuum mors nostri mediatóris exprímitur; non immérito per Gélboë montes supérba Judæórum corda signántur, quæ dum in hujus mundi desidériis défluunt, in Christi, id est, uncti se morte miscuérunt: et quia in eis unctus rex corporáliter móritur, ipsi ab omni grátiæ rore siccántur.")  ; Lesson 5
         (:text "De quibus et bene dícitur, ut agri primitiárum esse non possint. Supérbæ quippe Hebræórum mentes primitívos fructus non ferunt: quia in Redemptóris advéntu ex parte máxima in perfídia remanéntes, primórdia fídei sequi noluérunt. Sancta namque Ecclésia in primítiis suis multitúdine Géntium fœcundáta, vix in mundi fine Judǽos quos invénerit, súscipit, et extréma cólligens, eos quasi relíquias frugum ponit.")  ; Lesson 6
         (:ref "Matt 5:20-24"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis: Nisi abundáverit justítia vestra plus quam scribárum et pharisæórum, non intrábitis in regnum cælórum. Et réliqua."
             :source "Homilía sancti Augustíni Epíscopi
Liber 1 de Sermóne Dómini in monte, cap. 9"
             :text "Justítia pharisæórum est, ut non occídant: justítia eórum, qui intratúri sunt in regnum cælórum, ut non irascántur sine causa. Mínimum est ergo, non occídere; et qui illud sólverit, mínimus vocábitur in regno cælórum. Qui autem illud impléverit, ut non occídat, non contínuo magnus erit, et idóneus regno cælórum; sed tamen ascéndit áliquem gradum: perficiétur autem, si nec irascátur sine causa; quod si perfécerit, multo remótior erit ab homicídio. Quaprópter qui docet ut non irascámur, non solvit legem ne occidámus, et in corde, dum non iráscimur, innocéntiam custodiámus.")  ; Lesson 7
         (:text "Gradus ítaque sunt in istis peccátis: ut primo quisque irascátur, et eum motum retíneat corde concéptum. Jam si extórserit vocem indignántis ipsa commótio, non significántem áliquid, sed illum ánimi motum ipsa eruptióne testántem, qua feriátur ille, cui iráscitur; plus est útique, quam si surgens ira siléntio premerétur. Si vero non solum vox indignántis audiátur, sed étiam verbum, quo jam certam ejus vituperatiónem, in quem profértur, desígnet et notet; quis dúbitet, ámplius hoc esse, quam si solus indignatiónis sonus ederétur?")  ; Lesson 8
         (:text "Vide nunc étiam tres reátus, judícii, concílii, et gehénnæ ignis. Nam in judício adhuc defensióni datur locus. In concílio autem, quamquam et judícium esse sóleat, tamen quia interésse áliquid hoc loco fatéri cogit ipsa distínctio, vidétur ad concílium pertinére senténtiæ prolátio; quando non jam cum ipso reo ágitur, utrum damnándus sit; sed inter se, qui júdicant, cónferunt quo supplício damnári opórteat, quem constat esse damnándum. Gehénna vero ignis, nec damnatiónem habet dúbiam, sicut judícium, nec damnáti pœnam, sicut concílium: in gehénna quippe ignis, certa est damnátio, et pœna damnáti.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
             :repeat "Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia:"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
             :repeat "Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
             :repeat "Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (6
     . (:lessons
        (
         (:ref "2 Reg 12:1-4"
             :text "1 Misit ergo Dóminus Nathan ad David: qui, cum venísset ad eum, dixit ei: Duo viri erant in civitáte una, unus dives et alter pauper.
2 Dives habébat oves et boves plúrimos valde,
3 pauper autem nihil habébat omníno præter ovem unam párvulam, quam émerat et nutríerat, et quæ créverat apud eum cum fíliis ejus simul de pane illíus cómedens et de cálice ejus bibens et in sinu illíus dórmiens; erátque illic sicut fília.
4 Cum autem peregrínus quidam venísset ad dívitem, parcens ille súmere de óvibus et de bobus suis, ut exhibéret convívium peregríno illi qui vénerat ad se, tulit ovem viri páuperis et præparávit cibos hómini qui vénerat ad se.")  ; Lesson 1
         (:ref "2 Reg 12:5-9"
             :text "5 Irátus autem indignatióne David advérsus hóminem illum nimis, dixit ad Nathan: Vivit Dóminus, quóniam fílius mortis est vir qui fecit hoc:
6 ovem reddet in quádruplum, eo quod fécerit verbum istud et non pepércerit.
7 Dixit autem Nathan ad David: Tu es ille vir. Hæc dicit Dóminus Deus Israël: Ego unxi te in regem super Israël et ego érui te de manu Saul,
8 et dedi tibi domum dómini tui, et uxóres dómini tui in sinu tuo dedíque tibi domum Israël et Juda; et, si parva sunt ista, adíciam tibi multo majóra.
9 Quare ergo contempsísti verbum Dómini, ut fáceres malum in conspéctu meo? Uríam Hethǽum percussísti gládio et uxórem illíus accepísti in uxórem tibi et interfecísti eum gládio filiórum Ammon.")  ; Lesson 2
         (:ref "2 Reg 12:10-16"
             :text "10 Quam ob rem non recédet gládius de domo tua usque in sempitérnum, eo quod despéxeris me et túleris uxórem Uríæ Hethǽi ut esset uxor tua.
11 Itaque hæc dicit Dóminus: Ecce ego suscitábo super te malum de domo tua, et tollam uxóres tuas in óculis tuis et dabo próximo tuo, et dórmiet cum uxóribus tuis in óculis solis hujus.
12 Tu enim fecísti abscóndite, ego autem fáciam verbum istud in conspéctu omnis Israël et in conspéctu solis.
13 Et dixit David ad Nathan: Peccávi Dómino. Dixítque Nathan ad David: Dóminus quoque tránstulit peccátum tuum: non moriéris.
14 Verúmtamen, quóniam blasphemáre fecísti inimícos Dómini propter verbum hoc, fílius, qui natus est tibi, morte moriétur.
15 Et revérsus est Nathan in domum suam. Percússit quoque Dóminus párvulum, quem pepérerat uxor Uríæ David, et desperátus est.
16 Deprecatúsque est David Dóminum pro párvulo, et jejunávit David jejúnio et ingréssus seórsum jácuit super terram.")  ; Lesson 3
         (:source "Ex libro sancti Ambrósii Epíscopi de Apología David
Apolog. 1, c. 2"
             :text "Unusquísque nostrum per síngulas horas quam multa delínquit! nec tamen unusquísque de plebe peccátum suum confiténdum putat. Ille rex, tantus ac potens, ne exíguo quidem moménto manére penes se delícti passus est consciéntiam; sed, præmatúra confessióne atque imménso dolóre, réddidit peccátum suum Dómino. Quem mihi nunc fácile repérias honorátum ac dívitem, qui, si arguátur alicújus culpæ reus, non moléste ferat? At ille régio clarus império, tot divínis probátus oráculis, cum a priváto hómine corriperétur quod gráviter deliquísset, non indignátus infrémuit, sed conféssus ingémuit culpæ dolóre.")  ; Lesson 4
         (:text "Dénique Dóminum dolor íntimi movit afféctus, ut Nathan díceret: Quóniam pœnítuit te, et Dóminus ábstulit peccátum tuum. Matúritas ítaque véniæ, profúndam regis fuísse pœniténtiam declarávit, quæ tanti erróris offénsam tradúxerit. Alii hómines cum a sacerdótibus corripiúntur, peccátum suum íngravant, dum negáre cúpiunt aut deféndere; ibíque eórum lapsus est major, ubi sperátur corréctio. Sancti autem Dómini, qui consummáre pium certámen géstiunt, et cúrrere cursum salútis, sícubi forte ut hómines corrúerint, natúræ magis fragilitáte quam peccándi libídine, acrióres ad curréndum resúrgunt, pudóris stímulo majóra reparántes certámina; ut non solum nullum attulísse æstimétur lapsus impediméntum, sed étiam velocitátis incentíva cumulásse.")  ; Lesson 5
         (:text "Peccávit David, quod solent reges; sed pœniténtiam gessit, flevit, ingémuit, quod non solent reges. Conféssus est culpam, obsecrávit indulgéntiam, humi stratus deplorávit ærúmnam, jejunávit, orávit, confessiónis suæ testimónium in perpétua sǽcula vulgáto dolóre transmísit. Quod erubéscunt fácere priváti, rex non erúbuit confitéri. Qui tenéntur légibus, audent suum negáre peccátum, dedignántur rogáre indulgéntiam, quam petébat qui nullis légibus tenebátur humánis. Quod peccávit, conditiónis est; quod supplicávit, correctiónis. Lapsus commúnis, sed speciális conféssio. Culpam ítaque incidísse, natúræ est: diluísse, virtútis.")  ; Lesson 6
         (:ref "Marc 8:1-9"
             :gospel-incipit "In illo témpore: Cum turba multa esset cum Jesu nec habérent quod manducárent, convocátis discípulis, ait illis: Miséreor super turbam, quia ecce jam tríduo sústinent me nec habent quod mandúcent. Et réliqua."
             :source "Homilía sancti Ambrósii Epíscopi
Liber 6 in Lucæ cap. 9, post initium"
             :text "Posteáquam illa, quæ Ecclésiæ typum accépit, a fluxu curáta est sánguinis, posteáquam Apóstoli ad evangelizándum regnum Dei sunt destináti, grátiæ cæléstis impartítur aliméntum. Sed quibus impartiátur, advérte. Non otiósis, non in civitáte, quasi in synagóga vel sæculári dignitáte residéntibus; sed inter desérta quæréntibus Christum. Qui enim non fastídiunt, ipsi excipiúntur a Christo, et cum ipsis lóquitur Dei Verbum, non de sæculáribus, sed de regno Dei. Et si qui corporális gerunt úlcera passiónis, his medicínam suam libénter indúlget.")  ; Lesson 7
         (:text "Cónsequens ígitur erat, ut quos a vúlnerum dolóre sanáverat, eos alimóniis spiritálibus a jejúnio liberáret. Itaque nemo cibum áccipit Christi, nisi fúerit ante sanátus; et illi qui vocántur ad cœnam, prius vocándo sanántur. Si claudus fuit, gradiéndi facultátem, ut veníret, accépit: si lúmine oculórum privátus, domum útique Dómini, nisi refúsa luce, intráre non pótuit.")  ; Lesson 8
         (:text "Ubíque ígitur mystérii ordo servátur, ut prius per remissiónem peccatórum vulnéribus medicína tribuátur, post alimónia mensæ cæléstis exúberat; quamquam nondum validióribus hæc turba reficiátur aliméntis, neque Christi córpore et sánguine jejúna solidióris fídei corda pascántur. Lacte, inquit, vos potávi, non esca; nondum enim poterátis, sed nec adhuc quidem potéstis. In modum lactis quinque sunt panes: esca autem solídior, corpus est Christus; potus veheméntior, sanguis est Dómini.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
             :repeat "Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia:"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
             :repeat "Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
             :repeat "Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (7
     . (:lessons
        (
         (:ref "3 Reg 1:1-4"
             :text "1 Et rex David senúerat habebátque ætátis plúrimos dies: cumque operirétur véstibus, non calefiébat.
2 Dixérunt ergo ei servi sui: Quærámus dómino nostro regi adolescéntulam vírginem, et stet coram rege et fóveat eum dormiátque in sinu suo et calefáciat dóminum nostrum regem.
3 Quæsiérunt ígitur adolescéntulam speciósam in ómnibus fínibus Israël et invenérunt Abísag Sunamítidem et adduxérunt eam ad regem.
4 Erat autem puélla pulchra nimis dormiebátque cum rege et ministrábat ei; rex vero non cognóvit eam.")  ; Lesson 1
         (:ref "3 Reg 1:5-8"
             :text "5 Adonías autem fílius Haggith elevabátur, dicens: Ego regnábo. Fecítque sibi currus et équites et quinquagínta viros, qui cúrrerent ante eum.
6 Nec corrípuit eum pater suus aliquándo dicens: Quare hoc fecísti? Erat autem et ipse pulcher valde, secúndus natu post Absalom.
7 Et sermo ei cum Joab fílio Sárviæ et cum Abíathar sacerdóte, qui adjuvábant partes Adoníæ.
8 Sadoc vero sacérdos, et Banájas fílius Jójadæ, et Nathan prophéta, et Sémei et Rei, et robur exércitus David non erat cum Adonía.")  ; Lesson 2
         (:ref "3 Reg 1:11-15"
             :text "11 Dixit ítaque Nathan ad Bethsabée matrem Salomónis: Num audísti quod regnáverit Adonías fílius Haggith, et dóminus noster David hoc ignórat?
12 Nunc ergo veni, áccipe consílium a me et salva ánimam tuam filiíque tui Salomónis.
13 Vade et ingrédere ad regem David et dic ei: Nonne tu, dómine mi rex, jurásti mihi ancíllæ tuæ dicens: Sálomon fílius tuus regnábit post me et ipse sedébit in sólio meo? Quare ergo regnat Adonías?
14 Et, adhuc ibi te loquénte cum rege, ego véniam post te et complébo sermónes tuos.
15 Ingréssa est ítaque Bethsabée ad regem in cubículum.")  ; Lesson 3
         (:source "Ex Epístola sancti Hierónymi Presbýteri ad Nepotiánum
Epist. 2, tom. 1"
             :text "David annos natus septuagínta, bellicósus quondam vir, senectúte frigescénte, non póterat calefíeri. Quǽritur ítaque puélla de univérsis fínibus Israël Abísag Sunamítis, quæ cum rege dormíret, et seníle corpus calefáceret. Quæ est ista Sunamítis, uxor et virgo, tam fervens, ut frígidum calefáceret; tam sancta, ut caléntem ad libídinem non provocáret? Expónat sapientíssimus Sálomon patris sui delícias, et pacíficus bellatóris viri narret ampléxus: Pósside sapiéntiam, pósside intelligéntiam. Ne obliviscáris, et ne declináveris a verbis oris mei: neque derelínquas illam, et apprehéndet te: ama illam, et servábit te. Princípium sapiéntiæ, pósside sapiéntiam, et in omni possessióne tua pósside intelligéntiam: circúmda illam, et exaltábit te; honóra illam, et amplexábitur te, ut det cápiti tuo corónam gratiárum. Coróna quoque deliciárum próteget te.")  ; Lesson 4
         (:text "Omnes pene virtútes córporis mutántur in sénibus, et crescénte sola sapiéntia, decréscunt cétera: jejúnia, vigíliæ, chaméuniæ, id est, super paviméntum dormitiónes, huc illúcque discúrsus, peregrinórum suscéptio, defénsio páuperum, instántia oratiónum et perseverántia, visitátio languéntium, labor mánuum unde præbeántur eleemósynæ. Et, ne sermónem lóngius prótraham, cuncta exercéntur, fracto córpore, minóra fiunt.")  ; Lesson 5
         (:text "Nec hoc dico, quod in juvénibus et adhuc solidióris ætátis, his dumtáxat, qui labóre et ardentíssimo stúdio, vitæ quoque sanctimónia, et oratiónis ad Dóminum Jesum frequéntia, sciéntiam consecúti sunt, frígeat sapiéntia, quæ in plerísque sénibus ætáte marcéscit; sed quod adolescéntia multa córporis bella sustíneat, et inter incentíva vitiórum et carnis titillatiónes, quasi ignis in lignis virídibus suffocétur, ut suum non possit explicáre fulgórem. Senéctus vero rursus eórum qui adolescéntiam suam honéstis ártibus instruxérunt, et in lege Dómini meditáti sunt die ac nocte, ætáte fit dóctior, usu trítior, procéssu témporis sapiéntior, et véterum studiórum dulcíssimos fructus metit.")  ; Lesson 6
         (:ref "Matt 7:15-21"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis: Atténdite a falsis prophétis, qui véniunt ad vos in vestiméntis óvium, intrínsecus autem sunt lupi rapáces. Et réliqua."
             :source "Homilía sancti Hilárii Epíscopi
Comment. in Matth. can. 6"
             :text "Blandiménta verbórum et mansuetúdinis simulatiónem ádmonet fructu operatiónis expéndi oportére; ut non qualem quis verbis réferat, sed qualem se rebus effíciat, spectémus; quia in multis vestítu óvium rábies lupína contégitur. Ergo ut spinæ uvas, ut tríbuli ficus non génerant, et ut iníquæ árbores utília poma non áfferunt; ita ne in istis quidem consístere docet boni óperis efféctum, et idcírco omnes cognoscéndos esse de frúctibus. Regnum enim cælórum sola verbórum offícia non óbtinent; neque qui díxerit: Dómine, Dómine, heres illíus erit.")  ; Lesson 7
         (:text "Quid enim mériti est Dómino dícere, Dómine? Numquid Dóminus non erit, nisi fúerit dictus a nobis? Et quæ offícii sánctitas est nóminis nuncupátio, cum cæléstis regni iter obediéntia pótius voluntátis Dei, non nuncupátio, repertúra sit? Multi mihi dicent in illa die: Dómine, Dómine, nonne in tuo nómine prophetávimus? Etiam nunc pseudoprophetárum frauduléntiam et hypocritárum simulaménta condémnat, qui glóriam sibi ex verbi virtúte præsúmunt, in doctrínæ prophetía, et dæmoniórum fuga, et istiúsmodi óperum virtútibus.")  ; Lesson 8
         (:text "Atque hinc sibi regnum cælórum pollicéntur: quasi vero eórum áliquid próprium sit, quæ loquúntur aut fáciunt, et non ómnia virtus Dei invocáta perfíciat; cum doctrínæ sciéntiam léctio áfferat, dæmónia Christi nomen exágitet. De nostro ígitur est beáta illa ætérnitas promerénda, præstandúmque est áliquid ex próprio, ut bonum velímus, malum omne vitémus, totóque afféctu præcéptis cæléstibus obtemperémus, ac tálibus offíciis cógniti Deo simus, agamúsque pótius quod vult, quam quod potest gloriémur; repúdians eos ac repéllens, quos a cognitióne sua, ópera iniquitátis avérterint.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
             :repeat "Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia:"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
             :repeat "Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
             :repeat "Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (8
     . (:lessons
        (
         (:ref "3 Reg 9:1-5"
             :text "1 Factum est autem cum perfecísset Sálomon ædifícium domus Dómini et ædifícium regis et omne quod optáverat et volúerat fácere,
2 appáruit ei Dóminus secúndo, sicut apparúerat ei in Gábaon.
3 Dixítque Dóminus ad eum: Exaudívi oratiónem tuam et deprecatiónem tuam, quam deprecátus es coram me; sanctificávi domum hanc, quam ædificásti, ut pónerem nomen meum ibi in sempitérnum; et erunt óculi mei et cor meum ibi cunctis diébus.
4 Tu quoque, si ambuláveris coram me sicut ambulávit pater tuus in simplicitáte cordis et in æquitáte, et féceris ómnia quæ præcépi tibi et legítima mea et judícia mea serváveris,
5 ponam thronum regni tui super Israël in sempitérnum, sicut locútus sum David, patri tuo dicens: Non auferétur vir de génere tuo de sólio Israël.")  ; Lesson 1
         (:ref "3 Reg 9:6-9"
             :text "6 Si autem aversióne avérsi fuéritis vos et fílii vestri non sequéntes me nec custodiéntes mandáta mea et cæremónias meas quas propósui vobis, sed abiéritis et coluéritis deos aliénos et adoravéritis eos;
7 áuferam Israël de superfície terræ quam dedi eis, et templum quod sanctificávi nómini meo proíciam a conspéctu meo, erítque Israël in provérbium et in fábulam cunctis pópulis,
8 et domus hæc erit in exémplum: omnis qui transíerit per eam stupébit et sibilábit et dicet: Quare fecit Dóminus sic terræ huic et dómui huic?
9 Et respondébunt: Quia dereliquérunt Dóminum Deum suum, qui edúxit patres eórum de terra Ægýpti, et secúti sunt deos aliénos et adoravérunt eos et coluérunt eos; idcírco indúxit Dóminus super eos omne malum hoc.")  ; Lesson 2
         (:ref "3 Reg 9:10-14"
             :text "10 Explétis autem annis vigínti postquam ædificáverat Sálomon duas domos, id est domus Dómini et domum regis
11 (Hiram rege Tyri præbénte Salomóni ligna cédrina et abiégna et aurum juxta omne quod opus habúerat), tunc dedit Sálomon Hiram vigínti óppida in terra Galilǽæ.
12 Et egréssus est Hiram de Tyro ut vidéret óppida, quæ déderat ei Sálomon, et non placuérunt ei,
13 et ait: Hǽcine sunt civitátes, quas dedísti mihi, frater? Et appellávit eas terram Chabul usque in diem hanc.
14 Misit quoque Hiram ad regem Salomónem centum vigínti talénta auri.")  ; Lesson 3
         (:source "Ex libro sancti Augustíni Epíscopi de Civitáte Dei.
Liber 17. cap. 8. sub medio."
             :text "Facta est quidem nonnúlla imágo rei futúræ étiam in Salomóne, in eo quod templum ædificávit, et pacem hábuit secúndum nomen suum (Sálomon quippe pacíficus est Latíne), et in exórdio regni sui mirabíliter laudábilis fuit. Sed eádem sua persóna per umbram futúri prænuntiábat étiam ipse Christum Dóminum nostrum, non exhibébat. Unde quædam de illo ita scripta sunt, quasi de ipso ista prædícta sint, dum Scriptúra sancta étiam rebus gestis prophétans, quodámmodo in eo figúram delíneat futurórum.")  ; Lesson 4
         (:text "Nam præter libros divínæ históriæ, ubi regnásse narrátur, Psalmus étiam septuagésimus primus título nóminis ejus inscríptus est. In quo tam multa dicúntur, quæ omníno ei conveníre non possunt, Dómino autem Christo aptíssima perspicuitáte convéniunt: ut evidénter appáreat, quod in illo figúra qualiscúmque adumbráta sit, in isto autem ipsa véritas præsentáta.")  ; Lesson 5
         (:text "Notum est enim quibus términis regnum conclúsum fúerit Salomónis: et tamen in eo Psalmo légitur, ut ália táceam: Dominábitur a mari usque ad mare, et a flúmine usque ad términos orbis terræ; quod in Christo vidémus impléri. A flúmine quippe dominándi sumpsit exórdium, ubi baptizátus a Joánne, eódem monstránte, cœpit agnósci a discípulis, qui eum non solum magístrum, verum étiam Dóminum appellavérunt.")  ; Lesson 6
         (:ref "Luc 16:1-9"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis parábolam hanc: Homo quidam erat dives, qui habébat víllicum, et hic diffamátus est apud illum quasi dissipásset bona ipsíus. Et réliqua."
             :source "Homilía sancti Hierónymi Presbýteri
Epistola 151 ad Algasium, quæst. 6, tom. 3"
             :text "Si dispensátor iníqui mammónæ, dómini voce laudátur, quod de re iníqua sibi justítiam præparárit; et passus dispéndia dóminus laudat dispensatóris prudéntiam, quod advérsus dóminum quidem fraudulénter, sed pro se prudénter égerit: quanto magis Christus, qui nullum damnum sustinére potest, et pronus est ad cleméntiam, laudábit discípulos suos, si in eos qui creditúri sibi sunt, misericórdes fúerint?")  ; Lesson 7
         (:text "Dénique post parábolam íntulit: Et ego vobis dico, Fácite vobis amícos de iníquo mammóna. Mammóna autem non Hebræórum, sed Syrórum lingua divítiæ nuncupántur, quod de iniquitáte colléctæ sint. Si ergo iníquitas bene dispensáta vértitur in justítiam; quanto magis sermo divínus, in quo nulla est iníquitas, qui et Apóstolis créditus est, si bene fúerit dispensátus, dispensatóres suos levábit in cælum?")  ; Lesson 8
         (:text "Quam ob rem séquitur: Qui fidélis est in mínimo, hoc est, in carnálibus; et in multis fidélis erit, hoc est, in spirituálibus. Qui autem in parvo iníquus est, ut non det frátribus ad uténdum, quod a Deo pro ómnibus est creátum; iste et in spirituáli pecúnia dividénda iníquus erit, ut non pro necessitáte, sed pro persónis doctrínam Dómini dívidat. Si autem, inquit, carnáles divítia, quæ labúntur, non bene dispensátis; veras æternásque divítias doctrínæ Dei quis credet vobis?")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
             :repeat "Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia:"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
             :repeat "Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
             :repeat "Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (9
     . (:lessons
        (
         (:ref "4 Reg 1:1-4"
             :text "1 Prævaricátus est autem Moab in Israël, postquam mórtuus est Achab.
2 Cecidítque Ochozías per cancéllos cœnáculi sui, quod habébat in Samaría, et ægrotávit; misítque núntios dicens ad eos: Ite, consúlite Beélzebub deum Accaron, utrum vívere queam de infirmitáte mea hac.
3 Angelus autem Dómini locútus est ad Elíam Thesbíten dicens: Surge et ascénde in occúrsum nuntiórum regis Samaríæ et dices ad eos: Numquid non est Deus in Israël, ut eátis ad consuléndum Beélzebub deum Accaron?
4 Quam ob rem hæc dicit Dóminus: De léctulo, super quem ascendísti, non descéndes, sed morte moriéris.")  ; Lesson 1
         (:ref "4 Reg 1:4-6"
             :text "4 Et ábiit Elías.
5 Reversíque sunt núntii ad Ochozíam. Qui dixit eis: Quare revérsi estis?
6 At illi respondérunt ei: vir occúrrit nobis et dixit ad nos: Ite et revertímini ad regem qui misit vos, et dicétis ei: Hæc dicit Dóminus: Numquid quia non erat Deus in Israël, mittis ut consulátur Beélzebub deus Accaron? Idcírco de léctulo, super quem ascendísti, non descéndes, sed morte moriéris.")  ; Lesson 2
         (:ref "4 Reg 1:7-10"
             :text "7 Qui dixit eis: Cujus figúræ et hábitus est vir ille, qui occúrrit vobis et locútus est verba hæc?
8 At illi dixérunt: Vir pilósus et zona pellícea accínctus rénibus. Qui ait: Elías Thesbítes est.
9 Misítque ad eum quinquagenárium príncipem et quinquagínta qui erant sub eo. Qui ascéndit ad eum sedentíque in vértice montis ait: Homo Dei, rex præcépit ut descéndas.
10 Respondénsque Elías dixit quinquagenário: Si homo Dei sum, descéndat ignis de cælo, et dévoret te et quinquagínta tuos. Descéndit ítaque ignis de cælo, et devorávit eum et quinquagínta qui erant cum eo.")  ; Lesson 3
         (:source "Sermo sancti Augustíni Epíscopi
Sermo 201 de Tempore"
             :text "In lectiónibus quæ nobis diébus istis recitántur, fratres caríssimi, frequénter admónui, ut non sequámur lítteram occidéntem, et vivificántem spíritum relinquámur. Sic enim Apóstolus ait: Líttera enim occídit, spíritus vivíficat. Si enim hoc tantum vólumus intellégere quod sonat in líttera, aut parvam, aut prope nullam ædificatiónem de divínis lectiónibus capiémus. Illa enim ómnia quæ recitántur, typus erant et imágo futurórum. In Judǽis enim figuráta, in nobis, grátia Dei donánte, compléta sunt.")  ; Lesson 4
         (:text "Beátus enim Elías typum hábuit Dómini Salvatóris. Sicut enim Elías a Judǽis persecutiónem passus est; ita et verus Elías Dóminus noster ab ipsis Judǽis reprobátus est et contémptus. Elías relíquit gentem suam; et Christus deséruit synagógam. Elías ábiit in desértum; et Christus venit in mundum. Elías in desérto corvis ministrántibus pascebátur; et Christus in desérto mundi hujus Géntium fide refícitur.")  ; Lesson 5
         (:text "Corvi enim illi qui beáto Elíæ, jubénte Dómino, ministrábant, Géntium pópulum figurábant. Proptérea et de géntium Ecclésia dícitur: Nigra sum et formósa, fília Jerúsalem. Unde est Ecclésia nigra et formósa? Nigra per natúram, formósa per grátiam. Unde nigra? Ecce in iniquitátibus concéptus sum, et in delíctis péperit me mater mea. Unde formósa? Aspérges me hyssópo, et mundábor: lavábis me, et super nivem dealbábor.")  ; Lesson 6
         (:ref "Luc 19:41-47"
             :gospel-incipit "In illo témpore: Cum appropinquáret Jesus Jerúsalem, videns civitátem flevit super illam dicens: Quia si cognovísses et tu, et quidem in hac die tua, quæ ad pacem tibi! Nunc autem abscóndita sunt ab óculis tuis. Et réliqua."
             :source "Homilía sancti Gregórii Papæ
Homilia 39 in Evangelia"
             :text "Quod a flente Dómino illa Jerosolymórum subvérsio descríbitur, quæ a Vespasiáno et Tito Románis princípibus facta est, nullus qui históriam eversiónis ejúsdem legit, ignórat. Románi étenim príncipes denuntiántur, cum dícitur: Quia vénient dies in te, et circúmdabunt te inimíci tui vallo. Hoc quoque quod ádditur: Non relínquent in te lápidem super lápidem: étiam jam ipsa ejúsdem civitátis transmigrátio testátur; quia dum nunc in eo loco constrúcta est, ubi extra portam fúerat Dóminus crucifíxus, prior illa Jerúsalem, ut dícitur, fúnditus est evérsa.")  ; Lesson 7
         (:text "Cui ex qua culpa eversiónis suæ pœna fúerit illáta, subjúngitur: Eo quod non cognóveris tempus visitatiónis tuæ. Creátor quippe hóminum per incarnatiónis suæ mystérium hanc visitáre dignátus est; sed ipsa timóris et amóris ílius recordáta non est. Unde étiam per prophétam in increpatióne cordis humáni aves cæli ad testimónium deducúntur, dum dícitur: Milvus in cælo cognóvit tempus suum, turtur et hirúndo et cicónia custodiérunt tempus advéntus sui; pópulus autem meus non cognóvit judícium Dómini.")  ; Lesson 8
         (:text "Flevit étenim prius Redémptor ruínam pérfidæ civitátis, quam ipsa sibi cívitas non cognoscébat esse ventúram. Cui a flente Dómino recte dícitur: Quia si cognovísses, et tu; subáudi, fleres; quæ modo, quæ nescis quod ímminet, exsúltas. Unde et súbditur: Et quidem in hac die tua, quæ ad pacem tibi. Cum enim carnis se voluptátibus daret, et ventúra mala non prospíceret; in die sua, quæ ad pacem esse ei póterant, habébat.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
             :repeat "Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia:"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
             :repeat "Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
             :repeat "Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (10
     . (:lessons
        (
         (:ref "4 Reg 9:29-34"
             :text "29 Anno undécimo Joram fílii Achab regnávit Ochozías super Judam,
30 venítque Jehu in Jézrahel. Porro Jézabel, intróitu ejus audíto, depínxit óculos suos stíbio et ornávit caput suum et respéxit per fenéstram
31 ingrediéntem Jehu per portam et ait: Numquid pax potest esse Zambri, qui interfécit dóminum suum?
32 Levavítque Jehu fáciem suam ad fenéstram et ait: Quæ est ista? Et inclinavérunt se ad eum duo vel tres eunúchi.
33 At ille dixit eis: Præcipitáte eam deórsum; et præcipitavérunt eam, aspersúsque est sánguine páries, et equórum úngulæ conculcavérunt eam.
34 Cumque introgréssus esset ut coméderet biberétque, ait: Ite et vidéte maledíctam illam et sepelíte eam, quia fília regis est.")  ; Lesson 1
         (:ref "4 Reg 9:35-37; 10:1-3"
             :text "35 Cumque issent ut sepelírent eam, non invenérunt nisi calváriam et pedes et summas manus.
36 Reversíque nuntiavérunt ei. Et ait Jehu: Sermo Dómini est, quem locútus est per servum suum Elíam Thesbíten dicens: In agro Jézrahel cómedent canes carnes Jézabel,
37 et erunt carnes Jézabel sicut stercus super fáciem terræ in agro Jézrahel, ita ut prætereúntes dicant: Hǽccine est illa Jézabel?
1 Erant autem Achab septuagínta fílii in Samaría. Scripsit ergo Jehu lítteras et misit in Samaríam ad optimátes civitátis et ad majóres natu et ad nutrícios Achab, dicens:
2 Statim ut accepéritis lítteras has, qui habétis fílios dómini vestri et currus et equos et civitátes firmas et arma,
3 elígite meliórem et eum qui vobis placúerit de fíliis dómini vestri et eum pónite super sólium patris sui et pugnáte pro domo dómini vestri.")  ; Lesson 2
         (:ref "4 Reg 10:4-7"
             :text "4 Timuérunt illi veheménter et dixérunt: Ecce duo reges non potuérunt stare coram eo, et quómodo nos valébimus resístere?
5 Misérunt ergo præpósiti domus et præfécti civitátis et majóres natu et nutrícii ad Jehu dicéntes: Servi tui sumus: quæcúmque jússeris faciémus, nec constituémus nobis regem: quæcúmque tibi placent, fac.
6 Rescrípsit autem eis lítteras secúndo dicens: Si mei estis et obedítis mihi, tóllite cápita filiórum dómini vestri et veníte ad me hac eádem hora cras in Jézrahel. Porro fílii regis, septuagínta viri, apud optimátes civitátis nutriebántur.
7 Cumque veníssent lítteræ ad eos, tulérunt fílios regis et occidérunt septuagínta viros et posuérunt cápita eórum in cóphinis et misérunt ad eum in Jézrahel.")  ; Lesson 3
         (:source "Sermo sancti Joánnis Chrysóstomi
Homilia 25 in Epistola ad Romanos"
             :text "Non putémus nos excusatiónem habitúros, si quando delictórum sócios invenérimus: nam istud, supplícium magis augébit. Quandóquidem et serpens magis punítus est quam múlier, quemádmodum et múlier plus quam vir. Et Jézabel majóres pœnas dedit, quam Achab víneæ raptor; ipsa quippe univérsum istud negótium texúerat, regíque lapsus occasiónem déderat. Igitur et tu quoque, si réliquis perditiónis causa fúeris, gravióra patiéris quam qui per te subvérsi sunt. Neque enim peccáre tantum in se perditiónis habet, quantum quod réliqui ad peccándum inducúntur.")  ; Lesson 4
         (:text "Itaque, si quando peccántes vidérimus, non solum non impellámus, sed et extrahámus ex ipso malítiæ bárathro, ne et aliénæ perditiónis pœnas demus. Recordémur quoque perpétuo terríbilis illíus tribunális, flúminis ígnei, vinculórum insolubílium, profundárum tenebrárum, stridórum déntium, venenosíque vermis. Sed dices: Benígnus est Deus. Ergo hæc ómnia verba sunt, et neque punítur dives ille Lázari contémptor, neque fátuæ vírgines a sponso rejiciúntur? Ergo qui Christum non pavérunt, in ignem diábolo præparátum non abíbunt? Ergo qui sórdibus est véstibus, non períbit, manus ac pedes vinctus? Qui centum denários a consérvo suo exégit, non tradétur tortóribus? Quod de mœchis dictum est, nimírum quod vermis eórum non moriétur, et ignis eórum non exstinguétur, verum non erit?")  ; Lesson 5
         (:text "Sed minátur ista tantúmmodo Deus? Utique ínquies. Et unde, dic quæso, tantam rem audes públice loqui, atque ex te ipso ferre senténtiam? Ego quippe et ex iis quæ dixit Deus, et ex iis quæ fecit, contrárium probáre pótero. Quod si propter futúra non credis, vel saltem propter ea quæ jam facta sunt, crede. Non enim certe minæ sunt et verba tantúmmodo, quæ facta sunt et in opus ipsum exiérunt. Quis ígitur totum orbem indúcto dilúvio stagnávit, ac grave illud naufrágium, omnimodámque géneris nostri perditiónem effécit? Quis deínde fúlmina illa, télaque flammántia super terram Sodomórum dimísit? Quis univérsum Ægýpti exércitum in mare demérsit? Quis synagógam Abíron combússit? Quis septuagínta illa míllia propter Davídis peccátum uno témporis moménto peste occídit? Nonne hæc ómnia et ália Deus illis íntulit?")  ; Lesson 6
         (:ref "Luc 18:9-14"
             :gospel-incipit "In illo témpore: Dixit Jesus ad quosdam, qui in se confidébant tamquam justi et aspernabántur céteros, parábolam istam: Duo hómines ascendérunt in templum ut orárent: unus pharisǽus, et alter publicánus. Et réliqua."
             :source "Homilía sancti Augustíni Epíscopi
Sermo 36 de Verbis Domini, circa medium"
             :text "Díceret saltem pharisǽus: Non sum sicut multi hómines. Quid est, céteri hómines, nisi omnes præter ipsum? Ego, inquit, justus sum, céteri peccatóres. Non sum sicut céteri hómines, injústi, raptóres, adúlteri. Et ecce tibi ex vicíno publicáno majóris tumóris occásio: Sicut, inquit, publicánus iste. Ego, inquit, solus sum: iste de céteris est. Non sum, inquit, talis, qualis iste, per justítias meas, quibus iníquus non sum.")  ; Lesson 7
         (:text "Jejúno bis in sábbato, décimas do ómnium quæ possídeo. Quid rogáverit Deum, quære in verbis ejus, nihil invénies. Ascéndit oráre: nóluit Deum rogáre, sed se laudáre. Parum est, non Deum rogáre, sed se laudáre; ínsuper et rogánti insultáre. Publicánus autem de longínquo stabat et Deo tamen ipse appropinquábat: cordis consciéntia eum removébat, píetas applicábat. Publicánus autem de longínquo stabat, sed Dóminus eum de propínquo attendébat.")  ; Lesson 8
         (:text "Excélsus enim Dóminus, et humília réspicit; excélsos autem, qualis erat ille pharisǽus, a longe cognóscit. Excélsa quidem Deus a longe cognóscit, sed non ignóscit. Adhuc audi humilitátem publicáni. Parum est, quia de longínquo stabat: nec óculos suos ad cælum levábat: ut aspicerétur, non aspiciébat; respícere sursum non audébat: premébat consciéntia, spes sublevábat. Adhuc audi: Percutiébat pectus suum. Pœnas a se ipso exigébat; proptérea Dóminus confiténti parcébat. Percutiébat pectus suum, dicens: Dómine, propítius esto mihi peccatóri. Ecce qui rogat. Quid miráris, si Deus ignóscit, quando ipse agnóscit?")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
             :repeat "Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia:"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
             :repeat "Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
             :repeat "Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (11
     . (:lessons
        (
         (:ref "4 Reg 20:1-3"
             :text "1 In diébus illis ægrotáret Ezechías usque ad mortem, et venit ad eum Isaías fílius Amos prophéta dixítque ei: Hæc dicit Dóminus Deus: Prǽcipe dómui tuæ, moriéris enim tu et non vives.
2 Qui convértit fáciem suam ad paríetem et orávit Dóminum, dicens:
3 Obsecro, Dómine: meménto, quæso, quómodo ambuláverim coram te in veritáte et in corde perfécto et quod plácitum est coram te fécerim. Flevit ítaque Ezechías fletu magno.")  ; Lesson 1
         (:ref "4 Reg 20:4-7"
             :text "4 Et ántequam egrederétur Isaías médiam partem átrii, factus est sermo Dómini ad eum, dicens:
5 Revértere et dic Ezechíæ duci pópuli mei: Hæc dicit Dóminus Deus David patris tui: Audívi oratiónem tuam et vidi lácrimas tuas et ecce sanávi te: die tértio ascéndes templum Dómini,
6 et addam diébus tuis quíndecim annos; sed et de manu regis Assyriórum liberábo te et civitátem hanc et prótegam urbem istam propter me et propter David servum meum.
7 Dixítque Isaías: Afférte massam ficórum. Quam cum attulíssent et posuíssent super ulcus ejus, curátus est.")  ; Lesson 2
         (:ref "4 Reg 20:8-11"
             :text "8 Díxerat autem Ezechías ad Isaíam: Quod erit signum quia Dóminus me sanábit, et quia ascensúrus sum die tértia templum Dómini?
9 Cui ait Isaías: Hoc erit signum a Dómino, quod factúrus sit Dóminus sermónem quem locútus est: vis ut ascéndat umbra decem líneis, an ut revertátur tótidem grádibus?
10 Et ait Ezechías: Fácile est umbram créscere decem líneis, nec hoc volo ut fiat; sed ut revertátur retrórsum decem grádibus.
11 Invocávit ítaque Isaías prophéta Dóminum, et redúxit umbram per líneas, quibus jam descénderat in horológio Achaz, retrórsum decem grádibus.")  ; Lesson 3
         (:source "Ex Expositióne sancti Hierónymi Presbýteri in Isaíam Prophétam
Lib. 11 in Isaíæ cap. 38"
             :text "Ne elevarétur cor Ezechíæ post incredíbiles triúmphos et de média captivitáte victóriam, infirmitáte córporis sui visitátur, et audit se esse moritúrum; ut convérsus ad Dóminum flectat senténtiam ejus. Quod quidem et in Jona prophéta légimus, et in comminatiónibus contra David: quæ dicúntur futúra, nec facta sunt, non Deo mutánte senténtiam, sed provocánte humánum genus ad notítiam sui. Dóminus enim pœ́nitens est super malítiis. Convertítque Ezechías fáciem suam ad paríetem, quia ad templum ire non póterat. Ad paríetem autem templi, juxta quod Sálomon palátium exstrúxerat; vel absolúte ad paríetem, ne lácrimas suas assidéntibus ostentáre viderétur.")  ; Lesson 4
         (:text "Audiénsque se esse moritúrum, non precátur vitam et annos plúrimos, sed in Dei judício, quid velit præstáre, dimíttit. Nóverat enim idcírco Deo placuísse Salomónem, quod annos vitæ non petíerit amplióres; sed itúrus ad Dóminum narrat ópera sua, quómodo ambuláverit coram eo in veritáte et in corde perfécto. Felix consciéntia, quæ afflictiónis témpore bonórum óperum recordátur. Beáti enim mundo corde: quóniam ipsi Deum vidébunt. Et quómodo álibi scríbitur: Quis gloriábitur purum habére se cor? Quod ita sólvitur: perfectiónem cordis in eo nunc dici, quod idóla destrúxerit, templi valvas aperúerit, serpéntem ǽneum comminúerit, et cétera fécerit quæ Scriptúra commémorat.")  ; Lesson 5
         (:text "Flevit autem fletu magno, propter promissiónem Dómini ad David, quam vidébat in sua morte peritúram. Eo enim témpore Ezechías fílios non habébat; nam post mortem ejus Manásses cum duódecim esset annórum, regnáre cœpit in Judǽa: ex quo perspícuum est, post tértium annum concéssæ vitæ Manássen esse generátum. Ergo iste omnis est fletus, quod desperábat Christum de suo sémine nascitúrum. Alii ásserunt, quamvis sanctos viros morte terréri, propter incértum judícii et ignoratiónem senténtiæ Dei, quam sedem habitúri sint.")  ; Lesson 6
         (:ref "Marc 7:31-37"
             :gospel-incipit "In illo témpore: Exiens Jesus de fínibus Tyri venit per Sidónem ad mare Galilǽæ inter médios fines Decapóleos. Et réliqua."
             :source "Homilía sancti Gregórii Papæ
Homilia 10, liber 1 in Ezech., ante medium"
             :text "Quid est quod creátor ómnium Deus, cum surdum et mutum sanáre voluísset, in aures illíus suos dígitos misit, et éxspuens linguam ejus tétigit? Quid per dígitos Redemptóris, nisi dona Sancti Spíritus designántur? Unde cum in álio loco ejecísset dæmónium, dixit: Si in dígito Dei eício dæmónia, profécto pervénit in vos regnum Dei. Qua de re per Evangelístam álium dixísse descríbitur: Si ego in Spíritu Dei eício dǽmones, ígitur pervénit in vos regnum Dei. Ex quo utróque loco collígitur, quia dígitus Spíritus vocátur. Dígitos ergo in aurículas míttere, est per dona Spíritus Sancti mentem surdi ad obediéndum aperíre.")  ; Lesson 7
         (:text "Quid est vero, quod éxspuens linguam ejus tétigit? Salíva nobis est ex ore Redemptóris, accépta sapiéntia in elóquio divíno. Salíva quippe ex cápite défluit in ore. Ea ergo sapiéntia, quæ ipse est, dum lingua nostra tángitur, mox ad prædicatiónis verba formátur. Qui suspíciens in cælum, ingémuit: non quod ipse necessárium gémitum habéret, qui dabat quod postulábat; sed nos ad eum gémere, qui cælo prǽsidet, dócuit: ut et aures nostræ per donum Spíritus Sancti aperíri, et lingua per salívam oris, id est, per sciéntiam divínæ locutiónis, solvi débeat ad verba prædicatiónis.")  ; Lesson 8
         (:text "Cui mox, Ephphétha, id est, Adaperíre dícitur: et statim apértæ sunt aures ejus, et solútum est vínculum linguæ ejus. Qua in re notándum est, quia propter clausas aures dictum est, Adaperíre. Sed cui aures cordis ad obediéndum apértæ fúerint, ex subsequénti procul dúbio étiam linguæ ejus vínculum sólvitur; ut bona quæ ipse fécerit, étiam faciénda áliis loquátur. Ubi bene ádditur: Et loquebátur recte. Ille enim recte lóquitur, qui prius obediéndo fécerit quæ loquéndo ádmonet esse faciénda.")  ; Lesson 9
         )
        :responsories
        (
         (:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
             :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
             :verse "Convertímini ad eum in toto corde vestro, et auférte deos aliénos de médio vestri.")  ; R1
         (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
             :repeat "Et unxit me unctióne misericórdiæ suæ."
             :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me.")  ; R2
         (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
             :repeat "Ipse me erípiet de mánibus inimicórum meórum."
             :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
             :gloria t)  ; R3
         (:respond "Percússit Saul mille, et David decem míllia:"
             :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
             :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?")  ; R4
         (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
             :repeat "Ubi cecidérunt fortes Israël."
             :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat.")  ; R5
         (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
             :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
             :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
             :gloria t)  ; R6
         (:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
             :repeat "Et malum coram te feci."
             :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi.")  ; R7
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (12
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Luc 10:23-37"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis: Beáti óculi qui vident quæ vos vidétis; dico enim vobis quod multi prophétæ et reges voluérunt vidére quæ vos vidétis, et non vidérunt. Et réliqua."
             :source "Homilía sancti Bedæ Venerábilis Presbýteri
Liber 3, cap. 43 in Lucæ 10"
             :text "Non óculi scribárum et pharisæórum, qui corpus tantum Dómini vidére; sed illi beáti óculi, qui ejus possunt cognóscere sacraménta, de quibus dícitur: Et revelásti ea párvulis. Beáti óculi parvulórum, quibus et se et Patrem Fílius reveláre dignátur. Abraham exsultávit ut vidéret diem Christi; et vidit, et gavísus est. Isaías quoque, et Michǽas, et multi álii prophétæ vidérunt glóriam Dómini, qui et proptérea Vidéntes sunt appelláti; sed hi omnes, a longe aspiciéntes et salutántes, per spéculum et in ænígmate vidérunt.")  ; Lesson 7
         (:text "Apóstoli autem, in præsentiárum habéntes Dóminum, convescentésque ei, et quæcúmque voluíssent interrogándo discéntes, nequáquam per Angelos aut várias visiónum spécies opus habébant docéri. Quos vero Lucas multos prophétas et reges dicit, Matthǽus apértius prophétas et justos appéllat. Ipse sunt enim reges magni; quia tentatiónum suárum mótibus non consentiéndo succúmbere, sed regéndo præésse novérunt.")  ; Lesson 8
         (:text "Et ecce quidam legisperítus surréxit, tentans eum et dicens: Magíster, quid faciéndo vitam ætérnam possidébo? Legisperítus, qui de vita ætérna Dóminum tentans intérrogat, occasiónem, ut reor, tentándi de ipsis Dómini sermónibus sumpsit, ubi ait: Gaudéte autem quod nómina vestra scripta sunt in cælis. Sed ipsa sua tentatióne declárat quam vera sit illa Dómini conféssio, qua Patri lóquitur: Quod abscondísti hæc a sapiéntibus, et prudéntibus, et revelásti ea párvulis.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (13
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Luc 17:11-19"
             :gospel-incipit "In illo témpore: Dum iret Jesus in Jerúsalem, transíbat per médiam Samaríam et Galilǽam. Et cum ingrederétur quoddam castéllum, occurrérunt ei decem viri leprósi. Et réliqua."
             :source "Homilía sancti Augustíni Epíscopi
Lib. 2 quæst. Evang. cap. 40"
             :text "De decem leprósis, quos Dóminus ita mundávit, cum ait: Ite, osténdite vos sacerdótibus; quæri potest, cur eos ad sacerdótes míserit, ut cum irent, mundaréntur. Nullum enim eórum, quibus hæc corporália benefícia prǽstitit, invenítur misísse ad sacerdótes, nisi leprósos. Nam et illum a lepra mundáverat, cui dixit: Vade, osténde te sacerdótibus, et offer pro te sacrifícium, quod præcépit Móyses, in testimónium illis. Quæréndum ígitur est, quid ipsa lepra signíficet: non enim sanáti, sed mundáti dicúntur, qui ea caruérunt. Colóris quippe vítium est, non valetúdinis, aut integritátis sénsuum atque membrórum.")  ; Lesson 7
         (:text "Leprósi ergo non absúrde intélligi possunt, qui sciéntiam veræ fídei non habéntes, várias doctrínas profiténtur erróris. Non enim abscóndunt imperítiam suam; sed pro summa perítia próferunt in lucem, et jactántia sermónis osténtant. Nulla porro falsa doctrína est, quæ non áliqua vera intermísceat. Vera ergo falsis inordináte permíxta, in una disputatióne vel narratióne hóminis, tamquam in uníus córporis colóre apparéntia, signíficant lepram, tamquam veris falsísque colórum variántem atque maculántem.")  ; Lesson 8
         (:text "Hi autem tam vitándi sunt Ecclésiæ, ut, si fíeri potest, lóngius remóti, magno clamóre Christum interpéllent; sicut isti decem stetérunt a longe, et levavérunt vocem, dicéntes: Jesu præcéptor, miserére nostri. Nam et quod præceptórem vocant, quo nómine néscio utrum quisquam Dóminum interpelláverit pro medicína corporáli; satis puto significáre, lepram falsam esse doctrínam, quam bonus præcéptor abstérgit.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (14
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Matt 6:24-33"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis: Nemo potest duóbus dóminis servíre. Et réliqua."
             :source "Homilía sancti Augustíni Epíscopi
Lib. 2 de Sermone Dómini in monte, cap. 14"
             :text "Nemo potest duóbus dóminis servíre. Ad hanc ipsam intentiónem referéndum est quod consequénter expónit, dicens: Aut enim unum ódio habébit, et álterum díliget; aut álterum patiétur, et álterum contémnet. Quæ verba diligénter consideránda sunt: nam, qui sint duo dómini, deínceps osténdit, cum dicit: Non potéstis Deo servíre, et mammónæ. Mammóna apud Hebrǽos divítiæ appellári dicúntur. Cóngruit et Púnicum nomen; nam lucrum Púnice mammon dícitur.")  ; Lesson 7
         (:text "Sed qui servit mammónæ, illi útique servit, qui rebus istis terrénis mérito suæ perversitátis præpósitus, magistrátus hujus sǽculi a Dómino dícitur. Aut enim unum ódio habébit homo, et álterum díliget, id est, Deum; aut álterum patiétur, et álterum contémnet. Patiétur enim durum et perniciósum dóminum, quisquis servit mammónæ; sua enim cupiditáte implicátus, súbditur diábolo, et non eum díligit. Quis enim est qui díligat diábolum? sed tamen pátitur.")  ; Lesson 8
         (:text "Ideo, inquit, dico vobis, non habére sollicitúdinem ánimæ vestræ quid edátis, neque córpori vestro quid induátis; ne forte, quamvis jam supérflua non quærántur, propter ipsa necessária cor duplicétur, et ad ipsa conquirénda, nostra detorqueátur inténtio, cum áliquid quasi misericórditer operámur: id est, ut cum consúlere alícui vidéri vólumus, nostrum emoluméntum ibi pótius, quam illíus utilitátem attendámus; et ídeo nobis non videámur peccáre, quia non supérflua, sed necessária sunt, quæ cónsequi vólumus.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (15
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Luc 7:11-16"
             :gospel-incipit "In illo témpore: Ibat Jesus in civitátem, quæ vocátur Naim; et ibant cum eo discípuli ejus, et turba copiósa. Et réliqua."
             :source "Homilía sancti Augustíni Epíscopi
Sermo 44 de verbis Domini, circa initium"
             :text "De júvene illo resuscitáto gavísa est mater vídua; de homínibus in spíritu cotídie suscitátis gaudet mater Ecclésia. Ille quidem mórtuus erat córpore; illi autem mente. Illíus mors visíbilis visibíliter plangebátur; illórum mors invisíbilis nec quærebátur, nec videbátur. Quæsívit ille, qui nóverat mórtuos. Ille solus nóverat mórtuos, qui póterat fácere vivos. Nisi enim ad mórtuos suscitándos venísset, Apóstolus non díceret: Surge, qui dormis, et exsúrge a mórtuis, et illuminábit te Christus.")  ; Lesson 7
         (:text "Tres autem mórtuos invenímus a Dómino resuscitátos visibíliter, míllia invisibíliter. Quot autem mórtuos visibíliter suscitáverit, quis novit? Non enim ómnia, quæ fecit, scripta sunt. Joánnes hoc dixit: Multa ália fecit Jesus, quæ si scripta essent, árbitror totum mundum non posse libros cápere. Multi ergo sunt álii sine dúbio suscitáti, sed non tres frustra commemoráti. Dóminus enim noster Jesus Christus ea quæ faciébat corporáliter, étiam spiritáliter volébat intélligi. Neque enim tantum mirácula propter mirácula faciébat; sed ut illa, quæ faciébat, mira essent vidéntibus, vera essent intelligéntibus.")  ; Lesson 8
         (:text "Quemádmodum qui videt lítteras in códice óptime scripto, et non novit légere, laudat quidem antiquárii manum, admírans ápicum pulchritúdinem; sed quid sibi velint, quid índicent illi ápices, nescit, et est óculis laudátor, mente non cógnitor. Alius autem et laudat artifícium, et capit intelléctum: ille útique, qui non solum vidére quod commúne est ómnibus, potest, sed étiam légere; quod qui non dídicit, non potest. Ita qui vidérunt Christi mirácula, et non intellexérunt quid sibi vellent, et quid intelligéntibus quodámmodo innúerent, miráti sunt tantum quia facta sunt; álii vero et facta miráti, et intellécta assecúti. Tales nos in schola Christi esse debémus.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         (:respond "Duo Séraphim clamábant alter ad álterum:"
             :repeat "Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus."
             :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt."
             :gloria t)  ; R8
         )))

    (16
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Luc 14:1-11"
             :gospel-incipit "In illo témpore: Cum intráret Jesus in domum cujúsdam príncipis pharisæórum sábbato manducáre panem, et ipsi observábant eum. Et ecce homo quidam hydrópicus erat ante illum. Et réliqua."
             :source "Homilía sancti Ambrósii Epíscopi
Liber 7 in Lucæ cap. 14"
             :text "Curátur hydrópicus, in quo fluxus carnis exúberans ánimæ gravábat offícia, spíritus exstinguébat ardórem. Deínde docétur humílitas, dum in illo convívio nuptiáli appeténtia loci superióris arcétur; cleménter tamen, ut persuásio humanitátis aspertitátem coërcitiónis exclúderet, rátio profíceret ad persuasiónis efféctum, et corréctio emendáret afféctum. Huic quasi próximo límine humánitas copulátur: quæ ita Domínicæ senténtiæ definitióne distínguitur, si in páuperes et débiles conferátur: nam hospitálem esse remuneratúris, afféctus avarítiæ est.")  ; Lesson 7
         (:text "Postrémo jam quasi eméritæ milítiæ viro contemnendárum stipéndium præscríbitur facultátum: quod neque ille, qui stúdiis inténtus inferióribus possessiónes sibi terrénas coémit, regnum cæli possit adipísci, cum Dóminus dicat: Vende ómnia tua, et séquere me: nec ille, qui emit boves, cum Eliséus occíderit, et pópulo divíserit quos habébat: et ille qui duxit uxórem, cógitet quæ mundi sunt, non quæ Dei. Non quo conjúgium reprehendátur, sed quia ad majórem honórem vocétur intégritas: quóniam múlier innúpta et vídua cógitat quæ sunt Dómini, ut sit sancta córpore et spíritu.")  ; Lesson 8
         (:text "Sed ut in grátiam, ut supra cum víduis, ita nunc étiam cum conjúgibus revertámur: non refúgimus opiniónem, quam sequúntur pleríque, ut tria génera hóminum a consórtio magnæ illíus cœnæ æstimémus exclúdi: Gentílium, Judæórum, Hæreticórum. Et ídeo Apóstolus avarítiam dicit esse fugiéndam; ne impedíti more Gentíli, iniquitáte, malítia, impudicítia, avarítia, ad regnum Christi perveníre nequeámus. Omnis enim immúndus aut avárus, quod est idolórum sérvitus, non habet hereditátem in regno Christi et Dei.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    (17
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Matt 22:34-46"
             :gospel-incipit "In illo témpore: Accessérunt ad Jesum pharisǽi, et interrogávit eum unus ex eis legis doctor tentans eum: Magíster, quod est mandátum magnum in lege? Et réliqua."
             :source "Homilía sancti Joánnis Chrysóstomi
Homilia 72 in Matthæum"
             :text "Sadducǽis confúsis, pharisǽi rursus aggrediúntur; cumque quiéscere oportéret, decertáre voluérunt: et legis perítiam profiténtem præmíttunt, non díscere, sed tentáre cupiéntes; ac ita intérrogant: Quodnam primum mandátum in lege sit. Nam cum primum illud sit, Díliges Dóminum Deum tuum: putántes causas sibi allatúrum ad mandátum hoc corrigéndum, áliquid addéndo, quóniam Deum se faciébat, hoc modo intérrogant. Quid ígitur Christus? Ut osténdat idcírco ad hæc eos devenísse, quia nulla in eis esset cáritas, sed invídiæ livóre tabéscerent: Díliges, inquit, Dóminum Deum tuum: hoc primum et magnum mandátum est. Secúndum autem símile huic: Díliges próximum tuum sicut teípsum.")  ; Lesson 7
         (:text "Quam ob rem símile est huic?  Quóniam hoc illud indúcit, et ab illo rursus munítur. Quicúmque enim male agit, ódio habet lucem, et non venit ad lucem. Et rursus: Dixit insípiens in corde suo, Non est Deus. Deínde séquitur: Corrúpti sunt, et abominábiles facti sunt in stúdiis suis. Et íterum: Radix ómnium malórum avarítia est; quam quidam appeténtes, erravérunt a fide. Et, Qui díligit me, mandáta mea servábit: quorum caput et radix est: Díliges Dóminum Deum tuum, et próximum tuum sicut teípsum.")  ; Lesson 8
         (:text "Si ergo dilígere Deum, dilígere próximum est: (nam si díligis me, o Petre, inquit, pasce oves meas) si étiam diléctio próximi facit ut mandáta custódias: mérito ait in his totam legem et prophétas pendére. Et quemádmodum in superióribus, cum de resurrectióne interrogarétur, plus dócuit quam tentántes petébant; sic in hoc loco de primo interrogátus mandáto, secúndum étiam non valde quam primum inférius, sponte áttulit; secúndum enim est primo símile. Ita occúlte insinuávit, ódio illos ad quæréndum incitári. Cáritas enim, inquit, non æmulátur.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    (18
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Matt 9:1-8"
             :gospel-incipit "In illo témpore: Ascéndens Jesus in navículam transfretávit et venit in civitátem suam. Et réliqua."
             :source "Homilía sancti Petri Chrysólogi
Sermo 50"
             :text "Christum in humánis áctibus divína gessísse mystéria, et in rebus visibílibus invisibília exercuísse negótia, léctio hodiérna monstrávit. Ascéndit, inquit, in navículam, et transfretávit, et venit in civitátem suam. Nonne ipse est, qui, fugátis flúctibus, maris profúnda nudávit, ut Israëlíticus pópulus inter stupéntes undas sicco vestígio velut móntium cóncava pertransíret? Nonne hic est, qui Petri pédibus marínos vórtices inclinávit, ut iter líquidum humánis gréssibus sólidum præbéret obséquium.")  ; Lesson 7
         (:text "Et quid est, quod ipse sibi sic maris dénegat servitútem, ut brevíssimi lacus tránsitum sub mercéde náutica transfretáret? Ascéndit, inquit, in navículam, et transfretávit. Et quid mirum, fratres? Christus venit suscípere infirmitátes nostras, et suas nobis conférre virtútes; humána quǽrere, præstáre divína; accípere injúrias, réddere dignitátes; ferre tǽdia, reférre sanitátes: quia médicus, qui non fert infirmitátes, curáre nescit; et qui non fúerit cum infírmo infirmátus, infírmo non potest conférre sanitátem.")  ; Lesson 8
         (:text "Christus ergo, si in suis mansísset virtútibus, commúne cum homínibus nil habéret; et nisi implésset carnis órdinem, carnis in illo esset otiósa suscéptio. Ascéndit, inquit, in navículam, et transfretávit, et venit in civitátem suam. Creátor rerum orbis Dóminus, posteáquam se propter nos nostra angustávit in carne, cœpit habére humánam pátriam, cœpit civitátis Judáicæ esse civis, paréntes habére cœpit paréntum ómnium ipse parens; ut invitáret amor, attráheret cáritas, vincíret afféctio, suadéret humánitas, quos fúgerat dominátio, metus dispérserat, fécerat vis potestátis extórres.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    (19
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Matt 22:1-14"
             :gospel-incipit "In illo témpore: Loquebátur Jesus princípibus sacerdótum et pharisǽis in parábolis, dicens: Símile factum est regnum cælórum hómini regi, qui fecit núptias fílio suo. Et réliqua."
             :source "Homilía sancti Gregórii Papæ
Homilia 38 in Evangelia, post initium"
             :text "Sæpe jam me dixísse mémini, quod plerúmque in sancto Evangélio regnum cælórum præsens Ecclésia nominátur: congregátio quippe justórum, regnum cælórum dícitur. Quia enim per prophétam Dóminus dicit: Cælum mihi sedes est; et Sálomon ait: Anima justi sedes sapiéntiæ; Paulus étiam dicit Christum Dei virtútem, et Dei sapiéntiam: líquido collígere debémus, quia si Deus sapiéntia, ánima autem justi, sedes sapiéntiæ, dum cælum dícitur sedes Dei, cælum ergo est ánima justi. Hinc per Psalmístam de sanctis prædicatóribus dícitur: Cæli enárrant glóriam Dei.")  ; Lesson 7
         (:text "Regnum ergo cælórum est Ecclésia justórum: quia dum eórum corda in terra nil ámbiunt, per hoc quod ad supérna suspírant, jam in eis Dóminus quasi in cæléstibus regnat. Dicátur ergo: Símile est regnum cælórum hómini regi, qui fecit núptias fílio suo. Jam intélligit cáritas vestra, quis est iste Rex, Regis fílii pater: ille nimírum, cui Psalmísta ait: Deus judícium tuum Regi da, et justítiam tuam fílio Regis. Qui fecit núptias fílio suo. Tunc enim Deus Pater Deo Fílio suo núptias fecit, quando hunc in útero Vírginis humánæ natúræ conjúnxit, quando Deum ante sǽcula fíeri vóluit hóminem in fine sæculórum.")  ; Lesson 8
         (:text "Sed quia ex duábus persónis fíeri solet ista nuptiális conjúnctio; absit hoc ab intelléctibus nostris, ut persónam Dei et hóminis Redemptóris nostri Jesu Christi, ex duábus persónis credámus unítam. Ex duábus quippe atque in duábus hunc natúris exsístere dícimus; sed ex duábus persónis compósitum credi, ut nefas vitámus. Apértius ergo atque secúrius dici potest, quia in hoc Pater Regi Fílio núptias fecit, quo ei per incarnatiónis mystérium sanctam Ecclésiam sociávit. Uterus autem Genitrícis Vírginis, hujus sponsi thálamus fuit. Unde et Psalmísta dicit: In sole pósuit tabernáculum suum, et ipse tamquam sponsus procédens de thálamo suo.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    (20
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Joannes 4:46-53"
             :gospel-incipit "In illo témpore: Erat quidam régulus, cujus fílius infirmabátur Caphárnaum. Et réliqua."
             :source "Homilía sancti Gregórii Papæ
Homilia 28 in Evangelia"
             :text "Léctio sancti Evangélii, quam modo, fratres, audístis, expositióne non índiget: sed ne hanc táciti præteriísse videámur, exhortándo pótius quam exponéndo in ea áliquid loquámur. Hoc autem nobis solúmmodo de expositióne vídeo esse requiréndum, cur is, qui ad salútem fílio peténdam vénerat, audívit: Nisi signa et prodígia vidéritis, non créditis. Qui enim salútem fílio quærébat, proculdúbio credébat; neque enim ab eo quǽreret salútem, quem non créderet Salvatórem. Quare ergo dícitur: Nisi signa et prodígia vidéritis, non créditis: qui ante crédidit, quam signa vidéret?")  ; Lesson 7
         (:text "Sed mementóte quid pétiit; et apérte cognoscétis, quia in fide dubitávit. Popóscit namque, ut descénderet et sanáret fílium ejus. Corporálem ergo præséntiam Dómini quærébat, qui per spíritum nusquam déerat. Minus ítaque in illum crédidit, quem non putávit posse salútem dare, nisi præsens esset et córpore. Si enim perfécte credidísset, proculdúbio sciret, quia non esset locus ubi non esset Deus.")  ; Lesson 8
         (:text "Ex magna ergo parte diffísus est, qui virtútem non dedit majestáti, sed præséntiæ corporáli. Salútem ítaque fílio pétiit, et tamen in fide dubitávit; quia eum ad quem vénerat, et poténtem ad curándum crédidit, et tamen moriénti fílio esse abséntem putávit. Sed Dóminus, qui rogátur ut vadat, quia non desit ubi invitátur, índicat: solo jussu salútem réddidit, qui voluntáte ómnia creávit.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    (21
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Matt 18:23-35"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis parábolam hanc: Assimilátum est regnum cælórum hómini regi, qui vóluit ratiónem pónere cum servis suis. Et réliqua."
             :source "Homilía sancti Hierónymi Presbýteri
Lib. 3 Comm. in cap. 18 Matth."
             :text "Familiáre est Syris, et máxime Palæstínis, ad omnem sermónem suum parábolas júngere: ut quod per simplex præcéptum tenéri ab auditóribus non potest, per similitúdinem exempláque teneátur. Præcépit ítaque Dóminus Petro sub comparatióne regis et dómini, et servi, qui débitor decem míllium talentórum a dómino rogans véniam impetráverat, ut ipse quoque dimíttat consérvis suis minóra peccántibus. Si enim ille rex et dóminus servo debitóri decem míllia talentórum tam fácile dimísit: quanto magis servi consérvis suis debent minóra dimíttere?")  ; Lesson 7
         (:text "Quod ut maniféstius fiat, dicámus sub exémplo. Si quis nostrum commíserit adultérium, homicídium, sacrilégium; majóra crímina decem míllium talentórum rogántibus dimittúntur, si et ipsi dimíttant minóra peccántibus. Sin autem ob factam contuméliam simus implacábiles, et propter amárum verbum pérpetes habeámus discórdias; nonne nobis vidémur recte redigéndi in cárcerem, et sub exémplo óperis nostri hoc ágere, ut majórum nobis delictórum vénia non relaxétur?")  ; Lesson 8
         (:text "Sic et Pater meus cæléstis fáciet vobis, si non remiséritis unusquísque fratri suo de córdibus vestris. Formidolósa senténtia, si juxta nostram mentem senténtia Dei fléctitur, atque mutátur: si parva frátribus non dimíttimus, magna nobis a Deo non dimitténtur. Et quia potest unusquísque dícere: Nihil hábeo contra eum, ipse novit, habet Deum júdicem; non mihi curæ est quid velit ágere, ego ignóvi ei: confírmat senténtiam suam, et omnem simulatiónem fictæ pacis evértit, dicens: Si non remiséritis unusquísque fratri suo de córdibus vestris.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    (22
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Matt 22:15-21"
             :gospel-incipit "In illo témpore: Abeúntes pharisǽi consílium iniérunt ut cáperent Jesum in sermóne. Et réliqua."
             :source "Homilía sancti Hilárii Epíscopi
Comment. in Matth. can. 23"
             :text "Frequénter pharisǽi commovéntur, et occasiónem insimulándi eum habére ex prætéritis non possunt. Cádere enim vítium in gesta ejus et dicta non póterat; sed de malítiæ afféctu, in omnem se inquisitiónem reperiúndæ accusatiónis exténdunt. Namque a sǽculi vítiis, atque a superstitiónibus humanárum religiónum, univérsos ad spem regni cæléstis vocábat. Igitur an violáret sǽculi potestátem, de propósitæ interrogatiónis condicióne perténtant; an vidélicet reddi tribútum Cǽsari oportéret.")  ; Lesson 7
         (:text "Qui intérna cognitiónum secréta cognóscens (Deus enim nihil eórum quæ intra hóminem sunt abscónsa, non speculátur) afférri sibi denárium jussit, et quæsívit cujus et inscríptio esset et forma. Pharisǽi respondérunt: Cǽsaris eam esse. Quibus ait: Cǽsari redhibénda esse quæ Cǽsaris sunt; Deo autem reddénda esse, quæ Dei sunt. O plenam miráculi responsiónem, et perféctam dicti cæléstis absolutiónem! Ita ómnia inter contémptum sǽculi, et contuméliam lædéndi Cǽsaris temperávit, ut curis ómnibus et offíciis humánis devótas Deo mentes absólveret, cum Cǽsari quæ ejus essent, reddénda decérnit.")  ; Lesson 8
         (:text "Si enim nihil ejus penes nos reséderit, conditióne reddéndi ei quæ sua sunt, non tenébimur. Porro autem si rebus illíus incubámus, si jure potestátis ejus útimur, et nos tamquam mercenários aliéni patrimónii procuratióni subjícimus; extra querélam injúriæ est, Cǽsari redhibéri quod Cǽsaris est, Deo autem quæ ejus sunt própria, réddere nos oportére, corpus, ánimam, voluntátem. Ab eo enim hæc profécta atque aucta retinémus: proínde condígnum est, ut ei se totum reddant, cui debére se récolunt et oríginem et proféctum.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    (23
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Matt 9:18-26"
             :gospel-incipit "In illo témpore: Loquénte Jesu ad turbas, ecce princeps unus accéssit et adorábat eum dicens: Dómine, fília mea modo defúncta est. Et réliqua."
             :source "Homilía sancti Hierónymi Presbýteri
Liber 1 Comment. in cap. 9 Matthæi"
             :text "Octávum signum est, in quo princeps suscitári póstulat fíliam suam, nolens de mystério veræ circumcisiónis exclúdi: sed subíntrat múlier sánguine fluens, et octávo sanátur loco; ut príncipis fília de hoc exclúsa número, véniat ad nonum, juxta illud quod in Psalmis dícitur: Æthiópia prævéniet manus ejus Deo; et, Cum intráverit plenitúdo géntium, tunc omnis Israël salvus fiet.")  ; Lesson 7
         (:text "Et ecce múlier, quæ sánguinis fluxum patiebátur duódecim annis, accéssit retro, et tétigit fímbriam vestiménti ejus. In Evangélio secúndum Lucam scríbitur, quod príncipis fília duódecim annos habéret ætátis. Nota ergo, quod eo témpore hæc múlier, id est, Géntium pópulus cœ́perit ægrotáre, quo genus Judæórum credíderat. Nisi enim ex comparatióne virtútum, vítium non osténditur.")  ; Lesson 8
         (:text "Hæc autem múlier sánguine fluens, non in domo, non in urbe accédit ad Dóminum, quia juxta legem úrbibus excludebátur; sed in itínere, ambulánte Dómino; ut, dum pergit ad áliam, ália curarétur. Unde dicunt et Apóstoli: Vobis quidem oportébat prædicári verbum Dei: sed quóniam vos judicástis indígnos salúte, transgrédimur ad gentes.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    (24
     . (:lessons
        (
         nil  ; Lesson 1 (not in file)
         nil  ; Lesson 2 (not in file)
         nil  ; Lesson 3 (not in file)
         nil  ; Lesson 4 (not in file)
         nil  ; Lesson 5 (not in file)
         nil  ; Lesson 6 (not in file)
         (:ref "Matt 24:15-35"
             :gospel-incipit "In illo témpore: Dixit Jesus discípulis suis: Cum vidéritis abominatiónem desolatiónis, quæ dicta est a Daniéle prophéta, stantem in loco sancto: qui legit, intéllegat. Et réliqua."
             :source "Homilía sancti Hierónymi Presbýteri
Liber 4 Comment. in cap. 24 Matthæi"
             :text "Quando ad intellegéntiam provocámur, mýsticum monstrátur esse quod dictum est. Légimus autem in Daniéle hoc modo: Et in dimídio hebdómadis auferétur sacrifícium et libámina; et in templo abominátio desolatiónum erit, usque ad consummatiónem témporis, et consummátio dábitur super solitúdinem. De hoc et Apóstolus lóquitur, quod homo iniquitátis, et adversárius elevándus sit contra omne quod dícitur Deus et cólitur; ita ut áudeat stare in templo Dei, et osténdere quod ipse sit Deus: cujus advéntus secúndum operatiónem sátanæ déstruat eos, et ad Dei solitúdinem rédigat, qui se suscéperint.")  ; Lesson 7
         (:text "Potest autem simpliciter aut de Antichristo accipi, aut de imagine Cæsaris, quam Pilátus pósuit in templo, aut de Hadriáni equestri státua, quæ in ipso sancto sanctórum loco usque in præséntem diem stetit. Abominátio quoque secúndum veterem Scripturam idolum nuncupátur; et idcirco additur, desolatiónis, quod in desolato templo atque destructo idolum positum sit.")  ; Lesson 8
         (:text "Abominátio desolatiónis intelligi potest et omne dogma perversum: quod cum vidérimus stare in loco sancto, hoc est in Ecclésia, et se osténdere Deum, debémus fugere de Judæa ad montes, hoc est, dimissa occidénte littera, et Judáica pravitáte, appropinquare móntibus ætérnis, de quibus illúminat mirabíliter Deus; et esse in tecto et in dómate, quo non possint igníta diaboli jácula perveníre, nec descéndere et tóllere aliquid de domo conversatiónis prístinæ, nec quærere quæ retrórsum sunt, sed magis sérere in agro spiritualium Scripturárum, ut fructus capiámus ex eo; nec tóllere álteram túnicam, quam Apóstoli habére prohibentur.")  ; Lesson 9
         )
        :responsories
        (
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
         )))

    )
  "Dominical Matins lessons and responsories for Sundays after Pentecost.
Each entry is (WEEK . (:lessons (L1..L9) :responsories (R1..R8))).
Lessons are plists with keys :ref :source :gospel-incipit :text.
Responsories are plists with keys :respond :repeat :verse :gloria.")

;;; ──────────────────────────────────────────────────────────────────────────
;;; Scriptura occurrens: month-week indexed Matins data (Aug–Nov)
;;
;; Fixed scripture cycle for Per Annum months. Indexed by month-week key
;; (e.g. "081" = August week 1). Contains:
;; - :scripture-refs — Nocturn I references (fetched via bcp-fetcher)
;; - :lessons — Nocturn II patristic commentaries (L4-L6)
;; - :responsories — R1-R8 for all three nocturns
;; Extracted from Divinum Officium Tempora month-week Sunday files.

(defconst bcp-roman-tempora--scriptura-occurrens
  '(
    ("081" . (:scripture-refs ("Prov 1:1-6" "Prov 1:7-14" "Prov 1:15-19")
     :lessons ((:source "Ex Tractatu sancti Ambrósii Epíscopi in Psalmum centésimum décimum octavum
Sermo 5, n. 36-37" :text "Inítium esse sapiéntiæ timórem Dómini, dicit prophéta. Quid est autem inítium sapiéntiæ, nisi sǽculo renuntiáre? Quia sápere sæculária, stultítia est. Dénique sapiéntiam hujus mundi, stultítiam esse apud Deum, Apóstolus dicit. Sed et ipse timor Dómini, nisi secúndum sciéntiam sit, nihil prodest, immo obest plúrimum. Síquidem Judǽi habent zelum Dei; sed quia non habent secúndum sciéntiam, in ipso zelo et timóre majórem cóntrahunt divinitátis offénsam. Quod circumcídunt infántulos suos, quod sábbata custódiunt, timórem Dei habent; sed quia nesciunt legem spiritálem esse, circumcídunt corpus, non cor suum.")
     (:source nil :text "Et quid de Judǽis dico? Sunt étiam in nobis qui habent timórem Dei, sed non secúndum sciéntiam, statuéntes durióra præcépta, quæ non possit humána condítio sustinére. Timor in eo est, quia vidéntur sibi consúlere disciplínæ, opus virtútis exígere; sed inscítia in eo est, quia non compatiúntur natúræ, non ǽstimant possibilitátem. Non sit ergo irrationábilis timor. Etenim vera sapiéntia a timóre Dei íncipit, nec est sapiéntia spiritális sine timóre Dei; ita timor sine sapiéntia esse non debet.")
     (:source nil :text "Basis quædam verbi est timor sanctus. Sicut enim simulácrum áliquod in basi statúitur, et tunc majórem habet grátiam, cum in basi státua fúerit collocáta, standíque áccipit firmitátem: ita verbum Dei in timóre sancto mélius statúitur, fórtius radicátur in péctore timéntis Dóminum; ne labátur verbum de corde viri, ne véniant vólucres et áuferant illud de incuriósi et dissimulántis afféctu."))
     :responsories ((:respond "In princípio Deus ántequam terram fáceret, priúsquam abýssos constitúeret, priúsquam prodúceret fontes aquárum, * Antequam montes collocaréntur, ante omnes colles generávit me Dóminus." :verse "Ego in altíssimis hábito, et thronus meus in colúmna nubis." :repeat "Ante omnes colles generávit me Dóminus.")
     (:respond "Gyrum cæli circuívi sola, et in flúctibus maris ambulávi, in omni gente et in omni pópulo primátum ténui: * Superbórum et sublímium colla própria virtúte calcávi." :verse "Diléctio illíus custódia legum est: quia omnis sapiéntia timor Dómini." :repeat "Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi.")
     (:respond "Emítte, Dómine, sapiéntiam de sede magnitúdinis tuæ, ut mecum sit et mecum labóret: * Ut sciam, quid accéptum sit coram te omni témpore." :verse "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam." :repeat "Ut mecum sit, et mecum labóret, ut sciam quid accéptum sit coram te omni témpore.")
     (:respond "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam, et noli me reprobáre a púeris tuis: * Quóniam servus tuus sum ego, et fílius ancíllæ tuæ." :verse "Duo rogáví te, ne déneges mihi ántequam móriar: vanitátem, et verbum mendácii longe fac a me:" :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Inítium sapiéntiæ timor Dómini: * Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi." :verse "Ne forte satiátus évomam illud, et perjúrem nomen Dei mei." :repeat "Sed tantum víctui meo tríbue necessária.")
     (:respond "Verbum iníquum et dolósum longe fac a me, Dómine: * Divítias et paupertátem ne déderis mihi, sed tantum víctui meo tríbue necessária." :verse "Duo rogávi te, ne déneges mihi ántequam móriar." :repeat "Divítias et paupertátem ne déderis mihi, sed tantum víctui meo tríbue necessária.")
     (:respond "Dómine, Pater et Deus vitæ meæ, ne derelínquas me in cogitátu malígno: extolléntiam oculórum meórum ne déderis mihi, et desidérium malígnum avérte a me, Dómine; aufer a me concupiscéntiam, * Et ánimo irreverénti et infruníto ne tradas me, Dómine." :verse "Ne derelínquas me, Dómine, ne accréscant ignorántiæ meæ, nec multiplicéntur delícta mea." :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("082" . (:scripture-refs ("Eccl 1:1-7" "Eccl 1:8-11" "Eccl 1:12-17")
     :lessons ((:source "Sermo sancti Joánnis Chrysóstomi
Sermo contra concubinarios, in fine, tomo 5" :text "Sálomon cum sæculárium rerum concupiscéntia tenerétur, magnas eas et admirándas putábat, multúmque in eis labóris et sollicitúdinis insumébat, magníficas ædificándo domos, copiósum coacervándo aurum, congregándo cantórum choros, vária génera ministrórum mensæ et popínæ, quæréndo ánimæ suæ voluptátem ab hortórum et córporum formosórum grátia, et omnem, ut ita dicam, oblectatiónis et refrigérii viam sectándo.")
     (:source nil :text "At ubi inde ad se revérsus, et quasi ex umbrósa quadam abýsso ad lumen veræ sapiéntiæ respícere váluit, tunc sublímem illam et cælis dignam emísit vocem: Vánitas vanitátum, dicens, et ómnia vánitas. Hanc et vos, et hac sublimiórem, si voluéritis, efferétis senténtiam de intempestíva hac voluptáte, si aliquantísper a mala consuetúdine vos sequestravéritis.")
     (:source nil :text "Quamvis autem a Salomóne sǽculis superióribus non tam multa sapiéntiæ exigebátur diligéntia: neque enim delícias lex vetus prohibébat, neque áliis frui supervácuis dicébat vanum: áttamen et sic se habéntibus rebus, in ipsis contuéri licébit, quam viles et vanitáti obnóxiæ res sint. Nos vero ad majórem vocáti vitam, et ad excelléntius fastígium ascéndimus, et in majóribus exercémur palǽstris: et quid áliud, quam quod, sicut supérnæ virtútes intellectuáles et incorpóreæ illæ, vitam institúere jubémur?"))
     :responsories ((:respond "In princípio Deus ántequam terram fáceret, priúsquam abýssos constitúeret, priúsquam prodúceret fontes aquárum, * Antequam montes collocaréntur, ante omnes colles generávit me Dóminus." :verse "Ego in altíssimis hábito, et thronus meus in colúmna nubis." :repeat "Ante omnes colles generávit me Dóminus.")
     (:respond "Gyrum cæli circuívi sola, et in flúctibus maris ambulávi, in omni gente et in omni pópulo primátum ténui: * Superbórum et sublímium colla própria virtúte calcávi." :verse "Diléctio illíus custódia legum est: quia omnis sapiéntia timor Dómini." :repeat "Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi.")
     (:respond "Emítte, Dómine, sapiéntiam de sede magnitúdinis tuæ, ut mecum sit et mecum labóret: * Ut sciam, quid accéptum sit coram te omni témpore." :verse "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam." :repeat "Ut mecum sit, et mecum labóret, ut sciam quid accéptum sit coram te omni témpore.")
     (:respond "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam, et noli me reprobáre a púeris tuis: * Quóniam servus tuus sum ego, et fílius ancíllæ tuæ." :verse "Duo rogáví te, ne déneges mihi ántequam móriar: vanitátem, et verbum mendácii longe fac a me:" :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Inítium sapiéntiæ timor Dómini: * Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi." :verse "Ne forte satiátus évomam illud, et perjúrem nomen Dei mei." :repeat "Sed tantum víctui meo tríbue necessária.")
     (:respond "Verbum iníquum et dolósum longe fac a me, Dómine: * Divítias et paupertátem ne déderis mihi, sed tantum víctui meo tríbue necessária." :verse "Duo rogávi te, ne déneges mihi ántequam móriar." :repeat "Divítias et paupertátem ne déderis mihi, sed tantum víctui meo tríbue necessária.")
     (:respond "Dómine, Pater et Deus vitæ meæ, ne derelínquas me in cogitátu malígno: extolléntiam oculórum meórum ne déderis mihi, et desidérium malígnum avérte a me, Dómine; aufer a me concupiscéntiam, * Et ánimo irreverénti et infruníto ne tradas me, Dómine." :verse "Ne derelínquas me, Dómine, ne accréscant ignorántiæ meæ, nec multiplicéntur delícta mea." :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("083" . (:scripture-refs ("Sap 1:1-4" "Sap 1:5-8" "Sap 1:9-11")
     :lessons ((:source "Ex libro Officiórum sancti Ambrósii Epíscopi
Lib. 1. Cap. 28 et 29" :text "Magnus justítiæ splendor, quæ áliis pótius nata quam sibi, communitátem et societátem nostram ádjuvat, excelsitátem tenet, ut suo judício ómnia subjécta hábeat, opem áliis ferat, pecúniam cónferat, offícia non ábnuat, perícula suscípiat aliéna. Quis non cúperet hanc virtútis arcem tenére, nisi prima avarítia infirmáret atque inflécteret tantæ virtútis vigórem? Etenim dum augére opes, aggregáre pecúnias, occupáre terras possessiónibus cúpimus, præstáre divítiis; justítiæ formam exúimus, beneficéntiam commúnem amíttimus.")
     (:source nil :text "Quanta autem justítia sit, ex hoc intélligi potest, quod nec locis, nec persónis, nec tempóribus excípitur, quæ étiam hóstibus reservátur: ut si constitútus sit cum hoste aut locus aut dies prǽlio, advérsus justítiam putétur aut loco præveníre aut témpore. Interest enim utrum áliquis pugna áliqua et conflíctu gravi capiátur, an superióre grátia, vel áliquo evéntu. Si ergo in bello justítia valet, quanto magis in pace servánda est?")
     (:source nil :text "Fundaméntum ergo est justítiæ fides. Justórum enim corda meditántur fidem: et qui se justus accúsat, justítiam supra fidem cóllocat. Nam tunc justítia ejus appáret, si vera fateátur. Dénique et Dóminus per Isaíam: Ecce, inquit, mitto lápidem in fundaméntum Sion: id est, Christum in fundaméntum Ecclésiæ. Fides enim ómnium Christus: Ecclésia autem quædam forma justítiæ est, commúne jus ómnium: in commúne orat, in commúne operátur, in commúne tentátur. Dénique qui seípsum sibi ábnegat, ipse justus, ipse dignus Christo est. Ideo et Paulus fundaméntum pósuit Christum, ut supra eum ópera justítiæ locarémus, quia fides fundaméntum est."))
     :responsories ((:respond "In princípio Deus ántequam terram fáceret, priúsquam abýssos constitúeret, priúsquam prodúceret fontes aquárum, * Antequam montes collocaréntur, ante omnes colles generávit me Dóminus." :verse "Ego in altíssimis hábito, et thronus meus in colúmna nubis." :repeat "Ante omnes colles generávit me Dóminus.")
     (:respond "Gyrum cæli circuívi sola, et in flúctibus maris ambulávi, in omni gente et in omni pópulo primátum ténui: * Superbórum et sublímium colla própria virtúte calcávi." :verse "Diléctio illíus custódia legum est: quia omnis sapiéntia timor Dómini." :repeat "Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi.")
     (:respond "Emítte, Dómine, sapiéntiam de sede magnitúdinis tuæ, ut mecum sit et mecum labóret: * Ut sciam, quid accéptum sit coram te omni témpore." :verse "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam." :repeat "Ut mecum sit, et mecum labóret, ut sciam quid accéptum sit coram te omni témpore.")
     (:respond "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam, et noli me reprobáre a púeris tuis: * Quóniam servus tuus sum ego, et fílius ancíllæ tuæ." :verse "Duo rogáví te, ne déneges mihi ántequam móriar: vanitátem, et verbum mendácii longe fac a me:" :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Inítium sapiéntiæ timor Dómini: * Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi." :verse "Ne forte satiátus évomam illud, et perjúrem nomen Dei mei." :repeat "Sed tantum víctui meo tríbue necessária.")
     (:respond "Verbum iníquum et dolósum longe fac a me, Dómine: * Divítias et paupertátem ne déderis mihi, sed tantum víctui meo tríbue necessária." :verse "Duo rogávi te, ne déneges mihi ántequam móriar." :repeat "Divítias et paupertátem ne déderis mihi, sed tantum víctui meo tríbue necessária.")
     (:respond "Dómine, Pater et Deus vitæ meæ, ne derelínquas me in cogitátu malígno: extolléntiam oculórum meórum ne déderis mihi, et desidérium malígnum avérte a me, Dómine; aufer a me concupiscéntiam, * Et ánimo irreverénti et infruníto ne tradas me, Dómine." :verse "Ne derelínquas me, Dómine, ne accréscant ignorántiæ meæ, nec multiplicéntur delícta mea." :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("084" . (:scripture-refs ("Sir 1:1-5" "Sir 1:6-10" "Sir 1:11-15")
     :lessons ((:source "Ex libro Morálium sancti Gregórii Papæ
Liber 1, cap. 10 in cap. 1 Job" :text "Sunt nonnúlli qui vitam suam négligunt et, dum transitória áppetunt, dum ætérna vel non intélligunt, vel intellécta contémnunt, nec dolórem séntiunt, nec habére consílium sciunt; cumque supérna quæ amisérunt, non consíderant, esse se (heu míseri) in bonis felíces putant. Nequáquam enim ad veritátis lucem, cui cónditi fúerant, mentis óculos érigunt; nequáquam ad contemplatiónem pátriæ ætérnæ desidérii áciem tendunt; sed semetípsos in his, ad quæ projécti sunt, deseréntes, vice pátriæ díligunt exsílium quod patiúntur, et in cæcitáte quam tólerant, quasi in claritáte lúminis exsúltant.")
     (:source nil :text "At contra, electórum mentes, dum transitória cuncta nulla esse conspíciunt, ad quæ sint cónditæ exquírunt: cumque eórum satisfactióni nihil extra Deum súfficit, ipsa inquisitiónis exercitatióne fatigáta illórum cogitátio, in Conditóris sui spe et contemplatióne requiéscit, supérnis intérseri cívibus áppetit; et unusquísque eórum adhuc in mundo córpore pósitus, mente tamen extra mundum surgit: ærúmnam exsílii, quam tólerat, deplórat, et ad sublímem pátriam incessántibus se amóris stímulis éxcitat. Cum ergo dolens videt, quam sit ætérnum quod pérdidit, ínvenit salúbre consílium, temporále hoc despícere quod percúrrit: et quo magis crescit consílii sciéntia ut peritúra déserat, eo augétur dolor, quod necdum ad mansúra pertíngat.")
     (:source nil :text "Intuéndum quoque est, quod nullus dolor mentis sit in actióne præcipitatiónis. Qui enim sine consíliis vivunt, qui seípsos rerum evéntibus præcípites déserunt, nullo ínterim cogitatiónum dolóre fatigántur. Nam qui solérter in vitæ consílio figit mentem, caute sese in omni actióne circumspiciéndo consíderat; et ne ex re quæ ágitur, repentínus finis adversúsque surrípiat, hunc prius mólliter pósito pede cogitatiónis palpat: pensat, ne ab his quæ agénda sunt, præpédiat formído; ne in his quæ differénda sunt, præcipitátio impéllat; ne prava per concupiscéntiam apérto bello súperent; ne recta per inánem glóriam insidiándo supplántent."))
     :responsories ((:respond "In princípio Deus ántequam terram fáceret, priúsquam abýssos constitúeret, priúsquam prodúceret fontes aquárum, * Antequam montes collocaréntur, ante omnes colles generávit me Dóminus." :verse "Ego in altíssimis hábito, et thronus meus in colúmna nubis." :repeat "Ante omnes colles generávit me Dóminus.")
     (:respond "Gyrum cæli circuívi sola, et in flúctibus maris ambulávi, in omni gente et in omni pópulo primátum ténui: * Superbórum et sublímium colla própria virtúte calcávi." :verse "Diléctio illíus custódia legum est: quia omnis sapiéntia timor Dómini." :repeat "Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi.")
     (:respond "Emítte, Dómine, sapiéntiam de sede magnitúdinis tuæ, ut mecum sit et mecum labóret: * Ut sciam, quid accéptum sit coram te omni témpore." :verse "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam." :repeat "Ut mecum sit, et mecum labóret, ut sciam quid accéptum sit coram te omni témpore.")
     (:respond "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam, et noli me reprobáre a púeris tuis: * Quóniam servus tuus sum ego, et fílius ancíllæ tuæ." :verse "Duo rogáví te, ne déneges mihi ántequam móriar: vanitátem, et verbum mendácii longe fac a me:" :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Inítium sapiéntiæ timor Dómini: * Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi." :verse "Ne forte satiátus évomam illud, et perjúrem nomen Dei mei." :repeat "Sed tantum víctui meo tríbue necessária.")
     (:respond "Inítium sapiéntiæ timor Dómini: * Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi." :verse "Ne forte satiátus évomam illud, et perjúrem nomen Dei mei." :repeat "Sed tantum víctui meo tríbue necessária.")
     (:respond "Dómine, Pater et Deus vitæ meæ, ne derelínquas me in cogitátu malígno: extolléntiam oculórum meórum ne déderis mihi, et desidérium malígnum avérte a me, Dómine; aufer a me concupiscéntiam, * Et ánimo irreverénti et infruníto ne tradas me, Dómine." :verse "Ne derelínquas me, Dómine, ne accréscant ignorántiæ meæ, nec multiplicéntur delícta mea." :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("085" . (:scripture-refs ("Sir 5:1-5" "Sir 5:6-11" "Sir 5:12-16")
     :lessons ((:source "Sermo sancti Joánnis Chrysóstomi
Homilia 22 in 2 Cor. 10 in Moralibus." :text "Ne tardes convérti ad Dóminum, et ne dífferas de die in diem;  nescis enim quid paritúra sit superventúra dies. Perículum enim et metus est in defferéndo;  salus vero certa ac secúra, si nulla sit dilátio. Virtútem ígitur cole: sic enim, licet júvenis moriáris, secúre discésseris: quod si ad senectútem pervéneris, cum multa facilitáte et nulla moléstia e vita discédes;  duplicémque habébis festivitátem, et quod a vitæ malítia abstinúeris, et quod virtútem colúeris. Ne dicas: Erit tempus, quando convérti licébit: verba enim hæc Deum valde exásperant.")
     (:source nil :text "Cur nam, cum ipse tibi ætérna sǽcula promísit, tu in præsénti vita laboráre non vis, quæ parva et momentánea est; sed sic ignávus ac dissolútus agis, quasi hac breviórem áliam quamdam inquíras? Nonne illæ quotidiánæ comessatiónes, nonne illæ mensæ, nonne scorta illa, nonne theátra illa, nonne divítiæ illæ testántur inexplébilem malítiæ concupiscéntiam? Cógita bene, quod quóties scortátus es, tóties condemnásti teípsum;  peccátum enim ita se habet, ut mox atque patrátum fúerit, senténtiam ferat judex.")
     (:source nil :text "Inebriátus es? ventri indulsísti? rapuísti? siste jam gradum: verte te in divérsum: confitére Deo grátiam, quod non in médiis peccátis te ábstulit: ne quære áliud tibi prorogári tempus ut male operéris. Multi dum male ac vitióse víverent, súbito periérunt et in maniféstam damnatiónem abiérunt: time ne idem tibi áccidat. Sed multis, inquis, dedit Deus spátium, ut in última senécta confiteréntur. Quid ígitur? numquid et tibi dábitur? Fortásse dabit, inquis. Cur dicis, fortásse? Cóntigit aliquóties? Cógita quod de ánima delíberas: proínde étiam de contrário cógita, et dic: Quid autem, si non det? Quid autem, si det, inquis? Esto, dat quidem ipse: verúmtamen hoc illo cértius et utílius."))
     :responsories ((:respond "In princípio Deus ántequam terram fáceret, priúsquam abýssos constitúeret, priúsquam prodúceret fontes aquárum, * Antequam montes collocaréntur, ante omnes colles generávit me Dóminus." :verse "Ego in altíssimis hábito, et thronus meus in colúmna nubis." :repeat "Ante omnes colles generávit me Dóminus.")
     (:respond "Gyrum cæli circuívi sola, et in flúctibus maris ambulávi, in omni gente et in omni pópulo primátum ténui: * Superbórum et sublímium colla própria virtúte calcávi." :verse "Diléctio illíus custódia legum est: quia omnis sapiéntia timor Dómini." :repeat "Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi.")
     (:respond "Emítte, Dómine, sapiéntiam de sede magnitúdinis tuæ, ut mecum sit et mecum labóret: * Ut sciam, quid accéptum sit coram te omni témpore." :verse "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam." :repeat "Ut mecum sit, et mecum labóret, ut sciam quid accéptum sit coram te omni témpore.")
     (:respond "Da mihi, Dómine, sédium tuárum assistrícem sapiéntiam, et noli me reprobáre a púeris tuis: * Quóniam servus tuus sum ego, et fílius ancíllæ tuæ." :verse "Duo rogáví te, ne déneges mihi ántequam móriar: vanitátem, et verbum mendácii longe fac a me:" :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Inítium sapiéntiæ timor Dómini: * Intelléctus bonus ómnibus faciéntibus eum: laudátio ejus manet in sǽculum sǽculi." :verse "Ne forte satiátus évomam illud, et perjúrem nomen Dei mei." :repeat "Sed tantum víctui meo tríbue necessária.")
     (:respond "Verbum iníquum et dolósum longe fac a me, Dómine: * Divítias et paupertátem ne déderis mihi, sed tantum víctui meo tríbue necessária." :verse "Duo rogávi te, ne déneges mihi ántequam móriar." :repeat "Divítias et paupertátem ne déderis mihi, sed tantum víctui meo tríbue necessária.")
     (:respond "Dómine, Pater et Deus vitæ meæ, ne derelínquas me in cogitátu malígno: extolléntiam oculórum meórum ne déderis mihi, et desidérium malígnum avérte a me, Dómine; aufer a me concupiscéntiam, * Et ánimo irreverénti et infruníto ne tradas me, Dómine." :verse "Ne derelínquas me, Dómine, ne accréscant ignorántiæ meæ, nec multiplicéntur delícta mea." :repeat "Et ánimo irreverénti et infruníto ne tradas me, Dómine.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("091" . (:scripture-refs ("Job 1:1-3" "Job 1:4-5" "Job 1:6-11")
     :lessons ((:source "Ex libro Morálium sancti Gregórii Papæ
Lectio iv, Lib. 2, Cap. 1" :text "Scriptúra sacra mentis óculis quasi quoddam spéculum oppónitur, ut intérna nostra fácies in ipsa videátur. Ibi étenim fœda, ibi pulchra nostra cognóscimus: ibi sentímus quantum profícimus, ibi a proféctu quam longe distámus. Narrat autem gesta Sanctórum, et ad imitatiónem corda próvocat infirmórum; dumque illórum victrícia facta commémorat, contra vitiórum prǽlia, debília nostra confírmat: fitque verbis illíus, ut eo mens minus inter certámina trépidet, quo ante se pósitos tot virórum fórtium triúmphos videt.")
     (:source nil :text "Nonnúmquam vero non solum nobis eórum virtútes ásserit, sed étiam casus innotéscit; ut et in victória fórtium, quod imitándo arrípere, et rursum videámus in lápsibus quid debeámus timére. Ecce enim Job descríbitur tentatióne auctus, sed David tentatióne prostrátus; ut et majórum virtus spem nostram fóveat, et majórum casus ad cautélam nos humilitátis accíngat: quátenus dum illa gaudéntes súblevant, ista metuéntes premant; et audiéntis ánimus illinc spei fidúcia, hinc humilitáte timóris erudítus, nec temeritáte supérbiat, quia formídine prémitur; nec pressus timóre despéret, quia ad spei fidúciam virtútis exémplo roborátur.")
     (:source "Lib. 1 Moral., cap. 1" :text "Vir erat in terra Hus, nómine Job. Idcírco sanctus vir ubi habitáverit dícitur, ut ejus méritum virtútis exprimátur. Hus namque quis nésciat quod sit in terra Gentílium? Gentílitas autem eo obligáta vítiis éxstitit, quo cognitiónem sui Conditóris ignorávit. Dicátur ítaque ubi habitáverit; ut hoc ejus láudibus profíciat, quod bonus inter malos fuit. Neque enim valde laudábile est, bonum esse cum bonis, sed bonum esse cum malis. Sicut enim gravióris culpæ est, inter bonus bonum non esse; ita imménsi est præcónii, bonum étiam inter malos exstitísse."))
     :responsories ((:respond "Si bona suscépimus de manu Dei, mala autem quare non sustineámus? * Dóminus dedit, Dóminus ábstulit; sicut Dómino plácuit, ita factum est: sit nomen Dómini benedíctum." :verse "Nudus egréssus sum de útero matris meæ et nudus revértar illuc." :repeat "Dóminus dedit, Dóminus ábstulit; sicut Dómino plácuit, ita factum est: sit nomen Dómini benedíctum.")
     (:respond "Antequam cómedam, suspíro, et tamquam inundántes aquæ sic rugítus meus; quia timor, quem timébam, evénit mihi, et quod verébar áccidit. Nonne dissimulávi? nonne sílui? nonne quiévi? * Et venit super me indignátio." :verse "Ecce non est auxílium mihi in me, et necessárii quoque mei recessérunt a me." :repeat "Et venit super me indignátio.")
     (:respond "Quare detraxístis sermónibus veritátis? ad increpándum verba compónitis et subvértere nitímini amícum vestrum: * Verúmtamen quæ cogitástis, expléte." :verse "Quod justum est, judicáte; et non inveniétis in lingua mea iniquitátem." :repeat "Verúmtamen quæ cogitástis, expléte.")
     (:respond "Indúta est caro mea putrédine, et sórdibus púlveris cutis mea áruit et contrácta est: * Meménto mei, Dómine, quóniam ventus est vita mea." :verse "Dies mei velócius transiérunt quam a texénte tela succíditur, et consúmpti sunt absque ulla spe." :repeat "Meménto mei, Dómine, quóniam ventus est vita mea.")
     (:respond "Páucitas diérum meórum finiétur brevi; dimítte me, Dómine, ut plangam páululum dolórem meum, * Antequam vadam ad terram tenebrósam et opértam mortis calígine." :verse "Manus tuæ, Dómine, fecérunt me, et plasmavérunt me totum in circúitu; et sic repénte præcípitas me?" :repeat "Antequam vadam ad terram tenebrósam et opértam mortis calígine.")
     (:respond "Non abscóndas me, Dómine, a fácie tua: manum tuam longe fac a me, * Et formído tua non me térreat." :verse "Córripe me, Dómine, in misericórdia, non in furóre tuo, ne forte ad níhilum rédigas me." :repeat "Et formído tua non me térreat.")
     (:respond "Quis mihi tríbuat, ut in inférno prótegas me et abscóndas me, donec pertránseat furor tuus, Dómine, nisi tu, qui solus es Deus? * Et constítuas mihi tempus, in quo recordéris mei?" :verse "Numquid sicut dies hóminis dies tui, ut quæras iniquitátem meam; cum sit nemo, qui de manu tua possit erúere." :repeat "Et constítuas mihi tempus, in quo recordéris mei?")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("092" . (:scripture-refs ("Job 9:1-5" "Job 9:6-10" "Job 9:11-17")
     :lessons ((:source "Ex libro Morálium sancti Gregórii Papæ
Liber 9, Cap. 2." :text "Vero scio quod ita sit, et quod non justificábitur homo compósitus Deo. Homo quippe Deo non compósitus justítiam pércipit, compósitus amíttit; quia quisquis se auctóri bonórum cómparat, bono se, quod accéperat, privat. Qui enim accépta bona sibi árrogat, suis contra Deum donis pugnat. Unde ergo despéctus erígitur, dignum est ut eréctus inde destruátur. Sanctus autem vir, quia omne virtútis nostræ méritum esse vítium cónspicit, si ab intérno árbitro distrícte judicétur, recte subjúngit: Si volúerit conténdere cum eo, non póterit respondére ei unum pro mille.")
     (:source nil :text "In Scriptúra sancta millenárius númerus pro universitáte solet intélligi. Hinc étenim Psalmísta ait: Verbi, quod mandávit in mille generatiónes: cum profécto constet, quod ab ipso mundi exórdio usque ad Redemptiónis advéntum per Evangelístam non ámplius quam septuagínta et septem propágines numeréntur. Quid ergo in millenário número nisi ad proferéndam novam sóbolem perfécta univérsitas præscítæ generatiónis exprímitur? Hinc et per Joánnem dícitur: Et regnábunt cum eo mille annis: quia vidélicet regnum sanctæ Ecclésiæ universitátis perfectióne solidátur.")
     (:source nil :text "Quia vero monas décies multiplicáta in denárium dúcitur, denárius per semetípsum ductus in centenárium dilatátur, qui rursus per denárium ductus in millenárium ténditur; cum ab uno incípimus, ut ad millenárium veniámus, quid hoc loco uníus appellatióne, nisi bene vivéndi inítium? quid millenárii númeri amplitúdine, nisi ejúsdem bonæ vitæ perféctio designátur? Cum Deo autem conténdere, est, non ei tribúere, sed sibi glóriam suæ virtútis arrogáre. Sed sanctus vir conspíciat, quia et qui summa jam dona percépit, si de accéptis extóllitur, cuncta quæ accéperat, amíttit."))
     :responsories ((:respond "Si bona suscépimus de manu Dei, mala autem quare non sustineámus? * Dóminus dedit, Dóminus ábstulit; sicut Dómino plácuit, ita factum est: sit nomen Dómini benedíctum." :verse "Nudus egréssus sum de útero matris meæ et nudus revértar illuc." :repeat "Dóminus dedit, Dóminus ábstulit; sicut Dómino plácuit, ita factum est: sit nomen Dómini benedíctum.")
     (:respond "Antequam cómedam, suspíro, et tamquam inundántes aquæ sic rugítus meus; quia timor, quem timébam, evénit mihi, et quod verébar áccidit. Nonne dissimulávi? nonne sílui? nonne quiévi? * Et venit super me indignátio." :verse "Ecce non est auxílium mihi in me, et necessárii quoque mei recessérunt a me." :repeat "Et venit super me indignátio.")
     (:respond "Quare detraxístis sermónibus veritátis? ad increpándum verba compónitis et subvértere nitímini amícum vestrum: * Verúmtamen quæ cogitástis, expléte." :verse "Quod justum est, judicáte; et non inveniétis in lingua mea iniquitátem." :repeat "Verúmtamen quæ cogitástis, expléte.")
     (:respond "Indúta est caro mea putrédine, et sórdibus púlveris cutis mea áruit et contrácta est: * Meménto mei, Dómine, quóniam ventus est vita mea." :verse "Dies mei velócius transiérunt quam a texénte tela succíditur, et consúmpti sunt absque ulla spe." :repeat "Meménto mei, Dómine, quóniam ventus est vita mea.")
     (:respond "Páucitas diérum meórum finiétur brevi; dimítte me, Dómine, ut plangam páululum dolórem meum, * Antequam vadam ad terram tenebrósam et opértam mortis calígine." :verse "Manus tuæ, Dómine, fecérunt me, et plasmavérunt me totum in circúitu; et sic repénte præcípitas me?" :repeat "Antequam vadam ad terram tenebrósam et opértam mortis calígine.")
     (:respond "Non abscóndas me, Dómine, a fácie tua: manum tuam longe fac a me, * Et formído tua non me térreat." :verse "Córripe me, Dómine, in misericórdia, non in furóre tuo, ne forte ad níhilum rédigas me." :repeat "Et formído tua non me térreat.")
     (:respond "Quis mihi tríbuat, ut in inférno prótegas me et abscóndas me, donec pertránseat furor tuus, Dómine, nisi tu, qui solus es Deus? * Et constítuas mihi tempus, in quo recordéris mei?" :verse "Numquid sicut dies hóminis dies tui, ut quæras iniquitátem meam; cum sit nemo, qui de manu tua possit erúere." :repeat "Et constítuas mihi tempus, in quo recordéris mei?")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("093" . (:scripture-refs ("Tob 1:1-4" "Tob 1:5-10" "Tob 1:11-15")
     :lessons ((:source "Sermo sancti Leónis Papæ
Sermo 9 de jejúnio 7 mensis" :text "Scio quidem, dilectíssimi, plúrimos vestrum ita in iis, quæ ad observántiam christiánæ fídei pértinent, esse devótos, ut nostris cohortatiónibus non indígeant admonéri. Quod enim dudum et tradítio decrévit, et consuetúdo firmávit; nec erudítio ignórat, nec píetas prætermíttit. Sed quia sacerdotális offícii est, erga omnes Ecclésiæ fílios curam habére commúnem, in id quod et rúdibus prosit et doctis, quos simul dilígimus, páriter incitámus; ut jejúnium, quod nobis séptimi mensis recúrsus indícit, fide álacri per castigatiónem ánimi et córporis celebrémus.")
     (:source nil :text "Ideo enim ipsa continéntiæ observántia quátuor est assignáta tempóribus, ut in idípsum totíus anni redeúnte decúrsu, cognoscerémus nos indesinénter purificatiónibus indigére; sempérque esse niténdum, dum hujus vitæ varietáte jactámur, ut peccátum, quod fragilitáte carnis et cupiditátum pollutióne contráhitur, jejúniis atque eleemósynis deleátur. Esuriámus páululum, dilectíssimi, et aliquántulum, quod juvándis possit prodésse paupéribus, nostræ consuetúdini subtrahámus.")
     (:source nil :text "Delectétur consciéntia benignórum frúctibus largitátis: et gáudia tríbuens, quo es lætificándus, accípies. Diléctio próximi, diléctio Dei est, qui plenitúdinem legis et prophetárum in hac géminæ caritátis unitáte constítuit; ut nemo ambígeret, Deo se offérre, quod hómini contulísset, dicénte Dómino Salvatóre, cum de aléndis juvandísque paupéribus loquerétur: Quod uni eórum fecístis, mihi fecístis. Quarta ígitur et sexta féria jejunémus; sábbato vero apud beátum Petrum Apóstolum vigílias celebrémus: cujus nos méritis et oratiónibus crédimus adjuvándos, ut misericórdi Deo jejúnio nostro et devotióne placeámus."))
     :responsories ((:respond "Peto, Dómine, ut de vínculo impropérii hujus absólvas me, aut certe désuper terram erípias me: * Ne reminiscáris delícta mea vel paréntum meórum, neque vindíctam sumas de peccátis meis: quia éruis sustinéntes te, Dómine." :verse "Omnia enim judícia tua justa sunt, et omnes viæ tuæ misericórdia et véritas: et nunc, Dómine, meménto mei." :repeat "Ne reminiscáris delícta mea vel paréntum meórum, neque vindíctam sumas de peccátis meis: quia éruis sustinéntes te, Dómine.")
     (:respond "Omni témpore bénedic Deum, et pete ab eo ut vias tuas dírigat, * Et in omni témpore consília tua in ipso permáneant." :verse "Inquíre ut fácias quæ plácita sunt illi in veritáte, et in tota virtúte tua." :repeat "Et in omni témpore consília tua in ipso permáneant.")
     (:respond "Memor esto, fili, quóniam páuperem vitam gérimus: * Habébis multa bona, si timúeris Deum." :verse "In mente habéto eum, et cave nequándo prætermíttas præcépta ejus." :repeat "Habébis multa bona, si timúeris Deum.")
     (:respond "Sufficiébat nobis paupértas nostra, ut divítiæ computaréntur: numquam fuísset pecúnia ipsa, pro qua misísti fílium nostrum, * Báculum senectútis nostræ!" :verse "Heu me, fili mi, ut quid te mísimus peregrinári, lumen oculórum nostrórum?" :repeat "Báculum senectútis nostræ!")
     (:respond "Benedícite Deum cæli et coram ómnibus vivéntibus confitémini ei, * Quia fecit vobíscum misericórdiam suam." :verse "Ipsum benedícite et cantáte illi: et enarráte ómnia mirabília ejus." :repeat "Quia fecit vobíscum misericórdiam suam.")
     (:respond "Tempus est ut revértar ad eum qui misit me; * Vos autem benedícite Deum, et enarráte ómnia mirabília ejus." :verse "Confitémini ei coram ómnibus vivéntibus, quia fecit vobíscum misericórdiam suam." :repeat "Vos autem benedícite Deum, et enarráte ómnia mirabília ejus.")
     (:respond "Tribulatiónes civitátum audívimus, quas passæ sunt, et defécimus: timor et hebetúdo mentis cécidit super nos et super líberos nostros: ipsi montes nolunt recípere fugam nostram: * Dómine, miserére." :verse "Peccávimus cum pátribus nostris, injúste égimus, iniquitátem fécimus." :repeat "Dómine, miserére.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("094" . (:scripture-refs ("Jdt 1:1-4" "Jdt 1:5-9" "Jdt 1:10-12; 2:1-3")
     :lessons ((:source "Ex libro sancti Ambrósii Epíscopi de Elía et jejúnio
Lectio iv, Cap. 9" :text "Poténtes vinum prohibéntur bíbere, ne, cum bíberint, obliviscántur sapiéntiam. Dénique bibébant vinum in ebrietáte poténtes, qui Holoférni príncipi milítiæ regis Assyriórum se trádere gestiébant; sed non bibébant fémina Judith, jejúnans ómnibus diébus viduitátis suæ, præter festórum diérum solemnitátes. His armis muníta procéssit et omnem Assyriórum circumvénit exércitum. Sóbrii vigóre consílii ábstulit Holoférnis caput, servávit pudicítiam, victóriam reportávit.")
     (:source nil :text "Hæc enim succíncta jejúnio in castris prætendébat aliénis; ille vino sepúltus jacébat, ut ictum vúlneris sentíre non posset. Ítaque uníus mulíeris jejúnium innúmeros stravit exércitus Assyriórum. Esther quoque púlchrior facta est jejúnio; Dóminus enim grátiam sóbriæ mentis augébat. Omne genus suum, id est, totum pópulum Judæórum a persecutiónis acerbitáte liberávit, ita ut regem sibi fáceret esse subjéctum.")
     (:source nil :text "Itaque illa, quæ tríduo jejunávit contínuo, et corpus suum aqua lavit, plus plácuit, et vindíctam rétulit. Aman autem, dum se regáli jactat convívio, inter ipsa vina pœnam suæ ebrietátis exsólvit. Est ergo jejúnium reconciliatiónis sacrifícium, virtútis increméntum, quod fecit étiam féminas fortióres augménto grátiæ. Jejúnium nescit fæneratórem, non sortem fǽnoris novit: non rédolet usúras mensa jejunántium. Etiam ipsis jejúnium convíviis dat grátiam: dulcióres post famem épulæ fiunt, quæ assiduitáte fastídio sunt, et diutúrna continuatióne viléscunt. Condiméntum cibi jejúnium est: quanto avídior appeténtia, tanto esca jucúndior."))
     :responsories ((:respond "Adonái, Dómine, Deus magne et mirábilis, qui dedísti salútem in manu féminæ, * Exáudi preces servórum tuórum." :verse "Benedíctus es, Dómine, qui non derelínquis præsuméntes de te, et de sua virtúte gloriántes humílias." :repeat "Exáudi preces servórum tuórum.")
     (:respond "Tribulatiónes civitátum audívimus, quas passæ sunt, et defécimus: timor et hebetúdo mentis cécidit super nos et super líberos nostros: ipsi montes nolunt recípere fugam nostram: * Dómine, miserére." :verse "Peccávimus cum pátribus nostris, injúste égimus, iniquitátem fécimus." :repeat "Dómine, miserére.")
     (:respond "Benedícat te Dóminus in virtúte sua, qui per te ad níhilum redégit inimícos nostros: * Ut non defíciat laus tua de ore hóminum." :verse "Benedíctus Dóminus qui creávit cælum et terram; quia hódie nomen tuum ita magnificávit." :repeat "Ut non defíciat laus tua de ore hóminum.")
     (:respond "Nos álium Deum nescímus præter Dóminum, in quo sperámus: * Qui non déspicit nos, nec ámovet salútem suam a génere nostro." :verse "Indulgéntiam ipsíus fusis lácrimis postulémus, et humiliémus illi ánimas nostras." :repeat "Qui non déspicit nos, nec ámovet salútem suam a génere nostro.")
     (:respond "Dominátor, Dómine, cælórum et terræ, Creátor aquárum, Rex univérsæ creatúræ: * Exáudi oratiónem servórum tuórum." :verse "Tu, Dómine, cui humílium semper et mansuetórum plácuit deprecátio." :repeat "Exáudi oratiónem servórum tuórum.")
     (:respond "Dómine Deus, qui cónteris bella ab inítio, éleva brácchium tuum super gentes, quæ cógitant servis tuis mala: * Et déxtera tua glorificétur in nobis." :verse "Allíde virtútem eórum in virtúte tua; cadat robur eórum in iracúndia tua." :repeat "Et déxtera tua glorificétur in nobis.")
     (:respond "Confórta me, Rex, Sanctórum principátum tenens: * Et da sermónem rectum et bene sonántem in os meum." :verse "Dómine, Rex univérsæ potestátis, convérte consílium eórum super eos." :repeat "Et da sermónem rectum et bene sonántem in os meum.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("095" . (:scripture-refs ("Esth 1:1-4" "Esth 1:5-6" "Esth 1:7-9")
     :lessons ((:source "Ex libro Officiórum sancti Ambrósii Epíscopi
Lectio iv, Liber 3, Cap. 15" :text "Quid Esther regína, nonne ut pópulum suum perículo erúeret (quod erat decórum atque honéstum) morti se óbtulit, nec immítis regis trepidávit furórem? Ipse quoque rex Persárum, ferox atque túmido corde, tamen decórum judicávit índici insidiárum, quæ sibi parátæ forent, grátiam repræsentáre, populúmque líberum a servitúte erípere, erúere neci, nec párcere neci ejus, qui tam indecóra suasísset. Dénique quem secúndum a se, ac præcípuum inter omnes amícos habéret, cruci trádidit, quod dehonestátum se ejus frauduléntis consíliis animadvertísset.")
     (:source "Cap. 16" :text "Ea enim amicítia probábilis, quæ honestátem tuétur, præferénda sane ópibus, honóribus, potestátibus; honestáti vero præférri non solet, sed honestátem sequi. Qualis fuit Jónathæ, qui pro pietáte nec offénsam patris, nec salútis perículum refugiébat. Qualis fuit Achímelech, qui pro hospitális grátiæ offíciis necem pótius sibi, quam proditiónem fugiéntis amíci, subeúndam arbitrabátur. Nihil ígitur præferéndum honestáti; quæ tamen ne amicítiæ stúdio prætereátur, étiam hoc Scriptúra ádmonet.")
     (:source nil :text "Sunt enim plerǽque philosophórum quæstiónes: Utrum amíci causa quisquam contra pátriam sentíre necne débeat, ut amíco obédiat: utrum opórteat ut fidem déserat, dum indúlget atque inténdit amíci commoditátibus. Et Scriptúra quidem ait: Clava, et gládius, et sagítta ferráta, sic homo est testimónium dans falsum advérsus amícum suum. Sed consídera quid ástruat. Non testimónium reprehéndit dictum in amícum, sed falsum testimónium. Quid enim si Dei causa, quid si pátriæ, cogátur áliquis dícere testimónium? Numquid præponderáre debet amicítia religióni, præponderáre caritáti vítium?"))
     :responsories ((:respond "Dómine, mi Rex omnípotens, in dicióne tua cuncta sunt pósita, et non est qui possit resístere voluntáti tuæ: * Líbera nos propter nomen tuum." :verse "Exáudi oratiónem nostram, et convérte luctum nostrum in gáudium." :repeat "Líbera nos propter nomen tuum.")
     (:respond "Confórta me, Rex, Sanctórum principátum tenens: * Et da sermónem rectum et bene sonántem in os meum." :verse "Dómine, Rex univérsæ potestátis, convérte consílium eórum super eos." :repeat "Et da sermónem rectum et bene sonántem in os meum.")
     (:respond "Spem in álium nunquam hábui, prætérquam in te, Deus Israël: * Qui irásceris, et propítius eris, et ómnia peccáta hóminum in tribulatióne dimíttis." :verse "Dómine Deus, Creátor cæli et terræ, réspice ad humilitátem nostram." :repeat "Qui irásceris, et propítius eris, et ómnia peccáta hóminum in tribulatióne dimíttis.")
     (:respond "Meménto mei, Dómine Deus, in bonum: * Et ne déleas miseratiónes meas, quas feci in domo Dei mei et in cæremóniis ejus." :verse "Recordáre mei, Dómine, Deus meus." :repeat "Et ne déleas miseratiónes meas, quas feci in domo Dei mei et in cæremóniis ejus.")
     (:respond "Tribulatiónes civitátum audívimus, quas passæ sunt, et defécimus: timor et hebetúdo mentis cécidit super nos et super líberos nostros: ipsi montes nolunt recípere fugam nostram: * Dómine, miserére." :verse "Peccávimus cum pátribus nostris, injúste égimus, iniquitátem fécimus." :repeat "Dómine, miserére.")
     (:respond "Benedícat te Dóminus in virtúte sua, qui per te ad níhilum redégit inimícos nostros: * Ut non defíciat laus tua de ore hóminum." :verse "Benedíctus Dóminus qui creávit cælum et terram; quia hódie nomen tuum ita magnificávit." :repeat "Ut non defíciat laus tua de ore hóminum.")
     (:respond "Nos álium Deum nescímus præter Dóminum, in quo sperámus: * Qui non déspicit nos, nec ámovet salútem suam a génere nostro." :verse "Indulgéntiam ipsíus fusis lácrimis postulémus, et humiliémus illi ánimas nostras." :repeat "Qui non déspicit nos, nec ámovet salútem suam a génere nostro.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("101" . (:scripture-refs ("1 Mac 1:1-7" "1 Mac 1:8-11" "1 Mac 1:12-16")
     :lessons ((:source "Ex libro Officiórum sancti Ambrósii Epíscopi
Lib. 1, Cap. 40" :text "Fortásse áliquos béllica defíxos glória tenet, ut putent solam esse præliárem fortitúdinem; et ídeo me ad ista deflexísse, quia illa nostris déforet. Quam fortis Jesus Nave, ut uno prǽlio quinque reges captos stérneret cum pópulis suis! Deínde cum advérsum Gabaonítas urgéret prǽlium, et vererétur ne nox impedíret victóriam, magnitúdine mentis et fídei clamávit: Stet sol, et stetit, donec victória consummarétur. Gédeon in trecéntis viris de ingénti pópulo et acérbo hoste revéxit triúmphum. Jónathas adoléscens virtútem magnam fecit in prǽlio.")
     (:source nil :text "Quid de Machabǽis loquar? Sed prius de pópulo dicam patrum; qui cum essent paráti ad repugnándum pro templo Dei et pro legítimis suis, dolo hóstium die lacessíti sábbati, maluérunt vulnéribus offérre nuda córpora, quam repugnáre, ne violárent sábbatum. Itaque omnes læti se obtulérunt morti. Sed Machabǽi considerántes quod hoc exémplo gens omnis posset períre, sábbato étiam, cum ipsi in bellum provocaréntur, ulti sunt innocéntium necem fratrum suórum. Unde póstea stimulátus rex Antíochus, cum bellum accénderet per duces suos Lýsiam, Nicánorem, Górgiam, ita cum Orientálibus suis et Assýriis attrítus est cópiis, ut quadragínta et octo míllia in médio campi a tribus míllibus prosterneréntur.")
     (:source nil :text "Virtútem ducis Judæ Machabǽi de uno ejus mílite consideráte. Namque Eleázarus, cum supereminéntem céteris elephántem loríca vestítum régia advérteret, arbitrátus quod in eo esset rex, cursu cóncito in médium legiónis se prorúpit: et, abjécto clýpeo, utráque manu interficiébat, donec perveníret ad béstiam, atque intrávit sub eam, et subjécto gládio interémit eam. Itaque cadens béstia oppréssit Eleázarum, atque ita mórtuus est. Quanta ígitur virtus ánimi! primo, ut mortem non timéret; deínde, ut circumfúsus legiónibus inimicórum, in confértos raperétur hostes, médium penetráret agmen, et contémpta morte ferócior, abjécto clýpeo, utráque manu vulnerátæ molem béstiæ subíret ac sustinéret: post infra ipsam succéderet, quo plenióri feríret ictu; cujus ruína inclúsus magis quam oppréssus, suo est sepúltus triúmpho."))
     :responsories ((:respond "Adapériat Dóminus cor vestrum in lege sua et in præcéptis suis et fáciat pacem in diébus vestris: * Concédat vobis salútem, et rédimat vos a malis." :verse "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo." :repeat "Concédat vobis salútem, et rédimat vos a malis.")
     (:respond "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo, * Dóminus, Deus noster." :verse "Det vobis cor ómnibus, ut colátis eum et faciátis ejus voluntátem." :repeat "Dóminus, Deus noster.")
     (:respond "Congregáti sunt inimíci nostri, et gloriántur in virtúte sua: cóntere fortitúdinem illórum, Dómine, et dispérge illos: * Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster." :verse "Dispérge illos in virtúte tua, et déstrue eos, protéctor noster, Dómine." :repeat "Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster.")
     (:respond "Impetum inimicórum ne timuéritis: mémores estóte, quómodo salvi facti sunt patres nostri: * Et nunc clamémus in cælum et miserébitur nostri Deus noster." :verse "Mementóte mirabílium ejus, quæ fecit pharaóni et exercítui ejus in Mari Rubro." :repeat "Et nunc clamémus in cælum et miserébitur nostri Deus noster.")
     (:respond "Congregátæ sunt gentes in multitúdine, ut dímicent contra nos, et ignorámus quid ágere debeámus: * Dómine Deus, ad te sunt óculi nostri, ne pereámus." :verse "Tu scis quæ cógitant in nos: quómodo potérimus subsístere ante fáciem illórum, nisi tu ádjuves nos?" :repeat "Dómine Deus, ad te sunt óculi nostri, ne pereámus.")
     (:respond "Tua est poténtia, tuum regnum, Dómine: tu es super omnes gentes: * Da pacem, Dómine, in diébus nostris." :verse "Creátor ómnium, Deus, terríbilis et fortis, justus et miséricors." :repeat "Da pacem, Dómine, in diébus nostris.")
     (:respond "Refúlsit sol in clípeos áureos, et resplenduérunt montes ab eis: * Et fortitúdo géntium dissipáta est." :verse "Erat enim exércitus magnus valde et fortis: et appropiávit Judas et exércitus ejus in prǽlio." :repeat "Et fortitúdo géntium dissipáta est.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("102" . (:scripture-refs ("1 Mac 4:36-40" "1 Mac 4:41-46" "1 Mac 4:47-51")
     :lessons ((:source "Ex libro sancti Augustíni Epíscopi de Civitáte Dei
Liber 18, cap. 45" :text "Posteáquam gens Judǽa cœpit non habére prophétas, proculdúbio detérior facta est, eo scílicet témpore, quo se sperábat instauráto templo post captivitátem, quæ fuit in Babylónia, futúram esse meliórem. Sic quippe intelligébat pópulus ille carnális, quod prænuntiátum est per Aggæum prophétam dicéntem: Magna erit glória domus istíus novíssimæ, plus quam primæ. Quod de novo testaménto dictum esse, paulo supérius demonstrávit, ubi ait apérte Christum promíttens: Et movébo omnes gentes, et véniet Desiderátus cunctis Géntibus.")
     (:source nil :text "Tálibus enim eléctis Géntium, domus Dei ædificátur per Testaméntum novum lapídibus vivis, longe gloriósior, quam templum illud fuit, quod a rege Salomóne constrúctum est, et post captivitátem instaurátum. Propter hoc ergo nec prophétas ex illo témpore hábuit illa gens; sed multis cládibus afflícta est ab alienígenis régibus, ipsísque Románis, ne hanc Aggæi prophetíam in illa instauratióne templi opinarétur implétam. Non multo enim post, adveniénte Alexándro, subjugáta est; quando, etsi nulla facta est vastátio, quóniam non sunt ausi ei resístere, et ídeo placátum facíllime súbditi recepérunt; non erat tamen glória tanta domus illíus, quanta fuit in suórum regum líbera potestáte.")
     (:source nil :text "Deínde Ptolemǽus Lagi fílius, post Alexándri mortem captívos inde in Ægýptum tránstulit, quos ejus succéssor Ptolemǽus Philadélphus benevolentíssime inde dimísit: per quem factum est, ut Septuagínta intérpretum Scriptúras haberémus. Deínde contríti sunt bellis, quæ in Machabæórum libris explicántur. Post hæc capti a rege Alexandríæ Ptolemǽo qui est appellátus Epíphanes, inde ab Antíocho rege Sýriæ multis et gravíssimis malis ad idóla colénda compúlsi: templúmque ipsum replétum sacrílegis superstitiónibus Géntium, quod tamen dux eórum strenuíssimus Judas, qui étiam Machabǽus dictus est, Antíochi dúcibus pulsis, ab omni illa idololatríæ contaminatióne mundávit."))
     :responsories ((:respond "Adapériat Dóminus cor vestrum in lege sua et in præcéptis suis et fáciat pacem in diébus vestris: * Concédat vobis salútem, et rédimat vos a malis." :verse "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo." :repeat "Concédat vobis salútem, et rédimat vos a malis.")
     (:respond "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo, * Dóminus, Deus noster." :verse "Det vobis cor ómnibus, ut colátis eum et faciátis ejus voluntátem." :repeat "Dóminus, Deus noster.")
     (:respond "Congregáti sunt inimíci nostri, et gloriántur in virtúte sua: cóntere fortitúdinem illórum, Dómine, et dispérge illos: * Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster." :verse "Dispérge illos in virtúte tua, et déstrue eos, protéctor noster, Dómine." :repeat "Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster.")
     (:respond "Impetum inimicórum ne timuéritis: mémores estóte, quómodo salvi facti sunt patres nostri: * Et nunc clamémus in cælum et miserébitur nostri Deus noster." :verse "Mementóte mirabílium ejus, quæ fecit pharaóni et exercítui ejus in Mari Rubro." :repeat "Et nunc clamémus in cælum et miserébitur nostri Deus noster.")
     (:respond "Congregátæ sunt gentes in multitúdine, ut dímicent contra nos, et ignorámus quid ágere debeámus: * Dómine Deus, ad te sunt óculi nostri, ne pereámus." :verse "Tu scis quæ cógitant in nos: quómodo potérimus subsístere ante fáciem illórum, nisi tu ádjuves nos?" :repeat "Dómine Deus, ad te sunt óculi nostri, ne pereámus.")
     (:respond "Tua est poténtia, tuum regnum, Dómine: tu es super omnes gentes: * Da pacem, Dómine, in diébus nostris." :verse "Creátor ómnium, Deus, terríbilis et fortis, justus et miséricors." :repeat "Da pacem, Dómine, in diébus nostris.")
     (:respond "Refúlsit sol in clípeos áureos, et resplenduérunt montes ab eis: * Et fortitúdo géntium dissipáta est." :verse "Erat enim exércitus magnus valde et fortis: et appropiávit Judas et exércitus ejus in prǽlio." :repeat "Et fortitúdo géntium dissipáta est.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("103" . (:scripture-refs ("1 Mac 9:1-6" "1 Mac 9:7-11" "1 Mac 9:12-20")
     :lessons ((:source "Ex libro Officiórum sancti Ambrósii Epíscopi
Lib. 1. cap. 41" :text "Quia fortitúdo non solum secúndis rebus, sed étiam advérsis probátur, spectémus Judæ Machabǽi éxitum. Is enim post victum Nicánorem, regis Demétrii ducem, secúrior advérsus vigínti míllia exércitus regis, cum octingéntis viris bellum adórsus, voléntibus his cédere, ne multitúdine opprimeréntur, gloriósam magis mortem quam turpem fugam suásit: Ne crimen, inquit, nostræ relinquámus glóriæ. Ita commísso prǽlio, cum a primo ortu diéi in vésperam dimicarétur, dextrum cornu, in quo validíssimam manum advértit hóstium, aggréssus fácile avértit. Sed dum fugiéntes séquitur, a tergo vúlneri locum prǽbuit; ítaque gloriosiórem triúmphis mortem invénit.")
     (:source nil :text "Quid Jónatham fratrem ejus attéxam, qui cum parva manu advérsus exércitus régios pugnans, desértus a suis et cum duóbus tantum relíctus, reparávit bellum, avértit hostem, fugitántes suos ad societátem revocávit triúmphi? Habes fortitúdinem béllicam, in qua non medíocris honésti ac decóri forma est, quod mortem servitúti prǽferat ac turpitúdini. Quid autem de Mártyrum dicam passiónibus? Et ne lóngius evagémur, non minórem de supérbo rege Antíocho Machabǽi púeri revexérunt triúmphum, quam paréntes próprii; síquidem illi armáti, isti sine armis vicérunt.")
     (:source nil :text "Stetit invícta septem puerórum cohors, régiis cincta legiónibus: defecérunt supplícia, cessérunt tortóres, non defecérunt Mártyres. Alius córium cápitis exútus, spéciem mutáverat, virtútem áuxerat. Alius linguam jussus amputándam prómere, respóndit: Non solos Dóminus audit loquéntes, qui audiébat Móysen tacéntem; plus audit tácitas cogitatiónes suórum, quam voces ómnium. Linguæ flagéllum times, flagéllum sánguinis non times? Habet et sanguis vocem suam, qua clamat ad Deum, sicut clamávit in Abel."))
     :responsories ((:respond "Adapériat Dóminus cor vestrum in lege sua et in præcéptis suis et fáciat pacem in diébus vestris: * Concédat vobis salútem, et rédimat vos a malis." :verse "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo." :repeat "Concédat vobis salútem, et rédimat vos a malis.")
     (:respond "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo, * Dóminus, Deus noster." :verse "Det vobis cor ómnibus, ut colátis eum et faciátis ejus voluntátem." :repeat "Dóminus, Deus noster.")
     (:respond "Congregáti sunt inimíci nostri, et gloriántur in virtúte sua: cóntere fortitúdinem illórum, Dómine, et dispérge illos: * Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster." :verse "Dispérge illos in virtúte tua, et déstrue eos, protéctor noster, Dómine." :repeat "Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster.")
     (:respond "Impetum inimicórum ne timuéritis: mémores estóte, quómodo salvi facti sunt patres nostri: * Et nunc clamémus in cælum et miserébitur nostri Deus noster." :verse "Mementóte mirabílium ejus, quæ fecit pharaóni et exercítui ejus in Mari Rubro." :repeat "Et nunc clamémus in cælum et miserébitur nostri Deus noster.")
     (:respond "Congregátæ sunt gentes in multitúdine, ut dímicent contra nos, et ignorámus quid ágere debeámus: * Dómine Deus, ad te sunt óculi nostri, ne pereámus." :verse "Tu scis quæ cógitant in nos: quómodo potérimus subsístere ante fáciem illórum, nisi tu ádjuves nos?" :repeat "Dómine Deus, ad te sunt óculi nostri, ne pereámus.")
     (:respond "Tua est poténtia, tuum regnum, Dómine: tu es super omnes gentes: * Da pacem, Dómine, in diébus nostris." :verse "Creátor ómnium, Deus, terríbilis et fortis, justus et miséricors." :repeat "Da pacem, Dómine, in diébus nostris.")
     (:respond "Refúlsit sol in clípeos áureos, et resplenduérunt montes ab eis: * Et fortitúdo géntium dissipáta est." :verse "Erat enim exércitus magnus valde et fortis: et appropiávit Judas et exércitus ejus in prǽlio." :repeat "Et fortitúdo géntium dissipáta est.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("104" . (:scripture-refs ("2 Mac 1:1-6" "2 Mac 1:18-19" "2 Mac 1:20-22")
     :lessons ((:source "Ex Tractátu sancti Joánnis Chrysóstomi super Psalmum quadragésimum tértium" :text "Deus, áuribus nostris audívimus, patres nostri annuntiavérunt nobis opus quod operátus es in diébus eórum. Hunc Psalmum dicit quidem prophéta, dicit autem non ex persóna própria, sed ex persóna Machabæórum, narrans et prædícens quæ futúra erant illo témpore. Tales enim sunt prophétæ: ómnia témpora percúrrunt, præséntia, prætérita, futúra. Quinam sint autem hi Machabǽi, quidque passi sint et quid fécerint, necessárium est primum dícere, ut sint apertióra quæ in arguménto dicúntur. Ii enim, cum invasísset Judǽam Antíochus qui dictus est Epíphanes, et ómnia devastásset, et multos qui tunc erant, a pátriis institútis resilíre coëgísset, permansérunt illǽsi ab illis tentatiónibus.")
     (:source nil :text "Et quando grave quidem bellum ingruébat, nec quidquam possent fácere quod prodésset, se abscondébant; nam hoc quoque fecérunt Apóstoli. Non enim semper apparéntes in média irruébant perícula, sed nonnúmquam et fugiéntes, et laténtes secedébant. Postquam autem parum respirárunt, tamquam generósi quidam cátuli ex antris exsiliéntes et e látebris emergéntes, statuérunt non se ámplius solos serváre, sed étiam álios quoscúmque possent: et civitátem et omnem regiónem obeúntes, collegérunt quotquot invenérunt adhuc sanos et íntegros; et multos étiam qui laborábant et corrúpti erant, in statum prístinum redegérunt, eis persuadéntes redíre ad legem pátriam.")
     (:source nil :text "Deum enim dicébant esse benígnum et cleméntem, nec umquam adímere salútem, quæ proficíscitur ex pœniténtia. Hæc autem dicéntes, habuérunt deléctum fortissimórum virórum. Non enim pro uxóribus, líberis, et ancíllis, patriǽque eversióne et captivitáte, sed pro lege et pátria república pugnábant. Eórum autem dux erat Deus. Cum ergo áciem dirígerent, et suas ánimas prodígerent, fundébant adversários, non armis fidéntes, sed loco omnis armatúræ, pugnæ causam suffícere ducéntes. Ad bellum autem eúntes non tragœ́dias excitábant, non pæána canébant, sicut nonnúlli fáciunt: non ascivérunt tibícines, ut fit in áliis castris: sed Dei supérne auxílium invocábant, ut adésset, opem ferret et manum præbéret, propter quem bellum gerébant, pro cujus glória decertábant."))
     :responsories ((:respond "Adapériat Dóminus cor vestrum in lege sua et in præcéptis suis et fáciat pacem in diébus vestris: * Concédat vobis salútem, et rédimat vos a malis." :verse "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo." :repeat "Concédat vobis salútem, et rédimat vos a malis.")
     (:respond "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo, * Dóminus, Deus noster." :verse "Det vobis cor ómnibus, ut colátis eum et faciátis ejus voluntátem." :repeat "Dóminus, Deus noster.")
     (:respond "Congregáti sunt inimíci nostri, et gloriántur in virtúte sua: cóntere fortitúdinem illórum, Dómine, et dispérge illos: * Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster." :verse "Dispérge illos in virtúte tua, et déstrue eos, protéctor noster, Dómine." :repeat "Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster.")
     (:respond "Impetum inimicórum ne timuéritis: mémores estóte, quómodo salvi facti sunt patres nostri: * Et nunc clamémus in cælum et miserébitur nostri Deus noster." :verse "Mementóte mirabílium ejus, quæ fecit pharaóni et exercítui ejus in Mari Rubro." :repeat "Et nunc clamémus in cælum et miserébitur nostri Deus noster.")
     (:respond "Congregátæ sunt gentes in multitúdine, ut dímicent contra nos, et ignorámus quid ágere debeámus: * Dómine Deus, ad te sunt óculi nostri, ne pereámus." :verse "Tu scis quæ cógitant in nos: quómodo potérimus subsístere ante fáciem illórum, nisi tu ádjuves nos?" :repeat "Dómine Deus, ad te sunt óculi nostri, ne pereámus.")
     (:respond "Tua est poténtia, tuum regnum, Dómine: tu es super omnes gentes: * Da pacem, Dómine, in diébus nostris." :verse "Creátor ómnium, Deus, terríbilis et fortis, justus et miséricors." :repeat "Da pacem, Dómine, in diébus nostris.")
     (:respond "Refúlsit sol in clípeos áureos, et resplenduérunt montes ab eis: * Et fortitúdo géntium dissipáta est." :verse "Erat enim exércitus magnus valde et fortis: et appropiávit Judas et exércitus ejus in prǽlio." :repeat "Et fortitúdo géntium dissipáta est.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("105" . (:scripture-refs ("2 Mac 6:18-22" "2 Mac 6:23-28" "2 Mac 7:1-5")
     :lessons ((:source "Sermo sancti Gregorii Nazianzeni
Sermo 20 de Machabæis" :text "Eleázarus primítiæ eorum qui hic ante Christum sunt passi, quemadmodum post Christum Stephanus. Is vir et sacérdos et senex, canus capillis, canus et prudentia, prius quidem pro populo sacrificabat et orabat: nunc autem semetipsum hostiam obtulit Deo perfectissimam ad totius populi expiationem, faustum certaminis initium, ad quod loquens pariter ac tacens cohortabatur. Obtulit autem et filios septem, suæ fructus disciplinæ, hostiam viventem, sanctam, beneplacitam Deo, omni legali sacrificio splendidiorem et puriorem: quæ sunt enim filiorum, ad patrem referri, æquissimum ac justissimum est.")
     (:source nil :text "Ibi tum generosi et magnanimi pueri, generosæ matris nobilis proles, gloriosi veritatis propugnatores, Antiochi temporibus excelsiores, veri Mosaicæ legis discipuli, paternorum rituum observantissimi, numerus apud Hebræos laudabilis, et propter septenariæ quietis mysterium venerabilis unum spirantes, unum spectantes, unum illud ad vitam iter agnoscentes, ut mortem Dei causa susciperent: non minus animis fratres quam corporibus, inter se mutuæ mortis æmuli: o rem admirandam! tormenta quasi thesauros præripientes, pro magistra lege pericula subeuntes, quæ non magis illata formidabant, quam relicta requirebant, unum illud veriti, ne tyrannus a pœnis desisteret, ne quis ipsorum sine coronæ præmio discederet, ne inviti fratres alii ab alio sejungerentur, et ne, in eo discrimine cruciatibus erepti, mala victoria superarent.")
     (:source nil :text "Erat ibi fortis et generosa mater, puerorum simul ac Dei amans, cujus materna viscera supra naturæ consuetudinem dilaniabantur. Non enim filiorum, qui in tormentis erant, miserebatur, sed timore angebatur, ne non ea susciperent: neque magis eos, qui e vita migraverant, desiderabat, quam precabatur, ut reliqui cum illis conjungerentur: de quibus filiis magis quam de mortuis erat sollicita. Horum enim dubium erat certamen, at illorum securus vitæ exitus: atque illos quidem jam Deo adjunxerat; de his vero, quomodo eos Deus susciperet, laborabat. O virilem ánimum in corpore muliebri! o admirabile magni animi incrementum!"))
     :responsories ((:respond "Adapériat Dóminus cor vestrum in lege sua et in præcéptis suis et fáciat pacem in diébus vestris: * Concédat vobis salútem, et rédimat vos a malis." :verse "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo." :repeat "Concédat vobis salútem, et rédimat vos a malis.")
     (:respond "Exáudiat Dóminus oratiónes vestras, et reconciliétur vobis, nec vos déserat in témpore malo, * Dóminus, Deus noster." :verse "Det vobis cor ómnibus, ut colátis eum et faciátis ejus voluntátem." :repeat "Dóminus, Deus noster.")
     (:respond "Congregáti sunt inimíci nostri, et gloriántur in virtúte sua: cóntere fortitúdinem illórum, Dómine, et dispérge illos: * Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster." :verse "Dispérge illos in virtúte tua, et déstrue eos, protéctor noster, Dómine." :repeat "Ut cognóscant quia non est álius qui pugnet pro nobis, nisi tu, Deus noster.")
     (:respond "Impetum inimicórum ne timuéritis: mémores estóte, quómodo salvi facti sunt patres nostri: * Et nunc clamémus in cælum et miserébitur nostri Deus noster." :verse "Mementóte mirabílium ejus, quæ fecit pharaóni et exercítui ejus in Mari Rubro." :repeat "Et nunc clamémus in cælum et miserébitur nostri Deus noster.")
     (:respond "Congregátæ sunt gentes in multitúdine, ut dímicent contra nos, et ignorámus quid ágere debeámus: * Dómine Deus, ad te sunt óculi nostri, ne pereámus." :verse "Tu scis quæ cógitant in nos: quómodo potérimus subsístere ante fáciem illórum, nisi tu ádjuves nos?" :repeat "Dómine Deus, ad te sunt óculi nostri, ne pereámus.")
     (:respond "Tua est poténtia, tuum regnum, Dómine: tu es super omnes gentes: * Da pacem, Dómine, in diébus nostris." :verse "Creátor ómnium, Deus, terríbilis et fortis, justus et miséricors." :repeat "Da pacem, Dómine, in diébus nostris.")
     (:respond "Refúlsit sol in clípeos áureos, et resplenduérunt montes ab eis: * Et fortitúdo géntium dissipáta est." :verse "Erat enim exércitus magnus valde et fortis: et appropiávit Judas et exércitus ejus in prǽlio." :repeat "Et fortitúdo géntium dissipáta est.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("111" . (:scripture-refs (nil nil nil)
     :lessons ((:source "De Expositióne sancti Gregórii Papæ in Ezechiélem Prophétam
Liber 1, Homilía 2." :text "Usus prophéticæ locutiónis est, ut prius persónam, tempus, locúmque descríbat, et póstmodum dícere mystéria prophetíæ incípiat; quátenus ad veritátem solídius ostendéndam, ante, históriæ radícem figat, et post, fructus spíritus per signa et allegorías próferat. Ezéchiel ítaque ætátis suæ tempus índicat, dicens: Et factum est in trigésimo anno, in quarto mense, in quinta mensis. Locum quoque denúntians, adjúngit: Cum essem in médio captivórum juxta flumen Chobar, apérti sunt cæli, et vidi visiónes Dei. Tempus étiam insínuat, subdens, In quinta mensis, ipse est annus quintus transmigratiónis regis Jóachin. Qui ut bene persónam índicet, étiam genus narrat, cum súbditur: Et factum est verbum Dómini ad Ezechiélem, fílium Buzi, sacerdótem.")
     (:source nil :text "Sed prima quǽstio nobis óritur, cur is qui nihil adhuc díxerat, ita exórsus est dicens: Et factum est in trigésimo anno. Et, namque sermo conjunctiónis est: et scimus quia non conjúngitur sermo súbsequens, nisi sermóni præcedénti. Qui ígitur nihil díxerat, cur dicit, Et factum est: cum non sit sermo, cui hoc quod íncipit, subjúngat? Qua in re intuéndum est, quia sicut nos corporália, sic prophétæ sensu spiritália aspíciunt; eísque et illa sunt præséntia, quæ nostræ ignorántiæ abséntia vidéntur. Unde fit, ut in mente prophetárum ita conjúncta sint exterióribus interióra, quátenus simul útraque vídeant, simúlque in eis fiat et intus verbum quod áudiunt, et foris quod dicunt.")
     (:source nil :text "Patet ígitur causa, cur qui nihil díxerat, inchoávit dicens: Et factum est in trigésimo anno: quia hoc verbum quod foris prótulit, illi verbo quod intus audíerat, conjúnxit. Continuávit ergo verba quæ prótulit visióni íntimæ, et idcírco íncipit dicens, Et factum est. Subjúnxit enim hoc quod extérius loqui ínchoat; ac si et illud foris sit, quod intus vidit. Hoc autem quod dícitur, quia in trigésimo anno spíritum prophetíæ accéperit, índicat áliquid nobis considerándum; vidélicet quia juxta ratiónis usum, doctrínæ sermo non súppetit, nisi in ætáte perfécta. Unde et ipse Dóminus anno duodécimo ætátis suæ in médio doctórum in templo sedens, non docens sed intérrogans vóluit inveníri."))
     :responsories ((:respond "Vidi Dóminum sedéntem super sólium excélsum et elevátum, et plena erat omnis terra majestáte ejus: * Et ea, quæ sub ipso erant, replébant templum." :verse "Séraphim stabant super illud: sex alæ uni, et sex alæ álteri." :repeat "Et ea, quæ sub ipso erant, replébant templum.")
     (:respond "Aspice, Dómine, de sede sancta tua, et cógita de nobis: inclína, Deus meus, aurem tuam et audi: * Aperi óculos tuos et vide tribulatiónem nostram." :verse "Qui regis Israël, inténde, qui dedúcis velut ovem Joseph." :repeat "Aperi óculos tuos et vide tribulatiónem nostram.")
     (:respond "Aspice, Dómine, quia facta est desoláta cívitas plena divítiis, sedet in tristítia dómina géntium: * Non est qui consolétur eam, nisi tu, Deus noster." :verse "Plorans plorávit in nocte, et lácrimæ ejus in maxíllis ejus." :repeat "Non est qui consolétur eam, nisi tu, Deus noster.")
     (:respond "Super muros tuos, Jerúsalem, constítui custódes; * Tota die et nocte non tacébunt laudáre nomen Dómini." :verse "Prædicábunt pópulis fortitúdinem meam, et annuntiábunt géntibus glóriam meam." :repeat "Tota die et nocte non tacébunt laudáre nomen Dómini.")
     (:respond "Muro tuo inexpugnábili circumcínge nos, Dómine, et armis tuæ poténtiæ prótege nos semper: * Líbera, Dómine, Deus Israël, clamántes ad te." :verse "Erue nos in mirabílibus tuis, et da glóriam nómini tuo." :repeat "Líbera, Dómine, Deus Israël, clamántes ad te.")
     (:respond "Sustinúimus pacem, et non venit: quæsívimus bona, et ecce turbátio: cognóvimus, Dómine, peccáta nostra; * Non in perpétuum obliviscáris nos." :verse "Peccávimus, ímpie géssimus, iniquitátem fécimus, Dómine, in omnem justítiam tuam." :repeat "Non in perpétuum obliviscáris nos.")
     (:respond "Laudábilis pópulus, * Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël." :verse "Beáta gens, cujus est Dóminus Deus, pópulus eléctus in hereditátem." :repeat "Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("112" . (:scripture-refs ("Ezek 21:1-5" "Ezek 21:6-11" "Ezek 21:12-15")
     :lessons ((:source "De Expositióne sancti Hierónymi Presbýteri in Ezechielem Prophetam.
Liber 7 in Ezechiel. cap. 21." :text "Quia supra dixerat: Ipsi dicunt ad me: Numquid non per parábolas lóquitur iste? et apertam pópulus flagitábat senténtiam: idcirco id quod Dóminus per metáphoram, sive parábolam, et, ut alii vertére, proverbium, est locútus, nunc manifestius lóquitur: saltus Nageb et Darom et Theman esse Jerúsalem, et templus illíus, sancta sanctórum et omnem terram Judææ; flammámque quæ combustura sit saltum, intelligi gládium devorántem, qui edúctus sit de vagina sua, ut interfíciat justum et ímpium. Hoc est enim lignum víride, et lignum aridum. Unde et Dóminus: si in ligno, ait, víridi tanta faciunt, in sicco quid facient?")
     (:source nil :text "Primum dixerat: Vaticinare, vel stilla ad Austrum, Africum et Meridiem et ad saltum Meridianum. Quod quia videbátur obscurum, et dicta Prophetæ pópulus nesciebat, secúndo pónitur manifestius, saltum Meridianum esse Jerúsalem; et omnes infructuosas árbores, ad quarum radíces securis posita sit, intelligi habitatóres ejus, gladiúmque interpretari pro incendio. Tertio jubétur Prophetæ, ut tacéntibus illis nec interrogántibus cur ista vaticinátus sit, fáciat per quæ interrogétur, et respondeat quæ Dóminus locútus est.")
     (:source nil :text "Ingemísce, inquit, ejulare non levi voce nec dolóre moderáto, sed in contritióne lumbórum, ut gémitus tuus ex imis viscéribus et amaritúdine animi proferátur. Et hoc fácies coram eis, ut cum te interrogáverint, cur tanto gémitu conteraris, et quid tibi mali accíderit, ut sic ingemiscas; tu eis meo sermóne respondeas: Idcirco plango et dolórem cordis mei dissimuláre non valeo, quia audítus, qui semper meis áuribus insonúerat, opere complétur et venit, ímminens videlicet Babylonii furentis exercitus; qui cum venerit et vallaverit Jerúsalem, tunc tabescet omne cor, et dissolvéntur univérsæ manus: ut occupante pavóre mentes hóminum, nullus audeat repugnare."))
     :responsories ((:respond "Vidi Dóminum sedéntem super sólium excélsum et elevátum, et plena erat omnis terra majestáte ejus: * Et ea, quæ sub ipso erant, replébant templum." :verse "Séraphim stabant super illud: sex alæ uni, et sex alæ álteri." :repeat "Et ea, quæ sub ipso erant, replébant templum.")
     (:respond "Aspice, Dómine, de sede sancta tua, et cógita de nobis: inclína, Deus meus, aurem tuam et audi: * Aperi óculos tuos et vide tribulatiónem nostram." :verse "Qui regis Israël, inténde, qui dedúcis velut ovem Joseph." :repeat "Aperi óculos tuos et vide tribulatiónem nostram.")
     (:respond "Aspice, Dómine, quia facta est desoláta cívitas plena divítiis, sedet in tristítia dómina géntium: * Non est qui consolétur eam, nisi tu, Deus noster." :verse "Plorans plorávit in nocte, et lácrimæ ejus in maxíllis ejus." :repeat "Non est qui consolétur eam, nisi tu, Deus noster.")
     (:respond "Super muros tuos, Jerúsalem, constítui custódes; * Tota die et nocte non tacébunt laudáre nomen Dómini." :verse "Prædicábunt pópulis fortitúdinem meam, et annuntiábunt géntibus glóriam meam." :repeat "Tota die et nocte non tacébunt laudáre nomen Dómini.")
     (:respond "Muro tuo inexpugnábili circumcínge nos, Dómine, et armis tuæ poténtiæ prótege nos semper: * Líbera, Dómine, Deus Israël, clamántes ad te." :verse "Erue nos in mirabílibus tuis, et da glóriam nómini tuo." :repeat "Líbera, Dómine, Deus Israël, clamántes ad te.")
     (:respond "Sustinúimus pacem, et non venit: quæsívimus bona, et ecce turbátio: cognóvimus, Dómine, peccáta nostra; * Non in perpétuum obliviscáris nos." :verse "Peccávimus, ímpie géssimus, iniquitátem fécimus, Dómine, in omnem justítiam tuam." :repeat "Non in perpétuum obliviscáris nos.")
     (:respond "Laudábilis pópulus, * Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël." :verse "Beáta gens, cujus est Dóminus Deus, pópulus eléctus in hereditátem." :repeat "Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("113" . (:scripture-refs ("Dan 1:1-4" "Dan 1:5-9" "Dan 1:10-15")
     :lessons ((:source "Ex libro sancti Athanásii Epíscopi ad Vírgines
Liber de Virginitate, post initium." :text "Si accédant áliqui, e dicant tibi: Ne frequénter jejúnes, ne imbecíllior fias; ne credas illis, neque auscúltes: per istos enim inimícus hæc súggerit. Reminíscere ejus quod scriptum est, quod, cum tres púeri, et Dániel, et álii adolescéntuli, captívi ducti essent a Nabuchodónosor rege Babylónis, jussúmque esset ut de ipsíus mensa régia coméderent et de vino bíberent; Dániel et tres púeri illi noluérunt póllui ex mensa regis, sed dixérunt eunúcho qui eos curándos suscéperat: Da nobis de semínibus terræ, et vescémur. Quibus ait eunúchus: Tímeo ego regem, qui constítuit vobis cibum et potum, ne forte fácies vestræ appáreant regi squalidióres præ céteris púeris qui régia mensa alúntur, et púniat me.")
     (:source nil :text "Cui dixérunt illi: Tenta servos tuos dies decem, et da nobis de semínibus. Et dedit eis legúmina ad vescéndum, et aquam ad bibéndum; et introdúxit eos in conspéctu regis, et visæ sunt fácies ipsórum speciosióres præter céteros púeros, qui régiæ mensæ cibis nutriebántur. Vidésne quid fáciat jejúnium? Morbos sanat, distillatiónes córporis exsíccat, dǽmones fugat, pravas cogitatiónes expéllit, mentem clariórem reddit, cor mundum éfficit, corpus sanctíficat, dénique ad thronum Dei hóminem sistit. Et ne putes hæc témere dici; habes hujus rei testimónium in Evangéliis a Salvatóre prolátum. Cum enim quæsivíssent discípuli quonam modo immúndi spíritus ejiceréntur, respóndit Dóminus: Hoc genus non ejícitur, nisi in oratióne et jejúnio.")
     (:source nil :text "Quisquis ígitur ab immúndo spíritu vexátur, si hoc animadvértat, et hoc phármaco utátur, jejúnio inquam, statim spíritus malus oppréssus abscédet, vim jejúnii métuens. Valde enim dǽmones oblectántur crápula et ebrietáte et córporis cómmodis. Magna vis in jejúnio, et magna ac præclára fiunt per illud. Alióquin unde hómines tam mirífica præstárent, et signa per eos fíerent, et sanitátem infírmis per ipsos largirétur Deus, nisi plane ob exercitatiónes spirituáles, et humilitátem ánimi, et conversatiónem bonam? Jejúnium enim Angelórum cibus est: et qui eo útitur, órdinis angélici censéndus est."))
     :responsories ((:respond "Vidi Dóminum sedéntem super sólium excélsum et elevátum, et plena erat omnis terra majestáte ejus: * Et ea, quæ sub ipso erant, replébant templum." :verse "Séraphim stabant super illud: sex alæ uni, et sex alæ álteri." :repeat "Et ea, quæ sub ipso erant, replébant templum.")
     (:respond "Aspice, Dómine, de sede sancta tua, et cógita de nobis: inclína, Deus meus, aurem tuam et audi: * Aperi óculos tuos et vide tribulatiónem nostram." :verse "Qui regis Israël, inténde, qui dedúcis velut ovem Joseph." :repeat "Aperi óculos tuos et vide tribulatiónem nostram.")
     (:respond "Aspice, Dómine, quia facta est desoláta cívitas plena divítiis, sedet in tristítia dómina géntium: * Non est qui consolétur eam, nisi tu, Deus noster." :verse "Plorans plorávit in nocte, et lácrimæ ejus in maxíllis ejus." :repeat "Non est qui consolétur eam, nisi tu, Deus noster.")
     (:respond "Super muros tuos, Jerúsalem, constítui custódes; * Tota die et nocte non tacébunt laudáre nomen Dómini." :verse "Prædicábunt pópulis fortitúdinem meam, et annuntiábunt géntibus glóriam meam." :repeat "Tota die et nocte non tacébunt laudáre nomen Dómini.")
     (:respond "Muro tuo inexpugnábili circumcínge nos, Dómine, et armis tuæ poténtiæ prótege nos semper: * Líbera, Dómine, Deus Israël, clamántes ad te." :verse "Erue nos in mirabílibus tuis, et da glóriam nómini tuo." :repeat "Líbera, Dómine, Deus Israël, clamántes ad te.")
     (:respond "Sustinúimus pacem, et non venit: quæsívimus bona, et ecce turbátio: cognóvimus, Dómine, peccáta nostra; * Non in perpétuum obliviscáris nos." :verse "Peccávimus, ímpie géssimus, iniquitátem fécimus, Dómine, in omnem justítiam tuam." :repeat "Non in perpétuum obliviscáris nos.")
     (:respond "Laudábilis pópulus, * Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël." :verse "Beáta gens, cujus est Dóminus Deus, pópulus eléctus in hereditátem." :repeat "Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("114" . (:scripture-refs ("Osee 1:1-3" "Osee 1:4-7" "Osee 1:8-11")
     :lessons ((:source "Ex libro sancti Augustíni Epíscopi de Civitáte Dei
Liber 18, cap. 28." :text "Osée prophéta, quanto profúndius quidem lóquitur, tanto operósius penetrátur. Sed áliquid inde suméndum est, et hic ex nostra promissióne ponéndum. Et erit, inquit, in loco quo dictum est eis, Non pópulus meus vos; vocabúntur et ipsi fílii Dei vivi. Hoc testimónium prophéticum de vocatióne pópuli Géntium, qui prius non pertinébat ad Deum, étiam Apóstoli intellexérunt.")
     (:source nil :text "Et quia ipse quoque pópulus Géntium spiritáliter est in fíliis Abrahæ, ac per hoc recte dícitur Israël; proptérea séquitur, et dicit: Et congregabúntur fílii Juda et fílii Israël in idípsum, et ponent síbimet principátum unum, et ascéndent a terra. Hoc si adhuc velímus expónere, elóquii prophétici obtundétur sapor. Recolátur tamen lapis ille anguláris, et duo illi paríetes, unus ex Judǽis, alter ex Géntibus: ille nómine filiórum Juda, iste nómine filiórum Israël, eídem uni principátui suo in idípsum inniténtes, et ascendéntes agnoscántur in terra.")
     (:source nil :text "Istos autem carnáles Israëlítas, qui nunc nolunt crédere in Christum, póstea creditúros, id est fílios eórum, (nam útique isti in suum locum moriéndo transíbunt) idem prophéta testátur, dicens: Quóniam diébus multis sedébunt fílii Israël sine rege, sine príncipe, sine sacrifício, sine altári, sine sacerdótio, sine manifestatiónibus. Quis non vídeat, nunc sic esse Judǽos?"))
     :responsories ((:respond "Vidi Dóminum sedéntem super sólium excélsum et elevátum, et plena erat omnis terra majestáte ejus: * Et ea, quæ sub ipso erant, replébant templum." :verse "Séraphim stabant super illud: sex alæ uni, et sex alæ álteri." :repeat "Et ea, quæ sub ipso erant, replébant templum.")
     (:respond "Aspice, Dómine, de sede sancta tua, et cógita de nobis: inclína, Deus meus, aurem tuam et audi: * Aperi óculos tuos et vide tribulatiónem nostram." :verse "Qui regis Israël, inténde, qui dedúcis velut ovem Joseph." :repeat "Aperi óculos tuos et vide tribulatiónem nostram.")
     (:respond "Aspice, Dómine, quia facta est desoláta cívitas plena divítiis, sedet in tristítia dómina géntium: * Non est qui consolétur eam, nisi tu, Deus noster." :verse "Plorans plorávit in nocte, et lácrimæ ejus in maxíllis ejus." :repeat "Non est qui consolétur eam, nisi tu, Deus noster.")
     (:respond "Super muros tuos, Jerúsalem, constítui custódes; * Tota die et nocte non tacébunt laudáre nomen Dómini." :verse "Prædicábunt pópulis fortitúdinem meam, et annuntiábunt géntibus glóriam meam." :repeat "Tota die et nocte non tacébunt laudáre nomen Dómini.")
     (:respond "Muro tuo inexpugnábili circumcínge nos, Dómine, et armis tuæ poténtiæ prótege nos semper: * Líbera, Dómine, Deus Israël, clamántes ad te." :verse "Erue nos in mirabílibus tuis, et da glóriam nómini tuo." :repeat "Líbera, Dómine, Deus Israël, clamántes ad te.")
     (:respond "Sustinúimus pacem, et non venit: quæsívimus bona, et ecce turbátio: cognóvimus, Dómine, peccáta nostra; * Non in perpétuum obliviscáris nos." :verse "Peccávimus, ímpie géssimus, iniquitátem fécimus, Dómine, in omnem justítiam tuam." :repeat "Non in perpétuum obliviscáris nos.")
     (:respond "Laudábilis pópulus, * Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël." :verse "Beáta gens, cujus est Dóminus Deus, pópulus eléctus in hereditátem." :repeat "Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    ("115" . (:scripture-refs ("Mic 1:1-3" "Mic 1:4-6" "Mic 1:7-9")
     :lessons ((:source "Sermo sancti Basilíi Magni in Psalmum trigésimum tértium
Homilia in Ps. 33, n. 8" :text "Cum te appetítus inváserit peccándi, velim cógites horríbile illud et intolerábile Christi tribúnal, in quo præsidébit judex in alto et excélso throno; astábit autem omnis creatúra, ad gloriósum illíus conspéctum contremíscens. Adducéndi étiam nos sumus sínguli, eórum quæ in vita gessérimus ratiónem redditúri. Mox illis qui multa mala in vita perpetrárint, terríbiles quidam et deformes assistent angeli, igneos vultus præ se feréntes atque ignem spirántes, ea re propositi et voluntátis acerbitátem ostendéntes, nocti vultu similes, propter mærórem et ódium in humánum genus.")
     (:source nil :text "Ad hæc cógites profúndum bárathrum, inextricábiles ténebras, ignem caréntem splendore, uréndi quidem vim habéntem, sed privátum lúmine: deínde vermium genus venénum immittens, et carnem vorans, inexplebíliter edens neque umquam saturitátem sentiens, intolerábiles dolóres corrosióne ipsa infígens: postremo, quod suppliciórum ómnium gravíssimum est, oppróbrium illud et confusiónem sempiternam. Hæc time, et hoc timóre correptus ánimam a peccatórum concupiscéntia tamquam freno quodam réprime.")
     (:source nil :text "Hunc timórem Dómini se docturum prophéta promisit. Docére autem non simpliciter promisit, sed eos qui eum audíre volúerint: non eos qui longius prolapsi sunt, sed qui salútem appeténtes accurrunt: non alienos a promissiónibus, sed ex baptismate filiórum adoptiónis verbo ipsi consiliatos atque conjunctos. Proptérea, Veníte, inquit, hoc est, per bona ópera accédite ad me, fílii, quippe qui per regeneratiónem fílii lucis effici digni facti estis: audíte, qui aures cordis habetis apértas; timórem Dómini docébo vos: illum scilicet, quem paulo ante oratióne nostra descrípsimus."))
     :responsories ((:respond "Vidi Dóminum sedéntem super sólium excélsum et elevátum, et plena erat omnis terra majestáte ejus: * Et ea, quæ sub ipso erant, replébant templum." :verse "Séraphim stabant super illud: sex alæ uni, et sex alæ álteri." :repeat "Et ea, quæ sub ipso erant, replébant templum.")
     (:respond "Aspice, Dómine, de sede sancta tua, et cógita de nobis: inclína, Deus meus, aurem tuam et audi: * Aperi óculos tuos et vide tribulatiónem nostram." :verse "Qui regis Israël, inténde, qui dedúcis velut ovem Joseph." :repeat "Aperi óculos tuos et vide tribulatiónem nostram.")
     (:respond "Aspice, Dómine, quia facta est desoláta cívitas plena divítiis, sedet in tristítia dómina géntium: * Non est qui consolétur eam, nisi tu, Deus noster." :verse "Plorans plorávit in nocte, et lácrimæ ejus in maxíllis ejus." :repeat "Non est qui consolétur eam, nisi tu, Deus noster.")
     (:respond "Super muros tuos, Jerúsalem, constítui custódes; * Tota die et nocte non tacébunt laudáre nomen Dómini." :verse "Prædicábunt pópulis fortitúdinem meam, et annuntiábunt géntibus glóriam meam." :repeat "Tota die et nocte non tacébunt laudáre nomen Dómini.")
     (:respond "Muro tuo inexpugnábili circumcínge nos, Dómine, et armis tuæ poténtiæ prótege nos semper: * Líbera, Dómine, Deus Israël, clamántes ad te." :verse "Erue nos in mirabílibus tuis, et da glóriam nómini tuo." :repeat "Líbera, Dómine, Deus Israël, clamántes ad te.")
     (:respond "Sustinúimus pacem, et non venit: quæsívimus bona, et ecce turbátio: cognóvimus, Dómine, peccáta nostra; * Non in perpétuum obliviscáris nos." :verse "Peccávimus, ímpie géssimus, iniquitátem fécimus, Dómine, in omnem justítiam tuam." :repeat "Non in perpétuum obliviscáris nos.")
     (:respond "Laudábilis pópulus, * Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël." :verse "Beáta gens, cujus est Dóminus Deus, pópulus eléctus in hereditátem." :repeat "Quem Dóminus exercítuum benedíxit dicens: Opus mánuum meárum tu es, heréditas mea Israël.")
     (:respond "Duo Séraphim clamábant alter ad álterum: * Sanctus, sanctus, sanctus Dóminus Deus Sábaoth: * Plena est omnis terra glória ejus." :verse "Tres sunt qui testimónium dant in cælo: Pater, Verbum, et Spíritus Sanctus: et hi tres unum sunt." :repeat "Plena est omnis terra glória ejus."))))
    )
  "Scriptura occurrens: month-week indexed Matins data.
Scripture refs for Nocturn I (L1-L3), patristic lessons for Nocturn II (L4-L6),
and responsories for all three nocturns (R1-R8).
Indexed by month-week key (e.g. \"081\" = August week 1).")



(defun bcp-roman-tempora--month-week-key (date)
  "Return the month-week key string for DATE, e.g. \"081\" for August week 1.
DATE is (MONTH DAY YEAR).  Week 1 = day 1-7, week 2 = day 8-14, etc."
  (let ((month (car date))
        (day (cadr date)))
    (format "%02d%d" month (1+ (/ (1- day) 7)))))

(defun bcp-roman-tempora-dominical-matins (date)
  "Return the dominical Matins data for the Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories.
For Sundays with complete Pent data (Pent01-11), returns that directly.
For later Sundays, merges Nocturn I-II from scriptura occurrens (month-week)
with Nocturn III lessons from the Pent table.  Returns nil outside Per Annum."
  (let* ((n (bcp-roman-tempora--pent-number date))
         (pent-data (when n (alist-get n bcp-roman-tempora--dominical-matins))))
    (when pent-data
      (let ((lessons (plist-get pent-data :lessons)))
        ;; If Nocturn I is populated (L1 non-nil), Pent data is complete
        (if (nth 0 lessons)
            pent-data
          ;; Merge with scriptura occurrens
          (let* ((mw-key (bcp-roman-tempora--month-week-key date))
                 (mw-data (cdr (assoc mw-key
                                       bcp-roman-tempora--scriptura-occurrens))))
            (if (null mw-data)
                pent-data  ; fallback: return whatever Pent has
              (let* ((refs (plist-get mw-data :scripture-refs))
                     (mw-lessons (plist-get mw-data :lessons))
                     (mw-resps (plist-get mw-data :responsories))
                     (pent-lessons (plist-get pent-data :lessons))
                     (pent-resps (plist-get pent-data :responsories))
                     ;; L1-L3: scripture refs from month-week
                     (l1 (list :ref (nth 0 refs)))
                     (l2 (list :ref (nth 1 refs)))
                     (l3 (list :ref (nth 2 refs)))
                     ;; L4-L6: patristic from month-week
                     (l4 (nth 0 mw-lessons))
                     (l5 (nth 1 mw-lessons))
                     (l6 (nth 2 mw-lessons))
                     ;; L7-L9: homily from Pent table
                     (l7 (nth 6 pent-lessons))
                     (l8 (nth 7 pent-lessons))
                     (l9 (nth 8 pent-lessons))
                     ;; R1-R7 from month-week; R8 from Pent table if
                     ;; available, otherwise from month-week
                     (pent-r8 (nth 7 pent-resps))
                     (merged-resps
                      (if (and mw-resps (>= (length mw-resps) 8))
                          (if pent-r8
                              (append (cl-subseq mw-resps 0 7)
                                      (list pent-r8))
                            mw-resps)
                        pent-resps)))
                (list :lessons (list l1 l2 l3 l4 l5 l6 l7 l8 l9)
                      :responsories merged-resps)))))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Ferial Matins lessons and responsories

;; Post-Pentecost ferial Matins (DA 1911): 1 nocturn, 3 scripture lessons
;; + 3 responsories.  Scripture readings follow the weekly Pent cycle
;; (1 Kings through Maccabees over weeks 1-11).
;;
;; Key: (WEEK . DOW) where WEEK is 1-11, DOW is 1=Mon..6=Sat.
;; Weeks 12-24 have no proper ferial lessons in the DO files; their
;; scriptura occurrens comes from the month-based system.
;; Some responsories are nil where the DO source uses monastic or
;; rubric-qualified references only.

(defconst bcp-roman-tempora--ferial-matins
  '(
    ;; Pent01-1: Feria Secunda infra Hebdomadam I post Octavam Pentecostes
    ((1 . 1) . (:lessons
              ((:source "Incipit liber primus Regum"
               :ref "1 Reg 1:1-3"
               :text "1 Fuit vir unus de Ramáthaim Sophim, de monte Ephraim, et nomen ejus Elcana, fílius Iéroham, fílii Eliu, fílii Thohu, fílii Suph, Ephrathǽus:
2 et hábuit duas uxóres, nomen uni Anna, et nomen secúndæ Phenénna. Fuerúntque Phenénnæ fílii: Annæ autem non erant líberi.
3 Et ascendébat vir ille de civitáte sua statútis diébus, ut adoráret et sacrificáret Dómino exercítuum in Silo. Erant autem ibi duo fílii Heli, Ophni et Phínees, sacerdótes Dómini.")
               (:ref "1 Reg 1:4-8"
               :text "4 Venit ergo dies, et immolávit Elcana, dedítque Phenénnæ uxóri suæ, et cunctis fíliis ejus et filiábus, partes:
5 Annæ autem dedit partem unam tristis, quia Annam diligébat. Dóminus autem conclúserat vulvam ejus.
6 Affligébat quoque eam ǽmula ejus, et veheménter angébat, in tantum ut exprobráret quod Dóminus conclusísset vulvam ejus:
7 sicque faciébat per síngulos annos: cum redeúnte témpore ascénderent ad templum Dómini, et sic provocábat eam: porro illa flebat, et non capiébat cibum.
8 Dixit ergo ei Elcana vir suus: Anna, cur fles? et quare non cómedis? et quam ob rem afflígitur cor tuum? numquid non ego mélior tibi sum, quam decem fílii?")
               (:ref "1 Reg 1:9-11"
               :text "9 Surréxit autem Anna postquam coméderat et bíberat in Silo. Et Heli sacerdóte sedénte super sellam ante postes templi Dómini,
10 cum esset Anna amáro ánimo, orávit ad Dóminum, flens lárgiter,
11 et votum vovit, dicens: Dómine exercítuum, si respíciens víderis afflictiónem fámulæ tuæ, et recordátus mei fúeris, nec oblítus ancíllæ tuæ, dederísque servæ tuæ sexum virílem: dabo eum Dómino ómnibus diébus vitæ ejus, et novácula non ascéndet super caput ejus."))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent01-2: Feria Tertia infra Hebdomadam I post Octavam Pentecostes
    ((1 . 2) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 1:12-18"
               :text "12 Factum est autem, cum illa multiplicáret preces coram Dómino, ut Heli observáret os ejus.
13 Porro Anna loquebátur in corde suo, tantúmque lábia illíus movebántur, et vox pénitus non audiebátur. Æstimávit ergo eam Heli temuléntam,
14 dixítque ei: Usquequo ébria eris? dígere paulísper vinum, quo mades.
15 Respóndens Anna: Nequáquam, inquit, dómine mi: nam múlier infélix nimis ego sum: vinúmque et omne quod inebriáre potest, non bibi, sed effúdi ánimam meam in conspéctu Dómini.
16 Ne réputes ancíllam tuam quasi unam de filiábus Bélial: quia ex multitúdine dolóris et mæróris mei locúta sum usque in præsens.
17 Tunc Heli ait ei: Vade in pace: et Deus Israël det tibi petitiónem tuam quam rogásti eum.
18 Et illa dixit: Utinam invéniat ancílla tua grátiam in óculis tuis.")
               (:ref "1 Reg 1:18-22"
               :text "18 Et ábiit múlier in viam suam, et comédit, vultúsque illíus non sunt ámplius in divérsa mutáti.
19 Et surrexérunt mane, et adoravérunt coram Dómino: reversíque sunt, et venérunt in domum suam Rámatha. Cognóvit autem Elcana Annam uxórem suam: et recordátus est ejus Dóminus.
20 Et factum est post círculum diérum, concépit Anna, et péperit fílium: vocavítque nomen ejus Sámuel, eo quod a Dómino postulásset eum.
21 Ascéndit autem vir ejus Elcana, et omnis domus ejus, ut immoláret Dómino hóstiam solémnem, et votum suum.
22 Et Anna non ascéndit: dixit enim viro suo: Non vadam donec ablactétur infans, et ducam eum, ut appáreat ante conspéctum Dómini, et máneat ibi júgiter.")
               (:ref "1 Reg 1:23-28"
               :text "23 Et ait ei Elcana vir suus: Fac quod bonum tibi vidétur, et mane donec abláctes eum: precórque ut ímpleat Dóminus verbum suum. Mansit ergo múlier, et lactávit fílium suum, donec amovéret eum a lacte.
24 Et addúxit eum secum, postquam ablactáverat, in vítulis tribus, et tribus módiis farínæ, et ámphora vini, et addúxit eum ad domum Dómini in Silo. Puer autem erat adhuc infántulus:
25 et immolavérunt vítulum, et obtulérunt púerum Heli.
26 Et ait Anna: Obsecro mi dómine, vivit ánima tua, dómine: ego sum illa múlier, quæ steti coram te hic orans Dóminum.
27 Pro púero isto orávi, et dedit mihi Dóminus petitiónem meam quam postulávi eum.
28 Idcírco et ego commodávi eum Dómino cunctis diébus quibus fúerit commodátus Dómino. Et adoravérunt ibi Dóminum."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent01-3: Feria Quarta infra Hebdomadam I post Octavam Pentecostes
    ((1 . 3) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 2:12-14"
               :text "12 Porro fílii Heli, fílii Bélial, nesciéntes Dóminum,
13 neque offícium sacerdótum ad pópulum: sed quicúmque immolásset víctimam, veniébat puer sacerdótis, dum coqueréntur carnes, et habébat fuscínulam tridéntem in manu sua,
14 et mittébat eam in lebétem, vel in caldáriam, aut in ollam, sive in cácabum: et omne quod levábat fuscínula, tollébat sacérdos sibi: sic faciébant univérso Israéli veniéntium in Silo.")
               (:ref "1 Reg 2:15-17"
               :text "15 Etiam ántequam adolérent ádipem, veniébat puer sacerdótis, et dicébat immolánti: Da mihi carnem, ut coquam sacerdóti: non enim accípiam a te carnem coctam, sed crudam.
16 Dicebátque illi ímmolans: Incendátur primum juxta morem hódie adeps, et tolle tibi quantumcúmque desíderat ánima tua. Qui respóndens ajébat ei: Nequáquam: nunc enim dabis, alióquin tollam vi.
17 Erat ergo peccátum puerórum grande nimis coram Dómino: quia retrahébant hómines a sacrifício Dómini.")
               (:ref "1 Reg 2:18-21"
               :text "18 Sámuel autem ministrábat ante fáciem Dómini, puer accínctus ephod líneo.
19 Et túnicam parvam faciébat ei mater sua, quam afferébat statútis diébus, ascéndens cum viro suo, ut immoláret hóstiam solémnem.
20 Et benedíxit Heli Elcanæ et uxóri ejus: dixítque ei: Reddat tibi Dóminus semen de mulíere hac, pro fœ́nore quod commodásti Dómino. Et abiérunt in locum suum.
21 Visitávit ergo Dóminus Annam, et concépit, et péperit tres fílios, et duas fílias: et magnificátus est puer Sámuel apud Dóminum."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent01-4: Festum Sanctissimi Corporis Christi
    ((1 . 4) . (:lessons
              ((:source "De Epístola prima beáti Pauli Apóstoli ad Corínthios"
               :ref "1 Cor 11:20-22"
               :text "20 Conveniéntibus ergo vobis in unum, jam non est Domínicam cenam manducáre.
21 Unusquísque enim suam cenam præsúmit ad manducándum. Et álius quidem ésurit, álius autem ébrius est.
22 Numquid domos non habétis ad manducándum et bibéndum? aut Ecclésiam Dei contémnitis, et confúnditis eos, qui non habent? Quid dicam vobis? Laudo vos? In hoc non laudo.")
               (:ref "1 Cor 11:23-26"
               :text "23 Ego enim accépi a Dómino quod et trádidi vobis, quóniam Dóminus Jesus, in qua nocte tradebátur, accépit panem,
24 et grátias agens fregit, et dixit: Accípite, et manducáte: hoc est corpus meum, quod pro vobis tradétur: hoc fácite in meam commemoratiónem.
25 Simíliter et cálicem, postquam cœnávit, dicens: Hic calix novum testaméntum est in meo sánguine: hoc fácite, quotiescúmque bibétis, in meam commemoratiónem.
26 Quotiescúmque enim manducábitis panem hunc, et cálicem bibétis, mortem Dómini annuntiábitis donec véniat.")
               (:ref "1 Cor 11:27-32"
               :text "27 Itaque quicúmque manducáverit panem hunc, vel bíberit cálicem Dómini indígne, reus erit córporis et sánguinis Dómini.
28 Probet autem seípsum homo: et sic de pane illo edat, et de cálice bibat.
29 Qui enim mandúcat et bibit indígne, judícium sibi mandúcat et bibit, non dijúdicans corpus Dómini.
30 Ideo inter vos multi infírmi et imbecílles, et dórmiunt multi.
31 Quod, si nosmetípsos dijudicarémus, non útique judicarémur.
32 Dum judicámur autem, a Dómino corrípimur, ut non cum hoc mundo damnémur."))
              :responsories
              ((:respond "Immolábit hædum multitúdo filiórum Israël ad vésperam Paschæ:"
                  :verse "Pascha nostrum immolátus est Christus: ítaque epulémur in ázymis sinceritátis et veritátis."
                  :repeat "Et edent carnes et ázymos panes."
                  :gloria nil)
               (:respond "Comedétis carnes, et saturabímini pánibus:"
                  :verse "Non Móyses dedit vobis panem de cælo, sed Pater meus dat vobis panem de cælo verum."
                  :repeat "Iste est panis, quem dedit vobis Dóminus ad vescéndum."
                  :gloria nil)
               (:respond "Respéxit Elías ad caput suum subcinerícium panem: qui surgens comédit et bibit:"
                  :verse "Si quis manducáverit ex hoc pane, vivet in ætérnum."
                  :repeat "Et ambulávit in fortitúdine cibi illíus usque ad montem Dei."
                  :gloria t))))

    ;; Pent01-5: Feria VI infra Hebdomadam I post Octavam Pentecostes
    ((1 . 5) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 2:27-29"
               :text "27 Venit autem vir Dei ad Heli, et ait ad eum: Hæc dicit Dóminus: Numquid non apérte revelátus sum dómui patris tui, cum essent in Ægýpto in domo Pharaónis?
28 Et elégi eum ex ómnibus tríbubus Israël mihi in sacerdótem, ut ascénderet ad altáre meum, et adoléret mihi incénsum, et portáret ephod coram me: et dedi dómui patris tui ómnia de sacrifíciis filiórum Israël.
29 Quare calce abiecístis víctimam meam, et múnera mea quæ præcépi ut offerréntur in templo: et magis honorásti fílios tuos quam me, ut comederétis primítias omnis sacrifícii Israël pópuli mei?")
               (:ref "1 Reg 2:30-33"
               :text "30 Proptérea ait Dóminus Deus Israël: Loquens locútus sum, ut domus tua, et domus patris tui, ministráret in conspéctu meo usque in sempitérnum. Nunc autem dicit Dóminus: Absit hoc a me: sed quicúmque glorificáverit me, glorificábo eum: qui autem contémnunt me, erunt ignóbiles.
31 Ecce dies véniunt, et præcídam brácchium tuum, et brácchium domus patris tui, ut non sit senex in domo tua.
32 Et vidébis ǽmulum tuum in templo, in univérsis prósperis Israël: et non erit senex in domo tua ómnibus diébus.
33 Verúmtamen non áuferam pénitus virum ex te ab altári meo: sed ut defíciant óculi tui, et tabéscat ánima tua: et pars magna domus tuæ moriétur cum ad virílem ætátem vénerit.")
               (:ref "1 Reg 2:34-36"
               :text "34 Hoc autem erit tibi signum, quod ventúrum est duóbus fíliis tuis, Ophni et Phínees: in die uno moriéntur ambo.
35 Et suscitábo mihi sacerdótem fidélem, qui juxta cor meum et ánimam meam fáciet: et ædificábo ei domum fidélem, et ambulábit coram christo meo cunctis diébus.
36 Futúrum est autem, ut quicúmque remánserit in domo tua, véniat ut orétur pro eo, et ófferat nummum argénteum, et tortam panis, dicátque: Dimítte me, óbsecro, ad unam partem sacerdotálem, ut cómedam buccéllam panis."))
              :responsories
              (nil
               nil
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil))))

    ;; Pent01-6: Sabbato infra Hebdomadam I post Octavam Pentecostes
    ((1 . 6) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 3:1-7"
               :text "1 Puer autem Sámuel ministrábat Dómino coram Heli, et sermo Dómini erat pretiósus in diébus illis: non erat vísio manifésta.
2 Factus est ergo in quadam, Heli jacébat in loco suo, et óculi ejus caligáverant, nec póterant vidére.
3 Lucérna Dei ántequam exstinguerétur, Sámuel dormiébat in templo Dómini, ubi erat arca Dei.
4 Et vocávit Dóminus Sámuel, qui respóndens ait: Ecce ego.
5 Et cucúrrit ad Heli et dixit: Non vocávi: revértere et dormi. Et ábiit et dormívit.
6 Et adjécit Dóminus rursum vocáre Samuélem. Consurgénsque Sámuel ábiit ad Heli, et dixit: Ecce ego, quia vocásti me. Qui respóndit: Non vocávi te, fili mi: revértere et dormi.
7 Porro Sámuel necdum sciébat Dóminum, neque revelátus fúerat ei sermo Dómini.")
               (:ref "1 Reg 3:8-12"
               :text "8 Et adjécit Dóminus, et vocávit adhuc Samuélem tértio. Qui consúrgens ábiit ad Heli,
9 et ait: Ecce ego, quia vocásti me. Intelléxit ergo Heli quia Dóminus vocáret púerum: et ait ad Samuélem: Vade, et dormi: et si deínceps vocáverit te, dices: Lóquere, Dómine, quia audit servus tuus. Abiit ergo Sámuel, et dormívit in loco suo.
10 Et venit Dóminus, et stetit: et vocávit, sicut vocáverat secúndo: Sámuel, Sámuel. Et ait Sámuel: Lóquere, Dómine, quia audit servus tuus.
11 Et dixit Dóminus ad Samuélem: Ecce ego fácio verbum in Israël, quod quicúmque audíerit, tínnient ambæ aures ejus.
12 In die illa suscitábo advérsum Heli ómnia quæ locútus sum super domum ejus: incípiam, et complébo.")
               (:ref "1 Reg 3:15-20"
               :text "15 Dormívit autem Sámuel usque mane, aperuítque óstia domus Dómini. Et Sámuel timébat indicáre visiónem Heli.
16 Vocávit ergo Heli Samuélem, et dixit: Sámuel fili mi? Qui respóndens ait: Præsto sum.
17 Et interrogávit eum: Quis est sermo, quem locútus est Dóminus ad te? oro te ne celáveris me: hæc fáciat tibi Deus, et hæc addat, si abscónderis a me sermónem ex ómnibus verbis quæ dicta sunt tibi.
18 Indicávit ítaque ei Sámuel univérsos sermónes, et non abscóndit ab eo. Et ille respóndit: Dóminus est: quod bonum est in óculis suis fáciat.
19 Crevit autem Sámuel, et Dóminus erat cum eo, et non cécidit ex ómnibus verbis ejus in terram.
20 Et cognóvit univérsus Israël, a Dan usque Bersabée, quod fidélis Sámuel prophéta esset Dómini."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent02-1: Feria II infra Hebdomadam II post Octavam Pentecostes
    ((2 . 1) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 5:1-5"
               :text "1 Philísthiim autem tulérunt arcam Dei et asportavérunt eam a Lápide adjutórii in Azótum.
2 Tulerúntque Philísthiim arcam Dei et intulérunt eam in templum Dagon et statuérunt eam juxta Dagon.
3 Cumque surrexíssent dilúculo Azótii áltera die, ecce Dagon jacébat pronus in terra ante arcam Dómini; et tulérunt Dagon et restituérunt eum in locum suum.
4 Rursúmque mane die áltera consurgéntes invenérunt Dagon jacéntem super fáciem suam in terra coram arca Dómini; caput autem Dagon et duæ palmæ mánuum ejus abscíssæ erant super limen;
5 porro Dagon solus truncus remánserat in loco suo.")
               (:ref "1 Reg 5:6-8"
               :text "6 Aggraváta est autem manus Dómini super Azótios, et demolítus est eos. Et ebulliérunt villæ et agri in médio regiónis illíus, et nati sunt mures, et facta est confúsio mortis magnæ in civitáte.
7 Vidéntes autem viri Azótii hujuscémodi plagam dixérunt: Non máneat arca Dei Israël apud nos, quóniam dura est manus ejus super nos et super Dagon deum nostrum.
8 Et mitténtes congregavérunt omnes sátrapas Philisthinórum ad se et dixérunt: Quid faciémus de arca Dei Israël? Responderúntque Gethǽi: Circumducátur arca Dei Israël.")
               (:ref "1 Reg 5:8-12"
               :text "8 Et circumduxérunt arcam Dei Israël.
9 Illis autem circumducéntibus eam, fiébat manus Dómini per síngulas civitátes interfectiónis magnæ nimis; et percutiébat viros uniuscujúsque urbis a parvo usque ad majórem.
10 Misérunt ergo arcam Dei in Accaron. Cumque venísset arca Dei in Accaron, exclamavérunt Accaronítæ dicéntes: Adduxérunt ad nos arcam Dei Israël, ut interfíciat nos et pópulum nostrum.
11 Misérunt ítaque et congregavérunt omnes sátrapas Philisthinórum, qui dixérunt: Dimíttite arcam Dei Israël, et revertátur in locum suum et non interfíciat nos cum pópulo nostro.
12 Fiébat enim pavor mortis in síngulis úrbibus et gravíssima valde manus Dei."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent02-2: Feria III infra Hebdomadam II post Octavam Pentecostes
    ((2 . 2) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 6:1-3"
               :text "1 Fuit ergo arca Dómini in regióne Philisthinórum septem ménsibus,
2 et vocavérunt Philísthiim sacerdótes et divínos, dicéntes: Quid faciémus de arca Dómini? Indicáte nobis quómodo remittámus eam in locum suum. Qui dixérunt:
3 Si remíttitis arcam Dei Israël, nolíte dimíttere eam vácuam, sed quod debétis réddite ei pro peccáto: et tunc curabímini et sciétis quare non recédat manus ejus a vobis.")
               (:ref "1 Reg 6:6-10"
               :text "6 Quare aggravátis corda vestra, sicut aggravávit Ægýptus et phárao cor suum? Nonne, postquam percússus est, tunc dimísit eos, et abiérunt?
7 Nunc ergo arrípite et fácite plaustrum novum unum, et duas vaccas fœtas, quibus non est impósitum jugum, júngite in plaustro et reclúdite vítulos eárum domi.
8 Tolletísque arcam Dómini et ponétis in plaustro et vasa áurea, quæ exsolvétis ei pro delícto, ponétis in capséllam ad latus ejus, et dimíttite eam ut vadat.
9 Et aspiciétis, et, si quidem per viam fínium suórum ascénderit contra Béthsames ipse fecit nobis hoc malum grande; sin autem mínime, sciémus quia nequáquam manus ejus tétigit nos, sed casu áccidit.
10 Fecérunt ergo illi hoc modo.")
               (:ref "1 Reg 6:12-15"
               :text "12 Ibant autem in diréctum vaccæ per viam, quæ ducit Béthsames, et itínere uno gradiebántur pergéntes et mugiéntes et non declinábant neque ad déxteram neque ad sinístram; sed et sátrapæ Philísthiim sequebántur usque ad términos Béthsames.
13 Porro Bethsamítæ metébant tríticum in valle, et elevántes óculos suos vidérunt arcam et gavísi sunt cum vidíssent.
14 Et plaustrum venit in agrum Jósue Bethsamítæ et stetit ibi. Erat autem ibi lapis magnus, et concidérunt ligna plaustri, vaccásque imposuérunt super ea holocáustum Dómino.
15 Levítæ autem deposuérunt arcam Dei."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent02-3: Feria IV infra Hebdomadam II post Octavam Pentecostes
    ((2 . 3) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 6:19-21; 7:1"
               :text "19 Percússit autem de viris Bethsamítibus, eo quod vidíssent arcam Dómini; et percússit de pópulo septuagínta viros et quinquagínta míllia plebis. Luxítque pópulus, eo quod Dóminus percussísset plebem plaga magna.
20 Et dixérunt viri Bethsamítæ: Quis póterit stare in conspéctu Dómini Dei sancti hujus? et ad quem ascéndet a nobis?
21 Miserúntque núntios ad habitatóres Cariathíarim, dicéntes: Reduxérunt Philísthiim arcam Dómini: descéndite, et redúcite eam ad vos.
1 Venérunt ergo viri Cariathíarim, et reduxérunt arcam Dómini, et intulérunt eam in domum Abínadab in Gábaa: Eleázarum autem fílium ejus sanctificavérunt, ut custodíret arcam Dómini.")
               (:ref "1 Reg 7:2-4"
               :text "2 Et factum est, ex qua die mansit arca Dómini in Cariathíarim, multiplicáti sunt dies (erat quippe jam annus vigésimus), et requiévit omnis domus Israël post Dóminum.
3 Ait autem Sámuel ad univérsam domum Israël dicens: Si in toto corde vestro revertímini ad Dóminum, auférte deos aliénos de médio vestri Báalim et Astaroth et præparáte corda vestra Dómino et servíte ei soli, et éruet vos de manu Philísthiim.
4 Abstulérunt ergo fílii Israël Báalim et Astaroth, et serviérunt Dómino soli.")
               (:ref "1 Reg 7:5-8"
               :text "5 Dixit autem Sámuel: Congregáte univérsum Israël in Masphath, ut orem pro vobis Dóminum.
6 Et convenérunt in Masphath hauserúntque aquam et effudérunt in conspéctu Dómini et jejunavérunt in die illa atque dixérunt ibi: Peccávimus Dómino. Judicavítque Sámuel fílios Israël in Masphath.
7 Et audiérunt Philísthiim quod congregáti essent fílii Israël in Masphath, et ascendérunt sátrapæ Philisthinórum ad Israël. Quod cum audíssent fílii Israël, timuérunt a fácie Philisthinórum.
8 Dixerúntque ad Samuélem: Ne cesses pro nobis clamáre ad Dóminum Deum nostrum, ut salvet nos de manu Philisthinórum."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent02-4: Feria V infra Hebdomadam II post Octavam Pentecostes
    ((2 . 4) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 8:4-6"
               :text "4 Congregáti ergo univérsi majóres natu Israël, venérunt ad Samuélem in Rámatha,
5 dixerúntque ei: Ecce tu senuísti, et fílii tui non ámbulant in viis tuis: constítue nobis regem, ut júdicet nos, sicut et univérsæ habent natiónes.
6 Displícuit sermo in óculis Samuélis, eo quod dixíssent: Da nobis regem, ut júdicet nos. Et orávit Sámuel ad Dóminum.")
               (:ref "1 Reg 8:7-9"
               :text "7 Dixit autem Dóminus ad Samuélem: Audi vocem pópuli in ómnibus quæ loquúntur tibi: non enim te abjecérunt sed me, ne regnem super eos.
8 Juxta ómnia ópera sua, quæ fecérunt a die qua edúxi eos de Ægýpto usque ad diem hanc, sicut dereliquérunt me et serviérunt diis aliénis, sic fáciunt étiam tibi.
9 Nunc ergo vocem eórum audi; verúmtamen contestáre eos et prædic eis jus regis, qui regnatúrus est super eos.")
               (:ref "1 Reg 8:10-14"
               :text "10 Dixit ítaque Sámuel ómnia verba Dómini ad pópulum, qui petíerat a se regem,
11 et ait: Hoc erit jus regis, qui imperatúrus est vobis. Fílios vestros tollet et ponet in cúrribus suis, faciétque sibi équites et præcursóres quadrigárum suárum;
12 et constítuet sibi tribúnos et centuriónes et aratóres agrórum suórum et messóres ségetum et fabros armórum et cúrruum suórum;
13 fílias quoque vestras fáciet sibi unguentárias, et focárias, et paníficas:
14 agros quoque vestros, et víneas, et olivéta, óptima tollet, et dabit servis suis."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent02-5: Sacratissimi Cordis Domini Nostri Jesu Christi
    ((2 . 5) . (:lessons
              ((:source "De Jeremía Prophéta"
               :ref "Jer 24:5-7"
               :text "5 Hæc dicit Dóminus, Deus Israël: Cognóscam transmigratiónem Juda, quam emísi de loco isto in terram Chaldæórum, in bonum.
6 Et ponam óculos meos super eos ad placándum, et redúcam eos in terram hanc; et ædificábo eos, et non déstruam; et plantábo eos et non evéllam.
7 Et dabo eis cor ut sciant me, quia ego sum Dóminus; et erunt mihi in pópulum, et ego ero eis in Deum, quia reverténtur ad me in toto corde suo.")
               (:ref "Jer 30:18-19; 30:21-24"
               :text "18 Hæc dicit Dóminus: Ecce ego convértam conversiónem tabernaculórum Jacob, et tectis ejus miserébor, et ædificábitur cívitas in excélso suo, et templum juxta órdinem suum fundábitur,
19 et egrediétur de eis laus, voxque ludéntium.
21 Et erit dux ejus ex eo, et princeps de médio ejus producétur; et, applicábo eum et accédet ad me. Quis enim iste est qui ápplicet cor suum ut appropínquet mihi? ait Dóminus.
22 Et éritis mihi in pópulum, et ego ero vobis in Deum.
23 Ecce turbo Dómini, furor egrédiens, procélla ruens; in cápite impiórum conquiéscet.
24 Non avértet iram indignatiónis Dóminus, donec fáciat et cómpleat cogitatiónem Cordis sui: in novíssimo diérum intellegétis ea.")
               (:ref "Jer 31:1-3; 31:31-33"
               :text "1 In témpore illo, dicit Dóminus, ero Deus univérsis cognatiónibus Israël, et ipsi erunt mihi in pópulum.
2 Hæc dicit Dóminus: Invénit grátiam in desérto pópulus qui remánserat a gládio; vadet ad réquiem suam Israël.
3 Longe Dóminus appáruit mihi. Et in caritáte perpétua diléxi te: ídeo attráxi te, míserans.
31 Ecce dies vénient, dicit Dóminus: et fériam dómui Israël et dómui Juda fœdus novum:
32 non secúndum pactum, quod pépigi cum pátribus eórum in die, qua apprehéndi manum eórum, ut edúcerem eos de Terra Ægýpti: pactum quod írritum fecérunt, et ego dominátus sum eórum, dicit Dóminus.
33 Sed hoc erit pactum, quod fériam cum domo Israël: post dies illos dicit Dóminus: Dabo legem meam in viscéribus eórum, et in corde eórum scribam eam: et ero eis in Deum, et ipsi erunt mihi in pópulum."))
              :responsories
              ((:respond "Fériam eis pactum sempitérnum et non désinam eis benefácere et timórem meum dabo in corde eórum"
                  :verse "Et lætábor super eis cum bene eis fécero in toto Corde meo."
                  :repeat "Ut non recédant a me."
                  :gloria nil)
               (:respond "Si inimícus meus maledixísset mihi, sustinuíssem útique"
                  :verse "Et si is qui me óderat super me magna locútus fuísset, abscondíssem me fórsitan ab eo."
                  :repeat "Tu vero homo unánimis qui simul mecum dulces capiébas cibos."
                  :gloria nil)
               (:respond "Cum essémus mórtui peccátis, convivificávit nos Deus in Christo"
                  :verse "Ut osténderet in sǽculis superveniéntibus abundántes divítias grátiæ suæ."
                  :repeat "Propter nímiam caritátem suam qua diléxit nos."
                  :gloria t))))

    ;; Pent02-6: Die II infra Octavam SSmi Cordis Jesu
    ((2 . 6) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 9:1-4"
               :text "1 Et erat vir de Bénjamin nómine Cis, fílius Abiel, fílii Seror, fílii Béchorath, fílii Aphia, fílii viri Jémini, fortis róbore.
2 Et erat ei fílius vocábulo Saul eléctus et bonus, et non erat vir de fíliis Israël mélior illo: ab húmero et sursum eminébat super omnem pópulum.
3 Períerant autem ásinæ Cis patris Saul, et dixit Cis ad Saul fílium suum: Tolle tecum unum de púeris et consúrgens vade et quære ásinas.  Qui, cum transíssent per montem Ephraim
4 et per terram Salísa et non inveníssent, transiérunt étiam per terram Salim, et non erant, sed et per terram Jémini, et mínime reperérunt.")
               (:ref "1 Reg 9:5-8"
               :text "5 Cum autem veníssent in terram Suph, dixit Saul ad púerum, qui erat cum eo: Veni et revertámur, ne forte dimíserit pater meus ásinas et sollícitus sit pro nobis.
6 Qui ait ei: Ecce vir Dei est in civitáte hac, vir nóbilis: omne quod lóquitur, sine ambiguitáte venit; nunc ergo eámus illuc, si forte índicet nobis de via nostra, propter quam vénimus.
7 Dixítque Saul ad púerum suum: Ecce íbimus: quid ferémus ad virum Dei? panis defécit in sitárciis nostris, et spórtulam non habémus, ut demus hómini Dei, nec quidquam áliud.
8 Rursum puer respóndit Sauli et ait: Ecce invénta est in manu mea quarta pars statéris argénti: demus hómini Dei, ut índicet nobis viam nostram.")
               (:ref "1 Reg 9:14-17"
               :text "14 Et ascendérunt in civitátem. Cumque illi ambulárent in médio urbis, appáruit Sámuel egrédiens óbviam eis, ut ascénderet in excélsum.
15 Dóminus autem reveláverat aurículam Samuélis, ante unam diem quam veníret Saul, dicens:
16 Hac ipsa hora, quæ nunc est, cras mittam virum ad te de terra Bénjamin, et unges eum ducem super pópulum meum Israël, et salvábit pópulum meum de manu Philisthinórum, quia respéxi pópulum meum; venit enim clamor eórum ad me.
17 Cumque aspexísset Sámuel Saulem Dóminus dixit ei: Ecce vir, quem díxeram tibi: iste dominábitur pópulo meo."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent03-1: Die IV infra Octavam SSmi Cordis Jesu
    ((3 . 1) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 10:17-19"
               :text "17 Et convocávit Sámuel pópulum ad Dóminum in Maspha:
18 et ait ad fílios Israël: Hæc dicit Dóminus Deus Israël: Ego edúxi Israël de Ægýpto, et érui vos de manu Ægyptiórum et de manu ómnium regum, qui affligébant vos.
19 Vos autem hódie projecístis Deum vestrum, qui solus salvávit vos de univérsis malis et tribulatiónibus vestris, et dixístis: Nequáquam, sed regem constítue super nos. Nunc ergo state coram Dómino per tribus vestras et per famílias.")
               (:ref "1 Reg 10:20-24"
               :text "20 Et applícuit Sámuel omnes tribus Israël, et cécidit sors tribus Bénjamin;
21 et applícuit tribum Bénjamin et cognatiónes ejus, et cécidit cognátio Metri, et pervénit usque ad Saul fílium Cis. Quæsiérunt ergo eum, et non est invéntus.
22 Et consuluérunt post hæc Dóminum utrúmnam ventúrus esset illuc. Respondítque Dóminus: Ecce abscónditus est domi.
23 Cucurrérunt ítaque et tulérunt eum inde; stetítque in médio pópuli, et áltior fuit univérso pópulo ab húmero et sursum.
24 Et ait Sámuel ad omnem pópulum: Certe vidétis quem elégit Dóminus, quóniam non sit símilis illi in omni pópulo. Et clamávit omnis pópulus et ait: Vivat rex.")
               (:ref "1 Reg 10:25-27"
               :text "25 Locútus est autem Sámuel ad pópulum legem regni, et scripsit in libro, et repósuit coram Dómino; et dimísit Sámuel omnem pópulum, síngulos in domum suam.
26 Sed et Saul ábiit in domum suam in Gábaa; et ábiit cum eo pars exércitus, quorum tetígerat Deus corda.
27 Fílii vero Bélial dixérunt: Num salváre nos póterit iste? Et despexérunt eum, et non attulérunt ei múnera; ille vero dissimulábat se audíre."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent03-2: Die V infra Octavam SSmi Cordis Jesu
    ((3 . 2) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 12:1-5"
               :text "1 Dixit autem Sámuel ad univérsum Israël: Ecce audívi vocem vestram juxta ómnia quæ locúti estis ad me, et constítui super vos regem.
2 Et nunc rex gráditur ante vos: ego autem sénui, et incánui: porro fílii mei vobíscum sunt: ítaque conversátus coram vobis ab adolescéntia mea usque ad hanc diem, ecce præsto sum.
3 Loquímini de me coram Dómino, et coram christo ejus, utrum bovem cujúsquam túlerim, aut ásinum: si quémpiam calumniátus sum, si oppréssi áliquem, si de manu cujúsquam munus accépi: et contémnam illud hódie, restituámque vobis.
4 Et dixérunt: Non es calumniátus nos, neque oppressísti, neque tulísti de manu alicújus quíppiam.
5 Dixítque ad eos: Testis est Dóminus advérsum vos, et testis Christus ejus in die hac, quia non invenéritis in manu mea quíppiam. Et dixérunt: Testis.")
               (:ref "1 Reg 12:6-9"
               :text "6 Et ait Sámuel ad pópulum: Dóminus, qui fecit Móysen et Aaron, et edúxit patres nostros de terra Ægýpti.
7 Nunc ergo state, ut judício conténdam advérsum vos coram Dómino de ómnibus misericórdiis Dómini quas fecit vobíscum et cum pátribus vestris:
8 quómodo Jacob ingréssus est in Ægýptum, et clamavérunt patres vestri ad Dóminum: et misit Dóminus Móysen et Aaron, et edúxit patres vestros de Ægýpto, et collocávit eos in loco hoc.
9 Qui oblíti sunt Dómini Dei sui, et trádidit eos in manu Sísaræ magístri milítiæ Hasor, et in manu Philisthinórum, et in manu regis Moab: et pugnavérunt advérsum eos.")
               (:ref "1 Reg 12:10-14"
               :text "10 Póstea autem clamavérunt ad Dóminum, et dixérunt: Peccávimus, quia derelíquimus Dóminum, et servívimus Báalim et Astaroth: nunc ergo érue nos de manu inimicórum nostrórum, et serviémus tibi.
11 Et misit Dóminus Jeróbaal, et Badan, et Jephte, et Sámuel, et éruit vos de manu inimicórum vestrórum per circúitum, et habitástis confidénter.
12 Vidéntes autem quod Naas rex filiórum Ammon venísset advérsum vos, dixístis mihi: Nequáquam, sed rex imperábit nobis: cum Dóminus Deus vester regnáret in vobis.
13 Nunc ergo præsto est rex vester, quem elegístis et petístis: ecce dedit vobis Dóminus regem.
14 Si timuéritis Dóminum, et serviéritis ei, et audiéritis vocem ejus, et non exasperavéritis os Dómini, éritis et vos, et rex qui ímperat vobis, sequéntes Dóminum Deum vestrum."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent03-3: Die VI infra Octavam SSmi Cordis Jesu
    ((3 . 3) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 13:1-4"
               :text "1 Fílius uníus anni erat Saul, cum regnáre cœpísset; duóbus autem annis regnávit super Israël.
2 Et elégit sibi Saul tria míllia de Israël. Et erant cum Saul duo míllia in Machmas et in monte Bethel, mille autem cum Jónatha in Gábaa Bénjamin. Porro céterum pópulum remísit unumquémque in tabernácula sua.
3 Et percússit Jónathas statiónem Philisthinórum, quæ erat in Gábaa. Quod cum audíssent Philísthiim Saul cécinit búccina in omni terra dicens: Audiant Hebrǽi.
4 Et univérsus Israël audívit hujuscémodi famam: Percússit Saul statiónem Philisthinórum, et eréxit se Israël advérsus Philísthiim; clamávit ergo pópulus post Saul in Gálgala.")
               (:ref "1 Reg 13:5-8"
               :text "5 Et Philísthiim congregáti sunt ad præliándum contra Israël, trigínta míllia cúrruum et sex míllia équitum et réliquum vulgus, sicut aréna, quæ est in líttore maris plúrima. Et ascendéntes castrametáti sunt in Machmas ad oriéntem Betháven.
6 Quod cum vidíssent viri Israël se in arcto pósitos, (afflíctus enim erat pópulus) abscondérunt se in spelúncis et in ábditis, in petris quoque et in antris et in cistérnis.
7 Hebrǽi autem transiérunt Jordánem in terram Gad et Gálaad. Cumque adhuc esset Saul in Gálgala, univérsus pópulus pertérritus est, qui sequebátur eum.
8 Et exspectávit septem diébus juxta plácitum Samuélis; et non venit Sámuel in Gálgala, dilapsúsque est pópulus ab eo.")
               (:ref "1 Reg 13:9-14"
               :text "9 Ait ergo Saul: Afférte mihi holocáustum et pacífica. Et óbtulit holocáustum.
10 Cumque complésset ófferens holocáustum, ecce Samuel veniébat; et egréssus est Saul óbviam ei ut salutáret eum.
11 Locutúsque est ad eum Samuel: Quid fecísti? Respóndit Saul: Quia vidi quod pópulus dilaberétur a me, et tu non véneras juxta plácitos dies, porro Philísthiim congregáti fúerant in Machmas,
12 dixi: Nunc descéndent Philísthiim ad me in Gálgala, et fáciem Dómini non placávi. Necessitáte compúlsus, óbtuli holocáustum.
13 Dixítque Sámuel ad Saul: Stulte egísti, nec custodísti mandáta Dómini Dei tui, quæ præcépit tibi. Quod si non fecísses, jam nunc præparásset Dóminus regnum tuum super Israël in sempitérnum;
14 sed nequáquam regnum tuum ultra consúrget. Quæsívit Dóminus sibi virum juxta cor suum et præcépit ei Dóminus ut esset dux super pópulum suum, eo quod non serváveris quæ præcépit Dóminus."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent03-4: Die VII infra Octavam SSmi Cordis Jesu
    ((3 . 4) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 14:6-11"
               :text "6 Dixit autem Jónathas ad adolescéntem armígerum suum: Veni, transeámus ad statiónem incircumcisórum horum, si forte fáciat Dóminus pro nobis, quia non est Dómino diffícile salváre vel in multis vel in paucis.
7 Dixítque ei ármiger suus: Fac ómnia, quæ placent ánimo tuo, perge quo cupis, et ero tecum ubicúmque volúeris.
8 Et ait Jónathas: Ecce nos transímus ad viros istos. Cumque apparuérimus eis,
9 si táliter locúti fúerint ad nos: Manéte donec veniámus ad vos; stemus in loco nostro nec ascendámus ad eos.
10 Si autem díxerint: Ascéndite ad nos; ascendámus, quia trádidit eos Dóminus in mánibus nostris: hoc erit nobis signum.
11 Appáruit ígitur utérque statióni Philísthiim. Dixerúntque Philísthiim: En Hebrǽi egrediúntur de cavérnis, in quibus abscónditi fúerant.")
               (:ref "1 Reg 14:12-15"
               :text "12 Et locúti sunt viri de statióne ad Jónatham et ad armígerum ejus, dixerúntque: Ascéndite ad nos, et ostendámus vobis rem. Et ait Jónathas ad armígerum suum: Ascendámus, séquere me; trádidit enim Dóminus eos in manus Israël.
13 Ascéndit autem Jónathas mánibus et pédibus reptans et ármiger ejus post eum. Itaque álii cadébant ante Jónatham, álios ármiger ejus interficiébat sequens eum.
14 Et facta est plaga prima, qua percússit Jónathas et ármiger ejus, quasi vigínti virórum, in média parte júgeri, quam par boum in die aráre consuévit.
15 Et factum est miráculum in castris per agros; sed et omnis pópulus statiónis eórum, qui íerant ad prædándum, obstúpuit, et conturbáta est terra, et áccidit quasi miráculum a Deo.")
               (:ref "1 Reg 14:16-20"
               :text "16 Et respexérunt speculatóres Saul, qui erant in Gábaa Bénjamin, et ecce multitúdo prostráta et huc illúcque diffúgiens.
17 Et ait Saul pópulo, qui erat cum eo: Requírite et vidéte quis abíerit ex nobis. Cumque requisíssent, repértum est non adésse Jónatham et armígerum ejus.
18 Et ait Saul ad Achíam: Applica arcam Dei (erat enim ibi arca Dei in die illa cum fíliis Israël).
19 Cumque loquerétur Saul ad sacerdótem, tumúltus magnus exórtus est in castris Philisthinórum, crescebátque paulátim et clárius resonábat. Et ait Saul ad sacerdótem: Cóntrahe manum tuam.
20 Conclamávit ergo Saul, et omnis pópulus, qui erat cum eo, et venérunt usque ad locum certáminis; et ecce versus fúerat gládius uniuscujúsque ad próximum suum, et cædes magna nimis."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent03-5: In Octava SSmi Cordis Jesu
    ((3 . 5) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 15:1-3"
               :text "1 Et dixit Samuel ad Saul: Me misit Dóminus, ut úngerem te in regem super pópulum ejus Israël; nunc ergo audi vocem Dómini.
2 Hæc dicit Dóminus exercítuum: Recénsui quæcúmque fecit Amalec Israéli, quómodo réstitit ei in via, cum ascénderet de Ægýpto.
3 Nunc ergo vade et pércute Amalec et demolíre univérsa ejus: non parcas ei et non concupíscas ex rebus ipsíus áliquid; sed intérfice a viro usque ad mulíerem et párvulum atque lacténtem, bovem et ovem, camélum et ásinum.")
               (:ref "1 Reg 15:4-8"
               :text "4 Præcépit ítaque Saul pópulo, et recénsuit eos quasi agnos: ducénta míllia péditum et decem míllia virórum Juda.
5 Cumque venísset Saul usque ad civitátem Amalec, teténdit insídias in torrénte.
6 Dixítque Saul Cinǽo: Abíte, recédite atque descéndite ab Amalec, ne forte invólvam te cum eo; tu enim fecísti misericórdiam cum ómnibus fíliis Israël cum ascénderent de Ægýpto. Et recéssit Cinǽus de médio Amalec.
7 Percussítque Saul Amalec ab Hévila donec vénias ad Sur, quæ est e regióne Ægýpti.
8 Et apprehéndit Agag regem Amalec vivum; omne autem vulgus interfécit in ore gládii.")
               (:ref "1 Reg 15:9-11"
               :text "9 Et pepércit Saul et pópulus Agag et óptimis grégibus óvium et armentórum et véstibus et ariétibus et univérsis, quæ pulchra erant, nec voluérunt dispérdere ea; quidquid vero vile fuit et réprobum, hoc demolíti sunt.
10 Factum est autem verbum Dómini ad Sámuel, dicens:
11 Pœ́nitet me quod constitúerim Saul regem, quia derelíquit me et verba mea ópere non implévit. Contristatúsque est Sámuel et clamávit ad Dóminum tota nocte."))
              :responsories
              (nil
               nil
               nil)))

    ;; Pent03-6: Sabbato infra Hebdomadam III post Octavam Pentecostes
    ((3 . 6) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 16:1-3"
               :text "1 Dixítque Dóminus ad Samuélem: Usquequo tu luges Saul, cum ego projécerim eum ne regnet super Israël? Imple cornu tuum óleo et veni, ut mittam te ad Isai Bethlehemítem; provídi enim in fíliis ejus mihi regem.
2 Et ait Samuel: Quómodo vadam? áudiet enim Saul et interfíciet me. Et ait Dóminus: Vítulum de arménto tolles in manu tua et dices: Ad immolándum Dómino veni.
3 Et vocábis Isai ad víctimam, et ego osténdam tibi quid fácias, et unges quemcúmque monstrávero tibi.")
               (:ref "1 Reg 16:4-7"
               :text "4 Fecit ergo Samuel sicut locútus est ei Dóminus, venítque in Béthlehem, et admiráti sunt senióres civitátis occurréntes ei dixerúntque: Pacificúsne est ingréssus tuus?
5 Et ait: Pacíficus: ad immolándum Dómino veni: sanctificámini, et veníte mecum ut ímmolem. Sanctificávit ergo Isai et fílios ejus et vocávit eos ad sacrifícium.
6 Cumque ingréssi essent, vidit Eliab et ait: Num coram Dómino est Christus ejus?
7 Et dixit Dóminus ad Samuélem: Ne respícias vultum ejus neque altitúdinem statúræ ejus, quóniam abjéci eum, nec juxta intúitum hóminis ego júdico; homo enim videt ea quæ parent, Dóminus autem intuétur cor.")
               (:ref "1 Reg 16:8-11"
               :text "8 Et vocávit Isai Abínadab et addúxit eum coram Samuéle. Qui dixit: Nec hunc elégit Dóminus.
9 Addúxit autem Isai Samma, de quo ait: Etiam hunc non elégit Dóminus.
10 Addúxit ítaque Isai septem fílios suos coram Samuéle, et ait Sámuel ad Isai: Non elégit Dóminus ex istis.
11 Dixítque Samuel ad Isai: Numquid jam compléti sunt fílii? Qui respóndit: Adhuc réliquus est párvulus et pascit oves. Et ait Sámuel ad Isai: Mitte et adduc eum."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent04-1: Feria secunda infra Hebdomadam IV post Octavam Pentecostes
    ((4 . 1) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 17:25-26"
               :text "25 Et dixit unus quíspiam de Israël: Num vidístis virum hunc qui ascéndit? Ad exprobrándum enim Israéli ascéndit. Virum ergo, qui percússerit eum, ditábit rex divítiis magnis et fíliam suam dabit ei et domum patris ejus fáciet absque tribúto in Israël.
26 Et ait David ad viros, qui stabant secum, dicens: Quid dábitur viro, qui percússerit Philisthǽum hunc et túlerit oppróbrium de Israël? Quis enim est hic Philisthǽus incircumcísus, qui exprobrávit ácies Dei vivéntis?")
               (:ref "1 Reg 17:31-33"
               :text "31 Audíta sunt autem verba, quæ locútus est David, et annuntiáta in conspéctu Saul.
32 Ad quem cum fuísset addúctus, locútus est ei: Non cóncidat cor cujúsquam in eo: ego servus tuus vadam et pugnábo advérsus Philisthǽum.
33 Et ait Saul ad David: Non vales resistere Philisthǽo isti nec pugnáre advérsus eum, quia puer es, hic autem vir bellátor est ab adulescéntia sua.")
               (:ref "1 Reg 17:34-36"
               :text "34 Dixítque David ad Saul: Pascébat servus tuus patris sui gregem, et veniébat leo vel ursus et tollébat aríetem de médio gregis,
35 et persequébar eos et percutiébam eruebámque de ore eórum; et illi consurgébant advérsum me, et apprehendébam mentum eórum et suffocábam interficiebámque eos;
36 nam et leónem et ursum interféci ego servus tuus. Erit ígitur et Philisthǽus hic incircumcísus quasi unus ex eis."))
              :responsories
              ((:respond "Recordáre, Dómine, testaménti tui, et dic Angelo percutiénti: Cesset jam manus tua,"
                  :verse "Quiéscat, Dómine, ira tua a pópulo tuo, et a civitáte sancta tua:"
                  :repeat "Ut non desolétur terra, et ne perdas omnem ánimam vivam."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent04-2: Feria tertia infra Hebdomadam IV post Octavam Pentecostes
    ((4 . 2) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 17:38-40"
               :text "38 Et índuit Saul David vestiméntis suis et impósuit gáleam ǽream super caput ejus et vestívit eum loríca.
39 Accínctus ergo David gládio ejus super vestem suam cœpit tentáre si armátus posset incédere, non enim habébat consuetúdinem. Dixítque David ad Saul: Non possum sic incédere, quia non usum hábeo. Et depósuit ea,
40 et tulit báculum suum, quem semper habébat in mánibus, et elégit sibi quinque limpidíssimos lápides de torrénte et misit eos in peram pastorálem, quam habébat secum, et fundam manu tulit et procéssit advérsum Philisthǽum.")
               (:ref "1 Reg 17:41-46"
               :text "41 Ibat autem Philisthǽus incédens et appropínquans advérsum David, et ármiger ejus ante eum.
42 Cumque inspexísset Philisthǽus et vidísset David, despéxit eum; erat enim adoléscens rufus et pulcher aspéctu.
43 Et dixit Philisthǽus ad David: Numquid ego canis sum, quod tu venis ad me cum báculo? Et maledíxit Philisthǽus David in diis suis,
44 dixítque ad David: Veni ad me et dabo carnes tuas volatílibus cæli et béstiis terræ.
45 Dixit autem David ad Philisthǽum: Tu venis ad me cum gládio et hasta et clípeo, ego autem vénio ad te in nómine Dómini exercítuum, Dei ágminum Israël, quibus exprobrásti
46 hódie; et dabit te Dóminus in manu mea, et percútiam te et áuferam caput tuum a te et dabo cadávera castrórum Philísthiim hódie volatílibus cæli et béstiis terræ, ut sciat omnis terra quia est Deus in Israël.")
               (:ref "1 Reg 17:48-51"
               :text "48 Cum ergo surrexísset Philisthǽus et veníret et appropinquáret contra David, festinávit David et cucúrrit ad pugnam ex advérso Philisthǽi.
49 Et misit manum suam in peram tulítque unum lápidem et funda jecit et circumdúcens percússit Philisthǽum in fronte; et infíxus est lapis in fronte ejus, et cécidit in fáciem suam super terram.
50 Prævaluítque David advérsum Philisthǽum in funda et lápide percussúmque Philisthǽum interfécit. Cumque gládium non habéret in manu, David
51 cucúrrit et stetit super Philisthǽum et tulit gládium ejus et edúxit eum de vagína sua et interfécit eum, præcidítque caput ejus."))
              :responsories
              ((:respond "Dómine, si convérsus fúerit pópulus tuus, et oráverit ad sanctuárium tuum:"
                  :verse "Si peccáverit in te pópulus tuus, et convérsus égerit pœniténtiam, veniénsque oráverit in isto loco."
                  :repeat "Tu exáudies de cælo, Dómine, et líbera eos de mánibus inimicórum suórum."
                  :gloria nil)
               (:respond "Factum est, dum tólleret Dóminus Elíam per túrbinem in cælum, Eliséus clamábat, dicens:"
                  :verse "Cumque simul pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque, et clamábat Eliséus:"
                  :repeat "Pater mi, pater mi, currus Israël, et auríga ejus."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent04-3: Feria quarta infra Hebdomadam IV post Octavam Pentecostes
    ((4 . 3) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 18:6-8"
               :text "6 Porro, cum reverterétur, percússo Philisthǽo, David, egréssæ sunt mulíeres de univérsis úrbibus Israël cantántes chorósque ducéntes in occúrsum Saul regis in týmpanis lætítiæ et in sistris.
7 Et præcinébant mulíeres ludéntes atque dicéntes: Percússit Saul mille, et David decem míllia.
8 Irátus est autem Saul nimis, et displícuit in óculis ejus sermo iste, dixítque: Dedérunt David decem míllia et mihi mille dedérunt; quid ei súperest, nisi solum regnum?")
               (:ref "1 Reg 18:9-13"
               :text "9 Non rectis ergo óculis Saul aspiciébat David a die illa et deínceps.
10 Post diem autem álteram invásit spíritus Dei malus Saul, et prophetábat in médio domus suæ; David autem psallébat manu sua sicut per síngulos dies. Tenebátque Saul lánceam
11 et misit eam putans quod confígere posset David cum paríete; et declinávit David a fácie ejus secúndo.
12 Et tímuit Saul David eo quod Dóminus esset cum eo, et a se recessísset.
13 Amóvit ergo eum Saul a se et fecit eum tribúnum super mille viros; et egrediebátur et intrábat in conspéctu pópuli.")
               (:ref "1 Reg 18:14-17"
               :text "14 In ómnibus quoque viis suis David prudénter agébat, et Dóminus erat cum eo.
15 Vidit ítaque Saul quod prudens esset nimis et cœpit cavére eum.
16 Omnis autem Israël et Juda diligébat David; ipse enim ingrediebátur et egrediebátur ante eos.
17 Dixítque Saul ad David: Ecce fília mea major Merob, ipsam dabo tibi uxórem; tantúmmodo esto vir fortis et præliáre bella Dómini. Saul autem reputábat dicens: Non sit manus mea in eum, sed sit super eum manus Philisthinórum."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent04-4: Feria quinta infra Hebdomadam IV post Octavam Pentecostes
    ((4 . 4) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 19:1-3"
               :text "1 Locútus est autem Saul ad Jónatham fílium suum et ad omnes servos suos ut occíderent David. Porro Jónathas fílius Saul diligébat David valde.
2 Et indicávit Jónathas David dicens: Quærit Saul pater meus occídere te; quaprópter obsérva te, quæso, mane, et manébis clam, et abscondéris.
3 Ego autem egrédiens stabo juxta patrem meum in agro ubicúmque fúeris; et ego loquar de te ad patrem meum, et quodcúmque vídero, nuntiábo tibi.")
               (:ref "1 Reg 19:4-6"
               :text "4 Locútus est ergo Jónathas de David bona ad Saul patrem suum dixítque ad eum: Ne pecces, rex, in servum tuum David, quia non peccávit tibi, et ópera ejus bona sunt tibi valde.
5 Et pósuit ánimam suam in manu sua et percússit Philisthǽum, et fecit Dóminus salútem magnam univérso Israéli. Vidísti et lætátus es; quare ergo peccas in sánguine innóxio interfíciens David, qui est absque culpa?
6 Quod cum audísset Saul, placátus voce Jónathæ jurávit: Vivit Dóminus, quia non occidétur.")
               (:ref "1 Reg 19:8-10"
               :text "8 Motum est autem rursum bellum, et egréssus David pugnávit advérsum Philísthiim percussítque eos plaga magna, et fugérunt a fácie ejus.
9 Et factus est spíritus Dómini malus in Saul. Sedébat autem in domo sua et tenébat lánceam; porro David psallébat manu sua.
10 Nisúsque est Saul confígere David láncea in paríete, et declinávit David a fácie Saul; láncea autem, casso vúlnere, perláta est in paríetem. Et David fugit et salvátus est nocte illa."))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent04-5: Feria sexta infra Hebdomadam IV post Octavam Pentecostes
    ((4 . 5) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 20:1-2"
               :text "1 Fugit autem David de Najoth, quæ est in Rámatha, veniénsque locútus est coram Jónatha: Quid feci? quæ est iníquitas mea, et quod peccátum meum in patrem tuum, quia quærit ánimam meam?
2 Qui dixit ei: Absit, non moriéris; neque enim fáciet pater meus quidquam grande vel parvum nisi prius indicáverit mihi; hunc ergo celávit me pater meus sermónem tantúmmodo? Nequáquam erit istud.")
               (:ref "1 Reg 20:3-4"
               :text "3 Et jurávit rursum Davídi. Et ille ait: Scit profécto pater tuus quia invéni grátiam in óculis tuis et dicet: Nésciat hoc Jónathas, ne forte tristétur. Quinímmo vivit Dóminus, et vivit ánima tua, quia uno tantum (ut ita dicam) gradu ego morsque divídimur.
4 Et ait Jónathas ad David: Quodcúmque díxerit mihi ánima tua, fáciam tibi.")
               (:ref "1 Reg 20:5-7"
               :text "5 Dixit autem David ad Jónathan: Ecce caléndæ sunt crástino, et ego ex more sedére sóleo juxta regem ad vescéndum; dimítte ergo me, ut abscóndar in agro usque ad vésperam diéi tértiæ.
6 Si respíciens requisíerit me pater tuus, respondébis ei: Rogávit me David ut iret celériter in Béthlehem civitátem suam, quia víctimæ solémnes ibi sunt univérsis contribúlibus suis.
7 Si díxerit: Bene, pax erit servo tuo; si autem fúerit irátus, scito quia compléta est malítia ejus."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent04-6: Sabbato infra Hebdomadam IV post Octavam Pentecostes
    ((4 . 6) . (:lessons
              ((:source "De libro primo Regum"
               :ref "1 Reg 21:1-3"
               :text "1 Venit autem David in Nobe ad Achímelech sacerdótem. Et obstúpuit Achímelech, eo quod venísset David, et dixit ei: Quare tu solus, et nullus est tecum?
2 Et ait David ad Achímelech sacerdótem: Rex præcépit mihi sermónem et dixit: Nemo sciat rem propter quam missus es a me, et cujúsmodi præcépta tibi déderim; nam et púeris condíxi in illum et illum locum.
3 Nunc ergo, si quid habes ad manum, vel quinque panes, da mihi, aut quidquid invéneris.")
               (:ref "1 Reg 21:4-6"
               :text "4 Et respóndens sacérdos ad David ait illi: Non hábeo láicos panes ad manum, sed tantum panem sanctum; si mundi sunt púeri, máxime a muliéribus?
5 Et respóndit David sacerdóti et dixit ei: Equidem, si de muliéribus ágitur, continúimus nos ab heri et nudiustértius, quando egrediebámur, et fuérunt vasa puerórum sancta. Porro via hæc pollúta est, sed et ipsa hódie sanctificábitur in vasis.
6 Dedit ergo ei sacérdos sanctificátum panem; neque enim erat ibi panis, nisi tantum panes propositiónis, qui subláti fúerant a fácie Dómini, ut poneréntur panes cálidi.")
               (:ref "1 Reg 21:7-9"
               :text "7 Erat autem ibi vir quidam de servis Saul in die illa intus in tabernáculo Dómini, et nomen ejus Doëg Idumǽus potentíssimus pastórum Saul.
8 Dixit autem David ad Achímelech: Si habes hic ad manum hastam aut gládium? quia gládium meum et arma mea non tuli mecum; sermo enim regis urgébat.
9 Et dixit sacérdos: Ecce hic gládius Góliath Philisthǽi, quem percussísti in Valle terebínthi: est involútus pállio post ephod. Si istum vis tóllere, tolle, neque enim hic est álius absque eo. Et ait David: Non est huic alter símilis: da mihi eum."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent05-1: Feria secunda infra Hebdomadam V post Octavam Pentecostes
    ((5 . 1) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 2:1-4"
               :text "1 Igitur post hæc consúluit David Dóminum dicens: Num ascéndam in unam de civitátibus Juda? Et ait Dóminus ad eum: Ascénde. Dixítque David: Quo ascéndam? Et respóndit ei: In Hebron.
2 Ascéndit ergo David et duæ uxóres ejus Achínoam Jezrahelítes et Abígail uxor Nabal Carméli;
3 sed et viros, qui erant cum eo, duxit David síngulos cum domo sua; et mansérunt in óppidis Hebron.
4 Venerúntque viri Juda, et unxérunt ibi David, ut regnáret super domum Juda.")
               (:ref "2 Reg 2:4-7"
               :text "4 Et nuntiátum est David, quod viri Jabes Gálaad sepelíssent Saul.
5 Misit ergo David núntios ad viros Jabes Gálaad dixítque ad eos: Benedícti vos a Dómino, qui fecístis misericórdiam hanc cum dómino vestro Saul, et sepelístis eum.
6 Et nunc retríbuet vobis quidem Dóminus misericórdiam et veritátem, sed et ego reddam grátiam, eo quod fecístis verbum istud.
7 Conforténtur manus vestræ et estóte fílii fortitúdinis; licet enim mórtuus sit dóminus vester Saul, tamen me unxit domus Juda in regem sibi.")
               (:ref "2 Reg 2:8-11"
               :text "8 Abner autem fílius Ner, princeps exércitus Saul, tulit Isboseth fílium Saul, et circumdúxit eum per castra,
9 regémque constítuit super Gálaad, et super Géssuri, et super Jézrahel, et super Ephraim, et super Bénjamin, et super Israël univérsum.
10 Quadragínta annórum erat Isboseth fílius Saul cum regnáre cœpísset super Israël, et duóbus annis regnávit. Sola autem domus Juda sequebátur David.
11 Et fuit númerus diérum, quos commorátus est David ímperans in Hebron super domum Juda, septem annórum et sex ménsium."))
              :responsories
              ((:respond "Recordáre, Dómine, testaménti tui, et dic Angelo percutiénti: Cesset jam manus tua,"
                  :verse "Quiéscat, Dómine, ira tua a pópulo tuo, et a civitáte sancta tua:"
                  :repeat "Ut non desolétur terra, et ne perdas omnem ánimam vivam."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent05-2: Feria tertia infra Hebdomadam V post Octavam Pentecostes
    ((5 . 2) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 3:6-10"
               :text "6 Cum ergo esset prǽlium inter domum Saul et domum David, Abner fílius Ner regébat domum Saul.
7 Fúerat autem Sauli concubína nómine Respha, fília Aja. Dixítque Isboseth ad Abner:
8 Quare ingréssus es ad concubínam patris mei? Qui irátus nimis propter verba Isboseth ait: Numquid caput canis ego sum advérsum Judam hódie, qui fécerim misericórdiam super domum Saul patris tui, et super fratres et próximos ejus, et non trádidi te in manus David? Et tu requisísti in me quod argúeres pro mulíere hódie?
9 Hæc fáciat Deus Abner, et hæc addat ei, nisi, quómodo jurávit Dóminus David, sic fáciam cum eo,
10 ut transferátur regnum de domo Saul, et elevétur thronus David super Israël et super Judam a Dan usque Bersabée.")
               (:ref "2 Reg 3:12-16"
               :text "12 Misit ergo Abner núntios ad David pro se dicéntes: Cujus est terra? et ut loqueréntur: Fac mecum amicítias, et erit manus mea tecum et redúcam ad te univérsum Israël.
13 Qui ait: Optime: ego fáciam tecum amicítias, sed unam rem peto a te, dicens: Non vidébis fáciem meam, ántequam addúxeris Michol fíliam Saul; et sic vénies, et vidébis me.
14 Misit autem David núntios ad Isboseth fílium Saul dicens: Redde uxórem meam Michol, quam despóndi mihi centum præpútiis Philísthiim.
15 Misit ergo Isboseth et tulit eam a viro suo Pháltiel, fílio Lais.
16 Sequebatúrque eam vir suus, plorans usque Bahúrim. Et dixit ad eum Abner: Vade et revértere. Qui revérsus est.")
               (:ref "2 Reg 3:17-21"
               :text "17 Sermónem quoque íntulit Abner ad senióres Israël, dicens: Tam heri quam nudiustértius quærebátis David, ut regnáret super vos.
18 Nunc ergo fácite, quóniam Dóminus locútus est ad David, dicens: In manu servi mei David salvábo pópulum meum Israël de manu Philísthiim, et ómnium inimicórum ejus.
19 Locútus est autem Abner étiam ad Bénjamin. Et ábiit ut loquerétur ad David in Hebron ómnia quæ placúerant Israéli et univérso Bénjamin.
20 Venítque ad David in Hebron cum vigínti viris, et fecit David Abner et viris ejus, qui vénerant cum eo, convívium.
21 Et dixit Abner ad David: Surgam ut cóngregem ad te, dóminum meum regem, omnem Israël."))
              :responsories
              ((:respond "Dómine, si convérsus fúerit pópulus tuus, et oráverit ad sanctuárium tuum:"
                  :verse "Si peccáverit in te pópulus tuus, et convérsus égerit pœniténtiam, veniénsque oráverit in isto loco."
                  :repeat "Tu exáudies de cælo, Dómine, et líbera eos de mánibus inimicórum suórum."
                  :gloria nil)
               (:respond "Factum est, dum tólleret Dóminus Elíam per túrbinem in cælum, Eliséus clamábat, dicens:"
                  :verse "Cumque simul pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque, et clamábat Eliséus:"
                  :repeat "Pater mi, pater mi, currus Israël, et auríga ejus."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent05-3: Feria quarta infra Hebdomadam V post Octavam Pentecostes
    ((5 . 3) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 4:5-8"
               :text "5 Veniéntes ígitur fílii Remmon Berothítæ, Rechab et Báana, ingréssi sunt, fervénte die, domum Isboseth; qui dormiébat super stratum suum merídie. Et ostiária domus purgans tríticum obdormívit.
6 Ingréssi sunt autem domum laténter assuméntes spicas trítici, et percussérunt eum in ínguine Rechab et Báana frater ejus et fugérunt.
7 Cum autem ingréssi fuíssent domum, ille dormiébat super lectum suum in conclávi, et percutiéntes interfecérunt eum; sublatóque cápite ejus abiérunt per viam desérti tota nocte.
8 Et attulérunt caput Isboseth ad David in Hebron dixerúntque ad regem: Ecce caput Isboseth, fílii Saul inimíci tui, qui quærébat ánimam tuam.")
               (:ref "2 Reg 4:9-12"
               :text "9 Respóndens autem David Rechab et Báana fratri ejus fíliis Remmon Berothítæ dixit ad eos: Vivit Dóminus, qui éruit ánimam meam de omni angústia,
10 quóniam eum, qui annuntiáverat mihi et díxerat: Mórtuus est Saul; qui putábat se próspera nuntiáre, ténui et occídi eum in Síceleg, cui oportébat mercédem dare pro núntio:
11 quanto magis nunc, cum hómines ímpii interfecérunt virum innóxium in domo sua super lectum suum, non quæram sánguinem ejus de manu vestra et áuferam vos de terra?
12 Præcépit ítaque David púeris suis, et interfecérunt eos, præcidentésque manus et pedes eórum suspendérunt eos super piscínam in Hebron; caput autem Isboseth tulérunt et sepeliérunt in sepúlcro Abner in Hebron.")
               (:ref "2 Reg 5:1-7"
               :text "1 Et venérunt univérsæ tribus Israël ad David in Hebron dicéntes: Ecce nos os tuum et caro tua sumus.
2 Sed et heri et nudiustértius, cum esset Saul rex super nos, tu eras edúcens et redúcens Israël; dixit autem Dóminus ad te: Tu pasces pópulum meum Israël et tu eris dux super Israël.
3 Venérunt quoque et senióres Israël ad regem in Hebron, et percússit cum eis rex David fœdus in Hebron coram Dómino, unxerúntque David in regem super Israël.
4 Fílius trigínta annórum erat David, cum regnáre cœpísset, et quadragínta annis regnávit.
5 In Hebron regnávit super Judam septem annis et sex ménsibus, in Jerúsalem autem regnávit trigínta tribus annis super omnem Israël et Judam.
6 Et ábiit rex, et omnes viri, qui erant cum eo, in Jerúsalem ad Jebusǽum habitatórem terræ, dictúmque est David ab eis: Non ingrediéris huc nisi abstúleris cæcos et claudos dicéntes: Non ingrediétur David huc.
7 Cepit autem David arcem Sion, hæc est cívitas David."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent05-4: Feria quinta infra Hebdomadam V post Octavam Pentecostes
    ((5 . 4) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 6:1-3"
               :text "1 Congregávit autem rursum David omnes eléctos ex Israël trigínta míllia.
2 Surrexítque pópulus et ábiit et univérsus pópulus qui erat cum eo de viris Juda, ut addúcerent arcam Dei, super quam invocátum est nomen Dómini exercítuum, sedéntis in Chérubim super eam.
3 Et imposuérunt arcam Dei super plaustrum novum tulerúntque eam de domo Abínadab, qui erat in Gábaa; Oza autem et Ahio fílii Abínadab, minábant plaustrum novum.")
               (:ref "2 Reg 6:4-7"
               :text "4 Cumque tulísset eam de domo Abínadab, qui erat in Gábaa custódiens arcam Dei, Ahio præcedébat arcam.
5 David autem et omnis Israël ludébant coram Dómino in ómnibus lignis fabrefáctis, et cítharis et lyris et týmpanis et sistris et cýmbalis.
6 Postquam autem venérunt ad áream Nachon, exténdit Oza manum ad arcam Dei et ténuit eam, quóniam calcitrábant boves et declinavérunt eam.
7 Iratúsque est indignatióne Dóminus contra Ozam, et percússit eum super temeritáte: qui mórtuus est ibi juxta arcam Dei.")
               (:ref "2 Reg 6:8-12"
               :text "8 Contristátus est autem David eo quod percussísset Dóminus Ozam; et vocátum est nomen loci illíus: Percússio Ozæ, usque in diem hanc.
9 Et extímuit David Dóminum in die illa, dicens: Quómodo ingrediétur ad me arca Dómini?
10 Et nóluit divértere ad se arcam Dómini in civitátem David; sed divértit eam in domum Obédedom Gethǽi.
11 Et habitávit arca Dómini in domo Obédedom Gethǽi tribus ménsibus, et benedíxit Dóminus Obédedom et omnem domum ejus.
12 Nuntiatúmque est regi David quod benedixísset Dóminus Obédedom, et ómnia ejus, propter arcam Dei. Abiit ergo David et addúxit arcam Dei de domo Obédedom in civitátem David cum gáudio."))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent05-5: Feria sexta infra Hebdomadam V post Octavam Pentecostes
    ((5 . 5) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 7:4-6"
               :text "4 Et ecce sermo Dómini ad Nathan, dicens:
5 Vade, et lóquere ad servum meum David: Hæc dicit Dóminus: Numquid tu ædificábis mihi domum ad habitándum?
6 Neque enim habitávi in domo ex die illa, qua edúxi fílios Israël de terra Ægýpti usque in diem hanc, sed ambulábam in tabernáculo, et in tentório.")
               (:ref "2 Reg 7:7-11"
               :text "7 Per cuncta loca, quæ transívi cum ómnibus fíliis Israël, numquid loquens locútus sum ad unum de tríbubus Israël, cui præcépi ut pásceret pópulum meum Israël, dicens: Quare non ædificástis mihi domum cédrinam?
8 Et nunc hæc dices servo meo David: Hæc dicit Dóminus exercítuum: Ego tuli te de páscuis sequéntem greges, ut esses dux super pópulum meum Israël,
9 et fui tecum in ómnibus ubicúmque ambulásti, et interféci univérsos inimícos tuos a fácie tua: fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra.
10 Et ponam locum pópulo meo Israël et plantábo eum, et habitábit sub eo et non turbábitur ámplius; nec addent fílii iniquitátis ut afflígant eum sicut prius, ex die qua constítui júdices super pópulum meum Israël.
11 Et réquiem dabo tibi ab ómnibus inimícis tuis: prædicítque tibi Dóminus, quod domum fáciat tibi Dóminus.")
               (:ref "2 Reg 7:12-17"
               :text "12 Cumque compléti fúerint dies tui, et dormíeris cum pátribus tuis, suscitábo semen tuum post te, quod egrediétur de útero tuo, et firmábo regnum ejus.
13 Ipse ædificábit domum nómini meo, et stabíliam thronum regni ejus usque in sempitérnum.
14 Ego ero ei in patrem, et ipse erit mihi in fílium. Qui si iníque áliquid gésserit, árguam eum in virga virórum, et in plagis filiórum hóminum.
15 Misericórdiam autem meam non áuferam ab eo, sicut ábstuli a Saul, quem amóvi a fácie mea.
16 Et fidélis erit domus tua, et regnum tuum usque in ætérnum ante fáciem tuam, et thronus tuus erit firmus júgiter.
17 Secúndum ómnia verba hæc, et juxta univérsam visiónem istam, sic locútus est Nathan ad David."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent05-6: Sabbato infra Hebdomadam V post Octavam Pentecostes
    ((5 . 6) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 11:1-4"
               :text "1 Factum est autem, verténte anno, eo témpore quo solent reges ad bella procédere, misit David Joab, et servos suos cum eo, et univérsum Israël, et vastavérunt fílios Ammon, et obsedérunt Rabba; David autem remánsit in Jerúsalem.
2 Dum hæc ageréntur, áccidit ut súrgeret David de strato suo post merídiem et deambuláret in solário domus régiæ: vidítque mulíerem se lavántem ex advérso super solárium suum; erat autem múlier pulchra valde.
3 Misit ergo rex, et requisívit quæ esset múlier; nuntiatúmque est ei, quod ipsa esset Bethsabée fília Elíam, uxor Uríæ Hethǽi.
4 Missis ítaque David núntiis, tulit eam.")
               (:ref "2 Reg 11:5-11"
               :text "5 Et revérsa est in domum suam, concépto fœtu. Mitténsque nuntiávit David et ait: Concépi.
6 Misit autem David ad Joab dicens: Mitte ad me Uríam Hethǽum. Misítque Joab Uríam ad David.
7 Et venit Urías ad David. Quæsivítque David quam recte ágeret Joab et pópulus, et quómodo administrarétur bellum.
8 Et dixit David ad Uríam: Vade in domum tuam et lava pedes tuos. Et egréssus est Urías de domo regis, secutúsque est eum cibus régius.
9 Dormívit autem Urías ante portam domus régiæ cum áliis servis dómini sui, et non descéndit ad domum suam.
10 Nuntiatúmque est David a dicéntibus: Non ivit Urías in domum suam. Et ait David ad Uríam: Numquid non de via venísti? quare non descendísti in domum tuam?
11 Et ait Urías ad David: Arca Dei et Israël et Juda hábitant in papiliónibus, et dóminus meus Joab et servi dómini mei super fáciem terræ manent; et ego ingrédiar domum meam, ut cómedam et bibam, et dórmiam cum uxóre mea? Per salútem tuam et per salútem ánimæ tuæ non fáciam rem hanc.")
               (:ref "2 Reg 11:12-17"
               :text "12 Ait ergo David ad Uríam: Mane hic étiam hódie, et cras dimíttam te. Mansit Urías in Jerúsalem in die illa et áltera.
13 Et vocávit eum David ut coméderet coram se et bíberet et inebriávit eum; qui egréssus véspere dormívit in strato suo cum servis dómini sui, et in domum suam non descéndit.
14 Factum est ergo mane, et scripsit David epístolam ad Joab: misítque per manum Uríæ,
15 scribens in epístola: Pónite Uríam ex advérso belli, ubi fortíssimum est prǽlium, et derelínquite eum ut percússus intéreat.
16 Igitur cum Joab obsidéret urbem, pósuit Uríam in loco ubi sciébat viros esse fortíssimos.
17 Egressíque viri de civitáte bellábant advérsum Joab, et cecidérunt de pópulo servórum David, et mórtuus est étiam Urías Hethǽus."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent06-1: Feria secunda infra Hebdomadam VI post Octavam Pentecostes
    ((6 . 1) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 13:22-25"
               :text "22 Porro non est locútus Absalom ad Amnon nec malum nec bonum; óderat enim Absalom Amnon, eo quod violásset Thamar sorórem suam.
23 Factum est autem post tempus biénnii ut tonderéntur oves Absalom in Baálhasor, quæ est juxta Ephraim; et vocávit Absalom omnes fílios regis,
24 venítque ad regem et ait ad eum: Ecce tondéntur oves servi tui; véniat, oro, rex cum servis suis ad servum suum.
25 Dixítque rex ad Absalom: Noli, fili mi, noli rogáre ut veniámus omnes et gravémus te. Cum autem cógeret eum, et noluísset ire, benedíxit ei.")
               (:ref "2 Reg 13:26-29"
               :text "26 Et ait Absalom: Si non vis veníre, véniat, óbsecro, nobíscum saltem Amnon frater meus. Dixítque ad eum rex: Non est necésse ut vadat tecum.
27 Coégit ítaque Absalom eum et dimísit cum eo Amnon et univérsos fílios regis. Fecerátque Absalom convívium quasi convívium regis.
28 Præcéperat autem Absalom púeris suis dicens: Observáte: cum temuléntus fúerit Amnon vino, et díxero vobis: Percútite eum et interfícite; nolíte timére, ego enim sum qui præcípio: roborámini et estóte viri fortes.
29 Fecérunt ergo púeri Absalom advérsum Amnon sicut præcéperat eis Absalom. Surgentésque omnes fílii regis ascendérunt sínguli mulas suas et fugérunt.")
               (:ref "2 Reg 13:30-34"
               :text "30 Cumque adhuc pérgerent in itínere, fama pervénit ad David dicens: Percússit Absalom omnes fílios regis, et non remánsit ex eis saltem unus.
31 Surréxit ítaque rex et scidit vestiménta sua et cécidit super terram, et omnes servi illíus, qui assistébant ei, scidérunt vestiménta sua.
32 Respóndens autem Jónadab fílius Sémmaa fratris David dixit: Ne ǽstimet dóminus meus rex quod omnes púeri fílii regis occísi sint; Amnon solus mórtuus est, quóniam in ore Absalom erat pósitus ex die qua oppréssit Thamar sorórem ejus.
33 Nunc ergo ne ponat dóminus meus rex super cor suum verbum istud dicens: Omnes fílii regis occísi sunt, quóniam Amnon solus mórtuus est.
34 Fugit autem Absalom."))
              :responsories
              ((:respond "Recordáre, Dómine, testaménti tui, et dic Angelo percutiénti: Cesset jam manus tua,"
                  :verse "Quiéscat, Dómine, ira tua a pópulo tuo, et a civitáte sancta tua:"
                  :repeat "Ut non desolétur terra, et ne perdas omnem ánimam vivam."
                  :gloria nil)
               nil
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent06-2: Feria tertia infra Hebdomadam VI post Octavam Pentecostes
    ((6 . 2) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 14:4-7"
               :text "4 Cum ingréssa fuísset múlier Thecuítis ad regem, cécidit coram eo super terram et adorávit et dixit: Serva me, rex.
5 Et ait ad eam rex: Quid causæ habes? Quæ respóndit: Heu, múlier vídua ego sum; mórtuus est enim vir meus.
6 Et ancíllæ tuæ erant duo fílii, qui rixáti sunt advérsum se in agro, nullúsque erat qui eos prohibére posset, et percússit alter álterum et interfécit eum.
7 Et ecce consúrgens univérsa cognátio advérsum ancíllam tuam dicit: Trade eum qui percússit fratrem suum, ut occidámus eum pro ánima fratris sui quem interfécit, et deleámus herédem. Et quærunt exstínguere scintíllam meam quæ relícta est, ut non supérsit viro meo nomen, et relíquiæ super terram.")
               (:ref "2 Reg 14:10-14"
               :text "10 Et ait rex: Qui contradíxerit tibi, adduc eum ad me, et ultra non addet ut tangat te.
11 Quæ ait: Recordétur rex Dómini Dei sui, ut non multiplicéntur próximi sánguinis ad ulciscéndum, et nequáquam interfíciant fílium meum. Qui ait: Vivit Dóminus, quia non cadet de capíllis fílii tui super terram.
12 Dixit ergo múlier: Loquátur ancílla tua ad dóminum meum regem verbum. Et ait: Lóquere.
13 Dixítque múlier: Quare cogitásti hujuscémodi rem contra pópulum Dei et locútus est rex verbum istud, ut peccet et non redúcat ejéctum suum?
14 Omnes mórimur et quasi aquæ dilábimur in terram, quæ non revertúntur, nec vult Deus períre ánimam, sed retráctat cógitans ne pénitus péreat qui abjéctus est.")
               (:ref "2 Reg 14:19-21"
               :text "19 Et ait rex: Numquid manus Joab tecum est in ómnibus istis? Respóndit múlier et ait: Per salútem ánimæ tuæ, dómine mi rex, nec ad sinístram nec ad déxteram est ex ómnibus his quæ locútus est dóminus meus rex; servus enim tuus Joab ipse præcépit mihi et ipse pósuit in os ancíllæ tuæ ómnia verba hæc.
20 Ut vérterem figúram sermónis hujus, servus tuus Joab præcépit istud; tu autem, dómine mi rex, sápiens es, sicut habet sapiéntiam Angelus Dei, ut intéllegas ómnia super terram.
21 Et ait rex ad Joab: Ecce placátus feci verbum tuum; vade ergo, et révoca púerum Absalom."))
              :responsories
              ((:respond "Dómine, si convérsus fúerit pópulus tuus, et oráverit ad sanctuárium tuum:"
                  :verse "Si peccáverit in te pópulus tuus, et convérsus égerit pœniténtiam, veniénsque oráverit in isto loco."
                  :repeat "Tu exáudies de cælo, Dómine, et líbera eos de mánibus inimicórum suórum."
                  :gloria nil)
               (:respond "Factum est, dum tólleret Dóminus Elíam per túrbinem in cælum, Eliséus clamábat, dicens:"
                  :verse "Cumque simul pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque, et clamábat Eliséus:"
                  :repeat "Pater mi, pater mi, currus Israël, et auríga ejus."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent06-3: Feria quarta infra Hebdomadam VI post Octavam Pentecostes
    ((6 . 3) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 15:1-3"
               :text "1 Igitur post hæc fecit sibi Absalom currus et équites et quinquagínta viros, qui præcéderent eum.
2 Et mane consúrgens Absalom stabat juxta intróitum portæ et omnem virum, qui habébat negótium ut veníret ad regis judícium, vocábat Absalom ad se et dicébat: De qua civitáte es tu? Qui respóndens ajébat: Ex una tribu Israël ego sum servus tuus.
3 Respondebátque ei Absalom: Vidéntur mihi sermónes tui boni et justi; sed non est qui te áudiat constitútus a rege.")
               (:ref "2 Reg 15:3-6"
               :text "3 Dicebátque Absalom:
4 Quis me constítuat júdicem super terram, ut ad me véniant omnes qui habent negótium et juste júdicem?
5 Sed et, cum accéderet ad eum homo ut salutáret illum, extendébat manum suam et apprehéndens osculabátur eum.
6 Faciebátque hoc omni Israël veniénti ad judícium ut audirétur a rege, et sollicitábat corda virórum Israël.")
               (:ref "2 Reg 15:7-10"
               :text "7 Post quadragínta autem annos, dixit Absalom ad regem David: Vadam et reddam vota mea, quæ vovi Dómino, in Hebron.
8 Vovens enim vovit servus tuus, cum esset in Gessur Sýriæ, dicens: Si redúxerit me Dóminus in Jerúsalem, sacrificábo Dómino.
9 Dixítque ei rex David: Vade in pace. Et surréxit et ábiit in Hebron.
10 Misit autem Absalom exploratóres in univérsas tribus Israël dicens: Statim ut audiéritis clangórem búccinæ, dícite: Regnávit Absalom in Hebron."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent06-4: Feria quinta infra Hebdomadam VI post Octavam Pentecostes
    ((6 . 4) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 15:13-15"
               :text "13 Venit ígitur núntius ad David dicens: Toto corde univérsus Israël séquitur Absalom.
14 Et ait David servis suis qui erant cum eo in Jerúsalem: Súrgite, fugiámus; neque enim erit nobis effúgium a fácie Absalom. Festináte égredi, ne forte véniens óccupet nos et impéllat super nos ruínam et percútiat civitátem in ore gládii.
15 Dixerúntque servi regis ad eum: Omnia, quæcúmque præcéperit dóminus noster rex, libénter exsequémur servi tui.")
               (:ref "2 Reg 15:16-18"
               :text "16 Egréssus est ergo rex et univérsa domus ejus pédibus suis; et derelíquit rex decem mulíeres concubínas ad custodiéndam domum.
17 Egressúsque rex et omnis Israël pédibus suis stetit procul a domo.
18 Et univérsi servi ejus ambulábant juxta eum; et legiónes Ceréthi et Pheléthi et omnes Gethǽi pugnatóres válidi sexcénti viri, qui secúti eum fúerant de Geth, pédites præcedébant regem.")
               (:ref "2 Reg 15:19-20"
               :text "19 Dixit autem rex ad Ethái Gethǽum: Cur venis nobíscum? Revértere et hábita cum rege, quia peregrínus es et egréssus es de loco tuo.
20 Heri venísti, et hódie compélleris nobíscum égredi? Ego autem vadam quo itúrus sum; revértere et reduc tecum fratres tuos, et Dóminus fáciet tecum misericórdiam et veritátem, quia ostendísti grátiam et fidem."))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent06-5: Feria sexta infra Hebdomadam VI post Octavam Pentecostes
    ((6 . 5) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 16:5-8"
               :text "5 Venit ergo rex David usque Bahúrim, et ecce egrediebátur inde vir de cognatióne domus Saul nómine Sémei fílius Gera; procedebátque egrédiens et maledicébat,
6 mittebátque lápides contra David et contra univérsos servos regis David.  Omnis autem pópulus et univérsi bellatóres a dextro et a sinístro látere regis incedébant.
7 Ita autem loquebátur Sémei, cum maledíceret regi: Egrédere, egrédere, vir sánguinum et vir Bélial:
8 réddidit tibi Dóminus univérsum sánguinem domus Saul, quóniam invasísti regnum pro eo.")
               (:ref "2 Reg 16:9-10"
               :text "9 Dixit autem Abísai fílius Sárviæ regi: Quare maledícit canis hic mórtuus dómino meo regi? vadam et amputábo caput ejus.
10 Et ait rex: Quid mihi et vobis est, fílii Sárviæ?  Dimíttite eum ut maledícat; Dóminus enim præcépit ei ut maledíceret David, et quis est qui áudeat dícere quare sic fécerit?")
               (:ref "2 Reg 16:11-12"
               :text "11 Et ait rex Abísai et univérsis servis suis: Ecce fílius meus, qui egréssus est de útero meo, quærit ánimam meam; quanto magis nunc fílius Jémini? Dimíttite eum ut maledícat juxta præcéptum Dómini;
12 si forte respíciat Dóminus afflictiónem meam et reddat mihi Dóminus bonum pro maledictióne hac hodiérna."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent06-6: Sabbato infra Hebdomadam VI post Octavam Pentecostes
    ((6 . 6) . (:lessons
              ((:source "De libro secúndo Regum"
               :ref "2 Reg 18:6-8"
               :text "6 Egréssus est pópulus in campum contra Israël, et factum est prǽlium in saltu Ephraim.
7 Et cæsus est ibi pópulus Israël ab exércitu David, fáctaque est plaga magna in die illa vigínti míllium.
8 Fuit autem ibi prǽlium dispérsum super fáciem omnis terræ, et multo plures erant, quos saltus consúmpserat de pópulo, quam hi quos voráverat gládius in die illa.")
               (:ref "2 Reg 18:9-12"
               :text "9 Accidit autem ut occúrreret Absalom servis David sedens mulo; cumque ingréssus fuísset mulus subter condénsam quercum et magnam, adhǽsit caput ejus quércui et, illo suspénso inter cælum et terram, mulus cui inséderat, pertransívit.
10 Vidit autem hoc quíspiam, et nuntiávit Joab dicens: Vidi Absalom pendére de quercu.
11 Et ait Joab viro qui nuntiáverat ei: Si vidísti, quare non confodísti eum cum terra et ego dedíssem tibi decem argénti siclos et unum bálteum?
12 Qui dixit ad Joab: Si appénderes in mánibus meis mille argénteos, nequáquam mítterem manum meam in fílium regis; audiéntibus enim nobis, præcépit rex tibi, et Abísai, et Ethái, dicens: Custodíte mihi púerum Absalom.")
               (:ref "2 Reg 18:14-17"
               :text "14 Et ait Joab: Non sicut tu vis, sed aggrédiar eum coram te. Tulit ergo tres lánceas in manu sua et infíxit eas in corde Absalom; cumque adhuc palpitáret hærens in quercu,
15 cucurrérunt decem júvenes armígeri Joab et percutiéntes interfecérunt eum.
16 Cécinit autem Joab búccina et retínuit pópulum, ne persequerétur fugiéntem Israël, volens párcere multitúdini.
17 Et tulérunt Absalom et projecérunt eum in saltu in fóveam grandem et comportavérunt super eum acérvum lápidum magnum nimis."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent07-1: Feria secunda infra Hebdomadam VII post Octavam Pentecostes
    ((7 . 1) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 1:28-31"
               :text "28 Et respóndit rex David dicens: Vocáte ad me Bethsabée. Quæ cum fuísset ingréssa coram rege et stetísset ante eum,
29 jurávit rex, et ait: Vivit Dóminus, qui éruit ánimam meam de omni angústia,
30 quia, sicut jurávi tibi per Dóminum Deum Israël dicens: Sálomon fílius tuus regnábit post me et ipse sedébit super sólium meum pro me, sic fáciam hódie.
31 Summissóque Bethsabée in terram vultu, adorávit regem, dicens: Vivat dóminus meus David in ætérnum.")
               (:ref "3 Reg 1:32-35"
               :text "32 Dixit quoque rex David: Vocáte mihi Sadoc sacerdótem et Nathan prophétam et Banájam fílium Jójadæ. Qui cum ingréssi fuíssent coram rege,
33 dixit ad eos: tóllite vobíscum servos Dómini vestri, et impónite Salomónem fílium meum super mulam meam, et dúcite eum in Gihon,
34 et ungat eum ibi Sadoc sacérdos et Nathan prophéta in regem super Israël. Et canétis búccina, atque dicétis: Vivat rex Sálomon.
35 Et ascendétis post eum, et véniet, et sedébit super sólium meum, et ipse regnábit pro me.")
               (:ref "3 Reg 1:38-40"
               :text "38 Descéndit ergo Sadoc sacérdos, et Nathan prophéta, et Banájas fílius Jójadæ et Ceréthi, et Pheléthi: et imposuérunt Salomónem super mulam regis David, et adduxérunt eum in Gihon.
39 Sumpsítque Sadoc sacérdos cornu ólei de tabernáculo, et unxit Salomónem: et cecinérunt búccina, et dixit omnis pópulus: Vivat rex Sálomon.
40 Et ascéndit univérsa multitúdo post eum, et pópulus canéntium tíbiis, et lætántium gáudio magno: et insónuit terra a clamóre eórum."))
              :responsories
              ((:respond "Recordáre, Dómine, testaménti tui, et dic Angelo percutiénti: Cesset jam manus tua,"
                  :verse "Quiéscat, Dómine, ira tua a pópulo tuo, et a civitáte sancta tua:"
                  :repeat "Ut non desolétur terra, et ne perdas omnem ánimam vivam."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent07-2: Feria tertia infra Hebdomadam VII post Octavam Pentecostes
    ((7 . 2) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 2:1-4"
               :text "1 Appropinquavérunt autem dies David ut morerétur, præcepítque Salomóni fílio suo, dicens:
2 Ego ingrédior viam univérsæ terræ: confortáre, et esto vir,
3 et obsérva custódias Dómini Dei tui, ut ámbules in viis ejus: ut custódias cæremónias ejus, et præcépta ejus, et judícia, et testimónia, sicut scriptum est in lege Móysi; ut intéllegas univérsa quæ facis, et quocúmque te vérteris;
4 ut confírmet Dóminus sermónes suos, quos locútus est de me dicens: Si custodíerint fílii tui vias suas, et ambuláverint coram me in veritáte in omni corde suo et in omni ánima sua, non auferétur tibi vir de sólio Israël.")
               (:ref "3 Reg 2:5-6"
               :text "5 Tu quoque nosti quæ fécerit mihi Joab fílius Sárviæ, quæ fécerit duóbus princípibus exércitus Israël, Abner fílio Ner, et Amasæ fílio Jether: quos occídit, et effúdit sánguinem belli in pace, et pósuit cruórem prǽlii in bálteo suo, qui erat circa lumbos ejus, et in calceaménto suo, quod erat in pédibus ejus.
6 Fácies ergo juxta sapiéntiam tuam, et non dedúces canítiem ejus pacífice ad ínferos.")
               (:ref "3 Reg 2:7-9"
               :text "7 Sed et fíliis Berzellái Galaadítis reddes grátiam, erúntque comedéntes in mensa tua; occurérunt enim mihi quando fugiébam a fácie Absalom fratris tui.
8 Habes quoque apud te Sémei fílium Gera fílii Jémini de Bahúrim, qui maledíxit mihi maledictióne péssima, quando ibam ad castra; sed quia descéndit mihi in occúrsum, cum transírem Jordánem, et jurávi ei per Dóminum, dicens: Non te interfíciam gládio.
9 Tu noli pati eum esse innóxium."))
              :responsories
              ((:respond "Dómine, si convérsus fúerit pópulus tuus, et oráverit ad sanctuárium tuum:"
                  :verse "Si peccáverit in te pópulus tuus, et convérsus égerit pœniténtiam, veniénsque oráverit in isto loco."
                  :repeat "Tu exáudies de cælo, Dómine, et líbera eos de mánibus inimicórum suórum."
                  :gloria nil)
               (:respond "Factum est, dum tólleret Dóminus Elíam per túrbinem in cælum, Eliséus clamábat, dicens:"
                  :verse "Cumque simul pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque, et clamábat Eliséus:"
                  :repeat "Pater mi, pater mi, currus Israël, et auríga ejus."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent07-3: Feria quarta infra Hebdomadam VII post Octavam Pentecostes
    ((7 . 3) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 3:5-6"
               :text "5 Appáruit autem Dóminus Salomóni per sómnium nocte, dicens: Póstula quod vis ut dem tibi.
6 Et ait Sálomon: Tu fecísti cum servo tuo David patre meo misericórdiam magnam, sicut ambulávit in conspéctu tuo in veritáte et justítia, et recto corde tecum; custodísti ei misericórdiam tuam grandem, et dedísti ei fílium sedéntem super thronum ejus, sicut est hódie.")
               (:ref "3 Reg 3:7-9"
               :text "7 Et nunc, Dómine Deus, tu regnáre fecísti servum tuum pro David patre meo: Ego autem sum puer párvulus et ignórans egréssum et intróitum meum;
8 et servus tuus in médio est pópuli quem elegísti, pópuli infiníti, qui numerári et supputári non potest præ multitúdine.
9 Dabis ergo servo tuo cor dócile, ut pópulum tuum judicáre possit et discérnere inter bonum et malum. Quis enim póterit judicáre pópulum istum, pópulum tuum hunc multum?")
               (:ref "3 Reg 3:10-13"
               :text "10 Plácuit ergo sermo coram Dómino, quod Sálomon postulásset hujuscémodi rem.
11 Et dixit Dóminus Salomóni: Quia postulásti verbum hoc, et non petísti tibi dies multos, nec divítias, aut ánimas inimicórum tuórum, sed postulásti tibi sapiéntiam ad discernéndum judícium:
12 ecce feci tibi secúndum sermónes tuos, et dedi tibi cor sápiens et intéllegens, in tantum ut nullus ante símilis tui fúerit, nec post te surrectúrus sit.
13 Sed et hæc, quæ non postulásti, dedi tibi, divítias scílicet et glóriam, ut nemo fúerit símilis tui in régibus cunctis retro diébus."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent07-4: Feria quinta infra Hebdomadam VII post Octavam Pentecostes
    ((7 . 4) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 4:21-24"
               :text "21 Sálomon autem erat in dicióne sua, habens ómnia regna a flúmine terræ Philísthiim usque ad términum Ægýpti: offeréntium sibi múnera, et serviéntium ei cunctis diébus vitæ ejus.
22 Erat autem cibus Salomónis per dies síngulos trigínta cori símilæ, et sexagínta cori farínæ,
23 decem boves pingues, et vigínti boves pascuáles, et centum aríetes, excépta venatióne cervórum, capreárum, atque bubalórum, et ávium altílium.
24 Ipse enim obtinébat omnem regiónem, quæ erat trans flumen, a Thaphsa usque ad Gazam, et cunctos reges illárum regiónum: et habébat pacem ex omni parte in circúitu.")
               (:ref "3 Reg 4:25-29"
               :text "25 Habitabátque Juda et Israël absque timóre ullo, unusquísque sub vite sua et sub ficu sua, a Dan usque Bersabée, cunctis diébus Salomónis.
26 Et habébat Sálomon quadragínta míllia præsépia equórum currílium, et duódecim míllia equéstrium.
27 Nutriebántque eos supradícti regis præfécti; sed et necessária mensæ regis Salomónis cum ingénti cura præbébant in témpore suo.
28 Hórdeum quoque, et páleas equórum et jumentórum, deferébant in locum, ubi erat rex, juxta constitútum sibi.
29 Dedit quoque Deus sapiéntiam Salomóni et prudéntiam multam nimis et latitúdinem cordis quasi arénam quæ est in líttore maris.")
               (:ref "3 Reg 4:30-34"
               :text "30 Et præcedébat sapiéntia Salomónis sapiéntiam ómnium Orientálium et Ægyptiórum;
31 et erat sapiéntior cunctis homínibus: sapiéntior Ethan Ezrahíta, et Heman, et Chalcol, et Dorda fíliis Mahol: et erat nominátus in univérsis géntibus per circúitum.
32 Locútus est quoque Sálomon tria míllia parábolas: et fuérunt cármina ejus quinque et mille.
33 Et disputávit super lignis a cedro, quæ est in Líbano, usque ad hyssópum quæ egrediétur de paríete; et disséruit de juméntis, et volúcribus, et reptílibus, et píscibus.
34 Et veniébant de cunctis pópulis ad audiéndam sapiéntiam Salomónis, et ab univérsis régibus terræ, qui audiébant sapiéntiam ejus."))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent07-5: Feria sexta infra Hebdomadam VII post Octavam Pentecostes
    ((7 . 5) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 5:1-4"
               :text "1 Misit quoque Hiram, rex Tyri, servos suos ad Salomónem; audívit enim quod ipsum unxíssent regem pro patre ejus; quia amícus fúerat Hiram David omni témpore.
2 Misit autem Sálomon ad Hiram, dicens:
3 Tu scis voluntátem David patris mei, et quia non potúerit ædificáre domum nómini Dómini Dei sui propter bella imminéntia per circúitum, donec daret Dóminus eos sub vestígio pedum ejus.
4 Nunc autem réquiem dedit Dóminus Deus meus mihi per circúitum, et non est satan neque occúrsus malus.")
               (:ref "3 Reg 5:5-6"
               :text "5 Quam ob rem cógito ædificáre templum nómini Dómini Dei mei, sicut locútus est Dóminus David, patri meo, dicens: Fílius tuus, quem dabo pro te super sólium tuum, ipse ædificábit domum nómini meo.
6 Prǽcipe ígitur ut præcídant mihi servi tui cedros de Líbano, et servi mei sint cum servis tuis; mercédem autem servórum tuórum dabo tibi quamcúmque petíeris; scis enim quómodo non est in pópulo meo vir qui nóverit ligna cǽdere sicut Sidónii.")
               (:ref "3 Reg 5:7-9"
               :text "7 Cum ergo audísset Hiram verba Salomónis, lætátus est valde, et ait: Benedíctus Dóminus Deus hódie, qui dedit David fílium sapientíssimum super pópulum hunc plúrimum.
8 Et misit Hiram ad Salomónem, dicens: Audívi quæcúmque mandásti mihi: ego fáciam omnem voluntátem tuam in lignis cédrinis et abiégnis.
9 Servi mei depónent ea de Líbano ad mare, et ego compónam ea in rátibus in mari usque ad locum quem significáveris mihi; et applicábo ea ibi, et tu tolles ea præbebísque necessária mihi ut detur cibus dómui meæ."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent07-6: Sabbato infra Hebdomadam VII post Octavam Pentecostes
    ((7 . 6) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 7:51; 8:1-2"
               :text "51 Et perfécit omne opus, quod faciébat Sálomon in domo Dómini, et íntulit quæ sanctificáverat David pater suus, argéntum, et aurum, et vasa, reposuítque in thesáuris domus Dómini.
1 Tunc congregáti sunt omnes majóres natu Israël cum princípibus tríbuum et duces familiárum filiórum Israël ad regem Salomónem in Jerúsalem, ut deférrent arcam fœ́deris Dómini de civitáte David, id est de Sion.
2 Convenítque ad regem Salomónem univérsus Israël in mense Ethánim in solémni die (ipse est mensis séptimus).")
               (:ref "3 Reg 8:3-7"
               :text "3 Venerúntque cuncti senes de Israël, et tulérunt arcam sacerdótes,
4 et portavérunt arcam Dómini, et tabernáculum fœ́deris et ómnia vasa sanctuárii, quæ erant in tabernáculo, et ferébant ea sacerdótes et levítæ.
5 Rex autem Sálomon et omnis multitúdo Israël, quæ convénerat ad eum, gradiebátur cum illo ante arcam, et immolábant oves et boves absque æstimatióne et número.
6 Et intulérunt sacerdótes arcam fœ́deris Dómini in locum suum, in oráculum templi, in Sanctum sanctórum, subter alas Chérubim;
7 síquidem Chérubim expandébant alas super locum arcæ, et protegébant arcam, et vectes ejus désuper.")
               (:ref "3 Reg 8:9-12"
               :text "9 In arca autem non erat áliud nisi duæ tábulæ lapídeæ, quas posúerat in ea Móyses in Horeb, quando pépigit Dóminus fœdus cum fíliis Israël, cum egrederéntur de terra Ægýpti.
10 Factum est autem, cum exíssent sacerdótes de sanctuário, nébula implévit domum Dómini,
11 et non póterant sacerdótes stare et ministráre propter nébulam; impléverat enim glória Dómini domum Dómini.
12 Tunc ait Sálomon: Dóminus dixit ut habitáret in nébula."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent08-1: Feria secunda infra Hebdomadam VIII post Octavam Pentecostes
    ((8 . 1) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 10:1-3"
               :text "1 Sed et regína Saba audíta fama Salomónis in nómine Dómini, venit tentáre eum in ænigmátibus.
2 Et ingréssa Jerúsalem multo cum comitátu et divítiis, camélis portántibus arómata, et aurum infinítum nimis, et gemmas pretiósas, venit ad regem Salomónem, et locúta est ei univérsa quæ habébat in corde suo.
3 Et dócuit eam Sálomon ómnia verba quæ proposúerat; non fuit sermo qui regem posset latére, et non respondéret ei.")
               (:ref "3 Reg 10:4-7"
               :text "4 Videns autem regína Saba omnem sapiéntiam Salomónis et domum quam ædificáverat,
5 et cibos mensæ ejus, et habitácula servórum, et órdines ministrántium, vestésque eórum, et pincérnas, et holocáusta quæ offerébat in domo Dómini, non habébat ultra spíritum;
6 dixítque ad regem: Verus est sermo, quem audívi in terra mea
7 super sermónibus tuis, et super sapiéntia tua: et non credébam narrántibus mihi, donec ipsa veni, et vidi óculis meis, et probávi quod média pars mihi nuntiáta non fúerit. Major est sapiéntia et ópera tua, quam rumor quem audívi.")
               (:ref "3 Reg 10:8-11"
               :text "8 Beáti viri tui, et beáti servi tui, qui stant coram te semper et áudiunt sapiéntiam tuam.
9 Sit Dóminus Deus tuus benedíctus, cui complacuísti, et pósuit te super thronum Israël, eo quod diléxerit Dóminus Israël in sempitérnum, et constítuit te regem ut fáceres judícium et justítiam.
10 Dedit ergo regi centum vigínti talénta auri, et arómata multa nimis, et gemmas pretiósas. Non sunt alláta ultra arómata tam multa, quam ea quæ dedit regína Saba regi Salomóni.
11 Sed et classis Hiram, quæ portábat aurum de Ophir, áttulit ex Ophir ligna thyína multa nimis, et gemmas pretiósas."))
              :responsories
              ((:respond "Recordáre, Dómine, testaménti tui, et dic Angelo percutiénti: Cesset jam manus tua,"
                  :verse "Quiéscat, Dómine, ira tua a pópulo tuo, et a civitáte sancta tua:"
                  :repeat "Ut non desolétur terra, et ne perdas omnem ánimam vivam."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent08-2: Feria tertia infra Hebdomadam VIII post Octavam Pentecostes
    ((8 . 2) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 11:1-4"
               :text "1 Rex autem Sálomon adamávit mulíeres alienígenas multas, fíliam quoque pharaónis, et Moabítidas, et Ammonítidas, Idumǽas, et Sidónias, et Hethǽas:
2 de géntibus super quibus dixit Dóminus fíliis Israël: Non ingrediémini ad eas, neque de illis ingrediéntur ad vestras; certíssime enim avértent corda vestra ut sequámini deos eárum.  His ítaque copulátus est Sálomon ardentíssimo amóre:
3 fuerúntque ei uxóres quasi regínæ septingéntæ, et concubínæ trecéntæ; et avertérunt mulíeres cor ejus.
4 Cumque jam esset senex, depravátum est cor ejus per mulíeres, ut sequerétur deos aliénos; nec erat cor ejus perféctum cum Dómino Deo suo, sicut cor David patris ejus.")
               (:ref "3 Reg 11:5-8"
               :text "5 Sed colébat Sálomon Astárthen deam Sidoniórum, et Moloch idólum Ammonitárum.
6 Fecítque Sálomon quod non placúerat coram Dómino, et non adimplévit ut sequerétur Dóminum sicut David pater ejus.
7 Tunc ædificávit Sálomon fanum Chamos idólo Moab in monte, qui est contra Jerúsalem, et Moloch idólo filiórum Ammon.
8 Atque in hunc modum fecit univérsis uxóribus suis alienígenis, quæ adolébant thura, et immolábant diis suis.")
               (:ref "3 Reg 11:9-12"
               :text "9 Igitur irátus est Dóminus Salomóni, quod avérsa esset mens ejus a Dómino Deo Israël, qui apparúerat ei secúndo,
10 et præcéperat de verbo hoc ne sequerétur deos aliénos: et non custodívit quæ mandávit ei Dóminus.
11 Dixit ítaque Dóminus Salomóni: Quia habuísti hoc apud te, et non custodísti pactum meum, et præcépta mea quæ mandávi tibi, disrúmpens scindam regnum tuum, et dabo illud servo tuo.
12 Verúmtamen in diébus tuis non fáciam, propter David patrem tuum."))
              :responsories
              ((:respond "Dómine, si convérsus fúerit pópulus tuus, et oráverit ad sanctuárium tuum:"
                  :verse "Si peccáverit in te pópulus tuus, et convérsus égerit pœniténtiam, veniénsque oráverit in isto loco."
                  :repeat "Tu exáudies de cælo, Dómine, et líbera eos de mánibus inimicórum suórum."
                  :gloria nil)
               (:respond "Factum est, dum tólleret Dóminus Elíam per túrbinem in cælum, Eliséus clamábat, dicens:"
                  :verse "Cumque simul pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque, et clamábat Eliséus:"
                  :repeat "Pater mi, pater mi, currus Israël, et auríga ejus."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent08-3: Feria quarta infra Hebdomadam VIII post Octavam Pentecostes
    ((8 . 3) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 11:26-28"
               :text "26 Jeróboam quoque fílius Nabat Ephrathǽus de Saréda servus Salomónis, cujus mater erat nómine Sarva, múlier vídua, levávit manum contra regem.
27 Et hæc causa rebelliónis advérsus eum, quia Sálomon ædificávit Mello, et coæquávit voráginem civitátis David patris sui.
28 Erat autem Jeróboam vir fortis et potens; vidénsque Sálomon adolescéntem bonæ índolis et indústrium, constitúerat eum præféctum super tribúta univérsæ domus Joseph.")
               (:ref "3 Reg 11:29-31"
               :text "29 Factum est ígitur in témpore illo, ut Jeróboam egrederétur de Jerúsalem, et inveníret eum Ahías Silónites prophéta in via opértus pállio novo; erant autem duo tantum in agro.
30 Apprehendénsque Ahías pállium suum novum, quo coopértus erat, scidit in duódecim partes,
31 et ait ad Jeróboam: Tolle tibi decem scissúras; hæc enim dicit Dóminus Deus Israël: Ecce ego scindam regnum de manu Salomónis, et dabo tibi decem tribus.")
               (:ref "3 Reg 11:40-43"
               :text "40 Vóluit ergo Sálomon interfícere Jeróboam, qui surréxit, et aufúgit in Ægýptum ad Sesac regem Ægýpti, et fuit in Ægýpto usque ad mortem Salomónis.
41 Réliquum autem verbórum Salomónis, et ómnia quæ fecit, et sapiéntia ejus, ecce univérsa scripta sunt in libro verbórum diérum Salomónis.
42 Dies autem, quos regnávit Sálomon in Jerúsalem super omnem Israël, quadragínta anni sunt.
43 Dormivítque Sálomon cum pátribus suis, et sepúltus est in civitáte David patris sui: regnavítque Róboam fílius ejus pro eo."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent08-4: Feria quinta infra Hebdomadam VIII post Octavam Pentecostes
    ((8 . 4) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 12:1-5"
               :text "1 Venit autem Róboam in Sichem; illuc enim congregátus erat omnis Israël ad constituéndum eum regem.
2 At vero Jeróboam fílius Nabat, cum adhuc esset in Ægýpto prófugus a fácie regis Salomónis, audíta morte ejus, revérsus est de Ægýpto.
3 Miserúntque et vocavérunt eum. Venit ergo Jeróboam, et omnis multitúdo Israël, et locúti sunt ad Róboam, dicéntes:
4 Pater tuus duríssimum jugum impósuit nobis; tu ítaque nunc immínue páululum de império patris tui duríssimo, et de jugo gravíssimo quod impósuit nobis, et serviémus tibi.
5 Qui ait eis: Ite usque ad tértium diem, et revertímini ad me.")
               (:ref "3 Reg 12:5-8"
               :text "5 Cumque abiísset pópulus,
6 íniit consílium rex Róboam cum senióribus, qui assistébant coram Salomóne patre ejus cum adhuc víveret, et ait: Quod datis mihi consílium ut respóndeam pópulo huic?
7 Qui dixérunt ei: Si hódie obedíeris pópulo  huic et servíeris et petitióni eórum césseris locutúsque fúeris ad eos verba lénia, erunt tibi servi cunctis diébus.
8 Qui derelíquit consílium senum, quod déderant ei, at adhíbuit adolescéntes, qui nutríti fúerant cum eo, et assistébant illi.")
               (:ref "3 Reg 12:13-16"
               :text "13 Respondítque rex pópulo dura, derelícto consílio seniórum quod ei déderant,
14 et locútus est eis secúndum consílium júvenum dicens: Pater meus aggravávit jugum vestrum, ego autem addam jugo vestro; pater meus cécidit vos flagéllis, ego autem cædam vos scorpiónibus.
15 Et non acquiévit rex pópulo, quóniam aversátus fúerat eum Dóminus, ut suscitáret verbum suum, quod locútus fúerat in manu Ahíæ Silonítæ, ad Jeróboam fílium Nabat.
16 Videns ítaque pópulus quod noluísset eos audíre rex, respóndit ei, dicens: Quæ nobis pars in David? vel quæ heréditas in fílio Isai?"))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent08-5: Feria sexta infra Hebdomadam VIII post Octavam Pentecostes
    ((8 . 5) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 14:5-6"
               :text "5 Dixit autem Dóminus ad Ahíam: Ecce uxor Jeróboam ingréditur ut cónsulat te super fílio  suo, qui ægrótat: hæc et hæc loquéris ei. Cum ergo illa intráret et dissimuláret se esse quæ erat,
6 audívit Ahías sónitum pedum ejus introëúntis per óstium, et ait: Ingrédere, uxor Jeróboam: quare áliam te esse símulas? Ego autem missus sum ad te durus núntius.")
               (:ref "3 Reg 14:7-9"
               :text "7 Vade et dic Jeróboam: Hæc dicit Dóminus Deus Israël: Quia exaltávi te de médio pópuli, et dedi te ducem super pópulum meum Israël,
8 et scidi regnum domus David, et dedi illud tibi, et non fuísti sicut servus meus David, qui custodívit mandáta mea, et secútus est me in toto corde suo, fáciens quod plácitum esset in conspéctu meo;
9 sed operátus es mala super omnes, qui fuérunt ante te, et fecísti tibi deos aliénos et conflátiles, ut me ad iracúndiam provocáres; me autem projecísti post corpus tuum.")
               (:ref "3 Reg 14:10-12"
               :text "10 Idcírco ecce ego indúcam mala super domum Jeróboam, et percútiam de Jeróboam mingéntem ad paríetem, et clausum, et novíssimum in Israël; et mundábo relíquias domus Jeróboam, sicut mundári solet fimus usque ad purum.
11 Qui mórtui fúerint de Jeróboam in civitáte, cómedent eos canes; qui autem mórtui fúerint in agro, vorábunt eos aves cæli: quia Dóminus locútus est.
12 Tu ígitur surge, et vade in domum tuam, et in ipso intróitu pedum tuórum in urbem, moriétur puer."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent08-6: Sabbato infra Hebdomadam VIII post Octavam Pentecostes
    ((8 . 6) . (:lessons
              ((:source "De libro tértio Regum"
               :ref "3 Reg 18:21-22"
               :text "21 Accédens autem Elías ad omnem pópulum ait: Usquequo claudicátis in duas partes? Si Dóminus est Deus, sequímini eum; si autem Baal, sequímini illum. Et non respóndit ei pópulus verbum.
22 Et ait rursus Elías ad pópulum: Ego remánsi prophéta Dómini solus, prophétæ autem Baal quadringénti et quinquagínta viri sunt.")
               (:ref "3 Reg 18:23-24"
               :text "23 Dentur nobis duo boves; et illi éligant sibi bovem unum, et in frusta cædéntes ponant super ligna, ignem autem non suppónant; et ego fáciam bovem álterum et impónam super ligna, ignem autem non suppónam.
24 Invocáte nómina deórum vestrórum, et ego invocábo nomen Dómini mei; et Deus, qui exaudíerit per ignem, ipse sit Deus.  Respóndens omnis pópulus ait: Optima proposítio.")
               (:ref "3 Reg 18:25-27"
               :text "25 Dixit ergo Elías prophétis Baal: Elígite vobis bovem unum et fácite primi, quia vos plures estis, et invocáte nómina deórum vestrórum, ignémque non supponátis.
26 Qui, cum tulíssent bovem quem déderat eis, fecérunt, et invocábant nomen Baal de mane usque ad merídiem, dicéntes: Baal, exáudi nos. Et non erat vox, nec qui respondéret. Transiliebántque altáre quod fécerant.
27 Cumque esset jam merídies, illudébat illis Elías, dicens: Clamáte voce majóre."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent09-1: Feria secunda infra Hebdomadam IX post Octavam Pentecostes
    ((9 . 1) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 2:5-7"
               :text "5 Accessérunt fílii prophetárum qui erant in Jéricho, ad Eliséum, et dixérunt ei: Numquid nosti quia Dóminus hódie tollet dóminum tuum a te? Et ait: Et ego novi: siléte.
6 Dixit autem ei Elías: Sede hic, quia Dóminus misit me usque ad Jordánem. Qui ait: Vivit Dóminus, et vivit ánima tua, quia non derelínquam te. Iérunt ígitur ambo páriter.
7 Et quinquagínta viri de fíliis prophetárum secúti sunt eos, qui et stetérunt e contra longe; illi autem ambo stabant super Jordánem.")
               (:ref "4 Reg 2:8-10"
               :text "8 Tulítque Elías pállium suum et invólvit illud et percússit aquas, quæ divísæ sunt in utrámque partem, et transiérunt ambo per siccum.
9 Cumque transíssent, Elías dixit ad Eliséum: Póstula quod vis ut fáciam tibi, ántequam tollar a te. Dixítque Eliséus: Obsecro ut fiat in me duplex spíritus tuus.
10 Qui respóndit: Rem diffícilem postulásti; áttamen si víderis me, quando tollar a te, erit tibi quod petísti; si autem non víderis, non erit.")
               (:ref "4 Reg 2:11-13"
               :text "11 Cumque pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque; et ascéndit Elías per túrbinem in cælum.
12 Eliséus autem vidébat et clamábat: Pater mi, pater mi, currus Israël et auríga ejus. Et non vidit eum ámplius. Apprehendítque vestiménta sua et scidit illa in duas partes.
13 Et levávit pállium Elíæ, quod cecíderat ei. Reversúsque stetit super ripam Jordánis."))
              :responsories
              ((:respond "Recordáre, Dómine, testaménti tui, et dic Angelo percutiénti: Cesset jam manus tua,"
                  :verse "Quiéscat, Dómine, ira tua a pópulo tuo, et a civitáte sancta tua:"
                  :repeat "Ut non desolétur terra, et ne perdas omnem ánimam vivam."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent09-2: Feria tertia infra Hebdomadam IX post Octavam Pentecostes
    ((9 . 2) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 3:6-9"
               :text "6 Egréssus est ígitur rex Joram in die illa de Samaría, et recénsuit univérsum Israël.
7 Misítque ad Jósaphat regem Juda, dicens: Rex Moab recéssit a me; veni mecum contra eum ad prǽlium. Qui respóndit: Ascéndam: qui meus est, tuus est; pópulus meus, pópulus tuus, et equi mei, equi tui.
8 Dixítque: Per quam viam ascendémus? At ille respóndit: Per desértum Idumǽæ.
9 Perrexérunt ígitur rex Israël, et rex Juda, et rex Edom, et circuiérunt per viam septem diérum; nec erat aqua exercítui et juméntis quæ sequebántur eos.")
               (:ref "4 Reg 3:10-13"
               :text "10 Dixítque rex Israël: Heu! Heu! Heu! congregávit nos Dóminus tres reges, ut tráderet in manus Moab.
11 Et ait Jósaphat: Estne hic prophéta Dómini, ut deprecémur Dóminum per eum? Et respóndit unus de servis regis Israël: Est hic Eliséus fílius Saphat, qui fundébat aquam super manus Elíæ.
12 Et ait Jósaphat: Est apud eum sermo Dómini. Descendítque ad eum rex Israël, et Jósaphat rex Juda, et rex Edom.
13 Dixit autem Eliséus ad regem Israël: Quid mihi et tibi est? Vade ad prophétas patris tui et matris tuæ.")
               (:ref "4 Reg 3:13-18"
               :text "13 Et ait illi rex Israël: Quare congregávit Dóminus tres reges hos, ut tráderet eos in manus Moab?
14 Dixítque ad eum Eliséus: Vivit Dóminus exercítuum, in cujus conspéctu sto, quod si non vultum Jósaphat regis Judæ erubéscerem, non attendíssem quidem te, nec respexíssem.
15 Nunc autem addúcite mihi psaltem. Cumque cáneret psaltes, facta est super eum manus Dómini, et ait:
16 Hæc dicit Dóminus: Fácite álveum torréntis hujus fossas et fossas;
17 hæc enim dicit Dóminus: Non vidébitis ventum, neque plúviam, et álveus iste replébitur aquis, et bibétis vos, et famíliæ vestræ et juménta vestra.
18 Parúmque est hoc in conspéctu Dómini; ínsuper tradet étiam Moab in manus vestras."))
              :responsories
              ((:respond "Dómine, si convérsus fúerit pópulus tuus, et oráverit ad sanctuárium tuum:"
                  :verse "Si peccáverit in te pópulus tuus, et convérsus égerit pœniténtiam, veniénsque oráverit in isto loco."
                  :repeat "Tu exáudies de cælo, Dómine, et líbera eos de mánibus inimicórum suórum."
                  :gloria nil)
               (:respond "Factum est, dum tólleret Dóminus Elíam per túrbinem in cælum, Eliséus clamábat, dicens:"
                  :verse "Cumque simul pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque, et clamábat Eliséus:"
                  :repeat "Pater mi, pater mi, currus Israël, et auríga ejus."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent09-3: Feria quarta infra Hebdomadam IX post Octavam Pentecostes
    ((9 . 3) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 4:1-4"
               :text "1 Múlier autem quædam de uxóribus prophetárum clamábat ad Eliséum, dicens: Servus tuus vir meus mórtuus est, et tu nosti quia servus tuus fuit timens Dóminum; et ecce créditor venit ut tollat duos fílios meos ad serviéndum sibi.
2 Cui dixit Eliséus: Quid vis ut fáciam tibi? Dic mihi, quid habes in domo tua? At illa respóndit: Non hábeo ancílla tua quidquam in domo mea, nisi parum ólei, quo ungar.
3 Cui ait: Vade, pete mútuo ab ómnibus vicínis tuis vasa vácua non pauca;
4 et ingrédere et claude óstium tuum, cum intrínsecus fúeris tu et fílii tui, et mitte inde in ómnia vasa hæc; et, cum plena fúerint, tolles.")
               (:ref "4 Reg 4:5-10"
               :text "5 Ivit ítaque múlier et clausit óstium super se et super fílios suos; illi offerébant vasa, et illa infundébat.
6 Cumque plena fuíssent vasa, dixit ad fílium suum: affer mihi adhuc vas. Et ille respóndit: Non hábeo. Stetítque óleum.
7 Venit autem illa et indicávit hómini Dei. Et ille, Vade, inquit, vende óleum et redde creditóri tuo; tu autem et fílii tui vívite de réliquo.
8 Facta est autem quædam dies, et transíbat Eliséus per Sunam. Erat autem ibi múlier magna, quæ ténuit eum et ut coméderet panem; cumque frequénter inde transíret, divertébat ad eam ut coméderet panem.
9 Quæ dixit ad virum suum: Animadvérto quod vir Dei sanctus est iste, qui transit per nos frequénter:
10 faciámus ergo ei cenáculum parvum, et ponámus ei in eo léctulum, et mensam, et sellam, et candelábrum, ut, cum vénerit ad nos, máneat ibi.")
               (:ref "4 Reg 4:11-17"
               :text "11 Facta est ergo dies quædam, et véniens divértit in cenáculum et requiévit ibi.
12 Dixítque ad Giézi púerum suum: Voca Sunamítidem istam. Qui, cum vocásset eam et illa stetísset coram eo,
13 dixit ad púerum suum: Lóquere ad eam: Ecce, sédule in ómnibus ministrásti nobis, quid vis ut fáciam tibi? Numquid habes negótium, et vis ut loquar regi, sive príncipi milítiæ? Quæ respóndit: In médio pópuli mei hábito.
14 Et ait: Quid ergo vult ut fáciam ei? Dixítque Giézi: Ne quæras, fílium enim non habet, et vir ejus senex est.
15 Præcépit ítaque ut vocáret eam; quæ cum vocáta fuísset, et stetísset ante óstium,
16 dixit ad eam: In témpore isto et in hac eádem hora, si vita comes fúerit, habébis in útero fílium. At illa respóndit: Noli, quæso, dómine mi, vir Dei, noli mentíri ancíllæ tuæ.
17 Et concépit múlier, et péperit fílium in témpore, et in hora eádem, qua díxerat Eliséus."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent09-4: Feria quinta infra Hebdomadam IX post Octavam Pentecostes
    ((9 . 4) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 6:24-27"
               :text "24 Congregávit Bénadad rex Sýriæ univérsum exércitum suum et ascéndit et obsidébat Samaríam.
25 Factáque est fames magna in Samaría, et támdiu obséssa est, donec venumdarétur caput ásini octogínta argénteis, et quarta pars cabi stércoris columbárum quinque argénteis.
26 Cumque rex Israël transíret per murum, múlier quædam exclamávit ad eum, dicens: Salva me, dómine mi rex.
27 Qui ait: Non te salvat Dóminus, unde te possum salváre? de área, vel de torculári?")
               (:ref "4 Reg 6:27-32"
               :text "27 Dixítque ad eam rex: Quid tibi vis? Quæ respóndit:
28 Múlier ista dixit mihi: Da fílium tuum ut comedámus eum hódie, et fílium meum comedémus cras.
29 Cóximus ergo fílium meum, et comédimus; dixíque ei die áltera: Da fílium tuum, ut comedámus eum; quæ abscóndit fílium suum.
30 Quod cum audísset rex, scidit vestiménta sua, et transíbat per murum; vidítque omnis pópulus cilícium, quo vestítus erat ad carnem intrínsecus.
31 Et ait rex: Hæc mihi fáciat Deus et hæc addat, si stéterit caput Eliséi fílii Saphat super ipsum hódie.
32 Eliséus autem sedébat in domo sua, et senes sedébant cum eo.")
               (:ref "4 Reg 6:32-33; 7:1"
               :text "32 Præmísit ítaque virum; et ántequam veníret núntius ille, dixit ad senes: Numquid scitis quod míserit fílius homicídæ hic, ut præcidátur caput meum? Vidéte ergo, cum vénerit núntius, cláudite óstium, et non sinátis eum introíre; ecce enim sónitus pedum dómini ejus post eum est.
33 Adhuc illo loquénte eis, appáruit núntius qui veniébat ad eum. Et ait: Ecce, tantum malum a Dómino est; quid ámplius exspectábo a Dómino?
1 Dixit autem Eliséus: Audíte verbum Dómini: hæc dicit Dóminus: In témpore hoc cras módius símilæ uno statére erit, et duo módii hórdei statére uno, in porta Samaríæ."))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent09-5: Feria sexta infra Hebdomadam IX post Octavam Pentecostes
    ((9 . 5) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 8:1-3"
               :text "1 Eliséus autem locútus est ad mulíerem, cujus vívere fécerat fílium, dicens: Surge, vade tu et domus tua et peregrináre ubicúmque repéreris; vocávit enim Dóminus famem, et véniet super terram septem annis.
2 Quæ surréxit, et fecit juxta verbum hóminis Dei; et vadens cum domo sua, peregrináta est in terra Philísthiim diébus multis.
3 Cumque finíti essent anni septem, revérsa est múlier de terra Philísthiim: et egréssa est ut interpelláret regem pro domo sua, et pro agris suis.")
               (:ref "4 Reg 8:4-6"
               :text "4 Rex autem loquebátur cum Giézi púero viri Dei dicens: Narra mihi ómnia magnália, quæ fecit Eliséus.
5 Cumque ille narráret regi quómodo mórtuum suscitásset, appáruit múlier, cujus vivificáverat fílium, clamans ad regem pro domo sua, et pro agris suis. Dixítque Giézi: Dómine mi rex, hæc est múlier, et hic est fílius ejus quem suscitávit Eliséus.
6 Et interrogávit rex mulíerem, quæ narrávit ei, dedítque ei rex eunúchum unum dicens: Restítue ei ómnia quæ sua sunt, et univérsos réditus agrórum, a die qua relíquit terram usque ad præsens.")
               (:ref "4 Reg 8:7-10"
               :text "7 Venit quoque Eliséus Damáscum, et Bénadad rex Sýriæ ægrotábat. Nuntiaverúntque ei dicéntes: Venit vir Dei huc.
8 Et ait rex ad Házaël: Tolle tecum múnera et vade in occúrsum viri Dei et cónsule Dóminum per eum dicens: Si evádere pótero de infirmitáte mea hac?
9 Ivit ígitur Házaël in occúrsum ejus. Cumque stetísset coram eo, ait: Fílius tuus Bénadad rex Sýriæ misit me ad te, dicens: Si sanári pótero de infirmitáte mea hac?
10 Dixítque ei Eliséus: Vade, dic ei: Sanáberis. Porro osténdit mihi Dóminus quia morte moriétur."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent09-6: Sabbato secunda infra Hebdomadam IX post Octavam Pentecostes
    ((9 . 6) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 9:1-5"
               :text "1 Eliséus autem prophétes vocávit unum de fíliis prophetárum et ait illi: Accínge lumbos tuos et tolle lentículam ólei hanc in manu tua et vade in Ramoth Gálaad.
2 Cumque véneris illuc, vidébis Jehu fílium Jósaphat fílii Namsi; et ingréssus suscitábis eum de médio fratrum suórum, et introdúces in intérius cubículum.
3 Tenénsque lentículam ólei fundes super caput ejus, et dices: Hæc dicit Dóminus: Unxi te regem super Israël. Aperiésque óstium, et fúgies, et non ibi subsístes.
4 Abiit ergo adoléscens puer prophétæ in Ramoth Gálaad
5 et ingréssus est illuc: ecce autem príncipes exércitus sedébant, et ait: Verbum mihi ad te, o princeps. Dixítque Jehu: Ad quem ex ómnibus nobis? At ille dixit: Ad te, o princeps.")
               (:ref "4 Reg 9:6-10"
               :text "6 Et surréxit et ingréssus est cubículum; at ille fudit óleum super caput ejus et ait: Hæc dicit Dóminus Deus Israël: Unxi te regem super pópulum Dómini Israël,
7 et percúties domum Achab dómini tui, et ulcíscar sánguinem servórum meórum prophetárum, et sánguinem ómnium servórum Dómini de manu Jézabel.
8 Perdámque omnem domum Achab: et interfíciam de Achab mingéntem ad paríetem, et clausum et novíssimum in Israël.
9 Et dabo domum Achab sicut domum Jeróboam fílii Nabat, et sicut domum Báasa fílii Ahía.
10 Jézabel quoque cómedent canes in agro Jézrahel, nec erit qui sepéliat eam. Aperuítque óstium, et fugit.")
               (:ref "4 Reg 9:11-13"
               :text "11 Jehu autem egréssus est ad servos dómini sui, qui dixérunt ei: Recte ne sunt ómnia? quid venit insánus iste ad te? Qui ait eis: Nostis hóminem, et quid locútus sit.
12 At illi respondérunt: Falsum est, sed magis narra nobis. Qui ait eis: Hæc et hæc locútus est mihi, et ait: Hæc dicit Dóminus: Unxi te regem super Israël.
13 Festinavérunt ítaque, et unusquísque tollens pállium suum posuérunt sub pédibus ejus in similitúdinem tribunális, et cecinérunt tuba, atque dixérunt: Regnávit Jehu."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent10-1: Feria secunda infra Hebdomadam X post Octavam Pentecostes
    ((10 . 1) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 11:1-3"
               :text "1 Athalía vero mater Ochozíæ videns mórtuum fílium suum surréxit et interfécit omne semen régium.
2 Tollens autem Jósaba fília regis Joram, soror Ochozíæ, Joas fílium Ochozíæ, furáta est eum de médio filiórum regis qui interficiebántur, et nutrícem ejus de triclínio: et abscóndit eum a fácie Athalíæ, ut non interficerétur.
3 Erátque cum ea sex annis clam in domo Dómini; porro Athalía regnávit super terram.")
               (:ref "4 Reg 11:4-7"
               :text "4 Anno autem séptimo misit Jójada, et assúmens centuriónes et mílites, introdúxit ad se in templum Dómini, pepigítque cum eis fœdus; et adjúrans eos in domo Dómini, osténdit eis fílium regis:
5 et præcépit illis, dicens: Iste est sermo quem fácere debétis:
6 tértia pars vestrum intróëat sábbato, et obsérvet excúbias domus regis; tértia autem pars sit ad portam Sur, et tértia pars sit ad portam quæ est post habitáculum scutariórum, et custodiétis excúbias domus Messa.
7 Duæ vero partes e vobis, omnes egrediéntes sábbato, custódiant excúbias domus Dómini circa regem.")
               (:ref "4 Reg 11:9-12"
               :text "9 Et assuméntes sínguli viros suos, qui ingrediebántur sábbatum, cum his qui egrediebántur sábbato, venérunt ad Jójadam sacerdótem,
10 qui dedit eis hastas et arma regis David, quæ erant in domo Dómini.
11 Et stetérunt sínguli habéntes arma in manu sua, a parte templi déxtera usque ad partem sinístram altáris et ædis, circum regem.
12 Produxítque fílium regis, et pósuit super eum diadéma et testimónium: fecerúntque eum regem, et unxérunt: et plaudéntes manu, dixérunt: Vivat rex."))
              :responsories
              ((:respond "Recordáre, Dómine, testaménti tui, et dic Angelo percutiénti: Cesset jam manus tua,"
                  :verse "Quiéscat, Dómine, ira tua a pópulo tuo, et a civitáte sancta tua:"
                  :repeat "Ut non desolétur terra, et ne perdas omnem ánimam vivam."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent10-2: Feria tertia infra Hebdomadam X post Octavam Pentecostes
    ((10 . 2) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 12:1-3"
               :text "1 Anno séptimo Jehu, regnávit Joas: et quadragínta annis regnávit in Jerúsalem. Nomen matris ejus Sébia de Bersabée.
2 Fecítque Joas rectum coram Dómino cunctis diébus quibus dócuit eum Jójada sacérdos;
3 verúmtamen excélsa non ábstulit; adhuc enim pópulus immolábat, et adolébat in excélsis incénsum.")
               (:ref "4 Reg 12:4-5"
               :text "4 Dixítque Joas ad sacerdótes: Omnem pecúniam sanctórum, quæ illáta fúerit in templum Dómini a prætereúntibus, quæ offértur pro prétio ánimæ, et quam sponte et arbítrio cordis sui ínferunt in templum Dómini,
5 accípiant illam sacerdótes juxta órdinem suum, et instáurent sartatécta domus, si quid necessárium víderint instauratióne.")
               (:ref "4 Reg 12:6-8"
               :text "6 Igitur usque ad vigésimum tértium annum regis Joas, non instauravérunt sacerdótes sartatécta templi.
7 Vocavítque rex Joas Jójadam pontíficem et sacerdótes, dicens eis: Quare sartatécta non instaurátis templi? Nolíte ergo ámplius accípere pecúniam juxta órdinem vestrum; sed ad instauratiónem templi réddite eam.
8 Prohibitíque sunt sacerdótes ultra accípere pecúniam a pópulo, et instauráre sartatécta domus."))
              :responsories
              ((:respond "Dómine, si convérsus fúerit pópulus tuus, et oráverit ad sanctuárium tuum:"
                  :verse "Si peccáverit in te pópulus tuus, et convérsus égerit pœniténtiam, veniénsque oráverit in isto loco."
                  :repeat "Tu exáudies de cælo, Dómine, et líbera eos de mánibus inimicórum suórum."
                  :gloria nil)
               (:respond "Factum est, dum tólleret Dóminus Elíam per túrbinem in cælum, Eliséus clamábat, dicens:"
                  :verse "Cumque simul pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque, et clamábat Eliséus:"
                  :repeat "Pater mi, pater mi, currus Israël, et auríga ejus."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent10-3: Feria quarta infra Hebdomadam X post Octavam Pentecostes
    ((10 . 3) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 13:14-17"
               :text "14 Eliséus autem ægrotábat infirmitáte, qua et mórtuus est; descendítque ad eum Joas rex Israël, et flebat coram eo, dicebátque: Pater mi, pater mi, currus Israël et auríga ejus.
15 Et ait illi Eliséus: Affer arcum et sagíttas. Cumque attulísset ad eum arcum et sagíttas,
16 dixit ad regem Israël: Pone manum tuam super arcum. Et, cum posuísset ille manum suam, superpósuit Eliséus manus suas mánibus regis,
17 et ait: Aperi fenéstram orientálem. Cumque aperuísset, dixit Eliséus: Jace sagíttam. Et jecit. Et ait Eliséus: Sagítta salútis Dómini, et sagítta salútis contra Sýriam; percutiésque Sýriam in Aphec, donec consúmas eam.")
               (:ref "4 Reg 13:18-20"
               :text "18 Et ait: Tolle sagíttas. Qui cum tulísset, rursum dixit ei: Pércute jáculo terram. Et, cum percussísset tribus vícibus, et stetísset,
19 irátus est vir Dei contra eum, et ait: Si percussísses quínquies aut séxies sive sépties, percussísses Sýriam usque ad consumptiónem; nunc autem tribus vícibus percúties eam.
20 Mórtuus est ergo Eliséus, et sepeliérunt eum. Latrúnculi autem de Moab venérunt in terram in ipso anno.")
               (:ref "4 Reg 13:21; 13:24-25"
               :text "21 Quidam autem sepeliéntes hóminem, vidérunt latrúnculos, et projecérunt cadáver in sepúlcro Eliséi. Quod cum tetigísset ossa Eliséi, revíxit homo et stetit super pedes suos.
24 Mórtuus est autem Házaël rex Sýriæ, et regnávit Bénadad fílius ejus pro eo.
25 Porro Joas fílius Jóachaz tulit urbes de manu Bénadad fílii Házaël, quas túlerat de manu Jóachaz patris sui jure prǽlii; tribus vícibus percússit eum Joas, et réddidit civitátes Israël."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent10-4: Feria quinta infra Hebdomadam X post Octavam Pentecostes
    ((10 . 4) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 17:6-9"
               :text "6 Anno autem nono Osée, cepit rex Assyriórum Samaríam et tránstulit Israël in Assyrios: posuítque eos in Hala et in Habor juxta fluvium Gozan, in civitátibus Medórum.
7 Factum est enim, cum peccássent fílii Israël Dómino Deo suo, qui edúxerat eos de terra Ægýpti, de manu pharaónis regis Ægýpti, coluérunt deos alienos.
8 Et ambulavérunt juxta ritum Géntium, quas consúmpserat Dóminus in conspéctu filiórum Israël et regum Israël, quia simíliter fécerant.
9 Et offendérunt fílii Israël verbis non rectis Dóminum Deum suum: et ædificavérunt sibi excélsa in cunctis úrbibus suis.")
               (:ref "4 Reg 17:13-15"
               :text "13 Et testificátus est Dóminus in Israël et in Juda per manum ómnium prophetárum et vidéntium, dicens: Revertímini a viis vestris pessimis, et custodíte præcépta mea et cæremónias, juxta omnem legem, quam præcépi pátribus vestris, et sicut misi ad vos in manu servórum meórum prophetárum.
14 Qui non audiérunt, sed induravérunt cervícem suam juxta cervícem patrum suórum, qui noluérunt obedíre Dómino Deo suo;
15 et abjecérunt legítima ejus, et pactum quod pépigit cum pátribus eórum, et testificatiónes, quibus contestátus est eos, secutíque sunt vanitátes, et vane egérunt.")
               (:ref "4 Reg 17:18-21"
               :text "18 Iratúsque est Dóminus veheménter Israéli, et ábstulit eos a conspéctu suo; et non remánsit nisi tribus Juda tantúmmodo.
19 Sed nec ipse Juda custodívit mandáta Dómini Dei sui: verum ambulávit in erróribus Israël, quos operátus fuerat.
20 Projecítque Dóminus omne semen Israël, et afflíxit eos, et trádidit eos in manu diripiéntium, donec proíceret eos a fácie sua:
21 ex eo jam témpore, quo scissus est Israël a domo David, et constituérunt sibi regem Jeróboam fílium Nabat."))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent10-5: Feria sexta infra Hebdomadam X post Octavam Pentecostes
    ((10 . 5) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 17:21-23"
               :text "21 Separávit Jeróboam Israël a Dómino, et peccáre eos fecit peccátum magnum.
22 Et ambulavérunt fílii Israël in univérsis peccátis Jeróboam quæ fécerat, et non recessérunt ab eis,
23 úsquequo Dóminus auférret Israël a fácie sua, sicut locútus fúerat in manu ómnium servórum suórum prophetárum; translatúsque est Israël de terra sua in Assýrios, usque in diem hanc.")
               (:ref "4 Reg 17:24-25"
               :text "24 Addúxit autem rex Assyriórum de Babylóne et de Cutha et de Avah et de Emath et de Sephárvaim, et collocávit eos in civitátibus Samaríæ pro fíliis Israël: qui possedérunt Samaríam, et habitavérunt in úrbibus ejus.
25 Cumque ibi habitáre cœpíssent, non timébant Dóminum, et immísit in eos Dóminus leónes, qui interficiébant eos.")
               (:ref "4 Reg 17:26-27"
               :text "26 Nuntiatúmque est regi Assyriórum et dictum: gentes, quas transtulísti, et habitáre fecísti in civitátibus Samaríæ, ignórant legítima Dei terræ: et immísit in eos Dóminus leónes, et ecce interfíciunt eos, eo quod ignórent ritum Dei terræ.
27 Præcépit autem rex Assyriórum, dicens: Dúcite illuc unum de sacerdótibus, quos inde captívos adduxístis; et vadat, et hábitet cum eis: et dóceat eos legítima Dei terræ."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent10-6: Sabbato infra Hebdomadam X post Octavam Pentecostes
    ((10 . 6) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 18:1-5"
               :text "1 Anno tértio Osée fílii Ela regis Israël, regnávit Ezechías fílius Achaz regis Juda.
2 Vigínti quinque annórum erat cum regnáre cœpísset, et vigínti novem annis regnávit in Jerúsalem: Nomen matris ejus Abi fília Zacharíæ.
3 Fecítque quod erat bonum coram Dómino, juxta ómnia quæ fécerat David pater ejus.
4 Ipse dissipávit excélsa, et contrívit státuas, et succídit lucos, confregítque serpéntem ǽneum, quem fécerat Móyses: síquidem usque ad illud tempus fílii Israël adolébant ei incénsum: vocavítque nomen ejus Nohéstan.
5 In Dómino Deo Israël sperávit.")
               (:ref "4 Reg 18:5-8"
               :text "5 Itaque post eum non fuit símilis ei de cunctis régibus Juda, sed neque in his qui ante eum fuérunt.
6 Et adhǽsit Dómino, et non recéssit a vestígiis ejus, fecítque mandáta ejus, quæ præcéperat Dóminus Móysi.
7 Unde et erat Dóminus cum eo, et in cunctis ad quæ procedébat, sapiénter se agébat.  Rebellávit quoque contra regem Assyriórum, et non servívit ei.
8 Ipse percússit Philisthǽos usque ad Gazam, et omnes términos eórum, a turre custódum usque ad civitátem munítam.")
               (:ref "4 Reg 18:9-12"
               :text "9 Anno quarto regis Ezechíæ, qui erat annus séptimus Osée fílii Ela regis Israël, ascéndit Salmánasar rex Assyriórum in Samaríam, et oppugnávit eam,
10 et cepit, nam post annos tres, anno sexto Ezechíæ, id est nono anno Osée regis Israël, capta est Samaría.
11 Et tránstulit rex Assyriórum Israël in Assýrios, collocavítque eos in Hala et in Habor flúviis Gozan, in civitátibus Medórum,
12 quia non audiérunt vocem Dómini Dei sui, sed prætergréssi sunt pactum ejus; ómnia, quæ præcéperat Móyses servus Dómini, non audiérunt, neque fecérunt."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent11-1: Feria secunda infra Hebdomadam XI post Octavam Pentecostes
    ((11 . 1) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 22:1-5"
               :text "1 Octo annórum erat Josías cum regnáre cœpísset : trigínta et uno anno regnávit in Jerúsalem.  Nomen matris ejus Idida fília Hadaía de Bésecath.
2 Fecítque quod plácitum erat coram Dómino et ambulávit per omnes vias David patris sui: non declinávit ad déxteram, sive ad sinistram.
3 Anno autem octavo décimo regis Josíæ misit rex Saphan fílium Aslía fílii Méssulam scribam templi Dómini, dicens ei:
4 Vade ad Helcíam sacerdotem magnum, ut conflétur pecúnia, quæ illáta est in templum Dómini, quam collegérunt janitores templi a pópulo,
5 detúrque febris per præpósitos domus Dómini; qui et distríbuant eam his qui operántur in templo Domini.")
               (:ref "4 Reg 22:8-10"
               :text "8 Dixit autem Helcías pontifex ad Saphan scribam: Librum legis réperi in domo Dómini.  Dedítque Helcías volúmen Saphan, qui et legit illud.
9 Venit quoque Saphan scriba ad regem, et renuntiávit ei quod præceperat, et ait: Conflavérunt servi tui pecúniam, quæ repérta est in domo Dómini, et dedérunt ut distribuerétur fabris a præfectis óperum templi Dómini.
10 Narrávit quoque Saphan scriba regi, dicens: Librum dedit mihi Helcías sacérdos.")
               (:ref "4 Reg 22:10-13"
               :text "10 Quem cum legísset Saphan coram rege,
11 et audísset rex verba libri legis Dómini, scidit vestiménta sua.
12 Et præcépit Helcíæ sacerdóti, et Ahícam fílio Saphan, et Achobor fílio Micha, et Saphan scribæ, et Asaíæ servo regis, dicens:
13 Ite et consúlite Dóminum super me, et super pópulo, et super omni Juda, de verbis volúminis istius, quod invéntum est; magna enim ira Dómini succénsa est contra nos, quia non audiérunt patres nostri verba libri hujus, ut fácerent omne quod scriptum est nobis."))
              :responsories
              ((:respond "Recordáre, Dómine, testaménti tui, et dic Angelo percutiénti: Cesset jam manus tua,"
                  :verse "Quiéscat, Dómine, ira tua a pópulo tuo, et a civitáte sancta tua:"
                  :repeat "Ut non desolétur terra, et ne perdas omnem ánimam vivam."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent11-2: Feria tertia infra Hebdomadam XI post Octavam Pentecostes
    ((11 . 2) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 23:2-3"
               :text "2 Ascéndit rex templum Dómini, et omnes viri Juda, universíque qui habitábant in Jerúsalem cum eo, sacerdótes et prophétæ, et omnis pópulus a parvo usque ad magnum: legítque, cunctis audiéntibus, omnia verba libri fœ́deris, qui invéntus est in domo Domini.
3 Stetítque rex super gradum: et fœ́dus percússit coram Dómino, ut ambulárent post Dóminum, et custodírent præcépta ejus, et testimónia, et cæremónias in omni corde, et in tota ánima, et suscitárent verba fœ́deris hujus, quæ scripta erant in libro illo: Acquievítque pópulus pacto.")
               (:ref "4 Reg 23:4-5"
               :text "4 Et præcépit rex Helcíæ pontífici, et sacerdótibus secúndi órdinis, et janitóribus, ut proícerent de templo Dómini omnia vasa, quæ facta fúerant Baal, et in luco, et univérsæ milítiæ cæli: et combússit ea foris Jerúsalem in conválle Cedron, et tulit púlverem eorum in Bethel.
5 Et delévit arúspices quos posúerant reges Juda ad sacrificándum in excélsis per civitátes Juda, et in circúitu Jerúsalem: et eos qui adolébant incénsum Baal, et soli, et lunæ, et duódecim signis, et omni milítiæ cæli.")
               (:ref "4 Reg 23:6-8"
               :text "6 Et efférri fecit lucum de domo Dómini foras Jerúsalem in conválle Cedron, et combússit eum ibi, et redégit in púlverem, et projécit super sepúlcra vulgi.
7 Destrúxit quoque ædículas effeminatórum quæ erant in domo Dómini, pro quibus mulíeres texébant quasi domúnculas luci.
8 Congregavítque omnes sacerdótes de civitátibus Juda, et contaminávit excélsa ubi sacrificábant sacerdótes, de Gábaa usque Bersabée."))
              :responsories
              ((:respond "Dómine, si convérsus fúerit pópulus tuus, et oráverit ad sanctuárium tuum:"
                  :verse "Si peccáverit in te pópulus tuus, et convérsus égerit pœniténtiam, veniénsque oráverit in isto loco."
                  :repeat "Tu exáudies de cælo, Dómine, et líbera eos de mánibus inimicórum suórum."
                  :gloria nil)
               (:respond "Factum est, dum tólleret Dóminus Elíam per túrbinem in cælum, Eliséus clamábat, dicens:"
                  :verse "Cumque simul pérgerent, et incedéntes sermocinaréntur, ecce currus ígneus, et equi ígnei divisérunt utrúmque, et clamábat Eliséus:"
                  :repeat "Pater mi, pater mi, currus Israël, et auríga ejus."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent11-3: Feria quarta infra Hebdomadam XI post Octavam Pentecostes
    ((11 . 3) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 23:24-26"
               :text "24 Pythónes, et haríolos, et figúras idolórum, et immundítias, et abominatiónes, quæ fúerant in terra Juda et Jerúsalem, ábstulit Josías, ut statúeret verba legis, quæ scripta sunt in libro, quem invenit Helcías sacérdos in templo Dómini.
25 Símilis illi non fuit ante eum rex, qui reverterétur ad Dóminum in omni corde suo, et in tota ánima sua, et in univérsa virtúte sua juxta omnem legem Móysi: neque post eum surréxit símilis illi.
26 Verúmtamen non est avérsus Dóminus ab ira furóris sui magni, quo irátus est furor ejus contra Judam propter irritatiónes, quibus provocáverat eum Manásses.")
               (:ref "4 Reg 23:27-30"
               :text "27 Dixit ítaque Dóminus: Etiam Judam áuferam a fácie mea, sicut ábstuli Israël, et proíciam civitátem hanc, quam elégi, Jerúsalem, et domum de qua dixi: Erit nomen meum ibi.
28 Réliqua autem sermónum Josíæ, et univérsa quæ fecit, nonne hæc scripta sunt in libro verbórum diérum regum Juda?
29 In diébus ejus ascéndit phárao Néchao rex Ægýpti contra regem Assyriórum ad flumen Euphráten, et abiit Josías rex in occúrsum ejus: et occísus est in Magéddo, cum vidísset eum.
30 Et portavérunt eum servi sui mórtuum de Magéddo: et pertulérunt in Jerúsalem, et sepeliérunt eum in sepúlcro suo.")
               (:ref "4 Reg 23:30-34"
               :text "30 Tulítque pópulus terræ Jóachaz fílium Josiæ: et unxérunt eum, et constituérunt eum regem pro patre suo.
31 Vigínti trium annórum erat Joachaz cum regnäre cœpísset, et tribus ménsibus regnávit in Jerúsalem. Nomen matris ejus Amítal fília Jeremíæ de Lobna.
32 Et fecit malum coram Dómino, juxta omnia quæ fécerant patres ejus.
33 Vinxítque eum phárao Néchao in Rebla, quæ est in terra Emath, ne regnäret in Jerúsalem; et impósuit mulctam terræ centum taléntis argénti, et talénto auri.
34 Regémque constítuit phárao Néchao Elíacim fílium Josíæ pro Josía patre ejus: vertítque nomen ejus Jóakim. Porro Jóachaz tulit, et duxit in Ægýptum, et mórtuus est ibi."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent11-4: Feria quinta infra Hebdomadam XI post Octavam Pentecostes
    ((11 . 4) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 23:36-37; 24:1"
               :text "36 Vigínti quinque annórum erat Jóakim cum regnáre cœpísset, et úndecim annis regnávit in Jerúsalem. Nomen matris ejus Zébida filia Phadaía de Ruma.
37 Et fecit malum coram Dómino juxta omnia quæ fécerant patres ejus.
1 In diébus ejus ascéndit Nabuchodónosor rex Babylónis, et factus est ei Jóakim servus tribus annis: et rursum rebellávit contra eum.")
               (:ref "4 Reg 24:2-4"
               :text "2 Immisítque ei Dóminus latrúnculos Chaldæórum, et latrúnculos Sýriæ, et latrúnculos Moab, et latrúnculos filiórum Ammon: et immísit eos in Judam ut dispérderent eum, juxta verbum Dómini quod locútus fúerat per servos suos prophétas.
3 Factum est autem hoc per verbum Dómini contra Judam, ut auférret eum coram se propter peccáta Manásse univérsa quæ fecit,
4 et propter sánguinem innóxium quem effúdit, et implévit Jerúsalem cruóre innocéntium: et ob hanc rem nóluit Dóminus propitiári.")
               (:ref "4 Reg 24:5-7"
               :text "5 Réliqua autem sermónum Jóakim, et univérsa quæ fecit, nonne hæc scripta sunt in libro sermónum diérum regum Juda? Et dormívit Joakim cum pátribus suis:
6 Et regnávit Jóachin fílius ejus pro eo.
7 Et ultra non áddidit rex Ægýpti ut egrederétur de terra sua; túlerat enim rex Babylónis, a rivo Ægýpti usque ad flúvium Euphráten, ómnia quæ fúerant regis Ægýpti."))
              :responsories
              ((:respond "Præparáte corda vestra Dómino, et servíte illi soli:"
                  :verse "Auférte deos aliénos de médio vestri."
                  :repeat "Et liberábit vos de mánibus inimicórum vestrórum."
                  :gloria nil)
               (:respond "Deus ómnium exaudítor est: ipse misit Angelum suum, et tulit me de óvibus patris mei:"
                  :verse "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me."
                  :repeat "Et unxit me unctióne misericórdiæ suæ."
                  :gloria nil)
               (:respond "Dóminus, qui erípuit me de ore leónis, et de manu béstiæ liberávit me,"
                  :verse "Misit Deus misericórdiam suam et veritátem suam: ánimam meam erípuit de médio catulórum leónum."
                  :repeat "Ipse me erípiet de mánibus inimicórum meórum."
                  :gloria t))))

    ;; Pent11-5: Feria sexta infra Hebdomadam XI post Octavam Pentecostes
    ((11 . 5) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 24:8-11"
               :text "8 Decem et octo annórum erat Jóachin cum regnáre cœpísset, et tribus ménsibus regnávit in Jerúsalem. Nomen matris ejus Nohésta fília Elnathan de Jerúsalem.
9 Et fecit malum coram Dómino, juxta omnia quæ fécerat pater ejus.
10 In témpore illo ascendérunt servi Nabuchodónosor regis Babylónis in Jerúsalem, et circúmdata est urbs munitiónibus,
11 venítque Nabuchodónosor rex Babylónis ad civitátem cum servis suis ut oppugnárent eam.")
               (:ref "4 Reg 24:12-14"
               :text "12 Egressúsque est Jóachin rex Juda ad regem Babylónis, ipse et mater ejus, et servi ejus, et príncipes ejus, et eunúchi ejus: et suscépit eum rex Babylónis anno octávo regni sui.
13 Et prótulit inde omnes thesáuros domus Dómini, et thesáuros domus regiæ: et cóncidit univérsa vasa aurea quæ fécerat Salomon rex Israël in templo Dómini juxta verbum Dómini,
14 et tránstulit omnem Jerúsalem, et univérsos príncipes, et omnes fortes exércitus, decem míllia, in captivitátem, et omnem artíficem et clusórem: nihílque relíctum est, excéptis paupéribus pópuli terræ.")
               (:ref "4 Reg 24:15-17"
               :text "15 Tránstulit quoque Jóachin in Babylónem, et matrem regis, et uxóres regis, et eunúchos ejus: et júdices terræ duxit in captivitátem de Jerúsalem in Babylónem;
16 et omnes viros robústos, septem míllia, et artífices, et clusóres mille, omnes viros fortes et bellatóres: duxítque eos rex Babylónis captívos in Babylónem;
17 et constítuit Matthaníam pátruum ejus pro eo: imposuítque nomen ei Sedecíam."))
              :responsories
              ((:respond "Percússit Saul mille, et David decem míllia:"
                  :verse "Nonne iste est David, de quo canébant in choro, dicéntes: Saul percússit mille, et David decem míllia?"
                  :repeat "Quia manus Dómini erat cum illo: percússit Philisthǽum, et ábstulit oppróbrium ex Israël."
                  :gloria nil)
               (:respond "Montes Gélboë, nec ros nec plúvia véniant super vos,"
                  :verse "Omnes montes, qui estis in circúitu ejus, vísitet Dóminus: a Gélboë autem tránseat."
                  :repeat "Ubi cecidérunt fortes Israël."
                  :gloria nil)
               (:respond "Ego te tuli de domo patris tui, dicit Dóminus, et pósui te páscere gregem pópuli mei:"
                  :verse "Fecíque tibi nomen grande, juxta nomen magnórum, qui sunt in terra: et réquiem dedi tibi ab ómnibus inimícis tuis."
                  :repeat "Et fui tecum in ómnibus ubicúmque ambulásti, firmans regnum tuum in ætérnum."
                  :gloria t))))

    ;; Pent11-6: Sabbato infra Hebdomadam XI post Octavam Pentecostes
    ((11 . 6) . (:lessons
              ((:source "De libro quarto Regum"
               :ref "4 Reg 24:18-20; 25:1-3"
               :text "18 Vigésimum et primum annum ætátis habébat Sedecías cum regnáre cœpísset, et úndecim annis regnávit in Jerúsalem. Nomen matris ejus erat Amítal fília Jeremíæ de Lobna.
19 Et fecit malum coram Dómino, juxta ómnia quæ fecerat Jóakim;
20 irascebátur enim Dóminus contra Jerúsalem et contra Judam, donec proíceret eos a fácie sua: recessítque Sedecías a rege Babylónis.
1 Factum est autem anno nono regni ejus, mense décimo, décima die mensis, venit Nabuchodónosor rex Babylónis, ipse et omnis exércitus ejus, in Jerúsalem, et circumdedérunt eam: et exstruxérunt in circúitu ejus munitiónes;
2 et clausa est cívitas atque valláta usque ad undécimum annum regis Sedecíæ,
3 nona die mensis: prævaluítque fames in civitáte, nec erat panis pópulo terræ.")
               (:ref "4 Reg 25:4-7"
               :text "4 Et interrúpta est cívitas: et omnes viri bellatóres nocte fugérunt per viam portæ quæ est inter dúplicem murum ad hortum regis. Porro Chaldǽi obsidébant in circúitu civitátem. Fugit ítaque Sedecías per viam quæ ducit ad campéstria solitúdinis.
5 Et persecútus est exércitus Chaldæórum regem, comprehendítque eum in planítie Jéricho: et omnes bellatóres qui erant cum eo, dispérsi sunt, et reliquérunt eum.
6 Apprehénsum ergo regem duxérunt ad regem Babylónis in Réblatha: qui locútus est cum eo judícium.
7 Fílios autem Sedecíæ occídit coram eo, et óculos ejus effódit, vinxítque eum caténis, et addúxit in Babylónem.")
               (:ref "4 Reg 25:8-13"
               :text "8 Mense quinto, séptima die mensis, ipse est annus nonus décimus regis Babylónis, venit Nabuzárdan princeps exércitus, servus regis Babylónis, in Jerúsalem.
9 Et succendit domum Domini, et domum regis: et domos Jerúsalem, omnémque domum combússit igni.
10 Et muros Jerúsalem in circúitu destrúxit omnis exércitus Chaldæórum, qui erat cum príncipe mílitum.
11 Réliquam autem pópuli partem quæ remánserat in civitáte, et pérfugas qui transfúgerant ad regem Babylónis, et réliquum vulgus tránstulit Nabuzárdan princeps milítiæ;
12 et de paupéribus terræ relíquit vinitóres et agrícolas.
13 Colúmnas autem ǽreas quæ erant in templo Dómini, et bases, et mare ǽreum quod erat in domo Dómini, confregérunt Chaldǽi, et transtulérunt æs omne in Babylónem."))
              :responsories
              ((:respond "Peccávi super númerum arénæ maris, et multiplicáta sunt peccáta mea: et non sum dignus vidére altitúdinem cæli præ multitúdine iniquitátis meæ: quóniam irritávi iram tuam,"
                  :verse "Quóniam iniquitátem meam ego cognósco: et delíctum meum contra me est semper, quia tibi soli peccávi."
                  :repeat "Et malum coram te feci."
                  :gloria nil)
               (:respond "Exaudísti, Dómine, oratiónem servi tui, ut ædificárem templum nómini tuo:"
                  :verse "Dómine, qui custódis pactum cum servis tuis, qui ámbulant coram te in toto corde suo."
                  :repeat "Bénedic et sanctífica domum istam in sempitérnum, Deus Israël."
                  :gloria nil)
               (:respond "Audi, Dómine, hymnum et oratiónem, quam servus tuus orat coram te hódie, ut sint óculi tui apérti, et aures tuæ inténtæ,"
                  :verse "Réspice, Dómine, de sanctuário tuo, et de excélso cælórum habitáculo."
                  :repeat "Super domum istam die ac nocte."
                  :gloria t))))

    ;; Pent12-1: Feria secunda infra Hebdomadam XII post Octavam Pentecostes

    ;; Pent12-2: Feria Tertia infra Hebdomadam XII post Octavam Pentecostes

    ;; Pent12-3: Feria Quarta infra Hebdomadam XII post Octavam Pentecostes

    ;; Pent12-4: Feria Quinta infra Hebdomadam XII post Octavam Pentecostes

    ;; Pent12-5: Feria Sexta infra Hebdomadam XII post Octavam Pentecostes

    ;; Pent12-6: Sabbato infra Hebdomadam XII post Octavam Pentecostes

    ;; Pent13-1: Feria Secunda infra Hebdomadam XIII post Octavam Pentecostes

    ;; Pent13-2: Feria Tertia infra Hebdomadam XIII post Octavam Pentecostes

    ;; Pent13-3: Feria Quarta infra Hebdomadam XIII post Octavam Pentecostes

    ;; Pent13-4: Feria Quinta infra Hebdomadam XIII post Octavam Pentecostes

    ;; Pent13-5: Feria Sexta infra Hebdomadam XIII post Octavam Pentecostes

    ;; Pent13-6: Sabbato infra Hebdomadam XIII post Octavam Pentecostes

    ;; Pent14-1: Feria Secunda infra Hebdomadam XIV post Octavam Pentecostes

    ;; Pent14-2: Feria Tertia infra Hebdomadam XIV post Octavam Pentecostes

    ;; Pent14-3: Feria Quarta infra Hebdomadam XIV post Octavam Pentecostes

    ;; Pent14-4: Feria Quinta infra Hebdomadam XIV post Octavam Pentecostes

    ;; Pent14-5: Feria Sexta infra Hebdomadam XIV post Octavam Pentecostes

    ;; Pent14-6: Sabbato infra Hebdomadam XIV post Octavam Pentecostes

    ;; Pent15-1: Feria Secunda infra Hebdomadam XV post Octavam Pentecostes

    ;; Pent15-2: Feria Tertia infra Hebdomadam XV post Octavam Pentecostes

    ;; Pent15-3: Feria Quarta infra Hebdomadam XV post Octavam Pentecostes

    ;; Pent15-4: Feria Quinta infra Hebdomadam XV post Octavam Pentecostes

    ;; Pent15-5: Feria Sexta infra Hebdomadam XV post Octavam Pentecostes

    ;; Pent15-6: Sabbato infra Hebdomadam XV post Octavam Pentecostes

    ;; Pent16-1: Feria Secunda infra Hebdomadam XVI post Octavam Pentecostes

    ;; Pent16-2: Feria Tertia infra Hebdomadam XVI post Octavam Pentecostes

    ;; Pent16-3: Feria Quarta infra Hebdomadam XVI post Octavam Pentecostes

    ;; Pent16-4: Feria Quinta infra Hebdomadam XVI post Octavam Pentecostes

    ;; Pent16-5: Feria Sexta infra Hebdomadam XVI post Octavam Pentecostes

    ;; Pent16-6: Sabbato infra Hebdomadam XVI post Octavam Pentecostes

    ;; Pent17-1: Feria Secunda infra Hebdomadam XVII post Octavam Pentecostes

    ;; Pent17-2: Feria Tertia infra Hebdomadam XVII post Octavam Pentecostes

    ;; Pent17-3: Feria Quarta infra Hebdomadam XVII post Octavam Pentecostes

    ;; Pent17-4: Feria Quinta infra Hebdomadam XVII post Octavam Pentecostes

    ;; Pent17-5: Feria Sexta infra Hebdomadam XVII post Octavam Pentecostes

    ;; Pent17-6: Sabbato infra Hebdomadam XVII post Octavam Pentecostes

    ;; Pent18-1: Feria Secunda infra Hebdomadam XVIII post Octavam Pentecostes

    ;; Pent18-2: Feria Tertia infra Hebdomadam XVIII post Octavam Pentecostes

    ;; Pent18-3: Feria Quarta infra Hebdomadam XVIII post Octavam Pentecostes

    ;; Pent18-4: Feria Quinta infra Hebdomadam XVIII post Octavam Pentecostes

    ;; Pent18-5: Feria Sexta infra Hebdomadam XVIII post Octavam Pentecostes

    ;; Pent18-6: Sabbato infra Hebdomadam XVIII post Octavam Pentecostes

    ;; Pent19-1: Feria Secunda infra Hebdomadam XIX post Octavam Pentecostes

    ;; Pent19-2: Feria Tertia infra Hebdomadam XIX post Octavam Pentecostes

    ;; Pent19-3: Feria Quarta infra Hebdomadam XIX post Octavam Pentecostes

    ;; Pent19-4: Feria Quinta infra Hebdomadam XIX post Octavam Pentecostes

    ;; Pent19-5: Feria Sexta infra Hebdomadam XIX post Octavam Pentecostes

    ;; Pent19-6: Sabbato infra Hebdomadam XIX post Octavam Pentecostes

    ;; Pent20-1: Feria Secunda infra Hebdomadam XX post Octavam Pentecostes

    ;; Pent20-2: Feria Tertia infra Hebdomadam XX post Octavam Pentecostes

    ;; Pent20-3: Feria Quarta infra Hebdomadam XX post Octavam Pentecostes

    ;; Pent20-4: Feria Quinta infra Hebdomadam XX post Octavam Pentecostes

    ;; Pent20-5: Feria Sexta infra Hebdomadam XX post Octavam Pentecostes

    ;; Pent20-6: Sabbato infra Hebdomadam XX post Octavam Pentecostes

    ;; Pent21-1: Feria Secunda infra Hebdomadam XXI post Octavam Pentecostes

    ;; Pent21-2: Feria Tertia infra Hebdomadam XXI post Octavam Pentecostes

    ;; Pent21-3: Feria Quarta infra Hebdomadam XXI post Octavam Pentecostes

    ;; Pent21-4: Feria Quinta infra Hebdomadam XXI post Octavam Pentecostes

    ;; Pent21-5: Feria Sexta infra Hebdomadam XXI post Octavam Pentecostes

    ;; Pent21-6: Sabbato infra Hebdomadam XXI post Octavam Pentecostes

    ;; Pent22-1: Feria Secunda infra Hebdomadam XXII post Octavam Pentecostes

    ;; Pent22-2: Feria Tertia infra Hebdomadam XXII post Octavam Pentecostes

    ;; Pent22-3: Feria Quarta infra Hebdomadam XXII post Octavam Pentecostes

    ;; Pent22-4: Feria Quinta infra Hebdomadam XXII post Octavam Pentecostes

    ;; Pent22-5: Feria Sexta infra Hebdomadam XXII post Octavam Pentecostes

    ;; Pent22-6: Sabbato infra Hebdomadam XXII post Octavam Pentecostes

    ;; Pent23-1: Feria Secunda infra Hebdomadam XXIII post Octavam Pentecostes

    ;; Pent23-2: Feria Tertia infra Hebdomadam XXIII post Octavam Pentecostes

    ;; Pent23-3: Feria Quarta infra Hebdomadam XXIII post Octavam Pentecostes

    ;; Pent23-4: Feria Quinta infra Hebdomadam XXIII post Octavam Pentecostes

    ;; Pent23-5: Feria Sexta infra Hebdomadam XXIII post Octavam Pentecostes

    ;; Pent23-6: Sabbato infra Hebdomadam XXIII post Octavam Pentecostes

    ;; Pent24-1: Feria Secunda infra Hebdomadam XXIV post Octavam Pentecostes

    ;; Pent24-2: Feria Tertia infra Hebdomadam XXIV post Octavam Pentecostes

    ;; Pent24-3: Feria Quarta infra Hebdomadam XXIV post Octavam Pentecostes

    ;; Pent24-4: Feria Quinta infra Hebdomadam XXIV post Octavam Pentecostes

    ;; Pent24-5: Feria Sexta infra Hebdomadam XXIV post Octavam Pentecostes

    ;; Pent24-6: Sabbato infra Hebdomadam XXIV post Octavam Pentecostes
    )
  "Ferial Matins data for post-Pentecost weekdays (weeks 1-11).
Each entry is ((WEEK . DOW) . (:lessons (L1 L2 L3) :responsories (R1 R2 R3))).
Weeks 12-24 use the scriptura occurrens (month-based) system instead.")

(defun bcp-roman-tempora--ferial-week-dow (date)
  "Return (WEEK . DOW) for DATE within the post-Pentecost season, or nil.
WEEK is 1-24, DOW is 1=Mon..6=Sat.  Returns nil on Sundays and
outside the per-annum season."
  (let* ((year (caddr date))
         (feasts (bcp-moveable-feasts year))
         (easter (cdr (assq 'easter feasts)))
         (easter-abs (calendar-absolute-from-gregorian easter))
         ;; Week 1 begins the Monday after Pentecost octave Saturday
         ;; Pentecost = Easter + 49; octave Saturday = Easter + 55
         ;; Week 1 Sunday = Easter + 56
         (pent1-sun-abs (+ easter-abs 56))
         (date-abs (calendar-absolute-from-gregorian date))
         (dow (calendar-day-of-week date))
         (diff (- date-abs pent1-sun-abs)))
    ;; Skip Sundays; must be within season.
    ;; Max week varies by Easter date (early Easter → up to ~28 weeks).
    (when (and (> dow 0) (>= diff 0))
      (let ((week (1+ (/ diff 7))))
        (when (<= week 28)
          (cons week dow))))))

(defun bcp-roman-tempora-ferial-matins (date)
  "Return ferial Matins data for DATE if it is a post-Pentecost weekday.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories,
or nil if DATE is a Sunday or outside per-annum.
For weeks 1-11, uses the Pent-based ferial data (scripture from Kings etc.).
For weeks 12-24, falls back to scriptura occurrens (month-based readings)."
  (let ((key (bcp-roman-tempora--ferial-week-dow date)))
    (when key
      (or (cdr (assoc key bcp-roman-tempora--ferial-matins))
          ;; Weeks 12-24: build ferial data from scriptura occurrens
          (let* ((mw-key (bcp-roman-tempora--month-week-key date))
                 (mw-data (cdr (assoc mw-key
                                       bcp-roman-tempora--scriptura-occurrens))))
            (when mw-data
              (let ((refs (plist-get mw-data :scripture-refs))
                    (mw-resps (plist-get mw-data :responsories)))
                (list :lessons (list (list :ref (nth 0 refs))
                                     (list :ref (nth 1 refs))
                                     (list :ref (nth 2 refs)))
                      :responsories (list (nth 0 mw-resps)
                                          (nth 1 mw-resps)
                                          (nth 2 mw-resps))))))))))


(provide 'bcp-roman-tempora)

;;; bcp-roman-tempora.el ends here
