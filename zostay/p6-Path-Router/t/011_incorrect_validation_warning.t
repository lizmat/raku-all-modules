#!/usr/bin/perl6

use v6;

use Test;

use Path::Router;

my $router = Path::Router.new;

throws-like(
    {
        $router.add-route(
            '/foo/:bar' => (
                validations => {
                    baz => 'Int',
                },
            ),
        );
    },
    X::Path::Router::BadRoute,
    'creating routes with mismatch between path and validations fails',
    validation => 'baz',
    path       => '/foo/:bar',
);

done;
