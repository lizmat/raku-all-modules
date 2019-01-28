#! /usr/bin/env perl6

use v6.c;

use Test;
use IP::Addr;

plan 19;

my $ip = IP::Addr.new( "2001::da:beef" );

is $ip.handler.WHO, "IP::Addr::v6", "handler class";

is ~$ip, "2001::da:beef", "stringification";
is "IP inline: $ip", "IP inline: 2001::da:beef", "string inlining";

$ip = IP::Addr.new( "2002::da:beef/33" );

is $ip.network, "2002::/33", "network";

is $ip, "2002::da:beef/33", "before increment";

$ip++;

is ~$ip, "2002::da:bef0/33", "after increment";

my $ip2 = $ip.first;

is ~$ip2, "2002::/33", "first";

$ip2 = $ip2.next;

is ~$ip2, "2002::1/33", "next IP";

$ip2 = $ip2.prev;

is ~$ip2, "2002::/33", "prev IP";

# Narrow the CIDR or test would take forever to complete
$ip = IP::Addr.new( "2003::da:beef/122" );
my @ips;
for $ip.first.each -> $i {
    push @ips, ~$i;
}

my @expect = (0xc0..0xff).map( { "2003::da:be{$_.fmt("%x")}/122" } );

is-deeply @ips, @expect, "iterator";

$ip = IP::Addr.new( "2002::da:bef0-2002::da:beff" );
$ip2 = IP::Addr.new( :v6, :first( $ip.int-first-ip ), :last( $ip.int-last-ip ), :ip( $ip.int-first-ip + 3 ), :abbreviated, :compact );
ok $ip2.abbreviated, ":abbreviated attribute passed over to handler";
is $ip2.ip, "2002::da:bef3", "IPv6 range with current IP";

$ip = IP::Addr.new( "::" );
$ip--;
is $ip, "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "decrement of ::";

$ip = IP::Addr.new( "::" ) - 2;
is $ip, "ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe", ":: - 2";

$ip = IP::Addr.new( "2001:0000:0000:0000:0000:0000:0000:0001", :abbreviated, :compact );
is ~$ip, "2001::1", "formatting as abbreviated + compact";
$ip = IP::Addr.new( "2001:0000:0000:0000:0000:0000:0000:0001", :abbreviated, :!compact );
is ~$ip, "2001:0:0:0:0:0:0:1", "formatting as abbreviated + expaned";
$ip = IP::Addr.new( "2001::1", :!abbreviated, :!compact );
is ~$ip, "2001:0000:0000:0000:0000:0000:0000:0001", "formatting as non-abbreviated + expaned";
$ip = IP::Addr.new( "2001::1" );
is ~$ip, "2001::1", "formatting preserved: abbreviated + compact";
$ip = IP::Addr.new( "2001:0:0:0:0:0:0:1" );
is ~$ip, "2001:0:0:0:0:0:0:1", "formatting preserved: abbreviated + expaned";

done-testing;
# vim: ft=perl6 et sw=4
