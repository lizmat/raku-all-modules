use v6.c;

use List::MoreUtils <duplicates>;
use Test;

plan 6;

# Test numbers
{
    my @s = 1001 .. 1200;
    my @d = 1 .. 1000;
    my @a = |@d, |@s, |@d;
    my @u = duplicates @a;
    is-deeply @u, @d, "duplicates of numbers";

    my $u = duplicates @a, :scalar;
    is $u, +@d, "scalar result of duplicates of numbers";
}

# Test strings
{
    my @s = "AA" .. "ZZ";
    my @d = "aa" .. "zz";
    my @a = |@d, |@s, |@d;
    my @u = duplicates @a;
    is-deeply @u, @d, "duplicates of strings";

    my $u = duplicates @a, :scalar;
    is $u, +@d, "scalar result of duplicates of strings";
}

# Test mixing strings and numbers
{
    my @s = |(1001 .. 1200), |("AA" .. "ZZ");
    my @d = |(1 .. 1000), |("aa" .. "zz");
    my @a = |@d, |@s, |@d;

    my @u = duplicates @a;
    is-deeply @u, @d, "duplicates of numbers/strings mixture";

    my $u = duplicates @a, :scalar;
    is $u, +@d, "scalar result of duplicates of numbers/strings mixture";
}

# vim: ft=perl6 expandtab sw=4
