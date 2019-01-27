use v6.c;
use Test;

#
# Copyright (C) 2018 Joelle Maslak
# All Rights Reserved - See License
#

use IP::Random;

my constant TRIALS      = 2048;
my constant SMALLTRIALS =  128;

my @ips = map { IP::Random::random_ipv4 }, ^TRIALS;

my @octets = map { 0 }, ^256;
for @ips -> $ip {
    for $ip.split('.') -> $oct {
        @octets[$oct]++;
    }
}

subtest 'randomness', {
    for ^256 -> $oct {
        my $min = ($oct == 0 || $oct == 10 || $oct > 224) ?? 2 !! 4;
        ok(@octets[$oct] <=   64, "$oct randomness 1 (@octets[$oct])");
        ok(@octets[$oct] >= $min, "$oct randomness 2 (@octets[$oct])");
    }
    done-testing;
}

subtest 'not invalid', {
    is @ips.grep( { $_ ~~ m/^0\./ } ).elems, 0, 'IPs starting with 0.';
    is @ips.grep( { $_ ~~ m/^10\./ } ).elems, 0, 'IPs starting with 10.';
    is @ips.grep( { $_ ~~ m/^240\./ } ).elems, 0, 'IPs starting with 240.';
    done-testing;
}

subtest 'only RFC1112', {
    my @ips = map { IP::Random::random_ipv4(exclude => [ 'rfc1112' ]) }, ^TRIALS;

    ok @ips.grep( { $_ ~~ m/^0\./ } ).elems  > 0, 'IPs starting with 0.';
    ok @ips.grep( { $_ ~~ m/^10\./ } ).elems > 0, 'IPs starting with 10.';
    is @ips.grep( { $_ ~~ m/^240\./ } ).elems, 0, 'IPs starting with 240.';

    done-testing;
}

subtest 'RFC1112 and RFC 1122', {
    my @ips = map { IP::Random::random_ipv4(exclude => ('rfc1112', 'rfc1122') ) }, ^TRIALS;

    is @ips.grep( { $_ ~~ m/^0\./ } ).elems,   0, 'IPs starting with 0.';
    ok @ips.grep( { $_ ~~ m/^10\./ } ).elems > 0, 'IPs starting with 10.';
    is @ips.grep( { $_ ~~ m/^240\./ } ).elems, 0, 'IPs starting with 240.';

    done-testing;
}

subtest 'exclude_cidrs', {
    my @ips = map { IP::Random::random_ipv4(exclude => ('0.0.0.0/2', '128.0.0.0/2') ) }, ^SMALLTRIALS;

    my $lowcount  = elems grep { Int($_.split('.')[0]) ~~ 0..^64    }, @ips;
    my $midcount  = elems grep { Int($_.split('.')[0]) ~~ 64..^128  }, @ips;
    my $mid2count = elems grep { Int($_.split('.')[0]) ~~ 128..^192 }, @ips;
    my $highcount = elems grep { Int($_.split('.')[0]) ~~ 192..^256 }, @ips;

    my $allcount  = elems grep { Int($_.split('.')[0]) ~~ 0..^256   }, @ips;

    is $lowcount,   0,           'IPs starting with   0 ..  63';
    ok $midcount >  0,           'IPs starting with  64 .. 127';
    is $mid2count,  0,           'IPs starting with 128 .. 191';
    ok $highcount > 0,           'IPs starting with 192 .. 255';
    is $allcount,   SMALLTRIALS, 'IPs starting with   0 .. 255';

    done-testing;
}

done-testing;

