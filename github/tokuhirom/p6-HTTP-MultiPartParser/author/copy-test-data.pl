#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

use lib 'author/lib/';

# copy test data from p5's HTTP::MultiPartParser

use PAML qw/LoadFile/;
use JSON::PP;
use File::Basename;
use File::Copy;

my $encoder = JSON::PP->new->ascii->pretty;

for my $file (glob('../p5-http-multipartparser/t/data/*.pml')) {
    my $dat = LoadFile($file);
    my $out = "t/data/" . basename($file);
    $out =~ s/\.pml/.json/;
    my $json = $encoder->encode($dat);

    open my $fh, '>', $out or die $!;
    print {$fh} $json;
    close $fh;
}

for my $file (glob('../p5-http-multipartparser/t/data/*.dat')) {
    my $out = "t/data/" . basename($file);
    system('cp', $file, $out)==0 or die $!;
}
