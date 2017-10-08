
unit module Pekyll::Routers;

sub router_id($route) is export { $route }

sub ext2html($route) is export { $route.subst(/\.\w+$/, '.html') }

