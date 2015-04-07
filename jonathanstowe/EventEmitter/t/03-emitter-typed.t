#!perl6

use v6;

use lib "lib";

use Test;

use EventEmitter::Typed;

class Foo does EventEmitter::Typed {
}

# class to test with

class MyEvent {
}

class BadEvent {
}

ok(my $obj = Foo.new, "create an object that consumes the role");

ok($obj.^does(EventEmitter::Typed), "and it does the role");

my $test_handled = False;
my $boom_handled = False;

ok(my $tap = $obj.on(MyEvent, { pass("event got handled"); $test_handled = True  }), "set handler on 'test' event");

isa_ok($tap, Tap, "on returned a Tap okay");

$obj.on(BadEvent, { fail("different named event didn't get handled"); $boom_handled = True });

lives_ok { $obj.emit(MyEvent.new) }, "emit with MyEvent works";

ok($test_handled, "and test handler was right");
ok(!$boom_handled, "and the other one wasn't called");

dies_ok({ $obj.on(MyEvent,"bar") }, "dies with a non-code argument");
dies_ok({ $obj.on("foo",{ say $_ }) }, "dies with a non-type argument");

done();
