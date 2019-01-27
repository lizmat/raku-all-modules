unit module Test::SpawnRedisServer;

use File::Which;
sub SpawnRedis() is export {

    my $proc;
    if which('redis-server') -> $redis {
        $proc = Proc::Async.new($redis,'t/redis.conf');
        $proc.Supply;
        $proc.start;
        sleep 2;
    }

    $proc;
}

# vim: ft=perl6
