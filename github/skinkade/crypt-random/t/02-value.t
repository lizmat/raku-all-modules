use Test;

use lib 'lib';

use Crypt::Random;

my $one = crypt_random();
my $two = crypt_random();
my $thr = crypt_random();

ok ($one != $two && $two != $thr), "crypt_random() output changes";

done-testing;
