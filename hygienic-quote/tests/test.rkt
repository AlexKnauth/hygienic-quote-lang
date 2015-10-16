#lang hygienic-quote racket/base

(require rackunit)

(check-equal? '3 3)
(check-equal? `3 3)
(check-equal? `,3 3)
(check-equal? `(,@(list 3)) (list 3))
(check-equal? (syntax-e #'3) 3)
(check-equal? (syntax-e #`3) 3)
(check-equal? (syntax-e #`#,3) 3)
(check-equal? (syntax->datum #`(#,@(list 3))) (list 3))

(let ([quote (λ (x) 5)])
  (check-equal? '3 3))

(let ()
  (define 'foo 6)      ; (define (quote foo) 6)
  (check-equal? '3 3)) ; but that quote does not bind this one

(let ([syntax (λ (x) #'5)])
  (check-equal? (syntax-e #'3) 3))

(let ()
  (define #'foo (quote-syntax 6))  ; (define (syntax foo) (quote-syntax 6))
  (check-equal? (syntax-e #'3) 3)) ; but that syntax does not bind this one
