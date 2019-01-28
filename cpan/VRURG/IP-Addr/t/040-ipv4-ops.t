#! /usr/bin/env perl6

use v6.c;

use Test;

use IP::Addr;

plan 2;

subtest "CIDR" => {
    plan 23;

    my $ip = IP::Addr.new( "10.11.12.13/24" );

    is ++$ip, "10.11.12.14/24", "increment";
    is --$ip, "10.11.12.13/24", "decrement";
    is $ip++, "10.11.12.14/24", "post-increment";
    is $ip--, "10.11.12.13/24", "post-decrement";

    my $ip2 = $ip + 10;
    is $ip2, "10.11.12.23/24", "addition";
    nok $ip.WHICH === $ip2.WHICH, "addition generates a new object";
    $ip2 += 2;
    is $ip2, "10.11.12.25/24", "+=";

    $ip2 = $ip - 10;
    is $ip2, "10.11.12.3/24", "subtraction";
    nok $ip.WHICH === $ip2.WHICH, "subtraction generates a new object";

    $ip2 = $ip - 20;
    is $ip2, "10.11.12.0/24", "subtraction: out of range produces network address";

    ok $ip2 == $ip.network, "netowrk == network";
    nok $ip2 == $ip, "network != original IP";
    ok $ip ⊆ $ip2, "orig belongs to its network";
    ok $ip ⊆ "10.11.12.0/24", "orig belongs to network defined with Str";
    nok $ip ⊆ "10.11.13.0/24", "doesn't belong to a network";
    ok $ip2 < $ip, "network is < than orig";
    ok $ip2 <= $ip2, "network is <= than itself"; 
    ok $ip2 ≤ "10.11.12.0/24", "network is <= then itself in Str form"; 
    is $ip cmp "10.11.12.20", Less, "cmp higher";
    is $ip cmp "10.11.12.13", Same, "cmp with same";
    is $ip cmp "10.11.12.1", More, "cmp with lower";
    nok $ip eqv "10.11.12.13", "CIDR isn't eqv to plain IP";
    ok $ip eqv "10.11.12.13/24", "eqv to same CIDR";
}

subtest "Range" => {
    plan 13;

    my $range = IP::Addr.new( "172.1.0.10-172.1.1.9" );

    ok $range eqv "172.1.0.10-172.1.1.9", "eqv to same range";
    nok $range eqv "172.1.0.10-172.1.1.10", "not eqv to different range";
    ok $range ⊆ "172.1.0.10-172.1.1.10", "contained in a wider range";
    nok $range ⊆ "172.1.0.11-172.1.1.10", "not contained in narrower range";
    ok "172.1.0.10-172.1.1.10" (cont) $range, "contained in wider range (with (cont) op)";
    nok $range (cont) "172.1.0.10-172.1.1.10", "wider range isn't contained (with (cont) op)";
    ok $range.overlaps( "172.1.0.11-172.1.1.10" ), "overlaps higher range";
    ok $range.overlaps( "172.1.0.1-172.1.1.16" ), "overlaps with lower range";
    ok $range.overlaps( "172.1.0.100-172.1.0.200" ), "overlaps with contained range";
    ok $range.overlaps( "172.1.0.9-172.1.1.100" ), "overlaps with containing range";
    nok $range.overlaps( "172.1.1.10-172.1.1.19" ), "doesn't overlap";
    ok $range ⊇ "172.1.1.1", "IP is in range";
    nok $range ⊇ "172.1.1.100", "IP isn't in range";
}

done-testing;
# vim: ft=perl6 et sw=4
