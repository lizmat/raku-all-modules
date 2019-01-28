#!perl6

use v6;

use Test;

use Tinky;
use Tinky::JSON;

# This is basically the synopsis code instrumented to
# function as a test

lives-ok {

    my $json = $*PROGRAM.parent.child('data/ticket.json').slurp;
    my $workflow = Tinky::JSON::Workflow.from-json($json);

    class Ticket does Tinky::Object {
        has Str $.ticket-number = (^100000).pick.fmt("%08d");
        has Str $.owner;
    }

    my Bool $seen-entered = False;
    $workflow.enter-supply('rejected').act( -> $object { $seen-entered = True });

    my Bool $seen-transition-supply = False;

    $workflow.find-transition('in-progress', 'stalled').supply.act( -> $object { $seen-transition-supply = True });

    my Int $transition-count = 0;

    $workflow.transition-supply.act(-> ($trans, $object) { 
        isa-ok $trans, Tinky::Transition, "got a Transition"; 
        isa-ok $object, Ticket, "got a Ticket"; 
        ok $trans.to ~~ $object.state, "and the state is what we expected"; 
        $transition-count++;  
    });

    my Bool $seen-final = False;

    $workflow.final-supply.act(-> ( $state, $object) { $seen-final = True });

    my $ticket-a = Ticket.new(owner => "Operator A");

    $ticket-a.apply-workflow($workflow);

    $ticket-a.open;

    is $ticket-a.state, $workflow.state('open'), "In state 'open'";

    $ticket-a.take;

    is $ticket-a.state, $workflow.state('in-progress'), "In progress";

    is-deeply $ticket-a.next-states, [ $workflow.state('stalled'), $workflow.state('complete') ], "Next-states gives what expected";

    $ticket-a.state = $workflow.state('stalled');

    is $ticket-a.state.name, 'stalled', "Stalled";

    $ticket-a.reject;

    is $ticket-a.state, $workflow.state('rejected'), "Rejected";

    is $transition-count, 4, "saw the right number of transitions";
    ok $seen-transition-supply, "saw the event on stall transition";
    ok $seen-entered, "Saw an event on the entered supply";
    ok $seen-final, "Saw an event on the final supply";

}, "synopsis code runs ok";

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
