#!perl6

use v6.c;

use Test;
use JSON::Fast;

use App::ModuleSnap;
use META6;

my @dists;

lives-ok { @dists = App::ModuleSnap.get-dists },"get-dists";
ok @dists.elems > 0, "must have some dists";
nok @dists.grep({$_.name eq 'CORE'}), "and we didn't get CORE";
my $meta;
lives-ok { $meta = App::ModuleSnap.get-meta(name => 'Foo::Bar') }, "get-meta";
isa-ok $meta, META6, "and it is a META6";
is $meta.name, 'Foo::Bar', "and the name is right";
is $meta.perl-version, $*PERL.version, "perl version is correct";
is $meta.depends.elems, @dists.elems, "got the right number of dists";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
