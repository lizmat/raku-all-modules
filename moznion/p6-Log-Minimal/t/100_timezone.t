use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

my $timezone = DateTime.new('2015-12-24T12:23:00+0900').timezone;
my $log = Log::Minimal.new(:$timezone);

subtest {
    my $out = capture_stderr {
        $log.critf('critical');
    };
    like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2\+09\:00' '\[CRITICAL\]' 'critical' 'at' 't\/100_timezone\.t' 'line' '11\n$};
}, 'test for critf';

done-testing;
