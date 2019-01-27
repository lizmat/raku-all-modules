#!perl6

use v6;

use Test;

use Unix::Groups;

my $obj;

lives-ok { $obj = Unix::Groups.new }, "create an object";

isa-ok $obj, Unix::Groups, "and its the right sort of thing";
ok $obj.groups.elems, "got some groups";
isa-ok $obj.groups[0], Unix::Groups::Group, "and it's a group";

my $group;

ok $group = $obj.group-by-name($obj.groups[0].name), "group-by-name";
ok $group === $obj.groups[0], "and it's the right one";
is $group.gid, $obj.groups[0].gid, "and just check the ids";

ok $group = $obj.group-by-id($obj.groups[0].gid), "group-by-id";
ok $group === $obj.groups[0], "and it's the right one";
is $group.name, $obj.groups[0].name, "and just check the names";

my @groups;

# Add the user to some groups as don't know the target system
for $obj.groups.pick(3) -> $group {
    $group.users.push($*USER.Str);
}

lives-ok { @groups = $obj.groups-for-user($*USER.Str) }, "groups-for-user";

ok @groups.elems >= 3, "got at least the number of groups we expected";

for @groups -> $group {
    ok ?$group.users.grep($*USER.Str), "and the group '{$group.name}' has the user";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
