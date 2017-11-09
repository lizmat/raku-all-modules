#!/usr/bin/env perl6

use v6;
use lib 'lib';

use Bench;
use Data::MessagePack;
use Inline::Perl5;
use MsgPack;

# Prepare Inline::Perl5 benchmark
my $p5 = Inline::Perl5.new;
$p5.use('Data::MessagePack');

constant COUNT = 1000;
constant SIZE  = 1000;
say "Iterations: " ~ COUNT;
say "List size:  " ~ SIZE;
my %results = Bench.new.timethese(COUNT, {
    "Data::MessagePack" => sub {
        my $data     = [1 xx SIZE];
        my $packed   = Data::MessagePack::pack( $data );
        my $unpacked = Data::MessagePack::unpack( $packed );
        warn "Something went wrong" if ($packed.elems <= $data.elems)
            or $unpacked.elems != $data.elems;
    },
    "MsgPack" => sub {
        my $data     = [1 xx SIZE];
        my $packed   = MsgPack::pack( $data );
        my $unpacked = MsgPack::unpack( $packed );
        warn "Something went wrong" if ($packed.elems <= $data.elems)
            or $unpacked.elems != $data.elems;
    },
    "Data::MessagePack (via Inline::Perl5)" => sub {
        my $ret = $p5.run(sprintf(q'
            my $data     = (1) x %d;
            my $mp       = Data::MessagePack->new;
            my $packed   = $mp->pack( $data );
            my $unpacked = $mp->unpack( $packed );
            warn "Something went wrong" if (length $packed <= length $data)
                or (length $unpacked != length $data);
            42;
        ', SIZE));
        die if $ret != 42;
    },
});
say ~%results;
