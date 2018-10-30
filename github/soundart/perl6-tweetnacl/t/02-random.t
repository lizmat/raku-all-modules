use v6;
use Test;
use Crypt::TweetNacl::Basics;
use Crypt::TweetNacl::PublicKey;
use NativeCall;
plan 2;
my $i;
my $a = randombytes(42);
my $b = randombytes(42);
my $same = Bool::True;
loop ($i=0; $i < 42 ; $i++)
{
   if ( $a[$i] != $b[$i] )
   {
      $same = Bool::False;
   }

}

say $a;
say $b;

is $same , Bool::False;

my $n = nonce();
isa-ok CArray[int8], $n;
