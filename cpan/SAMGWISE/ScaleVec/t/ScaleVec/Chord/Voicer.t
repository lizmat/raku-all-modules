#! /usr/bin/env perl6
use v6;
use Test;
use ScaleVec;

plan 10;

use-ok 'ScaleVec::Chord::Voicer';
use ScaleVec::Chord::Voicer;

my ScaleVec $sv .= new( :vector(0, 4, 7) );

is voicing($sv, 12, -12, 4), (3, 2, 1, -3), "Function voicing provides expected output";
is voicing($sv, -12, 12, 4), (3, 2, 1, -3), "Function voicing provides expected output";

is voicing($sv, 15, -12, 4), (4, 3, 2, -3), "Function voicing provides expected output";

is voicing($sv, 7, 0, 4), (2, 2, 1, 0), "Function voicing provides expected output";

# Weired input cases
is voicing($sv, 0, 0, 4), (0, 0, 0, 0), "Function voicing provides expected output";
is voicing($sv, 12, -12, 1), (-3), "Function voicing provides expected output";
is voicing($sv, 12, -12, 0), (-3), "Function voicing provides expected output";
is voicing($sv, 12, -12, -1), (-3), "Function voicing provides expected output";
is voicing($sv, 12, -12, -2), (-3), "Function voicing provides expected output";
