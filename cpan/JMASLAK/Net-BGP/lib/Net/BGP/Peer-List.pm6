use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::IP;
use Net::BGP::Peer;
use Net::BGP::Time;
use OO::Monitors;

unit monitor Net::BGP::Peer-List:ver<0.0.0>:auth<cpan:JMASLAK>;

has Net::BGP::Peer:D %!peers;
has Int:D $.my-asn is required where ^(2³²);

method get(Str:D $peer-ip) {
    my $key = self.peer-key($peer-ip);
    if %!peers{$key}:exists {
        return %!peers{$key};
    } else {
        return;
    }
}

method add(
    Int:D  :$peer-asn,
    Str:D  :$peer-ip,
    Int:D  :$peer-port? = 179,
    Bool:D :$passive?   = False,
    Bool:D :$ipv4?      = True,
    Bool:D :$ipv6?      = False,
) {
    my $key = self.peer-key($peer-ip);

    if %!peers{$key}:exists {
        die("Peer was already defined - IP: $peer-ip");
    }

    my @af;
    if ! ($ipv4 or $ipv6) { die("Must specify one address family"); }

    @af.push( Net::BGP::AFI-SAFI.from-str('IP',   'unicast') ) if $ipv4;
    @af.push( Net::BGP::AFI-SAFI.from-str('IPv6', 'unicast') ) if $ipv6;

    %!peers{$key} = Net::BGP::Peer.new(
        :$peer-ip,
        :$peer-port,
        :$peer-asn,
        :$!my-asn,
        :$passive,
        :my-af(@af),
    );
}

method remove(Str:D $peer-ip) {
    my $key = self.peer-key($peer-ip);
    
    if %!peers{$key}:exists {
        %!peers{$key}.destroy-peer();
        %!peers{$key}:delete;
    }
}

method peer-key(Str:D $peer-ip) {
    return ip-cannonical($peer-ip);
}

method get-peer-due-for-connect(-->Net::BGP::Peer) {
    my $now = monotonic-whole-seconds;
    for %!peers.values -> $peer {
        $peer.lock.protect: {
            if $peer.passive              { next; }
            if $peer.connection.defined   { next; }
            if $peer.state == OpenSent    { next; }
            if $peer.state == OpenConfirm { next; }
            if $peer.state == Established { next; }

            # Never connected?
            if ! $peer.last-connect-attempt.defined { return $peer; }

            # Connected in the past by at least retry time?
            if $now ≥ ($peer.last-connect-attempt + $peer.connect-retry-time) {
                return $peer;
            }
        }
    }
    return;
}

method get-peer-due-for-keepalive(-->Net::BGP::Peer) {
    my $now = monotonic-whole-seconds;
    for %!peers.values -> $peer {
        $peer.lock.protect: {
            if ! $peer.connection.defined                { next; }
            if $peer.state ≠ Net::BGP::Peer::Established { next; }

            # Get time
            my $hold-time = min($peer.peer-hold-time, $peer.my-hold-time);
            if $hold-time == 0 { next; }

            # Never sent?
            if ! $peer.last-message-sent.defined { return $peer; }

            # Send time
            my $send-time = ($hold-time / 3).truncate;

            # Connected in the past by at least retry time?
            if $now ≥ ($peer.last-message-sent + $send-time) {
                return $peer;
            }
        }
    }
    return;
}

method get-peer-dead(-->Net::BGP::Peer) {
    my $now = monotonic-whole-seconds;
    for %!peers.values -> $peer {
        $peer.lock.protect: {
            if ! $peer.connection.defined                { next; }
            if $peer.state ≠ Net::BGP::Peer::Established { next; }

            # Get time
            my $hold-time = min(($peer.peer-hold-time // 65535), $peer.my-hold-time);
            if $hold-time == 0 { next; }

            # Never received?
            if ! $peer.last-message-received.defined { return $peer; }

            # Send time
            my $send-time = $hold-time;

            # Connected in the past by at least retry time?
            if $now ≥ (($peer.last-message-received // 0) + $send-time) {
                return $peer;
            }
        }
    }
    return;
}

