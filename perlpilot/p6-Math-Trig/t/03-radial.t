use Test;
use Math::Trig :DEFAULT, :radial;

plan 30;

# cartesian X cylindrical
{
    my ($r,$t,$z) = cartesian-to-cylindrical(1,1,1);
    is-approx($r, sqrt(2), '');
    is-approx($t, deg2rad(45), '');
    is-approx($z, 1, '');

    (my $x,my $y,$z) = cylindrical-to-cartesian($r, $t, $z);
    is-approx($x, 1, '');
    is-approx($y, 1, '');
    is-approx($z, 1, '');

    ($r,$t,$z) = cartesian-to-cylindrical(1,1,0);
    is-approx($r, sqrt(2), '');
    is-approx($t, deg2rad(45), '');
    is-approx($z, 0, '');

    ($x,$y,$z) = cylindrical-to-cartesian($r, $t, $z);
    is-approx($x, 1, '');
    is-approx($y, 1, '');
    is-approx($z, 0, '');
}

# cartesian X spherical
{
    my ($r,$t,$f) = cartesian-to-spherical(1,1,1);
    is-approx($r, sqrt(3), '');
    is-approx($t, deg2rad(45), '');
    is-approx($f, atan2(sqrt(2), 1), '');

    my ($x,$y,$z) = spherical-to-cartesian($r,$t,$f);
    is-approx($x, 1, '');
    is-approx($y, 1, '');
    is-approx($z, 1, '');

    ($r,$t,$f) = cartesian-to-spherical(1,1,0);
    is-approx($r, sqrt(2), '');
    is-approx($t, deg2rad(45), '');
    is-approx($f, deg2rad(90), '');

    ($x,$y,$z) = spherical-to-cartesian($r, $t, $f);
    is-approx($x, 1, '');
    is-approx($y, 1, '');
    is-approx($z, 0, '');
}

# cylindrical X spherical
{
    my ($r,$t,$z) = cylindrical-to-spherical(|spherical-to-cylindrical(1,1,1));
    is-approx($r, 1, '');
    is-approx($t, 1, '');
    is-approx($z, 1, '');
 
    ($r,$t,$z) = spherical-to-cylindrical(|cylindrical-to-spherical(1,1,1));
    is-approx($r, 1, '');
    is-approx($t, 1, '');
    is-approx($z, 1, '');
}


