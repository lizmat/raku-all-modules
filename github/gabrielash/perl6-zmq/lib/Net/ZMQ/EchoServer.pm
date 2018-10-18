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
  has Promise $!promise;
  has Bool $!terminate;
  my Str $ctrl-uri := 'inproc://';

  method TWEAK {
    $!ctx .= new;
  }

method _test {
  die "No Context" without $!ctx;
  die "No Socket" without $!socket;
  die "No Control" without $!control;
  die "No Terminator" without $!terminator;
  say "Promise EchoServer = " ~ $!promise.status;
  return  $!promise.status;
 }

  method !start {
    die "EchoServer: cannot reuse EchoServer" with $!socket;
    $!socket .= new($!ctx, :server);
    #say $!socket.perl;
    $!socket.bind($!uri);
    $!control .= new($!ctx, :pull);
    $!control.connect($ctrl-uri ~ self.WHICH );
    Proxy.new(:frontend($!socket), :backend($!socket), :$!control ).run();
    CATCH { default { say $_.perl; $_.rethrow }}
  }

  method DESTROY {
   with $.socket {
      $!ctx.shutdown;
      $!socket.unbind.close;
      $!control.disconnect.close;
      $!terminator.unbind.close;
   }
  }

  method detach( --> EchoServer) {
    $!promise =  Promise.start( { self!start  });
    $!terminator .= new($!ctx, :push);
    $!terminator.bind($ctrl-uri ~ self.WHICH );
    return self;
  }


  method run( --> EchoServer) {
    self!start();
    $!terminator .= new($!ctx, :push);
    $!terminator.connect($ctrl-uri ~ self.WHICH );
    return self;
  }

  method shutdown() {
    $!terminator.send('TERMINATE');    
  }

}
