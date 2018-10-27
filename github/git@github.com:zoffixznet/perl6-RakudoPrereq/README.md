[![Build Status](https://travis-ci.org/zoffixznet/perl6-RakudoPrereq.svg)](https://travis-ci.org/zoffixznet/perl6-RakudoPrereq)

# NAME

RakudoPrereq - Specify minimum required versions of Rakudo

# SYNOPSIS

```perl6
    use RakudoPrereq v2017.04; # specify minimum Rakudo version 2017.04

    # specify minimum Rakudo version 2017.04, with custom message
    # when user's Rakudo is too old
    use RakudoPrereq v2017.04, 'Your Perl 6 is way too old, bruh!';

    # specify minimum Rakudo version 2017.04, use default message and die
    # when non-Rakudo compiler is used
    use RakudoPrereq v2017.04, '', 'rakudo-only';

    # specify minimum Rakudo version 2017.04, use custom message and die
    # when non-Rakudo compiler is used
    use RakudoPrereq v2017.04, 'your compiler is no good', 'rakudo-only';

    # specify minimum Rakudo version 2017.04, use default message and die
    # when non-Rakudo compiler is used and don't print location of `use`
    use RakudoPrereq v2017.04, '', 'rakudo-only no-where';
```

# DESCRIPTION

Need to black-list non-Rakudo compilers or some Rakudo versions that implement
the same language version? This module is for you!

If the program is run on a Rakudo that's too old, the module will print a
message and exit with status `1`

# USAGE

The entire API is via the arguments specified on the `use RakudoPrereq` line.

- **Minimum Rakudo version:** The first argument is required and is the
  [`Version`](https://docs.perl6.org/type/Version)
  object specifying the minimum required Rakudo version.
- **Custom message:** by default, the module will print a generic message
  before exiting, you can specify a custom message here. Default message will
  be printed if the specified custom message is an empty string
- **String with options:** space-separated string of options
  - `rakudo-only` - by default, the module would not fail if the compiler
    is not Rakudo. Specify this option if you want to fail for non-Rakudo
    compilers as well, regardless of their version.
  - `no-where` - both the default and custom message will have the location
    of where the `use RakudoPrereq` that caused failure is at. Specify this
    argument if you want to surpress that information.

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-RakudoPrereq

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-RakudoPrereq/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
