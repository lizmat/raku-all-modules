# this is NOT run when installing via panda
# it is only here to facilitate local testing without needing
# to do a panda install every rebuild

use v6;
use LibraryMake;

my $destdir = '../lib';
my %vars = get-vars($destdir);
process-makefile('.', %vars);
