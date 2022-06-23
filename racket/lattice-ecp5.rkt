#lang errortrace racket

(require rosette)

(provide interpret-lattice-ecp5
         interpret-lattice-ecp5-pfu
         lattice-ecp5-logical-to-physical-inputs)

; The output of a LUT is simply the bit at the entry pointed to by `inputs`,
; when interpreted as an integer.
;
; LUTs must return only one bit.
;
; TODO: figure out how to return multiple bits while still using theory of
;       bitvectors only. The old solution used theory of integers to index into
;       the bitvector.
;
; TODO: It's probably worth putting this somewhere more generally usable.
(define (lut memory inputs)
  (let* ([len    (length (bitvector->bits memory))]
         [inputs (zero-extend inputs (bitvector len))])
    (bit 0 (bvlshr memory inputs))))

(module+ test
  (require rackunit)
  (check-equal? (lut (bv #b0110 4) (bv 0 1)) (bv #b0 1))
  (check-equal? (lut (bv #b0110 4) (bv 1 1)) (bv #b1 1))
  (check-equal? (lut (bv #b0110 4) (bv 2 2)) (bv #b1 1))
  (check-equal? (lut (bv #b0110 4) (bv 3 2)) (bv #b0 1)))

(define (interpret-lattice-ecp5 interpreter expr)
  '())

(define (interpret-lattice-ecp5-pfu interpreter expr)
  (match expr
    [`(lattice-ecp5-pfu ,lut-a
                        ,lut-b
                        ,lut-c
                        ,lut-d
                        ,lut-e
                        ,lut-f
                        ,lut-g
                        ,lut-h
                        ,inputs)
     (let* ([inputs     (interpreter  inputs)]
            [pfu        (list lut-a lut-b lut-c lut-d lut-e lut-f lut-g lut-h)])
       (interpret-ecp5-pfu-impl pfu inputs))]))

; Returns the physical outputs of the PFU
(define (interpret-ecp5-pfu-impl pfu
                                 lut-inputs)
  ; TODO: This can be a let*?
  ; TODO: can we get rid of the pfu struct and use luts directly? or make the
  ; pfu a list instead of a struct? We are just packing/unpacking the struct
  ; which is verbose
  (let ([bits (for/list ([l pfu]
                         [i lut-inputs])
                (interpret-lut4-impl l i))])
    (apply concat (reverse bits))))

(module+ test
  (require rackunit)
  (let* ([a (bv #x0003 16)]
         [b (bv #x000c 16)]
         [c (bv #x0030 16)]
         [d (bv #x00c0 16)]
         [e (bv #x0300 16)]
         [f (bv #x0c00 16)]
         [g (bv #x3000 16)]
         [h (bv #xc000 16)]
         [pfu (list a b c d e f g h)]
         [inputs-0s (make-list 8 (bv #x0 4))]
         [inputs-1s (make-list 8 (bv #x1 4))]
         [inputs-2s (make-list 8 (bv #x2 4))]
         [inputs-3s (make-list 8 (bv #x3 4))]
         [inputs-4s (make-list 8 (bv #x4 4))]
         [inputs-5s (make-list 8 (bv #x5 4))]
         [inputs-6s (make-list 8 (bv #x6 4))]
         [inputs-7s (make-list 8 (bv #x7 4))]
         [inputs-8s (make-list 8 (bv #x8 4))]
         [inputs-9s (make-list 8 (bv #x9 4))]
         [inputs-as (make-list 8 (bv #xa 4))]
         [inputs-bs (make-list 8 (bv #xb 4))]
         [inputs-cs (make-list 8 (bv #xc 4))]
         [inputs-ds (make-list 8 (bv #xd 4))]
         [inputs-es (make-list 8 (bv #xe 4))]
         [inputs-fs (make-list 8 (bv #xf 4))])
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-0s) (bv #b00000001 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-1s) (bv #b00000001 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-2s) (bv #b00000010 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-3s) (bv #b00000010 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-4s) (bv #b00000100 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-5s) (bv #b00000100 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-6s) (bv #b00001000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-7s) (bv #b00001000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-8s) (bv #b00010000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-9s) (bv #b00010000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-as) (bv #b00100000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-bs) (bv #b00100000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-cs) (bv #b01000000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-ds) (bv #b01000000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-es) (bv #b10000000 8))
    (check-equal? (interpret-ecp5-pfu-impl pfu inputs-fs) (bv #b10000000 8))))

(define (interpret-lut4-impl l inputs)
    (lut l (extract 3 0 inputs)))

(module+ test
  (require rackunit)
  (let* ([l (bv #b0110 16)])
    (check-equal? (interpret-lut4-impl l (bv 0 4)) (bv 0 1))
    (check-equal? (interpret-lut4-impl l (bv 1 4)) (bv 1 1))
    (check-equal? (interpret-lut4-impl l (bv 2 4)) (bv 1 1))
    (check-equal? (interpret-lut4-impl l (bv 3 4)) (bv 0 1))))


; Implements the basic arity-4 routing template for bv8 inputs.
;
; + We choose arity-4 because we are working with LUT4s
; + We default to bv8s because there are 8 LUT4s
; + Thus there are 4*8 = 32 input wires.
;
; Logical Inputs:
;
;   Each 'logical input' represents an input of a high-level operation that we
;   are trying to translate to a low-level LUT operation. For instance, if we
;   are trying to synthesize arity-2 addition for bv8s, the logical inputs
;   would be two bv8s.
;
; Physical Inputs:
;
;   Each 'physical input' represents an input pin on a LUT4.
; 
;
; Diagramatically, this routing template looks like:
;
;       in3-0 --> A +-------+     # LSB of input 3 goes to pin 0 of LUT A
;       in2-0 --> B | LUT A |
;       in1-0 --> C |       |
;       in0-0 --> D +-------+
;
;       in3-1 --> A +-------+
;       in2-1 --> B | LUT B |
;       in1-1 --> C |       |
;       in0-1 --> D +-------+
;
;       in3-2 --> A +-------+
;       in2-2 --> B | LUT C |
;       in1-2 --> C |       |
;       in0-2 --> D +-------+
;
;       in3-3 --> A +-------+
;       in2-3 --> B | LUT D |
;       in1-3 --> C |       |
;       in0-3 --> D +-------+
;
;       in3-4 --> A +-------+
;       in2-4 --> B | LUT E |
;       in1-4 --> C |       |
;       in0-4 --> D +-------+
;
;       in3-5 --> A +-------+
;       in2-5 --> B | LUT F |
;       in1-5 --> C |       |
;       in0-5 --> D +-------+
;
;       in3-6 --> A +-------+
;       in2-6 --> B | LUT G |
;       in1-6 --> C |       |
;       in0-6 --> D +-------+
;
;       in3-7 --> A +-------+
;       in2-7 --> B | LUT H |
;       in1-7 --> C |       |
;       in0-7 --> D +-------+
(define (lattice-ecp5-logical-to-physical-inputs logical-input-0
                                                 logical-input-1
                                                 logical-input-2
                                                 logical-input-3)
  (let ([helper (lambda (idx)
                  (concat (extract idx idx logical-input-3)
                          (extract idx idx logical-input-2)
                          (extract idx idx logical-input-1)
                          (extract idx idx logical-input-0)))])
    (list (helper 0) (helper 1) (helper 2) (helper 3) (helper 4) (helper 5) (helper 6) (helper 7))))

(module+ test
  (require rackunit)
  (let* ([li0 (bv #b00000000 8)]
         [li1 (bv #b11110000 8)]
         [li2 (bv #b11001100 8)]
         [li3 (bv #b10101010 8)]
         [out (lattice-ecp5-logical-to-physical-inputs li0 li1 li2 li3)])
         
    (check-equal? (list-ref out 7) (bv #b1110 4))
    (check-equal? (list-ref out 6) (bv #b0110 4))
    (check-equal? (list-ref out 5) (bv #b1010 4))
    (check-equal? (list-ref out 4) (bv #b0010 4))
    (check-equal? (list-ref out 3) (bv #b1100 4))
    (check-equal? (list-ref out 2) (bv #b0100 4))
    (check-equal? (list-ref out 1) (bv #b1000 4))
    (check-equal? (list-ref out 0) (bv #b0000 4))
    ))