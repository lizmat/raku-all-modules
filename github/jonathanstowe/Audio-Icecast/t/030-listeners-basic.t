#!perl6

use v6.c;

use Test;
use Audio::Icecast;

my $data-dir = $*PROGRAM.parent.child('data');

my $xml = $data-dir.child('admin_listeners.xml').slurp;

my $obj;

lives-ok { $obj = Audio::Icecast::Listeners.from-xml($xml); }, "create Listeners from xml";

is $obj.listeners.elems, 1, "we have one listener";

for $obj.listeners -> $listener {
    isa-ok $listener, 'Audio::Icecast::Listener', "and the listener is the right thing";
    isa-ok $listener.connected, Duration, "and we got back a Duration for connected";
    is $listener.ip, '195.157.190.48', 'ip is right';
    is $listener.user-agent, 'MPlayer 1.2.1-5.1.1', 'user-agent is correct';
    is $listener.id, '20439', 'got an ID';
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
