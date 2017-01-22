[![Build Status](https://travis-ci.org/bradclawsie/Net-IP-Parse.png)](https://travis-ci.org/bradclawsie/Net-IP-Parse)

# Net::IP::Parse 

An IP type for Perl6.

## DESCRIPTION

This library tries to fill a gap of a standard type for IP addresses that can
be used in programs and other libraries. Preferrably Perl6 would ship with
a default implementation for this common type, but until then, this is one
attempt at defining such a type.

For our purposes, an IP address is an array of bytes. For IPv4, there
are four bytes. For IPv6, sixteen. Perl6 only provides a byte type
for native interfaces, and this doesn't have adequate degradation in case
of errors, so I have opted to use my own `Subsets::Common` which defines
a `UInt8` subset that integrates nicely for common use.

This library parses common formats for IP address and creates a `UInt8`
array of the right size that is well-formed. That means values that are
bytes (between 0 and 255). This means you may be able to create instances
that are syntactically correct but are not applicable to real use given
some point of IP specification. This library does not concern itself
with determining if you instantiate a reserved or otherwise practically
useless IP address, I leave this to you to determine.

There is also support for a CIDR type which lets you stipulate network
ranges. 

The best set of examples for use can be found in the tests in `basic.t`
in the repository with this library.

IPv6 is complex. Please let me know what I have not properly supported.

## SYNOPSIS

```
use v6;
use Subsets::Common; # required
use Net::IP::Parse;

my IP $ipv4_from_str = IP.new(addr=><1.2.3.4>);
my IP $ipv4_from_octets = IP.new(octets=>Array[UInt8].new(1,2,3,4));
say 'equal' if ($ipv4_from_str ip== $ipv4_from_octets);

my IP $ipv6_from_str = IP.new(addr=>'dfea:dfea:dfea:dfea:dfea:dfea:dfea:dfea');
my IP $ipv6_from_octets = IP.new(octets=>Array[UInt8].new(223,234,223,234,223,234,223,234,223,234,223,234,223,234,223,234));
say 'equal' if ($ipv6_from_str ip== $ipv6_from_octets);

my IP $ip1 = IP.new(addr=><2001:db8:a0b:12f0::1:1>);
say 'equal' if ($ip1.str eq '2001:db8:a0b:12f0:0:0:1:1');
my IP $ip2 = IP.new(addr=><2001:db8:a0b:12f0:0:0:1:1>);
say 'equal' if ($ip ip1== $ip2);

my IP $ip3 = IP.new(addr=><1:0:0:0:1:0:0:1>);
my $compressed = $ip3.compress_str;
say 'equal' if ($compressed eq '1::1:0:0:1');

my CIDR $cidr_ipv4 = CIDR.new(cidr=>'8.8.8.8/16');
my IP $ip4 = IP.new(addr=>'8.8.0.1');
say 'in' if ($ip4 in_cidr $cidr_ipv4);

my CIDR $cidr_ipv6 = CIDR.new(cidr=>'2001:db8::/32');
my IP $ip5 = IP.new(addr=>'2001:0db8:0000:0000:0000:0000:0000:0001');
say 'in' if ($ip5 in_cidr $cidr_ipv6);
```

## AUTHOR 

Brad Clawsie (PAUSE:bradclawsie, email:brad@b7j0c.org) 

## LICENSE 

This module is licensed under the BSD license, see: https://b7j0c.org/stuff/license.txt


