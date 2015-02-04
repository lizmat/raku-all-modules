use Test;
use IO::Capture::Simple;

module Test::IO::Capture;

sub prints-stdout-ok (Callable $code, $expected as Str, $reason = '')
is export {
    my $out = capture_stdout $code;
    is $out, $expected, $reason;
}

sub prints-stderr-ok (Callable $code, $expected as Str, $reason = '')
is export {
    my $out = capture_stderr $code;
    is $out, $expected, $reason;
}
