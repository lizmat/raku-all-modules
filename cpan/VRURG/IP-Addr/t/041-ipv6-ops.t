#! /usr/bin/env perl6

use v6.c;

use Test;

use IP::Addr;

plan 2;

subtest "CIDR" => {
    plan 22;

    my $ip = IP::Addr.new( "600d::f00d/112" );

    is ++$ip, "600d::f00e/112", "increment";
    is --$ip, "600d::f00d/112", "decrement";
    is $ip++, "600d::f00e/112", "post-increment";
    is $ip--, "600d::f00d/112", "post-decrement";

    my $ip2 = $ip + 0x10;
    is $ip2, "600d::f01d/112", "addition";
    nok $ip.WHICH === $ip2.WHICH, "addition generates a new object";

    $ip2 = $ip - 0x10;
    is $ip2, "600d::effd/112", "subtraction";
    nok $ip.WHICH === $ip2.WHICH, "subtraction generates a new object";

    $ip2 = $ip - ( $ip.int-mask - 10 );
    is $ip2, "600d::/112", "subtraction: out of range produces network address";

    ok $ip2 == $ip.network, "netowrk == network";
    nok $ip2 == $ip, "network != original IP";
    ok $ip ⊆ $ip2, "orig belongs to its network";
    ok $ip ⊆ "600d::/110", "orig belongs to network defined with Str";
    nok $ip ⊆ "600e::/112", "doesn't belong to a network";
    ok $ip2 < $ip, "network is < than orig";
    ok $ip2 <= $ip2, "network is <= than itself"; 
    ok $ip2 ≤ "600d::f00d/112", "network is <= then itself in Str form"; 
    is $ip cmp "600f::", Less, "cmp higher";
    is $ip cmp "600d::f00d", Same, "cmp with same";
    is $ip cmp "600a::", More, "cmp with lower";
    nok $ip eqv "600d::f00d", "CIDR isn't eqv to plain IP";
    ok $ip eqv "600d::f00d/112", "eqv to same CIDR";
}

subtest "Range" => {
    plan 13;

    my $range = IP::Addr.new( "600d::f00d-600d::f01d" );

    ok $range eqv "600d::f00d-600d::f01d", "eqv to same range";
    nok $range eqv "600d::f00d-600d::f01e", "not eqv to different range";
    ok $range ⊆ "600d::f000-600d::f01e", "contained in a wider range";
    nok $range ⊆ "600d::f00e-600d::f01d", "not contained in narrower range";
    ok "600d::f000-600d::f01e" (cont) $range, "contained in wider range (with (cont) op)";
    nok $range (cont) "600d::f000-600d::f01e", "wider range isn't contained (with (cont) op)";
    ok $range.overlaps( "600d::f00e-600d::f01e" ), "overlaps higher range";
    ok $range.overlaps( "600d::f00c-600d::f01c" ), "overlaps with lower range";
    ok $range.overlaps( "600d::f00f-600d::f010" ), "overlaps with contained range";
    ok $range.overlaps( "600d::f00c-600d::f01e" ), "overlaps with containing range";
    nok $range.overlaps( "600d::f000-600d::f00c" ), "doesn't overlap";
    ok $range ⊇ "600d::f00f", "IP is in range";
    nok $range ⊇ "600d::f00c", "IP isn't in range";
}

done-testing;

# vim: ft=perl6 et sw=4
