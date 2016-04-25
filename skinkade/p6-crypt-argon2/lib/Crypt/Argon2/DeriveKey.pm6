use v6;
use strict;
use Crypt::Random;
use Crypt::Argon2::Base;

unit module Crypt::Argon2::DeriveKey;



class Argon2-meta is export {
    has uint32 $.t_cost is required;
    has uint32 $.m_cost is required;
    has uint32 $.parallelism is required;
    has uint32 $.hashlen is required;
    has Buf $.salt is required;
}



multi sub argon2-derive-key(Str $pwd, :$t_cost = 3, :$m_cost = 1 +< 17,
                            :$parallelism = 2, :$hashlen = 32) is export {

    my $key = Buf.new;
    $key[$hashlen - 1] = 0;

    my $saltlen = 16;
    my $salt = crypt_random_buf($saltlen);

    my $err = argon2i_hash_raw($t_cost, $m_cost, $parallelism,
                               $pwd, $pwd.encode.bytes,
                               $salt, $saltlen,
                               $key, $hashlen);

    if $err { die("Hashing failed with error code: "~$err); }

    my $meta = Argon2-meta.new(:$t_cost, :$m_cost, :$parallelism,
                               :$hashlen, :$salt);

    $key, $meta;
}

multi sub argon2-derive-key(Str $pwd, Argon2-meta $meta) is export {
    my $key = Buf.new;
    $key[$meta.hashlen - 1] = 0;

    my $err = argon2i_hash_raw($meta.t_cost, $meta.m_cost, $meta.parallelism,
                               $pwd, $pwd.encode.bytes,
                               $meta.salt, $meta.salt.elems,
                               $key, $meta.hashlen);

    if $err { die("Hashing failed with error code: "~$err); }

    $key;
}

