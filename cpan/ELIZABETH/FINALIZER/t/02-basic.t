use v6.c;
use Test;

use lib BEGIN $?FILE.IO.parent;
use Frobnicate;

plan 6;

my $finalized;
{
    use FINALIZER;
    dbiconnect( { $finalized = True } );
    nok $finalized, 'did we not finalize yet inside scope';
}
ok $finalized, 'did we finalize when leaving scope';

{
    use FINALIZER;
    $finalized = 0;
    my $frobnicator = dbiconnect( { ++$finalized } );
    is $finalized, 0, 'did we not finalize yet inside scope';
    is +$*FINALIZER.blocks, 1, 'do we have a finalizer block for this';

    $frobnicator.finalize;

    is $finalized, 1, 'did we finalize';
    is +$*FINALIZER.blocks, 0, 'is the finalizer block gone';
}

# vim: ft=perl6 expandtab sw=4
