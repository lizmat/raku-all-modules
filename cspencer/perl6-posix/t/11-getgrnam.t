use Test;
use POSIX;

plan 5;

{
  my $name  = ~$*GROUP;
  my $gid   = +$*GROUP;
  my $group = getgrnam($name);

  ok(1, "Called getgrnam($name)");

  ok($group.name eq $name, ".name eq $name");

  ok($group.password.isa(Str), ".password isa Str");

  ok($group.gid.isa(Int), ".gid isa Int");

  ok($group.gid == $gid, ".gid == $gid");
}
