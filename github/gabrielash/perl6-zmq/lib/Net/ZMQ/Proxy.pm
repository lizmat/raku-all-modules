#!/usr/bin/env perl6

unit module Net::ZMQ::Proxy;
use NativeCall;
use v6;

use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::Socket;
use Net::ZMQ::Error;

class Proxy is export {
  has Socket $.frontend is required;
  has Socket $.backend is required; 
  has Socket $.capture;
  has Socket $.control;
  has Bool   $.throw = True;
  has ZMQError $.error;

 method TWEAK {}

  method run() {
     my $r = zmq_proxy_steerable($!frontend.as-ptr
                                , $!backend.as-ptr
                                , $!capture.defined ?? $!capture.as-ptr !! Any
                                , $!control.defined ?? $!control.as-ptr !! Any );
    if $r == -1  {
      $!error = $!throw ?? throw-error() !! get-error();
      return Any;
    }
    return 0;
 }
}

