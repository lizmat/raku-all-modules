#!/usr/bin/env perl6

use v6;

use Test;

use Tinky::JSON;

my $json = $*PROGRAM.parent.child('data/ticket.json').slurp;
my $workflow = Tinky::JSON::Workflow.from-json($json);

for $workflow.states -> $state {
    ok my $found-state = $workflow.state($state.name), "can find '{ $state.name }' by name";
    ok $found-state === $state, "and it is the right one";
    isa-ok $workflow.enter-supply($state.name), Supply, "got enter-supply for that state";
    isa-ok $workflow.leave-supply($state.name), Supply, "got leave-supply for that state";
    is-deeply $workflow.transitions-for-state($state.name), $workflow.transitions-for-state($found-state), "transitions for state returns the same with a string";
}

for $workflow.transitions -> $transition {
    ok $workflow.transition($transition.name).elems > 0, "got at least one transition with the name '{ $transition.name }'";
    ok $workflow.find-transition($transition.from.name, $transition.to.name) === $workflow.find-transition($transition.from, $transition.to), "find-transition { $transition.name }";
    ok $workflow.transitions-for-state($transition.from.name).elems, "transitions for state on the from state must return at least one";
}

throws-like { $workflow.transitions-for-state('Xtotally-bogus-stateX') }, Tinky::JSON::X::NoState, "got expected exception for bogus state";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
