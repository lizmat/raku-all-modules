use v6;
use Test;
plan 44;

use Config::INI;

my $first = Q {
foo=bar
some=thing
};

my %f = Config::INI::parse($first);

pass 'first config parsed';

is %f<_><foo>, 'bar', '1.1 ok';
is %f<_><some>, 'thing', '1.2 ok';

my $second = Q {
    foo = bar
 some=  thing
};

my %s = Config::INI::parse($second);

pass 'second config parsed';

is %s<_><foo>, 'bar', '2.1 ok';
is %s<_><some>, 'thing', '2.2 ok';

my $third = Q {
    foo = bar ; comment
    another= thing;commie
};

my %t = Config::INI::parse($third);

pass 'third config parsed';

is %t<_><foo>, 'bar', '3.1 ok';
is %t<_><another>, 'thing', '3.2 ok';

my $fourth = Q {
    foo = bar
[core]
inur=section
messing=with
ur=keyvals

[more]
optimized=fun
dragon=storm

};

my %fo = Config::INI::parse($fourth);

pass 'forth config parsed';

is %fo<_><foo>, 'bar', '4.1 ok';
is %fo<core><inur>, 'section', '4.2 ok';
is %fo<core><messing>, 'with', '4.3 ok';
is %fo<core><ur>, 'keyvals', '4.4 ok';
is %fo<more><optimized>, 'fun', '4.5 ok';
is %fo<more><dragon>, 'storm', '4.6 ok';

my $fifth = Q {
    emptykey = 
    another = withvalue

    [section with space]
    whynot=;comment
    why yes=because
};

my %fi = Config::INI::parse($fifth);

pass 'fifth config parsed';

is %fi<_><emptykey>, '', '5.1 ok';
is %fi<_><another>, 'withvalue', '5.2 ok';
is %fi{'section with space'}<whynot>, '', '5.3 ok';
is %fi{'section with space'}{'why yes'}, 'because', '5.4 ok';

my $sixth = Q {
root=something

[section]
one=two
Foo=Bar
this=Your Mother!
blank=
moo=kooh

[Section Two]
something else=blah
 remove = whitespace
};

my %si = Config::INI::parse($sixth);

pass 'sixth config parsed';

is %si<_><root>, 'something', '6.1 ok';
is %si<section><one>, 'two', '6.2 ok';
is %si<section><Foo>, 'Bar', '6.3 ok';
is %si<section><this>, 'Your Mother!', '6.4 ok';
is %si<section><blank>, '', '6.5 ok';
is %si<section><moo>, 'kooh', '6.6 ok';
is %si{'Section Two'}{'something else'}, 'blah', '6.7 ok';
is %si{'Section Two'}<remove>, 'whitespace', '6.8 ok';

my $seventh = Q {
[section]
one=two
Foo=Bar
this=Your Mother!
blank=
moo=kooh

[Section Two]
something else=blah
 remove = whitespace
};

my %se = Config::INI::parse($seventh);

pass 'seventh config parsed';

is %si<section><one>, 'two', '7.1 ok';
is %si<section><Foo>, 'Bar', '7.2 ok';
is %si<section><this>, 'Your Mother!', '7.3 ok';
is %si<section><blank>, '', '7.4 ok';
is %si<section><moo>, 'kooh', '7.5 ok';
is %si{'Section Two'}{'something else'}, 'blah', '7.6 ok';
is %si{'Section Two'}<remove>, 'whitespace', '7.7 ok';

my $eight = Q {
[empty section]
};

my %ei = Config::INI::parse($eight);

pass 'eight config parsed';
is-deeply %ei, { 'empty section' => {} };

my $ninth = Q {
[Hello... world]
};

my %ni = Config::INI::parse($ninth);

pass 'ninth config parsed';
is-deeply %ni, { 'Hello... world' => {} };

my $tenth = q{t/test00.ini};

my %te = Config::INI::parse_file($tenth);

pass 'tenth config (file) parsed';
is-deeply %te, {
    '_' => {
        foo => 'comma, separated, values',
        ano => 'ther',
        ki  => 'waliu',
        asd => 'esd'
    }
};
