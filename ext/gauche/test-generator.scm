;; Test gauche.generator
;;  gauche.generator isn't precompiled (yet), but it depends on gauche.sequence
;;  so we test it here.

(use gauche.test)
(use gauche.sequence)
(use srfi-1)
(use srfi-60)
(test-start "generators")

(use gauche.generator)
(test-module 'gauche.generator)

(test-section "genreator constructors")

;; first, let's test the stuff used by the following tests.
(test* "giota + generator->list" '(0 1 2 3 4)
       (generator->list (giota 5)))
(test* "giota(start) + generator->list" '(10 11 12 13 14)
       (generator->list (giota 5 10)))
(test* "giota(start,step) + generator->list" '(10 12 14 16 18)
       (generator->list (giota 5 10 2)))
(test* "giota + generator->list(n)" '(0 1 2)
       (generator->list (giota 5) 3))
(test* "giota + generator->list(n)" '(0 1 2 3 4)
       (generator->list (giota 5) 10))

(test* "grange + generator->list" '(0 1 2 3 4)
       (generator->list (grange 0 5)))
(test* "grange + generator->list" '(2 3 4 5)
       (generator->list (grange 2 6)))
(test* "grange + generator->list" '(2 5 8 11)
       (generator->list (grange 2 14 3)))

;; converters
(let-syntax ((t (syntax-rules ()
                  [(t dir fn cv data)
                   (let1 expect (^ args
                                  (if (eq? 'dir 'r)
                                    (reverse (apply subseq (cv data) args))
                                    (apply subseq (cv data) args)))
                     (test* (format "~a" 'fn) (expect)
                            (generator->list (fn data)))
                     (test* (format "~a (1,_)" 'fn) (expect 1)
                            (generator->list (fn data 1)))
                     (test* (format "~a (1,3)" 'fn) (expect 1 3)
                            (generator->list (fn data 1 3)))
                     )])))
  (t f list->generator identity '(a b c d e))
  (t f vector->generator vector->list '#(a b c d e))
  (t r reverse-vector->generator vector->list '#(a b c d e))
  (t f string->generator string->list "abcde")
  (t f bits->generator integer->list 26)
  (t r reverse-bits->generator integer->list 26)
  (t f bits->generator integer->list 4395928592485)
  (t r reverse-bits->generator integer->list 4395928592485)
  )

;; file generators
(let-syntax ((t (syntax-rules ()
                  [(t fn expect data)
                   (unwind-protect
                       (begin
                         (with-output-to-file "test.o" (cut display data))
                         (test* (format "~a" 'fn) expect
                                (generator->list (fn "test.o"))))
                     (sys-unlink "test.o"))])))
  (t file->sexp-generator '((a) (b) (c) (d) (e))
     "(a)\n(b)\n(c)\n(d) (e)")
  (t file->char-generator '(#\a #\b #\c #\d #\e #\newline) "abcde\n")
  (t file->line-generator '("ab" "cd" "ef") "ab\ncd\nef")
  (t file->byte-generator '(97 98 99 100 101) "abcde"))

(test* "circular-generator" '(0 1 2 0 1 2 0 1 2 0)
       (generator->list (circular-generator 0 1 2) 10))

(test* "do-generator" '(4 4 3 3 2 2 1 1 0 0)
       (rlet1 p '()
         (do-generator [v (giota 5)]
           (push! p v)
           (push! p v))))

(let ()
  (define (test-gcons xs tail)
    (test* (format "gcons* ~s + ~s" xs tail)
           (apply cons* (append xs `(,tail)))
           (generator->list (apply gcons*
                                   (append xs `(,(list->generator tail)))))))
  (test-gcons '() '(x y z))
  (test-gcons '(a) '(x y z))
  (test-gcons '(a b) '(x y z))
  (test-gcons '(a b c) '(x y z)))

(let ()
  (define (test-generate expect gen)
    (test* "generate" expect (generator->list gen 10)))

  (test-generate '() (generate (^[yield] #f)))
  (test-generate '(0) (generate (^[yield] (yield 0) 3)))
  (test-generate '(0 1) (generate (^[yield] (yield 0) (yield 1))))

  (test-generate '(0 1 2 3 4 5 6 7 8 9)
                 (generate
                  (^[yield] (let loop ([i 0]) (yield i) (loop (+ i 1))))))
  )

(test* "gappend" '(0 1 2 3 a b c d A B C D)
       (generator->list (gappend (giota 4) 
                                 (x->generator '(a b c d))
                                 (x->generator '(A B C D)))))

(test* "gunfold" (unfold (^s (>= s 10))
                         (^s (* s 2))
                         (^s (+ s 1))
                         0
                         (^s (iota 10)))
       (generator->list (gunfold (^s (>= s 10))
                                 (^s (* s 2))
                                 (^s (+ s 1))
                                 0
                                 (^s (giota 10)))))

(define-syntax test-list-like
  (syntax-rules ()
    [(_  gfn lfn src ...)
     (dolist [s (list src ...)]
       (test* (format "~s" 'gfn) (lfn s)
              (generator->list (gfn (x->generator s))))
       (test* (format "~s (autoconvert)" 'gfn) (lfn s)
              (generator->list (gfn s))))]))
       
(define-syntax test-list-like*
  (syntax-rules ()
    [(_  gfn lfn src ...)
     (dolist [s (list src ...)]
       (test* (format "~s" 'gfn) (apply lfn s)
              (generator->list (apply gfn (map x->generator s))))
       (test* (format "~s (autoconvert)" 'gfn) (apply lfn s)
              (generator->list (apply gfn s))))]))

(test-list-like (cut gmap (^x (* x 2)) <>)
                (cut map (^x (* x 2)) <>)
                '(1 2 3 4 5) '())

(test-list-like* (cut gmap (^[x y] (* x y)) <...>)
                 (cut map (^[x y] (* x y)) <...>)
                 '((1 2 3 4 5) (2 3 4 5)) '(() ()))

(test-list-like (cut gmap-accum (^[x s] (values (+ x s) x)) 0 <>)
                (^[l]
                  (values-ref (map-accum (^[x s] (values (+ x s) x)) 0 l) 0))
                '(1 2 3 4 5) '())

(test-list-like* (cut gmap-accum (^[x y s] (values (+ x y s) x)) 0 <...>)
                 (^[l m]
                   (values-ref (map-accum (^[x y s] (values (+ x y s) x)) 0 l m)
                               0))
                '((1 2 3 4) (8 9 0 1 2)) '(() ()))

(test-list-like (cut gfilter odd? <>)
                (cut filter odd? <>)
                '(1 2 3 4 5) '())

(test-list-like (cut gfilter-map (^[n] (and (odd? n) (* n 2))) <>)
                (cut filter-map (^[n] (and (odd? n) (* n 2))) <>)
                '(1 2 3 4 5) '())

(test-list-like (cut gtake <> 3)
                (cut take* <> 3)
                '(1 2 3 4 5 6) '(1 2))

(test-list-like (cut gtake <> 3 #t 'a)
                (cut take* <> 3 #t 'a)
                '(1 2 3 4 5 6) '(1 2))

(test-list-like (cut gdrop <> 3)
                (cut drop* <> 3)
                '(1 2 3 4 5 6) '(1 2))

(test-list-like (cut gtake-while even? <>)
                (cut take-while even? <>)
                '(2 4 0 1 3) '(1 2 4 4 8) '() '(2 2) '(3 5))

(test-list-like (cut gdrop-while even? <>)
                (cut drop-while even? <>)
                '(2 4 0 1 3) '(1 2 4 4 8) '() '(2 2) '(3 5))

(test* "gstate-filter"
       '(1 2 3 1 2 3 1 2 3)
       (generator->list
        (gstate-filter (^[v s] (values (< s v) v)) 0
                       (list->generator '(1 2 3 2 1 0 1 2 3 2 1 0 1 2 3)))))

(test* "grxmatch (string)" '("ab" "cde" "fgh" "jkl")
       (map rxmatch-substring
            (generator->list (grxmatch #/\w{2,}/ " ab x y.cde\nfgh/j/jkl "))))
(test* "grxmatch (string/nomatch)" '()
       (map rxmatch-substring
            (generator->list (grxmatch #/\w{2,}/ " a x c e\n.f/g/j "))))
(test* "grxmatch (generator 1)" '("ab" "cde" "fgh" "jkl")
       ($ map rxmatch-substring
          $ generator->list
          $ grxmatch #/\w{2,}/
          $ string->generator " ab x y.cde\nfgh/j/jkl "))
(test* "grxmatch (generator 2)" '()
       ($ map rxmatch-substring
          $ generator->list
          $ grxmatch #/\w{2,}/
          $ string->generator " a x c e\n.f/g/j "))
(test* "grxmatch (generator 2)" '("ab" "cde" "fgh" "jkl")
       ($ map rxmatch-substring
          $ generator->list
          $ grxmatch #/\w{2,}/
          $ port->char-generator
          $ open-input-string " ab x y.cde\nfgh/j/jkl "))
(test* "grxmatch (generator 1000 chars)" '(500 499)
       ($ map (.$ string-length rxmatch-substring)
          $ generator->list
          $ grxmatch #/\w+/
          $ gappend (make-string 500 #\a) " " (make-string 499 #\a)))
(test* "grxmatch (generator 1001 chars)" '(500 500)
       ($ map (.$ string-length rxmatch-substring)
          $ generator->list
          $ grxmatch #/\w+/
          $ gappend (make-string 500 #\a) " " (make-string 500 #\a)))
(test* "grxmatch (generator 1002 chars)" '(501 500)
       ($ map (.$ string-length rxmatch-substring)
          $ generator->list
          $ grxmatch #/\w+/
          $ gappend (make-string 501 #\a) " " (make-string 500 #\a)))
(test* "grxmatch (generator 1001 chars)" '(2)
       ($ map (.$ string-length rxmatch-substring)
          $ generator->list
          $ grxmatch #/\w+/
          $ gappend (make-string 999 #\space) "aa"))
(test* "grxmatch (generator 1002 chars)" '(2)
       ($ map (.$ string-length rxmatch-substring)
          $ generator->list
          $ grxmatch #/\w+/
          $ gappend (make-string 1000 #\space) "aa"))
(test* "grxmatch (generator 2003 chars)" '(1999)
       ($ map (.$ string-length rxmatch-substring)
          $ generator->list
          $ grxmatch #/\w+/
          $ gappend "    " (make-string 1999 #\a)))


(test-end)

