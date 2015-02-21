use v6;
use BSON::ObjectId;
use BSON::Regex;
use BSON::Javascript;

class X::BSON::Deprecated is Exception {
  has $.operation;                      # Operation encode, decode
  has $.type;                           # Type to encode/decode

  method message () {
      return [~] "\n$!operation\() error:\n",
                 "  Type $!type is deprecated by BSON specification\n"
                 ;
  }
}

class X::BSON::ImProperUse is Exception {
  has $.operation;                      # Operation encode, decode
  has $.type;                           # Type to encode/decode
  has $.emsg;                           # Extra message

  method message () {
      return "\n$!operation\() on $!type error: $!emsg";
  }
}


class BSON:ver<0.8.3> {

  method encode ( %h ) {

      return self._enc_document( %h );
  }

  method decode ( Buf $b ) {

      return self._dec_document( $b.list );
  }


  # BSON Document
  # document ::= int32 e_list "\x00"

  # The int32 is the total number of bytes comprising the document.

  method _enc_document ( %h ) {

      my $l = self._enc_e_list( %h.pairs );

      return self._enc_int32( $l.elems + 5 ) ~ $l ~ Buf.new( 0x00 );
  }

  method _dec_document ( Array $a ) {

      my $s = $a.elems;
      my $i = self._dec_int32($a);
      my %h = self._dec_e_list($a);

      die 'Parse error' unless $a.shift ~~ 0x00;
      die 'Parse error' unless $s ~~ $a.elems + $i;

      return %h;
  }


  # Sequence of elements
  # e_list ::= element e_list
  # | ""

  method _enc_e_list ( *@p ) {

      my Buf $b = Buf.new( );

      for @p -> $p {
          $b = $b ~ self._enc_element( $p );
      }

      return $b;
  }

  method _dec_e_list ( Array $a ) {

      my @p;
      while $a[0] !~~ 0x00 {
          push @p, self._dec_element($a);
      }

      return @p;
  }

  method _enc_element ( Pair $p ) {

      given $p.value {

          when Num {
              # Double precision
              # "\x01" e_name Num

              return Buf.new( 0x01 ) ~ self._enc_e_name( $p.key ) ~ self._enc_double( $p.value );
          }

          when Str {
              # UTF-8 string
              # "\x02" e_name string

              return Buf.new( 0x02 ) ~ self._enc_e_name( $p.key ) ~ self._enc_string( $p.value );
          }

          when Hash {
              # Embedded document
              # "\x03" e_name document

              return Buf.new( 0x03 ) ~  self._enc_e_name( $p.key ) ~ self._enc_document( $_ );
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

              my %h = .kv;

              return Buf.new( 0x04 ) ~  self._enc_e_name( $p.key ) ~ self._enc_document( %h );
          }

          when Buf {
              # Binary data
              # "\x05" e_name int32 subtype byte*
              # subtype is '\x00' for the moment (Generic binary subtype)
              #
              return [~] Buf.new( 0x05 ),
                         self._enc_e_name( $p.key ),
                         self._enc_binary( 0x00, $_);
          }

#`{{
          when ... {
              # Undefined deprecated 
              # "\x06" e_name
              
              # Do not know what type to test. Mu?
          }
}}

          when BSON::ObjectId {
              # ObjectId
              # "\x07" e_name (byte*12)

              return Buf.new( 0x07 ) ~ self._enc_e_name( $p.key ) ~ .Buf;
          }

          when Bool {
              # Bool
              # \0x08 e_name (\0x00 or \0x01)
              #
              if .Bool {
                  # Boolean "true"
                  # "\x08" e_name "\x01

                  return Buf.new( 0x08 ) ~ self._enc_e_name( $p.key ) ~ Buf.new( 0x01 );
              }
              else {
                  # Boolean "false"
                  # "\x08" e_name "\x00

                  return Buf.new( 0x08 ) ~ self._enc_e_name( $p.key ) ~ Buf.new( 0x00 );
              }
          }

          when DateTime {
              # UTC dateime
              # "\x09" e_name int64
              #
              return [~] Buf.new( 0x09 ),
                         self._enc_e_name( $p.key ),
                         self._enc_int64( $p.value().posix() )
                         ;
          }

          when not .defined {
              # Null value
              # "\x0A" e_name
              #
              return Buf.new( 0x0A ) ~ self._enc_e_name( $p.key );
          }

          when BSON::Regex {
              # Regular expression
              # "\x0B" e_name cstring cstring
              #
              return [~] Buf.new( 0x0B ),
                         self._enc_e_name( $p.key ),
                         self._enc_cstring( $p.value.regex ),
                         self._enc_cstring( $p.value.options )
                         ;
          }

#`{{
          when ... {
              # DBPointer - deprecated
              # "\x0C" e_name string (byte*12)
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

                  my Buf $js = self._enc_string($p.value.javascript);
                  if $p.value.has_scope {

                      my Buf $doc = self._enc_document($p.value.scope);
                      return [~] Buf.new( 0x0F ),
                                 self._enc_e_name($p.key),
                                 self._enc_int32([+] $js.elems, $doc.elems, 4),
                                 $js, $doc
                                 ;
                  }

                  else {
                      my Buf $js = self._enc_string($p.value.javascript);
                      return [~] Buf.new( 0x0D ),
                                 self._enc_e_name($p.key),
                                 $js
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
          }
}}

#`{{
          when ... {
              # Javascript code. Handled above.
              # "\x0F" e_name string document
          }
}}

          when Int {
              # 32-bit Integer
              # "\x10" e_name int32

              return Buf.new( 0x10 ) ~ self._enc_e_name( $p.key ) ~ self._enc_int32( $p.value );
          }

          default {

              die 'Sorry, not yet supported type: ' ~ .WHAT;
          }

      }

  }

  # Test elements see http://bsonspec.org/spec.html
  #
  # Basic types are;
  #
  # byte 	        1 byte (8-bits)
  # int32 	4 bytes (32-bit signed integer, two's complement)
  # int64 	8 bytes (64-bit signed integer, two's complement)
  # double 	8 bytes (64-bit IEEE 754 floating point)
  #
  method _dec_element ( Array $a ) {

      # Type is given in first byte.
      #
      given $a.shift {


          when 0x01 {
              # Double precision
              # "\x01" e_name Num

              return self._dec_e_name( $a ) => self._dec_double( $a );
          }

          when 0x02 {
              # UTF-8 string
              # "\x02" e_name string

              return self._dec_e_name( $a ) => self._dec_string( $a );
          }

          when 0x03 {
              # Embedded document
              # "\x03" e_name document

              return self._dec_e_name( $a )  => self._dec_document( $a );
          }

          when 0x04 {
              # Array
              # "\x04" e_name document

              # The document for an array is a normal BSON document
              # with integer values for the keys,
              # starting with 0 and continuing sequentially.
              # For example, the array ['red', 'blue']
              # would be encoded as the document {'0': 'red', '1': 'blue'}.
              # The keys must be in ascending numerical order.

              return self._dec_e_name( $a ) => [ self._dec_document( $a ).values ];
          }

          when 0x05 {
              # Binary
              # "\x05 e_name int32 subtype byte*
              # subtype = byte \x00 .. \x05, \x80

              return self._dec_e_name( $a ) => self._dec_binary( $a );
          }

          when 0x06 {
              # Undefined and deprecated
              # "\x06" e_name
              #
              # Must drop some bytes from array.
              #
              self._dec_e_name( $a );
              die X::BSON::Deprecated.new( :operation('decode'),
                                           :type('Undefined(0x06)')
                                         );
          }

          when 0x07 {
              # ObjectId
              # "\x07" e_name (byte*12)

              my $n = self._dec_e_name( $a );

              my @a;
              @a.push( $a.shift ) for ^ 12;

              return $n => BSON::ObjectId.new( Buf.new( @a ) );
          }

          when 0x08 {
              my $n = self._dec_e_name( $a );

              given $a.shift {

                  when 0x01 {
                      # Boolean "true"
                      # "\x08" e_name "\x01

                      return $n => Bool::True;
                  }

                  when 0x00 {
                      # Boolean "false"
                      # "\x08" e_name "\x00

                      return $n => Bool::False;
                  }

                  default {

                      die 'Parse error';
                  }
              }
          }

          when 0x09 {
              # Datetime
              # "\x09" e_name int64
              #
              return self._dec_e_name( $a ) => DateTime.new(self._dec_int64( $a ));
          }

          when 0x0A {
              # Null value
              # "\x0A" e_name
              #
              return self._dec_e_name( $a ) => Any;
          }

          when 0x0B {
              # Regular expression
              # "\x0B" e_name cstring cstring
              #
              return self._dec_e_name($a) =>
                  BSON::Regex.new( :regex(self._dec_cstring($a)),
                                   :options(self._dec_cstring($a))
                                 );
          }

          when 0x0C {
              # DPPointer and deprecated
              # \0x0C e_name string (byte*12)
              #
              # Must drop some bytes from array.
              #
              self._dec_e_name($a);
              self._dec_string($a);
              $a.splice( 0, 12);
              die X::BSON::Deprecated.new( :operation('decode'),
                                           :type('Undefined(0x06)')
                                         );
          }

          when 0x0D {
              # Javascript code
              # "\x0D" e_name string
              #
              return self._dec_e_name($a) =>
                  BSON::Javascript.new( :javascript(self._dec_string($a)));
          }

          when 0x0E {
              # ? deprecated
              # "\x0E" e_name string
              #
              # Must drop some bytes from array.
              #
              self._dec_e_name($a);
              self._dec_string($a);
              die X::BSON::Deprecated.new( :operation('decode'),
                                           :type('(0x0E)')
                                         );
          }

          when 0x0F {
              # Javascript code with scope
              # "\x0F" e_name string document
              #
              my $name = self._dec_e_name($a);
              my $js_scope_size = self._dec_int32($a);
              return $name =>
                  BSON::Javascript.new( :javascript(self._dec_string($a)),
                                        :scope(self._dec_document($a))
                                      );
          }

          when 0x10 {
              # 32-bit Integer
              # "\x10" e_name int32

              return self._dec_e_name($a) => self._dec_int32($a);
          }

          default {

              # Number of bytes must be taken from $a otherwise a parse
              # error will occur later on.
              #
              return X::NYI.new(feature => "Type $_")
  #            die 'Sorry, not yet supported type: ' ~ $_;
          }

      }

  }


  # Binary buffer
  #
  method _enc_binary ( Int $sub_type, Buf $b ) {

       return [~] self._enc_int32($b.elems), Buf.new( $sub_type, $b.list);
  }

  method _dec_binary ( Array $a ) {

      # Get length
      my $lng = self._dec_int32( $a );

      # Get subtype
      my $sub_type = $a.shift;

      # Most of the tests are not necessary because of arbitrary sizes.
      # UUID and MD5 can be tested.
      #
      given $sub_type {
          when 0x00 {
              # Generic binary subtype
          }

          when 0x01 {
              # Function
          }

          when 0x02 {
              # Binary (Old - deprecated)
              die 'Code (0x02) Deprecated binary data';
          }

          when 0x03 {
              # UUID (Old - deprecated)
              die 'UUID(0x03) Deprecated binary data';
          }

          when 0x04 {
              # UUID. According to http://en.wikipedia.org/wiki/Universally_unique_identifier
              # the universally unique identifier is a 128-bit (16 byte) value.
              die 'UUID(0x04) Binary string parse error' unless $lng ~~ 16;
          }

          when 0x05 {
              # MD5. This is a 16 byte number (32 character hex string)
              die 'UUID(0x04) Binary string parse error' unless $lng ~~ 16;
          }

          when 0x80 {
              # User defined. That is, all other codes 0x80 .. 0xFF
          }
      }

      # Just return part of the array.
      return Buf.new( $a.splice( 0, $lng));
  }



  # 4 bytes (32-bit signed integer)
  method _enc_int32 ( Int $i ) {

      return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100, $i +> 0x18 % 0x100 );
  }

  method _dec_int32 ( Array $a ) {

      return [+] $a.shift, $a.shift +< 0x08, $a.shift +< 0x10, $a.shift +< 0x18;
  }

  # 8 bytes (64-bit number)
  method _enc_double ( Num $r is copy ) {

      my Buf $a;

      # Test special cases
      #
      # 0x 0000 0000 0000 0000 = 0
      # 0x 8000 0000 0000 0000 = -0       Not recognizable
      # 0x 7ff0 0000 0000 0000 = Inf
      # 0x fff0 0000 0000 0000 = -Inf
      #
      if $r == Num.new(0) {
          $a = Buf.new(0 xx 8);
      }

      elsif $r == Num.new(-Inf) {
          $a = Buf.new( 0 xx 6, 0xF0, 0xFF);
      }

      elsif $r == Num.new(Inf) {
          $a = Buf.new( 0 xx 6, 0xF0, 0x7F);
      }

      else
      {
          my Int $sign = $r.sign == -1 ?? -1 !! 1;
          $r *= $sign;

          # Get proper precision from base(2) by first shifting 52 places which
          # is the number of precision bits. Adjust the exponent bias for this.
          #
          my Int $exp-shift = 0;
          my Int $exponent = 1023;
          my Str $bit-string = $r.base(2);

          # Smaller than zero
          #
          if $bit-string ~~ m/^0\./ {

              # Normalize
              #
              my $first-one = $bit-string.index('1');
              $exponent -= $first-one - 1;

              # Multiply to get more bits in precision
              #
              while $bit-string ~~ m/^0\./ {      # Starts with 0.
                  $exp-shift += 52;               # modify precision
                  $r *= 2 ** $exp-shift;          # modify number
                  $bit-string = $r.base(2)        # Get bit string again
              }
          }

          # Bigger than zero
          #
          else {
              # Normalize
              #
              my Int $dot-loc = $bit-string.index('.');
              $exponent += $dot-loc - 1;

              # If dot is in the string, not at the end, the precision might
              # be not sufficient. Enlarge one time more
              #
              my Int $str-len = $bit-string.chars;
              if $dot-loc < $str-len - 1 {
                  $r *= 2 ** 52;
                  $bit-string = $r.base(2)
              }
          }

          $bit-string ~~ s/<[0.]>*$//;            # Remove trailing zeros
          $bit-string ~~ s/\.//;                  # Remove the dot
          my @bits = $bit-string.split('');       # Create array of '1' and '0'
          @bits.shift;                            # Remove the first 1.

          my Int $i = $sign == -1 ?? 0x8000_0000_0000_0000 !! 0;
          $i = $i +| ($exponent +< 52);
          my Int $bit-pattern = 1 +< 51;
          do for @bits -> $bit {
              $i = $i +| $bit-pattern if $bit eq '1';

              $bit-pattern = $bit-pattern +> 1;

              last unless $bit-pattern;
          }

          $a = self._enc_int64($i);
      }

      return $a;
  }

  # We have to do some simulation using the information on
  # http://en.wikipedia.org/wiki/Double-precision_floating-point_format#Endianness
  # until better times come.
  #
  method _dec_double ( Array $a ) {

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
          $a.splice( 0, 8);
      }

      # If value is not set by the special cases above, calculate it here
      #
      else {
        my Int $i = self._dec_int64( $a );
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

  # 8 bytes (64-bit int)
  method _enc_int64 ( Int $i ) {

      return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100,
                      $i +> 0x18 % 0x100, $i +> 0x20 % 0x100,
                      $i +> 0x28 % 0x100, $i +> 0x30 % 0x100,
                      $i +> 0x38 % 0x100
                    );
  }

  method _dec_int64 ( Array $a ) {

      return [+] $a.shift, $a.shift +< 0x08, $a.shift +< 0x10, $a.shift +< 0x18
               , $a.shift +< 0x20, $a.shift +< 0x28, $a.shift +< 0x30
               , $a.shift +< 0x38
               ;
  }


  # Key name
  # e_name ::= cstring

  method _enc_e_name ( Str $s ) {

      return self._enc_cstring( $s );
  }

  method _dec_e_name ( Array $a ) {

      return self._dec_cstring( $a );
  }


  # String
  # string ::= int32 (byte*) "\x00"

  # The int32 is the number bytes in the (byte*) + 1 (for the trailing '\x00').
  # The (byte*) is zero or more UTF-8 encoded characters.

  method _enc_string ( Str $s ) {
#say "CF: ", callframe(1).file, ', ', callframe(1).line;
      my $b = $s.encode('UTF-8');
      return self._enc_int32($b.bytes + 1) ~ $b ~ Buf.new(0x00);
  }

  method _dec_string ( Array $a ) {

      my $i = self._dec_int32( $a );

      my @a;
      @a.push( $a.shift ) for ^ ( $i - 1 );

      die 'Parse error' unless $a.shift ~~ 0x00;

      return Buf.new( @a ).decode( );
  }


  # CString
  # cstring ::= (byte*) "\x00"

  # Zero or more modified UTF-8 encoded characters followed by '\x00'.
  # The (byte*) MUST NOT contain '\x00', hence it is not full UTF-8.

  method _enc_cstring ( Str $s ) {

      die "Forbidden 0x00 sequence in $s" if $s ~~ /\x00/;

      return $s.encode() ~ Buf.new(0x00);
  }

  method _dec_cstring ( Array $a ) {

      my @a;
      while $a[ 0 ] !~~ 0x00 {
          @a.push( $a.shift );
      }

      die 'Parse error' unless $a.shift ~~ 0x00;
      return Buf.new( @a ).decode();
  }
}
