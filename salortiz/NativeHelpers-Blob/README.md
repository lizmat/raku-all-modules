# NativeHelpers::Blob

## Introduction

Right now the support for `Blob`/`Buf` in Perl 6's NativeCall is incomplete.
You can use these as arguments for native functions, but not as attributes for
CStruct or CUnion, for example.

In a `CStruct` class, you can use a `Pointer` or a `CArray`, but those don't have the
flexibility of a `Blob` or `Buf`, and move data between them is slow, and with
big buffers the memory involved increases dramatically.

At some point, these problems will be addressed in core, but in the meantime...

## Usage

    use NativeHelpers::Blob;

## Exported functions

### sub Pointer(Blob:D, :$typed)

Returns a `Pointer` to the contents of the `Blob`.

The type of the returned `Pointer` will be the same of the `Blob` if `:typed` was used
or `void` if not.

### sub carray-from-blob(Blob:D, :$managed)

Returns a `CArray` constructed from de contents of the `Blob`.

If `:managed` was given, the returned `CArray` contains a copy of the original
content of the `Blob` and will be managed, otherwise the `CArray` holds a
reference to the `Blob` content.


### sub blob-new(Mu \type = uint8, :$elems)

A fast `Blob` constructor, initialized with `:elems` zeroed elements.

### sub blob-from-pointer(Pointer:D, Int :$elems!, Mu :$type)

Returns a `Blob` constructed from the memory pointed by the given `Pointer` and the
following `:elems` elements.

The type of the `Pointer` determines the type of the `Blob`, so when given a
`Pointer[void]` you should pass the extra `:type` with the desired type.

Please note that the amount of memory copied depends of `$elems` **and** `:type`´s
native size;

### sub blob-from-carray(CArray:D, Int :$size)

Returns a `Blob` constructed from the contents of the `CArray`.

When the `CArray` is unmanaged, for example as returned by a native call function, you
should include de `:size` argument.

The type of the `Blob` is determined by the type of the `CArray`.


## WARNING
This module depends on internal details of the REPRs of the involved types in MoarVM,
so it can stop working without notice.

In the same way as when handling pointers in C, you should known what are you doing.

This is an early release to allow the interested people the testing and
discussion of the module: there is some missing features and you should
be aware that the API isn't in stone yet.

## COPYRIGHT

Copyright © 2016 by Salvador Ortiz
