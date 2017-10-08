use v6;

use Test;
use HTTP::Request;
use Crust::Test;
use Hematite;

sub MAIN() {
    my @methods = ('GET', 'POST');
    my $app     = Hematite.new;

    # create the app routes
    for @methods -> $method {
        $app.METHOD($method, "/{ $method.lc }", sub () { return; } );
    }

    # create the test handler
    my $test = Crust::Test.create(sub ($env) { start { $app($env); }; });

    # test the routes
    for @methods -> $method {
        my $res  = $test.request(HTTP::Request.new(|($method => "/{ $method.lc }")));
        # test status code
        is($res.code, 200, "method { $method }");
    }

    done-testing;
}
