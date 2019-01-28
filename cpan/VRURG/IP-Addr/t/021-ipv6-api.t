#! /usr/bin/env perl6

use v6.c;

use Test;

use IP::Addr;
use IP::Addr::Common;

subtest "Base methods" => {
    my @tests = 
        {
            name => "Single IP, default",
            src => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
            methods => {
                ip => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
                prefix => "2001:0db8:85a3:0000:0000:8a2e:0370:7334/128",
                Str => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
                gist => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
                first-ip => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
                last-ip => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
            }
        },
        {
            name => "Single IP, abbreviated, long",
            src => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
            setup => sub ( $ip ) { $ip.abbreviated = True; $ip.compact = False; },
            methods => {
                ip => "2001:db8:85a3:0:0:8a2e:370:7334",
                prefix => "2001:db8:85a3:0:0:8a2e:370:7334/128",
                Str => "2001:db8:85a3:0:0:8a2e:370:7334",
                gist => "2001:db8:85a3:0:0:8a2e:370:7334",
                first-ip => "2001:db8:85a3:0:0:8a2e:370:7334",
                last-ip => "2001:db8:85a3:0:0:8a2e:370:7334",
            }
        },
        {
            name => "Single IP, abbreviated, compact",
            src => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
            setup => sub ( $ip ) { $ip.abbreviated = True; $ip.compact = True; },
            methods => {
                ip => "2001:db8:85a3::8a2e:370:7334",
                prefix => "2001:db8:85a3::8a2e:370:7334/128",
                Str => "2001:db8:85a3::8a2e:370:7334",
                gist => "2001:db8:85a3::8a2e:370:7334",
                first-ip => "2001:db8:85a3::8a2e:370:7334",
                last-ip => "2001:db8:85a3::8a2e:370:7334",
            }
        },
        {
            name => "Single IP, abbreviated, compact, zeroed tail",
            src => "2001:0db8:85a3:0000:0000:0000:0000:0000",
            setup => sub ( $ip ) { $ip.abbreviated = True; $ip.compact = True; },
            methods => {
                ip => "2001:db8:85a3::",
                prefix => "2001:db8:85a3::/128",
                Str => "2001:db8:85a3::",
                gist => "2001:db8:85a3::",
                first-ip => "2001:db8:85a3::",
                last-ip => "2001:db8:85a3::",
            }
        },
        {
            name => "Single IP, abbreviated, compact, zeroed head",
            src => '::da:beef',
            setup => sub ( $ip ) { $ip.abbreviated = True; $ip.compact = True; },
            methods => {
                ip => "::da:beef",
                prefix => "::da:beef/128",
                Str => "::da:beef",
                gist => "::da:beef",
                first-ip => "::da:beef",
                last-ip => "::da:beef",
            }
        },
        {
            name => "Single IP, preserve source abbreviation",
            src => "2001:db8:85a3::8a2e:370:7334",
            methods => {
                ip => "2001:db8:85a3::8a2e:370:7334",
                prefix => "2001:db8:85a3::8a2e:370:7334/128",
                Str => "2001:db8:85a3::8a2e:370:7334",
                gist => "2001:db8:85a3::8a2e:370:7334",
                first-ip => "2001:db8:85a3::8a2e:370:7334",
                last-ip => "2001:db8:85a3::8a2e:370:7334",
            }
        },
        {
            name => "Range",
            src => "2001:db8:85a3::8a2e:370:7334-2001:db8:85a3::8a2e:370:8334",
            methods => {
                ip => "2001:db8:85a3::8a2e:370:7334",
                Str => "2001:db8:85a3::8a2e:370:7334-2001:db8:85a3::8a2e:370:8334",
                gist => "2001:db8:85a3::8a2e:370:7334-2001:db8:85a3::8a2e:370:8334",
                first-ip => "2001:db8:85a3::8a2e:370:7334",
                last-ip => "2001:db8:85a3::8a2e:370:8334",
            }
        },
        {
            name => "Range, full format",
            src => "2001:0db8:85a3:0000:0000:8a2e:0370:7334-2001:0db8:85a3:0000:0000:8a2e:0370:8334",
            methods => {
                ip => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
                Str => "2001:0db8:85a3:0000:0000:8a2e:0370:7334-2001:0db8:85a3:0000:0000:8a2e:0370:8334",
                gist => "2001:0db8:85a3:0000:0000:8a2e:0370:7334-2001:0db8:85a3:0000:0000:8a2e:0370:8334",
                first-ip => "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
                last-ip => "2001:0db8:85a3:0000:0000:8a2e:0370:8334",
            }
        },
        {
            name => "CIDR, abbreviated, compact",
            src => "2001:db8:85a3::8a2e:370:7334/23",
            methods => {
                ip => "2001:db8:85a3::8a2e:370:7334",
                prefix => "2001:db8:85a3::8a2e:370:7334/23",
                Str => "2001:db8:85a3::8a2e:370:7334/23",
                gist => "2001:db8:85a3::8a2e:370:7334/23",
                first-ip => "2001:c00::",
                last-ip => "2001:dff:ffff:ffff:ffff:ffff:ffff:ffff",
                mask => "ffff:fe00::",
                int-mask => 0xfffffe00000000000000000000000000,
            }
        },
        ;
    for @tests -> $t {
        subtest $t<name> => {
            plan $t<methods>.keys.elems;
            my $ip = IP::Addr.new( $t<src> );

            if $t<setup> {
                $t<setup>( $ip );
            }

            for @( $t<methods> ) -> $m {
                my $meth = $m.key;
                my $expect = $m.value;
                is $ip."$meth"(), $expect, "method $meth";
            }
        }
    }
}

done-testing;
# vim: ft=perl6 et sw=4
