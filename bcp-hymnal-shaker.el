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
        :author nil
        :copyright :public-domain
        :notes "Communal affection; tune unknown pending Patterson.")
   ))

(provide 'bcp-hymnal-shaker)
;;; bcp-hymnal-shaker.el ends here
