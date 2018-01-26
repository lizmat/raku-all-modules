[![Build Status](https://travis-ci.org/cono/p6-supply-timeout.svg?branch=master)](https://travis-ci.org/cono/p6-supply-timeout)

NAME
====

Supply::Timeout - Supply wrapper which can terminate by timeout.

SYNOPSIS
========

    use Supply::Timeout;

    react {
        whenever IO::Socket::Async.listen('0.0.0.0', 3333) -> $conn {
            whenever Supply::Timeout.new($conn.Supply.lines, 4) -> $line {
                $conn.print("$line\n");
                QUIT {
                    when X::Supply::Timeout {
                        $conn.print("TIMEOUT\n");
                        $conn.close;
                    }
                }
            }
        }
        whenever signal(SIGINT) { done(); exit; }
    }

DESCRIPTION
===========

Supply::Timeout can surround your Supply by another one with ability to interrupt in case timeout happend.

METHODS
-------

### new($supply = Supply.interval(0.1), $timeout = 15)

Default constructor

### supply

Accessor to the internal Supply instance.

### timeout

Accessor to the timeout value.

### Supply

Method which produce new Supply with timeout functionality.

AUTHOR
======

cono <q@cono.org.ua>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 cono

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

