use v6;
use Test;

plan 7;

use Compress::Zlib::Raw;
use NativeCall;

ok True, 'Compiled';
my $version;
ok (($version = zlibVersion) ~~ /^1/), 'Got zlib version ('~$version~')';

my $to-compress = CArray[int8].new;
$to-compress[0] = 97;
$to-compress[1] = 115;
$to-compress[2] = 100;
$to-compress[3] = 102;

my $return-buf-len = CArray[int].new;
$return-buf-len[0] = 128;

my $return-buf = CArray[int8].new;
# How do I set the length of the CArray directly?
$return-buf[127] = 1;

is compress($return-buf, $return-buf-len, $to-compress, 4), Compress::Zlib::Raw::Z_OK, 'Compressed data';

ok ($to-compress[0] != $return-buf[0]), 'Compressed data is different than input';

my $orig-buf = CArray[int8].new;
$orig-buf[127] = 1;

my $orig-size = CArray[int].new;
$orig-size[0] = 128;

is uncompress($orig-buf, $orig-size, $return-buf, $return-buf-len[0]), Compress::Zlib::Raw::Z_OK, 'Uncompressed data';

is $orig-size[0], 4, 'Got correct original data size...';
ok $orig-buf[0] == 97 && $orig-buf[1] == 115 && $orig-buf[2] == 100 && $orig-buf[3] == 102, '...And got the right data!';
