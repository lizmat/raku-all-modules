# Tinky

An experimental workflow module for Perl 6

[![Build Status](https://travis-ci.org/jonathanstowe/Tinky.svg?branch=master)](https://travis-ci.org/jonathanstowe/Tinky)

## Synopsis

This is quite long [skip to the Description](#description) if you are impatient.

```
use Tinky;


# A class that will use the workflow
# it can have any attributes or methods
# required by your application

class Ticket does Tinky::Object {
    has Str $.ticket-number = (^100000).pick.fmt("%08d");
    has Str $.owner;
}

# Set up some states as required by the application
my $state-new         = Tinky::State.new(name => 'new');
my $state-open        = Tinky::State.new(name => 'open');
my $state-rejected    = Tinky::State.new(name => 'rejected');
my $state-in-progress = Tinky::State.new(name => 'in-progress');
my $state-stalled     = Tinky::State.new(name => 'stalled');
my $state-complete    = Tinky::State.new(name => 'complete');

# Each state has an 'enter-supply' and a 'leave-supply' which get the
# object which the state was applied to.

$state-rejected.enter-supply.act( -> $object { say "** sending rejected e-mail for Ticket '{ $object.ticket-number }' **"});

# Create some transitions to describe pre-determined change of state
# A method will be created on the Tinky::Object for each transition name

my $open              = Tinky::Transition.new(name => 'open', from => $state-new, to => $state-open);

# Where  more than one transition has the same name, the transition which matches the object's 
# current state will be use.
my $reject-new        = Tinky::Transition.new(name => 'reject', from => $state-new, to => $state-rejected);
my $reject-open       = Tinky::Transition.new(name => 'reject', from => $state-open, to => $state-rejected);
my $reject-stalled    = Tinky::Transition.new(name => 'reject', from => $state-stalled, to => $state-rejected);

my $stall-open        = Tinky::Transition.new(name => 'stall', from => $state-open, to => $state-stalled);
my $stall-progress    = Tinky::Transition.new(name => 'stall', from => $state-in-progress, to => $state-stalled);

# The transition supply allows specific logic for the transition to be performed

$stall-progress.supply.act( -> $object { say "** rescheduling tickets for '{ $object.owner }' on ticket stall **"});

my $unstall           = Tinky::Transition.new(name => 'unstall', from => $state-stalled, to => $state-in-progress);

my $take              = Tinky::Transition.new(name => 'take', from => $state-open, to => $state-in-progress);

my $complete-open     = Tinky::Transition.new(name => 'complete', from => $state-open, to => $state-complete);
my $complete-progress = Tinky::Transition.new(name => 'complete', from => $state-in-progress, to => $state-complete);

my @transitions = $open, $reject-new, $reject-open, $reject-stalled, $stall-open, $stall-progress, $unstall, $take, $complete-open, $complete-progress;

# The Workflow object allows the relation between states and transitions to be calculate
# and generates the methods that will be applied to the ticket object.  The initual-state
# will be applied to the object if there is no existing state on the state.
my $workflow = Tinky::Workflow.new(:@transitions, name => 'ticket-workflow', initial-state => $state-new );

# The workflow aggregates the Supplies of the transitions and the states.
# This could be to a logging subsystem for instance. 

$workflow.transition-supply.act(-> ($trans, $object) { say "Ticket '{ $object.ticket-number }' went from { $trans.from.name }' to '{ $trans.to.name }'" });

# The final-supply emits the state and the object when a state is reached where there are no
# further transitions available

$workflow.final-supply.act(-> ( $state, $object) { say "** updating performance stats with Ticket '{ $object.ticket-number }' entered State '{ $state.name }'" });

# Create an instance of the Tinky::Object.
# A 'state' can be supplied to initialise if, for example, the data was retrieved from a database.
my $ticket-a = Ticket.new(owner => "Operator A");

# Applying the workflow will set the initial state if one is configured and will
# apply a role that provides the transition methods.
# The workflow object can be configured to check whether the object to which it
# is being applied is suitable and throw an exception if not.

$ticket-a.apply-workflow($workflow);

# Exercise the transition methods.
# Other mechanisms are available for performing the transitions whuch may be more
# suitable if the next state is to be calculated.

# State new -> open
$ticket-a.open;

# State open -> in-progress
$ticket-a.take;

# Get the names of the states which are now available for the object
# [stalled complete]
$ticket-a.next-states>>.name.say;

# Directly assigning the state will be validated, an exception will
# be thrown if this is not a valid transition at the time
$ticket-a.state = $state-stalled;

# State stalled -> rejected
# This is a final state and no further transitions are available.
$ticket-a.reject;

```

## Description

Tinky is a deterministic state manager that can be used to implement a
workflow system, it provides a role ```Tinky::Object``` that allows an
object to have a managed state.

A ```Workflow``` is simply a set of ```State```s and allowable transitions
between them. Validators can be defined to check whether an object should
be allowed to enter or leave a specific state or have a transition
performed, asynchronous notification of state change (enter, leave or
transition application,) is provided by Supplies which are available at
```State```/```Transition``` level or aggregrated.

I have taken somewhat of a "kitchen-sink" toolkit approach with this to
provide a somewhat rich interface that can be more easily used to create
higher level applications which interact nicely with Perl 6's reactive and
composable nature. I've taken some ideas from similar software in other 
languages that I have used and added features that I would have liked for
the problems that I was solving and ended up providing myself.

By the way I've deliberately chosen a "non-enterprisey" name for this for a 
couple of reasons, largely however because I'm not convinced that this will
remain the gold standard within the problem domain I don't want to block out
a more sensible name for someone who may want to make something later, also
the possible candidates involving some variant of "Workflow" or "state machine"
don't properly fit what I see this as which is something that has some of the
features of the latter in order to provide a toolkit to help implement the former.

## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Tinky

Other install mechanisms may be become available in the future.

## Support

This is an experimental software but suggestions and patches that
may make it more useful in your software are welcomed via github at

   https://github.com/jonathanstowe/Tinky


## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2016
