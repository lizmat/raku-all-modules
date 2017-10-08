use v6;
use Test;
use lib 'lib';
use System::Passwd;

plan 12;

# test on root user
ok my $user = get_user_by_uid(0), 'get root user by uid';
is $user.username, 'root', 'root user returned';
is $user.uid, 0, 'uid is zero';
is $user.gid, 0, 'gid is zero';

ok my $user_2 = get_user_by_username('root'), 'get root user by username';
is $user_2.username, 'root', 'root user returned';
is $user_2.uid, 0, 'uid is zero';
is $user_2.gid, 0, 'gid is zero';

my $fullname = $user_2.fullname;

ok my $user_3 = get_user_by_fullname($fullname), 'get root user by fullname';
is $user_3.username, 'root', 'root user returned';
is $user_3.uid, 0, 'uid is zero';
is $user_3.gid, 0, 'gid is zero';
