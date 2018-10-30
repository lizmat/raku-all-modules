unit module HTTP::Request::Supply::Test;
use v6;

use Test;
use HTTP::Request::Supply;

constant @chunk-sizes = 1, 3, 11, 101, 1009;
#constant @chunk-sizes = 3;


multi await-or-timeout(Promise:D $p, Int :$seconds = 5, :$message) {
    await Promise.anyof($p, Promise.in($seconds));
    if $p {
        $p.result;
    }
    else {
        die "operation timed out after $seconds seconds"
            ~ ($message ?? ": $message" !! "");
    }
}

multi await-or-timeout(@p, Int :$seconds = 5, :$message) {
    await-or-timeout(Promise.allof(@p), :$seconds, :$message);
}

sub run-test($envs, @expected is copy) is export {
    my @processing-envs;

    # capture test results in closures for later final evaluation
    my @output;
    react {
        whenever $envs -> %env {
            my %exp = @expected.shift;

            CATCH {
                default { .warn; .rethrow }
            }

            @output.push: {
                flunk 'unexpected environment received: ', %env.perl
                    unless %exp.defined;
            };

            my $input   = %env<p6w.input> :delete;
            my $content = %exp<p6w.input> :delete;

            my %trailers;
            if %exp<test.trailers>:exists {
                %trailers = %exp<test.trailers> :delete;
            }

            @output.push: {
                is-deeply %env, %exp, 'environment looks good';
                ok $input.defined, 'input found in environment';
            };

            my $acc = buf8.new;
            # note "CURRENT LOADS PRE-CHUNKING = ", $*SCHEDULER.loads;
            push @processing-envs, start {
                # note "START CHUNKING";
                react {
                    whenever $input -> $chunk {
                        # note "GOT CHUNK ", $chunk;
                        given $chunk {
                            when Blob { $acc ~= $chunk }
                            when Hash {
                                if $chunk eqv %trailers {
                                    @output.push: { pass 'found trailers' };
                                }
                                else {
                                    @output.push: { flunk 'found trailers' };
                                }
                                %trailers = ();
                            }
                            default {
                                @output.push: { flunk 'unknown body output' };
                            }
                        }

                        LAST {
                            @output.push: {
                                is $acc.decode('utf8'), $content, 'message body looks good';
                                flunk 'trailers were not received' if %trailers;
                            };

                            done;
                        }
                    }
                }
                # note "STOP CHUNKING";
            }

            LAST { done }

            QUIT {
                warn $_;
                @output.push: { flunk $_ };
            }
        }
    }


    await-or-timeout(@processing-envs, :message<processing test environments>);

    # emit test results in order, single threaded
    for @output -> $test-ok {
        $test-ok.();
    }

    is @expected.elems, 0, 'last request received, no more expected?';
}

sub file-reader($test-file, :$size) is export {
    $test-file.open(:r, :bin).Supply(:$size)
}

sub socket-reader($test-file, :$size) is export {
    my Int $port = (rand * 1000 + 10000).Int;

    my $listener = do {
        # note "# new listener";
        my $listener = IO::Socket::Async.listen('127.0.0.1', $port);

        my $promised-tap = Promise.new;
        sub close-tap {
            await-or-timeout(
                $promised-tap.then({ .result.close }),
                :message<connection close>,
            );
        }

        $promised-tap.keep($listener.act: {
            CATCH {
                default { .warn; .rethrow }
            }

            # note "# accepted $*THREAD.id()";
            my $input = $test-file.open(:r, :bin);
            while $input.read($size) -> $chunk {
                # note "# write ", $chunk;
                await-or-timeout(.write($chunk), :message<writing chunk>);
            }
            # note "# closing";
            .close;
            # note "# closed";
            close-tap;
            # note "# not listening";
        });

        # note "# ready to connect";
        $listener;
    }

    # When we get here, we should be ready to connect to ourself on the other
    # thread.
    my $conn = await-or-timeout(
        IO::Socket::Async.connect('127.0.0.1', $port),
        :message<client connnection>,
    );
    # note "# connected  $*THREAD.id()";
    $conn.Supply(:bin);
}

sub run-tests(@tests, :&reader = &file-reader) is export {
    for @tests -> %test {

        # Run the tests at various chunk sizes
        for @chunk-sizes -> $chunk-size {
            # note "chunk size $chunk-size";
            my $test-file = "t/data/%test<source>".IO;
            my $envs = HTTP::Request::Supply.parse-http(
                reader($test-file, :size($chunk-size))
            );

            my @expected = |%test<expected>;

            run-test($envs, @expected);

            CATCH {
                default {
                    note $_;
                    flunk "Because: " ~ $_;
                }
            }
        }
    }
}
