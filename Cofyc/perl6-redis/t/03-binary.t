use v6;

BEGIN { @*INC.push('t', 'lib') };
use Redis;
use Test;

my $r = Redis.new("127.0.0.1:63790");
$r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');
$r.flushall;

plan 2;

# arbitary binary string 
my Buf $binary = Buf.new(1,2,3,129);
is-deeply $r.set("key", $binary), True;
is-deeply $r.get("key"), $binary;
