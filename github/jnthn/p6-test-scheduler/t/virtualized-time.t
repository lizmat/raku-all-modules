use Test;
use Test::Scheduler;

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $p = Promise.in(0.001);
    nok $p, 'Promise in 0.001 seconds not kept yet';
    sleep 0.1;
    nok $p, 'Promise in 0.001 seconds not kept even after 0.1 seconds of real time';

    $*SCHEDULER.advance-by(0.001);
    await $p;
    ok $p, 'Promise kept upon advancing scheduler';
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $p = Promise.in(200);
    nok $p, 'Promise in 200 seconds not kept yet';
    for 20, 40 ... 180 {
        $*SCHEDULER.advance-by(20);
        nok $p, "Promise still next kept after advancing scheudler by $_ seconds";
    }
    my $before = now;
    $*SCHEDULER.advance-by(20);
    await $p;
    ok $p, 'Promise kept upon advancing scheduler to 200 seconds';
    ok now - $before < 2, 'Certainly did not take 200 seconds; time is virtual';
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $p1 = Promise.in(20);
    my $p2 = Promise.in(40);

    $*SCHEDULER.advance-by(20);
    await $p1;
    ok $p1, 'Promise 1 in 20s kept upon advancing by 20s';
    my $p3 = Promise.in(10);
    nok $p2, 'Promise at 40s not yet kept';
    nok $p3, 'New promise at 10s (relative to current 20s) not yet kept';

    $*SCHEDULER.advance-by(10);
    await $p3;
    ok $p3, 'Promise 3 kept after a further 10s';
    nok $p2, 'Promise at 40s from start point not yet kept';

    $*SCHEDULER.advance-by(10);
    await $p3;
    ok $p3, 'Promise at 40s kept after a further 10s';

    throws-like { $*SCHEDULER.advance-by(-1) }, X::Test::Scheduler::BackInTime;

    my $p4 = Promise.in(0);
    await $p4;
    ok $p4, 'Promise in 0 seconds is scheduled immediately; no need to advance';
}

{
    my $sim-time = now + 50000;
    my $*SCHEDULER = Test::Scheduler.new(virtual-time => $sim-time);
    is $*SCHEDULER.virtual-time, $sim-time, 'Can set virtual time in constructor';
    $*SCHEDULER.advance-by(10);
    is $*SCHEDULER.virtual-time, $sim-time + 10, 'Virtual time advances';

    my $p1 = Promise.new;
    my $p2 = Promise.new;
    $*SCHEDULER.cue: { $p1.keep(42) }, :at($sim-time + 40);
    $*SCHEDULER.cue: { $p2.keep(101) }, :at($sim-time + 30);
    $*SCHEDULER.advance-by(20);
    is await($p2), 101, 'Scheduling with at works in virtual time (kept at sim + 30s)';
    nok $p1, 'Still not kept promise at sim + 40s yet';

    $*SCHEDULER.advance-by(10);
    is await($p1), 42, 'After another 10s, kept promise at sim + 40s';

    my $p3 = Promise.new;
    $*SCHEDULER.cue: { $p3.keep(22) }, :at($sim-time + 40);
    is await($p3), 22, 'Promise at current virtual time scheduled immediately';

    my $p4 = Promise.new;
    $*SCHEDULER.cue: { $p4.keep(69) }, :at($sim-time + 35);
    is await($p4), 69, 'Promise at earlier virtual time scheduled immediately';
}

{
    my $c = Channel.new;
    my $*SCHEDULER = Test::Scheduler.new;
    $*SCHEDULER.cue: { $c.send('x') }, :in(10), :times(3);
    $*SCHEDULER.advance-by(1);
    nok $c.poll, 'Nothing sent when advancing just 1s';
    $*SCHEDULER.advance-by(4);
    nok $c.poll, 'Nothing sent when advancing another 4s';
    $*SCHEDULER.advance-by(5);
    my @a = $c.receive xx 3;
    is @a, ['x', 'x', 'x'], 'Ran 3 times when got to 10s total time';
}

{
    my $c = Channel.new;
    my $*SCHEDULER = Test::Scheduler.new;
    $*SCHEDULER.cue: { $c.send('x') }, :times(4);
    my @a = $c.receive xx 4;
    is @a, ['x', 'x', 'x', 'x'], ':times used without :in schedules right away';
}

{
    my $sim-time = now + 50000;
    my $*SCHEDULER = Test::Scheduler.new(virtual-time => $sim-time);

    my $p1 = Promise.in(20);
    my $p2 = Promise.in(40);
    $*SCHEDULER.advance-to($sim-time + 20);
    await $p1;
    ok $p1, 'Promise 1 in 20s kept upon advancing to 20s';
    my $p3 = Promise.in(10);
    nok $p2, 'Promise at 40s not yet kept';
    nok $p3, 'New promise in 10s (relative to current 20s) not yet kept';

    $*SCHEDULER.advance-to($sim-time + 30);
    await $p3;
    ok $p3, 'Promise 3 kept after advancing to 30s';
    nok $p2, 'Promise at 40s from start point not yet kept';

    $*SCHEDULER.advance-to($sim-time + 40);
    await $p3;
    ok $p3, 'Promise at 40s kept after advancing to 40s';

    throws-like { $*SCHEDULER.advance-to($sim-time + 39) },
        X::Test::Scheduler::BackInTime;
}

{
    my $sim-time = now + 50000;
    my $*SCHEDULER = Test::Scheduler.new(virtual-time => $sim-time);
    $*SCHEDULER.advance-to($sim-time + 10);
    is $*SCHEDULER.virtual-time, $sim-time + 10,
        'Virtual time can be advanced with advance-to';

    my $p1 = Promise.new;
    my $p2 = Promise.new;
    $*SCHEDULER.cue: { $p1.keep(42) }, :at($sim-time + 40);
    $*SCHEDULER.cue: { $p2.keep(101) }, :at($sim-time + 30);
    $*SCHEDULER.advance-to($sim-time + 30);
    is await($p2), 101, 'Scheduling with at works when using advance-to';
    nok $p1, 'Still not kept promise at sim + 40s yet';

    $*SCHEDULER.advance-to($sim-time + 40);
    is await($p1), 42,
        'After advancing to 40s past start time, kept promise at sim + 40s';

    my $p3 = Promise.new;
    $*SCHEDULER.cue: { $p3.keep(22) }, :at($sim-time + 40);
    is await($p3), 22,
        'Promise at current virtual time scheduled immediately having used advance-to';

    my $p4 = Promise.new;
    $*SCHEDULER.cue: { $p4.keep(69) }, :at($sim-time + 35);
    is await($p4), 69,
        'Promise at earlier virtual time scheduled immediately having used advance-to';
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $s = Supply.interval(10);
    my $c = Channel.new;
    $s.tap: { $c.send($_) }
    is $c.receive, 0, 'Supply.interval zero value scheduled right away';

    my $real-start = now;
    nok $c.poll, 'No more values available before advancing scheduler';
    $*SCHEDULER.advance-by(10);
    is $c.receive, 1, 'After advancing by 10s, get one more value';

    nok $c.poll, 'No more values available before advancing scheduler again';
    $*SCHEDULER.advance-by(20);
    is $c.receive, 2, 'After advancing by a further 20s, get one more value...';
    is $c.receive, 3, '...and another value';

    ok now - $real-start < 5, 'Certainly scheduling using virtual time';
}

{
    my $*SCHEDULER = Test::Scheduler.new();
    my $p = Promise.new;
    my $canc = $*SCHEDULER.cue: { $p.keep(42) }, :in(20);
    $canc.cancel();
    $*SCHEDULER.advance-by(20);
    nok $p, 'Cancelled scheduled work does not run...';
    sleep 0.1;
    nok $p, '...even after giving it a little time';
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $c = Channel.new;
    my $canc = $*SCHEDULER.cue: { state $i = 0; $c.send($i++) }, :every(10);
    is $c.receive, 0, ':every zero value scheduled right away';
    nok $c.poll, 'No more values available before advancing scheduler';

    $*SCHEDULER.advance-by(10);
    is $c.receive, 1, 'After advancing by 10s, get one more value';
    nok $c.poll, 'No more values after 10s';

    $canc.cancel;
    $*SCHEDULER.advance-by(10);
    nok $c.poll, 'No value after cancellation then a further 10s';
    $*SCHEDULER.advance-by(10);
    nok $c.poll, 'Same after a further 10s...';
    sleep 0.1;
    nok $c.poll, '...even after giving it a little time';
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $c = Channel.new;
    my $stop = False;
    my $canc = $*SCHEDULER.cue: { state $i = 0; $c.send($i++) },
        :every(10),
        :stop({ $stop });
    is $c.receive, 0, ':every + :stop zero value scheduled right away';
    nok $c.poll, 'No more values available before advancing scheduler';

    $*SCHEDULER.advance-by(10);
    is $c.receive, 1, 'After advancing by 10s, get one more value';
    nok $c.poll, 'No more values after 10s';

    $stop = True;
    $*SCHEDULER.advance-by(10);
    nok $c.poll, 'No value after stopper became true';
    $*SCHEDULER.advance-by(10);
    nok $c.poll, 'Same after a further 10s...';
    sleep 0.1;
    nok $c.poll, '...even after giving it a little time';
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $c = Channel.new;
    $*SCHEDULER.cue: { state $i = 0; $c.send($i++) }, :every(10), :times(3);
    is $c.receive, 0, ':every + :times(3) zero value scheduled right away';
    nok $c.poll, 'No more values available before advancing scheduler';

    $*SCHEDULER.advance-by(10);
    is $c.receive, 1, 'After advancing by 10s, get one more value';
    nok $c.poll, 'No more values after 10s';

    $*SCHEDULER.advance-by(10);
    is $c.receive, 2, 'After advancing by a further 10s, get one more value';
    nok $c.poll, 'No more values after 10s';

    $*SCHEDULER.advance-by(10);
    nok $c.poll, 'No forth value due to :times(3)';
    $*SCHEDULER.advance-by(10);
    nok $c.poll, 'Same after a further 10s...';
    sleep 0.1;
    nok $c.poll, '...even after giving it a little time';
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $c = Channel.new;
    for reverse 1..20 -> $i {
        Promise.in($i).then({ $c.send($i) })
    }
    $*SCHEDULER.advance-by(20);
    ok [<]($c.receive xx 20), 'Events are scheduled in the right order';
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $c = Channel.new;
    my $p1 = Promise.in(1).then({ Promise.in(1).then({ $c.send('a') }) });
    my $p2 = Promise.in(3).then({ $c.send('b') });

    $*SCHEDULER.advance-by(4);
    is $c.receive, 'a', 'Scheduling order respects nested scheduling order (1)';
    is $c.receive, 'b', 'Scheduling order respects nested scheduling order (2)';
}

done-testing;
