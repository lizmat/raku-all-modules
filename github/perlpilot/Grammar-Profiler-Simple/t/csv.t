#!/usr/bin/env perl6

use Test;
use Grammar::Profiler::Simple;

grammar CSV {
    token TOP { ^ <line>+ % "\n" $ }
    token line { <value>+ % ',' }
    token value { <-[,]>+ }
}

my @tests = ( 
    # string,                   { rule1 => call1, rule2 => call2, ... }
    [ "",                       { TOP => 1, line => 1, value => 1 } ],
    [ "alpha",                  { TOP => 2, line => 2, value => 2 } ],
    [ "alpha,beta,gamma,delta", { TOP => 3, line => 3, value => 6 } ],
    [ "a\nb\nc",                { TOP => 4, line => 4, value => 7 } ],
    [ "a,b,c\ne,f\n,g,h,i",     { TOP => 5, line => 5, value => 14 } ],
);
plan(+@tests * 3);

for @tests -> [ $str, %tt ] {
    my $match = CSV.parse($str);
#    say (?$match ?? "MATCH" !! "no match") ~ " '$str'";
    my %t = get-timing;
    for %tt.kv -> $rule, $calls {
        is %tt{$rule}, %t<CSV>{$rule}<calls>, "Rule ``$rule'' was called %tt{$rule} times";
    }
}

