#!perl6

use v6.c;

use Test;
use CheckSocket;
use Monitor::Monit;

my $host        = %*ENV<MONIT_TEST_HOST> // 'localhost';
my $port        = (%*ENV<MONIT_TEST_PORT> // 2812).Int;
my $username    = %*ENV<MONIT_TEST_USER> // 'admin';
my $password    = %*ENV<MONIT_TEST_PASS> // 'monit';

if check-socket($port, $host) {
    pass "got monit daemon";
    my $mon;
    lives-ok { $mon = Monitor::Monit.new(:$host, :$port, :$username, :$password) }, "new with credentials";
    isa-ok $mon, Monitor::Monit, "and got the right sort of thing";

    my $status;

    lives-ok { $status = $mon.status }, "get status";
    isa-ok $status, Monitor::Monit::Status, "got the right thing back";

    isa-ok $status.platform, Monitor::Monit::Status::Platform, 'platform is the right thing';

    for $status.service -> $service {
        does-ok $service, Monitor::Monit::ServiceWrapper, "the service  { $service.name } has the role";
        isa-ok $service, Monitor::Monit::Status::Service, "and it's still the right sort of object";
        if %*ENV<MONIT_TEST_CONTROL> {
            pass "going to test control of " ~ $service.name ;
            lives-ok {
                ok $service.restart, "looks good";
            }, "restart ok";
        }
        ok $service.status-name.defined, "looks like the service is { $service.status-name }";
    }

    is $mon.service.elems, $status.service.elems, "delegate service is the same";
}
else {
    plan 1;
    skip-rest "no monit daemon";
}



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
