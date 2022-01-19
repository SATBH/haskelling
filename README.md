# Haskelling
Small, Opinionated, Haskell-inspired,  Common Lisp library for writing functional Code.

## Goals
- Provide a more succint way of declaring anonymous functions
through reader macros.
```lisp
$(x -> (+ 5 x))
;; (lambda (x) (progn (+ 5 x)))
```
- Partial application reader macro
```lisp
 (assert (equal (mapcar #!(+ 1) '(1 2)) '(2 3)))
```
- Macro implementation of Haskell's "do notation".
```lisp
  (with-monad 'list-monad
    (-do- x <- '(1 2)
          (unit x)))
```
- Support for Applicative
- Support for Monoids
- Support for Functors
