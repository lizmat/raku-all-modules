use v6;
use strict;
use NativeCall;

unit module Crypt::Argon2::Base;



constant ARGON2 = %?RESOURCES<libraries/argon2>.Str;



sub argon2i_hash_encoded(uint32 $t_cost,
                         uint32 $m_cost,
                         uint32 $parallelism,
                         Str $pwd is encoded('utf8'), uint32 $pwdlen,
                         Buf $salt, size_t $saltlen,
                         size_t $hashlen, Buf $encoded,
                         size_t $encodedlen)
    is native(ARGON2)
    returns int
    is export
    { * }

sub argon2_encodedlen(uint32 $t_cost, uint32 $m_cost, uint32 $parallelism,
                      uint32 $saltlen, uint32 $hashlen)
    is native(ARGON2)
    returns size_t
    is export
    { * }

sub argon2i_verify(Str $encoded is encoded('utf8'),
                   Str $pwd is encoded('utf8'),
                   size_t $pwdlen)
    is native(ARGON2)
    returns int
    is export
    { * }



sub argon2i_hash_raw(uint32 $t_cost,
                     uint32 $m_cost,
                     uint32 $parallelism,
                     Str $pwd is encoded('utf8'), uint32 $pwdlen,
                     Buf $salt, size_t $saltlen,
                     Buf $hash, size_t $hashlen)
    is native(ARGON2)
    returns int
    is export
    { * }
