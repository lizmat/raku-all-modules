# Common mathematical sequences for Perl 6

## Included components

* `Math::Sequences::Integer` - Integer sequences
  * `class Integers` - generic Integer sequences class
  * `class Naturals` - more specific finite-starting-point class
  * `ℤ` - The integers as a range
  * `𝕀` - The naturals (from 0) as a range
  * `ℕ` - The naturals (from 1) as a range
  * `@AXXXXXX` - All of the core OEIS sequences from
    http://oeis.org/wiki/Index_to_OEIS:_Section_Cor
* `Math::Sequences::Real` - Real sequences
  * `class Reals` - generic Real number sequences class
  * `ℝ` - The reals as a range

## Support routines

These routines and operators are defined to support the definition
of the sequences. Because they're not the primary focus of this
library, they may be moved out into some extrnal library in the
future...

### Integer support routines

To gain access to these, use:

    use Math::Sequences::Integer :support;

* `$a choose $b`
  The choose and ichoose (for integer-only results) infix operators
  return the binomial coefficient on the inputs.
* `binpart($n)`
  The binary partitions of n.
* `factorial($n)`
  The factorial of n.
* `factors($n, :%map)`
  The prime factors (non-unique) of n. Takes an optional map of
  inputs to results, mostly used to deal with the ambiguous factors
  of 0 and 1.
* `divisors($n)`
  The unique list of whole divisors of n. e.g. `divisors(6)` gives
  `(1, 2, 3, 6)`.
* `sigma($n, $exponent=1)`
  The sum of positive divisors function σ. The optional exponent is
  the power to which each divisor is raised before summing.
* `planar-partitions($n)`
  The planar partitions of n. http://mathworld.wolfram.com/PlanePartition.html
* `Pi-digits`
  A generator of digits for pi. Relatively fast and very memory-efficient.
* `FatPi($digits=100)`
  This function is certainly going to be moved out of this library at some
  point, as it is not used here and doesn't return an integer, but it's
  a simple wrapper around Pi-digits which returns a `FatRat` rational
  for pi to the given number of digits. e.g. `FatPi(17).nude` gives:
  `(7853981633974483 2500000000000000)`.

##About Unicode

This library used a few non-ASCII unicode characters that are widely used
within the mathematical community. They are entirely optional, however, and
if you wish to use their ASCII equivalents, this table will help you out:

(the following assume `use Math::Sequences::Integer; use Math::Sequences::Real;`)

* `ℤ` - `Integers.new`
* `𝕀` - `Naturals.new.from(0)` or simply `Naturals.new`
* `ℕ` - `Naturals.new.from(1)`
* `ℝ` - `Reals.new`

### Entering symbols

To enter each of these symbols, however, here are common shortcuts in vim and emacs:

* `ℤ` - DOUBLE-STRUCK CAPITAL Z - U+2124
  * vim - Ctrl-v u 2 1 2 4
  * emacs - Ctrl-x 8 `<enter>` 2 1 2 4 `<enter>`
* `𝕀` - MATHEMATICAL DOUBLE-STRUCK CAPITAL I - U+1D540
  * vim - Ctrl-v U 0 0 0 1 d 5 4 0
  * emacs - Ctrl-x 8 `<enter>` 1 d 5 4 0 `<enter>`
* `ℕ` - DOUBLE-STRUCK CAPITAL N - U+2115
  * vim - Ctrl-v u 2 1 1 5
  * emacs - Ctrl-x 8 `<enter>` 2 1 1 5 `<enter>`
* `ℝ` - DOUBLE-STRUCK CAPITAL R - U+211D
  * vim - Ctrl-v u 2 1 1 d
  * emacs - Ctrl-x 8 `<enter>` 2 1 1 d `<enter>`
