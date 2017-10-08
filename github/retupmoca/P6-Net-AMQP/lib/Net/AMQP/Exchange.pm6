unit class Net::AMQP::Exchange;

use Net::AMQP::Frame;
use Net::AMQP::Payload::Method;

has $.name;
has $.type;
has $.durable;
has $.passive;

has $!conn;
has $!login;
has $!frame-max;
has $!methods;
has $!channel;
has $!channel-lock;

submethod BUILD(:$!name, :$!type, :$!durable, :$!passive, :$!conn, :$!methods,
                :$!channel, :$!login, :$!channel-lock, :$!frame-max) { }

method Str {
    $.name;
}

method declare {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'exchange.declare-ok').tap({
        $tap.close;

        $v.keep(self);
    });

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
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $declare.Buf).Buf);
    };

    return $p;
}

method delete($if-unused = 0) {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'exchange.delete-ok').tap({
        $tap.close;

        $v.keep(1);
    });
    
    my $delete = Net::AMQP::Payload::Method.new('exchange.delete',
                                                0,
                                                $.name,
                                                $if-unused,
                                                0);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $delete.Buf).Buf);
    };
    return $p;
}

method publish(:$routing-key = "", :$mandatory, :$immediate, :$content-type = "", :$content-encoding = "",
               :$persistent, :$priority = 0, :$correlation-id = "", :$reply-to = "",
               :$expiration = "0", :$message-id = "", :$timestamp = 0, :$type = "",
               :$app-id = "", :$body is copy, *%headers) {

    $!channel-lock.protect: {
        #method
        my $publish = Net::AMQP::Payload::Method.new('basic.publish',
                                                     0,
                                                     $.name,
                                                     $routing-key,
                                                     $mandatory,
                                                     $immediate);
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $publish.Buf).Buf);

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
        $!conn.write(Net::AMQP::Frame.new(type => 2, channel => $!channel, payload => $header.Buf).Buf);

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

            $!conn.write(Net::AMQP::Frame.new(type => 3, channel => $!channel, payload => $chunk).Buf);
        }
    };
}

method return-supply {

}

method ack-supply {

}
