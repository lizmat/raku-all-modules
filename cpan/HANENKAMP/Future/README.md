NAME
====

Future - A futuristic extension to Promises and other awaitables

SYNOPSIS
========

    use Future;

    # Works like Promise.start({})
    my $f = Future.start: { long-running-process() };
    my $result = await $f;

    # Or from a Promise.new
    my $p = Promise.new;
    my $f = Future.from-promise($p);
    $p.keep(42);
    my $result = await $f;

    # But you can add types
    my Future[Int] $f .= start: { long-running-process() };
    my $result = await $f; # guaranteed to be an Int or throws exception
    CATCH { when X::Future::Mismatch { .say } }

    # And nested Futures automatically unravel nested Futures/Promises
    my $f = Future.start: {
        start { 42 }
    }
    say await $f; # prints 42, not Promise.new(...)

    # Callback chains have entirely different semantics from Promise
    # - catch() - allows you to handle exceptions
    # - then() - allows for asynchronous processing
    my Future[Int] $i = Future.start(
        { open('file.txt', :r) }
    ).catch(
        -> X::IO { open('alt.txt', :r) }
    ).catch(
        -> X::IO { "42" }
    ).then(
        -> Str $val { $val.Numeric },
        -> IO::Handle $fh { $fh.slurp.Numeric },
    ).constrain(Int);

    say await $i;

DESCRIPTION
===========

**EXPERIMENTAL.** This is an experimental API. Suggestions welcome.

Promises are wonderful, but having become accustomed to some of the features of promises in other languages, I found a few things lacking. I wanted to make something that made Promises a little nicer to work with. So to the [Future](Future).

A [Future](Future) is just a placeholder for a future value. It does not directly provide any means of resolving that value. Instead, it depends on something else to eventually provide that value:

  * The `.start()` method takes a block which will run on a new thread. The return value from the block becomes the future value.

  * The `.awaitable()` method takes any object that can be used with `await`. The Future will get the value of that object whenever `await` returns it.

  * The `.immediate()` takes a value which immediately fulfills the Future.

  * The `.exceptional()` takes an [Exception](Exception), which creates a rejected Future.

This means a Future can get its value from basically anything, including a [Promise](Promise), [Supply](Supply), or [Channel](Channel).

A [Future](Future) provides asynchronous callbacks similar to those of [Promise](Promise). These will be called when the future is fulfilled or rejected. This is different from a [Promise](Promise), whose callbacks are only called when the Promise is kept. The callbacks are executed using a form of multi-dispatch, so multiple alternative callbacks can be provided and the callback chosen is based upon its signature.

The action of the callbacks is based on the method used to register them:

  * `.then()` These callbacks are executed on fulfillment.

  * `.catch()` These callbacks are executed on rejection.

Each of these return a new [Future](Future) that will be fulfilled after the original Future is fulfilled and the callback completes. The actual semantics of how each these calls work is subtly different, but are loosely based upon the differences in how Perl 6 handles multi-subs, CATCH-blocks, and LAST-blocks.

A [Future](Future) is also type-aware. I often want to return a [Promise](Promise) from a method, but then I have to explicitly document what that Promise is actually supposed to return. This is no longer a problem with Future:

    # This is bleh
    method fib($n --> Promise) { ... }

    # This is nice
    method fib($n --> Future[Int]) { ... }

You can create a [Future](Future) with an explicitly parameterized type or you can use the `.constrain()` method to take an existing Future and apply that type expectation. The latter should be done at the end of a callback chain because it's only the final fulfillment that ought to be constrained to the final result type. (Though, you may, of course, constrain the intermediate steps if you like.)

Finally, a [Future](Future) will recursively await anything that is `await`-able. All concurrent objects built-in to Perl 6 provide an await function that can be used to wait for a value from another thread to become available whtin the current thread. This means that any time a Future encounters an object that can be awaited, it will await that return before continuing.

GOALS
=====

Why has this module been created? This module's purpose is to create an interface based on [Promise](Promise) that has a few features which can make it nicer to work with as a developer. These goals are based upon my own experience working with promise-type tools in other languages, such as Perl 5, JavaScript, and Scala. It does not try to implement a particular interface from that experience, but tries to remain true to idiomatic Perl 6 in style and implementation instead.

Here are the primary goals I had in mind, contrasted with the behavior of [Promise](Promise):

  * * A [Future](Future) should have the ability to use chains of callback to handle exceptional conditions. A [Promise](Promise) does not call any callbacks if the Promise is broken. To handle an exception, you must do something like nested `start` blocks with the outer start block `await`ing an inner block and catching the exception that may be rethrown.

  * * A [Future](Future) should be parameterized by type. A [Promise](Promise) may be kept with any kind of value. One advantage of a type-system is that it is self-documenting. By examining the types accepted as parameters or returned, its often possible to infer what a subroutine does. A Promise provides some useful information about the immediate type, but no indication as to what it could become in the future.

FUTURE STATES
=============

A [Future](Future) has three possible states:

  * * **Pending.** A pending Future is one that may either become fulfilled or become rejected. It might also remain pending indefinitely. This corresponds to the Planned state of [Promise](Promise).

  * * **Fulfilled.** A fulfilled Future is complete and has a value. This is a stop state and the Future is not able to transition out of this status. This corresponds to the Kept state of [Promise](Promise).

  * * **Rejected.** A rejected Future is failed with an exception. This is a stop state and the Future is not able to transition out of this status. This corresponds to the Broken state of [Promise](Promise).

While a particular [Future](Future) object is unable to transition out of a fulfilled or rejected stop state, you can transform the Future using a callback. Callbacks will construct a new future, which can have a different state than the one the callback starts with.

METHODS
=======

method awaitable
----------------

    method awaitable(Future:U: $p --> Future:D)

This constructs and returns a new [Future](Future) based around the given [Promise](Promise) or other awaitable object. The Future will be fulfilled or rejected whenever the underlying Promise or other `await`-able is fulfilled or rejected.

The following is mostly a reiteration of the documentation for `await`, but here's a quick rundown of how each behaves when wrapped in a [Future](Future).

### Promise

The [Future](Future) will remain pending as long as the [Promise](Promise) is Planned. The Future will become fulfilled when the Promise is Kept or rejected when the Promise is broken.

### Channel

The [Future](Future) remains pending until the next value is sent to the underlying [Channel](Channel). At that time, the Future becomes fulfilled with that value. If the Channel is closed before a value is sent, the Future is rejected.

### Supply

The [Future](Future) is held pending until the [Supply](Supply) emits all values and is done. The Future will become fulfilled with the final value emitted at that point. If, isntead, the Supply quits, the [Future](Future) becomes rejected.

method start
------------

    method start(Future:U: &block --> Future:D)

You can think of this as a shortcut for:

    Future.awaitable(start { ... });

The given `&block` will be scheduled to run on the next available thread. Then, this method constructs and returns a [Future](Future) whose outcome will be based upon the outcome of that block. If the block exits normally, the result of the block will become the fulfilled Future value. If, instead, the block throws an exception, the Future is rejected with that exception.

method immediate
----------------

    method immediate(Future:U: $value --> Future:D)

This method constructs and returns a Future that is already fulfilled with the given value.

method exceptional
------------------

    method exceptional(Future:U: Exception $x --> Future:D)

This method constructs and returns a Future that is already rejected with the given [Exception](Exception).

method is-pending
-----------------

    method is-pending(Future:D: --> Bool)

Returns True while the [Future](Future) is pending and not yet either fulfilled or rejected. Therefore, the following invariant will always be true:

    .is-pending ?? !.is-fulfilled && !.is-rejected !! .is-fulfilled || .is-rejected

Once this becomes False, it will always be False.

method is-fulfilled
-------------------

    method is-fulfilled(Future:D: --> Bool)

Returns True if the [Future](Future) has been fulfilled with a value. Once this becomes True it will always be True.

method is-rejected
------------------

    method is-rejected(Future:D: --> Bool)

Returns True if the [Future](Future) has been rejected with an [Exception](Exception). Once this becomes True it will always be True.

method then
-----------

    method then(Future:D: *@callbacks --> Future:D)

This method constructs and returns a new [Future](Future). When the original invocant is fulfilled, a callback will be selected based on the outcome of the original Future's fulfillment. For example:

    my $v = await Future.start({ 41 }).then(
        -> Str $s { $s.Int },
        -> Int $i { $i + 1 },
    );
    say $v; #> 42

The callback with a signature matching the original value will be chosen. Exactly one callback must apply to the value or an exception will be thrown. If multiple callbacks may apply, you should use the `is default` trait to distinguish which is preferred. The goal here is to act as much like a multi-sub as possible. (Though, the exceptions thrown are [X::Future::NoMatch](X::Future::NoMatch) and [X::Future::Ambiguous](X::Future::Ambiguous) rather than the Perl counterparts for multis.)

The outcome of the callback is then used to determine the outcome of the newly constructed [Future](Future). If the block exits normally, the resulting value will be the fulfilled value of the Future. If the block exits with an exception, that exception will be used for the rejection of that Future.

If the Future is rejected, none of these callbacks are called and the [Future](Future) becomes rejected with the same exception as the original invocant:

    await Future.start({ die 42 }).then(
        -> Str $s { $s.Int }, # ignored
        -> Int $i { $i + 1 }, # ignored
    );

    CATCH { .payload.say }
    #> 42

When going from one [Future](Future) to the next in the `.then()` callback chain, the results of each Future earlier in the chain is treated as a [Capture](Capture). This means that by using Capture objects directly (or, if you prefer, lists or hashes to create Capture-like objects indirectly), you can very nicely chain complex results from one [Future](Future) to the next:

    Future.start({ \(42, :!beeblebrox) }).then(
        -> $answer, :$beeblebrox = True { ... }
    });

method catch
------------

    method catch(Future:D: *@callbacks --> Future:D)

This method constructs and returns a new [Future](Future). When the original invocant is rejected, a callback will be selected based on teh outcome of the original Future's rejection. For example:

    my $v = await Future({ die 42 }).then(
        -> X::AdHoc $x { .payload }),
        -> X::IO $x { $x.rethrow }),
    );
    say $v; #> 42

The callback with a signature matching the original Future's rejected Exception value will be chosen. The first matching callback is accepted and it is acceptable for no callback to match (in which case, the returned Future will be rejected with the same exception as the original). The goal is to act as much as possible like a CATCH-block.

The outcome of the callback is used to determine the outcome of the newly constructure [Future](Future). If the block exits normally, the resulting value will be the fulfilled value of the Future. If the block exits with an exception, that exception will be used for the rejection of that Future.

If the original [Future](Future) is fulfilled, the callbacks will be ignored and the new Future in the chain will be fulfilled with the same value as the previous.

method constrain
----------------

    method constrain(Future:D: Mu \type --> Future:D)

Given a type name, this constructs a new Future constrained to that type. It is most useful in situations where you want to add a type constraint on the end-product but the intermediate steps in the callback chain can be something different:

    # This example is trivial, but makes the point
    sub calculate(Int $i --> Future[Str]) {
        Future.start({
            (1..*).grep(*.is-prime)[$i]
        }).then({ .Str }).constrain(Str);
    }

    my Future[Str] $p = calculate(10_000_000_000);
    say await $p;

It constrains the type. It is up to the [Future](Future) to make sure the correct type is actually fulfilled. If the fulfilled type does not match the constraint, the Future is rejected with an [X::Future::Mismatch](X::Future::Mismatch) exception.

method result
-------------

    method result(Future:D: --> Mu)

This will return the fulfilled result of the [Future](Future) or throw the [Exception](Exception) the future was rejected with. This will block until a value becomes available.

sub await
---------

    sub await(Future:D $future --> Mu)

This will return the fulfilled result of the [Future](Future) or throw the [Exception](Exception) the future was rejected with. This will block until a value becomes available.

DIAGNOSTICS
===========

Here are the exceptions that are specifically added by this class. Please note that there may be other exceptions thrown by a [Future](Future) that are just standard Perl exceptions. See the documentation of exceptions for Perl and Rakudo, especially regarding exceptions that may be thrown by `await`.

X::Future
---------

All of the special exceptions that may be thrown by the [Future](Future) itself will implement this base exception.

X::Future::NoMatch
------------------

This is roughly equivalent to [X::Multi::NoMatch](X::Multi::NoMatch) and occurs when none of the callbacks listed in a callback chain are unable to handle the incoming value.

X::Future::Ambiguous
--------------------

This is rougly equivalent to [X::Multi::Ambiguous](X::Multi::Ambiguous) and occurs when more than one callback listed could resolve the callback value. If this could be possible, it is recommended that you add the `is default` trait to one of the callbacks.

X::Future::Mismatch
-------------------

This is thrown when the [Future](Future) is fulfilled with a value that does not match the parameterized type constraint of the Future.

### method expected

    method expected(X::Future::Mismatch:D: --> Mu)

Returns the type constraint of the [Future](Future).

### method got

    method got(X::Future::Mismatch:D: --> Mu)

Returns the value that failed the type constraint.

