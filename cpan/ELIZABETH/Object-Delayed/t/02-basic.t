use v6.c;
use Test;
use Object::Delayed;

plan 15;

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

# Set up the values for checking later.  Note that each piece of code waits
# one second.  So this test-file should run in at least 5 seconds.  But
# because the catchup executes asychronously, the tests are typically done
# in about 1.3 seconds.
my $foo1 = catchup { sleep 1; Foo.new };
my $foo2 = catchup { sleep 1; Foo.new: zip => 666 }
my $foo3 = catchup { sleep 1; Foo.new: zip => 314 }
my $bar3 = catchup { sleep 1; $foo3.Bar }

# simple catchup
nok $foo1.WHAT =:= Foo, 'did we get something else than Foo';

is $foo1.zip, 42, 'did we get the right bar';
isa-ok $foo1, Foo, 'do we have a Foo object now';

# another simple catchup
nok $foo2.WHAT =:= Foo, 'did we get something else than Foo again';
is $foo2.zip, 666, 'did we get the right bar again';
isa-ok $foo2, Foo, 'do we have a Foo object again';

# stacked catchups
nok $foo3.WHAT =:= Foo, 'did we get something else than Foo yet again';
nok $bar3.WHAT =:= Bar, 'did we get else then Bar';

is $bar3.zop, 314, 'did we get the right object and value';
isa-ok $foo3, Foo, 'do we have a Foo object again';
isa-ok $bar3, Bar, 'do we have a Bar object';

# all values requested, so all async should be done
is @seen.grep("Foo").elems, 3, "did we see 3 Foo's";
is @seen.grep("Bar").elems, 1, "did we see 1 Bar";

# sink context
catchup { Foo.new }

is @seen.grep("Foo").elems, 4, "did we now see 4 Foo's";
is @seen.grep("Bar").elems, 1, "did we still see 1 Bar";

# vim: ft=perl6 expandtab sw=4
