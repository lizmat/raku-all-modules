#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;
use Path::Router;

my $router = Path::Router.new;

$router.add-route('/', (
    defaults => {
        controller => 'root',
        action     => 'index',
    }
));

$router.add-route('/name/?:first', (
    defaults => {
        controller => 'name',
    },
));

$router.add-route('/:name', (
    defaults => {
        controller => 'root',
        action     => 'hello',
    },
));

mapping-is(
    $router,
    {
        controller => 'root',
        action     => 'index',
    },
    '',
    'return "" for /',
);

mapping-is(
    $router,
    {
        controller => 'root',
        action     => 'bogus',
    },
    Str,
    'return Str for bogus mapping',
);

mapping-is(
    $router,
    {
        name       => 'world',
    },
    'world',
    'match with only component variables',
);

mapping-is(
    $router,
    {
        first      => 'Sally',
    },
    'name/Sally',
    'match with only optional component variables',
);

mapping-is(
    $router,
    {
        controller => 'root',
        action     => 'hello',
        name       => 'world',
    },
    'world',
    'match with extra variables',
);

mapping-is(
    $router,
    {
        controller => 'root',
        name       => 'world',
    },
    'world',
    'match with partial defaults',
);

mapping-is(
    $router,
    {
        controller => 'root',
        action     => 'hello',
    },
    Str,
    'do not match with missing component variable',
);

done;
