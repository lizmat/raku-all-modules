# Util::Bitfield

Utility subroutines for working with bitfields

## Synopsis

```
use Util::Bitfield;

my $number = 0b0001011101101010;

# source integer, number of bits, starting position, word size
say extract-bits($number,3,3,16); # 5
say sprintf "%016b",insert-bits(7, $number, 3, 3, 16); # "0001111101101010"

```

## Description

"Bitfields" are common in hardware interfaces and 
compact binary data formats, allowing the packing
of multiple fields of information within a single
machine word sized value for instance, hardware
examples might include device registers or gpio
ports, software examples include MP3 "frame headers".

Whilst highly efficient for data storage and
transmission, they're usually a pain to work with
in high level languages, requiring masking and
shifting of numbers possibly multiple times to
get a value you can sensibly use in your program.

Also because it's not something I at least tend
to do very frequently the patterns don't come
naturally and I end up starting from first principles
every time.

So to this end, on being presented with some data
that required unpacking of a bit field, I made this
fairly simple library to extract and insert an
arbitrary number of bits from an arbitrary location
within a larger integer as smaller integers.

## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Util::Bitfield

I haven't tried this with "zef" but I have no reason to think it
shouldn't work if you would rather use that.

Other install mechanisms may be become available in the future.

## Support

Suggestions/patches are welcomed via github at

   https://github.com/jonathanstowe/Util-Bitfield

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2016
