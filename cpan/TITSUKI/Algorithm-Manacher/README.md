[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-Manacher.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-Manacher)

NAME
====

Algorithm::Manacher - a perl6 implementation of the extended Manacher's Algorithm for solving longest palindromic substring(i.e. palindrome) problem

SYNOPSIS
========

    use Algorithm::Manacher;

    # "たけやぶやけた" is one of the most famous palindromes in Japan.
    # It means "The bamboo grove was destroyed by a fire." in English.
    my $manacher = Algorithm::Manacher.new(text => "たけやぶやけた");
    $manacher.is-palindrome(); # True
    $manacher.find-longest-palindrome(); # {"たけやぶやけた" => [0]};
    $manacher.find-all-palindrome(); # {"た" => [0, 6], "け" => [1, 5], "や" => [2, 4], "たけやぶやけた" => [0]}

DESCRIPTION
===========

Algorithm::Manacher is a perl6 implementation of the extended Manacher's Algorithm for solving longest palindromic substring problem. A palindrome is a sequence which can be read same from left to right and right to left. In the original Manacher's paper [0], his algorithm has some limitations(e.g. couldn't handle a text of even length). Therefore this module employs the extended Manacher's Algorithm in [1], it enables to handle a text of both even and odd length, and compute all palindromes in a given text.

CONSTRUCTOR
-----------

    my $manacher = Algorithm::Manacher.new(text => $text);

METHODS
-------

### find-all-palindrome

    Algorithm::Manacher.new(text => "たけやぶやけた").find-all-palindrome(); # {"た" => [0, 6], "け" => [1, 5], "や" => [2, 4], "たけやぶやけた" => [0]}

Finds all palindromes in a text and returns a hash containing key/value pairs, where key is a palindromic substring and value is an array of its starting positions. If there are multiple palindromes that share the same point of symmetry, it remains the longest one.

### is-palindrome

    Algorithm::Manacher.new(text => "たけやぶやけた").is-palindrome(); # True
    Algorithm::Manacher.new(text => "たけやぶやけたわ").is-palindrome(); # False
    Algorithm::Manacher.new(text => "Perl6").is-palindrome(); # False

Returns whether a given text is a palindrome or not.

### find-longest-palindrome

    Algorithm::Manacher.new(text => "たけやぶやけた").find-longest-palindrome(); # {"たけやぶやけた" => [0]};
    Algorithm::Manacher.new(text => "たけやぶやけた。、だんしがしんだ").find-longest-palindrome(), {"たけやぶやけた" => [0], "だんしがしんだ" => [9]};

Returns the longest palindrome. If there are many candidates, it returns all of them.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from

  * [0] Manacher, Glenn. "A New Linear-Time``On-Line''Algorithm for Finding the Smallest Initial Palindrome of a String." Journal of the ACM (JACM) 22.3 (1975): 346-351.

  * [1] Tomohiro, I., et al. "Counting and verifying maximal palindromes." String Processing and Information Retrieval. Springer Berlin Heidelberg, 2010.

