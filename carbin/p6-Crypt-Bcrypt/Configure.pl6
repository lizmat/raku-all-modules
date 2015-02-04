use v6;
use LibraryMake;

my $dir = '../../lib';
my %vars = get-vars($dir);
process-makefile('ext/crypt_blowfish-1.2', %vars);
make("ext/crypt_blowfish-1.2", $dir);

# vim: ft=perl6
