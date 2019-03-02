use v6;

use Test;
use Smack::Test;
use Smack::Client::Request::Common;

use Smack::Middleware::Runtime;
use Smack::Builder;

my &app = builder {
    enable Smack::Middleware::Runtime;
    sub (%env) {
        start {
            sleep 1;
            200, [ Content-Type => 'text/plain' ], 'Hello'
        }
    }
}

test-p6wapi &app, -> $c {
    my $res = await $c.request(GET '/');
    ok $res.header('X-Runtime').value >= 0.5;
}

done-testing;
