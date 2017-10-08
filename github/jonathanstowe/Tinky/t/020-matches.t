#!perl6

use v6;

use Test;

use Tinky;

throws-like { Tinky::State.new() }, X::Attribute::Required, "name is required";

my @states = <one two three four>.map({ Tinky::State.new(name => $_) });

my @transitions = @states.rotor(2 => -1).map(-> ($from, $to) { my $name = $from.name ~ '-' ~ $to.name; Tinky::Transition.new(:$from, :$to, :$name) });

ok @states[0] ~~ @states[0], "state matches itself";
ok @states[0] ~~ none(@states[1 .. 3]), "and none of the others";
ok @states[0] ~~ @transitions[0], "state matches the one transition that applies";
ok @states[0] ~~ none(@transitions[1,2]), "and none of the other";
ok @transitions[0] ~~ @states[0], "transition matches the state it can be applied";
ok @transitions[0] ~~ none(@states[1 .. 3]), "and not the rest";

class FooTest does Tinky::Object { }

my $obj = FooTest.new(state => @states[0]);

ok $obj ~~ @states[0], "object in a state matches that state";
ok $obj ~~ none(@states[1 .. 3]), "and none of the others";
ok @states[0] ~~ $obj, "and the other way round";
ok $obj ~~ @transitions[0], "object matches the right transition";
ok $obj ~~ none(@transitions[1,2]), "and none of the others";
ok @transitions[0] ~~ $obj, "transition matches object";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
