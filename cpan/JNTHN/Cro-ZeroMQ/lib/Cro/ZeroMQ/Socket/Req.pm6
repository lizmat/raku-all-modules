use Cro::Transform;
use Cro::ZeroMQ::Internal;
use Cro::ZeroMQ::Message;
use Net::ZMQ4::Constants;

class Cro::ZeroMQ::Socket::Req does Cro::ZeroMQ::Connector {
    class Transform does Cro::Transform {
        has $.socket;
        has $.ctx;

        method consumes() { Cro::ZeroMQ::Message }
        method produces() { Cro::ZeroMQ::Message }

        method transformer(Supply $incoming --> Supply) {
            supply {
                whenever $incoming {
                    $!socket.sendmore(|@(.parts));
                    my @res = $!socket.receivemore;
                    emit Cro::ZeroMQ::Message.new(|@res);
                    LAST {
                        self!cleanup;
                    }
                    QUIT {
                        self!cleanup;
                    }
                }
                CLOSE {
                    self!cleanup;
                }
            }
        }
        method !cleanup() {
            $!socket.close;
            $!ctx.term;
        }
    }

    method !type() { ZMQ_REQ }
    method !promise($ctx, $socket) {
        Promise.start({ Transform.new(:$ctx, :$socket)} );
    }
}
