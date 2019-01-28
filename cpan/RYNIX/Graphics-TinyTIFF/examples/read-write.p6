#!/usr/bin/env perl6

use v6.c;
use NativeCall;
use Graphics::TinyTIFF;

########## reader ##########

my $tiff = TinyTIFFReader_open('cell.tif');
my $frames = TinyTIFFReader_countFrames($tiff);
my $bits = TinyTIFFReader_getBitsPerSample($tiff, 0);
my $width = TinyTIFFReader_getWidth($tiff);
my $height = TinyTIFFReader_getHeight($tiff);
my $description = TinyTIFFReader_getImageDescription($tiff);

my $size = $width * $height;
my $sample-data := CArray[uint8].allocate($size);

TinyTIFFReader_getSampleData($tiff, $sample-data, 0);

# you now have $sample-data for the current frame
# and can manipulate it as you wish!

my $format = TinyTIFFReader_getSampleFormat($tiff);
my $samples-per-pixel = TinyTIFFReader_getSamplesPerPixel($tiff);
my $has-next = ?TinyTIFFReader_hasNext($tiff);
TinyTIFFReader_readNext($tiff) if $has-next;
my $success = ?TinyTIFFReader_success($tiff);
my $was-error = ?TinyTIFFReader_wasError($tiff);
my $last-error = TinyTIFFReader_getLastError($tiff) if $was-error;
TinyTIFFReader_close($tiff);

########## writer ##########

my $tiff-file = TinyTIFFWriter_open('cell2.tif', $bits, $width, $height);
my $description-size = TinyTIFFWriter_getMaxDescriptionTextSize();
TinyTIFFWriter_writeImageVoid( $tiff-file, $sample-data);
TinyTIFFWriter_close( $tiff-file, 'test');

print qq:to/END/;
    frames            -> $frames
    bits              -> $bits
    width             -> $width
    height            -> $height
    description       -> $description
    format            -> $format
    samples per pixel -> $samples-per-pixel
    has next?         -> $has-next
    success?          -> $success
    was error?        -> $was-error
    description size  -> $description-size
    sample data       -> $sample-data[^3] ...
    END

