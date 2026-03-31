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
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
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
         nil  ; R1 (not in file)
         nil  ; R2 (not in file)
         nil  ; R3 (not in file)
         nil  ; R4 (not in file)
         nil  ; R5 (not in file)
         nil  ; R6 (not in file)
         nil  ; R7 (not in file)
         nil  ; R8 (not in file)
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

(defun bcp-roman-tempora-dominical-matins (date)
  "Return the dominical Matins data for the Sunday on or before DATE.
DATE is (MONTH DAY YEAR).  Returns a plist with :lessons and :responsories,
or nil if outside Per Annum."
  (let ((n (bcp-roman-tempora--pent-number date)))
    (when n
      (alist-get n bcp-roman-tempora--dominical-matins))))

(provide 'bcp-roman-tempora)

;;; bcp-roman-tempora.el ends here
