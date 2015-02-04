use NativeCall;
class Net::ZMQ::Pollitem is repr('CStruct');

use Net::ZMQ::Constants;
use Net::ZMQ::Socket;

has Net::ZMQ::Socket $.socket;
has int              $.fd;
has int16            $.events;
has int16            $.revents;

multi method new(Net::ZMQ::Socket $socket, :$in? as Bool, :$out? as Bool, :$err? as Bool) {
    my int16 $eventmask = $in.Bool * ZMQ_POLLIN
                        +| $out.Bool * ZMQ_POLLOUT
                        +| $err.Bool * ZMQ_POLLERR;
    return self.bless(:$socket, :fd(0), :events($eventmask), :revents(0));
}

# TODO "native" fd pollitem constructor

method !flag_proxy(int16 $flag) {
    Proxy.new(
        FETCH    => anon sub ($) { $!events +& $flag },
        STORE    => anon sub ($, $val as Bool) {
                        if $val {
                            $!events +| $flag
                        } else {
                            $!events +& +^$flag
                        }
                    }
    )
}

method in  { self!flag_proxy(ZMQ_POLLIN)  }
method out { self!flag_proxy(ZMQ_POLLOUT) }
method err { self!flag_proxy(ZMQ_POLLERR) }

method rin  { $!revents +& ZMQ_POLLIN  }
method rout { $!revents +& ZMQ_POLLOUT }
method rerr { $!revents +& ZMQ_POLLERR }

# vim: ft=perl6
