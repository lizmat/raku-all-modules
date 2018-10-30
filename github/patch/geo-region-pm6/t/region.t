use lib 'lib';

use Test;
use Geo::Region;

plan 8;

subtest {
    plan 2;
    my $r = Geo::Region.new;

    nok       $r.is-within(1),       'not within world';
    is-deeply $r.countries, ().list, 'no countries';
}, 'default empty region';

subtest {
    plan 2;
    my $r = Geo::Region.new(include => []);

    nok       $r.is-within(1),       'not within world';
    is-deeply $r.countries, ().list, 'no countries';
}, 'explicit empty region';

subtest {
    plan 44;
    my $r = Geo::Region.new(include => 1);

    ok $r.is-within(1),    'region is within itself';
    ok $r.contains(1),     'region contains itself';
    ok $r.contains(2),     'region contains subregion';
    ok $r.contains(11),    'region contains subsubregion';
    ok $r.contains('011'), 'region contains subsubregion string';
    ok $r.contains('BF'),  'region contains country';
    ok $r.contains('bf'),  'region contains lowercase country';
    ok $r.contains(all <1 2 11 BF>), 'region contains junctive all';
    ok $r.contains(any <1 ZZ>),      'region contains junctive any';

    is        $r.countries.elems, 256,              'expected # of countries';
    cmp-ok    $r.countries.join, '~~', /^<:Lu>+$/,  'countries are uppercase';
    is-deeply $r.countries, $r.countries.sort.list, 'countries are sorted';

    # these codes are: 1. deprecated; 2. grouping; and 3. aliases
    for <
        AN BU CS DD FX NT QU SU TP YD YU ZR
        EU QO
        QU UK
    > -> $code {
        ok $r.contains($code),        "contains code $code";
        isnt $code, $r.countries.any, "does not return code $code";
    }
}, 'World (001) superregion';

subtest {
    plan 12;
    my $r = Geo::Region.new(include => 'MX');

    ok $r.contains('MX'),  'country contains itself';
    ok $r.contains('mx'),  'country contains itself, case insensitive';
    ok $r.is-within('MX'), 'country is within itself';
    ok $r.is-within('mx'), 'country is within itself, case insensitive';
    ok $r.is-within(13),   'within Central America (013) region';
    ok $r.is-within(19),   'within Americas (019) region';
    ok $r.is-within(1),    'within World (001) region';
    ok $r.is-within(3),    'within North America (003) grouping';
    ok $r.is-within(419),  'within Latin America (419) grouping';
    ok $r.is-within(all <1 3 13 19 419 MX>), 'within junctive all';
    ok $r.is-within(any <MX US>),            'within junctive any';
    is-deeply $r.countries, <MX>.list, 'only one country in a country';
}, 'Mexico (MX) country';

subtest {
    plan 7;
    my $r = Geo::Region.new(include => [143, 'RU']);

    ok  $r.contains('143'), 'contains included region';
    ok  $r.contains('RU'),  'contains included country';
    ok  $r.contains('KZ'),  'contains country within any included region';
    ok  $r.is-within(1),    'within regions shared by all included';
    nok $r.is-within(143),  'not within either included region';
    nok $r.is-within('RU'), 'not within either included region';

    is-deeply(
        $r.countries,
        <KG KZ RU TJ TM UZ>.list,
        'return all countries within any included'
    );
}, 'Central Asia (143) + Russia (RU)';

subtest {
    plan 5;
    my $r = Geo::Region.new(include => 150, exclude => 'EU');

    ok  $r.contains('CH'), 'contains countries !within excluded region';
    ok  $r.contains(155),  'contains regions within included region';
    nok $r.contains('EU'), '!contains excluded region';
    nok $r.contains('FR'), '!contains countries within excluded region';

    is-deeply $r.countries, <
        AD AL AX BA BY CH FO GG GI IM IS JE LI
        MC MD ME MK NO RS RU SJ SM UA VA XK
    >.list, 'return all countries within included except excluded';
}, 'Europe (150) − European Union (EU)';

subtest {
    plan 6;
    my $r = Geo::Region.new(include => 'QU');

    ok $r.is-within('EU'), 'within official region';
    ok $r.is-within('QU'), 'within deprecated region';
    ok $r.contains('EU'),  'contains official region';
    ok $r.contains('QU'),  'contains deprecated region';
    ok $r.contains('GB'),  'contains official country';
    ok $r.contains('UK'),  'contains deprecated country';
}, 'deprecated alias QU for EU';

subtest {
    plan 5;
    my $r = Geo::Region.new(include => 'UK');

    ok $r.is-within('GB'), 'within official country';
    ok $r.is-within('UK'), 'within deprecated country';
    ok $r.contains('GB'),  'contains official country';
    ok $r.contains('UK'),  'contains deprecated country';
    is-deeply $r.countries, <GB>.list, 'only official countries';
}, 'deprecated alias UK for GB';
