use Test;

use Cache::Async;

my $cache1 = Cache::Async.new(producer => sub ($k, $a) { return "$k: $a"; });
my $cache2 = Cache::Async.new(producer => sub ($k, $a, $b) { return "$k: $a $b"; });

plan 2;

ok((await $cache1.get("X", "1")) eq 'X: 1', "single slurpy arg is passed to producer correctly");
ok((await $cache2.get("X", "1", "test")) eq 'X: 1 test', "multiple slurpy args are passed to producer correctly");

done-testing;
