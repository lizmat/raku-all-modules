use v6.c;
use Test;
use NativeCall;
use Graphics::TinyTIFF;

my $dir = $?FILE.IO.dirname;
my $in = $dir.IO.add('cell.tif').Str;
my $out = $dir.IO.add('cell2.tif').Str;
my $tiff-r;
my $tiff-w;
my $width;
my $height;
my $size;
my $bits;
my $sample-data;

plan 20;

lives-ok { $tiff-r = TinyTIFFReader_open($in) };
lives-ok { TinyTIFFReader_countFrames($tiff-r) };
lives-ok { $bits = TinyTIFFReader_getBitsPerSample($tiff-r, 0) };
lives-ok { $width = TinyTIFFReader_getWidth($tiff-r) };
lives-ok { $height = TinyTIFFReader_getHeight($tiff-r) };
lives-ok { TinyTIFFReader_getImageDescription($tiff-r) };
lives-ok { TinyTIFFReader_getLastError($tiff-r) };

$size = $width * $height;
$sample-data := CArray[uint8].allocate($size);

lives-ok { TinyTIFFReader_getSampleData($tiff-r, $sample-data, 0) };
lives-ok { TinyTIFFReader_getSampleFormat($tiff-r) };
lives-ok { TinyTIFFReader_getSamplesPerPixel($tiff-r) };
lives-ok { TinyTIFFReader_getWidth($tiff-r) };
lives-ok { TinyTIFFReader_hasNext($tiff-r) };
lives-ok { TinyTIFFReader_success($tiff-r) };
lives-ok { TinyTIFFReader_wasError($tiff-r) };
lives-ok { TinyTIFFReader_readNext($tiff-r) };
lives-ok { TinyTIFFReader_close($tiff-r) };

lives-ok { $tiff-w = TinyTIFFWriter_open($out, $bits, $width, $height) };
lives-ok { TinyTIFFWriter_getMaxDescriptionTextSize() };
lives-ok { TinyTIFFWriter_writeImageVoid( $tiff-w, $sample-data) };
lives-ok { TinyTIFFWriter_close( $tiff-w, 'test') };
