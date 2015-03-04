use v6;
use Test;
use BSON::Decoder;

#-------------------------------------------------------------------------------
#
my BSON::Decoder $d1 .= new;
#say "d1: {$d1.^name}, $d1";
#say "d1: {$d1.perl}";
#say "d1: ", $d1.^methods;

#-------------------------------------------------------------------------------
#
my Array $b0 = [ 0xA2,                                  # Unknown code
                 0x74, 0x73, 0x74, 0x00                 # 'tst' + 0
               ];
if 1 {
  $d1.decode($b0);
  CATCH {
    my $type = .type;
    my $msg = .emsg;

    when X::BSON::Decoding {
      ok $type ~~ m/ Unknown \( 0xA2 \) /, $type;
      ok $msg ~~ ms/ Not \(yet\) implemented/, $msg;
    }
  }
}

#-------------------------------------------------------------------------------
#
my Array $b1 = [ 0x01,                                  # Double
                 0x62, 0x63, 0x64, 0x00,                # 'bcd' + 0
                 0x55, 0x55, 0x55, 0x55,                # 8 byte double
                 0x55, 0x55, 0xD5, 0x3F
               ];
$d1.decode($b1);

is( $d1.code, $BSON::Decoder::DOUBLE, 'BSON type: Double');
is( $d1.value.^name, 'Num', 'Perl type: Num');
is_approx( $d1.value, 0.3333333, "Value: {$d1.value}");

#-------------------------------------------------------------------------------
#
my Array $b2 = [ 0x02,                                  # String
                 0x61, 0x00,                            # 'a' + 0
                 0x0C, 0x00, 0x00, 0x00,                # Length + 1
                 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20,    # 'hello world' + 0
                 0x77, 0x6F, 0x72, 0x6C, 0x64, 0x00
               ];
$d1.decode($b2);

is( $d1.code, $BSON::Decoder::STRING, 'BSON type: String');
is( $d1.value.^name, 'Str', 'Perl type: Str');
is( $d1.value, 'hello world', "Value: {$d1.value}");

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
