#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use lib '.';
use IRC::TextColor;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>;

if AUTHOR {
    require Test::META <&meta-ok>;
    meta-ok;
    done-testing;
}
else {
     skip-rest "Skipping META.json test";
     exit;
}
