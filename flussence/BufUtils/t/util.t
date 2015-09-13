#!/usr/bin/env perl6
use BufUtils;
use Test;
plan 3;

subtest {
    plan 3;
    for ^3 {
        my $string = "hello world" ~ "\n" x $_;
        is chomp($string.encode).decode,
           $string.chomp,
           "chomp({$string.perl}) works";
    }
}, 'chomp(Buf)';

subtest {
    plan 4;
    given 'hello World!' {
        is lc(.encode).decode, .lc, "lc({$_.perl})";
        is uc(.encode).decode, .uc, "uc({$_.perl})";
        is tc(.encode).decode, .tc, "tc({$_.perl})";
        is tclc(.encode).decode, .tclc, "tclc({$_.perl})";
    }
}, '/lc|uc|tc[lc]?/(Buf)';

subtest {
    plan 5;
    given '¾' {
        is unival(.encode('utf-8')), 3/4,
            "unival({$_.perl})";
        dies-ok { unival(.encode('latin-1')) },
            'unival() wants Blob[utf8]';
    }

    given '4a¾' {
        is unival(.encode('utf-8')), 4,
            "unival({$_.perl})";
        is-deeply univals(.encode('utf-8')).list, (4, NaN, 3/4),
            "univals({$_.perl})";
        dies-ok { univals(.encode('latin-1')) },
            'univals() wants Blob[utf8]';
    }
}, 'unival(Buf) and univals(Buf)';
