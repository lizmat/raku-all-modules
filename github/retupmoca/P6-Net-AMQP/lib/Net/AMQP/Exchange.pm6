unit class Net::AMQP::Exchange;

use Net::AMQP::Payload::Header;
use Net::AMQP::Payload::Method;
use Net::AMQP::Payload::Body;

has Str $.name;
has $.type;
has $.durable;
has $.passive;

has $!login;
has $!frame-max;
has $!channel;

submethod BUILD(:$!name, :$!type, :$!durable, :$!passive,
                :$!channel, :$!login, :$!frame-max) { }

method Str( --> Str ) {
    $.name;
}

method declare( --> Promise )  {
    my $p = $!channel.ok-method-promise('exchange.declare-ok', keep => self);

    my $declare = Net::AMQP::Payload::Method.new('exchange.declare',
                                                 0,
                                                 $.name,
                                                 $.type,
                                                 $.passive,
                                                 $.durable,
                                                 0,
                                                 0,
                                                 0,
                                                 Nil);
    $!channel.write-frame($declare);
    $p;
}

method delete($if-unused = 0 --> Promise) {
    my $p = $!channel.ok-method-promise('exchange.delete-ok');

    my $delete = Net::AMQP::Payload::Method.new('exchange.delete',
                                                0,
                                                $.name,
                                                $if-unused,
                                                0);
    $!channel.write-frame($delete);
    $p;
}

method publish(:$routing-key = "", Bool :$mandatory, Bool :$immediate, :$content-type, :$content-encoding ,
               :$persistent, :$priority, :$correlation-id, :$reply-to ,
               :$expiration, :$message-id, :$timestamp, :$type,
               :$app-id, :$body is copy, *%headers) {


    $!channel.protect: {
        #method
        my $publish = Net::AMQP::Payload::Method.new('basic.publish',
                                                     0,
                                                     $.name,
                                                     $routing-key,
                                                     $mandatory,
                                                     $immediate);
        $!channel.write-frame($publish, :no-lock);

        # header
        my $delivery-mode = 1;
        $delivery-mode = 2 if $persistent;
        my $header = Net::AMQP::Payload::Header.new(class-id => 60,
                                                    body-size => $body.bytes,
                                                    :$content-type,
                                                    :$content-encoding,
                                                    headers => $%headers,
                                                    :$delivery-mode,
                                                    :$priority,
                                                    :$correlation-id,
                                                    :$reply-to,
                                                    :$expiration,
                                                    :$message-id,
                                                    :$timestamp,
                                                    :$type,
                                                    user-id => $!login,
                                                    :$app-id);
        $!channel.write-frame($header, :no-lock);

        # content
        my $max-frame-size = $!frame-max;
        my $buf-size = $max-frame-size - 8; # header + trailer
        while $body.bytes {
            my $chunk;
            if $buf-size < $body.bytes {
                $chunk = $body.subbuf(0, $buf-size);
                $body .= subbuf($buf-size);
            } else {
                $chunk = $body;
                $body = buf8.new;
            }

            my $body-part = Net::AMQP::Payload::Body.new(content => $chunk);
            $!channel.write-frame($body-part, :no-lock);
        }
    };
}

method return-supply(--> Supply) {
    $!channel.method-supply('basic.return');
}

method ack-supply(--> Supply) {
    $!channel.method-supply('basic.ack');
}
