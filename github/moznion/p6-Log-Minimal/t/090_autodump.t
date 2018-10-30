use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my regex timestamp { \d ** 4 '-' \d ** 2 '-' \d ** 2 'T' \d ** 2 ':' \d ** 2 ':' \d ** 2 '.' \d+ 'Z' };

subtest {
    {
        my $log = Log::Minimal.new(:autodump(True), :timezone(0));
        my $out = capture_stderr {
            $log.critf({foo => 'bar'});
        };
        like $out, rx{^ <timestamp>  ' [CRITICAL] :foo("bar") at t/090_autodump.t line 12' \n $};
    }

    {
        my $log = Log::Minimal.new(:timezone(0));
        {
            temp $log.autodump = True;

            my $out = capture_stderr {
                $log.critf('%s', {foo => 'bar'});
            };
            like $out, rx{^ <timestamp> ' [CRITICAL] :foo("bar") at t/090_autodump.t line 23' \n $};
        }
        is $log.autodump, False;
    }
}, 'test for critf';

done-testing;
