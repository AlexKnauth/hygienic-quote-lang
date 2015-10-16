#lang scribble/manual

@(require (for-label racket/base))

@title{hygienic-quote}

@defmodule[hygienic-quote #:lang]{
A meta-language that overrides the @litchar{'}, @litchar{`}, etc. abbreviations
for @racket[quote], @racket[quasiquote], etc, and provides hygienic versions
instead.

Even if you re-define @racketvarfont{quote} somewhere in your program (either
accidentally or on purpose), @racket['3] will use the @racket[quote] from
@racketmodname[racket/base], not your definition. The same is true for
@litchar{`} as @racket[quasiquote], @litchar{,} as @racket[unquote],
@litchar|{,@}| as @racket[unquote-splicing], @litchar{#'} as @racket[syntax],
@litchar{#`} as @racket[quasisyntax], @litchar{#,} as @racket[unsyntax], and
@litchar|{#,@}| as @racket[unsyntax-splicing].

@codeblock|{
#lang hygienic-quote racket
(define (quote x) 5)
'3 ; still 3
}|}
