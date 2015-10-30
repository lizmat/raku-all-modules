Text::Homoglyph
=============

Perl6 package for mapping ASCII characters to unicode homoglyphs (similar looking characters)

Data
====

The data was pinched and modified from the super evil https://github.com/reinderien/mimic
Several gaps were filled in with http://shapecatcher.com please feel free to extend and improve the character mapping. Some obvious improvements can be made by completing full ranges like the maths letters. More work needs to be done on curating the "best" looking unicode homoglyph as the first in the list.

N.b. the very first character returned is the ASCII character

Example Use
===========

```perl
#!/usr/bin/env perl6
use v6;

use Text::Homoglyph;

say "Woohoo this is some nice text".comb.map({(rand > 0.8)?? $_ !! homoglyphs($_)[1] }).join;
```

> Ꮃοοһοo 𝗍һiѕ іs ѕοⅿе niϲе 𝗍eх𝗍
