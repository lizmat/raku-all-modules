use v6.c;
use Test;
use P5getpwnam;

plan 17;

my int $userid = +$*USER;
ok $userid > 0, "we got user ID $userid";

my $username = getlogin;
if $username {
    ok $username ~~ m/^ \w+ /, 'did we get a name';
    is getpwuid($userid,:scalar), $username,
      'does getlogin/getpwuid give the same';
}
else {
    $username = getpwuid($userid,:scalar);
    pass "getlogin empty";
    ok $username ~~ m/^ \w+ /, 'did we get a name';
}

my @result = getpwuid($userid);
is @result[0], $username, 'did we get the username in this struct by uid';
is @result[2], $userid,   'did we get the userid in this struct by uid';

is getpwnam($username, :scalar), $userid, 'did we get the uid';
@result = getpwnam($username);
is @result[0], $username, 'did we get the username in this struct by name';
is @result[2], $userid,   'did we get the userid in this struct by name';

@result = getpwent;
ok @result, 'did we get anything from getpwent';

my int $seen = 1;
my $seen_me;
while getpwent() -> @result {
    $seen_me = True if @result[0] eq $username && @result[2] == $userid;
    ++$seen;
}
ok $seen_me, 'did we see ourselves';
is setpwent, 1, 'did we return the undocumented 1';

--$seen while getpwent;
is $seen, 0, 'did we get the same number of entries the 2nd time';
is endpwent, 1, 'did we return the undocumented 1';

is-deeply getpwnam("thisnameshouldnotexist"), (), 'non-existing name';
is getpwnam("thisnameshouldnotexist", :scalar), Nil, 'non-existing name scalar';

is-deeply getpwuid(9999), (), 'non-existing uid';
is getpwuid(9999, :scalar), Nil, 'non-existing name uid';

# vim: ft=perl6 expandtab sw=4
