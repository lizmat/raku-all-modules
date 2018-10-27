#!/usr/bin/env perl6

use v6;

use Compress::Snappy;

my &scompress = &Compress::Snappy::compress;
my &svalidate = &Compress::Snappy::validate;
my &sdecompress = &Compress::Snappy::decompress;

sub MAIN(Int $loopcount = 1) {
    for ^$loopcount {
	my $buf = scompress("a" x 80000);

	my $valid = svalidate($buf);

	my $decoded = sdecompress($buf);
    }
}
