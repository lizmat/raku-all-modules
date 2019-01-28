use v6.c;
use Test;
use User::grent;

plan 17;

my int $groupid = +$*GROUP;
ok $groupid > 0, 'did we get a group ID';

my $groupname = getgrgid($groupid).name;
ok $groupname ~~ m/^ \w+ /, 'did we get a name';

my $gr = getgrgid($groupid);
is $gr.name, $groupname, 'did we get the groupname in this struct by gid';
is $gr.gid,  $groupid,   'did we get the groupid in this struct by gid';
ok $gr.members ~~ List,  'did we get the members by gid';

$gr = getgrnam($groupname);
is $gr.name, $groupname, 'did we get the groupname in this struct by name';
is $gr.gid,  $groupid,   'did we get the groupid in this struct by name';
ok $gr.members ~~ List,  'did we get the members by gid';

$gr = getgrent;
ok $gr ~~ User::grent, 'did we get anything from getgrent';

my int $seen = 1;
my $seen_me;
while getgrent() -> $gr {
    $seen_me = True if $gr.name eq $groupname && $gr.gid == $groupid;
    ++$seen;
}

ok $seen_me, 'did we see ourselves';
is setgrent, 1, 'did we return the undocumented 1';

--$seen while getgrent;
is $seen, 0, 'did we get the same number of entries the 2nd time';
is endgrent, 1, 'did we return the undocumented 1';

is getgrnam("thisnameshouldnotexist"), Nil, 'non-existing name';
is getgrgid(9999), Nil, 'non-existing gid';

is getgr(+$*GROUP).name, ~$*GROUP, 'does int lookup give name';
is getgr(~$*GROUP).gid,  +$*GROUP, 'does name lookup give int';

# vim: ft=perl6 expandtab sw=4
