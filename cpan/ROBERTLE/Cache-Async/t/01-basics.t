use Test;

use Cache::Async;

my %producer-count;

my $cache = Cache::Async.new(producer => sub ($k) { my $i = %producer-count{$k}++; return "$k/$i"; });

plan 6;

ok(sum(%producer-count.values) == 0, "no initial producer state");

$cache.put('X', '??');
ok((await $cache.get("X")) eq '??', "previously put' content returned");
ok(%producer-count{'X'}//0 == 0, "X not produced, already in cache");

await $cache.get("Y");
ok(%producer-count{'Y'}//0 == 1, "Y produced on first call");
ok((await $cache.get("Y")) ~~ /'Y/' <digit>/, "returned content matches producer output");
ok(%producer-count{'Y'}//0 == 1, "Y not re-produced on second call");

done-testing;
