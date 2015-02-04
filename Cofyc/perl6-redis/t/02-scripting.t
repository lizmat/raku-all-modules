use v6;

BEGIN { @*INC.push('t', 'lib') };
use Redis;
use Test;

my $r = Redis.new("127.0.0.1:63790", decode_response => True);
$r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');
$r.flushall;

if $r.info<redis_version> gt "2.6" {
    plan 5;

    $r.set("key", 1);
    is_deeply $r.eval("return redis.call('get', 'key')", 0), "1";

    is_deeply $r.script_flush(), True;

    dies_ok { $r.script_kill() };

    my $sha = $r.script_load("return redis.call('get', 'key')");
    is_deeply $r.script_exists($sha, "unknown"), [1, 0];

    is_deeply $r.evalsha($sha, 0), "1";
} else {
    done;
}
