use v6;
use lib 'lib';
use Test;

use Crypt::RSA;

my $crypt = Crypt::RSA.new;

my ($pub,$pri) = $crypt.generate-keys;
isa-ok $pub, Crypt::RSA::Key, 'public key';
isa-ok $pri, Crypt::RSA::Key, 'private key';

my $message = 2340823403012;
my $encrypted = $crypt.encrypt($message);
ok $encrypted, 'encrypted message';
ok $encrypted != $message, 'plaintext != ciphertext';
my $decrypted = $crypt.decrypt($encrypted);
ok $decrypted, "decrypted message";
is $decrypted, $message, "got original message";

$message = 764938576435;
my $signature = $crypt.generate-signature($message);
ok $signature, 'generated signature';
ok $crypt.verify-signature($message,$signature), "verified signature";

done-testing;

