use v6;

use Test;
use Linux::Process::SignalInfo;

plan :skip-all<These tests are only for Linux> unless $*KERNEL.name eq 'linux';
plan 4;

ok(
    my $signal_info = Linux::Process::SignalInfo.new(pid => 65537),
    'New instance with non existed PID'
);
nok($signal_info.read, 'Reading non existed process');
ok($signal_info.error ne '', 'Error' ~ $signal_info.error);
nok($signal_info.parse, 'Empty data');
