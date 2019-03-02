#!/usr/bin/env perl6
use v6;

use Smack::Client::Request::Common;
use Smack::Builder;
use Smack::Test;
use Test;

use Smack::Middleware::Runtime;
use Smack::Middleware::XFramework;

constant Runtime    := Smack::Middleware::Runtime;
constant XFramework := Smack::Middleware::XFramework;

sub app(%env) {
    start {
        200, [ Content-Type => 'text/plain' ], [ 'ok' ]
    }
}

sub test-app(&app) {
    test-p6wapi &app, -> $c {
        my $res = await $c.request(GET '/app/foo/bar');
        ok $res.header('X-Runtime'), 'has an X-Runtime header';
        is $res.header('X-Framework'), 'Smack::Builder', 'has the correct X-Framework header';
        is $res.content, 'ok', 'content is ok';
    }
}

subtest {
    my $builder = Smack::Builder.new;
    $builder.add-middleware(Runtime);
    $builder.add-middleware(XFramework, framework => 'Smack::Builder');
    $builder.mount('/app/foo/bar', &app);
    test-app $builder.to-app;
}, 'basic oo test';

subtest {
    my $builder = Smack::Builder.new;
    $builder.add-middleware-if({ %^env<HTTP_HOST> eq 'localhost' }, Runtime);
    $builder.add-middleware(XFramework, framework => 'Smack::Builder');
    $builder.mount('/app/foo/bar', &app);
    test-app $builder.to-app;
}, 'partial conditional test';

done-testing;
