# Note that this is *not* run during panda install - it is intended to be
# run manually for testing / recompiling without needing to do a 'panda install'
#
# The example here is how the 'make' sub generates the makefile in the above Build.pm file
use LibraryMake;

my $destdir = '../resources';
my %vars = get-vars($destdir);

process-makefile('./src', %vars);

say "Configure completed! You can now run '%vars<MAKE>' to build libmurmurhash3.";
