use v6.c;
use Test;

BEGIN my @vars = <$frob @mung %seen>;
BEGIN plan 2 * @vars + 1;

use vars @vars;

BEGIN ok ::{$_}:exists, "did we get an export for $_ at BEGIN" for @vars;

ok $frob.VAR ~~ Scalar, 'is $frob a scalar container';
ok @mung     ~~ Array,  'is @mung an Array';
ok %seen     ~~ Hash,   'is %seen a Hash';

{
    my $exception-seen;
    EVAL 'use vars <zinkfnob>';
    CATCH { default {
        $exception-seen = True if $_.Str.contains('zinkfnob');
        .resume
    } }
    ok $exception-seen, 'did we see an exception with zinkfnob';
}

# vim: ft=perl6 expandtab sw=4
