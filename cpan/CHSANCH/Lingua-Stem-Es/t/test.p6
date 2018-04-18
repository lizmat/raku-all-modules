#! /usr/bin/env perl6

use v6.c;

use lib 'lib';

my $i = 1;
for 'diffs.txt'.IO.lines -> $line {
    say $line.words; 
    $i++;
    last if $i == 2271;
    #say $0.Str;
}