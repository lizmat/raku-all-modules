#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;

use Path::Router;

class Blog::Index { }
class Blog::ShowDate { }
class Blog::Controller { }

my $INDEX     = Blog::Index.new;
my $SHOW_DATE = Blog::ShowDate.new;
my $GENERAL   = Blog::Controller.new;

my $router = Path::Router.new;
isa_ok($router, 'Path::Router');

# create some routes

$router.add-route('blog' => {
    defaults       => {
        controller => 'blog',
        action     => 'index',
    },
    target => $INDEX,
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
    },
    target => $SHOW_DATE,
});

$router.add-route('blog/:action/:id' => {
    defaults       => {
        controller => 'blog',
    },
    validations => {
        action  => /\D+/,
        id      => /\d+/
    },
    target => $GENERAL
});

{
    my $match = $router.match('/blog/');
    isa_ok($match, 'Path::Router::Route::Match');

    is($match.route.target, $INDEX, '... got the right target');
    is_deeply(
        $match.mapping,
        {
            controller => 'blog',
            action     => 'index',
        },
        '... got the right mapping'
    );
}
{
    my $match = $router.match('/blog/2006/12/1');
    isa_ok($match, 'Path::Router::Route::Match');

    is($match.route.target, $SHOW_DATE, '... got the right target');
    is_deeply(
        $match.mapping,
        {
            controller => 'blog',
            action     => 'show_date',
            year       => '2006',
            month      => '12',
            day        => '1',
        },
        '... got the right mapping'
    );
}
{
    my $match = $router.match('/blog/show/5');
    isa_ok($match, 'Path::Router::Route::Match');

    is($match.route.target, $GENERAL, '... got the right target');
    is_deeply(
        $match.mapping,
        {
            controller => 'blog',
            action     => 'show',
            id         => '5',
        },
        '... got the right mapping' 
    );
}
{
    my $match = $router.match('/blog/show/0');
    isa_ok($match, 'Path::Router::Route::Match');

    is($match.route.target, $GENERAL, '... got the right target');
    is_deeply(
        $match.mapping,
        {
            controller => 'blog',
            action     => 'show',
            id         => '0',
        },
        '... got the right mapping'
    );
}

done;
