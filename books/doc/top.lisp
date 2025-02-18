; ACL2 System+Books Combined XDOC Manual
; Copyright (C) 2008-2014 Centaur Technology
;
; Contact:
;   Centaur Technology Formal Verification Group
;   7600-C N. Capital of Texas Highway, Suite 300, Austin, TX 78731, USA.
;   http://www.centtech.com/
;
; License: (An MIT/X11-style license)
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
; Original author: Jared Davis <jared@centtech.com>

(in-package "ACL2")

; Note, 7/28/2014: if we include
; (include-book "std/system/top" :dir :system)
; instead of the following, we get a name conflict.
(include-book "std/system/non-parallel-book" :dir :system)


 ;; Disabling waterfall parallelism because the include-books are too slow with
 ;; it enabled, since waterfall parallelism unmemoizes the six or so functions
 ;; that ACL2(h) memoizes by default (in particular, fchecksum-obj needs to be
 ;; memoized to include centaur/esim/tutorial/alu16-book).

 ;; [Jared] BOZO: is the above comment about include books even true anymore?
 ;; If so, maybe waterfall parallelism doesn't have to do this with the new
 ;; thread-safe memo code?

 ;; [Jared] BOZO: even if waterfall parallelism still disables this memoization,
 ;; do we care?  The alu16-book demo has been removed from the manual.  (Maybe
 ;; we should put it back in.  Do we care how long the manual takes to build?)
(non-parallel-book)

(include-book "centaur/misc/tshell" :dir :system)
(value-triple (acl2::tshell-ensure))

(include-book "centaur/misc/memory-mgmt" :dir :system)
(value-triple (set-max-mem (* 10 (expt 2 30))))


(include-book "relnotes")
(include-book "practices")

(include-book "xdoc/save" :dir :system)

(include-book "build/doc" :dir :system)

(include-book "centaur/4v-sexpr/top" :dir :system)
(include-book "centaur/aig/top" :dir :system)

(include-book "centaur/aignet/aig-sim" :dir :system)
(include-book "centaur/aignet/copying" :dir :system)
(include-book "centaur/aignet/from-hons-aig-fast" :dir :system)
(include-book "centaur/aignet/prune" :dir :system)
(include-book "centaur/aignet/to-hons-aig" :dir :system)
(include-book "centaur/aignet/types" :dir :system)
(include-book "centaur/aignet/vecsim" :dir :system)

; The rest of ihs is included elsewhere transitively.
; We load logops-lemmas first so that the old style :doc-strings don't get
; stripped away when they're loaded redundantly later.
(include-book "ihs/logops-lemmas" :dir :system)

(include-book "centaur/bitops/top" :dir :system)
(include-book "centaur/bitops/congruences" :dir :system)
(include-book "centaur/bitops/defaults" :dir :system)

(include-book "centaur/bridge/top" :dir :system)

(include-book "centaur/clex/example" :dir :system)
(include-book "centaur/nrev/demo" :dir :system)

(include-book "centaur/defrstobj/defrstobj" :dir :system)

(include-book "centaur/esim/stv/stv-top" :dir :system)
(include-book "centaur/esim/stv/stv-debug" :dir :system)
(include-book "centaur/esim/esim-sexpr-correct" :dir :system)

(include-book "centaur/getopt/top" :dir :system)
(include-book "centaur/getopt/demo" :dir :system)
(include-book "centaur/getopt/demo2" :dir :system)
(include-book "centaur/bed/top" :dir :system)

(include-book "centaur/gl/gl" :dir :system)
(include-book "centaur/gl/bfr-aig-bddify" :dir :system)
(include-book "centaur/gl/gl-ttags" :dir :system)
(include-book "centaur/gl/gobject-type-thms" :dir :system)
(include-book "centaur/gl/bfr-satlink" :dir :system)
(include-book "centaur/gl/def-gl-rule" :dir :system)

(include-book "centaur/satlink/top" :dir :system)
(include-book "centaur/satlink/check-config" :dir :system)
(include-book "centaur/satlink/benchmarks" :dir :system)

(include-book "centaur/depgraph/top" :dir :system)

(include-book "centaur/quicklisp/top" :dir :system)

(include-book "centaur/misc/top" :dir :system)
(include-book "centaur/misc/smm" :dir :system)
(include-book "centaur/misc/tailrec" :dir :system)
(include-book "centaur/misc/hons-remove-dups" :dir :system)
(include-book "centaur/misc/seed-random" :dir :system)
(include-book "centaur/misc/load-stobj" :dir :system)
(include-book "centaur/misc/load-stobj-tests" :dir :system)
(include-book "centaur/misc/count-up" :dir :system)
(include-book "centaur/misc/fast-alist-pop" :dir :system)
(include-book "centaur/misc/spacewalk" :dir :system)
(include-book "centaur/misc/dag-measure" :dir :system)

;; BOZO conflicts with something in 4v-sexpr?

;; (include-book "misc/remove-assoc")
;; (include-book "misc/sparsemap")
;; (include-book "misc/sparsemap-impl")
(include-book "centaur/misc/stobj-swap" :dir :system)

(include-book "oslib/top" :dir :system)

(include-book "std/top" :dir :system)
(include-book "std/basic/inductions" :dir :system)
(include-book "std/io/unsound-read" :dir :system)
(include-book "std/bitsets/top" :dir :system)

(include-book "std/strings/top" :dir :system)
(include-book "std/strings/base64" :dir :system)
(include-book "std/strings/pretty" :dir :system)


(include-book "centaur/ubdds/lite" :dir :system)
(include-book "centaur/ubdds/param" :dir :system)

(include-book "centaur/sv/top" :dir :system)
(include-book "centaur/sv/tutorial/alu" :dir :system)
(include-book "centaur/sv/tutorial/boothpipe" :dir :system)
(include-book "centaur/esim/vcd/vcd" :dir :system)
(include-book "centaur/esim/vcd/esim-snapshot" :dir :system)
(include-book "centaur/esim/vcd/vcd-stub" :dir :system)
;; BOZO causes some error with redefinition?  Are we loading the right
;; books above?  What does stv-debug load?
;; (include-book "centaur/esim/vcd/vcd-impl")

(include-book "centaur/vl/doc" :dir :system)

;; This rule causes type determination to take forever in VL for some reason
(in-theory (disable consp-append
                    true-listp-append
                    (:t append)))

(include-book "centaur/vl/kit/top" :dir :system)
(include-book "centaur/vl/mlib/atts" :dir :system)

(include-book "centaur/vl2014/doc" :dir :system)
(include-book "centaur/vl2014/kit/top" :dir :system)
(include-book "centaur/vl2014/mlib/clean-concats" :dir :system)
(include-book "centaur/vl2014/lint/use-set" :dir :system)
(include-book "centaur/vl2014/transforms/clean-selects" :dir :system)
(include-book "centaur/vl2014/transforms/propagate" :dir :system)
(include-book "centaur/vl2014/transforms/expr-simp" :dir :system)
(include-book "centaur/vl2014/transforms/inline" :dir :system)
(include-book "centaur/vl2014/util/prefix-hash" :dir :system)

;; BOZO conflict with prefix-hash stuff above.  Need to fix this.  Also, are
;; these being used at all?

;; (include-book "centaur/vl2014/util/prefixp" :dir :system)

(include-book "hacking/all" :dir :system)
(include-book "hints/consider-hint" :dir :system)
(include-book "hints/hint-wrapper" :dir :system)

(include-book "ordinals/e0-ordinal" :dir :system)

(include-book "tools/do-not" :dir :system)
(include-book "tools/plev" :dir :system)
(include-book "tools/plev-ccl" :dir :system)
(include-book "tools/with-supporters" :dir :system)
(include-book "tools/remove-hyps" :dir :system)
(include-book "tools/removable-runes" :dir :system)
(include-book "tools/oracle-time" :dir :system)
(include-book "tools/oracle-timelimit" :dir :system)
(include-book "clause-processors/doc" :dir :system)

;; [Jared] removing these to speed up the manual build
;; BOZO should we put them back in?
;(include-book "centaur/esim/tutorial/intro" :dir :system)
;(include-book "centaur/esim/tutorial/alu16-book" :dir :system)
;(include-book "centaur/esim/tutorial/counter" :dir :system)

;; [Jared] removed this to avoid depending on glucose and to speed up
;; the manual build
; (include-book "centaur/esim/tests/common" :dir :system)


;; Not much doc here, but some theorems from arithmetic-5 are referenced by
;; other topics...
(include-book "arithmetic-5/top" :dir :system)
(include-book "arithmetic/top" :dir :system)

(include-book "rtl/rel11/lib/top" :dir :system)
; And books not included in lib/top:
(include-book "rtl/rel11/lib/add" :dir :system)
(include-book "rtl/rel11/lib/mult" :dir :system)
(include-book "rtl/rel11/lib/div" :dir :system)
(include-book "rtl/rel11/lib/srt" :dir :system)
(include-book "rtl/rel11/lib/sqrt" :dir :system)

(include-book "centaur/fty/top" :dir :system)

(include-book "misc/find-lemmas" :dir :system)
(include-book "misc/simp" :dir :system)
(include-book "misc/without-waterfall-parallelism" :dir :system)
(include-book "misc/with-waterfall-parallelism" :dir :system)
(include-book "misc/seq" :dir :system)
(include-book "misc/seqw" :dir :system)
(include-book "misc/defpm" :dir :system)
(include-book "misc/install-not-normalized" :dir :system)

(include-book "make-event/proof-by-arith" :dir :system)

(include-book "centaur/memoize/old/profile" :dir :system)
(include-book "centaur/memoize/old/watch" :dir :system)

(include-book "data-structures/top" :dir :system)
(include-book "acl2s/doc" :dir :system)

(include-book "projects/doc" :dir :system)



#||

;; This is a nice place to put include-book scanner hacks that trick cert.pl
;; into certifying unit-testing books that don't actually need to be included
;; anywhere.  This just tricks the dependency scanner into building
;; these books.

(include-book "xdoc/all" :dir :system)

(include-book "xdoc/tests/preprocessor-tests" :dir :system)
(include-book "xdoc/tests/unsound-eval-tests" :dir :system)
(include-book "xdoc/tests/defsection-tests" :dir :system)
(include-book "centaur/defrstobj/basic-tests" :dir :system)
(include-book "std/util/tests/top" :dir :system)
(include-book "std/util/extensions/assert-return-thms" :dir :system)
(include-book "centaur/misc/tshell-tests" :dir :system)
(include-book "centaur/misc/stobj-swap-test" :dir :system)
(include-book "oslib/tests/top" :dir :system)

(include-book "centaur/ubdds/sanity-check-macros" :dir :system)

(include-book "centaur/memoize/old/case" :dir :system)
(include-book "centaur/memoize/old/profile" :dir :system)
(include-book "centaur/memoize/old/watch" :dir :system)
(include-book "centaur/memoize/portcullis" :dir :system)
(include-book "centaur/memoize/tests" :dir :system)
(include-book "centaur/memoize/top" :dir :system)

||#

(defpointer assocs patbind-assocs)

; Historically we had a completely ad-hoc organization that grew organically as
; topics were added.  This turned out to be a complete mess.  To make the
; manual more approachable and relevant, we now try to impose a better
; hierarchy and add some context.

;; Jared moved the documentation that used to be here into more-topics.lisp so
;; that it can be easily included in other manuals without including top.
(include-book "more-topics")


(include-book "xdoc/topics" :dir :system)
(include-book "xdoc/alter" :dir :system)


; These are legacy defdoc topics that need to be incorporated into the
; hierarchy at some sensible places.  These changes are not controversial, so
; we'll do them globally, so they'll be included, e.g., in the Emacs version of
; the combined manual.

; data-definitions went away.  It might be reasonable to place with-timeout
; under defdata, if that still exists.
;(xdoc::change-parents data-definitions (macro-libraries projects debugging))
;(xdoc::change-parents with-timeout (data-definitions))
;(xdoc::change-parents testing (cgen))
;; (xdoc::change-parents data-structures (macro-libraries))

#!XDOC
(defun fix-redundant-acl2-parents (all-topics)

; Modification 7/19/2015 by Matt K.: The rebinding of topic just below caused
; the removal of ACL2 as a parent for three topics, as indicated in the
; following output in books/doc/top.cert.out:

; Note: Removing 'redundant' ACL2 parent for PROOF-AUTOMATION.
; Note: Removing 'redundant' ACL2 parent for INTERFACING-TOOLS.
; Note: Removing 'redundant' ACL2 parent for DEBUGGING.

; But I definitely want DEBUGGING to show up under ACL2.  One reason is that
; otherwise, many ACL2 topics quite appropriately have DEBUGGING as their sole
; parent, and thus are not included in the tree of topics under ACL2.  I'd
; prefer that INTERFACING-TOOLS to show up under ACL2 as well (for example, so
; that COMMAND-LINE is in the tree of topics under ACL2).  But I agree that
; ther is no reason for PROOF-AUTOMATION to be under ACL2, so I have removed
; ACL2 as a parent of PROOF-AUTOMATION in books/doc/more-topics.lisp.

; (b* (((when (atom all-topics))
;       nil)
;      (topic (car all-topics))
;      (parents (cdr (assoc :parents topic)))
;      (topic (if (or (equal parents '(acl2::top acl2::acl2))
;                     (equal parents '(acl2::acl2 acl2::top)))
;                 (progn$
;                  (cw "; Note: Removing 'redundant' ACL2 parent for ~x0.~%"
;                      (cdr (assoc :name topic)))
;                  (cons (cons :parents '(acl2::top))
;                        (delete-assoc-equal :parents topic)))
;               topic)))
;   (cons topic
;         (fix-redundant-acl2-parents (cdr all-topics))))

  all-topics)

(defmacro xdoc::fix-the-hierarchy ()
  ;; Semi-bozo.
  ;;
  ;; This is a place that Jared can put changes that are either experimental or
  ;; under discussion.
  ;;
  ;; Later in this file, I call fix-the-hierarchy, but only LOCALLY, so that it
  ;; only affects the web manual (not the Emacs manual), and not any other
  ;; manuals that include doc/top
  ;;
  ;; I wrap these changes up in a non-local macro so that authors of other
  ;; manuals (e.g., our internal manual at Centaur) can also choose to call
  ;; fix-the-hierarchy if they wish.
  `(progn

     #!XDOC
     (table xdoc 'doc (fix-redundant-acl2-parents
                       (get-xdoc-table acl2::world)))

     ;; These run afoul of the acl2-parents issue
     (xdoc::change-parents documentation (top))
     (xdoc::change-parents bdd (boolean-reasoning proof-automation))
     (xdoc::change-parents books (top))

     ))

(local

; The TOP topic will be the first thing the user sees when they open the
; manual!  We localize this because you may want to write your own top topics
; for custom manuals.

 (include-book "top-topic"))


(comp t)

(local (xdoc::fix-the-hierarchy))
(local (deflabel doc-rebuild-label))

(make-event
 (b* ((state (serialize-write "xdoc.sao"
                              (xdoc::get-xdoc-table (w state))
                              :verbosep t)))
   (value '(value-triple "xdoc.sao"))))


; Once upon a time we had a an out-of-control macro generating automatic docs
; that included every event in the world(!).  To make this sort of problem
; easier to spot, we now print out a brief listing of the longest topics.

#!XDOC
(defun find-long-topics (all-topics)
  (if (atom all-topics)
      nil
    (cons (cons (length (cdr (assoc :long (car all-topics))))
                (cdr (assoc :name (car all-topics))))
          (find-long-topics (cdr all-topics)))))

#!XDOC
(value-triple
 (b* ((lengths->names (find-long-topics (get-xdoc-table (w state)))))
   (cw "Longest topics listing (length . name):~%~x0~%"
       (take 30 (reverse (mergesort lengths->names))))))

; GC so the fork for the zip call of xdoc::save has a smaller chance of running
; out of memory.
(value-triple (hons-clear t))

(value-triple
 (progn$ (cw "--- Writing ACL2+Books Manual ----------------------------------~%")
         :invisible))

(make-event
; xdoc::save is an event, so we might have just called it directly.  But for
; reasons Jared doesn't understand this is screwing up the extended manual we
; build at Centaur.  So, I'm putting the save event into a make-event to try
; to localize its effects to just this book's certification.
 (er-progn (xdoc::save "./manual"
                       ;; Allow redefinition so that we don't have to get
                       ;; everything perfect (until it's release time)
                       :redef-okp t)
           (value `(value-triple :manual))))

(value-triple
 (progn$ (cw "--- Done Writing ACL2+Books Manual -----------------------------~%")
         :invisible))



; Support for the Emacs-based Manual
;
; Historically this was part of system/doc/render-doc-combined.lisp.  However,
; that file ended up being quite expensive and in the critical path.  Most of
; the expense was that it just had to include-book doc/top.lisp, which takes
; a lot of time because of how many books are included.
;
; So now, instead, to improve performance, we just merge the export of the
; text-based manual into doc/top.lisp.

(include-book "system/doc/render-doc-base" :dir :system)

(defttag :open-output-channel!)

#!XDOC
(make-event
 (time$
  (state-global-let*
   ((current-package "ACL2" set-current-package-state))
   (b* ((all-topics (time$
                     (force-root-parents
                      (maybe-add-top-topic
                       (normalize-parents-list ; Should we clean-topics?
                        (get-xdoc-table (w state)))))))
        ((mv rendered state)
         (time$ (render-topics all-topics all-topics state)))
        (rendered (time$ (split-acl2-topics rendered nil nil nil)))
        (outfile (acl2::extend-pathname (cbd)
                                        "../system/doc/rendered-doc-combined.lsp"
                                        state))
        (- (cw "Writing ~s0~%" outfile))
        ((mv channel state) (open-output-channel! outfile :character state))
        ((unless channel)
         (cw "can't open ~s0 for output." outfile)
         (acl2::silent-error state))
        (state (princ$ "; Documentation for acl2+books
; WARNING: GENERATED FILE, DO NOT HAND EDIT!
; The contents of this file are derived from the full acl2+books
; documentation.  For license and copyright information, see community book
; xdoc/fancy/LICENSE.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; LICENSE for more details.

(in-package \"ACL2\")

(defconst *acl2+books-documentation* '"
                      channel state))
       (state (time$ (fms! "~x0"
                    (list (cons #\0 rendered))
                    channel state nil)))
       (state (fms! ")" nil channel state nil))
       (state (newline channel state))
       (state (close-output-channel channel state)))
      (value '(value-triple :ok))))))



(local
 (defmacro doc-rebuild ()

; It is sometimes useful to make tweaks to the documentation and then quickly
; be able to see your changes.  This macro can be used to do this, as follows:
;
; SETUP:
;
;  (ld "doc.lisp")  ;; slow, takes a few minutes to get all the books loaded
;
; DEVELOPMENT LOOP: {
;
;   1. make documentation changes in new-doc.lsp; e.g., you can add new topics
;      there with defxdoc, or use commands like change-parents, etc.
;
;   2. type (doc-rebuild) to rebuild the manual with your changes; this only
;      takes 20-30 seconds
;
;   3. view your changes, make further edits
;
; }
;
; Finally, move your changes out of new-doc.lsp and integrate them properly
; into the other sources, and do a proper build.

   `(er-progn
     (ubt! 'doc-rebuild-label)
     (ld ;; newline to fool dependency scanner
      "new-doc.lsp")
     (xdoc::save "./manual"
                 :redef-okp t
                 :zip-p nil)
     (value `(value-triple :manual)))))





#||

(redef-errors (get-xdoc-table (w state)))

(defun collect-topics-with-name (name topics)
  (if (atom topics)
      nil
    (if (equal (cdr (assoc :name (car topics))) name)
        (cons (Car topics) (collect-topics-with-name name (Cdr topics)))
      (collect-topics-with-name name (Cdr topics)))))

(b* (((list a b) (collect-topics-with-name 'oslib::lisp-type (get-xdoc-table (w state)))))
  (equal a b))

(b* (((list a b) (collect-topics-with-name 'acl2::ADD-LISTFIX-RULE (get-xdoc-table (w state)))))
  (equal a b))



(defun map-topic-names (x)
  (if (atom x)
      nil
    (cons (cdr (assoc :name (car x)))
          (map-topic-names (cdr x)))))

(map-topic-names (get-xdoc-table (w state)))


(b* (((list a b) (collect-topics-with-name 'oslib::lisp-type (get-xdoc-table (w state)))))
  (equal a b))



(collect-topics-with-name 'acl2::add-listfix-rule (get-xdoc-table (w state)))
||#
