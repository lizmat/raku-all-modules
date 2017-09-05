#!/usr/bin/env perl6

unit module Net::ZMQ::SocketOptions;
use v6;

use Net::ZMQ::V4::Constants;

role SocketOptions is export {

    # type defaults to int
    # int size defaults to int32 (4)
    my %options =
	     test-value	 	=> %(code => ZMQ_TEST,			get => True, set => False)
	    , affinity		=> %(code => ZMQ_AFFINITY, 		get => True, set => True, size => 8)
	    , backlog 		=> %(code => ZMQ_BACKLOG,		get => True, set => True)
	    , connect-rid	=> %(code => ZMQ_CONNECT_RID,		get => False, set => True, type => buf8, size => 255 )
	    , conflate		=> %(code => ZMQ_CONFLATE,		get => False, set => True)
	    , connect-timeout   => %(code => ZMQ_CONNECT_TIMEOUT,	get => False, set => True,)
	    , curve-publickey	=> %(code => ZMQ_CURVE_PUBLICKEY,	get => True, set => True, type => buf8, size => 32)
      , curve-publickey-z85	=> %(code => ZMQ_CURVE_PUBLICKEY,	get => True, set => True, type => Str, size  => 41)
	    , curve-secretkey   => %(code => ZMQ_CURVE_SECRETKEY,	get => True, set => True,  type => buf8, size => 32)
	    , curve-server 	=> %(code => ZMQ_CURVE_SERVER,		get => False, set => True)
      , curve-secretkey-z85   	=> %(code => ZMQ_CURVE_SECRETKEY,	get => True, set => True,  type => Str , size => 41)
	    , curve-serverkey	=> %(code => ZMQ_CURVE_SERVERKEY,	get => True, set => True, type => buf8, size => 32)
      , curve-serverkey-z85	=> %(code => ZMQ_CURVE_SERVERKEY,	get => True, set => True, type => Str  , size => 41)
	    , events		=> %(code => ZMQ_EVENTS,		get => True, set => False)
	    , fd	  	=> %(code => ZMQ_FD,			get => True, set => False)
	    , gssapi-plaintest 	=> %(code => ZMQ_GSSAPI_PLAINTEXT,	get => False, set => True)
	    , gssapi-principal	=> %(code => ZMQ_GSSAPI_PRINCIPAL,	get => True, set => True, type => Str, size => 255)
	    , gssapi-server	=> %(code => ZMQ_GSSAPI_SERVER,		get => True, set => True)
	    , gssapi-service-principal => %(code =>  ZMQ_GSSAPI_SERVICE_PRINCIPAL,	get => True, set => True, type => Str, size => 255 )
	    , handshake-ivl	=> %(code => ZMQ_HANDSHAKE_IVL, 		get => True, set => True)
	    , heartbeat-ivl 	=> %(code => ZMQ_HEARTBEAT_IVL,			get => False, set => True)
	    , heartbit-timeout 	=> %(code => ZMQ_HEARTBEAT_TIMEOUT,		get => False, set => True)
	    , hearbeat-ttl 	=> %(code => ZMQ_HEARTBEAT_TTL,			get => False, set => True)
	    , identity		=> %(code => ZMQ_IDENTITY, 			get => True, set => True, type => buf8 , size => 255)
	    , immediate		=> %(code => ZMQ_IMMEDIATE, 			get => True, set => True)
	    , invert-matching	=> %(code => ZMQ_INVERT_MATCHING, 		get => True, set => True)
      #, ipv4only		=> %(code => ZMQ_IPV4ONLY, 			get => True, set => True)
	    , ipv6		=> %(code => ZMQ_IPV6, 				get => True, set => True)
	    , last-endpoint	=> %(code => ZMQ_LAST_ENDPOINT, 		get => True, set => False, type => Str, size => 127)
	    , linger		=> %(code => ZMQ_LINGER,	 		get => True, set => True, signed => True)
	    , max-msg-size	=> %(code => ZMQ_MAXMSGSIZE, 			get => True, set => True, size => 8)
	    , mechanism		=> %(code => ZMQ_MECHANISM, 			get => True, set => False)
	    , multicast-hops	=> %(code => ZMQ_MULTICAST_HOPS, 		get => True, set => True)
	    , plain-password	=> %(code => ZMQ_PLAIN_PASSWORD, 		get => True, set => True, type => Str, size => 255)
	    , plain-server	=> %(code => ZMQ_PLAIN_SERVER, 			get => True, set => True )
	    , plain-username	=> %(code => ZMQ_PLAIN_USERNAME, 		get => True, set => True, type => Str, size => 255)
	    , use-fd		=> %(code => ZMQ_USE_FD, 			get => True, set => True)
	    , probe-router 	=> %(code => ZMQ_PROBE_ROUTER,			get => False, set => True)
	    , rate		=> %(code => ZMQ_RATE, 				get => True, set => True)
	    , rcvbuf		=> %(code => ZMQ_RCVBUF, 			get => True, set => True)
	    , rcvhwm		=> %(code => ZMQ_RCVHWM,	 		get => True, set => True)
	    , incomplete    => %(code => ZMQ_RCVMORE, 			get => True, set => False)
	    , rcvtimeo		=> %(code => ZMQ_RCVTIMEO, 			get => True, set => True, signed => True)
	    , reconnect-ivl	=> %(code => ZMQ_RECONNECT_IVL, 		get => True, set => True)
	    , reconnect-ivl-max	=> %(code => ZMQ_RECONNECT_IVL_MAX, 		get => True, set => True)
	    , recovery-ivl	=> %(code => ZMQ_RECOVERY_IVL, 			get => True, set => True)
	    , req-correlate 	=> %(code => ZMQ_REQ_CORRELATE,			get => False, set => True)
	    , req-relaxed 	=> %(code => ZMQ_REQ_RELAXED,			get => False, set => True)
	    , router-handover 	=> %(code => ZMQ_ROUTER_HANDOVER,		get => False, set => True)
	    , router-mandatory	=> %(code => ZMQ_ROUTER_MANDATORY,		get => False, set => True)
	    , router-raw 	=> %(code => ZMQ_ROUTER_RAW,			get => False, set => True)
	    , sndbuf		=> %(code => ZMQ_SNDBUF, 			get => True, set => True)
	    , sndhwm	 	=> %(code => ZMQ_SNDHWM,				get => False, set => True)
	    , sndtimeo	 	=> %(code => ZMQ_SNDTIMEO,			get => False, set => True, signed => True)
	    , socks-proxy	=> %(code => ZMQ_SOCKS_PROXY, 			get => True, set => True)
	    , stream-notify 	=> %(code => ZMQ_STREAM_NOTIFY,			get => False, set => True)
	    , subscribe	 	=> %(code => ZMQ_SUBSCRIBE,			get => False, set => True, type => buf8 , size => 128)
	    , tcp-keepalive	=> %(code => ZMQ_TCP_KEEPALIVE, 		get => True, set => True, signed => True)
	    , tcp-keepalive-cnt	=> %(code => ZMQ_TCP_KEEPALIVE_CNT, 		get => True, set => True,  signed => True)
	    , tcp-keepalive-idle	=> %(code => ZMQ_TCP_KEEPALIVE_IDLE, 	get => True, set => True,  signed => True)
	    , tcp-keepalive-intlv	=> %(code => ZMQ_TCP_KEEPALIVE_INTVL, 	get => True, set => True,  signed => True)
	    , tcp-maxrt		=> %(code => ZMQ_TCP_MAXRT, 			get => True, set => True)
	    , thread-safe	=> %(code => ZMQ_THREAD_SAFE, 			get => True, set => False)
	    , tos		=> %(code => ZMQ_TOS, 				get => True, set => True)
	    , type		=> %(code => ZMQ_TYPE,	 			get => True, set => False)
	    , unsubscribe 	=> %(code => ZMQ_UNSUBSCRIBE,			get => False, set => True, type => buf8 , size => 128)
	    , xpub-verbose 	=> %(code => ZMQ_XPUB_VERBOSE,			get => False, set => True)
	    , xpub-verboser	=> %(code => ZMQ_XPUB_VERBOSER,			get => False, set => True)
	    , xpub-nodrop 	=> %(code => ZMQ_XPUB_NODROP,			get => False, set => True)
#	    , tcp-accpet-filter	=> %(code => ZMQ_TCP_ACCEPT_FILTER,		get => False, set => True, type => buf8, size => 255)
#	    , ipc-filter-gid 	=> %(code => ZMQ_IPC_FILTER_GID,		get => False, set => True, type => buf8)
#	    , ipc-filter-pid 	=> %(code => ZMQ_IPC_FILTER_PID,		get => False, set => True)
#	    , ipc-filter-uid 	=> %(code => ZMQ_IPC_FILTER_UID,		get => False, set => True)
#	    , zap-domain	=> %(code => ZMQ_ZAP_DOMAIN, 			get => True, set => True, type => Str, size => 63)
#	    , vmct-buffer-size	=> %(code => ZMQ_VMCI_BUFFER_SIZE, 		get => True, set => True)
	    , vmct-buffer-min-size  => %(code => ZMQ_VMCI_BUFFER_MIN_SIZE, 	get => True, set => True)
	    , vmct-buffer-max-size  => %(code => ZMQ_VMCI_BUFFER_MAX_SIZE, 	get => True, set => True)
	    , vmci-connect-timeout  => %(code => ZMQ_VMCI_CONNECT_TIMEOUT, 	get => True, set => True)
	;

    multi method option($name) { return %options{ $name };}

    multi method option($name, $key) {
		  my $value = %options{ $name }{ $key };
		  return $value
        unless $value === Any;
		  return Int
        if $key eq 'type';
		  return 4
        if $key eq 'size';
	  }






}
