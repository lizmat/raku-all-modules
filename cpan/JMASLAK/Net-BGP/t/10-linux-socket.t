use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use experimental :pack;
use Net::BGP::Socket-Linux;
use Net::BGP::Socket-Connection-Linux;

note "KERNEL Name: " ~ $*KERNEL.name;
plan :skip-all("Non-Linux Host") unless $*KERNEL.name eq 'linux';

subtest 'Basic Server', {
    my $inet = Net::BGP::Socket-Linux.new(:my-host('127.0.0.1'), :my-port(0));
    my $sock = $inet.socket;

    ok $sock ~~ Int, "sock is proper type";
    is $sock.defined, True, "sock is defined";

    $inet.bind;
    $inet.listen;
    
    ok $inet.bound-port ~~ Int, "bound port does not die";
    ok $inet.bound-port ~~ 1024..65535, "bound port in proper range";
    note "# Listening on port {$inet.bound-port}";

    my $connections = $inet.acceptor;
    ok $connections ~~ Supply, "connections is a Supply";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($inet.bound-port));

    my $conn;
    my $promise = Promise.new;
    $connections.tap: { $conn = $_; $promise.keep };
    await $promise;

    ok $conn ~~ Net::BGP::Socket-Connection-Linux, "conn is Socket-Connection";
    is $conn.defined, True, "conn is defined";
    is $conn.my-host, $inet.my-host, "my-host matches";
    is $conn.my-port, $inet.bound-port, "my-port matches bound-port";
    is $conn.peer-family, 2, "Peer family is AF_INET";
    is $conn.peer-host, $inet.my-host, "Connected to localhost";
    ok $conn.socket-fd ~~ UInt, "Socket is UInt";
    ok $conn.socket-fd > 0, "Socket is defined";

    my $str = "Hello, World!\n";
    $conn.write( buf8.new( $str.encode(:encoding('ascii')) ) );
    is $client.recv, $str, "Read line 1";
   
    $conn.print($str);
    is $client.recv, $str, "Read line 2";
  
    $str = "Hello, World!"; 
    $conn.say($str);
    is $client.recv, "$str\n", "Read line 3";

    $str = "Hello, World!\n";
    $client.print($str);
    is $conn.recv.unpack('a*'), $str, "Read line 4";

    $promise = Promise.new;
    my $buf;
    $client.print($str);
    $conn.Supply.tap: { $buf = $_; $promise.keep }
    await $promise;
    is $buf.unpack('a*'), $str, "Read line 5";

    $conn.buffered-send( buf8.new( $str.encode(:encoding('ascii')) ) );
    is $client.recv, $str, "Read line 6";
    $conn.buffered-send( buf8.new( $str.encode(:encoding('ascii')) ) );
    is $client.recv, $str, "Read line 7";
   
    done-testing;
};

subtest 'Client/Server', {
    my $inet1 = Net::BGP::Socket-Linux.new(:my-host('127.0.0.1'), :my-port(0));
    my $sock1 = $inet1.socket;
    $inet1.bind;
    $inet1.listen;
    note "# Listening on port {$inet1.bound-port}";
    
    my $inet2 = Net::BGP::Socket-Linux.new(:my-host('127.0.0.1'), :my-port(0));
    my $conn2 = await $inet2.connect('127.0.0.1', $inet1.bound-port);
    
    my $connections1 = $inet1.acceptor;
    my $promise = Promise.new;
    $connections1.tap: { $promise.keep($_) };
    my $conn1 = await $promise;
    lives-ok { $inet1.close }, "Listening socket closed";

    my $str = "Hello, World!\n";
    my $buf = buf8.new( $str.encode(:encoding('ascii')) );

    $conn1.write($buf);
    is $conn2.recv, $buf, "Read line 1";
    $conn2.write($buf);
    is $conn1.recv, $buf, "Read line 2";

    lives-ok { $conn1.close }, "Connection 1 closed";
    lives-ok { $conn2.close }, "Connection 2 closed";
   
    done-testing;
};

subtest 'Client/Server - MD5 Non-Match', sub {
    plan :skip-all("No MD5 support") unless Net::BGP::Socket-Linux.supports-md5;

    my $inet1 = Net::BGP::Socket-Linux.new(:my-host('127.0.0.1'), :my-port(0));
    my $sock1 = $inet1.socket;

    my $inet2 = Net::BGP::Socket-Linux.new(:my-host('127.0.0.1'), :my-port(0));

    $inet1.add-md5('192.0.2.1', 'key key key'); # should not match anything
    $inet1.bind;

    $inet1.listen;

    my $conn2 = await $inet2.connect('127.0.0.1', $inet1.bound-port);
    
    my $connections1 = $inet1.acceptor;
    my $promise = Promise.new;
    $connections1.tap: { $promise.keep($_) };
    my $conn1 = await $promise;
    lives-ok { $inet1.close }, "Listening socket closed";

    my $str = "Hello, World!\n";
    my $buf = buf8.new( $str.encode(:encoding('ascii')) );

    $conn1.write($buf);
    is $conn2.recv, $buf, "Read line 1";

    lives-ok { $conn1.close }, "Connection 1 closed";
    lives-ok { $conn2.close }, "Connection 2 closed";
   
    done-testing;
};


subtest 'Client/Server - MD5 Match', sub {
    plan :skip-all("No MD5 support") unless Net::BGP::Socket-Linux.supports-md5;

    my $inet1 = Net::BGP::Socket-Linux.new(:my-host('127.0.0.1'), :my-port(0));
    my $sock1 = $inet1.socket;

    my $inet2 = Net::BGP::Socket-Linux.new(:my-host('127.0.0.1'), :my-port(0));

    $inet1.add-md5('127.0.0.1', 'key key key');
    $inet2.add-md5('127.0.0.1', 'key key key');

    $inet1.bind;
    $inet1.listen;

    my $conn2 = await $inet2.connect('127.0.0.1', $inet1.bound-port);
    
    my $connections1 = $inet1.acceptor;
    my $promise = Promise.new;
    $connections1.tap: { $promise.keep($_) };
    my $conn1 = await $promise;
    lives-ok { $inet1.close }, "Listening socket closed";

    my $str = "Hello, World!\n";
    my $buf = buf8.new( $str.encode(:encoding('ascii')) );

    $conn1.write($buf);
    is $conn2.recv, $buf, "Read line 1";

    lives-ok { $conn1.close }, "Connection 1 closed";
    lives-ok { $conn2.close }, "Connection 2 closed";
   
    done-testing;
};

done-testing;

