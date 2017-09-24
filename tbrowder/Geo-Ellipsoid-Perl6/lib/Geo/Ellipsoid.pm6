#	Geo::Ellipsoid
#
#	This package implements an Ellipsoid class to perform latitude
#	and longitude calculations on the surface of an ellipsoid.
#
#	This is a Perl conversion of existing Fortran code (see
#	ACKNOWLEDGEMENTS) and the author of this class makes no
#	claims of originality. Nor can he even vouch for the
#	results of the calculations, although they do seem to
#	work for him and have been tested against other methods.

use v6;

#use Math::Trig;
use Geo::Ellipsoid::Utils;

unit class Geo::Ellipsoid:auth<github:tbrowder>;

# export a debug var for users
our $DEBUG = False;
BEGIN {
    if %*ENV<GEO_ELLIPSOID_DEBUG> {
	$DEBUG = True;
    }
    else {
	$DEBUG = False;
    }
}

# constants for this module
constant $eps            = 1.0e-23;
constant $max_loop_count = 20;

=begin pod

=head1 NAME

Geo::Ellipsoid - Longitude and latitude calculations using an ellipsoid model.

=head1 VERSION

Version 1.0.0, not yet released.

=end pod

=begin pod

=head1 SYNOPSIS

  use Geo::Ellipsoid;
  $geo = Geo::Ellipsoid.new(ellipsoid => 'NAD27', units => 'degrees');
  @origin = (37.619002, -122.374843);    # SFO
  @dest = (33.942536, -118.408074);      # LAX
  ($range, $bearing) = $geo.to(@origin, @dest);
  ($lat,$lon) = $geo.at(@origin, 2000, 45.0);
  ($x, $y) = $geo.displacement(@origin, $lat, $lon);
  @pos = $geo.location($lat, $lon, $x, $y);

=head1 DESCRIPTION

Geo::Ellipsoid performs geometrical calculations on the surface of
an ellipsoid. An ellipsoid is a three-dimensional object formed from
the rotation of an ellipse about one of its axes. The approximate
shape of the earth is an ellipsoid, so Geo::Ellipsoid can accurately
calculate distance and bearing between two widely-separated locations
on the earth's surface.

The shape of an ellipsoid is defined by the lengths of its
semi-major and semi-minor axes. The shape may also be specifed by
the flattening ratio C<f> as:

    f = (semi-major - semi-minor) / semi-major

which, since f is a small number, is normally given as the reciprocal
of the flattening C<1/f>.

The shape of the earth has been surveyed and estimated differently
at different times over the years. The two most common sets of values
used to describe the size and shape of the earth in the United States
are 'NAD27', dating from 1927, and 'WGS84', from 1984. United States
Geological Survey topographical maps, for example, use one or the
other of these values, and commonly-available Global Positioning
System (GPS) units can be set to use one or the other.
See L<"DEFINED ELLIPSOIDS"> below for the ellipsoid survey values
that may be selected for use by Geo::Ellipsoid.

=end pod

# arrays for use during testing
our @rw_attributes
  = <
ellipsoid
units
distance_units
longitude_sym
bearing_sym
equatorial
polar
flattening
eccentricity
conversion
    >;

our @public_methods
  = <
at
displacement
bearing
location
new
range
scales
set_bearing_symmetric
set_custom_ellipsoid
set_defaults
set_distance_unit
set_ellipsoid
set_longitude_symmetric
set_units
to
to-range
    >;

our @private_methods
  = <
_forward
_inverse
normalize-input-angles
normalize-output-angle
    >;

# these may disappear with proper Perl 6 class def
our %defaults = (
  ellipsoid      => 'WGS84',
  units          => 'radians',
  distance_units => 'meter',
  longitude_sym  => False,
  bearing_sym    => False,
);

our %distance = (
  'foot'      => 0.3048,
  'kilometer' => 1_000,
  'meter'     => 1.0,
  'mile'      => 1_609.344,
  'nm'        => 1_852,
);

# set of ellipsoids that can be used.
# values are
#  1) a = semi-major (equatorial) radius of Ellipsoid
#  2) 1/f = reciprocal of flattening (f), the ratio of the semi-minor
#     (polar) radius to the semi-major (equatorial) axis, or
#     polar radius = equatorial radius * (1 - f)

our %ellipsoids = (
    'AIRY'               => [ 6377563.396, 299.3249646     ],
    'AIRY-MODIFIED'      => [ 6377340.189, 299.3249646     ],
    'AUSTRALIAN'         => [ 6378160.0,   298.25          ],
    'BESSEL-1841'        => [ 6377397.155, 299.1528128     ],
    'CLARKE-1880'        => [ 6378249.145, 293.465         ],
    'EVEREST-1830'       => [ 6377276.345, 300.8017        ],
    'EVEREST-MODIFIED'   => [ 6377304.063, 300.8017        ],
    'FISHER-1960'        => [ 6378166.0,   298.3           ],
    'FISHER-1968'        => [ 6378150.0,   298.3           ],
    'GRS80'              => [ 6378137.0,   298.25722210088 ],
    'HOUGH-1956'         => [ 6378270.0,   297.0           ],
    'HAYFORD'            => [ 6378388.0,   297.0           ],
    'IAU76'              => [ 6378140.0,   298.257         ],
    'KRASSOVSKY-1938'    => [ 6378245.0,   298.3           ],
    'NAD27'              => [ 6378206.4,   294.9786982138  ],
    'NWL-9D'             => [ 6378145.0,   298.25          ],
    'SOUTHAMERICAN-1969' => [ 6378160.0,   298.25          ],
    'SOVIET-1985'        => [ 6378136.0,   298.257         ],
    'WGS72'              => [ 6378135.0,   298.26          ],
    'WGS84'              => [ 6378137.0,   298.257223563   ],
);

=begin pod

=head1 CONSTRUCTOR

=head2 new

The new() constructor may be called with a hash list to set the value of the
ellipsoid to be used, the value of the units to be used for angles and
distances, and whether or not the output range of longitudes and bearing
angles should be symmetric around zero or always greater than zero.
The initial default constructor is equivalent to the following:

    my $geo = Geo::Ellipsoid.new(
      ellipsoid      => 'WGS84',
      units          => 'radians' ,
      distance_units => 'meter',
      longitude_sym  => False,
      bearing_sym    => False,
   );

The constructor arguments may be of any case and, with the exception of
the ellipsoid value, abbreviated to their first three characters.
Thus, (UNI => 'DEG', DIS => 'FEE', Lon => 1, ell => 'NAD27', bEA => 0)
is valid.

=end pod

# define the class attributes
has $.ellipsoid           is rw;
has $.units               is rw;
has $.distance_units      is rw;
has Bool $.longitude_sym  is rw;
has Bool $.bearing_sym    is rw;
has Bool $.latitude_sym   is readonly;  # NOTE!!

# following were implicit in original Perl 5 version, some (all?) should be private
has $.equatorial   is rw;
has $.polar        is rw;
has $.flattening   is rw;
has $.eccentricity is rw;
has $.conversion   is rw;

# the above are set during construction
submethod BUILD(
  # set defaults here
  :$!ellipsoid      = %defaults<ellipsoid>,      # 'WGS84',
  :$!units          = %defaults<units>,          # 'radians',
  :$!distance_units = %defaults<distance_units>, # 'meter',
  :$!longitude_sym  = %defaults<longitude_sym>,  # False,
  :$!latitude_sym   = True,                      # always true
  :$!bearing_sym    = %defaults<bearing_sym>,    # False,

  # these depend on values above
  :$!equatorial,
  :$!polar,
  :$!flattening,
  :$!eccentricity,
  :$!conversion,
               ) {
  say "Setting units..." if $DEBUG;
  self.set_units($!units);

  say "Setting ellipsoid..." if $DEBUG;
  self.set_ellipsoid($!ellipsoid);

  say "Setting distance_units..." if $DEBUG;
  self.set_distance_unit($!distance_units);

  say "Setting longitude sym..." if $DEBUG;
  self.set_longitude_symmetric($!longitude_sym);

  say "Setting bearing sym..." if $DEBUG;
  self.set_bearing_symmetric($!bearing_sym);

  say
    "Ellipsoid(units=>{self.units},distance_units=>" ~
    "{self.distance_units},ellipsoid=>{self.ellipsoid}," ~
    "longitude_sym=>{self.longitude_sym},bearing_sym=>{self.bearing_sym})" if $DEBUG;
}

=begin comment

TODO PUT IN PROPER P6 FORMAT AS USED IN THE CODE
sub new
{
  my ($class, %args) = @_;
  my $self = {%defaults};
  print "new: @_\n" if $DEBUG;
  foreach my $key (keys %args) {
    my $val = $args{$key};
    if ($key =~ /^ell/i) {
      $self.{ellipsoid} = uc $args{$key};
    } elsif ($key =~ /^uni/i) {
      $self.{units} = $args{$key};
    } elsif ($key =~ /^dis/i) {
      $self.{distance_units} = $args{$key};
    } elsif ($key =~ /^lon/i) {
      $self.{longitude} = $args{$key};
    } elsif ($key =~ /^bea/i) {
      $self.{bearing} = $args{$key};
    } else {
      die("Unknown argument: $key => $args{$key}");
    }
  }

  set_units($self,$self.{units});
  set_ellipsoid($self,$self.{ellipsoid});
  set_distance_unit($self,$self.{distance_units});
  set_longitude_symmetric($self,$self.{longitude});
  set_bearing_symmetric($self,$self.{bearing});
  print
    "Ellipsoid(units=>$self.{units},distance_units=>" .
    "$self.{distance_units},ellipsoid=>$self.{ellipsoid}," .
    "longitude=>$self.{longitude},bearing=>$self.{bearing})\n" if $DEBUG;
  bless $self,$class;
  return $self;
}

=end comment

=begin pod

=head1 METHODS

=head2 set_units

Set the angle units used by the Geo::Ellipsoid object. The units may
also be set in the constructor of the object. The allowable values are
'degrees' or 'radians'. The default is 'radians'. The units value is
not case sensitive and may be abbreviated to 3 letters. The units of
angle apply to both input and output latitude, longitude, and bearing
values.

    $geo.set_units('degrees');

=end pod

# public method
method set_units($units)
{
    if $units ~~ m:i/deg/ {
        self.units = 'degrees';
    }
    elsif $units ~~ m:i/rad/ {
        self.units = 'radians';
    }
    else {
        die("Invalid units specifier '$units' - please use either " ~
            "degrees or radians (the default)") unless $units ~~ m:i/rad/;
    }
}

=begin pod

=head2 set_distance_unit

Set the distance unit used by the Geo::Ellipsoid object. The unit of
distance may also be set in the constructor of the object. The recognized
values are 'meter', 'kilometer', 'mile', 'nm' (nautical mile), or 'foot'.
The default is 'meter'. The value is not case sensitive and may be
abbreviated to 3 letters.

    $geo.set_distance_unit('kilometer');

For any other unit of distance not recogized by this method, pass a
numerical argument representing the length of the distance unit in
meters. For example, to use units of furlongs, call

    $geo.set_distance_unit(201.168);

The distance conversion factors used by this module are as follows:

  Unit          Units per meter
  --------      ---------------
  foot             0.3048
  kilometer     1000.0
  mile          1609.344
  nm            1852.0

=end pod

# public
method set_distance_unit($unit)
{
    say "distance unit = '$unit'" if $DEBUG;

    my $conversion = 0;

    if $unit {
        for %distance.kv -> $key, $val { # each?) {
            say "key = '$key'" if $DEBUG;
            my $re = $key.substr(0, 3); #substr($key,0,3);
            say "trying ($key, $re, $val)" if $DEBUG;
            if $unit ~~ m:i/^$re/ {
                self.distance_units = $unit;
                $conversion = $val;

	        # finish iterating to reset 'each' function call
	        #while (%distance.each) {}
	        last;
            }
        }

        if $conversion == 0 {
            if $unit.WHAT ~~ Num {
                $conversion = $unit;
            }
            else {
                die("Unknown argument to set_distance_unit: $unit\nAssuming meters");
                $conversion = 1.0;
            }
        }
    }
    else {
         die("Missing or undefined argument to set_distance_unit: " ~
         "$unit\nAssuming meters");
         $conversion = 1.0;
    }

    self.conversion = $conversion;
}

=begin pod

=head2 set_ellipsoid

Set the ellipsoid to be used by the Geo::Ellipsoid object. See
L<"DEFINED ELLIPSOIDS"> below for the allowable values. The value
may also be set by the constructor. The default value is 'WGS84'.

    $geo.set_ellipsoid('NAD27');

=end pod

# public
method set_ellipsoid($ell)
{
  my $ellipsoid = uc $ell || %defaults<ellipsoid>;
  say "  set ellipsoid to $ellipsoid" if $DEBUG;
  unless (%ellipsoids{$ellipsoid}:exists) {
    die("Ellipsoid $ellipsoid does not exist - please use " ~
      "set_custom_ellipsoid to use an ellipsoid not in valid set");
  }
  self.ellipsoid = $ellipsoid;
  my ($major, $recip) = @(%ellipsoids{$ellipsoid});
  self.equatorial = $major;
  if $recip == 0 {
    say "# WARNING: Infinite flattening specified by ellipsoid--assuming a sphere.";
    self.polar        = self.equatorial;
    self.flattening   = 0;
    self.eccentricity = 0;
  }
  else {
    self.flattening   = (1.0 / %ellipsoids{$ellipsoid}[1]);
    self.polar        = self.equatorial * (1.0  - self.flattening);
    self.eccentricity = sqrt(2.0 * self.flattening -
      (self.flattening * self.flattening));
  }
}

=begin pod

=head2 set_custom_ellipsoid

Sets the ellipsoid parameters to the specified major semiaxis and
reciprocal flattening. A zero value for the reciprocal flattening
will result in a sphere for the ellipsoid, and a warning message
will be issued.

    $geo.set_custom_ellipsoid('sphere', 6378137, 0);

=end pod

# public
method set_custom_ellipsoid($nam, $major, $recip = 0)
{
  my $name           = uc $nam;
  %ellipsoids{$name} = [ $major, $recip ];
  self.set_ellipsoid($name);
}

=begin pod

=head2 set_longitude_symmetric

If called with no argument or a true argument, sets the range of output
values for longitude to be in the range [-pi,+pi) radians.  If called with
a false or undefined argument, sets the output angle range to be
[0,2*pi) radians.

    $geo.set_longitude_symmetric(True);

=end pod

# public
multi method set_longitude_symmetric($sym)
{
  # see if argument is true
  if $sym {
    # yes -- set to true
    self.longitude_sym = True;
  }
  else {
    # no -- set to false
    self.longitude_sym = False;
  }
}

multi method set_longitude_symmetric()
{
  # no arg -- set to true
  self.longitude_sym = True;
}

=begin pod

=head2 set_bearing_symmetric

If called with no argument or a true argument, sets the range of output
values for bearing to be in the range [-pi,+pi) radians.  If called with
a false or undefined argument, sets the output angle range to be
[0,2*pi) radians.

    $geo.set_bearing_symmetric(True);

=end pod

# public
multi method set_bearing_symmetric($sym)
{
  # see if argument is true
  if $sym {
    # yes -- set to true
    self.bearing_sym = True;
  }
  else {
    # no -- set to false
    self.bearing_sym = False;
  }
}

multi method set_bearing_symmetric()
{
  # no arg -- set to true
  self.bearing_sym = True;
}

=begin pod

=head2 set_defaults

Sets the defaults for the new method. Call with key, value pairs similar to
new.

    $Geo::Ellipsoid.set_defaults(
      units          => 'degrees',
      ellipsoid      => 'GRS80',
      distance_units => 'kilometer',
      longitude_sym  => True,
      bearing_sym    => False,
   );

Keys and string values (except for the ellipsoid identifier) may be shortened
to their first three letters and are case-insensitive:

    $Geo::Ellipsoid.set_defaults(
      uni => 'deg',
      ell => 'GRS80',
      dis => 'kil',
      lon => False,
      bea => False,
   );

=end pod

# public
method set_defaults(*%a)
{
  my %args = %a;
  for %args.kv -> $key, $val {
    if $key ~~ m:i/^ell/ {
      %defaults<ellipsoid> = uc $val;
    }
    elsif $key ~~ m:i/^uni/ {
      %defaults<units> = $val;
    }
    elsif $key ~~ m:i/^dis/ {
      %defaults<distance_units> = $val;
    }
    elsif $key ~~ m:i/^lon/ {
      %defaults<longitude_sym> = $val;
    }
    elsif $key ~~ m:i/^bea/ {
      %defaults<bearing_sym> = $val;
    }
    else {
      die("Geo::Ellipsoid::set_defaults called with invalid key: $key");
    }
  }
  say "Defaults set to (%defaults<ellipsoid>,%defaults<units>)"
    if $DEBUG;
}

=begin pod

=head2 scales

Returns a list consisting of the distance unit per angle of latitude
and longitude (degrees or radians) at the specified latitude.
These values may be used for fast approximations of distance
calculations in the vicinity of some location.

    ($lat_scale, $lon_scale) = $geo.scales($lat0);
    $x = $lon_scale * ($lon - $lon0);
    $y = $lat_scale * ($lat - $lat0);

=end pod

# public
method scales($lat is copy)
{
  # convert to radians for calculations
  $lat = deg2rad($lat) if self.units eq 'degrees';

  my $aa = self.equatorial;
  my $bb = self.polar;
  my $a2 = $aa*$aa;
  my $b2 = $bb*$bb;
  my $d1 = $aa * cos($lat);
  my $d2 = $bb * sin($lat);
  my $d3 = $d1*$d1 + $d2*$d2;
  my $d4 = sqrt($d3);
  my $n1 = $aa * $bb;

  # units of distance per rad:
  my $latscl = ($n1 * $n1) / ($d3 * $d4 * self.conversion);
  my $lonscl = ($aa * $d1) / ($d4 * self.conversion);

  if $DEBUG {
    say "lat=$lat, aa=$aa, bb=$bb\nd1=$d1, d2=$d2, d3=$d3, d4=$d4";
    say "latscl=$latscl, lonscl=$lonscl";
  }

  if self.units eq 'degrees' {
    # convert back to distance per degree for output
    # dist/rad  / deg/rad => dist/rad X rad/deg => dist/deg
    $latscl /= $degrees_per_radian;
    $lonscl /= $degrees_per_radian;
  }
  return ($latscl, $lonscl);
}

=begin pod

=head2 range

Returns the range in distance units between two specified locations given
as latitude, longitude pairs.

    my $dist = $geo.range($lat1, $lon1, $lat2, $lon2);
    my $dist = $geo.range(|@origin, |@destination);

=end pod

# public
method range($lat1, $lon1, $lat2, $lon2)
{
  my @a = normalize-input-angles(self.units, $lat1, $lon1, $lat2, $lon2);
  my ($range, $bearing) = self._inverse(|@a);
  say "inverse(|@a) returns($range, $bearing)" if $DEBUG;
  return $range;
}

=begin pod

=head2 bearing

Returns the bearing in degrees or radians from the first location to
the second. Zero bearing is true north.

    my $bearing = $geo.bearing($lat1, $lon1, $lat2, $lon2);

=end pod

# public
method bearing($lat1, $lon1, $lat2, $lon2)
{
  my @a = normalize-input-angles(self.units, $lat1, $lon1, $lat2, $lon2);
  my ($range, $bearing) = self._inverse(|@a);

  if $DEBUG {
      say "DEBUG: =======================";
      say "\$range, \$bearing";
      say $range.WHAT;
      say $bearing.WHAT;
  }

  say "inverse(|@a) returns($range, $bearing)" if $DEBUG;

  my $t = $bearing;

  if $DEBUG {
      say "\$t";
      say $t.WHAT;
  }

  $bearing = normalize-output-angle($bearing, :symmetric(self.bearing_sym), :units(self.units));

  if $DEBUG {
      say "orig bearing: $t";
      say "normalized bearing: $bearing";
      say "\$bearing";
      say $bearing.WHAT;
      say "normalize-output-angles($t) returns($bearing)";
  }

  return $bearing;
}

=begin pod

=head2 at

Returns the list (latitude,longitude) in degrees or radians that is a
specified range and bearing from a given location.

    my ($lat2, $lon2) = $geo.at($lat1, $lon1, $range, $bearing);

=end pod

# public
method at($lat1, $lon1, $range, $bearing)
{
  my ($lat, $lon, $az) = normalize-input-angles(self.units, $lat1, $lon1, $bearing);
  say "at($lat,$lon,$range,$az)" if $DEBUG;
  my ($lat2, $lon2) = self._forward($lat, $lon, $range, $az);
  say "_forward returns ($lat2, $lon2)" if $DEBUG;
  $lat2 = normalize-output-angle($lat2, :symmetric(self.latitude_sym), :units(self.units));
  $lon2 = normalize-output-angle($lon2, :symmetric(self.longitude_sym), :units(self.units));

  #say "DEBUG: \$lat2:";
  #say $lat2.WHAT;
  #say "DEBUG: \$lon2:";
  #say $lon2.WHAT;

  return ($lat2, $lon2);
}

=begin pod

=head2 to

Returns (range, bearing) between two specified locations.

    my ($dist, $theta) = $geo.to($lat1, $lon1, $lat2, $lon2);

=end pod

# public
method to($lat1, $lon1, $lat2, $lon2 --> List)
{
  my @a = normalize-input-angles(self.units, $lat1, $lon1, $lat2, $lon2);
  say "to(self.units,|@a)" if $DEBUG;
  my ($range, $bearing) = self._inverse(|@a);
  say "to: inverse(|@a) returns($range, $bearing)" if $DEBUG;
  $bearing = normalize-output-angle($bearing, :symmetric(self.bearing_sym), :units(self.units));
  return ($range, $bearing);
}

=begin pod

=head2 to_range

Returns range between two specified locations.

    my $dist = $geo.to-range($lat1, $lon1, $lat2, $lon2);

=end pod

method to-range($lat1, $lon1, $lat2, $lon2 --> Real)
{
  my @a = normalize-input-angles(self.units, $lat1, $lon1, $lat2, $lon2);
  my $range = self._inverse(|@a);
  say "to(self.units, $range)" if $DEBUG;
  say "to: inverse(|@a) returns($range)" if $DEBUG;
  return $range;
}

=begin pod

=head2 displacement

Returns the (x,y) displacement in distance units between the two specified
locations.

    my ($x, $y) = $geo.displacement($lat1, $lon1, $lat2, $lon2);

NOTE: The x and y displacements are only approximations and only valid
between two locations that are fairly near to each other. Beyond 10 kilometers
or more, the concept of X and Y on a curved surface loses its meaning.

=end pod

# public
method displacement(*@args --> List)
{
  my @a = @args;
  say "displacement(",join(',',@a),"" if $DEBUG;
  @a = normalize-input-angles(self.units, |@a);
  say "call self._inverse(|@a)" if $DEBUG;
  my ($range, $bearing) = self._inverse(|@a);
  say "disp: _inverse(@a) returns ($range,$bearing)" if $DEBUG;

  # check angle units:
  if self.units eq 'degrees' {
      $bearing = deg2rad $bearing;
  }

  my $x = $range * sin($bearing);
  my $y = $range * cos($bearing);
  return ($x,$y);
}

=begin pod

=head2 location

Returns the list (latitude,longitude) of a location at a given (x,y)
displacement from a given location.

	#my @loc = $geo.location($lat, $lon, $x, $y);
	my @loc = $geo.location($x, $y);

=end pod

# public
method location($lat, $lon, $x, $y)
{
  my $range    = sqrt($x*$x+ $y*$y);
  my $bearing  = atan2($x,$y);
  $bearing     = rad2deg($bearing) if self.units eq 'degrees';
  #say "location($lat, $lon, $x, $y, $range, $bearing)" if $DEBUG;
  say "location($x, $y, $range, $bearing)" if $DEBUG;
  return self.at($lat, $lon, $range, $bearing);
}

########################################################################
#
#      internal functions
#
#	inverse
#
#	Calculate the displacement from origin to destination.
#	The input to this subroutine is
#	  (latitude-1, longitude-1, latitude-2, longitude-2) in radians.
#
#	Return the results as the list (range,bearing) with range in the
#	current specified distance unit and bearing in radians.
#
# pseudo "private" method
method _inverse($lat1 is copy, $lon1 is copy, $lat2 is copy, $lon2 is copy)
{
    #die "FATAL: angle units need to be in radians, units: {self.units}" if self.units eq 'degrees';
    say "_inverse($lat1, $lon1, $lat2, $lon2)" if $DEBUG;
    if self.units eq 'degrees' {
        $lat1 = deg2rad $lat1;
        $lon1 = deg2rad $lon1;
        $lat2 = deg2rad $lat2;
        $lon2 = deg2rad $lon2;
    } 

    my $a = self.equatorial;
    my $f = self.flattening;

    my $r = 1.0 - $f;
    my $tu1 = $r * sin($lat1) / cos($lat1);
    my $tu2 = $r * sin($lat2) / cos($lat2);
    my $cu1 = 1.0 / (sqrt(($tu1*$tu1) + 1.0));
    my $su1 = $cu1 * $tu1;
    my $cu2 = 1.0 / (sqrt(($tu2*$tu2) + 1.0));
    my $s = $cu1 * $cu2;
    my $baz = $s * $tu2;
    my $faz = $baz * $tu1;
    my $dlon = $lon2 - $lon1;

    if $DEBUG {
	printf "lat1=%.8f, lon1=%.8f\n", $lat1, $lon1;
	printf "lat2=%.8f, lon2=%.8f\n", $lat2, $lon2;
	printf "r=%.8f, tu1=%.8f, tu2=%.8f\n", $r, $tu1, $tu2;
	printf "faz=%.8f, dlon=%.8f\n", $faz, $dlon;
    }

    my $x = $dlon;
    my $cnt = 0;
    say "enter loop:" if $DEBUG;
    my ($c2a, $c, $cx, $cy, $cz, $d, $del, $e, $sx, $sy, $y);
    repeat {
        printf "  x=%.8f\n", $x if $DEBUG;
        $sx = sin($x);
        $cx = cos($x);
        $tu1 = $cu2*$sx;
        $tu2 = $baz - ($su1*$cu2*$cx);

        printf "    sx=%.8f, cx=%.8f, tu1=%.8f, tu2=%.8f\n",
        $sx, $cx, $tu1, $tu2 if $DEBUG;

        $sy = sqrt($tu1*$tu1 + $tu2*$tu2);
        $cy = $s*$cx + $faz;
        $y = atan2($sy,$cy);
        my $sa;
        if $sy == 0.0 {
            $sa = 1.0;
        } 
        else {
            $sa = ($s*$sx) / $sy;
        }

        printf "    sy=%.8f, cy=%.8f, y=%.8f, sa=%.8f\n", $sy, $cy, $y, $sa 
            if $DEBUG;

        $c2a = 1.0 - ($sa*$sa);
        $cz = $faz + $faz;
        if $c2a > 0.0 {
            $cz = ((-$cz)/$c2a) + $cy;
        }
        $e = (2.0 * $cz * $cz) - 1.0;
        $c = (((((-3.0 * $c2a) + 4.0)*$f) + 4.0) * $c2a * $f)/16.0;
        $d = $x;
        $x = (($e * $cy * $c + $cz) * $sy * $c + $y) * $sa;
        $x = (1.0 - $c) * $x * $f + $dlon;
        $del = $d - $x;

        if $DEBUG {
            printf "    c2a=%.8f, cz=%.8f\n", $c2a, $cz;
            printf "    e=%.8f, d=%.8f\n", $e, $d;
            printf "    (d-x)=%.8g\n", $del;
        }

    } while ((abs($del) > $eps) && (++$cnt <= $max_loop_count));

    $faz = atan2($tu1,$tu2);
    $baz = atan2($cu1*$sx,($baz*$cx - $su1*$cu2)) + pi;
    $x = sqrt(((1.0/($r*$r)) -1.0) * $c2a+1.0) + 1.0;
    $x = ($x-2.0)/$x;
    $c = 1.0 - $x;
    $c = (($x*$x)/4.0 + 1.0)/$c;
    $d = ((0.375*$x*$x) - 1.0)*$x;
    $x = $e*$cy;

    if $DEBUG {
        printf "e=%.8f, cy=%.8f, x=%.8f\n", $e, $cy, $x;
        printf "sy=%.8f, c=%.8f, d=%.8f\n", $sy, $c, $d;
        printf "cz=%.8f, a=%.8f, r=%.8f\n", $cz, $a, $r;
    }

    $s = 1.0 - $e - $e;
    $s = (((((((($sy * $sy * 4.0) - 3.0) * $s * $cz * $d/6.0) - $x) *
    $d /4.0) + $cz) * $sy * $d) + $y) * $c * $a * $r;

    printf "s=%.8f\n", $s if $DEBUG;

    # REPLACE THIS WITH FUNCTION CALL!!
    # adjust azimuth to (0,360) or (-180,180) as specified
    # units MUST be radians at this point
    if self.bearing_sym {
        $faz += $twopi if $faz < -(pi);
        $faz -= $twopi if $faz >= pi;
    } 
    else {
        $faz += $twopi if $faz < 0;
        $faz -= $twopi if $faz >= $twopi;
    }

    if self.units eq 'degrees' {
        $faz = rad2deg $faz;
    } 

    # return result
    #my @disp = (($s/self.conversion), $faz);
    my @disp = ($s/self.conversion, $faz);
    print "disp = (@disp)\n" if $DEBUG;
    return (|@disp);
} # _inverse

#	_forward
#
#	Calculate the location (latitude, longitude) of a point
#	given a starting point and a displacement from that
#	point as (range, bearing) where range is in the class's
#       current units and bearing is in degrees from true north.
#
# pseudo "private" method
method _forward($lat1 is copy, $lon1 is copy, $range, $bearing is copy)
{
  #die "FATAL: need to use radians for trig funcs, units are: {self.units}" if self.units eq 'degrees';
  if self.units eq 'degrees' {
      $lat1    = deg2rad $lat1;
      $lon1    = deg2rad $lon1;
      $bearing = deg2rad $bearing;
  }

  if $DEBUG {
    printf "_forward(lat1=%.8f,lon1=%.8f,range=%.8f,bearing=%.8f)\n",
      $lat1, $lon1, $range, $bearing;
  }

  my $eps = 0.5e-13;

  my $a = self.equatorial;
  my $f = self.flattening;
  my $r = 1.0 - $f;
  my $tu = $r * sin($lat1) / cos($lat1);
  my $faz = $bearing;
  my $s = self.conversion * $range;

  if $DEBUG {
      say "DEBUG: \$faz = $faz";
      say $faz.WHAT;
  }

  my $sf = sin($faz);
  my $cf = cos($faz);

  my $baz = 0.0;
  $baz = 2.0 * atan2($tu,$cf) if $cf != 0.0;

  my $cu = 1.0 / sqrt(1.0 + $tu*$tu);
  my $su = $tu * $cu;
  my $sa = $cu * $sf;
  my $c2a = 1.0 - ($sa*$sa);
  my $x = 1.0 + sqrt((((1.0/($r*$r)) - 1.0)*$c2a) +1.0);
  $x = ($x-2.0)/$x;
  my $c = 1.0 - $x;
  $c = ((($x*$x)/4.0) + 1.0)/$c;
  my $d = $x * ((0.375*$x*$x)-1.0);
  $tu = (($s/$r)/$a)/$c;
  my $y = $tu;

  if $DEBUG {
    printf "r=%.8f, tu=%.8f, faz=%.8f\n", $r, $tu, $faz;
    printf "baz=%.8f, sf=%.8f, cf=%.8f\n", $baz, $sf, $cf;
    printf "cu=%.8f, su=%.8f, sa=%.8f\n", $cu, $su, $sa;
    printf "x=%.8f, c=%.8f, y=%.8f\n", $x, $c, $y;
  }

  my ($cy, $cz, $e, $sy);
  repeat {
    $sy = sin($y);
    $cy = cos($y);
    $cz = cos($baz+$y);
    $e = (2.0*$cz*$cz)-1.0;
    $c = $y;
    $x = $e * $cy;
    $y = (2.0 * $e) - 1.0;
    $y = ((((((((($sy*$sy*4.0)-3.0)*$y*$cz*$d)/6.0)+$x)*$d)/4.0)-$cz)*$sy*$d) +
      $tu;
    } while (abs($y-$c) > $eps);

  $baz = ($cu*$cy*$cf) - ($su*$sy);
  $c = $r*sqrt(($sa*$sa) + ($baz*$baz));
  $d = $su*$cy + $cu*$sy*$cf;
  my $lat2 = atan2($d,$c);
  $c = $cu*$cy - $su*$sy*$cf;
  $x = atan2($sy*$sf,$c);
  $c = (((((-3.0*$c2a)+4.0)*$f)+4.0)*$c2a*$f)/16.0;
  $d = (((($e*$cy*$c) + $cz)*$sy*$c)+$y)*$sa;
  my $lon2 = $lon1 + $x - (1.0-$c)*$d*$f;
  #$baz = atan2($sa,$baz) + pi;

  if self.units eq 'degrees' {
      $lat2 = rad2deg $lat2;
      $lon2 = rad2deg $lon2;
  }

  # return result
  return ($lat2, $lon2);

} # _forward

=begin pod

=head1 DEFINED ELLIPSOIDS

The following ellipsoids are defined in Geo::Ellipsoid, with the
semi-major axis in meters and the reciprocal flattening as shown.
The default ellipsoid is WGS84.

    Ellipsoid        Semi-Major Axis (m.)     1/Flattening
    ---------        -------------------     ---------------
    AIRY                 6377563.396         299.3249646
    AIRY-MODIFIED        6377340.189         299.3249646
    AUSTRALIAN           6378160.0           298.25
    BESSEL-1841          6377397.155         299.1528128
    CLARKE-1880          6378249.145         293.465
    EVEREST-1830         6377276.345         290.8017
    EVEREST-MODIFIED     6377304.063         290.8017
    FISHER-1960          6378166.0           298.3
    FISHER-1968          6378150.0           298.3
    GRS80                6378137.0           298.25722210088
    HOUGH-1956           6378270.0           297.0
    HAYFORD              6378388.0           297.0
    IAU76                6378140.0           298.257
    KRASSOVSKY-1938      6378245.0           298.3
    NAD27                6378206.4           294.9786982138
    NWL-9D               6378145.0           298.25
    SOUTHAMERICAN-1969   6378160.0           298.25
    SOVIET-1985          6378136.0           298.257
    WGS72                6378135.0           298.26
    WGS84                6378137.0           298.257223563

=head1 LIMITATIONS

The methods should not be used on points which are too near the poles
(above or below 89 degrees), and should not be used on points which
are antipodal, i.e., exactly on opposite sides of the ellipsoid. The
methods will not return valid results in these cases.

=head1 ACKNOWLEDGEMENTS

The conversion algorithms used here are Perl translations of Fortran
routines written by LCDR S<L. Pfeifer> NGS Rockville MD that implement
S<T. Vincenty's> Modified Rainsford's method with Helmert's elliptical
terms as published in "Direct and Inverse Solutions of Ellipsoid on
the Ellipsoid with Application of Nested Equations", S<T. Vincenty,>
Survey Review, April 1975.

The Fortran source code files inverse.for and forward.for
may be obtained from

    ftp://ftp.ngs.noaa.gov/pub/pcsoft/for_inv.3d/source/

=head1 AUTHOR

Jim Gibson, C<< <Jim@Gibson.org> >>
Tom Browder, C<< <tom.browder@gmail.com> >>

=head1 BUGS

See LIMITATIONS, above.

Please enter any bugs or feature requests to the issues 
 through the web interface at
L<https://github.com/tbrowder/Geo-Ellipsoid-Perl6>.

=head1 COPYRIGHT & LICENSE

Copyright (c) 2005-2008 Jim Gibson, all rights reserved.
Copyright (c) 2015-2017 Tom Browder, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

Geo::Distance, Geo::Ellipsoids

=end pod
