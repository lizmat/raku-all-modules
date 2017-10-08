use v6;
use Test;

use Number::More :ALL;

plan 180;

my $LC = True;

# a random set of decimal inputs
my $nrands = 10; # num loops
my $ntests = 18; # per loop
my $total-tests = $nrands * $ntests;
my @uints = ((rand * 10000).Int) xx $nrands;
for @uints -> $dec {
    my $bin  = $dec.base: 2;
    my $oct  = $dec.base: 8;
    my $hex  = $dec.base: 16; # alpha chars are upper case
    my $hex2 = lc $hex;       # a lower-case version

    # the tests 18
    is bin2oct($bin), $oct, $oct;
    is bin2dec($bin), $dec, $dec;
    is bin2hex($bin), $hex, $hex;
    is bin2hex($bin, :$LC), $hex2, $hex2;

    is oct2bin($oct), $bin, $oct;
    is oct2dec($oct), $dec, $dec;
    is oct2hex($oct), $hex, $hex;
    is oct2hex($oct, :$LC), $hex2;

    is dec2bin($dec), $bin, $bin;
    is dec2oct($dec), $oct, $oct;
    is dec2hex($dec), $hex, $hex;
    is dec2hex($dec, :$LC), $hex2, $hex2;

    is hex2bin($hex), $bin, $bin;
    is hex2oct($hex), $oct, $oct;
    is hex2dec($hex), $dec, $dec;

    is hex2bin($hex2), $bin, $bin;
    is hex2oct($hex2), $oct, $oct;
    is hex2dec($hex2), $dec, $dec;
}
