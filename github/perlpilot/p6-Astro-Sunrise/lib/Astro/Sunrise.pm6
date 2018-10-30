unit module Astro::Sunrise;

# port of Perl 5 code
# See https://metacpan.org/source/JFORGET/Astro-Sunrise-0.92/Sunrise.pm

constant DEGRAD = pi / 180;
constant RADEG = 180 / pi;

# See http://www.stjarnhimlen.se/comp/riset.html
constant LHA-TO-DEGREES = 15.04107;

proto sunrise(|) {*}

multi sub sunrise(Date $date, $lon, $lat, $tz = 0, $altit = -0.833, Bool :$isdst = False, Bool :$iter = False) is export {

    my ($h1,$h2);
    my $d = days_since_1999_Dec_31( $date ) + 0.5 - $lon / 360.0;
    if ($iter) {
        my ($tmp_rise_1,$tmp_set_1) = sun_rise_set($d, $lon, $lat, $altit, LHA-TO-DEGREES);
     
        # Now we have the initial rise/set times next recompute d using the exact moment
        # recompute sunrise
     
        my $tmp_rise_2 = 9;
        my $tmp_rise_3 = 0;
        until (equal($tmp_rise_2, $tmp_rise_3, 8) )   {
             my $d_sunrise_1 = $d + $tmp_rise_1 / 24.0;
             ($tmp_rise_2,$) = sun_rise_set($d_sunrise_1, $lon, $lat, $altit, LHA-TO-DEGREES);
             $tmp_rise_1 = $tmp_rise_3;
             my $d_sunrise_2 = $d + $tmp_rise_2 / 24.0;
             ($tmp_rise_3,$) = sun_rise_set($d_sunrise_2, $lon, $lat, $altit, LHA-TO-DEGREES);
        }
     
        my $tmp_set_2 = 9;
        my $tmp_set_3 = 0;
        until (equal($tmp_set_2, $tmp_set_3, 8) )   {
             my $d_sunset_1 = $d + $tmp_set_1 / 24.0;
             ($,$tmp_set_2) = sun_rise_set($d_sunset_1, $lon, $lat, $altit, LHA-TO-DEGREES);
             $tmp_set_1 = $tmp_set_3;
             my $d_sunset_2 = $d + $tmp_set_2 / 24.0;
             ($,$tmp_set_3) = sun_rise_set($d_sunset_2, $lon, $lat, $altit, LHA-TO-DEGREES);
        }
        
        ($h1,$h2) = ($tmp_rise_3, $tmp_set_3);
    } else {
        ($h1,$h2) = sun_rise_set($d, $lon, $lat, $altit, 15.0);
    }
    return convert_hour($h1, $h2, $tz, $isdst);
}

# return a pair of DateTimes for sunrise/sunset
multi sub sunrise(Cool(Int) $year, $month, $day, $lon, $lat, $tz = 0, $altit = -0.833, Bool :$isdst = False, :$iter = False) is export {
    my $date = Date.new(:year(+$year), :month(+$month), :day(+$day));
    my ($sr,$ss) = sunrise($date, $lon, $lat, $tz, $altit, :$isdst, :$iter);
    my ($rhr,$rmn) = split /\:/, $sr;
    my ($shr,$smn) = split /\:/, $ss;
    return DateTime.new( :$year, :$month, :$day, :hour($rhr.Int), :minute($rmn.Int) ), 
           DateTime.new( :$year, :$month, :$day, :hour($shr.Int), :minute($smn.Int) );
}

# From http://www.stjarnhimlen.se/comp/riset.html WRT $divisor ...
#   to convert LHA from degrees to hours, divide by 15.04107 instead of
#   15.0 (this accounts for the difference between the solar day and the
#   sidereal day. You should only use 15.04107 if you intend to iterate;
#   if you don't want to iterate, use 15.0 as before since that will
#   give an approximate correction for the Earth's orbital motion during
#   the day).

sub sun_rise_set($d, $lon, $lat, $altit is copy, $divisor = 15.0) {
    # Compute local sidereal time of this moment
    my $sidtime = revolution( GMST0($d) + 180.0 + $lon );
 
    # Compute Sun's RA + Decl + distance at this moment
    my ( $sRA, $sdec, $sr ) = sun_RA_dec($d);
 
    # Compute time when Sun is at south - in hours UT
    my $tsouth  = 12.0 - rev180( $sidtime - $sRA ) / $divisor;
 
    # Compute the Sun's apparent radius, degrees
    my $sradius = 0.2666 / $sr;
    $altit -= $sradius;
 
    # Compute the diurnal arc that the Sun traverses to reach
    # the specified altitude altit:
 
    my $cost =
      ( sind($altit) - sind($lat) * sind($sdec) ) /
      ( cosd($lat) * cosd($sdec) );
 
    my $t;
    if ( $cost >= 1.0 ) {
        fail "Sun never rises!!\n";
        $t = 0.0;    # Sun always below altit
    }
    elsif ( $cost <= -1.0 ) {
        fail "Sun never sets!!\n";
        $t = 12.0;    # Sun always above altit
    }
    else {
        $t = acosd($cost) / $divisor;    # The diurnal arc, hours
    }
 
    # Store rise and set times - in hours UT
 
    my $hour_rise_ut = $tsouth - $t;
    my $hour_set_ut  = $tsouth + $t;
    return ($hour_rise_ut, $hour_set_ut);
}

sub GMST0($d) {
    my $sidtim0 = revolution( ( 180.0 + 356.0470 + 282.9404 ) + ( 0.9856002585 + 4.70935E-5 ) * $d );
    return $sidtim0;
}

sub sunpos($d) {
    #                       Mean anomaly of the Sun
    #                       Mean longitude of perihelion
    #                         Note: Sun's mean longitude = M + w
    #                       Eccentricity of Earth's orbit
    #                       Eccentric anomaly
    #                       x, y coordinates in orbit
    #                       True anomaly
 
    # Compute mean elements
    my $Mean_anomaly_of_sun = revolution( 356.0470 + 0.9856002585 * $d );
    my $Mean_longitude_of_perihelion = 282.9404 + 4.70935E-5 * $d;
    my $Eccentricity_of_Earth_orbit  = 0.016709 - 1.151E-9 * $d;
 
    # Compute true longitude and radius vector
    my $Eccentric_anomaly =
      $Mean_anomaly_of_sun + $Eccentricity_of_Earth_orbit * RADEG *
      sind($Mean_anomaly_of_sun) *
      ( 1.0 + $Eccentricity_of_Earth_orbit * cosd($Mean_anomaly_of_sun) );
 
    my $x = cosd($Eccentric_anomaly) - $Eccentricity_of_Earth_orbit;
 
    my $y =
      sqrt( 1.0 - $Eccentricity_of_Earth_orbit * $Eccentricity_of_Earth_orbit )
      * sind($Eccentric_anomaly);
 
    my $Solar_distance = sqrt( $x * $x + $y * $y );    # Solar distance
    my $True_anomaly = atan2d( $y, $x );               # True anomaly
 
    my $True_solar_longitude =
      $True_anomaly + $Mean_longitude_of_perihelion;    # True solar longitude
 
    if ( $True_solar_longitude >= 360.0 ) {
        $True_solar_longitude -= 360.0;    # Make it 0..360 degrees
    }
 
    return ( $Solar_distance, $True_solar_longitude );
}

sub sun_RA_dec($d) {
    # Compute Sun's ecliptical coordinates
    my ( $r, $lon ) = sunpos($d);
 
    # Compute ecliptic rectangular coordinates (z=0)
    my $x = $r * cosd($lon);
    my $y = $r * sind($lon);
 
    # Compute obliquity of ecliptic (inclination of Earth's axis)
    my $obl_ecl = 23.4393 - 3.563E-7 * $d;
 
    # Convert to equatorial rectangular coordinates - x is unchanged
    my $z = $y * sind($obl_ecl);
    $y = $y * cosd($obl_ecl);
 
    # Convert to spherical coordinates
    my $RA  = atan2d( $y, $x );
    my $dec = atan2d( $z, sqrt( $x * $x + $y * $y ) );
 
    return ( $RA, $dec, $r );
 
} 

sub days_since_1999_Dec_31(Date $date)
{
    state $epoch = Date.new(:year(1999), :month(12), :day(31));
    return $date - $epoch;
}


sub sind { sin( ( $^a ) * DEGRAD ); }
 
sub cosd { cos( ( $^a ) * DEGRAD ); }
 
sub tand { tan( ( $^a ) * DEGRAD ); }
 
sub atand { ( RADEG * atan( $^a ) ); }
 
sub asind { ( RADEG * asin( $^a ) ); }
 
sub acosd { ( RADEG * acos( $^a ) ); }
 
sub atan2d { ( RADEG * atan2( $^a, $^b ) ); }

sub revolution($x) {
    return ( $x - 360.0 * floor( $x / 360 ) );
}

sub rev180($x) {
    return ( $x - 360.0 * floor( $x / 360 + 0.5 ) );
}
 
sub equal($A,$B,$dp) {
    return sprintf("%.{$dp}g", $A) eq sprintf("%.{$dp}g", $B);
}
 
sub convert_hour($hour_rise_ut, $hour_set_ut, $tz, Bool $isdst) {
 
  my $rise_local = $hour_rise_ut + $tz;
  my $set_local = $hour_set_ut + $tz;
  if ($isdst) {
    $rise_local += 1;
    $set_local += 1;
  }
 
  # Rise and set should be between 0 and 24;
  if $rise_local < 0 {
    $rise_local += 24;
  }
  elsif $rise_local > 24 {
    $rise_local -= 24;
  }
  if $set_local < 0 {
    $set_local += 24;
  }
  elsif $set_local > 24 {
    $set_local -= 24;
  }
 
  my $hour_rise =  $rise_local.Int;
  my $hour_set  =  $set_local.Int;
 
  my $min_rise  = floor(($rise_local-$hour_rise)*60+0.5);
  my $min_set   = floor(($set_local-$hour_set)*60+0.5);
 
  if $min_rise >= 60 {
    $min_rise -= 60;
    $hour_rise += 1;
    $hour_rise -= 24 if $hour_rise >= 24;
  }
  if $min_set >= 60 {
    $min_set -= 60;
    $hour_set += 1;
    $hour_set -= 24 if $hour_set >= 24;
  }
 
  if $min_rise < 10 {
    $min_rise = sprintf( "%02d", $min_rise );
  }
  if $min_set < 10 {
    $min_set = sprintf( "%02d", $min_set );
  }
  $hour_rise = sprintf( "%02d", $hour_rise );
  $hour_set  = sprintf( "%02d", $hour_set );
  return "$hour_rise:$min_rise", "$hour_set:$min_set";
 
}

sub _helper($longitude, $latitude, $alt = -0.833, $offset = 0) {
    my $today = DateTime.now.local.Date;
    $today += $offset;

    my $toff = DateTime.new(year => $today.year, month => $today.month, day => $today.day).offset;
    return sunrise( $today, $longitude, $latitude, ( $toff / 3600 ), $alt );
}
 

sub sun_rise ($longitude, $latitude, $alt = -0.833, $offset = 0) is export {
    return (_helper($longitude, $latitude, $alt, $offset))[0]
}

sub sun_set ($longitude, $latitude, $alt = -0.833, $offset = 0) is export {
    return (_helper($longitude, $latitude, $alt, $offset))[1]
}
