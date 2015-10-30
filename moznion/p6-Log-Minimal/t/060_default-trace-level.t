use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

subtest {
    my $log = Log::Minimal.new(:default-trace-level(2), :timezone(0));
    my $out = capture_stderr {
        $log.critf('critical');
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' 'critical' 'at' 't\/060_default\-trace\-level\.t' 'line' '8\n$}
}, 'test for default-trace-level';

done-testing;
