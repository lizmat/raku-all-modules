use v6;
use Test;

plan 7;

use Compress::Zlib;

my $compressor;
ok $compressor = Compress::Zlib::Stream.new, 'Can create stream object';
my $data;
my $data2;
ok $data = $compressor.deflate('asdf'.encode), 'Get data when a chunk is deflated';
ok $data2 = $compressor.finish, 'Get flushed data on finish';

is uncompress($data ~ $data2).decode, 'asdf', 'Can decompress data';

my $decompressor = Compress::Zlib::Stream.new;
is $decompressor.inflate($data).decode, 'asdf', 'Can inflate chunk';
ok $decompressor.inflate($data2).elems == 0, 'Reading second chunk gives no output';
ok $decompressor.finished, 'Is marked end-of-stream';
