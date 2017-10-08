use v6;
use lib 'lib';
use HTTP::Request;
use Test;
use URI;
use WebService::SOP::V1_1::Request::PUT;

my Str $class = 'WebService::SOP::V1_1::Request::PUT';

subtest {
    my URI $uri .= new('http://hoge/post?hoge=hoge');

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
            params     => { fuga => 'fuga' },
            app-secret => 'hoge',
        )
    }, 'Dies when `time` is missing';

}, 'Test create-request fails';

subtest {

    subtest {
        my HTTP::Request $req = ::($class).create-request(
            uri        => URI.new('http://hoge/fuga'),
            params     => { aaa => 'aaa', bbb => 'bbb', time => 1234 },
            app-secret => 'hogehoge',
        );

        is $req.method,     'PUT';
        is $req.uri.scheme, 'http';
        is $req.uri.host,   'hoge';
        is $req.uri.path,   '/fuga';
        is $req.header.field('Content-Type'), 'application/x-www-form-urlencoded';
        is-deeply $req.uri.query-form, {};

        my %query = URI::split-query(~$req.content);

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

        is $req.method,     'PUT';
        is $req.uri.scheme, 'http';
        is $req.uri.host,   'hoge';
        is $req.uri.path,   '/fuga';
        is $req.header.field('Content-Type'), 'application/x-www-form-urlencoded';
        is-deeply $req.uri.query-form, {};

        my %query = URI::split-query(~$req.content);

        is-deeply %query, {
            aaa  => 'aaa',
            bbb  => 'bbb',
            time => '1234',
            sig  => '40499603a4a5e8d4139817e415f637a180a7c18c1a2ab03aa5b296d7756818f6',
        };

    }, 'With query merge';

}, 'Test create-request succeeds';

done-testing;
