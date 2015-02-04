use v6;
use Test;
use lib 'lib';
use System::Passwd::User::MacOSX;

plan 24;
my @lines =
    ['nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false',
     'nobody', '*', -2, -2, 'Unprivileged User', '/var/empty', '/usr/bin/false'],
    ['daemon:*:1:1:System Services:/var/root:/usr/bin/false',
     'daemon', '*', 1, 1, 'System Services', '/var/root', '/usr/bin/false'],
    ['_unknown:*:99:99:Unknown User:/var/empty:/usr/bin/false',
    '_unknown', '*', 99, 99, 'Unknown User', '/var/empty', '/usr/bin/false'];

for @lines -> @line
{
    ok my $user = System::Passwd::User::MacOSX.new(@line[0]), "Constructing {@line[0]}";
    is $user.username,      @line[1], "username is {@line[1]}";
    is $user.password,      @line[2], "password is {@line[2]}";
    is $user.uid,           @line[3], "uid is {@line[3]}";
    is $user.gid,           @line[4], "gid is {@line[4]}";
    is $user.fullname,      @line[5], "fullname is {@line[5]}";
    is $user.home_directory,@line[6], "home_dir is {@line[6]}";
    is $user.login_shell,   @line[7], "login_shell is {@line[7]}";
}

