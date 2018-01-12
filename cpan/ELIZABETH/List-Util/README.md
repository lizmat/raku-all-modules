[![Build Status](https://travis-ci.org/lizmat/List-Util.svg?branch=master)](https://travis-ci.org/lizmat/List-Util)

NAME
====

List::Util - Port of Perl 5's List::Util 1.49

SYNOPSIS
========

    use List::Util <
      reduce any all none notall first

      max maxstr min minstr product sum sum0

      pairs unpairs pairkeys pairvalues pairfirst pairgrep pairmap

      shuffle uniq uniqnum uniqstr
    >;

DESCRIPTION
===========

`List::Util` contains a selection of subroutines that people have expressed would be nice to have in the perl 5 core, but the usage would not really be high enough to warrant the use of a keyword, and the size so small such that being individual extensions would be wasteful.

By default `List::Util` does not export any subroutines.

Porting Caveats
===============

Perl 6 does not have the concept of `scalar` and `list` context. Usually, the effect of a scalar context can be achieved by prefixing `+` to the result, which would effectively return the number of elements in the result, which usually is the same as the scalar context of Perl 5 of these functions.

Perl 6 does not have a magic `$a` and `$b`. But they can be made to exist by specifying the correct signature to blocks, specifically "-> $a, $b". These have been used in all examples that needed them. Just using the signature auto-generating `$^a` and `$^b` would be more Perl 6 like. But since we want to keep the documentation as close to the original as possible, it was decided to specifically specify the "-> $a, $b" signatures.

Perl 6 also doesn't have a single `undef` value, but instead has `Type Objects`, which could be considered undef values, but with a type annotation.

Perl 6 has real `Pair` objects, which in the Perl 5 version are mimiced by blessed arrays that have a `.key` and `.value` methods. In the Perl 6 version these are represented by a subclass of the `List` class, namely the `P5Pair`, which also provides a .key and a .value method.

Also note there are no special parsing rules with regards to blocks in Perl 6. So a comma is **always** required after having specified a block.

The following functions are actually built-ins in Perl 6.

    reduce any all none first max min sum uniq

They mostly provide the same or similar semantics, but there may be subtle differences, so it was decided to not just use the built-ins. If these functions are imported from this library in a scope, they will used instead of the Perl 6 builtins. The easiest way to use both the functions of this library and the Perl 6 builtins in the same scope, is to use the method syntax for the Perl 6 versions.

    {  # Note: imports in Perl 6 are always lexically scoped
        use List::Util <max>;
        say max 1..10;    # Ported Perl 5 version
        say (1..10).max;  # Perl 6 version
    }
    say max 1..10;  # Perl 6 version again

LIST-REDUCTION FUNCTIONS
========================

The following set of functions all reduce a list down to a single value.

reduce
------

    $result = reduce -> $a, $b { BLOCK }, @list;

Reduces `@list` by calling `BLOCK` multiple times, setting `$a` and `$b` each time. The first call will be with `$a` and `$b` set to the first two elements of the list, subsequent calls will be done by setting `$a` to the result of the previous call and `$b` to the next element in the list.

Returns the result of the last call to the `BLOCK`. If `@list` is empty then `Nil` is returned. If `@list` only contains one element then that element is returned and `BLOCK` is not executed.

The following examples all demonstrate how `reduce` could be used to implement the other list-reduction functions in this module. (They are not in fact implemented like this, but instead in a more efficient manner in individual C functions).

    $foo = reduce -> $a, $b { defined($a)            ? $a :
                              $code->(local $_ = $b) ? $b :
                                                Nil } Nil, @list; # first

    $foo = reduce -> $a, $b { $a > $b ?? $a !! $b } 1..10;       # max
    $foo = reduce -> $a, $b { $a gt $b ?? $a !! $b } 'A'..'Z';   # maxstr
    $foo = reduce -> $a, $b { $a < $b ?? $a !! $b } 1..10;       # min
    $foo = reduce -> $a, $b { $a lt $b ?? $a !! $b } 'aa'..'zz'; # minstr
    $foo = reduce -> $a, $b { $a + $b } 1 .. 10;                 # sum
    $foo = reduce -> $a, $b { $a ~ $b } @bar;                    # concat

    $foo = reduce -> $a, $b { $a || $b }   0, @bar;  # any
    $foo = reduce -> $a, $b { $a && $b }   1, @bar;  # all
    $foo = reduce -> $a, $b { $a && !$b }  1, @bar;  # none
    $foo = reduce -> $a, $b { $a || !$b) } 0, @bar;  # notall
    # Note that these implementations do not fully short-circuit

If your algorithm requires that `reduce` produce an identity value, then make sure that you always pass that identity value as the first argument to prevent `Nil` being returned

    $foo = reduce -> $a, $b { $a + $b } 0, @values;  # sum with 0 identity value

The above example code blocks also suggest how to use `reduce` to build a more efficient combined version of one of these basic functions and a `map` block. For example, to find the total length of all the strings in a list, we could use

    $total = sum map { .chars }, @strings;

However, this produces a list of temporary integer values as long as the original list of strings, only to reduce it down to a single value again. We can compute the same result more efficiently by using `reduce` with a code block that accumulates lengths by writing this instead as:

    $total = reduce -> $a, $b { $a + $b.chars } 0, @strings;

The remaining list-reduction functions are all specialisations of this generic idea.

any
---

    my $bool = any { BLOCK }, @list;

Similar to `grep` in that it evaluates `BLOCK` setting `$_` to each element of `@list` in turn. `any` returns true if any element makes the `BLOCK` return a true value. If `BLOCK` never returns true or `@list` was empty then it returns false.

Many cases of using `grep` in a conditional can be written using `any` instead, as it can short-circuit after the first true result.

    if( any { .chars > 10 }, @strings ) {
        # at least one string has more than 10 characters
    }

all
---

    my $bool = all { BLOCK }, @list;

Similar to [/any](/any), except that it requires all elements of the `@list` to make the `BLOCK` return true. If any element returns false, then it returns false. If the `BLOCK` never returns false or the `@list` was empty then it returns true.

none
----

notall
------

    my $bool = none { BLOCK }, @list;

    my $bool = notall { BLOCK }, @list;

Similar to [/any](/any) and [/all](/all), but with the return sense inverted. `none` returns true only if no value in the `@list` causes the `BLOCK` to return true, and `notall` returns true only if not all of the values do.

first
-----

    my $val = first { BLOCK }, @list;

Similar to `grep` in that it evaluates `BLOCK` setting `$_` to each element of `@list` in turn. `first` returns the first element where the result from `BLOCK` is a true value. If `BLOCK` never returns true or `@list` was empty then `Nil` is returned.

    $foo = first { defined($_) }, @list;   # first defined value in @list
    $foo = first { $_ > $value }, @list;   # first value in @list which
                                           # is greater than $value

max
---

    my $num = max @list;

Returns the entry in the list with the highest numerical value. If the list is empty then `Nil` is returned.

    $foo = max 1..10;         # 10
    $foo = max 3,9,12;        # 12
    $foo = max @bar, @baz;    # whatever

maxstr
------

    my $str = maxstr @list;

Similar to [/max](/max), but treats all the entries in the list as strings and returns the highest string as defined by the `gt` operator. If the list is empty then `Nil` is returned.

    $foo = maxstr 'A'..'Z';         # 'Z'
    $foo = maxstr "hello","world";  # "world"
    $foo = maxstr @bar, @baz;       # whatever

min
---

    my $num = min @list;

Similar to [/max](/max) but returns the entry in the list with the lowest numerical value. If the list is empty then `Nil` is returned.

    $foo = min 1..10;               # 1
    $foo = min 3,9,12;              # 3
    $foo = min @bar, @baz;          # whatever

minstr
------

    my $str = minstr @list;

Similar to [/min](/min), but treats all the entries in the list as strings and returns the lowest string as defined by the `lt` operator. If the list is empty then `Nil` is returned.

    $foo = minstr 'A'..'Z';         # 'A'
    $foo = minstr "hello","world";  # "hello"
    $foo = minstr @bar, @baz;       # whatever

product
-------

    my $num = product @list;

Returns the numerical product of all the elements in `@list`. If `@list` is empty then `1` is returned.

    $foo = product 1..10;           # 3628800
    $foo = product 3,9,12;          # 324

sum
---

    my $num_or_nil = sum @list;

Returns the numerical sum of all the elements in `@list`. For backwards compatibility, if `@list` is empty then `Nil` is returned.

    $foo = sum 1..10;               # 55
    $foo = sum 3,9,12;              # 24
    $foo = sum @bar, @baz;          # whatever

sum0
----

    my $num = sum0 @list;

Similar to [/sum](/sum), except this returns 0 when given an empty list, rather than `Nil`.

cut
===



KEY/VALUE PAIR LIST FUNCTIONS
=============================

The following set of functions, all inspired by [List::Pairwise](List::Pairwise), consume an even-sized list of pairs. The pairs may be key/value associations from a hash, or just a list of values. The functions will all preserve the original ordering of the pairs, and will not be confused by multiple pairs having the same "key" value - nor even do they require that the first of each pair be a plain string.

**NOTE**: At the time of writing, the following `pair*` functions that take a block do not modify the value of `$_` within the block, and instead operate using the `$a` and `$b` globals instead. This has turned out to be a poor design, as it precludes the ability to provide a `pairsort` function. Better would be to pass pair-like objects as 2-element array references in `$_`, in a style similar to the return value of the `pairs` function. At some future version this behaviour may be added.

Until then, users are alerted **NOT** to rely on the value of `$_` remaining unmodified between the outside and the inside of the control block. In particular, the following example is **UNSAFE**:

    my @kvlist = ...

    foreach (qw( some keys here )) {
       my @items = pairgrep { $a eq $_ } @kvlist;
       ...
    }

Instead, write this using a lexical variable:

    foreach my $key (qw( some keys here )) {
       my @items = pairgrep { $a eq $key } @kvlist;
       ...
    }

cut
===



pairs
-----

    my @pairs = pairs @kvlist;

A convenient shortcut to operating on even-sized lists of pairs, this function returns a list of `ARRAY` references, each containing two items from the given list. It is a more efficient version of

    @pairs = pairmap { [ $a, $b ] }, @kvlist;

It is most convenient to use in a `foreach` loop, for example:

    foreach my $pair ( pairs @kvlist ) {
       my ( $key, $value ) = @$pair;
       ...
    }

The following code is equivalent:

    foreach my $pair ( pairs @kvlist ) {
       my $key   = $pair.key;
       my $value = $pair.value;
       ...
    }

unpairs
-------

    my @kvlist = unpairs @pairs;

The inverse function to `pairs`; this function takes a list of `ARRAY` references containing two elements each, and returns a flattened list of the two values from each of the pairs, in order. This is notionally equivalent to

    my @kvlist = map { @{$_}[0,1] } @pairs;

except that it is implemented more efficiently internally. Specifically, for any input item it will extract exactly two values for the output list; using `Nil` if the input array references are short.

Between `pairs` and `unpairs`, a higher-order list function can be used to operate on the pairs as single scalars; such as the following near-equivalents of the other `pair*` higher-order functions:

    @kvlist = unpairs grep { FUNC }, pairs @kvlist;
    # Like pairgrep, but takes $_ instead of $a and $b

    @kvlist = unpairs map { FUNC }, pairs @kvlist;
    # Like pairmap, but takes $_ instead of $a and $b

Finally, this technique can be used to implement a sort on a keyvalue pair list; e.g.:

    @kvlist = unpairs sort -> $a, $b { $a.key cmp $b.key }, pairs @kvlist;

pairkeys
--------

    my @keys = pairkeys @kvlist;

A convenient shortcut to operating on even-sized lists of pairs, this function returns a list of the the first values of each of the pairs in the given list. It is a more efficient version of

    @keys = pairmap -> $a, $b { $a }, @kvlist;

pairvalues
----------

    my @values = pairvalues @kvlist;

A convenient shortcut to operating on even-sized lists of pairs, this function returns a list of the the second values of each of the pairs in the given list. It is a more efficient version of

    @values = pairmap -> $a, $b { $b }, @kvlist;

pairgrep
--------

    my @kvlist = pairgrep -> $a, $b { BLOCK }, @kvlist;

    my $count = pairgrep -> $a, $b { BLOCK }, @kvlist;

Similar to perl's `grep` keyword, but interprets the given list as an even-sized list of pairs. It invokes the `BLOCK` multiple times, with `$a` and `$b` set to successive pairs of values from the `@kvlist`.

Returns an even-sized list of those pairs for which the `BLOCK` returned true.

    @subset = pairgrep -> $a, $b { $a =~ m/^[[:upper:]]+$/ }, @kvlist;

As with `grep` aliasing `$_` to list elements, `pairgrep` aliases `$a` and `$b` to elements of the given list.

pairfirst
---------

    my ( $key, $val ) = pairfirst -> $a, $b { BLOCK }, @kvlist;

    my $found = pairfirst -> $a, $b { BLOCK }, @kvlist;

Similar to the [/first](/first) function, but interprets the given list as an even-sized list of pairs. It invokes the `BLOCK` multiple times, with `$a` and `$b` set to successive pairs of values from the `@kvlist`.

Returns the first pair of values from the list for which the `BLOCK` returned true, or an empty list of no such pair was found.

    ( $key, $value ) = pairfirst -> $a, $b { $a =~ m/^[[:upper:]]+$/ }, @kvlist;

As with `grep` aliasing `$_` to list elements, `pairfirst` aliases `$a` and `$b` to elements of the given list.

pairmap
-------

    my @list = pairmap -> $a, $b { BLOCK }, @kvlist;

    my $count = pairmap -> $a, $b { BLOCK }, @kvlist;

Similar to perl's `map` keyword, but interprets the given list as an even-sized list of pairs. It invokes the `BLOCK` multiple times, with `$a` and `$b` set to successive pairs of values from the `@kvlist`.

Returns all the values returned by the `BLOCK`.

    @result = pairmap -> $a, $b { "The key $a has value $b" }, @kvlist

As with `map` aliasing `$_` to list elements, `pairmap` aliases `$a` and `$b` to elements of the given list.

OTHER FUNCTIONS
===============

shuffle
-------

    my @values = shuffle @values;

Returns the values of the input in a random order

    @cards = shuffle 0..51;     # 0..51 in a random order

uniq
----

    my @subset = uniq @values;

Filters a list of values to remove subsequent duplicates, as judged by a DWIM-ish string equality. Preserves the order of unique elements, and retains the first value of any duplicate set.

Type objects are treated by this function as distinct from the empty string, and no warning will be produced. It is left as-is in the returned list. Subsequent identical type objects are still considered identical to the first, and will be removed.

uniqnum
-------

    my @subset = uniqnum @values;

Filters a list of values to remove subsequent duplicates, as judged by a numerical equality test. Preserves the order of unique elements, and retains the first value of any duplicate set.

Note that type objects are treated much as other numerical operations treat it; it compares equal to zero but additionally produces a warning. In addition, a type object in the returned list is coerced into a numerical zero, so that the entire list of values returned by `uniqnum` are well-behaved as numbers.

Note also that multiple IEEE `NaN` values are treated as duplicates of each other, regardless of any differences in their payloads.

uniqstr
-------

    my @subset = uniqstr @values;

Filters a list of values to remove subsequent duplicates, as judged by a string equality test. Preserves the order of unique elements, and retains the first value of any duplicate set.

Note that type objects are treated much as other string operations treat it; it compares equal to the empty string but additionally produces a warning. In addition, a type object in the returned list is coerced into an empty string, so that the entire list of values returned by `uniqstr` are well-behaved as Str.

SEE ALSO
========

[Scalar::Util](Scalar::Util), [List::MoreUtils](List::MoreUtils)

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-Util . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5 version originally developed by Graham Barr, subsequently maintained by Paul Evans.

