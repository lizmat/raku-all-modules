# Native::LibC [![Build Status](https://travis-ci.org/cygx/p6-native-libc.svg?branch=master)](https://travis-ci.org/cygx/p6-native-libc)

The C standard library

# Synopsis

```
    use Native::LibC <malloc fopen puts free>;

    my $buf = malloc(1024);
    my $file = fopen('LICENSE', 'r');

    loop { puts(chomp $file.gets($buf, 1024) // last) }

    $file.close;
    free($buf);
```

# Description

Provides access to the C standard library. It's accompanied by the module
`Native::Array` that provides an iterable wrapper over `CArray` as well as
patching `NativeCall::Pointer`, among other things adding an `rw` accessor.

This is still work in progress and not a finished product. Feel free to
[open a ticket](https://github.com/cygx/p6-native-libc/issues/new) if you
need a particular feature that's still missing.


# Building

The file `p6-native-libc.c` needs to be compiled into a shared library named
`p6-native-libc.[so|dll|...]`.

You can try using the Makefile, ie

    make
    make test
    make install PREFIX=/path/to/share/perl6/site

but no guarantees.

On Windows, use the wrapper batch scripts for MSVC nmake or MinGW gmake as
appropriate.


# LibC API

Overview over the `libc::` namespace, a lexical alias for `Native::LibC::`.

Anything that's missing from this list still needs to be implemented.


## Constants

    constant int    = int32;

    constant uint   = uint32;

    constant llong  = longlong;

    constant ullong = ulonglong;

    constant float  = num32;

    constant double = num64;

    constant intptr_t = do given PTRSIZE { * }

    constant uintptr_t = do given PTRSIZE { * }

    constant size_t    = uintptr_t;

    constant ptrdiff_t = intptr_t;

    constant clock_t = do { * }

    constant time_t = do { * }

    constant _IOFBF = do { * }

    constant _IOLBF = do { * }

    constant _IONBF = do { * }

    constant BUFSIZ = do { * }

    constant EOF = do { * }

    constant SEEK_CUR = do { * }

    constant SEEK_END = do { * }

    constant SEEK_SET = do { * }

    constant Ptr = Pointer;

    constant &sizeof = &nativesizeof;

    constant CHAR_BIT = do { * }

    constant SCHAR_MIN = do { * }

    constant SCHAR_MAX = do { * }

    constant UCHAR_MAX = do { * }

    constant CHAR_MIN = do { * }

    constant CHAR_MAX = do { * }

    constant MB_LEN_MAX = do { * }

    constant SHRT_MIN = do { * }

    constant SHRT_MAX = do { * }

    constant USHRT_MAX = do { * }

    constant INT_MIN = do { * }

    constant INT_MAX = do { * }

    constant UINT_MAX = do { * }

    constant LONG_MIN = do { * }

    constant LONG_MAX = do { * }

    constant ULONG_MAX = do { * }

    constant LLONG_MIN = do { * }

    constant LLONG_MAX = do { * }

    constant ULLONG_MAX = do { * }

    constant limits = %( * );

    constant CLOCKS_PER_SEC = do { * }


## Functions

    our sub NULL { once Ptr.new(0) }

    our sub isalnum(int --> int) is native(LIBC) { * }

    our sub isalpha(int --> int) is native(LIBC) { * }

    our sub isblank(int --> int) is native(LIBC) { * }

    our sub iscntrl(int --> int) is native(LIBC) { * }

    our sub isdigit(int --> int) is native(LIBC) { * }

    our sub isgraph(int --> int) is native(LIBC) { * }

    our sub islower(int --> int) is native(LIBC) { * }

    our sub isprint(int --> int) is native(LIBC) { * }

    our sub ispunct(int --> int) is native(LIBC) { * }

    our sub isspace(int --> int) is native(LIBC) { * }

    our sub isupper(int --> int) is native(LIBC) { * }

    our sub isxdigit(int --> int) is native(LIBC) { * }

    our sub tolower(int --> int) is native(LIBC) { * }

    our sub toupper(int --> int) is native(LIBC) { * }

    multi sub errno() { * }

    multi sub errno(Int \value) { * }

    our sub fopen(Str, Str --> FILE) is native(LIBC) { * }

    our sub fclose(FILE --> int) is native(LIBC) { * }

    our sub fflush(FILE --> int) is native(LIBC) { * }

    our sub puts(Str --> int) is native(LIBC) { * }

    our sub fgets(Ptr, int, FILE --> Str) is native(LIBC) { * }

    our sub fread(Ptr, size_t, size_t, FILE --> size_t) is native(LIBC) { * }

    our sub feof(FILE --> int) is native(LIBC) { * }

    our sub fseek(FILE, long, int --> int) is native(LIBC) { * };

    our sub malloc(size_t --> Ptr) is native(LIBC) { * }

    our sub realloc(Ptr, size_t --> Ptr) is native(LIBC) { * }

    our sub calloc(size_t, size_t --> Ptr) is native(LIBC) { * }

    our sub free(Ptr) is native(LIBC) { * }

    our sub memcpy(Ptr, Ptr, size_t --> Ptr) is native(LIBC) { * }

    our sub memmove(Ptr, Ptr, size_t --> Ptr) is native(LIBC) { * }

    our sub memset(Ptr, int, size_t --> Ptr) is native(LIBC) { * }

    our sub memcmp(Ptr, Ptr, size_t --> int) is native(LIBC) { * }

    our sub strlen(Ptr[int8] --> size_t) is native(LIBC) { * }

    our sub system(Str --> int) is native(LIBC) { * }

    our sub exit(int) is native(LIBC) { * }

    our sub abort() is native(LIBC) { * }

    our sub raise(int --> int) is native(LIBC) { * }

    our sub getenv(Str --> Str) is native(LIBC) { * }

    our sub srand(uint) is native(LIBC) { * };

    our sub rand(--> int) is native(LIBC) { * };

    our sub clock(--> clock_t) is native(LIBC) { * }

    our sub time(Ptr[time_t] --> time_t) is native(LIBC) { * }


## Classes

    class FILE is Ptr { * }

        method open(FILE:U: Str \path, Str \mode = 'r') { * }

        method close(FILE:D:) { * }

        method flush(FILE:D:) { * }

        method eof(FILE:D:) { * }

        method seek(FILE:D: Int \offset, Int \whence) { * }

        method gets(FILE:D: Ptr() \ptr, int \count) { * }



# Bugs and Development

Development happens at [GitHub](https://github.com/cygx/p6-native-libc). If you
found a bug or have a feature request, use the
[issue tracker](https://github.com/cygx/p6-native-libc/issues) over there.


# Copyright and License

Copyright (C) 2015 by <cygx@cpan.org>

Distributed under the
[Boost Software License, Version 1.0](http://www.boost.org/LICENSE_1_0.txt)
