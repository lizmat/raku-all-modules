#!/usr/bin/env perl6

use v6.c;

use Test;
plan 5;

use Manifesto;

my $manifesto = Manifesto.new;

my $p1 = Promise.new;
my $p2 = $p1.then({  die "boom" });

$manifesto.add-promise($p2);

my $no-break = True;

$manifesto.Supply.tap(-> $v {
    $no-break = False;
});

my $empty = False;

my $p-wait = Promise.new;

$manifesto.empty.tap({
    $p-wait.keep: "empty";
    $empty = True;
});

my $exception = False;
$manifesto.exception.tap({
    $exception = True;
});

is $manifesto.promises.elems, 1, "got the promise";

$p1.keep: True;

await Promise.anyof($p-wait, Promise.in(1));

is $manifesto.promises.elems, 0, "haven't got the promise anymore";
ok $empty, "got the empty event";
ok $no-break, "didn't get the event from the broken promise";
ok $exception, "but got one on the exception supply";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
