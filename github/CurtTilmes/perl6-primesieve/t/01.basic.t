use v6;

use Test;
use Math::Primesieve;

plan 15;

ok my $p = Math::Primesieve.new, 'new';

ok $p.version, 'version';

is $p.primes(100), [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41,
                    43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97], 'primes';


is $p.primes(100, 200), [101, 103, 107, 109, 113, 127, 131, 137, 139,
                         149, 151, 157, 163, 167, 173, 179, 181, 191,
                         193, 197, 199], 'primes > 100';

is $p.n-primes(20), [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41,
                     43, 47, 53, 59, 61, 67, 71], 'n-primes';

is $p.n-primes(10, 1000), [1009, 1013, 1019, 1021, 1031, 1033, 1039,
                           1049, 1051, 1061], 'n-primes > 1000';


is $p.nth-prime(10), 29, 'nth-prime';

is $p[10], 29, 'subscript nth-prime';

is $p.nth-prime(100, 1000), 1721, 'nth-prime > 1000';

is $p.count(10**9), 50847534, 'count primes < 10^9';

is $p.count(10**9, :twins), 3424506, 'count twins < 10^9';

is $p.count(10**9, :triplets), 759256, 'count triplets < 10^9';

is $p.count(10**9, :quadruplets), 28388, 'count quadruplets < 10^9';

is $p.count(10**9, :quintuplets), 7221, 'count quintuplets < 10^9';

is $p.count(10**9, :sextuplets), 317, 'count sextuplets < 10^9';

done-testing;
