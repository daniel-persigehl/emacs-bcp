;;; bcp-shinjitai.el --- Toggleable 旧字体→新字体 display overlay -*- lexical-binding: t -*-

;;; Commentary:

;; The Bungo-yaku Bible (1917) and other pre-war Japanese texts use
;; 旧字体 (kyūjitai) — the pre-1949 character forms.  Many modern
;; CJK fonts either lack glyphs for these forms or render them in a
;; Chinese style that surprises the eye.
;;
;; This module provides a buffer-local overlay that displays each
;; 旧字体 character as its 新字体 (shinjitai) equivalent.  The
;; underlying buffer text is unchanged: search, copy, and the rubi
;; furigana machinery all see the original 旧字体.  Pronunciation is
;; not affected — the 1949 simplification was orthographic, not
;; phonetic.
;;
;; Public API:
;;   `bcp-toggle-shinjitai'   — interactive toggle in current buffer
;;
;; Implementation note: chars that already carry a rubi furigana
;; annotation (`bcp-rubi-reading' or `bcp-furigana') are skipped, since
;; rubi SVG rendering owns their `display' property.

;;; Code:

(require 'cl-lib)

(defgroup bcp-shinjitai nil
  "Display 旧字体 (kyūjitai) characters as 新字体 (shinjitai)."
  :group 'bcp)

(defcustom bcp-shinjitai-allow-lossy-substitutions t
  "When non-nil, also substitute hyogai-ji that have no formal shinjitai.
The replacement is a semantically related Joyo character (e.g. 犢→子,
\"calf\" → \"child\", which yields the modern compound 子牛 from the
Bungo-yaku 犢牛《こうし》).  The rubi reading above the substituted
glyph preserves the original pronunciation, so the loss is purely
graphical.  Set to nil to display only the formal 1949 simplifications."
  :type 'boolean
  :group 'bcp-shinjitai)

(defcustom bcp-shinjitai-auto-enable t
  "When non-nil, automatically enable shinjitai display in buffers with 旧字体.
Triggered at office/scripture finalize time.  The buffer-local
`bcp-shinjitai--active' flag is set the first time a buffer
containing kyūjitai is rendered, so the user does not have to
toggle manually.  Set to nil to require explicit
`bcp-toggle-shinjitai' invocation."
  :type 'boolean
  :group 'bcp-shinjitai)

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Mapping table
;;
;; Curated from the 1949 当用漢字字体表 simplifications.  Each entry
;; maps a 旧字体 codepoint to its standard 新字体 form.  Pronunciation
;; is preserved across the mapping in every case below.
;;
;; A handful of merger cases (e.g. 辨/瓣/辯/辮 → 弁) collapse multiple
;; distinct 旧字体 to a single 新字体.  Display-only substitution makes
;; this lossless from the user's perspective: the buffer text stays as
;; the original 旧字体 and yank/search/rubi all see the original.

(defconst bcp-shinjitai--alist
  '((?學 . ?学) (?國 . ?国) (?體 . ?体) (?實 . ?実) (?寶 . ?宝)
    (?寫 . ?写) (?廣 . ?広) (?應 . ?応) (?樂 . ?楽) (?醫 . ?医)
    (?圖 . ?図) (?圓 . ?円) (?萬 . ?万) (?與 . ?与) (?經 . ?経)
    (?嚴 . ?厳) (?戰 . ?戦) (?將 . ?将) (?廢 . ?廃) (?處 . ?処)
    (?當 . ?当) (?發 . ?発) (?兒 . ?児) (?藏 . ?蔵) (?圍 . ?囲)
    (?縱 . ?縦) (?樣 . ?様) (?醉 . ?酔) (?號 . ?号) (?區 . ?区)
    (?拜 . ?拝) (?對 . ?対) (?隱 . ?隠) (?險 . ?険) (?驅 . ?駆)
    (?雙 . ?双) (?雜 . ?雑) (?靈 . ?霊) (?靜 . ?静) (?顯 . ?顕)
    (?餘 . ?余) (?龍 . ?竜) (?邊 . ?辺) (?鎭 . ?鎮) (?釋 . ?釈)
    (?證 . ?証) (?點 . ?点) (?黨 . ?党) (?麥 . ?麦) (?縣 . ?県)
    (?變 . ?変) (?譽 . ?誉) (?藝 . ?芸) (?戀 . ?恋) (?讀 . ?読)
    (?賣 . ?売) (?觀 . ?観) (?黃 . ?黄) (?來 . ?来) (?兩 . ?両)
    (?參 . ?参) (?收 . ?収) (?攝 . ?摂) (?效 . ?効) (?敍 . ?叙)
    (?數 . ?数) (?斷 . ?断) (?條 . ?条) (?樞 . ?枢) (?棧 . ?桟)
    (?檢 . ?検) (?權 . ?権) (?殘 . ?残) (?歲 . ?歳) (?歷 . ?歴)
    (?氣 . ?気) (?沒 . ?没) (?涉 . ?渉) (?淺 . ?浅) (?渴 . ?渇)
    (?溫 . ?温) (?滯 . ?滞) (?滿 . ?満) (?燒 . ?焼) (?爲 . ?為)
    (?燈 . ?灯) (?爭 . ?争) (?狀 . ?状) (?獨 . ?独) (?獸 . ?獣)
    (?獻 . ?献) (?畫 . ?画) (?疊 . ?畳) (?盡 . ?尽) (?眞 . ?真)
    (?禪 . ?禅) (?稻 . ?稲) (?穗 . ?穂) (?竊 . ?窃) (?粹 . ?粋)
    (?緣 . ?縁) (?繪 . ?絵) (?聲 . ?声) (?聽 . ?聴) (?肅 . ?粛)
    (?舊 . ?旧) (?舉 . ?挙) (?舍 . ?舎) (?藥 . ?薬) (?蟲 . ?虫)
    (?蠶 . ?蚕) (?衞 . ?衛) (?裝 . ?装) (?覺 . ?覚) (?觸 . ?触)
    (?豐 . ?豊) (?豫 . ?予) (?贊 . ?賛) (?轉 . ?転) (?辭 . ?辞)
    (?鐵 . ?鉄) (?顏 . ?顔) (?髮 . ?髪) (?鬪 . ?闘) (?假 . ?仮)
    (?價 . ?価) (?傳 . ?伝) (?僞 . ?偽) (?儉 . ?倹) (?卷 . ?巻)
    (?戶 . ?戸) (?旣 . ?既) (?曉 . ?暁) (?惡 . ?悪) (?亞 . ?亜)
    (?卽 . ?即) (?晝 . ?昼) (?缺 . ?欠) (?艷 . ?艶) (?辨 . ?弁)
    (?瓣 . ?弁) (?辯 . ?弁) (?辮 . ?弁) (?舘 . ?館) (?臺 . ?台)
    (?鹽 . ?塩) (?礦 . ?鉱) (?齒 . ?歯) (?屬 . ?属) (?續 . ?続)
    (?總 . ?総) (?彈 . ?弾) (?徵 . ?徴) (?懷 . ?懐) (?擔 . ?担)
    (?擧 . ?挙) (?擴 . ?拡) (?擇 . ?択) (?據 . ?拠) (?濱 . ?浜)
    (?瀧 . ?滝) (?犧 . ?犠) (?礙 . ?碍) (?祿 . ?禄) (?禰 . ?祢)
    (?稱 . ?称) (?穩 . ?穏) (?籠 . ?篭) (?繼 . ?継) (?纖 . ?繊)
    (?罐 . ?缶) (?膽 . ?胆) (?臟 . ?臓) (?藪 . ?薮) (?蘂 . ?蕊)
    (?譯 . ?訳) (?貳 . ?弐) (?輕 . ?軽) (?遞 . ?逓) (?鄕 . ?郷)
    (?釀 . ?醸) (?銳 . ?鋭) (?錢 . ?銭) (?鎔 . ?溶) (?鑛 . ?鉱)
    (?關 . ?関) (?隨 . ?随) (?靑 . ?青) (?驗 . ?験) (?髓 . ?髄)
    (?鬭 . ?闘) (?寢 . ?寝) (?壓 . ?圧) (?巖 . ?巌) (?歡 . ?歓)
    (?歸 . ?帰) (?勸 . ?勧) (?勞 . ?労) (?擄 . ?虜) (?團 . ?団)
    (?榮 . ?栄) (?佛 . ?仏) (?拂 . ?払) (?從 . ?従) (?廳 . ?庁)
    (?屆 . ?届) (?卻 . ?却) (?嶽 . ?岳) (?拔 . ?抜) (?攜 . ?携)
    (?鄰 . ?隣) (?誡 . ?戒))
  "Alist of 旧字体 character → 新字体 character.")

(defconst bcp-shinjitai--table
  (let ((tbl (make-hash-table :test 'eql :size (* 2 (length bcp-shinjitai--alist)))))
    (dolist (cell bcp-shinjitai--alist tbl)
      (puthash (car cell) (cdr cell) tbl)))
  "Hashtable form of `bcp-shinjitai--alist' for O(1) lookup.
Defconst so `bcp-reload' rebuilds it after alist changes; `defvar'
would skip re-initialization on already-bound symbols.")

;; Hyogai-ji (表外字) — characters outside the Joyo list that have no
;; formal shinjitai.  The Bungo-yaku uses several that lack glyph
;; coverage in common Japanese fonts.  The substitutions below pick a
;; semantically adjacent Joyo character; the rubi reading carries the
;; original pronunciation, so meaning is recoverable.

(defconst bcp-shinjitai--lossy-alist
  '((?犢 . ?子)   ; calf → child; in 犢牛《こうし》 yields 子牛, the modern form
    (?阱 . ?穴)   ; pit → hole; same reading あな
    (?儆 . ?戒)   ; warn → admonish; same reading いましめ
    (?縲 . ?縄)   ; black-silk-rope → rope
    (?絏 . ?縛)   ; bind → bind
    (?腭 . ?顎))  ; jaw/palate (hyogai) → modern jaw, reading あぎ
  "Alist of hyogai-ji → semantically adjacent Joyo character.
Used only when `bcp-shinjitai-allow-lossy-substitutions' is non-nil.")

(defconst bcp-shinjitai--lossy-table
  (let ((tbl (make-hash-table :test 'eql
                              :size (* 2 (length bcp-shinjitai--lossy-alist)))))
    (dolist (cell bcp-shinjitai--lossy-alist tbl)
      (puthash (car cell) (cdr cell) tbl)))
  "Hashtable form of `bcp-shinjitai--lossy-alist' for O(1) lookup.
Defconst so `bcp-reload' rebuilds it after alist changes.")

(defun bcp-shinjitai-lookup (char)
  "Return the 新字体 equivalent of CHAR, or nil if not in either table.
If `bcp-shinjitai-allow-lossy-substitutions' is non-nil, also
consults `bcp-shinjitai--lossy-table' for hyogai-ji."
  (or (gethash char bcp-shinjitai--table)
      (and bcp-shinjitai-allow-lossy-substitutions
           (gethash char bcp-shinjitai--lossy-table))))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Buffer-local apply / remove

(defvar-local bcp-shinjitai--active nil
  "Non-nil when the shinjitai display overlay is active in this buffer.")

(defun bcp-shinjitai--apply ()
  "Add `display' substitutions for every 旧字体 character in the buffer.
Skips characters covered by a rubi annotation, since rubi rendering
owns their `display' property."
  (save-excursion
    (let ((inhibit-read-only t)
          (count 0))
      (goto-char (point-min))
      (while (not (eobp))
        (let* ((ch (char-after))
               (replacement (bcp-shinjitai-lookup ch))
               (covered (or (get-text-property (point) 'bcp-rubi-reading)
                            (get-text-property (point) 'bcp-furigana)
                            (get-text-property (point) 'bcp-rubi-svg))))
          (when (and replacement (not covered))
            (put-text-property (point) (1+ (point))
                               'display (string replacement))
            (put-text-property (point) (1+ (point))
                               'bcp-shinjitai-overlay t)
            (cl-incf count)))
        (forward-char 1))
      (setq bcp-shinjitai--active t)
      count)))

(defun bcp-shinjitai--remove ()
  "Strip every shinjitai `display' substitution from the buffer."
  (save-excursion
    (let ((inhibit-read-only t)
          (pos (point-min)))
      (while (setq pos (text-property-any pos (point-max)
                                          'bcp-shinjitai-overlay t))
        (let ((end (or (next-single-property-change
                        pos 'bcp-shinjitai-overlay nil (point-max))
                       (point-max))))
          (remove-text-properties pos end
                                  '(display nil bcp-shinjitai-overlay nil))
          (setq pos end))))
    (setq bcp-shinjitai--active nil)))

;;;; ──────────────────────────────────────────────────────────────────────────
;;;; Buffer detection and toggle command

(defun bcp-shinjitai--buffer-has-kyujitai-p (buf)
  "Non-nil if BUF contains any character in `bcp-shinjitai--table'."
  (and (buffer-live-p buf)
       (with-current-buffer buf
         (save-excursion
           (goto-char (point-min))
           (let (found)
             (while (and (not found) (not (eobp)))
               (when (bcp-shinjitai-lookup (char-after))
                 (setq found t))
               (forward-char 1))
             found)))))

(defun bcp-shinjitai--target-buffer ()
  "Return a buffer with 旧字体 content.
Prefers the current buffer; otherwise returns the first live buffer
that has 旧字体 characters, or nil."
  (if (bcp-shinjitai--buffer-has-kyujitai-p (current-buffer))
      (current-buffer)
    (seq-find #'bcp-shinjitai--buffer-has-kyujitai-p (buffer-list))))

(declare-function bcp-fetcher--rubi-remove-svg "bcp-fetcher")
(declare-function bcp-fetcher--rubi-apply-svg  "bcp-fetcher")

(defun bcp-shinjitai--regenerate-rubi-svgs ()
  "Re-render any rubi SVGs so the new shinjitai state takes effect.
The SVG builder substitutes per `bcp-shinjitai--active' at build
time; stripping and re-applying forces a refresh."
  (when (and (fboundp 'bcp-fetcher--rubi-apply-svg)
             (text-property-any (point-min) (point-max) 'bcp-rubi-svg t))
    (bcp-fetcher--rubi-remove-svg)
    (bcp-fetcher--rubi-apply-svg)))

;;;###autoload
(defun bcp-shinjitai-maybe-enable ()
  "Enable shinjitai display in the current buffer if conditions are met.
A no-op unless `bcp-shinjitai-auto-enable' is non-nil, the buffer
contains kyūjitai, and the overlay is not already active.  Intended
to be called from buffer-finalize hooks before rubi SVG rendering."
  (when (and bcp-shinjitai-auto-enable
             (not bcp-shinjitai--active)
             (save-excursion
               (goto-char (point-min))
               (let (found)
                 (while (and (not found) (not (eobp)))
                   (when (bcp-shinjitai-lookup (char-after))
                     (setq found t))
                   (forward-char 1))
                 found)))
    (bcp-shinjitai--apply)))

;;;###autoload
(defun bcp-shinjitai-refresh ()
  "Re-render shinjitai overlay and rubi SVGs in the active buffer.
Use after `bcp-reload' to force already-rendered SVGs to pick up
table changes (e.g. newly added entries in
`bcp-shinjitai--lossy-alist').  The toggle state is preserved.
Also clears any stale entries in `bcp-fetcher--rubi-svg-cache' so
SVGs built under earlier substitution logic are dropped."
  (interactive)
  (let ((buf (bcp-shinjitai--target-buffer)))
    (unless buf
      (user-error "No buffer with 旧字体 content is open"))
    (with-current-buffer buf
      (when (boundp 'bcp-fetcher--rubi-svg-cache)
        (clrhash bcp-fetcher--rubi-svg-cache))
      (cond
       (bcp-shinjitai--active
        (bcp-shinjitai--remove)
        (bcp-shinjitai--apply))
       (t
        (bcp-shinjitai-maybe-enable)))
      (bcp-shinjitai--regenerate-rubi-svgs)
      (message "Refreshed shinjitai display in %s." (buffer-name)))))

;;;###autoload
(defun bcp-shinjitai-scan-rubi-spans ()
  "List every kanji+rubi span in the active buffer and its substitution.
For each span, shows the raw kanji, the substituted display form,
and a per-char breakdown.  Use this to diagnose remaining tofu in
rubi'd text — if `display-kanji' still contains the original
kyūjitai, the substitution did not fire and the lookup table needs
an entry; if it shows a Joyo character that still tofus, the SVG
font lacks the glyph, not a kyūjitai problem."
  (interactive)
  (let ((buf (or (bcp-shinjitai--target-buffer) (current-buffer))))
    (with-current-buffer buf
      (let ((spans nil)
            (uncovered (make-hash-table :test 'eql)))
        (save-excursion
          (goto-char (point-min))
          (while (not (eobp))
            (let ((reading (get-text-property (point) 'bcp-rubi-reading))
                  (width   (get-text-property (point) 'bcp-rubi-base-width)))
              (cond
               ((and reading width)
                (let* ((end   (+ (point) (/ width 2)))
                       (kanji (buffer-substring-no-properties (point) end))
                       (display-kanji
                        (and (fboundp 'bcp-fetcher--rubi-display-kanji)
                             (bcp-fetcher--rubi-display-kanji kanji))))
                  (push (list kanji reading display-kanji) spans)
                  (dolist (c (string-to-list kanji))
                    (unless (or (gethash c bcp-shinjitai--table)
                                (gethash c bcp-shinjitai--lossy-table))
                      (puthash c (1+ (gethash c uncovered 0)) uncovered)))
                  (goto-char end)))
               (t
                (goto-char (or (next-single-property-change
                                (point) 'bcp-rubi-reading nil (point-max))
                               (point-max))))))))
        (with-current-buffer (get-buffer-create "*bcp-shinjitai-spans*")
          (let ((inhibit-read-only t))
            (erase-buffer)
            (insert (format "Buffer: %s   bcp-shinjitai--active = %s\n"
                            (buffer-name buf)
                            (buffer-local-value 'bcp-shinjitai--active buf)))
            (insert (format "Total rubi spans: %d   Uncovered chars: %d\n\n"
                            (length spans) (hash-table-count uncovered)))
            (insert "── Rubi spans ──────────────────────────────────────\n")
            (insert "kanji   →  display    《reading》\n")
            (dolist (s (nreverse spans))
              (insert (format " %s    →  %s    《%s》\n"
                              (nth 0 s) (or (nth 2 s) "(no fn)") (nth 1 s))))
            (insert "\n── Uncovered kanji (no formal or lossy entry) ──\n")
            (let (rows)
              (maphash (lambda (c n) (push (cons c n) rows)) uncovered)
              (dolist (r (sort rows (lambda (a b) (> (cdr a) (cdr b)))))
                (insert (format " %c  U+%04X  ×%d\n"
                                (car r) (car r) (cdr r)))))
            (goto-char (point-min)))
          (display-buffer (current-buffer)))
        (message "Scanned %s: %d rubi spans, %d uncovered chars."
                 (buffer-name buf) (length spans)
                 (hash-table-count uncovered))))))

;;;###autoload
(defun bcp-toggle-shinjitai ()
  "Toggle 旧字体→新字体 display in a buffer with 旧字体 content.
Operates on the current buffer if it contains 旧字体, otherwise on
the first buffer that does.  The underlying buffer text is never
modified — only the display.  Rubi SVGs, if present, are
regenerated so kanji-with-furigana spans also pick up the new
display form."
  (interactive)
  (let ((buf (bcp-shinjitai--target-buffer)))
    (unless buf
      (user-error "No buffer with 旧字体 content is open"))
    (with-current-buffer buf
      (if bcp-shinjitai--active
          (progn (bcp-shinjitai--remove)
                 (bcp-shinjitai--regenerate-rubi-svgs)
                 (message "旧字体 displayed (overlay off) in %s." (buffer-name)))
        (let ((n (bcp-shinjitai--apply)))
          (bcp-shinjitai--regenerate-rubi-svgs)
          (message "新字体 displayed (%d substitution%s) in %s."
                   n (if (= n 1) "" "s") (buffer-name)))))))

(provide 'bcp-shinjitai)
;;; bcp-shinjitai.el ends here
