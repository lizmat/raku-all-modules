#!/usr/bin/env perl6

unit module Net::ZMQ::V4::Constants;
use v6;

constant ZMQ_VERSION_MAJOR is export = 4;
constant ZMQ_VERSION_MINOR is export = 2;
constant ZMQ_VERSION_PATCH is export = 1;

# for testing only
constant ZMQ_TEST is export = -10000;

constant ZMQ_DEFINED_STDINT  is export(:MANDATORY) = 1;

my constant ZMQ_HAUSNUMERO = 156384712;

enum ERROR_C is export(:MANDATORY)
  <<
  :ZMQ_EAGAIN(11)
  >>;


enum 	ERRORS1 is export(:MANDATORY)
	<<
	:ENOTSUP(156384713)
	EPROTONOSUPPORT
	ENOBUF
	ENETDOWN
	EADDRINUSE
	EADDRNOTAVAIL
	ECONNREFUSED
	EINPROGRESS
	ENOTSOCK
	EMSGSIZE
	EAFNOSUPPORT
	ENETUNREACH
	ECONNABORTED
	ECONNRESET
	ENOTCONN
	ETIMEDOUT
	EHOSTUNREACH
	ENETRESET
	>>;

enum	ERRORS2  is export(:MANDATORY)
	<<
	:EFSM(156384763)
	ENOCOMPATPROTO
	ETERM
	EMTHREAD
	>>;

# context
constant ZMQ_IO_THREADS is export(:MANDATORY)  = 1;
constant ZMQ_MAX_SOCKETS is export(:MANDATORY) = 2;
constant ZMQ_SOCKET_LIMIT is export(:MANDATORY) = 3;
constant ZMQ_THREAD_PRIORITY is export(:MANDATORY) = 3;
constant ZMQ_THREAD_SCHED_POLICY is export(:MANDATORY) = 4;
constant ZMQ_MAX_MSGSZ is export(:MANDATORY) = 5;

# context defaults
constant ZMQ_IO_THREADS_DFLT is export(:MANDATORY)  = 1;
constant ZMQ_MAX_SOCKETS_DFLT is export(:MANDATORY) = 1023;
constant ZMQ_THREAD_PRIORITY_DFLT is export(:MANDATORY) =  -1;
constant ZMQ_THREAD_SCHED_POLICY_DFLT is export(:MANDATORY) = -1;

# socket types
constant ZMQ_PAIR is export(:MANDATORY) = 0;
constant ZMQ_PUB is export(:MANDATORY) = 1;
constant ZMQ_SUB is export(:MANDATORY) = 2;
constant ZMQ_REQ is export(:MANDATORY) = 3;
constant ZMQ_REP is export(:MANDATORY) = 4;
constant ZMQ_DEALER is export(:MANDATORY) = 5;
constant ZMQ_ROUTER is export(:MANDATORY) = 6;
constant ZMQ_PULL is export(:MANDATORY) = 7;
constant ZMQ_PUSH is export(:MANDATORY) = 8;
constant ZMQ_XPUB is export(:MANDATORY) = 9;
constant ZMQ_XSUB is export(:MANDATORY) = 10;
constant ZMQ_STREAM is export(:MANDATORY) = 11;

# deprecated
constant ZMQ_XREQ is export(:DEPRECATED) = ZMQ_DEALER;
constant ZMQ_XREP is export(:DEPRECATED) = ZMQ_ROUTER;

# socket options
enum SOCKET_OPTS  is export(:MANDATORY)
    <<
    :ZMQ_AFFINITY(4)
    ZMQ_IDENTITY
    ZMQ_SUBSCRIBE
    ZMQ_UNSUBSCRIBE
    ZMQ_RATE
    ZMQ_RECOVERY_IVL

    ZMQ_UNUSED_10
    ZMQ_SNDBUF
    ZMQ_RCVBUF
    ZMQ_RCVMORE
    ZMQ_FD
    ZMQ_EVENTS
    ZMQ_TYPE
    ZMQ_LINGER
    ZMQ_RECONNECT_IVL
    ZMQ_BACKLOG

    ZMQ_UNUSED_20
    ZMQ_RECONNECT_IVL_MAX
    ZMQ_MAXMSGSIZE
    ZMQ_SNDHWM
    ZMQ_RCVHWM
    ZMQ_MULTICAST_HOPS
    ZMQ_UNUSED_26
    ZMQ_RCVTIMEO
    ZMQ_SNDTIMEO
    ZMQ_UNUSED_29
    ZMQ_UNUSED_30
    ZMQ_UNUSED_31
    ZMQ_LAST_ENDPOINT
    ZMQ_ROUTER_MANDATORY
    ZMQ_TCP_KEEPALIVE
    ZMQ_TCP_KEEPALIVE_CNT
    ZMQ_TCP_KEEPALIVE_IDLE
    ZMQ_TCP_KEEPALIVE_INTVL

    ZMQ_UNUSED_38
    ZMQ_IMMEDIATE
    ZMQ_XPUB_VERBOSE
    ZMQ_ROUTER_RAW
    ZMQ_IPV6
    ZMQ_MECHANISM
    ZMQ_PLAIN_SERVER
    ZMQ_PLAIN_USERNAME
    ZMQ_PLAIN_PASSWORD
    ZMQ_CURVE_SERVER
    ZMQ_CURVE_PUBLICKEY
    ZMQ_CURVE_SECRETKEY
    ZMQ_CURVE_SERVERKEY
    ZMQ_PROBE_ROUTER
    ZMQ_REQ_CORRELATE
    ZMQ_REQ_RELAXED
    ZMQ_CONFLATE
    ZMQ_ZAP_DOMAIN
    ZMQ_ROUTER_HANDOVER
    ZMQ_TOS
    ZMQ_UNUSED_58 ZMQ_UNUSED_59 ZMQ_UNUSED_60
    ZMQ_CONNECT_RID
    ZMQ_GSSAPI_SERVER
    ZMQ_GSSAPI_PRINCIPAL
    ZMQ_GSSAPI_SERVICE_PRINCIPAL
    ZMQ_GSSAPI_PLAINTEXT
    ZMQ_HANDSHAKE_IVL

    ZMQ_UNUSED_67
    ZMQ_SOCKS_PROXY
    ZMQ_XPUB_NODROP
    ZMQ_BLOCKY
    ZMQ_XPUB_MANUAL
    ZMQ_XPUB_WELCOME_MSG
    ZMQ_STREAM_NOTIFY
    ZMQ_INVERT_MATCHING
    ZMQ_HEARTBEAT_IVL
    ZMQ_HEARTBEAT_TTL
    ZMQ_HEARTBEAT_TIMEOUT
    ZMQ_XPUB_VERBOSER
    ZMQ_CONNECT_TIMEOUT
    ZMQ_TCP_MAXRT
    ZMQ_THREAD_SAFE

    ZMQ_UNUSED_82
    ZMQ_UNUSED_83
    ZMQ_MULTICAST_MAXTPDU
    ZMQ_VMCI_BUFFER_SIZE
    ZMQ_VMCI_BUFFER_MIN_SIZE
    ZMQ_VMCI_BUFFER_MAX_SIZE
    ZMQ_VMCI_CONNECT_TIMEOUT
    ZMQ_USE_FD
    >>;

# message
constant ZMQ_MORE is export(:MANDATORY) = 1;
constant ZMQ_SHARED is export(:MANDATORY) = 3;

# send/recv
constant ZMQ_DONTWAIT is export(:MANDATORY) = 1;
constant ZMQ_SNDMORE is export(:MANDATORY) = 2;

# security
constant ZMQ_NULL is export(:SECURITY) = 0;
constant ZMQ_PLAIN is export(:SECURITY) = 1;
constant ZMQ_CURVE is export(:SECURITY) = 2;
constant ZMQ_GSSAPI is export(:SECURITY) = 3;

#Radio Dish
constant ZMQ_GROUP_MAX_LENGTH is export(:RADIO)        = 15;

# Deprecated
constant ZMQ_TCP_ACCEPT_FILTER is export(:DEPRECATED)       = 38;
constant ZMQ_IPC_FILTER_PID is export(:DEPRECATED)          = 58;
constant ZMQ_IPC_FILTER_UID is export(:DEPRECATED)          = 59;
constant ZMQ_IPC_FILTER_GID is export(:DEPRECATED)          = 60;
constant ZMQ_IPV4ONLY is export(:DEPRECATED)                = 31;

constant ZMQ_DELAY_ATTACH_ON_CONNECT is export(:DEPRECATED) = ZMQ_IMMEDIATE;
constant ZMQ_NOBLOCK is export(:DEPRECATED)                 = ZMQ_DONTWAIT;
constant ZMQ_FAIL_UNROUTABLE is export(:DEPRECATED)         = ZMQ_ROUTER_MANDATORY;
constant ZMQ_ROUTER_BEHAVIOR is export(:DEPRECATED)         = ZMQ_ROUTER_MANDATORY;

constant ZMQ_SRCFD is export(:DEPRECATED) = 2;


# Socket Transport Events
constant ZMQ_EVENT_CONNECTED is export(:EVENT)         = 0x0001;
constant ZMQ_EVENT_CONNECT_DELAYED is export(:EVENT)   = 0x0002;
constant ZMQ_EVENT_CONNECT_RETRIED is export(:EVENT)   = 0x0004;
constant ZMQ_EVENT_LISTENING     is export(:EVENT)     = 0x0008;
constant ZMQ_EVENT_BIND_FAILED is export(:EVENT)       = 0x0010;
constant ZMQ_EVENT_ACCEPTED is export(:EVENT)          = 0x0020;
constant ZMQ_EVENT_ACCEPT_FAILED is export(:EVENT)     = 0x0040;
constant ZMQ_EVENT_CLOSED is export(:EVENT)            = 0x0080;
constant ZMQ_EVENT_CLOSE_FAILED  is export(:EVENT)     = 0x0100;
constant ZMQ_EVENT_DISCONNECTED is export(:EVENT)      = 0x0200;
constant ZMQ_EVENT_MONITOR_STOPPED is export(:EVENT)   = 0x0400;
constant ZMQ_EVENT_ALL is export(:EVENT)               = 0xFFFF;

# I/O multiplexing
constant ZMQ_POLLIN is export(:IOPLEX) = 1;
constant ZMQ_POLLOUT is export(:IOPLEX) = 2;
constant ZMQ_POLLERR is export(:IOPLEX) = 4;
constant ZMQ_POLLPRI is export(:IOPLEX) = 8;
constant ZMQ_POLLITEMS_DFLT is export(:IOPLEX) = 16;
constant ZMQ_HAS_CAPABILITIES is export(:IOPLEX) = 1;


# deprecated
constant ZMQ_STREAMER is export(:DEPRECATED) = 1;
constant ZMQ_FORWARDER is export(:DEPRECATED) = 2;
constant ZMQ_QUEUE is export(:DEPRECATED) = 3;



# Draft Constants, not in stable releases
constant ZMQ_SERVER is export(:DRAFT) = 12;
constant ZMQ_CLIENT is export(:DRAFT) = 13;
constant ZMQ_RADIO is export(:DRAFT) = 14;
constant ZMQ_DISH is export(:DRAFT) = 15;
constant ZMQ_GATHER is export(:DRAFT) = 16;
constant ZMQ_SCATTER is export(:DRAFT) = 17;
constant ZMQ_DGRAM is export(:DRAFT) = 18;

constant ZMQ_EVENT_HANDSHAKE_FAILED is export(:DRAFT)  = 0x0800;
constant ZMQ_EVENT_HANDSHAKE_SUCCEED is export(:DRAFT) = 0x1000;

constant ZMQ_MSG_T_SIZE is export(:DRAFT) = 6;

constant ZMQ_HAVE_POLLER is export(:DRAFT) = 1;
constant ZMQ_HAVE_TIMERS is export(:DRAFT) = 1;
