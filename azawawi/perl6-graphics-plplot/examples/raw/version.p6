#!/usr/bin/env perl6

use v6;
use lib 'lib';
use NativeCall;
use Graphics::PLplot::Raw;

my $version = CArray[int8].new;
$version[79] = 0;
plgver($version);
my $ver = '';
for 0..$version.elems -> $i {
    last if $version[$i] == 0;
    $ver ~= $version[$i].chr;
}
say "version: '$ver'";
