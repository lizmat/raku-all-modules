#!/usr/bin/env perl6
use v6;

use Smack::Client::Request::Common;
use Smack::Middleware::Conditional;
use Smack::Test;
use Smack::Util;
use Test;

sub wrapped-app(%env) {
    start {
        200,
        [ Content-Type => 'text/plain' ],
        [ 'Hello' ],
    }
}

subset AllCapsRequest of Associative
    where { %^env<HTTP_X_ALLCAPS> eq 'YES-PLEASE' };

my &app = Smack::Middleware::Conditional.new(
    app       => &wrapped-app,
    condition => AllCapsRequest,
    builder   => -> &app {
        sub (%env) {
            app(%env).then(-> $p {
                unpack-response($p, -> $s, @h, $e {
                    $s, @h, $e.map(&uc)
                });
            });
        }
    },
).to-app;

test-p6wapi &app, -> $c {
    subtest {
        my $res = await $c.request(GET '/', X-AllCaps => 'YES-PLEASE');
        is $res.content, 'HELLO', 'response is modified';
    }, 'condition active';

    subtest {
        my $res = await $c.request(GET '/', X-AllCaps => 'no-thanks');
        is $res.content, 'Hello', 'response is original';
    }, 'condition inactive';
};

done-testing;
