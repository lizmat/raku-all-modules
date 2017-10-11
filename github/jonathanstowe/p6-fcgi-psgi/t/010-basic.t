use v6.c;
use Test;
use FastCGI::NativeCall;
use FastCGI::NativeCall::PSGI;

plan 3;


sub sock-path(--> Str) {
    $*PID ~ '-' ~ now.Int ~ '.sock';
}

subtest {

    my $path = sock-path();
    my $psgi = FastCGI::NativeCall::PSGI.new(fcgi => FastCGI::NativeCall.new(:$path, backlog => 5));

    ok $psgi, 'created object';

    ok $path.IO.e, "the socket was created okay";

    sub dispatch-psgi($env) { return 'works' }

    $psgi.app(&dispatch-psgi);

    is $psgi.app.({}), 'works', 'app successfully set';

    LEAVE {
        unlink($path);
    }
}, "old API";

subtest {

    my $path = sock-path();
    my $psgi = FastCGI::NativeCall::PSGI.new(:$path, backlog => 5);

    ok $psgi, 'created object';

    ok $path.IO.e, "the socket was created okay";

    sub dispatch-psgi($env) { return 'works' }

    $psgi.app(&dispatch-psgi);

    is $psgi.app.({}), 'works', 'app successfully set';

    LEAVE {
        unlink($path);
    }
}, "new API";
subtest {

    my $path = sock-path();

    my $sock = FastCGI::NativeCall::OpenSocket($path, 5);
    my $psgi = FastCGI::NativeCall::PSGI.new(:$sock);

    ok $psgi, 'created object';

    ok $path.IO.e, "the socket was created okay";

    sub dispatch-psgi($env) { return 'works' }

    $psgi.app(&dispatch-psgi);

    is $psgi.app.({}), 'works', 'app successfully set';

    LEAVE {
        unlink($path);
    }
}, "with socket";

# vim: expandtab shiftwidth=4 ft=perl6
