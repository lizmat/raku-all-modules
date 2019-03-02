use v6;
use Test;
use Smack::Test;
use Smack::Client::Request::Common;

use Smack::Builder;
use Smack::Middleware::XFramework;

my &app = builder {
    enable Smack::Middleware::XFramework, framework => 'Dog';
    -> %env {
        start {
            200, [ Content-Type => 'text/plain' ], 'hello'
        }
    }
}

test-p6wapi &app, -> $c {
    my $res = await $c.request(GET '/');
    is $res.header('X-Framework'), 'Dog';
}

done-testing;
