use v6.c;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Message;
use Net::BGP::Parameter;

subtest 'Open Message', {
    my $bgp = Net::BGP::Message.from-raw( read-message('open-message'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 1, 'Message type is correct';
    is $bgp.message-name, 'OPEN', 'Message code is correct';
    is $bgp.version, 4, 'BGP version is correct';
    is $bgp.asn, :16('1020'), 'ASN is correct';
    is $bgp.hold-time, 3, 'Hold time is correct';
    is $bgp.identifier, :16('01020304'), 'BGP identifier is correct';
    is $bgp.ipv4-support, True, 'Supports IPv4';
    is $bgp.ipv6-support, False, 'Supports IPv6';

    my $from-hash = Net::BGP::Message.from-hash(
        {
            message-name => 'OPEN',
            asn          => :16('1020'),
            hold-time    => 3,
            identifier   => :16('01020304'),
            parameters   => (
                {
                    parameter-code  => 240,
                    parameter-value => buf8.new() ,
                },
                {
                    parameter-code  => 241,
                    parameter-value => buf8.new(255)
                },
            ),
        }
    );
    ok defined($from-hash), "FH BGP message is defined";
    is $from-hash.message-code, 1, 'FH Message type is correct';
    is $from-hash.message-name, 'OPEN', 'FH Message code is correct';
    is $from-hash.version, 4, 'BGP version is correct';
    is $from-hash.asn, :16('1020'), 'FH ASN is correct';
    is $from-hash.hold-time, 3, 'FH Hold time is correct';
    is $from-hash.identifier, :16('01020304'), 'FH BGP identifier is correct';

    ok check-list($bgp.raw, read-message('open-message')), 'Message value correct';;

    my $from-hash2 = Net::BGP::Message.from-hash(
        {
            message-name => 'OPEN',
            asn          => :16('1020'),
            hold-time    => 3,
            identifier   => '1.2.3.4',
            parameters   => (
                {
                    parameter-code  => 240,
                    parameter-value => buf8.new() ,
                },
                {
                    parameter-code  => 241,
                    parameter-value => buf8.new(255)
                },
            ),
        }
    );
    ok check-list($from-hash2.raw, read-message('open-message')), 'can create with IP ID';

    my $from-hash3 = Net::BGP::Message.from-hash(
        {
            message-name => '1',
            asn          => :16('1020'),
            hold-time    => 3,
            identifier   => '1.2.3.4',
            parameters   => (
                {
                    parameter-code  => 240,
                    parameter-value => buf8.new() ,
                },
                {
                    parameter-code  => 241,
                    parameter-value => buf8.new(255)
                },
            ),
        }
    );
    ok check-list($from-hash3.raw, read-message('open-message')), 'can create with Int Message Code';

    my $from-hash4 = Net::BGP::Message.from-hash(
        {
            message-code => 1,
            asn          => :16('1020'),
            hold-time    => 3,
            identifier   => '1.2.3.4',
            parameters   => (
                {
                    parameter-code => 240,
                    parameter-value => buf8.new() ,
                },
                {
                    parameter-code => 241,
                    parameter-value => buf8.new(255)
                },
            ),
        }
    );
    ok check-list($from-hash4.raw, read-message('open-message')), 'can create with Message Type';

    my $from-hash5 = Net::BGP::Message.from-hash(
        {
            message-code => 1,
            message-name => '1',
            asn          => :16('1020'),
            hold-time    => 3,
            identifier   => '1.2.3.4',
            parameters   => (
                {
                    parameter-code => 240,
                    parameter-value => buf8.new() ,
                },
                {
                    parameter-code => 241,
                    parameter-value => buf8.new(255)
                },
            ),
        }
    );
    ok check-list($from-hash5.raw, read-message('open-message')), 'can create with Message Typeand int Code';

    my $from-hash6 = Net::BGP::Message.from-hash(
        {
            message-code => 1,
            message-name => 'OPEN',
            asn          => :16('1020'),
            hold-time    => 3,
            identifier   => '1.2.3.4',
            parameters   => (
                {
                    parameter-code => 240,
                    parameter-value => buf8.new() ,
                },
                {
                    parameter-code => 241,
                    parameter-value => buf8.new(255)
                },
            ),
        }
    );
    ok check-list($from-hash6.raw, read-message('open-message')), 'can create with Message Type and Code';

    done-testing;
};

subtest 'Keep-Alive Message', {
    my $bgp = Net::BGP::Message.from-raw( read-message('keep-alive'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 4, 'Message type is correct';
    is $bgp.message-name, 'KEEP-ALIVE', 'Message code is correct';

    my $from-hash = Net::BGP::Message.from-hash(
        {
            message-name => 'KEEP-ALIVE',
        }
    );
    ok defined($from-hash), "FH BGP message is defined";
    is $from-hash.message-code, 4, 'FH Message type is correct';
    is $from-hash.message-name, 'KEEP-ALIVE', 'FH Message code is correct';

    ok check-list($bgp.raw, read-message('keep-alive')), 'Message value correct';;

    done-testing;
};

subtest 'Update-ASN16', {
    my $bgp = Net::BGP::Message.from-raw( read-message('update-asn16'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 2, 'Message type is correct';
    is $bgp.message-name, 'UPDATE', 'Message code is correct';

    my $from-hash = Net::BGP::Message.from-hash(
        {
            message-name => 'UPDATE',
            withdrawn    => [
                '0.0.0.0/0',
                '192.168.150.0/24',
                '192.168.150.1/32',
            ],
            origin           => '?',
            as-path          => '258 772',
            next-hop         => '10.0.0.1',
            med              => 5000,
            local-pref       => 100,
            atomic-aggregate => True,
            aggregator-asn   => 258,
            aggregator-ip    => '192.0.2.6',
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
    is $from-hash.message-code, 2, 'FH Message type is correct';
    is $from-hash.message-name, 'UPDATE', 'FH Message code is correct';

    ok check-list($from-hash.raw, $bgp.raw), 'Message value correct';
    if !check-list($from-hash.raw, $bgp.raw) {
        note "GENERATED: " ~ $from-hash.raw.perl;
        note "EXPECTED : " ~ $bgp.raw.perl;
    }

    done-testing;
};

subtest 'Update-MP', {
    my $bgp = Net::BGP::Message.from-raw( read-message('update-mp'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 2, 'Message type is correct';
    is $bgp.message-name, 'UPDATE', 'Message code is correct';

    my $from-hash = Net::BGP::Message.from-hash(
        {
            message-name   => 'UPDATE',
            withdrawn      => [ ],
            origin         => '?',
            as-path        => '258 772',
            next-hop       => '2001:db8::1',
            nlri           => ( '2001:db8::/32' ),
            withdrawn      => ( '2001:db8::/33' ),
            address-family => 'ipv6',
        },
        :!asn32,
    );
    ok defined($from-hash), "FH BGP message is defined";
    is $from-hash.message-code, 2, 'FH Message type is correct';
    is $from-hash.message-name, 'UPDATE', 'FH Message code is correct';

    ok check-list($from-hash.raw, $bgp.raw), 'Message value correct';
    if !check-list($from-hash.raw, $bgp.raw) {
        note "GENERATED: " ~ $from-hash.raw.perl;
        note "EXPECTED : " ~ $bgp.raw.perl;
    }

    done-testing;
};

done-testing;

sub read-message($filename) {
    buf8.new( slurp("t/bgp-messages/$filename.msg", :bin)[18..*] ); # Strip header
}

sub check-list($a, $b -->Bool) {
    if $a.elems != $b.elems { return False; }
    return [&&] $a.values Z== $b.values;
}

