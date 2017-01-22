use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my regex timestamp { \d ** 4 '-' \d ** 2 '-' \d ** 2 'T' \d ** 2 ':' \d ** 2 ':' \d ** 2 '.' \d+ 'Z' };

subtest {
    my $log = Log::Minimal.new(:timezone(0));
    my $out = capture_stderr {
        $log.critf("s\r\n\te");
    };
    like $out, rx{^ <timestamp> ' [CRITICAL] s\\r\\n\\te at t/040_escape-white-space.t line 11' \n $};
}, 'default, escape white space';

subtest {
    my $log = Log::Minimal.new(:escape-whitespace(False), :timezone(0));
    my $out = capture_stderr {
        $log.critf("s\r\n\te");
    };
    like $out, rx{^ <timestamp> " [CRITICAL] s\r\n\te at t/040_escape-white-space.t line 19" \n $};
}, 'do not escape white space';

done-testing;
