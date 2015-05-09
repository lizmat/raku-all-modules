use v6;
use Test;
use BSON::Encodable;
use BSON::Double;

#-------------------------------------------------------------------------------
# Forgotten code test, skipped, captured at compile time
#
if 1 {
  class MyThing0 does BSON::Encodable {
    submethod BUILD ( Str :$key_name, Int :$key_data ) {
      self.init( :$key_name, :$key_data);
    }

    method encode_obj( $data --> Buf ) { }
    method decode_obj( List $b ) { }
  }

  my MyThing0 $m0 .= new( :key_name('t'), :key_data(10));

  CATCH {
    when X::BSON::Encodable {
      my $emsg = $_.emsg;
      $emsg ~~ s:g/\n+//;

      ok $_.type ~~ m/MyThing0/, 'MyThing0 is a thrown object';
      is $emsg,
         "Code undefined out of bounds or not defined, must be positive 8 bit int",
         "Code undefined";
    }
  }
}
#-------------------------------------------------------------------------------
# Code too large test
#
if 1 {
  class MyThing1 does BSON::Encodable {
    submethod BUILD ( Str :$key_name, Int :$key_data ) {
      self.init( :bson_code(0x1FF), :$key_name, :$key_data);
    }

    method encode_obj( $data --> Buf ) { }
    method decode_obj( List $b ) { }
  }

  my MyThing1 $m1 .= new( :key_name('t'), :key_data(10));

  CATCH {
    when X::BSON::Encodable {
      my $emsg = $_.emsg;
      $emsg ~~ s:g/\n+//;

      ok $_.type ~~ m/MyThing1/, 'MyThing1 is a thrown object';
      is $emsg,
         "Code 511 out of bounds or not defined, must be positive 8 bit int",
         "Code 0x1FF too big";
    }
  }
}

#-------------------------------------------------------------------------------
# Role to encode to and/or decode from a BSON representation from a Thing.
# 
class MyThing2 does BSON::Encodable {

  submethod BUILD ( Str :$key_name, Int :$key_data ) {
    self.init( :bson_code(0xA1), :$key_name, :$key_data);
  }

  method encode_obj( $data --> Buf ) {
    return self!enc_int32($!key_data);
  }

  # Decode a binary buffer to internal data.
  #
  method decode_obj( List $b --> Any ) {
    return self!dec_int32($b.list);
  }
}


my MyThing2 $m .= new( :key_name('test'), :key_data(10));

isa_ok $m, 'MyThing2', 'Is a thing 2';
ok $m.^does(BSON::Encodable), 'Does BSON::Encodable role';

my Buf $bdata = $m.encode();
#say "Bdata: ", $bdata;

is_deeply $bdata,
          Buf.new( 0xA1,                                # MyThing2 BSON code
                   0x74, 0x65, 0x73, 0x74, 0x00,        # 'test' + 0
                   0x0A, 0x00 xx 3,                     # 32 bit integer
                 ),
          'encoding 10';

my MyThing2 $m2 .= new;
$m2.decode($bdata.list);
is $m2.key_data, $m.key_data, 'Compare item after encode decode';


#-------------------------------------------------------------------------------
# Test BSON::Double.
#
my BSON::Double $double .= new( :key_name('var1'));

my Buf $b = Buf.new( 0x01,                              # Double
                     0x74, 0x65, 0x73, 0x74, 0x00,      # 'test' + 0
                     0x55, 0x55, 0x55, 0x55,            # 8 byte floating point
                     0x55, 0x55, 0xD5, 0x3F
                   );
my Num $r1 = $double.decode($b.list);
#say "R: $r1";
is $r1, Num(1/3), "Decoded 1/3";
$double.key_data = $r1;
my Buf $r2 = $double.encode;
is_deeply $b, $r2, 'Bufs compare';

#say "R1/2: $r1, ", $r2;

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
