[![Build Status](https://travis-ci.org/titsuki/p6-Text-Sift4.svg?branch=master)](https://travis-ci.org/titsuki/p6-Text-Sift4)

NAME
====

Text::Sift4 - A Perl 6 Sift4 (Super Fast and Accurate string distance algorithm) implementation

SYNOPSIS
========

    use Text::Sift4;

    say sift4("abc", "ab");  # OUTPUT: «1␤»
    say sift4("ab", "abc");  # OUTPUT: «1␤»
    say sift4("abc", "xxx"); # OUTPUT: «3␤»

DESCRIPTION
===========

Text::Sift4 is a Perl 6 Sift4 implementation. Sift4 computes approximate results of Levenshtein Distance.

METHODS
=======

sift4
-----

Defined as:

    sub sift4(Str $lhs, Str $rhs, Int :$max-offset = 5 --> Int:D) is export

returns approximation of Levenshtein Distance.

  * Str `$lhs` is one side of the strings to compare.

  * Str `$rhs` is one side of the strings to compare.

  * Int `:$max-offset` is the maximum offset value. The value is default to 5.

AUTHOR
======

Itsuki Toyota <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Itsuki Toyota

Sift4 Algorithm was invented by Siderite, and is from: https://siderite.blogspot.com/2014/11/super-fast-and-accurate-string-distance.html

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

