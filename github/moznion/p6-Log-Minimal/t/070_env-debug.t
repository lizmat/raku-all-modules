use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

subtest {
    my $log = Log::Minimal.new(:timezone(0));
    temp %*ENV<LM_DEBUG> = 0;
    my $out = capture_stderr {
        $log.debugf('debug');
    };
    is $out.defined, False;
}, 'should not output log by DEBUG level';

subtest {
    my $log = Log::Minimal.new(:env-debug('LOG_MINIMAL_DEBUG'), :timezone(0));

    {
        temp %*ENV<LOG_MINIMAL_DEBUG> = 0;
        my $out = capture_stderr {
            $log.debugf('debug');
        };
        is $out.defined, False;
    }

    {
        temp %*ENV<LOG_MINIMAL_DEBUG> = 1;
        my $out = capture_stderr {
            $log.debugf('debug');
        };
        is $out.defined, True;
    }
}, 'should be configurable env name';

done-testing;
