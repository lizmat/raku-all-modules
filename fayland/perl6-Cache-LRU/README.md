# perl6-Cache-LRU - Simple, fast implementation of LRU cache in pure perl

[![Build Status](https://travis-ci.org/fayland/perl6-Cache-LRU.svg?branch=master)](https://travis-ci.org/fayland/perl6-Cache-LRU)

## SYNOPSIS

```
use Cache::LRU;

my $cache = Cache::LRU.new(size => 1024);

$cache->set($key, $value);

my $value = $cache->get($key);

my $removed_value = $cache->remove($key);

```

## DESCRIPTION
