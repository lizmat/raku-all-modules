use v6;

BEGIN { @*INC.push('t', 'lib') };
use Redis;
use Test;

my $r = Redis.new("127.0.0.1:63790", decode_response => True);
$r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');
$r.flushall;


if $r.info<redis_version> gt "2.6" {
    plan 21;
} else {
    plan 14;
}

# del
is_deeply $r.del("key", "key2", "does_not_exists"), 0;

# dump & restore
if $r.info<redis_version> gt "2.6" {
    $r.set("key", "value");
    my $serialized = $r.dump("key");
    $r.del("newkey");
    is_deeply $r.restore("newkey", 100, $serialized), True;
    is_deeply $r.get("newkey"), "value";
}

# exists
$r.set("key", "value");
is_deeply $r.exists("key"), True;
is_deeply $r.exists("does_not_exists"), False;

# expire & persist & pexpire & expireat & pexpireat & pttl & ttl
if $r.info<redis_version> gt "2.6" {
    is_deeply $r.expire("key", 100), True;
    ok $r.ttl("key") <= 100;
    ok $r.persist("key");
    is_deeply $r.ttl("key"), -1;
    is_deeply $r.pexpire("key", 100000), True;
    is_deeply $r.expireat("key", 100), True;
    is_deeply $r.ttl("key"), -1;
    is_deeply $r.pexpireat("key", 1), False;
    is_deeply $r.pttl("key"), -1;
} else {
    is_deeply $r.expire("key", 100), True;
    ok $r.ttl("key") <= 100;
    ok $r.persist("key");
    is_deeply $r.ttl("key"), -1;
}

# keys
$r.set("pattern1", 1);
$r.set("pattern2", 2);
is_deeply $r.keys("pattern*"), ["pattern1", "pattern2"];

# migrate TODO

# move TODO

# object
$r.set("key", "value");
is_deeply $r.object("refcount", "key"), 1;

# randomkey
is_deeply $r.randomkey().WHAT.gist, "Str()";

# rename
is_deeply $r.rename("key", "newkey"), True;

# renamenx
dies_ok { $r.renamenx("does_not_exists", "newkey"); }

# sort TODO
#say $r.sort("key", :desc);

# type
$r.set("key", "value");
is_deeply $r.type("key"), "string";
is_deeply $r.type("does_not_exists"), "none";

# vim: ft=perl6
