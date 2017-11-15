use v6.c;
unit class Timer::Breakable:ver<0.1.0>:auth<Simon Proctor "simon.proctor@gmail.com">;

=begin pod

=head1 NAME

Timer::Breakable - Timed block calls that can be broken externally.

=head1 SYNOPSIS

=begin code

use Timer::Breakable;

my $timer = Timer::Breakable.start( 10, { say "Times up" } );
... Stuff occurs ...
$timer.break if $variable-from-stuff;

say $timer.result if $timer.status ~~ Kept;

=end code

=head1 DESCRIPTION

Timer::Breakable is wrapper aroud the standard Promise.in() functionality that lets you stop the timer without running it's block.

=head2 PUBLIC ATTRIBUTES

=head3 promise

A vowed promise that can be handed to await, anyof or allof. Note that the promises status and results can be accessed from the Timer::Breakable object directly.

=end pod

has Promise $.promise = Promise.new();
has atomicint $!lock = 0;
has $!vow;

=begin pod

=head2 PUBLIC METHODS

=head3 start( $time where * > 0, &block )

Factory method to start the timer. Expects the time to run and the block to run on completion.

=end pod

method start( Timer::Breakable:U: $time where * > 0, &block ) {
    my $timer = self.bless();
    $timer!init( $time, &block );
    return $timer;
}

method !init( $time where * > 0, &block ) {
    Promise.in($time).then(
        {
            try {
                self!kill( block => &block );
                CATCH {
                    when X::Promise::Vowed { say "Should not happen in timer" }
                }
            }
        }
    );
    $!vow = $.promise.vow;
    return self;
}

method !kill( :$keep = True, :&block = sub{} ) {
    return if atomic-fetch-inc( $!lock ) > 0;
    $keep ?? $!vow.keep( &block() ) !! $!vow.break( Nil );
}

=begin pod

=head3 stop()

Stops the timer. Note that the timer itself will still run to completion but the given block will not be run.

=end pod

method stop() {
    self!kill( keep => False );
}

=begin pod

=head3 status()

As per Promise.status()

=end pod


method status() {
    return $.promise.status;
}

=begin pod

=head3 result()

As per Promise.result()

=end pod


method result() {
    return $.promise.result;
}

=begin pod

=head1 NOTES

Version 0.1.0 updated the object creation to use start as a factory method.

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
