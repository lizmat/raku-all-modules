use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Conversions;
use Net::BGP::Message::Notify::Header::Connection-Not-Syncronized;

subtest 'Syncronization', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1111), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/test-invalid-marker.msg') );
    
    my $cr-bgp = $uc.receive;
    is $cr-bgp.message-name, 'Marker-Format', 'Channel message type is as expected';
    is $cr-bgp.is-error, True, 'Is not an error';

    is $bgp.peer-get(:peer-ip('127.0.0.1')).defined, True, 'Peer is defined';
    is $bgp.peer-get(:peer-ip('127.0.0.1')).state, Net::BGP::Peer::Idle, 'Peer is Idle';
    
    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Closed-Connection', 'Close message type is as expected';
    is $cr-bad.is-error, False, 'Is not an error';
    
    is $bgp.peer-get(:peer-ip('127.0.0.1')).state, Net::BGP::Peer::Idle, 'Peer is idle';

    my $pkt = $client.read(16); # Read (and silently discard) header
    my $raw = $client.read(nuint16($client.read(2))-18); # Read appropriate length
    my $msg = Net::BGP::Message.from-raw($raw, :!asn32);
    ok $msg ~~ Net::BGP::Message::Notify::Header::Connection-Not-Syncronized, "Message is proper type";

    $client.close();
    $bgp.listen-stop();
    done-testing;
};

done-testing;

sub read-message($filename) {
    return slurp $filename, :bin;
}

sub check-list($a, $b -->Bool) {
    if $a.elems != $b.elems { return False; }
    return [&&] $a.values Z== $b.values;
}

