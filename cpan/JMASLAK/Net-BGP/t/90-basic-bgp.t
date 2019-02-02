use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Conversions;

subtest 'invalid-marker', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1020), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/test-invalid-marker.msg') );
    $client.close();

    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Marker-Format', 'Error message type is as expected';
    is $cr-bad.is-error, True, 'Is an error';
    
    $bgp.listen-stop();

    done-testing;
};

subtest 'invalid-length-short', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1020), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/test-invalid-length-short.msg') );
    $client.close();

    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Length-Too-Short', 'Error message type is as expected';
    is $cr-bad.is-error, True, 'Is an error';
    
    $bgp.listen-stop();

    done-testing;
};

subtest 'invalid-length-long', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1020), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/test-invalid-length-long.msg') );
    $client.close();

    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Length-Too-Long', 'Error message type is as expected';
    is $cr-bad.is-error, True, 'Is an error';
    
    $bgp.listen-stop();

    done-testing;
};

subtest 'invalid-version', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1020), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/test-invalid-version.msg') );

    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Unknown-Version', 'Error message type is as expected';
    is $cr-bad.is-error, True, 'Is an error';
    
    my $pkt = $client.read(16); # Read (and silently discard) header
    my $raw = $client.read(nuint16($client.read(2))-18); # Read appropriate length
    my $msg = Net::BGP::Message.from-raw($raw, :!asn32);
    ok $msg ~~ Net::BGP::Message::Notify::Open::Unsupported-Version, "Message is proper type";
    is $msg.max-supported-version, 4, "Max supported version is valid";

    $client.close();

    $bgp.listen-stop();

    done-testing;
};

subtest 'hold-time-too-short', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1020), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/test-invalid-hold-time.msg') );
    $client.close();

    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Hold-Time-Too-Short', 'Error message type is as expected';
    is $cr-bad.is-error, True, 'Is an error';
    
    $bgp.listen-stop();

    done-testing;
};

subtest 'bad-option-length [1]', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1020), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/test-invalid-option-len-in-open-1.msg') );
    $client.close();

    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Bad-Option-Length', 'Error message type is as expected';
    is $cr-bad.is-error, True, 'Is an error';
    is $cr-bad.length, 1, 'Length == 1';
    
    $bgp.listen-stop();

    done-testing;
};

subtest 'bad-option-length [3]', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1020), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/test-invalid-option-len-in-open-3.msg') );
    $client.close();

    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Bad-Option-Length', 'Error message type is as expected';
    is $cr-bad.is-error, True, 'Is an error';
    is $cr-bad.length, 3, 'Length == 3';
    
    $bgp.listen-stop();

    done-testing;
};

subtest 'OPEN', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    $bgp.peer-add( :peer-asn(0x1020), :peer-ip('127.0.0.1'), :passive );
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    is $bgp.my-asn, 65000, "ASN is correct";

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';

    $client.write( read-message('t/bgp-messages/open-message-no-opt.msg') );
    
    my $cr-bgp = $uc.receive;
    is $cr-bgp.message-name, 'BGP-Message', 'BGP message type is as expected';
    is $cr-bgp.is-error, False, 'Is not an error';
    is $cr-bgp.message.message-name, 'OPEN', 'BGP Message is proper name';
    is $cr-bgp.message.message-code, 1, 'BGP Message is proper type';
    is $cr-bgp.message.option-len, 0, 'Option length is zero';
    is $cr-bgp.message.option-len, $cr-bgp.message.option.bytes, 'Option bytes = len';
    is $cr-bgp.peer-asn, 0x1020, "Peer ASN is proper";

    $bgp.peer-get(:peer-ip('127.0.0.1')).lock.protect: {
        my $peer = $bgp.peer-get(:peer-ip<127.0.0.1>);
        is $peer.defined, True, 'Peer is defined';
        is $peer.state, Net::BGP::Peer::OpenConfirm, 'Peer is OpenConfirm';
        is $peer.connection.asn32, False, 'Connection does not support ASN32';
        is $peer.peer-af.elems, 1, "One AF present";
        is $peer.peer-af[0].afi-code, 1, "AFI correct";
        is $peer.peer-af[0].safi-code, 1, "SAFI correct";
    }
    
    my $pkt = $client.read(16); # Read (and silently discard) header
    my $raw = $client.read(nuint16($client.read(2))-18); # Read appropriate length

    my $msg = Net::BGP::Message.from-raw($raw, :!asn32);
    ok $msg ~~ Net::BGP::Message::Open, "Message is proper type";
    is $msg.version, 4, "Version correct";
    is $msg.asn, 65000, "ASN is correct";
    is $msg.hold-time, 60, "Hold-Time is correct";
    is $msg.identifier, 1000, "Identifier is correct";
    is $msg.option-len, 0, "Option length is correct";
    is $msg.parameters.elems, 0, "No parameters provided";

    $client.close();

    my $cr-bad = $uc.receive;
    is $cr-bad.message-name, 'Closed-Connection', 'Close message type is as expected';
    is $cr-bad.is-error, False, 'Is not an error';
    
    is $bgp.peer-get(:peer-ip('127.0.0.1')).state, Net::BGP::Peer::Idle, 'Peer is idle';

    $bgp.listen-stop();

    done-testing;
}

done-testing;

sub read-message($filename) {
    return slurp $filename, :bin;
}

