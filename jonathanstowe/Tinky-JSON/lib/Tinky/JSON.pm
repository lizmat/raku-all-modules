use v6;

use Tinky;
use JSON::Unmarshal:ver(v0.07);
use JSON::Class;
use JSON::Name;

=begin pod

=head1 NAME

Tinky::JSON - create a L<Tinky|https://github.com/jonathanstowe/Tinky> workflow from JSON

=head1 SYNOPSIS

Given a JSON file like:

=begin code
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

=end code

This is functionally the same as the example for L<Tinky|https://github.com/jonathanstowe/Tinky> but
adjusted to use the state and transition names rather than the objects themselves.

=begin code

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

=end code

=head1 DESCRIPTION

This is a sub-class of  L<Tinky|https://github.com/jonathanstowe/Tinky>
that provides the facility of defining and loading a state machine
definition from a JSON file rather than creating all of the objects
individually.

Convenience methods are provided to be able to reference states and
transitions by name rather than using the objects directly so this
may be useful for other applications too.

No additional methods have been added to the sub-classes of
C<Tinky::State> and C<Tinky::Transition> that are used.

=head1 METHODS

All of the changed or added methods are on the class C<Tinky::JSON::Workflow>
for the full documentation of all the available methods please see
the L<Tinky|https://github.com/jonathanstowe/Tinky>.

=head2 method from-json

    method from-json(Str $json) returns Tinky::JSON::Workflow

Given a JSON document (in the format shown in the SYNOPSIS,) it will return
a new populated Tinky::JSON::Workflow.

=head2 method state

    method state(Str $name) returns Tinky::JSON::State

Given the name of a state in the workflow this will return the Tinky::JSON::State
with that name, this is useful to access the methods of the state where there
isn't a helper provided.

If the name provided isn't that of a valid state then a C<X::NoState> exception
will be thrown.

=head2 method transition

    method transition(Str $name) returns List[Tinky::JSON::Transition]


Given the name of a transition in the workflow it will return a list of one or
more C<Tinky::JSON::Transition> objects. Transition names are B<not> required to be
unique by C<Tinky> (though those sharing a name are suggested to have the same end
target,) so you may get more than one with the same name.  Similary, this does
not throw an exception when the transition is not found.

If you want to find exactly one transition you may want to use C<find-transition>
instead which searches by the from and to states and is thus guaranteed to return
a unique result.

=head2 method enter-supply

    multi method enter-supply(Str $state) returns Supply

Given the name of a state in the workflow this will return the state's enter-supply.
If the name is not that of a valid state then an C<X::NoState> exception will be thrown.

=head2 method leave-supply

    multi method leave-supply(Str $state) returns Supply

Given the name of a state in the workflow this will return that state's leave-supply.
If the name is not that of a valid state then an C<X::NoState> exception will be thrown.

=head2 method transitions-for-state

    multi method transitions-for-state(Str $state) returns Array[Tinky::JSON::Transition]

Given the name of a state in the workflow this will return a list of all the transitions
that are available to the state. Typically you are only interested in the target states
so a common idiom might be something like

    $workflow.transitions-for-state('current-state').map({ $_.to });

If the name supplied isn't that of a valid state in the workflow then an C<X::NoState>
will be thrown.

=head2 method find-transition

    multi method find-transition(Str $from, Str $to) returns Tinky::JSON::Transition

Given the names of a "from" state and a "to" state this will return the matching transtion
if any.  There should be only one transition with the matching definition in the workflow.

If either of the supplied state names are not those of a valid state in the workflow then
an C<X::NoState> exception will be thrown.


=end pod

class Tinky::JSON {

    class X::NoState is X::Fail {
        has Str $.name is required;
        method message() returns Str {
            "There is no state '{ $!name }' in this workflow";
        }
    }

    class State is Tinky::State does JSON::Class {
    }


    state %states;
    sub deserialise-state(Str $name) {
        %states{$name} //= Tinky::JSON::State.new(:$name);
    }

    class Transition is Tinky::Transition does JSON::Class {
        has Tinky::JSON::State $.from is unmarshalled-by(&deserialise-state);
        has Tinky::JSON::State $.to is unmarshalled-by(&deserialise-state);
    }

    sub deserialise-states(@names) {
        my @states = @names.map(&deserialise-state);
        @states;
    }


    class Workflow is Tinky::Workflow does JSON::Class {

        method from-json(|c) {
            %states = ();
            self.JSON::Class::from-json(|c);
        }

        has State $.initial-state is unmarshalled-by(&deserialise-state);
        has Tinky::JSON::State @.states is unmarshalled-by(&deserialise-states);
        has Tinky::JSON::Transition @.transitions;

        method state(Str:D $state) returns State {
            self.states.first({ $_ ~~ $state }) // X::NoState.new(name => $state).throw;
        }

        method transition(Str:D $trans) {
            self.transitions.grep: $trans
        }

        multi method enter-supply(Str:D $state) returns Supply {
            self.state($state).?enter-supply();
        }

        multi method leave-supply(Str:D $state) returns Supply {
            self.state($state).?leave-supply();
        }

        multi method transitions-for-state(Str:D $state) {
            self.transitions-for-state(self.state($state));
        }

        multi method find-transition(Str:D $from, Str:D $to) {
            self.find-transition(self.state($from), self.state($to));
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
