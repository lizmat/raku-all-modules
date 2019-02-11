use v6;

use Test;
use Test::Path::Router;

use Path::Router;

=for pod
This test shows how nil in mapping used to break things doesn't anymore.

my Path::Router $router .= new;
isa-ok($router, 'Path::Router');

$router.add-route: 'blog', %(
    defaults => %(
        a => 'b',
        c => 'd',
    ),
);

mapping-ok($router, %(a => 'b', c => 'd', e => Nil), 'nil mapping does not break anything');

done-testing;
