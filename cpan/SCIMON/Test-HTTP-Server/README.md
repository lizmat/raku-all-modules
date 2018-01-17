[![Build Status](https://travis-ci.org/Scimon/p6-Test-HTTP-Server.svg?branch=master)](https://travis-ci.org/Scimon/p6-Test-HTTP-Server)

NAME
====

Test::HTTP::Server - Simple to use wrapper around HTTP::Server::Async designed for tests

SYNOPSIS
========

    use Test::HTTP::Server;

    # Simple usage
    # $path is a folder with a selection of test files including index.html
    my $test-server = Test::HTTP::Server.new( :dir($path) );

    # method-to-test expects a web host and will make a GET request to host/index.html
    ok method-to-test( :host( "http://localhost:{$test-server.port}" ) ), "This is a test";
    # Other tests on the results here.

    my @events = $test-server.events;
    is @events.elems, 1, "One request made";
    is @events[0].path, '/index.html', "Expected path called";
    is @events[0].method, 'GET', "Expected method used";
    is @events[0].code, 200, "Expected response code";
    $test-server.clear-events;

DESCRIPTION
===========

Test::HTTP::Server is a wrapper around HTTP::Server::Asnyc designed to allow for simple Mock testing of web services. 

The constructor accepts a 'dir' and an optional 'port' parameter.

The server will server up any files that exist in 'dir' on the given port (if not port is given then one will be assigned, the '.port' method can be acccesed to find what port is being used).

All requests are logged in a basic even log allowing for testing. If you make multiple async requests to the server the ordering of the events list cannot be assured and tests should be written based on this.

If a file doesn't exist then the server will return a 404.

Currently the server returns all files as 'text/plain' except ones ending, '.html'.

TODO
----

Add additional MIME Types.

This is a very basic version of the server in order to allow other development to be worked on. Planned is to allow a config.yml file to exist in the top level directory. If the file exists it will allow you control different paths and their responses.

This is intended to allow the system to replicate errors to allow for error testing.

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
