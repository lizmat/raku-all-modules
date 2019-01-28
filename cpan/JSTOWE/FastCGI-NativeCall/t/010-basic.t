use v6;

use Test;
use FastCGI::NativeCall;

plan 2;

sub sock-path(--> Str) {
    $*PID ~ '-' ~ now.Int ~ '.sock';
}

subtest {
    my $path = sock-path();
    my $socket = FastCGI::NativeCall::OpenSocket($path, 5);
    ok $path.IO ~~ :e, 'opened socket';

    my $fcgi = FastCGI::NativeCall.new(:$socket);
    ok $fcgi, 'created object';
    lives-ok { $fcgi.close }, "close";

    LEAVE {
        unlink($path);
    }
}, "original interface";

subtest {

    my $path = sock-path();

    my $fcgi = FastCGI::NativeCall.new(:$path, backlog => 10);
    ok $path.IO ~~ :e, 'opened socket';
    ok $fcgi, 'created object';
    lives-ok { $fcgi.close }, "close";

    LEAVE {
        unlink($path);
    }
}, "new interface";

# vim: ft=perl6
