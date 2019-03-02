#!/usr/bin/env perl6
use v6;

use Smack::Client::Request::Common;
use Smack::App::URLMap;
use Smack::Test;
use Test;

sub make-app($name) {
    sub (%env) {
        start {
            my $body = join '|', $name, %env<SCRIPT_NAME>, %env<PATH_INFO>;
            200,
            [ Content-Type => 'text/plain' ],
            [ $body ]
        }
    }
}

my &app1 = make-app('app1');
my &app2 = make-app('app2');
my &app3 = make-app('app3');
my &app4 = make-app('app4');

my $app = Smack::App::URLMap.new;
$app.mount("/", &app1);
$app.mount("/foo", &app2);
$app.mount("/foobar", &app3);
$app.mount("http://bar.example.com/", &app4);

test-p6wapi $app, -> $c {
    my $res;

    $res = await $c.request(GET '/');
    is $res.content, 'app1||/', 'root content is ok';

    $res = await $c.request(GET '/foo');
    is $res.content, 'app2|/foo|', 'foo content is ok';

    $res = await $c.request(GET '/foo/bar');
    is $res.content, 'app2|/foo|/bar', 'foo bar content is ok';

    $res = await $c.request(GET '/foox');
    is $res.content, 'app1||/foox', 'root foox content is ok';

    $res = await $c.request(GET '/foobar');
    is $res.content, 'app3|/foobar|', 'foobar content is ok';

    $res = await $c.request(GET '/foobar/baz');
    is $res.content, 'app3|/foobar|/baz', 'foobar baz content is ok';

    $res = await $c.request(GET '/bar/foo');
    is $res.content, 'app1||/bar/foo', 'root bar foo content is ok';

    $res = await $c.request(GET 'http://bar.example.com/');
    is $res.content, 'app4||/', 'example.com root is ok';

    $res = await $c.request(GET 'http://bar.example.com/foo');
    is $res.content, 'app4||/foo', 'example.com root foo is ok';
}

done-testing;
