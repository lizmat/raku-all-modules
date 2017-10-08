[![Build Status](https://travis-ci.org/zoffixznet/perl6-Trait-IO.svg)](https://travis-ci.org/zoffixznet/perl6-Trait-IO)

# NAME

Trait::IO - Helper IO traits

# SYNOPSIS

```perl6
    use Trait::IO;

    for <a b c> {
        my $fh does auto-close = .IO.open: :w;
        # ... do things with the file handle
        # $fh is auto-closed on block leave
    }
    
    # Top-level is OK too; will close on scope leave
    my $fh does auto-close = "foo".IO.open: :w;
    # ...
```

# DESCRIPTION

Useful traits for working with Perl 6 IO.

# EXPORTS

## `does` `auto-close`

    my $fh does auto-close = "foo".IO.open: :w;

Installs a `LEAVE` phaser to automatically close the file handle when scope
is left.

Exports the `auto-close` constant and the `trait_mod:<does>` multi that
accepts it as a value.

Currently works only with variables and not with attributes or parameters.
Patches welcome.

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Trait-IO

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Trait-IO/issues

#### AUTHOR

Zoffix Znet (https://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
