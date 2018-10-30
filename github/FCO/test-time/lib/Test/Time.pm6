=begin pod

=head1 Test::Time

Use B<Test::Scheduler> to use on your tests, not only Promises, but B<sleep>, B<now> and time.

=begin code
my $started = now;
$*SCHEDULER = mock-time :auto-advance;

sleep 10;
say "did it passed { now - $started } seconds?";
unmock-time;

say "No, just passed { now - $started } seconds!";

#`{{{
Output:
    did it passed 10.0016178 seconds?
    No, just passed 0.07388266 seconds!
}}}
=end code

Or you can use C<$*SCHEDULER.advance-by: 10> as you would when using B<Test::Scheduler>
=end pod

use Test::Scheduler;
my %wraps;

sub unmock-time is export {
    die "Time isn't mocked yet";
}

sub mock-time(Instant $now is copy = now, Bool :$auto-advance = False, Rat() :$interval = .1 --> Scheduler) is export {
    my $*SCHEDULER = Test::Scheduler.new: :virtual-time($now);

    my $tai = now - time;
    %wraps<sleep> = &sleep.wrap: -> \seconds {
        await Promise.in: seconds;
        Nil
    }

    %wraps<now>     = &term:<now>.wrap:  { $*SCHEDULER.virtual-time }
    %wraps<time>    = &term:<time>.wrap: { (now - $tai).Int }
    %wraps<unmock>  = &unmock-time.wrap: {
        &sleep.unwrap:          %wraps<sleep>;
        &term:<now>.unwrap:     %wraps<now>;
        &term:<time>.unwrap:    %wraps<time>;
        &unmock-time.unwrap:    %wraps<unmock>;

        %wraps = ()
    }

    start {
        while %wraps.elems {
            $*SCHEDULER.advance-by: $interval
        }
    } if $auto-advance;

    $*SCHEDULER
}
