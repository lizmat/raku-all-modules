#!/usr/bin/env perl6

use v6;
use Test;
use Cache::Memcached;
use CheckSocket;

plan 2;

my $testaddr = "127.0.0.1";
my $port = 11211;

if not check-socket($port, "127.0.0.1") {
    skip-rest "no memcached server"; 
    exit;

}

my $memd = Cache::Memcached.new(
    servers   => [ "$testaddr:$port" ],
);

my $key = "Ïâ";

ok($memd.set($key, "val1"), "set key1 as val1");
is($memd.get($key), "val1", "get key1 is val1");

done-testing();
