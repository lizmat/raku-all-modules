use v6;
use Test;
use Crypt::TweetNacl::Basics;
use Crypt::TweetNacl::PublicKey;
use NativeCall;
plan 2;

my $a = randombytes(42);
my $b = randombytes(42);
nok $a eqv $b;

my $n = nonce();
isa-ok CArray[int8], $n;
