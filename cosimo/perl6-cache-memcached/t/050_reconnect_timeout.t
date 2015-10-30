#!/usr/bin/env perl6

use v6;
use Test;
use Cache::Memcached;

my $testaddr = "127.0.0.1:11211";
my $testport = 11211;

plan 2;

try {
   my $sock = IO::Socket::INET.new(host => $testaddr, port => $testport);
   CATCH {
      default {
         skip-rest "No memcached instance running on $testaddr";
         exit 0;
      }
   }
   $sock.close;
}

my $memd = Cache::Memcached.new(
    servers   => [ $testaddr ],
    namespace => "Cache::Memcached::t/$*PID/" ~ (now % 100) ~ "/",
);

todo("may not be testing this right", 2);

my $time1 = now;
$memd.set("key", "bar");
my $time2 = now;
# 100ms is faster than the default connect timeout.
ok($time2 - $time1 > .1, "Expected pause while connecting");

# 100ms should be slow enough that dead socket reconnects happen faster than it.
$memd.set("key", "foo");
my $time3 = now;
ok($time3 - $time2 < .1, "Should return fast on retry");

done-testing();
