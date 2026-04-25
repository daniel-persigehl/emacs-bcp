;;; bcp-anglican-1928-ordo.el --- 1928 American BCP Daily Office ordo -*- lexical-binding: t -*-

;;; Commentary:

;; The ordo (order of service) for Morning and Evening Prayer from the
;; 1928 American Book of Common Prayer.
;;
;; Key differences from the 1662 BCP:
;;   - Lord's Prayer: "who art in heaven", "those who trespass" (vs 1662 "which"/"them that")
;;   - General Confession: "those who confess", "those who are penitent" (vs 1662 "them"/"them that")
;;   - Nicene Creed offered as alternative to Apostles' Creed
;;   - Benedictus es Domine as third canticle option after first lesson (Morning)
;;   - Versicles after Lord's Prayer simplified (no monarchical pairs)
;;   - State prayers: Prayer for the President (not the King/Royal Family)
;;   - Opening sentences from the 1928 corpus (bcp-common-anglican)
;;
;; Step format is identical to bcp-1662-ordo.el; see that file's
;; commentary for type descriptions.

;;; Code:

(require 'bcp-common-prayers)
(require 'bcp-common-anglican)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; 1928 fixed texts

(defconst bcp-1928-text-exhortation-brief bcp-common-anglican-exhortation-brief
  "Brief bidding sentence used in place of the full exhortation (1928 rubrical option).
Alias for `bcp-common-anglican-exhortation-brief'; the 1928 BCP provides only
this abbreviated form rather than the full 1662 exhortation.")

(defconst bcp-1928-text-general-confession
  "Almighty and most merciful Father; We have erred, and strayed from thy ways \
like lost sheep. We have followed too much the devices and desires of our own \
hearts. We have offended against thy holy laws. We have left undone those things \
which we ought to have done; And we have done those things which we ought not to \
have done; And there is no health in us. But thou, O Lord, have mercy upon us, \
miserable offenders. Spare thou those, O God, who confess their faults. Restore \
thou those who are penitent; According to thy promises declared unto mankind in \
Christ Jesus our Lord. And grant, O most merciful Father, for his sake; That we \
may hereafter live a godly, righteous, and sober life, To the glory of thy holy \
Name. Amen."
  "General Confession, 1928 American BCP form.")

(defconst bcp-1928-text-absolution
  "Almighty God, the Father of our Lord Jesus Christ, who desireth not the death \
of a sinner, but rather that he may turn from his wickedness, and live; and hath \
given power, and commandment, to his Ministers, to declare and pronounce to his \
people, being penitent, the Absolution and Remission of their sins: He pardoneth \
and absolveth all those who truly repent, and unfeignedly believe his holy Gospel. \
Wherefore let us beseech him to grant us true repentance, and his Holy Spirit, \
that those things may please him, which we do at this present; and that the rest \
of our life hereafter may be pure, and holy; so that at the last we may come to \
his eternal joy; through Jesus Christ our Lord."
  "The Absolution, 1928 American BCP form.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Morning Prayer Ordo

(defconst bcp-1928-ordo-morning
  '((:rubric "At the beginning of Morning Prayer, the Minister shall read with a \
loud voice some one or more of these Sentences of the Scripture that follow; and \
then he shall say the Exhortation that followeth."
     :ref bcp-common-anglican-opening-sentences-1928)
    (:sentences)

    (:text exhortation
     :ref bcp-1928-text-exhortation-brief)

    (:rubric "Then shall be said by the Minister and people, all kneeling."
     :name general-confession)
    (:text general-confession
     :ref bcp-1928-text-general-confession)

    (:rubric "The Absolution or Remission of sins to be pronounced by the Priest \
alone, standing; the people still kneeling."
     :name absolution)
    (:text absolution
     :ref bcp-1928-text-absolution)
    (:rubric "If no Priest be present, the Minister shall say this Collect."
     :alt-collect after-trinity-21)

    (:rubric "Then the Minister shall kneel and say the Lord's Prayer, the people \
also kneeling and repeating it with him.")
    (:text lords-prayer
     :ref bcp-common-prayers-lords-prayer-1928
     :doxology bcp-common-prayers-lords-prayer-doxology-1928)

    (:rubric "Then the Minister standing up shall say,")
    (:versicles
     ("O Lord, open thou our lips."
      "And our mouth shall shew forth thy praise.")
     ("O God, make speed to save us."
      "O Lord, make haste to help us."))

    (:rubric "Here all standing up, the Minister shall say,")
    (:text gloria-patri
     :ref bcp-common-prayers-gloria-patri)
    (:versicles
     ("Praise ye the Lord."
      "The Lord's Name be praised."))

    (:hymn :slot-kind office-hymn)

    (:rubric "Then shall be said or sung the following Canticle; except on those \
days for which other Canticles are appointed; and except also, that Psalm 95 may \
be used in this place. But Note, That on Ash Wednesday and Good Friday the Venite \
may be omitted. And on the nineteenth day of every month it is not to be read here, \
but in the ordinary course of the Psalms. On the days hereafter named, here may be \
sung or said the appointed Invitatory.")
    (:canticle venite
     :latin "Venite, exultemus Domino."
     :ref "Ps 95"
     :exception-easter t
     :exception-day-of-month 19)

    (:rubric "Then shall follow the Psalms in order as they be appointed.")
    (:psalm first
     :rubric "Psalms appointed for the day.")

    (:rubric "Then shall be read the First Lesson, taken out of the Old Testament \
as is appointed in the Table of Lessons. After the Lesson shall follow one of \
these Canticles, or the Song of the Three Children (Benedicite).")
    (:lesson first
     :testament old)

    (:alternatives
     (:canticle te-deum
      :latin "Te Deum Laudamus."
      :rubric "To be used throughout the Year.")
     (:canticle benedictus-es-domine
      :latin "Benedictus es, Domine."
      :ref "Song of Three 29-34"
      :rubric "Or this Canticle.")
     (:canticle benedicite
      :latin "Benedicite, omnia opera."
      :rubric "Or this Canticle, especially in Advent and Lent."))

    (:rubric "Then shall be read the Second Lesson, taken out of the New Testament \
as is appointed in the Table of Lessons. After the Lesson shall follow one of \
these Canticles.")
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

    (:rubric "Then shall be said the Apostles' Creed by the Minister and the \
people, standing. The Nicene Creed may be used in place of the Apostles' Creed.")
    (:text apostles-creed
     :ref bcp-common-prayers-apostles-creed
     :alt-creed bcp-common-prayers-nicene-creed)

    (:rubric "And after that, these Prayers following, all devoutly kneeling.")
    (:versicles-preces)

    (:rubric "Then the Minister and people shall say the Lord's Prayer.")
    (:text lords-prayer
     :ref bcp-common-prayers-lords-prayer-1928)

    (:rubric "Then the Minister, standing, shall say,")
    (:versicles
     ("O Lord, show thy mercy upon us."
      "And grant us thy salvation."))
    (:state-versicles :tradition 1928)
    (:versicles
     ("Endue thy ministers with righteousness."
      "And make thy chosen people joyful.")
     ("O Lord, save thy people."
      "And bless thine inheritance.")
     ("Give peace in our time, O Lord."
      "For it is thou, Lord, only, that makest us dwell in safety.")
     ("O God, make clean our hearts within us."
      "And take not thy Holy Spirit from us."))

    (:rubric "Then shall follow three Collects; the first of the Day; the second \
for Peace; the third for Grace. The two last Collects shall never alter, but shall \
daily be said at Morning Prayer throughout all the Year.")
    (:collect day
     :rubric "The Collect of the Day.")
    (:collect morning-peace
     :ref bcp-common-anglican-collect-morning-peace)
    (:collect morning-grace
     :ref bcp-common-anglican-collect-morning-grace-1928)

    (:anthem
     :rubric "In Quires and Places where they sing, here followeth the Anthem.")

    (:rubric "Then shall be said the following Prayers.")
    (:state-prayers :tradition 1928)
    (:prayer chrysostom
     :ref bcp-common-prayers-chrysostom)
    (:prayer grace-2cor
     :ref bcp-common-prayers-grace-2cor)

    (:hymn :slot-kind closing)

    (:rubric "Here endeth the Order of Morning Prayer."))
  "Ordo for Morning Prayer from the 1928 American BCP.
Steps are tagged plists; see bcp-1662-ordo.el commentary for type descriptions.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Evening Prayer Ordo

(defconst bcp-1928-ordo-evening
  '((:rubric "At the beginning of Evening Prayer, the Minister shall read with a \
loud voice some one or more of these Sentences of the Scripture that follow; and \
then he shall say the Exhortation that followeth."
     :ref bcp-common-anglican-opening-sentences-1928-evensong)
    (:sentences)

    (:text exhortation
     :ref bcp-1928-text-exhortation-brief)

    (:rubric "Then shall be said by the Minister and people, all kneeling."
     :name general-confession)
    (:text general-confession
     :ref bcp-1928-text-general-confession)

    (:rubric "The Absolution or Remission of sins to be pronounced by the Priest \
alone, standing; the people still kneeling."
     :name absolution)
    (:text absolution
     :ref bcp-1928-text-absolution)
    (:rubric "If no Priest be present, the Minister shall say this Collect."
     :alt-collect after-trinity-21)

    (:rubric "Then the Minister shall kneel and say the Lord's Prayer, the people \
also kneeling and repeating it with him.")
    (:text lords-prayer
     :ref bcp-common-prayers-lords-prayer-1928
     :doxology bcp-common-prayers-lords-prayer-doxology-1928)

    (:rubric "Then the Minister standing up shall say,")
    (:versicles
     ("O Lord, open thou our lips."
      "And our mouth shall shew forth thy praise.")
     ("O God, make speed to save us."
      "O Lord, make haste to help us."))

    (:rubric "Here, all standing up, the Minister shall say,")
    (:text gloria-patri
     :ref bcp-common-prayers-gloria-patri)
    (:versicles
     ("Praise ye the Lord."
      "The Lord's Name be praised."))

    (:hymn :slot-kind office-hymn)

    (:rubric "Then shall be said or sung the Psalms appointed for the day.")
    (:psalm first
     :rubric "Psalms appointed for the day.")

    (:rubric "Then shall be read the First Lesson, taken out of the Old Testament \
as is appointed. After the Lesson shall follow one of these Canticles.")
    (:lesson first
     :testament old)

    (:alternatives
     (:canticle magnificat
      :latin "Magnificat."
      :ref "Luke 1:46-55")
     (:canticle cantate-domino
      :latin "Cantate Domino."
      :ref "Ps 98"
      :rubric "Or this Psalm; except on the nineteenth day of the month."))

    (:rubric "Then shall be read the Second Lesson, taken out of the New Testament \
as is appointed. After the Lesson shall follow one of these Canticles.")
    (:lesson second
     :testament new)

    (:alternatives
     (:canticle nunc-dimittis
      :latin "Nunc dimittis."
      :ref "Luke 2:29-32")
     (:canticle deus-misereatur
      :latin "Deus misereatur."
      :ref "Ps 67"
      :rubric "Or this Psalm; except on the twelfth day of the month."))

    (:rubric "Then shall be said the Apostles' Creed by the Minister and the \
people, standing. The Nicene Creed may be used in place of the Apostles' Creed.")
    (:text apostles-creed
     :ref bcp-common-prayers-apostles-creed
     :alt-creed bcp-common-prayers-nicene-creed)

    (:rubric "And after that, these Prayers following, all devoutly kneeling.")
    (:versicles-preces)

    (:rubric "Then the Minister and people shall say the Lord's Prayer.")
    (:text lords-prayer
     :ref bcp-common-prayers-lords-prayer-1928)

    (:rubric "Then the Minister, standing, shall say,")
    (:versicles
     ("O Lord, show thy mercy upon us."
      "And grant us thy salvation."))
    (:state-versicles :tradition 1928)
    (:versicles
     ("Endue thy ministers with righteousness."
      "And make thy chosen people joyful.")
     ("O Lord, save thy people."
      "And bless thine inheritance.")
     ("Give peace in our time, O Lord."
      "For it is thou, Lord, only, that makest us dwell in safety.")
     ("O God, make clean our hearts within us."
      "And take not thy Holy Spirit from us."))

    (:rubric "Then shall follow three Collects; the first of the Day; the second \
for Peace; the third for Aid against all Perils.")
    (:collect day
     :rubric "The Collect of the Day.")
    (:collect evening-peace
     :ref bcp-common-anglican-collect-evening-peace)
    (:collect evening-perils
     :ref bcp-common-anglican-collect-evening-perils)

    (:anthem
     :rubric "In Quires and Places where they sing, here followeth the Anthem.")

    (:rubric "Then shall be said the following Prayers.")
    (:state-prayers :tradition 1928)
    (:prayer chrysostom
     :ref bcp-common-prayers-chrysostom)
    (:prayer grace-2cor
     :ref bcp-common-prayers-grace-2cor)

    (:hymn :slot-kind closing)

    (:rubric "Here endeth the Order of Evening Prayer."))
  "Ordo for Evening Prayer from the 1928 American BCP.
Steps are tagged plists; see bcp-1662-ordo.el commentary for type descriptions.")

(provide 'bcp-anglican-1928-ordo)
;;; bcp-anglican-1928-ordo.el ends here
