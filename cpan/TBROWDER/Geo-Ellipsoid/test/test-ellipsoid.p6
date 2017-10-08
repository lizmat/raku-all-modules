#!/usr/bin/env perl6
#
#	test_ellipsoid.pl
#
#	Test Geo::Ellipsoid.pm module coordinate transformations

#use v6;

#require '../lib/Geo/Ellipsoid.pm';

#use lib <../lib ../lib/Geo>;
#use blib './lib';
use Geo::Ellipsoid;
use Geo::Ellipsoid::GenFuncs :ALL; #('to_decimal', 'to_hms');

#sub MAIN ($debug, $xdebug);

my $twopi = 2 * pi;
my $halfpi = pi/2;
my $degrees_per_radian = 180.0/pi;
my $degree = pi/180.0;

# arg/option handling
sub MAIN (Bool :d(:$debug),
	  Bool :x(:$xdebug),
	  Bool :s(:$sdebug),
          Bool :p(:$pdebug),
          Bool :t(:$tdebug),
         );

my $usage = "Usage: $*PROGRAM.basename -p | -t [-d, -x, -s]";
if !$tdebug && !$pdebug {
  say $usage;
  exit;
}

if ($xdebug) {
  $Geo::Ellipsoid::DEBUG = 1;
}

test-private-methods if $pdebug;

say "Enter test-ellipsoid\n";
say "Using Geo::Ellipsoid version 1.12";

print "WGS84 ellipsoid values:\n";
my $earth = Geo::Ellipsoid.new(
  units     => 'degrees',
  ellipsoid => 'WGS84',
);

printf "    Equatorial radius = %.10f\n", $earth.equatorial;
printf "         Polar radius = %.10f\n", $earth.polar;

my $ef = $earth.flattening;
my $rf = 1.0 / $ef;
printf   "           Flattening = %.16f\n", $ef;
printf   "         Eccentricity = %.16f\n", $earth.eccentricity;
printf   "Reciprocal flattening = %.8f\n", $rf;

# print displacements between various locations
print "\nResults for various locations:\n\n";
my @dfw_arp  = (Angle(32,53,45.42),Angle(-97,2,13.92));
my @ffc_orig = (Angle(32,52,44.02),Angle(-97,1,48.29));
my @ord_orig = (Angle(41,58,43.48),Angle(-87,54,11.31));

my @c1 = (Angle(0,0,0),Angle(0,0,0));
my @c2 = (Angle(90,0,0),Angle(0,0,0));
my @c3 = (Angle(0,0,0),Angle(90,0,0));
my @c4 = (Angle(0,0,0),Angle(89,0,0));
my @c5 = (Angle(-1,0,0),Angle(90,0,0));
my @c6 = (Angle(0,0,0),Angle(-90,0,0));
my @c7 = (Angle(1,0,0),Angle(-90,0,0));

my @ord_9l =  (Angle(42, 0,19.51), Angle(-87,55,36.17));
my @ord_27r = (Angle(42, 0,19.83), Angle(-87,53,57.15));
my @ord_10c = (Angle(41,58, 6,28), Angle(-87,55,52,65));
my @ord_28c = (Angle(41,58, 6,98), Angle(-87,53,30, 2));

print_dist(|@ord_orig,|@ord_9l);

if ($sdebug) {
  say "DEBUG: early exit.";
  exit;;
}

print_dist(|@ord_9l,|@ord_27r);

print_vector(
  32, 53, 45.42, -97, 2, 13.92,
  32, 52, 44.02, -97, 1, 48.29
);

print_dist(|@dfw_arp,|@ffc_orig);
print_dist(|@c1,|@c1);

print_dist(|@c2,|@c2);
print_dist(|@c3,|@c3);
print_dist(|@c4,|@c4);
print_dist(|@c5,|@c5);
print_dist(|@c6,|@c6);
print_dist(|@c7,|@c7);

print_dist(|@c1,|@c2);
print_dist(|@c1,|@c3);
print_dist(|@c1,|@c4);
print_dist(|@c1,|@c5);
print_dist(|@c1,|@c6);
print_dist(|@c1,|@c7);

print_dist(|@c2,|@c3);
print_dist(|@c2,|@c4);
print_dist(|@c2,|@c5);
print_dist(|@c2,|@c6);
print_dist(|@c2,|@c7);

print_dist(|@c3,|@c4);
print_dist(|@c3,|@c5);
print_dist(|@c3,|@c6);
print_dist(|@c3,|@c7);

print_dist(|@c4,|@c5);
print_dist(|@c4,|@c6);
print_dist(|@c4,|@c7);

print_dist(|@c5,|@c6);
print_dist(|@c5,|@c7);

print_dist(|@c6,|@c7);

print_target(
  32, 53, 45.42, -97, 2, 13.92,
  2005.3871, 160.5960
);

# print latlon coefficients at selected latitudes
print "\nPrint Latitude and Longitude scale factors (meters per degree):\n\n";
print "+----------------------------------------+\n";
print "| Latitude |    F(Lat)    |    F(Lon)    |\n";
print "|----------|--------------|--------------|\n";
loop (my $l = 0; $l <= 90; $l++) {
  print_latlon_scale($l);
}
print "+----------------------------------------+\n";

exit(0);

sub print_latlon_scale($deg)
{
  print "print_latlon_scale($deg)\n" if $debug;
  my ($r_lat, $r_lon) = $earth.scales($deg);

  printf "| %8.4f | %12.4f | %12.4f |\n", $deg, $r_lat, $r_lon;
}

sub print_displacement($east, $north)
{
  my $range = sqrt($east*$east + $north*$north);
  my $bearing = atan2($north,$east);
  my $deg = $bearing * $degrees_per_radian;
  print "displacement = ($east,$north), r=$range, az=$bearing = $deg deg.\n";
}

sub print_vector($lat1deg, $lat1min, $lat1sec,
      $lon1deg, $lon1min, $lon1sec,
      $lat2deg, $lat2min, $lat2sec,
      $lon2deg, $lon2min, $lon2sec)
{
  my $lat1 = Angle($lat1deg,$lat1min,$lat1sec);
  my $lon1 = Angle($lon1deg,$lon1min,$lon1sec);
  my $lat2 = Angle($lat2deg,$lat2min,$lat2sec);
  my $lon2 = Angle($lon2deg,$lon2min,$lon2sec);

  my @here = ($lat1, $lon1);
  my @there = ($lat2, $lon2);

  print "Print range and bearing from:\n";
  print "({$lat1deg}d {$lat1min}m {$lat1sec})-(" ~
    "{$lon1deg}d {$lon1min}m {$lon1sec}) ";
  printf "[%.8f,%.8f] to\n", $lat1, $lon1;
  print
  "({$lat2deg}d {$lat2min}m {$lat2sec})-({$lon2deg}d {$lon2min}m {$lon2sec}) ";
  printf "[%.8f,%.8f]\n", $lat2, $lon2;

  print_dist(|@here,|@there);
}

sub print_dist($lat1, $lon1, $lat2, $lon2)
{
  my $ellipsoid = Geo::Ellipsoid.new(uni=>'radians',ell=>'WGS84');
  my ($dlat1, $dlon1, $dlat2, $dlon2) = map({ $_ * $degrees_per_radian },
    ($lat1, $lon1, $lat2, $lon2));

  printf "Here   = [%.12f,%.12f]\n", $dlat1, $dlon1;
  printf "There  = [%.12f,%.12f]\n", $dlat2, $dlon2;

  my @d = $ellipsoid.displacement($lat1, $lon1, $lat2, $lon2);
  my ($range, $bearing) = $ellipsoid.to($lat1, $lon1, $lat2, $lon2);
  my @loc = $ellipsoid.location($lat1, $lon1, $range, $bearing);
  $bearing *= $degrees_per_radian;
  print "displacement() returns (@d)\n" if $debug;

  printf "Range  = %.4f m., bearing = %.4f deg.\n", $range, $bearing;
  printf "East   = %.4f m., north = %.4f m.\n", @d;
  printf "There2 = [%.12f,%.12f]\n", map({ $_ * $degrees_per_radian }, @loc);
  print "\n";
}

sub print_target($lat1deg, $lat1min, $lat1sec,
      $lon1deg, $lon1min, $lon1sec,
      $range, $degrees)
{
  my $lat1 = Angle($lat1deg,$lat1min,$lat1sec);
  my $lon1 = Angle($lon1deg,$lon1min,$lon1sec);

  my @here = ($lat1, $lon1);
  my $ellipsoid = Geo::Ellipsoid.new(ellip=>'WGS84');

  my $radians = $degrees / $degrees_per_radian;
  my $x = $range*sin($radians);
  my $y = $range*cos($radians);

  my @d = ($x,$y);

  my @there = $ellipsoid.at(|@here,|@d);

  printf "Starting at (%.8f,%.8f)\n", @here;
  printf "and going (x=%.4f m.,y=%.4f m.)\n", @d;
  printf "or (%.4f  m.,%.4f deg.)\ngives (%.8f,%.8f)\n", $range, $degrees,
    @there;
}

sub print_all_ellipsoids
{
  #while ((my ($ell, $aref) = %Geo::Ellipsoid::ellipsoids.each)) {
  for (%Geo::Ellipsoid::ellipsoids.kv) -> $ell, $aref {
    print_ellipsoid_values($ell);
  }
  print_ellipsoid_values('WGS84');
}

sub print_ellipsoid_values($ell)
{
  print "$ell ellipsoid values:\n";
  my $earth = Geo::Ellipsoid.new(
    units => 'degrees',
    ellipsoid => 'WGS84',
    debug => $debug
 );

  printf "    Equatorial radius = %.10f\n", $earth.equatorial;
  printf "         Polar radius = %.10f\n", $earth.polar;

  my $ef = $earth.flattening;
  my $rf = 1.0 / $ef;
  printf   "           Flattening = %.16f\n", $ef;
  printf   "         Eccentricity = %.16f\n", $earth.eccentricity;
  printf   "Reciprocal flattening = %.8f\n\n", $rf;
}

sub Angle($deg = 0, $min = 0, $sec = 0,
          $csec = 0 # optional 100th's of a second
)
{

  my $frac = ($min + (($sec + ($csec/100.0))/60.0))/60.0;
  my $angle = $deg;
  print "  angle=$angle, frac=$frac\n" if $debug;
  if ($angle < 0) {
    $angle += 360.0 - $frac;
  } else {
    $angle += $frac;
  }
  print "  angle.frac = $angle\n" if $debug;
  my $angrad = $angle/$degrees_per_radian;
  die "!!!" if !defined $angrad;
  return $angrad;
}

sub polar($x, $y)
{
  my $range = sqrt($x*$x + $y*$y);
  my $bearing = $halfpi - atan2($y,$x);
  return ($range, $bearing);
}

sub test-private-methods {
  say "in test-private-methods";

  my $o = Geo::Ellipsoid.new();

  my $_forward = $o.^private_method_table{'_forward'};

  my ($lat, $lon, $rg, $bg);

  # case 1
  $lat = 90;
  $lon =  0;
  $rg = 10001965.7292; # m
  $bg = 180; # deg
  my ($lat2, $lon2) = $o.$_forward($lat, $lon, $rg, $bg);
  say "lat2 = $lat2 (should be 0)";
  say "lon2 = $lon2 (should be 0)";

  # case 2
  $lat = to_decimal('n32', 33, 33.33);
  $lon = to_decimal('e33', 33, 33.33);
  $rg = 100000;
  $bg = 90;
  ($lat2, $lon2) = $o.$_forward($lat, $lon, $rg, $bg);
  $lat2 = to_hms($lat2, 'lat');
  $lon2 = to_hms($lon2, 'lon');
  say "lat2 = $lat2 (should be 32 33 17.09706 North)";
  say "lon2 = $lon2 (should be 34 37 26.45221 East)";

  # case 3
  $lat = to_decimal('n32', 33, 33.33);
  $lon = to_decimal('e33', 33, 33.33);
  $rg = 100000;
  $bg = -90;
  ($lat2, $lon2) = $o.$_forward($lat, $lon, $rg, $bg);
  $lat2 = to_hms($lat2, 'lat');
  $lon2 = to_hms($lon2, 'lon');
  say "lat2 = $lat2 (should be 32 33 17.09706 North)";
  say "lon2 = $lon2 (should be 34 37 26.45221 West)";

=begin pod

_inverse
_normalize_input_angles
_normalize_output_angles

=end pod

  say "Normal exit.";
  exit;
}
