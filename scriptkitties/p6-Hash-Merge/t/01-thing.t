#! /usr/bin/env perl6

use v6;
use lib 'lib';
use Test;

use Hash::Merge;

my %a;
my %b;

%a<b> = 1;
%b<a> = 2;
%a<y><z> = 2;
%b<y><a> = 1;

my %b-orig = %b;
my %a-orig = %a;

%a.merge(%b);
is-deeply %b, %b-orig;
is-deeply %a, {:a(2), :b(1), :y(${:a(1), :z(2)})};

%a = %a-orig;
%b = %b-orig;
%a<Z> = "orig";
%b<Z> = "new";
%a.merge(%b);

is-deeply %a, {Z => 'new', a => 2, b => 1, y => {a => 1, z => 2}};

{
    my (%z, %y);

    %z<y><p> = (1,2,3,4);
    %y<y><p> = (5,4,6,7);

    %z.merge(%y);

    is %z, {y => {p => [1, 2, 3, 4, 5, 4, 6, 7]}}, "appends arrays";
}

{
    my (%z, %y);

    %z<y><p> = (1,2,3,4);
    %y<y><p> = (5,4,6,7);

    %z.merge(%y, :no-append-array);

    is-deeply %z,  ${:y(${:p($(5, 4, 6, 7))})}, "no-append-array (replaces the instead)";
}

done-testing;
