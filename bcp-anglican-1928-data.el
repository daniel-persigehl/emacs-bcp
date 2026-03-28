;;; bcp-anglican-1928-data.el --- Collects for the 1928 American BCP -*- lexical-binding: t -*-

;; Keywords: bible, bcp, liturgy, collects

;;; Commentary:

;; This file contains the collect and communion proper tables for the
;; 1928 American Book of Common Prayer.
;;
;; Contents:
;;   `bcp-1928-collects'           — collect for every Sunday, feast, and occasion
;;   `bcp-1928-communion-propers'  — Epistle and Gospel for every Sunday, feast,
;;                                   saints' day, and special occasion
;;
;; Text variants: where the 1928 edition diverges from earlier American
;; BCPs (1789/1892), the 1928 text is used throughout.  See inline
;; comments for specific divergences noted in the source apparatus.
;;
;; Key naming follows bcp-anglican-1928-lectionary.el conventions.

;;; Code:

(require 'bcp-anglican-1928-calendar)


(defconst bcp-1928-collects
  '(

    ;;;; ── ADVENT ─────────────────────────────────────────────────────────────

    ;; Advent 1 text: 1892/1928 add "the" before "dead" ("judge both the quick
    ;; and the dead").  The 1662 text omits the second "the".
    (advent-1
     :name "First Sunday in Advent"
     :rubric "To be repeated every day, with the other Collects in Advent, until Christmas Eve."
     :text "ALMIGHTY God, give us grace that we may cast away the works of darkness, and put upon us the armour of light, now in the time of this mortal life, in which thy Son Jesus Christ came to visit us in great humility; that in the last day, when he shall come again in his glorious majesty to judge both the quick and the dead, we may rise to the life immortal, through him who liveth and reigneth with thee and the Holy Ghost, now and ever. Amen.")

    (advent-2
     :name "Second Sunday in Advent"
     :text "BLESSED Lord, who hast caused all holy Scriptures to be written for our learning; Grant that we may in such wise hear them, read, mark, learn, and inwardly digest them, that by patience and comfort of thy holy Word, we may embrace, and ever hold fast, the blessed hope of everlasting life, which thou hast given us in our Saviour Jesus Christ. Amen.")

    ;; Advent 3 text: 1928 places the comma after "ever", not before it —
    ;; "Holy Spirit ever, one God" (not "Holy Spirit, ever one God").
    (advent-3
     :name "Third Sunday in Advent"
     :text "O LORD Jesus Christ, who at thy first coming didst send thy messenger to prepare thy way before thee; Grant that the ministers and stewards of thy mysteries may likewise so prepare and make ready thy way, by turning the hearts of the disobedient to the wisdom of the just, that at thy second coming to judge the world we may be found an acceptable people in thy sight, who livest and reignest with the Father and the Holy Spirit ever, one God, world without end. Amen.")

    ;; Advent 4 text: 1928 replaces "through the satisfaction of thy Son our
    ;; Lord" (1662) with "through Jesus Christ our Lord".
    (advent-4
     :name "Fourth Sunday in Advent"
     :text "O LORD, raise up, we pray thee, thy power, and come among us, and with great might succour us; that whereas, through our sins and wickedness, we are sore let and hindered in running the race that is set before us, thy bountiful grace and mercy may speedily help and deliver us; through Jesus Christ our Lord, to whom, with thee and the Holy Ghost, be honour and glory, world without end. Amen.")


    ;;;; ── CHRISTMASTIDE ──────────────────────────────────────────────────────

    ;; Christmas text: "Holy Spirit" capitalised from 1892 onward (1662 has
    ;; lower-case "same Spirit").
    (christmas
     :name "Christmas Day (The Nativity of our Lord)"
     :rubric "The Collect of Christmas shall be said continually unto New Year's Eve."
     :text "ALMIGHTY God, who hast given us thy only-begotten Son to take our nature upon him, and as at this time to be born of a pure virgin; Grant that we being regenerate, and made thy children by adoption and grace, may daily be renewed by thy Holy Spirit; through the same our Lord Jesus Christ, who liveth and reigneth with thee and the same Spirit ever, one God, world without end. Amen.")

    ;; A second optional collect for a second celebration of Christmas,
    ;; added in the 1892 revision and retained in 1928.
    (christmas-second
     :name "Christmas Day (Second Collect, for Second Celebration)"
     :text "O GOD, who makest us glad with the yearly remembrance of the birth of thine only Son Jesus Christ; Grant that as we joyfully receive him for our Redeemer, so we may with sure confidence behold him when he shall come to be our Judge, who liveth and reigneth with thee and the Holy Ghost, one God, world without end. Amen.")

    ;; The Sunday after Christmas Day uses the Christmas collect; the text is
    ;; repeated here verbatim so that collect lookup is uniform.
    (sunday-after-christmas
     :name "Sunday after Christmas Day"
     ;; Note: the 1928 BCP directs the Christmas collect to be used on this
     ;; Sunday; the text below is identical to the `christmas' entry above.
     :text "ALMIGHTY God, who hast given us thy only-begotten Son to take our nature upon him, and as at this time to be born of a pure virgin; Grant that we being regenerate, and made thy children by adoption and grace, may daily be renewed by thy Holy Spirit; through the same our Lord Jesus Christ, who liveth and reigneth with thee and the same Spirit ever, one God, world without end. Amen.")

    ;; In the 1928 BCP, January 1 is titled "The First Sunday after Christmas
    ;; Day" (= the Circumcision).  The key `circumcision' is retained for
    ;; consistency with the lectionary key conventions.
    (circumcision
     :name "The Circumcision of Christ (First Sunday after Christmas Day, Jan 1)"
     :rubric "The same Collect, Epistle, and Gospel shall serve for every day after unto the Epiphany."
     :text "ALMIGHTY God, who madest thy blessed Son to be circumcised, and obedient to the law for man; Grant us the true circumcision of the Spirit; that, our hearts, and all our members, being mortified from all worldly and carnal lusts, we may in all things obey thy blessed will; through the same thy Son Jesus Christ our Lord. Amen.")

    ;; New in the 1928 BCP: a proper collect for the Second Sunday after
    ;; Christmas Day (when it falls between Jan 1 and the Epiphany).
    (after-christmas-2
     :name "Second Sunday after Christmas Day"
     :text "ALMIGHTY God, who hast poured upon us the new light of thine incarnate Word; Grant that the same light enkindled in our hearts may shine forth in our lives; through Jesus Christ our Lord. Amen.")


    ;;;; ── EPIPHANYTIDE ───────────────────────────────────────────────────────

    ;; Epiphany text: 1928 uses "through the same thy Son Jesus Christ our
    ;; Lord" (1662 has simply "through Jesus Christ our Lord").
    (epiphany
     :name "The Epiphany (Manifestation of Christ to the Gentiles)"
     :text "O GOD, who by the leading of a star didst manifest thy only-begotten Son to the Gentiles; Mercifully grant that we, who know thee now by faith, may after this life have the fruition of thy glorious Godhead; through the same thy Son Jesus Christ our Lord. Amen.")

    (after-epiphany-1
     :name "First Sunday after the Epiphany"
     :text "O LORD, we beseech thee mercifully to receive the prayers of thy people who call upon thee; and grant that they may both perceive and know what things they ought to do, and also may have grace and power faithfully to fulfil the same; through Jesus Christ our Lord. Amen.")

    (after-epiphany-2
     :name "Second Sunday after the Epiphany"
     :text "ALMIGHTY and everlasting God, who dost govern all things in heaven and earth; Mercifully hear the supplications of thy people, and grant us thy peace all the days of our life; through Jesus Christ our Lord. Amen.")

    (after-epiphany-3
     :name "Third Sunday after the Epiphany"
     :text "ALMIGHTY and everlasting God, mercifully look upon our infirmities, and in all our dangers and necessities stretch forth thy right hand to help and defend us; through Jesus Christ our Lord. Amen.")

    (after-epiphany-4
     :name "Fourth Sunday after the Epiphany"
     :text "O GOD, who knowest us to be set in the midst of so many and great dangers, that by reason of the frailty of our nature we cannot always stand upright; Grant to us such strength and protection, as may support us in all dangers, and carry us through all temptations; through Jesus Christ our Lord. Amen.")

    (after-epiphany-5
     :name "Fifth Sunday after the Epiphany"
     :text "O LORD, we beseech thee to keep thy Church and household continually in thy true religion; that they who do lean only upon the hope of thy heavenly grace may evermore be defended by thy mighty power; through Jesus Christ our Lord. Amen.")

    (after-epiphany-6
     :name "Sixth Sunday after the Epiphany"
     :text "O GOD, whose blessed Son was manifested that he might destroy the works of the devil, and make us the sons of God, and heirs of eternal life; Grant us, we beseech thee, that, having this hope, we may purify ourselves, even as he is pure; that, when he shall appear again with power and great glory, we may be made like unto him in his eternal and glorious kingdom; where with thee, O Father, and thee, O Holy Ghost, he liveth and reigneth ever, one God, world without end. Amen.")


    ;;;; ── PRE-LENTEN SEASON ──────────────────────────────────────────────────

    (septuagesima
     :name "Septuagesima (Third Sunday before Lent)"
     :text "O LORD, we beseech thee favourably to hear the prayers of thy people; that we, who are justly punished for our offences, may be mercifully delivered by thy goodness, for the glory of thy Name; through Jesus Christ our Saviour, who liveth and reigneth with thee and the Holy Ghost ever, one God, world without end. Amen.")

    (sexagesima
     :name "Sexagesima (Second Sunday before Lent)"
     :text "O LORD God, who seest that we put not our trust in any thing that we do; Mercifully grant that by thy power we may be defended against all adversity; through Jesus Christ our Lord. Amen.")

    (quinquagesima
     :name "Quinquagesima (Sunday next before Lent)"
     :text "O LORD, who hast taught us that all our doings without charity are nothing worth; Send thy Holy Ghost, and pour into our hearts that most excellent gift of charity, the very bond of peace and of all virtues, without which whosoever liveth is counted dead before thee. Grant this for thine only Son Jesus Christ's sake. Amen.")


    ;;;; ── LENTEN SEASON ──────────────────────────────────────────────────────

    (ash-wednesday
     :name "Ash Wednesday (The First Day of Lent)"
     :rubric "To be read every day in Lent after the Collect appointed for the Day."
     :text "ALMIGHTY and everlasting God, who hatest nothing that thou hast made, and dost forgive the sins of all those who are penitent; Create and make in us new and contrite hearts, that we, worthily lamenting our sins and acknowledging our wretchedness, may obtain of thee, the God of all mercy, perfect remission and forgiveness; through Jesus Christ our Lord. Amen.")

    (lent-1
     :name "First Sunday in Lent"
     :text "O LORD, who for our sake didst fast forty days and forty nights; Give us grace to use such abstinence, that, our flesh being subdued to the Spirit, we may ever obey thy godly motions in righteousness, and true holiness, to thy honour and glory, who livest and reignest with the Father and the Holy Ghost, one God, world without end. Amen.")

    (lent-2
     :name "Second Sunday in Lent"
     :text "ALMIGHTY God, who seest that we have no power of ourselves to help ourselves; Keep us both outwardly in our bodies, and inwardly in our souls; that we may be defended from all adversities which may happen to the body, and from all evil thoughts which may assault and hurt the soul; through Jesus Christ our Lord. Amen.")

    (lent-3
     :name "Third Sunday in Lent"
     :text "WE beseech thee, Almighty God, look upon the hearty desires of thy humble servants, and stretch forth the right hand of thy Majesty, to be our defence against all our enemies; through Jesus Christ our Lord. Amen.")

    (lent-4
     :name "Fourth Sunday in Lent"
     :text "GRANT, we beseech thee, Almighty God, that we, who for our evil deeds do worthily deserve to be punished, by the comfort of thy grace may mercifully be relieved; through our Lord and Saviour Jesus Christ. Amen.")

    (lent-5
     :name "Fifth Sunday in Lent (Passion Sunday)"
     :text "WE beseech thee, Almighty God, mercifully to look upon thy people; that by thy great goodness they may be governed and preserved evermore, both in body and soul; through Jesus Christ our Lord. Amen.")


    ;;;; ── HOLY WEEK ──────────────────────────────────────────────────────────

    ;; Palm Sunday text: title "commonly called Palm Sunday" added in 1928.
    ;; The rubric directing repetition until Good Friday is original.
    (palm-sunday
     :name "The Sunday next before Easter (Palm Sunday)"
     :rubric "This Collect is to be repeated every day, after the Collect appointed for the day, until Good Friday."
     :text "ALMIGHTY and everlasting God, who of thy tender love towards mankind, hast sent thy Son, our Saviour Jesus Christ, to take upon him our flesh, and to suffer death upon the cross, that all mankind should follow the example of his great humility; Mercifully grant, that we may both follow the example of his patience, and also be made partakers of his resurrection; through the same Jesus Christ our Lord. Amen.")

    ;; The Monday, Tuesday, and Wednesday collects for Holy Week are all new
    ;; in the 1928 BCP (no equivalent in 1662 or earlier American BCPs).
    (holy-monday
     :name "Monday before Easter"
     :text "ALMIGHTY God, whose most dear Son went not up to joy but first he suffered pain, and entered not into glory before he was crucified; Mercifully grant that we, walking in the way of the cross, may find it none other than the way of life and peace; through the same thy Son Jesus Christ our Lord. Amen.")

    (holy-tuesday
     :name "Tuesday before Easter"
     :text "O LORD God, whose blessed Son, our Saviour, gave his back to the smiters and hid not his face from shame; Grant us grace to take joyfully the sufferings of the present time, in full assurance of the glory that shall be revealed; through the same thy Son Jesus Christ our Lord. Amen.")

    (holy-wednesday
     :name "Wednesday before Easter"
     :text "ASSIST us mercifully with thy help, O Lord God of our salvation; that we may enter with joy upon the meditation of those mighty acts, whereby thou hast given unto us life and immortality; through Jesus Christ our Lord. Amen.")

    (maundy-thursday
     :name "Thursday before Easter (Maundy Thursday)"
     :text "ALMIGHTY Father, whose dear Son, on the night before he suffered, did institute the Sacrament of his Body and Blood; Mercifully grant that we may thankfully receive the same in remembrance of him, who in these holy mysteries giveth us a pledge of life eternal; the same thy Son Jesus Christ our Lord, who now liveth and reigneth with thee and the Holy Spirit ever, one God, world without end. Amen.")

    ;; Good Friday has three collects in the 1928 BCP; all three are provided
    ;; here under separate keys so the renderer can present them in sequence.
    (good-friday-1
     :name "Good Friday (First Collect)"
     :text "ALMIGHTY God, we beseech thee graciously to behold this thy family, for which our Lord Jesus Christ was contented to be betrayed and given up into the hands of wicked men, and to suffer death upon the cross; who now liveth and reigneth with thee and the Holy Ghost ever, one God, world without end. Amen.")

    (good-friday-2
     :name "Good Friday (Second Collect, for all conditions of men)"
     :text "ALMIGHTY and everlasting God, by whose Spirit the whole body of the Church is governed and sanctified; Receive our supplications and prayers, which we offer before thee for all estates of men in thy holy Church, that every member of the same, in his vocation and ministry, may truly and godly serve thee; through our Lord and Saviour Jesus Christ. Amen.")

    ;; The third Good Friday collect is for the conversion of the world.
    ;; The 1928 text retains the archaic "Jews, Turks, infidels, and heretics."
    (good-friday-3
     :name "Good Friday (Third Collect, for the conversion of all)"
     :text "O MERCIFUL God, who hast made all men, and hatest nothing that thou hast made, nor desirest the death of a sinner, but rather that he should be converted and live; Have mercy upon all Jews, Turks, infidels, and heretics; and take from them all ignorance, hardness of heart, and contempt of thy Word; and so fetch them home, blessed Lord, to thy flock, that they may be saved among the remnant of the true Israelites, and be made one fold under one shepherd, Jesus Christ our Lord, who liveth and reigneth with thee and the Holy Spirit, one God, world without end. Amen.")

    ;; Easter Even: "[the same]" added in 1928.  The full 1928 ending is
    ;; "for his merits, who died, and was buried, and rose again for us,
    ;; the same thy Son Jesus Christ our Lord."
    (easter-even
     :name "Easter Even (Holy Saturday)"
     :text "GRANT, O Lord, that as we are baptized into the death of thy blessed Son, our Saviour Jesus Christ, so by continual mortifying our corrupt affections we may be buried with him; and that through the grave, and gate of death, we may pass to our joyful resurrection; for his merits, who died, and was buried, and rose again for us, the same thy Son Jesus Christ our Lord. Amen.")


    ;;;; ── EASTERTIDE ─────────────────────────────────────────────────────────

    ;; Easter Day: the 1928 text reads "through the same Jesus Christ our
    ;; Lord" (earlier editions have simply "through Jesus Christ our Lord").
    (easter
     :name "Easter Day (The Resurrection of our Lord Jesus Christ)"
     :rubric "This Collect is to be said daily throughout Easter Week."
     :text "ALMIGHTY God, who through thine only-begotten Son Jesus Christ hast overcome death, and opened unto us the gate of everlasting life; We humbly beseech thee that, as by thy special grace preventing us thou dost put into our minds good desires, so by thy continual help we may bring the same to good effect; through the same Jesus Christ our Lord, who liveth and reigneth with thee and the Holy Ghost ever, one God, world without end. Amen.")

    ;; The 1928 BCP provides distinct proper collects for Easter Monday and
    ;; Tuesday (the 1789/1892 BCPs simply repeated the Easter Day collect).
    (easter-monday
     :name "Monday in Easter Week"
     :text "O GOD, whose blessed Son did manifest himself to his disciples in the breaking of bread; Open, we pray thee, the eyes of our faith, that we may behold thee in all thy works; through the same thy Son Jesus Christ our Lord. Amen.")

    (easter-tuesday
     :name "Tuesday in Easter Week"
     :text "GRANT, we beseech thee, Almighty God, that we who celebrate with reverence the Paschal feast, may be found worthy to attain to everlasting joys; through Jesus Christ our Lord. Amen.")

    ;; Sundays after Easter (Low Sunday = after-easter-1).
    (after-easter-1
     :name "First Sunday after Easter (Low Sunday)"
     :text "ALMIGHTY Father, who hast given thine only Son to die for our sins, and to rise again for our justification; Grant us so to put away the leaven of malice and wickedness, that we may always serve thee in pureness of living and truth; through the merits of the same thy Son Jesus Christ our Lord. Amen.")

    ;; Easter 2 text: "through the same thy Son Jesus Christ" — "thy Son" added
    ;; in the 1928 revision (earlier: "through the same Jesus Christ our Lord").
    (after-easter-2
     :name "Second Sunday after Easter"
     :text "ALMIGHTY God, who hast given thine only Son to be unto us both a sacrifice for sin, and also an ensample of godly life; Give us grace that we may always most thankfully receive that his inestimable benefit, and also daily endeavour ourselves to follow the blessed steps of his most holy life; through the same thy Son Jesus Christ our Lord. Amen.")

    (after-easter-3
     :name "Third Sunday after Easter"
     :text "ALMIGHTY God, who showest to them that are in error the light of thy truth, to the intent that they may return into the way of righteousness; Grant unto all those who are admitted into the fellowship of Christ's Religion, that they may avoid those things that are contrary to their profession, and follow all such things as are agreeable to the same; through our Lord Jesus Christ. Amen.")

    (after-easter-4
     :name "Fourth Sunday after Easter"
     :text "O ALMIGHTY God, who alone canst order the unruly wills and affections of sinful men; Grant unto thy people, that they may love the thing which thou commandest, and desire that which thou dost promise; that so, among the sundry and manifold changes of the world, our hearts may surely there be fixed, where true joys are to be found; through Jesus Christ our Lord. Amen.")

    ;; Easter 5 = Rogation Sunday.  The title "Rogation Sunday" was added in
    ;; the 1928 revision.
    (after-easter-5
     :name "Fifth Sunday after Easter (Rogation Sunday)"
     :text "O LORD, from whom all good things do come; Grant to us thy humble servants, that by thy holy inspiration we may think those things that are good, and by thy merciful guiding may perform the same; through our Lord Jesus Christ. Amen.")


    ;;;; ── ASCENSIONTIDE ──────────────────────────────────────────────────────

    ;; Heading "ASCENSIONTIDE" added in 1928.
    (ascension
     :name "The Ascension Day"
     :rubric "This Collect is to be said daily throughout the Octave."
     :text "GRANT, we beseech thee, Almighty God, that like as we do believe thy only-begotten Son our Lord Jesus Christ to have ascended into the heavens; so we may also in heart and mind thither ascend, and with him continually dwell, who liveth and reigneth with thee and the Holy Ghost, one God, world without end. Amen.")

    (after-ascension
     :name "Sunday after Ascension Day"
     :text "O GOD, the King of glory, who hast exalted thine only Son Jesus Christ with great triumph unto thy kingdom in heaven; We beseech thee, leave us not comfortless; but send to us thine Holy Ghost to comfort us, and exalt us unto the same place whither our Saviour Christ is gone before, who liveth and reigneth with thee and the Holy Ghost, one God, world without end. Amen.")


    ;;;; ── WHITSUNTIDE ─────────────────────────────────────────────────────────

    ;; Whitsunday: title expanded in 1928 to "Pentecost, commonly called
    ;; Whitsunday."  The Proposed (1786) Book omits the initial "O" and has
    ;; "the sending" instead of "sending."  The 1928 text used here reads
    ;; "by sending to them."
    (whitsunday
     :name "Whitsunday (Pentecost)"
     :text "O GOD, who as at this time didst teach the hearts of thy faithful people, by sending to them the light of thy Holy Spirit; Grant us by the same Spirit to have a right judgment in all things, and evermore to rejoice in his holy comfort; through the merits of Christ Jesus our Saviour, who liveth and reigneth with thee, in the unity of the same Spirit, one God, world without end. Amen.")

    ;; A second collect for Whitsunday, used when Holy Communion is celebrated
    ;; twice; added in the 1892 revision and retained in 1928.
    (whitsunday-second
     :name "Whitsunday (Second Collect, for Second Celebration)"
     :text "ALMIGHTY and most merciful God, grant, we beseech thee, that by the indwelling of thy Holy Spirit, we may be enlightened and strengthened for thy service; through Jesus Christ our Lord, who liveth and reigneth with thee in the unity of the same Spirit ever, one God, world without end. Amen.")

    ;; The 1928 BCP provides distinct proper collects for Whit Monday and
    ;; Tuesday (the 1789/1892 BCPs simply repeated the Whitsunday collect).
    (whit-monday
     :name "Monday in Whitsun Week"
     :text "SEND, we beseech thee, Almighty God, thy Holy Spirit into our hearts, that he may direct and rule us according to thy will, comfort us in all our afflictions, defend us from all error, and lead us into all truth; through Jesus Christ our Lord, who with thee and the same Holy Spirit liveth and reigneth, one God, world without end. Amen.")

    (whit-tuesday
     :name "Tuesday in Whitsun Week"
     :text "GRANT, we beseech thee, merciful God, that thy Church, being gathered together in unity by thy Holy Spirit, may manifest thy power among all peoples, to the glory of thy Name; through Jesus Christ our Lord, who liveth and reigneth with thee and the same Spirit, one God, world without end. Amen.")


    ;;;; ── TRINITY SEASON ──────────────────────────────────────────────────────

    (trinity-sunday
     :name "Trinity Sunday"
     :text "ALMIGHTY and everlasting God, who hast given unto us thy servants grace, by the confession of a true faith, to acknowledge the glory of the eternal Trinity, and in the power of the Divine Majesty to worship the Unity; We beseech thee that thou wouldest keep us stedfast in this faith, and evermore defend us from all adversities, who livest and reignest, one God, world without end. Amen.")

    (after-trinity-1
     :name "First Sunday after Trinity"
     :text "O GOD, the strength of all those who put their trust in thee; Mercifully accept our prayers; and because, through the weakness of our mortal nature, we can do no good thing without thee, grant us the help of thy grace, that in keeping thy commandments we may please thee, both in will and deed; through Jesus Christ our Lord. Amen.")

    ;; Trinity 2: 1928 reads "those" (Proposed Book has "them").
    (after-trinity-2
     :name "Second Sunday after Trinity"
     :text "O LORD, who never failest to help and govern those whom thou dost bring up in thy stedfast fear and love; Keep us, we beseech thee, under the protection of thy good providence, and make us to have a perpetual fear and love of thy holy Name; through Jesus Christ our Lord. Amen.")

    (after-trinity-3
     :name "Third Sunday after Trinity"
     :text "O LORD, we beseech thee mercifully to hear us; and grant that we, to whom thou hast given an hearty desire to pray, may, by thy mighty aid, be defended and comforted in all dangers and adversities; through Jesus Christ our Lord. Amen.")

    (after-trinity-4
     :name "Fourth Sunday after Trinity"
     :text "O GOD, the protector of all that trust in thee, without whom nothing is strong, nothing is holy; Increase and multiply upon us thy mercy; that, thou being our ruler and guide, we may so pass through things temporal, that we finally lose not the things eternal. Grant this, O heavenly Father, for Jesus Christ's sake our Lord. Amen.")

    (after-trinity-5
     :name "Fifth Sunday after Trinity"
     :text "GRANT, O Lord, we beseech thee, that the course of this world may be so peaceably ordered by thy governance, that thy Church may joyfully serve thee in all godly quietness; through Jesus Christ our Lord. Amen.")

    (after-trinity-6
     :name "Sixth Sunday after Trinity"
     :text "O GOD, who hast prepared for those who love thee such good things as pass man's understanding; Pour into our hearts such love toward thee, that we, loving thee above all things, may obtain thy promises, which exceed all that we can desire; through Jesus Christ our Lord. Amen.")

    (after-trinity-7
     :name "Seventh Sunday after Trinity"
     :text "LORD of all power and might, who art the author and giver of all good things; Graft in our hearts the love of thy Name, increase in us true religion, nourish us with all goodness, and of thy great mercy keep us in the same; through Jesus Christ our Lord. Amen.")

    (after-trinity-8
     :name "Eighth Sunday after Trinity"
     :text "O GOD, whose never-failing providence ordereth all things both in heaven and earth; We humbly beseech thee to put away from us all hurtful things, and to give us those things which are profitable for us; through Jesus Christ our Lord. Amen.")

    ;; Trinity 9: 1928 reads "right" (Proposed Book has "rightful").
    (after-trinity-9
     :name "Ninth Sunday after Trinity"
     :text "GRANT to us, Lord, we beseech thee, the spirit to think and do always such things as are right; that we, who cannot do any thing that is good without thee, may by thee be enabled to live according to thy will; through Jesus Christ our Lord. Amen.")

    (after-trinity-10
     :name "Tenth Sunday after Trinity"
     :text "LET thy merciful ears, O Lord, be open to the prayers of thy humble servants; and, that they may obtain their petitions, make them to ask such things as shall please thee; through Jesus Christ our Lord. Amen.")

    ;; Trinity 11: 1928 reads "chiefly" (Proposed Book has "power most chiefly").
    (after-trinity-11
     :name "Eleventh Sunday after Trinity"
     :text "O GOD, who declarest thy almighty power chiefly in showing mercy and pity; Mercifully grant unto us such a measure of thy grace, that we, running the way of thy commandments, may obtain thy gracious promises, and be made partakers of thy heavenly treasure; through Jesus Christ our Lord. Amen.")

    (after-trinity-12
     :name "Twelfth Sunday after Trinity"
     :text "ALMIGHTY and everlasting God, who art always more ready to hear than we to pray, and art wont to give more than either we desire or deserve; Pour down upon us the abundance of thy mercy; forgiving us those things whereof our conscience is afraid, and giving us those good things which we are not worthy to ask, but through the merits and mediation of Jesus Christ, thy Son, our Lord. Amen.")

    (after-trinity-13
     :name "Thirteenth Sunday after Trinity"
     :text "ALMIGHTY and merciful God, of whose only gift it cometh that thy faithful people do unto thee true and laudable service; Grant, we beseech thee, that we may so faithfully serve thee in this life, that we fail not finally to attain thy heavenly promises; through the merits of Jesus Christ our Lord. Amen.")

    (after-trinity-14
     :name "Fourteenth Sunday after Trinity"
     :text "ALMIGHTY and everlasting God, give unto us the increase of faith, hope, and charity; and, that we may obtain that which thou dost promise, make us to love that which thou dost command; through Jesus Christ our Lord. Amen.")

    (after-trinity-15
     :name "Fifteenth Sunday after Trinity"
     :text "KEEP, we beseech thee, O Lord, thy Church with thy perpetual mercy; and, because the frailty of man without thee cannot but fall, keep us ever by thy help from all things hurtful, and lead us to all things profitable to our salvation; through Jesus Christ our Lord. Amen.")

    (after-trinity-16
     :name "Sixteenth Sunday after Trinity"
     :text "O LORD, we beseech thee, let thy continual pity cleanse and defend thy Church; and, because it cannot continue in safety without thy succour, preserve it evermore by thy help and goodness; through Jesus Christ our Lord. Amen.")

    (after-trinity-17
     :name "Seventeenth Sunday after Trinity"
     :text "LORD, we pray thee that thy grace may always prevent and follow us, and make us continually to be given to all good works; through Jesus Christ our Lord. Amen.")

    (after-trinity-18
     :name "Eighteenth Sunday after Trinity"
     :text "LORD, we beseech thee, grant thy people grace to withstand the temptations of the world, the flesh, and the devil; and with pure hearts and minds to follow thee, the only God; through Jesus Christ our Lord. Amen.")

    (after-trinity-19
     :name "Nineteenth Sunday after Trinity"
     :text "O GOD, forasmuch as without thee we are not able to please thee; Mercifully grant that thy Holy Spirit may in all things direct and rule our hearts; through Jesus Christ our Lord. Amen.")

    ;; Trinity 20: 1928 reads "commandest" (Proposed Book has "wouldest have done").
    (after-trinity-20
     :name "Twentieth Sunday after Trinity"
     :text "O ALMIGHTY and most merciful God, of thy bountiful goodness keep us, we beseech thee, from all things that may hurt us; that we, being ready both in body and soul, may cheerfully accomplish those things which thou commandest; through Jesus Christ our Lord. Amen.")

    (after-trinity-21
     :name "Twenty-first Sunday after Trinity"
     :text "GRANT, we beseech thee, merciful Lord, to thy faithful people pardon and peace, that they may be cleansed from all their sins, and serve thee with a quiet mind; through Jesus Christ our Lord. Amen.")

    (after-trinity-22
     :name "Twenty-second Sunday after Trinity"
     :text "LORD, we beseech thee to keep thy household the Church in continual godliness; that through thy protection it may be free from all adversities, and devoutly given to serve thee in good works, to the glory of thy Name; through Jesus Christ our Lord. Amen.")

    (after-trinity-23
     :name "Twenty-third Sunday after Trinity"
     :text "O GOD, our refuge and strength, who art the author of all godliness; Be ready, we beseech thee, to hear the devout prayers of thy Church; and grant that those things which we ask faithfully we may obtain effectually; through Jesus Christ our Lord. Amen.")

    ;; Trinity 24: the closing doxology in 1928 reads "for Jesus Christ's sake"
    ;; (earlier editions differ slightly).
    (after-trinity-24
     :name "Twenty-fourth Sunday after Trinity"
     :text "O LORD, we beseech thee, absolve thy people from their offences; that through thy bountiful goodness we may all be delivered from the bands of those sins, which by our frailty we have committed. Grant this, O heavenly Father, for Jesus Christ's sake, our blessed Lord and Saviour. Amen.")

    ;; Trinity 25 = the Sunday next before Advent ("Stir-up Sunday").
    ;; The 1928 rubric directs that if there are more than 25 Sundays after
    ;; Trinity, services omitted after Epiphany supply the surplus; the Trinity
    ;; 25 collect always falls on the Sunday next before Advent.
    (after-trinity-25
     :name "Twenty-fifth Sunday after Trinity (Sunday next before Advent)"
     :text "STIR up, we beseech thee, O Lord, the wills of thy faithful people; that they, plenteously bringing forth the fruit of good works, may by thee be plenteously rewarded; through Jesus Christ our Lord. Amen.")


    ;;;; ── HOLY DAYS (SAINTS' DAYS) ───────────────────────────────────────────
    ;;
    ;; Key names match bcp-anglican-1928-lectionary.el:
    ;;   st-*  — single apostle / evangelist / saint
    ;;   ss-*  — shared feast of two apostles
    ;;   other — holy-innocents, conversion-of-st-paul, purification,
    ;;            annunciation, transfiguration, all-saints
    ;;
    ;; For 1928 text variants, see inline comments; notable changes are:
    ;;   - St John Ev.: "illumined" (1928) vs "instructed" (1892) vs "enlightened" (Prop.)
    ;;   - St John Ev.: "life everlasting" (1928) vs "everlasting life" (1892)
    ;;   - St John Baptist: "through the same thy Son Jesus Christ" (1928)
    ;;   - St Peter: "through the same thy Son Jesus Christ" (1928)
    ;;   - All Saints: "through the same thy Son Jesus Christ" (1928)
    ;;   - St Luke: entirely rewritten in 1928

    ;; Advent season
    (st-andrew
     :name "Saint Andrew the Apostle (November 30)"
     :text "ALMIGHTY God, who didst give such grace unto thy holy Apostle Saint Andrew, that he readily obeyed the calling of thy Son Jesus Christ, and followed him without delay; Grant unto us all, that we, being called by thy holy Word, may forthwith give up ourselves obediently to fulfil thy holy commandments; through the same Jesus Christ our Lord. Amen.")

    (st-thomas
     :name "Saint Thomas the Apostle (December 21)"
     ;; 1928: "greater confirmation" (Proposed Book: "more confirmation").
     :text "ALMIGHTY and everliving God, who, for the greater confirmation of the faith, didst suffer thy holy Apostle Thomas to be doubtful in thy Son's resurrection; Grant us so perfectly, and without all doubt, to believe in thy Son Jesus Christ, that our faith in thy sight may never be reproved. Hear us, O Lord, through the same Jesus Christ, to whom, with thee and the Holy Ghost, be all honour and glory, now and for evermore. Amen.")

    ;; Christmas season
    (st-stephen
     :name "Saint Stephen, Deacon and Martyr (December 26)"
     :text "GRANT, O Lord, that, in all our sufferings here upon earth for the testimony of thy truth, we may stedfastly look up to heaven, and by faith behold the glory that shall be revealed; and, being filled with the Holy Ghost, may learn to love and bless our persecutors by the example of thy first Martyr Saint Stephen, who prayed for his murderers to thee, O blessed Jesus, who standest at the right hand of God to succour all those who suffer for thee, our only Mediator and Advocate. Amen.")

    (st-john-evangelist
     :name "Saint John, Apostle and Evangelist (December 27)"
     ;; 1928: "illumined" (1892: "instructed"; Proposed: "enlightened").
     ;; 1928: "life everlasting" (Proposed: "the light of everlasting life"; 1892: "everlasting life").
     :text "MERCIFUL Lord, we beseech thee to cast thy bright beams of light upon thy Church, that it, being illumined by the doctrine of thy blessed Apostle and Evangelist Saint John, may so walk in the light of thy truth, that it may at length attain to life everlasting; through Jesus Christ our Lord. Amen.")

    (holy-innocents
     :name "The Holy Innocents (December 28)"
     :text "O ALMIGHTY God, who out of the mouths of babes and sucklings hast ordained strength, and madest infants to glorify thee by their deaths: Mortify and kill all vices in us, and so strengthen us by thy grace, that by the innocency of our lives, and constancy of our faith even unto death, we may glorify thy holy Name; through Jesus Christ our Lord. Amen.")

    ;; Epiphany season
    (conversion-of-st-paul
     :name "The Conversion of Saint Paul (January 25)"
     :text "O GOD, who, through the preaching of the blessed Apostle Saint Paul, hast caused the light of the Gospel to shine throughout the world; Grant, we beseech thee, that we, having his wonderful conversion in remembrance, may show forth our thankfulness unto thee for the same, by following the holy doctrine which he taught; through Jesus Christ our Lord. Amen.")

    (purification
     :name "The Presentation of Christ in the Temple (Purification of Saint Mary the Virgin, February 2)"
     :text "ALMIGHTY and everliving God, we humbly beseech thy Majesty, that, as thy only-begotten Son was this day presented in the temple in substance of our flesh, so we may be presented unto thee with pure and clean hearts, by the same thy Son Jesus Christ our Lord. Amen.")

    (st-matthias
     :name "Saint Matthias the Apostle (February 24)"
     :text "O ALMIGHTY God, who into the place of the traitor Judas didst choose thy faithful servant Matthias to be of the number of the twelve Apostles; Grant that thy Church, being alway preserved from false Apostles, may be ordered and guided by faithful and true pastors; through Jesus Christ our Lord. Amen.")

    (annunciation
     :name "The Annunciation of the Blessed Virgin Mary (March 25)"
     :text "WE beseech thee, O Lord, pour thy grace into our hearts; that, as we have known the incarnation of thy Son Jesus Christ by the message of an Angel, so by his cross and passion we may be brought unto the glory of his resurrection; through the same Jesus Christ our Lord. Amen.")

    ;; Eastertide / early summer
    (st-mark
     :name "Saint Mark the Evangelist (April 25)"
     :text "O ALMIGHTY God, who hast instructed thy holy Church with the heavenly doctrine of thy Evangelist Saint Mark; Give us grace that, being not like children carried away with every blast of vain doctrine, we may be established in the truth of thy holy Gospel; through Jesus Christ our Lord. Amen.")

    (ss-philip-and-james
     :name "Saint Philip and Saint James, Apostles (May 1)"
     :text "O ALMIGHTY God, whom truly to know is everlasting life; Grant us perfectly to know thy Son Jesus Christ to be the way, the truth, and the life; that, following the steps of thy holy Apostles, Saint Philip and Saint James, we may stedfastly walk in the way that leadeth to eternal life through the same thy Son Jesus Christ our Lord. Amen.")

    (st-barnabas
     :name "Saint Barnabas the Apostle (June 11)"
     :text "O LORD God Almighty, who didst endue thy holy Apostle Barnabas with singular gifts of the Holy Ghost; Leave us not, we beseech thee, destitute of thy manifold gifts, nor yet of grace to use them alway to thy honour and glory; through Jesus Christ our Lord. Amen.")

    ;; 1928: closing doxology changed to "through the same thy Son Jesus Christ."
    (st-john-baptist
     :name "Saint John Baptist (June 24)"
     :text "ALMIGHTY God, by whose providence thy servant John Baptist was wonderfully born, and sent to prepare the way of thy Son our Saviour by preaching repentance; Make us so to follow his doctrine and holy life, that we may truly repent according to his preaching; and after his example constantly speak the truth, boldly rebuke vice, and patiently suffer for the truth's sake; through the same thy Son Jesus Christ our Lord. Amen.")

    ;; 1928: closing doxology changed to "through the same thy Son Jesus Christ."
    (st-peter
     :name "Saint Peter the Apostle (June 29)"
     :text "O ALMIGHTY God, who by thy Son Jesus Christ didst give to thy Apostle Saint Peter many excellent gifts, and commandedst him earnestly to feed thy flock; Make, we beseech thee, all Bishops and Pastors diligently to preach thy holy Word, and the people obediently to follow the same, that they may receive the crown of everlasting glory; through the same thy Son Jesus Christ our Lord. Amen.")

    (st-james
     :name "Saint James the Apostle (July 25)"
     :text "GRANT, O merciful God, that, as thine holy Apostle Saint James, leaving his father and all that he had, without delay was obedient unto the calling of thy Son Jesus Christ, and followed him; so we, forsaking all worldly and carnal affections, may be evermore ready to follow thy holy commandments; through Jesus Christ our Lord. Amen.")

    (transfiguration
     :name "The Transfiguration of Christ (August 6)"
     :text "O GOD, who on the mount didst reveal to chosen witnesses thine only-begotten Son wonderfully transfigured, in raiment white and glistering; Mercifully grant that we, being delivered from the disquietude of this world, may be permitted to behold the King in his beauty, who with thee, O Father, and thee, O Holy Ghost, liveth and reigneth, one God, world without end. Amen.")

    (st-bartholomew
     :name "Saint Bartholomew the Apostle (August 24)"
     :text "O ALMIGHTY and everlasting God, who didst give to thine Apostle Bartholomew grace truly to believe and to preach thy Word; Grant, we beseech thee, unto thy Church to love that Word which he believed, and both to preach and receive the same; through Jesus Christ our Lord. Amen.")

    (st-matthew
     :name "Saint Matthew, Apostle and Evangelist (September 21)"
     :text "O ALMIGHTY God, who by thy blessed Son didst call Matthew from the receipt of custom to be an Apostle and Evangelist; Grant us grace to forsake all covetous desires, and inordinate love of riches, and to follow the same thy Son Jesus Christ, who liveth and reigneth with thee and the Holy Ghost, one God, world without end. Amen.")

    (st-michael-and-all-angels
     :name "Saint Michael and all Angels (September 29)"
     :text "O EVERLASTING God, who hast ordained and constituted the services of Angels and men in a wonderful order; Mercifully grant that, as thy holy Angels always do thee service in heaven, so, by thy appointment, they may succour and defend us on earth; through Jesus Christ our Lord. Amen.")

    ;; 1928: entirely new collect replacing the 1789/1892 version.
    ;; 1789/1892: "Almighty God, who calledst Luke the Physician... all the diseases
    ;; of our souls may be healed; through the merits of thy Son Jesus Christ our Lord."
    (st-luke
     :name "Saint Luke the Evangelist (October 18)"
     :text "ALMIGHTY God, who didst inspire thy servant Saint Luke the Physician, to set forth in the Gospel the love and healing power of thy Son; Manifest in thy Church the like power and love, to the healing of our bodies and our souls; through the same thy Son Jesus Christ our Lord. Amen.")

    (ss-simon-and-jude
     :name "Saint Simon and Saint Jude, Apostles (October 28)"
     :text "O ALMIGHTY God, who hast built thy Church upon the foundation of the Apostles and Prophets, Jesus Christ himself being the head corner-stone; Grant us so to be joined together in unity of spirit by their doctrine, that we may be made an holy temple acceptable unto thee; through Jesus Christ our Lord. Amen.")

    ;; 1928: closing doxology changed to "through the same thy Son Jesus Christ."
    (all-saints
     :name "All Saints' Day (November 1)"
     :rubric "This Collect is to be said daily throughout the Octave."
     :text "O ALMIGHTY God, who hast knit together thine elect in one communion and fellowship, in the mystical body of thy Son Christ our Lord; Grant us grace so to follow thy blessed Saints in all virtuous and godly living, that we may come to those unspeakable joys which thou hast prepared for those who unfeignedly love thee; through the same thy Son Jesus Christ our Lord. Amen.")


    ;;;; ── COMMONS AND SPECIAL OCCASIONS ─────────────────────────────────────

    ;; Common of Saints: two alternative collects.  The second uses the
    ;; placeholder "[Saint——]" for the name of the specific saint; the
    ;; renderer must substitute the saint's name.
    (common-of-saints-1
     :name "A Saint's Day (First Collect)"
     :text "ALMIGHTY and everlasting God, who dost enkindle the name of thy love in the hearts of the Saints; Grant to us, thy humble servants, the same faith and power of love; that, as we rejoice in their triumphs, we may profit by their examples; through Jesus Christ our Lord. Amen.")

    (common-of-saints-2
     :name "A Saint's Day (Second Collect, with saint's name)"
     ;; The placeholder [Saint——] should be replaced with the saint's name
     ;; at render time (e.g. "thy servant Saint Aidan").
     :text "O ALMIGHTY God, who hast called us to faith in thee, and hast compassed us about with so great a cloud of witnesses; Grant that we, encouraged by the good examples of thy Saints, and especially of thy servant [Saint——], may persevere in running the race that is set before us, until at length, through thy mercy, we, with them, attain to thine eternal joy; through him who is the author and finisher of our faith, thy Son Jesus Christ our Lord. Amen.")

    (dedication-of-church
     :name "Feast of the Dedication of a Church"
     :text "O GOD, whom year by year we praise for the dedication of this church; Hear, we beseech thee, the prayers of thy people, and grant that whosoever shall worship before thee in this place, may obtain thy merciful aid and protection; through Jesus Christ our Lord. Amen.")

    ;; General Ember Day collect, used for all four seasonal Ember Day sets.
    ;; Specific lesson overrides for Advent Ember Days are encoded separately
    ;; in the lesson table under ember-advent-{wednesday,friday,saturday}.
    (ember-days
     :name "The Ember Days (at the Four Seasons)"
     :text "O ALMIGHTY God, who hast committed to the hands of men the ministry of reconciliation; We humbly beseech thee, by the inspiration of thy Holy Spirit, to put it into the hearts of many to offer themselves for this ministry; that thereby mankind may be drawn to thy blessed kingdom; through Jesus Christ our Lord. Amen.")

    ;; Rogation Days: the three days before Ascension (Mon–Wed).
    ;; Lesson entries for Rogation Mon/Tue/Wed are in the lesson table.
    (rogation-days
     :name "The Rogation Days (Three Days before Ascension)"
     :text "ALMIGHTY God, Lord of heaven and earth; We beseech thee to pour forth thy blessing upon this land, and to give us a fruitful season; that we, constantly receiving thy bounty, may evermore give thanks unto thee in thy holy Church; through Jesus Christ our Lord. Amen.")

    ;; American propers added in the 1928 revision.
    (independence-day
     :name "Independence Day (July 4)"
     :text "O ETERNAL God, through whose mighty power our fathers won their liberties of old; Grant, we beseech thee, that we and all the people of this land may have grace to maintain these liberties in righteousness and peace; through Jesus Christ our Lord. Amen.")

    (thanksgiving-day
     :name "Thanksgiving Day"
     :text "O MOST merciful Father, who hast blessed the labours of the husbandman in the returns of the fruits of the earth; We give thee humble and hearty thanks for this thy bounty; beseeching thee to continue thy loving-kindness to us, that our land may still yield her increase, to thy glory and our comfort; through Jesus Christ our Lord. Amen.")


    ;;;; ── OCCASIONAL OFFICES ─────────────────────────────────────────────────

    (matrimony
     :name "At a Marriage"
     :text "O ETERNAL God, we humbly beseech thee, favourably to behold these thy servants now (or about to be) joined in wedlock according to thy holy ordinance; and grant that they, seeking first thy kingdom and thy righteousness, may obtain the manifold blessings of thy grace; through Jesus Christ our Lord. Amen.")

    ;; Two alternative collects are provided for the Burial of the Dead.
    (burial-1
     :name "At the Burial of the Dead (First Collect)"
     :text "O ETERNAL Lord God, who holdest all souls in life; Vouchsafe, we beseech thee, to thy whole Church in paradise and on earth, thy light and thy peace; and grant that we, following the good examples of those who have served thee here and are now at rest, may at the last enter with them into thine unending joy; through Jesus Christ our Lord. Amen.")

    (burial-2
     :name "At the Burial of the Dead (Second Collect)"
     :text "O GOD, whose mercies cannot be numbered; Accept our prayers on behalf of the soul of thy servant departed, and grant him an entrance into the land of light and joy, in the fellowship of thy saints; through Jesus Christ our Lord. Amen.")

    )
  "Collect table for the 1928 American Book of Common Prayer.
Each entry is (KEY :name STRING [:rubric STRING] :text STRING).
Epistles and Gospels (Communion propers) are out of scope.")


;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Communion Propers: Epistle and Gospel
;;;; ──────────────────────────────────────────────────────────────────────────

;; Ref format: (BOOK CHAPTER START END) or (BOOK CHAPTER) for a whole chapter,
;; or ((BOOK CH1 V1 V2) (BOOK CH2 V1 V2)) for a reading that spans chapters.
;; END may be nil to mean "to end of chapter".
;; Book abbreviations follow Roman-numeral style matching bcp-anglican-1928-lectionary.el.
;;
;; Changes vs. the 1662 BCP:
;;   Ascension:       Gospel Mark 16:14-20  → Luke 24:49-53
;;   St Thomas:       Epistle Eph 2:19-22   → Heb 10:35-11:1
;;   SS Simon & Jude: Epistle Jude 1:1-8    → Eph 2:19-22
;;   Trinity 9:       Gospel  Luke 16:1-9   → Luke 15:11-32 (Prodigal Son)
;;
;; Entries with no 1662 equivalent (new in 1928):
;;   christmas-second, after-christmas-2 (rare second Sunday after Christmas),
;;   whitsunday-second, transfiguration, independence-day, thanksgiving-day,
;;   common-of-saints, dedication-of-church, ember-days, rogation-days,
;;   matrimony, burial.

(defconst bcp-1928-communion-propers
  '(

    ;;;; ── ADVENT ─────────────────────────────────────────────────────────────

    (advent-1
     :name    "First Sunday in Advent"
     :epistle ("Rom" 13 8 14)
     :gospel  ("Matt" 21 1 13))

    (advent-2
     :name    "Second Sunday in Advent"
     :epistle ("Rom" 15 4 13)
     :gospel  ("Luke" 21 25 33))

    (advent-3
     :name    "Third Sunday in Advent"
     :epistle ("I Cor" 4 1 5)
     :gospel  ("Matt" 11 2 10))

    (advent-4
     :name    "Fourth Sunday in Advent"
     :epistle ("Phil" 4 4 7)
     :gospel  ("John" 1 19 28))

    ;;;; ── CHRISTMAS ───────────────────────────────────────────────────────────

    (christmas
     :name    "Christmas Day"
     :epistle ("Heb" 1 1 12)
     :gospel  ("John" 1 1 14))

    ;; 1928 provides a second Christmas service with different propers.
    (christmas-second
     :name    "Christmas Day (Second Service)"
     :epistle ("Tit" 3 4 7)
     :gospel  ("Luke" 2 1 14))

    (st-stephen
     :name    "St Stephen's Day"
     :epistle ("Acts" 7 55 60)
     :gospel  ("Matt" 23 34 39))

    (st-john-evangelist
     :name    "St John the Evangelist"
     :epistle ("I John" 1)
     :gospel  ("John" 21 19 25))

    (holy-innocents
     :name    "Holy Innocents"
     :epistle ("Rev" 14 1 5)
     :gospel  ("Matt" 2 13 18))

    (sunday-after-christmas
     :name    "Sunday after Christmas Day"
     :epistle ("Gal" 4 1 7)
     :gospel  ("Matt" 1 18 25))

    ;; Second Sunday after Christmas (rare; occurs when Christmas falls on a
    ;; Thursday or earlier and Jan 1 is not Sunday).
    (after-christmas-2
     :name    "Second Sunday after Christmas Day"
     :epistle ("I Pet" 2 1 10)
     :gospel  ("John" 1 1 18))

    (circumcision
     :name    "Circumcision of Christ"
     :epistle ("Rom" 4 8 14)
     :gospel  ("Luke" 2 15 21))

    ;;;; ── EPIPHANY ────────────────────────────────────────────────────────────

    (epiphany
     :name    "Epiphany"
     :epistle ("Eph" 3 1 12)
     :gospel  ("Matt" 2 1 12))

    (after-epiphany-1
     :name    "First Sunday after Epiphany"
     :epistle ("Rom" 12 1 5)
     :gospel  ("Luke" 2 41 52))

    (after-epiphany-2
     :name    "Second Sunday after Epiphany"
     :epistle ("Rom" 12 6 16)
     :gospel  ("John" 2 1 11))

    (after-epiphany-3
     :name    "Third Sunday after Epiphany"
     :epistle ("Rom" 12 16 21)
     :gospel  ("Matt" 8 1 13))

    (after-epiphany-4
     :name    "Fourth Sunday after Epiphany"
     :epistle ("Rom" 13 1 7)
     :gospel  ("Matt" 8 23 34))

    (after-epiphany-5
     :name    "Fifth Sunday after Epiphany"
     :epistle ("Col" 3 12 17)
     :gospel  ("Matt" 13 24 30))

    (after-epiphany-6
     :name    "Sixth Sunday after Epiphany"
     :epistle ("I John" 3 1 8)
     :gospel  ("Matt" 24 23 31))

    ;;;; ── PRE-LENT ────────────────────────────────────────────────────────────

    (septuagesima
     :name    "Septuagesima Sunday"
     :epistle ("I Cor" 9 24 27)
     :gospel  ("Matt" 20 1 16))

    (sexagesima
     :name    "Sexagesima Sunday"
     :epistle ("II Cor" 11 19 31)
     :gospel  ("Luke" 8 4 15))

    (quinquagesima
     :name    "Quinquagesima Sunday"
     :epistle ("I Cor" 13)
     :gospel  ("Luke" 18 31 43))

    ;;;; ── LENT ───────────────────────────────────────────────────────────────

    (ash-wednesday
     :name    "Ash Wednesday"
     :epistle ("Joel" 2 12 17)
     :gospel  ("Matt" 6 16 21))

    (lent-1
     :name    "First Sunday in Lent"
     :epistle ("II Cor" 6 1 10)
     :gospel  ("Matt" 4 1 11))

    (lent-2
     :name    "Second Sunday in Lent"
     :epistle ("I Thess" 4 1 8)
     :gospel  ("Matt" 15 21 28))

    (lent-3
     :name    "Third Sunday in Lent"
     :epistle ("Eph" 5 1 14)
     :gospel  ("Luke" 11 14 28))

    (lent-4
     :name    "Fourth Sunday in Lent"
     :epistle ("Gal" 4 21 31)
     :gospel  ("John" 6 1 14))

    (lent-5
     :name    "Fifth Sunday in Lent (Passion Sunday)"
     :epistle ("Heb" 9 11 15)
     :gospel  ("John" 8 46 59))

    ;;;; ── HOLY WEEK ──────────────────────────────────────────────────────────

    (palm-sunday
     :name    "Sunday next before Easter (Palm Sunday)"
     :epistle ("Phil" 2 5 11)
     :gospel  ("Matt" 27 1 54))

    (holy-monday
     :name    "Monday in Holy Week"
     :epistle ("Isa" 63)
     :gospel  ("Mark" 14))

    (holy-tuesday
     :name    "Tuesday in Holy Week"
     :epistle ("Isa" 50 5 11)
     :gospel  ("Mark" 15 1 39))

    (holy-wednesday
     :name    "Wednesday in Holy Week"
     :epistle ("Heb" 9 16 28)
     :gospel  ("Luke" 22))

    (maundy-thursday
     :name    "Thursday in Holy Week (Maundy Thursday)"
     :epistle ("I Cor" 11 17 34)
     :gospel  ("Luke" 23 1 49))

    (good-friday
     :name    "Good Friday"
     :epistle ("Heb" 10 1 25)
     :gospel  ("John" 19 1 37))

    (easter-even
     :name    "Easter Even"
     :epistle ("I Pet" 3 17 22)
     :gospel  ("Matt" 27 57 66))

    ;;;; ── EASTER ─────────────────────────────────────────────────────────────

    (easter
     :name    "Easter Day"
     :epistle ("Col" 3 1 7)
     :gospel  ("John" 20 1 10))

    (easter-monday
     :name    "Monday in Easter Week"
     :epistle ("Acts" 10 34 43)
     :gospel  ("Luke" 24 13 35))

    (easter-tuesday
     :name    "Tuesday in Easter Week"
     :epistle ("Acts" 13 26 41)
     :gospel  ("Luke" 24 36 48))

    (after-easter-1
     :name    "First Sunday after Easter"
     :epistle ("I John" 5 4 12)
     :gospel  ("John" 20 19 23))

    (after-easter-2
     :name    "Second Sunday after Easter"
     :epistle ("I Pet" 2 19 25)
     :gospel  ("John" 10 11 16))

    (after-easter-3
     :name    "Third Sunday after Easter"
     :epistle ("I Pet" 2 11 17)
     :gospel  ("John" 16 16 22))

    (after-easter-4
     :name    "Fourth Sunday after Easter"
     :epistle ("Jas" 1 17 21)
     :gospel  ("John" 16 5 15))

    (after-easter-5
     :name    "Fifth Sunday after Easter (Rogation Sunday)"
     :epistle ("Jas" 1 22 27)
     :gospel  ("John" 16 23 33))

    ;;;; ── ASCENSIONTIDE ──────────────────────────────────────────────────────

    ;; 1928: gospel Luke 24:49-53 (1662: Mark 16:14-20).
    (ascension
     :name    "Ascension Day"
     :epistle ("Acts" 1 1 11)
     :gospel  ("Luke" 24 49 53))

    (after-ascension
     :name    "Sunday after Ascension"
     :epistle ("I Pet" 4 7 11)
     :gospel  (("John" 15 26 nil) ("John" 16 1 4)))

    ;;;; ── WHITSUNTIDE ────────────────────────────────────────────────────────

    (whitsunday
     :name    "Whitsunday"
     :epistle ("Acts" 2 1 11)
     :gospel  ("John" 14 15 31))

    ;; 1928 appoints alternative propers for a second Whitsunday service.
    (whitsunday-second
     :name    "Whitsunday (Second Service)"
     :epistle ("I Cor" 12 4 11)
     :gospel  ("Luke" 11 9 13))

    (whit-monday
     :name    "Monday in Whitsun Week"
     :epistle ("Acts" 10 34 48)
     :gospel  ("John" 3 16 21))

    (whit-tuesday
     :name    "Tuesday in Whitsun Week"
     :epistle ("Acts" 8 14 17)
     :gospel  ("John" 10 1 10))

    ;;;; ── TRINITY ────────────────────────────────────────────────────────────

    (trinity-sunday
     :name    "Trinity Sunday"
     :epistle ("Rev" 4)
     :gospel  ("John" 3 1 15))

    (after-trinity-1
     :name    "First Sunday after Trinity"
     :epistle ("I John" 4 7 21)
     :gospel  ("Luke" 16 19 31))

    (after-trinity-2
     :name    "Second Sunday after Trinity"
     :epistle ("I John" 3 13 24)
     :gospel  ("Luke" 14 16 24))

    (after-trinity-3
     :name    "Third Sunday after Trinity"
     :epistle ("I Pet" 5 5 11)
     :gospel  ("Luke" 15 1 10))

    (after-trinity-4
     :name    "Fourth Sunday after Trinity"
     :epistle ("Rom" 8 18 23)
     :gospel  ("Luke" 6 36 42))

    (after-trinity-5
     :name    "Fifth Sunday after Trinity"
     :epistle ("I Pet" 3 8 15)
     :gospel  ("Luke" 5 1 11))

    (after-trinity-6
     :name    "Sixth Sunday after Trinity"
     :epistle ("Rom" 6 3 11)
     :gospel  ("Matt" 5 20 26))

    (after-trinity-7
     :name    "Seventh Sunday after Trinity"
     :epistle ("Rom" 6 19 23)
     :gospel  ("Mark" 8 1 9))

    (after-trinity-8
     :name    "Eighth Sunday after Trinity"
     :epistle ("Rom" 8 12 17)
     :gospel  ("Matt" 7 15 21))

    ;; 1928: gospel Luke 15:11-32 (Prodigal Son) (1662: Luke 16:1-9).
    (after-trinity-9
     :name    "Ninth Sunday after Trinity"
     :epistle ("I Cor" 10 1 13)
     :gospel  ("Luke" 15 11 32))

    (after-trinity-10
     :name    "Tenth Sunday after Trinity"
     :epistle ("I Cor" 12 1 11)
     :gospel  ("Luke" 19 41 47))

    (after-trinity-11
     :name    "Eleventh Sunday after Trinity"
     :epistle ("I Cor" 15 1 11)
     :gospel  ("Luke" 18 9 14))

    (after-trinity-12
     :name    "Twelfth Sunday after Trinity"
     :epistle ("II Cor" 3 4 9)
     :gospel  ("Mark" 7 31 37))

    (after-trinity-13
     :name    "Thirteenth Sunday after Trinity"
     :epistle ("Gal" 3 16 22)
     :gospel  ("Luke" 10 23 37))

    (after-trinity-14
     :name    "Fourteenth Sunday after Trinity"
     :epistle ("Gal" 5 16 24)
     :gospel  ("Luke" 17 11 19))

    (after-trinity-15
     :name    "Fifteenth Sunday after Trinity"
     :epistle ("Gal" 6 11 18)
     :gospel  ("Matt" 6 24 34))

    (after-trinity-16
     :name    "Sixteenth Sunday after Trinity"
     :epistle ("Eph" 3 13 21)
     :gospel  ("Luke" 7 11 17))

    (after-trinity-17
     :name    "Seventeenth Sunday after Trinity"
     :epistle ("Eph" 4 1 6)
     :gospel  ("Luke" 14 1 11))

    (after-trinity-18
     :name    "Eighteenth Sunday after Trinity"
     :epistle ("I Cor" 1 4 8)
     :gospel  ("Matt" 22 34 46))

    (after-trinity-19
     :name    "Nineteenth Sunday after Trinity"
     :epistle ("Eph" 4 17 32)
     :gospel  ("Matt" 9 1 8))

    (after-trinity-20
     :name    "Twentieth Sunday after Trinity"
     :epistle ("Eph" 5 15 21)
     :gospel  ("Matt" 22 1 14))

    (after-trinity-21
     :name    "Twenty-first Sunday after Trinity"
     :epistle ("Eph" 6 10 20)
     :gospel  ("John" 4 46 54))

    (after-trinity-22
     :name    "Twenty-second Sunday after Trinity"
     :epistle ("Phil" 1 3 11)
     :gospel  ("Matt" 18 21 35))

    (after-trinity-23
     :name    "Twenty-third Sunday after Trinity"
     :epistle ("Phil" 3 17 21)
     :gospel  ("Matt" 22 15 22))

    (after-trinity-24
     :name    "Twenty-fourth Sunday after Trinity"
     :epistle ("Col" 1 3 12)
     :gospel  ("Matt" 9 18 26))

    (after-trinity-25
     :name    "Sunday next before Advent (Twenty-fifth Sunday after Trinity)"
     :epistle ("Jer" 23 5 8)
     :gospel  ("John" 6 5 14))

    ;;;; ── SAINTS' DAYS ───────────────────────────────────────────────────────

    (st-andrew
     :name    "St Andrew the Apostle (November 30)"
     :epistle ("Rom" 10 9 21)
     :gospel  ("Matt" 4 18 22))

    ;; 1928: epistle Heb 10:35-11:1 (1662: Eph 2:19-22).
    (st-thomas
     :name    "St Thomas the Apostle (December 21)"
     :epistle (("Heb" 10 35 nil) ("Heb" 11 1 1))
     :gospel  ("John" 20 24 31))

    (conversion-of-st-paul
     :name    "Conversion of St Paul (January 25)"
     :epistle ("Acts" 9 1 22)
     :gospel  ("Matt" 19 27 30))

    (purification
     :name    "Purification of the Blessed Virgin Mary (February 2)"
     :epistle ("Mal" 3 1 5)
     :gospel  ("Luke" 2 22 40))

    (st-matthias
     :name    "St Matthias the Apostle (February 24)"
     :epistle ("Acts" 1 15 26)
     :gospel  ("Matt" 11 25 30))

    (annunciation
     :name    "Annunciation of the Blessed Virgin Mary (March 25)"
     :epistle ("Isa" 7 10 15)
     :gospel  ("Luke" 1 26 38))

    (st-mark
     :name    "St Mark the Evangelist (April 25)"
     :epistle ("Eph" 4 7 16)
     :gospel  ("John" 15 1 11))

    (ss-philip-and-james
     :name    "St Philip and St James, Apostles (May 1)"
     :epistle ("Jas" 1 1 12)
     :gospel  ("John" 14 1 14))

    (st-barnabas
     :name    "St Barnabas the Apostle (June 11)"
     :epistle ("Acts" 11 22 30)
     :gospel  ("John" 15 12 16))

    (st-john-baptist
     :name    "Nativity of St John the Baptist (June 24)"
     :epistle ("Isa" 40 1 11)
     :gospel  ("Luke" 1 57 80))

    (st-peter
     :name    "St Peter the Apostle (June 29)"
     :epistle ("Acts" 12 1 11)
     :gospel  ("Matt" 16 13 19))

    (st-james
     :name    "St James the Apostle (July 25)"
     :epistle (("Acts" 11 27 nil) ("Acts" 12 1 3))
     :gospel  ("Matt" 20 20 28))

    (transfiguration
     :name    "Transfiguration of our Lord (August 6)"
     :epistle ("II Pet" 1 13 18)
     :gospel  ("Luke" 9 28 36))

    (st-bartholomew
     :name    "St Bartholomew the Apostle (August 24)"
     :epistle ("Acts" 5 12 16)
     :gospel  ("Luke" 22 24 30))

    (st-matthew
     :name    "St Matthew the Apostle (September 21)"
     :epistle ("II Cor" 4 1 6)
     :gospel  ("Matt" 9 9 13))

    (st-michael-and-all-angels
     :name    "St Michael and All Angels (September 29)"
     :epistle ("Rev" 12 7 12)
     :gospel  ("Matt" 18 1 10))

    (st-luke
     :name    "St Luke the Evangelist (October 18)"
     :epistle ("II Tim" 4 5 15)
     :gospel  ("Luke" 10 1 7))

    ;; 1928: epistle Eph 2:19-22 (1662: Jude 1:1-8).
    (ss-simon-and-jude
     :name    "St Simon and St Jude, Apostles (October 28)"
     :epistle ("Eph" 2 19 22)
     :gospel  ("John" 15 17 27))

    (all-saints
     :name    "All Saints' Day (November 1)"
     :epistle ("Rev" 7 2 12)
     :gospel  ("Matt" 5 1 12))

    ;;;; ── COMMONS AND SPECIAL OCCASIONS ─────────────────────────────────────

    (common-of-saints
     :name    "A Saint's Day (Common)"
     :epistle ("Heb" 12 1 2)
     :gospel  ("Matt" 25 31 40))

    (dedication-of-church
     :name    "Dedication of a Church"
     :epistle ("I Pet" 2 1 5)
     :gospel  ("Matt" 21 12 16))

    ;; General Ember Day propers; specific seasons (Advent, Lent, Whitsun,
    ;; Holy Cross) use the same E&G in the 1928 BCP.
    (ember-days
     :name    "Ember Days"
     :epistle ("Acts" 13 44 49)
     :gospel  ("Luke" 4 16 21))

    (rogation-days
     :name    "Rogation Days"
     :epistle ("Ezek" 34 25 31)
     :gospel  ("Luke" 11 5 13))

    (independence-day
     :name    "Independence Day (July 4)"
     :epistle ("Deut" 10 17 21)
     :gospel  ("Matt" 5 43 48))

    (thanksgiving-day
     :name    "Thanksgiving Day"
     :epistle ("Jas" 1 16 27)
     :gospel  ("Matt" 6 25 34))

    ;;;; ── OCCASIONAL OFFICES ─────────────────────────────────────────────────

    (matrimony
     :name    "At a Marriage"
     :epistle ("Eph" 5 20 33)
     :gospel  ("Matt" 19 4 6))

    (burial
     :name    "At the Burial of the Dead"
     :epistle ("I Thess" 4 13 18)
     :gospel  ("John" 6 37 40))

  )
  "Communion propers (Epistle and Gospel) for the 1928 American BCP.
Each entry is (KEY :name STRING :epistle REF :gospel REF).
REF is (BOOK CHAPTER START END), (BOOK CHAPTER) for a whole chapter, or
a list of such refs for readings spanning chapter boundaries.
END may be nil to mean end-of-chapter.")


(defun bcp-1928-communion-proper (symbol)
  "Return the communion proper plist for SYMBOL, or nil.
Returns (:name STRING :epistle REF :gospel REF)."
  (cdr (assq symbol bcp-1928-communion-propers)))

(defun bcp-1928-epistle (symbol)
  "Return the Epistle ref for SYMBOL, or nil."
  (plist-get (bcp-1928-communion-proper symbol) :epistle))

(defun bcp-1928-gospel (symbol)
  "Return the Gospel ref for SYMBOL, or nil."
  (plist-get (bcp-1928-communion-proper symbol) :gospel))


(defun bcp-1928-collect (symbol)
  "Return the collect plist for SYMBOL from `bcp-1928-collects', or nil.
Returns a plist of the form (:name STRING :text STRING)."
  (cdr (assq symbol bcp-1928-collects)))

(defun bcp-1928-collect-text (symbol)
  "Return the collect text string for SYMBOL, or nil."
  (plist-get (bcp-1928-collect symbol) :text))


(provide 'bcp-anglican-1928-data)
;;; bcp-anglican-1928-data.el ends here
