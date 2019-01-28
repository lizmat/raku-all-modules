# Tinky-JSON

Tinky Machines defined in JSON

[![Build Status](https://travis-ci.org/jonathanstowe/Tinky-JSON.svg?branch=master)](https://travis-ci.org/jonathanstowe/Tinky-JSON)

## Synopsis

Given a JSON file like:

```javascript
{
    "name" : "Test Workflow",
    "initial-state" : "new",
    "states" : [ "new", "open", "rejected", "in-progress", "stalled", "complete" ],
    "transitions" : [
        {
            "name" : "open",
            "from" : "new",
            "to"   : "open"
        },
        {
            "name" : "reject",
            "from" : "new",
            "to"   : "rejected"
        },
        {
            "name" : "reject",
            "from" : "open",
            "to"   : "rejected"
        },
        {
            "name" : "reject",
            "from" : "stalled",
            "to"   : "rejected"
        },
        {
            "name" : "stall",
            "from" : "open",
            "to"   : "stalled"
        },
        {
            "name" : "stall",
            "from" : "in-progress",
            "to"   : "stalled"
        },
        {
            "name" : "unstall",
            "to"   : "in-progress",
            "from" : "stalled"
        },
        {
            "name" : "take",
            "from" : "open",
            "to"   : "in-progress"
        },
        {
            "name" : "complete",
            "from" : "open",
            "to"   : "complete"
        },
        {
            "name" : "complete",
            "from" : "open",
            "to"   : "complete"
        },
        {
            "name" : "complete",
            "from" : "in-progress",
            "to"   : "complete"
        }
    ]
}
```

This is functionally the same as the example for [Tinky](https://github.com/jonathanstowe/Tinky)


```perl6
use Tinky;
use Tinky::JSON;

my $json = $*PROGRAM.parent.child('ticket.json').slurp;

my $workflow = Tinky::JSON::Workflow.from-json($json);

class Ticket does Tinky::Object {
    has Str $.ticket-number = (^100000).pick.fmt("%08d");
    has Str $.owner;
}

# Each state has an 'enter-supply' and a 'leave-supply' which get the
# object which the state was applied to.

$workflow.enter-supply('rejected').act( -> $object { say "** sending rejected e-mail for Ticket '{ $object.ticket-number }' **" });

# The transition supply allows specific logic for the transition to be performed

$workflow.find-transition('in-progress', 'stalled').supply.act( -> $object { say "** rescheduling tickets for '{ $object.owner }' on ticket stall **"});

# The workflow aggregates the Supplies of the transitions and the states.
# This could be to a logging subsystem for instance. 

$workflow.transition-supply.act(-> ($trans, $object) { say "Ticket '{ $object.ticket-number }' went from { $trans.from.name }' to '{ $trans.to.name }'" });

# The final-supply emits the state and the object when a state is reached where there are no
# further transitions available

$workflow.final-supply.act(-> ( $state, $object) { say "** updating performance stats with Ticket '{ $object.ticket-number }' entered State '{ $state.name }'" });

# Create an instance of the Tinky::Object.
# A 'state' can be supplied to initialise if, for example, the data was retrieved from a database
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
$ticket-a.state = $workflow.state('stalled');

# State stalled -> rejected
# This is a final state and no further transitions are available.
$ticket-a.reject;
```


## Description

This allows you to define a [Tinky](https://github.com/jonathanstowe/Tinky) workflow from JSON data.

It provides sub-classes of ```Tinky::Workflow```, ```Tinky::State```, amd ```Tinky::Transition```
that can be serialised from JSON and have over-rides of some of the methods to take the names
of objects in the workflow definition (states or transitions,) rather than the objects themselves.

This aims to simplify the construction of state machines from a fixed configuration.

## Installation

Assuming you have a working Rakudo Perl 6 installation then you
should be able to install this module with *zef* :

	zef install Tinky::JSON

Or if you have a clone of the repository you can substitute the
name of the module for '.' (assuming you are actually in the 
cloned directory.)

## Support

Please send any reports, suggestions or patches to https://github.com/jonathanstowe/Tinky-JSON/issues

## Copyright and Licence

The is free software.  The terms are described in the [LICENCE](LICENCE)
file in the distribution.

© Jonathan Stowe, 2016 - 2019
