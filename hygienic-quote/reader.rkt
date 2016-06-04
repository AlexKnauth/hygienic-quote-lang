#lang racket/base

(provide wrap-reader)

(require "private/make-quote-proc.rkt"
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

;; wrap-reader : [A ... -> Any] -> [A ... -> Any]
(define (wrap-reader p)
  (extend-reader p make-hygienic-quote-readtable))

;; make-hygienic-quote-readtable : Readtable [Syntax -> Syntax] -> Readtable
(define (make-hygienic-quote-readtable orig-rt outer-scope)
  (make-readtable orig-rt
    #\' 'terminating-macro (make-quote-proc (o #'quote) outer-scope)
    #\` 'terminating-macro (make-quote-proc (o #'quasiquote) outer-scope)
    #\, 'terminating-macro (make-unquote-proc #\@ (o #'unquote-splicing) (o #'unquote) outer-scope)
    #\' 'dispatch-macro (make-quote-proc (o #'syntax) outer-scope)
    #\` 'dispatch-macro (make-quote-proc (o #'quasisyntax) outer-scope)
    #\, 'dispatch-macro (make-unquote-proc #\@ (o #'unsyntax-splicing) (o #'unsyntax) outer-scope)
    ))

;; o : Syntax -> Syntax
(define (o stx)
  (syntax-property stx 'original-for-check-syntax #true))

