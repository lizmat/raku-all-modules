#!/usr/bin/env perl6

use v6.c;

use Test;

use Doublephone;

my @lines;

for $*PROGRAM.parent.child("words.txt").lines -> $line {
    @lines.push: $line.split: /\,/;
}

plan @lines.elems;

for @lines -> ($in, $one, $two? ) {
    my ( $out-one, $out-two ) = double-metaphone($in);
    is $out-one, $one, "$in is rendered to $one";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
