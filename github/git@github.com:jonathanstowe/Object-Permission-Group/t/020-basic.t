#!perl6

use v6.c;
use Test;

use Unix::Groups;
use Object::Permission::Group;

isa-ok $*AUTH-USER, Object::Permission::Group, '$*AUTH-USER is set correctly';

my @groups = Unix::Groups.new.groups-for-user($*USER.Str).map(-> $g { $g.Str });

ok $*AUTH-USER.permissions.sort.list ~~ @groups.sort.list, "and the permissions are the same as the users groups";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
