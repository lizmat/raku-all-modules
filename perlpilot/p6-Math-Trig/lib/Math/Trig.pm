unit module Math::Trig:ver<0.01>;

constant two-pi = pi * 2;

sub rad2rad ($rad)  is export 
{
    return $rad % two-pi;
}

sub deg2deg ($deg) is export
{
    return $deg % 360;
}

sub grad2grad ($grad) is export 
{
    return $grad % 400;
}

sub rad2deg ($rad) is export
{
    return $rad * 180 / pi;
}

sub deg2rad ($deg) is export
{
    return $deg * pi / 180;
}

sub grad2deg ($grad) is export
{
    return 360 / 400 * $grad;
}

sub deg2grad ($deg) is export
{
    return 400 / 360 * $deg;
}

sub rad2grad ($rad) is export
{
    return 400 / two-pi * $rad;
}

sub grad2rad ($grad) is export 
{
    return two-pi / 400 * $grad;
}

sub cartesian-to-spherical($x,$y,$z) is export(:radial)
{
    my $rho = sqrt($x*$x + $y*$y + $z*$z);
    return $rho, atan2($y, $x), acos($z / $rho);
}

sub spherical-to-cartesian($rho, $theta, $phi) is export(:radial)
{
    return ( $rho * cos( $theta ) * sin( $phi ),
             $rho * sin( $theta ) * sin( $phi ),
             $rho * cos( $phi   ) );
}

sub spherical-to-cylindrical($rho, $theta, $phi) is export(:radial)
{
    my ($x, $y, $z) = spherical-to-cartesian($rho,$theta,$phi);
    return ( sqrt( $x * $x + $y * $y ), $theta, $z );
}

sub cartesian-to-cylindrical($x,$y,$z) is export(:radial)
{
    return ( sqrt( $x * $x + $y * $y ), atan2( $y, $x ), $z );
}

sub cylindrical-to-cartesian($rho, $theta, $z) is export(:radial)
{
    return ( $rho * cos( $theta ), $rho * sin( $theta ), $z );
}

sub cylindrical-to-spherical($rho, $theta, $phi)  is export(:radial)
{
    return cartesian-to-spherical( |cylindrical-to-cartesian( $rho, $theta, $phi ) );
}

sub great-circle-distance($theta0, $phi0, $theta1, $phi1, $rho = 1) is export(:great-circle)
{
    my $lat0 = pi/2 - $phi0;
    my $lat1 = pi/2 - $phi1;
    return $rho * acos( cos( $lat0 ) * cos( $lat1 ) * cos( $theta0 - $theta1 ) +
                   sin( $lat0 ) * sin( $lat1 ) );
}

sub great-circle-direction($theta0, $phi0, $theta1, $phi1) is export(:great-circle)
{
    my $lat0 = pi/2 - $phi0;
    my $lat1 = pi/2 - $phi1;
 
    return rad2rad(2 * pi -
        atan2(sin($theta0-$theta1) * cos($lat1),
                cos($lat0) * sin($lat1) -
                    sin($lat0) * cos($lat1) * cos($theta0-$theta1)));
}

our &great-circle-bearing is export(:great-circle) = &great-circle-direction;

sub great-circle-waypoint($theta0, $phi0, $theta1, $phi1, $point = 0.5) is export(:great-circle)
{
    my $d = great-circle-distance( $theta0, $phi0, $theta1, $phi1 );
 
    return if $d == pi;
 
    my $sd = sin($d);
 
    return ($theta0, $phi0) if $sd == 0;
 
    my $A = sin((1 - $point) * $d) / $sd;
    my $B = sin(     $point  * $d) / $sd;
 
    my $lat0 = pi/2 - $phi0;
    my $lat1 = pi/2 - $phi1;
 
    my $x = $A * cos($lat0) * cos($theta0) + $B * cos($lat1) * cos($theta1);
    my $y = $A * cos($lat0) * sin($theta0) + $B * cos($lat1) * sin($theta1);
    my $z = $A * sin($lat0)                + $B * sin($lat1);
 
    my $theta = atan2($y, $x);
    my $phi   = acos($z);
 
    return ($theta, $phi);
}

our &great-circle-midpoint is export(:great-circle) = &great-circle-waypoint.assuming(:point(0.5));

sub great-circle-destination( $theta0, $phi0, $dir0, $dst ) is export(:great-circle)
{
    my $lat0 = pi/2 - $phi0;
 
    my $phi1   = asin(sin($lat0)*cos($dst) +
                      cos($lat0)*sin($dst)*cos($dir0));
 
    my $theta1 = $theta0 + atan2(sin($dir0)*sin($dst)*cos($lat0),
                                 cos($dst)-sin($lat0)*sin($phi1));
 
    my $dir1 = great-circle-bearing($theta1, $phi1, $theta0, $phi0) + pi;
 
    $dir1 -= 2*pi if $dir1 > 2*pi;
 
    return ($theta1, $phi1, $dir1);
}
