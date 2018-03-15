use v6.d.PREVIEW;

use Test;
use MoarVM::Remote;

use nqp;

sub run_debugtarget($code, &checker, :$start-suspended, :$writable) is export {
    my $prefix = nqp::backendconfig<prefix>;

    my $moarbinpath = %*ENV<DEBUGGABLE_MOAR_PATH>.?IO // $prefix.IO.add("bin/moar");

    my $nqplibdir = $prefix.IO.add("share/nqp/lib");
    my $nqpprogpath = $nqplibdir.add("nqp.moarvm");

    my @pre-command  = $moarbinpath.absolute, "--libpath=" ~ $nqplibdir.absolute;
    my @post-command = $nqpprogpath.absolute, "-e", $code;

    my $supplier = Supplier::Preserving.new;

    my $conn-refused-retries = 0;

    for (1000 ^..^ 65536).pick(*) -> $port {
        my $try-sock = IO::Socket::INET.new(:localhost("localhost"), :localport($port), :listen(True));
        $try-sock.close;

        my $proc = Proc::Async.new(|@pre-command, "--debug-port=$port", |("--debug-suspend" if $start-suspended), |@post-command, |%("w" => True if $writable));

        react {
            whenever $proc.stderr.lines {
                when / "Address already in use" / {
                    die "Address already in use"
                }
                when / "Unknown flag --debug-port=" / {
                    die "MoarVM binary at $moarbinpath doesn't understand debugger flags. Please set the environment variable DEBUGGABLE_MOAR_PATH to a moar binary that does."
                }
                when / "SORRY" / {
                    die "Program could not be run: $_";
                }
                say "STDERR: " ~ $_ for $_.lines;
                $supplier.emit("stderr" => $_);
            }

            whenever $proc.stdout.lines {
                $supplier.emit("stdout" => $_);
            }

            whenever $proc.start {
                if .status === PromiseStatus::Broken {
                    .result.self
                }
                $supplier.emit("event" => $_);
                $supplier.done;
                last;
            }

            whenever $proc.ready {
                whenever MoarVM::Remote.connect($port) -> $client {
                    whenever start { checker($client, $supplier.Supply, $proc) } {
                        $proc.kill;
                    }
                    QUIT {
                        note "Checker failed to run";
                        say $_;
                        $proc.kill;
                        die $_;
                    }
                }
            }
        }
        last;

        CATCH {
            next if .Str.contains("Address already in use");
            if .Str.contains("connection refused" | "Permission denied") && $conn-refused-retries++ < 5 {
                sleep(0.1);
                redo;
            }
        }
        $conn-refused-retries = 0;
    }
}

sub ALLOW-INPUT($code) is export { Q:to/NQP/ ~ $code }
    # allow input
    sub create_buf($type) {
        my $buf := nqp::newtype(nqp::null(), 'VMArray');
        nqp::composetype($buf, nqp::hash('array', nqp::hash('type', $type)));
        nqp::setmethcache($buf, nqp::hash('new', method () {nqp::create($buf)}));
        $buf;
    };

    my $buf8 := create_buf(uint8);

    sub read($count) {
        nqp::readfh(nqp::getstdin, $buf8.new, $count)
    }
    NQP

sub ALLOW-LOCK($code) is export { Q:to/NQP/ ~ $code }
    # Let's have a lock
    class Lock is repr('ReentrantMutex') { }
    NQP

my $testsubject = ALLOW-INPUT ALLOW-LOCK Q:to/NQP/;
    my @locks;

    sub do_thread($lock_number) {
        say("OK R$lock_number");
        nqp::lock(nqp::atpos(@locks, $lock_number));
        say("OK U$lock_number");
        nqp::sleep(0.3);
    }

    my @threads;

    while 1 {
        my $result := nqp::readfh(nqp::getstdin(), $buf8.new(), 2);
        my $opcode := nqp::chr(nqp::atpos_i($result, 0));
        my $arg := +nqp::chr(nqp::atpos_i($result, 1));
        if $opcode eq "T" { # spawn thread
            nqp::push(@threads, nqp::newthread({ do_thread($arg) }, 0));
            say("OK T$arg");
        } elsif $opcode eq "R" { # run thread
            nqp::threadrun(@threads[$arg]);
        } elsif $opcode eq "L" { # create a locked lock
            my $l := Lock.new;
            nqp::lock($l);
            nqp::bindpos(@locks, $arg, $l);
            say("OK L$arg");
        } elsif $opcode eq "U" { # unlock lock
            nqp::unlock(@locks[$arg]);
        } elsif $opcode eq "J" { # join thread
            nqp::threadjoin(@threads[$arg]);
            say("OK J$arg");
        } elsif $opcode eq "Q" { # quit gracefully
            last;
        } else {
            note("unknown operation requested: $opcode");
            nqp::exit(1);
        }
    }
    say("OK...");
    NQP

my %command_to_letter =
    CreateThread => "T",
    RunThread => "R",
    CreateLock => "L",
    UnlockThread => "U",
    JoinThread => "J",
    Quit => "Q";

sub run_testplan(@plan is copy, $description = "test plan") is export {
    subtest {

    run_debugtarget $testsubject, :writable,
    -> $client, $supply, $proc {
        my $outputs =
            $supply.grep({ .key eq "stdout" }).map(*.value).Channel;

        my $testsubject-exited = $supply.grep({ .key eq "event" && .value ~~ Proc }).Promise;

        my $reactions = $client.events
                .grep({ .<type> == any(MT_ThreadStarted, MT_ThreadEnded) })
                .Channel;

        while @plan {
            if $testsubject-exited.status === PromiseStatus::Kept {
                ok False, "The test subject exited!";
                last;
            }
            given @plan.shift {
                when Positional | Seq {
                    note "positional or seq";
                    @plan.prepend(@$_);
                }
                when .key eq "command" {
                    my $wants-await = True;
                    my $wants-send  = True;
                    if .value.key eq "async" {
                        $_ = command => .value.value;
                        $wants-await = False;
                    }
                    if .value.key eq "finish" {
                        $_ = command => .value.value;
                        $wants-send = False;
                    }

                    my $command = .value ~~ Pair ?? .value.key !! .value;
                    my $arg = .value ~~ Pair ?? .value.value !! 0;
                    my $to-send =
                        (%command_to_letter{$command} // die "command type not understood: $_.value()")
                        ~ $arg;
                    if $wants-send {
                        lives-ok {
                            await $proc.print: $to-send;
                        }, "sent command $command to process";
                    }
                    if $wants-await {
                        if $command ne "Quit" {
                            is-deeply (try await $outputs), "OK $to-send", "command $command executed";
                        } else {
                            is-deeply (try await $outputs), "OK...", "quit the program";
                        }
                    }
                }
                when .key eq "assert" {
                    if .value eq "NoEvent" {
                        await Promise.in(0.1);
                        is-deeply $reactions.poll, Nil, "no events received";
                    }
                    elsif .value eq "NoOutput" {
                        await Promise.in(0.1);
                        is-deeply $outputs.poll, Nil, "no outputs received";
                    }
                    else {
                        die "Do not understand this assertion: $_.value()";
                    }
                }
                when .key eq "receive" {
                    die unless .value ~~ Positional;
                    subtest {
                        my $received = try await $reactions;
                        cmp-ok $received, "~~", Hash, "an event successfully received";
                        for .value {
                            if .value.VAR.^name eq "Scalar" && not .value.defined {
                                lives-ok {
                                    .value = $received{.key};
                                }, "stored result from key $_.key()";
                            } else {
                                cmp-ok $received{.key}, "~~", .value, "check event's $_.key() against $_.value.perl()";
                            }
                        }
                    }, "receive an event";
                }
                when .key eq "send" {
                    my $commandname = .value.key.head;
                    my @params = .value.key.skip;

                    @params .= map({ $_ = $_.() if $_ ~~ Callable; $_ });

                    my $prom = $client."$commandname"(|@params);

                    given .value {
                        if .value.VAR.^name eq "Scalar" && not .value.defined {
                            lives-ok {
                                .value = $prom;
                            }, "stashed away result promise for later";
                        } else {
                            cmp-ok (try await $prom), "~~", .value, "check remote's answer against $_.value.perl()";
                        }
                    }
                }
                when .key eq "planned" {
                    my $prom = .value;
                    is-deeply $prom.status, PromiseStatus::Planned, "promise still planned";
                }
                when .key eq "await" {
                    my Mu $checker = .value.key;
                    my $prom = .value.value;

                    note "awaiting a promise...";
                    cmp-ok (await $prom), "~~", .value, "check remote's answer against $_.value.perl()";
                    note "done";
                }
                when .key eq "execute" {
                    .value.();
                }
                default {
                    die "unknown command in test plan: $_.perl()";
                }
            }
        }
    };

    }, $description;
}
