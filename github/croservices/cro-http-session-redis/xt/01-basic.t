use Cro::HTTP::Auth;
use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::HTTP::Session::Redis;
use Test;

constant TEST_PORT = 31319;
my $url = "http://localhost:{TEST_PORT}";

my $fake-now = now;

my class SessionData does Cro::HTTP::Auth {
    has $.count is rw = 0;
}
my $app = route {
    get -> SessionData $session, 'hits' {
        content 'text/plain', 'Visit ' ~ ++$session.count;
    }
}

class RedisBackend does Cro::HTTP::Session::Redis[SessionData] {
    method serialize(SessionData $s --> Blob) {
        Blob.new($s.count);
    }
    method deserialize(Blob $b --> SessionData) {
        SessionData.new(count => $b[0])
    }
}

my $service = Cro::HTTP::Server.new(
    :host('localhost'), :port(TEST_PORT), application => $app,
    before => RedisBackend.new(
        expiration => Duration.new(60 * 30),
        now => { $fake-now }
    )
);
$service.start;
END $service.stop();

given Cro::HTTP::Client.new -> $client {
    given await $client.get("$url/hits") {
        is await(.body-text), 'Visit 1', 'Request with no session cookie gets fresh state (1)';
    }
    given await $client.get("$url/hits") {
        is await(.body-text), 'Visit 1', 'Request with no session cookie gets fresh state (2)';
    }
}

given Cro::HTTP::Client.new(:cookie-jar) -> $client {
    for 1..5 -> $i {
        given await $client.get("$url/hits") {
            is await(.body-text), "Visit $i",
                "Session cookie being sent makes state work (request $i)";
        }
    }
}

given Cro::HTTP::Client.new(:cookie-jar) -> $client-a {
    given Cro::HTTP::Client.new(:cookie-jar) -> $client-b {
        my ($res-a, $res-b) = await do for $client-a, $client-b -> $client {
            start {
                my @a;
                for 1..5 -> $i {
                    given await $client.get("$url/hits") {
                        push @a, await(.body-text);
                    }
                }
                @a.join(',')
            }
        }
        is $res-a, 'Visit 1,Visit 2,Visit 3,Visit 4,Visit 5',
            'No session confusion with concurrent clients (A)';
        is $res-b, 'Visit 1,Visit 2,Visit 3,Visit 4,Visit 5',
            'No session confusion with concurrent clients (B)';
    }
}

done-testing;
