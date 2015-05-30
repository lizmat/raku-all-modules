# All the various constants that are #defined in zmq.h
unit module Net::ZMQ::Constants;

# Message constants:
our constant ZMQ_MSG_MORE   is export(:DEFAULT, :message) = 1;
our constant ZMQ_MSG_SHARED is export(:DEFAULT, :message) = 128;
our constant ZMQ_MSG_MASK   is export(:DEFAULT, :message) = 129;

# Socket types:
our constant ZMQ_PAIR   is export(:DEFAULT, :socket-types) = 0;
our constant ZMQ_PUB    is export(:DEFAULT, :socket-types) = 1;
our constant ZMQ_SUB    is export(:DEFAULT, :socket-types) = 2;
our constant ZMQ_REQ    is export(:DEFAULT, :socket-types) = 3;
our constant ZMQ_REP    is export(:DEFAULT, :socket-types) = 4;
our constant ZMQ_DEALER is export(:DEFAULT, :socket-types) = 5;
our constant ZMQ_ROUTER is export(:DEFAULT, :socket-types) = 6;
our constant ZMQ_PULL   is export(:DEFAULT, :socket-types) = 7;
our constant ZMQ_PUSH   is export(:DEFAULT, :socket-types) = 8;
our constant ZMQ_XPUB   is export(:DEFAULT, :socket-types) = 9;
our constant ZMQ_XSUB   is export(:DEFAULT, :socket-types) = 10;

# Socket options:
our constant ZMQ_HWM               is export(:DEFAULT, :socket-options) = 1;
our constant ZMQ_SWAP              is export(:DEFAULT, :socket-options) = 3;
our constant ZMQ_AFFINITY          is export(:DEFAULT, :socket-options) = 4;
our constant ZMQ_IDENTITY          is export(:DEFAULT, :socket-options) = 5;
our constant ZMQ_SUBSCRIBE         is export(:DEFAULT, :socket-options) = 6;
our constant ZMQ_UNSUBSCRIBE       is export(:DEFAULT, :socket-options) = 7;
our constant ZMQ_RATE              is export(:DEFAULT, :socket-options) = 8;
our constant ZMQ_RECOVERY_IVL      is export(:DEFAULT, :socket-options) = 9;
our constant ZMQ_MCAST_LOOP        is export(:DEFAULT, :socket-options) = 10;
our constant ZMQ_SNDBUF            is export(:DEFAULT, :socket-options) = 11;
our constant ZMQ_RCVBUF            is export(:DEFAULT, :socket-options) = 12;
our constant ZMQ_RCVMORE           is export(:DEFAULT, :socket-options) = 13;
our constant ZMQ_FD                is export(:DEFAULT, :socket-options) = 14;
our constant ZMQ_EVENTS            is export(:DEFAULT, :socket-options) = 15;
our constant ZMQ_TYPE              is export(:DEFAULT, :socket-options) = 16;
our constant ZMQ_LINGER            is export(:DEFAULT, :socket-options) = 17;
our constant ZMQ_RECONNECT_IVL     is export(:DEFAULT, :socket-options) = 18;
our constant ZMQ_BACKLOG           is export(:DEFAULT, :socket-options) = 19;
our constant ZMQ_RECOVERY_IVL_MSEC is export(:DEFAULT, :socket-options) = 20;
our constant ZMQ_RECONNECT_IVL_MAX is export(:DEFAULT, :socket-options) = 21;

# Send/receive options:
our constant ZMQ_NOBLOCK is export(:DEFAULT, :send-options) = 1;
our constant ZMQ_SNDMORE is export(:DEFAULT, :send-options) = 2;

# Device types:
our constant ZMQ_STREAMER  is export(:DEFAULT, :devices) = 1;
our constant ZMQ_FORWARDER is export(:DEFAULT, :devices) = 2;
our constant ZMQ_QUEUE     is export(:DEFAULT, :devices) = 3;

# Poll types:
our constant ZMQ_POLLIN  is export(:DEFAULT, :poll) = 1;
our constant ZMQ_POLLOUT is export(:DEFAULT, :poll) = 2;
our constant ZMQ_POLLERR is export(:DEFAULT, :poll) = 4;

# ZMQ-specific error codes:
my constant ZMQ_HAUSNUMERO  = 156384712;
our constant EFSM            is export(:DEFAULT, :errors) = (ZMQ_HAUSNUMERO + 51);
our constant ENOCOMPATPROTO  is export(:DEFAULT, :errors) = (ZMQ_HAUSNUMERO + 52);
our constant ETERM           is export(:DEFAULT, :errors) = (ZMQ_HAUSNUMERO + 53);
our constant EMTHREAD        is export(:DEFAULT, :errors) = (ZMQ_HAUSNUMERO + 54);

# vim: ft=perl6
