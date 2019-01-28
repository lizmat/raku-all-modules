use lib 'lib';

use Test;
use Config;

my $config = Config.new();

plan 6;

ok($config.read("t/files/config.json"), "Read a JSON file");

is($config.get<name>, 'test', "attribute 'name' read correctly");
is($config.get<value>, 123, "attribute 'value' read correctly");
is($config.get<tags>, ['A', 'B'], "attribute 'tags' read correctly");
ok($config.get("notthere") === Nil, "get nonexistent key returns nil");
ok($config.get("notthere", "def") === "def", "get nonexistant key with default returns default value");

done-testing;
