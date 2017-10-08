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
my $FILE = 't/010_f.t';

my $log = Log::Minimal.new(:timezone(0));

my regex timestamp { \d ** 4 '-' \d ** 2 '-' \d ** 2 'T' \d ** 2 ':' \d ** 2 ':' \d ** 2 '.' \d+ 'Z' };

subtest {
    {
        use Grammar::Tracer;
        my $out = capture_stderr {
            $log.critf('critical');
        };
        like $out, rx{^ <timestamp> ' [CRITICAL] critical at t/010_f.t line 30' \n $};
    }

    {
        my $out = capture_stderr {
            $log.critf('critical:%s', 'foo');
        };
        like $out, rx{^ <timestamp> ' [CRITICAL] critical:foo at t/010_f.t line 37' \n $};
    }
}, 'test for critf';

subtest {
    {
        my $out = capture_stderr {
            $log.warnf('warn');
        };
        like $out, rx{^ <timestamp> ' [WARN] warn at t/010_f.t line 46' \n $};
    }

    {
        my $out = capture_stderr {
            $log.warnf('warn:%s', 'foo');
        };
		like $out, rx{^ <timestamp> ' [WARN] warn:foo at t/010_f.t line 53' \n $};
    }
}, 'test for warnf';

subtest {
    {
        my $out = capture_stderr {
            $log.infof('info');
        };
		like $out, rx{^ <timestamp> ' [INFO] info at t/010_f.t line 62' \n $};
    }

    {
        my $out = capture_stderr {
            $log.infof('info:%s', 'foo');
        };
		like $out, rx{^ <timestamp> ' [INFO] info:foo at t/010_f.t line 69' \n $};
    }
}, 'test for infof';

subtest {
    temp %*ENV<LM_DEBUG> = 1;
    {
        my $out = capture_stderr {
            $log.debugf('debug');
        };
		like $out, rx{^ <timestamp> ' [DEBUG] debug at t/010_f.t line 79' \n $};
    }

    {
        my $out = capture_stderr {
            $log.debugf('debug:%s', 'foo');
        };
		like $out, rx{^ <timestamp> ' [DEBUG] debug:foo at t/010_f.t line 86' \n $};
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
