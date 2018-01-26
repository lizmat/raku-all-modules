use v6;

use Test;

use Supply::Timeout;

my $sup = Supply::Timeout.new;
isa-ok($sup, 'Supply::Timeout');

isa-ok($sup.supply, 'Supply', 'Method supply returns Supply object');
ok($sup.timeout ~~ Numeric, 'Method timeout returns Numeric');

done-testing;

# vim: ft=perl6
