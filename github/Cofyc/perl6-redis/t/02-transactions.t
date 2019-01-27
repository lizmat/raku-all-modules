use v6;

use lib <t lib>;
use Redis;
use Test;

use Test::SpawnRedisServer;

plan 5;

if SpawnRedis() -> $proc {
    LEAVE {
        $proc.kill('INT');
    }
    my $r = Redis.new("127.0.0.1:63790", decode_response => True);
    $r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');
    $r.flushall;


    # multi->...->exec
    is-deeply $r.multi(), True;
    $r.set("key", "value");
    $r.set("key2", "value2");
    is-deeply $r.exec(), ["OK", "OK"];

    # multi->...->discard
    is-deeply $r.multi(), True;
    $r.set("key2", "value3");
    is-deeply $r.discard(), True;
    is-deeply $r.get("key2"), "value2";
}
else {
    skip-rest "no redis-server";
}
