#!perl6

use v6;

use Test;

use Tinky;

my @states = <one two three four>.map({ Tinky::State.new(name => $_) });

for @states -> $state {
    $state.enter-supply.tap({does-ok $_, Tinky::Object, "got an Object from enter supply"; });
    $state.leave-supply.tap({ does-ok $_, Tinky::Object, "got an Object from leave supply" });
}

my @transitions = @states.rotor(2 => -1).map(-> ($from, $to) { my $name = $from.name ~ '-' ~ $to.name; Tinky::Transition.new(:$from, :$to, :$name) });

class FooTest does Tinky::Object { }

throws-like { Tinky::Workflow.new.states }, X::NoTransitions, ".states throws if there aren't any transitions";

my Tinky::Workflow $wf;

lives-ok { $wf = Tinky::Workflow.new(:@transitions) }, "create new workflow with transitions";

my Int $applied = 0;

lives-ok { $wf.applied-supply.act(-> $obj { does-ok $obj, Tinky::Object, "applied-supply got a Tinky::Object"; $applied++ }) }, "tap the workflow applied-supply";


my @enter;
my @leave;
my @trans-events;
my Bool $final = False;

my $obj = FooTest.new();
$obj.apply-workflow($wf);

lives-ok { $wf.enter-supply.act( -> $ ( $state, $object) { @enter.push($state.name); }) }, "set up tap on enter-supply";
lives-ok { $wf.enter-supply.act( -> $ ( $state, $object) {isa-ok $state, Tinky::State }) }, "set up tap on enter-supply";
lives-ok { $wf.leave-supply.act( -> $ ( $state, $object) { @leave.push($state.name); }) }, "set up tap on leave-supply";
lives-ok { $wf.leave-supply.act(-> $ ( $state, $obj ) { isa-ok $state, Tinky::State } ) }, "set up tap on leave-supply";
lives-ok { $wf.transition-supply.act( -> $ ( $transition, $object ) { isa-ok $transition, Tinky::Transition; does-ok $object, Tinky::Object; @trans-events.push($transition.name) } ) }, "set up tap on transition-supply";
lives-ok { $wf.final-supply.act( -> $ ( $state, $object ) { isa-ok $state, Tinky::State; does-ok $object, Tinky::Object; is $wf.transitions-for-state($state).elems, 0, "really is a final state"; $final = True } ) }, "set up tap on final-supply";

for @states -> $state {
    my $old-state = $obj.state;
    lives-ok { $obj.state = $state }, "set state to '{ $state.name }' by assigning to current-state";
    ok $obj.state ~~ $state , "and it is the expected state";
}

is-deeply @enter, [<two three four>], "got the right enter events";
is-deeply @leave, [<one two three>], "got the right leave events";
is-deeply @trans-events, [ <one-two two-three three-four> ], "got the right transition events";

ok $final, "and got the final event";
is $applied, 1, "and we saw the application of the workflow";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
