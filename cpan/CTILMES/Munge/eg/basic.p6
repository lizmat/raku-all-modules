#!/usr/bin/env perl6

use Munge;

my $m = Munge.new;

my $encoded = $m.encode('this');

say $encoded;

say $m.decode($encoded);
