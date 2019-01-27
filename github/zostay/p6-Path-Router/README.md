NAME
====

Path::Router - A tool for routing paths

SYNOPSIS
========

    my $router = Path::Router.new;

    $router.add-route('blog' => %(
        conditions => %( :method<GET> ),
        defaults => {
            controller => 'blog',
            action     => 'index',
        },
        # you can provide a fixed "target"
        # for a match as well, this can be
        # anything you want it to be ...
        target => My::App.get_controller('blog').get_action('index')
    ));

    $router.add-route('blog/:year/:month/:day' => %(
        conditions => %( :method<GET> ),
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

    $router.add-route('blog/:action/?:id' => %(
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
    my $match = $router.match('/blog/edit/15', context => %( method => 'GET' ));

    # ... in your code

    my $uri = $router.path-for(
        controller => 'blog',
        action     => 'show_date',
        year       => 2006,
        month      => 10,
        day        => 5,
    );

DESCRIPTION
===========

This module provides a way of deconstructing paths into parameters suitable for dispatching on. It also provides the inverse in that it will take a list of parameters, and construct an appropriate uri for it.

Reversable
----------

This module places a high degree of importance on reversability. The value produced by a path match can be passed back in and you will get the same path you originally put in. The result of this is that it removes ambiguity and therefore reduces the number of possible mis-routings.

Verifiable
----------

This module also provides additional tools you can use to test and verify the integrity of your router. These include:

  * An interactive shell in which you can test various paths and see the match it will return, and also test the reversability of that match.

  * A [Test::Path::Router](Test::Path::Router) module which can be used in your applications test suite to easily verify the integrity of your paths.

Validated and Automatically Coerced
-----------------------------------

Each path may use one or more variables, each given a validation. If a numeric type is used, the value passed on to the action will also be coerced into the correct value.

Flexible
--------

This module has no opinions about what it might be useful for. It simply produces a hash of values that can be used for dispatch, logging, or whatever your application is.

ATTRIBUTES
==========

routes
------

    has Path::Router::Route @.routes

Stores all the route objects that have been added to the router.

METHODS
=======

method add-route
----------------

    method add-route(Str $path, *%options --> Int)

Adds a new route to the *end* of the routes list.

Returns the number of routes stored.

method insert-route
-------------------

    method insert-route(Str $path, *%options --> Int)

Adds a new route to the routes list. You may specify an `at` parameter, which would indicate the position where you want to insert your newly created route. The `at` parameter is the `index` position in the list, so it starts at 0.

Returns the number of routes stored.

Examples:

    # You have more than three paths, insert a new route at
    # the 4th item
    $router.insert-route($path => %(
        at => 3, |%options
    ));

    # If you have less items than the index, then it's the same as
    # as add_route -- it's just appended to the end of the list
    $router.insert-route($path => %(
        at => 1_000_000, |%options
    ));

    # If you want to prepend, omit "at", or specify 0
    $router.insert-route($path => %(
        at => 0, |%options
    ));

method include-router
---------------------

    method include-router (Str $path, Path::Router $other-router --> Int)

This extracts all the route from `$other-router` and includes them into the invocant router and prepends `$path` to all their paths.

It should be noted that this does **not** do any kind of redispatch to the `$other-router`, it actually extracts all the paths from `$other-router` and inserts them into the invocant router. This means any changes to `$other-router` after inclusion will not be reflected in the invocant.

Returns the number of routes stored.

method match
------------

    method match(Str $path, :%context --> Path::Router::Route::Match)

Return a [Path::Router::Route::Match](Path::Router::Route::Match) object for the best route that matches the given the `$path` and `%context` (if given), or an undefined type-object if no routes match.

The `%context` is an optional value that is only used if routes with conditions are present. The context is used as an additional match in the process and can be used to apply extra conditions, such as matching the HTTP method when used in a web application.

The "best route" is chosen by first matching the `$path` against every route and then applying the following rules:

over
====



  * If no route matches, an undefined type object will be returned. If exactly one route matches, a match for that route will be returned.

  * If multiple routes match, the one with the most required variables will be considered the best match and be returned.

  * In the case that exactly two routes match and have the same number of variables, but one has conditions and the other does not, the one that has conditions will be considered best and returned.

  * Otherwise, if there is more than one matching route with the same number of required variables, an [X::Path::Router::AmbiguousMatch::PathMatch](#X::Path::Router::AmbiguousMatch::PathMatch) exception is thrown. This exception contains all the best matches, so your code can disambiguate them in any way you want or treat this as an error condition as suits your application.

method path-for
---------------

    method path-for(:%context, *%path_descriptor --> Str)

Find the path that, when passed to `method match `, would produce the given arguments. Returns the path without any leading `/`. Returns an undefined type-object if no routes match.

The `%context` is optional, but if present, this will also apply any route conditions to the given `%context`.

This will throw an [X::Path::Router::AmbiguousMatch::ReverseMatch](#X::Path::Router::AmbiguousMatch::ReverseMatch) exception if multiple URLs match. This exception includes the possible routes so your code can disambiguate them in whatever fashion makes sense to you.

DEBUGGING
=========

You can turn on the verbose debug logging with the `PATH_ROUTER_DEBUG` environment variable. Set that environment variable to a truthy value to enable debugging.

DIAGNOSTIC
==========

X::Path::Router
---------------

All path router exceptions inherit from this exception class.

X::Path::Router::AmbiguousMatch::PathMatch
------------------------------------------

This exception is thrown when a path is found to match two different routes equally well.

Provides:

  * `method path(--> Str) ` returns the ambiguous path.

  * `method matches(--> Array) ` returns the best matches found.

X::Path::Router::AmbiguousMatch::ReverseMatch
---------------------------------------------

This exception is thrown when two paths are found to match a given criteria when looking up the `path-for` a path

Provides:

  * `method match-keys(--> Array[Str]) ` returns the mapping that was ambiguous

  * `method routes(--> Array[Str]) ` returns the best matches found

X::Path::Router::BadInclusion
-----------------------------

This exception is thrown whenever an attempt is made to include one router in another incorrectly.

X::Path::Router::BadRoute
-------------------------

This exception is thrown when a route has some serious flaw.

Provides:

  * `method path(--> Str) ` returns the bad route

X::Path::Router::BadValidation
------------------------------

This is an [X::Path::Router::BadRoute](#X::Path::Router::BadRoute) exception that is thrown when a validation for a variable that is not found in the path.

Provides:

  * `method validation(--> Str) ` returns the validation variable that was named in the route, but was not found in the path

X::Path::Router::BadSlurpy
--------------------------

This is an [X::Path::Router::BadRoute](#X::Path::Router::BadRoute) exception that is thrown when a validation attempts to add a slurpy parameter that is not at the end of the path.

AUTHOR
======

Andrew Sterling Hanenkamp lthanenkamp@cpan.orggt

Based very closely on the original Perl 5 version by Stevan Little ltstevan.little@iinteractive.comgt

COPYRIGHT
=========

Copyright 2015 Andrew Sterling Hanenkamp.

LICENSE
=======

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

