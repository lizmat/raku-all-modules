use v6;
use BSON::ObjectId;
use BSON::Regex;
use BSON::Javascript;
use BSON::Binary;
use BSON::EDCTools;
use BSON::Exception;

package BSON {

  class Bson:ver<0.9.7> {
    constant $BSON_BOOL = 0x08;

    has Int $.index is rw = 0;

    #-----------------------------------------------------------------------------
    # Test elements see http://bsonspec.org/spec.html
    #
    # Basic types are;
    #
    # byte 	1 byte (8-bits)
    # int32 	4 bytes (32-bit signed integer, two's complement)
    # int64 	8 bytes (64-bit signed integer, two's complement)
    # double 	8 bytes (64-bit IEEE 754 floating point)
    #
    #-----------------------------------------------------------------------------
    # Encoding a document given in a hash variable
    #
    method encode ( Hash $h --> Buf ) {
      return self.encode_document($h);
    }

    # BSON Document
    # document ::= int32 e_list "\x00"
    #
    # The int32 is the total number of bytes comprising the document.
    #
    multi method encode_document ( Hash $h --> Buf ) {
      my Buf $b = self.encode_e_list($h.pairs);
      return [~] encode_int32($b.elems + 5), $b, Buf.new(0x00);
    }

    multi method encode_document ( Pair @p --> Buf ) {
      my Buf $b = self.encode_e_list(@p);
      return [~] encode_int32($b.elems + 5), $b, Buf.new(0x00);
    }

    # Sequence of elements
    # e_list ::= element e_list
    # | ""
    #
    method encode_e_list ( *@p --> Buf ) {
      my Buf $b = Buf.new();

      for @p -> $p {
        $b ~= self.encode_element($p);
      }

      return $b;
    }

    # Encode a key value pair
    # element ::= type-code e_name some-encoding
    #
    method encode_element ( Pair $p --> Buf ) {

      given $p.value {

        when Num {
          # Double precision
          # "\x01" e_name Num
          #
          return [~] Buf.new(0x01),
                     encode_e_name($p.key),
                     self._enc_double($p.value);
        }

        when Str {
          # UTF-8 string
          # "\x02" e_name string
          #
          return [~] Buf.new(0x02),
                     encode_e_name($p.key),
                     encode_string($p.value)
                     ;
        }

        when Hash {
          # Embedded document
          # "\x03" e_name document
          #
          return [~] Buf.new(0x03),
                     encode_e_name($p.key),
                     self.encode_document($_)
                     ;
        }

        when Array {
          # Array
          # "\x04" e_name document

          # The document for an array is a normal BSON document
          # with integer values for the keys,
          # starting with 0 and continuing sequentially.
          # For example, the array ['red', 'blue']
          # would be encoded as the document {'0': 'red', '1': 'blue'}.
          # The keys must be in ascending numerical order.
          #
          my %h = .kv;
          return [~] Buf.new(0x04),
                     encode_e_name($p.key),
                     self.encode_document(%h)
                     ;
        }

        when BSON::Binary {
          # Binary data
          # "\x05" e_name int32 subtype byte*
          # subtype is '\x00' for the moment (Generic binary subtype)
          #
          return [~] Buf.new(0x05), encode_e_name($p.key), .enc_binary();
        }

  #`{{
        # Do not know what type to test. Any?
        when Any {
          # Undefined deprecated 
          # "\x06" e_name
          #
          die X::BSON::Deprecated.new(
            operation => 'encode',
            type => 'Undefined(0x06)'
          );
        }
  }}
        when BSON::ObjectId {
          # ObjectId
          # "\x07" e_name (byte*12)
          #
          return Buf.new(0x07) ~ encode_e_name($p.key) ~ .Buf;
        }

        when Bool {
          # Bool
          # \0x08 e_name (\0x00 or \0x01)
          #
          if .Bool {
            # Boolean "true"
            # "\x08" e_name "\x01
            #
            return Buf.new(0x08) ~ encode_e_name($p.key) ~ Buf.new(0x01);
          }
          else {
            # Boolean "false"
            # "\x08" e_name "\x00
            #
            return Buf.new(0x08) ~ encode_e_name($p.key) ~ Buf.new(0x00);
          }
        }

        when DateTime {
          # UTC dateime
          # "\x09" e_name int64
          #
          return [~] Buf.new(0x09),
                     encode_e_name($p.key),
                     encode_int64($p.value().posix())
                     ;
        }

        when not .defined {
          # Null value
          # "\x0A" e_name
          #
          return Buf.new(0x0A) ~ encode_e_name($p.key);
        }

        when BSON::Regex {
          # Regular expression
          # "\x0B" e_name cstring cstring
          #
          return [~] Buf.new(0x0B),
                     encode_e_name($p.key),
                     encode_cstring($p.value.regex),
                     encode_cstring($p.value.options)
                     ;
        }

  #`{{
        when ... {
          # DBPointer - deprecated
          # "\x0C" e_name string (byte*12)
          #
          die X::BSON::Deprecated(
            operation => 'encoding DBPointer',
            type => '0x0C'
          );
        }
  }}

        # This entry does 2 codes. 0x0D for javascript only and 0x0F when
        # there is a scope document defined in the object
        #
        when BSON::Javascript {
          # Javascript code
          # "\x0D" e_name string
          # "\x0F" e_name int32 string document
          #
          if $p.value.has_javascript {
            my Buf $js = encode_string($p.value.javascript);

            if $p.value.has_scope {
              my Buf $doc = self.encode_document($p.value.scope);
              return [~] Buf.new(0x0F),
                         encode_e_name($p.key),
                         encode_int32([+] $js.elems, $doc.elems, 4),
                         $js, $doc
                         ;
            }

            else {
              return [~] Buf.new(0x0D),
                         encode_e_name($p.key),
                         encode_string($p.value.javascript)
                         ;
            }
          }

          else {
            die X::BSON::ImProperUse.new( :operation('encode'),
                                          :type('javascript 0x0D/0x0F'),
                                          :emsg('cannot send empty code')
                                        );
          }
        }

  #`{{
        when ... {
          # ? - deprecated
          # "\x0E" e_name string (byte*12)
          #
          die X::BSON::Deprecated(
            operation => 'encoding ?',
            type => '0x0E'
          );
        }

        when ... {
          # Javascript code with scope. Handled above.
          # "\x0F" e_name string document
        }
  }}

        when Int {
          # Integer
          # "\x10" e_name int32
          # '\x12' e_name int64
          #
          if -0xffffffff < $p.value < 0xffffffff {
            return [~] Buf.new(0x10),
                       encode_e_name($p.key),
                       encode_int32($p.value)
                       ;
          }

          elsif -0x7fffffff_ffffffff < $p.value < 0x7fffffff_ffffffff {
            return [~] Buf.new(0x12),
                       encode_e_name($p.key),
                       encode_int64($p.value)
                       ;
          }

          else {
            my $reason = 'small' if $p.value < -0x7fffffff_ffffffff;
            $reason = 'large' if $p.value > 0x7fffffff_ffffffff;
            die X::BSON::ImProperUse.new( :operation('encode'),
                                          :type('integer 0x10/0x12'),
                                          :emsg("cannot encode too $reason number")
                                        );
          }
        }

  #`{{
        when ... {
            # Timestamp. 
            # "\x11" e_name int64
            #
            # Special internal type used by MongoDB replication and
            # sharding. First 4 bytes are an increment, second 4 are a
            # timestamp.
        }
  }}

        when Buf {
          die X::BSON::ImProperUse.new(
              :operation('encode'),
              :type('Binary Buf'),
              :emsg('Buf not supported, please use BSON::Binary')
          );
        }

        default {
          if .can('encode') {
            my $code = 1; # which bson code

            return [~] Buf.new($code),
                       encode_e_name($p.key),
                       .encode;
                       ;
          }

          else {
            die X::BSON::NYS.new( :operation('encode'), :type($_));
  #             die "Sorry, not yet supported type: $_"; # ~ .WHAT;
          }
        }
      }
    }

    # 8 bytes double (64-bit floating point number)
    #
    method _enc_double ( Num $r is copy --> Buf ) {

      my Buf $a;
      my Num $r2;

      # Test special cases
      #
      # 0x 0000 0000 0000 0000 = 0
      # 0x 8000 0000 0000 0000 = -0       Not recognizable
      # 0x 7ff0 0000 0000 0000 = Inf
      # 0x fff0 0000 0000 0000 = -Inf
      #
      given $r {
        when 0.0 {
          $a = Buf.new(0 xx 8);
        }

        when -Inf {
          $a = Buf.new( 0 xx 6, 0xF0, 0xFF);
        }

        when Inf {
          $a = Buf.new( 0 xx 6, 0xF0, 0x7F);
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

          $a = encode_int64($i);
        }
      }

      return $a;
    }



    #-----------------------------------------------------------------------------
    # Method used to initialize the index for testing purposes when the decode
    # functions such as decode_double() are tested directly.
    #
    method _init_index ( ) {
      $!index = 0;
    }

    # Decoding a document given in a binary buffer
    #
    method decode ( Buf $b --> Hash ) {
      $!index = 0;
      return self.decode_document($b.list);
    }

    multi method decode_document ( Array $a --> Hash ) {
      my Int $i = decode_int32( $a, $!index);
      my Hash $h = self.decode_e_list($a);

      die X::BSON::Parse.new(
        :operation('decode_document'),
        :error('Missing trailing 0x00')
      ) unless $a[$!index++] ~~ 0x00;

      # Test doesn't work anymore because of sub documents
      #die "Parse error: $!index != \$a elems({$a.elems})"
      #  unless $!index == $a.elems;

      return $h;
    }

    multi method decode_document ( Array $a, Int $index is rw --> Hash ) {
      $!index = $index;
      my Hash $h = self.decode_document($a);
      $index = $!index;
      return $h;
    }

    method decode_e_list ( Array $a --> Hash ) {
      my Pair @p;
      while $a[$!index] !~~ 0x00 {
  #say "DL 0: $!index, $a[$!index]";
        my Pair $element = self.decode_element($a);
  #say "DL 1: $!index, ", $element.defined ?? $element !! 'undefined';
        push @p, $element;
      }

      return hash(@p);
    }

    method decode_element ( Array $a --> Pair ) {

  #say "DE 0: $!index, {$a.elems}, $a[$!index], {$a[$!index].perl}";

      # Type is given in first byte.
      #
      my $bson_code = $a[$!index++];
      if $bson_code == 0x01 {
        # Double precision
        # "\x01" e_name Num
        #
        return decode_e_name( $a, $!index) => self.decode_double($a);
      }

      elsif $bson_code == 0x02 {
        # UTF-8 string
        # "\x02" e_name string
        #
        return decode_e_name( $a, $!index) => decode_string( $a, $!index);
      }

      elsif $bson_code == 0x03 {
        # Embedded document
        # "\x03" e_name document
        #
        return decode_e_name( $a, $!index) => self.decode_document($a);
      }

      elsif $bson_code == 0x04 {
        # Array
        # "\x04" e_name document
        #
        # The document for an array is a normal BSON document
        # with integer values for the keys,
        # starting with 0 and continuing sequentially.
        # For example, the array ['red', 'blue']
        # would be encoded as the document {'0': 'red', '1': 'blue'}.
        # The keys must be in ascending numerical order.
        #
        # Cannot use a simple $h.values because the hash keys might not be
        # in an ascending order. Furthermore the sorting method must be forced
        # into integer comparison otherwise you get series like 0,1,10,11,...2,
        # etc
        # 
        my Str $key = decode_e_name( $a, $!index);
        my Hash $h = self.decode_document($a);
        my @values;
        for $h.keys.sort({$^x <=> $^y}) -> $k {@values.push($h{$k})};
        return $key => [@values];
      }

      elsif $bson_code == 0x05 {
        # Binary
        # "\x05 e_name int32 subtype byte*
        # subtype = byte \x00 .. \x05, \x80
        #
        my $name = decode_e_name( $a, $!index);
        my BSON::Binary $bin_obj .= new;
        $bin_obj.dec_binary( $a, $!index);
        return $name => $bin_obj;
      }

      elsif $bson_code == 0x06 {
        # Undefined and deprecated
        # "\x06" e_name
        #
        # Must drop some bytes from array.
        #
        decode_e_name( $a, $!index);
        die X::BSON::Deprecated.new( :operation('decode'),
                                     :type('Undefined(0x06)')
                                   );
      }

      elsif $bson_code == 0x07 {
        # ObjectId
        # "\x07" e_name (byte*12)
        #
        my $n = decode_e_name( $a, $!index);
        my @a = $a[$!index..($!index+11)];
        $!index += 12;
  #        my @a = $a.splice( 0, 12);

        my Buf $oid = Buf.new(@a);
        my BSON::ObjectId $o = BSON::ObjectId.decode($oid);
        return $n => $o;
      }

      elsif $bson_code == 0x08 {
        my $n = decode_e_name( $a, $!index);

        given $a[$!index++] {

          when 0x01 {
            # Boolean "true"
            # "\x08" e_name "\x01
            #
            return $n => Bool::True;
          }

          when 0x00 {
            # Boolean "false"
            # "\x08" e_name "\x00
            #
            return $n => Bool::False;
          }

          default {
            die X::BSON::Parse.new(
              :operation('decode_element'),
              :error('Faulty boolean code')
            );
          }
        }
      }

      elsif $bson_code == 0x09 {
        # Datetime
        # "\x09" e_name int64
        #
        return decode_e_name( $a, $!index) => DateTime.new(decode_int64( $a, $!index));
      }

      elsif $bson_code == 0x0A {
        # Null value
        # "\x0A" e_name
        #
        return decode_e_name( $a, $!index) => Any;
      }

      elsif $bson_code == 0x0B {
        # Regular expression
        # "\x0B" e_name cstring cstring
        #
        return decode_e_name( $a, $!index) =>
          BSON::Regex.new( :regex(decode_cstring( $a, $!index)),
                           :options(decode_cstring( $a, $!index))
                         );
      }

      elsif $bson_code == 0x0C {
        # DPPointer and deprecated
        # \0x0C e_name string (byte*12)
        #
        # Must drop some bytes from array.
        #
        decode_e_name( $a, $!index);
        decode_string( $a, $!index);
        $a[0..11];
        $!index += 12;
        die X::BSON::Deprecated.new( :operation('decode'),
                                     :type('DPPointer(0x0C)')
                                   );
      }

      elsif $bson_code == 0x0D {
        # Javascript code
        # "\x0D" e_name string
        #
        return decode_e_name( $a, $!index) =>
          BSON::Javascript.new( :javascript(decode_string( $a, $!index)));
      }

      elsif $bson_code == 0x0E {
        # ? deprecated
        # "\x0E" e_name string
        #
        # Must drop some bytes from array.
        #
        decode_e_name( $a, $!index);
        decode_string( $a, $!index);
        die X::BSON::Deprecated.new( :operation('decode'), :type('(0x0E)'));
      }

      elsif $bson_code == 0x0F {
        # Javascript code with scope
        # "\x0F" e_name string document
        #
        my $name = decode_e_name( $a, $!index);
        my $js_scope_size = decode_int32( $a, $!index);
        return $name =>
          BSON::Javascript.new( :javascript(decode_string( $a, $!index)),
                                :scope(self.decode_document($a))
                              );
      }

      elsif $bson_code == 0x10 {
        # 32-bit Integer
        # "\x10" e_name int32
        #
        return decode_e_name( $a, $!index) => decode_int32( $a, $!index);
      }
  #`{{
      elsif $bson_code == 0x11 {
        # Timestamp. 
        # "\x11" e_name int64
        # Special internal type used by MongoDB replication and
        # sharding. First 4 bytes are an increment, second 4 are a
        # timestamp.
      }
  }}

      elsif $bson_code == 0x12 {
        # 64-bit Integer
        # "\x12" e_name int64
        #
        return decode_e_name( $a, $!index) => decode_int64( $a, $!index);
      }
  #`{{
      elsif $bson_code == 0x7F {
        # Max key.
        # "\x7F" e_name
      }
  }}

  #`{{
      elsif $bson_code == 0xFF {
        # Min key.
        # "\xFF" e_name
      }
  }}

      else {
        # Number of bytes must be taken from $a otherwise a parse
        # error will occur later on.
        #

        die X::BSON::NYS.new( :operation('encode'),
                              :type('code ' ~ $_.fmt('%02x'))
                            );
  #              return X::NYI.new(feature => "Type $_");
  #              die 'Sorry, not yet supported type: ' ~ $_;
      }
    }



    #-----------------------------------------------------------------------------

    # We have to do some simulation using the information on
    # http://en.wikipedia.org/wiki/Double-precision_floating-point_format#Endianness
    # until better times come.
    #
    method decode_double ( Array $a ) {

      # Test special cases
      #
      # 0x 0000 0000 0000 0000 = 0
      # 0x 8000 0000 0000 0000 = -0
      # 0x 7ff0 0000 0000 0000 = Inf
      # 0x fff0 0000 0000 0000 = -Inf
      #
      my Bool $six-byte-zeros = True;
      for ^6 -> $i {
        if $a[$i] {
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

      elsif $a[6] == 0xF0 {
        if $a[7] == 0x7F {
          $value .= new(Inf);
        }

        elsif $a[7] == 0xFF {
          $value .= new(-Inf);
        }
      }

      # If value is set by the special cases above, remove the 8 bytes from
      # the array.
      #
      if $value.defined {
  #      $a.splice( 0, 8);
        $!index += 8;
      }

      # If value is not set by the special cases above, calculate it here
      #
      else {
        my Int $i = decode_int64( $a, $!index);
        my Int $sign = $i +& 0x8000_0000_0000_0000 ?? -1 !! 1;

        # Significand + implicit bit
        #
        my $significand = 0x10_0000_0000_0000 +| ($i +& 0xF_FFFF_FFFF_FFFF);

        # Exponent - bias (1023) - the number of bits for precision
        #
        my $exponent = (($i +& 0x7FF0_0000_0000_0000) +> 52) - 1023 - 52;

        $value = Num.new((2 ** $exponent) * $significand * $sign);
      }

      return $value; #X::NYI.new(feature => "Type Double");
    }
  }
}
