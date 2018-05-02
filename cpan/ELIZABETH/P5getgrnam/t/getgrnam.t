use v6.c;
use Test;
use P5getgrnam;

plan 12;

my int $groupid = +$*GROUP;
ok $groupid > 0, 'did we get a group ID';

my $groupname = getgrgid($groupid,:scalar);
ok $groupname ~~ m/^ \w+ /, 'did we get a name';

my @result = getgrgid($groupid);
is @result[0], $groupname, 'did we get the groupname in this struct by gid';
is @result[2], $groupid,   'did we get the groupid in this struct by gid';
ok @result[3] ~~ Str,      'did we get the members by gid';

is getgrnam($groupname, :scalar), $groupid, 'did we get the gid';
@result = getgrnam($groupname);
is @result[0], $groupname, 'did we get the groupname in this struct by name';
is @result[2], $groupid,   'did we get the groupid in this struct by name';
ok @result[3] ~~ Str,      'did we get the members by name';

@result = getgrent;
ok @result, 'did we get anything from getgrent';

my int $seen = 1;
my $seen_me;
while getgrent() -> @result {
    $seen_me = True if @result[0] eq $groupname && @result[2] == $groupid;
    ++$seen;
}
ok $seen_me, 'did we see ourselves';
endgrent;

--$seen while getgrent;
is $seen, 0, 'did we get the same number of entries the 2nd time';
endgrent;

# vim: ft=perl6 expandtab sw=4
