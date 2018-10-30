use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my $DATETIME = rx/
    (<[+-]>? \d**4 \d*)                            # year
    '-'
    (\d\d)                                         # month
    '-'
    (\d\d)                                         # day
    <[Tt]>                                         # time separator
    (\d\d)                                         # hour
    ':'
    (\d\d)                                         # minute
    ':'
    (\d\d[<[\.,]>\d ** 1..6]?)                     # second
    (<[Zz]> || (<[\-\+]>) (\d\d) (':'? (\d\d))? )? # timezone
/;
my $FILE = 't/020_ff.t';

my $log = Log::Minimal.new(:timezone(0));

my regex timestamp { \d ** 4 '-' \d ** 2 '-' \d ** 2 'T' \d ** 2 ':' \d ** 2 ':' \d ** 2 '.' \d+ 'Z' };

subtest {
    my $out = capture_stderr {
        $log.critff('critical');
    };
    like $out, rx{^ <timestamp> ' [CRITICAL] critical at t/020_ff.t line 28, ' .+ \n $};
}, 'test for critf';

subtest {
    my $out = capture_stderr {
        $log.warnff('warn');
    };
    like $out, rx{^ <timestamp> ' [WARN] warn at t/020_ff.t line 35, ' .+ \n $};
}, 'test for warnff';

subtest {
    my $out = capture_stderr {
        $log.infoff('info');
    };
    like $out, rx{^ <timestamp> ' [INFO] info at t/020_ff.t line 42, ' .+ \n $};
}, 'test for infoff';

subtest {
    temp %*ENV<LM_DEBUG> = 1;
    my $out = capture_stderr {
        $log.debugff('debug');
    };
    like $out, rx{^ <timestamp> ' [DEBUG] debug at t/020_ff.t line 50, ' .+ \n $};
}, 'test for debugff';

subtest {
    dies-ok {
        $log.errorff('error');
    }; # XXX
}, 'test for errorff';

done-testing;
