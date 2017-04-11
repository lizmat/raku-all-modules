# Slippy::Semilist

[![Build Status](https://travis-ci.org/gfldex/perl6-slippy-semilist.svg?branch=master)](https://travis-ci.org/gfldex/perl6-slippy-semilist)

Implements `postcircumfix:<{|| }>` to allow coercion of Array to semilist.
Implements `postcircumfix:<{; }>:exists` and `postcircumfix:<{|| }>`.
see: http://design.perl6.org/S09.html#line_419

## SYNOPSIS

```
use Slippy::Semilist;

my @a = 1,2,3;
my %h;
%h{||@a} = 42;
dd %h;
# OUTPUT«Hash %h = {"1" => ${"2" => ${"3" => 42}}}␤»
dd %h{1;2;3}:exists;
# OUTPUT«Bool::True␤»
```

## LICENSE

All files (unless noted otherwise) can be used, modified and redistributed
under the terms of the Artistic License Version 2. Examples (in the
documentation, in tests or distributed as separate files) can be considered
public domain.

ⓒ2017 Wenzel P. P. Peppmeyer
