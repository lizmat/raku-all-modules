use v6;
use Test;
use IO::Capture::Simple;
use Log::Minimal;

subtest {
    {
        my $log = Log::Minimal.new(:autodump(True), :timezone(0));
        my $out = capture_stderr {
            $log.critf({foo => 'bar'});
        };
        like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' '\:foo\(\"bar\"\)' 'at' 't\/090_autodump\.t' 'line' '10\n$};
    }

    {
        my $log = Log::Minimal.new(:timezone(0));
        {
            temp $log.autodump = True;

            my $out = capture_stderr {
                $log.critf('%s', {foo => 'bar'});
            };
            like $out, rx{^<[0..9]> ** 4\-<[0..9]> ** 2\-<[0..9]> ** 2T<[0..9]> ** 2\:<[0..9]> ** 2\:<[0..9]> ** 2Z' '\[CRITICAL\]' '\:foo\(\"bar\"\)' 'at' 't\/090_autodump\.t' 'line' '21\n$};
        }
        is $log.autodump, False;
    }
}, 'test for critf';

done-testing;
