#! /usr/bin/env perl6

use v6.c;

use Hash::Merge;
use Test;

plan 2;

subtest "merge-hash" => {
    plan 2;

    my %original =
        a => "a",
        b => {
            c => "c"
        }
    ;

    my %result =
        a => "a",
        b => {
            c => "c",
            d => "d",
        },
    ;

    is-deeply merge-hash(%original, %(b => %(d => "d"))), %result, "Hash merges correctly";
    is-deeply merge-hash(%original, %()), %original, "Empty Hash doesn't affect original";
}

subtest "merge-hashes" => {
    plan 4;

    my %original =
        a => "a",
        b => {
            c => "c"
        }
    ;

    my %result =
        a => "a",
        b => {
            c => "c",
            d => "d",
        },
    ;

    is-deeply merge-hashes(%original), %original, "Single argument returns original";
    is-deeply merge-hashes(%original, %(b => %(d => "d"))), %result, "Hash merges correctly";
    is-deeply merge-hashes(%original, %()), %original, "Empty Hash doesn't affect original";

    %result<b><e> = "e";

    is-deeply merge-hashes(%original, %(b => %(d => "d")), %(b => %(e => "e"))), %result, "Hash merges correctly";
}

# vim: ft=perl6 ts=4 sw=4 et
