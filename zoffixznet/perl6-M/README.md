[![Build Status](https://travis-ci.org/zoffixznet/perl6-M.svg)](https://travis-ci.org/zoffixznet/perl6-M)

# NAME

M - M, the 1-character Map: non-nodal, non-autothreading `.map(*.some-method)`

# SYNOPSIS

Default operator:

```perl6
    use M;
    (^3, [^4], '5')▸.Numeric.say; # (3, 4, 5)
```

Custom operator:

```perl6
    use M '♥';
    (^3, [^4], '5')♥.Numeric.say;  # (3, 4, 5)
```

# DESCRIPTION

The `.map: *.some-method` is a pretty common construct to desire in your code,
and many people choose to write it as `».some-method`, using the hyper method
call. The problem is that's not always what you want and sometimes is the
wrong thing to use.

What's wrong with `»`? First, it's an auto-threaded operator, which means
`@foo».say` won't output stuff in any predictable order. Second, it does
the whole nodal thing and descends into iterables, so that
 `(^3, [^4], '5')».Numeric` doesn't return `(3, 4, 5)`.

Never fear, `M` is here! Why `M`? Cause it's a 1-character `.map`!

# OPERATOR

By default, use `▸` (U+25B8) to call the hypered map (see SYNOPSIS).

If you want to use some other name for the operator, specify it as a string
on the `use M` line.

# HOW DOES IT WORK?

Magic.

# LIMITATIONS AND TODO

Currently you can't use exported operator to map
`ACCEPTS`, `new`, `bless`, or `BUILDALL` methods.

Eventually, I hope to figure out how to make the operator available in
everywhere in the program after a single `use M` anywhere,
even in scopes where `use M` was not used.

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-M

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-M/issues

# AUTHOR

Zoffix Znet ([@zoffix](https://twitter.zoffix))

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
