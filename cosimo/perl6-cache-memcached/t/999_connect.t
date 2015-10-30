use v6;
use Test;
use Cache::Memcached;

my $testaddr = "127.0.0.1:11211";
my $testport = 11211;

plan 3;

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

my $mc = Cache::Memcached.new(
    servers => [$testaddr],
);

ok($mc, "memcached object created");

ok(my $rv = $mc.set("mykey", "myvalue"), "set value");

$rv = $mc.get("mykey");
is($rv, "myvalue", "get() should get back the same value");

done-testing();
