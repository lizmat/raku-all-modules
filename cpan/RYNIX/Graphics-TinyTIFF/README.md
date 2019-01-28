NAME
====

Graphics::TinyTIFF - Perl6 bindings to [a slightly modified] TinyTIFF

DEPENDANCIES
============

## Unix
```
git clone https://github.com/ryn1x/TinyTIFF.git
cd TinyTIFF
mkdir build
cd build
cmake ..
make
sudo make install
```

## Windows
```
git clone https://github.com/ryn1x/TinyTIFF.git
cd TinyTIFF
mkdir build
cd build
cmake ..
cmake -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE -DBUILD_SHARED_LIBS=TRUE -G "Visual Studio 15 2017 win64" ..
build generated ".sln" file with visual studio
```

INSTALL
======

zef install Graphics::TinyTIFF


SYNOPSIS
========

```
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
```

Output:
```
frames            -> 1
bits              -> 8
width             -> 191
height            -> 159
description       -> image description
format            -> 1
samples per pixel -> 1
has next?         -> False
success?          -> True
was error?        -> False
description size  -> 1024
sample data       -> 118 116 112 ...
```

SUBROUTINES
========

### sub TinyTIFFReader_open

```perl6
sub TinyTIFFReader_open(
    str $filename
) returns NativeCall::Types::Pointer
```

open tiff file for reading, returns tiff pointer

### sub TinyTIFFReader_getSampleData

```perl6
sub TinyTIFFReader_getSampleData(
    NativeCall::Types::Pointer $tiff,
    NativeCall::Types::CArray $sample-data is rw,
    uint16 $sample
) returns int32
```

read data from current frame into supplied buffer

### sub TinyTIFFReader_close

```perl6
sub TinyTIFFReader_close(
    NativeCall::Types::Pointer $tiff
) returns Mu
```

close the tiff file

### sub TinyTIFFReader_getBitsPerSample

```perl6
sub TinyTIFFReader_getBitsPerSample(
    NativeCall::Types::Pointer $tiff,
    int32 $sample
) returns uint16
```

return bits per sample of current frame

### sub TinyTIFFReader_getWidth

```perl6
sub TinyTIFFReader_getWidth(
    NativeCall::Types::Pointer $tiff
) returns uint32
```

return width of current frame

### sub TinyTIFFReader_getHeight

```perl6
sub TinyTIFFReader_getHeight(
    NativeCall::Types::Pointer $tiff
) returns uint32
```

return height of current frame

### sub TinyTIFFReader_countFrames

```perl6
sub TinyTIFFReader_countFrames(
    NativeCall::Types::Pointer $tiff
) returns uint32
```

return number of frames

### sub TinyTIFFReader_getSampleFormat

```perl6
sub TinyTIFFReader_getSampleFormat(
    NativeCall::Types::Pointer $tiff
) returns uint16
```

return sample format of current frame

### sub TinyTIFFReader_getSamplesPerPixel

```perl6
sub TinyTIFFReader_getSamplesPerPixel(
    NativeCall::Types::Pointer $tiff
) returns uint16
```

return samples per pixel of current frame

### sub TinyTIFFReader_getImageDescription

```perl6
sub TinyTIFFReader_getImageDescription(
    NativeCall::Types::Pointer $tiff
) returns str
```

return image descrition of current frame

### sub TinyTIFFReader_hasNext

```perl6
sub TinyTIFFReader_hasNext(
    NativeCall::Types::Pointer $tiff
) returns int32
```

retun non-zero if another frame exists

### sub TinyTIFFReader_readNext

```perl6
sub TinyTIFFReader_readNext(
    NativeCall::Types::Pointer $tiff
) returns int32
```

read the next frame from a multi-frame tiff

### sub TinyTIFFReader_success

```perl6
sub TinyTIFFReader_success(
    NativeCall::Types::Pointer $tiff
) returns int32
```

return non-zero if no error in last function call

### sub TinyTIFFReader_wasError

```perl6
sub TinyTIFFReader_wasError(
    NativeCall::Types::Pointer $tiff
) returns int32
```

return non-zero if error in last function call

### sub TinyTIFFReader_getLastError

```perl6
sub TinyTIFFReader_getLastError(
    NativeCall::Types::Pointer $tiff
) returns str
```

return last error message

### sub TinyTIFFWriter_open

```perl6
sub TinyTIFFWriter_open(
    str $filename,
    uint16 $bits-per-sample,
    uint32 $width,
    uint32 $height
) returns NativeCall::Types::Pointer
```

create a new tiff file, returns tiff-file pointer

### sub TinyTIFFWriter_getMaxDescriptionTextSize

```perl6
sub TinyTIFFWriter_getMaxDescriptionTextSize() returns int32
```

get max size for image descrition

### sub TinyTIFFWriter_writeImageDouble

```perl6
sub TinyTIFFWriter_writeImageDouble(
    NativeCall::Types::Pointer $tiff-file,
    NativeCall::Types::CArray $sample-data is rw
) returns Mu
```

writes row-major image data to a tiff file

### sub TinyTIFFWriter_writeImageFloat

```perl6
sub TinyTIFFWriter_writeImageFloat(
    NativeCall::Types::Pointer $tiff-file,
    NativeCall::Types::CArray $sample-data is rw
) returns Mu
```

writes row-major image data to a tiff file

### sub TinyTIFFWriter_writeImageVoid

```perl6
sub TinyTIFFWriter_writeImageVoid(
    NativeCall::Types::Pointer $tiff-file,
    NativeCall::Types::CArray $sample-data is rw
) returns Mu
```

writes row-major image data to a tiff file

### sub TinyTIFFWriter_close

```perl6
sub TinyTIFFWriter_close(
    NativeCall::Types::Pointer $tiff-file,
    str $image-description
) returns Mu
```

close the tiff and write image description to first frame

COPYRIGHT AND LICENSE
=====================

Copyright 2018 ryn1x

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

