use v6;
module Compress::Zlib::Raw;

use Inline;
use NativeCall;

my Str $lib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        # we're on windows, different library name
        $lib = 'zlib1';
    } elsif $*VM.config<dll> ~~ /so$/ {
        $lib = 'libz.so.1';
    } else {
        $lib = 'libz';
    }
}

my sub z_stream_sizeof() is inline('C') returns Int {
'
DLLEXPORT int z_stream_sizeof() {
    return sizeof(struct {void* a;int b;long c;void* d;int e;long f;void* g;void* h;void* i;void* j;void* k;int l;long m;long n;});
}
'
}

# structs
our class z_stream is repr('CStruct') is export {
    has CArray $.next-in;
    has int32 $.avail-in;
    has long $.total-in;

    has CArray $.next-out;
    has int32 $.avail-out;
    has long $.total-out;

    has Str $.msg;
    has OpaquePointer $.state;

    has OpaquePointer $.zalloc;
    has OpaquePointer $.zfree;
    has OpaquePointer $.opaque;

    has int32 $.data-type;
    has long $.adler;
    has long $.reserved;

    method set-input(Blob $stuff){
        set_input_buf(self, $stuff);
        $!avail-in = $stuff.bytes;
    }

    method set-output(Blob $stuff){
        set_output_buf(self, $stuff);
        $!avail-out = $stuff.bytes;
    }
};

# XXX Hack since we can't put a Blob into a CStruct
my sub set_input_buf(z_stream $z, Blob $b) is inline('C') {
'
DLLEXPORT void set_input_buf(void* z, void* b) {
    typedef struct {void* a;int b;long c;void* d;int e;long f;void* g;void* h;void* i;void* j;void* k;int l;long m;long n;} zs;
    ((zs*)z)->a = b;
}
'
}
my sub set_output_buf(z_stream $z, Blob $b) is inline('C') {
'
DLLEXPORT void set_output_buf(void* z, void* b) {
    typedef struct {void* a;int b;long c;void* d;int e;long f;void* g;void* h;void* i;void* j;void* k;int l;long m;long n;} zs;
    ((zs*)z)->d = b;
}
'
}
# XXX End hack

our class gz_header is repr('CStruct') is export {
    has int32 $.text;
    has long $.time;
    has int32 $.xflags;
    has int32 $.os;
    has OpaquePointer $.extra;
    has int32 $.extra_len;
    has int32 $.extra_max;
    has Str $.name;
    has int32 $.name_max;
    has Str $.comment;
    has int32 $.comm_max;
    has int32 $.hcrc;
    has int32 $.done;
}

# constants

constant ZLIB_VERSION = "1.2.8";
constant ZLIB_VERNUM = 0x1280;

constant Z_NULL = 0;

# allowed flush values
constant Z_NO_FLUSH = 0;
constant Z_PARTIAL_FLUSH = 1;
constant Z_SYNC_FLUSH = 2;
constant Z_FULL_FLUSH = 3;
constant Z_FINISH = 4;
constant Z_BLOCK = 5;
constant Z_TREES = 6;

# return codes
constant Z_OK = 0;
constant Z_STREAM_END = 1;
constant Z_NEED_DICT = 2;
constant Z_ERRNO = -1;
constant Z_STREAM_ERROR = -2;
constant Z_DATA_ERROR = -3;
constant Z_MEM_ERROR = -4;
constant Z_BUF_ERROR = -5;
constant Z_VERSION_ERROR = -6;

# compression levels
constant Z_NO_COMPRESSION = 0;
constant Z_BEST_SPEED = 1;
constant Z_BEST_COMPRESSION = 9;
constant Z_DEFAULT_COMPRESSION = -1;

# compression strategy
constant Z_FILTERED = 1;
constant Z_HUFFMAN_ONLY = 2;
constant Z_RLE = 3;
constant Z_FIXED = 4;
constant Z_DEFAULT_STRATEGY = 0;

# data_type values
constant Z_BINARY = 0;
constant Z_TEXT = 1;
constant Z_ASCII = Z_TEXT;
constant Z_UNKNOWN = 2;

# deflate compression method
constant Z_DEFLATED = 8;

# basic functions
our sub zlibVersion() returns Str is encoded('ascii') is native($lib) is export { * }

our sub deflateInit_(z_stream, int32, Str is encoded('ascii'), int32) returns int32 is native($lib) { * }
our sub deflateInit(z_stream $stream, int32 $level) is export {
    return deflateInit_($stream, $level, ZLIB_VERSION, z_stream_sizeof); # 112 == sizeof z_stream (64 bit linux)
}
our sub deflate(z_stream, int32) returns int32 is native($lib) is export { * }
our sub deflateEnd(z_stream) returns int32 is native($lib) is export { * }

our sub inflateInit_(z_stream, Str is encoded('ascii'), int32) returns int32 is native($lib) { * }
our sub inflateInit(z_stream $stream) is export {
    return inflateInit_($stream, ZLIB_VERSION, z_stream_sizeof);
}
our sub inflate(z_stream, int32) returns int32 is native($lib) is export { * }
our sub inflateEnd(z_stream) returns int32 is native($lib) is export { * }

# advanced functions

our sub deflateInit2_(z_stream, int32, int32, int32, int32, int32, Str is encoded('ascii'), int32) returns int32 is native($lib) { * }
our sub deflateInit2(z_stream $strm, int32 $level, int32 $method, int32 $windowbits, int32 $memlevel, int32 $strategy) is export {
    return deflateInit2_($strm, $level, $method, $windowbits, $memlevel, $strategy, ZLIB_VERSION, z_stream_sizeof);
}
our sub deflateSetDictionary(z_stream, CArray[int8], int32) returns int32 is native($lib) is export { * }
our sub deflateCopy(z_stream, z_stream) returns int32 is native($lib) is export { * }
our sub deflateReset(z_stream) returns int32 is native($lib) is export { * }
our sub deflateParams(z_stream, int32, int32) returns int32 is native($lib) is export { * }
our sub deflateTune(z_stream, int32, int32, int32, int32) returns int32 is native($lib) is export { * }
our sub deflateBound(z_stream, int) returns long is native($lib) is export { * }
# arguments are actually (z_stream, unsigned*, int*)
our sub deflatePending(z_stream, CArray[int32], CArray[int32]) returns int32 is native($lib) is export { * }
our sub deflatePrime(z_stream, int32, int32) returns int32 is native($lib) is export { * }
our sub deflateSetHeader(z_stream, gz_header) returns int32 is native($lib) is export { * }

our sub inflateInit2_(z_stream, int32, Str is encoded('ascii'), int32) returns int32 is native($lib) { * }
our sub inflateInit2(z_stream $strm, int32 $windowbits) is export {
    return inflateInit2_($strm, $windowbits, ZLIB_VERSION, z_stream_sizeof);
}
our sub inflateSetDictionary(z_stream, CArray[int8], int32) returns int32 is native($lib) is export { * }
our sub inflateGetDictionary(z_stream, CArray[int8], CArray[int32]) returns int32 is native($lib) is export { * }
our sub inflateSync(z_stream) returns int32 is native($lib) is export { * }
our sub inflateCopy(z_stream, z_stream) returns int32 is native($lib) is export { * }
our sub inflateReset(z_stream) returns int32 is native($lib) is export { * }
our sub inflateReset2(z_stream, int32) returns int32 is native($lib) is export { * }
our sub inflatePrime(z_stream, int32, int32) returns int32 is native($lib) is export { * }
our sub inflateMark(z_stream) returns long is native($lib) is export { * }
our sub inflateGetHeader(z_stream, gz_header) returns int32 is native($lib) is export { * }
our sub inflateBackInit(z_stream, int32, CArray[int8]) returns int32 is native($lib) is export { * }
our sub inflateBack(z_stream, Callable, OpaquePointer, Callable, OpaquePointer) returns int32 is native($lib) is export { * }
our sub inflateBackEnd(z_stream) returns int32 is native($lib) is export { * }

our sub zlibCompileFlags() returns long is native($lib) is export { * }

# utility functions

#second argument is actually long*, but I don't know how to do a pointer to a long
our sub compress(Blob, CArray[int], Blob, int) returns int32 is native($lib) is export { * }
our sub compress2(Blob, CArray[int], Blob, int, int32) returns int32 is native($lib) is export { * }
our sub compressBound(int) returns long is native($lib) is export { * }

#second argument: see note above
our sub uncompress(Blob, CArray[int], Blob, int) returns int32 is native($lib) is export { * }

# gzip file access functions

class gzFile is repr('CPointer') { }

our sub gzopen(Str is encoded('ascii'), Str is encoded('ascii')) returns gzFile is native($lib) is export { * }
our sub gzdopen(int32, Str is encoded('ascii')) returns gzFile is native($lib) is export { * }
our sub gzbuffer(gzFile, int32) returns int32 is native($lib) is export { * }
our sub gzsetparams(gzFile, int32, int32) returns int32 is native($lib) is export { * }
our sub gzread(gzFile, CArray[int8], int32) returns int32 is native($lib) is export { * }
our sub gzwrite(gzFile, CArray[int8], int32) returns int32 is native($lib) is export { * }
# gzprintf # I have no idea how to do variable number of args
our sub gzputs(gzFile, Str is encoded('ascii')) returns int32 is native($lib) is export { * }
our sub gzgets(gzFile, CArray[int8], int32) returns Str is encoded('ascii') is native($lib) is export { * }
our sub gzputc(gzFile, int32) returns int32 is native($lib) is export { * }
our sub gzgetc(gzFile) returns int32 is native($lib) is export { * }
our sub gzungetc(int32, gzFile) returns int32 is native($lib) is export { * }
our sub gzflush(gzFile, int32) returns int32 is native($lib) is export { * }
our sub gzseek(gzFile, int32, int32) returns int32 is native($lib) is export { * }
our sub gzrewind(gzFile) returns int32 is native($lib) is export { * }
our sub gztell(gzFile) returns int32 is native($lib) is export { * }
our sub gzoffset(gzFile) returns int32 is native($lib) is export { * }
our sub gzeof(gzFile) returns int32 is native($lib) is export { * }
our sub gzdirect(gzFile) returns int32 is native($lib) is export { * }
our sub gzclose(gzFile) returns int32 is native($lib) is export { * }
our sub gzclose_r(gzFile) returns int32 is native($lib) is export { * }
our sub gzclose_w(gzFile) returns int32 is native($lib) is export { * }
our sub gzerror(gzFile, CArray[int32]) returns Str is encoded('ascii') is native($lib) is export { * }
our sub gzclearerr(gzFile) is native($lib) is export { * }

# checksum functions
#
our sub adler32(int, CArray[int8], int32) returns long is native($lib) is export { * }
our sub adler32_combine(int, int, int32) returns long is native($lib) is export { * }
our sub crc32(int, CArray[int8], int32) returns long is native($lib) is export { * }
our sub crc32_combine(int, int, int32) returns long is native($lib) is export { * }

# undocumented functions
#
# zError
# inflateSyncPoint
# get_crc_table
# inflateUndermine
# inflateResetKeep
# deflateResetKeep
# gzopen_w
# gzvprintf
