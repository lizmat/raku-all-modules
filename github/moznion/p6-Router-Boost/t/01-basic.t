use v6;
use Test;
use Router::Boost;

my $r = Router::Boost.new();
$r.add('/',                         'dispatch_root');
$r.add('/entrylist',                'dispatch_entrylist');
$r.add('/:user',                    'dispatch_user');
$r.add('/:user/{year}',             'dispatch_year');
$r.add('/:user/{year}/{month:\d+}', 'dispatch_month');
$r.add('/download/*',               'dispatch_download');

is-deeply $r.match('/'), {
    stuff    => 'dispatch_root',
    captured => {},
};

is-deeply $r.match('/entrylist'), {
    stuff    => 'dispatch_entrylist',
    captured => {},
};

is-deeply $r.match('/gfx'), {
    stuff    => 'dispatch_user',
    captured => {
        user => 'gfx'
    },
};

is-deeply $r.match('/gfx/2013/12'), {
    stuff    => 'dispatch_month',
    captured => {
        user  => 'gfx',
        year  => '2013',
        month => '12',
    },
};

is-deeply $r.match('/gfx/2013/gorou'), {};

is-deeply $r.match('/download/foo/bar/baz.zip'), {
    stuff => 'dispatch_download',
    captured => {
        '*' => 'foo/bar/baz.zip',
    },
};

done-testing;

