#!/usr/bin/env perl6

unit module Net::ZMQ::ContextOptions;
use v6;

use Net::ZMQ::V4::Constants;
use Net::ZMQ::Common;

role ContextOptions is export {

  my %options =
    fix-blocky		=> %(code => ZMQ_BLOCKY , 		get => True, set => True)
		, io-threads 	=> %(code => ZMQ_IO_THREADS,		get => True, set => True)
		, scheduling-policy => %(code => ZMQ_THREAD_SCHED_POLICY,	get => True, set => True)
		, priority		=> %(code => ZMQ_THREAD_PRIORITY,	get => True, set => True)
		, max-msg-size	=> %(code => ZMQ_MAX_MSGSZ,		get => True, set => True)
		, max-sockets	=> %(code => ZMQ_MAX_SOCKETS,		get => True, set => True)
		, ipv6		=> %(code => ZMQ_IPV6,			get => True, set => True)
    # experimental	    , rt-msg-size  	=> %(code => ZMQ_MSG_T_SIZE,		get => True, set => False)
		, socket-limit	=> %(code => ZMQ_SOCKET_LIMIT,		get => True, set => False)
    ## this is only for tests
		, test-value	=> %(code => ZMQ_TEST,			get => True, set => True)
		;

    multi method option($name) { return %options{ $name };}
    multi method option($name, $key) { return %options{ $name }{ $key };}
}
