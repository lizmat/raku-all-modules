# Test Geo::Ellipsoid load

use v6;
use Test;

#plan 21;
plan 47;

use Geo::Ellipsoid;

# This original Perl 5 test used the following test functions (the
# resulting Perl 6 versions are shown after the fat comma):
#
#   isa_ok => isa-ok
#   can_ok => can-ok
#
#  From the Perl 5 test file:
#    use Test::Number::Delta relative => 1e-6;
#  which translates ro:
my $rel-tol = 1e-6;

#BEGIN { use-ok('Geo::Ellipsoid'); }
use-ok('Geo::Ellipsoid');


my $e0 = Geo::Ellipsoid.new();
isa-ok($e0, 'Geo::Ellipsoid');
my $e1 = Geo::Ellipsoid.new(units => 'degrees');
isa-ok($e1, 'Geo::Ellipsoid');
my $e2 = Geo::Ellipsoid.new(distance_units => 'foot');
isa-ok($e2, 'Geo::Ellipsoid');
my $e3 = Geo::Ellipsoid.new(bearing => 1);
isa-ok($e3, 'Geo::Ellipsoid');
my $e4 = Geo::Ellipsoid.new(longitude => 1);
isa-ok($e4, 'Geo::Ellipsoid');


can-ok($e0, 'new');
can-ok($e0, 'set_units');
can-ok($e0, 'set_distance_unit');
can-ok($e0, 'set_ellipsoid');
can-ok($e0, 'set_custom_ellipsoid');
can-ok($e0, 'set_longitude_symmetric');
can-ok($e0, 'set_bearing_symmetric');
can-ok($e0, 'set_defaults');
can-ok($e0, 'scales');
can-ok($e0, 'range');
can-ok($e0, 'bearing');
can-ok($e0, 'at');
can-ok($e0, 'to');
can-ok($e0, 'displacement');
can-ok($e0, 'location');

#say "DEBUG early exit"; exit;

#=begin pod

my $e5 = Geo::Ellipsoid.new();

# check public methods
for @Geo::Ellipsoid::public_methods -> $m {
  #can-ok($e5.can($m), "public method '$m'");
  can-ok($e5, $m, "public method '$m'");
}

# check rw attributes
for @Geo::Ellipsoid::rw_attributes -> $a {
  my $val = $e5."$a"();
  if defined $val {
    ok(True, "attribute '$a'");
  }
  else {
    ok(False, "attribute '$a'");
  }
}

#=end pod
