use v6;
use Test;
use Compress::Bzip2;
plan *;

my $test = roll 100, "a" .. "z";
my Str $filename-global = "/tmp/test.txt";
my Str $filename-rel = "./test.txt";

lives-ok { spurt $filename-global, $test }, "Glogal file was written.";
lives-ok { spurt $filename-rel, $test }, "Relative file was written.";
lives-ok { compress($filename-global) }, "Compression was done.";
lives-ok { compress($filename-rel) }, "Compression was done.";
dies-ok { decompress($filename-global) }, "Attempt to read non-.bz file threw an exception.";
dies-ok { decompress($filename-rel) }, "Attempt to read non-.bz file threw an exception.";
lives-ok { decompress($filename-global ~ ".bz2") }, "Decompression is okay.";
lives-ok { decompress($filename-rel ~ ".bz2") }, "Decompression is okay.";
unlink($filename-global);
unlink($filename-rel);
unlink($filename-global ~ ".bz2");
unlink($filename-rel ~ ".bz2");

my buf8 $buf .= new("Some string".encode);
my buf8 $result = compressToBlob($buf);
my $new = decompressToBlob($result).decode;
is "Some string", $new, "Compression and decompression from buf to buf seems normal!";

# Stream compression(will work with stdio, sockets, etc.);
my $cstream = Compress::Bzip2::Stream.new;
my $filename = "/tmp/streamed.bz2";
my $test-string = "Some test string.".encode;
my $buffer = buf8.new;
$buffer ~= $cstream.compress($test-string);
$buffer ~= $cstream.finish();
my $fd = open $filename, :w, :bin;
$fd.write($buffer);
$fd.close();

my $dstream = Compress::Bzip2::Stream.new;
$buffer = buf8.new;
my $data = slurp($filename, :bin);
$buffer ~= $dstream.decompress($data);
is $buffer.decode, "Some test string.", "Streaming decoding is good.";
unlink($filename);

done-testing;
