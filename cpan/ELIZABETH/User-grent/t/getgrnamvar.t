use v6.c;
use Test;
use User::grent :FIELDS;

plan 15;

my int $groupid = +$*GROUP;
ok $groupid > 0, 'did we get a group ID';

my $groupname = ~$*GROUP;
ok $groupname ~~ m/^ \w+ /, 'did we get a name';

getgrgid($groupid);
is $gr_name, $groupname, 'did we get the groupname in this struct by gid';
is $gr_gid,  $groupid,   'did we get the groupid in this struct by gid';

getgrnam($groupname);
is $gr_name, $groupname, 'did we get the groupname in this struct by name';
is $gr_gid,  $groupid,   'did we get the groupid in this struct by name';

getgrent;
ok $gr_name, 'did we get anything from getgrent';

my int $seen;
my $seen_me;
while defined($gr_gid) {
    $seen_me = True if $gr_name eq $groupname && $gr_gid == $groupid;
    getgrent;
    ++$seen;
}

ok $seen_me, 'did we see ourselves';
is setgrent, 1, 'did we return the undocumented 1';

getgrent;
while defined($gr_gid) { --$seen; getgrent }
is $seen, 0, 'did we get the same number of entries the 2nd time';
is endgrent, 1, 'did we return the undocumented 1';

getgrnam("thisnameshouldnotexist"),
nok defined($gr_name), 'non-existing name';
getgrgid(9999);
nok defined($gr_gid), 'non-existing gid';

getgr(+$*GROUP);
is $gr_name, ~$*GROUP, 'does int lookup give name';
getgr(~$*GROUP);
is $gr_gid,  +$*GROUP, 'does name lookup give int';

# vim: ft=perl6 expandtab sw=4
