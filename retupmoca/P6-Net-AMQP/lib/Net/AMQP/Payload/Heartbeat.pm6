unit class Net::AMQP::Payload::Heartbeat;

method Buf {
    return buf8.new();
}

method new($data?) { self.bless(); }
