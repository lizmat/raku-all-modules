use v6;
use Test;
use Crypt::TweetNacl::SecretKey;
use Crypt::TweetNacl::Constants;
use NativeCall;

plan 1;



# create key
my $alice = Key.new;

# create Buf to encrypt
my $msg = 'Hello World'.encode('UTF-8');

# encrypt
my $csb = CryptoSecretBox.new(sk => $alice.secret);
my $data = $csb.encrypt($msg);

# decrypt
my $csbo = CryptoSecretBoxOpen.new(sk => $alice.secret);
my $rmsg = $csbo.decrypt($data);

is $rmsg.decode('UTF-8'), 'Hello World'
