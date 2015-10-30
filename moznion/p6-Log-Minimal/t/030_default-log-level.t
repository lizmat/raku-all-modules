use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

subtest {
    my $log = Log::Minimal.new(:default-log-level(Log::Minimal::MUTE), :timezone(0));
    my $out = capture_stderr {
        $log.critf('critical');
        $log.warnf('warn');
        $log.infof('info');
        $log.debugf('debug');

        $log.critff('critical');
        $log.warnff('warn');
        $log.infoff('info');
        $log.debugff('debug');
    };
    is $out.defined, False;

    dies-ok {
        $log.errorf('error');
    };
    is $log.default-log-level, Log::Minimal::MUTE, 'should roll back the default-log-level';

    dies-ok {
        $log.errorff('error');
    };
    is $log.default-log-level, Log::Minimal::MUTE, 'should roll back the default-log-level';
}, 'when mute';

subtest {
    my $log = Log::Minimal.new(:default-log-level(Log::Minimal::CRITICAL), :timezone(0));
    {
        my $out = capture_stderr {
            $log.warnf('warn');
            $log.infof('info');
            $log.debugf('debug');

            $log.warnff('warn');
            $log.infoff('info');
            $log.debugff('debug');
        };
        is $out.defined, False;
    }
    {
        my $out = capture_stderr {
            $log.critf('critical');
        };
        is $out.defined, True;
    }
    {
        my $out = capture_stderr {
            $log.critff('critical');
        };
        is $out.defined, True;
    }
}, 'when CRITICAL';

done-testing;
