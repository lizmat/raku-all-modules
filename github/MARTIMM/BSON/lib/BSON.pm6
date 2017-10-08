use v6;
use NativeCall;

#------------------------------------------------------------------------------
package BSON:auth<github:MARTIM> {
  # BSON type codes
  constant C-DOUBLE             = 0x01;
  constant C-STRING             = 0x02;
  constant C-DOCUMENT           = 0x03;
  constant C-ARRAY              = 0x04;
  constant C-BINARY             = 0x05;
  constant C-UNDEFINED          = 0x06;         # Deprecated
  constant C-OBJECTID           = 0x07;
  constant C-BOOLEAN            = 0x08;
  constant C-DATETIME           = 0x09;
  constant C-NULL               = 0x0A;
  constant C-REGEX              = 0x0B;
  constant C-DBPOINTER          = 0x0C;         # Deprecated
  constant C-JAVASCRIPT         = 0x0D;
  constant C-DEPRECATED         = 0x0E;         # Deprecated
  constant C-JAVASCRIPT-SCOPE   = 0x0F;
  constant C-INT32              = 0x10;
  constant C-TIMESTAMP          = 0x11;
  constant C-INT64              = 0x12;
  constant C-DECIMAL128         = 0x13;
  constant C-MIN-KEY            = 0xFF;
  constant C-MAX-KEY            = 0x7F;

  #----------------------------------------------------------------------------
  # Fixed sizes
  constant C-INT32-SIZE         = 4;
  constant C-INT64-SIZE         = 8;
  constant C-UINT64-SIZE        = 8;
  constant C-DOUBLE-SIZE        = 8;
  constant C-DECIMAL128-SIZE    = 16;

  #----------------------------------------------------------------------------
  subset Timestamp of UInt where ( $_ < (2**64 - 1 ) );
}

#------------------------------------------------------------------------------
class X::BSON is Exception {

  # No string types used because there can be lists of strings too
  has $.operation;                      # Operation method encode/decode
  has $.type;                           # Type to process
  has $.error;                          # Parse error

  method message ( --> Str ) {
    "$!operation\() on $!type, error: $!error\n";
  }
}




#------------------------------------------------------------------------------
sub encode-e-name ( Str:D $s --> Buf ) is export {
  return encode-cstring($s);
}

#------------------------------------------------------------------------------
sub encode-cstring ( Str:D $s --> Buf ) is export {
  die X::BSON.new(
    :operation<encode>, :type<cstring>,
    :error("Forbidden 0x00 sequence in '$s'")
  ) if $s ~~ /\x00/;

  return $s.encode() ~ Buf.new(0x00);
}

#------------------------------------------------------------------------------
sub encode-string ( Str:D $s --> Buf ) is export {
  my Buf $b .= new($s.encode('UTF-8'));
  return [~] encode-int32($b.bytes + 1), $b, Buf.new(0x00);
}

#------------------------------------------------------------------------------
sub encode-int32 ( Int:D $i --> Buf ) is export {
  my int $ni = $i;

  return Buf.new(
    $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
  );
}

#------------------------------------------------------------------------------
sub encode-int64 ( Int:D $i --> Buf ) is export {

  # No tests for too large/small numbers because it is called from
  # enc-element normally where it is checked
  my int $ni = $i;
  return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                  ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF,
                  ($ni +> 0x20) +& 0xFF, ($ni +> 0x28) +& 0xFF,
                  ($ni +> 0x30) +& 0xFF, ($ni +> 0x38) +& 0xFF
                );
}

#------------------------------------------------------------------------------
sub encode-uint64 ( UInt:D $i --> Buf ) is export {

  # No tests for too large/small numbers because it is called from
  # enc-element normally where it is checked
  my int $ni = $i;
  return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                  ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF,
                  ($ni +> 0x20) +& 0xFF, ($ni +> 0x28) +& 0xFF,
                  ($ni +> 0x30) +& 0xFF, ($ni +> 0x38) +& 0xFF
                );
}

#------------------------------------------------------------------------------
# encode Num in buf little endian
sub encode-double ( Num:D $r --> Buf ) is export {

  state $little-endian = little-endian();

  my Buf $b;
  my CArray[num64] $na .= new($r);
  if $little-endian {
    $b .= new(nativecast( CArray[uint8], $na)[^8]);
  }

  else {
    $b .= new(nativecast( CArray[uint8], $na)[^8]);
  }

  $b;
}





#------------------------------------------------------------------------------
sub decode-e-name ( Buf:D $b, Int:D $index is rw --> Str ) is export {
  return decode-cstring( $b, $index);
}

#------------------------------------------------------------------------------
sub decode-cstring ( Buf:D $b, Int:D $index is rw --> Str ) is export {

  my @a;
  my $l = $b.elems;

  while $b[$index] !~~ 0x00 and $index < $l {
    @a.push($b[$index++]);
  }

  # This takes only place if there are no 0x0 characters found until the
  # end of the buffer which is almost never.
  #
  die X::BSON.new(
    :operation<decode>, :type<cstring>,
    :error('Missing trailing 0x00')
  ) unless $index < $l and $b[$index++] ~~ 0x00;

  return Buf.new(@a).decode();
}

#------------------------------------------------------------------------------
sub decode-string ( Buf:D $b, Int:D $index is copy --> Str ) is export {

  my $size = decode-int32( $b, $index);
  my $end-string-at = $index + 4 + $size - 1;

  # Check if there are enaugh letters left
  #
  die X::BSON.new(
    :operation<decode>, :type<string>,
    :error('Not enaugh characters left')
  ) unless ($b.elems - $size) > $index;

  die X::BSON.new(
    :operation<decode>, :type<string>,
    :error('Missing trailing 0x00')
  ) unless $b[$end-string-at] == 0x00;

  return Buf.new($b[$index+4 ..^ $end-string-at]).decode;
}

#------------------------------------------------------------------------------
sub decode-int32 ( Buf:D $b, Int:D $index --> Int ) is export {

  # Check if there are enaugh letters left
  #
  die X::BSON.new(
    :operation<decode>, :type<int32>,
    :error('Not enaugh characters left')
  ) if $b.elems - $index < 4;

  my Int $ni = $b[$index]             +| $b[$index + 1] +< 0x08 +|
               $b[$index + 2] +< 0x10 +| $b[$index + 3] +< 0x18
               ;

  # Test if most significant bit is set. If so, calculate two's complement
  # negative number.
  # Prefix +^: Coerces the argument to Int and does a bitwise negation on
  # the result, assuming two's complement. (See
  # http://doc.perl6.org/language/operators^)
  # Infix +^ :Coerces both arguments to Int and does a bitwise XOR
  # (exclusive OR) operation.
  #
  $ni = (0xffffffff +& (0xffffffff+^$ni) +1) * -1  if $ni +& 0x80000000;
  return $ni;
}

#------------------------------------------------------------------------------
sub decode-int64 ( Buf:D $b, Int:D $index --> Int ) is export {

  # Check if there are enaugh letters left
  #
  die X::BSON.new(
    :operation<decode>, :type<int64>,
    :error('Not enaugh characters left')
  ) if $b.elems - $index < 8;

  my Int $ni = $b[$index]             +| $b[$index + 1] +< 0x08 +|
               $b[$index + 2] +< 0x10 +| $b[$index + 3] +< 0x18 +|
               $b[$index + 4] +< 0x20 +| $b[$index + 5] +< 0x28 +|
               $b[$index + 6] +< 0x30 +| $b[$index + 7] +< 0x38
               ;
  return $ni;
}

#------------------------------------------------------------------------------
# decode unsigned 64 bit integer
sub decode-uint64 ( Buf:D $b, Int:D $index --> UInt ) is export {

  # Check if there are enaugh letters left
  die X::BSON.new(
    :operation<decode>, :type<int64>,
    :error('Not enough characters left')
  ) if $b.elems - $index < 8;

  my UInt $ni = $b[$index]            +| $b[$index + 1] +< 0x08 +|
               $b[$index + 2] +< 0x10 +| $b[$index + 3] +< 0x18 +|
               $b[$index + 4] +< 0x20 +| $b[$index + 5] +< 0x28 +|
               $b[$index + 6] +< 0x30 +| $b[$index + 7] +< 0x38
               ;
  return $ni;
}

#------------------------------------------------------------------------------
# decode to Num from buf little endian
sub decode-double ( Buf:D $b, Int:D $index --> Num ) is export {

  state $little-endian = little-endian();

  # Check if there are enaugh letters left
  die X::BSON.new(
    :operation<decode>, :type<double>,
    :error('Not enaugh characters left')
  ) if $b.elems - $index < 8;

  my Buf[uint8] $ble;
  if $little-endian {
    $ble .= new($b.subbuf( $index, 8));
  }

  else {
    $ble .= new($b.subbuf( $index, 8).reverse);
  }

  nativecast( CArray[num64], $ble)[0];
}

#------------------------------------------------------------------------------
sub little-endian ( --> Bool ) is export {

  my $i = CArray[uint32].new: 1;
  my $j = nativecast( CArray[uint8], $i);

  $j[0] == 0x01;
}
