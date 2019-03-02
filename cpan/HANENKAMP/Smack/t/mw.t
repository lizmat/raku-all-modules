#!perl6

use v6;

use Test;
use Smack::Test::Smackup;
use Smack::Client::Request::Common;

my @tests =
    -> $c, $u {
        my $response = await $c.request(GET($u));
        ok $response.is-success, 'request is ok';

        is $response.header('P6W-Used'), 'True', 'mw inserted header';
    },
    ;

my $test-server = Smack::Test::Smackup.new(:app<mw.p6w>, :@tests);
$test-server.run;
note $test-server.err;

done-testing;
