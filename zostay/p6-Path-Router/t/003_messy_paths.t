#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;

use Path::Router;

=for pod
This test how the router fairs with messy URIs

my $router = Path::Router.new;
isa-ok($router, 'Path::Router');

# create some routes

$router.add-route('blog', {
    defaults       => {
        controller => 'blog',
        action     => 'index',
    }
});

$router.add-route('blog/:year/:month/:day', {
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

$router.add-route('blog/:action/:id', {
    defaults       => {
        controller => 'blog',
    },
    validations => {
        action  => /\D+/,
        id      => /\d+/
    }
});

# run it through some tests

path-ok($router, '/blog/', '... this path is valid');
path-ok($router, './blog/', '... this path is valid');
path-ok($router, '///.///.///blog//.//', '... this path is valid');
path-ok($router, '/blog/./show/.//./20', '... this path is valid');
path-ok($router, '/blog/./2006/.//./20////////10', '... this path is valid');

path-is($router,
    '/blog/',
    {
        controller => 'blog',
        action     => 'index',
    },
'... this path matches the mapping');

path-is($router,
    '///.///.///blog//.//',
    {
        controller => 'blog',
        action     => 'index',
    },
'... this path matches the mapping');

path-is($router,
    '/blog/./show/.//./20',
    {
        controller => 'blog',
        action     => 'show',
        id         => '20',
    },
'... this path matches the mapping');

path-is($router,
    '/blog/./2006/.//./20////////10',
    {
        controller => 'blog',
        action     => 'show_date',
        year       => '2006',
        month      => '20',
        day        => '10',
    },
'... this path matches the mapping');

done-testing;
