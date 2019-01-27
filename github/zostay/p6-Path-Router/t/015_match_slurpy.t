use v6;

use Test;
use Test::Path::Router;

use Path::Router;

my Path::Router $router .= new;
isa-ok($router, Path::Router);

# create some routes

$router.add-route('page/:controller/+:path', %(
    defaults => %(
        controller => 'page',
    ),
));

subset Colorful of Str
    where 'red' | 'blue' | 'green' | 'yellow' | 'purple' | 'orange';
subset ColorfulList of List
    where *.all ~~ Colorful;

$router.add-route('info/*:info', %(
    defaults => %(
        info => [ 'not', 'colorful' ],
    ),
    validations => %(
        #info => ColorfulList,
    ),
));

routes-ok($router, {
    'page/page/a/b/c' => {
        controller => 'page',
        path       => <a b c>
    },
    'page/user/x' => {
        controller => 'user',
        path       => ('x',),
    },
    'page/steve/x/y' => {
        controller => 'steve',
        path       => <x y>,
    },
});

routes-ok($router, %(
    'info' => %(
        info => <not colorful>.Array,
    ),
    'info/blue' => %(
        info => ('blue',),
    ),
    'info/blue/orange/green' => %(
        info => <blue orange green>,
    ),
));

throws-like(
    { $router.add-route('*:info/+:things') },
    X::Path::Router::BadSlurpy,
    "... this dies correctly"
);

done-testing;
