#!perl6

use v6;

use Test;
use Monitor::Monit;

my $xml = $*PROGRAM.parent.add('data/cannibal.xml').slurp;

my $status;

lives-ok { 
    $status = Monitor::Monit::Status.from-xml($xml);
}, "from-xml";

isa-ok $status.platform, Monitor::Monit::Status::Platform, 'platform is the right thing';
isa-ok $status.server, Monitor::Monit::Status::Server, 'server is the right thing';
isa-ok $status.server.version, Version, "got server version";

for $status.service -> $service {
    subtest {
        isa-ok $service, Monitor::Monit::Status::Service, "and it's still the right sort of object";
        ok $service.status-name.defined, "looks like the service is { $service.status-name }";
    }, $service.name;
}



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
