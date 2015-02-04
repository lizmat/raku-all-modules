use v6;
use Test;
plan *;
use Math::Quaternion;

sub is_q ( Math::Quaternion $got, @expected, $reason = '' ) {
    # Complex always have real coefficients, so we use .Num to force
    # conversion when @expected might contain Ints.
    is_deeply( [$got.coeffs».Num], [@expected».Num], $reason );
}

my          Complex $c   = 8+9i;
my Math::Quaternion $qc .= new: $c;
my Math::Quaternion $q  .= new: 1, 2, 3, 4;

is_q $q  + $c, [   9,  11,   3,   4 ], 'Add      Complex';
is_q $c  + $q, [   9,  11,   3,   4 ], 'Add to   Complex';
is_q $q  - $c, [  -7,  -7,   3,   4 ], 'Sub      Complex';
is_q $c  - $q, [   7,   7,  -3,  -4 ], 'Sub from Complex';
is_q $q  * $c, [ -10,  25,  60,   5 ], 'Mult by  Complex';
is_q $c  * $q, [ -10,  25, -12,  59 ], 'Mult     Complex';

is   $c ⋅ $q , 26, 'Dot product';
is   $q ⋅ $c , 26, 'Dot product - commutative';

ok $qc eqv Math::Quaternion.new( $c.re, $c.im, 0, 0 ), 'eqv';

ok ! $q.is_complex,  '$q is not Complex';
ok  $qc.is_complex,  '$c is     Complex';

done;
# vim: ft=perl6
