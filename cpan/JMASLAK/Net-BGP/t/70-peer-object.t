use v6.c;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Peer;

subtest 'eBGP' => {
    my $peer = Net::BGP::Peer.new(
        :peer-ip('192.0.2.1'),
        :peer-asn(65001),
        :my-asn(65000),
    );
    ok $peer, "Created BGP Class";

    is $peer.peer-ip, '192.0.2.1', "Peer IP is correct";
    is $peer.peer-port, 179, "Peer port is okay";
    is $peer.peer-asn, 65001, "Peer ASN is okay";
    is $peer.my-asn, 65000, "My ASN is okay";
    is $peer.state, PeerState::Idle, "Peer state is okay";
    is $peer.do-asn32, False, 'ASN 32 support not indicated';
    is $peer.is-ibgp, False, 'Not iBGP';

    done-testing;
}

subtest 'iBGP' => {
    my $peer = Net::BGP::Peer.new(
        :peer-ip('192.0.2.1'),
        :peer-asn(65000),
        :my-asn(65000),
        :peer-supports-asn32,
    );
    ok $peer, "Created BGP Class";

    is $peer.peer-ip, '192.0.2.1', "Peer IP is correct";
    is $peer.peer-port, 179, "Peer port is okay";
    is $peer.peer-asn, 65000, "Peer ASN is okay";
    is $peer.my-asn, 65000, "My ASN is okay";
    is $peer.state, PeerState::Idle, "Peer state is okay";
    is $peer.do-asn32, True, 'ASN 32 supported';
    is $peer.is-ibgp, True, 'iBGP';

    done-testing;
}

done-testing;

