unit class Net::AMQP::Frame;

use experimental :pack;

use Net::AMQP::Payload::Body;
use Net::AMQP::Payload::Header;
use Net::AMQP::Payload::Heartbeat;
use Net::AMQP::Payload::Method;

has Int $.type;
has Int $.channel;
has Blob $.payload;

method size(Blob $header? --> Int){
    if self {
        return $!payload.bytes;
    } else {
        my ($type, $channel, $size) = $header.unpack('CnN');
        return $size;
    }
}

method type-class( --> Mu:U ) {
    given $!type {
        when 1 {
            Net::AMQP::Payload::Method;
        }
        when 2 {
            Net::AMQP::Payload::Header;
        }
        when 3 {
            Net::AMQP::Payload::Body;
        }
        when 4 {
            Net::AMQP::Payload::Heartbeat;
        }
        default {
            fail "unknown frame type";
        }
    }
}

method Buf( --> Buf ) {
    return pack('CnN', ($!type, $!channel, self.size)) ~ $!payload ~ Buf.new(0xCE);
}

proto method new(|c) { * }

multi method new(Buf() $data){
    my ($type, $channel, $size) = $data.unpack('CnN');
    my $payload = $data.subbuf(7, $size);
    if $data[7+$size] != 0xCE {
        fail "...";
    }
    self.bless(:$type, :$channel, :$payload);
}

multi method new( Int :$type = 1, :$channel!, Buf(Net::AMQP::Payload::Method) :$payload!) {
    self.bless(:$type, :$channel, :$payload);
}

multi method new(Int :$type = 2, :$channel!, Buf(Net::AMQP::Payload::Header) :$payload!) {
    self.bless(:$type, :$channel, :$payload);
}

multi method new(Int :$type = 3, :$channel!, Buf(Net::AMQP::Payload::Body) :$payload!) {
    self.bless(:$type, :$channel, :$payload);
}

multi method new(Int :$type = 4, :$channel!, Buf(Net::AMQP::Payload::Heartbeat) :$payload!) {
    self.bless(:$type, :$channel, :$payload);
}

multi method new(Int :$type!, :$channel!, Buf() :$payload!) {
    self.bless(:$type, :$channel, :$payload);
}

multi method new(Int :$type!, :$channel!, Blob :$payload!) {
    self.bless(:$type, :$channel, :$payload);
}

submethod BUILD(:$!type, :$!channel, Blob :$!payload) { }
