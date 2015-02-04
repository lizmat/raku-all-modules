use v6;

BEGIN { @*INC.push('t', 'lib') };
use Redis;
use Test;

my $r = Redis.new("127.0.0.1:63790", decode_response => True);
$r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');
$r.flushall;

if $r.info<redis_version> gt "2.6" {
    plan 13;
} else {
    plan 12;
}

# hset & hget & hmset & hmget & hsetnx
$r.hdel("hash", "field1");
is_deeply $r.hset("hash", "field1", 1), True;
is_deeply $r.hsetnx("hash", "field1", 1), False;
is_deeply $r.hget("hash", "field1"), "1";
is_deeply $r.hmset("hash", "key", "value", key2 => "value2"), True;
is_deeply $r.hmget("hash", "key", "key2"), ["value", "value2"];

# hdel & hexists
is_deeply $r.hdel("hash", "field1", "key"), 2;
is_deeply $r.hexists("hash", "field1"), False;

# hgetall
$r.hset("hash", "count", 1);
is_deeply $r.hgetall("hash"), {key2 => "value2", count => "1"};

# hincrby & hincrbyfloat
is_deeply $r.hincrby("hash", "count", 10), 11;
if $r.info<redis_version> gt "2.6" {
    is_deeply $r.hincrbyfloat("hash", "count", 10.1), 21.1;
}

# hkeys & hlen & hvals
is_deeply $r.hkeys("hash"), ["key2", "count"];
is_deeply $r.hlen("hash"), 2;
$r.hset("hash", "count", 10);
is_deeply $r.hvals("hash"), ["value2", "10"];

# vim: ft=perl6
