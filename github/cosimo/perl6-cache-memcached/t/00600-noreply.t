#!/usr/bin/env perl6
#

use v6.c;

use Test;
use Cache::Memcached;
use CheckSocket;

plan 16;

my $testaddr = "127.0.0.1:11211";
my $port = 11211;

if not check-socket($port, "127.0.0.1") {
    skip-rest "no memcached server";
    exit;

}

my $memd = Cache::Memcached.new(
    servers   => [ $testaddr ],
    namespace => "Cache::Memcached::t/$*PID/" ~ (now % 100) ~ "/",
);

isa-ok($memd, 'Cache::Memcached');


constant count = 30;


$memd.set("foobar", 42);
is $memd.get("foobar"), 42, "set a random key";
lives-ok { $memd.flush-all }, "flush-all";
is $memd.get("foobar"), Nil, "Key is unavailable";

$memd.add("key", "add");
is($memd.get("key"), "add", "added a value");

for ^count -> $i {
    $memd.set("key", $i);
}
is($memd.get("key"), count - 1, "value should be " ~ count - 1);

$memd.replace("key", count);
is($memd.get("key"), count, "value should now be " ~ count);

for ^count -> $i {
    $memd.incr("key", 2);
}
is($memd.get("key"), count + 2 * count, "value should now be " ~ count + 2 * count);

for ^count -> $i {
    $memd.decr("key", 1);
}
is(my $count = $memd.get("key"), count + 1 * count, "got the correct decremented value");

lives-ok { $memd.incr("key") }, "incr with a default value";
is $memd.get("key"), $count + 1, "and it was incremented";

lives-ok { $memd.decr("key") }, "decr with a default value";
is $memd.get("key"), $count, "and got the expected value back";

$memd.delete("key");
is($memd.get("key"), Nil, "key is deleted");

nok $memd.incr("key"), "incr returns false if the key doesn't exist";

subtest {
    my $key = ("a" .. "z").pick(8).join("");

    nok $memd.incr($key), "incr returns false if the key doesn't exist";
    ok $memd.incr($key, init => 10), "supply an initialiser";
    is $memd.get($key), 11, "got back the initialiser + 1";
    ok $memd.set($key, "VastAndBulbous"), "set to a non numeric value";
    nok $memd.incr($key), "incr returns false if the key is non numeric";
    nok $memd.incr($key, init => 0), "incr returns false if the key is non numeric even with an initialiser";
    $memd.flush-all;

}, "new incr feature";


done-testing();
