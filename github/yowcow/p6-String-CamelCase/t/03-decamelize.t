use v6;
use String::CamelCase;
use Test;

subtest {

    subtest {

        is decamelize('HogeMuge'),       'hoge-muge';
        is decamelize('AD'),             'ad';
        is decamelize('YearBBS'),        'year-bbs';
        is decamelize('ClientAdClient'), 'client-ad-client';
        is decamelize('ADClient'),       'ad-client';

    }, 'Taken from p5 String::CamelCase';

    is decamelize('FooBar'), 'foo-bar', 'FooBar => foo-bar';
    is decamelize('FooBar', '_'), 'foo_bar', 'FooBar => foo_bar';
    is decamelize('FOOBAR'), 'foobar',  'FOOBAR => foobar';
    is decamelize('FOOBar'), 'foo-bar', 'FOOBar => foo-bar';
    is decamelize('fooBar'), 'foo-bar', 'fooBar => foo-bar';
    is decamelize('fooBAR'), 'foo-bar', 'fooBAR => foo-bar';
    is decamelize('123fooBar'), '123foo-bar', '123fooBar => 123foo-bar';
    is decamelize('ClADClHoge'), 'cl-ad-cl-hoge', 'ClADClHoge => cl-ad-cl-hoge';

}, 'Test decamelize';

done-testing;
