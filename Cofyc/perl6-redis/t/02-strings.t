use v6;

use lib <t lib>;
use Redis;
use Test;

my $r = Redis.new("127.0.0.1:63790", decode_response => True);
$r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');
$r.flushall;

if $r.info<redis_version> gt "2.6" {
    plan 35;
} else {
    plan 26;
}

# append
$r.del("key");
is_deeply $r.append("key", "Hello"), 5;
is_deeply $r.append("key", " World"), 11;

# bitcount
if $r.info<redis_version> gt "2.6" {
    $r.set("key", "foobar");
    is_deeply $r.bitcount("key"), 26;
    is_deeply $r.bitcount("key", 0, 0), 4;
    is_deeply $r.bitcount("key", 1, 1), 6;
}

# bitop
if $r.info<redis_version> gt "2.6" {
    $r.set("key1", "foobar");
    $r.set("key2", "abcdefg");
    is_deeply $r.bitop("AND", "dest", "key1", "key2"), 7;
}

# incr & decr & decrby & incrby
$r.set("key2", 100);
is_deeply $r.incr("key2"), 101;
is_deeply $r.decr("key2"), 100;
is_deeply $r.decrby("key2", 2), 98;
is_deeply $r.incrby("key2", 3), 101;

# getbit
is_deeply $r.getbit("key2", 2), 1;

# getrange
$r.set("mykey", "This is a string");
is_deeply $r.getrange("mykey", 0, 3), "This";

# getset
$r.del("mycounter");
is_deeply $r.incr("mycounter"), 1;
is_deeply $r.getset("mycounter", 0), "1";
is_deeply $r.get("mycounter"), "0";

# incrbyfloat
if $r.info<redis_version> gt "2.6" {
    $r.set("mykey", 10.50);
    is_deeply $r.incrbyfloat("mykey", 0.1), 10.6;
    $r.set("mykey", 5.0e3);
    is_deeply $r.incrbyfloat("mykey", 2.0e2), 5200;
}

# set & get
is_deeply $r.set("key", "value"), True;
is_deeply $r.get("key"), "value";
is_deeply $r.get("does_not_exists"), Nil;
is_deeply $r.set("key2", 100), True;
is_deeply $r.get("key2"), "100";

# mget
$r.del("key", "key2");
is_deeply $r.mset("key", "value", key2 => "value2"), True;
is_deeply $r.mget("key", "key2"), ["value", "value2"];
is_deeply $r.msetnx("key", "value", key2 => "value2"), 0;

# psetex
if $r.info<redis_version> gt "2.6" {
    is_deeply $r.psetex("key", 100, "value"), True;
    is_deeply $r.get("key"), "value";
    sleep(0.1);
    is_deeply $r.get("key"), Nil;
}

# setbit
$r.del("mykey");
is_deeply $r.setbit("mykey", 7, 1), 0;
is_deeply $r.setbit("mykey", 7, 0), 1;

# setex
is_deeply $r.setex("key", 1, "value"), True;

# setnx
is_deeply $r.setnx("key", "value"), False;

# setrange
is_deeply $r.setrange("key", 2, "123"), 5;
is_deeply $r.get("key"), "va123";

# strlen
is_deeply $r.strlen("key"), 5;

# vim: ft=perl6
