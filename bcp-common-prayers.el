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

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; User configuration

(defgroup bcp-common-prayers nil
  "Shared liturgical prayer texts."
  :prefix "bcp-common-prayers-"
  :group 'bcp-liturgy)

(defcustom bcp-common-prayers-language 'english
  "Active language for common prayer texts.
Language symbols correspond to keyword keys in each text entry plist,
e.g. \\='english → :english, \\='latin → :latin."
  :type  '(choice (const english) (const latin))
  :group 'bcp-common-prayers)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Lookup

(defun bcp-common-prayers-text (entry)
  "Return the text string from ENTRY for the current prayer language.
ENTRY is a plist whose language keys are keywords (:english, :latin, …).
Falls back to :english when the current language has no text.
Falls back to :text for backward compatibility with tradition-specific
prayer plists that have not yet adopted the language-keyed format."
  (let* ((key (intern (format ":%s" bcp-common-prayers-language)))
         (val (plist-get entry key)))
    (if (and (null val) (not (eq bcp-common-prayers-language 'english)))
        (or (plist-get entry :english)
            (plist-get entry :text))
      (or val (plist-get entry :text)))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Fixed texts

(defconst bcp-common-prayers-lords-prayer
  '(:english
    "Our Father, which art in heaven, Hallowed be thy Name. Thy kingdom come. \
Thy will be done in earth, As it is in heaven. Give us this day our daily bread. \
And forgive us our trespasses, As we forgive them that trespass against us. \
And lead us not into temptation, But deliver us from evil."
    :latin nil)
  "The Lord's Prayer body without doxology (1662 form: \"which\"/\"them that\").
Use with `bcp-common-prayers-lords-prayer-doxology' when the doxology is required.")

(defconst bcp-common-prayers-lords-prayer-doxology
  '(:english
    "For thine is the kingdom, The power, and the glory, For ever and ever. Amen."
    :latin nil)
  "Doxology appended to the Lord's Prayer (1662 form).
Append to `bcp-common-prayers-lords-prayer' via the ordo step's :doxology key.")

(defconst bcp-common-prayers-lords-prayer-1928
  '(:english
    "Our Father, who art in heaven, Hallowed be thy Name. Thy kingdom come. \
Thy will be done on earth, As it is in heaven. Give us this day our daily bread. \
And forgive us our trespasses, As we forgive those who trespass against us. \
And lead us not into temptation, But deliver us from evil."
    :latin nil)
  "The Lord's Prayer body without doxology (1928 American form: \"who\"/\"those who\").
Use with `bcp-common-prayers-lords-prayer-doxology-1928' when the doxology is required.")

(defconst bcp-common-prayers-lords-prayer-doxology-1928
  '(:english
    "For thine is the kingdom, and the power, and the glory, for ever and ever. Amen."
    :latin nil)
  "Doxology appended to the Lord's Prayer (1928 American form).
Append to `bcp-common-prayers-lords-prayer-1928' via the ordo step's :doxology key.")

(defconst bcp-common-prayers-gloria-patri
  '(:english
    "Glory be to the Father, and to the Son, and to the Holy Ghost; \
As it was in the beginning, is now, and ever shall be, world without end. Amen."
    :latin nil)
  "The Gloria Patri (Lesser Doxology).")

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
    :latin nil)
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
    :latin nil)
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
    :latin nil)
  "The Prayer of St. Chrysostom.")

(defconst bcp-common-prayers-grace-2cor
  '(:name  grace-2cor
    :ref   ("2 Cor" 13 14)
    :title "The Grace."
    :english
    "The grace of our Lord Jesus Christ, and the love of God, and the fellowship \
of the Holy Ghost, be with us all evermore. Amen."
    :latin nil)
  "The Grace (2 Corinthians 13:14).")

(provide 'bcp-common-prayers)
;;; bcp-common-prayers.el ends here
