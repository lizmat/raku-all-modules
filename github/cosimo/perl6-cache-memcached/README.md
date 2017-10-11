# Cache::Memcached [![Build Status](https://travis-ci.org/cosimo/perl6-cache-memcached.svg?branch=master)](https://travis-ci.org/cosimo/perl6-cache-memcached)

Perl6 client for [memcached](http://www.danga.com/memcached/) a distributed
caching daemon.

## Synopsis

```perl6
  use Cache::Memcached;

  my $memd = Cache::Memcached.new;

  $memd.set("my_key", "Some value");

  $memd.incr("key");
  $memd.decr("key");
  $memd.incr("key", 2);

```
Or you can use it as an Associative type:

```perl6

use Cache::Memcached;

my $memd = Cache::Memcached.new;

$memd<my_key> = "Some value";
say $memd<my_key>;
$memd<my_key>:delete;
```

## Description

This provides an interface to the [memcached](http://www.danga.com/memcached/)
daemon. You will need to have access to a memcached server to be able to
use it.

Currently there is no support for compression or the serialization of
structured objects (though both could be provided by the agency of
external modules.)

## Installation

Assuming you have a working Rakudo Perl 6 installation you should be able to
install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install Cache::Memcached

There should be no reason that it won't work with any new installer
that may come along in the future.

## Support

Suggestions/patches are welcomed via github at

https://github.com/cosimo/perl6-cache-memcached/issues


