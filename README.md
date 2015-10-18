hygienic-quote-lang [![Build Status](https://travis-ci.org/AlexKnauth/hygienic-quote-lang.png?branch=master)](https://travis-ci.org/AlexKnauth/hygienic-quote-lang)
===
A meta-language that overrides the `'`, `` ` ``, etc. abbreviations for `quote`, `quasiquote`, etc, and
provides hygienic versions instead.

documentation: http://pkg-build.racket-lang.org/doc/hygienic-quote/index.html

Even if you re-define `quote` somewhere in your program (either accidentally or on
purpose), `'3` will use the quote from racket/base, not your definition. The same is true
for `` ` `` as quasiquote, `,` as unquote, `,@` as unquote-splicing, `#'` as syntax, `` #` `` as
quasisyntax, `#,` as unsyntax, and `#,@` as unsyntax-splicing.

```racket
#lang hygienic-quote racket
(define (quote x) 5)
'3 ; still 3
```
