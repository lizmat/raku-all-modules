use v6;

use Test;
use Smack::Builder;
use Smack::Test;
use Smack::Client::Request::Common;
use Smack::Middleware::Head;

my &app = anon sub app(%env) {
    start {
        my $body = "Hello World";

        200,
        [
            Content-Type   => 'text/plain',
            Content-Length => $body.chars,
        ],
        $body
    }
}

&app = builder { enable Smack::Middleware::Head; &app }

test-p6wapi &app, -> $c {
    my $res = await $c.request(GET '/');
    is $res.content, "Hello World";

    $res = await $c.request(HEAD '/');
    ok !$res.content;
    is $res.Content-Length, 11;
}

done-testing;
