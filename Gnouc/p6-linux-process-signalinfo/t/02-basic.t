use v6;

use Test;
use Linux::Process::SignalInfo;

plan :skip-all<These tests are only for Linux> unless $*KERNEL.name eq 'linux';
plan 5;
dies-ok(
    { Linux::Process::SignalInfo.new },
    'pid is required'
);
ok(
    my $signal_info = Linux::Process::SignalInfo.new(pid => 1),
    'New instance'
);
ok($signal_info.read, 'Reading process signal information');
ok($signal_info.error eq '', 'No error');
ok($signal_info.parse, 'Parsing signal information');
