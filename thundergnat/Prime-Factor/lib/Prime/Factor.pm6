unit module Prime::Factor:ver<0.0.2>:auth<github:thundergnat>;
use v6;

my @primes := 2, 3, |(flat map( { $^i-1, $i+1 }, (6, 12, 18 ... *))).grep: *.is-prime;

multi sub factors(1) is export { 1 }
multi sub factors(Int $remainder is copy where $remainder > 1) is export {
    gather for @primes -> $factor {

        # if remainder < factor², we're done
        if $factor * $factor > $remainder {
            take $remainder if $remainder > 1;
            last;
        }

        # How many times can we divide by this prime?
        while $remainder %% $factor {
            take $factor;
            last if ($remainder div= $factor) === 1;
        }
    }
}
