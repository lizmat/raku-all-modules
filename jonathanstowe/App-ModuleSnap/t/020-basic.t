#!perl6

use v6.c;

use Test;

use App::ModuleSnap;

my @dists;

lives-ok { @dists = App::ModuleSnap.get-dists },"get-dists";
ok @dists.elems > 0, "must have some dists";
ok all(@dists) ~~ Distribution, "and the are all Distributions";
nok @dists.grep({$_.name eq 'CORE'}), "and we didn't get CORE";
ok @dists.grep({$_.name eq 'META6'}), "but we did get META6";
my $meta;
lives-ok { $meta = App::ModuleSnap.get-meta(name => 'Foo::Bar') }, "get-meta";
isa-ok $meta, META6, "and it is a META6";
is $meta.name, 'Foo::Bar', "and the name is right";
is $meta.perl-version, $*PERL.version, "perl version is correct";
is $meta.depends.elems, @dists.elems, "got the right number of dists";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
