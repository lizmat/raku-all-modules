[![Build Status](https://travis-ci.org/zoffixznet/perl6-Failer.svg)](https://travis-ci.org/zoffixznet/perl6-Failer)

# NAME

Failer - Handle Failures like a Pro

# SYNOPSIS

```perl6
    use Failer;

    sub do-stuff { fail "meow" }

    sub meows {
        $*CWD = no-fail do-stuff;  # leaves $*CWD untouched; returns unhandled Failure from meows
        my $foo = do-stuff ∨-fail; # returns unhandled Failure from meows

        my $f = Failure.new;
        say so-fail $f; # like regular `so`, but leaves Failure unhandled
        say de-fail $f; # like regular `defined`, but leaves Failure unhandled
    }
```

# DESCRIPTION

[`Failure`s](http://docs.perl6.org/type/Failure) are awesome! But,
non-invasively checking for `Failure`s isn't always. Any calls to `.Bool` or
`.defined` on a `Failure` will disarm it, so other than using a
smartmatch, once you detect that what you have in fact is a
`Failure`, you have to re-arm it again to maintain its explositivity.
Here's where this module saves the day!

All available goodies are named in `XX-fail` format: `no-fail`, `so-fail`,
and `de-fail`. The exception is `∨-fail`, because rules need exceptions.

# EXPORTED ROUTINES AND OPERATORS

## `no-fail`

```perl6
    $*CWD = no-fail do-stuff;
```

Takes a single positional argument. If it's a `Failure` will return it unhandled **from the current routine**. If it isn't, will merely pass the argument along.
Functionally, it's equivalent to writing:

```perl6
    $*CWD = do {
        my $res = do-stuff;
        return $res if $res ~~ Failure;
        $res;
    }
```

## `postfix:<∨-fail>`

```perl6
    my $foo = do-stuff ∨-fail;
```

A postfix operator with the same precedence as
[`infix:<orelse>`](https://docs.perl6.org/routine/orelse). Checks if its argument is a `Failure` and returns it unhandled **from the current
routine**. Does nothing otherwise. Returns `Nil`.
Functionally, it's equivalent to writing:

```perl6
    my $foo = do-stuff orelse do { when Failure { .handled = 0; .return }; Nil }
```

**NOTE:** the `∨` in `∨-fail` is `U+2228 LOGICAL OR [Sm] (∨)`, not a regular
`v`. "What's with the crazy Unicode, bruh!" you ask? The reason is postfix ops
with names that are valid identifiers can't have whitespace before them and
that means they'd need either parentheses or an unspace before listops. I like
whitespace. I don't like unspace. DEATH TO PARENS!

## `prefix:<so-fail>`

```perl6
    my $f = do-stuff;
    if so-fail $f { … }
    else {
        say "Wow! \$f is totally a Failure right there, but it's still unhandled!"
    }
```

Same as [`prefix:<so>`](https://docs.perl6.org/routine/so), except it does not
mark the `Failure`s as handled.
Functionally, it's equivalent to writing:

```perl6
    my $f = do-stuff;
    if $f !~~ Failure and so $f { … }
    else {
        say "Wow! \$f is totally a Failure right there, but it's still unhandled!"
    }
```

## `prefix:<de-fail>`

```perl6
    my $f = do-stuff;
    if de-fail $f { … }
    else {
        say "Wow! \$f is totally a Failure right there, but it's still unhandled!"
    }
```

Same as [`&defined`](https://docs.perl6.org/routine/defined), except it's a
prefix op with same precedence as
[`prefix:<so>`](https://docs.perl6.org/routine/so) and it does not mark the
`Failure`s as handled. Functionally, it's equivalent to writing:

```perl6
    my $f = do-stuff;
    if $f !~~ Failure and defined $f { … }
    else {
        say "Wow! \$f is totally a Failure right there, but it's still unhandled!"
    }
```

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Failer

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Failer/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
