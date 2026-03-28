;;; bcp-liturgy-canticles.el --- Liturgical canticle texts -*- lexical-binding: t -*-

;;; Commentary:

;; A language-agnostic library of liturgical canticle texts for the
;; BCP — Biblical Commentary and Prayer project.  Contains no references
;; to any specific prayer book edition or ordo.
;;
;; Canticles are indexed by canonical symbol and language.  Stored text
;; is primary — liturgical texts have specific pointing (colons for mediants,
;; asterisks for flexes) that prose Bible fetches cannot reproduce.
;;
;; Pointing conventions (BCP/Sarum):
;;   :   mediant (half-verse division)
;;   *   flex (short verse, additional pause before mediant)
;;
;; User configuration:
;;   `bcp-liturgy-canticle-language'        — default language ('english or 'latin)
;;   `bcp-liturgy-canticle-overrides'       — per-canticle language overrides
;;   `bcp-liturgy-canticle-append-gloria'   — append Gloria Patri after canticles
;;                                    (default nil for private recitation)
;;
;; Latin texts that are nil fall back to English automatically.

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-liturgy-canticles nil
  "Liturgical canticle texts."
  :prefix "bcp-liturgy-canticle-"
  :group 'text)

(defcustom bcp-liturgy-canticle-language 'english
  "Default language for canticles.  `english' or `latin'."
  :type  '(choice (const english) (const latin))
  :group 'bcp-liturgy-canticles)

(defcustom bcp-liturgy-canticle-overrides nil
  "Alist of (CANTICLE-SYMBOL . LANGUAGE) per-canticle language overrides.
Takes precedence over `bcp-liturgy-canticle-language'.

Example: \\='((te-deum . latin) (venite . english))"
  :type  '(alist :key-type symbol :value-type symbol)
  :group 'bcp-liturgy-canticles)

(defcustom bcp-liturgy-canticle-append-gloria nil
  "Whether to append Gloria Patri after each canticle and psalm.
Disabled by default for private recitation.
When enabled the renderer appends Gloria Patri after every canticle
except Te Deum, and after every psalm.
Passiontide suppression is the responsibility of the ordo or renderer."
  :type  'boolean
  :group 'bcp-liturgy-canticles)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Gloria Patri

(defconst bcp-liturgy-canticle-gloria-patri-english
  "Glory be to the Father, and to the Son : and to the Holy Ghost;\n\
   As it was in the beginning, is now, and ever shall be : world without end.  Amen."
  "Gloria Patri in English (BCP pointing).")

(defconst bcp-liturgy-canticle-gloria-patri-latin
  nil
  "Gloria Patri in Latin.  Nil until supplied.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Canticle texts

(defconst bcp-liturgy-canticle-texts
  '(
    ;;──── Venite ─────────────────────────────────────────────────────────────

    (venite
     :title   "Venite, exultemus Domino"
     :source  "Psalm 95"
     :gloria  t
     :english "O COME, let us sing unto the Lord : \
let us heartily rejoice in the strength of our salvation.\n\
   Let us come before his presence with thanksgiving : \
and shew ourselves glad in him with Psalms.\n\
   For the Lord is a great God : \
and a great King above all gods.\n\
   In his hand are all the corners of the earth : \
and the strength of the hills is his also.\n\
   The sea is his, and he made it : \
and his hands prepared the dry land.\n\
   O come, let us worship and fall down : \
and kneel before the Lord our Maker.\n\
   For he is the Lord our God : \
and we are the people of his pasture, and the sheep of his hand.\n\
   To day if ye will hear his voice, harden not your hearts : \
as in the provocation, and as in the day of temptation in the wilderness;\n\
   When your fathers tempted me : proved me, and saw my works.\n\
   Forty years long was I grieved with this generation, and said : \
It is a people that do err in their hearts, for they have not known my ways.\n\
   Unto whom I sware in my wrath : \
that they should not enter into my rest."
     :latin   nil)

    ;;──── Te Deum ────────────────────────────────────────────────────────────

    (te-deum
     :title   "Te Deum Laudamus"
     :source  "Patristic hymn (attr. Niceta of Remesiana, c. 400)"
     :gloria  nil
     :english "WE praise thee, O God : we acknowledge thee to be the Lord.\n\
   All the earth doth worship thee : the Father everlasting.\n\
   To thee all Angels cry aloud : the Heavens, and all the Powers therein.\n\
   To thee Cherubin and Seraphin : continually do cry,\n\
   Holy, Holy, Holy : Lord God of Sabaoth;\n\
   Heaven and earth are full of the Majesty : of thy glory.\n\
   The glorious company of the Apostles : praise thee.\n\
   The goodly fellowship of the Prophets : praise thee.\n\
   The noble army of Martyrs : praise thee.\n\
   The holy Church throughout all the world : doth acknowledge thee;\n\
   The Father : of an infinite Majesty;\n\
   Thine honourable, true : and only Son;\n\
   Also the Holy Ghost : the Comforter.\n\
   Thou art the King of Glory : O Christ.\n\
   Thou art the everlasting Son : of the Father.\n\
   When thou tookest upon thee to deliver man : \
thou didst not abhor the Virgin's womb.\n\
   When thou hadst overcome the sharpness of death : \
thou didst open the Kingdom of Heaven to all believers.\n\
   Thou sittest at the right hand of God : in the glory of the Father.\n\
   We believe that thou shalt come : to be our Judge.\n\
   We therefore pray thee, help thy servants : \
whom thou hast redeemed with thy precious blood.\n\
   Make them to be numbered with thy Saints : in glory everlasting.\n\
   O Lord, save thy people : and bless thine heritage.\n\
   Govern them : and lift them up for ever.\n\
   Day by day : we magnify thee;\n\
   And we worship thy Name : ever world without end.\n\
   Vouchsafe, O Lord : to keep us this day without sin.\n\
   O Lord, have mercy upon us : have mercy upon us.\n\
   O Lord, let thy mercy lighten upon us : as our trust is in thee.\n\
   O Lord, in thee have I trusted : let me never be confounded."
     :latin   nil)

    ;;──── Benedicite ─────────────────────────────────────────────────────────

    (benedicite
     :title   "Benedicite, omnia opera"
     :source  "Song of the Three Young Men (Apocrypha)"
     :gloria  t
     :english "O ALL ye Works of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Angels of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Heavens, bless ye the Lord : praise him, and magnify him for ever.\n\
   O ye Waters that be above the firmament, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O all ye Powers of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Sun and Moon, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Stars of heaven, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Showers and Dew, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Winds of God, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Fire and Heat, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Winter and Summer, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Dews and Frosts, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Frost and Cold, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Ice and Snow, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Nights and Days, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Light and Darkness, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Lightnings and Clouds, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O let the Earth bless the Lord : \
yea, let it praise him, and magnify him for ever.\n\
   O ye Mountains and Hills, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O all ye Green Things upon the earth, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Wells, bless ye the Lord : praise him, and magnify him for ever.\n\
   O ye Seas and Floods, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Whales, and all that move in the waters, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O all ye Fowls of the air, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O all ye Beasts and Cattle, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Children of Men, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O let Israel bless the Lord : praise him, and magnify him for ever.\n\
   O ye Priests of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Servants of the Lord, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye Spirits and Souls of the Righteous, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O ye holy and humble Men of heart, bless ye the Lord : \
praise him, and magnify him for ever.\n\
   O Ananias, Azarias, and Misael, bless ye the Lord : \
praise him, and magnify him for ever."
     :latin   nil)

    ;;──── Benedictus ─────────────────────────────────────────────────────────

    (benedictus
     :title   "Benedictus"
     :source  "Luke 1:68-79"
     :gloria  t
     :english "BLESSED be the Lord God of Israel : \
for he hath visited and redeemed his people;\n\
   And hath raised up a mighty salvation for us : \
in the house of his servant David;\n\
   As he spake by the mouth of his holy Prophets : \
which have been since the world began;\n\
   That we should be saved from our enemies : \
and from the hand of all that hate us.\n\
   To perform the mercy promised to our forefathers : \
and to remember his holy Covenant;\n\
   To perform the oath which he sware to our forefather Abraham : \
that he would give us;\n\
   That we being delivered out of the hand of our enemies : \
might serve him without fear;\n\
   In holiness and righteousness before him : all the days of our life.\n\
   And thou, Child, shalt be called the Prophet of the Highest : \
for thou shalt go before the face of the Lord to prepare his ways;\n\
   To give knowledge of salvation unto his people : \
for the remission of their sins,\n\
   Through the tender mercy of our God : \
whereby the day-spring from on high hath visited us;\n\
   To give light to them that sit in darkness, and in the shadow of death : \
and to guide our feet into the way of peace."
     :latin   nil)

    ;;──── Jubilate Deo ───────────────────────────────────────────────────────

    (jubilate-deo
     :title   "Jubilate Deo"
     :source  "Psalm 100"
     :gloria  t
     :english "O BE joyful in the Lord, all ye lands : \
serve the Lord with gladness, and come before his presence with a song.\n\
   Be ye sure that the Lord he is God; it is he that hath made us, \
and not we ourselves : we are his people, and the sheep of his pasture.\n\
   O go your way into his gates with thanksgiving, and into his courts with praise : \
be thankful unto him, and speak good of his Name.\n\
   For the Lord is gracious, his mercy is everlasting : \
and his truth endureth from generation to generation."
     :latin   nil)

    ;;──── Magnificat ─────────────────────────────────────────────────────────

    (magnificat
     :title   "Magnificat"
     :source  "Luke 1:46-55"
     :gloria  t
     :english "MY soul doth magnify the Lord : \
and my spirit hath rejoiced in God my Saviour.\n\
   For he hath regarded : the lowliness of his handmaiden.\n\
   For behold, from henceforth : all generations shall call me blessed.\n\
   For he that is mighty hath magnified me : and holy is his Name.\n\
   And his mercy is on them that fear him : throughout all generations.\n\
   He hath showed strength with his arm : \
he hath scattered the proud in the imagination of their hearts.\n\
   He hath put down the mighty from their seat : \
and hath exalted the humble and meek.\n\
   He hath filled the hungry with good things : \
and the rich he hath sent empty away.\n\
   He remembering his mercy hath holpen his servant Israel : \
as he promised to our forefathers, Abraham and his seed, for ever."
     :latin   nil)

    ;;──── Cantate Domino ─────────────────────────────────────────────────────

    (cantate-domino
     :title   "Cantate Domino"
     :source  "Psalm 98"
     :gloria  t
     :english "O SING unto the Lord a new song : for he hath done marvellous things.\n\
   With his own right hand, and with his holy arm : \
hath he gotten himself the victory.\n\
   The Lord declared his salvation : \
his righteousness hath he openly showed in the sight of the heathen.\n\
   He hath remembered his mercy and truth toward the house of Israel : \
and all the ends of the world have seen the salvation of our God.\n\
   Show yourselves joyful unto the Lord, all ye lands : \
sing, rejoice, and give thanks.\n\
   Praise the Lord upon the harp : sing to the harp with a psalm of thanksgiving.\n\
   With trumpets also and shawms : \
O shew yourselves joyful before the Lord the King.\n\
   Let the sea make a noise, and all that therein is : \
the round world, and that dwell therein.\n\
   Let the floods clap their hands, and let the hills be joyful together before the Lord : \
for he cometh to judge the earth.\n\
   With righteousness shall he judge the world : and the peoples with equity."
     :latin   nil)

    ;;──── Nunc Dimittis ──────────────────────────────────────────────────────

    (nunc-dimittis
     :title   "Nunc Dimittis"
     :source  "Luke 2:29-32"
     :gloria  t
     :english "LORD, now lettest thou thy servant depart in peace : \
according to thy word.\n\
   For mine eyes have seen : thy salvation,\n\
   Which thou hast prepared : before the face of all people;\n\
   To be a light to lighten the Gentiles : \
and to be the glory of thy people Israel."
     :latin   nil)

    ;;──── Deus Misereatur ────────────────────────────────────────────────────

    (deus-misereatur
     :title   "Deus Misereatur"
     :source  "Psalm 67"
     :gloria  t
     :english "GOD be merciful unto us, and bless us : \
and shew us the light of his countenance, and be merciful unto us;\n\
   That thy way may be known upon earth : \
thy saving health among all nations.\n\
   Let the peoples praise thee, O God : yea, let all the peoples praise thee.\n\
   O let the nations rejoice and be glad : \
for thou shalt judge the folk righteously, and govern the nations upon earth.\n\
   Let the people praise thee, O God : yea, let all the people praise thee.\n\
   Then shall the earth bring forth her increase : \
and God, even our own God, shall give us his blessing.\n\
   God shall bless us : and all the ends of the world shall fear him."
     :latin   nil)

    ;;──── Benedictus es Domine ───────────────────────────────────────────────

    (benedictus-es-domine
     :title   "Benedictus es, Domine"
     :source  "Song of the Three Young Men (Dan 3:52-56 Vulg.)"
     :gloria  t
     :english "BLESSED art thou, O Lord God of our fathers : \
praised and exalted above all for ever.\n\
   Blessed art thou for the Name of thy Majesty : \
praised and exalted above all for ever.\n\
   Blessed art thou in the temple of thy holiness : \
praised and exalted above all for ever.\n\
   Blessed art thou that beholdest the depths, and dwellest between the Cherubim : \
praised and exalted above all for ever.\n\
   Blessed art thou on the glorious throne of thy Kingdom : \
praised and exalted above all for ever.\n\
   Blessed art thou in the firmament of heaven : \
praised and exalted above all for ever."
     :latin   nil)

    ;;──── Gloria Patri ───────────────────────────────────────────────────────

    (gloria-patri
     :title   "Gloria Patri"
     :source  "Doxology"
     :gloria  nil
     :english "Glory be to the Father, and to the Son : and to the Holy Ghost;\n\
   As it was in the beginning, is now, and ever shall be : \
world without end.  Amen."
     :latin   nil))

  "Alist of canticle data keyed by canonical symbol.
Each entry: (SYMBOL :title STRING :source STRING :gloria BOOL
                    :english VALUE :latin VALUE)

:gloria t means Gloria Patri should follow this canticle when
`bcp-liturgy-canticle-append-gloria' is non-nil.

Values are strings (stored pointed text) or nil (not yet supplied).
nil for a language falls back to English automatically.")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Accessors

(defun bcp-liturgy-canticle-data (symbol)
  "Return the data plist for canticle SYMBOL, or nil."
  (cdr (assq symbol bcp-liturgy-canticle-texts)))

(defun bcp-liturgy-canticle-effective-language (symbol)
  "Return the effective language for canticle SYMBOL.
Checks `bcp-liturgy-canticle-overrides' first, then `bcp-liturgy-canticle-language'."
  (or (cdr (assq symbol bcp-liturgy-canticle-overrides))
      bcp-liturgy-canticle-language))

(defun bcp-liturgy-canticle-get (symbol &optional language)
  "Return the text for canticle SYMBOL in LANGUAGE.
LANGUAGE defaults to the effective language for SYMBOL.
Falls back to English if the requested language text is nil.
Returns a string or nil."
  (let* ((data (bcp-liturgy-canticle-data symbol))
         (lang (or language (bcp-liturgy-canticle-effective-language symbol)))
         ;; plist keys are keywords (:english, :latin) — convert symbol
         (key  (intern (format ":%s" lang)))
         (val  (plist-get data key)))
    (if (and (null val) (eq lang 'latin))
        (plist-get data :english)
      val)))

(defun bcp-liturgy-canticle-title (symbol)
  "Return the display title for canticle SYMBOL."
  (plist-get (bcp-liturgy-canticle-data symbol) :title))

(defun bcp-liturgy-canticle-source (symbol)
  "Return the scriptural or patristic source description for canticle SYMBOL."
  (plist-get (bcp-liturgy-canticle-data symbol) :source))

(defun bcp-liturgy-canticle-gloria-p (symbol)
  "Return non-nil if Gloria Patri should follow canticle SYMBOL."
  (plist-get (bcp-liturgy-canticle-data symbol) :gloria))

(defun bcp-liturgy-canticle-gloria-text (&optional language)
  "Return the Gloria Patri text in LANGUAGE (default: effective language)."
  (let ((lang (or language (bcp-liturgy-canticle-effective-language 'gloria-patri))))
    (or (plist-get (bcp-liturgy-canticle-data 'gloria-patri) (intern (format ":%s" lang)))
        (plist-get (bcp-liturgy-canticle-data 'gloria-patri) :english))))


(provide 'bcp-liturgy-canticles)
;;; bcp-liturgy-canticles.el ends here
