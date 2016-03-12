use v6;
use lib 'lib';
use JSON::Fast;
use Test;
use WebService::SOP::V1_1::Request::PUT_JSON;

my Str $class = 'WebService::SOP::V1_1::Request::PUT_JSON';

subtest {
    my URI $uri .= new('http://hoge/get?hoge=hoge');

    dies-ok {
        ::($class).create-request(
            uri        => $uri,
            params     => ['hoge', 'fuga'],
            app-secret => 'hoge',
        )
    }, 'Dies when `params` is not Hash';

    dies-ok {
        ::($class).create-request(
            uri        => $uri,
            params     => { foo => 'bar' },
            app-secret => 'hoge'
        )
    }, 'Dies when `time` is missing in params';

}, 'Test create-request fails';

subtest {

    my URI $uri .= new('http://hoge/fuga');
    my HTTP::Request $req = ::($class).create-request(
        uri        => $uri,
        params     => { aaa => 'aaa', bbb => 'bbb', time => 1234 },
        app-secret => 'hogehoge',
    );

    is $req.method, 'PUT';
    is ~$req.uri,   'http://hoge/fuga';
    like ~$req.header.field('X-Sop-Sig'), rx{ ^^ <[a..f 0..9]> ** 64 $$ };
    is $req.header.field('Content-Type'), 'application/json';

    my %params = from-json($req.content);

    is-deeply %params, {
        aaa => 'aaa',
        bbb => 'bbb',
        time => 1234,
    };

}, 'Test create-request succeeds';

done-testing;
