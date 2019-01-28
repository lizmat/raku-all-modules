use v6.c;
use Test;

use WriteOnceHash;

plan 26;

# normal hash
my %woh is WriteOnceHash = a => 42;
isa-ok %woh, WriteOnceHash;
is %woh<a>, 42, 'did the initialization work';

is (%woh<b> = 48), 48, 'does assignment pass value through';
is %woh<b>,        48, 'did the assignment work';

{
    my $caught = False;
    CATCH {
        $caught = True;
        when X::Hash::WriteOnce {
            pass 'threw the correct exception';
            .resume;
        }
        default {
            flunk 'did not throw correct exception';
            .resume
        }
    }
    %woh<a> = 1;
    ok $caught, 'did we get an exception';
    is %woh<a>, 42, 'did the assignment fail';

    $caught = False;
    %woh<b> = 1;
    ok $caught, 'did we get an exception';
    is %woh<b>, 48, 'did the assignment fail';

    $caught = False;
    %woh<b>:delete;
    ok $caught, 'did we get an exception';
    is %woh<b>, 48, 'did the removal fail';
}

# object hash with mixed in role
my %owoh{Any} does WriteOnce = 42 => "a";
does-ok %owoh, WriteOnce;
is %owoh{42}, "a", 'did the initialization work';

is (%owoh{48} = "b"), "b", 'does assignment pass value through';
is %owoh{48},         "b", 'did the assignment work';

{
    my $caught = False;
    CATCH {
        $caught = True;
        when X::Hash::WriteOnce {
            pass 'threw the correct exception';
            .resume;
        }
        default {
            flunk 'did not throw correct exception';
            .resume
        }
    }
    %owoh{42} = "c";
    ok $caught, 'did we get an exception';
    is %owoh{42}, "a", 'did the assignment fail';

    $caught = False;
    %owoh{48} = "c";
    ok $caught, 'did we get an exception';
    is %owoh{48}, "b", 'did the assignment fail';

    $caught = False;
    %owoh{48}:delete;
    ok $caught, 'did we get an exception';
    is %owoh{48}, "b", 'did the removal fail';
}

# vim: ft=perl6 expandtab sw=4
