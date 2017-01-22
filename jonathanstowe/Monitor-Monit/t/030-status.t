#!perl6

use v6.c;

use Test;
use Monitor::Monit;

my $xml = $*PROGRAM.parent.child('data/cannibal.xml').slurp;

my $obj;

lives-ok { 
    $obj = Monitor::Monit::Status.from-xml($xml);
}, "from-xml";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
