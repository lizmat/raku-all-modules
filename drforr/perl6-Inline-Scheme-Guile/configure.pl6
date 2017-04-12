#!/usr/bin/env perl6
use v6;
use LibraryMake;

sub get-guile-include()
	{
	my $include = chomp(qqx/pkg-config --cflags-only-I guile-2.0/);
	$include ~~ s/^\-I//;
	$include ~~ s/\s+$//;
	return $include;
	}

sub get-guile-lib()
	{
	my $library = chomp(qqx/pkg-config --libs-only-l guile-2.0/);
	$library ~~ s/^\-l//;
	$library ~~ s/\s+$//;
	return $library;
	}

say "*** Should check for LibraryMake and warn if it's not there.";
my %vars = get-vars('.');

%vars<INCLUDE-GUILE> = get-guile-include();
%vars<LIBRARY-GUILE> = get-guile-lib();

%vars<guile-helper> = $*VM.platform-library-name('guile-helper'.IO);
mkdir 'resources' unless 'resources'.IO.e;
mkdir 'resources/libraries' unless 'resources/libraries'.IO.e;
process-makefile('.', %vars);
shell(%vars<MAKE>);

# vim: ft=perl6
