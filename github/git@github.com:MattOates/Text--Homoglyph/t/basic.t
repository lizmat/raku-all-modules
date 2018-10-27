#!/usr/bin/env perl6

use v6;
use Test;
use Text::Homoglyph;

plan 1;

is homoglyphs("A"), ("A", "Α", "А", "Ꭺ"), 'Calling homoglyphs() works ok';

done-testing;
