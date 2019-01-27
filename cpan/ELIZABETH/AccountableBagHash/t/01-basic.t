use v6.c;
use Test;

use AccountableBagHash;

plan 8;

my %b is AccountableBagHash = a => 42, b => 666;
isa-ok %b, AccountableBagHash;

is (%b<a> = 48), 48, 'does assignment pass value through';
is %b<a>,        48, 'did the assignment work';
is %b<a>++,      48, 'can we increment';
is %b<a>,        49, 'did the increment work';

{
    my $caught = False;
    CATCH {
        $caught = True;
        when X::BagHash::Accountable {
            pass 'threw the correct exception';
            .resume;
        }
        default {
            flunk 'did not throw correct exception';
            .resume
        }
    }
    %b<a> = -1;
    ok $caught, 'did we get an exception';
    is %b<a>, 49, 'did the assignment fail';
}

# vim: ft=perl6 expandtab sw=4
