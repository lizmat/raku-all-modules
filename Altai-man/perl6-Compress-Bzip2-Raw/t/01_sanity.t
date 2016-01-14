use v6;
use Test;
use NativeCall;
use Compress::Bzip2::Raw;
plan *;

my int32 $bzerror;
my $text = "Text string.";
my Blob $blob_text = $text.encode("UTF-8");
my $size = $blob_text.elems;
my $write_array = CArray[uint8].new;
$write_array[$_] = $blob_text[$_] for ^$size;

## Writing.
# Open.
my $handle = fopen("/tmp/test.bz2", "wb");
my $bz = bzWriteOpen($bzerror, $handle);
ok $bzerror == BZ_OK, 'Stream was opened.';
if $bzerror != BZ_OK { bzWriteClose($bzerror, $bz) };

# Writing.
BZ2_bzWrite($bzerror, $bz, $write_array, $size);
ok $bzerror == BZ_OK, 'No errors in writing.';
if $bzerror == BZ_IO_ERROR { bzWriteClose($bzerror, $bz) }

# Closing.
bzWriteClose($bzerror, $bz);
ok $bzerror == BZ_OK, 'Stream was closed properly.';
close($handle);

## Reading.
# Opening.
$handle = fopen("/tmp/test.bz2", "rb");
$bz = BZ2_bzReadOpen($bzerror, $handle, 0, 0, $null, 0);
ok $bzerror == BZ_OK, 'Stream was opened.';
if $bzerror != BZ_OK { BZ2_bzReadClose($bzerror, $bz) }

# Reading.
my $read_array = CArray[uint8].new;
$read_array[$size] = 0;

my $len = BZ2_bzRead($bzerror, $bz, $read_array, $size);
ok $bzerror == BZ_STREAM_END, 'No errors at reading';

my Buf $read_buffer = Buf.new;
$read_buffer[$_] = $read_array[$_] for ^$len;
my $decoded_text = $read_buffer.decode("UTF-8");
is $decoded_text, $text, 'Text is correct.';

# Closing.
BZ2_bzReadClose($bzerror, $bz);
ok $bzerror == BZ_OK, 'Stream was closed properly.';
close($handle);

done-testing;
