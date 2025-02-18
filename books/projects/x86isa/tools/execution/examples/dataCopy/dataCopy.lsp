;; Author: Shilpi Goel <shigoel@cs.utexas.edu>

;; A simple program that copies data from one location to another.

(in-package "X86ISA")

(include-book "../../top" :ttags :all)

;; ======================================================================

;; Read and load binary into the x86 model's memory:
(binary-file-load "dataCopy.o")

;; 0000000100000ed0 <_copyData>:
;;    100000ed0:	55                      push   %rbp
;;    100000ed1:	48 89 e5                mov    %rsp,%rbp
;;    100000ed4:	85 d2                   test   %edx,%edx
;;    100000ed6:	74 1a                   je     100000ef2 <_copyData+0x22>
;;    100000ed8:	48 63 c2                movslq %edx,%rax
;;    100000edb:	48 c1 e0 02             shl    $0x2,%rax
;;    100000edf:	90                      nop
;;    100000ee0:	8b 0f                   mov    (%rdi),%ecx
;;    100000ee2:	48 83 c7 04             add    $0x4,%rdi
;;    100000ee6:	89 0e                   mov    %ecx,(%rsi)
;;    100000ee8:	48 83 c6 04             add    $0x4,%rsi
;;    100000eec:	48 83 c0 fc             add    $0xfffffffffffffffc,%rax
;;    100000ef0:	75 ee                   jne    100000ee0 <_copyData+0x10>
;;    100000ef2:	5d                      pop    %rbp
;;    100000ef3:	c3                      retq


(!programmer-level-mode t x86)

;; Initialize the x86 state:
(init-x86-state
 ;; Status (MS and fault field)
 nil
 ;; Start Address --- set the RIP to this address
 #x100000ed0
 ;; Halt Address --- overwrites this address by #xF4 (HLT)
 #x100000ef3
 ;; Initial values of General-Purpose Registers
 '((#.*RAX* . #x1)
   (#.*RBX* . #x0)
   (#.*RCX* . #x4B00345618D749B7)
   (#.*RDX* . #x5)            ;; n
   (#.*RSI* . #x7FFF5FBFF430) ;; destination
   (#.*RDI* . #x7FFF5FBFF450) ;; source
   (#.*RBP* . #x7FFF5FBFF470)
   (#.*RSP* . #x7FFF5FBFF418)
   (#.*R8*  . #x7FFF5FBFF290)
   (#.*R9*  . #x7FFF7A90F300)
   (#.*R10* . #xA)
   (#.*R11* . #x246)
   (#.*R12* . #x0)
   (#.*R13* . #x0)
   (#.*R14* . #x0)
   (#.*R15* . #x0))
 ;; Control Registers: a value of nil will not nullify existing
 ;; values.
 nil
 ;; Model-Specific Registers: a value of nil will not nullify existing
 ;; values.
 nil ;; (!ia32_efer-slice :ia32_efer-lma 1 (!ia32_efer-slice :ia32_efer-sce 1 0))
 ;; Rflags Register
 #x202
 ;; Source Array
 '((#x7FFF5FBFF450 . 6)
   (#x7FFF5FBFF454 . 7)
   (#x7FFF5FBFF458 . 8)
   (#x7FFF5FBFF45C . 9)
   (#x7FFF5FBFF460 . 10))
 ;; x86 state
 x86)

;; Run the program for up to 100000 or till the machine halts, whatever comes first:
(x86-run-steps 1000000 x86)

;; ======================================================================
;; Inspect the output:

(set-print-base 10 state)

;; Destination Array:
(rb
 '(#x7FFF5FBFF430
   #x7FFF5FBFF434
   #x7FFF5FBFF438
   #x7FFF5FBFF43C
   #x7FFF5FBFF440)
 :r x86)

;; Source Array:
(rb
 '(#x7FFF5FBFF450
   #x7FFF5FBFF454
   #x7FFF5FBFF458
   #x7FFF5FBFF45C
   #x7FFF5FBFF460)
 :r x86)

;; ======================================================================
