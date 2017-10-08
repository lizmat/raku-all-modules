#!perl6

use v6.c;

use Test;
use lib $*PROGRAM.parent.child('lib').Str;

use Country;

my $xml = $*PROGRAM.parent.child('data/country.xml').slurp;

my $in;

lives-ok { $in = Country.from-xml($xml) }, "from-xml with multiple embedded complex-types";
is $in.code, "FR", "code is right";
is $in.name.lang, 'en', 'name/@lang is right';
is $in.name.name, 'France', 'name is right';
is $in.population.date, "2000-01-01", 'population/@date is right';
is $in.population.figure, 60000000, 'population/@figure is right';
is $in.currency.code, 'EUR', 'currency/@code';
is $in.currency.name, 'Euro', 'currency/@name';

is $in.cities.elems, 5, "and we have five cities";

for $in.cities -> $city {
    isa-ok $city, Country::City, "city is the right thing";
    ok $city.code.defined, "city.code defined { $city.code }";
    ok $city.name.defined, "city.name defined { $city.name }";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
