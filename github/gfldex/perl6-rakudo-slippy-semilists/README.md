# Rakudo::Slippy::Semilist
[![Build Status](https://travis-ci.org/gfldex/perl6-rakudo-slippy-semilists.svg?branch=master)](https://travis-ci.org/gfldex/perl6-rakudo-slippy-semilists)

Implements `postcircumfix:<{|| }>` to allow coercion of Array to semilist.
Implements `postcircumfix:<{; }>:exists` and `postcircumfix:<{|| }>`.
see: http://design.perl6.org/S09.html#line_419

# Usage:

```
use Rakudo::Slippy::Semilist;

my @a = 1,2,3;
my %h;
%h{||@a} = 42;
dd %h;
# OUTPUT«Hash %h = {"1" => ${"2" => ${"3" => 1}}}␤»
dd %h{1;2;3}:exists;
# OUTPUT«Bool::True␤»
```
