use v6;
use Test;
use Cache::Memcached;

plan 8;

my $testaddr = "127.0.0.1:11211";
my $port = 11211;

try {
   my $msock = IO::Socket::INET.new(host => $testaddr, port => $port);
   CATCH {
      default {
         skip-rest "No memcached instance running at $testaddr";
         exit;
      }
   }
}

my $memd;

my $ns = "Cache::Memcached::t/$*PID/" ~ (now % 100) ~ "/";

lives-ok {
$memd = Cache::Memcached.new(
    servers   => [ $testaddr ],
    namespace => $ns
) }, "can create a Cache::Memcached";

isa-ok($memd, 'Cache::Memcached', "and it's the right sort of object");

is($memd.namespace, $ns, "namepace okay");

my $sock;

lives-ok { $sock = $memd.sock_to_host($testaddr) }, "sock_to_host";

isa-ok $sock, IO::Socket::INET, "returns a socket";

my $lines;

lives-ok { $lines = $memd._write_and_read($sock, "version\r\n") }, "_write_and_read";

like($lines, /VERSION/, "got version back");

lives-ok { $lines = $memd._write_and_read($sock, "stats\r\n") }, "_write_and_read";


done-testing();


# vim: ft=perl6
