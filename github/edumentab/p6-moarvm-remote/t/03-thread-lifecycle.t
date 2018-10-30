use v6.d.PREVIEW;

use lib $?FILE.IO.sibling("lib");

use Test;

use MoarVM::Remote;
use MoarRemoteTest;

plan 2;


Promise.in(10).then: { note "Did not finish test in 10 seconds. Considering this a failure."; exit 1 }

{
my $T0-id;
run_testplan [
    command => CreateLock => 0,
    command => CreateThread => 0,
    assert  => "NoEvent",
    command => RunThread => 0,
    receive =>
            [type => MT_ThreadStarted,
             thread => $T0-id,
             app_lifetime => 0],
    assert  => "NoEvent",
    assert  => "NoOutput",
    command => UnlockThread => 0,
    receive =>
            [type => MT_ThreadEnded,
             thread => $T0-id],
    assert  => "NoEvent",
    assert  => "NoOutput",
    command => JoinThread => 0,
    command => Quit => 0,
]
}

{
my ($T0-id, $T1-id);
my @initial_threads;
run_testplan [
    send    => <threads-list> =>
        -> @threads {
            is-deeply @threads.first(*.<thread> == 1).<num_locks>, 0,
                "main thread has no locks held";
            @initial_threads = @threads>>.<thread>;
        },
    command => CreateLock => 0,
    command => CreateLock => 1,
    send    => <threads-list> =>
        -> @threads {
            is-deeply @threads.first(*.<thread> == 1).<num_locks>, 2,
                "two locks created and held show up";
        },
    command => CreateThread => 0,
    command => CreateThread => 1,
    assert  => "NoEvent",
    command => RunThread => 0,
    receive =>
            [type => MT_ThreadStarted,
             thread => $T0-id,
             app_lifetime => 0],
    command => RunThread => 1,
    receive =>
            [type => MT_ThreadStarted,
             thread => $T1-id,
             app_lifetime => 0],
    assert  => "NoOutput",
    command => UnlockThread => 0,
    send    => <threads-list> =>
        -> @threads {
            is-deeply @threads.first(*.<thread> == 1).<num_locks>, 1,
                "one lock unlocked shows up.";
            is-deeply @threads.first(*.<thread> == $T0-id).<num_locks>, 1,
                "one lock now held by first thread shows up";
        },
    receive =>
            [type => MT_ThreadEnded,
             thread => $T0-id],
    assert  => "NoEvent",
    assert  => "NoOutput",
    command => JoinThread => 0,
    command => UnlockThread => 1,
    send    => <threads-list> =>
        -> @threads {
            is-deeply @threads.first(*.<thread> == 1).<num_locks>, 0,
                "all locks unlocked shows up.";
            is-deeply @threads.first(*.<thread> == $T1-id).<num_locks>, 1,
                "one lock now held by second thread shows up";
        },
    command => Quit => 0,
]
}
