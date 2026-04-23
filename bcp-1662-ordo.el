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
;;   (:canticle NAME :ref "Book CH:V-V" :rubric TEXT)
;;     — a canticle identified by name, with its scriptural reference
;;       as a passage string (e.g. "Luke 1:46-55", "Ps 95") and any
;;       governing rubric; text kept elsewhere
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
(require 'bcp-common-anglican)

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

;; Lord's Prayer, Gloria Patri, Apostles' Creed — now in bcp-liturgy-common-prayers.el

;; Fixed office collects (peace, grace, perils) — now in bcp-common-anglican.el
;; Monarchical state prayers (king, royal family, clergy/people) — now in bcp-common-anglican.el

;; Prayer of St. Chrysostom and The Grace — now in bcp-common-prayers.el

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
     :ref bcp-common-prayers-lords-prayer
     :doxology bcp-common-prayers-lords-prayer-doxology)

    (:rubric "Then likewise he shall say,")
    (:versicles
     ("O Lord, open thou our lips."
      "And our mouth shall shew forth thy praise.")
     ("O God, make speed to save us."
      "O Lord, make haste to help us."))

    (:rubric "Here all standing up, the Priest shall say,")
    (:text gloria-patri
     :ref bcp-common-prayers-gloria-patri)
    (:versicles
     ("Praise ye the Lord."
      "The Lord's Name be praised."))

    (:rubric "Then shall be said or sung this Psalm following; Except on Easter Day, upon which another Anthem is appointed; and on the nineteenth day of every month it is not to be read here, but in the ordinary course of the Psalms.")
    (:canticle venite
     :latin "Venite, exultemus Domino."
     :ref "Ps 95"
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
      :ref "Luke 1:68-79")
     (:canticle jubilate-deo
      :latin "Jubilate Deo."
      :ref "Ps 100"
      :rubric "Or this Psalm."))

    (:rubric "Then shall be sung or said the Apostles' Creed, by the Minister and the people standing: Except only such days as the Creed of Saint Athanasius is appointed to be read.")
    (:text apostles-creed
     :ref bcp-common-prayers-apostles-creed)

    (:rubric "And after that these Prayers following, all devoutly kneeling: the Minister first pronouncing with a loud voice,")
    (:versicles-preces)
    (:versicles
     ("Lord, have mercy upon us." nil)
     ("Christ, have mercy upon us." nil)
     ("Lord, have mercy upon us." nil))

    (:rubric "Then the Minister, Clerks, and people shall say the Lord's Prayer with a loud voice.")
    (:text lords-prayer
     :ref bcp-common-prayers-lords-prayer)

    (:rubric "Then the Priest standing up shall say,")
    (:versicles
     ("O Lord, shew thy mercy upon us."
      "And grant us thy salvation."))
    (:state-versicles :tradition 1662)
    (:versicles
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
     :ref bcp-common-anglican-collect-morning-peace)
    (:collect morning-grace
     :ref bcp-common-anglican-collect-morning-grace)

    (:anthem
     :rubric "In Quires and Places where they sing here followeth the Anthem.")

    (:rubric "Then these five Prayers following are to be read here: Except when the Litany is read; and then only the two last are to be read, as they are there placed.")
    (:state-prayers :tradition 1662)
    (:prayer chrysostom
     :ref bcp-common-prayers-chrysostom)
    (:prayer grace-2cor
     :ref bcp-common-prayers-grace-2cor)

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
     :ref bcp-common-prayers-lords-prayer
     :doxology bcp-common-prayers-lords-prayer-doxology)

    (:rubric "Then likewise he shall say,")
    (:versicles
     ("O Lord, open thou our lips."
      "And our mouth shall shew forth thy praise.")
     ("O God, make speed to save us."
      "O Lord, make haste to help us."))

    (:rubric "Here, all standing up, the Priest shall say,")
    (:text gloria-patri
     :ref bcp-common-prayers-gloria-patri)
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
      :ref "Luke 1:46-55")
     (:canticle cantate-domino
      :latin "Cantate Domino."
      :ref "Ps 98"
      :rubric "Or else this Psalm; except it be on the nineteenth day of the month, when it is read in the ordinary course of the Psalms."
      :exception-day-of-month 19))

    (:rubric "Then a Lesson of the New Testament, as it is appointed. And after that Nunc dimittis (or the Song of Simeon) in English, as followeth.")
    (:lesson second
     :testament new)

    (:alternatives
     (:canticle nunc-dimittis
      :latin "Nunc dimittis."
      :ref "Luke 2:29-32")
     (:canticle deus-misereatur
      :latin "Deus misereatur."
      :ref "Ps 67"
      :rubric "Or else this Psalm: Except it be on the twelfth day of the month."
      :exception-day-of-month 12))

    (:rubric "Then shall be sung or said the Apostles' Creed, by the Minister and the people standing.")
    (:text apostles-creed
     :ref bcp-common-prayers-apostles-creed)

    (:rubric "And after that, these Prayers following, all devoutly kneeling: the Minister first pronouncing with a loud voice,")
    ;; TODO: when `office-officiant' is `lay or `deacon (i.e. not a priest),
    (:versicles-preces)
    (:versicles
     ("Lord, have mercy upon us." nil)
     ("Christ, have mercy upon us." nil)
     ("Lord, have mercy upon us." nil))

    (:rubric "Then the Minister, Clerks, and people shall say the Lord's Prayer with a loud voice.")
    (:text lords-prayer
     :ref bcp-common-prayers-lords-prayer)

    (:rubric "Then the Priest standing up shall say,")
    (:versicles
     ("O Lord, shew thy mercy upon us."
      "And grant us thy salvation."))
    (:state-versicles :tradition 1662)
    (:versicles
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
     :ref bcp-common-anglican-collect-evening-peace)
    (:collect evening-perils
     :ref bcp-common-anglican-collect-evening-perils)

    (:anthem
     :rubric "In Quires and Places where they sing here followeth the Anthem.")

    (:state-prayers :tradition 1662)
    (:prayer chrysostom
     :ref bcp-common-prayers-chrysostom)
    (:prayer grace-2cor
     :ref bcp-common-prayers-grace-2cor)

    (:rubric "Here endeth the Order of Evening Prayer throughout the Year."))
  "Ordo for Evening Prayer from the 1662 BCP.
Steps are tagged plists; see file commentary for type descriptions.")

(provide 'bcp-1662-ordo)
;;; bcp-1662-ordo.el ends here
