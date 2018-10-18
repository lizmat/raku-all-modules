use v6;
use String::CamelCase;
use Test;

subtest {

    is camelize('foo_bar'), 'FooBar';
    is camelize('foo-bar'), 'FooBar';
    is camelize('FOO_BAR'), 'FooBar';
    is camelize('FOO-Bar'), 'FooBar';

    subtest {

        is camelize('hoge_muge'),        'HogeMuge';
        is camelize('ad'),               'Ad';
        is camelize('year_bbs'),         'YearBbs';
        is camelize('client_ad_client'), 'ClientAdClient';
        is camelize('ad_client'),        'AdClient';

    }, 'Taken from p5 String::CamelCase';

}, 'Test camelize';

done-testing;
