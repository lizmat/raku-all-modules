use v6;
use strict;

unit module Crypt::Random::Nix;



my $urandom = open("/dev/urandom", :bin);

sub _crypt_random_bytes(uint64 $len) returns Buf is export {
    my $bytes = $urandom.read($len);

    if ($bytes.elems != $len) {
        die("Failed to read enough bytes from /dev/urandom");
    }

    $bytes;
}
