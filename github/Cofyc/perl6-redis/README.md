# Redis - Perl6 binding for Redis

[![Build Status](https://travis-ci.com/cofyc/perl6-redis.svg?branch=master)](https://travis-ci.com/cofyc/perl6-redis)

Synopsis
========

    my $redis = Redis.new("127.0.0.1:6379");
    $redis.set("key", "value");
    say $redis.get("key");
    say $redis.info();
    $redis.quit();

Build & Test & Install
======================

Testing this will require redis-server to be installed on your machine.
The tests will start their own version of the redis server on a different
port so as not to interfere with a running server.  If no redis-server
can be found on your machine the tests will be skipped so you will still
be able to install this module.

Assuming you have a working rakudo perl 6 installation then you should be
able to install this with zef:

    zef install Redis

or if you have a local copy of the library:

    zef install .

Unit Tests
==========

    Tested agaist Redis version 2.4.16, 2.5.12 and 4.0.9

Docs
====

    $ p6doc Redis

References
==========

1. http://redis.io/topics/protocol
2. http://search.cpan.org/~melo/Redis-1.951/
