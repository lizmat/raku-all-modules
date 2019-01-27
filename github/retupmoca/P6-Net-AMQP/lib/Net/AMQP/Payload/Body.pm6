use Net::AMQP::Payload;

unit class Net::AMQP::Payload::Body does Net::AMQP::Payload;

has Blob $.content;

method Buf( --> Blob) {
    $!content
}
