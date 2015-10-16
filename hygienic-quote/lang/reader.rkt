#lang racket/base

(provide (rename-out [hygienic-quote-read read]
                     [hygienic-quote-read-syntax read-syntax]
                     [hygienic-quote-get-info get-info]))

(require syntax/module-reader
         (only-in "../reader.rkt" wrap-reader))

(define-values (hygienic-quote-read hygienic-quote-read-syntax hygienic-quote-get-info)
  (make-meta-reader
   'hygienic-quote
   "language path"
   (lambda (bstr)
     (let* ([str (bytes->string/latin-1 bstr)]
            [sym (string->symbol str)])
       (and (module-path? sym)
            (vector
             ;; try submod first:
             `(submod ,sym reader)
             ;; fall back to /lang/reader:
             (string->symbol (string-append str "/lang/reader"))))))
   wrap-reader ; for read
   wrap-reader ; for read-syntax
   (lambda (proc)
     (lambda (key defval)
       (define (fallback) (if proc (proc key defval) defval))
       (fallback)))))
