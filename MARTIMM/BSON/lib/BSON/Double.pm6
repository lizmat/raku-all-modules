use v6;
use BSON::EDCTools;

package BSON {

  # https://www.doc.ic.ac.uk/~eedwards/compsys/float/nan.html
  # http://steve.hollasch.net/cgindex/coding/ieeefloat.html
  # https://en.wikipedia.org/wiki/Floating_point
  #
  class Double {

    #---------------------------------------------------------------------------
    # 8 bytes double (64-bit floating point number)
    #
#`{{    method encode_double ( Num:D $r is copy --> Buf
    ) is DEPRECATED('encode-double') {
      BSON::Double.encode-double($r);
    }
}}

    method encode-double ( Num:D $r is copy --> Buf ) {

#      my Str $key-name = $p.key;
#      my Num $r = $p.value;

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

    #---------------------------------------------------------------------------
    # We have to do some simulation using the information on
    # http://en.wikipedia.org/wiki/Double-precision_floating-point_format#Endianness
    # until better times come.
    #
#`{{
    multi method decode_double ( List:D $a, Int:D $index is rw ) is DEPRECATED('decode-double') {
      return self.decode-double( $a.Array, $index);
    }

    multi method decode-double ( List:D $a, Int:D $index is rw ) {
      return self.decode-double( $a.Array, $index);
    }

    multi method decode_double ( Array:D $a, Int:D $index is rw ) is DEPRECATED('decode-double') {
      return self.decode-double( $a, $index);
    }

    multi method decode-double ( Array:D $a, Int:D $index is rw ) {
}}

    multi method decode-double ( Array:D $a, Int:D $index is rw --> Num ) {
      self.decode-double( Buf.new($a.List), $index);
    }

    multi method decode-double ( Buf:D $a, Int:D $index is rw --> Num ) {

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
        if ? $a[$i] {
          $six-byte-zeros = False;
          last;
        }
      }
      my Num $value;
      if $six-byte-zeros and $a[6] == 0 {
        if $a[7] == 0 {
          $value .= new(0);
        }

        elsif $a[7] == 0x80 {
          $value .= new(-0);
        }
      }

      elsif $six-byte-zeros and $a[6] == 0xF0 {
        if $a[7] == 0x7F {
          $value .= new(Inf);
        }

        elsif $a[7] == 0xFF {
          $value .= new(-Inf);
        }
      }

      elsif $a[7] == 0x7F and (0xf0 <= $a[6] <= 0xf7 or 0xf8 <= $a[6] <= 0xff) {
        $value .= new(NaN);
      }

      elsif $a[7] == 0xFF and (0xf0 <= $a[6] <= 0xf7 or 0xf8 <= $a[6] <= 0xff) {
        $value .= new(NaN);
      }

      # If value is set by the special cases above, remove the 8 bytes from
      # the array.
      #
      if $value.defined {
        $index += 8;
      }

      # If value is not set by the special cases above, calculate it here
      #
      else {

        my Int $i = decode-int64( $a.Array, $index);
        my Int $sign = $i +& 0x8000_0000_0000_0000 ?? -1 !! 1;

        # Significand + implicit bit
        #
        my $significand = 0x10_0000_0000_0000 +| ($i +& 0xF_FFFF_FFFF_FFFF);
#        my $significand = 0x10_0000_0000_0000 +| $i;

        # Exponent - bias (1023) - the number of bits for precision
        #
        my $exponent = (($i +& 0x7FF0_0000_0000_0000) +> 52) - 1023 - 52;
#say "Dbl: $significand, $exponent, $i, $sign, ", $a;

        $value = Num.new((2 ** $exponent) * $significand * $sign);
      }

      return $value;
    }
  }
}
