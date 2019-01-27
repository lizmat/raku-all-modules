use v6.c;
use Test;
use Acme::ಠ_ಠ;

plan 1;

{
    my $warned = False;
    ಠ_ಠ "too bad";

    CONTROL {
        when CX::Warn {
            $warned = True;
            .resume;
        }
    }
    ok $warned, 'did we warn';
}

# vim: ft=perl6 expandtab sw=4
