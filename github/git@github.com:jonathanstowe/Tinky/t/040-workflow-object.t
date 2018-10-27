#!perl6

use v6;

use Test;

use Tinky;

my @states = <one two three four>.map({ Tinky::State.new(name => $_) });

my @transitions = @states.rotor(2 => -1).map(-> ($from, $to) { my $name = $from.name ~ '-' ~ $to.name; Tinky::Transition.new(:$from, :$to, :$name) });

class FooTest does Tinky::Object { }

throws-like { Tinky::Workflow.new.states }, X::NoTransitions, ".states throws if there aren't any transitions";

my Tinky::Workflow $wf;

lives-ok { $wf = Tinky::Workflow.new(:@transitions) }, "create new workflow with transitions";
is $wf.transitions.elems, @transitions.elems, "and got the right number of transitions";
is $wf.states.elems, @states.elems, "and calculated the right number of states";

for @states[0 .. 2] -> $state {
    is $wf.transitions-for-state($state).elems, 1, "got a transition for State '{ $state.name }'";
    ok $wf.transitions-for-state($state)[0].from ~~ $state, "and it is the the transition we expected";
}

for @states.rotor(2 => -1) -> ($from, $to) {
    ok $wf.find-transition($from, $to), "find-transition '{ $from.name }' -> '{ $to.name }'";
}

my $obj = FooTest.new(state => @states[0]);


throws-like { $obj.transitions }, X::NoWorkflow, "'transitions' throws without workflow";
throws-like { $obj.transition-for-state(@states[0]) }, X::NoWorkflow, "'transition-for-state' throws without workflow";

lives-ok { $obj.apply-workflow($wf) }, "apply workflow";

is $obj.transitions.elems, 1, "got one transition for current state";
ok $obj.transition-for-state(@states[1]).defined, "and there is a transition for the next state";
nok $obj.transition-for-state(@states[2]).defined, "and there is no transition for the another state";
nok $obj.transition-for-state(@states[3]).defined, "and there is no transition for the another another state";

for @transitions -> $trans {
    can-ok $obj, $trans.name, "Object has '{ $trans.name }' method";
    for @transitions.grep({ $_.name ne $trans.name }) -> $no-trans {
        throws-like { $obj."{ $no-trans.name }"() }, X::InvalidTransition, "'{ $no-trans.name }' method throws";
    }
    lives-ok { $obj."{ $trans.name }"() }, "'{ $trans.name }' method works";
    is $obj.state, $trans.to, "and it got changed to the '{ $trans.to.name }' state";
}

$obj = FooTest.new();
$obj.apply-workflow($wf);

for @states -> $state {
    lives-ok { $obj.state = $state }, "set state to '{ $state.name }' by assigning to current-state";
    ok $obj.state ~~ $state , "and it is the expected state";
}

subtest {

    my $wf = Tinky::Workflow.new(:@transitions, initial-state => @states[0]);
    ok $wf.initial-state ~~ @states[0], "just check the initial-state got set";
    my $obj = FooTest.new();
    #lives-ok { 
    $obj.apply-workflow($wf); # }, "apply workflow with an initial-state (object has no state)";
    ok $obj.state ~~ @states[0], "and the new object now has that state";
    my $new-state = Tinky::State.new(name => 'new-state');
    $obj = FooTest.new(state => $new-state);
    lives-ok { $obj.apply-workflow($wf) }, "apply workflow with an initial-state (object has an existing state)";
    ok $obj.state ~~ $new-state, "and it retained the original state";
    nok $obj.state ~~ @states[0], "just check the comparison";

}, "initial state on Workflow";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
