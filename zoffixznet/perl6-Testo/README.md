[![Build Status](https://travis-ci.org/zoffixznet/perl6-Testo.svg)](https://travis-ci.org/zoffixznet/perl6-Testo)

# NAME

Testo - Perl 6 Testing Done Right

# SYNOPSIS

```perl6
    use Testo;
    plan 10;

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
        :out(/'HI!'/), 'can say hi';

    # run a bunch of tests as a group; like Test.pm6's `subtest`
    group 'a bunch of test' => 3 => {
        is 1, 1;
        is 4, 4;
        is 'foobar', /foo/;
    }
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

```perl6
    is-run $*EXECUTABLE, :in<hi!>, :args['-e', 'say $*IN.uc'],
        :out(/'HI!'/), 'can say hi';

    is-run $*EXECUTABLE, :args['-e', '$*ERR.print: 42'],
        :err<42>, 'can err 42';

    is-run $*EXECUTABLE, :args['-e', 'die 42'],
        :err(*), :42status, 'can exit with exit code 42';
```

**NOTE:** due to [a Rakudo bug
RT#130781](https://rt.perl.org/Ticket/Display.html?id=130781#ticket-history)
exit code is currently always reported as `0`

Runs an executable (via [&run](https://docs.perl6.org/routine/run)), optionally
supplying extra args given as `:args[...]` or feeding STDIN with a `Str` or
`Blob` data given via C<:in>.

Runs three `is` tests on STDOUT, STDERR, and exit code expected values for
which are provided via `:out`, `:err` and `:status` arguments respectively.
If omitted, `:out` and `:err` default to empty string (`''`) and `:status`
defaults to `0`. Use the [Whatever star](https://docs.perl6.org/type/Whatever)
(`*`) as the value for any of the three arguments (see `:err` in last
example above).

## `group`

```perl6
    plan 1;

    # run a bunch of tests as a group; like Test.pm6's `subtest`
    group 'a bunch of tests' => 4 => {
        is 1, 1;
        is 4, 4;
        is 'foobar', /foo/;

        group 'nested bunch of tests; with manual `plan`' => {
            plan 2;
            is 1, 1;
            is 4, 4;
        }
    }
```

Similar to `Test.pm6`'s `subtest`. Groups a number of tests into a... group
with its own plan. The entire group counts as 1 test towards the planned/ran
number of tests.

Takes a `Pair` as the argument that is either `Str:D $desc => &group-code`
or `Str:D $desc => UInt:D $plan where .so => &group-code` (see code example
above), the latter form lets you specify the plan for the group, while the
former would require you to manually use `&plan` inside of the `&group-code`.

Groups can be nested for any (reasonable) number of levels.

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
