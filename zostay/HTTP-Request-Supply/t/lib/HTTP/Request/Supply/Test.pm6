unit module HTTP::Request::Supply::Test;
use v6;

use Test;
use HTTP::Request::Supply;

constant @chunk-sizes = 1, 3, 11, 101, 1009;
#constant @chunk-sizes = 3;

sub run-test($envs, @expected is copy) is export {
    my @processing-envs;
    react {
        whenever $envs -> %env {
            my %exp = @expected.shift;

            flunk 'unexpected environment received: ', %env.perl
                unless %exp.defined;

            my $input   = %env<p6w.input> :delete;
            my $content = %exp<p6w.input> :delete;

            my %trailers;
            if %exp<test.trailers>:exists {
                %trailers = %exp<test.trailers> :delete;
            }

            is-deeply %env, %exp, 'environment looks good';

            ok $input.defined, 'input found in environment';

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
                                is-deeply $chunk, %trailers, 'found trailers';
                                %trailers = ();
                            }
                            default {
                                flunk 'unknown body output';
                            }
                        }

                        LAST {
                            is $acc.decode('utf8'), $content, 'message body looks good';
                            flunk 'trailers were not received' if %trailers;
                        }
                    }
                }
                # note "STOP CHUNKING";
            }

            QUIT {
                warn $_;
                flunk $_;
            }
        }
    }


    await @processing-envs;

    is @expected.elems, 0, 'last request received, no more expected?';
}

sub file-reader($test-file, :$size) is export {
    $test-file.open(:r).Supply(:$size, :bin)
}

sub socket-reader($test-file, :$size) is export {
    my Int $port = (rand * 1000 + 10000).Int;

    my $listener = do {
        # note "new listener";
        my $listener = IO::Socket::Async.listen('127.0.0.1', $port);

        my $promised-tap = Promise.new;
        sub close-tap { await $promised-tap.then({ .result.close }) }

        $promised-tap.keep($listener.act: {
            # note "accepted";
            my $input = $test-file.open(:r, :bin);
            while $input.read($size) -> $chunk {
                # note "write ", $chunk;
                await .write: $chunk;
            }
            # note "closing";
            .close;
            # note "closed";
            close-tap;
            # note "not listening";
        });

        # note "ready to connect";
        $listener;
    }

    # When we get here, we should be ready to connect to ourself on the other
    # thread.
    my $conn = await IO::Socket::Async.connect('127.0.0.1', $port);
    # note "connected ", $*THREAD.id;
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
