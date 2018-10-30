NAME
====

Tinky - a basic and experimental Workflow/State Machine implementation

SYNOPSIS
========

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

There may be further example code in the `examples` directory in the distribution.

DESCRIPTION
===========

Tinky is a deterministic state manager that can be used to implement a workflow system, it provides a c<role> [Tinky::Object](Tinky::Object) that allows an object to have a managed state.

A [Workflow](Tinky::Workflow) is simply a set of [State](Tinky::State)s and allowable transitions between them. Validators can be defined to check whether an object should be allowed to enter or leave a specific state or have a transition performed, asynchronous notification of state change (enter, leave or transition application,) is provided by Supplies which are available at [State](Tinky::State)/[Transition](Tinky::Transition) level or aggregrated at the Workflow level.

subset ValidateCallback
-----------------------

This is a type constraint that is used for the validator callbacks described below, a validator should have the same signature as:

    sub (Tinky::Object $object ) returns Bool

All those subroutines that would accept the supplied Tinky::Object will be called for validation, so a subroutine which specifies [Tinky::Object](Tinky::Object) will be called for all objects, whereas those that have a more specific type that does the role [Tinky::Object](Tinky::Object) will only be called for that type (or sub-classes thereof.)

A similar mechanism is used for method callbacks.

class Tinky::State 
-------------------

The [Tinky::State](Tinky::State) is the managed state that is applied to an object, it provides a mechanism for validating whether on object should enter or leave a particular state and supplies that emit objects that have entered or left a given state.

As well as the [enter-validators](enter-validators) and [leave-validators](leave-validators) validation callbacks described below, a sub-class of [Tinky::State](Tinky::State) can specify callback methods with the traits `enter-validator` or `leave-validator`. These methods should have the same general signature as [ValidateCallback](ValidateCallback) and will be called for each [Tinky::Object](Tinky::Object) of the same or less-specific type than specified in the signature.

### method new

    method new(Tinky:U: :$name!, :@enter-validators, @leave-validators)

The constructor must be supplied with a `name` named parameter which must be unique with any given workflow (though this is not currently constrained.)

### method enter

    method enter(Object:D $object)

This is called with the [Tinky::Object](Tinky::Object) instance when the state has been entered by the object, the default implementation arranges for the object to be emitted on the `enter-supply`, so if it is over-ridden in a  sub-class it should nonetheless call the base implementation with `nextsame` in order to provide the object to the supply. It would probably be better however to simply tap the [enter-supply](enter-supply).

### method validate-enter

    method validate-enter(Object $object) returns Promise

This is called prior to the transition being actually performed and returns a [Promise](Promise) that will be kept with [True](True) if all of the enter validators return True, or False otherwise. It can be over-ridden in a sub-class if some other validation mechanism to the callbacks is required, but **must** return a [Promise](Promise)

### method enter-supply

    method enter-supply()  returns Supply

This returns a [Supply](Supply) to which is emitted each object that has successfully entered the state, generally speaking creating a tap on this should be preferred to over-riding the `enter` method.

### method leave

    method leave(Object:D $object)

This is called when an object leaves this state, with the object instance as the argument. Like <enter> the default implementation provides for the object to emitted on the `leave-supply` so  any over-ride implementation should arrange to call this base method. Typically it would be preferred to tap the `leave-supply` if some action is required on leaving a state.

### method validate-leave

    method validate-leave(Object $object) returns Promise

This is called prior to the transition being actually performed and returns a [Promise](Promise) that will be kept with [True](True) if all of the leave validators return True, or False otherwise. It can be over-ridden in a sub-class if some other validation mechanism to the callbacks is required, but **must** return a [Promise](Promise)

### method leave-supply 

    method leave-supply() returns Supply

This returns a [Supply](Supply) to which each object instance that leaves the state is emitted (after it has left,) tapping this should generally be preferred to over-riding `leave`.

### method Str

    method Str()

This returns a sensible string representation of the State,

### method ACCEPTS

    multi method ACCEPTS(State:D $state) returns Bool 
    multi method ACCEPTS(Transition:D $transition) returns Bool 
    multi method ACCEPTS(Object:D $object) returns Bool

This provides for smart-matching against another [State](State) ( returning true if they evaluate to the same state,) a [Transition](Transition) ( returning True if the `from` State of the transition is the same as this state,) or a [Tinky::Object](Tinky::Object) ( returnning True if the Object is at the State.)

### attribute enter-validators

This is a list of [ValidateCallback](ValidateCallback) callables that will be called with a matching object to that specified in their signature and should return a Bool to indicate whether the enter should be allowed or not, all the called validators must return True for the state to be entered, the implementation is free to use any mechanism to check but all the validators will be started concurrently so there should be no side-effects that may be relied upon by the other validators, specifically they probably shouldn't alter the object. The validation will not be completed until all the validators run have returned a value.

Alternatively a sub-class can define validator methods with the `enter-validator` trait like:

    method validate-foo(Tinky::Object $obj) returns Bool is enter-validator {
        ...

    }

This may be useful if you have fixed states and wish to substitute runtime complexity.

### attribute leave-validators

This is a list of [ValidateCallback](ValidateCallback) callables that will be called with a matching object to that specified in their signature and should return a Bool to indicate whether the leave should be allowed or not, all the called validators must return True for the state to be left, the implementation is free to use any mechanism to check but all the validators will be started concurrently so there should be no side-effects that may be relied upon by the other validators, specifically they probably shouldn't alter the object. The validation will not be completed until all the validators run have returned a value.

Alternatively a sub-class can define validator methods with the `leave-validator` trait like:

    method validate-foo(Tinky::Object $obj) returns Bool is leave-validator {
        ...

    }

This may be useful if you have fixed states and wish to substitute runtime complexity.

class Tinky::Transition 
------------------------

A transition is the configured change between two pre-determined states, Only changes described by a transition are allowed to be performed. The transaction class provides for validators that can indicate whether the transition should be applied to an object (distinct from the enter or leave state validators,) and provides a separate supply that emits the object whenever the transition is succesfully applied to an object's state. This higher level of granularity may simplify application logic when in some circumstances than taking both from state and to state individually.

### method new

    method new(Tinky::Transition:U: Str :$!name!, Tinky::State $!from!, Tinky::State $!to!, :@!validators)

The constructor of the class, The `name` parameter must be supplied, it need not be unique but will be used to create a helper method that will be applied to the target Object when the workflow is applied so should be a valid Perl 6 identifier. The mechanism for creating these methods is decribed under [Tinky::Workflow](Tinky::Workflow).

The `from` and `to` states must be supplied, A transition can only be supplied to an object that has a current state that matches `from`.

Additionally an array of ValidateCallback subroutines can be supplied (or added later,) how these are applied is described below.

### method applied

    method applied(Object:D $object)

This is called with the Tinky::Object instance after the transition has been successfully implied, the default implementation arranges for the object instance to be emitted to the transition supply. If this is over-ridden in a sub-class the implementation should call the base implementation with `nextsame` or similar in order that the supply continues to work. It is preferrable however to tap the supply in most cases.

### method validate

    method validate(Object:D $object) returns Promise

This will be called with an instance of Tinky::Object and returns a Promise that will be Kept with True if all of the validators for this transition return True and False otherwise. The way that the validators are called is the same as that for the enter and leave validators of [Tinky::State](Tinky::State).

This can be over-ridden in a sub-class if some other validation mechanism is to be provided but it still must return a Promise, but almost anything that can be done here could be done in a validator subroutine or method anyway.

### method validate-apply

    method validate-apply(Object:D $object) returns Promise

This is the top-level method that is used to check whether a  transition should be applied, it returns a Promise that will be kept with True if all of the promises returned by the transition's `validate`, the `from` state's `leave-validate` and the `to` state's `enter-validate` are kept with True.

It is unlikely that this would need to over-ridden but any sub-class implementation must return a Promise that will be kept with a Bool.

### method supply

    method supply() returns Supply

This returns a [Supply](Supply) to which will be emitted every [Tinky::Object](Tinky::Object) instance that has this transition applied.

Tapping this supply is recommended over creating a sub-class implementation of `apply`.

### method Str

    method Str()

Returns a plausible string representation of the transition.

### method ACCEPTS

    multi method ACCEPTS(State:D $state) returns Bool 
    multi method ACCEPTS(Object:D $object) returns Bool

This is used to smart match the transition against either a [Tinky::State](Tinky::State) (returning True if the State matches the transition's `from` state,) or a [Tink::Object](Tink::Object) (returning True if the object's current state matches the transition's `from` state.)

### attribute validators

This is an array of `ValidationCallback` callables that will be called to validate whether the transition can be applied, only those callbacks will be executed that specify a matching or less specific type than the [Tinky::Object](Tinky::Object) supplied as a parameter, that is to say if the subroutine specifies [Tinky::Object](Tinky::Object) then it will always be executed for any object, if the subroutine specifies a type that does the Tinky::Object role then it will only be called when an object of that type (or a sub-class thereof) is passed.

Alternatively validators can be supplied as methods with the `transition-validator` trait from a sub-class (or another role for example,) such as:

    method my-validator(Tinky::Object:D $obj) returns Bool is transition-validator {
        ...
    }

The same rules for execution based on the signature and the object to which the transition is being applied are true for methods as for validation subroutines.

class Tinky::Workflow 
----------------------

The [Tinky::Workflow](Tinky::Workflow) class brings together a collection of transitions together and provides additional functionality to objects that consume the workflow as well as aggregating  the various [Supply](Supply)s that are provided by State and Transition.

Whilst it is possible that standalone transitions can be applied to any object that does the [Tinky::Object](Tinky::Object) role, certain functionality is not available if workflow is not known.

The application of a Workflow to a Tinky::Object can be subject to a similar form of validation as with State and Transition validators and may useful if a certain workflow is only applicable to a certain type of object for instance, but validators of any complexity are possible.

### method new

    method new(Tinky::Workflow:U: Str :$!name!, :@!transitions!, State :$!initial-state, :@!validators)

The constructor of [Tinky::Workflow](Tinky::Workflow) should be provided with and array of the Transition objects that are part of the workflow and an optional list of ValidatorCallback subroutines, if they are to be used then they must be supplied before the first time a workflow is applied to an object.

If the `initial-state` is supplied this will be be applied to a Tinky::Object with no current state at the time of the workflow application as described below.

The name isn't required but may be useful for identification purposes if there is more than one workflow in a system.

### method states

    method states()

This is an array of the [Tinky::State](Tinky::State) objects that are defined for this workflow, it will be constructed from the unique states found in the transitions of the workflow, this list can be over-ridden by adding to the `states` attribute but this probably doesn't make sense as a state is almost certainly useless if there isn't at least one transition which has it as `from` or `to` state.

### method transitions-for-state

    method transitions-for-state(State:D $state ) returns Array[Transition]

This returns an array of the transitions that have the supplied State as the `from` state, this is used internally but may be useful for example in a user interface if a list of possible transitions is required.

### method find-transition

    multi method find-transition(State:D $from, State:D $to) returns Transition

This returns a Transition that matches the provided `from` and `to` states, ( or a undefined type object otherwise, this may be useful for validating in advance whether a transition to a new state is valid for an object at a given state (any further validations as described above, notwithstanding.)

### method validate-apply

    method validate-apply(Object:D $object) returns Promise

This is called prior to the actual application of the workflow to a Tinky::Object and returns a Promise that will be kept with True if all of the validators and validation methods return True or False otherwise.

This could be over-ridden in a sub-class if some other validation mechanism is required but it must always return a Promise, in most cases however the existing validation mechanisms should be sufficient.

### method applied

    method applied(Object:D $object)

This is called with the Tinky::Object instance to which the workflow has been applied immediately after the application has completed. It will arranged for the object to be emitted onto the `applied-supply`.

If it is over-ridden in a sub-class then it should almost certainly call the base implementation with `nextsame`, though a tap on the `applied-supply` is usually preferrable.

### method applied-supply

    method applied-supply() returns Supply

This is a Supply to which all of the Tinky::Object instances to which the workflow has been applied are emitted.

### method enter-supply

    method enter-supply() returns Supply

This is a Supply which aggregates the `enter-supply` of all the `states` in the Workflow, it will emit a two element array comprising the State object that was entered and the Tinky::Object instance.

### method leave-supply

    method leave-supply() returns Supply

This is a Supply which aggregates the `leave-supply` of all the `states` in the Workflow, it will emit a two element array comprising the State object that was left and the Tinky::Object instance.

### method final-supply

    method final-supply() returns Supply

This returns a Supply onto which are emitted an Array of State and Object whenever an object enters a state from which there are no further transitions possible. It may be useful for notification or cleanup purposes or possibly for activating a transition on another object for instance.

### method transition-supply

    method transition-supply() returns Supply

This returns a Supply that aggregates the `supply` of all the transitions of the workflow, it emits a two element array of the Transition object and the Tinky::Object instance to which it was applied.

This is particularly suitable for example for logging purposes.

### method role

    method role() returns Role

This returns an anonymous role that will be applied to the Tinky::Object when the workflow is applied.

The role provides methods that are named as the transitions and which cause the transition to be applied (throwing an exception if the transition cannot be applied to the current state or if any validators return false.) If two or more transitions share the same name then a single method will be created which will select the appropriate transition based on the current state of the object.

### attribute validators

This is an array of `ValidationCallback` callables that will be called to validate whether the workflow can be applied to an object, only those callbacks will be executed that specify a matching or less specific type than the [Tinky::Object](Tinky::Object) supplied as a parameter, that is to say if the subroutine specifies [Tinky::Object](Tinky::Object) then it will always be executed for any object, if the subroutine specifies a type that does the Tinky::Object role then it will only be called when an object of that type (or a sub-class thereof) is passed.

Alternatively validators can be supplied as methods with the `apply-validator` trait from a sub-class (or another role for example,) such as:

    method my-validator(Tinky::Object:D $obj) returns Bool is apply-validator {
        ...
    }

The same rules for execution based on the signature and the object to which the transition is being applied are true for methods as for validation subroutines.

role Tinky::Object 
-------------------

This is a role that should should be applied to any application object that is to have a state managed by [Tink::Workflow](Tink::Workflow), it provides the mechanisms for transition application and allows the transitions to be validated by the mechanisms described above for [Tinky::State](Tinky::State) and [Tinky::Transition](Tinky::Transition)

### method state

    method state(Object:D: ) is rw

This is read/write method that allows the state of an object to be set directly with a [Tinky::State](Tinky::State) object. If the object has no current state (or the state is being set within the constructor,) then no validation will occur (though obviously it should be a valid state within the workflow for it to be meaningful.) If the state is already set then there must be a valid transition to the required state from the current state otherwise an exception will be thrown, once the transition is resolved it will be passed to `apply-transition` and will be subject to checking by the validators for the states and transition and will throw an exception if it cannot be applied.

### method apply-workflow

    method apply-workflow(Tinky::Workflow:D $wf)

This should be called with the Tinky::Workflow object that is to manage the objects state, it will call the `validators` subroutines of the Workflow and will throw an exception if any return False. If successfull the role provided by the [Tinky::Workflow](Tinky::Workflow) object will be applied and the workflow stored so that it can be used to gain information about the workflow. After succesfull application the Object will be emitted on the Workflow's `applied-supply` which can be tapped to provide any further processing required.

### method apply-transition

    method apply-transition(Tinky::Transition $trans) returns Tinky::State

Applies the transition supplied to the object, if the current state of the object doesn't match the `from` state of transition then an [X::InvalidTransition](X::InvalidTransition) will be thrown, if one or more state or transition validators return False then a [X::TransitionRejected](X::TransitionRejected) exception will be thrown, If the object has no current state then [X::NoState](X::NoState) will be thrown.

If the application is successfull then the state of the object will be changed to the `to` state of the transition and the object will be emitted to the appropriate supplies of the left and entered states and the transition.

### method transitions

    method transitions() returns Array[Transition]

This returns an array of the [Tinky::Transition](Tinky::Transition)s that are available for the object based on their `from` state matching the current state of the object.

### method next-states

    method next-states() returns Array[State]

This returns an Array of the states that are available as the `to` state of the available `transitions`, this may be more convenient for example for a user interface than the raw transitions.

### method transition-for-state

    method transition-for-state(State:D $to-state) returns Transition

This returns the transition that would place the object in the supplied state from its current state (or the Transition type object if there is no such transition.)

### method ACCEPTS

    multi method ACCEPTS(State:D $state) returns Bool 
    multi method ACCEPTS(Transition:D $trans) returns Bool

Used to smart match the object against either a State (returns True if the state matches the current state of the object,) or a Transition (returns True if the `from` state matches the current state of the object.)

EXCEPTIONS
----------

The methods for applying a transition to an object will signal an  inability to apply the transition by means of an exception.

The below documents the location where the exceptions are thrown directly, of course they may be the result of some higher level method.

### class Tinky::X::Fail is Exception 

This is used as a base class for all of the exceptions thrown by Tinky, it will never be thrown itself.

### class Tinky::X::Workflow is X::Fail

This is an additional sub-class of [X::Fail](X::Fail) that is used by some of the other exceptions.

### class Tinky::X::InvalidState is X::Workflow 

### class Tinky::X::InvalidTransition is X::Workflow 

This will be thrown by the helper methods provided by the application of the workflow if the current state of the object does match the `from` state of any of the applicable transitions. It will also be thrown by `apply-transition` if the `from` state of the transition supplied doesn't match the current state of the object.

### class Tinky::X::NoTransition is X::Fail 

This will be thrown when attempting to set the state of the object by assignment when there is no transition that goes from the object's current state to the supplied state.

### class Tinky::X::NoWorkflow is X::Fail 

This is thrown by `transitions` and `transitions-for-state` on the [Tinky::Object](Tinky::Object) if they are called when no workflow has yet been applied to the object.

### class Tinky::X::NoTransitions is X::Fail 

This is thrown by the [Workflow](Workflow) `states` method if it is called and there are no transitions defined.

### class Tinky::X::TransitionRejected is X::Fail 

This is thrown by `apply-transition` when the transition validation resulted in a False value, because the transition, leave state or enter state validators returned false.

### class Tinky::X::ObjectRejected is X::Fail 

This is thrown on `apply-workflow` if one or more of the workflow's apply validators returned false.

### class Tinky::X::NoState is X::Fail 

This will be thrown by apply-transition if there is no current state on the object.
