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
;;;; Fixed office collects  (shared across 1662 and 1928)

(defconst bcp-common-anglican-collect-morning-peace
  '(:name  collect-morning-peace
    :title "The second Collect, for Peace."
    :english
    "O God, who art the author of peace and lover of concord, in knowledge of \
whom standeth our eternal life, whose service is perfect freedom; Defend us thy \
humble servants in all assaults of our enemies; that we, surely trusting in thy \
defence, may not fear the power of any adversaries, through the might of Jesus \
Christ our Lord. Amen.")
  "Morning Prayer: Collect for Peace.")

(defconst bcp-common-anglican-collect-morning-grace
  '(:name  collect-morning-grace
    :title "The third Collect, for Grace."
    :english
    "O Lord, our heavenly Father, Almighty and everlasting God, who hast safely \
brought us to the beginning of this day; Defend us in the same with thy mighty \
power; and grant that this day we fall into no sin, neither run into any kind of \
danger; but that all our doings may be ordered by thy governance, to do always \
that is righteous in thy sight; through Jesus Christ our Lord. Amen.")
  "Morning Prayer: Collect for Grace.")

(defconst bcp-common-anglican-collect-evening-peace
  '(:name  collect-evening-peace
    :title "The Second Collect at Evening Prayer."
    :english
    "O God, from whom all holy desires, all good counsels, and all just works do \
proceed; Give unto thy servants that peace which the world cannot give; that both \
our hearts may be set to obey thy commandments, and also that by thee, we, being \
defended from the fear of our enemies, may pass our time in rest and quietness; \
through the merits of Jesus Christ our Saviour. Amen.")
  "Evening Prayer: Collect for Peace.")

(defconst bcp-common-anglican-collect-evening-perils
  '(:name  collect-evening-perils
    :title "The Third Collect, for Aid against all Perils."
    :english
    "Lighten our darkness, we beseech thee, O Lord; and by thy great mercy defend \
us from all perils and dangers of this night; for the love of thy only Son, our \
Saviour, Jesus Christ. Amen.")
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
our most gracious Sovereign Lord, King CHARLES; and so replenish him with the \
grace of thy Holy Spirit, that he may always incline to thy will, and walk in \
thy way. Endue him plenteously with heavenly gifts; grant him in health and wealth \
long to live; strengthen him that he may vanquish and overcome all his enemies; \
and finally, after this life, he may attain everlasting joy and felicity; through \
Jesus Christ our Lord. Amen.")
  "A Prayer for the King's Majesty (current sovereign: Charles III).
Update the sovereign's name when the crown passes.")

(defconst bcp-common-anglican-prayer-royal-family
  '(:name  prayer-royal-family
    :title "A Prayer for the Royal Family."
    :text  "Almighty God, the fountain of all goodness, we humbly beseech thee \
to bless Queen Camilla, William Prince of Wales, the Princess of Wales, and all \
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
    ("The Lord is in his holy temple: let all the earth keep silence before him."
     ("Hab" 2 20))
    ("I was glad when they said unto me, We will go into the house of the Lord."
     ("Ps" 122 1))
    ("Let the words of my mouth, and the meditation of my heart, be alway acceptable in thy sight, O Lord, my strength and my redeemer."
     ("Ps" 19 14))
    ("O send out thy light and thy truth, that they may lead me, and bring me unto thy holy hill, and to thy dwelling."
     ("Ps" 43 3))
    ("Thus saith the high and lofty One that inhabiteth eternity, whose name is Holy; I dwell in the high and holy place, with him also that is of a contrite and humble spirit, to revive the spirit of the humble, and to revive the heart of the contrite ones."
     ("Isa" 57 15))
    ("The hour cometh, and now is, when the true worshippers shall worship the Father in spirit and in truth: for the Father seeketh such to worship him."
     ("John" 4 23))
    ("Grace be unto you, and peace, from God our Father, and from the Lord Jesus Christ."
     ("Phil" 1 2))
    ;; Advent
    ("Repent ye, for the Kingdom of heaven is at hand."
     ("Matt" 3 2))
    ("Prepare ye the way of the Lord, make straight in the desert a highway for our God."
     ("Isa" 40 3))
    ;; Christmas
    ("Behold, I bring you good tidings of great joy, which shall be to all people. For unto you is born this day in the city of David a Saviour, which is Christ the Lord."
     ("Luke" 2 10 11))
    ;; Epiphany
    ("From the rising of the sun even unto the going down of the same my Name shall be great among the Gentiles; and in every place incense shall be offered unto my Name, and a pure offering: for my Name shall be great among the heathen, saith the Lord of hosts."
     ("Mal" 1 11))
    ("Awake, awake; put on thy strength, O Zion; put on thy beautiful garments, O Jerusalem."
     ("Isa" 52 1))
    ;; Lent
    ("Rend your heart, and not your garments, and turn unto the Lord your God: for he is gracious and merciful, slow to anger, and of great kindness, and repenteth him of the evil."
     ("Joel" 2 13))
    ("The sacrifices of God are a broken spirit: a broken and a contrite heart, O God, thou wilt not despise."
     ("Ps" 51 17))
    ("I will arise and go to my father, and will say unto him, Father, I have sinned against heaven, and before thee, and am no more worthy to be called thy son."
     ("Luke" 15 18 19))
    ;; Passiontide
    ("Is it nothing to you, all ye that pass by? behold, and see if there be any sorrow like unto my sorrow which is done unto me, wherewith the Lord hath afflicted me."
     ("Lam" 1 12))
    ("In whom we have redemption through his blood, the forgiveness of sins, according to the riches of his grace."
     ("Eph" 1 7))
    ;; Easter
    ("He is risen. The Lord is risen indeed."
     (("Mark" 16 6) ("Luke" 24 34)))
    ("This is the day which the Lord hath made; we will rejoice and be glad in it."
     ("Ps" 118 24))
    ;; Ascension (within Eastertide)
    ("Seeing that we have a great High Priest, that is passed into the heavens, Jesus the Son of God, let us come boldly unto the throne of grace, that we may obtain mercy, and find grace to help in time of need."
     ("Heb" 4 14 16))
    ;; Whitsunday (within Eastertide)
    ("Ye shall receive power, after that the Holy Ghost is come upon you: and ye shall be witnesses unto me both in Jerusalem, and in all Judaea, and in Samaria, and unto the uttermost part of the earth."
     ("Acts" 1 8))
    ("Because ye are sons, God hath sent forth the Spirit of his Son into your hearts, crying, Abba, Father."
     ("Gal" 4 6))
    ;; Trinity
    ("Holy, holy, holy, Lord God Almighty, which was, and is, and is to come."
     ("Rev" 4 8))
    ;; Thanksgiving Day (occasion, not a liturgical season)
    ("Honour the Lord with thy substance, and with the first-fruits of all thine increase: so shall thy barns be filled with plenty, and thy presses shall burst out with new wine."
     ("Prov" 3 9 10))
    ("The Lord by wisdom hath founded the earth; by understanding hath he established the heavens. By his knowledge the depths are broken up, and the clouds drop down the dew."
     ("Prov" 3 19 20)))
  "Opening sentences from the 1928 American BCP Morning Prayer.
Each entry: (TEXT CITATION) where CITATION is a lesson ref or list of refs.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; 1928 opening sentences — Evening Prayer

(defconst bcp-common-anglican-opening-sentences-1928-evensong
  '(;; General — suitable at any time
    ("The Lord is in his holy temple: let all the earth keep silence before him."
     ("Hab" 2 20))
    ("Lord, I have loved the habitation of thy house, and the place where thine honour dwelleth."
     ("Ps" 26 8))
    ("Let my prayer be set forth in thy sight as the incense; and let the lifting up of my hands be an evening sacrifice."
     ("Ps" 141 2))
    ("O worship the Lord in the beauty of holiness; let the whole earth stand in awe of him."
     ("Ps" 96 9))
    ("Let the words of my mouth, and the meditation of my heart, be alway acceptable in thy sight, O Lord, my strength and my redeemer."
     ("Ps" 19 14 15))
    ;; Advent
    ("Watch ye, for ye know not when the master of the house cometh, at even, or at midnight, or at the cock-crowing, or in the morning: lest coming suddenly he find you sleeping."
     ("Mark" 13 35 36))
    ;; Christmas
    ("Behold, the tabernacle of God is with men, and he will dwell with them, and they shall be his people, and God himself shall be with them, and be their God."
     ("Rev" 21 3))
    ;; Epiphany
    ("And the Gentiles shall come to thy light, and kings to the brightness of thy rising."
     ("Isa" 60 3))
    ;; Lent
    ("I acknowledge my transgressions: and my sin is ever before me."
     ("Ps" 51 3))
    ("To the Lord our God belong mercies and forgivenesses, though we have rebelled against him; neither have we obeyed the voice of the Lord our God, to walk in his laws which he set before us."
     (("Dan" 9 9) ("Dan" 9 10)))
    ("If we say that we have no sin, we deceive ourselves, and the truth is not in us; but if we confess our sins, God is faithful and just to forgive us our sins, and to cleanse us from all unrighteousness."
     ("1 John" 1 8 9))
    ;; Passiontide
    ("All we like sheep have gone astray; we have turned every one to his own way; and the Lord hath laid on him the iniquity of us all."
     ("Isa" 53 6))
    ;; Easter
    ("Thanks be to God, which giveth us the victory through our Lord Jesus Christ."
     ("1 Cor" 15 57))
    ("If ye then be risen with Christ, seek those things which are above, where Christ sitteth on the right hand of God."
     ("Col" 3 1))
    ;; Ascension (within Eastertide)
    ("Christ is not entered into the holy places made with hands, which are the figures of the true; but into heaven itself, now to appear in the presence of God for us."
     ("Heb" 9 24))
    ;; Whitsunday (within Eastertide)
    ("There is a river, the streams whereof shall make glad the city of God, the holy place of the tabernacles of the Most High."
     ("Ps" 46 4))
    ("The Spirit and the bride say, Come. And let him that heareth say, Come. And let him that is athirst come. And whosoever will, let him take the water of life freely."
     ("Rev" 22 17))
    ;; Trinity
    ("Holy, holy, holy, is the Lord of hosts: the whole earth is full of his glory."
     ("Isa" 6 3)))
  "Opening sentences from the 1928 American BCP Evening Prayer.
Each entry: (TEXT CITATION) where CITATION is a lesson ref or list of refs.")

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

(defun bcp-liturgy-state-versicles (tradition)
  "Return the versicle pair for civil authority as (VERSICLE RESPONSE).
Adapts to the current region and TRADITION:
  monarchy           — \"O Lord, save the King.\" (all traditions)
  republic/us + 1662 — \"O Lord, save them that rule.\" (1662 International)
  republic/us + 1928 — \"O Lord, save those who govern us.\" (1928 American)"
  (let ((response "And mercifully hear us when we call upon thee."))
    (cond
     ((eq bcp-liturgy-region 'monarchy)
      (list "O Lord, save the King." response))
     ((eq tradition '1928)
      (list "O Lord, save those who govern us." response))
     (t  ; 1662 and other traditions in a republic
      (list "O Lord, save them that rule." response)))))

(defun bcp-liturgy-state-prayers (tradition)
  "Return the list of state prayer plists for the current region and TRADITION.
TRADITION is a symbol naming the prayer book (e.g. `1662', `1928') and is
used to select tradition-appropriate wording for the clergy prayer in the
monarchy case.  The active region is read from `bcp-liturgy-region'.

Regions:
  `monarchy' — sovereign, royal family, clergy (1662 wording: \"Curates\";
               1928 and later: \"other Clergy\")
  `us'       — President, clergy (1928 American BCP form for both)
  `republic' — civil authority, clergy (generic; no specific office or nation)

Each returned plist has at least :title and :text (or :english) keys."
  (cond
   ((eq bcp-liturgy-region 'us)
    (list bcp-common-anglican-prayer-for-president
          bcp-common-anglican-prayer-clergy-people-1928))
   ((eq bcp-liturgy-region 'republic)
    (list bcp-common-anglican-prayer-civil-authority
          bcp-common-anglican-prayer-clergy-people-1928))
   (t  ; monarchy
    (list bcp-common-anglican-prayer-king
          bcp-common-anglican-prayer-royal-family
          (if (eq tradition '1662)
              bcp-common-anglican-prayer-clergy-people
            bcp-common-anglican-prayer-clergy-people-1928)))))

(provide 'bcp-common-anglican)
;;; bcp-common-anglican.el ends here
