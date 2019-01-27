use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;

subtest 'Event', {
    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    my $client = IO::Socket::INET.new(:host<127.0.0.1>, :port($bgp.port));
    my $uc = $bgp.user-channel;
    my $cr = $uc.receive;
    is $cr.message-name, 'New-Connection', 'Message type is as expected';
    is normalize-ip($cr.client-ip), '127.0.0.1', 'Client IP is as expected';
    ok $cr.client-port > 0, 'Client port is as expected';

    $client.close();
    
    my $cr-close = $uc.receive;
    is $cr-close.message-name, 'Closed-Connection', 'Close message type is as expected';
    is normalize-ip($cr-close.client-ip), '127.0.0.1', 'Close client IP is as expected';
    is $cr-close.client-port, $cr.client-port, 'Close client port is as expected';

    $bgp.listen-stop();

    done-testing;
};

done-testing;

sub normalize-ip($ip) {
    my $normalized-ip = $ip;
    $normalized-ip ~~ s/^ '::ffff:' //;

    return $normalized-ip;
}

