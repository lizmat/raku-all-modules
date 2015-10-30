#!/usr/bin/env perl6

use v6;
use Test;
use Cache::Memcached;

plan 2;

my $testaddr = "127.0.0.1";
my $port = 11211;

try {
   my $msock = IO::Socket::INET.new(host => $testaddr, port => $port);
   CATCH {
      default {
         skip-rest "No memcached instance running at $testaddr";
         exit 0;
      }
   }
}

my $memd = Cache::Memcached.new(
    servers   => [ "$testaddr:$port" ],
);

my $key = "Ïâ";

ok($memd.set($key, "val1"), "set key1 as val1");
is($memd.get($key), "val1", "get key1 is val1");

done-testing();
