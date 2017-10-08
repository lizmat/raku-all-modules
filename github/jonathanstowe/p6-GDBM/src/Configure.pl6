#!perl6

use v6;

use LibraryMake;
use Shell::Command;

my $destdir = $*CWD.child("lib/../resources/libraries").Str;
my %vars = get-vars($destdir);
%vars<gdbmhelper> = $*VM.platform-library-name('gdbmhelper'.IO).Str;
my $src = $*CWD.child('src').Str;
%vars<LIBS> ~= ' -lgdbm';
mkpath "$destdir";
process-makefile($src, %vars);
my $goback = $*CWD;
chdir($src);
shell(%vars<MAKE>);
chdir($goback);

