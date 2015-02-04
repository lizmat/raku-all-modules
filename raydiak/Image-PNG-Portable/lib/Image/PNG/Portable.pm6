class Image::PNG::Portable;

use String::CRC32;
need Compress::Zlib::Raw;
use NativeCall;

#`[[[
https://rt.perl.org/Public/Bug/Display.html?id=123700
subset UInt of Int where * >= 0;
subset PInt of Int where * > 0;
subset UInt8 of Int where 0 <= * <= 255;
subset NEStr of Str where *.chars;
]]]

has Int $.width = die 'Width is required';
has Int $.height = die 'Height is required';

# + 1 allows filter bytes in the raw data, avoiding needless buf manip later
has $!line-bytes = $!width * 3 + 1;
has $!data-bytes = $!line-bytes * $!height;
has $!data-pointer = memset malloc($!data-bytes), 0, $!data-bytes;
has $!data = nativecast CArray[uint8], $!data-pointer;
has $!freed = False;

# magic string for PNGs
my $magic = Blob.new: 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A;

method set (
    Int $x where * < $!width,
    Int $y where * < $!height,
    Int $r, Int $g, Int $b
) {
    my $buffer = $!data;
    # + 1 skips aforementioned filter byte
    my $index = $!line-bytes * $y + 3 * $x + 1;

    $buffer[$index++] = $r;
    $buffer[$index++] = $g;
    $buffer[$index] = $b;

    True;
}

method write (Str $file) {
    my $fh = $file.IO.open(:w, :bin);

    $fh.write: $magic;

    $fh.write: chunk 'IHDR', bytes($!width, 4), bytes($!height, 4),
        8, 2, 0, 0, 0; # w, h, bpp, color, compress, filter, interlace

    # would love to skip compression for my purposes, but PNG mandates it
    my $zdata = compress $!data, $!data-bytes;
    $fh.write: chunk 'IDAT', @$zdata;

    $fh.write: chunk 'IEND';

    $fh.close;

    True;
}

method free () {
    return True if $!freed;

    $!data = Any;
    free $!data-pointer;

    $!freed = True;

    True;
}

submethod DESTROY () {
    self.free;
}

# creates a chunk
sub chunk (Str $type, *@data) {
    my @length = bytes @data.elems, 4;

    my @type := $type.encode;
    my @td := Blob[uint8].new: |@type, |@data;
    my @crc = bytes String::CRC32::crc32 @td;

    Blob[uint8].new: |@length, |@td, |@crc;
}

# converts a number to a list of byte values with optional fixed width
sub bytes (Int $n is copy, Int $count = 0) {
    my @return;

    my $exp = 1;
    $exp++ while 256 ** $exp <= $n;

    if $count {
        my $diff = $exp - $count;
        die 'Overflow' if $diff > 0;
        @return.push(0 xx -$diff) if $diff < 0;
    }

    while $exp {
        my $scale = 256 ** --$exp;
        my $value = $n div $scale;
        @return.push: $value;
        $n -= $value * $scale;
    }

    @return;
}

# https://github.com/retupmoca/P6-Compress-Zlib/blob/master/lib/Compress/Zlib.pm6
# forked to receive a CArray directly, yielding a massive performance increase
sub compress(CArray $indata, Int $inlen, Int $level = 6 --> Buf) is export {
    if $level < -1 || $level > 9 {
        die "compression level must be between -1 and 9";
    }

    my $outlen = CArray[int].new();
    $outlen[0] = Compress::Zlib::Raw::compressBound($inlen);
    my $outdata = CArray[int8].new();
    $outdata[$outlen[0] - 1] = 1;

    Compress::Zlib::Raw::compress2($outdata, $outlen, $indata, $inlen, $level);

    my $len = $outlen[0];
    my @out;
    for 0..^$len {
        @out[$_] = $outdata[$_];
    }
    return Buf.new(@out);
}

# these bits are needed to create a zero-filled CArray quickly
sub memset ( OpaquePointer $p, int8 $c, int $n )
    returns OpaquePointer is native {*}
sub malloc ( int $n ) returns OpaquePointer is native {*}
sub free ( OpaquePointer $p ) is native {*}


