use v6;
use BSON::Exception;

# Basic BSON encoding and decoding tools. These exported subs process
# strings and integers.

package BSON {
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
  constant C-TIMESTAMP          = 0x11;         # Used internally
  constant C-INT64              = 0x12;
  constant C-MIN-KEY            = 0xFF;
  constant C-MAX-KEY            = 0x7F;

  #-----------------------------------------------------------------------------
  constant C-INT32-SIZE         = 4;
  constant C-INT64-SIZE         = 8;
  constant C-DOUBLE-SIZE        = 8;

  #-----------------------------------------------------------------------------
  # Encoding tools
  #
  sub encode_e_name ( Str:D $s --> Buf ) is export is DEPRECATED('encode-e-name') {
    return encode-cstring($s);
  }

  sub encode-e-name ( Str:D $s --> Buf ) is export {
    return encode-cstring($s);
  }

  #-----------------------------------------------------------------------------
  sub encode_cstring ( Str:D $s --> Buf ) is export is DEPRECATED('encode-cstring') {
    return encode-cstring($s);
  }

  sub encode-cstring ( Str:D $s --> Buf ) is export {
    die X::BSON::Parse.new(
      :operation('encode_cstring'),
      :error('Forbidden 0x00 sequence in $s')
    ) if $s ~~ /\x00/;

    return $s.encode() ~ Buf.new(0x00);
  }

  #-----------------------------------------------------------------------------
  # string ::= int32 (byte*) "\x00"
  #
  sub encode_string ( Str:D $s --> Buf ) is export is DEPRECATED('encode-string') {
    my Buf $b .= new($s.encode('UTF-8'));
    return [~] encode-int32($b.bytes + 1), $b, Buf.new(0x00);
  }

  sub encode-string ( Str:D $s --> Buf ) is export {
    my Buf $b .= new($s.encode('UTF-8'));
    return [~] encode-int32($b.bytes + 1), $b, Buf.new(0x00);
  }

  #-----------------------------------------------------------------------------
  # 4 bytes (32-bit signed integer)
  #
  sub encode_int32 ( Int:D $i ) is export is DEPRECATED('encode-int32') {
    my int $ni = $i;      
    return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
                  );
  }

  sub encode-int32 ( Int:D $i ) is export {
    my int $ni = $i;      
    return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
                  );

    # Original method goes wrong on negative numbers. Also modulo
    # operations are slower than the bit operations.
    #
    # return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100, $i +> 0x18 % 0x100 );
  }

  #-----------------------------------------------------------------------------
  # 8 bytes (64-bit int)
  #
  sub encode_int64 ( Int:D $i ) is export is DEPRECATED('encode-int64') {
    # No tests for too large/small numbers because it is called from
    # _enc_element normally where it is checked
    #
    my int $ni = $i;
    return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF,
                    ($ni +> 0x20) +& 0xFF, ($ni +> 0x28) +& 0xFF,
                    ($ni +> 0x30) +& 0xFF, ($ni +> 0x38) +& 0xFF
                  );
  }

  sub encode-int64 ( Int:D $i ) is export {
    # No tests for too large/small numbers because it is called from
    # _enc_element normally where it is checked
    #
    my int $ni = $i;
    return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF,
                    ($ni +> 0x20) +& 0xFF, ($ni +> 0x28) +& 0xFF,
                    ($ni +> 0x30) +& 0xFF, ($ni +> 0x38) +& 0xFF
                  );

    # Original method goes wrong on negative numbers. Also modulo operations
    # are slower than the bit operations.
    #
    #return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100,
    #                $i +> 0x18 % 0x100, $i +> 0x20 % 0x100,
    #                $i +> 0x28 % 0x100, $i +> 0x30 % 0x100,
    #                $i +> 0x38 % 0x100
    #              );
  }


  #-----------------------------------------------------------------------------
  # Decoding tools
  #
  multi sub decode_e_name ( List:D $b, Int:D $index is rw --> Str
  ) is export is DEPRECATED('decode-e-name') {
    return decode-cstring( $b.Array, $index);
  }

  multi sub decode-e-name ( List:D $b, Int:D $index is rw --> Str ) is export {
    return decode-cstring( $b.Array, $index);
  }

  multi sub decode_e_name ( Array:D $b, Int:D $index is rw --> Str
  ) is export is DEPRECATED('decode-e-name') {
    return decode-cstring( $b, $index);
  }

  multi sub decode-e-name ( Array:D $b, Int:D $index is rw --> Str ) is export {
    return decode-cstring( $b, $index);
  }

#  multi sub decode-e-name ( Buf:D $b, Int:D $index is rw --> Str ) is export {
#    return decode-cstring( $b, $index);
#  }

  #-----------------------------------------------------------------------------
  multi sub decode_cstring ( List:D $a, Int:D $index is rw --> Str
  ) is export is DEPRECATED('decode-cstring') {
    return decode-cstring( $a.Array, $index);
  }

  multi sub decode-cstring ( List:D $a, Int:D $index is rw --> Str ) is export {
    return decode-cstring( $a.Array, $index);
  }

  multi sub decode_cstring ( Array:D $a, Int:D $index is rw --> Str
  ) is export is DEPRECATED('decode-cstring') {
    return decode-cstring( $a, $index);
  }

  multi sub decode-cstring ( Array:D $a, Int:D $index is rw --> Str ) is export {
    my @a;
    my $l = $a.elems;
    while $index < $l and $a[$index] !~~ 0x00 { @a.push($a[$index++]); }

    die X::BSON::Parse.new(
      :operation('decode-cstring'),
      :error('Missing trailing 0x00')
    ) unless $index < $l and $a[$index++] ~~ 0x00;
    return Buf.new(@a).decode();
  }

  #-----------------------------------------------------------------------------
  # string ::= int32 (byte*) "\x00"
  #
  multi sub decode_string ( List:D $a, Int:D $index is rw --> Str
  ) is export is DEPRECATED('decode-string') {
    decode-string( $a.Array, $index);
  }

  multi sub decode-string ( List:D $a, Int:D $index is rw --> Str ) is export {
    decode-string( $a.Array, $index);
  }

  multi sub decode_string ( Array:D $a, Int:D $index is rw --> Str
  ) is export is DEPRECATED('decode-string') {
    decode-string( $a, $index);
  }

  multi sub decode-string ( Array:D $a, Int:D $index is rw --> Str ) is export {
    my $i = decode-int32( $a, $index);

    # Check if there are enaugh letters left
    #
    my $l = $a.elems - $index;

    die X::BSON::Parse.new(
      :operation('decode_string'),
      :error('Not enaugh characters left')
    ) if $l < $i;

    my @a;
    @a.push($a[$index++]) for ^ ($i - 1);

    die X::BSON::Parse.new(
      :operation('decode_string'),
      :error('Missing trailing 0x00')
    ) unless $a[$index++] ~~ 0x00;

    return Buf.new(@a).decode();
  }

  #-----------------------------------------------------------------------------
  multi sub decode_int32 ( List:D $a, Int:D $index is rw --> Int
  ) is export is DEPRECATED('decode-int32') {
    decode-int32( $a.Array, $index);
  }

  multi sub decode-int32 ( List:D $a, Int:D $index is rw --> Int ) is export {
    decode-int32( $a.Array, $index);
  }

  multi sub decode_int32 ( Array:D $a, Int:D $index is rw --> Int
  ) is export is DEPRECATED('decode-int32') {
    decode-int32( $a, $index);
  }

  multi sub decode-int32 ( Array:D $a, Int:D $index is rw --> Int ) is export {
    # Check if there are enaugh letters left
    #
    die X::BSON::Parse.new(
      :operation('decode_int32'),
      :error('Not enaugh characters left')
    ) if $a.elems - $index < 4;

    my int $ni = $a[$index]             +| $a[$index + 1] +< 0x08 +|
                 $a[$index + 2] +< 0x10 +| $a[$index + 3] +< 0x18
                 ;
    $index += 4;

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

    # Original method goes wrong on negative numbers. Also adding might be
    # slower than the bit operations.
    #
    # return [+] $a.shift, $a.shift +< 0x08, $a.shift +< 0x10, $a.shift +< 0x18;
  }

  #-----------------------------------------------------------------------------
  # 8 bytes (64-bit int)
  #
  multi sub decode_int64 ( List:D $a, Int:D $index is rw --> Int
  ) is export is DEPRECATED('decode-int64') {
    decode-int64( $a.Array, $index);
  }

  multi sub decode-int64 ( List:D $a, Int:D $index is rw --> Int ) is export {
    decode-int64( $a.Array, $index);
  }

  multi sub decode_int64 ( Array:D $a, Int:D $index is rw --> Int
  ) is export is DEPRECATED('decode-int64') {
    decode-int64( $a, $index);
  }

  multi sub decode-int64 ( Array:D $a, Int:D $index is rw --> Int ) is export {
    # Check if there are enaugh letters left
    #
    die X::BSON::Parse.new(
      :operation('decode_int64'),
      :error('Not enaugh characters left')
    ) if $a.elems - $index < 8;

    my int $ni = $a[$index]             +| $a[$index + 1] +< 0x08 +|
                 $a[$index + 2] +< 0x10 +| $a[$index + 3] +< 0x18 +|
                 $a[$index + 4] +< 0x20 +| $a[$index + 5] +< 0x28 +|
                 $a[$index + 6] +< 0x30 +| $a[$index + 7] +< 0x38
                 ;
    $index += 8;
    return $ni;

    # Original method goes wrong on negative numbers. Also adding might be
    # slower than the bit operations.
    #
    #return [+] $a.shift, $a.shift +< 0x08, $a.shift +< 0x10, $a.shift +< 0x18
    #         , $a.shift +< 0x20, $a.shift +< 0x28, $a.shift +< 0x30
    #         , $a.shift +< 0x38
    #         ;
  }
}
