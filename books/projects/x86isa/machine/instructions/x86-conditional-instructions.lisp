;; AUTHOR:
;; Shilpi Goel <shigoel@cs.utexas.edu>

(in-package "X86ISA")

;; ======================================================================

(include-book "../x86-decoding-and-spec-utils"
              :ttags (:include-raw :syscall-exec :other-non-det :undef-flg))
(local (include-book "centaur/bitops/ihs-extensions" :dir :system))

;; ======================================================================
;; INSTRUCTION: Jcc/JrCXZ/CMOVcc/SETcc
;; ======================================================================

; From Intel Vol. 1, 6-11:

;; In 64-bit mode, the operand size for all near branches (CALL, RET, JCC,
;; JCXZ, JMP, and LOOP) is forced to 64 bits. These instructions update the
;; 64-bit RIP without the need for a REX operand-size prefix.

;; The following aspects of near branches are controlled by the effective
;; operand size:
;;   Truncation of the size of the instruction pointer
;;   Size of a stack pop or push, due to a CALL or RET
;;   Size of a stack-pointer increment or decrement, due to a CALL or RET
;;   Indirect-branch operand size

;; In 64-bit mode, all of the above actions are forced to 64 bits regardless of
;; operand size prefixes (operand size prefixes are silently ignored). However,
;; the displacement field for relative branches is still limited to 32 bits and
;; the address size for near branches is not forced in 64-bit mode.

;; Address sizes affect the size of RCX used for JCXZ and LOOP; they also
;; impact the address calculation for memory indirect branches. Such addresses
;; are 64 bits by default; but they can be overridden to 32 bits by an address
;; size prefix.

(define jcc/cmovcc/setcc-spec
  ((opcode :type (unsigned-byte 8))
   x86)

  ;; Jcc

  ;; Op    Instruction                                  Condition
  ;; 70    JO rel8                                      Jump if OF = 1
  ;; 71    JNO rel8                                     Jump if OF = 0
  ;; 72    JB/NAE/C rel8                                Jump if CF = 1
  ;; 73    JNB/AE/NC rel8                               Jump if CF = 0
  ;; 74    JZ/E rel8                                    Jump if ZF = 1
  ;; 75    JNZ/NE rel8                                  Jump if ZF = 0
  ;; 76    JBE/NA rel8                                  Jump if CF = 1 or ZF = 1
  ;; 77    JNBE/A rel8                                  Jump if CF = 0 and ZF = 0
  ;; 78    JS rel8                                      Jump if SF = 1
  ;; 79    JNS rel8                                     Jump if SF = 0
  ;; 7A    JP/PE rel8                                   Jump if PF = 1
  ;; 7B    JNP/PO rel8                                  Jump if PF = 0
  ;; 7C    JL/NGE rel8                                  Jump if SF != OF
  ;; 7D    JNL/GE rel8                                  Jump if SF = OF
  ;; 7E    JLE/NG rel8                                  Jump if ZF = 1 or SF != OF
  ;; 7F    JNLE/G rel8                                  Jump if ZF = 0 and SF = OF

  ;; Op    Instruction                                  Condition
  ;; 0F 80 JO rel32                                     Jump if OF = 1
  ;; 0F 81 JNO rel32                                    Jump if OF = 0
  ;; 0F 82 JB/NAE/C rel32                               Jump if CF = 1
  ;; 0F 83 JNB/AE/NC rel32                              Jump if CF = 0
  ;; 0F 84 JZ/E rel32                                   Jump if ZF = 1
  ;; 0F 85 JNZ/JNE rel32                                Jump if ZF = 0
  ;; 0F 86 JBE/NA rel32                                 Jump if CF = 1 or ZF = 1
  ;; 0F 87 JNBE/A rel32                                 Jump if CF = 0 and ZF = 0
  ;; 0F 88 JS rel32                                     Jump if SF = 1
  ;; 0F 89 JNS rel32                                    Jump if SF = 0
  ;; 0F 8A JP/PE rel32                                  Jump if PF = 1
  ;; 0F 8B JNP/PO rel32                                 Jump if PF = 0
  ;; 0F 8C JL/NGE rel32                                 Jump if SF != OF
  ;; 0F 8D JNL/GE rel32                                 Jump if SF = OF
  ;; 0F 8E JLE/NG rel32                                 Jump if ZF = 1 or SF != OF
  ;; 0F 8F JNLE/G rel32                                 Jump if ZF = 0 and SF = OF

  ;; CMOVcc

  ;; 0F 40 CMOVO r16/32/64, r/m16/32/64                 Move if OF = 1
  ;; 0F 41 CMOVNO r16/32/64, r/m16/32/64                Move if OF = 0
  ;; 0F 42 CMOVB/CMOVC/CMOVNAE r16/32/64, r/m16/32/64   Move if CF = 1
  ;; 0F 43 CMOVAE/CMOVNB/CMOVNC r16/32/64, r/m16/32/64  Move if CF = 0
  ;; 0F 44 CMOVE/CMOVZ r16/32/64, r/m16/32/64           Move if ZF = 1
  ;; 0F 45 CMOVNE/CMOVNZ r16/32/64, r/m16/32/64         Move if ZF = 0
  ;; 0F 46 CMOVBE/CMOVNA r16/32/64, r/m16/32/64         Move if CF = 1 or ZF = 1
  ;; 0F 47 CMOVA/CMOVNBE  r16/32/64, r/m16/32/64        Move if CF = 0 and ZF = 0
  ;; 0F 48 CMOVS r16/32/64, r/m16/32/64                 Move if SF = 1
  ;; 0F 49 CMOVNS r16/32/64, r/m16/32/64                Move if SF = 0
  ;; 0F 4A CMOVP/CMOVPE r16/32/64, r/m16/32/64          Move if PF = 1
  ;; 0F 4B CMOVNP/CMOVPO r16/32/64, r/m16/32/64         Move if PF = 0
  ;; 0F 4C CMOVL/CMOVNGE r16/32/64, r/m16/32/64         Move if SF != OF
  ;; 0F 4D CMOVGE/CMOVNL r16/32/64, r/m16/32/64         Move if SF = OF
  ;; 0F 4E CMOVLE/CMOVNG r16/32/64, r/m16/32/64         Move if ZF = 1 or SF != OF
  ;; 0F 4F CMOVG/CMOVNLE r16/32/64, r/m16/32/64         Move if ZF = 0 and SF = OF

  (let ((low-nibble (the (unsigned-byte 4) (logand opcode #xf))))
    (case low-nibble
      (#x0 (equal 1 (the (unsigned-byte 1) (flgi #.*of* x86))))
      (#x1 (equal 0 (the (unsigned-byte 1) (flgi #.*of* x86))))
      (#x2 (equal 1 (the (unsigned-byte 1) (flgi #.*cf* x86))))
      (#x3 (equal 0 (the (unsigned-byte 1) (flgi #.*cf* x86))))
      (#x4 (equal 1 (the (unsigned-byte 1) (flgi #.*zf* x86))))
      (#x5 (equal 0 (the (unsigned-byte 1) (flgi #.*zf* x86))))
      (#x6 (or (equal 1 (the (unsigned-byte 1) (flgi #.*cf* x86)))
               (equal 1 (the (unsigned-byte 1) (flgi #.*zf* x86)))))
      (#x7 (and (equal 0 (the (unsigned-byte 1) (flgi #.*cf* x86)))
                (equal 0 (the (unsigned-byte 1) (flgi #.*zf* x86)))))
      (#x8 (equal 1 (the (unsigned-byte 1) (flgi #.*sf* x86))))
      (#x9 (equal 0 (the (unsigned-byte 1) (flgi #.*sf* x86))))
      (#xA (equal 1 (the (unsigned-byte 1) (flgi #.*pf* x86))))
      (#xB (equal 0 (the (unsigned-byte 1) (flgi #.*pf* x86))))
      (#xC (not (equal (the (unsigned-byte 1) (flgi #.*sf* x86))
                       (the (unsigned-byte 1) (flgi #.*of* x86)))))
      (#xD (equal (the (unsigned-byte 1) (flgi #.*sf* x86))
                  (the (unsigned-byte 1) (flgi #.*of* x86))))
      (#xE (or (equal 1 (the (unsigned-byte 1) (flgi #.*zf* x86)))
               (not (equal (the (unsigned-byte 1) (flgi #.*sf* x86))
                           (the (unsigned-byte 1) (flgi #.*of* x86))))))
      (#xF (and (equal 0 (the (unsigned-byte 1) (flgi #.*zf* x86)))
                (equal (the (unsigned-byte 1) (flgi #.*sf* x86))
                       (the (unsigned-byte 1) (flgi #.*of* x86)))))
      (otherwise ;; will not be reached
       nil))))

(def-inst x86-one-byte-jcc

  ;; Jump (short) if condition is met

  ;; Intel Vol. 2A, p. 3-554 says: "In 64-bit mode, operand size is
  ;; fixed at 64 bits. JMP Short is RIP + 8-bit offset sign extended to
  ;; 64 bits."

  ;; Op/En: D
  ;; Jcc

  ;; Op    Instruction                                  Condition
  ;; 70    JO rel8                                      Jump if OF = 1
  ;; 71    JNO rel8                                     Jump if OF = 0
  ;; 72    JB/NAE/C rel8                                Jump if CF = 1
  ;; 73    JNB/AE/NC rel8                               Jump if CF = 0
  ;; 74    JZ/E rel8                                    Jump if ZF = 1
  ;; 75    JNZ/NE rel8                                  Jump if ZF = 0
  ;; 76    JBE/NA rel8                                  Jump if CF = 1 or ZF = 1
  ;; 77    JNBE/A rel8                                  Jump if CF = 0 and ZF = 0
  ;; 78    JS rel8                                      Jump if SF = 1
  ;; 79    JNS rel8                                     Jump if SF = 0
  ;; 7A    JP/PE rel8                                   Jump if PF = 1
  ;; 7B    JNP/PO rel8                                  Jump if PF = 0
  ;; 7C    JL/NGE rel8                                  Jump if SF != OF
  ;; 7D    JNL/GE rel8                                  Jump if SF = OF
  ;; 7E    JLE/NG rel8                                  Jump if ZF = 1 or SF != OF
  ;; 7F    JNLE/G rel8                                  Jump if ZF = 0 and SF = OF

  :parents (one-byte-opcodes)
  :guard-hints (("Goal" :in-theory (e/d (rim08 rim32) ())))

  :returns (x86 x86p :hyp (and (x86p x86)
                               (canonical-address-p temp-rip)))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'JO #x70 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JNO #x71 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JC #x72 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JNC #x73 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JZ #x74 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JNZ #x75 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JBE #x76 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JNBE #x77 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JS #x78 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JNS #x79 '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JP #x7A '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JNP #x7B '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JL #x7C '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JNL #x7D '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JLE #x7E '(:nil nil)
                                      'x86-one-byte-jcc)
    (add-to-implemented-opcodes-table 'JNLE #x7F '(:nil nil)
                                      'x86-one-byte-jcc))
  :body

  (b* ((ctx 'x86-one-byte-jcc)
       (lock? (equal #.*lock* (prefixes-slice :group-1-prefix prefixes)))
       ((when lock?)
        (!!ms-fresh :lock-prefix prefixes))

       (branch-cond (jcc/cmovcc/setcc-spec opcode x86))
       ((mv ?flg (the (signed-byte #.*max-linear-address-size+1*) rel8/next-rip) x86)
        (if branch-cond
            (rim-size 1 temp-rip :x x86)
          (mv nil (+ 1 temp-rip) x86)))
       ((when flg)
        (!!ms-fresh :rim-size-error flg))
       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (if branch-cond
            (+ (+ 1 temp-rip) ;; rip of the next instruction
               rel8/next-rip) ;; rel8
          rel8/next-rip)      ;; next-rip
        )
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (or
                          (< (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip)
                             #.*-2^47*)
                          (<= #.*2^47*
                              (the (signed-byte
                                    #.*max-linear-address-size+1*)
                                temp-rip)))))
        (!!ms-fresh :virtual-memory-error temp-rip))
       ;; Update the x86 state:
       (x86 (!rip temp-rip x86)))
      x86))

(def-inst x86-two-byte-jcc

  ;; Jump (near) if condition is met

  ;; Intel Vol. 2A, p. 3-554 says: "In 64-bit mode, operand size is
  ;; fixed at 64 bits. JMP Short is RIP + 32-bit offset sign extended to
  ;; 64 bits."

  ;; Two-byte Jcc: The operand-size is forced to a 64-bit operand size
  ;; when in 64-bit mode (prefixes that change operand size are ignored
  ;; for this instruction in 64-bit mode).  See Intel Manual, Vol. 2C,
  ;; p. A-8.

  ;; Op/En: D
  ;; Op    Instruction                                  Condition
  ;; 0F 80 JO rel32                                     Jump if OF = 1
  ;; 0F 81 JNO rel32                                    Jump if OF = 0
  ;; 0F 82 JB/NAE/C rel32                               Jump if CF = 1
  ;; 0F 83 JNB/AE/NC rel32                              Jump if CF = 0
  ;; 0F 84 JZ/E rel32                                   Jump if ZF = 1
  ;; 0F 85 JNZ/JNE rel32                                Jump if ZF = 0
  ;; 0F 86 JBE/NA rel32                                 Jump if CF = 1 or ZF = 1
  ;; 0F 87 JNBE/A rel32                                 Jump if CF = 0 and ZF = 0
  ;; 0F 88 JS rel32                                     Jump if SF = 1
  ;; 0F 89 JNS rel32                                    Jump if SF = 0
  ;; 0F 8A JP/PE rel32                                  Jump if PF = 1
  ;; 0F 8B JNP/PO rel32                                 Jump if PF = 0
  ;; 0F 8C JL/NGE rel32                                 Jump if SF != OF
  ;; 0F 8D JNL/GE rel32                                 Jump if SF = OF
  ;; 0F 8E JLE/NG rel32                                 Jump if ZF = 1 or SF != OF
  ;; 0F 8F JNLE/G rel32                                 Jump if ZF = 0 and SF = OF

  :parents (two-byte-opcodes)
  :guard-hints (("Goal" :in-theory (e/d (rim08 rim32) ())))

  :returns (x86 x86p :hyp (and (x86p x86)
                               (canonical-address-p temp-rip)))

  :implemented
  (progn
    (add-to-implemented-opcodes-table 'JO #x0F80 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JNO #x0F81 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JC #x0F82 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JNC #x0F83 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JZ #x0F84 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JNZ #x0F85 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JBE #x0F86 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JNBE #x0F87 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JS #x0F88 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JNS #x0F89 '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JP #x0F8A '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JNP #x0F8B '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JL #x0F8C '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JNL #x0F8D '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JLE #x0F8E '(:nil nil)
                                      'x86-two-byte-jcc)
    (add-to-implemented-opcodes-table 'JNLE #x0F8F '(:nil nil)
                                      'x86-two-byte-jcc))

  :body

  ;; Note: Here opcode is the second byte of the two byte opcode.

  (b* ((ctx 'x86-two-byte-jcc)
       (lock? (equal #.*lock* (prefixes-slice :group-1-prefix prefixes)))
       ((when lock?)
        (!!ms-fresh :lock-prefix prefixes))

       (branch-cond (jcc/cmovcc/setcc-spec opcode x86))
       ((mv ?flg (the (signed-byte #.*max-linear-address-size+1*)
                   rel32/next-rip)
            x86)
        (if branch-cond
            (rim-size 4 temp-rip :x x86) ;; rel32
          (mv nil (+ 4 temp-rip) x86)))  ;; next-rip
       ((when flg)
        (!!ms-fresh :rim-size-error flg))
       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (if branch-cond
            (+ (the (signed-byte #.*max-linear-address-size+1*)
                 (+ 4 temp-rip)) ;; rip of the next instruction
               rel32/next-rip)   ;; rel32
          rel32/next-rip)        ;; next-rip
        )

       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (or
                          (< (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip)
                             #.*-2^47*)
                          (<= #.*2^47*
                              (the (signed-byte
                                    #.*max-linear-address-size+1*)
                                temp-rip)))))
        (!!ms-fresh :virtual-memory-error temp-rip))

       ;; Update the x86 state:
       (x86 (!rip temp-rip x86)))
      x86))

(def-inst x86-jrcxz

  ;; Jump (short) if condition is met

  ;; E3 cb: JECXZ rel8 Jump short if ECX is 0
  ;; E3 cb: JRCXZ rel8 Jump short if RCX is 0

  ;; The register checked is determined by the address-size attribute.

  ;; Jump short: RIP = RIP + 8-bit offset sign-extended to 64-bits

  ;; Op/En: D

  :parents (one-byte-opcodes)
  :guard-hints (("Goal" :in-theory (e/d (rim08 rim32) ())))

  :returns (x86 x86p :hyp (and (x86p x86)
                               (canonical-address-p temp-rip)))
  :implemented
  (add-to-implemented-opcodes-table 'JRCXZ #xE3 '(:nil nil) 'x86-jrcxz)

  :body

  (b* ((ctx 'x86-jrcxz)
       (lock? (equal #.*lock* (prefixes-slice :group-1-prefix prefixes)))
       ((when lock?)
        (!!ms-fresh :lock-prefix prefixes))
       (p4? (equal #.*addr-size-override*
                   (prefixes-slice :group-4-prefix prefixes)))
       (register-size (if p4? 4 8))
       (branch-cond
        (equal (rgfi-size register-size *rcx* rex-byte x86) 0))
       ((mv ?flg (the (signed-byte #.*max-linear-address-size+1*) rel8/next-rip) x86)
        (if branch-cond
            (rim-size 1 temp-rip :x x86)
          (mv nil (+ 1 temp-rip) x86)))
       ((when flg)
        (!!ms-fresh :rim-size-error flg))

       ((the (signed-byte #.*max-linear-address-size+1*) temp-rip)
        (if branch-cond
            (+ (the (signed-byte #.*max-linear-address-size+1*)
                 (+ 1 temp-rip)) ;; rip of the next instruction
               rel8/next-rip)    ;; rel8
          rel8/next-rip)         ;; next-rip
        )
       ((when (mbe :logic (not (canonical-address-p temp-rip))
                   :exec (or
                          (< (the (signed-byte
                                   #.*max-linear-address-size+1*)
                               temp-rip)
                             #.*-2^47*)
                          (<= #.*2^47*
                              (the (signed-byte
                                    #.*max-linear-address-size+1*)
                                temp-rip)))))
        (!!ms-fresh :virtual-memory-error temp-rip))
       ;; Update the x86 state:
       (x86 (!rip temp-rip x86)))
      x86))

(def-inst x86-cmovcc

  ;; Op/En: RM
  ;; [OP REG, R/M]

  ;; CMOVcc

  ;; 0F 40 CMOVO r16/32/64, r/m16/32/64                 Move if OF = 1
  ;; 0F 41 CMOVNO r16/32/64, r/m16/32/64                Move if OF = 0
  ;; 0F 42 CMOVB/CMOVC/CMOVNAE r16/32/64, r/m16/32/64   Move if CF = 1
  ;; 0F 43 CMOVAE/CMOVNB/CMOVNC r16/32/64, r/m16/32/64  Move if CF = 0
  ;; 0F 44 CMOVE/CMOVZ r16/32/64, r/m16/32/64           Move if ZF = 1
  ;; 0F 45 CMOVNE/CMOVNZ r16/32/64, r/m16/32/64         Move if ZF = 0
  ;; 0F 46 CMOVBE/CMOVNA r16/32/64, r/m16/32/64         Move if CF = 1 or ZF = 1
  ;; 0F 47 CMOVA/CMOVNBE  r16/32/64, r/m16/32/64        Move if CF = 0 and ZF = 0
  ;; 0F 48 CMOVS r16/32/64, r/m16/32/64                 Move if SF = 1
  ;; 0F 49 CMOVNS r16/32/64, r/m16/32/64                Move if SF = 0
  ;; 0F 4A CMOVP/CMOVPE r16/32/64, r/m16/32/64          Move if PF = 1
  ;; 0F 4B CMOVNP/CMOVPO r16/32/64, r/m16/32/64         Move if PF = 0
  ;; 0F 4C CMOVL/CMOVNGE r16/32/64, r/m16/32/64         Move if SF != OF
  ;; 0F 4D CMOVGE/CMOVNL r16/32/64, r/m16/32/64         Move if SF = OF
  ;; 0F 4E CMOVLE/CMOVNG r16/32/64, r/m16/32/64         Move if ZF = 1 or SF != OF
  ;; 0F 4F CMOVG/CMOVNLE r16/32/64, r/m16/32/64         Move if ZF = 0 and SF = OF


  :parents (two-byte-opcodes)
  :guard-hints (("Goal" :in-theory (e/d (rim08 rim32) ())))

  :returns (x86 x86p :hyp (and (x86p x86)
                               (canonical-address-p temp-rip)))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'CMOVO #x0F40 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVNO #x0F41 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVC #x0F42 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVNC #x0F43 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVZ #x0F44 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVNZ #x0F45 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVBE #x0F46 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVNBE #x0F40F4 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVS #x0F48 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVNS #x0F49 '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVP #x0F4A '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVNP #x0F4B '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVL #x0F4C '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVNL #x0F4D '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVLE #x0F4E '(:nil nil)
                                      'x86-cmovcc)
    (add-to-implemented-opcodes-table 'CMOVNLE #x0F4F '(:nil nil)
                                      'x86-cmovcc))

  :body

  ;; Note, opcode here denotes the second byte of the two-byte opcode.

  (b* ((ctx 'x86-cmovcc)

       (r/m (the (unsigned-byte 3) (mrm-r/m modr/m)))
       (mod (the (unsigned-byte 2) (mrm-mod  modr/m)))
       (reg (the (unsigned-byte 3) (mrm-reg  modr/m)))

       (lock? (equal #.*lock* (prefixes-slice :group-1-prefix prefixes)))
       ((when lock?)
        (!!ms-fresh :lock-prefix prefixes))
       (p2 (prefixes-slice :group-2-prefix prefixes))

       ((the (integer 1 8) operand-size)
        (select-operand-size nil rex-byte nil prefixes))
       (p4? (equal #.*addr-size-override*
                   (prefixes-slice :group-4-prefix prefixes)))
       ((mv flg0 reg/mem (the (unsigned-byte 3) increment-RIP-by)
            (the (signed-byte #.*max-linear-address-size*) ?v-addr) x86)
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

       (branch-cond (jcc/cmovcc/setcc-spec opcode x86))

       ;; Update the x86 state:
       (x86
        (if branch-cond
            (!rgfi-size operand-size (reg-index reg rex-byte #.*r*)
                        reg/mem rex-byte x86)
          x86))
       (x86 (!rip temp-rip x86)))
      x86))

(def-inst x86-setcc

  ;; Op/En: M

  ;; SETcc

  ;; 0F 90 SETO r/m8                                    Set if OF = 1
  ;; 0F 91 SETNO r/m8                                   Set if OF = 0
  ;; 0F 92 SETB/SETC/SETNAE r/m8                        Set if CF = 1
  ;; 0F 93 SETAE/SETNB/SETNC r/m8                       Set if CF = 0
  ;; 0F 94 SETE/SETZ r/m8                               Set if ZF = 1
  ;; 0F 95 SETNE/SETNZ r/m8                             Set if ZF = 0
  ;; 0F 96 SETBE/SETNA r/m8                             Set if CF = 1 or ZF = 1
  ;; 0F 97 SETA/SETNBE  r/m8                            Set if CF = 0 and ZF = 0
  ;; 0F 98 SETS r/m8                                    Set if SF = 1
  ;; 0F 99 SETNS r/m8                                   Set if SF = 0
  ;; 0F 9A SETP/SETPE r/m8                              Set if PF = 1
  ;; 0F 9B SETNP/SETPO r/m8                             Set if PF = 0
  ;; 0F 9C SETL/SETNGE r/m8                             Set if SF != OF
  ;; 0F 9D SETGE/SETNL r/m8                             Set if SF = OF
  ;; 0F 9E SETLE/SETNG r/m8                             Set if ZF = 1 or SF != OF
  ;; 0F 9F SETG/SETNLE r/m8                             Set if ZF = 0 and SF = OF

  :parents (two-byte-opcodes)
  :guard-hints (("Goal" :in-theory (e/d (rim08 rim32) ())))

  :returns (x86 x86p :hyp (and (x86p x86)
                               (canonical-address-p temp-rip)))
  :implemented
  (progn
    (add-to-implemented-opcodes-table 'SETO #x0F90 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETNO #x0F91 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETC #x0F92 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETNC #x0F93 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETZ #x0F94 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETNZ #x0F95 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETBE #x0F96 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETNBE #x0F97 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETS #x0F98 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETNS #x0F99 '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETP #x0F9A '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETNP #x0F9B '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETL #x0F9C '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETNL #x0F9D '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETLE #x0F9E '(:nil nil)
                                      'x86-setcc)
    (add-to-implemented-opcodes-table 'SETNLE #x0F9F '(:nil nil)
                                      'x86-setcc))

  :body

  ;; Note, opcode here denotes the second byte of the two-byte opcode.

  (b* ((ctx 'x86-setcc)

       (r/m (the (unsigned-byte 3) (mrm-r/m modr/m)))
       (mod (the (unsigned-byte 2) (mrm-mod  modr/m)))
       (lock? (equal #.*lock* (prefixes-slice :group-1-prefix prefixes)))
       ((when lock?)
        (!!ms-fresh :lock-prefix prefixes))
       (p2 (prefixes-slice :group-2-prefix prefixes))
       (p4? (equal #.*addr-size-override*
                   (prefixes-slice :group-4-prefix prefixes)))
       ((mv flg0 (the (signed-byte 64) v-addr) (the (unsigned-byte 3) increment-RIP-by) x86)
        (if (equal mod #b11)
            (mv nil 0 0 x86)
          (x86-effective-addr p4? temp-rip rex-byte r/m mod sib 0 x86)))
       ((when flg0)
        (!!ms-fresh :x86-effective-addr-error flg0))
       ((mv flg1 v-addr)
        (case p2
          (0 (mv nil v-addr))
          ;; I don't really need to check whether FS and GS base are
          ;; canonical or not.  On the real machine, if the MSRs
          ;; containing these bases are assigned non-canonical
          ;; addresses, an exception is raised.
          (#.*fs-override*
           (let* ((nat-fs-base (msri *IA32_FS_BASE-IDX* x86))
                  (fs-base (n64-to-i64 nat-fs-base)))
             (if (not (canonical-address-p fs-base))
                 (mv 'Non-Canonical-FS-Base fs-base)
               (mv nil (+ fs-base v-addr)))))
          (#.*gs-override*
           (let* ((nat-gs-base (msri *IA32_GS_BASE-IDX* x86))
                  (gs-base (n64-to-i64 nat-gs-base)))
             (if (not (canonical-address-p gs-base))
                 (mv 'Non-Canonical-GS-Base gs-base)
               (mv nil (+ gs-base v-addr)))))
          (t (mv 'Unidentified-P2 v-addr))))
       ((when flg1)
        (!!ms-fresh :Fault-in-FS/GS-Segment-Addressing flg1))
       ((when (not (canonical-address-p v-addr)))
        (!!ms-fresh :v-addr-not-canonical v-addr))

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

       (branch-cond (jcc/cmovcc/setcc-spec opcode x86))

       ;; Update the x86 state:
       (val (if branch-cond 1 0))
       ((mv flg2 x86)
        (x86-operand-to-reg/mem 1 val
                                (the (signed-byte
                                      #.*max-linear-address-size+1*) v-addr)
                                rex-byte r/m mod x86))
       ;; Note: If flg1 is non-nil, we bail out without changing the x86 state.
       ((when flg2)
        (!!ms-fresh :x86-operand-to-reg/mem flg2))
       (x86 (!rip temp-rip x86)))
      x86))

;; ======================================================================
