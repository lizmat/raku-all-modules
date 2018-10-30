[![Build Status](https://travis-ci.org/lestrrat/p6-Crust-Middleware-Session.svg?branch=master)](https://travis-ci.org/lestrrat/p6-Crust-Middleware-Session)

NAME
====

Crust::Middleware::Session - Session Middleware for Crust Framework

SYNOPSIS
========

    use Crust::Builder;
    use Crust::Middleware::Session;

    # $store can be anything that implements Crust::Middleware:Session::StoreRole.
    # This here is a dummy that stores everything in memory
    my $store = Crust::Middleware::Session::Store::Memory.new();
    builder {
      enable 'Session', :store($store);
      &app;
    };

DESCRIPTION
===========

Crust::Middleware::Session manages sessions for your Crust app. This
module uses cookies to keep session state and does not support URI
based session state.

A session object will be available under the kye `p6sgix.session` in
the P6SGI environment hash. You can use this to access session data

    my &app = ->%env {
        %env<p6sgix.session>.get("username").say;
        ...
    };

AUTHOR
======

Daisuke Maki <lestrrat@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2015 Daisuke Maki

This library is free software; you can redistribute it and/or modify
it under the Artistic License 2.0.
