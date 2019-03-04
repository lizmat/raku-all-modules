#!perl6

use v6;

use Test;
use HTTP::Headers;
use Smack::Test::Smackup;
use Smack::Client::Request::Common;

# TODO WHY!? Fix testing server on Travis
plan skip-all => "Fails on Travis CI for some reason."
    if %*ENV<TRAVIS>;

my @tests =
    -> $c, $u {
        my $response = await $c.request(GET($u));
        ok($response.is-success, 'successfully made a request');

        is($response.code, 200, 'returned 200');

        is $response.headers.elems, 1, 'only one header set';
        is $response.Content-Type, 'text/plain', 'Content-Type: text/plain';

        is $response.content, 'Hello World', 'Content is Hello World';
    };

for <hello hello-supply hello-psgi> -> $name {
    subtest {
        my $app = $name ~ ".p6w";
        my $test-server = Smack::Test::Smackup.new(:$app, :@tests);
        $test-server.run;
    }, "$name";
}

done-testing;
