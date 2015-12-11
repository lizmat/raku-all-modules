#!perl6

use v6;

use LibraryMake;
use Shell::Command;

my $destdir = 'lib/../resources/lib';
my %vars = get-vars($destdir);
mkpath $destdir;
process-makefile('src', %vars);
make('src', "../$destdir");
