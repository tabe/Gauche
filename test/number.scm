;;
;; test numeric system implementation
;;

(use gauche.test)

(define (exp2 pow)
  (do ((i 0 (+ i 1))
       (m 1 (+ m m)))
      ((>= i pow) m)))

(define (fermat n)                      ;Fermat's number
  (+ (expt 2 (expt 2 n)) 1))

(test-start "numbers")

;;==================================================================
;; Reader/writer
;;

;;------------------------------------------------------------------
(test-section "integer addition & reader")

(define (i-tester x)
  (list x (+ x -1 x) (+ x x) (- x) (- (+ x -1 x)) (- 0 x x) (- 0 x x 1)))

(test "around 2^28"
      '(268435456 536870911 536870912
        -268435456 -536870911 -536870912 -536870913)
      (lambda () (i-tester (exp2 28))))
      
(test "around 2^31"
      '(2147483648 4294967295 4294967296
        -2147483648 -4294967295 -4294967296 -4294967297)
      (lambda () (i-tester (exp2 31))))

(test "around 2^60"
      '(1152921504606846976 2305843009213693951 2305843009213693952
        -1152921504606846976 -2305843009213693951 -2305843009213693952
        -2305843009213693953)
      (lambda () (i-tester (exp2 60))))

(test "around 2^63"
      '(9223372036854775808 18446744073709551615 18446744073709551616
        -9223372036854775808 -18446744073709551615 -18446744073709551616
        -18446744073709551617)
      (lambda () (i-tester (exp2 63))))

(test "around 2^127"
      '(170141183460469231731687303715884105728
        340282366920938463463374607431768211455
        340282366920938463463374607431768211456
        -170141183460469231731687303715884105728
        -340282366920938463463374607431768211455
        -340282366920938463463374607431768211456
        -340282366920938463463374607431768211457)
      (lambda () (i-tester (exp2 127))))

;; test for reader's overflow detection code
(test "peculiarity around 2^32"
      (* 477226729 10) (lambda () 4772267290))

(test "radix" '(43605 342391 718048024785
                123456789 123456789987654321
                1193046 3735928559 3735928559)
      (lambda ()
        (list #b1010101001010101
              #o1234567
              #o12345677654321
              #d123456789
              #d123456789987654321
              #x123456
              #xdeadbeef
              #xDeadBeef)))

(test "exactness" #t (lambda () (exact? #e10)))
(test "exactness" #t (lambda () (exact? #e10.0)))
(test "exactness" #t (lambda () (exact? #e10e10)))
(test "exactness" #f (lambda () (string->number "#e12.34")))
(test "inexactness" #f (lambda () (exact? #i10)))
(test "inexactness" #f (lambda () (exact? #i10.0)))
(test "inexactness" #f (lambda () (exact? #i12.34)))

(test "exactness & radix" '(#t 3735928559 #t 3735928559)
      (lambda () (list (exact? #e#xdeadbeef)
                       #e#xdeadbeef
                       (exact? #x#edeadbeef)
                       #x#edeadbeef)))
(test "inexactness & radix" '(#f 3735928559.0 #f 3735928559.0)
      (lambda () (list (exact? #i#xdeadbeef)
                       #i#xdeadbeef
                       (exact? #x#ideadbeef)
                       #x#ideadbeef)))

(test "invalid exactness/radix spec" #f
      (lambda () (or (string->number "#e")
                     (string->number "#i")
                     (string->number "#e#i3")
                     (string->number "#i#e5")
                     (string->number "#x#o13")
                     (string->number "#e#b#i00101"))))

(define (radix-tester radix)
  (list (let loop ((digits 0)
                   (input "1")
                   (value 1))
          (cond ((> digits 64) #t)
                ((eqv? (string->number input radix) value)
                 (loop (+ digits 1) (string-append input "0") (* value radix)))
                (else #f)))
        (let loop ((digits 0)
                   (input (string (integer->digit (- radix 1) radix)))
                   (value (- radix 1)))
          (cond ((> digits 64) #t)
                ((eqv? (string->number input radix) value)
                 (loop (+ digits 1)
                       (string-append input (string (integer->digit (- radix 1) radix)))
                       (+ (* value radix) (- radix 1))))
                (else #f)))))

(test "base-2 reader" '(#t #t) (lambda () (radix-tester 2)))
(test "base-3 reader" '(#t #t) (lambda () (radix-tester 3)))
(test "base-4 reader" '(#t #t) (lambda () (radix-tester 4)))
(test "base-5 reader" '(#t #t) (lambda () (radix-tester 5)))
(test "base-6 reader" '(#t #t) (lambda () (radix-tester 6)))
(test "base-7 reader" '(#t #t) (lambda () (radix-tester 7)))
(test "base-8 reader" '(#t #t) (lambda () (radix-tester 8)))
(test "base-9 reader" '(#t #t) (lambda () (radix-tester 9)))
(test "base-10 reader" '(#t #t) (lambda () (radix-tester 10)))
(test "base-11 reader" '(#t #t) (lambda () (radix-tester 11)))
(test "base-12 reader" '(#t #t) (lambda () (radix-tester 12)))
(test "base-13 reader" '(#t #t) (lambda () (radix-tester 13)))
(test "base-14 reader" '(#t #t) (lambda () (radix-tester 14)))
(test "base-15 reader" '(#t #t) (lambda () (radix-tester 15)))
(test "base-16 reader" '(#t #t) (lambda () (radix-tester 16)))
(test "base-17 reader" '(#t #t) (lambda () (radix-tester 17)))
(test "base-18 reader" '(#t #t) (lambda () (radix-tester 18)))
(test "base-19 reader" '(#t #t) (lambda () (radix-tester 19)))
(test "base-20 reader" '(#t #t) (lambda () (radix-tester 20)))
(test "base-21 reader" '(#t #t) (lambda () (radix-tester 21)))
(test "base-22 reader" '(#t #t) (lambda () (radix-tester 22)))
(test "base-23 reader" '(#t #t) (lambda () (radix-tester 23)))
(test "base-24 reader" '(#t #t) (lambda () (radix-tester 24)))
(test "base-25 reader" '(#t #t) (lambda () (radix-tester 25)))
(test "base-26 reader" '(#t #t) (lambda () (radix-tester 26)))
(test "base-27 reader" '(#t #t) (lambda () (radix-tester 27)))
(test "base-28 reader" '(#t #t) (lambda () (radix-tester 28)))
(test "base-29 reader" '(#t #t) (lambda () (radix-tester 29)))
(test "base-30 reader" '(#t #t) (lambda () (radix-tester 30)))
(test "base-31 reader" '(#t #t) (lambda () (radix-tester 31)))
(test "base-32 reader" '(#t #t) (lambda () (radix-tester 32)))
(test "base-33 reader" '(#t #t) (lambda () (radix-tester 33)))
(test "base-34 reader" '(#t #t) (lambda () (radix-tester 34)))
(test "base-35 reader" '(#t #t) (lambda () (radix-tester 35)))
(test "base-36 reader" '(#t #t) (lambda () (radix-tester 36)))

;;------------------------------------------------------------------
(test-section "rational reader")

(define (rational-test v)
  (if (number? v) (list v (exact? v)) v))

(test "rational reader" '(1234 #t) (lambda () (rational-test '1234/1)))
(test "rational reader" '(-1234 #t) (lambda () (rational-test '-1234/1)))
(test "rational reader" '(1234 #t) (lambda () (rational-test '+1234/1)))
(test "rational reader" '|1234/-1| (lambda () (rational-test '1234/-1)))
(test "rational reader" '(1234 #t) (lambda () (rational-test '2468/2)))
(test "rational reader" '(0.5 #f) (lambda () (rational-test '1/2)))
(test "rational reader" '(-0.5 #f) (lambda () (rational-test '-1/2)))
(test "rational reader" '(0.5 #f) (lambda () (rational-test '+1/2)))
(test "rational reader" '(0.5 #f) (lambda () (rational-test '751/1502)))

(test "rational reader" '(1 #t)
      (lambda () (rational-test (string->number "3/03"))))
(test "rational reader" #f
      (lambda () (rational-test (string->number "3/0"))))
(test "rational reader" #f
      (lambda () (rational-test (string->number "3/3/4"))))
(test "rational reader" #f
      (lambda () (rational-test (string->number "1/2."))))
(test "rational reader" #f
      (lambda () (rational-test (string->number "1.3/2"))))

(test "rational reader w/#e" '(1234 #t)
      (lambda () (rational-test '#e1234/1)))
(test "rational reader w/#e" '(-1234 #t)
      (lambda () (rational-test '#e-1234/1)))
(test "rational reader w/#e" #f
      (lambda () (string->number "#e32/7")))
(test "rational reader w/#e" #f
      (lambda () (string->number "#e-32/7")))
(test "rational reader w/#i" '(1234.0 #f)
      (lambda () (rational-test '#i1234/1)))
(test "rational reader w/#i" '(-1234.0 #f)
      (lambda () (rational-test '#i-1234/1)))
(test "rational reader w/#i" '(-0.125 #f)
      (lambda () (rational-test '#i-4/32)))

(test "rational reader w/radix" '(15 #t)
      (lambda () (rational-test '#e#xff/11)))
(test "rational reader w/radix" '(56 #t)
      (lambda () (rational-test '#o770/11)))
(test "rational reader w/radix" '(15.0 #f)
      (lambda () (rational-test '#x#iff/11)))


;;------------------------------------------------------------------
(test-section "flonum reader")

(define (flonum-test v)
  (if (number? v) (list v (inexact? v)) v))

(test "flonum reader" '(3.14 #t)  (lambda () (flonum-test 3.14)))
(test "flonum reader" '(0.14 #t)  (lambda () (flonum-test 0.14)))
(test "flonum reader" '(0.14 #t)  (lambda () (flonum-test .14)))
(test "flonum reader" '(3.0  #t)  (lambda () (flonum-test 3.)))
(test "flonum reader" '(-3.14 #t)  (lambda () (flonum-test -3.14)))
(test "flonum reader" '(-0.14 #t)  (lambda () (flonum-test -0.14)))
(test "flonum reader" '(-0.14 #t)  (lambda () (flonum-test -.14)))
(test "flonum reader" '(-3.0  #t)  (lambda () (flonum-test -3.)))
(test "flonum reader" '(3.14 #t)  (lambda () (flonum-test +3.14)))
(test "flonum reader" '(0.14 #t)  (lambda () (flonum-test +0.14)))
(test "flonum reader" '(0.14 #t)  (lambda () (flonum-test +.14)))
(test "flonum reader" '(3.0  #t)  (lambda () (flonum-test +3.)))
(test "flonum reader" '(0.0  #t)  (lambda () (flonum-test .0)))
(test "flonum reader" '(0.0  #t)  (lambda () (flonum-test 0.)))
(test "flonum reader" #f (lambda () (string->number ".")))
(test "flonum reader" #f (lambda () (string->number "-.")))
(test "flonum reader" #f (lambda () (string->number "+.")))

(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test 3.14e2)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314e3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test 314e0)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test 314e-0)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test 3140000e-4)))
(test "flonum reader (exp)" '(-314.0 #t) (lambda () (flonum-test -3.14e2)))
(test "flonum reader (exp)" '(-314.0 #t) (lambda () (flonum-test -.314e3)))
(test "flonum reader (exp)" '(-314.0 #t) (lambda () (flonum-test -314e0)))
(test "flonum reader (exp)" '(-314.0 #t) (lambda () (flonum-test -314.e-0)))
(test "flonum reader (exp)" '(-314.0 #t) (lambda () (flonum-test -3140000e-4)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test +3.14e2)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test +.314e3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test +314.e0)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test +314e-0)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test +3140000.000e-4)))

(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314E3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314s3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314S3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314l3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314L3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314f3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314F3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314d3)))
(test "flonum reader (exp)" '(314.0 #t) (lambda () (flonum-test .314D3)))

;;------------------------------------------------------------------
(test-section "complex reader")

(define (decompose-complex z)
  (cond ((real? z) z)
        ((complex? z)
         (list (real-part z) (imag-part z)))
        (else z)))

(test "complex reader" '(1.0 1.0) (lambda () (decompose-complex '1+i)))
(test "complex reader" '(1.0 1.0) (lambda () (decompose-complex '1+1i)))
(test "complex reader" '(1.0 -1.0) (lambda () (decompose-complex '1-i)))
(test "complex reader" '(1.0 -1.0) (lambda () (decompose-complex '1-1i)))
(test "complex reader" '(1.0 1.0) (lambda () (decompose-complex '1.0+1i)))
(test "complex reader" '(1.0 1.0) (lambda () (decompose-complex '1.0+1.0i)))
(test "complex reader" '(1e-5 1.0) (lambda () (decompose-complex '1e-5+1i)))
(test "complex reader" '(1e+5 1.0) (lambda () (decompose-complex '1e+5+1i)))
(test "complex reader" '(1.0 1e-5) (lambda () (decompose-complex '1+1e-5i)))
(test "complex reader" '(1.0 1e+5) (lambda () (decompose-complex '1+1e+5i)))
(test "complex reader" '(0.1 1e+4) (lambda () (decompose-complex '0.1+0.1e+5i)))
(test "complex reader" '(0.0 1.0) (lambda () (decompose-complex '+i)))
(test "complex reader" '(0.0 -1.0) (lambda () (decompose-complex '-i)))
(test "complex reader" '(0.0 1.0) (lambda () (decompose-complex '+1i)))
(test "complex reader" '(0.0 -1.0) (lambda () (decompose-complex '-1i)))
(test "complex reader" '(0.0 1.0) (lambda () (decompose-complex '+1.i)))
(test "complex reader" '(0.0 -1.0) (lambda () (decompose-complex '-1.i)))
(test "complex reader" '(0.0 1.0) (lambda () (decompose-complex '+1.0i)))
(test "complex reader" '(0.0 -1.0) (lambda () (decompose-complex '-1.0i)))
(test "complex reader" 1.0 (lambda () (decompose-complex '1+0.0i)))
(test "complex reader" 1.0 (lambda () (decompose-complex '1+.0i)))
(test "complex reader" 1.0 (lambda () (decompose-complex '1+0.i)))
(test "complex reader" 1.0 (lambda () (decompose-complex '1+0.0e-43i)))
(test "complex reader" 100.0 (lambda () (decompose-complex '1e2+0.0e-43i)))

(test "complex reader" 'i (lambda () (decompose-complex 'i)))
(test "complex reader" #f
      (lambda () (decompose-complex (string->number ".i"))))
(test "complex reader" #f
      (lambda () (decompose-complex (string->number "+.i"))))
(test "complex reader" #f
      (lambda () (decompose-complex (string->number "-.i"))))
(test "complex reader" '33i (lambda () (decompose-complex '33i)))
(test "complex reader" 'i+1 (lambda () (decompose-complex 'i+1)))

(test "complex reader" '(0.5 0.5)
      (lambda () (decompose-complex 1/2+1/2i)))
(test "complex reader" '(0.0 0.5)
      (lambda () (decompose-complex 0+1/2i)))
(test "complex reader" '(0.0 -0.5)
      (lambda () (decompose-complex -1/2i)))
(test "complex reader" 0.5
      (lambda () (decompose-complex 1/2-0/2i)))
(test "complex reader" #f
      (lambda () (decompose-complex (string->number "1/2-1/0i"))))

(test "complex reader (polar)" (make-polar 1.0 1.0)
      (lambda () 1.0@1.0))
(test "complex reader (polar)" (make-polar 1.0 -1.0)
      (lambda () 1.0@-1.0))
(test "complex reader (polar)" (make-polar 1.0 1.0)
      (lambda () 1.0@+1.0))
(test "complex reader (polar)" (make-polar -7.0 -3.0)
      (lambda () -7@-3.0))
(test "complex reader (polar)" (make-polar 3.5 -3.0)
      (lambda () 7/2@-3.0))
(test "complex reader (polar)" #f
      (lambda () (string->number "7/2@-3.14i")))


;;------------------------------------------------------------------
(test-section "integer writer syntax")

(define (i-tester2 x)
  (map number->string (i-tester x)))

(test "around 2^28"
      '("268435456" "536870911" "536870912"
        "-268435456" "-536870911" "-536870912" "-536870913")
      (lambda () (i-tester2 (exp2 28))))
      
(test "around 2^31"
      '("2147483648" "4294967295" "4294967296"
        "-2147483648" "-4294967295" "-4294967296" "-4294967297")
      (lambda () (i-tester2 (exp2 31))))

(test "around 2^60"
      '("1152921504606846976" "2305843009213693951" "2305843009213693952"
        "-1152921504606846976" "-2305843009213693951" "-2305843009213693952"
        "-2305843009213693953")
      (lambda () (i-tester2 (exp2 60))))

(test "around 2^63"
      '("9223372036854775808" "18446744073709551615" "18446744073709551616"
        "-9223372036854775808" "-18446744073709551615" "-18446744073709551616"
        "-18446744073709551617")
      (lambda () (i-tester2 (exp2 63))))

(test "around 2^127"
      '("170141183460469231731687303715884105728"
        "340282366920938463463374607431768211455"
        "340282366920938463463374607431768211456"
        "-170141183460469231731687303715884105728"
        "-340282366920938463463374607431768211455"
        "-340282366920938463463374607431768211456"
        "-340282366920938463463374607431768211457")
      (lambda () (i-tester2 (exp2 127))))


;;==================================================================
;; Predicates
;;

(test-section "predicates")

(test "integer?" #t (lambda () (integer? 0)))
(test "integer?" #t (lambda () (integer? 85736847562938475634534245)))
(test "integer?" #f (lambda () (integer? 85736.534245)))
(test "integer?" #f (lambda () (integer? 3.14)))
(test "integer?" #f (lambda () (integer? 3+4i)))
(test "integer?" #t (lambda () (integer? 3+0i)))
(test "integer?" #f (lambda () (integer? #f)))

(test "rational?" #t (lambda () (rational? 0)))
(test "rational?" #t (lambda () (rational? 85736847562938475634534245)))
(test "rational?" #t (lambda () (rational? 85736.534245)))
(test "rational?" #t (lambda () (rational? 3.14)))
(test "rational?" #f (lambda () (rational? 3+4i)))
(test "rational?" #t (lambda () (rational? 3+0i)))
(test "rational?" #f (lambda () (rational? #f)))

(test "real?" #t (lambda () (real? 0)))
(test "real?" #t (lambda () (real? 85736847562938475634534245)))
(test "real?" #t (lambda () (real? 857368.4756293847)))
(test "real?" #t (lambda () (real? 3+0i)))
(test "real?" #f (lambda () (real? 3+4i)))
(test "real?" #f (lambda () (real? +4.3i)))
(test "real?" #f (lambda () (real? '())))

(test "complex?" #t (lambda () (complex? 0)))
(test "complex?" #t (lambda () (complex? 85736847562938475634534245)))
(test "complex?" #t (lambda () (complex? 857368.4756293847)))
(test "complex?" #t (lambda () (complex? 3+0i)))
(test "complex?" #t (lambda () (complex? 3+4i)))
(test "complex?" #t (lambda () (complex? +4.3i)))
(test "complex?" #f (lambda () (complex? '())))

(test "number?" #t (lambda () (number? 0)))
(test "number?" #t (lambda () (number? 85736847562938475634534245)))
(test "number?" #t (lambda () (number? 857368.4756293847)))
(test "number?" #t (lambda () (number? 3+0i)))
(test "number?" #t (lambda () (number? 3+4i)))
(test "number?" #t (lambda () (number? +4.3i)))
(test "number?" #f (lambda () (number? '())))

(test "exact?" #t (lambda () (exact? 1)))
(test "exact?" #t (lambda () (exact? 4304953480349304983049304953804)))
(test "exact?" #f (lambda () (exact? 1.0)))
(test "exact?" #f (lambda () (exact? 4304953480349304983.049304953804)))
(test "exact?" #f (lambda () (exact? 1.0+0i)))
(test "exact?" #f (lambda () (exact? 1.0+5i)))
(test "inexact?" #f (lambda () (inexact? 1)))
(test "inexact?" #f (lambda () (inexact? 4304953480349304983049304953804)))
(test "inexact?" #t (lambda () (inexact? 1.0)))
(test "inexact?" #t (lambda () (inexact? 4304953480349304983.049304953804)))
(test "inexact?" #t (lambda () (inexact? 1.0+0i)))
(test "inexact?" #t (lambda () (inexact? 1.0+5i)))

(test "odd?" #t (lambda () (odd? 1)))
(test "odd?" #f (lambda () (odd? 2)))
(test "even?" #f (lambda () (even? 1)))
(test "even?" #t (lambda () (even? 2)))
(test "odd?" #t (lambda () (odd? 1.0)))
(test "odd?" #f (lambda () (odd? 2.0)))
(test "even?" #f (lambda () (even? 1.0)))
(test "even?" #t (lambda () (even? 2.0)))
(test "odd?" #t (lambda () (odd? 10000000000000000000000000000000000001)))
(test "odd?" #f (lambda () (odd? 10000000000000000000000000000000000002)))
(test "even?" #f (lambda () (even? 10000000000000000000000000000000000001)))
(test "even?" #t (lambda () (even? 10000000000000000000000000000000000002)))

(test "zero?" #t (lambda () (zero? 0)))
(test "zero?" #t (lambda () (zero? 0.0)))
(test "zero?" #t (lambda () (zero? (- 10 10.0))))
(test "zero?" #t (lambda () (zero? 0+0i)))
(test "zero?" #f (lambda () (zero? 1.0)))
(test "zero?" #f (lambda () (zero? +5i)))
(test "positive?" #t (lambda () (positive? 1)))
(test "positive?" #f (lambda () (positive? -1)))
(test "positive?" #t (lambda () (positive? 3.1416)))
(test "positive?" #f (lambda () (positive? -3.1416)))
(test "positive?" #t (lambda () (positive? 134539485343498539458394)))
(test "positive?" #f (lambda () (positive? -134539485343498539458394)))
(test "negative?" #f (lambda () (negative? 1)))
(test "negative?" #t (lambda () (negative? -1)))
(test "negative?" #f (lambda () (negative? 3.1416)))
(test "negative?" #t (lambda () (negative? -3.1416)))
(test "negative?" #f (lambda () (negative? 134539485343498539458394)))
(test "negative?" #t (lambda () (negative? -134539485343498539458394)))

(test "eqv?" #t (lambda () (eqv? 20 20)))
(test "eqv?" #t (lambda () (eqv? 20.0 20.00000)))
(test "eqv?" #t (lambda () (eqv? 20 (inexact->exact 20.0))))
(test "eqv?" #f (lambda () (eqv? 20 20.0)))

;;==================================================================
;; Arithmetics
;;

;;------------------------------------------------------------------
(test-section "integer addition")

(define x #xffffffff00000000ffffffff00000000)
(define xx (- x))
(define y #x00000002000000000000000200000000)
(define yy (- y))
(define z #x00000000000000010000000000000001)
(test "bignum + bignum" #x100000001000000010000000100000000
      (lambda () (+ x y)))
(test "bignum + -bignum" #xfffffffd00000000fffffffd00000000
      (lambda () (+ x yy)))
(test "bignum - bignum" #xfffffffefffffffffffffffeffffffff
      (lambda () (- x z)))
(test "bignum - bignum" x
      (lambda () (- (+ x y) y)))
(test "-bignum + bignum" #x-fffffffd00000000fffffffd00000000
      (lambda () (+ xx y)))
(test "-bignum + -bignum" #x-100000001000000010000000100000000
      (lambda () (+ xx yy)))
(test "-bignum - bignum" #x-100000001000000010000000100000000
      (lambda () (- xx y)))
(test "-bignum - -bignum" #x-fffffffd00000000fffffffd00000000
      (lambda () (- xx yy)))

;;------------------------------------------------------------------
(test-section "small immediate integer constants")

;; pushing small literal integer on the stack may be done
;; by combined instruction PUSHI.  These tests if it works.

(define (foo a b c d e) (list a b c d e))

;; 2^19-1
(test "PUSHI" '(0 524287 524288 -524287 -524288)
      (lambda ()
        (foo 0 524287 524288 -524287 -524288)))
;; 2^51-1
(test "PUSHI" '(0 2251799813685247 2251799813685248
                  -2251799813685247 -2251799813685248 )
      (lambda ()
        (foo 0 2251799813685247 2251799813685248
             -2251799813685247 -2251799813685248)))

;;------------------------------------------------------------------
(test-section "small immediate integer additions")

;; small literal integer x (-2^19 <= x < 2^19 on 32bit architecture)
;; in binary addition/subtraction is compiled in special instructuions,
;; NUMADDI and NUMSUBI.

(define x 2)
(test "NUMADDI" 5 (lambda () (+ 3 x)))
(test "NUMADDI" 5 (lambda () (+ x 3)))
(test "NUMADDI" 1 (lambda () (+ -1 x)))
(test "NUMADDI" 1 (lambda () (+ x -1)))
(test "NUMSUBI" 1 (lambda () (- 3 x)))
(test "NUMSUBI" -1 (lambda () (- x 3)))
(test "NUMSUBI" -5 (lambda () (- -3 x)))
(test "NUMSUBI" 5 (lambda () (- x -3)))
(define x 2.0)
(test "NUMADDI" 5.0 (lambda () (+ 3 x)))
(test "NUMADDI" 5.0 (lambda () (+ x 3)))
(test "NUMADDI" 1.0 (lambda () (+ -1 x)))
(test "NUMADDI" 1.0 (lambda () (+ x -1)))
(test "NUMSUBI" 1.0 (lambda () (- 3 x)))
(test "NUMSUBI" -1.0 (lambda () (- x 3)))
(test "NUMSUBI" -5.0 (lambda () (- -3 x)))
(test "NUMSUBI" 5.0 (lambda () (- x -3)))
(define x #x100000000)
(test "NUMADDI" #x100000003 (lambda () (+ 3 x)))
(test "NUMADDI" #x100000003 (lambda () (+ x 3)))
(test "NUMADDI" #xffffffff (lambda () (+ -1 x)))
(test "NUMADDI" #xffffffff (lambda () (+ x -1)))
(test "NUMSUBI" #x-fffffffd (lambda () (- 3 x)))
(test "NUMSUBI" #xfffffffd (lambda () (- x 3)))
(test "NUMSUBI" #x-100000003 (lambda () (- -3 x)))
(test "NUMSUBI" #x100000003 (lambda () (- x -3)))

(test "NUMADDI" 30 (lambda () (+ 10 (if #t 20 25))))
(test "NUMADDI" 30 (lambda () (+ (if #t 20 25) 10)))
(test "NUMADDI" 35 (lambda () (+ 10 (if #f 20 25))))
(test "NUMADDI" 35 (lambda () (+ (if #f 20 25) 10)))
(test "NUMADDI" 30 (lambda () (let ((x #t)) (+ 10 (if x 20 25)))))
(test "NUMADDI" 30 (lambda () (let ((x #t)) (+ (if x 20 25) 10))))
(test "NUMADDI" 35 (lambda () (let ((x #f)) (+ 10 (if x 20 25)))))
(test "NUMADDI" 35 (lambda () (let ((x #f)) (+ (if x 20 25) 10))))
(test "NUMADDI" 21 (lambda () (+ 10 (do ((x 0 (+ x 1))) ((> x 10) x)))))
(test "NUMADDI" 21 (lambda () (+ (do ((x 0 (+ x 1))) ((> x 10) x)) 10)))
(test "NUMSUBI" -10 (lambda () (- 10 (if #t 20 25))))
(test "NUMSUBI" 10 (lambda () (- (if #t 20 25) 10)))
(test "NUMSUBI" -15 (lambda () (- 10 (if #f 20 25))))
(test "NUMSUBI" 15 (lambda () (- (if #f 20 25) 10)))
(test "NUMSUBI" -10 (lambda () (let ((x #t)) (- 10 (if x 20 25)))))
(test "NUMSUBI" 10 (lambda () (let ((x #t)) (- (if x 20 25) 10))))
(test "NUMSUBI" -15 (lambda () (let ((x #f)) (- 10 (if x 20 25)))))
(test "NUMSUBI" 15 (lambda () (let ((x #f)) (- (if x 20 25) 10))))
(test "NUMSUBI" -1 (lambda () (- 10 (do ((x 0 (+ x 1))) ((> x 10) x)))))
(test "NUMSUBI" 1 (lambda () (- (do ((x 0 (+ x 1))) ((> x 10) x)) 10)))

;;------------------------------------------------------------------
(test-section "promotions in addition")

(define (+-tester x) (list x (exact? x)))

(test "+" '(0 #t) (lambda () (+-tester (+))))
(test "+" '(1 #t) (lambda () (+-tester (+ 1))))
(test "+" '(3 #t) (lambda () (+-tester (+ 1 2))))
(test "+" '(6 #t) (lambda () (+-tester (+ 1 2 3))))
(test "+" '(1.0 #f) (lambda () (+-tester (+ 1.0))))
(test "+" '(3.0 #f) (lambda () (+-tester (+ 1.0 2))))
(test "+" '(3.0 #f) (lambda () (+-tester (+ 1 2.0))))
(test "+" '(6.0 #f) (lambda () (+-tester (+ 1 2 3.0))))
(test "+" '(1+i #f) (lambda () (+-tester (+ 1 +i))))
(test "+" '(3+i #f) (lambda () (+-tester (+ 1 2 +i))))
(test "+" '(3+i #f) (lambda () (+-tester (+ +i 1 2))))
(test "+" '(3+i #f) (lambda () (+-tester (+ 1.0 2 +i))))
(test "+" '(3+i #f) (lambda () (+-tester (+ +i 1.0 2))))
(test "+" '(4294967298.0 #f) (lambda () (+-tester (+ 4294967297 1.0))))
(test "+" '(4294967299.0 #f) (lambda () (+-tester (+ 4294967297 1 1.0))))
(test "+" '(4294967298.0-i #f) (lambda () (+-tester (+ 4294967297 1.0 -i))))
(test "+" '(4294967298.0-i #f) (lambda () (+-tester (+ -i 4294967297 1.0))))
(test "+" '(4294967298.0-i #f) (lambda () (+-tester (+ 1.0 4294967297 -i))))

;;------------------------------------------------------------------
(test-section "integer multiplication")

(define (m-result x) (list x (- x) (- x) x))
(define (m-tester x y)
  (list (* x y) (* (- x) y) (* x (- y)) (* (- x) (- y))))

(test "fix*fix->big[1]" (m-result 727836879)
      (lambda () (m-tester 41943 17353)))
(test "fix*fix->big[1]" (m-result 3663846879)
      (lambda () (m-tester 41943 87353)))
(test "fix*fix->big[2]" (m-result 4294967296)
      (lambda () (m-tester 65536 65536)))
(test "fix*fix->big[2]" (m-result 366384949959)
      (lambda () (m-tester 4194303 87353)))
(test "fix*big[1]->big[1]" (m-result 3378812463)
      (lambda () (m-tester 3 1126270821)))
(test "fix*big[1]->big[2]" (m-result 368276265762816)
      (lambda () (m-tester 85746 4294967296)))
(test "big[1]*fix->big[1]" (m-result 3378812463)
      (lambda () (m-tester 1126270821 3)))
(test "big[1]*fix->big[2]" (m-result 368276265762816)
      (lambda () (m-tester 4294967296 85746)))
(test "big[2]*fix->big[2]" (m-result 12312849128741)
      (lambda () (m-tester 535341266467 23)))
(test "big[1]*big[1]->big[2]" (m-result 1345585795375391817)
      (lambda () (m-tester 1194726677 1126270821)))

;; Large number multiplication test using Fermat's number
;; The decomposition of Fermat's number is taken from
;;   http://www.dd.iij4u.or.jp/~okuyamak/Information/Fermat.html
(test "fermat(7)" (fermat 7)
      (lambda () (* 59649589127497217 5704689200685129054721)))
(test "fermat(8)" (fermat 8)
      (lambda ()
        (* 1238926361552897
           93461639715357977769163558199606896584051237541638188580280321)))
(test "fermat(9)" (fermat 9)
      (lambda ()
        (* 2424833
           7455602825647884208337395736200454918783366342657
           741640062627530801524787141901937474059940781097519023905821316144415759504705008092818711693940737)))
(test "fermat(10)" (fermat 10)
      (lambda ()
        (* 45592577
           6487031809
           4659775785220018543264560743076778192897
           130439874405488189727484768796509903946608530841611892186895295776832416251471863574140227977573104895898783928842923844831149032913798729088601617946094119449010595906710130531906171018354491609619193912488538116080712299672322806217820753127014424577
           )))
(test "fermat(11)" (fermat 11)
      (lambda ()
        (* 319489
           974849
           167988556341760475137
           3560841906445833920513
           173462447179147555430258970864309778377421844723664084649347019061363579192879108857591038330408837177983810868451546421940712978306134189864280826014542758708589243873685563973118948869399158545506611147420216132557017260564139394366945793220968665108959685482705388072645828554151936401912464931182546092879815733057795573358504982279280090942872567591518912118622751714319229788100979251036035496917279912663527358783236647193154777091427745377038294584918917590325110939381322486044298573971650711059244462177542540706913047034664643603491382441723306598834177
           )))

;;------------------------------------------------------------------
(test-section "division")

(define (almost=? x y)
  (define (flonum=? x y)
    (let ((ax (abs x)) (ay (abs y)))
      (< (abs (- x y)) (* (max ax ay) 0.0000000000001))))
  (and (flonum=? (car x) (car y))
       (flonum=? (cadr x) (cadr y))
       (flonum=? (caddr x) (caddr y))
       (flonum=? (cadddr x) (cadddr y))
       (eq? (list-ref x 4) (list-ref y 4))))

(define (d-result x exact?) (list x (- x) (- x) x exact?))
(define (d-tester x y)
  (list (/ x y) (/ (- x) y) (/ x (- y)) (/ (- x) (- y))
        (exact? (/ x y))))

;; these uses BignumDivSI -> bignum_sdiv
(test "big[1]/fix->fix" (d-result 17353 #t) 
      (lambda () (d-tester 727836879 41943)))
(test "big[1]/fix->fix" (d-result 136582.040690235 #f)
      (lambda () (d-tester 3735928559 27353))
      almost=?)
(test "big[2]/fix->big[1]" (d-result 535341266467 #t)
      (lambda () (d-tester 12312849128741 23)))
(test "big[2]/fix->big[2]" (d-result 12312849128741 #t)
      (lambda () (d-tester 12312849128741 1)))

;; these uses BignumDivSI -> bignum_gdiv
(test "big[1]/fix->fix" (d-result 41943 #t)
      (lambda () (d-tester 3663846879 87353)))
(test "big[2]/fix->fix" (d-result 19088743.0196145 #f)
      (lambda () (d-tester 705986470884353 36984440))
      almost=?)
(test "big[2]/fix->fix" (d-result 92894912.9263878 #f)
      (lambda () (d-tester 12312849128741 132546))
      almost=?)
(test "big[2]/fix->big[1]" (d-result 2582762030.11968 #f)
      (lambda () (d-tester 425897458766735 164900))
      almost=?)

;; inexact division
(test "exact/inexact -> inexact" (d-result 3.25 #f)
      (lambda () (d-tester 13 4.0)))
(test "inexact/exact -> inexact" (d-result 3.25 #f)
      (lambda () (d-tester 13.0 4)))
(test "inexact/inexact -> inexact" (d-result 3.25 #f)
      (lambda () (d-tester 13.0 4.0)))

;;------------------------------------------------------------------
(test-section "quotient")

(define (q-result x exact?) (list x (- x) (- x) x exact?))
(define (q-tester x y)
  (list (quotient x y) (quotient (- x) y)
        (quotient x (- y)) (quotient (- x) (- y))
        (exact? (quotient x y))))

;; these uses BignumDivSI -> bignum_sdiv
(test "big[1]/fix->fix" (q-result 17353 #t) 
      (lambda () (q-tester 727836879 41943)))
(test "big[1]/fix->fix" (q-result 136582 #t)
      (lambda () (q-tester 3735928559 27353)))
(test "big[2]/fix->big[1]" (q-result 535341266467 #t)
      (lambda () (q-tester 12312849128741 23)))
(test "big[2]/fix->big[2]" (q-result 12312849128741 #t)
      (lambda () (q-tester 12312849128741 1)))

;; these uses BignumDivSI -> bignum_gdiv
(test "big[1]/fix->fix" (q-result 41943 #t)
      (lambda () (q-tester 3663846879 87353)))
(test "big[2]/fix->fix" (q-result 19088743 #t)
      (lambda () (q-tester 705986470884353 36984440)))
(test "big[2]/fix->fix" (q-result 92894912 #t)
      (lambda () (q-tester 12312849128741 132546)))
(test "big[2]/fix->big[1]" (q-result 2582762030 #t)
      (lambda () (q-tester 425897458766735 164900)))

;; these uses BignumDivRem
(test "big[1]/big[1]->fix" (q-result 2 #t)
      (lambda () (q-tester 4020957098 1952679221)))
(test "big[1]/big[1] -> fix" (q-result 0 #t)
      (lambda () (q-tester 1952679221 4020957098)))
;; this tests loop in estimation phase
(test "big[3]/big[2] -> big[1]" (q-result #xffff0001 #t)
      (lambda () (q-tester #x10000000000000000 #x10000ffff)))
;; this test goes through a rare case handling code ("add back") in
;; the algorithm.
(test "big[3]/big[2] -> fix" (q-result #xeffe #t)
      (lambda () (q-tester #x7800000000000000 #x80008889ffff)))

;; inexact quotient
(test "exact/inexact -> inexact" (q-result 3.0 #f)
      (lambda () (q-tester 13 4.0)))
(test "inexact/exact -> inexact" (q-result 3.0 #f)
      (lambda () (q-tester 13.0 4)))
(test "inexact/inexact -> inexact" (q-result 3.0 #f)
      (lambda () (q-tester 13.0 4.0)))
(test "exact/inexact -> inexact" (q-result 17353.0 #f)
      (lambda () (q-tester 727836879 41943.0)))
(test "inexact/exact -> inexact" (q-result 17353.0 #f)
      (lambda () (q-tester 727836879.0 41943)))
(test "inexact/inexact -> inexact" (q-result 17353.0 #f)
      (lambda () (q-tester 727836879.0 41943.0)))

;; Test by fermat numbers
(test "fermat(7)" 59649589127497217
      (lambda () (quotient (fermat 7) 5704689200685129054721)))
(test "fermat(8)" 1238926361552897
      (lambda ()
        (quotient (fermat 8) 93461639715357977769163558199606896584051237541638188580280321)))
(test "fermat(9)" 2424833
      (lambda ()
        (quotient (quotient (fermat 9) 7455602825647884208337395736200454918783366342657)
                  741640062627530801524787141901937474059940781097519023905821316144415759504705008092818711693940737)))
(test "fermat(10)" 4659775785220018543264560743076778192897
      (lambda ()
        (quotient (quotient (quotient (fermat 10)
                                      130439874405488189727484768796509903946608530841611892186895295776832416251471863574140227977573104895898783928842923844831149032913798729088601617946094119449010595906710130531906171018354491609619193912488538116080712299672322806217820753127014424577)
                            6487031809)
                  45592577)))
(test "fermat(11)" 3560841906445833920513
      (lambda ()
        (quotient (quotient (quotient (quotient (fermat 11)
                                                167988556341760475137)
                                      173462447179147555430258970864309778377421844723664084649347019061363579192879108857591038330408837177983810868451546421940712978306134189864280826014542758708589243873685563973118948869399158545506611147420216132557017260564139394366945793220968665108959685482705388072645828554151936401912464931182546092879815733057795573358504982279280090942872567591518912118622751714319229788100979251036035496917279912663527358783236647193154777091427745377038294584918917590325110939381322486044298573971650711059244462177542540706913047034664643603491382441723306598834177
                                      )
                            974849)
                  319489)))

;;------------------------------------------------------------------
(test-section "remainder")

(define (r-result x exact?) (list x (- x) x (- x) exact?))
(define (r-tester x y)
  (list (remainder x y) (remainder (- x) y)
        (remainder x (- y)) (remainder (- x) (- y))
        (exact? (remainder x y))))

;; small int
(test "fix rem fix -> fix" (r-result 1 #t)
      (lambda () (r-tester 13 4)))
(test "fix rem fix -> fix" (r-result 1234 #t)
      (lambda () (r-tester 1234 87935)))
(test "fix rem big[1] -> fix" (r-result 12345 #t)
      (lambda () (r-tester 12345 3735928559)))

;; these uses BignumDivSI -> bignum_sdiv
(test "big[1] rem fix -> fix" (r-result 0 #t)
      (lambda () (r-tester 727836879 41943)))
(test "big[1] rem fix -> fix" (r-result 1113 #t)
      (lambda () (r-tester 3735928559 27353)))
(test "big[2] rem fix -> fix" (r-result 15 #t)
      (lambda () (r-tester 12312849128756 23)))
(test "big[2] rem fix -> fix" (r-result 0 #t)
      (lambda () (r-tester 12312849128756 1)))

;; these uses BignumDivSI -> bignum_gdiv
(test "big[1] rem fix -> fix" (r-result 0 #t)
      (lambda () (r-tester 3663846879 87353)))
(test "big[2] rem fix -> fix" (r-result 725433 #t)
      (lambda () (r-tester 705986470884353 36984440)))
(test "big[2] rem fix -> fix" (r-result 122789 #t)
      (lambda () (r-tester 12312849128741 132546)))
(test "big[2] rem fix -> fix" (r-result 19735 #t)
      (lambda () (r-tester 425897458766735 164900)))

;; these uses BignumDivRem
(test "big[1] rem big[1] -> fix" (r-result 115598656 #t)
      (lambda () (r-tester 4020957098 1952679221)))
(test "big[1] rem big[1] -> fix" (r-result 1952679221 #t)
      (lambda () (r-tester 1952679221 4020957098)))
;; this tests loop in estimation phase
(test "big[3] rem big[2] -> big[1]" (r-result #xfffe0001 #t)
      (lambda () (r-tester #x10000000000000000 #x10000ffff)))
;; this tests "add back" code
(test "big[3] rem big[2] -> big[2]" (r-result #x7fffb114effe #t)
      (lambda () (r-tester #x7800000000000000 #x80008889ffff)))

;; inexact remainder
(test "exact rem inexact -> inexact" (r-result 1.0 #f)
      (lambda () (r-tester 13 4.0)))
(test "inexact rem exact -> inexact" (r-result 1.0 #f)
      (lambda () (r-tester 13.0 4)))
(test "inexact rem inexact -> inexact" (r-result 1.0 #f)
      (lambda () (r-tester 13.0 4.0)))
(test "exact rem inexact -> inexact" (r-result 1113.0 #f)
      (lambda () (r-tester 3735928559 27353.0)))
(test "inexact rem exact -> inexact" (r-result 1113.0 #f)
      (lambda () (r-tester 3735928559.0 27353)))
(test "inexact rem inexact -> inexact" (r-result 1113.0 #f)
      (lambda () (r-tester 3735928559.0 27353.0)))

;;------------------------------------------------------------------
(test-section "modulo")

(define (m-result a b exact?) (list a b (- b) (- a) exact?))
(define (m-tester x y)
  (list (modulo x y) (modulo (- x) y)
        (modulo x (- y)) (modulo (- x) (- y))
        (exact? (modulo x y))))

;; small int
(test "fix mod fix -> fix" (m-result 1 3 #t)
      (lambda () (m-tester 13 4)))
(test "fix mod fix -> fix" (m-result 1234 86701 #t)
      (lambda () (m-tester 1234 87935)))
(test "fix mod big[1] -> fix/big" (m-result 12345 3735916214 #t)
      (lambda () (m-tester 12345 3735928559)))

;; these uses BignumDivSI -> bignum_sdiv
(test "big[1] mod fix -> fix" (m-result 0 0 #t)
      (lambda () (m-tester 727836879 41943)))
(test "big[1] mod fix -> fix" (m-result 1113 26240 #t)
      (lambda () (m-tester 3735928559 27353)))
(test "big[2] mod fix -> fix" (m-result 15 8 #t)
      (lambda () (m-tester 12312849128756 23)))
(test "big[2] mod fix -> fix" (m-result 0 0 #t)
      (lambda () (m-tester 12312849128756 1)))

;; these uses BignumDivSI -> bignum_gdiv
(test "big[1] mod fix -> fix" (m-result 0 0 #t)
      (lambda () (m-tester 3663846879 87353)))
(test "big[2] mod fix -> fix" (m-result 725433 36259007 #t)
      (lambda () (m-tester 705986470884353 36984440)))
(test "big[2] mod fix -> fix" (m-result 122789 9757 #t)
      (lambda () (m-tester 12312849128741 132546)))
(test "big[2] mod fix -> fix" (m-result 19735 145165 #t)
      (lambda () (m-tester 425897458766735 164900)))

;; these uses BignumDivRem
(test "big[1] mod big[1] -> fix" (m-result 115598656 1837080565 #t)
      (lambda () (m-tester 4020957098 1952679221)))
(test "big[1] mod big[1] -> fix" (m-result 1952679221 2068277877 #t)
      (lambda () (m-tester 1952679221 4020957098)))
;; this tests loop in estimation phase
(test "big[3] mod big[2] -> big[1]" (m-result #xfffe0001 #x2fffe #t)
      (lambda () (m-tester #x10000000000000000 #x10000ffff)))
;; this tests "add back" code
(test "big[3] mod big[2] -> big[2]" (m-result #x7fffb114effe #xd7751001 #t)
      (lambda () (m-tester #x7800000000000000 #x80008889ffff)))

;; inexact modulo
(test "exact mod inexact -> inexact" (m-result 1.0 3.0 #f)
      (lambda () (m-tester 13 4.0)))
(test "inexact mod exact -> inexact" (m-result 1.0 3.0 #f)
      (lambda () (m-tester 13.0 4)))
(test "inexact mod inexact -> inexact" (m-result 1.0 3.0 #f)
      (lambda () (m-tester 13.0 4.0)))
(test "exact mod inexact -> inexact" (m-result 1113.0 26240.0 #f)
      (lambda () (m-tester 3735928559 27353.0)))
(test "inexact mod exact -> inexact" (m-result 1113.0 26240.0 #f)
      (lambda () (m-tester 3735928559.0 27353)))
(test "inexact mod inexact -> inexact" (m-result 1113.0 26240.0 #f)
      (lambda () (m-tester 3735928559.0 27353.0)))

;;------------------------------------------------------------------
(test-section "expt")

(test "exact expt" 1 (lambda () (expt 5 0)))
(test "exact expt" 9765625 (lambda () (expt 5 10)))
(test "exact expt" 1220703125 (lambda () (expt 5 13)))
(test "exact expt" 94039548065783000637498922977779654225493244541767001720700136502273380756378173828125 (lambda () (expt 5 123)))
(test "exact expt" 1 (lambda () (expt -5 0)))
(test "exact expt" 9765625 (lambda () (expt -5 10)))
(test "exact expt" -1220703125 (lambda () (expt -5 13)))
(test "exact expt" -94039548065783000637498922977779654225493244541767001720700136502273380756378173828125 (lambda () (expt -5 123)))
(test "exact expt" 1 (lambda () (expt 1 720000)))
(test "exact expt" 1 (lambda () (expt -1 720000)))
(test "exact expt" -1 (lambda () (expt -1 720001)))

;;------------------------------------------------------------------
(test-section "logical operations")

(test "ash (fixnum)" #x408000           ;fixnum
      (lambda () (ash #x81 15)))
(test "ash (fixnum)" #x81
      (lambda () (ash #x408000 -15)))
(test "ash (fixnum)" #x01
      (lambda () (ash #x408000 -22)))
(test "ash (fixnum)" 0
      (lambda () (ash #x408000 -23)))
(test "ash (fixnum)" 0
      (lambda () (ash #x408000 -24)))
(test "ash (fixnum)" 0
      (lambda () (ash #x408000 -100)))
(test "ash (fixnum)" #x81
      (lambda () (ash #x81 0)))
(test "ash (neg. fixnum)" #x-408000  ;negative fixnum
      (lambda () (ash #x-81 15)))
(test "ash (neg. fixnum)" #x-81      ;nagative fixnum
      (lambda () (ash #x-408000 -15)))
(test "ash (fixnum)" -2
      (lambda () (ash #x-408000 -22)))
(test "ash (fixnum)" -1
      (lambda () (ash #x-408000 -23)))
(test "ash (fixnum)" -1
      (lambda () (ash #x-408000 -24)))
(test "ash (fixnum)" -1
      (lambda () (ash #x-408000 -100)))
(test "ash (fixnum)" #x-408000
      (lambda () (ash #x-408000 0)))

(test "ash (fixnum->bignum)" #x81000000
      (lambda () (ash #x81 24)))
(test "ash (fixnum->bignum)" #x4080000000
      (lambda () (ash #x81 31)))
(test "ash (fixnum->bignum)" #x8100000000
      (lambda () (ash #x81 32)))
(test "ash (fixnum->bignum)" #x8100000000000000
      (lambda () (ash #x81 56)))
(test "ash (fixnum->bignum)" #x408000000000000000
      (lambda () (ash #x81 63)))
(test "ash (fixnum->bignum)" #x810000000000000000
      (lambda () (ash #x81 64)))
(test "ash (neg.fixnum->bignum)" #x-81000000
      (lambda () (ash #x-81 24)))
(test "ash (neg.fixnum->bignum)" #x-4080000000
      (lambda () (ash #x-81 31)))
(test "ash (neg.fixnum->bignum)" #x-8100000000
      (lambda () (ash #x-81 32)))
(test "ash (neg.fixnum->bignum)" #x-8100000000000000
      (lambda () (ash #x-81 56)))
(test "ash (neg.fixnum->bignum)" #x-408000000000000000
      (lambda () (ash #x-81 63)))
(test "ash (neg.fixnum->bignum)" #x-810000000000000000
      (lambda () (ash #x-81 64)))

(test "ash (bignum->fixnum)" #x81
      (lambda () (ash  #x81000000 -24)))
(test "ash (bignum->fixnum)" #x40
      (lambda () (ash  #x81000000 -25)))
(test "ash (bignum->fixnum)" 1
      (lambda () (ash  #x81000000 -31)))
(test "ash (bignum->fixnum)" 0
      (lambda () (ash  #x81000000 -32)))
(test "ash (bignum->fixnum)" 0
      (lambda () (ash  #x81000000 -100)))
(test "ash (bignum->fixnum)" #x81
      (lambda () (ash #x4080000000 -31)))
(test "ash (bignum->fixnum)" #x81
      (lambda () (ash #x8100000000 -32)))
(test "ash (bignum->fixnum)" #x40
      (lambda () (ash #x8100000000 -33)))
(test "ash (bignum->fixnum)" 1
      (lambda () (ash #x8100000000 -39)))
(test "ash (bignum->fixnum)" 0
      (lambda () (ash #x8100000000 -40)))
(test "ash (bignum->fixnum)" 0
      (lambda () (ash #x8100000000 -100)))
(test "ash (bignum->fixnum)" #x81
      (lambda () (ash #x8100000000000000 -56)))
(test "ash (bignum->fixnum)" #x81
      (lambda () (ash #x408000000000000000 -63)))
(test "ash (bignum->fixnum)" #x40
      (lambda () (ash #x408000000000000000 -64)))
(test "ash (bignum->fixnum)" #x20
      (lambda () (ash #x408000000000000000 -65)))
(test "ash (bignum->fixnum)" 1
      (lambda () (ash #x408000000000000000 -70)))
(test "ash (bignum->fixnum)" 0
      (lambda () (ash #x408000000000000000 -71)))
(test "ash (bignum->fixnum)" 0
      (lambda () (ash #x408000000000000000 -100)))

(test "ash (neg.bignum->fixnum)" #x-81
      (lambda () (ash #x-81000000 -24)))
(test "ash (neg.bignum->fixnum)" #x-41
      (lambda () (ash #x-81000000 -25)))
(test "ash (neg.bignum->fixnum)" #x-21
      (lambda () (ash #x-81000000 -26)))
(test "ash (neg.bignum->fixnum)" -2
      (lambda () (ash #x-81000000 -31)))
(test "ash (neg.bignum->fixnum)" -1
      (lambda () (ash #x-81000000 -32)))
(test "ash (neg.bignum->fixnum)" -1
      (lambda () (ash #x-81000000 -33)))
(test "ash (neg.bignum->fixnum)" -1
      (lambda () (ash #x-81000000 -100)))
(test "ash (neg.bignum->fixnum)" #x-81
      (lambda () (ash #x-4080000000 -31)))
(test "ash (neg.bignum->fixnum)" #x-41
      (lambda () (ash #x-4080000000 -32)))
(test "ash (neg.bignum->fixnum)" #x-21
      (lambda () (ash #x-4080000000 -33)))
(test "ash (neg.bignum->fixnum)" -2
      (lambda () (ash #x-4080000000 -38)))
(test "ash (neg.bignum->fixnum)" -1
      (lambda () (ash #x-4080000000 -39)))
(test "ash (neg.bignum->fixnum)" -1
      (lambda () (ash #x-4080000000 -100)))
(test "ash (neg.bignum->fixnum)" #x-81
      (lambda () (ash #x-408000000000000000 -63)))
(test "ash (neg.bignum->fixnum)" #x-41
      (lambda () (ash #x-408000000000000000 -64)))
(test "ash (neg.bignum->fixnum)" #x-21
      (lambda () (ash #x-408000000000000000 -65)))
(test "ash (neg.bignum->fixnum)" -2
      (lambda () (ash #x-408000000000000000 -70)))
(test "ash (neg.bignum->fixnum)" -1
      (lambda () (ash #x-408000000000000000 -71)))
(test "ash (neg.bignum->fixnum)" -1
      (lambda () (ash #x-408000000000000000 -72)))

(test "ash (bignum->bignum)" #x12345678123456780
      (lambda () (ash #x1234567812345678 4)))
(test "ash (bignum->bignum)" #x1234567812345678000000000000000
      (lambda () (ash #x1234567812345678 60)))
(test "ash (bignum->bignum)" #x12345678123456780000000000000000
      (lambda () (ash #x1234567812345678 64)))
(test "ash (bignum->bignum)" #x123456781234567
      (lambda () (ash #x1234567812345678 -4)))
(test "ash (bignum->bignum)" #x12345678
      (lambda () (ash #x1234567812345678 -32)))
(test "ash (neg.bignum->bignum)" #x-123456781234568
      (lambda () (ash #x-1234567812345678 -4)))
(test "ash (bignum->bignum)" #x-12345679
      (lambda () (ash #x-1234567812345678 -32)))

(test "lognot (fixnum)" -1 (lambda () (lognot 0)))
(test "lognot (fixnum)" 0 (lambda () (lognot -1)))
(test "lognot (fixnum)" -65536 (lambda () (lognot 65535)))
(test "lognot (fixnum)" 65535 (lambda () (lognot -65536)))
(test "lognot (bignum)" #x-1000000000000000001
      (lambda () (lognot #x1000000000000000000)))
(test "lognot (bignum)" #x1000000000000000000
      (lambda () (lognot #x-1000000000000000001)))

(test "logand (+fix & 0)" 0
      (lambda () (logand #x123456 0)))
(test "logand (+big & 0)" 0
      (lambda () (logand #x1234567812345678 0)))
(test "logand (+fix & -1)" #x123456
      (lambda () (logand #x123456 -1)))
(test "logand (+big & -1)" #x1234567812345678
      (lambda () (logand #x1234567812345678 -1)))
(test "logand (+fix & +fix)" #x2244
      (lambda () (logand #xaa55 #x6666)))
(test "logand (+fix & +big)" #x2244
      (lambda () (logand #xaa55 #x6666666666)))
(test "logand (+big & +fix)" #x4422
      (lambda () (logand #xaa55aa55aa #x6666)))
(test "logand (+big & +big)" #x2244224422
      (lambda () (logand #xaa55aa55aa #x6666666666)))
(test "logand (+big & +big)" #x103454301aaccaa
      (lambda () (logand #x123456789abcdef #xfedcba987654321fedcba987654321fedcba)))
(test "logand (+big & +big)" #x400000
      (lambda () (logand #xaa55ea55aa #x55aa55aa55)))
(test "logand (+fix & -fix)" #x8810
      (lambda () (logand #xaa55 #x-6666)))
(test "logand (+fix & -big)" #x8810
      (lambda () (logand #xaa55 #x-6666666666)))
(test "logand (+big & -fix)" #xaa55aa118a
      (lambda () (logand #xaa55aa55aa #x-6666)))
(test "logand (+big & -big)" #x881188118a
      (lambda () (logand #xaa55aa55aa #x-6666666666)))
(test "logand (+big & -big)" #x20002488010146
      (lambda () (logand #x123456789abcdef #x-fedcba987654321fedcba987654321fedcba)))
(test "logand (-fix & +fix)" #x4422
      (lambda () (logand #x-aa55 #x6666)))
(test "logand (-fix & +big)" #x6666664422
      (lambda () (logand #x-aa55 #x6666666666)))
(test "logand (-big & +fix)" #x2246
      (lambda () (logand #x-aa55aa55aa #x6666)))
(test "logand (-big & +big)" #x4422442246
      (lambda () (logand #x-aa55aa55aa #x6666666666)))
(test "logand (-big & +big)" #xfedcba987654321fedcba884200020541010
      (lambda () (logand #x-123456789abcdef #xfedcba987654321fedcba987654321fedcba)))
(test "logand (-fix & -fix)" #x-ee76
      (lambda () (logand #x-aa55 #x-6666)))
(test "logand (-fix & -big)" #x-666666ee76
      (lambda () (logand #x-aa55 #x-6666666666)))
(test "logand (-big & -fix)" #x-aa55aa77ee
      (lambda () (logand #x-aa55aa55aa #x-6666)))
(test "logand (-big & -big)" #x-ee77ee77ee
      (lambda () (logand #x-aa55aa55aa #x-6666666666)))
(test "logand (-big & -big)" #x-fedcba987654321fedcba9a76567a9ffde00
      (lambda () (logand #x-123456789abcdef #x-fedcba987654321fedcba987654321fedcba)))

(test "logior (+fix | 0)" #x123456
      (lambda () (logior #x123456 0)))
(test "logior (+big | 0)" #x1234567812345678
      (lambda () (logior #x1234567812345678 0)))
(test "logior (+fix | -1)" -1
      (lambda () (logior #x123456 -1)))
(test "logior (+big | -1)" -1
      (lambda () (logior #x1234567812345678 -1)))
(test "logior (+fix | +fix)" #xee77
      (lambda () (logior #xaa55 #x6666)))
(test "logior (+fix | +big)" #x666666ee77
      (lambda () (logior #xaa55 #x6666666666)))
(test "logior (+big | +fix)" #xaa55aa77ee
      (lambda () (logior #xaa55aa55aa #x6666)))
(test "logior (+big | +big)" #xee77ee77ee
      (lambda () (logior #xaa55aa55aa #x6666666666)))
(test "logior (+big | +big)" #xfedcba987654321fedcba9a76567a9ffddff
      (lambda () (logior #x123456789abcdef #xfedcba987654321fedcba987654321fedcba)))
(test "logior (+fix | -fix)" #x-4421
      (lambda () (logior #xaa55 #x-6666)))
(test "logior (+fix | -big)" #x-6666664421
      (lambda () (logior #xaa55 #x-6666666666)))
(test "logior (+big | -fix)" #x-2246
      (lambda () (logior #xaa55aa55aa #x-6666)))
(test "logior (+big | -big)" #x-4422442246
      (lambda () (logior #xaa55aa55aa #x-6666666666)))
(test "logior (+big | -big)" #x-fedcba987654321fedcba884200020541011
      (lambda () (logior #x123456789abcdef #x-fedcba987654321fedcba987654321fedcba)))
(test "logior (-fix | +fix)" #x-8811
      (lambda () (logior #x-aa55 #x6666)))
(test "logior (-fix | +big)" #x-8811
      (lambda () (logior #x-aa55 #x6666666666)))
(test "logior (-big | +fix)" #x-aa55aa118a
      (lambda () (logior #x-aa55aa55aa #x6666)))
(test "logior (-big | +big)" #x-881188118a
      (lambda () (logior #x-aa55aa55aa #x6666666666)))
(test "logior (-big | +big)" #x-20002488010145
      (lambda () (logior #x-123456789abcdef #xfedcba987654321fedcba987654321fedcba)))
(test "logior (-fix | -fix)" #x-2245
      (lambda () (logior #x-aa55 #x-6666)))
(test "logior (-fix | -big)" #x-2245
      (lambda () (logior #x-aa55 #x-6666666666)))
(test "logior (-big | -fix)" #x-4422
      (lambda () (logior #x-aa55aa55aa #x-6666)))
(test "logior (-big | -big)" #x-2244224422
      (lambda () (logior #x-aa55aa55aa #x-6666666666)))
(test "logior (-big | -big)" #x-103454301aacca9
      (lambda () (logior #x-123456789abcdef #x-fedcba987654321fedcba987654321fedcba)))

(test "logtest" #t
      (lambda () (logtest #xfeedbabe #x10000000)))
(test "logtest" #f
      (lambda () (logtest #xfeedbabe #x01100101)))

(test "logcount" 4
      (lambda () (logcount #b10101010)))
(test "logcount" 13
      (lambda () (logcount #b00010010001101000101011001111000)))
(test "logcount" 4
      (lambda () (logcount #b-10101010)))

(test "logbit?" '(#f #t #t #f #t #f #f)
      (lambda ()
        (map (lambda (i) (logbit? i #b10110)) '(0 1 2 3 4 5 6))))
(test "logbit?" '(#f #t #f #t #f #t #t)
      (lambda ()
        (map (lambda (i) (logbit? i #b-10110)) '(0 1 2 3 4 5 6))))

(test "copy-bit" #b11010110
      (lambda () (copy-bit 4 #b11000110 #t)))
(test "copy-bit" #b11000110
      (lambda () (copy-bit 4 #b11000110 #f)))
(test "copy-bit" #b10000110
      (lambda () (copy-bit 6 #b11000110 #f)))

(test "bit-field" #b1010
      (lambda () (bit-field #b1101101010 0 4)))
(test "bit-field" #b10110
      (lambda () (bit-field #b1101101010 4 9)))

(test "copy-bit-field" #b1101100000
      (lambda () (copy-bit-field #b1101101010 0 4 0)))
(test "copy-bit-field" #b1101101111
      (lambda () (copy-bit-field #b1101101010 0 4 -1)))
(test "copy-bit-field" #b1111111111101010
      (lambda () (copy-bit-field #b1101101010 5 16 -1)))

(test "integer-length" 8
      (lambda () (integer-length #b10101010)))
(test "integer-length" 4
      (lambda () (integer-length #b1111)))

;;------------------------------------------------------------------
(test-section "arithmetic operation override")

;; NB: these tests requires the object system working.

;; These code are only for tests, and do not suggest the real use of
;; arithmetic operation override.  For practical use, it is important
;; to define those operations consistently.  Note that Gauche's compiler
;; may reorder or change operations based on the assumption of the
;; normal definition of those arithmetic operations.

(define-method object-+ ((a <string>) b) #`",|a|+,|b|")
(define-method object-+ (a (b <string>)) #`",|a|+,|b|")
(define-method object-- ((a <string>) b) #`",|a|-,|b|")
(define-method object-- (a (b <string>)) #`",|a|-,|b|")
(define-method object-* ((a <string>) b) #`",|a|*,|b|")
(define-method object-* (a (b <string>)) #`",|a|*,|b|")
(define-method object-/ ((a <string>) b) #`",|a|/,|b|")
(define-method object-/ (a (b <string>)) #`",|a|/,|b|")

(define-method object-- ((a <string>)) #`"-,|a|")
(define-method object-/ ((a <string>)) #`"/,|a|")

(test "object-+" "a+b" (lambda () (+ "a" "b")))
(test "object-+" "a+b" (lambda () (+ "a" 'b)))
(test "object-+" "a+b" (lambda () (+ 'a "b")))
(test "object-+" "3+a" (lambda () (+ 3 "a")))
;; NB: this becomes "3+a" instead of "a+3", because of compiler optimization.
;; DO NOT COUNT ON THIS BEHAVIOR IN THE REAL CODE.   Might be changed in
;; the future release.
(test "object-+" "3+a" (lambda () (+ "a" 3)))

(test "object--" "a-b" (lambda () (- "a" "b")))
(test "object--" "a-b" (lambda () (- "a" 'b)))
(test "object--" "a-b" (lambda () (- 'a "b")))
(test "object--" "3-a" (lambda () (- 3 "a")))
;; NB: this becomes "-3+a" instead of "a-3", because of compiler optimization
;; DO NOT COUNT ON THIS BEHAVIOR IN THE REAL CODE.   Might be changed in
;; the future release.
(test "object--" "-3+a" (lambda () (- "a" 3)))

(test "object--" "-a"  (lambda () (- "a")))

(test "object-*" "a*b" (lambda () (* "a" "b")))
(test "object-*" "a*b" (lambda () (* "a" 'b)))
(test "object-*" "a*b" (lambda () (* 'a "b")))
(test "object-*" "3*a" (lambda () (* 3 "a")))
(test "object-*" "a*3" (lambda () (* "a" 3)))

(test "object-/" "a/b" (lambda () (/ "a" "b")))
(test "object-/" "a/b" (lambda () (/ "a" 'b)))
(test "object-/" "a/b" (lambda () (/ 'a "b")))
(test "object-/" "3/a" (lambda () (/ 3 "a")))
(test "object-/" "a/3" (lambda () (/ "a" 3)))

(test "object-/" "/a"  (lambda () (/ "a")))

(test-end)
