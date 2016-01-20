unit class Net::AMQP::Channel;

use Net::AMQP::Exchange;
use Net::AMQP::Queue;

use Net::AMQP::Payload::Method;
use Net::AMQP::Frame;

has $.id;
has $!conn;
has $!login;
has $!frame-max;

# supplies
has $!methods;
has $!headers;
has $!bodies;
#

has $!flow-stopped;
has $!write-lock;
has $!channel-lock;

# This should be part of the public interface
# as dependent promises may want to react to it
# This will be Kept when the channel.close-ok method
# is received

has Promise $.closed;
has         $!closed-vow;

submethod BUILD(:$!id, :$!conn, :$!methods, :$!headers, :$!bodies, :$!login, :$!frame-max) {
    $!write-lock = Lock.new;
    $!channel-lock = Lock.new;
    my $wl = $!write-lock;
    my $c = $!conn;
    $!conn = class { method write($stuff) { $wl.protect: { $c.write($stuff); }; }; method real { $c }; };
}

method open {
    my $p = Promise.new;
    my $v = $p.vow;

    $!closed     = Promise.new;
    $!closed-vow = $!closed.vow;

    my $tap = $!methods.grep(*.method-name eq 'channel.open-ok').tap({
        $tap.close;

        $v.keep(self);
    });

    $!methods.grep(*.method-name eq 'channel.flow').tap({
        my $flow-ok = Net::AMQP::Payload::Method.new("channel.flow-ok",
                                                     $_.arguments[0]);
        if $_.arguments[0] {
            if $!flow-stopped {
                $!conn.real.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $flow-ok.Buf).Buf);
                $!write-lock.unlock();
                $!flow-stopped = 0;
            }
        } else {
            unless $!flow-stopped {
                $!flow-stopped = 1;
                $!write-lock.lock();
                $!conn.real.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $flow-ok.Buf).Buf);
            }
        }

    });

    my $closed-tap = $!methods.grep(*.method-name eq 'channel.close').tap({
        $closed-tap.close;
        $!closed-vow.keep(True);
    });

    my $open = Net::AMQP::Payload::Method.new("channel.open", "");
    $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $open.Buf).Buf);

    return $p;
}

method close($reply-code, $reply-text, $class-id = 0, $method-id = 0) {
    my $p = Promise.new;
    my $v = $p.vow;

    if $!closed.status ~~ Kept {
        $v.keep(1);
    }
    else {
        my $tap = $!methods.grep(*.method-name eq 'channel.close-ok').tap({
            $tap.close;
            $!closed-vow.keep(True);
            $v.keep(1);
        });

        my $close = Net::AMQP::Payload::Method.new("channel.close",
                                                $reply-code,
                                                $reply-text,
                                                $class-id,
                                                $method-id);
        $!channel-lock.protect: {
            $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $close.Buf).Buf);
        };
    }
    return $p;
}

method declare-exchange($name, $type, :$durable = 0, :$passive = 0) {
    return Net::AMQP::Exchange.new(:$name,
                                   :$type,
                                   :$durable,
                                   :$passive,
                                   conn => $!conn,
                                   channel-lock => $!channel-lock,
                                   login => $!login,
                                   frame-max => $!frame-max,
                                   methods => $!methods,
                                   channel => $.id).declare;
}

method exchange($name = "") {
    my $p = Promise.new;
    $p.keep(Net::AMQP::Exchange.new(:$name,
                                   conn => $!conn,
                                   channel-lock => $!channel-lock,
                                   login => $!login,
                                   frame-max => $!frame-max,
                                   methods => $!methods,
                                   channel => $.id));
    return $p;
}

method declare-queue($name, :$passive, :$durable, :$exclusive, :$auto-delete, *%arguments) {
    return Net::AMQP::Queue.new(:$name,
                                :$passive,
                                :$durable,
                                :$exclusive,
                                :$auto-delete,
                                arguments => $%arguments,
                                conn => $!conn,
                                channel-lock => $!channel-lock,
                                methods => $!methods,
                                headers => $!headers,
                                bodies => $!bodies,
                                channel => $.id).declare;
}

method queue($name) {
    my $p = Promise.new;
    $p.keep(Net::AMQP::Queue.new(:$name,
                                conn => $!conn,
                                channel-lock => $!channel-lock,
                                methods => $!methods,
                                headers => $!headers,
                                bodies => $!bodies,
                                channel => $.id));
    return $p;
}

method qos($prefetch-size, $prefetch-count, $global = 0){
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'basic.qos-ok').tap({
        $tap.close;

        $v.keep(1);
    });

    my $qos = Net::AMQP::Payload::Method.new("basic.qos",
                                             $prefetch-size,
                                             $prefetch-count,
                                             $global);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $qos.Buf).Buf);
    };
    return $p;
}

method flow($status) {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'channel.flow-ok').tap({
        $tap.close;

        $v.keep(1);
    });

    my $flow = Net::AMQP::Payload::Method.new("channel.flow",
                                             $status);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $flow.Buf).Buf);
    }
    return $p;
}

method recover($requeue) {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq 'basic.recover-ok').tap({
        $tap.close;

        $v.keep(1);
    });

    my $recover = Net::AMQP::Payload::Method.new("basic.recover",
                                              $requeue);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $recover.Buf).Buf);
    }
    return $p;
}

method ack(Int() $delivery-tag, Bool :$multiple) returns Promise {
    self!basic-method('basic.ack', 'basic.ack-ok', $delivery-tag, $multiple);
}

# Helper to make implementing/refactoring basic methods on channel easier
# it is the responsibility of the caller to ensure the right args are passed.
method !basic-method(Str:D $method, Str:D $ok-method, *@args ) returns Promise {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = $!methods.grep(*.method-name eq $ok-method).tap({
        $tap.close;

        $v.keep(1);
    });

    my $method-payload = Net::AMQP::Payload::Method.new($method, @args);
    $!channel-lock.protect: {
        $!conn.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $method-payload.Buf).Buf);
    }
    return $p;
}
