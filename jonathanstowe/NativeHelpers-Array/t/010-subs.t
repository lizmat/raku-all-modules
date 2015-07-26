#!perl6

use v6;
use lib 'lib';
use Test;

use NativeHelpers::Array;
use NativeCall;

my @array = 1,2,3,4;

my $carray;

lives-ok { $carray = copy-to-carray(@array, int32) }, "copy-to-carray";
isa-ok($carray, CArray[int32], "got the right type back");
ok(compare-to-carray(@array, $carray), "and the elements are copied");

lives-ok { @array = copy-to-array($carray, 4) }, "copy-to-array";
is(@array.elems, 4, "got the right number of elememts");
ok(compare-to-carray(@array, $carray), "and the elements are copied");

my Buf $buf = Buf.new(@array);
lives-ok { $carray = copy-buf-to-carray($buf) }, "copy-buf-to-carray";
isa-ok($carray, CArray[uint8], "and it's the right type");
ok(compare-to-carray($buf, $carray), "and the elements are copied");

lives-ok { $buf = copy-carray-to-buf($carray, 4) }, "copy-carray-to-buf";
is($buf.elems, 4, "got the right number of elements");
ok(compare-to-carray($buf, $carray), "and the elements are copied");

sub compare-to-carray($array, CArray $carray) returns Bool {
    my Bool @tests;
    for ^$array.elems -> $i {
        @tests.push($carray[$i] eq $array[$i]);
    }

    return any(@tests).Bool;
}

done;

# vim: expandtab shiftwidth=4 ft=perl6
