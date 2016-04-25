use Test;

use lib 'lib';

use Crypt::Random;

my $upper = 10000;
my $one = crypt_random_uniform($upper);
my $two = crypt_random_uniform($upper);
my $thr = crypt_random_uniform($upper);

ok ($one != $two || $two != $thr), "crypt_random_uniform() output changes";
ok (0 <= $one < $upper || 0 <= $two < $upper || 0 <= $thr < $upper),
        "crypt_random_uniform() outputs are within range";

done-testing;
