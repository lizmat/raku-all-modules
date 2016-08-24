# Doublephone

Implementation of the Double Metaphone phonetic encoding algorithm.

## Synopsis

```perl6

use Doublephone;

say double-metaphone("SMITH"); # (SM0 XMT)
say double-metaphone("SMIHT"); # (SMT XMT)


```

## Description

This implements the [Double Metaphone](https://en.wikipedia.org/wiki/Metaphone#Double_Metaphone) 
algorithm which can be used to match similar sounding words.  It is an improved version of
Metaphone (which in turn follows on from soundex,) and was first described by Lawrence Philips
in the June 2000 issue of the C/C++ Users Journal.

It differs from some other similar algorithms in that a primary and secondary code are returned
which allows the comparison of words (typically names,) with some common roots in different languages
as well as dealing with ambiguities.  So for instance "SMITH", "SMYTH" and "SMYTHE" will yield 
(SM0 XMT) as the primary and secondary, whereas "SCHMIDT", "SCHMIT" will yield (XMT SMT) so if a
"cross language" comparison is required then either of the primary or secondary codes can be matched
to the target primary or secondary code - this will also deal with, for example, transpositions in
typed names.

This is basically a Perl 6 binding to the original C implementation I extracted from the Perl 5
[Text::DoubleMetaphone](https://metacpan.org/release/Text-DoubleMetaphone).  

The algorithm itself isn't designed for unicode strings and making something that is is
probably best left to another module using a different technique.

Though this is described as a "phonetic" encoding it is only approximately so, rather it is
optimised for comparison and not as a guide to how something might be pronounced.

## Installation

If you have a working installation of Rakudo Perl 6 with one of ```panda``` or ```zef``` installed
then you should be able to install this with either:

	panda install Doublephone

	# or from a local clone

	panda install .

or:

	zef install Doublephone

	# or from a local clone

	zef install .

Though other installers may become available that should work equally.

## Support

Almost all of the functionality of this is in the C library which has
a fairly long heritage, so is less likely to be buggy than the way in
which I am using it.  Please feel free to report any bugs/send patches
or just make suggestions to https://github.com/jonathanstowe/Doublephone/issues


I would also like more tests for the correct output if anyone finds a good
data source for these.

# Licence and Copyright

This is free software, please see the [LICENCE](LICENCE) file in the distribution.

© Jonathan Stowe, 2016

The C portions from Text::DoubleMetaphone have the following copyright text:


  Copyright 2000, Maurice Aubrey <maurice@hevanet.com>. 
  All rights reserved.

  This code is based heavily on the C++ implementation by
  Lawrence Philips and incorporates several bug fixes courtesy
  of Kevin Atkinson <kevina@users.sourceforge.net>.

  This module is free software; you may redistribute it and/or
  modify it under the same terms as Perl itself.


