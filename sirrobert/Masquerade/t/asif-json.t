use v6;
use Test;
plan 3;

# Load the module
use Masquerade;

# Predeclare a reusable variable for the expected jsonification.
my $expected;

# A utility sub to test.  Pass in the object, expected result, and test
# description to run the test.
sub test_json ($obj, Str $expected, Str $explanation) {
  ok ($obj but AsIf::JSON eq $expected), $explanation;
}

#####
# Basic perl objects.  It's worth noting that the tests for some things
# (e.g. hashes) are a little bit brittle right now:  they assume a
# garaunteed order, but order isn't garaunteed.  I may have to enforce some
# sort of order in the jsonification.

# Simple hash
test_json {one => 1, two => 'pickle'},
  '{ "one" : 1, "two" : "pickle" }',
  'simple hash';

# Hash with nested hashes and arrays.
test_json {hash => {a => 1}, array => [<foo bar>]},
  '{ "hash" : { "a" : 1 }, "array" : [ "foo", "bar" ] }',
  'hash with nested hashes and arrays';

##
# Try a more complex perl object.
class Weather::Phenomenon {
  has $!id;
  has $.name;
  has $.description;
  has %.properties;
  has @.affects;
};

my $tornado = Weather::Phenomenon.new(
  id          => 123,
  name        => 'tornado',
  description => 'a twister!',
  properties  => {
    twistiness  => 100,
    windiness   => 88,
    size        => 40,
  }, 
  affects     => <Houses Barns Couches Chickens>
);

$expected = '{ "name" : "tornado", "description" : "a twister!", "properties" : { "twistiness" : 100, "windiness" : 88, "size" : 40 }, "affects" : [ "Houses", "Barns", "Couches", "Chickens" ] }';

test_json $tornado, $expected, 'perl object properties render to json objects';






