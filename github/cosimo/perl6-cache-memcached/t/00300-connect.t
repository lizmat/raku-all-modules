use v6;
use Test;
use Cache::Memcached;
use CheckSocket;

my $testaddr = "127.0.0.1:11211";
my $testport = 11211;

plan 3;

if not check-socket($testport, "127.0.0.1") {
    skip-rest "no memcached server"; 
    exit;

}

my $mc = Cache::Memcached.new(
    servers => [$testaddr],
);

ok($mc, "memcached object created");

ok(my $rv = $mc.set("mykey", "myvalue"), "set value");

$rv = $mc.get("mykey");
is($rv, "myvalue", "get() should get back the same value");

done-testing();
