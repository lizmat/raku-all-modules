[![Build Status](https://travis-ci.org/zoffixznet/perl6-Subsets-IO.svg)](https://travis-ci.org/zoffixznet/perl6-Subsets-IO)

# NAME

`Subsets::IO` - Subsets for various types of `IO::Path` instances

# SYNOPSIS

```perl-6
use Subsets::IO :frw;

say "Our script is writable and readable"
    if $?FILE.IO ~~ IO::Path::frw;
```

```perl-6
use Subsets::IO; # export all available subsets

sub make-conf($conf where IO::Path::dw | IO::Path::fw) {
    say "$conf is either a writable directory or a writable file";
}

sub make-conf-file(IO::Path::E $conf) {
    say "$conf is a non-existent path";
}
make-conf-file $?FILE.IO;
# Path must NOT exist Got /home/zoffix/CPANPRC/Subsets-IO/foo.p6
# Constraint type check failed in binding to parameter '$conf';
#   expected IO::Path::E but got IO::Path (IO::Path.new("/home/z...)
```

# DESCRIPTION

The module provides subsets of
[`IO::Path:D`](https://docs.perl6.org/type/IO::Path) that additionally perform
file tests and use
[`Subset::Helper`](https://modules.perl6.org/dist/Subset::Helper) to dispay
useful error messages on typecheck failure.

# IMPORTING

By default, all subsets are imported. You can specify tags that match the name
of the subsets you want to import only those subsets. For example, to import
only `IO::Path::E` and `IO::Path::frw`, use:

```perl-6
    use Subsets::IO :E, :frw;
```

# AVAILABLE SUBSETS

## `IO::Path::e`

Path must exist.

## `IO::Path::E`

Path must NOT exist.

## `IO::Path::f`

Path must be an existing file.

## `IO::Path::F`

Path must NOT be an existing file.

## `IO::Path::d`

Path must be an existing directory.

## `IO::Path::D`

Path must NOT be an existing directory.

## `IO::Path::fr`

Path must be an existing, readable file.

## `IO::Path::frw`

Path must be an existing, readable and writable file.

## `IO::Path::frx`

Path must be an existing, readable and executable file.

## `IO::Path::fwx`

Path must be an existing, writeable and executable file.

## `IO::Path::frwx`

Path must be an existing, readable, writable, and executable file.

## `IO::Path::dr`

Path must be an existing, readable directory.

## `IO::Path::drw`

Path must be an existing, readable and writable directory.

## `IO::Path::drx`

Path must be an existing, readable and executable directory.

## `IO::Path::dwx`

Path must be an existing, writeable and executable directory.

## `IO::Path::drwx`

Path must be an existing, readable, writable, and executable directory.

# BUGS AND LIMITATIONS

* Due to [R#1458](https://github.com/rakudo/rakudo/issues/1458), all symbols
are currently exported all the time, even if specific tags are specified.

* On typecheck failure, the error message is printed twice, due to how Rakudo's
    fast and slow-path binding works. If you know a good solution to that,
    submit a PR to
    [`Subset::Helper`](https://modules.perl6.org/dist/Subset::Helper)

-----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Subsets-IO

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Subsets-IO/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
