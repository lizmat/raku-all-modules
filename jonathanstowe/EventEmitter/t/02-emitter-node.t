#!perl6

use v6;

use lib "lib";

use Test;

use EventEmitter::Node;

class Foo does EventEmitter::Node {
}

ok(my $obj = Foo.new, "create an object that consumes the role");

ok($obj.^does(EventEmitter::Node), "and it does the role");

my $test_handled = False;
my $boom_handled = False;

ok(my $tap = $obj.on('test', { pass("event got handled"); $test_handled = True  }), "set handler on 'test' event");

isa_ok($tap, Tap, "on returned a Tap okay");

$obj.on("boom", { fail("different named event didn't get handled"); $boom_handled = True });

lives_ok { $obj.emit('test', "yahaha") }, "emit to 'test' works";

ok($test_handled, "and test handler was right");
ok(!$boom_handled, "and the other one wasn't called");

dies_ok({ $obj.on("foo","bar") }, "dies with a non-code argument");

done();
