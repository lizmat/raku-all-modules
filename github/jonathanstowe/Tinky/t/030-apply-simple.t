#!perl6

use v6;

use Test;

use Tinky;

my @states = <one two three four>.map({ Tinky::State.new(name => $_) });

my @transitions = @states.rotor(2 => -1).map(-> ($from, $to) { my $name = $from.name ~ '-' ~ $to.name; Tinky::Transition.new(:$from, :$to, :$name) });

class FooTest does Tinky::Object { }

my $obj = FooTest.new(state => @states[0]);

for @transitions -> $trans {
    for @transitions.grep({ $obj !~~ $_ }) -> $no-trans {
        throws-like { $obj.apply-transition($no-trans) }, X::InvalidTransition, "throws trying to apply wrong transition";
    }

    lives-ok { $obj.apply-transition($trans) }, "apply-transition with '{ $trans.name }' lives";
    is $obj.state, $trans.to, "and it is in the expected state";
}

$obj = FooTest.new;
throws-like {  $obj.apply-transition(@transitions[0]) }, X::NoState, "should throw X::NoState with apply-transition and state not set";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
