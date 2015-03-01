use Test;
#use BSON;
use BSON::Encodable;

#-------------------------------------------------------------------------------
# 
#my BSON $bson .= new;

#-------------------------------------------------------------------------------
# Role to encode to and/or decode from a BSON representation from a Thing.
# 
class MyThing1 does BSON::Encodable {

#  $bson_code = 0x01;
#say "MT1: $bson_code";
  $BSON::Encodable::bson_code = 0x01;

  method encode( --> Buf ) {
      return [~] self._encode_code,
                 self._encode_key,
                 self._enc_int32($!key_data);
  }

  # Decode a binary buffer to internal data.
  #
  method decode( List $b ) {
      self._decode_code($b);
      self._decode_key($b);
      $!key_data = self._dec_int32($b.list);
  }
}

if 1 {
  class MyThing2 does BSON::Encodable {
    $BSON::Encodable::bson_code = 0x01FF;
    method encode( --> Buf ) { }
    method decode( List $b ) { }
  }

  my MyThing1 $m0 .= new( :key_name('t'), :key_data(10));
  CATCH {
    when X::BSON::Encodable {
      my $emsg = $_.emsg;
      $emsg ~~ s:g/\n+//;

      ok $_.type ~~ m/MyThing1/, 'Thrown object';
      is $emsg, "Code 511 out of bounds, must be positive 8 bit int", $emsg;
    }
  }
}

my MyThing1 $m .= new( :bson_code(0x01), :key_name('test'), :key_data(10));

isa_ok $m, 'MyThing1', 'Is a thing';
#ok $m.^does(BSON::Encodable), 'Does BSON::Encodable role';

#`{{
my Buf $bdata = $m.encode();
is_deeply $bdata,
          Buf.new( 0x01,                                # BSON code
                   0x74, 0x65, 0x73, 0x74, 0x00,        # 'test' + 0
                   0x0A, 0x00 xx 3,                     # 32 bit integer
                 ),
          'encoding 10';

my MyThing1 $m2 .= new;
$m2.decode($bdata.list);
is $m2.key_data, $m.key_data, 'Compare item after encode decode';
}}

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
