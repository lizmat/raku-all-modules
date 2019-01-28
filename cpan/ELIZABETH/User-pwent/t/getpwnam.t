use v6.c;
use Test;
use User::pwent;

plan 17;

my int $userid  = +$*USER;
my int $groupid = +$*GROUP;
ok $userid > 0, "we got user ID $userid";

my $username = getpwuid($userid).name;
ok $username ~~ m/^ \w+ /, "we got user name $username";

my $pw = getpwuid($userid);
is $pw.name, $username, 'did we get the username in this struct by uid';
is $pw.uid,  $userid,   'did we get the userid in this struct by uid';
is $pw.gid,  $groupid,  'did we get the groupid in this struct by uid';

$pw = getpwnam($username);
is $pw.name, $username, 'did we get the username in this struct by name';
is $pw.uid,  $userid,   'did we get the userid in this struct by name';
is $pw.gid,  $groupid,  'did we get the groupid in this struct by name';

$pw = getpwent;
ok $pw ~~ User::pwent, 'did we get anything from getpwent';

my int $seen = 1;
my $seen_me;
while getpwent() -> $pw {
    $seen_me = True if $pw.name eq $username && $pw.uid == $userid;
    ++$seen;
}
ok $seen_me, 'did we see ourselves';
is setpwent, 1, 'did we return the undocumented 1';

--$seen while getpwent;
is $seen, 0, 'did we get the same number of entries the 2nd time';
is endpwent, 1, 'did we return the undocumented 1';

is getpwnam("thisnameshouldnotexist"), Nil, 'non-existing name';
is getpwuid(9999), Nil, 'non-existing uid';

is getpw(+$*USER).name, ~$*USER, 'does int lookup give name';
is getpw(~$*USER).uid,  +$*USER, 'does name lookup give int';

# vim: ft=perl6 expandtab sw=4
