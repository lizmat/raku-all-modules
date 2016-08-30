[![Build Status](https://travis-ci.org/zoffixznet/perl6-SPEC-Func.svg)](https://travis-ci.org/zoffixznet/perl6-SPEC-Func)

# NAME

SPEC::Func - Import `$*SPEC` methods as functions

# SYNOPSIS

```perl6
    use lib <lib>;
    use SPEC::Func <dir-sep splitdir>;
    say join dir-sep, map &flip, splitdir 'foo/bar/ber';

    # OUTPUT:
    # oof/rab/reb
```

# EXPORTS

```perl6
    use SPEC::Func <dir-sep splitdir>; # export dir-sep and splitdir
```

Specify the subs you want to import on the `use` line.

# AVAILABLE SUBS

```perl6
canonpath dir-sep curdir updir curupdir rootdir devnull basename extension
tmpdir is-absolute path splitpath join catpath catdir splitdir catfile
abs2rel rel2abs split select
```

At the time of this writing, the above subroutines can be exported, however,
the actual list is derived directly from the methods provided by `$*SPEC`.

---

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-SPEC-Func

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-SPEC-Func/issues

#### AUTHOR

Zoffix Znet (http://zoffix.com/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
