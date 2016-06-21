#lang racket/base

(provide (rename-out [hygienic-quote-read read]
                     [hygienic-quote-read-syntax read-syntax]
                     [hygienic-quote-get-info get-info]))

(require (only-in syntax/module-reader make-meta-reader)
         (only-in lang-extension/meta-reader-util lang-reader-module-paths)
         (only-in "../reader.rkt" wrap-reader))

(define-values (hygienic-quote-read hygienic-quote-read-syntax hygienic-quote-get-info)
  (make-meta-reader
   'hygienic-quote
   "language path"
   lang-reader-module-paths
   wrap-reader ; for read
   wrap-reader ; for read-syntax
   (λ (get-info) get-info)))
