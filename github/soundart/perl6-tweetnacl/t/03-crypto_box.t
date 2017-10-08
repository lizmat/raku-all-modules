use v6;
use Test;
use Crypt::TweetNacl::PublicKey;
use Crypt::TweetNacl::Basics;
use NativeCall;

plan 8;
my $alice = KeyPair.new;
my $bob = KeyPair.new;
my $msg = 'Hello World'.encode('UTF-8');

my CArray[int8] $nonce = nonce();
my $data1 = crypto_box($msg, $nonce, $alice.public , $bob.secret);
my $rmsg1 = crypto_box_open($data1, $nonce, $bob.public , $alice.secret);
is $rmsg1.decode('UTF-8'), $msg , "Roundtrip encrypt->decrypt";

# as far as I know a nonce should never be reused,
# here it is reused for test purposes.
my $cb = CryptoBox.new(pk => $alice.public , sk => $bob.secret);
my $data2 = $cb.encrypt($msg, $nonce);
is-deeply $data1, $data2, "encrypt, precomputation interface";


my $cbo = CryptoBoxOpen.new(pk => $bob.public , sk => $alice.secret);
my $rmsg2 = $cbo.decrypt($data2, $nonce);
is $rmsg2.decode('UTF-8'), $msg, "decrypt, precomputation interface";


# nonce free interface
my $cb3 = CryptoBox.new(pk => $alice.public , sk => $bob.secret);
my $data3 = $cb3.encrypt($msg);
my $cbo3 = CryptoBoxOpen.new(pk => $bob.public , sk => $alice.secret);
my $rmsg3 = $cbo3.decrypt($data3);
is $rmsg3.decode('UTF-8'), $msg, "Roundtrip, precomputation interface, nonce free interface";

# should throw
dies-ok { CryptoBox.new(pk => $alice.public); } , "Error, Missing Parameter";
dies-ok { CryptoBox.new(sk => $alice.public); } , "Error, Missing Parameter";
dies-ok { CryptoBoxOpen.new(pk => $alice.public); } , "Error, Missing Parameter";
dies-ok { CryptoBoxOpen.new(sk => $alice.public); } , "Error, Missing Parameter";
