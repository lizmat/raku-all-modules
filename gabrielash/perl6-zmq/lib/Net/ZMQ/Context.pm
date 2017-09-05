#!/usr/bin/env perl6

unit module Net::ZMQ::Context;
use v6;
use NativeCall;

use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::V4::Constants;
use Net::ZMQ::Error;
use Net::ZMQ::Common;
use Net::ZMQ::ContextOptions;

class Context does ContextOptions is export {
    has Pointer $.ctx;
    has Bool $.throw-everything = True;
    has ZMQError $.last-error;

    submethod TWEAK(){
        $!ctx := zmq_ctx_new();
        throw-error()  if ! $!ctx;
    }

    method DESTROY() {
        throw-error() if zmq_ctx_term( $!ctx ) == -1
                          && $.throw-everything;
    }

  method !fail()  {
       throw-error()
        if $.throw-everything;
       $!last-error =  get-error();
       return Any;
    }

    method !terminate() {
	     return zmq_ctx_term( $!ctx ) == 0
            ?? self !! self!fail;
    }

    method shutdown() {
      return zmq_ctx_shutdown( $!ctx ) == 0
            ?? self !! self!fail;
    }

    method get-option(Int $opt) {
	   my $result = zmq_ctx_get($!ctx, $opt);
	   return $result != -1
            ?? $result !! self!fail;
    }

    method set-option(Int $opt, Int $value) {
	    return zmq_ctx_set($!ctx, $opt, $value) == 0
            ?? self !! self!fail;
    }

    method FALLBACK($name, |c(Int $value = Int)) {

	    my $set-get = $value.defined ?? 'set' !! 'get';
	    my $method = $name.substr(0,4) eq "$set-get-"  ?? $name.substr(4) !! $name;
	    my $code = self.option( $method, 'code') ;

	    die "Context: unrecognized option request : { ($name, $value).perl }"
	      if ! $code.defined;

	    my $can-do = self.option( $method, $set-get );

	    die   "Context: { $value.defined ?? 'set' !! 'get'}ting this option not allowed: { ($name, $value).perl }"
	       if ! $can-do;

	    return $value // -1 if $code == ZMQ_TEST;

	    return $value.defined ?? self.set-option($code, $value)
				  !! self.get-option($code);
    }
}
