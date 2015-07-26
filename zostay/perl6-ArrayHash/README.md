NAME
====

ArrayHash - a data structure that is both Array and Hash

SYNOPSIS
========

    use ArrayHash;

    my @array := array-hash('a' =x> 1, 'b' => 2);
    my %hash := @array;

    @array[0].say; #> "a" =x> 1
    %hash<b> = 3;
    @array[1].say; #> "b" =x> 3;

    # The order of the keys is preserved
    for %hash.kv -> $k, $v { 
        say "$k: $v";
    }

    # Note, the special ip operation, here is a significant interface
    # difference from a usual array, .kv is always a key-value alternation,
    # there's also an .ikv:
    for @array.ip -> $i, $p {
        say "$p.key: $p.value is #$i";
    }

DESCRIPTION
===========

**Experimental:** The API here is experimental. Some important aspects of the API may change without warning.

You can think of this as a [Hash](Hash) that always iterates in insertion order or you can think of this as an [Array](Array) of [Pair](Pair)s with fast lookups by key. Both are correct, though it really is more hashish than arrayish because of the Pairs, which is why it's an ArrayHash and not a HashArray. 

This class uses [KnottyPair](KnottyPair) internally, rather than plain old Pairs, but you can usually use either when interacting with objects of this class.

An ArrayHash is both Associative and Positional. This means you can use either a `@` sigil or a `%` sigil safely. However, there is some amount of conflicting tension between a [Positional](Positional) and [Assocative](Assocative) data structure. An Associative object in Perl requires unique keys and has no set order. A Positional, on the othe rhand, is a set order, but no inherent uniqueness invariant. The primary way this tension is resolved depends on whether the operations you are performing are hashish or arrayish.

For example, consider this `push` operation:

    my @a := array-hash('a' =x> 1, 'b' =x> 2);
    @a.push: 'a' =x> 3, b => 4;
    @a.perl.say;
    #> array-hash(KnottyPair, "b" =x> 4, "a" =x> 3);

Here, the `push` is definitely an arrayish operation, but it is given both an arrayish argument, `'a' =x> 3`, and a hashish argument `b => 4`. Therefore, the [KnottyPair](KnottyPair) keyed with `"a"` is pushed onto the end of the ArrayHash and the earlier value is nullified. The [Pair](Pair) keyed with `"b"` performs a more hash-like operation and replaces the value on the existing pair.

Now, compare this to a similar `unshit` operation:

    my @a := array-hash('a' =x> 1, 'b' =x> 2);
    @a.unshift: 'a' =x> 3, b => 4;
    @a.perl.say;
    #> array-hash(KnottyPair, 'a' =x> 1, 'b' =x> 2);

What happened? Why didn't the values changed and where did this extra [KnottyPair](KnottyPair) come from? Again, `unshift` is arrayish and we have an arrayish and a hashish argument, but this time we demonstrate another normal principle of Perl hashes that is enforced, which is, when dealing with a list of [Pair](Pair)s, the latest Pair is the one that bequeaths its value to the hash. That is,

    my %h = a => 1, a => 2;
    say "a = %h<a>";
    #> a = 2

Since an [ArrayHash](ArrayHash) maintains its order, this rule always applies. A value added near the end will win over a value at the beginning. Adding a value near the beginning will lose to a value nearer the end.

So, returning to the `unshift` example above, the arrayish value with key `"a"` gets unshifted to the front of the array, but immediately nullified because of the later value. The hashish value with key `"b"` sees an existing value for the same key and the existing value wins since it would come after it. 

The same rule holds for all operations: If the key already exists, but before the position the value is being added, the new value wins. If the key already exists, but after the position we are inserting, the old value wins.

For a regular ArrayHash, the losing value will either be replaced, if the operation is hashish, or will be nullified, if the operation is arrayish. 

This might not always be the desired behavior so this module also provides the multivalued ArrayHash, or multi-hash:

    my @a := multi-hash('a' =x> 1, 'b' =x> 2);
    @a.push: 'a' =x> 3, b => 4;
    @a.perl.say;
    #> multi-hash('a' =x> 1, "b" =x> 4, "a" =x> 3);

The operations all work the same, but array values are not nullified and it is find for there to be multiple values in the array. This is the same class, ArrayHash, but the [has $.multivalued](has $.multivalued) property is set to true.

[Conjecture: Consider adding a `has $.collapse` attribute or some such to govern whether a replaced value in a `$.multivalued` array hash is replaced with a type object or spiced out. Or perhaps change the `$.multivalued` into an enum of operational modes.]

[Conjecture: In the future, a parameterizable version of this class could be created with some sort of general keyable object trait rather than KnottyPair.]

Methods
=======

method multivalued
------------------

    method multivalued() returns Bool:D

This setting determines whether the ArrayHash is a regular array-hash or a multi-hash. Usually, you will use the [sub array-hash](sub array-hash) or [sub multi-hash](sub multi-hash) constructors rather than setting this directly on the constructor.

method new
----------

    method new(Bool :multivalued = False, *@a, *%h) returns ArrayHash:D

Constructs a new ArrayHash. This is not the preferred method of construction. You should use [sub array-hash](sub array-hash) or [sub multi-hash](sub multi-hash) instead.

method of
---------

    method of() returns Mu:U

Returns what type of values are stored. This always returns a [KnottyPair](KnottyPair) type object.

method postcircumfix:<{ }>
--------------------------

    method postcircumfix:<( )>(ArrayHash:D: $key) returns Mu

This provides the usual value lookup by key. You can use this to retrieve a value, assign a value, or bind a value. You may also combine this with the hash adverbs `:delete` and `:exists`.

method postcircumfix:<[ ]>
--------------------------

    method postcircumfix:<[ ]>(ArrayHash:D: Int:D $pos) returns KnottyPair

This returns the value lookup by index. You can use this to retrieve the pair at the given index or assign a new pair or even bind a pair. It may be combined with the array adverts `:delete` and `:exists` as well.

method push
-----------

    method push(ArrayHash:D: *@values, *%values) returns ArrayHash:D

Adds the given values onto the end of the ArrayHash. These values will replace any existing values with matching keys. If the values pushed are [Pair](Pair)s (hashish interface), then the existing values are replaced. If the values are [KnottyPair](KnottyPair)s (arrayish interface), then new values are added to the end of the ArrayHash.

    my @a := array-hash('a' =x> 1, 'b' =x> 2);
    @a.push: 'a' =x> 3, b => 4, 'c' =x> 5;
    @a.perl.say; 
    #> array-hash(KnottyPair, "b" =x> 4, "a" =x> 3, "c" =x> 5);

    my @m := multi-hash('a' =x> 1, 'b' =x> 2);
    @m.push: 'a' =x> 3, b => 4, 'c' =x> 5;
    @m.perl.say; 
    #> multi-hash("a" =x> 1, "b" =x> 4, "a" =x> 3, "c" =x> 5);

method unshift
--------------

    method unshift(ArrayHash:D: *@values, *%values) returns ArrayHash:D

Adds the given values onto the front of the ArrayHash. These values will never replace any existing values in the data structure. If the values are passed as [KnottyPair](KnottyPair)s, these pairs will be put onto the front of the data structure without changing the primary keyed value. These insertions will be nullified if the hash is not multivalued.

    my @a := array-hash('a' =x> 1, 'b' =x> 2);
    @a.unshift 'a' =x> 3, b => 4, 'c' =x> 5;
    @a.perl.say; 
    #> array-hash(KnottyPair, "c" =x> 5, "a" =x> 1, "b" =x> 2);

    my @m := multi-hash('a' =x> 1, 'b' =x> 2);
    @m.push: 'a' =x> 3, b => 4, 'c' =x> 5;
    @m.perl.say; 
    #> multi-hash("a" =x> 3, "c" =x> 5, "a" =x> 1, "b" =x> 2);

method splice
-------------

    multi method splice(ArrayHash:D: &offset, Int(Cool) $size? *@values, *%values) returns ArrayHash:D
    multi method splice(ArrayHash:D: Int(Cool) $offset, &size, *@values, *%values) returns ArrayHash:D
    multi method splice(ArrayHash:D: &offset, &size, *@values, *%values) returns ArrayHash:D
    multi method splice(ArrayHash:D: Int(Cool) $offset = 0, Int(Cool) $size?, *@values, *%values) returns ArrayHash:D

This is a general purpose splice method for ArrayHash. As with [Array](Array) splice, it is able to perform most modification operations.

    my KnottyPair $p;
    my @a := array-hash( ... );

    @a.splice: *, 0, "a" =x> 1;  # push
    $p = @a.splice: *, 1;        # pop
    @a.splice: 0, 0, "a" =x> 1;  # unshift
    $p = @a.splice: *, 1;        # shift
    @a.splice: 3, 1, "a" =x> 1;  # assignment
    @a.splice: 4, 1, "a" =X> $a; # binding
    @a.splice: 5, 1, KnottyPair; # deletion

    # And some operations that are uniqe to splice
    @a.splice: 1, 3;             # delete and squash
    @a.splice: 3, 0, "a" =x> 1;  # insertion

    # And the no-op, the $offset could be anything legal
    @a.splice: 4, 0;

The `$offset` is a point in the ArrayHash to perform the work. It is not an index, but a boundary between indexes. The 0th offset is just before index 0, the 1st offset is after index 0 and before index 1, etc.

The `$size` determines how many elements after `$offset` will be removed. These are returned as a new ArrayHash.

The `%values` and `@values` are a list of new values to insert. If empty, no new values are inserted. The number of elements inserted need not have any relationship to the number of items removed.

This method will fail with an [X::OutOfRange](X::OutOfRange) exception if the `$offset` or `$size` is out of range.

**Caveat:** It should be clarified that splice does not perform precisely the same sort of operation its named equivalent would. Unlike [#method push](#method push) or [#method unshift](#method unshift), all arguments are treated as arrayish. This is because a splice is very specific about what parts of the data structure are being manipulated.

[Conjecture: Is the caveat correct or should [Pair](Pair)s be treated as hashish instead anyway?]

method sort
-----------

    method sort(ArrayHash:D: 5by = &infix:<cmp>) returns ArrayHash:D

This is not yet implemented.

method unique
-------------

    method unique(ArrayHash:D:) returns ArrayHash:D

For a multivalued hash, this returns the same hash as a non-multivalued hash. Otherwise, it returns itself. 

method squish
-------------

    method squish(ArrayHash:D:) returns ArrayHash:D

This is not yet implemented.

method rotor
------------

Not yet implemented.

method pop
----------

    method pop(ArrayHash:D:) returns KnottyPair

Takes the last element off the ArrayHash and returns it.

method shift
------------

    method shift(ArrayHash:D:) returns KnottyPair

Takes the first element off the ArrayHash and returns it.

method values
-------------

    method values() returns List:D

Returns all the values of the stored pairs in insertion order.

method keys
-----------

    method keys() returns List:D

Returns all the keys of the stored pairs in insertion order.

method indexes
--------------

    method index() returns List:D

This returns the indexes of the ArrayHash, similar to what would be returned by [Array#method keys](Array#method keys).

method kv
---------

    method kv() returns List:D

This returns an alternating list of key/value pairs. The list is always returned in insertion order.

method ip
---------

    method ip() returns List:D

This returns an alternating list of index/pair pairs. This is similar to what would be returned by [Array#method kv](Array#method kv) storing [Pair](Pair)s.

method ikv
----------

    method ikv() returns List:D

This returns an alternating list of index/key/value tuples. This list is always returne d in insertion order.

method pairs
------------

    method pairs() returns List:D

This returns a list of pairs stored in the ArrayHash.

method invert
-------------

    method invert() returns List:D

Not yet implemented.

method antipairs
----------------

    method antipairs() returns List:D

Not yet implemented.

method permutations
-------------------

Not yet implemented.

method perl
-----------

    multi method perl(ArrayHash:D:) returns Str:D

Returns the Perl code that could be used to recreate this list.

method gist
-----------

    multi method gist(ArrayHash:D:) returns Str:D

Returns the Perl code that could be used to recreate this list, up to the 100th element.

method fmt
----------

    method fmt($format = "%s\t%s", $sep = "\n") returns Str:D

Prints the contents of the ArrayHash using the given format and separator.

method reverse
--------------

    method reverse(ArrayHash:D:) returns ArrayHash:D

Returns the ArrayHash, but with pairs inserted in reverse order.

method rotate
-------------

    method rotate(ArrayHash:D: Int $n = 1) returns ArrayHash:D

Returns the ArrayHash, but with the pairs inserted rotated by `$n` elements.

sub array-hash
--------------

    sub array-hash(*@a, *%h) returns ArrayHash:D where { !*.multivalued }

Constructs a new ArrayHash with multivalued being false, containing the given initial pairs in the given order (or whichever order Perl picks arbitrarily if passed as [Pair](Pair)s.

sub multi-hash
--------------

    sub multi-hash(*@a, *%h) returns ArrayHash:D where { *.multivalued }

Constructs a new multivalued ArrayHash containing the given initial pairs in the given order. (Again, if you use [Pair](Pair)s to do the initial insertion, the order will be randomized, but stable upon insertion.)
