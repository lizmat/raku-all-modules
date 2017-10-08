use v6;

use lib 'lib';

use Test;
plan 6;

use Config::Clever;
ok 1, "'use Config::Clever' worked";

my $result;

$result = Config::Clever.load();
ok $result == %(one => 1, two => 2), "load works";

$result = Config::Clever.load(:environment('production'));
ok $result == %(
    one => 1,
    two => 22,
    three => %(four => 4),
    five => 5
    ), "production load works";

# test more advanced usage
$result = Config::Clever.load(:environment("production"),
                               :config-dir("t/advanced-config"));
ok $result == %(
    web => %(
        port => 8080,
        secret => "a_real_good_secret",
        logLevel => "WARN"
    ),
    db => %(
        host => "db.example.com",
        port => 27017,
        auth => True,
        user => "someuser",
        password => "password"
    )), "advanced example works";


# test hash-merge
$result = Config::Clever::hash-merge( %(), %(one => 1) );
ok $result == %(one => 1), "hash merge works on simple value";

$result = Config::Clever::hash-merge(
    %(one => 0,
      two => %(three => 0),
      four => 4),
    %(one => 1,
      two => %(three => [3, 33]))
);
ok $result == %(one => 1,
                two => %(three => [3, 33]),
                four => 4), "hash merge works on more complex value";
