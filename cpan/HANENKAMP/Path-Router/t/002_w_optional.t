#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;

use Path::Router;

my $router = Path::Router.new;
isa-ok($router, 'Path::Router');

# create some routes

$router.add-route(':controller/?:action', {
    defaults   => {
        action => 'index'
    },
    validations => {
        action  => /\D+/
    }
});

$router.add-route(':controller/:id/?:action', {
    defaults   => {
        action => 'show',
    },
    validations => {
        id      => Int,
    }
});

# run it through some tests

routes-ok($router, {
    'people' => {
        controller => 'people',
        action     => 'index',
    },
    'people/new' => {
        controller => 'people',
        action     => 'new',
    },
    'people/create' => {
        controller => 'people',
        action     => 'create',
    },
    'people/56' => {
        controller => 'people',
        action     => 'show',
        id         => 56,
    },
    'people/56/edit' => {
        controller => 'people',
        action     => 'edit',
        id         => 56,
    },
    'people/56/remove' => {
        controller => 'people',
        action     => 'remove',
        id         => 56,
    },
    'people/56/update' => {
        controller => 'people',
        action     => 'update',
        id         => 56,
    },
},
"... our routes are solid");

done-testing;
