# Cache::Async

... A Concurrent and Asynchronous Cache for Perl 6.

## Features

* Producer function that gets passed in on construction and that gets called by
  cache on misses
* Cache size and maximum entry age can be limited
* Cache allows refreshing of entries even before they have expired
* Calls producer async and returns promise to result, perfect for usage in an
  otherwise async or reactive system
* Transparent support for producers that return promises themselves
* Extra args can be passed through to producer easily
* Jitter for refresh and expiry to smooth out producer calls over time
* Locked internally so it can be used from multiple threads or a thread pool
* Propagates exceptions from producer transparently
* Monitoring of hit rate 

## Upcoming Features

* Get entry from cache if present, without loading/refreshing
* Optimizations of the async producer case
* Object lifetimes can be restricted by producer function

## Example usage

    my $cache = Cache::Async.new(max-size => 1000, producer => sub ($k) { ... });
    say await $cache.get("key234");

## Documentation

Please see the POD in lib/Cache/Async.pm6 for usage scenarios and details on how to use Cache::Async.

## License

Cache::Async is licensed under the [Artistic License 2.0](https://opensource.org/licenses/Artistic-2.0).

## Feedback and Contact

Please let me know what you think: Robert Lemmen <robertle@semistable.com>
