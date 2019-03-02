use v6;

use Test;
use Smack::Test;

use Smack::Client::Request::Common;
use Smack::Builder;

use Smack::Middleware::ErrorDocument;
use Smack::Middleware::Static;

my $root = $*PROGRAM.parent;

my &app = builder {
    enable Smack::Middleware::ErrorDocument,
        500 => "$root/errors/500.html";
    enable Smack::Middleware::ErrorDocument,
        404 => "/errors/404.html", :subrequest;
    enable Smack::Middleware::Static,
        path => rx{^ '/errors' }, root => $root;

    -> %env {
        start {
            my $status = +(%env<PATH_INFO> ~~ m! "status/" (\d+) !)[0] || 200;
            $status, [ Content-Type => 'text/plain' ], "Error: $status";
        }
    }
}

test-p6wapi &app, -> $c {
    my $res = await $c.request(GET '/');
    is $res.code, 200;

    $res = await $c.request(GET '/status/500');
    is $res.code, 500;
    like $res.content, rx/'fancy 500'/;

    $res = await $c.request(GET '/status/404');
    is $res.code, 404;
    is $res.Content-Type.primary, 'text/html';
    like $res.content, rx/'fancy 404'/;
}

done-testing;
