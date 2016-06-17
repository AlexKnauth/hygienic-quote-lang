#lang racket/base

(provide extend-reader
         make-quote-proc
         make-unquote-proc
         )

(require syntax/srcloc)

;; extend-reader : (A ... -> Any) (Readtable (Syntax -> Syntax) -> Readtable) -> (A ... -> Any)
(define (extend-reader proc extend-readtable)
  (lambda args
    (define orig-readtable (current-readtable))
    (define outer-scope (make-syntax-introducer/use-site))
    (parameterize ([current-readtable (extend-readtable orig-readtable outer-scope)])
      (define stx (apply proc args))
      (if (syntax? stx)
          (outer-scope stx)
          stx))))

;; make-syntax-introducer/use-site : -> [Syntax -> Syntax]
(define (make-syntax-introducer/use-site)
  (cond [(procedure-arity-includes? make-syntax-introducer 1)
         (make-syntax-introducer #t)]
        [else
         (make-syntax-introducer)]))

;; make-quote-proc : Id [Syntax -> Syntax] -> Readtable-Proc
(define ((make-quote-proc quote-id outer-scope)
         char in src ln col pos)
  (define stx (read-syntax/recursive src in #f))
  (define quote-id*
    (update-source-location quote-id
      #:source src #:line ln #:column col #:position pos
      #:span (and pos (syntax-position stx) (- (syntax-position stx) pos))))
  (parse quote-id* stx outer-scope))

;; make-unquote-proc : Char Id Id [Syntax -> Syntax] -> Readtable-Proc
(define ((make-unquote-proc splicing-char splicing-id unquote-id outer-scope)
         char in src ln col pos)
  (define c2 (read-char in))
  (cond [(char=? c2 splicing-char)
         (define stx (read-syntax/recursive src in #f))
         (define splicing-id*
           (update-source-location splicing-id
             #:source src #:line ln #:column col #:position pos
             #:span (and pos (syntax-position stx) (- (syntax-position stx) pos))))
         (parse splicing-id* stx outer-scope)]
        [else
         (define stx (read-syntax/recursive src in c2))
         (define unquote-id*
           (update-source-location unquote-id
             #:source src #:line ln #:column col #:position pos
             #:span (and pos (syntax-position stx) (- (syntax-position stx) pos))))
         (parse unquote-id* stx outer-scope)]))

;; parse : Id Syntax [Syntax -> Syntax] -> Syntax
(define (parse quote-id stx outer-scope)
  (hygienic-app
   #:outer-scope outer-scope
   (lambda (stx*)
     #`(#,quote-id #,stx*))
   stx))

;; hygienic-app : [Syntax -> Syntax] Syntax #:outer-scope [Syntax -> Syntax] -> Syntax
;; Applies proc to stx, but with extra scopes added to the input and
;; output to make it hygienic.
(define (hygienic-app proc stx #:outer-scope outer-scope)
  (define inner-scope (make-syntax-introducer))
  (outer-scope (inner-scope (proc (inner-scope (outer-scope stx))))))

