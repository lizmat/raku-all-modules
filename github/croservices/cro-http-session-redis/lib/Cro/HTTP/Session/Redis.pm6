use Cro::HTTP::Session::IdGenerator;
use Cro::HTTP::Session::Persistent;
use Redis::Async;

role Cro::HTTP::Session::Redis[::TSession] does Cro::HTTP::Session::Persistent[::TSession] {
    has $.redis-host = 'localhost';
    has $.redis-port = 6379;
    has $!redis;

    method load(Str $session-id) {
        self.deserialize(self!execute(-> { $!redis.get($session-id, :bin) }));
    }

    method save(Str $session-id, TSession $session --> Nil) {
        my $blob = self.serialize($session);
        self!execute(-> {
                            $!redis.set($session-id, $blob);
                            $!redis.expireat($session-id, now + self.expiration);
                        });
    }

    method clear(--> Nil) {}

    method serialize(TSession $s --> Blob) { ... }
    method deserialize(Blob $b --> TSession) { ... }

    method !execute(&command) {
        $!redis //= Redis::Async.new("{$!redis-host}:{$!redis-port}");
        try {
            # We ping server every time to be sure that handle is alive
            $!redis.ping;
            my $executed = &command();
            return $executed;
        }
        CATCH {
            default {
                fail($!);
            }
        }
    }
}


=begin pod

=head1 Cro::HTTP::Session::Redis

This is part of the Cro libraries for implementing services and distributed
systems in Perl 6. See the [Cro website](http://cro.services/) for further
information and documentation.
=end pod
