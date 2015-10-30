use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

%*ENV<LM_COLOR> = True;
my $log = Log::Minimal.new(:timezone(0));

subtest {
    my $out = capture_stderr {
        $log.critf('critical');
    };

    if $out ~~ m{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' '(.+)' 'at' 't\/050_color\.t' 'line' '11\n$} {
        is $0, "\x[1b][30;41mcritical\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    };
}, 'test for critf';

subtest {
    my $out = capture_stderr {
        $log.warnf('warn');
    };

    if $out ~~ rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[WARN\]' '(.+)' 'at' 't\/050_color\.t' 'line' '23\n$} {
        is $0, "\x[1b][30;43mwarn\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    }
}, 'test for warnf';

subtest {
    my $out = capture_stderr {
        $log.infof('info');
    };

    if $out ~~ rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[INFO\]' '(.+)' 'at' 't\/050_color\.t' 'line' '35\n$} {
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

    if $out ~~ rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[DEBUG\]' '(.+)' 'at' 't\/050_color\.t' 'line' '48\n$} {
        is $0, "\x[1b][31;47mdebug\x[1b][0m";
    } else {
        ok False, 'Not matched to regex';
    }
}, 'test for debugf';

done-testing;
