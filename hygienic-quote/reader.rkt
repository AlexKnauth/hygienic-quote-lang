#lang racket/base

(provide wrap-reader)

(require racket/match
         rackjure/threading
         racket/port
         racket/list
         syntax/srcloc
         (for-meta -10 racket/base)
         (for-meta -9 racket/base)
         (for-meta -8 racket/base)
         (for-meta -7 racket/base)
         (for-meta -6 racket/base)
         (for-meta -5 racket/base)
         (for-meta -4 racket/base)
         (for-meta -3 racket/base)
         (for-meta -2 racket/base)
         (for-meta -1 racket/base)
         (for-meta 0 racket/base)
         (for-meta 1 racket/base)
         (for-meta 2 racket/base)
         (for-meta 3 racket/base)
         (for-meta 4 racket/base)
         (for-meta 5 racket/base)
         (for-meta 6 racket/base)
         (for-meta 7 racket/base)
         (for-meta 8 racket/base)
         (for-meta 9 racket/base)
         (for-meta 10 racket/base)
         )

(module+ test
  (require rackunit racket/function))

(define current-outer-scope
  (make-parameter
   (lambda (stx)
     (error 'current-outer-scope "must be used within the hygienic-quote reader"))))

(define (wrap-reader p)
  (lambda args
    (define orig-readtable (current-readtable))
    (define intro (make-syntax-introducer #t))
    (parameterize ([current-readtable (make-hygienic-quote-readtable orig-readtable)]
                   [current-outer-scope intro])
      (define stx (apply p args))
      (if (syntax? stx)
          (intro stx)
          stx))))

(define (make-hygienic-quote-readtable [orig-rt (current-readtable)])
  (make-readtable orig-rt
    #\' 'terminating-macro (make-quote-proc #'quote)
    #\` 'terminating-macro (make-quote-proc #'quasiquote)
    #\, 'terminating-macro (make-unquote-proc #\@ #'unquote-splicing #'unquote)
    #\' 'dispatch-macro (make-quote-proc #'syntax)
    #\` 'dispatch-macro (make-quote-proc #'quasisyntax)
    #\, 'dispatch-macro (make-unquote-proc #\@ #'unsyntax-splicing #'unsyntax)
    ))


(define ((make-quote-proc quote-id)
         char in src ln col pos)
  (define stx (read-syntax/recursive src in #f))
  (parse quote-id stx))

(define ((make-unquote-proc splicing-char splicing-id unquote-id)
         char in src ln col pos)
  (define c2 (read-char in))
  (cond [(char=? c2 splicing-char)
         (define stx (read-syntax/recursive src in #f))
         (parse splicing-id stx)]
        [else
         (define stx (read-syntax/recursive src in c2))
         (parse unquote-id stx)]))

(define (parse quote-id stx)
  (define outer-scope (current-outer-scope))
  (define inner-scope (make-syntax-introducer))
  (with-syntax ([quote-id quote-id]
                [stx* (inner-scope (outer-scope stx))])
    (outer-scope (inner-scope #'(quote-id stx*)))))

