use v6;

use Test;
use JSON::Fast;
use HTTP::Request;
use Crust::Test;
use Hematite;

sub MAIN() {
    my $app = Hematite.new;

    # create the app routes
    $app.GET('/key/:key', sub ($ctx) {
        $ctx.render({
            'named' => $ctx.named-captures,
            'list'  => $ctx.captures,
        });
    });
    $app.GET('/keys/:key1/:key2', sub ($ctx) {
        $ctx.render({
            'named' => $ctx.named-captures,
            'list'  => $ctx.captures,
        });
    });
    $app.GET('/key1/:key1/key2/:key2', sub ($ctx) {
        $ctx.render({
            'named' => $ctx.named-captures,
            'list'  => $ctx.captures,
        });
    });

    # create the test handler
    my $test = Crust::Test.create(sub ($env) { start { $app($env); }; });

    # TEST: single key
    {
        my $res  = $test.request(HTTP::Request.new(GET => '/key/test'));
        my %data = from-json($res.content.decode);
        is-deeply(%data{'named'}, {'key' => 'test'}, 'named-captures - single element');
        is-deeply(%data{'list'}, ['test'], 'list-captures - single element');
    }

    # TEST: multiple keys
    {
        my $res  = $test.request(HTTP::Request.new(GET => '/key1/key1/key2/key2'));
        my %data = from-json($res.content.decode);
        is-deeply(%data{'named'}, {'key1' => 'key1', 'key2' => 'key2'}, 'named-captures - multiple elements');
        is-deeply(%data{'list'}, ['key1', 'key2'], 'list-captures - multiple elements');
    }

    # TEST: multiple keys scaterred
    {

        my $res  = $test.request(HTTP::Request.new(GET => '/keys/key1/key2'));
        my %data = from-json($res.content.decode);
        is-deeply(%data{'named'}, {'key1' => 'key1', 'key2' => 'key2'}, 'named-captures - multiple elements scattered');
        is-deeply(%data{'list'}, ['key1', 'key2'], 'list-captures - multiple elements scattered');
    }

    done-testing;
}
