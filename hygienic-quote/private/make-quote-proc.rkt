#lang racket/base

(provide extend-reader
         make-quote-proc
         make-unquote-proc
         )

;; extend-reader : (A ... -> Any) (Readtable (Syntax -> Syntax) -> Readtable) -> (A ... -> Any)
(define (extend-reader proc extend-readtable)
  (lambda args
    (define orig-readtable (current-readtable))
    (define intro
      (cond [(procedure-arity-includes? make-syntax-introducer 1)
             (make-syntax-introducer #t)]
            [else
             (make-syntax-introducer)]))
    (parameterize ([current-readtable (extend-readtable orig-readtable intro)])
      (define stx (apply proc args))
      (if (syntax? stx)
          (intro stx)
          stx))))


;; make-quote-proc : Id [Syntax -> Syntax] -> Readtable-Proc
(define ((make-quote-proc quote-id outer-scope)
         char in src ln col pos)
  (define stx (read-syntax/recursive src in #f))
  (parse quote-id stx outer-scope))

;; make-unquote-proc : Char Id Id [Syntax -> Syntax] -> Readtable-Proc
(define ((make-unquote-proc splicing-char splicing-id unquote-id outer-scope)
         char in src ln col pos)
  (define c2 (read-char in))
  (cond [(char=? c2 splicing-char)
         (define stx (read-syntax/recursive src in #f))
         (parse splicing-id stx outer-scope)]
        [else
         (define stx (read-syntax/recursive src in c2))
         (parse unquote-id stx outer-scope)]))

;; parse : Id Syntax [Syntax -> Syntax] -> Syntax
(define (parse quote-id stx outer-scope)
  (define inner-scope (make-syntax-introducer))
  (with-syntax ([quote-id quote-id]
                [stx* (inner-scope (outer-scope stx))])
    (outer-scope (inner-scope #'(quote-id stx*)))))

