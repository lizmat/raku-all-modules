use v6;
use Test;
use Cache::Memcached;

my $mc = Cache::Memcached.new(
    servers => [ "127.0.0.1:11211" ],
);

ok($mc, "memcached object created");

#my $rv = $mc.set("mykey", "myvalue");
#say "Set rv = '$rv'";
#is($rv, "myvalue", "set() should return the set value");

diag("Calling get() now");

my $rv = $mc.get("mykey");
say "Get rv = '$rv'";
is($rv, "myvalue", "get() should get back the same value");

done_testing;

