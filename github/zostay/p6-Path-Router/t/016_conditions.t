use v6;

use Test;
use Test::Path::Router;

use Path::Router;

my Path::Router $router .= new;
isa-ok($router, Path::Router);

# create some routes

$router.add-route: 'one', %(
    conditions => %( foo => any('zip', 'zap') ),
    defaults => %( duh => 'x' ),
);

$router.add-route: 'one', %(
    conditions => %( foo => 'zeep' ),
    defaults => %( duh => 'y' ),
);

$router.add-route: 'one', %( defaults => %( duh => 'z' ) );

routes-ok($router, %(
    'one' => %(
        context => %( foo => 'zip' ),
        duh => 'x',
    ),
));

routes-ok($router, %(
    'one' => %(
        context => %( foo => 'zap' ),
        duh => 'x',
    ),
));

routes-ok($router, %(
    'one' => %(
        context => %( foo => 'zeep' ),
        duh => 'y',
    ),
));

routes-ok($router, %(
    'one' => %(
        context => %( foo => 'zipe' ),
        duh => 'z',
    ),
));

routes-ok($router, %(
    'one' => %(
        context => %( bar => 'whatever' ),
        duh => 'z',
    ),
));

done-testing;
