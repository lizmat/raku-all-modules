[![Build Status](https://travis-ci.org/hartenfels/Javascript-SpiderMonkey.svg)](https://travis-ci.org/hartenfels/Javascript-SpiderMonkey)

NAME
====

JavaScript::SpiderMonkey - glue for Mozilla's JavaScript interpreter

SYNOPSIS
========

This is still really hard in development you don't even know, so this interface is still in flux.

    use JavaScript::SpiderMonkey;

    my $thing = js-eval('({
        add : function(a, b) { return a + b; },
    })')

    say $thing.add( 1,   2 ); # 3
    say $thing.add('1', '2'); # 12

TODO
====

  * Nicer errors

  * Implement console.log and friends

  * Use LibraryMake and compile this sanely

  * Write more tests

  * Test multiple SpiderMonkey versions

  * Calling JavaScript from Perl6:

  * → Also allow calling things on the global object

  * → Convert hashes and arrays

  * Writing to JavaScript object and array elements

  * Call Perl6 from JavaScript somehow (https://github.com/jnthn/zavolaj#function-arguments)

  * Add documentation

AUTHOR
======

[Carsten Hartenfels](mailto:carsten.hartenfels@googlemail.com)

COPYRIGHT AND LICENSE
=====================

This software is copyright (c) 2015 by Carsten Hartenfels. This program is distributed under the terms of the Artistic License 2.0. For further information, please see LICENSE or visit <http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt>.
