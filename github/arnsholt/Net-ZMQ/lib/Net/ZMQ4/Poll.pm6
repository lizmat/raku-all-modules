use Net::ZMQ4::Pollitem;

use NativeCall;

unit module Net::ZMQ4::Poll;

# ZMQ_EXPORT int zmq_poll (zmq_pollitem_t *items, int nitems, long timeout);
my sub zmq_poll(Net::ZMQ4::Pollitem, int32, int64 --> int32) is native('zmq',v5) { * }

# This is a temporary function. Ideally, we'd like to allow the user to poll
# several sockets at the same time (obviously). But the zmq_poll function
# takes an array of pollitems as zmq_pollitem_t*, but in NativeCall we can
# only express an array as zmq_pollitem_t**. So we currently only expose
# polling of a single socket.
#
# We could expose polling of several sockets by creating a multi-pollitem with
# several pollitems repeated in a single CStruct, but that's a hack. to get it
# working properly, we need NativeCall to support arrays of value structs
# rather than reference structs.
our sub poll_one(Net::ZMQ4::Socket $socket, $timeout, Bool :$in, Bool :$out, Bool :$err) is export {
    my Net::ZMQ4::Pollitem $pollitem .= new: :$socket, :$in, :$out, :$err;
    my $ret = zmq_poll($pollitem, 1, $timeout);
    if $ret < 0 { die "zmq_poll returned error: $ret" }
    return $pollitem.revents;
}
