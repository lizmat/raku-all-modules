use v6;
use NativeCall;

unit module Compress::Bzip2::Raw;

# structs and pointers.
our $null is export = Pointer[uint32].new(0);

our class bz_stream is repr('CStruct') is export {
    has CArray[uint8] $.next-in;
    has int32 $.avail-in;
    has int32 $.total-in_lo32;
    has int32 $.total-in_hi32;

    has CArray[uint8] $.next-out;
    has int32 $.avail-out;
    has int32 $.total-out-lo32;
    has int32 $.total-out-hi32;

    has Pointer[void] $.state;

    has Pointer[void] $.bzalloc is rw;
    has Pointer[void] $.bzfree is rw;
    has Pointer[void] $.opaque is rw;

    method set-input(Blob $stuff){
        $!next-in := nativecast CArray[uint8], $stuff;
        $!avail-in = $stuff.bytes;
    }

    method set-output(Blob $stuff){
        $!next-out := nativecast CArray[uint8], $stuff;
        $!avail-out = $stuff.bytes;
    }
}

# constants
constant BZ_RUN is export = 0;
constant BZ_FLUSH is export = 1;
constant BZ_FINISH is export = 2;

constant BZ_OK is export = 0;
constant BZ_RUN_OK is export = 1;
constant BZ_FLUSH_OK is export = 2;
constant BZ_FINISH_OK is export = 3;
constant BZ_STREAM_END is export = 4;
# Errors.
constant BZ_SEQUENCE_ERROR is export = (-1);
constant BZ_PARAM_ERROR is export = (-2);
constant BZ_MEM_ERROR is export = (-3);
constant BZ_DATA_ERROR is export = (-4);
constant BZ_DATA_ERROR_MAGIC is export = (-5);
constant BZ_IO_ERROR is export = (-6);
constant BZ_UNEXPECTED_EOF is export = (-7);
constant BZ_OUTBUFF_FULL is export = (-8);
constant BZ_CONFIG_ERROR is export = (-9);

## Low-level.
# Compress.
our sub BZ2_bzCompressInit(bz_stream, int32, int32, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzCompress(bz_stream, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzCompressEnd(bz_stream) returns int32 is native("bz2", v1) is export { * }
# Decompress.
our sub BZ2_bzDecompressInit(bz_stream, int32, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzDecompress(bz_stream) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzDecompressEnd(bz_stream) returns int32 is native("bz2", v1) is export { * }

## High-level.
# Reading.
our sub BZ2_bzReadOpen(int32 is rw, OpaquePointer, int32, int32, Pointer[uint8], int32) returns OpaquePointer is native("bz2", v1) { * }
our sub bzReadOpen(int32 $bzerror is rw, OpaquePointer $file, $verbosity=0, $small=0, $unused=$null, $nUnused=0) is export {
    BZ2_bzReadOpen($bzerror, $file, $verbosity, $small, $unused, $nUnused);
}
our sub BZ2_bzRead(int32 is rw, OpaquePointer, Blob, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzReadClose(int32 is rw, Pointer[void]) is native("bz2", v1) is export { * }
our sub BZ2_bzReadGetUnused(int32 is rw, Pointer[void], Pointer, int32 is rw) is native("bz2", v1) is export { * }
# Writing.
our sub BZ2_bzWriteOpen(int32 is rw, OpaquePointer, int32, int32, int32) returns OpaquePointer is native("bz2", v1) { * }
our sub bzWriteOpen(int32 $bzerror is rw, OpaquePointer $file, $blockSize100k=6, $verbosity=0, $workFactor=0) is export {
    BZ2_bzWriteOpen($bzerror, $file, $blockSize100k, $verbosity, $workFactor);
}
our sub BZ2_bzWrite(int32 is rw, OpaquePointer, Blob, int32) is native("bz2", v1) is export { * }
our sub BZ2_bzWriteClose(int32 is rw, Pointer, int32, Pointer[uint32], Pointer[uint32]) is native("bz2", v1) { * }
our sub bzWriteClose(int32 $bzerror is rw, OpaquePointer $bz, $abandon=0, $nbytes_in=$null, $nbytes_out=$null) is export {
    BZ2_bzWriteClose($bzerror, $bz, $abandon, $nbytes_in, $nbytes_out);
}
our sub BZ2_bzWriteClose64(int32 is rw, OpaquePointer, int32, Pointer[uint32], Pointer[uint32], Pointer[uint32], Pointer[uint32]) is native("bz2", v1) is export { * }

## Utility.
our sub BZ2_bzBuffToBuffCompress(Blob, uint32 is rw, Blob, uint32, int32, int32, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzBuffToBuffDecompress(Blob, uint32 is rw, Blob, uint32, int32, int32) returns int32 is native("bz2", v1) is export { * }
our sub fopen(Str $filename, Str $mode) returns OpaquePointer is native() is export { * }
our sub close(OpaquePointer $handle) is native() is export { * }

# High-level helpers.
our sub name-to-compress-info(Str $filename) is export {
    # TODO: docs. This function provides all needed data to compress file.
    my $handle = fopen($filename ~ ".bz2", "wb");
    my $blob = slurp $filename, :bin;
    my $len = $blob.elems;
    my @array = ($handle, $blob, $len);
}

our sub name-to-decompress-info(Str $filename) is export {
    my $handle = fopen($filename, "rb");
    my Str $output = ($filename ~~ m/(.+).bz2/)[0].Str;
    my $fd = open $output, :w, :bin;
    my @array = ($handle, $fd);
}
