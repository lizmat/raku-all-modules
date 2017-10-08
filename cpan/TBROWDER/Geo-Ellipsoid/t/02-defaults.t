# Test Geo::Ellipsoid defaults

use v6;
use Test;

plan 192;

use Geo::Ellipsoid;

# This original Perl 5 test used the following test functions (the
# resulting Perl 6 versions are shown after the fat comma):
#
#   ok       => ok
#   delta_ok => is-approx($a, $b, :$rel-tol)
#
#  From the Perl 5 test file:
#    use Test::Number::Delta relative => 1e-6;
#  which translates to:
my $rel-tol = 1e-6;

# tests 1-6
my $e1 = Geo::Ellipsoid.new();
ok($e1.ellipsoid eq 'WGS84');
ok($e1.units eq 'radians');
ok($e1.distance_units eq 'meter');
ok($e1.longitude_sym == False);
ok($e1.latitude_sym); # should always be true
ok($e1.bearing_sym == False);
$e1.set_defaults(
    ellipsoid      => 'NAD27',
    units          => 'degrees',
    distance_units => 'kilometer',
    longitude_sym  => True,
    bearing_sym    => True
);

# tests 7-12
my $e2 = Geo::Ellipsoid.new();
ok($e2.ellipsoid eq 'NAD27');
ok($e2.units eq 'degrees');
ok($e2.distance_units eq 'kilometer');
ok({$e2.longitude_sym ?? True !! False});
ok($e2.latitude_sym); # should always be true
ok({$e2.bearing_sym ?? True !! False});

# tests 13-21
Geo::Ellipsoid.set_defaults(units=>'degrees', ellipsoid=>'EVEREST-1830');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'EVEREST-1830');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e3 = Geo::Ellipsoid.new();
ok($e3.defined);
ok($e3.isa('Geo::Ellipsoid'));
ok($e3.ellipsoid eq 'EVEREST-1830');
ok($e3.units eq 'degrees');
is-approx($e3.equatorial, 6377276.345, :$rel-tol);
is-approx($e3.polar, 6356075.41314024, :$rel-tol);
is-approx($e3.flattening, 0.00332444929666288, :$rel-tol);

# tests 22-30
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'HOUGH-1956');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'HOUGH-1956');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e4 = Geo::Ellipsoid.new();
ok($e4.defined);
ok($e4.isa('Geo::Ellipsoid'));
ok($e4.ellipsoid eq 'HOUGH-1956');
ok($e4.units eq 'degrees');
is-approx($e4.equatorial, 6378270, :$rel-tol);
is-approx($e4.polar, 6356794.34343434, :$rel-tol);
is-approx($e4.flattening, 0.00336700336700337, :$rel-tol);

# tests 31-39
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'HAYFORD');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'HAYFORD');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e5 = Geo::Ellipsoid.new();
ok($e5.defined);
ok($e5.isa('Geo::Ellipsoid'));
ok($e5.ellipsoid eq 'HAYFORD');
ok($e5.units eq 'degrees');
is-approx($e5.equatorial, 6378388, :$rel-tol);
is-approx($e5.polar, 6356911.94612795, :$rel-tol);
is-approx($e5.flattening, 0.00336700336700337, :$rel-tol);

# tests 40-48
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'AIRY-MODIFIED');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'AIRY-MODIFIED');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e6 = Geo::Ellipsoid.new();
ok(defined $e6);
ok($e6.isa('Geo::Ellipsoid'));
ok($e6.ellipsoid eq 'AIRY-MODIFIED');
ok($e6.units eq 'degrees');
is-approx($e6.equatorial, 6377340.189, :$rel-tol);
is-approx($e6.polar, 6356034.44793853, :$rel-tol);
is-approx($e6.flattening, 0.00334085064149708, :$rel-tol);

# tests 49-57
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'NWL-9D');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'NWL-9D');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e7 = Geo::Ellipsoid.new();
ok(defined $e7);
ok($e7.isa('Geo::Ellipsoid'));
ok($e7.ellipsoid eq 'NWL-9D');
ok($e7.units eq 'degrees');
is-approx($e7.equatorial, 6378145, :$rel-tol);
is-approx($e7.polar, 6356759.76948868, :$rel-tol);
is-approx($e7.flattening, 0.00335289186923722, :$rel-tol);

# tests 58-66
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'CLARKE-1880');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'CLARKE-1880');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e8 = Geo::Ellipsoid.new();
ok(defined $e8);
ok($e8.isa('Geo::Ellipsoid'));
ok($e8.ellipsoid eq 'CLARKE-1880');
ok($e8.units eq 'degrees');
is-approx($e8.equatorial, 6378249.145, :$rel-tol);
is-approx($e8.polar, 6356514.86954978, :$rel-tol);
is-approx($e8.flattening, 0.00340756137869933, :$rel-tol);

# tests 67-75
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'KRASSOVSKY-1938');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'KRASSOVSKY-1938');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e9 = Geo::Ellipsoid.new();
ok(defined $e9);
ok($e9.isa('Geo::Ellipsoid'));
ok($e9.ellipsoid eq 'KRASSOVSKY-1938');
ok($e9.units eq 'degrees');
is-approx($e9.equatorial, 6378245, :$rel-tol);
is-approx($e9.polar, 6356863.01877305, :$rel-tol);
is-approx($e9.flattening, 0.00335232986925913, :$rel-tol);

# tests 76-84
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'FISHER-1968');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'FISHER-1968');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e10 = Geo::Ellipsoid.new();
ok(defined $e10);
ok($e10.isa('Geo::Ellipsoid'));
ok($e10.ellipsoid eq 'FISHER-1968');
ok($e10.units eq 'degrees');
is-approx($e10.equatorial, 6378150, :$rel-tol);
is-approx($e10.polar, 6356768.33724438, :$rel-tol);
is-approx($e10.flattening, 0.00335232986925913, :$rel-tol);

# tests 85-93
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'AUSTRALIAN');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'AUSTRALIAN');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e11 = Geo::Ellipsoid.new();
ok(defined $e11);
ok($e11.isa('Geo::Ellipsoid'));
ok($e11.ellipsoid eq 'AUSTRALIAN');
ok($e11.units eq 'degrees');
is-approx($e11.equatorial, 6378160, :$rel-tol);
is-approx($e11.polar, 6356774.71919531, :$rel-tol);
is-approx($e11.flattening, 0.00335289186923722, :$rel-tol);

# tests 94-102
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'EVEREST-MODIFIED');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'EVEREST-MODIFIED');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e12 = Geo::Ellipsoid.new();
ok(defined $e12);
ok($e12.isa('Geo::Ellipsoid'));
ok($e12.ellipsoid eq 'EVEREST-MODIFIED');
ok($e12.units eq 'degrees');
is-approx($e12.equatorial, 6377304.063, :$rel-tol);
is-approx($e12.polar, 6356103.03899315, :$rel-tol);
is-approx($e12.flattening, 0.00332444929666288, :$rel-tol);

# tests 103-111
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'WGS72');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'WGS72');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e13 = Geo::Ellipsoid.new();
ok(defined $e13);
ok($e13.isa('Geo::Ellipsoid'));
ok($e13.ellipsoid eq 'WGS72');
ok($e13.units eq 'degrees');
is-approx($e13.equatorial, 6378135, :$rel-tol);
is-approx($e13.polar, 6356750.52001609, :$rel-tol);
is-approx($e13.flattening, 0.0033527794541675, :$rel-tol);

# tests 112-120
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'FISHER-1960');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'FISHER-1960');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e14 = Geo::Ellipsoid.new();
ok(defined $e14);
ok($e14.isa('Geo::Ellipsoid'));
ok($e14.ellipsoid eq 'FISHER-1960');
ok($e14.units eq 'degrees');
is-approx($e14.equatorial, 6378166, :$rel-tol);
is-approx($e14.polar, 6356784.28360711, :$rel-tol);
is-approx($e14.flattening, 0.00335232986925913, :$rel-tol);

# tests 122-129
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'BESSEL-1841');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'BESSEL-1841');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e15 = Geo::Ellipsoid.new();
ok(defined $e15);
ok($e15.isa('Geo::Ellipsoid'));
ok($e15.ellipsoid eq 'BESSEL-1841');
ok($e15.units eq 'degrees');
is-approx($e15.equatorial, 6377397.155, :$rel-tol);
is-approx($e15.polar, 6356078.96281819, :$rel-tol);
is-approx($e15.flattening, 0.00334277318217481, :$rel-tol);

# tests 130-138
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'AIRY');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'AIRY');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e16 = Geo::Ellipsoid.new();
ok(defined $e16);
ok($e16.isa('Geo::Ellipsoid'));
ok($e16.ellipsoid eq 'AIRY');
ok($e16.units eq 'degrees');
is-approx($e16.equatorial, 6377563.396, :$rel-tol);
is-approx($e16.polar, 6356256.90923729, :$rel-tol);
is-approx($e16.flattening, 0.00334085064149708, :$rel-tol);

# tests 139-147
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'GRS80');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'GRS80');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e17 = Geo::Ellipsoid.new();
ok(defined $e17);
ok($e17.isa('Geo::Ellipsoid'));
ok($e17.ellipsoid eq 'GRS80');
ok($e17.units eq 'degrees');
is-approx($e17.equatorial, 6378137, :$rel-tol);
is-approx($e17.polar, 6356752.31414035, :$rel-tol);
is-approx($e17.flattening, 0.00335281068118367, :$rel-tol);

# tests 148-156
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'IAU76');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'IAU76');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e18 = Geo::Ellipsoid.new();
ok(defined $e18);
ok($e18.isa('Geo::Ellipsoid'));
ok($e18.ellipsoid eq 'IAU76');
ok($e18.units eq 'degrees');
is-approx($e18.equatorial, 6378140, :$rel-tol);
is-approx($e18.polar, 6356755.28815753, :$rel-tol);
is-approx($e18.flattening, 0.00335281317789691, :$rel-tol);

# tests 157-165
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'SOUTHAMERICAN-1969');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'SOUTHAMERICAN-1969');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e19 = Geo::Ellipsoid.new();
ok(defined $e19);
ok($e19.isa('Geo::Ellipsoid'));
ok($e19.ellipsoid eq 'SOUTHAMERICAN-1969');
ok($e19.units eq 'degrees');
is-approx($e19.equatorial, 6378160, :$rel-tol);
is-approx($e19.polar, 6356774.71919531, :$rel-tol);
is-approx($e19.flattening, 0.00335289186923722, :$rel-tol);

# tests 166-174
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'WGS84');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'WGS84');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e20 = Geo::Ellipsoid.new();
ok(defined $e20);
ok($e20.isa('Geo::Ellipsoid'));
ok($e20.ellipsoid eq 'WGS84');
ok($e20.units eq 'degrees');
is-approx($e20.equatorial, 6378137, :$rel-tol);
is-approx($e20.polar, 6356752.31424518, :$rel-tol);
is-approx($e20.flattening, 0.00335281066474748, :$rel-tol);

# tests 175-183
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'SOVIET-1985');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'SOVIET-1985');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e21 = Geo::Ellipsoid.new();
ok(defined $e21);
ok($e21.isa('Geo::Ellipsoid'));
ok($e21.ellipsoid eq 'SOVIET-1985');
ok($e21.units eq 'degrees');
is-approx($e21.equatorial, 6378136, :$rel-tol);
is-approx($e21.polar, 6356751.30156878, :$rel-tol);
is-approx($e21.flattening, 0.00335281317789691, :$rel-tol);

# tests 184-192
Geo::Ellipsoid.set_defaults(units=>'degrees',ellipsoid=>'NAD27');
ok(%Geo::Ellipsoid::defaults<ellipsoid> eq 'NAD27');
ok(%Geo::Ellipsoid::defaults<units> eq 'degrees');
my $e22 = Geo::Ellipsoid.new();
ok(defined $e22);
ok($e22.isa('Geo::Ellipsoid'));
ok($e22.ellipsoid eq 'NAD27');
ok($e22.units eq 'degrees');
is-approx($e22.equatorial, 6378206.4, :$rel-tol);
is-approx($e22.polar, 6356583.79999999, :$rel-tol);
is-approx($e22.flattening, 0.00339007530392992, :$rel-tol);
