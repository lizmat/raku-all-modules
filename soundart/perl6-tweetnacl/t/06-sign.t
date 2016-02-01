use v6;
use Test;
use Crypt::TweetNacl::Sign;
use Crypt::TweetNacl::Constants;
use NativeCall;

plan 7;

my $keypair = KeyPair.new;
isa-ok $keypair.secret, CArray[int8];
isa-ok $keypair.public, CArray[int8];

is $keypair.secret.elems, CRYPTO_SIGN_SECRETKEYBYTES;
is $keypair.public.elems, CRYPTO_SIGN_PUBLICKEYBYTES;

my $msg = 'Hello World'.encode('UTF-8');
my $cs = CryptoSign.new(buf => $msg, sk => $keypair.secret);
isa-ok $cs.signature, CArray[int8];
is $cs.signature.elems, 75;


my $cso = CryptoSignOpen.new(buf => $cs.signature, pk => $keypair.public);
is $cso.message.decode('UTF-8'), 'Hello World', 'verify signature';
