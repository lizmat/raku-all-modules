#!perl6

use v6;

use LibraryMake;
use Shell::Command;

my $destdir = $*CWD.child("lib/../resources/libraries").Str;
my %vars = get-vars($destdir);
%vars<i2chelper> = $*VM.platform-library-name('i2chelper'.IO).Str;
my $src = $*CWD.child('src').Str;
mkpath "$destdir";
process-makefile($src, %vars);
my $goback = $*CWD;
chdir($src);
shell(%vars<MAKE>);
chdir($goback);

