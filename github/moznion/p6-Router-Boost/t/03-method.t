use v6;
use Test;
use Router::Boost::Method;

my $r = Router::Boost::Method.new();
$r.add(['GET'],  '/a', 'g');
$r.add(['POST'], '/a', 'p');
$r.add([],       '/b', 'any');
$r.add(['GET'],  '/c', 'get only');
$r.add(['GET', 'HEAD'],  '/d', 'get/head');
$r.add(['GET'], '/capture/{id:\d ** 3}', 'capture');

subtest {
    is-deeply $r.match('GET', '/'), {};
}, 'GET /';

subtest {
    my $matched = $r.match('GET', '/a');
    is $matched<stuff>, 'g';
    is-deeply $matched<captured>, {};
    is $matched<is-method-not-allowed>, False;
    is-deeply $matched<allowed-methods>, [];
}, 'GET /a';

subtest {
    my $matched = $r.match('POST', '/a');
    is $matched<stuff>, 'p';
    is-deeply $matched<captured>, {};
    is $matched<is-method-not-allowed>, False;
    is-deeply $matched<allowed-methods>, [];
}, 'POST /a';

subtest {
    my $matched = $r.match('HEAD', '/a');
    ok !$matched<stuff>.defined;
    is-deeply $matched<captured>, {};
    is $matched<is-method-not-allowed>, True;
    is-deeply $matched<allowed-methods>, ['GET', 'POST'];
}, 'HEAD /a';

subtest {
    my $matched = $r.match('POST', '/b');
    is $matched<stuff>, 'any';
    is-deeply $matched<captured>, {};
    is $matched<is-method-not-allowed>, False;
    is-deeply $matched<allowed-methods>, [];
}, 'GET /b';

subtest {
    my $matched = $r.match('GET', '/c');
    is $matched<stuff>, 'get only';
    is-deeply $matched<captured>, {};
    is $matched<is-method-not-allowed>, False;
    is-deeply $matched<allowed-methods>, [];
}, 'GET /c';

subtest {
    my $matched = $r.match('POST', '/c');
    ok !$matched<stuff>.defined;
    is-deeply $matched<captured>, {};
    is $matched<is-method-not-allowed>, True;
    is-deeply $matched<allowed-methods>, ['GET'];
}, 'POST /c';

subtest {
    subtest {
        my $matched = $r.match('GET', '/d');
        is $matched<stuff>, 'get/head';
    }, 'GET';
    subtest {
        my $matched = $r.match('HEAD', '/d');
        is $matched<stuff>, 'get/head';
    }, 'HEAD';
    subtest {
        my $matched = $r.match('POST', '/d');
        ok !$matched<stuff>.defined;
        is-deeply $matched<allowed-methods>, ['GET', 'HEAD'];
    }, 'POST';
}, '/d';

subtest {
    my $matched = $r.match('GET', '/capture/123');
    is $matched<stuff>, 'capture';
    is-deeply $matched<captured>, {
        id => '123',
    };
    is $matched<is-method-not-allowed>, False;
    is-deeply $matched<allowed-methods>, [];
}, 'GET /capture/{id:\d ** 3}';

subtest {
    is-deeply $r.routes, [
        [['GET'], '/a', 'g'],
        [['POST'], '/a', 'p'],
        [[], '/b', 'any'],
        [['GET'], '/c', 'get only'],
        [['GET', 'HEAD'], '/d', 'get/head'],
        [['GET'], '/capture/{id:\d ** 3}', 'capture'],
    ];
}, 'Test for routes';

done-testing;

