#!/usr/bin/perl6

use Coro::Simple;
use Test;

# a tree walker test

plan 3;

sub tree-map (&f, $tree) {
    if $tree {
        if $tree<left> or $tree<right> {
            tree-map &f, $tree<left>  if $tree<left>;
            tree-map &f, $tree<right> if $tree<right>;
        }
        else {
            %$tree<value> = f $tree<value>;
        }
    }
}

my &tree-next = coro -> $node {
    tree-map &yield, $node
}

my $hs = %( );
$hs<left><left>         = value => 8;
$hs<left><right><right> = value => 14;
$hs<right><right>       = value => 10;

for from tree-next $hs -> $x {
    ok $x;
    say $x;
    sleep 0.5;
}

# end of test