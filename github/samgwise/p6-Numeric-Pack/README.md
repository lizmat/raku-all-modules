[![Build Status](https://travis-ci.org/samgwise/p6-Numeric-Pack.svg?branch=master)](https://travis-ci.org/samgwise/p6-Numeric-Pack)

NAME
====

Numeric::Pack - Convert perl6 Numerics to Bufs and back again!

SYNOPSIS
========

    use Numeric::Pack :ALL;

    # pack and unpack floats
    my Buf $float-buf = pack-float 2.5;
    say "{ $float-buf.perl } -> { unpack-float $float-buf }";

    # pack and unpack doubles
    my Buf $double-buf = pack-double 2.5;
    say "{ $double-buf.perl } -> { unpack-double $double-buf }";

    # pack and unpack Int (see also int64 variants)
    my Buf $int-buf = pack-int32 11;
    say "{ $int-buf.perl } -> { unpack-int32 $int-buf }";

    # pack and unpack specific byte orders (big-endian is the default)
    my Buf $little-endian-buf = pack-int32 11, :byte-order(little-endian);
    say "{ $little-endian-buf.perl } -> {
      unpack-int32 $little-endian-buf, :byte-order(little-endian)
    }";

DESCRIPTION
===========

Numeric::Pack is a Perl6 module for packing values of the Numeric role into Buf objects (With the exception of Complex numbers). Currently there are no core language mechanisms for packing the majority of Numeric types into C compatible Bufs. The experimental pack language feature module does not yet implement packing to and from floating-point representations, A feature used by many modules in the Perl5 pack and unpack routines, (Since righting this the 5Pack module was released). Numeric::Pack fills this gap in functionality through utilising the facilities offered by the core NativeCall module and is now pure perl. Fixed size integer types are included for completeness and are used internally to assist in assessing a system's byte ordering.

Byte ordering is controlled with the ByteOrder enum.

Numeric::Pack exports the enum ByteOrder by default (ByteOrder is exported as :MANDATORY).

<table class="pod-table">
<thead><tr>
<th>ByteOrder</th> <th>Description</th>
</tr></thead>
<tbody>
<tr> <td>native-endian</td> <td>The native byte ordering of the current system</td> </tr> <tr> <td>little-endian</td> <td>Common byte ordering of contemporary CPUs</td> </tr> <tr> <td>big-endian</td> <td>Also known as network byte order</td> </tr>
</tbody>
</table>

By default Numeric::Pack's pack and unpack functions return and accept big-endian Bufs. To override this provide the :byte-order named parameter with the enum value for your desired behaviour. To disable byte order management pass :byte-order(native-endian).

Use Numeric::Pack :ALL to export all exportable functionality.

Use :floats or :ints flags to export subsets of the module's functionality.

<table class="pod-table">
<thead><tr>
<th>Export tag</th> <th>Functions</th>
</tr></thead>
<tbody>
<tr> <td>:floats</td> <td>pack-float, unpack-float, pack-double, unpack-double</td> </tr> <tr> <td>:ints</td> <td>pack-uint32, pack-int32, unpack-int32, unpack-uint32, pack-int64, unpack-int64, pack-uint64, unpack-uint64</td> </tr>
</tbody>
</table>

TODO
====

  * larger types

  * smaller types

  * optimise memory management

CHANGES
=======

<table class="pod-table">
<tbody>
<tr> <td>Removed bundled native library, now pure perl6</td> <td>Improved portability and reliability</td> <td>2018-06-20</td> </tr> <tr> <td>Added pack-uint32, pack-uint32 and unpack-uint32</td> <td>Added support for unsigned types</td> <td>2017-04-20</td> </tr> <tr> <td>Changed named argument :endianness to :byte-order</td> <td>Signatures now read more naturally</td> <td>2016-08-30</td> </tr>
</tbody>
</table>

AUTHOR
======

Sam Gillespie <samgwise@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

FUNCTIONS
=========

### sub pack-float

```perl6
sub pack-float(
    Cool $rat,
    ByteOrder :$byte-order = { ... }
) returns Buf
```

Pack a Rat into a single-precision floating-point Buf (e.g. float). Exported via tag :floats. Be aware that Rats and floats are not directly analogous and as such you should expect some variation in the values packed via this method and the original value.

### sub unpack-float

```perl6
sub unpack-float(
    Buf $float-buf,
    ByteOrder :$byte-order = { ... }
) returns Rat
```

Unpack a Buf containing a single-precision floating-point number (float) into a Numeric. Returns a Rat object on a NaN buffer. Exported via tag :floats.

### sub pack-int32

```perl6
sub pack-int32(
    Cool $int,
    ByteOrder :$byte-order = { ... }
) returns Buf
```

Pack an Int to a 4 byte integer buffer Exported via tag :ints. Be aware that the behaviour of Int values outside the range of a signed 32bit integer [−2,147,483,648 to 2,147,483,647] is undefined.

### sub unpack-int32

```perl6
sub unpack-int32(
    Buf $int-buf,
    ByteOrder :$byte-order = { ... }
) returns Int
```

Unpack a signed 4 byte integer buffer. Exported via tag :ints.

### sub pack-uint32

```perl6
sub pack-uint32(
    Cool $int,
    ByteOrder :$byte-order = { ... }
) returns Buf
```

Pack an Int to a 4 byte unsigned integer buffer Exported via tag :ints. Be aware that the behaviour of Int values outside the range of a signed 32bit integer [0 to 4,294,967,295] is undefined.

### sub unpack-uint32

```perl6
sub unpack-uint32(
    Buf $int-buf,
    ByteOrder :$byte-order = { ... }
) returns Int
```

Unpack an unsigned 4 byte integer buffer. Exported via tag :ints.

### sub pack-double

```perl6
sub pack-double(
    Cool $rat,
    ByteOrder :$byte-order = { ... }
) returns Buf
```

Pack a Rat into a double-precision floating-point Buf (e.g. double). Exported via tag :floats. Be aware that Rats and doubles are not directly analogous and as such you should expect some variation in the values packed via this method and the original value.

### sub unpack-double

```perl6
sub unpack-double(
    Buf $double-buf,
    ByteOrder :$byte-order = { ... }
) returns Rat
```

Unpack a Buf containing a double-precision floating-point number (double) into a Numeric. Returns a Rat on NaN buffer. Exported via tag :floats.

### sub pack-int64

```perl6
sub pack-int64(
    Cool $int,
    ByteOrder :$byte-order = { ... }
) returns Buf
```

Pack an Int to an 8 byte integer buffer Exported via tag :ints. Be aware that the behaviour of Int values outside the range of a signed 64bit integer [−9,223,372,036,854,775,808 to 9,223,372,036,854,775,807] is undefined.

### sub unpack-int64

```perl6
sub unpack-int64(
    Buf $int-buf,
    ByteOrder :$byte-order = { ... }
) returns Int
```

Unpack a signed 8 byte integer buffer. Exported via tag :ints.

### sub pack-uint64

```perl6
sub pack-uint64(
    Cool $int,
    ByteOrder :$byte-order = { ... }
) returns Buf
```

Pack an Int to an 8 byte unsigned integer buffer Exported via tag :ints. Be aware that the behaviour of Int values outside the range of a signed 64bit integer [0 to 18,446,744,073,709,551,615] is undefined.

### sub unpack-uint64

```perl6
sub unpack-uint64(
    Buf $int-buf,
    ByteOrder :$byte-order = { ... }
) returns Int
```

Unpack an unsigned 8 byte integer buffer. Exported via tag :ints.

