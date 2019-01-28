#! /usr/bin/env perl6

use v6.c;

use Test;

use IP::Addr;
use IP::Addr::Common;

plan 2;

subtest "Base methods" => {
    plan 4;
    my @tests = 
        {
            src => "127.0.0.1",
            name => "Single IP",
            methods => [
                ip => "127.0.0.1",
                prefix => "127.0.0.1/32",
                Str => "127.0.0.1",
                gist => "127.0.0.1",
                first-ip => "127.0.0.1",
                last-ip => "127.0.0.1",
                wildcard => "0.0.0.0",
            ],
        },
        {
            src => "127.0.0.1/13",
            name => "CIDR",
            methods => [
                ip => "127.0.0.1",
                prefix => "127.0.0.1/13",
                Str => "127.0.0.1/13",
                gist => "127.0.0.1/13",
                first-ip => "127.0.0.0",
                last-ip => "127.7.255.255",
                wildcard => "0.7.255.255",
                size => 524288,
            ],
        },
        {
            src => "127.0.0.1/255.255.240.0",
            name => "CIDR with quad mask",
            methods => [
                ip => "127.0.0.1",
                prefix => "127.0.0.1/20",
                Str => "127.0.0.1/20",
                gist => "127.0.0.1/20",
                first-ip => "127.0.0.0",
                last-ip => "127.0.15.255",
                wildcard => "0.0.15.255",
                size => 4096,
            ],
        },
        {
            src => "127.0.0.11-127.0.0.100",
            name => "Range",
            methods => [
                ip => "127.0.0.11",
                prefix => "127.0.0.11/0",
                Str => "127.0.0.11-127.0.0.100",
                gist => "127.0.0.11-127.0.0.100",
                first-ip => "127.0.0.11",
                last-ip => "127.0.0.100",
                wildcard => "0.0.0.0",
                size => 90,
            ],
        },
        ;

    for @tests -> $t {
        subtest $t<name> => {
            plan $t<methods>.keys.elems;
            my $ip = IP::Addr.new( $t<src> );
            for @( $t<methods> ) -> $m {
                my $meth = $m.key;
                my $expect = $m.value;
                is $ip."$meth"(), $expect, "method $meth";
            }
        }
    }
}

subtest "Info" => {
    my @tests =
        "8.8.8.8" => public,
        "8.8.8.8/16" => public,
        "192.168.13.0/24" => private,
        "192.167.255.250-192.168.0.10" => undetermined,
        "10.11.12.13/10" => private,
        "10.0.0.0/8" => private,
        "10.0.0.0-10.255.255.255" => private,
        "192.0.2.3/25" => documentation,
        "192.0.2.3-192.0.3.0" => undetermined,
        "224.0.1.2" => internet,
        ;

    plan @tests.elems;

    for @tests -> $test {
        my $info = IP::Addr.new( $test.key ).info;
        is $info<scope>, $test.value, $test.key ~ " is " ~ $test.value;
    }
}

done-testing;
# vim: ft=perl6 et sw=4
