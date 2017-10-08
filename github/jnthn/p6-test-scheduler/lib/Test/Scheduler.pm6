my $original-scheduler = INIT $*SCHEDULER;

class X::Test::Scheduler::BackInTime is Exception {
    method message() {
        "Test scheduler can not go backwards in time";
    }
}

class Test::Scheduler does Scheduler {
    my class FutureEvent {
        has &.schedulee is required;
        has $.virtual-time is required;
        has $.reschedule-after;
        has $.cancellation;
    }

    has $!wrapped-scheduler;
    has $.virtual-time = now;
    has $!virtual-target = $!virtual-time;
    has @!future;
    has $!lock = Lock.new;

    submethod BUILD(
        :wrap($!wrapped-scheduler) = $original-scheduler,
        :$!virtual-time = now
    ) { }

    method cue(&code, :$at, :$in, :$every, :$times = 1, :&stop is copy, :&catch ) {
        die "Cannot specify :at and :in at the same time"
          if $at.defined and $in.defined;
        die "Cannot specify :every, :times and :stop at the same time"
          if $every.defined and $times > 1 and &stop;
        my $delay = $at ?? $at - $!virtual-time !! $in // 0;

        # need repeating
        if $every {
            # generate a stopper if needed
            if $times > 1 {
                my $todo = $times;
                my $times-lock = Lock.new;
                &stop = { $times-lock.protect: { $todo ?? !$todo-- !! True } }
            }

            # we have a stopper
            if &stop {
                my $cancellation = Cancellation.new;
                $!lock.protect: {
                    push @!future, FutureEvent.new(
                        schedulee => &catch
                            ?? -> {
                                my $*SCHEDULER = self;
                                stop()
                                    ?? $cancellation.cancel
                                    !! code();
                                CATCH { default { catch($_) } };
                            }
                            !! -> {
                                my $*SCHEDULER = self;
                                stop()
                                    ?? $cancellation.cancel
                                    !! code();
                            },
                        virtual-time => $!virtual-time + $delay,
                        reschedule-after => $every,
                        cancellation => $cancellation
                    );
                }
                self!run-due($!virtual-time);
                return $cancellation;
            }
            # no stopper
            else {
                my $cancellation = Cancellation.new;
                $!lock.protect: {
                    push @!future, FutureEvent.new(
                        schedulee => &catch
                            ?? -> {
                                my $*SCHEDULER = self;
                                code();
                                CATCH { default { catch($_) } } 
                            }
                            !! -> {
                                my $*SCHEDULER = self;
                                code()
                            },
                        virtual-time => $!virtual-time + $delay,
                        reschedule-after => $every,
                        cancellation => $cancellation
                    );
                }
                self!run-due($!virtual-time);
                return $cancellation;
            }
        }

        # only after waiting a bit or more than once
        elsif $delay or $times > 1 {
            my &schedulee := &catch
                ?? -> {
                    my $*SCHEDULER = self;
                    code();
                    CATCH { default { catch($_) } }
                }
                !! -> {
                    my $*SCHEDULER = self;
                    code();
                };
            my $cancellation = Cancellation.new;
            my $virtual-time = $!virtual-time + $delay;
            $!lock.protect: {
                for 1..$times {
                    @!future.push: FutureEvent.new(:&schedulee, :$virtual-time, :$cancellation);
                }
            }
            self!run-due($!virtual-time);
            return $cancellation;
        }

        # just cue the code
        else {
            with @*TEST-SCHEDULER-NESTED -> @nested {
                my $p = Promise.new;
                $!lock.protect: { @nested.push($p) };
                $!wrapped-scheduler.cue(
                    {
                        my $*SCHEDULER = self;
                        code();
                        LEAVE $p.keep(True);
                    },
                    :&catch);
            }
            else {
                $!wrapped-scheduler.cue(
                    {
                        my $*SCHEDULER = self;
                        code()
                    },
                    :&catch);
            }
            return Nil;
        }
    }

    method advance-by($seconds --> Nil) {
        die X::Test::Scheduler::BackInTime.new if $seconds < 0;
        $!virtual-target += $seconds;
        self!run-due();
        $!virtual-time = $!virtual-target;
    }

    method advance-to(Instant $new-virtual-time --> Nil) {
        die X::Test::Scheduler::BackInTime.new if $new-virtual-time < $!virtual-time;
        $!virtual-target = $new-virtual-time;
        self!run-due();
        $!virtual-time = $!virtual-target;
    }

    method !run-due($target = $!virtual-target) {
        loop {
            my (@now, @future) := $!lock.protect: {
                my (:@now, :@future) := @!future.classify: {
                    .virtual-time <= $target ?? 'now' !! 'future'
                }
                return unless @now;
                @!future = ();
                @now, @future
            }

            my @sorted = @now.sort(*.virtual-time);
            for @sorted.kv -> $i, $_ {
                next if .cancellation.?cancelled;
                $!virtual-time = .virtual-time;
                given .schedulee -> &to-run {
                    my $done = Promise.new;
                    $!wrapped-scheduler.cue({
                        my @*TEST-SCHEDULER-NESTED = ();
                        to-run();
                        await Promise.allof(@*TEST-SCHEDULER-NESTED);
                        LEAVE $done.keep(True);
                    });
                    await $done;
                    if $!lock.protect: { so @!future } {
                        @future.append(@sorted[$i + 1 .. *]);
                        last;
                    }
                }
                if .reschedule-after {
                    my $next-time = .virtual-time + .reschedule-after;
                    @future.push(.clone(
                        virtual-time => $next-time
                    ));
                    if $next-time < $target {
                        @future.append(@sorted[$i + 1 .. *]);
                        last;
                    }
                }
            }

            $!lock.protect: { @!future.append(@future) }
        }
    }

    method uncaught_handler(|c) is raw {
        $!wrapped-scheduler.uncaught_handler(|c)
    }

    method handle_uncaught(|c) is raw {
        $!wrapped-scheduler.handle_uncaught(|c)
    }

    method loads(|c) is raw {
        $!wrapped-scheduler.loads(|c)
    }
}
