use v6;
use strict;
use Crypt::Random;
use Crypt::Argon2::Base;

unit module Crypt::Argon2;



sub argon2-hash(Str $pwd, :$t_cost = 2, :$m_cost = 1 +< 16,
                :$parallelism = 2, :$hashlen = 16) is export {
    my $saltlen = 16;
    my $encodedlen = argon2_encodedlen($t_cost, $m_cost, $parallelism,
                                       $saltlen, $hashlen);

    my $salt = crypt_random_buf($saltlen);
    my $encoded = Buf.new;
    $encoded[$encodedlen - 1] = 0;

    my $err = argon2i_hash_encoded($t_cost, $m_cost, $parallelism,
                                   $pwd, $pwd.encode.bytes,
                                   $salt, $saltlen, $hashlen,
                                   $encoded, $encodedlen);

    if $err { die("Hashing failed with error code: "~$err); }

    $encoded.decode;
}

sub argon2-verify($encoded, $pwd) is export {
    # ARGON2_OK = 0
    if argon2i_verify($encoded, $pwd, $pwd.encode.bytes) {
        return False;
    } else {
        return True;
    }
}
