use v6.c;
use Test;
use User::pwent;

plan 17;

my int $userid  = +$*USER;
my int $groupid = +$*GROUP;
ok $userid > 0, "we got user ID $userid";

my $username = ~$*USER;
ok $username ~~ m/^ \w+ /, "we got user name $username";

getpwuid($userid);
is $pw_name, $username, 'did we get the username in this struct by uid';
is $pw_uid,  $userid,   'did we get the userid in this struct by uid';
is $pw_gid,  $groupid,  'did we get the groupid in this struct by uid';

getpwnam($username);
is $pw_name, $username, 'did we get the username in this struct by name';
is $pw_uid,  $userid,   'did we get the userid in this struct by name';
is $pw_gid,  $groupid,  'did we get the groupid in this struct by name';

getpwent;
ok $pw_name, 'did we get anything from getpwent';

my int $seen;
my $seen_me;
while defined($pw_uid) {
    $seen_me = True if $pw_name eq $username && $pw_uid == $userid;
    getpwent;
    ++$seen;
}
ok $seen_me, 'did we see ourselves';
is setpwent, 1, 'did we return the undocumented 1';

getpwent;
while defined($pw_uid) { --$seen; getpwent }
is $seen, 0, 'did we get the same number of entries the 2nd time';
is endpwent, 1, 'did we return the undocumented 1';

getpwnam("thisnameshouldnotexist");
nok defined($pw_name), 'non-existing name';
getpwuid(9999);
nok defined($pw_uid), 'non-existing uid';

getpw(+$*USER);
is $pw_name, ~$*USER, 'does int lookup give name';
getpw(~$*USER).uid;
is $pw_uid,  +$*USER, 'does name lookup give int';

# vim: ft=perl6 expandtab sw=4
