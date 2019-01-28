use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#
# Some of this is "borrowed" from https://docs.perl6.org/language/nativecall .
# I do not have copyright to that, so those portions are not subject to my
# copyright.
#

use StrictClass;
unit class Net::BGP::Socket:ver<0.0.9>:auth<cpan:JMASLAK> does StrictClass;

use if;
use Net::BGP::Socket-Linux:if($*KERNEL.name eq 'linux');

our $linux = $*KERNEL.name eq 'linux';

#
# Public attributes
#
has Str:D     $.my-host     is rw is required;
has Int:D     $.my-port     is rw is required;
has Promise:D $.socket-port = Promise.new;
has           $.sock        is rw;
has Str:D     %!md5;

# Aliases for socket-(port|host)
method socket-host { return $.my-host }
method socket-post { return $.my-post }

method listen(-->Nil) {
    if $linux {
        $!sock = Net::BGP::Socket-Linux.new(:$.my-host, :$.my-port);
        for %!md5.keys -> $key { $!sock.add-md5($key, %!md5{$key}) }

        $!sock.socket.sink;
        $!sock.set-reuseaddr;
        $!sock.bind;
        $!sock.listen;

        $!socket-port.keep($!sock.find-bound-port);
    } else {
        $!sock = IO::Socket::Async.listen($.my-host, $.my-port);
    }
}

# Start accepting connections
method acceptor(-->Supply:D) {
    if $linux {
        return $!sock.acceptor;
    } else {
        my $supply = Supplier::Preserving.new();
        my $tap = $!sock.tap( { $supply.emit($_) } );

        await $tap.socket-port;
        $.socket-port.keep( $tap.socket-port.result );

        return $supply.Supply(:bin);
    }
}

method connect(Str:D $host, Int:D $port -->Promise) {
    if $linux {
        $!sock = Net::BGP::Socket-Linux.new(:$.my-host, :$.my-port);
        for %!md5.keys -> $key { $!sock.add-md5($key, %!md5{$key}) }
        # $!sock.socket.sink;
        # $!sock.bind;
        return $!sock.connect($host, $port);
    } else {
        return IO::Socket::Async.connect($host, $port);
    }
}

method close(-->Nil) {
    $!sock.close;
}

method add-md5(Str:D $host, Str $MD5 -->Nil) {
    if ! $linux { die("Cannot configure MD5 on this operating system") }

    %!md5{ $host.fc } = $MD5;
}

