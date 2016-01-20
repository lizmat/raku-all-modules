#!perl6

use Test;

use Tinky;

# This is basically the synopsis code instrumented to
# function as a test

lives-ok {
class Ticket does Tinky::Object {
    has Str $.ticket-number = (^100000).pick.fmt("%08d");
    has Str $.owner;
}

my $state-new         = Tinky::State.new(name => 'new');
my $state-open        = Tinky::State.new(name => 'open');
my $state-rejected    = Tinky::State.new(name => 'rejected');
my $state-in-progress = Tinky::State.new(name => 'in-progress');
my $state-stalled     = Tinky::State.new(name => 'stalled');
my $state-complete    = Tinky::State.new(name => 'complete');

my Bool $seen-entered = False;
$state-rejected.enter-supply.act( -> $object { $seen-entered = True });

my $open              = Tinky::Transition.new(name => 'open', from => $state-new, to => $state-open);

my $reject-new        = Tinky::Transition.new(name => 'reject', from => $state-new, to => $state-rejected);
my $reject-open       = Tinky::Transition.new(name => 'reject', from => $state-open, to => $state-rejected);
my $reject-stalled    = Tinky::Transition.new(name => 'reject', from => $state-stalled, to => $state-rejected);
my $stall-open        = Tinky::Transition.new(name => 'stall', from => $state-open, to => $state-stalled);
my $stall-progress    = Tinky::Transition.new(name => 'stall', from => $state-in-progress, to => $state-stalled);

my Bool $seen-transition-supply = False;

$stall-progress.supply.act( -> $object { $seen-transition-supply = True });

my $unstall           = Tinky::Transition.new(name => 'unstall', from => $state-stalled, to => $state-in-progress);

my $take              = Tinky::Transition.new(name => 'take', from => $state-open, to => $state-in-progress);

my $complete-open     = Tinky::Transition.new(name => 'complete', from => $state-open, to => $state-complete);
my $complete-progress = Tinky::Transition.new(name => 'complete', from => $state-in-progress, to => $state-complete);

my @transitions = $open, $reject-new, $reject-open, $reject-stalled, $stall-open, $stall-progress, $unstall, $take, $complete-open, $complete-progress;

my $workflow = Tinky::Workflow.new(:@transitions, name => 'ticket-workflow', initial-state => $state-new );

my Int $transition-count = 0;

$workflow.transition-supply.act(-> ($trans, $object) { isa-ok $trans, Tinky::Transition, "got a Transition"; isa-ok $object, Ticket, "got a Ticket"; ok $trans.to ~~ $object.state, "and the state is what we expected"; $transition-count++;  });

my Bool $seen-final = False;

$workflow.final-supply.act(-> ( $state, $object) { $seen-final = True });

my $ticket-a = Ticket.new(owner => "Operator A");

$ticket-a.apply-workflow($workflow);

$ticket-a.open;

is $ticket-a.state, $state-open, "In state 'open'";

$ticket-a.take;

is $ticket-a.state, $state-in-progress, "In progress";

is-deeply $ticket-a.next-states, [ $state-stalled, $state-complete ], "Next-states gives what expected";

$ticket-a.state = $state-stalled;

is $ticket-a.state, $state-stalled, "Stalled";

$ticket-a.reject;

is $ticket-a.state, $state-rejected, "Rejected";

is $transition-count, 4, "saw the right number of transitions";
ok $seen-transition-supply, "saw the event on stall transition";
ok $seen-entered, "Saw an event on the entered supply";
ok $seen-final, "Saw an event on the final supply";

}, "synopsis code runs ok";

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
