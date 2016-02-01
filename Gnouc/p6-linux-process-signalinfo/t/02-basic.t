use v6;

use Test;
use lib 'lib';

use Linux::Process::SignalInfo;

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

done-testing();
