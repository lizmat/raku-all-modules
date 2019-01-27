use Net::AMQP::Payload;
unit class Net::AMQP::Payload::Heartbeat does Net::AMQP::Payload;

method Buf {
    return buf8.new();
}

method new($data?) { self.bless(); }
