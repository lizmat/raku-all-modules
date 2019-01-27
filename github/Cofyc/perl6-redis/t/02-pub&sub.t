use v6;

use lib <t lib>;
use Redis;
use Test;

plan 1;

use Test::SpawnRedisServer;

if SpawnRedis() -> $proc {
    LEAVE {
        $proc.kill('INT');
    }

    my $r = Redis.new("127.0.0.1:63790", decode_response => True);
    $r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');
    $r.flushall;


    # TODO
    is-deeply $r.publish("queue", "data"), 0;
}
else {
    skip-rest "no redis-server";
}
