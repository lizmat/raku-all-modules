use Net::ZMQ::Pollitem;

use NativeCall;

module Net::ZMQ::Poll;

# ZMQ_EXPORT int zmq_poll (zmq_pollitem_t *items, int nitems, long timeout);
my sub zmq_poll(CArray[Net::ZMQ::Pollitem], int, Int --> int) is native('libzmq') { * }

multi sub poll_these(Net::ZMQ::Socket @socks, $timeout as Int = 0, :$in? as Bool, :$out? as Bool, :$err? as Bool) {
    my @pollitems = do Net::ZMQ::Pollitem.new($_, :$in, :$out, :$err) for @socks;
    my $pollarray = CArray[Net::ZMQ::Pollitem].new(|@pollitems);
    zmq_poll($pollarray, $pollarray.elems, $timeout);
    return $pollarray;
}

multi sub poll_these(CArray[Net::ZMQ::Pollitem] $pollarray, $timeout as Int, :$in?, :$out?, :$err?) {
    if ($in | $out | $err).defined {
        for @$pollarray -> $item {
            if $in.defined  { $item.in = $in }
            if $out.defined { $item.out = $out }
            if $err.defined { $item.err = $err }
        }
    }
    zmq_poll($pollarray, $pollarray.elems, $timeout);
    return $pollarray;
}
