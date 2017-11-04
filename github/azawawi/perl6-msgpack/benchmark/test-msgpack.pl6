#!/usr/bin/env perl6

use v6;
use lib 'lib';

use Bench;
use Data::MessagePack;
use MsgPack;

constant SIZE = 10_000;
my $b = Bench.new;
my %results = $b.timethese(25, {
    "Data::MessagePack" => sub { 
        my $data   = ['1' xx SIZE];
        my $packed = Data::MessagePack::pack( $data );
        warn "Something went wrong" if $packed.elems <= $data.elems
    },
    "MsgPack" => sub {
        my $data   = ['1' xx SIZE];
        my $packed = MsgPack::pack( $data );
        warn "Something went wrong" if $packed.elems <= $data.elems
    },
});
say "list size: " ~ SIZE;
say ~%results;
