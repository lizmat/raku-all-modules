#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Method::Modifiers;

plan 10;

my $called-chars = False;
my $orig = before(Str, 'chars', { $called-chars = True; });
my $chars = "hello".chars;

is $chars, 5, 'chars returned properly';
ok $called-chars, 'wrapper was called';
ok $orig.restore, 'we restored the original';

$called-chars = False;
$orig = after(Str, 'chars', { $called-chars = True });
$chars = "test".chars;
is $chars, 4, 'chars returned properly';
ok $called-chars, 'wrapper was called';
ok $orig.restore, 'we restored the original';

$orig = around(Str, 'chars', { '<chars>'~callsame~'</chars>' });
$chars = "goodbye".chars;
is $chars, '<chars>7</chars>', 'overridden chars returned properly';
ok $orig.restore, 'we restored the original';

$called-chars = False;
$chars = "mu".chars;
is $chars, 2, 'original chars returns properly';
ok !$called-chars, 'no former modifiers being called';
