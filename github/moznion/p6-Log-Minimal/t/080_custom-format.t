use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my regex timestamp { \d ** 4 '-' \d ** 2 '-' \d ** 2 'T' \d ** 2 ':' \d ** 2 ':' \d ** 2 '.' \d+ 'Z' };

subtest {
    my $log = Log::Minimal.new(:timezone(0));
    $log.print = sub (:$time, :$log-level, :$messages, :$trace) {
        note "$trace $messages [$log-level] $time";
    }

    my $out = capture_stderr {
        $log.warnf('msg');
    }
    like $out, rx{'at t/080_custom-format.t line 15 msg [WARN] ' <timestamp> \n $}
}, 'custom print';

done-testing;
