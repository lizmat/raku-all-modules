use lib 'lib';

use Test;
use Config;

my $config = Config.new();

plan 7;

ok($config.read("t/files/config.json"), "Read a JSON file");
ok($config.read("t/files/config2.json"), "Read another JSON file");

is($config.get<name>, 'ofen', "attribute 'name' (merged) read correctly");
is($config.get<value>, 123, "attribute 'value' (unchanged read correctly");
is($config.get<lname>, 'rohr', "attribute 'lname' (new) read correctly");

ok($config.get("notthere") === Nil, "get nonexistent key returns nil");
ok($config.get("notthere", "def") === "def", "get nonexistant key with default returns default value");

done-testing;
