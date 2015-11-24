# Perl6 Brotli Compression
[![Build Status](https://travis-ci.org/sylvarant/Compress-Brotli.svg?branch=master)](https://travis-ci.org/sylvarant/Compress-Brotli) [![artistic](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

Provides acces to [Brotli compression](https://github.com/google/brotli) by means of the perl6 NativeCall API.  

## Usage

A simple compression/decompression round trip can be written as follows. 

```Perl6
use Compress::Brotli; 

my Buf $blob = compress("a simple string");
my Buf $buffer = decompress($blob);
say $buffer.decode('UTF-8');
```

To control the [parameters](https://github.com/google/brotli/blob/master/enc/encode.h) of the brotli compression 
an object of class `Compress::Brotli::Config` can be passed as an argument to the `compress` subroutine.

```Perl6
use Compress::Brotli; 

# a low quality text compression
my Config $conf = Config.new(:mode(1),:quality(1),:lgwin(10),:lgblock(0));
my Buf $blob = compress("a simple string",$conf);

```

## Platforms

Linux, FreeBSD and Mac OSX are tested and supported. 


## Dependencies

To build brotli the [libbrotli](https://github.com/bagder/libbrotli/) project is used.
To succesfully compile libbrotli and the added wrapper library you need:
`libtool`, `autoconf`, `gmake` and `automake`.

## License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)
