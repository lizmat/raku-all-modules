#!/usr/bin/env perl6

use v6;

use Test;
plan 1;

ok $_, $_ ?? "Everything's shiny, Cap'n." !! "Big mosquito." given do {
    use Native::Types;
    use Native::LibC <malloc sizeof>;

    class Point is repr<CStruct> {
        has num64 $.x;
        has num64 $.y;
    }

    my @triangle := malloc(3 * sizeof(Point)).to(Point).grab(3);
    @triangle[flat ^3] =
        Point.new(x => 0e0, y => 0e0),
        Point.new(x => 0e0, y => 1.2e0),
        Point.new(x => 1.8e0, y => 0.6e0);

    my $com = malloc(sizeof(Point)).to(Point);
    $com.lv = Point.new(
        x => ([+] @triangle>>.x) / 3,
        y => ([+] @triangle>>.y) / 3
    );

   so all($com.rv.x, $com.rv.y) == 0.6;
}
