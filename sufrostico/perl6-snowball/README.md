# Lingua::Stem::Snowball [![Build Status](https://travis-ci.org/Sufrostico/perl6-snowball.svg?branch=master)](https://travis-ci.org/Sufrostico/perl6-snowball)

Perl6 binding for the "Snowball compiler"
[http://snowballstem.org/](http://snowballstem.org/)

# Status: **ALPHA**

  - No Snowball code shipped, you need to install it from its own repo.
  - NativeCalls are implemented to emulate the libstemmer.h file.
  - Only the load and sb_stemmer_stem tests are implemented.
  - NEED ASAP lots and lots of tests.

## Functions working

- [x] sb_stemmer_list() returns CArray[Str]
- [x] sb_stemmer_new(Str, Str) returns sb_stemmer
- [x] sb_stemmer_delete(sb_stemmer)
- [x] sb_stemmer_stem(sb_stemmer, Str, int32 ) returns CArray[uint8]
- [ ] sb_stemmer_length(sb_stemmer) returns int32

## TODO
- [ ] Write a gazillion tests
- [ ] Clone functions from the [perl5's Lingua::Stem::Snowball](https://metacpan.org/pod/Lingua::Stem::Snowball)


  
# Installation 

1. You need to install the libstemmer.so shared library from this repository
    [Sufrostico/snowball](https://github.com/Sufrostico/snowball) because the
    [patch to generate the shared
    library](https://github.com/snowballstem/snowball/pull/35) has not been
   a accepted yet.

    To install the library

```
    $ git clone git@github.com:Sufrostico/snowball.git sufrostico-snowball
    $ cd sufrostico-snowball
    $ make
```

Then as root install the .h (usr/include) and .so (user/lib) files.

```
    # make install_shared_library
```

2. Install this module

```
    $ git clone git@github.com:Sufrostico/perl6-snowball.git
    $ cd perl6-snowball
    $ panda install .
```

# Contributors

  - [Altai-man](https://github.com/Altai-man) 
