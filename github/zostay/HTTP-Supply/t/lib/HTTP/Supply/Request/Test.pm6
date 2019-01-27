use v6;

use HTTP::Supply::Test;
unit class HTTP::Supply::Request::Test is HTTP::Supply::Test;

use Test;
use HTTP::Supply::Request;

method run-test($envs, @expected is copy, :%quits) {
    my @processing-envs;

    # capture test results in closures for later final evaluation
    my @output;
    react {
        whenever $envs -> %env {
            my %exp = try { @expected.shift } // %();

            CATCH {
                default {
                    .note; .rethrow
                }
            }

            @output.push: {
                flunk 'unexpected environment received: ', %env.perl
                    without %exp;
            };

            my $input   = %env<p6w.input> :delete;
            my $content = %exp<p6w.input> :delete;

            my @trailers;
            if %exp<test.trailers>:exists {
                @trailers := %exp<test.trailers> :delete;
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
                            when List {
                                self.headers-equivalent($chunk, @trailers);
                                @trailers := ();
                            }
                            default {
                                @output.push: { flunk 'unknown body output' };
                            }
                        }

                        LAST {
                            @output.push: {
                                is $acc.decode('utf8'), $content, 'message body looks good';
                                flunk 'trailers were not received' if @trailers;
                            };

                            done;
                        }

                        QUIT {
                            when %quits<body> {
                                @output.push: {
                                    pass 'Body quit on expected error.';
                                }
                            }
                            default {
                                .note;
                                @output.push: {
                                    flunk 'Body quit on expected error.';
                                }
                            }
                        }
                    }
                }
                # note "STOP CHUNKING";
            }

            LAST {
                if %quits<on> :exists {
                    @output.push: {
                        flunk "Quit on expected error.";
                    }
                };
                done
            }

            QUIT {
                when %quits<on> {
                    @output.push: {
                        pass "Quit on expected error.";
                    }
                }
                default {
                    .note;
                    @output.push: { flunk $_ };
                }
            }
        }
    }

    self.await-or-timeout(@processing-envs, :message<processing test environments>);

    # emit test results in order, single threaded
    for @output -> $test-ok {
        $test-ok.();
    }

    is @expected.elems, 0, 'last request received, no more expected?';
}

method test-class { HTTP::Supply::Request }

