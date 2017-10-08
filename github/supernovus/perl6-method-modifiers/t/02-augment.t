#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Method::Modifiers::Augment;

plan 10;

skip-rest('currently not working in rakudo due to rakudobug');
exit;

my $called-chars = False;
my $orig = Str.before('chars', { $called-chars = True; });
my $chars = "hello".chars;

is $chars, 5, 'chars returned properly';
ok $called-chars, 'wrapper was called';
ok $orig.restore, 'we restored the original';

$called-chars = False;
$orig = Str.after('chars', { $called-chars = True });
$chars = "test".chars;
is $chars, 4, 'chars returned properly';
ok $called-chars, 'wrapper was called';
ok $orig.restore, 'we restored the original';

$orig = Str.around('chars', { '<chars>'~callsame~'</chars>' });
$chars = "goodbye".chars;
is $chars, '<chars>7</chars>', 'overridden chars returned properly';
ok $orig.restore, 'we restored the original';

$called-chars = False;
$chars = "mu".chars;
is $chars, 2, 'original chars returns properly';
ok !$called-chars, 'no former modifiers being called';

