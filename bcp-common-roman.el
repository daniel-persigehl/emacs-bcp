;;; bcp-common-roman.el --- Shared Roman Rite prayer texts -*- lexical-binding: t -*-

;;; Commentary:

;; Prayers shared across Roman Rite implementations within this framework.
;; The target form is the pre-1955 Roman Breviary as reformed by Pius X's
;; Divino Afflatu (1911), which is the form the Anglican Breviary follows.
;; The domain prefix for the Roman Office implementation is `bcp-roman-'.
;;
;; Primary data source: the Divinum Officium project, Divino Afflatu (DA)
;; rubrics.  Before using DA data extensively, verify that its pre-1955
;; octave structure is intact (the 1955 suppressions must not have been
;; silently applied in DA mode).
;;
;; Scope: Divine Office (Breviary) only.  Mass propers and occasional rites
;; are out of scope.
;;
;; Texts here are Latin-primary.  Texts shared with the Anglican Office
;; (Lord's Prayer, Gloria Patri, Apostles' Creed) live in
;; `bcp-common-prayers' with both :english and :latin keys.
;;
;; Relationship to other common layers:
;;   `bcp-common-prayers'  — truly ecumenical texts shared with this layer
;;                           (Lord's Prayer, Gloria Patri, Apostles' Creed)
;;   `bcp-common-anglican' — Anglican-family texts; not shared here

;;; Code:

(require 'bcp-common-prayers)

;; Shared officiant variable — defined as defcustom in bcp-1662.el,
;; declared here so the Roman Office can reference it independently.
(defvar office-officiant 'lay
  "Role of the person reciting the Office.
One of: lay, deacon, priest, bishop.")

;;;; ──────────���───────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-roman nil
  "Roman Office settings."
  :prefix "bcp-roman-"
  :group 'bcp-liturgy)

(defcustom bcp-roman-office-language 'latin
  "Language for the Roman Office.
When set to \\='latin, all texts render in Latin (the default).
When set to \\='english, the renderer uses:
  - Hymnal translations for hymns (`bcp-roman-hymnal')
  - The configured Bible fetcher for scripture (capitula, lessons)
  - Bute 1908 prose translations for antiphons, collects, versicles
  - Latin fallback when no English text is available"
  :type  '(choice (const latin) (const english))
  :group 'bcp-roman)

;;;;──────────────────────────────────────────────────────────────────────────
;;;; Penitential rite
;;
;; The Confiteor and absolution prayers.  The DA form names the saints in
;; the standard Roman order; monastic forms (Benedictine, Cistercian, OP)
;; insert their founder and are not included here.

(defconst bcp-roman-confiteor
  "Confíteor Deo omnipoténti, beátæ Maríæ semper Vírgini, beáto Michaéli \
Archángelo, beáto Joánni Baptístæ, sanctis Apóstolis Petro et Paulo, \
et ómnibus Sanctis, quia peccávi nimis, cogitatióne, verbo et ópere: \
mea culpa, mea culpa, mea máxima culpa. \
Ídeo precor beátam Maríam semper Vírginem, beátum Michaélem Archángelum, \
beátum Joánnem Baptístam, sanctos Apóstolos Petrum et Paulum, \
et omnes Sanctos, oráre pro me ad Dóminum Deum nostrum."
  "The Confiteor (DA form, secular Office).")

(defconst bcp-roman-misereatur
  "Misereátur nostri omnípotens Deus, et dimíssis peccátis nostris, \
perdúcat nos ad vitam ætérnam. Amen."
  "The Misereatur (absolution response after the Confiteor).")

(defconst bcp-roman-indulgentiam
  "Indulgéntiam, absolutiónem et remissiónem peccatórum nostrórum \
tríbuat nobis omnípotens et miséricors Dóminus. Amen."
  "The Indulgentiam (priestly absolution after the Confiteor).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Office versicles and responses

(defconst bcp-roman-converte-nos
  '("Convérte nos, Deus, salutáris noster."
    "Et avérte iram tuam a nobis.")
  "Compline opening versicle: Converte nos (V. R.).")

(defconst bcp-roman-deus-in-adjutorium
  '(:versicle "Deus, in adjutórium meum inténde."
    :response "Dómine, ad adjuvándum me festína.")
  "The Deus in adjutorium incipit (V. R.).
The Gloria Patri and Alleluia/Laus tibi are appended by the renderer.")

(defconst bcp-roman-dominus-vobiscum
  '("Dóminus vobíscum."
    "Et cum spíritu tuo.")
  "Dominus vobiscum (V. R.).")

(defconst bcp-roman-domine-exaudi
  '("Dómine, exáudi oratiónem meam."
    "Et clamor meus ad te véniat.")
  "Domine exaudi (V. R.), often follows Dominus vobiscum.")

(defconst bcp-roman-benedicamus-domino
  '("Benedicámus Dómino."
    "Deo grátias.")
  "Benedicamus Domino (V. R.).")

(defconst bcp-roman-kyrie
  "Kýrie, eléison. Christe, eléison. Kýrie, eléison."
  "The Kyrie eleison (threefold).")

(defconst bcp-roman-oremus
  "Orémus."
  "The Oremus (Let us pray).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Ave Maria

(defconst bcp-roman-ave-maria
  "Ave María, grátia plena; Dóminus tecum: benedícta tu in muliéribus, \
et benedíctus fructus ventris tui Jesus. Sancta María, Mater Dei, \
ora pro nobis peccatóribus, nunc et in hora mortis nostræ. Amen."
  "The Ave Maria (full form with post-Tridentine addition).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Alleluia / Lenten substitute

(defconst bcp-roman-alleluia
  "Allelúja."
  "Alleluia, appended to the incipit outside penitential seasons.")

(defconst bcp-roman-laus-tibi
  "Laus tibi, Dómine, Rex ætérnæ glóriæ."
  "Lenten substitute for the Alleluia at the incipit.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Benedictions

(defun bcp-roman-jube-domne ()
  "Return the Jube domne/Domine versicle based on `office-officiant'.
\"domne\" (sir) when addressed to a priest; \"Dómine\" (Lord) when lay."
  (if (memq office-officiant '(priest bishop))
      "Jube, domne, benedícere."
    "Jube, Dómine, benedícere."))

(defconst bcp-roman-benedictio-compline
  "Noctem quiétam et finem perféctum concédat nobis Dóminus omnípotens."
  "The Compline benediction (Noctem quietam).")

(defconst bcp-roman-benedictio-compline-final
  "Benedícat et custódiat nos omnípotens et miséricors Dóminus, \
Pater, et Fílius, et Spíritus Sanctus."
  "The final Compline benediction (Benedicat et custodiat).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Collect conclusion formulae

(defconst bcp-roman-per-dominum
  "Per Dóminum nostrum Jesum Christum, Fílium tuum: qui tecum vivit \
et regnat in unitáte Spíritus Sancti, Deus, per ómnia sǽcula sæculórum. Amen."
  "Standard collect conclusion: Per Dominum.")

(defconst bcp-roman-per-eumdem
  "Per eúmdem Dóminum nostrum Jesum Christum Fílium tuum, qui tecum vivit \
et regnat in unitáte Spíritus Sancti, Deus, per ómnia sǽcula sæculórum. Amen."
  "Collect conclusion when Christ is named in the body: Per eumdem.")

(defconst bcp-roman-qui-vivis
  "Qui vivis et regnas cum Deo Patre, in unitáte Spíritus Sancti, Deus, \
per ómnia sǽcula sæculórum. Amen."
  "Collect conclusion addressed to the Son: Qui vivis.")

(defconst bcp-roman-qui-tecum
  "Qui tecum vivit et regnat in unitáte Spíritus Sancti, Deus, \
per ómnia sǽcula sæculórum. Amen."
  "Collect conclusion: Qui tecum (shorter form).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Matins absolutiones et benedictiones
;;
;; The absolutio is said before the lessons of each nocturn.
;; The benedictiones rotate: one per lesson.
;; These are the standard forms from the secular (non-monastic) Breviary.

(defconst bcp-roman-absolutiones
  '("Exáudi, Dómine Jesu Christe, preces servórum tuórum, et miserére nobis: \
Qui cum Patre et Spíritu Sancto vivis et regnas in sǽcula sæculórum."
    "Ipsíus píetas et misericórdia nos ádjuvet, qui cum Patre et Spíritu Sancto \
vivit et regnat in sǽcula sæculórum."
    "A vínculis peccatórum nostrórum absólvat nos omnípotens et miséricors Dóminus.")
  "The three absolutiones before the lessons of each nocturn.
Index 0 = Nocturn I, 1 = Nocturn II, 2 = Nocturn III.")

(defconst bcp-roman-benedictiones-nocturn-1
  '("Benedictióne perpétua benedícat nos Pater ætérnus."
    "Unigénitus Dei Fílius nos benedícere et adjuváre dignétur."
    "Spíritus Sancti grátia illúminet sensus et corda nostra.")
  "The three standard benedictions for Nocturn I lessons.")

(defconst bcp-roman-benedictiones-nocturn-2
  '("Deus Pater omnípotens sit nobis propítius et clemens."
    "Christus perpétuæ det nobis gáudia vitæ."
    "Ignem sui amóris accéndat Deus in córdibus nostris.")
  "The three standard benedictions for Nocturn II lessons.")

(defconst bcp-roman-benedictiones-nocturn-3
  '("Ille nos benedícat, qui sine fine vivit et regnat."
    "Divínum auxílium máneat semper nobíscum."
    "Ad societátem cívium supernórum perdúcat nos Rex Angelórum.")
  "The three standard benedictions for Nocturn III lessons.")

(defconst bcp-roman-benedictio-evangelica
  "Evangélica léctio sit nobis salus et protéctio."
  "The Evangelica benediction, said before the first lesson of Nocturn III
\(the Gospel homily lesson\).")

(defconst bcp-roman-benedictiones-nocturn-3-dominical
  (list "Evangélica léctio sit nobis salus et protéctio."
        "Divínum auxílium máneat semper nobíscum."
        "Ad societátem cívium supernórum perdúcat nos Rex Angelórum.")
  "Benedictions for Nocturn III on Sundays (Evangelica replaces position 0).")

;; English translations (Bute 1908)

(defconst bcp-roman-absolutiones-en
  '("O Lord Jesus Christ, graciously hear the prayers of Thy servants, \
and have mercy upon us, Who livest and reignest with the Father, \
and the Holy Ghost, ever world without end."
    "May His loving-kindness and mercy help us, Who liveth and reigneth \
with the Father, and the Holy Ghost, world without end."
    "May the Almighty and merciful Lord loose us from the bonds of our sins.")
  "English translations of the three absolutiones.")

(defconst bcp-roman-benedictiones-nocturn-1-en
  '("May the Eternal Father bless us with an eternal blessing."
    "May the Son, the Sole-begotten, mercifully bless and keep us."
    "May the grace of the Holy Spirit enlighten all our hearts and minds.")
  "English translations of the Nocturn I benedictions.")

(defconst bcp-roman-benedictiones-nocturn-2-en
  '("May God the Father Omnipotent, be to us merciful and clement."
    "May Christ to all His people give, for ever in His sight to live."
    "May the Spirit's fire Divine in our hearts enkindled shine.")
  "English translations of the Nocturn II benedictions.")

(defconst bcp-roman-benedictiones-nocturn-3-en
  '("May His blessing be upon us who doth live and reign for ever."
    "God's most mighty strength alway be His people's staff and stay."
    "May He that is the Angels' King to that high realm His people bring.")
  "English translations of the Nocturn III benedictions.")

(defconst bcp-roman-benedictiones-nocturn-3-dominical-en
  (list "May the Gospel's holy lection be our safety and protection."
        "God's most mighty strength alway be His people's staff and stay."
        "May He that is the Angels' King to that high realm His people bring.")
  "English benedictions for Nocturn III on Sundays (Evangelica at position 0).")

(defconst bcp-roman-benedictiones-lobvm
  '("Précibus et méritis beátæ Maríæ semper Vírginis et ómnium Sanctórum, \
perdúcat nos Dóminus ad regna cælórum."
    "Nos cum prole pia benedícat Virgo María."
    "Ipsa Virgo Vírginum intercédat pro nobis ad Dóminum.")
  "The three special benedictions for the Little Office of the BVM (from C10).
Used instead of the standard nocturn benedictions.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Closing versicles

(defconst bcp-roman-divinum-auxilium
  "Divínum auxílium máneat semper nobíscum. \
Et cum frátribus nostris abséntibus. Amen."
  "The Divinum auxilium (closing versicle of the Office).")

(defconst bcp-roman-fidelium-animae
  '("Fidélium ánimæ per misericórdiam Dei requiéscant in pace."
    "Amen.")
  "Fidelium animae (V. R.).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Seasonal Marian antiphons
;;
;; The four final antiphons of the BVM, said after Compline (and after
;; Lauds in some uses).  Each has: antiphon text, versicle/response,
;; Oremus, collect, and conclusion.
;;
;; Season assignment:
;;   advent       — Alma Redemptoris Mater (Advent I – Christmas Eve)
;;   christmastide — Alma Redemptoris Mater (Christmas – Feb 1)
;;                   with different V./R. and collect from Advent
;;   per-annum     — Salve Regina (Trinity – Saturday before Advent I)
;;   lent          — Ave Regina caelorum (Feb 2 – Wednesday of Holy Week)
;;   eastertide    — Regina caeli (Easter – Friday after Pentecost)

(defconst bcp-roman-marian-antiphon-advent
  '(:antiphon
    "Alma Redemptóris Mater, quæ pérvia cæli porta manes, \
et stella maris, succúrre cadénti, \
Súrgere qui curat, pópulo: tu quæ genuísti, \
Natúra miránte, tuum sanctum Genitórem, \
Virgo prius ac postérius, Gabriélis ab ore \
Sumens illud Ave, peccatórum miserére."
    :versicle "Ángelus Dómini nuntiávit Maríæ."
    :response "Et concépit de Spíritu Sancto."
    :collect
    "Grátiam tuam, quǽsumus, Dómine, méntibus nostris infúnde: \
ut, qui, Ángelo nuntiánte, Christi Fílii tui incarnatiónem cognóvimus; \
per passiónem ejus et crucem, ad resurrectiónis glóriam perducámur. \
Per eúmdem Christum Dóminum nostrum. Amen.")
  "Alma Redemptoris Mater — Advent form.")

(defconst bcp-roman-marian-antiphon-christmastide
  '(:antiphon
    "Alma Redemptóris Mater, quæ pérvia cæli porta manes, \
et stella maris, succúrre cadénti, \
Súrgere qui curat, pópulo: tu quæ genuísti, \
Natúra miránte, tuum sanctum Genitórem, \
Virgo prius ac postérius, Gabriélis ab ore \
Sumens illud Ave, peccatórum miserére."
    :versicle "Post partum, Virgo, invioláta permansísti."
    :response "Dei Génetrix, intercéde pro nobis."
    :collect
    "Deus, qui salútis ætérnæ, beátæ Maríæ virginitáte fecúnda, humáno géneri \
prǽmia præstitísti: tríbue, quǽsumus; ut ipsam pro nobis intercédere sentiámus, \
per quam merúimus auctórem vitæ suscípere, Dóminum nostrum Jesum Christum \
Fílium tuum. Amen.")
  "Alma Redemptoris Mater — Christmastide form (different V./R. and collect).")

(defconst bcp-roman-marian-antiphon-lent
  '(:antiphon
    "Ave, Regína cælórum, \
Ave, Dómina Angelórum: \
Salve radix, salve porta, \
Ex qua mundo lux est orta: \
Gaude, Virgo gloriósa, \
Super omnes speciósa, \
Vale, o valde decóra, \
Et pro nobis Christum exóra."
    :versicle "Dignáre me laudáre te, Virgo sacráta."
    :response "Da mihi virtútem contra hostes tuos."
    :collect
    "Concéde, miséricors Deus, fragilitáti nostræ præsídium; ut, qui sanctæ Dei \
Genetrícis memóriam ágimus; intercessiónis ejus auxílio, a nostris iniquitátibus \
resurgámus. Per eúmdem Christum Dóminum nostrum. Amen.")
  "Ave Regina caelorum — Lent (Feb 2 – Wednesday of Holy Week).")

(defconst bcp-roman-marian-antiphon-eastertide
  '(:antiphon
    "Regína cæli, lætáre, allelúja; \
Quia quem meruísti portáre, allelúja, \
Resurréxit, sicut dixit, allelúja: \
Ora pro nobis Deum, allelúja."
    :versicle "Gaude et lætáre, Virgo María, allelúja."
    :response "Quia surréxit Dóminus vere, allelúja."
    :collect
    "Deus, qui per resurrectiónem Fílii tui, Dómini nostri Jesu Christi, mundum \
lætificáre dignátus es: præsta, quǽsumus; ut, per ejus Genetrícem Vírginem \
Maríam, perpétuæ capiámus gáudia vitæ. Per eúmdem Christum Dóminum nostrum. Amen.")
  "Regina caeli — Eastertide (Easter – Friday after Pentecost).")

(defconst bcp-roman-marian-antiphon-per-annum
  '(:antiphon
    "Salve, Regína, mater misericórdiæ; \
vita, dulcédo et spes nóstra, salve. \
Ad te clamámus éxsules fílii Hevæ. \
Ad te suspirámus geméntes et flentes \
in hac lacrimárum valle. \
Eja ergo, advocáta nostra, \
illos tuos misericórdes óculos ad nos convérte. \
Et Jesum, benedíctum fructum ventris tui, \
nobis post hoc exsílium osténde. \
O clemens, o pia, o dulcis Virgo María."
    :versicle "Ora pro nobis, sancta Dei Génetrix."
    :response "Ut digni efficiámur promissiónibus Christi."
    :collect
    "Omnípotens sempitérne Deus, qui gloriósæ Vírginis Matris Maríæ corpus et ánimam, \
ut dignum Fílii tui habitáculum éffici mererétur, Spíritu Sancto cooperánte, \
præparásti: da, ut, cujus commemoratióne lætámur, ejus pia intercessióne, \
ab instántibus malis et a morte perpétua liberémur. \
Per eúmdem Christum Dóminum nostrum. Amen.")
  "Salve Regina — per annum (Trinity – Saturday before Advent I).")

(defconst bcp-roman-marian-antiphons
  `((advent       . ,bcp-roman-marian-antiphon-advent)
    (christmastide . ,bcp-roman-marian-antiphon-christmastide)
    (lent         . ,bcp-roman-marian-antiphon-lent)
    (eastertide   . ,bcp-roman-marian-antiphon-eastertide)
    (per-annum    . ,bcp-roman-marian-antiphon-per-annum))
  "Alist of (SEASON . MARIAN-ANTIPHON-PLIST) for the final antiphon of the BVM.
Used after Compline and (in some uses) after Lauds.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Penitential form registration

(bcp-penitential-register
 'roman
 `(:confession ,bcp-roman-confiteor
   :absolution ,(concat bcp-roman-misereatur "\n" bcp-roman-indulgentiam)
   :rubric "Confíteor."))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Configurable penitential rite for the Roman Office

(defcustom bcp-roman-confession-form 'roman
  "Which confession form to use in the Roman Office.
The symbol must be a key in `bcp-penitential-forms'."
  :type '(choice (const :tag "Roman (Confiteor)" roman)
                 (const :tag "Anglican 1662 (General Confession)" anglican-1662)
                 (const :tag "Anglican 1928 (General Confession)" anglican-1928))
  :group 'bcp-common-prayers)

(defcustom bcp-roman-absolution-form 'roman
  "Which absolution form to use in the Roman Office.
The symbol must be a key in `bcp-penitential-forms'."
  :type '(choice (const :tag "Roman (Misereatur + Indulgentiam)" roman)
                 (const :tag "Anglican 1662 (Absolution)" anglican-1662)
                 (const :tag "Anglican 1662 lay (Pardon and peace)" anglican-1662-lay)
                 (const :tag "Anglican 1928 (Absolution)" anglican-1928))
  :group 'bcp-common-prayers)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; English structural texts (Bute 1908)
;;
;; English equivalents of the Latin structural formulae above.
;; Used by the renderer when `bcp-roman-office-language' is 'english.

(defconst bcp-roman-converte-nos-en
  '("Turn us then, O God, our saviour:"
    "And let thy anger cease from us.")
  "Converte nos, English — Bute.")

(defconst bcp-roman-deus-in-adjutorium-en
  '(:versicle "O God, come to my assistance;"
    :response "O Lord, make haste to help me.")
  "Deus in adjutorium, English — Bute.")

(defconst bcp-roman-dominus-vobiscum-en
  '("The Lord be with you."
    "And with thy spirit.")
  "Dominus vobiscum, English — Bute.")

(defconst bcp-roman-domine-exaudi-en
  '("O Lord, hear my prayer."
    "And let my cry come unto thee.")
  "Domine exaudi, English — Bute.")

(defconst bcp-roman-benedicamus-domino-en
  '("Let us bless the Lord."
    "Thanks be to God.")
  "Benedicamus Domino, English — Bute.")

(defconst bcp-roman-kyrie-en
  "Lord, have mercy. Christ, have mercy. Lord, have mercy."
  "Kyrie eleison, English — Bute.")

(defconst bcp-roman-oremus-en
  "Let us pray."
  "Oremus, English — Bute.")

(defconst bcp-roman-alleluia-en
  "Alleluia."
  "Alleluia, English form.")

(defconst bcp-roman-laus-tibi-en
  "Praise be to thee, O Lord, King of everlasting glory."
  "Laus tibi, English — Bute.")

(defconst bcp-roman-benedictio-compline-en
  "May almighty God grant us a quiet night and a perfect end."
  "Compline benediction, English — Bute.")

(defconst bcp-roman-benedictio-compline-final-en
  "The almighty and merciful Lord, the Father, the Son and the Holy Spirit, \
bless us and keep us."
  "Final Compline benediction, English — Bute.")

(defconst bcp-roman-divinum-auxilium-en
  "May the divine assistance remain with us always. \
And with our brothers, who are absent. Amen."
  "Divinum auxilium, English — Bute.")

(defconst bcp-roman-fidelium-animae-en
  '("May the souls of the faithful, through the mercy of God, rest in peace."
    "Amen.")
  "Fidelium animae, English — Bute.")

(defun bcp-roman-jube-domne-en ()
  "Return English Jube domne based on `office-officiant'."
  (if (memq office-officiant '(priest bishop))
      "Grant, sir, a blessing."
    "Grant, Lord, a blessing."))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; English Marian antiphons (Bute 1908)

(defconst bcp-roman-marian-antiphon-advent-en
  '(:antiphon
    "Mother of Christ, hear thou thy people's cry,\n\
Star of the deep and Portal of the sky!\n\
Mother of Him who thee from nothing made,\n\
Sinking we strive and call to thee for aid:\n\
O, by what joy which Gabriel brought to thee,\n\
Thou Virgin first and last, let us thy mercy see."
    :versicle "The Angel of the Lord announced unto Mary."
    :response "And she conceived of the Holy Spirit."
    :collect
    "Pour forth, we beseech thee, O Lord, thy grace into our hearts: \
that as we have known the incarnation of thy Son Jesus Christ by the \
message of an Angel, so too by his Cross and passion may we be brought \
to the glory of his resurrection. Through the same Christ our Lord. Amen.")
  "Alma Redemptoris Mater — Advent, English — Bute.")

(defconst bcp-roman-marian-antiphon-christmastide-en
  '(:antiphon
    "Mother of Christ, hear thou thy people's cry,\n\
Star of the deep and Portal of the sky!\n\
Mother of Him who thee from nothing made,\n\
Sinking we strive and call to thee for aid:\n\
O, by what joy which Gabriel brought to thee,\n\
Thou Virgin first and last, let us thy mercy see."
    :versicle "After childbirth thou didst remain a virgin."
    :response "Intercede for us, O Mother of God."
    :collect
    "O God, who, by the fruitful virginity of blessed Mary, hast bestowed \
upon mankind the reward of eternal salvation: grant, we beseech thee, that \
we may experience her intercession, through whom we have been made worthy \
to receive the author of life, Our Lord Jesus Christ thy Son. Amen.")
  "Alma Redemptoris Mater — Christmastide, English — Bute.")

(defconst bcp-roman-marian-antiphon-lent-en
  '(:antiphon
    "Hail, O Queen of heaven, enthroned!\n\
Hail, by Angels Mistress owned!\n\
Root of Jesse, Gate of morn,\n\
Whence the world's true Light was born:\n\
\n\
Glorious Virgin, joy to thee,\n\
Loveliest whom in heaven they see:\n\
Fairest thou, where all are fair,\n\
Plead with Christ our sins to spare."
    :versicle "Allow me to praise thee, holy Virgin."
    :response "Give me strength against thine enemies."
    :collect
    "Grant, O merciful God, to our weak natures thy protection, that we \
who commemorate the holy Mother of God may, by the help of her intercession, \
arise from our iniquities. Through the same Christ our Lord. Amen.")
  "Ave Regina caelorum — Lent, English — Bute.")

(defconst bcp-roman-marian-antiphon-eastertide-en
  '(:antiphon
    "O Queen of heaven rejoice! alleluia:\n\
For He whom thou didst merit to bear, alleluia,\n\
Hath arisen as he said, alleluia.\n\
Pray for us to God, alleluia."
    :versicle "Rejoice and be glad, O Virgin Mary, alleluia."
    :response "Because the Lord is truly risen, alleluia."
    :collect
    "O God, who gave joy to the world through the resurrection of thy Son, \
our Lord Jesus Christ; grant, we beseech thee, that through his Mother, the \
Virgin Mary, we may obtain the joys of everlasting life. Through the same \
Christ our Lord. Amen.")
  "Regina caeli — Eastertide, English — Bute.")

(defconst bcp-roman-marian-antiphon-per-annum-en
  '(:antiphon
    "Hail holy Queen, Mother of Mercy,\n\
our life, our sweetness, and our hope.\n\
To thee do we cry, poor banished children of Eve.\n\
To thee do we send up our sighs, mourning and weeping\n\
In this valley of tears.\n\
Turn then, most gracious Advocate,\n\
thine eyes of mercy toward us.\n\
And after this our exile show unto us\n\
the blessed fruit of thy womb, Jesus.\n\
O clement, O loving, O sweet Virgin Mary."
    :versicle "Pray for us, O Holy Mother of God."
    :response "That we may be made worthy of the promises of Christ."
    :collect
    "O almighty, everlasting God, who by the cooperation of the Holy Spirit, \
didst prepare the body and soul of Mary, glorious Virgin and Mother, to become \
a worthy dwelling for Thy Son; grant that we who rejoice in her commemoration \
may, by her gracious intercession, be delivered from present evils and from \
everlasting death. Through the same Christ our Lord. Amen.")
  "Salve Regina — per annum, English — Bute.")

(defconst bcp-roman-marian-antiphons-en
  `((advent       . ,bcp-roman-marian-antiphon-advent-en)
    (christmastide . ,bcp-roman-marian-antiphon-christmastide-en)
    (lent         . ,bcp-roman-marian-antiphon-lent-en)
    (eastertide   . ,bcp-roman-marian-antiphon-eastertide-en)
    (per-annum    . ,bcp-roman-marian-antiphon-per-annum-en))
  "English Marian antiphons alist, parallel to `bcp-roman-marian-antiphons'.")

(provide 'bcp-common-roman)
;;; bcp-common-roman.el ends here
