#!/usr/bin/env perl6
use v6;

use Test;
use Future;

subtest 'Nested Promise' => {
    my $f = Future.start({ start { 42 } });
    is await($f), 42;
}

subtest 'Nested Future' => {
    my $f = Future.start({ Future.start({ 42 }) });
    is await($f), 42;
}

subtest 'Wrapped Promise' => {
    my $f = Future.start({ %(p => start { 42 }) });
    isa-ok await($f)<p>, Promise;
}

done-testing;
