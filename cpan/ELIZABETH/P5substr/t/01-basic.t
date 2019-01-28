use v6.c;
use Test;
use P5substr;

plan 19;

ok defined(::('&substr')),          'is &substr imported?';
ok !defined(P5substr::{'&substr'}), 'is &substr externally NOT accessible?';

# tests based on perldoc -f substr
{
    my $s = 'The black cat climbed the green tree';
    is substr($s,   4,   5), 'black',                  'positive length';
    is substr($s,   4, -11), 'black cat climbed the',  'negative length';
    is substr($s,  14     ), 'climbed the green tree', 'no length';
    is substr($s,  -4     ), 'tree',                   'negative offset';
    is substr($s,  -4,   2), 'tr',                     'neg offset, pos length';
    is substr($s, -10,  -5), 'green',                  'neg offset, neg length';

    is substr($s, 14, 7, "jumped from"), 'climbed',    'setting with 4 arg';
    is $s, 'The black cat jumped from the green tree', 'result of 4 args';
}

{
    my $name = 'fred';
    is (substr($name, 4) = 'dy'), 'dy', 'using as lvalue after';
    is $name, 'freddy',                 'did we get a freddy';
    is substr($name, 6, 2), '',         'offset at/after end of string';

    {
        my $caught;
        CATCH { $caught = True; .resume }
        substr($name,7) = 'gap';
        ok $caught, 'did we get an exception on lvalue out of range';
    }
}

{
    my $x = '1234';
    with substr($x,1,2) {
        $_ = 'a';
        is $x, "1a4",   'using positive proxy first time';
        $_ = 'xyz';
        is $x, '1xyz4', 'using positive proxy second time';
        $x = '56789';
        $_ = 'pq';
        is $x, '5pq9',  'using positive proxy third time';
    }
}

{
    my $x = '1234';
    with substr($x, -3, 2) {
        $_ = 'a';
        is $x, "1a4",   'using negative proxy first time';
        $x = 'abcdefg';
        is $_, "f",     'using negative proxy second time';
    }
}

# vim: ft=perl6 expandtab sw=4
