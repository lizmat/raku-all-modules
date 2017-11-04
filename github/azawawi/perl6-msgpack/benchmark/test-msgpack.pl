#!/usr/bin/env perl

use v5.22;
use Data::MessagePack;

sub test() {
    my $SIZE     = 10_000_000;
	my @data     = (1) x $SIZE;
    my $packed   = Data::MessagePack->pack( @data );
    my $unpacked = Data::MessagePack->unpack( $packed );
}

test() for 1..10;

# vim: set ts=4 sw=4:
