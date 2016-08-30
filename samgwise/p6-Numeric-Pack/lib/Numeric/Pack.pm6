use v6;
unit module Numeric::Pack;

=begin pod

=head1 NAME

Numeric::Pack - Convert perl6 Numerics to Bufs and back again!

=head1 SYNOPSIS

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


=head1 DESCRIPTION

Numeric::Pack is a Perl6 module for packing values of the Numeric role into Buf objects
(With the exception of Complex numbers).
Currently there are no core language mechanisms for packing the majority of Numeric types into Bufs.
Both the experimental pack language feature and the PackUnpack module do not yet implement packing to and from floating-point representations,
A feature used by many modules in the Perl5 pack and unpack routines.
Numeric::Pack fills this gap in functionality via a packaged native C library and a corresponding NativeCall interface.
By relying on C to pack and unpack floating-point types we avoid the need to implement error prone bit manipulations in pure perl.
Fixed size integer types are included for completeness and are used internally to assist in assessing a system's byte ordering.

Byte ordering (endianness) is managed at the Perl6 level to make it easier to extend later if necessary.
Byte ordering is controlled with the Endianness enum.

Numeric::Pack exports the enum Endianness by default (Endianness is exported as :MANDATORY).

=begin table
        Endianness       | Description
        ===============================================================
        native-endian    | The native byte ordering of the current system
        little-endian    | Common byte ordering of contemporary CPUs
        big-endian       | Also known as network byte order
=end table

By default Numeric::Pack's pack and unpack functions return and accept big-endian Bufs.
To override this provide the :byte-order named parameter with the enum value for your desired behaviour.
To disable byte order management pass :byte-order(native-endian).

Use Numeric::Pack :ALL to export all exportable functionality.

Use :floats or :ints flags to export subsets of the module's functionality.
=begin table
        :floats           | :ints
        ===============================
        pack-float        | pack-int32
        unpack-float      | unpack-int32
        pack-double       | pack-int64
        unpack-double     | unpack-int64
=end table

=head1 TODO

=item unsigned types
=item larger types
=item smaller types

=head1 CHANGES

=begin table
      changed named argument :endianness to :byte-order | Signitures now read more naturally | 2016-08-30
=end table

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=head1 FUNCTIONS
=end pod

use NativeCall;
use LibraryMake;

# Find our compiled library.
sub libnumpack {
    my $so = get-vars('')<SO>;
    return ~(%?RESOURCES{"lib/libnumpack$so"});
}

# While heard there are other endian behaviours about, little and big are the most common.
enum Endianness is export(:MANDATORY) ( native-endian => 0, little-endian => 1, big-endian => 2 );

#
# Native calls and wrappers:
#

### 4 byte types:

# void pack_rat_to_float(int32_t n, int32_t d, char *bytes)
sub pack_rat_to_float(int32, int32, CArray[uint8]) is native(&libnumpack) { * }

sub pack-float(Rat(Cool) $rat, Endianness :$byte-order = big-endian) returns Buf is export(:floats)
#= Pack a Rat into a single-precision floating-point Buf (e.g. float).
#= Exported via tag :floats.
#= Be aware that Rats and floats are not directly analogous  storage schemes and
#=  as such you should expect some variation in the values packed via this method and the original   value.
{
  my $bytes = CArray[uint8].new;
  $bytes[3] = 0; #make room for 4 bytes
  pack_rat_to_float $rat.numerator, $rat.denominator, $bytes;
  byte-array-to-buf($bytes, 4, :$byte-order);
}

# float unpack_bits_to_float(char *bytes)
sub unpack_bits_to_float(CArray[uint8]) returns num32 is native(&libnumpack) { * }

sub unpack-float(Buf $float-buf, Endianness :$byte-order = big-endian) returns Numeric is export(:floats)
#= Unpack a Buf containing a single-precision floating-point number (float) into a Numeric.
#= Exported via tag :floats.
{
  die "Unable to unpack buffer: expected 4 bytes but recieved { $float-buf.elems }" unless $float-buf.elems == 4;
  unpack_bits_to_float(buf-to-byte-array $float-buf, :$byte-order);
}

# void pack_int32(int32_t i, char *bytes)
sub pack_int32(int32, CArray[uint8]) is native(&libnumpack) { * }

sub pack-int32(Int(Cool) $int, Endianness :$byte-order = big-endian) returns Buf is export(:ints)
#= Pack an Int to an 4 byte integer buffer
#= Exported via tag :ints.
#= Be aware that the behaviour of Int values outside the range of a signed 32bit integer
#= [−2,147,483,648 to 2,147,483,647]
#= is undefined.
{
  my $bytes = CArray[uint8].new;
  $bytes[3] = 0; #make room for 4 bytes
  pack_int32 $int, $bytes;
  byte-array-to-buf($bytes, 4, :$byte-order);
}

# int32_t unpack_int32(char *bytes)
sub unpack_int32(CArray[uint8]) returns int32 is native(&libnumpack) { * }

sub unpack-int32(Buf $int-buf, Endianness :$byte-order = big-endian) returns Int is export(:ints)
#= Unpack a signed 4 byte integer buffer.
#= Exported via tag :ints.
{
  die "Unable to unpack buffer: expected 4 bytes but recieved { $int-buf.elems }" unless $int-buf.elems == 4;
  unpack_int32 buf-to-byte-array $int-buf, :$byte-order;
}

### 8 byte types:

# void pack_rat_to_double(int64_t n, int64_t d, char *bytes)
sub pack_rat_to_double(int64, int64, CArray[uint8]) returns int64 is native(&libnumpack) { * }

sub pack-double(Rat(Cool) $rat, Endianness :$byte-order = big-endian) returns Buf is export(:floats)
#= Pack a Rat into a double-precision floating-point Buf (e.g. double).
#= Exported via tag :floats.
#= Be aware that Rats and doubles are not directly analogous  storage schemes and
#=  as such you should expect some variation in the values packed via this method and the original   value.
{
  my $bytes = CArray[uint8].new;
  $bytes[7] = 0; #make room for 8 bytes
  pack_rat_to_double $rat.numerator, $rat.denominator, $bytes;
  byte-array-to-buf($bytes, 8, :$byte-order);
}

# double unpack_bits_to_double(char *bytes)
sub unpack_bits_to_double(CArray[uint8]) returns num64 is native(&libnumpack) { * }

sub unpack-double(Buf $double-buf, Endianness :$byte-order = big-endian) returns Numeric is export((:floats))
#= Unpack a Buf containing a single-precision floating-point number (float) into a Numeric.
#= Exported via tag :floats.
{
  die "Unable to unpack buffer: expected 8 bytes but recieved { $double-buf.elems }" unless $double-buf.elems == 8;
  unpack_bits_to_double(buf-to-byte-array $double-buf, :$byte-order);
}

# void pack_int64(int64_t i, char *bytes)
sub pack_int64(int64, CArray[uint8]) is native(&libnumpack) { * }

sub pack-int64(Int(Cool) $int, Endianness :$byte-order = big-endian) returns Buf is export(:ints)
#= Pack an Int to an 8 byte integer buffer
#= Exported via tag :ints.
#= Be aware that the behaviour of Int values outside the range of a signed 64bit integer
#= [−9,223,372,036,854,775,808 to 9,223,372,036,854,775,807]
#= is undefined.
{
  my $bytes = CArray[uint8].new;
  $bytes[7] = 0; #make room for 8 bytes
  pack_int64 $int, $bytes;
  byte-array-to-buf($bytes, 8, :$byte-order);
}

# int64_t unpack_int64(char *bytes)
sub unpack_int64(CArray[uint8]) returns int64 is native(&libnumpack) { * }

sub unpack-int64(Buf $int-buf, Endianness :$byte-order = big-endian) returns Int is export(:ints)
#= Unpack a signed 8 byte integer buffer.
#= Exported via tag :ints.
{
  die "Unable to unpack buffer: expected 8 bytes but recieved { $int-buf.elems }" unless $int-buf.elems == 8;
  unpack_int64 buf-to-byte-array $int-buf, :$byte-order;
}


#
# Utils:
#
# Keep these here as they depend on the Endianness enum
#  which must also be exported up to any code using this module

# use state until is chached trait is no longer experimental
sub native-byte-order() returns Endianness {
  state Endianness $native-bo = assess-native-byte-order;
  $native-bo;
}

sub assess-native-byte-order() returns Endianness {
  #= Get a native to break the int into bytes and observe which endian order they use
  given pack-int32(0b00000001, :byte-order(native-endian))[0] {
    when 0b00000000 {
      return big-endian;
    }
    when 0b00000001 {
      return little-endian;
    }
    default {
      die "Unable to determine local byte-order!";
    }
  }
}

sub byte-array-to-buf(CArray[uint8] $bytes, Int $size, Endianness :$byte-order = native-endian) returns Buf {
  given $byte-order {
    when little-endian {
      return Buf.new($bytes[0..($size - 1)]) if native-byte-order() eqv little-endian;
      # else return a reversed byte order to convert big to little
      return Buf.new($bytes[0..($size - 1)].reverse);
    }
    when big-endian {
      return Buf.new($bytes[0..($size - 1)]) if native-byte-order() eqv big-endian;
      # else return a reversed byte order to convert little to big
      return Buf.new($bytes[0..($size - 1)].reverse);
    }
    default {
      # default to return native endianness
      return Buf.new($bytes[0..($size - 1)])
    }
  }
}

sub buf-to-byte-array(Buf $buf, Endianness :$byte-order = native-endian) returns CArray[uint8] {
  my $bytes = CArray[uint8].new;
  my $end = $buf.elems - 1;

  given $byte-order {
    when little-endian {
      if native-byte-order() eqv little-endian {
        $buf[0..$end].kv.reverse.map( -> $k, $v { $bytes[$k] = $v } );
      }
      else {
        # else a reversed byte order to convert big to little
        $buf[0..$end].kv.map( -> $k, $v { $bytes[$end - $k] = $v } );
      }
      return $bytes;
    }
    when big-endian {
      if native-byte-order() eqv big-endian {
        $buf[0..$end].kv.reverse.map( -> $k, $v { $bytes[$k] = $v } );
      }
      else {
        # else a reversed byte order to convert big to little
        $buf[0..$end].kv.map( -> $k, $v { $bytes[$end - $k] = $v } );
      }
      return $bytes;
    }
    default {
      # default to return native endianness
      $buf[0..$end].kv.reverse.map( -> $k, $v { $bytes[$k] = $v } );
      return $bytes;
    }
  }
}
