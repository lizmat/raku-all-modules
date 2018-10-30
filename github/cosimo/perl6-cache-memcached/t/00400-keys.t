use v6;
use Test;
use Cache::Memcached;
use CheckSocket;

#use IO::Socket::INET;

plan 19;

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


ok($memd.stats('misc').keys, "got some stats");

my $memcached_version =
        Version.new(
            $memd.stats('misc')<hosts>{$testaddr}<misc><version>
        );
    diag("Server version: $memcached_version") if $memcached_version;

ok($memd.set("key1", "val1"), "set key1 as val1");

is($memd.get("key1"), "val1", "get key1 is val1");
ok(! $memd.add("key1", "val-replace"), "add key1 properly failed");
ok($memd.add("key2", "val2"), "add key2 as val2");
is($memd.get("key2"), "val2", "get key2 is val2");

ok($memd.replace("key2", "val-replace"), "replace key2 as val-replace");
is($memd.get("key2"), "val-replace", "get key2 is val-replace");
ok(! $memd.replace("key-noexist", "bogus"), "replace key-noexist properly failed");

ok($memd.delete("key1"), "delete key1");
ok(! $memd.get("key1"), "get key1 properly failed");

SKIP: {
  skip "Could not parse server version; version.pm 0.77 required", 7
      unless $memcached_version;
  skip "Only using prepend/append on memcached >= 1.2.4, you have $memcached_version", 7
      unless $memcached_version && ($memcached_version cmp v1.2.4) ~~ (Same|More);

  ok(! $memd.append("key-noexist", "bogus"), "append key-noexist properly failed");
  ok(! $memd.prepend("key-noexist", "bogus"), "prepend key-noexist properly failed");
  ok($memd.set("key3", "base"), "set key3 to base");
  ok($memd.append("key3", "-end"), "appended -end to key3");
  is($memd.get("key3"), "base-end", "key3 is base-end");
  ok($memd.prepend("key3", "start-"), "prepended start- to key3");
  is($memd.get("key3"), "start-base-end", "key3 is base-end");
}

