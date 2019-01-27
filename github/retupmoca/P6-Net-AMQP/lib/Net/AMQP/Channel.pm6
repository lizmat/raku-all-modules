unit class Net::AMQP::Channel;

use Net::AMQP::Exchange;
use Net::AMQP::Queue;

need Net::AMQP::Payload;
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

method open( --> Promise ) {

    $!closed     = Promise.new;
    $!closed-vow = $!closed.vow;

    my $p = self.ok-method-promise('channel.open-ok', keep => self);

    self.method-supply('channel.flow').tap({
        my $flow-ok = Net::AMQP::Payload::Method.new("channel.flow-ok",
                                                     $_.arguments[0]);
        if $_.arguments[0] {
            if $!flow-stopped {
                $!conn.real.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $flow-ok).Buf);
                $!write-lock.unlock();
                $!flow-stopped = 0;
            }
        } else {
            unless $!flow-stopped {
                $!flow-stopped = 1;
                $!write-lock.lock();
                $!conn.real.write(Net::AMQP::Frame.new(type => 1, channel => $.id, payload => $flow-ok).Buf);
            }
        }

    });

    my $closed-tap = self.method-supply('channel.close').tap({
        $closed-tap.close;
        $!closed-vow.keep(True);
    });

    my $open = Net::AMQP::Payload::Method.new("channel.open", "");
    self.write-frame($open, :no-lock);

    $p;
}

method close($reply-code = '', $reply-text = '', $class-id = 0, $method-id = 0 --> Promise ) {
    my $p = Promise.new;
    my $v = $p.vow;

    if $!closed.status ~~ Kept {
        $v.keep(True);
    }
    else {
        self.ok-method-promise('channel.close-ok').then({
            $!closed-vow.keep(True);
            $v.keep(True);
        });

        my $close = Net::AMQP::Payload::Method.new("channel.close",
                                                $reply-code,
                                                $reply-text,
                                                $class-id,
                                                $method-id);
        $.write-frame($close);
    }
    $p;
}

method declare-exchange($name, $type, :$durable = 0, :$passive = 0 --> Promise) {
    Net::AMQP::Exchange.new(:$name,
                            :$type,
                            :$durable,
                            :$passive,
                            login => $!login,
                            frame-max => $!frame-max,
                            channel => self).declare;
}

method exchange($name = "" --> Promise ) {
    my $p = Promise.new;
    $p.keep(Net::AMQP::Exchange.new(:$name,
                                   login => $!login,
                                   frame-max => $!frame-max,
                                   channel => self));
    $p;
}

proto method declare-queue(|c) { * }

multi method declare-queue(*%args --> Promise ) {
    self.declare-queue('', |%args);
}

multi method declare-queue($name, :$passive, :$durable, :$exclusive, :$auto-delete, *%arguments --> Promise ) {
    Net::AMQP::Queue.new(:$name,
                                :$passive,
                                :$durable,
                                :$exclusive,
                                :$auto-delete,
                                arguments => $%arguments,
                                methods => $!methods,
                                headers => $!headers,
                                bodies => $!bodies,
                                channel => self).declare;
}

method queue( Str $name --> Promise ) {
    my $p = Promise.new;
    $p.keep(Net::AMQP::Queue.new(:$name,
                                methods => $!methods,
                                headers => $!headers,
                                bodies => $!bodies,
                                channel => self));
    $p;
}

proto method qos(|c) { * }

multi method qos( Int $, Int $prefetch-count, Bool :$global = False --> Promise ) {
    DEPRECATED("qos() with one argument", what => "qos() with ignored prefetch size argument");
    self.qos($prefetch-count, :$global);
}

multi method qos( Int $prefetch-count, Bool :$global = False --> Promise ){
    self!basic-method("basic.qos",'basic.qos-ok',0, $prefetch-count,$global);
}

method flow($status --> Promise) {
    self!basic-method("channel.flow",'channel.flow-ok',$status);
}

method recover($requeue --> Promise) {
    self!basic-method("basic.recover", 'basic.recover-ok', $requeue);
}

method ack(Int() $delivery-tag, Bool :$multiple --> Promise ) {
    self!basic-method('basic.ack', 'basic.ack-ok', $delivery-tag, $multiple);
}

method reject(Int() $delivery-tag, Bool :$requeue --> Promise ) {
    self!basic-method('basic.reject', 'basic.reject-ok', $delivery-tag, $requeue);
}

# Helper to make implementing/refactoring basic methods on channel easier
# it is the responsibility of the caller to ensure the right args are passed.
method !basic-method(Str:D $method, Str:D $ok-method, *@args --> Promise ) {
    my $p = self.ok-method-promise($ok-method);

    my $method-payload = Net::AMQP::Payload::Method.new($method, @args);

    $.write-frame($method-payload);
    $p;
}

multi method method-supply(Str $method --> Supply) {
    $!methods.grep(*.method-name eq $method);
}

# For ok methods where only want to keep a Promise.

method ok-method-promise(Str:D $ok-method, Any:D :$keep = True, Bool :$with-method --> Promise ) {
    my $p = Promise.new;
    my $v = $p.vow;

    my $tap = self.method-supply($ok-method).tap(-> $method {
        $tap.close;
        $v.keep($with-method ?? $method !! $keep );
    });
    $p;
}

# This should be public so that we a) don't need to repear the frame creation pattern and
# b) only need to pass the channel to exchange and queue

method write-frame(Net::AMQP::Payload $payload, Bool :$no-lock) {

    my $frame-buf = Net::AMQP::Frame.new(channel => $.id, payload => $payload).Buf;
    if $no-lock {
        $!conn.write: $frame-buf;
    }
    else {
        self.protect: {
            $!conn.write: $frame-buf;
        }
    }
}

method protect( Callable $block ) {
    $!channel-lock.protect: $block;
}

# vim: ft=perl6
