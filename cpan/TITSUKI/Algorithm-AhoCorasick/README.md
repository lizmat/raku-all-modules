[![Build Status](https://travis-ci.org/titsuki/p6-Algorithm-AhoCorasick.svg?branch=master)](https://travis-ci.org/titsuki/p6-Algorithm-AhoCorasick)

NAME
====

Algorithm::AhoCorasick - A Perl 6 Aho-Corasick dictionary matching algorithm implementation

SYNOPSIS
========

    use Algorithm::AhoCorasick;
    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => ['corasick','sick','algorithm','happy']);
    my $matched = $aho-corasick.match('aho-corasick was invented in 1975'); # set("corasick","sick")
    my $located = $aho-corasick.locate('aho-corasick was invented in 1975'); # {"corasick" => [4], "sick" => [8]}

DESCRIPTION
===========

Algorithm::AhoCorasick is a implmentation of the Aho-Corasick algorithm (1975). It constructs the finite state machine from a list of keywords offline. By the finite state machine, it can find the keywords within an input text online.

CONSTRUCTOR
-----------

### new

    my Algorithm::AhoCorasick $aho-corasick .= new(keywords => @keyword-list);

Constructs a new finite state machine from a list of keywords.

METHODS
-------

### match

    my $matched = $aho-corasick.match($text);

Returns elements of a finite set of strings within an input text.

### locate

    my $located = $aho-corasick.locate($text);

Returns elements of a finite set of strings within an input text where each string contains the locations in which it appeared.

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from Alfred V. Aho and Margaret J. Corasick, Efficient string matching: an aid to bibliographic search, CACM, 18(6):333-340, June 1975.

