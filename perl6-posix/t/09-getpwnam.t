use Test;
use POSIX;

plan 10;

{
  my $uid   = +$*USER;
  my $gid   = +$*GROUP;
  my $user  = ~$*USER;
  my $group = ~$*GROUP;

  my $pwnam = getpwnam($user);

  ok(1, "Called getpwnam('$user')");

  ok($pwnam.username eq $user, ".username eq $user");

  ok($pwnam.password.isa(Str), ".password isa Str");

  ok($pwnam.uid.isa(Int), ".uid isa Int");

  ok($pwnam.uid == $uid, ".uid == $uid");

  ok($pwnam.gid.isa(Int), ".gid isa Int");

  ok($pwnam.gid == $gid, ".gid == $gid");

  ok($pwnam.gecos.isa(Str), ".gecos isa Str");

  ok($pwnam.homedir.isa(Str), ".homedir isa Str");

  ok($pwnam.shell.isa(Str), ".shell isa Str");
}
