use v6;
unit module Numeric::Pack:ver<0.3.0>;

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
Currently there are no core language mechanisms for packing the majority of Numeric types into C compatible Bufs.
The experimental pack language feature module does not yet implement packing to and from floating-point representations,
A feature used by many modules in the Perl5 pack and unpack routines, (Since righting this the 5Pack module was released).
Numeric::Pack fills this gap in functionality through utilising the facilities offered by the core NativeCall module and is now pure perl.
Fixed size integer types are included for completeness and are used internally to assist in assessing a system's byte ordering.

Byte ordering is controlled with the ByteOrder enum.

Numeric::Pack exports the enum ByteOrder by default (ByteOrder is exported as :MANDATORY).

=begin table
        ByteOrder           | Description
        ===============================================================
        native-endian       | The native byte ordering of the current system
        little-endian       | Common byte ordering of contemporary CPUs
        big-endian          | Also known as network byte order
=end table

By default Numeric::Pack's pack and unpack functions return and accept big-endian Bufs.
To override this provide the :byte-order named parameter with the enum value for your desired behaviour.
To disable byte order management pass :byte-order(native-endian).

Use Numeric::Pack :ALL to export all exportable functionality.

Use :floats or :ints flags to export subsets of the module's functionality.
=begin table
        Export tag       | Functions
        ===============================
        :floats     | pack-float, unpack-float, pack-double, unpack-double
        :ints       | pack-uint32, pack-int32, unpack-int32, unpack-uint32, pack-int64, unpack-int64, pack-uint64, unpack-uint64
=end table

=head1 TODO

=item larger types
=item smaller types
=item optimise memory management

=head1 CHANGES

=begin table
      Removed bundled native library, now pure perl6    | Improved portability and reliability  | 2018-06-20
      Added pack-uint32, pack-uint32 and unpack-uint32  | Added support for unsigned types      | 2017-04-20
      Changed named argument :endianness to :byte-order | Signatures now read more naturally    | 2016-08-30
=end table

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=head1 FUNCTIONS
=end pod

use NativeCall;


# While heard there are other endian behaviours about, little and big are the most common.
enum ByteOrder is export(:MANDATORY) ( native-endian => 0, little-endian => 1, big-endian => 2 );

# The core interface for all Word unions
role ByteUnion {
    method as-buf(ByteOrder :$byte-order = native-byte-order() --> Buf) { … }

    method set-buf(Buf $buf, ByteOrder :$byte-order = native-byte-order()) { … }

    method as-int( --> Int) { … }

    method as-uint( --> UInt) { … }

    method as-float( --> Rat) { … }

    method set-int(Int $i) { … }

    method set-uint(UInt $i) { … }

    method set-float(Rat $r) { … }
}

### 4 byte types:

class Word32 is repr('CUnion') does ByteUnion {
    has int32 $!int;
    has uint32 $!uint;
    has num32 $!float;

    method as-buf(ByteOrder :$byte-order = native-byte-order() --> Buf) {
        my CArray[uint8] $bytes = nativecast(CArray[uint8], self);
        byte-array-to-buf($bytes, 4, :$byte-order)
    }

    method set-buf(Buf $buf, ByteOrder :$byte-order = native-byte-order() --> Word32) {
        my CArray[uint8] $bytes := nativecast(CArray[uint8], self);
        for order-bytes($buf, :$byte-order)[0..3].kv -> $i, $byte {
            $bytes[$i] = $byte
        }
    }

    method as-int( --> Int) { $!int }

    method as-float( --> Rat) { $!float.isNaN ?? Rat !! $!float.Rat }

    method as-uint( --> UInt) {
        # Handle native uint unpacking rakudo bug
        self.as-buf(:byte-order(little-endian))[]
            .kv
            .map( -> $k, $v { $v +< ($k * 8) })
            .sum
    }

    method set-int(Int $i) { $!int = $i }

    method set-float(Rat $r) { $!float = $r.Num }

    method set-uint(UInt $i) { $!uint = $i }
}

sub pack-float(Rat(Cool) $rat, ByteOrder :$byte-order = native-byte-order() --> Buf) is export(:floats)
#= Pack a Rat into a single-precision floating-point Buf (e.g. float).
#= Exported via tag :floats.
#= Be aware that Rats and floats are not directly analogous and
#=  as such you should expect some variation in the values packed via this method and the original   value.
{
  my Word32 $word .= new;
  $word.set-float($rat);
  $word.as-buf(:$byte-order);
}

sub unpack-float(Buf $float-buf, ByteOrder :$byte-order = native-byte-order() --> Rat) is export(:floats)
#= Unpack a Buf containing a single-precision floating-point number (float) into a Numeric.
#= Returns a Rat object on a NaN buffer.
#= Exported via tag :floats.
{
  my Word32 $word .= new;
  $word.set-buf($float-buf, :$byte-order);
  $word.as-float;
}

sub pack-int32(Int(Cool) $int, ByteOrder :$byte-order = native-byte-order() --> Buf) is export(:ints)
#= Pack an Int to a 4 byte integer buffer
#= Exported via tag :ints.
#= Be aware that the behaviour of Int values outside the range of a signed 32bit integer
#= [−2,147,483,648 to 2,147,483,647]
#= is undefined.
{
  my Word32 $word .= new;
  $word.set-int($int);
  $word.as-buf(:$byte-order);
}

sub unpack-int32(Buf $int-buf, ByteOrder :$byte-order = native-byte-order() --> Int) is export(:ints)
#= Unpack a signed 4 byte integer buffer.
#= Exported via tag :ints.
{
  my Word32 $word .= new;
  $word.set-buf($int-buf, :$byte-order);
  $word.as-int;
}

sub pack-uint32(UInt(Cool) $int, ByteOrder :$byte-order = native-byte-order() --> Buf) is export(:ints)
#= Pack an Int to a 4 byte unsigned integer buffer
#= Exported via tag :ints.
#= Be aware that the behaviour of Int values outside the range of a signed 32bit integer
#= [0 to 4,294,967,295]
#= is undefined.
{
  my Word32 $word .= new;
  $word.set-uint($int);
  $word.as-buf(:$byte-order);
}

sub unpack-uint32(Buf $int-buf, ByteOrder :$byte-order = native-byte-order() --> Int) is export(:ints)
#= Unpack an unsigned 4 byte integer buffer.
#= Exported via tag :ints.
{
  my Word32 $word .= new;
  $word.set-buf($int-buf, :$byte-order);
  $word.as-uint;
}

#
### 8 byte types:
#

class Word64 is repr('CUnion') does ByteUnion {
    has int64 $!int;
    has uint64 $!uint;
    has num64 $!float;

    method as-buf(ByteOrder :$byte-order = native-byte-order() --> Buf) {
        my CArray[uint8] $bytes = nativecast(CArray[uint8], self);
        byte-array-to-buf($bytes, 8, :$byte-order)
    }

    method set-buf(Buf $buf, ByteOrder :$byte-order = native-byte-order() --> Word32) {
        my CArray[uint8] $bytes := nativecast(CArray[uint8], self);
        for order-bytes($buf, :$byte-order)[0..7].kv -> $i, $byte {
            $bytes[$i] = $byte
        }
    }

    method as-int( --> Int) { $!int }

    method as-float( --> Rat) { $!float.isNaN ?? Rat !! $!float.Rat }

    method as-uint( --> UInt) {
        # Handle native uint unpacking rakudo bug
        self.as-buf(:byte-order(little-endian))[]
            .kv
            .map( -> $k, $v { $v +< ($k * 8) })
            .sum
    }

    method set-int(Int $i) { $!int = $i }

    method set-float(Rat $r) { $!float = $r.Num }

    method set-uint(UInt $i) {
        # Handle rakudo bug
        # If greater than 7 bytes, pack as a buffer instead
        if $i > 0x00FF_FFFF_FFFF_FFFF {
            my UInt $diff = 0xFFFF_FFFF_FFFF_FFFF - $i;
            if native-byte-order() eqv little-endian {
                self.set-buf: Buf.new(0xFF - $diff, |(0xFF xx 7))
            }
            else {
                self.set-buf: Buf.new(|(0xFF xx 7), 0xFF - $diff)
            }
        }
        else {
            $!uint = $i
        }
    }
}

sub pack-double(Rat(Cool) $rat, ByteOrder :$byte-order = native-byte-order() --> Buf) is export(:floats)
#= Pack a Rat into a double-precision floating-point Buf (e.g. double).
#= Exported via tag :floats.
#= Be aware that Rats and doubles are not directly analogous and
#=  as such you should expect some variation in the values packed via this method and the original   value.
{
  my Word64 $word .= new;
  $word.set-float($rat);
  $word.as-buf(:$byte-order);
}

sub unpack-double(Buf $double-buf, ByteOrder :$byte-order = native-byte-order() --> Rat) is export((:floats))
#= Unpack a Buf containing a double-precision floating-point number (double) into a Numeric.
#= Returns a Rat on NaN buffer.
#= Exported via tag :floats.
{
  my Word64 $word .= new;
  $word.set-buf($double-buf, :$byte-order);
  $word.as-float;
}

sub pack-int64(Int(Cool) $int, ByteOrder :$byte-order = native-byte-order() --> Buf) is export(:ints)
#= Pack an Int to an 8 byte integer buffer
#= Exported via tag :ints.
#= Be aware that the behaviour of Int values outside the range of a signed 64bit integer
#= [−9,223,372,036,854,775,808 to 9,223,372,036,854,775,807]
#= is undefined.
{
  my Word64 $word .= new;
  $word.set-int($int);
  $word.as-buf(:$byte-order);
}

sub unpack-int64(Buf $int-buf, ByteOrder :$byte-order = native-byte-order() --> Int) is export(:ints)
#= Unpack a signed 8 byte integer buffer.
#= Exported via tag :ints.
{
  my Word64 $word .= new;
  $word.set-buf($int-buf, :$byte-order);
  $word.as-int;
}

sub pack-uint64(UInt(Cool) $int, ByteOrder :$byte-order = native-byte-order() --> Buf) is export(:ints)
#= Pack an Int to an 8 byte unsigned integer buffer
#= Exported via tag :ints.
#= Be aware that the behaviour of Int values outside the range of a signed 64bit integer
#= [0 to 18,446,744,073,709,551,615]
#= is undefined.
{
  my Word64 $word .= new;
  $word.set-uint($int);
  $word.as-buf(:$byte-order);
}

sub unpack-uint64(Buf $int-buf, ByteOrder :$byte-order = native-byte-order() --> Int) is export(:ints)
#= Unpack an unsigned 8 byte integer buffer.
#= Exported via tag :ints.
{
  my Word64 $word .= new;
  $word.set-buf($int-buf, :$byte-order);
  $word.as-uint;
}


#
# Utils:
#
# Keep these here as they depend on the ByteOrder enum
#  which must also be exported up to any code using this module

# use state until is chached trait is no longer experimental
sub native-byte-order( --> ByteOrder) {
  state ByteOrder $native-bo = assess-native-byte-order;
  $native-bo;
}

sub assess-native-byte-order( --> ByteOrder) {
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

# reverse the order of the Buf's bytes if byte-ordering does not match
sub order-bytes(Buf $buf, ByteOrder :$byte-order --> Seq) {
    if native-endian or $byte-order eqv native-byte-order() {
        $buf[].Seq
    }
    else {
        $buf[].Seq.reverse
    }
}

# Take an Array of bytes and return a buf according to the byte order directive provided
sub byte-array-to-buf(CArray[uint8] $bytes, Int $size, ByteOrder :$byte-order = native-endian --> Buf) {
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

# Not currently used but nice to have the compliment to the above function around
sub buf-to-byte-array(Buf $buf, ByteOrder :$byte-order = native-endian --> CArray[uint8]) {
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
