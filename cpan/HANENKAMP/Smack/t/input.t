#!perl6

use v6;

use Test;
use Smack::Test::Smackup;

my @tests =
    -> $c, $url {
        use Smack::Client::Request::Common;
        my $req = POST($url,
            Content-Type   => 'text/plain',
            content        => 'this is a test',
        );
        my $response = await $c.request($req);

        ok $response.is-success, 'request is ok';
        ok $response.content, 'this is a test';
    },
    ;

my $test-server = Smack::Test::Smackup.new(:app<echo.p6w>, :@tests);
$test-server.run;

done-testing;
