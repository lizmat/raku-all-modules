use v6.c;
use lib 'lib';

use HTTP::Server::Ogre;

my $server = HTTP::Server::Ogre.new(
    :host<localhost>,
    :port(1337),
    :app(&app-simple),
    :tls-mode(True),
    :http-mode<2>,
    tls-config => (
        certificate-file => 'example/cert.pem',
        private-key-file => 'example/key.pem',
        version          => 1.2,
    )
);

sub app-simple(%env) {
    start {
        200, [Content-Type => 'text/plain', Content-Length => '11'], ['Hello World'];
    }
}

sub app-supply(%env) {
    start {
        200, [Content-Type => 'text/plain'], supply { emit 'Hello World' };
    }
}

$server.run;
