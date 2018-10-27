use v6;

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
role BSON::Encodable {

  has Int $!bson_code;
  has Str $!key_name;
  has Any $.key_data is rw;

  submethod init ( Int :$bson_code, Str :$key_name, :$key_data ) {
    my $code = $bson_code // 'undefined';

    if !?$bson_code or $code < 0x00 or $code > 0xFF {
      die X::BSON::Encodable.new(
          :operation('bson_code'),
          :type(self.^name),
          :emsg("Code $code out of bounds or not defined, must be positive 8 bit int")
      )
    }

    $!bson_code = $code;
    $!key_name = $key_name if ?$key_name;
    $!key_data = $key_data if ?$key_data;
  }

  #-----------------------------------------------------------------------------
  # Basic encoding functions
  #
  # Encode code, key and data
  #
  method encode( --> Buf ) {
    return [~] self.encode_code,
               self.encode_key,
               self.encode_obj($!key_data);
  }

  # Abstract method to encode internal data to a binary buffer
  #
  method encode_obj( $data --> Buf ) { ... }

  # Encode bson code
  #
  method encode_code ( --> Buf ) {
    return Buf.new($!bson_code);
  }

  # Encode key
  #
  method encode_key ( --> Buf ) {
  
    return self!enc_e_name($!key_name);
  }

  method !enc_e_name ( Str $s --> Buf ) {

    return self!enc_cstring($s);
  }

  method !enc_cstring ( Str $s --> Buf ) {

    die "Forbidden 0x00 sequence in $s" if $s ~~ /\x00/;

    return $s.encode() ~ Buf.new(0x00);
  }

  # string ::= int32 (byte*) "\x00"
  #
  method !enc_string ( Str $s --> Buf ) {
#say "CF: ", callframe(1).file, ', ', callframe(1).line;
    my $b = $s.encode('UTF-8');
    return self!enc_int32($b.bytes + 1) ~ $b ~ Buf.new(0x00);
  }

  # 4 bytes (32-bit signed integer)
  #
  method !enc_int32 ( Int $i #`{{is copy}} ) {
#say "CF: $i", callframe(1).file, ', ', callframe(1).line;
    my int $ni = $i;      
    return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
                  );
# Original method goes wrong on negative numbers. Also modulo operations are
# slower than the bit operations.
# return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100, $i +> 0x18 % 0x100 );
  }
  
  # 8 bytes (64-bit int)
  #
  method !enc_int64 ( Int $i ) {
    # No tests for too large/small numbers because it is called from
    # _enc_element normally where it is checked
    #
    my int $ni = $i;
    return Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF,
                    ($ni +> 0x20) +& 0xFF, ($ni +> 0x28) +& 0xFF,
                    ($ni +> 0x30) +& 0xFF, ($ni +> 0x38) +& 0xFF
                  );

# Original method goes wrong on negative numbers. Also modulo operations are
# slower than the bit operations.
#
#return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100,
#                $i +> 0x18 % 0x100, $i +> 0x20 % 0x100,
#                $i +> 0x28 % 0x100, $i +> 0x30 % 0x100,
#                $i +> 0x38 % 0x100
#              );
  }

  #-----------------------------------------------------------------------------
  # Basic decoding functions
  #
  # Decode code, key and data
  #
  method decode( Array $b ) {
    self.decode_code($b);
    self.decode_key($b);
    $!key_data = self.decode_obj($b);
  }

  # Abstract method to decode a binary buffer to internal data.
  #
  method decode_obj( Array $b --> Any ) { ... }

  # The code must be the first octet in the buffer
  #
  method decode_code ( Array $b ) {

    $!bson_code = $b.shift;
    # Test proper range...
  }

  method decode_key ( Array $b ) {

#    $!key_name = self!dec_e_name( $b );
    $!key_name = self!dec_cstring( $b );
  }

  method !dec_e_name ( Array $b ) {

    return self!dec_cstring( $b );
  }

  method !dec_cstring ( Array $b ) {
    my @b;
    while $b[ 0 ] !~~ 0x00 {
      @b.push( $b.shift );
    }

    die 'Parse error' unless $b.shift ~~ 0x00;
    return Buf.new( @b ).decode();
  }

  # string ::= int32 (byte*) "\x00"
  #
  method !dec_string ( Array $a ) {

    my $i = self!dec_int32( $a );

    my @a;
    @a.push( $a.shift ) for ^ ( $i - 1 );

    die 'Parse error' unless $a.shift ~~ 0x00;

    return Buf.new( @a ).decode( );
  }

  method !dec_int32 ( Array $a --> Int ) {
    my int $ni = $a.shift +| $a.shift +< 0x08 +|
                 $a.shift +< 0x10 +| $a.shift +< 0x18
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

# Original method goes wrong on negative numbers. Also adding might be slower
# than the bit operations. 
# return [+] $a.shift, $a.shift +< 0x08, $a.shift +< 0x10, $a.shift +< 0x18;
  }

  # 8 bytes (64-bit int)
  #
  method !dec_int64 ( Array $a ) {
    my int $ni = $a.shift +| $a.shift +< 0x08 +|
                 $a.shift +< 0x10 +| $a.shift +< 0x18 +|
                 $a.shift +< 0x20 +| $a.shift +< 0x28 +|
                 $a.shift +< 0x30 +| $a.shift +< 0x38
                 ;
    return $ni;

# Original method goes wrong on negative numbers. Also adding might be slower
# than the bit operations. 
#return [+] $a.shift, $a.shift +< 0x08, $a.shift +< 0x10, $a.shift +< 0x18
#         , $a.shift +< 0x20, $a.shift +< 0x28, $a.shift +< 0x30
#         , $a.shift +< 0x38
#         ;
  }
}

