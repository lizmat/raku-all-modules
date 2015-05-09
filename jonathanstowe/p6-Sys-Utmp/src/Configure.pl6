#!perl6

use v6;

use LibraryMake;

my $destdir = '../lib';
my %vars = get-vars($destdir);
process-makefile('src', %vars);
make('src', $destdir);
