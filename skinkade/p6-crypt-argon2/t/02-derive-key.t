use Test;

use lib 'lib';

use Crypt::Argon2::DeriveKey;



my ($key, $meta) = argon2-derive-key("password");

my $test = argon2-derive-key("password", $meta);

my $same_key = True;
for ^$test.elems {
    if $test[$_] != $key[$_] {
        $same_key = False;
    }
}
ok $same_key, "Key can be successfully re-derived";



done-testing;
