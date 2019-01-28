[![Build Status](https://travis-ci.org/lizmat/P5substr.svg?branch=master)](https://travis-ci.org/lizmat/P5substr)

NAME
====

P5substr - Implement Perl 5's substr() built-in

SYNOPSIS
========

    use P5substr; # exports substr()

    say substr("foobar",3);   # bar
    say substr("foobar",1,4); # ooba

    my $a = "foobar";
    substr($a,1,2) = "OO";
    say $a;                   # fOObar

DESCRIPTION
===========

This module tries to mimic the behaviour of the `substr` function of Perl 5 as closely as possible.

ORIGINAL PERL 5 DOCUMENTATION
=============================

    substr EXPR,OFFSET,LENGTH,REPLACEMENT
    substr EXPR,OFFSET,LENGTH
    substr EXPR,OFFSET
            Extracts a substring out of EXPR and returns it. First character
            is at offset zero. If OFFSET is negative, starts that far back
            from the end of the string. If LENGTH is omitted, returns
            everything through the end of the string. If LENGTH is negative,
            leaves that many characters off the end of the string.

                my $s = "The black cat climbed the green tree";
                my $color  = substr $s, 4, 5;      # black
                my $middle = substr $s, 4, -11;    # black cat climbed the
                my $end    = substr $s, 14;        # climbed the green tree
                my $tail   = substr $s, -4;        # tree
                my $z      = substr $s, -4, 2;     # tr

            You can use the substr() function as an lvalue, in which case EXPR
            must itself be an lvalue. If you assign something shorter than
            LENGTH, the string will shrink, and if you assign something longer
            than LENGTH, the string will grow to accommodate it. To keep the
            string the same length, you may need to pad or chop your value
            using "sprintf".

            If OFFSET and LENGTH specify a substring that is partly outside
            the string, only the part within the string is returned. If the
            substring is beyond either end of the string, substr() returns the
            undefined value and produces a warning. When used as an lvalue,
            specifying a substring that is entirely outside the string raises
            an exception. Here's an example showing the behavior for boundary
            cases:

                my $name = 'fred';
                substr($name, 4) = 'dy';         # $name is now 'freddy'
                my $null = substr $name, 6, 2;   # returns "" (no warning)
                my $oops = substr $name, 7;      # returns undef, with warning
                substr($name, 7) = 'gap';        # raises an exception

            An alternative to using substr() as an lvalue is to specify the
            replacement string as the 4th argument. This allows you to replace
            parts of the EXPR and return what was there before in one
            operation, just as you can with splice().

                my $s = "The black cat climbed the green tree";
                my $z = substr $s, 14, 7, "jumped from";    # climbed
                # $s is now "The black cat jumped from the green tree"

            Note that the lvalue returned by the three-argument version of
            substr() acts as a 'magic bullet'; each time it is assigned to, it
            remembers which part of the original string is being modified; for
            example:

                $x = '1234';
                for (substr($x,1,2)) {
                    $_ = 'a';   print $x,"\n";    # prints 1a4
                    $_ = 'xyz'; print $x,"\n";    # prints 1xyz4
                    $x = '56789';
                    $_ = 'pq';  print $x,"\n";    # prints 5pq9
                }

            With negative offsets, it remembers its position from the end of
            the string when the target string is modified:

                $x = '1234';
                for (substr($x, -3, 2)) {
                    $_ = 'a';   print $x,"\n";    # prints 1a4, as above
                    $x = 'abcdefg';
                    print $_,"\n";                # prints f
                }

            Prior to Perl version 5.10, the result of using an lvalue multiple
            times was unspecified. Prior to 5.16, the result with negative
            offsets was unspecified.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5substr . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

