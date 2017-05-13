[![Build Status](https://travis-ci.org/zoffixznet/perl6-Testo.svg)](https://travis-ci.org/zoffixznet/perl6-Testo)

# NAME

Testo - Perl 6 Testing Done Right

# SYNOPSIS

```perl6
    use Testo;
    plan 9;

    # `is` uses smart match semantics:
    is 'foobar', *.contains('foo');    # test passes
    is (1, 2, (3, 4)), [1, 2, [3, 4]]; # test passes
    is (1, 2, (3, 4)), '1 2 3 4';      # test fails; unlike Test.pm6's `is`
    is 'foobar', /foo/;   # no more Test.pm6's `like`;    just use a regex
    is 'foobar', Str;     # no more Test.pm6's `isa-ok`;  just use a type object
    is 'foobar', Stringy; # no more Test.pm6's `does-ok`; just use a type object

    # uses `eqv` semantics and works right with Seqs
    is-eqv (1, 2).Seq, (1, 2); # test fails; unlike Test.pm6's `is-deeply`

    # execute a program with some args and STDIN input and smartmatch its
    # STDERR, STDOUT, and exit status:
    is-run $*EXECUTABLE, :in<hi!>, :args['-e', 'say $*IN.uc'],
        :out(/'HI!'/), :err(''), :0status, 'can say hi';
```

# FEATURES

- Tests routines designed for testing Perl 6 code
- Configurable output: TAP, JSON, or even a custom type!
- Easy to extend with your own custom test routines!

# BETA-WARE

Note this module is still in fleshing-out stage. JSON output type, more
test functions, and docs for the classes under the hood and customization
are yet to be made, but will be made soon!

# DESCRIPTION

Testo is the New and Improved version of `Test.pm6` that you can use
*instead* of `Test.pm6` to test all of your code and generate output in
[TAP](https://testanything.org/tap-specification.html),
JSON, or any other custom format!

# EXPORTED ROUTINES

## `plan`

Defined as:

```perl6
    sub plan (Int $number-of-tests);
```

Specifies the number of tests you plan to run.

```perl6
    plan 5;
```

## `is`

Defined as:

```perl6
    sub is (Mu $expected, Mu $got, Str $desc?);
```

Testo's workhorse you'll use for most testing. Performs the test using
[smartmatch](https://docs.perl6.org/routine/~~.html) semantics; i.e. it's
equivalent to doing `($expected ~~ $got).Bool`, with the test passing if the
result is `True`. An optional description of the test can be specified

```perl6
    is 'foobar', *.contains('foo');    # test passes
    is (1, 2, (3, 4)), [1, 2, [3, 4]]; # test passes
    is (1, 2, (3, 4)), '1 2 3 4';      # test fails; unlike Test.pm6's `is`
    is 'foobar', /foo/;      # no more Test.pm6's `like`;    just use a regex
    is 'foobar', none /foo/; # no more Test.pm6's `unlike`;  just use a none  Junction
    is 'foobar', Str;        # no more Test.pm6's `isa-ok`;  just use a type object
    is 'foobar', Stringy;    # no more Test.pm6's `does-ok`; just use a type object

    is 1, 2, 'some description'; # you can provide optional description too
```

Note that Testo does not provide several of [Test.pm6's
tests](https://docs.perl6.org/language/testing), such as `isnt`, `like`,
`unlike`, `isa-ok` or `does-ok`, as those are replaced by `is` with Regex/type
objects/`none` Junctions as arguments.

## `is-eqv`

Defined as:

```perl6
    sub is-eqv (Mu $expected, Mu $got, Str $desc?);
```

Uses [`eqv`](https://docs.perl6.org/routine/eqv) semantics to perform the test.
An optional description of the test can be specified.

```perl6
    is-eqv (1, 2).Seq, (1, 2); # fails; types do not match
    is-eqv 1.0, 1; # fails; types do not match
    is-eqv 1, 1;   # succeeds; types and values match
```

## `is-run`

NYI.

---

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Testo

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Testo/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

Some portions of this software may be based on or re-use code
of `Test.pm6` module shipped with
[Rakudo 2107.04.03](http://rakudo.org/downloads/rakudo/), © 2017 by The Perl
Foundation, under The Artistic License 2.0.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
