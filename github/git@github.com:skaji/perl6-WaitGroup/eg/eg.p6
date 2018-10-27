#!/usr/bin/env perl6
use v6;
use lib "lib", "../lib";

use WaitGroup;
use HTTP::Tinyish;

my $wg = WaitGroup.new;

my @url = <
    http://www.golang.org/
    http://www.google.com/
    http://www.somestupidname.com/
>;

for @url -> $url {
    $wg.add(1);
    start {
        LEAVE $wg.done;
        my $res = HTTP::Tinyish.new.get($url, :bin);
        note "-> {$res<status>}, $url";
    };
}

$wg.wait;
