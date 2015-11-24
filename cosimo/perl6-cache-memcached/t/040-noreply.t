#!/usr/bin/env perl6
#

use v6;

use Test;
use Cache::Memcached;
use CheckSocket;

plan 7;

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

$memd.flush-all;

$memd.add("key", "add");
is($memd.get("key"), "add");

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
is($memd.get("key"), count + 1 * count);

$memd.delete("key");
is($memd.get("key"), Nil);

done-testing();
