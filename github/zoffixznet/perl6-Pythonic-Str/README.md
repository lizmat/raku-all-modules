[![Build Status](https://travis-ci.org/zoffixznet/perl6-Pythonic-Str.svg)](https://travis-ci.org/zoffixznet/perl6-Pythonic-Str)

# NAME

Pythonic::Str - Index into strings like Pythonists do!

# SYNOPSIS

```perl6
    use Pythonic::Str;

    say 'foobar'[3];            # b
    say 'foobar'[3..*];         # bar
    say 'foobar'[^3];           # foo
    say 'foobar'[3,5,6]:exists; # (True True False)
```

# DESCRIPTION

Provides `&postcircumfix:<[ ]>` candidates to index into strings. Any
indexing operation you normally can use on lists is supported.

When multiple indices are given, the result will be calculated as if the
indexing were called on a list of individual characters that compose the given
string. **If all the elements** nodally are of type `Str` or `Nil` (excluding `Failures`), then the result will be joined together to form a single string.
Any other type of the output is returned as if it were called on a list
of individual characters that compose the given string.

In plainer language this means that you get a single string result for stuff
like:

```perl6
    say 'foobar'[^3];           # foo
    say 'foobar'[0, 1, 2];      # foo
    say 'foobar'[0, (1, (2,))]; # foo
```

... but will get the same result as if you called indexing on a list of
characters for stuff like:

```perl6
    say 'foobar'[^3]:p;           # (0 => f 1 => o 2 => o)
    say 'foobar'[0, 1, 2]:exists; # (True True True)
    say WHAT 'foobar'[1]:delete;  # (Failure)
```

# LIMITATIONS

This module does not provide `Str.AT-POS` or make `Str` type do `Positional`
or `Iterable` roles. The latter causes all sorts of fallout with core and
non-core code due to inherent assumptions that `Str` type does not do
those roles. What this means in plain English is you can only index your
strings with `[...]` postcircumfix operator and can't willy-nilly treat
them as lists of characters—simply call
[`.comb`](https://docs.perl6.org/routine/comb) if you need that.

# SEE ALSO

- [`Str.comb`](https://docs.perl6.org/routine/comb)
- [`Str.substr`](https://docs.perl6.org/routine/substr)

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Pythonic-Str

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Pythonic-Str/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
