use v6.c;
use Test;

use-ok 'Reaper::Control';
use Reaper::Control;

# Test init for udp
my $listener = reaper-listener(:host<127.0.0.1>, :port(9243));

done-testing;
