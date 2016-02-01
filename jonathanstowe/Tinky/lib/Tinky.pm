use v6;

=begin pod

=head1 NAME

Tinky - a basic and experimental Workflow/State Machine implementation

=head1 SYNOPSIS

=begin code

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

=end code

There may be further example code in the C<examples> directory in the
distribution.

=head1 DESCRIPTION

Tinky is a deterministic state manager that can be used to implement a
workflow system, it provides a c<role> L<Tinky::Object> that allows an
object to have a managed state.

A L<Workflow|Tinky::Workflow> is simply a set of L<State|Tinky::State>s
and allowable transitions between them. Validators can be defined to check
whether an object should be allowed to enter or leave a specific state or
have a transition performed, asynchronous notification of state change
(enter, leave or transition application,) is provided by Supplies which
are available at L<State|Tinky::State>/L<Transition|Tinky::Transition>
level or aggregrated at the Workflow level.

=head2 subset ValidateCallback

This is a type constraint that is used for the validator callbacks
described below, a validator should have the same signature as:

    sub (Tinky::Object $object ) returns Bool

All those subroutines that would accept the supplied Tinky::Object will
be called for validation, so a subroutine which specifies L<Tinky::Object>
will be called for all objects, whereas those that have a more specific
type that does the role L<Tinky::Object> will only be called for that
type (or sub-classes thereof.)

A similar mechanism is used for method callbacks.

=head2 class Tinky::State 

The L<Tinky::State> is the managed state that is applied to an object,
it provides a mechanism for validating whether on object should enter
or leave a particular state and supplies that emit objects that have
entered or left a given state.

As well as the L<enter-validators> and L<leave-validators> validation
callbacks described below, a sub-class of L<Tinky::State> can specify
callback methods with the traits C<enter-validator> or C<leave-validator>.
These methods should have the same general signature as L<ValidateCallback>
and will be called for each L<Tinky::Object> of the same or less-specific
type than specified in the signature.

=head3 method new

    method new(Tinky:U: :$name!, :@enter-validators, @leave-validators)

The constructor must be supplied with a C<name> named parameter which must
be unique with any given workflow (though this is not currently constrained.)


=head3 method enter

        method enter(Object:D $object) 

This is called with the L<Tinky::Object> instance when the state has been
entered by the object, the default implementation arranges for the object
to be emitted on the C<enter-supply>, so if it is over-ridden in a 
sub-class it should nonetheless call the base implementation with C<nextsame>
in order to provide the object to the supply.  It would probably be better
however to simply tap the L<enter-supply>.

=head3 method validate-enter

        method validate-enter(Object $object) returns Promise 

This is called prior to the transition being actually performed and
returns a L<Promise> that will be kept with L<True> if all of the
enter validators return True, or False otherwise.  It can be
over-ridden in a sub-class if some other validation mechanism to
the callbacks is required, but B<must> return a L<Promise>

=head3 method enter-supply

        method enter-supply()  returns Supply

This returns a L<Supply> to which is emitted each object that
has successfully entered the state, generally speaking creating
a tap on this should be preferred to over-riding the C<enter>
method.

=head3 method leave

        method leave(Object:D $object) 

This is called when an object leaves this state, with the object
instance as the argument. Like <enter> the default implementation
provides for the object to emitted on the C<leave-supply> so 
any over-ride implementation should arrange to call this base method.
Typically it would be preferred to tap the C<leave-supply> if some
action is required on leaving a state.

=head3 method validate-leave

        method validate-leave(Object $object) returns Promise 

This is called prior to the transition being actually performed and
returns a L<Promise> that will be kept with L<True> if all of the
leave validators return True, or False otherwise.  It can be
over-ridden in a sub-class if some other validation mechanism to
the callbacks is required, but B<must> return a L<Promise>

=head3 method leave-supply 

        method leave-supply() returns Supply

This returns a L<Supply> to which each object instance that
leaves the state is emitted (after it has left,) tapping this
should generally be preferred to over-riding C<leave>.


=head3 method Str

        method Str() 

This returns a sensible string representation of the State,

=head3 method ACCEPTS

        multi method ACCEPTS(State:D $state) returns Bool 
        multi method ACCEPTS(Transition:D $transition) returns Bool 
        multi method ACCEPTS(Object:D $object) returns Bool 

This provides for smart-matching against another L<State> ( returning
true if they evaluate to the same state,)  a L<Transition> ( returning
True if the C<from> State of the transition is the same as this state,)
or a L<Tinky::Object> ( returnning True if the Object is at the State.)

=head3 attribute enter-validators

This is a list of L<ValidateCallback> callables that will be called with
a matching object to that specified in their signature and should return
a Bool to indicate whether the enter should be allowed or not, all the called
validators must return True for the state to be entered, the implementation
is free to use any mechanism to check but all the validators will be started
concurrently so there should be no side-effects that may be relied upon by the
other validators, specifically they probably shouldn't alter the object.  The
validation will not be completed until all the validators run have returned a
value.

Alternatively a sub-class can define validator methods with the C<enter-validator>
trait like:

    method validate-foo(Tinky::Object $obj) returns Bool is enter-validator {
        ...

    }

This may be useful if you have fixed states and wish to substitute runtime
complexity.

=head3 attribute leave-validators

This is a list of L<ValidateCallback> callables that will be called with
a matching object to that specified in their signature and should return
a Bool to indicate whether the leave should be allowed or not, all the called
validators must return True for the state to be left, the implementation
is free to use any mechanism to check but all the validators will be started
concurrently so there should be no side-effects that may be relied upon by the
other validators, specifically they probably shouldn't alter the object.  The
validation will not be completed until all the validators run have returned a
value.

Alternatively a sub-class can define validator methods with the C<leave-validator>
trait like:

    method validate-foo(Tinky::Object $obj) returns Bool is leave-validator {
        ...

    }

This may be useful if you have fixed states and wish to substitute runtime
complexity.

=head2 class Tinky::Transition 

A transition is the configured change between two pre-determined states,  Only
changes described by a transition are allowed to be performed. The transaction
class provides for validators that can indicate whether the transition should
be applied to an object (distinct from the enter or leave state validators,)
and provides a separate supply that emits the object whenever the transition
is succesfully applied to an object's state.  This higher level of granularity
may simplify application logic when in some circumstances than taking both
from state and to state individually.


=head3 method new

    method new(Tinky::Transition:U: Str :$!name!, Tinky::State $!from!, Tinky::State $!to!, :@!validators)

The constructor of the class,  The C<name> parameter must be supplied, it need not
be unique but will be used to create a helper method that will be applied to the
target Object when the workflow is applied so should be a valid Perl 6 identifier.
The mechanism for creating these methods is decribed under L<Tinky::Workflow>.

The C<from> and C<to> states must be supplied,  A transition can only be supplied
to an object that has a current state that matches C<from>.

Additionally an array of ValidateCallback subroutines can be supplied (or added later,)
how these are applied is described below.

=head3 method applied

        method applied(Object:D $object) 

This is called with the Tinky::Object instance after the transition
has been successfully implied, the default implementation arranges for
the object instance to be emitted to the transition supply. If this
is over-ridden in a sub-class the implementation should call the base
implementation with C<nextsame> or similar in order that the supply
continues to work.  It is preferrable however to tap the supply in
most cases.

=head3 method validate

        method validate(Object:D $object) returns Promise 

This will be called with an instance of Tinky::Object and returns
a Promise that will be Kept with True if all of the validators
for this transition return True and False otherwise. The way that
the validators are called is the same as that for the enter and
leave validators of L<Tinky::State>.

This can be over-ridden in a sub-class if some other validation
mechanism is to be provided but it still must return a Promise,
but almost anything that can be done here could be done in a
validator subroutine or method anyway.

=head3 method  validate-apply

        method validate-apply(Object:D $object) returns Promise 

This is the top-level method that is used to check whether a 
transition should be applied, it returns a Promise that will be
kept with True if all of the promises returned by the transition's
C<validate>, the C<from> state's C<leave-validate> and the C<to>
state's C<enter-validate> are kept with True.

It is unlikely that this would need to over-ridden but any
sub-class implementation must return a Promise that will be
kept with a Bool.

=head3 method supply

        method supply() returns Supply 

This returns a L<Supply> to which will be emitted every
L<Tinky::Object> instance that has this transition applied.

Tapping this supply is recommended over creating a sub-class
implementation of C<apply>.

=head3 method Str

        method Str() 

Returns a plausible string representation of the transition.

=head3 method ACCEPTS

        multi method ACCEPTS(State:D $state) returns Bool 
        multi method ACCEPTS(Object:D $object) returns Bool 

This is used to smart match the transition against either a
L<Tinky::State> (returning True if the State matches the
transition's C<from> state,) or a L<Tink::Object> (returning
True if the object's current state matches the transition's
C<from> state.)

=head3 attribute validators

This is an array of C<ValidationCallback> callables that will
be called to validate whether the transition can be applied,
only those callbacks will be executed that specify a matching
or less specific type than the L<Tinky::Object> supplied as
a parameter, that is to say if the subroutine specifies
L<Tinky::Object> then it will always be executed for any object,
if the subroutine specifies a type that does the Tinky::Object
role then it will only be called when an object of that type
(or a sub-class thereof) is passed.

Alternatively validators can be supplied as methods with the
C<transition-validator> trait from a sub-class (or another
role for example,) such as:

    method my-validator(Tinky::Object:D $obj) returns Bool is transition-validator {
        ...
    }

The same rules for execution based on the signature and the
object to which the transition is being applied are true for
methods as for validation subroutines.

=head2 class Tinky::Workflow 

The L<Tinky::Workflow> class brings together a collection of
transitions together and provides additional functionality to
objects that consume the workflow as well as aggregating 
the various L<Supply>s that are provided by State and Transition.

Whilst it is possible that standalone transitions can be applied to any
object that does the L<Tinky::Object> role, certain functionality is
not available if workflow is not known.

The application of a Workflow to a Tinky::Object can be subject
to a similar form of validation as with State and Transition
validators and may useful if a certain workflow is only applicable
to a certain type of object for instance, but validators of any
complexity are possible.

=head3 method new

    method new(Tinky::Workflow:U: Str :$!name!, :@!transitions!, State :$!initial-state, :@!validators)

The constructor of L<Tinky::Workflow> should be provided with and array of the Transition objects
that are part of the workflow and an optional list of ValidatorCallback subroutines, if they are to
be used then they must be supplied before the first time a workflow is applied to an object.

If the C<initial-state> is supplied this will be be  applied to a Tinky::Object with no current state
at the time of the workflow application as described below.

The name isn't required but may be useful for identification purposes if there is more than one
workflow in a system.

=head3  method states

        method states() 

This is an array of the L<Tinky::State> objects that are defined for this workflow, it will be 
constructed from the unique states found in the transitions of the workflow,  this list can
be over-ridden by adding to the C<states> attribute but this probably doesn't make sense as a
state is almost certainly useless if there isn't at least one transition which has it as 
C<from> or C<to> state.

=head3 method transitions-for-state

        method transitions-for-state(State:D $state ) returns Array[Transition]

This returns an array of the transitions that have the supplied State as the C<from> state,
this is used internally but may be useful for example in a user interface if a list
of possible transitions is required.

=head3 method find-transition

        multi method find-transition(State:D $from, State:D $to) returns Transition

This returns a Transition that matches the provided C<from> and C<to> states, ( or
a undefined type object otherwise, this may be useful for validating in advance
whether a transition to a new state is valid for an object at a given state (any
further validations as described above, notwithstanding.)

=head3 method validate-apply

        method validate-apply(Object:D $object) returns Promise 

This is called prior to the actual application of the workflow to a Tinky::Object
and returns a Promise that will be kept with True if all of the validators and
validation methods return True or False otherwise.

This could be over-ridden in a sub-class if some other validation mechanism
is required but it must always return a Promise,  in most cases however the
existing validation mechanisms should be sufficient.

=head3 method applied

        method applied(Object:D $object) 

This is called with the Tinky::Object instance to which the workflow has
been applied immediately after the application has completed.  It will
arranged for the object to be emitted onto the C<applied-supply>.

If it is over-ridden in a sub-class then it should almost certainly call
the base implementation with C<nextsame>, though a tap on the C<applied-supply>
is usually preferrable.

=head3 method applied-supply

        method applied-supply() returns Supply 

This is a Supply to which all of the Tinky::Object instances to which the
workflow has been applied are emitted.

=head3 method enter-supply

        method enter-supply() returns Supply 

This is a Supply which aggregates the C<enter-supply> of all the C<states> in the
Workflow, it will emit a two element array comprising the State object that was
entered and the Tinky::Object instance.

=head3 method leave-supply

        method leave-supply() returns Supply 

This is a Supply which aggregates the C<leave-supply> of all the C<states> in the
Workflow, it will emit a two element array comprising the State object that was
left and the Tinky::Object instance.

=head3 method final-supply

        method final-supply() returns Supply 

This returns a Supply onto which are emitted an Array of State and Object whenever
an object enters a state from which there are no further transitions possible.  It
may be useful for notification or cleanup purposes or possibly for activating a 
transition on another object for instance.

=head3 method transition-supply


        method transition-supply() returns Supply 

This returns a Supply that aggregates the C<supply> of all the transitions of the
workflow, it emits a two element array of the Transition object and the Tinky::Object
instance to which it was applied.

This is particularly suitable for example for logging purposes.

=head3 method role

        method role() returns Role

This returns an anonymous role that will be applied to the Tinky::Object when the
workflow is applied.

The role provides methods that are named as the transitions and which cause the
transition to be applied (throwing an exception if the transition cannot be
applied to the current state or if any validators return false.)  If two or more
transitions share the same name then a single method will be created which will
select the appropriate transition based on the current state of the object.

=head3 attribute validators

This is an array of C<ValidationCallback> callables that will be called
to validate whether the workflow can be applied to an object, only those
callbacks will be executed that specify a matching or less specific
type than the L<Tinky::Object> supplied as a parameter, that is to say
if the subroutine specifies L<Tinky::Object> then it will always be
executed for any object, if the subroutine specifies a type that does
the Tinky::Object role then it will only be called when an object of
that type (or a sub-class thereof) is passed.

Alternatively validators can be supplied as methods with the
C<apply-validator> trait from a sub-class (or another role for example,)
such as:

    method my-validator(Tinky::Object:D $obj) returns Bool is apply-validator {
        ...
    }

The same rules for execution based on the signature and the
object to which the transition is being applied are true for
methods as for validation subroutines.

=head2 role Tinky::Object 

This is a role that should should be applied to any application object that is to
have a state managed by L<Tink::Workflow>, it provides the mechanisms for
transition application and allows the transitions to be validated by the mechanisms
described above for L<Tinky::State> and L<Tinky::Transition>

=head3 method state

        method state(Object:D: ) is rw 

This is read/write method that allows the state of an object to be
set directly with a L<Tinky::State> object.  If the object has no
current state (or the state is being set within the constructor,) then
no validation will occur (though obviously it should be a valid state
within the workflow for it to be meaningful.)  If the state is already
set then there must be a valid transition to the required state from the
current state otherwise an exception will be thrown, once the transition
is resolved it will be passed to C<apply-transition> and will be subject
to checking by the validators for the states and transition and will
throw an exception if it cannot be applied.

=head3 method apply-workflow

        method apply-workflow(Tinky::Workflow:D $wf) 

This should be called with the Tinky::Workflow object that is to manage
the objects state, it will call the C<validators> subroutines of the
Workflow and will throw an exception if any return False.  If successfull
the role provided by the L<Tinky::Workflow> object will be applied and
the workflow stored so that it can be used to gain information about the
workflow.  After succesfull application the Object will be emitted on the
Workflow's C<applied-supply> which can be tapped to provide any further
processing required.

=head3 method apply-transition

        method apply-transition(Tinky::Transition $trans) returns Tinky::State 

Applies the transition supplied to the object, if the current state of the
object doesn't match the C<from> state of transition then an L<X::InvalidTransition>
will be thrown, if one or more state or transition validators return False
then a L<X::TransitionRejected> exception will be thrown,  If the object has no
current state then  L<X::NoState> will be thrown.

If the application is successfull then the state of the object will be changed to
the C<to> state of the transition and the object will be emitted to the appropriate
supplies of the left and entered states and the transition.

=head3 method transitions

        method transitions() returns Array[Transition]

This returns an array of the L<Tinky::Transition>s that are available for the 
object based on their C<from> state matching the current state of the object.

=head3 method next-states

        method next-states() returns Array[State]

This returns an Array of the states that are available as the C<to> state of
the available C<transitions>, this may be more convenient for example for
a user interface than the raw transitions.

=head3 method transition-for-state

        method transition-for-state(State:D $to-state) returns Transition

This returns the transition that would place the object in the supplied
state from its current state (or the Transition type object if there is
no such transition.)

=head3 method ACCEPTS

        multi method ACCEPTS(State:D $state) returns Bool 
        multi method ACCEPTS(Transition:D $trans) returns Bool 
        
Used to smart match the object against either a State (returns True if
the state matches the current state of the object,) or a Transition
(returns True if the C<from> state matches the current state of the
object.)

=head2 EXCEPTIONS

The methods for applying a transition to an object will signal an 
inability to apply the transition by means of an exception.

The below documents the location where the exceptions are thrown
directly, of course they may be the result of some higher level
method.

=head3 class Tinky::X::Fail is Exception 

This is used as a base class for all of the exceptions thrown by
Tinky, it will never be thrown itself.

=head3 class Tinky::X::Workflow is X::Fail

This is an additional sub-class of L<X::Fail> that is used by
some of the other exceptions.

=head3 class Tinky::X::InvalidState is X::Workflow 

=head3 class Tinky::X::InvalidTransition is X::Workflow 

This will be thrown by the helper methods provided by the
application of the workflow if the current state of the
object does match the C<from> state of any of the applicable
transitions. It will also be thrown by C<apply-transition>
if the C<from> state of the transition supplied doesn't match
the current state of the object.

=head3 class Tinky::X::NoTransition is X::Fail 

This will be thrown when attempting to set the state of
the object by assignment when there is no transition that
goes from the object's current state to the supplied state.

=head3 class Tinky::X::NoWorkflow is X::Fail 

This is thrown by C<transitions> and C<transitions-for-state>
on the L<Tinky::Object> if they are called when no workflow
has yet been applied to the object.

=head3 class Tinky::X::NoTransitions is X::Fail 

This is thrown by the L<Workflow> C<states> method if it
is called and there are no transitions defined.

=head3 class Tinky::X::TransitionRejected is X::Fail 

This is thrown by C<apply-transition> when the transition
validation resulted in a False value, because the transition,
leave state or enter state validators returned false.

=head3 class Tinky::X::ObjectRejected is X::Fail 

This is thrown on C<apply-workflow> if one or more of the
workflow's apply validators returned false.

=head3 class Tinky::X::NoState is X::Fail 

This will be thrown by apply-transition if there is no
current state on the object.

=end pod

module Tinky:ver<0.0.2>:auth<github:jonathanstowe> {

    # Stub here, definition below
    class State      { ... };
    class Transition { ... }
    class Workflow   { ... };
    role Object      { ... };


    # This is a handy type definition to save having to type
    # this out all over the place so we can pretend a role
    # is a type.
    subset Role of Mu where { $_.HOW.archetypes.composable };

    # Traits for user defined state and transition classes
    # The roles are only used to indicate the purpose of the
    # methods for the time being.

    my role EnterValidator { }
    multi sub trait_mod:<is> ( Method $m, :$enter-validator! ) is export {
        $m does EnterValidator;
    }

    my role LeaveValidator { }
    multi sub trait_mod:<is> (Method $m, :$leave-validator! ) is export {
        $m does LeaveValidator;
    }

    my role TransitionValidator { }
    multi sub trait_mod:<is> (Method $m, :$transition-validator! ) is export {
        $m does TransitionValidator;
    }

    my role ApplyValidator { }
    multi sub trait_mod:<is> (Method $m, :$apply-validator! ) is export {
        $m does ApplyValidator;
    }


    subset ValidateCallback of Callable where { $_.signature.params && $_.signature ~~ :(Object --> Bool) };

    # This doesn't need any state and can be used by both Transition and State
    # The @subs isn't constrained but they should be ValidateCallbacks
    my sub validate-helper(Object $object, @subs) returns Promise {
        my sub run(|c) {
            my @promises = do for @subs.grep( -> $v { c ~~ $v.signature  }) -> &callback {
                start { callback(|c) };
            }
            my $p1 = do {
                if all(@promises>>.status) ~~ Kept {
                    my $p = Promise.new;
                    $p.keep: so all(@promises>>.result);
                    $p;
                }
                else {
                    Promise.allof(@promises);
                }
            }
            $p1.status ~~ Kept ?? $p1 !! $p1.then({ so all(@promises>>.result) });
        }
        run($object);
    }

    # find the methods in the supplied object, that would
    # accept the Object as an argument and then wrap them
    # as subs with the object to pass to the above
    my sub validate-methods(Mu:D $self, Object $object, ::Phase) {
        my @meths;
        for $self.^methods.grep(Phase) -> $meth {
            if $object.WHAT ~~ $meth.signature.params[1].type  {
                @meths.push: $meth.assuming($self);
            }
        }
        @meths;
    }

    class X::Fail is Exception {
    }

    class X::Workflow is X::Fail {
        has State       $.state;
        has Transition  $.transition;
    }

    class X::InvalidState is X::Workflow {
        method message() {
            "State '{ $.state.Str }' is not valid for Transition '{ $.transition.Str }'";
        }
    }

    class X::InvalidTransition is X::Workflow {
        has Str $.message;
        method message() {
            $!message // "Transition '{ $.transition.Str }' is not valid for State '{ $.state.Str }'";
        }
    }

    class X::NoTransition is X::Fail {
        has State $.from;
        has State $.to;
        has Str   $.message;
        method message() {
            $!message // "No Transition for '{ $.from.Str }' to '{ $.to.Str }'";
        }
    }

    class X::NoWorkflow is X::Fail {
        has Str $.message = "No workflow defined";

    }

    class X::NoTransitions is X::Fail {
        has Str $.message = "No Transitions defined in workflow";
    }

    class X::TransitionRejected is X::Fail {
        has Transition $.transition;
        method message() {
            "Transition '{ $!transition.Str }' was rejected by one or more validators";
        }
    }

    class X::ObjectRejected is X::Fail {
        has Workflow $.workflow;
        method message() {
            "The Workflow '{ $!workflow.Str }' rejected the object at apply";
        }
    }

    class X::NoState is X::Fail {
        has Str $.message = "No current state";
    }
    

    class State {
        has Str $.name is required;

        has Supplier $!enter-supplier  = Supplier.new;
        has Supplier $!leave-supplier  = Supplier.new;

        has ValidateCallback @.enter-validators;
        has ValidateCallback @.leave-validators;

        multi method ACCEPTS(State:D $state) returns Bool {
            # naive approach for the time being
            return self.name eq $state.name;
        }

        # define in terms of above so only need to change once
        multi method ACCEPTS(Transition:D $transition) returns Bool {
            return self ~~ $transition.from;
        }

        multi method ACCEPTS(Object:D $object) returns Bool {
            return self ~~ $object.state;
        }

        method Str() {
            $!name;
        }

        method validate-enter(Object $object) returns Promise {
            self!validate-phase('enter', $object);
        }

        method enter-supply() {
            $!enter-supplier.Supply;
        }
        method enter(Object:D $object) {
            $!enter-supplier.emit($object);
        }

        method validate-leave(Object $object) returns Promise {
            self!validate-phase('leave', $object);
        }

        method !validate-phase(Str $phase where 'enter'|'leave', Object $object) returns Promise {
            my @subs = do given $phase {
                when 'leave' {
                    (@!leave-validators, validate-methods(self, $object, LeaveValidator)).flat;
                }
                when 'enter' {
                    (@!enter-validators, validate-methods(self, $object, EnterValidator)).flat;
                }
            }
            validate-helper($object, @subs);
        }



        method leave-supply() {
            $!leave-supplier.Supply;
        }

        method leave(Object:D $object) {
            $!leave-supplier.emit($object);
        }
    }

    class Transition {
        has Str $.name;

        has State $.from;
        has State $.to;

        has Supplier $!supplier = Supplier.new;

        has ValidateCallback @.validators;

        # defined in terms of State so we only need to change once
        multi method ACCEPTS(State:D $state) returns Bool {
            return self.from ~~ $state;
        }

        multi method ACCEPTS(Object:D $object) returns Bool {
            return self.from ~~ $object.state;
        }

        method applied(Object:D $object) {
            self.from.leave($object);
            self.to.enter($object);
            $!supplier.emit($object);
        }

        # This just calls the validators for the Transition
        method validate(Object:D $object) returns Promise {
            validate-helper($object, ( @!validators, validate-methods(self, $object, TransitionValidator)).flat);
        }

        method validate-apply(Object:D $object) returns Promise {
            my @promises = (self.validate($object), self.from.validate-leave($object), self.to.validate-enter($object));
            my $p1 = do {
                            if all(@promises>>.status) ~~ Kept {
                                my $p = Promise.new;
                                $p.keep: so all(@promises>>.result);
                                $p;
                            }
                            else {
                                Promise.allof(@promises);
                            }
            };

            $p1.status ~~ Kept ?? $p1 !! $p1.then({ so all(@promises>>.result)});
        }

        method supply() returns Supply {
            $!supplier.Supply;
        }

        method Str() {
            $!name;
        }

    }


    class Workflow {

        has Str $.name;

        has State      @.states;
        has Transition @.transitions;

        has State      $.initial-state;

        has ValidateCallback @.validators;

        method validate-apply(Object:D $object) returns Promise {
            validate-helper($object, ( @!validators, validate-methods(self, $object, ApplyValidator)).flat);
        }

        has $!role;

        method states() {
            if not @!states.elems {
                if @!transitions {
                    @!states = @!transitions.map({ $_.from, $_.to }).flat.unique;
                }
                else {
                    X::NoTransitions.new.throw;
                }
            }
            @!states;
        }

        has Supplier $!applied-supplier = Supplier.new;

        method applied(Object:D $object) {
            $!applied-supplier.emit($object);
        }

        method applied-supply() returns Supply {
            $!applied-supplier.Supply;
        }

        has Supply $!enter-supply;
        method enter-supply() returns Supply {
            $!enter-supply //= do {
                my @supplies = self.states.map(-> $state { $state.enter-supply.map(-> $value { $state, $value }) });
                Supply.merge(@supplies);
            }
            $!enter-supply;
        }
        
        has Supply $!final-supply;
        method final-supply() returns Supply {
            $!final-supply //= self.enter-supply.grep( -> $ ($state, $object) { !?self.transitions-for-state($state) } );
        }

        has Supply $!leave-supply;
        method leave-supply() returns Supply {
            $!leave-supply //= do {
                my @supplies = self.states.map(-> $state { $state.leave-supply.map(-> $value { $state, $value }) });
                Supply.merge(@supplies);
            }
            $!leave-supply;
        }

        has Supply $!transition-supply;
        method transition-supply() returns Supply {
            $!transition-supply //= do {
                my @supplies = self.transitions.map( -> $transition { $transition.supply.map(-> $value { $transition, $value }) });
                Supply.merge(@supplies);
            }
            $!transition-supply;
        }

        method transitions-for-state(State:D $state ) {
            @!transitions.grep($state);
        }

        # I'm half tempted to have this throw if there is more than one
        multi method find-transition(State:D $from, State:D $to) {
            return self.transitions-for-state($from).first({ $_.to ~~ $to }); 
        }

        method role() returns Role {
            if not $!role ~~ Role {
                $!role = role { };
                for @.transitions.classify(-> $t { $t.name }).kv -> $name, $transitions {
                    my $method = method (|c) {
                        if $transitions.grep(self.state).first -> $tran {
                            self.apply-transition($tran, |c);
                        }
                        else {
                            X::InvalidTransition.new(message => "No transition '$name' for state '{ self.state.Str }'").throw;
                        }
                    }
                    $!role.^add_method($name, $method);
                }
            }
            $!role;
        }
    }

    role Object {
        has Workflow $!workflow;

        has State $.state;

        method !state() is rw returns State {
            $!state;
        }

        method state(Object:D $SELF:) is rw {
            Proxy.new(
                FETCH => method () {
                    $SELF!state;
                },
                STORE => method (State $val) {
                    if not $SELF!state.defined {
                        $SELF!state = $val;
                    }
                    else {
                        if $SELF.transition-for-state($val) -> $trans {
                            $SELF.apply-transition($trans);
                        }
                        else {
                            X::NoTransition.new(from => $SELF.state, to => $val).throw;
                        }
                    }
                    $SELF!state;
                }
            );
        }

        method apply-workflow(Workflow $wf) {
            my $p = $wf.validate-apply(self);
            if $p.result {
                $!workflow = $wf;
                if not $!state.defined and $!workflow.initial-state.defined {
                    $!state = $!workflow.initial-state;
                }
                try self does $wf.role;
                $wf.applied(self);;
            }
            else {
                X::ObjectRejected.new(workflow => $wf).throw;
            }
        }

        multi method ACCEPTS(State:D $state) returns Bool {
            return $!state ~~ $state;
        }

        multi method ACCEPTS(Transition:D $trans) returns Bool {
            return $!state ~~ $trans;
        }

        method transitions() {
            my @trans;
            if $!workflow.defined {
                @trans = $!workflow.transitions-for-state($!state);
            }
            else {
                X::NoWorkflow.new.throw;
            }
            @trans;
        }

        method next-states() {
            my @states = self.transitions>>.to;
            @states;
        }

        method transition-for-state(State:D $to-state) {
            my $trans;
            if $!workflow.defined {
                $trans = $!workflow.find-transition($!state, $to-state);
            }
            else {
                X::NoWorkflow.new.throw;
            }
            $trans;
        }

        method apply-transition(Transition $trans,|c) returns State {
            if $!state.defined {
                if self ~~ $trans {
                    if await $trans.validate-apply(self) {
                        $!state = $trans.to;
                        $trans.applied(self);
                        $!state;
                    }
                    else {
                        X::TransitionRejected.new(transition => $trans).throw;
                    }
                }
                else {
                    if $!state.defined {
                        X::InvalidTransition.new(state => $!state, transition => $trans).throw;
                    }
                    else {
                        X::NoState.new.throw;
                    }

                }
            }
            else {
                X::NoState.new.throw;
            }
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
