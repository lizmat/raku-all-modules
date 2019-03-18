NAME
====

BitEnum -- Wrapper for Bitfields stored in an integer

SYNOPSIS
========

    use BitEnum;

    my enum MyBits (
      A => 0x01,
      B => 0x02,
      C => 0x04,
      D => 0x08,
    );

    my $x = BitEnum[MyBits].new(6);      # Pass in an integer
                                         # or
    my $x = BitEnum[MyBits].new(B,C);    # flags to set
                                         # or
    my $x = BitEnum[MyBits].new;         # nothing defaults to 0

    put $x;                              # Stringify to list of keys
    # B C                                # could also get "C B"

    put +$x;                             # Numify to value
    # 6

    say $x;                              # gistify to value and list
    6 = B C                              # or '6 = C B'

    $x.set(A,B);                         # Set bits

    $x.clear(B);                         # Clear bits

    say $x.isset(A,B);                   # Check if all listed bits are set
    # False

    $x.toggle(C);                        # Flip bits

    .key.say for @$x;                    # listify

DESCRIPTION
===========

Especially when interfacing with Nativecall libraries, various flags are often packed into an integer. Helpful library developers thoughfully provide various SET(), CLEAR(), ISSET(), etc. macros to perform the bit manipulations for C programmers. This module makes it easy to wrap an Enumeration of bit field values with a parameterized role that make it easy to perform the bit manipulations and human display for such values from Perl 6.

Printing as a string or gist make it easy to see which bits are set, and numifying and Int-ifying make it easy to pass in to routines that just want the value.

COMBO keys
----------

Sometimes libraries have convenience values that have multiple bits set. Those will work fine too. You can handle them in one of two ways.

Just put them into the enumeration like normal:

    my enum MyBits (
        A => 0x01,
        B => 0x02,
        C => 0x04,
        D => 0x08,
        AB => 0x03,
        BC => 0x06,
    );

    my $x = BitEnum[MyBits].new(6);

    say $x;

    # 6 = B C BC

    $x.set(AB, C);

    say $x;

    # 7 = AB BC A B C

or

Put them in their own, separate enumeration. They won't show up in the stringification, but you can still use them to set/clear/etc. combinations of bits.

    my enum MyBits (
        A => 0x01,
        B => 0x02,
        C => 0x04,
        D => 0x08,
    );

    my enum Combos (
        AB => 0x03,
        BC => 0x06,
    );

    my $x = BitEnum[MyBits].new(6);

    say $x;

    # 6 = B C

    $x.set(AB, C);

    say $x;

    # 7 = A B C

COPYRIGHT and LICENSE
=====================

Copyright 2019 Curt Tilmes

This module is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

