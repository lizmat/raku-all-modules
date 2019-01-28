#! /usr/bin/env perl6

use v6.c;

use Test;
use IP::Addr;
use IP::Addr::Common;

plan 33;

my $ip = IP::Addr.new( "192.168.13.1" );

is $ip.handler.WHO, "IP::Addr::v4", "handler class";

is ~$ip, "192.168.13.1", "stringification";
is "IP inline: $ip", "IP inline: 192.168.13.1", "IP inlining";

is $ip.inc.ip, "192.168.13.2", "increment on single IP";

$ip = IP::Addr.new( "192.168.13.9/26" );

is $ip.prefix, "192.168.13.9/26", "prefix representation";
is $ip.prefix( :mask ), "192.168.13.9/255.255.255.192", "mask representation";

is $ip.network, "192.168.13.0/26", "network";

is $ip, "192.168.13.9/26", "before increment";

$ip++;

is ~$ip, "192.168.13.10/26", "after increment";

my $ip2 = $ip.first;

is ~$ip2, "192.168.13.0/26", "first for single IP is the IP itself";

$ip2 = $ip2.next;

is ~$ip2, "192.168.13.1/26", "next IP";

$ip2 = $ip2.prev;

is ~$ip2, "192.168.13.0/26", "prev IP";

my @ips;
for $ip.first.each -> $i {
    push @ips, ~$i;
}

my @expect = (0..63).map( { "192.168.13.$_/26" } );

is-deeply @ips, @expect, "iterator";
is-deeply $ip.first.list.map( { ~$_ } ), @expect.List, ".first.list method";

@expect = (10..63).map( { "192.168.13.$_/26" } );
is-deeply $ip.list.map( { ~$_ } ), @expect.List, ".list method";

$ip = IP::Addr.new( "10.11.12.13/28" );
is ~$ip.broadcast, "10.11.12.15", "broadcast address";

$ip2 = $ip.next-host;
is $ip2.ip, "10.11.12.14", "next-host available";
$ip2 = $ip2.next-host;
nok $ip2.defined, "next-host is not available";

$ip = IP::Addr.new( "10.11.12.2/28" );

$ip2 = $ip.prev-host;
is $ip2.ip, "10.11.12.1", "prev-host available";
$ip2 = $ip2.prev-host;
nok $ip2.defined, "prev-host is not available";

my $net = $ip.next-network;
is ~$net, "10.11.12.16/28", "next network";
$net = $ip.prev-network;
is ~$net, "10.11.11.240/28", "prev network";

$ip = IP::Addr.new( "0.0.0.2/24" );
$net = $ip.prev-network;
is ~$net, "255.255.255.0/24", "prev-network cycles over 0";

is $ip.next-range, Nil, "next-range is not applicable to CIDR";

$ip = IP::Addr.new( "10.11.12.13-10.11.12.23" );
$ip2 = IP::Addr.new( :v4, :first( $ip.int-first-ip ), :last( $ip.int-last-ip ), :ip( $ip.int-first-ip + 3 ) );
is $ip2.ip, "10.11.12.16", "ip range with current IP";

my $range = $ip.next-range;
is ~$range, "10.11.12.24-10.11.12.34", "next range";
$range = $ip.prev-range;
is ~$range, "10.11.12.2-10.11.12.12", "previous range";

is $ip.next-network, Nil, "next-network is not applicable to a range";

$ip = IP::Addr.new( :v4, ip => 3221225986, prefix-len => 24 );
is ~$ip, "192.0.2.2/24", "CIDR created from named params";

$ip = IP::Addr.new( :v4, first => 3221225984, last => 3221225994, ip => 3221225986 );
is ~$ip, "192.0.2.0-192.0.2.10", "range created from named params";
is $ip.ip, "192.0.2.2", "range IP is set properly";

$ip = IP::Addr.new( "0.0.0.0" );
$ip--;
is ~$ip, "255.255.255.255", "decrement of 0.0.0.0";

$ip = IP::Addr.new( "0.0.0.0" ) - 2;
is ~$ip, "255.255.255.254", "0.0.0.0 - 2";

.say for IP::Addr.new( "192.0.2.2/29" ).each;
for IP::Addr.new( "192.0.2.2/29" ).first.each { say $_ }

done-testing;
# vim: ft=perl6 et sw=4
