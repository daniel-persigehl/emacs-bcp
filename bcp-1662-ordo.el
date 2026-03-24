;;; bcp-1662-ordo.el --- 1662 BCP Daily Office ordo -*- lexical-binding: t -*-

;; Author: You
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1") (bcp-1662-lectionary "0.1.0"))
;; Keywords: bible, bcp, daily-office, liturgy, 1662

;;; Commentary:

;; The ordo (order of service) for Morning and Evening Prayer from
;; the 1662 Book of Common Prayer.  "Do the red, say the black."
;;
;; Structure of each step:
;;
;;   (:rubric TEXT)
;;     — a rubric (direction); would be printed in red
;;
;;   (:text NAME TEXT)
;;     — a fixed spoken or said text, identified by name
;;
;;   (:versicles (VERSICLE RESPONSE) ...)
;;     — one or more versicle/response pairs
;;
;;   (:kyrie)
;;     — the Kyrie (Lord have mercy / Christ have mercy / Lord have mercy)
;;
;;   (:canticle NAME :ref REF :rubric TEXT)
;;     — a canticle identified by name, with its scriptural reference
;;       and any governing rubric; text kept elsewhere
;;
;;   (:alternatives CANTICLE-A CANTICLE-B :rubric TEXT)
;;     — two canticles between which the rubric prescribes a choice
;;
;;   (:lesson SLOT :rubric TEXT)
;;     — a lesson slot; SLOT is 'first or 'second
;;       filled from bcp-1662-lectionary at runtime
;;
;;   (:psalm SLOT :rubric TEXT)
;;     — the psalm slot; filled from bcp-office psalm cycle at runtime
;;
;;   (:collect WHICH :rubric TEXT)
;;     — a collect; WHICH is 'day (variable), or a keyword naming a
;;       fixed collect
;;
;;   (:prayer NAME TEXT)
;;     — a fixed prayer identified by name
;;
;;   (:anthem :rubric TEXT)
;;     — the anthem placeholder (in quires and places where they sing)
;;
;; Sentences are kept in `bcp-1662-opening-sentences', shared between
;; both offices.  Each entry: (TEXT . CITATION) where CITATION is a
;; list suitable for rendering with italics, e.g.:
;;   ("text..." ("Ezek" 18 27))

;;; Code:

(require 'bcp-1662-data)

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Opening Sentences
;; Shared between Morning and Evening Prayer.
;; Each entry: (TEXT CITATION) where CITATION is a lesson ref.
;; A sentence with two citations (Jer x.24 / Ps vi.1) has a list of refs.

(defconst bcp-1662-opening-sentences
  '(("When the wicked man turneth away from his wickedness that he hath committed, and doeth that which is lawful and right, he shall save his soul alive."
     ("Ezek" 18 27))
    ("I acknowledge my transgressions, and my sin is ever before me."
     ("Ps" 51 3))
    ("Hide thy face from my sins, and blot out all mine iniquities."
     ("Ps" 51 9))
    ("The sacrifices of God are a broken spirit: a broken and a contrite heart, O God, thou wilt not despise."
     ("Ps" 51 17))
    ("Rend your heart, and not your garments, and turn unto the Lord your God: for he is gracious and merciful, slow to anger, and of great kindness, and repenteth him of the evil."
     ("Joel" 2 13))
    ("To the Lord our God belong mercies and forgivenesses, though we have rebelled against him; neither have we obeyed the voice of the Lord our God, to walk in his laws which he set before us."
     (("Dan" 9 9) ("Dan" 9 10)))
    ("O Lord, correct me, but with judgment; not in thine anger, lest thou bring me to nothing."
     (("Jer" 10 24) ("Ps" 6 1)))
    ("Repent ye; for the Kingdom of Heaven is at hand."
     ("Matt" 3 2))
    ("I will arise and go to my father, and will say unto him, Father, I have sinned against heaven, and before thee, and am no more worthy to be called thy son."
     ("Luke" 15 18 19))
    ("Enter not into judgment with thy servant, O Lord; for in thy sight shall no man living be justified."
     ("Ps" 143 2))
    ("If we say that we have no sin, we deceive ourselves, and the truth is not in us; but if we confess our sins, God is faithful and just to forgive us our sins, and to cleanse us from all unrighteousness."
     ("1 John" 1 8 9)))
  "Opening sentences for Morning and Evening Prayer.
Each entry: (TEXT CITATION) where CITATION is a lesson ref or list of refs.
The minister reads one or more of these at the opening of the service.")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Fixed Texts

(defconst bcp-1662-text-exhortation
  "Dearly beloved brethren, the Scripture moveth us, in sundry places, to acknowledge and confess our manifold sins and wickedness; and that we should not dissemble nor cloak them before the face of Almighty God our heavenly Father; but confess them with an humble, lowly, penitent, and obedient heart; to the end that we may obtain forgiveness of the same, by his infinite goodness and mercy. And although we ought, at all times, humbly to acknowledge our sins before God; yet ought we chiefly so to do, when we assemble and meet together to render thanks for the great benefits that we have received at his hands, to set forth his most worthy praise, to hear his most holy Word, and to ask those things which are requisite and necessary, as well for the body as the soul. Wherefore I pray and beseech you, as many as are here present, to accompany me with a pure heart, and humble voice, unto the throne of the heavenly grace, saying after me;")

(defconst bcp-1662-text-general-confession
  "Almighty and most merciful Father; We have erred, and strayed from thy ways like lost sheep. We have followed too much the devices and desires of our own hearts. We have offended against thy holy laws. We have left undone those things which we ought to have done; And we have done those things which we ought not to have done; And there is no health in us. But thou, O Lord, have mercy upon us, miserable offenders. Spare thou them, O God, who confess their faults. Restore thou them that are penitent; According to thy promises declared unto mankind in Christ Jesu our Lord. And grant, O most merciful Father, for his sake; That we may hereafter live a godly, righteous, and sober life, To the glory of thy holy Name. Amen.")

(defconst bcp-1662-text-absolution
  "Almighty God, the Father of our Lord Jesus Christ, who desireth not the death of a sinner, but rather that he may turn from his wickedness, and live; and hath given power, and commandment, to his Ministers, to declare and pronounce to his people, being penitent, the Absolution and Remission of their sins: He pardoneth and absolveth all them that truly repent, and unfeignedly believe his holy Gospel. Wherefore let us beseech him to grant us true repentance, and his Holy Spirit, that those things may please him, which we do at this present; and that the rest of our life hereafter may be pure, and holy; so that at the last we may come to his eternal joy; through Jesus Christ our Lord.")

(defconst bcp-1662-text-lords-prayer
  "Our Father, which art in heaven, Hallowed be thy Name. Thy kingdom come. Thy will be done in earth, As it is in heaven. Give us this day our daily bread. And forgive us our trespasses, As we forgive them that trespass against us. And lead us not into temptation, But deliver us from evil. For thine is the kingdom, The power, and the glory, For ever and ever. Amen.")

(defconst bcp-1662-text-lords-prayer-short
  "Our Father, which art in heaven, Hallowed be thy Name. Thy kingdom come. Thy will be done in earth, As it is in heaven. Give us this day our daily bread. And forgive us our trespasses, As we forgive them that trespass against us. And lead us not into temptation, But deliver us from evil. Amen.")

(defconst bcp-1662-text-gloria-patri
  "Glory be to the Father, and to the Son, and to the Holy Ghost; As it was in the beginning, is now, and ever shall be, world without end. Amen.")

(defconst bcp-1662-text-apostles-creed
  "I believe in God the Father Almighty, Maker of heaven and earth: And in Jesus Christ his only Son our Lord: Who was conceived by the Holy Ghost, Born of the Virgin Mary: Suffered under Pontius Pilate, Was crucified, dead, and buried: He descended into hell; The third day he rose again from the dead: He ascended into heaven, And sitteth on the right hand of God the Father Almighty: From thence he shall come to judge the quick and the dead. I believe in the Holy Ghost: The holy Catholick Church; The Communion of Saints: The Forgiveness of sins: The Resurrection of the body, And the Life everlasting. Amen.")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Fixed Collects and Prayers

(defconst bcp-1662-collect-morning-peace
  '(:name collect-morning-peace
    :title "The second Collect, for Peace."
    :text "O God, who art the author of peace and lover of concord, in knowledge of whom standeth our eternal life, whose service is perfect freedom; Defend us thy humble servants in all assaults of our enemies; that we, surely trusting in thy defence, may not fear the power of any adversaries, through the might of Jesus Christ our Lord. Amen."))

(defconst bcp-1662-collect-morning-grace
  '(:name collect-morning-grace
    :title "The third Collect, for Grace."
    :text "O Lord, our heavenly Father, Almighty and everlasting God, who hast safely brought us to the beginning of this day; Defend us in the same with thy mighty power; and grant that this day we fall into no sin, neither run into any kind of danger; but that all our doings may be ordered by thy governance, to do always that is righteous in thy sight; through Jesus Christ our Lord. Amen."))

(defconst bcp-1662-collect-evening-peace
  '(:name collect-evening-peace
    :title "The Second Collect at Evening Prayer."
    :text "O God, from whom all holy desires, all good counsels, and all just works do proceed; Give unto thy servants that peace which the world cannot give; that both our hearts may be set to obey thy commandments, and also that by thee, we, being defended from the fear of our enemies, may pass our time in rest and quietness; through the merits of Jesus Christ our Saviour. Amen."))

(defconst bcp-1662-collect-evening-perils
  '(:name collect-evening-perils
    :title "The Third Collect, for Aid against all Perils."
    :text "Lighten our darkness, we beseech thee, O Lord; and by thy great mercy defend us from all perils and dangers of this night; for the love of thy only Son, our Saviour, Jesus Christ. Amen."))

(defconst bcp-1662-prayer-king
  '(:name prayer-king
    :title "A Prayer for the King's Majesty."
    :text "O Lord, our heavenly Father, the high and mighty, King of kings, Lord of lords, the only Ruler of princes, who dost from thy throne behold all the dwellers upon earth; Most heartily we beseech thee with thy favour to behold our most gracious Sovereign Lord, King CHARLES; and so replenish him with the grace of thy Holy Spirit, that he may always incline to thy will, and walk in thy way. Endue him plenteously with heavenly gifts; grant him in health and wealth long to live; strengthen him that he may vanquish and overcome all his enemies; and finally, after this life, he may attain everlasting joy and felicity; through Jesus Christ our Lord. Amen."))

(defconst bcp-1662-prayer-royal-family
  '(:name prayer-royal-family
    :title "A Prayer for the Royal Family."
    :text "Almighty God, the fountain of all goodness, we humbly beseech thee to bless Queen Camilla, William Prince of Wales, the Princess of Wales, and all the Royal Family: Endue them with thy Holy Spirit; enrich them with thy heavenly grace; prosper them with all happiness; and bring them to thine everlasting kingdom; through Jesus Christ our Lord. Amen."))

(defconst bcp-1662-prayer-clergy-people
  '(:name prayer-clergy-people
    :title "A Prayer for the Clergy and People."
    :text "Almighty and everlasting God, who alone workest great marvels; Send down upon our Bishops, and Curates, and all Congregations committed to their charge, the healthful Spirit of thy grace; and that they may truly please thee, pour upon them the continual dew of thy blessing. Grant this, O Lord, for the honour of our Advocate and Mediator, Jesus Christ. Amen."))

(defconst bcp-1662-prayer-chrysostom
  '(:name prayer-chrysostom
    :title "A Prayer of St. Chrysostom."
    :text "Almighty God, who hast given us grace at this time with one accord to make our common supplications unto thee; and dost promise, that when two or three are gathered together in thy Name thou wilt grant their requests; Fulfil now, O Lord, the desires and petitions of thy servants, as may be most expedient for them; granting us in this world knowledge of thy truth, and in the world to come life everlasting. Amen."))

(defconst bcp-1662-grace-2cor
  '(:name grace-2cor
    :ref ("2 Cor" 13 14)
    :text "The grace of our Lord Jesus Christ, and the love of God, and the fellowship of the Holy Ghost, be with us all evermore. Amen."))

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Morning Prayer Ordo

(defconst bcp-1662-ordo-morning
  '((:rubric "At the beginning of Morning Prayer the Minister shall read with a loud voice some one or more of these Sentences of the Scriptures that follow. And then he shall say that which is written after the said Sentences."
     :ref bcp-1662-opening-sentences)
    (:sentences)

    (:text exhortation
     :ref bcp-1662-text-exhortation)

    (:rubric "A general Confession to be said of the whole Congregation after the Minister, all kneeling."
     :name general-confession)
    (:text general-confession
     :ref bcp-1662-text-general-confession)

    (:rubric "The Absolution, or Remission of sins, to be pronounced by the Priest alone, standing; the people still kneeling."
     :name absolution)
    (:text absolution
     :ref bcp-1662-text-absolution)

    (:rubric "If no priest be present the person saying the service shall read the Collect for the Twenty-First Sunday after Trinity, that person and the people still kneeling."
     :alt-collect after-trinity-21)

    (:rubric "Then the Minister shall kneel, and say the Lord's Prayer with an audible voice; the people also kneeling, and repeating it with him, both here, and wheresoever else it is used in Divine Service.")
    (:text lords-prayer
     :ref bcp-1662-text-lords-prayer)

    (:rubric "Then likewise he shall say,")
    (:versicles
     ("O Lord, open thou our lips."
      "And our mouth shall shew forth thy praise.")
     ("O God, make speed to save us."
      "O Lord, make haste to help us."))

    (:rubric "Here all standing up, the Priest shall say,")
    (:text gloria-patri
     :ref bcp-1662-text-gloria-patri)
    (:versicles
     ("Praise ye the Lord."
      "The Lord's Name be praised."))

    (:rubric "Then shall be said or sung this Psalm following; Except on Easter Day, upon which another Anthem is appointed; and on the nineteenth day of every month it is not to be read here, but in the ordinary course of the Psalms.")
    (:canticle venite
     :latin "Venite, exultemus Domino."
     :ref ("Ps" 95)
     :exception-easter t
     :exception-day-of-month 19)

    (:rubric "Then shall follow the Psalms in order as they be appointed. And at the end of every Psalm throughout the year, and likewise at the end of Benedicite, Benedictus, Magnificat, and Nunc dimittis, shall be repeated, Glory be to the Father...")
    (:psalm first
     :rubric "Psalms appointed for the day.")

    (:rubric "Then shall be read distinctly with an audible voice the First Lesson, taken out of the Old Testament, as is appointed in the Calendar, except there be proper Lessons assigned for that day. He that readeth so standing and turning himself, as he may best be heard of all such as are present. And after that, shall be said or sung, in English, the Hymn called Te Deum Laudamus, daily throughout the Year."
     :note "Note, That before every Lesson the Minister shall say, Here beginneth such a Chapter, or Verse of such a Chapter, of such a Book: And after every Lesson, Here endeth the First, or the Second Lesson.")
    (:lesson first
     :testament old)

    (:alternatives
     (:canticle te-deum
      :latin "Te Deum Laudamus."
      :rubric "Said or sung daily throughout the Year.")
     (:canticle benedicite
      :latin "Benedicite, omnia opera."
      :rubric "Or this Canticle."))

    (:rubric "Then shall be read in like manner the Second Lesson, taken out of the New Testament. And after that, the Hymn following; except when that shall happen to be read in the Chapter for the day, or for the Gospel on Saint John Baptist's Day.")
    (:lesson second
     :testament new)

    (:alternatives
     (:canticle benedictus
      :latin "Benedictus."
      :ref ("Luke" 1 68))
     (:canticle jubilate-deo
      :latin "Jubilate Deo."
      :ref ("Ps" 100)
      :rubric "Or this Psalm."))

    (:rubric "Then shall be sung or said the Apostles' Creed, by the Minister and the people standing: Except only such days as the Creed of Saint Athanasius is appointed to be read.")
    (:text apostles-creed
     :ref bcp-1662-text-apostles-creed)

    (:rubric "And after that these Prayers following, all devoutly kneeling: the Minister first pronouncing with a loud voice,")
    (:versicles
     ("The Lord be with you."
      "And with thy spirit.")
     ("Let us pray." nil)
     ("Lord, have mercy upon us." nil)
     ("Christ, have mercy upon us." nil)
     ("Lord, have mercy upon us." nil))

    (:rubric "Then the Minister, Clerks, and people shall say the Lord's Prayer with a loud voice.")
    (:text lords-prayer-short
     :ref bcp-1662-text-lords-prayer-short)

    (:rubric "Then the Priest standing up shall say,")
    (:versicles
     ("O Lord, shew thy mercy upon us."
      "And grant us thy salvation.")
     ("O Lord, save the King."
      "And mercifully hear us when we call upon thee.")
     ("Endue thy Ministers with righteousness."
      "And make thy chosen people joyful.")
     ("O Lord, save thy people."
      "And bless thine inheritance.")
     ("Give peace in our time, O Lord."
      "Because there is none other that fighteth for us, but only thou, O God.")
     ("O God, make clean our hearts within us."
      "And take not thy Holy Spirit from us."))

    (:rubric "Then shall follow three Collects; the first of the day, which shall be the same that is appointed at the Communion; The second for Peace; The third for Grace to live well. And the two last Collects shall never alter, but daily be said at Morning Prayer throughout all the year, as followeth, all kneeling.")
    (:collect day
     :rubric "The Collect of the Day, as appointed at the Communion.")
    (:collect morning-peace
     :ref bcp-1662-collect-morning-peace)
    (:collect morning-grace
     :ref bcp-1662-collect-morning-grace)

    (:anthem
     :rubric "In Quires and Places where they sing here followeth the Anthem.")

    (:rubric "Then these five Prayers following are to be read here: Except when the Litany is read; and then only the two last are to be read, as they are there placed.")
    (:prayer king
     :ref bcp-1662-prayer-king)
    (:prayer royal-family
     :ref bcp-1662-prayer-royal-family)
    (:prayer clergy-people
     :ref bcp-1662-prayer-clergy-people)
    (:prayer chrysostom
     :ref bcp-1662-prayer-chrysostom)
    (:prayer grace-2cor
     :ref bcp-1662-grace-2cor)

    (:rubric "Here endeth the Order of Morning Prayer throughout the Year."))
  "Ordo for Morning Prayer from the 1662 BCP.
Steps are tagged plists; see file commentary for type descriptions.")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Evening Prayer Ordo

(defconst bcp-1662-ordo-evening
  '((:rubric "At the beginning of Evening Prayer the Minister shall read with a loud voice some one or more of these Sentences of the Scriptures that follow. And then he shall say that which is written after the said Sentences."
     :ref bcp-1662-opening-sentences)
    (:sentences)

    (:text exhortation
     :ref bcp-1662-text-exhortation)

    (:rubric "A general Confession to be said of the whole Congregation after the Minister, all kneeling."
     :name general-confession)
    (:text general-confession
     :ref bcp-1662-text-general-confession)

    (:rubric "The Absolution or Remission of sins to be pronounced by the Priest alone, standing: the people still kneeling."
     :name absolution)
    (:text absolution
     :ref bcp-1662-text-absolution)

    (:rubric "If no priest be present the person saying the service shall read the Collect for the Twenty-First Sunday after Trinity, that person and the people still kneeling."
     :alt-collect after-trinity-21)

    (:rubric "Then the Minister shall kneel, and say the Lord's Prayer: the people also kneeling, and repeating it with him.")
    (:text lords-prayer
     :ref bcp-1662-text-lords-prayer)

    (:rubric "Then likewise he shall say,")
    (:versicles
     ("O Lord, open thou our lips."
      "And our mouth shall shew forth thy praise.")
     ("O God, make speed to save us."
      "O Lord, make haste to help us."))

    (:rubric "Here, all standing up, the Priest shall say,")
    (:text gloria-patri
     :ref bcp-1662-text-gloria-patri)
    (:versicles
     ("Praise ye the Lord."
      "The Lord's Name be praised."))

    (:rubric "Then shall be said or sung the Psalms in order as they be appointed.")
    (:psalm first
     :rubric "Psalms appointed for the day.")

    (:rubric "Then a Lesson of the Old Testament, as is appointed. And after that Magnificat (or the Song of the blessed Virgin Mary) in English, as followeth.")
    (:lesson first
     :testament old)

    (:alternatives
     (:canticle magnificat
      :latin "Magnificat."
      :ref ("Luke" 1 46))
     (:canticle cantate-domino
      :latin "Cantate Domino."
      :ref ("Ps" 98)
      :rubric "Or else this Psalm; except it be on the nineteenth day of the month, when it is read in the ordinary course of the Psalms."
      :exception-day-of-month 19))

    (:rubric "Then a Lesson of the New Testament, as it is appointed. And after that Nunc dimittis (or the Song of Simeon) in English, as followeth.")
    (:lesson second
     :testament new)

    (:alternatives
     (:canticle nunc-dimittis
      :latin "Nunc dimittis."
      :ref ("Luke" 2 29))
     (:canticle deus-misereatur
      :latin "Deus misereatur."
      :ref ("Ps" 67)
      :rubric "Or else this Psalm: Except it be on the twelfth day of the month."
      :exception-day-of-month 12))

    (:rubric "Then shall be sung or said the Apostles' Creed, by the Minister and the people standing.")
    (:text apostles-creed
     :ref bcp-1662-text-apostles-creed)

    (:rubric "And after that, these Prayers following, all devoutly kneeling: the Minister first pronouncing with a loud voice,")
    (:versicles
     ("The Lord be with you."
      "And with thy spirit.")
     ("Let us pray." nil)
     ("Lord, have mercy upon us." nil)
     ("Christ, have mercy upon us." nil)
     ("Lord, have mercy upon us." nil))

    (:rubric "Then the Minister, Clerks, and people shall say the Lord's Prayer with a loud voice.")
    (:text lords-prayer-short
     :ref bcp-1662-text-lords-prayer-short)

    (:rubric "Then the Priest standing up shall say,")
    (:versicles
     ("O Lord, shew thy mercy upon us."
      "And grant us thy salvation.")
     ("O Lord, save the King."
      "And mercifully hear us when we call upon thee.")
     ("Endue thy Ministers with righteousness."
      "And make thy chosen people joyful.")
     ("O Lord, save thy people."
      "And bless thine inheritance.")
     ("Give peace in our time, O Lord."
      "Because there is none other that fighteth for us, but only thou, O God.")
     ("O God, make clean our hearts within us."
      "And take not thy Holy Spirit from us."))

    (:rubric "Then shall follow three Collects; the first of the day; The second for Peace; The third for Aid against all Perils, as hereafter followeth: which two last Collects shall be daily said at Evening Prayer without alteration.")
    (:collect day
     :rubric "The Collect of the Day.")
    (:collect evening-peace
     :ref bcp-1662-collect-evening-peace)
    (:collect evening-perils
     :ref bcp-1662-collect-evening-perils)

    (:anthem
     :rubric "In Quires and Places where they sing here followeth the Anthem.")

    (:prayer king
     :ref bcp-1662-prayer-king)
    (:prayer royal-family
     :ref bcp-1662-prayer-royal-family)
    (:prayer clergy-people
     :ref bcp-1662-prayer-clergy-people)
    (:prayer chrysostom
     :ref bcp-1662-prayer-chrysostom)
    (:prayer grace-2cor
     :ref bcp-1662-grace-2cor)

    (:rubric "Here endeth the Order of Evening Prayer throughout the Year."))
  "Ordo for Evening Prayer from the 1662 BCP.
Steps are tagged plists; see file commentary for type descriptions.")

(provide 'bcp-1662-ordo)
;;; bcp-1662-ordo.el ends here
