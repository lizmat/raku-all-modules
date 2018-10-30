use v6;

use Path::Map;

use Test;

plan 12;

my $mapper = Path::Map.new( 'foo/:foo/*/blah' => 'ABC' );

my $match = $mapper.lookup('foo/bar/baz/qux');

ok $match.handler ~~ 'ABC', 'Unambiguous slurpy';
ok $match.variables ~~ ( foo => 'bar' ), '.. has correct variables';
ok $match.values ~~ <bar baz qux>, '.. has correct values';

# Check conflicting paths, plus a catch-all
$mapper = Path::Map.new(
    'foo/*'        => 'Wild',
    'foo/:foo/bar' => 'Specific',
    '*'            => 'Default',
);

$match = $mapper.lookup('foo/foo/foo');
ok $match.handler ~ 'Wild', 'foo/*';
ok $match.variables ~~ (), '.. has empty variables';
ok $match.values ~~ <foo foo>, '.. has correct values';

$match = $mapper.lookup('foo/foo/bar');
ok $match.handler ~~ 'Specific', 'foo/:foo/bar';
ok $match.variables ~~ ( foo => 'foo' ), '.. has correct variables';
ok $match.values ~~ <foo> , '.. has correct values';

$match = $mapper.lookup('bar');
ok $match.handler ~~ 'Default', 'Catch-all';
ok $match.variables ~~ (), '.. has empty variables';
ok $match.values ~~ <bar>, '.. has correct values';
