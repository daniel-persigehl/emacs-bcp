;;; bcp-hymnal-shaker.el --- Shaker hymnal manifest -*- lexical-binding: t -*-

;;; Commentary:

;; Manifest for Shaker hymns.  Numbering is provisional pending Daniel W.
;; Patterson's _The Shaker Spiritual_ (1979) as the primary source; the
;; texts and underlying melodies are 19th-century and firmly in the public
;; domain, while Patterson's editorial apparatus is not — so if we adopt
;; his numbering, we treat it as attribution, not licensed content.
;;
;; For now, entries use ad-hoc numeric keys.  When Patterson arrives the
;; keys should be renumbered to match the book's enumeration.

;;; Code:

(require 'bcp-hymnal)

;; Provisional tune-ids: Shaker melodies are usually anonymous and
;; folk-transmitted, so we mint a tune symbol per text until Patterson
;; supplies an authoritative name.

(bcp-hymnal-register-tune 'GOOD-ELDER
  :name "GOOD ELDER"
  :source "Shaker tradition (anonymous)"
  :copyright :public-domain
  :recording-url "https://www.youtube.com/watch?v=m-0H8b3t3JE")

(bcp-hymnal-register-hymnal
 'hymnal-shaker
 '(:name "Shaker Hymns"
   :year nil
   :editor nil
   :publisher nil
   :kind :hymnal
   :tradition shaker)
 '(
   ("1" :text shaker-good-elder
        :first-line "Good Elder, dear Brethren and Sisters, I love you"
        :tune GOOD-ELDER
        :author nil
        :copyright :public-domain
        :notes "Communal affection; tune symbol provisional pending Patterson.")
   ))

(provide 'bcp-hymnal-shaker)
;;; bcp-hymnal-shaker.el ends here
