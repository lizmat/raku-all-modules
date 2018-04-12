# Cache::Async

... a concurrent and asynchronous cache for Perl 6.

## Features

* Producer function that gets passed in on construction and that gets called by
  cache on misses
* Calls producer async and returns future to result, perfect for usage in an
  otherwise async system
* Locked internally so it can be used from multiple threads or a thread pool
* Limits on cache size and optionally entry age

## Upcoming Features

* Sharding to reduce lock contention
* Monitoring of hit rate etc

## Example usage

    my $cache = Cache::Async.new(max-size => 1000, producer => sub ($k) { ... });
    say await $cache.get("key234");

## License

Cache::Async is licensed under the [Artistic License 2.0](https://opensource.org/licenses/Artistic-2.0).

## Feedback and Contact

Please let me know what you think: Robert Lemmen <robertle@semistable.com>
