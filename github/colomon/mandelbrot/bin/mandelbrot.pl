#!/usr/bin/env perl6

use v6;

my $height = @*ARGS[0] // 31;
my $width = $height;
my $max_iterations = 50;

my $upper-right = -2 + (5/4)i;
my $lower-left = 1/2 - (5/4)i;

sub mandel(Complex $c) {
    my $z = 0i;
    for ^$max_iterations {
        $z = $z * $z + $c;
        return 1 if ($z.abs > 2);
    }
    return 0;
}

sub subdivide($low, $high, $count) {
    (^$count).map({ $low + ($_ / ($count - 1)) * ($high - $low) });
}

say "P1";
say "$width $height";

for subdivide($upper-right.re, $lower-left.re, $height) -> $re {
    my @line = subdivide($re + ($upper-right.im)i, $re + 0i, ($width + 1) / 2).map({ mandel($_) });
    my $middle = @line.pop;
    (@line, $middle, @line.reverse).join(' ').say;
}