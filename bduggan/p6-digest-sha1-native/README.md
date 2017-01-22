Digest::SHA1::Native
=======
Fast SHA1 computation using NativeCall to C.

[![Build Status](https://travis-ci.org/bduggan/p6-digest-sha1-native.svg)](https://travis-ci.org/bduggan/p6-digest-sha1-native)

Synopsis
========
```
use Digest::SHA1::Native;

say sha1-hex("The quick brown fox jumps over the lazy dog");
say sha1-hex("The quick brown fox jumps over the lazy dog".encode);
say sha1("The quick brown fox jumps over the lazy dog")».fmt('%02x').join;
```

```
2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
```

Description
===========

`sha1-hex` accepts a string or bytes (a Buf or Blob) and returns a hex string.

`sha1` converts the hex into binary (i.e. it returns a Blob).

Examples
========
From <https://en.wikipedia.org/wiki/Hash-based_message_authentication_code#Examples>:
```
use Digest::HMAC;
use Digest::SHA1::Native;

say hmac-hex("key","The quick brown fox jumps over the lazy dog",&sha1);

```

`de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9`

