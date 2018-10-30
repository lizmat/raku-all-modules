use v6;
use Test;

plan 7;

use Compress::Zlib::Raw;
use NativeCall;

ok True, 'Compiled';
my $version;
ok (($version = zlibVersion) ~~ /^1/), 'Got zlib version ('~$version~')';

my $to-compress = "test".encode;

my $return-buf-len = CArray[long].new;
$return-buf-len[0] = 128;

my $return-buf = buf8.new;
$return-buf[127] = 0;

is compress($return-buf, $return-buf-len, $to-compress, 4), Compress::Zlib::Raw::Z_OK, 'Compressed data';

ok ($to-compress[0] != $return-buf[0]), 'Compressed data is different than input';

my $orig-buf = buf8.new;
$orig-buf[127] = 1;

my $orig-size = CArray[long].new;
$orig-size[0] = 128;

is uncompress($orig-buf, $orig-size, $return-buf, $return-buf-len[0]), Compress::Zlib::Raw::Z_OK, 'Uncompressed data';

is $orig-size[0], 4, 'Got correct original data size...';
ok $orig-buf.subbuf(0, 4).decode eq 'test', '...And got the right data!';
