use v6;
use BSON;

class X::BSON::Encodable is Exception {
  has $.operation;                      # Operation encode, decode or other
  has $.type;                           # Type to handle
  has $.emsg;                           # Extra message

  method message () {
      return "\n$!operation\() on $!type error: $!emsg";
  }
}

# This role implements BSON serialization functions. To provide full encoding
# of a type more information must be stored. This class must represent
# a document such as { key => SomeType.new(...) }. Therefore it needs to store
# the key name and the data representing the class.
# Furthermore it needs a code for the specific BSON type.
# 
#
# Role to encode to and/or decode from a BSON representation.
#
role BSON::Encodable is BSON {

  has Int $.bson_code;
  has Str $.key_name;
  has Any $.key_data;

  submethod BUILD ( :$bson_code, :$key_name, :$key_data ) {
      my $code = $bson_code // '-';
      if !?$bson_code or $bson_code < 0x00 or $bson_code > 0xFF {
          die X::BSON::Encodable.new(
              :operation('bson_code'),
              :type(self.^name),
              :emsg("Code $code out of bounds, must be positive 8 bit int")
          )
      }

      $!bson_code = $bson_code if ?$bson_code;
      $!key_name = $key_name if ?$key_name;
      $!key_data = $key_data if ?$key_data;
  }

  # Encode internal data to a binary buffer
  #
  method encode( --> Buf ) { ... }

  # Decode a binary buffer to internal data.
  #
  method decode( List $b ) { ... }



  method _encode_code ( --> Buf ) {

      return Buf.new($!bson_code);
  }

  method _encode_key ( --> Buf ) {
  
      return self._enc_e_name($!key_name);
  }

  method _decode_code ( $b ) {
  
      $!bson_code = $b.shift;
  }

  method _decode_key ( $b ) {
  
      $!key_name = self._dec_e_name( $b );
  }
}

