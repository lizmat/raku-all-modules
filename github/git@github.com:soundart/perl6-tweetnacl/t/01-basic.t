use v6;
use Test;
use Crypt::TweetNacl::PublicKey;
use Crypt::TweetNacl::Constants;
use Crypt::TweetNacl::Basics;
use NativeCall;
plan 5;


my $keypair = KeyPair.new;
isa-ok $keypair.secret, CArray[int8];
isa-ok $keypair.public, CArray[int8];

is $keypair.secret.elems, CRYPTO_BOX_SECRETKEYBYTES;
is $keypair.public.elems, CRYPTO_BOX_PUBLICKEYBYTES;

my $hash = CryptoHash.new(buf => 'hi'.encode('UTF-8'));
is $hash.hex, <<150a14ed5bea6cc731cf86c41566ac42
                7a8db48ef1b9fd626664b3bfbb99071f
                a4c922f33dde38719b8c8354e2b7ab9d
                77e0e67fc12843920a712e73d558e197>>.join,
                'computed correct known sha-512';

