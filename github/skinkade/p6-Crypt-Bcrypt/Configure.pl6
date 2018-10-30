use v6;
use LibraryMake;

my $dir = 'lib/';
my %vars = get-vars($dir);
process-makefile('.', %vars);
make('.', $dir);

# vim: ft=perl6
