use IO::Socket::SSL;

my $sock = IO::Socket::SSL.new(:host<filip.sergot.pl>, :port(443));
$sock.send("GET / HTTP/1.1\r\nHost: filip.sergot.pl\r\n\r\n");
say 'Response: ', $sock.recv();
