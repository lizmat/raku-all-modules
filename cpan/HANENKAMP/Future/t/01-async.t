#!/usr/bin/env perl6
use v6;

use Test;
use Future;

subtest 'Basic Then' => {
    my $f = Future.start({ 41 }).then(* + 1);
    is await($f), 42;
};

subtest 'Basic Catch' => {
    my $f = Future.start({ die "foo" }).catch({ 42 });
    is await($f), 42;
}

subtest 'Basic Last' => {
    my $f = Future.start({ 42 }).last({ 43 });
    is await($f), 42;
}

done-testing;
