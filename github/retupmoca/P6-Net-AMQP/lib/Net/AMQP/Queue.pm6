unit class Net::AMQP::Queue;

use Net::AMQP::Payload::Method;

has $.name;
has $.passive;
has $.durable;
has $.exclusive;
has $.auto-delete;
has $.arguments;

has Supply $!methods;
has Supply $!headers;
has Supply $!bodies;
has $!channel;

has Str $.consumer-tag;

has Supplier $!message-supplier;

submethod BUILD(:$!name, :$!passive, :$!durable, :$!exclusive, :$!auto-delete, :$!methods,
                :$!headers, :$!bodies, :$!channel, :$!arguments) { }

method Str( --> Str ) {
    $.name;
}

method declare( --> Promise ) {
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

    $!channel.write-frame($declare);

    $p;
}

method bind($exchange, $routing-key = '', *%arguments --> Promise) {

    my $p = $!channel.ok-method-promise('queue.bind-ok');

    my $bind = Net::AMQP::Payload::Method.new('queue.bind',
                                               0,
                                               $.name,
                                               ~$exchange,
                                               $routing-key,
                                               0,
                                               $%arguments);
    $!channel.write-frame($bind);

    $p;
}

method unbind($exchange, $routing-key = '', *%arguments --> Promise) {

    my $p = $!channel.ok-method-promise('queue.unbind-ok');

    my $unbind = Net::AMQP::Payload::Method.new('queue.unbind',
                                               0,
                                               $.name,
                                               ~$exchange,
                                               $routing-key,
                                               $%arguments);
    $!channel.write-frame($unbind);
    $p;
}

method purge( --> Promise ) {
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
    $!channel.write-frame($purge);
    $p;
}

method delete(:$if-unused, :$if-empty --> Promise ) {

    my $p = $!channel.ok-method-promise('queue.delete-ok');

    my $delete = Net::AMQP::Payload::Method.new('queue.delete',
                                                0,
                                                $.name,
                                                $if-unused,
                                                $if-empty,
                                                0);
    $!channel.write-frame($delete);
    $p;
}

method get {

}

method consume(:$consumer-tag = "", :$exclusive, :$no-local, :$ack, *%arguments --> Promise ) {
    my $p = Promise.new;
    my $v = $p.vow;

    $!consumer-tag = $consumer-tag;

    my $tap = $!channel.method-supply('basic.consume-ok').tap({
        $tap.close;

        if not $!consumer-tag {
            $!consumer-tag = $_.arguments[0];
        }

        $v.keep($_.arguments[0]);
    });

    my $consume = Net::AMQP::Payload::Method.new('basic.consume',
                                                0,
                                                $.name,
                                                $consumer-tag,
                                                $no-local,
                                                !$ack,
                                                $exclusive,
                                                0,
                                                $%arguments);
    $!channel.write-frame($consume);
    $p;
}

# Deliberately ignoring the no-wait as allowing this would
# prevent us from finishing the message-supplier;
method cancel( --> Promise ) {

    my $p = $!channel.ok-method-promise('basic.cancel-ok');
    $p.then({
        if $!message-supplier.defined {
            $!message-supplier.done;
        }
    });

    my $cancel = Net::AMQP::Payload::Method.new('basic.cancel',$!consumer-tag, 0);
    $!channel.write-frame($cancel);

    $p;
}

class Message {
    has $.consumer-tag;
    has $.delivery-tag;
    has $.redelivered;
    has $.exchange-name;
    has $.routing-key;

    has %.headers;
    has $.body;
}

method !accept-message(Net::AMQP::Payload::Method $method where { $_.method-name eq 'basic.deliver' } --> Bool) {
    my @checks;
    if $!consumer-tag {
        if $method.arguments[0] ne $!consumer-tag {
            @checks.push: False;
        }
    }
    return so all(@checks);
}

method message-supply( --> Supply ) {

    $!message-supplier //= do {
        my $s = Supplier.new;

        my $delivery-lock = Lock.new;

        $!methods.grep(*.method-name eq 'basic.deliver').tap(-> $method {
            if self!accept-message($method) {
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
                            $s.emit(Message.new(consumer-tag => $method.arguments[0],
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
            }
        });
        $s;
    }
    $!message-supplier.Supply;
}

method recover {

}
