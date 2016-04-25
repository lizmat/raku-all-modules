use v6;
use strict;
use NativeCall;

unit module Crypt::Random::Win;



# RtlGenRandom
sub SystemFunction036(Buf, uint64)
    returns Bool
    is native('Advapi32', v0)
    { * }



sub _crypt_random_bytes($len) returns Buf is export {
    my $bytes = Buf.new;
    $bytes[$len - 1] = 0;

    if (!SystemFunction036($bytes, $len)) {
        die("RtlGenRandom() failed");
    }

    $bytes;
}

