#!/usr/bin/env perl6
use v6;
use lib "lib";
use MetaCPAN::Favorite;

# unlink cache first for test
my $cache = "./cache.txt";
$cache.IO.unlink if $cache.IO.e;

my $metacpan = MetaCPAN::Favorite.new(:$cache);
my $favorite = Supply.interval(60).map({ $metacpan.Supply }).flat;

# my $favorite = $metacpan.Supply; # only once

sub tweet($msg) { note $msg }

react {
    whenever $favorite -> %fav {
        my $name = %fav<name>; # Plack
        my $user = %fav<user>; # SKAJI (the user who favorites Plack, can be undef)
        my $date = %fav<date>; # 2016-08-05T07:49:15.000Z
        my $url  = %fav<url>;  # https://metacpan.org/release/Plack
        $user //= "anonymous";

        tweet("$name++ by $user, $url"); # or, whatever you want
    };
};
