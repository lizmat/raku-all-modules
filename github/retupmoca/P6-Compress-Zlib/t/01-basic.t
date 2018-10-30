use v6;
use Test;

plan 5;

use Compress::Zlib;

ok True, 'Compiled';

my $data = compress("asdf".encode('utf8'));

ok $data ~~ Buf, 'Compression success';

my $result = uncompress($data).decode('utf8');

is $result, "asdf", 'Uncompression success';

$data = compress("asdf".encode('utf8'), 9);

ok $data ~~ Buf, 'Compression with custom level success';

$result = uncompress($data).decode('utf8');

is $result, "asdf", 'Uncompression success';
