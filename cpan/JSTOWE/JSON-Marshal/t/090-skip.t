#!/usr/bin/env perl6

use v6;

use Test;

use JSON::Marshal;
use JSON::Fast;

class WithSkip {
    has Str $.skipped is json-skip = "skipped";
    has Str $.not-skipped = "not skipped";
}


my $c = WithSkip.new;

my $json = marshal($c);

my %data = from-json($json);

ok !(%data<skipped>:exists), "the skipped attribute isn't in the JSON";
ok %data<not-skipped>:exists, "the not skipped attribute is in the JSON";


done-testing;

# vim: ft=perl6

