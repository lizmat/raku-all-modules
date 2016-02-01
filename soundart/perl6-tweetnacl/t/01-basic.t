use v6;
use Test;
use Crypt::TweetNacl::PublicKey;
use Crypt::TweetNacl::Constants;
use NativeCall;
plan 4;


my $keypair = KeyPair.new;
isa-ok $keypair.secret, CArray[int8];
isa-ok $keypair.public, CArray[int8];

is $keypair.secret.elems, CRYPTO_BOX_SECRETKEYBYTES;
is $keypair.public.elems, CRYPTO_BOX_PUBLICKEYBYTES;
