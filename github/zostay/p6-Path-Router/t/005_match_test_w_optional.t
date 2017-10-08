#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;

use Path::Router;

my $router = Path::Router.new;
isa-ok($router, 'Path::Router');

# create some routes

$router.add-route(':controller/?:action' => {
    defaults   => {
        action => 'index'
    },
    validations => {
        controller => /\D+/,
        action     => /\D+/
    }
});

$router.add-route(':controller/:id/?:action' => {
    defaults   => {
        action => 'show',
    },
    validations => {
        controller => /\D+/,
        action     => /\D+/,
        id         => /\d+/,
    }
});

path-ok($router, $_, '... matched path (' ~ $_ ~ ')')
    for <
        /users/

        /users/new/

        /users/10/
        /users/100000000000101010101/

        /users/10/edit/
        /users/1/show/
        /users/100000000000101010101/show
    >;

path-not-ok($router, $_, '... could not match path (' ~ $_ ~ ')')
    for <
        /10/

        /20/10/

        /users/10/12/

        /users/edit/12/
    >;

done-testing;
