unit module Prime::Factor:ver<0.2.1>:auth<github:thundergnat>;
use v6;

sub prime-factors ( Int $n where * > 0 ) is export {
    return $n if $n.is-prime;
    return [] if $n == 1;
    my $factor = find-factor( $n );
    sort flat prime-factors( $factor ), prime-factors( $n div $factor );
}

# use Pollard's rho algorithm to speed factorization
# See Wikipedia "Pollard's rho algorithm" and
# Damian Conways "On the Shoulders of Giants" presentation from YAPC::NA 2016
sub find-factor ( Int $n, $constant = 1 ) {
    return 2 if $n %% 2;          # catch common factors
    return 5 if $n == any(5, 25); # which cause recursion
    my $x      = 2;
    my $rho    = 1;
    my $factor = 1;
    while $factor == 1 {
        $rho *= 2;
        my $fixed = $x;
        for 1 ..^ $rho {
            $x = ($x * $x + $constant) % $n;
            $factor = ($x - $fixed) gcd $n;
            last if 1 < $factor;
        }
    }
    $factor = find-factor( $n, $constant + 1 ) if $n == $factor;
    $factor;
}
