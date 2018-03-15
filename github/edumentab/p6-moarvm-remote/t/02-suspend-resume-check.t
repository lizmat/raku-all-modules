use v6.d.PREVIEW;

use lib $?FILE.IO.sibling("lib");

use Test;

use MoarRemoteTest;

plan 4;

Promise.in(10).then: { note "Did not finish test in 10 seconds. Considering this a failure."; exit 1 }

run_debugtarget("nqp::sleep(1)", :start-suspended,
    -> $client, $supply, $proc {
        is-deeply (await $client.is-execution-suspended()), True, "start-suspended starts program suspended";
    });

note "running the other thing";
run_debugtarget("say('alive'); nqp::sleep(5)",
    -> $client, $supply, $proc {
        my $got-alive = False;
        my $got-execution = Bool;
        my $reached-timeout = False;
        react {
            whenever $supply {
                when :stdout(/ alive /) {
                    $got-alive = True;
                    last;
                }
                when :event(Proc) {
                    die "Process exited with error" unless .value.exitcode == 0;
                    done;
                }
            }
            whenever $client.is-execution-suspended() {
                $got-execution = $_;
                whenever Promise.in(1) {
                    $proc.kill;
                }
            }
            whenever Promise.in(3) {
                say "the timeout fired";
                $reached-timeout = True;
                done;
            }
        }
        is-deeply $got-execution, False, "program starts in non-suspended state";
        ok $got-alive, "code was executed";
        nok $reached-timeout, "code did not reach timeout";
    });
