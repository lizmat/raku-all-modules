#!/usr/bin/env perl6

use v6;

use Compress::Snappy;

sub MAIN() {
	my $buf = Compress::Snappy::compress("a" x 800);
	say $buf;

	my $valid = Compress::Snappy::validate($buf);
	say "buffer is ", ($valid ?? "" !! "NOT "), "valid!";

	my $decoded = Compress::Snappy::decompress($buf);
	say $decoded.decode("utf8");
}
