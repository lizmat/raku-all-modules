# NAME

Compress::Snappy - (de)compress data in Google's Snappy compression format

# SYNOPSIS

```perl6
my Buf $compressed = Compress::Snappy::compress("hello, world");
my Bool $valid = Compress::Snappy::validate($compressed);
my Buf $decompressed = Compress::Snappy::decompress($compressed);
```

See also examples/test.p6

# DESCRIPTION

This module uses NativeCall to provide bindings to the C API for libsnappy, a
compression library with an emphasis on speed over compression.

# FUNCTIONS

## Compress::Snappy::compress(Blob $uncompressed) returns Buf

Main compression function. Returns a Buf of compressed data.

## Compress::Snappy::compress(Str $uncompressed) returns Buf

Convenience function to make a Str to a utf8-encoded Blob and compress that.

## Compress::Snappy::decompress(Blob $compressed) returns Buf

Decompress provided data to a Buf.

## Compress::Snappy::validate(Blob $compressed) returns Bool

Returns if the compressed data is valid, without fully decompressing it.

# SEE ALSO

[Snappy on Google Code](https://code.google.com/p/snappy/)

[Snappy on GitHub](https://github.com/google/snappy)
