use v6;

unit module Crypt::TweetNacl::Constants;

constant TWEETNACL is export = %?RESOURCES<libraries/tweetnacl>.Str;

constant CRYPTO_BOX_SECRETKEYBYTES  is export = 32;
constant CRYPTO_BOX_BOXZEROBYTES  is export = 16;
constant CRYPTO_BOX_NONCEBYTES  is export = 24;
constant CRYPTO_BOX_ZEROBYTES  is export = 32;
constant CRYPTO_BOX_PUBLICKEYBYTES  is export = 32;
constant CRYPTO_BOX_BEFORENMBYTES  is export = 32;
constant CRYPTO_SECRETBOX_KEYBYTES  is export = 32;
constant CRYPTO_SECRETBOX_NONCEBYTES  is export = 24;
constant CRYPTO_SECRETBOX_ZEROBYTES  is export = 32;
constant CRYPTO_SECRETBOX_BOXZEROBYTES  is export = 16;
constant CRYPTO_SIGN_PUBLICKEYBYTES is export = 32;
constant CRYPTO_SIGN_SECRETKEYBYTES  is export = 64;
constant CRYPTO_SIGN_BYTES  is export = 64;
