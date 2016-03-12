[![Build Status](https://travis-ci.org/okaoka/p6-Algorithm-ZobristHashing.svg?branch=master)](https://travis-ci.org/okaoka/p6-Algorithm-ZobristHashing)

NAME
====

Algorithm::ZobristHashing - a hash function for board games

SYNOPSIS
========

    use Algorithm::ZobristHashing;

    # the case input is Str
    my $zobrist = Algorithm::ZobristHashing.new();
    my $status = $zobrist.encode("Perl6 is fun");
    my $code = $zobrist.get(0,"P"); # Int value which represents state h(0,"P")
    my $code = $zobrist.get(5," "); # Int value which represents state h(5," ")

    # the case input is Array
    my $zobrist = Algorithm::ZobristHashing.new();
    my $status = $zobrist.encode([["Perl6"],["is"],["fun"]]);
    my $code = $zobrist.get(0,"Perl6"); # Int value which represents state h(0,"Perl6")

DESCRIPTION
===========

Algorithm::ZobristHashing is a hash function for board games such as chess, GO, GO-MOKU, tic-tac-toe, and so on. 

CONSTRUCTOR
-----------

### new

    my $zobrist = Algorithm::ZobristHashing.new(%options);

#### OPTIONS

  * `max-rand => $max-rand`

Sets the upper bound number for generating random number. Default is 1e9.

METHODS
-------

### encode(Str|Array)

    my $status = $zobrist.encode("abc"); # h(0,"a") xor h(1,"b") xor h(2,"c")
    my $status = $zobrist.encode([["a"],["b"],["c"]]); # h(0,"a") xor h(1,"b") xor h(2,"c")
    my $status = $zobrist.encode([["ab"],["c"]]); # h(0,"ab") xor h(1,"c")

Returns the hash value which represents the status of the input sequence. If the input value is the nested array, it flattens this and handles as a 1-dimensional array. If the input value is empty, it returns the type object Int.

### get(Int $position, Str $type)

    my $status = $zobrist.encode(["abc"]);
    my $code = $zobrist.get(0,"abc"); # in this case $code == $status
    my $new-code = $zobrist.get(0,"perl"); # assigns a new rand value, since h(0,"perl") is not yet encoded

Returns the Int value which represents the state(i.e position-type pair). If it intends to get the state not yet encoded, it assigns a new rand value to the state and returns this new value.

AUTHOR
======

okaoka <cookbook_000@yahoo.co.jp>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 okaoka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from Zobrist, Albert L. "A new hashing method with application for game playing." ICCA journal 13.2 (1970): 69-73.
