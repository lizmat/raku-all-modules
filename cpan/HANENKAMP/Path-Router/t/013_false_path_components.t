#!/usr/bin/perl6

use v6;

use Test;

use Path::Router;

for '0/1', '1/0' -> $path {
    my $router = Path::Router.new;
    $router.add-route($path);
    my $match = $router.match($path);
    ok($match);
    is-deeply($match.route.components, Array[Str].new($path.comb(/ <-[ \/ ]>+ /).Slip));
}

done-testing;
