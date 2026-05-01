;;; bcp-common-prayers.el --- Shared liturgical prayer texts -*- lexical-binding: t -*-

;;; Commentary:

;; Texts shared across multiple prayer book traditions: the Lord's Prayer,
;; Apostles' Creed, Gloria Patri, Prayer of St. Chrysostom, and the Grace.
;;
;; TODO: add the Athanasian Creed (Quicumque vult) — predates the East-West
;; schism; used in Roman, Anglican (Sunday Prime/1662 rubric), and Lutheran
;; traditions.  Both Latin and English texts needed.
;;
;; Each entry is a plist with keyword language keys (:english, :latin, …).
;; This matches the convention used in `bcp-liturgy-canticles'.
;;
;; User configuration:
;;   `bcp-common-prayers-language'  — active language (default \\='english)
;;
;; Primary public function:
;;   `bcp-common-prayers-text'  — resolve text from an entry for the
;;                                 current language, with English fallback

;;; Code:

(require 'cl-lib)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-common-prayers nil
  "Shared liturgical prayer texts."
  :prefix "bcp-common-prayers-"
  :group 'bcp-liturgy)

(defcustom bcp-common-prayers-language 'english
  "Active language for common prayer texts.
Language symbols correspond to keyword keys in each text entry plist,
e.g. \\='english → :english, \\='latin → :latin, \\='bungo → :bungo,
\\='nskk-1959 → :nskk-1959 (Nippon Sei Ko Kai 1959 BCP)."
  :type  '(choice (const english) (const latin) (const bungo) (const nskk-1959))
  :group 'bcp-common-prayers)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lookup

(defconst bcp-common-prayers-language-fallback
  '((nskk-1959 . (bungo))
    (bungo     . (nskk-1959)))
  "Per-language fallback chain consulted before defaulting to English.
When a text plist has no key for the requested language, each fallback
language is tried in order; the first non-nil hit wins.  English is
always the final fallback.

This is consulted by `bcp-common-prayers-text' and
`bcp-liturgy-canticle-get'.  Japanese editions chain to each other in
both directions: a JAP-59 user gets bungo (1895-style) where 1959 is
unencoded, and a JAP user gets 1959 where bungo is unencoded — better
to mix Japanese registers than fall straight to English.")

(defun bcp-common-prayers--language-chain (language)
  "Return the lookup chain (LANGUAGE then any fallbacks) for LANGUAGE.
Does not include English; callers append :english as the final fallback."
  (cons language
        (cdr (assq language bcp-common-prayers-language-fallback))))

(defun bcp-common-prayers-text (entry)
  "Return the text string from ENTRY for the current prayer language.
ENTRY is a plist whose language keys are keywords (:english, :latin, …).
Walks `bcp-common-prayers-language-fallback' before defaulting to English.
Falls back to :text for backward compatibility with tradition-specific
prayer plists that have not yet adopted the language-keyed format."
  (let* ((lang  bcp-common-prayers-language)
         (chain (bcp-common-prayers--language-chain lang))
         (val   (cl-some (lambda (l) (plist-get entry (intern (format ":%s" l))))
                         chain)))
    (cond
     (val val)
     ((eq lang 'english) (or (plist-get entry :english)
                             (plist-get entry :text)))
     (t (or (plist-get entry :english)
            (plist-get entry :text))))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Fixed texts

(defconst bcp-common-prayers-lords-prayer
  '(:english
    "Our Father, which art in heaven, Hallowed be thy Name. Thy kingdom come. \
Thy will be done in earth, As it is in heaven. Give us this day our daily bread. \
And forgive us our trespasses, As we forgive them that trespass against us. \
And lead us not into temptation, But deliver us from evil."
    :latin
    "Pater noster, qui es in cælis, sanctificétur nomen tuum: advéniat regnum tuum: \
fiat volúntas tua, sicut in cælo et in terra. Panem nostrum cotidiánum da nobis hódie: \
et dimítte nobis débita nostra, sicut et nos dimíttimus debitóribus nostris: \
et ne nos indúcas in tentatiónem: sed líbera nos a malo. Amen."
    :nskk-1959
    "天にします我らの父よ、願わくは御名を聖となさしめたまえ。御国をきたらしめたまえ。\
御心を天におけるごとく、地にも行わしめたまえ。我らの日用の糧を今日も与えたまえ。\
我らに罪を犯すものを我ら赦すごとく、我らの罪をも赦したまえ。\
我らを試みにあわせず、悪より救いいだしたまえ。アーメン")
  "The Lord's Prayer body without doxology (1662 form: \"which\"/\"them that\").
Use with `bcp-common-prayers-lords-prayer-doxology' when the doxology is required.")

(defconst bcp-common-prayers-lords-prayer-doxology
  '(:english
    "For thine is the kingdom, The power, and the glory, For ever and ever. Amen."
    :latin
    "Quia tuum est regnum, et potéstas, et glória, in sǽcula sæculórum. Amen.")
  "Doxology appended to the Lord's Prayer (1662 form).
Append to `bcp-common-prayers-lords-prayer' via the ordo step's :doxology key.")

(defconst bcp-common-prayers-lords-prayer-1928
  '(:english
    "Our Father, who art in heaven, Hallowed be thy Name. Thy kingdom come. \
Thy will be done on earth, As it is in heaven. Give us this day our daily bread. \
And forgive us our trespasses, As we forgive those who trespass against us. \
And lead us not into temptation, But deliver us from evil."
    :latin
    "Pater noster, qui es in cælis, sanctificétur nomen tuum: advéniat regnum tuum: \
fiat volúntas tua, sicut in cælo et in terra. Panem nostrum cotidiánum da nobis hódie: \
et dimítte nobis débita nostra, sicut et nos dimíttimus debitóribus nostris: \
et ne nos indúcas in tentatiónem: sed líbera nos a malo. Amen.")
  "The Lord's Prayer body without doxology (1928 American form: \"who\"/\"those who\").
Use with `bcp-common-prayers-lords-prayer-doxology-1928' when the doxology is required.")

(defconst bcp-common-prayers-lords-prayer-doxology-1928
  '(:english
    "For thine is the kingdom, and the power, and the glory, for ever and ever. Amen."
    :latin
    "Quia tuum est regnum, et potéstas, et glória, in sǽcula sæculórum. Amen.")
  "Doxology appended to the Lord's Prayer (1928 American form).
Append to `bcp-common-prayers-lords-prayer-1928' via the ordo step's :doxology key.")

(defconst bcp-common-prayers-oremus
  '(:english   "Let us pray."
    :latin     "Orémus."
    :bungo     "我《われ》ら祈《いの》るべし。"
    :nskk-1959 "我ら祈るべし")
  "The bidding before a collect.")

(defconst bcp-common-prayers-gloria-patri
  '(:english
    "Glory be to the Father, and to the Son, * and to the Holy Ghost;\n\
As it was in the beginning, is now, and ever shall be, * world without end. Amen."
    :latin
    "Glória Patri, et Fílio, * et Spirítui Sancto.\n\
Sicut erat in princípio, et nunc, et semper, * et in sǽcula sæculórum. Amen."
    :nskk-1959
    "父と子と聖霊に栄光あれ\n\
始めにあり、今あり、世々限りなくあるなり アーメン")
  "The Gloria Patri (Lesser Doxology).
Pointed with * mediants for psalmody and responsories.
For BCP canticle contexts (colon mediants), rendering functions
use `bcp-liturgy-canticle-gloria-text' instead.")

(defconst bcp-common-prayers-apostles-creed
  '(:english
    "I believe in God the Father Almighty, Maker of heaven and earth: \
And in Jesus Christ his only Son our Lord: Who was conceived by the Holy Ghost, \
Born of the Virgin Mary: Suffered under Pontius Pilate, Was crucified, dead, and buried: \
He descended into hell; The third day he rose again from the dead: \
He ascended into heaven, And sitteth on the right hand of God the Father Almighty: \
From thence he shall come to judge the quick and the dead. \
I believe in the Holy Ghost: The holy Catholick Church; The Communion of Saints: \
The Forgiveness of sins: The Resurrection of the body, And the Life everlasting. Amen."
    :latin
    "Credo in Deum, Patrem omnipoténtem, Creatórem cæli et terræ. \
Et in Jesum Christum, Fílium ejus únicum, Dóminum nostrum: \
qui concéptus est de Spíritu Sancto, natus ex María Vírgine, \
passus sub Póntio Piláto, crucifíxus, mórtuus, et sepúltus: \
descéndit ad ínferos; tértia die resurréxit a mórtuis; \
ascéndit ad cælos; sedet ad déxteram Dei Patris omnipoténtis: \
inde ventúrus est judicáre vivos et mórtuos. \
Credo in Spíritum Sanctum, sanctam Ecclésiam cathólicam, \
Sanctórum communiónem, remissiónem peccatórum, \
carnis resurrectiónem, vitam ætérnam. Amen."
    :nskk-1959
    "我は天地の造り主・全能の父なる神を信ず\n\
我はそのひとり子、我らの主イエス＝キリストを信ず。\
主は聖霊によりてやどり、おとめマリヤより生まれ、\
ポンテオ＝ピラトのとき苦しみを受け、十字架につけられ、死にて葬られ、\
よみにくだり、三日目に死にし者のうちよりよみがえり、天に昇り、\
全能の父なる神の右に座したまえり。\
かしこよりきたりて生ける人と死ねる人をさばきたまわん\n\
我らは聖霊を信ず。\
また聖公会、聖徒の交わり、罪の赦し、からだのよみがえり、\
限りなきいのちを信ず アーメン")
  "The Apostles' Creed.")

(defconst bcp-common-prayers-nicene-creed
  '(:english
    "I believe in one God the Father Almighty, Maker of heaven and earth, \
And of all things visible and invisible: \
And in one Lord Jesus Christ, the only-begotten Son of God; \
Begotten of his Father before all worlds, God of God, Light of Light, \
Very God of very God; Begotten, not made; Being of one substance with the Father; \
By whom all things were made: \
Who for us men and for our salvation came down from heaven, \
And was incarnate by the Holy Ghost of the Virgin Mary, And was made man: \
And was crucified also for us under Pontius Pilate; He suffered and was buried: \
And the third day he rose again according to the Scriptures: \
And ascended into heaven, And sitteth on the right hand of the Father: \
And he shall come again, with glory, to judge both the quick and the dead; \
Whose kingdom shall have no end. \
And I believe in the Holy Ghost, The Lord, and Giver of Life, \
Who proceedeth from the Father and the Son; \
Who with the Father and the Son together is worshipped and glorified; \
Who spake by the Prophets: \
And I believe one Catholick and Apostolick Church: \
I acknowledge one Baptism for the remission of sins: \
And I look for the Resurrection of the dead: \
And the Life of the world to come. Amen."
    :latin
    "Credo in unum Deum, Patrem omnipoténtem, factórem cæli et terræ, \
visibílium ómnium et invisibílium. \
Et in unum Dóminum Jesum Christum, Fílium Dei unigénitum, \
et ex Patre natum ante ómnia sǽcula. \
Deum de Deo, lumen de lúmine, Deum verum de Deo vero, \
génitum, non factum, consubstantiálem Patri: per quem ómnia facta sunt. \
Qui propter nos hómines et propter nostram salútem descéndit de cælis. \
Et incarnátus est de Spíritu Sancto ex María Vírgine, et homo factus est. \
Crucifíxus étiam pro nobis sub Póntio Piláto; passus et sepúltus est, \
et resurréxit tértia die, secúndum Scriptúras, \
et ascéndit in cælum, sedet ad déxteram Patris. \
Et íterum ventúrus est cum glória, judicáre vivos et mórtuos: \
cujus regni non erit finis. \
Et in Spíritum Sanctum, Dóminum et vivificántem: \
qui ex Patre Filióque procédit. \
Qui cum Patre et Fílio simul adorátur et conglorificátur: \
qui locútus est per prophétas. \
Et unam, sanctam, cathólicam et apostólicam Ecclésiam. \
Confíteor unum baptísma in remissiónem peccatórum. \
Et exspécto resurrectiónem mortuórum, et vitam ventúri sǽculi. Amen.")
  "The Nicene Creed (Niceno-Constantinopolitan form with Filioque).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Shared prayers

(defconst bcp-common-prayers-chrysostom
  '(:name  prayer-chrysostom
    :title "A Prayer of St. Chrysostom."
    :english
    "Almighty God, who hast given us grace at this time with one accord to make \
our common supplications unto thee; and dost promise, that when two or three are \
gathered together in thy Name thou wilt grant their requests; Fulfil now, O Lord, \
the desires and petitions of thy servants, as may be most expedient for them; \
granting us in this world knowledge of thy truth, and in the world to come life \
everlasting. Amen."
    :latin nil
    ;; 1895 NSKK 聖キリソストムの祈り (旧仮名遣).  The 1959 NSKK does not
    ;; carry this collect; under a JAP-1959 profile it resolves here via
    ;; the language fallback chain (nskk-1959 → bungo → english).
    :bungo
    "今《いま》、心《こころ》を合《あ》はせて主《しゆ》に祈《いの》る恵《めぐ》みを\
与《あた》へたまへる全能《ぜんのう》の神《かみ》よ、\
御名《みな》によりて両三人《りやうさんにん》集《あつ》まる時《とき》は、\
その願《ねが》ひを許《ゆる》さんと約《やく》したまへり。\
願《ねが》はくは我《われ》らの益《えき》を図《はか》りて、\
望《のぞ》みと願《ねが》ひを遂《と》げしめ、\
この世《よ》においては主《しゆ》の道《みち》を悟《さと》り、\
後《のち》の世《よ》においては限《かぎ》りなき命《いのち》に至《いた》るとを得《え》させたまへ。アーメン")
  "The Prayer of St. Chrysostom.")

(defconst bcp-common-prayers-grace-2cor
  '(:name  grace-2cor
    :ref   ("2 Cor" 13 14)
    :title "The Grace."
    :english
    "The grace of our Lord Jesus Christ, and the love of God, and the fellowship \
of the Holy Ghost, be with us all evermore. Amen."
    :latin
    "Grátia Dómini nostri Jesu Christi, et cáritas Dei, et communicátio \
Sancti Spíritus sit cum ómnibus nobis. Amen."
    :bungo
    "願くは主イエス・キリストの恩惠、神の愛、聖霊の交感、われら凡ての者と偕に永遠にあらんことを。アァメン。"
    :nskk-1959
    "願わくは主イエス＝キリストの恵み、神のいつくしみ、聖霊のまじわり、\
我らとともに限りなくあらんことを。アーメン")
  "The Grace (2 Corinthians 13:14).")

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Penitential forms registry
;;
;; Cross-tradition registry for confession and absolution texts.
;; Each tradition registers its forms at load time; the ordo step
;; `:confession' / `:absolution' resolves via a defcustom key.

(defvar bcp-penitential-forms nil
  "Alist of (KEY . PLIST) for cross-tradition penitential rites.
Each PLIST has:
  :confession  STRING — the confession text
  :absolution  STRING — the absolution/pardon text
  :rubric      STRING — optional rubric for the confession
Traditions register their forms via `bcp-penitential-register'.")

(defun bcp-penitential-register (key plist)
  "Register PLIST as penitential form KEY.
KEY is a symbol (e.g. \\='roman, \\='anglican-1662).
PLIST has :confession, :absolution, and optionally :rubric."
  (setf (alist-get key bcp-penitential-forms) plist))

(defun bcp-penitential-form (key)
  "Return the penitential form plist for KEY, or nil."
  (alist-get key bcp-penitential-forms))

(provide 'bcp-common-prayers)
;;; bcp-common-prayers.el ends here
