use v6;
use Test;
plan *;
use Math::Quaternion;

multi sub is_q ( Math::Quaternion $got, @expected, $reason = '' ) {
    is-deeply( [$got.coeffs], @expected, $reason );
}
multi sub is_q ( Math::Quaternion $got, Math::Quaternion $expected, $reason = '' ) {
    is-deeply( [$got.coeffs], [$expected.coeffs], $reason );
}

my $r  = 7;
my Math::Quaternion $q  .= new:  1, 2, 3, 4;
my Math::Quaternion $q1 .= new:  2, 3, 4, 5;
my Math::Quaternion $q2 .= new:  3, 4, 5, 6;
my Math::Quaternion $qr .= new: $r, 0, 0, 0;

is   $q.norm,   5.47722557505166,   '.norm';

is_q $q.conj,   [  1, -2, -3, -4 ], '.conj';
is_q -$q,       [ -1, -2, -3, -4 ], 'Unary minus';
is_q $q  + $r,  [  8,  2,  3,  4 ], 'Add    real';
is_q $r  + $q,  [  8,  2,  3,  4 ], 'Add to real';
is_q $q1 + $q2, [  5,  7,  9, 11 ], 'Add    Quat';
is_q $q  - $r,  [ -6,  2,  3,  4 ], 'Sub      real';
is_q $r  - $q,  [  6, -2, -3, -4 ], 'Sub from real';
is_q $q1 - $q2, [ -1, -1, -1, -1 ], 'Sub      Quat';
is_q $q2 - $q1, [  1,  1,  1,  1 ], 'Sub from Quat';
is_q $q  * $r,  [  7, 14, 21, 28 ], 'Mult by  Real';
is_q $r  * $q,  [  7, 14, 21, 28 ], 'Mult     Real';
is_q $q1 * $q2, [-56, 16, 24, 26 ], 'Mult by  Quat';
is_q $q2 * $q1, [-56, 18, 20, 28 ], 'Mult     Quat - non commutative';

is   $q1 ⋅ $q2, 68, 'Dot product';
is   $q2 ⋅ $q1, 68, 'Dot product - commutative';

# Quaternions are eqv iff all 4 of their component coeffs match each other.
ok $q   eqv Math::Quaternion.new( |$q.coeffs ), ' eqv';
ok $q1 !eqv $q2,                                '!eqv';

ok !$q.is_real,  '$q  is not real';
ok !$q1.is_real, '$q1 is not real';
ok !$q2.is_real, '$q2 is not real';
ok  $qr.is_real, '$qr is     real';

is-deeply [$q.v ], [ 2, 3, 4 ], '$q  .v works';
is-deeply [$q1.v], [ 3, 4, 5 ], '$q1 .v works';
is-deeply [$q2.v], [ 4, 5, 6 ], '$q2 .v works';
is-deeply [$qr.v], [ 0, 0, 0 ], '$qr .v works';


# The product of an Quaternion with its conjugate is a non-negative real number.
is_q $q * $q.conj, [ 30, 0, 0, 0 ], 'Mult by conjugate';
is_q $q.conj * $q, [ 30, 0, 0, 0 ], 'Mult    conjugate';

my sub four_quats ( $n ) {
    return  Math::Quaternion.new( $n,  0,  0,  0 ),
            Math::Quaternion.new(  0, $n,  0,  0 ),
            Math::Quaternion.new(  0,  0, $n,  0 ),
            Math::Quaternion.new(  0,  0,  0, $n );
}
{
    my ( $r, $i, $j, $k ) = four_quats(1);

    # http://en.wikipedia.org/wiki/Quaternion#Multiplication_of_basis_elements
    is_q $r * $r,   $r, '1 * 1 =  1';
    is_q $i * $i,  -$r, 'i * i = -1';
    is_q $j * $j,  -$r, 'j * j = -1';
    is_q $k * $k,  -$r, 'k * k = -1';
    is_q $i * $j,   $k, 'i * j =  k';
    is_q $j * $i,  -$k, 'j * i = -k';
    is_q $j * $k,   $i, 'j * k =  i';
    is_q $k * $j,  -$i, 'k * j = -i';
    is_q $k * $i,   $j, 'k * i =  j';
    is_q $i * $k,  -$j, 'i * k = -j';
}

done-testing;
# vim: ft=perl6
