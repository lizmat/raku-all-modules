#!perl6

use v6;

use Test;
use Smack::Test::Smackup;

my @tests =
    -> $c, $u {
        use Smack::Client::Request::Common;
        my $req = POST($u, content => supply {
            emit "ok 1 # got some content\n";
            emit "1..1\n";
        });
        my $response = await $c.request($req);
        ok $response.is-success, 'request is ok';
    },
    ;

my $test-server = Smack::Test::Smackup.new(:app<echo-err.p6w>, :@tests);
$test-server.run;

$test-server.treat-err-as-tap;

done-testing;
