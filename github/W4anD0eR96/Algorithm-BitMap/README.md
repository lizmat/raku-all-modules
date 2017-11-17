NAME
====

Algorithm::BitMap - Efficient way to handle Boolean vector

SYNOPSIS
========

    use Algorithm::BitMap;

    my $bitmap1 = BitMap.new;
    my $bitmap2 = BitMap.new;

    say $bitmap1.set(4);
    say $bitmap2.fill;

    say $bitmap1 +| $bitmap2;
    say $bitmap1;

    say $bitmap1 +^= $bitmap2;
    say $bitmap1;

DESCRIPTION
===========

Algorithm::BitMap is an efficient way to handle Boolean vector.

It is use an Int value `$.bits` to simulate bool vector by its binary representation.

Attention, when you get new BitMap by operating some previous BitMap, the new one will be initialized using the least bits it needs. So the result of `(10000)_2 +^ (10010)_2 ` is `(10)_2`. To negate or fill the BitMap properly, you can `align` it at first.

CONSTRUCTOR
-----------

### `method new`

Defined as:

    multi method new()
    multi method new(:n!)
    multi method new(:bits!)

With no named parameters passed, it constructs a `BitMap` initialized to be all `0`.

If you provide `:n`, then the constructor builds a `BitMap` having n bits.

If you provide `:bits`, then the constructor build a `BitMap` having same `bits`.

SUBROUTINE
----------

### `method align`

Defined as:

    multi method align(Int $n)

Set size of the BitMap to be `$n`.

### `method set`

Defined as:

    multi method set(Int $n)

Set the n-th bit of the BitMap, base on 0. It will modify the invocant.

### `method unset`

Defined as:

    multi method unset(Int $n)

Unset the n-th bit of the BitMap, base on 0. It will modify the invocant.

### `method fill`

Defined as:

    multi method fill()

Set all bits of the BitMap. It will modify the invocant.

### `method clear`

Defined as:

    multi method clear()

Unset all bits of the BitMap. It will modify the invocant.

### `method get`

Defined as:

    multi method get(Int $n)

Returns the n-th bits of the BitMap, base on 0.

### `method and`

Defined as:

    multi method and(BitMap \other)

Returns this BitMap bitwise AND the other BitMap.

### `sub infix:<+&>`

Defined as:

    multi sub infix:<+&>(BitMap \this, BitMap \other)

Same as `this.and(other)`.

### `method or`

Defined as:

    multi method or(BitMap \other)

Returns this BitMap bitwise OR the other BitMap.

### `sub infix:<+|>`

Defined as:

    multi sub infix:<+|>(BitMap \this, BitMap \other)

Same as `this.or(other)`.

### `method xor`

Defined as:

    multi method xor(BitMap \other)

Returns this BitMap bitwise XOR the other BitMap.

### `sub infix:<+^>`

Defined as:

    multi sub infix:<+^>(BitMap \this, BitMap \other)

Same as `this.xor(other)`.

### `method neg`

Defined as:

    multi method neg()

Returns the BitMap bitwise negated.

### `sub prefix:<+^>`

Defined as:

    multi sub prefix:<+^>(BitMap \this)

Same as `this.neg`.

### `method and-not`

Defined as:

    multi method and-not(BitMap \other)

Returns this BitMap bitwise AND-NOT the other BitMap.

### `sub infix:<+&^>`

Defined as:

    multi sub infix:<+&^>(BitMap \this, BitMap \other)

Same as `this.and-not(other)`.

### `method equals`

Defined as:

    multi method equals(BitMap \other)

Returns whether this BitMap equals the other BitMap.

### `sub infix:<eq>`

Defined as:

    multi sub infix:<eq>(BitMap \this, BitMap \other)

Same as `this.equals(other)`.

### `method count`

Defined as:

    multi method count()

Returns how many `1`s the BitMap has.

### `method Str`

Defined as:

    multi method Str()

Returns binary representation of the BitMap.

AUTHOR
======

Alex Chen <wander4096@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Alex Chen

The Artistic License 2.0
