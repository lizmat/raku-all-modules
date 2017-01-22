# Text::Diff::Sift4
A Perl 6 implementation of the common version of the Sift4 string distance algorithm (http://siderite.blogspot.com/2014/11/super-fast-and-accurate-string-distance.html).

## Synopsis
```
use Text::Diff::Sift4;

say sift4("string1", "string2");
# 1
```

## Description
An algorithm to compute the distance between two strings in O(n).
```
sift4(Str s1, Str s2, Int maxOffset = 100, Int maxDistance = 100 --> Int)
s1 and s2 are the strings to compare
maxOffset is the number of characters to search for matching letters
maxDistance is the distance at which the algorithm should stop computing the value and just exit (the strings are too different anyway)
```

## Copyright & License
Copyright 2016 Daniel Green.

This module may be used under the terms of the Artistic License 2.0.
