# Haskelling
Opinionated, Haskell-inspired,  Common Lisp library for writing functional Code.

## Goals
- Provide a more succint way of declaring anonymous functions
through reader macros.
> (assert (equal '$(x -> x) '(lambda (x) x)))
- Partial application reader macro
> (assert (equal (mapcar !(+ 1) '(1 2)) '(2 3)))
- Haskell's "do notation" and support for Monads
>  (with-monad 'list-monad
>    (-do- x <- '(1 2)
>          (unit x)))
- Support for Applicative
- Support for Monoids
- Support for Functors
