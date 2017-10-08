[![Build Status](https://travis-ci.org/zoffixznet/perl6-LN.svg)](https://travis-ci.org/zoffixznet/perl6-LN)

# NAME

LN - Get `$*ARGFILES` with line numbers via `$*LN`


# SYNOPSIS

```bash
perl  -wlnE    'say "$.:$_"; close ARGV if eof' foo bar # Perl 5
perl6 -MLN -ne 'say "$*LN:$_"'                  foo bar # Perl 6
```

```bash
$ echo -e "a\nb\nc" > foo
$ echo -e "d\ne"    > bar

$ perl6 -MLN -ne 'say "$*LN:$_"' foo bar
1:a
2:b
3:c
1:d
2:e

$ perl6 -ne 'use LN "no-reset"; say "$*LN:$_"' foo bar
1:a
2:b
3:c
4:d
5:e
```

# DESCRIPTION

Mixes in
[`IO::CatHandle::AutoLines`](https://github.com/zoffixznet/perl6-IO-CatHandle-AutoLines) into
[`$*ARGFILES`](https://docs.perl6.org/language/variables#index-entry-%24%2AARGFILES)
which provides `.ln` method containing current line number of the current handle
(or total line number if `'no-reset'` option was passed to `use`). For ease
of access to that method `$*LN` dynamic variable containing its value is
available.

# EXPORTED TERMS

# `$*LN`

Contains same value as [`$*ARGFILES.ln`](https://github.com/zoffixznet/perl6-IO-CatHandle-AutoLines#synopsis)
which is a method exported by
[`IO::CatHandle::AutoLines`](https://github.com/zoffixznet/perl6-IO-CatHandle-AutoLines)
that gives the current line number of the handle.

By default, the line number will get reset on each new file in `$*ARGFILES`.
If you wish it to *not* reset, pass `"no-reset"` positional argument to the
`use` line:

```perl6
use LN 'no-reset';
```

# EXPORTED TYPES

## role `IO::CatHandle::AutoLines`

Exports [`IO::CatHandle::AutoLines`](https://github.com/zoffixznet/perl6-IO-CatHandle-AutoLines) role, for you to use, if needed.

-----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-LN

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-LN/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
