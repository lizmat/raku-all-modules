use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

subtest {
    my $log = Log::Minimal.new(:timezone(0));
    $log.print = sub (:$time, :$log-level, :$messages, :$trace) {
        note "$trace $messages [$log-level] $time";
    }

    my $out = capture_stderr {
        $log.warnf('msg');
    }
    like $out, rx{at' 't\/080_custom\-format\.t' 'line' '13' 'msg' '\[WARN\]' '<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z\n$}
}, 'custom print';

done-testing;
