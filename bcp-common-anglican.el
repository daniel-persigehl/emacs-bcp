;;; bcp-common-anglican.el --- Shared Anglican prayer texts -*- lexical-binding: t -*-

;;; Commentary:

;; Prayers shared across multiple Anglican prayer book traditions (BCP 1662,
;; 1928, 1979, etc.) but specific to the Anglican family.  Each tradition's
;; ordo may draw from this pool rather than duplicating texts.
;;
;; Texts that are truly ecumenical (Lord's Prayer, Apostles' Creed, Gloria
;; Patri) belong in `bcp-common-prayers'.  Texts here are Anglican by
;; tradition but cross-edition: the General Thanksgiving, the Prayer for
;; All Conditions of Men, and the fixed office collects (peace, grace, perils).
;;
;; Entry format matches `bcp-common-prayers': plists with keyword language
;; keys (:english, :latin, …).  Use `bcp-common-prayers-text' to resolve
;; text for the current language.
;;
;; Tradition-specific variants (e.g. the 1928 form of the General
;; Thanksgiving) should be registered here alongside the 1662 form, keyed
;; by a distinct symbol, so each ordo can reference the appropriate entry.

;;; Code:

(require 'bcp-common-prayers)
(require 'bcp-liturgy-render)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Defgroup

(defgroup bcp-anglican nil
  "Settings shared across Anglican BCP traditions."
  :prefix "bcp-anglican-"
  :group 'bcp-liturgy)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Rubrical options shared across the Anglican BCP family

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Shared liturgical texts

(defconst bcp-common-anglican-exhortation-brief
  "Let us humbly confess our sins unto Almighty God."
  "Brief form of the Bidding (exhortation) before the General Confession.
Text from the 1928 American BCP.  Used in place of the full \"Dearly
beloved brethren\" exhortation when a shorter form is desired.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Fixed office collects  (shared across 1662 and 1928)

(defconst bcp-common-anglican-collect-morning-peace
  '(:name  collect-morning-peace
    :title "The second Collect, for Peace."
    :english
    "O God, who art the author of peace and lover of concord, in knowledge of \
whom standeth our eternal life, whose service is perfect freedom; Defend us thy \
humble servants in all assaults of our enemies; that we, surely trusting in thy \
defence, may not fear the power of any adversaries, through the might of Jesus \
Christ our Lord. Amen."
    :nskk-1959
    "親しみを好み、平安をあたえたもう神よ、主を知るはこれ限りなき命なり、\
主につこうるは全き自由なり。願わくは常にしもべらを守り、すべて攻めきたる敵を防ぎ、\
いかなる強きあだをも恐れず、堅く主にたよりて安んずることを得させたまえ。\
大能の主イエス＝キリストによりてこいねがい奉る。アーメン")
  "Morning Prayer: Collect for Peace.")

(defconst bcp-common-anglican-collect-morning-grace
  '(:name  collect-morning-grace
    :title "The third Collect, for Grace."
    :english
    "O Lord, our heavenly Father, Almighty and everlasting God, who hast safely \
brought us to the beginning of this day; Defend us in the same with thy mighty \
power; and grant that this day we fall into no sin, neither run into any kind of \
danger; but that all our doings may be ordered by thy governance, to do always \
that is righteous in thy sight; through Jesus Christ our Lord. Amen."
    :nskk-1959
    "天のちち、かぎりなく生ける全能の神よ、我らを今朝まで安全に至らせたまえるごとく、\
今日も大いなる力をもって守りたまえ。願わくは罪に陥らず、危うきことにもあわず、\
常に主の導きをこうむり正しき行ないをなすことを得させたまえ。\
主イエス＝キリストによりてこいねがい奉る。アーメン")
  "Morning Prayer: Collect for Grace.")

(defconst bcp-common-anglican-collect-evening-peace
  '(:name  collect-evening-peace
    :title "The Second Collect at Evening Prayer."
    :english
    "O God, from whom all holy desires, all good counsels, and all just works do \
proceed; Give unto thy servants that peace which the world cannot give; that both \
our hearts may be set to obey thy commandments, and also that by thee, we, being \
defended from the fear of our enemies, may pass our time in rest and quietness; \
through the merits of Jesus Christ our Saviour. Amen."
    :nskk-1959
    "もろもろの聖なる望み・良き思い・正しきわざのもとなる神よ、\
願わくは、しもべらに世のあたえ得ざる平安をあたえ、\
主の戒めに従うことを決心せしめ、\
また主の守りによりてあだを恐れず、おだやかに世を渡ることを得させたまえ。\
救い主イエス＝キリストのいさおによりてこいねがい奉る。アーメン")
  "Evening Prayer: Collect for Peace.")

(defconst bcp-common-anglican-collect-evening-perils
  '(:name  collect-evening-perils
    :title "The Third Collect, for Aid against all Perils."
    :english
    "Lighten our darkness, we beseech thee, O Lord; and by thy great mercy defend \
us from all perils and dangers of this night; for the love of thy only Son, our \
Saviour, Jesus Christ. Amen."
    :nskk-1959
    "主よ、御光もって我らの暗きを照らし、\
主の大いなるあわれみをもって今夜の危うき防ぎたまわんことを、\
御子・われらの救い主イエス＝キリストのいつくしみによりてこいねがい奉る。アーメン")
  "Evening Prayer: Collect for Aid against all Perils.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Monarchical state prayers  (shared across monarchy-context Anglican BCPs)
;;
;; These are common Anglican prayers, not 1662-specific.  Any Commonwealth
;; prayer book in a monarchy context uses essentially the same texts.
;; The sovereign's name and the Royal Family members are updated as required.

(defconst bcp-common-anglican-prayer-king
  '(:name  prayer-king
    :title "A Prayer for the King's Majesty."
    :text  "O Lord, our heavenly Father, the high and mighty, King of kings, \
Lord of lords, the only Ruler of princes, who dost from thy throne behold all \
the dwellers upon earth; Most heartily we beseech thee with thy favour to behold \
our most gracious Sovereign Lord, KING CHARLES; and so replenish him with the \
grace of thy Holy Spirit, that he may always incline to thy will, and walk in \
thy way. Endue him plenteously with heavenly gifts; grant him in health and wealth \
long to live; strengthen him that he may vanquish and overcome all his enemies; \
and finally, after this life, he may attain everlasting joy and felicity; through \
Jesus Christ our Lord. Amen.")
  "A Prayer for the King's Majesty (current sovereign: Charles III).
Update the sovereign's name when the crown passes.")

(defconst bcp-common-anglican-prayer-queen
  '(:name  prayer-queen
    :title "A Prayer for the Queen's Majesty."
    :text  "O Lord, our heavenly Father, the high and mighty, King of kings, \
Lord of lords, the only Ruler of princes, who dost from thy throne behold all \
the dwellers upon earth; Most heartily we beseech thee with thy favour to behold \
our most gracious Sovereign Lady, QUEEN ELIZABETH; and so replenish her with the \
grace of thy Holy Spirit, that she may always incline to thy will, and walk in \
thy way. Endue her plenteously with heavenly gifts; grant her in health and wealth \
long to live; strengthen her that she may vanquish and overcome all her enemies; \
and finally, after this life, she may attain everlasting joy and felicity; through \
Jesus Christ our Lord. Amen.")
  "A Prayer for the Queen's Majesty.
Update the sovereign's name when the crown passes.")

(defconst bcp-common-anglican-prayer-royal-family
  '(:name  prayer-royal-family
    :title "A Prayer for the Royal Family."
    :text  "Almighty God, the fountain of all goodness, we humbly beseech thee \
to bless QUEEN CAMILLA, WILLIAM PRINCE OF WALES, THE PRINCESS OF WALES, and all \
the Royal Family: Endue them with thy Holy Spirit; enrich them with thy heavenly \
grace; prosper them with all happiness; and bring them to thine everlasting \
kingdom; through Jesus Christ our Lord. Amen.")
  "A Prayer for the Royal Family (current members named above).
Update names as required.")

(defconst bcp-common-anglican-prayer-clergy-people
  '(:name  prayer-clergy-people
    :title "A Prayer for the Clergy and People."
    :text  "Almighty and everlasting God, who alone workest great marvels; Send \
down upon our Bishops, and Curates, and all Congregations committed to their \
charge, the healthful Spirit of thy grace; and that they may truly please thee, \
pour upon them the continual dew of thy blessing. Grant this, O Lord, for the \
honour of our Advocate and Mediator, Jesus Christ. Amen.")
  "A Prayer for the Clergy and People (1662 form: \"Bishops, and Curates\").
See also `bcp-common-anglican-prayer-clergy-people-1928' for the 1928 form
(\"Bishops, and other Clergy\").")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; 1928 collect variant

(defconst bcp-common-anglican-collect-morning-grace-1928
  '(:name  collect-morning-grace-1928
    :title "The third Collect, for Grace."
    :english
    "O Lord, our heavenly Father, Almighty and everlasting God, who hast safely \
brought us to the beginning of this day; Defend us in the same with thy mighty \
power; and grant that this day we fall into no sin, neither run into any kind of \
danger; but that all our doings, being ordered by thy governance, may be righteous \
in thy sight; through Jesus Christ our Lord. Amen.")
  "Morning Prayer: Collect for Grace (1928 American form).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; 1928 state prayers

(defconst bcp-common-anglican-prayer-for-president
  '(:name  prayer-for-president
    :title "A Prayer for the President of the United States, and all in Civil Authority."
    :english
    "O Lord, our Governor, whose glory is in all the world; We commend this \
nation to thy merciful care, that, being guided by thy Providence, we may dwell \
secure in thy peace. Grant to the President of the United States, and to all in \
authority, wisdom and strength to know and to do thy will. Fill them with the love \
of truth and righteousness; and make them ever mindful of their calling to serve \
this people in thy fear; through Jesus Christ our Lord, who liveth and reigneth \
with thee and the Holy Ghost, one God, world without end. Amen.")
  "A Prayer for the President (1928 American BCP).")

(defconst bcp-common-anglican-prayer-civil-authority
  '(:name  prayer-civil-authority
    :title "A Prayer for those in Civil Authority."
    :english
    "O Lord our Governor, whose glory is in all the world; We commend this nation \
to thy merciful care, that, being guided by thy Providence, we may dwell secure in \
thy peace. Grant to those who bear rule over us wisdom and strength to know and to \
do thy will; fill them with the love of truth and righteousness; and make them ever \
mindful of their calling to serve thy people in thy fear; through Jesus Christ our \
Lord, who liveth and reigneth with thee and the Holy Ghost, one God, world without \
end. Amen.")
  "A Prayer for Civil Authority (generic republic form, without reference to any office or nation).")

(defconst bcp-common-anglican-prayer-imperial-family
  '(:name  prayer-imperial-family
    :title "A Prayer for the Imperial Family."
    ;; 1895 NSKK 「皇室の為(に)」.  Imperial-court register with several
    ;; ateji-style readings preserved as inline rubi (kanji《reading》):
    ;;   諸般《もろもろ》  — manifold (vs. standard しょはん)
    ;;   盈《みし》        — fill, transitive 連用形 of 盈す
    ;;                       (vs. standard えい / みつ)
    ;;   疆《かぎり》なき  — boundless (vs. standard きょう / さかい)
    ;;   天國《みくに》    — heavenly kingdom (vs. standard てんごく);
    ;;                       旧字体 国; standard liturgical reading
    ;;   由《よ》りて      — by/through (vs. standard ゆ)
    ;; No English equivalent — the prayer is specifically for the Japanese
    ;; Imperial House and has no 1662 counterpart.  Not currently invoked
    ;; from any 1662/1928 ordo (which use UK/US state-prayer forms);
    ;; available for future NSKK ordo wiring.
    :bungo
    "恵《めぐ》みに富《と》みたまふ全能《ぜんのう》の神《かみ》よ。\
我《われ》らの皇太后《くわうたいこう》、皇太子《くわうたいし》、\
すべての皇室《くわうしつ》を祝《しゆく》したまへ。\
願《ねが》はくは、まことのみちびき、豊《ゆた》かに聖霊《せいれい》を注《そそ》ぎ、\
諸般《もろもろ》の喜《よろこ》びを盈《みし》、\
終《つひ》に疆《かぎり》なき天國《みくに》に至《いた》らせたまへ。\
主《しゆ》イエスキリストに由《よ》りて乞《こ》ひ願《ねが》ひたてまつる アーメン")
  "A Prayer for the Imperial Family (1895 NSKK 皇室の為).
Bungo-only entry: the 1959 NSKK has no direct counterpart, and the
prayer is Japan-specific (no English original).  Available for future
NSKK ordo wiring; not currently invoked from any 1662/1928 ordo since
those use UK/US state-prayer forms.")

(defconst bcp-common-anglican-prayer-clergy-people-1928
  '(:name  prayer-clergy-people-1928
    :title "A Prayer for the Clergy and People."
    :english
    "Almighty and everlasting God, from whom cometh every good and perfect gift; \
Send down upon our Bishops, and other Clergy, and upon the Congregations committed \
to their charge, the healthful Spirit of thy grace; and, that they may truly please \
thee, pour upon them the continual dew of thy blessing. Grant this, O Lord, for the \
honour of our Advocate and Mediator, Jesus Christ. Amen.")
  "A Prayer for the Clergy and People (1928 American form; \"other Clergy\" vs 1662 \"Curates\").")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; 1928 opening sentences — Morning Prayer

(defconst bcp-common-anglican-opening-sentences-1928
  '(;; General — suitable at any time
    (:text "The Lord is in his holy temple: let all the earth keep silence before him."
     :ref ("Hab" 2 20))
    (:text "I was glad when they said unto me, We will go into the house of the Lord."
     :ref ("Ps" 122 1))
    (:text "Let the words of my mouth, and the meditation of my heart, be alway acceptable in thy sight, O Lord, my strength and my redeemer."
     :ref ("Ps" 19 14))
    (:text "O send out thy light and thy truth, that they may lead me, and bring me unto thy holy hill, and to thy dwelling."
     :ref ("Ps" 43 3))
    (:text "Thus saith the high and lofty One that inhabiteth eternity, whose name is Holy; I dwell in the high and holy place, with him also that is of a contrite and humble spirit, to revive the spirit of the humble, and to revive the heart of the contrite ones."
     :ref ("Isa" 57 15))
    (:text "The hour cometh, and now is, when the true worshippers shall worship the Father in spirit and in truth: for the Father seeketh such to worship him."
     :ref ("John" 4 23))
    (:text "Grace be unto you, and peace, from God our Father, and from the Lord Jesus Christ."
     :ref ("Phil" 1 2))
    ;; Advent
    (:text "Repent ye, for the Kingdom of heaven is at hand."
     :ref ("Matt" 3 2))
    (:text "Prepare ye the way of the Lord, make straight in the desert a highway for our God."
     :ref ("Isa" 40 3))
    ;; Christmas
    (:text "Behold, I bring you good tidings of great joy, which shall be to all people. For unto you is born this day in the city of David a Saviour, which is Christ the Lord."
     :ref ("Luke" 2 10 11))
    ;; Epiphany
    (:text "From the rising of the sun even unto the going down of the same my Name shall be great among the Gentiles; and in every place incense shall be offered unto my Name, and a pure offering: for my Name shall be great among the heathen, saith the Lord of hosts."
     :ref ("Mal" 1 11))
    (:text "Awake, awake; put on thy strength, O Zion; put on thy beautiful garments, O Jerusalem."
     :ref ("Isa" 52 1))
    ;; Lent
    (:text "Rend your heart, and not your garments, and turn unto the Lord your God: for he is gracious and merciful, slow to anger, and of great kindness, and repenteth him of the evil."
     :ref ("Joel" 2 13))
    (:text "The sacrifices of God are a broken spirit: a broken and a contrite heart, O God, thou wilt not despise."
     :ref ("Ps" 51 17))
    ;; Printed text ends mid-v.19; strict partial verse.
    (:text "I will arise and go to my father, and will say unto him, Father, I have sinned against heaven, and before thee, and am no more worthy to be called thy son."
     :ref ("Luke" 15 18 19) :inexact t)
    ;; Passiontide
    (:text "Is it nothing to you, all ye that pass by? behold, and see if there be any sorrow like unto my sorrow which is done unto me, wherewith the Lord hath afflicted me."
     :ref ("Lam" 1 12))
    (:text "In whom we have redemption through his blood, the forgiveness of sins, according to the riches of his grace."
     :ref ("Eph" 1 7))
    ;; Easter — stitched paraphrase of Mk 16:6 + Lk 24:34; multi-ref auto-daggered.
    (:text "He is risen. The Lord is risen indeed."
     :ref (("Mark" 16 6) ("Luke" 24 34)) :inexact t)
    (:text "This is the day which the Lord hath made; we will rejoice and be glad in it."
     :ref ("Ps" 118 24))
    ;; Ascension (within Eastertide)
    (:text "Seeing that we have a great High Priest, that is passed into the heavens, Jesus the Son of God, let us come boldly unto the throne of grace, that we may obtain mercy, and find grace to help in time of need."
     :ref ("Heb" 4 14 16))
    ;; Whitsunday (within Eastertide)
    (:text "Ye shall receive power, after that the Holy Ghost is come upon you: and ye shall be witnesses unto me both in Jerusalem, and in all Judaea, and in Samaria, and unto the uttermost part of the earth."
     :ref ("Acts" 1 8))
    (:text "Because ye are sons, God hath sent forth the Spirit of his Son into your hearts, crying, Abba, Father."
     :ref ("Gal" 4 6))
    ;; Trinity
    (:text "Holy, holy, holy, Lord God Almighty, which was, and is, and is to come."
     :ref ("Rev" 4 8))
    ;; Thanksgiving Day (occasion, not a liturgical season)
    (:text "Honour the Lord with thy substance, and with the first-fruits of all thine increase: so shall thy barns be filled with plenty, and thy presses shall burst out with new wine."
     :ref ("Prov" 3 9 10))
    (:text "The Lord by wisdom hath founded the earth; by understanding hath he established the heavens. By his knowledge the depths are broken up, and the clouds drop down the dew."
     :ref ("Prov" 3 19 20)))
  "Opening sentences from the 1928 American BCP Morning Prayer.
Each entry is a plist (:text TEXT :ref REF [:inexact t]).
:inexact t marks entries whose printed text covers only part of the
cited verse(s) — the renderer appends a † to the citation label.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; 1928 opening sentences — Evening Prayer

(defconst bcp-common-anglican-opening-sentences-1928-evensong
  '(;; General — suitable at any time
    (:text "The Lord is in his holy temple: let all the earth keep silence before him."
     :ref ("Hab" 2 20))
    (:text "Lord, I have loved the habitation of thy house, and the place where thine honour dwelleth."
     :ref ("Ps" 26 8))
    (:text "Let my prayer be set forth in thy sight as the incense; and let the lifting up of my hands be an evening sacrifice."
     :ref ("Ps" 141 2))
    (:text "O worship the Lord in the beauty of holiness; let the whole earth stand in awe of him."
     :ref ("Ps" 96 9))
    (:text "Let the words of my mouth, and the meditation of my heart, be alway acceptable in thy sight, O Lord, my strength and my redeemer."
     :ref ("Ps" 19 14 15))
    ;; Advent
    (:text "Watch ye, for ye know not when the master of the house cometh, at even, or at midnight, or at the cock-crowing, or in the morning: lest coming suddenly he find you sleeping."
     :ref ("Mark" 13 35 36))
    ;; Christmas
    (:text "Behold, the tabernacle of God is with men, and he will dwell with them, and they shall be his people, and God himself shall be with them, and be their God."
     :ref ("Rev" 21 3))
    ;; Epiphany
    (:text "And the Gentiles shall come to thy light, and kings to the brightness of thy rising."
     :ref ("Isa" 60 3))
    ;; Lent
    (:text "I acknowledge my transgressions: and my sin is ever before me."
     :ref ("Ps" 51 3))
    (:text "To the Lord our God belong mercies and forgivenesses, though we have rebelled against him; neither have we obeyed the voice of the Lord our God, to walk in his laws which he set before us."
     :ref (("Dan" 9 9) ("Dan" 9 10)))
    ;; Conjoined paraphrase of vv.8-9 — see 1662 sentence note.
    (:text "If we say that we have no sin, we deceive ourselves, and the truth is not in us; but if we confess our sins, God is faithful and just to forgive us our sins, and to cleanse us from all unrighteousness."
     :ref ("1 John" 1 8 9) :inexact t)
    ;; Passiontide
    (:text "All we like sheep have gone astray; we have turned every one to his own way; and the Lord hath laid on him the iniquity of us all."
     :ref ("Isa" 53 6))
    ;; Easter
    (:text "Thanks be to God, which giveth us the victory through our Lord Jesus Christ."
     :ref ("1 Cor" 15 57))
    (:text "If ye then be risen with Christ, seek those things which are above, where Christ sitteth on the right hand of God."
     :ref ("Col" 3 1))
    ;; Ascension (within Eastertide)
    (:text "Christ is not entered into the holy places made with hands, which are the figures of the true; but into heaven itself, now to appear in the presence of God for us."
     :ref ("Heb" 9 24))
    ;; Whitsunday (within Eastertide)
    (:text "There is a river, the streams whereof shall make glad the city of God, the holy place of the tabernacles of the Most High."
     :ref ("Ps" 46 4))
    (:text "The Spirit and the bride say, Come. And let him that heareth say, Come. And let him that is athirst come. And whosoever will, let him take the water of life freely."
     :ref ("Rev" 22 17))
    ;; Trinity
    (:text "Holy, holy, holy, is the Lord of hosts: the whole earth is full of his glory."
     :ref ("Isa" 6 3)))
  "Opening sentences from the 1928 American BCP Evening Prayer.
Each entry is a plist (:text TEXT :ref REF [:inexact t]).
:inexact t marks entries whose printed text covers only part of the
cited verse(s) — the renderer appends a † to the citation label.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; General prayers  (shared across 1662 and 1928)

(defconst bcp-common-anglican-general-thanksgiving
  '(:name  general-thanksgiving
    :title "A General Thanksgiving."
    :english
    "Almighty God, Father of all mercies, we thine unworthy servants do give thee \
most humble and hearty thanks for all thy goodness and loving-kindness to us, and \
to all men; We bless thee for our creation, preservation, and all the blessings of \
this life; but above all, for thine inestimable love in the redemption of the world \
by our Lord Jesus Christ; for the means of grace, and for the hope of glory. And, \
we beseech thee, give us that due sense of all thy mercies, that our hearts may be \
unfeignedly thankful; and that we shew forth thy praise, not only with our lips, \
but in our lives, by giving up our selves to thy service, and by walking before \
thee in holiness and righteousness all our days; through Jesus Christ our Lord, to \
whom, with thee and the Holy Ghost, be all honour and glory, world without end. \
Amen.")
  "A General Thanksgiving.")

(defconst bcp-common-anglican-all-conditions
  '(:name  all-conditions
    :title "A Prayer for all Conditions of Men."
    :english
    "O God, the Creator and Preserver of all mankind, we humbly beseech thee for \
all sorts and conditions of men; that thou wouldest be pleased to make thy ways \
known unto them, thy saving health unto all nations. More especially, we pray for \
the good estate of the Catholick Church; that it may be so guided and governed by \
thy good Spirit, that all who profess and call themselves Christians may be led \
into the way of truth, and hold the faith in unity of spirit, in the bond of peace, \
and in righteousness of life. Finally, we commend to thy fatherly goodness all \
those, who are any ways afflicted, or distressed, in mind, body, or estate; \
especially those for whom our prayers are desired; that it may please thee to \
comfort and relieve them, according to their several necessities, giving them \
patience under their sufferings, and a happy issue out of all their afflictions. \
And this we beg for Jesus Christ his sake. Amen.")
  "A Prayer for all Conditions of Men.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; State prayer resolver

(defun bcp-liturgy-state-versicles (_tradition)
  "Return the versicle pair for civil authority as (VERSICLE RESPONSE).
The form is selected by `bcp-liturgy-state-versicle-form':
  `monarchy'       — \"O Lord, save the King.\" or \"…the Queen.\" per
                     `bcp-liturgy-sovereign-title'
  `state'          — \"O Lord, save the State.\" (1928 American)
  `them-that-rule' — \"O Lord, save them that rule.\" (1662 international)"
  (let ((response "And mercifully hear us when we call upon thee."))
    (pcase bcp-liturgy-state-versicle-form
      ('monarchy
       (list (if (eq bcp-liturgy-sovereign-title 'queen)
                 "O Lord, save the Queen."
               "O Lord, save the King.")
             response))
      ('state         (list "O Lord, save the State."      response))
      (_              (list "O Lord, save them that rule." response)))))

(defconst bcp-liturgy--monarchic-roles '(monarchy imperial)
  "Roles that route through the monarchic head-of-state prayer
template (`bcp-common-anglican-prayer-king' / `-queen').  Other roles
route to the generic 1928 civil-authority prayer.")

(defun bcp-liturgy--monarchic-role-p (&optional role)
  "Return non-nil if ROLE (default `bcp-head-of-state-role') is monarchic.
Includes nil (treated as legacy monarchy default)."
  (let ((r (or role bcp-head-of-state-role)))
    (or (null r)
        (memq r bcp-liturgy--monarchic-roles))))

(defun bcp-liturgy--civil-authority-prayer ()
  "Return the civil-authority prayer plist for a civil head-of-state role.
Delegates to `bcp-liturgy--head-of-state-prayer', which uses
`bcp-common-anglican-prayer-for-president' as the base template (the
named 1928 form) and substitutes title-of-country and personal name
into it — so `role=presidency name=Biden country=\"United States\"' renders
\"Grant to BIDEN, the President of the United States, …\".  When neither
title nor name is configured, that helper falls back to the truly
generic `bcp-common-anglican-prayer-civil-authority' (\"those who bear
rule over us\")."
  (bcp-liturgy--head-of-state-prayer))

(defun bcp-liturgy--sovereign-prayer ()
  "Return the head-of-state prayer plist, dispatched on role class.

Role dispatch:
- monarchy / imperial / nil (legacy default) → monarchic prayer
  (King's / Queen's Majesty) with title and name substitution.
- presidency / premiership / chancellorship / governor /
  governor-general / sovereignty / custom → generic 1928 civil-authority
  prayer with country name substitution.

This routing reflects that monarchic and civil heads of state belong
in liturgically distinct prayer templates: \"King's Majesty\" framing
fits a sovereign monarch; \"Civil Authority\" framing fits an elected
or appointed officer.  See `bcp-liturgy--monarchic-role-p'."
  (if (bcp-liturgy--monarchic-role-p)
      (bcp-liturgy--monarchic-prayer)
    (bcp-liturgy--civil-authority-prayer)))

(defun bcp-liturgy--monarchic-prayer ()
  "Return the monarchic head-of-state prayer plist with substitutions.
When `bcp-head-of-state-role' is set, derives title and possessive-form
from the registry and uses `bcp-head-of-state-name'; otherwise falls
back to legacy `bcp-liturgy-sovereign-title' and
`bcp-liturgy-sovereign-name'.

Substitutions happen in three places: the prayer's :title field
(possessive form, e.g. \"King's\" → \"Emperor's\"), the body's title
placeholder (UPPERCASE \"KING\" → \"EMPEROR\"), and the body's name
placeholder.

Under `:name-taboo' (e.g. Japanese Emperor in bungo / nskk-1959), the
name slot is replaced by a \"the {Title}\" form rather than left with
the literal placeholder name.

Substitutions are case-sensitive (`case-fold-search' bound nil) so
that body phrases like \"King of kings\" / \"Lord of lords\" are not
disturbed by a placeholder swap."
  (let* (;; Gender resolution
         (use-female-p
          (cond
           (bcp-head-of-state-role (eq bcp-head-of-state-gender 'female))
           (t (eq bcp-liturgy-sovereign-title 'queen))))
         (base-plist (if use-female-p
                         bcp-common-anglican-prayer-queen
                       bcp-common-anglican-prayer-king))
         ;; Default forms (the placeholders embedded in the BCP prayer)
         (default-title-upper (if use-female-p "QUEEN" "KING"))
         (default-title-mixed (if use-female-p "Queen" "King"))
         (default-title-poss  (if use-female-p "Queen's" "King's"))
         ;; Registry-resolved English forms (or fall back to default)
         (title-upper
          (or (and bcp-head-of-state-role
                   (let ((form (bcp-head-of-state-title-form 'english)))
                     (and form (upcase form))))
              default-title-upper))
         (title-mixed
          (or (and bcp-head-of-state-role
                   (bcp-head-of-state-title-form 'english))
              default-title-mixed))
         (title-poss
          (or (and bcp-head-of-state-role
                   (bcp-head-of-state-title-form 'english t))
              default-title-poss))
         ;; Name (unified field or legacy)
         (name (or bcp-head-of-state-name bcp-liturgy-sovereign-name))
         ;; Honour name-taboo for the active prayer language
         (taboo-p (bcp-head-of-state-name-tabooed-p))
         ;; Case-sensitive substitution — "KING" should not match "King"/"kings"
         (case-fold-search nil))
    ;; Build the substituted display title (possessive replacement)
    (let* ((display-title (plist-get base-plist :title))
           (display-title
            (if (string= title-poss default-title-poss)
                display-title
              (replace-regexp-in-string
               (regexp-quote default-title-poss) title-poss
               display-title t t)))
           ;; Build the substituted body text
           (text (plist-get base-plist :text))
           (placeholder-rx (format "%s [A-Z]+"
                                   (regexp-quote default-title-upper)))
           (text
            (cond
             ;; Taboo: drop name, render "the {Title}"
             (taboo-p
              (replace-regexp-in-string
               placeholder-rx (format "the %s" title-mixed)
               text t nil))
             ;; Title changed by role: full placeholder rewrite
             ((not (string= title-upper default-title-upper))
              (replace-regexp-in-string
               placeholder-rx
               (if name
                   (format "%s %s" title-mixed (upcase name))
                 (format "the %s" title-mixed))
               text t nil))
             ;; Default title, name supplied: classic name swap
             (name
              (replace-regexp-in-string
               placeholder-rx
               (format "%s %s" default-title-upper (upcase name))
               text t nil))
             ;; Default title, no name: leave the BCP default visible
             (t text))))
      (list :name  (plist-get base-plist :name)
            :title display-title
            :text  text))))

(defun bcp-liturgy--royal-family-prayer ()
  "Return the Royal Family prayer plist, substituting member names when configured.
If `bcp-liturgy-royal-family-names' is non-nil, it replaces the named members
in the prayer before \"and all the Royal Family\".
The substituted names are rendered in ALL-CAPS in the output."
  (if (not bcp-liturgy-royal-family-names)
      bcp-common-anglican-prayer-royal-family
    (let* ((base (plist-get bcp-common-anglican-prayer-royal-family :text))
           (text (replace-regexp-in-string
                  "to bless [^,]+\\(?:, [^,]+\\)*, and all the Royal Family"
                  (format "to bless %s, and all the Royal Family"
                          (upcase bcp-liturgy-royal-family-names))
                  base t nil)))
      (list :name  'prayer-royal-family
            :title (plist-get bcp-common-anglican-prayer-royal-family :title)
            :text  text))))

(defun bcp-liturgy--head-of-state-prayer ()
  "Return the head-of-state prayer plist for the current republic configuration.
Title resolution: when `bcp-head-of-state-role' is set, derives the
title from the registry (e.g. \"the President\", \"the Prime Minister\");
when role is `custom', uses `bcp-head-of-state-custom-title'; otherwise
falls back to `bcp-liturgy-head-of-state-title' (the legacy free-form
field).  Name resolution: `bcp-head-of-state-name' takes precedence
over the legacy `bcp-liturgy-president-name'.

When no title is configured by either path, returns the generic civil
authority prayer."
  (let* (;; Title — registry > custom > legacy free-form
         (registry-title
          (and bcp-head-of-state-role
               (not (eq bcp-head-of-state-role 'custom))
               (let ((form (bcp-head-of-state-title-form 'english)))
                 (and form (concat "the " form)))))
         (custom-title
          (and (eq bcp-head-of-state-role 'custom)
               bcp-head-of-state-custom-title))
         (title (or custom-title registry-title bcp-liturgy-head-of-state-title))
         (country bcp-liturgy-country-name)
         (name    (or bcp-head-of-state-name bcp-liturgy-president-name)))
    (if (or (null title) (string-empty-p title))
        ;; No title configured — generic civil authority prayer
        bcp-common-anglican-prayer-civil-authority
      ;; Build from the 1928 president prayer template
      (let* (;; "the President of the United States" or just "the President"
             (office-phrase (if (and country (not (string-empty-p country)))
                               (format "%s of %s" title country)
                             title))
             ;; Prayer title
             (prayer-title (format "A Prayer for %s, and all in Civil Authority."
                                   office-phrase))
             ;; Prayer text — substitute the office phrase
             (base (plist-get bcp-common-anglican-prayer-for-president :english))
             (text (replace-regexp-in-string
                    "the President of the United States"
                    office-phrase base t t))
             ;; Insert personal name if provided
             (text (if (not name)
                       text
                     (replace-regexp-in-string
                      (regexp-quote (format "Grant to %s" office-phrase))
                      (format "Grant to %s, %s" (upcase name) office-phrase)
                      text t t))))
        (list :name    'prayer-for-head-of-state
              :title   prayer-title
              :english text)))))

(defun bcp-liturgy-state-prayers (tradition)
  "Return the list of state prayer plists for the current region and TRADITION.
TRADITION is a symbol naming the prayer book (e.g. `1662', `1928') and is
used to select tradition-appropriate wording for the clergy prayer in the
monarchy case.  The active region is read from `bcp-liturgy-region'.

Regions:
  `monarchy'       — sovereign, royal family, clergy (1662 wording:
                     \"Curates\"; 1928 and later: \"other Clergy\")
  `us' / `republic' — head of state and civil authority, clergy.
                     When `bcp-liturgy-head-of-state-title' is set, names
                     the office (and country via `bcp-liturgy-country-name').
                     When nil, uses generic \"those in Civil Authority\"
                     wording.

Each returned plist has at least :title and :text (or :english) keys."
  (cond
   ((memq bcp-liturgy-region '(us republic))
    (list (bcp-liturgy--head-of-state-prayer)
          bcp-common-anglican-prayer-clergy-people-1928))
   (t  ; monarchy
    (list (bcp-liturgy--sovereign-prayer)
          (bcp-liturgy--royal-family-prayer)
          (if (eq tradition '1662)
              bcp-common-anglican-prayer-clergy-people
            bcp-common-anglican-prayer-clergy-people-1928)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Head-of-state title registry
;;
;; Per-language title forms for substitution into state prayers.  Latin
;; entries are in the ACCUSATIVE case (the most common slot in BCP-Latin
;; petition prayers — direct object of "rogamus ut … respicias /
;; benedicere").  Other cases are a TODO when a prayer slot needs them.
;;
;; Japanese forms are bare title nouns, no honorific suffix (matching the
;; 1895 NSKK convention which writes 「我らの皇太后、皇太子…」 not
;; 「皇太后陛下、皇太子殿下…」).  The prayer template handles surrounding
;; particles and honorific verb forms.

(defconst bcp-head-of-state-titles
  '((king
     :english             "King"
     :english-possessive  "King's"
     :latin               "Regem"            ; nom. Rex
     :latin-possessive    "Regis"            ; gen. for "King's Majesty"-type slots
     :bungo               "国王"
     :nskk-1959           "国王"
     :gender              male)
    (queen
     :english             "Queen"
     :english-possessive  "Queen's"
     :latin               "Reginam"          ; nom. Regina
     :latin-possessive    "Reginae"
     :bungo               "女王"
     :nskk-1959           "女王"
     :gender              female)
    (emperor
     :english             "Emperor"
     :english-possessive  "Emperor's"
     :latin               "Imperatorem"      ; nom. Imperator
     :latin-possessive    "Imperatoris"
     :bungo               "天皇"
     :nskk-1959           "天皇"
     :gender              male
     ;; Direct use of the Emperor's personal name is liturgically taboo
     ;; in Japanese; formal reference uses titles only.  Helpers honor
     ;; this by suppressing name substitution under JAP profiles when
     ;; this flag is set.
     :name-taboo          (bungo nskk-1959))
    (empress
     :english             "Empress"
     :english-possessive  "Empress's"
     :latin               "Imperatricem"     ; nom. Imperatrix
     :latin-possessive    "Imperatricis"
     :bungo               "女帝"              ; regnant; consort = 皇后 (kōgō)
     :nskk-1959           "女帝"
     :gender              female
     :name-taboo          (bungo nskk-1959))
    (president
     :english             "President"
     :english-possessive  "President's"
     :latin               "Praesidem"        ; nom. Praeses
     :latin-possessive    "Praesidis"
     :bungo               "大統領"
     :nskk-1959           "大統領"
     :gender              any)
    (prime-minister
     :english             "Prime Minister"
     :english-possessive  "Prime Minister's"
     :latin               "Primum Ministrum" ; nom. Primus Minister
     :latin-possessive    "Primi Ministri"
     :bungo               "総理大臣"
     :nskk-1959           "総理大臣"
     :gender              any)
    (chancellor
     :english             "Chancellor"
     :english-possessive  "Chancellor's"
     :latin               "Cancellarium"     ; nom. Cancellarius
     :latin-possessive    "Cancellarii"
     :bungo               "首相"
     :nskk-1959           "首相"
     :gender              any)
    (governor
     :english             "Governor"
     :english-possessive  "Governor's"
     :latin               "Praefectum"       ; nom. Praefectus
     :latin-possessive    "Praefecti"
     :bungo               "知事"
     :nskk-1959           "知事"
     :gender              any)
    (governor-general
     :english             "Governor-General"
     :english-possessive  "Governor-General's"
     :latin               "Praefectum Generalem"
     :latin-possessive    "Praefecti Generalis"
     :bungo               "総督"
     :nskk-1959           "総督"
     :gender              any)
    (sovereign
     :english             "Sovereign"
     :english-possessive  "Sovereign's"
     :latin               "Principem"        ; nom. Princeps
     :latin-possessive    "Principis"
     :bungo               "主権者"
     :nskk-1959           "主権者"
     :gender              any))
  "Per-language head-of-state title forms.
Each entry: (KEY :english S :english-possessive S :latin S
:latin-possessive S :bungo S :nskk-1959 S :gender G [:name-taboo
LIST]).

Latin forms are ACCUSATIVE (most common slot in BCP petition prayers);
:latin-possessive supplies the GENITIVE form for \"King's Majesty\"-type
slots.  Japanese possessive is just suffix の in the template.
Japanese forms are bare title nouns — honorifics belong in the prayer
template.  Gender axis: `male', `female', or `any'.

:name-taboo, when present, lists languages (e.g. `(bungo nskk-1959)')
in which the personal name is liturgically not used; helpers suppress
name substitution accordingly (used for `emperor' and `empress' in
Japanese).")

(defconst bcp-head-of-state-roles
  '((monarchy   :male king     :female queen)
    (imperial   :male emperor  :female empress)
    (presidency :any  president)
    (premiership :any prime-minister)
    (chancellorship :any chancellor)
    (governor-generalship :any governor-general)
    (sovereignty :any sovereign))
  "Map from abstract role to gender-keyed title entries.
A role like `monarchy' carries `:male king' / `:female queen'; the user
picks the role + gender, and the resolver looks up the appropriate
entry in `bcp-head-of-state-titles'.  `:any' means the role is
gender-neutral (one entry serves both).")

(defcustom bcp-head-of-state-role nil
  "Active head-of-state role.
Symbol from `bcp-head-of-state-roles' (`monarchy', `imperial',
`presidency', etc.) or `custom' to use `bcp-head-of-state-custom-title'
as a free-form override string.  When nil, falls back to legacy
behavior (sovereign-title for monarchy, head-of-state-title string for
republic)."
  :type  '(choice (const :tag "(use legacy controls)" nil)
                  (const monarchy)
                  (const imperial)
                  (const presidency)
                  (const premiership)
                  (const chancellorship)
                  (const governor-generalship)
                  (const sovereignty)
                  (const :tag "Custom string" custom))
  :group 'bcp-liturgy)

(defcustom bcp-head-of-state-gender 'male
  "Gender axis for the active head-of-state role.
Only consulted for gendered roles (monarchy, imperial); ignored for
gender-neutral roles."
  :type  '(choice (const male) (const female))
  :group 'bcp-liturgy)

(defcustom bcp-head-of-state-custom-title nil
  "Free-form title string used when `bcp-head-of-state-role' is `custom'.
Inserted literally into the prayer-language regardless of grammatical
register; multilingual substitution is not performed for custom titles.
Use a registered role wherever possible for proper Latin and Japanese
forms."
  :type  '(choice (const :tag "(none)" nil) string)
  :group 'bcp-liturgy)

(defcustom bcp-head-of-state-name nil
  "Personal name of the active head of state.
When `bcp-head-of-state-role' is set, this name is substituted into
state prayers (rendered uppercase per BCP convention).  When nil, the
legacy fields are consulted: `bcp-liturgy-sovereign-name' (monarchy)
or `bcp-liturgy-president-name' (republic)."
  :type  '(choice (const :tag "(use legacy / defconst)" nil) string)
  :group 'bcp-liturgy)

(defun bcp-head-of-state-entry-key (&optional role gender)
  "Resolve (ROLE × GENDER) to a title-registry key, or nil.
Defaults to `bcp-head-of-state-role' / `bcp-head-of-state-gender'."
  (let* ((r        (or role gender bcp-head-of-state-role))
         (r        (or role bcp-head-of-state-role))
         (g        (or gender bcp-head-of-state-gender))
         (role-pl  (cdr (assq r bcp-head-of-state-roles))))
    (when role-pl
      (or (plist-get role-pl (intern (format ":%s" g)))
          (plist-get role-pl :any)))))

(defun bcp-head-of-state-title-form (&optional language possessive-p)
  "Return the head-of-state title in LANGUAGE.
LANGUAGE defaults to the current `bcp-common-prayers-language';
POSSESSIVE-P, if non-nil, requests the possessive/genitive form
(English \"King's\", Latin genitive \"Regis\", etc.); Japanese languages
ignore POSSESSIVE-P (template handles の).

Resolution order: custom string (role = `custom') → registered entry
under (role × gender) → nil."
  (let ((lang (or language
                  (and (boundp 'bcp-common-prayers-language)
                       bcp-common-prayers-language)
                  'english)))
    (cond
     ((eq bcp-head-of-state-role 'custom)
      bcp-head-of-state-custom-title)
     (bcp-head-of-state-role
      (let* ((key   (bcp-head-of-state-entry-key))
             (entry (cdr (assq key bcp-head-of-state-titles)))
             (poss-key (intern (format ":%s-possessive" lang)))
             (base-key (intern (format ":%s" lang))))
        (and entry
             (or (and possessive-p (plist-get entry poss-key))
                 (plist-get entry base-key)
                 (and possessive-p (plist-get entry :english-possessive))
                 (plist-get entry :english)))))
     (t nil))))

(defun bcp-head-of-state-name-tabooed-p (&optional language)
  "Return non-nil if the active title's :name-taboo covers LANGUAGE.
LANGUAGE defaults to the current `bcp-common-prayers-language'.
Used to suppress personal-name substitution where direct naming is
liturgically inappropriate (e.g. the Japanese Emperor)."
  (let ((lang (or language
                  (and (boundp 'bcp-common-prayers-language)
                       bcp-common-prayers-language))))
    (when (and lang bcp-head-of-state-role
               (not (eq bcp-head-of-state-role 'custom)))
      (let* ((key   (bcp-head-of-state-entry-key))
             (entry (cdr (assq key bcp-head-of-state-titles)))
             (taboo (plist-get entry :name-taboo)))
        (and taboo (memq lang taboo))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; State-set bundles
;;
;; A "state-set" bundles the suffrages-tail state-versicle and the discrete
;; state-prayer slot for a given liturgical/regional context.  Each ordo
;; declares its rubric default state-set in its build-ctx; users can override
;; per language via `bcp-state-set-override-by-language'.
;;
;; Each entry's :prayers is a list of symbols.  At render time, function
;; symbols are called (for name-substituting forms like the sovereign and
;; royal-family prayers); variable symbols are dereferenced for their plist
;; (for fixed forms like Clergy and People).

(defconst bcp-state-sets
  '((uk-monarchy-1662
     :name     "UK Monarchy (1662 — Curates)"
     :versicle save-the-king
     :prayers  (bcp-liturgy--sovereign-prayer
                bcp-liturgy--royal-family-prayer
                bcp-common-anglican-prayer-clergy-people)
     :role     monarchy)
    (uk-monarchy-1928
     :name     "UK Monarchy (1928 form — other Clergy)"
     :versicle save-the-king
     :prayers  (bcp-liturgy--sovereign-prayer
                bcp-liturgy--royal-family-prayer
                bcp-common-anglican-prayer-clergy-people-1928)
     :role     monarchy)
    (us-1928
     :name     "United States (1928 BCP)"
     :versicle save-the-state
     :prayers  (bcp-liturgy--head-of-state-prayer
                bcp-common-anglican-prayer-clergy-people-1928)
     :role     presidency)
    (us-civil-authority
     :name     "United States — Civil Authority (generic republic)"
     :versicle save-them-that-rule
     :prayers  (bcp-common-anglican-prayer-civil-authority
                bcp-common-anglican-prayer-clergy-people-1928)
     :role     nil)
    (japan-imperial-1895
     :name     "Japan — Imperial Family (1895 NSKK)"
     ;; Reuses the save-the-king versicle key; under :bungo the
     ;; localizer surfaces the imperial form 「主よ。わが天皇を救ひたまへ」.
     :versicle save-the-king
     :prayers  (bcp-common-anglican-prayer-imperial-family)
     :role     imperial)
    (none
     :name     "(no state prayers / suppress slot)"
     :versicle nil
     :prayers  nil
     :role     nil))
  "Named bundles of state-versicle + state-prayer-list.
Each entry is (NAME . PLIST) where PLIST has :name (display string),
:versicle (key into `bcp-anglican-versicles--entries' or nil to suppress),
and :prayers (a list of symbols, each either a defun returning a prayer
plist or a defvar/defconst whose value is a prayer plist).")

(defcustom bcp-state-set-override-by-language nil
  "Alist mapping language symbols to state-set names overriding the rubric.
Keys are language symbols (`english', `latin', `bungo', `nskk-1959').
Values are state-set names from `bcp-state-sets', or nil to follow the
active ordo's rubric default.  Languages not listed default to the
rubric.  Set entries via the state-prayer subtransient or directly.

Example:
  ((bungo . japan-imperial-1895))
"
  :type  '(alist :key-type symbol :value-type symbol)
  :group 'bcp-liturgy)

(defun bcp-state-set-data (name)
  "Return the plist for state-set NAME, or nil."
  (cdr (assq name bcp-state-sets)))

(defun bcp-state-set-active (rubric-default)
  "Resolve the active state-set name.
Walks `bcp-state-set-override-by-language' (keyed by current
`bcp-common-prayers-language'); if no override is set for the active
language, returns RUBRIC-DEFAULT (the symbol the active ordo declares
in its build-ctx)."
  (let ((lang (and (boundp 'bcp-common-prayers-language)
                   bcp-common-prayers-language)))
    (or (and lang (cdr (assq lang bcp-state-set-override-by-language)))
        rubric-default
        'none)))

(defconst bcp-state-set--monarchic-only-prayers
  '(bcp-liturgy--royal-family-prayer)
  "Prayer helpers that are monarchic-only and should be suppressed
when the active head-of-state role is non-monarchic.  The
state-prayer-slot helper itself (`bcp-liturgy--sovereign-prayer') is
polymorphic — it dispatches on role internally — so it is NOT in
this list.  Clergy/people prayers are shared across both monarchic
and civil contexts and likewise stay.")

(defun bcp-state-set--resolve-prayer (sym)
  "Resolve a state-set prayer SYMBOL to its plist.
Function symbols are called (for name-substituting prayer helpers like
`bcp-liturgy--sovereign-prayer'); variable symbols are dereferenced.
Returns nil when SYM is in `bcp-state-set--monarchic-only-prayers' and
the active role is non-monarchic — so e.g. `prayer-royal-family' is
silently suppressed under role=presidency."
  (cond
   ((and (memq sym bcp-state-set--monarchic-only-prayers)
         (not (bcp-liturgy--monarchic-role-p)))
    nil)
   ((functionp sym) (funcall sym))
   ((boundp sym)    (symbol-value sym))
   (t nil)))

(defun bcp-state-set-prayers (set-name)
  "Return the resolved list of prayer plists for state-set SET-NAME.
The state-set's `:role' is dynamically bound to `bcp-head-of-state-role'
during prayer resolution so helpers (sovereign-prayer, head-of-state-prayer)
pick up the role naturally — unless the user has already set
`bcp-head-of-state-role' explicitly, in which case the explicit
override wins."
  (let* ((data (bcp-state-set-data set-name))
         (set-role (plist-get data :role))
         ;; Honour explicit user override; otherwise derive from state-set.
         (bcp-head-of-state-role (or bcp-head-of-state-role set-role)))
    (when data
      (delq nil (mapcar #'bcp-state-set--resolve-prayer
                        (plist-get data :prayers))))))

(defun bcp-state-set-versicle-key (set-name)
  "Return the versicle entry key for state-set SET-NAME, or nil."
  (plist-get (bcp-state-set-data set-name) :versicle))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Shared Venite helpers

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Preces versicles

;; Scripture provenance:
;;   "The Lord be with you" — Ruth 2:4 (Boaz' greeting), 2 Thess 3:16
;;       (composite/composition); a primitive liturgical exchange,
;;       not a substitutable verse.
;;   "And with thy spirit" — 2 Tim 4:22 ("the Lord Jesus Christ
;;       be with thy spirit"), but the liturgical form pre-dates and
;;       echoes that verse rather than quoting it.
(defconst bcp-common-anglican-preces-lord-be-with-you
  '(("The Lord be with you." "And with thy spirit."))
  "Greeting versicle pair for a priest or bishop officiant.
The bidding \"Let us pray.\" follows on its own line and is emitted
by the caller via `bcp-liturgy-render--insert-oremus'.")

;; Scripture provenance: Ps 102:1 (Coverdale, verbatim).  Substituted for
;; the dominus-vobiscum greeting when the officiant lacks priestly orders.
(defconst bcp-common-anglican-preces-lay
  '(("Hear my prayer, O Lord." "And let my cry come unto thee."))
  "Greeting versicle pair substituted when the officiant is a layperson or deacon.
The bidding \"Let us pray.\" follows on its own line and is emitted
by the caller via `bcp-liturgy-render--insert-oremus'.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Venite

(defconst bcp-common-anglican-ps96-venite-substitute
  "O worship the Lord in the beauty of holiness;\
 let the whole earth stand in awe of him.\n\
For he cometh, for he cometh to judge the earth;\
 and with righteousness to judge the world,\
 and the people with his truth."
  "Psalm 96 verses 9 and 13 in Coverdale's translation.
Used by the 1928 American BCP in place of Venite vv.8–11 when those
verses are omitted outside of Lent.")

(defun bcp-anglican--venite-strip-verses-8-11 (text)
  "Return TEXT with Venite verses 8–11 removed.
Verses 8–11 begin with \"To day if ye will hear\" and end before verse 12
\"Unto whom I sware\".  Returns TEXT unchanged if the markers are not found."
  (if (null text) nil
    (let ((start (string-match "To day if ye will hear" text)))
      (if (null start)
          text
        (let ((end (string-match "Unto whom I sware" text start)))
          (if (null end)
              text
            (concat (substring text 0 start)
                    (substring text end))))))))

(defun bcp-anglican--venite-filter (text season verses-setting substitute-p)
  "Apply Venite vv.8–11 handling to TEXT according to VERSES-SETTING and SEASON.
VERSES-SETTING is the value of a tradition's venite-lent-verses defcustom:
  `always' — retain vv.8–11 in all seasons
  `lent'   — retain in Lent and Passiontide; strip otherwise
  `never'  — always strip vv.8–11
When SUBSTITUTE-P is non-nil and vv.8–11 are stripped, verses from Psalm 96
\(vv.9 and 13 in Coverdale's translation) are inserted in their place,
per the 1928 American BCP rubric."
  (let ((strip-p (pcase verses-setting
                   ('always nil)
                   ('lent   (not (memq season '(lent passiontide))))
                   (_       t))))
    (if (not strip-p)
        text
      (if (not substitute-p)
          (bcp-anglican--venite-strip-verses-8-11 text)
        ;; 1928 BCP rubric: substitute Ps.96:9,13 for the omitted verses.
        ;; The strip function removes from "To day if ye will hear" up to
        ;; "Unto whom I sware"; the Ps.96 text is spliced in at that point.
        (let ((start (string-match "To day if ye will hear" text)))
          (if (null start)
              text
            (let ((end (string-match "Unto whom I sware" text start)))
              (if (null end)
                  text
                (concat (substring text 0 start)
                        bcp-common-anglican-ps96-venite-substitute
                        "\n"
                        (substring text end))))))))))

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Seasonal invitatory antiphons (1928 American BCP)
;;;; ══════════════════════════════════════════════════════════════════════════

;; Invitatory sentences appointed in the 1928 BCP rubric before the Venite.
;; Each sentence is said or sung by the officiant (or choir) before the Venite
;; is intoned.  The rubric lists nine occasions; ordinary days have none.

(defconst bcp-common-anglican-invitatory-advent-sundays
  "Our King and Saviour draweth nigh : O come, let us adore him."
  "Invitatory antiphon for the four Sundays in Advent (1928 American BCP).")

(defconst bcp-common-anglican-invitatory-christmas
  "Alleluia. Unto us a child is born : O come, let us adore him."
  "Invitatory antiphon from Christmas Day until the Epiphany (1928 American BCP).")

(defconst bcp-common-anglican-invitatory-epiphany
  "The Lord hath manifested forth his glory : O come, let us adore him."
  "Invitatory antiphon for the Epiphany octave (Jan 6–13) and the
Transfiguration (1928 American BCP).")

(defconst bcp-common-anglican-invitatory-easter
  "Alleluia. The Lord is risen indeed : O come, let us adore him. Alleluia."
  "Invitatory antiphon from Monday in Easter Week until Ascension Day (1928
American BCP).  Easter Day itself uses the Easter Anthems instead of the Venite.")

(defconst bcp-common-anglican-invitatory-ascension
  "Alleluia. Christ the Lord ascended into heaven : O come, let us adore him. Alleluia."
  "Invitatory antiphon from Ascension Day until Whitsunday (1928 American BCP).")

(defconst bcp-common-anglican-invitatory-whitsun
  "Alleluia. The Spirit of the Lord filleth the world : O come, let us adore him. Alleluia."
  "Invitatory antiphon for Whitsunday and the six days following (1928 American BCP).")

(defconst bcp-common-anglican-invitatory-trinity
  "Father, Son, and Holy Ghost, One God : O come, let us adore him."
  "Invitatory antiphon for Trinity Sunday (1928 American BCP).")

(defconst bcp-common-anglican-invitatory-incarnation
  "The Word was made flesh : O come, let us adore him."
  "Invitatory antiphon for the Purification and the Annunciation (1928 American BCP).")

(defconst bcp-common-anglican-invitatory-saints
  "The Lord is glorious in his saints : O come, let us adore him."
  "Invitatory antiphon for other festivals with a proper Epistle and Gospel (1928
American BCP).  Used when no more specific invitatory is appointed.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Penitential form registration
;;
;; Register Anglican confession/absolution forms so that the Roman Office
;; (and any future cross-tradition rendering) can swap them in.

(bcp-penitential-register
 'anglican-1662
 '(:confession
   "Almighty and most merciful Father; We have erred, and strayed from thy ways like lost sheep. We have followed too much the devices and desires of our own hearts. We have offended against thy holy laws. We have left undone those things which we ought to have done; And we have done those things which we ought not to have done; And there is no health in us. But thou, O Lord, have mercy upon us, miserable offenders. Spare thou them, O God, which confess their faults. Restore thou them that are penitent; According to thy promises declared unto mankind in Christ Jesu our Lord. And grant, O most merciful Father, for his sake; That we may hereafter live a godly, righteous, and sober life, To the glory of thy holy Name. Amen."
   :absolution
   "Almighty God, the Father of our Lord Jesus Christ, who desireth not the death of a sinner, but rather that he may turn from his wickedness, and live; and hath given power, and commandment, to his Ministers, to declare and pronounce to his people, being penitent, the Absolution and Remission of their sins: He pardoneth and absolveth all them that truly repent, and unfeignedly believe his holy Gospel. Wherefore let us beseech him to grant us true repentance, and his Holy Spirit, that those things may please him, which we do at this present; and that the rest of our life hereafter may be pure, and holy; so that at the last we may come to his eternal joy; through Jesus Christ our Lord."
   :rubric "A general Confession to be said of the whole Congregation after the Minister, all kneeling."))

(bcp-penitential-register
 'anglican-1662-lay
 '(:confession
   "Almighty and most merciful Father; We have erred, and strayed from thy ways like lost sheep. We have followed too much the devices and desires of our own hearts. We have offended against thy holy laws. We have left undone those things which we ought to have done; And we have done those things which we ought not to have done; And there is no health in us. But thou, O Lord, have mercy upon us, miserable offenders. Spare thou them, O God, which confess their faults. Restore thou them that are penitent; According to thy promises declared unto mankind in Christ Jesu our Lord. And grant, O most merciful Father, for his sake; That we may hereafter live a godly, righteous, and sober life, To the glory of thy holy Name. Amen."
   :absolution
   "GRANT, we beseech thee, merciful Lord, to thy faithful people pardon and peace, that they may be cleansed from all their sins, and serve thee with a quiet mind; through Jesus Christ our Lord. Amen."
   :rubric "If no priest be present the person saying the service shall read the Collect for the Twenty-First Sunday after Trinity."))

(bcp-penitential-register
 'anglican-1928
 '(:confession
   "Almighty and most merciful Father; We have erred, and strayed from thy ways like lost sheep. We have followed too much the devices and desires of our own hearts. We have offended against thy holy laws. We have left undone those things which we ought to have done; And we have done those things which we ought not to have done; And there is no health in us. But thou, O Lord, have mercy upon us, miserable offenders. Spare thou those, O God, who confess their faults. Restore thou those who are penitent; According to thy promises declared unto mankind in Christ Jesus our Lord. And grant, O most merciful Father, for his sake; That we may hereafter live a godly, righteous, and sober life, To the glory of thy holy Name. Amen."
   :absolution
   "Almighty God, the Father of our Lord Jesus Christ, who desireth not the death of a sinner, but rather that he may turn from his wickedness, and live; and hath given power, and commandment, to his Ministers, to declare and pronounce to his people, being penitent, the Absolution and Remission of their sins: He pardoneth and absolveth all those who truly repent, and unfeignedly believe his holy Gospel. Wherefore let us beseech him to grant us true repentance, and his Holy Spirit, that those things may please him, which we do at this present; and that the rest of our life hereafter may be pure, and holy; so that at the last we may come to his eternal joy; through Jesus Christ our Lord."
   :rubric "Then shall be said by the Minister and people, all kneeling."))

(provide 'bcp-common-anglican)
;;; bcp-common-anglican.el ends here
