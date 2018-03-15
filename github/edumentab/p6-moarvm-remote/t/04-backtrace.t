use v6.d.PREVIEW;

use lib $?FILE.IO.sibling("lib");

use Test;

use MoarVM::Remote;
use MoarRemoteTest;

plan 1;


Promise.in(10).then: { note "Did not finish test in 10 seconds. Considering this a failure."; exit 1 }

subtest {
    run_debugtarget (ALLOW-INPUT ALLOW-LOCK Q:to/NQP/), :writable,
        sub outermost_sub() {
            note("looking for data");
            my $first_input := nqp::chr(nqp::atpos_i(read(1), 0));
            note("got data");
            inner_sub($first_input ~ "!");
            inner_sub("!" ~ $first_input);
        }
        sub inner_sub($_) {
            my $this_input := nqp::chr(nqp::atpos_i(read(1), 0));
            say($this_input);
        }
        outermost_sub();
        NQP
    -> $client, $supply, $proc {
        note "let's go!";
        sleep(0.1);
        note "looking to suspend a thread";
        my $suspend-promise = $client.suspend(1);
        sleep(0.1);
        await $proc.print("A"), $suspend-promise;
        is-deeply $suspend-promise.result, True, "could suspend process";
        note "suspended, yay";
        my @frames = await $client.dump(1);
        cmp-ok @frames.map(*.<name>).grep("outermost_sub" | "read" | "<mainline>").head(3),  "~~",
            ["read", "outermost_sub", "<mainline>"], "stack has read, outermost_sub, mainline, in that order";

        await $client.resume(1);

        sleep(0.1);

        $suspend-promise = $client.suspend(1);

        sleep(0.1);

        await $proc.print("B");
        await $suspend-promise;

        @frames = await $client.dump(1);
        cmp-ok @frames.map(*.<name>).grep("inner_sub" |"outermost_sub" | "read" | "<mainline>").head(4),  "~~",
            ["read", "inner_sub", "outermost_sub", "<mainline>"], "stack has read, inner_sub, outermost_sub, mainline, in that order";

    };
};
