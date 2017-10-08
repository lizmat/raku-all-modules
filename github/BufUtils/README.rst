========
BufUtils
========

Somewhere between Perl 5 and 6 it was decided to add a distinction between byte
strings and text strings. `Str` got to keep all the string methods, while `Blob`
and `Buf` were left with next to nothing. This module is a small hack that tries
to fix that.
