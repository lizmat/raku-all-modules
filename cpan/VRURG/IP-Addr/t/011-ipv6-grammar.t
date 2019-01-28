#! /usr/bin/env perl6

use Grammar::Tracer;

use v6.c;

use Test;

use IP::Addr::v6;

plan 30;

ok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:0370:7334' ), "plain expanded";
nok is-ipv6( '2001a:0db8:85a3:0000:0000:8a2e:0370:7334' ), "plain: too long hextet";
nok is-ipv6( '200g:0db8:85a3:0000:0000:8a2e:0370:7334' ), "plain: invalid char in hextet";
nok is-ipv6( '0db8:85a3:0000:0000:8a2e:0370:7334' ), "plain: too few hextets";
nok is-ipv6( '1:2001:0db8:85a3:0000:0000:8a2e:0370:7334' ), "plain: too many hextets";

ok is-ipv6( '2001:db8:85a3::8a2e:370:7334' ), "plain compressed";
ok is-ipv6( '::8a2e:370:7334' ), "plain compressed - starts with zeroes";
ok is-ipv6( '2001:db8:85a3::' ), "plain compressed - ends with zeroes";
ok is-ipv6( '::' ), "compressed - all zeroes";
nok is-ipv6( '2001:0db8:85a3::0000:0000:8a2e:0370:7334' ), "expanded: too many hextets";

ok is-ipv6( '0000:0000:0000:0000:0000:ffff:192.168.13.1' ), "IPv4 mapped";
ok is-ipv6( '::ffff:192.168.13.1' ), "IPv4 mapped - compressed";
ok is-ipv6( '::ffff:0:192.168.13.1' ), "IPv4 translated - compressed";
ok is-ipv6( '64:ff9b::192.168.13.1' ), "IPv4/IPv6 translation - compressed";
nok is-ipv6( 'a:2001:0db8:85a3:0000:0000:8a2e:192.168.13.1' ), "IPv4 mix in: too many hextets";
nok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:192.168.13' ), "IPv4 mix in: incomplete IPv4";
nok is-ipv6( '2001:0db8:85a3::8a2e:192.168.1' ), "IPv4 mix in - compressed: incomplete IPv4";

ok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:0370:7334/48' ), "CIDR expanded";
ok is-ipv6( '2001:db8:85a3::8a2e:370:7334/49' ), "CIDR compressed";
nok is-ipv6( '2001:db8:85a3::8a2e:370:7334/a0' ), "CIDR: prefix length isn't all digits";

ok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:0370:7334-2001:0db8:85a3:0000:0000:8a2e:0370:7334' ), "range";
ok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:0370:7334 - 2001:0db8:85a3:0000:0000:8a2e:0370:7334' ), "range with spaces";

ok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:0370:7334%eth0' ), "interface-scoped expanded";
ok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:0370:7334%2' ), "number-scoped expanded";
ok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:0370:7334%vmx-net' ), "dashed-interface scoped, expanded";
nok is-ipv6( '2001:0db8:85a3:0000:0000:8a2e:0370:7334%vmx net' ), "spaced scope, expanded";
ok is-ipv6( '2001:db8:85a3::8a2e:370:7334%eth0' ), "interface-scoped compressed";
ok is-ipv6( '2001:db8:85a3::8a2e:370:7334%13' ), "number-scoped compressed";
ok is-ipv6( '2001:db8:85a3::8a2e:370:7334%no-eth' ), "dashed-interface scoped, compressed";
nok is-ipv6( '2001:db8:85a3::8a2e:370:7334%no eth' ), "spaced-interface scoped, compressed";

done-testing;
# vim: ft=perl6 et sw=4
