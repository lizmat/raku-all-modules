use v6;
use BSON::ObjectId-old;
use BSON::Regex;
use BSON::Javascript-old;
use BSON::Binary-old;
use BSON::Double;
use BSON::EDCTools;
use BSON::Exception;

package BSON:ver<0.9.14> {

  class Bson {
    constant $BSON_BOOL = 0x08;

    has Int $!index = 0;
    
    #---------------------------------------------------------------------------
    # Test elements see http://bsonspec.org/spec.html
    #
    # Basic types are;
    #
    # byte 	1 byte (8-bits)
    # int32 	4 bytes (32-bit signed integer, two's complement)
    # int64 	8 bytes (64-bit signed integer, two's complement)
    # double 	8 bytes (64-bit IEEE 754 floating point)
    #
    #---------------------------------------------------------------------------
    # Encoding a document given in a hash variable
    #
    method encode ( Hash:D $h --> Buf ) {
      return self.encode-document($h);
    }

    #---------------------------------------------------------------------------
    # BSON Document
    # document ::= int32 e_list "\x00"
    #
    # The int32 is the total number of bytes comprising the document.
    #
    multi method encode_document ( Hash:D $h --> Buf ) is DEPRECATED('encode-document') {
      my Buf $b = self.encode-e-list($h.pairs);
      return [~] encode-int32($b.elems + 5), $b, Buf.new(0x00);
    }

    multi method encode-document ( Hash:D $h --> Buf ) {
      my Buf $b = self.encode-e-list($h.pairs);
      return [~] encode-int32($b.elems + 5), $b, Buf.new(0x00);
    }

    multi method encode_document ( Pair:D @p --> Buf ) is DEPRECATED('encode-document') {
      my Buf $b = self.encode-e-list(@p);
      return [~] encode-int32($b.elems + 5), $b, Buf.new(0x00);
    }

    multi method encode-document ( Pair:D @p --> Buf ) {
      my Buf $b = self.encode-e-list(@p);
      return [~] encode-int32($b.elems + 5), $b, Buf.new(0x00);
    }

    #---------------------------------------------------------------------------
    # Sequence of elements
    # e_list ::= element e_list
    # | ""
    #
    method encode_e_list ( @p --> Buf ) is DEPRECATED('encode-e-list') {
      my Buf $b = Buf.new();
      for @p -> $p { $b ~= self.encode-element($p); }
      return $b;
    }

    method encode-e-list ( @p --> Buf ) {
      my Buf $b = Buf.new();

      for @p -> $p {
        $b ~= self.encode-element($p);
      }

      return $b;
    }

    #---------------------------------------------------------------------------
    # Encode a key value pair
    # element ::= type-code e_name some-encoding
    #
    method encode_element ( Pair:D $p --> Buf ) is DEPRECATED('encode-element') {
      return self.encode-element($p);
    }

    method encode-element ( Pair:D $p --> Buf ) {

      given $p.value {

        when Num {
          # Double precision
          # "\x01" e_name Num
          #
#          return BSON::Double.encode-double($p);

          return [~] Buf.new(0x01),
                     encode-e-name($p.key),
                     BSON::Double.encode-double($p.value);
        }

        when Str {
          # UTF-8 string
          # "\x02" e_name string
          #
          return [~] Buf.new(0x02),
                     encode-e-name($p.key),
                     encode-string($p.value)
                     ;
        }

        # Converting a pair same way as a hash:
        #
        when Pair {
          # Embedded document
          # "\x03" e_name document
          #
          my Pair @pairs = $p.value;
          return [~] Buf.new(0x03),
                     encode-e-name($p.key),
                     self.encode-document(@pairs)
                     ;
        }

        when Hash {
          # Embedded document
          # "\x03" e_name document
          #
          return [~] Buf.new(0x03),
                     encode-e-name($p.key),
                     self.encode-document($p.value)
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
          # Simple assigning .kv to %hash wouldn't work because the order
          # of items can go wrong. Mongo doesn't process it very well if e.g.
          # { 1 => 'abc', 0 => 'def' } was encoded instead of
          # { 0 => 'def', 1 => 'abc' }.
          #
           my Pair @pairs;
          for .kv -> $k, $v {
            @pairs.push: ("$k" => $v);
          }

          return [~] Buf.new(0x04),
                     encode-e-name($p.key),
                     self.encode-document(@pairs)
                     ;
        }

        when BSON::Binary {
          # Binary data
          # "\x05" e_name int32 subtype byte*
          # subtype is '\x00' for the moment (Generic binary subtype)
          #
          return [~] Buf.new(0x05), encode-e-name($p.key), .encode-binary();
        }

  #`{{
        # Do not know what type to test. Any, Nil?
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
          return Buf.new(0x07) ~ encode-e-name($p.key) ~ .Buf;
        }

        when Bool {
          # Bool
          # \0x08 e_name (\0x00 or \0x01)
          #
          if .Bool {
            # Boolean "true"
            # "\x08" e_name "\x01
            #
            return Buf.new(0x08) ~ encode-e-name($p.key) ~ Buf.new(0x01);
          }
          else {
            # Boolean "false"
            # "\x08" e_name "\x00
            #
            return Buf.new(0x08) ~ encode-e-name($p.key) ~ Buf.new(0x00);
          }
        }

        when DateTime {
          # UTC dateime
          # "\x09" e_name int64
          #
          return [~] Buf.new(0x09),
                     encode-e-name($p.key),
                     encode-int64($p.value().posix())
                     ;
        }

        when not .defined {
          # Null value
          # "\x0A" e_name
          #
          return Buf.new(0x0A) ~ encode-e-name($p.key);
        }

        when BSON::Regex {
          # Regular expression
          # "\x0B" e_name cstring cstring
          #
          return [~] Buf.new(0x0B),
                     encode-e-name($p.key),
                     encode-cstring($p.value.regex),
                     encode-cstring($p.value.options)
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

#          return .encode-javascript( $p.key, self);
#`{{}}
          # Javascript code
          # "\x0D" e_name string
          # "\x0F" e_name int32 string document
          #
          if .has_javascript {
            my Buf $js = encode-string(.javascript);

            if $p.value.has_scope {
              my Buf $doc = self.encode-document(.scope);
              return [~] Buf.new(0x0F),
                         encode-e-name($p.key),
                         encode-int32([+] $js.elems, $doc.elems, 4),
                         $js, $doc
                         ;
            }

            else {
              return [~] Buf.new(0x0D), encode-e-name($p.key), $js;
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
                       encode-e-name($p.key),
                       encode-int32($p.value)
                       ;
          }

          elsif -0x7fffffff_ffffffff < $p.value < 0x7fffffff_ffffffff {
            return [~] Buf.new(0x12),
                       encode-e-name($p.key),
                       encode-int64($p.value)
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
            my $code = 0x1F; # which bson code??

            return [~] Buf.new($code),
                       encode-e-name($p.key),
                       .encode;
                       ;
          }

          else {
            die X::BSON::NYS.new(
              :operation('encode'),
              :type($_ ~ '(' ~ $_.WHAT ~ ')')
            );
          }
        }
      }
    }

    #---------------------------------------------------------------------------
    # Method used to initialize the index for testing purposes when the decode
    # functions such as decode_double() are tested directly.
    #
    method _init_index ( ) is DEPRECATED('init-index') {
      $!index = 0;
    }

    method init-index ( ) {
      $!index = 0;
    }

    #---------------------------------------------------------------------------
    # Decoding a document given in a binary buffer
    #
    method decode ( Buf:D $b --> Hash ) {
      $!index = 0;
      return self.decode-document($b.list);
    }

    #---------------------------------------------------------------------------
    #
    multi method decode_document ( List:D $a --> Hash ) is DEPRECATED('decode-document') {
      return self.decode-document($a.Array);
    }

    multi method decode-document ( List:D $a --> Hash ) {
      return self.decode-document($a.Array);
    }

    multi method decode_document ( Array:D $a --> Hash ) is DEPRECATED('decode-document') {
      return self.decode-document($a);
    }

    multi method decode-document ( Array:D $a --> Hash ) {
      my Int $i = decode-int32( $a, $!index);
      my Hash $h = self.decode-e-list($a);

      die X::BSON::Parse.new(
        :operation('decode-document'),
        :error('Missing trailing 0x00')
      ) unless $a[$!index++] ~~ 0x00;

      # Test doesn't work anymore because of sub documents
      #die "Parse error: $!index != \$a elems({$a.elems})"
      #  unless $!index == $a.elems;

      return $h;
    }

    multi method decode_document ( Array:D $a, Int:D $index is rw --> Hash ) is DEPRECATED('decode-document') {
      return self.decode-document( $a, $index);
    }

    multi method decode-document ( Array:D $a, Int:D $index is rw --> Hash ) {
      $!index = $index;
      my Hash $h = self.decode-document($a);
      $index = $!index;
      return $h;
    }


    #---------------------------------------------------------------------------
    multi method decode_e_list ( List:D $a --> Hash ) is DEPRECATED('decode-e-list') {
      return self.decode-e-list($a.Array);
    }

    multi method decode_e_list ( List:D $a --> Hash ) {
      return self.decode-e-list($a.Array);
    }

    multi method decode_e_list ( Array:D $a --> Hash ) is DEPRECATED('decode-e-list') {
      return self.decode-e-list($a);
    }

    multi method decode-e-list ( Array:D $a --> Hash ) {
      my Pair @p;
      while $a[$!index] !~~ 0x00 {
        my Pair $element = self.decode-element($a);
        push @p, $element;
      }

      return hash(@p);
    }


    #---------------------------------------------------------------------------
    multi method decode_element ( List:D $a --> Pair ) is DEPRECATED('decode-element') {
      self.decode-element($a.Array);
    }

    multi method decode-element ( List:D $a --> Pair ) {
      self.decode-element($a.Array);
    }

    multi method decode_element ( Array:D $a --> Pair ) is DEPRECATED('decode-element') {
      self.decode-element($a);
    }

    multi method decode-element ( Array:D $a --> Pair ) {

      # Type is given in first byte.
      #
      my $bson_code = $a[$!index++];
      if $bson_code == 0x01 {
        # Double precision
        # "\x01" e_name Num
        #
        my Str $key-name = decode-e-name( $a, $!index);

        return $key-name => BSON::Double.decode-double( $a, $!index);
#`{{
        return decode-e-name( $a, $!index) =>
               BSON::Double.decode-double( $a, $!index);
}}
      }

      elsif $bson_code == 0x02 {
        # UTF-8 string
        # "\x02" e_name string
        #
        return decode-e-name( $a, $!index) => decode-string( $a, $!index);
      }

      elsif $bson_code == 0x03 {
        # Embedded document
        # "\x03" e_name document
        #
        return decode-e-name( $a, $!index) => self.decode-document($a);
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
        my Str $key = decode-e-name( $a, $!index);
        my Hash $h = self.decode-document($a);
        my @values;
        for $h.keys.sort({$^x <=> $^y}) -> $k {@values.push($h{$k})};
        return $key => [@values];
      }

      elsif $bson_code == 0x05 {
        # Binary
        # "\x05 e_name int32 subtype byte*
        # subtype = byte \x00 .. \x05, \x80
        #
        my $name = decode-e-name( $a, $!index);
        my BSON::Binary $bin_obj .= new;
        $bin_obj.decode-binary( $a, $!index);
        return $name => $bin_obj;
      }

      elsif $bson_code == 0x06 {
        # Undefined and deprecated
        # "\x06" e_name
        #
        # Must drop some bytes from array.
        #
        decode-e-name( $a, $!index);
        die X::BSON::Deprecated.new( :operation('decode'),
                                     :type('Undefined(0x06)')
                                   );
      }

      elsif $bson_code == 0x07 {
        # ObjectId
        # "\x07" e_name (byte*12)
        #
        my $n = decode-e-name( $a, $!index);
        my @a = $a[$!index..($!index+11)];
        $!index += 12;

        my Buf $oid = Buf.new(@a);
        my BSON::ObjectId $o = BSON::ObjectId.decode($oid);
        return $n => $o;
      }

      elsif $bson_code == 0x08 {
        my $n = decode-e-name( $a, $!index);

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
        return decode-e-name( $a, $!index) => DateTime.new(decode-int64( $a, $!index));
      }

      elsif $bson_code == 0x0A {
        # Null value
        # "\x0A" e_name
        #
        return decode-e-name( $a, $!index) => Any;
      }

      elsif $bson_code == 0x0B {
        # Regular expression
        # "\x0B" e_name cstring cstring
        #
        return decode-e-name( $a, $!index) =>
          BSON::Regex.new( :regex(decode-cstring( $a, $!index)),
                           :options(decode-cstring( $a, $!index))
                         );
      }

      elsif $bson_code == 0x0C {
        # DPPointer and deprecated
        # \0x0C e_name string (byte*12)
        #
        # Must drop some bytes from array.
        #
        decode-e-name( $a, $!index);
        decode-string( $a, $!index);
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
#        return BSON::Javascript.decode-javascript( $a, $!index);
#`{{}}

        return decode-e-name( $a, $!index) =>
          BSON::Javascript.new( :javascript(decode-string( $a, $!index)));
      }

      elsif $bson_code == 0x0E {
        # ? deprecated
        # "\x0E" e_name string
        #
        # Must drop some bytes from array.
        #
        decode-e-name( $a, $!index);
        decode-string( $a, $!index);
        die X::BSON::Deprecated.new( :operation('decode'), :type('(0x0E)'));
      }

      elsif $bson_code == 0x0F {
        # Javascript code with scope
        # "\x0F" e_name string document
        #
        my $name = decode-e-name( $a, $!index);
        my $js_scope_size = decode-int32( $a, $!index);
        return $name =>
          BSON::Javascript.new( :javascript(decode-string( $a, $!index)),
                                :scope(self.decode-document($a))
                              );
      }

      elsif $bson_code == BSON::C-INT32 {
        # 32-bit Integer
        # "\x10" e_name int32
        #
        return decode-e-name( $a, $!index) => decode-int32( $a, $!index);
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
        return decode-e-name( $a, $!index) => decode-int64( $a, $!index);
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
  }
}
