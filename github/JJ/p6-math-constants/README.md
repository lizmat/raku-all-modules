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


