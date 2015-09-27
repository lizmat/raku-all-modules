#!perl6
use v6;

use lib 'lib';
use Raw::Socket::INET;

my $sock = Raw::Socket::INET.new(
    host => '127.0.0.1',
    port => 80,
);
my $msg = "GET / HTTP/1.0\r\n\r\n".encode('utf-8');
$sock.send($msg, $msg.bytes, 0);
my $buf = Buf.new;
$buf[100-1] = 0; # extend buffer
my $readlen;
while (($readlen = $sock.recv($buf, 100, 0)) > 0) {
    say($buf.subbuf(0, $readlen).decode('utf-8'));
}

