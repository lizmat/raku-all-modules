# All the various constants that are #defined in zmq.h
unit module Net::ZMQ4::Constants;

# Context options
our constant ZMQ_IO_THREADS          is export(:DEFAULT, :context) = 1;
our constant ZMQ_MAX_SOCKETS         is export(:DEFAULT, :context) = 2;
our constant ZMQ_SOCKET_LIMIT        is export(:DEFAULT, :context) = 3;
our constant ZMQ_THREAD_PRIORITY     is export(:DEFAULT, :context) = 3;
our constant ZMQ_THREAD_SCHED_POLICY is export(:DEFAULT, :context) = 4;
our constant ZMQ_MAX_MSGSZ           is export(:DEFAULT, :context) = 5;

# Socket types
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
our constant ZMQ_STREAM is export(:DEFAULT, :socket-types) = 11;

# Socket options:
our constant ZMQ_AFFINITY                 is export(:DEFAULT, :socket-options) = 4;
our constant ZMQ_IDENTITY                 is export(:DEFAULT, :socket-options) = 5;
our constant ZMQ_SUBSCRIBE                is export(:DEFAULT, :socket-options) = 6;
our constant ZMQ_UNSUBSCRIBE              is export(:DEFAULT, :socket-options) = 7;
our constant ZMQ_RATE                     is export(:DEFAULT, :socket-options) = 8;
our constant ZMQ_RECOVERY_IVL             is export(:DEFAULT, :socket-options) = 9;
our constant ZMQ_SNDBUF                   is export(:DEFAULT, :socket-options) = 11;
our constant ZMQ_RCVBUF                   is export(:DEFAULT, :socket-options) = 12;
our constant ZMQ_RCVMORE                  is export(:DEFAULT, :socket-options) = 13;
our constant ZMQ_FD                       is export(:DEFAULT, :socket-options) = 14;
our constant ZMQ_EVENTS                   is export(:DEFAULT, :socket-options) = 15;
our constant ZMQ_TYPE                     is export(:DEFAULT, :socket-options) = 16;
our constant ZMQ_LINGER                   is export(:DEFAULT, :socket-options) = 17;
our constant ZMQ_RECONNECT_IVL            is export(:DEFAULT, :socket-options) = 18;
our constant ZMQ_BACKLOG                  is export(:DEFAULT, :socket-options) = 19;
our constant ZMQ_RECONNECT_IVL_MAX        is export(:DEFAULT, :socket-options) = 21;
our constant ZMQ_MAXMSGSIZE               is export(:DEFAULT, :socket-options) = 22;
our constant ZMQ_SNDHWM                   is export(:DEFAULT, :socket-options) = 23;
our constant ZMQ_RCVHWM                   is export(:DEFAULT, :socket-options) = 24;
our constant ZMQ_MULTICAST_HOPS           is export(:DEFAULT, :socket-options) = 25;
our constant ZMQ_RCVTIMEO                 is export(:DEFAULT, :socket-options) = 27;
our constant ZMQ_SNDTIMEO                 is export(:DEFAULT, :socket-options) = 28;
our constant ZMQ_LAST_ENDPOINT            is export(:DEFAULT, :socket-options) = 32;
our constant ZMQ_ROUTER_MANDATORY         is export(:DEFAULT, :socket-options) = 33;
our constant ZMQ_TCP_KEEPALIVE            is export(:DEFAULT, :socket-options) = 34;
our constant ZMQ_TCP_KEEPALIVE_CNT        is export(:DEFAULT, :socket-options) = 35;
our constant ZMQ_TCP_KEEPALIVE_IDLE       is export(:DEFAULT, :socket-options) = 36;
our constant ZMQ_TCP_KEEPALIVE_INTVL      is export(:DEFAULT, :socket-options) = 37;
our constant ZMQ_IMMEDIATE                is export(:DEFAULT, :socket-options) = 39;
our constant ZMQ_XPUB_VERBOSE             is export(:DEFAULT, :socket-options) = 40;
our constant ZMQ_ROUTER_RAW               is export(:DEFAULT, :socket-options) = 41;
our constant ZMQ_IPV6                     is export(:DEFAULT, :socket-options) = 42;
our constant ZMQ_MECHANISM                is export(:DEFAULT, :socket-options) = 43;
our constant ZMQ_PLAIN_SERVER             is export(:DEFAULT, :socket-options) = 44;
our constant ZMQ_PLAIN_USERNAME           is export(:DEFAULT, :socket-options) = 45;
our constant ZMQ_PLAIN_PASSWORD           is export(:DEFAULT, :socket-options) = 46;
our constant ZMQ_CURVE_SERVER             is export(:DEFAULT, :socket-options) = 47;
our constant ZMQ_CURVE_PUBLICKEY          is export(:DEFAULT, :socket-options) = 48;
our constant ZMQ_CURVE_SECRETKEY          is export(:DEFAULT, :socket-options) = 49;
our constant ZMQ_CURVE_SERVERKEY          is export(:DEFAULT, :socket-options) = 50;
our constant ZMQ_PROBE_ROUTER             is export(:DEFAULT, :socket-options) = 51;
our constant ZMQ_REQ_CORRELATE            is export(:DEFAULT, :socket-options) = 52;
our constant ZMQ_REQ_RELAXED              is export(:DEFAULT, :socket-options) = 53;
our constant ZMQ_CONFLATE                 is export(:DEFAULT, :socket-options) = 54;
our constant ZMQ_ZAP_DOMAIN               is export(:DEFAULT, :socket-options) = 55;
our constant ZMQ_ROUTER_HANDOVER          is export(:DEFAULT, :socket-options) = 56;
our constant ZMQ_TOS                      is export(:DEFAULT, :socket-options) = 57;
our constant ZMQ_CONNECT_RID              is export(:DEFAULT, :socket-options) = 61;
our constant ZMQ_GSSAPI_SERVER            is export(:DEFAULT, :socket-options) = 62;
our constant ZMQ_GSSAPI_PRINCIPAL         is export(:DEFAULT, :socket-options) = 63;
our constant ZMQ_GSSAPI_SERVICE_PRINCIPAL is export(:DEFAULT, :socket-options) = 64;
our constant ZMQ_GSSAPI_PLAINTEXT         is export(:DEFAULT, :socket-options) = 65;
our constant ZMQ_HANDSHAKE_IVL            is export(:DEFAULT, :socket-options) = 66;
our constant ZMQ_SOCKS_PROXY              is export(:DEFAULT, :socket-options) = 68;
our constant ZMQ_XPUB_NODROP              is export(:DEFAULT, :socket-options) = 69;
our constant ZMQ_BLOCKY                   is export(:DEFAULT, :socket-options) = 70;
our constant ZMQ_XPUB_MANUAL              is export(:DEFAULT, :socket-options) = 71;
our constant ZMQ_XPUB_WELCOME_MSG         is export(:DEFAULT, :socket-options) = 72;
our constant ZMQ_STREAM_NOTIFY            is export(:DEFAULT, :socket-options) = 73;
our constant ZMQ_INVERT_MATCHING          is export(:DEFAULT, :socket-options) = 74;
our constant ZMQ_HEARTBEAT_IVL            is export(:DEFAULT, :socket-options) = 75;
our constant ZMQ_HEARTBEAT_TTL            is export(:DEFAULT, :socket-options) = 76;
our constant ZMQ_HEARTBEAT_TIMEOUT        is export(:DEFAULT, :socket-options) = 77;
our constant ZMQ_XPUB_VERBOSER            is export(:DEFAULT, :socket-options) = 78;
our constant ZMQ_CONNECT_TIMEOUT          is export(:DEFAULT, :socket-options) = 79;
our constant ZMQ_TCP_MAXRT                is export(:DEFAULT, :socket-options) = 80;
our constant ZMQ_THREAD_SAFE              is export(:DEFAULT, :socket-options) = 81;
our constant ZMQ_MULTICAST_MAXTPDU        is export(:DEFAULT, :socket-options) = 84;
our constant ZMQ_VMCI_BUFFER_SIZE         is export(:DEFAULT, :socket-options) = 85;
our constant ZMQ_VMCI_BUFFER_MIN_SIZE     is export(:DEFAULT, :socket-options) = 86;
our constant ZMQ_VMCI_BUFFER_MAX_SIZE     is export(:DEFAULT, :socket-options) = 87;
our constant ZMQ_VMCI_CONNECT_TIMEOUT     is export(:DEFAULT, :socket-options) = 88;
our constant ZMQ_USE_FD                   is export(:DEFAULT, :socket-options) = 89;

# Message options
our constant ZMQ_MORE   is export(:DEFAULT, :message) = 1;
our constant ZMQ_SHARED is export(:DEFAULT, :message) = 128;

# Send/receive options:
our constant ZMQ_DONTWAIT is export(:DEFAULT, :send-options) = 1;
our constant ZMQ_SNDMORE  is export(:DEFAULT, :send-options) = 2;

# Security mechanisms
our constant ZMQ_NULL   is export(:DEFAULT, :secure-options) = 0;
our constant ZMQ_PLAIN  is export(:DEFAULT, :secure-options) = 1;
our constant ZMQ_CURVE  is export(:DEFAULT, :secure-options) = 2;
our constant ZMQ_GSSAPI is export(:DEFAULT, :secure-options) = 3;

# Socket transport events
our constant ZMQ_EVENT_CONNECTED       is export(:DEFAULT, :events) = 0x0001;
our constant ZMQ_EVENT_CONNECT_DELAYED is export(:DEFAULT, :events) = 0x0002;
our constant ZMQ_EVENT_CONNECT_RETRIED is export(:DEFAULT, :events) = 0x0004;
our constant ZMQ_EVENT_LISTENING       is export(:DEFAULT, :events) = 0x0008;
our constant ZMQ_EVENT_BIND_FAILED     is export(:DEFAULT, :events) = 0x0010;
our constant ZMQ_EVENT_ACCEPTED        is export(:DEFAULT, :events) = 0x0020;
our constant ZMQ_EVENT_ACCEPT_FAILED   is export(:DEFAULT, :events) = 0x0040;
our constant ZMQ_EVENT_CLOSED          is export(:DEFAULT, :events) = 0x0080;
our constant ZMQ_EVENT_CLOSE_FAILED    is export(:DEFAULT, :events) = 0x0100;
our constant ZMQ_EVENT_DISCONNECTED    is export(:DEFAULT, :events) = 0x0200;
our constant ZMQ_EVENT_MONITOR_STOPPED is export(:DEFAULT, :events) = 0x0400;
our constant ZMQ_EVENT_ALL             is export(:DEFAULT, :events) = 0xFFFF;

# I/O multiplexing
our constant ZMQ_POLLIN  is export(:DEFAULT, :poll) = 1;
our constant ZMQ_POLLOUT is export(:DEFAULT, :poll) = 2;
our constant ZMQ_POLLERR is export(:DEFAULT, :poll) = 4;
our constant ZMQ_POLLPRI is export(:DEFAULT, :poll) = 8;

# ZMQ-specific error codes:
my constant ZMQ_HAUSNUMERO  = 156384712;
our constant EFSM            is export(:DEFAULT, :errors) = (ZMQ_HAUSNUMERO + 51);
our constant ENOCOMPATPROTO  is export(:DEFAULT, :errors) = (ZMQ_HAUSNUMERO + 52);
our constant ETERM           is export(:DEFAULT, :errors) = (ZMQ_HAUSNUMERO + 53);
our constant EMTHREAD        is export(:DEFAULT, :errors) = (ZMQ_HAUSNUMERO + 54);
