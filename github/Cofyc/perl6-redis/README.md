# Redis - Perl6 binding for Redis

Synopsis
========

    my $redis = Redis.new("127.0.0.1:6379");
    $redis.set("key", "value");
    say $redis.get("key");
    say $redis.info();
    $redis.quit();

Build & Test & Install
======================
    
First, please get 'ufo' from <http://github.com/masak/ufo> , then run:

    $ ufo
    $ make
    $ make test     # run `redis-server t/redis.conf` in another terminal first
    $ make install

Install with Panda
==================

    $ panda install --notests Redis # unit tests need Redis server

Unit Tests
==========

    Tested agaist Redis version 2.4.16 and 2.5.12.

Docs
====

    $ p6doc Redis

References
==========

1. http://redis.io/topics/protocol
2. http://search.cpan.org/~melo/Redis-1.951/
