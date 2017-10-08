use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my regex timestamp { \d ** 4 '-' \d ** 2 '-' \d ** 2 'T' \d ** 2 ':' \d ** 2 ':' \d ** 2 '.' \d+ '+09:00' };

my $timezone = DateTime.new('2015-12-24T12:23:00+0900').timezone;
my $log = Log::Minimal.new(:$timezone);

subtest {
    my $out = capture_stderr {
        $log.critf('critical');
    };
    like $out, rx{^ <timestamp> ' [CRITICAL] critical at t/100_timezone.t line 13' \n $};
}, 'test for critf';

done-testing;
