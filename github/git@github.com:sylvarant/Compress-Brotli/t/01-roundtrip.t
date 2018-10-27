use v6;
use Test;
use lib 'lib';
use Compress::Brotli;

plan 7;

# basic roundtrip
my $simple = "test data ";
my Buf $blob = compress($simple);
ok 1, "compress executed";
my Buf $buffer = decompress($blob);
my Str $res = decode_str($buffer);
ok 1, "decompress executed";
is $res,$simple,"Succesfully roundtripped small test data";

# Testing compression of large input
my $large = (map { (roll 10, "0".."z") } ,^1000).join(" ");
$blob = compress($large);
my $size = $blob.bytes();
ok ($size < $large.chars()), "compressed string is smaller";
$buffer = decompress($blob);
$res = decode_str($buffer);
is $res,$large,"Succesfully roundtripped large test data";

# try a low quality compression
$blob = compress($large,Config.new(:mode(1),:quality(1),:lgwin(10),:lgblock(0)));
ok ($size < $blob.bytes()), "low quality compression is larger";
$buffer = decompress($blob);
$res = decode_str($buffer);
is $res,$large,"Succesfully roundtripped low quality roundtrip";

