; SOFT Examples from the ACL2-2015 Workshop paper
;
; Copyright (C) 2015 Kestrel Institute (http://www.kestrel.edu)
;
; License (an MIT license):
;
;   Permission is hereby granted, free of charge, to any person obtaining a
;   copy of this software and associated documentation files (the "Software"),
;   to deal in the Software without restriction, including without limitation
;   the rights to use, copy, modify, merge, publish, distribute, sublicense,
;   and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in
;   all copies or substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;   DEALINGS IN THE SOFTWARE.
;
; Original author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the SOFT ('Second-Order Functions and Theorems') examples
; in the ACL2-2015 Workshop paper "Second-Order Functions and Theorems in ACL2".

; Comments indicate the sections and subsections of the paper.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "soft")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 1  Second-Order Functions and Theorems

; 1.1  Function Variables

(defunvar ?f (*) => *)

(defunvar ?p (*) => *)

(defunvar ?g (* *) => *)

; 1.2   Second-Order Functions

; 1.2.1   Plain Functions

; Matt K.: Avoid ACL2(p) error in quad[?f] below pertaining to override hints.
(local (set-waterfall-parallelism nil))

(defun2 quad[?f] (?f) (x)
  (?f (?f (?f (?f x)))))

(defun2 all[?p] (?p) (l)
  (cond ((atom l) (null l))
        (t (and (?p (car l))
                (all[?p] (cdr l))))))

(defun2 map[?f_?p] (?f ?p) (l)
  (declare (xargs :guard (all[?p] l)))
  (cond ((endp l) nil)
        (t (cons (?f (car l))
                 (map[?f_?p] (cdr l))))))

(defun2 fold[?f_?g] (?f ?g) (bt)
  (cond ((atom bt) (?f bt))
        (t (?g (fold[?f_?g] (car bt))
               (fold[?f_?g] (cdr bt))))))

; 1.2.2  Choice Functions

(defchoose2 fixpoint[?f] x (?f) ()
  (equal (?f x) x))

; 1.2.3  Quantifier Functions

(defun-sk2 injective[?f] (?f) ()
  (forall (x y)
          (implies (equal (?f x) (?f y))
                   (equal x y))))

; 1.3  Instances of Second-Order Functions

(defun wrap (x)
  (list x))

(verify-guards wrap) ; omitted from the paper, for brevity

(defun-inst quad[wrap]
  (quad[?f] (?f . wrap)))

(defun octetp (x)
  (and (natp x) (< x 256)))

(verify-guards octetp) ; omitted from the paper, for brevity

(defun-inst all[octetp]
  (all[?p] (?p . octetp)))

(defun-inst map[code-char]
  (map[?f_?p] (?f . code-char) (?p . octetp)))

(defun-inst fold[nfix_plus]
  (fold[?f_?g] (?f . nfix) (?g . binary-+)))

(defun twice (x)
  (* 2 (fix x)))

(verify-guards twice) ; omitted from the paper, for brevity

(defun-inst fixpoint[twice]
  (fixpoint[?f] (?f . twice)))

(defun-inst injective[quad[?f]] (?f)
  (injective[?f] (?f . quad[?f])))

; 1.4  Second-Order Theorems

(defthm len-of-map[?f_?p]
  (equal (len (map[?f_?p] l))
         (len l)))

(defthm injective[quad[?f]]-when-injective[?f]
  (implies (injective[?f])
           (injective[quad[?f]]))
  :hints
  (("Goal" :use
    ((:instance
      injective[?f]-necc
      (x (?f (?f (?f (?f (mv-nth 0 (injective[quad[?f]]-witness)))))))
      (y (?f (?f (?f (?f (mv-nth 1 (injective[quad[?f]]-witness))))))))
     (:instance
      injective[?f]-necc
      (x (?f (?f (?f (mv-nth 0 (injective[quad[?f]]-witness))))))
      (y (?f (?f (?f (mv-nth 1 (injective[quad[?f]]-witness)))))))
     (:instance
      injective[?f]-necc
      (x (?f (?f (mv-nth 0 (injective[quad[?f]]-witness)))))
      (y (?f (?f (mv-nth 1 (injective[quad[?f]]-witness))))))
     (:instance
      injective[?f]-necc
      (x (?f (mv-nth 0 (injective[quad[?f]]-witness))))
      (y (?f (mv-nth 1 (injective[quad[?f]]-witness)))))
     (:instance
      injective[?f]-necc
      (x (mv-nth 0 (injective[quad[?f]]-witness)))
      (y (mv-nth 1 (injective[quad[?f]]-witness))))))))

(defunvar ?io (* *) => *)

(defun-sk2 atom-io[?f_?io] (?f ?io) ()
  (forall x (implies (atom x)
                     (?io x (?f x))))
  :rewrite :direct)

(defun-sk2 consp-io[?g_?io] (?g ?io) ()
  (forall (x y1 y2)
          (implies (and (consp x)
                        (?io (car x) y1)
                        (?io (cdr x) y2))
                   (?io x (?g y1 y2))))
  :rewrite :direct)

(defthm fold-io[?f_?g_?io]
  (implies (and (atom-io[?f_?io])
                (consp-io[?g_?io]))
           (?io x (fold[?f_?g] x))))

; 1.5  Instances of Second-Order Theorems

(defthm-inst len-of-map[code-char]
  (len-of-map[?f_?p] (?f . code-char) (?p . octetp)))

(defun-inst injective[quad[wrap]]
  (injective[quad[?f]] (?f . wrap)))

(defun-inst injective[wrap]
  (injective[?f] (?f . wrap)))

(defthm-inst injective[quad[wrap]]-when-injective[wrap]
  (injective[quad[?f]]-when-injective[?f] (?f . wrap)))

; 2  Use in Program Refinement

; to keep the program refinement example shorter:
(set-verify-guards-eagerness 0) ; omitted from the paper, for brevity

; 2.1  Specifications as Second-Order Predicates

(defun leaf (e bt)
  (cond ((atom bt) (equal e bt))
        (t (or (leaf e (car bt))
               (leaf e (cdr bt))))))

(defunvar ?h (*) => *)

(defun-sk io (x y)
  (forall e (iff (member e y)
                 (and (leaf e x)
                      (natp e))))
  :rewrite :direct)

(defun-sk2 spec[?h] (?h) ()
  (forall x (io x (?h x)))
  :rewrite :direct)

(defthm natp-of-member-of-output
  (implies (and (spec[?h])
                (member e (?h x)))
           (natp e))
  :hints (("Goal" :use (spec[?h]-necc
                        (:instance io-necc (y (?h x)))))))

; 2.2  Refinement as Second-Order Predicate Strengthening

; Step 1

(defun-sk2 def-?h-fold[?f_?g] (?h ?f ?g) ()
  (forall x (equal (?h x)
                   (fold[?f_?g] x)))
  :rewrite :direct)

(defun2 spec1[?h_?f_?g] (?h ?f ?g) ()
  (and (def-?h-fold[?f_?g])
       (spec[?h])))

(defthm step1
  (implies (spec1[?h_?f_?g])
           (spec[?h]))
  :hints (("Goal" :in-theory '(spec1[?h_?f_?g]))))

; Step 2

(defun-inst atom-io[?f] (?f)
  (atom-io[?f_?io] (?io . io)))

(defun-inst consp-io[?g] (?g)
  (consp-io[?g_?io] (?io . io)))

(defthm-inst fold-io[?f_?g]
  (fold-io[?f_?g_?io] (?io . io)))

(defun2 spec2[?h_?f_?g] (?h ?f ?g) ()
  (and (def-?h-fold[?f_?g])
       (atom-io[?f])
       (consp-io[?g])))

(defthm step2
  (implies (spec2[?h_?f_?g])
           (spec1[?h_?f_?g]))
  :hints (("Goal" :in-theory '(spec1[?h_?f_?g]
                               spec2[?h_?f_?g]
                               spec[?h]
                               def-?h-fold[?f_?g]-necc
                               fold-io[?f_?g]))))

; Step 3

(defun f (x)
  (if (natp x)
      (list x)
    nil))

(defun-inst atom-io[f]
  (atom-io[?f] (?f . f)))

(defthm atom-io[f]!
  (atom-io[f]))

(defun-sk2 def-?f (?f) ()
  (forall x (equal (?f x) (f x)))
  :rewrite :direct)

(defun2 spec3[?h_?f_?g] (?h ?f ?g) ()
  (and (def-?h-fold[?f_?g])
       (def-?f)
       (consp-io[?g])))

(defthm step3-lemma
  (implies (def-?f)
           (atom-io[?f]))
  :hints (("Goal" :in-theory '(atom-io[?f]
                               atom-io[f]-necc
                               atom-io[f]!
                               def-?f-necc))))

(defthm step3
  (implies (spec3[?h_?f_?g])
           (spec2[?h_?f_?g]))
  :hints (("Goal" :in-theory '(spec2[?h_?f_?g]
                               spec3[?h_?f_?g]
                               step3-lemma))))

; Step 4

(defun g (y1 y2)
  (append y1 y2))

(defun-inst consp-io[g]
  (consp-io[?g] (?g . g)))

(defthm member-of-append
  (iff (member e (append y1 y2))
       (or (member e y1)
           (member e y2))))

(defthm consp-io[g]-lemma
  (implies (and (consp x)
                (io (car x) y1)
                (io (cdr x) y2))
           (io x (g y1 y2)))
  :hints (("Goal"
           :in-theory (disable io)
           :expand (io x (append y1 y2)))))

(defthm consp-io[g]!
  (consp-io[g])
  :hints (("Goal" :in-theory (disable g))))

(defun-sk2 def-?g (?g) ()
  (forall (y1 y2)
          (equal (?g y1 y2) (g y1 y2)))
  :rewrite :direct)

(defun2 spec4[?h_?f_?g] (?h ?f ?g) ()
  (and (def-?h-fold[?f_?g])
       (def-?f)
       (def-?g)))

(defthm step4-lemma
  (implies (def-?g)
           (consp-io[?g]))
  :hints (("Goal" :in-theory '(consp-io[?g]
                               consp-io[g]-necc
                               consp-io[g]!
                               def-?g-necc))))

(defthm step4
  (implies (spec4[?h_?f_?g])
           (spec3[?h_?f_?g]))
  :hints (("Goal" :in-theory '(spec3[?h_?f_?g]
                               spec4[?h_?f_?g]
                               step4-lemma))))

; Step 5

(defun-inst h
  (fold[?f_?g] (?f . f) (?g . g)))

(defun-sk2 def-?h (?h) ()
  (forall x (equal (?h x) (h x)))
  :rewrite :direct)

(defun2 spec5[?h_?f_?g] (?h ?f ?g) ()
  (and (def-?h)
       (def-?f)
       (def-?g)))

(defthm step5-lemma
  (implies (and (def-?f)
                (def-?g))
           (equal (h x) (fold[?f_?g] x)))
  :hints (("Goal" :in-theory '(h fold[?f_?g] def-?f-necc def-?g-necc))))

(defthm step5
  (implies (spec5[?h_?f_?g])
           (spec4[?h_?f_?g]))
  :hints (("Goal" :in-theory '(spec4[?h_?f_?g]
                               spec5[?h_?f_?g]
                               def-?h-fold[?f_?g]
                               def-?h-necc
                               step5-lemma))))

(defthm chain[?h_?f_?g]
  (implies (spec5[?h_?f_?g])
           (spec[?h]))
  :hints (("Goal" :in-theory '(step1 step2 step3 step4 step5))))

(defun-inst def-h
  (def-?h (?h . h))
  :rewrite :default)

(defun-inst def-f
  (def-?f (?f . f))
  :rewrite :default)

(defun-inst def-g
  (def-?g (?g . g))
  :rewrite :default)

(defun-inst spec5[h_f_g]
  (spec5[?h_?f_?g] (?h . h) (?f . f) (?g . g)))

(defun-inst spec[h]
  (spec[?h] (?h . h)))

(defthm-inst chain[h_f_g]
  (chain[?h_?f_?g] (?h . h) (?f . f) (?g . g)))

(defthm spec5[h_f_g]!
  (spec5[h_f_g])
  :hints (("Goal" :in-theory '(spec5[h_f_g]))))

(defthm spec[h]!
  (spec[h])
  :hints (("Goal" :in-theory '(chain[h_f_g] spec5[h_f_g]!))))
