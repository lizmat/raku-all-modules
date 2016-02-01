[![Build Status](https://travis-ci.org/zoffixznet/perl6-String-Quotemeta.svg)](https://travis-ci.org/zoffixznet/perl6-String-Quotemeta)

# NAME

String::Quotemeta - Perl 5's quotemeta subroutine

# SYNOPSIS

```perl6
use String::Quotemeta;

say quotemeta 'foo$bar';

given 'foo$bar' {
    say quotemeta;
}
```

# DESCRIPTION

Implementation of Perl 5's
[quotemeta function](https://metacpan.org/pod/perlfunc).

**NOTE:** this module largely exists to assist in porting Perl 5 code. In
regular Perl 6 code, you'll likely find one of the many
[quoting constructs](http://docs.perl6.org/language/quoting) more useful.

# EXPORTED SUBROUTINES

## `quotemeta`

```perl6
say quotemeta 'foo$bar';

given 'foo$bar' {
    say quotemeta;
}
```

Escapes special characters in input. Will operate on `$_` if no arguments
are provided. See Perl 5's `perldoc -f quotemeta` for details.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-String-Quotemeta

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-String-Quotemeta/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
