use v6;

use HTTP::Supply::Test;
unit class HTTP::Supply::Response::Test is HTTP::Supply::Test;

use Test;
use HTTP::Supply::Response;

method run-test($resps, @expected is copy, :%quits) {
    my @processing-resps;

    # capture test results in closures for later final evaluation
    my @output;
    react {
        whenever $resps -> @res {
            my @exp := try { @expected.shift } // @();

            CATCH {
                default {
                    .note; .rethrow;
                }
            }

            @output.push: {
                flunk 'unexpected response received: ', @res.perl
                    without @exp;
            };

            my $code = @res[0];
            my @headers := @res[1];
            my $output = @res[2];

            my @trailers = @exp.elems > 3 ?? |@exp[3] !! ();

            @output.push: {
                self.headers-equivalent: @headers, @exp[1];
            };

            my $acc = buf8.new;

            push @processing-resps, start {
                react {
                    whenever $output -> $chunk {
                        given $chunk {
                            when Blob { $acc ~= $chunk }
                            when List {
                                self.headers-equivalent($chunk, @trailers, :test<trailers>);
                                @trailers := ();
                            }
                            default {
                                @output.push: { flunk 'unknown body output' };
                            }
                        }

                        LAST {
                            @output.push: {
                                is $acc.decode('utf8'), @exp[2], 'message body looks good';
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

    self.await-or-timeout(@processing-resps, :message<processing test responses>);

    # emit test results in order, single threaded
    for @output -> $test-ok {
        $test-ok.();
    }

    is @expected.elems, 0, 'last request received, no more expected?';
}

method test-class { HTTP::Supply::Response }

