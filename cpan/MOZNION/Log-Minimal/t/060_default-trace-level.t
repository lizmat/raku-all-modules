use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my regex timestamp { \d ** 4 '-' \d ** 2 '-' \d ** 2 'T' \d ** 2 ':' \d ** 2 ':' \d ** 2 '.' \d+ 'Z' };

subtest {
    my $log = Log::Minimal.new(:default-trace-level(2), :timezone(0));
    my $out = capture_stderr {
        $log.critf('critical');
    };
    like $out, rx{^ <timestamp> ' [CRITICAL] critical at t/060_default-trace-level.t line 10' \n $}
}, 'test for default-trace-level';

done-testing;
