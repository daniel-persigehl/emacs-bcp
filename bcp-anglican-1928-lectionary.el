;;; bcp-anglican-1928-lectionary.el --- 1928 BCP lesson tables -*- lexical-binding: t -*-

;;; Commentary:

;; Lesson tables for the 1928 American Book of Common Prayer.
;;
;; IMPORTANT: This file was transcribed from a PDF scan.  Individual lesson
;; references should be verified against the printed BCP before liturgical use.
;; Entries marked ; VERIFY are particularly uncertain.
;;
;; Structure of bcp-1928-lesson-table:
;;
;;   Each entry: (WEEK-KEY DAY-ENTRY …)
;;   where WEEK-KEY is a symbol (e.g. `advent-1', `lent-3', `after-trinity-7')
;;   and each DAY-ENTRY is: (DOW-SYMBOL :mattins  (:lesson1 REF :lesson2 REF)
;;                                       :evensong (:lesson1 REF :lesson2 REF))
;;
;; Reference format (identical to bcp-1662-data.el):
;;   ("Book" CH)                  — whole chapter
;;   ("Book" CH V1)               — from V1 to end of chapter
;;   ("Book" CH V1 V2)            — V1 through V2
;;   (REF1 REF2)                  — cross-chapter continuous range
;;   (:multiple REF1 REF2 ...)    — non-contiguous segments, fetched and concatenated
;;
;; Fixed holy day lessons (with :vespers-i) are in bcp-1928-holy-day-lessons.
;; Special occasion lessons are in bcp-1928-special-lessons.
;;
;; Lookup: bcp-1928-office-lessons (month day year office)

;;; Code:

(require 'cl-lib)
(require 'bcp-anglican-1928-calendar)

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Main lesson table
;;;; ══════════════════════════════════════════════════════════════════════════

(defconst bcp-1928-lesson-table
  '(

    ;;;; ── ADVENT ────────────────────────────────────────────────────────────

    (advent-1
     (sunday
      :mattins  (:lesson1 ("Isa" 55)
                 :lesson2 ("Luke" 1 57))
      :evensong (:lesson1 (:multiple ("Isa" 60 1 11) ("Isa" 60 18))
                 :lesson2 ("John" 1 15 28)))
     (monday
      :mattins  (:lesson1 (("Gen" 1 1) ("Gen" 2 1 3))
                 :lesson2 ("Mark" 1 1 21))
      :evensong (:lesson1 ("I Kgs" 11 1 13)
                 :lesson2 ("Rev" 4)))
     (tuesday
      :mattins  (:lesson1 ("Gen" 2 4 14)
                 :lesson2 ("Mark" 1 21))
      :evensong (:lesson1 ("I Kgs" 11 14 25)
                 :lesson2 ("Rev" 5)))
     (wednesday
      :mattins  (:lesson1 ("Gen" 2 15 24)
                 :lesson2 ("Mark" 2 1 22))
      :evensong (:lesson1 ("I Kgs" 11 26)
                 :lesson2 ("Rev" 6)))
     (thursday
      :mattins  (:lesson1 ("Gen" 3)
                 :lesson2 (("Mark" 2 23) ("Mark" 3 1 12)))
      :evensong (:lesson1 ("I Kgs" 12 1 19)
                 :lesson2 ("Rev" 7)))
     (friday
      :mattins  (:lesson1 ("Gen" 4 1 15)
                 :lesson2 ("Mark" 3 13))
      :evensong (:lesson1 ("I Kgs" 12 20)
                 :lesson2 ("Rev" 8)))
     (saturday
      :mattins  (:lesson1 ("Gen" 4 16)
                 :lesson2 ("Mark" 4 1 34))
      :evensong (:lesson1 ("I Kgs" 13 1 10)
                 :lesson2 ("Rev" 9 1 12))))

    (advent-2
     (sunday
      :mattins  (:lesson1 ("Isa" 35)
                 :lesson2 ("Luke" 4 14 32))
      :evensong (:lesson1 ("Judg" 16 21)
                 :lesson2 ("Luke" 6 27 42)))
     (monday
      :mattins  (:lesson1 ("Gen" 6)
                 :lesson2 (("Mark" 4 35) ("Mark" 5 1 20)))
      :evensong (:lesson1 (("I Kgs" 13 33) ("I Kgs" 14 1 20))
                 :lesson2 ("Rev" 6 13)))
     (tuesday
      :mattins  (:lesson1 ("Gen" 7 1 12)
                 :lesson2 ("Mark" 5 21))
      :evensong (:lesson1 ("I Esd" 15 21)
                 :lesson2 ("Rev" 11 1 14)))
     (wednesday
      :mattins  (:lesson1 ("Gen" 7 13)
                 :lesson2 ("Mark" 6 1 29))
      :evensong (:lesson1 ("I Kgs" 16 1 14)
                 :lesson2 ("Rev" 11 1 14)))
     (thursday
      :mattins  (:lesson1 ("Gen" 8 1 19)
                 :lesson2 ("Mark" 6 30))
      :evensong (:lesson1 ("I Kgs" 16 11 33)
                 :lesson2 (("Rev" 11 15) ("Rev" 12 1 6))))
     (friday
      :mattins  (:lesson1 (("Gen" 8 20) ("Gen" 9 1 19))
                 :lesson2 ("Mark" 7 1 23))
      :evensong (:lesson1 ("I Kgs" 17)
                 :lesson2 ("Rev" 12 1)))
     (saturday
      :mattins  (:lesson1 ("Gen" 11 1 9)
                 :lesson2 ("Mark" 7 24))
      :evensong (:lesson1 ("I Kgs" 18 1 15)             ; VERIFY — "18:1-Is." in source
                 :lesson2 ("Rev" 13))))

    (advent-3
     (sunday
      :mattins  (:lesson1 ("Isa" 40 1 11)
                 :lesson2 ("Luke" 3 1 18))
      :evensong (:lesson1 ("Isa" 61)
                 :lesson2 (("Matt" 9 35) ("Matt" 10 1 7))))
     (monday
      :mattins  (:lesson1 ("II Esd" 6 38 55)
                 :lesson2 ("Mark" 8 1 21))
      :evensong (:lesson1 ("I Kgs" 18 21)
                 :lesson2 ("Rev" 14)))
     (tuesday
      :mattins  (:lesson1 (("Ecclus" 42 15) ("Ecclus" 43 1 10))
                 :lesson2 (("Mark" 8 22) ("Mark" 9 1 1)))
      :evensong (:lesson1 ("I Kgs" 19)
                 :lesson2 (("Rev" 15) ("Rev" 16))))
     (wednesday
      :mattins  (:lesson1 ("Ecclus" 43 11)
                 :lesson2 ("Mark" 9 2 29))
      :evensong (:lesson1 ("I Kgs" 20 1 21)
                 :lesson2 ("Rev" 17)))                  ; VERIFY — Ember Day
     (thursday
      :mattins  (:lesson1 (("Ecclus" 16 24) ("Ecclus" 17 1 15))
                 :lesson2 ("Mark" 9 30))
      :evensong (:lesson1 ("I Kgs" 20 22 34)
                 :lesson2 ("Rev" 18)))                  ; VERIFY
     (friday
      :mattins  (:lesson1 ("Mal" 3 1 12)
                 :lesson2 ("Matt" 9 1 17))
      :evensong (:lesson1 ("I Sam" 3)
                 :lesson2 ("Rev" 19)))
     (saturday
      :mattins  (:lesson1 ("Mal" 3 13)
                 :lesson2 ("Matt" 10 24))
      :evensong (:lesson1 ("Amos" 7 15)
                 :lesson2 ("Rev" 20))))

    (advent-4
     (sunday
      :mattins  (:lesson1 ("Isa" 52 1 10)
                 :lesson2 ("Matt" 25 1 13))
      :evensong (:lesson1 ("I Kgs" 17 1 16)
                 :lesson2 ("Matt" 3 1 12)))
     (monday
      :mattins  (:lesson1 ("Isa" 1 1 20)
                 :lesson2 ("Mark" 11 1 26))
      :evensong (:lesson1 ("Deut" 18 9)
                 :lesson2 ("Rev" 21)))
     (tuesday
      :mattins  (:lesson1 ("Isa" 2 1 21)               ; VERIFY range
                 :lesson2 (("Mark" 11 27) ("Mark" 12 1 12)))
      :evensong (:lesson1 (("Mic" 3 5) ("Mic" 4 1 7))
                 :lesson2 ("Rev" 22)))
     (wednesday
      :mattins  (:lesson1 (("Isa" 2 22) ("Isa" 3 1 15))
                 :lesson2 ("Mark" 12 13))             ; VERIFY — source reads "Mark 12.-v.13"
      :evensong (:lesson1 ("Joel" 3 9)
                 :lesson2 ("Luke" 1 1 25)))
     (thursday
      :mattins  (:lesson1 ("Isa" 5 1 16)
                 :lesson2 ("Mark" 13 1 20))
      :evensong (:lesson1 ("Ezek" 12 21)
                 :lesson2 ("Luke" 1 26 38)))
     (friday
      :mattins  (:lesson1 ("Isa" 5 18)
                 :lesson2 ("Mark" 13 21))
      :evensong (:lesson1 ("Zech" 2 10)
                 :lesson2 ("Luke" 1 39 56)))
     (saturday
      :mattins  (:lesson1 (("Isa" 9 8) ("Isa" 10 1 4))
                 :lesson2 ("Matt" 1 18))
      :evensong (:lesson1 ("Mic" 5 2 7)                  ; † both lessons may be used Christmas Eve
                 :lesson2 ("Luke" 1 57))))

    ;;;; ── CHRISTMAS OCTAVE — weekdays (fixed-date, DOW = day) ───────────────

    ;;;; ── SUNDAYS AFTER CHRISTMAS ────────────────────────────────────────────

    (after-christmas-1
     (sunday
      :mattins  (:lesson1 ("I Sam" 1 20)
                 :lesson2 ("Luke" 2 22 40))
      :evensong (:lesson1 ("Isa" 9 2 7)
                 :lesson2 ("Luke" 2 1 19))))

    (after-christmas-2
     (sunday
      :mattins  (:lesson1 ("Exod" 2 1 10)
                 :lesson2 ("Matt" 2 13))
      :evensong (:lesson1 ("Prov" 31 10 29)
                 :lesson2 ("Luke" 2 13 32))))

    ;;;; ── SUNDAYS AND WEEKDAYS AFTER EPIPHANY ───────────────────────────────

    (after-epiphany-1
     (sunday
      :mattins  (:lesson1 ("Gen" 28 10)
                 :lesson2 ("Matt" 2 1 11))
      :evensong (:lesson1 (("I Sam" 2 1 11) ("I Sam" 2 26 26)) ; non-contig approx
                 :lesson2 (("Matt" 18 1 3) ("Matt" 18 10 14)))) ; non-contig approx
     (monday
      :mattins  (:lesson1 ("Isa" 42 5 12)
                 :lesson2 ("Gal" 1))
      :evensong (:lesson1 ("Jer" 31 1 9)
                 :lesson2 ("John" 2 12)))
     (tuesday
      :mattins  (:lesson1 ("Isa" 45 11 23)
                 :lesson2 ("Gal" 2))
      :evensong (:lesson1 ("Jer" 31 27 37)
                 :lesson2 ("John" 3 1 21)))
     (wednesday
      :mattins  (:lesson1 ("Isa" 55)
                 :lesson2 ("Gal" 3))
      :evensong (:lesson1 ("Jer" 33 14)
                 :lesson2 ("John" 3 22)))
     (thursday
      :mattins  (:lesson1 ("Isa" 56 1 8)
                 :lesson2 (("Gal" 4 1) ("Gal" 5 1 1)))
      :evensong (:lesson1 ("Ezek" 36 1 15)
                 :lesson2 ("John" 4 1 26)))
     (friday
      :mattins  (:lesson1 ("Isa" 61)
                 :lesson2 ("Gal" 5 2))
      :evensong (:lesson1 ("Zeph" 3 7)
                 :lesson2 ("John" 4 27 42)))
     (saturday
      :mattins  (:lesson1 ("Isa" 66 1 14)             ; non-contig 1-2,10-14 approx
                 :lesson2 ("Gal" 6))
      :evensong (:lesson1 ("Zech" 14 1 9)
                 :lesson2 ("John" 4 43))))

    (after-epiphany-2
     (sunday
      :mattins  (:lesson1 ("Exod" 3 1 15)
                 :lesson2 ("Mark" 9 2 13))
      :evensong (:lesson1 ("Neh" 2 1 11)
                 :lesson2 ("Acts" 5 17 32)))
     (monday
      :mattins  (:lesson1 (("Gen" 11 27) ("Gen" 12 1 9))
                 :lesson2 ("Rom" 1 1 13))
      :evensong (:lesson1 ("I Kgs" 22 1 28)
                 :lesson2 ("John" 5 1 24)))
     (tuesday
      :mattins  (:lesson1 ("Gen" 13)
                 :lesson2 ("Rom" 1 14 25))
      :evensong (:lesson1 ("I Kgs" 22 29 40)
                 :lesson2 ("John" 5 25)))
     (wednesday
      :mattins  (:lesson1 ("Gen" 14)                  ; VERIFY
                 :lesson2 ("Rom" 2 1 16))
      :evensong (:lesson1 (("I Kgs" 22 51) ("II Kgs" 1))
                 :lesson2 ("John" 6 1 21)))
     (thursday
      :mattins  (:lesson1 ("Gen" 14 1 18)
                 :lesson2 ("Rom" 2 17))
      :evensong (:lesson1 ("II Kgs" 2 1 22)
                 :lesson2 ("John" 6 22 39)))
     (friday
      :mattins  (:lesson1 ("Gen" 15 1 18)
                 :lesson2 ("Rom" 3 1 18))
      :evensong (:lesson1 ("II Kgs" 3 1 24)
                 :lesson2 ("John" 6 40 51)))
     (saturday
      :mattins  (:lesson1 ("Gen" 16)
                 :lesson2 ("Rom" 3 19))
      :evensong (:lesson1 ("II Kgs" 4 8 37)
                 :lesson2 ("John" 6 51))))

    (after-epiphany-3
     (sunday
      :mattins  (:lesson1 (("I Sam" 3 1 10) ("I Sam" 3 16 16)) ; non-contig approx
                 :lesson2 ("Mark" 10 13 16))
      :evensong (:lesson1 ("Acts" 10 1 35)             ; VERIFY
                 :lesson2 ("Acts" 10 35)))              ; VERIFY
     (monday
      :mattins  (:lesson1 ("Gen" 17 1 22)
                 :lesson2 ("Rom" 4 1 13))
      :evensong (:lesson1 ("II Kgs" 5)
                 :lesson2 ("John" 7 1 30)))
     (tuesday
      :mattins  (:lesson1 ("Gen" 18 1 15)
                 :lesson2 ("Rom" 4 14))
      :evensong (:lesson1 ("II Kgs" 6 1 23)
                 :lesson2 ("John" 7 31)))
     (wednesday
      :mattins  (:lesson1 ("Gen" 19 1 29)
                 :lesson2 ("Rom" 5 1 12))
      :evensong (:lesson1 (("II Kgs" 6 24) ("II Kgs" 7)) ; non-contig approx
                 :lesson2 ("John" 8 1 11)))
     (thursday
      :mattins  (:lesson1 ("Gen" 20)                  ; VERIFY
                 :lesson2 ("Rom" 8 1 15))
      :evensong (:lesson1 ("II Kgs" 8 1 15)
                 :lesson2 ("John" 8 12 32)))
     (friday
      :mattins  (:lesson1 ("Gen" 21 1 21)
                 :lesson2 ("Rom" 6 1 14))
      :evensong (:lesson1 ("II Kgs" 9 1 21)           ; approx 1-7,11-end
                 :lesson2 ("John" 8 31)))
     (saturday
      :mattins  (:lesson1 ("Gen" 21 22)
                 :lesson2 ("Rom" 6 15))
      :evensong (:lesson1 ("II Kgs" 10 18)
                 :lesson2 ("John" 9 1 23))))

    (after-epiphany-4
     (sunday
      :mattins  (:lesson1 ("I Kgs" 18 17 39)          ; VERIFY range
                 :lesson2 ("Mark" 1 32))
      :evensong (:lesson1 ("Num" 22 1 35)
                 :lesson2 ("Matt" 23 16 26)))
     (monday
      :mattins  (:lesson1 ("Gen" 22 1 19)
                 :lesson2 ("Rom" 7 1 12))
      :evensong (:lesson1 ("II Kgs" 13)
                 :lesson2 ("John" 9 24)))
     (tuesday
      :mattins  (:lesson1 ("Gen" 23)
                 :lesson2 ("Rom" 7 13))
      :evensong (:lesson1 ("Jonah" 1 1 16)
                 :lesson2 ("John" 10 1 21)))
     (wednesday
      :mattins  (:lesson1 ("Gen" 24 1 28)
                 :lesson2 ("Rom" 8 1 11))
      :evensong (:lesson1 (("Jonah" 3) ("Jonah" 4))
                 :lesson2 ("John" 10 22)))
     (thursday
      :mattins  (:lesson1 ("Gen" 24 29 52)
                 :lesson2 ("Rom" 8 11 25))
      :evensong (:lesson1 ("II Kgs" 14 23)
                 :lesson2 ("John" 11 1 16)))
     (friday
      :mattins  (:lesson1 ("Gen" 25 7 34)             ; non-contig 7-12,19-34 approx
                 :lesson2 ("Rom" 8 26))
      :evensong (:lesson1 ("Amos" 1)
                 :lesson2 ("John" 11 17 44)))
     (saturday
      :mattins  (:lesson1 ("Gen" 26 1 31)
                 :lesson2 ("Rom" 9 1 18))
      :evensong (:lesson1 ("Amos" 2 4)                ; approx 2:4-end
                 :lesson2 ("John" 11 45))))

    (after-epiphany-5
     (sunday
      :mattins  (:lesson1 (("Gen" 31 41) ("Gen" 32 1 19)) ; VERIFY
                 :lesson2 ("Mark" 8 22))               ; VERIFY
      :evensong (:lesson1 ("Num" 23 1 26)              ; VERIFY
                 :lesson2 ("Acts" 5 11 26)))            ; VERIFY
     (monday
      :mattins  (:lesson1 ("Gen" 27 1 29)              ; VERIFY
                 :lesson2 ("Rom" 10 1))                ; VERIFY
      :evensong (:lesson1 ("Amos" 4 1)                 ; VERIFY
                 :lesson2 ("John" 12 12)))              ; VERIFY
     (tuesday
      :mattins  (:lesson1 (("Gen" 27 30) ("Gen" 28 1 5)) ; VERIFY
                 :lesson2 ("Rom" 10 11))               ; VERIFY
      :evensong (:lesson1 ("Amos" 5)                   ; VERIFY
                 :lesson2 ("John" 12 20)))              ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Gen" 29 1 20)              ; VERIFY
                 :lesson2 ("Rom" 11 1 11))             ; VERIFY
      :evensong (:lesson1 ("Hos" 4 1 9)                ; VERIFY
                 :lesson2 ("John" 14 1 14)))            ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Gen" 30 1 24)              ; VERIFY
                 :lesson2 ("Rom" 11 25))               ; VERIFY
      :evensong (:lesson1 ("Hos" 6)                    ; VERIFY
                 :lesson2 ("John" 14 15)))              ; VERIFY
     (friday
      :mattins  (:lesson1 ("Gen" 31 1 21)              ; VERIFY
                 :lesson2 ("Rom" 12))                  ; VERIFY
      :evensong (:lesson1 ("Hos" 11)                   ; VERIFY
                 :lesson2 ("John" 15 1 16)))            ; VERIFY
     (saturday
      :mattins  (:lesson1 (("Gen" 31 22) ("Gen" 32 1 2)) ; VERIFY
                 :lesson2 ("Rom" 13))                  ; VERIFY
      :evensong (:lesson1 ("Hos" 14)                   ; VERIFY
                 :lesson2 ("John" 16 1 15))))           ; VERIFY

    (after-epiphany-6
     (sunday
      :mattins  (:lesson1 ("Dan" 3 8)                  ; VERIFY
                 :lesson2 ("Mark" 10 46))              ; VERIFY
      :evensong (:lesson1 ("Num" 24 2)                 ; VERIFY
                 :lesson2 ("Luke" 10 1 16)))            ; VERIFY
     (monday
      :mattins  (:lesson1 ("Gen" 33 1 17)              ; VERIFY
                 :lesson2 ("Rom" 14))                  ; VERIFY
      :evensong (:lesson1 ("I Kgs" 18 21)
                 :lesson2 ("John" 16 16)))              ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Gen" 35 1 15)              ; VERIFY
                 :lesson2 ("Rom" 15 1 13))             ; VERIFY
      :evensong (:lesson1 ("I Kgs" 19)
                 :lesson2 ("John" 17)))                ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Gen" 37 1 11)              ; VERIFY
                 :lesson2 ("Rom" 15 14))               ; VERIFY
      :evensong (:lesson1 ("I Kgs" 20 1 21)
                 :lesson2 ("John" 18 1 27)))            ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Gen" 37 12)                ; VERIFY
                 :lesson2 ("Rom" 16))                  ; VERIFY
      :evensong (:lesson1 ("I Kgs" 20 22 34)
                 :lesson2 ("John" 18 28)))              ; VERIFY
     (friday
      :mattins  (:lesson1 ("Gen" 39)                   ; VERIFY
                 :lesson2 ("Phil" 1 1 11))             ; VERIFY
      :evensong (:lesson1 ("I Kgs" 20 35)
                 :lesson2 ("John" 19 1 30)))            ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Gen" 40)                   ; VERIFY
                 :lesson2 ("Phil" 1 12))               ; VERIFY
      :evensong (:lesson1 (:multiple ("I Kgs" 21 1 20) ("I Kgs" 21 27))
                 :lesson2 ("John" 19 31))))             ; VERIFY

    ;;;; ── PRE-LENT ──────────────────────────────────────────────────────────

    (septuagesima
     (sunday
      :mattins  (:lesson1 ("Josh" 6 1 20)
                 :lesson2 ("Luke" 7 1 10))
      :evensong (:lesson1 ("Lam" 1 1 12)
                 :lesson2 ("Matt" 23 29)))             ; approx 23:29–24:2
     (monday
      :mattins  (:lesson1 ("Gen" 37 12)               ; VERIFY — may overlap Epiph-6
                 :lesson2 ("Phil" 1 1 11))             ; VERIFY
      :evensong (:lesson1 ("I Kgs" 14 21)             ; VERIFY
                 :lesson2 ("Phil" 4)))                 ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Gen" 38)                  ; VERIFY
                 :lesson2 ("Phil" 1 12))              ; VERIFY
      :evensong (:lesson1 ("I Kgs" 15 1 24)           ; VERIFY
                 :lesson2 ("I Thess" 1)))              ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Gen" 39)                  ; VERIFY
                 :lesson2 ("Phil" 2 1 13))            ; VERIFY
      :evensong (:lesson1 ("I Kgs" 16 1 14)           ; VERIFY
                 :lesson2 ("I Thess" 2)))              ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Gen" 40)                  ; VERIFY
                 :lesson2 ("Phil" 2 14))              ; VERIFY
      :evensong (:lesson1 ("I Kgs" 16 15)             ; VERIFY
                 :lesson2 ("I Thess" 3)))              ; VERIFY
     (friday
      :mattins  (:lesson1 ("Gen" 41 1 36)             ; VERIFY
                 :lesson2 ("Phil" 3))                 ; VERIFY
      :evensong (:lesson1 ("I Kgs" 17)                ; VERIFY
                 :lesson2 ("I Thess" 4)))              ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Gen" 41 37)               ; VERIFY
                 :lesson2 ("Phil" 4))                 ; VERIFY
      :evensong (:lesson1 ("I Kgs" 18 1 16)           ; VERIFY
                 :lesson2 ("I Thess" 5))))             ; VERIFY

    (sexagesima
     (sunday
      :mattins  (:lesson1 ("I Sam" 17 17)             ; VERIFY
                 :lesson2 ("Mark" 10 32 39))          ; VERIFY
      :evensong (:lesson1 ("I Sam" 22 1 23)           ; VERIFY
                 :lesson2 ("Acts" 12 1 17)))           ; VERIFY
     (monday
      :mattins  (:lesson1 ("Gen" 42 1 17)             ; VERIFY
                 :lesson2 ("Jas" 1 16))               ; VERIFY
      :evensong (:lesson1 ("II Chr" 24)               ; VERIFY
                 :lesson2 ("Matt" 18 1 14)))           ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Gen" 42 18)               ; VERIFY
                 :lesson2 ("Jas" 2))                  ; VERIFY
      :evensong (:lesson1 ("II Chr" 25)               ; VERIFY
                 :lesson2 ("Matt" 18 15)))             ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Gen" 43 1 14)             ; VERIFY
                 :lesson2 ("Jas" 3))                  ; VERIFY
      :evensong (:lesson1 ("II Chr" 26 1 21)          ; VERIFY
                 :lesson2 ("Matt" 19 1 15)))           ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Gen" 43 15)               ; VERIFY
                 :lesson2 ("Jas" 4))                  ; VERIFY
      :evensong (:lesson1 ("II Chr" 28)               ; VERIFY
                 :lesson2 ("Matt" 19 16)))             ; VERIFY
     (friday
      :mattins  (:lesson1 ("Gen" 44 1 17)             ; VERIFY
                 :lesson2 ("Jas" 5 1 13))             ; VERIFY
      :evensong (:lesson1 ("II Chr" 29 1 19)          ; VERIFY
                 :lesson2 ("Matt" 20 1 16)))           ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Gen" 44 18)               ; VERIFY
                 :lesson2 ("Jas" 5 13))               ; VERIFY
      :evensong (:lesson1 ("II Chr" 30)               ; VERIFY
                 :lesson2 ("Matt" 20 17))))            ; VERIFY

    (quinquagesima
     (sunday
      :mattins  (:lesson1 ("Ruth" 1 17)               ; VERIFY
                 :lesson2 ("Mark" 15 1))              ; VERIFY
      :evensong (:lesson1 ("Isa" 63 7 36)             ; non-contig approx; VERIFY
                 :lesson2 ("I John" 4)))              ; VERIFY
     (monday
      :mattins  (:lesson1 (("Gen" 44 45) ("Gen" 45 1 1)) ; VERIFY garbled
                 :lesson2 ("Jas" 5 7))                ; VERIFY
      :evensong (:lesson1 ("II Chr" 32 1 5)           ; VERIFY
                 :lesson2 ("Matt" 21 1 16)))           ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Gen" 45 3)                ; VERIFY
                 :lesson2 ("I Pet" 1 1 19))           ; VERIFY
      :evensong (:lesson1 ("II Chr" 33)               ; VERIFY
                 :lesson2 ("Matt" 21 17)))             ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Gen" 45 16)               ; VERIFY
                 :lesson2 ("I Pet" 1 13))             ; VERIFY
      :evensong (:lesson1 ("II Chr" 34)               ; VERIFY
                 :lesson2 ("Matt" 21 28)))             ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Gen" 46 1)                ; VERIFY
                 :lesson2 ("I Pet" 2 1 11))           ; VERIFY
      :evensong (:lesson1 ("II Chr" 35 1 19)          ; VERIFY
                 :lesson2 ("Matt" 22 1 14)))           ; VERIFY
     (friday
      :mattins  (:lesson1 ("Gen" 46 7)                ; non-contig 7,26-end approx; VERIFY
                 :lesson2 ("I Pet" 2 11))             ; VERIFY
      :evensong (:lesson1 ("II Chr" 36 1 15)          ; non-contig approx; VERIFY
                 :lesson2 ("Matt" 22 15)))             ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Gen" 47 1)                ; VERIFY
                 :lesson2 ("I Pet" 3 1))              ; VERIFY
      :evensong (:lesson1 ("Micah" 5 2 7)              ; † may also be used Christmas Eve
                 :lesson2 ("Matt" 22 34))))            ; VERIFY

    ;;;; ── ASH WEDNESDAY ──────────────────────────────────────────────────────

    (ash-wednesday
     (ash-wednesday
      :mattins  (:lesson1 ("Isa" 1 2 20)
                 :lesson2 ("Luke" 15 1 10))
      :evensong (:lesson1 ("Isa" 26 1)
                 :lesson2 ("Mark" 1 1 13))))

    ;;;; ── LENT ───────────────────────────────────────────────────────────────

    (lent-1
     (sunday
      :mattins  (:lesson1 ("II Sam" 12 1 13)          ; VERIFY — complex reference
                 :lesson2 ("Luke" 11 10 14))
      :evensong (:lesson1 ("I Sam" 26 5)
                 :lesson2 ("Mark" 1 9 28)))
     (monday
      :mattins  (:lesson1 ("Gen" 47 13)
                 :lesson2 ("I Cor" 3 10))
      :evensong (:lesson1 ("Hab" 1 1)                 ; approx 1:1–2:4
                 :lesson2 ("Luke" 5 1 16)))
     (tuesday
      :mattins  (:lesson1 ("Gen" 48)
                 :lesson2 ("I Cor" 4 1 17))
      :evensong (:lesson1 ("Jer" 13 1 25)
                 :lesson2 ("Luke" 3 17)))
     (wednesday
      :mattins  (:lesson1 ("Gen" 49)
                 :lesson2 (("I Cor" 4 18) ("I Cor" 5)))
      :evensong (:lesson1 ("Jer" 35)
                 :lesson2 ("Luke" 6 1 11)))
     (thursday
      :mattins  (:lesson1 ("Gen" 50 1 14)
                 :lesson2 ("I Cor" 6))
      :evensong (:lesson1 ("Jer" 36)
                 :lesson2 ("Luke" 6 12)))
     (friday
      :mattins  (:lesson1 ("Gen" 50 15)
                 :lesson2 ("I Cor" 7 1 35))
      :evensong (:lesson1 ("Jer" 25 1 14)
                 :lesson2 ("Luke" 7 1 23)))
     (saturday
      :mattins  (:lesson1 ("Exod" 1)
                 :lesson2 ("I Cor" 7 36))
      :evensong (:lesson1 ("Jer" 22)
                 :lesson2 ("Luke" 7 24))))

    (lent-2
     (sunday
      :mattins  (:lesson1 ("Gen" 50 7 21)             ; VERIFY
                 :lesson2 ("Matt" 18 21))
      :evensong (:lesson1 ("I Sam" 19 1 18)           ; VERIFY — "Sam" in scratch
                 :lesson2 ("Matt" 21 1 22)))
     (monday
      :mattins  (:lesson1 ("Exod" 1 1 14)
                 :lesson2 ("I Cor" 9 1 23))
      :evensong (:lesson1 (("II Kgs" 23 36) ("II Kgs" 24 1 17))
                 :lesson2 ("Luke" 8 22 39)))
     (tuesday
      :mattins  (:lesson1 (("Exod" 1 22) ("Exod" 2 1 10))
                 :lesson2 (("I Cor" 9 24) ("I Cor" 10 1 14)))
      :evensong (:lesson1 ("Jer" 24)
                 :lesson2 ("Luke" 8 40)))
     (wednesday
      :mattins  (:lesson1 ("Exod" 2 11)
                 :lesson2 ("I Cor" 10 15))
      :evensong (:lesson1 ("Jer" 29 1 14)
                 :lesson2 ("Luke" 9 1 17)))
     (thursday
      :mattins  (:lesson1 ("Exod" 3 1 20)
                 :lesson2 ("I Cor" 11 17))
      :evensong (:lesson1 ("Jer" 21)
                 :lesson2 ("Luke" 9 18)))
     (friday
      :mattins  (:lesson1 ("Exod" 4 1 23)
                 :lesson2 ("I Cor" 12 1 26))
      :evensong (:lesson1 ("Jer" 38 1 13)
                 :lesson2 ("Luke" 9 18)))              ; VERIFY Luke ref
     (saturday
      :mattins  (:lesson1 ("Exod" 4 27)
                 :lesson2 ("I Cor" 12 27))
      :evensong (:lesson1 ("Jer" 22)                  ; VERIFY
                 :lesson2 ("Luke" 9 37))))             ; VERIFY

    (lent-3
     (sunday
      :mattins  (:lesson1 ("Gen" 50 7 21)             ; VERIFY
                 :lesson2 ("Matt" 18 21))
      :evensong (:lesson1 ("Gen" 27 1 38)             ; VERIFY
                 :lesson2 ("Matt" 20 1 28)))           ; VERIFY
     (monday
      :mattins  (:lesson1 ("Exod" 5 1)
                 :lesson2 ("I Cor" 13 1))
      :evensong (:lesson1 ("Jer" 37)
                 :lesson2 ("Luke" 9 51)))
     (tuesday
      :mattins  (:lesson1 ("Exod" 6 28)
                 :lesson2 ("I Cor" 14 1 19))
      :evensong (:lesson1 ("Jer" 38 14)
                 :lesson2 ("Luke" 10 25)))
     (wednesday
      :mattins  (:lesson1 ("Exod" 7 8 25)
                 :lesson2 ("I Cor" 14 20))
      :evensong (:lesson1 (("Jer" 39 11) ("Jer" 40))
                 :lesson2 ("Luke" 11 1)))
     (thursday
      :mattins  (:lesson1 ("Exod" 8 1 19)
                 :lesson2 ("I Cor" 15 1 20))
      :evensong (:lesson1 ("Jer" 40 7)
                 :lesson2 ("Luke" 11 29)))
     (friday
      :mattins  (:lesson1 ("Exod" 8 20)
                 :lesson2 ("I Cor" 15 20))
      :evensong (:lesson1 ("Jer" 41)
                 :lesson2 ("Luke" 12 1 12)))
     (saturday
      :mattins  (:lesson1 ("Exod" 9 1 12)
                 :lesson2 ("I Cor" 15 35))
      :evensong (:lesson1 ("Jer" 42)
                 :lesson2 ("Luke" 12 13))))

    (lent-4
     (sunday
      :mattins  (:lesson1 ("II Sam" 5 1)              ; VERIFY
                 :lesson2 ("Mark" 15 5))
      :evensong (:lesson1 ("II Sam" 11 1 17)          ; VERIFY
                 :lesson2 ("Mark" 9 14)))              ; VERIFY
     (monday
      :mattins  (:lesson1 ("Exod" 9 13)
                 :lesson2 ("II Cor" 1 1 22))
      :evensong (:lesson1 (("II Kgs" 24 18) ("II Kgs" 25 1 11)) ; approx; VERIFY
                 :lesson2 ("Luke" 12 35)))             ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Exod" 10 1 20)
                 :lesson2 (("II Cor" 1 23) ("II Cor" 2)))
      :evensong (:lesson1 ("Jer" 24)
                 :lesson2 ("Luke" 13 1 17)))
     (wednesday
      :mattins  (:lesson1 ("Exod" 10 21)
                 :lesson2 (("II Cor" 3 1) ("II Cor" 4 1 6)))
      :evensong (:lesson1 ("Jer" 41)
                 :lesson2 ("Luke" 13 18)))
     (thursday
      :mattins  (:lesson1 ("Exod" 11)
                 :lesson2 ("II Cor" 4 7))              ; VERIFY
      :evensong (:lesson1 ("Jer" 42)
                 :lesson2 ("Luke" 14 1 24)))           ; VERIFY
     (friday
      :mattins  (:lesson1 ("Exod" 12 1 20)
                 :lesson2 (("II Cor" 5 11) ("II Cor" 6 1 10)))
      :evensong (:lesson1 ("Jer" 43)
                 :lesson2 ("Luke" 14 25)))
     (saturday
      :mattins  (:lesson1 ("Exod" 12 21 36)
                 :lesson2 (("II Cor" 6 11) ("II Cor" 7)))
      :evensong (:lesson1 ("Jer" 22)
                 :lesson2 ("Luke" 15))))

    (lent-5
     (sunday
      :mattins  (:lesson1 ("Gen" 22 1)                ; VERIFY
                 :lesson2 ("John" 10 1 16))
      :evensong (:lesson1 ("I Kgs" 8 22 53)           ; VERIFY
                 :lesson2 ("Heb" 11 1 17)))            ; VERIFY
     (monday
      :mattins  (:lesson1 ("Gen" 22 1)                ; VERIFY L1 dup
                 :lesson2 ("II Cor" 8 1 22))
      :evensong (:lesson1 ("I Kgs" 8 54)              ; VERIFY
                 :lesson2 ("Luke" 16 1 18)))
     (tuesday
      :mattins  (:lesson1 ("Exod" 13 1 16)
                 :lesson2 (("II Cor" 8 23) ("II Cor" 9)))
      :evensong (:lesson1 ("Dan" 3)
                 :lesson2 ("Luke" 16 19)))
     (wednesday
      :mattins  (:lesson1 ("Exod" 13 17)
                 :lesson2 ("II Cor" 10 1 24))
      :evensong (:lesson1 ("Dan" 4)
                 :lesson2 ("Luke" 17 11)))
     (thursday
      :mattins  (:lesson1 ("Exod" 14 1 14)
                 :lesson2 ("II Cor" 11))
      :evensong (:lesson1 ("Dan" 5)
                 :lesson2 ("Luke" 18 1 27)))
     (friday
      :mattins  (:lesson1 ("Exod" 14 15)
                 :lesson2 ("II Cor" 12))
      :evensong (:lesson1 ("Dan" 6)
                 :lesson2 ("Luke" 18 28)))             ; VERIFY
     (saturday
      :mattins  (:lesson1 (("Wis" 9 17) ("Wis" 10))  ; VERIFY; non-contig approx
                 :lesson2 ("II Cor" 13 1))
      :evensong (:lesson1 ("Amos" 7 1 15)             ; VERIFY; non-contig approx
                 :lesson2 ("Luke" 7 24))))             ; VERIFY

    ;;;; ── PALM SUNDAY and HOLY WEEK ─────────────────────────────────────────

    (palm-sunday
     (sunday
      :mattins  (:lesson1 ("Zech" 9 9 16)
                 :lesson2 ("Matt" 21 1 13))
      :evensong (:lesson1 (("Isa" 52 13) ("Isa" 53)) ; VERIFY
                 :lesson2 ("Luke" 19 28)))             ; VERIFY
     (monday
      :mattins  (:lesson1 (("Exod" 15 22) ("Exod" 16 1 10))
                 :lesson2 ("Mark" 11 1 26))
      :evensong (:lesson1 ("Isa" 40 15)               ; VERIFY
                 :lesson2 ("II Cor" 13)))              ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Exod" 16 11 35)
                 :lesson2 ("John" 20 1 18))
      :evensong (:lesson1 ("Isa" 40 12)               ; VERIFY
                 :lesson2 ("II Cor" 13)))              ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Isa" 42 1 12)
                 :lesson2 ("John" 10 11 18))
      :evensong (:lesson1 ("Exod" 37 3 28)            ; VERIFY
                 :lesson2 ("Luke" 22 1 6)))            ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Jer" 31 31 34)
                 :lesson2 ("John" 13 1 35))            ; approx 1-17,33-35; VERIFY
      :evensong (:lesson1 ("Exod" 16 4 15)            ; VERIFY
                 :lesson2 ("Luke" 22 7 22)))           ; VERIFY
     (friday
      :mattins  (:lesson1 ("Gen" 22 1 18)
                 :lesson2 ("John" 18))
      :evensong (:lesson1 (("Isa" 52 13) ("Isa" 53))
                 :lesson2 ("Luke" 23 13 47)))          ; Good Friday
     (saturday
      :mattins  (:lesson1 ("Job" 14 1 15)
                 :lesson2 ("Acts" 15))                 ; VERIFY
      :evensong (:lesson1 ("Exod" 12 1 14)            ; VERIFY
                 :lesson2 ("Luke" 23 50))))            ; Easter Even; VERIFY

    ;;;; ── EASTER ─────────────────────────────────────────────────────────────

    (easter
     (sunday
      :mattins  (:lesson1 ("Isa" 51 9 16)
                 :lesson2 ("Luke" 24 1 12))
      :evensong (:lesson1 ("Exod" 15 1 21)            ; VERIFY
                 :lesson2 ("Matt" 28 1 10)))           ; approx 1-10,16-end; VERIFY
     (monday
      :mattins  (:lesson1 (("Exod" 15 22) ("Exod" 16 1 10))
                 :lesson2 ("Mark" 16 1 8))
      :evensong (:lesson1 ("Isa" 40 1 11)
                 :lesson2 ("Luke" 24 13 35)))
     (tuesday
      :mattins  (:lesson1 ("Exod" 16 11 35)
                 :lesson2 ("John" 20 1 18))
      :evensong (:lesson1 ("Isa" 40 12)
                 :lesson2 ("Luke" 24 36 49)))
     (wednesday
      :mattins  (:lesson1 ("Exod" 17)
                 :lesson2 (("Mark" 8 27) ("Mark" 9 1 1)))
      :evensong (:lesson1 ("Isa" 41 1 20)
                 :lesson2 ("John" 20 19)))
     (thursday
      :mattins  (:lesson1 ("Exod" 18)
                 :lesson2 ("John" 9 2 32))             ; approx; VERIFY
      :evensong (:lesson1 (("Isa" 41 21) ("Isa" 42 1 4))
                 :lesson2 ("John" 21 1 14)))           ; VERIFY
     (friday
      :mattins  (:lesson1 ("Exod" 19 1 14)
                 :lesson2 ("Mark" 10 32 45))
      :evensong (:lesson1 ("Isa" 42 5 16)
                 :lesson2 ("John" 21 15)))
     (saturday
      :mattins  (:lesson1 (("Exod" 19 18) ("Exod" 20 1 24))
                 :lesson2 ("Heb" 4 17))                ; VERIFY
      :evensong (:lesson1 (("Isa" 42 17) ("Isa" 43 1 7))
                 :lesson2 ("Mark" 16 9))))             ; VERIFY

    ;;;; ── SUNDAYS AND WEEKDAYS AFTER EASTER ──────────────────────────────────

    (after-easter-1
     (sunday
      :mattins  (:lesson1 ("II Kgs" 4 18 37)
                 :lesson2 ("John" 20 24))
      :evensong (:lesson1 (("Ezek" 34 11 16) ("Ezek" 34 30 31)) ; non-contig approx
                 :lesson2 ("John" 10 11 18)))
     (monday
      :mattins  (:lesson1 ("Exod" 24)
                 :lesson2 ("I Pet" 1 1 21))
      :evensong (:lesson1 ("Isa" 43 8 21)
                 :lesson2 ("Acts" 3 12)))
     (tuesday
      :mattins  (:lesson1 ("Exod" 25 1 22)
                 :lesson2 (("I Pet" 1 22) ("I Pet" 2 1 10)))
      :evensong (:lesson1 (("Isa" 43 22) ("Isa" 44 1 5))
                 :lesson2 ("Luke" 7 11 16)))
     (wednesday
      :mattins  (:lesson1 ("Exod" 31)
                 :lesson2 ("I Pet" 2 11))
      :evensong (:lesson1 ("Isa" 44 6 23)
                 :lesson2 ("Acts" 13 16 39)))
     (thursday
      :mattins  (:lesson1 ("Exod" 32 1 24)
                 :lesson2 ("I Pet" 3 8))
      :evensong (:lesson1 (("Isa" 44 24) ("Isa" 45 1 13))
                 :lesson2 ("Isa" 49 1 13)))
     (friday
      :mattins  (:lesson1 (("Exod" 32 30) ("Exod" 33))
                 :lesson2 ("I Pet" 4 2))
      :evensong (:lesson1 ("Isa" 49 14 23)
                 :lesson2 ("Acts" 26 1 23)))
     (saturday
      :mattins  (:lesson1 ("Exod" 34 1 10)
                 :lesson2 ("I Pet" 5))
      :evensong (:lesson1 (("Isa" 49 24) ("Isa" 50))
                 :lesson2 ("Acts" 9 32))))             ; VERIFY

    (after-easter-2
     (sunday
      :mattins  (:lesson1 ("II Sam" 1 19)             ; VERIFY
                 :lesson2 ("John" 20 24))
      :evensong (:lesson1 (("Ezek" 34 11 16) ("Ezek" 34 30 31)) ; non-contig approx; VERIFY
                 :lesson2 ("John" 10 1 11)))           ; VERIFY
     (monday
      :mattins  (:lesson1 ("Exod" 34 27)              ; VERIFY
                 :lesson2 ("Col" 1 1 17))
      :evensong (:lesson1 ("Isa" 43 8 21)             ; VERIFY
                 :lesson2 ("Acts" 3 12)))              ; VERIFY
     (tuesday
      :mattins  (:lesson1 (("Exod" 35 20) ("Exod" 36 1 1)) ; VERIFY
                 :lesson2 (("Col" 1 18) ("Col" 2 1 5)))
      :evensong (:lesson1 ("Isa" 50 1)                ; VERIFY
                 :lesson2 ("Acts" 7 1 16)))            ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Exod" 40 17)              ; VERIFY
                 :lesson2 (("Col" 2 4) ("Col" 3 1 3)))
      :evensong (:lesson1 ("Isa" 51 1 8)              ; VERIFY
                 :lesson2 ("Acts" 13 16 39)))          ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Num" 9 1 5)               ; approx 1-5,15-end; VERIFY
                 :lesson2 (("Col" 3 4) ("Col" 4 1 1)))
      :evensong (:lesson1 ("Isa" 51 9)                ; VERIFY
                 :lesson2 ("Isa" 49 1 13)))            ; VERIFY
     (friday
      :mattins  (:lesson1 ("Num" 10 1 13)             ; approx 1-13,29-end; VERIFY
                 :lesson2 ("Col" 4 2))
      :evensong (:lesson1 ("Isa" 49 14 23)            ; VERIFY
                 :lesson2 ("Acts" 26 1 23)))           ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Num" 11 1 17)             ; VERIFY
                 :lesson2 ("Phlm"))
      :evensong (:lesson1 (("Isa" 49 24) ("Isa" 50))  ; VERIFY
                 :lesson2 ("Acts" 9 32))))             ; VERIFY

    (after-easter-3
     (sunday
      :mattins  (:lesson1 ("II Kgs" 5 1 23)           ; VERIFY
                 :lesson2 ("John" 21 1 19))
      :evensong (:lesson1 ("Exod" 4 5)                ; VERIFY
                 :lesson2 ("Rom" 6 1 18)))             ; VERIFY
     (monday
      :mattins  (:lesson1 ("Num" 11 16)               ; VERIFY
                 :lesson2 ("Eph" 1 1 23))
      :evensong (:lesson1 ("I Cor" 15 1 11)           ; VERIFY
                 :lesson2 ("I Cor" 15 12 22)))         ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Num" 13 1 35)             ; approx 1-3,17-35; VERIFY
                 :lesson2 ("Eph" 2 4))
      :evensong (:lesson1 ("Isa" 51 9)                ; VERIFY
                 :lesson2 ("I Cor" 5 5)))              ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Num" 14 1 35)             ; VERIFY
                 :lesson2 ("Eph" 3))
      :evensong (:lesson1 ("Isa" 52 1 12)             ; VERIFY
                 :lesson2 ("II Cor" 5 5)))             ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Num" 14 11 35)            ; VERIFY
                 :lesson2 ("Eph" 4 1 16))
      :evensong (:lesson1 (("Isa" 52 13) ("Isa" 53))  ; VERIFY
                 :lesson2 ("Rom" 1 1 12)))             ; VERIFY
     (friday
      :mattins  (:lesson1 ("Num" 14 26)               ; VERIFY
                 :lesson2 ("Eph" 4 17))
      :evensong (:lesson1 ("Isa" 54)                  ; VERIFY
                 :lesson2 ("Rom" 6 1 13)))             ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Num" 16 1 40)             ; VERIFY
                 :lesson2 ("Eph" 5 1 21))
      :evensong (:lesson1 ("Isa" 54)                  ; VERIFY
                 :lesson2 ("Rom" 14 1 9))))            ; VERIFY

    (after-easter-4
     (sunday
      :mattins  (:lesson1 ("II Esd" 2 42 47)
                 :lesson2 ("John" 11 17 44))           ; approx 17-39a,41-44
      :evensong (:lesson1 ("Gen" 8 6 16)              ; approx 6-12,15-16,9:8-16
                 :lesson2 ("Mark" 12 18 27)))          ; approx 18-27a
     (monday
      :mattins  (:lesson1 (("Num" 16 41) ("Num" 17 1 11))
                 :lesson2 (("Eph" 5 22) ("Eph" 6 1 9)))
      :evensong (:lesson1 ("Isa" 55)
                 :lesson2 ("Phil" 3 7)))
     (tuesday
      :mattins  (:lesson1 (("Num" 17 12) ("Num" 18 1 24))
                 :lesson2 ("Eph" 6 10))
      :evensong (:lesson1 (("Isa" 56 1) ("Isa" 57 1 2))
                 :lesson2 ("II Cor" 1 1 10)))          ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Num" 20 1)
                 :lesson2 ("Heb" 1 1 12))
      :evensong (:lesson1 ("Isa" 38)
                 :lesson2 ("Rom" 1 1 17)))
     (thursday
      :mattins  (:lesson1 ("Num" 20 14)
                 :lesson2 (("Heb" 2 14) ("Heb" 3)))
      :evensong (:lesson1 ("Isa" 60)
                 :lesson2 ("I Cor" 15 35)))
     (friday
      :mattins  (:lesson1 ("Num" 21 1 9)
                 :lesson2 (("Heb" 4 14) ("Heb" 5 1 10)))
      :evensong (:lesson1 ("Isa" 61)
                 :lesson2 ("Rev" 21 1 7)))
     (saturday
      :mattins  (:lesson1 ("Num" 21 21)
                 :lesson2 ("Heb" 4 1 13))
      :evensong (:lesson1 ("Isa" 60)                  ; VERIFY
                 :lesson2 ("Rev" 21 7))))              ; VERIFY

    (after-easter-5
     (sunday
      :mattins  (:lesson1 ("Deut" 37 14)              ; VERIFY — garbled in source
                 :lesson2 ("Matt" 6 24))
      :evensong (:lesson1 ("Deut" 8)                  ; VERIFY
                 :lesson2 ("Jas" 1 1 17)))             ; VERIFY
     (monday
      :mattins  (:lesson1 (("Num" 23 27) ("Num" 24))
                 :lesson2 ("Matt" 6 9))               ; VERIFY
      :evensong (:lesson1 ("Deut" 8)                  ; VERIFY
                 :lesson2 ("Jas" 4))))                 ; VERIFY

    ;;;; ── ROGATION DAYS ──────────────────────────────────────────────────────

    (rogation-monday
     (rogation-monday
      :mattins  (:lesson1 ("Isa" 64)
                 :lesson2 ("Luke" 11 1 13))
      :evensong (:lesson1 ("I Kgs" 8 22 40)
                 :lesson2 ("Jas" 4))))

    (rogation-tuesday
     (rogation-tuesday
      :mattins  (:lesson1 ("Jer" 14)
                 :lesson2 ("John" 6 27 63))
      :evensong (:lesson1 ("Hab" 3 1 18)
                 :lesson2 ("Jas" 5))))

    (rogation-wednesday
     (rogation-wednesday
      :mattins  (:lesson1 ("Jer" 14)                  ; VERIFY — may be same as Tue
                 :lesson2 ("John" 6 27 63))
      :evensong (:lesson1 ("Gen" 5 18 24)             ; VERIFY
                 :lesson2 ("Eph" 4 1 13))))           ; VERIFY

    ;;;; ── ASCENSION DAY ───────────────────────────────────────────────────────

    (ascension
     (day
      :mattins  (:lesson1 ("II Kgs" 2 1 15)
                 :lesson2 (("Heb" 4 14) ("Heb" 5 1 10)))
      :evensong (:lesson1 ("Dan" 7 9 14)
                 :lesson2 ("Luke" 24 44))))

    ;;;; ── SUNDAY AFTER ASCENSION ──────────────────────────────────────────────

    (sunday-after-ascension
     (sunday
      :mattins  (:lesson1 ("II Kgs" 2 1 22)
                 :lesson2 (("Heb" 8 1) ("Heb" 9 1 12)))
      :evensong (:lesson1 ("Isa" 63 1 6)
                 :lesson2 ("John" 14 15 27)))
     (monday
      :mattins  (:lesson1 (("Num" 23 27) ("Num" 24)) ; VERIFY — same as Sunday?
                 :lesson2 (("Heb" 8 1) ("Heb" 9 1 12)))
      :evensong (:lesson1 ("Isa" 63 1 6)             ; VERIFY
                 :lesson2 ("John" 14 15 27)))         ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Num" 26 1 56)            ; approx; VERIFY
                 :lesson2 ("Heb" 9 11))
      :evensong (:lesson1 ("Isa" 63 7 16)            ; VERIFY
                 :lesson2 ("John" 14 15)))            ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Num" 27 12)              ; VERIFY
                 :lesson2 ("Heb" 10 1 34))
      :evensong (:lesson1 ("Isa" 63 17)              ; VERIFY
                 :lesson2 ("John" 16 1 16)))          ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Num" 32 1 23)            ; VERIFY
                 :lesson2 (("Heb" 11 23) ("Heb" 12 1 2)))
      :evensong (:lesson1 ("Isa" 63 17)              ; VERIFY
                 :lesson2 ("John" 16 16)))            ; VERIFY
     (friday
      :mattins  (:lesson1 ("Num" 27 12)              ; VERIFY
                 :lesson2 (("Heb" 11 23) ("Heb" 12 1 2)))
      :evensong (:lesson1 ("Isa" 63 15)              ; approx 15-17; VERIFY
                 :lesson2 ("John" 16 16)))            ; VERIFY
     (saturday
      :mattins  (:lesson1 (("Deut" 32 48) ("Deut" 33 1 29)) ; approx; VERIFY
                 :lesson2 ("Heb" 7))
      :evensong (:lesson1 ("Isa" 63 15)              ; VERIFY
                 :lesson2 ("John" 17))))              ; VERIFY

    ;;;; ── WHITSUNDAY ──────────────────────────────────────────────────────────

    (whitsunday
     (sunday
      :mattins  (:lesson1 ("Joel" 2 20)              ; VERIFY
                 :lesson2 ("John" 3 1 16))
      :evensong (:lesson1 (("Gen" 2 7 10) ("Gen" 2 15 24)) ; non-contig approx; VERIFY
                 :lesson2 ("Acts" 2 16 39)))          ; approx; VERIFY
     (monday
      :mattins  (:lesson1 ("Gen" 11 1 9)
                 :lesson2 ("Heb" 12 14))
      :evensong (:lesson1 ("Ezek" 11 14)
                 :lesson2 ("Acts" 2 38)))
     (tuesday
      :mattins  (:lesson1 ("Num" 11 16 29)           ; approx 16-17,24-29
                 :lesson2 ("Heb" 12 18))
      :evensong (:lesson1 ("Ezek" 47 8 12)
                 :lesson2 ("Acts" 3 1)))              ; approx 3:1–4:4
     (wednesday
      :mattins  (:lesson1 (("Ezek" 2 1) ("Ezek" 3 1 14))
                 :lesson2 ("Eph" 4 1 16))
      :evensong (:lesson1 ("Isa" 32 1 19)
                 :lesson2 ("Acts" 4 3 31)))
     (thursday
      :mattins  (:lesson1 ("Ezek" 3 15)              ; VERIFY
                 :lesson2 (("Gal" 5 16) ("Gal" 6 1 8)))
      :evensong (:lesson1 ("Jer" 31 27 37)
                 :lesson2 ("Acts" 4 32)))             ; approx 4:32–5:11; VERIFY
     (friday
      :mattins  (:lesson1 ("Jer" 33 14)
                 :lesson2 ("Gal" 6))
      :evensong (:lesson1 ("Isa" 42 1 12)
                 :lesson2 ("Acts" 5 12)))
     (saturday
      :mattins  (:lesson1 ("Isa" 61)                 ; VERIFY
                 :lesson2 ("Matt" 28 16))
      :evensong (:lesson1 ("Zech" 7 1 10)
                 :lesson2 ("Acts" 6))))               ; VERIFY

    ;;;; ── TRINITY SUNDAY AND WEEKDAYS ────────────────────────────────────────

    (trinity
     (sunday
      :mattins  (:lesson1 (("Gen" 1 1) ("Gen" 2 1 3))
                 :lesson2 ("John" 1 1 18))
      :evensong (:lesson1 ("Job" 38 1 7)             ; approx 38:1-7,42:1-5; VERIFY
                 :lesson2 ("Rev" 19 3 16)))           ; VERIFY
     (monday
      :mattins  (:lesson1 ("Josh" 1)
                 :lesson2 ("Matt" 3))
      :evensong (:lesson1 ("Ezra" 1)
                 :lesson2 ("Acts" 7 1 53)))
     (tuesday
      :mattins  (:lesson1 ("Josh" 2)
                 :lesson2 ("Matt" 4 1 11))
      :evensong (:lesson1 ("Ezra" 3)
                 :lesson2 ("Acts" 7 34)))             ; approx 7:34–8:12
     (wednesday
      :mattins  (:lesson1 ("Josh" 3)
                 :lesson2 ("Matt" 4 12))
      :evensong (:lesson1 ("Ezra" 4 1 6)             ; approx 4:1-6,24
                 :lesson2 ("Acts" 8 14)))
     (thursday
      :mattins  (:lesson1 ("Josh" 4)
                 :lesson2 ("Matt" 5 1 16))
      :evensong (:lesson1 ("Hag" 1)
                 :lesson2 ("Acts" 9 1 22)))
     (friday
      :mattins  (:lesson1 (("Josh" 5 10) ("Josh" 6 1 11))
                 :lesson2 ("Matt" 5 17 32))
      :evensong (:lesson1 ("Hag" 2 1 9)
                 :lesson2 ("Acts" 9 23)))
     (saturday
      :mattins  (:lesson1 ("Josh" 6 12)
                 :lesson2 ("Matt" 5 33))
      :evensong (:lesson1 ("Hag" 2 10)
                 :lesson2 ("Acts" 10))))

    ;;;; ── SUNDAYS AND WEEKDAYS AFTER TRINITY 1–6 ─────────────────────────────

    (after-trinity-1
     (sunday
      :mattins  (:lesson1 ("Isa" 6 1 8)
                 :lesson2 ("Acts" 9 1 22))
      :evensong (:lesson1 ("Isa" 40 12)
                 :lesson2 ("Acts" 17 16)))
     (monday
      :mattins  (:lesson1 ("Josh" 7)
                 :lesson2 ("Matt" 6 1 18))
      :evensong (:lesson1 ("Zech" 1 1 6)
                 :lesson2 ("Acts" 11)))
     (tuesday
      :mattins  (:lesson1 ("Josh" 8 1 21)            ; approx; VERIFY
                 :lesson2 ("Matt" 9 2 13))
      :evensong (:lesson1 ("Zech" 1 7 17)
                 :lesson2 ("Acts" 16 16)))            ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Josh" 9 1 21)            ; approx; VERIFY
                 :lesson2 ("Matt" 7 14))
      :evensong (:lesson1 ("Neh" 4 11)
                 :lesson2 ("Acts" 17)))
     (thursday
      :mattins  (:lesson1 ("Josh" 10 1 15)
                 :lesson2 ("Matt" 7 15))
      :evensong (:lesson1 ("Josh" 24)                ; VERIFY — "Josh 25" in source
                 :lesson2 ("Acts" 18 1 23)))          ; VERIFY
     (friday
      :mattins  (:lesson1 ("Josh" 11 1 19)           ; approx; VERIFY
                 :lesson2 ("Matt" 8 1 13))
      :evensong (:lesson1 (("Zech" 4 1) ("Zech" 5 1 4))
                 :lesson2 ("Acts" 18 24)))            ; approx 18:24–19:20; VERIFY
     (saturday
      :mattins  (:lesson1 ("Josh" 14)
                 :lesson2 ("Matt" 8 16))
      :evensong (:lesson1 ("Zech" 8)
                 :lesson2 ("Acts" 19 21))))

    (after-trinity-2
     (sunday
      :mattins  (:lesson1 ("Gen" 3)                  ; VERIFY
                 :lesson2 ("Rev" 3 7))
      :evensong (:lesson1 ("Exod" 20 1 17)           ; VERIFY
                 :lesson2 ("Mark" 12 28 34)))         ; VERIFY
     (monday
      :mattins  (:lesson1 ("Josh" 18 1 10)
                 :lesson2 ("Matt" 8 28))              ; approx 8:28–9:1
      :evensong (:lesson1 ("Matt" 11 20)
                 :lesson2 ("Acts" 20)))
     (tuesday
      :mattins  (:lesson1 ("Josh" 20 1 21)           ; approx; VERIFY
                 :lesson2 ("Matt" 9 2))
      :evensong (:lesson1 ("Zech" 9 9 16)            ; VERIFY
                 :lesson2 ("Acts" 21 1 26)))          ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Josh" 22 1 20)
                 :lesson2 ("Matt" 9 14))
      :evensong (:lesson1 ("Neh" 8 11)               ; VERIFY
                 :lesson2 ("Acts" 21 27)))            ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Josh" 23)
                 :lesson2 ("Matt" 9 18))
      :evensong (:lesson1 ("Zech" 10 15)             ; approx 10:15–11; VERIFY
                 :lesson2 ("Acts" 22 30)))            ; VERIFY
     (friday
      :mattins  (:lesson1 ("Josh" 24 1 28)
                 :lesson2 ("Matt" 9 35))
      :evensong (:lesson1 ("Neh" 8 13)               ; approx; VERIFY
                 :lesson2 ("Acts" 23)))               ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Josh" 24)
                 :lesson2 ("Matt" 10 16))
      :evensong (:lesson1 ("Zech" 14)                ; VERIFY
                 :lesson2 ("Acts" 24 1 26))))         ; VERIFY

    (after-trinity-3
     (sunday
      :mattins  (:lesson1 ("Gen" 4 2 10)             ; VERIFY
                 :lesson2 ("I Cor" 13))
      :evensong (:lesson1 ("Gen" 18 1 19)            ; approx 1-10,16-19; VERIFY
                 :lesson2 ("Acts" 26 1 19)))          ; approx; VERIFY
     (monday
      :mattins  (:lesson1 ("Judg" 1 16 28)           ; approx 1:16-28,2:1-5
                 :lesson2 ("Matt" 11 20))
      :evensong (:lesson1 ("Neh" 1)
                 :lesson2 ("Acts" 20)))
     (tuesday
      :mattins  (:lesson1 ("Judg" 2 8)
                 :lesson2 ("Matt" 12 1 21))
      :evensong (:lesson1 ("Neh" 2)
                 :lesson2 ("Acts" 21 1 16)))
     (wednesday
      :mattins  (:lesson1 ("Judg" 3 1 11)
                 :lesson2 ("Matt" 12 22 37))
      :evensong (:lesson1 ("Neh" 4 1 11)
                 :lesson2 ("Acts" 21 17)))
     (thursday
      :mattins  (:lesson1 ("Judg" 3 12)
                 :lesson2 ("Matt" 12 38))
      :evensong (:lesson1 ("Zech" 7)                 ; VERIFY
                 :lesson2 ("Acts" 21 37)))            ; approx 21:37–22:29; VERIFY
     (friday
      :mattins  (:lesson1 ("Judg" 4)
                 :lesson2 ("Matt" 13 1 23))
      :evensong (:lesson1 ("Neh" 5)                  ; VERIFY
                 :lesson2 ("Acts" 22 30)))            ; approx 22:30–23:end; VERIFY
     (saturday
      :mattins  (:lesson1 ("Judg" 5)
                 :lesson2 ("Matt" 13 24))
      :evensong (:lesson1 ("Neh" 6 1 16)
                 :lesson2 ("Acts" 24))))

    (after-trinity-4
     (sunday
      :mattins  (:lesson1 ("Deut" 10 12 17)          ; approx; VERIFY
                 :lesson2 ("Matt" 5 1 16))
      :evensong (:lesson1 ("Deut" 10 12 17)          ; VERIFY — L1=L3 in source
                 :lesson2 ("John" 8 21 36)))          ; VERIFY
     (monday
      :mattins  (:lesson1 ("Judg" 6 1 23)
                 :lesson2 ("Matt" 13 24))
      :evensong (:lesson1 ("Ezra" 7 1 10)
                 :lesson2 ("Acts" 25)))
     (tuesday
      :mattins  (:lesson1 ("Judg" 6 28)
                 :lesson2 ("Matt" 14 1 21))
      :evensong (:lesson1 ("Ezra" 8 15 32)           ; VERIFY
                 :lesson2 ("Acts" 26 1 23)))          ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Judg" 7 1 21)
                 :lesson2 ("Matt" 14 22))
      :evensong (:lesson1 ("Ezra" 9)                 ; VERIFY
                 :lesson2 ("Acts" 27 1 26)))          ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Judg" 8 1 21)
                 :lesson2 ("Matt" 15 1 20))
      :evensong (:lesson1 ("Neh" 8 1 12)             ; approx 1-12,17; VERIFY
                 :lesson2 ("John" 8 21 36)))          ; VERIFY
     (friday
      :mattins  (:lesson1 ("Judg" 8 22)
                 :lesson2 ("Matt" 15 21))
      :evensong (:lesson1 ("Neh" 8 13)               ; approx; VERIFY
                 :lesson2 ("Acts" 28 1 15)))          ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Judg" 9 1 21)
                 :lesson2 ("Matt" 15 29))
      :evensong (:lesson1 ("Neh" 9 6 16)             ; VERIFY
                 :lesson2 ("Acts" 28 16))))           ; VERIFY

    (after-trinity-5
     (sunday
      :mattins  (:lesson1 ("Gen" 41 1 49)            ; approx; VERIFY
                 :lesson2 ("Matt" 28 16))             ; VERIFY — "28:16-50" in source
      :evensong (:lesson1 ("Exod" 6 1 13)            ; VERIFY
                 :lesson2 ("Mark" 9 14)))             ; VERIFY
     (monday
      :mattins  (:lesson1 ("Judg" 9 22 40)           ; VERIFY
                 :lesson2 ("Matt" 16 1 20))
      :evensong (:lesson1 ("Neh" 9 26)               ; VERIFY
                 :lesson2 ("I Thess" 1)))             ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Judg" 9 41)              ; VERIFY
                 :lesson2 ("Matt" 17 1 13))
      :evensong (:lesson1 ("Neh" 9 34)               ; VERIFY
                 :lesson2 ("I Thess" 2)))             ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Judg" 10)                ; VERIFY
                 :lesson2 ("Matt" 17 14))
      :evensong (:lesson1 ("Neh" 10 28)              ; approx 10:28–11; VERIFY
                 :lesson2 ("I Thess" 3)))             ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Judg" 11 1 19)           ; approx; VERIFY
                 :lesson2 ("Matt" 18 1 20))
      :evensong (:lesson1 ("Neh" 13 1 17)            ; VERIFY
                 :lesson2 ("I Thess" 4 1 12)))        ; VERIFY
     (friday
      :mattins  (:lesson1 ("Judg" 11 28 33)          ; approx; VERIFY
                 :lesson2 ("Matt" 18 15))
      :evensong (:lesson1 ("Neh" 13 23)              ; VERIFY
                 :lesson2 ("I Thess" 5 14)))          ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Judg" 12)                ; VERIFY
                 :lesson2 ("Matt" 18 21))
      :evensong (:lesson1 ("Neh" 13)                 ; VERIFY
                 :lesson2 ("I Thess" 5))))            ; VERIFY

    (after-trinity-6
     (sunday
      :mattins  (:lesson1 ("Gen" 42)
                 :lesson2 (("Matt" 5 38) ("Matt" 6 1 15)))
      :evensong (:lesson1 ("Exod" 20 1 17)
                 :lesson2 ("Luke" 15 1 27)))
     (monday
      :mattins  (:lesson1 ("Judg" 13)
                 :lesson2 ("Matt" 19 16))
      :evensong (:lesson1 ("Esth" 1)
                 :lesson2 ("II Thess" 1)))
     (tuesday
      :mattins  (:lesson1 ("Judg" 14)
                 :lesson2 ("Matt" 20 1 16))
      :evensong (:lesson1 ("Esth" 2 1 11)            ; approx 2:1-11,16-end; VERIFY
                 :lesson2 ("II Thess" 2)))            ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Judg" 15)
                 :lesson2 ("Matt" 20 17))
      :evensong (:lesson1 ("Esth" 3)                 ; VERIFY
                 :lesson2 ("II Thess" 3 1 15)))       ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Judg" 16 2)
                 :lesson2 ("Matt" 21 1 22))
      :evensong (:lesson1 ("Esth" 4)                 ; VERIFY
                 :lesson2 ("Gal" 1)))                 ; VERIFY
     (friday
      :mattins  (:lesson1 ("Judg" 17 6)              ; approx; VERIFY
                 :lesson2 ("Matt" 21 18))
      :evensong (:lesson1 ("Esth" 13 8)              ; VERIFY
                 :lesson2 ("Gal" 2)))                 ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Judg" 18 13)
                 :lesson2 ("Matt" 21 33))
      :evensong (:lesson1 ("Esth" 14)                ; VERIFY
                 :lesson2 ("Gal" 3 1 15))))           ; VERIFY

    ;;;; ── SUNDAYS AFTER TRINITY 7–26 ────────────────────────────────────────

    (after-trinity-7
     (sunday
      :mattins  (:lesson1 ("Gen" 43)
                 :lesson2 ("Matt" 6 1))
      :evensong (:lesson1 ("Exod" 6 2 13)
                 :lesson2 ("Mark" 9 14 29)))
     (monday
      :mattins  (:lesson1 ("Ruth" 1)
                 :lesson2 ("Matt" 22 1 14))
      :evensong (:lesson1 ("Esth" 5)
                 :lesson2 ("Gal" 3 16)))
     (tuesday
      :mattins  (:lesson1 ("Ruth" 2)
                 :lesson2 ("Matt" 22 15 33))
      :evensong (:lesson1 ("Esth" 6 1 12)
                 :lesson2 ("Gal" 4 1 18)))
     (wednesday
      :mattins  (:lesson1 ("Ruth" 3)
                 :lesson2 ("Matt" 22 34))
      :evensong (:lesson1 (("Esth" 6 13) ("Esth" 7))
                 :lesson2 (("Gal" 4 19) ("Gal" 5 1 1))))
     (thursday
      :mattins  (:lesson1 ("Ruth" 4 1 17)
                 :lesson2 ("Matt" 23 1 12))
      :evensong (:lesson1 ("Esth" 8)
                 :lesson2 ("Gal" 5 2 15)))          ; VERIFY
     (friday
      :mattins  (:lesson1 ("I Sam" 1 1 20)
                 :lesson2 ("Matt" 23 13))
      :evensong (:lesson1 (("Esth" 9 20) ("Esth" 10))
                 :lesson2 ("Gal" 6 15)))             ; VERIFY
     (saturday
      :mattins  (:lesson1 (("I Sam" 1 21) ("I Sam" 2 1 21))
                 :lesson2 ("Matt" 23 27))
      :evensong (:lesson1 (("Esth" 9 20) ("Esth" 10)) ; VERIFY — possible duplicate
                 :lesson2 ("Gal" 6))))               ; VERIFY — possible duplicate

    (after-trinity-8
     (sunday
      :mattins  (:lesson1 (("Gen" 44 18) ("Gen" 45 1 15))
                 :lesson2 ("Matt" 7 8))
      :evensong (:lesson1 ("Gen" 18 20)
                 :lesson2 ("Luke" 11 5 13)))
     (monday
      :mattins  (:lesson1 ("I Sam" 2 26)
                 :lesson2 ("Matt" 24 1 28))
      :evensong (:lesson1 ("Zech" 9 9 16)
                 :lesson2 ("I Cor" 1)))
     (tuesday
      :mattins  (:lesson1 ("I Sam" 3)
                 :lesson2 ("Matt" 24 29))
      :evensong (:lesson1 ("Zech" 10)
                 :lesson2 ("I Cor" 2)))
     (wednesday
      :mattins  (:lesson1 ("I Sam" 4 1 18)
                 :lesson2 ("Matt" 25 1 30))
      :evensong (:lesson1 ("Zech" 11)                ; VERIFY — "Zech. 11, 13:7-end" approx
                 :lesson2 ("I Cor" 3)))
     (thursday
      :mattins  (:lesson1 ("I Sam" 5)
                 :lesson2 ("Matt" 25 31))
      :evensong (:lesson1 ("Zech" 12 1 8)
                 :lesson2 ("I Cor" 4 1 17)))
     (friday
      :mattins  (:lesson1 (("I Sam" 6 1) ("I Sam" 7 1 2))
                 :lesson2 ("Matt" 26 1 35))
      :evensong (:lesson1 ("Zech" 14)
                 :lesson2 (("I Cor" 4 18) ("I Cor" 5)))) ; VERIFY
     (saturday
      :mattins  (:lesson1 ("I Sam" 7 3)
                 :lesson2 ("Matt" 26 36))
      :evensong (:lesson1 ("Zech" 14)                ; VERIFY — possible duplicate
                 :lesson2 ("I Cor" 6))))             ; VERIFY

    (after-trinity-9
     (sunday
      :mattins  (:lesson1 ("Exod" 32 1 24)
                 :lesson2 ("John" 4 1 30))
      :evensong (:lesson1 ("Acts" 27 14)
                 :lesson2 ("I Cor" 10 7 14)))
     (monday
      :mattins  (:lesson1 ("I Sam" 8)
                 :lesson2 ("Matt" 26 36))
      :evensong (:lesson1 ("Mal" 1)
                 :lesson2 ("I Cor" 7 10 35)))        ; VERIFY
     (tuesday
      :mattins  (:lesson1 (("I Sam" 9 1) ("I Sam" 10 1 1))
                 :lesson2 ("Matt" 26 57))
      :evensong (:lesson1 ("Mal" 2 1 9)
                 :lesson2 ("I Cor" 8)))              ; VERIFY
     (wednesday
      :mattins  (:lesson1 (("I Sam" 10 17) ("I Sam" 11 1 13))
                 :lesson2 ("Matt" 27 1 26))
      :evensong (:lesson1 ("Mal" 2 10)
                 :lesson2 ("I Cor" 9)))              ; VERIFY
     (thursday
      :mattins  (:lesson1 (("I Sam" 11 14) ("I Sam" 12))
                 :lesson2 ("Matt" 27 27 56))
      :evensong (:lesson1 ("Mal" 3 7 12)
                 :lesson2 ("I Cor" 10 1 22)))        ; VERIFY
     (friday
      :mattins  (:lesson1 ("I Sam" 13)
                 :lesson2 ("Matt" 27 57))
      :evensong (:lesson1 (("Mal" 3 13) ("Mal" 4))
                 :lesson2 ("I Cor" 11 17)))          ; VERIFY
     (saturday
      :mattins  (:lesson1 ("I Sam" 14 1 23)          ; approx — "14:1-23, 28-48"
                 :lesson2 ("Matt" 28))
      :evensong (:lesson1 (("Mal" 3 13) ("Mal" 4))   ; VERIFY — possible duplicate
                 :lesson2 ("I Cor" 12 1 26))))       ; VERIFY

    (after-trinity-10
     (sunday
      :mattins  (:lesson1 ("Judg" 5)
                 :lesson2 ("Rom" 12 9))
      :evensong (:lesson1 ("Josh" 24 14 28)
                 :lesson2 ("Luke" 9 46)))
     (monday
      :mattins  (:lesson1 ("I Sam" 15)
                 :lesson2 ("Luke" 3 1 22))
      :evensong (:lesson1 ("Dan" 2 1 24)
                 :lesson2 ("I Cor" 12 27)))          ; VERIFY — "12:27-13:end"
     (tuesday
      :mattins  (:lesson1 ("I Sam" 16)
                 :lesson2 ("Luke" 4 1 13))
      :evensong (:lesson1 ("Dan" 2 25)
                 :lesson2 ("I Cor" 14 1 20)))        ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("I Sam" 17 1 30)
                 :lesson2 ("Luke" 4 32))
      :evensong (:lesson1 ("Dan" 7)
                 :lesson2 ("I Cor" 14 20)))          ; VERIFY
     (thursday
      :mattins  (:lesson1 ("I Sam" 17 31 53)
                 :lesson2 ("Luke" 4 33))
      :evensong (:lesson1 ("Dan" 8)
                 :lesson2 ("I Cor" 15 1 28)))        ; VERIFY
     (friday
      :mattins  (:lesson1 ("I Sam" 18)
                 :lesson2 ("Luke" 5 1 16))
      :evensong (:lesson1 ("Dan" 9)
                 :lesson2 ("I Cor" 15 29)))          ; VERIFY
     (saturday
      :mattins  (:lesson1 ("I Sam" 18 10 21)
                 :lesson2 ("Luke" 5 17))
      :evensong (:lesson1 ("Dan" 10)
                 :lesson2 ("I Cor" 16))))            ; VERIFY

    (after-trinity-11
     (sunday
      :mattins  (:lesson1 ("I Sam" 16)
                 :lesson2 (("Mark" 4 35) ("Mark" 5 1 20)))
      :evensong (:lesson1 ("Gen" 24 1 38)            ; VERIFY — approx "24:1-38, 50-51"
                 :lesson2 ("Acts" 26 1 19)))         ; VERIFY — approx "26:1-2, 8-19"
     (monday
      :mattins  (:lesson1 ("I Sam" 19 1 18)
                 :lesson2 ("Luke" 6 1 19))
      :evensong (:lesson1 ("Esth" 1)
                 :lesson2 ("II Cor" 1 1 22)))        ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("I Sam" 20 1 21)          ; VERIFY — approx "20:1-21, 3"
                 :lesson2 ("Luke" 6 20))
      :evensong (:lesson1 ("I Macc" 1 1 28)
                 :lesson2 (("II Cor" 1 23) ("II Cor" 2)))) ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("I Sam" 20 24)
                 :lesson2 ("Luke" 7 1 16))
      :evensong (:lesson1 ("Ezra" 9)
                 :lesson2 (("II Cor" 3 1) ("II Cor" 4 1 6)))) ; VERIFY
     (thursday
      :mattins  (:lesson1 (("I Sam" 21 1) ("I Sam" 22 1 2))
                 :lesson2 ("Luke" 7 17))
      :evensong (:lesson1 ("I Macc" 2 1 30)
                 :lesson2 ("II Cor" 4 7)))           ; VERIFY
     (friday
      :mattins  (:lesson1 (("I Sam" 22 6) ("I Sam" 23 1 1))
                 :lesson2 ("Luke" 7 36))
      :evensong (:lesson1 ("I Macc" 2 31)
                 :lesson2 ("II Cor" 5 5)))           ; VERIFY
     (saturday
      :mattins  (:lesson1 ("I Sam" 23 14)
                 :lesson2 ("Luke" 8 1 21))
      :evensong (:lesson1 ("I Macc" 2 42)
                 :lesson2 (("II Cor" 6 1) ("II Cor" 7 1 1))))) ; VERIFY

    (after-trinity-12
     (sunday
      :mattins  (:lesson1 ("I Sam" 20 11)
                 :lesson2 ("Mark" 7 31))
      :evensong (:lesson1 ("II Sam" 9)
                 :lesson2 ("Acts" 16 16)))           ; VERIFY
     (monday
      :mattins  (:lesson1 ("I Sam" 24)
                 :lesson2 ("Luke" 8 22))
      :evensong (:lesson1 ("I Macc" 3 1 26)
                 :lesson2 (("II Cor" 7 2) ("II Cor" 8)))) ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("I Sam" 25 1 35)
                 :lesson2 ("Luke" 9 1 17))
      :evensong (:lesson1 ("I Macc" 3 27)
                 :lesson2 ("II Cor" 9)))             ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("I Sam" 25 36)
                 :lesson2 ("Luke" 9 18))
      :evensong (:lesson1 ("I Macc" 4 1 25)
                 :lesson2 ("II Cor" 10)))            ; VERIFY
     (thursday
      :mattins  (:lesson1 ("I Sam" 26)
                 :lesson2 ("Luke" 9 28))
      :evensong (:lesson1 ("I Macc" 4 26)
                 :lesson2 ("II Cor" 11)))            ; VERIFY
     (friday
      :mattins  (:lesson1 (("I Sam" 27 1) ("I Sam" 28 1 2))
                 :lesson2 ("Luke" 10 1 24))
      :evensong (:lesson1 ("I Macc" 4 36)
                 :lesson2 ("II Cor" 12)))            ; VERIFY
     (saturday
      :mattins  (:lesson1 ("I Sam" 28 3)
                 :lesson2 ("Luke" 10 25))
      :evensong (:lesson1 ("I Macc" 4 19)           ; VERIFY — "4:19-10:end" ref garbled
                 :lesson2 ("II Cor" 13))))           ; VERIFY

    (after-trinity-13
     (sunday
      :mattins  (:lesson1 ("I Sam" 24)
                 :lesson2 ("Matt" 5 17 26))
      :evensong (:lesson1 ("Exod" 18 13)
                 :lesson2 ("Acts" 20 17)))           ; VERIFY
     (monday
      :mattins  (:lesson1 ("I Sam" 29)
                 :lesson2 ("Luke" 10 25))
      :evensong (:lesson1 ("Deut" 4 1 20)
                 :lesson2 ("Rom" 1 1 25)))           ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("I Sam" 30 1 25)
                 :lesson2 ("Luke" 10 38))
      :evensong (:lesson1 ("Deut" 5 1 22)
                 :lesson2 ("Rom" 2)))                ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("I Sam" 31)
                 :lesson2 ("Luke" 11 1))
      :evensong (:lesson1 ("Deut" 5 23)
                 :lesson2 ("Rom" 3)))                ; VERIFY
     (thursday
      :mattins  (:lesson1 ("II Sam" 1 1)
                 :lesson2 ("Luke" 11 14))
      :evensong (:lesson1 ("Deut" 6)
                 :lesson2 ("Rom" 4)))                ; VERIFY
     (friday
      :mattins  (:lesson1 (("II Sam" 1 17) ("II Sam" 2 1 7))
                 :lesson2 ("Luke" 11 29))
      :evensong (:lesson1 ("Deut" 7 12)
                 :lesson2 ("Rom" 5)))                ; VERIFY
     (saturday
      :mattins  (:lesson1 ("II Sam" 2 8)
                 :lesson2 ("Luke" 12 1 12))
      :evensong (:lesson1 ("Deut" 7 1 11)           ; VERIFY — "7:v.1-11"
                 :lesson2 ("Rom" 6 1 13))))          ; VERIFY

    (after-trinity-14
     (sunday
      :mattins  (:lesson1 ("II Sam" 23 5 17)
                 :lesson2 ("Matt" 26 1 13))
      :evensong (:lesson1 (:multiple ("II Kgs" 22 10 18) ("II Kgs" 22 29 37))
                 :lesson2 ("Matt" 11 2 19)))         ; VERIFY
     (monday
      :mattins  (:lesson1 ("II Sam" 2 12)
                 :lesson2 ("Luke" 12 13))
      :evensong (:lesson1 ("Deut" 7 12)
                 :lesson2 ("Rom" 7)))                ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("II Sam" 3 1 17)          ; VERIFY — "3:1-17, end" approx
                 :lesson2 ("Luke" 12 35))
      :evensong (:lesson1 ("Deut" 8)
                 :lesson2 ("Rom" 8 1 17)))           ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("II Sam" 4)
                 :lesson2 ("Luke" 12 49))
      :evensong (:lesson1 (("Deut" 10 12) ("Deut" 11 1 1))
                 :lesson2 ("Rom" 8 18)))             ; VERIFY
     (thursday
      :mattins  (:lesson1 ("II Sam" 5 1 12)          ; VERIFY — "5:1-12, 17" approx
                 :lesson2 ("Luke" 13 1))
      :evensong (:lesson1 ("Deut" 11 13)
                 :lesson2 ("Rom" 9 1)))              ; VERIFY
     (friday
      :mattins  (:lesson1 ("II Sam" 6 1 19)
                 :lesson2 ("Luke" 13 18))
      :evensong (:lesson1 ("Deut" 11 29)
                 :lesson2 ("Rom" 9 19)))             ; VERIFY
     (saturday
      :mattins  (:lesson1 ("II Sam" 7)
                 :lesson2 ("Luke" 14 1 24))
      :evensong (:lesson1 ("Deut" 28 1 14)
                 :lesson2 ("Rom" 10))))              ; VERIFY

    (after-trinity-15
     (sunday
      :mattins  (:lesson1 ("I Kgs" 3 5)
                 :lesson2 ("Matt" 10 26))
      :evensong (:lesson1 ("I Kgs" 20 28)
                 :lesson2 ("Mark" 9 33)))            ; VERIFY
     (monday
      :mattins  (:lesson1 ("II Sam" 8 1 15)
                 :lesson2 ("Luke" 14 25))
      :evensong (:lesson1 ("Deut" 12 17)
                 :lesson2 ("Rom" 11)))               ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("II Sam" 9)
                 :lesson2 ("Luke" 14 25))
      :evensong (:lesson1 ("Deut" 14 22)
                 :lesson2 ("Rom" 12)))               ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("II Sam" 10)
                 :lesson2 ("Luke" 15 1))
      :evensong (:lesson1 ("Deut" 15 1)
                 :lesson2 ("Rom" 13)))               ; VERIFY
     (thursday
      :mattins  (:lesson1 ("II Sam" 11 12)
                 :lesson2 ("Luke" 15 11))
      :evensong (:lesson1 ("Deut" 16 1)
                 :lesson2 ("Rom" 14)))               ; VERIFY
     (friday
      :mattins  (:lesson1 ("II Sam" 12 1 25)
                 :lesson2 ("Luke" 16 1))
      :evensong (:lesson1 ("Deut" 17 8)
                 :lesson2 ("Rom" 15)))               ; VERIFY
     (saturday
      :mattins  (:lesson1 ("II Sam" 13 23)
                 :lesson2 ("Luke" 16 19))
      :evensong (:lesson1 ("Deut" 19 1)
                 :lesson2 ("Rom" 16 1 5))))          ; VERIFY — approx "16:1-5, 17-end"

    (after-trinity-16
     (sunday
      :mattins  (:lesson1 ("Dan" 5 1 9)              ; VERIFY — approx "5:1-9, 13-20"
                 :lesson2 ("Luke" 12 13 21))
      :evensong (:lesson1 ("Gen" 32 24 30)
                 :lesson2 ("Eph" 6 10 20)))          ; VERIFY
     (monday
      :mattins  (:lesson1 ("II Sam" 14 1 20)
                 :lesson2 ("Luke" 17 1))
      :evensong (:lesson1 ("Deut" 21 15)
                 :lesson2 ("Eph" 1)))                ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("II Sam" 14 21)
                 :lesson2 ("Luke" 17 11))
      :evensong (:lesson1 ("Deut" 24 19)
                 :lesson2 ("Eph" 2)))                ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("II Sam" 15 1 12)
                 :lesson2 ("Luke" 17 20))
      :evensong (:lesson1 ("Deut" 26 1 9)
                 :lesson2 ("Eph" 3)))                ; VERIFY
     (thursday
      :mattins  (:lesson1 ("II Sam" 15 13 17)        ; VERIFY — approx "15:v.13-17, 22"
                 :lesson2 ("Luke" 18 1))
      :evensong (:lesson1 ("Deut" 27 10)
                 :lesson2 ("Eph" 4 1 25)))           ; VERIFY
     (friday
      :mattins  (:lesson1 ("II Sam" 16 1 19)
                 :lesson2 ("Luke" 18 15))
      :evensong (:lesson1 ("Deut" 28 1 14)
                 :lesson2 (("Eph" 4 25) ("Eph" 5 1 14)))) ; VERIFY
     (saturday
      :mattins  (:lesson1 ("II Sam" 16 1 19)         ; VERIFY — possible duplicate of Fri
                 :lesson2 ("Luke" 18 31))
      :evensong (:lesson1 ("Deut" 28 1 14)           ; VERIFY — possible duplicate
                 :lesson2 (("Eph" 5 15) ("Eph" 6 1 9))))) ; VERIFY

    (after-trinity-17
     (sunday
      :mattins  (:lesson1 ("Dan" 6 1 23)
                 :lesson2 ("Rom" 8 14 18))           ; VERIFY — approx "8:14-18, 31-end"
      :evensong (:lesson1 ("Ruth" 2)
                 :lesson2 ("John" 8)))               ; VERIFY — ref incomplete
     (monday
      :mattins  (:lesson1 ("II Sam" 17 1 14)
                 :lesson2 ("Luke" 19 1 10))
      :evensong (:lesson1 ("Deut" 29)
                 :lesson2 ("Eph" 6 10)))             ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("II Sam" 17 15)
                 :lesson2 ("Luke" 19 11))
      :evensong (:lesson1 ("Deut" 30)
                 :lesson2 ("John" 8)))               ; VERIFY — ref incomplete
     (wednesday
      :mattins  (:lesson1 ("II Sam" 18 1 17)
                 :lesson2 ("Luke" 19 20))
      :evensong (:lesson1 ("Deut" 31)
                 :lesson2 ("John" 8 12)))            ; VERIFY
     (thursday
      :mattins  (:lesson1 ("II Sam" 18 19)           ; VERIFY — approx "18:v.19-19:8, 15"
                 :lesson2 ("Luke" 20 1 26))
      :evensong (:lesson1 ("Deut" 32 1 14)
                 :lesson2 nil))                      ; VERIFY — ref illegible
     (friday
      :mattins  (:lesson1 ("II Sam" 19 1 14)
                 :lesson2 ("Luke" 20 27))
      :evensong (:lesson1 ("Deut" 33)
                 :lesson2 nil))                      ; VERIFY — ref illegible
     (saturday
      :mattins  (:lesson1 ("II Sam" 19 15 23)
                 :lesson2 ("Luke" 21 1))
      :evensong (:lesson1 nil                        ; VERIFY — illegible
                 :lesson2 nil)))                     ; VERIFY — illegible

    (after-trinity-18
     (sunday
      :mattins  (:lesson1 ("Eccl" 12)
                 :lesson2 ("Luke" 2 41))
      :evensong (:lesson1 ("Exod" 34 27)
                 :lesson2 (("I John" 2 24) ("I John" 3 1 2)))) ; VERIFY
     (monday
      :mattins  (:lesson1 (("II Sam" 19 31) ("II Sam" 20 1 2))
                 :lesson2 ("Luke" 21 5))
      :evensong (:lesson1 ("Phil" 1 1 11)
                 :lesson2 ("Phil" 1)))               ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("II Sam" 20 4 22)
                 :lesson2 ("Luke" 21 25))
      :evensong (:lesson1 ("Phil" 2 12)
                 :lesson2 ("Phil" 2)))               ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("II Sam" 21 1 14)
                 :lesson2 ("Luke" 22 1 13))          ; VERIFY — approx "22:1-13, 38"
      :evensong (:lesson1 ("Phil" 2 14)
                 :lesson2 ("Phil" 3)))               ; VERIFY
     (thursday
      :mattins  (:lesson1 ("II Sam" 22 1 7)
                 :lesson2 ("Luke" 22 39))
      :evensong (:lesson1 ("Phil" 3 2)
                 :lesson2 ("Phil" 4 14)))            ; VERIFY
     (friday
      :mattins  (:lesson1 ("II Sam" 23 8 23)
                 :lesson2 ("Luke" 23 1))
      :evensong (:lesson1 ("Phil" 4 1)
                 :lesson2 ("Phil" 4)))               ; VERIFY
     (saturday
      :mattins  (:lesson1 (("II Sam" 23 24) ("II Sam" 24 1 17))
                 :lesson2 ("Luke" 24 1))
      :evensong (:lesson1 ("Lev" 26 1 12)
                 :lesson2 ("Phlm"))))                ; VERIFY

    (after-trinity-19
     (sunday
      :mattins  (:lesson1 ("II Kgs" 5)
                 :lesson2 ("John" 13 1 15))
      :evensong (:lesson1 ("II Kgs" 19 14 34)        ; VERIFY — "19:14-34, 50-end" ref garbled
                 :lesson2 ("Acts" 20 17)))           ; VERIFY
     (monday
      :mattins  (:lesson1 (("I Chron" 21 18) ("I Chron" 22 1 4))
                 :lesson2 ("Luke" 23 26))
      :evensong (:lesson1 ("Job" 8)
                 :lesson2 ("I Tim" 1)))              ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("I Chron" 22 5)
                 :lesson2 ("Luke" 23 46))
      :evensong (:lesson1 ("Job" 9)
                 :lesson2 ("I Tim" 2)))              ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("I Kgs" 1 5 21)
                 :lesson2 ("Luke" 24 1))
      :evensong (:lesson1 ("Job" 11)
                 :lesson2 ("I Tim" 3)))              ; VERIFY
     (thursday
      :mattins  (:lesson1 ("I Kgs" 1 25)
                 :lesson2 ("Luke" 24 13))
      :evensong (:lesson1 ("Job" 12 1 24)
                 :lesson2 ("I Tim" 4)))              ; VERIFY
     (friday
      :mattins  (:lesson1 ("I Kgs" 1 38)
                 :lesson2 ("Luke" 24 36))
      :evensong (:lesson1 ("Job" 13 15 25)
                 :lesson2 ("I Tim" 5)))              ; VERIFY
     (saturday
      :mattins  (:lesson1 ("I Kgs" 2 1 6)            ; VERIFY — approx "2:1-6, 10-end"
                 :lesson2 ("Luke" 24 36))            ; VERIFY — possible duplicate
      :evensong (:lesson1 ("Job" 16)
                 :lesson2 ("I Tim" 6))))             ; VERIFY

    (after-trinity-20
     (sunday
      :mattins  (:lesson1 ("II Kgs" 6 8 17)
                 :lesson2 ("John" 9 1 38))
      :evensong (:lesson1 ("Micah" 4 1 7)
                 :lesson2 ("Jas" 3)))                ; VERIFY
     (monday
      :mattins  (:lesson1 ("I Chron" 28 1 10)
                 :lesson2 ("John" 1 1 18))
      :evensong (:lesson1 ("Job" 18)
                 :lesson2 (("Tit" 1 1) ("Tit" 2 1 10)))) ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("I Chron" 29 1 19)
                 :lesson2 ("John" 1 19))
      :evensong (:lesson1 ("Job" 19 27)              ; VERIFY — "19:v.27a"
                 :lesson2 (("Tit" 2 11) ("Tit" 3)))) ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("I Chron" 29 20)
                 :lesson2 ("John" 1 35))
      :evensong (:lesson1 ("Job" 20)
                 :lesson2 ("II Tim" 1)))             ; VERIFY
     (thursday
      :mattins  (:lesson1 ("I Kgs" 2 1 4)            ; VERIFY — approx "2:1-4, 10-27"
                 :lesson2 ("John" 2 1 12))
      :evensong (:lesson1 ("Job" 21)
                 :lesson2 ("II Tim" 2)))             ; VERIFY
     (friday
      :mattins  (:lesson1 ("I Kgs" 2 28)
                 :lesson2 ("John" 2 13))
      :evensong (:lesson1 (("Job" 23 1) ("Job" 24 1 1))
                 :lesson2 ("II Tim" 3)))             ; VERIFY
     (saturday
      :mattins  (:lesson1 ("I Kgs" 3 1 21)
                 :lesson2 ("John" 3 1))
      :evensong (:lesson1 (("Job" 23 1) ("Job" 24 1 1)) ; VERIFY — possible duplicate
                 :lesson2 ("II Tim" 4))))            ; VERIFY

    (after-trinity-21
     (sunday
      :mattins  (:lesson1 ("Wis" 3 1 9)
                 :lesson2 ("Rev" 21 1 7))            ; VERIFY — approx "21:v.1-7, 10-11a, 22-end"
      :evensong (:lesson1 ("I Kgs" 19 1 18)
                 :lesson2 ("Matt" 11 16)))           ; VERIFY — L1 ref garbled in source
     (monday
      :mattins  (:lesson1 ("I Kgs" 3 15)
                 :lesson2 ("John" 3 22))
      :evensong (:lesson1 (("Job" 25) ("Job" 26))
                 :lesson2 ("Jas" 1 1 15)))           ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("I Kgs" 3 16)
                 :lesson2 ("John" 4 1 26))
      :evensong (:lesson1 ("Job" 28)
                 :lesson2 ("Jas" 1 16)))             ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("I Kgs" 4 21)
                 :lesson2 ("John" 4 27))
      :evensong (:lesson1 (("Job" 29 1) ("Job" 30 1 1))
                 :lesson2 ("Jas" 2)))                ; VERIFY
     (thursday
      :mattins  (:lesson1 ("I Kgs" 5 1 12)
                 :lesson2 ("John" 4 43))
      :evensong (:lesson1 ("Job" 31)
                 :lesson2 ("Jas" 3)))                ; VERIFY
     (friday
      :mattins  (:lesson1 ("I Kgs" 5 13)             ; VERIFY — approx "5:13-6:1, 11-14"
                 :lesson2 ("John" 5 1 24))
      :evensong (:lesson1 ("Job" 32)
                 :lesson2 ("Jas" 4)))                ; VERIFY
     (saturday
      :mattins  (:lesson1 (("I Kgs" 6 37) ("I Kgs" 7 1 14))
                 :lesson2 ("John" 5 25))
      :evensong (:lesson1 ("Job" 33)
                 :lesson2 ("Jas" 5 14))))            ; VERIFY

    (after-trinity-22
     (sunday
      :mattins  (:lesson1 ("Ecclus" 44 1 14)
                 :lesson2 ("Heb" 11 1 3))            ; VERIFY — approx "11:1-3, 17"
      :evensong (:lesson1 ("Isa" 1 10 20)
                 :lesson2 (("Luke" 5 36) ("Luke" 6 1 10)))) ; VERIFY
     (monday
      :mattins  (:lesson1 ("I Kgs" 8 1 21)
                 :lesson2 ("John" 6 1 21))
      :evensong (:lesson1 ("Job" 34)
                 :lesson2 ("I Pet" 1 1 28)))         ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("I Kgs" 8 22 53)
                 :lesson2 ("John" 6 22))
      :evensong (:lesson1 ("Job" 36 5 25)            ; VERIFY — "36:v.5-25" (may be 36:25-37:end)
                 :lesson2 ("I Pet" 2 11)))           ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("I Kgs" 8 54)
                 :lesson2 ("John" 6 51))
      :evensong (:lesson1 ("Job" 38 1 36)
                 :lesson2 ("I Pet" 3 8)))            ; VERIFY
     (thursday
      :mattins  (:lesson1 ("I Kgs" 9 1 10)
                 :lesson2 ("John" 7 1 31))
      :evensong (:lesson1 ("Job" 40)
                 :lesson2 ("I Pet" 4 1)))            ; VERIFY
     (friday
      :mattins  (:lesson1 ("I Kgs" 9 10)
                 :lesson2 ("John" 7 31))
      :evensong (:lesson1 ("Job" 42)
                 :lesson2 ("I Pet" 5 1)))            ; VERIFY
     (saturday
      :mattins  (:lesson1 ("I Kgs" 10 1 15)          ; VERIFY — approx "10:1-15, 21-24"
                 :lesson2 ("John" 8 1 11))
      :evensong (:lesson1 (("Eccl" 1) ("Eccl" 2))
                 :lesson2 ("I Cor" 12 1 26))))       ; VERIFY

    (after-trinity-23
     (sunday
      :mattins  (:lesson1 ("Job" 1 1 21)
                 :lesson2 ("II Cor" 11 18 30))
      :evensong (:lesson1 ("Exod" 33 7 19)
                 :lesson2 ("Heb" 1 1 12)))           ; VERIFY
     (monday
      :mattins  (:lesson1 ("Prov" 1 19)
                 :lesson2 ("John" 8 12))
      :evensong (:lesson1 ("Ecclus" 1 20)
                 :lesson2 (("Heb" 1 3) ("Heb" 2 1 13)))) ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Prov" 1 20)
                 :lesson2 ("John" 8 31))
      :evensong (:lesson1 (("Ecclus" 1 21) ("Ecclus" 2))
                 :lesson2 (("Heb" 2 14) ("Heb" 3 1 11)))) ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Prov" 2)
                 :lesson2 ("John" 9))
      :evensong (:lesson1 ("Ecclus" 3 1 15)
                 :lesson2 (("Heb" 3 12) ("Heb" 4 1 13)))) ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Prov" 3 1 12)
                 :lesson2 ("John" 10 21))
      :evensong (:lesson1 ("Ecclus" 4 1 19)
                 :lesson2 (("Heb" 4 14) ("Heb" 5)))) ; VERIFY
     (friday
      :mattins  (:lesson1 ("Prov" 3 15 26)
                 :lesson2 ("John" 10 22))
      :evensong (:lesson1 ("Ecclus" 6 18)
                 :lesson2 ("Heb" 6)))                ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Prov" 4 1 13)
                 :lesson2 ("John" 11 1 16))
      :evensong (:lesson1 ("Ecclus" 6 18)            ; VERIFY — possible duplicate
                 :lesson2 ("Heb" 7 1 17))))          ; VERIFY

    (after-trinity-24
     (sunday
      :mattins  (:lesson1 ("Isa" 51 7)
                 :lesson2 ("Luke" 8 4 15))
      :evensong (:lesson1 nil                        ; VERIFY — "Sam. 28:v.7-20" ref garbled
                 :lesson2 ("Matt" 11 2 19)))         ; VERIFY
     (monday
      :mattins  (:lesson1 ("Prov" 4 14)
                 :lesson2 ("John" 11 17))
      :evensong (:lesson1 ("Ecclus" 7 1 18)
                 :lesson2 ("Heb" 7 18)))             ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Prov" 5 1 18)
                 :lesson2 ("John" 11 45))
      :evensong (:lesson1 (("Ecclus" 9 15) ("Ecclus" 10 1 8))
                 :lesson2 (("Heb" 8 1) ("Heb" 9 1 12)))) ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Prov" 6 1 23)
                 :lesson2 ("John" 12 1 19))
      :evensong (:lesson1 ("Ecclus" 10 12 24)        ; VERIFY — "10:v.12-24" (may be 10:12-15, 20-24)
                 :lesson2 (("Heb" 8 13) ("Heb" 9))))  ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Prov" 8 1 21)
                 :lesson2 ("John" 12 20))
      :evensong (:lesson1 (("Ecclus" 14 20) ("Ecclus" 15))
                 :lesson2 ("Heb" 9 11)))             ; VERIFY
     (friday
      :mattins  (:lesson1 ("Prov" 8 22)
                 :lesson2 ("John" 13 1))
      :evensong (:lesson1 ("Ecclus" 24 1 22)
                 :lesson2 ("Heb" 10 1 18)))          ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Prov" 9 1 12)
                 :lesson2 ("John" 13 20))
      :evensong (:lesson1 ("Ecclus" 26 1 6)          ; VERIFY — approx "26:1-6, 13-21"
                 :lesson2 ("Heb" 10 19 37))))        ; VERIFY

    ; Sunday: use omitted Epiphany lessons (per rubric)
    (after-trinity-25
     (monday
      :mattins  (:lesson1 ("Prov" 22 17)
                 :lesson2 ("John" 14 1 14))
      :evensong (:lesson1 ("Ecclus" 28 1 11)
                 :lesson2 (("Heb" 10 38) ("Heb" 11 1 16)))) ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Prov" 23 19 26)          ; VERIFY — approx "23:19-26, 29-32"
                 :lesson2 ("John" 14 15))
      :evensong (:lesson1 ("Ecclus" 29 1 13)
                 :lesson2 ("Heb" 11 16 31)))         ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Prov" 24 1 12)
                 :lesson2 ("John" 15 1 16))
      :evensong (:lesson1 ("Ecclus" 35)
                 :lesson2 (("Heb" 11 32) ("Heb" 12 1 2)))) ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Prov" 24 15 22)
                 :lesson2 (("John" 15 17) ("John" 16 1 11)))
      :evensong (:lesson1 nil                        ; VERIFY — illegible
                 :lesson2 ("Heb" 12 1 13)))          ; VERIFY
     (friday
      :mattins  (:lesson1 ("Prov" 24 23)
                 :lesson2 ("John" 16 12))
      :evensong (:lesson1 ("Eccl" 2)
                 :lesson2 ("Heb" 12 14)))            ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Prov" 25 1 13)           ; VERIFY — approx "25:1-13, 21-22"
                 :lesson2 ("John" 17))
      :evensong (:lesson1 ("Eccl" 3)
                 :lesson2 ("Heb" 13))))              ; VERIFY

    ; Sunday: use omitted Epiphany lessons (per rubric)
    (after-trinity-26
     (monday
      :mattins  (:lesson1 ("Prov" 26 1 16)
                 :lesson2 ("John" 18 1 27))
      :evensong (:lesson1 ("Eccl" 5)
                 :lesson2 (("I John" 1 1) ("I John" 2 1 6)))) ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Prov" 27 1 12)           ; VERIFY — approx "27:1-12, 23-end"
                 :lesson2 (("John" 18 28) ("John" 19 1 16)))
      :evensong (:lesson1 (("Eccl" 6 1) ("Eccl" 7 1 8))
                 :lesson2 ("I John" 2 7 17)))        ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Prov" 28 1 16)
                 :lesson2 ("John" 19 17))
      :evensong (:lesson1 ("Eccl" 8 1 15)
                 :lesson2 ("I John" 2 18)))          ; VERIFY
     (thursday
      :mattins  (:lesson1 ("Prov" 29 2 18)
                 :lesson2 ("John" 20 1 18))
      :evensong (:lesson1 (("Eccl" 8 16) ("Eccl" 9))
                 :lesson2 ("I John" 3)))             ; VERIFY
     (friday
      :mattins  (:lesson1 ("Prov" 30 1 9)            ; VERIFY — approx "30:1-9, 24-32"
                 :lesson2 ("John" 20 19))
      :evensong (:lesson1 ("Eccl" 11)
                 :lesson2 ("I John" 4)))             ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Prov" 31 10)
                 :lesson2 nil)                       ; VERIFY — illegible
      :evensong (:lesson1 ("Eccl" 12)
                 :lesson2 ("I John" 5))))            ; VERIFY

    (sunday-before-advent
     (sunday
      :mattins  (:lesson1 ("II Kgs" 19 14 36)
                 :lesson2 ("Matt" 6 19))
      :evensong (:lesson1 ("Micah" 6 5 8)
                 :lesson2 ("Jas" 1 12)))             ; VERIFY
     (monday
      :mattins  (:lesson1 (("Ecclus" 44 1) ("Ecclus" 45 1 5))
                 :lesson2 ("Rev" 1 1 8))
      :evensong (:lesson1 ("II Esd" 3 4 27)
                 :lesson2 ("II John")))              ; VERIFY
     (tuesday
      :mattins  (:lesson1 ("Ecclus" 44 16)           ; VERIFY — "44:16-45:5" approx
                 :lesson2 ("Rev" 1 9))
      :evensong (:lesson1 ("II Esd" 4 8 16)          ; VERIFY — two entries may be merged
                 :lesson2 ("III John")))             ; VERIFY
     (wednesday
      :mattins  (:lesson1 ("Ecclus" 46)
                 :lesson2 ("Rev" 2 1 11))
      :evensong (:lesson1 ("II Esd" 4 8 16)
                 :lesson2 ("Jude")))                 ; VERIFY
     ; Thursday omitted — liturgical year ends
     (friday
      :mattins  (:lesson1 ("Ecclus" 47 11)
                 :lesson2 ("Rev" 3 1 13))
      :evensong (:lesson1 ("II Esd" 7 12)
                 :lesson2 ("II Pet" 1)))             ; VERIFY
     (saturday
      :mattins  (:lesson1 ("Ecclus" 47 12)
                 :lesson2 ("Rev" 3 14))
      :evensong (:lesson1 ("II Esd" 16 54 67)
                 :lesson2 ("II Pet" 2))))            ; VERIFY

    ) ; end bcp-1928-lesson-table
  "Lesson table for the 1928 American BCP Daily Office.
See file commentary for reference format and verification notes.")

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Fixed Holy Day lessons (Christmas octave + Saints' days)
;;;; ══════════════════════════════════════════════════════════════════════════

(defconst bcp-1928-holy-day-lessons
  '(

    ;;;; ── CHRISTMAS OCTAVE (no Vespers I listed) ─────────────────────────────

    (christmas
     (day
      :mattins  (:lesson1 ("Isa" 9 2 7)
                 :lesson2 ("Luke" 2 1 20))
      :evensong (:lesson1 ("Isa" 7 10 16)
                 :lesson2 (("Titus" 2 11) ("Titus" 3 1 7)))))

    (st-stephen
     (day
      :mattins  (:lesson1 ("II Chr" 24 15 25)
                 :lesson2 ("Acts" 6))
      :evensong (:lesson1 ("Wis" 4 7 15)
                 :lesson2 (("Acts" 7 59) ("Acts" 8 1 8)))))

    (st-john-evangelist
     (day
      :mattins  (:lesson1 ("Exod" 33 7)
                 :lesson2 ("John" 13 10 35))
      :evensong (:lesson1 ("Isa" 6 1 8)
                 :lesson2 ("Rev" 4))))

    (holy-innocents
     (day
      :mattins  (:lesson1 ("Jer" 31 1 17)
                 :lesson2 ("Matt" 18 1 14))
      :evensong (:lesson1 ("II Chr" 22 8)
                 :lesson2 ("Mark" 10 13 27))))

    (december-29
     (day
      :mattins  (:lesson1 (("Isa" 10 33) ("Isa" 11 1 9))
                 :lesson2 (("I John" 1 1) ("I John" 2 1 6)))
      :evensong (:lesson1 ("Ezek" 34 1 16)
                 :lesson2 ("Luke" 2 41))))             ; from v.41

    (december-30
     (day
      :mattins  (:lesson1 (("Isa" 11 10) ("Isa" 12))
                 :lesson2 ("I John" 2 7 17))
      :evensong (:lesson1 ("Ezek" 34 17)
                 :lesson2 ("Matt" 2 1 12))))

    (december-31
     (day
      :mattins  (:lesson1 ("Isa" 25 1 9)
                 :lesson2 ("I John" 2 18))
      :evensong (:lesson1 (("Deut" 10 12) ("Deut" 11 1 1))
                 :lesson2 ("Matt" 2 13))))

    (circumcision
     (day
      :mattins  (:lesson1 ("Exod" 6 2 8)
                 :lesson2 ("Matt" 1 18))
      :evensong (:lesson1 ("Gen" 32 22 30)
                 :lesson2 ("Rev" 19 11 16))))

    (january-2
     (day
      :mattins  (:lesson1 ("Isa" 28 9 22)
                 :lesson2 ("I John" 3 1 18))
      :evensong (:lesson1 ("Jer" 23 1 6)
                 :lesson2 ("Luke" 2 41))))

    (january-3
     (day
      :mattins  (:lesson1 ("Isa" 29 9 19)
                 :lesson2 (("I John" 3 18) ("I John" 4 1 6)))
      :evensong (:lesson1 ("Jer" 30 1 11)
                 :lesson2 ("John" 1 1 28))))

    (january-4
     (day
      :mattins  (:lesson1 (:multiple ("Isa" 32 1 8) ("Isa" 32 16 18))
                 :lesson2 ("I John" 4 7))
      :evensong (:lesson1 ("Jer" 30 13 22)
                 :lesson2 ("John" 1 29))))

    (january-5
     (day
      :mattins  (:lesson1 ("Isa" 35)
                 :lesson2 ("I John" 5))
      :evensong (:lesson1 ("Num" 24 13 24)
                 :lesson2 ("Matt" 28 16))))

    (epiphany
     (day
      :mattins  (:lesson1 ("Isa" 60)
                 :lesson2 ("Matt" 3 13))
      :evensong (:lesson1 ("Isa" 49 1 13)
                 :lesson2 ("John" 2 1 11))))

    ;;;; ── SAINTS' DAYS (with Vespers I) ──────────────────────────────────────

    (st-andrew
     (day
      :vespers-i (:lesson1 ("Isa" 49 1 13)
                  :lesson2 ("I Cor" 4 1 16))
      :mattins   (:lesson1 ("Num" 10 29)
                  :lesson2 ("John" 1 29 42))
      :evensong  (:lesson1 ("Isa" 55)
                  :lesson2 ("John" 12 20 36))))

    (st-thomas
     (day
      :vespers-i (:lesson1 ("II Kgs" 6 8 23)
                  :lesson2 ("John" 14 1 14))
      :mattins   (:lesson1 ("II Kgs" 7)
                  :lesson2 ("Mark" 16 9))
      :evensong  (:lesson1 (("Heb" 1 1) ("Heb" 2 1 4))
                  :lesson2 ("John" 14 9))))             ; VERIFY eve L2

    (conversion-of-st-paul
     (day
      :vespers-i (:lesson1 ("Wis" 5 1 16)
                  :lesson2 ("Gal" 1))
      :mattins   (:lesson1 ("Ecclus" 39 1 10)
                  :lesson2 ("Acts" 26 1 23))
      :evensong  (:lesson1 ("Jer" 1 1 10)
                  :lesson2 (("II Tim" 3 10) ("II Tim" 4 1 8)))))

    (purification
     (day
      :vespers-i (:lesson1 ("Exod" 13 11 16)
                  :lesson2 ("Heb" 10 1 10))
      :mattins   (:lesson1 ("I Sam" 1 20)
                  :lesson2 ("Lev" 12))
      :evensong  (:lesson1 (("Gal" 3 15) ("Gal" 4 1 7))
                  :lesson2 ("I John" 3 1 8))))

    (st-matthias
     (day
      :vespers-i (:lesson1 ("I Kgs" 2 26 36)          ; VERIFY range
                  :lesson2 ("Luke" 10 1 20))
      :mattins   (:lesson1 ("I Sam" 2 27)
                  :lesson2 ("Luke" 12 16 40))
      :evensong  (:lesson1 ("Isa" 22 15 24)
                  :lesson2 ("I John" 2 15))))

    (annunciation
     (day
      :vespers-i (:lesson1 ("Gen" 3 1 15)
                  :lesson2 ("Rev" 12))
      :mattins   (:lesson1 ("Gen" 18 1 14)
                  :lesson2 ("John" 1 1 18))
      :evensong  (:lesson1 (("I Sam" 1 21) ("I Sam" 2 1 10))
                  :lesson2 ("Luke" 1 39 56))))

    (st-mark
     (day
      :vespers-i (:lesson1 ("Ecclus" 2)
                  :lesson2 (("Acts" 12 24) ("Acts" 13 1 13)))
      :mattins   (:lesson1 ("Isa" 62)
                  :lesson2 ("I Pet" 5))
      :evensong  (:lesson1 ("Ezek" 1 2 14)
                  :lesson2 ("II Tim" 4 1 18))))

    (ss-philip-and-james
     (day
      :vespers-i (:lesson1 (("Ecclus" 14 20) ("Ecclus" 15 1 10))
                  :lesson2 ("John" 6 1 14))
      :mattins   (:lesson1 ("Isa" 43 1 12)
                  :lesson2 ("John" 1 45))
      :evensong  (:lesson1 ("Isa" 61)
                  :lesson2 ("Acts" 15 1 31))))

    (st-barnabas
     (day
      :vespers-i (:lesson1 ("Ecclus" 31 3 11)
                  :lesson2 ("Acts" 4 23))
      :mattins   (:lesson1 ("II Esd" 2 33)
                  :lesson2 ("Acts" 9 23 31))
      :evensong  (:lesson1 ("Deut" 33 8 11)           ; non-contig 8-11,26-end approx
                  :lesson2 ("Acts" 14))))

    (st-john-baptist
     (day
      :vespers-i (:lesson1 ("Judg" 13)
                  :lesson2 ("Mal" 3 1 12))             ; VERIFY eve L2 — may be Luke 1:5-25
      :mattins   (:lesson1 ("Mal" 3 1 12)
                  :lesson2 ("Matt" 3))
      :evensong  (:lesson1 ("I Kgs" 21 17)
                  :lesson2 ("Mark" 6 14 29))))

    (st-peter
     (day
      :vespers-i (:lesson1 ("Ezek" 3 4 14)
                  :lesson2 ("Matt" 4 12))              ; VERIFY eve L2
      :mattins   (:lesson1 ("Ezek" 34 1 16)
                  :lesson2 ("John" 21 1 22))
      :evensong  (:lesson1 ("Zech" 3)
                  :lesson2 (("I Pet" 4 12) ("I Pet" 5)))))

    (st-james
     (day
      :vespers-i (:lesson1 ("I Sam" 22 6 19)
                  :lesson2 ("Mark" 1 14 22))
      :mattins   (:lesson1 ("Jer" 26 1 11)
                  :lesson2 ("Matt" 10 16))
      :evensong  (:lesson1 ("II Kgs" 1 1 15)
                  :lesson2 ("Luke" 9 46))))

    (transfiguration
     (day
      :vespers-i (:lesson1 ("Exod" 24 2)              ; VERIFY range
                  :lesson2 ("Mark" 9 2 13))
      :mattins   (:lesson1 (("Mal" 3 16) ("Mal" 4))
                  :lesson2 ("Rev" 1))
      :evensong  (:lesson1 ("Exod" 34 29)
                  :lesson2 ("II Cor" 3))))

    (st-bartholomew
     (day
      :vespers-i (:lesson1 ("Isa" 66 1 23)            ; non-contig 1-2,18-23 approx
                  :lesson2 ("Luke" 6 12 23))
      :mattins   (:lesson1 ("Gen" 28 10)
                  :lesson2 ("John" 1 43))
      :evensong  (:lesson1 ("Mic" 4 1 7)
                  :lesson2 (("I Pet" 1 22) ("I Pet" 2 1 10)))))

    (st-matthew
     (day
      :vespers-i (:lesson1 (("Wis" 7 21) ("Wis" 8 1 1))
                  :lesson2 ("Luke" 5 27 32))           ; VERIFY eve L2
      :mattins   (:lesson1 ("I Kgs" 19)
                  :lesson2 ("Matt" 19 16))
      :evensong  (:lesson1 ("Isa" 52 1 10)
                  :lesson2 ("Rom" 10 1 15))))

    (st-michael-and-all-angels
     (day
      :vespers-i (:lesson1 ("Job" 38)
                  :lesson2 (("Heb" 1 3) ("Heb" 2 1 10)))
      :mattins   (:lesson1 ("Gen" 32 24 30)
                  :lesson2 ("Acts" 12 1 17))
      :evensong  (:lesson1 ("Dan" 13)                 ; VERIFY — Dan 13 = Apocr. Susanna
                  :lesson2 ("Rev" 12 7))))             ; VERIFY

    (st-luke
     (day
      :vespers-i (:lesson1 ("Ecclus" 38 1 14)
                  :lesson2 (("Acts" 15 36) ("Acts" 16 1 15)))
      :mattins   (:lesson1 ("Ezek" 1 1 14)
                  :lesson2 ("Luke" 1 1 4))
      :evensong  (:lesson1 ("Ezek" 47 1 12)
                  :lesson2 ("Col" 4 2))))

    (ss-simon-and-jude
     (day
      :vespers-i (:lesson1 ("Isa" 4 1 8)              ; approx; VERIFY
                  :lesson2 ("Mark" 6 1 13))            ; VERIFY
      :mattins   (:lesson1 ("Isa" 21 9 16)             ; VERIFY
                  :lesson2 ("Eph" 2))
      :evensong  (:lesson1 ("Jer" 3 12 18)
                  :lesson2 ("John" 14 15))))

    (all-saints
     (day
      :vespers-i (:lesson1 ("Ecclus" 44 1 15)
                  :lesson2 (("Heb" 11 32) ("Heb" 12 1 11)))
      :mattins   (:lesson1 ("Wis" 3 1 9)
                  :lesson2 ("Rev" 19 1 16))
      :evensong  (:lesson1 (:multiple ("Deut" 33 1 5) ("Deut" 33 26))
                  :lesson2 (("Rev" 21 1) ("Rev" 22 1 5)))))

    ;;;; ── EMBER DAYS (Advent) ────────────────────────────────────────────────
    ;; These entries override the regular week lessons when the day is an
    ;; Advent Ember Day.  Keyed by ember-advent-{wednesday,friday,saturday}.

    (ember-advent-wednesday
     (day
      :mattins  (:lesson1 (("Mal" 1 6) ("Mal" 2 1 7))
                 :lesson2 ("John" 1 29))
      :evensong (:lesson1 ("Deut" 18 13)
                 :lesson2 (("II Tim" 1 1) ("II Tim" 2 1 7)))))

    (ember-advent-friday
     (day
      :mattins  (:lesson1 ("Ecclus" 18 1 14)
                 :lesson2 ("Matt" 9 1 17))
      :evensong (:lesson1 ("I Sam" 3)
                 :lesson2 ("II Tim" 2 5))))

    (ember-advent-saturday
     (day
      :mattins  (:lesson1 (("Mal" 3 13) ("Mal" 4))
                 :lesson2 ("Luke" 6 12 23))
      :evensong (:lesson1 ("Jer" 1)
                 :lesson2 (("II Tim" 3 14) ("II Tim" 4 1 8)))))

    ) ; end bcp-1928-holy-day-lessons
  "Fixed holy day lessons for the 1928 American BCP.
Saints' days include :vespers-i; Christmas octave days do not.
See file commentary for reference format and verification notes.")

;;;; ══════════════════════════════════════════════════════════════════════════
;;;; Special occasion lessons
;;;; ══════════════════════════════════════════════════════════════════════════

(defconst bcp-1928-special-lessons
  '(
    (confirmation
     (:lesson1 ("Isa" 11 1 9)   :lesson2 ("Acts" 19 1 7))
     (:lesson1 ("Ezek" 36 25 28) :lesson2 ("Eph" 3 14)))

    (ordination-diaconate
     (:lesson1 ("Isa" 6 1 8)   :lesson2 ("Mark" 10 32 45))
     (:lesson1 ("Ezek" 3 1 11) :lesson2 (("II Cor" 5 11) ("II Cor" 6 1 10))))

    (institution-of-minister
     (:lesson1 ("Ezek" 33 1 9) :lesson2 ("John" 10 1 18)))

    (consecration-of-bishop
     (:lesson1 ("Isa" 61)      :lesson2 ("II Tim" 2)))

    (laying-of-corner-stone
     (:lesson1 ("Isa" 28 14 22) :lesson2 ("I Pet" 2 1 10)))

    (dedication-of-church
     (:lesson1 ("Gen" 28 10 17)  :lesson2 ("Heb" 10 19 25))
     (:lesson1 ("I Kgs" 8 22 62) :lesson2 ("Rev" 21 10)))

    (church-convention
     (:lesson1 ("Isa" 55)  :lesson2 ("Acts" 15 22 31))
     (:lesson1 ("Isa" 60)  :lesson2 ("I Cor" 12 1 26)))

    (church-missions-or-social-service
     (:lesson1 ("Isa" 49 1 23)  :lesson2 ("Matt" 28 1 10)) ; approx 1-10,16-end
     (:lesson1 ("Isa" 52 1 10)  :lesson2 ("John" 12 20 32))
     (:lesson1 ("Zech" 8 7 22)  :lesson2 ("II Cor" 9 6)))

    (christian-education
     (:lesson1 ("Deut" 6 1 9)  :lesson2 (("II Tim" 3 14) ("II Tim" 4 1 5)))) ; approx 6:1-9,17-end

    (christian-unity
     (:lesson1 ("Isa" 35) :lesson2 ("John" 17)))

    (memorial-day
     (:lesson1 ("Ecclus" 44 1 15) :lesson2 (("Heb" 11 32) ("Heb" 12 1 2))))

    (independence-day
     (:lesson1 ("Deut" 28 1 14) :lesson2 ("John" 8 31 36)))

    (thanksgiving-day
     (:lesson1 ("Deut" 8)   :lesson2 ("I Thess" 5 12 23))
     (:lesson1 ("Isa" 12)   :lesson2 ("Phil" 4 4 7)))

    (national-and-state-festivals
     (:lesson1 ("Isa" 25 1 9) :lesson2 ("Heb" 11 8 16))) ; approx; VERIFY second lesson

    (national-and-state-fasts
     (:lesson1 ("Dan" 9 3 19) :lesson2 ("II Pet" 2 9)))

    (beginning-or-end-of-civil-year
     (:lesson1 ("Eccl" 11 1 10) :lesson2 ("Rev" 21 1 7))) ; non-contig approx; VERIFY

    ) ; end bcp-1928-special-lessons
  "Special occasion lessons for the 1928 American BCP.
Each entry: (OCCASION PERICOPE…) where each PERICOPE is
\(:lesson1 REF :lesson2 REF).  Some occasions have multiple sets.")

(provide 'bcp-anglican-1928-lectionary)
;;; bcp-anglican-1928-lectionary.el ends here
