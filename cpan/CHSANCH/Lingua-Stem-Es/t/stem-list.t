#! /usr/bin/env perl6

use v6.c;

use lib 'lib';
use Lingua::Stem::Es;
use Test;

plan 28377;

for 't/diffs.txt'.IO.lines -> $line {
    my ( $word, $stem ) = $line.words; 
    is stem($word), $stem, "Stem for $word is $stem";
}

done-testing;

# vim: ft=perl6 noet
