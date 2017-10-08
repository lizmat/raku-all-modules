[![Build Status](https://travis-ci.org/tokuhirom/p6-Test-Base.svg?branch=master)](https://travis-ci.org/tokuhirom/p6-Test-Base)

NAME
====

Test::Base - Data driven development for Perl6

SYNOPSIS
========

        use v6;
        use Test;

        use Test::Base;

        for blocks($=finish) {
            is EVAL($_<input>), .expected;
        }

        done-testing;

        =finish

        === simple
        --- input: 3+2
        --- expected: 5

        === more
        --- input: 4+2
        --- expected: 6

DESCRIPTION
===========

Test::Base is a port of ingy's perl5 Test::Base for Perl6.

FUNCTIONS
=========

  * `blocks(Str $src)`

Parse `$src` as a data source and returns test data.

AUTHOR
======

Tokuhiro Matsuno <tokuhirom@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2015 Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
