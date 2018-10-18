use v6;

use Test;
use HTTP::Request;
use Crust::Test;
use Hematite;
use Hematite::Middleware::Static;

sub MAIN() {
    my $app = Hematite.new;

    $app.use(Hematite::Middleware::Static.new(public_dir => $?FILE.IO.dirname ~ '/../test-files/'));

    # create the test handler
    my $test = Crust::Test.create(sub ($env) { start { $app($env); }; });

    # Serving valid file
    {
        my $file    = $?FILE.IO.dirname ~ '/../test-files/dummy-file.txt';
        my $res     = $test.request(HTTP::Request.new(GET => '/dummy-file.txt'));
        my $content = $res.content.decode;
        is-deeply($content, $file.IO.slurp, 'static middleware serving file');
    }

    # serving invalid file, should return not found
    {
        my $res = $test.request(HTTP::Request.new(GET => '/dummy-file.txt2'));
        is-deeply($res.code, 404, 'static middleware serving unexistant file');
    }

    done-testing;
}
