use v6;

use Test;
use JSON::Fast;
use HTTP::Request;
use Crust::Test;
use Hematite;

sub MAIN() {
    my $app = Hematite.new();

    my %simple_structure = ('hello' => 'world');
    $app.GET('/simple.json', sub ($ctx) { $ctx.render(%simple_structure); } );

    my %complex_structure = (
        'hello' => 'world',
        'array' => [
            1,2,3
        ],
        'hash'  => {
            'key1' => 1,
            'key2' => 2,
        }
    );
    $app.GET('/complex.json', sub ($ctx) { $ctx.render(%complex_structure); } );

    # create the test handler
    my $test = Crust::Test.create(sub ($env) { start { $app($env); }; });

    {
        my $res = $test.request(HTTP::Request.new(GET => "/simple.json"));
        is($res.content.decode, to-json(%simple_structure), 'render simple json structure');
    }


    {
        my $res = $test.request(HTTP::Request.new(GET => "/complex.json"));
        is($res.content.decode, to-json(%complex_structure), 'render complex json structure');
    }

    done-testing;

    return;
}
