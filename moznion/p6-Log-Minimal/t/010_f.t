use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my $log = Log::Minimal.new(:timezone(0));

subtest {
    {
        my $out = capture_stderr {
            $log.critf('critical');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' 'critical' 'at' 't\/010_f\.t' 'line' '11\n$};
    }

    {
        my $out = capture_stderr {
            $log.critf('critical:%s', 'foo');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' 'critical\:foo' 'at' 't\/010_f\.t' 'line' '18\n$};
    }
}, 'test for critf';

subtest {
    {
        my $out = capture_stderr {
            $log.warnf('warn');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[WARN\]' 'warn' 'at' 't\/010_f\.t' 'line' '27\n$};
    }

    {
        my $out = capture_stderr {
            $log.warnf('warn:%s', 'foo');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[WARN\]' 'warn\:foo' 'at' 't\/010_f\.t' 'line' '34\n$};
    }
}, 'test for warnf';

subtest {
    {
        my $out = capture_stderr {
            $log.infof('info');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[INFO\]' 'info' 'at' 't\/010_f\.t' 'line' '43\n$};
    }

    {
        my $out = capture_stderr {
            $log.infof('info:%s', 'foo');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[INFO\]' 'info\:foo' 'at' 't\/010_f\.t' 'line' '50\n$};
    }
}, 'test for infof';

subtest {
    temp %*ENV<LM_DEBUG> = 1;
    {
        my $out = capture_stderr {
            $log.debugf('debug');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[DEBUG\]' 'debug' 'at' 't\/010_f\.t' 'line' '60\n$};
    }

    {
        my $out = capture_stderr {
            $log.debugf('debug:%s', 'foo');
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[DEBUG\]' 'debug\:foo' 'at' 't\/010_f\.t' 'line' '67\n$};
    }
}, 'test for debugf';

subtest {
    dies-ok {
        $log.errorf('error');
    }; # XXX

    dies-ok {
        $log.errorf('error: %s', 'foo');
    }; # XXX
}, 'test for errorf';

done-testing;
