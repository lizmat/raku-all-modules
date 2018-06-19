#!/usr/bin/env perl6
use v6;
use LibraryMake;

my $libname = 'tweetnacl';
my %vars = get-vars('.');
%vars{$libname} = $*VM.platform-library-name($libname.IO);
mkdir "resources" unless "resources".IO.e;
mkdir "resources/libraries" unless "resources/libraries".IO.e;
process-makefile('.', %vars);
shell(%vars<MAKE>);

say "Configure completed! You can now run '%vars<MAKE>' to build lib$libname.";
