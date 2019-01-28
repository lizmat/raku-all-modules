use v6.c;

unit module Net::NNG::Options;

#define NNG_OPT_SOCKNAME        "socket-name"
constant NNG_OPT_SOCKNAME       is export = "socket-name";
#define NNG_OPT_RAW             "raw"
constant NNG_OPT_RAW            is export = "raw";
#define NNG_OPT_PROTO           "protocol"
constant NNG_OPT_PROTO          is export = "protocol";
#define NNG_OPT_PROTONAME       "protocol-name"
constant NNG_OPT_PROTONAME      is export = "protocol-name";
#define NNG_OPT_PEER            "peer"
constant NNG_OPT_PEER           is export = "peer";
#define NNG_OPT_PEERNAME        "peer-name"
constant NNG_OPT_PEERNAME       is export = "peer-name";
#define NNG_OPT_RECVBUF         "recv-buffer"
constant NNG_OPT_RECVBUF        is export = "recv-buffer";
#define NNG_OPT_SENDBUF         "send-buffer"
constant NNG_OPT_SENDBUF        is export = "send-buffer";
#define NNG_OPT_RECVFD          "recv-fd"
constant NNG_OPT_RECVFD         is export = "recv-fd";
#define NNG_OPT_SENDFD          "send-fd"
constant NNG_OPT_SENDFD         is export = "send-fd";
#define NNG_OPT_RECVTIMEO       "recv-timeout"
constant NNG_OPT_RECVTIMEO      is export = "recv-timeout";
#define NNG_OPT_SENDTIMEO       "send-timeout"
constant NNG_OPT_SENDTIMEO      is export = "send-timeout";
#define NNG_OPT_LOCADDR         "local-address"
constant NNG_OPT_LOCADDR        is export = "local-address";
#define NNG_OPT_REMADDR         "remote-address"
constant NNG_OPT_REMADDR        is export = "remote-address";
#define NNG_OPT_URL             "url"
constant NNG_OPT_URL            is export = "url";
#define NNG_OPT_MAXTTL          "ttl-max"
constant NNG_OPT_MAXTTL         is export = "ttl-max";
#define NNG_OPT_RECVMAXSZ       "recv-size-max"
constant NNG_OPT_RECVMAXSZ      is export = "recv-size-max";
#define NNG_OPT_RECONNMINT      "reconnect-time-min"
constant NNG_OPT_RECONNMINT     is export = "reconnect-time-min";
#define NNG_OPT_RECONNMAXT      "reconnect-time-max"
constant NNG_OPT_RECONNMAXT     is export = "reconnect-time-max";
#define NNG_OPT_TCP_NODELAY     "tcp-nodelay"
constant NNG_OPT_TCP_NODELAY    is export = "tcp-nodelay";
#define NNG_OPT_TCP_KEEPALIVE   "tcp-keepalive"
constant NNG_OPT_TCP_KEEPALIVE  is export = "tcp-keepalive";


