use v6.c;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Message;
use Net::BGP::Parameter;

subtest "Both AS4 and AS", {
    my $from-hash = Net::BGP::Message.from-hash(
        {
            message-name => 'UPDATE',
            withdrawn    => [
                '0.0.0.0/0',
                '192.168.150.0/24',
                '192.168.150.1/32',
            ],
            origin           => '?',
            as-path          => '258 772 23456 {1,2} 3',
            as4-path         => '100000 {1,2} 3',
            next-hop         => '10.0.0.1',
            med              => 5000,
            local-pref       => 100,
            atomic-aggregate => True,
            originator-id    => '10.0.0.2',
            community        => [ '2571:258' ],
            cluster-list     => '10.0.0.10 10.0.0.11',
            nlri             => [
                '10.0.0.0/8',
                '192.168.151.0/24',
                '192.168.151.1/32',
            ],
        },
        :!asn32,
    );
    ok defined($from-hash), "FH BGP message is defined";
    is $from-hash.as-path, '258 772 100000 {1,2} 3', "AS Path is correct";
    is $from-hash.as-array, (258,772,100000,1,2,3), "AS Path members are correct";

    done-testing;
}

subtest "Only AS-Path on !ASN32", {
    my $from-hash = Net::BGP::Message.from-hash(
        {
            message-name => 'UPDATE',
            withdrawn    => [
                '0.0.0.0/0',
                '192.168.150.0/24',
                '192.168.150.1/32',
            ],
            origin           => '?',
            as-path          => '258 772 100000 {1,2} 3',
            next-hop         => '10.0.0.1',
            med              => 5000,
            local-pref       => 100,
            atomic-aggregate => True,
            originator-id    => '10.0.0.2',
            community        => [ '2571:258' ],
            cluster-list     => '10.0.0.10 10.0.0.11',
            nlri             => [
                '10.0.0.0/8',
                '192.168.151.0/24',
                '192.168.151.1/32',
            ],
        },
        :!asn32,
    );
    ok defined($from-hash), "FH BGP message is defined";
    is $from-hash.as-path, '258 772 100000 {1,2} 3', "AS Path is correct";

    my $as-path = $from-hash.path-attributes.first( * ~~ Net::BGP::Path-Attribute::AS-Path );
    is $as-path.as-path, '258 772 23456 {1,2} 3', "AS-Path attribute correct";

    my $as4-path = $from-hash.path-attributes.first( * ~~ Net::BGP::Path-Attribute::AS4-Path );
    is $as4-path.as4-path, '258 772 100000 {1,2} 3', "AS4-Path attribute correct";

    done-testing;
}

subtest "Only AS-Path on ASN32", {
    my $from-hash = Net::BGP::Message.from-hash(
        {
            message-name => 'UPDATE',
            withdrawn    => [
                '0.0.0.0/0',
                '192.168.150.0/24',
                '192.168.150.1/32',
            ],
            origin           => '?',
            as-path          => '258 772 100000 {1,2} 3',
            next-hop         => '10.0.0.1',
            med              => 5000,
            local-pref       => 100,
            atomic-aggregate => True,
            originator-id    => '10.0.0.2',
            community        => [ '2571:258' ],
            cluster-list     => '10.0.0.10 10.0.0.11',
            nlri             => [
                '10.0.0.0/8',
                '192.168.151.0/24',
                '192.168.151.1/32',
            ],
        },
        :asn32,
    );
    ok defined($from-hash), "FH BGP message is defined";
    is $from-hash.as-path, '258 772 100000 {1,2} 3', "AS Path is correct";

    my $as-path = $from-hash.path-attributes.first( * ~~ Net::BGP::Path-Attribute::AS-Path );
    is $as-path.as-path, '258 772 100000 {1,2} 3', "AS-Path attribute correct";

    my $as4-path = $from-hash.path-attributes.first( * ~~ Net::BGP::Path-Attribute::AS4-Path );
    is $as4-path.defined, False, "AS4-Path attribute correct";

    done-testing;
}

done-testing;
