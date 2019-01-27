#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;

use Path::Router;

my $router = Path::Router.new;
isa-ok($router, 'Path::Router');

# create some routes

$router.add-route('blog' => {
    defaults       => {
        controller => 'blog',
        action     => 'index',
    }
});

$router.add-route('blog/:year/:month/:day' => {
    defaults       => {
        controller => 'blog',
        action     => 'show_date',
    },
    validations => {
        year    => /\d ** 4/,
        month   => /\d ** 1..2/,
        day     => /\d ** 1..2/,
    }
});

$router.add-route('blog/:action/:id' => {
    defaults       => {
        controller => 'blog',
    },
    validations => {
        action  => /\D+/,
        id      => /\d+/
    }
});

path-ok($router, $_, '... matched path (' ~ $_ ~ ')')
    for <
        /blog/

        /blog/edit/15/

        /blog/2006/31/20/
        /blog/2006/31/2/
        /blog/2006/3/2/
        /blog/2006/3/20/
    >;

path-not-ok($router, $_, '... could not match path (' ~ $_ ~ ')')
    for < 
        foo/
        /foo

        /blog/index
        /blog/foo
        /blog/foo/bar
        /blog/10/bar
        blog/10/1000

        /blog/show_date/2006/31/2
        /blog/06/31/2
        /blog/20063/31/2
        /blog/2006/31/200
        /blog/2006/310/1
    >;

done-testing;
