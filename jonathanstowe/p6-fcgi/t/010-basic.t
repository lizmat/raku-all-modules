use v6;
use Test;
use FastCGI::NativeCall;

plan 2;

my $sock = FastCGI::NativeCall::OpenSocket('01-test.sock', 5);
ok '01-test.sock'.IO ~~ :e, 'opened socket';

my $fcgi = FastCGI::NativeCall.new($sock);
ok $fcgi, 'created objected';

unlink('01-test.sock');

# vim: ft=perl6
