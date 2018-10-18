use v6;
use lib 'lib';
use HTTP::Request;
use URI;
use Test;
use WebService::SOP::V1_1::Request::GET;

my Str $class = 'WebService::SOP::V1_1::Request::GET';

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

    subtest {
        my HTTP::Request $req = ::($class).create-request(
            uri        => URI.new('http://hoge/fuga'),
            params     => { aaa => 'aaa', bbb => 'bbb', time => 1234 },
            app-secret => 'hogehoge',
        );

        is $req.method,     'GET';
        is $req.uri.scheme, 'http';
        is $req.uri.host,   'hoge';
        is $req.uri.path,   '/fuga';

        my %query = $req.uri.query-form;

        is-deeply %query, {
            aaa  => 'aaa',
            bbb  => 'bbb',
            time => '1234',
            sig  => '40499603a4a5e8d4139817e415f637a180a7c18c1a2ab03aa5b296d7756818f6',
        };

    }, 'With no query merge';

    subtest {
        my HTTP::Request $req = ::($class).create-request(
            uri        => URI.new('http://hoge/fuga?bbb=bbb'),
            params     => { aaa => 'aaa', time => 1234 },
            app-secret => 'hogehoge',
        );

        is $req.method,     'GET';
        is $req.uri.scheme, 'http';
        is $req.uri.host,   'hoge';
        is $req.uri.path,   '/fuga';

        my %query = $req.uri.query-form;

        is-deeply %query, {
            aaa  => 'aaa',
            bbb  => 'bbb',
            time => '1234',
            sig  => '40499603a4a5e8d4139817e415f637a180a7c18c1a2ab03aa5b296d7756818f6',
        };

    }, 'With query merge';

}, 'Test create-request succeeds';

done-testing;
