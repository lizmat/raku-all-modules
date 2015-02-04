use v6;
use Config::INI;
use Config::INI::Writer;
use Test;
plan 14;

ok 1, 'Modules loaded';

{
    my %hash =
    foo => 'bar',
    another => 'thing',
    section => {
        one => 'two',
        three => 4,
    },
    onemore => {
        why => 'not',
    };


    my $str = Config::INI::Writer::dump(%hash);

    ok 2, 'String dumped';

    my %new = Config::INI::parse($str);

    ok 3, 'String parsed';

    is %new<_><foo>, 'bar', 'content ok, 1/5';
    is %new<_><another>, 'thing', 'content ok, 2/5';
    is %new<section><one>, 'two', 'content ok, 3/5';
    is %new<section><three>, '4', 'content ok, 4/5';
    is %new<onemore><why>, 'not', 'content ok, 5/5';
}
{
    my %hash = section => { one => 'two', three => 4, },
               onemore => { why => 'not' };
    my $str = Config::INI::Writer::dump(%hash);

    ok 1, 'String dumped';

    my %new = Config::INI::parse($str);

    ok 1, 'String parsed';

    ok %new.keys ~~ <section onemore>;

    is %new<section><one>, 'two', 'content ok, 1/3';
    is %new<section><three>, '4', 'content ok, 2/3';
    is %new<onemore><why>, 'not', 'content ok, 3/3';
}

done;

# vim: ft=perl6
