;;; bcp-1662-data.el --- Lectionary and collects for 1662 BCP -*- lexical-binding: t -*-

;; Keywords: bible, bcp, liturgy, lectionary

;;; Commentary:

;; Consolidated data module.  Contains:
;;   - Daily lectionary (bcp-1662-propers-year): all 366 calendar days
;;   - Sunday proper lessons (bcp-1662-propers-sunday)
;;   - Communion propers: Epistle and Gospel for all Sundays and feasts
;;   - OT/first lessons for Communion
;;   - Collects: all Sundays, feasts, Ember/Rogation days, and commons

;;; Code:

(require 'cl-lib)


;;;; ──────────────────────────────────────────────────────────────────────
;;;; Daily Calendar Lectionary
;;;; ──────────────────────────────────────────────────────────────────────

(defconst bcp-1662-propers-year
  '(
  ;; ---- January ----
    (1 1
     :dominical "A"
     :feast "Circumcision of our Lord"
     :mattins  (:lesson1 ("Gen" 17 19 27)  :lesson2 ("Rom" 2 17 29))
     :evensong (:lesson1 ("Deut" 10 12 22)  :lesson2 ("Col" 2 8 18)))
    (1 2
     :dominical "b"
     :mattins  (:lesson1 ("Gen" 1 1 20)  :lesson2 ("Matt" 1 18 25))
     :evensong (:lesson1 (("Gen" 1 20 nil) ("Gen" 2 1 4))  :lesson2 ("Acts" 1)))
    (1 3
     :dominical "c"
     :mattins  (:lesson1 ("Gen" 2 4 25)  :lesson2 ("Matt" 2))
     :evensong (:lesson1 ("Gen" 3 1 20)  :lesson2 ("Acts" 2 1 22)))
    (1 4
     :dominical "d"
     :mattins  (:lesson1 (("Gen" 3 20 nil) ("Gen" 4 1 16))  :lesson2 ("Matt" 3))
     :evensong (:lesson1 ("Gen" 4 16 26)  :lesson2 ("Acts" 2 22 47)))
    (1 5
     :dominical "e"
     :mattins  (:lesson1 ("Gen" 5 1 28)  :lesson2 ("Matt" 4 1 23))
     :evensong (:lesson1 (("Gen" 5 28 nil) ("Gen" 6 1 9))  :lesson2 ("Acts" 3)))
    (1 6
     :dominical "f"
     :feast "Epiphany of our Lord"
     :mattins  (:lesson1 ("Isa" 60)  :lesson2 ("Luke" 3 15 23))
     :evensong (:lesson1 ("Isa" 49 13 24)  :lesson2 ("John" 2 1 12)))
    (1 7
     :dominical "g"
     :mattins  (:lesson1 ("Gen" 6 9 22)  :lesson2 (("Matt" 4 23 nil) ("Matt" 5 1 13)))
     :evensong (:lesson1 ("Gen" 7)  :lesson2 ("Acts" 4 1 32)))
    (1 8
     :dominical "A"
     :feast "Lucian, P. & M."
     :mattins  (:lesson1 ("Gen" 8)  :lesson2 ("Matt" 5 13 33))
     :evensong (:lesson1 ("Gen" 9 1 20)  :lesson2 (("Acts" 4 32 nil) ("Acts" 5 1 17))))
    (1 9
     :dominical "b"
     :mattins  (:lesson1 ("Gen" 11 1 10)  :lesson2 ("Matt" 5 33 48))
     :evensong (:lesson1 ("Gen" 12)  :lesson2 ("Acts" 5 17 42)))
    (1 10
     :dominical "c"
     :mattins  (:lesson1 ("Gen" 13)  :lesson2 ("Matt" 6 1 19))
     :evensong (:lesson1 ("Gen" 14)  :lesson2 ("Acts" 6)))
    (1 11
     :dominical "d"
     :mattins  (:lesson1 ("Gen" 15)  :lesson2 (("Matt" 6 19 nil) ("Matt" 7 1 7)))
     :evensong (:lesson1 ("Gen" 16)  :lesson2 ("Acts" 7 1 35)))
    (1 12
     :dominical "e"
     :mattins  (:lesson1 ("Gen" 17 1 23)  :lesson2 ("Matt" 7 7 29))
     :evensong (:lesson1 ("Gen" 18 1 17)  :lesson2 (("Acts" 7 35 nil) ("Acts" 8 1 5))))
    (1 13
     :dominical "f"
     :feast "Hilary, Bp. & C."
     :mattins  (:lesson1 ("Gen" 18 17 33)  :lesson2 ("Matt" 8 1 18))
     :evensong (:lesson1 ("Gen" 19 12 30)  :lesson2 ("Acts" 8 5 26)))
    (1 14
     :dominical "g"
     :mattins  (:lesson1 ("Gen" 20)  :lesson2 ("Matt" 8 18 34))
     :evensong (:lesson1 ("Gen" 21 1 22)  :lesson2 ("Acts" 8 26 40)))
    (1 15
     :dominical "A"
     :mattins  (:lesson1 (("Gen" 21 33 nil) ("Gen" 22 1 20))  :lesson2 ("Matt" 9 1 18))
     :evensong (:lesson1 ("Gen" 23)  :lesson2 ("Acts" 9 1 23)))
    (1 16
     :dominical "b"
     :mattins  (:lesson1 ("Gen" 24 1 29)  :lesson2 ("Matt" 9 18 38))
     :evensong (:lesson1 ("Gen" 24 29 52)  :lesson2 ("Acts" 9 23 43)))
    (1 17
     :dominical "c"
     :mattins  (:lesson1 ("Gen" 24 52 67)  :lesson2 ("Matt" 10 1 24))
     :evensong (:lesson1 ("Gen" 25 5 19)  :lesson2 ("Acts" 10 1 24)))
    (1 18
     :dominical "d"
     :feast "Prisca, V. & M."
     :mattins  (:lesson1 ("Gen" 25 19 34)  :lesson2 ("Matt" 10 24 42))
     :evensong (:lesson1 ("Gen" 26 1 18)  :lesson2 ("Acts" 10 24 48)))
    (1 19
     :dominical "e"
     :mattins  (:lesson1 ("Gen" 26 18 35)  :lesson2 ("Matt" 11))
     :evensong (:lesson1 ("Gen" 27 1 30)  :lesson2 ("Acts" 11)))
    (1 20
     :dominical "f"
     :feast "Fabian, Bp. & M."
     :mattins  (:lesson1 ("Gen" 27 30 46)  :lesson2 ("Matt" 12 1 22))
     :evensong (:lesson1 ("Gen" 28)  :lesson2 ("Acts" 12)))
    (1 21
     :dominical "g"
     :feast "Agnes, V. & M."
     :mattins  (:lesson1 ("Gen" 29 1 21)  :lesson2 ("Matt" 12 22 50))
     :evensong (:lesson1 ("Gen" 31 1 25)  :lesson2 ("Acts" 13 1 26)))
    (1 22
     :dominical "A"
     :feast "Vincent, Mart."
     :mattins  (:lesson1 ("Gen" 31 36 55)  :lesson2 ("Matt" 13 1 24))
     :evensong (:lesson1 ("Gen" 32 1 22)  :lesson2 ("Acts" 13 26 52)))
    (1 23
     :dominical "b"
     :mattins  (:lesson1 ("Gen" 32 22 32)  :lesson2 ("Matt" 13 24 53))
     :evensong (:lesson1 ("Gen" 33)  :lesson2 ("Acts" 14)))
    (1 24
     :dominical "c"
     :mattins  (:lesson1 ("Gen" 35 1 21)  :lesson2 (("Matt" 13 53 nil) ("Matt" 14 1 13)))
     :evensong (:lesson1 ("Gen" 37 1 12)  :lesson2 ("Acts" 15 1 30)))
    (1 25
     :dominical "d"
     :feast "Conversion of St. Paul"
     :mattins  (:lesson1 ("Isa" 49 1 13)  :lesson2 ("Gal" 1 11 24))
     :evensong (:lesson1 ("Jer" 1 1 11)  :lesson2 ("Acts" 26 1 21)))
    (1 26
     :dominical "e"
     :mattins  (:lesson1 ("Gen" 37 12 36)  :lesson2 ("Matt" 14 13 36))
     :evensong (:lesson1 ("Gen" 39)  :lesson2 (("Acts" 15 30 nil) ("Acts" 16 1 16))))
    (1 27
     :dominical "f"
     :mattins  (:lesson1 ("Gen" 40)  :lesson2 ("Matt" 15 1 21))
     :evensong (:lesson1 ("Gen" 49 1 17)  :lesson2 ("Acts" 16 16 40)))
    (1 28
     :dominical "g"
     :mattins  (:lesson1 ("Gen" 41 17 53)  :lesson2 ("Matt" 15 21 39))
     :evensong (:lesson1 (("Gen" 41 53 nil) ("Gen" 42 1 25))  :lesson2 ("Acts" 17 1 16)))
    (1 29
     :dominical "A"
     :mattins  (:lesson1 ("Gen" 42 25 38)  :lesson2 ("Matt" 16 1 24))
     :evensong (:lesson1 ("Gen" 43 1 25)  :lesson2 ("Acts" 17 16 34)))
    (1 30
     :dominical "b"
     :mattins  (:lesson1 (("Gen" 43 25 nil) ("Gen" 44 1 14))  :lesson2 (("Matt" 16 24 nil) ("Matt" 17 1 14)))
     :evensong (:lesson1 ("Gen" 44 14 34)  :lesson2 ("Acts" 18 1 24)))
    (1 31
     :dominical "c"
     :mattins  (:lesson1 ("Gen" 45 1 25)  :lesson2 ("Matt" 17 14 27))
     :evensong (:lesson1 (("Gen" 45 25 nil) ("Gen" 46 1 8))  :lesson2 (("Acts" 18 24 nil) ("Acts" 19 1 21))))

  ;; ---- February ----
    (2 1
     :dominical "d"
     :feast "Fast."
     :mattins  (:lesson1 (("Gen" 46 26 nil) ("Gen" 47 1 13))  :lesson2 ("Matt" 18 1 21))
     :evensong (:lesson1 ("Gen" 47 13 31)  :lesson2 ("Acts" 19 21 41)))
    (2 2
     :dominical "e"
     :feast "Purific. of V. M."
     :mattins  (:lesson1 ("Exod" 13 1 17)  :lesson2 (("Matt" 18 21 nil) ("Matt" 19 1 3)))
     :evensong (:lesson1 ("Hag" 2 1 10)  :lesson2 ("Acts" 20 1 17)))
    (2 3
     :dominical "f"
     :mattins  (:lesson1 ("Gen" 48)  :lesson2 ("Matt" 19 3 27))
     :evensong (:lesson1 ("Gen" 49)  :lesson2 ("Acts" 20 17 38)))
    (2 4
     :dominical "g"
     :mattins  (:lesson1 ("Gen" 50)  :lesson2 (("Matt" 19 27 nil) ("Matt" 20 1 17)))
     :evensong (:lesson1 ("Exod" 1)  :lesson2 ("Acts" 21 1 17)))
    (2 5
     :dominical "A"
     :feast "Agatha, V. & M."
     :mattins  (:lesson1 ("Exod" 2)  :lesson2 ("Matt" 20 17 34))
     :evensong (:lesson1 ("Exod" 3)  :lesson2 ("Acts" 21 17 37)))
    (2 6
     :dominical "b"
     :mattins  (:lesson1 ("Exod" 4 1 24)  :lesson2 ("Matt" 21 1 23))
     :evensong (:lesson1 (("Exod" 4 27 nil) ("Exod" 5 1 15))  :lesson2 (("Acts" 21 37 nil) ("Acts" 22 1 23))))
    (2 7
     :dominical "c"
     :mattins  (:lesson1 (("Exod" 5 15 nil) ("Exod" 6 1 14))  :lesson2 ("Matt" 21 23 46))
     :evensong (:lesson1 (("Exod" 6 28 nil) ("Exod" 7 1 14))  :lesson2 (("Acts" 22 23 nil) ("Acts" 23 1 12))))
    (2 8
     :dominical "d"
     :mattins  (:lesson1 ("Exod" 7 14 25)  :lesson2 ("Matt" 22 1 15))
     :evensong (:lesson1 ("Exod" 8 1 20)  :lesson2 ("Acts" 23 12 35)))
    (2 9
     :dominical "e"
     :mattins  (:lesson1 (("Exod" 8 20 nil) ("Exod" 9 1 13))  :lesson2 ("Matt" 22 15 41))
     :evensong (:lesson1 ("Exod" 9 13 35)  :lesson2 ("Acts" 24)))
    (2 10
     :dominical "f"
     :mattins  (:lesson1 ("Exod" 10 1 21)  :lesson2 (("Matt" 22 41 nil) ("Matt" 23 1 13)))
     :evensong (:lesson1 (("Exod" 10 21 nil) ("Exod" 11))  :lesson2 ("Acts" 25)))
    (2 11
     :dominical "g"
     :mattins  (:lesson1 ("Exod" 12 1 21)  :lesson2 ("Matt" 23 13 39))
     :evensong (:lesson1 ("Exod" 12 21 43)  :lesson2 ("Acts" 26)))
    (2 12
     :dominical "A"
     :mattins  (:lesson1 (("Exod" 12 43 nil) ("Exod" 13 1 17))  :lesson2 ("Matt" 24 1 29))
     :evensong (:lesson1 (("Exod" 13 17 nil) ("Exod" 14 1 10))  :lesson2 ("Acts" 27 1 18)))
    (2 13
     :dominical "b"
     :mattins  (:lesson1 ("Exod" 14 10 31)  :lesson2 ("Matt" 24 29 51))
     :evensong (:lesson1 ("Exod" 15 1 22)  :lesson2 ("Acts" 27 18 44)))
    (2 14
     :dominical "c"
     :feast "Valentine, Bishop"
     :mattins  (:lesson1 (("Exod" 15 22 nil) ("Exod" 16 1 11))  :lesson2 ("Matt" 25 1 31))
     :evensong (:lesson1 ("Exod" 16 11 36)  :lesson2 ("Acts" 28 1 17)))
    (2 15
     :dominical "d"
     :mattins  (:lesson1 ("Exod" 17)  :lesson2 ("Matt" 25 3 46))
     :evensong (:lesson1 ("Exod" 18)  :lesson2 ("Acts" 28 17 31)))
    (2 16
     :dominical "e"
     :mattins  (:lesson1 ("Exod" 19)  :lesson2 ("Matt" 26 1 31))
     :evensong (:lesson1 ("Exod" 20 1 22)  :lesson2 ("Rom" 1)))
    (2 17
     :dominical "f"
     :mattins  (:lesson1 ("Exod" 21 1 18)  :lesson2 ("Matt" 26 31 57))
     :evensong (:lesson1 (("Exod" 22 21 nil) ("Exod" 23 1 10))  :lesson2 ("Rom" 2 1 17)))
    (2 18
     :dominical "g"
     :mattins  (:lesson1 ("Exod" 23 14 33)  :lesson2 ("Matt" 26 57 75))
     :evensong (:lesson1 ("Exod" 24)  :lesson2 ("Rom" 2 17 29)))
    (2 19
     :dominical "A"
     :mattins  (:lesson1 ("Exod" 25 1 23)  :lesson2 ("Matt" 27 1 27))
     :evensong (:lesson1 ("Exod" 28 1 13)  :lesson2 ("Rom" 3)))
    (2 20
     :dominical "b"
     :mattins  (:lesson1 ("Exod" 28 29 42)  :lesson2 ("Matt" 27 27 57))
     :evensong (:lesson1 (("Exod" 29 35 nil) ("Exod" 30 1 11))  :lesson2 ("Rom" 4)))
    (2 21
     :dominical "c"
     :mattins  (:lesson1 ("Exod" 31)  :lesson2 ("Matt" 27 57 66))
     :evensong (:lesson1 ("Exod" 32 1 15)  :lesson2 ("Rom" 5)))
    (2 22
     :dominical "d"
     :mattins  (:lesson1 ("Exod" 32 15 35)  :lesson2 ("Matt" 28))
     :evensong (:lesson1 ("Exod" 33 1 12)  :lesson2 ("Rom" 6)))
    (2 23
     :dominical "e"
     :feast "Fast."
     :mattins  (:lesson1 (("Exod" 33 12 nil) ("Exod" 34 1 10))  :lesson2 ("Mark" 1 1 21))
     :evensong (:lesson1 ("Exod" 34 10 27)  :lesson2 ("Rom" 7)))
    (2 24
     :dominical "f"
     :feast "St. Matthias, Ap."
     :mattins  (:lesson1 ("1 Sam" 2 27 36)  :lesson2 ("Mark" 1 21 45))
     :evensong (:lesson1 ("Isa" 22 15 nil)  :lesson2 ("Rom" 8 1 18)))
    (2 25
     :dominical "g"
     :mattins  (:lesson1 ("Exod" 34 27 35)  :lesson2 ("Mark" 2 1 23))
     :evensong (:lesson1 (("Exod" 35 29 nil) ("Exod" 36 1 8))  :lesson2 ("Rom" 8 18 nil)))
    (2 26
     :dominical "A"
     :mattins  (:lesson1 ("Exod" 39 30 43)  :lesson2 (("Mark" 2 23 nil) ("Mark" 3 1 13)))
     :evensong (:lesson1 ("Exod" 40 1 17)  :lesson2 ("Rom" 9 1 19)))
    (2 27
     :dominical "b"
     :mattins  (:lesson1 ("Exod" 40 17 38)  :lesson2 ("Mark" 3 13 35))
     :evensong (:lesson1 (("Lev" 9 22 nil) ("Lev" 10 1 12))  :lesson2 ("Rom" 9 19 33)))
    (2 28
     :dominical "c"
     :mattins  (:lesson1 ("Lev" 14 1 23)  :lesson2 ("Mark" 4 1 35))
     :evensong (:lesson1 ("Lev" 16 1 23)  :lesson2 ("Rom" 10)))
    (2 29
     :dominical nil
     :mattins  (:lesson1 ("Lev" 19 1 19)  :lesson2 ("Matt" 7))
     :evensong (:lesson1 (("Lev" 19 30 nil) ("Lev" 20 1 9))  :lesson2 ("Rom" 12)))

  ;; ---- March ----
    (3 1
     :dominical "d"
     :feast "David, Archbp."
     :mattins  (:lesson1 ("Lev" 25 1 18)  :lesson2 (("Mark" 4 35 nil) ("Mark" 5 1 21)))
     :evensong (:lesson1 ("Lev" 25 18 44)  :lesson2 ("Rom" 11 1 25)))
    (3 2
     :dominical "e"
     :feast "Chad, Bishop"
     :mattins  (:lesson1 ("Lev" 26 1 21)  :lesson2 ("Mark" 5 21 nil))
     :evensong (:lesson1 ("Lev" 26 21 46)  :lesson2 ("Rom" 11 25 nil)))
    (3 3
     :dominical "f"
     :mattins  (:lesson1 ("Num" 6)  :lesson2 ("Mark" 6 1 14))
     :evensong (:lesson1 (("Num" 9 15 nil) ("Num" 10 1 11))  :lesson2 ("Rom" 12)))
    (3 4
     :dominical "g"
     :mattins  (:lesson1 ("Num" 10 11 36)  :lesson2 ("Mark" 6 14 30))
     :evensong (:lesson1 ("Num" 11 1 24)  :lesson2 ("Rom" 13)))
    (3 5
     :dominical "A"
     :mattins  (:lesson1 ("Num" 11 24 36)  :lesson2 ("Mark" 6 30 nil))
     :evensong (:lesson1 ("Num" 12)  :lesson2 (("Rom" 14) ("Rom" 15 1 8))))
    (3 6
     :dominical "b"
     :mattins  (:lesson1 ("Num" 13 17 33)  :lesson2 ("Mark" 7 1 24))
     :evensong (:lesson1 ("Num" 14 1 26)  :lesson2 ("Rom" 15 8 nil)))
    (3 7
     :dominical "c"
     :feast "Perpetua, M."
     :mattins  (:lesson1 ("Num" 14 26 45)  :lesson2 (("Mark" 7 24 nil) ("Mark" 8 1 10)))
     :evensong (:lesson1 ("Num" 16 1 23)  :lesson2 ("Rom" 16)))
    (3 8
     :dominical "d"
     :mattins  (:lesson1 ("Num" 16 23 50)  :lesson2 (("Mark" 8 10 nil) ("Mark" 9 1 2)))
     :evensong (:lesson1 ("Num" 17)  :lesson2 ("1 Cor" 1 1 26)))
    (3 9
     :dominical "e"
     :mattins  (:lesson1 ("Num" 20 1 14)  :lesson2 ("Mark" 9 2 30))
     :evensong (:lesson1 ("Num" 20 14 29)  :lesson2 (("1 Cor" 1 26 nil) ("1 Cor" 2))))
    (3 10
     :dominical "f"
     :mattins  (:lesson1 ("Num" 21 1 10)  :lesson2 ("Mark" 9 30 nil))
     :evensong (:lesson1 ("Num" 21 10 32)  :lesson2 ("1 Cor" 3)))
    (3 11
     :dominical "g"
     :mattins  (:lesson1 ("Num" 22 1 22)  :lesson2 ("Mark" 10 1 32))
     :evensong (:lesson1 ("Num" 22 22 41)  :lesson2 ("1 Cor" 4 1 18)))
    (3 12
     :dominical "A"
     :feast "Gregory, M. B."
     :mattins  (:lesson1 ("Num" 23)  :lesson2 ("Mark" 10 32 nil))
     :evensong (:lesson1 ("Num" 24)  :lesson2 (("1 Cor" 4 18 nil) ("1 Cor" 5))))
    (3 13
     :dominical "b"
     :mattins  (:lesson1 ("Num" 25)  :lesson2 ("Mark" 11 1 27))
     :evensong (:lesson1 ("Num" 27 12 23)  :lesson2 ("1 Cor" 6)))
    (3 14
     :dominical "c"
     :mattins  (:lesson1 ("Deut" 1 1 19)  :lesson2 (("Mark" 11 27 nil) ("Mark" 12 1 13)))
     :evensong (:lesson1 ("Deut" 1 19 46)  :lesson2 ("1 Cor" 7 1 25)))
    (3 15
     :dominical "d"
     :mattins  (:lesson1 ("Deut" 2 1 26)  :lesson2 ("Mark" 12 13 35))
     :evensong (:lesson1 (("Deut" 2 26 nil) ("Deut" 3 1 18))  :lesson2 ("1 Cor" 7 25 nil)))
    (3 16
     :dominical "e"
     :mattins  (:lesson1 ("Deut" 3 18 29)  :lesson2 (("Mark" 12 35 nil) ("Mark" 13 1 14)))
     :evensong (:lesson1 ("Deut" 4 1 25)  :lesson2 ("1 Cor" 8)))
    (3 17
     :dominical "f"
     :mattins  (:lesson1 ("Deut" 4 25 41)  :lesson2 ("Mark" 13 14 nil))
     :evensong (:lesson1 ("Deut" 5 1 22)  :lesson2 ("1 Cor" 9)))
    (3 18
     :dominical "g"
     :feast "Edward, King of the West-Sax."
     :mattins  (:lesson1 ("Deut" 5 22 33)  :lesson2 ("Mark" 14 1 27))
     :evensong (:lesson1 ("Deut" 6)  :lesson2 (("1 Cor" 10) ("1 Cor" 11 1 1))))
    (3 19
     :dominical "A"
     :mattins  (:lesson1 ("Deut" 7 1 12)  :lesson2 ("Mark" 14 27 53))
     :evensong (:lesson1 ("Deut" 7 12 26)  :lesson2 ("1 Cor" 11 2 17)))
    (3 20
     :dominical "b"
     :mattins  (:lesson1 ("Deut" 8)  :lesson2 ("Mark" 14 53 72))
     :evensong (:lesson1 ("Deut" 10 8 22)  :lesson2 ("1 Cor" 11 17 nil)))
    (3 21
     :dominical "c"
     :feast "Benedict, Abbot."
     :mattins  (:lesson1 ("Deut" 11 1 18)  :lesson2 ("Mark" 15 1 42))
     :evensong (:lesson1 ("Deut" 11 18 32)  :lesson2 ("1 Cor" 12 1 28)))
    (3 22
     :dominical "d"
     :mattins  (:lesson1 ("Deut" 15 1 16)  :lesson2 (("Mark" 15 42 nil) ("Mark" 16)))
     :evensong (:lesson1 ("Deut" 17 8 20)  :lesson2 (("1 Cor" 12 28 nil) ("1 Cor" 13))))
    (3 23
     :dominical "e"
     :mattins  (:lesson1 ("Deut" 18 9 22)  :lesson2 ("Luke" 1 1 26))
     :evensong (:lesson1 ("Deut" 24 5 22)  :lesson2 ("1 Cor" 14 1 20)))
    (3 24
     :dominical "f"
     :feast "Fast."
     :mattins  (:lesson1 ("Deut" 26)  :lesson2 ("Luke" 1 26 46))
     :evensong (:lesson1 ("Deut" 27)  :lesson2 ("1 Cor" 14 20 nil)))
    (3 25
     :dominical "g"
     :feast "Annunc. of Vir. Mary"
     :mattins  (:lesson1 ("Gen" 3 1 16)  :lesson2 ("Luke" 1 46 nil))
     :evensong (:lesson1 ("Isa" 52 7 13)  :lesson2 ("1 Cor" 15 1 35)))
    (3 26
     :dominical "A"
     :mattins  (:lesson1 ("Deut" 28 1 15)  :lesson2 ("Luke" 2 1 21))
     :evensong (:lesson1 ("Deut" 28 15 47)  :lesson2 ("1 Cor" 15 35 nil)))
    (3 27
     :dominical "b"
     :mattins  (:lesson1 ("Deut" 28 47 68)  :lesson2 ("Luke" 2 21 nil))
     :evensong (:lesson1 ("Deut" 29 9 29)  :lesson2 ("1 Cor" 16)))
    (3 28
     :dominical "c"
     :mattins  (:lesson1 ("Deut" 30)  :lesson2 ("Luke" 3 23 nil))
     :evensong (:lesson1 ("Deut" 31 1 14)  :lesson2 ("2 Cor" 1 1 23)))
    (3 29
     :dominical "d"
     :mattins  (:lesson1 ("Deut" 31 14 30)  :lesson2 ("Luke" 4 1 16))
     :evensong (:lesson1 (("Deut" 31 30 nil) ("Deut" 32 1 44))  :lesson2 (("2 Cor" 1 23 nil) ("2 Cor" 2 1 14))))
    (3 30
     :dominical "e"
     :mattins  (:lesson1 ("Deut" 32 44 52)  :lesson2 ("Luke" 4 16 nil))
     :evensong (:lesson1 ("Deut" 33)  :lesson2 (("2 Cor" 2 14 nil) ("2 Cor" 3))))
    (3 31
     :dominical "f"
     :mattins  (:lesson1 ("Deut" 34)  :lesson2 ("Luke" 5 1 17))
     :evensong (:lesson1 ("Josh" 1)  :lesson2 ("2 Cor" 4)))

  ;; ---- April ----
    (4 1
     :dominical "g"
     :mattins  (:lesson1 ("Josh" 2)  :lesson2 ("Luke" 5 17 39))
     :evensong (:lesson1 ("Josh" 3)  :lesson2 ("2 Cor" 5)))
    (4 2
     :dominical "A"
     :mattins  (:lesson1 ("Josh" 4)  :lesson2 ("Luke" 6 1 20))
     :evensong (:lesson1 ("Josh" 5)  :lesson2 (("2 Cor" 6) ("2 Cor" 7 1 1))))
    (4 3
     :dominical "b"
     :feast "Richard, Bp."
     :mattins  (:lesson1 ("Josh" 6)  :lesson2 ("Luke" 6 20 49))
     :evensong (:lesson1 ("Josh" 7)  :lesson2 ("2 Cor" 7 2 16)))
    (4 4
     :dominical "c"
     :feast "S. Ambrose, Bp."
     :mattins  (:lesson1 ("Josh" 9 3 27)  :lesson2 ("Luke" 7 1 24))
     :evensong (:lesson1 ("Josh" 10 1 16)  :lesson2 ("2 Cor" 8)))
    (4 5
     :dominical "d"
     :mattins  (:lesson1 (("Josh" 21 43 nil) ("Josh" 22 1 11))  :lesson2 ("Luke" 7 24 50))
     :evensong (:lesson1 ("Josh" 22 11 34)  :lesson2 ("2 Cor" 9)))
    (4 6
     :dominical "e"
     :mattins  (:lesson1 ("Josh" 23)  :lesson2 ("Luke" 8 1 26))
     :evensong (:lesson1 ("Josh" 24)  :lesson2 ("2 Cor" 10)))
    (4 7
     :dominical "f"
     :mattins  (:lesson1 ("Judg" 2)  :lesson2 ("Luke" 8 26 56))
     :evensong (:lesson1 ("Judg" 4)  :lesson2 ("2 Cor" 11 1 30)))
    (4 8
     :dominical "g"
     :mattins  (:lesson1 ("Judg" 5)  :lesson2 ("Luke" 9 1 28))
     :evensong (:lesson1 ("Judg" 6 1 24)  :lesson2 (("2 Cor" 11 30 nil) ("2 Cor" 12 1 14))))
    (4 9
     :dominical "A"
     :mattins  (:lesson1 ("Judg" 6 24 40)  :lesson2 ("Luke" 9 28 51))
     :evensong (:lesson1 ("Judg" 7)  :lesson2 (("2 Cor" 12 14 nil) ("2 Cor" 13))))
    (4 10
     :dominical "b"
     :mattins  (:lesson1 (("Judg" 8 32 nil) ("Judg" 9 1 25))  :lesson2 (("Luke" 9 51 nil) ("Luke" 10 1 17)))
     :evensong (:lesson1 ("Judg" 10)  :lesson2 ("Gal" 1)))
    (4 11
     :dominical "c"
     :mattins  (:lesson1 ("Judg" 11 1 29)  :lesson2 ("Luke" 10 17 42))
     :evensong (:lesson1 ("Judg" 11 29 40)  :lesson2 ("Gal" 2)))
    (4 12
     :dominical "d"
     :mattins  (:lesson1 ("Judg" 13)  :lesson2 ("Luke" 11 1 29))
     :evensong (:lesson1 ("Judg" 14)  :lesson2 ("Gal" 3)))
    (4 13
     :dominical "e"
     :mattins  (:lesson1 ("Judg" 15)  :lesson2 ("Luke" 11 29 54))
     :evensong (:lesson1 ("Judg" 16)  :lesson2 ("Gal" 4 1 21)))
    (4 14
     :dominical "f"
     :mattins  (:lesson1 ("Ruth" 1)  :lesson2 ("Luke" 12 1 35))
     :evensong (:lesson1 ("Ruth" 2)  :lesson2 (("Gal" 4 21 nil) ("Gal" 5 1 13))))
    (4 15
     :dominical "g"
     :mattins  (:lesson1 ("Ruth" 3)  :lesson2 ("Luke" 12 35 59))
     :evensong (:lesson1 ("Ruth" 4)  :lesson2 ("Gal" 5 13 13)))
    (4 16
     :dominical "A"
     :mattins  (:lesson1 ("1 Sam" 1)  :lesson2 ("Luke" 13 1 18))
     :evensong (:lesson1 ("1 Sam" 2)  :lesson2 ("Gal" 6)))
    (4 17
     :dominical "b"
     :mattins  (:lesson1 ("1 Sam" 2 21 36)  :lesson2 ("Luke" 13 18 35))
     :evensong (:lesson1 ("1 Sam" 3)  :lesson2 ("Eph" 1)))
    (4 18
     :dominical "c"
     :mattins  (:lesson1 ("1 Sam" 4)  :lesson2 ("Luke" 14 1 25))
     :evensong (:lesson1 ("1 Sam" 5)  :lesson2 ("Eph" 2)))
    (4 19
     :dominical "d"
     :feast "Alphege, Abp."
     :mattins  (:lesson1 ("1 Sam" 6)  :lesson2 (("Luke" 14 25 nil) ("Luke" 15 1 11)))
     :evensong (:lesson1 ("1 Sam" 7)  :lesson2 ("Eph" 3)))
    (4 20
     :dominical "e"
     :mattins  (:lesson1 ("1 Sam" 8)  :lesson2 ("Luke" 15 11 32))
     :evensong (:lesson1 ("1 Sam" 9)  :lesson2 ("Eph" 4 1 25)))
    (4 21
     :dominical "f"
     :mattins  (:lesson1 ("1 Sam" 10)  :lesson2 ("Luke" 16))
     :evensong (:lesson1 ("1 Sam" 11)  :lesson2 (("Eph" 4 25 nil) ("Eph" 5 1 22))))
    (4 22
     :dominical "g"
     :mattins  (:lesson1 ("1 Sam" 12)  :lesson2 ("Luke" 17 1 20))
     :evensong (:lesson1 ("1 Sam" 13)  :lesson2 (("Eph" 5 22 nil) ("Eph" 6 1 10))))
    (4 23
     :dominical "A"
     :feast "St. George, M."
     :mattins  (:lesson1 ("1 Sam" 14 1 24)  :lesson2 ("Luke" 17 20 37))
     :evensong (:lesson1 ("1 Sam" 14 24 47)  :lesson2 ("Eph" 6 10 24)))
    (4 24
     :dominical "b"
     :mattins  (:lesson1 ("1 Sam" 15)  :lesson2 ("Luke" 18 1 31))
     :evensong (:lesson1 ("1 Sam" 16)  :lesson2 ("Phil" 1)))
    (4 25
     :dominical "c"
     :feast "St. Mark, Evan."
     :mattins  (:lesson1 ("Isa" 62 6 12)  :lesson2 (("Luke" 18 31 nil) ("Luke" 19 1 11)))
     :evensong (:lesson1 ("Ezek" 1 1 15)  :lesson2 ("Phil" 2)))
    (4 26
     :dominical "d"
     :mattins  (:lesson1 ("1 Sam" 17 1 31)  :lesson2 ("Luke" 19 11 28))
     :evensong (:lesson1 ("1 Sam" 17 31 55)  :lesson2 ("Phil" 3)))
    (4 27
     :dominical "e"
     :mattins  (:lesson1 (("1 Sam" 17 55 nil) ("1 Sam" 18 1 17))  :lesson2 ("Luke" 19 28 48))
     :evensong (:lesson1 ("1 Sam" 19)  :lesson2 ("Phil" 4)))
    (4 28
     :dominical "f"
     :mattins  (:lesson1 ("1 Sam" 20 1 18)  :lesson2 ("Luke" 20 1 27))
     :evensong (:lesson1 ("1 Sam" 20 18 42)  :lesson2 ("Col" 1 1 21)))
    (4 29
     :dominical "g"
     :mattins  (:lesson1 ("1 Sam" 21)  :lesson2 (("Luke" 20 27 nil) ("Luke" 21 1 5)))
     :evensong (:lesson1 ("1 Sam" 22)  :lesson2 (("Col" 1 21 nil) ("Col" 2 1 8))))
    (4 30
     :dominical "A"
     :mattins  (:lesson1 ("1 Sam" 23)  :lesson2 ("Luke" 21 5 38))
     :evensong (:lesson1 (("1 Sam" 24) ("1 Sam" 25 1 1))  :lesson2 ("Col" 2 8 23)))

  ;; ---- May ----
    (5 1
     :dominical "b"
     :feast "St. Philip and St. James, Ap."
     :mattins  (:lesson1 ("Isa" 61)  :lesson2 ("John" 1 43 51))
     :evensong (:lesson1 ("Zech" 4)  :lesson2 ("Col" 3 1 18)))
    (5 2
     :dominical "c"
     :mattins  (:lesson1 ("1 Sam" 26)  :lesson2 ("Luke" 22 1 31))
     :evensong (:lesson1 ("1 Sam" 28 3 25)  :lesson2 (("Col" 3 18 nil) ("Col" 4 1 7))))
    (5 3
     :dominical "d"
     :feast "Invent. of Cross"
     :mattins  (:lesson1 ("1 Sam" 31)  :lesson2 ("Luke" 22 31 54))
     :evensong (:lesson1 ("2 Sam" 1)  :lesson2 ("Col" 4 7 18)))
    (5 4
     :dominical "e"
     :mattins  (:lesson1 ("2 Sam" 3 17 39)  :lesson2 ("Luke" 22 54 71))
     :evensong (:lesson1 ("2 Sam" 4)  :lesson2 ("1 Thess" 1)))
    (5 5
     :dominical "f"
     :mattins  (:lesson1 ("2 Sam" 6)  :lesson2 ("Luke" 23 1 26))
     :evensong (:lesson1 ("2 Sam" 7 1 18)  :lesson2 ("1 Thess" 2)))
    (5 6
     :dominical "g"
     :feast "St. John, E. ante Port. Lat."
     :mattins  (:lesson1 ("2 Sam" 7 18 29)  :lesson2 ("Luke" 23 26 50))
     :evensong (:lesson1 ("2 Sam" 9)  :lesson2 ("1 Thess" 3)))
    (5 7
     :dominical "A"
     :mattins  (:lesson1 ("2 Sam" 11)  :lesson2 (("Luke" 23 50 nil) ("Luke" 24 1 13)))
     :evensong (:lesson1 ("2 Sam" 12 1 24)  :lesson2 ("1 Thess" 4)))
    (5 8
     :dominical "b"
     :mattins  (:lesson1 (("2 Sam" 13 39 nil) ("2 Sam" 14 1 26))  :lesson2 ("Luke" 24 13 53))
     :evensong (:lesson1 ("2 Sam" 15 1 16)  :lesson2 ("1 Thess" 5)))
    (5 9
     :dominical "c"
     :mattins  (:lesson1 ("2 Sam" 15 16 37)  :lesson2 ("John" 1 1 29))
     :evensong (:lesson1 ("2 Sam" 16 1 15)  :lesson2 ("2 Thess" 1)))
    (5 10
     :dominical "d"
     :mattins  (:lesson1 (("2 Sam" 16 15 nil) ("2 Sam" 17 1 24))  :lesson2 ("John" 1 29 51))
     :evensong (:lesson1 (("2 Sam" 17 24 nil) ("2 Sam" 18 1 18))  :lesson2 ("2 Thess" 2)))
    (5 11
     :dominical "e"
     :mattins  (:lesson1 ("2 Sam" 18 18 33)  :lesson2 ("John" 2))
     :evensong (:lesson1 ("2 Sam" 19 1 24)  :lesson2 ("2 Thess" 3)))
    (5 12
     :dominical "f"
     :mattins  (:lesson1 ("2 Sam" 19 24 43)  :lesson2 ("John" 3 1 22))
     :evensong (:lesson1 ("2 Sam" 21 1 15)  :lesson2 ("1 Tim" 1 1 17)))
    (5 13
     :dominical "g"
     :mattins  (:lesson1 ("2 Sam" 23 1 24)  :lesson2 ("John" 3 22 36))
     :evensong (:lesson1 ("2 Sam" 24)  :lesson2 (("1 Tim" 1 18 nil) ("1 Tim" 2))))
    (5 14
     :dominical "A"
     :mattins  (:lesson1 ("1 Kgs" 1 1 28)  :lesson2 ("John" 4 1 31))
     :evensong (:lesson1 ("1 Kgs" 1 28 49)  :lesson2 ("1 Tim" 3)))
    (5 15
     :dominical "b"
     :mattins  (:lesson1 ("1 Chr" 29 10 30)  :lesson2 ("John" 4 31 54))
     :evensong (:lesson1 ("1 Kgs" 3)  :lesson2 ("1 Tim" 4)))
    (5 16
     :dominical "c"
     :mattins  (:lesson1 ("1 Kgs" 4 20 34)  :lesson2 ("John" 5 1 24))
     :evensong (:lesson1 ("1 Kgs" 5)  :lesson2 ("1 Tim" 5)))
    (5 17
     :dominical "d"
     :mattins  (:lesson1 ("1 Kgs" 6 1 15)  :lesson2 ("John" 5 24 47))
     :evensong (:lesson1 ("1 Kgs" 8 1 22)  :lesson2 ("1 Tim" 6)))
    (5 18
     :dominical "e"
     :mattins  (:lesson1 ("1 Kgs" 8 22 54)  :lesson2 ("John" 6 1 22))
     :evensong (:lesson1 (("1 Kgs" 8 54 nil) ("1 Kgs" 9 1 10))  :lesson2 ("2 Tim" 1)))
    (5 19
     :dominical "f"
     :feast "Dunstan, Archbp."
     :mattins  (:lesson1 ("1 Kgs" 10)  :lesson2 ("John" 6 22 41))
     :evensong (:lesson1 ("1 Kgs" 11 1 26)  :lesson2 ("2 Tim" 2)))
    (5 20
     :dominical "g"
     :mattins  (:lesson1 ("1 Kgs" 11 26 43)  :lesson2 ("John" 6 41 71))
     :evensong (:lesson1 ("1 Kgs" 12 1 25)  :lesson2 ("2 Tim" 3)))
    (5 21
     :dominical "A"
     :mattins  (:lesson1 (("1 Kgs" 12 25 nil) ("1 Kgs" 13 1 11))  :lesson2 ("John" 7 1 25))
     :evensong (:lesson1 ("1 Kgs" 13 11 34)  :lesson2 ("2 Tim" 4)))
    (5 22
     :dominical "b"
     :mattins  (:lesson1 ("1 Kgs" 14 1 21)  :lesson2 ("John" 7 25 53))
     :evensong (:lesson1 (("1 Kgs" 15 25 nil) ("1 Kgs" 16 1 8))  :lesson2 ("Titus" 1)))
    (5 23
     :dominical "c"
     :mattins  (:lesson1 ("1 Kgs" 16 8 34)  :lesson2 ("John" 8 1 31))
     :evensong (:lesson1 ("1 Kgs" 17)  :lesson2 ("Titus" 2)))
    (5 24
     :dominical "d"
     :mattins  (:lesson1 ("1 Kgs" 18 1 17)  :lesson2 ("John" 8 31 59))
     :evensong (:lesson1 ("1 Kgs" 18 17 46)  :lesson2 ("Titus" 3)))
    (5 25
     :dominical "e"
     :mattins  (:lesson1 ("1 Kgs" 19)  :lesson2 ("John" 9 1 39))
     :evensong (:lesson1 ("1 Kgs" 21)  :lesson2 ("Phlm" 1)))
    (5 26
     :dominical "f"
     :feast "Augustine, Archbp."
     :mattins  (:lesson1 ("1 Kgs" 22 1 41)  :lesson2 (("John" 9 39 nil) ("John" 10 1 22)))
     :evensong (:lesson1 ("2 Kgs" 1)  :lesson2 ("Heb" 1)))
    (5 27
     :dominical "g"
     :feast "Ven. Bede, Presb."
     :mattins  (:lesson1 ("2 Kgs" 2)  :lesson2 ("John" 10 22 42))
     :evensong (:lesson1 ("2 Kgs" 4 8 44)  :lesson2 (("Heb" 2) ("Heb" 3 1 7))))
    (5 28
     :dominical "A"
     :mattins  (:lesson1 ("2 Kgs" 5)  :lesson2 ("John" 11 1 17))
     :evensong (:lesson1 ("2 Kgs" 6 1 24)  :lesson2 (("Heb" 3 7 nil) ("Heb" 4 1 14))))
    (5 29
     :dominical "b"
     :mattins  (:lesson1 ("2 Kgs" 6 24 33)  :lesson2 ("John" 11 17 47))
     :evensong (:lesson1 ("2 Kgs" 7)  :lesson2 (("Heb" 4 14 nil) ("Heb" 5))))
    (5 30
     :dominical "c"
     :mattins  (:lesson1 ("2 Kgs" 8 1 16)  :lesson2 (("John" 11 47 nil) ("John" 12 1 20)))
     :evensong (:lesson1 ("2 Kgs" 9)  :lesson2 ("Heb" 6)))
    (5 31
     :dominical "d"
     :mattins  (:lesson1 ("2 Kgs" 10 1 18)  :lesson2 ("John" 12 20 50))
     :evensong (:lesson1 ("2 Kgs" 10 18 36)  :lesson2 ("Heb" 7)))

  ;; ---- June ----
    (6 1
     :dominical "e"
     :feast "Nicomede, M."
     :mattins  (:lesson1 ("2 Kgs" 13)  :lesson2 ("John" 13 1 21))
     :evensong (:lesson1 ("2 Kgs" 17 1 24)  :lesson2 ("Heb" 8)))
    (6 2
     :dominical "f"
     :mattins  (:lesson1 ("2 Kgs" 17 24 41)  :lesson2 ("John" 13 21 38))
     :evensong (:lesson1 ("2 Chr" 12)  :lesson2 ("Heb" 9)))
    (6 3
     :dominical "g"
     :mattins  (:lesson1 ("2 Chr" 13)  :lesson2 ("John" 14))
     :evensong (:lesson1 ("2 Chr" 14)  :lesson2 ("Heb" 10 1 19)))
    (6 4
     :dominical "A"
     :mattins  (:lesson1 ("2 Chr" 15)  :lesson2 ("John" 15))
     :evensong (:lesson1 (("2 Chr" 16) ("2 Chr" 17 1 14))  :lesson2 ("Heb" 10 19 39)))
    (6 5
     :dominical "b"
     :feast "Boniface, Bishop."
     :mattins  (:lesson1 ("2 Chr" 19)  :lesson2 ("John" 16 1 16))
     :evensong (:lesson1 ("2 Chr" 20 1 31)  :lesson2 ("Heb" 11 1 17)))
    (6 6
     :dominical "c"
     :mattins  (:lesson1 (("2 Chr" 20 31 37) ("2 Chr" 21))  :lesson2 ("John" 16 16 33))
     :evensong (:lesson1 ("2 Chr" 22)  :lesson2 ("Heb" 11 17 40)))
    (6 7
     :dominical "d"
     :mattins  (:lesson1 ("2 Chr" 23)  :lesson2 ("John" 17))
     :evensong (:lesson1 ("2 Chr" 24)  :lesson2 ("Heb" 12)))
    (6 8
     :dominical "e"
     :mattins  (:lesson1 ("2 Chr" 25)  :lesson2 ("John" 18 1 28))
     :evensong (:lesson1 (("2 Chr" 26) ("2 Chr" 27))  :lesson2 ("Heb" 13)))
    (6 9
     :dominical "f"
     :mattins  (:lesson1 ("2 Chr" 28)  :lesson2 ("John" 18 28 40))
     :evensong (:lesson1 ("2 Kgs" 18 1 9)  :lesson2 ("Jas" 1)))
    (6 10
     :dominical "g"
     :mattins  (:lesson1 ("2 Chr" 29 3 21)  :lesson2 ("John" 19 1 25))
     :evensong (:lesson1 (("2 Chr" 30) ("2 Chr" 31 1 1))  :lesson2 ("Jas" 2)))
    (6 11
     :dominical "A"
     :feast "St. Barnabas, Ap."
     :mattins  (:lesson1 ("Deut" 33 1 12)  :lesson2 ("John" 4 31 54))
     :evensong (:lesson1 ("Nah" 1)  :lesson2 ("Acts" 14 8 28)))
    (6 12
     :dominical "b"
     :mattins  (:lesson1 ("2 Kgs" 18 13 37)  :lesson2 ("John" 19 25 42))
     :evensong (:lesson1 ("2 Kgs" 19 1 20)  :lesson2 ("Jas" 3)))
    (6 13
     :dominical "c"
     :mattins  (:lesson1 ("2 Kgs" 19 20 37)  :lesson2 ("John" 20 1 19))
     :evensong (:lesson1 ("2 Kgs" 20)  :lesson2 ("Jas" 4)))
    (6 14
     :dominical "d"
     :mattins  (:lesson1 ("Isa" 38 9 21)  :lesson2 ("John" 20 19 31))
     :evensong (:lesson1 ("2 Chr" 33)  :lesson2 ("Jas" 5)))
    (6 15
     :dominical "e"
     :mattins  (:lesson1 ("2 Kgs" 22)  :lesson2 ("John" 21))
     :evensong (:lesson1 ("2 Kgs" 23 1 21)  :lesson2 ("1 Pet" 1 1 22)))
    (6 16
     :dominical "f"
     :mattins  (:lesson1 (("2 Kgs" 23 21 37) ("2 Kgs" 24 1 8))  :lesson2 ("Acts" 1))
     :evensong (:lesson1 (("2 Kgs" 24 8 20) ("2 Kgs" 25 1 8))  :lesson2 (("1 Pet" 1 22 25) ("1 Pet" 2 1 11))))
    (6 17
     :dominical "g"
     :feast "St. Alban, Mart."
     :mattins  (:lesson1 ("2 Kgs" 25 8 30)  :lesson2 ("Acts" 2 1 22))
     :evensong (:lesson1 (("Ezra" 1) ("Ezra" 3))  :lesson2 (("1 Pet" 2 11 25) ("1 Pet" 3 1 8))))
    (6 18
     :dominical "A"
     :mattins  (:lesson1 ("Ezra" 4)  :lesson2 ("Acts" 2 22 47))
     :evensong (:lesson1 ("Ezra" 5)  :lesson2 (("1 Pet" 3 8 22) ("1 Pet" 4 1 7))))
    (6 19
     :dominical "b"
     :mattins  (:lesson1 ("Ezra" 7)  :lesson2 ("Acts" 3))
     :evensong (:lesson1 ("Ezra" 8 15 36)  :lesson2 ("1 Pet" 4 7 19)))
    (6 20
     :dominical "c"
     :feast "Tr. of King Edw."
     :mattins  (:lesson1 ("Ezra" 9)  :lesson2 ("Acts" 4 1 32))
     :evensong (:lesson1 ("Ezra" 10 1 20)  :lesson2 ("1 Pet" 5)))
    (6 21
     :dominical "d"
     :mattins  (:lesson1 ("Neh" 1)  :lesson2 (("Acts" 4 32 37) ("Acts" 5 1 17)))
     :evensong (:lesson1 ("Neh" 2)  :lesson2 ("2 Pet" 1)))
    (6 22
     :dominical "e"
     :mattins  (:lesson1 ("Neh" 4)  :lesson2 ("Acts" 5 17 42))
     :evensong (:lesson1 ("Neh" 5)  :lesson2 ("2 Pet" 2)))
    (6 23
     :dominical "f"
     :feast "Fast."
     :mattins  (:lesson1 (("Neh" 6) ("Neh" 7 1 5))  :lesson2 ("Acts" 6))
     :evensong (:lesson1 (("Neh" 7 73 nil) ("Neh" 8))  :lesson2 ("2 Pet" 3)))
    (6 24
     :dominical "g"
     :feast "St. John Baptist"
     :mattins  (:lesson1 ("Mal" 3 1 7)  :lesson2 ("Matt" 3))
     :evensong (:lesson1 ("Mal" 4)  :lesson2 ("Matt" 14 1 13)))
    (6 25
     :dominical "A"
     :mattins  (:lesson1 ("Neh" 13 1 15)  :lesson2 ("Acts" 7 1 35))
     :evensong (:lesson1 ("Neh" 13 15 31)  :lesson2 ("1 John" 1)))
    (6 26
     :dominical "b"
     :mattins  (:lesson1 ("Esth" 1)  :lesson2 (("Acts" 7 35 60) ("Acts" 8 1 5)))
     :evensong (:lesson1 (("Esth" 2 15 23) ("Esth" 3))  :lesson2 ("1 John" 2 1 15)))
    (6 27
     :dominical "c"
     :mattins  (:lesson1 ("Esth" 4)  :lesson2 ("Acts" 8 5 26))
     :evensong (:lesson1 ("Esth" 5)  :lesson2 ("1 John" 2 15 29)))
    (6 28
     :dominical "d"
     :feast "Fast."
     :mattins  (:lesson1 ("Esth" 6)  :lesson2 ("Acts" 8 26 40))
     :evensong (:lesson1 ("Esth" 7)  :lesson2 ("1 John" 3 1 16)))
    (6 29
     :dominical "e"
     :feast "St. Peter, Apostle."
     :mattins  (:lesson1 ("Ezek" 3 4 15)  :lesson2 ("John" 21 15 23))
     :evensong (:lesson1 ("Zech" 3)  :lesson2 ("Acts" 4 8 23)))
    (6 30
     :dominical "f"
     :mattins  (:lesson1 ("Job" 1)  :lesson2 ("Acts" 9 1 23))
     :evensong (:lesson1 ("Job" 2)  :lesson2 (("1 John" 3 16 24) ("1 John" 4 1 7))))

  ;; ---- July ----
    (7 1
     :dominical "g"
     :mattins  (:lesson1 ("Job" 3)  :lesson2 ("Acts" 9 23 43))
     :evensong (:lesson1 ("Job" 4)  :lesson2 ("1 John" 4 7 21)))
    (7 2
     :dominical "A"
     :feast "Visitation of the Blessed Virgin Mary"
     :mattins  (:lesson1 ("Job" 5)  :lesson2 ("Acts" 10 1 24))
     :evensong (:lesson1 ("Job" 6)  :lesson2 ("1 John" 5)))
    (7 3
     :dominical "b"
     :mattins  (:lesson1 ("Job" 7)  :lesson2 ("Acts" 10 24 48))
     :evensong (:lesson1 ("Job" 9)  :lesson2 ("2 John" 1)))
    (7 4
     :dominical "c"
     :feast "Tr. of St. Martin"
     :mattins  (:lesson1 ("Job" 10)  :lesson2 ("Acts" 11))
     :evensong (:lesson1 ("Job" 11)  :lesson2 ("3 John" 1)))
    (7 5
     :dominical "d"
     :mattins  (:lesson1 ("Job" 12)  :lesson2 ("Acts" 12))
     :evensong (:lesson1 ("Job" 13)  :lesson2 ("Jude" 1)))
    (7 6
     :dominical "e"
     :mattins  (:lesson1 ("Job" 14)  :lesson2 ("Acts" 13 1 26))
     :evensong (:lesson1 ("Job" 16)  :lesson2 ("Matt" 1 18 25)))
    (7 7
     :dominical "f"
     :mattins  (:lesson1 ("Job" 17)  :lesson2 ("Acts" 13 26 52))
     :evensong (:lesson1 ("Job" 19)  :lesson2 ("Matt" 2)))
    (7 8
     :dominical "g"
     :mattins  (:lesson1 ("Job" 21)  :lesson2 ("Acts" 14))
     :evensong (:lesson1 ("Job" 22 12 29)  :lesson2 ("Matt" 3)))
    (7 9
     :dominical "A"
     :mattins  (:lesson1 ("Job" 23)  :lesson2 ("Acts" 15 1 30))
     :evensong (:lesson1 ("Job" 24)  :lesson2 ("Matt" 4 1 23)))
    (7 10
     :dominical "b"
     :mattins  (:lesson1 (("Job" 25) ("Job" 26))  :lesson2 (("Acts" 15 30 41) ("Acts" 16 1 16)))
     :evensong (:lesson1 ("Job" 27)  :lesson2 (("Matt" 4 23 25) ("Matt" 5 1 13))))
    (7 11
     :dominical "c"
     :mattins  (:lesson1 ("Job" 28)  :lesson2 ("Acts" 16 16 40))
     :evensong (:lesson1 (("Job" 29) ("Job" 30 1 1))  :lesson2 ("Matt" 5 13 33)))
    (7 12
     :dominical "d"
     :mattins  (:lesson1 ("Job" 30 12 27)  :lesson2 ("Acts" 17 1 16))
     :evensong (:lesson1 ("Job" 34 13 37)  :lesson2 ("Matt" 5 33 48)))
    (7 13
     :dominical "e"
     :mattins  (:lesson1 ("Job" 32)  :lesson2 ("Acts" 17 16 34))
     :evensong (:lesson1 ("Job" 38 1 39)  :lesson2 ("Matt" 6 1 19)))
    (7 14
     :dominical "f"
     :mattins  (:lesson1 (("Job" 38 39 41) ("Job" 39))  :lesson2 ("Acts" 18 1 24))
     :evensong (:lesson1 ("Job" 40)  :lesson2 (("Matt" 6 19 34) ("Matt" 7 1 7))))
    (7 15
     :dominical "g"
     :feast "Swithun, Bishop"
     :mattins  (:lesson1 ("Job" 41)  :lesson2 (("Acts" 18 24 nil) ("Acts" 19 1 21)))
     :evensong (:lesson1 ("Job" 42)  :lesson2 ("Matt" 7 7 29)))
    (7 16
     :dominical "A"
     :mattins  (:lesson1 ("Prov" 1 1 20)  :lesson2 ("Acts" 19 21 41))
     :evensong (:lesson1 ("Prov" 1 20 33)  :lesson2 ("Matt" 8 1 18)))
    (7 17
     :dominical "b"
     :mattins  (:lesson1 ("Prov" 2)  :lesson2 ("Acts" 20 1 17))
     :evensong (:lesson1 ("Prov" 3 1 27)  :lesson2 ("Matt" 8 18 34)))
    (7 18
     :dominical "c"
     :mattins  (:lesson1 (("Prov" 3 27 35) ("Prov" 4 1 20))  :lesson2 ("Acts" 20 17 38))
     :evensong (:lesson1 (("Prov" 4 20 nil) ("Prov" 5 1 15))  :lesson2 ("Matt" 9 1 18)))
    (7 19
     :dominical "d"
     :mattins  (:lesson1 ("Prov" 5 15 23)  :lesson2 ("Acts" 21 1 17))
     :evensong (:lesson1 ("Prov" 6 1 20)  :lesson2 ("Matt" 9 18 38)))
    (7 20
     :dominical "e"
     :feast "Margaret V. & M."
     :mattins  (:lesson1 ("Prov" 7)  :lesson2 ("Acts" 21 17 37))
     :evensong (:lesson1 ("Prov" 8)  :lesson2 ("Matt" 10 1 24)))
    (7 21
     :dominical "f"
     :mattins  (:lesson1 ("Prov" 9)  :lesson2 (("Acts" 21 37 40) ("Acts" 22 1 23)))
     :evensong (:lesson1 ("Prov" 10 16 32)  :lesson2 ("Matt" 10 24 42)))
    (7 22
     :dominical "g"
     :feast "St. Mary Magdalen"
     :mattins  (:lesson1 ("Prov" 11 1 15)  :lesson2 (("Acts" 22 23 30) ("Acts" 23 1 12)))
     :evensong (:lesson1 ("Prov" 11 15 31)  :lesson2 ("Matt" 11)))
    (7 23
     :dominical "A"
     :mattins  (:lesson1 ("Prov" 12 10 28)  :lesson2 ("Acts" 23 12 35))
     :evensong (:lesson1 ("Prov" 13)  :lesson2 ("Matt" 12 1 22)))
    (7 24
     :dominical "b"
     :feast "Fast."
     :mattins  (:lesson1 ("Prov" 14 9 28)  :lesson2 ("Acts" 24))
     :evensong (:lesson1 (("Prov" 14 28 35) ("Prov" 15 1 18))  :lesson2 ("Matt" 12 22 50)))
    (7 25
     :dominical "c"
     :feast "St. James, Apostle"
     :mattins  (:lesson1 ("2 Kgs" 1 1 16)  :lesson2 ("Luke" 9 51 57))
     :evensong (:lesson1 ("Jer" 26 8 16)  :lesson2 ("Matt" 13 1 24)))
    (7 26
     :dominical "d"
     :feast "St. Anne"
     :mattins  (:lesson1 ("Prov" 15 18 33)  :lesson2 ("Acts" 25))
     :evensong (:lesson1 ("Prov" 16 1 20)  :lesson2 ("Matt" 13 24 53)))
    (7 27
     :dominical "e"
     :mattins  (:lesson1 (("Prov" 16 31 nil) ("Prov" 17 1 18))  :lesson2 ("Acts" 26))
     :evensong (:lesson1 ("Prov" 18 10 24)  :lesson2 (("Matt" 13 53 nil) ("Matt" 14 1 13))))
    (7 28
     :dominical "f"
     :mattins  (:lesson1 ("Prov" 19 13 29)  :lesson2 ("Acts" 27))
     :evensong (:lesson1 ("Prov" 20 1 23)  :lesson2 ("Matt" 14 13 36)))
    (7 29
     :dominical "g"
     :mattins  (:lesson1 ("Prov" 21 1 17)  :lesson2 ("Acts" 28 1 17))
     :evensong (:lesson1 ("Prov" 22 1 17)  :lesson2 ("Matt" 15 1 21)))
    (7 30
     :dominical "A"
     :mattins  (:lesson1 ("Prov" 23 10 35)  :lesson2 ("Acts" 28 17 31))
     :evensong (:lesson1 ("Prov" 24 21 34)  :lesson2 ("Matt" 15 21 39)))
    (7 31
     :dominical "b"
     :mattins  (:lesson1 ("Prov" 25)  :lesson2 ("Rom" 1))
     :evensong (:lesson1 ("Prov" 26 1 21)  :lesson2 ("Matt" 16 1 24)))

  ;; ---- August ----
    (8 1
     :dominical "c"
     :feast "Lammas Day"
     :mattins  (:lesson1 ("Prov" 27 1 23)  :lesson2 ("Rom" 2 1 17))
     :evensong (:lesson1 ("Prov" 28 1 15)  :lesson2 (("Matt" 16 24 28) ("Matt" 17 1 14))))
    (8 2
     :dominical "d"
     :mattins  (:lesson1 ("Prov" 30 1 18)  :lesson2 ("Rom" 2 17 nil))
     :evensong (:lesson1 ("Prov" 31 10 nil)  :lesson2 ("Matt" 17 14 nil)))
    (8 3
     :dominical "e"
     :mattins  (:lesson1 ("Eccl" 1)  :lesson2 ("Rom" 3))
     :evensong (:lesson1 ("Eccl" 2 1 12)  :lesson2 ("Matt" 18 1 21)))
    (8 4
     :dominical "f"
     :mattins  (:lesson1 ("Eccl" 3)  :lesson2 ("Rom" 4))
     :evensong (:lesson1 ("Eccl" 4)  :lesson2 (("Matt" 18 21 nil) ("Matt" 19 1 3))))
    (8 5
     :dominical "g"
     :mattins  (:lesson1 ("Eccl" 5)  :lesson2 ("Rom" 5))
     :evensong (:lesson1 ("Eccl" 6)  :lesson2 ("Matt" 19 3 27)))
    (8 6
     :dominical "A"
     :feast "Transfiguration"
     :mattins  (:lesson1 ("Eccl" 7)  :lesson2 ("Rom" 6))
     :evensong (:lesson1 ("Eccl" 8)  :lesson2 (("Matt" 19 27 nil) ("Matt" 20 1 17))))
    (8 7
     :dominical "b"
     :feast "Name of Jesus"
     :mattins  (:lesson1 ("Eccl" 9)  :lesson2 ("Rom" 7))
     :evensong (:lesson1 ("Eccl" 11)  :lesson2 ("Matt" 20 17 nil)))
    (8 8
     :dominical "c"
     :mattins  (:lesson1 ("Eccl" 12)  :lesson2 ("Rom" 8 1 18))
     :evensong (:lesson1 ("Jer" 1)  :lesson2 ("Matt" 21 1 23)))
    (8 9
     :dominical "d"
     :mattins  (:lesson1 ("Jer" 2 1 14)  :lesson2 ("Rom" 8 18 nil))
     :evensong (:lesson1 ("Jer" 5 1 19)  :lesson2 ("Matt" 21 23 nil)))
    (8 10
     :dominical "e"
     :feast "St. Lawrence, M."
     :mattins  (:lesson1 ("Jer" 5 19 nil)  :lesson2 ("Rom" 9 1 19))
     :evensong (:lesson1 ("Jer" 6 1 22)  :lesson2 ("Matt" 22 1 15)))
    (8 11
     :dominical "f"
     :mattins  (:lesson1 ("Ezek" 7 1 17)  :lesson2 ("Rom" 9 19 nil))
     :evensong (:lesson1 ("Jer" 8 4 nil)  :lesson2 ("Matt" 22 15 41)))
    (8 12
     :dominical "g"
     :mattins  (:lesson1 ("Ezek" 9 1 17)  :lesson2 ("Rom" 10))
     :evensong (:lesson1 ("Jer" 13 8 24)  :lesson2 (("Matt" 22 41 46) ("Matt" 23 1 13))))
    (8 13
     :dominical "A"
     :mattins  (:lesson1 ("Ezek" 15)  :lesson2 ("Rom" 11 25 nil))
     :evensong (:lesson1 ("Jer" 17 1 19)  :lesson2 ("Matt" 23 13 nil)))
    (8 14
     :dominical "b"
     :mattins  (:lesson1 ("Ezek" 18 1 18)  :lesson2 ("Rom" 11 25 nil))
     :evensong (:lesson1 ("Jer" 19)  :lesson2 ("Matt" 24 1 29)))
    (8 15
     :dominical "c"
     :mattins  (:lesson1 ("Ezek" 21)  :lesson2 ("Rom" 12))
     :evensong (:lesson1 ("Jer" 22 1 13)  :lesson2 ("Matt" 24 29 nil)))
    (8 16
     :dominical "d"
     :mattins  (:lesson1 ("Ezek" 22 13 nil)  :lesson2 ("Rom" 13))
     :evensong (:lesson1 ("Jer" 23 1 16)  :lesson2 ("Matt" 25 1 31)))
    (8 17
     :dominical "e"
     :mattins  (:lesson1 ("Ezek" 24)  :lesson2 (("Rom" 14) ("Rom" 15 1 8)))
     :evensong (:lesson1 ("Jer" 25 1 15)  :lesson2 ("Matt" 25 31 nil)))
    (8 18
     :dominical "f"
     :mattins  (:lesson1 ("Ezek" 26)  :lesson2 ("Rom" 15 8 nil))
     :evensong (:lesson1 ("Jer" 28)  :lesson2 ("Matt" 26 1 31)))
    (8 19
     :dominical "g"
     :mattins  (:lesson1 ("Ezek" 29 4 20)  :lesson2 ("Rom" 16))
     :evensong (:lesson1 ("Jer" 30)  :lesson2 ("Matt" 26 31 57)))
    (8 20
     :dominical "A"
     :mattins  (:lesson1 ("Ezek" 31 1 15)  :lesson2 ("1 Cor" 1 1 26))
     :evensong (:lesson1 ("Jer" 31 15 38)  :lesson2 ("Matt" 26 57 nil)))
    (8 21
     :dominical "b"
     :mattins  (:lesson1 ("Ezek" 33 1 14)  :lesson2 (("1 Cor" 1 26 nil) ("1 Cor" 2)))
     :evensong (:lesson1 ("Jer" 33 14 nil)  :lesson2 ("Matt" 27 1 27)))
    (8 22
     :dominical "c"
     :mattins  (:lesson1 ("Ezek" 35)  :lesson2 ("1 Cor" 3))
     :evensong (:lesson1 ("Jer" 36 1 14)  :lesson2 ("Matt" 27 27 57)))
    (8 23
     :dominical "d"
     :feast "Fast."
     :mattins  (:lesson1 ("Ezek" 36 14 nil)  :lesson2 ("1 Cor" 4 1 18))
     :evensong (:lesson1 ("Jer" 38 1 14)  :lesson2 ("Matt" 27 57 nil)))
    (8 24
     :dominical "e"
     :feast "St. Bartholomew"
     :mattins  (:lesson1 ("Gen" 28 10 18)  :lesson2 (("1 Cor" 4 18 nil) ("1 Cor" 5)))
     :evensong (:lesson1 ("Deut" 18 15 nil)  :lesson2 ("Matt" 28)))
    (8 25
     :dominical "f"
     :mattins  (:lesson1 ("Jer" 38 14 nil)  :lesson2 ("1 Cor" 6))
     :evensong (:lesson1 ("Jer" 39)  :lesson2 ("Mark" 1 1 21)))
    (8 26
     :dominical "g"
     :mattins  (:lesson1 ("Jer" 50 1 21)  :lesson2 ("1 Cor" 7 1 25))
     :evensong (:lesson1 ("Jer" 51 54 nil)  :lesson2 ("Mark" 1 21 nil)))
    (8 27
     :dominical "A"
     :mattins  (:lesson1 ("Ezek" 1 1 15)  :lesson2 ("1 Cor" 7 25 nil))
     :evensong (:lesson1 ("Ezek" 1 15 nil)  :lesson2 ("Mark" 2 1 23)))
    (8 28
     :dominical "b"
     :feast "St. Augustine, B."
     :mattins  (:lesson1 ("Ezek" 2)  :lesson2 ("1 Cor" 8))
     :evensong (:lesson1 ("Ezek" 3 1 15)  :lesson2 (("Mark" 2 23 28) ("Mark" 3 1 13))))
    (8 29
     :dominical "c"
     :feast "Beheading of St. John Baptist"
     :mattins  (:lesson1 ("Ezek" 3 15 nil)  :lesson2 ("1 Cor" 9))
     :evensong (:lesson1 ("Ezek" 8)  :lesson2 ("Mark" 3 13 nil)))
    (8 30
     :dominical "d"
     :mattins  (:lesson1 ("Ezek" 9)  :lesson2 (("1 Cor" 10) ("1 Cor" 11 1 1)))
     :evensong (:lesson1 ("Ezek" 11 14 nil)  :lesson2 ("Mark" 4 1 35)))
    (8 31
     :dominical "e"
     :mattins  (:lesson1 ("Ezek" 12 17 nil)  :lesson2 ("1 Cor" 11 2 17))
     :evensong (:lesson1 ("Ezek" 13 1 17)  :lesson2 (("Mark" 4 35 41) ("Mark" 5 1 21))))

  ;; ---- September ----
    (9 1
     :dominical "f"
     :feast "Giles, Abbot."
     :mattins  (:lesson1 ("Ezek" 13 17 23)  :lesson2 ("1 Cor" 11 17 34))
     :evensong (:lesson1 ("Ezek" 14 1 12)  :lesson2 ("Mark" 5 21 43)))
    (9 2
     :dominical "g"
     :mattins  (:lesson1 ("Ezek" 14 12 23)  :lesson2 ("1 Cor" 12 1 28))
     :evensong (:lesson1 ("Ezek" 16 44 63)  :lesson2 ("Mark" 6 1 14)))
    (9 3
     :dominical "A"
     :mattins  (:lesson1 ("Ezek" 18 1 19)  :lesson2 (("1 Cor" 12 28 nil) ("1 Cor" 13)))
     :evensong (:lesson1 ("Ezek" 18 19 32)  :lesson2 ("Mark" 6 14 30)))
    (9 4
     :dominical "b"
     :mattins  (:lesson1 ("Ezek" 20 1 18)  :lesson2 ("1 Cor" 14 1 20))
     :evensong (:lesson1 ("Ezek" 20 18 33)  :lesson2 ("Mark" 6 30 56)))
    (9 5
     :dominical "c"
     :mattins  (:lesson1 ("Ezek" 20 33 44)  :lesson2 ("1 Cor" 14 20 40))
     :evensong (:lesson1 ("Ezek" 22 23 31)  :lesson2 ("Mark" 7 1 24)))
    (9 6
     :dominical "d"
     :mattins  (:lesson1 ("Ezek" 24 15 27)  :lesson2 ("1 Cor" 15 1 35))
     :evensong (:lesson1 ("Ezek" 26)  :lesson2 (("Mark" 7 24 nil) ("Mark" 8 1 10))))
    (9 7
     :dominical "e"
     :feast "Enurchus, Bishop."
     :mattins  (:lesson1 ("Ezek" 27 1 26)  :lesson2 ("1 Cor" 15 35 58))
     :evensong (:lesson1 ("Ezek" 27 26 36)  :lesson2 (("Mark" 8 10 nil) ("Mark" 9 1 2))))
    (9 8
     :dominical "f"
     :feast "Nat. of Vir. Mary."
     :mattins  (:lesson1 ("Ezek" 28 1 20)  :lesson2 ("1 Cor" 16))
     :evensong (:lesson1 ("Ezek" 31)  :lesson2 ("Mark" 9 2 30)))
    (9 9
     :dominical "g"
     :mattins  (:lesson1 ("Ezek" 32 1 17)  :lesson2 ("2 Cor" 1 1 23))
     :evensong (:lesson1 ("Ezek" 33 1 21)  :lesson2 ("Mark" 9 30 50)))
    (9 10
     :dominical "A"
     :mattins  (:lesson1 ("Ezek" 33 21 33)  :lesson2 (("2 Cor" 1 23 nil) ("2 Cor" 2 1 14)))
     :evensong (:lesson1 ("Ezek" 34 1 17)  :lesson2 ("Mark" 10 1 32)))
    (9 11
     :dominical "b"
     :mattins  (:lesson1 ("Ezek" 34 17 31)  :lesson2 (("2 Cor" 2 14 nil) ("2 Cor" 3)))
     :evensong (:lesson1 ("Ezek" 36 16 33)  :lesson2 ("Mark" 10 32 52)))
    (9 12
     :dominical "c"
     :mattins  (:lesson1 ("Ezek" 37 1 15)  :lesson2 ("2 Cor" 4))
     :evensong (:lesson1 ("Ezek" 37 15 28)  :lesson2 ("Mark" 11 1 27)))
    (9 13
     :dominical "d"
     :mattins  (:lesson1 ("Ezek" 47 1 13)  :lesson2 ("2 Cor" 5))
     :evensong (:lesson1 ("Dan" 1)  :lesson2 (("Mark" 11 27 nil) ("Mark" 12 1 13))))
    (9 14
     :dominical "e"
     :feast "Holy-Cross Day"
     :mattins  (:lesson1 ("Dan" 2 1 24)  :lesson2 (("2 Cor" 6) ("2 Cor" 7 1 1)))
     :evensong (:lesson1 ("Dan" 2 24 49)  :lesson2 ("Mark" 12 13 35)))
    (9 15
     :dominical "f"
     :mattins  (:lesson1 ("Dan" 3)  :lesson2 ("2 Cor" 7 2 16))
     :evensong (:lesson1 ("Dan" 4 1 19)  :lesson2 (("Mark" 12 35 nil) ("Mark" 13 1 14))))
    (9 16
     :dominical "g"
     :mattins  (:lesson1 ("Dan" 4 19 37)  :lesson2 ("2 Cor" 8))
     :evensong (:lesson1 ("Dan" 5 1 17)  :lesson2 ("Mark" 13 14 37)))
    (9 17
     :dominical "A"
     :feast "Lambert, Bishop"
     :mattins  (:lesson1 ("Dan" 5 17 31)  :lesson2 ("2 Cor" 9))
     :evensong (:lesson1 ("Dan" 6)  :lesson2 ("Mark" 14 1 27)))
    (9 18
     :dominical "b"
     :mattins  (:lesson1 ("Dan" 7 1 15)  :lesson2 ("2 Cor" 10))
     :evensong (:lesson1 ("Dan" 7 15 28)  :lesson2 ("Mark" 14 27 53)))
    (9 19
     :dominical "c"
     :mattins  (:lesson1 ("Dan" 9 1 20)  :lesson2 ("2 Cor" 11 1 30))
     :evensong (:lesson1 ("Dan" 9 20 27)  :lesson2 ("Mark" 14 53 72)))
    (9 20
     :dominical "d"
     :feast "Fast."
     :mattins  (:lesson1 ("Dan" 10 1 20)  :lesson2 (("2 Cor" 11 30 nil) ("2 Cor" 12 1 14)))
     :evensong (:lesson1 ("Dan" 12)  :lesson2 ("Mark" 15 1 42)))
    (9 21
     :dominical "e"
     :feast "St. Matthew, Apos."
     :mattins  (:lesson1 ("1 Kgs" 19 15 21)  :lesson2 (("2 Cor" 12 14 nil) ("2 Cor" 13)))
     :evensong (:lesson1 ("1 Chr" 29 1 20)  :lesson2 (("Mark" 15 42 nil) ("Mark" 16))))
    (9 22
     :dominical "f"
     :mattins  (:lesson1 ("Hos" 2 14 23)  :lesson2 ("Gal" 1))
     :evensong (:lesson1 ("Hos" 4 1 13)  :lesson2 ("Luke" 1 1 26)))
    (9 23
     :dominical "g"
     :mattins  (:lesson1 (("Hos" 5 8 nil) ("Hos" 6 1 7))  :lesson2 ("Gal" 2))
     :evensong (:lesson1 ("Hos" 7 8 16)  :lesson2 ("Luke" 1 26 57)))
    (9 24
     :dominical "A"
     :mattins  (:lesson1 ("Hos" 8)  :lesson2 ("Gal" 3))
     :evensong (:lesson1 ("Hos" 9)  :lesson2 ("Luke" 1 57 80)))
    (9 25
     :dominical "b"
     :mattins  (:lesson1 ("Hos" 10)  :lesson2 ("Gal" 4 1 21))
     :evensong (:lesson1 (("Hos" 11) ("Hos" 12 1 7))  :lesson2 ("Luke" 2 1 21)))
    (9 26
     :dominical "c"
     :feast "St. Cyprian, Abp."
     :mattins  (:lesson1 ("Hos" 13 1 15)  :lesson2 (("Gal" 4 21 nil) ("Gal" 5 1 13)))
     :evensong (:lesson1 ("Hos" 14)  :lesson2 ("Luke" 2 21 52)))
    (9 27
     :dominical "d"
     :mattins  (:lesson1 ("Joel" 1)  :lesson2 ("Gal" 5 13 26))
     :evensong (:lesson1 ("Joel" 2 1 15)  :lesson2 ("Luke" 3 1 23)))
    (9 28
     :dominical "e"
     :mattins  (:lesson1 ("Joel" 2 15 28)  :lesson2 ("Gal" 6))
     :evensong (:lesson1 (("Joel" 2 28 nil) ("Joel" 3 1 9))  :lesson2 ("Luke" 4 1 16)))
    (9 29
     :dominical "f"
     :feast "St. Michael and all Angels"
     :mattins  (:lesson1 ("Gen" 32)  :lesson2 ("Acts" 12 5 18))
     :evensong (:lesson1 ("Dan" 10 4 21)  :lesson2 ("Rev" 14 14 20)))
    (9 30
     :dominical "g"
     :feast "St. Jerome"
     :mattins  (:lesson1 ("Joel" 3 9 21)  :lesson2 ("Eph" 1))
     :evensong (:lesson1 (("Amos" 1) ("Amos" 2 1 4))  :lesson2 ("Luke" 4 16 44)))

  ;; ---- October ----
    (10 1
     :dominical "A"
     :feast "Remigius, Bp."
     :mattins  (:lesson1 (("Amos" 2 4 nil) ("Amos" 3 1 9))  :lesson2 ("Eph" 2))
     :evensong (:lesson1 ("Amos" 4 4 nil)  :lesson2 ("Luke" 5 1 17)))
    (10 2
     :dominical "b"
     :mattins  (:lesson1 ("Amos" 5 1 18)  :lesson2 ("Eph" 3))
     :evensong (:lesson1 (("Amos" 5 18 nil) ("Amos" 6 1 9))  :lesson2 ("Luke" 5 17 39)))
    (10 3
     :dominical "c"
     :mattins  (:lesson1 ("Amos" 7)  :lesson2 ("Eph" 4 1 25))
     :evensong (:lesson1 ("Amos" 8)  :lesson2 ("Luke" 6 1 20)))
    (10 4
     :dominical "d"
     :mattins  (:lesson1 ("Amos" 9)  :lesson2 (("Eph" 4 25 nil) ("Eph" 5 1 22)))
     :evensong (:lesson1 ("Obad" 1)  :lesson2 ("Luke" 6 20 49)))
    (10 5
     :dominical "e"
     :mattins  (:lesson1 ("Jonah" 1)  :lesson2 (("Eph" 5 22 nil) ("Eph" 6 1 10)))
     :evensong (:lesson1 ("Jonah" 2)  :lesson2 ("Luke" 7 1 24)))
    (10 6
     :dominical "f"
     :feast "Faith, V. & M."
     :mattins  (:lesson1 ("Jonah" 3)  :lesson2 ("Eph" 6 10 24))
     :evensong (:lesson1 ("Jonah" 4)  :lesson2 ("Luke" 7 24 50)))
    (10 7
     :dominical "g"
     :mattins  (:lesson1 ("Mic" 1 1 10)  :lesson2 ("Phil" 1))
     :evensong (:lesson1 ("Mic" 2)  :lesson2 ("Luke" 8 1 26)))
    (10 8
     :dominical "A"
     :mattins  (:lesson1 ("Mic" 3)  :lesson2 ("Phil" 2))
     :evensong (:lesson1 ("Mic" 4)  :lesson2 ("Luke" 8 26 56)))
    (10 9
     :dominical "b"
     :feast "St. Denys, Bishop"
     :mattins  (:lesson1 ("Mic" 5)  :lesson2 ("Phil" 3))
     :evensong (:lesson1 ("Mic" 6)  :lesson2 ("Luke" 9 1 28)))
    (10 10
     :dominical "c"
     :mattins  (:lesson1 ("Mic" 7)  :lesson2 ("Phil" 4))
     :evensong (:lesson1 ("Nah" 1)  :lesson2 ("Luke" 9 28 51)))
    (10 11
     :dominical "d"
     :mattins  (:lesson1 ("Nah" 2)  :lesson2 ("Col" 1 1 21))
     :evensong (:lesson1 ("Nah" 3)  :lesson2 (("Luke" 9 51 nil) ("Luke" 10 1 17))))
    (10 12
     :dominical "e"
     :mattins  (:lesson1 ("Hab" 1)  :lesson2 (("Col" 1 21 nil) ("Col" 2 1 8)))
     :evensong (:lesson1 ("Hab" 3)  :lesson2 ("Luke" 10 17 42)))
    (10 13
     :dominical "f"
     :feast "Trans. K. Edw."
     :mattins  (:lesson1 ("Hab" 3)  :lesson2 ("Col" 2 8 23))
     :evensong (:lesson1 ("Zeph" 1 1 14)  :lesson2 ("Luke" 11 1 29)))
    (10 14
     :dominical "g"
     :mattins  (:lesson1 (("Zeph" 1 14 nil) ("Zeph" 2 1 4))  :lesson2 ("Col" 3 1 18))
     :evensong (:lesson1 ("Hag" 2 4 23)  :lesson2 ("Luke" 11 1 29)))
    (10 15
     :dominical "A"
     :mattins  (:lesson1 ("Zeph" 3)  :lesson2 (("Col" 3 18 nil) ("Col" 4)))
     :evensong (:lesson1 ("Zech" 1)  :lesson2 ("Luke" 12 1 35)))
    (10 16
     :dominical "b"
     :mattins  (:lesson1 ("Hag" 2 1 10)  :lesson2 ("1 Thess" 1))
     :evensong (:lesson1 ("Sir" 2 10 nil)  :lesson2 ("Luke" 12 35 59)))
    (10 17
     :dominical "c"
     :feast "Etheldreda, V."
     :mattins  (:lesson1 ("Zech" 1 1 18)  :lesson2 ("1 Thess" 2))
     :evensong (:lesson1 (("Zech" 1 18 nil) ("Zech" 2))  :lesson2 ("Luke" 13 1 18)))
    (10 18
     :dominical "d"
     :feast "St. Luke, Evang."
     :mattins  (:lesson1 ("Isa" 55)  :lesson2 ("1 Thess" 3))
     :evensong (:lesson1 ("Zech" 8 1 15)  :lesson2 ("Luke" 13 18 35)))
    (10 19
     :dominical "e"
     :mattins  (:lesson1 ("Zech" 3)  :lesson2 ("1 Thess" 4))
     :evensong (:lesson1 ("Zech" 4)  :lesson2 ("Luke" 14 1 25)))
    (10 20
     :dominical "f"
     :mattins  (:lesson1 ("Zech" 5)  :lesson2 ("1 Thess" 5))
     :evensong (:lesson1 ("Zech" 6)  :lesson2 (("Luke" 14 25 nil) ("Luke" 15 1 11))))
    (10 21
     :dominical "g"
     :mattins  (:lesson1 ("Zech" 7)  :lesson2 ("2 Thess" 1))
     :evensong (:lesson1 ("Zech" 8 1 14)  :lesson2 ("Luke" 15 11 32)))
    (10 22
     :dominical "A"
     :mattins  (:lesson1 ("Zech" 8 14 23)  :lesson2 ("2 Thess" 2))
     :evensong (:lesson1 ("Zech" 9 9 17)  :lesson2 ("Luke" 16)))
    (10 23
     :dominical "b"
     :mattins  (:lesson1 ("Zech" 10)  :lesson2 ("2 Thess" 3))
     :evensong (:lesson1 ("Zech" 11)  :lesson2 ("Luke" 17 1 20)))
    (10 24
     :dominical "c"
     :mattins  (:lesson1 ("Zech" 12)  :lesson2 ("1 Tim" 1 1 18))
     :evensong (:lesson1 ("Zech" 13)  :lesson2 ("Luke" 17 20 37)))
    (10 25
     :dominical "d"
     :feast "Crispin, Martyr"
     :mattins  (:lesson1 ("Zech" 14)  :lesson2 (("1 Tim" 1 18 nil) ("1 Tim" 2)))
     :evensong (:lesson1 ("Mal" 1)  :lesson2 ("Luke" 18 1 31)))
    (10 26
     :dominical "e"
     :mattins  (:lesson1 ("Mal" 2)  :lesson2 ("1 Tim" 3))
     :evensong (:lesson1 ("Mal" 3 1 13)  :lesson2 (("Luke" 18 31 nil) ("Luke" 19 1 11))))
    (10 27
     :dominical "f"
     :feast "Fast."
     :mattins  (:lesson1 (("Mal" 3 13 nil) ("Mal" 4))  :lesson2 ("1 Tim" 4))
     :evensong (:lesson1 ("Wis" 1)  :lesson2 ("Luke" 19 11 28)))
    (10 28
     :dominical "g"
     :feast "St. Simon & St. Jude"
     :mattins  (:lesson1 ("Isa" 28 9 17)  :lesson2 ("1 Tim" 5))
     :evensong (:lesson1 ("Jer" 3 12 19)  :lesson2 ("Luke" 19 28 48)))
    (10 29
     :dominical "A"
     :mattins  (:lesson1 ("Wis" 2)  :lesson2 ("1 Tim" 6))
     :evensong (:lesson1 ("Wis" 4 7 nil)  :lesson2 ("Luke" 20 1 27)))
    (10 30
     :dominical "b"
     :mattins  (:lesson1 ("Wis" 6 1 22)  :lesson2 ("2 Tim" 1))
     :evensong (:lesson1 (("Wis" 6 22 nil) ("Wis" 7))  :lesson2 (("Luke" 20 27 nil) ("Luke" 21 1 5))))
    (10 31
     :dominical "c"
     :feast "Fast."
     :mattins  (:lesson1 ("Wis" 7 15 nil)  :lesson2 ("2 Tim" 2))
     :evensong (:lesson1 ("Wis" 8 1 19)  :lesson2 ("Luke" 21 5 38)))

  ;; ---- November ----
    (11 1
     :dominical "d"
     :feast "All Saints' Day"
     :mattins  (:lesson1 ("Wis" 3 1 10)  :lesson2 (("Heb" 11 38 nil) ("Heb" 12 1 7)))
     :evensong (:lesson1 ("Wis" 5 1 17)  :lesson2 ("Rev" 19 1 17)))
    (11 2
     :dominical "e"
     :mattins  (:lesson1 ("Wis" 9)  :lesson2 ("2 Tim" 3))
     :evensong (:lesson1 ("Wis" 11 1 15)  :lesson2 ("Luke" 22 1 31)))
    (11 3
     :dominical "f"
     :mattins  (:lesson1 (("Wis" 11 15 nil) ("Wis" 12 1 3))  :lesson2 ("2 Tim" 4))
     :evensong (:lesson1 ("Sir" 17)  :lesson2 ("Luke" 22 31 54)))
    (11 4
     :dominical "g"
     :mattins  (:lesson1 ("Sir" 1 1 14)  :lesson2 ("Titus" 1))
     :evensong (:lesson1 ("Sir" 2)  :lesson2 ("Luke" 22 54 71)))
    (11 5
     :dominical "A"
     :mattins  (:lesson1 ("Sir" 3 17 30)  :lesson2 ("Titus" 2))
     :evensong (:lesson1 ("Sir" 4 10 nil)  :lesson2 ("Luke" 23 1 26)))
    (11 6
     :dominical "b"
     :feast "Leonard, Conf."
     :mattins  (:lesson1 ("Sir" 5)  :lesson2 ("Titus" 3))
     :evensong (:lesson1 ("Sir" 7 27 nil)  :lesson2 ("Luke" 23 26 50)))
    (11 7
     :dominical "c"
     :mattins  (:lesson1 ("Sir" 10 18 nil)  :lesson2 ("Phlm" 1))
     :evensong (:lesson1 ("Sir" 14 1 20)  :lesson2 (("Luke" 23 50 56) ("Luke" 24 1 13))))
    (11 8
     :dominical "d"
     :mattins  (:lesson1 ("Sir" 15 9 nil)  :lesson2 ("Heb" 1))
     :evensong (:lesson1 ("Sir" 16 17 nil)  :lesson2 ("Luke" 24 13 53)))
    (11 9
     :dominical "e"
     :mattins  (:lesson1 ("Sir" 18 1 15)  :lesson2 (("Heb" 2) ("Heb" 3 1 7)))
     :evensong (:lesson1 ("Sir" 18 15 nil)  :lesson2 ("John" 1 1 29)))
    (11 10
     :dominical "f"
     :mattins  (:lesson1 ("Sir" 19 13 nil)  :lesson2 (("Heb" 3 17 nil) ("Heb" 4 1 14)))
     :evensong (:lesson1 ("Sir" 22 6 24)  :lesson2 ("John" 1 29 51)))
    (11 11
     :dominical "g"
     :feast "St. Martin, Bp."
     :mattins  (:lesson1 ("Sir" 24 1 24)  :lesson2 (("Heb" 4 14 nil) ("Heb" 5)))
     :evensong (:lesson1 ("Sir" 24 24 nil)  :lesson2 ("John" 2)))
    (11 12
     :dominical "A"
     :mattins  (:lesson1 ("Sir" 33 7 23)  :lesson2 ("Heb" 6))
     :evensong (:lesson1 ("Sir" 34 15 nil)  :lesson2 ("John" 3 1 22)))
    (11 13
     :dominical "b"
     :feast "Britius, Bishop"
     :mattins  (:lesson1 ("Sir" 35)  :lesson2 ("Heb" 7))
     :evensong (:lesson1 ("Sir" 37 8 19)  :lesson2 ("John" 3 22 36)))
    (11 14
     :dominical "c"
     :mattins  (:lesson1 ("Sir" 39 1 13)  :lesson2 ("Heb" 8))
     :evensong (:lesson1 ("Sir" 39 13 nil)  :lesson2 ("John" 4 1 31)))
    (11 15
     :dominical "d"
     :feast "Machutus, Bp."
     :mattins  (:lesson1 ("Sir" 41 1 14)  :lesson2 ("Heb" 9))
     :evensong (:lesson1 ("Sir" 42 15 nil)  :lesson2 ("John" 4 31 54)))
    (11 16
     :dominical "e"
     :mattins  (:lesson1 ("Sir" 44 1 16)  :lesson2 ("Heb" 10 1 19))
     :evensong (:lesson1 ("Sir" 50 1 25)  :lesson2 ("John" 5 1 24)))
    (11 17
     :dominical "f"
     :feast "Hugh, Bishop"
     :mattins  (:lesson1 ("Sir" 51 10 nil)  :lesson2 ("Heb" 10 19 39))
     :evensong (:lesson1 ("Bar" 4 1 21)  :lesson2 ("John" 5 24 47)))
    (11 18
     :dominical "g"
     :mattins  (:lesson1 (("Bar" 4 36 nil) ("Bar" 5))  :lesson2 ("Heb" 11 1 17))
     :evensong (:lesson1 ("Isa" 1 1 21)  :lesson2 ("John" 6 1 22)))
    (11 19
     :dominical "A"
     :mattins  (:lesson1 ("Isa" 1 21 31)  :lesson2 ("Heb" 11 17 40))
     :evensong (:lesson1 ("Isa" 2)  :lesson2 ("John" 6 22 41)))
    (11 20
     :dominical "b"
     :feast "Edmund, King"
     :mattins  (:lesson1 ("Isa" 3 1 16)  :lesson2 ("Heb" 12))
     :evensong (:lesson1 ("Isa" 4 2 6)  :lesson2 ("John" 6 41 71)))
    (11 21
     :dominical "c"
     :mattins  (:lesson1 ("Isa" 5 1 18)  :lesson2 ("Heb" 13))
     :evensong (:lesson1 ("Isa" 5 18 30)  :lesson2 ("John" 7 1 25)))
    (11 22
     :dominical "d"
     :feast "Cecilia, V. & M."
     :mattins  (:lesson1 ("Isa" 6)  :lesson2 ("Jas" 1))
     :evensong (:lesson1 ("Isa" 7 1 17)  :lesson2 ("John" 7 25 53)))
    (11 23
     :dominical "e"
     :feast "St. Clement, Bp."
     :mattins  (:lesson1 ("Isa" 8 5 18)  :lesson2 ("Jas" 2))
     :evensong (:lesson1 (("Isa" 8 18 22) ("Isa" 9 1 8))  :lesson2 ("John" 8 1 31)))
    (11 24
     :dominical "f"
     :mattins  (:lesson1 (("Isa" 9 8 21) ("Isa" 10 1 5))  :lesson2 ("Jas" 3))
     :evensong (:lesson1 ("Isa" 10 5 20)  :lesson2 ("John" 8 31 59)))
    (11 25
     :dominical "g"
     :feast "Catherine, V. & M."
     :mattins  (:lesson1 ("Isa" 10 20 34)  :lesson2 ("Jas" 4))
     :evensong (:lesson1 ("Isa" 11 1 10)  :lesson2 ("John" 9 1 39)))
    (11 26
     :dominical "A"
     :mattins  (:lesson1 ("Isa" 11 10 16)  :lesson2 ("Jas" 5))
     :evensong (:lesson1 ("Isa" 12)  :lesson2 (("John" 9 39 41) ("John" 10 1 22))))
    (11 27
     :dominical "b"
     :mattins  (:lesson1 ("Isa" 13)  :lesson2 ("1 Pet" 1 1 22))
     :evensong (:lesson1 ("Isa" 14 1 24)  :lesson2 ("John" 10 22 42)))
    (11 28
     :dominical "c"
     :mattins  (:lesson1 ("Isa" 17)  :lesson2 (("1 Pet" 1 22 25) ("1 Pet" 2 1 11)))
     :evensong (:lesson1 ("Isa" 18)  :lesson2 ("John" 11 1 17)))
    (11 29
     :dominical "d"
     :feast "Fast"
     :mattins  (:lesson1 ("Isa" 19 1 16)  :lesson2 (("1 Pet" 2 11 25) ("1 Pet" 3 1 8)))
     :evensong (:lesson1 ("Isa" 19 16 25)  :lesson2 ("John" 11 17 47)))
    (11 30
     :dominical "e"
     :feast "St. Andrew, Ap."
     :mattins  (:lesson1 ("Isa" 54)  :lesson2 ("John" 1 35 43))
     :evensong (:lesson1 ("Isa" 65 1 17)  :lesson2 ("John" 12 20 42)))

  ;; ---- December ----
    (12 1
     :dominical "f"
     :mattins  (:lesson1 ("Isa" 21 1 13)  :lesson2 (("1 Pet" 3 8 nil) ("1 Pet" 4 1 7)))
     :evensong (:lesson1 ("Isa" 22 1 15)  :lesson2 (("John" 11 47 nil) ("John" 12 1 20))))
    (12 2
     :dominical "g"
     :mattins  (:lesson1 ("Isa" 22 15 25)  :lesson2 ("1 Pet" 4 7 19))
     :evensong (:lesson1 ("Isa" 23)  :lesson2 ("John" 12 20 50)))
    (12 3
     :dominical "A"
     :mattins  (:lesson1 ("Isa" 24)  :lesson2 ("1 Pet" 5))
     :evensong (:lesson1 ("Isa" 25)  :lesson2 ("John" 13 1 21)))
    (12 4
     :dominical "b"
     :mattins  (:lesson1 ("Isa" 26 1 20)  :lesson2 ("2 Pet" 1))
     :evensong (:lesson1 (("Isa" 26 20 nil) ("Isa" 27))  :lesson2 ("John" 13 21 38)))
    (12 5
     :dominical "c"
     :mattins  (:lesson1 ("Isa" 28 1 14)  :lesson2 ("2 Pet" 2))
     :evensong (:lesson1 ("Isa" 28 14 29)  :lesson2 ("John" 14)))
    (12 6
     :dominical "d"
     :feast "Nicolas, Bishop"
     :mattins  (:lesson1 ("Isa" 29 1 9)  :lesson2 ("2 Pet" 3))
     :evensong (:lesson1 ("Isa" 29 9 24)  :lesson2 ("John" 15)))
    (12 7
     :dominical "e"
     :mattins  (:lesson1 ("Isa" 30 1 18)  :lesson2 ("1 John" 1))
     :evensong (:lesson1 ("Isa" 30 18 33)  :lesson2 ("John" 16 1 16)))
    (12 8
     :dominical "f"
     :feast "Conception of Vir. Mary"
     :mattins  (:lesson1 ("Isa" 31)  :lesson2 ("1 John" 2 1 15))
     :evensong (:lesson1 ("Isa" 32)  :lesson2 ("John" 16 16 33)))
    (12 9
     :dominical "g"
     :mattins  (:lesson1 ("Isa" 33)  :lesson2 ("1 John" 2 15 29))
     :evensong (:lesson1 ("Isa" 34)  :lesson2 ("John" 17)))
    (12 10
     :dominical "A"
     :mattins  (:lesson1 ("Isa" 35)  :lesson2 ("1 John" 3 1 16))
     :evensong (:lesson1 ("Isa" 40 1 12)  :lesson2 ("John" 18 1 28)))
    (12 11
     :dominical "b"
     :mattins  (:lesson1 ("Isa" 40 12 31)  :lesson2 (("1 John" 3 16 24) ("1 John" 4 1 7)))
     :evensong (:lesson1 ("Isa" 41 1 17)  :lesson2 ("John" 18 28 40)))
    (12 12
     :dominical "c"
     :mattins  (:lesson1 ("Isa" 41 17 29)  :lesson2 ("1 John" 4 7 21))
     :evensong (:lesson1 ("Isa" 42 1 18)  :lesson2 ("John" 19 1 25)))
    (12 13
     :dominical "d"
     :feast "Lucy, Vir. & M."
     :mattins  (:lesson1 (("Isa" 42 18 nil) ("Isa" 43 1 8))  :lesson2 ("1 John" 5))
     :evensong (:lesson1 ("Isa" 43 8 28)  :lesson2 ("John" 19 25 42)))
    (12 14
     :dominical "e"
     :mattins  (:lesson1 ("Isa" 44 1 21)  :lesson2 ("2 John" 1))
     :evensong (:lesson1 (("Isa" 44 21 nil) ("Isa" 45 1 8))  :lesson2 ("John" 20 1 19)))
    (12 15
     :dominical "f"
     :mattins  (:lesson1 ("Isa" 45 8 25)  :lesson2 ("3 John" 1))
     :evensong (:lesson1 ("Isa" 46)  :lesson2 ("John" 20 19 31)))
    (12 16
     :dominical "g"
     :feast "O Sapientia"
     :mattins  (:lesson1 ("Isa" 47)  :lesson2 ("Jude" 1))
     :evensong (:lesson1 ("Isa" 48)  :lesson2 ("John" 21)))
    (12 17
     :dominical "A"
     :mattins  (:lesson1 ("Isa" 49 1 13)  :lesson2 ("Rev" 1))
     :evensong (:lesson1 ("Isa" 49 13 26)  :lesson2 ("Rev" 2 1 18)))
    (12 18
     :dominical "b"
     :mattins  (:lesson1 ("Isa" 50)  :lesson2 (("Rev" 2 18 nil) ("Rev" 3 1 7)))
     :evensong (:lesson1 ("Isa" 51 1 9)  :lesson2 ("Rev" 3 7 22)))
    (12 19
     :dominical "c"
     :mattins  (:lesson1 ("Isa" 51 9 23)  :lesson2 ("Rev" 4))
     :evensong (:lesson1 ("Isa" 52 1 13)  :lesson2 ("Rev" 5)))
    (12 20
     :dominical "d"
     :feast "Fast."
     :mattins  (:lesson1 (("Isa" 52 13 nil) ("Isa" 53))  :lesson2 ("Rev" 6))
     :evensong (:lesson1 ("Isa" 54)  :lesson2 ("Rev" 7)))
    (12 21
     :dominical "e"
     :feast "St. Thomas, Apos."
     :mattins  (:lesson1 ("Job" 42 1 7)  :lesson2 ("John" 19 1 24))
     :evensong (:lesson1 ("Isa" 35)  :lesson2 ("John" 14 1 8)))
    (12 22
     :dominical "f"
     :mattins  (:lesson1 ("Isa" 55)  :lesson2 ("Rev" 8))
     :evensong (:lesson1 ("Isa" 56)  :lesson2 ("Rev" 10)))
    (12 23
     :dominical "g"
     :mattins  (:lesson1 ("Isa" 57)  :lesson2 ("Rev" 11))
     :evensong (:lesson1 ("Isa" 58)  :lesson2 ("Rev" 12)))
    (12 24
     :dominical "A"
     :feast "Fast."
     :mattins  (:lesson1 ("Isa" 59)  :lesson2 ("Rev" 14))
     :evensong (:lesson1 ("Isa" 60)  :lesson2 ("Rev" 15)))
    (12 25
     :dominical "b"
     :feast "Christmas-Day"
     :mattins  (:lesson1 ("Isa" 9 1 8)  :lesson2 ("Luke" 2 1 15))
     :evensong (:lesson1 ("Isa" 7 10 17)  :lesson2 ("Titus" 3 4 9)))
    (12 26
     :dominical "c"
     :feast "St. Stephen, M."
     :mattins  (:lesson1 ("Gen" 4 1 11)  :lesson2 ("Acts" 6))
     :evensong (:lesson1 ("2 Chr" 24 15 23)  :lesson2 ("Acts" 8 1 9)))
    (12 27
     :dominical "d"
     :feast "St. John, Evang."
     :mattins  (:lesson1 ("Exod" 33 9 23)  :lesson2 ("John" 13 23 36))
     :evensong (:lesson1 ("Isa" 6)  :lesson2 ("Rev" 1)))
    (12 28
     :dominical "e"
     :feast "Innocents' Day"
     :mattins  (:lesson1 ("Jer" 31 1 18)  :lesson2 ("Rev" 16))
     :evensong (:lesson1 ("Bar" 4 21 31)  :lesson2 ("Rev" 18)))
    (12 29
     :dominical "f"
     :mattins  (:lesson1 ("Isa" 61)  :lesson2 ("Rev" 19 1 11))
     :evensong (:lesson1 ("Isa" 62)  :lesson2 ("Rev" 19 11 21)))
    (12 30
     :dominical "g"
     :mattins  (:lesson1 ("Isa" 63)  :lesson2 ("Rev" 20))
     :evensong (:lesson1 (("Isa" 64) ("Isa" 65 1 8))  :lesson2 ("Rev" 21 1 15)))
    (12 31
     :dominical "A"
     :feast "Silvester, Bishop"
     :mattins  (:lesson1 ("Isa" 65 8 25)  :lesson2 (("Rev" 21 15 nil) ("Rev" 22 1 6)))
     :evensong (:lesson1 ("Isa" 66)  :lesson2 ("Rev" 22 6 21)))
  )
  "BCP 1662 daily lectionary for the full calendar year.")


;;;; ──────────────────────────────────────────────────────────────────────
;;;; Sunday Proper Lessons
;;;; ──────────────────────────────────────────────────────────────────────

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Proper Psalms for Principal Feasts

(defconst bcp-1662-proper-psalms
  '((christmas     :mattins (19 45 85)   :evensong (89 110 132))
    (ash-wednesday :mattins (6 32 38)    :evensong (102 130 143))
    (good-friday   :mattins (22 40 54)   :evensong (69 88))
    (easter        :mattins (2 57 111)   :evensong (113 114 118))
    (ascension     :mattins (8 15 21)    :evensong (24 47 108))
    (whitsunday    :mattins (48 68)      :evensong (104 145)))
  "Proper psalms for principal feasts, overriding the monthly cycle.
Each entry: (FEAST-KEY :mattins (PSALMS) :evensong (PSALMS)).")

;;;; ──────────────────────────────────────────────────────────────────────
;;;; Proper Lessons for Sundays
;;
;; The table has four columns: Mattins L1, Evensong L1, [or], Evensong L1 alt.
;; Where an "or" alternative exists for Evensong L1 it is stored under
;; :evensong-alt.  The second lesson columns are only populated for a
;; handful of Sundays (Septuagesima, Palm Sunday, Easter, after Easter 1,
;; Whitsunday, Trinity).

(defconst bcp-1662-propers-sunday
  '(;; ── Advent ──────────────────────────────────────────────────────
    (advent-1
     :mattins      (:lesson1 ("Isa" 1)  :lesson2 nil)
     :evensong      (:lesson1 ("Isa" 2)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Isa" 4 2 nil)  :lesson2 nil))
    (advent-2
     :mattins      (:lesson1 ("Isa" 5)  :lesson2 nil)
     :evensong      (:lesson1 ("Isa" 11 1 11)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Isa" 24)  :lesson2 nil))
    (advent-3
     :mattins      (:lesson1 ("Isa" 25)  :lesson2 nil)
     :evensong      (:lesson1 ("Isa" 26)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Isa" 28 5 19)  :lesson2 nil))
    (advent-4
     :mattins      (:lesson1 ("Isa" 30 1 27)  :lesson2 nil)
     :evensong      (:lesson1 ("Isa" 32)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Isa" 33 2 23)  :lesson2 nil))

    ;; ── After Christmas ─────────────────────────────────────────────
    (after-christmas-1
     :mattins      (:lesson1 ("Isa" 35)  :lesson2 nil)
     :evensong      (:lesson1 ("Isa" 38)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Isa" 40)  :lesson2 nil))
    (after-christmas-2
     :mattins      (:lesson1 ("Isa" 42)  :lesson2 nil)
     :evensong      (:lesson1 ("Isa" 43)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Isa" 44)  :lesson2 nil))

    ;; ── After Epiphany ──────────────────────────────────────────────
    (after-epiphany-1
     :mattins      (:lesson1 ("Isa" 51)  :lesson2 nil)
     :evensong     ((("Isa" 52 13 nil)
                     ("Isa" 53))             nil)
     :evensong-alt      (:lesson1 ("Isa" 54)  :lesson2 nil))
    (after-epiphany-2
     :mattins      (:lesson1 ("Isa" 55)  :lesson2 nil)
     :evensong      (:lesson1 ("Isa" 57)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Isa" 61)  :lesson2 nil))
    (after-epiphany-3
     :mattins      (:lesson1 ("Isa" 62)  :lesson2 nil)
     :evensong      (:lesson1 ("Isa" 65)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Isa" 66)  :lesson2 nil))
    (after-epiphany-4
     :mattins      (:lesson1 ("Job" 27)  :lesson2 nil)
     :evensong      (:lesson1 ("Job" 28)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Job" 29)  :lesson2 nil))
    (after-epiphany-5
     :mattins      (:lesson1 ("Prov" 1)  :lesson2 nil)
     :evensong      (:lesson1 ("Prov" 3)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Prov" 8)  :lesson2 nil))
    (after-epiphany-6
     :mattins      (:lesson1 ("Prov" 9)  :lesson2 nil)
     :evensong      (:lesson1 ("Prov" 11)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Prov" 15)  :lesson2 nil))

    ;; ── Pre-Lent ────────────────────────────────────────────────────
    (septuagesima
     :mattins      (:lesson1 (("Gen" 1) ("Gen" 2 1 4))  :lesson2 ("Rev" 21 1 9))
     :evensong      (:lesson1 ("Gen" 2 4 nil)  :lesson2 (("Rev" 21 9 nil) ("Rev" 22 1 6)))
     :evensong-alt      (:lesson1 ("Job" 38)  :lesson2 nil))
    (sexagesima
     :mattins      (:lesson1 ("Gen" 3)  :lesson2 nil)
     :evensong      (:lesson1 ("Gen" 6)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Gen" 8)  :lesson2 nil))
    (quinquagesima
     :mattins      (:lesson1 ("Gen" 9 1 20)  :lesson2 nil)
     :evensong      (:lesson1 ("Gen" 12)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Gen" 13)  :lesson2 nil))

    ;; ── Lent ────────────────────────────────────────────────────────
    (lent-1
     :mattins      (:lesson1 ("Gen" 19 12 30)  :lesson2 nil)
     :evensong      (:lesson1 ("Gen" 22 1 20)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Gen" 23)  :lesson2 nil))
    (lent-2
     :mattins      (:lesson1 ("Gen" 27 1 41)  :lesson2 nil)
     :evensong      (:lesson1 ("Gen" 28)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Gen" 32)  :lesson2 nil))
    (lent-3
     :mattins      (:lesson1 ("Gen" 37)  :lesson2 nil)
     :evensong      (:lesson1 ("Gen" 39)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Gen" 40)  :lesson2 nil))
    (lent-4
     :mattins      (:lesson1 ("Gen" 42)  :lesson2 nil)
     :evensong      (:lesson1 ("Gen" 43)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Gen" 45)  :lesson2 nil))
    (lent-5
     :mattins      (:lesson1 ("Exod" 3)  :lesson2 nil)
     :evensong      (:lesson1 ("Exod" 5)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Exod" 6 1 14)  :lesson2 nil))
    (lent-6                            ; Palm Sunday
     :mattins      (:lesson1 ("Exod" 9)  :lesson2 ("Matt" 26))
     :evensong      (:lesson1 ("Exod" 10)  :lesson2 ("Luke" 19 28 nil))
     :evensong-alt      (:lesson1 ("Exod" 11)  :lesson2 ("Luke" 20 9 21)))

    ;; ── Easter ──────────────────────────────────────────────────────
    (easter-day
     :mattins      (:lesson1 ("Exod" 12 1 29)  :lesson2 ("Rev" 1 10 19))
     :evensong      (:lesson1 ("Exod" 12 29 nil)  :lesson2 ("John" 20 11 19))
     :evensong-alt      (:lesson1 ("Exod" 14)  :lesson2 ("Rev" 5)))

    ;; ── After Easter ────────────────────────────────────────────────
    (after-easter-1
     :mattins      (:lesson1 ("Num" 16 1 36)  :lesson2 ("1 Cor" 15 1 29))
     :evensong      (:lesson1 ("Num" 16 36 nil)  :lesson2 ("John" 20 24 30))
     :evensong-alt      (:lesson1 ("Num" 17 1 12)  :lesson2 nil))
    (after-easter-2
     :mattins      (:lesson1 ("Num" 20 1 14)  :lesson2 nil)
     :evensong     ((("Num" 20 14 nil)
                     ("Num" 21 1 10))  nil)
     :evensong-alt      (:lesson1 ("Num" 21 10 nil)  :lesson2 nil))
    (after-easter-3
     :mattins      (:lesson1 ("Num" 22)  :lesson2 nil)
     :evensong      (:lesson1 ("Num" 23)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Num" 24)  :lesson2 nil))
    (after-easter-4
     :mattins      (:lesson1 ("Deut" 4 1 23)  :lesson2 nil)
     :evensong      (:lesson1 ("Deut" 4 23 41)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Deut" 5)  :lesson2 nil))
    (after-easter-5
     :mattins      (:lesson1 ("Deut" 6)  :lesson2 nil)
     :evensong      (:lesson1 ("Deut" 9)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Deut" 10)  :lesson2 nil))

    ;; ── After Ascension ─────────────────────────────────────────────
    (after-ascension
     :mattins      (:lesson1 ("Deut" 30)  :lesson2 nil)
     :evensong      (:lesson1 ("Deut" 34)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Josh" 1)  :lesson2 nil))

    ;; ── Whitsunday ──────────────────────────────────────────────────
    (whitsunday
     :mattins      (:lesson1 ("Deut" 16 1 18)  :lesson2 ("Rom" 8 1 18))
     :evensong      (:lesson1 ("Isa" 11)  :lesson2 ("Gal" 5 16 nil))
     :evensong-alt      (:lesson1 ("Ezek" 36 25 nil)  :lesson2 (("Acts" 18 24 nil) ("Acts" 19 1 21))))

    ;; ── Trinity Sunday ──────────────────────────────────────────────
    (trinity-sunday
     :mattins      (:lesson1 ("Isa" 6 1 11)  :lesson2 ("Rev" 1 1 9))
     :evensong      (:lesson1 ("Gen" 18)  :lesson2 ("Eph" 4 1 17))
     :evensong-alt      (:lesson1 (("Gen" 1) ("Gen" 2 1 4))  :lesson2 ("Matt" 3)))

    ;; ── After Trinity ───────────────────────────────────────────────
    (after-trinity-1
     :mattins      (:lesson1 (("Josh" 3 7 nil) ("Josh" 4 1 15))  :lesson2 nil)
     :evensong      (:lesson1 (("Josh" 5 13 nil) ("Josh" 6 1 21))  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Josh" 24)  :lesson2 nil))
    (after-trinity-2
     :mattins      (:lesson1 ("Judg" 4)  :lesson2 nil)
     :evensong      (:lesson1 ("Judg" 5)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Judg" 6 11 nil)  :lesson2 nil))
    (after-trinity-3
     :mattins      (:lesson1 ("1 Sam" 2 1 27)  :lesson2 nil)
     :evensong      (:lesson1 ("1 Sam" 3)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("1 Sam" 4 1 19)  :lesson2 nil))
    (after-trinity-4
     :mattins      (:lesson1 ("1 Sam" 12)  :lesson2 nil)
     :evensong      (:lesson1 ("1 Sam" 13)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Ruth" 1)  :lesson2 nil))
    (after-trinity-5
     :mattins      (:lesson1 ("1 Sam" 15 1 24)  :lesson2 nil)
     :evensong      (:lesson1 ("1 Sam" 16)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("1 Sam" 17)  :lesson2 nil))
    (after-trinity-6
     :mattins      (:lesson1 ("2 Sam" 1)  :lesson2 nil)
     :evensong      (:lesson1 ("2 Sam" 12 1 24)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("2 Sam" 18)  :lesson2 nil))
    (after-trinity-7
     :mattins      (:lesson1 ("1 Chr" 21)  :lesson2 nil)
     :evensong      (:lesson1 ("1 Chr" 22)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("1 Chr" 28 1 21)  :lesson2 nil))
    (after-trinity-8
     :mattins      (:lesson1 ("1 Chr" 29 9 29)  :lesson2 nil)
     :evensong      (:lesson1 ("2 Chr" 1)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("1 Kgs" 3)  :lesson2 nil))
    (after-trinity-9
     :mattins      (:lesson1 ("1 Kgs" 10 1 25)  :lesson2 nil)
     :evensong      (:lesson1 ("1 Kgs" 11 1 15)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("1 Kgs" 11 26 nil)  :lesson2 nil))
    (after-trinity-10
     :mattins      (:lesson1 ("1 Kgs" 12)  :lesson2 nil)
     :evensong      (:lesson1 ("1 Kgs" 13)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("1 Kgs" 17)  :lesson2 nil))
    (after-trinity-11
     :mattins      (:lesson1 ("1 Kgs" 18)  :lesson2 nil)
     :evensong      (:lesson1 ("1 Kgs" 19)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("1 Kgs" 21)  :lesson2 nil))
    (after-trinity-12
     :mattins      (:lesson1 ("1 Kgs" 22 41 nil)  :lesson2 nil)
     :evensong      (:lesson1 ("2 Kgs" 2 1 16)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("2 Kgs" 4 8 38)  :lesson2 nil))
    (after-trinity-13
     :mattins      (:lesson1 ("2 Kgs" 5)  :lesson2 nil)
     :evensong      (:lesson1 ("2 Kgs" 6 1 24)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("2 Kgs" 7)  :lesson2 nil))
    (after-trinity-14
     :mattins      (:lesson1 ("2 Kgs" 9)  :lesson2 nil)
     :evensong      (:lesson1 ("2 Kgs" 10 1 32)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("2 Kgs" 13)  :lesson2 nil))
    (after-trinity-15
     :mattins      (:lesson1 ("2 Kgs" 18)  :lesson2 nil)
     :evensong      (:lesson1 ("2 Kgs" 19)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("2 Kgs" 23 1 31)  :lesson2 nil))
    (after-trinity-16
     :mattins      (:lesson1 ("2 Chr" 36)  :lesson2 nil)
     :evensong      (:lesson1 (("Neh" 1) ("Neh" 2 1 9))  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Neh" 8)  :lesson2 nil))
    (after-trinity-17
     :mattins      (:lesson1 ("Jer" 5)  :lesson2 nil)
     :evensong      (:lesson1 ("Jer" 22)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Jer" 35)  :lesson2 nil))
    (after-trinity-18
     :mattins      (:lesson1 ("Jer" 36)  :lesson2 nil)
     :evensong      (:lesson1 ("Ezek" 2)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Ezek" 13 1 17)  :lesson2 nil))
    (after-trinity-19
     :mattins      (:lesson1 ("Ezek" 14)  :lesson2 nil)
     :evensong      (:lesson1 ("Ezek" 18)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Ezek" 24 15 nil)  :lesson2 nil))
    (after-trinity-20
     :mattins      (:lesson1 ("Ezek" 34)  :lesson2 nil)
     :evensong      (:lesson1 ("Ezek" 37)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Dan" 1)  :lesson2 nil))
    (after-trinity-21
     :mattins      (:lesson1 ("Dan" 3)  :lesson2 nil)
     :evensong      (:lesson1 ("Dan" 4)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Dan" 5)  :lesson2 nil))
    (after-trinity-22
     :mattins      (:lesson1 ("Dan" 6)  :lesson2 nil)
     :evensong      (:lesson1 ("Dan" 7 9 nil)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Dan" 12)  :lesson2 nil))
    (after-trinity-23
     :mattins      (:lesson1 ("Hos" 14)  :lesson2 nil)
     :evensong      (:lesson1 ("Joel" 2 1 21)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Joel" 3 9 nil)  :lesson2 nil))
    (after-trinity-24
     :mattins      (:lesson1 ("Amos" 3)  :lesson2 nil)
     :evensong      (:lesson1 ("Amos" 5)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Amos" 9)  :lesson2 nil))
    (after-trinity-25
     :mattins      (:lesson1 (("Mic" 4) ("Mic" 5 1 8))  :lesson2 nil)
     :evensong      (:lesson1 ("Mic" 6)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Mic" 7)  :lesson2 nil))
    (after-trinity-26
     :mattins      (:lesson1 ("Hab" 2)  :lesson2 nil)
     :evensong      (:lesson1 ("Hab" 3)  :lesson2 nil)
     :evensong-alt      (:lesson1 ("Zeph" 3)  :lesson2 nil))
    ;; Note: Trinity 27 = Sunday next before Advent
    (after-trinity-27
     :mattins      (:lesson1 (("Eccl" 11) ("Eccl" 12))  :lesson2 nil)
     :evensong      (:lesson1 ("Hag" 2 1 10)  :lesson2 nil)
     :evensong-alt      (:lesson1 (("Mal" 3) ("Mal" 4))  :lesson2 nil)))
  "Proper lessons for Sundays in the 1662 BCP lectionary.
Keys are season symbols e.g. `advent-1', `after-trinity-14'.
Where an alternative Evensong 1st lesson exists it is stored under
:evensong-alt.  Trinity 27 is always read on the Sunday next before Advent.
Each entry: (KEY :mattins (L1 L2) :evensong (L1 L2) [:evensong-alt (L1 L2)]).")


;;;; ──────────────────────────────────────────────────────────────────────
;;;; Communion Propers
;;;; ──────────────────────────────────────────────────────────────────────

(defconst bcp-1662-communion-propers
  '(
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
     :epistle ("1 Cor" 4 1 5)
     :gospel  ("Matt" 11 2 10))

    (advent-4
     :name    "Fourth Sunday in Advent"
     :epistle ("Phil" 4 4 7)
     :gospel  ("John" 1 19 28))

    (christmas
     :name    "Christmas Day"
     :epistle ("Heb" 1 1 12)
     :gospel  ("John" 1 1 14))

    (stephen
     :name    "St Stephen"
     :epistle ("Acts" 7 55 60)
     :gospel  ("Matt" 23 34 39))

    (john-evangelist
     :name    "St John the Evangelist"
     :epistle ("1 John" 1)
     :gospel  ("John" 21 19 25))

    (innocents
     :name    "Innocents Day"
     :epistle ("Rev" 14 1 5)
     :gospel  ("Matt" 2 13 18))

    (sunday-after-christmas
     :name    "Sunday after Christmas Day"
     :epistle ("Gal" 4 1 7)
     :gospel  ("Matt" 1 18 25))

    (circumcision
     :name    "Circumcision of Christ"
     :epistle ("Rom" 4 8 14)
     :gospel  ("Luke" 2 15 21))

    (epiphany
     :name    "Epiphany"
     :epistle ("Eph" 3 1 12)
     :gospel  ("Matt" 2 1 12))

    (epiphany-1
     :name    "First Sunday after Epiphany"
     :epistle ("Rom" 12 1 5)
     :gospel  ("Luke" 2 41 52))

    (epiphany-2
     :name    "Second Sunday after Epiphany"
     :epistle ("Rom" 12 6 16)
     :gospel  ("John" 2 1 11))

    (epiphany-3
     :name    "Third Sunday after Epiphany"
     :epistle ("Rom" 12 16 21)
     :gospel  ("Matt" 8 1 13))

    (epiphany-4
     :name    "Fourth Sunday after Epiphany"
     :epistle ("Rom" 13 1 7)
     :gospel  ("Matt" 8 23 34))

    (epiphany-5
     :name    "Fifth Sunday after Epiphany"
     :epistle ("Col" 3 12 17)
     :gospel  ("Matt" 13 24 30))

    (epiphany-6
     :name    "Sixth Sunday after Epiphany"
     :epistle ("1 John" 3 1 8)
     :gospel  ("Matt" 24 23 31))

    (septuagesima
     :name    "Septuagesima Sunday"
     :epistle ("1 Cor" 9 24 27)
     :gospel  ("Matt" 20 1 16))

    (sexagesima
     :name    "Sexagesima Sunday"
     :epistle ("2 Cor" 11 19 31)
     :gospel  ("Luke" 8 4 15))

    (quinquagesima
     :name    "Quinquagesima Sunday"
     :epistle ("1 Cor" 13)
     :gospel  ("Luke" 18 31 43))

    (ash-wednesday
     :name    "Ash Wednesday"
     :epistle ("Joel" 2 12 17)
     :gospel  ("Matt" 6 16 21))

    (lent-1
     :name    "First Sunday in Lent"
     :epistle ("2 Cor" 6 1 10)
     :gospel  ("Matt" 4 1 11))

    (lent-2
     :name    "Second Sunday in Lent"
     :epistle ("1 Thess" 4 1 8)
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
     :name    "Fifth Sunday in Lent (Passion)"
     :epistle ("Heb" 9 11 15)
     :gospel  ("John" 8 46 59))

    (palm-sunday
     :name    "Sunday next before Easter (Palm)"
     :epistle ("Phil" 2 5 11)
     :gospel  ("Matt" 27 1 54))

    (monday-holy-week
     :name    "Monday before Easter"
     :epistle ("Isa" 63)
     :gospel  ("Mark" 14))

    (tuesday-holy-week
     :name    "Tuesday before Easter"
     :epistle ("Isa" 50 5 11)
     :gospel  ("Mark" 15 1 39))

    (wednesday-holy-week
     :name    "Wednesday before Easter"
     :epistle ("Heb" 9 16 28)
     :gospel  ("Luke" 22))

    (thursday-holy-week
     :name    "Thursday before Easter"
     :epistle ("1 Cor" 11 17 34)
     :gospel  ("Luke" 23 1 49))

    (good-friday
     :name    "Good Friday"
     :epistle ("Heb" 10 1 25)
     :gospel  ("John" 19 1 37))

    (easter-eve
     :name    "Easter Even"
     :epistle ("1 Pet" 3 17 22)
     :gospel  ("Matt" 27 57 66))

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

    (easter-1
     :name    "First Sunday after Easter"
     :epistle ("1 John" 5 4 12)
     :gospel  ("John" 20 19 23))

    (easter-2
     :name    "Second Sunday after Easter"
     :epistle ("1 Pet" 2 19 25)
     :gospel  ("John" 10 11 16))

    (easter-3
     :name    "Third Sunday after Easter"
     :epistle ("1 Pet" 2 11 17)
     :gospel  ("John" 16 16 22))

    (easter-4
     :name    "Fourth Sunday after Easter"
     :epistle ("Jas" 1 17 21)
     :gospel  ("John" 16 5 15))

    (easter-5
     :name    "Fifth Sunday after Easter"
     :epistle ("Jas" 1 22 27)
     :gospel  ("John" 16 23 33))

    (ascension
     :name    "Ascension Day"
     :epistle ("Acts" 1 1 11)
     :gospel  ("Mark" 16 14 20))

    (sunday-after-ascension
     :name    "Sunday after Ascension"
     :epistle ("1 Pet" 4 7 11)
     :gospel  (("John" 15 26 nil) ("John" 16 1 4)))

    (whitsunday
     :name    "Whitsunday"
     :epistle ("Acts" 2 1 11)
     :gospel  ("John" 14 15 31))

    (whit-monday
     :name    "Monday in Whitsun Week"
     :epistle ("Acts" 10 34 48)
     :gospel  ("John" 3 16 21))

    (whit-tuesday
     :name    "Tuesday in Whitsun Week"
     :epistle ("Acts" 8 14 17)
     :gospel  ("John" 10 1 10))

    (trinity-sunday
     :name    "Trinity Sunday"
     :epistle ("Rev" 4)
     :gospel  ("John" 3 1 15))

    (trinity-1
     :name    "First Sunday after Trinity"
     :epistle ("1 John" 4 7 21)
     :gospel  ("Luke" 16 19 31))

    (trinity-2
     :name    "Second Sunday after Trinity"
     :epistle ("1 John" 3 13 24)
     :gospel  ("Luke" 14 16 24))

    (trinity-3
     :name    "Third Sunday after Trinity"
     :epistle ("1 Pet" 5 5 11)
     :gospel  ("Luke" 15 1 10))

    (trinity-4
     :name    "Fourth Sunday after Trinity"
     :epistle ("Rom" 8 18 23)
     :gospel  ("Luke" 6 36 42))

    (trinity-5
     :name    "Fifth Sunday after Trinity"
     :epistle ("1 Pet" 3 8 15)
     :gospel  ("Luke" 5 1 11))

    (trinity-6
     :name    "Sixth Sunday after Trinity"
     :epistle ("Rom" 6 3 11)
     :gospel  ("Matt" 5 20 26))

    (trinity-7
     :name    "Seventh Sunday after Trinity"
     :epistle ("Rom" 6 19 23)
     :gospel  ("Mark" 8 1 9))

    (trinity-8
     :name    "Eighth Sunday after Trinity"
     :epistle ("Rom" 8 12 17)
     :gospel  ("Matt" 7 15 21))

    (trinity-9
     :name    "Ninth Sunday after Trinity"
     :epistle ("1 Cor" 10 1 13)
     :gospel  ("Luke" 16 1 9))

    (trinity-10
     :name    "Tenth Sunday after Trinity"
     :epistle ("1 Cor" 12 1 11)
     :gospel  ("Luke" 19 41 47))

    (trinity-11
     :name    "Eleventh Sunday after Trinity"
     :epistle ("1 Cor" 15 1 11)
     :gospel  ("Luke" 18 9 14))

    (trinity-12
     :name    "Twelfth Sunday after Trinity"
     :epistle ("2 Cor" 3 4 9)
     :gospel  ("Mark" 7 31 37))

    (trinity-13
     :name    "Thirteenth Sunday after Trinity"
     :epistle ("Gal" 3 16 22)
     :gospel  ("Luke" 10 23 37))

    (trinity-14
     :name    "Fourteenth Sunday after Trinity"
     :epistle ("Gal" 5 16 24)
     :gospel  ("Luke" 17 11 19))

    (trinity-15
     :name    "Fifteenth Sunday after Trinity"
     :epistle ("Gal" 6 11 18)
     :gospel  ("Matt" 6 24 34))

    (trinity-16
     :name    "Sixteenth Sunday after Trinity"
     :epistle ("Eph" 3 13 21)
     :gospel  ("Luke" 7 11 17))

    (trinity-17
     :name    "Seventeenth Sunday after Trinity"
     :epistle ("Eph" 4 1 6)
     :gospel  ("Luke" 14 1 11))

    (trinity-18
     :name    "Eighteenth Sunday after Trinity"
     :epistle ("1 Cor" 1 4 8)
     :gospel  ("Matt" 22 34 46))

    (trinity-19
     :name    "Nineteenth Sunday after Trinity"
     :epistle ("Eph" 4 17 32)
     :gospel  ("Matt" 9 1 8))

    (trinity-20
     :name    "Twentieth Sunday after Trinity"
     :epistle ("Eph" 5 15 21)
     :gospel  ("Matt" 22 1 14))

    (trinity-21
     :name    "Twenty-first Sunday after Trinity"
     :epistle ("Eph" 6 10 20)
     :gospel  ("John" 4 46 54))

    (trinity-22
     :name    "Twenty-second Sunday after Trinity"
     :epistle ("Phil" 1 3 11)
     :gospel  ("Matt" 18 21 35))

    (trinity-23
     :name    "Twenty-third Sunday after Trinity"
     :epistle ("Phil" 3 17 21)
     :gospel  ("Matt" 22 15 22))

    (trinity-24
     :name    "Twenty-fourth Sunday after Trinity"
     :epistle ("Col" 1 3 12)
     :gospel  ("Matt" 9 18 26))

    (sunday-before-advent
     :name    "Sunday Next Before Advent (Trinity 25)"
     :epistle ("Jer" 23 5 8)
     :gospel  ("John" 6 5 14))

    (andrew
     :name    "St Andrew"
     :epistle ("Rom" 10 9 21)
     :gospel  ("Matt" 4 18 22))

    (thomas
     :name    "St Thomas"
     :epistle ("Eph" 2 19 22)
     :gospel  ("John" 20 24 31))

    (conversion-st-paul
     :name    "Conversion of St Paul"
     :epistle ("Acts" 9 1 22)
     :gospel  ("Matt" 19 27 30))

    (purification-bvm
     :name    "Presentation / Purification BVM"
     :epistle ("Mal" 3 1 5)
     :gospel  ("Luke" 2 22 40))

    (matthias
     :name    "St Matthias"
     :epistle ("Acts" 1 15 26)
     :gospel  ("Matt" 11 25 30))

    (annunciation
     :name    "Annunciation BVM"
     :epistle ("Isa" 7 10 15)
     :gospel  ("Luke" 1 26 38))

    (mark
     :name    "St Mark"
     :epistle ("Eph" 4 7 16)
     :gospel  ("John" 15 1 11))

    (philip-and-james
     :name    "St Philip and St James"
     :epistle ("Jas" 1 1 12)
     :gospel  ("John" 14 1 14))

    (barnabas
     :name    "St Barnabas"
     :epistle ("Acts" 11 22 30)
     :gospel  ("John" 15 12 16))

    (john-baptist
     :name    "St John the Baptist"
     :epistle ("Isa" 40 1 11)
     :gospel  ("Luke" 1 57 80))

    (peter
     :name    "St Peter"
     :epistle ("Acts" 12 1 11)
     :gospel  ("Matt" 16 13 19))

    (james
     :name    "St James"
     :epistle (("Acts" 11 27 nil) ("Acts" 12 1 3))
     :gospel  ("Matt" 20 20 28))

    (bartholomew
     :name    "St Bartholomew"
     :epistle ("Acts" 5 12 16)
     :gospel  ("Luke" 22 24 30))

    (matthew
     :name    "St Matthew"
     :epistle ("2 Cor" 4 1 6)
     :gospel  ("Matt" 9 9 13))

    (michael
     :name    "St Michael and All Angels"
     :epistle ("Rev" 12 7 12)
     :gospel  ("Matt" 18 1 10))

    (luke
     :name    "St Luke"
     :epistle ("2 Tim" 4 5 15)
     :gospel  ("Luke" 10 1 7))

    (simon-and-jude
     :name    "St Simon and St Jude"
     :epistle (("Jude" 1) ("Jude" 8))
     :gospel  ("John" 15 17 27))

    (all-saints
     :name    "All Saints Day"
     :epistle ("Rev" 7 2 12)
     :gospel  ("Matt" 5 1 12))

  )
  "Communion propers (Epistle and Gospel) for the 1662 BCP.")

(defun bcp-1662-communion-propers (symbol)
  "Return the communion propers plist for SYMBOL, or nil.
Returns (:name STRING :epistle REF :gospel REF).

`trinity-25' is an alias for `sunday-before-advent'."
  (let ((sym (if (eq symbol 'trinity-25) 'sunday-before-advent symbol)))
    (cdr (assq sym bcp-1662-communion-propers))))

(defun bcp-1662-epistle (symbol)
  "Return the Epistle ref for SYMBOL, or nil."
  (plist-get (bcp-1662-communion-propers symbol) :epistle))

(defun bcp-1662-gospel (symbol)
  "Return the Gospel ref for SYMBOL, or nil."
  (plist-get (bcp-1662-communion-propers symbol) :gospel))


;;;; ──────────────────────────────────────────────────────────────────────
;;;; OT / First Lessons
;;;; ──────────────────────────────────────────────────────────────────────

(defconst bcp-1662-ot-readings
  '(
    ;; ---- Advent ----
    (advent-1          . ("Isa" 62 10 12))
    (advent-2          . ("Isa" 55 6 11))
    (advent-3          . ("Isa" 35))
    (advent-4          . ("Isa" 40 1 9))

    ;; ---- Christmas & Epiphany ----
    (christmas         . ("Prov" 8 22 31))
    (stephen           . ("2 Chr" 24 15 22))
    (john-evangelist   . ("Exod" 33 9 23))
    (innocents         . ("Exod" 1 15 22))
    (sunday-after-christmas . ("Ruth" 4 13 17))
    (circumcision      . ("Isa" 9 2 7))
    (epiphany          . ("Isa" 60 1 9))
    (epiphany-1        . ("Prov" 1 1 9))
    (epiphany-2        . (("Isa" 61 10 nil) ("Isa" 62 1 4)))
    (epiphany-3        . ("1 Kgs" 8 22 30))   ; v.41-43 also appointed; joined lesson
    (epiphany-4        . ("Job" 38 1 18))
    ;; Epiphany 5: 1662 E&G (Col 3:12-17 / Matt 13:24-30). OT: Dan 12:1-4.
    (epiphany-5        . ("Dan" 12 1 4))
    (epiphany-6        . ("Isa" 63 15 19))

    ;; ---- Gesima & Lent ----
    (septuagesima      . ("Deut" 34 1 12))
    (sexagesima        . ("Exod" 16 11 21))
    (quinquagesima     . ("Exod" 34 1 8))
    (ash-wednesday     . ("Joel" 2 12 19))
    (lent-1            . ("Deut" 8 1 10))
    (lent-2            . ("Josh" 2 1 14))
    (lent-3            . ("Deut" 12 1 7))
    (lent-4            . ("Deut" 15 1 11))
    (lent-5            . ("Isa" 1 10 20))
    (palm-sunday       . ("Isa" 33 13 17))
    (monday-holy-week  . ("Isa" 63))
    (tuesday-holy-week . ("Isa" 50 5 11))
    (wednesday-holy-week . ("Isa" 53 4 7))
    (thursday-holy-week  . ("Exod" 24 3 11))
    (good-friday       . ("Exod" 12 1 14))    ; vv.1-6, 12-14
    (easter-eve        . ("Exod" 14 19 22))

    ;; ---- Easter ----
    (easter            . ("Isa" 25 6 9))
    (easter-monday     . ("Song" 2 8 13))
    (easter-tuesday    . ("Song" 6 4 10))
    (easter-1          . ("Acts" 2 41 47))
    (easter-2          . ("Acts" 4 1 12))
    (easter-3          . ("Acts" 4 23 31))
    (easter-4          . ("Acts" 4 32 35))
    (easter-5          . ("Acts" 9 32 42))
    (ascension         . ("Dan" 7 13 14))
    (sunday-after-ascension . ("Isa" 32 14 17))
    (whitsunday        . ("Wis" 7 22 27))
    (whit-monday       . ("Jer" 31 31 34))
    (whit-tuesday      . ("Ezek" 11 17 20))

    ;; ---- Trinity ----
    (trinity-sunday    . ("Isa" 57 15 21))
    (trinity-1         . ("2 Sam" 9 1 11))
    (trinity-2         . ("Dan" 9 15 19))
    (trinity-3         . ("1 Sam" 17 32 50))
    (trinity-4         . ("Lam" 3 22 32))
    (trinity-5         . ("Isa" 6 1 8))
    (trinity-6         . ("Jonah" 2))
    (trinity-7         . ("Isa" 55 1 5))
    (trinity-8         . ("Deut" 30 11 20))
    (trinity-9         . ("Prov" 8 1 13))
    (trinity-10        . ("1 Kgs" 8 22 30))
    (trinity-11        . ("1 Chr" 29 10 15))
    (trinity-12        . ("Exod" 4 10 12))
    (trinity-13        . ("Gen" 26 1 5))
    (trinity-14        . ("2 Kgs" 5 9 19))
    (trinity-15        . ("Josh" 24 14 25))
    (trinity-16        . ("Deut" 7 6 9))
    (trinity-17        . ("Ezek" 37 21 28))
    (trinity-18        . ("2 Sam" 7 8 14))
    (trinity-19        . ("Prov" 2 1 22))   ; vv.1-10, 20-22
    (trinity-20        . ("Prov" 1 20 33))
    (trinity-21        . ("Isa" 11 1 5))
    (trinity-22        . ("Isa" 2 10 18))
    (trinity-23        . ("Hag" 2 4 9))
    (trinity-24        . ("Ezek" 47 1 12))
    ;; Sunday Next Before Advent = Trinity 25 in traditional numbering.
    ;; Dan 12:1-4 is thematically eschatological, matching both the gospel
    ;; (John 6:5-14) and the epistle (Jer 23:5-8).
    (sunday-before-advent . ("Dan" 12 1 4))

    ;; ---- Fixed Feasts ----
    (andrew            . ("Zech" 8 20 23))
    (thomas            . ("Job" 42 1 6))
    (conversion-st-paul . ("Jer" 1 4 10))
    (purification-bvm  . ("Mal" 3 1 5))
    (matthias          . ("Exod" 24 1 4))
    (annunciation      . ("Isa" 7 10 15))
    (mark              . ("Ecclus" 51 13 30))
    (philip-and-james  . ("Mal" 3 16 18))
    (barnabas          . ("Job" 29 11 16))
    (john-baptist      . ("Isa" 40 1 11))
    (peter             . ("Ezek" 34 11 16))
    (james             . ("Jer" 45))
    (transfiguration   . (("Exod" 33 18 nil) ("Exod" 34 1 7)))
    (bartholomew       . ("Deut" 18 15 19))
    (holy-cross        . ("Isa" 45 21 25))
    (matthew           . ("Isa" 33 13 17))
    (michael           . ("Isa" 14 12 17))
    (luke              . ("Isa" 43 8 13))
    (simon-and-jude    . ("Isa" 28 9 16))
    (all-saints        . ("Ecclus" 44 1 15)))

  "First Lessons for the Communion service.

Each entry: (SYMBOL . REF) where REF follows bcp-1662-propers-year.el format.

Source: The Lectionary of 1662, Adapted and Supplemented
        (Prayer Book Society of Canada, 2025).

`trinity-25' is an alias for `sunday-before-advent'.")

(defun bcp-1662-ot-reading (symbol)
  "Return the first lesson REF for SYMBOL, or nil.
`trinity-25' is an alias for `sunday-before-advent'."
  (let ((sym (if (eq symbol 'trinity-25) 'sunday-before-advent symbol)))
    (cdr (assq sym bcp-1662-ot-readings))))


;;;; ──────────────────────────────────────────────────────────────────────
;;;; Collects
;;;; ──────────────────────────────────────────────────────────────────────

(defconst bcp-1662-collects
  '(
    ;;;; ── Supplemental Sunday / Seasonal Collects ──────────────────────────

    ;; stephen collect is in the seasonal section above

    ;; circumcision collect is in the seasonal section above

    (epiphany-octave-sunday
     :name "Sunday in the Octave of the Epiphany"
     :text "O HEAVENLY Father, whose blessed Son Jesus Christ did take our nature upon him, and was baptized for our sakes in the river Jordan: Mercifully grant that we being regenerate, and made thy children by adoption and grace, may also be partakers of thy Holy Spirit; through him whom thou didst send to be our Saviour and Redeemer, even the same thy Son Jesus Christ our Lord. Amen.")

    ;; epiphany-1 collect is in the seasonal section above

    ;; epiphany-3 collect is in the seasonal section above

    ;; septuagesima collect is in the seasonal section above

    ;; sexagesima collect is in the seasonal section above

    ;; lent-1 collect is in the Lent & Holy Week section below

    ;; lent-3 collect is in the Lent & Holy Week section below

    (thursday-holy-week
     :name "Maundy Thursday"
     :text "O GOD, who in a wonderful sacrament hast left unto us a memorial of thy passion: Grant us so to reverence the holy mysteries of thy Body and Blood, that we may ever know within ourselves the fruit of thy redemption; who livest and reignest with the Father in the unity of the Holy Ghost, one God, world without end. Amen.")

    ;; easter-1 collect is in the Easter season section below

    ;; trinity-24 collect is in the Trinity season section below

    ;;;; ── Feast Day Collects ────────────────────────────────────────────────

    ;; thomas collect is in the Apostles & Fixed Feasts section below

    ;; peter-confession collect is in the Apostles & Fixed Feasts section below

    ;; mark collect is in the Apostles & Fixed Feasts section below

    ;; philip-and-james collect is in the Apostles & Fixed Feasts section below

    ;; barnabas collect is in the Apostles & Fixed Feasts section below

    (peter-and-paul
     :name "Sts Peter and Paul, Apostles (Jun 29)"
     :text "O GOD, who didst give such grace unto thy holy Apostles Saint Peter and Saint Paul, that they were enabled to bear witness to the truth by their death: Grant unto thy Church that, as in the beginning it was enlightened by their teaching, so it may continue in the same unto the coming of our Lord Jesus Christ; who liveth and reigneth with thee and the Holy Spirit, one God, world without end. Amen.")

    ;; james collect is in the Apostles & Fixed Feasts section below

    ;; luke collect is in the Apostles & Fixed Feasts section below

    ;; simon-and-jude collect is in the Apostles & Fixed Feasts section below

    (all-souls
     :name "All Souls Day (Nov 2)"
     :text "MOST merciful Father, who hast been pleased to take unto thyself our brethren departed: Grant to us who are still in our pilgrimage, and who walk as yet by faith, that having served thee faithfully in this world, we may, with all faithful Christian souls, be joined hereafter to the company of thy blessed Saints in glory; through Jesus Christ our Lord, who with thee and the Holy Spirit liveth and reigneth, one God, world without end. Amen.")

    (bvm-feasts
     :name "Feasts of the Blessed Virgin Mary"
     :text "O GOD Most High, who didst endue with wonderful virtue and grace the Blessed Virgin Mary, the Mother of our Lord: Grant that we, who now call her blessed, may be made very members of the heavenly family of him who was pleased to be called the first-born among many brethren; who liveth and reigneth with thee and the Holy Spirit, one God, world without end. Amen.")

    ;;;; ── Apostles & Fixed Feast Collects (BCP 1662 text) ─────────────────

    (andrew
     :name "St Andrew, Apostle (Nov 30)"
     :rubric "The Collect from the First Sunday in Advent is to be repeated every day, with the other Collects in Advent, from Advent Sunday until Christmas Eve."
     :text "ALMIGHTY God, who didst give such grace unto thy holy Apostle Saint Andrew, that he readily obeyed the calling of thy Son Jesus Christ, and followed him without delay; Grant unto us all, that we, being called by thy holy Word, may forthwith give up ourselves obediently to fulfil the holy commandments; through the same Jesus Christ our Lord. Amen.")

    (thomas
     :name "St Thomas, Apostle (Dec 21)"
     :text "ALMIGHTY and everliving God, who for the more confirmation of the faith didst suffer thy holy Apostle Thomas to be doubtful in thy Son's resurrection; Grant us so perfectly, and without all doubt, to believe in thy Son Jesus Christ, that our faith in thy sight may never be reproved. Hear us, O Lord, through the same Jesus Christ, to whom, with thee and the Holy Ghost, be all honour and glory, now and for evermore. Amen.")

    (conversion-st-paul
     :name "Conversion of St Paul (Jan 25)"
     :text "O GOD, who, through the preaching of the blessed Apostle Saint Paul, hast caused the light of the Gospel to shine throughout the world; Grant, we beseech thee, that we, having his wonderful conversion in remembrance, may shew forth our thankfulness unto thee for the same, by following the holy doctrine which he taught; through Jesus Christ our Lord. Amen.")

    (purification-bvm
     :name "Purification of the Blessed Virgin Mary (Feb 2)"
     :text "ALMIGHTY and everliving God, we humbly beseech thy Majesty, that, as thy only-begotten Son was this day presented in the temple in substance of our flesh, so we may be presented unto thee with pure and clean hearts, by the same thy Son Jesus Christ our Lord. Amen.")

    (matthias
     :name "St Matthias, Apostle (Feb 24)"
     :text "ALMIGHTY God, who into the place of the traitor Judas didst choose thy faithful servant Matthias to be of the number of the twelve Apostles; Grant that thy Church, being alway preserved from false Apostles, may be ordered and guided by faithful and true pastors; through Jesus Christ our Lord. Amen.")

    (annunciation
     :name "Annunciation of the Blessed Virgin Mary (Mar 25)"
     :text "WE beseech thee, O Lord, pour thy grace into our hearts; that, as we have known the incarnation of thy Son Jesus Christ by the message of an angel, so by his cross and passion we may be brought unto the glory of his resurrection; through the same Jesus Christ our Lord. Amen.")

    (mark
     :name "St Mark, Evangelist (Apr 25)"
     :text "ALMIGHTY God, who hast instructed thy holy Church with the heavenly doctrine of thy Evangelist Saint Mark; Give us grace, that, being not like children carried away with every blast of vain doctrine, we may be established in the truth of thy holy Gospel; through Jesus Christ our Lord. Amen.")

    (philip-and-james
     :name "Sts Philip and James, Apostles (May 1)"
     :text "ALMIGHTY God, whom truly to know is everlasting life; Grant us perfectly to know thy Son Jesus Christ to be the way, the truth, and the life; that, following the steps of thy holy Apostles, Saint Philip and Saint James, we may stedfastly walk in the way that leadeth to eternal life; through the same thy Son Jesus Christ our Lord. Amen.")

    (barnabas
     :name "St Barnabas, Apostle (Jun 11)"
     :text "O LORD God Almighty, who didst endue thy holy Apostle Barnabas with singular gifts of the Holy Ghost; Leave us not, we beseech thee, destitute of thy manifold gifts, nor yet of grace to use them alway to thy honour and glory; through Jesus Christ our Lord. Amen.")

    (john-baptist
     :name "St John the Baptist (Jun 24)"
     :text "ALMIGHTY God, by whose providence thy servant John Baptist was wonderfully born, and sent to prepare the way of thy Son our Saviour, by preaching of repentance; Make us so to follow his doctrine and holy life, that we may truly repent according to his preaching; and after his example constantly speak the truth, boldly rebuke vice, and patiently suffer for the truth's sake; through Jesus Christ our Lord. Amen.")

    (peter
     :name "St Peter, Apostle (Jun 29)"
     :text "ALMIGHTY God, who by thy Son Jesus Christ didst give to thy Apostle Saint Peter many excellent gifts, and commandedst him earnestly to feed thy flock; Make, we beseech thee, all Bishops and Pastors diligently to preach thy holy Word, and the people obediently to follow the same, that they may receive the crown of everlasting glory; through Jesus Christ our Lord. Amen.")

    (james
     :name "St James, Apostle (Jul 25)"
     :text "GRANT, O merciful God, that as thine holy Apostle Saint James, leaving his father and all that he had, without delay was obedient unto the calling of thy Son Jesus Christ, and followed him; so we, forsaking all worldly and carnal affections, may be evermore ready to follow thy holy commandments; through Jesus Christ our Lord. Amen.")

    (bartholomew
     :name "St Bartholomew, Apostle (Aug 24)"
     :text "ALMIGHTY and everlasting God, who didst give to thine Apostle Bartholomew grace truly to believe and to preach thy Word; Grant, we beseech thee, unto thy Church, to love that Word which he believed, and both to preach and receive the same; through Jesus Christ our Lord. Amen.")

    (matthew
     :name "St Matthew, Apostle and Evangelist (Sep 21)"
     :text "ALMIGHTY God, who by thy blessed Son didst call Matthew from the receipt of custom to be an Apostle and Evangelist; Grant us grace to forsake all covetous desires, and inordinate love of riches, and to follow the same thy Son Jesus Christ, who liveth and reigneth with thee and the Holy Ghost, one God, world without end. Amen.")

    (michael
     :name "St Michael and All Angels (Sep 29)"
     :text "EVERLASTING God, who hast ordained and constituted the services of Angels and men in a wonderful order; Mercifully grant, that as thy holy Angels alway do thee service in heaven, so by thy appointment they may succour and defend us on earth; through Jesus Christ our Lord. Amen.")

    (luke
     :name "St Luke, Evangelist (Oct 18)"
     :text "ALMIGHTY God, who calledst Luke the Physician, whose praise is in the Gospel, to be an Evangelist, and Physician of the soul; May it please thee, that, by the wholesome medicines of the doctrine delivered by him, all the diseases of our souls may be healed; through the merits of thy Son Jesus Christ our Lord. Amen.")

    (simon-and-jude
     :name "Sts Simon and Jude, Apostles (Oct 28)"
     :text "ALMIGHTY God, who hast built thy Church upon the foundation of the Apostles and Prophets, Jesus Christ himself being the head corner-stone; Grant us so to be joined together in unity of spirit by their doctrine, that we may be made an holy temple acceptable unto thee; through Jesus Christ our Lord. Amen.")

    (all-saints
     :name "All Saints' Day (Nov 1)"
     :text "ALMIGHTY God, who hast knit together thine elect in one communion and fellowship, in the mystical body of thy Son Christ our Lord; Grant us grace so to follow thy blessed Saints in all virtuous and godly living, that we may come to those unspeakable joys, which thou hast prepared for them that unfeignedly love thee; through Jesus Christ our Lord. Amen.")

    ;;;; ── Ember Days ────────────────────────────────────────────────────────

    (ember-advent
     :name "Advent Ember Days"
     :text "ALMIGHTY Lord and everlasting Father, who wouldest have the kingdoms of the world become the kingdom of thy Son Jesus Christ: Bestow thy blessing, we beseech thee, upon all who labour for peace and righteousness among the nations, that the day may be hastened when war shall be no more, and thou shalt take the nations for thine inheritance; through the same Jesus Christ our Lord. Amen.")

    (ember-autumn
     :name "Autumn Ember Days (after Holy Cross Day)"
     :text "O LORD Jesus Christ, who in thy earthly life didst share man's toil, and thereby hallow the labour of his hands: Prosper all those who maintain the industries of this land; and give them pride in their work, a just reward for their labour, and joy both in supplying the needs of others and in serving thee their Saviour; who with the Father and the Holy Spirit livest and reignest, ever one God, world without end. Amen.")

    ;;;; ── Rogation Days ─────────────────────────────────────────────────────

    (rogation-1
     :name "Rogation Days I"
     :text "ASSIST us mercifully, O Lord, in these our supplications and prayers, and dispose the way of thy servants towards the attainment of everlasting salvation; that, among all the changes and chances of this mortal life, they may ever be defended by thy most gracious and ready help; through Jesus Christ our Lord. Amen.")

    (rogation-2
     :name "Rogation Days II"
     :text "ALMIGHTY and merciful God, from whom cometh every good and perfect gift: Bless, we beseech thee, the labours of thy people, and cause the earth to bring forth her fruits abundantly in their season, that we may with grateful hearts give thanks to thee for the same; through Jesus Christ our Lord. Amen.")

    ;;;; ── Occasional ────────────────────────────────────────────────────────

    (world-missions
     :name "World Missions"
     :text "ALMIGHTY and everlasting God, who desirest not the death of sinners, but rather that they may turn unto thee and live: Deliver the nations of the world from superstition and unbelief, and gather them all into thy holy Church, to the praise and glory of thy Name; through Jesus Christ our Lord. Amen.")

    ;;;; ── Advent Collects ─────────────────────────────────────────────────

    ;; Advent 1 is appointed to be repeated every day until Christmas Eve,
    ;; along with the other Advent collects.
    (advent-1
     :name "First Sunday of Advent"
     :rubric "To be repeated every day, with the other Collects in Advent, until Christmas Eve."
     :text "ALMIGHTY God, give us grace that we may cast away the works of darkness, and put upon us the armour of light, now in the time of this mortal life in which thy Son Jesus Christ came to visit us in great humility; that in the last day, when he shall come again in his glorious majesty to judge both the quick and the dead, we may rise to the life immortal; through him who liveth and reigneth with thee and the Holy Ghost, one God, now and for ever. Amen.")

    (advent-2
     :name "Second Sunday in Advent"
     :rubric "The Collect from the First Sunday in Advent is to be repeated every day, with the other Collects in Advent, until Christmas Eve."
     :text "BLESSED Lord, who hast caused all holy Scriptures to be written for our learning; Grant that we may in such wise hear them, read, mark, learn, and inwardly digest them, that by patience and comfort of thy holy Word, we may embrace, and ever hold fast, the blessed hope of everlasting life, which thou hast given us in our Saviour Jesus Christ. Amen.")

    (advent-3
     :name "Third Sunday in Advent"
     :text "O LORD Jesu Christ, who at thy first coming didst send thy messenger to prepare thy way before thee; Grant that the ministers and stewards of thy mysteries may likewise so prepare and make ready thy way, by turning the hearts of the disobedient to the wisdom of the just, that at thy second coming to judge the world we may be found an acceptable people in thy sight, who livest and reignest with the Father and the Holy Spirit ever, one God, world without end. Amen.")

    (advent-4
     :name "Fourth Sunday in Advent"
     :text "O LORD, raise up (we pray thee) thy power, and come among us, and with great might succour us; that whereas, through our sins and wickedness, we are sore let and hindered in running the race that is set before us, thy bountiful grace and mercy may speedily help and deliver us; through the satisfaction of thy Son our Lord, to whom with thee and the Holy Ghost be honour and glory, world without end. Amen.")

    ;;;; ── Christmas & Epiphany Collects ────────────────────────────────────

    ;; The Christmas collect serves also for the Sunday after Christmas.
    ;; The Circumcision collect serves every day from Jan 1 to the Epiphany.
    ;; Stephen: the Christmas collect is to be read continually unto New Year's Eve.
    (christmas
     :name "Christmas Day (The Nativity of our Lord)"
     :rubric "The Collect of Christmas shall be said continually unto New Year's Eve."
     :text "ALMIGHTY God, who hast given us thy only-begotten Son to take our nature upon him, and as at this time to be born of a pure Virgin; Grant that we being regenerate, and made thy children by adoption and grace, may daily be renewed by thy Holy Spirit; through the same our Lord Jesus Christ, who liveth and reigneth with thee and the same Spirit, ever one God, world without end. Amen.")

    (stephen
     :name "St Stephen, Deacon and First Martyr (Dec 26)"
     :text "GRANT, O Lord, that, in all our sufferings here upon earth for the testimony of thy truth, we may stedfastly look up to heaven, and by faith behold the glory that shall be revealed; and, being filled with the Holy Ghost, may learn to love and bless our persecutors by the example of thy first Martyr Saint Stephen, who prayed for his murderers to thee, O blessed Jesus, who standest at the right hand of God to succour all those that suffer for thee, our only Mediator and Advocate. Amen.")

    (john-evangelist
     :name "St John, Apostle and Evangelist (Dec 27)"
     :text "MERCIFUL Lord, we beseech thee to cast thy bright beams of light upon thy Church, that it being enlightened by the doctrine of thy blessed Apostle and Evangelist Saint John may so walk in the light of thy truth, that it may at length attain to the light of everlasting life; through Jesus Christ our Lord. Amen.")

    (innocents
     :name "Innocents' Day (Dec 28)"
     :text "ALMIGHTY God, who out of the mouths of babes and sucklings hast ordained strength, and madest infants to glorify thee by their deaths; Mortify and kill all vices in us, and so strengthen us by thy grace, that by the innocency of our lives, and constancy of our faith even unto death, we may glorify thy holy Name; through Jesus Christ our Lord. Amen.")

    (sunday-after-christmas
     :name "Sunday after Christmas Day"
     :text "ALMIGHTY God, who hast given us thy only-begotten Son to take our nature upon him, and as at this time to be born of a pure Virgin; Grant that we being regenerate, and made thy children by adoption and grace, may daily be renewed by thy Holy Spirit; through the same our Lord Jesus Christ, who liveth and reigneth with thee and the same Spirit, one God, world without end. Amen.")

    (circumcision
     :name "Circumcision of Christ (Jan 1)"
     :rubric "The same Collect, Epistle, and Gospel shall serve for every day after unto the Epiphany."
     :text "ALMIGHTY God, who madest thy blessed Son to be circumcised, and obedient to the law for man; Grant us the true Circumcision of the Spirit; that, our hearts, and all our members, being mortified from all worldly and carnal lusts, we may in all things obey thy blessed will; through the same thy Son Jesus Christ our Lord. Amen.")

    (epiphany
     :name "The Epiphany (Manifestation of Christ to the Gentiles)"
     :text "O GOD, who by the leading of a star didst manifest thy only-begotten Son to the Gentiles: Mercifully grant, that we, which know thee now by faith, may after this life have the fruition of thy glorious Godhead; through Jesus Christ our Lord. Amen.")

    ;;;; ── Epiphany Season Collects ──────────────────────────────────────────

    (epiphany-1
     :name "First Sunday after the Epiphany"
     :text "O LORD, we beseech thee mercifully to receive the prayers of thy people which call upon thee; and grant that they may both perceive and know what things they ought to do, and also may have grace and power faithfully to fulfil the same; through Jesus Christ our Lord. Amen.")

    (epiphany-2
     :name "Second Sunday after the Epiphany"
     :text "ALMIGHTY and everlasting God, who dost govern all things in heaven and earth; Mercifully hear the supplications of thy people, and grant us thy peace all the days of our life; through Jesus Christ our Lord. Amen.")

    (epiphany-3
     :name "Third Sunday after the Epiphany"
     :text "ALMIGHTY and everlasting God, mercifully look upon our infirmities, and in all our dangers and necessities stretch forth thy right hand to help and defend us; through Jesus Christ our Lord. Amen.")

    (epiphany-4
     :name "Fourth Sunday after the Epiphany"
     :text "O GOD, who knowest us to be set in the midst of so many and great dangers, that by reason of the frailty of our nature we cannot always stand upright; Grant to us such strength and protection, as may support us in all dangers, and carry us through all temptations; through Jesus Christ our Lord. Amen.")

    (epiphany-5
     :name "Fifth Sunday after the Epiphany"
     :text "O LORD, we beseech thee to keep thy Church and household continually in thy true religion; that they who do lean only upon the hope of thy heavenly grace may evermore be defended by thy mighty power; through Jesus Christ our Lord. Amen.")

    (epiphany-6
     :name "Sixth Sunday after the Epiphany"
     :text "O GOD, whose blessed Son was manifested that he might destroy the works of the devil, and make us the sons of God, and heirs of eternal life; Grant us, we beseech thee, that, having this hope, we may purify ourselves, even as he is pure; that, when he shall appear again with power and great glory, we may be made like unto him in his eternal and glorious kingdom; where with thee, O Father, and thee, O Holy Ghost, he liveth and reigneth, ever one God, world without end. Amen.")

    ;;;; ── Gesima Collects ───────────────────────────────────────────────────

    (septuagesima
     :name "Septuagesima (Third Sunday before Lent)"
     :text "O LORD, we beseech thee favourably to hear the prayers of thy people; that we, who are justly punished for our offences, may be mercifully delivered by thy goodness, for the glory of thy Name; through Jesus Christ our Saviour, who liveth and reigneth with thee and the Holy Ghost, ever one God, world without end. Amen.")

    (sexagesima
     :name "Sexagesima (Second Sunday before Lent)"
     :text "O LORD God, who seest that we put not our trust in any thing that we do; Mercifully grant that by thy power we may be defended against all adversity; through Jesus Christ our Lord. Amen.")

    (quinquagesima
     :name "Quinquagesima (Sunday next before Lent)"
     :text "O LORD, who hast taught us that all our doings without charity are nothing worth; Send thy Holy Ghost and pour into our hearts that most excellent gift of charity, the very bond of peace and of all virtues, without which whosoever liveth is counted dead before thee; Grant this for thine only Son Jesus Christ's sake. Amen.")

    ;;;; ── Lent & Holy Week Collects ──────────────────────────────────────

    ;; Note: The Ash Wednesday collect is appointed to be read every day
    ;; in Lent after the collect for the day.  The Lent 1 collect carries
    ;; the same instruction.
    (ash-wednesday
     :name "Ash Wednesday (The First Day of Lent)"
     :rubric "To be read every day in Lent after the Collect appointed for the Day."
     :text "ALMIGHTY and everlasting God, who hatest nothing that thou hast made and dost forgive the sins of all them that are penitent; Create and make in us new and contrite hearts, that we, worthily lamenting our sins, and acknowledging our wretchedness, may obtain of thee, the God of all mercy, perfect remission and forgiveness; through Jesus Christ our Lord. Amen.")

    (lent-1
     :name "First Sunday in Lent"
     :rubric "The Collect from the First Day of Lent is to be read every day in Lent after the Collect appointed for the Day."
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

    (palm-sunday
     :name "Sunday Next Before Easter (Palm Sunday)"
     :text "ALMIGHTY and everlasting God, who, of thy tender love towards mankind, hast sent thy Son, our Saviour Jesus Christ, to take upon him our flesh, and to suffer death upon the cross, that all mankind should follow the example of his great humility; Mercifully grant, that we may both follow the example of his patience, and also be made partakers of his resurrection; through the same Jesus Christ our Lord. Amen.")

    (good-friday
     :name "Good Friday (First Collect)"
     :text "ALMIGHTY God, we beseech thee graciously to behold this thy family, for whom our Lord Jesus Christ was contented to be betrayed, and given up into the hands of wicked men, and to suffer death upon the cross, who now liveth and reigneth with thee and the Holy Ghost, ever one God, world without end. Amen.")

    (good-friday-2
     :name "Good Friday (Second Collect)"
     :text "ALMIGHTY and everlasting God, by whose Spirit the whole body of the Church is governed and sanctified; Receive our supplications and prayers, which we offer before thee for all estates of men in thy holy Church, that every member of the same, in his vocation and ministry, may truly and godly serve thee; through our Lord and Saviour Jesus Christ. Amen.")

    (good-friday-3
     :name "Good Friday (Third Collect)"
     :text "MERCIFUL God, who hast made all men, and hatest nothing that thou hast made, nor wouldest the death of a sinner, but rather that he should be converted and live; Have mercy upon all Jews, Turks, Infidels, and Hereticks, and take from them all ignorance, hardness of heart, and contempt of thy Word; and so fetch them home, blessed Lord, to thy flock, that they may be saved among the remnant of the true Israelites, and be made one fold under one shepherd, Jesus Christ our Lord, who liveth and reigneth with thee and the Holy Spirit, one God, world without end. Amen.")

    (easter-eve
     :name "Easter Even"
     :text "GRANT, O Lord, that as we are baptized into the death of thy blessed Son our Saviour Jesus Christ, so by continual mortifying our corrupt affections we may be buried with him; and that through the grave, and gate of death, we may pass to our joyful resurrection; for his merits, who died, and was buried, and rose again for us, thy Son Jesus Christ our Lord. Amen.")

    ;;;; ── Easter Anthems ──────────────────────────────────────────────────

    ;; At Morning Prayer on Easter Day, the Venite is replaced by these
    ;; anthems.  Stored as a single string with scripture citations embedded.
    (easter-anthems
     :name "Easter Anthems (at Morning Prayer, Easter Day)"
     :rubric "At Morning Prayer, instead of the Psalm O come let us sing, these Anthems shall be sung or said."
     :text "CHRIST our passover is sacrificed for us : therefore let us keep the feast; Not with the old leaven, nor with the leaven of malice and wickedness : but with the unleavened bread of sincerity and truth. [1 Cor. 5:7]
Christ being raised from the dead dieth no more : death hath no more dominion over him. For in that he died, he died unto sin once : but in that he liveth, he liveth unto God. Likewise reckon ye also yourselves to be dead indeed unto sin : but alive unto God through Jesus Christ our Lord. [Rom. 6:9]
Christ is risen from the dead : and become the first-fruits of them that slept. For since by man came death : by man came also the resurrection of the dead. For as in Adam all die : even so in Christ shall all be made alive. [1 Cor. 15:20]
Glory be to the Father, and to the Son : and to the Holy Ghost; As it was in the beginning, is now, and ever shall be : world without end. Amen.")

    ;;;; ── Easter Season Collects ───────────────────────────────────────────

    ;; Note: Easter Day, Easter Monday, and Easter Tuesday all share the
    ;; same collect text.  Minor textual variants between the three are
    ;; preserved exactly as in the BCP source.
    (easter
     :name "Easter Day"
     :text "ALMIGHTY God, who through thine only-begotten Son Jesus Christ hast overcome death, and opened unto us the gate of everlasting life; We humbly beseech thee, that, as by thy special grace preventing us thou dost put into our minds good desires, so by thy continual help we may bring the same to good effect; through Jesus Christ our Lord, who liveth and reigneth with thee and the Holy Ghost, ever one God, world without end. Amen.")

    (easter-monday
     :name "Monday in Easter Week"
     :text "ALMIGHTY God, who through thy only-begotten Son Jesus Christ hast overcome death, and opened unto us the gate of everlasting life; We humbly beseech thee, that, as by thy special grace preventing us thou dost put into our minds good desires, so by thy continual help we may bring the same to good effect; through Jesus Christ our Lord, who liveth and reigneth with thee and the Holy Ghost, ever one God, world without end. Amen.")

    (easter-tuesday
     :name "Tuesday in Easter Week"
     :text "ALMIGHTY God, who through thine only-begotten Son Jesus Christ hast overcome death, and opened unto us the gate of everlasting life; We humbly beseech thee, that, as by thy special grace preventing us thou dost put into our minds good desires, so by thy continual help we may bring the same to good effect; through Jesus Christ our Lord, who liveth and reigneth with thee and the Holy Ghost, ever one God, world without end. Amen.")

    (easter-1
     :name "First Sunday after Easter"
     :text "ALMIGHTY Father, who hast given thine only Son to die for our sins, and to rise again for our justification; Grant us so to put away the leaven of malice and wickedness, that we may alway serve thee in pureness of living and truth; through the merits of the same thy Son Jesus Christ our Lord. Amen.")

    (easter-2
     :name "Second Sunday after Easter"
     :text "ALMIGHTY God, who hast given thine only Son to be unto us both a sacrifice for sin, and also an ensample of godly life; Give us grace that we may always most thankfully receive that his inestimable benefit, and also daily endeavour ourselves to follow the blessed steps of his most holy life; through the same Jesus Christ our Lord. Amen.")

    (easter-3
     :name "Third Sunday after Easter"
     :text "ALMIGHTY God, who shewest to them that be in error the light of thy truth, to the intent that they may return into the way of righteousness; Grant unto all them that are admitted into the fellowship of Christ's Religion, that they may eschew those things that are contrary to their profession, and follow all such things as are agreeable to the same; through our Lord Jesus Christ. Amen.")

    (easter-4
     :name "Fourth Sunday after Easter"
     :text "ALMIGHTY God, who alone canst order the unruly wills and affections of sinful men; Grant unto thy people, that they may love the thing which thou commandest, and desire that which thou dost promise; that so, among the sundry and manifold changes of the world, our hearts may surely there be fixed, where true joys are to be found; through Jesus Christ our Lord. Amen.")

    (easter-5
     :name "Fifth Sunday after Easter (Rogation Sunday)"
     :text "O LORD, from whom all good things do come; Grant to us thy humble servants, that by thy holy inspiration we may think those things that be good, and by thy merciful guiding may perform the same; through our Lord Jesus Christ. Amen.")

    ;;;; ── Ascension & Whitsun Collects ─────────────────────────────────────

    (ascension
     :name "Ascension Day"
     :text "GRANT, we beseech thee, Almighty God, that like as we do believe thy only-begotten Son our Lord Jesus Christ to have ascended into the heavens; so we may also in heart and mind thither ascend, and with him continually dwell, who liveth and reigneth with thee and the Holy Ghost, one God, world without end. Amen.")

    (sunday-after-ascension
     :name "Sunday after Ascension Day"
     :text "O GOD the King of glory, who hast exalted thine only Son Jesus Christ with great triumph unto thy kingdom in heaven; We beseech thee, leave us not comfortless; but send to us thine Holy Ghost to comfort us, and exalt us unto the same place whither our Saviour Christ is gone before, who liveth and reigneth with thee and the Holy Ghost, one God, world without end. Amen.")

    ;; Whitsunday, Whit Monday, and Whit Tuesday share the same collect.
    ;; Minor textual variants between them preserved as in the BCP.
    (whitsunday
     :name "Whitsunday"
     :text "GOD, who as at this time didst teach the hearts of thy faithful people, by the sending to them the light of thy Holy Spirit; Grant us by the same Spirit to have a right judgement in all things, and evermore to rejoice in his holy comfort; through the merits of Christ Jesus our Saviour, who liveth and reigneth with thee, in the unity of the same Spirit, one God, world without end. Amen.")

    (whit-monday
     :name "Monday in Whitsun Week"
     :text "GOD, who as at this time didst teach the hearts of thy faithful people, by sending to them the light of thy Holy Spirit; Grant us by the same Spirit to have a right judgement in all things, and evermore to rejoice in his holy comfort; through the merits of Christ Jesus our Saviour, who liveth and reigneth with thee, in the unity of the same Spirit, one God, world without end. Amen.")

    (whit-tuesday
     :name "Tuesday in Whitsun Week"
     :text "GOD, who as at this time didst teach the hearts of thy faithful people, by sending to them the light of thy Holy Spirit; Grant us by the same Spirit to have a right judgement in all things, and evermore to rejoice in his holy comfort; through the merits of Christ Jesus our Saviour, who liveth and reigneth with thee, in the unity of the same Spirit, one God, world without end. Amen.")

    ;;;; ── Trinity Season Collects ─────────────────────────────────────────

    (trinity-sunday
     :name "Trinity Sunday"
     :text "ALMIGHTY and everlasting God, who hast given unto us thy servants grace, by the confession of a true faith to acknowledge the glory of the eternal Trinity, and in the power of the Divine Majesty to worship the Unity; We beseech thee, that thou wouldst keep us steadfast in this faith, and evermore defend us from all adversities, who livest and reignest, one God, world without end. Amen.")

    (trinity-1
     :name "First Sunday after Trinity"
     :text "O GOD, the strength of all them that put their trust in thee, mercifully accept our prayers; and because through the weakness of our mortal nature we can do no good thing without thee, grant us the help of thy grace, that in keeping of thy commandments we may please thee, both in will and deed; through Jesus Christ our Lord. Amen.")

    (trinity-2
     :name "Second Sunday after Trinity"
     :text "O LORD, who never failest to help and govern them whom thou dost bring up in thy stedfast fear and love; Keep us, we beseech thee, under the protection of thy good providence, and make us to have a perpetual fear and love of thy holy Name; through Jesus Christ our Lord. Amen.")

    (trinity-3
     :name "Third Sunday after Trinity"
     :text "O LORD, we beseech thee mercifully to hear us; and grant that we, to whom thou hast given an hearty desire to pray, may by thy mighty aid be defended and comforted in all dangers and adversities; through Jesus Christ our Lord. Amen.")

    (trinity-4
     :name "Fourth Sunday after Trinity"
     :text "O GOD, the protector of all that trust in thee, without whom nothing is strong, nothing is holy; Increase and multiply upon us thy mercy; that, thou being our ruler and guide, we may so pass through things temporal, that we finally lose not the things eternal: Grant this, O heavenly Father, for Jesus Christ's sake our Lord. Amen.")

    (trinity-5
     :name "Fifth Sunday after Trinity"
     :text "GRANT, O Lord, we beseech thee, that the course of this world may be so peaceably ordered by thy governance, that thy Church may joyfully serve thee in all godly quietness; through Jesus Christ our Lord. Amen.")

    (trinity-6
     :name "Sixth Sunday after Trinity"
     :text "O GOD, who hast prepared for them that love thee such good things as pass man's understanding; Pour into our hearts such love toward thee, that we, loving thee above all things, may obtain thy promises, which exceed all that we can desire; through Jesus Christ our Lord. Amen.")

    (trinity-7
     :name "Seventh Sunday after Trinity"
     :text "LORD of all power and might, who art the author and giver of all good things; Graft in our hearts the love of thy Name, increase in us true religion, nourish us with all goodness, and of thy great mercy keep us in the same; through Jesus Christ our Lord. Amen.")

    (trinity-8
     :name "Eighth Sunday after Trinity"
     :text "O GOD, whose never-failing providence ordereth all things both in heaven and earth; We humbly beseech thee to put away from us all hurtful things, and to give us those things which be profitable for us; through Jesus Christ our Lord. Amen.")

    (trinity-9
     :name "Ninth Sunday after Trinity"
     :text "GRANT to us, Lord, we beseech thee, the spirit to think and do always such things as be rightful; that we, who cannot do any thing that is good without thee, may by thee be enabled to live according to thy will; through Jesus Christ our Lord. Amen.")

    (trinity-10
     :name "Tenth Sunday after Trinity"
     :text "LET thy merciful ears, O Lord, be open to the prayers of thy humble servants; and that they may obtain their petitions make them to ask such things as shall please thee; through Jesus Christ our Lord. Amen.")

    (trinity-11
     :name "Eleventh Sunday after Trinity"
     :text "O GOD, who declarest thy almighty power most chiefly in shewing mercy and pity; Mercifully grant unto us such a measure of thy grace, that we, running the way of thy commandments, may obtain thy gracious promises, and be made partakers of thy heavenly treasure; through Jesus Christ our Lord. Amen.")

    (trinity-12
     :name "Twelfth Sunday after Trinity"
     :text "ALMIGHTY and everlasting God, who art always more ready to hear than we are to pray, and art wont to give more than either we desire, or deserve; Pour down upon us the abundance of thy mercy; forgiving us those things whereof our conscience is afraid, and giving us those good things which we are not worthy to ask, but through the merits and mediation of Jesus Christ, thy Son, our Lord. Amen.")

    (trinity-13
     :name "Thirteenth Sunday after Trinity"
     :text "ALMIGHTY and merciful God, of whose only gift it cometh that thy faithful people do unto thee true and laudable service; Grant, we beseech thee, that we may so faithfully serve thee in this life, that we fail not finally to attain thy heavenly promises; through the merits of Jesus Christ our Lord. Amen.")

    (trinity-14
     :name "Fourteenth Sunday after Trinity"
     :text "ALMIGHTY and everlasting God, give unto us the increase of faith, hope, and charity; and, that we may obtain that which thou dost promise, make us to love that which thou dost command; through Jesus Christ our Lord. Amen.")

    (trinity-15
     :name "Fifteenth Sunday after Trinity"
     :text "KEEP, we beseech thee, O Lord, thy Church with thy perpetual mercy: and, because the frailty of man without thee cannot but fall, keep us ever by thy help from all things hurtful, and lead us to all things profitable to our salvation; through Jesus Christ our Lord. Amen.")

    (trinity-16
     :name "Sixteenth Sunday after Trinity"
     :text "O LORD, we beseech thee, let thy continual pity cleanse and defend thy Church; and, because it cannot continue in safety without thy succour, preserve it evermore by thy help and goodness; through Jesus Christ our Lord. Amen.")

    (trinity-17
     :name "Seventeenth Sunday after Trinity"
     :text "LORD, we pray thee that thy grace may always prevent and follow us, and make us continually to be given to all good works; through Jesus Christ our Lord. Amen.")

    (trinity-18
     :name "Eighteenth Sunday after Trinity"
     :text "LORD, we beseech thee, grant thy people grace to withstand the temptations of the world, the flesh, and the devil, and with pure hearts and minds to follow thee the only God; through Jesus Christ our Lord. Amen.")

    (trinity-19
     :name "Nineteenth Sunday after Trinity"
     :text "O GOD, forasmuch as without thee we are not able to please thee; Mercifully grant, that thy Holy Spirit may in all things direct and rule our hearts; through Jesus Christ our Lord. Amen.")

    (trinity-20
     :name "Twentieth Sunday after Trinity"
     :text "ALMIGHTY and most merciful God, of thy bountiful goodness keep us, we beseech thee, from all things that may hurt us; that we, being ready both in body and soul, may cheerfully accomplish those things that thou wouldest have done; through Jesus Christ our Lord. Amen.")

    (trinity-21
     :name "Twenty-first Sunday after Trinity"
     :text "GRANT, we beseech thee, merciful Lord, to thy faithful people pardon and peace, that they may be cleansed from all their sins, and serve thee with a quiet mind; through Jesus Christ our Lord. Amen.")

    (trinity-22
     :name "Twenty-second Sunday after Trinity"
     :text "LORD, we beseech thee to keep thy household the Church in continual godliness; that through thy protection it may be free from all adversities, and devoutly given to serve thee in good works, to the glory of thy Name; through Jesus Christ our Lord. Amen.")

    (trinity-23
     :name "Twenty-third Sunday after Trinity"
     :text "O GOD, our refuge and strength, who art the author of all godliness; Be ready, we beseech thee, to hear the devout prayers of thy Church; and grant that those things which we ask faithfully we may obtain effectually; through Jesus Christ our Lord. Amen.")

    (trinity-24
     :name "Twenty-fourth Sunday after Trinity"
     :text "O LORD, we beseech thee, absolve thy people from their offences; that through thy bountiful goodness we may all be delivered from the bands of those sins, which by our frailty we have committed: Grant this, O heavenly Father, for Jesus Christ's sake, our blessed Lord and Saviour. Amen.")

    ;; Sunday Next Before Advent = Trinity 25 in traditional numbering.
    ;; The collect "Stir up" is traditionally the last collect of Trinity,
    ;; always used on the Sunday immediately before Advent Sunday.
    (sunday-before-advent
     :name "Sunday Next Before Advent (Trinity 25)"
     :text "STIR up, we beseech thee, O Lord, the wills of thy faithful people; that they, plenteously bringing forth the fruit of good works, may of thee be plenteously rewarded; through Jesus Christ our Lord. Amen.")

    ;;;; ── Commons ───────────────────────────────────────────────────────────

    (common-any-saint
     :name "Common of Any Saint"
     :text "O ALMIGHTY God, who willest to be glorified in thy Saints, and didst raise up thy servant N. to shine as a light in the world: Shine, we pray thee, in our hearts, that we also in our generation may show forth thy praises, who hast called us out of darkness into thy marvellous light; through Jesus Christ our Lord. Amen.")

    (common-martyr-1
     :name "Common of Martyrs I"
     :text "ALMIGHTY God, by whose grace and power thy Martyr N. was enabled to witness to the truth and to be faithful unto death: Grant that we, who now remember him before thee, may likewise so bear witness unto thee in this world, that we may receive with him the crown of glory that fadeth not away; through Jesus Christ our Lord, who with thee and the Holy Spirit liveth and reigneth, one God, for ever and ever. Amen.")

    (common-martyr-2
     :name "Common of Martyrs II"
     :text "O GOD, who didst bestow upon thy Saints such marvellous virtue, that they were able to stand fast, and have the victory against the world, the flesh, and the devil: Grant that we, who now commemorate thy Martyr N., may ever rejoice in their fellowship, and also be enabled by thy grace to fight the good fight of faith and lay hold upon eternal life; through our Lord Jesus Christ, who with thee and the Holy Spirit liveth and reigneth, one God, for ever and ever. Amen.")

    (common-missionary
     :name "Common of Missionaries"
     :text "O GOD, our heavenly Father, who by thy Son Jesus Christ didst call thy blessed Apostles and send them forth to preach thy Gospel of salvation unto all the nations: We bless thy holy Name for thy servant N., whose labours we commemorate this day, and we pray thee, according to thy holy Word, to send forth many labourers into thy harvest; through the same Jesus Christ our Lord, who liveth and reigneth with thee and the Holy Spirit, one God, for ever and ever. Amen.")

    (common-holy-woman
     :name "Common of Holy Women"
     :text "O GOD Most High, the creator of all mankind, we bless thy holy Name for the virtue and grace which thou hast given unto holy women in all ages, especially thy servant N.; and we pray that the example of her faith and purity, and courage unto death, may inspire many souls in this generation to look unto thee, and to follow thy blessed Son Jesus Christ our Saviour; who with thee and the Holy Spirit liveth and reigneth, one God, world without end. Amen.")

    (common-doctor
     :name "Common of Doctors and Teachers"
     :text "O GOD, who by thy Holy Spirit hast given unto one man a word of wisdom, and to another a word of knowledge, and to another the gift of tongues: We praise thy Name for the gifts of grace manifested in thy servant N., and we pray that thy Church may never be destitute of the same; through Jesus Christ our Lord. Amen.")

    (common-founder
     :name "Common of Founders"
     :text "ALMIGHTY God, our heavenly Father, we remember before thee all thy servants who have served thee faithfully in their generation, and have entered into rest, especially N. [and N.]; beseeching thee to give us grace so to follow in their steps, that with them we may be partakers of thy heavenly kingdom; through Jesus Christ our Lord. Amen."))

  "Supplemental and feast-day collects for the 1662 BCP.

Each entry: (SYMBOL :name STRING :text STRING)

Standard Sunday collects already in the BCP text are not included here.
Commons use \\='N.' as a placeholder for the saint's name.")

(defun bcp-1662-collect (symbol)
  "Return the collect plist for SYMBOL, or nil.
Returns (:name STRING :text STRING).

`trinity-25' is an alias for `sunday-before-advent'."
  (let ((sym (if (eq symbol 'trinity-25) 'sunday-before-advent symbol)))
    (cdr (assq sym bcp-1662-collects))))

(defun bcp-1662-collect-text (symbol)
  "Return the collect text string for SYMBOL, or nil."
  (plist-get (bcp-1662-collect symbol) :text))


(provide 'bcp-1662-data)
;;; bcp-1662-data.el ends here
