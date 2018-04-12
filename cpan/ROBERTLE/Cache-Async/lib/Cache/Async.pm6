unit class Cache::Async;

my class Entry {
    has Str $.key;
    has $.value is rw;
    has $.timestamp is rw; # XXX would like this to be Instant but then it can't be nullable
    has Entry $.older is rw;
    has Entry $.younger is rw;
    has Promise $.promise is rw;
}

has &.producer;
has Int $.max-size = 1024;
has Duration $.max-age;

has Entry %!entries = {};
has Entry $!youngest;
has Entry $!oldest;
has Lock $!lock = Lock.new;

# XXX hit rate and other monitoring

# XXX measure throughput

# XXX we could use some sort of overhand locking scheme to make the lock on the
# entries struct taken for shorter amoutns of time, needs measurement though.
# sharding could solve that problem as well

# XXX sharding

method !unlink($entry) {
    if $!youngest === $entry {
        $!youngest = $entry.older;
    }
    if $!oldest === $entry {
        $!oldest = $entry.younger;
    }
    if defined $entry.older {
        $entry.older.younger = $entry.younger;
        $entry.older = Nil;
    }
    if defined $entry.younger {
        $entry.younger.older = $entry.older;
        $entry.younger = Nil;
    }
}

method !link($entry) {
    if defined $!youngest {
        $!youngest.younger = $entry;
    }
    $entry.older = $!youngest;
    $!youngest = $entry;
    if ! defined $!oldest {
        $!oldest = $entry;
    }
}

method !expire-by-count() {
    while (%!entries.elems > $!max-size) {
        my $evicted = $!oldest;
        my $key = $evicted.key;
        %!entries{$evicted.key}:delete;
        self!unlink($evicted);
    }
}

method !expire-by-age($now) {
    while (defined $!oldest) && ($!oldest.timestamp < ($now - $!max-age)) {
        # XXX duplication from above
        my $evicted = $!oldest;
        my $key = $evicted.key;
        %!entries{$evicted.key}:delete;
        self!unlink($evicted);
    }
}

method get($key --> Promise) {
    my $entry;
    my $now = Nil;
    $!lock.protect({
        if defined $!max-age {
            $now = now;
            self!expire-by-age($now);
        }
        $entry = %!entries{$key};
        if ! defined $entry {
            $entry = Entry.new(key => $key, timestamp => $now);
            %!entries{$key} = $entry;
            self!link($entry);            
            $entry.promise = Promise.start({
                $!lock.protect({
                    $entry.value = &.producer.($key);
                    $entry.promise = Nil;
                });
                $entry.value;
            });
            self!expire-by-count();
            return $entry.promise;
        }
        else {
            if defined $entry.promise {
                return $entry.promise;
            }
            else {
                my $ret = Promise.new;
                $ret.keep($entry.value);
                return $ret;
            }
        }
    });
}

method put($key, $value) {
    $!lock.protect({
        my $entry = %!entries{$key};
        if ! defined $entry {
            $entry = Entry.new(key => $key, value => $value);
            %!entries{$key} = $entry;
        }
        $entry.value = $value;
        # XXX expire old entries
    });
}

method remove($key) {
    $!lock.protect({
        my $removed = %!entries{$key};
        if defined $removed {
            self!unlink($removed);
        }
        %!entries{$key}:delete;
    });
}

method clear() {
    $!lock.protect({
        %!entries = %();
        $!youngest = Nil;
        $!oldest = Nil;
    });
}

