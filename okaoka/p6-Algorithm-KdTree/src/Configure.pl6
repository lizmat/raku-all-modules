use LibraryMake;

my $destdir = '../resources';
my %vars = get-vars($destdir);
process-makefile('.', %vars);

say "Configure completed! You can now run '%vars<MAKE>' to build libfoo.";
