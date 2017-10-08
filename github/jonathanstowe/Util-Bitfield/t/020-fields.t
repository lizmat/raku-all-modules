#!perl6

use v6;

use Test;

use Util::Bitfield;

my @tests = {
                title   => "eight bits two from MSB",
                size    =>  8,
                bits    =>  2,
                start   =>  0,                
                value   =>  3,
                target  =>  0b11000000,
                origin  =>  0b00000000
            },
            {
                title   => "eight bits two from LSB",
                size    =>  8,
                bits    =>  2,
                start   =>  6,                
                value   =>  3,
                target  =>  0b00000011,
                origin  =>  0b00000000
            },
            {
                title   =>  "eight bits two from middle",
                size    =>  8,
                bits    =>  2,
                start   =>  3,                
                value   =>  3,
                target  =>  0b00011000,
                origin  =>  0b00000000
            },
            {
                title   =>  "eight bits two from middle with other bits set",
                size    =>  8,
                bits    =>  2,
                start   =>  3,                
                value   =>  2,
                target  =>  0b11110111,
                origin  =>  0b11111111
            },
            {
                title   => "sixteen bits two from MSB",
                size    =>  16,
                bits    =>  2,
                start   =>  0,                
                value   =>  3,
                target  =>  0b1100000000000000,
                origin  =>  0b0000000000000000
            },
            {
                title   => "sixteen bits two from LSB",
                size    =>  16,
                bits    =>  2,
                start   =>  6,                
                value   =>  3,
                target  =>  0b0000001100000000,
                origin  =>  0b0000000000000000
            },
            {
                title   =>  "sixteen bits two from middle",
                size    =>  16,
                bits    =>  2,
                start   =>  3,                
                value   =>  3,
                target  =>  0b0001100000000000,
                origin  =>  0b0000000000000000
            },
            {
                title   =>  "sixteen bits two from middle with other bits set",
                size    =>  16,
                bits    =>  2,
                start   =>  3,                
                value   =>  2,
                target  =>  0b1111011111111111,
                origin  =>  0b1111111111111111
            },
            ;

for @tests -> $test {
    is extract-bits($test<target>, $test<bits>, $test<start>, $test<size>), $test<value>, "extract-value { $test<title> }";
    is insert-bits($test<value>, $test<origin>, $test<bits>, $test<start>, $test<size>), $test<target>, "insert-value { $test<title> }";
}

for 8, 16, 32, 64, 128 -> $p {
    for 2 .. $p - 2 -> $length {
        my $origin = (^(2**$p)).pick;
        my $start = Int(($p/($length/2)) - 2);
        my $set = (0 .. ((2**$length) - 1)).pick;
        my $get = extract-bits($origin, $length, $start, $p);
        my $new = insert-bits($set, $origin, $length, $start, $p);
        is extract-bits($new, $length, $start, $p), $set, "inserted $length bit number $set in a $p bit number okay";
        is insert-bits($get, $new, $length, $start, $p), $origin, "and managed to set it back again";
    }
}

for ^2**8 -> $i {
    is split-bits(8, $i).join(''), sprintf("%08b", $i), "split-bits for $i";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
