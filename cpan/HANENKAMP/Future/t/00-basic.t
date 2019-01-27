#!/usr/bin/env perl6
use v6;

use Test;
use Future;

dies-ok { Future.new };
lives-ok { Promise.new };

subtest 'Future' => {
    my $f = Future.start: { 42 };
    does-ok $f, Future;
    is await($f), 42;
    is $f.result, 42;
    nok $f.is-pending;
    ok $f.is-fulfilled;
    nok $f.is-rejected;
}

subtest 'Promise to Future' => {
    my $p = Promise.new;
    isa-ok $p, Promise;

    my $f = Future.awaitable($p);
    does-ok $f, Future;

    ok $f.is-pending;
    nok $f.is-fulfilled;
    nok $f.is-rejected;

    $p.keep(42);
    is await($f), 42;
    is $f.result, 42;
    nok $f.is-pending;
    ok $f.is-fulfilled;
    nok $f.is-rejected;
}

subtest 'Value to Future' => {
    my $f = Future.immediate(42);

    does-ok $f, Future;

    is await($f), 42;
    is $f.result, 42;
    nok $f.is-pending;
    ok $f.is-fulfilled;
    nok $f.is-rejected;
}

subtest 'Exception to Future' => {
    my $f = Future.exceptional(X::AdHoc.new(:message<bad stuff>));

    does-ok $f, Future;

    dies-ok { await $f };
    dies-ok { $f.result };

    nok $f.is-pending;
    nok $f.is-fulfilled;
    ok $f.is-rejected;
}

done-testing;
