use Test;

use lib 'lib';

use Crypt::Random;

my $bytes = 32;
my $one = crypt_random_buf($bytes);
my $two = crypt_random_buf($bytes);

ok ($one.elems == $bytes && $two.elems == $bytes),
        "crypt_random_buf() outputs hold correct number of bytes";

nok $one eqv $two, "crypt_random_buf() outputs hold different values";

done-testing;
