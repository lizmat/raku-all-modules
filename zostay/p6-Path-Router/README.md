# Path::Router

[![Build Status](https://travis-ci.org/zostay/p6-Path-Router.svg?branch=master)](https://travis-ci.org/zostay/p6-Path-Router)

## Synopsis

    my $router = Path::Router.new;
  
    $router.add-route('blog' => (
        defaults => {
            controller => 'blog',
            action     => 'index',
        },
        # you can provide a fixed "target"
        # for a match as well, this can be
        # anything you want it to be ...
        target => My::App.get_controller('blog').get_action('index')
    ));
  
    $router.add-route('blog/:year/:month/:day' => (
        defaults => {
            controller => 'blog',
            action     => 'show_date',
        },
        # validate with ...
        validations => {
            # ... raw-Regexp refs
            year       => rx/\d ** 4/,
            # ... custom types you created
            month      => NumericMonth,
            # ... anon-subsets created inline
            day        => (anon subset NumericDay of Int where * <= 31),
        }
    ));
  
    $router.add-route('blog/:action/?:id' => (
        defaults => {
            controller => 'blog',
        },
        validations => {
            action  => rx/\D+/,
            id      => Int,  # also use Perl6 types too
        }
    ));
  
    # even include other routers
    $router.include-router( 'polls/' => $another_router );
  
    # ... in your dispatcher
  
    # returns a Path::Router::Route::Match object
    my $match = $router.match('/blog/edit/15');
  
    # ... in your code
  
    my $uri = $router.uri-for(
        controller => 'blog',
        action     => 'show_date',
        year       => 2006,
        month      => 10,
        day        => 5,
    );

## Description

This module provides a way of deconstructing paths into parameters
suitable for dispatching on. It also provides the inverse in that
it will take a list of parameters, and construct an appropriate
uri for it.

### Reversable

This module places a high degree of importance on reversability.
The value produced by a path match can be passed back in and you
will get the same path you originally put in. The result of this
is that it removes ambiguity and therefore reduces the number of
possible mis-routings.

### Verifyable

This module also provides additional tools you can use to test
and verify the integrity of your router. These include:

* An interactive shell in which you can test various paths and see the
match it will return, and also test the reversability of that match.

* A Test::Path::Router module which can be used in your applications
test suite to easily verify the integrity of your paths.

## Author

Andrew Sterling Hanenkamp ported the Perl 5 version of this library by Stevan
Little to Perl 6. From there, he continued to embellish it further.

Copyright 2015 Andrew Sterling Hanenkamp.

This is a derivative work of the Perl 5 version of this library which is
Copyright 2008-2011 Infinity Interactive, Inc.

This library is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0.
