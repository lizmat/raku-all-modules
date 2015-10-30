#!/usr/bin/env perl6

use v6;

use Test;
use Cache::Memcached;


my $port = 11311;
my $testaddr = "127.0.0.1:$port";

my @res = (
    ["OK\r\n", 1],
    ["ERROR\r\n", 0],
    ["\r\nERROR\r\n", 0],
    ["FOO\r\nERROR\r\n", 0],
    ["FOO\r\nOK\r\nERROR\r\n", 0],
    ["\r\n\r\nOK\r\n", 0],
    ["END\r\n", 0],
);

plan +@res;

try {
   my $sock = IO::Socket::INET.new(host => $testaddr, port => $port);
   CATCH {
      default {
         skip-rest "cannot bind to $testaddr";
         exit 0;
      }
   }
   close $sock;
}

my $p = start {
    
    my $sock = IO::Socket::INET.new( host => $testaddr, listen => True);
    my $csock = $sock.accept();
    while (defined (my $buf = <$csock>)) {
        my $res = @res.shift;
        $csock.send($res[0]);
    }
    close $csock;
    close $sock;
}

# give the forked server a chance to startup
sleep 1;

my $memd = Cache::Memcached.new( servers   => [ $testaddr ] );

for @res <-> $v {
    ($v[0] ~~ s:g/\W//);
    is $memd.flush_all, $v[1], $v[0];
}

done-testing();
