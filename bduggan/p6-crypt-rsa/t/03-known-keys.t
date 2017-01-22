use v6;
use lib 'lib';
use Test;

use Crypt::RSA;

# primes: 5 and 7
# phi: 28
# 5*17 % 28 == 1
my $crypt = Crypt::RSA.new(
    public-key => Crypt::RSA::Key.new(:exponent(5),:modulus(35)),
    private-key => Crypt::RSA::Key.new(:exponent(17),:modulus(35))
);

# 2**5 mod 35
is $crypt.encrypt(2), 32, 'encrypt';
is $crypt.decrypt(32), 2, 'decrypt';

done-testing;

