unit class Net::AMQP::Frame;

use Net::AMQP::Payload::Body;
use Net::AMQP::Payload::Header;
use Net::AMQP::Payload::Heartbeat;
use Net::AMQP::Payload::Method;

has $.type;
has $.channel;
has $.payload;

method size(Blob $header?){
    if self {
        return $!payload.bytes;
    } else {
        my ($type, $channel, $size) = $header.unpack('CnN');
        return $size;
    }
}

method type-class {
    if $!type == 1 {
        return Net::AMQP::Payload::Method;
    } elsif $!type == 2 {
        return Net::AMQP::Payload::Header;
    } elsif $!type == 3 {
        return Net::AMQP::Payload::Body;
    } elsif $!type == 4 {
        return Net::AMQP::Payload::Heartbeat;
    }
}

method Buf {
    return pack('CnN', ($!type, $!channel, self.size)) ~ $!payload ~ Buf.new(0xCE);
}

multi method new(Blob $data){
    my ($type, $channel, $size) = $data.unpack('CnN');
    my $payload = $data.subbuf(7, $size);
    if $data[7+$size] != 0xCE {
        fail "...";
    }
    self.bless(:$type, :$channel, :$payload);
}

multi method new(:$type, :$channel, :$payload) {
    self.bless(:$type, :$channel, :$payload);
}

submethod BUILD(:$!type, :$!channel, :$!payload) { }
