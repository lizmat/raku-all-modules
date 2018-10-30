use v6;
use Test;
plan *;
use Math::Quaternion;

my         $r = 7;
my Complex $c = 8+9i;

my Math::Quaternion $q1 .= new:  1, 2, 3, 4;
my Math::Quaternion $qr .= new: $r, 0, 0, 0;
my Math::Quaternion $qc .= new: $c;
my Math::Quaternion $qp .= new: pi, 0, 0, 0;
my Math::Quaternion $qz .= new:  0, 0, 0, 0;
my Math::Quaternion $qi .= new:  0, 2, 3, 4;
my Math::Quaternion $qu .= unit;
my Math::Quaternion $qU  = $q1 * ( 1 / $q1.squarednorm.sqrt ); # XXX Change to .norm or .normalize(d) when available.

my @test_pairs =
    zero      => { $^a.is_zero },
    real      => { $^a.is_real },
    complex   => { $^a.is_complex },
    imaginary => { $^a.is_imaginary },
;
my @data =
    # z  r  c  i
    [ 0, 0, 0, 0, :$q1 ],
    [ 0, 1, 1, 0, :$qr ],
    [ 0, 0, 1, 0, :$qc ],
    [ 0, 1, 1, 0, :$qp ],
    [ 1, 1, 1, 1, :$qz ],
    [ 0, 0, 0, 1, :$qi ],
    [ 0, 1, 1, 0, :$qu ],
    [ 0, 0, 0, 0, :$qU ], # Non-real Unit Q
;
for @test_pairs.kv -> $i, ( :key($test_name), :value($subref) ) {
    for @data -> $d_aref {
        my ( $expected, $q_pair ) = $d_aref.[ $i, *-1 ];
        my ( $q_name, $q ) = $q_pair.kv;
        my $not = $expected ?? '   ' !! 'not';
        ok (? $q.$subref) == (? $expected), "\$$q_name is $not $test_name";
    }
}

done-testing;
# vim: ft=perl6
