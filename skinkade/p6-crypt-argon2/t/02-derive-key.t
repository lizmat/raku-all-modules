use Test;

use lib 'lib';

use Crypt::Argon2::DeriveKey;



my ($key, $meta) = argon2-derive-key("password");

my $test = argon2-derive-key("password", $meta);

ok $test eqv $key, "Key can be successfully re-derived";



done-testing;
