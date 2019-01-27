use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use experimental :pack;
use Net::BGP::Socket;

subtest 'Basic Server - Native OS', { connectivity-test }
$Net::BGP::Socket::linux = False;
subtest 'Basic Server - Fallback',  { connectivity-test }

sub connectivity-test() {
    my $inet = Net::BGP::Socket.new(:my-host("127.0.0.1"), :my-port(0));
    $inet.listen;
    is $inet.defined, True, "sock is defined";

    my $connections = $inet.acceptor;
    ok $connections ~~ Supply, "connections is a Supply";

    is $inet.socket-port.status, Kept, "bound port promise is kept";
    ok $inet.socket-port.result ~~ Int, "bound port does not die";
    ok $inet.socket-port.result ~~ 1024..65535, "bound port in proper range";
    note "# Listening on port {$inet.socket-port.result}";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($inet.socket-port.result));

    my $conn;
    my $promise = Promise.new;
    $connections.tap: { $conn = $_; $promise.keep };
    await $promise;

    is $conn.defined, True, "conn is defined";
    is $conn.socket-host, $inet.socket-host, "socket-host matches";
    is $conn.socket-port, $inet.socket-port.result, "socket-port matches socket-port";
    is $conn.peer-host, $inet.socket-host, "Connected to localhost";

    my $str = "Hello, World!\n";
    $conn.write( buf8.new( $str.encode(:encoding('ascii')) ) );
    is $client.recv, $str, "Read line 1";
   
    $conn.print($str);
    is $client.recv, $str, "Read line 2";
  
    $str = "Hello, World!"; 
    $conn.print("$str\n");
    is $client.recv, "$str\n", "Read line 3";

    $promise = Promise.new;
    my $buf;
    $client.print($str);
    $conn.Supply(:bin).tap: { $buf = $_; $promise.keep }
    await $promise;
    is $buf.unpack('a*'), $str, "Read line 4";

    done-testing;
};

done-testing;

