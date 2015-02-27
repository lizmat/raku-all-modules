use v6;
#use BSON;

class BSON::Binary {
#  our $bson = BSON.new;

  constant $GENERIC             = 0x00;
  constant $FUNCTION            = 0x01;
  constant $BINARY-OLD          = 0x02;         # Deprecated
  constant $UUID-OLD            = 0x03;         # Deprecated
  constant $UUID                = 0x04;
  constant $MD5                 = 0x05;

  # User defined codes where code starts from 0x80
  #
  #constant
  #constant 

  has Buf $.binary_data;
  has Bool $.has_binary_data = False;
  has Int $.binary_type;

  method raw ( Buf $data --> BSON::Binary ) {

      $!binary_data = $data;
      $!has_binary_data = ?$!binary_data;
      $!binary_type = $GENERIC;

      return self;
  }

  method Buf ( --> Buf ) {

      return $!binary_data;
  }

  method _enc_binary ( $bson --> Buf ) {

      if $!has_binary_data {
          return [~] $bson._enc_int32($!binary_data.elems),
                     Buf.new( $!binary_type, $!binary_data.list);
      }

      else {
          return [~] $bson._enc_int32(0), Buf.new($!binary_type);
      }
  }

  method _dec_binary ( $bson, Array $a ) {

      # Get length
      #
      my $lng = $bson._dec_int32($a);

      # Get subtype
      #
      my $sub_type = $a.shift;

      # Most of the tests are not necessary because of arbitrary sizes.
      # UUID and MD5 can be tested.
      #
      given $sub_type {
          when $GENERIC {
              # Generic binary subtype
          }

          when $FUNCTION {
              # Function
          }

          when $BINARY-OLD {
              # Binary (Old - deprecated)
              die 'Code (0x02) Deprecated binary data';
          }

          when $UUID-OLD {
              # UUID (Old - deprecated)
              die 'UUID(0x03) Deprecated binary data';
          }

          when $UUID {
              # UUID. According to http://en.wikipedia.org/wiki/Universally_unique_identifier
              # the universally unique identifier is a 128-bit (16 byte) value.
              die 'UUID(0x04) Binary string parse error' unless $lng ~~ 16;
          }

          when $MD5 {
              # MD5. This is a 16 byte number (32 character hex string)
              die 'UUID(0x04) Binary string parse error' unless $lng ~~ 16;
          }

          when 0x80 {
              # User defined. That is, all other codes 0x80 .. 0xFF
          }
      }

      # Store part of the array.
      #
      $!binary_data = Buf.new( $a.splice( 0, $lng));
      $!binary_type = $sub_type;
      $!has_binary_data = ?$!binary_data;
  }
}
