#!/usr/bin/env perl6

use v6;
use LibraryMake;

use lib ($*PROGRAM.dirname);

use Build;
my $build = Build.new();
$build.build($*PROGRAM.dirname);

