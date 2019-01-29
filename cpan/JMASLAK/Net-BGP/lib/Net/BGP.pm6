use v6.d;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Command;
use Net::BGP::Command::BGP-Message;
use Net::BGP::Command::Stop;
use Net::BGP::Controller;
use Net::BGP::Connection;
use Net::BGP::Conversions;
use Net::BGP::IP;
use Net::BGP::Event::New-Connection;
use Net::BGP::Peer;
use Net::BGP::Socket;
use Net::BGP::Time;

# We need to register all the parameter types, which happens when the
# module is loaded.
use Net::BGP::Parameter;
use Net::BGP::Parameter::Capabilities;
use Net::BGP::Parameter::Generic;

# We need to register all the message types, which happens when the
# module is loaded.
use Net::BGP::Message;
use Net::BGP::Message::Generic;
use Net::BGP::Message::Keep-Alive;
use Net::BGP::Message::Open;
use Net::BGP::Message::Notify;
use Net::BGP::Message::Notify::Generic;
use Net::BGP::Message::Notify::Header;
use Net::BGP::Message::Notify::Header::Connection-Not-Syncronized;
use Net::BGP::Message::Notify::Header::Generic;
use Net::BGP::Message::Notify::Open;
use Net::BGP::Message::Notify::Open::Bad-Peer-AS;
use Net::BGP::Message::Notify::Open::Generic;
use Net::BGP::Message::Notify::Open::Unsupported-Optional-Parameter;
use Net::BGP::Message::Notify::Open::Unsupported-Version;
use Net::BGP::Message::Notify::Hold-Timer-Expired;
use Net::BGP::Message::Update;

use StrictClass;
unit class Net::BGP:ver<0.1.0>:auth<cpan:JMASLAK> does StrictClass;

our subset PortNum of Int where ^65536;

has PortNum:D $.port is default(179);
has Str:D     $.listen-host is default('0.0.0.0');

has Channel  $.listener-channel;    # Listener channel
has Supplier $!user-supplier;       # Supplier object (to send events to the user)
has Channel  $.user-channel;        # User channel (for the user to receive the events)

has Net::BGP::Controller $.controller is rw;

has Int:D  $.my-asn     is required where ^(2³²);
has Int:D  $.identifier is required where ^(2³²);
has Bool:D $.add-unknown-peers = False;

has Str:D %!md5;

submethod BUILD( *%args ) {
    for %args.keys -> $k {
        given $k {
            when 'port'              { $!port              = %args{$k} if %args{$k}.defined }
            when 'listen-host'       { $!listen-host       = %args{$k} }
            when 'my-asn'            { $!my-asn            = %args{$k} }
            when 'identifier'        { $!identifier        = %args{$k} }
            when 'add-unknown-peers' { $!add-unknown-peers = %args{$k} }
            default { die("Invalid attribute set in call to constructor: $k") }
        }
    }

    $!user-supplier = Supplier.new;
    $!user-channel  = $!user-supplier.Supply.Channel;

    # This really shouldn't be necessary, but I seem to have tripped a
    # Rakudo bug.
    my $unknown = $!add-unknown-peers // False;

    $!controller    = Net::BGP::Controller.new(
        :$!my-asn,
        :$!identifier,
        :$!user-supplier,
        :add-unknown-peers($unknown),
    );
}

method listen-stop(--> Nil) {
    if defined $!listener-channel {
        $!listener-channel.send(Net::BGP::Command::Stop.new);
    }
}

method send-bgp(Int:D $connection-id, Net::BGP::Message:D $bgp) {
    my $msg = Net::BGP::Command::BGP-Message.new(
        :connection-id($connection-id),
        :message($bgp),
    );

    $!controller.connections.get($connection-id).command.send($msg);
}

method announce(
    Int:D $connection-id,
          @prefixes,
    Str:D $next-hop,
    Str:D $as-path? is copy = "",
    Str:D $origin? = '?',
          :@attrs? = [],
          :@communities? = []
    -->Nil
) {
    die "Invalid origin" unless $origin.fc eq 'i'|'e'|'?';
  
    my $connection  = $!controller.connections.get($connection-id);
    my $ip = $connection.peer-ip;
    my $peer = self.peer-get(:peer-ip($ip));
    my Bool $asn32;
    my Bool $ibgp;
    my Int  $my-asn;
    $peer.lock.protect: {
        die "Peer not defined" unless $peer.defined;
        $asn32  = $peer.do-asn32;
        $ibgp   = $peer.is-ibgp;
        $my-asn = $peer.my-asn;
    }

    # If it's an eBGP session, we want to prepend our ASN.
    if ! $ibgp {
        if $as-path ne '' {
            $as-path = "$my-asn $as-path";
        } else {
            $as-path = ~$my-asn;
        }
    }

    # We're going to assume we can fit 20 prefixes into an update
    # message.  This is completely arbitrary and completely the wrong
    # way to do this.
    # XXX We should test for a special exception type when we construct
    # the announcement.
    
    my $af = @prefixes.grep( { $_.contains(':') } ).elems ?? 'ipv6' !! 'ipv4';

    for @prefixes.batch(20) -> $batch {
        my %hash;
        %hash<message-name>    = 'UPDATE';
        %hash<as-path>         = $as-path;
        %hash<local-pref>      = 100 if $ibgp;    # XXX Vlaue should be configurable
        %hash<origin>          = $origin;
        %hash<next-hop>        = $next-hop;
        %hash<nlri>            = @prefixes;
        %hash<path-attributes> = @attrs;

        if @communities.elems {
            %hash<community>   = @communities;
        }

        %hash<address-family>  = $af;

        my $msg = Net::BGP::Message.from-hash(%hash, :$asn32);
        self.send-bgp($connection-id, $msg);
    }
}

method listen(--> Nil) {
    my $promise = Promise.new;

    my $listen-socket;

    if defined $!listener-channel {
        die("BGP is already listening");
    }

    $!listener-channel = Channel.new;
    my $listen-promise = Promise.new;

    start {
        $listen-socket = Net::BGP::Socket.new(:my-host($.listen-host), :my-port($.port));
        for %!md5.keys -> $h { $listen-socket.add-md5($h, %!md5{$h}) }
        $listen-socket.listen;

        react {
            whenever $listen-socket.acceptor -> $socket {
                my $conn = Net::BGP::Connection.new(
                    :socket($socket),
                    :listener-channel($!listener-channel),
                    :user-supplier($!user-supplier),
                    :bgp-handler($.controller),
                    :remote-ip($socket.peer-host),
                    :remote-port($socket.peer-port),
                    :inbound(True),
                );
                if %*ENV<bgp_debug_prefix>:exists {
                    my $prefix = %*ENV<bgp_debug_prefix>;
                    if $prefix ne '' {
                        $conn.debug = open "{$prefix}.{$conn.id}", :w;
                    }
                }

                # Set up connection object
                $!controller.connections.add($conn);
                $!user-supplier.emit(
                    Net::BGP::Event::New-Connection.new(
                        :client-ip( $socket.peer-host ),
                        :client-port( $socket.peer-port ),
                        :connection-id( $conn.id ),
                    ),
                );

                # Do this in a child process.
                start {
                    $conn.handle-messages;

                    CATCH {
                        default {
                            # We should log better
                            $*ERR.say("Error in child process!");
                            $*ERR.say(.message);
                            $*ERR.say(.backtrace.join);
                            .rethrow;
                        }
                    }
                }
            }

            await $listen-socket.socket-port;      # make sure the socket is ready
            $!port = $listen-socket.socket-port.result;
            $listen-promise.keep($.port);

            whenever $!listener-channel -> Net::BGP::Command $msg {
                if $msg.message-name eq "Stop" {
                    $listen-socket = Nil;
                    $promise.keep();
                    done();
                    # XXX Do we need to kill the children?
                } elsif $msg.message-name eq "Dead-Child" {
                    $!controller.connections.remove($msg.connection-id);
                } else {
                    !!!;
                }
            }

            whenever Supply.interval(1) { self.tick }
        }

        await $promise;

        CATCH {
            default {
                # We should log better
                $*ERR.say("Error in child process!");
                $*ERR.say(.message);
                $*ERR.say(.backtrace.join);
                .rethrow;
            }
        }

    }
    await $listen-promise;

    return;
}

method peer-add (
    Int:D  :$peer-asn,
    Str:D  :$peer-ip,
    Int:D  :$peer-port? = 179,
    Bool:D :$passive? = False,
    Bool:D :$ipv4? = True,
    Bool:D :$ipv6? = False,
) {
    $.controller.peers.add(
        :$peer-asn,
        :$peer-ip,
        :$peer-port,
        :$passive,
        :$ipv4,
        :$ipv6
    );
}

method peer-get (
    Str:D :$peer-ip,
    -->Net::BGP::Peer
) {
    return $.controller.peers.get($peer-ip);
}

method peer-remove ( Str:D :$peer-ip, Int:D :$peer-port? = 179 ) {
    $.controller.peers.remove(:$peer-ip, :$peer-port);
}

# Deal with clock tick
method tick(-->Nil) {
    self.connect-if-needed;
    self.send-keepalives;
    self.reap-dead-connections;
}

method connect-if-needed(-->Nil) {
    loop {
        my $p = $.controller.peers.get-peer-due-for-connect;
        if ! $p.defined { return; }

        $p.lock.protect: {
            if $p.connection.defined { next; }    # Someone created a connection

            $p.last-connect-attempt = monotonic-whole-seconds;
        }

        my $obj = Net::BGP::Socket.new(:my-host('::'), :my-port(0));
        if %!md5{ $p.peer-ip.fc }:exists {
            $obj.add-md5($p.peer-ip.fc, %!md5{ $p.peer-ip.fc });
        }
        my $promise = $obj.connect($p.peer-ip, $p.peer-port);
        start self.connection-handler($promise, $p);
    }
}

method connection-handler(Promise:D $socket-promise, Net::BGP::Peer:D $peer) {
    my $socket;
    {
	$socket = $socket-promise.result;
	CATCH {
	    default {
		# XXX We should log better
		# But we know...Connection failed.
		return;
	    }
	}
    }

    my $conn;
    if $peer.connection.defined { return } # Just in case it got defined

    $conn = Net::BGP::Connection.new(
	:socket($socket),
	:listener-channel($!listener-channel),
	:user-supplier($!user-supplier),
	:bgp-handler($.controller),
	:remote-ip($socket.peer-host),
	:remote-port($socket.peer-port),
	:inbound(False),
    );
    if %*ENV<bgp_debug_prefix>:exists {
        my $prefix = %*ENV<bgp_debug_prefix>;
        if $prefix ne '' {
            $conn.debug = open "{$prefix}.{$conn.id}", :w;
        }
    }

    # Add peer to connection
    $peer.connection = $conn;

    # Set up connection object
    $!controller.connections.add($conn);

    # Send Open
    $peer.state = Net::BGP::Peer::OpenSent;
    $!controller.send-open($conn,
	:hold-time($peer.my-hold-time),
	:supports-capabilities($peer.supports-capabilities),
	:af($peer.my-af),
    );

    # Let user know.
    $!user-supplier.emit(
	Net::BGP::Event::New-Connection.new(
	    :client-ip( $socket.peer-host ),
	    :client-port( $socket.peer-port ),
	    :connection-id( $conn.id ),
	),
    );

    $conn.handle-messages;

    CATCH {
	default {
	    # We should log better
	    $*ERR.say("Error in child process!");
	    $*ERR.say(.message);
	    $*ERR.say(.backtrace.join);
	    .rethrow;
	}
    }
}

method send-keepalives(-->Nil) {
    loop {
        my $p = $.controller.peers.get-peer-due-for-keepalive;
        if ! $p.defined { return; }

        $p.lock.protect: {
            if ! $p.connection.defined { next; }
            $.controller.send-keep-alive($p.connection);
        }
    }
}

method reap-dead-connections(-->Nil) {
    loop {
        my $p = $.controller.peers.get-peer-dead;
        if ! $p.defined { return; }

        $p.lock.protect: {
            if ! $p.connection.defined { next; }
            my $msg = Net::BGP::Message.from-hash(
                %{
                    message-name => 'NOTIFY',
                    error-name   => 'Hold-Timer-Expired',
                },
            );
            $p.connection.send-bgp($msg);
            $p.connection.close;
        }
    }
}

method add-md5(Str:D $host, Str $MD5 -->Nil) {
    %!md5{ $host.fc } = $MD5;
}

