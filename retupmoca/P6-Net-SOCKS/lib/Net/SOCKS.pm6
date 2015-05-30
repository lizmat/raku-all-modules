unit class Net::SOCKS;

method connect(:$host!, :$port!, :$proxy-server, :$proxy-port = 1080, :$socket = IO::Socket::INET) {
    my $request = Buf.new(0x05, # version 5
                          0x01, # one auth method
                          0x00); # no authentication
    my $sock = $socket;
    unless $sock.defined {
        fail "No proxy server!" unless $proxy-server;
        $sock = $sock.new(:host($proxy-server), :port($proxy-port));
    }

    $sock.write($request);
    my $r = $sock.read(2);
    unless $r[0] == 0x05 && $r[1] == 0x00 {
        $sock.close;
        fail "Server doesn't support SOCKS5 with no auth";
    }

    my $request-type;
    my $request-data;
    if $host ~~ /^\d+\.\d+\.\d+\.\d+$/ {
        # ipv4
        $request-type = 0x01;
        $request-data = Buf.new($host.split('.')».Int);
    } elsif $host ~~ /^\[.+\]$/ {
        # ipv6
        $sock.close;
        fail "IPv6 literal NYI";
        $request-type = 0x01;
        $request-data = Buf.new(0..15);
    } else {
        # domain
        $request-type = 0x03;
        $request-data = Buf.new($host.chars);
        $request-data ~= $host.encode;
    }

    $request = Buf.new(0x05, # version 5
                       0x01, # establish a TCP connection
                       0x00, #reserved
                       $request-type # host type
                   ) ~ $request-data ~ pack('n', $port);
    $sock.write($request);

    $r = $sock.read(4);
    unless $r[0] == 0x05 && $r[1] == 0x00 && $r[2] == 0x00 {
        $sock.close;
        fail "SOCKS request failed";
    }
    if $r[3] == 0x01 {
        $sock.read(4);
    } elsif $r[3] == 0x03 {
        my $len = $sock.read(1);
        $len = $len[0];
        $sock.read($len);
    } elsif $r[3] == 0x04 {
        $sock.read(16);
    } else {
        $sock.close;
        fail "Can't understand SOCKS response";
    }

    $sock.read(2);

    return $sock;
}
