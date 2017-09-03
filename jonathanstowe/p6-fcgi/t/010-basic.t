use v6.c;
use Test;
use FastCGI::NativeCall;

plan 2;

subtest {
    my $sock = FastCGI::NativeCall::OpenSocket('01-test.sock', 5);
    ok '01-test.sock'.IO ~~ :e, 'opened socket';

    my $fcgi = FastCGI::NativeCall.new($sock);
    ok $fcgi, 'created objected';
    lives-ok { $fcgi.close }, "close";

    unlink('01-test.sock');
}, "original interface";
subtest {

    my $fcgi = FastCGI::NativeCall.new(path => "02-test.sock", backlog => 10);
    ok '02-test.sock'.IO ~~ :e, 'opened socket';
    ok $fcgi, 'created objected';
    lives-ok { $fcgi.close }, "close";

    unlink('01-test.sock');
}, "new interface";

# vim: ft=perl6
