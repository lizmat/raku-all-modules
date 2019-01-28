#! /usr/bin/env perl6

use v6.c;

use Test;

use IP::Addr::v4;

plan 14;

ok is-ipv4( '127.0.0.1' ), "simple IP";
ok is-ipv4( '192.168.1.10 - 192.168.1.100' ), "IP range";
ok is-ipv4( '192.168.1.13/24' ), "CIDR with bits";
ok is-ipv4( '192.168.1.13/0' ), "CIDR with bits == 0";
ok is-ipv4( '192.168.1.13/255.255.240.0' ), "CIDR with dotted subnet";
ok is-ipv4( '192.168.1.13/0.0.0.0' ), "CIDR with all 0 subnet";
ok is-ipv4( '192.168.1.13/255.255.255.255' ), "CIDR with all 1 subnet";

nok is-ipv4( '127.256.0.1' ), "invalid simple IP";
nok is-ipv4( '127.0.0.10 - 127.256.0.1' ), "invalid octet in IP in a range";
nok is-ipv4( '127.0.0.10 - 127.0.0' ), "invalid IP in a range";
nok is-ipv4( '192.168.1.1/33' ), "invalid bits in CIDR";
nok is-ipv4( '192.168.1.1/255.255.' ), "invalid dotted subnet in CIDR";
nok is-ipv4( '192.168.1.1/255.256.0.0' ), "too big octet in dotted subnet in CIDR";
nok is-ipv4( '192.168.1.1/255.253.0.0' ), "invalid octet in dotted subnet in CIDR";

done-testing
# vim: ft=perl6 et sw=4
