[![Build Status](https://travis-ci.org/zoffixznet/perl6-Benchy.svg)](https://travis-ci.org/zoffixznet/perl6-Benchy)

# NAME

Benchy - Benchmark some code

# SYNOPSIS

```perl6
    use Benchy;
    b 20_000,  # number of times to loop
        { some-setup; my-old-code }, # your old version
        { some-setup; my-new-code }, # your new version
        { some-setup } # optional "bare" loop to eliminate setup code's time

    # SAMPLE OUTPUT:
    # Bare: 0.0606532677866851s
    # Old:  2.170558s
    # New:  0.185170s
    # NEW version is 11.72x faster
```

# DESCRIPTION

Takes 2 `Callable`s and measures which one is faster. Optionally takes a 3rd
`Callable` that will be run the same number of times as other two callables,
and the time it took to run will be subtracted from the other results.

# EXPORTED PRAGMAS

## `MONKEY`

The `use` of this module enables `MONKEY` pragma, so you can augment, use NQP,
EVAL, etc, without needing to specify those pragmas.

# EXPORTED SUBROUTINES

## `b`

Defined as:

```perl6
    sub b (int $n, &old, &new, &bare = { $ = $ }, :$silent)
```

Benches the codes and prints the results. Will print in colour, if
[`Terminal::ANSIColor`](https://modules.perl6.org/repo/Terminal::ANSIColor)
is installed.

**Args:**

- `$n` how many times to loop[^1]
- `&old` your "old" code; assumption is you have "old" code and you're trying
    to write some "new" code to replace it
- `&new` your "new" code
- `&bare` optional (defaults to `{ $ = $ }`). When specified, this `Callable`
    will be run same number of times as other code and the time it took to
    run will be subtracted from the `&new` and `&old` times. Use this to
    run some "setup" code. That is code that's used in `&new` and `&old` but
    should not be part of the benched times
- `:$silent` if set to a truthy value, the routine will not print anything to
    the screen

[1] Note that the exact number to loop will always be evened out,
    as the bench splits the work into two chunks that are measured at different
    times, so the total time is `2 × floor ½ × $n`

**Return value:**

Returns a hash with three keys—`bare`, `new`, and `old`—whose values are
[`Duration`](https://docs.perl6.org/type/Duration) objects representing the
time it took the corresponding `Callable`s to run. **NOTE:** the `new` and
`old` already have the duration of `bare` subtracted from them.

```perl6
    {
        :bare(Duration.new(<32741983139/488599474770>)),
        :new(Duration.new(<167/956>)),
        :old(Duration.new(<1280561957330937733/590077351150947660>))
    }
```

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Benchy

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Benchy/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
