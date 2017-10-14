[![Build Status](https://travis-ci.org/atroxaper/p6-Propius.svg?branch=master)](https://travis-ci.org/atroxaper/p6-Propius)

Propius
=======

Memory cache with loader and eviction by time.
Inspired by [Guava's CacheLoader](https://github.com/google/guava/wiki/CachesExplained).

Examples
--------
        use Propius;
        my $cache = eviction-based-cache(
          loader => { $:key ** 2 }, # calculation of the new value for key
          removal-listener => { say 'removed ', $:key, ':', $:value, ' cause ', $:cause },
            # optional listener for removed values
          expire-after-write => 60); # freshness time of cached values;
        
        $cache.get(5); # returns prodused the new value - 25;
        $cache.get(5): # returns cached value - 25;
        $cache.get-if-exists(6); # returns Any
        $cache.put(:9key, loader => { $:key ** 3 }); # cache value for specified loader
        $cache.get(9); # returns cached value - 729
        # ... 60 seconds later in output (in case you use the cache)
        removed 5:25 cause Expired
        removed 9:729 cause Expired
        
Create
------

You can use sub `eviction-based-cache` for creation the new cache.
Arguments are:

`:&loader! where .signature ~~ :(:$key)` - sub with signature like (:$key).
The sub will be used for producing the new values. Obligatory argument.

`:&removal-listener where .signature ~~ :(:$key, :$value, :$cause)` -
sub with signature like (:$key, :$value, :$cause).
The sub will be called in case when value removed from the cache.
Cause is element of enum RemoveCause.

`:$expire-after-write` - how long the cache have to store value after its last re/write

`:$expire-after-access` - how long the cache have to store value after its last access (read or write)

`:$time-unit` - object of TimeUnit, indicate time unit of expire-after-write/access value.
seconds by default.

`:$ticker` - object of Ticker, witch is used for retrieve 'current' time.
Can be specified for overriding standard behaviour (current system time),for example for testing.

`:$size` - max capacity of the cache.

Notes
-----

The cache can use object keys. If you want that you have to control .WHICH method if keys.

Of course the cache is thread-save. It simply uses OO::Monitors for synchronisation.

Available methods
-----------------

### get(Any:D $key)
Retrieve value by key.

        my $is-primitive = $cache.get(655360001);

If there is no value for specified key then loader with be
used to produce the new value.

### get-if-exists(Any:D $key)
Retrieve value by key only if it exists.

        my $is-primitive = $cache.get-if-exists(900900900900990990990991);

If there is no value for specified key then Any will be returned.

### put(Any:D :$key, Any:D :$value)
### put(Any:D :$key, :&loader! where .signature ~~ :(:$key))
Store a value in cache with/without specified loader.

        $cache.put(:900900900900990990990991key, :value);
        $cache.put(:2key, loader => { True });

It will rewrite any cached value for specified key. In that case
removal-listener will be called with old value cause Replaced.

In case of cache already reached max capacity value which has not
been used for a longest time will be removed. In that case
removal-listener will be called with old value cause Size.

### invalidate
### invalidateAll(List:D @keys)
### invalidateAll
Mark value/values for specified/all key/keys as invalidate.

        $cache.invalidate(655360001);
        $cache.invalidateAll(<1 2 3>);
        $cahce.invalidateAll();
        
The value will be removed and removal-listener will be called for each
old values cause Explicit.

### elems
Return keys and values stored in cache as Hash.

        $cache.elems();
        
### hash
Return keys and values stored in cache as Hash.

        $cache.hash();
        
This is a copy of values. Any modification of returned cache will no have
an effect on values in the store.

### clean-up
Clean evicted values from cache.

        $cache.clean-up();
        
This method may be invoked directly by user.

The method invoked on each write operation and ones for several read operation
if there was no write operation recently.

It means that evicted values will be removed on just in time of its eviction.
This is done for the purpose of optimisation - is it not requires special thread
for checking an eviction. If it is issue for you then you can call it method yourself
by some scheduled Promise for example.

Sources
-------

[GitHub](https://github.com/atroxaper/p6-Propius)

Author
------

Mikhail Khorkov <atroxaper@cpan.org>

License
-------

See [LICENSE](LICENSE) file for the details of the license of the code in this repository.

       



