# Huffman Encoding in pure perl6

[![Build Status](https://travis-ci.org/tony-o/perl6-encoding-huffman-pp6.svg)](https://travis-ci.org/tony-o/perl6-encoding-huffman-pp6)

What a joy.

## Subs provided + signatures

### Encoding

```sub huffman-encode(Str $string-to-encode, %table?)``` 

#### ```$string-to-encode``` 

The string you wish to encode

#### ```%table?```

The encoding table you'd like to use.  Defaults to the HTTP2 spec's predefined huffman table found [here](https://http2.github.io/http2-spec/compression.html#huffman.code)

### Decoding

```sub huffman-decode(Buf[uint8] $buffer-to-decode, %table?)```

#### ```$buffer-to-decode```

A ```Buf[uint8]``` that you wish to decode

#### ```%table?```

Please reference above.
