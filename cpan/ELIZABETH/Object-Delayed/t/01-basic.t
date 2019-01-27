use v6.c;
use Test;
use Object::Delayed;

plan 17;

my @seen;

class Bar {
    has $.zop;
    submethod TWEAK() { @seen.push("Bar") }
}

class Foo {
    has $.zip = 42;
    submethod TWEAK() { @seen.push("Foo") }
    method Bar() { Bar.new( zop => $.zip ) }
}

# simple slack
my $foo = slack { Foo.new };
nok $foo.WHAT =:= Foo, 'did we get something else than Foo';

is +@seen, 0, 'no Foo object created yet';

is $foo.zip, 42, 'did we get the right bar';
isa-ok $foo, Foo, 'do we have a Foo object now';
is @seen, "Foo", 'did we create an object now';

# another simple slack
$foo = slack { Foo.new: zip => 666 }
nok $foo.WHAT =:= Foo, 'did we get something else than Foo again';
is $foo.zip, 666, 'did we get the right bar again';
isa-ok $foo, Foo, 'do we have a Foo object again';
is @seen, "Foo Foo", 'did we create an object again';

# stacked slacks
   $foo = slack { Foo.new: zip => 314 }
my $bar = slack { $foo.Bar }
nok $foo.WHAT =:= Foo, 'did we get something else than Foo yet again';
nok $bar.WHAT =:= Bar, 'did we get else then Bar';
is @seen, "Foo Foo", 'did we not create any real object again';

is $bar.zop, 314, 'did we get the right object and value';
isa-ok $foo, Foo, 'do we have a Foo object again';
isa-ok $bar, Bar, 'do we have a Bar object';
is @seen, "Foo Foo Foo Bar", 'did we not create any real object again';

# sink context
slack { Foo.new }
is @seen, "Foo Foo Foo Bar Foo", 'did we create a real object while sinking';

# vim: ft=perl6 expandtab sw=4
