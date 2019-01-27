use Cro::ZeroMQ::Component;
use Cro::ZeroMQ::Message;
use Cro;
use Net::ZMQ4::Constants;
use Net::ZMQ4::Poll;

role Cro::ZeroMQ::Replyable does Cro::Replyable {
    my class ReplyHandler does Cro::Sink {
        has $!socket;
        has $!ctx;

        submethod BUILD(:$!socket!, :$!ctx!) {}

        method consumes() { Cro::ZeroMQ::Message }
        method sinker(Supply:D $messages --> Supply:D) {
            supply {
                whenever $messages -> Cro::ZeroMQ::Message $_ {
                    $!socket.sendmore(|@(.parts));
                }
                CLOSE {
                    $!socket.close;
                    $!ctx.term;
                }
            }
        }
    }

    method replier(--> Cro::Replier) {
        self!initial;
        ReplyHandler.new(|self!data);
    }
}

role Cro::ZeroMQ::Component::Impure does Cro::ZeroMQ::Component {
    has $!socket;
    has $!ctx;
    has $!replier-init;

    method !socket() { $!socket }
    method !ctx()    { $!ctx }

    method !type() { ... }
    method !initial() {
        return if $!replier-init;
        $!replier-init = True;
        $!ctx = Net::ZMQ4::Context.new();
        $!socket = Net::ZMQ4::Socket.new($!ctx, self!type);
        $!socket.setopt(ZMQ_SNDHWM, self.high-water-mark) if self.high-water-mark;
        $!socket.connect(self.connect) if self.connect;
        $!socket.bind(self.bind) if self.bind;
    }

    method !cleanup() {
        $!socket.close;
        $!ctx.term;
        $!replier-init = False;
    }
}

role Cro::ZeroMQ::Component::Pure does Cro::ZeroMQ::Component {
    method !type() { ... }
    method !initial() {
        my $ctx = Net::ZMQ4::Context.new();
        my $socket = Net::ZMQ4::Socket.new($ctx, self!type);
        $socket.setopt(ZMQ_SNDHWM, self.high-water-mark) if self.high-water-mark;
        $socket.connect(self.connect) if self.connect;
        $socket.bind(self.bind) if self.bind;
        ($ctx, $socket);
    }
    method !cleanup($ctx, $socket) {
        $socket.close;
        $ctx.term;
    }
}

role Cro::ZeroMQ::Sink does Cro::Sink does Cro::ZeroMQ::Component::Pure {
    method consumes() { Cro::ZeroMQ::Message }
    method sinker(Supply:D $incoming) {
        supply {
            my ($ctx, $socket) = self!initial;
            whenever $incoming -> Cro::ZeroMQ::Message $_ {
                $socket.sendmore(|@(.parts));
            }
            CLOSE {
                self!cleanup($ctx, $socket)
            }
        }
    }
}

role Cro::ZeroMQ::Source::Impure does Cro::Source does Cro::ZeroMQ::Component::Impure {
    has $!tapped;

    method produces() { Cro::ZeroMQ::Message }
    method !data() { {socket => self!socket, ctx => self!ctx} }

    method incoming() { self!source-supply; }
    method !source-supply() {
        supply {
            die 'Already tapped' if $!tapped;
            self!initial;
            $!tapped = True;
            my $closer = False;
            my $messages = Supplier.new;
            start {
                loop {
                    last if $closer;
                    my $event = poll_one(self!socket, 100, :in);
                    if $event > 0 {
                        $messages.emit: Cro::ZeroMQ::Message.new(parts => self!socket.receivemore);
                    }
                }
            }
            whenever $messages { emit $_ }
            CLOSE {
                $!tapped = False;
                $closer = True;
                self!cleanup;
            }
        }
    }
}

role Cro::ZeroMQ::Source::Pure does Cro::Source does Cro::ZeroMQ::Component::Pure {
    method produces() { Cro::ZeroMQ::Message }
    method incoming() { self!source-supply }

    method !source-supply(:$ctx, :$socket) {
        supply {
            my ($ictx, $isocket) = $socket ?? ($ctx, $socket) !! self!initial;
            my $closer = False;
            my $messages = Supplier.new;
            start {
                loop {
                    last if $closer;
                    my $event = poll_one($isocket, 100, :in);
                    if $event > 0 {
                        $messages.emit: Cro::ZeroMQ::Message.new(parts => $isocket.receivemore);
                    }
                }
            }
            whenever $messages { emit $_ }
            CLOSE {
                $closer = True;
                self!cleanup($ictx, $isocket);
            }
        }
    }
}

role Cro::ZeroMQ::Connector does Cro::Connector does Cro::ZeroMQ::Component {
    method consumes() { Cro::ZeroMQ::Message }
    method produces() { Cro::ZeroMQ::Message }

    method connect(:$connect, :$bind, :$high-water-mark --> Promise) {
        my $ctx = Net::ZMQ4::Context.new();
        my $socket = Net::ZMQ4::Socket.new($ctx, self!type);
        $socket.setopt(ZMQ_SNDHWM, $high-water-mark) if $high-water-mark;
        $socket.connect($connect) if $connect;
        $socket.bind($bind) if $bind;
        self!promise($ctx, $socket);
    }
}
