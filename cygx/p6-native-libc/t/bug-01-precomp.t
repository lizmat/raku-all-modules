#!/usr/bin/env perl6

use v6;

use Test;
use Native::Array;
use Native::LibC <NULL>;

plan 1;

class S is repr('CStruct') { has int $.i }
ok try { NULL.to(S) }, 'cast NULL to struct';
