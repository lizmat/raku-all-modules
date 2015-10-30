#!/usr/bin/env perl6

use v6;

# use Test;
use Native::LibC <malloc fopen puts>;

say '1..3';

my $buf = malloc(1024);
my $file = fopen('t/ok123.txt', 'r');
loop { puts(chomp $file.gets($buf, 1024) // last) }
