[![Build Status](https://travis-ci.org/scovit/NativeHelpers-CBuffer.svg?branch=master)](https://travis-ci.org/scovit/NativeHelpers-CBuffer)

NAME
====

NativeHelpers::CBuffer - A type for storing a caller allocated Buffer

SYNOPSIS
========

```perl6
    use NativeHelpers::CBuffer;

   class CBuffer is repr('CPointer') is export
```

The CBuffer object, is `repr("CPointer")`, as such, it can be directly used in
`NativeCall` signatures in the place of a Pointer.

DESCRIPTION
===========

NativeHelpers::CBuffer is a convinent way to store buffers and C NULL terminated strings

EXAMPLE
=======

```perl6
    use NativeHelpers::CBuffer;

    my CBuffer $buf = CBuffer.new(100); # Allocates a buffer of 100 bytes

    sub strncpy(CBuffer, Str, size_t) is native { };
    strncpy($buf, "Uella!", 100);

    say $buf; # Uella!
```

METHODS
=======

## new

```perl6
    method new(size_t $size, :$init, :$type where { $type ∈ $types } = uint8)
```

Allocates a buffer of size `$size` elements, of type `$type` and with content a copy of `$init`.
Where `$init` can be either a Str or a Blob, and `$type` can be any of:

```perl6
    my $types = (uint8, int8, uint16, int16, uint32, int32, uint64, int64, size_t, long, ulong, longlong, ulonglong);
```

## size

```perl6
    method size(--> size_t)
```

Return the stored size

## type

```perl6
    method type()
```

Return the stored type

## Blob

```perl6
    method Blob(--> Blob)
```

Return a copy of the content as a Blob

## Pointer

```perl6
    method Pointer(--> Pointer)
```

Return the pointer to the allocated buffer of type Pointer[self.type]

## Str

```perl6
    method Str(--> Str)
```

Return a Str with the content decoded as null-terminated ASCII

## gist

same as `method Str`

## free

```perl6
     method free()
```

Calls `free` the allocated buffer

TODO
====

At the moment, the CBuffer is immutable on the `perl` side, that means that,
once created and initialized, the content can be only read or modified only
by `C` functions. It is possible to implement `perl` side modifications using
array-type access. It is possible to implement resizing through a call to
`realloc` and `memset`.

AUTHOR
======

Vittore F. Scolari <vittore.scolari@pasteur.fr>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Institut Pasteur

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
