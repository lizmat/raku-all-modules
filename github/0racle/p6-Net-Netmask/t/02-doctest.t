use v6.c;
use Test;

#
# Copyright © 2018 Joelle Maslak
# See License 
#

# These tests test the examples in the POD as closely as possible to
# what is written in the docs.

use Net::Netmask;

subtest "Synopsis" => {
    my $net = Net::Netmask.new('192.168.75.8/29');

    is $net.desc, '192.168.75.8/29', "desc";
    is $net.base, '192.168.75.8', "base";
    is $net.mask, '255.255.255.248', "mask";

    is $net.broadcast, '192.168.75.15', "broadcast";
    is $net.hostmask, '0.0.0.7', "hostmask";

    is $net.bits, 29, "bits";
    is $net.size, 8, "size";

    is $net.match('192.168.75.10'), 2, "match";

    is $net.enumerate, (map { "192.168.75.$^a" }, 8..15), "enumerate";

    # Split subnet into smaller blocks
    is $net.enumerate(:30bit :nets),
        «192.168.75.8/30 192.168.75.12/30»,
        "enumerate small blocks";
}

subtest "Construction" => {
    # CIDR notation (1 positional arg)
    my $net = Net::Netmask.new('192.168.75.8/29');
    is $net, '192.168.75.8/29', "CIDR notation (1 position arg)";

    # Address and netmask (1 positional arg)
    $net = Net::Netmask.new('192.168.75.8 255.255.255.248');
    is $net, '192.168.75.8/29', "Address and netmask (1 positional arg)";

    # Address and netmask (2 positional args)
    $net = Net::Netmask.new('192.168.75.8', '255.255.255.248');
    is $net, '192.168.75.8/29', "Address and netmask (2 positional args)";

    # Named arguments
    $net = Net::Netmask.new( :address('192.168.75.8') :netmask('255.255.255.248') );
    is $net, '192.168.75.8/29', "Named arguments";

    $net = Net::Netmask.new('192.168.75.10/29');
    is $net.desc, "192.168.75.8/29", "inside subnet";
}

subtest "Bits" => {
    is Net::Netmask.new('192.168.0.0', '255.255.255.0').bits, 24, "24 Bits";
    is Net::Netmask.new('192.168.0.0', '255.255.255.252').bits, 30, "30 Bits";
}

subtest "Size" => {
    is Net::Netmask.new('192.168.0.0', '255.255.255.0').size, 256, "256 Addresses";
    is Net::Netmask.new('192.168.0.0', '255.255.255.252').size, 4, "4 Addresses";
}

subtest "Match" => {
    my $net = Net::Netmask.new('192.168.0.0/24');
    is $net.match('192.168.0.0'), 0, "IP as at index";

    my @blacklist = map { Net::Netmask.new($_) },
        < 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 >;

    my $host = '192.168.0.15';
    ok ( any @blacklist».match($host) ), "$host is blacklisted";
}

subtest "Enumerate" => {
    my $net = Net::Netmask.new('192.168.75.8/29');
    is $net.enumerate(:30bit), «192.168.75.8 192.168.75.12», "enumerate :30bit";

    $net = Net::Netmask.new('192.168.75.8/29');
    is $net.enumerate(:30bit :nets).map( *.desc ),
        «192.168.75.8/30 192.168.75.12/30»,
        "enumerate :30bit :nets";

    is $net.enumerate[4], "192.168.75.12", "The address at index 4";
}

subtest "Nth" => {
    my $net = Net::Netmask.new('10.0.0.0/8');

    is $net.nth(10000), "10.0.39.16", "10000th address";

    # Takes several seconds
    is $net.enumerate[10000], "10.0.39.16", "10000th address (enumerate)";

    # Works as expected
    is $net.nth(10000..10010),
        (16..26).map( { "10.0.39.$^a" } ),
        "10000..10010";

    # Too many arguments
    dies-ok { $net.nth(10000..10010, 20000) }, "Too many arguments";

    # Works if in container
    is $net.nth([10000..10010, 20000]),
        [ (16..26).map( { "10.0.39.$^a" } ), "10.0.78.32" ],
        "[10000..10010, 20000]";

    # This also works
    my @n = 10000..10010, 20000;
    is $net.nth(@n),
        [ (16..26).map( { "10.0.39.$^a" } ), "10.0.78.32" ],
        "\@n";

    my $net2 = Net::Netmask.new('192.168.75.8/29');

    # OUTPUT: (192.168.75.11)
    is $net2.nth(3), "192.168.75.11", "nth(3)";

    # FAILURE: Index out of range. Is: 3, should be in 0..1;
    dies-ok { $net2.nth(3, :30bit) }, "Out of range";

    # OUTPUT: ((192.168.75.8 192.168.75.9) (192.168.75.12 192.168.75.13))
    is $net2.nth(^2, :30bit :nets)».nth(^2),
        ( «192.168.75.8 192.168.75.9», «192.168.75.12 192.168.75.13» ),
        "nth(^2).nth(^2)";
}

subtest "Next" => {
    my $net = Net::Netmask.new('192.168.0.0/24');
    my $next = $net.next;
    is $next, "192.168.1.0/24", "next";

    $net++;
    is ~$net, ~$next, "++";
}

subtest "Prev" => {
    my $net = Net::Netmask.new('192.168.1.0/24');
    my $prev = $net.prev;
    is $prev, "192.168.0.0/24", "prev";

    is $net, "192.168.1.0/24", "Net is set right";
    $net--;
    is $net, "192.168.0.0/24", "--";
}

subtest "Int / Str" => {
    my $net = Net::Netmask.new('192.168.1.0/24');
    is $net.Int, 3232235776, "Int";
    is $net.Real, 3232235776, "Real";
    is $net.Str, '192.168.1.0/24', "Str";
}

subtest "sort" => {
    my @nets = Net::Netmask.new('192.168.1.0/24'),
        Net::Netmask.new('192.168.0.0/16'),
        Net::Netmask.new('192.168.0.0/24');

    is @nets.sort(*.sortkey)[0], '192.168.0.0/16', "sortkey";
    is @nets.sort(*.sk)[0], '192.168.0.0/16', "sk";

    is Net::Netmask.sort(@nets)[0], '192.168.0.0/16', "sort";
}

done-testing;

