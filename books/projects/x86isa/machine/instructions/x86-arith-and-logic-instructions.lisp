;; AUTHOR:
;; Shilpi Goel <shigoel@cs.utexas.edu>

(in-package "X86ISA")

;; ======================================================================

(include-book "arith-and-logic"
              :ttags (:include-raw :syscall-exec :other-non-det :undef-flg))
(include-book "../x86-decoding-and-spec-utils"
              :ttags (:include-raw :syscall-exec :other-non-det :undef-flg))

(local (include-book "centaur/bitops/ihs-extensions" :dir :system))
(local (include-book "centaur/bitops/signed-byte-p" :dir :system))

;; ======================================================================

;; Some helper theorems to speed up checkpoints involving (un)signed-byte-p:

(local
 (defthm member-equal-and-integers
   (implies (and (<= operation 8)
                 (<= 0 operation)
                 (integerp operation))
            (member-equal operation '(0 2 4 6 8 1 3 5 7)))))

(local
 (defthm signed-byte-p-49-thm-1
   (implies (and (signed-byte-p 48 (+ a b))
                 (signed-byte-p 48 c)
                 (integerp a)
                 (integerp b))
            (signed-byte-p 49 (+ (- c) a b)))))

(local
 (defthm signed-byte-p-48-thm-1
   (implies (and (signed-byte-p 48 x)
                 (< (+ x y) *2^47*)
                 (natp y))
            (signed-byte-p 48 (+ x y)))))

(local
 (defthm signed-byte-p-49-thm-2
   (implies (and (signed-byte-p 48 (+ a b))
                 (signed-byte-p 48 c)
                 (< (+ z a b) *2^47*)
                 (integerp a)
                 (integerp b)
                 (natp z))
            (signed-byte-p 49 (+ z (- c) a b)))
   :hints (("Goal" :in-theory (e/d* (signed-byte-p) ())))))

(local
 (defthm signed-byte-p-48-thm-2
   (implies (and (signed-byte-p 48 x)
                 (< (+ z x y) *2^47*)
                 (natp y)
                 (natp z))
            (signed-byte-p 48 (+ z x y)))))

(local
 (defthm signed-byte-p-49-thm-3
   (implies (and (signed-byte-p 48 x)
                 (natp y)
                 (<= y 4))
            (signed-byte-p 49 (+ x y)))
   :hints (("Goal" :in-theory (e/d* (signed-byte-p unsigned-byte-p)
                                    ())))))

(local
 (defthm signed-byte-p-48-thm-3
   (implies (and (not (signed-byte-p 48 (+ x y)))
                 (signed-byte-p 48 x)
                 (natp y))
            (<= *2^47* (+ x y)))))

(local
 (defthm signed-byte-p-49-thm-4
   (implies (and (signed-byte-p 48 y)
                 (signed-byte-p 48 z)
                 (< (+ x y) *2^47*)
                 (natp x))
            (signed-byte-p 49 (+ x y (- z))))
   :hints (("Goal" :in-theory (e/d* (signed-byte-p unsigned-byte-p)
                                    ())))))

(local
 (defthm unsigned-byte-p-32-of-rm08
   (implies (and (signed-byte-p *max-linear-address-size* lin-addr)
                 (x86p x86))
            (unsigned-byte-p 32 (mv-nth 1 (rm08 lin-addr r-w-x x86))))
   :hints (("Goal" :in-theory (e/d* (unsigned-byte-p member-equal) (ash))))))

(local
 (defthm unsigned-byte-p-32-of-rm16
   (implies (and (signed-byte-p *max-linear-address-size* lin-addr)
                 (x86p x86))
            (unsigned-byte-p 32 (mv-nth 1 (rm16 lin-addr r-w-x x86))))
   :hints (("Goal" :in-theory (e/d* (unsigned-byte-p member-equal) (ash))))))

(local
 (defthm unsigned-byte-p-64-of-rm08
   (implies (and (signed-byte-p *max-linear-address-size* lin-addr)
                 (x86p x86))
            (unsigned-byte-p 64 (mv-nth 1 (rm08 lin-addr r-w-x x86))))
   :hints (("Goal" :in-theory (e/d* (unsigned-byte-p member-equal) (ash))))))

(local (in-theory (e/d* ()
                        (member-equal
                         signed-byte-p
                         unsigned-byte-p))))

;; ======================================================================
;; INSTRUCTIONS: (one-byte opcode map)
;; add, adc, sub, sbb, or, and, sub, xor, cmp, test
;; ======================================================================

(def-inst x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G

  :parents (one-byte-opcodes)

  :short "Operand Fetch and Execute for ADD, ADC, SUB, SBB, OR, AND,
  XOR, CMP, TEST: Addressing Mode = \(E,G\)"

  :long "<h3>Op/En = MR: \[OP R/M, REG\] or \[OP E G\]</h3>

  <p>where @('E') is the destination operand and @('G') is the source
  operand.  Note that @('E') stands for a general-purpose register or
  memory operand specified by the @('ModRM.r/m') field, and @('G')
  stands for a general-purpose register specified by the
  @('ModRM.reg') field.</p>

  \[OP R/M, REG\]  Flags Affected<br/>
  00, 01: ADD    c p a z s o<br/>
  08, 09: OR       p   z s   \(o and c cleared, a undefined\)<br/>
  10, 11: ADC    c p a z s o<br/>
  18, 19: SBB    c p a z s o<br/>
  20, 21: AND      p   z s   \(o and c cleared, a undefined\)<br/>
  28, 29: SUB    c p a z s o<br/>
  30, 31: XOR      p   z s   \(o and c cleared, a undefined\)<br/>
  38, 39: CMP    c p a z s o<br/>
  84, 85: TEST     p   z s   \(o and c cleared, a undefined\)<br/>"

  :operation t
  :returns (x86 x86p :hyp (x86p x86)
                :hints (("Goal" :in-theory (e/d* ()
                                                 (unsigned-byte-p
                                                  signed-byte-p)))))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'ADD #x00 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'ADD #x01 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'OR #x08 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'OR #x09 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'ADC #x10 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'ADC #x11 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'SBB #x18 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'SBB #x19 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'AND #x20 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'AND #x21 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'SUB #x28 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'SUB #x29 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'XOR #x30 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'XOR #x31 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'CMP #x38 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'CMP #x39 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'TEST #x84 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
    (add-to-implemented-opcodes-table 'TEST #x85 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G))

  :body

  (b* ((ctx 'x86-add/adc/sub/sbb/or/and/xor/cmp/test-E-G)
       (r/m (the (unsigned-byte 3) (mrm-r/m modr/m)))
       (mod (the (unsigned-byte 2) (mrm-mod  modr/m)))
       (reg (the (unsigned-byte 3) (mrm-reg  modr/m)))
       (lock? (eql #.*lock*
                   (prefixes-slice :group-1-prefix prefixes)))
       ((when (and lock? (eql operation #.*OP-CMP*)))
        ;; CMP does not allow a LOCK prefix.
        (!!ms-fresh :lock-prefix prefixes))

       (p2 (prefixes-slice :group-2-prefix prefixes))
       (byte-operand? (eql 0 (the (unsigned-byte 1)
                               (logand 1 opcode))))
       ((the (integer 1 8) operand-size)
        (select-operand-size byte-operand? rex-byte nil prefixes))

       (G (rgfi-size operand-size
                     (the (unsigned-byte 4)
                       (reg-index reg rex-byte #.*r*))
                     rex-byte x86))

       (p4? (eql #.*addr-size-override*
                 (prefixes-slice :group-4-prefix prefixes)))

       ((mv flg0 E (the (unsigned-byte 3) increment-RIP-by)
            (the (signed-byte #.*max-linear-address-size*) E-addr)
            x86)
        (x86-operand-from-modr/m-and-sib-bytes
         #.*rgf-access* operand-size p2 p4? temp-rip rex-byte r/m mod sib 0 x86))
       ((when flg0)
        (!!ms-fresh :x86-operand-from-modr/m-and-sib-bytes flg0))

       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (+ temp-rip increment-RIP-by))
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (<= #.*2^47*
                             (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip))))
        (!!ms-fresh :temp-rip-not-canonical temp-rip))
       ((the (signed-byte #.*max-linear-address-size+1*) addr-diff)
        (-
         (the (signed-byte #.*max-linear-address-size*)
           temp-rip)
         (the (signed-byte #.*max-linear-address-size*)
           start-rip)))
       ((when (< 15 addr-diff))
        (!!ms-fresh :instruction-length addr-diff))

       ;; Everything above this point is just further decoding the
       ;; instruction and fetching operands.

       ;; Instruction Specification:

       ;; Computing the flags and the result:
       ((the (unsigned-byte 32) input-rflags) (rflags x86))
       ((mv result
            (the (unsigned-byte 32) output-rflags)
            (the (unsigned-byte 32) undefined-flags))
        (gpr-arith/logic-spec operand-size operation E G input-rflags))

       ;; Updating the x86 state with the result and eflags.
       ((mv flg1 x86)
        (if (or (eql operation #.*OP-CMP*)
                (eql operation #.*OP-TEST*))
            ;; CMP and TEST modify just the flags.
            (mv nil x86)
          (x86-operand-to-reg/mem
           operand-size result
           (the (signed-byte #.*max-linear-address-size*) E-addr)
           rex-byte r/m mod x86)))
       ;; Note: If flg1 is non-nil, we bail out without changing the
       ;; x86 state.
       ((when flg1)
        (!!ms-fresh :x86-operand-to-reg/mem flg1))

       (x86 (write-user-rflags output-rflags undefined-flags x86))
       (x86 (!rip temp-rip x86)))

      x86))

(def-inst x86-add/adc/sub/sbb/or/and/xor/cmp-G-E

  :parents (one-byte-opcodes)

  :short "Operand Fetch and Execute for ADD, ADC, SUB, SBB, OR, AND,
  XOR, CMP: Addressing Mode = \(G,E\)"

  :long "<h3>Op/En = RM: \[OP REG, R/M\] or \[OP G, E\]</h3>

  <p>where @('G') is the destination operand and @('E') is the source
  operand.  Note that @('G') stands for a general-purpose register
  specified by the @('ModRM.reg') field, and @('E') stands for a
  general-purpose register or memory operand specified by the
  @('ModRM.r/m') field.</p>

  \[OP REG, R/M\]  Flags Affected<br/>
  02, 03: ADD   c p a z s o<br/>
  0A, 0B: OR      p   z s   \(o and c cleared, a undefined\) <br/>
  12, 13: ADC   c p a z s o<br/>
  1A, 1B: SBB   c p a z s o<br/>
  22, 23: AND     p   z s   \(o and c cleared, a undefined\) <br/>
  2A, 2B: SUB   c p a z s o<br/>
  32, 33: XOR     p   z s   \(o and c cleared, a undefined\) <br/>
  3A, 3B: CMP   c p a z s o <br/>"

  :operation t
  :guard (not (equal operation #.*OP-TEST*))

  :returns (x86 x86p :hyp (x86p x86)
                :hints (("Goal" :in-theory (e/d* ()
                                                 (unsigned-byte-p
                                                  signed-byte-p)))))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'ADD #x02 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'ADD #x03 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'OR #x0A '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'OR #x0B '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'ADC #x12 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'ADC #x13 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'SBB #x1A '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'SBB #x1B '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'AND #x22 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'AND #x23 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'SUB #x2A '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'SUB #x2B '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'XOR #x32 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'XOR #x33 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'CMP #x3A '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
    (add-to-implemented-opcodes-table 'CMP #x3B '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E))

  :body

  (b* ((ctx 'x86-add/adc/sub/sbb/or/and/xor/cmp-G-E)
       (r/m (the (unsigned-byte 3) (mrm-r/m  modr/m)))
       (mod (the (unsigned-byte 2) (mrm-mod  modr/m)))
       (reg (the (unsigned-byte 3) (mrm-reg  modr/m)))
       (lock (eql #.*lock*
                  (prefixes-slice :group-1-prefix prefixes)))
       ((when (and lock (eql operation #.*OP-CMP*)))
        ;; CMP does not allow a LOCK prefix.
        (!!ms-fresh :lock-prefix prefixes))

       (p2 (prefixes-slice :group-2-prefix prefixes))
       (byte-operand? (eql 0 (the (unsigned-byte 1)
                               (logand 1 opcode))))
       ((the (integer 1 8) operand-size)
        (select-operand-size byte-operand? rex-byte nil prefixes))

       (G (rgfi-size operand-size
                     (the (unsigned-byte 4)
                       (reg-index reg rex-byte #.*r*))
                     rex-byte x86))

       (p4? (eql #.*addr-size-override*
                 (prefixes-slice :group-4-prefix prefixes)))

       ((mv flg0 E (the (unsigned-byte 3) increment-RIP-by)
            (the (signed-byte #.*max-linear-address-size*) E-addr)
            x86)
        (x86-operand-from-modr/m-and-sib-bytes
         #.*rgf-access* operand-size p2 p4? temp-rip rex-byte r/m mod sib 0 x86))
       ((when flg0)
        (!!ms-fresh :x86-operand-from-modr/m-and-sib-bytes flg0))

       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (+ temp-rip increment-RIP-by))
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (<= #.*2^47*
                             (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip))))
        (!!ms-fresh :temp-rip-not-canonical temp-rip))
       ((the (signed-byte #.*max-linear-address-size+1*) addr-diff)
        (-
         (the (signed-byte #.*max-linear-address-size*)
           temp-rip)
         (the (signed-byte #.*max-linear-address-size*)
           start-rip)))
       ((when (< 15 addr-diff))
        (!!ms-fresh :instruction-length addr-diff))

       ;; Everything above this point is just further decoding the
       ;; instruction and fetching operands.

       ;; Instruction Specification:

       ;; Computing the flags and the result:
       ((the (unsigned-byte 32) input-rflags) (rflags x86))
       ((mv result
            (the (unsigned-byte 32) output-rflags)
            (the (unsigned-byte 32) undefined-flags))
        (gpr-arith/logic-spec operand-size operation G E input-rflags))

       ;; Updating the x86 state with the result and eflags.
       (x86
        (if (eql operation #.*OP-CMP*)
            ;; CMP modifies the flags only.
            x86
          (!rgfi-size operand-size (reg-index reg rex-byte #.*r*) result
                      rex-byte x86)))

       (x86 (write-user-rflags output-rflags undefined-flags x86))

       (x86 (!rip temp-rip x86)))

      x86))

(def-inst x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I

  :parents (one-byte-opcodes)

  :short "Operand Fetch and Execute for ADD, ADC, SUB, SBB, OR, AND,
  XOR, CMP, TEST: Addressing Mode = \(E, I\)"

  :long "<h3>Op/En = MI: \[OP R/M, IMM\] or \[OP E, I\]</h3>

  <p>where @('E') is the destination operand and @('I') is the source
  operand.  Note that @('E') stands for a general-purpose register or
  memory operand specified by the @('ModRM.r/m') field, and @('I')
  stands for immediate data.  All opcodes except those of TEST fall
  under group 1A, and have opcode extensions (ModR/M.reg field), as
  per Table A-6 of the Intel Manuals, Vol. 2.  The opcodes for TEST
  fall under Unary Group 3, and also have opcode extensions.</p>

  \[OP R/M, IMM\]  Flags Affected<br/>
  80-83 (000): ADD   c p a z s o<br/>
  80-83 (001): OR      p   z s   \(o and c cleared, a undefined\)<br/>
  80-83 (010): ADC   c p a z s o<br/>
  80-83 (011): SBB   c p a z s o<br/>
  80-83 (100): AND     p   z s   \(o and c cleared, a undefined\)<br/>
  80-83 (101): SUB   c p a z s o<br/>
  80-83 (110): XOR     p   z s   \(o and c cleared, a undefined\)<br/>
  80-83 (111): CMP   c p a z s o<br/>
  F6-F7 (000): TEST    p   z s   \(o and c cleared, a undefined\)<br/>"

  :operation t
  :guard-hints (("Goal" :in-theory (e/d (n08-to-i08
                                         n16-to-i16
                                         n32-to-i32
                                         n64-to-i64)
                                        ())))

  :returns (x86 x86p :hyp (x86p x86)
                :hints (("Goal" :in-theory (e/d* ()
                                                 (force
                                                  (force)
                                                  gpr-arith/logic-spec-8
                                                  gpr-arith/logic-spec-4
                                                  gpr-arith/logic-spec-2
                                                  gpr-arith/logic-spec-1
                                                  rm-size
                                                  select-operand-size
                                                  unsigned-byte-p
                                                  signed-byte-p)))))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'ADD #x80 '(:reg 0)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'ADD #x81 '(:reg 0)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'ADD #x82 '(:reg 0)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'ADD #x83 '(:reg 0)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)

    (add-to-implemented-opcodes-table 'OR #x80 '(:reg 2)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'OR #x81 '(:reg 2)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'OR #x82 '(:reg 2)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'OR #x83 '(:reg 2)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)

    (add-to-implemented-opcodes-table 'ADC #x80 '(:reg 2)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'ADC #x81 '(:reg 2)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'ADC #x82 '(:reg 2)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'ADC #x83 '(:reg 2)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)

    (add-to-implemented-opcodes-table 'SBB #x80 '(:reg 3)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'SBB #x81 '(:reg 3)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'SBB #x82 '(:reg 3)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'SBB #x83 '(:reg 3)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)

    (add-to-implemented-opcodes-table 'AND #x80 '(:reg 4)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'AND #x81 '(:reg 4)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'AND #x82 '(:reg 4)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'AND #x83 '(:reg 4)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)

    (add-to-implemented-opcodes-table 'SUB #x80 '(:reg 5)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'SUB #x81 '(:reg 5)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'SUB #x82 '(:reg 5)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'SUB #x83 '(:reg 5)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)

    (add-to-implemented-opcodes-table 'XOR #x80 '(:reg 6)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'XOR #x81 '(:reg 6)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'XOR #x82 '(:reg 6)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'XOR #x83 '(:reg 6)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)

    (add-to-implemented-opcodes-table 'CMP #x80 '(:reg 7)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'CMP #x81 '(:reg 7)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'CMP #x82 '(:reg 7)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'CMP #x83 '(:reg 7)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)

    (add-to-implemented-opcodes-table 'TEST #xF6 '(:reg 0)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
    (add-to-implemented-opcodes-table 'TEST #xF7 '(:reg 0)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I))

  :body

  (b* ((ctx 'x86-add/adc/sub/sbb/or/and/xor/cmp-test-E-I)
       (r/m (the (unsigned-byte 3) (mrm-r/m  modr/m)))
       (mod (the (unsigned-byte 2) (mrm-mod  modr/m)))
       (lock? (eql #.*lock*
                   (prefixes-slice :group-1-prefix prefixes)))
       ((when (and lock? (eql operation #.*OP-CMP*)))
        ;; CMP does not allow a LOCK prefix.
        (!!ms-fresh :lock-prefix prefixes))

       (p2 (prefixes-slice :group-2-prefix prefixes))
       (p4? (eql #.*addr-size-override*
                 (prefixes-slice :group-4-prefix prefixes)))

       (E-byte-operand? (or (eql opcode #x80)
                            (eql opcode #xF6)))
       ((the (integer 1 8) E-size)
        (select-operand-size E-byte-operand? rex-byte nil
                             prefixes))

       (imm-byte-operand? (or (eql opcode #x80)
                              (eql opcode #x83)
                              (eql opcode #xF6)))
       ((the (integer 1 4) imm-size)
        (select-operand-size imm-byte-operand? rex-byte t prefixes))

       ((mv flg0 E increment-RIP-by
            (the (signed-byte #.*max-linear-address-size*) E-addr)
            x86)
        (x86-operand-from-modr/m-and-sib-bytes
         #.*rgf-access* E-size p2 p4? temp-rip rex-byte r/m mod sib 0 x86))
       ((when flg0)
        (!!ms-fresh :x86-operand-from-modr/m-and-sib-bytes flg0))
       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (+ temp-rip increment-RIP-by))
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (<= #.*2^47*
                             (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip))))
        (!!ms-fresh :temp-rip-not-canonical temp-rip))

       ((mv ?flg1 (the (unsigned-byte 32) imm) x86)
        (rm-size imm-size temp-rip :x x86))
       ((when flg1)
        (!!ms-fresh :rm-size-error flg1))
       ;; Sign-extend imm:
       (imm
        (mbe :logic (loghead (ash E-size 3) (logext (ash imm-size 3) imm))
             :exec (logand (case E-size
                             (1 #.*2^8-1*)
                             (2 #.*2^16-1*)
                             (4 #.*2^32-1*)
                             (8 #.*2^64-1*)
                             ;; Won't reach here.
                             (t 0))
                           (case imm-size
                             (1 (the (signed-byte 8)
                                  (n08-to-i08
                                   (the (unsigned-byte 8) imm))))
                             (2 (the (signed-byte 16)
                                  (n16-to-i16
                                   (the (unsigned-byte 16) imm))))
                             (4 (the (signed-byte 32)
                                  (n32-to-i32
                                   (the (unsigned-byte 32) imm))))
                             ;; Won't reach here.
                             (t 0)))))

       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (+ temp-rip imm-size))
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (<= #.*2^47*
                             (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip))))
        (!!ms-fresh :temp-rip-not-canonical temp-rip))
       ((the (signed-byte #.*max-linear-address-size+1*) addr-diff)
        (-
         (the (signed-byte #.*max-linear-address-size*)
           temp-rip)
         (the (signed-byte #.*max-linear-address-size*)
           start-rip)))
       ((when (< 15 addr-diff))
        (!!ms-fresh :instruction-length addr-diff))

       ;; Everything above this point is just further decoding the
       ;; instruction and fetching operands.

       ;; Instruction Specification:

       ;; Computing the flags and the result:
       ((the (unsigned-byte 32) input-rflags) (rflags x86))
       ((mv result
            (the (unsigned-byte 32) output-rflags)
            (the (unsigned-byte 32) undefined-flags))
        (gpr-arith/logic-spec E-size operation E imm input-rflags))

       ;; Updating the x86 state with the result and eflags.
       ((mv flg1 x86)
        (if (or (eql operation #.*OP-CMP*)
                (eql operation #.*OP-TEST*))
            ;; CMP and TEST modify just the flags.
            (mv nil x86)
          (x86-operand-to-reg/mem
           E-size result
           (the (signed-byte #.*max-linear-address-size*) E-addr)
           rex-byte r/m mod x86)))
       ;; Note: If flg1 is non-nil, we bail out without changing the
       ;; x86 state.
       ((when flg1)
        (!!ms-fresh :x86-operand-to-reg/mem flg1))

       (x86 (write-user-rflags output-rflags undefined-flags x86))
       (x86 (!rip temp-rip x86)))

      x86))

(def-inst x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I
  :parents (one-byte-opcodes)

  :short "Operand Fetch and Execute for ADD, ADC, SUB, SBB, OR, AND,
  XOR, CMP, TEST: Addressing Mode = \(rAX, I\)"

  :long "<h3>Op/En = I: \[OP rAX, IMM\] or \[OP rAX, I\]</h3>

  <p>where @('rAX') is the destination operand and @('I') is the
  source operand.  Note that @('rAX') stands for AL/AX/EAX/RAX,
  depending on the operand size, and @('I') stands for immediate
  data.</p>

  \[OP rAX, IMM\]   Flags Affected<br/>
  04, 05: ADD        c p a z s o<br/>
  0C, 0D: OR           p   z s   \(o and c cleared, a undefined\)<br/>
  14, 15: ADC        c p a z s o<br/>
  1C, 1D: SBB        c p a z s o<br/>
  24, 25: AND          p   z s   \(o and c cleared, a undefined\)<br/>
  2C, 2D: SUB        c p a z s o<br/>
  34, 35: XOR          p   z s   \(o and c cleared, a undefined\)<br/>
  3C, 3D: CMP        c p a z s o<br/>
  A8, A9: TEST         p   z s   \(o and c cleared, a undefined\)<br/>"

  :operation t
  :prepwork ((local (in-theory (e/d* () (commutativity-of-+)))))
  :returns (x86 x86p :hyp (x86p x86)
                :hints (("Goal" :in-theory (e/d* ()
                                                 (force (force)
                                                        gpr-arith/logic-spec-8
                                                        gpr-arith/logic-spec-4
                                                        gpr-arith/logic-spec-2
                                                        gpr-arith/logic-spec-1
                                                        unsigned-byte-p)))))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'ADD #x04 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'ADD #x05 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'OR #x0C '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'OR #x0D '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'ADC #x14 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'ADC #x15 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'SBB #x1C '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'SBB #x1D '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'AND #x24 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'AND #x25 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'SUB #x2C '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'SUB #x2D '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'XOR #x34 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'XOR #x35 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'CMP #x3C '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'CMP #x3D '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'TEST #xA8 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
    (add-to-implemented-opcodes-table 'TEST #xA9 '(:nil nil)
                                      'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I))

  :body

  (b* ((ctx 'x86-add/adc/sub/sbb/or/and/xor/cmp-test-rAX-I)
       (lock (eql #.*lock*
                  (prefixes-slice :group-1-prefix prefixes)))
       ((when (and lock (eql operation #.*OP-CMP*)))
        ;; CMP does not allow a LOCK prefix.
        (!!ms-fresh :lock-prefix prefixes))

       (byte-operand? (equal 0 (logand 1 opcode)))
       ((the (integer 1 8) operand-size)
        (select-operand-size byte-operand? rex-byte t prefixes))
       (rAX-size (if (logbitp #.*w* rex-byte)
                     8
                   operand-size))
       (rAX (rgfi-size rAX-size *rax* rex-byte x86))
       ((mv ?flg imm x86)
        (rm-size operand-size temp-rip :x x86))
       ((when flg)
        (!!ms-fresh :rm-size-error flg))

       ;; Sign-extend imm when required.
       (imm
        (if (and (not byte-operand?)
                 (equal rAX-size 8))
            (the (unsigned-byte 64)
              (n64
               (the (signed-byte 32)
                 (n32-to-i32
                  (the (unsigned-byte 32) imm)))))
          (the (unsigned-byte 32) imm)))

       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (+ temp-rip operand-size))
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (<= #.*2^47*
                             (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip))))
        (!!ms-fresh :temp-rip-not-canonical temp-rip))
       ((the (signed-byte #.*max-linear-address-size+1*) addr-diff)
        (-
         (the (signed-byte #.*max-linear-address-size*)
           temp-rip)
         (the (signed-byte #.*max-linear-address-size*)
           start-rip)))
       ((when (< 15 addr-diff))
        (!!ms-fresh :instruction-length addr-diff))

       ;; Everything above this point is just further decoding the
       ;; instruction and fetching operands.

       ;; Instruction Specification:

       ;; Computing the flags and the result:
       ((the (unsigned-byte 32) input-rflags) (rflags x86))
       ((mv result
            (the (unsigned-byte 32) output-rflags)
            (the (unsigned-byte 32)  undefined-flags))
        (gpr-arith/logic-spec rAX-size operation rAX imm input-rflags))

       ;; Updating the x86 state with the result and eflags.
       (x86
        (if (or (eql operation #.*OP-CMP*)
                (eql operation #.*OP-TEST*))
            ;; CMP and TEST modify just the flags.
            x86
          (!rgfi-size rAX-size *rax* result rex-byte x86)))

       (x86 (write-user-rflags output-rflags undefined-flags x86))
       (x86 (!rip temp-rip x86)))

      x86))

;; ======================================================================
;; INSTRUCTION: INC/DEC
;; ======================================================================

(local
 (defthm logsquash-and-logand-32
   (implies (unsigned-byte-p 32 x)
            (equal (bitops::logsquash 1 x)
                   (logand 4294967294 x)))
   :hints (("Goal" :in-theory (e/d (bitops::logsquash)
                                   (bitops::logand-with-negated-bitmask))))))

(def-inst x86-inc/dec-FE-FF

  ;; FE/0,1: INC/DEC r/m8
  ;; FF/0,1: INC/DEC r/m16, r/m32, r/m64

  :parents (one-byte-opcodes)

  :returns (x86 x86p :hyp (and (x86p x86)
                               (canonical-address-p temp-rip)))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'INC #xFE '(:reg 0)
                                      'x86-inc/dec-FE-FF)
    (add-to-implemented-opcodes-table 'DEC #xFE '(:reg 1)
                                      'x86-inc/dec-FE-FF)
    (add-to-implemented-opcodes-table 'INC #xFF '(:reg 0)
                                      'x86-inc/dec-FE-FF)
    (add-to-implemented-opcodes-table 'DEC #xFF '(:reg 1)
                                      'x86-inc/dec-FE-FF))

  :body

  (b* ((ctx 'x86-inc/dec-FE-FF)
       (r/m (the (unsigned-byte 3) (mrm-r/m  modr/m)))
       (mod (the (unsigned-byte 2) (mrm-mod  modr/m)))
       (reg (the (unsigned-byte 3) (mrm-reg  modr/m)))
       (p2 (prefixes-slice :group-2-prefix prefixes))
       (p4? (equal #.*addr-size-override*
                   (prefixes-slice :group-4-prefix prefixes)))
       (select-byte-operand (equal 0 (logand 1 opcode)))
       ((the (integer 1 8) r/mem-size)
        (select-operand-size
         select-byte-operand rex-byte nil prefixes))

       ((mv flg0 r/mem (the (unsigned-byte 3) increment-RIP-by)
            (the (signed-byte #.*max-linear-address-size*) v-addr) x86)
        (x86-operand-from-modr/m-and-sib-bytes
         #.*rgf-access* r/mem-size p2 p4? temp-rip rex-byte r/m mod sib 0 x86))
       ((when flg0)
        (!!ms-fresh :x86-operand-from-modr/m-and-sib-bytes flg0))

       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (+ temp-rip increment-RIP-by))
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (<= #.*2^47*
                             (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip))))
        (!!ms-fresh :virtual-memory-error temp-rip))
       ;; If the instruction goes beyond 15 bytes, stop. Change to an
       ;; exception later.
       ((the (signed-byte #.*max-linear-address-size+1*) addr-diff)
        (-
         (the (signed-byte #.*max-linear-address-size*)
           temp-rip)
         (the (signed-byte #.*max-linear-address-size*)
           start-rip)))
       ((when (< 15 addr-diff))
        (!!ms-fresh :instruction-length addr-diff))

       ;; Computing the flags and the result:
       ((the (unsigned-byte 32) input-rflags) (rflags x86))
       ((the (unsigned-byte 1) old-cf)
        (rflags-slice :cf input-rflags))
       ((mv result output-rflags undefined-flags)
        (gpr-arith/logic-spec r/mem-size
                              (if (eql reg 0)
                                  ;; INC
                                  #.*OP-ADD*
                                ;; DEC
                                #.*OP-SUB*)
                              r/mem 1 input-rflags))

       ;; Updating the x86 state:
       ;; CF is unchanged.
       (output-rflags (the (unsigned-byte 32)
                        (!rflags-slice :cf old-cf output-rflags)))
       (x86 (write-user-rflags output-rflags undefined-flags x86))


       ((mv flg1 x86)
        (x86-operand-to-reg/mem r/mem-size result
                                (the (signed-byte #.*max-linear-address-size*) v-addr)
                                rex-byte r/m mod x86))
       ((when flg1)
        (!!ms-fresh :x86-operand-to-reg/mem flg1))
       (x86 (!rip temp-rip x86)))
      x86))

;; ======================================================================
;; INSTRUCTION: NOT/NEG
;; ======================================================================

(def-inst x86-not/neg-F6-F7

  ;; F6/2: NOT r/m8
  ;; F7/2: NOT r/m16, r/m32, r/m64

  ;; F6/3: NEG r/m8
  ;; F7/3: NEG r/m16, r/m32, r/m64

  :parents (one-byte-opcodes)

  :returns (x86 x86p :hyp (and (x86p x86)
                               (canonical-address-p temp-rip)))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'NOT #xF6 '(:reg 2)
                                      'x86-not/neg-F6-F7)
    (add-to-implemented-opcodes-table 'NOT #xF6 '(:reg 3)
                                      'x86-not/neg-F6-F7)
    (add-to-implemented-opcodes-table 'NEG #xF7 '(:reg 2)
                                      'x86-not/neg-F6-F7)
    (add-to-implemented-opcodes-table 'NEG #xF7 '(:reg 3)
                                      'x86-not/neg-F6-F7))
  :body

  (b* ((ctx 'x86-not/neg-F6-F7)
       (r/m (the (unsigned-byte 3) (mrm-r/m modr/m)))
       (mod (the (unsigned-byte 2) (mrm-mod modr/m)))
       (reg (the (unsigned-byte 3) (mrm-reg modr/m)))
       (p2 (prefixes-slice :group-2-prefix prefixes))
       (p4? (equal #.*addr-size-override*
                   (prefixes-slice :group-4-prefix prefixes)))

       (select-byte-operand (equal 0 (logand 1 opcode)))
       ((the (integer 0 8) r/mem-size)
        (select-operand-size select-byte-operand rex-byte nil
                             prefixes))
       ((mv flg0 r/mem (the (unsigned-byte 3) increment-RIP-by)
            (the (signed-byte #.*max-linear-address-size*) ?v-addr) x86)
        (x86-operand-from-modr/m-and-sib-bytes
         #.*rgf-access* r/mem-size p2 p4? temp-rip rex-byte r/m mod sib 0 x86))
       ((when flg0)
        (!!ms-fresh :x86-operand-from-modr/m-and-sib-bytes flg0))

       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (+ temp-rip increment-RIP-by))
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (<= #.*2^47*
                             (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip))))
        (!!ms-fresh :virtual-memory-error temp-rip))

       ((the (signed-byte #.*max-linear-address-size+1*) addr-diff)
        (-
         (the (signed-byte #.*max-linear-address-size*)
           temp-rip)
         (the (signed-byte #.*max-linear-address-size*)
           start-rip)))
       ((when (< 15 addr-diff))
        (!!ms-fresh :instruction-length addr-diff))

       ;; Computing the flags and the result:

       ((the (unsigned-byte 32) input-rflags) (rflags x86))
       ((mv result
            (the (unsigned-byte 32) output-rflags)
            (the (unsigned-byte 32) undefined-flags))
        (case reg
          (3
           ;; (NEG x) = (SUB 0 x)
           (gpr-arith/logic-spec r/mem-size #.*OP-SUB* 0 r/mem input-rflags))
          (otherwise
           ;; NOT (and some other instructions not specified yet)
           (mv (trunc r/mem-size (lognot r/mem)) 0 0))))

       ;; Updating the x86 state:
       (x86
        (if (eql reg 3)
            (let* ( ;; CF is special for NEG.
                   (cf (the (unsigned-byte 1) (if (equal 0 r/mem) 0 1)))
                   (output-rflags
                    (the (unsigned-byte 32)
                      (!rflags-slice :cf cf output-rflags)))
                   (x86 (write-user-rflags output-rflags undefined-flags x86)))
              x86)
          x86))
       ((mv flg1 x86)
        (x86-operand-to-reg/mem
         r/mem-size result (the (signed-byte #.*max-linear-address-size*) v-addr)
         rex-byte r/m mod x86))
       ((when flg1)
        (!!ms-fresh :x86-operand-to-reg/mem flg1))
       (x86 (!rip temp-rip x86)))
      x86))

;; ======================================================================
