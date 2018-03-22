
Digest::SHA256::Native
=======
Fast SHA256 computation using NativeCall to C.

[![Build Status](https://travis-ci.org/bduggan/p6-digest-sha256-native.svg?branch=master)](https://travis-ci.org/bduggan/p6-digest-sha256-native)

Synopsis
========
```
use Digest::SHA256::Native;

say sha256-hex("The quick brown fox jumps over the lazy dog");
say sha256-hex("The quick brown fox jumps over the lazy dog".encode);
say sha256("The quick brown fox jumps over the lazy dog")».fmt('%02x').join;
```

```
d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592
d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592
d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592
```

Description
===========

`sha256-hex` accepts a string or bytes (a Buf or Blob) and returns a hex string.

`sha256` converts the hex into binary (i.e. it returns a Blob).

Examples
========
From <https://en.wikipedia.org/wiki/Hash-based_message_authentication_code#Examples>:
```
use Digest::HMAC;
use Digest::SHA256::Native;

say hmac-hex("key","The quick brown fox jumps over the lazy dog",&sha256);

```

`f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8`

References
======
The implementation is mostly taken from Brad Conte's [crypto-algorithms](https://github.com/B-Con/crypto-algorithms).

