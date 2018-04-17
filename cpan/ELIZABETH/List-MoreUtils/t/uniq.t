use v6.c;

use List::MoreUtils <uniq distinct>;
use Test;

plan 7;

ok &uniq =:= &distinct, 'is uniq the same as distinct';

{
    my @a = |(1 .. 10) xx 2;
    my @u = uniq @a;
    is-deeply @u, [1..10], "1..10 are the uniq values in order";
    is uniq( @a, :scalar), 10, 'we got 10 unique values';
}

{
    my @a = |("aa" .. "zz") xx 2;
    my @u = uniq @a;
    is-deeply @u, ["aa" .. "zz"], "aa .. zz are unique";
    is uniq( @a, :scalar), 676, 'we got 676 unique values';
}

{
    my @a  = |(|(1 .. 10), |("aa" .. "zz")) xx 2;
    my @u  = uniq @a;
    is-deeply @u, [|(1..10), |("aa".."zz")], "1 .. 10, aa .. zz are unique";
    is uniq( @a, :scalar), 10 + 676, 'we got 10 + 676 values occurring once';
}

# vim: ft=perl6 expandtab sw=4
