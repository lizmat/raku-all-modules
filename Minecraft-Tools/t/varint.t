#!/usr/bin/env perl6
use Test;

my @tests = ( (((128 X** ^5) X+ -2..2) X* 1,-1), int32.Range.bounds ).flat;
@tests .= grep(* > 0); # Need to support negative values someday, but not now
plan +@tests;

my \P = (require Net::Minecraft::Packet);
constant trailing = Blob.new(0xFF xx 5);

.&test-one-value for @tests;

sub test-one-value(Int $_) {
    my $packed = P::serialize($_);
    my $unpacked = P::unserialize(Int, $packed);
    my $garbage  = P::unserialize(Int, $packed ~ trailing);

    subtest {
        for 'logarithm'    => (1 max 1 + .log(128).floor),
            'bit counting' => ceiling(.fmt('%1b').chars / 7),
            '.bytes mixin' => $unpacked.bytes {
            is $packed.bytes, .value, "{.key} equals serialized byte length";
        }

        is $unpacked, $_, "Value round trips";
        is $garbage,  $_, '...even with trailing bytes';
    }, .fmt('%+#08x');
}
