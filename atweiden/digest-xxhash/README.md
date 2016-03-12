Digest::xxHash
==============

Perl6 bindings for xxHash. 32 bit functions recommended pending unsigned
long long support in NativeCall.


Usage
-----

```perl6
# 32 or 64 bit xxHash from string, depending on architecture
say xxHash("dupa");

# 32 bit
say xxHash32("dupa");

# 64 bit
say xxHash64("dupa");

# 32 or 64 bit xxHash from file
say xxHash(:file<filename.txt>);

# 32 or 64 bit xxHash from Buf
say xxHash(buf-u8 => Buf[uint8].new(0x64, 0x75, 0x70, 0x61))
```


Dependencies
------------

- Rakudo Perl6
- [libxxhash](https://aur.archlinux.org/packages/libxxhash)


Licensing
---------

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
