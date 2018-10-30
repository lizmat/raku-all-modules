use v6;

use lib <t lib>;
use Redis;
use Test;

my $r = Redis.new("127.0.0.1:63790", decode_response => True);
$r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');

plan 4;

#dies-ok { $r.auth("WRONG PASSWORD"); }
is-deeply $r.echo("Hello World!"), "Hello World!";
is-deeply $r.ping, True;
is-deeply $r.select(2), True;
is-deeply $r.quit, True;

# vim: ft=perl6
