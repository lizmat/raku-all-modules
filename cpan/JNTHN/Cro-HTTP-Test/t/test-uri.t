use Cro::HTTP::Server;
use Cro::HTTP::Test;

my constant TEST_PORT = 44044;

sub routes() is export {
    use Cro::HTTP::Router;
    route {
        get -> {
            content 'text/plain', 'Nothing to see here';
        }
        post -> 'add' {
            request-body 'application/json' => -> (:$x!, :$y!) {
                content 'application/json', { :result($x + $y) };
            }
        }
    }
}

my $server = Cro::HTTP::Server.new: :host<127.0.0.1>, :port(TEST_PORT), :application(routes());
$server.start;
END $server.stop;

plan 4;

test-service "http://127.0.0.1:{TEST_PORT}/", {
    test get('/'),
        status => 200,
        content-type => 'text/plain',
        body => /:i nothing/;

    test-given '/add', {
        test post(json => { :x(37), :y(5) }),
            status => 200,
            json => { :result(42) };

        test post(json => { :x(37) }),
            status => 400;

        test get(json => { :x(37) }),
            status => 405;
    }
}
