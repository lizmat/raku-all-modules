[![Build Status](https://travis-ci.org/skaji/perl6-MetaCPAN-Favorite.svg?branch=master)](https://travis-ci.org/skaji/perl6-MetaCPAN-Favorite)

NAME
====

MetaCPAN::Favorite - consume MetaCPAN recent favorite

SYNOPSIS
========

    use MetaCPAN::Favorite;

    my $metacpan = MetaCPAN::Favorite.new(cache => "./cache.txt");
    my $favorite = Supply.interval(60).map({ $metacpan.Supply }).flat;

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

DESCRIPTION
===========

MetaCPAN::Favorite helps you consume MetaCPAN recent favorite page.

https://metacpan.org/favorite/recent

MOTIVATION
==========

I want to learn how to do concurrency and asynchronous programming in Perl6. More precisely, I want to learn how to use Supply, Channel, Promise, react, whenever, supply.... in Perl6.

Your advice will be highly appreciated.

AUTHOR
======

Shoichi Kaji <skaji@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
