use v6.c;
use Test;

#
# Copyright (C) 2018 Joelle Maslak
# All Rights Reserved - See License
#

subtest 'named_exclude', {
    use IP::Random;

    # Specify values in sorted order
    my constant TESTS = (
        { ip => '4.0.0.0/24',         values => <NONE> },
        { ip => '255.255.255.255/32', values => <default rfc919>  },
        { ip => '10.0.0.0/8',         values => <default rfc1918> },
        { ip => '192.168.0.0/16',     values => <default rfc1918> },
    );

    for TESTS -> %test {
        my %vals = IP::Random::named_exclude.grep( { $_.key eq %test<ip> } );

        my @got = <NONE>;
        if (%vals) { @got = %vals.values; }

        is @got, %test<values>, "%test<ip>";
    }

    done-testing;
};

subtest 'exclude_ipv4_list', {
    use IP::Random;

    my constant TESTS = (
        { type => 'default', ip => '4.0.0.0/24',         exists => 0 },
        { type => 'default', ip => '255.255.255.255/32', exists => 1 },
        { type => 'default', ip => '10.0.0.0/8',         exists => 1 },
        { type => 'default', ip => '192.168.0.0/16',     exists => 1 },

        { type => 'rfc1918', ip => '4.0.0.0/24',         exists => 0 },
        { type => 'rfc1918', ip => '255.255.255.255/32', exists => 0 },
        { type => 'rfc1918', ip => '10.0.0.0/8',         exists => 1 },
        { type => 'rfc1918', ip => '192.168.0.0/16',     exists => 1 },
    );

    for TESTS -> %test {
        my $got = IP::Random::exclude_ipv4_list(%test<type>).grep(%test<ip>).elems;
        is $got, %test<exists>, "%test<type> %test<ip>";
    }

    done-testing;
};

subtest 'default_ipv4_exclude', {
    use IP::Random;

    my @from_exclude = IP::Random::exclude_ipv4_list('default').sort;
    my @from_default = IP::Random::default_ipv4_exclude().sort;

    is @from_exclude, @from_default, 'Excluded matches Default';
}

done-testing;

