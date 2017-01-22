use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my regex timestamp { \d ** 4 '-' \d ** 2 '-' \d ** 2 'T' \d ** 2 ':' \d ** 2 ':' \d ** 2 '.' \d+ 'Z' };

%*ENV<LM_COLOR> = True;
my $log = Log::Minimal.new(:timezone(0));

subtest {
    my $out = capture_stderr {
        $log.critf('critical');
    };

    if $out ~~ m{^ <timestamp> ' [CRITICAL] ' (.+) ' at t/050_color.t line 13' \n $} {
        is $0, "\x[1b][30;41mcritical\x[1b][0m";
    } else {
		$0.encode.note;
        ok False, 'Not matched to regex';
    };
}, 'test for critf';

subtest {
    my $out = capture_stderr {
        $log.warnf('warn');
    };

    if $out ~~ rx{^ <timestamp> ' [WARN] ' (.+) ' at t/050_color.t line 26' \n $} {
        is $0, "\x[1b][30;43mwarn\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    }
}, 'test for warnf';

subtest {
    my $out = capture_stderr {
        $log.infof('info');
    };

    if $out ~~ rx{^ <timestamp> ' [INFO] ' (.+) ' at t/050_color.t line 38' \n $} {
        is $0, "\x[1b][32minfo\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    }
}, 'test for infof';

subtest {
    temp %*ENV<LM_DEBUG> = 1;
    my $out = capture_stderr {
        $log.debugf('debug');
    };

    if $out ~~ rx{^ <timestamp> ' [DEBUG] ' (.+) ' at t/050_color.t line 51' \n $} {
        is $0, "\x[1b][31;47mdebug\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    }
}, 'test for debugf';

done-testing;
