;;
;; testing fcntl
;;

(use gauche.test)
(test-start "fcntl")

(if (member "." *load-path*) ;; trick to allow in-place test
  (load "fcntl")
  (load "gauche/fcntl"))
(import gauche.fcntl)
(test-module 'gauche.fcntl)

;; It is difficult to compose a full test that works on every situation.
;; Here I provide tests for some common features.

(test-section "F_GETFL")

(sys-unlink "test.o")

(test "F_GETFL" |O_WRONLY|
      (lambda ()
        (call-with-output-file "test.o"
          (lambda (p) (logand (sys-fcntl p |F_GETFL|) |O_ACCMODE|)))))

(test "F_GETFL" |O_RDONLY|
      (lambda ()
        (call-with-input-file "test.o"
          (lambda (p) (logand (sys-fcntl p |F_GETFL|) |O_ACCMODE|)))))

(test "F_GETFL" #t
      (lambda ()
        (call-with-input-file "test.o"
          (lambda (p)
            (zero? (logand (sys-fcntl p |F_GETFL|) |O_APPEND|))))))

(test "F_GETFL" #f
      (lambda ()
        (call-with-output-file "test.o"
          (lambda (p) (zero? (logand (sys-fcntl p |F_GETFL|) |O_APPEND|)))
          :if-exists :append)))

(sys-unlink "test.o")

;; TODO: test lock

(test-end)
