TrigPi
======
[![Build Status](https://travis-ci.org/grondilu/trigpi.svg)](https://travis-ci.org/grondilu/trigpi)

This modules implements `cosPi`, `sinPi` and `cisPi` as mentioned in [IEEE
954](https://www.csee.umbc.edu/~tsimo1/CMSC455/IEEE-754-2008.pdf).

`cosPi($x)`, `sinPi($x)` and `cisPi($x)`
are designed to be more accurate values of
`cos($x*pi)`, `sin($x*pi)` and `cis($x*pi)` respectively,
especially for large values of `$x`.
