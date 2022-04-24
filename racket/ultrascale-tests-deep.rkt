; "Deep" tests, in which we see if we can synthesize functions using multiple CLBs in sequence.
#lang racket

(require "ultrascale.rkt"
         rosette
         "programs-to-synthesize.rkt"
         "circt-comb-operators.rkt")

(define-symbolic cin-0 (bitvector 1))
(define-symbolic lut-memory-a-0 (bitvector 64))
(define-symbolic lut-memory-b-0 (bitvector 64))
(define-symbolic lut-memory-c-0 (bitvector 64))
(define-symbolic lut-memory-d-0 (bitvector 64))
(define-symbolic lut-memory-e-0 (bitvector 64))
(define-symbolic lut-memory-f-0 (bitvector 64))
(define-symbolic lut-memory-g-0 (bitvector 64))
(define-symbolic lut-memory-h-0 (bitvector 64))
(define-symbolic mux-selector-a-0 (bitvector 2))
(define-symbolic mux-selector-b-0 (bitvector 2))
(define-symbolic mux-selector-c-0 (bitvector 2))
(define-symbolic mux-selector-d-0 (bitvector 2))
(define-symbolic mux-selector-e-0 (bitvector 2))
(define-symbolic mux-selector-f-0 (bitvector 2))
(define-symbolic mux-selector-g-0 (bitvector 2))
(define-symbolic mux-selector-h-0 (bitvector 2))
(assert (< (bitvector->natural mux-selector-a-0) 3))
(assert (< (bitvector->natural mux-selector-b-0) 3))
(assert (< (bitvector->natural mux-selector-c-0) 3))
(assert (< (bitvector->natural mux-selector-d-0) 3))
(assert (< (bitvector->natural mux-selector-e-0) 3))
(assert (< (bitvector->natural mux-selector-f-0) 3))
(assert (< (bitvector->natural mux-selector-g-0) 3))
(assert (< (bitvector->natural mux-selector-h-0) 3))

(define-symbolic logical-input-0-0 (bitvector 8))
(define-symbolic logical-input-1-0 (bitvector 8))
(define-symbolic logical-input-2-0 (bitvector 8))
(define-symbolic logical-input-3-0 (bitvector 8))
(define-symbolic logical-input-4-0 (bitvector 8))
(define-symbolic logical-input-5-0 (bitvector 8))

(define out-0
  (apply ultrascale-clb
         cin-0
         lut-memory-a-0
         lut-memory-b-0
         lut-memory-c-0
         lut-memory-d-0
         lut-memory-e-0
         lut-memory-f-0
         lut-memory-g-0
         lut-memory-h-0
         mux-selector-a-0
         mux-selector-b-0
         mux-selector-c-0
         mux-selector-d-0
         mux-selector-e-0
         mux-selector-f-0
         mux-selector-g-0
         mux-selector-h-0
         (ultrascale-logical-to-physical-inputs logical-input-0-0
                                                logical-input-1-0
                                                logical-input-2-0
                                                logical-input-3-0
                                                logical-input-4-0
                                                logical-input-5-0)))

(define logical-inputs-0
  (list logical-input-0-0
        logical-input-1-0
        logical-input-2-0
        logical-input-3-0
        logical-input-4-0
        logical-input-5-0))

(define-symbolic cin-1 (bitvector 1))
(define-symbolic lut-memory-a-1 (bitvector 64))
(define-symbolic lut-memory-b-1 (bitvector 64))
(define-symbolic lut-memory-c-1 (bitvector 64))
(define-symbolic lut-memory-d-1 (bitvector 64))
(define-symbolic lut-memory-e-1 (bitvector 64))
(define-symbolic lut-memory-f-1 (bitvector 64))
(define-symbolic lut-memory-g-1 (bitvector 64))
(define-symbolic lut-memory-h-1 (bitvector 64))
(define-symbolic mux-selector-a-1 (bitvector 2))
(define-symbolic mux-selector-b-1 (bitvector 2))
(define-symbolic mux-selector-c-1 (bitvector 2))
(define-symbolic mux-selector-d-1 (bitvector 2))
(define-symbolic mux-selector-e-1 (bitvector 2))
(define-symbolic mux-selector-f-1 (bitvector 2))
(define-symbolic mux-selector-g-1 (bitvector 2))
(define-symbolic mux-selector-h-1 (bitvector 2))
(assert (< (bitvector->natural mux-selector-a-1) 3))
(assert (< (bitvector->natural mux-selector-b-1) 3))
(assert (< (bitvector->natural mux-selector-c-1) 3))
(assert (< (bitvector->natural mux-selector-d-1) 3))
(assert (< (bitvector->natural mux-selector-e-1) 3))
(assert (< (bitvector->natural mux-selector-f-1) 3))
(assert (< (bitvector->natural mux-selector-g-1) 3))
(assert (< (bitvector->natural mux-selector-h-1) 3))

(define out-1
  (ultrascale-clb cin-1
                  lut-memory-a-1
                  lut-memory-b-1
                  lut-memory-c-1
                  lut-memory-d-1
                  lut-memory-e-1
                  lut-memory-f-1
                  lut-memory-g-1
                  lut-memory-h-1
                  mux-selector-a-1
                  mux-selector-b-1
                  mux-selector-c-1
                  mux-selector-d-1
                  mux-selector-e-1
                  mux-selector-f-1
                  mux-selector-g-1
                  mux-selector-h-1
                  (zero-extend (bit 0 out-0) (bitvector 6))
                  (zero-extend (bit 1 out-0) (bitvector 6))
                  (zero-extend (bit 2 out-0) (bitvector 6))
                  (zero-extend (bit 3 out-0) (bitvector 6))
                  (zero-extend (bit 4 out-0) (bitvector 6))
                  (zero-extend (bit 5 out-0) (bitvector 6))
                  (zero-extend (bit 6 out-0) (bitvector 6))
                  (zero-extend (bit 7 out-0) (bitvector 6))))

(define (helper f arity)
  (println f)
  (define soln
    (time
     (synthesize
      #:forall logical-inputs-0
      #:guarantee
      (begin
        ; Assume unused inputs are zero. We can set them to whatever we want, but it's important that
        ; we tell the solver that they're unused and unimportant, and setting them to a constant value
        ; is the way to this.
        ; When these aren't set, synthesis takes about 10-20x longer (20mins vs 1.5mins). In this case,
        ; we synthesize a LUT that is correct for inputs 0 and 1 regardless of the settings of the
        ; other inputs. I'm not sure if that's useful. I also wonder if there's a faster way to get
        ; the same result. E.g. either 1. assume 2-5 are all 0 and then manually edit the resulting LUT
        ; and duplicate the "correct" parts of the LUT memory into the rest of the LUT memory, OR, 2.,
        ; a more graceful solution, `assume` some predicates that basically say that 2-5 "don't matter"
        ; and that the outputs for a given 0 and 1 should be the same for any 2-5.
        (for ([logical-input (list-tail logical-inputs-0 arity)])
          (assume (bvzero? logical-input)))

        ; Assert that the output of the CLB implements the requested function f.
        (assert (bveq (apply f (take logical-inputs-0 arity)) out-1))))))

  ; Print the output. Unwrap the model if there is one, so that all of the values print.
  (if (sat? soln) (pretty-print (model soln)) (println soln))
  (displayln ""))

; CIRCT Comb dialect.
(helper circt-comb-add 2)
(helper circt-comb-and 2)
(helper circt-comb-divs 2)
(helper circt-comb-divu 2)
(helper (lambda (a b) (zero-extend (circt-comb-icmp a b) (bitvector 8))) 2)
(helper circt-comb-mods 2)
(helper circt-comb-mul 2)
(helper circt-comb-mux 3)
(helper circt-comb-or 2)
(helper (lambda (a) (zero-extend (circt-comb-parity a) (bitvector 8))) 1)
(helper circt-comb-shl 2)
(helper circt-comb-shrs 2)
(helper circt-comb-shru 2)
(helper circt-comb-sub 2)
(helper circt-comb-xor 2)

; Bithack examples.
(helper floor-avg 2)
(helper bithack3 2)
(helper bithack2 2)
(helper bithack1 2)
(helper ceil-avg 2)
(helper bvadd 2)
(helper cycle 4)