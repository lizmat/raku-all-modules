#!/usr/bin/env perl6

unit module Net::ZMQ::EchoServer;
use NativeCall;
use v6;

use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::Context;
use Net::ZMQ::Socket;
use Net::ZMQ::Error;
use Net::ZMQ::Proxy;

class EchoServer is export {
  has Str $.uri is required;
  has Context $!ctx;
  has Socket $!socket;
  has Socket $!control;
  has Socket $!terminator;
  has Callable $!start;

my $ctrl-uri := 'inproc://';

  method TWEAK {
    $!start = sub () {
                      die "EchoServer: cannot reuse EchoServer" if $!ctx.defined;
                      $!ctx .= new;
                      $!socket .= new($!ctx, :server);
                      $!socket.bind($!uri);
                      $!control .= new($!ctx, :pull);
                      $!terminator .= new($!ctx, :push);
                      $!control.bind($ctrl-uri ~ self.WHICH );
                      $!terminator.connect($ctrl-uri ~ self.WHICH );
                      }
  } 

  method DESTROY {
   if $.socket.defined {
      $!ctx.shutdown;
      $!socket.unbind.close;
      $!control.unbind.close;
      $!terminator.unbind.close;
   }
  }

  method detach( --> Promise) {
    return  start { self.run() };
  }

  method run() {
    $!start();
    Proxy.new(:frontend($!socket), :backend($!socket), :$!control ).run();
  }

  method shutdown() { $!terminator.send('TERMINATE'); }

}
