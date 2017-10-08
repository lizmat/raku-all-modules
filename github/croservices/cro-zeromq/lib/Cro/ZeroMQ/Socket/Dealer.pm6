use Cro::Connector;
use Cro::Transform;
use Cro::ZeroMQ::Internal;
use Cro::ZeroMQ::Message;
use Net::ZMQ4::Constants;
use Net::ZMQ4::Poll;

class Cro::ZeroMQ::Socket::Dealer does Cro::ZeroMQ::Connector {
    class Transform does Cro::Transform {
        has $.socket;
        has $.ctx;

        method consumes() { Cro::ZeroMQ::Message }
        method produces() { Cro::ZeroMQ::Message }

        method transformer(Supply $incoming --> Supply) {
            my $closer = False;
            supply {
                whenever $incoming {
                    $!socket.sendmore(|@(.parts));
                    LAST {
                        self!cleanup;
                    }
                    QUIT {
                        self!cleanup;
                    }
                }
                my $messages = Channel.new;
                start {
                    loop {
                        last if $closer;
                        my $event = poll_one($!socket, 100, :in);
                        if $event > 0 {
                            $messages.send: Cro::ZeroMQ::Message.new(parts => $!socket.receivemore);
                        }
                    }
                }
                whenever $messages { .emit }
                CLOSE {
                    $closer = True;
                    self!cleanup;
                }
            }
        }
        method !cleanup() {
            $!socket.close;
            $!ctx.term;
        }
    }

    method !type() { ZMQ_DEALER }
    method !promise($ctx, $socket) {
        Promise.start({ Transform.new(:$ctx, :$socket)} );
    }
}
