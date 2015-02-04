use v6;
use Test;
use IO::Socket::SSL;

plan 1;

my $ssl = IO::Socket::SSL.new(:host<github.com>, :port(443));
isa_ok $ssl, IO::Socket::SSL, 'new 1/1';
$ssl.close;
