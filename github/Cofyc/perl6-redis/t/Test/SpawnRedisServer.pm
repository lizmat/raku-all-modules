module Test::SpawnRedisServer;

sub SpawnRedis() is export {
    shell "redis-server t/redis.conf";
}

# vim: ft=perl6
