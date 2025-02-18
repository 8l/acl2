; VL Verilog Toolkit
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

(in-package "VL")
(include-book "argresolve")
(include-book "make-implicit-wires")
(include-book "type-disambiguation")
(include-book "enumnames")
(include-book "portdecl-sign")
(include-book "port-resolve")
(include-book "udp-elim")
(include-book "portcheck")
(include-book "../../util/cwtime")

(defsection annotate
  :parents (transforms)
  :short "Typically the first step after <see topic='@(url
loader')'>loading</see> a design.  Applies several basic, preliminary
transforms to normalize the design and check it for well-formedness."

  :long "<p>The @(see vl-design)s produced by VL's @(see loader) are not yet in
a very finished or error-checked form.  The function @(see vl-annotate-design)
transforms such a ``raw'' design into something that is much more reasonable to
work with.  Typically it should be invoked immediately after loading as the
first step in any VL-based tool.</p>"

  ;; BOZO it would be nice to explain this better.

  )

(local (xdoc::set-default-parents annotate))

(define vl-annotate-design
  :short "Top level @(see annotate) transform."
  ((design vl-design-p))
  :returns (new-design vl-design-p)
  (b* ((design (xf-cwtime (vl-design-resolve-ansi-portdecls design)))
       (design (xf-cwtime (vl-design-resolve-nonansi-interfaceports design)))
       (design (xf-cwtime (vl-design-add-enumname-declarations design)))
       (design (xf-cwtime (vl-design-make-implicit-wires design)))
       (design (xf-cwtime (vl-design-portdecl-sign design)))
       (design (xf-cwtime (vl-design-udp-elim design)))
       (design (xf-cwtime (vl-design-portcheck design)))
       (design (xf-cwtime (vl-design-argresolve design)))
       (design (xf-cwtime (vl-design-type-disambiguate design))))
    design))

