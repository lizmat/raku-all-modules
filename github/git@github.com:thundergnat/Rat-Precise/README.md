NAME
====

Rat::Precise

SYNOPSIS
========

Stringify Rats to a configurable precision.

Provides a Rational method .precise. Pass in a positive integer to set places of precision. Pass in a boolean flag :z to preserve trailing zeros.

    use Rat::Precise;

    my $rat = 2213445/437231;

    say $rat;                 # 5.0624155
    say $rat.precise;         # 5.0624155194851234
    say $rat.FatRat.precise;  # 5.06241551948512342445983930691099
    say $rat.precise(37);     # 5.06241551948512342445983930691099213
    say $rat.precise(37, :z); # 5.0624155194851234244598393069109921300
    say $rat.precise(0);      # 5

    # terminating Rats
    say (1.5**63).Str;     # 124093581919.64894769782737365038
    say (1.5**63).precise; # 124093581919.648947697827373650380188008224280338254175148904323577880859375

DESCRIPTION
===========

The default Rat stringification routines are a fairly conservative tradeoff between speed and precision. This module shifts hard to the precision side at the expense of speed.

Augments Rat and FatRat classes with a .precise method. Stringifies configurably to a more precise representation than default .Str methods.

The .precise method can accept two parameters. A positive integer to specify the number of places of precision after the decimal, and/or a boolean flag to control whether non-significant zeros are trimmed.

In base 10, Rational fractions with denominators that are a power of 2 or 5 will terminate.

By default, the precise method stringifies terminating fractions completely. If the fraction is non-terminating, Rats return at least 16 places of precision, FatRats return at least 32 places. Any trailing zeros are trimmed.

If an integer parameter is passed, the fractional portion will be calculated to that many digits, but may have non-significant digits trimmed. The integer must be non negative. Negative integers will be ignored. It can be zero, and it will return zero fractional digits, but it would be much more efficient to just Int the Rat.

If a :z flag is passed, trailing (non-significant) zeros will be preserved.

Parameters can be in any order and combination.

Note that the .precise method only affects stringification. It doesn't change the internal representations of the Rationals, nor does it make calculations any more precise. It is merely a shortcut to express Rational strings to a configurable specified precision.

The :z flag is mostly intended to be used in combination with a digits parameter. It may be used on its own, but may return slightly non-intuitive results. In order to save unnecessary calculations (and speed up the overall process) the .precise method only checks for terminating fractions that multiples of 2 & 5 less than 10. To avoid lots of pointless checks and general slowdown, any terminating fraction that is a multiple of 10 or above will be calculated out to the default precision (16 digits for Rats, 32 for FatRats or the number of characters in the denominator if that is greater) since it will terminate within that precision.

The point is, if you want to keep trailing zeros, you are better off specifying digits of precision also.

AUTHOR
======

2018 Steve Schulze aka thundergnat

This package is free software and is provided "as is" without express or implied warranty. You can redistribute it and/or modify it under the same terms as Perl itself.

LICENSE
=======

Licensed under The Artistic 2.0; see LICENSE.

