[![Build Status](https://travis-ci.org/zoffixznet/perl6-IO-CatHandle-AutoLines.svg)](https://travis-ci.org/zoffixznet/perl6-IO-CatHandle-AutoLines)

# NAME

IO::CatHandle::AutoLines - Get IO::CatHandle's current handle's line number


# SYNOPSIS

```perl6
    use IO::CatHandle::AutoLines;

    'some'   .IO.spurt: "a\nb\nc";
    'files'  .IO.spurt: "d\ne\nf";
    'to-read'.IO.spurt: "g\nh";

    my $kitty = IO::CatHandle.new(<some files to-read>, :on-switch{
        say "Meow!"
    }) does IO::CatHandle::AutoLines;

    say "$kitty.ln(): $_" for $kitty.lines;

    # OUTPUT:
    # Meow!
    # 1: a
    # 2: b
    # 3: c
    # Meow!
    # 1: d
    # 2: e
    # 3: f
    # Meow!
    # 1: g
    # 2: h
    # Meow!
```

# DESCRIPTION

A role that adds `.ln` method to
[`IO::CatHandle`](https://docs.perl6.org/type/IO::CatHandle) type that will
contain the current line number. Optionally, the lines counter can be reset when
next source handle get switched into.

**Note:** only
[`.lines`](https://docs.perl6.org/type/IO::CatHandle#method_lines)
and [`.get`](https://docs.perl6.org/type/IO::CatHandle#method_get) methods
are overriden to increment the line counter. Using any other methods to
read data will not increment the line counter.

# EXPORTED TYPES

## `role IO::CatHandle::AutoLines`

Defined as:

```perl6
    role IO::CatHandle::AutoLines[Bool:D :$reset = True]
```

Provides `.ln` method containing `Int:D` of the current line number. If
`:$reset` parameter is set to `True` (default), then on source handle switch,
the line number will be reset back to zero.

```perl6
    # Reset on-switch enabled
    my $cat1 = IO::CatHandle.new(…) does role IO::CatHandle::AutoLines;

    # Reset on-switch disabled
    my $cat2 = IO::CatHandle.new(…) does role IO::CatHandle::AutoLines[:!reset];
```

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-IO-CatHandle-AutoLines

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-IO-CatHandle-AutoLines/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
