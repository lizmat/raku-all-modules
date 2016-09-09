unit module HTTP::Request::Supply::Test;
use v6;

use Test;
use HTTP::Request::Supply;

constant @chunk-sizes = 1, 3, 11, 101, 1009;

sub run-test($envs, @expected) is export {
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
            react {
                whenever $input -> $chunk {
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
                }
            }

            is $acc.decode('utf8'), $content, 'message body looks good';

            LAST {
                is @expected.elems, 0, 'last request received, no more expected?';
                flunk 'trailers were not received'
                    if %trailers;
            }

            QUIT {
                warn $_;
                flunk $_;
            }
        }
    }
}

sub run-tests(@tests) is export {
    for @tests -> %test {

        # Run the tests at various chunk sizes
        for @chunk-sizes -> $chunk-size {
            my $test-file = "t/data/%test<source>".IO;
            my $envs = HTTP::Request::Supply.parse-http(
                $test-file.open(:r).Supply(:size($chunk-size), :bin)
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
