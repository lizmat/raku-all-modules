use v6.c;
use NativeCall;

#-----------------------------------------------------------------------------
class X::BSON::Parse-objectid is Exception {

  # No string types used because there can be lists of strings too
  has $.operation;                      # Operation method
  has $.error;                          # Parse error

  method message () {
    return "\n$!operation\() error: $!error\n";
  }
}

#-------------------------------------------------------------------------------
class X::BSON::Parse-document is Exception {
  has $.operation;                      # Operation method
  has $.error;                          # Parse error

  method message () {
    return "\n$!operation error: $!error\n";
  }
}

#-------------------------------------------------------------------------------
class X::BSON::NYS is Exception {
  has $.operation;                      # Operation encode, decode
  has $.type;                           # Type to encode/decode

  method message () {
    return "\n$!operation error: BSON type '$!type' is not (yet) supported\n";
  }
}

#-------------------------------------------------------------------------------
class X::BSON::Deprecated is Exception {
  has $.operation;                      # Operation encode, decode
  has $.type;                           # Type to encode/decode
  has Int $.subtype;                    # Subtype of type

  method message () {
    my Str $m;
    if ?$!subtype {
      $m = "subtype '$!subtype' of BSON '$!type'";
    }

    else {
      $m = "BSON type '$!type'"
    }

    return "\n$!operation error: $m is deprecated\n";
  }
}




#-------------------------------------------------------------------------------
sub encode-e-name ( Str:D $s --> Buf ) is export {
  return encode-cstring($s);
}

#-------------------------------------------------------------------------------
sub encode-cstring ( Str:D $s --> Buf ) is export {
  die X::BSON::Parse-document.new(
    :operation('encode-cstring()'),
    :error('Forbidden 0x00 sequence in $s')
  ) if $s ~~ /\x00/;

  return $s.encode() ~ Buf.new(0x00);
}

#-------------------------------------------------------------------------------
sub encode-string ( Str:D $s --> Buf ) is export {
  my Buf $b .= new($s.encode('UTF-8'));
  return [~] encode-int32($b.bytes + 1), $b, Buf.new(0x00);
}

#-------------------------------------------------------------------------------
sub encode-int32 ( Int:D $i --> Buf ) is export {
  my int $ni = $i;

  return Buf.new(
    $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
  );
}

#-------------------------------------------------------------------------------
sub encode-int64 ( Int:D $i --> Buf ) is export {

  # No tests for too large/small numbers because it is called from
  # enc-element normally where it is checked
  #
  my int $ni = $i;
  return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                  ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF,
                  ($ni +> 0x20) +& 0xFF, ($ni +> 0x28) +& 0xFF,
                  ($ni +> 0x30) +& 0xFF, ($ni +> 0x38) +& 0xFF
                );
}

#-------------------------------------------------------------------------------
# encode Num in buf little endian
#
sub encode-double ( Num:D $r --> Buf ) is export {

  my CArray[num64] $da .= new($r);
  my $list = nativecast( CArray[uint8], $da)[^8];
  if little-endian() {
    Buf[uint8].new($list);
  }

  else {
    Buf[uint8].new($list.reverse);
  }
}

#-------------------------------------------------------------------------------
# Experimental code
sub encode-double-emulated ( Num:D $r is copy --> Buf ) is export {

  # Make array starting with bson code 0x01 and the key name
  my Buf $a = Buf.new(); # Buf.new(0x01) ~ encode-e-name($key-name);
  my Num $r2;

  # Test special cases
  #
  # 0x 0000 0000 0000 0000 = 0
  # 0x 8000 0000 0000 0000 = -0       Not recognizable
  # 0x 7ff0 0000 0000 0000 = Inf
  # 0x fff0 0000 0000 0000 = -Inf
  # 0x 7ff0 0000 0000 0001 <= nan <= 0x 7ff7 ffff ffff ffff signalling NaN
  # 0x fff0 0000 0000 0001 <= nan <= 0x fff7 ffff ffff ffff
  # 0x 7ff8 0000 0000 0000 <= nan <= 0x 7fff ffff ffff ffff quiet NaN
  # 0x fff8 0000 0000 0000 <= nan <= 0x ffff ffff ffff ffff
  #
  given $r {
    when 0.0 {
      $a ~= Buf.new(0 xx 8);
    }

    when -Inf {
      $a ~= Buf.new( 0 xx 6, 0xF0, 0xFF);
    }

    when Inf {
      $a ~= Buf.new( 0 xx 6, 0xF0, 0x7F);
    }

    when NaN {
      # Choose only one number out of the quiet NaN range
      #
      $a ~= Buf.new( 0 xx 6, 0xF8, 0x7F);
    }

    default {
      my Int $sign = $r.sign == -1 ?? -1 !! 1;
      $r *= $sign;

      # Get proper precision from base(2). Adjust the exponent bias for
      # this.
      #
      my Int $exp-shift = 0;
      my Int $exponent = 1023;
      my Str $bit-string = $r.base(2);

      $bit-string ~= '.' unless $bit-string ~~ m/\./;

      # Smaller than one
      #
      if $bit-string ~~ m/^0\./ {

        # Normalize, Check if a '1' is found. Possible situation is
        # a series of zeros because r.base(2) won't give that much
        # information.
        #
        my $first-one;
        while !($first-one = $bit-string.index('1')) {
          $exponent -= 52;
          $r *= 2 ** 52;
          $bit-string = $r.base(2);
        }

        $first-one--;
        $exponent -= $first-one;

        $r *= 2 ** $first-one;                # 1.***
        $r2 = $r * 2 ** 52;                   # Get max precision
        $bit-string = $r2.base(2);            # Get bits
        $bit-string ~~ s/\.//;                # Remove dot
        $bit-string ~~ s/^1//;                # Remove first 1
      }

      # Bigger than one
      #
      else {
        # Normalize
        #
        my Int $dot-loc = $bit-string.index('.');
        $exponent += ($dot-loc - 1);

        # If dot is in the string, not at the end, the precision might
        # be not sufficient. Enlarge one time more
        #
        my Int $str-len = $bit-string.chars;
        if $dot-loc < $str-len - 1 or $str-len < 52 {
          $r2 = $r * 2 ** 52;                 # Get max precision
          $bit-string = $r2.base(2);          # Get bits
        }

        $bit-string ~~ s/\.//;              # Remove dot
        $bit-string ~~ s/^1//;              # Remove first 1
      }

      # Prepare the number. First set the sign bit.
      #
      my Int $i = $sign == -1 ?? 0x8000_0000_0000_0000 !! 0;

      # Now fit the exponent on its place
      #
      $i +|= $exponent +< 52;

      # And the precision
      #
      $i +|= :2($bit-string.substr( 0, 52));

      $a ~= encode-int64($i);
    }
  }

  return $a;
}





#-------------------------------------------------------------------------------
sub decode-e-name ( Buf:D $b, Int:D $index is rw --> Str ) is export {
  return decode-cstring( $b, $index);
}

#-------------------------------------------------------------------------------
sub decode-cstring ( Buf:D $b, Int:D $index is rw --> Str ) is export {

  my @a;
  my $l = $b.elems;

  while $b[$index] !~~ 0x00 and $index < $l {
    @a.push($b[$index++]);
  }

  # This takes only place if there are no 0x0 characters found until the
  # end of the buffer which is almost never.
  #
  die X::BSON::Parse-document.new(
    :operation<decode-cstring>,
    :error('Missing trailing 0x00')
  ) unless $index < $l and $b[$index++] ~~ 0x00;

  return Buf.new(@a).decode();
}

#-------------------------------------------------------------------------------
sub decode-string ( Buf:D $b, Int:D $index is copy --> Str ) is export {

  my $size = decode-int32( $b, $index);
  my $end-string-at = $index + 4 + $size - 1;

  # Check if there are enaugh letters left
  #
  die X::BSON::Parse-document.new(
    :operation<decode-string>,
    :error('Not enaugh characters left')
  ) unless ($b.elems - $size) > $index;

  die X::BSON::Parse-document.new(
    :operation<decode-string>,
    :error('Missing trailing 0x00')
  ) unless $b[$end-string-at] == 0x00;

  return Buf.new($b[$index+4 ..^ $end-string-at]).decode;
}

#-------------------------------------------------------------------------------
sub decode-int32 ( Buf:D $b, Int:D $index --> Int ) is export {

  # Check if there are enaugh letters left
  #
  die X::BSON::Parse-document.new(
    :operation<decode-int32>,
    :error('Not enaugh characters left')
  ) if $b.elems - $index < 4;

  my int $ni = $b[$index]             +| $b[$index + 1] +< 0x08 +|
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

#-----------------------------------------------------------------------------
sub decode-int64 ( Buf:D $b, Int:D $index --> Int ) is export {

  # Check if there are enaugh letters left
  #
  die X::BSON::Parse-document.new(
    :operation<decode-int64>,
    :error('Not enaugh characters left')
  ) if $b.elems - $index < 8;

  my int $ni = $b[$index]             +| $b[$index + 1] +< 0x08 +|
               $b[$index + 2] +< 0x10 +| $b[$index + 3] +< 0x18 +|
               $b[$index + 4] +< 0x20 +| $b[$index + 5] +< 0x28 +|
               $b[$index + 6] +< 0x30 +| $b[$index + 7] +< 0x38
               ;
  return $ni;
}

#-------------------------------------------------------------------------------
# decode to Int from buf little endian
#
sub decode-int64-native ( Buf:D $b, Int:D $index --> Int ) is export {

  my Buf[uint8] $ble;
  if little-endian() {
    $ble .= new($b.subbuf( $index, 8));
  }

  else {
    $ble .= new($b.subbuf( $index, 8).reverse);
  }

  nativecast( CArray[int64], $ble)[0];
}

#-------------------------------------------------------------------------------
# decode to Num from buf little endian
#
sub decode-double ( Buf:D $b, Int:D $index --> Num ) is export {

  my Buf[uint8] $ble;
  if little-endian() {
    $ble .= new($b.subbuf( $index, 8));
  }

  else {
    $ble .= new($b.subbuf( $index, 8).reverse);
  }

  nativecast( CArray[num64], $ble)[0];
}

#-----------------------------------------------------------------------------
# experimental code
# We have to do some simulation using the information on
# http://en.wikipedia.org/wiki/Double-precision_floating-point_format#Endianness
# until better times come.
#
sub decode-double-emulated ( Buf:D $b, Int:D $index --> Num ) is export {

#say "Dbl 0: ", $b.subbuf( $index, 8);

  # Test special cases
  #
  # 0x 0000 0000 0000 0000 = 0
  # 0x 8000 0000 0000 0000 = -0
  # 0x 7ff0 0000 0000 0000 = Inf
  # 0x fff0 0000 0000 0000 = -Inf
  # 0x 7ff0 0000 0000 0001 <= nan <= 0x 7ff7 ffff ffff ffff signalling NaN
  # 0x fff0 0000 0000 0001 <= nan <= 0x fff7 ffff ffff ffff
  # 0x 7ff8 0000 0000 0000 <= nan <= 0x 7ff7 ffff ffff ffff quiet NaN
  # 0x fff8 0000 0000 0000 <= nan <= 0x ffff ffff ffff ffff
  #
  my Bool $six-byte-zeros = True;

  for ^6 -> $i {
    if ? $b[$index + $i] {
      $six-byte-zeros = False;
      last;
    }
  }
#say "Dbl 1: $six-byte-zeros";

  my Num $value;
  if $six-byte-zeros and $b[$index + 6] == 0 {
    if $b[$index + 7] == 0 {
      $value .= new(0);
    }

    elsif $b[$index + 7] == 0x80 {
      $value .= new(-0);
    }
  }

  elsif $six-byte-zeros and $b[$index + 6] == 0xF0 {
    if $b[$index + 7] == 0x7F {
      $value .= new(Inf);
    }

    elsif $b[$index + 7] == 0xFF {
      $value .= new(-Inf);
    }
  }

  elsif $b[$index + 7] == 0x7F and (0xf0 <= $b[$index + 6] <= 0xf7
        or 0xf8 <= $b[$index + 6] <= 0xff) {
    $value .= new(NaN);
  }

  elsif $b[$index + 7] == 0xFF and (0xf0 <= $b[$index + 6] <= 0xf7
        or 0xf8 <= $b[$index + 6] <= 0xff) {
    $value .= new(NaN);
  }

  # If value is not set by the special cases above, calculate it here
  #
  if !$value.defined {

    my Int $i = decode-int64( $b, $index);
    my Int $sign = $i +& 0x8000_0000_0000_0000 ?? -1 !! 1;

    # Significand + implicit bit
    #
    my $significand = 0x10_0000_0000_0000 +| ($i +& 0xF_FFFF_FFFF_FFFF);

    # Exponent - bias (1023) - the number of bits for precision
    #
    my $exponent = (($i +& 0x7FF0_0000_0000_0000) +> 52) - 1023 - 52;

    $value = Num.new((2 ** $exponent) * $significand * $sign);
  }

  return $value;
}

#------------------------------------------------------------------------------
sub little-endian ( --> Bool ) {

  my $i = CArray[uint32].new: 1;
  my $j = nativecast( CArray[uint8], $i);

  $j[0] == 0x01;
}

