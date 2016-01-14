unit class Net::Minecraft::Query:auth<github:flussence>:ver<0.1.0>;
use Net::Minecraft::Packet;
use JSON::Fast;

constant protocol-version    = 47;
constant packet-id-handshake = 0x00;
constant packet-id-request   = 0x00;
constant packet-id-ping      = 0x01;
constant request-status      = 0x01;

method ping(Str() :$host, uint16 :$port where uint16.Range) {
    my \P = Net::Minecraft::Packet;

    $_ = IO::Socket::INET.new(:$host, :$port);

    # I have no idea what I'm doing
    .write(P.encode(
        packet-id-handshake,
        protocol-version,
        $host,
        pack('n', $port),
        request-status
    ));
    .write(P.encode(packet-id-request));

    my $data = P.recv-payload($_) or die 'Empty response from server';

    # chop off the packet ID...
    $data[0] == packet-id-request or die 'Bad response from server';
    $data   .= subbuf(1);

    # and grab the JSON
    my $info = from-json P::unserialize(Str, $data);

    # actually ping
    my $ping-start = now;
    .write(P.encode(packet-id-ping, ^8));
    sink .recv(:bin);
    my $ping-end = now;
    $info<ping> = (1000 * ($ping-end - $ping-start)).Int;

    return $info;
}
