use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;

subtest 'Basic Class Construction', {
    my $bgp = Net::BGP.new(:my-asn(65000), :identifier(1000));
    ok $bgp, "Created BGP Class";
    is $bgp.port, 179, 'Port has proper default';

    $bgp = Net::BGP.new( port => 1179, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 1179, 'Port is properly set to 1179';

    $bgp = Net::BGP.new( port => Nil, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 179, 'Port is properly set to 179 by Nil';

    dies-ok { $bgp.port = 17991; }, 'Cannot change port';

    dies-ok { $bgp = Net::BGP.new( port =>    -1, my-asn => 65000, identifier => 1000 ); }, '< 0 port rejected';
    dies-ok { $bgp = Net::BGP.new( port => 65536, my-asn => 65000, identifier => 1000 ); }, '>65535 port rejected';
    dies-ok { $bgp = Net::BGP.new( port => 65536, my-asn => 65000, identifier => 65536 ); }, '>65535 identifier rejected';

    dies-ok { $bgp = Net::BGP.new( foo => 1, my-asn => 65000, identifier => 1000 ); }, 'Non-existent attribute causes failure';

    dies-ok { $bgp = Net::BGP.new(); }, 'Must provide my-asn';
    dies-ok { $bgp = Net::BGP.new(:my-asn(-1)); }, 'Invalid ASN dies';

    done-testing;
};

subtest 'Listener', {

    my $bgp = Net::BGP.new( port => 0, my-asn => 65000, identifier => 1000 );
    is $bgp.port, 0, 'BGP Port is 0';

    $bgp.listen();
    isnt $bgp.port, 0, 'BGP Port isnt 0';

    $bgp.listen-stop();

    done-testing;
};

done-testing;

