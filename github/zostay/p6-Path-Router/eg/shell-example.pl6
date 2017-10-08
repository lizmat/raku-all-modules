#!/usr/bin/env perl6

use v6;
use lib "lib";
use Path::Router;
use Path::Router::Shell;

subset PosInt of Int where * > 0;

my $router = Path::Router.new;
$router.add-route('/a/b');
$router.add-route('/a/b/:c', {
    validations => {
        c => PosInt,
    },
});

Path::Router::Shell.new(:$router).shell;
