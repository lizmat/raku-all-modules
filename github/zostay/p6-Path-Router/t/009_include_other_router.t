#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;

use Path::Router;

my $poll-router = Path::Router.new();
isa-ok($poll-router, 'Path::Router');

# create some routes

$poll-router.add-route('' => (
    defaults       => {
        controller => 'polls',
        action     => 'index',
    }
));

$poll-router.add-route(':id/vote' => (
    defaults       => {
        controller => 'polls',
        action     => 'vote',
    },
    validations => {
        id      => /\d+/
    }
));

$poll-router.add-route(':id/results' => (
    defaults       => {
        controller => 'polls',
        action     => 'results',
    },
    validations => {
        id      => /\d+/
    }
));

path-ok($poll-router, $_, '... matched path (' ~ $_ ~ ')')
for <
    /
    /15/vote
    /15/results
>;

routes-ok($poll-router, {
    '' => {
        controller => 'polls',
        action     => 'index',
    },
    '15/vote' => {
        controller => 'polls',
        action     => 'vote',
        id         => '15',
    },
    '15/results' => {
        controller => 'polls',
        action     => 'results',
        id         => '15',
    },
},
"... our routes are solid");

# root router

my $router = Path::Router.new();
isa-ok($router, 'Path::Router');

# create some routes

$router.add-route('' => (
    defaults       => {
        controller => 'mysite',
        action     => 'index',
    }
));

$router.add-route('admin' => (
    defaults       => {
        controller => 'admin',
        action     => 'index',
    }
));

$router.include-router('polls/' => $poll-router);

path-ok($router, $_, '... matched path (' ~ $_ ~ ')')
for <
    /
    /admin
    /polls/
    /polls/15/vote
    /polls/15/results
>;

routes-ok($router, {
    '' => {
        controller => 'mysite',
        action     => 'index',
    },
    'admin' => {
        controller => 'admin',
        action     => 'index',
    },
    'polls' => {
        controller => 'polls',
        action     => 'index',
    },
    'polls/15/vote' => {
        controller => 'polls',
        action     => 'vote',
        id         => '15',
    },
    'polls/15/results' => {
        controller => 'polls',
        action     => 'results',
        id         => '15',
    },
},
"... our routes are solid");

# hmm, will this work

my $test-router = Path::Router.new();
isa-ok($test-router, 'Path::Router');

# create some routes

$test-router.add-route('testing' => (
    defaults       => {
        controller => 'testing',
        action     => 'index',
    }
));

$test-router.add-route('testing/:id' => (
    defaults       => {
        controller => 'testing',
        action     => 'get_id',
    },
    validations => {
        id      => /\d+/
    }
));

$router.include-router('' => $test-router);

path-ok($router, $_, '... matched path (' ~ $_ ~ ')')
for <
    /
    /admin
    /polls/
    /polls/15/vote
    /polls/15/results
    /testing
    /testing/100
>;

routes-ok($router, {
    '' => {
        controller => 'mysite',
        action     => 'index',
    },
    'admin' => {
        controller => 'admin',
        action     => 'index',
    },
    'polls' => {
        controller => 'polls',
        action     => 'index',
    },
    'polls/15/vote' => {
        controller => 'polls',
        action     => 'vote',
        id         => '15',
    },
    'polls/15/results' => {
        controller => 'polls',
        action     => 'results',
        id         => '15',
    },
    'testing' => {
        controller => 'testing',
        action     => 'index',
    },
    'testing/1000' => {
        controller => 'testing',
        action     => 'get_id',
        id         => '1000',
    },
},
"... our routes are solid");

# test a few errors

throws-like(
    { $router.include-router('foo' => $test-router) },
    X::Path::Router::BadInclusion,
    "... this dies correctly"
);

throws-like(
    { $router.include-router('/foo' => $test-router) },
    X::Path::Router::BadInclusion,
    "... this dies correctly"
);

throws-like(
    { $router.include-router('/foo/1' => $test-router) },
    X::Path::Router::BadInclusion,
    "... this dies correctly"
);

done-testing;
