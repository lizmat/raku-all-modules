#!/usr/bin/env perl6

use v6;
use lib 'lib';

use Bench;
use Data::MessagePack;
use MsgPack;

constant SIZE = 1000;
say "List size: " ~ SIZE;
my %results = Bench.new.timethese(25, {
    "Data::MessagePack" => sub { 
        my $data     = ['1' xx SIZE];
        my $packed   = Data::MessagePack::pack( $data );
        my $unpacked = Data::MessagePack::unpack( $packed );
        warn "Something went wrong" if ($packed.elems <= $data.elems)
            or $unpacked != $data;
    },
    "MsgPack" => sub {
        my $data     = ['1' xx SIZE];
        my $packed   = MsgPack::pack( $data );
        my $unpacked = MsgPack::unpack( $packed );
        warn "Something went wrong" if ($packed.elems <= $data.elems)
            or $unpacked != $data;
    },
});
say ~%results;
