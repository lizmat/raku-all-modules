use v6;

use Test;
use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::Uri::HTTP;
use CroX::HTTP::FallbackPassthru;

my constant $TEST-PORT1 = 33331;
my constant $TEST-PORT2 = 33332;

my $route1 = route {
    get -> 'foo' { content 'text/plain', 'foo' };
};

my $route2 = route {
    get -> 'bar', 'baz' { content 'text/plain', 'baz' };

    post -> 'bar', 'baz' { content 'text/plain', 'baz POST' };
};

my $fallback = CroX::HTTP::FallbackPassthru.new(
    forward-uri => Cro::Uri::HTTP.parse("http://localhost:$TEST-PORT2/bar"),
);

my $s1 = Cro::HTTP::Server.new(
    :host<localhost>, :port($TEST-PORT1),
    :application($route1),
    :after($fallback),
);

my $s2 = Cro::HTTP::Server.new(
    :host<localhost>, :port($TEST-PORT2),
    :application($route2),
);

{
    $s2.start;
    $s1.start;

    given await Cro::HTTP::Client.get("http://localhost:$TEST-PORT2/bar/baz") -> $r {
        is await($r.body-text), 'baz', 'bar/baz works directly';
    }

    given await Cro::HTTP::Client.post("http://localhost:$TEST-PORT2/bar/baz") -> $r {
        is await($r.body-text), 'baz POST', 'bar/baz POST works direclty';
    }

    given await Cro::HTTP::Client.get("http://localhost:$TEST-PORT1/foo") -> $r {
        is await($r.body-text), 'foo', 'foo works directly';
    }

    given await Cro::HTTP::Client.get("http://localhost:$TEST-PORT1/baz") -> $r {
        is await($r.body-text), 'baz', 'bar/baz works indirectly';
    }

    given await Cro::HTTP::Client.post("http://localhost:$TEST-PORT1/baz") -> $r {
        is await($r.body-text), 'baz POST', 'bar/baz POST works indirectly';
    }

    given Cro::HTTP::Client.post("http://localhost:$TEST-PORT1/asdfasdf") -> $p {
        my $r = await $p;
        CATCH {
            when X::Cro::HTTP::Error {
                is .response.status, 404, '404 passthru is okay';
            }
            default {
                fail "did not get a 404";
            }
        }
    }

    LEAVE $s1.stop;
    LEAVE $s2.stop;
}

done-testing;
