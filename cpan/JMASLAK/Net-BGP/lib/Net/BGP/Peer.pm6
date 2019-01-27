use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use OO::Monitors;

unit monitor Net::BGP::Peer:ver<0.0.0>:auth<cpan:JMASLAK>;

use Net::BGP::AFI-SAFI;
use Net::BGP::Connection;
use Net::BGP::IP;

has Lock:D $.lock is rw = Lock.new;

# We need to track state of the connection.
enum PeerState is export «Idle Connect Active OpenSent OpenConfirm Established»;
has PeerState $.state is rw = Idle;

# Their side
has Str:D  $.peer-ip is required where { ip-valid($^a) };
has Int:D  $.peer-port where ^65536 = 179;
has Int:D  $.peer-asn is required where ^(2³²);
has Int    $.peer-identifier is rw where ^(2³²);
has Int    $.peer-hold-time where { $^h == 0 or $^h ~~ 3..65535 };
has Int    $.last-connect-attempt is rw;
has UInt:D $.connect-retry-time is rw = 60;
has Bool:D $.passive = False;
has Bool   $.supports-capabilities is rw;
has Bool:D $.peer-supports-asn32 is rw = False;
has Int:D  $.last-message-received is rw = 0;

# My side
has Int:D  $.my-asn is required where ^(2³²);
has Int:D  $.my-hold-time where { $^h == 0 or $^h ~~ 3..65535 } = 60;
has Int:D  $.last-message-sent is rw = 0;
has Bool:D $.local-supports-asn32 is rw = True;

# Address Families
has Net::BGP::AFI-SAFI:D @.peer-af;
has Net::BGP::AFI-SAFI:D @.my-af   = @( Net::BGP::AFI-SAFI.from-str('IP', 'unicast') );

# Channel from server component
has Channel $.channel is rw;

# Current "up" connection - in OpenConfirm or Established
has Net::BGP::Connection $.connection is rw;

method supports-afi-safi($afi, $safi -->Bool:D) {
    my $af = Net::BGP::AFI-SAFI.from-str($afi, $safi);
    return @.peer-af.first( { $^a == $af } ).so;
}

method set-channel($channel) {
    if $.channel.defined { die("A channel is already defined for peer") }
    $!channel = $channel;
}

method do-asn32(-->Bool:D) {
    return $.peer-supports-asn32 && $.local-supports-asn32;
}

method is-ibgp(-->Bool:D) {
    return $.my-asn == $.peer-asn;
}

method remove-peer() {
    # We currently don't do anything
    # XXX We should close the channel and any other cleanup.
    # XXX We should also add this in the destructor.
}

=begin pod

=head1 NAME

Net::BGP::Peer - BGP Server Peer Class

=head1 SYNOPSIS

  use Net::BGP::Peer;

  my $peer = Net::BGP::Peer.new(:peer-ip('192.0.2.1'), :peer-asn(65001));
  $peer.set-channel($channel);
  $peer.remove-peer;

=head1 DESCRIPTION

This keeps track of a peer's state and configuration.

=head1 ATTRIBUTES

=head2 state

The current state of the connection.

=head2 passive

If true, this peer is "passive" - meaning that we will not initiate an outbound
connection to this peer.

=head2 peer-ip

The IP address for the peer (String).

=head2 peer-port

The port of the peer (passive side).

=head2 peer-asn

The ASN belonging to the peer.

=head2 peer-af

The AFI/SAFI combinations supported by the peer.

=head2 peer-supports-asn32

True if the peer sent an ASN32 capability.

=head supports-capabilities

True if the peer has sent a capability in the open message to us.

=head last-message-received

The monotonic time stamp of the last message received.

=head2 my-asn

The ASN belonging to the server process.

=head2 my-af

The AFI/SAFI combinations supported by us.

=head2 supports-capabilities

Set to C<True> if a connection has been established where the peer sent a
capability parameter.  Set to C<False> if the peer didn't send a capability
parameter in the last OPEN they sent.  Not defined if the peer has not yet
connected.

=head1 METHODS

=head1 set-channel

  $peer.set-channel($channel);

Sets the channel that is connected to the BGP server component.

=head1 remove-peer

  $peer.remove-peer

Does an ungraceful shutdown of the peer (if open).

=head1 supports-afi-safi($afi, $safi)

Returns true if the peer has indicated support for this AFI/SAFI address
family specification.

=head do-asn32

Returns C<True> if we have negotiated 4 byte (32 bit) ASNs with the peer.
Otherwise returns C<False>.

=head is-ibgp

Return C<True> if this peer is an iBGP peer, C<False> otherwise.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
