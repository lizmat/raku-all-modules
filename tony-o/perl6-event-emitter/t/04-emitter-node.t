#!perl6

use v6;

use lib "lib";

use Test;

plan 14;

use Event::Emitter::Role::Node;

class Foo does Event::Emitter::Role::Node {
}

ok(my $obj = Foo.new, "create an object that consumes the role");

ok($obj.^does(Event::Emitter::Role::Node), "and it does the role");

my $test_handled = False;
my $boom_handled = False;

ok(my $tap = $obj.on('test', { pass("event got handled"); $test_handled = True  }), "set handler on 'test' event");


$obj.on("boom", { fail("different named event didn't get handled"); $boom_handled = True });

lives_ok { $obj.emit('test', "yahaha") }, "emit to 'test' works";

ok($test_handled, "and test handler was right");
ok(!$boom_handled, "and the other one wasn't called");

dies_ok({ $obj.on("foo","bar") }, "dies with a non-code argument");

class Bar does Event::Emitter::Role::Node[:threaded] {
}

ok($obj = Bar.new, "create an object that consumes the role (threaded)");

ok($obj.^does(Event::Emitter::Role::Node), "and it does the role (threaded)");

ok($tap = $obj.on('test', { pass("event got handled (threaded)"); }), "set handler on 'test' event (threaded)");


$obj.on("boom", { fail("different named event didn't get handled (threaded)"); });

lives_ok { $obj.emit('test', "yahaha") }, "emit to 'test' works (threaded)";

dies_ok({ $obj.on("foo","bar") }, "dies with a non-code argument (threaded)");

