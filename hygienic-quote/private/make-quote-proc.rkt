#lang racket/base

(provide make-quote-proc
         make-unquote-proc
         )

(require syntax/srcloc hygienic-reader-extension/extend-reader)

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

