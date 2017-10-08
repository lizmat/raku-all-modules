[![Build Status](https://travis-ci.org/zoffixznet/perl6-Die.svg)](https://travis-ci.org/zoffixznet/perl6-Die)

# NAME

Die - Perl 5 like die routine for note + exit

# SYNOPSIS

```perl6
    use Die;

    die "I don't like you, bruh\n"; # new line at the end == no stack trace
    die "something looks broken";   # no new line at end == stack trace
    die X::SomeShinyException.new;  # this still works like normal
```

# DESCRIPTION

Perl 6 avoids many magics prevalent in Perl 5 land, among which is automatically
omitting the stack trace if the `&die` routine is given a string with a new
line at the end.

In Perl 6, you do the same with `note "foo" and exit 1`... or use this shiny
module that adds Perl 5 behaviour to `&die`

# EXPORTS

## `&die`

```perl6
    die "I don't like you, bruh\n"; # new line at the end == no stack trace
    die "something looks broken";   # no new line at end == full stack trace
    die X::SomeShinyException.new;  # this still works like normal
```

Works just like core `&die` except stack trace will be omitted if you
include a newline at the end of the die message.

Note that Perl 5's `&die` exits with status `255`, while core Perl 6 `&die` and
this module's `&die` exit with status `1`.

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Die

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Die/issues

#### AUTHOR

Zoffix Znet (https://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
