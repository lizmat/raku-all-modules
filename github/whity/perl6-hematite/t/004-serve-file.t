use v6;

use Test;
use HTTP::Request;
use Crust::Test;
use Hematite;

sub MAIN() {
    my $app = Hematite.new;

    my $file = $?FILE.IO.dirname ~ '/test-files/dummy-file.txt';

    # create the app routes
    $app.GET('/dummy-file', sub ($ctx) {
        $ctx.serve-file($file);
        return;
    });

    # create the test handler
    my $test = Crust::Test.create(sub ($env) { start { $app($env); }; });

    my $res     = $test.request(HTTP::Request.new(GET => '/dummy-file'));
    my $content = $res.content.decode;
    is-deeply($content, $file.IO.slurp, '"serve-file" context method');

    done-testing;
}
