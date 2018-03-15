use v6.d.PREVIEW;

use lib $?FILE.IO.sibling("lib");

use Test;

use MoarVM::Remote;
use MoarRemoteTest;

plan 1;


Promise.in(10).then: { note "Did not finish test in 10 seconds. Considering this a failure."; exit 1 }

{
my @threads;
my $suspend-all-promise;
run_testplan [
    |(
      command => CreateLock => $++,
      command => CreateThread => $++,
      command => RunThread => $++,
      receive =>
              [type => MT_ThreadStarted,
               thread => @threads[$++],
               app_lifetime => 0],
    ) xx 4,
    assert  => "NoEvent",
    assert  => "NoOutput",
    send    => ("suspend", *) => True,
    send    => ("resume", 1) => True,
    command => async => UnlockThread => 0,
    assert  => "NoEvent",
    command => async => UnlockThread => 1,
    assert  => "NoEvent",
    command => async => UnlockThread => 2,
    assert  => "NoEvent",
    command => async => UnlockThread => 3,
    assert  => "NoOutput",
    send    => ["resume", { @threads[0] }] => True,
    command => finish => UnlockThread => 0,
    command => JoinThread => 0,
    command => Quit => 0,
]
}
