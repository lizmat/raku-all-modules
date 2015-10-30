use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my $log = Log::Minimal.new(:timezone(0));

subtest {
    my $out = capture_stderr {
        $log.critff('critical');
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' 'critical' 'at' 't\/020_ff\.t' 'line' '10 ',' .+\n$};
}, 'test for critf';

subtest {
    my $out = capture_stderr {
        $log.warnff('warn');
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[WARN\]' 'warn' 'at' 't\/020_ff\.t' 'line' '17 ',' .+\n$};
}, 'test for warnff';

subtest {
    my $out = capture_stderr {
        $log.infoff('info');
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[INFO\]' 'info' 'at' 't\/020_ff\.t' 'line' '24 ',' .+\n$};
}, 'test for infoff';

subtest {
    temp %*ENV<LM_DEBUG> = 1;
    my $out = capture_stderr {
        $log.debugff('debug');
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[DEBUG\]' 'debug' 'at' 't\/020_ff\.t' 'line' '32 ',' .+\n$};
}, 'test for debugff';

subtest {
    dies-ok {
        $log.errorff('error');
    }; # XXX
}, 'test for errorff';

done-testing;

