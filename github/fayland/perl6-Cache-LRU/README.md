# perl6-Cache-LRU - Simple, fast implementation of LRU cache in pure perl

[![Build Status](https://travis-ci.org/fayland/perl6-Cache-LRU.svg?branch=master)](https://travis-ci.org/fayland/perl6-Cache-LRU)

## SYNOPSIS

```
use Cache::LRU;

my $cache = Cache::LRU.new(size => 1024);

$cache.set($key, $value);

my $value = $cache.get($key);

my $removed_value = $cache.remove($key);

```

## DESCRIPTION

Cache::LRU is a simple, fast implementation of an in-memory LRU cache in
pure perl.

## FUNCTIONS

### Cache::LRU.new(size => $max_num_of_entries)
Creates a new cache object. Takes a hash as the only argument. The only
parameter currently recognized is the "size" parameter that specifies
the maximum number of entries to be stored within the cache object.
size is default 1024.

### $cache.get($key)
Returns the cached object if exists, or undef otherwise.

### $cache.set($key => $value)
Stores the given key-value pair.

### $cache.remove($key)
Removes data associated to the given key and returns the old value, if
any.

### $cache.clear($key)
Removes all entries from the cache.
