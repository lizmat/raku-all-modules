unit class Net::AMQP::Queue;

use Net::AMQP::Payload::Method;
use Net::AMQP::Frame;

has $.name;
has $.passive;
has $.durable;
has $.exclusive;
has $.auto-delete;
has $.arguments;

has $!conn;
has $!login;
has $!methods;
has $!headers;
has $!bodies;
has $!channel;
has $!channel-lock;

submethod BUILD(:$!name, :$!passive, :$!durable, :$!exclusive, :$!auto-delete, :$!conn, :$!methods,
                :$!headers, :$!bodies, :$!channel, :$!channel-lock, :$!arguments) { }
                
method Str {
    $.name;
}

method declare {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'queue.declare-ok').tap( -> $ok {
        $tap.close;

        if not $!name {
            $!name = $ok.arguments[0];
        }

        $v.keep(self);
    });

    my $declare = Net::AMQP::Payload::Method.new('queue.declare',
                                                 0,
                                                 $.name,
                                                 $.passive,
                                                 $.durable,
                                                 $.exclusive,
                                                 $.auto-delete,
                                                 0,
                                                 $.arguments);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $declare.Buf).Buf);
    };

    return $p;
}

method bind($exchange, $routing-key = '', *%arguments) {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'queue.bind-ok').tap({
        $tap.close;

        $v.keep(1);
    });

    my $bind = Net::AMQP::Payload::Method.new('queue.bind',
                                               0,
                                               $.name,
                                               ~$exchange,
                                               $routing-key,
                                               0,
                                               $%arguments);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $bind.Buf).Buf);
    };

    return $p;
}

method unbind($exchange, $routing-key = '', *%arguments) {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'queue.unbind-ok').tap({
        $tap.close;

        $v.keep(1);
    });

    my $bind = Net::AMQP::Payload::Method.new('queue.unbind',
                                               0,
                                               $.name,
                                               ~$exchange,
                                               $routing-key,
                                               $%arguments);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $bind.Buf).Buf);
    };

    return $p;
}

method purge {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'queue.purge-ok').tap({
        $tap.close;

        $v.keep($_.arguments[0]);
    });

    my $purge = Net::AMQP::Payload::Method.new('queue.purge',
                                               0,
                                               $.name,
                                               0);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $purge.Buf).Buf);
    };

    return $p;
}

method delete(:$if-unused, :$if-empty) {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'queue.delete-ok').tap({
        $tap.close;

        $v.keep(1);
    });

    my $delete = Net::AMQP::Payload::Method.new('queue.delete',
                                                0,
                                                $.name,
                                                $if-unused,
                                                $if-empty,
                                                0);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $delete.Buf).Buf);
    };

    return $p;
}

method get {

}

method consume(:$consumer-tag = "", :$exclusive, :$no-local, :$ack, *%arguments) {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'basic.consume-ok').tap({
        $tap.close;

        $v.keep($_.arguments[0]);
    });

    my $delete = Net::AMQP::Payload::Method.new('basic.consume',
                                                0,
                                                $.name,
                                                $consumer-tag,
                                                $no-local,
                                                !$ack,
                                                $exclusive,
                                                0,
                                                $%arguments);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $!channel, payload => $delete.Buf).Buf);
    };

    return $p;
}

method cancel {

}

class Net::AMQP::Message {
    has $.consumer-tag;
    has $.delivery-tag;
    has $.redelivered;
    has $.exchange-name;
    has $.routing-key;
                                                                                                                    
    has %.headers;
    has $.body;
}

method message-supply() returns Supply {
    my $s = Supplier.new;

    my $delivery-lock = Lock.new;

    $!methods.grep(*.method-name eq 'basic.deliver').tap(-> $method {
        $delivery-lock.lock();

        my $header-payload;
        my $body = buf8.new();

        my $htap = $!headers.tap({
            $htap.close;
            $header-payload = $_;
            $delivery-lock.unlock();
        });

        my $btap = $!bodies.tap(-> $chunk {
            $delivery-lock.protect: {
                $body ~= $chunk;
                if $header-payload.body-size == $body.bytes {
                    # last chunk
                    $btap.close;

                    my $h = $header-payload.headers;
                    my %headers = %$h;
                    %headers<content-type> = $header-payload.content-type;
                    %headers<content-encoding> = $header-payload.content-encoding;
                    %headers<delivery-mode> = $header-payload.delivery-mode;
                    %headers<priority> = $header-payload.priority;
                    %headers<correlation-id> = $header-payload.correlation-id;
                    %headers<reply-to> = $header-payload.reply-to;
                    %headers<expiration> = $header-payload.expiration;
                    %headers<message-id> = $header-payload.message-id;
                    %headers<timestamp> = $header-payload.timestamp;
                    %headers<type> = $header-payload.type;
                    %headers<user-id> = $header-payload.user-id;
                    %headers<app-id> = $header-payload.app-id;

                    start {
                    $s.emit(Net::AMQP::Message.new(consumer-tag => $method.arguments[0],
                                                   delivery-tag => $method.arguments[1],
                                                   redelivered => $method.arguments[2],
                                                   exchange-name => $method.arguments[3],
                                                   routing-key => $method.arguments[4],
                                                   :%headers,
                                                   :$body));
                    }
                }
            };
        });

    });

    return $s.Supply;
}

method recover {

}
