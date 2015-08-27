use v6;
use Test;

use BSON::EDCTools;

#-------------------------------------------------------------------------------
my $index;

#-------------------------------------------------------------------------------
# int32 decoding
#
$index = 0;
my Buf $b = Buf.new( 0x00 xx 4 );
my Int $v = decode_int32( $b.list, $index);
is( $v, 0, 'int32: dec N = 0');

$index = 0;
$b = Buf.new( 0xFF xx 4 );
$v = decode_int32( $b.list, $index);
is( $v, -1, 'int32: dec N = -1');

$index = 0;
$b = Buf.new( 0xFE, 0xFF xx 3 );
$v = decode_int32( $b.list, $index);
is( $v, -2, 'int32: dec N = -2');

$index = 0;
$b = Buf.new( 0xfc, 0x4c, 0x01, 0x00);
$v = decode_int32( $b.list, $index);
is( $v, 85244, 'int32: dec N = 85244');

$index = 0;
$b = Buf.new( 0x01, 0x00, 0x00, 0xff);
$v = decode_int32( $b.list, $index);
is( $v, -16777215, 'int32: dec N = -16777215');

#-------------------------------------------------------------------------------
# int32 decoding too short length
#
if 1 {
  $index = 0;
  $b = Buf.new(0x00 xx 3);
  $v = decode_int32( $b.list, $index);
  
  CATCH {
    my $msg = .message;
    $msg ~~ s:g/\n//;
    when X::BSON::Parse {
      ok .message ~~ m/'Not enaugh characters left'/, $msg;
    }
  }
}

#-------------------------------------------------------------------------------
# int32 encoding
#
$b = encode_int32(-1);
is-deeply( $b, Buf.new( 0xff, 0xff, 0xff, 0xff), 'int32: enc -1');

$b = encode_int32(-2);
is-deeply( $b, Buf.new( 0xfe, 0xff, 0xff, 0xff), 'int32: enc -2');

$b = encode_int32(-16777215);
is-deeply( $b, Buf.new( 0x01, 0x00, 0x00, 0xff), 'int32: enc -16777215');

$b = encode_int32(2147483647);
is-deeply( $b, Buf.new( 0xff xx 3, 0x7f), 'int32: enc 2147483647');

#-------------------------------------------------------------------------------
# int64 decoding
# 
$index = 0;
$b = Buf.new( 0x00 xx 8 );
$v = decode_int64( $b.list, $index);
is( $v, 0, 'int64: dec N = 0');

$index = 0;
$b = Buf.new( 0xFF xx 8 );
$v = decode_int64( $b.list, $index);
is( $v, -1, 'int64: dec N = -1');

$index = 0;
$b = Buf.new( 0xFE, 0xFF xx 7 );
$v = decode_int64( $b.list, $index);
is( $v, -2, 'int64: dec N = -2');

$index = 0;
$b = Buf.new( 0xfc, 0x4c, 0x01, 0x00 xx 5);
$v = decode_int64( $b.list, $index);
is( $v, 85244, 'int64: dec N = 85244');

$index = 0;
$b = Buf.new( 0x01, 0x00 xx 6, 0xff);
$v = decode_int64( $b.list, $index);
my int $i = 1 + 0xff * 2**56;
is( $v, $i, "int64: dec N = $i");

#-------------------------------------------------------------------------------
# int64 decoding too short length
#
if 1 {
  $index = 0;
  $b = Buf.new(0x00 xx 3);
  $v = decode_int64( $b.list, $index);
  
  CATCH {
    my $msg = .message;
    $msg ~~ s:g/\n//;
    when X::BSON::Parse {
      ok .message ~~ m/'Not enaugh characters left'/, $msg;
    }
  }
}

#-------------------------------------------------------------------------------
# int64 encoding
#
$b = encode_int64(-1);
is-deeply( $b, Buf.new( 0xff xx 8 ), 'int64: enc -1');

$b = encode_int64(-2);
is-deeply( $b, Buf.new( 0xfe, 0xff xx 7), 'int64: enc -2');

$i = 1 + 0xff * 2**56;
$b = encode_int64($i);
is-deeply( $b, Buf.new( 0x01, 0x00 xx 6, 0xff), "int64: enc $i");

$i = 1 * 2**63 - 1;
$b = encode_int64($i);
is-deeply( $b, Buf.new( 0xff xx 7, 0x7f), "int64: enc $i");

#-------------------------------------------------------------------------------
# Number too large encoding
#
$b = encode_int64(0x7fffffff_ffffffff + 1);
is-deeply( $b, Buf.new( 0x00 xx 7, 0x80 ), 'int64: enc too large becomes negative');

$index = 0;
$i = 1 * 2**63;
$v = decode_int64( $b.list, $index);
is( $v, $i, "int64: dec N = $i");

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);
