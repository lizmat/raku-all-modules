use v6;

# Basic BSON encoding and decoding tools. These are to process strings and
# integers.

package BSON {

  class Encode-Tools {
  
    #--------------------------------------------------------------------------
    # Encoding tools
    #
    # Is bypassed by calling enc_cstring directly
    #
    # method enc_e_name ( Str $s --> Buf ) {
    #
    #   return self.enc_cstring($s);
    # }

    method enc_cstring ( Str $s --> Buf ) {

      die "Forbidden 0x00 sequence in $s" if $s ~~ /\x00/;

      return $s.encode() ~ Buf.new(0x00);
    }

    # string ::= int32 (byte*) "\x00"
    #
    method enc_string ( Str $s --> Buf ) {
      my $b = $s.encode('UTF-8');
      return self.enc_int32($b.bytes + 1) ~ $b ~ Buf.new(0x00);
    }

    # 4 bytes (32-bit signed integer)
    #
    method enc_int32 ( Int $i #`{{is copy}} ) {
      my int $ni = $i;      
      return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                      ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
                    );
      # Original method goes wrong on negative numbers. Also modulo
      # operations are slower than the bit operations.
      #
      # return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100, $i +> 0x18 % 0x100 );
    }

    # 8 bytes (64-bit int)
    #
    method enc_int64 ( Int $i ) {
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
  }

  class Decode-Tools {
    #--------------------------------------------------------------------------
    # Decoding tools
    #
    # Is bypassed by calling dec_cstring directly
    #
    # method dec_e_name ( Array $b ) {
    #
    #   return self.dec_cstring( $b );
    # }

    method dec_cstring ( Array $a, Int $index is rw --> Str ) {
      my @a;
      while $a[$index] !~~ 0x00 { @a.push($a[$index++]); }

      die 'Parse error' unless $a[$index++] ~~ 0x00;

      return Buf.new(@a).decode();
    }

    # string ::= int32 (byte*) "\x00"
    #
    method dec_string ( Array $a, Int $index is rw --> Str ) {
      my $i = self.dec_int32( $a, $index);

      my @a;
      @a.push( $a[$index++] ) for ^ ( $i - 1 );

      die 'Parse error' unless $a[$index++] ~~ 0x00;

      return Buf.new(@a).decode();
    }

    method dec_int32 ( Array $a, Int $index is rw --> Int ) {
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

    # 8 bytes (64-bit int)
    #
    method dec_int64 ( Array $a, Int $index is rw --> Int ) {
      my Int $ni = $a[$index]             +| $a[$index + 1] +< 0x08 +|
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
}
