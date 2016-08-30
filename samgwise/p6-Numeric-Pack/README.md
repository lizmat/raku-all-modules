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

Numeric::Pack is a Perl6 module for packing values of the Numeric role into Buf objects (With the exception of Complex numbers). Currently there are no core language mechanisms for packing the majority of Numeric types into Bufs. Both the experimental pack language feature and the PackUnpack module do not yet implement packing to and from floating-point representations, A feature used by many modules in the Perl5 pack and unpack routines. Numeric::Pack fills this gap in functionality via a packaged native C library and a corresponding NativeCall interface. By relying on C to pack and unpack floating-point types we avoid the need to implement error prone bit manipulations in pure perl. Fixed size integer types are included for completeness and are used internally to assist in assessing a system's byte ordering.

Byte ordering (endianness) is managed at the Perl6 level to make it easier to extend later if necessary. Byte ordering is controlled with the Endianness enum.

Numeric::Pack exports the enum Endianness by default (Endianness is exported as :MANDATORY).

<table>
  <thead>
    <tr>
      <td>Endianness</td>
      <td>Description</td>
    </tr>
  </thead>
  <tr>
    <td>native-endian</td>
    <td>The native byte ordering of the current system</td>
  </tr>
  <tr>
    <td>little-endian</td>
    <td>Common byte ordering of contemporary CPUs</td>
  </tr>
  <tr>
    <td>big-endian</td>
    <td>Also known as network byte order</td>
  </tr>
</table>

By default Numeric::Pack's pack and unpack functions return and accept big-endian Bufs. To override this provide the :byte-order named parameter with the enum value for your desired behaviour. To disable byte order management pass :byte-order(native-endian).

Use Numeric::Pack :ALL to export all exportable functionality.

Use :floats or :ints flags to export subsets of the module's functionality.

<table>
  <thead>
    <tr>
      <td>:floats</td>
      <td>:ints</td>
    </tr>
  </thead>
  <tr>
    <td>pack-float</td>
    <td>pack-int32</td>
  </tr>
  <tr>
    <td>unpack-float</td>
    <td>unpack-int32</td>
  </tr>
  <tr>
    <td>pack-double</td>
    <td>pack-int64</td>
  </tr>
  <tr>
    <td>unpack-double</td>
    <td>unpack-int64</td>
  </tr>
</table>

TODO
====

  * unsigned types

  * larger types

  * smaller types

CHANGES
=======

<table>
  <tr>
    <td>changed named argument :endianness to :byte-order</td>
    <td>Signitures now read more naturally</td>
    <td>2016-08-30</td>
  </tr>
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

```
sub pack-float(
    Cool $rat, 
    Endianness :$byte-order = Endianness::big-endian
) returns Buf
```

Pack a Rat into a single-precision floating-point Buf (e.g. float). Exported via tag :floats. Be aware that Rats and floats are not directly analogous storage schemes and as such you should expect some variation in the values packed via this method and the original value.

### sub unpack-float

```
sub unpack-float(
    Buf $float-buf, 
    Endianness :$byte-order = Endianness::big-endian
) returns Numeric
```

Unpack a Buf containing a single-precision floating-point number (float) into a Numeric. Exported via tag :floats.

### sub pack-int32

```
sub pack-int32(
    Cool $int, 
    Endianness :$byte-order = Endianness::big-endian
) returns Buf
```

Pack an Int to an 4 byte integer buffer Exported via tag :ints. Be aware that the behaviour of Int values outside the range of a signed 32bit integer [−2,147,483,648 to 2,147,483,647] is undefined.

### sub unpack-int32

```
sub unpack-int32(
    Buf $int-buf, 
    Endianness :$byte-order = Endianness::big-endian
) returns Int
```

Unpack a signed 4 byte integer buffer. Exported via tag :ints.

### sub pack-double

```
sub pack-double(
    Cool $rat, 
    Endianness :$byte-order = Endianness::big-endian
) returns Buf
```

Pack a Rat into a double-precision floating-point Buf (e.g. double). Exported via tag :floats. Be aware that Rats and doubles are not directly analogous storage schemes and as such you should expect some variation in the values packed via this method and the original value.

### sub unpack-double

```
sub unpack-double(
    Buf $double-buf, 
    Endianness :$byte-order = Endianness::big-endian
) returns Numeric
```

Unpack a Buf containing a single-precision floating-point number (float) into a Numeric. Exported via tag :floats.

### sub pack-int64

```
sub pack-int64(
    Cool $int, 
    Endianness :$byte-order = Endianness::big-endian
) returns Buf
```

Pack an Int to an 8 byte integer buffer Exported via tag :ints. Be aware that the behaviour of Int values outside the range of a signed 64bit integer [−9,223,372,036,854,775,808 to 9,223,372,036,854,775,807] is undefined.

### sub unpack-int64

```
sub unpack-int64(
    Buf $int-buf, 
    Endianness :$byte-order = Endianness::big-endian
) returns Int
```

Unpack a signed 8 byte integer buffer. Exported via tag :ints.
