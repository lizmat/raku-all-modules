use v6;

class X::Future is Exception { }

my sub sigs(:$tried, :@found) {
    my $tried-sig = ":(" ~ @($tried).map({ .^name }).join(", ") ~ ")";
    my @found-sigs = @found.map({ .signature.gist });
    \(:$tried-sig, :@found-sigs);
}

class X::Future::NoMatch is X::Future {
    has $.handler;
    has $.tried;
    has @.found;

    method message(--> Str:D) {
        my (:$tried-sig, :@found-sigs) := sigs(:$!tried, :@!found);
        "Cannot resolve .$!handler() called with $tried-sig; none of these signatures match:\n"
            ~ join("\n", @found-sigs.map({ .indent(4) }))
    }
}

class X::Future::Ambiguous is X::Future {
    has $.handler;
    has $.tried;
    has @.found;

    method message(--> Str:D) {
        my (:$tried-sig, :@found-sigs) := sigs(:$!tried, :@!found);
        "Cannot resolve .$!handler() called with $tried-sig; these signatures all match:\n"
            ~ join("\n", @found-sigs.map({ .indent(4) }))
    }
}

class X::Future::Mismatch is X::Future {
    has $.expected;
    has $.got;

    method message(--> Str:D) {
        "Future[$!expected.^name()] type mismatch; expected $!expected.^name() but got $!got.^name()"
    }
}

my enum ValueStatus <Rejected Fulfilled>;

role Future:ver<0.1>:auth<cpan:hanenkamp@cpan.org>[::Type = Any] {
    has Promise $!metal;

    method !get-metal() { $!metal }
    method !set-metal($metal) { $!metal = $metal }

    only method new(Future:) { die "Future.new cannot be used to create a Future." }

    method !new-future(Promise $p) {
        my $f = self.bless;
        $f!set-metal($p);
        $f
    }

    method awaitable(Future: $p --> Future:D) {
        my &promise-handler = self!make-promise-handler-into-future-handler({ await $p });

        my $f = self.bless;
        $f!set-metal(start { promise-handler() });
        $f
    }

    method immediate(Future: $v --> Future:D) {
        my $f = self.bless;
        my $p = Promise.new;
        $p.keep(\(Fulfilled, $v));
        $f!set-metal($p);
        $f;
    }

    method exceptional(Future: Exception $x --> Future:D) {
        my $f = self.bless;
        my $p = Promise.new;
        $p.keep(\(Rejected, $x));
        $f!set-metal($p);
        $f;
    }

    method is-pending(Future:D: --> Bool) { $!metal.status ~~ Planned }
    method is-rejected(Future:D: --> Bool) { !$.is-pending && !$.is-fulfilled }
    method is-fulfilled(Future:D: --> Bool) {
        $!metal.status ~~ Kept
            && $!metal.result[0] ~~ Fulfilled
            && $!metal.result[1] ~~ Type
    }

    method !make-promise-handler-into-future-handler(&handler) {
        anon sub future-handler(|c) {
            try {
                CATCH { default { return \(Rejected, $_) } }

                my $new-result = handler(|c);
                try {
                    my $c = \(|$new-result);
                    $new-result = await(|$c);
                }

                return \(Fulfilled, $new-result);
            }
        }
    }

    method !best-callable(@callbacks, $capture, :$handler) {
        # make sure the "capture" is a Capture
        my $c = \(|$capture);

        my @callable = @callbacks.grep({ $c ~~ &^cb.signature });
        if @callable == 0 {
            X::Future::NoMatch.new(
                :$handler, :tried($c), :found(@callbacks),
            ).throw;
        }
        elsif @callable > 1 {
            my @default = @callable.grep({ .?default });
            if @default == 1 {
                return @default[0];
            }
            else {
                X::Future::Ambiguous.new(
                    :$handler, :tried($c), :found(@callable),
                ).throw;
            }
        }
        else {
            return @callable[0];
        }
    }

    multi method then(Future:D: *@callbacks --> Future:D) {
        self!new-future(
            $!metal.then(sub ($p) {
                my $result = $p.result;
                if $result[0] ~~ Fulfilled {
                    try {
                        CATCH {
                            default {
                                return \(Rejected, $_);
                            }
                        }

                        my $c = \(|$result[1]);
                        my &callback = self!best-callable(@callbacks, $result[1], :handler<then>);
                        return .(|$c) with self!make-promise-handler-into-future-handler(&callback);
                    }
                }
                else {
                    return \(Rejected, $result[1]);
                }
            }),
        );
    }

    multi method catch(Future:D: *@callbacks --> Future:D) {
        self!new-future(
            $!metal.then(sub ($p) {
                my $result = $p.result;
                if $result[0] ~~ Rejected {
                    try {
                        CATCH {
                            default {
                                return \(Rejected, $_);
                            }
                        }

                        my $c = \($result[1]);
                        for @callbacks -> &callback {
                            next unless $c ~~ &callback.signature;
                            return .(|$c) with self!make-promise-handler-into-future-handler(&callback);
                        }

                        return \(Rejected, $result[1]);
                    }
                }
                else {
                    return \(Fulfilled, $result[1]);
                }
            }),
        );
    }

    # EXPERIMENTAL!!! This will probably go away.
    method last(Future:D: &callback --> Future:D) {
        self!new-future(
            $!metal.then(sub ($p) {
                my $result = $p.result;
                my $c = \(|$result[1]);
                try {
                    CATCH {
                        default {
                            return \(Rejected, $_);
                        }
                    }

                    callback();
                }

                return $result;
            }),
        );
    }

    method constrain(Future:D: Mu \type --> Future:D) {
        Future[type].new( metal => $!metal );
    }

    method result(Future:D: --> Mu) {
        my $result = $!metal.result;
        if $result[0] ~~ Fulfilled {
            my $v = $result[1];
            if $v ~~ Type {
                return $v;
            }
            else {
                X::Future::Mismatch.new(:expected(Type), :got($v)).throw;
            }
        }
        else {
            $result[1].rethrow;
        }
    }

    method start(Future: &code --> Future:D) {
        my &future-code = self!make-promise-handler-into-future-handler(&code);
        Future!new-future(start { future-code() });
    }
}

multi await(Future $future --> Mu) is export { $future.result }

=begin pod
=head1 NAME

Future - A futuristic extension to Promises and other awaitables

=head1 SYNOPSIS

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

=head1 DESCRIPTION

B<EXPERIMENTAL.> This is an experimental API. Suggestions welcome.

Promises are wonderful, but having become accustomed to some of the features of
promises in other languages, I found a few things lacking. I wanted to make
something that made Promises a little nicer to work with. So to the L<Future>.

A L<Future> is just a placeholder for a future value. It does not directly
provide any means of resolving that value. Instead, it depends on something else
to eventually provide that value:

=item The C<.start()> method takes a block which will run on a new thread. The
return value from the block becomes the future value.

=item The C<.awaitable()> method takes any object that can be used with
C<await>.  The Future will get the value of that object whenever C<await>
returns it.

=item The C<.immediate()> takes a value which immediately fulfills the Future.

=item The C<.exceptional()> takes an L<Exception>, which creates a rejected Future.

This means a Future can get its value from basically anything, including a
L<Promise>, L<Supply>, or L<Channel>.

A L<Future> provides asynchronous callbacks similar to those of L<Promise>.
These will be called when the future is fulfilled or rejected. This is different
from a L<Promise>, whose callbacks are only called when the Promise is kept. The
callbacks are executed using a form of multi-dispatch, so multiple alternative
callbacks can be provided and the callback chosen is based upon its signature.

The action of the callbacks is based on the method used to register them:

=item C<.then()> These callbacks are executed on fulfillment.

=item C<.catch()> These callbacks are executed on rejection.

Each of these return a new L<Future> that will be fulfilled after the original
Future is fulfilled and the callback completes.  The actual semantics of how
each these calls work is subtly different, but are loosely based upon the
differences in how Perl 6 handles multi-subs, CATCH-blocks, and LAST-blocks.

A L<Future> is also type-aware. I often want to return a L<Promise> from a
method, but then I have to explicitly document what that Promise is actually
supposed to return. This is no longer a problem with Future:

    # This is bleh
    method fib($n --> Promise) { ... }

    # This is nice
    method fib($n --> Future[Int]) { ... }

You can create a L<Future> with an explicitly parameterized type or you can use
the C<.constrain()> method to take an existing Future and apply that type
expectation. The latter should be done at the end of a callback chain because
it's only the final fulfillment that ought to be constrained to the final result
type. (Though, you may, of course, constrain the intermediate steps if you
like.)

Finally, a L<Future> will recursively await anything that is C<await>-able. All
concurrent objects built-in to Perl 6 provide an await function that can be used
to wait for a value from another thread to become available whtin the current
thread. This means that any time a Future encounters an object that can be
awaited, it will await that return before continuing.

=head1 GOALS

Why has this module been created? This module's purpose is to create an
interface based on L<Promise> that has a few features which can make it nicer to
work with as a developer. These goals are based upon my own experience working
with promise-type tools in other languages, such as Perl 5, JavaScript, and
Scala. It does not try to implement a particular interface from that experience,
but tries to remain true to idiomatic Perl 6 in style and implementation
instead.

Here are the primary goals I had in mind, contrasted with the behavior of
L<Promise>:

=item * A L<Future> should have the ability to use chains of callback to handle
exceptional conditions. A L<Promise> does not call any callbacks if the Promise
is broken. To handle an exception, you must do something like nested C<start>
blocks with the outer start block C<await>ing an inner block and catching the
exception that may be rethrown.

=item * A L<Future> should be parameterized by type. A L<Promise> may be kept
with any kind of value. One advantage of a type-system is that it is
self-documenting. By examining the types accepted as parameters or returned, its
often possible to infer what a subroutine does. A Promise provides some useful
information about the immediate type, but no indication as to what it could
become in the future.

=head1 FUTURE STATES

A L<Future> has three possible states:

=item * B<Pending.> A pending Future is one that may either become fulfilled or
become rejected. It might also remain pending indefinitely. This corresponds to
the Planned state of L<Promise>.

=item * B<Fulfilled.> A fulfilled Future is complete and has a value. This is a
stop state and the Future is not able to transition out of this status. This
corresponds to the Kept state of L<Promise>.

=item * B<Rejected.> A rejected Future is failed with an exception. This is a
stop state and the Future is not able to transition out of this status. This
corresponds to the Broken state of L<Promise>.

While a particular L<Future> object is unable to transition out of a fulfilled
or rejected stop state, you can transform the Future using a callback.
Callbacks will construct a new future, which can have a different state than the
one the callback starts with.

=head1 METHODS

=head2 method awaitable

    method awaitable(Future:U: $p --> Future:D)

This constructs and returns a new L<Future> based around the given L<Promise> or
other awaitable object. The Future will be fulfilled or rejected whenever the
underlying Promise or other C<await>-able is fulfilled or rejected.

The following is mostly a reiteration of the documentation for C<await>, but
here's a quick rundown of how each behaves when wrapped in a L<Future>.

=head3 Promise

The L<Future> will remain pending as long as the L<Promise> is Planned. The
Future will become fulfilled when the Promise is Kept or rejected when the
Promise is broken.

=head3 Channel

The L<Future> remains pending until the next value is sent to the
underlying L<Channel>. At that time, the Future becomes fulfilled with that
value. If the Channel is closed before a value is sent, the Future is
rejected.

=head3 Supply

The L<Future> is held pending until the L<Supply> emits all values and is
done. The Future will become fulfilled with the final value emitted at that
point. If, isntead, the Supply quits, the L<Future> becomes rejected.

=head2 method start

    method start(Future:U: &block --> Future:D)

You can think of this as a shortcut for:

    Future.awaitable(start { ... });

The given C<&block> will be scheduled to run on the next available thread. Then,
this method constructs and returns a L<Future> whose outcome will be based upon
the outcome of that block. If the block exits normally, the result of the block
will become the fulfilled Future value. If, instead, the block throws an
exception, the Future is rejected with that exception.

=head2 method immediate

    method immediate(Future:U: $value --> Future:D)

This method constructs and returns a Future that is already fulfilled with the
given value.

=head2 method exceptional

    method exceptional(Future:U: Exception $x --> Future:D)

This method constructs and returns a Future that is already rejected with the
given L<Exception>.

=head2 method is-pending

    method is-pending(Future:D: --> Bool)

Returns True while the L<Future> is pending and not yet either fulfilled or
rejected.  Therefore, the following invariant will always be true:

    .is-pending ?? !.is-fulfilled && !.is-rejected !! .is-fulfilled || .is-rejected

Once this becomes False, it will always be False.

=head2 method is-fulfilled

    method is-fulfilled(Future:D: --> Bool)

Returns True if the L<Future> has been fulfilled with a value. Once this becomes
True it will always be True.

=head2 method is-rejected

    method is-rejected(Future:D: --> Bool)

Returns True if the L<Future> has been rejected with an L<Exception>. Once this
becomes True it will always be True.

=head2 method then

    method then(Future:D: *@callbacks --> Future:D)

This method constructs and returns a new L<Future>. When the original invocant
is fulfilled, a callback will be selected based on the outcome of the original
Future's fulfillment. For example:

    my $v = await Future.start({ 41 }).then(
        -> Str $s { $s.Int },
        -> Int $i { $i + 1 },
    );
    say $v; #> 42

The callback with a signature matching the original value will be chosen.
Exactly one callback must apply to the value or an exception will be thrown. If
multiple callbacks may apply, you should use the C<is default> trait to
distinguish which is preferred. The goal here is to act as much like a multi-sub
as possible. (Though, the exceptions thrown are L<X::Future::NoMatch> and
L<X::Future::Ambiguous> rather than the Perl counterparts for multis.)

The outcome of the callback is then used to determine the outcome of the newly
constructed L<Future>. If the block exits normally, the resulting value will be
the fulfilled value of the Future. If the block exits with an exception, that
exception will be used for the rejection of that Future.

If the Future is rejected, none of these callbacks are called and the L<Future>
becomes rejected with the same exception as the original invocant:

    await Future.start({ die 42 }).then(
        -> Str $s { $s.Int }, # ignored
        -> Int $i { $i + 1 }, # ignored
    );

    CATCH { .payload.say }
    #> 42

When going from one L<Future> to the next in the C<.then()> callback chain, the
results of each Future earlier in the chain is treated as a L<Capture>. This
means that by using Capture objects directly (or, if you prefer, lists or hashes
to create Capture-like objects indirectly), you can very nicely chain complex
results from one L<Future> to the next:

    Future.start({ \(42, :!beeblebrox) }).then(
        -> $answer, :$beeblebrox = True { ... }
    });

=head2 method catch

    method catch(Future:D: *@callbacks --> Future:D)

This method constructs and returns a new L<Future>. When the original invocant
is rejected, a callback will be selected based on teh outcome of the original
Future's rejection. For example:

    my $v = await Future({ die 42 }).then(
        -> X::AdHoc $x { .payload }),
        -> X::IO $x { $x.rethrow }),
    );
    say $v; #> 42

The callback with a signature matching the original Future's rejected Exception
value will be chosen. The first matching callback is accepted and it is
acceptable for no callback to match (in which case, the returned Future will be
rejected with the same exception as the original). The goal is to act as much as
possible like a CATCH-block.

The outcome of the callback is used to determine the outcome of the newly
constructure L<Future>. If the block exits normally, the resulting value will be
the fulfilled value of the Future. If the block exits with an exception, that
exception will be used for the rejection of that Future.

If the original L<Future> is fulfilled, the callbacks will be ignored and the
new Future in the chain will be fulfilled with the same value as the previous.

=head2 method constrain

    method constrain(Future:D: Mu \type --> Future:D)

Given a type name, this constructs a new Future constrained to that type. It is
most useful in situations where you want to add a type constraint on the
end-product but the intermediate steps in the callback chain can be something
different:

    # This example is trivial, but makes the point
    sub calculate(Int $i --> Future[Str]) {
        Future.start({
            (1..*).grep(*.is-prime)[$i]
        }).then({ .Str }).constrain(Str);
    }

    my Future[Str] $p = calculate(10_000_000_000);
    say await $p;

It constrains the type. It is up to the L<Future> to make sure the correct type
is actually fulfilled. If the fulfilled type does not match the constraint, the
Future is rejected with an L<X::Future::Mismatch> exception.

=head2 method result

    method result(Future:D: --> Mu)

This will return the fulfilled result of the L<Future> or throw the L<Exception>
the future was rejected with. This will block until a value becomes available.

=head2 sub await

    sub await(Future:D $future --> Mu)

This will return the fulfilled result of the L<Future> or throw the L<Exception>
the future was rejected with. This will block until a value becomes available.

=head1 DIAGNOSTICS

Here are the exceptions that are specifically added by this class. Please note
that there may be other exceptions thrown by a L<Future> that are just
standard Perl exceptions. See the documentation of exceptions for Perl and
Rakudo, especially regarding exceptions that may be thrown by C<await>.

=head2 X::Future

All of the special exceptions that may be thrown by the L<Future> itself will
implement this base exception.

=head2 X::Future::NoMatch

This is roughly equivalent to L<X::Multi::NoMatch> and occurs when none of the
callbacks listed in a callback chain are unable to handle the incoming value.

=head2 X::Future::Ambiguous

This is rougly equivalent to L<X::Multi::Ambiguous> and occurs when more than
one callback listed could resolve the callback value. If this could be possible,
it is recommended that you add the C<is default> trait to one of the callbacks.

=head2 X::Future::Mismatch

This is thrown when the L<Future> is fulfilled with a value that does not match
the parameterized type constraint of the Future.

=head3 method expected

    method expected(X::Future::Mismatch:D: --> Mu)

Returns the type constraint of the L<Future>.

=head3 method got

    method got(X::Future::Mismatch:D: --> Mu)

Returns the value that failed the type constraint.

=end pod
