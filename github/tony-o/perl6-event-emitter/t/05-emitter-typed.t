#!perl6

use v6;

use lib "lib";

use Test;

plan 14;

use Event::Emitter::Role::Typed;

class Foo does Event::Emitter::Role::Typed {
}

# class to test with

class MyEvent {
}

class BadEvent {
}

ok(my $obj = Foo.new, "create an object that consumes the role");

ok($obj.^does(Event::Emitter::Role::Typed), "and it does the role");

my $test_handled = False;
my $boom_handled = False;

ok(my $tap = $obj.on(MyEvent, { pass("event got handled"); $test_handled = True  }), "set handler on 'test' event");

$obj.on(BadEvent, { fail("different named event didn't get handled"); $boom_handled = True });

lives-ok { $obj.emit(MyEvent.new) }, "emit with MyEvent works";

ok($test_handled, "and test handler was right");
ok(!$boom_handled, "and the other one wasn't called");

dies-ok({ $obj.on(MyEvent,"bar") }, "dies with a non-code argument");
dies-ok({ $obj.on("foo",{ say $_ }) }, "dies with a non-type argument");

class Bar does Event::Emitter::Role::Typed[:threaded] {
}

ok($obj = Bar.new, "create an object that consumes the role (threaded)");

ok($obj.^does(Event::Emitter::Role::Typed), "and it does the role (threaded)");


ok($tap = $obj.on(MyEvent, { pass("event got handled (threaded)"); }), "set handler on 'test' event");

$obj.on(BadEvent, { fail("different named event didn't get handled (threaded)"); });

lives-ok { $obj.emit(MyEvent.new) }, "emit with MyEvent works (threaded)";


