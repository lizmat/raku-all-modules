use v6;

use Test;
use CompUnit::DynamicLib;

plan 6;

sub capture-repo { $*REPO.repo-chain.map({ .id }).join(',') }

{
    my $repo-before = capture-repo;
    my $pkg = require-from('t/lib', 'Foo::Bar::Baz');
    is $pkg, ::('Foo::Bar::Baz'), 'dynamic load returns package';
    is ::('Foo::Bar::Baz').qux, 42, 'loaded Foo::Bar::Baz dyanmically';
    my $repo-after = capture-repo;
    is $repo-after, $repo-before, '$*REPO appears the same before and after';
}

use-lib-do 't/lib', {
    require ::('Foo');
    require ::('Bar');
}

{
    my $repo-before = capture-repo;
    ok ::('Foo').loaded, 'loaded Foo';
    ok ::('Bar').loaded, 'loaded Bar';
    my $repo-after = capture-repo;
    is $repo-after, $repo-before, '$*REPO appears the same before and after';
}
