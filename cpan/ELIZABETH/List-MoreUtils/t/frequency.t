use v6.c;

use List::MoreUtils <frequency>;
use Test;

plan 5107;

# Test numbers
{
    my @s = 1001 .. 1200;
    my @d = 1 .. 1000;
    my @a = |@d, |@s, |@d;
    my $b = @a.Bag;

    my %f = frequency @a;
    for $b.keys {
        is %f{$_}, $b{$_}, "does int $_ have the right frequency";
    }

    my $u = frequency @a, :scalar;
    is $u, @s + @d, "scalar result of frequency of numbers";
}

# Test strings
{
    my @s = "AA" .. "ZZ";
    my @d = "aa" .. "zz";
    my @a = |@d, |@s, |@d;
    my $b = @a.Bag;

    my %f = frequency @a;
    for $b.keys {
        is %f{$_}, $b{$_}, "does str $_ have the right frequency";
    }

    my $u = frequency @a, :scalar;
    is $u, @s + @d, "scalar result of frequency of strings";
}

# Test mixing strings and numbers
{
    my @s = |(1001 .. 1200), |("AA" .. "ZZ");
    my @d = |(1 .. 1000), |("aa" .. "zz");
    my @a = |@d, |@s, |@d;
    my $b = @a.Bag;

    my %f = frequency @a;
    for $b.keys {
        is %f{$_}, $b{$_}, "does mixed $_ have the right frequency";
    }

    my $u = frequency @a, :scalar;
    is $u, @s + @d, "scalar result of frequency of numbers/strings mixture";
}

# vim: ft=perl6 expandtab sw=4
