[![Build Status](https://travis-ci.org/lizmat/List-MoreUtils.svg?branch=master)](https://travis-ci.org/lizmat/List-MoreUtils)

NAME
====

List::MoreUtils - Port of Perl 5's List::MoreUtils 0.428

SYNOPSIS
========

    # import specific functions
    use List::MoreUtils <any uniq>;

    if any { /foo/ }, uniq @has_duplicates {
        # do stuff
    }

    # import everything
    use List::MoreUtils ':all';

DESCRIPTION
===========

List::MoreUtils provides some trivial but commonly needed functionality on lists which is not going to go into `List::Util`.

EXPORTS
=======

Nothing by default. To import all of this module's symbols use the `:all` tag. Otherwise functions can be imported by name as usual:

    use List::MoreUtils :all;

    use List::MoreUtils <any firstidx>;

Porting Caveats
===============

Perl 6 does not have the concept of `scalar` and `list` context. Usually, the effect of a scalar context can be achieved by prefixing `+` to the result, which would effectively return the number of elements in the result, which usually is the same as the scalar context of Perl 5 of these functions.

Perl 6 does not have a magic `$a` and `$b`. But they can be made to exist by specifying the correct signature to blocks, specifically "-> $a, $b". These have been used in all examples that needed them. Just using the signature auto-generating `$^a` and `$^b` would be more Perl 6 like. But since we want to keep the documentation as close to the original as possible, it was decided to specifically specify the "-> $a, $b" signatures.

Many functions take a `&code` parameter of a `Block` to be called by the function. Many of these assume **$_** will be set. In Perl 6, this happens automagically if you create a block without a definite or implicit signature:

    say { $_ == 4 }.signature;   # (;; $_? is raw)

which indicates the Block takes an optional parameter that will be aliased as `$_` inside the Block.

Perl 6 also doesn't have a single `undef` value, but instead has `Type Objects`, which could be considered undef values, but with a type annotation. In this module, `Nil` (a special value denoting the absence of a value where there should have been one) is used instead of `undef`.

Also note there are no special parsing rules with regards to blocks in Perl 6. So a comma is **always** required after having specified a block.

The following functions are actually built-ins in Perl 6.

    any all none minmax uniq zip

They mostly provide the same or similar semantics, but there may be subtle differences, so it was decided to not just use the built-ins. If these functions are imported from this library in a scope, they will used instead of the Perl 6 builtins. The easiest way to use both the functions of this library and the Perl 6 builtins in the same scope, is to use the method syntax for the Perl 6 versions.

    my @a = 42,5,2,98792,88;
    {  # Note: imports in Perl 6 are always lexically scoped
        use List::Util <minmax>;
        say minmax @a;  # Ported Perl 5 version
        say @a.minmax;  # Perl 6 version
    }
    say minmax @a;  # Perl 6 version again

Many functions returns either `True` or `False`. These are `Bool`ean objects in Perl 6, rather than just `0` or `1`. However, if you use a Boolean value in a numeric context, they are silently coerced to 0 and 1. So you can still use them in numeric calculations as if they are 0 and 1.

Some functions return something different in scalar context than in list context. Perl 6 doesn't have those concepts. Functions that are supposed to return something different in scalar context also accept a `:scalar` named parameter to indicate a scalar context result is required. This will be noted with the function in question if that feature is available.

FUNCTIONS
=========

Junctions
---------

### *Treatment of an empty list*

There are two schools of thought for how to evaluate a junction on an empty list:

  * Reduction to an identity (boolean)

  * Result is undefined (three-valued)

In the first case, the result of the junction applied to the empty list is determined by a mathematical reduction to an identity depending on whether the underlying comparison is "or" or "and". Conceptually:

    "any are true"      "all are true"
    --------------      --------------

    2 elements:     A || B || 0         A && B && 1
    1 element:      A || 0              A && 1
    0 elements:     0                   1

In the second case, three-value logic is desired, in which a junction applied to an empty list returns `Nil` rather than `True` or `False`.

Junctions with a `_u` suffix implement three-valued logic. Those without are boolean.

### all BLOCK, LIST

### all_u BLOCK, LIST

Returns True if all items in LIST meet the criterion given through BLOCK. Passes each element in LIST to the BLOCK in turn:

    say "All values are non-negative"
      if all { $_ >= 0 }, ($x, $y, $z);

For an empty LIST, `all` returns True (i.e. no values failed the condition) and `all_u` returns `Nil`.

Thus, `all_u(@list) ` is equivalent to `@list ?? all(@list) !! Nil `.

**Note**: because Perl treats `Nil` as false, you must check the return value of `all_u` with `defined` or you will get the opposite result of what you expect.

#### Idiomatic Perl 6 ways

    say "All values are non-negative"
      if $x & $y & $z >= 0;

    say "All values are non-negative"
      if all(@list) >= 0;

### any BLOCK, LIST

### any_u BLOCK, LIST

Returns True if any item in LIST meets the criterion given through BLOCK. Passes each element in LIST to the BLOCK in turn:

    say "At least one non-negative value"
      if any { $_ >= 0 }, ($x, $y, $z);

For an empty LIST, `any` returns False and `any_u` returns `Nil`.

Thus, `any_u(@list) ` is equivalent to `@list ?? any(@list) !! undef `.

#### Idiomatic Perl 6 ways

    say "At least one non-negative value"
      if $x | $y | $z >= 0;

    say "At least one non-negative value"
      if any(@list) >= 0;

### none BLOCK, LIST

### none_u BLOCK, LIST

Logically the negation of `any`. Returns True if no item in LIST meets the criterion given through BLOCK. Passes each element in LIST to the BLOCK in turn:

    say "No non-negative values"
      if none { $_ >= 0 }, ($x, $y, $z);

For an empty LIST, `none` returns True (i.e. no values failed the condition) and `none_u` returns `Nil`.

Thus, `none_u(@list) ` is equivalent to `@list ?? none(@list) !! Nil `.

**Note**: because Perl treats `Nil` as false, you must check the return value of `none_u` with `defined` or you will get the opposite result of what you expect.

#### Idiomatic Perl 6 ways

    say "No non-negative values"
      if none($x,$y,$z) >= 0;

    say "No non-negative values"
      if none(@list) >= 0;

### notall BLOCK, LIST

### notall_u BLOCK, LIST

Logically the negation of `all`. Returns True if not all items in LIST meet the criterion given through BLOCK. Passes each element in LIST to the BLOCK in turn:

    say "Not all values are non-negative"
      if notall { $_ >= 0 }, ($x, $y, $z);

For an empty LIST, `notall` returns False and `notall_u` returns `Nil`.

Thus, `notall_u(@list) ` is equivalent to `@list ?? notall(@list) !! Nil `.

#### Idiomatic Perl 6 ways

    say "Not all values are non-negative"
      if not all($x,$y,$z) >= 0;

    say "Not all values are non-negative"
      if not all(@list) >= 0;

### one BLOCK, LIST

### one_u BLOCK, LIST

Returns True if precisely one item in LIST meets the criterion given through BLOCK. Passes each element in LIST to the BLOCK in turn:

    say "Precisely one value defined"
      if one { defined($_) }, @list;

Returns False otherwise.

For an empty LIST, `one` returns False and `one_u` returns `Nil`.

The expression `one BLOCK, LIST` is almost equivalent to `1 == True BLOCK, LIST`, except for short-cutting. Evaluation of BLOCK will immediately stop at the second true value seen.

#### Idiomatic Perl 6 ways

    say "Precisely one value defined"
      if ($x ^ $y ^ $z).defined;

    say "Precisely one value defined"
      if one(@list>>.defined);

Transformation
--------------

### apply BLOCK, LIST

Applies BLOCK to each item in LIST and returns a list of the values after BLOCK has been applied. Returns the last element if `:scalar` has been specified. This function is similar to `map` but will not modify the elements of the input list:

    my @list = 1 .. 4;
    my @mult = apply { $_ *= 2 }, @list;
    print "@list = @list[]\n";
    print "@mult = @mult[]\n";
    =====================================
    @list = 1 2 3 4
    @mult = 2 4 6 8

With the `:scalar` named parameter:

    my @list = 1 .. 4;
    my $last = apply { $_ *= 2 }, @list, :scalar;
    print "@list = @list[]\n";
    print "\$last = $last\n";
    =====================================
    @list = 1 2 3 4
    $last = 8

#### Idiomatic Perl 6 ways

    my @mult = @list.map: -> $_ is copy { $_ *= 2 };

    my $last = @list.map( -> $_ is copy { $_ *= 2 }).tail;

### insert_after BLOCK, VALUE, LIST

Inserts VALUE after the first item in LIST for which the criterion in BLOCK is true. Sets `$_` for each item in LIST in turn.

    my @list = <This is a list>;
    insert_after { $_ eq "a" }, "longer" => @list;
    say "@list[]";
    ===================================
    This is a longer list

### insert_after_string STRING, VALUE, LIST

Inserts VALUE after the first item in LIST which is equal to STRING.

    my @list = <This is a list>;
    insert_after_string "a", "longer" => @list;
    say "@list[]";
    ===================================
    This is a longer list

### pairwise BLOCK, ARRAY1, ARRAY2

Evaluates BLOCK for each pair of elements in ARRAY1 and ARRAY2 and returns a new list consisting of BLOCK's return values. The two elements are passed as parameters to BLOCK.

    my @a = 1 .. 5;
    my @b = 11 .. 15;
    my @x = pairwise -> $a, $b { $a + $b }, @a, @b; # returns 12, 14, 16, 18, 20

    # mesh with pairwise
    my @a = <a b c>;
    my @b = <1 2 3>;
    my @x = pairwise -> $a, $b { $a, $b }, @a, @b;    # returns a, 1, b, 2, c, 3

#### Idiomatic Perl 6 ways

    my @x = zip(@a,@b).map: -> ($a,$b) { $a + $b };

    my @x = zip(@a,@b).flat;

### mesh ARRAY1, ARRAY2 [ , ARRAY3 ... ]

### zip ARRAY1, ARRAY2 [ , ARRAY3 ... ]

Returns a list consisting of the first elements of each array, then the second, then the third, etc, until all arrays are exhausted.

Examples:

    my @x = <a b c d>;
    my @y = <1 2 3 4>;
    my @z = mesh @x, @y;       # returns a, 1, b, 2, c, 3, d, 4

    my Str @a = 'x';
    my Int @b = 1, 2;
    my @c = <zip zap zot>;
    my @d = mesh @a, @b, @c;   # x, 1, zip, Str, 2, zap, Str, Int, zot

`zip` is an alias for `mesh`.

#### Idiomatic Perl 6 ways

    my @x = zip(@a,@b).flat;

    my @x = zip(@a,@b,@c).flat;

### zip6 ARRAY1, ARRAY2 [ , ARRAY3 ... ]

### zip_unflatten ARRAY1, ARRAY2 [ , ARRAY3 ... ]

Returns a list of arrays consisting of the first elements of each array, then the second, then the third, etc, until all arrays are exhausted.

    my @x = <a b c d>;
    my @y = <1 2 3 4>;
    my @z = zip6 @x, @y;     # returns [a, 1], [b, 2], [c, 3], [d, 4]

    my Str @a = 'x';
    my Int @b = 1, 2;
    my @c = <zip zap zot>;
    my @d = zip6 @a, @b, @c; # [x, 1, zip], [Str, 2, zap], [Str, Int, zot]

`zip_unflatten` is an alias for `zip6`.

#### Idiomatic Perl 6 ways

    my @x = zip(@a,@b);

    my @x = zip(@a,@b,@c);

### listcmp ARRAY0 ARRAY1 [ ARRAY2 ... ]

Returns an associative list of elements and every *id* of the list it was found in. Allows easy implementation of @a & @b, @a | @b, @a ^ @b and so on. Undefined entries in any given array are skipped.

    my @a = <one two four five six seven eight nine ten>;
    my @b = <two five seven eleven thirteen seventeen>;
    my @c = <one one two five eight thirteen twentyone>;

    my %cmp := listcmp @a, @b, @c;
    # (one => [0, 2], two => [0, 1, 2], four => [0], ...)

    my @seq = 1, 2, 3;
    my @prim = Int, 2, 3, 5;
    my @fib = 1, 1, 2;
    my $cmp = listcmp @seq, @prim, @fib;
    # { 1 => [0, 2], 2 => [0, 1, 2], 3 => [0, 1], 5 => [1] }

#### Idiomatic Perl 6 ways

    my @x = zip(@a,@b);

    my @x = zip(@a,@b,@c);

### arrayify LIST [,LIST [,LIST...]]

Returns a list costisting of each element of the given arrays. Recursive arrays are flattened, too.

    my @a = 1, [[2], 3], 4, [5], 6, [7], 8, 9;
    my @l = arrayify @a;   # returns 1, 2, 3, 4, 5, 6, 7, 8, 9

### uniq LIST

### distinct LIST

Returns a new list by stripping duplicate values in LIST by comparing the values as hash keys, except that type objects are considered separate from ''. The order of elements in the returned list is the same as in LIST. Returns the number of unique elements in LIST if the `:scalar` named parameter has been specified.

    my @x = uniq (1, 1, 2, 2, 3, 5, 3, 4);           # returns (1,2,3,5,4)
    my $x = uniq (1, 1, 2, 2, 3, 5, 3, 4), :$scalar; # returns 5

    my @n = distinct "Mike", "Michael", "Richard", "Rick", "Michael", "Rick"
    # ("Mike", "Michael", "Richard", "Rick")

    my @s = distinct "A8", "", Str, "A5", "S1", "A5", "A8"
    # ("A8", "", Str, "A5", "S1")

    my @w = uniq "Giulia", "Giulietta", Str, "", 156, "Giulietta", "Giulia";
    # ("Giulia", "Giulietta", Str, "", 156)

`distinct` is an alias for `uniq`.

#### Idiomatic Perl 6 ways

    my @x = (1, 1, 2, 2, 3, 5, 3, 4).unique;
    my $x = (1, 1, 2, 2, 3, 5, 3, 4).unique.elems;

### singleton LIST

Returns a new list by stripping values in LIST occurring only once by comparing the values as hash keys, except that type objects are considered separate from ''. The order of elements in the returned list is the same as in LIST. Returns the number of elements occurring only once in LIST if the `:scalar` named parameter has been specified.

    my @x = singleton (1,1,4,2,2,3,3,5);          # returns (4,5)
    my $n = singleton (1,1,4,2,2,3,3,5), :scalar; # returns 2

### duplicates LIST

Returns a new list by stripping values in LIST occuring more than once by comparing the values as hash keys, except that type objects are considered separate from ''. The order of elements in the returned list is the same as in LIST. Returns the number of elements occurring more than once in LIST.

    my @y = duplicates (1,1,2,4,7,2,3,4,6,9);          # returns (1,2,4)
    my $n = duplicates (1,1,2,4,7,2,3,4,6,9), :scalar; # returns 3

#### Idiomatic Perl 6 ways

    my @y = (1,1,2,4,7,2,3,4,6,9).repeated;
    my $n = (1,1,2,4,7,2,3,4,6,9).repeated.elems;

### frequency LIST

Returns a hash of distinct values and the corresponding frequency.

    my %f := frequency values %radio_nrw; # returns (
    #  'Deutschlandfunk (DLF)' => 9, 'WDR 3' => 10,
    #  'WDR 4' => 11, 'WDR 5' => 14, 'WDR Eins Live' => 14,
    #  'Deutschlandradio Kultur' => 8,...)

#### Idiomatic Perl 6 ways

    my %f := %radio_nrw.values.Bag;

### occurrences LIST

Returns a new list of frequencies and the corresponding values from LIST.

    my @o = occurrences (1 xx 3, 2 xx 4, 3 xx 2, 4 xx 7, 5 xx 2, 6 xx 4);
    # (Any, Any, [3, 5], [1], [2, 6], Any, Any, [4])

### mode LIST

Returns the modal value of LIST. Returns the modal value only if the `:scalar` name parameter is specified. Otherwise all probes occuring *modal* times are returned as well.

    my @m = mode (1 xx 3, 2 xx 4, 3 xx 2, 4 xx 7, 5 xx 2, 6 xx 7);
    #  (7, 4, 6)
    my $mode = mode (1 xx 3, 2 xx 4, 3 xx 2, 4 xx 7, 5 xx 2, 6 xx 7), :scalar;
    #  7

Partitioning
------------

### after BLOCK, LIST

Returns a list of the values of LIST after (and not including) the point where BLOCK returns a true value. Passes the value as a parameter to BLOCK for each element in LIST in turn.

    my @x = after { $_ %% 5 }, (1..9);   # returns (6, 7, 8, 9)

### after_incl BLOCK, LIST

Same as `after` but also includes the element for which BLOCK is true.

    my @x = after_incl { $_ %% 5 }, (1..9);   # returns (5, 6, 7, 8, 9)

#### Idiomatic Perl 6 ways

    my @x = (1..9).toggle: * %% 5, :off;

### before BLOCK, LIST

Returns a list of values of LIST up to (and not including) the point where BLOCK returns a true value. Passes the value as a parameter to BLOCK for each element in LIST in turn.

    my @x = before { $_ %% 5 }, (1..9);   # returns (1, 2, 3, 4)

#### Idiomatic Perl 6 ways

    my @x = (1..9).toggle: * %% 5;

### before_incl BLOCK LIST

Same as `before` but also includes the element for which BLOCK is true.

    my @x = before_incl { $_ %% 5 }, (1..9);   # returns (1, 2, 3, 4, 5)

### part BLOCK, LIST

Partitions LIST based on the return value of BLOCK which denotes into which partition the current value is put.

Returns a list of the partitions thusly created. Each partition created is an Array.

    my $i = 0;
    my @part = part { $i++ % 2 } (1..8); # returns ([1, 3, 5, 7], [2, 4, 6, 8])

You can have a sparse list of partitions as well where non-set partitions will be an `Array` type object:

    my @part = part { 2 } (1..5);        # returns (Array, Array, [1,2,3,4,5])

Be careful with negative values, though:

    my @part = part { -1 } (1..10);
    ===============================
    Unsupported use of a negative -1 subscript to index from the end

Negative values are only ok when they refer to a partition previously created:

    my @idx  = 0, 1, -1;
    my $i    = 0;
    my @part = part { $idx[$i++ % 3] }, (1..8); # ([1, 4, 7], [2, 3, 5, 6, 8])

### samples COUNT, LIST

Returns a new list containing COUNT random samples from LIST. Is similar to [List::Util/shuffle](List::Util/shuffle), but stops after COUNT.

    my @r  = samples 10, (1..10); # same as (1..10).pick(*)
    my @r2 = samples 5, (1..10);  # same as (1..10).pick(5)

#### Idiomatic Perl 6 ways

    my @r  = (1..10).pick(*);
    my @r2 = (1..10).pick(5);

Iteration
---------

### each_array ARRAY1, ARRAY2 ...

Creates an array iterator to return the elements of the list of arrays ARRAY1, ARRAY2 throughout ARRAYn in turn. That is, the first time it is called, it returns the first element of each array. The next time, it returns the second elements. And so on, until all elements are exhausted.

This is useful for looping over more than one array at once:

    my &ea = each_array(@a, @b, @c);
    while ea() -> ($a,$b,$c) { .... }

The iterator returns the empty list when it reached the end of all arrays.

If the iterator is passed an argument of '`index`', then it returns the index of the last fetched set of values, as a scalar.

#### Idiomatic Perl 6 ways

    while zip(@a,@b,@c) -> ($a,$b,$c) { .... }

### each_arrayref LIST

Like each_array, but the arguments is a single list with arrays.

### natatime EXPR, LIST

Creates an array iterator, for looping over an array in chunks of `$n` items at a time. (n at a time, get it?). An example is probably a better explanation than I could give in words.

Example:

    my @x = 'a'..'g';
    my &it = natatime 3, @x;
    while it() -> @vals {
        print "@vals[]\n";
    }

This prints

    a b c
    d e f
    g

#### Idiomatic Perl 6 ways

    for @x.rotor(3,:partial) -> @vals {
        print "@vals[]\n";
    }

Searching
---------

### firstval BLOCK, LIST

### first_value BLOCK, LIST

Returns the first element in LIST for which BLOCK evaluates to true. Each element of LIST is passed to the BLOCK in turn. Returns `Nil` if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say firstval { .starts-with('c') }, @list;  # cicero
    say firstval { .starts-with('b') }, @list;  # beta
    say firstval { .starts-with('g') }, @list;  # Nil, because never

`first_value` is an alias for `firstval`.

#### Idiomatic Perl 6 ways

    say @list.first: *.starts-with('c');
    say @list.first: *.starts-with('b');
    say @list.first: *.starts-with('g');

### onlyval BLOCK, LIST

### only_value BLOCK, LIST

Returns the only element in LIST for which BLOCK evaluates to true. Each element in LIST is passed to BLOCK in turn. Returns `Nil` if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say onlyval { .starts-with('c') }, @list;  # cicero
    say onlyval { .starts-with('b') }, @list;  # Nil, because twice
    say onlyval { .starts-with('g') }, @list;  # Nil, because never

`only_value` is an alias for `onlyval`.

### lastval BLOCK, LIST

### last_value BLOCK, LIST

Returns the last value in LIST for which BLOCK evaluates to true. Each element in LIST is passed to BLOCK in turn. Returns `Nil` if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say lastval { .starts-with('c') }, @list;  # cicero
    say lastval { .starts-with('b') }, @list;  # bearing
    say lastval { .starts-with('g') }, @list;  # Nil, because never

`last_value` is an alias for `lastval`.

#### Idiomatic Perl 6 ways

    say @list.first: *.starts-with('c'), :end;
    say @list.first: *.starts-with('b'), :end;
    say @list.first: *.starts-with('g'), :end;

### firstres BLOCK, LIST

### first_result BLOCK, LIST

Returns the result of BLOCK for the first element in LIST for which BLOCK evaluates to true. Each element of LIST is passed to BLOCK in turn. Returns `Nil` if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say firstres { .uc if .starts-with('c') }, @list;  # CICERO
    say firstres { .uc if .starts-with('b') }, @list;  # BETA
    say firstres { .uc if .starts-with('g') }, @list;  # Nil, because never

`first_result` is an alias for `firstres`.

### onlyres BLOCK, LIST

### only_result BLOCK, LIST

Returns the result of BLOCK for the first element in LIST for which BLOCK evaluates to true. Each element of LIST is passed to BLOCK in turn. Returns `Nil` if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say onlyres { .uc if .starts-with('c') }, @list;  # CICERO
    say onlyres { .uc if .starts-with('b') }, @list;  # Nil, because twice
    say onlyres { .uc if .starts-with('g') }, @list;  # Nil, because never

`only_result` is an alias for `onlyres`.

### lastres BLOCK, LIST

### last_result BLOCK, LIST

Returns the result of BLOCK for the last element in LIST for which BLOCK evaluates to true. Each element of LIST is passed to BLOCK in turn. Returns `Nil` if no such element has been found.

    my @list = <alpha beta cicero bearing effortless>;
    say lastval { .uc if .starts-with('c') }, @list;  # CICERO
    say lastval { .uc if .starts-with('b') }, @list;  # BEARING
    say lastval { .uc if .starts-with('g') }, @list;  # Nil, because never

`last_result` is an alias for `lastres`.

### indexes BLOCK, LIST

Evaluates BLOCK for each element in LIST (passed to BLOCK as the parameter) and returns a list of the indices of those elements for which BLOCK returned a true value. This is just like `grep` only that it returns indices instead of values:

    my @x = indexes { $_ %% 2 } (1..10);   # returns (1, 3, 5, 7, 9)

#### Idiomatic Perl 6 ways

    my @x = (1..10).grep: * %% 2, :k;

### firstidx BLOCK, LIST

### first_index BLOCK, LIST

Returns the index of the first element in LIST for which the criterion in BLOCK is true. Passes each element in LIST to BLOCK in turn:

    my @list = 1, 4, 3, 2, 4, 6;
    printf "item with index %i in list is 4", firstidx { $_ == 4 }, @list;
    ===============================
    item with index 1 in list is 4

Returns `-1` if no such item could be found.

    my @list = 1, 3, 4, 3, 2, 4;
    print firstidx { $_ == 3 }, @list;    # 1
    print firstidx { $_ == 5 }, @list;    # -1, because not found

`first_index` is an alias for `firstidx`.

#### Idiomatic Perl 6 ways

    printf "item with index %i in list is 4", @list.first: * == 4, :k;

    print @list.first: * == 3, :k;
    print @list.first( * == 5, :k) // -1;  # not found == Nil

### onlyidx BLOCK, LIST

### only_index BLOCK, LIST

Returns the index of the only element in LIST for which the criterion in BLOCK is true. Passes each element in LIST to BLOCK in turn:

    my @list = 1, 3, 4, 3, 2, 4;
    printf "uniqe index of item 2 in list is %i", onlyidx { $_ == 2 }, @list;
    ===============================
    unique index of item 2 in list is 4

Returns `-1` if either no such item or more than one of these has been found.

    my @list = 1, 3, 4, 3, 2, 4;
    print onlyidx { $_ == 3 }, @list;    # -1, because more than once
    print onlyidx { $_ == 5 }, @list;    # -1, because not found

`only_index` is an alias for `onlyidx`.

### lastidx BLOCK, LIST

### last_index BLOCK, LIST

Returns the index of the last element in LIST for which the criterion in BLOCK is true. Passes each element in LIST to BLOCK in turn:

    my @list = 1, 4, 3, 2, 4, 6;
    printf "item with index %i in list is 4", lastidx { $_ == 4 } @list;
    ==================================
    item with index 4 in list is 4

Returns `-1` if no such item could be found.

    my @list = 1, 3, 4, 3, 2, 4;
    print lastidx { $_ == 3 }, @list;    # 3
    print lastidx { $_ == 5 }, @list;    # -1, because not found

`last_index` is an alias for `lastidx`.

#### Idiomatic Perl 6 ways

    printf "item with index %i in list is 4", @list.first: * == 4, :k, :end;

    print @list.first: * == 3, :k, :end;
    print @list.first( * == 5, :k, :end) // -1;  # not found == Nil

Sorting
-------

### sort_by BLOCK, LIST

Returns the list of values sorted according to the string values returned by the BLOCK. A typical use of this may be to sort objects according to the string value of some accessor, such as:

    my @sorted = sort_by { .name }, @people;

The key function is being passed each value in turn, The values are then sorted according to string comparisons on the values returned. This is equivalent to:

    my @sorted = sort -> $a, $b { $a.name cmp $b.name }, @people;

except that it guarantees the `name` accessor will be executed only once per value. One interesting use-case is to sort strings which may have numbers embedded in them "naturally", rather than lexically:

    my @sorted = sort_by { S:g/ (\d+) / { sprintf "%09d", $0 } / }, @strings;

This sorts strings by generating sort keys which zero-pad the embedded numbers to some level (9 digits in this case), helping to ensure the lexical sort puts them in the correct order.

#### Idiomatic Perl 6 ways

    my @sorted = @people.sort: *.name;

### nsort_by BLOCK, LIST

Similar to `sort_by` but compares its key values numerically.

#### Idiomatic Perl 6 ways

    my @sorted = <10 1 20 42>.sort: +*;

### qsort BLOCK, ARRAY

This sorts the given array **in place** using the given compare code. The Perl 6 version uses the basic sort functionality as provided by the `sort` built-in function.

#### Idiomatic Perl 6 ways

    @people .= sort;

Searching in sorted Lists
-------------------------

### bsearch BLOCK, LIST

Performs a binary search on LIST which must be a sorted list of values. BLOCK receives each element in turn and must return a negative value if the element is smaller, a positive value if it is bigger and zero if it matches.

Returns a boolean value if the `:scalar` named parameter is specified. Otherwise it returns a single element list if it was found, or the empty list if none of the calls to BLOCK returned `0`.

    my @list  = <alpha beta cicero delta>;
    my @found = bsearch { $_ cmp "cicero" }, @list;   # ("cicero",)
    my @found = bsearch { $_ cmp "effort" }, @list;   # ()

    my @list  = <alpha beta cicero delta>;
    my $found = bsearch { $_ cmp "cicero" }, @list, :scalar;   # True
    my $found = bsearch { $_ cmp "effort" }, @list, :scalar;   # False

### bsearchidx BLOCK, LIST

### bsearch_index BLOCK, LIST

Performs a binary search on LIST which must be a sorted list of values. BLOCK receives each element in turn and must return a negative value if the element is smaller, a positive value if it is bigger and zero if it matches.

Returns the index of found element, otherwise `-1`.

    my @list  = <alpha beta cicero delta>;
    my $found = bsearchidx { $_ cmp "cicero" }, @list;   # 2
    my $found = bsearchidx { $_ cmp "effort" }, @list;   # -1

`bsearch_index` is an alias for `bsearchidx`.

### lower_bound BLOCK, LIST

Returns the index of the first element in LIST which does not compare *less than val*. Technically it's the first element in LIST which does not return a value below zero when passed to BLOCK.

    my @ids = 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6;
    my $lb = lower_bound { $_ <=> 2 }, @ids; # 1
    my $lb = lower_bound { $_ <=> 4 }, @ids; # 9

### upper_bound BLOCK, LIST

Returns the index of the first element in LIST which does not compare *greater than val*. Technically it's the first element in LIST which does not return a value below or equal to zero when passed to BLOCK.

    my @ids = 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6;
    my $ub = upper_bound { $_ <=> 2 }, @ids; # 3
    my $ub = upper_bound { $_ <=> 4 }, @ids; # 13

### equal_range BLOCK, LIST

Returns a list of indices containing the `lower_bound` and the `upper_bound` of given BLOCK and LIST.

    my @ids = 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6;
    my $er = equal_range { $_ <=> 2 }, @ids; # (1,3)
    my $er = equal_range { $_ <=> 4 }, @ids; # (9,13)

Operations on sorted Lists
--------------------------

### binsert BLOCK, ITEM, LIST

### bsearch_insert BLOCK, ITEM, LIST

Performs a binary search on LIST which must be a sorted list of values. BLOCK must return a negative value if the current element (passed as a parameter to the BLOCK) is smaller, a positive value if it is bigger and zero if it matches.

ITEM is inserted at the index where the ITEM should be placed (based on above search). That means, it's inserted before the next bigger element.

    my @l = 2,3,5,7;
    binsert { $_ <=> 4 },  4, @l; # @l = (2,3,4,5,7)
    binsert { $_ <=> 6 }, 42, @l; # @l = (2,3,4,5,42,7)

You take care that the inserted element matches the compare result.

`bsearch_insert` is an alias for `binsert`.

### bremove BLOCK, LIST

### bsearch_remove BLOCK, LIST

Performs a binary search on LIST which must be a sorted list of values. BLOCK must return a negative value if the current element (passed as a parameter to the BLOCK) is smaller, a positive value if it is bigger and zero if it matches.

The item at the found position is removed and returned.

    my @l = 2,3,4,5,7;
    bremove { $_ <=> 4 }, @l; # @l = (2,3,5,7);

`bsearch_remove` is an alias for `bremove`.

Counting and calculation
------------------------

### true BLOCK, LIST

Counts the number of elements in LIST for which the criterion in BLOCK is true. Passes each item in LIST to BLOCK in turn:

    printf "%i item(s) are defined", true { defined($_) }, @list;

#### Idiomatic Perl 6 ways

    print "@list.grep(*.defined).elems() item(s) are defined";

### false BLOCK, LIST

Counts the number of elements in LIST for which the criterion in BLOCK is false. Passes each item in LIST to BLOCK in turn:

    printf "%i item(s) are not defined", false { defined($_) }, @list;

#### Idiomatic Perl 6 ways

    print "@list.grep(!*.defined).elems() item(s) are not defined";

### reduce_0 BLOCK, LIST

Reduce LIST by calling BLOCK in scalar context for each element of LIST. The first parameter contains the progressional result and is initialized with **0**. The second parameter contains the currently being processed element of LIST.

    my $reduced = reduce_0 -> $a, $b { $a + $b }, @list;

In the Perl 5 version, `$_` is also set to the index of the element being processed. This is not the case in the Perl 6 version for various reasons. Should you need the index value in your calculation, you can post-increment the anonymous state variable instead: `$++`:

    my $reduced = reduce_0 -> $a, $b { dd $++ }, @list; # 0 1 2 3 4 5 ...

The idea behind reduce_0 is **summation** (addition of a sequence of numbers).

### reduce_1 BLOCK, LIST

Reduce LIST by calling BLOCK in scalar context for each element of LIST. The first parameter contains the progressional result and is initialized with **1**. The second parameter contains the currently being processed element of LIST.

    my $reduced = reduce_1 -> $a, $b { $a * $b }, @list;

In the Perl 5 version, `$_` is also set to the index of the element being processed. This is not the case in the Perl 6 version for various reasons. Should you need the index value in your calculation, you can post-increment the anonymous state variable instead: `$++`:

    my $reduced = reduce_1 -> $a, $b { dd $++ }, @list; # 0 1 2 3 4 5 ...

The idea behind reduce_1 is **product** of a sequence of numbers.

### reduce_u BLOCK, LIST

Reduce LIST by calling BLOCK in scalar context for each element of LIST. The first parameter contains the progressional result and is initialized with **Any**. The second parameter contains the currently being processed element of LIST.

    my $reduced = reduce_u -> $a, $b { $a.push($b) }, @list;

In the Perl 5 version, `$_` is also set to the index of the element being processed. This is not the case in the Perl 6 version for various reasons. Should you need the index value in your calculation, you can post-increment the anonymous state variable instead: `$++`:

    my $reduced = reduce_u -> $a, $b { dd $++ }, @list; # 0 1 2 3 4 5 ...

The idea behind reduce_u is to produce a list of numbers.

### minmax LIST

Calculates the minimum and maximum of LIST and returns a two element list with the first element being the minimum and the second the maximum. Returns the empty list if LIST was empty.

    my ($min,$max) = minmax (43,66,77,23,780); # (23,780)

#### Idiomatic Perl 6 ways

    my $range = <43,66,77,23,780>.minmax( +* );
    my $range = (43,66,77,23,780).minmax;   # auto-numerically compares

### minmaxstr LIST

Computes the minimum and maximum of LIST using string compare and returns a two element list with the first element being the minimum and the second the maximum. Returns the empty list if LIST was empty.

    my ($min,$max) = minmaxstr <foo bar baz zippo>; # <bar zippo>

#### Idiomatic Perl 6 ways

    my $range = (43,66,77,23,780).minmax( ~* );
    my $range = <foo bar baz zippo>.minmax;  # auto-string compares

SEE ALSO
========

[List::Util](List::Util), [List::AllUtils](List::AllUtils), [List::UtilsBy](List::UtilsBy)

THANKS
======

Thanks to all of the individuals who have contributed to the Perl 5 version of this module.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-MoreUtils . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5 version originally developed by Tassilo von Parseval, subsequently maintained by Adam Kennedy and Jens Rehsack.

