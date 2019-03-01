use Test;

use Cache::Async;

my $trace = "";
my $trace-lock = Lock.new;

my $cache = Cache::Async.new(max-size => 4, producer => sub ($k) { $trace-lock.protect({ $trace = $trace ~ $k}); return "[$k]"; });

plan 12;

subtest {
    plan 40;
    for 1..10 -> $l {
        for 'A'..'D' -> $k {
            my $ret = $cache.get($k);
            $ret = await $ret;
            is($ret, "[$k]", "cache returned expected result");
        }
    }
}
is($trace, 'ABCD', "repeatedly getting the same 4 items does not cause cache eviction");

$cache.clear;
$trace = "";
subtest {
    plan 9;
    for ('A', 'B', 'C', 'D', 'X', 'B', 'C', 'D', 'A') -> $k {
        my $ret = $cache.get($k);
        $ret = await $ret;
        is($ret, "[$k]", "cache returned expected result");
    }
}
is($trace, 'ABCDXA', "getting a fith item evicts oldest entry");

$cache.clear;
$trace = "";
subtest {
    plan 9;
    for ('A', 'B', 'C', 'D', 'X', 'A', 'B', 'C', 'D') -> $k {
        my $ret = $cache.get($k);
        $ret = await $ret;
        is($ret, "[$k]", "cache returned expected result");
    }
}
is($trace, 'ABCDXABCD', "cycling through items exposes LRU behavior");

$cache = Cache::Async.new(max-age => Duration.new(.8), producer => sub ($k) { $trace-lock.protect({ $trace = $trace ~ $k}); return "[$k]"; });
$trace = "";

subtest {
    plan 8;
    for ('A', 'B', 'C', 'D', 'A', 'B', 'C', 'D') -> $k {
        my $ret = $cache.get($k);
        $ret = await $ret;
        is($ret, "[$k]", "cache returned expected result");
    }
}
is($trace, 'ABCD', "quickly getting objects is not affected by max-age");

$cache.clear;
$trace = "";
subtest {
    plan 8;
    for ('A', 'B', 'C', 'D') -> $k {
        my $ret = $cache.get($k);
        $ret = await $ret;
        is($ret, "[$k]", "cache returned expected result");
    }
    sleep 1.2;
    for ('A', 'B', 'C', 'D') -> $k {
        my $ret = $cache.get($k);
        $ret = await $ret;
        is($ret, "[$k]", "cache returned expected result");
    }
}
is($trace, 'ABCDABCD', "pausing for longer than max-age clears cache");

$cache.clear;
$trace = "";
subtest {
    plan 8;
    for ('A', 'B', 'C', 'D', 'D', 'C', 'B', 'A') -> $k {
        my $ret = $cache.get($k);
        $ret = await $ret;
        is($ret, "[$k]", "cache returned expected result");
        sleep .25;
    }
}
is($trace, 'ABCDBA', "pausing between gets evicts the older entries");

done-testing;
