# Number::More
[![Build Status](https://travis-ci.org/tbrowder/Number-More-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/Number-More-Perl6)

## Synopsis

    use Number::More :ALL;
    my $bin = '11001011';   # do not enter any prefix
    my $hex = bin2hex $bin;
    say $hex; # OUTPUT: 'CB'


## The Number::More module

This module provides some convenience functions to convert unsigned
integers between different, commonly used number bases: decimal,
hexadecimal, octal, and binary. There is also a function to convert
between bases 2 through 62.

Note that bases greater than 36 will use a set of digits consisting of
a case-sensitive set of ASCII characters in an array indexed from
0..base-1, and the reverse mapping is in a hash.  Both exported
variables are shown in
[NUMBERS](https://github.com/tbrowder/Number-More-Perl6/blob/master/docs/NUMBERS.md).
Also included in that document is more information on other exported
variables, number systems (and references), and their use in this
module.

The current subroutines are described in detail in
[ALL-SUBS](https://github.com/tbrowder/Number-More-Perl6/blob/master/docs/ALL-SUBS.md)
which shows a short description of each exported routine along along
with its complete signature.

The functions in this module are recommended for users who don't want
to have to deal with the messy code involved with such transformations
and who want an easy interface to get the various results they may
need.

As an example of the detail involved, any transformation from a
non-decimal base to another non-decimal base requires an intermediate
step to convert the first non-decimal number to decimal and then
convert the decimal number to the final desired base.  In addition,
adding prefixes, changing to lower-case where appropriate, and
increasing lengths will involve more processing.

The following illustrates the process using Perl 6 routines for the
example above:

    my $bin = '11001011';
    my $dec = parse-base $bin, 2;
    my $hex = $dec.base : 16;
    say $hex; # OUTPUT 'CB'

The default for each provided function is to take a string (valid
decimals may be entered as numbers) representing a valid number in one
base and transform it into the desired base with no leading zeroes or
descriptive prefix (such as '0x', '0o', and '0b') to indicate the type
of number.  The default is also to use upper-case characters for the
hexadecimal results and all bases greater than 10 and less than 37.
Bases greater than 36 use a mixture of upper-case and lower-case
characters.

There is an optional parameter to define desired lengths of results
(which will result in adding leading zeroes if needed).  There are
named parameters to have results in lower-case (`:$LC`) for bases
between 11 and 36 and add appropriate prefixes to transformed numbers
(`:$prefix`) in bases 2 (binary), 8 (octal), and 16 (hecadecimal).
Note that requested prefixes will take up two characters in a
requested length.  There is also an option (`:$suffix`) to add the
appropriate base suffix to any number, the result of which will look
like this:

    '2Zz3_base-62'

The suffix overrides any requested prefix.

The user can also set an environment variable to set the reponse to
situations where the transformed length is greater than the requested
length: (1) ignore and provide the required length (the default), (2)
warn of the increased length but provide it, and (3) throw an
exception and report the offending data.

## Debugging

For debugging, use one of the following methods:

- set the module's $DEBUG variable:

```Perl6
$Number::More::DEBUG = True;
```

- set the environment variable:

```Perl6
NUMBER_MORE_DEBUG=1
```

## Contributing

Interested users are encouraged to contribute improvements and
corrections to this module, and pull requests, bug reports, and
suggestions are always welcome.

## Credits

Thanks to 'timotimo' on IRC **\#perl6** for the suggestion of the name
'rebase' for the general base transformation subroutine.

## LICENSE and COPYRIGHT

Artistic 2.0. See [LICENSE](https://github.com/tbrowder/Number-More-Perl6/blob/master/LICENSE).

Copyright (C) 2017 Thomas M. Browder, Jr. <<tom.browder@gmail.com>>
