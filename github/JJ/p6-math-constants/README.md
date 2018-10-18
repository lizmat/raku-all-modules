Math::Constants
====

Math::Constants - A few constants defined in Perl6

SYNOPSIS
========

	#!/usr/bin/env perl6
	
	use v6;
    use Math::Constants;

	say "We have ", phi, " ", plancks-h, " ",  plancks-reduced-h, " ", 
	    c, " ", G, " and ", fine-structure-constant, " plus ",
	    elementary-charge, " and ", vacuum-permittivity ;
		
	say "And also  φ ", φ, " α ", α,  " ℎ ",  ℎ, " and ℏ ", ℏ,
	    " with e ", e, " and ε0 ", ε0;

	say "We are flying at speed ", .1c;

DESCRIPTION
===========

Math::Constants is a collection of Math and Physics constants that
will save you the trouble of defining them.

## Constants included

* [Gravitational constant](https://en.wikipedia.org/wiki/Gravitational_constant) as `G`.
* [Speed of light](https://en.wikipedia.org/wiki/Speed_of_light) as `c`. It works also as a suffix for expressing speeds, as in `3c` for 3 times the speed of light. 
* [Planck constant and reduced constant](https://en.wikipedia.org/wiki/Planck_constant)
in J/s
as `plancks-h` or `ℎ` and `plancks-reduced-h` or `ℏ`.
* [Golden ratio](https://en.wikipedia.org/wiki/Golden_ratio) as `phi`
  or φ.
* Several electronic constants: [α](https://en.wikipedia.org/wiki/Fine-structure_constant) and the elementary charge and vacuum permittivity. 
* [Feigenbaum constants](https://en.wikipedia.org/wiki/Feigenbaum_constants) as `alpha-feigenbaum-constant` and `delta-feigenbaum-constant`.
* [Apéry's constant](https://en.wikipedia.org/wiki/Ap%C3%A9ry%27s_constant) as `apery-constant`.
* [Conway's constant](https://en.wikipedia.org/wiki/Look-and-say_sequence#Growth_in_length) as `conway-constant` and `λ`.
* [Khinchin's constant](https://en.wikipedia.org/wiki/Khinchin%27s_constant) as `khinchin-constant` and `k0`.
* [Glaisher–Kinkelin constant](https://en.wikipedia.org/wiki/Glaisher%E2%80%93Kinkelin_constant) as `glaisher-kinkelin-constant` and `A`.
* [Golomb–Dickman constant](https://en.wikipedia.org/wiki/Golomb%E2%80%93Dickman_constant) as `golomb-dickman-constant`. 
* [Catalan's constant](https://en.wikipedia.org/wiki/Catalan%27s_constant) as `catalan-constant`. 
* [Mill's constant](https://en.wikipedia.org/wiki/Mills%27_constant) as `mill-constant`. 
* [Gauss's constant](https://en.wikipedia.org/wiki/Gauss%27s_constant) as `gauss-constant`. 
* [Euler–Mascheroni constant](https://en.wikipedia.org/wiki/Euler%E2%80%93Mascheroni_constant) as `euler-mascheroni-gamma` and `γ`. 
* [Sierpiński's constant](https://en.wikipedia.org/wiki/Sierpi%C5%84ski%27s_constant) as `sierpinski-gamma` and `k`. 

Issues and suggestions
======================

Please post them [in GitHub](https://github.com/JJ/p6-math-constants/issues). Pull requests are also welcome.

AUTHOR
======

JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 JJ Merelo

This library is free software; you can redistribute it and/or modify
it under the GPL 3.0.


