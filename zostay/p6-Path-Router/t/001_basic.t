#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;

use Path::Router;

subset NumericMonth of Int where * <= 12;

my $router = Path::Router.new;
isa_ok($router, 'Path::Router');

ok($router.^can('add-route'));
ok($router.^can('match'));
ok($router.^can('uri-for'));

# create some routes

$router.add-route('blog/:year/:month/:day', {
    defaults       => {
        controller => 'blog',
        action     => 'show_date',
    },
    validations => {
        year    => /\d ** 4/,
        month   => NumericMonth,
        day     => (anon subset NumericDay of Int where * <= 31),
    }
});

# This used to be added at the very beginning, but we're putting it here
# to test insert_route
$router.insert-route('blog', {
    defaults       => {
        controller => 'blog',
        action     => 'index',
    }
});

# This used to be added as the second argument, but we're... see above.
$router.insert-route('blog/:action/:id', {
    at => 2,
    defaults       => {
        controller => 'blog',
    },
    validations => {
        action  => /\D+/,
        id      => Int,
    }
});

# This used to be added as the last argument, but we're... see above.
$router.insert-route('test/?:x/?:y', {
    at => 1_000_000,
    defaults => {
        controller => 'test',
        x          => 'x',
        y          => 'y',
    },
});

# create some tests

# check to make sure that "blog" is at the front
is( $router.routes.[0].path, 'blog', "first route is 'blog'");
is( $router.routes.[2].path, 'blog/:action/:id', "3rd route is 'blog/:action/:id'");
is( $router.routes.[3].path, 'test/?:x/?:y', "4th route is 'test/?:x/?:y'");

routes-ok($router, {
    # blog
    'blog' => {
        controller => 'blog',
        action     => 'index',
    },
    # blog/:year/:month/:day
    'blog/2006/12/5' => {
        controller => 'blog',
        action     => 'show_date',
        year       => '2006',
        month      => 12,
        day        => 5,
    },
    # blog/:year/:month/:day
    'blog/1920/12/10' => {
        controller => 'blog',
        action     => 'show_date',
        year       => '1920',
        month      => 12,
        day        => 10,
    },
    # blog/:action/:id
    'blog/edit/5' => {
        controller => 'blog',
        action     => 'edit',
        id         => 5
    },
    'blog/show/123' => {
        controller => 'blog',
        action     => 'show',
        id         => 123
    },
    'blog/some_crazy_long_winded_action_name/12356789101112131151' => {
        controller => 'blog',
        action     => 'some_crazy_long_winded_action_name',
        id         => 12356789101112131151,
    },
    'blog/delete/5' => {
        controller => 'blog',
        action     => 'delete',
        id         => 5,
    },
    'test/x1' => {
        controller => 'test',
        x          => 'x1',
        y          => 'y',
    },
},
"... our routes are solid");

done;
